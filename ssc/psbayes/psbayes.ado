*! 1.2.0 NJC 16 August 2004 
* 1.1.0 NJC 24 March 1999
* 1.0.0 NJC 17 July 1998
program psbayes, rclass 
	version 8.0
	syntax varlist(min=1 max=2) [if] [in] /// 
	[, Prob Generate(str) BY(varlist min=1 max=3) CENtre CENter ///
	Format(str) * ]
	
	tokenize `varlist'
	args data prior 

	marksample touse
	quietly { 
		count if `touse' 
		if r(N) == 0 error 2000 
	
		tempvar sq diffsq pb
		
		if "`by'" != "" {
			tokenize `by'
		        args row col layer
		        local by "`row' `col'"
		}
		else {
			tempvar by
			gen long `by' = _n if `touse'
			label var `by' "Obs"
		}

		su `data' if `touse', meanonly
		local N = r(sum)

		if "`prior'" == "" {
			tempvar prior
			gen `prior' = 1 / r(N) if `touse'
		}
		else {
			su `prior' if `touse', meanonly
			if abs(r(sum) - 1) > 0.01 {
				di as err "prior probabilities sum to " r(sum)
				exit 198
			}
		}

		gen `sq' = `data'^2 if `touse'
		su `sq', meanonly
		local sumsq = r(sum)
		gen `diffsq' = (`data' - `N' * `prior')^2 if `touse'
		su `diffsq', meanonly
		local sumd2 = r(sum)
		local K = (`N'^2 - `sumsq') / `sumd2'

		local factor = cond("`prob'" != "", 1, `N') 
		gen `pb' = (`factor' / (`N' + `K')) * (`data' + `K' * `prior')
		label var `pb' "Estimate"
	}

	if "`center'`centre'" == "" local center "center"
	if "`format'" == "" { 
		local format = cond("`prob'" == "", "%9.1f", "%5.3f")
	} 	
	if "`layer'" != "" local layer "by(`layer')" 
		
	tabdisp `by' if `touse', /// 
	c(`pb') f(`format') `center' `options' `layer'

	qui if "`generate'" != "" {
		confirm new variable `generate'
		gen `generate' = `pb'
	}

	return local N = `N'
	return local K = `K'
end
