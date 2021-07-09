*! NJC 1.1.0 9 March 2004
*! NJC 1.0.0 8 March 2004
program hlist
	version 8 
	syntax varlist(numeric) [if] [in] [, * ]
	
	preserve 
	qui gen _varname = "" 
	
	qui if "`if'`in'" != "" { 
		tempvar id 
		gen long `id' = _n 
		levels `id' `if' `in' 
		local obs "`r(levels)'" 
		keep `if' `in' 
	} 	
	else { 
		numlist "1/`=_N'"
		local obs "`r(numlist)'" 
	} 	

	keep `varlist' 
	xpose, clear varname format promote 
	
	tokenize `obs' 
	local i = 0 
	foreach v of var v* { 
		char `v'[varname] "``++i''"
	}	
	char _varname[varname] "obs:" 

	list _varname v* , noobs subvarname `options' 
end 	
