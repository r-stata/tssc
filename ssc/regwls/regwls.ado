*! regwls v.1.0.0 | By Dany Bahar | 19May2014
*! Builds on wls0.ado, and incorporates support for factor variables and areg
*! based on two-step heteroscedastic regression in 4th edition of Greene

cap prog drop regwls
program define regwls
version 10.1

syntax varlist(fv) [if] [in], WVars(varlist)  Type(string) [NOConst ROBust hc2 hc3 GRaph] [Absorb(varlist max=1)]
local cmdline "regwls `0'"
di "`cmdline'"

local typerr = 0
if "`type'"~="abse" & "`type'"~="e2" & "`type'"~="loge2" & "`type'"~="xb2" {
  local typerr = 1
}

if `typerr' {
  display
  display in red "Error: WLS type must be one of the following:"
  display in red "       abse  - absolute value of residual"
  display in red "       e2    - residual squared"
  display in red "       loge2 - log residual squa"
  display in red "       xb2   - fitted value squared"
  exit
}

capture drop _wls_wgt _wls_res
tempvar p1 p2 p3 e grp bsd ee


if "`absorb'"=="" {
  quietly regress `varlist' `if' `in'
}
else {
  quietly areg `varlist' `if' `in', a(`absorb')
}


quietly predict `p3'
quietly predict `e', resid

if "`type'"=="abse" { 
  generate `ee' = abs(`e') 
  local eetype " type: proportional to abs(e)"
}
if "`type'"=="e2" { 
  generate `ee' = (`e')^2 
  local eetype " type: proportional to e^2"
}
if "`type'"=="loge2" { 
  generate `ee' = log((`e')^2 )
  local eetype " type: proportional to log(e)^2 "
}
if "`type'"=="xb2" {
  quietly replace `p3' = (`p3')^2
  local eetype " type: proportional to xb^2 "
}

if "`type'"~="xb2" {
  quietly regress `ee' `wvars', `noconst'
  quietly predict `p1'
} 
else {
  quietly regress `p3' `wvars', `noconst'
  quietly predict `p1'
}

generate _wls_wgt = 1/(`p1'^2)

label variable _wls_wgt "wls weights"

display
display in green "WLS regression - `eetype'"
display

if "`absorb'"=="" {
  regress `varlist' `if' `in' [aw = _wls_wgt], `robust' `hc2' `hc3'
}
else {
  areg `varlist' `if' `in' [aw = _wls_wgt], `robust' `hc2' `hc3' a(`absorb')
}


quietly predict _wls_res, resid
quietly predict `p2'
label variable _wls_res "wls residuals"
quietly replace _wls_res = _wls_res*_wls_wgt
if "`graph'" != "" {
  graph twoway scatter _wls_res `p2', yline(0) 
}
end
