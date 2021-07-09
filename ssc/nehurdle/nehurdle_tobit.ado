*! nehurdle_tobit v1.1.0
*! 29 June 2018
*! Alfonso Sanchez-Penalver
*! Version history at the bottom.

/*******************************************************************************
*	ML lf2 evaluator for homoskedastic and heteroskedastic Tobit, both linear  *
*	and exponential.														   *
*******************************************************************************/

capture program drop nehurdle_tobit
program nehurdle_tobit
	version 11
	args todo b lnfj g1 g2 H
	
	quietly {
		// Setting the censoring point and conditions, depending on whether it
		// is linear or exponential. The macro $neh_method should be set in
		// nehurdle.ado.
		tempname gamma
		if "$neh_method" == "linear" {
			scalar `gamma' = 0
			local lcond "$ML_y1 <= 0"
			local rcond "$ML_y1 > 0"
		}
		else {
			sum $ML_y1, mean
			scalar `gamma' = r(min) - 1e-7
			local lcond "missing($ML_y1)"
			local rcond "!missing($ML_y1)"
		}
		
		// Get the values of the parameters
		tempvar xb z lnsigma sigma
		
		mleval `xb' = `b', eq(1)
		mleval `lnsigma' = `b', eq(2)
		
		gen double `sigma' = exp(`lnsigma')
		gen double `z' = (`xb' - `gamma') / `sigma'
	
		// Log-Likelihood
		replace `lnfj' = lnnormal(- `z') if `lcond'
		replace `lnfj' = lnnormalden(($ML_y1 - `xb') / `sigma') - `lnsigma'		///
			if `rcond'
		if "$neh_method" == "exponential"										///
			replace `lnfj' = `lnfj' -	$ML_y1 if `rcond'
			
		if (`todo' == 0) exit
		
		tempvar lambda
		gen double `lambda' = normalden(`z') / normal(- `z')
		
		// Gradient
		// g1 (xb)
		replace `g1' = - `lambda' * `sigma'^(-1) if `lcond'
		replace `g1' = ($ML_y1 - `xb') / (`sigma'^2) if `rcond'
		
		// g2 (lnsigma)
		replace `g2' = `lambda' * `z' if `lcond'
		replace `g2' = (($ML_y1 - `xb') / `sigma')^2 - 1 if `rcond'
		
		if (`todo' == 1) exit
		
		// Hessian
		// There are 2 equations so we need to compute 3 elements for the Hessian
		tempvar d11 d12 d22
		tempname h11 h12 h22
		
		// h11 (xb xb)
		gen double `d11' = `sigma'^(-2) * `lambda' * (`z' - `lambda') if `lcond'
		replace `d11' = - `sigma'^(-2) if `rcond'
		mlmatsum `lnfj' `h11' = `d11', eq(1)
		
		// h12 (xb lnsigma)
		gen double `d12' = `sigma'^(-1) * `lambda' * (1 - `z' * (`z' -			///
			`lambda')) if `lcond'
		replace `d12' = - 2 * ($ML_y1 - `xb') / (`sigma'^2) if `rcond'
		mlmatsum `lnfj' `h12' = `d12', eq(1,2)
		
		// h22 (lnsigma lnsigma)
		gen double `d22' = `z' * `lambda' * (`z' * (`z' - `lambda') - 1)		///
			if `lcond'
		replace `d22' = - 2 * (($ML_y1 - `xb') / `sigma')^2 if `rcond'
		mlmatsum `lnfj' `h22' = `d22', eq(2)
		
		mat `H' =		(`h11',`h12')
		mat `H' = `H' \ ((`h12')', `h22')
	}
end

// Version 1.0.0 is an lf evaluator for only linear models
// Version 1.1.0 is an lf2 evaluator (adding analytical gradient and hessian)
//		for both linear and exponential models
