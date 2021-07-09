*! version 1.5.0 18Aug2011 MLB
program define hangr_geometric, rclass
	syntax varname [if] [fweight] ,  ///
	x(string) nobs(real) nbins(real) w(real) min(real) max(real) theor(string) ///
	[ par(numlist) suspended XXfit(integer 0) withx(integer 0) xwx(varname) grden(string) theorgr(string) ]
	
	if "`suspended'" != "" local minus "-"
	if "`weight'" != "" local wght "[`weight'`exp']"
	marksample touse
	
	if "`par'" != "" {
		local p : word 1 of `par'
	}
	else {
		qui sum `varlist' if `touse' `wght', meanonly
		local p = 1/(1+r(mean))
	}
	qui gen `theor' = sqrt(((1-`p')^(`x')*`p')*`nobs'*`w')
	qui gen `theorgr' = `minus'sqrt(((1-`p')^(`x')*`p')*`nobs'*`w')
	local grden "(1-`p')^(x)*`p'"
	return local gr "scatter `theorgr' `x', msymbol(D) || line `theorgr' `x', sort"
	return scalar a = `p'

end
	