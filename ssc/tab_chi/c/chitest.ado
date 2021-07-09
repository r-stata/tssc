*! 2.0.1 NJC 10 March 2004 
*! 2.0.0 NJC 10 July 2003 
program chitest, sort rclass 
	version 8
	syntax varlist(min=1 max=2) [if] [in] [, nfit(int 0) kb count /// 
	ABbreviate(int 9) NOObs SUBVARname * ]

	// ignore subvarname noobs (default) 
	// kb is undocumented: it's -chitesti-'s secret handshake 
	
	tokenize `varlist'
	local nvars : word count `varlist'

	tempvar obs exp lrchi2 res Pearson Pearson2 
	marksample touse, strok 

	quietly { 
		// observed frequencies 
		if "`count'" != "" { 
			if `nvars' == 2 { 
				di as err "{p}count option not valid " /// 
				"with two variables: consider "        ///
				as cmd "tabulate" 
				exit 198 
			} 
			local counted "`varlist'" 	
			local link "of" 
			bysort `touse' `varlist': ///
				gen double `obs' = _N * (_n == 1) if `touse' 
			replace `touse' = 0 if `obs' == 0 
		} 	
		else { 
			gen double `obs' = `1' if `touse' 
			local link "from" 
		} 	

		// degrees of freedom (subtract `nfit')
		count if `touse'
		local df = r(N) - 1 - `nfit'
		if `df' < 1 {
			di as err "too few categories"
			exit 149
		}
		
		// check observed frequencies
		capture assert `obs' == int(`obs') if `touse'
		if _rc == 9 {
			di as err "observed frequencies must be integers"
			exit 499
		}

		su `obs' if `touse', meanonly
		local omean = r(mean)
		local osum = r(sum)
		local omin = r(min)

		if `omin' < 0 {
			di as err 
			/// "observed frequencies must be zero or positive"
			exit 499
		}

		// expected frequencies 
		if `nvars' == 2 gen double `exp' = `2'
		else gen double `exp' = `omean' 
		
		// check expected frequencies
		su `exp' if `touse', meanonly
		local emean = r(mean)
		local esum =  r(sum)
		local emin =  r(min)

		if `emin' <= 0 {
			di as err "expected frequencies must be positive"
			exit 411
		}

		// got to here => we're in business
		tempname chi2 p chi2_lr p_lr
		char `obs'[varname] "observed"
		char `exp'[varname] "expected"

		// count cells with < 5 & < 1
		local lowexp = `emin' < 5
		count if `touse' & `exp' >= 1 & `exp' < 5
		local lt5 = r(N)
		count if `touse' & `exp' < 1
		local lt1 = r(N)
	} 	

	// print header
	if `nvars' == 2 { 
		di _n as txt ///
		"{p}observed frequencies from "                  /// 
        	cond("`kb'" == "kb", "keyboard", "`1'") "; "     ///
		"expected frequencies from"                      ///
		cond("`kb'" == "kb", " keyboard", " `2'") "{p_end}" 
	}
	else { 
		di _n as txt ///
		"{p}observed frequencies "                      ///
		cond("`count'" != "", "of ", "from ")            /// 
        	cond("`kb'" == "kb", "keyboard", "`1'") "; "     ///
		"expected frequencies equal{p_end}" 
	} 	

	// warn if totals differ by more than 0.01
	if `nvars' == 2 & abs(`osum'-`esum') > 0.01 {
		di _n as err "Warning: totals of `1' and `2' differ"
		di as err _col(15) "total"
		di as err "`1'" _col(12) %8.0g `osum'
		di as err "`2'" _col(12) %8.0g `esum'
	}
	
	// prepare notes if `emin' < 5
	quietly if `lowexp' {
		tempvar notes 
		gen `notes' = ""
		char `notes'[varname] "notes" 
		replace `notes' = "*" if `exp' < 5
		replace `notes' = "**" if `exp' < 1
		format `notes' %-5s
	}

	// chi-square calculations
	quietly  {
		gen double `res' = `obs' - `exp'
		char `res'[varname] "obs - exp" 
		gen double `Pearson' = (`obs' - `exp') / sqrt(`exp')
		char `Pearson'[varname] "Pearson" 
		format `exp' `res' `Pearson' %10.3f
		gen double `Pearson2' = `Pearson'^2
		su `Pearson2' if `touse', meanonly
	    	local k  = r(N)
		scalar `chi2' = r(sum)
		scalar `p' = chiprob(`df', `chi2')
		gen double `lrchi2' = `obs' * log(`obs' / `exp')
		su `lrchi2', meanonly
		scalar `chi2_lr' = 2 * r(sum)
		scalar `p_lr' = chiprob(`df', `chi2_lr')
	}

	// output results
	di _n as txt "         Pearson chi2(" as res "`df'"            ///
		as txt ") = " as res %8.4f `chi2' as txt "   Pr = "    ///
		as res %6.3f `p'
	di as txt "likelihood-ratio chi2(" as res "`df'"               ///
		as txt ") = " as res %8.4f `chi2_lr' as txt "   Pr = " /// 
		as res %6.3f `p_lr'

	l `counted' `obs' `exp' `notes' `res' `Pearson' if `touse', ///
	ab(`abbreviate') noobs subvarname `options' 

	// explain notes if necessary
	if `lt5' | `lt1' di 
	if `lt5' di as res "* " as txt " 1 <= expected < 5" 
	if `lt1' di as res "**" as txt " 0 <  expected < 1"

	// returned results 
	return scalar emean = `emean'
	return scalar p_lr = `p_lr'
	return scalar chi2_lr = `chi2_lr'
	return scalar p = `p'
	return scalar chi2 = `chi2'
	return scalar df = `df'
	return scalar k = `k'
end
