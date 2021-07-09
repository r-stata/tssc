*! name changed from -ineqdec0- to -ineqdec05-, August 2006
*! This version for versions 5 to 8.1 
*! Use -ineqdec0- with version 8.2 onwards
*! version 1.0.0 Stephen P. Jenkins, April 1998   STB-48 sg104
*! version 1.6 April 2001 (made compatible with Stata 7)
*! Inequality indices and decomposition by population subgroups
*! Stripped-down version of -ineqdeco- which handles zero and
*! negative incomes (and thence output is only Gini and I2)

program define ineqdec05
	version 5.0

	local varlist "req ex max(1)"
	local if "opt"
	local in "opt"
	local options "BYgroup(string) W Summ"
	local weight "aweight fweight"
	parse "`*'"
	parse "`varlist'", parse (" ")
	local inc "`1'"

	tempvar fi totaly py gini wgini im1 i0 i1 i2 /*
         */  nk vk fik meanyk varyk lambdak loglamk lgmeank  /*
         */  thetak i2k  ginik pyk /*
         */  i2bt i2b  wginik /*
         */  with2 touse wi badinc first

	if "`weight'" == "" {ge `wi' = 1}
	else {ge `wi' `exp'}

	mark `touse' `if' `in'
	markout `touse' `varlist' `bygroup'
	lab var `touse' "All obs"
	lab def `touse' 1 " "
	lab val `touse' `touse'
	
	set more 1
	
	quietly {

	count if `inc' < 0 & `touse'
	local ct = _result(1)
	if `ct' > 0 {
		noi di " "
		noi di in blue "Warning: `inc' has `ct' values < 0." _c
		noi di in blue " Used in calculations"
		}
	count if `inc' == 0 & `touse'
	local ct = _result(1)
	if `ct' > 0 {
		noi di " "
		noi di in blue "Warning: `inc' has `ct' values = 0." _c
		noi di in blue " Used in calculations"
		}

	noi di " "
	if "`summ'" ~= "" {
		noi di "Summary statistics for distribution of " _c
		noi di "`inc'" ": all valid cases"
		noi sum `inc' [w = `wi'] if `touse', de
	}
	else {sum `inc' [w = `wi'] if `touse', de }
	local p5  = _result(7)
	local p10 = _result(8)
	local p25 = _result(9)
	local p50 = _result(10)
	local p75 = _result(11)
	local p90 = _result(12)
	local p95 = _result(13)

	if `p95' <= 0 {
		noi di in blue "Note: p95 (and smaller percentiles) <= 0"
		}
	else if `p90' <= 0 {
		noi di in blue "Note: p90 (and smaller percentiles) <= 0"
		}		
	else if `p75' <= 0 {
		noi di in blue "Note: p75 (and smaller percentiles) <= 0"
		}
	else if `p50' <= 0 {
		noi di in blue "Note: p50 (and smaller percentiles) <= 0"
		}
	else if `p25' <= 0 {
		noi di in blue "Note: p25 (and smaller percentiles) <= 0"
		}
	else if `p10' <= 0 {
		noi di in blue "Note: p10 (and smaller percentiles) <= 0"
		}
	else if `p5' <= 0 {
		noi di in blue "Note: p5 (and smaller percentiles) <= 0"
		}

	local sumwi = _result(2)
	local meany = _result(3)
	local vary = _result(4) 
	local sdy = sqrt(`vary') 

	ge `fi' = `wi'/`sumwi' if `touse'

	/* OLD CODE:	sort `touse' `inc' */


	gsort -`touse' `inc'

