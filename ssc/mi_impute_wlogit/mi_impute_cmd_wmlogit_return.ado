* PROGRAMME FOR STORING RESULTS [wmlogit, md(varname) marginal]
* Factor variables not allowed
* Return scalar for negative weights
*! version 1.1 TPham 21dec2016

program mi_impute_cmd_wmlogit_return, rclass
	version 14.1
	
	qui	{
	
	* RETURN A WEIGHT MATRIX
	
	foreach i of global MI_IMPUTE_userdef_ivarcat {
		local pwmi_list `pwmi_list' ${MI_IMPUTE_userdef_pwmi_`i'} 	
		local pwmi_colnames = "`pwmi_colnames' "  + "`i'.$MI_IMPUTE_user_ivar"
	}   
	
	mat input pw = (`pwmi_list') 
	mat colnames pw = `pwmi_colnames'
	mat rownames pw = "pwmi"
	
	ret mat pwmi = pw 
	
	* RETURN TYPES OF WEIGHTS
	if "$MI_IMPUTE_userdef_w" == "marginal"	{
		ret local wtype = "marginal"
	}
	else	{
		ret local wtype = "conditional"
	}
	
	}
	
	* RETURN SCALAR FOR NEGATIVE WEIGHTS
	if $MI_IMPUTE_userdef_negw == 1	{
		ret scalar negw = 1
	}
	else	{
		ret scalar negw = 0
	}

end

