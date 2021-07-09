* version 1.0 2008-01-22
* version 1.01, 2008-02-11
*   Fixed display of info about ARCH-robust Q-stat
* version 1.02, 2008-02-13
*   Turn on printout of table when nograph is specified
*! version 1.03, 2008-02-18
*   Fixed display of info about ARCH-robust Q-stat
*! Sune.Karlsson@oru.se
*
*! Correlation diagnostics for ARMA, ARCH and reg
*
* A lot of the code is stolen from corrgram
* and some borrowed from ac

program define armadiag
/*
   -ac- requires

   1.  N >= 2,

   2.  lags() <= N - 1.

   -pac- requires

   1.  N >= 6,

   2.  lags() <= int(N/2) - 2.

   If lags() not specified, by default lags() = max(1, min(int(N/2) - 2, 40)).
*/

version 9

syntax [varname(ts default=none numeric)] [if] [in] ///
  [, Arch Dfc(integer -999) Hetrobust LAGs(integer -999) LEVel(cilevel) YW ///
  noGraph Table LINscale FORCE ]

if "`arch'" != "" & "`hetrobust'" != "" {
  di as err "Option hetrobust not available with arch"
  exit 498
}

if `dfc' != -999 {
  local dfcnote "Q-stat d.f. corrected by `dfc'"
}

if ( "`graph'" == "nograph" ) local table "table"

// find out if we are to use ARMA, REGRESS or ARCH results or variable
if "`varlist'" == "" {
  // See if previous estimates is something we understant

  tempname dfcorr nlags
  scalar `dfcorr' = 0
  scalar `nlags'  = 0
  
  if "`e(cmd)'" == "arima" {
    // ARIMA, get residuals and find number of AR and MA terms
    
    tempvar testvar
    if  "`if'" == "" & "`in'" == "" {
      local if "if e(sample)"
    }
    quietly : predict `testvar' `if' `in', residuals
    label var `testvar' "ARMA residuals"
    if `dfc' == -999 {
      local dfc = 0
      if ( "`arch'" == "" ) {
        // find the number of ARMA terms
        CountTerms "ARMA" `dfcorr'
        // find the number of lagged dep vars, if someone is perverse enough
        // to use that
        CountLaggedDepVar `nlags'
        local dfc = `dfcorr' + `nlags'
        local dfcnote "Q-stat d.f. corrected for `dfc' ARMA parameters"
      }
    }

  } 
  else if "`e(cmd)'" == "arch" {
    // arch, get standardized residuals

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
    if `dfc' == -999 {
      local dfc = 0
      if ( "`arch'" == "" ) {
        // find the number of ARMA terms
        CountTerms "ARMA" `dfcorr'
        // find the number of lagged dep vars
        CountLaggedDepVar `nlags'
        local dfc = `dfcorr' + `nlags'
        local dfcnote "Q-stat d.f. corrected for `dfc' ARMA parameters"
      }
      else {
        // find the number of ARCH terms
        CountTerms "ARCH" `dfcorr'
        local dfc = `dfcorr'
        local dfcnote "Q-stat d.f. corrected for `dfc' ARCH parameters"
      }
    }
    
  }
  else if "`e(cmd)'" == "regress" {
    // regression, get residuals and find number of lags of dep var
    
    tempvar testvar
    if  "`if'" == "" & "`in'" == "" {
      local if "if e(sample)"
    }
    quietly : predict `testvar' `if' `in', residuals
    label var `testvar' "regression residuals"
    if `dfc' == -999 {
      local dfc = 0
      if ( "`arch'" == "" ) {
        * find the number of lagged dep vars
        CountLaggedDepVar `nlags'
        local dfc = `nlags'
        local dfcnote "Q-stat d.f. corrected for `dfc' lags of dep var"
      }
    }

  }
  else if "`e(cmd)'" != "" & "`force'" == "force" {

    local cmd = "`e(cmd)'"
    tempvar testvar
    if  "`if'" == "" & "`in'" == "" {
      local if "if e(sample)"
    }
    capture {
      quietly : predict `testvar' `if' `in', residuals
    }
    if ( _rc > 0 ) {
      local rc = _rc
      di as err "`cmd' does not support 'predict  , residuals', return code was `rc'"
      exit 498
    }
    label var `testvar' "`cmd' residuals"
    local warning "residuals from unknown command '`cmd'', properties unknown"
    if `dfc' == -999 {
      local dfc = 0
    }

  }
  else {

    di as err "armadiag can only be run after arch, arima, regress or with a variable"
    di as err "try FORCE at your own risk"
    exit 498

  }
    
} 
else {
  // diagnostics for variable
  
  tempvar testvar
  quietly: gen `testvar' = `varlist'
  label var `testvar' `"`varlist'"'
  if `dfc' == -999 {
    local dfc = 0
  }

}

if "`arch'" == "arch" {
  // diagnostics for conditional heteroskedasticity
  // square testvar
  
  local yttl : var label `testvar'
  quietly: replace `testvar' = `testvar'^2
  label var `testvar' `"Square of `yttl'"'

}

