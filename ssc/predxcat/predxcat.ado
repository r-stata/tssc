*! version 3.1.3 JMGarrett 19Feb14  
/* Calculate adjusted means, medians, or probabilities for nominal       */
/*  variables in linear, quantile, or logistic regression models         */
/* Form: predxcat y, xvar(x1 x2) cov1 cov2...)                           */
/* Options required:  xvar (x1 [x2])                                     */
/* Options allowed:  adjust, model, level, graph, bar, linear, cluster   */
/* 06Jul03: uses new lrtest code                                         */
/* 30Aug04: add cluster option                                           */
/* 26Mar06: fixed -- interaction can now have more than 11 categories    */
/* 19Feb14: Added "xsectional" option for table and y-axis label         */

program define predxcat
  version 8.0
  #delimit ;
    syntax varlist (min=1 max=1) [if] [in] [pweight], Xvar(varlist)
      [Adjust(string) MODel Graph LINear MEDian Bar CLuster(string)
       Level(real 95) SAVepred(string) XSECtional * ] ;
  #delimit cr
  marksample touse
  markout `touse' `xvar'
  tokenize "`varlist'"
  preserve
  quietly keep if `touse'
  local yvar "`1'"
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
      as error "and " as result "median " as error "options"  ;
    #delimit cr
    exit
    }
  if "`cluster'"~="" & "`median'"=="median" {
    disp _n(1) as error "option cluster() not allowed with median"
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
    local ++i
    macro shift
    local numcov=`i'-1
    }
  local i 1
  while `i'<=`numcov' {
    if "`mcov`i''"=="mean" {
      quietly sum `cov`i''
      local mcov`i'=r(mean)
      }
    local ++i
    }
  keep `yvar' `xvar' `covlist' `cluster'

* Read in X variables and create dummy variables
  tokenize "`xvar'"
  local xvar1 "`1'"
  local vlblx1 : variable label `xvar1'
  quietly tab `xvar1', gen(X)
  local numcat1=r(r)
  local i 2
  while `i'<=`numcat1'  {
    local xlist1 `xlist1' X`i'
    local ++i
    }
  macro shift
  if "`1'"==""  {
    local x2 0
    local numcat=`numcat1'
    }
  if "`1'"~=""  {
    local xlist1 ""
    local i 2
    while `i'<=`numcat1'  {
      rename X`i' X1b`i'              /* was X1 */
      local xlist1 `xlist1' X1b`i'    /* was X1 */
      local ++i
      }
    local x2 1
    local xvar2 "`1'"
    local vlblx2 : variable label `xvar2'
    quietly tab `xvar2', gen(X2)
    local numcat2=r(r)
      local i 2
      while `i'<=`numcat2'  {
        local xlist2 `xlist2' X2`i'
        local ++i
        }
    local numcat=`numcat1'*`numcat2'
  macro shift
  if "`1'"~=""  {
    disp "  "
    disp as error "Only two X variables allowed in the xvar( ) option"
    exit
    }
    
* create interaction terms
    local i 2
    while `i'<=`numcat1' {
      local j 2
      while `j'<=`numcat2' {
        quietly gen I`i'`j'=X1b`i'*X2`j'  /* was X1 */
        local intlist `intlist' I`i'`j'
        local ++j
        }
      local ++i
      }
    }
 
* Run models to get parameter estimates
  if "`regtype'"=="lin" | "`regtype'"=="med" {
     if "`model'"~="model"  {
       if "`regtype'"=="lin" {
         quietly reg `yvar' `xlist1' `xlist2' `intlist' `covlist', cluster(`cluster')
         }
       if "`regtype'"=="med" {
         quietly qreg `yvar' `xlist1' `xlist2' `intlist' `covlist'
         }
       }
     if "`model'"=="model"  {
       if "`regtype'"=="lin" {
         reg `yvar' `xlist1' `xlist2' `intlist' `covlist', cluster(`cluster')
         more
         }
       if "`regtype'"=="med" {
         qreg `yvar' `xlist1' `xlist2' `intlist' `covlist'
         more
         }
       }
    local varlbly : variable label `yvar'
    local varlblx : variable label `xvar1'
  
  * Test for overall association, and interaction if present
    quietly test `xlist1' `xlist2' `intlist'
    local df1=r(df)
    local df2=r(df_r)
    local f=r(F)
    local probf=fprob(`df1', `df2', `f')
    if `x2'==1  {
      quietly test `intlist'
      local df1i=r(df)
      local df2i=r(df_r)
      local fi=r(F)
      local probfi=fprob(`df1i', `df2i', `fi')
      }
    }

   if "`regtype'"=="log" {
      if "`model'"~="model" {
       quietly logistic `yvar' `xlist1' `xlist2' `intlist' `covlist', cluster(`cluster')
       }
     if "`model'"=="model"  {
       logistic `yvar' `xlist1' `xlist2' `intlist' `covlist', cluster(`cluster')
       more
       }
    local varlbly : variable label `yvar'
    quietly estimates store logest

  
  * LR test for overall association, and interaction if present
    if "`cluster'"=="" {
       quietly logistic `yvar' `covlist' if e(sample)
       quietly lrtest logest
       }
    if "`cluster'"~="" {
       quietly test `xlist1' `xlist2' `intlist'
       }
    local df=r(df)
    local chisq=r(chi2)
    local probchi=r(p)
    if `x2'==1  {
       if "`cluster'"=="" {
          quietly logistic `yvar' `xlist1' `xlist2' `covlist' if e(sample)
          quietly lrtest logest
          }
       if "`cluster'"~="" {
          quietly test `intlist'
          }
      local dfi=r(df)
      local chisqi=r(chi2)
      local pchisqi=r(p)
      }
    quietly estimates restore logest
    }
   
* Collapse to 1 obs. per category, dummy variables, and covariates
  quietly gen numobs=1
  sort `xvar'
  collapse `yvar' `xlist1' `xlist2' `intlist' (sum) numobs, by(`xvar')
  quietly replace `yvar'=.

* Replace covariates with their means (or specified values)
  local i 1
  while `i'<=`numcov'  {
    quietly gen `cov`i''=`mcov`i''
    local ++i
    }

