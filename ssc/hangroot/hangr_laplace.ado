*! version 1.5.0 18Aug2011 MLB
program define hangr_laplace, rclass
	syntax varname [if] [fweight] ,  ///
	x(string) nobs(real) nbins(real) w(real) min(real) max(real) theor(string) ///
	[ par(numlist) suspended XXfit(integer 0) withx(integer 0) xwx(varname) grden(string) ]
	
	if "`suspended'" != "" local minus "-"
	if "`weight'" != "" local wght "[`weight'`exp']"
	marksample touse


	if "`par'" != "" {
			local m : word 1 of `par'
			local b : word 2 of `par'
	}
	else {
		qui sum `varlist' if `touse' `wght', detail
		local m = r(p50)
		tempvar absdif
		gen `absdif' = abs(`varlist' - `m') if `touse'
		sum `absdif' `wght' if `touse', meanonly
		local b = r(mean)
	}
	qui gen `theor' = sqrt((1/(2*`b')*exp(-1*abs(`x'-`m')/`b'))*`nobs'*`w')
	local grden "1/(2*`b')*exp(-1*abs(x-`m')/`b')"
	return local gr "function y = `minus'sqrt(`nobs'*`w'*(`grden')), range(`min' `max')" 
	return scalar a = `m'
	return scalar b = `b'

end
