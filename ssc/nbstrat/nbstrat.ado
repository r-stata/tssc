*! Version 1.0.0 
* NEGATIVE BINOMIAL REGRESION WITH ENDOGENOUS STRATIFICATION
* Joseph Hilbe and Roberto Marteniz-Espineira:  10Sep2005 add GOF 26Sep2005
program nbstrat, eclass properties(svyb svyj  svyr)
    version  9.1
    syntax [varlist] [if] [in] [fweight pweight aweight  iweight] [, ///
        CENsor(string)  Level(cilevel)                ///
        OFFset(passthru)  EXposure(passthru)            ///
        CLuster(passthru) IRr Robust noLOG FROM(string asis) *  ]   
    gettoken  lhs rhs : varlist

    mlopts mlopts, `options'

    if ("`weight'" != "")   local weight "[`weight'   `exp']"
    if (`"`from'"' != `""') local initopt `"init(`from')"'

    ml model lf jhnbstr_ll (xb: `lhs' =  `rhs', `offset' `exposure')    ///
                /lnalpha                    ///
        `if' `in' `weight',                             ///
        `mlopts' `robust' `cluster'                ///
        title("Negative Binomial with Endogenous Stratification")     ///
        maximize `log' `initopt'                ///
        diparm(lnalpha, exp label(alpha))

    ereturn scalar k_aux = 1

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
gen double `mu' = exp(`lp')
gen `y' = `lhs'
local alpha  r(est)
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

