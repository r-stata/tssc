*! Version 1.0.0 
* GEOMETRIC-CLOGLOG HURDLE REGRESSION :  Joseph Hilbe  :  25Sep2005
program hgclg, eclass properties(svyb svyj  svyr)
    version    9.1
    syntax [varlist] [if] [in] [fweight pweight aweight  iweight] [, ///
        CENsor(string)  Level(cilevel)                ///
        OFFset(passthru)  EXposure(passthru)            ///
        CLuster(passthru) IRr Robust noLOG FROM(string asis) *  ]   
    gettoken  lhs rhs : varlist

    mlopts mlopts, `options'

    if ("`weight'" != "")   local weight "[`weight'   `exp']"
    if (`"`from'"' != `""') local initopt `"init(`from')"'

    ml model lf jhgeo_cln_ll (cloglog: `lhs' =  `rhs', `offset' `exposure')   ///
         (geometric: `lhs' = `rhs', `offset' `exposure')                   ///
        `if' `in' `weight',                     ///
        `mlopts' `robust' `cluster'             ///
        title("Geometric-Cloglog Hurdle Regression")           ///
        maximize `log' `initopt'                ///
        

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

di in gr _col(1) "AIC Statistic = " in ye %9.3f `aic' 
end







