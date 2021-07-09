*! version 2.1.0 JMGarrett 30Aug04
/* Program to calculate predictions for linear or logistic regression */
/* Form:  predcalc y, xvar(x1=# x2=# ...) options                     */
/* Options required: xvar( )                                          */
/* Options allowed:  model, level                                     */
/* (30Aug04 -- added cluster option)                                  */

program define predcalc
  version 6.0
  #delimit ;
    syntax varname (min=1 max=1) [if] [in] [pweight], Xvar(string) 
     [Model Level(real 95) LINear CLuster(string)] ;
  #delimit cr
  marksample touse
  markout `touse'
  tokenize "`varlist'"
  preserve
  quietly keep if `touse'
  local yvar "`1'"
  capture assert `yvar'==1 | `yvar'==0
  if _rc==0 {local regtype "log"}
  if _rc~=0 | "`linear'"=="linear" {local regtype "lin"}

* Store values for X variables to use for prediction
  tokenize "`xvar'"  
  local numx 0
  local i 1
  while "`1'"~="" {
    local equal=index("`1'","=")
    local x`i'=substr("`1'",1,`equal'-1)
    quietly drop if `x`i''==.
    local valx`i'=substr("`1'",`equal'+1,length("`1'"))
    local xlist `xlist' `x`i''
    local xdisp `xdisp' `1'
    local i=`i'+1
    macro shift
    local numx=`i'-1
    }
  keep `yvar' `xlist' `cluster'
  local n=_N

* Run models
  if "`regtype'"=="lin" {
     if "`model'"~="model"  {quietly reg `yvar' `xlist', cluster(`cluster')}
     if "`model'"=="model"  {reg `yvar' `xlist', cluster(`cluster')}
     }
  if "`regtype'"=="log" {
     if "`model'"~="model"  {quietly logistic `yvar' `xlist', clus(`cluster')}
     if "`model'"=="model"  {logistic `yvar' `xlist', cluster(`cluster')}
     }
  local varlbly : variable label `yvar'

* Keep 1 observation and replace values with stored X values
  local numobs=e(N)
  quietly keep if _n==1
  keep `yvar'
  quietly replace `yvar'=.
  local i 1
  while `i'<=`numx'  {
    quietly gen `x`i''=`valx`i''
    local i=`i'+1
    }

* Calculate the predicted values and confidence intervals
  tempvar linpred
  if "`regtype'"=="lin"  {predict predval, xb}
  if "`regtype'"=="log"  {predict predval, p}
  local predval=predval
  predict se, stdp
  predict `linpred', xb
  local z=invnorm((1-`level'/100)/2)
  if "`regtype'"=="lin"  {
     local lower=`linpred'+`z'*se
     local upper=`linpred'-`z'*se
     }
  if "`regtype'"=="log"  {
     local upper=1/(1+exp(-`linpred'+`z'*se))
     local lower=1/(1+exp(-`linpred'-`z'*se))
     }

* Display the results
  if "`regtype'"=="lin" {
    disp _n(1) in gr "Model:" in bl "     Linear Regression"
    }
  if "`regtype'"=="log" {
     disp _n(1) in gr "Model:" in bl "     Logistic Regression"
     }
  disp in gr "Outcome:" in yel "   `varlbly' -- $S_E_depv"
  disp in gr "X Values:  " in yel "`xdisp'"
  if "`cluster'"~="" {disp in gr "Cluster:   " in yel "`cluster'"}
  disp in gr "Num. Obs:  " in yel `numobs'
  disp _n(1) in gr "Predicted Value and `level'% CI for " in yel "`yvar'" in gr ":"
  disp "  "
  if `predval'<=1 {
    #delimit ;
      disp "    " %6.4f `predval' in gr "  (" in yel %6.4f `lower' in gr", " 
        in yel %6.4f `upper' in gr")";
    #delimit cr
    }
  if `predval'>1 {
    #delimit ;
      disp "    " %7.2f `predval' in gr "  (" in yel %7.2f `lower' in gr", " 
        in yel %7.2f `upper' in gr")";
    #delimit cr
    }
end
