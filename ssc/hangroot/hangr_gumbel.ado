*! version 1.5.0 15Aug2011 MLB
program define hangr_gumbel, rclass
	syntax varname [if] [fweight] ,  ///
	x(string) nobs(real) nbins(real) w(real) min(real) max(real) theor(string) ///
	[ par(numlist) suspended XXfit(integer 0) withx(integer 0) xwx(varname) grden(string) ]
	
	if "`suspended'" != "" local minus "-"
	if "`weight'" != "" local wght "[`weight'`exp']"
	marksample touse

	if "`par'" == "" {
		if `xxfit' & `withx' == 0  {
			local a = `e(alpha)'
			local mu = `e(mu)'
			qui gen `theor' = sqrt(((1 / `a') * exp(-(`x' - `mu') / `a') * exp(-exp(-(`x' - `mu') / `a'))) *`nobs'*`w')
			local grden "(1 / `a') * exp(-(x - `mu') / `a') * exp(-exp(-(x - `mu') / `a'))"
			return local gr "function y = `minus'sqrt(`nobs'*`w'*(`grden')), range(`min' `max')"
			return scalar a = `mu'
			return scalar b = `a'
		}
		else if `xxfit' {
			tempvar a mu partden
			qui predict double `a' if `touse', eq(#1)
			qui predict double `mu' if `touse', eq(#2)
			qui gen `partden' = .
			qui gen `grden' = .
			qui count if `xwx' < .
			forvalues i = 1/`r(N)' {
				qui replace `partden' = (1 / `a') * exp(-(`xwx'[`i'] - `mu') / `a') * exp(-exp(-(`xwx'[`i'] - `mu') / `a')) if `touse'
				sum `partden' if `touse' `wght', meanonly
				qui replace `grden' = r(mean) in `i'
				
			}
			qui gen `theor' = sqrt(`nobs'*`w'*(`grden'))
			qui replace `grden' = `minus'`theor'
			return local gr "line `grden' `xwx', sort"
		}
		else {
			qui sum `varlist' if `touse' `wght'
			local a = r(sd)*sqrt(6)/_pi
			// need to subtract gamma * a
			// gamma = - digamma(1)
			local mu = r(mean) + digamma(1)*`a'
			qui gen `theor' = sqrt(((1 / `a') * exp(-(`x' - `mu') / `a') * exp(-exp(-(`x' - `mu') / `a'))) *`nobs'*`w')
			local grden "(1 / `a') * exp(-(x - `mu') / `a') * exp(-exp(-(x - `mu') / `a'))"
			return local gr "function y = `minus'sqrt(`nobs'*`w'*(`grden')), range(`min' `max')"
			return scalar a = `mu'
			return scalar b = `a'	
		}
	}
	else {
		local mu : word 1 of `par'
		local a : word 2 of `par'
		qui gen `theor' = sqrt(((1 / `a') * exp(-(`x' - `mu') / `a') * exp(-exp(-(`x' - `mu') / `a'))) *`nobs'*`w')
		local grden "(1 / `a') * exp(-(x - `mu') / `a') * exp(-exp(-(x - `mu') / `a'))"
		return local gr "function y = `minus'sqrt(`nobs'*`w'*(`grden')), range(`min' `max')"
		return scalar a = `mu'
		return scalar b = `a'	
	}
end
