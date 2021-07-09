*! version 0.1, HS, Feb 28, 2005
/* wtddiag 

   Diagnostic plot for waiting time distribution.

*/


program define wtddiag
version 8.2
syntax , barsize(real) [frmodels(string) hdmodels(string) /* 
	*/ cens(passthru) nval(passthru) initmat(passthru) /*
        */ ylab(passthru) Cutpt(string) neval(integer 100) NOIEST *]

tokenize `varlist'
local events _t
local death _z
preserve
qui{
  wtd_is

  tempfile orgdat
  tempvar time
  save `orgdat'

  su _t [fw = _nev] , mean
  local nid = r(N)
  
  su _t [fw = _nev] if _ot <= 2, mean
  local nevobs = r(N)

  local start : char _dta[wtd_start]
  local end : char _dta[wtd_end]
  local scale : char _dta[wtd_scale]
  
  local scbarsize = `barsize' / (d(`end') - d(`start'))

  /* If Cutpt is present we compute empirical estimates */

  if "`cutpt'" ~= "" {
    tempvar incmark prevmrk prevcnt plotinc totus totcnt

    local sccutpt = (d(`cutpt') - d(`start')) / (d(`end') - d(`start'))
    su _t [fw = _nev] if _t >= `sccutpt' & _ot <= 2, mean
    local inccnt = r(N)
        
    local incid = `inccnt' / (1 - `sccutpt') / (d(`end') - d(`start'))
 
    su _t [fw = _nev] if _t < `sccutpt' & _ot <= 2, mean
    local prevcnt = r(N)
    local preval = `prevcnt' - `incid' * (d(`cutpt') - d(`start'))
    local incrate = `incid' * `scale' / ((`nid' - `preval') - .5 * `inccnt')
    local plotinc = `incid' * `barsize'

    noi di "Total # of events: " `nevobs'
    noi di "Total # of incident subjects in period: " `incid' * (d(`end') - d(`start'))
    noi di "Total # of prevalent subjects in period: "  `preval'
    noi di "Incidence rate: " `incrate'
    noi di "Prevalence: " `preval' / `nid'
    noi di "------------------------",,

 
    local numcutpt = d(`cutpt')
    local xline = "xline(`numcutpt')"
  }

  local npmod = 0
  if index("`frmodels'", "e") {
    local npmod = `npmod' + 1
    local p`npmod' = "exp"
    local leg`npmod' = "Exponential FR"
  }
  if index("`frmodels'", "w") {
    local npmod = `npmod' + 1
    local p`npmod' = "wei"
    local leg`npmod' = "Weibull FR"
  }
  if index("`frmodels'", "l") {
    local npmod = `npmod' + 1
    local p`npmod' = "lnorm"
    local leg`npmod' = "Log-Normal FR"
  }
  
  local nhdmod = 0
  if index("`hdmodels'", "u") {
    local nhdmod = `nhdmod' + 1
    local hd`nhdmod' = "unif"
  }
  if index("`hdmodels'", "e") {
    local nhdmod = `nhdmod' + 1
    local hd`nhdmod' = "exp"
  }

  /* For each model we estimate and store results */

    if `npmod' > 0 & `nhdmod' > 0 {
      forv pmod = 1 / `npmod' {
        forv hdmod = 1 / `nhdmod' {
          use `orgdat'
          tempname `p`pmod''`hd`hdmod''coef
          tempvar p`pmod'hd`hdmod'pred p`pmod'hd`hdmod'temp p`pmod'hd`hdmod'sum
          
          if "`noiest'" == "" {
            wtdml, prevd(`p`pmod'') hdens(`hd`hdmod'') ddens(`hd`hdmod'') `cens'
          }
          else {
            noi wtdml, prevd(`p`pmod'') hdens(`hd`hdmod'') ddens(`hd`hdmod'') `cens'
          }
          
          matrix `p`pmod''`hd`hdmod''coef = e(b)
          local tailar = r(tailar)
          drop _all
          set obs `neval'
          gen `time' = (_n - .5) / _N
          gen `p`pmod'hd`hdmod'pred' = .
          
          wtdpred `time' `p`pmod'hd`hdmod'pred', prevd(`p`pmod'') hdens(`hd`hdmod'') ddens(`hd`hdmod'') `cens' coefvek(`p`pmod''`hd`hdmod''coef) tailar(`tailar')
          
          replace `p`pmod'hd`hdmod'pred' = `p`pmod'hd`hdmod'pred' * `nevobs' * `scbarsize'
          
          la var `p`pmod'hd`hdmod'pred' "`leg`pmod''"
          tempfile `p`pmod''`hd`hdmod''pdat
          save ``p`pmod''`hd`hdmod''pdat'
        }
      }
    }

  /* Instead of Stata's built-in histogram we prefer a custom-made,
since it allows proper handling of bars at the lower and upper
date limit */
  
  use `orgdat'
  expand _nev
  tempvar tbin ncount mdate
  marksample touse, nov
  keep if `touse'
  
  local startdat = d(`start')
  local enddat = d(`end')
  egen `tbin' = cut(`events'), at(0(`scbarsize')1)
  _crcslbl `tbin' `events' 
  sort `tbin'
  by `tbin': gen `ncount' = _N if _n == 1 & `tbin' ~= .
  keep if `ncount' ~= .
  la var `ncount' "Empirical"
  sort `tbin'
  gen `mdate' = (`tbin'[_n + 1] - `tbin'[_n]) / `scbarsize'
  expand `mdate'
  sort `tbin'
  local newsize = _N + 1
  set obs `newsize'
  replace `tbin' = 1 if _n == _N
  sort `tbin'
  by `tbin': replace `ncount' = 0 if _n > 1
  by `tbin': replace `tbin' = `tbin'[1] + (_n - 1) * `scbarsize' if _n > 1
  expand 3
  sort `tbin'
  by `tbin': replace `ncount' = 0 if _n == 2
  drop if _n == 1
  drop if _n == _N
  replace `ncount' = `ncount'[_n - 1] if `ncount'[_n + 1] == 0
  replace `ncount' = `ncount' / (`tbin'[_N - 1] - `tbin'[_N - 2]) * `scbarsize' if _n == _N - 1 | _n == _N - 2
  
  rename `tbin' `time'
  if `npmod' > 0 & `nhdmod' > 0 {
    forv pmod = 1 / `npmod' {
      forv hdmod = 1 / `nhdmod' {
        append using ``p`pmod''`hd`hdmod''pdat'
      }
    }
  }

  local xmin = d(`start')
  local xmax = d(`end')
  replace `time' = d(`start') + (d(`end') - d(`start')) * `time'
  format %d `time'
  forv pmod = 1 / `npmod' {
    forv hdmod = 1 / `nhdmod' {
      local ps`pmod'`hdmod' = "(sc `p`pmod'hd`hdmod'pred' `time', c(l) m(i))"
    }
  }
  la var `time' "Event time"

  twoway (scatter `ncount' `time', c(l) m(i)) `ps11' `ps12' `ps21' `ps22' `ps31' `ps32', yline(`plotinc') `ylab' `xline' l2("Frequency") xsc(r(`xmin' `xmax')) xlab(minmax) plotr(m(r=+5)) `options' 

    
}
restore
end

