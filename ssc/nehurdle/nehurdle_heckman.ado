*! nehurdle_heckman v1.1.0
*! 29 June 2017
*! Alfonso Sanchez-Penalver
*! Version history at the bottom.

/*******************************************************************************
*	ML lf evaluator for linear and exponential Type II Tobit models, with	   *
*	homoskedastic selection errors.											   *
*******************************************************************************/

capture program drop nehurdle_heckman
program define nehurdle_heckman
	version 11
	args todo b lnfj g1 g2 g3 g4 H
	
	quietly {
		// Evaluate the parameters for each equation
		tempvar zg xb lnsval athrho
		mleval `zg' = `b', eq(1)
		mleval `xb' = `b', eq(2)
		mleval `lnsval' = `b', eq(3)
		mleval `athrho' = `b', eq(4)
		// Transform parametrized values to make equations easier to read
		tempvar sval rho zval rtrho hge
		gen double `sval' = exp(`lnsval')
		gen double `rho' = tanh(`athrho')
		gen double `zval' = ($ML_y2 - `xb') / `sval'
		gen double `rtrho' = sqrt(1 - `rho'^2)
		gen double `hge' = (`zg' + `rho' * `zval') / `rtrho'
		
		
		// Log-Likelihood
		replace `lnfj' = lnnormal(-`zg') if $ML_y1 == 0
		replace `lnfj' = lnnormal(`hge') + lnnormalden(`zval') - `lnsval'		///
			if $ML_y1 == 1
		// The global macro neh_method is set in nehurdle.ado and tells us whether
		// we want a linear or exponential specification of the value function
		if "$neh_method" == "exponential"										///
			replace `lnfj' = `lnfj' - $ML_y2 if $ML_y1 == 1
		
		if (`todo' == 0) exit
		
		// Variables to make programming gradient and hessian easier
		tempvar nlamzi lamhge
		gen double `nlamzi' = normalden(`zg') / normal(- `zg')
		gen double `lamhge' = normalden(`hge') / normal(`hge')
		
		// Gradient
		// g1 (zg)
		replace `g1' = - `nlamzi' if $ML_y1 == 0
		replace `g1' = `lamhge' / `rtrho' if $ML_y1 == 1
		
		// g2 (xb)
		replace `g2' = 0 if $ML_y1 == 0
		replace `g2' = `sval'^(-1) * (`zval' - `rho' / `rtrho' * `lamhge') if	///
			$ML_y1 == 1
		
		// g3 (lnsval)
		replace `g3' = 0 if $ML_y1 == 0
		replace `g3' = `zval' * (`zval' - `rho' / `rtrho' * `lamhge') - 1 if	///
			$ML_y1 == 1
		
		// g4 (athrho)
		replace `g4' = 0 if $ML_y1 == 0
		replace `g4' = `lamhge' * `rtrho' * (`zval' + `rho' / `rtrho' * `hge')	///
			if $ML_y1 == 1
		
		if (`todo' == 1) exit
		
		// Hessian
		// The Hessian is 4 x 4
		tempvar d11 d12 d13 d14 d22 d23 d24 d33 d34 d44
		tempname h11 h12 h13 h14 h22 h23 h24 h33 h34 h44
		
		// h11 (zg zg)
		gen double `d11' = `nlamzi' * (`zg' - `nlamzi') if $ML_y1 == 0
		replace `d11' = - `lamhge' / (1 - `rho'^2) * (`hge' + `lamhge') if		///
			$ML_y1 == 1
		mlmatsum `lnfj' `h11' = `d11', eq(1)
		
		// h12 (zg xb)
		gen double `d12' = 0 if $ML_y1 == 0
		replace `d12' = `rho' / `sval' * `lamhge' / (1 - `rho'^2) * (`hge' +	///
			`lamhge') if $ML_y1 == 1
		mlmatsum `lnfj' `h12' = `d12', eq(1,2)
		
		// h13 (zg lnsval)
		gen double `d13' = 0 if $ML_y1 == 0
		replace `d13' = `rho' / (1 - `rho'^2) * `lamhge' * `zval' * (`hge' +	///
			`lamhge') if $ML_y1 == 1
		mlmatsum `lnfj' `h13' = `d13', eq(1,3)
		
		// h14 (zg athrho)
		gen double `d14' = 0 if $ML_y1 == 0
		replace `d14' = `lamhge' * (`rho' / `rtrho' - (`hge' + `lamhge') *		///
			(`zval' + `rho' / `rtrho' * `hge')) if $ML_y1 == 1
		mlmatsum `lnfj' `h14' = `d14', eq(1,4)
		
		// h22 (xb xb)
		gen double `d22' = 0 if $ML_y1 == 0
		replace `d22' = - `sval'^(-2) * (1 + (`rho' / `rtrho')^2 * `lamhge' *	///
			(`hge' + `lamhge')) if $ML_y1 == 1
		mlmatsum `lnfj' `h22' = `d22', eq(2)
		
		// h23 (xb lnsval)
		gen double `d23' = 0 if $ML_y1 == 0
		replace `d23' = `sval'^(-1) * (`rho' / `rtrho' * `lamhge' * (1 - `rho'	///
		 	/ `rtrho' * `zval' * (`hge' + `lamhge')) - 2 * `zval') if $ML_y1 == 1
		mlmatsum `lnfj' `h23' = `d23', eq(2,3)
		
		// h24 (xb athrho)
		gen double `d24' = 0 if $ML_y1 == 0
		replace `d24' = `lamhge' / `sval' * `rtrho' * (`rho' / `rtrho' * 		///
			((`hge' + `lamhge') * (`zval' + `rho' / `rtrho' * `hge') - `rho' /	///
			`rtrho') - 1) if $ML_y1 == 1
		mlmatsum `lnfj' `h24' = `d24', eq(2,4)
		
		// h33 (lnsval lnsval)
		gen double `d33' = 0 if $ML_y1 == 0
		replace `d33' = `zval' * (`rho' / `rtrho' * `lamhge' * (1 - `rho' /		///
			`rtrho' * `zval' * (`hge' + `lamhge')) - 2 * `zval') if $ML_y1 == 1
		mlmatsum `lnfj' `h33' = `d33', eq(3)
		
		// h34 (lnsval athrho)
		gen double `d34' = 0 if $ML_y1 == 0
		replace `d34' = `zval' * `lamhge' * `rtrho'* (`rho' / `rtrho' *  		///
			((`hge' + `lamhge') * (`zval' + `rho' / `rtrho' * `hge') - `rho' /	///
			`rtrho') - 1) if $ML_y1 == 1
		mlmatsum `lnfj' `h34' = `d34', eq(3,4)
		
		// h44 (athrho athrho)
		gen double `d44' = 0 if $ML_y1 == 0
		replace `d44' = `lamhge' * (1 - `rho'^2) * ((1 + `rho'^2 / (1 -			///
			`rho'^2)) *	`hge' - (`hge' + `lamhge') * (`zval' + `rho' /			///
			`rtrho' * `hge')^2) if $ML_y1 == 1
		mlmatsum `lnfj' `h44' = `d44', eq(4)
		
		// Compose the Hessian
		mat `H' =		(`h11',`h12',`h13',`h14')
		mat `H' = `H' \ ((`h12')',`h22',`h23',`h24')
		mat `H' = `H' \ ((`h13')',(`h23')',`h33',`h34')
		mat `H' = `H' \ ((`h14')',(`h24')',(`h34')',`h44')
	}
end

// Version 1.0.0 is an lf evaluator for the linear model with homoskedastic
//		selection errors
// Version 1.1.0 is an lf2 evaluator (adding analytical gradient and hessian)
//		for both linear and exponential models with homoskedastic selection
//		errors
