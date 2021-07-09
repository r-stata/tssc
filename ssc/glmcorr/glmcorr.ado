*! 1.2.0 NJC 14 July 2004 
*! 1.1.0 NJC 9 March 2003 
*! 1.0.0 NJC 8 Oct 2002 
program def glmcorr, rclass 
	version 7
	syntax[, JACKknife ] 

	* previous model results in memory? 
	if "`e(cmd)'" != "glm" { 
		di as err "estimates not found" 
		exit 301 
	}
	
	* show text header 
	di 
	di as txt "{col 5}{title:`e(depvar)' and predicted}"  
	di 

	* get fit 
        tempvar fit errsq 
	qui predict `fit' if e(sample)
	
	* get root MSE 
	qui gen double `errsq' = (`e(depvar)' - `fit')^2  
	su `errsq', meanonly
	tempname rmse 
	scalar `rmse' = sqrt(r(sum) / e(df)) 

	* get correlation  
	qui corr `e(depvar)' `fit' 
	di as txt "    Correlation     " %10.3f as res `r(rho)'
	di as txt "    R-squared       " %10.3f as res (`r(rho)')^2
	return scalar rho = r(rho) 
	return scalar rsq = r(rho)^2 

	* jackknife it
	if "`jackknife'" != "" {  
		if r(rho) != . { 
			qui jknife "corr `e(depvar)' `fit'" r=r(rho), rclass
			return scalar jrho = r(mean1)
			di as txt "    (jackknifed)    " %10.3f as res `r(mean1)'
		} 
		else return scalar jrho = . 
	} 	
	
	* display RMSE 
	di as txt "    Root MSE   " %15.3f as res `rmse' 
	return scalar rmse = scalar(`rmse') 
end

