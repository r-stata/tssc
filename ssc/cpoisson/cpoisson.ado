*! Version 3.0.4
* CENSORED POISSON REGRESSION:  Joseph Hilbe :  4Oct2005 [Nick Cox: censor checking module]
program cpoisson, properties(svyb svyj svyr)
    version 9.1
    syntax [varlist] [if] [in] [fweight pweight aweight iweight] [,    ///
        CENsor(string) Level(cilevel)                ///
        OFFset(passthru) EXposure(passthru) noLOG        ///
        CLuster(passthru) IRr Robust FROM(string asis) * ]   
    gettoken  lhs rhs : varlist

    marksample touse

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

    ml model lf cpoisll (xb: `lhs' =  `rhs', `offset' `exposure')    ///
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

* LAGRANGE MULTIPLIER TEST
    tempvar y lp mu musq ymean 
    predict `lp', xb
    gen double `mu' = exp(`lp')
    gen `y' = `lhs'
    sum `y', meanonly
    local nybar = r(sum)
    local ny `nybar'
    gen double `musq' = `mu'*`mu'
    sum `musq', meanonly
    local mu2 = r(sum)
    local m2 `mu2'
    local chival = (`m2'-`ny')^2 / (2*`m2')

*SCORE
    local nobs e(N)
    local npred e(df_m)
    local df = `nobs' - (`npred'+1)
    tempvar stdp hat tnum tnum2 tden 
    predict `stdp', stdp
    gen `hat' = `stdp' * `stdp'*`mu'
    egen `tnum' = sum((`y'-`mu')^2 - (1-`hat')*`mu')
    gen `tnum2' = `tnum'*`tnum'
    egen `tden' = sum(`mu'*`mu')
    replace `tden' = `tden'*2
    local tstat = `tnum2'/`tden'

}
di in gr _col(1) "AIC Statistic =  " in ye %11.3f `aic'
di in gr _col(1) "LM Value      =  " in ye %11.3f `chival' _col(53) in gr   "LM Chi2(1)    = " in ye %10.3f chiprob(1,`chival')
di in gr _col(1) "Score test OD =  " in ye %11.3f `tstat'  _col(53) in gr   "Score Chi(1)  = " in ye %10.3f chiprob(1,`tstat')

end
