program define xsampsi
*version 1.0 Jan Brogger, Jan 31st 2002
*This program will compute
*sample size according to senn, 1991, p. 217
	version 7.0
	syntax , alpha(real) beta(real) delta(real) stddev(real) [ n(numlist) ]

	di as text "Sample size for cross-over trial (AB/BA)"
	di "according to Senn 1991:  'Cross-over trials in clinical research'" 
	di "Parameters below expressed in terms of the basic estimator, the treatment contrast." _n _dup(15) "-" _n

	di as text "Alpha level" _col(15) " = " as inp %4.3f `alpha' _col(25) as text "Power" _col(35) " = " as inp %4.3f (1-`beta')
	local zalpha=invnorm(1-(`alpha' / 2))
	local zbeta=invnorm(1-`beta')
	di as text "Zalpha  " _col(15) " = " as res %4.3f `zalpha' _col(25) as text "Zbeta " _col(35) " = " as res %4.3f `zbeta'

	di _n as text "Detectable effect size" _col(35) " = " as inp %4.3f `delta' 
	di as text "Std.dev. of basic estimator" _col(35) " = " as inp %4.3f `stddev'

	
	local napprox = ((`zalpha'+`zbeta')^2)*((`stddev'/`delta')^2)
	local napprox=int(`napprox')+1
	di _n as text "Approximate N (normal) " _col(35) " = " as res %4.0f `napprox'

	local tdegfree=`napprox'-2
	local tcritical=invttail(`tdegfree',`alpha'/2)
	di as text "Critical value of t(df=" as res `tdegfree' as text "," as res %4.3f `alpha'/2 as text ")" _col(35) " = " as res %4.3f `tcritical'

	local noncent = sqrt(`napprox')*(`delta'/`stddev')
	di as text "Noncentrality parameter of t" _col(35) " = " as res %4.3f `noncent'

	cap nctprob `tcritical' `noncent' `tdegfree'
	if _rc~=0 {
		di as err "Need to install package 'nct' to compute non-central t distribution"
		error 999
	}

	local power = 1-`r(p)'
	di as text "Power given approximate N above " _col(35) " = " as res %4.3f `power'

	if "`n'"=="" {
		di as text _n "(specify other sample sizes in paramter " as inp "n(numlist)" as text " to get power for other sample sizes)"
	}
	else {
		di _n as text "Sample size" _col(15) "Power"
		foreach sampsi of numlist `n' { 			local tdegfree=`sampsi'-2
			local tcritical=invttail(`tdegfree',`alpha'/2)
			local noncent = sqrt(`sampsi')*(`delta'/`stddev')

			qui nctprob `tcritical' `noncent' `tdegfree'
			local power = 1-`r(p)'
			di as res %4.0f `sampsi' _col(15) %4.3f `power'
		}
	}
	
end
