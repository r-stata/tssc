*! version 1.5.0 12Aug2011 MLB
program define hangr_sm, rclass sortpreserve
	syntax varname [if] [fweight /] ,  ///
	x(string) nobs(real) nbins(real) w(real) min(real) max(real) theor(string) ///
	[ par(numlist) suspended XXfit(integer 0) withx(integer 0) xwx(varname) grden(string) ]
	
	if "`suspended'" != "" local minus "-"
	if "`weight'" != "" local wght "[`weight' = `exp']"
	marksample touse

	if "`par'" == "" {
		if `xxfit' & `withx' == 0  {
			local a = [a]_b[_cons]
			local b = [b]_b[_cons]
			local q = [q]_b[_cons]
			qui gen `theor' = sqrt(( ///
			(`a'*`q'/`b')*((1 + (`x'/`b')^`a')^-(`q'+1))*((`x'/`b')^(`a'-1)) ///
			)*`nobs'*`w')
			local grden "(`a'*`q'/`b')*((1 + (x/`b')^`a')^-(`q'+1))*((x/`b')^(`a'-1))"
			return local gr "function y = `minus'sqrt(`nobs'*`w'*(`grden')), range(`min' `max')"
			return scalar a = `a'
			return scalar b = `b'
			return scalar c = `q'
		}
		else  {
			tempvar a b q partden
			qui predict double `a' if `touse', eq(#1)
			qui predict double `b' if `touse', eq(#2)
			qui predict double `q' if `touse', eq(#3)
			qui gen `partden' = .
			qui gen `grden' = .
			qui count if `xwx' < .
			forvalues i = 1/`r(N)' {
				qui replace `partden' = (`a'*`q'/`b')*((1 + (`xwx'[`i']/`b')^`a')^-(`q'+1))*((`xwx'[`i']/`b')^(`a'-1)) if `touse'
				sum `partden' if `touse' `wght' , meanonly
				qui replace `grden' = r(mean) in `i'
			}
			qui gen `theor' = sqrt(`nobs'*`w'*(`grden'))
			qui replace `grden' = `minus'`theor'
			return local gr "line `grden' `xwx', sort"			
		}
	}
	else {
		local a : word 1 of `par'
		local b : word 2 of `par'
		local q : word 3 of `par'
		qui gen `theor' = sqrt(( ///
		(`a'*`q'/`b')*((1 + (`x'/`b')^`a')^-(`q'+1))*((`x'/`b')^(`a'-1)) ///
		)*`nobs'*`w')
		local grden "(`a'*`q'/`b')*((1 + (x/`b')^`a')^-(`q'+1))*((x/`b')^(`a'-1))"
		return local gr "function y = `minus'sqrt(`nobs'*`w'*(`grden')), range(`min' `max')"
		return scalar a = `a'
		return scalar b = `b'
		return scalar c = `q'
	}
end
