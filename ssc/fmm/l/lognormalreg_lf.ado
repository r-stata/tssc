*! version 2.1.0 12feb2012
*! author: Partha Deb
* version 1.0.0 05sep2011

program lognormalreg_lf
	version 9.2

	args todo b lnf g negH g1 g2

	tempname xb lnsigma sigma

	mleval `xb' = `b', eq(1)
	mleval `lnsigma' = `b', eq(2)

	quietly {
		gen double `sigma' = exp(`lnsigma')
		mlsum `lnf' = lnnormalden(ln($ML_y),`xb',`sigma') - ln($ML_y)

		tempvar z
		tempname dxb dlnsigma
		gen double `z' = (ln($ML_y)-`xb')/`sigma'
		replace `g1' = `z'/`sigma'
		replace `g2' = `z'*`z'-1
		mlvecsum `lnf' `dxb' = `g1'		, eq(1)
		mlvecsum `lnf' `dlnsigma' = `g2'	, eq(2)
		matrix `g' = (`dxb', `dlnsigma')

		tempname d11 d12 d22
		mlmatsum `lnf' `d11' = 1/`sigma'^2	, eq(1)
		mlmatsum `lnf' `d12' = 2*`z'/`sigma'	, eq(1,2)
		mlmatsum `lnf' `d22' = 2*`z'*`z'	, eq(2)
		matrix `negH' = (`d11', `d12' \ `d12'', `d22')
	}

end
