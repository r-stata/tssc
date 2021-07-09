*! version 1.5.0 16Aug2011 MLB
program define hangr_lognormal, rclass
	syntax varname [if] [fweight] ,  ///
	x(string) nobs(real) nbins(real) w(real) min(real) max(real) theor(string) ///
	[ par(numlist) suspended XXfit(integer 0) withx(integer 0) xwx(varname) grden(string) ]
	
	if "`suspended'" != "" local minus "-"
	if "`weight'" != "" local wght "[`weight'`exp']"
	marksample touse

	if "`par'" == "" {
		if `xxfit' & `withx' == 0  {
			local mu = `e(bm)'
			local sigma = `e(bv)'
			qui gen `theor' = sqrt( ///
				(1 / (`x' * `sigma' * sqrt(2 * _pi))) * ///
						exp(-(log(`x') - `mu')^2 / (2 * `sigma'^2)) *  ///
			`nobs'*`w')
			local grden "(1 / (x * `sigma' * sqrt(2 * _pi))) * exp(-(log(x) - `mu')^2 / (2 * `sigma'^2))"
			return local gr "function y = `minus'sqrt(`nobs'*`w'*(`grden')), range(`min' `max')" 
			return scalar a = `mu'
			return scalar b = `sigma'
		}
		else if `xxfit' {
			tempvar mu sigma partden 
			qui predict double `mu' if `touse', eq(#1)
			qui predict double `sigma' if `touse', eq(#2)
			qui gen `partden' = .
			qui gen `grden' = .
			qui count if `xwx' < .
			forvalues i = 1/`r(N)' {
				qui replace `partden' = (1 / (`xwx'[`i'] * `sigma' * sqrt(2 * _pi))) * exp(-(log(`xwx'[`i']) - `mu')^2 / (2 * `sigma'^2)) if `touse'
				sum `partden' if `touse' `wght', meanonly
				qui replace `grden' = r(mean) in `i'
				
			}
			qui gen `theor' = sqrt(`nobs'*`w'*(`grden'))
			qui replace `grden' = `minus'`theor'
			return local gr "line `grden' `xwx', sort"
		}
		else {
			tempvar logvar
			qui gen double `logvar' = log(`varlist') if `touse'
			qui sum `logvar' if `touse' `wght'
			local mu = `r(mean)'
			// maximum likelihood does not contain the N-1 small sample correction
			local sigma = sqrt( ((`r(N)'-1)/`r(N)') * `r(Var)')
			qui gen `theor' = sqrt( ///
				(1 / (`x' * `sigma' * sqrt(2 * _pi))) * ///
					exp(-(log(`x') - `mu')^2 / (2 * `sigma'^2)) *  ///
				`nobs'*`w')
			local grden "(1 / (x * `sigma' * sqrt(2 * _pi))) * exp(-(log(x) - `mu')^2 / (2 * `sigma'^2))"
			return local gr "function y = `minus'sqrt(`nobs'*`w'*(`grden')), range(`min' `max')" 
			return scalar a = `mu'
			return scalar b = `sigma'
		}
	}
	else {
		local mu : word 1 of `par'
		local sigma : word 2 of `par'
		qui gen `theor' = sqrt( ///
			(1 / (`x' * `sigma' * sqrt(2 * _pi))) * ///
		          exp(-(log(`x') - `mu')^2 / (2 * `sigma'^2)) *  ///
		     `nobs'*`w')
		local grden "(1 / (x * `sigma' * sqrt(2 * _pi))) * exp(-(log(x) - `mu')^2 / (2 * `sigma'^2))"
		return local gr "function y = `minus'sqrt(`nobs'*`w'*(`grden')), range(`min' `max')" 
		return scalar a = `mu'
		return scalar b = `sigma'

	}
end
