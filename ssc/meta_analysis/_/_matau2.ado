/* Stata Macro -- Written by David B. Wilson 
   Version 2021.04.06
   Code for computing tau^2
   Code Based on Wolfgang Viechtbauer metafor package for R 
   http://https://cran.r-project.org/web/packages/metafor/index.html
   License:
   Creative Commons Attribution-ShareAlike
 */

program define _matau2, rclass
version 14.0

syntax varlist(min=2 numeric) [if] [in], [model(string)] [modtype(string)]

tokenize `varlist'
marksample touse 
markout `touse' 

tempvar P PP PVdiag RSS SJW SJWdiag SJw V Vdiag W W1 W1diag Wdiag X Y
tempvar _intercept K _sumw _vv _ww _xx _y adj b change invXX invXprimeWX iter
tempvar ivs oldtau2 p qe resid2 tau2 tau2start trP trPV se_tau2 v_tau2 k Wdiag2
tempvar sumPP sumPVP sumPVtPV sumw

tempfile _origfile
qui save "`_origfile'", replace 
qui keep if `touse'

/* Get data */
mkmat `1', matrix(`Y')
mkmat `2', matrix(`W')
qui generate `_intercept' = 1
if "`modtype'"=="" {
    mkmat `_intercept', matrix(`X')
    }
if "`modtype'"=="aov" {
    qui tab `3', gen(`_xx')
    mkmat `_xx'*, matrix(`X')
    }
if "`modtype'"=="reg" {
    mkmat `varlist' `_intercept', matrix(`X')
    matrix `X' = `X'[1...,4...]
    }
matrix `K' = rowsof(`X')
scalar `k' = `K'[1,1]
scalar `p' = colsof(`X')
matrix `Wdiag' = diag(`W')
matrix `_sumw' = trace(`Wdiag')
qui generate `_vv' = 1/`2'
qui generate `_ww' = 1/`_vv'
mkmat `_vv', matrix(`V') 
scalar `iter' = 0

/* Hedges (HE) estimator (also initial value for ML, REML, EB) */
if "`model'" == "HE" |  "`model'" == "ML" |  "`model'" == "REML" |  "`model'" == "EB" {
    mkmat `_intercept', matrix(`W1')
    matrix `W1diag' = diag(`W1')
    matrix `invXX' = syminv(`X'' * `W1diag' * `X')
    matrix `P' = `W1diag' - `X' * (`invXX'*`X'')
    matrix `RSS' = (`Y''*`P') * `Y'
    matrix `Vdiag' = diag(`V')
    matrix `PVdiag' = `P' * `Vdiag'
    matrix `trPV' = trace(`PVdiag')
    matrix `tau2' = (`RSS'[1,1] - `trPV'[1,1])/(`K'[1,1]-`p')
    scalar `tau2' = `tau2'[1,1]
}

/* Hunter and Schmidt */
if "`model'" == "HS" {
    matrix `invXprimeWX' = syminv(`X'' * `Wdiag' * `X')
    matrix `P' = `Wdiag' - `Wdiag' * `X' * `invXprimeWX' * (`X''*`Wdiag')
    matrix `RSS' = (`Y''*`P') * `Y'
    matrix `tau2' = (`RSS'[1,1]-`K'[1,1])/`_sumw'[1,1]
    scalar `tau2' = `tau2'[1,1]
} 

/* Dersimonian-Laird (DL) estimator */
if "`model'" == "DL" {
    matrix `Wdiag' = diag(`W')
    matrix `invXprimeWX' = syminv(`X'' * `Wdiag' * `X')
    matrix `P' = `Wdiag' - `Wdiag' * `X' * `invXprimeWX' * (`X''*`Wdiag')
    matrix `trP' = trace(`P')
    matrix `RSS' = (`Y''*`P') * `Y'
    matrix `tau2' = (`RSS'[1,1] - (`K'[1,1] - `p'))/`trP'[1,1]
    scalar `tau2' = `tau2'[1,1]
}

