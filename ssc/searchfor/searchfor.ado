prog searchfor
version 9
syntax anything, [in(varname) edit(varlist) list(varlist)]
*set trace on
local UPPER = upper("`anything'")
local LOWER = lower("`anything'")
local PROPER = proper("`anything'")


if "`in'"=="" & "`edit'"!=""{
dis as error "option edit must specified with option in"
exit
}

qui ds, has(type string)
	local strvars "`r(varlist)'"

	
	
* FIND IN ALL STRING VARIABLES
*_____________________________	
	
if "`in'"==""{
	foreach v of varlist `strvars' {
		list `v' if strmatch(`v', "*`anything'*") | strmatch(`v', "*`UPPER'*") | strmatch(`v', "*`LOWER'*") | strmatch(`v', "*`PROPER'*")
	}
	
	if "`list'"!=""{
		foreach v of varlist `strvars' {
			list `list' if strmatch(`v', "*`anything'*") | strmatch(`v', "*`UPPER'*") | strmatch(`v', "*`LOWER'*") | strmatch(`v', "*`PROPER'*")
		}

	}
	
}

*	
	
* FIND IN SELECTED VARIABLES
*_____________________________	
	
	

if "`in'"!= ""{

	if "`edit'" == ""{
		
			list `list' if strmatch(`in', "*`anything'*")| strmatch(`in', "*`UPPER'*") | strmatch(`in', "*`LOWER'*") | strmatch(`in', "*`PROPER'*")
		}
		
	else{
		  edit `edit' if strmatch(`in', "*`anything'*")| strmatch(`in', "*`UPPER'*") | strmatch(`in', "*`LOWER'*") | strmatch(`in', "*`PROPER'*")

	}	
	}
	

	*
	
	
end
