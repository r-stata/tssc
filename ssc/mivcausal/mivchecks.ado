*! version 1.0.0 13Jul2020
//-----------------------------------------------------------------------------
//
//	mivcausal - Testing the hypothesis about the signs of the 2SLS weights
//	Checking data and input
//
//-----------------------------------------------------------------------------

capt program drop mivchecks

program mivchecks, rclass
	
	version 10.0
	syntax anything [if] [in] [, SEEd(integer 1) 							///
								 PRECision(integer 3) 						///
								 MTDraws(integer 10000) 					///
								 RSW(passthru)]
								   
	// Step 1 - Check whether the parameters `precision' and `mtdraws'
	// are positive (they have to be integers so that this function is called)
	* Generic error message
	scalar gen_error = "Error: Please input a positive integer for "
	
	* Check `precision'
	if `precision' <= 0 {
		di as error gen_error "'precision'."
		exit 498
	}
	
	* Check `mtdraws'
	if `mtdraws' <= 0 {
		di as error gen_error "'mtdraws'."
		exit 498 
	}

	// Step 2 - Check whether RSW should be called and the number of reps for
	// the RSW test
	* RSW error messages
	local rswerr "Error: The option for the RSW test is rsw(reps = x) "		///
				 "where x is a positive integer representing the number "	///
				 "of replications."
	
	* If RSW is missing, check if it is because user did not specify anything
	* inside the parentheses. 
	if missing("`rsw'") {
		* If yes, assign the default number of reps as 1000.
		if strpos("`0'", "rsw") > 0 {
			local rswreps 1000
		}
		* Otherwise, assign the default number of reps as 0.
		else {
			local rswreps 0 
		}
	}
	* Otherwise, check whether the RSW syntax is correct and extract the number
	* of reps.
	else {
		* Extract the RSW syntax
		gettoken rsw1 rsw2 : rsw, parse("(") match(paren)
		if "`rsw1'" != "rsw" {
			local rswreps 0
		}
		else {
			* Extract the cluster inside the parentheses
			gettoken rsw3 rsw4 : rsw2, match(paren)

			* Assign the default number of replications if nothing is inside
			* the parentheses
			if "`rsw2'" == "" {
				local rswreps 1000
			}
			
			* Check if the syntax is correct. If correct, it should be empty 
			* here.
			if "`rsw4'" != "" {
				di as error "`rswerr'"
				exit 498
			}
		
			* Split the parts before and after the equal sign
			gettoken rsw5 rsw6 : rsw3, match(paren)
			if lower("`rsw5'") != "reps" {
				di as error "`rswerr'"
				exit 498
			}
			
			* Extract the number of reps
			gettoken rsw7 rsw8 : rsw6, match(paren)
			local rswsign : list retokenize rsw7
			local rswreps : list retokenize rsw8
		
			* Check if the user put an equal sign
			if lower("`rswsign'") != "=" {
				di as error "`rswerr'"
				exit 498
			}
		
			* Check the number of reps (Allow 0 here, which means the test will 
			* be skipped)
			if `rswreps' < 0 {
				di as error gen_error "the number of replications for the " ///
									  "RSW test."
				exit 498
			}
		}
	}
	
	* Return whether the RSW test is run and the number of replications
	return local rswreps = `rswreps'
	
	// Step 3 - Check whether there is one treatment and two instruments
	// This is checked by there must be at least three variables
	* Count the number of variables
	local nvar : word count `anything'
	if `nvar' < 3 {
		di as error "Error: There has to be at least three variables for " 	///
					"the 'mivcausal' module (one binary treatment and "   	///
					"two binary instruments)."
		exit 498	
	}
	
	// Step 4 - Retrieve the treatment, instruments and covariates
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
	
	// Step 5 - Check whether the treatment and instruments are binary
	* Define generic messages
	scalar msg1 = "Error: The variable '"
	scalar msg2 = "' has to be binary."
	
	* Check the treatment and instruments
	foreach vartemp of varlist `zvars' `dvar' {
		qui tab `vartemp'
		if r(r) != 2 {
			di as error msg1 "`vartemp'" msg2
			exit 498
		}
	}
	
	// Step 6 - Convert to treatment and instruments to 0 and 1 if they are
	// not already binary with 0 and 1 being the only possible values
	* Dummy variable to store the list of variables that are not 0 or 1
	local varerr `'
	mat varerrval = J(3, 2, .)
	
	* Initialize two scalars
	scalar nvarerr = 0
	scalar k = 1
	
	* Empty local variables to contain the updated variables
	local dvar_new `'
	local zvars_new `'
	
	* Inspect the treatment and instruments
	foreach vartemp of varlist `dvar' `zvars' {
		* Check the variable
		cap assert `vartemp' == 0 | `vartemp' == 1
		
		* Generate a variable that represents the variable if it is non 0 or 1
		if _rc != 0 {
			* Update the counter for variables being updated
			scalar nvarerr = nvarerr + 1
			
			* Obtain the max and min of the variable
			qui sum `vartemp'
			scalar vartemp_1 = r(max)
			scalar vartemp_0 = r(min)
			
			* Define the initial name for the variable
			local binarytemp `vartemp'_bin
			cap confirm variable `binarytemp', exact
			
			* Add some random integers to the variable name until the variable
			* name does not exist
			while _rc == 0 {
				local binarytemp `binarytemp'`=runiformint(1,100)'
				cap confirm variable `binarytemp', exact
			}
			
			* Generate the binary variable
			qui gen `binarytemp' = 1 if `vartemp' == vartemp_1
			qui replace `binarytemp' = 0 if `vartemp' == vartemp_0
			
			* Add the variable to the list
			mat varerrval[nvarerr, 1] = vartemp_1
			mat varerrval[nvarerr, 2] = vartemp_0
			
			* Assign the list of variables that are updated
			local varerr `varerr' `vartemp'
			
			* Assign the new list of variables with the updated variable
			if k == 1 {
				local dvar_new `dvar_new' `binarytemp'
			}
			else {
				local zvars_new `zvars_new' `binarytemp'
			}
		}
		else {
			* Assign the original variable in the updated list if the variable
			* is already either 0 or 1
			if k == 1 {
				local dvar_new `dvar_new' `dvar'
			}
			else {
				local zpos = k - 1
				local ztemp: word `zpos' of `zvars'
				local zvars_new `zvars_new' `ztemp'
			}
		}
		
		* Update counter
		scalar k = k + 1
	}
	
	// Step 7 - Return the list of variables that are updated
	return local varerr `varerr'
	return local dvar_new `dvar_new'
	return local zvars_new `zvars_new'
	
end
