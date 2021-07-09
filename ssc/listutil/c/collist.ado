program def collist
*! NJC 1.0.0 22 Dec 1999 
	version 6
	gettoken list 0 : 0, parse(",") 
	if "`list'" == "" | "`list'" == "," { 
		di in r "nothing in list"
		exit 198 
	}	
	syntax [ , Format(str) NUmber ] 

	tokenize `list'
	
        if "`number'" != "" { 	
		local n : word count `list' 
		local ndigits = length("`n'") 
		local number = 0 
	}

	* asstr  >0    string format 
	* asstr   0    numeric format 
	* asstr  -1    default 
	local asstr = cond("`format'" != "",index("`format'", "s"), -1) 
	
	while "`1'" != "" { 
		if "`number'" != "" { 
			local number = `number' + 1 
			local num : di %`ndigits'.0f `number' ". " 
		} 	
		if `asstr' { di in g "`num'" `format' in y `"`1'"' } 
		else di in g "`num'" `format' in y `1' 
		mac shift 
	}
end 
