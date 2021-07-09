*! Version 1.0.0 
* HETEROGENEOUS NEGATIVE BINOMIAL 1 REGRESSION:  Joseph Hilbe  : 13Sep2007
* Linear negative binomial; NB with constant dispersion
program hnbreg1, eclass properties(svyb svyj  svyr)
    version 9.1
    syntax [varlist] [if] [in] [fweight pweight aweight  iweight] [, ///
        Level(cilevel) OFFset(passthru)  EXposure(passthru) LNDelta(varlist numeric)  ///
        CLuster(passthru) IRr Robust noLOG FROM(string asis) *  ]   
    gettoken  lhs rhs : varlist

    qui {
    mlopts mlopts, `options'

    if ("`weight'" != "")   local weight "[`weight'   `exp']"
    if (`"`from'"' != `""') local initopt `"init(`from')"'

    ml model lf jhhnb1_ll (xb: `lhs' =  `rhs', `offset' `exposure')    ///
        (lndelta: `lndelta')                            ///
        `if' `in' `weight',                             ///
        `mlopts' `robust' `cluster'                ///
        title("Heterogeneous negative binomial 1 regression")            ///
        maximize `log' `initopt'                ///
        diparm(lndelta, exp label(delta))

      ereturn local cmd = "hnbreg1"
*    ereturn scalar k_aux = 1
    }
    tempvar y
    gen `y' = `lhs'

    ml display, level(`level') `irr'

qui {

* AIC 
    tempvar aic llf 
    local nobs e(N)
    local npred e(df_m)
    local df = e(N) - e(df_m) -1
    local llike  e(ll)
    gen `aic' = ((-2*`llike') +  2*(`npred'+1))/`nobs'
* LL TEST
    gen `llf' = e(ll)
    poisson `y' `rhs'
    local ll0 e(ll)
    local llnb  -2*(`ll0'-`llf') 
}

* DISPLAY
di in gr "Likelihood-ratio test of delta=0:  chibar2(01) = " in ye %7.2f `llnb'  in gr _col(56) " Prob>=chibar2 = " in ye %4.3f chi2tail(1,`llnb')/2
di in gr _col(1) "AIC Statistic = " in ye %7.3f `aic'


end

 


