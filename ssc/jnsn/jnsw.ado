*! jnsw.ado Version 1.1 2007-02-26 JRC
program define jnsw, rclass byable(recall)
    version 9.2
    syntax varname(numeric) [if] [in], [Generate(name) DIstribution(string) LNTolerance(real 0.01) ///
      TBOneonly Percentile(real 100) ///
      GAmma(string) Delta(string) Lambda(string) Xi(string)]

    local distribution = cond("`distribution'" == "", "auto", lower(trim("`distribution'")))
    if !inlist("`distribution'", "auto", "l", "sl", "u" , "su", "b", "sb") {
        display in smcl as error "Johnson distribution option is misspecified."
        exit = 99
    }
    if (length("`distribution'") == 1) local distribution = "s" + "`distribution'"
    if !inrange(`lntolerance', 0.0001, 0.5) {
        display in smcl as error "Log-normal line tolerance must be between 0.0001 and 0.5 inclusive"
        exit = 99
    }
    if !inrange(`percentile', 1, 100) {
        display in smcl as error "Percentile must lie between 1 and 100 inclusive."
        exit = 99
    }
    foreach parameter in gamma delta lambda xi {
        if ("``parameter''" != "") {
            capture assert missing(real(``parameter''))
            if !_rc {
                local parameter = proper("`parameter'")
                display in smcl as error "`parameter' must be numeric."
                exit = 99
            }
            else local `parameter' = real("``parameter''")
        }
        else local `parameter' = .
    }
    if (`delta' <= 0) {
        display in smcl as error "Delta must be greater than zero."
        exit = 99
    }
    if  (lower("`distribution'") != "sl") {
        if (`lambda' <= 0) {
            display in smcl as error "Lambda must be greater than zero if distribution is not SL."
            exit = 99
        }
    }
    else if !inlist(`lambda', -1, 1, .) {
        display in smcl as error "Lambda must be either -1 or +1 if distribution is SL."
        exit = 99
    }

    tempvar tmpvar0 tmpvar1 tmpvar2
    tempname xp xk x0 xm xn t a b tb tb1 tb2 tu w MEAN SD

    marksample touse

    preserve
    quietly {
        keep if `touse'
        keep `varlist'
        drop if missing(`varlist')
    }
    if (_N < 5) {
        display in smcl as error "Too few data."
        restore
        exit = 99
    }
    sort `varlist'
    if (`percentile' != 100) {
        quietly {
            generate double `tmpvar0' = (_n - 0.5) / _N
            replace `tmpvar0' = abs(`percentile' / 100 - `tmpvar0')
            summarize `tmpvar0', meanonly
            replace `tmpvar0' = sum(`tmpvar0' == r(min))
            count if `tmpvar0'
            drop if (_n > (_N - r(N) + 1))
            drop `tmpvar0'
        }
    }
*
    generate double `tmpvar0' = invnormal((_n - 0.5) / _N)
    generate double `tmpvar1' = abs(`tmpvar0' - `tmpvar0'[_N] / 2)
    summarize `tmpvar1', meanonly
    generate byte `tmpvar2' = sum(`tmpvar1' == r(min))
    summarize `varlist' if `tmpvar2', meanonly
    scalar `xm' = r(min)
    local m = _N - r(N) + 1
    scalar `xk' = `varlist'[`=1 + _N - `m'']
    quietly centile `varlist', centile(50)
    scalar `x0' = r(c_1)
    scalar `xn' = `varlist'[_N]
    scalar `xp' = `varlist'[1]
    quietly summarize `varlist'
    scalar define `MEAN' = r(mean)
    scalar define `SD' = r(sd)
*
    scalar define `tu' = (`xn' - `xp') / (`xm' - `xk')
    if ("`tboneonly'" == "") {
        scalar define `tb1' = (`xm' - `x0') * (`xn' - `xp') / (`xn' - `xm') / (`x0' - `xp')
        scalar define `tb2' = (`xk' - `x0') * (`xp' - `xn') / (`xp' - `xk') / (`x0' - `xn')
        scalar define `tb' = (`tb1' + `tb2') / 2
        return scalar LNLine = `tb' / `tu'
    }
    else {
        scalar define `tb' = (`xm' - `x0') * (`xn' - `xp') / (`xn' - `xm') / (`x0' - `xp')
        return scalar LNLine = (`xm' - `x0') * (`xm' - `xk') / (`xn' - `xm') / (`x0' - `xp')
    }
