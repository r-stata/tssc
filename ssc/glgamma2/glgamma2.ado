*! Version 1.0.0 
* GENERALIZED GAMMA REGRESSION - 2 PARAMETER WITH LOG PARAMETERIZATION:  Joseph Hilbe  :  16Oct2005
program glgamma2, eclass properties(svyb svyj  svyr)
    version  9.1
    syntax [varlist] [if] [in] [fweight pweight aweight  iweight] [, ///
        Level(cilevel)  LNPhi(varlist numeric)               ///
        OFFset(passthru)  EXposure(passthru)            ///
        CLuster(passthru) EForm Robust noLOG FROM(string asis) *  ]   
    gettoken  lhs rhs : varlist

    mlopts mlopts, `options'

    if ("`weight'" != "")   local weight "[`weight'   `exp']"
    if (`"`from'"' != `""') local initopt `"init(`from')"'

    ml model lf lgamm_ll (xb: `lhs' =  `rhs', `offset' `exposure')    ///
            (lnphi: `lnphi')                    ///
        `if' `in' `weight',                             ///
        `mlopts' `robust' `cluster'                ///
        title("Generalized 2-parameter Log-Gamma Regression")            ///
        maximize `log' `initopt'
      
    ereturn local cmd = "glgamma2"
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

/* To obtain phi when lnphi is not parameterized, 
   type /// at end of the last line of the ml model
   module, and create a new line:
   diparm(lnphi, exp label(phi))
*/




