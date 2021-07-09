*! Nikolas Mittag 16Jun2012

cap program drop cdreg
program define cdreg, eclass properties(b V svyb svyr svyj)
version 11.0
if replay()==1 {
	syntax [, EForm(passthru) PLUS NOTABle NOHEader *]
	if `"`e(cmd)'"'!="cdreg" error 301
	_get_diopts diopts options, `options'
	local diopts "`diopts' `eform' `plus' `notable'"		
	if "`noheader'"=="" {
		di ""
		di in smcl as text "Linear Regression with"  _col(56) "Number of obs" as text _col(70) "=" as res %8.0g e(N)
		di in smcl as text "mismeasured variable `tname'" _col(56) "F(" %3.0f e(df_m) "," %6.0g e(df_r) ")" _col(70) "=" as res %8.2f e(F)
		di in smcl as text _col(56) "Prob > F" _col(70) "=" as res %8.4f Ftail(e(df_m),e(df_r),e(F))
		di ""
	}
	ereturn display, `diopts'
	exit
}

syntax [anything] [if] [in] [fweight aweight iweight pweight /], [PARameters(string)] [CONDVars(string)] [CONDMean(string)] [NRMean(string)] [Draws(integer 40)] [Save(string)] [MASSpoint] [MODel(string)] [PREDictors(string)] [MIXFunc(string)] [MIXPar(string)] [MIXTransf(string)] [WGTTRfunc(string)] [MPFunc(string)] [MVars(varlist)] [NRFunc(string)] [NRPar(string)] [NRTRansf(string)] [NRWgttrfunc(string)] [Keep] [VARiance(string)] [EForm(passthru)] [Level(passthru)] [NOHEader] [NOTABle] [PLUS] *

*separate options and display options
_get_diopts diopts options, `options'
local diopts "`diopts' `eform' `plus' `notable'"

*set up varlists and sample
*set up varlists
gettoken dep cov : anything
*get variables for me
gettoken tname pred : condvars
fvunab pred : `pred'
gettoken obs pred : pred
if "`mvars'"!="" unab mvars : `mvars'
local varlist=subinword("`anything'","`tname'","",.)
if wordcount("`varlist'")!=0 {
	fvunab varlist : `varlist'
	foreach var in `varlist' {
		if strmatch("`var'","*.*")==0 confirm numeric variable `var'
	}
}

*Set Sample: Exclude observations with 1.dep, cov or weight missing (here) 2. pred missing and obs not (below) 3. If NR: with mvars & obs missing, if not: with obs missing (after loc is set up)
marksample touse

*make sure variable tname does not exist already
capture confirm variable `tname', exact
if _rc==0 {
	local names "`tname'"
	tempname tname
	di as err "Variable `names' already defined, using temporary variable `tname' instead"
}
if strmatch("`dep' `cov'","*`tname'*")==0 local cov "`tname' `cov'"

*exclude obs with pred missing and obs not
foreach var of varlist `pred' {
	qui replace `touse'=0 if missing(`var')==1 & missing(`obs')==0
}

*set tempnames
tempname b v nrparv mixparv mppar npred par locmp locnr locmix mixtrloc nrtrloc nrwgttr wgttr

/*set defaults (2 comp normal mixture w/ mp, no nr) & convert optional strings*/
*if mp specified, but no function, use normal()
if "`masspoint'"!="" sca def `mppar'=1
else sca def `mppar'=0
if "`mpfunc'"=="" & `mppar'==1 local mpfunc "&mnormal()"
if "`mpfunc'"=="" & `mppar'==0 local mpfunc .
if "`mpfunc'"=="&normal()" local mpfunc "&mnormal()"
*if model() not specified and parts of me model missing
if "`model'"=="" {
	*all missing->default to mixnorm
	if "`mixfunc'"=="" & "`mixpar'"=="" & "`mixtransf'"=="" & "`wgttrfunc'"=="" {
		local mixfunc "&mrnormal()"
		mat def `mixparv'=2
	}		
	*one of mixfunc or mixpar missing->stop
	if !("`mixfunc'"!="" & "`mixpar'"!="") | ("`mixfunc'"=="" & "`mixpar'"=="" & ("`mixtransf'"!="" | "`wgttrfunc'"!="")) {
		di as error "Invalid input specified"
		exit
	}
	if "`mixpar'"!="" mat def `mixparv'=`mixpar'
}
*set nr stuff to nothing if not specified ->throw error if relevant input is missing?
if wordcount("`model'")<2 {
	if "`nrfunc'"=="" local nrfunc .
	if "`nrpar'"=="" mat def `nrparv'=0
	else mat def `nrparv'=`nrpar'
	if "`nrtransf'"=="" local nrtransf ""
	if "`nrwgttrfunc'"=="" local nrwgttrfunc ""
}

*get modified command line for bootstrap if specified
if strmatch("`variance'","*bootstrap*")==1 {
		*pass whole initial command except for bootstrap() and par()
		local opt "`masspoint'"
		if "`model'"!="" local opt "`opt' model(`model' `nrmodel')"
		foreach i in condvars condmean nrmean draws predictors mixfunc mixpar mixtransf wgttrfunc mpfunc mvars nrfunc nrpar nrtransf nrwgttrfunc {
			if "``i''"!="" & "``i''"!="." local opt `"`opt' `i'(``i'')"'
		}
}

*shortcuts to common models using model()
*split model option into me and nr
if wordcount("`model'")==2 {
	local nrmodel=lower(word("`model'",2))
	local model=lower(word("`model'",1))
	local model=subinstr("`model'",",","",.)
	if "`mvars'"=="" {
		di as res "Option mvars() not specified, using only constants in `nrmodel' for missing values"
	}
}

*set up counter for position in xb
if "`masspoint'"!="" {
	local k=1
	local cm "select(xb[,1],sme):*select(obs,sme)"
}
else {
	local k=0
	local cm ""
}

*default model for nr if variables specified, but no model->prevent this from overriding manual specification?
if "`nrmodel'"=="" & "`mvars'"!="" & "`nrpar'"=="" {
	local nrmodel "mixnorm"
	di as res "Variables for Non-Response specified, but no model. Assuming mixture of two normals."
}
*setup model for non-response
if (inlist("`nrmodel'","normal","mixnorm","exp","mixexp","weibull","mixweibull","t","mixt","mixweit")==1 | inlist("`nrmodel'","trnorm","ltrnorm","rtrnorm","mixtrnorm","mixltrnorm","mixrtrnorm")==1) {
if "`nrmodel'"=="normal" {
	mat def `nrparv'=2
	local cmnr "select(xb[,`k'+1],snr)"
	local nrfunc "&mrnormal()"
	local dcmnr1 "(Z,J(rows(Z),1,0))"
}	
if "`nrmodel'"=="mixnorm" {
	mat def `nrparv'=(2,2)
	local cmnr "nrwgt[1,1]:*select(xb[,`k'+1],snr)+nrwgt[1,2]:*select(xb[,`k'+3],snr)"
	local nrfunc "&mrnormal(),&mrnormal()"
	local dcmnr1 "(nrwgt[1,1]:*Z,J(rows(Z),1,0),nrwgt[1,2]:*Z,J(rows(Z),1,0),xb[,`k'+3]-xb[,`k'+1]"
}
if "`nrmodel'"=="trnorm" {
	mat def `nrparv'=4
	local cmnr "select(xb[,`k'+1],snr)+(select(xb[,`k'+2],snr):^2):*(normalden(select(xb[,`k'+3],snr),select(xb[,`k'+1],snr),select(xb[,`k'+2],snr))-normalden(select(xb[,`k'+4],snr),select(xb[,`k'+1],snr),select(xb[,`k'+2],snr))):/(normal((select(xb[,`k'+4],snr)-select(xb[,`k'+1],snr)):/select(xb[,`k'+2],snr))-normal((select(xb[,`k'+3],snr)-select(xb[,`k'+1],snr)):/select(xb[,`k'+2],snr)))"
	local nrfunc "&rtrnormal()"
	local dcmnr1 "(Z:*(1:-(((xb[,`k'+4]-xb[,`k'+1]):/xb[,`k'+2]:*normalden((xb[,`k'+4]-xb[,`k'+1]):/xb[,`k'+2])-(xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2]:*normalden((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2])):*(normal((xb[,`k'+4]-xb[,`k'+1]):/xb[,`k'+2])-normal((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2]))+(normalden((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2])-normalden((xb[,`k'+4]-xb[,`k'+1]):/xb[,`k'+2])):^2):/(normal((xb[,`k'+4]-xb[,`k'+1]):/xb[,`k'+2])-normal((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2])):^2))" // derivative wrt beta
	local dcmnr2 "(1:/(normal((xb[,`k'+4]-xb[,`k'+1]):/xb[,`k'+2])-normal((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2])):*((normalden((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2])-normalden((xb[,`k'+4]-xb[,`k'+1]):/xb[,`k'+2])):*(1:-(((xb[,`k'+3]-xb[,`k'+1]):*normalden((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2])-(xb[,`k'+4]-xb[,`k'+1]):*normalden((xb[,`k'+4]-xb[,`k'+1]):/xb[,`k'+2])):/xb[,`k'+2]):/(normal((xb[,`k'+4]-xb[,`k'+1]):/xb[,`k'+2])-normal((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2])))+(((xb[,`k'+3]-xb[,`k'+1]):^2:*normalden((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2])-(xb[,`k'+4]-xb[,`k'+1]):^2:*normalden((xb[,`k'+4]-xb[,`k'+1]):/xb[,`k'+2])):/xb[,`k'+2]:^2)))"
	local dcmnr3 "(normalden((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2]):*((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2]:*(normal((xb[,`k'+4]-xb[,`k'+1]):/xb[,`k'+2])-normal((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2]))+normalden((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2])-normalden((xb[,`k'+4]-xb[,`k'+1]):/xb[,`k'+2])):/(normal((xb[,`k'+4]-xb[,`k'+1]):/xb[,`k'+2])-normal((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2])):^2)" // derivative wrt left truncation point
	local dcmnr4 "(-normalden((xb[,`k'+4]-xb[,`k'+1]):/xb[,`k'+2]):*((xb[,`k'+4]-xb[,`k'+1]):/xb[,`k'+2]:*(normal((xb[,`k'+4]-xb[,`k'+1]):/xb[,`k'+2])-normal((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2]))+normalden((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2])-normalden((xb[,`k'+4]-xb[,`k'+1]):/xb[,`k'+2])):/(normal((xb[,`k'+4]-xb[,`k'+1]):/xb[,`k'+2])-normal((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2])):^2)" // derivative wrt right truncation point
}
if "`nrmodel'"=="mixtrnorm" {
	mat def `nrparv'=(4,4)
	local cmnr "nrwgt[1,1]:*(select(xb[,`k'+1],snr)+(select(xb[,`k'+2],snr):^2):*(normalden(select(xb[,`k'+3],snr),select(xb[,`k'+1],snr),select(xb[,`k'+2],snr))-normalden(select(xb[,`k'+4],snr),select(xb[,`k'+1],snr),select(xb[,`k'+2],snr))):/(normal((select(xb[,`k'+4],snr)-select(xb[,`k'+1],snr)):/select(xb[,`k'+2],snr))-normal((select(xb[,`k'+3],snr)-select(xb[,`k'+1],snr)):/select(xb[,`k'+2],snr))))+nrwgt[1,2]:*(select(xb[,`k'+5],snr)+(select(xb[,`k'+6],snr):^2):*(normalden(select(xb[,`k'+7],snr),select(xb[,`k'+5],snr),select(xb[,`k'+6],snr))-normalden(select(xb[,`k'+8],snr),select(xb[,`k'+5],snr),select(xb[,`k'+6],snr))):/(normal((select(xb[,`k'+8],snr)-select(xb[,`k'+5],snr)):/select(xb[,`k'+6],snr))-normal((select(xb[,`k'+7],snr)-select(xb[,`k'+5],snr)):/select(xb[,`k'+6],snr))))"
	local nrfunc "&rtrnormal(),&rtrnormal()"
	local dcmnr1 "nrwgt[1,1]:*(Z:*(1:-(((xb[,`k'+4]-xb[,`k'+1]):/xb[,`k'+2]:*normalden((xb[,`k'+4]-xb[,`k'+1]):/xb[,`k'+2])-(xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2]:*normalden((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2])):*(normal((xb[,`k'+4]-xb[,`k'+1]):/xb[,`k'+2])-normal((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2]))+(normalden((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2])-normalden((xb[,`k'+4]-xb[,`k'+1]):/xb[,`k'+2])):^2):/(normal((xb[,`k'+4]-xb[,`k'+1]):/xb[,`k'+2])-normal((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2])):^2))" // derivative wrt beta
	local dcmnr2 "nrwgt[1,1]:*(1:/(normal((xb[,`k'+4]-xb[,`k'+1]):/xb[,`k'+2])-normal((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2])):*((normalden((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2])-normalden((xb[,`k'+4]-xb[,`k'+1]):/xb[,`k'+2])):*(1:-(((xb[,`k'+3]-xb[,`k'+1]):*normalden((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2])-(xb[,`k'+4]-xb[,`k'+1]):*normalden((xb[,`k'+4]-xb[,`k'+1]):/xb[,`k'+2])):/xb[,`k'+2]):/(normal((xb[,`k'+4]-xb[,`k'+1]):/xb[,`k'+2])-normal((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2])))+(((xb[,`k'+3]-xb[,`k'+1]):^2:*normalden((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2])-(xb[,`k'+4]-xb[,`k'+1]):^2:*normalden((xb[,`k'+4]-xb[,`k'+1]):/xb[,`k'+2])):/xb[,`k'+2]:^2)))"
	local dcmnr3 "nrwgt[1,1]:*(normalden((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2]):*((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2]:*(normal((xb[,`k'+4]-xb[,`k'+1]):/xb[,`k'+2])-normal((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2]))+normalden((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2])-normalden((xb[,`k'+4]-xb[,`k'+1]):/xb[,`k'+2])):/(normal((xb[,`k'+4]-xb[,`k'+1]):/xb[,`k'+2])-normal((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2])):^2)" // derivative wrt left truncation point
	local dcmnr4 "nrwgt[1,1]:*(-normalden((xb[,`k'+4]-xb[,`k'+1]):/xb[,`k'+2]):*((xb[,`k'+4]-xb[,`k'+1]):/xb[,`k'+2]:*(normal((xb[,`k'+4]-xb[,`k'+1]):/xb[,`k'+2])-normal((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2]))+normalden((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2])-normalden((xb[,`k'+4]-xb[,`k'+1]):/xb[,`k'+2])):/(normal((xb[,`k'+4]-xb[,`k'+1]):/xb[,`k'+2])-normal((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2])):^2)" // derivative wrt right truncation point
	local dcmnr5 "nrwgt[1,2]:*(Z:*(1:-(((xb[,`k'+8]-xb[,`k'+5]):/xb[,`k'+6]:*normalden((xb[,`k'+8]-xb[,`k'+5]):/xb[,`k'+6])-(xb[,`k'+7]-xb[,`k'+5]):/xb[,`k'+6]:*normalden((xb[,`k'+7]-xb[,`k'+5]):/xb[,`k'+6])):*(normal((xb[,`k'+8]-xb[,`k'+5]):/xb[,`k'+6])-normal((xb[,`k'+7]-xb[,`k'+5]):/xb[,`k'+6]))+(normalden((xb[,`k'+7]-xb[,`k'+5]):/xb[,`k'+6])-normalden((xb[,`k'+8]-xb[,`k'+5]):/xb[,`k'+6])):^2):/(normal((xb[,`k'+8]-xb[,`k'+5]):/xb[,`k'+6])-normal((xb[,`k'+7]-xb[,`k'+5]):/xb[,`k'+6])):^2))" // derivative wrt beta
	local dcmnr6 "nrwgt[1,2]:*(1:/(normal((xb[,`k'+8]-xb[,`k'+5]):/xb[,`k'+6])-normal((xb[,`k'+7]-xb[,`k'+5]):/xb[,`k'+6])):*((normalden((xb[,`k'+7]-xb[,`k'+5]):/xb[,`k'+6])-normalden((xb[,`k'+8]-xb[,`k'+5]):/xb[,`k'+6])):*(1:-(((xb[,`k'+7]-xb[,`k'+5]):*normalden((xb[,`k'+7]-xb[,`k'+5]):/xb[,`k'+6])-(xb[,`k'+8]-xb[,`k'+5]):*normalden((xb[,`k'+8]-xb[,`k'+5]):/xb[,`k'+6])):/xb[,`k'+6]):/(normal((xb[,`k'+8]-xb[,`k'+5]):/xb[,`k'+6])-normal((xb[,`k'+7]-xb[,`k'+5]):/xb[,`k'+6])))+(((xb[,`k'+7]-xb[,`k'+5]):^2:*normalden((xb[,`k'+7]-xb[,`k'+5]):/xb[,`k'+6])-(xb[,`k'+7]-xb[,`k'+5]):^2:*normalden((xb[,`k'+8]-xb[,`k'+5]):/xb[,`k'+6])):/xb[,`k'+6]:^2)))"
	local dcmnr7 "nrwgt[1,2]:*(normalden((xb[,`k'+7]-xb[,`k'+5]):/xb[,`k'+6]):*((xb[,`k'+7]-xb[,`k'+5]):/xb[,`k'+6]:*(normal((xb[,`k'+8]-xb[,`k'+5]):/xb[,`k'+6])-normal((xb[,`k'+7]-xb[,`k'+5]):/xb[,`k'+6]))+normalden((xb[,`k'+7]-xb[,`k'+5]):/xb[,`k'+6])-normalden((xb[,`k'+8]-xb[,`k'+5]):/xb[,`k'+6])):/(normal((xb[,`k'+8]-xb[,`k'+5]):/xb[,`k'+6])-normal((xb[,`k'+7]-xb[,`k'+5]):/xb[,`k'+6])):^2)" // derivative wrt left truncation point
	local dcmnr8 "nrwgt[1,2]:*(-normalden((xb[,`k'+8]-xb[,`k'+5]):/xb[,`k'+6]):*((xb[,`k'+8]-xb[,`k'+5]):/xb[,`k'+6]:*(normal((xb[,`k'+8]-xb[,`k'+5]):/xb[,`k'+6])-normal((xb[,`k'+7]-xb[,`k'+5]):/xb[,`k'+6]))+normalden((xb[,`k'+7]-xb[,`k'+5]):/xb[,`k'+6])-normalden((xb[,`k'+8]-xb[,`k'+5]):/xb[,`k'+6])):/(normal((xb[,`k'+8]-xb[,`k'+5]):/xb[,`k'+6])-normal((xb[,`k'+7]-xb[,`k'+5]):/xb[,`k'+6])):^2)" // derivative wrt right truncation point
	local dcmnr9 "(xb[,`k'+5]+(xb[,`k'+6]:^2):*(normalden(xb[,`k'+7],xb[,`k'+5],xb[,`k'+6])-normalden(xb[,`k'+8],xb[,`k'+5],xb[,`k'+6])):/(normal((xb[,`k'+8]-xb[,`k'+5]):/xb[,`k'+6])-normal((xb[,`k'+7]-xb[,`k'+5]):/xb[,`k'+6])))-(xb[,`k'+1]+(xb[,`k'+2]:^2):*(normalden(xb[,`k'+3],xb[,`k'+1],xb[,`k'+2])-normalden(xb[,`k'+4],xb[,`k'+1],xb[,`k'+2])):/(normal((xb[,`k'+4]-xb[,`k'+1]):/xb[,`k'+2])-normal((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2])))" //derivative wrt weight
}
if "`nrmodel'"=="ltrnorm" {
	mat def `nrparv'=3
	local cmnr "select(xb[,`k'+1],snr)+(select(xb[,`k'+2],snr):^2):*normalden(select(xb[,`k'+3],snr),select(xb[,`k'+1],snr),select(xb[,`k'+2],snr)):/(1:-normal((select(xb[,`k'+3],snr)-select(xb[,`k'+1],snr)):/select(xb[,`k'+2],snr)))"	
	local nrfunc "&rltrnormal()"
	local dcmnr1 "(Z:*(1:-((-(xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2]:*normalden((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2])):*(1:-normal((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2]))+normalden((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2]):^2):/(1:-normal((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2])):^2))" // derivative wrt beta
	local dcmnr2 "(normalden((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2]):/(1:-normal((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2])):*(1:+((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2]):^2-((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2]):*normalden((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2]):/(1:-normal((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2]))))" // derivative wrt sigma
	local dcmnr3 "(normalden((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2]):*((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2]:*(1:-normal((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2]))+normalden((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2])):/(1:-normal((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2])):^2)" // derivative wrt left truncation point
}
if "`nrmodel'"=="mixltrnorm" {
	mat def `nrparv'=(3,3)
	local cmnr "nrwgt[1,1]:*(select(xb[,`k'+1],snr)+(select(xb[,`k'+2],snr):^2):*normalden(select(xb[,`k'+3],snr),select(xb[,`k'+1],snr),select(xb[,`k'+2],snr)):/(1:-normal((select(xb[,`k'+3],snr)-select(xb[,`k'+1],snr)):/select(xb[,`k'+2],snr))))+nrwgt[1,2]:*(select(xb[,`k'+4],snr)+(select(xb[,`k'+5],snr):^2):*normalden(select(xb[,`k'+6],snr),select(xb[,`k'+4],snr),select(xb[,`k'+5],snr)):/(1:-normal((select(xb[,`k'+6],snr)-select(xb[,`k'+4],snr)):/select(xb[,`k'+5],snr))))"	
	local nrfunc "&rltrnormal(),&rltrnormal()"
	local dcmnr1 "nrwgt[1,1]:*(Z:*(1:-((-(xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2]:*normalden((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2])):*(1:-normal((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2]))+normalden((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2]):^2):/(1:-normal((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2])):^2))" // derivative wrt beta
	local dcmnr2 "nrwgt[1,1]:*(normalden((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2]):/(1:-normal((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2])):*(1:+((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2]):^2-((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2]):*normalden((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2]):/(1:-normal((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2]))))" // derivative wrt sigma
	local dcmnr3 "nrwgt[1,1]:*(normalden((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2]):*((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2]:*(1:-normal((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2]))+normalden((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2])):/(1:-normal((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2])):^2)" // derivative wrt left truncation point
	local dcmnr4 "nrwgt[1,2]:*(Z:*(1:-((-(xb[,`k'+6]-xb[,`k'+4]):/xb[,`k'+5]:*normalden((xb[,`k'+6]-xb[,`k'+4]):/xb[,`k'+5])):*(1:-normal((xb[,`k'+6]-xb[,`k'+4]):/xb[,`k'+5]))+normalden((xb[,`k'+6]-xb[,`k'+4]):/xb[,`k'+5]):^2):/(1:-normal((xb[,`k'+6]-xb[,`k'+4]):/xb[,`k'+5])):^2))" // derivative wrt beta
	local dcmnr5 "nrwgt[1,2]:*(normalden((xb[,`k'+6]-xb[,`k'+4]):/xb[,`k'+5]):/(1:-normal((xb[,`k'+6]-xb[,`k'+4]):/xb[,`k'+5])):*(1:+((xb[,`k'+6]-xb[,`k'+4]):/xb[,`k'+5]):^2-((xb[,`k'+6]-xb[,`k'+4]):/xb[,`k'+5]):*normalden((xb[,`k'+6]-xb[,`k'+4]):/xb[,`k'+5]):/(1:-normal((xb[,`k'+6]-xb[,`k'+4]):/xb[,`k'+5]))))" // derivative wrt sigma
	local dcmnr6 "nrwgt[1,2]:*(normalden((xb[,`k'+6]-xb[,`k'+4]):/xb[,`k'+5]):*((xb[,`k'+6]-xb[,`k'+4]):/xb[,`k'+5]:*(1:-normal((xb[,`k'+6]-xb[,`k'+4]):/xb[,`k'+5]))+normalden((xb[,`k'+6]-xb[,`k'+4]):/xb[,`k'+5])):/(1:-normal((xb[,`k'+6]-xb[,`k'+4]):/xb[,`k'+5])):^2)" // derivative wrt left truncation point
	local dcmnr7 "(xb[,`k'+4]+xb[,`k'+5]:*normalden((xb[,`k'+6]-xb[,`k'+4]):/xb[,`k'+5]):/(1:-normal((xb[,`k'+6]-xb[,`k'+4]):/xb[,`k'+5]))-(xb[,`k'+1]+xb[,`k'+2]:*normalden((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2]):/(1:-normal((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2]))))" // derivative wrt weight
}
if "`nrmodel'"=="rtrnorm" {
	mat def `nrparv'=3
	local cmnr "select(xb[,`k'+1],snr)-(select(xb[,`k'+2],snr):^2):*normalden(select(xb[,`k'+3],snr),select(xb[,`k'+1],snr),select(xb[,`k'+2],snr)):/normal((select(xb[,`k'+3],snr)-select(xb[,`k'+1],snr)):/select(xb[,`k'+2],snr))"	
	local nrfunc "&rrtrnormal()"
	local dcmnr1 "(Z:*(1:-(((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2]:*normalden((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2]):*normal((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2])+(normalden((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2]):^2)):/normal((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2]):^2)))" // derivative wrt beta
	local dcmnr2 "(-(normalden((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2]):/normal((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2])):*(1:+((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2]):^2+(xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2]:*normalden((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2]):/normal((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2])))"
	local dcmnr3 "(-normalden((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2]):*((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2]:*normal((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2])-normalden((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2])):/(normal((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2])):^2)" // derivative wrt right truncation point
}
if "`nrmodel'"=="mixrtrnorm" {
	mat def `nrparv'=(3,3)
	local cmnr "nrwgt[1,1]:*(select(xb[,`k'+1],snr)-(select(xb[,`k'+2],snr):^2):*normalden(select(xb[,`k'+3],snr),select(xb[,`k'+1],snr),select(xb[,`k'+2],snr)):/normal((select(xb[,`k'+3],snr)-select(xb[,`k'+1],snr)):/select(xb[,`k'+2],snr)))+nrwgt[1,2]:*(select(xb[,`k'+4],snr)-(select(xb[,`k'+5],snr):^2):*normalden(select(xb[,`k'+6],snr),select(xb[,`k'+4],snr),select(xb[,`k'+5],snr)):/normal((select(xb[,`k'+6],snr)-select(xb[,`k'+4],snr)):/select(xb[,`k'+5],snr)))"	
	local nrfunc "&rrtrnormal(),&rrtrnormal()"
	local dcmnr1 "nrwgt[1,1]:*(Z:*(1:-(((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2]:*normalden((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2]):*normal((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2])+(normalden((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2]):^2)):/normal((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2]):^2)))" // derivative wrt beta
	local dcmnr2 "nrwgt[1,1]:*(-(normalden((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2]):/normal((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2])):*(1:+((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2]):^2+(xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2]:*normalden((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2]):/normal((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2])))"
	local dcmnr3 "nrwgt[1,1]:*(-normalden((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2]):*((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2]:*normal((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2])-normalden((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2])):/(normal((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2])):^2)" // derivative wrt right truncation point
	local dcmnr4 "nrwgt[1,2]:*(Z:*(1:-(((xb[,`k'+6]-xb[,`k'+4]):/xb[,`k'+5]:*normalden((xb[,`k'+6]-xb[,`k'+4]):/xb[,`k'+5]):*normal((xb[,`k'+6]-xb[,`k'+4]):/xb[,`k'+5])+(normalden((xb[,`k'+6]-xb[,`k'+4]):/xb[,`k'+5]):^2)):/normal((xb[,`k'+6]-xb[,`k'+4]):/xb[,`k'+5]):^2)))" // derivative wrt beta
	local dcmnr5 "nrwgt[1,2]:*(-(normalden((xb[,`k'+6]-xb[,`k'+4]):/xb[,`k'+5]):/normal((xb[,`k'+6]-xb[,`k'+4]):/xb[,`k'+5])):*(1:+((xb[,`k'+6]-xb[,`k'+4]):/xb[,`k'+5]):^2+(xb[,`k'+6]-xb[,`k'+4]):/xb[,`k'+5]:*normalden((xb[,`k'+6]-xb[,`k'+4]):/xb[,`k'+5]):/normal((xb[,`k'+6]-xb[,`k'+4]):/xb[,`k'+5])))"
	local dcmnr6 "nrwgt[1,2]:*(-normalden((xb[,`k'+6]-xb[,`k'+4]):/xb[,`k'+5]):*((xb[,`k'+6]-xb[,`k'+4]):/xb[,`k'+5]:*normal((xb[,`k'+6]-xb[,`k'+4]):/xb[,`k'+5])-normalden((xb[,`k'+6]-xb[,`k'+4]):/xb[,`k'+5])):/(normal((xb[,`k'+6]-xb[,`k'+4]):/xb[,`k'+5])):^2)" // derivative wrt right truncation point
	local dcmnr7 "((xb[,`k'+4]+xb[,`k'+5]:*normalden((xb[,`k'+6]-xb[,`k'+4]):/xb[,`k'+5]):/normal((xb[,`k'+6]-xb[,`k'+4]):/xb[,`k'+5]))-(xb[,`k'+1]+xb[,`k'+2]:*normalden((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2]):/normal((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2])))" // derivative wrt weight
}
if "`nrmodel'"=="exp" {
	local nrtransf "1,2,&mexp()"
	mat def `nrparv'=2
	local nrfunc "&rexploc()"	
	local cmnr "select(xb[,`k'+1],snr)+1:/select(xb[,`k'+2],snr)"
	local dcmnr1 "(J(rows(Z),1,1),-Z:/((xb[,`k'+2]):^2))"
}	
if "`nrmodel'"=="mixexp" {
	local nrtransf "1,2,&mexp(),2,2,&mexp()"
	mat def `nrparv'=(2,2)
	local nrfunc "&rexploc(),&rexploc()"
	local cmnr "nrwgt[1,1]:*(select(xb[,`k'+1],snr)+1:/select(xb[,`k'+2],snr))+nrwgt[1,2]:*(select(xb[,`k'+1],snr)+1:/select(xb[,`k'+2],snr))"
	local dcmnr1 "(J(rows(Z),1,nrwgt[1,1]),-nrwgt[1,1]:*Z:/((xb[,`k'+2]):^2),J(rows(Z),1,nrwgt[1,2]),-nrwgt[1,2]:*Z:/((xb[,`k'+4]):^2),xb[,`k'+3]-xb[,`k'+1]+1:/xb[,`k'+4]-1:/xb[,`k'+2])"
}	
if "`nrmodel'"=="weibull" {
	local nrtransf "1,3,&mexp()"
	mat def `nrparv'=3
	local nrfunc "&rweibloc()"
	local cmnr "select(xb[,`k'+1],snr)+select(xb[,`k'+3],snr):*gamma(1:+1:/select(xb[,`k'+2],snr))"
	local dcmnr1 "(J(rows(Z),1,1),Z:*gamma(1:+1:/xb[,`k'+2]),-(xb[,`k'+2]):^(-2):*xb[,`k'+3]:*gamma(1:+1:/xb[,`k'+2]):*digamma(1:+1:/xb[,`k'+2]))"
}
if "`nrmodel'"=="mixweibull" {
	local nrtransf "1,3,&mexp(),2,3,&mexp()"
	mat def `nrparv'=(3,3)
	local nrfunc "&rweibloc(),&rweibloc()"
	local cmnr "nrwgt[1,1]:*(select(xb[,`k'+1],snr)+select(xb[,`k'+3],snr):*gamma(1:+1:/select(xb[,`k'+2],snr)))+nrwgt[1,2]:*(select(xb[,`k'+1],snr)+select(xb[,`k'+3],snr):*gamma(1:+1:/select(xb[,`k'+2],snr)))"
	local dcmnr1 "(J(rows(Z),1,nrwgt[1,1]),nrwgt[1,1]:*Z:*gamma(1:+1:/xb[,`k'+2]),-nrwgt[1,1]:*(xb[,`k'+2]):^(-2):*xb[,`k'+3]:*gamma(1:+1:/xb[,`k'+2]):*digamma(1:+1:/xb[,`k'+2]))"
	local dcmnr2 "(J(rows(Z),1,nrwgt[1,2]),nrwgt[1,2]:*Z:*gamma(1:+1:/xb[,`k'+5]),-nrwgt[1,2]:*(xb[,`k'+5]):^(-2):*xb[,`k'+6]:*gamma(1:+1:/xb[,`k'+5]):*digamma(1:+1:/xb[,`k'+5]),xb[,`k'+4]+xb[,`k'+6]:*gamma(1:+1:/xb[,`k'+5])-(xb[,`k'+1]+xb[,`k'+3]:*gamma(1:+1:/xb[,`k'+2])))"
}
if "`nrmodel'"=="t" {
	mat def `nrparv'=3
	local nrfunc "&rgent()"
	local cmnr "select(xb[,`k'+1],snr)"
	local dcmnr1 "(Z,J(rows(Z),2,0))"
}
if "`nrmodel'"=="mixt" {
	mat def `nrparv'=(3,3)
	local nrfunc "&rgent(),&rgent()"
	local cmnr "nrwgt[1,1]:*select(xb[,`k'+1],snr)+nrwgt[1,2]:*select(xb[,`k'+4],snr)"
	local dcmnr1 "(nrwgt[1,1]:*Z,J(rows(Z),2,0),nrwgt[1,2]:*Z,J(rows(Z),2,0),xb[,`k'+3]-xb[,`k'+1]"
}
if "`nrmodel'"=="mixweit" {
	mat def `nrparv'=(3,3)
	local nrfunc "&rgent(),&rweibloc()"
	local cmnr "nrwgt[1,1]:*select(xb[,`k'+1],snr)+nrwgt[1,2]:*(select(xb[,`k'+4],snr)+select(xb[,`k'+5],snr):*gamma(1:+1:/select(xb[,`k'+6],snr)))"
	local dcmnr1 "(nrwgt[1,1]:*Z,J(rows(Z),2,0),J(rows(Z),1,nrwgt[1,2]),nrwgt[1,2]:*Z:*gamma(1:+1:/xb[,`k'+5]),-nrwgt[1,2]:*(xb[,`k'+5]):^(-2):*xb[,`k'+6]:*gamma(1:+1:/xb[,`k'+5]):*digamma(1:+1:/xb[,`k'+5]),xb[,`k'+4]+xb[,`k'+6]:*gamma(1:+1:/xb[,`k'+5])-xb[,`k'+1])"
}
}
else if "`nrmodel'"!="" {
	di as err "Invalid argument for missing values in option model(): `nrmodel'"
	exit
}
mat def `b'=`nrparv'*J(colsof(`nrparv'),rowsof(`nrparv'),1)
local k=`k'+`b'[1,1]

*model definitions for measurement error
if (inlist("`model'","normal","mixnorm","exp","mixexp","weibull","mixweibull","t","mixt","mixweit")==1 | inlist("`model'","auto","trnorm","ltrnorm","rtrnorm","mixtrnorm","mixltrnorm","mixrtrnorm")==1) {
if "`cm'"!="" local cm="`cm'+"
if "`model'"=="auto" {
	mat def `par'=e(b)
	local mixfunc=e(mixfunc)
	mat def `mixparv'=e(mixpar)
	local mixtransf=e(mixtransf)
	local wgttrfunc=e(wgttrfunc)
	mat def `nrparv'=e(nrpar)
	mat def `npred'=e(predictors)
	local nrfunc=e(nrfunc)
	local nrtransf=e(nrtransf)
	local nrwgttrfunc=e(nrwgttrfunc)
}
if "`model'"=="normal" {
	mat def `mixparv'=2
	local mixfunc "&mrnormal()"
	local cm "`cm'(1:-mp):*select(xb[,`k'+1],sme)"
	local cmd "xb[,`k'+1]"
	local dcm1 "(Z,J(rows(Z),1,0))"
}
if "`model'"=="mixnorm" {
	mat def `mixparv'=2
	local mixfunc "&mrnormal()"
	local cm "`cm'(1:-mp):*(wgt[1,1]:*select(xb[,`k'+1],sme)+wgt[1,2]*select(xb[,`k'+3],sme))"
	local cmd "wgt[1,1]:*xb[,`k'+1]+wgt[1,2]:*xb[,`k'+3]"
	local dcm1 "(wgt[1,1]:*Z,J(rows(Z),1,0),wgt[1,2]:*Z,J(rows(Z),1,0),xb[,`k'+3]-xb[,`k'+1]"
}
if "`model'"=="trnorm" {
	mat def `mixparv'=4
	local nrfunc "&rtrnormal()"
	local cm "`cm'(1:-mp):*(select(xb[,`k'+1],sme)+(select(xb[,`k'+2],sme):^2):*(normalden(select(xb[,`k'+3],sme),select(xb[,`k'+1],sme),select(xb[,`k'+2],sme))-normalden(select(xb[,`k'+4],sme),select(xb[,`k'+1],sme),select(xb[,`k'+2],sme))):/(normal((select(xb[,`k'+4],sme)-select(xb[,`k'+1],sme)):/select(xb[,`k'+2],sme))-normal((select(xb[,`k'+3],sme)-select(xb[,`k'+1],sme)):/select(xb[,`k'+2],sme))))"
	local cmd "xb[,`k'+1]+xb[,`k'+2]:*(normalden((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2])-normalden(xb[,`k'+4]-xb[,`k'+1]):/xb[,`k'+2])):/(normal((xb[,`k'+4]-xb[,`k'+1]):/xb[,`k'+2])-normal((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2]))"
	local dcm1 "(Z:*(1:-(((xb[,`k'+4]-xb[,`k'+1]):/xb[,`k'+2]:*normalden((xb[,`k'+4]-xb[,`k'+1]):/xb[,`k'+2])-(xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2]:*normalden((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2])):*(normal((xb[,`k'+4]-xb[,`k'+1]):/xb[,`k'+2])-normal((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2]))+(normalden((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2])-normalden((xb[,`k'+4]-xb[,`k'+1]):/xb[,`k'+2])):^2):/(normal((xb[,`k'+4]-xb[,`k'+1]):/xb[,`k'+2])-normal((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2])):^2))" // derivative wrt beta
	local dcm2 "(1:/(normal((xb[,`k'+4]-xb[,`k'+1]):/xb[,`k'+2])-normal((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2])):*((normalden((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2])-normalden((xb[,`k'+4]-xb[,`k'+1]):/xb[,`k'+2])):*(1:-(((xb[,`k'+3]-xb[,`k'+1]):*normalden((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2])-(xb[,`k'+4]-xb[,`k'+1]):*normalden((xb[,`k'+4]-xb[,`k'+1]):/xb[,`k'+2])):/xb[,`k'+2]):/(normal((xb[,`k'+4]-xb[,`k'+1]):/xb[,`k'+2])-normal((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2])))+(((xb[,`k'+3]-xb[,`k'+1]):^2:*normalden((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2])-(xb[,`k'+4]-xb[,`k'+1]):^2:*normalden((xb[,`k'+4]-xb[,`k'+1]):/xb[,`k'+2])):/xb[,`k'+2]:^2)))"
	local dcm3 "(normalden((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2]):*((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2]:*(normal((xb[,`k'+4]-xb[,`k'+1]):/xb[,`k'+2])-normal((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2]))+normalden((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2])-normalden((xb[,`k'+4]-xb[,`k'+1]):/xb[,`k'+2])):/(normal((xb[,`k'+4]-xb[,`k'+1]):/xb[,`k'+2])-normal((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2])):^2)" // derivative wrt left truncation point
	local dcm4 "(-normalden((xb[,`k'+4]-xb[,`k'+1]):/xb[,`k'+2]):*((xb[,`k'+4]-xb[,`k'+1]):/xb[,`k'+2]:*(normal((xb[,`k'+4]-xb[,`k'+1]):/xb[,`k'+2])-normal((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2]))+normalden((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2])-normalden((xb[,`k'+4]-xb[,`k'+1]):/xb[,`k'+2])):/(normal((xb[,`k'+4]-xb[,`k'+1]):/xb[,`k'+2])-normal((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2])):^2)" // derivative wrt right truncation point
}
if "`model'"=="mixtrnorm" {
	mat def `mixparv'=4
	local mixfunc "&rtrnormal()"
	local cm "`cm'(1:-mp):*(wgt[1,1]:*(select(xb[,`k'+1],sme)+(select(xb[,`k'+2],sme):^2):*(normalden(select(xb[,`k'+3],sme),select(xb[,`k'+1],sme),select(xb[,`k'+2],sme))-normalden(select(xb[,`k'+4],sme),select(xb[,`k'+1],sme),select(xb[,`k'+2],sme))):/(normal((select(xb[,`k'+4],sme)-select(xb[,`k'+1],sme)):/select(xb[,`k'+2],sme))-normal((select(xb[,`k'+3],sme)-select(xb[,`k'+1],sme)):/select(xb[,`k'+2],sme))))+wgt[1,2]:*(select(xb[,`k'+5],sme)+(select(xb[,`k'+6],sme):^2):*(normalden(select(xb[,`k'+7],sme),select(xb[,`k'+5],sme),select(xb[,`k'+6],sme))-normalden(select(xb[,`k'+8],sme),select(xb[,`k'+5],sme),select(xb[,`k'+6],sme))):/(normal((select(xb[,`k'+8],sme)-select(xb[,`k'+5],sme)):/select(xb[,`k'+6],sme))-normal((select(xb[,`k'+7],sme)-select(xb[,`k'+5],sme)):/select(xb[,`k'+6],sme)))))"
	local cmd "wgt[1,1]:*(xb[,`k'+1]+(xb[,`k'+2]:^2):*(normalden(xb[,`k'+3],xb[,`k'+1],xb[,`k'+2])-normalden(xb[,`k'+4],xb[,`k'+1],xb[,`k'+2])):/(normal((xb[,`k'+4]-xb[,`k'+1]):/xb[,`k'+2])-normal((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2])))+wgt[1,2]:*(xb[,`k'+5]+(xb[,`k'+6]:^2):*(normalden(xb[,`k'+7],xb[,`k'+5],xb[,`k'+6])-normalden(xb[,`k'+8],xb[,`k'+5],xb[,`k'+6])):/(normal((xb[,`k'+8]-xb[,`k'+5]):/xb[,`k'+6])-normal((xb[,`k'+7]-xb[,`k'+5]):/xb[,`k'+6])))"
	local dcm1 "wgt[1,1]:*(Z:*(1:-(((xb[,`k'+4]-xb[,`k'+1]):/xb[,`k'+2]:*normalden((xb[,`k'+4]-xb[,`k'+1]):/xb[,`k'+2])-(xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2]:*normalden((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2])):*(normal((xb[,`k'+4]-xb[,`k'+1]):/xb[,`k'+2])-normal((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2]))+(normalden((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2])-normalden((xb[,`k'+4]-xb[,`k'+1]):/xb[,`k'+2])):^2):/(normal((xb[,`k'+4]-xb[,`k'+1]):/xb[,`k'+2])-normal((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2])):^2))" // derivative wrt beta
	local dcm2 "wgt[1,1]:*(1:/(normal((xb[,`k'+4]-xb[,`k'+1]):/xb[,`k'+2])-normal((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2])):*((normalden((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2])-normalden((xb[,`k'+4]-xb[,`k'+1]):/xb[,`k'+2])):*(1:-(((xb[,`k'+3]-xb[,`k'+1]):*normalden((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2])-(xb[,`k'+4]-xb[,`k'+1]):*normalden((xb[,`k'+4]-xb[,`k'+1]):/xb[,`k'+2])):/xb[,`k'+2]):/(normal((xb[,`k'+4]-xb[,`k'+1]):/xb[,`k'+2])-normal((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2])))+(((xb[,`k'+3]-xb[,`k'+1]):^2:*normalden((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2])-(xb[,`k'+4]-xb[,`k'+1]):^2:*normalden((xb[,`k'+4]-xb[,`k'+1]):/xb[,`k'+2])):/xb[,`k'+2]:^2)))"
	local dcm3 "wgt[1,1]:*(normalden((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2]):*((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2]:*(normal((xb[,`k'+4]-xb[,`k'+1]):/xb[,`k'+2])-normal((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2]))+normalden((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2])-normalden((xb[,`k'+4]-xb[,`k'+1]):/xb[,`k'+2])):/(normal((xb[,`k'+4]-xb[,`k'+1]):/xb[,`k'+2])-normal((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2])):^2)" // derivative wrt left truncation point
	local dcm4 "wgt[1,1]:*(-normalden((xb[,`k'+4]-xb[,`k'+1]):/xb[,`k'+2]):*((xb[,`k'+4]-xb[,`k'+1]):/xb[,`k'+2]:*(normal((xb[,`k'+4]-xb[,`k'+1]):/xb[,`k'+2])-normal((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2]))+normalden((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2])-normalden((xb[,`k'+4]-xb[,`k'+1]):/xb[,`k'+2])):/(normal((xb[,`k'+4]-xb[,`k'+1]):/xb[,`k'+2])-normal((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2])):^2)" // derivative wrt right truncation point
	local dcm5 "wgt[1,2]:*(Z:*(1:-(((xb[,`k'+8]-xb[,`k'+5]):/xb[,`k'+6]:*normalden((xb[,`k'+8]-xb[,`k'+5]):/xb[,`k'+6])-(xb[,`k'+7]-xb[,`k'+5]):/xb[,`k'+6]:*normalden((xb[,`k'+7]-xb[,`k'+5]):/xb[,`k'+6])):*(normal((xb[,`k'+8]-xb[,`k'+5]):/xb[,`k'+6])-normal((xb[,`k'+7]-xb[,`k'+5]):/xb[,`k'+6]))+(normalden((xb[,`k'+7]-xb[,`k'+5]):/xb[,`k'+6])-normalden((xb[,`k'+8]-xb[,`k'+5]):/xb[,`k'+6])):^2):/(normal((xb[,`k'+8]-xb[,`k'+5]):/xb[,`k'+6])-normal((xb[,`k'+7]-xb[,`k'+5]):/xb[,`k'+6])):^2))" // derivative wrt beta
	local dcm6 "wgt[1,2]:*(1:/(normal((xb[,`k'+8]-xb[,`k'+5]):/xb[,`k'+6])-normal((xb[,`k'+7]-xb[,`k'+5]):/xb[,`k'+6])):*((normalden((xb[,`k'+7]-xb[,`k'+5]):/xb[,`k'+6])-normalden((xb[,`k'+8]-xb[,`k'+5]):/xb[,`k'+6])):*(1:-(((xb[,`k'+7]-xb[,`k'+5]):*normalden((xb[,`k'+7]-xb[,`k'+5]):/xb[,`k'+6])-(xb[,`k'+8]-xb[,`k'+5]):*normalden((xb[,`k'+8]-xb[,`k'+5]):/xb[,`k'+6])):/xb[,`k'+6]):/(normal((xb[,`k'+8]-xb[,`k'+5]):/xb[,`k'+6])-normal((xb[,`k'+7]-xb[,`k'+5]):/xb[,`k'+6])))+(((xb[,`k'+7]-xb[,`k'+5]):^2:*normalden((xb[,`k'+7]-xb[,`k'+5]):/xb[,`k'+6])-(xb[,`k'+7]-xb[,`k'+5]):^2:*normalden((xb[,`k'+8]-xb[,`k'+5]):/xb[,`k'+6])):/xb[,`k'+6]:^2)))"
	local dcm7 "wgt[1,2]:*(normalden((xb[,`k'+7]-xb[,`k'+5]):/xb[,`k'+6]):*((xb[,`k'+7]-xb[,`k'+5]):/xb[,`k'+6]:*(normal((xb[,`k'+8]-xb[,`k'+5]):/xb[,`k'+6])-normal((xb[,`k'+7]-xb[,`k'+5]):/xb[,`k'+6]))+normalden((xb[,`k'+7]-xb[,`k'+5]):/xb[,`k'+6])-normalden((xb[,`k'+8]-xb[,`k'+5]):/xb[,`k'+6])):/(normal((xb[,`k'+8]-xb[,`k'+5]):/xb[,`k'+6])-normal((xb[,`k'+7]-xb[,`k'+5]):/xb[,`k'+6])):^2)" // derivative wrt left truncation point
	local dcm8 "wgt[1,2]:*(-normalden((xb[,`k'+8]-xb[,`k'+5]):/xb[,`k'+6]):*((xb[,`k'+8]-xb[,`k'+5]):/xb[,`k'+6]:*(normal((xb[,`k'+8]-xb[,`k'+5]):/xb[,`k'+6])-normal((xb[,`k'+7]-xb[,`k'+5]):/xb[,`k'+6]))+normalden((xb[,`k'+7]-xb[,`k'+5]):/xb[,`k'+6])-normalden((xb[,`k'+8]-xb[,`k'+5]):/xb[,`k'+6])):/(normal((xb[,`k'+8]-xb[,`k'+5]):/xb[,`k'+6])-normal((xb[,`k'+7]-xb[,`k'+5]):/xb[,`k'+6])):^2)" // derivative wrt right truncation point
	local dcm9 "(xb[,`k'+5]+(xb[,`k'+6]:^2):*(normalden(xb[,`k'+7],xb[,`k'+5],xb[,`k'+6])-normalden(xb[,`k'+8],xb[,`k'+5],xb[,`k'+6])):/(normal((xb[,`k'+8]-xb[,`k'+5]):/xb[,`k'+6])-normal((xb[,`k'+7]-xb[,`k'+5]):/xb[,`k'+6])))-(xb[,`k'+1]+(xb[,`k'+2]:^2):*(normalden(xb[,`k'+3],xb[,`k'+1],xb[,`k'+2])-normalden(xb[,`k'+4],xb[,`k'+1],xb[,`k'+2])):/(normal((xb[,`k'+4]-xb[,`k'+1]):/xb[,`k'+2])-normal((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2])))" //derivative wrt weight
}
if "`model'"=="ltrnorm" {
	mat def `mixparv'=3
	local mixfunc "&rltrnormal()"
	local cm "`cm'(1:-mp):*(select(xb[,`k'+1],sme)+(select(xb[,`k'+2],sme):^2):*normalden(select(xb[,`k'+3],sme),select(xb[,`k'+1],sme),select(xb[,`k'+2],sme)):/(1:-normal((select(xb[,`k'+3],sme)-select(xb[,`k'+1],sme)):/select(xb[,`k'+2],sme))))"	
	local cmd "xb[,`k'+1]+xb[,`k'+2]:*normalden((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2]):/(1:-normal((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2]))"
	local dcm1 "(Z:*(1:-((-(xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2]:*normalden((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2])):*(1:-normal((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2]))+normalden((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2]):^2):/(1:-normal((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2])):^2))" // derivative wrt beta
	local dcm2 "(normalden((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2]):/(1:-normal((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2])):*(1:+((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2]):^2-((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2]):*normalden((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2]):/(1:-normal((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2]))))" // derivative wrt sigma
	local dcm3 "(normalden((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2]):*((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2]:*(1:-normal((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2]))+normalden((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2])):/(1:-normal((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2])):^2)" // derivative wrt left truncation point
}
if "`model'"=="mixltrnorm" {
	mat def `mixparv'=3
	local mixfunc "&rltrnormal()"
	local cm "`cm'(1:-mp):*(wgt[1,1]:*(select(xb[,`k'+1],sme)+(select(xb[,`k'+2],sme):^2):*normalden(select(xb[,`k'+3],sme),select(xb[,`k'+1],sme),select(xb[,`k'+2],sme)):/(1:-normal((select(xb[,`k'+3],sme)-select(xb[,`k'+1],sme)):/select(xb[,`k'+2],sme))))+wgt[1,2]:*(select(xb[,`k'+4],sme)+(select(xb[,`k'+5],sme):^2):*normalden(select(xb[,`k'+6],sme),select(xb[,`k'+4],sme),select(xb[,`k'+5],sme)):/(1:-normal((select(xb[,`k'+6],sme)-select(xb[,`k'+4],sme)):/select(xb[,`k'+5],sme)))))"	
	local cmd "wgt[1,1]:*(xb[,`k'+1]+xb[,`k'+2]:*normalden((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2]):/(1:-normal((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2])))+wgt[1,2]:*(xb[,`k'+4]+xb[,`k'+5]:*normalden((xb[,`k'+6]-xb[,`k'+4]):/xb[,`k'+5]):/(1:-normal((xb[,`k'+6]-xb[,`k'+4]):/xb[,`k'+5])))"
	local dcm1 "wgt[1,1]:*(Z:*(1:-((-(xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2]:*normalden((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2])):*(1:-normal((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2]))+normalden((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2]):^2):/(1:-normal((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2])):^2))" // derivative wrt beta
	local dcm2 "wgt[1,1]:*(normalden((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2]):/(1:-normal((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2])):*(1:+((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2]):^2-((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2]):*normalden((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2]):/(1:-normal((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2]))))" // derivative wrt sigma
	local dcm3 "wgt[1,1]:*(normalden((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2]):*((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2]:*(1:-normal((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2]))+normalden((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2])):/(1:-normal((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2])):^2)" // derivative wrt left truncation point
	local dcm4 "wgt[1,2]:*(Z:*(1:-((-(xb[,`k'+6]-xb[,`k'+4]):/xb[,`k'+5]:*normalden((xb[,`k'+6]-xb[,`k'+4]):/xb[,`k'+5])):*(1:-normal((xb[,`k'+6]-xb[,`k'+4]):/xb[,`k'+5]))+normalden((xb[,`k'+6]-xb[,`k'+4]):/xb[,`k'+5]):^2):/(1:-normal((xb[,`k'+6]-xb[,`k'+4]):/xb[,`k'+5])):^2))" // derivative wrt beta
	local dcm5 "wgt[1,2]:*(normalden((xb[,`k'+6]-xb[,`k'+4]):/xb[,`k'+5]):/(1:-normal((xb[,`k'+6]-xb[,`k'+4]):/xb[,`k'+5])):*(1:+((xb[,`k'+6]-xb[,`k'+4]):/xb[,`k'+5]):^2-((xb[,`k'+6]-xb[,`k'+4]):/xb[,`k'+5]):*normalden((xb[,`k'+6]-xb[,`k'+4]):/xb[,`k'+5]):/(1:-normal((xb[,`k'+6]-xb[,`k'+4]):/xb[,`k'+5]))))" // derivative wrt sigma
	local dcm6 "wgt[1,2]:*(normalden((xb[,`k'+6]-xb[,`k'+4]):/xb[,`k'+5]):*((xb[,`k'+6]-xb[,`k'+4]):/xb[,`k'+5]:*(1:-normal((xb[,`k'+6]-xb[,`k'+4]):/xb[,`k'+5]))+normalden((xb[,`k'+6]-xb[,`k'+4]):/xb[,`k'+5])):/(1:-normal((xb[,`k'+6]-xb[,`k'+4]):/xb[,`k'+5])):^2)" // derivative wrt left truncation point
	local dcm7 "(xb[,`k'+4]+xb[,`k'+5]:*normalden((xb[,`k'+6]-xb[,`k'+4]):/xb[,`k'+5]):/(1:-normal((xb[,`k'+6]-xb[,`k'+4]):/xb[,`k'+5]))-(xb[,`k'+1]+xb[,`k'+2]:*normalden((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2]):/(1:-normal((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2]))))" // derivative wrt weight
}
if "`model'"=="rtrnorm" {
	mat def `mixparv'=3
	local mixfunc "&rrtrnormal()"
	local cm "`cm'(1:-mp):*(select(xb[,`k'+1],sme)-(select(xb[,`k'+2],sme):^2):*normalden(select(xb[,`k'+3],sme),select(xb[,`k'+1],sme),select(xb[,`k'+2],sme)):/normal((select(xb[,`k'+3],sme)-select(xb[,`k'+1],sme)):/select(xb[,`k'+2],sme)))"	
	local cmd "xb[,`k'+1]+xb[,`k'+2]:*normalden((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2]):/normal((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2])"
	local dcm1 "(Z:*(1:-(((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2]:*normalden((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2]):*normal((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2])+(normalden((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2]):^2)):/normal((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2]):^2)))" // derivative wrt beta
	local dcm2 "(-(normalden((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2]):/normal((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2])):*(1:+((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2]):^2+(xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2]:*normalden((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2]):/normal((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2])))"
	local dcm3 "(-normalden((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2]):*((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2]:*normal((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2])-normalden((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2])):/(normal((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2])):^2)" // derivative wrt right truncation point
}
if "`model'"=="mixrtrnorm" {
	mat def `mixparv'=3
	local mixfunc "&rrtrnormal(),&rrtrnormal()"
	local cm "`cm'(1:-mp):*(wgt[1,1]:*(select(xb[,`k'+1],sme)-(select(xb[,`k'+2],sme):^2):*normalden(select(xb[,`k'+3],sme),select(xb[,`k'+1],sme),select(xb[,`k'+2],sme)):/normal((select(xb[,`k'+3],sme)-select(xb[,`k'+1],sme)):/select(xb[,`k'+2],sme)))+wgt[1,2]:*(select(xb[,`k'+4],sme)-(select(xb[,`k'+5],sme):^2):*normalden(select(xb[,`k'+6],sme),select(xb[,`k'+4],sme),select(xb[,`k'+5],sme)):/normal((select(xb[,`k'+6],sme)-select(xb[,`k'+4],sme)):/select(xb[,`k'+5],sme))))"	
	local cmd "wgt[1,1]:*(xb[,`k'+1]+xb[,`k'+2]:*normalden((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2]):/normal((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2]))+wgt[1,2]:*(xb[,`k'+4]+xb[,`k'+5]:*normalden((xb[,`k'+6]-xb[,`k'+4]):/xb[,`k'+5]):/normal((xb[,`k'+6]-xb[,`k'+4]):/xb[,`k'+5]))"
	local dcm1 "wgt[1,1]:*(Z:*(1:-(((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2]:*normalden((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2]):*normal((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2])+(normalden((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2]):^2)):/normal((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2]):^2)))" // derivative wrt beta
	local dcm2 "wgt[1,1]:*(-(normalden((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2]):/normal((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2])):*(1:+((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2]):^2+(xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2]:*normalden((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2]):/normal((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2])))"
	local dcm3 "wgt[1,1]:*(-normalden((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2]):*((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2]:*normal((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2])-normalden((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2])):/(normal((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2])):^2)" // derivative wrt right truncation point
	local dcm4 "wgt[1,2]:*(Z:*(1:-(((xb[,`k'+6]-xb[,`k'+4]):/xb[,`k'+5]:*normalden((xb[,`k'+6]-xb[,`k'+4]):/xb[,`k'+5]):*normal((xb[,`k'+6]-xb[,`k'+4]):/xb[,`k'+5])+(normalden((xb[,`k'+6]-xb[,`k'+4]):/xb[,`k'+5]):^2)):/normal((xb[,`k'+6]-xb[,`k'+4]):/xb[,`k'+5]):^2)))" // derivative wrt beta
	local dcm5 "wgt[1,2]:*(-(normalden((xb[,`k'+6]-xb[,`k'+4]):/xb[,`k'+5]):/normal((xb[,`k'+6]-xb[,`k'+4]):/xb[,`k'+5])):*(1:+((xb[,`k'+6]-xb[,`k'+4]):/xb[,`k'+5]):^2+(xb[,`k'+6]-xb[,`k'+4]):/xb[,`k'+5]:*normalden((xb[,`k'+6]-xb[,`k'+4]):/xb[,`k'+5]):/normal((xb[,`k'+6]-xb[,`k'+4]):/xb[,`k'+5])))"
	local dcm6 "wgt[1,2]:*(-normalden((xb[,`k'+6]-xb[,`k'+4]):/xb[,`k'+5]):*((xb[,`k'+6]-xb[,`k'+4]):/xb[,`k'+5]:*normal((xb[,`k'+6]-xb[,`k'+4]):/xb[,`k'+5])-normalden((xb[,`k'+6]-xb[,`k'+4]):/xb[,`k'+5])):/(normal((xb[,`k'+6]-xb[,`k'+4]):/xb[,`k'+5])):^2)" // derivative wrt right truncation point
	local dcm7 "((xb[,`k'+4]+xb[,`k'+5]:*normalden((xb[,`k'+6]-xb[,`k'+4]):/xb[,`k'+5]):/normal((xb[,`k'+6]-xb[,`k'+4]):/xb[,`k'+5]))-(xb[,`k'+1]+xb[,`k'+2]:*normalden((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2]):/normal((xb[,`k'+3]-xb[,`k'+1]):/xb[,`k'+2])))" // derivative wrt weight
}
if "`model'"=="exp" {
	local mixtransf "1,2,&mexp()"
	mat def `mixparv'=2
	local mixfunc "&rexploc()"
	local cm "`cm'(1:-mp):*(select(xb[,`k'+1],sme)+1:/select(xb[,`k'+2],sme))"
	local cmd "xb[,`k'+1]+1:/xb[,`k'+2]"
	local dcm1 "(J(rows(Z),1,1),-Z:/((xb[,`k'+2]):^2))"
}
if "`model'"=="mixexp" {
	local mixtransf "1,2,&mexp()"
	mat def `mixparv'=2
	local mixfunc "&rexploc()"
	local cm "`cm'(1:-mp):*(wgt[1,1]:*(select(xb[,`k'+1],sme)+1:/select(xb[,`k'+2],sme))+wgt[1,2]:*(select(xb[,`k'+1],sme)+1:/select(xb[,`k'+2],sme)))"
	local cmd "wgt[1,1]:*(xb[,`k'+1]+1:/xb[,`k'+2])+wgt[1,2]:*(xb[,`k'+3]+1:/xb[,`k'+4])"
	local dcm1 "(J(rows(Z),1,wgt[1,1]),-wgt[1,1]:*Z:/((xb[,`k'+2]):^2),J(rows(Z),1,wgt[1,2]),-wgt[1,2]:*Z:/((xb[,`k'+4]):^2),xb[,`k'+3]-xb[,`k'+1]+1:/xb[,`k'+4]-1:/xb[,`k'+2])"
}
if "`model'"=="weibull" {
	local mixtransf "1,3,&mexp()"
	mat def `mixparv'=3
	local mixfunc "&rweibloc()"
	local cm "`cm'(1:-mp):*(select(xb[,`k'+1],sme)+select(xb[,`k'+3],sme):*gamma(1:+1:/select(xb[,`k'+2],sme)))"	
	local cmd "xb[,`k'+1]+xb[,`k'+3]:*gamma(1:+1:/xb[,`k'+2])"
	local dcm1 "(J(rows(Z),1,1),Z:*gamma(1:+1:/xb[,`k'+2]),-(xb[,`k'+2]):^(-2):*xb[,`k'+3]:*gamma(1:+1:/xb[,`k'+2]):*digamma(1:+1:/xb[,`k'+2]))"
}
if "`model'"=="mixweibull" {
	local mixtransf "1,3,&mexp()"
	mat def `mixparv'=3
	local mixfunc "&rweibloc()"
	local cm "`cm'(1:-mp):*(wgt[1,1]:*(select(xb[,`k'+1],sme)+select(xb[,`k'+3],sme):*gamma(1:+1:/select(xb[,`k'+2],sme)))+wgt[1,2]:*(select(xb[,`k'+1],sme)+select(xb[,`k'+3],sme):*gamma(1:+1:/select(xb[,`k'+2],sme))))"	
	local cmd "wgt[1,1]:*(xb[,`k'+1]+xb[,`k'+3]:*gamma(1:+1:/xb[,`k'+2]))+wgt[1,2]:*(xb[,`k'+4]+xb[,`k'+6]:*gamma(1:+1:/xb[,`k'+5]))"
	local dcm1 "(J(rows(Z),1,wgt[1,1]),wgt[1,1]:*Z:*gamma(1:+1:/xb[,`k'+2]),-wgt[1,1]:*(xb[,`k'+2]):^(-2):*xb[,`k'+3]:*gamma(1:+1:/xb[,`k'+2]):*digamma(1:+1:/xb[,`k'+2]))"
	local dcm2 "(J(rows(Z),1,wgt[1,2]),wgt[1,2]:*Z:*gamma(1:+1:/xb[,`k'+5]),-wgt[1,2]:*(xb[,`k'+5]):^(-2):*xb[,`k'+6]:*gamma(1:+1:/xb[,`k'+5]):*digamma(1:+1:/xb[,`k'+5]),xb[,`k'+4]+xb[,`k'+6]:*gamma(1:+1:/xb[,`k'+5])-(xb[,`k'+1]+xb[,`k'+3]:*gamma(1:+1:/xb[,`k'+2])))"
}
if "`model'"=="t" {
	mat def `mixparv'=3
	local mixfunc "&rgent()"
	local cm "`cm'(1:-mp):*select(xb[,`k'+1],sme)"
	local cmd "xb[,`k'+1]"
	local dcm1 "(Z,J(rows(Z),2,0))"
}
if "`model'"=="mixt" {
	mat def `mixparv'=3
	local mixfunc "&rgent()"
	local cm "`cm'(1:-mp):*(wgt[1,1]:*select(xb[,`k'+1],sme)+wgt[1,2]:*select(xb[,`k'+4],sme))"
	local cmd "wgt[1,1]:*xb[,`k'+1]+wgt[1,2]*xb[,`k'+3]"
	local dcm1 "(wgt[1,1]:*Z,J(rows(Z),2,0),wgt[1,2]:*Z,J(rows(Z),2,0),xb[,`k'+3]-xb[,`k'+1]"
}
if "`model'"=="mixweit" {
	mat def `mixparv'=(3,3)
	local mixfunc "&rgent(),&rweibloc()"
	local cm "`cm'(1:-mp):*(wgt[1,1]:*select(xb[,`k'+1],sme)+wgt[1,2]:*(select(xb[,`k'+4],sme)+select(xb[,`k'+5],sme):*gamma(1:+1:/select(xb[,`k'+6],sme))))"
	local cmd "wgt[1,1]:*xb[,`k'+1]+wgt[1,2]:*(xb[,`k'+4]+xb[,`k'+6]:*gamma(1:+1:/xb[,`k'+5]))"
	local dcm1 "(wgt[1,1]:*Z,J(rows(Z),2,0),J(rows(Z),1,wgt[1,2]),wgt[1,2]:*Z:*gamma(1:+1:/xb[,`k'+5]),-wgt[1,2]:*(xb[,`k'+5]):^(-2):*xb[,`k'+6]:*gamma(1:+1:/xb[,`k'+5]):*digamma(1:+1:/xb[,`k'+5]),xb[,`k'+4]+xb[,`k'+6]:*gamma(1:+1:/xb[,`k'+5])-xb[,`k'+1])"
}
}
else if "`model'"!="" {
di as err "Invalid argument for measurement error in option model(): `model'"
exit
}

