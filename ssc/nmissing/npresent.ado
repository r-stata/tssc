*! 3.0.0 NJC 25 Sept 2003 
program npresent, byable(recall) 
	version 8.0
	syntax [varlist] [if] [in] [, * ] 
	
	marksample touse, novarlist 
	qui count if `touse' 
	if r(N) == 0 error 2000 

	nmissing `varlist' if `touse', `options' present 
end 	

