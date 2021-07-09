*! version 1.0.0 13Jul2020
//-----------------------------------------------------------------------------
//
//	mivcausal - Testing the hypothesis about the signs of the 2SLS weights
//	Extract the list of variables from `anything'
//
//-----------------------------------------------------------------------------

capt program drop mivvars

program mivvars, sclass

	version 10.0
	syntax anything [if] [in] [, VCE(passthru) 								///
								 Robust 									///
								 CLuster(passthru)]

	// Step 1 - Extract the variable names
	gettoken vars xvars : anything, parse(" ,[") match(paren)
	
	// Step 2 - Check if there is anything before the parentheses
	* Count the number of words in vars
	local vn : word count `vars'
	
	* Message for incorrect syntax
	local varerrmsg "Error: The list of variables is specified "			///	
					"incorrectly. The list of variables should be " 		///
				    "'(D = Z1 Z2) X' where D is the endogenous variable, "	///
					"Z1 and Z2 are the instrumental variables and X " 		///
				    "is the list of covariates."
					
	* Return error if users put variables before the list of parentheses or 
	* if more than one set of parentheses is included
	if "`paren'" != "(" | strpos("`xvars'", "(") != 0 {
		di as error "`varerrmsg'"
		exit 498
	}	
	
	// Step 3 - Check the syntax of the terms inside the parenthesis
	* Return error if user does not put an equal sign inside the cluster of 
	* variables inside the parentheses
	if strpos("`vars'", "=") == 0 {
		di as error "`varerrmsg'"
		exit 498
	}	
	
	* Check the syntax
	scalar zstart = 0
	while `vn' != 0 {
		gettoken fvar vars : vars, parse(" =") match(paren)
		
		* Return error if the variables "vars" include any parentheses
		if "`paren'" == "(" {
			di as error "`varerrmsg'"
			exit 498
		}
		
		if "`fvar'" != "=" & zstart == 0 {
			local dvar `dvar' `fvar'
		}
		else if "`fvar'" == "=" {
			scalar zstart = 1
		}
		else {
			* Return error if the user puts more than one equal sign inside
			* the cluster of variables inside the parentheses
			if strpos("`vars'", "=") != 0 {
				di as error "`varerrmsg'"
				exit 498
			}	
			
			local zvars `zvars' `fvar'
		}
		
		* Count the remaining number of words
		local vn : word count `vars'
	}
	
	// Step 4 - Retokenize the variables
	local dvar : list retokenize dvar
	local zvars : list retokenize zvars
	local xvars : list retokenize xvars
	
	// Step 5 - Form the list of the variables explicitly if they include "*"
	* Treatment
	if strpos("`dvar'", "*") != 0 {
		local dvar_final `'
		foreach d of varlist `dvar' {
			local dvar_final `dvar_final' `d'
		}
	}
	else {
		local dvar_final `dvar'
	}
	
	* Instruments
	if strpos("`zvars'", "*") != 0 {
		local zvars_final `'
		foreach z of varlist `zvars' {
			local zvars_final `zvars_final' `z'
		}
	}
	else {
		local zvars_final `zvars'
	}
	
	// Step 6 - Count the number of variables dvar and zvars
	* Count the number of treatments
	local dn : word count `dvar_final'
	local zn : word count `zvars_final'
	
	* Return error if the number of variables is incorrect
	if `dn' != 1 {
		di as error "Error: There has to be one endogenous variable."
		exit 498
	}
	
	* Count the number of instruments
	if `zn' != 2 {
		di as error "Error: There have to be two binary instrumental variables."
		exit 498
	}
	
	// Step 7 - Check if the variables exist in the dataset
	foreach x of varlist `dvar_final' `zvars_final' `xvars' {
		capture confirm variable `x', exact
		if _rc != 0 {
			di as error "Error: The variable " `x' " does not exist in " 	///
						"the dataset."
			exit 498
		}
	}
	
	// Step 8 - Check variance
	* Parse the standard errors
	_vce_parse, optlist(Robust) argoptlist(CLuster) old : , `vce' 			///
															`robust'		///
															`cluster' 		

	// Step 9 - Assign the return list
	* Assign the return list of the variance
	if missing(r(vce)) {
		sreturn local vce "unadjusted"
	}
	else {
		sreturn local robust `r(robust)'
		sreturn local cluster `r(cluster)'
		sreturn local vceopt `r(vceopt)'
		sreturn local vceargs `r(vceargs)'
		sreturn local vce `r(vce)'
	}
	
	* Assign the return list of the variables
	sreturn local dvar `dvar_final'
	sreturn local zvars `zvars_final'
	sreturn local xvars `xvars'
	
end
