*! nehurdle_trunc_het v1.1.0
*! 29 June 2018
*! Alfonso Sanchez-Penalver
*! Version history at the bottom.

/*******************************************************************************
*	ML lf evaluator for selection heteroskedastic Truncated Hurdle estimator,  *
*	both linear and exponential, and homoskedastic and heteroskedastic value.  *
*******************************************************************************/

capture program drop nehurdle_trunc_het
program define nehurdle_trunc_het
	version 11
	args todo b lnfj g1 g2 g3 g4 H
	
	quietly{
		// Evaluate each equation
		tempvar zg xb lnssel lnsval
		mleval `zg' = `b', eq(1)
		mleval `xb' = `b', eq(2)
		mleval `lnssel' = `b', eq(3)
		mleval `lnsval' = `b', eq(4)
		// Generate variables that are going to help in writing the functions
		tempvar  ssel sval zsel zval
		gen double `ssel' = exp(`lnssel')
		gen double `sval' = exp(`lnsval')
		gen double `zsel' = `zg' / `ssel'
		gen double `zval' = `xb' / `sval'
		
		// Log-Likelihood
		replace `lnfj' = lnnormal(- `zsel') if $ML_y1 == 0
		
		// The global macro neh_method is set in nehurdle.ado and tells us whether
		// we want a linear or exponential specification of the value function
		if "$neh_method" == "linear" {
			replace `lnfj' = lnnormal(`zsel') + lnnormalden(($ML_y2 - `xb') /	///
				`sval') - lnnormal(`zval') - `lnsval' if $ML_y1 == 1
		}
		else {
			replace `lnfj' = lnnormal(`zsel') + lnnormalden(($ML_y2	- `xb') /	///
				`sval') - `lnsval' - $ML_y2 if $ML_y1 == 1
		}
		
		if (`todo' == 0) exit
		
		// Generate variables to help in writing the functions for the gradient
		// and Hessian
		tempvar lamzi nlamzi lamxi
		gen double `lamzi' = normalden(`zsel') / normal(`zsel')
		gen double `nlamzi' = normalden(`zsel') / normal(- `zsel')
		gen double `lamxi' = normalden(`zval') / normal(`zval')
		
		// Gradient
		// g1 (zg)
		replace `g1' = - `ssel'^(-1) * `nlamzi' if $ML_y1 == 0
		replace `g1' = `ssel'^(-1) * `lamzi' if $ML_y1 == 1
		
		// g2 (xb)
		replace `g2' = 0 if $ML_y1 == 0
		if "$neh_method" == "linear" {
			replace `g2' = `sval'^(-1) * (($ML_y2 - `xb') / `sval' - `lamxi')	///
				if $ML_y1 == 1
		}
		else replace `g2' = ($ML_y2 - `xb') / (`sval'^2) if $ML_y1 == 1
		
		// g3 (lnssel)
		replace `g3' = `zsel' * `nlamzi' if $ML_y1 == 0
		replace `g3' = - `zsel' * `lamzi' if $ML_y1 == 1
		
		// g4 (lnsval)
		replace `g4' = 0 if $ML_y1 == 0
		if "$neh_method" == "linear" {
			replace `g4' = (($ML_y2 - `xb') / `sval')^2 + `zval' * `lamxi' - 1	///
				if $ML_y1 == 1
		}
		else replace `g4' = (($ML_y2 - `xb') / `sval')^2 - 1 if $ML_y1 == 1
		
		if (`todo' == 1) exit
		
		// Hessian
		// This is going to be a 4x4 with elements h12, h14, h21, h23, h32, h34,
		// and h41 equal to 0
		
		tempvar d11 d13 d22 d24 d33 d44
		tempname h11 h12 h13 h14 h22 h23 h24 h33 h34 h44
		
		// h11 (zg zg)
		gen double `d11' = `ssel'^(-2) * `nlamzi' * (`zsel' - `nlamzi') if		///
			$ML_y1 == 0
		replace `d11' = - `ssel'^(-2) * `lamzi' * (`zsel' + `lamzi') if			///
			$ML_y1 == 1
		mlmatsum `lnfj' `h11' = `d11', eq(1)
		
		// h12 (zg xb)
		mlmatsum `lnfj' `h12' = 0, eq(1,2)
		
		// h13 (zg lnssel)
		gen double `d13' = `ssel'^(-1) * `nlamzi' * (1 - `zsel' * (`zsel' -		///
			`nlamzi')) if $ML_y1 == 0
		replace `d13' = `lamzi' / `ssel' * (`zsel' * (`zsel'+ `lamzi') - 1) ///
			if $ML_y1 == 1
		mlmatsum `lnfj' `h13' = `d13', eq(1,3)
		
		// h14 (zg lnsval)
		mlmatsum `lnfj' `h14' = 0, eq(1,4)
		
		// h22 (xb xb)
		gen double `d22' = 0 if $ML_y1 == 0
		if "$neh_method" == "linear" {
			replace `d22' = `sval'^(-2) * (`lamxi' * (`zval' + `lamxi') - 1)	///
				if $ML_y1 == 1
		}
		else replace `d22' = - `sval'^(-2) if $ML_y1 == 1
		mlmatsum `lnfj' `h22' = `d22', eq(2)
		
		// h23 (xb lnssel)
		mlmatsum `lnfj' `h23' = 0, eq(2,3)
		
		// h24 (xb lnsval)
		gen double `d24' = 0 if $ML_y1 == 0
		if "$neh_method" == "linear" {
			replace `d24' = `sval'^(-1) * (`lamxi' * (1 - `zval' * (`zval' +	///
				`lamxi')) - 2 * ($ML_y2 - `xb') / `sval') if $ML_y1 == 1
		}
		else replace `d24' = - 2 * ($ML_y2 - `xb') / (`sval'^2) if $ML_y1 == 1
		mlmatsum `lnfj' `h24' = `d24', eq(2,4)
		
		// h33 (lnssel lnssel)
		gen double `d33' = `zsel' * `nlamzi' * (`zsel' * (`zsel' - `nlamzi')	///
			- 1) if $ML_y1 == 0
		replace `d33' = - `zsel' * `lamzi' * (`zsel' * (`zsel' + `lamzi') - 1)	///
			if $ML_y1 == 1
		mlmatsum `lnfj' `h33' = `d33', eq(3)
		
		// h34 (lnssel lnsval)
		mlmatsum `lnfj' `h34' = 0, eq(3,4)
		
		// h44 (lnsval lnsval)
		gen double `d44' = 0 if $ML_y1 == 0
		if "$neh_method" == "linear" {
			replace `d44' = `zval' * `lamxi' * (`zval' * (`zval' + `lamxi') - 1) ///
				- 2 * (($ML_y2 - `xb') / `sval')^2 if $ML_y1 == 1
		}
		else replace `d44' = - 2 * (($ML_y2 - `xb') / `sval')^2 if $ML_y1 == 1
		mlmatsum `lnfj' `h44' = `d44', eq(4)
		
		// Compose the Hessian
		mat `H' =		(`h11',`h12',`h13',`h14')
		mat `H' = `H' \ ((`h12')',`h22',`h23',`h24')
		mat `H' = `H' \ ((`h13')',(`h23')',`h33',`h34')
		mat `H' = `H' \ ((`h14')',(`h24')',(`h34')',`h44')
	}
end

// Version 1.0.0 is an lf evaluator for linear model with heteroskedastic
//		selection errors
// Version 1.1.0 is an lf2 evaluator (adding analytical gradient and hessian)
//		for both linear and exponential models with heteroskedastic selection
//		errors