/* Sidik-Jonkman (SJ) estimator */
if "`model'" == "SJ" | "`model'" == "SJIT"{
    qui sum `1'
    scalar `tau2start' = r(Var) * (`K'[1,1]-1)/`K'[1,1]
    qui generate `SJw' = 1/(`_vv' + `tau2start')
    mkmat `SJw', matrix(`SJW')
    matrix `SJWdiag' = diag(`SJW')
    matrix `invXprimeWX' = syminv(`X'' * `SJWdiag' * `X')
    matrix `P' = `SJWdiag' - `SJWdiag' * `X' * `invXprimeWX' * (`X''*`SJWdiag')
    matrix `RSS' = (`Y''*`P') * `Y'
    matrix `Vdiag' = diag(`V')
    matrix `PVdiag' = `P' * `Vdiag'
    matrix `tau2' = (`RSS'[1,1] * `tau2start')/(`k'-`p')
    scalar `tau2' = `tau2'[1,1]
}

/* Sidik-Jonkman (SJIT) estimator with iteration */
if "`model'" == "SJIT" {
    scalar `iter' = 0
    scalar `change' = 1
    while abs(`change') > .0000001 & `iter'<100 { 
        scalar `iter' = `iter' + 1
        matrix `oldtau2' = `tau2'
        qui replace `SJw' = 1/(`_vv' + `tau2')
        mkmat `SJw', matrix(`SJW')
        matrix `SJWdiag' = diag(`SJW')
        matrix `invXprimeWX' = syminv(`X'' * `SJWdiag' * `X')
        matrix `P' = `SJWdiag' - `SJWdiag' * `X' * `invXprimeWX' * (`X''*`SJWdiag')
        matrix `RSS' = (`Y''*`P') * `Y'
        matrix `Vdiag' = diag(`V')
        matrix `PVdiag' = `P' * `Vdiag'
        matrix `tau2' = (`RSS'[1,1] * `tau2')/(`k'-`p')
        scalar `tau2' = `tau2'[1,1]
        scalar `change' = `tau2' - `oldtau2'[1,1]
    }
     if `tau2' > 0 {
        qui replace `_ww' = 1/(`_vv' + `tau2')
        mkmat `_ww', matrix(`W')
        matrix `Wdiag' = diag(`W')
     }
     if `tau2' <= 0 {
        qui replace `_ww' = 1/(`_vv')
        mkmat `_ww', matrix(`W')
        matrix `Wdiag' = diag(`W')
     }
    }

/* Maximum likelihood (ML, REML, EB) */
if "`model'" == "REML" | "`model'" == "ML" | "`model'" == "EB" {
    scalar `change' = 1
    scalar `iter' = 0
    while abs(`change') > .0000001 & `iter'<100 {
        scalar `iter' = `iter' + 1
        scalar `oldtau2' = `tau2'
        qui replace `_ww' = 1/(`_vv' + `tau2')
        mkmat `_ww', matrix(`W')
        matrix `Wdiag' = diag(`W')
        matrix `invXprimeWX' = syminv(`X'' * `Wdiag' * `X')
        matrix `P' = `Wdiag' - `Wdiag' * `X' * `invXprimeWX' * (`X''*`Wdiag')
        matrix `PP' = `P' * `P'
        if "`model'" == "ML" {
            matrix `adj' = (`Y''*`PP' * `Y' - trace(`Wdiag'))/trace(`Wdiag'*`Wdiag')
            }
        if "`model'" == "REML" {
            matrix `adj' = (`Y''*`PP' * `Y' - trace(`P'))/trace(`PP')
            }
        if "`model'" == "EB" {
            matrix `adj' = (`Y''*`P' * `Y' * `k'/(`k'-`p') - `k')/trace(`Wdiag')
            }
        scalar `tau2' = `tau2' + `adj'[1,1]
        scalar `change' = `tau2' - `oldtau2'
     }
     if `tau2' > 0 {
        qui replace `_ww' = 1/(`_vv' + `tau2')
        mkmat `_ww', matrix(`W')
        matrix `Wdiag' = diag(`W')
        matrix `invXprimeWX' = syminv(`X'' * `Wdiag' * `X')
        matrix `P' = `Wdiag' - `Wdiag' * `X' * `invXprimeWX' * (`X''*`Wdiag')
     }
     if `tau2' <= 0 {
        qui replace `_ww' = 1/(`_vv')
        mkmat `_ww', matrix(`W')
        matrix `Wdiag' = diag(`W')
        matrix `invXprimeWX' = syminv(`X'' * `Wdiag' * `X')
        matrix `P' = `Wdiag' - `Wdiag' * `X' * `invXprimeWX' * (`X''*`Wdiag')     
     }
}

