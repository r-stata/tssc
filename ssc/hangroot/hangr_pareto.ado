*! version 1.5.0 17Aug2011 MLB
program define hangr_pareto, rclass
	syntax varname [if] [fweight] ,  ///
	x(string) nobs(real) nbins(real) w(real) min(real) max(real) theor(string) ///
	[ par(numlist) suspended XXfit(integer 0) withx(integer 0) xwx(varname) grden(string) ]
	
	if "`suspended'" != "" local minus "-"
	if "`weight'" != "" local wght "[`weight'`exp']"
	marksample touse

	if "`par'" == "" {
		if `xxfit' & `withx' == 0  {
			local xm = e(x0)
			local k = e(ba)
			qui gen `theor' = sqrt((`k'*`xm'^`k'/`x'^(`k'+1))*`nobs'*`w')
			local grden "`k'*`xm'^`k'/x^(`k'+1)"
			return local gr "function y = `minus'sqrt(`nobs'*`w'*(`grden')), range(`xm' `max')" 
			return scalar a = `xm'
			return scalar b = `k'
		}
		else if `xxfit' {
			tempvar k partden
			qui predict double `k' if `touse'
			local xm = e(x0)
			qui gen `partden' = .
			qui gen `grden' = .
			qui count if `xwx' < .
			forvalues i = 1/`r(N)' {
				qui replace `partden' =`k'*`xm'^`k'/`xwx'[`i']^(`k'+1) if `touse'
				sum `partden' if `touse' `wght', meanonly
				qui replace `grden' = r(mean) in `i'
				
			}
			qui gen `theor' = sqrt(`nobs'*`w'*(`grden'))
			qui replace `grden' = `minus'`theor'
			return local gr "line `grden' `xwx', sort"		
		}
		else {
			sum `varlist' `wght' if `touse', meanonly
			local xm = r(min)
			tempvar temp
			qui gen double `temp' = ln(`varlist') - ln(`xm') if `touse'
			sum `temp' `wght' if `touse', meanonly
			local k = r(N)/r(sum)
			qui gen `theor' = sqrt((`k'*`xm'^`k'/`x'^(`k'+1))*`nobs'*`w')
			local grden "`k'*`xm'^`k'/x^(`k'+1)"
			return local gr "function y = `minus'sqrt(`nobs'*`w'*(`grden')), range(`xm' `max')" 
			return scalar a = `xm'
			return scalar b = `k'
		}
	}
	else {
		local xm : word 1 of `par'
		local k : word 2 of `par'
		qui gen `theor' = sqrt((`k'*`xm'^`k'/`x'^(`k'+1))*`nobs'*`w')
		local grden "`k'*`xm'^`k'/x^(`k'+1)"
		return local gr "function y = `minus'sqrt(`nobs'*`w'*(`grden')), range(`xm' `max')" 
		return scalar a = `xm'
		return scalar b = `k'
	}
end
