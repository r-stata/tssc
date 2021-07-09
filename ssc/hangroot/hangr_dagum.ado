*! version 1.5.0 12Aug2011 MLB
program define hangr_dagum, rclass sortpreserve
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
			local p = [p]_b[_cons]
			qui gen `theor' = sqrt(( ///
			(`a'*`p')*((`b'/`x')^`a')*(1/`x')/(1 + (`b'/`x')^`a')^(`p'+1) ///
			)*`nobs'*`w')
			local grden "(`a'*`p')*((`b'/x)^`a')*(1/x)/(1 + (`b'/x)^`a')^(`p'+1)"
			return local gr "function y = `minus'sqrt(`nobs'*`w'*(`grden')), range(`min' `max')"
			return scalar a = `a'
			return scalar b = `b'
			return scalar c = `p'
		}
		else  {
			tempvar a b p partden
			qui predict double `a' if `touse', eq(#1)
			qui predict double `b' if `touse', eq(#2)
			qui predict double `p' if `touse', eq(#3)
			qui gen `partden' = .
			qui gen `grden' = .
			qui count if `xwx' < .
			forvalues i = 1/`r(N)' {
				qui replace `partden' = (`a'*`p')*((`b'/`xwx'[`i'])^`a')*(1/`xwx'[`i'])/(1 + (`b'/`xwx'[`i'])^`a')^(`p'+1) if `touse'
				sum `partden' if `touse' `wght', meanonly
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
		local p : word 3 of `par'
		qui gen `theor' = sqrt(( ///
		(`a'*`p')*((`b'/`x')^`a')*(1/`x')/(1 + (`b'/`x')^`a')^(`p'+1) ///
		)*`nobs'*`w')
		local grden "(`a'*`p')*((`b'/x)^`a')*(1/x)/(1 + (`b'/x)^`a')^(`p'+1)"
		return local gr "function y = `minus'sqrt(`nobs'*`w'*(`grden')), range(`min' `max')"
		return scalar a = `a'
		return scalar b = `b'
		return scalar c = `p'
	}
end
