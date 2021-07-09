*! rdcii.ado Version 1.2 2010-09-30 JRC
program define rdcii, rclass
    version 9.2
    syntax anything(id="argument numlist") [, Level(real `c(level)') Zsot Cc noBRUTEforce ///
      TOLerance(real 1e-6) LTOLerance(real 0) Verbose INITial(numlist ascending min=1 max=2)]

    tempname z z2 n0 n1 p0 p1 rd lb ub bracket chi2rd

    tokenize `anything'
    if ("`1'" == "miemar") `1' `2' `3' `4' `5' `6' `7' `8'
    else {
        local variable_tally : word count `anything'
        if (`variable_tally' > 4) exit = 103
        if (`variable_tally' < 4) exit = 102
*
        forvalues i = 1/4 {
            capture confirm integer number ``i''
            if _rc {
                display in smcl as error "`id' must all be numeric."
                exit = 499
            }
        }
        forvalues i = 1/4 {
            capture assert ``i'' >= 0
            if _rc {
                display in smcl as error "`id' must all be nonnegative."
                exit = 499
            }
        }
        if !inrange(`level', 0.1, 99.9) {
            display in smcl as error "Level must lie between 0.1 and 99.9."
            exit = 499
        }
*
        scalar define `z' = invnormal(1 - (100 - `level') / 200 )
        scalar define `z2' = invchi2(1, `level' / 100)
        scalar define `n0' = `2' + `4'
        scalar define `n1' = `1' + `3'
        scalar define `p0' = `2' / `n0'
        scalar define `p1' = `1' / `n1'
        scalar define `rd' = `p1' - `p0'
        scalar define `lb' = .
        scalar define `ub' = .
*
        capture assert ( (`n0' > 0) & (`n1' > 0) )
        if _rc {
            display in smcl as error "Each exposure group must have at least one observation."
            exit = 499
        }
*
        return scalar p0 = `p0'
        return scalar p1 = `p1'
        return scalar rd = `rd'
*
* Agresti-Caffo confidence interval
*
        agresticaffo `1' `2' `n1' `n0', lb(`lb') ub(`ub') z(`z') z2(`z2') `zsot'
        return scalar lb_ac = `lb'
        return scalar ub_ac = `ub'
*
* Newcombe's Method 10 confidence interval
*
        newcombe `1' `2' `n1' `n0' `p1' `p0' `rd', lb(`lb') ub(`ub') z(`z') z2(`z2')
        return scalar lb_ne = `lb'
        return scalar ub_ne = `ub'
*
* Wallenstein's confidence interval
*
        wallenstein `1' `2' `n1' `n0' `p1' `p0' `rd', lb(`lb') ub(`ub') z(`z') z2(`z2') `cc'
        return scalar lb_wa = `lb'
        return scalar ub_wa = `ub'
*
* Miettinen-Nurminen confidence interval
*
        scalar define `chi2rd' = .
        if (`tolerance' != 1.000e-6) local tolerance tol `tolerance'
        else local tolerance
*
        if (`ltolerance' != 0) local ltolerance ltol `ltolerance'
        else local ltolerance
*
        if ("`verbose'" != "") local verbose noisily
*
        if ("`initial'" != "") {
            gettoken lower upper : initial
            scalar define `bracket' = `lower'
        }
        else scalar define `bracket' = `rd'
*
        local one = 0.9999999999
        local minus_one = -.9999999999
*
        if (`rd' == -1) return scalar lb_mn = `rd'
        else {
            capture `verbose' ridder rdcii "miemar" `1' `2' `n1' `n0' `rd' `chi2rd' X returns exp `chi2rd' = `z2' ///
              from `minus_one' to `bracket' `tolerance' `ltolerance'
            if !_rc return scalar lb_mn = $S_1
            else {
                return scalar lb_mn = .
                if ("`bruteforce'" == "") {
                    forvalues i = -1(0.01)`=`bracket'' {
                        capture `verbose' ///
                          ridder rdcii "miemar" `1' `2' `n1' `n0' `rd' `chi2rd' X returns exp `chi2rd' = `z2' ///
                          from `minus_one' to `i' `tolerance' `ltolerance'
                        if !_rc {
                            return scalar lb_mn = $S_1
                            continue, break
                        }
                    }
                }
            }
        }
*
        if (`rd' == 1) return scalar ub_mn = `rd'
        else {
*
            if ("`upper'" != "") scalar define `bracket' = `upper'
*
            capture `verbose' ridder rdcii "miemar" `1' `2' `n1' `n0' `rd' `chi2rd' X returns exp `chi2rd' = `z2' ///
              from `bracket' to `one' `tolerance' `ltolerance'
            if !_rc return scalar ub_mn = $S_1
            else {
                return scalar ub_mn = .
                if ("`bruteforce'" == "") {
                    forvalues i = `=`bracket''(0.01)1 {
                        capture `verbose' ///
                          ridder rdcii "miemar" `1' `2' `n1' `n0' `rd' `chi2rd' X returns exp `chi2rd' = `z2' ///
                          from `i' to `one' `tolerance' `ltolerance'
                        if !_rc {
                            return scalar ub_mn = $S_1
                            continue, break
                        }
                    }
                }
            }
        }
        macro drop S_1
*
* 
*
        display in smcl as text _newline(1) "Confidence intervals for risk difference" _newline(1)
        display in smcl as text "       Risk for unexposed (p0): " as result %05.3f return(p0)
        display in smcl as text "         Risk for exposed (p1): " as result %05.3f return(p1)
        display in smcl as text "     Risk difference (p1 - p0): " as result %05.3f return(rd)
        display in smcl as text _newline(1) "{hline 41}"
        display in smcl as text _column(10) "Method" _column(20) %22s "[`=string(`level', "%5.0g")'% Conf. Interval]"
        display in smcl as text "{hline 41}"
        display in smcl as text %18s "Agresti-Caffo" ///
          _column(`=cond(return(lb_ac) < 0, 22, 23)') as result %05.3f return(lb_ac) ///
          _column(`=cond(return(ub_ac) < 0, 36, 37)') as result %05.3f return(ub_ac)
        display in smcl as text %18s "Newcombe Method 10" ///
          _column(`=cond(return(lb_ne) < 0, 22, 23)') as result %05.3f return(lb_ne) ///
          _column(`=cond(return(ub_ne) < 0, 36, 37)') as result %05.3f return(ub_ne)
        display in smcl as text %18s "Wallenstein" ///
          _column(`=cond(return(lb_wa) < 0, 22, 23)') as result %05.3f return(lb_wa) ///
          _column(`=cond(return(ub_wa) < 0, 36, 37)') as result %05.3f return(ub_wa)
        display in smcl as text %18s "Miettinen-Nurminen" ///
          _column(`=cond(return(lb_mn) < 0, 22, 23)') as result %05.3f return(lb_mn) ///
          _column(`=cond(return(ub_mn) < 0, 36, 37)') as result %05.3f return(ub_mn)
        display in smcl _newline(1)
    }
end

program define agresticaffo
    version 9.2
    syntax anything, lb(name) ub(name) z(name) z2(name) [zsot]

    tempname tot N20 N21 c10 c11 rd zse tm tp

    tokenize `anything'

    if ("`zsot'" != "") scalar define `tot' = `z2' / 2 // T Over Two
    else scalar define `tot' = 2

    scalar define `N20' = `4' + `tot'
    scalar define `N21' = `3' + `tot'
    scalar define `c10' = `2' + `tot' / 2
    scalar define `c11' = `1' + `tot' / 2

    scalar define `rd' = `c11' / `N21' - `c10' / `N20'
    scalar define `zse' = `z' * sqrt( `c11' * (`N21' - `c11') / `N21' / `N21' / `N21' + ///
      `c10' * (`N20' - `c10') / `N20' / `N20' / `N20' )

    scalar define `tm' = `rd' - `zse'
    scalar define `tp' = `rd' + `zse'

    scalar define `lb' = max( -1, min(`tm', `tp') )
    scalar define `ub' = min(  1, max(`tm', `tp') )
end

program define newcombe
    version 9.2
    syntax anything, lb(name) ub(name) z(name) z2(name)

    tempname a b c lb1 lb2 ub1 ub2 cl1 cl2
    tokenize `anything'

* Wilson intervals of the individual proportions (adapted from -ciwi- by N. J. Cox)
    forvalues i = 1/2 {
        local n`i' = ``=`i' + 2''
        local p = `i' + 4
        scalar define `a' = 2 * ``i'' + `z2'
        scalar define `b' = `z' * sqrt( `z2' + 4 * `n`i'' * ``p'' * (1 - ``p'') )
        scalar define `c' = 2 * (`n`i'' + `z2')
        scalar define `lb`i'' = (`a' - `b') / `c'
        scalar define `ub`i'' = (`a' + `b') / `c'
    }
*
    scalar define `cl1' = `7' - `z' * sqrt( `lb1' * (1 - `lb1') / `n1' + `ub2' * (1 - `ub2') / `n2' )
    scalar define `cl2' = `7' + `z' * sqrt( `ub1' * (1 - `ub1') / `n1' + `lb2' * (1 - `lb2') / `n2' )

    if missing(`cl1') {
        scalar define `cl1' = sign(`7')
    }

    if missing(`cl2') {
        scalar define `cl2' = sign(`7')
    }

    scalar define `lb' = min(`cl1', `cl2')
    scalar define `ub' = max(`cl1', `cl2')
end

program define wallenstein
    version 9.2
    syntax anything, lb(name) ub(name) z(name) z2(name) [recursion(integer 0) cc]

    tempname epsilon delta p_bar d1 d2 p1dl p1du p2du minus_seven swap
    tokenize `anything'

    local N = `3' + `4'
    scalar define `p_bar' = (`1' + `2') / `N'
    scalar define `d1' = .
    scalar define `d2' = .
    if ("`cc'" == "") {
        wallenquad , d1(`d1') d2(`d2') three(`3') four(`4') delta(`7') z2(`z2') p_bar(`p_bar') en(`N')
        scalar define `lb' = min(`d1', `d2')
        scalar define `ub' = max(`d1', `d2')
        scalar define `epsilon' = 0
    }
    else {
        scalar define `epsilon' = 1 / 2 / `3' + 1 / 2 / `4'
        scalar define `delta' = sign(`7') * min(1, abs(`7' + `epsilon'))
        wallenquad , d1(`d1') d2(`d2') three(`3') four(`4') delta(`delta') z2(`z2') p_bar(`p_bar') en(`N')
        scalar define `ub' = max(`d1', `d2')
        scalar define `delta' = sign(`7') * min(1, abs(`7' - `epsilon'))
        wallenquad , d1(`d1') d2(`d2') three(`3') four(`4') delta(`delta') z2(`z2') p_bar(`p_bar') en(`N')
        scalar define `lb' = min(`d1', `d2')
    }
