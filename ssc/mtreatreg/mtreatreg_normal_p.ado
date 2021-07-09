*! version 1.0.0  10mar2009
*! author: Partha Deb

version 10.1
program mtreatreg_normal_p

	syntax anything(id="newvarname") [if] [in] ///
		[, MU XB AT(string)]

	syntax newvarname [if] [in] [, * ]

	tempname b c k lambda rnd latf
	mat `b' = e(b)
	sca `c' = colsof(`b')
	sca `k' = `e(k_aux)'-1
	mat `lambda' = `b'[1,(`c'-`k'+1)..`c']
	if "`at'"=="" {
		mat `rnd' = J(1,`k',0)
	}
	else {
		mat `rnd' = `at'
	}
	sca `latf' = 0
	forvalues i = 1/`=`e(k_aux)'-1' {
		sca `latf' = `latf' + `lambda'[1,`i']*`rnd'[1,`i']
	}

	quietly _predict `typlist' `varlist' `if' `in', equation(`e(outcome)')

	if "`xb'"=="" {
		quietly replace `varlist' = `varlist' + `latf'
		label variable `varlist' "E(outcome)"
	}

	if "`xb'"=="xb" {
		label variable `varlist' "xb: outcome"
	}


end
