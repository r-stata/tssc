program define labnoeq 
*! NJC 1.0.1 10 July 2001 
	version 7 
	syntax varlist

	foreach var of local varlist { 
		local label : variable label `var'
		local pos = index(`"`label'"',"==") 
		if `pos' { 
			local label = substr(`"`label'"',`pos' + 2,.)
			label variable `var' `"`label'"' 
		} 	
	}
end 	
