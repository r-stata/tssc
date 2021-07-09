
*! nneighbor 1.0.1  CFBaum 11aug2008
program nneighbor
	version 10.1
	syntax varlist(numeric) [if] [in], ///
	Y(varname numeric) MATCHOBS(string) MATCHVAL(string)

	marksample touse
	qui count if `touse'
	if r(N) == 0 {
		error 2000
	}
// validate new variable names
	confirm new variable `matchobs'
	confirm new variable `matchval'
	qui	generate long `matchobs' = .
	qui generate `matchval' = .
	mata: mf_nneighbor("`varlist'", "`matchobs'", "`y'", ///
		"`matchval'", "`touse'")
	summarize `y' if `touse', meanonly
	display _n "Nearest neighbors for `r(N)' observations of `y'"
	display    "Based on L2-norm of standardized vars: `varlist'"
	display    "Matched observation numbers: `matchobs'"
	display    "Matched values: `matchval'"
	qui correlate `y' `matchval' if `touse'
	display    "Correlation[ `y', `matchval' ] = " %5.4f `r(rho)'
end
