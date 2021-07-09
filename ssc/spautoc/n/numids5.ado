*! 1.1.0 NJC 15 April 1999 
* 1.0.0 NJC 27 March 1997
program define numids5
* assumes every boundary recorded twice
    version 5.0
    local varlist "min(2) max(2)"
    local options "gen(str)"
    parse "`*'"
    if "`gen'" != "" {
    	local nvars : word count `gen' 
	if `nvars' != 2 { 
		di in r "gen( ) option must specify two variable names"
		exit 198
	}
	local gen1 : word 1 of `gen'
        confirm new variable `gen1'
 	local gen2 : word 2 of `gen'
        confirm new variable `gen2'
    }
    else {
        di _n in r "gen( ) option required"
        exit 198
    }
    parse "`varlist'", parse(" ")

    sort `2'
    gen `gen2' = sum(`2' != `2'[_n-1])
    sort `1'
    gen `gen1' = sum(`1' != `1'[_n-1])
end
