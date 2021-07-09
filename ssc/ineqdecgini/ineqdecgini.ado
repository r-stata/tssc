*! version 1.0.0 Stephen P. Jenkins, August 2019
*! Gini index of inequality, with optional decomposition by population subgroups
*!   G_total = Gini_within_groups  +  Gini_between_groups  +  Residual, where
*!     Gini_within_groups = weighted sum of G within each group, 
*!	 with group-weight = income share * population share;
*!     Gini_between_groups = G arising if each obs attributed income = mean of group, and
*!     Residual is a term related to subgroup overlaps along income range 

program ineqdecgini, sortpreserve rclass 

version 8.2 
syntax varname(numeric) [aweight fweight iweight pweight] [if] [in] ///
	[, BYgroup(varname numeric) Summarize ]

if "`summarize'" != "" local summ "summ" 
local inc "`varlist'"

tempvar fi totaly py gini  ///
  nk vk fik meanyk lambdak ///
  thetak i2k  ginik pyk    ///
  wi first  
  

if "`weight'" == "" gen byte `wi' = 1
else gen `wi' `exp'

marksample touse
if "`bygroup'" != ""  markout `touse' `bygroup'

qui count if `touse'
if r(N) == 0 error 2000
	
lab var `touse' "All obs"
lab def `touse' 1 " "
lab val `touse' `touse'

if "`bygroup'" != "" {
	capture levelsof `bygroup' if `touse' , local(gp)
	qui if _rc levels `bygroup' if `touse' , local(gp)
	foreach x of local gp {
		if int(`x') != `x' | (`x' < 0) { 
			di as error "`bygroup' contains non-integer or negative values"
			exit 459
		}
	}
}

set more off
	
quietly {

	count if `inc' < 0 & `touse'
	noi if r(N) > 0 {
		di " "
		di as txt "Warning: `inc' has `r(N)' values < 0." _c
		di as txt " Used in calculations"
	}
	
	count if `inc' == 0 & `touse'
	noi if r(N) > 0 {
		di " "
		di as txt "Warning: `inc' has `r(N)' values = 0." _c
		di as txt " Used in calculations"
	}

	noi if "`summ'" != "" {
		di " "
		di as txt "Summary statistics for distribution of " _c
		di as txt "`inc'" ": all valid cases"
		sum `inc' [w = `wi'] if `touse', de
	}
	else  sum `inc' [w = `wi'] if `touse', de

	foreach P in 5 10 25 50 75 90 95 { 
		local p`P'  = r(p`P')
	}	
	
	if `p95' <= 0 {
		noi di as txt "Note: p95 (and smaller percentiles) <= 0"
		}
	else if `p90' <= 0 {
		noi di as txt "Note: p90 (and smaller percentiles) <= 0"
		}		
	else if `p75' <= 0 {
		noi di as txt "Note: p75 (and smaller percentiles) <= 0"
		}
	else if `p50' <= 0 {
		noi di as txt "Note: p50 (and smaller percentiles) <= 0"
		}
	else if `p25' <= 0 {
		noi di as txt "Note: p25 (and smaller percentiles) <= 0"
		}
	else if `p10' <= 0 {
		noi di as txt "Note: p10 (and smaller percentiles) <= 0"
		}
	else if `p5' <= 0 {
		noi di as txt "Note: p5 (and smaller percentiles) <= 0"
		}


	local sumwi = r(sum_w)
	local meany = r(mean)
	local vary = r(Var) 
	local sdy = r(sd)

	return scalar mean = r(mean)
	return scalar Var = r(Var)
	return scalar sd = r(sd)
	return scalar sumw = r(sum_w)
	return scalar N = r(N)
	return scalar min = r(min)
	return scalar max = r(max)

	foreach p in 5 10 25 50 75 90 95 {
		return scalar p`p' = r(p`p')
	}
	gen double `fi' = `wi' / `sumwi' if `touse'

	gsort -`touse' `inc' 

	gen double `py' = (2 * sum(`wi') - `wi' + 1)/(2 * `sumwi' ) if `touse'

	egen double `gini' = total(`fi'*(2 / `meany') * `py' * (`inc' - `meany')) if `touse'

	lab var `gini' "Gini"
	

	return scalar gini = `gini'[1] 

	noi { 
		di "  "
		di as txt "Gini for `inc'"
		tabdisp `touse' in 1, c(`gini') f(%9.5f)

	}
		

*************************
* SUBGROUP DECOMPOSITIONS
*************************

