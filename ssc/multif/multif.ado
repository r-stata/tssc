*!Construct multiple if conditions with the same value for different variables
*!Version 1.15: Added an option to display the created restriction (20.06.2018)
*!Version 1.1: Added an experimental test to make sure that the varid exists in conditions.
*!Version 1.05: Added two options for additional if conditions, which work only for the command option
*!Version 1.0: Contains basic functionality
capture program drop multif
program define multif, rclass
version 10.0
	syntax varlist(min=2),  CONDition(string) CONnection(string) [COMmand(string) COMOPTion(string) VARid(string) ADDif(string) ADDCon(string) test DISPlay] 
	*Parse syntax
	local vars `varlist'
	if "`varid'"=="" local varid VAR
	*Check if varid is correctly set in condition
	/*
	if strmatch("`condition'", "`varid'")
	*/
	if "`test'"!="" ParseCondError ,cond(`condition') varid(`varid')
	
	if "`addif'"=="" & "`addcon'"!=""{
		disp as err "Option addcon() only allowed {ul on}together{ul off} with option addif()"
		exit
	}
	if  "`addif'"!="" & "`addcon'"=="" local addcon &
	if "`comoption'"!="" local compoption , `comoption'
	local varcount: word count `vars' 
	
	*Start substitution 
	local varcounter 0
	foreach var of local vars{
		local ++varcounter
		*local cond: subinstr local condition "`varid'" "`var'"
		local cond = subinstr("`condition'","`varid'", "`var'",.)
		if "`varcounter'"=="`varcount'"{
			local multif "`multif' `cond'"
		}
		else{
			local multif "`multif' `cond' `connection'"
		}
	}
	return local multif = "`multif' `addcon' `addif'"
	if "`display'"!=""{
		display "The resulting multiple restrictions expressions is:"
		display " `multif' `addcon' `addif'"
	}
	*return local addif = "`addif'" 
	if "`command'"!=""{
		`command' if `multif' `addcon' `addif' `comoption'
	}
	

end

*Does not work yet for all cases
program define ParseCondError
	syntax,  cond(string) varid(string)
	local 0 `cond'
	/*
	Moving forward through the string does not work yet correctly
	Need to find a way to ... Draw path of string by hand to understand the correct way
	
	if strlen("`0'")<6{
		disp as error 
		exit
	}*/
	local conds 0
	while strlen("`0'")>1{
		local ++conds
		gettoken left right:0, parse("(")
		*disp "`0'"
		gettoken left right:right, parse("(")
		*disp " Left: `left' Right: `right'"
		gettoken left right:right, parse(")")
		*disp "Left: `left' Right: `right'"
		if  !strmatch("`left'","*`varid'*"){
			disp as error "Variable identifiers are not the same in all conditions!"
			disp as error "Please correct condition number `conds' or change the variable identifier with the option varid()"
			exit
		}
		else{
		gettoken left right:right, parse(")")
		local 0 `right'
		}
		

	}
end


*To-Do List:
/*
Add return codes for better error handling.
*/
