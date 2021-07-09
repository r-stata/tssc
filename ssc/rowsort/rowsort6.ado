*! renaming only 22 November 2005 
*! NJC 1.1.0 21 November 2000 
program def rowsort6
	version 6 
	syntax varlist(numeric), Generate(str) [ Ascend Descend ] 

	if "`ascend'" != "" & "`descend'" != "" { 
		di in r "must choose either ascend or descend" 
		exit 198 
	} 	

	tokenize `varlist' 
	local nvars : word count `varlist'

	local i = 1 
	while `i' <= `nvars' { 
		capture assert ``i'' == int(``i'') 
		if _rc { 
			di in r "``i'' bad: integer variables required"
			exit 198 
		} 	
		local i = `i' + 1
	} 	

	local 0 `generate' 
	syntax newvarlist
	local gen `varlist' 
	local ngen : word count `gen'
	local s = cond(`ngen' == 1, "", "s") 
	if `nvars' != `ngen' { 
		di in r "`nvars' variables, but `ngen' new name`s'"
		exit 198 
	} 

	local i = 1 
	qui while `i' <= `nvars' {
		local gen`i' : word `i' of `gen' 
		gen `gen`i'' = . 
		local i = `i' + 1 
	} 	

	local j = 1 
	qui while `j' <= _N  {
		local inobs 
		local i = 1 
		while `i' <= `nvars' { 
			local inval = ``i''[`j'] 
			local inobs "`inobs' `inval'" 
			local i = `i' + 1 
		} 
		numlist "`inobs'" , missingok sort
		if "`descend'" == "" { 
			local i = 1 
			while `i' <= `nvars' { 
				local outval : word `i' of `r(numlist)'  
				replace `gen`i'' = `outval' in `j'
				local i = `i' + 1 
			} 
		} 
		else { 
			local i = 1 
			local I = `nvars' 
			while `i' <= `nvars' { 
				local outval : word `i' of `r(numlist)' 
				replace `gen`I'' = `outval' in `j' 
				local I = `I' - 1 
				local i = `i' + 1 
			} 	
		}	
		local j = `j' + 1 
	} 	
end 	
	
