*! version 1.5.0 18Aug2011 MLB
program define hangr_uniform, rclass
	syntax varname [if] [fweight] ,  ///
	x(string) nobs(real) nbins(real) w(real) min(real) max(real) theor(string) ///
	[ par(numlist) suspended XXfit(integer 0) withx(integer 0) xwx(varname) grden(string) ]
	
	if "`suspended'" != "" local minus "-"
	if "`weight'" != "" local wght "[`weight'`exp']"
	marksample touse


	if "`par'" != "" {
		local a : word 1 of `par'
		local b : word 2 of `par'
	}
	else {
		qui sum `varlist' if `touse' `wght', 
		local a = r(mean) - sqrt(3)*r(sd)
		local b = r(mean) + sqrt(3)*r(sd)
	}
	local range = `b'-`a'
	qui gen `theor' = sqrt((1/`range')*`nobs'*`w') if `x' < .
	local grden "1/`range'"
	return local gr "function y = `minus'sqrt(`nobs'*`w'*`grden'), range(`a' `b')" 
	return scalar a = `a'
	return scalar b = `b'

end
