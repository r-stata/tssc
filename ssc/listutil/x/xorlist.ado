program def xorlist, rclass
*! NJC 1.0.0 9 June 2000 
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

	bothlist `list1' \ `list2' 
	local inter "`r(list)'" 
	uniqlist `list1' `list2' 
	local union "`r(list)'" 
	difflist `union' \ `inter'
	local newlist "`r(list)'" 
	
	if "`noisily'" != "" { di "`newlist'" } 
	if "`global'" != "" { global `global' "`newlist'" } 
	return local list `newlist' 
end 	
			 