*
    if ("`distribution'" == "auto") {
        if (return(LNLine) > (1 + `lntolerance')) local distribution sb
        else if (return(LNLine) < (1 - `lntolerance')) local distribution su
        else local distribution sl
    }
*
    scalar define `t' = (`xn' - `x0') / (`x0' - `xp')
*
    if ("`distribution'" == "su") {
        scalar define `b' = `tu' / 2 + sqrt((`tu' / 2)^2 - 1)
        scalar define `a' = sqrt((1 - `t' * `b' * `b') / (`t' - `b' * `b'))
        return scalar delta = cond(missing(`delta'),`tmpvar0'[_N] / 2 / ln(`b'), `delta')
        return scalar gamma = cond(missing(`gamma'), -return(delta) * ln(`a'), `gamma')
        if (!missing(return(gamma)) & !missing(return(delta))) {
            quietly {
                replace `tmpvar1' = (`tmpvar0' - return(gamma)) / return(delta)
                replace `tmpvar1' = (exp(`tmpvar1') - exp(-`tmpvar1')) / 2
            }
            if (!missing(`lambda') & missing(`xi')) {
                constraint define 1 `varlist' = `lambda'
                quietly cnsreg `tmpvar1' `varlist', constraints(1)
                return scalar lambda = `lambda'
                return scalar xi = -_b[_cons] * return(lambda)
            }
            else if (!missing(`xi') & missing(`lambda')) {
                quietly {
                    replace `tmpvar1' = `tmpvar1' - `xi'
                    regress `tmpvar1' `varlist', noconstant
                }
                return scalar xi = `xi'
                return scalar lambda = _b[`varlist']
            }
            else {
                quietly regress `tmpvar1' `varlist'
                return scalar lambda = cond(missing(`lambda'), 1 / _b[`varlist'], `lambda')
                return scalar xi = cond(missing(`xi'), ///
                  cond(missing(`lambda'), -_b[_cons] / _b[`varlist'], -_b[_cons] * return(lambda)), ///
                  `xi')
            }
        }
        else {
            return scalar lambda = .
            return scalar xi = .
        }
    }
*
    else if ("`distribution'" == "sb") {
        scalar define `b' = `tb' / 2 + sqrt((`tb' / 2)^2 - 1)
        scalar define `a' = (`t' - `b' * `b') / (1 - `t' * `b' * `b')
        return scalar delta = cond(missing(`delta'), `tmpvar0'[_N] / 2 / ln(`b'), `delta')
        return scalar gamma = cond(missing(`gamma'), -return(delta) * ln(`a'), `gamma')
        if (!missing(return(gamma)) & !missing(return(delta))) {
            quietly {
                replace `tmpvar1' = exp((`tmpvar0' - return(gamma)) / return(delta))
                replace `tmpvar1' = `tmpvar1' / (1 + `tmpvar1')
            }
            if (!missing(`lambda') & missing(`xi')) {
                constraint define 1 `varlist' = `lambda'
                quietly cnsreg `tmpvar1' `varlist', constraints(1)
                return scalar lambda = `lambda'
                return scalar xi = -_b[_cons] * return(lambda)
            }
            else if (!missing(`xi') & missing(`lambda')) {
                quietly {
                    replace `tmpvar1' = `tmpvar1' - `xi'
                    regress `tmpvar1' `varlist', noconstant
                }
                return scalar xi = `xi'
                return scalar lambda = _b[`varlist']
            }
            else {
                quietly regress `tmpvar1' `varlist'
                return scalar lambda = cond(missing(`lambda'), 1 / _b[`varlist'], `lambda')
                return scalar xi = cond(missing(`xi'), ///
                  cond(missing(`lambda'), -_b[_cons] / _b[`varlist'], -_b[_cons] * return(lambda)), ///
                  `xi')
            }
        }
        else {
            return scalar lambda = cond(missing(`lambda'), ., `lambda')
            return scalar xi = cond(missing(`xi'), ., `xi')
        }
    }
*
    else {
        return scalar delta = cond(missing(`delta'), `tmpvar0'[_N] / ln(`t'), `delta')
        return scalar lambda = cond(missing(`lambda'), sign(return(delta)), `lambda')
        return scalar delta = abs(return(delta))
        scalar define `w' = exp(1 / return(delta) / return(delta))
        return scalar gamma = cond(missing(`gamma'), return(delta) / 2 * ln(`w' * (`w' - 1) / `SD' / `SD'), `gamma')
        if (!missing(return(gamma)) & !missing(return(delta))) {
            return scalar xi = cond(missing(`xi'), `MEAN' - return(lambda) * ///
              exp(1 / 2 / return(delta) - return(gamma)) / return(delta), ///
              `xi')
        }
        else {
            return scalar lambda = cond(missing(`lambda'), ., `lambda')
            return scalar xi = cond(missing(`xi'), ., `xi')
        }
    }
    return  local johnson_type = upper("`distribution'")
    restore
*
    display in smcl as text "Johnson system of transformations fitted by the Wheeler method"
    display in smcl _newline(1)
    display in smcl as text "Johnson distribution type: " as result "`return(johnson_type)'"
    display in smcl as text " gamma = " as result %05.3f return(gamma)
    display in smcl as text " delta = " as result %05.3f return(delta)
    display in smcl as text "    xi = " as result %05.3f return(xi)
    display in smcl as text "lambda = " as result %05.3f return(lambda)
    display in smcl _newline(1)
*
    if "`generate'" ~= "" {
        local formula (`varlist' - return(xi)) / return(lambda)
        if inlist("`r(johnson_type)'", "SL", "SU", "SB") {
            if "`return(johnson_type)'" == "SL" {
                local formula return(gamma) + return(delta) * ln(`formula')
            }
            else if "`return(johnson_type)'" == "SU" {
                local formula return(gamma) + return(delta) * ln(`formula' + sqrt((`formula') * (`formula') + 1))
            }
            else {
                local formula return(gamma) + return(delta) * ln((`formula') / (1 - `formula'))
            }
        }
        if _byindex() == 1 {
            quietly generate double `generate' = `formula' if `touse'
        }
        else {
            quietly replace `generate' = `formula' if `touse'
        }
    }
end
