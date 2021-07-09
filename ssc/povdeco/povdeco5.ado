*! name changed from -povdeco- to -povdeco5-, August 2006
*! This version for versions 5 to 8.1 
*! Use -povdeco- with version 8.2 onwards
*! version 1.1 Stephen P. Jenkins, April 1998   STB-48 sg104
*! version 1.3 Feb 2001 (made compatible with Stata 7)
*! Poverty indices and decomposition by population subgroups
*! Syntax: povdeco <var> [[w=weight] if <exp> in <range>], 
*! 			[by(<gpvar>)] pl(z) varpl(zvar)

program define povdeco5
	version 5.0

	local varlist "req ex max(1)"
	local if "opt"
	local in "opt"
	local options "BYgroup(string) PLine(real 0) Varpl(string)"
	local weight "aweight fweight"
	parse "`*'"
	parse "`varlist'", parse (" ")
	local inc "`1'"

	if "`pline'" == "" | "`pline'" == "0"  {
		capture confirm variable `varpl'
		if _rc ~= 0 {
			di in r "Poverty line syntax incorrect"
			exit 198
		}
	}
	
	if "`varpl'" == ""  {
		capture confirm number `pline'
		if _rc ~= 0 {exit 198}
		if `pline' <= 0  {
			di in r "Poverty line is <= 0"
			exit 198
		}
	}


	tempvar wi touse fi poor fgt0 fgt1 fgt2 badinc /*
         */ nk vk fik meanyk mnypk mngapk fgt0k fgt1k fgt2k /*
         */  share0k share1k share2k risk0k risk1k risk2k /*
	 */ z meangap first

	if "`weight'" == "" {ge `wi' = 1}
	else {ge `wi' `exp'}

	mark `touse' `if' `in'
	markout `touse' `varlist' `bygroup' `varpl'
	lab var `touse' "All obs"
	lab def `touse' 1 " "
	lab val `touse' `touse'
	
	set more 1
	
	quietly {
	
	if "`pline'" ~= "" & "`varpl'" =="" {
		ge `z' = `pline'
		compress
	}
	
	if "`varpl'" ~= "" & "`pline'" == "0" {
		ge `z' = `varpl'
		compress
	}

	count if `z' <= 0 & `touse'
	local ct = _result(1)
	if `ct' > 0 {
		noi di " "
		noi di in b "Warning: Poverty line < 0 for `ct' obs." 
	}
	
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

	/* reinstate this bit if want to exclude 
	obs with `inc' <=0 from calculations */

	/*	ge `badinc' = 0
	replace `badinc' =. if `inc' <= 0
	markout `touse'  `badinc'
	*/

	sum `inc' [w=`wi'] if `touse'
	local sumwi = _result(2)
	local meany = _result(3)
	ge `fi' = `wi'/`sumwi' if `touse'
	noi di " "

	noi di in gr "Total number of observations = " in ye  _result(1)
	noi di in gr "Weighted total no. of observations = " in ye _result(2)

	gsort -`touse' `inc'    /* new here (moved from below; cosmetic) */

	ge `poor' = `inc' < `z' if `touse'
	sum `inc' [w=`wi'] if `touse' & `poor'
	noi di in gr "Number of observations poor = " in ye  _result(1)
	noi di in gr "Weighted no. of obs poor = " in ye _result(2)
	local meanyp = _result(3)
	noi di in gr "Mean of `inc' amongst the poor = " _c
	noi di in gr  in ye %9.3f `meanyp' 
	egen `fgt0' = sum(`fi'*`poor') if `touse'
	egen `fgt1' = sum(`fi'*`poor'*(`z'-`inc')/`z') /*
		*/ if `touse'
	egen `fgt2' = sum(`fi'*`poor'*((`z'-`inc')/`z')^2 ) /*
		*/ if `touse'

	/*	gsort -`touse' */

	ge `meangap' = `z' - `inc'  if `touse' & `poor'
	su `meangap' [w=`wi']
	noi di in gr "Mean of poverty gaps (poverty line - `inc') amongst " _c
	noi di in gr "the poor = " in ye %9.3f  _result(3)

	lab var `z' "Poverty line"
	lab var `fgt0' "a=0"
	lab var `fgt1' "a=1"
	lab var `fgt2' "a=2"
	noi di " "
	noi di "Foster-Greer-Thorbecke poverty indices, FGT(a)"
	noi tabdisp `touse' in 1 if `touse', /*
		*/ c(`fgt0' `fgt1' `fgt2') f(%9.5f)
	noi di in gr "FGT(0): headcount ratio (proportion poor)"
	noi di in gr "FGT(1): average normalised poverty gap"
	noi di in gr "FGT(2): average squared normalised poverty gap"

	global S_FGT0 = `fgt0'[1]
	global S_FGT1 = `fgt1'[1]
	global S_FGT2 = `fgt2'[1]

	*************************
	* SUBGROUP DECOMPOSITIONS
	*************************

	if "`bygroup'" ~= "" {	


	/*  sort `bygroup' `inc' */

	gsort `bygroup' -`touse' `inc'    /* new  */
	by `bygroup': ge `first' = (_n==1)

	egen `nk' = sum(`wi') if `touse', by(`bygroup')
	ge `vk' = `nk'/`sumwi' if `touse'
	ge `fik' = `wi'/`nk' if `touse'
	egen `fgt0k' = sum(`fik'*`poor') if `touse', by(`bygroup')
	egen `fgt1k' = sum(`fik'*`poor'*(`z'-`inc')/`z') /*
		*/ if `touse', by(`bygroup')
	egen `fgt2k' = sum(`fik'*`poor'*((`z'-`inc')/`z')^2) /*
		*/ if `touse', by(`bygroup')
	egen `meanyk' = sum(`fik'*`inc') if `touse', by(`bygroup')
	egen `mnypk' = sum( (`fik'*`poor'*`inc')/`fgt0k' ) /*
	  	*/ if `touse', by(`bygroup')
	egen `mngapk' = sum( (`fik'*(`z'-`inc')*`poor')/`fgt0k' )  /*
		*/  if `touse', by(`bygroup')


	lab var `fgt0k' "a=0"
	lab var `fgt1k' "a=1"
	lab var `fgt2k' "a=2"
	lab var `vk' "Pop. share"
	lab var `meanyk' "Mean"
	lab var `mnypk' "Mean|poor"
	lab var `mngapk' "Mean gap|poor"


	noi di "              "
	noi di "Decompositions by subgroup"
	noi di "--------------------------"
	noi di " "
	noi di "Summary statistics for subgroup k = 1,...,K"
	noi tabdisp `bygroup' if `first' /*
		*/ , c(`vk' `meanyk' `mnypk' `mngapk') f(%9.5f)


	noi di "              "
	noi di "Subgroup FGT index estimates, FGT(a)"
	noi tabdisp `bygroup' if `first' /*
		*/ , c(`fgt0k' `fgt1k' `fgt2k') f(%9.5f)


	drop `nk' `meanyk' `mnypk' `mngapk'

	* NB. FGTk(0) = (#poor in k)/(total # people in k); i.e. 'risk'
	* NB. Sk(0) = (#poor in k)/(total #poor); i.e. 'composition'

	ge `share0k' = `vk' * `fgt0k' / `fgt0' if `touse'
	ge `share1k' = `vk' * `fgt1k' / `fgt1' if `touse'
	ge `share2k' = `vk' * `fgt2k' / `fgt2' if `touse'
	lab var `share0k' "a=0"
	lab var `share1k' "a=1"
	lab var `share2k' "a=2"


	noi di "              "
	noi di "Subgroup poverty 'share', S_k = v_k.FGT_k(a)/FGT(a)"
	noi tabdisp `bygroup' if `first' /*
		*/ , c(`share0k' `share1k' `share2k') f(%9.5f)


	drop `share0k' `share1k' `share2k' `vk'

	ge `risk0k' = `fgt0k' / `fgt0' if `touse'
	ge `risk1k' = `fgt1k' / `fgt1' if `touse'
	ge `risk2k' = `fgt2k' / `fgt2' if `touse'
	lab var `risk0k' "a=0"
	lab var `risk1k' "a=1"
	lab var `risk2k' "a=2"

	noi di "              "
	noi di "Subgroup poverty 'risk' = FGT_k(a)/FGT(a) = S_k/v_k"
	noi tabdisp `bygroup' if `first' /*
		*/ , c(`risk0k' `risk1k' `risk2k') f(%9.5f)

	drop `risk0k' `risk1k' `risk2k' 
	drop  `fgt0k' `fgt1k' `fgt2k' `fgt0' `fgt1' `fgt2' 

		}  /* end of subgroup decompositions */

	}

end
