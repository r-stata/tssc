*! version 1.5.0 12Aug2011 MLB
program define hangr_chi2, rclass
	syntax varname [if] [fweight] ,  ///
	x(string) nobs(real) nbins(real) w(real) min(real) max(real) theor(string) ///
	[ par(numlist) suspended XXfit(integer 0) withx(integer 0) xwx(varname) grden(string) ]
	
	if "`suspended'" != "" local minus "-"
	if "`weight'" != "" local wght "[`weight'`exp']"
	marksample touse

	if "`par'" != "" {
			local v : word 1 of `par'
	}
	else {
		qui sum `varlist' if `touse' `wght', meanonly
		local v = r(mean)
	}
	qui gen `theor' = sqrt(gammaden(`=`v'/2',2,0,`x')*`nobs'*`w')
	local grden "gammaden(`=`v'/2',2,0,x)"
	return local gr "function y = `minus'sqrt(`nobs'*`w'*(`grden')), range(`min' `max')"
	return scalar a = `v'
end
