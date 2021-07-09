*! jnsni.ado Version 1.2 2007-01-17 JRC
program define jnsni
    version 9.2
    syntax , mean(real) sd(real) [SKEWness(real 0) kurtosis(real 3) called(integer 0) ///
      TOLerance(real 0.01) SBITERate(integer 50) ///
      MOITERate(integer 50) MOTOLerance(real 0.00001) MIITERate(integer 50) MITOLerance(real 0.00000001)]

    tempname fault skewness_squared r_w r_x r_kurtosis

    if (`sd' < 0) {
        jnsn_NULL , why("sd")
        display in smcl as error "`r(fault)'"
        exit = 99
    }
    scalar define `skewness_squared' = `skewness' * `skewness'
    if (`kurtosis' < (`skewness_squared' + 1)) {
        jnsn_NULL , why("ps")
        display in smcl as error "`r(fault)'"
        exit = 99
    }

    scalar define `fault' = "Program terminated normally"

// All values are the same?
    if (`sd' == 0) {
        jnsn_STabbreviated , mean(`mean') // If so, declare Johnson ST distribution (binomial)
        jnsn_reporter, called(`called')
        scalar drop `fault' `skewness_squared'
        exit
    }

// Johnson ST distribution (binomial)?
    if (`kurtosis' <= (`skewness_squared' + `tolerance' + 1)) {
        jnsn_ST , mean(`mean') sd(`sd') skewness(`skewness') fault(`fault')
        jnsn_reporter, called(`called')
        scalar drop `fault' `skewness_squared'
        exit 
    }

// Johnson SN distribution (normal)?
    if ( (abs(`skewness') <= `tolerance') & (abs(`kurtosis' - 3) <= `tolerance') ) {
        jnsn_SN , mean(`mean') sd(`sd') fault(`fault')
        jnsn_reporter, called(`called')
        scalar drop `fault' `skewness_squared'
        exit
    }

// Testing for position relative to lognormal line
    jnsn_SLline , skewness(`skewness') kurtosis(`kurtosis') fault(`fault')
    scalar define `r_x' = r(x)  // In order to maintain precision
    scalar define `r_w' = r(w)
    scalar define `r_kurtosis' = r(kurtosis)

// Johnson SL distribution family (lognormal)?
    if (abs(`r_x') <= `tolerance') {
        jnsn_SL , mean(`mean') sd(`sd') skewness(`skewness') w(`r_w') fault(`fault')
        jnsn_reporter, called(`called')
        scalar drop `fault' `skewness_squared' `r_x' `r_w' `r_kurtosis'
        exit
    }

// Johnson SU distribution family (unbounded)?
    if (`r_x' <= 0) {
        jnsn_SU , mean(`mean') sd(`sd') skewness(`skewness') kurtosis(`r_kurtosis') tolerance(`tolerance')
        jnsn_reporter, called(`called')
        scalar drop `fault' `skewness_squared' `r_x' `r_w' `r_kurtosis'
        exit
    }

// Else it must be the Johnson SB distribution family (bounded)
    jnsn_SB ,  mean(`mean') sd(`sd') skewness(`skewness') kurtosis(`kurtosis') ///
      tolerance(`tolerance') iterate(`sbiterate') fault(`fault') ///
      moiterate(`moiterate') motolerance(`motolerance') miiterate(`miiterate') mitolerance(`mitolerance')
    if `fault' != "Program terminated normally" { // Fail.  And so must approximate the distribution as well as possible
        if (`kurtosis' > (`skewness_squared' + 2)) {
            if (abs(`skewness') < `tolerance') { // Declare it normal
                jnsn_SN , mean(`mean') sd(`sd') fault(`fault')
            }
            else { // Declare it log-normal; get w for jnsn_SL to use
                jnsn_SLline , skewness(`skewness') kurtosis(`kurtosis') fault(`fault')
                assert r(x) == 0 // Consequence of fault != "Program terminated normally" from jnsn_SB
                scalar define `r_w' = r(w)
                jnsn_SL , mean(`mean') sd(`sd') skewness(`skewness') w(`r_w') fault(`fault')
            }
        }
        else { // Declare it Johnson ST
            jnsn_ST , mean(`mean') sd(`sd') skewness(`skewness') fault(`fault')
        }
    }
    jnsn_reporter, called(`called')
    scalar drop `fault' `skewness_squared' `r_x' `r_w' `r_kurtosis'
end
*
program define jnsn_NULL, rclass
    version 9.2
    syntax , why(string)
    return local johnson_type = ""
    return scalar gamma = .
    return scalar delta = .
    return scalar xi = .
    return scalar lambda = .
    assert inlist("`why'", "sd", "ps")
    if "`why'" == "sd" {
        return local fault = "SD is negative"
    }
    else {
        return local fault = "Kurtosis is less than skewness squared + 1"
    }
end
*
program define jnsn_reporter
    version 9.2
    syntax , called(integer)
    if (!`called') {
        display in smcl as text "Johnson's system of transformations"
    }
    display in smcl _newline(1)
    display in smcl as text "Johnson distribution type: " as result "`r(johnson_type)'"
    display in smcl as text " gamma = " as result %05.3f r(gamma)
    display in smcl as text " delta = " as result %05.3f r(delta)
    display in smcl as text "    xi = " as result %05.3f r(xi)
    display in smcl as text "lambda = " as result %05.3f r(lambda)
    display in smcl _newline(1)
    if "`r(fault)'" != "Program terminated normally" {
        display in smcl as text "Note:  `r(fault)'"
        display in smcl as text "       `r(johnson_type)' is a fall-back approximation to SB type"
    }
    else {
        display in smcl as text "Note: `r(fault)'"
    }
end
*
program define jnsn_STabbreviated, rclass
    version 9.2
    syntax , mean(real)
    return local johnson_type ST
    return scalar gamma = 0
    return scalar delta = 0
    return scalar xi = `mean'
    return scalar lambda = 0
    return local fault = "Program terminated normally"
end
*
program define jnsn_ST, rclass
    version 9.2
    syntax , mean(real) sd(real) skewness(real) fault(name)
    tempname x
    return local johnson_type ST
    return scalar gamma = 0
    return scalar delta = 0.5 + 0.5 * sqrt(1 - 4 / (`skewness' * `skewness' + 4))
    if (`skewness' > 0) return scalar delta = 1 - return(delta)
    scalar define `x' = `sd' / sqrt(return(delta) * (1 - return(delta)))
    return scalar xi = `mean' - return(delta) * scalar(`x')
    return scalar lambda = return(xi) + scalar(`x')
    return local fault = scalar(`fault')
    scalar drop `x'
end
*
program define jnsn_SN, rclass
    version 9.2
    syntax , mean(real) sd(real) fault(name)
    return local johnson_type SN
    return scalar gamma = -`mean' / `sd'
    return scalar delta = 1 / `sd'
    return scalar xi = 0
    return scalar lambda = 1
    return local fault = scalar(`fault')
end
*
program define jnsn_SL, rclass
    version 9.2
    syntax , mean(real) sd(real) skewness(real) w(name) fault(name)
    tempname u x y
    return local johnson_type SL
    local s = sign(`skewness')
    scalar define `u' = `s' * `mean'
    scalar define `x' = 1 / sqrt(ln(`w'))
    scalar define `y' = 0.5 * `x' * ln(`w' * (`w' - 1) / (`sd' * `sd'))
    return scalar gamma = `y'
    return scalar delta = `x'
    return scalar xi = `s' * (`u' - exp((0.5 / `x' - `y') / `x'))
    return scalar lambda = `s'
    return local fault = scalar(`fault')
    macro drop _s
    scalar drop `u' `x' `y'
end
*
program define jnsn_SLline, rclass
    version 9.2
    syntax , skewness(real) kurtosis(real) fault(name)
    tempname x y u
    scalar define `x' = 0.5 * `skewness' * `skewness' + 1
    scalar define `y' = abs(`skewness') * sqrt(0.25 * `skewness' * `skewness' + 1)
    scalar define `u' = (`x' + `y') ^ (1 / 3)
    return scalar w = `u' + 1 / `u' - 1
    scalar define `u' = return(w) * return(w) * (3 + return(w) * (2 + return(w))) - 3
    return scalar kurtosis = cond(((`kurtosis' < 0) | (`fault' != "Program terminated normally")), `u', `kurtosis')
    return scalar x = `u' - return(kurtosis)
    scalar drop `x' `y' `u'
end
*
program define jnsn_SU, rclass
    version 9.2
    syntax , mean(real) sd(real) skewness(real) kurtosis(name) tolerance(real)

    tempname skewness_squared kurtosis_minus_3 w y z w1 wm1 v a b x

    scalar define `skewness_squared' = `skewness' * `skewness'
    scalar define `kurtosis_minus_3' = `kurtosis' - 3
    scalar define `w' = sqrt(sqrt(2 * `kurtosis' - 2.8 * `skewness_squared' - 2) - 1)

    scalar define `w1' = .  // In order to avoid exception with symmetric distribution 
    scalar define `wm1' = . // when dropping scalars at end of this subroutine
    scalar define `v' = .
    scalar define `a' = .
    scalar define `b' = .

    if (abs(`skewness') <= `tolerance') scalar define `y' = 0 // Symmetrical distribution
    else { // Johnson iteration (using y for his m)
        local flag 1
        scalar define `z' = 0
        while ((abs(`skewness_squared' - `z') > `tolerance') | (`flag' == 1)) {
            local flag 0
            scalar define `w1' = `w' + 1
            scalar define `wm1' = `w' - 1
            scalar define `z' = `w1' * `kurtosis_minus_3'
            scalar define `v' = `w' * (6 + `w' * (3 + `w'))
            scalar define `a' = 8 * (`wm1' * (3 + `w' * (7 + `v')) - `z')
            scalar define `b' = 16 * (`wm1' * (6 + `v') - `kurtosis_minus_3')
            scalar define `y' = ///
              (sqrt(`a' * `a' - 2 * `b' * (`wm1' * (3 + `w' * (9 + `w' * (10 + `v'))) - 2 * `w1' * `z')) - `a') / `b'
            scalar define `z' = `y' * `wm1' * (4 * (`w' + 2) * `y' + 3 * `w1' * `w1') ^ 2 / (2 * (2 * `y' + `w1') ^ 3)
            scalar define `v' = `w' * `w'
            scalar define `w' = ///
              sqrt(1 - 2 * (1.5 - `kurtosis' + (`skewness_squared' * (`kurtosis' - 1.5 - `v' * (1 + 0.5 * `v'))) / `z'))
            scalar define `w' = sqrt(`w' - 1)
        }
        scalar define `y' = `y' / `w'
        scalar define `y' = ln(sqrt(`y') + sqrt(`y' + 1))
        if (`skewness' > 0) scalar define `y' = -(`y')
    }
    scalar define `x' = sqrt(1 / ln(`w'))
    return local johnson_type SU
    return scalar gamma = `y' * `x'
    return scalar delta = `x'
    scalar define `y' = exp(`y')
    scalar define `z' = `y' * `y'
    scalar define `x' = `sd' / sqrt(0.5 * (`w' - 1) * (0.5 * `w' * (`z' + 1 / `z') + 1))
    return scalar xi = (0.5 * sqrt(`w') * (`y' - 1 / `y')) * `x' + `mean'
    return scalar lambda = `x'
    return local fault = "Program terminated normally"
    macro drop _flag
    scalar drop `skewness_squared' `kurtosis_minus_3' `w' `y' `z' `w1' `wm1' `v' `a' `b'