* 	old code: now fixed to handle fweights properly
*	ge `py' = sum(`wi')/`sumwi' if `touse'
	ge `py' = (2*sum(`wi') - `wi' + 1)/(2 * `sumwi' ) if `touse'

	egen `gini' = sum(`fi'*(2/`meany')*`py'*(`inc'-`meany')) if `touse'


*	ge `i2' = .5*`vary'/`meany'^2 if `touse'
	egen `i2' = sum(`fi'*(((`inc'/`meany')^2)-1)/2) if `touse'

	ge `wgini' = `meany'*(1-`gini') if `touse'

	lab var `gini' "Gini"
	lab var `i2' "GE(2)"

	noi di " "
	noi di  "Percentile ratios for distribution of " "`inc'" _c
	noi di  ": all valid obs."
	noi di in gr _dup(60) "-"
	noi di in gr "p90/p10  p90/p50  p10/p50  p75/p25  p75/p50  p25/p50"
	noi di in gr _dup(60) "-"
	noi di  %7.3f `p90'/`p10' _col(10) %7.3f `p90'/`p50' _c
	noi di _col(3) %7.3f `p10'/`p50' _col(12) %7.3f `p75'/`p25' _c
	noi di _col(3) %7.3f `p75'/`p50' _col(12) %7.3f `p25'/`p50'

	global S_9010 = `p90'/`p10'
	global S_7525 = `p75'/`p25'

	noi di "              "
	noi di "Generalized Entropy index GE(2), and Gini coefficient"
	noi tabdisp `touse' in 1, c(`i2' `gini') f(%9.5f)

	global S_gini = `gini'[1]
	global S_i2 = `i2'[1]

	drop `gini' `i2' 

	if "`w'" ~= "" {

	lab var `wgini' "mean*(1-Gini)"

	noi di  "Sen's welfare index"
	noi tabdisp `touse' in 1, c(`wgini') f(%9.5f)

	}

	*************************
	* SUBGROUP DECOMPOSITIONS
	*************************

	if "`bygroup'" ~= "" {	

		/* OLD CODE: sort `bygroup' `inc' */

	gsort `bygroup' -`touse' `inc'
	by `bygroup': ge `first' = (_n==1)


	egen `nk' = sum(`wi') if `touse', by(`bygroup')
	ge `vk' = `nk'/`sumwi' if `touse'
	ge `fik' = `wi'/`nk' if `touse'
	egen `meanyk' = sum(`fik'*`inc') if `touse', by(`bygroup')
	egen `varyk' = sum(`fik'*(`inc'-`meanyk')^2) /*
		*/	if `touse', by(`bygroup')
	ge `loglamk' = log(`meanyk') if `touse'
	ge `lambdak' = `meanyk' / `meany' if `touse'
	ge `lgmeank' = log(`meanyk') if `touse'
	ge `thetak' = `vk' * `lambdak' if `touse'

*	ge `i2k' = .5*`varyk'/`meanyk'^2 if `touse'
	egen `i2k' = sum(`fik'*(((`inc'/`meanyk')^2)-1)/2) if `touse' /*
		*/ , by(`bygroup')


	noi di "              "
	noi di "Subgroup summary statistics, for each subgroup k = 1,...,K:"

	if "`summ'" ~= "" {
		noi by `bygroup': sum `inc' [w = `wi'] if `touse', de
	}

	sort `bygroup' `inc'
*	by `bygroup' : ge `pyk' = sum(`wi')/`nk'  if `touse'
	by `bygroup': ge `pyk' = (2*sum(`wi') - `wi' + 1)/(2 * `nk' ) /*
		*/ if `touse'

	gsort `bygroup' -`touse' `inc'
	egen `ginik' = sum(`fik'*(2/`meanyk')*`pyk'*(`inc'-`meanyk')) /*
		*/ if `touse', by(`bygroup')




	ge `wginik' = `meanyk'*(1-`ginik') if `touse'

	lab var `vk' "Pop. share"
	lab var `meanyk' "Mean"
	lab var `lambdak' "Rel.mean"
	lab var `thetak' "Income share"
	lab var `lgmeank' "log(mean)"
	lab var `ginik' "Gini"
	lab var `i2k' "GE(2)"
	lab var `wginik' "mean*(1-Gini)"

	noi di "              "
	noi tabdisp `bygroup' if `first' /*
	  */ , c(`vk' `meanyk' `lambdak' `thetak' `lgmeank') f(%9.5f)

	noi di "              "
	noi di "Subgroup indices: GE_k(2) and Gini_k "
	noi tabdisp `bygroup' if `first' /*
	  */ , c(`i2k' `ginik')  f(%9.5f)
	
	drop `lgmeank' `ginik' `thetak' `nk' `pyk' 

	egen `with2' = sum(`fi'*`i2k'*`lambdak'^2) if `touse'

	lab var `with2' "GE(2)"

	noi di "              "
	noi di "Within-group inequality, GE_W(2)"
	noi tabdisp `touse' in 1 if `touse', /*
	  */  c(`with2')  f(%9.5f)

	drop  `i2k' `with2' 

	** GE index between-group inequalities **

	egen `i2bt' = sum(`fi'*(`meanyk'-`meany')^2) if `touse'
	ge `i2b' = .5 * `i2bt' / `meany'^2 if `touse'
	lab var `i2b' "GE(2)"
	noi di "              "
	noi di "Between-group inequality, GE_B(a):"
	noi tabdisp `touse' in 1 if `touse', /*
	  */ c(`i2b')  f(%9.5f)

	drop `i2b' `i2bt'

	if "`w'" ~= "" {

	noi di "              "
	noi di "Subgroup welfare indices:Sen's index"
	noi tabdisp `bygroup' if `first' /*
	  */ , c(`wginik')  f(%9.5f)

	}

	drop `wginik' `fi'
	}

}


end
