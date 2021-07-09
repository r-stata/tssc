*! version 3.2  4Oct2005  Joseph Hilbe
* CENSORED POISSON  REGRESSION : LOG-LIKELIHOOD FUNCTION
program cpoisll
    version  9.1
    args lnf xb

    local censor "$S_cen"

    qui replace `lnf' = cond(`censor' == 1,                ///
        -exp(`xb') +  $ML_y1 * `xb' - lngamma($ML_y1 + 1),    ///
        ln(gammap($ML_y1, exp(`xb')))  )

    qui replace `lnf' =                        ///
        ln(1 - gammap($ML_y1 + 1,  exp(`xb'))) if `censor' == -1

end

