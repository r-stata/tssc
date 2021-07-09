* ************************************************************************************* *
*                                                                                       *
*   regoprob_llc                                                                        *
*   Version 1.0.3 - last revised September 05, 2006                                     *
*                                                                                       *
*   Author: Stefan Boes, boes@sts.unizh.ch                                              *
*                                                                                       *
*   Version 1.0    - initial version                                                    *
*   Version 1.0.1  - revision of help file and predict command                          *
*   Version 1.0.2  - score option deleted                                               *
*   Version 1.0.3  - problems in the predicted probabilities fixed                      *
*   Version 1.0.4  - problems when using mfx fixed, revision of help file               *
*                                                                                       *
* ************************************************************************************* *
*                                                                                       *
*                                                                                       *
*   regoprob is a user-written procedure to estimate random effects generalized         *
*   ordered probit models in Stata. It is a rewritten version of goprobit for panel     *
*   data that assumes normally distributed error terms and individually specific        *
*   effects. The likelihood for each unit is approximated by Gauss-Hermite quadrature.  *
*                                                                                       *
*   This is the subroutine providing the log-likelihood function and the score          *
*   for the constant-only model.                                                        *
*                                                                                       *
* ************************************************************************************* *



program define regoprob_llc
	version 8
	args todo b lnf g


	* Read out the equations from parameter vector ************************************ *
	forval ind = 1/$S_Numeqs {
		tempvar xb`ind'
		mleval `xb`ind'' = `b', eq(`ind')
	}
	tempvar rho
	local Numeqsp = $S_Numeqs + 1
	local Numeqsm = $S_Numeqs - 1
	mleval `rho' = `b', eq(`Numeqsp') scalar


	* Define everything needed for the Gauss-Hermite quadrature *********************** *
	tempvar s2su
	scalar `s2su' = sqrt(2*`rho'/(1 - `rho'))

	tempvar lit prodlit li
	quietly gen double `lit' = .
	quietly gen double `prodlit' = .
	quietly by $S_i: gen double `li' = cond(_n==_N,0,.)

	tempvar lit1 lit2 litr gradb1 gradb2 gradr
	quietly gen double `lit1' = .
	quietly gen double `lit2' = .
	quietly gen double `litr' = .
	quietly gen double `gradb1' = 0
	quietly gen double `gradb2' = 0
	quietly gen double `gradr' = 0

	tempname ab we u


	* Gauss-Hermite quadrature ******************************************************** *
	forval m = 1/$S_quad {

		scalar `ab' = $S_ab[1,`m']
		scalar `we' = $S_we[1,`m']
		scalar `u' = `s2su'*`ab'


		* Calculate individual likelihood contribution ******************************** *
		local fj "cond($ML_y1 == $dv_1, norm(-`xb1'-`u')"

		forval ind = 2/$S_Numeqs {
			local indd = `ind' - 1
			local fj "`fj', cond($ML_y1 == ${dv_`ind'}, norm(-`xb`ind''-`u') - norm(-`xb`indd''-`u')"
		}
		local fj "`fj', 1 - norm(-`xb$S_Numeqs'-`u') )"

		forval ind = 2/$S_Numeqs {
			local fj "`fj')"
		}

		quietly replace `lit' = `fj'
		quietly replace `lit' = 0.00000001 if `lit' == 0
		quietly by $S_i: replace `prodlit' = cond(_n==1, `lit', `lit'*`prodlit'[_n-1])
		quietly replace `li' = `li' + `we'*`prodlit'/sqrt(_pi)


		* The derivatives ************************************************************* *
		local db1 "cond($ML_y1 == $dv_1, 0"
		local db2 "cond($ML_y1 == $dv_1, -normden(-`xb1'-`u')"

		forval ind = 2/$S_Numeqs {
			local indd = `ind' - 1
			local db1 "`db1', cond($ML_y1 == ${dv_`ind'},  normden(-`xb`indd''-`u')"
			local db2 "`db2', cond($ML_y1 == ${dv_`ind'}, -normden(-`xb`ind''-`u')"
		}
		local db1 "`db1', normden(-`xb$S_Numeqs'-`u') ) "
		local db2 "`db2', 0 )"

		forval ind = 2/$S_Numeqs {
			local db1 "`db1')"
			local db2 "`db2')"
		}

		quietly by $S_i: replace `lit1' = `db1'*`prodlit'[_N]/`lit'
		quietly by $S_i: replace `lit2' = `db2'*`prodlit'[_N]/`lit'
		quietly by $S_i: replace `litr' = (`db1'+`db2')*`prodlit'[_N]/`lit'

		quietly replace `gradb1' = `gradb1' + `we'*`lit1'/sqrt(_pi)
		quietly replace `gradb2' = `gradb2' + `we'*`lit2'/sqrt(_pi)
		quietly replace `gradr' = `gradr' + `we'*`u'*`litr'/sqrt(_pi)

	}


	* Calculate the value of the log-likelihood *************************************** *
	mlsum `lnf' = ln(`li') if `li' !=.


	* Indicator for d0/d1 evaluator *************************************************** *
	if `todo' == 0 | `lnf' == . {
		exit
	}


	* Calculate score vector ********************************************************** *
	quietly by $S_i: replace `li' = `li'[_N]

	quietly replace `gradb1' = `gradb1'/`li'
	quietly replace `gradb2' = `gradb2'/`li'

	forval ind = 1/$S_Numeqs {
		tempname g`ind'
		tempname g1`ind'
		tempname g2`ind'
	}

	matrix vecaccum `g11' = `gradb2' if $ML_y1 == $dv_1
	matrix vecaccum `g21' = `gradb1' if $ML_y1 == $dv_2
	matrix `g1' = `g11' + `g21'
	matrix `g' = `g1'

	forval ind = 2/$S_Numeqs {
		local indd = `ind' + 1
		matrix vecaccum `g1`ind'' = `gradb2' if $ML_y1 == ${dv_`ind'}
		matrix vecaccum `g2`ind'' = `gradb1' if $ML_y1 == ${dv_`indd'}
		matrix `g`ind'' = `g1`ind'' + `g2`ind''
		matrix `g' = `g', `g`ind''
	}

	quietly replace `gradr' = sum(`gradr'/`li')
	tempname gr
	scalar `gr' = `gradr'[_N]/(2*`rho'*(1-`rho'))
	matrix `g' = `g', `gr'

end
