*! fielleri.ado Version 1.0 JRC 2004-12-07
*! Estimates confidence interval of quotient by Fieller's method for unpaired data
program define fielleri, rclass
    version 8.2
// The following is plagiarized from StataCorp's -cci-
    gettoken m1 0 : 0, parse(" ,")
    gettoken sd1 0 : 0, parse(" ,")
    gettoken N1 0 : 0, parse(" ,")
    gettoken m2 0 : 0, parse(" ,")
    gettoken sd2 0 : 0, parse(" ,")
    gettoken N2 0 : 0, parse(" ,")
    confirm integer number `N1'
    confirm integer number `N2'
    confirm number `m1'
    confirm number `m2'
    confirm number `sd1'
    confirm number `sd2'
    syntax , [Level(integer `c(level)')]
// End plagiarism
    tempname g Q SEQ m sd t
    local Level = (100 - `level') / 100 / 2
    scalar `t' = invttail(`N1' + `N2' - 2, `Level')
    scalar `g' = ( scalar(`t') * `sd2' / sqrt(`N2') / `m2' ) ^ 2
    if scalar(`g') >= 1 {
        display as error "Quotient not statistically significantly different from zero at the `level' level"
        display as error "Confidence interval not estimable"
        exit
    }
    return scalar quotient = `m1' / `m2'
    scalar `Q' = return(quotient) / (1 - scalar(`g'))
    scalar `SEQ' = scalar(`Q') * ///
      sqrt( ///
      ( 1 - scalar(`g') ) * ///
      ( `sd1' / sqrt(`N1') )^2 / (`m1')^2 + ///
      ( `sd2' / sqrt(`N2') )^2 / (`m2')^2 ///
      )
    return scalar lb = scalar(`Q') - scalar(`t') * scalar(`SEQ')
    return scalar ub = scalar(`Q') + scalar(`t') * scalar(`SEQ')
    display
    display as text "Confidence Interval for a Quotient by Fieller's Method (Unpaired Data)"
    display
    display as text "Numerator Mean:   " as result `m1'
    display as text "Denominator Mean: " as result `m2'
    display as text "Quotient:         " as result return(quotient)
    display as text "`level'% CI:      " as result return(lb) "–" return(ub)
end
