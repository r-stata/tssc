*! 1.0.0 NJC 13 October 1998
program define pexp5
        version 5.0
        local varlist "max(1)"
        local if "opt"
        local in "opt"
        #delimit ;
        local options "Symbol(string) noBorder Connect(string)
        YLAbel(string) XLAbel(string) GRid Mean(str) *" ;
        #delimit cr
        parse "`*'"

        if "`symbol'" == "" { local symbol "oi" }
        else { local symbol "`symbol'i" }
        if "`connect'" == "" { local connect ".l" }
        else { local connect "`connect'l" }
        if "`ylabel'" == "" { local ylabel "0,.25,.5,.75,1" }
        if "`xlabel'" == "" { local xlabel "0,.25,.5,.75,1" }
        if "`grid'" != "" { local grid "yli(.25,.5,.75) xli(.25,.5,.75)" }

        tempvar touse F Psubi
        mark `touse' `if' `in'
        markout `touse' `varlist'
        sort `touse' `varlist'

        if "`mean'" == "" {
                su `varlist' if `touse', meanonly
                local mean = _result(3)
        }
        qui gen float `F' = 1 - exp(-`varlist' / `mean') if `touse'
        qui gen float `Psubi' = sum(`touse') if `touse'
        qui replace `Psubi' = (`Psubi'-0.5) / `Psubi'[_N] if `touse'

        local yl: variable label `varlist'
        if "`yl'" == "" { local yl "`varlist'" }
        label var `F' "Exponential F[`yl']"
        label var `Psubi' "Empirical P[i] = (i-0.5) / N"
        format `F' `Psubi' %9.2f
        if "`border'" == "" { local bo "border" }

        graph `F' `Psubi' `Psubi', c(`connect') s(`symbol') /*
                */ ylab(`ylabel') xlab(`xlabel') `bo' `grid' `options'
end
