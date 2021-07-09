*! version 1.6.0 MLB 12sep2012
program propcnsreg_e2
	version 9
	args todo b lnf g H g1 g2 g3 g4
	tempvar unconstrained lambda constrained theta lj
	tempname ln_sigma
	mleval `unconstrained' = `b', eq(1)
	mleval `constrained'   = `b', eq(2)
	mleval `lambda'        = `b', eq(3)
	mleval `ln_sigma'      = `b', eq(4) scalar
	tempname sigma
	scalar `sigma' = exp(`ln_sigma')
	quietly{
		gen double `theta' = `unconstrained' + (`lambda'*`constrained')
		gen double `lj' = ln(normalden($ML_y1,`theta',`sigma'))
		mlsum `lnf' = `lj'
	
		if(`todo'==0 | `lnf' >= .) exit
	
		tempvar z
		tempname du dc dl dln_s
		gen double `z' = ($ML_y1 - `theta')/`sigma'
		replace `g1' = `z'/`sigma'
		replace `g2' = `lambda'*`z'/`sigma'
		replace `g3' = `constrained'*`z'/`sigma'
		replace `g4' = `z'*`z'-1

		mlvecsum `lnf' `du'    = `g1', eq(1)
		mlvecsum `lnf' `dc'    = `g2', eq(2)
		mlvecsum `lnf' `dl'    = `g3', eq(3)
		mlvecsum `lnf' `dln_s' = `g4', eq(4)
		matrix `g' = (`du', `dc', `dl', `dln_s')
		if (`todo'==1 | `lnf'>=.) exit
		
		tempname d11 d22 d33 d44 d12 d13 d14 d23 d24 d34
		mlmatsum `lnf' `d11' = 1/`sigma'^2                                   , eq(1)
		mlmatsum `lnf' `d22' = `lambda'^2*1/`sigma'^2                        , eq(2)
		mlmatsum `lnf' `d33' = `constrained'^2*1/`sigma'^2                   , eq(3)
		mlmatsum `lnf' `d44' = 2*`z'*`z'                                     , eq(4)
		mlmatsum `lnf' `d12' = `lambda'/`sigma'^2                            , eq(1,2)
		mlmatsum `lnf' `d13' = `constrained'/`sigma'^2                       , eq(1,3)
		mlmatsum `lnf' `d14' = 2*`z'/`sigma'                                 , eq(1,4)
		mlmatsum `lnf' `d23' = -(`z'/`sigma' - `constrained'*`lambda'/`sigma'^2) , eq(2,3)
		mlmatsum `lnf' `d24' = 2*`z'/`sigma'*`lambda'                        , eq(2,4)
		mlmatsum `lnf' `d34' = 2*`z'/`sigma'*`constrained'                   , eq(3,4)
		matrix `H' = (`d11' , `d12' , `d13' , `d14' \ ///
					  `d12'', `d22' , `d23' , `d24' \ ///
					  `d13'', `d23'', `d33' , `d34' \ ///
					  `d14'', `d24'', `d34'', `d44' )
	}
end
