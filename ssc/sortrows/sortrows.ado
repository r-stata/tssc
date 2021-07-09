*! sortrows
*! version 2.0
*! 29Oct2006
*! Jeff Arnold, Jeff DOT Arnold AT ny DOT frb DOT org
* 12Jul2006 replaced the sort routine with Mata code
* 29Oct2006 different sort routines based on v9 or v8.
* 07Nov2006 Only allow v9

/**
Package  : Sortrows
Title    : Sort Within Observation
Requires : Stata version 8

Sortrows sorts a variable list within each observation (row). 
*/

program define sortrows 
    version 9
    syntax varlist(min=2) ,         ///
    [                               ///
        REPLACE                     ///
        GENerate(string)            ///
        DESCending                  /// 
        MIssings                    ///
    ]

    if "`replace'`generate'" == "" {
        di as err "You must specify either generate or replace"
        exit 198
    }
    if "`replace'" != "" & "`generate'" != "" {
        di as err "Only one of generate or replace is allowed"
        exit 198
    }

    // array and dimension of array
    local n : word count `varlist'
    if "`generate'" != "" { 
        local new : word count `generate'
        if `new' != `n' {
            di as err "Number of generated variables must equal varlist"
            exit 198
        }
    }
    else local newvar "`varlist'"

    // test that all variables are of the same type
    local alpha : word 1 of `varlist'
    cap confirm numeric variable `alpha'
    if _rc {
        confirm string variable `varlist'
        local isnumeric = 0
    }
    else {
        confirm numeric variable `varlist'
        local isnumeric = 1
    }
    
    // descending sort
    local desc = ("`descending'" != "")

    // deal with missings 
    local miss = ("`missings'" != "")

    preserve
    marksample touse, strok novarlist

    if ("`replace'" != "") {
        local sortvars "`varlist'"
    }
    else {
        local sortvars ""
        forvalues i = 1(1)`n' {
            local oldvar : word `i' of `varlist' 
            local tmpvar : tempvar 
            clonevar  `tmpvar' = `oldvar'
            local sortvars "`sortvars' `tmpvar'"
        }
    }
    
    // expand data-types to maximal type in varlist
    if ("`generate'" != "") local capture "`capture'"
    `capture' decompress `sortvars'

    // sort with mata 
    mata _sortrower("`sortvars'", "`touse'",`desc',`miss')

    // rename generated variables to permanent ones 
    if "`generate'" != "" {
        forvalues i = 1/`n' {
            local newvar : word `i' of `generate'
            local tmpvar : word `i' of `sortvars'
            ren `tmpvar' `newvar'
        }
    }
    restore, not

end

* Used by sortrows to sort variable lists within a row 
version 9
mata 
void _sortrower(string scalar varlist, string scalar touse,
    real scalar descend, real scalar missing) 
{
    colvector x
    real scalar isnumeric, j

    isnumeric = st_isnumvar(tokens(varlist)[1])

    if (isnumeric) {
        st_view(X,.,tokens(varlist), touse)
    }
    else {
        st_sview(X,.,tokens(varlist), touse)
    }
    for (i = 1; i <= rows(X); i++) {
        x = sort((X[i,.])',1)
        // reverse order for descending
        if (descend) {
            x = x[revorder(1::rows(x)),.]
        }
        // find out how many missings there are
        if (missing) {
            j = 0
            if (isnumeric) {
                if (missing(x[1]) & (missing(x) != length(x))) {
                    j = missing(x)
                }
            }
            else {
                if (x[1] == "" & !allof(x,"")) {
                    j = sum( x :== "" )
                }
            }
            // move missings to the back
            if (j) x = x[((j+1)::rows(x) \ 1::j)] 
        }
        X[i,.] = x'
    }
}
end

exit
