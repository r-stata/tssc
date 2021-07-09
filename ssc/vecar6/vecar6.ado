*! vecar6: v.6 adaptation of CFBaum's vecar version 1.1.11  1620
*! version 2.1.2 04jun2002   CFBaum/PJoly
* v.2.1.2 04jun2002   PJoly   corrected dof for omnibus test
* v.2.1.1 31may2002   Pjoly   pred only in sample for wntstmvq
* v.2.1   22Jun2001   local macro eqnames2 renamed to eqnmes2
* v.2.0   13Jun2001

program define vecar6, eclass /* byable(recall) */
      version 6

      local myopt "Exog(varlist ts) Level(integer $S_level) Table noHeader COV DFK noConstant"
      qui tsset /* error if not set as time series */

      tempname sigma tsig ft
      tempname rcv
      if !replay() {
            syntax varlist(min=2 ts) [if] [in]  ,Maxlag(integer) [ `myopt' Saving(string) Using(string) uncorr]
            if `maxlag' < 1 {
                  di in r "maxlag must be at least 1."
                  error 198
                  }
            local eqnames `varlist'
            local neq : word count `eqnames'
            local eqnames `varlist'
            local varlist `exog'
            local dfk `dfk'
            local dev "dev"
            if "`constant'" == "noconstant" { local dev "" }
            local uncorr `uncorr'
            local i 1
            while (`i'<=`neq') {
                  local eqn : word `i' of `eqnames'
                  local varlist `varlist' L(1/`maxlag').`eqn'
                  local i = `i' + 1
            }
            local i 1
            while (`i'<=`neq') {
                  local eqn : word `i' of `eqnames'
                  eq `eqn' `varlist'
                  local i = `i' + 1
            }
            tempvar touse
            mark `touse' `if' `in'
            markout `touse' `eqnames' `varlist'

            tempname ee xx xy yy bb xxi cxxi b idfe ss
            qui mat accum `ee' = `eqnames' `varlist' /*
                  */ if `touse', `constant'
            local nobs = r(N)
            local neqp1 = `neq' + 1
            mat `xx' = `ee'[`neqp1'...,`neqp1'...]
            mat `xy' = `ee'[`neqp1'...,1..`neq']
            mat `yy' = `ee'[1..`neq',1..`neq']
            mat drop `ee'
            mat `xxi' = syminv(`xx')
            mat `bb' = `xy'' * `xxi'
            mat `rcv' = `yy' - `bb'*`xx'*`bb''

            local dfe = `nobs' - rowsof(`xx')
            scalar `idfe' = 1/`dfe'
            mat `rcv' = `rcv' * `idfe'
            mat `cxxi' = `rcv' # `xxi'
            local i 1
            while (`i' <= `neq') {
                  mat `xx' = `bb'[`i',1...]
                  local eqn : word `i' of `eqnames'
                  mat coleq `xx' = `eqn'
                  mat `b' = nullmat(`b') , `xx'
                  local t : display string(sqrt(`rcv'[`i',`i']), "%9.0g")
                  local sd "`sd' `t'"
                  qui summ `eqn' if `touse' [`weight'`exp']
                  if ("`constant'"=="") {
                        local t = 1 - `rcv'[`i',`i']*`dfe' /*
                                   */ /(r(N)-1)/r(Var)
                  }
                  else local t = 1 - `rcv'[`i',`i']*`dfe'/`yy'[`i',`i']
                  local t : display string(`t', "%6.4f")
                  local r2 "`r2' `t'"
                  local i = `i' + 1
            }
            est post `b' `cxxi', dof(`dfe') esample(`touse')
* get names stripped of ts operators
            tsrevar `eqnames',list
* 1620: correct 80-byte bug
            local eqnmes2  "`r(varlist)'"
            local i 1
            while (`i' <= `neq') {
                  local eqn : word `i' of `eqnmes2'
                  qui test [`eqn']
                  local t : display string(r(F), "%9.0g")
                  local f "`f' `t'"
                  local t : display /*
                        */ string(fprob(r(df),r(df_r),r(F)), "%6.4f")
                  local prv "`prv' `t'"
                  local i = `i' + 1
            }

            est local r2 "`r2'"
            est local p_F "`prv'"
            est local rmse "`sd'"
            est local F "`f'"
            est local eqnames "`eqnames'"
            est local depvar `e(eqnames)'
            est scalar k  = colsof(`bb')
            est scalar df_r = `dfe'
            est scalar maxlag = `maxlag'
            est scalar k_eq = `neq'
            est scalar N    = `nobs'
            est local predict "reg3_p"
            est local cmd "vecar6"

* create cov matrix of residuals
* default: divide by T, but dfk option implies division by T-k
            if "`dfk'"=="" {
                  mat `rcv' = float((e(N)-e(k))/e(N)) * `rcv'
                  }
            else {
                  local based "-k"
            }
            est matrix Sigma `rcv'
* save log det Sigma for VAR
            local ldet = log(det(e(Sigma)))
            est scalar ll = `ldet'
* calc equivalent for meanonly model (do not use dev if model lacks constant)
            qui mat accum `ss' = `e(eqnames)' if e(sample), `dev' noc
            mat `ss' = `ss'/`e(N)'
            local ldet0 = log(det(`ss'))
            est scalar ll0 = `ldet0'
            mat drop `xx' `yy' `xy' `bb'
      }
      else {
            if ("`e(cmd)'"!="vecar6") { error 301 }
            if _by() { error 190 }
            syntax [, `myopt']
      }
      if ("`header'"=="") {
            local i 1
            di
            di in g "Vector Autoregression for lags 1-`e(maxlag)'"
            di
            if "`exog'" !="" {
                  di "Exogenous variables : `exog'"
                  di
                  }
            di in gr "Equation            T      k        RMSE    " _quote "R-sq" _quote "          F        P"
            di in g _dup(70) "-"
            while (`i'<=e(k_eq)) {
                  local myword : word `i' of `e(eqnames)'
                  local sd : word `i' of `e(rmse)'
                  local r2 : word `i' of `e(r2)'
                  local f  : word `i' of `e(F)'
                  local pv : word `i' of `e(p_F)'
                  local parms "`e(k)'"
                  local nobs e(N)
/*                local myword = abbrev("`myword'",12) */
                  di in ye "`myword'" _col(14) %8.0f `nobs' /*
                        */ %7.0f `parms' /*
                        */ "   " %9.0g `sd' %10.4f `r2' "  " /*
                        */ %9.0g `f' %9.4f `pv'
                  local i = `i' + 1
            }
      }
      if ("`table'"!="") {
            di
            est di, level(`level')
      }

* VAR: block F tests on each eqn (joint signif of each variable in the eqn)
            mat def `ft' = J(e(k_eq)*e(k_eq),2,0)
            local i 1
            local k 1
            local rownam " "
            while (`i'<=e(k_eq)) {
* access eqnmes2 to look up equation name
                        local myword : word `i' of `eqnmes2'
                        local vl`k' " "
                        local j 1
                              while (`j'<=e(k_eq)) {
                              local myword2 : word `j' of `e(eqnames)'
                              local m 1
                              while (`m'<=`e(maxlag)') {
                                    local vl`k' `vl`k'' [`myword']L`m'.`myword2'
                                    local m = `m'+1
                                    }
                              local rownam  `rownam' `myword':`myword2'
                              local j = `j'+1
                              local k = `k'+1
                              }
                        local i = `i'+1
                        }
            local i 1
            while(`i'<`k') {
                        qui test  `vl`i''
                        mat `ft'[`i',1]=r(F)
                        mat `ft'[`i',2]=r(p)
                        local i = `i'+1
                        }
            di
            di "Block F-tests with `r(df)' and `r(df_r)' d.f."
            matrix rownames `ft' = `rownam'
            matrix colnames `ft' = F p-value
            di in gr _dup(32) "-"
            mat list `ft', nohead format(%9.4f)

            if "`saving'" != "" {
                  if (length("`saving'")>4) {
                        di in red "saving() name too long"
                        exit 198
                  }
                  capt macro drop LRTS`saving'
                  global LRTS`saving' "`e(cmd)' `e(N)' `e(ll)' `e(k_eq)' `e(maxlag)' `e(k)'"

            }

            if "`using'"!= "" {
                  if (length("`using'")>4) {
                        di in red "using() name too long"
                        exit 198
                  }
            local user `using'
            local name LRTS`user'
            local touse $`name'
            if "`touse'"=="" {
                  di in red _n "model `user' not found"
                  exit 302
            }
            tokenize `touse'
            local bmod `1'
            local bobs `2'
            local bll  `3'
            local bkeq `4'
            local bmxl `5'
            local bk   `6'
            if "`bmod'" != e(cmd)  {
                  di in red _n "cannot compare `bmod' and `e(cmd)' estimates"
                  exit 402
            }
            if `bkeq' != e(k_eq)  {
                  di in red _n "cannot compare vecar estimates from different systems"
                  exit 402
            }
            if  `bmxl' <= e(maxlag) {
                  di in red _n "cannot compare vecar estimates of `bmxl' vs. `e(maxlag)' lags"
                  exit 402
            }
            if `bobs' != e(N) {
                  di in blu _n "Warning:  observations differ:  `bobs' vs. `e(N)'"
                  }
            di _n "Log det (`bmxl' lags) = " in ye %9.4f `bll'
            di    "Log det (`e(maxlag)' lags) = " in ye %9.4f `e(ll)'
            local diff = `e(ll)' - `bll'
* correction per Sims, 1980 Econometrica, p.17 (disable with uncorr)
            local lrmult = `e(N)'
            if "`uncorr'" =="" {
                  local lrmult = `lrmult' - `bk'
                  local kadj "(T-k)"
                  }
            local lrt  = `lrmult' * `diff'
            local lrdf = `e(k_eq)'*(`bk'-`e(k)')
            di _n "LR Test `kadj' = " in ye %9.4f `lrt' in gr " Prob > Chi2(`lrdf') = " /*
            */ in ye %6.4f chiprob(`lrdf',`lrt')
            }

            if ("`cov'"!="") {
            di
            di in gr "Covariance matrix of residuals (based on T`based'):"
            mat list e(Sigma), nohead /* format(%9.4f) */
            di _n "Log det (`e(maxlag)' lags) = " in ye %9.4f `e(ll)'
            di    "Log det (0 lags) = " in ye %9.4f `e(ll0)'
            local diff = `e(ll0)' - `e(ll)'
* correction per Sims, 1980 Econometrica, p.17 (disable with uncorr)
            local lrmult = `e(N)'
            if "`uncorr'" =="" {
                  local lrmult = `lrmult' - `e(k)'
                  local kadj "(T-k)"
                  }
            local lrt  = `lrmult' * `diff'
            local lrdf = `e(k_eq)'^2*`e(maxlag)'
            di _n "LR Test `kadj' = " in ye %9.4f `lrt' in gr " Prob > Chi2(`lrdf') = " /*
            */ in ye %6.4f chiprob(`lrdf',`lrt')
* RSperling 1420; do not reverse sign e(ll)
            local AIC = `e(ll)' + 2 * `e(maxlag)' * `e(k_eq)'^2 / `e(N)'
            local SC = `e(ll)' + log(`e(N)') / `e(N)' * `e(maxlag)' *`e(k_eq)'^2
            local HQ = `e(ll)' + 2 * log(log(`e(N)')) / `e(N)' * `e(maxlag)' * `e(k_eq)'^2
            di in gr _n "Order selection criteria:" _n
            di in gr "AIC = " in ye %7.4f `AIC'
            di in gr "SC  = " in ye %7.4f `SC'
            di in gr "HQ  = " in ye %7.4f `HQ'
            est scalar AIC = `AIC'
            est scalar SC = `SC'
            est scalar HQ = `HQ'
*
/*          local vl
            forv i=1/`e(k_eq)' {
                  tempvar r`i'
                  qui predict `r`i'',r eq(#`i')
                  local vl `vl' `r`i''
                  } */
* PJoly: forv does not work with version 6.0, replaced by:
local i 0
while `i' < `e(k_eq)' {
      local i = `i'+1
      tempvar r`i'
      qui predict `r`i'' if e(sample), r eq(#`i')
      local vl `vl' `r`i''
}
            wntstmvq `vl' if e(sample),varlags(`e(maxlag)')
            mat `sigma' = corr(e(Sigma))
            mat `sigma' = `sigma' * `sigma' '
            local tsig = (trace(`sigma') - e(k_eq))*e(N)/2
            local df = e(k_eq)*(e(k_eq)-1)/2
            di
            di in gr "Breusch-Pagan test of independence: chi2(`df') = " /*
            */ in ye %9.3f `tsig' in gr ", Pr = " %6.4f /*
            */ in ye chiprob(`df',`tsig')

            est scalar df_chi2 = `df'
            est scalar chi2 = `tsig'

            /* Double saves */
            global S_3 "`e(df_chi2)'"
            global S_4 "`e(chi2)'"

            Omninor6 `vl'
      }
end


* omninor6: v.6. adaptation of CFBaum's omninorm version 1.0.2  1326
* version 1.0
* Omnibus normality test, Doornik / Hansen 1994
* http://ideas.uqam.ca/ideas/data/Papers/wuknucowp9604.html
* from normtest.ox
* requires matmap (NJC) and _gstdn

program define Omninor6, rclass
      version 6
      syntax varlist(ts) [if] [in]
      marksample touse
      qui count if `touse'
      if r(N) == 0 { error 2000 }
      local N = r(N)
      local Nm1 = r(N) - 1
      local oneN = 1.0/`N'
      tempname corr evec eval norm std iota skew kurt vy vy2 vys kurt2 lvy vz newskew newkurt omni omnia
      local count: word count `varlist'
* N01
      qui mat accum `corr' = `varlist' if `touse', noc d
      mat `corr' = `corr' / `Nm1'
      mat `corr' = corr(`corr')
      mat symeigen `evec' `eval' = `corr'
      local nc = colsof(`eval')
/*    forv i=1/`nc' {
PJoly: forv does not work with version 6.0 */
local i 0
while `i'<`nc' {
local i = `i'+1
            if `eval'[1,`i']>1e-12 {
                  mat `eval'[1,`i']=1.0/sqrt(`eval'[1,`i'])
                  }
            else {
                  mat `eval'[1,`i']=0
                  }
            }
local i 1
/*    foreach var of varlist `varlist' {
PJoly: forv does not work with version 6.0 */
while `i'<=`count' {
local var : word `i' of `varlist'
            tempvar s`i'
            qui egen `s`i'' = stdn(`var') if `touse'
            local svl `svl' `s`i''
            local i = `i'+1
      }
      mkmat `svl' if `touse',mat(`norm')
      mat `std' = `norm'*`evec'*diag(`eval')*`evec''
* skew, kurt
      matmap `std' `skew',map(@^3)
      matmap `std' `kurt',map(@^4)
      mat `iota'=J(1,`N',`oneN')
      mat `skew'=`iota'*`skew'
      mat `kurt'=`iota'*`kurt'
      mat `iota' = J(1,`nc',1)
* skewsu
            local nsk = cond(`N'<8,8,`N')
            local nsk2 = `nsk'^2
            local beta = 3 * (`nsk2'+27*`nsk'-70)/((`nsk'-2)*(`nsk'+5)) * ((`nsk'+1)/(`nsk'+7)) * ((`nsk'+3)/(`nsk'+9))
            local w2 = -1 + sqrt(2*(`beta' - 1))
            local delta = 1 / sqrt(log(sqrt(`w2')))
            local alfa = sqrt(2/(`w2' - 1))
            mat `vy' = `skew' * sqrt((`nsk'+1)*(`nsk'+3)/(6*(`nsk'-2))) / `alfa'
*           vy = delta * log(vy + sqrt(vy .^ 2 + 1))
            matmap `vy' `vy2',map(@^2)
            mat `vy2'=`vy2'+`iota'
            matmap `vy2' `vys',map(@^0.5)
            mat `vys' = `vy' + `vys'
            matmap `vys' `lvy',map(log(@))
            mat `newskew' = `lvy' * `delta'
* kurtgam
            local delta = ((`nsk'+5)/(`nsk'-3)) * ((`nsk'+7)/(`nsk'+1)) / (6*( `nsk2'+15*`nsk'-4))
            local a = (`nsk'-2) * (`nsk2'+27*`nsk'-70) * `delta'
      local c = (`nsk'-7) * (`nsk2'+2*`nsk'-5) * `delta'
      local k = (`nsk'*`nsk2'+37*`nsk2'+11*`nsk'-313) * `delta' / 2
      local r = 1 + `c' / `k'
      local p = 3 * (`nsk'-1)/(`nsk'+1) - `r'
      *6*(`nsk'-2)/((`nsk'+1)*(`nsk'+3))
          matmap `skew' `vy2',map(@^2)
      mat `vz' = `c'*`vy2' +`a'*`iota'
*           kurt = (vKurt - 1 - vSkew .^ 2) * k * 2;
          mat `kurt2' = (`kurt' - `iota' - `vy2')*`k'*2
*     for (i = 0; i < columns(kurt); ++i)
*           kurt[0][i] = ( ((kurt[0][i] / (2 * vz[0][i])) ^ (1/3)) - 1 +
*            1/(9*vz[0][i])) * sqrt(9*vz[0][i]);
            mat `newkurt' = `kurt'
        local i 0
      while `i'<`nc' {
          local i = `i'+1
            mat `newkurt'[1,`i'] = ((( `kurt2'[1,`i'] / (2 * `vz'[1,`i'])) ^ (1/3)) -1 + 1/(9*`vz'[1,`i']))*sqrt(9*`vz'[1,`i'])
            }
      mat `omni' = `newskew'*`newskew'' + `newkurt'*`newkurt''
            mat `kurt' = `kurt' - 3*`iota'
            mat `omnia' = `N'/6 * `skew'*`skew'' + `N'/24 * `kurt'*`kurt''
      return scalar stat = `omni'[1,1]
      return scalar statasy = `omnia'[1,1]
      return scalar N = `N'
      return scalar k = `nc'
      return scalar df = 2*return(k)
      return scalar p = chiprob(return(df),return(stat))
      return scalar pasy = chiprob(return(df),return(statasy))
      di _n in gr "Omnibus normality statistic (",%2.0f return(k), "variables): " /*
      */ _col(43) in ye %10.4f return(stat) /*
      */ in gr " Prob > chi2(" in ye return(df) in gr ") = " in ye %6.4f return(p)
      di in gr "Asymptotic statistic: " /*
      */ _col(46) in ye %10.4f return(statasy) in gr " Prob > chi2(" in ye return(df) in gr ") = " in ye %6.4f return(pasy)
end
exit

