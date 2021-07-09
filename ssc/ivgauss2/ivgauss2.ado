*! Version 2.0.0    
* INVERSE GAUSSIAN REGRESSION - 2 PARAMETER WITH LOG PARAMETERIZATION:  Joseph Hilbe  :  8Oct2005
program ivgauss2, eclass properties(svyb svyj  svyr)
    version  9.1
    syntax [varlist] [if] [in] [fweight pweight aweight  iweight] [, ///
        CENsor(string)  Level(cilevel)                ///
        OFFset(passthru)  EXposure(passthru)            ///
        CLuster(passthru) EForm Robust noLOG FROM(string asis) *  ]   
    gettoken  lhs rhs : varlist

    mlopts mlopts, `options'

    if ("`weight'" != "")   local weight "[`weight'   `exp']"
    if (`"`from'"' != `""') local initopt `"init(`from')"'

    ml model lf ivgln_ll (xb: `lhs' =  `rhs', `offset' `exposure')    ///
                /ln_phi                    ///
        `if' `in' `weight',                             ///
        `mlopts' `robust' `cluster'                ///
        title("2-parameter Log-Inverse Gaussian Regression")            ///
        maximize `log' `initopt'                ///
        diparm(ln_phi, exp label(phi))

    ereturn scalar k_aux = 1

    ml display, level(`level') `eform'

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





