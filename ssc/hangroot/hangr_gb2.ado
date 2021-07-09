*! version 1.5.0 12Aug2011 MLB
program define hangr_gb2, rclass sortpreserve
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
			local q = [q]_b[_cons]
			local B =  exp(lngamma(`p') + lngamma(`q') - lngamma(`p'+`q'))
			qui gen `theor' = sqrt(( ///
			`a'*`x'^(`a'*`p'-1)*((`b'^(`a'*`p'))*`B'*(1 + (`x'/`b')^`a' )^(`p'+`q'))^-1 ///
			)*`nobs'*`w')
			local grden "`a'*x^(`a'*`p'-1)*((`b'^(`a'*`p'))*`B'*(1 + (x/`b')^`a' )^(`p'+`q'))^-1"
			return local gr "function y = `minus'sqrt(`nobs'*`w'*(`grden')), range(`min' `max')"
			return scalar a = `a'
			return scalar b = `b'
			return scalar c = `p'
			return scalar d = `q'
		}
		else  {
			tempvar a b p q B partden
			qui predict double `a' if `touse', eq(#1)
			qui predict double `b' if `touse', eq(#2)
			qui predict double `p' if `touse', eq(#3)
			qui predict double `q' if `touse', eq(#4)
			qui gen double `B' =  exp(lngamma(`p') + lngamma(`q') - lngamma(`p'+`q'))

			qui gen `partden' = .
			qui gen `grden' = .
			qui count if `xwx' < .
			forvalues i = 1/`r(N)' {
				qui replace `partden' = `a'*`xwx'[`i']^(`a'*`p'-1)*((`b'^(`a'*`p'))*`B'*(1 + (`xwx'[`i']/`b')^`a' )^(`p'+`q'))^-1 if `touse'
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
		local q : word 4 of `par'
		local B =  exp(lngamma(`p') + lngamma(`q') - lngamma(`p'+`q'))
		qui gen `theor' = sqrt(( ///
		`a'*`x'^(`a'*`p'-1)*((`b'^(`a'*`p'))*`B'*(1 + (`x'/`b')^`a' )^(`p'+`q'))^-1 ///
		)*`nobs'*`w')
		local grden "`a'*x^(`a'*`p'-1)*((`b'^(`a'*`p'))*`B'*(1 + (x/`b')^`a' )^(`p'+`q'))^-1"
		return local gr "function y = `minus'sqrt(`nobs'*`w'*(`grden')), range(`min' `max')"	
		return scalar a = `a'
		return scalar b = `b'
		return scalar c = `p'
		return scalar d = `q'
	}
end
