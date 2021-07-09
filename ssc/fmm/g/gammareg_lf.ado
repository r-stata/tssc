*! version 2.1.0 12feb2012
*! author: Partha Deb
* version 1.1.0 12jul2007
* version 1.0.0 21dec2006

program gammareg_lf
	version 9.2

	args todo b lnf g negH g1 g2

	tempname xb exb lnalpha alpha G1 G2 h11 h21 h22 H11 H21 H22 

	mleval `xb' = `b', eq(1)
	mleval `lnalpha' = `b', eq(2)

	quietly {
		gen double `exb' = exp(`xb')
		gen double `alpha' = exp(`lnalpha')

		mlsum `lnf' = ln(gammaden(`alpha',`exb',0,$ML_y))

		replace `g1' = -`alpha' + $ML_y/`exb'
		replace `g2' = (-digamma(`alpha') - `xb' + log($ML_y))*`alpha'

		mlvecsum `lnf' `G1' = `g1', eq(1)
		mlvecsum `lnf' `G2' = `g2', eq(2)
		matrix `g' = (`G1', `G2')

		gen double `h11' = - $ML_y/`exb'
		gen double `h21' = -`alpha'
		gen double `h22' = (-digamma(`alpha') - `xb' + log($ML_y) ///
			- trigamma(`alpha')*`alpha')*`alpha'

		mlmatsum `lnf' `H11' = -`h11', eq(1,1)
		mlmatsum `lnf' `H21' = -`h21', eq(2,1)
		mlmatsum `lnf' `H22' = -`h22', eq(2,2)
		matrix `negH' = (`H11',`H21'' \	///
										 `H21',`H22')
	}

end
