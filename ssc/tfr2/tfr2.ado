* tfr2 *****************************
* Author : Bruno Schoumaker (UCL)  *
* bruno.schoumaker@uclouvain.be    *
* May 17, 2013                     *
*                                  *
* version 1.2.1                    *
************************************

program tfr2, byable(recall) 
version 10.0
syntax [varlist(default=none)] [if] [pweight] [, /*
*/ BVar(varlist)  LENgth(integer 3) DATes(string) /* 
*/ WBirth(varname) AGeg(integer 5) CLuster(varname) /* 
*/ TRend(integer 9999) AWF(varname) MINage(integer 15) (MAXage(integer 49)/*
*/ ENTRy(varname) MAC noRates CYears noTFR ONLYTab/*
*/ SAVETAB(string) SAVERates(string) SAVETRend(string) SAVESChed(string) GT GR SE Level(cilevel)/*
*/ ENDy(integer 9999) /* 
*/ INput(string) FRM ADJExp DV]  


*--------------------------
*------- error messages
*--------------------------


*------- error message if single age group

local max2=int(`maxage'/`ageg')*`ageg'
if `max2'==`minage' & ("`varlist'"==""& (`trend'==9999|`trend'==`length')) {
	di as error "tfr2 does not allow computing rates for a single age group. Use at least two age groups, or use the command tabexp."
	error 198
	exit
}


*-------- error message for input format

if ("`input'" != "wide" & "`input'"!="" & "`input'"!="table") {
	di as error "input format must be wide or table (default is wide)."
	error 198
	exit
}



*-------- error message for se without graph or save

if ("`se'"=="se" & ("`gr'"=="" & "`gt'"=="" & "`saverates'"=="" & "`savetrend'"=="")) {
	di as error "se is only allowed with gr, gt, saverates and savetrend."
	error 198
	exit
}

*-------- error message for savetr with saver

if ("`savetrend'"!="" & "`saverates'"!="")  {
	di as error "savetrend can not be combined with saverates."
	error 198
	exit
}



*-------- select TREND equal to LENgth as default 
if `trend' == 9999 {
	local trend=`length'
}


*------- error message for savesched without trend

if `trend'==`length' & ("`savesched'"!="") {
	di as error "savesched can only be used if trend<length."
	error 198
	exit
}

*------- error message for savesched without trend

if `trend'==`length' & ("`savetrend'"!="") {
	di as error "savetrend can only be used if trend<length."
	error 198
	exit
}

*------- error message for saver with trend

if `trend'!=`length' & ("`saverates'"!="") {
	di as error "saverates can not be used with trend. Use savetrend."
	error 198
	exit
}



*-------- Creation of list of explanatory variables for categorical variables

tokenize `varlist' , parse(" ")


if "`varlist'"!="" {
	di "Explanatory variables :" "`varlist'"
}


*-----------------
*------- tokenize
*-----------------


*-------- tokenize saverates for the replace option


tokenize "`saverates'", parse(",")

