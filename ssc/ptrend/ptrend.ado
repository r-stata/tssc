*! version 2.0.0 PR 27oct2014
program define ptrend, rclass /* chisq for trend */
	version 8.0
	syntax varlist(min=3 max=4 numeric) [if] [in]
	tokenize `varlist'
	local r `1'
	local nr `2'
	local x `3'
	local p `4'
	tempvar n pr touse
	quietly {
		marksample touse
		count if `touse'
		local rows = r(N)
		if (`rows' < 2) error 2001
		local r1 = `rows'-1
		gen long `n' = `r'+`nr' if `touse'
		if "`p'"=="" {
			local p "_prop"
			cap drop `p'
			gen `p' = `r'/`n'
			format `p' %8.3f
		}
/*
	Do regression for trend using binomial weights n for p = r/n.
	R = sum(r), N = sum(n) = sum(weights), P = R/N.

	Formula for chisq for trend adapted from that in TREND.MTB, needing
	some careful algebra and calculation of the weighted SSQ of x.
*/
		sum `r' if `touse'
		local R = r(mean)*`rows'
		sum `n'
		local N = r(mean)*`rows'
		local P = `R'/`N'
		sum `x' if `touse' [weight=`n']
		local ssx = `N'*r(Var)*(`r1')/`rows'
		regress `p' `x' [weight=`n']
		local b2 = _b[`x']^2
		local chitr = `b2'*`ssx'/(`P'*(1-`P'))
		local se = sqrt(`b2'/`chitr')
/*
	Ordinary chisquare
*/
		gen `pr' = sum(`p'*`r')
		local chisq = (`pr'[_N]-`R'*`P')/(`P'*(1-`P'))
		local chidep = `chisq' - `chitr'
		local dfdep = `rows'-2
	}
	list `r' `nr' `p' `x' if `touse'
	#delimit ;
	di as txt _n "Trend analysis for proportions" _n "{hline 30}" _n ;
	di as txt "Regression of p = " as res "`r'" as txt "/("
	 as res "`r'" as txt "+"
	 as res "`nr'" as txt ") on " as res "`x'" as txt ":" _n ;
	di as txt "Slope = " as res %7.0g _b[`x']
	 as txt ", std. error = " as res %7.0g `se'
	 as txt ", Z = " as res %7.3f sqrt(`chitr') ;
	di as txt _n "Overall chi2(" as res `rows'-1 as txt ") = " _col(27)
	 %7.3f as res `chisq' as txt ",  pr>chi2 = "
	 %6.4f as res chiprob(`r1', `chisq');
	di as txt "Chi2(" as res 1 as txt ") for trend = " _col(27)
	 %7.3f as res `chitr' as txt ",  pr>chi2 = "
	 %6.4f as res chiprob(1, `chitr') ;
	di as txt "Chi2(" as res `dfdep' as txt ") for departure = " _col(27)
	 %7.3f as res `chidep' as txt ",  pr>chi2 = "
	 %6.4f as res chiprob(`dfdep', `chidep') ;
	#delimit cr
	return scalar slope = _b[`x']
	return scalar se = `se'
	return scalar chi2trend = `chitr'
	return scalar chi2overall = `chisq'
	return scalar chi2dep = `chidep'
	return scalar dfdep = `dfdep'
	return scalar Pdep = chiprob(`dfdep', `chidep')
end
