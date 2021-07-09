*! version 1.0.0 13Jul2020
//-----------------------------------------------------------------------------
//
//	mivcausal - Testing the hypothesis about the signs of the 2SLS weights
//	Regression and system regressions
//
//-----------------------------------------------------------------------------

capt program drop mivreg

program mivreg, rclass
	
	version 10.0
	syntax anything [if] [in] [, VAROPTion(string) CLuster(varlist)]
	
	// Step 1 - Retrieve the treatment, instruments, covariates and other info
	* Treatment
	local dvar : word 1 of `anything'
	
	* Instruments
	local zvars ""
	forval i = 2/3 {
		local ztemp : word `i' of `anything'
		local zvars `zvars' `ztemp'
	}
	
	* Covariates
	local vardrop `dvar' `zvars'
	local xvars: list anything - vardrop
	
	* Count the number of covariates
	local xn : word count `xvars'
	
	* Count the total number of observations
	qui des
	scalar NN = r(N)
	
	// Step 2 - OLS
	* Initialize vector to store the coefficients and standard errors
	qui mat thetaols = J(2, 2, 0)
	scalar k = 1
	
	* Regress Z_{j} on D and X
	foreach z of local zvars {
	
		* Run the standard OLS without adjusting errors 
		qui reg `dvar' `z' `xvars'
		
		* Check if the variable name for the fitted value already exists
		local estnametemp zhat`=k'
		capture confirm variable _est_`estnametemp', exact
		
		* Add some random integers to the variable name until the variable name
		* does not exist
		while _rc == 0 {
			local estnametemp `estnametemp'`=runiformint(1,100)'
			cap confirm variable _est_`estnametemp', exact
		}
		
		* Store estimates
		qui est store `estnametemp'
		local zest`=k' `estnametemp'
		
		* If a nonstandard error or variance is used, store the coefficients
		* based on the updated OLS
		if "`varoption'" == "robust" {
			qui reg `dvar' `z' `xvars', `varoption'
		}
		else if "`varoption'" == "cluster" {
			qui reg `dvar' `z' `xvars', cluster(`cluster')
		}

		* Store the coefficients
		mat rtab_temp = r(table)
		mat thetaols[1, k] = rtab_temp[1, 1]
		mat thetaols[2, k] = rtab_temp[2, 1]
		scalar k = k + 1
	}
	
	// Step 3 - System regression
	mat thetasys = J(1, 2, 0)
	
	* System regression
	if "`varoption'" == "unadjusted" {
		qui suest `zest1' `zest2'
	}
	else if "`varoption'" == "robust" {
		qui suest `zest1' `zest2', `varoption'
	}
	else if "`varoption'" == "cluster" {
		qui suest `zest1' `zest2', cluster(`cluster')
	}
	
	* Drop the variables
	qui drop _est_`zest1' _est_`zest2'
	
	* Extract the r(table)
	mat rtab_tempsys = r(table)
	
	* Obtain the asymptotic s.d. of the first variable in the system regression
	mat thetasys[1, 1] = rtab_tempsys[2, 1] * sqrt(NN - 1)
	
	* Obtain the asymptotic s.d. of the second variable in the system regression
	* "+4" in the r(table) to cater for two _cons
	mat thetasys[1, 2] = rtab_tempsys[2, 4 + `xn'] * sqrt(NN - 1)
	
	* Obtain the asymptotic covariance between Z1 and Z2
	mat emat = e(V)
	scalar zcov = emat[4 + `xn', 1] * (NN - 1)
	mat Zcov = (thetasys[1, 1]^2, zcov \ zcov, thetasys[1, 2]^2)
	scalar zcorr = zcov/(thetasys[1, 1] * thetasys[1, 2])
	
end
