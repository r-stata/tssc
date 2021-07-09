*! version 1.5.0 16Aug2011 MLB
program define hangr_gamma, rclass
	syntax varname [if] [fweight] ,  ///
	x(string) nobs(real) nbins(real) w(real) min(real) max(real) theor(string) ///
	[ par(numlist) suspended XXfit(integer 0) withx(integer 0) xwx(varname) grden(string) ]
	
	if "`suspended'" != "" local minus "-"
	if "`weight'" != "" local wght "[`weight'`exp']"
	marksample touse

	if "`par'" == "" {
		if `xxfit' & `withx' == 0  {
			local a = `e(alpha)'
			if "`e(user)'" == "gammafit_lf" {
				local b = `e(beta)'
			}
			else {
				local b = 1/`e(beta)'
			}
			qui gen `theor' = sqrt( gammaden(`a', `b', 0,`x')*`nobs'*`w')
			local grden "gammaden(`a', `b', 0, x)"
			return local gr "function y = `minus'sqrt(`nobs'*`w'*(`grden')), range(`min' `max')"
			return scalar a = `a'
			return scalar b = `b'
		}
		else if `xxfit' {
			tempvar a b partden
			qui predict double `a' if `touse', eq(#1)
			qui predict double `b' if `touse', eq(#2)
			if "`e(user)'" == "gammafit_lf2" {
				replace `b' = 1/`b'
			}
			qui gen `partden' = .
			qui gen `grden' = .
			qui count if `xwx' < .
			forvalues i = 1/`r(N)' {
				qui replace `partden' = gammaden(`a', `b', 0, `xwx'[`i']) if `touse'
				sum `partden' if `touse' `wght', meanonly
				qui replace `grden' = r(mean) in `i'
			}
			qui gen `theor' = sqrt(`nobs'*`w'*(`grden'))
			qui replace `grden' = `minus'`theor'
			return local gr "line `grden' `xwx', sort"
		}
		else {
			tempname s a b m
			tempvar log
			gen double `log' = ln(`varlist')
			sum `varlist' if `touse' `wght', meanonly
			scalar `m' = r(mean)
			sum `log' if `touse' `wght', meanonly
			scalar `s' = ln(`m') - r(mean)
			scalar `a' = (3 - `s' + sqrt((`s'-3)^2 + 24*`s'))/(12*`s')
			scalar `a' = `a' - ( ln(`a') - digamma(`a') - `s' ) / ///
							   ( 1/`a' - trigamma(`a') )
			scalar `b' = `m'/`a'
			qui gen `theor' = sqrt( gammaden(`a', `b', 0,`x')*`nobs'*`w')
			local grden "gammaden(`=`a'', `=`b'', 0, x)"
			return local gr "function y = `minus'sqrt(`nobs'*`w'*(`grden')), range(`min' `max')"
			return scalar a = `a'
			return scalar b = `b'
		}
	}
	else {
		local a : word 1 of `par'
		local b : word 2 of `par'
		qui gen `theor' = sqrt( gammaden(`a', `b', 0,`x')*`nobs'*`w')
		local grden "gammaden(`a', `b', 0, x)"
		return local gr "function y = `minus'sqrt(`nobs'*`w'*(`grden')), range(`min' `max')"
		return scalar a = `a'
		return scalar b = `b'
	}
end
