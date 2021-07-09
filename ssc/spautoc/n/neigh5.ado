*! 1.1.0 NJC 15 April 1999
* 1.0.0 NJC 2 April 1997
program define neigh5
    version 5.0
    local varlist "min(2) max(3)"
    local options "GEN(str) WGEN(str)"
    parse "`*'"
    if "`gen'" != "" {
        confirm new variable `gen'
    }
    else {
        di _n in r "gen( ) required"
        exit 198
    }
    parse "`varlist'", parse(" ")
    if "`wgen'" != "" { 
    	confirm new variable `wgen' 
	if "`3'" == "" { 
	    di in r "no weight variable specified"
	    exit 198
	}    
	local weight 1    
    }	    
    else local weight 0 
    
    capture confirm str variable `1'
    if _rc == 0 {
        di in r "`1' should be numeric"
        exit 108
    }
    capture confirm str variable `2'
    if _rc == 0 {
        di in r "`2' should be numeric"
        exit 108
    }

    qui {
        gen str1 `gen' = ""
	if `weight' { gen str1 `wgen' = "" } 
        sort `1' `2'
        by `1' : replace `gen' = `gen'[_n-1] + string(`2') + " "
	if `weight' {
	    by `1' : replace `wgen' = `wgen'[_n-1] + string(`3') + " "
	}    
        by `1' : keep if _n == _N
        drop `2' `3' 
    }
end
