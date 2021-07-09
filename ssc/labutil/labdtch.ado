program def labdtch
*! NJC 1.0.0 15 June 2000 
	version 6.0 
	syntax varlist 
	tokenize `varlist' 

	while "`1'" != "" { 
		capture confirm numeric variable `1' 
		if _rc == 0 { label val `1' } 
		mac shift 
	}
end 	
