program def uclist, rclass
*! NJC 1.0.0 29 June 2000 
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

	while "`1'" != "" {
		if length("`1'") > 80 { 
			di in r "cannot handle word length > 80"
			exit 498 
		}	
		local 1 = upper("`1'") 
		local newlist "`newlist'`1' "
		mac shift  
	}
	
	if "`noisily'" != "" { di "`newlist'" } 
	if "`global'" != "" { global `global' "`newlist'" } 
	return local list `newlist'
end 	
			
