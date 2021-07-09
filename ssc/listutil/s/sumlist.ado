program def sumlist, rclass
*! NJC 1.0.0 9 April 2001 
	version 6.0 
	gettoken list 0 : 0, parse(",")
	if "`list'" == "" | "`list'" == "," {  
		di in r "no list specified" 
		exit 198 
	}
	
	numlist "`list'"                         
	local list `r(numlist)'
	local nw : word count `list' 
	
	syntax [ , Global(str) Noisily ]
	
	if length("`global'") > 8 { 
		di in r "global name must be <=8 characters" 
		exit 198 
	} 	

	tempname sum 
	scalar `sum' = 0 
	tokenize `list' 

	local i = 1 
	while `i' <= `nw' { 
		scalar `sum' = (`sum') + (``i'') 
		local i = `i' + 1
	}

	if "`noisily'" != "" { di `sum' } 
	if "`global'" != "" { global `global' = `sum' } 
    	return scalar sum = `sum' 
end 

			 
