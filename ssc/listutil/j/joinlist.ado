program def joinlist, rclass
*! NJC 1.2.0 14 December 2000 
* -separate- option renamed -sep- for consistency 
* NJC 1.1.0 6 June 2000 
* NJC 1.0.0 28 Jan 2000 	
	version 6.0 
	gettoken lists 0 : 0, parse(",")
	if "`lists'" == "" | "`lists'" == "," {  
		di in r "empty lists" 
		exit 198 
	}
	
	tokenize "`lists'", parse("\")
	args list1 bs list2 stuff 
	if "`stuff'" != ""  { 
		di in r "incorrect syntax: too much stuff" 
		exit 198 
	} 	
	if "`list1'" == "\" {  
		di in r "empty list 1" 
		exit 198 
	}
	if "`list2'" == "" | "`list2'" == "\" { 
		di in r "empty list 2"
		exit 198 
	} 	
	
	syntax [ , Global(str) Noisily Sep ]  
	
	if length("`global'") > 8 { 
		di in r "global name must be <=8 characters" 
		exit 198 
	} 	

	local n1 : word count `list1' 
	local n2 : word count `list2' 
	if `n1' != `n2' {
		if `n1' == 1 { 
			local list1 : di _dup(`n2') "`list1' "
			local n1 = `n2' 
		} 
		else if `n2' == 1 { 
			local list2 : di _dup(`n1') "`list2' "
		} 	
		else { 
			di in r "lists of unequal length"
			exit 198 
		} 	
	} 	

	if "`sep'" != "" { local sep " " }  

	local i = 1 
	while `i' <= `n1' {
		local w1 : word `i' of `list1' 
		local w2 : word `i' of `list2' 
		local newlist "`newlist'`w1'`sep'`w2' "
		local i = `i' + 1
	}
	
	if "`noisily'" != "" { di "`newlist'" } 
	if "`global'" != "" { global `global' "`newlist'" } 
	return local list `newlist' 
end 	
			 
