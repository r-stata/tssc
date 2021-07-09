*! semean  v1.1.0  CFBaum  04aug2005
program define semean, rclass byable(recall) sortpreserve
	version 9.0
	syntax varlist(max=1 ts numeric) [if] [in] ///
		[, noPRInt FUNCtion(string)]
	marksample touse
	tempvar target
	if "`function'" == "" {
		local tgt "`varlist'"
	}
	else {
		local tgt "`function'(`varlist')"
	}
	capture tsset
	capture generate double `target' = `tgt' if `touse'
	if _rc > 0 {
		display as err "Error: bad function `tgt'"
		error 198
		}
	quietly summarize `target' 
	scalar semean = r(sd)/sqrt(r(N))
	if ("`print'" ~= "noprint") {
		display _n "Mean of `tgt' = " r(mean) ///
		" S.E. = " semean
	}
	return scalar semean = semean
	return scalar mean = r(mean)
	return scalar N = r(N)
	return local var `tgt'
end
