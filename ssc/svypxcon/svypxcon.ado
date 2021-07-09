*! version 1.1.1 JMGarrett 16May06
/*  Graphs predicted values for linear or logistic models for survey data  */
/*  Form:  svypxcon y, xvar(xvar) f(#) t(#) i(#) options                   */
/*  Options required: xvar(), from(#), to(#), inc(#)                       */
/*  Options allowed: poly, adjust, model, graph, nolist, linear, subpop    */
/*  Note:  X variable should be continuous (interval or ordinal)           */
/*  Updated for version 9.0                                                */

program define svypxcon
  version 9.0
  #delimit ;
    syntax varlist (min=1 max=1) [if] [in], Xvar(varlist)
        [From(real 0) To(real 0) Inc(real 1) Poly(real 0) CLass(string)
         MODel Adjust(string) NOList GRaph LINear Level(real 95) 
         SAVepred(string) SUBpop(string) * ] ;
  #delimit cr
  marksample touse
  markout `touse' `xvar'
  tokenize "`varlist'"
  preserve
  if `from'==0 & `to'==0 {
    disp _n(1) as error "Both " as result "from() " as error "and "  ///
      as result "to() " as error "must be specified"
      exit
      }
  quietly keep if `touse'
  local varlbly : variable label `1'
  local yvar "`1'"
  local varlblx : variable label `xvar'
  if "`poly'"~="0" {
    capture assert `poly'==2 | `poly'==3
    if _rc~=0 {
       disp as error "Error: Poly() option can only contain 2 or 3"
       exit
       }
    }
  capture assert `yvar'==1 | `yvar'==0
  if _rc==0 & "`linear'"=="linear" {
     local reg2cat "01"
     }
  if _rc==0 {
     local regtype="log"
     }
  if _rc~=0 | "`linear'"=="linear" {
     local regtype="lin"
     }
  if "`class'"~="" {
     local clvar="`class'"
     local clval : value label `clvar'
     quietly drop if `clvar'==.
     local varlblc: variable label `class'
     }

* Read in subpop variable if it is an option
  if "`subpop'"~=""  {
    local sub "subpop(`subpop')"
    }

* If there are covariates, drop missing values, calculate means
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
    local covdisp `covdisp' `1'
    local i=`i'+1
    macro shift
    local numcov=`i'-1
    }
  local i 1
  while `i'<=`numcov' {
    if "`mcov`i''"=="mean" {
      quietly sum `cov`i''
      local mcov`i'=r(mean)
      }
    local i=`i'+1
    }
  * keep `yvar' `xvar' `clvar' `covlist'
  local newn=_N

* If polynomial terms are requested, create them
  if `poly'==2  {
     gen x_sq=`xvar'^2
     local polylst="x_sq"
     }
  if `poly'==3  {
     gen x_sq=`xvar'^2
     gen x_cube=`xvar'^3
     local polylst="x_sq x_cube"
     }
 
* If there is a class variable, set up dummy variables and interactions
  if "`class'"~="" {
     quietly tab `clvar', gen(clss)
     local numcat=_result(2)
     local i 2
     while `i'<=`numcat' {
      *** New section allows interaction terms with polynomials
       quietly gen Xxclss`i'=`xvar' * clss`i'
       if `poly'==2 | `poly'==3 {
          quietly gen Xxclss`i'sq=x_sq * clss`i'
          }
       if `poly'==3 {
          quietly gen Xxclss`i'cb=x_cube * clss`i'
          }
       local clist `clist' clss`i'
       if `poly'==0 {
          local ilist `ilist' Xxclss`i'
          }
       if `poly'==2 {
          local ilist `ilist' Xxclss`i' Xxclss`i'sq
          }
       if `poly'==3 {
          local ilist `ilist' Xxclss`i' Xxclss`i'sq Xxclss`i'cb
          }
       local i=`i'+1
       }
     }

