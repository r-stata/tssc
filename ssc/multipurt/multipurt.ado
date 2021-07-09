***************************************************************************************************
*!version 1.0.1 8Feb2011
*!multipurt - 	Carrying out 1st and 2nd generation panel unit root tests for several variables 
*		 	and a variety of lag augmentations
* 			For feedback please email me at markus.eberhardt@economics.ox.ac.uk
* 			Visit http://sites.google.com/site/medevecon/ for macro panel data 
*				and other Stata routines
***************************************************************************************************
* multipurt
***************************************************************************************************
* Known Bugs: 	
*		-none
*
* Planned extensions:
*		-include the new CIPSM by Pesaran, Smith & Yamagata (2009)
*
* Revisions made:
* v.1.0.1 (8Feb2011)
*		-corrected results table layout in accordance with Stata standards  
*		-corrected other minor presentational issues
*		-corrected results matrices for MW
*
***************************************************************************************************

capture program drop multipurt
program define multipurt, rclass prop(xt) sort
version 10

      syntax varlist [if] [in] [, I(varname) T(varname) LAGS(numlist integer max=1 >=0)]

      tokenize `varlist'
	local ind `varlist'
	local novars: word count `ind'

	if `novars' >9 {
		di as err "A maximum of 9 variables/series can be tested together."
		exit 459
	}

      _xt, i(`i') t(`t')
      local ivar "`r(ivar)'"
      local tvar "`r(tvar)'"
	sort `ivar' `tvar'
	
	set more off

quietly{

/* Error if  missing panel id or not tsset */
	if "`ivar'" == "" {
		di as err "You must tsset the data and specify the panel and time variables."
		exit 459
	}
	capture assert ! missing(`ivar')
	if c(rc) {
		di as err `"missing values in `ivar' `i' not allowed"'
		exit 459
	}

/* Mark the sample */
	marksample touse
	markout `touse' `ivar'
	tsreport if `touse', report panel

if r(N_gaps) {
	di as error ""
	di as error _col(2) "Note that since the panel has gaps the CIPS t-bar statistic cannot be computed."
	di as error _col(2) "However, the Z-tbar statistic is still available. Below error messages can be ignored."
	di as error ""
}

/* Create group variable */
	tempvar g 
	egen `g' = group(`ivar') if `touse'
	sum `g' if `touse'
	local ng = r(max)

/* Extract the lag augmentations to be tested */
	if "`lags'" == "" {
		di as err "The option lags has to be provided."
		exit 459
	}
	local maxlag = `lags'


/* Check the data */

	tempvar one numbobs miss nonmiss
	qui egen `miss' = rowmiss(`ind')
	qui gen `nonmiss' = 1 if `miss' == 0
	qui by `ivar': egen `numbobs' = sum(`nonmiss') if `touse'
	local minobs = 2*`maxlag' +2+ 4
	qui sum `numbobs' if `touse'
	local avgobs=r(mean)
	local nobs=r(N)
	if r(min) < `minobs' {
		di as err ""
		di as err _col(2) "With `maxlag' lag(s) as well as constant and trend terms " _continue 
		di as err _col(2) "at least `minobs' observations are required for the Pesaran (2007) test."
		di as err _col(2) "The following series do not contain sufficient observations:"
		noisily tab `ivar' if (`numbobs' < `minobs') & `touse'
		exit
	}


/* Create matrices to store the results */
	tempname mw mw_trend cips cips_trend
	local rrows=`maxlag'+1
	local rcols=`novars'*3+1
	local rcols2=`novars'*2+1
	mat `cips' = J(`rrows',`rcols',0)
	mat `cips_trend' = J(`rrows',`rcols',0)
	mat `mw' = J(`rrows',`rcols2',0)
	mat `mw_trend' = J(`rrows',`rcols2',0)

