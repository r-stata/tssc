program def strgen 
*! NJC 1.0.0 4 January 2001 
	version 6.0
 	gettoken 0 defn : 0, parse("=")       
	* `defn' will include any [if] or [in] 
	syntax newvarlist(max=1) 
	qui nobreak { 
		gen str1 `varlist' = "" 
		capture replace `varlist' `defn' 
		if _rc { 
			drop `varlist' 
			error _rc 
		}
	}	
end 