if "`masspoint'"!="" & "`model'"!="" {
	*multiplicative component of derivative for MP parameters
	if "`mpfunc'"=="&invlogit()" local dcmmp "xb[,1]:*(1:-xb[,1]):*(select(obs,sme)-`cmd'):*Z"
	else if "`mpfunc'"=="&mnormal()" local dcmmp "normalden(xb[,1]):*(select(obs,sme)-`cmd'):*Z"
	else if "`variance'"!="" & strmatch(lower("`variance'"),"*bootstrap*")==0 {
		di "Warning: Could not calculate derivatives for mass point (didn't know the derivatives for `mpfunc'), so SEs are NOT corrected for generated regressors"
		local "`variance'"==""
	}
}

*convert . to "" for optional strings
if "`mixtransf'"=="." local mixtransf ""
if "`nrtransf'"=="." local nrtransf ""
if "`wgttrfunc'"=="." local wgttrfunc ""
if "`nrwgttrfunc'"=="." local nrwgttrfunc ""

*get # of obs, parameter matrix, # of variables
qui: sum `touse', meanonly
local no=r(N)
if "`parameters'"!="" mat def `par'=`parameters'
else if "`model'"!="auto" {
	di as error "Parameter vector not found"
	exit
}
local nprvar: word count `obs' `pred'
local nmvar: word count `mvars'

*set up vector with number of predictors if not specified (needs equation names though)
if "`predictors'"=="" & "`model'"!="auto" {
	*get locations of parameters
	local names: coleq `par'
	tokenize "`names'"
	local i=1
	while `i'<=colsof(`par') {
		local k "``i''"
		local j=0
		local s=1
		while `s'==1 {
			local j=`j'+1
			local t=`j'+`i'
			local s=strmatch("`k'","``t''")
		}
		mat def `npred'=(nullmat(`npred'),`j')
		local i=`i'+`j'
	}
}
if "`predictors'"!="" mat def `npred'=`predictors'