foreach number of numlist  1/3 {
	local var`number'="``number''"
}

local saverates=trim("`var1'")

if "`var3'"=="replace" {
	local replace_r ", replace"
}

if "`var3'"!="replace" {
	local replace_r ""
}

*-------- tokenize savesched for the replace option

tokenize "`savesched'", parse(",")

foreach number of numlist  1/3 {
	local var`number'="``number''"
}

local savesched=trim("`var1'")
if "`var3'"=="replace" {
	local replace_s ", replace"
}

if "`var3'"!="replace" {
	local replace_s ""
}


*-------- tokenize savetrend for the replace option

tokenize "`savetrend'", parse(",")

foreach number of numlist  1/3 {
	local var`number'="``number''"
}
local savetrend=trim("`var1'")
if "`var3'"=="replace" {
	local replace_tr ", replace"
}

if "`var3'"!="replace" {
	local replace_tr ""
}


*-------- Keep the weight variable in exp

local varwei=subinstr("`exp'","=","",1)


if "`exp'" == "" {
	local pweight ""
}

if "`exp'" != "" {
	local pweight "[pweight`exp']"
}


*--------  preserve data set
preserve



*--------------------------
*------- Data organization
*--------------------------



*-------- KEEP OBSERVATIONS FOR BYABLE (and if)
marksample touse
quietly: keep if `touse'


*-------- reshape data according to input format

*if input=table - go to TFR directly (ask)
*if input=wide - use tabexp to prepare data


if "`input'"=="table" {
* do nothing (for now)
}


if "`input'" == "wide" |"`input'"=="" {

*-------- use tabexp

tabexp `varlist' `if' `pweight', /*
*/ bvar(`bvar')  length(`length') dates(`dates') wbirth(`wbirth') ageg(`ageg') cluster(`cluster')/*
*/ trend(`trend') awf(`awf') minage(`minage') maxage(`maxage')/*
*/ entry(`entry') `cyears'/*
*/ savetab(`savetab') endy(`endy') force nodis `frm' `adjexp' `dv'

}




*------ compute central date

tempvar centry_max centry_min centry_mean
egen `centry_max'=max(centry)
egen `centry_min'=min(centry)
gene `centry_mean'= (`centry_max'+`centry_min')/2
local centry=`centry_mean'


*------------------------------------------
*--------creation of the rates expressions
*------------------------------------------

* use same variable names as inputs if table format

tempvar exposy age_g period
gene `age_g'=ageg
gene `exposy'=exposure
gene `period'=period


tempvar agemax_v agemin_v 
egen `agemax_v'=max(`age_g')
egen `agemin_v'=min(`age_g')

local agemax=`agemax_v'
local agemin=`agemin_v'
local agemin_s=`agemin'+`ageg'


*--------names of rates
forval i=`agemin'(`ageg')`agemax' {

local lowerb=`i'
local upperb=`i'+`ageg'-1
local cent_age`i'=(`lowerb'+`upperb'+1)/2

if `lowerb'!=`upperb' {
local name`i' "Rate_`lowerb'`upperb'"
}

if `lowerb'==`upperb' {
local name`i' "Rate_`lowerb'"
}
}

*--------RATES AND TFR FOR REFERENCE CATEGORY/YEAR

*--------formulas of rates and mean age at childbearing

*--------rate of first group

local rate`agemin'="(exp(_b[_cons]))"
local rate_all (`name`agemin'':`rate`agemin'')
local TFR "`rate`agemin''*`ageg'"
local MAC "`rate`agemin''*`cent_age`agemin''"

*--------rate in other age groups

forval i=`agemin_s'(`ageg')`agemax' {
	local rate`i' "(exp(_b[_A`age_g'_`i']+_b[_cons]))"
	local rate_all `rate_all' (`name`i'':`rate`i'')

	local TFR `TFR' + `ageg'*`rate`i''
	local MAC `MAC' + `cent_age`i''*`rate`i''

	local COEFA`i' "_A`age_g'_`i' "
	local COEFA_all `COEFA_all' `COEFA`i''
}

*di "`rate_all'"
*di "`COEFA_all'"



*-------- TFR
local TFR "(`TFR')"
local TFR_all (TFR:`TFR')

*-------- Mean age at childbearing
local MAC_all (MAC:((`MAC')/(`TFR')*`ageg'))



*-----------------------------------------------
*-------- FITTING THE POISSON REGRESSION MODELS
*-----------------------------------------------


* --- no clustering

if "`cluster'" == "" {

** so prefix of age groupe is changed to _A - so that _I variables not dropped

	quietly : xi, prefix(_A) i.`age_g' 
	local Age _A*

	if `agemax'==`agemin' {
		local Age ""
	}

	quietly : poisson events `Age' `varlist', exposure(`exposy')  level(`level')


}


* --- with clustering

if "`cluster'" != "" {

	quietly : xi, prefix(_A) i.`age_g' 

	local Age _A*

	if `agemax'==`agemin' {
		local Age ""
	}

	quietly : jackknife, cluster("`cluster'") : poisson events `Age' `varlist'  , exposure(`exposy')  level(`level')

}


estimates store Rate_ratios

di ""

if "`varlist'"!=""{
	di in smcl  "{bf:ASFRs and TFR for the reference category/ies (categorical covariate) or covariate/s equal to 0}" 
}

if "`varlist'"==""{
	if `trend'<`length' {
		di in smcl  "{bf:ASFRs and TFR (average over the period)}" 
	}