* Run regression models and test for interaction if class specified
  svyset
  if "`model'"~=""  {
    if "`regtype'"=="lin" {
      svy, `sub': regress `yvar' `xvar' `polylst' `covlist' `clist' `ilist' 
      more
      }
    if "`regtype'"=="log" {
      svy, `sub': logistic `yvar' `xvar' `polylst' `covlist' `clist' `ilist'
      more
      }
    }
  if "`model'"==""  {
    if "`regtype'"=="lin" {
      qui svy, `sub': regress `yvar' `xvar' `polylst' `covlist' `clist' `ilist'
      }
    if "`regtype'"=="log" {
      qui svy, `sub': logistic `yvar' `xvar' `polylst' `covlist' `clist' `ilist'
      }
    }
  if "`class'"~="" {
    quietly test `ilist'
    local df1=r(df)
    local df2=r(df_r)
    local f=r(F)
    local probf=r(p)
    }
  else {  
    * tests for x, x_sq, or x_cube
    if `poly'==0 {
       quietly test `xvar'
       }
    if `poly'==2 {
       quietly test x_sq
       }
    if `poly'==3 {
       quietly test x_cube
       }
    local df1=r(df)
    local df2=r(df_r)
    local f=r(F)
    local probf=r(p)
    }

* Save the sample n, pop n, and subpop n's
    if "`sub'"=="" {
       local sampn=e(N)
       local popn=round(e(N_pop),.1)
       }
    if "`sub'"~="" {
       local sampn=e(N_sub)
       local popn=round(e(N_subpop),.1)
       }

* If there is a class variable, retain values for later
  if "`class'"~="" {
     tempvar count
     quietly gen `count'=1
     sort `clvar'
     collapse `count', by(`clvar')
     local class1=`clvar'
     local i 2
       while `i'<=`numcat' {
         local class`i'=`clvar'[_n+`i'-1]
         local i=`i'+1
         }
     }

* Generate the values of x to calculate the predicted values
  drop _all
  local i `from'
  while `i'<`to'  {
    local i=`i'+`inc'
    }
  if `i'>`to'  {
    local to=`i'-`inc'
    }
  local newobs=((`to'-`from')/`inc')+1
  local newobs=round(`newobs',1)
  quietly range `xvar' `from' `to' `newobs'
  label var `xvar' "`varlblx'"
  if `poly'==2  {
     gen x_sq=`xvar'^2
     }
  if `poly'==3  {
     gen x_sq=`xvar'^2
     gen x_cube=`xvar'^3
     }
  local i=1
  while `i'<=`numcov'  {
    quietly gen `cov`i''=`mcov`i''
    local i=`i'+1
    }

* If interaction, expand data, create dummy and interaction variables
  if "`class'"~=""  {
     quietly expand `numcat'
     sort `xvar'
     quietly by `xvar': gen `clvar'=_n
     local i 1
     while `i'<=`numcat'  {
       quietly replace `clvar'=`class`i'' if `clvar'==`i'
       local i=`i'+1
       }
     quietly tab `clvar', gen(clss)
     local numcat=r(r)
     local i=2
     while `i'<=`numcat' {
    *** New section allows interaction terms with polynomials
      quietly gen Xxclss`i'=`xvar' * clss`i'
       if `poly'==2 | `poly'==3 {
          quietly gen Xxclss`i'sq=x_sq * clss`i'
          }
       if `poly'==3 {
          quietly gen Xxclss`i'cb=x_cube * clss`i'
          }
       local clist `clist' clss`i'
       if `poly'==0 {
          local ilist `ilist' Xxclss`i'
          }
       if `poly'==2 {
          local ilist `ilist' Xxclss`i' Xxclss`i'sq
          }
       if `poly'==3 {
          local ilist `ilist' Xxclss`i' Xxclss`i'sq Xxclss`i'cb
          }
       local i=`i'+1
       } 
     }

* Calculate the predicted values and confidence intervals
  if "`regtype'"=="log" {
     predict pred_y, p
     }
     else {
       predict pred_y, xb
       }
  predict se, stdp
  local z=invnorm((1-`level'/100)/2)
  if "`regtype'"=="lin" | "`regtype'"=="med" {
    gen lower=pred_y+`z'*se
    gen upper=pred_y-`z'*se
    }
  if "`regtype'"=="log"  {
    tempvar linpred
    predict `linpred', xb
    gen lower=1/(1+exp(-`linpred'-`z'*se))
    gen upper=1/(1+exp(-`linpred'+`z'*se))
    }

* Print results
  if "`class'"~="" {
     sort `clvar' `xvar'
     }
  display "  "
  if "`regtype'"=="lin" {
     disp as text "Predicted Values and `level'% Confidence Intervals"
     }
  if "`regtype'"=="log" {
     disp as text "Predicted Probabilities and `level'% Confidence Intervals"
     }
  display "  "

  if "`regtype'"=="lin" & "`reg2cat'"=="01" {
      disp "  "
       #delimit  ;
       disp as result "    Warning:" as text "  Y variable is coded as " 
          as result "0" as text " and " as result "1" as text  ". Perhaps" ;
       display as text "               you didn't mean to use the "
          as result "linear" as text " option" ;
       #delimit cr
      disp "  "
      }
     
  if "`regtype'"=="lin" {
    display as text "  Model Type:" as result "    Survey Linear Regression"
    }
  if "`regtype'"=="log" {
    display as text "  Model Type:" as result "    Survey Logistic Regression"
    }
  display as text "  Outcome:" as result "       `varlbly' -- $S_E_depv"
  display as text "  X Variable:" as result"    `varlblx' -- `xvar'"
  if "`class'"~="" {
     display as text "  Class:" as result "         `varlblc' -- `clvar'"
     display as text "  Interaction:" as result "   `xvar' by `clvar'"
     }
  if `poly'==2 | `poly'==3  {
     display as text "  Polynomials:" as result "   `polylst'"
     }
  if `numcov'>0 {
     display as text "  Covariates:" as result "    `covdisp'"
     }
  if `numcov'==0 {
     display as text "  Covariates:" as result "    (none)"
     }
  if "`sub'"=="" {
     display as text "  Sample N:      " as result `sampn'
     display as text "  Population N:  " as result `popn'
     }
  if "`sub'"~="" {
     display as text "  Sub Sample N:  " as result `sampn'
     display as text "  Sub Pop N:     " as result `popn'
     }
  disp "  "
  if "`class'"=="" & "`nolist'"=="" {
     list `xvar' pred lower upper, noob separator(0)
     }
  if "`class'"~="" & "`nolist'"=="" {
    by `clvar': list `xvar' pred lower upper, noob separator(0)
    }

  if "`class'"=="" {
     disp "  "
     if `poly'==0 {
         disp as text "  Wald test for" as result " `xvar'" ///
            as text ":"
         }
     if `poly'==2 {
         disp as text "  Wald test for" as result " x_sq" ///
            as text ":"
         }
     if `poly'==3 {
         disp as text "  Wald test for" as result " x_cube" ///
            as text ":"
         }
     disp "  "
     disp as text "    F(`df1', `df2') =  " as result %6.2f `f'
     if `probf'>=.0001 {
        disp as text "    Prob > F  =  " as result %7.4f `probf'
        }
     if `probf'<.0001 {
        disp as text "    Prob > F   < " as result "0.0001"
        }
    }   

  if "`class'"~="" {
     disp "  "
     #delimit ;
       disp as text "  Wald test for interaction of"
        as result " `xvar' * `class'" as text ":";
     #delimit cr
     disp "  "
     disp as text "    F(`df1', `df2') =  " as result %6.2f `f'
     if `probf'>=.0001 {
       disp as text "    Prob > F   = " as result %7.4f `probf'
       }
     if `probf'<.0001 {
       disp as text "    Prob > F   < " as result "0.0001"
       }
    }

