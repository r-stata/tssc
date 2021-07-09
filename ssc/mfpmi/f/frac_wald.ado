*! version 1.0.1 PR 14sep2006
* Wald tests for use with FP models. Returns the Wald statistic as reported by test.
program define frac_wald, rclass
	version 8
	* Args are simply the xvarlist.
	qui test `*'
	if missing(r(F)) return scalar wald = r(chi2)
	*else return scalar wald = r(F)
	*else return scalar wald = invchi2tail(r(df), r(p))	// gets chisq equivalent
	else return scalar wald = r(df)*r(F)	// chisquare ignoring denominator
end
