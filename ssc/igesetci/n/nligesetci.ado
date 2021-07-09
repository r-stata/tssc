*! nligesetci v 1.0
*! Pablo Mitnik
*!
*! Auxiliary nl program
*!
*! Last updated Feb. 2019

program nligesetci

	version 9
	syntax varlist(min=1 max=1) if, at(name)
	
	local Y `varlist'
	
	// Retrieve c
	tempname c 
	scalar `c' = `at'[1, 1]

	// Fill in artificial dependent variable
	qui replace `Y' = 0
	qui replace `Y' = normal(`c' + $RW) - normal(-`c')  in 1 

end
