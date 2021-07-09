*! Version 1.0
* CENSORED NEGATIVE BINOMIAL REGRESSION:  Joseph Hilbe :  30Nov2005 
program censornb, properties(svyb svyj svyr)
    version 9.1
    syntax [varlist] [if] [in] [fweight pweight aweight iweight] [,    ///
        CENsor(string) Level(cilevel)                ///
        OFFset(passthru) EXposure(passthru) noLOG        ///
        CLuster(passthru) IRr Robust FROM(string asis) * ]   
    gettoken  lhs rhs : varlist

*   marksample touse
* if `touse' `weight',

    mlopts mlopts, `options'

    if ("`weight'" != "")   local weight "[`weight'   `exp']"
    if (`"`from'"' != `""') local initopt `"init(`from')"'

    global S_cen  "`censor'"
    
    qui count if  !inlist(`censor',-1,0,1)
    if  r(N)>0   {
        noi di as txt                        ///
        "Note: `r(N)' values of `censor' are not one of -1, 0,  1"
        qui replace `touse' = 0  if  !inlist(`censor',-1,0,1)
    }   

    ml model lf cenegbinll (xb: `lhs' =  `rhs', `offset' `exposure')    ///
              /lnalpha                                   ///
        `if' `in' `weight',                             ///
        `mlopts' `robust' `cluster'                      ///
        title("Censored Negative Binomial Regression")   ///
        maximize `log' `initopt'                         ///
        diparm(lnalpha, exp label(alpha))

 *   ereturn scalar k_aux = 1

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
di in gr _col(1) "AIC Statistic =  " in ye %11.3f `aic'

global S_obs `nobs'
 
end
