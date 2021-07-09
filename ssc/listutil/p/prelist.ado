program def prelist, rclass
*! NJC 1.2.0 6 June 2000 
* NJC 1.1.0 22 Dec 1999 
* NJC 1.0.0 12 Nov 1999 	
	version 6.0 
	gettoken list 0 : 0, parse(",")
	if "`list'" == "" | "`list'" == "," { 
		di in r "nothing in list"
		exit 198 
	}
	syntax , Pre(str) [ Global(str) Noisily ]
	
	if length("`global'") > 8 { 
		di in r "global name must be <=8 characters" 
		exit 198 
	} 	

	tokenize `list' 
	while "`1'" != "" { 
		local newlist "`newlist'`pre'`1' "
		mac shift
	}
	
	if "`noisily'" != "" { di "`newlist'" } 
	if "`global'" != "" { global `global' "`newlist'" } 
	return local list `newlist'
end 	
			