*split up into mass point, nr & cond
if `mppar'!=0 mat def `locmp'=`npred'[1,1..`mppar']
if `b'[1,1]!=0 {
	mat def `locnr'=`npred'[1,`mppar'+1..`mppar'+`b'[1,1]+colsof(`nrparv')-1]
}
else mat def `locnr'=0
mat def `locmix'=`npred'[1,`mppar'+`b'[1,1]+colsof(`nrparv')..colsof(`npred')]

*check whether predictors match # of vars specified
mata:st_local("c",strofreal(max(st_matrix(st_local("locmp")))))
if `mppar'!=0 & `c'!=`nprvar'+1 {
	di as err "Number of Variables specified in varlist does not match number of predictors for mass point in predictors()"
	exit
}
mata:st_local("c",strofreal(max(st_matrix(st_local("locnr")))))
if `b'[1,1]!=0 & `c'!=`nmvar'+1 {
	di as err "Number of Variables specified in mvars() does not match number of predictors for missing values in predictors()"
	exit
}
mata:st_local("c",strofreal(max(st_matrix(st_local("locmix")))))
if `c'!=`nprvar'+1 {
	di as err "Number of Variables specified in varlist does not match number of predictors in predictors()"
	exit
}

*exclude observations w/ mvars==. & obs==. if <nr> and observations w/ obs==. if no <nr>
mat def `b'=(`b',`locnr'*J(colsof(`locnr'),rowsof(`locnr'),1))
if `b'[1,1]!=0 & `b'[1,2]>colsof(`locnr') {
	foreach var of varlist `mvar' {
		qui replace `touse'=0 if missing(`var')==1 & missing(`obs')==1
	}
}
if `b'[1,1]==0 {
	qui replace `touse'=0 if missing(`obs')==1
}

*check if there are missing values if nr is specified
if `b'[1,1]==1 {
	qui: sum `dep' if `obs'==. & `touse'==1, meanonly
	if `r(N)'==0 {
		di as error "Non-Response specified, but `obs' does not contain any missing values."
		mat def `b'[1,1]=0	
	}
}

*create pointers & locations for parameter transformations
if "`mixtransf'"!="" {
	local mixtransf=subinstr("`mixtransf'",","," ",.)
	local c=wordcount("`mixtransf'")
	if mod(`c',3)!=0 {
		di as err "Invalid transformation for parameters of mixture specified"
	}
	tokenize `mixtransf'
	local i=1
	while `i'<=`c' {
		local j=`i'+1
		mat def `mixtrloc'=(nullmat(`mixtrloc')\(``i'',``j''))
		local j=`i'+2
		if "`mixtrfunc'"!="" local mixtrfunc "`mixtrfunc', "
		local mixtrfunc "`mixtrfunc'``j''"
		local i=`i'+3
	}
	local mixtrfunc="(`mixtrfunc')"
}
else {
	mat def `mixtrloc'=0
	local mixtrfunc .
}

if "`nrtransf'"!="" {
	local nrtransf=subinstr("`nrtransf'",","," ",.)
	local c=wordcount("`nrtransf'")
	tokenize `nrtransf'
	local i=1
	while `i'<=`c' {
		local j=`i'+1
		mat def `nrtrloc'=(nullmat(`nrtrloc')\(``i'',``j''))
		local j=`i'+2
		if "`nrtrfunc'"!="" local nrtrfunc "`nrtrfunc', "
		local nrtrfunc "`nrtrfunc'``j''"
		local i=`i'+3
	}
	local nrtrfunc="(`nrtrfunc')"
}
else {
	mat def `nrtrloc'=0
	local nrtrfunc .
}
if "`nrwgttrfunc'"!="" sca def `nrwgttr'=1
else {
	sca def `nrwgttr'=0
	local nrwgttrfunc .
}

if "`wgttrfunc'"!="" sca def `wgttr'=1
else {
	sca def `wgttr'=0
	local wgttrfunc .
}



**if condmean or nrmean is specified, needs to be specified in terms of xb,wgt &nrwgt
if "`condmean'"!="" local cm "`condmean'"
if "`nrmean'"!="" local cmnr "`nrmean'"

*use heteroskedastic errors if no variance is specified
if strmatch("`options'","*vce*")==0 & strmatch("`options'","*robust*")==0 & strmatch("`options'","*cluster*")==0 & strmatch("`weight'","iweight")==0 {
	local options "`options' robust"
}

*get conditional mean
*create temporary variable names for conditional mean and weights
if "`tname'"=="" tempname condmn
else local condmn "`tname'"
if "`exp'"=="" {
	local exp "none"
	local sweight ""
}
else {
	tempname wgt
	local sweight `"=`exp'"'
}

*get parameters
mata: condpar("`par'","`obs'","`pred'","`mvars'","`mixparv'","`nrparv'","`locmp'","`locmix'","`locnr'","`mixtrloc'","`nrtrloc'",(`mpfunc'),`mixtrfunc',`nrtrfunc',`nrwgttrfunc',`wgttrfunc',xb=.,wgt=.,nrwgt=.)
qui: gen `condmn'=.
*if model() used or condmean specified manually->cannot mix model w/ manual nr
if ("`model'"!="" & "`model'"!="auto") | "`condmean'"!="" {
	*create views for nr and me (if only me, whole view):
	mata: st_view(obs=.,.,st_local("obs"),st_local("touse"))
	if `b'[1,1]!=0 {
		tempvar missing
		qui: gen `missing'=(`obs'==.) if `touse'
		qui: replace `missing'=0 if `missing'!=1
		mata: st_view(cmnr=.,.,st_local("condmn"),st_local("missing"))
		mata: snr=st_data(.,st_local("missing"),st_local("touse"))
		mata: sme=1:-snr
		qui: replace `missing'=1-`missing' if `touse'
		mata: st_view(cm=.,.,st_local("condmn"),st_local("missing"))
		qui: drop `missing'
	}
	else {
		mata: st_view(cm=.,.,st_local("condmn"),st_local("touse"))
		mata: sme=J(rows(cm),1,1)
	}
	if "`masspoint'"!="" mata:mp=select(xb[,1],sme)
	else mata:mp=J(sum(sme),1,0)
	*cond mean for nr
	if `b'[1,1]!=0 {
		mata: cmnr[,]=`cmnr'
		mata: mata drop cmnr
	}
	*cond mean for me
	mata: cm[,]=`cm'
	mata: mata drop cm mp
	*regress
	qui: regress `dep' `cov' [`weight' `sweight'] if `touse', `options'
	if strmatch("`variance'","*bootstrap*")==1 est store orig
}
*without model: average over draws from conddraws()
else {
	if strmatch("`options'","*vce(bootstrap)*")==1 {
		di as error "Option vce(bootstrap) is not allowed when simulating the conditional mean. Use the bootstrap prefix instead."
		exit
	}
	mata: conddraw(xb,wgt,nrwgt,`draws',"`obs'","`exp'","`condmn'","`mppar'","`mixparv'","`nrparv'","`locmix'",(`mixfunc'),(`nrfunc'),svec=.)
	mata: st_store(.,st_local("condmn"),st_local("touse"),mean(rowshape(svec,`draws'))')
	*simulation correction
	*get variance of simulation error
	mata: a=sum((rowshape(svec,`draws')':-mean(rowshape(svec,`draws'))'):^2)/(`draws'*(`draws'-1))
	*regress
	qui: regress `dep' `cov' [`weight' `sweight'] if `touse', `options'
	mat def `b'=e(b)
	mat def `v'=e(V)
	*remove entries for colinear variables
	tempname noomit bc vc
	_ms_omit_info `b'
	matrix `noomit' =  J(1,colsof(`b'),1) - r(omit)
	local names: colnames `b'
	local cov ""
	foreach var of local names {
		_ms_parse_parts `var'
		if r(omit)==0 & "`var'"!="_cons" local cov "`cov' `var'"
	}
	mata: st_view(cov=.,.,st_local("cov"),st_local("touse"))
	mata: xx=(cov,J(rows(cov),1,1))'*(cov,J(rows(cov),1,1))
	local c=wordcount(substr("`cov'",1,strpos("`cov'","`tname'")-1))+1
	mata: cor=cholinv(xx-diag(e(`c',rows(xx)):*a))
	mata: st_matrix("e(V_modelbased)",cor)
	mata: st_matrix(st_local("bc"),(cor*xx*select(st_matrix(st_local("b"))',st_matrix(st_local("noomit"))'))')
	mata: st_matrix(st_local("vc"),cor*xx*select(select(st_matrix(st_local("v")),st_matrix(st_local("noomit"))),st_matrix(st_local("noomit"))')*xx'*cor')
	mata: mata drop a cor cov nrwgt wgt svec xb xx
	if `noomit'[1,1]==0 {
		mat def `bc'=(0,`bc')
		mat def `vc'=(J(rowsof(`vc'),1,0),`vc')
		mat def `vc'=(J(1\colsof(`vc'),0),`vc')
	}
	local i=2
	while `i'<=colsof(`b')-1 {
		if `noomit'[1,`i']==0 {
			mat def `bc'=(`bc'[1,1..`i'-1],0,`bc'[1,`i'...])
			mat def `vc'=(`vc'[1...,1..`i'-1],J(rowsof(`vc'),1,0),`vc'[1...,`i'...])
			mat def `vc'=(`vc'[1..`i'-1,1...]\J(1,colsof(`vc'),0)\\`vc'[`i'...,1...])
		}
		local i=`i'+1
	}
	if `noomit'[1,`i']==0 {
		mat def `bc'=(`bc',0)
		mat def `vc'=(`vc',J(rowsof(`vc'),1,0))
		mat def `vc'=(`vc'\J(1,colsof(`vc'),0))
	}
	mat def `b'[1,1]=`bc'
	mat def `v'[1,1]=`vc'
	ereturn repost b=`b' V=`v'
}


