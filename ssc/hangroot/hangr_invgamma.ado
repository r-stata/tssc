*! version 1.5.0 15Aug2011 MLB
program define hangr_invgamma, rclass
	syntax varname [if] [fweight] ,  ///
	x(string) nobs(real) nbins(real) w(real) min(real) max(real) theor(string) ///
	[ par(numlist) suspended XXfit(integer 0) withx(integer 0) xwx(varname) grden(string) ]
	
	if "`suspended'" != "" local minus "-"
	if "`weight'" != "" local wght "[`weight'`exp']"
	marksample touse

	if "`par'" == "" {
		if `xxfit' & `withx' == 0  {
			local a = `e(alpha)'
			local b = `e(beta)'
			qui gen `theor' = sqrt((`b'^`a'/exp(lngamma(`a'))*`x'^(-`a'-1)*exp(-`b'/`x'))*`nobs'*`w')
			local grden "`b'^`a'/exp(lngamma(`a'))*x^(-`a'-1)*exp(-`b'/x)"
			return local gr "function y = `minus'sqrt(`nobs'*`w'*(`grden')), range(`min' `max')"
			return scalar a = `a'
			return scalar b = `b'
		}
		else if `xxfit' {
			tempvar a b partden
			qui predict double `a' if `touse', eq(#1)
			qui predict double `b' if `touse', eq(#2)
			qui gen `partden' = .
			qui gen `grden' = .
			qui count if `xwx' < .
			forvalues i = 1/`r(N)' {
				qui replace `partden' = `b'^`a'/exp(lngamma(`a'))*`xwx'[`i']^(-`a'-1)*exp(-`b'/`xwx'[`i']) if `touse'
				sum `partden' if `touse' `wght', meanonly
				qui replace `grden' = r(mean) in `i'
				
			}
			qui gen `theor' = sqrt(`nobs'*`w'*(`grden'))
			qui replace `grden' = `minus'`theor'
			return local gr "line `grden' `xwx', sort"
		}
		else {
			qui sum `varlist' if `touse' `wght'
			local a = (r(mean)^2)/r(Var) + 2
			local b = r(mean)*(`a'-1)
			qui gen `theor' = sqrt((`b'^`a'/exp(lngamma(`a'))*`x'^(-`a'-1)*exp(-`b'/`x'))*`nobs'*`w')
			local grden "`b'^`a'/exp(lngamma(`a'))*x^(-`a'-1)*exp(-`b'/x)"
			return local gr "function y = `minus'sqrt(`nobs'*`w'*(`grden')), range(`min' `max')"
			return scalar a = `a'
			return scalar b = `b'
		}
	}
	else {
		local a : word 1 of `par'
		local b : word 2 of `par'
		qui gen `theor' = sqrt((`b'^`a'/exp(lngamma(`a'))*`x'^(-`a'-1)*exp(-`b'/`x'))*`nobs'*`w')
		local grden "`b'^`a'/exp(lngamma(`a'))*x^(-`a'-1)*exp(-`b'/x)"
		return local gr "function y = `minus'sqrt(`nobs'*`w'*(`grden')), range(`min' `max')"
		return scalar a = `a'
		return scalar b = `b'
	}
end
