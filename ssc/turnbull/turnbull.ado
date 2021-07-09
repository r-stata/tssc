*! version 1.0          <200100217>          JP Azevedo

capture program drop turnbull
program define turnbull, rclass
    version 8.0

    syntax  [varlist(max=2)] ///
		 	[if] ///
			[in] ///
                  [fweight] ///
			[, ///
				short ///
				MAXvalue(real -1) ///
				GROUP(varname) *  ///
				]

    tokenize `varlist'
    loc word = wordcount("`varlist'")
    loc N = _N

    tempvar touse
    tempname cell col row row2 bid n Tj Fj fj f FjT FjT2 fjT q1 a1 b1 c1 d1 e1 r1 rowini cellini A1 A1a A1b A1c

    mark `touse' `if' `in' [`weight'`exp']

    qui sum `1'  [`weight' `exp'] if `touse'
    if (`maxvalue' == -1) {
        loc maxvalue = 3*`r(max)'
    }
    qui tab `1' `2'  [`weight' `exp'] if `touse', matcell(`cell')  matrow(`row')

    mat `row' = 0 \ `row' \ `maxvalue'
    mat `cell' = 0,0 \ `cell' \ 0,0
    loc last = rowsof(`row')

    mat `rowini' = `row'
    mat `cellini' = `cell'

    preserve

    /** Turnbull - monotonicity */
    local tabname `1'
    loc t = 2
    loc intmax = `last'                            /*** max number interactions  */
    tempvar

    qui forvalues int = 1(1)`intmax' {

        tempvar t`int'  f`int' r`int' q`int' a`int' b`int' c`int' d`int' r`int'

        loc last = rowsof(`row')

        gen `t`int'' = .
        gen `f`int'' = 1 in 1/`last'

        svmat double `row', names(`c`int'')             /*** col bid          */
        svmat double `cell', names(`r`int'')            /*** val Nj e Sj      */
        local tabname "`c`int''1"

        gen `b`int''1 = `r`int''1 + `r`int''2           /*** gen Tj           */
        gen `a`int'' = `r`int''1/`b`int''1
        replace `a`int'' = 0 in 1
        replace `a`int'' = 1 in `last'

        if (`int' == 1) {

            tempvar tmp1 tmp2 tmp3 tmp4
            gen `tmp1' = 2 in 1/`last'
            gen `tmp2' = 3 in 1/`last'
            gen `tmp3' = 4 in 1/`last'
            gen `tmp4' = 1 in 1/`last'
            mkmat `c`int''1 `tmp1' `r`int''1 `tmp4' in 1/`last',  mat(`A1a')
            mkmat `c`int''1 `tmp2' `b`int''1 `tmp4' in 1/`last',  mat(`A1b')
            mkmat `c`int''1 `tmp3' `a`int''  `tmp4' in 1/`last',  mat(`A1c')
            mat A1 = `A1a' \ `A1b' \ `A1c'
            matrix colnames A1  = _v1 tipo _v _s
            mat list A1
        }

        qui tab `a`int''

        forvalues k = 1(1)`last' {
            loc k2 = `k'+1
            if (`a`int''[`k2'] <= `a`int''[`k']) {
                loc val = `c`int''1 in `k'
                loc val2 = `c`int''1 in `k2'
                replace `f`int'' = `t'  in `k' if  `f`int''[`k'] == 1
                replace `f`int'' = `t'  in `k2' if  `f`int''[`k'2] == .
                replace `c`int''1 = `c`int''1[_n-1] in `k2'
                loc t = `t'+1
                loc last = `last'-1
                if (`k' != `last') {
                    loc lab`int'   " `val'  `val'p "
                    loc labnames "`labnames'   `lab`int''  "
                    loc lab`int'   " `val2'  `val2'p "
                    loc labnames "`labnames'   `lab`int''  "
                }
                continue, break
            }
        }

        qui sum `f`int''
        if (`r(mean)'>1) {
            tempvar A`int'
            collapse (sum) `r`int''*, by(`c`int''1)
            gen `b`int''1 = `r`int''1 + `r`int''2           /*** gen Tj           */
            gen `a`int'' = `r`int''1/`b`int''1
            replace `a`int'' = 0 in 1
            replace `a`int'' = 1 in `last'
            mkmat `c`int''1 , mat(`row')
            mkmat `r`int''1 `r`int''2 , mat(`cell')
        }
        else {
            loc int = `int'-1
            loc final "A`int'"
            mkmat `c`int''1 `r`int''1 `r`int''2 `b`int''1  `a`int'' , mat(A`int')
            continue, break
        }
    }

    restore

    tempvar tmp fjT VFjT VfjT ElbWTP VElbWTP EubWTP
    svmat double `final', names(`tmp')
    loc y = `last'-1

    qui gen `fjT'       = `tmp'5[_n] - `tmp'5[_n-1]
    qui gen `VFjT'      = (`tmp'5*(1-`tmp'5))/`tmp'4
    qui gen `VfjT'      = `VFjT'[_n] + `VFjT'[_n-1]
    qui gen `ElbWTP'    = (`tmp'5[_n+1]-`tmp'5[_n])*`tmp'1
    qui gen `EubWTP'    = (`tmp'5[_n+1]-`tmp'5[_n])*`tmp'1[_n+1]
    qui gen `VElbWTP'   = (`VFjT')*(`tmp'1[_n]-`tmp'1[_n-1])^2

    qui sum `ElbWTP'    in 1/`y'
    loc elb = r(sum)
    loc n   = r(N)
    qui sum `VElbWTP'   in 2/`y'
    loc velb = r(sum)
    qui sum `EubWTP'    in 1/`y'
    loc eub = r(sum)
    qui sum `tmp'2    in 1/`y'
    loc NjT = r(sum)
    qui sum `tmp'4    in 1/`y'
    loc TjT = r(sum)


    loc tstat = `elb'/(`velb')^.5
    di ""
    di ""
    di ""
*     di "Elb(WTP)    = "   %9.3f  `elb'
*     di "V(Elb(WTP)) = "   %9.3f `velb'
*     di "Pval(Elb)   = "   %9.3f  ttail(`n',`tstat')
*     di "Eub(WTP)    = "   %9.3f  `eub'

    loc totalline = `maxvalue'+1
    tempvar total
    mat total = (`totalline', 2 , `NjT', 1) \ (`totalline', 3 , `TjT', 1 )\ (`totalline', 5 , `NjT', 2)\ (`totalline', 6 , `TjT', 2)\ (`totalline', 9 , `elb', 3)\ (`totalline', 10, `velb', 3)\ (`totalline', 11, `eub', 3)

    quietly {

         preserve

         keep if `tmp'1 != .
         keep `tmp'1 `tmp'2 `tmp'4 `tmp'5 `fjT' `ElbWTP' `VElbWTP'  `EubWTP'
         rename `tmp'1      _v1
         rename `tmp'2      _v5
         rename `tmp'4      _v6
         rename `tmp'5      _v7
         rename `fjT'       _v8
         rename `ElbWTP'    _v9
         rename `VElbWTP'   _v10
         rename `EubWTP'    _v11
         reshape long  _v, i(_v1) j(tipo)
         gen _s = 2 if tipo < 9
         replace _s = 3 if tipo >= 9
         mkmat _v1 tipo _v _s, mat(B1)
         mat B1 = B1 \ A1 \total
         drop _v1 tipo _v _s
         svmat double B1, names(col)

         label var _v1 Bid
         label var tipo "Turnbull Estimates"
         label define tipo 2 "Nj" 3 "Tj" 4 "Fj"  5 "Nj*" 6 "Tj*" 7 "Fj*" 8 "fj*" 9 "Elb" 10 "V(Elb)" 11 "Eub", modify
         label define s 1 "Original" 2 "Turnbull" 3 "WTP", modify
         label define bid `labnames', modify add
         label define bid `totalline' Total, modify add

         sum _v1
         replace _v = . if _v1 == `r(min)' & tipo == 2
         replace _v = . if _v1 == `r(min)' & tipo == 3
         replace _v = . if _v1 == `maxvalue' & tipo == 2
         replace _v = . if _v1 == `maxvalue' & tipo == 3
         replace _v = . if _v1 == `r(min)' & tipo == 5
         replace _v = . if _v1 == `r(min)' & tipo == 6
         replace _v = . if _v1 == `maxvalue' & tipo == 5
         replace _v = . if _v1 == `maxvalue' & tipo == 6

         label values _s s
         label values tipo tipo
         label values _v1  bid
	   if ("`short'" == "") {
	         noi tabdisp _v1 tipo if tipo != 1, c(_v) format(%16.3fc) center
	   }
	   if ("`short'" != "") {
	         noi tabdisp _v1 tipo if tipo != 1 & (tipo == 3 | tipo >= 9), c(_v) format(%16.3fc) center
	   }
	   noi di "Note: (p) pooled category. Last bid value was arbitrarily chosen. Pval(Elb) =" in y  %9.5f ttail(`n',`tstat') in g "."
	   noi di ""	
	   noi di ""	
	   noi di ""	

        tempvar A
        keep if tipo != 1
        drop _s
        reshape wide _v , i(_v1) j(tipo)
        mkmat _all , mat(`A')
        mat colnames `A' =  Bid     Nj        Tj        Fj        Nj*       Tj*       Fj*       fj*       Elb     V(Elb)      Eub
        restore

    }

    return matrix turnbull = `A'
    return scalar elbwtp  = `elb'
    return scalar velbwtp = `velb'
    return scalar eubwtp  = `eub'
    return scalar pval    = ttail(`n',`tstat')

end
