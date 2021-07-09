*! version 1.5.0 12Aug2011 MLB
program define hangr_gev, rclass sortpreserve
	syntax varname [if] [fweight /] ,  ///
	x(string) nobs(real) nbins(real) w(real) min(real) max(real) theor(string) ///
	[ par(numlist) suspended XXfit(integer 0) withx(integer 0) xwx(varname) grden(string) ]
	
	if "`suspended'" != "" local minus "-"
	if "`weight'" != "" local wght "[`weight' = `exp']"
	marksample touse

	if "`par'" == "" {
		if `xxfit' & `withx' == 0  {
			local loc = `e(blocation)'
			local scale = `e(bscale)'
			local shape = `e(bshape)'
			qui gen `theor' = sqrt(( ///
			1/`scale' * (1+`shape'*((`x'-`loc')/`scale'))^(-1-1/`shape')* ///
			exp(-1*(1+`shape'*((`x'-`loc')/`scale'))^(-1/`shape')) ///
			)*`nobs'*`w')
			local grden "1/`scale'*(1+`shape'*((x-`loc')/`scale'))^(-1-1/`shape')*exp(-1*(1+`shape'*((x-`loc')/`scale'))^(-1/`shape'))"
			return local gr "function y = `minus'sqrt(`nobs'*`w'*(`grden')), range(`min' `max')"
			return scalar a = `loc'
			return scalar b = `scale'
			return scalar c = `shape'
		}
		else  {
			tempvar loc scale shape partden 
			qui predict double `scale' if `touse', eq(#1)
			qui predict double `shape' if `touse', eq(#2)
			qui predict double `loc' if `touse', eq(#3)
			qui gen `partden' = .
			qui gen `grden' = .
			qui count if `xwx' < .
			forvalues i = 1/`r(N)' {
				qui replace `partden' = 1/`scale'*(1+`shape'*((`xwx'[`i']-`loc')/`scale'))^(-1-1/`shape')*exp(-1*(1+`shape'*((`xwx'[`i']-`loc')/`scale'))^(-1/`shape')) if `touse'
				sum `partden' if `touse' `wght' , meanonly
				qui replace `grden' = r(mean) in `i'
			}
			qui gen `theor' = sqrt(`nobs'*`w'*(`grden'))
			qui replace `grden' = `minus'`theor'
			return local gr "line `grden' `xwx', sort"		
		}
	}
	else {
		local loc : word 1 of `par'
		local scale : word 2 of `par'
		local shape : word 3 of `par'
		qui gen `theor' = sqrt(( ///
		1/`scale' * (1+`shape'*((`x'-`loc')/`scale'))^(-1-1/`shape')* ///
		exp(-1*(1+`shape'*((`x'-`loc')/`scale'))^(-1/`shape')) ///
		)*`nobs'*`w')
		local grden "1/`scale'*(1+`shape'*((x-`loc')/`scale'))^(-1-1/`shape')*exp(-1*(1+`shape'*((x-`loc')/`scale'))^(-1/`shape'))"
		return local gr "function y = `minus'sqrt(`nobs'*`w'*(`grden')), range(`min' `max')"
		return scalar a = `loc'
		return scalar b = `scale'
		return scalar c = `shape'
	}
end
