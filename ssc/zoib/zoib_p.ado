*! 1.0.2 MLB 01 Aug 2012
*  1.0.0 MLB 26 May 2010

program define zoib_p
        version 8.2

			/* handle scores */
	syntax [anything] [if] [in] [, SCores * ]
        if `"`scores'"' != "" {
                GenScores `0'
                exit
        }


        local myopts "Proportion pr0 pr1 prcond"
        _pred_se "`myopts'" `0'
        if `s(done)'  exit 
        local vtyp `s(typ)'
        local varn `s(varn)'
        local 0    `"`s(rest)'"'
        syntax [if] [in] [, `myopts']
        marksample touse
		
                        /* concatenate switch options together */
        local type "`proportion'`sd'`pr0'`pr1'`prcond'"

                        /* quickly process default case        */
        if ("`type'"=="" | "`type'"=="proportion")  {
           if "`type'"=="" {
                di in gr "(option pr assumed)"
           }
           if "`e(title)'" == "ML fit of beta" {
                tempvar t
                qui _predict double `t' `if' `in', equation(#1)
                gen `vtyp' `varn' = invlogit(`t') if `touse'
			}
			if "`e(title)'" == "ML fit of zib" {
                tempvar t zi
                qui _predict double `t'  if `touse', equation(#1)
				qui _predict double `zi' if `touse', equation(#2) 
                gen `vtyp' `varn' = invlogit(-`zi')*invlogit(`t') if `touse'
			}
			if "`e(title)'" == "ML fit of oib" {
                tempvar t oi
                qui _predict double `t'  if `touse', equation(#1)
				qui _predict double `oi' if `touse', equation(#2) 
                gen `vtyp' `varn' = invlogit(-`oi')*invlogit(`t') + invlogit(`oi') if `touse'
			}
			if "`e(title)'" == "ML fit of zoib" {
                tempvar t zi oi
                qui _predict double `t'  if `touse', equation(#1)
				qui _predict double `oi' if `touse', equation(#2) 
				qui _predict double `zi' if `touse', equation(#3) 
                gen `vtyp' `varn' = invlogit(-`zi')*invlogit(-`oi')*invlogit(`t') + invlogit(`oi') if `touse'
			}
	        label var `varn' "Proportion"
			exit
        }
        
		if "`prcond'" != "" {
            tempvar t
            qui _predict double `t' if `touse', equation(#1)
            gen `vtyp' `varn' = invlogit(`t') if `touse'
			label var `varn' "proportion conditional on not having value 0 or 1"
			exit
		}
		if "`pr0'" != "" {
			if "`e(title)'" == "ML fit of oib" | "`e(title)'" == "ML fit of beta" {
				gen `vtyp' `varn' = 0 if `touse'
			}
			else {
				tempvar t
				qui _predict double `t' if `touse', equation(zeroinflate)
				gen `vtyp' `varn' = invlogit(`t') if `touse'
			}
			label var `varn' "probability of having value 0"
			exit
		}
		if "`pr1'" != "" {
			if "`e(title)'" == "ML fit of zib" | "`e(title)'" == "ML fit of beta" {
				gen `vtyp' `varn' = 0 if `touse'
			}
			else {
				tempvar t
				qui _predict double `t' if `touse', equation(oneinflate)
				gen `vtyp' `varn' = invlogit(`t') if `touse'
			}
			label var `varn' "probability of having value 1"
			exit
		}        
        error 198
end

program GenScores
        version 9.2
        syntax [anything] [if] [in] [, * ]
        marksample touse
        
        _score_spec `anything', `options'
        local varn `s(varlist)'
        if "`s(eqname)'" != "" local eq "eq(`s(eqname)')"
        
        ml score `varn' if `touse', `eq'
end



