*! version 1.5.0 07Sept2011 MLB
program define hangr_nb2, rclass
	syntax varname [if] [fweight] ,  ///
	x(string) nobs(real) nbins(real) w(real) min(real) max(real) theor(string) ///
	[ par(numlist) suspended XXfit(integer 0) withx(integer 0) xwx(varname) grden(string) theorgr(string) ]
	
	if "`suspended'" != "" local minus "-"
	if "`weight'" != "" local wght "[`weight'`exp']"
	marksample touse
	
	if "`par'" == "" {
		if `xxfit' & `withx' == 0  {
			local mu = exp(_b[_cons])
			local lna [lnalpha]_b[_cons]
			local ia = exp(-1*`lna')
			if `lna' < -20 { // corresponds with nbreg_lf.ado
				local grden exp(-`mu')*`mu'^`x'/(exp(lngamma(`x'+1)))
			}
			else {
				local grden exp(lngamma(`x' + `ia') - lngamma(`x'+1) - lngamma(`ia')) * (`ia'/(`ia' + `mu'))^`ia' * (`mu'/(`ia' + `mu'))^`x'
			}
			qui gen `theor' = sqrt((`grden')*`nobs'*`w')
			qui gen `theorgr' = `minus'sqrt((`grden')*`nobs'*`w')
			return local gr "scatter `theorgr' `x', msymbol(D) || line `theorgr' `x', sort"
			return scalar a = `mu'
			return scalar b = 1/`ia'
		}
		else if `xxfit' {
			tempvar mu lna ia partden 
			qui predict double `mu' if `touse', n
			if "`e(cmd)'" == "nbreg" {
				qui gen double `lna' = [lnalpha]_b[_cons] if `touse'
			}
			else {
				qui predict double `lna' , lnalpha
			}
			qui gen double `ia' = exp(-1*`lna')
			qui gen `partden' = .
			qui gen `grden' = .
			qui count if `x' < .
			forvalues i = 1/`r(N)' {
				local poiss `"exp(-`mu')*`mu'^`x'[`i']/(exp(lngamma(`x'[`i']+1)))"'
				local nb2 `"exp(lngamma(`x'[`i'] + `ia') - lngamma(`x'[`i']+1) - lngamma(`ia')) * (`ia'/(`ia' + `mu'))^`ia' * (`mu'/(`ia' + `mu'))^`x'[`i']"'
				qui replace `partden' = cond(`lna' > -20, `nb2', `poiss') if `touse'
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
		local ia = 1/`: word 2 of `par''
		local grden exp(lngamma(`x' + `ia') - lngamma(`x'+1) - lngamma(`ia')) * (`ia'/(`ia' + `mu'))^`ia' * (`mu'/(`ia' + `mu'))^`x'
		qui gen `theor' = sqrt((`grden')*`nobs'*`w')
		qui gen `theorgr' = `minus'sqrt((`grden')*`nobs'*`w')
		return local gr "scatter `theorgr' `x', msymbol(D) || line `theorgr' `x', sort"
		return scalar a = `mu'
		return scalar b = 1/`ia'	
	}

end
	