* Save results if requested
  if "`savepred'"~="" {
    keep `clvar' `xvar' pred_y se lower upper
    tempfile tempprd
    quietly save `tempprd'
    }

* Graph results if requested
  
  if "`graph'"~=""  {
    if "`varlbly'"=="" {
       local ytitle "for $S_E_depv"
       }
    if "`varlbly'"~="" {
       local ytitle "for `varlbly'"
       }
    if "`varlblx'"=="" {
       local xtitle "`xvar'"
       }
    if "`varlblx'"~="" {
       local xtitle "`varlblx'"
       }
      if "`poly'"=="2" {
         local xtitle "`xtitle'  (quadratic)"
         }
      if "`poly'"=="3" {
        local xtitle "`xtitle'  (cubic)"
        }
    if "`class'"=="" {
       if "`varlblc'"=="" {
          local leg 'clvar'
          }
       if "`varlblc'"~="" {
          local leg `varlblc'
          }
       if "`regtype'"=="lin" {
          local l2title "Predicted Values and `level'% CI"
          }
       if "`regtype'"=="log" {
          local l2title "Predicted Probabilities and `level'% CI"
          }
  
      twoway (connected pred_y `xvar', sort)                              /// 
          (connected upper `xvar', sort msymbol(none) clcolor(cranberry)  ///
             clpat(dash))                                                 ///                                              
          (line lower `xvar', sort clcolor(cranberry) clpat(dash)),       ///
          ytitle("`ytitle'") l2("`l2title'") xtitle("`xtitle'")           ///
          legend(order(1 "Predicted Value" 2 "`level'% CI"))              ///
          ylabel(, angle(horizontal)) `options'                       
       }

    if "`class'"~="" {
      if "`regtype'"=="lin" {
         local l2title "Predicted Values"
         }
      if "`regtype'"=="log" {
         local l2title "Predicted Probabilities"
         }
      if "`varlblc'"=="" {
         local legtitle="`clvar'"
         }
      if "`varlblc'"~="" {
         local legtitle="`varlblc'"
         }
      if "`clval'"~="" {
        local i 1
        while `i'<=`numcat' {
          local clbl`i' : label `clval' `class`i''
          local i=`i'+1
          }
        }
      local i 2
      local cval `class1'
      while `i'<=`numcat' {
        local cval `cval' `class`i''
        local i=`i'+1
        }
      local i 1
      while `i'<=`numcat' {
        if "`clval'"~=""  {
          local leg`i' `i' "`clbl`i''"
          }
        if "`clval'"==""  {
         local leg`i' `i' "`clvar'=`class`i''"
          }
        local longleg `longleg' `leg`i''
        local i=`i'+1
        }
      rename pred_y _P
      keep _P `xvar' `clvar' upper lower
      quietly reshape wide _P upper lower, i(`xvar') j(`clvar')
      local i 1
      while `i'<=`numcat' {
        if "`clval'"~="" {
           label var _P`class`i'' "`clvar' = `clbl`i''"
           }
           else          {
             label var _P`class`i'' "`clvar' = `class`i''"
             }
        local i=`i'+1
        }
        twoway connect _P* `xvar', ytitle("`ytitle'") xtitle("`xtitle'")  ///
          legend(order("`longleg'") title("`legtitle'", size(default)))   ///
          l2("`l2title'") ylabel(, angle(horizontal)) `options'
      }
    }

if "`savepred'"~="" {
  disp "   "
  use `tempprd'
  save "`savepred'"
  }
end

