*! version 1.0   17Oct2009 Joseph Hilbe
* TRUNCATED POISSON - LOG-LIKELIHOOD 
program tpoisll
    version  11
    args lnf xb

    local trunc "$S_tru"
    local tleft   $Stlt
    local tright  $Strg

    qui replace `lnf' = cond(`trunc' == 1,                ///
        -exp(`xb') + $ML_y1 * `xb' - lngamma($ML_y1 + 1),    ///
    ln(1-gammap(exp(`xb'), `tleft')) )
    qui replace `lnf' = ln(gammap(exp(`xb')+1, `tright')) if `trunc' == -1        
end
