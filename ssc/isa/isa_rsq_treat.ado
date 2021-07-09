*capture program drop isa_rsq_treat

*********************************************************************
*	ESTIMATING R-SQ FOR TREATMENT ASSIGNMENT EQ.

program define isa_rsq_treat
	version 9
	syntax varlist [if] [in] [fw aw], alpha(real) 

	marksample touse
	gettoken y rhs : varlist
	gettoken t X :rhs
	
	*	COUNTING NUMBER OF VARIABLES
	local num_var=0
	foreach var in `varlist' {
		local num_var=`num_var'+1
	}
	local num_Xvar = `num_var' - 2
	
	*	DEFINE COEF VECTOR
	matrix COEF_t = J(1, `num_Xvar', .)
	forvalues c = 1/`num_Xvar' {
		local c2 = `c' + `num_var' /* coef of assignment starts after those of t x intercept of outcome eq.*/
		matrix COEF_t[1, `c'] = matB[1, `c2']
	}

	*	DEFINE COV MATRIX
	qui cor `X' if `touse' [`weight'`exp'], cov
	matrix V_t = r(C)
	
	*	DEFINE COEF VECTOR
	matrix VAR_t = COEF_t*V_t*COEF_t'
	scalar var_t = VAR_t[1,1]
	scalar rsq_t = (var_t + (`alpha')^2/4)/(var_t + (`alpha')^2/4 + _pi^2/3)
	matrix drop COEF_t V_t VAR_t
end

	