* Calculate the adjusted means, medians, or probabilities and CI's
  tempvar linpred
  if "`regtype'"=="log" {
    predict adjval, p
    }
     else {
       predict adjval, xb
       }
  predict se, stdp
  predict `linpred', xb
  local z=invnorm((1-`level'/100)/2)
  if "`regtype'"=="lin" | "`regtype'"=="med" {
    gen lower=`linpred'+`z'*se
    gen upper=`linpred'-`z'*se
    }
  if "`regtype'"=="log" {
    gen upper=1/(1+exp(-`linpred'+`z'*se))
    gen lower=1/(1+exp(-`linpred'-`z'*se))
    format adjval upper lower %6.3f
    format se %8.4f
    quietly estimates drop logest
    }

* Print results
  display "   "
  if `numcov'>0  {
    if "`regtype'"=="lin" {
      #delimit ;
        display as result "*" as text "Adjusted" as result "*" as text
          " Means and `level'% Confidence Intervals" ;
      #delimit cr
      local probtyp="adjmean"
      quietly gen adjmean=adjval
      }
    if "`regtype'"=="med" {
      #delimit ;
        display as result "*" as text "Adjusted" as result "*" as text
          " Medians and `level'% Confidence Intervals" ;
      #delimit cr
      local probtyp="adjmed"
      quietly gen adjmed=adjval
      }
    if "`regtype'"=="log" {
       if "`xsectional'"=="" {
          #delimit ;
             display as result "*" as text "Adjusted" as result "*" as text
              " Probabilities and `level'% Confidence Intervals" ;
          #delimit cr
          }
       if "`xsectional'"=="xsectional" {
          #delimit ;
             display as result "*" as text "Adjusted" as result "*" as text
              " Proportions and `level'% Confidence Intervals" ;
          #delimit cr
          }
      local probtyp="adjprob"
      quietly gen adjprob=adjval
      format adjprob %8.3f
      }
    }
  if `numcov'==0  {
    if "`regtype'"=="lin" {
      #delimit ;
        display as result "*" as text "Unadjusted" as result "*" as text
          " Means and `level'% Confidence Intervals";
      #delimit cr
      local probtyp="mean"
      quietly gen mean=adjval
      }
    if "`regtype'"=="med" {
      #delimit ;
        display as result "*" as text "Unadjusted" as result "*" as text
          " Medians and `level'% Confidence Intervals";
      #delimit cr
      local probtyp="med"
      quietly gen median=adjval
      }
    if "`regtype'"=="log" {
       if "`xsectional'"=="" {
          #delimit ;
             display as result "*" as text "Unadjusted" as result "*" as text
              " Probabilities and `level'% Confidence Intervals" ;
          #delimit cr
          }
       if "`xsectional'"=="xsectional" {
          #delimit ;
             display as result "*" as text "Unadjusted" as result "*" as text
              " Proportions and `level'% Confidence Intervals" ;
          #delimit cr
          }
      local probtyp="prob"
      quietly gen prob=adjval
      format prob %8.3f
      }
    }
  display "  "
    if "`regtype'"=="lin" {
      display as text "  Model Type:" as result "   Linear Regression"
      }
    if "`regtype'"=="med" {
      display as text "  Model Type:" as result "   Quantile Regression"
      }
    if "`regtype'"=="lin" & "`reg2cat'"=="01" {
      disp "  "
       #delimit  ;
       display as input "    Warning:" as text "  Y variable is coded as "
          as result "0" as text " and " as result "1" as text ". Perhaps" ;
       display as text "               you didn't mean to use the "
          as result "linear" as text " option" ;
       #delimit cr
      disp "  "
      }
    if "`regtype'"=="log" {
      display as text "  Model Type:" as result "   Logistic Regression"
      }
  display as text "  Outcome:" as result "      `varlbly' -- $S_E_depv"
  if `x2'==0 {
    display as text "  Nominal X:" as result "    `vlblx1' -- `xvar1'"
    }
  if `x2'==1 {
    display as text "  Nominal X1:" as result "   `vlblx1' -- `xvar1'"
    display as text "  Nominal X2:" as result "   `vlblx2' -- `xvar2'"
    display as text "  Interaction:" as result "  `xvar1' * `xvar2'"
    }
  if `numcov'~=0 {
     display as text "  Covariates:" as result "   `covdisp'"
     }
  if `numcov'==0 {
     display as text "  Covariates:" as result "   (none)"
     }
  if "`cluster'"~="" {
     display as text "  Cluster:" as result "      `cluster'"
     }
  
  if "`regtype'"=="lin" | "`regtype'"=="med" {
    list `xvar' numobs `probtyp' se lower upper, noob nod separator(0)
    disp "  "
    if "`regtype'"=="lin" {
       disp in text "  Test for difference of `numcat' means:"
       }
    if "`regtype'"=="med" {
       disp as text "  Test for difference of `numcat' medians:"
       }
    disp "  "
    disp as text "    F(`df1', `df2') =  " as result  %6.2f `f'
    if `probf'>=.0001 {
      disp as text "    Prob > F   =   " as result %7.4f `probf'
      }
    if `probf'<.0001 {
      disp as text "    Prob > F   <   " as result "0.0001"
      }
    if `x2'==1  {
      disp "  "
      #delimit ;
        disp as text "  Test for interaction of" as result
        " `xvar1' * `xvar2'" as text ":";
      #delimit cr
      disp "  "
      disp as text "    F(`df1i', `df2i') =  " as result %6.2f `fi'
      if `probfi'>=.0001 {
        disp as text "    Prob > F   =   " as result %7.4f `probfi'
        }
      if `probfi'<.0001 {
        disp as text "    Prob > F   <   " as result "0.0001"
        }
      }
    }
  if "`regtype'"=="log" {
    list `xvar' numobs `probtyp' se lower upper, noob nod separator(0)
    disp "  "
    if "`cluster'"=="" {
       disp as text "  Likelihood ratio test for difference of `numcat' probabilities:"
       disp "  "
       disp as text "    LR Chi2(`df')    =  " as result %6.2f `chisq'
       if `probchi'>=.0001 {
         disp as text "    Prob > Chi2   =   " as result %7.4f `probchi'
         }
       if `probchi'<.0001 {
         disp as text "    Prob > Chi2   <   " as result "0.0001"
         }
       if `x2'==1  {
         disp "  "
         #delimit ;
           disp as text "  Likelihood ratio test of interaction for" as result
           " `xvar1' * `xvar2'" as text ":";
         #delimit cr
         disp "  "
         disp as text "    LR Chi2(`dfi')    =  " as result %6.2f `chisqi'
         if `pchisqi'>=.0001 {
           disp as text "    Prob > Chi2   =   " as result %7.4f `pchisqi'
           }
         if `pchisqi'<.0001 {
           disp as text "    Prob > Chi2   <   " as result "0.0001"
           }
         }
       }
    if "`cluster'"~="" {
       disp as text "  Wald test for difference of `numcat' probabilities:"
       disp "  "
       disp as text "    Wald Chi2(`df')    =  " as result %6.2f `chisq'
       if `probchi'>=.0001 {
         disp as text "    Prob > Chi2   =   " as result %7.4f `probchi'
         }
       if `probchi'<.0001 {
         disp as text "    Prob > Chi2   <   " as result "0.0001"
         }
       if `x2'==1  {
         disp "  "
         #delimit ;
           disp as text "  Wald test of interaction for" as result
           " `xvar1' * `xvar2'" as text ":";
         #delimit cr
         disp "  "
         disp as text "    Wald Chi2(`dfi')    =  " as result %6.2f `chisqi'
         if `pchisqi'>=.0001 {
           disp as text "    Prob > Chi2   =   " as result %7.4f `pchisqi'
           }
         if `pchisqi'<.0001 {
           disp as text "    Prob > Chi2   <   " as result "0.0001"
           }
         }
       }
    }

