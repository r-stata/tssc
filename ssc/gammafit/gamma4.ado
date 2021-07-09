*! version 1.3.2  NJC 3 March 1998
* version 1.3.1  27 Jan 1998
* version 1.3.0  16 Jan 1998
* version 1.2.0  15 Sept 1997
* version 1.1.0  16 April 1997
program define gamma4
    version 4.0

    local varlist "req ex max(1)"
    local if "opt"
    local in "opt"
    local options "s(int 100) Tol(real 0.0000001) Log"
    parse "`*'"

    tempvar logx j k
    tempname mean var alpha beta amom bmom meanlog a c dalpha temp numer denom

    qui {
        su `varlist' `if' `in'
        local n = _result(1)
        if _result(5) < 0 { exit 411 }
        scalar `mean' = _result(3)
        scalar `var' = _result(4)
        gen `logx' = log(`varlist')
        su `logx' `if' `in'
        scalar `meanlog' = _result(3)

        preserve
        keep `varlist'
        count
        if _result(1) < `s' { set obs `s' }
    }

    scalar `alpha' = (`mean'^2)/`var'
    scalar `beta' = `mean'/`alpha'
    di _n in g "Fitting gamma distribution to `varlist'"
    di _n in g _dup(29) " " "shape parameter  scale parameter        mean"
    di in g _dup(34) " " "     alpha             beta          mu"
    di in g "Moments estimates" _dup(17) " " in y %10.3f `alpha' _c
    di in y _dup(7) " " %10.3f `beta' _dup(2) " " %10.3f `mean'
    scalar `amom' = `alpha'
    scalar `bmom' = `beta'

    qui {
        scalar `a' = log(`mean') - `meanlog'
        scalar `alpha' = (1 + sqrt(1 + (`a'*4)/3))/(4*`a')
        scalar `c' = 0.5772156649
        scalar `dalpha' = 1
        gen `j' = _n if _n <= 100
        gen `k' = .
        local i = 0

        while abs(`dalpha') > `tol' {
            scalar `temp' = `alpha'
            scalar `numer' = log((`temp'* (`s' + 0.5))/(`s' - 0.5 + `temp')) /*
                */ + `c' - `a'
            replace `k' = 1/(`j'*(`j' + `temp' - 1))
            su `k'
            scalar `denom' = _result(1) * _result(3)
            scalar `alpha' = 1 + `numer'/`denom'
            if "`log'" == "log" {
                if `i' == 0 { noi di }
                local i = `i' + 1
                noi di in g "Iteration `i'" _col(35) in y %10.3f `alpha'
            }
            scalar `dalpha' = `alpha' - `temp'
        }
        scalar `beta' = `mean'/`alpha'
    }
    if "`log'" == "log" { di }

    di in g "Maximum likelihood estimates      " in y %10.3f `alpha' _c
    di in y _dup(7) " " %10.3f `beta' "  "  %10.3f `mean'

    global S_1 = `n'
    global S_alpha = `alpha'
    global S_beta = `beta'
    global S_amom = `amom'
    global S_bmom = `bmom'

end
/*

The algorithm here for ML estimation of alpha was proposed by P.W.
Mielke. See Mielke and Johnson (1974), Mielke (1975), Mielke
(1976). The first approximation is that suggested by Thom (1958).

Mielke, P.W. 1975. Convenient beta distribution likelihood
techniques for describing and comparing meteorological data.
Journal of Applied Meteorology 14, 985-90.

Mielke, P.W. 1976. Simple iterative procedures for two-parameter
gamma distribution maximum likelihood estimates. Journal of
Applied Meteorology 15, 181-3.

Mielke, P.W. & Johnson, E.S. 1974. Some generalized beta
distributions of the second kind having desirable application
features in hydrology and meteorology. Water Resources Research
10, 223-6. See also 1976. Correction. Water Resources Research 12,
827.

Thom, H.C.S. 1958. A note on the gamma distribution. Monthly
Weather Review 86, 117-22.

*/
