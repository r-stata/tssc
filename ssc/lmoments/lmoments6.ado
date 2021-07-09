*! 2.2.0 NJC 31 March 1999
* 2.1.0 NJC 12 February 1999
* 2.0.2 NJC 8 January 1999
* 2.0.1 NJC 1 September 1998
* 2.0.0 NJC 26 April 1998
* 1.0.0 NJC 17 September 1997
* based on lshape v 2.0.1 PR 06Oct95.
program define lmoments6, rclass 
        version 6.0
        syntax [varlist(numeric)] [if] [in] /* 
        */ [, BY(varname) Matname(str) Format(str) Detail * ]
        tokenize `varlist'
        local nvars : word count `varlist'

        if `nvars' > 1 & "`by'" != "" {
                di in r "too many variables specified"
                exit 103
        }

        if "`by'" != "" {
                local bylab : value label `by'
                qui tab `by' `if' `in', miss
                local nobs = r(r)
        }
        else local nobs = `nvars'

        if `nvars' > _N {
                tempvar orig
                gen byte `orig' = 1
                qui set obs `nvars'
        }
        local extra = "`orig'" != ""

        tempvar touse a group id n l1 l2 l3 l4 t t3 t4 which
        tempname N d B1 B2 B3 B4 L1 L2 L3 L4 i1

        qui {
                gen long `which' = _n
                compress `which'
                gen str1 `n' = ""
                label var `n' "n"
                gen `l1' = .
                label var `l1' "l_1"
                gen `l2' = .
                label var `l2' "l_2"
                gen `l3' = .
                label var `l3' "l_3"
                gen `l4' = .
                label var `l4' "l_4"
                gen `t' = .
                label var `t' "t"
                gen `t3' = .
                label var `t3' "t_3"
                gen `t4' = .
                label var `t4' "t_4"
        }

        if "`matname'" != ""  { mat `matname' = J(`nobs',8,0) }

        local I = 1
        qui while "`1'" != "" {
                mark `touse' `if' `in'
                markout `touse' `1'
                gen double `a' = `1' if `touse'

                sort `touse' `by' `a'
                by `touse' `by' : gen byte `group' = _n == 1 if `touse'
                by `touse' `by' : gen `id' = _n if `touse'
                replace `group' = sum(`group')
                local max = `group'[_N]
                count if !`touse'
                local J = 1 + r(N)
                local j = 1

                while `j' <= `max' {
                        count if `group' == `j'
                        local obs = r(N)
                        sum `a' if `group' == `j', meanonly
                        scalar `B1' = r(mean)
                        scalar `N' = `obs'
                        scalar `d' = `N'
                        local i = 2
                        while `i' <= 4 {
                                scalar `i1' = `i' - 1
                                scalar `d' = `d' * (`N' - `i1')
                                replace `a' = `a' * (`id' - `i1') /*
                                 */ if `group' == `j'
                                sum `a' if `group' == `j', meanonly
                                scalar `B`i'' = r(sum) / `d'
                                local i = `i' + 1
                        }
                        scalar `L1' = `B1'
                        scalar `L2' = 2 * `B2' - `B1'
                        scalar `L3' = 6 * `B3' - 6 * `B2' + `B1'
                        scalar `L4' = 20 * `B4' - 30 * `B3' + 12 * `B2' - `B1'
                        replace `n' = string(`N') if `which' == `I'
                        replace `l1' = `B1' if `which' == `I'
                        replace `l2' = `L2' if `which' == `I'
                        replace `l3' = `L3' if `which' == `I'
                        replace `l4' = `L4' if `which' == `I'
                        replace `t'  = `L2' / `L1' if `which' == `I'
                        replace `t3' = `L3' / `L2' if `which' == `I'
                        replace `t4' = `L4' / `L2' if `which' == `I'

                        if "`matname'" != "" {
                                mat `matname'[`I',1] = `obs'
                                mat `matname'[`I',2] = `B1'
                                mat `matname'[`I',3] = `L2'
                                mat `matname'[`I',4] = `L3'
                                mat `matname'[`I',5] = `L4'
                                mat `matname'[`I',6] = `L2' / `L1'
                                mat `matname'[`I',7] = `L3' / `L2'
                                mat `matname'[`I',8] = `L4' / `L2'
                        }

                        if "`by'" != "" {
                                local name = `by'[`J']
                                if "`name'" == "" | "`name'" == "." {
                                        local name "missing"
                                }
                                else if "`bylab'" != "" {
                                        local name : label `bylab' `name'
                                }
                        }
                        else local name "`1'"
                        label def which `I' "`name'", modify
                        local name = substr("`name'",1,8)
                        local rnames "`rnames' `name'"

                        local I = `I' + 1
                        local J = `J' + `obs'
                        local j = `j' + 1
                }

                mac shift
                drop `touse' `id' `group' `a'
        }

        if "`matname'" != "" {
                mat colnames `matname' = n l_1 l_2 l_3 l4 t t_3 t_4
                mat rownames `matname' = `rnames'
        }

        label val `which' which
        if "`by'" != "" { label var `which' "Group" }
        else label var `which' "Variable"

        if "`format'" == "" { local format "%9.3f" }

        if "`detail'" != "" {
                tabdisp `which' if `which' < `I', /*
                */  c(`n' `l1' `l2' `l3' `l4') `options' f(`format') miss
                tabdisp `which' if `which' < `I', /*
                */ c(`t' `t3' `t4') `options' f(`format') miss
        }
        else {
                tabdisp `which' if `which' < `I', /*
                 */ c(`l1' `l2' `t' `t3' `t4') `options' f(`format') miss
        }

        ret local N = `obs'
        ret local l_1 = `L1'
        ret local l_2 = `L2'
        ret local l_3 = `L3'
        ret local l_4 = `L4'
        ret local t = `L2' / `L1'
        ret local t_3 = `L3' / `L2'
        ret local t_4 = `L4' / `L2'

        label drop which
        if `extra' { qui keep if `orig' == 1 }
end
