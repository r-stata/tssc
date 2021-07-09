*! version 2.1.1 Stephen P. Jenkins September 2004

program define pgmhaz8_ll

	version 8.2

	args todo b lnf

	tempvar I lnvarg sum sum1 sum2 last lnfi
	tempname bcoef v lnvar


	mleval `I' = `b'
	mleval `lnvarg' = `b', scalar eq(2)

	quietly {

		scalar `v' = exp(`lnvarg')

		by $S_E_id: gen double `sum' = sum(`v'*exp(`I')) 
		by $S_E_id: gen double `sum1' = `sum'[_N] if _n==_N
		by $S_E_id: gen double `sum2' = `sum'[_N-1] if _n==_N
		by $S_E_id: replace `sum2' = 0 if _N == 1 
		by $S_E_id: gen byte `last' = (_n==_N)

		gen double `lnfi' = cond(!`last',0,	///
				$ML_y1*ln( (1+`sum2')^(-1/`v') - (1+`sum1')^(-1/`v') ) +  ///
				(1-$ML_y1)*-ln(1+`sum1')/`v')
		mlsum `lnf' = `lnfi'



	}

end