* Save results if requested
  if "`savepred'"~="" {
    tempfile tempprd
    quietly save `tempprd'
  }

* Graph the results, if requested

  if "`graph'"=="graph"  {
    if "`varlbly'"=="" {
      local ytitle "for `yvar'"
      }
    if "`varlbly'"~="" {
      local ytitle "for `varlbly'"
      }
    if "`vlblx1'"=="" {
      local xtitle "`xvar1'"
      }
    if "`vlblx1'"~="" {
      local xtitle "`vlblx1'"
      }
    if "`bar'"=="" {     
      local x1val : value label `xvar1'
      local i 1
      local n 1
      while `n'<=_N  {
        if `xvar1'[`n']~=`xvar1'[`n'-1] {
          local catv1`i'=`xvar1'[`n']
          local catv1 `catv1' `catv1`i''
          local ++i
          }
        local ++n
        }
       if "`x1val'"~="" {
         local i 1 
           while `i'<=`numcat1' {
             local x1lbl`i' : label `x1val' `catv1`i''
             local ++i
             }
          }
        }
    if `numcov'==0 {
      if "`regtype'"=="lin" {
        if "`bar'"=="" {
          local l2title "Unadjusted Means and `level'% CI" 
          }
        if "`bar'"=="bar" {
          local l2title "Unadjusted Means" 
          }
        }
      if "`regtype'"=="med" {
        if "`bar'"=="" {
          local l2title "Unadjusted Medians and `level'% CI" 
          }
        if "`bar'"=="bar" {
          local l2title "Unadjusted Medians" 
          }
        }
      if "`regtype'"=="log" {
        if "`bar'"=="" {
           if "`xsectional'"=="" {
              local l2title "Unadjusted Probabilities and `level'% CI"
              }
           if "`xsectional'"=="xsectional" {
              local l2title "Unadjusted Proportions and `level'% CI"
              } 
           }
        if "`bar'"=="bar" {
           if "`xsectional'"=="" {
              local l2title "Unadjusted Probabilities"
              }
           if "`xsectional'"=="xsectional" {
              local l2title "Unadjusted Proportions"
              } 
           }
        }
      }    
    if `numcov'>0 {
      if "`regtype'"=="lin" {
        if "`bar'"=="" {
          local l2title "Adjusted Means and `level'% CI" 
          }
        if "`bar'"=="bar" {
          local l2title "Adjusted Means"
          }
        }
      if "`regtype'"=="med" {
        if "`bar'"=="" {
          local l2title "Adjusted Medians and `level'% CI" 
          }
        if "`bar'"=="bar" {
          local l2title "Adjusted Medians"
          }
        }
      if "`regtype'"=="log" {
        if "`bar'"=="" {
           if "`xsectional'"=="" {
              local l2title "Adjusted Probabilities and `level'% CI"
              }
           if "`xsectional'"=="xsectional" {
              local l2title "Adjusted Proportions and `level'% CI"
              } 
           }
        if "`bar'"=="bar" {
           if "`xsectional'"=="" {
              local l2title "Adjusted Probabilities"
              }
           if "`xsectional'"=="xsectional" {
              local l2title "Adjusted Proportions"
              } 
          }
        }
      }

    if `x2'==0 {
      sort `xvar1'
      if "`bar'"=="bar" {
        graph bar adjval, over(`xvar1') l2("`l2title'") ytitle("`ytitle'") ///
           b2("`xtitle'") ylabel(, angle(horizontal)) `options'
        }
      if "`bar'"=="" {
        twoway (scatter adjval `xvar1') (rcap lower upper `xvar1'),       ///
           xlabel(`catv1', valuelabel) l2("`l2title'") ytitle("`ytitle'") ///
           legend(order(1 "Predicted Value" 2 "`level'% CI"))             ///
              ylabel(, angle(horizontal)) `options' 
        } 
      }  /* end of graph with 1 X */

    if `x2'==1 {
      local x2val : value label `xvar2'
      if "`vlblx2'"=="" {
         local legtitle="`xvar2'"
         }
      if "`vlblx2'"~="" {
         local legtitle="`vlblx2'"
         }
      sort `xvar2' `xvar1'
      local i 1
      local n 1
      while `n'<=_N  {
        if `xvar2'[`n']~=`xvar2'[`n'-1] {
          local catv2`i'=`xvar2'[`n']
          local catv2 `catv2' `catv2`i''
          local ++i
          }
        local ++n
        }
       if "`x2val'"~="" {
         local i 1 
           while `i'<=`numcat2' {
             local x2lbl`i' : label `x2val' `catv2`i''
             local ++i
             }
          }
       local i 1
       while `i'<=`numcat2' {
         if "`x2val'"~=""  {
           local leg`i' `i' "`x2lbl`i''"
           }
         if "`x2val'"==""  {
          local leg`i' `i' "`xvar2'=`catv2`i''"
           }
         local legend `legend' `leg`i''
         local ++i
         }
       rename adjval M
       keep M `xvar1' `xvar2'
       quietly reshape wide M, i(`xvar1') j(`xvar2')
       local i 1
       while `i'<=`numcat2'  {
         if "`x2val'"~="" {
           label var M`catv2`i'' "`xvar2' = `x2lbl`i''"
           }
           else {          
             label var M`catv2`i'' "`xvar2' = `catv2`i''"
           }
         local ++i
         }
       if "`bar'"=="bar" {
         sort `xvar1'
         graph bar M*, over(`xvar1')                                     ///
           l2("`l2title'") ytitle("`ytitle'") b2("`xtitle'")             /// 
           legend(order("`legend'") title("`legtitle'", size(default)))  ///
           ylabel(, angle(horizontal)) `options'
         }
       if "`bar'"=="" {
         twoway scatter M* `xvar1', l2("`l2title'") ytitle("`ytitle'")   ///
           legend(order("`legend'") title("`legtitle'", size(default)))  ///
           xlabel(`catv1', valuelabel) ylabel(, angle(horizontal)) `options' 
         }
       }  /* end of graphs with 2 X */
     }  /* end of graph block */

  if "`savepred'"~="" {
    disp "  "
    use `tempprd'
    keep `xvar' `probtyp' se lower upper
    order `xvar' `probtyp' se lower upper
    save "`savepred'"
    }
end