if "`variance'"!="" {
*set trace on
	*remove first word, define first stage variance matrix
	tempname vpar
	local variance= subinstr(`"`variance'"',","," ",.)
	gettoken vmat variance: variance
	mat def `vpar'=`vmat'
	gettoken vtype variance: variance
*bootstrap variance
	if lower("`vtype'")=="bootstrap" {
		*setup
		tempname bs pars
		tempvar pard bscluster
		*separate "`variance'" into `bsiter' and options passed to bsample
		tokenize `"`variance'"'
		if "`1'"!="" local bsiter=`1'
		else local bsiter=50
		if "`2'"!="." local cluster "`2'"
		else local cluster ""
		local strata "`3'"
		mat def `b'=e(b)
		mat def `bs'=J(`bsiter',colsof(e(b)),.)
		local c=colsof(`par')
		local names : coleq `par'
		*draw parameters of conditional distribution
		preserve
		qui: drawnorm `pard'1-`pard'`c', means(`par') cov(`vpar') n(`bsiter') clear double
		mkmat `pard'*, matrix(`pars') nomissing 
		matrix coleq `pars'=`names'
		restore
		qui: gen `pard'=`tname'
		drop `tname'
		*set up options for bsample
		if "`cluster'"!="" local bsopt "cluster(`cluster') idcluster(`bscluster')"
		if "`strata'"!="" local bsopt "`bsample' strata(`strata')"
		*run simulation
		preserve
		foreach i of numlist 1/`bsiter' {
			if "`cluster'"!="" {
				qui: replace `cluster'=`bscluster'
				drop `bscluster'
			}
			*else: bsample if `touse'
			bsample if `touse', `bsopt'
			*run model on simulated sample
			qui: cdreg `anything' [`weight' `sweight'] if `touse', par(`pars'[`i',1...]) `opt' `options'
			mat def `bs'[`i',1]=e(b)
		}
		restore
