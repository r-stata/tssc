*! Version 1.0.0 
* HETEROGENEOUS CANONICAL NEGATIVE BINOMIAL REGRESSION:  Joseph Hilbe  : 8Sep2007
program hcnbreg, eclass properties(svyb svyj  svyr)
    version 9.1
    syntax [varlist] [if] [in] [fweight pweight aweight  iweight] [, ///
        Level(cilevel) OFFset(passthru)  EXposure(passthru) LNAlpha(varlist numeric)  ///
        CLuster(passthru) IRr Robust noLOG FROM(string asis) *  ]   
    gettoken  lhs rhs : varlist

    qui {
    mlopts mlopts, `options'

    if ("`weight'" != "")   local weight "[`weight'   `exp']"
    if (`"`from'"' != `""') local initopt `"init(`from')"'

    ml model lf jhhnb_ll (xb: `lhs' =  `rhs', `offset' `exposure')    ///
        (lnalpha: `lnalpha')                            ///
        `if' `in' `weight',                             ///
        `mlopts' `robust' `cluster'                ///
        title("Heterogeneous Canonical Negative Binomial Regression")            ///
        maximize `log' `initopt'                ///
        diparm(lnalpha, exp label(alpha))

      ereturn local cmd = "hcnbreg"
*    ereturn scalar k_aux = 1
    }

    ml display, level(`level') `irr'

qui {
* AIC
    tempvar aic
    local nobs e(N)
    local npred e(df_m)
    local df = e(N) - e(df_m) -1
    local llike  e(ll)
    gen `aic' = ((-2*`llike') +  2*(`npred'+1))/`nobs'


* DEVIANCE
tempvar y lp mu dev sdev alpha 
predict `lp', xb
gen `y' = `lhs'
local alpha  r(est)
gen double `mu' = 1/(`alpha'*(exp(-`lp')-1))
egen `dev' = sum((`y' * ln(`y'/`mu')) - (((1+`alpha'*`y')/`alpha') * ln((1+`alpha'*`y')/(1+`alpha'*`mu'))))
local deviance = 2*`dev' 
local nobs e(N)
local npred e(df_m)
local df = `nobs' - (`npred'+1)
local ddisp = `deviance'/ `df'

* BIC
local bic = `deviance' - `df'*ln(`nobs')

}

* DISPLAY
di in gr _col(1) "AIC Statistic   =  " in ye %11.3f `aic' _col(53) in gr      "BIC Statistic = " in ye %10.3f `bic'
di in gr _col(1) "Deviance        =  " in ye %11.3f `deviance' _col(53) in gr "Dispersion    = " in ye %10.3f `ddisp'


end



/* 
Deviance:  y*ln( (y*(1+mu))/(mu*(1+y)) ) - ln( (1+mu)/(1+y) )/a
*/


