*! fieller.ado Version 1.0 JRC 2004-12-07
*! Estimates confidence interval of quotient by Fieller's method for unpaired data
program define fieller, rclass byable(recall) sortpreserve
    version 8.2
    syntax varlist(min=1 max=1 numeric) [if] [in], BY(varlist min=1 max=1) [Level(integer `c(level)') REVerse]
    marksample touse
    tempname g Q SEQ m sd t
    tempvar group
    quietly tabulate `by', generate(`group')
    capture confirm `group'1 `group'2
    if _rc == 111 {
        display as error "By variable must contain at least two levels or groups"
        exit = 111
    }
    if "`reverse'" != "" {
        rename `group'1 `group'0
        rename `group'2 `group'1
        rename `group'0 `group'2
    }
    forvalues i = 1/2 {
        quietly summarize `varlist' if `touse' & `group'`i' == 1
        local N`i' = r(N)
        scalar `m'`i' = r(mean)
        scalar `sd'`i' = r(sd)
    }
    local Level = (100 - `level') / 100 / 2
    scalar `t' = invttail(`N1' + `N2' - 2, `Level')
    scalar `g' = ( scalar(`t') * scalar(`sd'2) / sqrt(`N2') / scalar(`m'2) ) ^ 2
    if scalar(`g') >= 1 {
        display as error "Quotient not statistically significantly different from zero at the `level' level"
        display as error "Confidence interval not estimable"
        exit
    }
    return scalar quotient = scalar(`m'1) / scalar(`m'2)
    scalar `Q' = return(quotient) / (1 - scalar(`g'))
    scalar `SEQ' = scalar(`Q') * ///
      sqrt( ///
      ( 1 - scalar(`g') ) * ///
      ( scalar(`sd'1) / sqrt(`N1') )^2 / scalar(`m'1)^2 + ///
      ( scalar(`sd'2) / sqrt(`N2') )^2 / scalar(`m'2)^2 ///
      )
    return scalar lb = scalar(`Q') - scalar(`t') * scalar(`SEQ')
    return scalar ub = scalar(`Q') + scalar(`t') * scalar(`SEQ')
    display as text "Confidence Interval for a Quotient by Fieller's Method (Unpaired Data)"
    display
    display as text "Numerator Mean:   " as result scalar(`m'1)
    display as text "Denominator Mean: " as result scalar(`m'2)
    display as text "Quotient:         " as result return(quotient)
    display as text "`level'% CI:      " as result return(lb) "–" return(ub)
end
