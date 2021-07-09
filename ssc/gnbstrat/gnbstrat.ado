*! Version 1.0.0 
* GENERALIZED NEGATIVE BINOMIAL REGRESION WITH ENDOGENOUS STRATIFICATION
* Joseph Hilbe 12OCT2005
program gnbstrat, eclass properties(svyb svyj  svyr)
    version  9.1
    syntax [varlist] [if] [in] [fweight pweight aweight  iweight] [, ///
        CENsor(string)  Level(cilevel) LNAlpha(varlist numeric)      ///
        OFFset(passthru)  EXposure(passthru)            ///
        CLuster(passthru) IRr Robust noLOG FROM(string asis) *  ]   
    gettoken  lhs rhs : varlist

    mlopts mlopts, `options'

    if ("`weight'" != "")   local weight "[`weight'   `exp']"
    if (`"`from'"' != `""') local initopt `"init(`from')"'

    ml model lf jhnbstr_ll (xb: `lhs' =  `rhs', `offset' `exposure')    ///
          (lnalpha: `lnalpha')                     ///
        `if' `in' `weight',                        ///
        `mlopts' `robust' `cluster'                ///
        title("Gen. Neg. Binomial w Endogenous Stratification")     ///
        maximize `log' `initopt'

     ereturn local cmd = "gnbstrat"

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

/* 
To allow calculation of phi, insert the following starting with the 
final line of the ml model module:
             ///
        diparm(lnalpha, exp label(alpha))
*/
