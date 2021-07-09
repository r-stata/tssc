*! NJC 1.1.0 28 November 1998
* 1.0.0  16 April 1997
program define beta4 
    version 4.0
    local varlist "req ex max(1)"
    local if "opt"
    local in "opt"
    local options "s(int 25) Tol(real 0.0000001) SEC"
    parse "`*'"
    tempvar fy j k
    tempname mu1 mu2 G H a amom b bmom gmom cha chb olda oldb /*
     */ anum bnum p gamma

    qui {
        preserve
        keep if `varlist' != .
        if "`if'`in'" != "" { keep `if' `in' }
        su `varlist', meanonly
        if _result(5) < 0 | _result(6) > 1 {
            di in r "values must be in 0-1 range"
            exit 498
        }
        scalar `mu1' = _result(3)
        gen `fy' = `varlist'^2
        su `fy', meanonly
        scalar `mu2' = _result(3)
        replace `fy' = log(`varlist')
        su `fy', meanonly
        scalar `G' = _result(3)
        replace `fy' = log(1 - `varlist')
        su `fy', meanonly
        scalar `H' = _result(3)
        scalar `a' = `mu1' * (`mu1' - `mu2') / (`mu2' - `mu1'^2)
        scalar `gmom' = (`mu1' - `mu2') / (`mu2' - `mu1'^2)
        scalar `amom' = `a'
        scalar `b' = (1 - `mu1') * (`mu1' - `mu2') / (`mu2' - `mu1'^2)
        scalar `bmom' = `b'

        count
        local n = _result(1)
        if `n' < `s' { set obs `s' }
        gen `j' = _n if _n <= `s'
        gen `k' = .

        scalar `cha' = 1
        scalar `chb' = 1

        while `cha' > `tol' | `chb' > `tol' {
            scalar `olda' = `a'
            scalar `oldb' = `b'
            scalar `anum' = `G' + /*
             */ log((`s' + `a' + `b' - 0.5)/(`s' + `a' - 0.5))
            replace `k' = `b' * (`j' + `a') / /*
             */ (`j' * (`j' + `a' - 1) * (`j' + `a' + `b' - 1))
            su `k', meanonly
            scalar `anum' = `anum' + _result(1) * _result(3)
            replace `k' = 1 / /*
             */ (`j' * (`j' + `a' - 1) * (`j' + `a' + `b' - 1))
            su `k', meanonly
            scalar `a' = `anum' / (`b' * _result(1) * _result(3))
            scalar `bnum' = `H' + log((`s' + `a' + `b' - 0.5) / /*
             */  (`s' +`b' - 0.5))
            replace `k' = `a' * (`j' + `b') / /*
             */ (`j' * (`j' + `b' - 1) * (`j' + `a' + `b' - 1))
            su `k', meanonly
            scalar `bnum' = `bnum' + _result(1) * _result(3)
            replace `k' = 1 / /*
             */  (`j' * (`j' + `b' - 1) * (`j' + `a' + `b' - 1))
            su `k', meanonly
            scalar `b' = `bnum' / (`a' * _result(1) * _result(3))

            if `a' == . | `b' == . {
                    di in r "convergence not achieved"
                    exit 430
            }

            scalar `cha' = abs(`a' - `olda')
            scalar `chb' = abs(`b' - `oldb')
        }

        scalar `p' = `a' / (`a' + `b')
        scalar `gamma' = `a' + `b'
    }

    di _n in g "Fitting beta distribution to `varlist'"
    di _n in g _dup(41) " "    "shape parameters"
    di in g _dup(39) " " "alpha           beta"
    di in g "Moments estimates" _dup(17) " " in y %10.4f `amom' _c
    di in y _dup(5) " " %10.4f `bmom'
    di in g "Maximum likelihood estimates      " in y %10.4f `a' _c
    di in y _dup(5) " " %10.4f `b' "  "

    if "`sec'" == "sec" {
        tempname sea seb rab
        scalar `sea' = sqrt(`a' * (2 * `a' - 1) / `n')
        scalar `seb' = sqrt(`b' * (2 * `b' - 1) / `n')
        scalar `rab' = sqrt((1 - 2 / `a') * (1 - 2 / `b'))
        di _n in g "If alpha and beta large:" _n "Standard errors" _c
        di in y _dup(19) " " %10.4f  `sea' _dup(5) " " %10.4f `seb'
        di in g "Correlation of alpha and beta" _c
        di in y _dup(12) " " %10.3f `rab'
        global S_10 = `sea'
        global S_11 = `seb'
        global S_12 = `rab'
    }

    global S_1 = `n'
    global S_2 = `a'
    global S_3 = `b'
    global S_4 = `amom'
    global S_5 = `bmom'
    global S_6 = `p'
    global S_7 = `gamma'
    global S_8 = `mu1'
    global S_9 = `gmom'

end
/*

The algorithm here for ML estimation was proposed by P.W. Mielke. See
Mielke and Johnson (1974), Mielke (1975), Mielke (1976).

Mielke, P.W. 1975. Convenient beta distribution likelihood techniques
for describing and comparing meteorological data. Journal of Applied
Meteorology 14, 985-90.

Mielke, P.W. 1976. Simple iterative procedures for two-parameter gamma
distribution maximum likelihood estimates. Journal of Applied
Meteorology 15, 181-3.

Mielke, P.W. & Johnson, E.S. 1974. Some generalized beta distributions
of the second kind having desirable application features in hydrology
and meteorology. Water Resources Research 10, 223-6. See also 1976.
Correction. Water Resources Research 12, 827.

*/