*
    if (`5' >= `6') {
        scalar define `p1du' = `p_bar' + `ub' * `4' / `N'
        scalar define `p2du' = `p_bar' - `ub' * `3' / `N'
        scalar define `p1dl' = `p_bar' + `lb' * `4' / `N'
        if (`p2du' < 0) {
            scalar define `ub' = `7' + `epsilon' + `z2' / 2 / `3' + (`z' / sqrt(`3')) * ///
                sqrt((`7' + `epsilon') * (1 - (`7' + `epsilon')) + `z2' / 4 / `3')
            scalar define `ub' = `ub' / (1 + `z2' / `3')
        }
        if (`p1du' > 1) {
            scalar define `ub' = `7' + `epsilon' + `z2' / 2 / `4' + (`z' / sqrt(`4')) * ///
                sqrt((`7' + `epsilon') * (1 - (`7' + `epsilon')) + `z2' / 4 / `4')
            scalar define `ub' = `ub' / (1 + `z2' / `4')
        }
        if (`p1dl' < 0) {
            scalar define `lb' = `7' - `epsilon' + `z2' / 2 / `3' + (`z' / sqrt(`3')) * ///
                sqrt((`7' - `epsilon') * (1 - (`7' - `epsilon')) + `z2' / 4 / `3')
            scalar define `lb' = `lb' / (1 + `z2' / `3')
            scalar define `lb' = -`lb'
        }
        if (`recursion' == 1) {
            scalar define `swap' = `ub'
            scalar define `ub' = -`lb'
            scalar define `lb' = -`swap'
        }
    }
    else { // "If p_hat2 > p_hat1, the above logic is somewhat reversed, and it may be easier simply to reverse indices."
        scalar define `minus_seven' = -`7'
        if (`recursion' == 0) wallenstein `2' `1' `4' `3' `6' `5' `minus_seven', ///
          lb(`lb') ub(`ub') z(`z') z2(`z2') recursion(1) `cc'
    }
end

program define wallenquad
    version 9.2
    syntax , d1(name) d2(name) three(name) four(name) delta(name) z2(name) p_bar(name) en(integer)

    tempname a b c d

    scalar define `a' = 1 + `z2' / `en' * ( 1 + (`three' - `four')^2 / `three' / `four' )
    scalar define `b' = -2 * `delta' + `z2' * (1 - 2 * `p_bar') * (`three' - `four') / `three' / `four'
    scalar define `c' = `delta' * `delta' - `z2' * `en' * `p_bar' * (1 - `p_bar') / `three' / `four'
    scalar define `d' = -( `b' + ( 2 * (`b' >= 0) - 1 )* sqrt(`b' * `b' - 4 * `a' * `c') ) / 2
    scalar define `d1' = `d' / `a'
    scalar define `d2' = `c' / `d'
end

program define miemar
    version 9.2
    syntax anything

    tempname L3 L2 L1 L0 L23 q p a R0 R1 V

    tokenize `anything'

    local c = `1' + `2'
    local S = `3' + `4'

    scalar define `L3' = `S'
    scalar define `L2' = (`4' + 2 * `3') * (-`7') - `S' - `c'
    scalar define `L1' = (`3' * (-`7') - `S' - 2 * `1') * (-`7') + `c'
    scalar define `L0' = `1' * (-`7') * (1 - (-`7'))

    scalar define `L23' = `L2' / 3 / `L3'

    scalar define `q' = `L23'^3 - `L1' * `L2' / 6 / `L3'^2 + `L0' / 2 / `L3'
    scalar define `p' = sign(`q') * sqrt(`L23'^2 - `L1' / 3 / `L3')
    scalar define `a' = ( _pi + acos(`q' / `p'^3) ) / 3
    scalar define `R0' = 2 * `p' * cos(`a') - `L23'
    scalar define `R1' = `R0' + (-`7')
    scalar define `V' = ( `R1' * (1 - `R1') / `4' + `R0' * (1 - `R0') / `3' ) * `S' / (`S' - 1)
    scalar define `6' = (`5' - `7')^2 / `V'
end
