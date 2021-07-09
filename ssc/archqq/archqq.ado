* version 1.0 2008-02-18
* version 1.01 2008-02-24
*   Added support for GED distribution, table of moments and K-S, J-B type tests of distribution.
* version 1.02 2008-03-18
*   Fixed bug with negative fourth moment for t-distribution, added explenation why J-B
*   is not calculated wiht small df for t.
*! version 1.03 2008-03-25
*   Turn off calculation of J-B as default with other distributions than normal.
*   Added JB option to force calculation of J-B.
*! Sune.Karlsson@oru.se
*
*! Q-Q plots to diagnose distributional assumption for ARCH models
*


program define archqq, sortpreserve
version 9

syntax [varname(default=none numeric)] [if] [in] [, DISTribution(string) noGraph noTest JB]

if ( "`varlist'" == "" & "`e(cmd)'" != "arch" ) {
  di as err "archqq can only be run after arch or with a variable"
  exit 198
}

if ( "`distribution'" != "" ) {

  PrsDist `distribution'
  local dist `s(dist)'
  local distdf `s(df)'
  if "`dist'" == "t" {
    if "`distdf'" <= "2" {
      di in smcl as error   /*
  */ "degrees of freedom for Student's {it:t} distribution must be greater than 2"
      exit 198
    }
  }
  if "`dist'" == "ged" {
    if "`distdf'" <= "0" {
      di in smcl as error /*
  */ "shape parameter for generalized error distribution must be positive"
      exit 198
    }
  }

}
else if ( "`varlist'" != "" ) {
  // variable, default to normal
  local dist "gaussian"
}
else {
  // arch, guess from eret
  if ( "`e(tdf)'" != "" ) {
    local dist "t"
    local distdf = e(tdf)
  } 
  else if ( "`e(shape)'" != "" ) {
    local dist "ged"
    local distdf = e(shape)
  }
  else {
    local dist "gaussian"
  }
}

if ( "`varlist'" == "" ) {
  // arch get standardized residuals
  
  tempvar testvar h
  if  "`if'" == "" & "`in'" == "" {
    local if "if e(sample)"
  }
  quietly {
    predict `testvar' `if' `in', residuals
    predict `h' `if' `in', variance
    replace `testvar' = `testvar'/sqrt(`h')
    label var `testvar' "ARCH standardized residuals"
  }

}
else {
  // user supplied variable

  local testvar "`varlist'"
  
}

tempvar touse xvar Psubi
quietly {
  gen byte `touse' = !missing(`testvar') `if' `in'
  if ( "`graph'" == "" ) {
    sort `testvar'
    gen float `Psubi' = sum(`touse')
    replace `Psubi' = cond(`touse'>=.,.,`Psubi'/(`Psubi'[_N]+1))
  }
}

if ( "`varlist'" != "" ) {
  // use data mean and variance in Q-Q plot
  
  quietly: sum `testvar' if `touse'==1
  local mean = r(mean)
  local std  = r(sd)

}
else {
  // ARCH standardized errors has zero mean and unit variance
  
  local mean = 0
  local std  = 1
  
}
 
