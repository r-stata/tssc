* PROGRAMME FOR IMPUTER [wmlogit, md(varname) marginal]
* Factor variables not allowed
* Return scalar for negative weights
*! version 1.1 TPham 21dec2016

program mi_impute_cmd_wmlogit
	version 14.1
	
	qui	{
	
	* Define weight variable from the weight global macros created in the initialiser
	tempvar pwmi
	gen `pwmi' = .
		
	foreach i of global MI_IMPUTE_userdef_ivarcat {		
		replace `pwmi' = ${MI_IMPUTE_userdef_pwmi_`i'} if $MI_IMPUTE_user_ivar == `i'	
	}
		
	replace `pwmi' = 1.e-05 if $MI_IMPUTE_user_miss & `pwmi' == .
	
	* Perform a single imputation by uvis
	* uvis does not have baseoutcome(#) option
	tempvar ivar_imp
	uvis mlogit $MI_IMPUTE_user_ivar $MI_IMPUTE_user_xvars [pw = `pwmi'], gen(`ivar_imp')
	
	replace $MI_IMPUTE_user_ivar = `ivar_imp' if $MI_IMPUTE_user_miss
	
	}
	
end
	
	
	
	
