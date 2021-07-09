program def cseplist, rclass
*! NJC 1.0.0 31 August 2000 
	version 6.0 
	gettoken list 0 : 0, parse(",")
	if "`list'" == "" | "`list'" == "," { 
		di in r "nothing in list" 
		exit 198 
	}
	syntax , [ Global(str) Noisily ]  
	
	if length("`global'") > 8 { 
		di in r "global name must be <=8 characters" 
		exit 198 
	} 	

	tokenize `list' 
	local n : word count `list' 
	local i = 1 
	while `i' < `n' { 
		local newlist "`newlist'``i'',"
		local i = `i' + 1 
	}
	local newlist "`newlist'``n''" 

	if "`noisily'" != "" { di "`newlist'" } 
	if "`global'" != "" { global `global' "`newlist'" } 
	return local list `newlist'
end 	
			
