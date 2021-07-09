program def charcopy
*! NJC 1.1.0 24 September 2000 
* NJC prompted by KTH 1.0.0 31 March 2000 
	version 6.0 
	syntax varlist(min=2 max=2) 
	tokenize `varlist' 
	args from to 

	local chfrom : char `from'[] 
	if "`chfrom'" == "" { 
		di in r "`from'" has no characteristics" 
		exit 498 
	}
	
	tokenize `chfrom' 
	while "`1'" != "" { 
		local fchar : char `from'[`1'] 
		char `to'[`1'] `"`fchar'"'   
		mac shift 
	} 	
end 		
	
`fchar'"'   
		mac shift 
	} 	
end 		
	
