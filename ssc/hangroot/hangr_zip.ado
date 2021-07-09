*! version 1.5.0 10Okt2011 MLB
program define hangr_zip, rclass
	syntax varname [if] [fweight] ,  ///
	x(string) nobs(real) nbins(real) w(real) min(real) max(real) theor(string) ///
	[ par(numlist) suspended XXfit(integer 0) withx(integer 0) xwx(varname) grden(string) theorgr(string) ]
	
	if "`suspended'" != "" local minus "-"
	if "`weight'" != "" local wght "[`weight'`exp']"
	marksample touse
	
	if "`par'" == "" {
		if `xxfit' & `withx' == 0  {
			local lambda = exp(_b[_cons])
			if "`e(inflate)'" == "logit" {
				local p  = invlogit(   [inflate]_b[_cons])
				local ip = invlogit(-1*[inflate]_b[_cons])
			}
			if "`inflate'" == "probit" {
				local p  = normal(   [inflate]_b[_cons])
				local ip = normal(-1*[inflate]_b[_cons])
			}
			
			local poisson "exp(-1*`lambda')*`lambda'^`x'/(exp(lngamma(`x'+1)))"
			local grden "cond(`x'==0, `p' + `ip'*exp(-`lambda'), `ip'*(`poisson') )"
 			qui gen `theor' = sqrt(`nobs'*`w'*(`grden'))
			qui gen `theorgr' = `minus'sqrt(`nobs'*`w'*(`grden'))
			return local gr "scatter `theorgr' `x', msymbol(D) || line `theorgr' `x' if `x' != 0, sort"
			return scalar a = `lambda'
			return scalar b = `p'
		}
		else if `xxfit' {
			tempvar lambda p ip xb1 xb2 partden 
			qui predict double `xb1' if `touse', xb eq(#1)
			qui gen double `lambda' = exp(`xb1')
			qui drop `xb1'
			qui predict double `xb2' if `touse', xb eq(#2)
			if "`e(inflate)'" == "logit" { 	
				qui gen double `p'  = invlogit(   `xb2')
				qui gen double `ip' = invlogit(-1*`xb2')
			}
			if "`e(inflate)'" == "probit" {
				qui gen double `p'  == normal(   `xb2')
				qui gen double `ip' == normal(-1*`xb2')
			}
			qui drop `xb2'
			qui gen `partden' = .
			qui gen `grden' = .
			qui count if `x' < .
			forvalues i = 1/`r(N)' {
				local poisson "exp(-1*`lambda')*`lambda'^`x'[`i']/(exp(lngamma(`x'[`i']+1)))"
				local grdenl "cond(`x'[`i']==0, `p' + `ip'*exp(-`lambda'), `ip'*(`poisson') )"
				qui replace `partden' = `grdenl' if `touse'
				sum `partden' if `touse' `wght' , meanonly
				qui replace `grden' = r(mean) in `i'
				
			}
			qui gen `theor' = sqrt(`nobs'*`w'*(`grden'))
			qui gen `theorgr' = `minus'`theor'
			return local gr "scatter `theorgr' `x', msymbol(D) || line `theorgr' `x' if `x' != 0, sort"
		}
	}
	else {
		local lambda : word 1 of `par'
		local p : word 2 of `par'
		local poisson "exp(-1*`lambda')*`lambda'^`x'/(exp(lngamma(`x'+1)))"
		local grden "cond(`x'==0, `p' + (1-`p')*exp(-`lambda'), (1-`p')*(`poisson') )"
		qui gen `theor' = sqrt(`nobs'*`w'*(`grden'))
		qui gen `theorgr' = `minus'sqrt(`nobs'*`w'*(`grden'))
		return local gr "scatter `theorgr' `x', msymbol(D) || line `theorgr' `x' if `x' != 0, sort"
		return scalar a = `lambda'
		return scalar b = `p'
	}
	
end
	