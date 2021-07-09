*! NJC 2.0.0 12 January 2004 
* NJC 1.2.0 22 February 2001 
* NJC 1.1.0 11 July 2000 
* NJC 1.0.1 16 December 1998
* NJC 1.0.0 29 October 1996
* differences for circular data
program circdiff
	version 8.0
	gettoken x 0 : 0 
	gettoken y 0 : 0, parse(" ,")  

	capture confirm numeric variable `x' 
	if _rc capture confirm num `x' 
	if _rc { 
		di as err "`x' not a number or a numeric variable" 
		exit 198 
	} 
	
	capture confirm numeric variable `y' 
	if _rc capture confirm num `y' 
	if _rc { 
		di as err "`y' not a number or a numeric variable" 
		exit 198 
	}
	
	syntax [if] [in] , Generate(str) [ ABSolute ] 
	confirm new variable `generate'
	tempvar diff1 diff2

	quietly { 
		gen `diff1' = max(`x',`y') - min(`x',`y') `if' `in'
		gen `diff2' = 360 - `diff1'
		if "`absolute'" == "" { 
			gen `generate' = ///
				sign(`y' - `x') * min(`diff1', `diff2')
		} 
		else gen `generate' = min(`diff1', `diff2') 
		label var `generate' "difference between `x' and `y'" 
	} 	
end
