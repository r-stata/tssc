*! version 1.0   4Aug2009 Joseph Hilbe
* CENSORED POISSON - ECONOMETRIC PARAMETERIZATION: LOG-LIKELIHOOD FUNCTION
program cpoisxll
    version  11
    args lnf xb

    local censor "$S_cen"
    local cleft   $Sclt
    local cright  $Scrg

    qui replace `lnf' = cond(`censor' == 1,                ///
        -exp(`xb') + $ML_y1 * `xb' - lngamma($ML_y1 + 1),    ///
        ln(poisson(exp(`xb'), `cleft')) )
    qui replace `lnf' = ln(poissontail(exp(`xb'), `cright')) if `censor' == -1        
end