if ( "`dist'" == "gaussian" ) {
  
  if ( "`graph'" == "" ) quietly {
    gen float `xvar' = invnorm(`Psubi')*`std' + `mean'
    label var `xvar' "Inverse Normal"
  }
  
  if ( "`test'" == "" ) {

    local tmean = `mean'
    local tvar  = `std'^2
    local tskew = 0
    local tkurt = 3
    local t6    = 15
    local t8    = 105
    local assumed "Normal"
    tempvar uni
    quietly: gen `uni' = normal((`testvar'-`mean')/`std')
    
  }
    
}
else if ( "`dist'" == "t" ) {
  
  if ( int(`distdf') != `distdf' ) {
    local ddf = string(`distdf',"%9.2f")
  } 
  else {
    local ddf = `distdf'
  }

  if ( "`graph'" == "" ) quietly {  
    gen float `xvar' = invttail(`distdf',1-`Psubi')*sqrt((`distdf'-2)/`distdf')*`std' + `mean'
    label var `xvar' "Inverse t(`ddf')"
  }

  if ( "`test'" == "" ) {

    local tmean = `mean'
    local tvar  = `std'^2
    local tskew = 0
    local tkurt = 3*(`distdf'-2)/(`distdf'-4)
    if ( `distdf' <= 4 ) local tkurt = .
    local t6    = `tkurt'*5*(`distdf'-2)/(`distdf'-6)
    if ( `distdf' <= 6 ) local t6 = .
    local t8    = `t6'*7*(`distdf'-2)/(`distdf'-8)
    if ( `distdf' <= 8 ) local t8 = .

    local assumed "t(`ddf')"

    tempvar uni
    quietly: gen `uni' = 1-ttail(`distdf',(`testvar'-`mean')*sqrt(`distdf'/(`distdf'-2))/`std')
    
  }

}
else if ( "`dist'" == "ged" ) {
  // use that if x ~ GED, then y = (1/2)*abs(x/lambda)^distdf ~ Gamma(1/distdf)

  if ( int(`distdf') != `distdf' ) {
    local ddf = string(`distdf',"%9.2f")
  } 
  else {
    local ddf = `distdf'
  }
  local gammadf = 1/`distdf'
  local lambda2v = exp((lngamma(`gammadf')-lngamma(3*`gammadf'))/2)
  local lambda   = `lambda2v'/2^(`gammadf')

  if ( "`graph'" == "" ) quietly {  
    // percentiles of Gamma(gammadf)
    // negative of Gamma for Percentiles < =.5 and reverse order
    gen float `xvar' = -invgammap(`gammadf',1-2*`Psubi') if `Psubi' < 0.5
    // positive for percentiles >= 0.5
    replace `xvar' = invgammap(`gammadf',2*`Psubi'-1) if `Psubi' >= 0.5

    // transform to GED and scale if required
    replace `xvar' = -`lambda2v'*abs(`xvar')^(`gammadf') if `xvar' < 0
    replace `xvar' = `lambda2v'*`xvar'^(`gammadf') if `xvar' >= 0
    replace `xvar' = `xvar'*`std' + `mean'
    label var `xvar' "GED(`ddf')"
  }
  
  
  if ( "`test'" == "" ) {

    local tmean = `mean'
    local tvar  = `std'^2
    local tskew = 0
    local tkurt = exp(lngamma(`gammadf')+lngamma(5*`gammadf')-2*lngamma(3*`gammadf'))
    local t6    = exp(2*lngamma(`gammadf')+lngamma(7*`gammadf')-3*lngamma(3*`gammadf'))
    local t8    = exp(3*lngamma(`gammadf')+lngamma(9*`gammadf')-4*lngamma(3*`gammadf'))

    local assumed "GED(`ddf')"

    tempvar uni
    quietly {
      gen `uni' = (abs((`testvar'-`mean')/(`std'*`lambda'))^`distdf')/2
      replace `uni' = (1-gammap(`gammadf',`uni'))/2 if `testvar' < `mean'
      replace `uni' = 0.5 + gammap(`gammadf',`uni')/2 if `testvar' >= `mean'
    }

  }
  
}
else {
  // shouldn't happen
  
  di as error "Invalid distribution option `distribution'"
  exit 198
  
}

local yttl : var label `testvar'
if ( "`yttl'" == "" ) local yttl "`testvar'"

