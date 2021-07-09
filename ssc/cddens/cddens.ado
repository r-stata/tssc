*! Nikolas Mittag 07Oct2011

cap program drop cddens
program define cddens, eclass
version 10.0
syntax varlist(min=1 numeric) [if] [in] [fweight aweight iweight /], [PARameters(string)] [Draws(integer 40)] [Save(string)] [Tname(string)] [MASSpoint] [MODel(string)] [PREDictors(string)] [MIXFunc(string)] [MIXPar(string)] [MIXTransf(string)] [WGTTRfunc(string)] [MPFunc(string)] [MVars(varlist)] [NRFunc(string)] [NRPar(string)] [NRTRansf(string)] [NRWgttrfunc(string)] [KSmirnov(varname)] [CKolmogorov(string)] [REStrict(string)] [CDF] [CDFVar(varlist)]
unab varlist: `varlist'
gettoken obs pred : varlist
marksample touse, novarlist
if wordcount("`pred'")>0 {
	foreach var of varlist `pred' {
		qui replace `touse'=0 if missing(`var')==1 & missing(`obs')==0
	}
}

*define temporary names
tempname b par nrtrloc mixtrloc locmix locnr locmp npred nrparv mixparv mppar wgttr nrwgttr ck ckp ckpnr


/*set defaults (2 comp normal mixture w/ mp, no nr) & convert optional strings*/
if "`masspoint'"!="" sca def `mppar'=1
else sca def `mppar'=0
if "`mpfunc'"=="" & `mppar'==1 local mpfunc "&mnormal()"
if "`mpfunc'"=="" & `mppar'==0 local mpfunc .
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
if wordcount("`model'")<2 {
	if "`nrfunc'"=="" local nrfunc .
	if "`nrpar'"=="" mat def `nrparv'=0
	else mat def `nrparv'=`nrpar'
	if "`nrtransf'"=="" local nrtransf ""
	if "`nrwgttrfunc'"=="" local nrwgttrfunc ""
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
*default model for nr if variables specified, but no model
if "`nrmodel'"=="" & "`mvars'"!="" & "`nrpar'"=="" {
	local nrmodel "mixnorm"
	di as res "Variables for Non-Response specified, but no model. Assuming mixture of two normals."
}

*model definitions for measurement error
if (inlist("`model'","normal","mixnorm","exp","mixexp","weibull","mixweibull","t","mixt","mixweit")==1 | inlist("`model'","auto","trnorm","ltrnorm","rtrnorm","mixtrnorm","mixltrnorm","mixrtrnorm")==1) {
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
if "`model'"=="normal" | "`model'"=="mixnorm" {
	local mixfunc "&mrnormal()"
	mat def `mixparv'=2
}
if "`model'"=="trnorm" | "`model'"=="mixtrnorm" {
	local mixfunc "&rtrnormal()"
	mat def `mixparv'=4
}
if "`model'"=="ltrnorm" | "`model'"=="mixltrnorm" {
	local mixfunc "&rltrnormal()"
	mat def `mixparv'=3
}
if "`model'"=="rtrnorm" | "`model'"=="mixrtrnorm" {
	local mixfunc "&rrtrnormal()"
	mat def `mixparv'=3
}
if "`model'"=="exp" | "`model'"=="mixexp" {
	local mixfunc "&rexploc()"
	local mixtransf "1,2,&mexp()"
	mat def `mixparv'=2
}
if "`model'"=="weibull" | "`model'"=="mixweibull" {
	local mixfunc "&rweibloc()"
	local mixtransf "1,3,&mexp()"
	mat def `mixparv'=3
}
if "`model'"=="t" | "`model'"=="mixt" {
	local mixfunc "&rgent()"
	mat def `mixparv'=3
}
if "`model'"=="mixweit" {
	local mixfunc "&rgent(),&rweibloc()"
	mat def `mixparv'=(3,3)
}
}
else if "`model'"!="" {
di as err "Invalid argument for measurement error in option model(): `model'"
exit
}

*setup model for non-response
if (inlist("`nrmodel'","normal","mixnorm","exp","mixexp","weibull","mixweibull","t","mixt","mixweit")==1 | inlist("`nrmodel'","trnorm","ltrnorm","rtrnorm","mixtrnorm","mixltrnorm","mixrtrnorm")==1) {
if "`nrmodel'"=="normal" {
	local nrfunc "&mrnormal()"
	mat def `nrparv'=2
}	
if "`nrmodel'"=="mixnorm" {
	local nrfunc "&mrnormal(),&mrnormal()"
	mat def `nrparv'=(2,2)
}	
if "`nrmodel'"=="trnorm" {
	local nrfunc "&rtrnormal()"
	mat def `nrparv'=4
}
if "`nrmodel'"=="mixtrnorm" {
	local nrfunc "&rtrnormal(),&rtrnormal()"
	mat def `nrparv'=(4,4)
}
if "`nrmodel'"=="ltrnorm" {
	local nrfunc "&rltrnormal()"
	mat def `nrparv'=3
}
if "`nrmodel'"=="mixltrnorm" {
	local nrfunc "&rltrnormal(),&rltrnormal()"
	mat def `nrparv'=(3,3)
}
if "`nrmodel'"=="rtrnorm" {
	local nrfunc "&rrtrnormal()"
	mat def `nrparv'=3
}
if "`nrmodel'"=="mixrtrnorm" {
	local nrfunc "&rrtrnormal(),&rrtrnormal()"
	mat def `nrparv'=(3,3)
}
if "`nrmodel'"=="exp" {
	local nrfunc "&rexploc()"
	local nrtransf "1,2,&mexp()"
	mat def `nrparv'=2
}	
if "`nrmodel'"=="mixexp" {
	local nrfunc "&rexploc(),&rexploc()"
	local nrtransf "1,2,&mexp(),2,2,&mexp()"
	mat def `nrparv'=(2,2)
}	
if "`nrmodel'"=="weibull" {
	local nrfunc "&rweibloc()"
	local nrtransf "1,3,&mexp()"
	mat def `nrparv'=3
}
if "`nrmodel'"=="mixweibull" {
	local nrfunc "&rweibloc(),&rweibloc()"
	local nrtransf "1,3,&mexp(),2,3,&mexp()"
	mat def `nrparv'=(3,3)
}
if "`nrmodel'"=="t" {
	local nrfunc "&rgent()"
	mat def `nrparv'=3
}
if "`nrmodel'"=="mixt" {
	local nrfunc "&rgent(),&rgent()"
	mat def `nrparv'=(3,3)
}
if "`nrmodel'"=="mixweit" {
	local nrfunc "&rgent(),&rweibloc()"
	mat def `nrparv'=(3,3)
}
}
else if "`nrmodel'"!="" {
	di as err "Invalid argument for missing values in option model(): `nrmodel'"
	exit
}

*convert . to "" for optional strings
if "`mixtransf'"=="." local mixtransf ""
if "`nrtransf'"=="." local nrtransf ""
if "`wgttrfunc'"=="." local wgttrfunc ""
if "`nrwgttrfunc'"=="." local nrwgttrfunc ""

*get # of obs, parameter matrix, # of variables
local no=_N
if "`parameters'"!="" mat def `par'=`parameters'
else if "`model'"!="auto" {
	di as error "Parameter vector not found"
	exit
}
local nprvar: word count `obs' `pred'
local nmvar: word count `mvars'

*set up vector with number of predictors if not specified
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
mat def `b'=`nrparv'*J(colsof(`nrparv'),rowsof(`nrparv'),1)
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


*exclude observations with inappropriate missings
mat def `b'=(`b',`locnr'*J(colsof(`locnr'),rowsof(`locnr'),1))
if `b'[1,1]!=0 & `b'[1,2]>colsof(`locnr') {
	foreach var of varlist `mvars' {
		qui replace `touse'=0 if missing(`var')==1 & missing(`obs')==1
	}
}
if `b'[1,1]==0 {
	qui replace `touse'=0 if missing(`obs')==1
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

*create temporary variable names for simulated values and weights
if "`tname'"=="" tempname sim
else local sim "`tname'"
if "`exp'"=="" {
	local exp "none"
	local sweight ""
}
else {
	tempvar wgt
	local sweight `"=`wgt'"'
}

*get local that restricts graph
if strmatch("`restrict'","")==0 {
	if strmatch(lower(substr(trim("`restrict'")),1,2),"if")==1 local restrict=substr(trim("`restrict'")),3,.)
	if strmatch(substr(trim("`restrict'"),1,1),"&")!=1 local restrict="& `restrict'"
}

mata: condpar("`par'","`obs'","`pred'","`mvars'","`mixparv'","`nrparv'","`locmp'","`locmix'","`locnr'","`mixtrloc'","`nrtrloc'",(`mpfunc'),`mixtrfunc',`nrtrfunc',`nrwgttrfunc',`wgttrfunc',xb=.,wgt=.,nrwgt=.)
mata: conddraw(xb,wgt,nrwgt,`draws',"`obs'","`exp'","`sim'","`mppar'","`mixparv'","`nrparv'","`locmix'",(`mixfunc'),(`nrfunc'))
if "`ckolmogorov'"=="" mata: mata drop xb wgt nrwgt

***get pdf/cdf
if "`cdf'"=="" kdensity `sim' if `touse' `restrict' [`weight'  `sweight'], `options'
else {
	if "`cdfvar'"!="" local add `cdf'
	tempvar cdf
	cumul `sim' if `touse' [`weight' `sweight'], gen(`cdf')
	if "`add'"!="" {
		local i=_N
		local k=2
		foreach var of varlist `add' {
			cumul `var' if `touse' [`weight' `sweight'], gen(`cdf'_`var')
			sum `var' if `touse', meanonly
			local c=r(N)
			local j=_N+`c'
			qui: set obs `j'
			mata: st_view(a=.,(1,`no'),"`var' `cdf'_`var'",st_local("touse"))
			mata: st_select(c=.,a,a[,1]:!=.)
			mata: st_view(b=.,(`j'-`c'+1,`j'),"`sim' `cdf'_`var'")
			mata: b[,]=c
			mata: a[,2]=J(rows(a),1,.)
			local lbl=`"`lbl' label(`k' "`var'")"'
			local k=`k'+1
		}
		qui: replace `touse'=1 if _n>`i'
		if strmatch("`options'","*xtitle*")==0 local xtitle "xtitle(`sim')"
		if strmatch("`options'","*legend*")==0 local lgnd `"legend(label(1 "`sim'") `lbl')"'
		line `cdf' `cdf'_* `sim' if `touse' `restrict', sort(`sim' `cdf') `options' `xtitle' `lgnd'
		drop `cdf' `cdf'_*
		mata: mata drop a b c
		qui: keep if _n<=`i'
	}
	else {
		line `cdf' `sim' if `touse' `restrict', sort(`sim' `cdf')
		drop `cdf'
	}
}

*change things that are saved if kdensity not used
if "`cdf'"=="" {
	local en=`r(n)'
	local escale=`r(scale)'
	local ebwidth=`r(bwidth)'
	local ekernel "`r(kernel)'"
}
sum `sim' if `touse' [`weight'  `sweight'], d
local mean=`r(mean)'
local skewness=`r(skewness)'
local min=`r(min)'
local max=`r(max)'
local sum_w=`r(sum_w)'/`draws'
local p1=`r(p1)'
local p5=`r(p5)'
local p10=`r(p10)'
local p25=`r(p25)'
local p50=`r(p50)'
local p75=`r(p75)'
local p90=`r(p90)'
local p95=`r(p95)'
local p99=`r(p99)'
local Var=`r(Var)'
local kurtosis=`r(kurtosis)'
local sum=`r(sum)'/`draws'
local sd=`r(sd)'

*save
if "`save'"!="" {
	gettoken fname save : save, parse(",")
	local save=trim(subinstr("`save'",","," ",.))
	preserve
	gen touse=`touse'
	qui: keep `sim' `save' touse
	save `fname', replace
	restore
}
*Kolmogorov Smirnov test
if "`ksmirnov'"!="" {
	local n=`no'+_N
	qui: set obs `n'
	tempvar group
	qui: gen `group'="`ksmirnov'" if _n>`n'-`no'
	qui: replace `group'="Simulated" if `group'==""
	if ("Simulated">"`ksmirnov'") local infl 1 `draws'
	else local infl `draws' 1
	qui: replace `sim'=`ksmirnov'[_n-`n'+`no'] if _n>`n'-`no'
	qui: replace `touse'=`touse'[_n-`n'+`no'] if _n>`n'-`no'
	if "`exp'"!="none" qui: replace `wgt'=`wgt'[_n-`n'+`no'] if _n>`n'-`no'
	capture findfile ksmirnov2.ado
	if _rc==0 ksmirnov2 `sim' if `touse' [`weight' `sweight'], by(`group') inflate(`infl')
	else {
		if "`weight'"!="" di as err "ksmirnov2.ado not found, performing Kolmogorov-Smirnov test without weights and correcting sample size"
		ksmirnov `sim' if `touse', by(`group')
	}
	drop `group'
}

drop `sim'
cap drop `wgt'
qui: keep if _n<=`no'

*conditional kolmogorov test
if "`ckolmogorov'"!="" {
	if "`model'"=="" | ("`nrmodel'"=="" & `nrparv'[1,1]!=0) {
		di as err "Could not perform the Conditional Kolmogorov test, since it currently only works for conditional distributions specified by option model(). Sorry."
	}
else {
	if wordcount("`ckolmogorov'")==2 & strmatch("`ckolmogorov'","*,*")!=1 {
		local bsiter=real(word("`ckolmogorov'",2))		
		local ckolmogorov=word("`ckolmogorov'",1)
	}
	else if strmatch("`ckolmogorov'","*,*")==1 {
		gettoken ckolmogorov bsiter : ckolmogorov, parse(",")
		local bsiter=real(trim(subinstr("`bsiter'",","," ",.)))
	}
	*get test stat
	mata: ck=ck("`ckolmogorov'","`obs' `pred'","`mvars'",xb,wgt,nrwgt)
	mata: st_matrix(st_local("ck"),ck)
	di ""
	di in smcl as text `"{ul:Conditional Kolmogorov Test that `ckolmogorov' is a sample from the specified conditional distribution:} "'
	*bootstrap critical values
	if "`bsiter'"!="" {
		preserve
		local i=1
		if "`nrmodel'"=="" mata: ckd=J(`bsiter',1,.)
		else mata: ckd=J(`bsiter',2,.)
		di "Bootstrapping p-value. Iteration: "_c
		while `i'<=`bsiter' {
			if `i'<10 | mod(`i',10)==0 di "`i' " _continue
			mata: conddraw(xb,wgt,nrwgt,1,"`obs'","`exp'","`sim'","`mppar'","`mixparv'","`nrparv'","`locmix'",(`mixfunc'),(`nrfunc'))
			mata: ckd[strtoreal(st_local("i")),]=ck("`sim'","`obs' `pred'","`mvars'",xb,wgt,nrwgt)
			drop `sim'
			cap drop `wgt'
			local i=`i'+1
		}
		*get p-value
		mata: st_local(st_local("ckp"),strofreal(sum((ckd[,1]:>=ck[1,1]))/`bsiter'))
		if "`nrmodel'"!="" mata: st_local(st_local("ckpnr"),strofreal(sum((ckd[,2]:>=ck[1,2]))/`bsiter'))
		mata: mata drop ckd
		restore
	}
	else {
		local `ckp' "N/A"
		if "`nrmodel'"!="" local `ckpnr' "N/A"
	}
*	mata: mata clear
	*display output
	di ""
	di in smcl as text "Test Statistic: " as result `ck'[1,1]
	di in smcl as text "Bootstrapped p-value:" as result "``ckp''"
	if "`nrmodel'"!="" {
		di in smcl as text "Test Statistic Non-Response: " as result `ck'[1,2]
		di in smcl as text "Bootstrapped p-value Non-Response:" as result "``ckpnr''"
	}
}
mata: mata drop xb wgt nrwgt ck
}

ereturn post, obs(`no') esample(`touse') properties("")
if "`cdf'"=="" {
ereturn scalar n=`en'
ereturn scalar scale=`escale'
ereturn scalar bwidth=`ebwidth'
ereturn local kernel "`ekernel'"
}
ereturn scalar mean=`mean'
ereturn scalar skewness=`skewness'
ereturn scalar min=`min'
ereturn scalar max=`max'
ereturn scalar sum_w=`sum_w'
ereturn scalar p1=`p1'
ereturn scalar p5=`p5'
ereturn scalar p10=`p10'
ereturn scalar p25=`p25'
ereturn scalar p50=`p50'
ereturn scalar p75=`p75'
ereturn scalar p90=`p90'
ereturn scalar p95=`p95'
ereturn scalar p99=`p99'
ereturn scalar Var=`Var'
ereturn scalar kurtosis=`kurtosis'
ereturn scalar sum=`sum'
ereturn scalar sd=`sd'

if "`ksmirnov'"!="" {
	ereturn scalar ks_D_1=r(D_1)
	ereturn scalar ks_p_1=r(p_1)
	ereturn scalar ks_D_2=r(D_2)
	ereturn scalar ks_p_2=r(p_2)
	ereturn scalar ks_D=r(D)
	ereturn scalar ks_p=r(p)
	ereturn scalar ks_p_cor=r(p_cor)   
	ereturn local ks_group1=r(group1)
	ereturn local ks_group2=r(group2)
}

if "`ckolmogorov'"!="" {
	ereturn scalar ck=`ck'[1,1]
	if colsof(`ck')>1 ereturn scalar cknr=`ck'[1,2]
	if real("``ckp''")!=. ereturn scalar p_ck=``ckp''
	if real("``ckpnr''")!=. ereturn scalar p_cknr=``ckpnr''
	if real("`bsiter'")!=. ereturn scalar ck_bsi=`bsiter'
}


*clean up
matrix drop `b' `par' `nrtrloc' `mixtrloc' `locmix' `npred' `nrparv' `mixparv' `locnr' 
cap matrix drop `locmp'
sca drop `mppar' `nrwgttr' `wgttr'
ereturn local cmd "cddens"
end

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

/*calculate test stat for conditional kolmogorov test*/
real rowvector ck(string scalar yvar,string scalar xvars, string scalar mvars, real matrix xb, real rowvector wgt, real rowvector nrwgt) {
/*declare variables*/
real matrix x,xnr
real colvector y, cf, c, mp, s
real scalar mppar,j,k
/*setup*/
st_view(y=.,.,yvar,st_local("touse"))
st_view(x=.,.,tokens(xvars), st_local("touse"))
st_view(xnr=.,.,tokens(mvars), st_local("touse"))
if (cols(xnr)==0) xnr=J(rows(xnr),1,0)
mppar=st_numscalar(st_local("mppar"))
k=1+mppar+st_matrix(st_local("nrparv"))*J(cols(st_matrix(st_local("nrparv"))),rows(st_matrix(st_local("nrparv"))),1)
c=J(rows(x),1,0)
if (mppar!=0) mp=xb[,1]
else mp=J(rows(x),1,0)
/*create ck for every observation*/
for(j=1;j<=rows(x);j++) {
	/*create vector of cond cdf for y[j,]*/
	/*for nr*/
	if (x[j,1]==.) {
		s=rowmin((xnr:<=xnr[j,])):*(x[,1]:==.)
		cf=J(sum(s),1,0)
		if (strmatch(st_local("nrmodel"),"normal")==1) cf=normal((y[j,]:-select(xb[,mppar+1],s)):/select(xb[,mppar+2],s))
		if (strmatch(st_local("nrmodel"),"trnorm")==1) cf=(normal((y[j,]:-select(xb[,mppar+1],s)):/select(xb[,mppar+2],s))-normal((select(xb[,mppar+3],s):-select(xb[,mppar+1],s)):/select(xb[,mppar+2],s))):/(normal((select(xb[,mppar+4],s):-select(xb[,mppar+1],s)):/select(xb[,mppar+2],s))-normal((select(xb[,mppar+3],s):-select(xb[,mppar+1],s)):/select(xb[,mppar+2],s)))
		if (strmatch(st_local("nrmodel"),"ltrnorm")==1) cf=(normal((y[j,]:-select(xb[,mppar+1],s)):/select(xb[,mppar+2],s))-normal((select(xb[,mppar+3],s):-select(xb[,mppar+1],s)):/select(xb[,mppar+2],s))):/(1:-normal((select(xb[,mppar+3],s):-select(xb[,mppar+1],s)):/select(xb[,mppar+2],s)))
		if (strmatch(st_local("nrmodel"),"rtrnorm")==1) cf=normal((y[j,]:-select(xb[,mppar+1],s)):/select(xb[,mppar+2],s)):/(normal((select(xb[,mppar+3],s):-select(xb[,mppar+1],s)):/select(xb[,mppar+2],s)))
		if (strmatch(st_local("nrmodel"),"mixnorm")==1) cf=(nrwgt[1,1]:*normal((y[j,]:-select(xb[,mppar+1],s)):/select(xb[,mppar+2],s))+nrwgt[1,2]:*normal((y[j,]:-select(xb[,mppar+3],s)):/select(xb[,mppar+4],s)))		
		if (strmatch(st_local("nrmodel"),"mixtrnorm")==1) cf=nrwgt[1,1]:*(normal((y[j,]:-select(xb[,mppar+1],s)):/select(xb[,mppar+2],s))-normal((select(xb[,mppar+3],s):-select(xb[,mppar+1],s)):/select(xb[,mppar+2],s))):/(normal((select(xb[,mppar+4],s):-select(xb[,mppar+1],s)):/select(xb[,mppar+2],s))-normal((select(xb[,mppar+3],s):-select(xb[,mppar+1],s)):/select(xb[,mppar+2],s)))+nrwgt[1,2]:*(normal((y[j,]:-select(xb[,mppar+5],s)):/select(xb[,mppar+6],s))-normal((select(xb[,mppar+7],s):-select(xb[,mppar+5],s)):/select(xb[,mppar+6],s))):/(normal((select(xb[,mppar+8],s):-select(xb[,mppar+5],s)):/select(xb[,mppar+6],s))-normal((select(xb[,mppar+7],s):-select(xb[,mppar+5],s)):/select(xb[,mppar+6],s)))
		if (strmatch(st_local("nrmodel"),"mixltrnorm")==1) cf=nrwgt[1,1]:*(normal((y[j,]:-select(xb[,mppar+1],s)):/select(xb[,mppar+2],s))-normal((select(xb[,mppar+3],s):-select(xb[,mppar+1],s)):/select(xb[,mppar+2],s))):/(1:-normal((select(xb[,mppar+3],s):-select(xb[,mppar+1],s)):/select(xb[,mppar+2],s)))+nrwgt[1,2]:*(normal((y[j,]:-select(xb[,mppar+4],s)):/select(xb[,mppar+5],s))-normal((select(xb[,mppar+6],s):-select(xb[,mppar+4],s)):/select(xb[,mppar+5],s))):/(1:-normal((select(xb[,mppar+6],s):-select(xb[,mppar+4],s)):/select(xb[,mppar+5],s)))
		if (strmatch(st_local("nrmodel"),"mixrtrnorm")==1) cf=nrwgt[1,1]:*normal((y[j,]:-select(xb[,mppar+1],s)):/select(xb[,mppar+2],s)):/(normal((select(xb[,mppar+3],s):-select(xb[,mppar+1],s)):/select(xb[,mppar+2],s)))+nrwgt[1,2]:*normal((y[j,]:-select(xb[,mppar+4],s)):/select(xb[,mppar+5],s)):/(normal((select(xb[,mppar+6],s):-select(xb[,mppar+4],s)):/select(xb[,mppar+5],s)))		
		if (strmatch(st_local("nrmodel"),"exp")==1) cf=(1:-exp((-1):*select(xb[,mppar+2],s):*(y[j,]:-select(xb[,mppar+1],s))))
		if (strmatch(st_local("nrmodel"),"mixexp")==1) cf=(nrwgt[1,1]:*(1:-exp((-1):*select(xb[,mppar+2],s):*(y[j,]:-select(xb[,mppar+1],s))))+nrwgt[1,2]:*(1:-exp((-1):*select(xb[,mppar+4],s):*(y[j,]:-select(xb[,mppar+3],s)))))
		if (strmatch(st_local("nrmodel"),"weibull")==1) cf=(1:-exp((-1):*((y[j,]:-select(xb[,mppar+1],s)):/select(xb[,mppar+3],s)):^select(xb[,mppar+2],s)))
		if (strmatch(st_local("nrmodel"),"mixweibull")==1) cf=(nrwgt[1,1]:*(1:-exp((-1):*((y[j,]:-select(xb[,mppar+1],s)):/select(xb[,mppar+3],s)):^select(xb[,mppar+2],s)))+nrwgt[1,2]:*(1:-exp((-1):*((y[j,]:-select(xb[,mppar+4],s)):/select(xb[,mppar+6],s)):^select(xb[,mppar+5],s))))
		if (strmatch(st_local("nrmodel"),"t")==1) cf=nrwgt[1,1]:*(1:-ttail(select(xb[,mppar+3],s),(y[j,]:-select(xb[,mppar+1],s)):/select(xb[,mppar+2],s)))
		if (strmatch(st_local("nrmodel"),"mixt")==1) cf=(nrwgt[1,1]:*(1:-ttail(select(xb[,mppar+3],s),(y[j,]:-select(xb[,mppar+1],s)):/select(xb[,mppar+2],s)))+nrwgt[1,2]:*(1:-ttail(select(xb[,mppar+6],s),(y[j,]:-select(xb[,mppar+4],s)):/select(xb[,mppar+5],s))))
		if (strmatch(st_local("nrmodel"),"mixweit")==1) cf=(nrwgt[1,1]:*(1:-ttail(select(xb[,mppar+3],s),(y[j,]:-select(xb[,mppar+1],s)):/select(xb[,mppar+2],s)))+nrwgt[1,2]:*(1:-exp((-1):*((y[j,]:-select(xb[,mppar+4],s)):/select(xb[,mppar+6],s)):^select(xb[,mppar+5],s))))
	} 
	else {
		s=rowmin((x:<=x[j,]))
		cf=J(sum(s),1,0)
		/*mp*/
		if (mppar!=0) {
			cf=(y[j,]:>=select(x[,1],s)):*select(xb[,1],s)
		} 
		/*for me*/
		if (strmatch(st_local("model"),"normal")==1) cf=cf+(1:-select(mp,s)):*normal((y[j,]:-select(xb[,k],s)):/select(xb[,k+1],s))
		if (strmatch(st_local("model"),"trnorm")==1) cf=cf+(1:-select(mp,s)):*(normal((y[j,]:-select(xb[,k],s)):/select(xb[,k+1],s))-normal((select(xb[,k+2],s):-select(xb[,k],s)):/select(xb[,k+1],s))):/(normal((select(xb[,k+3],s):-select(xb[,k],s)):/select(xb[,k+1],s))-normal((select(xb[,k+2],s):-select(xb[,k],s)):/select(xb[,k+1],s)))
		if (strmatch(st_local("model"),"ltrnorm")==1) cf=cf+(1:-select(mp,s)):*(normal((y[j,]:-select(xb[,k],s)):/select(xb[,k+1],s))-normal((select(xb[,k+2],s):-select(xb[,k],s)):/select(xb[,k+1],s))):/(1:-normal((select(xb[,k+2],s):-select(xb[,k],s)):/select(xb[,k+1],s)))
		if (strmatch(st_local("model"),"rtrnorm")==1) cf=cf+(1:-select(mp,s)):*normal((y[j,]:-select(xb[,k],s)):/select(xb[,k+1],s)):/(normal((select(xb[,k+2],s):-select(xb[,k],s)):/select(xb[,k+1],s)))
		if (strmatch(st_local("model"),"mixnorm")==1) cf=cf+(1:-select(mp,s)):*(wgt[1,1]:*normal((y[j,]:-select(xb[,k],s)):/select(xb[,k+1],s))+wgt[1,2]:*normal((y[j,]:-select(xb[,k+2],s)):/select(xb[,k+3],s)))
		if (strmatch(st_local("model"),"mixtrnorm")==1) cf=cf+(1:-select(mp,s)):*(wgt[1,1]:*(normal((y[j,]:-select(xb[,k],s)):/select(xb[,k+1],s))-normal((select(xb[,k+2],s):-select(xb[,k],s)):/select(xb[,k+1],s))):/(normal((select(xb[,k+3],s):-select(xb[,k],s)):/select(xb[,k+1],s))-normal((select(xb[,k+2],s):-select(xb[,k],s)):/select(xb[,k+1],s)))+wgt[1,2]:*(normal((y[j,]:-select(xb[,k+4],s)):/select(xb[,k+5],s))-normal((select(xb[,k+6],s):-select(xb[,k+4],s)):/select(xb[,k+5],s))):/(normal((select(xb[,k+7],s):-select(xb[,k+4],s)):/select(xb[,k+5],s))-normal((select(xb[,k+6],s):-select(xb[,k+4],s)):/select(xb[,k+5],s))))
		if (strmatch(st_local("model"),"mixltrnorm")==1) cf=cf+(1:-select(mp,s)):*(wgt[1,1]:*(normal((y[j,]:-select(xb[,k],s)):/select(xb[,k+1],s))-normal((select(xb[,k+2],s):-select(xb[,k],s)):/select(xb[,k+1],s))):/(1:-normal((select(xb[,k+2],s):-select(xb[,k],s)):/select(xb[,k+1],s)))+wgt[1,2]:*(normal((y[j,]:-select(xb[,k+3],s)):/select(xb[,k+4],s))-normal((select(xb[,k+5],s):-select(xb[,k+3],s)):/select(xb[,k+4],s))):/(1:-normal((select(xb[,k+5],s):-select(xb[,k+3],s)):/select(xb[,k+4],s))))
		if (strmatch(st_local("model"),"mixrtrnorm")==1) cf=cf+(1:-select(mp,s)):*(wgt[1,1]:*normal((y[j,]:-select(xb[,k],s)):/select(xb[,k+1],s)):/(normal((select(xb[,k+2],s):-select(xb[,k],s)):/select(xb[,k+1],s)))+wgt[1,2]:*normal((y[j,]:-select(xb[,k+3],s)):/select(xb[,k+4],s)):/(normal((select(xb[,k+5],s):-select(xb[,k+3],s)):/select(xb[,k+4],s))))
		if (strmatch(st_local("model"),"exp")==1) cf=cf+(1:-select(mp,s)):*(1:-exp((-1):*select(xb[,k+1],s):*(y[j,]:-select(xb[,k],s))))
		if (strmatch(st_local("model"),"mixexp")==1) cf=cf+(1:-select(mp,s)):*(wgt[1,1]:*(1:-exp((-1):*select(xb[,k+1],s):*(y[j,]:-select(xb[,k],s))))+wgt[1,2]:*(1:-exp((-1):*select(xb[,k+3],s):*(y[j,]:-select(xb[,k+2],s)))))
		if (strmatch(st_local("model"),"weibull")==1) cf=cf+(1:-select(mp,s)):*(1:-exp((-1):*((y[j,]:-select(xb[,k],s)):/select(xb[,k+2],s)):^select(xb[,k+1],s)))
		if (strmatch(st_local("model"),"mixweibull")==1) cf=cf+(1:-select(mp,s)):*(wgt[1,1]:*(1:-exp((-1):*((y[j,]:-select(xb[,k],s)):/select(xb[,k+2],s)):^select(xb[,k+1],s)))+wgt[1,2]:*(1:-exp((-1):*((y[j,]:-select(xb[,k+3],s)):/select(xb[,k+5],s)):^select(xb[,k+4],s))))
		if (strmatch(st_local("model"),"t")==1) cf=cf+(1:-select(mp,s)):*(1:-ttail(select(xb[,k+2],s),(y[j,]:-select(xb[,k],s)):/select(xb[,k+1],s)))
		if (strmatch(st_local("model"),"mixt")==1) cf=cf+(1:-select(mp,s)):*(wgt[1,1]:*(1:-ttail(select(xb[,k+2],s),(y[j,]:-select(xb[,k],s)):/select(xb[,k+1],s)))+wgt[1,2]:*(1:-ttail(select(xb[,k+5],s),(y[j,]:-select(xb[,k+3],s)):/select(xb[,k+4],s))))
		if (strmatch(st_local("model"),"mixweit")==1) cf=cf+(1:-select(mp,s)):*(wgt[1,1]:*(1:-ttail(select(xb[,k+2],s),(y[j,]:-select(xb[,k],s)):/select(xb[,k+1],s)))+wgt[1,2]:*(1:-exp((-1):*((y[j,]:-select(xb[,k+3],s)):/select(xb[,k+5],s)):^select(xb[,k+4],s))))
	}
	/*calculate statistic*/
	c[j,1]=J(1,sum(s),1)*((select(y,s):<=y[j,])-cf)
}
if (nrwgt[1,1]==.) return(max(abs(c))/sqrt(rows(x)))
else return((max(abs(select(c,(x[,1]:!=.))))/sqrt(sum((x[,1]:!=.))),max(abs(select(c,(x[,1]:==.))))/sqrt(sum((x[,1]:==.)))))
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
function mrexp(x) return(-log(runiform(1,1))/x)
end


