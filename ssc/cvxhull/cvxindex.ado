* 1.0 RAR 11 January 2004, with index counts returned
* designed only as utility to call after cvxhull
program cvxindex
	version 8.0
	syntax [if] [in] ///
	[, PREfix(string) SELect(numlist int min=0 >0 sort) noREPort]
* Extracts hull index counts from vectors set up by cvxhull

	marksample touse // Deal with `if' and `in'
	qui count if `touse'
	if r(N) == 0 error 2000

	if "`prefix'" == "" loc prefix "_cvxh"
	confirm numeric variable `prefix'hull `prefix'cnt

	tempvar grp
	capture confirm numeric variable `prefix'grp
	if _rc == 0  {
		qui gen `grp' = `prefix'grp
	}
	else qui gen `grp' = 1
	su `grp', meanonly
	loc maxgrp = r(max)
	if "`select'" == ""  loc select "1 / `maxgrp'"
	foreach i of numlist `select' {
		capture drop `prefix'`i'mindex `prefix'`i'maxdex
		qui gen `prefix'`i'mindex = .
		qui gen `prefix'`i'maxdex = .
		qui replace `touse' = `touse' * (`grp' == `i')
	}

	loc nn = _N 
	forvalues i = 1/`nn' {
		if `touse'[`i'] {
			loc g = string(`grp'[`i'])
			loc h = `prefix'hull[`i']
			loc v = `prefix'cnt[`i']
			if `h' > 0 {
				qui replace `prefix'`g'mindex = `v' in `h'
				if `prefix'`g'maxdex[`h'] == . qui replace `prefix'`g'maxdex = `v' in `h'
			}
			else {
				if `h' < 0 {
					loc h = -`h'
					qui replace `prefix'`g'maxdex = `v' in `h' 
				}
			}
		}
	}

	if "`report'" != "noreport"  di as txt "cvxindex run"

end

