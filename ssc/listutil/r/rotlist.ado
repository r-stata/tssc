program def rotlist, rclass
*! NJC 1.1.0 6 June 2000 
* NJC 1.0.0 26 Apr 2000 
	version 6.0 
	gettoken list 0 : 0, parse(",")
	if "`list'" == "" | "`list'" == "," { 
		di in r "nothing in list" 
		exit 198 
	}
	
	syntax , Rot(int) [ Global(str) Noisily ]
	
	if length("`global'") > 8 { 
		di in r "global name must be <=8 characters" 
		exit 198 
	} 	
	
	local n : word count `list'
	local rot = mod(`rot', `n')
	
	if `rot' == 0 { 
		local newlist "`list'" 
	} 
	else { 
		tokenize `list' 
		
		local i = `rot' + 1 
		while `i' <= `n' { 
			local newlist "`newlist'``i'' "
			local i = `i' + 1 
		} 
		
		local i = 1 
		while `i' <= `rot' { 
			local newlist "`newlist'``i'' " 
			local i = `i' + 1 
		} 
	} 	
	
	if "`noisily'" != "" { di "`newlist'" } 
	if "`global'" != "" { global `global' "`newlist'" } 
	return local list `newlist'
end 	
			
