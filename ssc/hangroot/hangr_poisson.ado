*! version 1.5.0 07Sept2011 MLB
program define hangr_poisson, rclass
	syntax varname [if] [fweight] ,  ///
	x(string) nobs(real) nbins(real) w(real) min(real) max(real) theor(string) ///
	[ par(numlist) suspended XXfit(integer 0) withx(integer 0) xwx(varname) grden(string) theorgr(string) ]
	
	if "`suspended'" != "" local minus "-"
	if "`weight'" != "" local wght "[`weight'`exp']"
	marksample touse
	
	if "`par'" == "" {
		if `xxfit' & `withx' == 0  {
			local lambda = exp(_b[_cons])
			qui gen `theor' = sqrt((exp(-`lambda')*`lambda'^`x'/(exp(lngamma(`x'+1))))*`nobs'*`w')
			qui gen `theorgr' = `minus'sqrt((exp(-`lambda')*`lambda'^`x'/(exp(lngamma(`x'+1))))*`nobs'*`w')
			return local gr "scatter `theorgr' `x', msymbol(D) || line `theorgr' `x', sort"
			return scalar a = `lambda'
		}
		else if `xxfit' {
			tempvar lambda partden 
			qui predict double `lambda' if `touse', n
			qui gen `partden' = .
			qui gen `grden' = .
			qui count if `x' < .
			forvalues i = 1/`r(N)' {
				qui replace `partden' = exp(-`lambda')*`lambda'^`x'[`i']/(exp(lngamma(`x'[`i']+1))) if `touse'
				sum `partden' if `touse' `wght' , meanonly
				qui replace `grden' = r(mean) in `i'
				
			}
			qui gen `theor' = sqrt(`nobs'*`w'*(`grden'))
			qui gen `theorgr' = `minus'`theor'
			return local gr "scatter `theorgr' `x', msymbol(D) || line `theorgr' `x', sort"
		}
		else {
			qui sum `varlist' if `touse' `wght', meanonly
			local lambda = r(mean)
			qui gen `theor' = sqrt((exp(-`lambda')*`lambda'^`x'/(exp(lngamma(`x'+1))))*`nobs'*`w')
			qui gen `theorgr' = `minus'sqrt((exp(-`lambda')*`lambda'^`x'/(exp(lngamma(`x'+1))))*`nobs'*`w')
			return local gr "scatter `theorgr' `x', msymbol(D) || line `theorgr' `x', sort"
			return scalar a = `lambda'
		}
	}
	else {
		local lambda `par'
		qui gen `theor' = sqrt((exp(-`lambda')*`lambda'^`x'/(exp(lngamma(`x'+1))))*`nobs'*`w')
		qui gen `theorgr' = `minus'sqrt((exp(-`lambda')*`lambda'^`x'/(exp(lngamma(`x'+1))))*`nobs'*`w')
		return local gr "scatter `theorgr' `x', msymbol(D) || line `theorgr' `x', sort"
		return scalar a = `lambda'
	}
	


end
	