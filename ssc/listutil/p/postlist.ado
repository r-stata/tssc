program def postlist, rclass
*! NJC 1.3.0 6 June 2000 
* NJC 1.2.0 22 Dec 1999 
* NJC 1.0.0 12 Nov 1999 	
	version 6.0 
	gettoken list 0 : 0, parse(",")
	if "`list'" == "" | "`list'" == "," { 
		di in r "nothing in list" 
		exit 198 
	}
	syntax , Post(str) [ Global(str) Sep Noisily ]  
	
	if length("`global'") > 8 { 
		di in r "global name must be <=8 characters" 
		exit 198 
	} 	

	tokenize `list' 
	local n : word count `list' 
	if "`sep'" != "" { 
		local last = `n' 
		local n = `n' - 1 
	}

	local i = 1 
	while `i' <= `n' { 
		local newlist "`newlist'``i''`post' "
		local i = `i' + 1 
	}

	if "`sep'" != "" { local newlist "`newlist'``last''" } 
	
	if "`noisily'" != "" { di "`newlist'" } 
	if "`global'" != "" { global `global' "`newlist'" } 
	return local list `newlist'
end 	
			
