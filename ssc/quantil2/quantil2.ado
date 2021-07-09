*! NJC 1.3.1 21 February 2002 ranks option  
*! NJC 1.3.0 22 February 2001   (STB-61: gr42.1)
* NJC 1.2.0 10 August 1999 
* NJC 1.1.0 24 March 1999
* NJC 1.0.1 17 March 1998
* NJC 1.0.0 15 March 1998
program def quantil2, sort 
    version 7.0
    syntax varlist [if] [in] [, A(real 0.5) BY(varname) L1title(str) /* 
    */ XLAbel(str) noBOrder SOrt MISSing Reverse RANKs * ]
    tokenize `varlist'
    local nvars : word count `varlist'

    if "`by'" != "" & `nvars' > 1 {
            di in r "too many variables specified"
            exit 103
    }

    marksample touse
    if "`missing'" == "" {
        if "`by'" != "" { markout `touse' `by', strok }
    }
    else {
        if "`by'" == "" { di in bl "missing only applies with by( )" }
    }

    if "`by'" == "" { /* no `by' option */
        tempvar pp order
	if "`ranks'" != "" { 
	    qui egen `pp' = rank(`1') if `touse', unique
	    label var `pp' "Rank" 
	}
	else egen `pp' = pp(`1') if `touse', a(`a')
	sort `touse' `pp' 
        gen `order' = _n

        local i 1
        while `i' <= `nvars' {
            tempvar y`i'
            sort `touse' ``i''
            gen `y`i'' = ``i''[`order']
            label var `y`i'' "``i''"
            local ylist "`ylist'`y`i'' "
            local Ylist "`Ylist'``i'' "
            local i = `i' + 1
        }

        if "`l1title'" == "" {
            if `nvars' == 1 { 
	        local l1title : variable label `varlist' 
		if "`l1title'" == "" { local l1title "`varlist'" }
		local l1title "Quantiles of `l1title'"     
	    }		
            else if length("`Ylist'") < 25 {
                local l1title "Quantiles of `Ylist'"
            }
            else local l1title "`Ylist'" 
        }
    }

    else { /* by( ) */
        tempvar pp group
	if "`ranks'" != "" { 
	    qui egen `pp' = rank(`varlist') if `touse', by(`by') unique
	    label var `pp' "Rank" 
	}    
        else qui egen `pp' = pp(`varlist') if `touse', by(`by') a(`a')
        sort `touse' `by'
        qui by `touse' `by': gen byte `group' = _n == 1 if `touse'
        qui replace `group' = sum(`group')
        local max = `group'[_N]
        local bylab : value label `by'
        local type : type `varlist'
        local vallab : value label `varlist'

        local i 1
        qui count if !`touse'
        local j = 1 + r(N)
        qui while `i' <= `max' {
            tempvar y`i'
            gen `type' `y`i'' = `varlist' if `group' == `i'
            compress `y`i''
            local ylist "`ylist' `y`i''"
            local byval = `by'[`j']
            if "`bylab'" != "" { local byval : label `bylab' `byval' }
            label var `y`i'' `"`byval'"'
            if "`vallab'" != "" { label val `y`i'' `vallab' }
            count if `group' == `i'
            local j = `j' + r(N)
            local i = `i' + 1
        }

        if "`l1title'" == "" {
            local l1title : variable label `varlist'
            if "`l1title'" == "" { local l1title "`varlist'" }
            if length("`l1title'") < 25 {
                local l1title "Quantiles of `l1title'"
            }
        }
   }

   if "`border'" == "" { local border "border" }
   if "`xlabel'" == "" { 
   	local xlabel = cond("`ranks'" != "", "xla", "xla(0(0.25)1)") 
   }
   else local xlabel "xla(`xlabel')" 
   qui if "`reverse'" != "" { 
   	if "`ranks'" != "" { 
		bysort `touse' `by' (`pp') : replace `pp' = _N + 1 - `pp' 
	} 
	else replace `pp' = 1 - `pp' 
   } 

   gra `ylist' `pp' , `xlabel' `border' l1("`l1title'") sort /*
    */ `options'

end
