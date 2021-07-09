*! version 1.0  30Nov2005  Joseph Hilbe
* CENSORED NEGATIVE BINOMIAL REGRESSION : LOG-LIKELIHOOD FUNCTION : HILBE SURVIVAL PARAMETERIZATION
program cenegbinll
    version  9.1
    args lnf xb alpha
    tempvar a mu

    local censor "$S_cen"
        
    qui gen  double `a' = exp(`alpha')
    qui gen double `mu' = exp(`xb') *  `a'

    qui replace `lnf' = cond(`censor' == 1,  $ML_y1 *  ln(`mu'/(1+`mu')) -  ///
       ln(1+`mu')/`a' +  lngamma($ML_y1 + 1/`a') -  ///
       lngamma($ML_y1 + 1) -  lngamma(1/`a'), ln(gammap($ML_y1, exp(`xb'))), ///
       ln(ibeta($ML_y1, $S_obs - $ML_y1 +1, exp(`xb')))  )
    qui replace `lnf' = ln(ibeta($ML_y1+1, $S_obs - $ML_y1, exp(`xb'))) if `censor' == -1

end


