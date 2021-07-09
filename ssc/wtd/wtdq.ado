*! version 0.1, HS
* Diagnostic Q-Q- plot for waiting time distribution.
program define wtdq
version 8.2
syntax , [prevd(passthru) ddens(passthru) hdens(passthru) /* 
	*/ cens(passthru) reest /*
        */ *]

qui {
  preserve
  tempvar pred orgmark Finv

  local start : char _dta[wtd_start]
  local end : char _dta[wtd_end]
  local scale : char _dta[wtd_scale]

  if "`reest'" ~= "" {
    noi wtdml, `prevd' `ddens' `hdens' `cens' `options'
  }
  else {
    foreach parm in prevd hdens ddens cens {
      local e`parm' = e(`parm')
      local `parm' = "`parm'(`e`parm'')"
    }
  }
  local tailar = e(tailar)
  
  tempname coefnam
  mat `coefnam' = e(b)
  if index(`"`prevd'"', "exp") {
    local tittyp = "Exponential"
  }
  if index(`"`prevd'"', "wei") {
    local tittyp = "Weibull"
  }
  if index(`"`prevd'"', "lnorm") {
    local tittyp = "Log-Normal"
  }
  
  tempvar tmppred time dayno Fwtd qwtd
  drop _all
  
  local neval = (d(`end') - d(`start')) * 10
  set obs `neval'
  gen double `time' = (_n - .5) / _N
  gen double `tmppred' = .
  wtdpred `time' `tmppred'
  gen double `Fwtd' = sum(`tmppred') / `neval'
  
  
  tempfile qwtdtab
  save `qwtdtab'
  
  restore
  preserve
  tempvar pobs yeqx
  
  keep if _ot <= 2
  expand _nev
  sort _t

  gen double `pobs' = _n / _N
*   replace `pobs' = `pobs' / _N
  gen `orgmark' = 1
  
  append using `qwtdtab'
  replace `Fwtd' = `pobs' if `orgmark' == 1
  sort `Fwtd'
  replace `Fwtd' = `Fwtd'[_n - 1] if `orgmark' == 1 & _n > 1
  replace `time' = `time'[_n - 1] if `orgmark' == 1 & _n > 1
  gsort -`Fwtd'
  replace `tmppred' = `tmppred'[_n - 1] if `orgmark' == 1 & _n > 1
  sort `Fwtd'

  keep if _t ~= .
  
  gen double `Finv' = `time'[_n] + (`pobs'[_n] - `Fwtd'[_n]) /*
*/ / `tmppred'[_n] * .1 
  
  replace `Finv' = `Finv' * (d(`end') - d(`start')) + d(`start') + 1
  tempvar events
  gen `events' = _t * (d(`end') - d(`start')) + d(`start') + .5
  
  la var `Finv' "Estimated quantiles of T"
  format `Finv' %d
  la var `events' "Empirical quantiles of T"
  format `events' %d
  gen double `yeqx' = `events' if _n == 1 | _n == _N
  la var `yeqx' "Perfect fit"
  format `yeqx' %d  
  local lablow = d(`start') + 1
  local labup = d(`end')
  local lablsc = d(`start') - (d(`end') - d(`start')) * .05
  local labusc = d(`end') + (d(`end') - d(`start')) * .05
  
  twoway (scatter `Finv' `events', c(.) m(o)) (scatter `yeqx' `events', c(l) m(i)), xlab(`lablow' `labup') ylab(`lablow' `labup') xsc(r(`lablsc', `labusc')) ysc(r(`lablsc', `labusc')) `options'
  
}


end
