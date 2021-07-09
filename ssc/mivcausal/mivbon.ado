*! version 1.0.0 13Jul2020
//-----------------------------------------------------------------------------
//
//	mivcausal - Testing the hypothesis about the signs of the 2SLS weights
//	Bonferroni test
//
//-----------------------------------------------------------------------------

capt program drop mivbon

program mivbon, rclass
	
	version 10.0
	syntax [anything] [if] [in]
	
	// Step 1 - Compute the p-values from the one-sided tests.
	* Define the q parameters
	mat pbon_temp = J(1, 2, 0)
	mat qpos = J(1, 2, 0)
	
	* Compute the p-value from each regression
	forval i = 1/2 {
		mat pbon_temp[1, `i'] = normal(thetaols[1, `i']/thetaols[2, `i'])
		mat qpos[1, `i'] = min(1, 2 * pbon_temp[1, `i'])
	}
	
	// Step 2 - Compute p-value of the Bonferroni test
	* Compute the p-value of the Bonferroni test
	scalar pval_bon = min(qpos[1, 1], qpos[1, 2])
	
	// Step 3 - Return the p-value
	return scalar pval_bon = pval_bon

end
