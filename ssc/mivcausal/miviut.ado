*! version 1.0.0 13Jul2020
//-----------------------------------------------------------------------------
//
//	mivcausal - Testing the hypothesis about the signs of the 2SLS weights
//	IUT
//
//-----------------------------------------------------------------------------

capt program drop miviut

program miviut, rclass

	version 10.0
	syntax [anything] [if] [in]
	
	// Step 1 - Compute the p-value of IUT
	mat qneg = J(1, 2, 0)
	
	* Compute the test statistic (using the info from Bonferroni test)
	forval i = 1/2 {
		mat qneg[1, `i'] = 1 - pbon_temp[1, `i']
	}
	
	* Compute the p-value
	scalar pv = max(qneg[1, 1], qneg[1, 2])

	// Step 2 - Return the p-value
	return scalar pval_iut = pv	
	
end
