* PROGRAMME FOR INITIALISER [wmlogit, md(varname) marginal]
* Factor variables not allowed
* Return scalar for negative weights
*! version 1.1 TPham 21dec2016

program mi_impute_cmd_wmlogit_init
	version 14.1
	
	qui	{
	
*** ERRORS FOR WHEN OPTIONS -md(varname)- or -marginal- ARE INCORRECTLY SPECIFIED

	if "$MI_IMPUTE_userdef_md" == ""	{
		noi di as err "marginal distribution of $MI_IMPUTE_user_ivar not found"
		exit 111
	}
	
	else	{
		cap assert !missing($MI_IMPUTE_userdef_md) if !$MI_IMPUTE_user_miss
		if _rc == 9	{
			noi di as err "missing data found in $MI_IMPUTE_userdef_md when $MI_IMPUTE_user_ivar is observed"
			exit 498
		}
	}
	
	if "$MI_IMPUTE_user_options" != ""	{
		local options "$MI_IMPUTE_user_options"
		gettoken op1: options
		noi di as err "option `op1' not allowed"
		exit 198
	}
	
	* Display weights used in weighted multiple imputation
	if "$MI_IMPUTE_userdef_w" == "marginal"	{
		noi di _newline as text "Imputing " as result "$MI_IMPUTE_user_ivar " as text "using " as result "marginal " as text "weights"
	}
	
	else	{
		noi	di _newline as text "Imputing " as result "$MI_IMPUTE_user_ivar " as text "using " as result "conditional " as text "weights"
	}	

*** CALCULATE WEIGHTS FOR WEIGHTED MULTIPLE IMPUTATION 
	
	* Count total number of observations with observed and missing ivar
	count if !$MI_IMPUTE_user_miss
	local N_obs = r(N)
	count if $MI_IMPUTE_user_miss
	local N_mis = r(N)
	
	* Create a macro list of categories of ivar by creating a tempvar ivar
	* to remove labels attached to $MI_IMPUTE_user_ivar
	tempvar ivar 
	gen `ivar' = $MI_IMPUTE_user_ivar
	mlogit `ivar' 
	global MI_IMPUTE_userdef_ivarcat = e(eqnames)
	
	* Global macro for negative weights to be used later 
	global MI_IMPUTE_userdef_negw = 0
	
	* CALCULATION OF MARGINAL WEIGHTS

	if "$MI_IMPUTE_userdef_w" == "marginal"	{
		
		foreach i of global MI_IMPUTE_userdef_ivarcat {
			count if $MI_IMPUTE_user_ivar == `i'
			local N_obs`i' = r(N)
			
			summ $MI_IMPUTE_userdef_md if $MI_IMPUTE_user_ivar == `i'
	
			* Calculate pwreq in the missing data and pwmi for wMI
			local pwreq_`i' = (r(mean)*_N - `N_obs`i'') / `N_mis'			
			global MI_IMPUTE_userdef_pwmi_`i' = 1/((`N_obs`i''/`N_obs')/`pwreq_`i'') 
			
			* Warning message for negative or 0 weights
			if ${MI_IMPUTE_userdef_pwmi_`i'} <= 0	{
				noi di as err "warning: non-positive weight encountered for $MI_IMPUTE_user_ivar = `i'; weight replaced with 1.e-05"
				global MI_IMPUTE_userdef_pwmi_`i' = 1.e-05
				global MI_IMPUTE_userdef_negw = 1
			}
		
		}
	}
	
	* CALCULATION OF CONDITIONAL WEIGHTS
	
	else	{
						 
		* Category-wise count of complete ivar after fitting the MAR imputation 
		* model to the complete cases and replacing missing ivar with predicted
		* values using predicted probabilities
		mlogit $MI_IMPUTE_user_ivar $MI_IMPUTE_user_xvars
		
		foreach i of global MI_IMPUTE_userdef_ivarcat	{
			
			* Obtain predicted probability for each ivarcat
			tempvar p`i'
			predict `p`i'', p outcome(`i')
			summ `p`i'' if $MI_IMPUTE_user_miss
			
			* Obtain predicted number for each ivarcat in the missing data
			* and in the complete data 
			local N_mis`i' = round(r(sum), 1)
			count if $MI_IMPUTE_user_ivar == `i'
			local N_obs`i' = r(N)
			local N_comp`i' = `N_obs`i''  + `N_mis`i''
			
			summ $MI_IMPUTE_userdef_md if $MI_IMPUTE_user_ivar == `i'
			
			* Calculate pwreq in missing data, and pwmi for wMI
			local pwreq_`i' = (r(mean)*_N - (`N_comp`i''/_N) *`N_obs') / `N_mis'
			global MI_IMPUTE_userdef_pwmi_`i' = 1/((`N_comp`i''/_N)/`pwreq_`i'') 	

			* Warning message for negative or 0 weights
			if ${MI_IMPUTE_userdef_pwmi_`i'} <= 0	{
				noi di as err "warning: non-positive weight encountered for $MI_IMPUTE_user_ivar = `i'; weight replaced with 1.e-05"
				global MI_IMPUTE_userdef_pwmi_`i' = 1.e-05
				global MI_IMPUTE_userdef_negw = 1
			}
		}
	}
	
	* OUTPUT DISPLAY FOR NOISILY OPTION
	
	if "$MI_IMPUTE_user_opt_noisily" == "noisily"	{
		noi di _newline as text "Running " as result "wmlogit " as text "on observed data:"
		
		tempvar pwmi
		gen `pwmi' = .
		
		foreach i of global MI_IMPUTE_userdef_ivarcat	{
			replace `pwmi' = ${MI_IMPUTE_userdef_pwmi_`i'} if $MI_IMPUTE_user_ivar == `i'
		}
		
		* uvis does not produce any imputation when pw == 0 | pw == .
		* replace pw with small weights for subjects with missing ivar
		replace `pwmi' = 1.e-05 if $MI_IMPUTE_user_miss & `pwmi' == .
	
		noi mlogit $MI_IMPUTE_user_ivar $MI_IMPUTE_user_xvars [pw = `pwmi']
	}
	
	}
	
	end

