*! version 1.5.0 17Aug2011 MLB
program define hangr_exponential, rclass
	syntax varname [if] [fweight] ,  ///
	x(string) nobs(real) nbins(real) w(real) min(real) max(real) theor(string) ///
	[ par(numlist) suspended XXfit(integer 0) withx(integer 0) xwx(varname) grden(string) ]
	
	if "`suspended'" != "" local minus "-"
	if "`weight'" != "" local wght "[`weight'`exp']"
	marksample touse


	if "`par'" != "" {
			local lambda : word 1 of `par'
	}
	else {
		qui sum `varlist' if `touse' `wght', meanonly
			local lambda = 1/r(mean)
	}
	qui gen `theor' = sqrt((`lambda'*exp(-`lambda'*`x'))*`nobs'*`w')
	local grden "`lambda'*exp(-`lambda'*x)"
	return scalar a = `lambda'
	return local gr "function y = `minus'sqrt(`nobs'*`w'*(`grden')), range(`min' `max')" 

end
