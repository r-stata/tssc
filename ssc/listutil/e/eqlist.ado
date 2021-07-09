program def eqlist, rclass
*! NJC 1.1.0 23 January 2001 
* NJC 1.0.0 5 January 2001 
	version 6.0 
	gettoken lists 0 : 0, parse(",")
	if "`lists'" == "" | "`lists'" == "," { /* no \ */ 
		di in r "incorrect syntax: no separator" 
		exit 198 
	}
	
	tokenize "`lists'", parse("\") 
	if "`4'" != "" { 
		di in r "incorrect syntax: too much stuff" 
		exit 198 
	} 	
	if "`1'" == "\" { /* list1 empty */ 
		if "`2'" == "\" { 
			di in r "incorrect syntax: one \ only" 
			exit 198
		}	
		local list2 "`2'" /* might be empty */ 
	} 
	else if "`2'" == "\" { 
		local list1 "`1'" 
		local list2 "`3'" /* might be empty */ 
	} 	
	else { 
		di in r "incorrect syntax: what to compare?" 
		exit 198 
	}
	
	syntax [ , Global(str) Noisily ]
	
	if length("`global'") > 8 { 
		di in r "global name must be <=8 characters" 
		exit 198 
	} 	

	local n1 : word count `list1' 
	tokenize `list1'
	local n2 : word count `list2'

	if `n1' != `n2' {
		local iseq = 0 
	} 	
	else { 
		local iseq = 1 
		local i = 1 
		while `i' <= `n1' & `iseq' { 
			local word : word `i' of `list2'
			if length("``i''") > 80 | length("`word'") > 80 { 
				di in r "cannot handle word length > 80"
				exit 498 
			}	
			if "`word'" != "``i''" { local iseq 0 } 
			local i = `i' + 1
		}
	} 	

	if "`noisily'" != "" { di `iseq' } 
	if "`global'" != "" { global `global' = `iseq' } 
	return local iseq = `iseq' 
end 	
			 
