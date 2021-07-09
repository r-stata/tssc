*********************************************************************
*** ------------------------------------------------------------- ***
*** PROGRAM TO CALCULATE COVARIANCE STRUCTURE OF EXISTING DATASET ***
*** ------------------------------------------------------------- ***
*********************************************************************
		
*! version 3.0 14apr2020

program define pc_dd_covar, rclass
version `=clip(`c(version)', 9.0, 13.1)'

syntax varname [if] [in], PREpsi(numlist >0 integer max=1) POSTpsi(numlist >0 integer max=1) ///
                          [i(varname) t(varname) DIsplay]

// store master dataset	in case of error
tempfile m_dta_before_psis
quietly save "`m_dta_before_psis'", replace

// check for errors in options
{
local depvar = subinstr("`1'",",","",1)

capture confirm numeric variable `depvar' 
	local rc = _rc
	if `rc' {
		display _n "{err}Error: Dependent variable `depvar' must be numeric"
		use "`m_dta_before_psis'", clear	
		exit `rc'
	}
capture tsset
	if !_rc & "`i'"=="" {
		local i = r(panelvar)
		display "{text}Warning: {inp}Cross-sectional unit i() missing, assumed to be `i'" _n
	}
capture tsset
	if !_rc & "`t'"=="" {
		local t = r(timevar)
		display "{text}Warning: {inp}Time period variable t() missing, assumed to be `t'" _n
	}
