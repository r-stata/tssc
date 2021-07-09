program def fmtlist, rclass
*! NJC 1.0.0 22 August 2000 
	version 6.0 
	gettoken list 0 : 0, parse(",")
	if "`list'" == "" | "`list'" == "," { 
		di in r "nothing in list"
		exit 198 
	}
	syntax , Format(str) [ Global(str) Noisily ]
	
	if length("`global'") > 8 { 
		di in r "global name must be <=8 characters" 
		exit 198 
	} 

	tokenize `list' 
	while "`1'" != "" { 
		capture local 1 : di `format' `1' 
		if _rc { 
			di in r "inappropriate argument or format?" 
			exit _rc 
		} 
		local newlist "`newlist'`1' " 
		mac shift
	}
	
	if "`noisily'" != "" { di "`newlist'" } 
	if "`global'" != "" { global `global' "`newlist'" } 
	return local list `newlist'
end 	
			
