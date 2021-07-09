*! version 1.0.0 13Jul2020
//-----------------------------------------------------------------------------
//
//	mivcausal - Testing the hypothesis about the signs of the 2SLS weights
//	Test by Romano, Shaikh and Wolf (2014)
//
//-----------------------------------------------------------------------------

capt program drop mivrsw mivrsw_firststep

//-----------------------------------
// Main function for the RSW test
//-----------------------------------
program mivrsw, rclass

	version 10.0
	syntax anything [if] [in] [, SEEd(integer 1) 							///
								 PRECision(integer 2)						///
								 BOOTstrap(integer 1000)					///
								 VAROPTion(string)							///
								 CLuster(varlist)]

	// Step 1 - Compute the test statistics (from Mintest)
	scalar That_rsw = max(-t_mint[1, 1], -t_mint[1, 2])
	
	// Step 2 - First-step bootstrap
	* Initialize the matrices
	mat mu_rsw = J(`bootstrap', 2, 0)
	mat bsfirst = J(`bootstrap', 3, 0)
	
	* Conduct the bootstrap using the function `mivrsw_firststep'
	forval b = 1/`bootstrap' {
		* Bootstrap and regression
		local b_seed = `b' + `seed' - 1
		qui mivrsw_firststep `anything', varopt(`varoption') seed(`b_seed')	///
									     cl(`cluster')
		
		* Obtain the bootstrap estimators
		forval k = 1/2 {
			mat mu_rsw[`b', `k'] = r(bs`k')
			mat bsfirst[`b', `k'] = 										///
				sqrt(NN) * (mu_rsw[`b', `k'] + 								///
				thetaols[1, `k']) / thetasys[1, `k']
		}
		mat bsfirst[`b', 3] = max(bsfirst[`b', 1], bsfirst[`b', 2])
	}
	
	// Step 3 - Second-step bootstrap
	* Initialize the matrices
	scalar pchange = 0.1^(`precision')
	scalar pv = -pchange
	scalar rswdecision = 0
	
	* Initiate the for-loop to get the p-value
	while ((rswdecision == 0) & (pv <= 1)) {
		* Update the candidate p-value
		scalar pv = pv + pchange
	
		* Compute the required percentile
		preserve
			clear
			
			* Generate data from matrix
			qui svmat bsfirst
			
			* Compute quantile
			local beta = 100 * (1 - pv * .1)
			if `beta' == 100 {
				qui sum bsfirst3
				scalar rquan = r(max)
			}
			else if `beta' == 0 {
				qui sum bsfirst3
				scalar rquan = r(min)				
			}
			else {
				qui _pctile bsfirst3, p(`beta')
				scalar rquan = r(r1)
			}
		restore
		
		* Compute r-star
		mat rstar = J(1, 2, 0)
		forval i = 1/2 {
			mat rstar[1, `i'] = 											///
				-thetaols[1, `i'] + thetasys[1, `i'] * rquan / sqrt(NN)
		}
		
		* Determine whether the second-step is required
		if (rstar[1, 1] <= 0 & rstar[1, 2] <= 0) {
			scalar rswdecision = 0
		}
		else {
			* Initialize the matrices
			mat bssecond = J(`bootstrap', 3, 0)
			mat lambdastar = J(1, 2, 0)
			
			* Compute lambda-star
			forval i = 1/2 {
				mat lambdastar[1, `i'] =  min(0, rstar[1, `i'])
			}
			
			preserve
				clear
				
				* Make the variables from matrix
				qui svmat bsfirst
				
				* Make the new variables
				forval i = 1/2 {
					qui gen bssecond`i' = 									///
						sqrt(NN) * lambdastar[1, `i'] / thetasys[1, `i'] - 	///
						bsfirst`i'
				}
				
				* Gen the maximum of the two
				qui gen bssecond3 = max(bssecond1, bssecond2)
				
				* Save the matrix
				qui mkmat bssecond3, matrix(bssecond3)
			restore

			
			* Compute the required percentile and the critical value
			preserve
				clear
				
				* Make the variables from matrix
				qui svmat bssecond3
				
				* Compute quantile
				local secondstep = 100 * (1 - pv + .1 * pv)
				if `secondstep' == 100 {
					qui sum bssecond3
					scalar cv_rsw = r(max)
				}
				else if `secondstep' == 0 {
					qui sum bssecond3
					scalar cv_rsw = r(min)				
				}
				else {
					qui _pctile bssecond3, p(`secondstep')
					scalar cv_rsw = r(r1)
				}
			restore
			
			* Update the decision
			if That_rsw > cv_rsw {
				scalar rswdecision = 1
			}
		}
	}
	
	// Step 4 - Return the p-value
	return scalar pval_rsw = pv
		
end

//-----------------------------------
// Function for the first-step bootstrap in the RSW test
//-----------------------------------
program mivrsw_firststep, rclass

	version 10.0
	syntax anything [, VAROPTion(string) 									///
					   SEEd(integer 1)										///
					   CLuster(varlist)]
	
	// Step 1 - Retrieve the treatment, instruments and covariates
	* Treatment
	local dvar: word 1 of `anything'
	
	* Instruments
	local zvars ""
	forval i = 2/3 {
		local ztemp: word `i' of `anything'
		local zvars `zvars' `ztemp'
	}
	
	* Covariates
	local vardrop `dvar' `zvars'
	local xvars: list anything - vardrop
	
	// Step 2 - Bootstrapping procedure
	preserve
		* Set seed and bootstrap
		set seed `seed'
		qui bsample NN
		
		// Step 3 - Regress Z on D and X
		* Initialize vector to store the coefficients and standard errors
		scalar j = 1
		
		* Regress Z_{j} on D and X
		foreach z of local zvars {
			if "`varoption'" == "unadjusted" {
				qui reg `dvar' `z' `xvars'
			}
			else if "`varoption'" == "robust" {
				qui reg `dvar' `z' `xvars', `varoption'
			}
			else if "`varoption'" == "cluster" {
				qui reg `dvar' `z' `xvars', cluster(`cluster')
			}
			
			* Store the coefficients
			qui mat rtab_rsw = r(table)
			return scalar bs`=j' = -rtab_rsw[1,1]
			scalar j = j + 1
		}
	restore
	
end
