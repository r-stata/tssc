program def difflist, rclass
*! NJC 1.4.0 6 June 2000 
* NJC 1.3.0 31 Jan 2000 
* NJC 1.2.0 22 Dec 1999
* NJC 1.1.0 21 Dec 1999 
* NJC 1.0.0 14 Oct 1999 	
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

	* remove duplicates from `list1' 

	tokenize `list1' 
	local list1 "`1'" 
	mac shift 
	 
	while "`1'" != "" { 
		local n1 : word count `list1' 
		local i = 1 
		local putin = 1 
		while `i' <= `n1' { 
			local word : word `i' of `list1' 
			if "`word'" == "`1'" { 
				local putin = 0 
				local i = `n1' 
			} 
			local i = `i' + 1 
		} 	
		if `putin' { local list1 "`list1' `1'" } 
		mac shift
	}
	
	* what is in `list1' but not `list2'? 

	local n1 : word count `list1' 
	tokenize `list1'
	local n2 : word count `list2' 

	local i = 1 
	while `i' <= `n1' { 
		local j = 1 
		local putin = 1 
		while `j' <= `n2' { 
			local word : word `j' of `list2' 
			if "`word'" == "``i''" { 
				local putin = 0 
				local j = `n2' 
			} 
			local j = `j' + 1 
		} 
		if `putin' { local newlist "`newlist' ``i''" } 
		local i = `i' + 1
	}

	if "`noisily'" != "" { di "`newlist'" } 
	if "`global'" != "" { global `global' "`newlist'" } 
	return local list `newlist' 
end 	
			 
