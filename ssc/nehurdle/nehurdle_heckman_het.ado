*! nehurdle_heckman_het v1.1.0
*! 29 June 2018
*! Alfonso Sanchez-Penalver
*! Version history at the bottom.

/*******************************************************************************
*	ML lf evaluator for linear and exponential Type II Tobit models, with	   *
*	heteroskedastic selection errors.										   *
*******************************************************************************/

capture program drop nehurdle_heckman_het
program define nehurdle_heckman_het
	version 11
	// args lnfj zg xb ss lnsigma athrho
	args todo b lnfj g1 g2 g3 g4 g5 H
	
	quietly {
		// Evaluate the parameters for each equation
		tempvar zg xb lnssel lnsval athrho
		mleval `zg' = `b', eq(1)
		mleval `xb' = `b', eq(2)
		mleval `lnssel' = `b', eq(3)
		mleval `lnsval' = `b', eq(4)
		mleval `athrho' = `b', eq(5)
		// Transform parametrized values to make equations easier to program and read
		tempvar sval ssel rho zsel zval rtrho hge
		gen double `sval' = exp(`lnsval')
		gen double `ssel' = exp(`lnssel')
		gen double `rho' = tanh(`athrho')
		gen double `zsel' = `zg' / `ssel'
		gen double `zval' = ($ML_y2 - `xb') / `sval'
		gen double `rtrho' = sqrt(1 - `rho'^2)
		gen double `hge' = (`zsel' + `rho' * `zval') / `rtrho'
		
		// Log-Likelihood
		replace `lnfj' = lnnormal(- `zsel') if $ML_y1 == 0
		replace `lnfj' = lnnormal(`hge') + lnnormalden(`zval') - `lnsval'		///
			if $ML_y1 == 1
		// The global macro neh_method is set in nehurdle.ado and tells us whether
		// we want a linear or exponential specification of the value function
		if "$neh_method" == "exponential"										///
			replace `lnfj' = `lnfj' - $ML_y2 if $ML_y1 == 1
		
		if (`todo' == 0) exit
		
		// Variables to make programming gradient and hessian easier
		tempvar nlamzi lamhge
		gen double `nlamzi' = normalden(`zsel') / normal(- `zsel')
		gen double `lamhge' = normalden(`hge') / normal(`hge')
		
		// Gradient
		// g1 (zg)
		replace `g1' = - `ssel'^(-1) * `nlamzi' if $ML_y1 == 0
		replace `g1' = `lamhge' / (`ssel' * `rtrho') if $ML_y1 == 1
		
		// g2 (xb)
		replace `g2' = 0 if $ML_y1 == 0
		replace `g2' = `sval'^(-1) * (`zval' - `rho' / `rtrho' * `lamhge') if	///
			$ML_y1 == 1
		
		// g3 (lnssel)
		replace `g3' = `zsel' * `nlamzi' if $ML_y1 == 0
		replace `g3' = - `zsel' / `rtrho' * `lamhge' if $ML_y1 == 1
		
		// g4 (lnsval)
		replace `g4' = 0 if $ML_y1 == 0
		replace `g4' = `zval' * (`zval' - `rho' / `rtrho' * `lamhge') - 1 if	///
			$ML_y1 == 1
		
		// g5 (athrho)
		replace `g5' = 0 if $ML_y1 == 0
		replace `g5' = `lamhge' * `rtrho' * (`zval' + `rho' / `rtrho' * `hge')	///
			if $ML_y1 == 1
			
		if (`todo' == 1) exit
		
		// Hessian
		// The Hessian is 5 x 5
		tempvar d11 d12 d13 d14 d15 d22 d23 d24 d25 d33 d34 d35 d44 d45 d55
		tempname h11 h12 h13 h14 h15 h22 h23 h24 h25 h33 h34 h35 h44 h45 h55
		
		// Derivatives of g1 (zg)
		// h11 (zg zg)
		gen double `d11' = `ssel'^(-2) * `nlamzi'  * (`zsel' - `nlamzi') if		///
			$ML_y1 == 0
		replace `d11' = - `lamhge' / (`ssel' * `rtrho')^2 * (`hge' + `lamhge')	///
			if $ML_y1 == 1
		mlmatsum `lnfj' `h11' = `d11', eq(1)
		
		// h12 (zg xb)
		gen double `d12' = 0 if $ML_y1 == 0
		replace `d12' = `rho' / (`ssel' * `sval') * `lamhge' / (1 - `rho'^2) *	///
			(`hge' + `lamhge') if $ML_y1 == 1
		mlmatsum `lnfj' `h12' = `d12', eq(1,2)
		
		// h13 (zg lnssel)
		gen double `d13' = `ssel'^(-1) * `nlamzi' * (1 - `zsel' * (`zsel' -		///
			`nlamzi')) if $ML_y1 == 0
		replace `d13' = `lamhge' / (`ssel' * `rtrho') * (`zsel' / `rtrho' *		///
			(`hge' + `lamhge') - 1) if $ML_y1 == 1
		mlmatsum `lnfj' `h13' = `d13', eq(1,3)
		
		// h14 (zg lnsval)
		gen double `d14' = 0 if $ML_y1 == 0
		replace `d14' = `lamhge' / `ssel' * `rho' / (1 - `rho'^2) * `zval' *	///
			(`hge' + `lamhge') if $ML_y1 == 1
		mlmatsum `lnfj' `h14' = `d14', eq(1,4)
		
		// h15 (zg athrho)
		gen double `d15' = 0 if $ML_y1 == 0
		replace `d15' = `lamhge' / `ssel' * (`rho' / `rtrho' - (`hge' +			///
			`lamhge') * (`zval' + `rho' / `rtrho' * `hge')) if $ML_y1 == 1
		mlmatsum `lnfj' `h15' = `d15', eq(1,5)
		
		// Derivatives of g2 (xb)
		// h22 (xb xb)
		gen double `d22' = 0 if $ML_y1 == 0
		replace `d22' = - `sval'^(-2) * (1 + (`rho' / `rtrho')^2 * `lamhge' *	///
			(`hge' + `lamhge')) if $ML_y1 == 1
		mlmatsum `lnfj' `h22' = `d22', eq(2)
		
		// h23 (xb lnssel)
		gen double `d23' = 0 if $ML_y1 == 0
		replace `d23' = - `zsel' * `lamhge' / `sval' * `rho' / (1 - `rho'^2) *	///
			(`hge' + `lamhge') if $ML_y1 == 1
		mlmatsum `lnfj' `h23' = `d23', eq(2,3)
		
		// h24 (xb lnsval)
		gen double `d24' = 0 if $ML_y1 == 0
		replace `d24' = `sval'^(-1) * (`rho' / `rtrho' * `lamhge' * (1 - `rho'	///
		 	/ `rtrho' * `zval' * (`hge' + `lamhge')) - 2 * `zval') if $ML_y1 == 1
		mlmatsum `lnfj' `h24' = `d24', eq(2,4)
		
		// h25 (xb athrho)
		gen double `d25' = 0 if $ML_y1 == 0
		replace `d25' = `lamhge' / `sval' * `rtrho' * (`rho' / `rtrho' * 		///
			((`hge' + `lamhge') * (`zval' + `rho' / `rtrho' * `hge') - `rho' /	///
			`rtrho') - 1) if $ML_y1 == 1
		mlmatsum `lnfj' `h25' = `d25', eq(2,5)
		
		// Derivatives of g3 (lnssel)
		// h33 (lnssel lnssel)
		gen double `d33' = `zsel' * `nlamzi' * (`zsel' * (`zsel' - `nlamzi')	///
			- 1) if $ML_y1 == 0
		replace `d33' = `zsel' * `lamhge' / `rtrho' * (1 - `zsel' / `rtrho' *	///
			(`hge' + `lamhge')) if $ML_y1 == 1
		mlmatsum `lnfj' `h33' = `d33', eq(3)
		
		// h34 (lnssel lnsval)
		gen double `d34' = 0 if $ML_y1 == 0
		replace `d34' = - `zsel' * `rho' / (1 - `rho'^2) * `zval' * `lamhge' *	///
			(`hge' + `lamhge') if $ML_y1 == 1
		mlmatsum `lnfj' `h34' = `d34', eq(3,4)
		
		// h35 (lnssel athrho)
		gen double `d35' = 0 if $ML_y1 == 0
		replace `d35' = `zsel' * `lamhge' * ((`hge' + `lamhge') * (`zval' +		///
			`rho' / `rtrho' * `hge') - `rho' / `rtrho') if $ML_y1 == 1
		mlmatsum `lnfj' `h35' = `d35', eq(3,5)
		
		// Derivatives of g4 (lnsval)
		// h44 (lnsval lnsval)
		gen double `d44' = 0 if $ML_y1 == 0
		replace `d44' = `zval' * (`rho' / `rtrho' * `lamhge' * (1 - `rho' /		///
			`rtrho' * `zval' * (`hge' + `lamhge')) - 2 * `zval') if $ML_y1 == 1
		mlmatsum `lnfj' `h44' = `d44', eq(4)
		
		// h45 (lnsval athrho)
		gen double `d45' = 0 if $ML_y1 == 0
		replace `d45' = `zval' * `lamhge' * `rtrho' * (`rho' / `rtrho' *  		///
			((`hge' + `lamhge') * (`zval' + `rho' / `rtrho' * `hge') - `rho' /	///
			`rtrho') - 1) if $ML_y1 == 1
		mlmatsum `lnfj' `h45' = `d45', eq(4,5)
		
		// Derivative of g5 (athrho)
		// h55 (athrho athrho)
		gen double `d55' = 0 if $ML_y1 == 0
		replace `d55' = `lamhge' * (1 - `rho'^2) * ((1 + `rho'^2 / (1 -			///
			`rho'^2)) *	`hge' - (`hge' + `lamhge') * (`zval' + `rho' /			///
			`rtrho' * `hge')^2) if $ML_y1 == 1
		mlmatsum `lnfj' `h55' = `d55', eq(5)
		
		// Compose the Hessian
		mat `H' =		(`h11',`h12',`h13',`h14',`h15')
		mat `H' = `H' \ ((`h12')',`h22',`h23',`h24',`h25')
		mat `H' = `H' \ ((`h13')',(`h23')',`h33',`h34',`h35')
		mat `H' = `H' \ ((`h14')',(`h24')',(`h34')',`h44',`h45')
		mat `H' = `H' \ ((`h15')',(`h25')',(`h35')',(`h45')',`h55')
	}
end

// Version 1.0.0 is an lf evaluator for the linear model with heteroskedastic
//		selection errors
// Version 1.1.0 is an lf2 evaluator (adding analytical gradient and hessian)
//		for both linear and exponential models with heteroskedastic selection
//		errors