capture assert "`i'"!="" & "`t'"!=""
	local rc = _rc
	if `rc' {
		display "{err}Error: Must specify cross-sectional unit i() and time period t() variables "
		display "{err}       to estimate covariance structure of variable `depvar'   "
		use "`m_dta_before_psis'", clear	
		exit `rc'
	}	
capture confirm numeric variable `i' 
	local rc = _rc
	if `rc' {
		display _n "{err}Error: Cross-sectional unit variable `i' must be numeric"
		use "`m_dta_before_psis'", clear	
		exit `rc'
	}
capture confirm numeric variable `t' 
	local rc = _rc
	if `rc' {
		display _n "{err}Error: Time period variable `t' must be numeric"
		use "`m_dta_before_psis'", clear	
		exit `rc'
	}
if "`if'"!="" {
	capture keep `if'
		local rc = _rc
		if `rc' {
			display _n "{err}Error: Option if() needs to be a valid if statement, i.e. if(year>2000 & group==1)"
			use "`m_dta_before_psis'", clear	
			exit `rc'
		}		
}
if "`in'"!="" {
	capture keep `in'
		local rc = _rc
		if `rc' {
			display _n "{err}Error: Option in() needs to be a valid if statement, i.e. in 1/100"
			use "`m_dta_before_psis'", clear	
			exit `rc'
		}		
}
capture unique `i' `t' if `depvar'!=. & `i'!=. & `t'!=.
	local rc = _rc
	if `rc' {
		display _n "{err}Error: Please ssc install unique"
		use "`m_dta_before_psis'", clear	
		exit `rc'
	}		
quietly unique `i' `t' if `depvar'!=. & `i'!=. & `t'!=.
capture assert (r(N)==r(sum)) | (r(N)==r(unique))
	local rc = _rc
	if `rc' {
		display _n "{err}Error: To calculate variance structure, dependent variable `depvar' "
		display "{err}       must be unique by `i' and `t' "
		use "`m_dta_before_psis'", clear	
		exit `rc'
	}		
	
local tpsi = `prepsi'+`postpsi'
quietly unique `t'
capture assert `tpsi'<=r(sum) & `tpsi'<=r(unique)
	local rc = _rc
	if `rc' {
		display _n "{err}Error: Dataset contains only `r(sum)' time periods; cannot estimate  "
		display "{err}       covariance structure of a panel DD model with `tpsi' periods "
		use "`m_dta_before_psis'", clear	
		exit `rc'
	}

quietly unique `i' if `depvar'!=. & `i'!=. & `t'!=.
local n_I = min(r(sum),r(unique))
quietly unique `i' `t' if `depvar'!=. & `i'!=. & `t'!=.
capture assert (`n_I' <= r(sum)/2) & (`n_I' <= r(unique)/2)
	local rc = _rc
	if `rc' {
		display _n "{err}Error: Option i() must specify factor variable to serve as cross-sectional  "
		display "{err}       unit identifier, and units must have multiple time periods "
		use "`m_dta_before_psis'", clear	
		exit `rc'
	}

quietly unique `t' if `depvar'!=. & `i'!=. & `t'!=.
local n_T = min(r(sum),r(unique))
quietly unique `i' `t' if `depvar'!=. & `i'!=. & `t'!=.
capture assert (`n_T' <= r(sum)/2) & (`n_T' <= r(unique)/2)
	local rc = _rc
	if `rc' {
		display _n "{err}Error: Option t() must specify factor variable to serve as time-period  "
		display "{err}       identifier, and time periods must have multiple units "
		use "`m_dta_before_psis'", clear	
		exit `rc'
	}

}

// estimate residual variance and lagged covariances for all possible panel lengths
{
quietly sort `t'
quietly unique `t'
quietly egen tEMp_t_gROUp = group(`t')
quietly sum tEMp_t_gROUp
local t_gROUP_max = r(max)
local t_LoOP_max = `t_gROUP_max'-`tpsi'+1
if `t_LoOP_max'<=5000 {
	quietly gen tEMp_t_gROUP_loop = tEMp_t_gROUp
}
else {
	quietly egen tEMp_t_gROUp_tag = tag(tEMp_t_gROUp) if tEMp_t_gROUp<=`t_gROUP_max'-`tpsi'+1
	quietly gen tEMp_t_tag_sort = runiform() if tEMp_t_gROUp_tag==1
	sort tEMp_t_tag_sort
	quietly replace tEMp_t_tag_sort = . if _n>5000
	quietly egen tEMp_t_gROUP_loop_tag = group(tEMp_t_gROUp) if tEMp_t_tag_sort!=.
	quietly egen tEMp_t_gROUP_loop = mean(tEMp_t_gROUP_loop_tag), by(tEMp_t_gROUp)
	sort tEMp_t_gROUp
	drop tEMp_t_gROUp_tag tEMp_t_tag_sort tEMp_t_gROUP_loop_tag
	local t_LoOP_max = 5000
}	
local lAGS_max = `tpsi'-1
local lAGS_maxPRE = `prepsi'-1
local lAGS_maxPOST = `postpsi'-1
local prepsi_minus1 = `prepsi'-1
local postpsi_minus1 = `postpsi'-1

quietly gen var_EST = .
quietly gen cov_psiB = .
quietly gen cov_psiA = .
quietly gen cov_psiX = .
quietly gen n_uNIts_est = .

forvalues t_LoOP_sample = 1/`t_LoOP_max' {

	quietly sum tEMp_t_gROUp if tEMp_t_gROUP_loop==`t_LoOP_sample'
	local t_LoOP = r(mean)
	local t_LoOP_tpsi = `t_LoOP'+`lAGS_max'
	local t_LoOP_premax = `t_LoOP'+`prepsi'-1
	local t_LoOP_premax_minus1 = `t_LoOP'+`prepsi'-2
	local t_LoOP_postmin = `t_LoOP'+`prepsi'
	local t_LoOP_postmax_minus1 = `t_LoOP_tpsi'-1
	
	preserve

		quietly keep if inrange(tEMp_t_gROUp,`t_LoOP',`t_LoOP_tpsi')
		quietly reghdfe `depvar' , absorb(tEMp_fe1=`i' tEMp_fe2=tEMp_t_gROUp) resid
		quietly predict rEsId if e(sample), residuals
		quietly sum rEsId
		local var__LoOP = r(sd)^2

		quietly keep `i' tEMp_t_gROUp rEsId
		quietly keep if rEsId!=.
		quietly unique `i'
		local n_I_LoOP = min(r(sum),r(unique))
		quietly reshape wide rEsId, i(`i') j(tEMp_t_gROUp)

		forvalues t___LoOP = 1/`prepsi_minus1' {
			quietly gen covlag_B`t___LoOP' = .
		}
		forvalues t___LoOP = 1/`postpsi_minus1' {
			quietly gen covlag_A`t___LoOP' = .
		}
		forvalues t___LoOP = 1/`lAGS_max' {
			quietly gen covlag_X`t___LoOP' = .
		}
		
		forvalues t__LoOP = `t_LoOP'/`t_LoOP_premax_minus1' {
			local lAGS_max__LoOP = `prepsi'-(`t__LoOP'-`t_LoOP')-1
			forvalues t___LoOP = 1/`lAGS_max__LoOP' {
				local t__LoOP2 = `t__LoOP'+`t___LoOP'
					quietly correlate rEsId`t__LoOP' rEsId`t__LoOP2', covariance
					quietly replace covlag_B`t___LoOP' = r(cov_12) if _n==`t__LoOP'-`t_LoOP'+1
			}
		}	
		forvalues t__LoOP = `t_LoOP_postmin'/`t_LoOP_postmax_minus1' {
			local lAGS_max__LoOP = `postpsi'-(`t__LoOP'-`t_LoOP'-`prepsi')-1
			forvalues t___LoOP = 1/`lAGS_max__LoOP' {
				local t__LoOP2 = `t__LoOP'+`t___LoOP'
					quietly correlate rEsId`t__LoOP' rEsId`t__LoOP2', covariance
					quietly replace covlag_A`t___LoOP' = r(cov_12) if _n==`t__LoOP'-`t_LoOP'+1
			}
		}	
		forvalues t__LoOP = `t_LoOP'/`t_LoOP_premax' {
			forvalues t__LoOP2 = `t_LoOP_postmin'/`t_LoOP_tpsi' {
				local t___LoOP = `t__LoOP2'-`t__LoOP'
					quietly correlate rEsId`t__LoOP' rEsId`t__LoOP2', covariance
					quietly replace covlag_X`t___LoOP' = r(cov_12) if _n==`t__LoOP'-`t_LoOP'+1
			}
		}	
		
		local psiB_LoOP_SUM = 0
		local psiB_LoOP_COUNT = 0
		if `prepsi'>1 {
			foreach v of varlist covlag_B* {
				quietly sum `v'
				local psiB_LoOP_SUM = `psiB_LoOP_SUM' + r(sum)
				local psiB_LoOP_COUNT = `psiB_LoOP_COUNT' + r(N)
			}
		}	
		local psiB_LoOP = `psiB_LoOP_SUM'/`psiB_LoOP_COUNT'

		local psiA_LoOP_SUM = 0
		local psiA_LoOP_COUNT = 0
		if `postpsi'>1 {
			foreach v of varlist covlag_A* {
				quietly sum `v'
				local psiA_LoOP_SUM = `psiA_LoOP_SUM' + r(sum)
				local psiA_LoOP_COUNT = `psiA_LoOP_COUNT' + r(N)
			}
		}
		local psiA_LoOP = `psiA_LoOP_SUM'/`psiA_LoOP_COUNT'

		local psiX_LoOP_SUM = 0
		local psiX_LoOP_COUNT = 0
		foreach v of varlist covlag_X* {
			quietly sum `v'
			local psiX_LoOP_SUM = `psiX_LoOP_SUM' + r(sum)
			local psiX_LoOP_COUNT = `psiX_LoOP_COUNT' + r(N)
		}
	 local psiX_LoOP = `psiX_LoOP_SUM'/`psiX_LoOP_COUNT'

	restore
	
	quietly replace var_EST = `var__LoOP' * (`tpsi'*`n_I_LoOP'-1)/(`tpsi'*`n_I_LoOP') if _n==`t_LoOP_sample'
	if `prepsi'>1 {
		quietly replace cov_psiB = `psiB_LoOP' * (`n_I_LoOP'-1)/(`n_I_LoOP') if _n==`t_LoOP_sample'
	}
	if `postpsi'>1 {
		quietly replace cov_psiA = `psiA_LoOP' * (`n_I_LoOP'-1)/(`n_I_LoOP') if _n==`t_LoOP_sample'
	}
	quietly replace cov_psiX = `psiX_LoOP' * (`n_I_LoOP'-1)/(`n_I_LoOP') if _n==`t_LoOP_sample'
	quietly replace n_uNIts_est = `n_I_LoOP'  if _n==`t_LoOP_sample'

}
}