local z "`varlist'"
forvalues k=1/`novars'{
		forvalues l=0/`maxlag'{
				* MW no trend
				tempname chi2 pval tbar
            		local name : word `k' of `varlist'
				qui xtfisher `name' if `touse', lag(`l') 
				scalar `chi2'=r(dftest)
				scalar `pval'=r(pval)
				scalar `tbar'=r(tbar)
				mat `mw'[`l'+1,1]=`l'
				mat `mw'[`l'+1,1+(`k'*2)-1]=`chi2'
				mat `mw'[`l'+1,1+(`k'*2)]=`pval'
*				mat `mw'[`l'+1,1+(`k'*3)]=`tbar'
				* MW with trend
            		local name : word `k' of `varlist'
				qui xtfisher `name' if `touse', lag(`l') trend 
				scalar `chi2'=r(dftest)
				scalar `pval'=r(pval)
				scalar `tbar'=r(tbar)
				mat `mw_trend'[`l'+1,1]=`l'
				mat `mw_trend'[`l'+1,1+(`k'*2)-1]=`chi2'
				mat `mw_trend'[`l'+1,1+(`k'*2)]=`pval'
*				mat `mw_trend'[`l'+1,1+(`k'*3)]=`tbar'

				* CIPS no trend
				tempname Ztbar
            		local name : word `k' of `varlist'
				qui pescadf `name' if `touse', lag(`l') 
				scalar `Ztbar'=r(Ztbar)
				scalar `pval'=r(pval)
				scalar `tbar'=r(tbar)
				mat `cips'[`l'+1,1]=`l'
				mat `cips'[`l'+1,1+(`k'*3)-2]=`Ztbar'
				mat `cips'[`l'+1,1+(`k'*3)-1]=`pval'
				mat `cips'[`l'+1,1+(`k'*3)]=`tbar'
				* CIPS with trend
            		local name : word `k' of `varlist'
				qui pescadf `name' if `touse', lag(`l') trend 
				scalar `Ztbar'=r(Ztbar)
				scalar `pval'=r(pval)
				scalar `tbar'=r(tbar)
				mat `cips_trend'[`l'+1,1]=`l'
				mat `cips_trend'[`l'+1,1+(`k'*3)-2]=`Ztbar'
				mat `cips_trend'[`l'+1,1+(`k'*3)-1]=`pval'
				mat `cips_trend'[`l'+1,1+(`k'*3)]=`tbar'
		}
}


*end of quietly
}

	di ""
	di ""
	di in gr _col(2) "First and Second Generation Panel Unit Root Tests"
	di ""
	di in gr _col(2) "Variables tested: " in ye _col(30) "`varlist'" 
	di in gr _col(2) "Group variable: " in ye _col(30) "`ivar'"    
	di in gr _col(2) "Number of groups: " in ye _col(30) "`ng'"
	di in gr _col(2) "Total # of observations: " in ye _col(30) `nobs' in gr "+"
	di in gr _col(2) "Average # of observations: " in ye _col(30) %-4.2f `avgobs' in gr "+" 
	if `avgobs'!= round(`avgobs'){
	di in gr _col(2) "Panel is " in ye "unbalanced" _continue
	}
	else di in gr  _col(2) "Panel is " in ye "balanced"  _continue
	if r(N_gaps){
		di in gr " and has " in ye "gaps" 
	}
	else di in gr " and has " in ye "no gaps" 
	di in gr _col(2) "+ Full sample statistics prior to testing."
	di ""
	di as text "{hline 52}"
	di in gr _col(2) "(A) Maddala and Wu (1999) Panel Unit Root test (MW)"
	di as text "{hline 52}"
	di ""
	di as text "{hline 13}{c TT}{hline 38}"
	di as text _col(2) "           " " {c |}" _col(20) "Specification without trend"
	di as text "{hline 13}{c +}{hline 38}"		 
	di as text _col(2) "   Variable" " {c |}" _col(17) "lags" _col(24) "chi_sq" _col(33) "p-value"  
*_col(45) "t-bar" 
	di as text "{hline 13}{c +}{hline 38}"
		forvalues k=1/`novars'{
		forvalues l=0/`maxlag'{
			local name : word `k' of `varlist'
			di as text %12s abbrev("`name'",12) " {c |}" _col(19) "`l'" _continue
			di as result _col(23) %7.3f `mw'[`l'+1,1+(`k'*2)-1]  _col(35) %5.3f `mw'[`l'+1,1+(`k'*2)] 
		}
	if (`k' < `novars') {
     			di as text "{hline 13}{c +}{hline 38}"
      	}
	else {
     			di as text "{hline 13}{c BT}{hline 38}"
		}
	}
	di as text "{hline 13}{c TT}{hline 38}"
	di as text _col(2) "           " " {c |}" _col(20) "Specification with trend"
	di as text "{hline 13}{c +}{hline 38}"		 
	di as text _col(2) "   Variable" " {c |}" _col(17) "lags" _col(24) "chi_sq" _col(33) "p-value" 
