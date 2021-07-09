*! Version 1.0
* TRUNCATED POISSON REGRESSION:  Joseph Hilbe :  17Oct2009
program tpoisson, properties(svyb svyj svyr)
    version 11
    syntax [varlist] [if] [in] [fweight pweight aweight iweight] [,    ///
        TRUnc(string) Level(cilevel)  TLEft(real 1) TRIght(real 1)         ///
        OFFset(passthru) EXposure(passthru) noLOG        ///
        CLuster(passthru) IRr Robust FROM(string asis) * ]   
    gettoken  lhs rhs : varlist

    marksample touse

    mlopts mlopts, `options'

    if ("`weight'" != "")   local weight "[`weight'   `exp']"
    if (`"`from'"' != `""') local initopt `"init(`from')"'

    global S_tru  "`trunc'"
    
    local tlft = `tleft'
    global Stlt   `"`tlft'"'  
    local trgt = `tright'
    global Strg   `"`trgt'"'
   
    qui count if  !inlist(`trunc',-1,0,1)
    if  r(N)>0   {
        noi di as txt                        ///
        "Note: `r(N)' values of `trunc' are not one of -1, 0,  1"
        qui replace `touse' = 0  if  !inlist(`trunc',-1,0,1)
    }   

    ml model lf tpoisll (xb: `lhs' =  `rhs', `offset' `exposure')    ///
        if `touse' `weight',                    ///
        `mlopts' `robust' `cluster'                ///
        title("Truncated Poisson Regression")            ///
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