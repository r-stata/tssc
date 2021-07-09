*! version 1.6.0 MLB 06 Sep 2012
program define propcnspoisson_e2
	version 9
	args todo b lnf g H g1 g2 g3
	tempvar unconstrained lambda constrained theta lj 
	mleval `unconstrained' = `b', eq(1)
	mleval `constrained'   = `b', eq(2)
	mleval `lambda'        = `b', eq(3)
	
	quietly {
    	gen double `theta' = `unconstrained' + (`lambda'*`constrained')
		gen double `lj' = $ML_y1*`theta' - exp(`theta') - lngamma($ML_y1 +1)
		mlsum `lnf' = `lj'
		
		if (`todo'==0 | `lnf' >= .) exit
		
		tempname du dc dl
		replace `g1' = ($ML_y1 - exp(`theta'))
		replace `g2' = ($ML_y1 - exp(`theta'))*`lambda'
		replace `g3' = ($ML_y1 - exp(`theta'))*`constrained'
		
		mlvecsum `lnf' `du' = `g1', eq(1)
		mlvecsum `lnf' `dc' = `g2', eq(2)
		mlvecsum `lnf' `dl' = `g3', eq(3)
		matrix `g' = ( `du', `dc', `dl' )
		
		if (`todo' == 1 | `lnf' >= . ) exit
		
		tempname d11 d22 d33 d12 d13  d23 
		mlmatsum `lnf' `d11' = exp(`theta')                              , eq(1)
		mlmatsum `lnf' `d22' = exp(`theta')*`lambda'^2                   , eq(2)
		mlmatsum `lnf' `d33' = exp(`theta')*`constrained'^2              , eq(3)
		mlmatsum `lnf' `d12' = exp(`theta')*`lambda'                     , eq(1,2)
		mlmatsum `lnf' `d13' = exp(`theta')*`constrained'                , eq(1,3)
		mlmatsum `lnf' `d23' = exp(`theta')*`constrained'*`lambda' - `g1', eq(2,3)
		matrix `H' = (`d11' , `d12' , `d13' \ ///
					  `d12'', `d22' , `d23' \ ///
					  `d13'', `d23'', `d33'  )
	}
end
