*! 1.0.1 NJC 15 April 1999 
* 1.0.0 NJC 27 March 1997
program define dupneigh5
* every boundary recorded once => add mirror image
    version 5.0
    local varlist "min(2) max(2)"
    parse "`*'"
    parse "`varlist'", parse(" ")

    local n = _N
    local np1 = _N + 1
    qui expand 2
    qui replace `1' = `2'[_n - `n'] in `np1' / l
    qui replace `2' = `1'[_n - `n'] in `np1' / l
end
