*! version 1  08 Oct 2020, Gueorgui I. Kolev
*! Computes robust and/or clustered variance matrix of estimates post sureg.
*! Methods and Formulas are in Kolev (2021) "Robust and/or cluster-robust variance estimation
*!				 in Seemingly Unrelated Regressions, and in Multivariate Regressions."

program define suregr
        version 11
		preserve 
        syntax [, CLUSTER(varname) MINUS(integer 0) noHeader]
		
		if "`e(cmd)'" != "sureg" {
		display as error "suregr can be used only after sureg"
        error 301
    }
	
* If the option cluster is specified, restrict sample to non missing cluster var.
if !missing("`cluster'") qui drop if missing(`cluster')

* Replay in case somebody is calling suregr repeatedly for the correct homoskedastic variance.
qui `e(cmdline)'

* Tempnames for the residuals, Inverse Sigma, and the weighted residuals.
tempname residual InvSigma weightedresidual	 
	
* Generate the residuals for each equation
qui foreach l in `e(depvar)' {
predict double `l'`residual' if e(sample), resid eq(`l') 
}

* Extract the names of the residuals
qui ds *`residual' 

* Generate the weighted residual
mat `InvSigma' = invsym(e(Sigma))	// Sigma^-1, Sigma is the covariance of errors across equations.
mat colnames `InvSigma' = `r(varlist)'	// assign the names of the residuals as column names of Sigma^-1.
forvalues i = 1/`=rowsof(`InvSigma')' { // Loop over the rows of Sigma^-1.
matrix tempvec = `InvSigma'[`i',1...]   // Extract the given row. 
matrix score `weightedresidual'`i'= tempvec	// Form a linear combination of the unweighted residual 
				// vectors u1 u2 .. uM, where the weights are given by the row of Sigma^-1.
local weightedresidualall `weightedresidualall' `weightedresidual'`i' // Accumulate the set of
															// weighted residuals wu1 wu2 .. wuM.
}

* Once we have calculated the set of weighted residuals wu1 wu2 .. wuM, we call _robust. 
_robust `weightedresidualall', minus(`minus') cluster(`cluster') 

sureg, `header' // We replay sureg, but Robust Variance = Bread*Meat*Bread has been substituted
				// by _robust for what was only Bread when we fit the sureg initially. 

end



