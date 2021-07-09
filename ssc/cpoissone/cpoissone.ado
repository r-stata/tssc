*! Version 3.0.4
* CENSORED POISSON REGRESSION:  Joseph Hilbe :  27Sep2009
* Econometric Parameterization
program cpoissone, properties(svyb svyj svyr)
    version 11
    syntax [varlist] [if] [in] [fweight pweight aweight iweight] [,    ///
        CENsor(string) Level(cilevel)  CLEft(real 1) CRIght(real 1)         ///
        OFFset(passthru) EXposure(passthru) noLOG        ///
        CLuster(passthru) IRr Robust FROM(string asis) * ]   
    gettoken  lhs rhs : varlist

    marksample touse

    mlopts mlopts, `options'

    if ("`weight'" != "")   local weight "[`weight'   `exp']"
    if (`"`from'"' != `""') local initopt `"init(`from')"'

    global S_cen  "`censor'"
    
    local clft = `cleft'
    global Sclt   `"`clft'"'  
    local crgt = `cright'
    global Scrg   `"`crgt'"'
   
    qui count if  !inlist(`censor',-1,0,1)
    if  r(N)>0   {
        noi di as txt                        ///
        "Note: `r(N)' values of `censor' are not one of -1, 0,  1"
        qui replace `touse' = 0  if  !inlist(`censor',-1,0,1)
    }   

    ml model lf cpoisxll (xb: `lhs' =  `rhs', `offset' `exposure')    ///
        if `touse' `weight',                    ///
        `mlopts' `robust' `cluster'                ///
        title("Censored Poisson Regression")            ///
        maximize `log' `initopt'

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
di in gr _col(1) "AIC Statistic =  " in ye %8.3f `aic'


end