end
*
program define jnsn_SB, rclass
    version 9.2
    syntax , mean(real) sd(real) skewness(real) kurtosis(real) tolerance(real) iterate(integer) ///
      moiterate(integer) motolerance(real) miiterate(integer) mitolerance(real) fault(name)
*
    tempname hmu dd deriv tt skewness_squared e x y u w f d g s t h2 h2a h2b h3 rbet h4 bet2 xlam

    matrix define `hmu' = J(1, 6, 0)
    matrix define `dd' = J(1, 4, 0)
    matrix define `deriv' = J(1, 4, 0)

    scalar define `tt' = `tolerance' * `tolerance'
*

    local  a1 = 0.0124
    local  a2 = 0.0623
    local  a3 = 0.4043
    local  a4 = 0.408
    local  a5 = 0.479
    local  a6 = 0.485
    local  a7 = 0.5291
    local  a8 = 0.5955
    local  a9 = 0.626
    local a10 = 0.64
    local a11 = 0.7077
    local a12 = 0.7466
    local a13 = 0.8
    local a14 = 0.9281
    local a15 = 1.0614
    local a16 = 1.25
    local a17 = 1.7973
    local a18 = 1.8
    local a19 = 2.163
    local a20 = 2.5
    local a21 = 8.5245
    local a22 = 11.346

*
    scalar define `skewness_squared' = `skewness' * `skewness'
    local negative = (`skewness' < 0)
