*! nehurdle_trunc v1.1.0
*! 29 June 2018
*! Alfonso Sanchez-Penalver
*! Version history at the bottom.

/*******************************************************************************
*	ML lf2 evaluator for homoskedastic and heteroskedastic Truncated Hurdle,   *
*	both linear and exponential												   *
*******************************************************************************/

capture program drop nehurdle_trunc
program define nehurdle_trunc
	version 11
	args todo b lnfj g1 g2 g3 H
	
	quietly{
		// Evaluating the variables
		tempvar xb zg lnsigma sigma
		mleval `zg' = `b', eq(1)
		mleval `xb' = `b', eq(2)
		mleval `lnsigma' = `b', eq(3)
		gen double `sigma' = exp(`lnsigma')
		
		// Log-Likelihood
		replace `lnfj' = lnnormal(- `zg') if $ML_y1 == 0
		
		// The global macro neh_method is set in nehurdle.ado and tells us whether
		// we want a linear or exponential specification of the value function
		if "$neh_method" == "linear" {
			replace `lnfj' = lnnormal(`zg') + lnnormalden(($ML_y2 - `xb') /		///
				`sigma') - lnnormal(`xb' / `sigma') - `lnsigma' if $ML_y1 == 1
		}
		else {
			// Exponential
			replace `lnfj' = lnnormal(`zg') + lnnormalden(($ML_y2 - `xb') /		///
				`sigma') - `lnsigma' - $ML_y2 if $ML_y1 == 1
		}
		
		if (`todo' == 0) exit
		
		tempvar lamzi lamxi nlamzi
		gen double `lamzi' = normalden(`zg') / normal(`zg')
		gen double `lamxi' = normalden(`xb' / `sigma') / normal(`xb' / `sigma')
		gen double `nlamzi' = normalden(`zg') / normal(- `zg')
		
		// Gradient
		// g1 (zg)
		replace `g1' = - `nlamzi' if $ML_y1 == 0
		replace `g1' = `lamzi' if $ML_y1 == 1
		
		// g2 (xb)
		replace `g2' = 0 if $ML_y1 == 0
		if "$neh_method" == "linear" {
			replace `g2' = `sigma'^(-1) * (($ML_y2 - `xb') / `sigma' - `lamxi')	///
				if $ML_y1 == 1
		}
		else replace `g2' = ($ML_y2 - `xb') / (`sigma'^2) if $ML_y1 == 1
		
		// g3 (lnsigma)
		replace `g3' = 0 if $ML_y1 == 0
		if "$neh_method" == "linear" {
			replace `g3' = `xb' / `sigma' * `lamxi' + (($ML_y2 - `xb') /		///
				`sigma')^2 - 1 if $ML_y1 == 1
		}
		else replace `g3' = (($ML_y2 - `xb') / `sigma')^2 - 1 if $ML_y1 == 1
		
		if (`todo' == 1) exit
		
		// Hessian
		// The Hessian is 3x3, with four elements (12, 13, 21, and 31) being 0.
		tempvar d11 d22 d23 d33
		tempname h11 h12 h13 h22 h23 h33
		
		// h11 (zg zg)
		gen double `d11' = `nlamzi' * (`zg' - `nlamzi') if $ML_y1 == 0
		replace `d11' = - `lamzi' * (`zg' + `lamzi') if $ML_y1 == 1
		mlmatsum `lnfj' `h11' = `d11', eq(1)
		
		// h12 (zg xb)
		mlmatsum `lnfj' `h12' = 0, eq(1,2)
		
		// h13 (zg lnsigma)
		mlmatsum `lnfj' `h13' = 0, eq(1,3)
		
		// h22 (xb xb)
		gen double `d22' = 0 if $ML_y1 == 0
		if "$neh_method" == "linear" {
			replace `d22' = `sigma'^(-2) * (`lamxi' * (`xb' / `sigma' +			///
				`lamxi') - 1) if $ML_y1 == 1
		}
		else replace `d22' = - `sigma'^(-2) if $ML_y1 == 1
		mlmatsum `lnfj' `h22' = `d22', eq(2)
		
		// h23 (xb lnsigma)
		gen double `d23' = 0 if $ML_y1 == 0
		if "$neh_method" == "linear" {
			replace `d23' = `sigma'^(-1) * (`lamxi' * (1 - `xb' / `sigma' *		///
				(`xb' / `sigma' + `lamxi')) - 2 * ($ML_y2 - `xb') / `sigma')	///
				if $ML_y1 == 1
		}
		else replace `d23' = - 2 * ($ML_y2 - `xb') / (`sigma'^2) if $ML_y1 == 1
		mlmatsum `lnfj' `h23' = `d23', eq(2,3)
		
		// h33 (lnsigma lnsigma)
		gen double `d33' = 0 if $ML_y1 == 0
		if "$neh_method" == "linear" {
			replace `d33' = `xb' / `sigma' * `lamxi' * (`xb' / `sigma' *		///
				(`xb' / `sigma' + `lamxi') - 1) - 2 * (($ML_y2 - `xb') /		///
				`sigma')^2 if $ML_y1 == 1
		}
		else replace `d33' = - 2 * (($ML_y2 - `xb') / `sigma')^2 if $ML_y1 == 1
		mlmatsum `lnfj' `h33' = `d33', eq(3)
		
		mat `H' =		(`h11',`h12',`h13')
		mat `H' = `H' \ ((`h12')',`h22',`h23')
		mat `H' = `H' \ ((`h13')',(`h23')',`h33') 
	}
end

// Version 1.0.0 is an lf evaluator for linear model with homoskedastic
//		selection errors
// Version 1.1.0 is an lf2 evaluator (adding analytical gradient and hessian)
//		for both linear and exponential models with homoskedastic selection
//		errors
