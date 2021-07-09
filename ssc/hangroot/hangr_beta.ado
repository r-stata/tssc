*! version 1.5.0 17Aug2011 MLB
program define hangr_beta, rclass
	syntax varname [if] [fweight] ,  ///
	x(string) nobs(real) nbins(real) w(real) min(real) max(real) theor(string) ///
	[ par(numlist) suspended XXfit(integer 0) withx(integer 0) xwx(varname) ninter(integer 1) grden(string) ]
	
	if "`suspended'" != "" local minus "-"
	if "`weight'" != "" local wght "[`weight'`exp']"
	marksample touse


	if "`par'" != "" {
		local alpha : word 1 of `par'
		local beta : word 2 of `par'
		qui gen `theor' = sqrt(betaden(`alpha',`beta',`x')*`nobs'*`w')
        local grden "betaden(`alpha',`beta',x)"
        return local gr "function y = `minus'sqrt(`nobs'*`w'*(`grden')), range(`min' `max')"
	    return scalar a = `alpha'
	    return scalar b = `beta'
	}
	else if `xxfit' {
		if "`e(alpha)'`e(beta)'" != "" {
			local alpha = e(alpha)
			local beta = e(beta)
			qui gen `theor' = sqrt(betaden(`alpha',`beta',`x')*`nobs'*`w')
	           local grden "betaden(`alpha',`beta',x)"
	           return local gr "function y = `minus'sqrt(`nobs'*`w'*(`grden')), range(`min' `max')"
	           return scalar a = `alpha'
	           return scalar b = `beta'
		}
		else if "`e(mu)'`e(phi)'" != ""  {
			local alpha = invlogit( e(mu))*exp(e(ln_phi))
			local beta  = invlogit(-e(mu))*exp(e(ln_phi))
			qui gen `theor' = sqrt(betaden(`alpha',`beta',`x')*`nobs'*`w')
			local grden "betaden(`alpha',`beta',x)"
			return local gr "function y = `minus'sqrt(`nobs'*`w'*(`grden')), range(`min' `max')"
			return scalar a = `alpha'
			return scalar b = `beta'
		}
		else if "`e(cmd)'" == "zoib" & `withx' == 0 {
			local alpha = invlogit( [proportion]_b[_cons])*exp([ln_phi]_b[_cons])
			local beta  = invlogit(-[proportion]_b[_cons])*exp([ln_phi]_b[_cons])
			qui gen `theor' = sqrt(betaden(`alpha',`beta',`x')*`nobs'*`w')
			local grden "betaden(`alpha',`beta',x)"
			return local gr "function y = `minus'sqrt(`nobs'*`w'*(`grden')), range(`min' `max')"
			return scalar a = `alpha'
			return scalar b = `beta'
		}
		else {
			tempvar alpha beta partden 
			if "`e(cmd)'" != "zoib" {
				qui predict double `alpha' if `touse', alpha
				qui predict double `beta' if `touse', beta
			}
			else {
				tempvar xb1 xb2
				qui predict double `xb1', xb eq(#1)
				qui predict double `xb2', xb eq(#2)
				qui gen double `alpha' = invlogit( `xb1')*exp(`xb2')
				qui gen double `beta'  = invlogit(-`xb1')*exp(`xb2')
				drop `xb1' `xb2'
			}
			qui gen `partden' = .
			qui gen `grden' = .
			qui count if `xwx' < .
			forvalues i = 1/`r(N)' {
				qui replace `partden' = betaden(`alpha',`beta',`xwx'[`i']) if `touse'
				sum `partden' if `touse' `wght', meanonly
				qui replace `grden' = r(mean) in `i'
			}
			qui gen `theor' = sqrt(`nobs'*`w'*(`grden'))
			qui replace `grden' = `minus'`theor'
			return local gr "line `grden' `xwx' if `xwx' > 0 & `xwx' < 1, sort"
		}
	}
	else {
		qui sum `varlist' if `touse' `wght'
		local alpha = r(mean)*((r(mean)*(1-r(mean)))/(r(Var))-1)
		local beta = (1-r(mean))*((r(mean)*(1-r(mean)))/(r(Var))-1)
		qui gen `theor' = sqrt(betaden(`alpha',`beta',`x')*`nobs'*`w')
		local grden "betaden(`alpha',`beta',x)"
		return local gr "function y = `minus'sqrt(`nobs'*`w'*(`grden')), range(`min' `max')"
		return scalar a = `alpha'
		return scalar b = `beta'
	}
	
end
