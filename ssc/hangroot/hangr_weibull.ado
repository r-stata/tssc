*! version 1.5.0 16Aug2011 MLB
program define hangr_weibull, rclass sortpreserve
	syntax varname [if] [fweight /] ,  ///
	x(string) nobs(real) nbins(real) w(real) min(real) max(real) theor(string) ///
	[ par(numlist) suspended XXfit(integer 0) withx(integer 0) xwx(varname) grden(string) ]
	
	if "`suspended'" != "" local minus "-"
	if "`weight'" != "" local wght "[`weight' = `exp']"
	marksample touse

	if "`par'" == "" {
		if `xxfit' & `withx' == 0  {
			tempname bs cs mat
			matrix `mat' = e(b)
			scalar `bs' = el(`mat',1,1)
			local b = `bs'
			matrix `mat' = e(c)
			scalar `cs' = el(`mat',1,1)
			local c = `cs'
			qui gen `theor' = sqrt( (`c'/`b')*(`x'/`b')^(`c' - 1)*exp(-(`x'/`b')^`c') * `nobs'*`w')
			local grden "(`c'/`b')*(x/`b')^(`c' - 1)*exp(-(x/`b')^`c')"
			return local gr "function y = `minus'sqrt(`nobs'*`w'*(`grden')), range(`min' `max')"
			return scalar a = `c'
			return scalar b = `b'
			
		}
		else  {
			tempvar b c partden
			qui predict double `b' if `touse', eq(#1)
			qui predict double `c' if `touse', eq(#2)
			qui gen `partden' = .
			qui gen `grden' = .
			qui count if `xwx' < .
			forvalues i = 1/`r(N)' {
				qui replace `partden' = (`c'/`b')*(`xwx'[`i']/`b')^(`c' - 1)*exp(-(`xwx'[`i']/`b')^`c') if `touse'
				sum `partden' if `touse' `wght', meanonly
				qui replace `grden' = r(mean) in `i'
				
			}
			qui gen `theor' = sqrt(`nobs'*`w'*(`grden'))
			qui replace `grden' = `minus'`theor'
			return local gr "line `grden' `xwx', sort"
		}
	}
	else {
		local c : word 1 of `par'
		local b : word 2 of `par'		
		qui gen `theor' = sqrt( (`c'/`b')*(`x'/`b')^(`c' - 1)*exp(-(`x'/`b')^`c') * `nobs'*`w')
		local grden "(`c'/`b')*(x/`b')^(`c' - 1)*exp(-(x/`b')^`c')"
		return local gr "function y = `minus'sqrt(`nobs'*`w'*(`grden')), range(`min' `max')"
		return scalar a = `c'
		return scalar b = `b'
	}
end
