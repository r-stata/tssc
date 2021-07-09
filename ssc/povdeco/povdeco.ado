*! 2.0.2 SPJ January 2008 (typo in a saved result fixed -- thanks John Haisken-DeN)
*! 2.0.1 SPJ August 2006 (new vbles created as doubles)
*! 2.0.0 SPJ August 2006 (port to Stata 8.2; additional saved results)
*! version 1.1 Stephen P. Jenkins, April 1998   STB-48 sg104
*! version 1.3 Feb 2001 (made compatible with Stata 7)
*! Poverty indices and decomposition by population subgroups

program define povdeco, rclass sortpreserve
	version 8.2

	syntax varname(numeric) [aweight fweight] [if] [in] ///
		[, BYgroup(varname numeric)  PLine(real 0) Varpline(string) ///
		   Summarize  ]

	local inc "`varlist'"

	if "`pline'" == "" | "`pline'" == "0"  {
		capture confirm variable `varpline'
		if _rc ~= 0 {
			di as error "Poverty line syntax incorrect"
			exit 198
		}
	}
	
	if "`varpline'" == ""  {
		capture confirm number `pline'
		if _rc ~= 0 exit 198
		if `pline' <= 0  {
			di as error "Poverty line is <= 0"
			exit 198
		}
	}


	tempvar wi touse fi poor fgt0 fgt1 fgt2 badinc ///
           nk vk fik meanyk mnypk mngapk fgt0k fgt1k fgt2k ///
           share0k share1k share2k risk0k risk1k risk2k ///
	   gap meangap first z

	if "`weight'" == "" ge `wi' = 1
	else ge `wi' `exp'

	marksample touse 
	if "`bygroup'" != "" markout `touse' `bygroup'
	if "`varpline'" != "" markout `touse' `varpline'

        qui count if `touse'
        if r(N) == 0  error 2000

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
	
	if "`pline'" != "" & "`varpline'" =="" {
		ge `z' = `pline'
		compress
	}
	
	if "`varpline'" != "" & "`pline'" == "0" {
		ge `z' = `varpline'
		compress
	}

	count if `z' <= 0 & `touse'
	noi if r(N) > 0 {
		noi di " "
		noi di as txt "Warning: Poverty line < 0 for `r(N)' obs." 
	}
	
	count if `inc' < 0 & `touse'
	noi if r(N) > 0 {
		noi di " "
		noi di as txt "Warning: `inc' has `r(N)' values < 0." _c
		noi di as txt " Used in calculations"
	}
	count if `inc' == 0 & `touse'
	noi if r(N) > 0 {
		noi di " "
		noi di as txt "Warning: `inc' has `r(N)' values = 0." _c
		noi di as txt " Used in calculations"
	}

	// Reinstate following if you wish to drop obs with inc <= 0
