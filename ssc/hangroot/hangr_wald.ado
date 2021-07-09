*! version 1.5.0 12Aug2011 MLB
program define hangr_wald, rclass
	syntax varname [if] [fweight] ,  ///
	x(string) nobs(real) nbins(real) w(real) min(real) max(real) theor(string) ///
	[ par(numlist) suspended XXfit(integer 0) withx(integer 0) xwx(varname) grden(string) ]
	
	if "`suspended'" != "" local minus "-"
	if "`weight'" != "" local wght "[`weight'`exp']"
	marksample touse

	if "`par'" == "" {
		if `xxfit' & `withx' == 0  {
			local mu = `e(mu)'
			local l = `e(lambda)'
			qui gen `theor' = sqrt( ///
			(sqrt(`l'/(2*_pi*`x'^3)) * exp(-`l'*(`x'-`mu')^2 / (2*`mu'^2*`x')))* ///
			`nobs'*`w')
			local grden "sqrt(`l'/(2*_pi*x^3)) * exp(-`l'*(x-`mu')^2 / (2*`mu'^2*x))"
			return local gr "function y = `minus'sqrt(`nobs'*`w'*(`grden')), range(`min' `max')"
			return scalar a = `mu'
			return scalar b = `l'
		}
		else if `xxfit' {
			tempvar mu l partden
			qui predict double `mu' if `touse', eq(#1)
			qui predict double `l' if `touse', eq(#2)
			qui gen `partden' = .
			qui gen `grden' = .
			qui count if `xwx' < .
			forvalues i = 1/`r(N)' {
				qui replace `partden' = sqrt(`l'/(2*_pi*`xwx'[`i']^3)) * exp(-`l'*(`xwx'[`i']-`mu')^2 / (2*`mu'^2*`xwx'[`i'])) if `touse'
				sum `partden' if `touse' `wght', meanonly
				qui replace `grden' = r(mean) in `i'
			}
			qui gen `theor' = sqrt(`nobs'*`w'*(`grden'))
			qui replace `grden' = `minus'`theor'
			return local gr "line `grden' `xwx', sort"
		}
		else {
			tempvar diff
			qui sum `varlist' if `touse' `wght', meanonly
			local mu = r(mean)
			qui gen double `diff' = 1/`varlist' - 1/r(mean)
			sum `diff' if `touse' `wght', meanonly
			local l = 1/r(mean)
			qui gen `theor' = sqrt( ///
			(sqrt(`l'/(2*_pi*`x'^3)) * exp(-`l'*(`x'-`mu')^2 / (2*`mu'^2*`x')))* ///
			`nobs'*`w')
			local grden "sqrt(`l'/(2*_pi*x^3)) * exp(-`l'*(x-`mu')^2 / (2*`mu'^2*x))"
			return local gr "function y = `minus'sqrt(`nobs'*`w'*(`grden')), range(`min' `max')"
			return scalar a = `mu'
			return scalar b = `l'

		}
	}
	else {
		local mu : word 1 of `par'
		local l : word 2 of `par'
		qui gen `theor' = sqrt( ///
		(sqrt(`l'/(2*_pi*`x'^3)) * exp(-`l'*(`x'-`mu')^2 / (2*`mu'^2*`x')))* ///
		`nobs'*`w')
		local grden "sqrt(`l'/(2*_pi*x^3)) * exp(-`l'*(x-`mu')^2 / (2*`mu'^2*x))"
		return local gr "function y = `minus'sqrt(`nobs'*`w'*(`grden')), range(`min' `max')"
		return scalar a = `mu'
		return scalar b = `l'
	}
end
