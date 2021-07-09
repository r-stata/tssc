program define psbayes6
*! renamed NJC 15 August 2004 
*! 1.1.0 NJC 24 March 1999
* 1.0.0 NJC 17 July 1998
    version 6.0
    syntax varlist(min=1 max=2) [if] [in] /* 
    */ [, Prob Generate(str) BY(varlist min=1 max=3) CENter Format(str) * ]
    tokenize `varlist'
    args data prior 

    tempvar sq diffsq pb
    marksample touse

    qui {
        if "`by'" != "" {
            tokenize `by'
            args row col layer
            local by "`row' `col'"
        }
        else {
            tempvar by
            gen `by' = _n if `touse'
            label var `by' "Obs"
        }

        su `data' if `touse', meanonly
        local N = r(sum)

        if "`prior'" == "" {
            tempvar prior
            gen `prior' = 1 / r(N) if `touse'
        }
        else {
            su `prior' if `touse', meanonly
            if abs(r(sum) - 1) > 0.01 {
                di in r "prior probabilities sum to " r(sum)
                exit 198
            }
        }

        gen `sq' = `data'^2 if `touse'
        su `sq', meanonly
        local sumsq = r(sum)
        gen `diffsq' = (`data' - `N' * `prior')^2 if `touse'
        su `diffsq', meanonly
        local sumd2 = r(sum)
        local K = (`N'^2 - `sumsq') / `sumd2'

        if "`prob'" != "" {
            gen `pb' = (1 / (`N' + `K')) * (`data' + `K' * `prior')
        }
        else {
            gen `pb' = (`N' / (`N' + `K')) * (`data' + `K' * `prior')
        }
        label var `pb' "Estimate"
    }

    if "`center'" == "" { local center "center" }
    if "`format'" == "" { local format "%9.1f" }
    if "`layer'" != "" { local layer "by(`layer')" }
    tabdisp `by' if `touse', /*
     */ c(`pb') f(`format') `center' `options' `layer'

    if "`generat'" != "" {
        confirm new variable `generat'
        qui gen `generat' = `pb'
    }

    global S_1 = `N'
    global S_2 = `K'
end
