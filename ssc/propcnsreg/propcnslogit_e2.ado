*! version 1.6.0 MLB 12Sep2012
program propcnslogit_e2
	version 9
	args todo b lnf g H g1 g2 g3 
	tempvar unconstrained lambda constrained theta lj
	mleval `unconstrained' = `b', eq(1)
	mleval `constrained'   = `b', eq(2)
	mleval `lambda'        = `b', eq(3)

	quietly{
		gen double `theta' = `unconstrained' + (`lambda'*`constrained')
		gen     double `lj' = invlogit( `theta') if $ML_y1 == 1
		replace  `lj' = invlogit(-`theta') if $ML_y1 == 0
		mlsum `lnf' = ln(`lj')
	
		if(`todo'==0 | `lnf' >= .) exit
	
		tempname du dc dl
		replace `g1' =  invlogit(-`theta') if $ML_y1 == 1
		replace `g1' = -invlogit( `theta') if $ML_y1 == 0
		replace `g2' =  invlogit(-`theta')*`lambda' if $ML_y1 == 1
		replace `g2' = -invlogit( `theta')*`lambda' if $ML_y1 == 0
		replace `g3' =  invlogit(-`theta')*`constrained' if $ML_y1 == 1
		replace `g3' = -invlogit( `theta')*`constrained' if $ML_y1 == 0

		mlvecsum `lnf' `du'    = `g1', eq(1)
		mlvecsum `lnf' `dc'    = `g2', eq(2)
		mlvecsum `lnf' `dl'    = `g3', eq(3)
		matrix `g' = (`du', `dc', `dl')
		if (`todo'==1 | `lnf'>=.) exit
		
		tempname d11 d22 d33 d12 d13  d23 
		mlmatsum `lnf' `d11' = abs(`g1')*`lj'                               , eq(1)
		mlmatsum `lnf' `d22' = `lambda'^2*abs(`g1')*`lj'                    , eq(2)
		mlmatsum `lnf' `d33' = `constrained'^2*abs(`g1')*`lj'               , eq(3)
		mlmatsum `lnf' `d12' = `lambda'*abs(`g1')*`lj'                      , eq(1,2)
		mlmatsum `lnf' `d13' = `constrained'*abs(`g1')*`lj'                 , eq(1,3)
		mlmatsum `lnf' `d23' = `constrained'*`lambda'*abs(`g1')*`lj' - `g1' , eq(2,3)
		matrix `H' = (`d11' , `d12' , `d13' \ ///
					  `d12'', `d22' , `d23' \ ///
					  `d13'', `d23'', `d33'  )
	}
end