local ttl : var label `testvar'
local ttl `"Diagnostics for `ttl'"'

marksample touse
_ts tvar panelvar `if' `in', sort onepanel
markout `touse' `tvar' `testvar'
quietly: sum(`touse')
tempname nobs
scalar `nobs' = r(sum)

// this is almost straight from corrgram except that we set version to 9
// and skip the vv stuff

* local vv : display "version " string(_caller()) ":"

quietly {
  marksample touse
  markout `touse' `tvar'
  count if `touse'
  local n = r(N)

  if `lags' == -999 {
    local lags = max(1,min(int(`n'/2)-2,40))
  }
  else if `lags' >= `n' {
    di as err "lags() too large; must be less than " `n'
    exit 498
  }
  else if `lags' <= 0 {
    di as err "lags() must be greater than zero"
    exit 498
  }

  tsreport if `touse' & `testvar'< .

  if r(N_gaps) > 0 {
    if r(N_gaps) > 1 {
      noi di as text "(note: time series has " r(N_gaps) " gaps)"
    }
    else  noi di as text "(note: time series has 1 gap)"
  }

  tempvar ac pac q

*   `vv' ac `testvar' if `touse', lags(`lags') gen(`ac') nograph
  ac `testvar' if `touse', lags(`lags') gen(`ac') nograph
  if "`hetrobust'" == "hetrobust" {
    // Correction for arch ala Milhoj and Diebold
    // use r(i)^2/(1+lambda(i)/s^4) in Q-stat instead of r(i)^2
    // lambda is autocovariance for square of variable
    // s^2 is variance of variable
    tempvar acsq tvarsq
    sum `testvar' if `touse'
    // dividing by r(Var) standardizes so we don't need to
    // divide autocovariances by the square of the variance
    gen double `tvarsq' = (`testvar'-r(mean))^2/r(Var) if `touse'
    sum `tvarsq'
    local var = r(Var)
    ac `tvarsq' if `touse', lags(`lags') gen(`acsq') nograph
    // multipy autocorrelation by variance to get autocovariance
    gen double `q' = `n'*(`n'+2)*sum(`ac'^2/((`n'-_n)*(1+`var'*`acsq'))) in 1/`lags' if `ac'< .
    local robnote "ARCH-robust Q-statistics"
  }
  else {
    gen double `q' = `n'*(`n'+2)*sum(`ac'^2/(`n'-_n)) in 1/`lags' if `ac'< .
  }
  
  if `lags' > int(`n'/2) - 2 {
    local plags = int(`n'/2) - 2
  }
  else  local plags `lags'

  if `plags' > 0 {
*     `vv' pac `testvar' if `touse', lags(`plags') /*
*     */ gen(`pac') nograph `yw'
    pac `testvar' if `touse', lags(`plags') gen(`pac') nograph `yw'
  }
  else  gen byte `pac' = . in 1

}

// Now we do the p-values with corrected df
  
tempvar pval df
quietly: gen `df' = _n-`dfc' in 1/`lags'
quietly: gen `pval' = chi2tail(`df',`q') in 1/`lags' if `q' < .


if "`table'"=="table" {
  // print out results
  
  di as text _n `"`ttl'"'
  if "`dfcnote'" != "" {
    di "`dfcnote'"
  }
  if "`robnote'" != "" di "`robnote'"
  if "`warning'" != "" {
    noi di"`warning'"
  }
  di _col(43) "-1       0       1 -1       0       1"               ///
    _n " LAG       AC       PAC      Q     Prob>Q"        ///
    "  [Autocorrelation]  [Partial Autocor]"              ///
    _n "{hline 79}"
  local i 1
  while `i' <= `lags' {
    DispLine `i' `dfc' `ac'[`i'] `pac'[`i'] `q'[`i'] `pval'[`i']
    local i = `i'+1
  }

}
  
if "`graph'" == "" {
  // Produce plot of results
  
  local xlab "minmax"
  local xx = `lags'/10
  local xx = ceil(`xx'/5)*5
  local x = `xx'
  while `x' < `lags'-`xx'/2 {
    local xlab "`xlab' `x'"
    local x = `x'+`xx'
  }

  // The AC plot
  tempvar obs se pci nci
  tempname zz acgraph pacgraph pvalgraph vargraph pvlab
  quietly {
    gen long `obs' = _n in 1/`lags'
    label var `obs' "Lags"
    gen `se' = sqrt((1 + 2*sum(`ac'^2))/`nobs')
    gen `pci' = `se'[_n-1]
    replace `pci' = 1/sqrt(`nobs') in 1
    scalar `zz' = invnorm((100+`level')/200)
    replace `pci' = `zz'*`pci'
    gen `nci' = -`pci'
  }
  local note `"Bartlett's formula for MA(q) `=strsubdp("`level'")'% confidence bands"'
  label var `ac' "Autocorrelations"
  local yttl : var label `ac'
  twoway (rarea `nci' `pci' `obs' in 1/`lags',                  /// CI bands
          sort pstyle(ci) yticks(0, grid gmin gmax notick )     ///
          ytitle("") legend(nodraw) note(`"`note'"')            ///
          xscale(range(1 `lags')) xlabel(none)                  ///
         )                                                      ///
         (dropline `ac' `obs' in 1/`lags',                      /// AC
          pstyle(p1) yscale(range(-1 1)) ymtick(-1(0.2)1, grid) ///
          ylabel(-0.8(0.4)0.8, angle(0) nogrid) ytitle("")      ///
          xscale(range(1 `lags')) xlabel(`xlab')                ///
         ),                                                     ///
         name(`acgraph') nodraw title(`"`yttl'"')

  // The PAC plot
  quietly {
    replace `pci' = `zz'*sqrt(1/`nobs') in 1/`lags'
    replace `nci' = -`pci'
  }
  label var `pac' "Partial Autocorrelations"
  local yttl : var label `pac'
  twoway (rarea `nci' `pci' `obs' in 1/`lags',                  /// CI bands
          sort pstyle(ci) yticks(0, grid gmin gmax notick)      ///
          ytitle("") legend(nodraw)                             ///
          xscale(range(1 `lags')) xlabel(none)                  ///
         )                                                      ///
         (dropline `pac' `obs' in 1/`lags',                     /// PAC
          pstyle(p1) yscale(range(-1 1)) ymtick(-1(0.2)1, grid) ///
          ylabel(-0.8(0.4)0.8, angle(0) nogrid) ytitle("")      ///
          xscale(range(1 `lags')) xlabel(`xlab')                ///
         ),                                                     ///
         name(`pacgraph') nodraw title(`"`yttl'"')

  // The p-value plot
  label var `pval' "P-values for Q-statistics"
  if "`linscale'" == "linscale" {
    local pvopts "yscale(range(0 1)) yline(0.025 0.05 0.1) ylabel(0(0.1)1, angle(0))"  
  }
  else {
    local mult = 400
    local offset = 10
    local mult2 = 800 //int(exp(log(`offset'+`mult'*0.25)-log(`offset'))/0.025)
    quietly {
      replace `pval' = `mult2'*`pval' if `pval' >= 0.025
      replace `pval' = `mult'*`pval' + `offset' if `pval' < 0.025
    }
    local max = `mult2'
    local labdef `"`offset' "0""'
    foreach z in 0.025 0.05 0.1 0.2 0.4 0.8 {
      local x = `z'*`mult2' //+`offset'
      if `z' < 0.2 local yline "`yline' `x'"
      local labdef `"`labdef' `x' "`z'""'
    }
    local pvopts ///
      `"yscale(range(`offset' `max')) yline(`yline') yscale(log) ylabel( `labdef', angle(0) )"' 
  }
  local yttl : var label `pval'
  if ( "`dfcnote'" != "" ) {
    local pvnote `""`dfcnote'" "`robnote'""'
  }
  else {
    local pvnote `""`robnote'""'
  }
  twoway  (dropline `pval' `obs' in 1/`lags', ///
           pstyle(p1) `pvopts' xscale(range(1 `lags')) xlabel(`xlab') ytitle("")   ///
          ), name(`pvalgraph') nodraw note(`pvnote') title(`"`yttl'"')

  // The variable plot
  local yttl : var label `testvar'
  twoway (tsline `testvar', ylabel(,angle(0)) ytitle("") xtitle("")) if `touse',  ///
          name(`vargraph') title(`"`yttl'"') nodraw

  // Combine graphs
  graph combine `vargraph' `acgraph' `pvalgraph' `pacgraph', title(`"`ttl'"') note( `"`warning'"' )
  graph drop `vargraph' `acgraph' `pvalgraph' `pacgraph'  
    
}

end

program define DispLine
  args lag dfc ac pac q pval

  MkString `ac'
  local sac `"`r(string)'"'
  MkString `pac'
  local spac `"`r(string)'"'

  if `lag' > `dfc' {
    di as text %-6.0g `lag' as res /*
      */ _col(9)  %7.4f `ac' /*
      */ _col(18) %7.4f `pac' /*
      */ _col(27) %7.0g `q' /*
      */ _col(36) %6.4f `pval' /*
      */ _col(44) `"`sac'"' /*
      */ _col(63) `"`spac'"'
  }
  else {
    di as text %-6.0g `lag' as res /*
      */ _col(9)  %7.4f `ac' /*
      */ _col(18) %7.4f `pac' /*
      */ _col(27) %7.0g `q' /*
      */ _col(44) `"`sac'"' /*
      */ _col(63) `"`spac'"'
  }
end

program define MkString, rclass
  args corr /* corr = ac  or  corr = pac */
  if `corr'>=. {
    exit
  }

  if `corr' >= 0 {
    local vb = 9
    local ve = int(8*`corr') + `vb'
  }
  else {
    local ve = 9
    local vb = int(8*`corr') + `ve'
  }
  local k 1
  while `k' <= 17 {
    local char " "
    if `vb' <= `k' & `k' <= `ve' {
      local char "{hline 1}"
    }
    if `k'==9 { 
      if `vb' == 9 & `ve' == 9 {
        local char "{c |}"
      }
      if `vb' == 9 & `ve' > 9 {
        local char "{c LT}"
      }
      if `vb' < 9 & `ve' == 9 {
        local char "{c RT}"
      }
    } 
    local s `"`s'`char'"'
    local k = `k' + 1
  }
  ret local string `"`s'"'

end

program define CountLaggedDepVar

  args nlags

  local dfc = 0
  local depvar  "`e(depvar)'"
  // extract variable name if ts operators have been used
  local test = regexm( "`depvar'", "^(D[0-9]*|L[0-9]*)\.(.+)$" )
  if `test' == 1 {
    local depvar = regexs(2)
  } 
  // count occurrences in exp var list allowing for ts operators
  local parnames : colfullnames e(b)
  foreach name of local parnames {
    if regexm( "`name'", "(^|:)L*[0-9]*D*[0-9]*\.`depvar'$" ) { 
      local dfc = `dfc' + 1
    }
  }

  scalar `nlags' = `dfc'
  
end

program define CountTerms

  args term nterms
  
  local dfc = 0

  local parnames : colfullnames e(b)
  // count occurrences of ARMA terms in parameter list
  foreach name of local parnames {
    if regexm( "`name'", "^`term'[0-9]*:(.+)$" ) { 
      local pnam = regexs(1)
      if `"`pnam'"' != "_cons" {
        local dfc = `dfc' + 1
      }
    }
  }

  scalar `nterms' = `dfc'

end

exit
----+----1----+----2----+----3----+----4----+----5----+----6----+----7----+----8

                                          -1       0       1 -1       0       1
 LAG       AC       PAC      Q     Prob>Q  [Autocorrelation]  [Partial Autocor]
######  S#.####  S#.####  ####### S#.####  AAAAAAAAAAAAAAAAA  AAAAAAAAAAAAAAAAA
 %6.0g   %6.4f    %6.4f    %7.0g   %6.4f         %17s                 %17s
