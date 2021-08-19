*! version 1:  10  April 2021, Gueorgui I. Kolev
*! Computes robust and/or clustered variance matrix of estimates post xtgls.
*! Methods and Formulas are in Kolev (2014) "Robust variance estimation in panel data 
*! generalized least squares regression."

program define xtglsr
        version 11
		preserve 
        syntax [, CLUSTER(varname) MINUS(integer 0)]
		
		if "`e(cmd)'" != "xtgls" {
		display as error "Can be used only after xtgls"
        error 301
		}
qui xtset
local panelis `r(panelvar)'
local timeis `r(timevar)'
		if "`r(panelvar)'"=="" | "`r(timevar)'"=="" {
		display as error "You need to xtset your data, and specify both panel and time identifiers"
        error 459
		}
	
* If the option cluster is specified, restrict sample to non missing cluster var.
if !missing("`cluster'") qui drop if missing(`cluster')

* Tempnames for the residuals, Inverse Sigma, and the weighted residuals.
tempname residual InvSigma weightedresidual
tempfile thedata	 

* Replay in case somebody is calling xtgls repeatedly for the correct homoskedastic variance.
quietly {
`e(cmdline)'
mat `InvSigma' = invsym(e(Sigma))	// Sigma^-1, Sigma is the covariance of errors across equations.
egen Individual_Observations = group(`timeis' `panelis') if e(sample)
	
* Generate the residuals
predict double `residual' if e(sample), xb	// only  the linear prediction is available post xtgls
replace `residual' = `e(depvar)' - `residual'

* Generate the weighted residual
save `thedata', replace
keep `residual' `panelis' `timeis'
levelsof `panelis', local(levelspanelis) // Extract the levels: panelvar might be something bizarre, like -3, 0, 5, 300, etc.

* We reshape the data to wide. matrix score operates on variables.
reshape wide `residual', i(`timeis') j(`panelis')
ds `timeis', not // at the point in the data there are only `residual'-stub variables, and `timeis'. 
local theresiduals `r(varlist)'
mat colnames `InvSigma' = `theresiduals'	// assign the names of the residuals as column names of Sigma^-1.
forvalues i = 1/`=rowsof(`InvSigma')' { // Loop over the rows of Sigma^-1.
matrix tempvec = `InvSigma'[`i',1...]   // Extract the given row. 
matrix score `weightedresidual'`: word `i' of `levelspanelis''= tempvec	// Form a linear combination 
// of the unweighted residual vectors u1 u2 .. uM, where the weights are given by the row of Sigma^-1.
}	// Closes the Forvalues loop. 

drop `theresiduals' 
reshape long `weightedresidual', i(`timeis') j(`panelis')

merge 1:1 `timeis' `panelis' using `thedata', nogenerate

* Once we have calculated the set of weighted residuals, we call _robust. 
if "`cluster'" != "" { // If the user has taken control of the clustering, we let the user decide what the clustring is on.
_robust `weightedresidual', minus(`minus') cluster(`cluster')
}
else if e(vt) == "heteroskedastic with cross-sectional correlation" { // If the user has not taken control of clustering,
				// and the estimator is cross sectionally correlated, we cluster by time.
					_robust `weightedresidual', minus(`minus') cluster(`timeis')
					}
else _robust `weightedresidual', minus(`minus') cluster(Individual_Observations) // If the user has not specified clustering,
			// and the estimator is NOT cross sectionally correlated, we cluster by observation, that is (Time X PanelId) identifier. 
			// I am doind this because _robust seems to be too smart for its own good: When I specify robust only, and the data is xtset
			// _robust computes clustered by PanelID standard errors. In the context of -xtgls- this is incorrect and we do NOT want it.  

} // Closes the Quietly brace.  

xtgls, // We replay xtgls, but Robust Variance = Bread*Meat*Bread has been substituted
				// by _robust for what was only Bread when we fit the xtgls initially. 

end