if ( "`graph'" == "" ) {

  local xttl : var label `xvar'
  local fmt : format `testvar'
  format `fmt' `xvar'

    graph twoway     ///
    (scatter `testvar' `xvar',     ///
      sort        ///
      ytitle(`"`yttl'"')    ///
      xtitle(`"`xttl'"')    ///
    )         ///
    (function y=x,        ///
      range(`xvar')      ///
      n(2)        ///
      lstyle(refline)     ///
      yvarlabel("Reference")    ///
      yvarformat(`fmt')   ///
    )        

  }
  
if ( "`test'" == "" ) {

  quietly sum `testvar' if `touse'==1, detail
  local dmean = r(mean)
  local dvar  = r(Var)
  local dskew = r(skewness)
  local dkurt = r(kurtosis)
  local nobs  = r(N)
  
  local yttl = abbrev("`yttl'", 15)
  local c1 = 25-length("`yttl'")
  local c2 = 40-length("`assumed'")
  
  di as text _n _col(16) "Data and assumed moments" _n _col(`c1') "`yttl'" _col(`c2') "`assumed'" _n "{hline 40}"
  di as text "Mean"     _col(15) as result %10.4g `dmean' _col(30) %10.4g `tmean'
  di as text "Variance" _col(15) as result %10.4g `dvar'  _col(30) %10.4g `tvar'
  di as text "Skewness" _col(15) as result %10.4g `dskew' _col(30) %10.4g `tskew'
  di as text "Kurtosis" _col(15) as result %10.4g `dkurt' _col(30) %10.4g `tkurt'
  di as text "{hline 40}"

  quietly: ksmirnov `uni' = `uni'
  di as text _n "Kolmogorov-Smirnov test of H0: `assumed'"
  di as text "K-S: " as result %4.3f r(D) ///
     as text " p-value: " as result %4.3f r(p)

  if ( "`dist'" == "gaussian" || "`jb'" == "jb" ) {

    local v     = `t6'-`tkurt'^2
    local sktst = `nobs'*(`dskew')^2/`v'
    local skp   = chi2tail(1,`sktst')
    local v     = `t8'-(`tkurt')^2-(`t6'-`tkurt')^2/(`tkurt'-1)
    local kutst = `nobs'*(`dkurt'-3)^2/`v'
    local kup   = chi2tail(1,`kutst')
    local ctst  = `sktst'+`kutst'
    local cp    = chi2tail(2,`ctst')
    di as text _n "Jarque-Bera type tests of H0: `assumed'"
    di as text "Moment" _col(15) "Chi^2" _col(22) "df" _col(26) "p-value" _n "{hline 33}"
    di as text "Skewness" as result _col(10) %10.4g `sktst' _col(23) "1" _col(28) %4.3f `skp'
    di as text "Kurtosis" as result _col(10) %10.4g `kutst' _col(23) "1" _col(28) %4.3f `kup'
    di as text "Combined" as result _col(10) %10.4g `ctst'  _col(23) "2" _col(28) %4.3f `cp'
    di as text "{hline 33}"
    if ( `t6' == . ) {
      di as text "Tests could not be calculated because" _n "sixth moment does not exist"
    }
    else  if ( `t8' == . ) {
      di as text "Kurtosis and combined test could not be calculated" _n "because eigth moment does not exist"
    }

  }
  
}

end

/////////////////////////////
// borrowed from arch.ado
/////////////////////////////
program PrsDist, sclass

  local input `0'
  
  local udist : word 1 of `input'
  

  if strmatch(`"`udist'"',    /*
    */ substr("gaussian", 1, max(3,length(`"`udist'"')))) {
    local dist "gaussian"
  }
  else if strmatch(`"`udist'"',     /*
    */ substr("normal", 1, max(3,length(`"`udist'"')))) {
    local dist "gaussian"
  }
  else if strmatch(`"`udist'"', "ged") {
    local dist "ged"
  }
  else if strmatch(`"`udist'"', "t") {
    local dist "t"
  }
  else if `"`udist'"' == "" {
    local dist "gaussian"   // default
  }
  else {
    di in smcl as error /*
      */ "invalid distribution in {cmd:distribution()}"
    exit 198
  }
  
  local udf : word 2 of `input'

  if "`udf'" != "" { 
    if "`dist'" == "gaussian" {
      di as error /*
*/ "cannot specify degrees of freedom or shape parameter with Gaussian errors"
      exit 198
    }
    capture confirm number `udf'
    if _rc {
      if "`dist'" == "t" {
        di in smcl as error /*
*/ "invalid degrees of freedom in {cmd:distribution()}"
      }
      else if "`dist'" == "ged" {
        di in smcl as error /*
*/ "invalid shape parameter in {cmd:distribution()}"
      }
      exit _rc
    }
  }

  sreturn local dist `dist'
  sreturn local df `udf'

end
