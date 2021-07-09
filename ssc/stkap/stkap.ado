*! version 3.0.2  JMGarrett 18Oct03
/* Graph adjusted Kaplan-Meier survivor function by categories of X        */
/* Form: stkap, by(xvars) adj(covariates) options                          */
/* Must have stset data before using this command                          */ 

program define stkap
  version 8.0
  st_is 2 analysis
  syntax [if] [in], [BY(string) STRata(string) ADJust(string) *]
  marksample touse
  if "`strata'"~="" & "`adjust'"=="" {
     disp as error "strata() requires adjust(); perhaps you mean by()"
     exit
     }
  preserve
  local t: char _dta[st_bt]
  local d: char _dta[st_bd]
  local t0: char _dta[st_bt0]
  local id: char _dta[st_id]
  quietly keep if `touse'
  quietly drop if `t'==. | `d'==.

* If there are covariates, drop missing, center or use specified values
  tokenize "`adjust'"
  local numcov 0
  local i 1
  while "`1'"~="" {
    local equal=index("`1'","=")
    if `equal'==0  {
       local cov`i'="`1'"
       local mcov`i'="mean"
       }
    if `equal'~=0  {
       local cov`i'=substr("`1'",1,`equal'-1)
       local mcov`i'=substr("`1'",`equal'+1,length("`1'"))
       }
    quietly drop if `cov`i''==.
    local covlist `covlist' `cov`i''
    local i=`i'+1
    macro shift
    local numcov=`i'-1
    }
  local i 1
  while `i'<=`numcov' {
    if "`mcov`i''"=="mean" {
      quietly sum `cov`i''
      quietly replace `cov`i''=`cov`i''-_result(3)
      }
    if "`mcov`i''"~="mean" {
      quietly replace `cov`i''=`cov`i''-`mcov`i''
      }
    local i=`i'+1
    }

* Graph KM
  quietly streset
  if "`by'"=="" & "`strata'"=="" & `numcov'==0 {
     sts graph, ylabel(0(.2)1, angle(horizontal)) `options'
     }
  if "`by'"~="" & "`strata'"=="" & `numcov'==0 {
     sts graph, by(`by') ylabel(0(.2)1, angle(horizontal)) `options'
     }
  if "`by'"=="" & "`strata'"=="" & `numcov'>0 {
     sts graph, adjust(`covlist') ylabel(0(.2)1, angle(horizontal)) ///
       `options'
     }
  if "`by'"~="" & "`strata'"=="" & `numcov'>0 {
     sts graph, by(`by') adjust(`covlist')  /// 
       ylabel(0(.2)1, angle(horizontal)) `options'
     }
  if "`by'"=="" & "`strata'"~="" & `numcov'>0 {
     sts graph, strata(`strata') adjust(`covlist') ///
       ylabel(0(.2)1, angle(horizontal)) `options'
     }
end
