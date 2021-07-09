*! Version 1.0.0 
* GENERALZED POISSON REGRESSION :  Joseph Hilbe  :  8Sep2005
program gnpoisson, eclass properties(svyb svyj  svyr)
    version  9.1
    syntax [varlist] [if] [in] [fweight pweight aweight  iweight] [, ///
        Level(cilevel)                ///
        OFFset(passthru)  EXposure(passthru)            ///
        CLuster(passthru) IRr Robust noLOG FROM(string asis) *  ]   
    gettoken  lhs rhs : varlist

    mlopts mlopts, `options'

    if ("`weight'" != "")   local weight "[`weight'   `exp']"
    if (`"`from'"' != `""') local initopt `"init(`from')"'

    ml model lf jhpoi_ll (xb: `lhs' =  `rhs', `offset' `exposure')    ///
                /lnphi                    ///
        `if' `in' `weight',                             ///
        `mlopts' `robust' `cluster'                ///
        title("Generalized Poisson Regression")            ///
        maximize `log' `initopt'                ///
        diparm(lnphi, exp label(phi))

    ereturn scalar k_aux = 1

    ml display, level(`level') `irr'

qui {
* AIC
    tempvar aic
    local nobs e(N)
    local npred e(df_m)
    local df = e(N) - e(df_m) -1
    local llike  e(ll)
    gen `aic' = ((-2*`llike') +  2*(`npred'+1))/`nobs'

}

* DISPLAY
di in gr _col(1) "AIC Statistic   =  " in ye %11.3f `aic' 

end





