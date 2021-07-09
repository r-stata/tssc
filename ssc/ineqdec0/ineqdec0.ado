*! 2.0.2 SPJ May 2008 (fix bug arising if bygroup() and `touse' lead to no obs in a group)
*!   bug fix method provided by Austin Nichols (many thanks!)
*! 2.0.1 SPJ August 2006 (new vbles created as doubles)
*! 2.0.0 SPJ August 2006 (port to Stata 8.2; additional saved results), 
*!   with initial code rewriting contribution from Nick Cox (many thanks!)
*! version 1.6 April 2001 (made compatible with Stata 7; SSC)
*! version 1.0.1 Stephen P. Jenkins, April 1998   STB-48 sg104
*! Inequality indices, with optional decomposition by population subgroups

program ineqdec0, sortpreserve rclass 

version 8.2 
syntax varname(numeric) [aweight fweight] [if] [in] ///
	[, BYgroup(varname numeric) Welfare Summarize ]

if "`summarize'" != "" local summ "summ" 
if "`welfare'" != ""    local w "w" 
local inc "`varlist'"

tempvar fi totaly py gini wgini i2 i2b     	///
  nk vk fik meanyk varyk lambdak loglamk lgmeank ///
  thetak i2k  ginik pyk  wginik with2 ///
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

	//	Following exclusion not used in this program
	//	replace `touse' = 0 if `inc' <= 0  // this replaces former 'badinc' stuff

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

	egen double `gini' = sum(`fi'*(2 / `meany') * `py' * (`inc' - `meany')) if `touse'

	egen double `i2' = sum(`fi' * (((`inc' / `meany')^2) - 1) / 2) if `touse'

	gen double `wgini' = `meany' * (1 - `gini') if `touse'

	lab var `gini' "Gini"
	lab var `i2' "GE(2)"

	tempvar v9010 v9050 v1050 v7525
	gen `v9010' = `p90'/`p10' in 1
	gen `v9050' = `p90'/`p50' in 1
	gen `v1050' = `p10'/`p50' in 1
	gen `v7525' = `p75'/`p25' in 1
	lab var `v9010' "p90/p10"
	lab var `v9050' "p90/p50"
	lab var `v1050' "p10/p50"
	lab var `v7525' "p75/p25"


	noi { 
		di " "
		di as txt "Percentile ratios" 
		tabdisp `touse' in 1, c(`v9010' `v9050' `v1050' `v7525') f(%9.3f)

		global S_9010 = `p90'/`p10'
		global S_7525 = `p75'/`p25'
		return scalar p90p10 = `p90'/`p10' 
		return scalar p75p25 = `p75'/`p25' 
		return scalar p90p50 = `p90'/`p50'
 		return scalar p10p50 = `p10'/`p50'
		return scalar p25p50 = `p25'/`p50' 
		return scalar p75p50 = `p75'/`p50' 

		di "  "
		di as txt "Generalized Entropy index GE(2), and Gini coefficient"
		tabdisp `touse' in 1, c(`i2' `gini') f(%9.5f)
	}	

	// saved results compatible with previous versions of -ineqdeco-
	global S_gini = `gini'[1]
	global S_i2 = `i2'[1]

	return scalar gini = `gini'[1] 
	return scalar ge2 = `i2'[1] 
		
	drop `gini' `im1' `i0' `i1' `i2' 


	if "`w'" == "w" {

		lab var `wgini' "mean*(1-Gini)"
		noi di "Sen's welfare index"
		noi tabdisp `touse' in 1, c(`wgini') f(%15.5f)
	}	

	return scalar wgini = `wgini'[1]

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
	by `notuse' `bygroup': egen  double `varyk' = sum(`fik'* (`inc' - `meanyk')^2) if `touse'
	gen double `loglamk' = log(`meanyk') if `touse'
	gen double `lambdak' = `meanyk' / `meany' if `touse'
	gen double `lgmeank' = log(`meanyk') if `touse'
	gen double `thetak' = `vk' * `lambdak' if `touse'

	by `notuse' `bygroup': egen double `i2k' = sum(`fik' * (((`inc' / `meanyk')^2) - 1) / 2) if `touse'


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

	gen double `wginik' = `meanyk' * (1 - `ginik') if `touse'

	lab var `vk' "Popn. share"
	lab var `meanyk' "Mean"
	lab var `lambdak' "Relative mean"
	lab var `thetak' "Income share"
	lab var `lgmeank' "log(mean)"
	lab var `ginik' "Gini"
	lab var `i2k' "GE(2)"
	lab var `wginik' "mean*(1-Gini)"


	noi { 
		di "  "
		tabdisp `bygroup' if `first' , c(`vk' `meanyk' `lambdak' `thetak' `lgmeank') f(%15.5f)

		di "  "
		di as txt "Subgroup indices: GE_2(a) and Gini_k "
		tabdisp `bygroup' if `first' , c(`i2k' `ginik')  f(%9.5f)
	}

	
	capture levelsof `bygroup' if `touse' , local(group)
	qui if _rc levels `bygroup' if `touse' , local(group)

	return local levels "`group'"
	
	gsort -`first' `bygroup'
	local i = 1
	foreach k of local group	{

		return scalar ge2_`k' = `i2k'[`i']
		return scalar gini_`k' = `ginik'[`i']

		return scalar mean_`k' = `meanyk'[`i']
		return scalar lgmean_`k' = `lgmeank'[`i']
		return scalar theta_`k' = `thetak'[`i']
		return scalar lambda_`k' = `lambdak'[`i']
		return scalar v_`k' = `vk'[`i']
		return scalar sumw_`k' = `nk'[`i']

		local ++i
	}

	drop `lgmeank' `ginik' `thetak' `nk' `pyk' 

	egen double `with2' = sum(`fi' * `i2k' * `lambdak'^2) if `touse'
	lab var `with2' "GE(2)"

	noi { 
		di "  "
		di as txt "Within-group inequality, GE_W(a)"
		tabdisp `touse' in 1 if `touse', c(`with2')  f(%9.5f)
	}	

	return scalar within_ge2 = `with2'[1]

	drop `i2k' `with2' 

	** GE index between-group inequalities **

	egen double `i2b' = sum(`fi' * (((`meanyk' / `meany')^2) - 1) / 2) if `touse'
	lab var `i2b' "GE(2)"

	noi { 
		di "  "
		di as txt "Between-group inequality, GE_B(a):"
		tabdisp `touse' in 1 if `touse' , c(`i2b')  f(%9.5f)
	}	

	return scalar between_ge2 = `i2b'[1]

	drop `i2b' 


	// results for Sen welfare index if requested 

	if "`w'" == "w" {
		noi { 
			di "  "
			di as txt "Subgroup welfare index: Sen's index"
			tabdisp `bygroup' if `first' , c(`wginik')  f(%15.5f)
		}  

		gsort -`first' `bygroup'
		local i = 1
		foreach k of local group	{
			return scalar wgini_`k' = `wginik'[`i']
			local ++i 
		}

	}

	drop `wginik' `fi'

}	// end of  "`bygroup'"  block for subgroup decompositions


}	// end quietly block


end