*calculate bsvariance, post results
mat list `bs'
		mata: st_matrix("`v'",variance(st_matrix("`bs'")))
		local vtyp "two-step bootstrap"
		*clean up
		capture drop `tname'
		qui: gen `tname'=`pard'
		drop `pard'
		qui: est restore orig
		est drop orig
	}
	else {
	if "`model'"=="" di "SEs could not be corrected for estimation error of first stage parameters"
	else {
		*calculate correction for indep case
		tempname xx xd
		tempvar cons
		qui: gen `cons'=1
		mat def `v'=e(V)
		if "`dep'"=="`tname'" local c=1
		else local c=_b[`tname']^2
		qui: mat accum `xx'=`cov' [`weight' `sweight'] if `touse'
		mat def `xx'=invsym(`xx'/`no')
		*X'dh/dpar for NR
		if `b'[1,1]!=0 {
			tempvar missing
			qui: gen `missing'=(`obs'==.) if `touse'
			qui: replace `missing'=0 if `missing'!=1			
			*get X,Z matrices for NR
			mata: st_view(X=.,.,"`cov' `cons'",st_local("missing"))
			mata: st_view(Z=.,.,"`mvars' `cons'",st_local("missing"))
			mata: xb2=select(xb,sme)
			mata: xb=select(xb,snr)
			*get X'd for NR parameters (Xd2)
			local i=1
			mata: Xd2=J(cols(X),0,0)
			while "`dcmnr`i''"!="" {
				mata: Xd2=(Xd2,X'*(`dcmnr`i''))
				local i=`i'+1
			}
			mata: mata drop snr
			qui: replace `missing'=1-`missing' if `touse'
			mata: xb=xb2
			mata: drop xb2
		}
		else {
			local missing `touse'
		}
		*get X,Z matrices for conditional density
		mata: st_view(X=.,.,"`cov' `cons'",st_local("missing"))
		mata: st_view(Z=.,.,"`obs' `pred' `cons'",st_local("missing"))
		*if mass point, get Xd1
		if "`masspoint'"!="" {
			mata: Xd1=X'*(`dcmmp')
			mata: mp=xb[,1]
		}
		else {
			mata: Xd1=J(cols(X),0,0)
			mata: mp=J(rows(xb),1,0)
		}
		*get Xd3 (X'dh/dpar for cond dens)
		local i=1
		mata: Xd3=J(cols(X),0,0)
		while "`dcm`i''"!="" {
			mata: Xd3=(Xd3,X'*((1:-mp):*(`dcm`i'')))
			local i=`i'+1
		}
		*put results together and return
		if `b'[1,1]==0 mata: Xd2=J(cols(X),0,0)
		mata: st_matrix("`xd'",(Xd1,Xd2,Xd3):/`no')		
		*get final variance matrix
		mat def `v'=`v'+`c'*`xx'*`xd'*`vpar'*`xd''*`xx'
		local vtyp "two-step indep"
		*clean up, return stuff
		mata: mata drop Xd1 Xd2 Xd3 X Z xb sme wgt nrwgt obs mp
		matrix drop `xx' `xd' `vpar'
		drop `cons'
	}
}
	*re-post variance
	capture noisily ereturn repost V=`v'
	if _rc!=0 di "The adjusted variance matrix returned the error above, using the unadjusted variance matrix."
	else ereturn local vce "`vtyp'"
}
else {
	capture mata: mata drop xb sme wgt nrwgt obs
	capture mata: mata drop snr
}

*display, return output, clean up

*display header
if "`noheader'"=="" {
	di ""
	di in smcl as text "Linear Regression with"  _col(56) "Number of obs" as text _col(70) "=" as res %8.0g e(N)
	di in smcl as text "missing variable `tname'" _col(56) "F(" %3.0f e(df_m) "," %6.0g e(df_r) ")" _col(70) "=" as res %8.2f e(F)
	di in smcl as text _col(56) "Prob > F" _col(70) "=" as res %8.4f Ftail(e(df_m),e(df_r),e(F))
	di ""
}

*display table
regress, noheader `diopts'

if "`keep'"=="" drop `tname'

*adjust/calculate other statistics returned by regress

mata: st_numscalar("e(r2)",J(0,0,.))
mata: st_numscalar("e(r2_a)",J(0,0,.))
mata: st_numscalar("e(rmse)",J(0,0,.))
ereturn local cmdline `"cdreg `0'"'
ereturn local cmd "cdreg"

end

*mata routines
mata
/*generate parameter matrix from variables*/
void condpar(string scalar parv, string scalar observe, string scalar predict, string scalar mvars, string scalar mixparn, string scalar nrparn, string scalar locmpn, string scalar locmixn, string scalar locnrn, string scalar mixtrlocn, string scalar nrtrlocn, pointer(function) scalar mpfunc, pointer(function) matrix mixtrfunc,pointer(function) matrix nrtrfunc,pointer(function) scalar nrwgttrfunc,pointer(function) scalar wgttrfunc, real matrix xb, real colvector wgt, real colvector nrwgt) {
/*declare variables*/
real scalar n,mppar,i,j,k,b
real matrix pred,nrvar,par,a
real colvector obs
real rowvector rep, mixpar, mixparv, nrpar,locmp,locnr,locmix,nrtrloc,mixtrloc


/*setup*/
st_view(obs=.,.,observe, st_local("touse"))
st_view(pred=.,.,tokens(predict), st_local("touse"))
st_view(nrvar=.,.,tokens(mvars),st_local("touse"))
par=st_matrix(parv)
mixparv=st_matrix(mixparn)
nrpar=st_matrix(nrparn)
locmp=st_matrix(locmpn)
locnr=st_matrix(locnrn)
locmix=st_matrix(locmixn)
nrtrloc=st_matrix(nrtrlocn)
mixtrloc=st_matrix(mixtrlocn)



n=rows(obs)
if (mpfunc!=.) mppar=1
else mppar=0

/*replicate mixpar to match vector of parameters*/
k=cols(mixparv)
rep=J(1,k,1)
i=sum(mixparv)+k+mixparv[1,1]
mixpar=mixparv
j=1
while (i<=length(locmix)) {
	mixpar=(mixpar,mixparv[1,j])
	rep[1,j]=rep[1,j]+1
	i=i+mixpar[1,j]+1
	if (j<k) {
		j=j+1
	}
	else j=1
}
if (length(locmix)-length(mixpar)+1!=sum(mixpar)) _error("Parameter Vector does not match Specification")
;

/*set up xb*/
j=1
xb=J(n,0,.)
if (mppar!=0) {
	if (locmp[1,1]==1) {
		xb=(xb,(*mpfunc)(J(n,1,par[1,1])))
		j=j+1
	}
	else {
		xb=(xb,(*mpfunc)((obs,pred,J(n,1,1))*par[1,1..locmp[1,1]]'))
		j=j+locmp[1,1]
	}
};

/*add columns for non-response & create weight vector for nr*/
if (nrpar[1,1]!=0) {
nrwgt=J(1,0,.)
i=1
for(k=1;k<=length(nrpar);k++) {
	while(i<=sum(nrpar[1,1..k])) {
		if (locnr[1,i]==1) {
			xb=(xb,J(n,1,par[1,j]))
			j=j+1
		}
		else {
			xb=(xb,(nrvar,J(n,1,1))*par[1,j..j+locnr[1,i]-1]')
			j=j+locnr[1,i]
		}
		i=i+1
	}
	if (k>1) {
		if (nrwgttrfunc!=.) nrwgt=(nrwgt,(*nrwgttrfunc)(par[1,j]))
		else nrwgt=(nrwgt,par[1,j])
		j=j+1
	}
}
nrwgt=(1-sum(nrwgt),nrwgt)
}
else nrwgt=J(1,1,.)
/*add columns for cond dens & create weight vector for cond dens*/
if (mixpar[1,1]!=0) {
wgt=J(1,0,.)
i=1
for(k=1;k<=length(mixpar);k++) {
	while(i<=sum(mixpar[1,1..k])) {
		if (locmix[1,i]==1) {
			xb=(xb,J(n,1,par[1,j]))
			j=j+1
		}
		else {
			xb=(xb,(obs,pred,J(n,1,1))*par[1,j..j+locmix[1,i]-1]')
			j=j+locmix[1,i]
		}
		i=i+1
	}
	if (k>1) {
		if (wgttrfunc!=.) wgt=(wgt,(*wgttrfunc)(par[1,j]))
		else wgt=(wgt,par[1,j])
		j=j+1
	}
}
wgt=(1-sum(wgt),wgt)
};
/*transform parameters*/
/*nr parameters*/
if (nrtrloc!=0) {
	a=mppar
	i=1
	while(i<=rows(nrtrloc)) {
		b=a+sum(nrpar[1,1..nrtrloc[i,1]])-nrpar[1,nrtrloc[i,1]]+nrtrloc[i,2]
		xb[,b]=(*nrtrfunc[i])(xb[,b])
		i=i+1
	}
}
/*mixing parameters*/
if (mixtrloc!=0) {
	a=mppar+sum(nrpar)
	i=1
	while(i<=rows(mixtrloc)) {
		b=a+sum(mixpar[1,1..mixtrloc[i,1]])-mixpar[1,mixtrloc[i,1]]+mixtrloc[i,2]
		xb[,b]=(*mixtrfunc[i])(xb[,b])
		j=2
		while(j<=rep[1,mixtrloc[i,1]]) {
			b=a+sum(mixpar[1,1..mixtrloc[i,1]])-mixpar[1,mixtrloc[i,1]]+mixtrloc[i,2]+(j-1)*sum(mixpar[1,1..cols(rep)])
			xb[,b]=(*mixtrfunc[i])(xb[,b])
			j=j+1
		}
		i=i+1
	}
}

}


/*simulate from conditional distribution*/
void conddraw(real matrix xb, real rowvector wgt, real rowvector nrwgt, real scalar d, string scalar observe, string scalar weights, string scalar simname, string scalar mpparn, string scalar mixparn,string scalar nrparn, string scalar locmixn, pointer(function) matrix mixfuncv, pointer(function) matrix nrfunc, | real colvector simvec) { 
/*declarations*/
real scalar i,j,k,n,mppar
real colvector sim,obs,rep,wght
real rowvector mixparv,mixpar,nrpar,locmix
real matrix cur,a
pointer(function) matrix mixfunc

/*set things up*/
mixparv=st_matrix(mixparn)
nrpar=st_matrix(nrparn)
locmix=st_matrix(locmixn)
mppar=st_numscalar(mpparn)

st_view(obs=.,.,observe, st_local("touse"))
n=rows(xb)

/*replicate mixing function to match vector of parameters*/
k=cols(mixparv)
rep=J(1,k,1)
i=sum(mixparv)+k+mixparv[1,1]
mixpar=mixparv
mixfunc=mixfuncv
j=1
while (i<=length(locmix)) {
	mixpar=(mixpar,mixparv[1,j])
	mixfunc=(mixfunc,mixfuncv[1,j])
	rep[1,j]=rep[1,j]+1
	i=i+mixpar[1,j]+1
	if (j<k) {
		j=j+1
	}
	else j=1
}
if (length(locmix)-length(mixpar)+1!=sum(mixpar)) _error("Parameter Vector does not match Specification")
;

/*simulate*/
sim=J(0,1,.)
cur=J(n,4,1)
cur[,2]=runningsum(cur[,2])
for(i=1;i<=d;i++) {
	/*non response (not a very elegant approach to passing elements)*/
	k=1+mppar
	if (nrpar[1,1]!=0) {
		cur[,4]=runiform(n,1)
		for(j=1;j<=length(nrpar);j++) {
			a=select(cur,(obs:==.):*(cur[,3]:==1):*(cur[,4]:<=sum(nrwgt[1..j])))
			if (nrpar[1,j]==1) cur[a[,2],1]=(*nrfunc[j])(xb[a[,2],k])
			if (nrpar[1,j]==2) cur[a[,2],1]=(*nrfunc[j])(xb[a[,2],k],xb[a[,2],k+1])
			if (nrpar[1,j]==3) cur[a[,2],1]=(*nrfunc[j])(xb[a[,2],k],xb[a[,2],k+1],xb[a[,2],k+2])
			if (nrpar[1,j]==4) cur[a[,2],1]=(*nrfunc[j])(xb[a[,2],k],xb[a[,2],k+1],xb[a[,2],k+2],xb[a[,2],k+3])
			if (nrpar[1,j]==5) cur[a[,2],1]=(*nrfunc[j])(xb[a[,2],k],xb[a[,2],k+1],xb[a[,2],k+2],xb[a[,2],k+3],xb[a[,2],k+4])
			if (nrpar[1,j]==6) cur[a[,2],1]=(*nrfunc[j])(xb[a[,2],k],xb[a[,2],k+1],xb[a[,2],k+2],xb[a[,2],k+3],xb[a[,2],k+4],xb[a[,2],k+5])
			k=k+nrpar[1,j]
			cur[a[,2],3]=J(rows(a),1,0)
		}
	} ;
	/*mass point*/
	if (mppar!=0) {
		cur[,4]=runiform(n,1)
		a=select(cur,(cur[,4]:<xb[,1]):*(cur[,3]:==1))
		cur[a[,2],1]=obs[a[,2],]
		cur[a[,2],3]=J(rows(a),1,0)
	} ;
	/*conditional density (not a very elegant approach to passing elements)*/
	if (mixpar[1,1]!=0) {
		cur[,4]=runiform(n,1)
		for(j=1;j<=length(mixpar);j++) {
			a=select(cur,(cur[,3]:==1):*(cur[,4]:<=sum(wgt[1..j])))
			if (mixpar[1,j]==1) cur[a[,2],1]=(*mixfunc[j])(xb[a[,2],k])
			if (mixpar[1,j]==2) cur[a[,2],1]=(*mixfunc[j])(xb[a[,2],k],xb[a[,2],k+1])
			if (mixpar[1,j]==3) cur[a[,2],1]=(*mixfunc[j])(xb[a[,2],k],xb[a[,2],k+1],xb[a[,2],k+2])
			if (mixpar[1,j]==4) cur[a[,2],1]=(*mixfunc[j])(xb[a[,2],k],xb[a[,2],k+1],xb[a[,2],k+2],xb[a[,2],k+3])
			if (mixpar[1,j]==5) cur[a[,2],1]=(*mixfunc[j])(xb[a[,2],k],xb[a[,2],k+1],xb[a[,2],k+2],xb[a[,2],k+3],xb[a[,2],k+4])
			if (mixpar[1,j]==6) cur[a[,2],1]=(*mixfunc[j])(xb[a[,2],k],xb[a[,2],k+1],xb[a[,2],k+2],xb[a[,2],k+3],xb[a[,2],k+4],xb[a[,2],k+5])
			k=k+mixpar[1,j]
			cur[a[,2],3]=J(rows(a),1,0)
		}

	} ;
sim=(sim\cur[,1])
cur[,3]=J(n,1,1)
cur[,1]=J(n,1,0)
}

/*save simulated vector as variable or return vector if simvec specified*/
if (args()==13) {
	st_addobs(st_nobs()*(d-1))
	st_view(wght=.,.,st_local("touse"))
	wght[,]=J(d,1,wght[1..st_nobs()/d])
	a=st_addvar("double",simname)
	st_store(.,a,st_local("touse"),sim)
	/*weights*/
	if (strmatch(weights,"none")!=1) {
		a=st_addvar("double",st_local("wgt"))
		st_view(wght=.,(1,st_nobs()/d),weights,st_local("touse"))
		st_store(.,a,st_local("touse"),J(d,1,wght))
	} ;
}
else simvec=sim

}


/*definitions of other functions*/
function mrnormal(a,b) return(rnormal(1,1,a,b))
function rtrnormal(m,s,l,r) return(m+s:*invnormal(normal((l-m):/s)+runiform(rows(m),cols(m)):*(normal((r-m):/s)-normal((l-m):/s))))
function rrtrnormal(m,s,r) return(m+s:*invnormal(runiform(rows(m),cols(m)):*(normal((r-m):/s))))
function rltrnormal(m,s,l) return(m+s:*invnormal(normal((l-m):/s)+runiform(rows(m),cols(m)):*(1:-normal((l-m):/s))))
function rexploc(a,b) return(a-log(runiform(rows(a),cols(a))):/b)
function rweibloc(loc,k,s) return(loc+(-s:*log(runiform(rows(loc),cols(loc)))):^(1:/k))
function rgent(loc,s,df) return(loc+s:*rt(1,1,df))
function mabs(x) return(abs(x))
function mneg(x) return(-1:*abs(x))
function mexp(x) return(exp(x))
function mnormal(x) return(normal(x))

end

