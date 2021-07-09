*! version 1.5.0 12Okt2011 MLB
program define hangr_zinb, rclass
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
			local alpha = exp([lnalpha]_b[_cons])
			local m     = 1/`alpha'
			local mu    = exp(_b[_cons]) 
			local pp    = 1/(1+`alpha'*`mu') 
			
			#delimit ;
			local grden cond(`x' == 0 , 
					`p' + `ip'*`pp'^`m',
					`ip' * exp(lngamma(`m'+`x') - lngamma(`x'+1) - lngamma(`m')) *
					(`pp')^`m' * (1-`pp')^`x' ) ;
			#delimit cr 

			qui gen `theor' = sqrt(`nobs'*`w'*(`grden'))
			qui gen `theorgr' = `minus'sqrt(`nobs'*`w'*(`grden'))
			return local gr "scatter `theorgr' `x', msymbol(D) || line `theorgr' `x' if `x' != 0, sort"
			return scalar a = `mu'
			return scalar b = `alpha'
			return scalar c = `p'
		}
		else if `xxfit' {
			tempvar mu alpha m pp  xb2 p ip partden 
			qui predict double `mu' if `touse', xb eq(#1)
			qui replace `mu' = exp(`mu')
			qui predict double `alpha' if `touse', xb eq(#3)
			qui replace `alpha' = exp(`alpha')
			qui gen double `m' = 1/`alpha'
			qui gen `pp' = 1/(1+`alpha'*`mu')
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
				#delimit ;
				local grdenl cond(`x'[`i'] == 0 , 
				 	`p' + `ip'*`pp'^`m',
					`ip' * exp(lngamma(`m'+`x'[`i']) - lngamma(`x'[`i']+1) - lngamma(`m')) *
					(`pp')^`m' * (1-`pp')^`x'[`i'] ) ;
				#delimit cr 
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
		local mu : word 1 of `par'
		local alpha : word 2 of `par'
		local p : word 3 of `par'
		local m     = 1/`alpha'
		local pp    = 1/(1+`alpha'*`mu') 
			
		#delimit ;
		local grden cond(`x' == 0 , 
				`p' + (1-`p')*`pp'^`m',
				(1-`p') * exp(lngamma(`m'+`x') - lngamma(`x'+1) - lngamma(`m')) *
				(`pp')^`m' * (1-`pp')^`x' ) ;
		#delimit cr 
		qui gen `theor' = sqrt(`nobs'*`w'*(`grden'))
		qui gen `theorgr' = `minus'sqrt(`nobs'*`w'*(`grden'))
		return local gr "scatter `theorgr' `x', msymbol(D) || line `theorgr' `x' if `x' != 0, sort"
		return scalar a = `mu'
		return scalar b = `alpha'
		return scalar c = `p'
	}
	
end
	