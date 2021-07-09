program tabsplit 
*! NJC 2.0.0 18 May 2004 
* NJC 1.4.0 16 February 2001 
* NJC 1.3.0 17 July 2000 
* NJC 1.2.2 23 March 1999
* NJC 1.1.0 11 August 1998
* NJC 1.0.0 29 July 1998
	version 8   
	syntax varname(string) [if] [in] [ , noTrim Parse(passthru) CHARacters * ]

	marksample touse, strok 

	qui {
		count if `touse' 
		if r(N) == 0 error 2000 
		
		tempvar data newdata 
		tempname stub 
		if "`trim'" != "" gen `data' = `varlist' if `touse' 
		else gen `data' = trim(`varlist') if `touse'
		
		if "`characters'" != "" {
			compress `data'
			local vartype: type `data'
			local len = substr("`vartype'",4,.)
			forval i = 1/`len' {
				gen `stub'`i' = substr(`data',`i',1)
			}
		}
		else split `data', `parse' gen(`stub') `trim'  

		preserve 
		
		local label : variable label `varlist' 
		if `"`label'"' == "" local label "`varlist'" 
		
		stack `stub'* if `touse', into(`newdata') clear
		if "`trim'" == "" replace `newdata' = trim(`newdata') 
		
		label var `newdata' `"`label'"' 
	} 				
	    
	tab `newdata', `options' 
end
