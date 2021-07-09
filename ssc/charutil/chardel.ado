program def chardel 
*! NJC 1.0.1 1 April 2000 
	version 6.0 
	syntax varname 

	local chvar : char `varlist'[] 
	if "`chvar'" == "" { 
		di in r "`varlist' has no characteristics" 
		exit 498 
	} 

	tokenize `chvar' 
	while "`1'" != "" { 
		char `varlist'[`1']         /* blank it out */ 
		mac shift 
	} 	
end 		
	
