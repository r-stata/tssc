* PROGRAMME FOR INITIALISER [wlogit, md(varname) marginal]
* Factor variables not allowed
* Return scalar for negative weights
*! version 1.1 TPham 21dec2016

program mi_impute_cmd_wlogit_init
	version 14.1
	
	qui	{
	
	* CHECK IF IVAR IS 0/1
	
	summ $MI_IMPUTE_user_ivar
	if r(min) != 0 & r(max) != 1	{
		di as err "$MI_IMPUTE_user_ivar is not coded as 0/1"
		exit 2000
	}
	
	* ERRORS FOR WHEN OPTIONS -md(varname)- or -marginal- ARE INCORRECTLY SPECIFIED
	
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

	* CALCULATE WEIGHTS FOR WEIGHTED MULTIPLE IMPUTATION 
	
	* Count total number of observations with observed and missing ivar
	
	count if !$MI_IMPUTE_user_miss
	local N_obs = r(N)
	count if $MI_IMPUTE_user_miss
	local N_mis = r(N)
	
	* Global macro for negative weights to be used later 
	
	global MI_IMPUTE_userdef_negw = 0
	
	/* MARGINAL WEIGHTS */

	if "$MI_IMPUTE_userdef_w" == "marginal"	{
		forval i = 0/1 {
			count if $MI_IMPUTE_user_ivar == `i'
			local N_obs`i' = r(N)
			
			summ $MI_IMPUTE_userdef_md if $MI_IMPUTE_user_ivar == `i'
	
			local pwreq_`i' = (r(mean)*_N - `N_obs`i'') / `N_mis'
			global MI_IMPUTE_userdef_pwmi_`i' = 1/((`N_obs`i''/`N_obs')/`pwreq_`i'')
			
			if ${MI_IMPUTE_userdef_pwmi_`i'} <= 0	{
				noi di as err "warning: non-positive weight encountered for $MI_IMPUTE_user_ivar = `i'; weight replaced with 1.e-05"
				global MI_IMPUTE_userdef_pwmi_`i' = 1.e-05
				global MI_IMPUTE_userdef_negw = 1
			}
		
		}
	}
	
	/* CONDITIONAL WEIGHTS */
	
	else	{
						 
		* Category-wise count of complete ivar after fitting the MAR imputation 
		* model to the complete cases and replacing missing ivar with predicted
		* values using predicted probabilities
		
		logit $MI_IMPUTE_user_ivar $MI_IMPUTE_user_xvars
		tempvar p_marmi
		predict `p_marmi', p
		
		* Count the number of ivar = 0 and ivar = 1 in the missing data
		* as predicted by the MAR imputation model
		
		summ `p_marmi' if $MI_IMPUTE_user_miss
		local ivar_mis1 = round(r(sum),1)
		local ivar_mis0 = `N_mis' - `ivar_mis1'
		
		forval i = 0/1	{	
			summ $MI_IMPUTE_user_ivar if $MI_IMPUTE_user_ivar == `i'
			
			* Total number of ivar post fitting MAR imputation model
			local ivar`i' = r(N) + `ivar_mis`i''
			
			summ $MI_IMPUTE_userdef_md if $MI_IMPUTE_user_ivar == `i'

			local pwreq_`i' = (r(mean)*_N - (`ivar`i''/_N) *`N_obs') / `N_mis'
			global MI_IMPUTE_userdef_pwmi_`i' = 1/((`ivar`i''/_N)/`pwreq_`i'')
			
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
		noi di _newline as text "Running " as result "wlogit " as text "on observed data:"
		
		tempvar pwmi
		gen `pwmi' = .
		
		forval i = 0/1 {
			replace `pwmi' = ${MI_IMPUTE_userdef_pwmi_`i'} if $MI_IMPUTE_user_ivar == `i'
		}
		
		* uvis does not produce any imputation when pw == 0 | pw == .
		
		replace `pwmi' = 1.e-05 if $MI_IMPUTE_user_miss & `pwmi' == .
	
		noi logit $MI_IMPUTE_user_ivar $MI_IMPUTE_user_xvars [pw = `pwmi']
	}
	
	}
	
	end

