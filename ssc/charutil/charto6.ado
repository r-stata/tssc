program def charto6 
*! NJC 1.0.0 28 August 2001 
	version 7.0 

	unab varlist : * 
	local evarlist "_dta `varlist'" 

	foreach evar of local evarlist {
		local charlist : char `evar'[] 
		foreach char of local charlist { 
			if length("`char'") > 8 { /* blank it out */  
				char `evar'[`char']   
				di as txt "dropping `evar'[`char']"  
			} 	
		} 	
	} 	
end 		
	
