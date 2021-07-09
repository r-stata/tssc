*! version 1.0.0 13Jul2020
//-----------------------------------------------------------------------------
//
//	mivcausal - Testing the hypothesis about the signs of the 2SLS weights
//	Master file
//
//-----------------------------------------------------------------------------

capt program drop mivcausal

program mivcausal, rclass

	version 10.0
	syntax [anything] [if] [in] [, SEed(integer 1) 							///
								   PRECision(integer 3) 					///
								   MTDraws(integer 10000) 					///
								   RSW(passthru)							///
								   VCE(passthru)							///
								   Robust									///
								   CLuster(varlist)							]
								   
	// Step 1 - Extract the list of variables
	* If [anything] is nonempty, pick the list of variables from [anything]
	if "`anything'" != "" {
		* Call 'mivvars' to extract the list of variables in [anything]
		qui mivvars `anything', `vce' `robust' `cluster'
		
		* Store information from sreturn 
		local vinst_temp `s(xvars)' `s(zvars)'
		local xvars_temp `s(xvars)'
		local dvar `s(dvar)'
		local varopt `s(vce)'
		local clustvar `s(cluster)'
	}
	else {
		* Store information from ereturn 
		local vinst_temp `e(insts)'
		local xvars_temp `e(exogr)'
		local dvar `e(instd)'
		local yvar `e(depvar)'
		local varopt `e(vce)'
		local clustvar `e(clustvar)'
		
		* Check if there is one treatment and two instrumental variables
		local nd : word count `dvar'
		local ne : word count `xvars_temp'
		if `nd' != 1 & (`ne' - `nd') != 2 {
			di as error "Error: There has to be one endogenous variable " 	///
						"and two instrumental variables. "
			exit 498	
		}
	}

	// Step 2 - Drop the variables that are omitted in the 2SLS (i.e. variables 
	// with prefix "o." in the xvars) & define the list of the two instruments
	* Update xvars
	foreach x of local xvars_temp {
		local xtemp = substr("`x'", 1, 2)
		if "`xtemp'" != "o." {
			local xvars `xvars' `x'
		}
	}
	
	* Update insts
	foreach v of local  vinst_temp {
		local vtemp = substr("`v'", 1, 2)
		if "`vtemp'" != "o." {
			local vinst `vinst' `v'
		}	
	}
	
	* Define the list of the two instruments
	local xn : word count `xvars'
	local zvars ""
	forval i = 1/2 {
		local wordpos = `xn' + `i'
		local ztemp: word `wordpos' of `vinst'
		local zvars `zvars' `ztemp'
	} 
	
	// Step 3 - Check the data and input
	* If "rsw()" appears when the function is called, i.e. empty inside the
	* parentheses
	if strpos("`0'", "rsw()") > 0 {
		qui mivchecks `dvar' `zvars' `xvars', seed(`seed') 					///
											  prec(`precision') 			///
											  mtdraws(`mtdraws') 			///
											  rsw(`rsw')
	}
	* If "rsw" appears when the function is called:
	else if strpos("`0'", "rsw") > 0 {
		qui mivchecks `dvar' `zvars' `xvars', seed(`seed') 					///
											  prec(`precision') 			///
											  mtdraws(`mtdraws') 			///
											  `rsw'	
	}
	* Otherwise, assign the reps as 0 directly.
	else {
		qui mivchecks `dvar' `zvars' `xvars', seed(`seed') 					///
											  prec(`precision') 			///
											  mtdraws(`mtdraws') 			///
											  rsw(reps = 0)
	}

	* Retrieve the updated list of variables
	local dvar_new = r(dvar_new)
	local zvars_new = r(zvars_new)
	
	* Retrieve the number of replications for the RSW test (equals 0 if it is
	* not run)
	local rswreps = r(rswreps)

	// Step 4 - Ordinary and system regression
	qui mivreg `dvar_new' `zvars_new' `xvars', varopt("`varopt'") ///
											   cl(`clustvar')
									
	// Step 5 - Bonferroni test
	qui mivbon
	local pval_bon = r(pval_bon)
	
	// Step 6 - Mintest
	qui mivmint, seed(`seed') nd(`mtdraws')
	local pval_mint = r(pval_mint)
	
	// Step 7 - Cox and Shi (2019) test
	 mivcs
	local pval_cs = r(pval_cs)

	// Step 8 - Romano, Shaikh and Wolf (2014) test
	if `rswreps' != 0 {
		qui mivrsw `dvar_new' `zvars_new' `xvars', seed(`seed')				///
												   prec(`precision')	 	///
												   boot(`rswreps')			///
											       varopt("`varopt'") 		///
												   cl(`clustvar')	
		local pval_rsw = r(pval_rsw)
	}
	
	// Step 9 - IUT
	qui miviut
	local pval_iut = r(pval_iut)
	
	// Step 10 - Return the p-values, parameters and variables
	return clear

	* Return the p-value
	return scalar pval_bon = `pval_bon'
	return scalar pval_cs = `pval_cs'
	return scalar pval_mint = `pval_mint'
	if `rswreps' != 0 {
		return scalar pval_rsw = `pval_rsw'
	}
	return scalar pval_iut = `pval_iut'
	
	* Return the parameters
	return scalar seed = `seed'	
	return scalar precision = `precision'
	return scalar mtdraws = `mtdraws'
	if `rswreps' != 0 {
		return scalar rswreps = `rswreps'
	}
	return local vce `varopt'
	return local cluster `clustvar'
	
	* Return the variables
	return local insts `vinst_temp'
	return local exogr `xvars_temp'
	return local instd `dvar'
	return local depvar `yvar'
	
	* Return the commands
	return local title "Testing hypotheses about the signs of the 2SLS weights"
	return local cmd "mivcausal"
	
	// Step 11 - Print the results
	* Precision parameter
	scalar prec = 10^(-`precision')

	* Print the results
	di _newline as result "Results from mivcausal:"
	di "{hline 26}{c TT}{hline 35}{c TT}{hline 15}"
	di _col(3) "Null hypothesis" 											///
	   _col(27) "{c |}" "  Test" 		  									///
	   _col(63) "{c |}" "  p-value"
	di as text "{hline 26}{c +}{hline 35}{c +}{hline 15}"
	di _col(3) "All weights positive"										///
	   _col(27) "{c |}" "  Bonferroni" 		  								///
	   _col(63) "{c |}" "  " round(`pval_bon', prec)
	di _col(27) "{c |}" "  Cox and Shi (2019)" 		  						///
	   _col(63) "{c |}" "  " round(`pval_cs', prec)	   
	di _col(27) "{c |}" "  Mintest" 		  								///
	   _col(63) "{c |}" "  " round(`pval_mint', prec)	   
	if `rswreps' != 0 {
		di _col(27) "{c |}" "  Romano, Shaikh and Wolf (2014)" 		  		///
		   _col(63) "{c |}" "  " round(`pval_rsw', prec)	   
	}
	di as text "{hline 26}{c +}{hline 35}{c +}{hline 15}"
	di _col(3) "Some weights negative"										///
	   _col(27) "{c |}" "  Intersection-union test" 		 				///
	   _col(63) "{c |}" "  " round(`pval_iut', prec)
	di as text "{hline 26}{c BT}{hline 35}{c BT}{hline 15}"
	
	* Print the parameters used
	di as result "Parameters:"
	di as text "* Precision (decimal places) = " `precision'
	di as text "* Number of draws in Mintest = "  `mtdraws'
	if `rswreps' != 0 {
		di as text "* Number of bootstraps in the Romano, Shaikh and Wolf " ///
				   "(2014) test = " `rswreps'
	}
	  
	* Display messages on the treatment and instruments if necessary
	if nvarerr != 0 {
		* Generic message
		scalar varerrmsg1 = "The following "
		scalar varerrmsg2 = "not binary with values of either 0 or 1. "
		scalar varerrmsg3 = "used to conduct the tests."
		
		* Display message header
		if nvarerr == 1 {
			di as result  "Remark:"
			di as text varerrmsg1 "variable is " varerrmsg2 				///
								  "A temporary variable is " varerrmsg3
		} 
		else {
			di as result  "Remarks:"
			di as text varerrmsg1 "variables are " varerrmsg2 				///
								  "Temporary variables are " varerrmsg3
		}
		
		* Display the corresponding variables
		scalar k = 1
		foreach vartemp of varlist `dvar' `zvars' {
			if varerrval[k, 1] != . {
				di as text "* " "`vartemp'" " (" "`vartemp'" " = "			///
						   varerrval[k, 1] " is assigned as 1 and " 		///
						   "`vartemp'" " = " varerrval[k, 2] " is " 		///
						   "assigned as 0) "
			}
			scalar k = k + 1
		}
	}
	
end