*-- title

	if `trend'>=`length' {

		local title "ASFRs - TFR"

		if "`rates'"=="norates" & "`tfr'"=="notfr" {
			local title=""
		}

		if "`rates'"=="norates" & "`tfr'"!="notfr" {
			local title="TFR"
		}

		if "`rates'"!="norates" & "`tfr'"=="notfr" {
			local title="ASFRs"
		}

	
		if "`mac'"=="mac" {
			local title="`title'  - Mean age at childbearing (MAC)"
		}

		di in smcl   "{bf:`title'}" 
	}

}

*---

if "`rates'"=="norates" {
	local rate_all ""
}

if "`tfr'"=="notfr" {
	local TFR_all ""
}

if "`mac'"=="" {
	local MAC_all ""
}


*---------------------------------------------------
*** --- display results (ASFRS, TFR and MAC) *******
*---------------------------------------------------

quietly : nlcom `rate_all' `TFR_all' `MAC_all', post level(`level')
nlcom, level(`level')


*----------------------
*-------- saving rates
*----------------------

if "`saverates'" !="" {

	matrix c=e(b)'
	svmat c, name(rates)
	matrix d=vecdiag(e(V))'
	svmat d, names(se)
	quietly : replace se=sqrt(se)

	if "`se'"=="se" {
		keep rates se 
	}

	if "`se'"=="" {
		keep rates
	}



	gene age=`agemin'+((_n-1)*`ageg')+`ageg'/2


	local nline=_N-1

	if "`tfr'"=="notfr" {
		local nline=`nline'+1
	}

	if "`mac'"=="mac" {
		local nline=`nline'-1
	}


	quietly : replace age=. if rates==. | _n>`nline'

	quietly: keep if rates!=. 
	order age

	gene date=`centry'

	if "`rates'"=="norates"{
		drop age
	}

	save `saverates' `replace_r'

}


*-------------------------------
*--------display graph rates ***
*-------------------------------

if "`gr'" !="" {
	quietly{
		matrix c=e(b)'
		svmat c, name(rates)
		matrix d=vecdiag(e(V))'
		svmat d, names(se)
		quietly : replace se=sqrt(se)
		keep rates se 

		gene age=`agemin'+((_n-1)*`ageg')+`ageg'/2
		local nbageg=(`agemax'-`agemin')/`ageg'+1
		keep if _n<=`nbageg'
	}

	if "`se'"=="se" {

		tempvar level2 z
		scalar `level2'=1-((100-`level')/200)
		scalar `z'=invnorm(`level2')
		gene low=rates-`z'*se
		gene hi=rates+`z'*se
		twoway (rarea low hi age) (line rates age), title("Age-Specific Fertility Rates") xtitle(Age) ytitle("RATE") subtitle() note("Rates computed by `trend'-year period") legend(ring(0) pos(1) order(1 "`level'% CI" 2 "Rates") cols(1) size(small))
	}

	if "`se'"=="" {
		twoway (line rates age) , title("Age-Specific Fertility Rates") xtitle(Age) ytitle("RATE") subtitle() note("Rates computed by `trend'-year period") legend(ring(0) pos(1) order(1 "Rate") cols(1) size(small))
	}

}


*-------------------------------
*--------display rate ratios ***
*-------------------------------

	local Age _A*

	if `agemax'==`agemin' {
		local Age ""
	}


if "`varlist'"!=""{
	di in smcl  "{bf:Rate ratios of explanatory variables - Assumption of constant age fertility schedule}"
	quietly : estimates restore Rate_ratios



	estimates table, drop(_cons `COEFA_all') eform star(.10 .05 .01)

} 


*-----------------------
*-------- Trend model***
*-----------------------


if `trend'<`length' {

	if "`cluster'" == "" {
		quietly : xi, prefix(_A) i.`age_g'
		local Age _A*
		if `agemax'==`agemin' {
		local Age ""
		} 
		quietly : xi: poisson events `Age' i.`period', exposure(`exposy') level(`level')

	}


	if "`cluster'" != "" {
		quietly : xi, prefix(_A) i.`age_g'
		local Age _A*
		if `agemax'==`agemin' {
		local Age ""
		} 
		quietly : xi : jackknife, cluster("`cluster'") : poisson events `Age' i.`period', exposure(`exposy') level(`level')

	}


*---------------------------------------------
*-------- computation of TFRs from the model
*---------------------------------------------

*-------- TFR of first year

	local TFR_0 "`TFR'"
	local TFR_all (TFR_0:`TFR_0')
	local lmax=`length'-1

*-------- TFR for other years

	forval i=`trend'(`trend')`lmax' {

		local p`i'=`i'
		local TFR_`i' "`TFR_0'*exp(_b[_I`period'_`p`i''])"
		local TFR_all `TFR_all' (TFR_`i':`TFR_`i'')
	}

	if "`savesched'" !="" {
		quietly : nlcom `TFR_all' `rate_all', post level(`level')
	}

	if "`savesched'" =="" {
		quietly : nlcom `TFR_all', post level(`level')
	}


	di in smcl  "{bf:TFRs by `trend'-year periods - Assumption of constant age fertility schedule}"

	nlcom, level(`level')

*-------------------------
*-------- saving schedule
*-------------------------

	if "`savesched'" !="" {
		tempfile temp_pp
		quietly : save `temp_pp', replace
		matrix c=e(b)'
		svmat c, name(rates)
		matrix d=vecdiag(e(V))'
		svmat d, names(se)
		quietly : replace se=sqrt(se)

		if "`se'"=="se" {
			keep rates se 
		}

		if "`se'"=="" {
			keep rates 
		}

		keep if _n>`length'

		quietly: gene age=`agemin'+((_n-1)*`ageg')+`ageg'/2
		quietly : replace age=. if rates==. 
		quietly: keep if rates!=. 
		order age
		quietly : save `savesched' `replace_s'
		use `temp_pp', clear
	}

*-------------------
*------saving trend
*-------------------

	if "`savetrend'" !="" {

		tempfile temp_pp
		quietly : save `temp_pp', replace
		quietly : nlcom, level(`level')
		matrix c=e(b)'
		svmat c, name(TFR)
		matrix d=vecdiag(e(V))'
		svmat d, names(se)
		quietly : replace se=sqrt(se)

		if "`se'"=="se" {
			keep TFR se 
		}

		if "`se'"=="" {
			keep TFR 
		}

	quietly: keep if _n<=`length'
	gene date=`centry'-(`length'/2)+((_n-1)*`trend')+(`trend'/2)
	quietly : replace date=. if TFR==. 
	order date
	save `savetrend' `replace_tr'
	use `temp_pp', clear
}


*-------------------------------------
*-------- Graph of results - TRENDS
*-------------------------------------

if "`gt'" !="" {

	tempfile temp_pp
	quietly : save `temp_pp', replace
	quietly: nlcom, level(`level')
	matrix c=e(b)'
	svmat c, name(TFR)
	matrix d=vecdiag(e(V))'
	svmat d, names(se)
	quietly : replace se=sqrt(se)
	keep TFR se 

	if "`savesched'" !="" {
		keep if _n<=`length'
	}

	quietly : gene date=`centry'-(`length'/2)+((_n-1)*`trend')+(`trend'/2)
	quietly : replace date=. if TFR==. 


	if "`se'"=="" {
		twoway (line TFR date) , title("Total Fertility Rates (`minage'-`maxage')") xtitle(Period) ytitle("TFR(`minage'-`maxage')") subtitle() note("Rates computed by `trend'-year periods - Assumption of constant age fertility schedule") legend(ring(0) pos(1) order(1 "TFR") cols(1) size(small))
	}

	if "`se'"=="se" {

		tempvar level2 z
		scalar `level2'=1-((100-`level')/200)
		scalar `z'=invnorm(`level2')
		quietly : gene low=TFR-`z'*se
		quietly : gene hi=TFR+`z'*se
		twoway (rarea low hi date) (line TFR date) , title("Total Fertility Rates (`minage'-`maxage')") xtitle(Period) ytitle("TFR(`minage'-`maxage')") subtitle() note("Rates computed by `trend'-year periods - Assumption of constant age fertility schedule") legend(ring(0) pos(1) order(1 "`level'% CI" 2 "TFR") cols(1) size(small))
		use `temp_pp', clear

	}
}

}

*-------------------------------------
*-------- Restore original data
*-------------------------------------

restore


end



