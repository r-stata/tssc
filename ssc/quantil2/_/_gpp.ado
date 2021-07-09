*! 1.0.1 NJC 29 January 1999
* 1.0.0 13 March 1998
* computes (i - a)/(n - 2a + 1)
program define _gpp
        version 5.0
        local varlist "req new max(1)"
        local exp "req nopre"
        local if "opt"
        local in "opt"
        local options "a(real 0.5) BY(string)"
        parse "`*'"
        tempvar value i touse
        if "`by'" != "" { confirm variable `by' }
        quietly {
                mark `touse' `if' `in'
                markout `touse' `exp'
                gen `value' = `exp' if `touse'
                sort `touse' `by' `value'
                by `touse' `by' : gen long `i' = _n if `value' != .
                by `touse' `by' : replace `varlist' = /*
                 */ (`i' - `a') / (`i'[_N] - 2 * `a' + 1)
                label var `varlist' "Fraction of the data"
        }
end
