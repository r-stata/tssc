*! version 1.5.0 17Aug2011 MLB
program define hangr_logistic, rclass
	syntax varname [if] [fweight] ,  ///
	x(string) nobs(real) nbins(real) w(real) min(real) max(real) theor(string) ///
	[ par(numlist) suspended XXfit(integer 0) withx(integer 0) xwx(varname) grden(string) ]
	
	if "`suspended'" != "" local minus "-"
	if "`weight'" != "" local wght "[`weight'`exp']"
	marksample touse


	if "`par'" != "" {
		local mu : word 1 of `par'
		local s : word 2 of `par'    
	}
	else {
		qui sum `varlist' if `touse' `wght'
		local mu = r(mean)
		local s  = r(sd)*sqrt(3)/_pi
	}
	local z (`x' - `mu' )/`s'
	qui gen `theor' = sqrt(exp(-1*`z')/(`s'*(1+exp(-1*`z'))^2)*`nobs'*`w') 
	local z (x - `mu' )/`s'
	local grden "exp(-1*`z')/(`s'*(1+exp(-1*`z'))^2)"
	return local gr "function y = `minus'sqrt(`nobs'*`w'*(`grden')), range(`min' `max')"
	return scalar a = `mu'
	return scalar b = `s'

end
