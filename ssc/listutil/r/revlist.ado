program def revlist, rclass
*! NJC 1.2.0 7 June 2000 
* NJC 1.1.0 22 Dec 1999 
* NJC 1.0.0 24 Oct 1999 	
	version 6.0 
	gettoken list 0 : 0, parse(",") 
	if "`list'" == "" | "`list'" == "," { 
		di in r "nothing in list"
		exit 198 
	}
	syntax [, Noisily Global(str) ]
	
	if length("`global'") > 8 { 
		di in r "global name must be <=8 characters" 
		exit 198 
	} 	

	tokenize `list'
	local nwords : word count `list' 
	
	local i = `nwords'
	while `i' >= 1 { 
		local newlist "`newlist'``i'' " 
		local i = `i' - 1 
	}
	
	if "`noisily'" != "" { di "`newlist'" } 
	if "`global'" != "" { global `global' "`newlist'" } 
	return local list `newlist'
end 	
			
