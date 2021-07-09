*! version 3.1.3 JMGarrett 19Feb14
/*  Graphs predicted values for linear, quantile, or logistic models       */
/*     (New: allows interactions with polynomials)                         */
/*  Form:  predxcon y, xvar(xvar) f(#) t(#) i(#) options                   */
/*  Options required: xvar(), from(#), to(#), inc(#)                       */
/*  Options allowed: poly, adjust, model, graph, nolist, linear, cluster   */
/*  Note:  X variable should be continuous (interval or ordinal)           */
/*  (added 30Jun03: tests for linear, squared, or cubed terms)             */ 
/*  (added 30Aug04: add cluster option)                                    */
/*  (added 19Feb14: added "xsectional option for table and y-axis label    */

program define predxcon
  version 8.0
  #delimit ;
    syntax varlist (min=1 max=1) [if] [in] [pweight], Xvar(varlist)
        [From(real 0) To(real 0) Inc(real 1) Poly(real 0) CLass(string)
         MODel Adjust(string) NOList GRaph LINear MEDian Level(real 95) 
         CLuster(string) SAVepred(string) XSECtional * ] ;
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
  if "`median'"=="median" & `poly'~=0 {
    #delimit ;
      disp _n(1) as error "Polynomial terms will not work with " as result 
      "median" as error " options" ;
    #delimit cr
    exit
    }
  if "`cluster'"~="" & "`median'"=="median" {
    disp _n(1) as error "option cluster() not allowed with median"
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
  if "`median'"=="median" & _rc==0 {
    disp "  "
    #delimit ;
      disp as error "Error: Y is coded as " as result "0" as error " and " 
      as result "1" as error ";  " as result "median" as error 
      " option not allowed" ;
    #delimit cr
    exit
    }
  if "`linear'"=="linear" & "`median'"=="median" {
    #delimit ;
    disp _n(1) as error "Error: Can't request both " as result "linear "
      "median " as error "options"  ;
    #delimit cr
    exit
    }
  if _rc==0 & "`linear'"=="linear" {
     local reg2cat "01"
     }
  if _rc==0 {
     local regtype="log"
     }
  if _rc~=0 | "`linear'"=="linear" {
     local regtype="lin"
     }
  if _rc~=0 & "`median'"=="median" {
     local regtype="med"
     }
  if "`class'"~="" {
     local clvar="`class'"
     local clval : value label `clvar'
     quietly drop if `clvar'==.
     local varlblc: variable label `class'
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
  keep `yvar' `xvar' `clvar' `covlist' `cluster'
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

* Run linear regression models and test for interaction if class specified
  if "`regtype'"=="lin" | "`regtype'"=="med" {
    if "`model'"~=""  {
      if "`regtype'"=="lin" {
        reg `yvar' `xvar' `polylst' `covlist' `clist' `ilist', clus(`cluster')
        more
        }
      if "`regtype'"=="med" {
        qreg `yvar' `xvar' `polylst' `covlist' `clist' `ilist'
        more
        }
      }
    if "`model'"==""  {
      if "`regtype'"=="lin" {
        quietly reg `yvar' `xvar' `polylst' `covlist' `clist' `ilist', cl(`cluster')
        }
      if "`regtype'"=="med" {
        quietly qreg `yvar' `xvar' `polylst' `covlist' `clist' `ilist'
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
    }
 
* Run logistic models and test for interaction if class specified
  if "`regtype'"=="log" {
    if "`model'"~=""  {
       logistic `yvar' `xvar' `polylst' `covlist' `clist' `ilist', clus(`cluster')
       more
       }
    if "`model'"==""  {
       quietly logistic `yvar' `xvar' `polylst' `covlist' `clist' `ilist', cl(`cluster')
       }
    estimates store logest

    if "`class'"~="" {
       if "`cluster'"=="" {
          quietly logistic `yvar' `xvar' `polylst' `covlist' `clist' if e(sample)
          quietly lrtest logest
          }
       if "`cluster'"~="" {
          quietly test `ilist'
          }
       local chisq=r(chi2)
       local df=r(df)
       local probchi=r(p)
       }

    else {
      * tests for x, x_sq, or x_cube
      if "`cluster'"=="" {
         if `poly'==0 {
            quietly logistic `yvar' `covlist' `clist' if e(sample)
            }
         if `poly'==2 {
            quietly logistic `yvar' `xvar' `covlist' `clist' if e(sample)
            }
         if `poly'==3 {
            quietly logistic `yvar' `xvar' `covlist' `clist' x_sq if e(sample)
            }
         quietly lrtest logest
         }
      if "`cluster'"~="" {
         if `poly'==0 {
            quietly test `xvar'
            }
         if `poly'==2 {
            quietly test x_sq
            }
         if `poly'==3 {
            quietly test x_cube
            }
         }
      local df=r(df)
      local chisq=r(chi2)
      local probchi=r(p)
      }
    quietly estimates restore logest
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

* List results
  if "`class'"~="" {
     sort `clvar' `xvar'
     }
     display "  "
     if "`regtype'"=="lin" {
        if "`xsectional'"=="" {
           disp as text "Predicted Values and `level'% Confidence Intervals"
           }
        if "`xsectional'"=="xsectional" {
           disp as text "Estimated Values and `level'% Confidence Intervals"
           } 
        }
     if "`regtype'"=="med" {
        disp as text "Predicted Medians and `level'% Confidence Intervals"
        }
     if "`regtype'"=="log" {
        if "`xsectional'"=="" {
           disp as text "Predicted Probabilities and `level'% Confidence Intervals"
           }
        if "`xsectional'"=="xsectional" {
           disp as text "Estimated Proportions and `level'% Confidence Intervals"
           } 
        }
     display "  "
     if "`regtype'"=="lin" {
       display as text "  Model Type:" as result "    Linear Regression"
       }

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
     if "`regtype'"=="med" {
       display as text "  Model Type:" as result "    Quantile Regression"
       }
     if "`regtype'"=="log" {
       display as text "  Model Type:" as result "    Logistic Regression"
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
     if "`cluster'"~="" {
        display as text "  Cluster:" as result "       `cluster'"
        }
     display as text "  Observations:" as result "  `newn'"
     if "`class'"=="" & "`nolist'"=="" {
        list `xvar' pred lower upper, noob separator(0)
        }
     if "`class'"~="" & "`nolist'"=="" {
       by `clvar': list `xvar' pred lower upper, noob separator(0)
       }

   if "`class'"=="" {
      disp "  "
      if "`regtype'"=="lin" | "`regtype'"=="med" {
         if `poly'==0 {
           disp as text "  Partial F test for" as result " `xvar'" as text ":"
           }
         if `poly'==2 {
           disp as text "  Partial F test for" as result " x_sq" as text ":"
           }
         if `poly'==3 {
           disp as text "  Partial F test for" as result " x_cube" as text ":"
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

      if "`regtype'"=="log" {
        if "`cluster'"=="" {
           if `poly'==0 {
               disp as text "  Likelihood ratio test for" as result " `xvar'" ///
                  as text ":"
               }
           if `poly'==2 {
               disp as text "  Likelihood ratio test for" as result " x_sq" ///
                  as text ":"
               }
           if `poly'==3 {
               disp as text "  Likelihood ratio test for" as result " x_cube" ///
                  as text ":"
               }
           disp "  "
           disp as text "    LR Chi2(" as result `df' as text ")  = "  ///
                 as result %6.2f `chisq'
           if `probchi'>=.0001 {
              disp as text "    Prob > Chi2 = " as result %7.4f `probchi'
              }
           if `probchi'<.0001 {
              disp as text "    Prob > Chi2 < " as result "0.0001"
              }
           }
        if "`cluster'"~="" {
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
           disp as text "    Wald Chi2(" as result `df' as text ") =  "  ///
                 as result %6.2f `chisq'
           if `probchi'>=.0001 {
              disp as text "    Prob > Chi2  = " as result %7.4f `probchi'
              }
           if `probchi'<.0001 {
              disp as text "    Prob > Chi2 < " as result "0.0001"
              }
           }
        }
     }   

   if "`class'"~="" {
      disp "  "
      if "`regtype'"=="lin" | "`regtype'"=="med" {
         #delimit ;
           disp as text "  Test for interaction of" as result
           " `xvar' * `class'" as text ":";
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
      if "`regtype'"=="log" {

        if "`cluster'"=="" {
           #delimit ;
             disp as text "  Likelihood ratio test for interaction of"
              as result " `xvar' * `class'" as text ":";
           #delimit cr
           disp "  "
           disp as text "    LR Chi2(" as result `df' as text ")  =  "  ///
                 as result %6.2f `chisq'
           if `probchi'>=.0001 {
             disp as text "    Prob > Chi2 = " as result %7.4f `probchi'
             }
           if `probchi'<.0001 {
             disp as text "    Prob > Chi2 < " as result "0.0001"
             }
           }
        if "`cluster'"~="" {
           #delimit ;
             disp as text "  Wald test for interaction of"
              as result " `xvar' * `class'" as text ":";
           #delimit cr
           disp "  "
           disp as text "    Wald Chi2(" as result `df' as text ") = "  ///
                 as result %6.2f `chisq'
           if `probchi'>=.0001 {
             disp as text "    Prob > Chi2 = " as result %7.4f `probchi'
             }
           if `probchi'<.0001 {
             disp as text "    Prob > Chi2 < " as result "0.0001"
             }
           }
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
          if "`xsectional'"=="" {
              local l2title "Predicted Values and `level'% CI"
              }
           if "`xsectional'"=="xsectional" {
              local l2title "Estimated Values and `level'% CI"
              } 
          }
       if "`regtype'"=="med" {
          local l2title "Predicted Medians and `level'% CI"
          }
       if "`regtype'"=="log" {
           if "`xsectional'"=="" {
              local l2title "Predicted Probabilities and `level'% CI"
              }
           if "`xsectional'"=="xsectional" {
              local l2title "Estimated Proportions and `level'% CI"
              } 
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
          if "`xsectional'"=="" {
              local l2title "Predicted Values"
              }
           if "`xsectional'"=="xsectional" {
              local l2title "Estimated Values"
              } 
         }
      if "`regtype'"=="med" {
         local l2title "Predicted Medians"
         }
      if "`regtype'"=="log" {
           if "`xsectional'"=="" {
              local l2title "Predicted Probabilities"
              }
           if "`xsectional'"=="xsectional" {
              local l2title "Estimated Proportions"
              } 
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

