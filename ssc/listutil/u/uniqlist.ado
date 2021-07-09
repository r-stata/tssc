program def uniqlist, rclass
*! NJC 1.3.0 7 June 2000 
* NJC 1.2.0 31 Jan 2000 
* NJC 1.1.0 22 Dec 1999 
* NJC 1.0.0 22 Sept 1999 	
	version 6.0 
	gettoken list 0 : 0, parse(",") 
	if "`list'" == "" | "`list'" == "," { 
		di in r "nothing ln list" 
		exit 198 
	}
	syntax [, Noisily Global(str) ]
	
	if length("`global'") > 8 { 
		di in r "global name must be <=8 characters" 
		exit 198 
	} 	
	
	tokenize `list' 
	local newlist "`1'" 
	mac shift 
	 
	while "`1'" != "" { 
		local nnew : word count `newlist' 
		local i = 1 
		local putin = 1 
		while `i' <= `nnew' { 
			local word : word `i' of `newlist' 
			if "`word'" == "`1'" { 
				local putin = 0 
				local i = `nnew' 
			} 
			local i = `i' + 1 
		} 	
		if `putin' { local newlist "`newlist' `1'" } 
		mac shift
	}
	
	if "`noisily'" != "" { di "`newlist'" } 
	if "`global'" != "" { global `global' "`newlist'" } 
	return local list `newlist'
end 	
			
