program def maplist, rclass
*! NJC 1.0.0 22 August 2000 
	version 6.0 
	gettoken list 0 : 0, parse(",")
	if "`list'" == "" | "`list'" == "," { 
		di in r "nothing in list"
		exit 198 
	}
	syntax , Map(str asis) [ Global(str) Noisily Symbol(str) ]

	if "`symbol'" == "" { local symbol "@" } 

	if !index(`"`map'"',"`symbol'") { 
		di in r "map( ) does not contain `symbol'" 
		exit 198 
	} 	
	
	if length("`global'") > 8 { 
		di in r "global name must be <=8 characters" 
		exit 198 
	} 	

	tokenize `list' 
	while "`1'" != "" { 
		local result : subinstr local map "`symbol'" "`1'", all 
		capture local 1 = `result' 
		if _rc { 
			di in r "inappropriate map?" 
			exit _rc 
		} 	
		local newlist "`newlist'`1' "
		mac shift
	}
	
	if "`noisily'" != "" { di "`newlist'" } 
	if "`global'" != "" { global `global' "`newlist'" } 
	return local list `newlist'
end 	
			