*
// Get d as the first estimate of delta
    scalar define `e' = `skewness_squared' + 1
    scalar define `x' = 0.5 * `skewness_squared' + 1
    scalar define `y' = abs(`skewness') * sqrt(0.25 * `skewness_squared' + 1)
/*    scalar define `u' = (`x' + `y') ^ (1/3)
    scalar define `w' = `u' + 1 / `u' - 1
These two lines are replaced with slightly more efficient code in the next two lines. */
    scalar define `u' = (1/3)
    scalar define `w' = (`x' + `y') ^ (`u') + (`x' - `y') ^ (`u') - 1
/* End revised */
    scalar define `f' = `w' * `w' * (3 + `w' * (2 + `w')) - 3
    scalar define `e' = (`kurtosis' - `e') / (`f' - `e')
    if (abs(`skewness') > `tolerance') {
        scalar define `d' = 1 / sqrt(ln(`w'))
        if (`d' < `a10') {
            scalar define `f' = `a16' * `d'
        }
        else {
            scalar define `f' = 2 - `a21' / (`d' * (`d' * (`d' - `a19') + `a22'))
        }
    }
    else {
        scalar define `f' = 2
    }
    scalar define `f' = `e' * `f' + 1
    if (`f' < `a18') {
        scalar define `d' = `a13' * (`f' - 1)
    }
    else {
        scalar define `d' = (`a9' * `f' - `a4') * (3 - `f') ^ (-(`a5'))
    }
