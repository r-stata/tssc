****************************************************************
*! Version 9.0.1, 5 October 2006
*! Author: James Cui, Monash University
*! Buckley-James method for analysing censored data
*! Original publication: Nov 2005 SJ-5-4: 517-526
****************************************************************

capture program drop buckley
program buckley, rclass 
version 9.0

	syntax varlist(min=3 numeric) [, Iterate(integer 100) 	/*
		*/	Tolerance(real 1e-6) Dispnum(integer 100)]
	marksample touse

	if `iterate' < 0 {
		di as err "iterate() must be positive"
		exit 198
	}
	if `tolerance'>=1 | `tolerance'<0 {
		di as err "tolerance() must be in [0,1)"
		exit 198
	}
	if `dispnum' < 0 {
		di as err "dispnum() must be positive"
		exit 198
	}

*---------------------------------------------------------------
* 1. PARSING 
*---------------------------------------------------------------

	tempvar y treatment x untreated var
	tempname numx coef_new sumsq loop absminres obs coef

	tokenize `varlist'
	local y `1'
	local treatment `2'
	macro shift 2
	local x `*'
	qui gen `untreated' = 1 - `treatment'	/* failure indicator */

	local numx 0				/* number of covariates */
	foreach var of local x {
		local ++numx 
	}


*---------------------------------------------------------------
* 2. REGRESSION OF ORIGINAL DATA
*---------------------------------------------------------------

	qui regress `y' `x'
	matrix `coef_new' = e(b)

	local sumsq = .
	local loop = 0


*---------------------------------------------------------------
* 3. UPDATE COEFFICIENTS BY ITERATION
*---------------------------------------------------------------

	while (`sumsq' > `tolerance' & `loop' < `iterate') {
		local ++loop
		disp as text _newline "Iteration " `loop' ": " _continue

		tempvar y_linear y_res y_pores sur_km mass_km step y_bj 
	

*---------------------------------------------------------------
* 4. DROP CONSTANT FROM LINEAR REGRESSION
*---------------------------------------------------------------

		matrix `coef' = `coef_new'
		matrix score `y_linear' = `coef' 
		qui replace `y_linear' = `y_linear' - `coef'[1,`numx'+1]       
								
*---------------------------------------------------------------
* 5. CALCULATE RESIDUALS AND SORT
*---------------------------------------------------------------

		qui gen `y_res' = `y' - `y_linear'
		qui sort `y_res'
		sum `y_res' if `touse', meanonly
		scalar `absminres' = abs(r(min)) + 1	/* abs min residaul */
		qui gen `y_pores' = `y_res' + `absminres'	/* positive residual */


*---------------------------------------------------------------
* 6. K-M ESTIMATOR
*---------------------------------------------------------------

		qui stset `y_pores' `untreated'
		sts gen `sur_km' = s
		qui gen `mass_km' = 1 - `sur_km'[1] if _n == 1
		qui replace `mass_km' = `sur_km'[_n-1] - `sur_km' if _n > 1
		qui replace `mass_km' = `sur_km'[_N] 		/*
			*/	if (_n==_N & `untreated'[_N] == 0)
			/*---- replace last survival because undefined if censored ----*/
					
	 
*---------------------------------------------------------------
* 7. CALCULATE CUMULATIVE MASS FUNCTION
*---------------------------------------------------------------

		sum `y' if `touse', meanonly
		local obs = r(N)
		qui gen `step' = 0
		forvalues i = 1/`obs' {
			if (`untreated'[`i'] == 0) {
				local k = `i' + 1
				forvalues j = `k' / `obs' {
      			   	qui replace `step' = `step' 			/*
					*/	+ `mass_km'[`j'] 	* `y_res'[`j'] 	/*
					*/	/ `sur_km'[`i'] if _n == `i'
				}
			}
			/*----- display iteration stage -----*/
			if (mod(`i', `dispnum') == 0) {
				disp as text "`i'." _continue 
			}
		}
		qui replace `step' = `y_res' if `untreated' == 1
		qui replace `step' = `y_res' if _n == _N & `untreated'[_N] == 0


*---------------------------------------------------------------
* 8. BUCKLEY-JAMES EXPECTATION
*---------------------------------------------------------------

		qui gen `y_bj' = `y_linear' + `step'

		qui regress `y_bj' `x'
		matrix `coef_new' = e(b)	


		/*----- convergence criterion -----*/	
		local sumsq 0
		forvalues i = 1/`numx' {
			local sumsq = `sumsq' + 					/*
			*/		(`coef'[1,`i'] - `coef_new'[1,`i'])^2
		}
	}
	/*--------- end of the iteration -------*/
	drop _st _d _t _t0


*---------------------------------------------------------------
* 9. GENERATE EXPECTATION VARIABLE
*---------------------------------------------------------------

	capture drop varbj
	qui gen varbj = `y_bj'
	label variable varbj "restored dependent variable"	


*---------------------------------------------------------------
* 10. GENERATE COEFFICIENT MATRIX
*---------------------------------------------------------------
	
	sum `step' if `touse', meanonly
	matrix `coef_new'[1,`numx'+1] = r(mean)	
	matrix coefbj = `coef_new'
	matrix rowname coefbj = "varbj"
	disp as text _newline(2) "Regression coefficients:" _continue
	matrix list coefbj, format(%12.4f)
	disp _newline


*---------------------------------------------------------------
* 11. SAVED RESULTS
*---------------------------------------------------------------
	
	return scalar N      = `obs'
	return scalar k      = `numx'
	return scalar iter   = `loop'
	return scalar sumsq  = `sumsq'

	return matrix coefbj = coefbj, copy
			
	return local depvar   "`y'"
	return local timevar  "`treatment'"
	return local covar    "`x'"
	return local varbj    varbj
		
end

