*! Version 2.0.0    
* GENERALIZED INVERSE GAUSSIAN REGRESSION - 2 PARAMETER WITH LOG PARAMETERIZATION:  Joseph Hilbe  :  16Oct2005
program givgauss2, eclass properties(svyb svyj  svyr)
    version  9.1
    syntax [varlist] [if] [in] [fweight pweight aweight  iweight] [, ///
        Level(cilevel)   LNPhi(varlist numeric)              ///
        OFFset(passthru)  EXposure(passthru)            ///
        CLuster(passthru) EForm Robust noLOG FROM(string asis) *  ]   
    gettoken  lhs rhs : varlist

    mlopts mlopts, `options'

    if ("`weight'" != "")   local weight "[`weight'   `exp']"
    if (`"`from'"' != `""') local initopt `"init(`from')"'

    ml model lf ivgln_ll (xb: `lhs' =  `rhs', `offset' `exposure')    ///
         (lnphi: `lnphi')                  ///
        `if' `in' `weight',                             ///
        `mlopts' `robust' `cluster'                ///
        title("Generalized 2-parameter Log-Inverse Gaussian")            ///
        maximize `log' `initopt'

    ereturn local cmd = "givgauss2"

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


/*
To obtain phi insert following beginning on last
line of ml model module:
               ///
        diparm(ln_phi, exp label(phi))
*/



