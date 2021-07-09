* This version 1.0     <12dec2008> 	   JPAzevedo

pr def mol , rclass

        version 7.0

        syntax varlist(min=1 max=1)     ///
              [if] [in]                 ///
              [aweight fweight],        ///
              house(string)             ///
              [                         ///
              alpha(string)             ///
              by(string)                ///
              format(string)            ///
              gen                       ///
              rank                      ///
              ]


        quietly {

        tempvar touse

        mark `touse' `if' `in' [`weight'`exp']

        if ("`alpha'" == "") & ("`house'" == "") {
            di _n in y "mol" in r " if alpha is not specified house must be"
            exit 498
        }

        local k  "`varlist'"

        if ("`format'"==""){
            local format "%9.1f"
        }

        if ("`by'" == "") {

            /* Optimal Alpha */

            tempvar label value Rj Re I_1 Q

            bysort `house' : egen `Rj' = mean(`k') if `touse' == 1
            gen     `Re' = `k'        if `k' == 1
            replace `Re' = `Rj'   if `k' == 0

            gen `label' = .
            gen `value' = .

            local c = 1
            local l = 1
            sum `k' [`weight' `exp'] if `touse' == 1
            local r = `r(mean)'
            local c = 1
            replace `label' = `c' in `l'
            replace `value' = `r' in `l'
            return local R = `r(mean)'
            label define label `c' "'Crude' Literacy Rate (R)", modify

            local c = `c'+1
            local l = `l'+1
            sum `Re' [`weight' `exp'] if `touse' == 1
            local c = 2
            replace `label' = `c' in `l'
            replace `value' = `r(mean)' in `l'
            return local Re = `r(mean)'
            label define label `c' "Effective Literacy (Re) [alpha = hous. lit. rate]", modify

            local c = `c'+1
            local l = `l'+1
            gen     `I_1' = 1   if `k' == 1
            replace `I_1' = 1   if `k' == 0 & `Rj' > 0
            replace `I_1' = 0   if `k' == 0 & `Rj' == 0
            sum `I_1' [`weight' `exp'] if `touse' == 1
            replace `label' = `c' in `l'
            replace `value' = `r(mean)' in `l'
            return local I = (1-`r(mean)')
            label define label `c' "Isolated Rate of Literacy (1-I)", modify

            local c = `c'+1
            local l = `l'+1
            replace `label' = `c' in `l'
            replace `value' = (1-`r(mean)') in `l'
            label define label `c' "Isolated Rate of Illiteracy (I)", modify


            local c = `c'+1
            local l = `l'+1
            local i = 1-`r(mean)'
            local q = `i'/(1-`r')
            replace `label' = `c' in `l'
            replace `value' = `q' in `l'
            return local Q = `q'
            label define label `c' "Efficiency Loss (Q)", modify

            local c = `c'+1
            local l = `l'+1
            local i = 1-`r(mean)'
            local ra = `r'*(1-`i')
            replace `label' = `c' in `l'
            replace `value' = `ra' in `l'
            return local Ra = `ra'
            label define label `c' "Externality-adjusted Literacy Rate (R*)", modify

            local c = `c'+1
            local l = `l'+1

            /* Flexible Alphas */

            if ("`alpha'" != "") {

                qui foreach i in `alpha' {

                    tempvar R_`c'
                    gen     `R_`c'' = 1     if `k' == 1
                    replace `R_`c'' = `i'   if `k' == 0 & `Rj' > 0
                    replace `R_`c'' = 0     if `k' == 0 & `Rj' == 0

                    sum `R_`c'' [`weight' `exp'] if `touse' == 1
                    replace `label' = `c' in `l'
                    replace `value' = `r(mean)' in `l'
                    return local R_`c' = `r(mean)'
                    label define label `c' "Proximate Literacy (P) [alpha = `i']", modify

                    local c = `c'+1
                    local l = `l'+1
                }

            }

        }

        if ("`by'" != "") {

            _pecats `by'  if `touse'  					
            local nrows = r(numcats)
            local cat = r(catvals)
            local labcat = r(catnms8)

            local byvalue : value label `by'

            /* Optimal Alpha */

            tempvar label value bytmp Rj Re

            bysort `house' : egen `Rj' = mean(`k') if `touse' == 1
            gen     `Re' = `k'    if `k' == 1
            replace `Re' = `Rj'   if `k' == 0

            gen `label' = .
            gen `bytmp'    = .
            gen `value' = .

            local l = 1
            foreach bycat in `cat' {

                tempvar I_1_`bycat'

                local c = 1

                sum `k' [`weight' `exp'] if `by' == `bycat' & `touse' == 1
                local r_`bycat' = `r(mean)'
                replace `label' = `c' in `l'
                replace `bytmp' = `bycat' in `l'
                replace `value' = `r_`bycat'' in `l'
                return local R_`bycat' = `r(mean)'
                label define label `c' "R", modify

                local c = `c'+1
                local l = `l'+1
                sum `Re' [`weight' `exp'] if `by' == `bycat' & `touse' == 1
                replace `label' = `c' in `l'
                replace `bytmp' = `bycat' in `l'
                replace `value' = `r(mean)' in `l'
                return local Re_`bycat' = `r(mean)'
                label define label `c' "Re", modify

                local c = `c'+1
                local l = `l'+1
                gen     `I_1_`bycat'' = 1   if `k' == 1
                replace `I_1_`bycat'' = 1   if `k' == 0 & `Rj' > 0
                replace `I_1_`bycat'' = 0   if `k' == 0 & `Rj' == 0
                sum `I_1_`bycat'' [`weight' `exp'] if `by' == `bycat' & `touse' == 1
                local i_`bycat' = (1-`r(mean)')
                replace `label' = `c' in `l'
                replace `bytmp' = `bycat' in `l'
                replace `value' = `r(mean)' in `l'
                label define label `c' "(1-I)", modify

                local c = `c'+1
                local l = `l'+1
                replace `label' = `c' in `l'
                replace `bytmp' = `bycat' in `l'
                replace `value' = `i_`bycat'' in `l'
                return local I_`bycat' = `i_`bycat''
                label define label `c' "I", modify

                local c = `c'+1
                local l = `l'+1
                local q = `i_`bycat''/(1-`r_`bycat'')
                replace `label' = `c' in `l'
                replace `bytmp' = `bycat' in `l'
                replace `value' = `q' in `l'
                return local Q_`bycat' = `q'
                label define label `c' "Q", modify

                local c = `c'+1
                local l = `l'+1
                local ra_`bycat' = `r_`bycat''*(1-`i_`bycat'')
                replace `label' = `c'       in `l'
                replace `bytmp' = `bycat'   in `l'
                replace `value' = `ra_`bycat''      in `l'
                return local Ra_`bycat' = `ra_`bycat''
                label define label `c' "R*", modify

                local c = `c'+1
                local l = `l'+1

                /* Flexible Alphas */

                if ("`alpha'" != "") {

                    qui foreach i in `alpha' {

                        tempvar R_`c'_`bycat'

                        gen     `R_`c'_`bycat'' = 1     if `k' == 1
                        replace `R_`c'_`bycat'' = `i'   if `k' == 0 & `Rj' > 0
                        replace `R_`c'_`bycat'' = 0     if `k' == 0 & `Rj' == 0

                        sum `R_`c'_`bycat'' [`weight' `exp'] if `by' == `bycat' & `touse' == 1
                        replace `label' = `c' in `l'
                        replace `bytmp' = `bycat' in `l'
                        replace `value' = `r(mean)' in `l'
                        return local R_`c'_`bycat' = `r(mean)'
                        label define label `c' "P[a=`i']", modify

                        local l = `l'+1
                        local c = `c'+1
                    }

                }
            }

        }


        if ("`by'" == "") {
           /* Display */

           label values  `label' label
           label var `label' "Index"
           label var `value' "Value"
           replace `value' = `value'*100

           noi tabdisp `label' if `value' != ., c(`value') format(`format') concise

        }

        if ("`by'" != "") {
           /* Display */

           label values  `label' label
           label values `bytmp' `byvalue'

           label var `label' "Index"
           label var `value' "Value"
           label var `bytmp' "`by'"
           replace `value' = `value'*100

         if ("`rank'" == "") {

               noi tabdisp `bytmp' `label' if `value' != . & `label' != 5 , c(`value') format(`format') concise

         }



         if ("`rank'" != "") {

                tempvar value2 rank value3

                gsort `label' -`value'

                by `label' : gen  `rank' = _n if `label' != .

                gen str5 `value2' = string(`value', "%9.1f")

                gen str10 `value3' = ""
                replace `value3' = `value2' +  " (" + string(`rank') + ")" if length(string(`rank')) == 2
                replace `value3' = `value2' + "  (" + string(`rank') + ")" if length(string(`rank')) == 1
                replace `value3' = `value2' if `label' == 3
                replace `value3' = `value2' if `label' == 4

                noi tabdisp `bytmp' `label' if `value3' != "" & `label' != 5 & `label' != . & `bytmp' != ., c(`value3') concise
                noi di "Note: Rank in parenthesis"

         }

         if ("`gen'" != "") {

               gen value = `value'
               gen index = `label'
               gen bytmp = `bytmp'
               label values index label

        }

        }

        }

        end
