*! 2.0.0 NJC 21 Feb 2005 
* 1.0.1 NJC 15 April 1999 
* 1.0.0 NJC 27 March 1997
// every boundary recorded once => add mirror image
program dupneigh
	version 8   
	syntax varlist(min=2 max=2) [if] [in] 
	marksample touse, strok 
	tokenize "`varlist'"
	local n = _N
	local np1 = _N + 1
	qui { 
		keep if `touse' 
		expand 2
		replace `1' = `2'[_n - `n'] in `np1' / l
		replace `2' = `1'[_n - `n'] in `np1' / l
	} 	
end
