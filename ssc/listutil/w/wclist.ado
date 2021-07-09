program def wclist, rclass
*! NJC 1.1.0 6 June 2000 
* NJC 1.0.0 13 March 2000 
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

	local nw : word count `list' 
	if "`noisily'" != "" { di `nw' } 
	if "`global'" != "" { global `global' `nw' } 
	return local nw `nw'
end 	
			
