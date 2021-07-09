program def convlist, rclass
*! NJC 1.0.0 9 April 2001 
	version 6.0 
	gettoken lists 0 : 0, parse(",")
	if "`lists'" == "" | "`lists'" == "," {  
		di in r "no lists specified" 
		exit 198 
	}
	
	tokenize "`lists'", parse("\") 
	if "`4'" != "" | "`2'" != "\" { 
		di in r "incorrect syntax" 
		exit 198 
	} 	
	numlist "`1'"                         
	local list1 `r(numlist)'
	local n1 : word count `list1' 
	numlist "`3'"  
	local list2 `r(numlist)' 
	local n2 : word count `list2' 
	
	syntax [ , Global(str) Noisily ]
	
	if length("`global'") > 8 { 
		di in r "global name must be <=8 characters" 
		exit 198 
	} 	

	local n3 = `n1' + `n2' - 1 
	local k = 1 
	while `k' <= `n3' { 
		tempname c`k' 
		scalar `c`k'' = 0 
		local k = `k' + 1
	} 	

	tokenize `list1' 

	local i = 1 
	while `i' <= `n1' { 
		local j = 1 
		while `j' <= `n2' {
			local b`j' : word `j' of `list2' 
			local k = `i' + `j' - 1
			scalar `c`k'' = `c`k'' + (``i'' * `b`j'') 
			local j = `j' + 1 
		} 
		local i = `i' + 1
	}
	
	local k = 1 
	while `k' <= `n3' {
		local this = `c`k'' 
		local newlist "`newlist'`this' " 
		local k = `k' + 1
	} 	

	if "`noisily'" != "" { di "`newlist'" } 
	if "`global'" != "" { global `global' "`newlist'" } 
	return local list `newlist' 
end 	
			 
