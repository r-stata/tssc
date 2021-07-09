*! version 1.0.0 13Jul2020
//-----------------------------------------------------------------------------
//
//	mivcausal - Testing the hypothesis about the signs of the 2SLS weights
//	Mintest
//
//-----------------------------------------------------------------------------

capt program drop mivmint

program mivmint, rclass

	version 10.0
	syntax [anything] [if] [in] [, SEEd(integer 1) 							///
								   NDraws(integer 10000)]

	// Step 1 - Compute the test statistic for Mintest
	mat t_mint = J(1, 2, 0)
	forval i = 1/2 {
		mat t_mint[1, `i'] = sqrt(NN) * thetaols[1, `i'] / thetasys[1, `i'] 
	}
	scalar mint = min(t_mint[1, 1], t_mint[1, 2])

	// Step 2 - Compute the p-value
	preserve
		clear
		
		* Set the number of observations
		qui set seed `seed'
		qui set obs `ndraws'
		
		* Define the mean and variance-covariance matrix
		mat mu = 0, 0
		mat sig = (1, zcorr \ zcorr, 1)
		qui drawnorm z1 z2, n(`ndraws') cov(sig) means(mu)
		
		* Find min Z_{j} and find the p-value
		qui gen zmin = min(z1, z2)
		qui drop z1 z2
		qui sort zmin
		qui count if zmin <= mint
		scalar pval_mint = r(N)/`ndraws'
	restore
	
	// Step 3 - Return the p-value
	return scalar pval_mint = pval_mint
	
end