if "`bygroup'" != "" {	


	tempvar notuse
	gen byte `notuse' = -`touse'
	sort `notuse' `bygroup' `inc'

	by `notuse' `bygroup': gen byte `first' = _n == 1 if `touse'
	by `notuse' `bygroup': egen `nk' = sum(`wi') if `touse'

	gen double `vk' = `nk' / `sumwi' if `touse'
  	gen double `fik' = `wi' / `nk' if `touse'
	by `notuse' `bygroup': egen  double `meanyk' = sum(`fik' * `inc') if `touse'
	gen double `lambdak' = `meanyk' / `meany' if `touse'
	gen double `thetak' = `vk' * `lambdak' if `touse'

	noi { 
		di "  "
		di as txt "Subgroup summary statistics, for each subgroup k = 1,...,K:"
		if "`summ'" != "" {
			bys `bygroup': sum `inc' [w = `wi'] if `touse', de
		}
	}	


	bysort `notuse' `bygroup' (`inc'): gen double `pyk' = (2 * sum(`wi') - `wi' + 1) / (2 * `nk' ) ///
		if `touse'

	by `notuse' `bygroup': egen double `ginik' = sum(`fik' * (2 / `meanyk') * `pyk' * (`inc' - `meanyk')) ///
		if `touse'

	lab var `vk' "Popn. share"
	lab var `meanyk' "Mean"
	lab var `lambdak' "Relative mean"
	lab var `thetak' "Income share"
	lab var `ginik' "Gini"


	noi { 
		di "  "
		tabdisp `bygroup' if `first' , c(`vk' `meanyk' `lambdak' `thetak' `ginik') f(%15.5f)

	}

	
	capture levelsof `bygroup' if `touse' , local(group)
	qui if _rc levels `bygroup' if `touse' , local(group)

	return local levels "`group'"
	
	
	tempvar incb  // attribute each obs with mean income of obs's group
	ge `incb' = .

	local GiniW = 0

	gsort -`first' `bygroup'
	local i = 1
	foreach k of local group	{

		return scalar gini_`k' = `ginik'[`i']

		return scalar mean_`k' = `meanyk'[`i']
		return scalar theta_`k' = `thetak'[`i']
		return scalar lambda_`k' = `lambdak'[`i']
		return scalar v_`k' = `vk'[`i']
		return scalar sumw_`k' = `nk'[`i']

		replace `incb' = `meanyk'[`i'] if `bygroup' == `k'

		local GiniW = `GiniW' +  (  `vk'[`i'] * `thetak'[`i'] * `ginik'[`i']  )

		local ++i
	}

	tempvar pyb giniB giniW R

	gsort -`touse' `incb' 

	gen double `pyb' = (2 * sum(`wi') - `wi' + 1)/(2 * `sumwi' ) if `touse'

	egen double `giniB' = sum(`fi'*(2 / `meany') * `pyb' * (`incb' - `meany')) if `touse'
	lab var `giniB' "Gini_between"

	ge double `giniW' = `GiniW' in 1
	label var `giniW' "Gini_within"

	ge double `R' = `gini' - `giniW' - `giniB' in 1
	label var `R' "Residual"

	return scalar gini_w = `giniW'[1]
	return scalar gini_b = `giniB'[1]
	return scalar residual = `R'[1]

	// As percentages of total

	tempvar ginip giniWp giniBp Rp

	ge double `ginip' = 100  in 1
	label var `ginip' "Gini"

	ge double `giniWp' = 100 * `giniW' / `gini' in 1
	label var `giniWp' "Gini_within"

	ge double `giniBp' = 100 * `giniB' / `gini' in 1
	label var `giniBp' "Gini_between"

	ge double `Rp' = `ginip' - `giniWp' - `giniBp' in 1
	label var `Rp' "Residual"

	return scalar gini_w_pc = `giniWp'[1]
	return scalar gini_b_pc = `giniBp'[1]
	return scalar residual_pc = `Rp'[1]



	noi { 
		di "  "
		di as txt "Decomposition: Gini = Gini_within + Gini_between + Residual"
		tabdisp `touse' in 1, c(`gini' `giniW' `giniB' `R') f(%9.5f)
		di "  "
		di as txt "Decomposition (% of total): Gini = Gini_within + Gini_between + Residual"
		tabdisp `touse' in 1, c(`ginip' `giniWp' `giniBp' `Rp') f(%9.5f)
		di as txt "Note: Gini_within = weighted sum across groups of subgroup Ginis, " 
		di as txt " with each subgroup's weight equal to the product of its income share and population share."
		di as txt " Gini_between = Gini calculated attributing each obs with the mean of the obs's subgroup."
	}



}	// end of  "`bygroup'"  block for subgroup decompositions


}	// end quietly block


end
