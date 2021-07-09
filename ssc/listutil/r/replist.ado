program def replist, rclass
*! NJC 1.0.0 19 June 2000 
	version 6.0 
	gettoken list 0 : 0, parse(",")
	if "`list'" == "" | "`list'" == "," { 
		di in r "nothing in list" 
		exit 198 
	}
	
	* note that 0 copies => empty list 
	syntax , Copies(numlist int >=0) [ Block Global(str) Noisily ]
	
	if length("`global'") > 8 { 
		di in r "global name must be <=8 characters" 
		exit 198 
	} 	
	
	if `copies' == 1 { 
		local newlist "`list'" 
	} 
	else if `copies' > 1 { 
		if "`block'" != "" { 
			local c = 1 
			while `c' <= `copies' { 
				local newlist "`newlist'`list' "
				local c = `c' + 1 
			} 
		} 
		else { 
			tokenize `list' 
			local n : word count `list'
			local i = 1 
			while `i' <= `n' { 
				local c = 1 
				while `c' <= `copies' { 
					local newlist "`newlist'``i'' " 
					local c = `c' + 1 
				} 
				local i = `i' + 1 
			} 	
		}	
	} 	
	
	if "`noisily'" != "" { di "`newlist'" } 
	if "`global'" != "" { global `global' "`newlist'" } 
	return local list `newlist'
end 	
			
