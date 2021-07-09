*! 1.0.0  NJC 13 October 1998
program define qexp5 
        version 5.0
        local varlist "max(1)"
        local if "opt"
        local in "opt"
        local options /*
         */ "Symbol(string) Connect(string) GRid noBorder Mean(str) *"
        parse "`*'"

        if "`mean'" != "" { confirm number `mean' }

        if "`symbol'" == "" { local symbol "oi" }
        else { local symbol "`symbol'`i" }
        if "`connect'" == "" { local connect ".l" }
        else { local connect "`connect'`l" }

        tempvar touse x Psubi
        mark `touse' `if' `in'
        markout `touse' `varlist'
        sort `touse' `varlist'
        qui gen float `Psubi' = sum(`touse') if `touse'
        qui replace `Psubi' = (`Psubi' - .5) / `Psubi'[_N] if `touse'

        qui if "`grid'" != "" | "`mean'" == "" {
                if "`grid'" == "" { local opt "meanonly" }
                else local opt "detail"
                su `varlist' if `touse', `opt'
                if "`mean'" == "" { local mean = _result(3) }
                if "`grid'" != "" {
                        parse "5 10 25 50 75 90 95", parse(" ")
                        while "`1'" != "" {
                                local eq`1' : /*
                                 */ di %4.3f - `mean' * log(1 -`1'/100)
                                mac shift
                        }
                        local xtl = "`eq50',`eq95',`eq5'"
                        local xn = "`xtl',`eq25',`eq75',`eq90',`eq10'"
                        #delimit ;
                        local ytl = string(_result(7)) + "," +
                         string(_result(10)) + "," + string(_result(13)) ;
                        local yn = "`ytl'" + "," + string(_result(8)) + "," +
                         string(_result(9)) + "," + string(_result(11)) +
                         "," + string(_result(12)) ;
                        #delimit cr
                }
        }

        qui gen float `x' = - `mean' * log(1 - `Psubi')
        label var `x' "inverse exponential"
        local fmt : format `varlist'
        format `x' `fmt'

        if "`grid'" != "" {
                #delimit ;
                graph `varlist' `x' `x', c(`connect') s(`symbol') yli(`yn')
                rti(`yn') rla(`ytl') xli(`xn') tti(`xn') tla(`xtl') `options'
        t1("(Grid lines are 5, 10, 25, 50, 75, 90, and 95 percentiles)") ;
                #delimit cr
        }
        else {
                if "`border'" == "" { local bo "border"  }
                graph `varlist' `x' `x', c(`connect') s(`symbol') `bo' `options'
        }
end