// Get g as the first estimate of gamma
    scalar define `g' = 0
    if (`skewness_squared' >= `tt') {
        if (`d' <= 1) {
            scalar define `g' = (`a12' * (`d') ^ (`a17') + `a8') * (`skewness_squared') ^ (`a6')
        }
        else {
            if (`d' >= `a20') {
                scalar define `u' = `a1'
                scalar define `y' = `a7'
            }
            else {
                scalar define `u' = `a2'
                scalar define `y' = `a3'
            }
            scalar define `g' = (`skewness_squared') ^ (`u' * `d' + `y') * (`a14' + `d' * (`a15' * `d' - `a11'))
        }
    }
    local m = 0
*
// Main iteration starts here
    local flag 1
    while ((abs(`u') > `tt') | (abs(`y') > `tt') | (`flag' == 1)) {
        local flag 0
        local m = `m' + 1
        if (`m' > `iterate') {
            scalar define `fault' = "Convergence not achieved in jnsn_SB"
            exit
        }
// Get first six moments for latest g and d values
        jnsn_mom , g(`g') d(`d') a(`hmu') outeriterate(`moiterate') zz(`motolerance') ///
          inneriterate(`miiterate') vv(`mitolerance') fault(`fault')
        if `fault' != "Program terminated normally" {
            exit
        }
        scalar define `s' = `hmu'[1,1] * `hmu'[1,1]
        scalar define `h2' = `hmu'[1,2] - `s'
        if (`h2' < 0) {
            scalar define `fault' = "H2 is less than zero in jnsn_SB"
            exit
        }

        scalar define `t' = sqrt(`h2')
        scalar define `h2a' = `t' * `h2'
        scalar define `h2b' = `h2' * `h2'
        scalar define `h3' = `hmu'[1,3] - `hmu'[1,1] * (3 * `hmu'[1,2] - 2 * `s')
        scalar define `rbet' = `h3' / `h2a'
        scalar define `h4' = `hmu'[1,4] - `hmu'[1,1] * (4 * `hmu'[1,3] - `hmu'[1,1] * (6 * `hmu'[1,2] - 3 * `s'))
        scalar define `bet2' = `h4' / `h2b'
        scalar define `w' = `g' * `d'
        scalar define `u' = `d' * `d'
// Get derivatives
        forvalues j = 1/2 {
            forvalues k = 1/4 {
                scalar define `t' = `k'
                if (`j' != 1) {
                    scalar define `s' = ((`w' - `t') * (`hmu'[1,`k'] - `hmu'[1,`k'+1]) + (`t' + 1) * ///
                      (`hmu'[1,`k'+1] - `hmu'[1,`k'+2])) / `u'
                }
                else {
                    scalar define `s' = `hmu'[1,`k'+1] - `hmu'[1,`k']
                }
                matrix define `dd'[1,`k'] = `t' * `s' / `d'
            }
            scalar define `t' = 2 * `hmu'[1,1] * `dd'[1,1]
            scalar define `s' = `hmu'[1,1] * `dd'[1,2]
            scalar define `y' = `dd'[1,2] - `t'
            matrix define `deriv'[1,`j'] = (`dd'[1,3] - 3 * (`s' + `hmu'[1,2] * `dd'[1,1] - `t' * `hmu'[1,1]) - ///
              1.5 * `h3' * `y' / `h2') / `h2a'
            matrix define `deriv'[1,`j'+2] = (`dd'[1,4] - 4 * (`dd'[1,3] * `hmu'[1,1] + `dd'[1,1] * `hmu'[1,3]) + ///
              6 * (`hmu'[1,2] * `t' + `hmu'[1,1] * (`s' - `t' * `hmu'[1,1])) - 2 * `h4' * `y' / `h2') / `h2b'
        }
        scalar define `t' = 1 / (`deriv'[1,1] * `deriv'[1,4] - `deriv'[1,2] * `deriv'[1,3])
        scalar define `u' = (`deriv'[1,4] * (`rbet' - abs(`skewness')) - `deriv'[1,2] * (`bet2' - `kurtosis')) * `t'
        scalar define `y' = (`deriv'[1,1] * (`bet2' - `kurtosis') - `deriv'[1,3] * (`rbet' - abs(`skewness'))) * `t'
// Form new estimates of g and d
        scalar define `g' = `g' - `u'
        scalar define `g' = cond(((`skewness_squared' == 0) | (`g' < 0)), 0, `g')
        scalar define `d' = `d' - `y'
    }
    macro drop _flag
*
    return local johnson_type SB
    if (`negative' == 0) {
        return scalar gamma = `g'
    }
    else {
        return scalar gamma = -(`g')
        matrix define `hmu'[1,1] = 1 - `hmu'[1,1]
    }
    return scalar delta = `d'
    scalar define `xlam' = `sd' / sqrt(`h2')
    return scalar xi = `mean' - `xlam' * `hmu'[1,1]
    return scalar lambda = `xlam'
    return local fault = scalar(`fault')
    matrix drop `hmu' `dd' `deriv'
    scalar drop `tt' `skewness_squared' `e' `x' `y' `u' `w' `f' `d' `g' `s' `t' `h2a' `h2b' `h3' `rbet' `h4' `bet2' `xlam'
    macro drop _a* _negative _m
end
*
program define jnsn_mom
    version 9.2
    syntax , g(name) d(name) a(name) outeriterate(integer) zz(real) inneriterate(integer) vv(real) fault(name)
*
    tempname b c e r h t u y x v f z s p q aa ab
    matrix define `b' = J(1, 6, 0)
    matrix define `c' = J(1, 6, 0)

// Trial value of h
    if missing(exp(`g' / `d')) {
        scalar define `fault' = "Overflow in jnsn_mom"
        exit
    }
    scalar define `e' = exp(`g' / `d') + 1
    scalar define `r' = sqrt(2) / `d'
    scalar define `h' = 0.75
// Start of outer loop
    local first_flag = 1
    local outer_continue_flag = 0
    while ((`outer_continue_flag' == 1) | (`first_flag' == 1)) {
        if (`first_flag' == 1) {
            if (`d' < 3) scalar define `h' = 0.25 * `d'
            local k = 1
            local first_flag = 0
        }
        else {
            local k = `k' + 1
            if (`k' > `outeriterate') {
                scalar define `fault' = "Convergence not achieved (outer loop) in jnsn_mom"
                exit
            }
            matrix define `c' = `a'
            scalar define `h' = 0.5 * `h' // No convergence yet.  Try smaller h
        }
        scalar define `t' = `g' / `d'
        scalar define `u' = `t'
        scalar define `y' = `h' * `h'
        scalar define `x' = 2 * `y'
        matrix define `a'[1,1] = 1 / `e'
        forvalues i = 2/6 {
            matrix define `a'[1,`i'] = `a'[1,`i'-1] / `e'
        }
        scalar define `v' = `y'
        scalar define `f' = `r' * `h'
        local m = 0
        local inner_continue_flag = 0
// Start of inner loop to evaluate infinite series
        while ((`inner_continue_flag' == 1) | (`m' == 0)) {
            local m = `m' + 1
            if (`m' > `inneriterate') {
                scalar define `fault' = "Convergence not achieved (inner loop) in jnsn_mom"
                exit
            }
            matrix define `b' = `a'
            scalar define `u' = `u' - `f'
            scalar define `z' = cond(((1 + exp(`u')) > 1), 1 + exp(`u'), 1)
            scalar define `t' = `t' + `f'
            local l = ((1 + exp(-`t')) == 1)
            if (!`l') scalar define `s' = exp(`t') + 1
            scalar define `p' = exp(-`v')
            scalar define `q' = `p'
            forvalues i = 1/6 {
                scalar define `aa' = `a'[1,`i']
                scalar define `p' = `p' / `z'
                scalar define `ab' = `aa'
                scalar define `aa' = `aa' + `p'
                if (`aa' == `ab') {
                    continue, break
                }
                if (!`l') {
                    scalar define `q' = `q' / `s'
                    scalar define `ab' = `aa'
                    scalar define `aa' = `aa' + `q'
                    local l = (`aa' == `ab')
                }
                matrix define `a'[1,`i'] = `aa'
            }
            scalar define `y' = `y' + `x'
            scalar define `v' = `v' + `y'
            local inner_continue_flag = 0
            forvalues i = 1/6 {
                if (`a'[1,`i'] == 0) {
                    scalar define `fault' = "A[1,`i'] == 0 in inner loop of jnsn_mom"
                    continue, break
                }
                if (abs((`a'[1,`i'] - `b'[1,`i']) / `a'[1,`i']) > `vv') {
                    local inner_continue_flag = 1
                }
            }
            if `fault' != "Program terminated normally" {
                exit
            }
        }
// End of inner loop
        scalar define `v' = 1 / sqrt(_pi) * `h'
        matrix define `a' = `a' * `v'
        local outer_continue_flag = 0
        forvalues i = 1/6 {
            if (`a'[1,`i'] == 0) {
                scalar define `fault' = "A[1,`i'] == 0 in outer loop of jnsn_mom"
                continue, break
            }
            if (abs((`a'[1,`i'] - `c'[1,`i']) / `a'[1,`i']) > `zz') {
                local outer_continue_flag = 1
            }
        }
        if `fault' != "Program terminated normally" {
            exit
        }

    }
// End of outer loop
    matrix drop `b' `c'
    scalar drop `e' `r' `h' `t' `u' `y' `x' `v' `f' `z' `s' `p' `q' `aa' `ab'
    macro drop _first_flag _outer_continue_flag _inner_continue_flag _k _m _l 
end
