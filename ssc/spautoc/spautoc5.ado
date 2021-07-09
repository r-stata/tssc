*! 1.2.0 NJC 14 April 1999 
* 1.1.0 NJC 30 Oct 1998
* 1.0.0 NJC 3 Apr 1997
program def spautoc5
    version 5.0
    local varlist "min(2) max(2)"
    local if "opt"
    local in "opt"
    local options "LMEAn(str) LMEDian(str) W(str)"
    parse "`*'"
    parse "`varlist'", parse(" ")
    
    confirm str var `2'
    
    if "`lmean'" != "" { confirm new variable `lmean'}
    if "`lmedian'" != "" { confirm new variable `lmedian' }

    if "`w'" != "" {
        confirm str var `w'
        tempvar W
        qui gen `W' = .
        local uneqwt = 1
        local ww "[w = `W']"
    }
    else local uneqwt = 0

    tempvar touse xdev xsq x4p xlocal xmean xmed wrow wcol s2
    tempname sumsq sum4p iprod cprod S0 S1 S2 b2
    tempname I EI varNI varRI sNI sRI c varNc varRc sNc sRc

    mark `touse' `if' `in'
    markout `touse' `1'

    qui {
        local x `1'
        local nei `2'
        su `x' if `touse', meanonly
        local n = _result(1)
        gen `xdev' = `x' - _result(3) if `touse'
        gen `xsq' = `xdev'^2
        su `xsq', meanonly
        scalar `sumsq' = _result(18)
        gen `x4p' = `xdev'^4
        su `x4p', meanonly
        scalar `sum4p' = _result(18)

        gen `xlocal' = .
        gen `xmean' = .
        gen `xmed' = .
        gen `wrow' = 0 if `touse'
        gen `wcol' = 0 if `touse'
        scalar `iprod' = 0
        scalar `cprod' = 0
        scalar `S0' = 0
        scalar `S1' = 0

        * for each observation
        local i = 1
        while `i' <= _N {
            local OK = `touse'[`i']
            if `OK' {
                local nabors  = `nei'[`i']
                parse "`nabors'", parse(" ")
                local ni : word count `nabors'
                local j = 1
                while `j' <= `ni' {
                    local j`j' = ``j''
                    local j = `j' + 1
                }
                * for each neighbour
                local j = 1
                while `j' <= `ni' {
                    if `uneqwt' {
                        local wi = `w'[`i']
                        parse "`wi'", parse(" ")
                        local nw : word count `wi'
                        if `nw' != `ni' {
                            di in r /*
                */ "number of weights != number of neighbours in `i'"
                            exit 198
                        }
                        local wij : word `j' of `wi'
                        replace `W' = `wij' in `j'
                    }
                    else local wij 1
                    scalar `iprod' = `iprod' + /*
                     */ `wij' * `xdev'[`i'] * `xdev'[`j`j'']
                    scalar `cprod' = `cprod' + /*
                     */ `wij' * (`xdev'[`i'] - `xdev'[`j`j''])^2
                    scalar `S0' = `S0' + `wij'
                    replace `xlocal' = `x'[`j`j''] in `j'
                    replace `wrow' = `wrow' + `wij' in `i'
                    replace `wcol' = `wcol' + `wij' in `j`j''

		    * look up w[j,i] which may differ from w[i,j] 
		    local naborsj = `nei'[`j`j''] 
		    local nj : word count `naborsj'
		    if `uneqwt' { local wj = `w'[`j`j''] }
		    local k = 1
		    local found = 0 
		    while !`found' & `k' <= `nj' { 
		        local ji : word `k' of `naborsj' 
			if `ji' == `i' { 
			    if `uneqwt' { local wji : word `k' of `wj' }
			    else local wji = 1 
			    local found = 1 
			}
			local k = `k' + 1 
	            }    
		    if !`found' { 
			di in r "`i' neighbours `j`j'', but not vice versa"
			exit 198 
		    }
		    
                    scalar `S1' = `S1' + (`wij' + `wji' )^2
                    local j = `j' + 1
                } /* next neighbour */
		
                if `ni' > 0 {
                    su `xlocal' in 1/`ni' `ww', d
                    replace `xmed' = _result(10) in `i'
                    replace `xmean' = _result(3) in `i'
                }
                else {
                    replace `xmed' = . in `i'
                    replace `xmean' = . in `i'
                }
            }
            local i = `i' + 1
	    
        } /* next observation */

        scalar `S1' = `S1' / 2
        scalar `I' = (`iprod' * `n') / (`S0' * `sumsq')
        scalar `EI' = -1 / (`n' - 1)
        gen `s2' = (`wrow' + `wcol')^2
        su `s2', meanonly
        scalar `S2' = _result(18)
        scalar `b2' = (`n' * `sum4p') / `sumsq'^2
        scalar `varNI' = (`n'^2 * `S1' - `n' * `S2' + 3 * `S0'^2)
        scalar `varNI' = `varNI' / (`S0'^2 * (`n'^2 - 1)) - `EI'^2
        scalar `varRI' = (`n'^2 - 3 * `n' + 3) * `S1' - `n' * `S2' + /*
         */ 3 * `S0'^2
        scalar `varRI' = `n' * `varRI'
        scalar `varRI' = `varRI' - `b2' *  /*
         */ ((`n'^2 - `n') * `S1' - 2 * `n' * `S2' + 6 * `S0'^2)
        scalar `varRI' = `varRI' / /*
         */ ((`n' - 1) * (`n' - 2) * (`n' - 3) * `S0'^2) - `EI'^2
        scalar `sNI' = (`I' - `EI') / sqrt(`varNI')
        scalar `sRI' = (`I' - `EI') / sqrt(`varRI')

        scalar `c' = (`cprod' * (`n' - 1)) / (2 * `S0' * `sumsq')
        local Ec = 1
        scalar `varNc' = ((2 * `S1' + `S2') * (`n' - 1) - 4 * `S0'^2) / /*
         */ (2 * (`n' + 1) * `S0'^2)
        scalar `varRc' = (`n' - 1) * `S1' * /*
         */  (`n'^2 - 3 * `n' + 3 - (`n' - 1) * `b2')
        scalar `varRc' = `varRc' - ( 1 / 4 * (`n' - 1) * `S2' * /*
         */ (`n'^2 + 3 * `n' - 6 - (`n'^2 - `n' + 2) * `b2'))
        scalar `varRc' = `varRc' + `S0'^2 * (`n'^2 - 3 - (`n' - 1)^2 * `b2')
        scalar `varRc' = `varRc' / (`n' * (`n' - 2) * (`n' - 3) * `S0'^2)
        scalar `sNc' = (`c' - `Ec') / sqrt(`varNc')
        scalar `sRc' = (`c' - `Ec') / sqrt(`varRc')
    }

    di _n in g _dup(28) " "  "           expected  standard"
    di    in g _dup(28) " "  "statistic    value    deviate  P-value"
    di _n in g "Moran coefficient I      "  /*
    */ in y %10.3f  `I' %11.3f `EI'
    di in g "           normality" _dup(26) " " /*
     */ in y %9.3f `sNI' %10.3f  2 * (1 - normprob(abs(`sNI')))
    di in g "           randomisation" _dup(22) " " /*
     */ in y %9.3f `sRI' %10.3f 2 * (1 - normprob(abs(`sRI')))
    di _n in g "Geary coefficient c      " /*
     */ in y %10.3f `c' %11.3f `Ec'
    di in g "           normality" _dup(26) " " /*
     */ in y %9.3f `sNc' %10.3f 2 * (1 - normprob(abs(`sNc')))
    di in g "           randomisation" _dup(22) " " /*
     */ in y %9.3f `sRc' %10.3f 2 * (1 - normprob(abs(`sRc')))

    qui if "`lmean'" != "" { gen `lmean' = `xmean' if `touse' }
    qui if "`lmedian'" != "" { gen `lmedian' = `xmed' if `touse' }

    global I = `I'
    global EI = `EI'
    global sNI = `sNI'
    global sRI = `sRI'
    global c = `c'
    global Ec = `Ec'
    global sNc = `sNc'
    global sRc = `sRc'

end
