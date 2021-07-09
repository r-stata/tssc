*! Version 1.0.0 
* ZERO TRUNCATED GEOMETRIC REGRESSION :  Joseph Hilbe  :  25Sep2005
program ztg, eclass properties(svyb svyj  svyr)
    version 9.1
    syntax [varlist] [if] [in] [fweight pweight aweight  iweight] [, ///
        CENsor(string)  Level(cilevel)                ///
        OFFset(passthru)  EXposure(passthru)            ///
        CLuster(passthru) IRr Robust noLOG FROM(string asis) *  ]   
    gettoken  lhs rhs : varlist

    mlopts mlopts, `options'

    if ("`weight'" != "")   local weight "[`weight'   `exp']"
    if (`"`from'"' != `""') local initopt `"init(`from')"'

    ml model lf jhzgeo_ll (xb: `lhs' =  `rhs', `offset' `exposure')    ///
        `if' `in' `weight',                     ///
        `mlopts' `robust' `cluster'             ///
        title("0-Truncated Geometric Regression")           ///
        maximize `log' `initopt'                ///
        

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
tempvar y lp mu dev sdev 
predict `lp', xb
gen double `mu' = exp(`lp')
gen `y' = `lhs'
egen `dev' = sum(`y'*ln(`y'/`mu') - (1+`y')*ln((1+`y')/(1+`mu')) )
local deviance = 2*`dev' 
local nobs e(N)
local npred e(df_m)
local df = `nobs' - (`npred'+1)
local ddisp = `deviance'/ `df'

* BIC
local bic = `deviance' - `df'*ln(`nobs')

}
di in gr _col(1) "AIC Statistic = " in ye %9.3f `aic'      _col(51) in gr "BIC Statistic =  " in ye %11.3f `bic'
di in gr _col(1) "Deviance      = " in ye %9.3f `deviance' _col(51) in gr "Dispersion    =  " in ye %11.3f `ddisp'

end






