*! version 1.0.0 MLB 04Apr2009
program define mkspline2, rclass
	syntax anything(equalok) [if] [in] [fweight] , [cubic *]
	
// only do something different when restricted cubic splines are created
	if "`cubic'" == "" {
		mkspline `0'
	}
	
	else {
// the spline variables are the new variables created with -mkspline-
		unab before : _all
		mkspline `0'
		unab after : _all
		local splines : list after - before
		
// the oldvar is the first variable after the = sign in anything
		gettoken a b : anything, parse("=")
		gettoken a b : b, parse("=")
		local oldvar : word 1 of `b'

// the knot locations are stored in the matrix r(knots)				
		tempname knotmat
		matrix `knotmat' = r(knots)
		forvalues k = 1/`r(N_knots)' {
			local k = el(`knotmat',1,`k')
			local knots "`knots' `k'"
		}
		local knots : list retokenize knots

// leave the results behind in characteristics
		char define _dta[rcsplines] "`splines'"
		char define _dta[oldvar] "`oldvar'"
		char define _dta[knots] "`knots'"

// leave knots behind in matrix r(knots) in order to be consistent with the behavior of -mkspline-		
		return matrix knots `knotmat'
	}
end
