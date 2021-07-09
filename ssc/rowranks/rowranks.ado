program def rowranks
*! NJC 1.0.0 4 Oct 2000 
	version 6 
	syntax varlist(numeric), Generate(str) [ Lowrank Highrank Field] 

	local nopts = ("`lowrank'" != "") + ("`highrank'" != "") 
	
	if `nopts' == 2 { 
		di in r "may not use both lowrank and highrank options"
		exit 198 
	} 	
	else if `nopts' == 0 { /* default */ 
		local averank "averank" 
	} 	
	
	tokenize `varlist' 
	local nvars : word count `varlist'

	local 0 `generate' 
	syntax newvarlist
	local gen `varlist' 
	local ngen : word count `gen' 
	if `nvars' != `ngen' { 
		di in r "`nvars' variables, but `ngen' new names"
		exit 198 
	} 

	if "`field'" == "" { 
	        local op = cond("`lowrank'`averank'" != "", "<", "<=") 
	} 
	else local op = cond("`lowrank'`averank'" != "", ">", ">=") 
	
	tempvar neq nmiss  
	gen byte `neq' = 0
	gen byte `nmiss' = 0 
	local i = 1 
	qui while `i' <= `ngen' { 
		local thisgen : word `i' of `gen' 
		gen byte `thisgen' = 0 
		replace `neq' = 0 
		replace `nmiss' = 0
		
		local j = 1 
		while `j' <= `ngen' { 
			replace `thisgen' = /* 
		*/ cond(missing(``i''), ., `thisgen' + (``j'' `op' ``i'')) 
			replace `neq' = `neq' + (``j'' == ``i'') 
			replace `nmiss' = `nmiss' + missing(``j'') 
			local j = `j' + 1 
		}
		
		if "`lowrank'" != "" { 
			replace `thisgen' = `thisgen' + 1 
		} 	
		else if "`averank'" != "" { 
			replace `thisgen' = `thisgen' + 1 + 0.5 * (`neq' - 1) 
		} 

		* missings are high, so must subtract # of missing values
		* with -field- 
		if "`field'" != "" { 
			replace `thisgen' = `thisgen' - `nmiss' 
		} 	
		
		local i = `i' + 1 
	} 
end 	
	
