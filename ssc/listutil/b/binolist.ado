program def binolist, rclass
*! NJC 1.1.0 6 June 2000 
* NJC 1.0.0 25 Jan 2000 
	version 6.0 
	syntax , K(numlist int max=1 >0) [ Global(str) Noisily ]
	
	if length("`global'") > 8 { 
		di in r "global name must be <=8 characters" 
		exit 198 
	} 	

	local i = 1 
	while `i' <= `k' { 
		local val = comb(`k'-1, `i'-1)  
	        local newlist "`newlist' `val'" 
		local i = `i' + 1 
	}
	
	if "`noisily'" != "" { di "`newlist'" } 
	if "`global'" != "" { global `global' "`newlist'" } 
	return local list `newlist' 
end 	
