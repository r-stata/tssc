program def sublist, rclass
*! NJC 1.3.0 7 June 2000 
* NJC 1.2.0 31 Jan 2000 
* NJC 1.1.0 22 Dec 1999 
* NJC 1.0.0 12 November 1999 	
	version 6.0 
	gettoken list 0 : 0, parse(",")
	if "`list'" == "" | "`list'" == "," { 
		di in r "nothing in list" 
		exit 198 
	}
	syntax , From(str) [ To(str) ALL Noisily Global(str)]
	
	if length("`global'") > 8 { 
		di in r "global name must be <=8 characters" 
		exit 198 
	} 	

	tokenize `list'
	
	local nwords : word count `list' 
	local i = 1 
	while `i' <= `nwords' { 	
		local len = length("``i''") 
		if `len' > 80 { 
			di in r "cannot handle word length > 80"
			exit 498 
		}
		local i = `i' + 1 
	}	

	while "`1'" != "" { 
		if index("`1'", "`from'") { 
			local 1 : subinstr local 1 "`from'" "`to'", `all'
		}	
		local newlist "`newlist'`1' "
		mac shift
	}
	
	if "`noisily'" != "" { di "`newlist'" } 
	if "`global'" != "" { global `global' "`newlist'" } 
	return local list `newlist'
end 	
			