if `iter' == 100 {
  di "  "
  di "**********************************************"
  di "Failed to converge. Try a different model type"
  di "**********************************************"
}

if `tau2' < 0 {
  scalar `tau2' = 0
  }

/* standard error of tau^2 */
/* compute sum(P*P) and sum(PV * t(PV)) and sum(PV*P) */
if "`model'" == "HS" | "`model'" == "DL" | "`model'" == "SJ" | "`model'" == "REML" | "`model'" == "HE" {
   scalar `sumPP' = 0
   scalar `sumPVP' = 0
   scalar `sumPVtPV' = 0
   local n = `k'
   forvalues i = 1/`n' {
      forvalues j = 1/`n' {
      scalar `sumPP'    = `sumPP'    + `P'[`i',`j']^2
      }
   }
   if "`model'" == "HE" | "`model'" == "SJ" {
     forvalues i = 1/`n' {
         forvalues j = 1/`n' {
            scalar `sumPVtPV' = `sumPVtPV' + `PVdiag'[`i',`j']*`PVdiag'[`j',`i']
         }
     }
   }
   if "`model'" == "SJ" {
     forvalues i = 1/`n' {
         forvalues j = 1/`n' {
            scalar `sumPVP'   = `sumPVP'   + `PVdiag'[`i',`j']*`P'[`i',`j']
         }
     }
   }
}

if "`model'" == "HE" {
   scalar `se_tau2' = sqrt( 1/(`k'-`p')^2 * (2*`sumPVtPV' + 4*`tau2'*`trPV'[1,1] + 2*`tau2'^2*(`k'*`p')))
}

if "`model'" == "HS" {
   qui replace `_ww' = 1/`_vv'
   qui sum `_ww'
   scalar `sumw' = r(sum)
   di `sumw'
   scalar `se_tau2' = sqrt(1/`sumw'^2 * (2 * (`k'-`p')  + 4*`tau2'*trace(`P') + 2 * `tau2'^2 * `sumPP')) 
} 
if "`model'" == "DL" {
   scalar `se_tau2' = sqrt(1/`trP'[1,1]^2 * (2*(`k'-`p') + 4*`tau2'*`trP'[1,1] + 2*`tau2'^2*`sumPP'))
}

if "`model'" == "SJ" {
   scalar `se_tau2' = sqrt(`tau2start'^2/(`k'-`p')^2 * (2*`sumPVtPV' + 4*`tau2'*`sumPVP' + 2*`tau2'^2*`sumPP'))
}

if "`model'" == "ML" {
   matrix `Wdiag2' = `Wdiag'' * `Wdiag'
   scalar `se_tau2' = sqrt(2/trace(`Wdiag2'))
    }
if "`model'" == "REML" {
   scalar `se_tau2' = sqrt(2/`sumPP')
   }
if "`model'" == "EB" | "`model'" == "SJIT"{
   scalar `se_tau2' = sqrt(2*`k'^2/(`k'-`p') /(trace(`Wdiag')^2))
   }

return scalar tau2 = `tau2'
return scalar se_tau2 = `se_tau2'

qui use "`_origfile'", replace

end
