*! igesetci v 1.0
*! Pablo Mitnik
*!
*! Post-estimation command that computes Imbens and Manski's (2004) and Nevo and Rosen's (2012)
*! confidence intervals for partially identified parameters when the parameter is an intergenerational elasticity
*!
*! Last updated Feb. 2019

program igesetci, rclass

	version 13
	syntax varlist(min=2 max=2), lb(string) ub(string) ige(string) [ci(string) level(cilevel)]
	
	local cvar : word 1 of `varlist'
	local pvar : word 2 of `varlist'
	
	if "`ci'" == "" local ci im
	
	/*1. Check inputs*/
	
	if "`ige'" != "igeg" & "`ige'" != "igee" {
		di as error "ige option may only be igeg or igee"
		exit 198
	}
	
	if "`ci'" != "im" & "`ci'" != "nr" & "`ci'" != "imnr" {
		di as error "ci option may only be im or nr or imnr"
		exit 198
	}
	
	tempname cmodel
	_estimates hold `cmodel', nullok copy
	
	qui {
	
		foreach model in `lb' `ub' {
	
			capture estimates restore `model'
			if _rc!=0 {
				noi di as error "estimation results from model `model' are not stored"
				exit 198
			}			
			
			local matvars : colfullnames e(b)
			local ispvarthere = 0 
			
			if "`ige'"=="igeg" {
				foreach var in `matvars' {
					if "`var'"=="`pvar'" local ispvarthere = 1
				}
				if `ispvarthere'==0 {
					noi di as error "IGE estimate for parental variable `pvar' is not included in the results of model `model'"
					_estimates unhold `cmodel'
					exit 198		
				}
			}
			
			else if "`ige'"=="igee" {
				foreach var in `matvars' {
					if "`var'"=="`cvar':`pvar'" local ispvarthere = 1
				}
				if `ispvarthere'==0 {
					noi di as error "IGE estimate for parental variable `cvar':`pvar' is not included in the results of model `model'"
					_estimates unhold `cmodel'
					exit 198		
				}
			}			
					
		}
		
		local nmodelsub: word count `ub' 
		local nmodelslb: word count `lb'
		
		if `nmodelsub' > 1 | `nmodelslb' > 1 {
			noi di as error "{cmd:igesetci} computes confidence intervals for an individual set estimate"
			noi di as error "use {cmd:igeintbounds} for estimation and inference with an intersection-bounds estimator of an IGE"
			exit 198		
		}
			
		estimates restore `lb'
			
		if "`ige'"=="igeg" & "`e(cmd)'"!="regress" {
			noi di as error "with ige igeg, lower bound estimate needs to be computed with command {cmd:regress} but model `lb' is based on a different command"
			_estimates unhold `cmodel'
			exit 198
		}
		if "`ige'"=="igee" & "`e(cmd)'"!="poisson" {
			noi di as error "with ige igee, lower bound estimate needs to be computed with command {cmd:poisson} but model `lb' is based on a different command"
			_estimates unhold `cmodel'
			exit 198
		}
		
		local N_lb = e(N)
		
		estimates restore `ub'
			
		if "`ige'"=="igeg" & "`e(cmd)'"!="ivregress" {
			noi di as error  "with ige igeg, upper bound estimate needs to be computed with command {cmd:ivregress} but model `ub' is based on a different command"
			_estimates unhold `cmodel'
			exit 198
		}
	
		if "`ige'"=="igee" & "`e(cmd)'"!="ivpoisson" {
			noi di as error "with ige igee, upper bound estimate needs to be computed with command {cmd:ivpoisson} but model `ub' is based on a different command"
			_estimates unhold `cmodel'
			exit 198
		}
		
		local N_ub = e(N)
		
		if `N_lb' != `N_ub' {
			noi di as error "samples sizes for the lower-bound and upper-bound models are different"
			exit 198
		}
		
		else if `N_lb' == `N_ub' local n = `N_lb'
		
	} /*ends qui*/	
	
	/*2. Compute and report requested confidence interval*/
	
	if "`ige'"=="igeg" local fullvar `pvar'
	else if "`ige'"=="igee" local fullvar `cvar':`pvar'
	
	/*linear IV or GMM IVP estimate*/
			
	qui estimates restore `ub'
	
	tempname sub_pe sub_se 
	scalar `sub_pe' = _b[`fullvar']
	scalar `sub_se' = _se[`fullvar']

	/*OLS or PPML estimate*/
	
	qui estimates restore `lb'
	
	tempname slb_pe slb_se 
	scalar `slb_pe' = _b[`fullvar']
	scalar `slb_se' = _se[`fullvar']
	
	if "`ci'"=="im" | "`ci'"=="imnr"  {
	
		/*Relative width*/

		global RW = (`sub_pe'  - `slb_pe') / max(`slb_se', `sub_se') 

		/*Compute c */

		tempvar Y 
		gen `Y' = 0
		qui replace `Y' = `level'/100 in 1
		qui nl igesetci @ `Y', parameters(c) initial(c 1.64)
		tempname c ci_im_lb ci_im_ub
		scalar `c' = _b[_cons]		
		scalar `ci_im_lb' = `slb_pe' - `c' * `slb_se'
		scalar `ci_im_ub' = `sub_pe' + `c' * `sub_se'
	}
	
	if "`ci'"=="nr" | "`ci'"=="imnr"  {
	      
	      	tempname deltan pn k ci_nr_lb ci_nr_ub
	 	scalar `deltan' = `sub_pe' - `slb_pe'
		scalar `pn' = 1 - normal(ln(`n') * `deltan') * (1 - (`level'/100))
		scalar `k' = invnormal(`pn')
		
		scalar `ci_nr_lb' = `slb_pe' - `k' * `slb_se'
		scalar `ci_nr_ub' = `sub_pe' + `k' * `sub_se'	
		
	}    	

	/*Return and display results*/

	if "`ige'"=="igeg" local rige IGE of geometric mean
	else if "`ige'"=="igee" local rige IGE of expectation

	return scalar confidence_level = `level'
	if "`ci'"=="im" | "`ci'"=="imnr" {
		return scalar c = `c'
		return scalar ci_im_ub = `ci_im_ub' 
		return scalar ci_im_lb = `ci_im_lb' 
	}
	if "`ci'"=="nr" | "`ci'"=="imnr" {
		return scalar k = `k'
		return scalar ci_nr_ub = `ci_nr_ub' 
		return scalar ci_nr_lb = `ci_nr_lb' 
	}		
	return scalar pe_ub = `sub_pe'
	return scalar pe_lb = `slb_pe'
	return local model_ub "`ub'"
	return local model_lb "`lb'"
	return local ci "`ci'"
	return local ige "`ige'"
	return local cmd "igesetci"		

	di as txt "{hline 70}"
	di as text "Partially identified `rige', based on estimates"
	di as text "from stored models `lb' (lower bound) and `ub' (upper bound)"
	di as text ""
	di as text _col(6) "Set estimate" _col(31) as res %6.5f `slb_pe' _col(39) as res "- " %6.5f `sub_pe'
	if "`ci'"=="im" | "`ci'"=="imnr" di as text _col(6) "`level'% IM Conf. interval" _col(31) as res %6.5f `ci_im_lb' _col(39) as res "- " %6.5f `ci_im_ub'
	if "`ci'"=="nr" | "`ci'"=="imnr" di as text _col(6) "`level'% NR Conf. interval" _col(31) as res %6.5f `ci_nr_lb' _col(39) as res "- " %6.5f `ci_nr_ub'
	di as txt "{hline 70}"	
	if "`ci'"=="im" {
		di as txt "Note: The confidence interval is Imbens and Manski's (2004)"
		di as txt "      confidence interval for a partially-identified parameter"
	}
	if "`ci'"=="nr" {
		di as txt "Note: The confidence interval is Nevo and Rosen's (2012: Sec. IV)"
		di as txt "      confidence interval for a partially-identified parameter"
	}
	if "`ci'"=="imnr" {
		di as txt "Note: The IM and NR confidence intervals are Imbens and Manski's"
		di as txt "      (2004) and Nevo and Rosen's (2012: Sec. IV) confidence"
		di as txt "      intervals for a partially-identified parameter, respectively"
	}
	
	di as txt ""

end
