program mimic_e2
	version 9
	args todo b lnf g H g1 g2 g3 g4 g5
	tempvar unconstrained lambda constrained theta lj
	tempname ln_sigma_y ln_sigma_l
	mleval `unconstrained' = `b', eq(1)
	mleval `constrained'   = `b', eq(2)
	mleval `lambda'        = `b', eq(3)
	mleval `ln_sigma_y'    = `b', eq(4) scalar
	mleval `ln_sigma_l'    = `b', eq(5) scalar
	tempname sigma_y sigma_l 
	scalar `sigma_l' = exp(`ln_sigma_l')
	scalar `sigma_y' = exp(`ln_sigma_y')
	quietly{
		tempvar sigma
		gen double `sigma' = sqrt(`sigma_y'^2 + `lambda'^2*`sigma_l'^2)
		gen double `theta' = `unconstrained' + (`lambda'*`constrained')
		gen double `lj' = ln(normalden($ML_y1,`theta',`sigma'))
		mlsum `lnf' = `lj'
	
		if(`todo'==0 | `lnf' >= .) exit
	
		tempvar z
		tempname du dc dl dln_sy dln_sl
		gen double `z' = ($ML_y1 - `theta')/`sigma'
		replace `g1' = `z'/`sigma'
		replace `g2' = `lambda'*`z'/`sigma'
		replace `g3' = ((`z'^2-1)*`sigma_l'^2*`lambda' + `constrained'*`z'*`sigma')/`sigma'^2
		replace `g4' = ((`z'*`z'-1)*`sigma_y'^2)/`sigma'^2
		replace `g5' = ((`z'*`z'-1)*`sigma_l'^2*`lambda'^2)/`sigma'^2

		mlvecsum `lnf' `du'    = `g1', eq(1)
		mlvecsum `lnf' `dc'    = `g2', eq(2)
		mlvecsum `lnf' `dl'    = `g3', eq(3)
		mlvecsum `lnf' `dln_sy' = `g4', eq(4)
		mlvecsum `lnf' `dln_sl' = `g5', eq(5)
		matrix `g' = (`du', `dc', `dl', `dln_sy', `dln_sl')
		if (`todo'==1 | `lnf'>=.) exit
		
		tempname d11 d22 d33 d44 d55 d12 d13 d14 d15 d23 d24 d25 d34 d35 d45
		mlmatsum `lnf' `d11' = 1/`sigma'^2                                   , eq(1)
		mlmatsum `lnf' `d22' = `lambda'^2/`sigma'^2                        , eq(2)
		mlmatsum `lnf' `d33' = -(((1-2*`z'^2)*2*`sigma_l'^4*`lambda'^2)/`sigma'^4 + ///
		                       (`sigma_l'^2*`z'^2 - `sigma_l'^2 - `constrained'^2)/`sigma'^2 - ///
							   (4*`sigma_l'^2*`lambda'*`constrained'*`z')/`sigma'^3)  , eq(3)
		mlmatsum `lnf' `d44' = -((2*`sigma_y'^4*(1-2*`z'^2))/`sigma'^4 +   ///
		                       (2*`sigma_y'^2*(`z'^2-1))/`sigma'^2 )           , eq(4)
		mlmatsum `lnf' `d55' = -((2*`sigma_l'^4*`lambda'^4*(1-2*`z'^2))/`sigma'^4 + ///
		                       (2*`sigma_l'^2*`lambda'^2*(`z'^2-1))/`sigma'^2) , eq(5)
		mlmatsum `lnf' `d12' = `lambda'/`sigma'^2                            , eq(1,2)
		mlmatsum `lnf' `d13' = -(-`constrained'/`sigma'^2 - ///
		                       (2*`sigma_l'^2*`lambda'*`z')/`sigma'^3)         , eq(1,3)
		mlmatsum `lnf' `d14' = 2*`sigma_y'^2*`z'/`sigma'^3                   , eq(1,4)
		mlmatsum `lnf' `d15' = 2*`sigma_l'^2*`lambda'^2*`z'/`sigma'^3        , eq(1,5)
		mlmatsum `lnf' `d23' = -(`z'/`sigma' - `constrained'*`lambda'/`sigma'^2 - ///
		                        2*`sigma_l'^2*`lambda'^2*`z'/`sigma'^3)        , eq(2,3)
		mlmatsum `lnf' `d24' = 2*`z'*`lambda'*`sigma_y'^2/`sigma'^3          , eq(2,4)
		mlmatsum `lnf' `d25' = 2*`z'*`lambda'^3*`sigma_l'^2/`sigma'^3        , eq(2,5)
		mlmatsum `lnf' `d34' = -(-2*`z'*`constrained'*`sigma_y'^2/`sigma'^3 + ///
		                       2*`sigma_y'^2*`sigma_l'^2*`lambda'*(1-2*`z'^2) / `sigma'^4), eq(3,4)
		mlmatsum `lnf' `d35' = -(2*`sigma_l'^4*`lambda'^3*(1-2*`z'^2)/`sigma'^4 + ///
		                       2*`sigma_l'^2*`lambda'*(`z'^2-1)/`sigma'^2 - ///
							   2*`constrained'*`sigma_l'^2*`lambda'^2*`z'/`sigma'^3), eq(3,5)
		mlmatsum `lnf' `d45' = -(2*`sigma_y'^2*`sigma_l'^2*`lambda'^2*(1-2*`z'^2)/`sigma'^4), eq(4,5)
		matrix `H' = (`d11' , `d12' , `d13' , `d14' , `d15' \ ///
					  `d12'', `d22' , `d23' , `d24' , `d25' \ ///
					  `d13'', `d23'', `d33' , `d34' , `d35' \ ///
					  `d14'', `d24'', `d34'', `d44' , `d45' \ ///
					  `d15'', `d25'', `d35'', `d45'', `d55' )
	}
end
