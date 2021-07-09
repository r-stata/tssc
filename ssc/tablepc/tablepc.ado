program def tablepc 
*! NJC 1.1.0 21 February 2001 
* NJC 1.0.0 20 February 2001 
	version 6 
	syntax varlist [if] [in] [fweight aweight iweight pweight/] /* 
	*/ , Generate(str) [ by(varlist) ] 
	marksample touse 
	confirm new variable `generate' 
	local g "`generate'" 
        sort `touse' `by'
	if "`exp'" == "" { local exp 1 } 
	qui { 
	        by `touse' `by': gen `g' = sum(`exp') if `touse'
                by `touse' `by': replace `g' = 100  * `exp' / `g'[_N]
	} 
end 	
	
