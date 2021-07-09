*! version 1.5.0 07Sept2011 MLB
program define hangr_nb1, rclass
	syntax varname [if] [fweight] ,  ///
	x(string) nobs(real) nbins(real) w(real) min(real) max(real) theor(string) ///
	[ par(numlist) suspended XXfit(integer 0) withx(integer 0) xwx(varname) grden(string) theorgr(string) ]
	
	if "`suspended'" != "" local minus "-"
	if "`weight'" != "" local wght "[`weight'`exp']"
	marksample touse
	
	if "`par'" == "" {
		if `xxfit' & `withx' == 0  {
			local mu = exp(_b[_cons])
			local ld [lndelta]_b[_cons]
			local m = exp(_b[_cons] - [lndelta]_b[_cons])
			local d = exp(`ld')
			
			if `ld' < -20 { // corresponds with nbreg_la.ado
				local grden exp(-`mu')*`mu'^`x'/(exp(lngamma(`x'+1)))
			}
			else {
				local grden exp(lngamma(`x' + `m') - lngamma(`x'+1) - lngamma(`m') + `ld'*`x' - ln(1 + `d')*(`x'+`m'))
			}
			qui gen `theor' = sqrt((`grden')*`nobs'*`w')
			qui gen `theorgr' = `minus'sqrt((`grden')*`nobs'*`w')
			return local gr "scatter `theorgr' `x', msymbol(D) || line `theorgr' `x', sort"
			return scalar a = `mu'
			return scalar b = `d'
		}
		else if `xxfit' {
			tempvar mu m partden 
			qui predict double `mu' if `touse', xb
			qui gen `m' = exp(`mu' - [lndelta]_b[_cons])
			qui replace `mu' = exp(`mu' )
			local ld = [lndelta]_b[_cons] 
			local d = exp(`ld')
			qui gen `partden' = .
			qui gen `grden' = .
			qui count if `x' < .
			forvalues i = 1/`r(N)' {
				local poiss `"exp(-`mu')*`mu'^`x'[`i']/(exp(lngamma(`x'[`i']+1)))"'
				local nb1 `"exp(lngamma(`x'[`i'] + `m') - lngamma(`x'[`i']+1) - lngamma(`m') + `ld'*`x'[`i'] - ln(1 + `d')*(`x'[`i']+`m'))"'
				qui replace `partden' = cond(`ld' > -20, `nb1', `poiss') if `touse'
				sum `partden' `wght' if `touse', meanonly
				qui replace `grden' = r(mean) in `i'
				
			}
			qui gen `theor' = sqrt(`nobs'*`w'*(`grden'))
			qui gen `theorgr' = `minus'`theor'
			return local gr "scatter `theorgr' `x', msymbol(D) || line `theorgr' `x', sort"
		}
	}
	else {
		local mu : word 1 of `par'
		local d : word 2 of `par'
		local m = `mu' / `d'
		if ln(`d') < -20 { // corresponds with nbreg_la.ado
			local grden exp(-`mu')*`mu'^`x'/(exp(lngamma(`x'+1)))
		}
		else {
			local grden exp(lngamma(`x' + `m') - lngamma(`x'+1) - lngamma(`m') + ln(`d')*`x' - ln(1 + `d')*(`x'+`m'))
		}
		qui gen `theor' = sqrt((`grden')*`nobs'*`w')
		qui gen `theorgr' = `minus'sqrt((`grden')*`nobs'*`w')
		return local gr "scatter `theorgr' `x', msymbol(D) || line `theorgr' `x', sort"
		return scalar a = `mu'
		return scalar b = `d'	
	}

end
	