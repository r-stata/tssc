*! version 1.5.0 17Aug2011 MLB
program define hangr_normal, rclass
	version 9.2
	syntax varname [if] [fweight] ,  ///
	x(string) nobs(real) nbins(real) w(real) min(real) max(real) theor(string) ///
	[ par(numlist) suspended XXfit(integer 0) withx(integer 0) xwx(varname) grden(string) ]
	
	if "`suspended'" != "" local minus "-"
	if "`weight'" != "" local wght "[`weight'`exp']"
	marksample touse

	if "`par'" == "" {
		if `xxfit' & `withx' == 0  {
			local m = _b[_cons]
			local sd = `e(rmse)'
			qui gen `theor' = sqrt(normalden(`x', `m', `sd')*`nobs'*`w')
			local grden "normalden(x, `m', `sd')"
			return local gr "function y = `minus'sqrt(`nobs'*`w'*(`grden')), range(`min' `max')" 
			return scalar a = `m'
			return scalar b = `sd'
		}
		else if `xxfit' {
			tempvar m partden 
			tempname sd
			qui predict double `m' if `touse', xb
			scalar `sd' = `e(rmse)'
			qui gen `partden' = .
			qui gen `grden' = .
			qui count if `xwx' < .
			forvalues i = 1/`r(N)' {
				qui replace `partden' = normalden(`xwx'[`i'],`m',`sd') if `touse'
				sum `partden' if `touse' `wght', meanonly
				qui replace `grden' = r(mean) in `i'
				
			}
			qui gen `theor' = sqrt(`nobs'*`w'*(`grden'))
			qui replace `grden' = `minus'`theor'
			return local gr "line `grden' `xwx', sort"
		}
		else {
			qui sum `varlist' if `touse' `wght'
			local sd = r(sd)
			local m = r(mean)
			qui gen `theor' = sqrt(normalden(`x', `m', `sd')*`nobs'*`w') 
			local grden "normalden(x, `m', `sd')"
			return local gr "function y = `minus'sqrt(`nobs'*`w'*(`grden')), range(`min' `max')"
			return scalar a = `m'
			return scalar b = `sd'
		}
	}
	else {
		local m : word 1 of `par'
		local sd : word 2 of `par'    
		qui gen `theor' = sqrt(normalden(`x', `m', `sd')*`nobs'*`w') 
		local grden "normalden(x, `m', `sd')"
		return local gr "function y = `minus'sqrt(`nobs'*`w'*(`grden')), range(`min' `max')"
		return scalar a = `m'
		return scalar b = `sd'
	}
end
	