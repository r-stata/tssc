********************************************************************************
*** LEAVE-ONE-OUT CROSS VALIDATION v.1.0.2
********************************************************************************

* Author: Manuel Barron
* manuel.barron@gmail.com
* October 11, 2014

program define loocv, rclass
version 11.0
syntax anything [aweight fweight iweight pweight/] [if] [in], [EWeight(varname)] *

	if "`weight'" != "" {
		local weight = "[weight=`exp']"
	}
	
	if "`eweight'" != "" {
		local eweight = "[weight=`eweight']"
	}
	
	tempvar yhat ehat diff sqdiff absdiff Yhat results
	
	
	
	qui{
		preserve
		mat `results' = J(3,1,.)
		`anything' `if' `in' `weight', `options'
		keep if e(sample)
		
		g `diff'=.
		g `Yhat'=.
		count
		local max = r(N)
		forval i = 1/`max' {
		
			`anything' if _n!=`i' `weight', `options'
			local depvar = e(depvar)

			predict `yhat' if _n==`i' `eif' `ein'
			
			g `ehat' =  `depvar' - `yhat'
			
			replace `diff' = `ehat' if _n==`i'
			replace `Yhat' = `yhat' if _n==`i'
			
			drop `ehat' `yhat'
		}
		
		* RMSE:
		g `sqdiff' = `diff'^2
		sum `sqdiff' `eweight'
		scalar cv1 = sqrt(r(mean))
		return scalar rmse = cv1
		mat `results'[1,1]  = cv1
		
		
		* MAE
		g `absdiff' = abs(`diff')
		sum `absdiff' `eweight'
		scalar cv2 = r(mean)
		return scalar mae = r(mean)
		mat `results'[2,1] = cv2
		
		
		* Pseudo-R2
		qui corr `Yhat' `depvar'
		scalar cv3  = r(rho)^2
		return scalar r2 = cv3
		mat `results'[3,1] =  cv3
				
	}
	
	mat colnames `results' = "LOOCV"

	mat rownames `results' = "RMSE" "MAE" "Pseudo-R2"
	
	return matrix loocv = `results'

	display _newline
	display as text " Leave-One-Out Cross-Validation Results "
	di as text "{hline 25}{c TT}{hline 15}"		
	di as text "         Method          {c |}" _col(30) " Value"
	di as text "{hline 25}{c +}{hline 15}"	
	display as text "Root Mean Squared Errors {c |}" _col(30) as result cv1
	display as text "Mean Absolute Errors     {c |}" _col(30) as result cv2
	display as text "Pseudo-R2                {c |} " _col(30) as result cv3
	di as text "{hline 25}{c BT}{hline 15}"		

end