*_col(45) "t-bar" 
	di as text "{hline 13}{c +}{hline 38}"
		forvalues k=1/`novars'{
		forvalues l=0/`maxlag'{
			local name : word `k' of `varlist'
			di as text %12s abbrev("`name'",12) " {c |}" _col(19) "`l'" _continue
			di as result _col(23) %7.3f `mw_trend'[`l'+1,1+(`k'*2)-1]  _col(35) %5.3f `mw_trend'[`l'+1,1+(`k'*2)] 
		}
	if (`k' < `novars') {
     			di as text "{hline 13}{c +}{hline 38}"
      	}
	else {
     			di as text "{hline 13}{c BT}{hline 38}"
		}
	}




	di ""
	di ""
	di as text "{hline 52}"
	di in gr _col(2) "(B) Pesaran (2007) Panel Unit Root test (CIPS)"
	di as text "{hline 52}"
	di ""
	di as text "{hline 13}{c TT}{hline 38}"
	di as text _col(2) "           " " {c |}" _col(20) "Specification without trend" 
	di as text "{hline 13}{c +}{hline 38}"		 
	di as text _col(2) "   Variable" " {c |}" _col(17) "lags" _col(24) "Zt-bar" _col(33) "p-value" _col(45) "t-bar" 
	di as text "{hline 13}{c +}{hline 38}"
	forvalues k=1/`novars'{
		forvalues l=0/`maxlag'{
			local name : word `k' of `varlist'
			di as text %12s abbrev("`name'",12) " {c |}" _col(19) "`l'" _continue
			di as result _col(23) %7.3f `cips'[`l'+1,1+(`k'*3)-2]  _col(35) %5.3f `cips'[`l'+1,1+(`k'*3)-1] _continue
			if r(N_gaps) {
				di as result _col(48) %5.3f "."
			}	
			else 	di as result _col(44) %5.3f `cips'[`l'+1,1+(`k'*3)]
		}
		if (`k' < `novars') {
     			di as text "{hline 13}{c +}{hline 38}"
      	}
		else {
     			di as text "{hline 13}{c BT}{hline 38}"
		}
	}
	di as text "{hline 13}{c TT}{hline 38}"
	di as text _col(2) "           " " {c |}" _col(20) "Specification with trend"
	di as text "{hline 13}{c +}{hline 38}"		 
	di as text _col(2) "   Variable" " {c |}" _col(17) "lags" _col(24) "Zt-bar" _col(33) "p-value" _col(45) "t-bar" 
	di as text "{hline 13}{c +}{hline 38}"
		forvalues k=1/`novars'{
		forvalues l=0/`maxlag'{
			local name : word `k' of `varlist'
			di as text %12s abbrev("`name'",12) " {c |}" _col(19) "`l'" _continue
			di as result _col(23) %7.3f `cips_trend'[`l'+1,1+(`k'*3)-2]  _col(35) %5.3f `cips_trend'[`l'+1,1+(`k'*3)-1] _continue
			if r(N_gaps) {
				di as result _col(48) %5.3f "."
			}	
			else 	di as result _col(44) %5.3f `cips_trend'[`l'+1,1+(`k'*3)]
		}
	if (`k' < `novars') {
     			di as text "{hline 13}{c +}{hline 38}"
      	}
	else {
     			di as text "{hline 13}{c BT}{hline 38}"
		}
	}


di in gr  _col(2) "Null for MW and CIPS tests: series is I(1)."
di in gr  _col(2) "MW test assumes cross-section independence."
di in gr  _col(2) "CIPS test assumes cross-section dependence is in "
di in gr  _col(7) "form of a single unobserved common factor."
di ""
di in gr _col(2) "-multipurt- uses Scott Merryman's -xtfisher- and "
di in gr _col(7) "Piotr Lewandowski's -pescadf-."

return local varname `varlist'
return matrix mw `mw'
return matrix mw_trend `mw_trend'
return matrix cips `cips'
return matrix cips_trend `cips_trend'
return scalar N = `nobs'
return scalar avgobs = `avgobs'
return scalar N_g = `ng'
return scalar maxlags = `maxlag'


end

exit