// output average of estimated variance/covariances 
{
quietly sum var_EST
local OuT_variance = `r(mean)'
return scalar variance = `OuT_variance'

if `prepsi'>1 {
	quietly sum cov_psiB 
	local OuT_psiB = `r(mean)'
	return scalar cov_pre = `OuT_psiB'
}

if `postpsi'>1 {
	quietly sum cov_psiA 
	local OuT_psiA = `r(mean)' 
	return scalar cov_post = `OuT_psiA'
}

quietly sum cov_psiX 
local OuT_psiX = `r(mean)'
return scalar cov_cross = `OuT_psiX'

quietly sum n_uNIts_est 
local OuT_nunits = `r(mean)'
return scalar n_units = `OuT_nunits'
}

// display output and restore original dataset
{
if "`display'"=="display" {
	foreach v in variance psiB psiA psiX {
		if "`OuT_`v''"!="" {
			local OuT_`v'_disp = string(`OuT_`v'',"%9.3f")
			if substr("`OuT_`v'_disp'",1,1)!="-" {
				local OuT_`v'_disp = " `OuT_`v'_disp'"
			}
		}
	}

	display _n "Estimated variance-covariance structure of idiosyncractic residuals:" _n 
	display "variance   = `OuT_variance_disp'  (estimated residual variance) " 
	if `prepsi'>1 {
		display "cov_pre = `OuT_psiB_disp'  (avg within-unit residual covariance in pre-treatment periods) " 
	}
	if `postpsi'>1 {
		display "cov_post = `OuT_psiA_disp'  (avg within-unit residual covariance in post-treatment periods) " 
	}
	display "cov_cross = `OuT_psiX_disp'  (avg within-unit residual covariance across pre/post-treatment periods) " 
}

use  "`m_dta_before_psis'", clear

}

end			

*******************************************************************************************
*******************************************************************************************