*	replace `touse' = 0 if `inc' <= 0  

	sum `inc' [w=`wi'] if `touse'
	local sumwi = r(sum_w)
	local mny = r(mean)

	return scalar mean = r(mean)
	return scalar sumw = r(sum_w)
	return scalar N = r(N)


	ge double `fi' = `wi' / `sumwi' if `touse'

	gsort -`touse' `inc'    

	ge byte `poor' = `inc' < `z' if `touse'
	sum `inc' [w=`wi'] if `touse' & `poor'
	local mnyp = r(mean)

	return scalar npoor = `r(N)'
	return scalar wgtednpoor = `r(sum_w)'
	return scalar meanpoor = `mnyp'

	ge double `gap' = `z' - `inc'  if `touse' & `poor'
	su `gap' [w=`wi']
	local mngap = r(mean)
	return scalar meangappoor = r(mean)

	egen double `fgt0' = sum(`fi'*`poor') if `touse'
	egen double `fgt1' = sum(`fi'*`poor'*(`z'-`inc')/`z') ///
		if `touse'
	egen double `fgt2' = sum(`fi'*`poor'*((`z'-`inc')/`z')^2 ) ///
		 if `touse'

	tempvar meany meanyp meangap
	gen double `meany' = `mny' in 1
	gen double `meanyp' = `mnyp' in 1
	gen double `meangap' = `mngap' in 1
	lab var `meany' "Mean"
	lab var `meanyp' "Mean|poor"
	lab var `meangap' "Mean gap|poor"

	if "`summarize'" != "" {
		noi {
			di " "
			di as txt "Summary statistics for `inc'"
			tabdisp `touse' in 1 if `touse', ///
				c(`meany' `meanyp' `meangap') f(%20.5f)
		}
	}

	lab var `z' "Poverty line"
	lab var `fgt0' "a=0"
	lab var `fgt1' "a=1"
	lab var `fgt2' "a=2"
	noi {
		di " "
		di as txt "Foster-Greer-Thorbecke poverty indices, FGT(a)"
		tabdisp `touse' in 1 if `touse', ///
			c(`fgt0' `fgt1' `fgt2') f(%9.5f)
		di as txt "FGT(0): headcount ratio (proportion poor)"
		di as txt "FGT(1): average normalised poverty gap"
		di as txt "FGT(2): average squared normalised poverty gap"

	}
	
	global S_FGT0 = `fgt0'[1]
	global S_FGT1 = `fgt1'[1]
	global S_FGT2 = `fgt2'[1]

	return scalar fgt0 = `fgt0'[1]
	return scalar fgt1 = `fgt1'[1]
	return scalar fgt2 = `fgt2'[1]


	*************************
	* SUBGROUP DECOMPOSITIONS
	*************************

	if "`bygroup'" ~= "" {	

		gsort `bygroup' -`touse' `inc'    /* new  */
		by `bygroup': ge byte `first' = (_n==1)

		by `bygroup': egen double `nk' = sum(`wi') if `touse'
		ge double `vk' = `nk'/`sumwi' if `touse'
		ge double `fik' = `wi'/`nk' if `touse'

		by `bygroup': egen double `fgt0k' = sum(`fik'*`poor') if `touse'
		by `bygroup': egen double `fgt1k' = sum(`fik'*`poor'*(`z'-`inc')/`z') ///		
			if `touse'
		by `bygroup': egen double `fgt2k' = sum(`fik'*`poor'*((`z'-`inc')/`z')^2) ///
			if `touse'
		by `bygroup': egen double `meanyk' = sum(`fik'*`inc') if `touse'
		by `bygroup': egen double `mnypk' = sum( (`fik'*`poor'*`inc')/`fgt0k' ) ///
		  	if `touse'
		by `bygroup': egen double `mngapk' = sum( (`fik'*(`z'-`inc')*`poor')/`fgt0k' )  ///
			if `touse'


		lab var `fgt0k' "a=0"
		lab var `fgt1k' "a=1"
		lab var `fgt2k' "a=2"
		lab var `vk' "Pop. share"
		lab var `meanyk' "Mean"
		lab var `mnypk' "Mean|poor"
		lab var `mngapk' "Mean gap|poor"

		noi {
			di " "
			di "Decompositions by subgroup"
			di " "
			di "Summary statistics for subgroup k = 1,...,K"
			tabdisp `bygroup' if `first' ///
				, c(`vk' `meanyk' `mnypk' `mngapk') f(%15.5f)
			di " "
			di "Subgroup FGT index estimates, FGT(a)"
			tabdisp `bygroup' if `first' ///
				, c(`fgt0k' `fgt1k' `fgt2k') f(%9.5f)
		}


		* NB. FGTk(0) = (#poor in k)/(total # people in k); i.e. 'risk'
		* NB. Sk(0) = (#poor in k)/(total #poor); i.e. 'composition'

		ge double `share0k' = `vk' * `fgt0k' / `fgt0' if `touse'
		ge double `share1k' = `vk' * `fgt1k' / `fgt1' if `touse'
		ge double `share2k' = `vk' * `fgt2k' / `fgt2' if `touse'
		lab var `share0k' "a=0"
		lab var `share1k' "a=1"
		lab var `share2k' "a=2"

		noi {
			di " "
			di "Subgroup poverty 'share', S_k = v_k.FGT_k(a)/FGT(a)"
			tabdisp `bygroup' if `first' ///
			    , c(`share0k' `share1k' `share2k') f(%9.5f)
		}

		ge double `risk0k' = `fgt0k' / `fgt0' if `touse'
		ge double `risk1k' = `fgt1k' / `fgt1' if `touse'
		ge double `risk2k' = `fgt2k' / `fgt2' if `touse'
		lab var `risk0k' "a=0"
		lab var `risk1k' "a=1"
		lab var `risk2k' "a=2"

		noi {
			di " "
			di "Subgroup poverty 'risk' = FGT_k(a)/FGT(a) = S_k/v_k"
			tabdisp `bygroup' if `first' ///
				, c(`risk0k' `risk1k' `risk2k') f(%9.5f)
		}


		capture levelsof `bygroup' if `touse' , local(group)
		qui if _rc levels `bygroup' if `touse' , local(group)

		return local levels "`group'"
		
		gsort -`first' `bygroup'
		local i = 1
		foreach k of local group	{
			return scalar risk0_`k' = `risk0k'[`i']
			return scalar risk1_`k' = `risk1k'[`i']
			return scalar risk2_`k' = `risk2k'[`i']

			return scalar share0_`k' = `share0k'[`i']
			return scalar share1_`k' = `share1k'[`i']
			return scalar share2_`k' = `share2k'[`i']

			return scalar fgt0_`k' = `fgt0k'[`i']
			return scalar fgt1_`k' = `fgt1k'[`i']
			return scalar fgt2_`k' = `fgt2k'[`i']

			return scalar n_`k' = `nk'[`i']
			return scalar mean_`k' = `meanyk'[`i']
			return scalar meanpoor_`k' = `mnypk'[`i']
			return scalar meangappoor_`k' = `mngapk'[`i']

			return scalar v_`k' = `vk'[`i']
			return scalar sumw_`k' = `nk'[`i']
			local ++i
		}


	}  /* end of subgroup decompositions */

}

end
