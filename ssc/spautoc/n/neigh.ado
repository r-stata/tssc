*! 2.0.0 NJC 21 February 2005 
* 1.1.0 NJC 15 April 1999
* 1.0.0 NJC 2 April 1997
program neigh, sort 
	version 8   
	capture syntax varlist(min=2 numeric), Generate(str) 
	if _rc { 
		syntax varlist(min=3 max=3), Generate(str) [ WGenerate(str) ] 
		tokenize "`varlist'" 
		args i j w 
		confirm numeric var `i' `j'
		confirm str var `w' 
	}	
	else { 
		tokenize "`varlist'" 
		args i j 
	}	
	
	confirm new variable `generate'
	local gen "`generate'" 
	
	if "`wgenerate'" != "" { 
		confirm new variable `wgenerate' 
		local weight 1    
		local wg "`wgenerate'" 
	}	    
	else local weight 0 

	qui {
		gen `gen' = ""
		if `weight' { 
			gen `wg' = "" 
		} 
		bysort `i' (`j'): replace `gen' = `gen'[_n-1] + string(`j') + " "
		if `weight' {
	        	by `i' : replace `wg' = `wg'[_n-1] + string(`w') + " "
		}    
		by `i' : keep if _n == _N
		drop `j' `w' 
	}
end
