*! 2.1.0 NJC 22 Aug 2006
* 2.0.0 NJC 3 Aug 2004
* 1.0.0 NJC 26 Nov 1996
program sdline, rclass
	version 8   
	syntax varlist(numeric min=2 max=2) [if] [in] ///
	[, GENerate(str) SORT NOGRAPH PLOT(str asis) ADDPLOT(str asis) * ]

	quietly { 
		marksample touse 
		count if `touse' 
		if r(N) == 0 error 2000 
		if r(N) == 1 error 2001 
		local N = r(N) 

		tokenize `varlist' 
		args y x 
		tempvar ysdl
		tempname meany meanx sdy sdx slope 

		corr `y' `x' if `touse'
		local sign = sign(r(rho))
		
		su `y' if `touse'
		scalar `meany' = r(mean)
		scalar `sdy' = r(sd)
		su `x' if `touse' 
		scalar `meanx' = r(mean)
		scalar `sdx' = r(sd)
		scalar `slope' = `sign' * (`sdy' / `sdx')
		gen `ysdl' = `meany' +  `slope' * (`x' - `meanx') if `touse' 

		local yttl `"`: variable label `y''"'
		if `"`yttl'"' == "" local yttl "`y'" 

		label var `ysdl' "SD line" 
	} 	

	di 
	di as txt "Slope:     " as res %9.3f `slope'  
	di as txt "Intercept: " as res %9.3f `meany' - `meanx' * `slope' 

	if "`nograph'" == "" {
		twoway scatter `y' `ysdl' `x' `if' `in', ///
		ms(oh none) connect(none l) sort yti(`"`yttl'"') `options' ///
		|| `plot'   ///
		|| `addplot' 
	}

	if "`generate'" != "" {
		confirm new variable `generate'
		gen `generate' = `ysdl' `if' `in'
	}

	return scalar N     = `N'
	return scalar ymean =  `meany'
	return scalar ysd   = `sdy'
	return scalar xmean = `meanx'
	return scalar xsd   = `sdx'
	return scalar slope = `slope'
end
