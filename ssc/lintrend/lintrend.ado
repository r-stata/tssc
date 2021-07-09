*! version 3.2.5 JGarrett 26Mar16
/* Graphs observed proportion of D or means of Y for groupings     */
/* of a continuous X variable                                      */
/* Form:lintrend y x,[groups(#),round(#),integer] graph            */
/* Options Required:  groups, round, or int (only 1);              */
/* Options Allowed:  graph, noline, xlabel, ylabel, titles         */
/* Automatically print logodds graph; graph for prop optional      */

program define lintrend
  version 8.0
  #delimit ;
   syntax varlist(min=2 max=2)[if] [in][, Groups(int 0) Round(real 0)
      Integer GRaph PROPortion LOGodds Title(string) NOLine *] ; 
  #delimit cr
  marksample touse
  tokenize "`varlist'"
  local choice 0
  if `groups'>0 {
    local choice=`choice'+1
    }
  if `round'>0 {
    local choice=`choice'+1
    } 
  if "`integer'"=="integer" {
    local choice=`choice'+1
    }
  if `choice'==0 {
    disp "  "
    #delimit ;
    disp as err "You must chose one:" as result "  groups(#)" as erro ","
      as result " round(#)" as err "," as result " or integer";
    #delimit cr 
    exit
    }
  if `choice'>1 {
    disp "  "
    #delimit ;
    disp as erro "You must chose only one:" as result "  groups(#)" as err ","
      as result " round(#)" as err "," as result " or integer";
    #delimit cr 
    exit
    }
  preserve
  quietly keep if `touse'
  keep `varlist'
  capture assert `1'==1 | `1'==0
    if _rc==0 {
      local ytype=1
      }
    if _rc~=0 {
      local ytype=2
      }
  local varlblx : variable label `2'
  local vallblx : value label `2'
  if `ytype'==1 {
     quietly logistic `1' `2'
     local chi2=e(chi2)
     local p=chiprob(1,e(chi2))
     }
  if `ytype'==2 {
     quietly reg `1' `2'
     local f=e(F)
     local df2=e(df_r)
     local p=fprob(1,`df2',e(F))
     }
  sort `2'

* If groups chosen, divide X into categories of equal size
  if `groups'>0  {
    quietly gen numgrps=group(`groups')
    quietly egen max=max(`2'), by(numgrps)
    quietly replace max=max[_n-1] if `2'==`2'[_n-1]
    #delimit ;
      quietly collapse (min) min=`2' (mean) mean=`2' (sum) y=`1'
        (count) total=`2', by(max);
    #delimit cr
    quietly gen group=mean
    label var group "Mean of `2' categories"
    }
 
* If round chosen, round x to nearest specified value
  if `round'>0  {
    quietly gen group=round(`2',`round')
    #delimit ;
      quietly collapse (sum) y=`1' (count) total=`1' (max) max=`2'
         (min) min=`2', by(group) ;
    #delimit  cr
    quietly replace group=max if group>max
    label var group "`2' rounded to nearest `round'"
    }

* If integer chosen, treat categories of x as original integers 
  if "`integer'"=="integer" {
    local intval: value label `2'   
    quietly gen group=`2'
    collapse (sum) y=`1' (count) total=`1', by(group)
    label var group "Grouped by values of `2'"
    label val group `intval'     
    }

* Calculate means, proportions, and log odds by groups of x
  quietly gen meany=y/total
  if `ytype'==1  {
     quietly gen ln_odds=ln(meany/(1-meany)) if y>0
     label var meany "Proportion of `1'"
     label var ln_odds "Ln(odds) of `1'"
     if "`graph'"~="" {
       quietly reg ln_odds group
       quietly predict hat
       }
     }
  if `ytype'==2  {
     label var meany "Category Mean of `1'"
     if "`graph'"~=""  {
        quietly reg meany group
        quietly predict hat
        }
     }
  
* Set up formats for output
  quietly compress
  format y %5.0f
  format total %7.0f
  if `groups'>0  {
     if _n==1  {
       local range=abs(max-min)
       }
     if `range'>=1000000 {
       format group % 8.2e
       }
     else if `range'>=1 {
       format group %10.1f
       }
     else if `range'>=.1 {
       format group %10.2f
       }
     else if `range'>=.01 {
       format group %10.3f
       }
     else if `range'>=.001 {
       format group %10.4f
       }
     }
  if `ytype'==1  {
      format ln_odds %7.2f
      format meany %6.2f
      }
  if `ytype'==2  {
     egen miny=min(meany)
     if _n==1  {
        local ymin=miny
        }
     if `ymin'>=10000000  {
        format meany %8.2e
        }
     else if `ymin'>=1  {
        format meany %10.2f
        }
     else if `ymin'>=.1  {
        format meany %10.3f
        }
     else if `ymin'>=.01  {
        format meany %10.4f
        }
     else if `ymin'>=.001  {
        format meany %10.5f
        }
     else if `ymin'>=.0001 {
        format meany %10.6f
        }
     }
  
* List results
  sort group
  display _n(1)
  rename group `2'
  rename meany `1'
  rename y d
  if `ytype'==1  /* outcome is binary */ {
   #delimit ;
   display as text "The proportion and ln(odds) of" as result " `1' "
         as text "by categories of" as result " `2'" ;
       display "  ";
    #delimit cr
    if `groups'>0  {
     display as text "  (Note:" as result " `groups'" as text ///
      " `2' categories of " as result "equal sample size" as text ";"
       display as text "     Uses mean `2' value for each category)"
       list `2' min max d total `1' ln_odds, nod noob separator(0)
       }
    if `round'>0  {
       display as text "  (Note: `2' in categories" as result " rounded" ///
          in text " to nearest" as result " `round'" as text ")"
       list `2' min max d total `1' ln_odds, nod noob separator(0)
       }
    if "`integer'"=="integer"  {
       display as text "  (Note: `2' in categories using"  ///
          as result " original values" as text ")"
       label val `2' `vallblx'
       list `2' d total `1' ln_odds, nod noob separator(0)
       }
    }
  if `ytype'==2  /* outcome is continuous */ {
    #delimit ;
       display as text "The mean of" as result " `1' "
         as text "by categories of" as result " `2' " ;
       display "  ";
    #delimit cr
    if `groups'>0  {
       display as text "  (Note:" as result " `groups'" as text ///
         " `2' categories of " as result "equal sample size" as text ";"
       display as text "     Uses mean `2' value for each category)"                                          
       list `2' min max total `1', nod noob separator(0) 
       }
    if `round'>0  {
       display as text "  (Note: `2' in categories" as result " rounded" ///
          in text " to nearest" as result " `round'" as text ")"
       list `2' min max total `1', nod noob separator(0)
       }
    if "`integer'"=="integer"  {
       display as text "  (Note: `2' in categories using"  ///
          as result " original values" as text ")"
       label val `2' `vallblx'
       list `2' total `1', nod noob separator(0)
       }
     }
  display "  "
  if `ytype'==1 {
    #delimit ;
     disp as text "  Test for linear trend:                "
       "  Chi2(1) =  " as result %6.2f `chi2';
     disp as text "                                      Prob > chi2 = "
       as result %7.4f `p';
    #delimit cr
    }
  if `ytype'==2 {
    #delimit ;
     disp as text "  Test for linear trend:            "
       "  F(1,`df2') =  " as result %6.2f `f';
     disp as text "                                       Prob > F = "
       as result %7.4f `p';
    #delimit cr
    }
 
* Graph results
  if "`graph'"=="graph" {
    more
    rename `2' grp
    rename `1' meany
    if `ytype'==1 & "`proportion'"=="proportion" {
      twoway (scatter meany grp, sort), ylabel(, angle(horizontal)) `options'
      more
      }
    if `ytype'==1 {
      if "`noline'"==""  {
        twoway (scatter ln_odds grp, sort) (line hat grp, sort), ///
          ylabel(, angle(horizontal)) `options'
        }
      if "`noline'"=="noline" {
        twoway (scatter ln_odds grp, sort), ylabel(, angle(horizontal)) ///
          `options'
        }
      }
    if `ytype'==2 {
      if "`noline'"=="" {
        twoway (scatter meany grp, sort) (line hat grp, sort), ///
          ylabel(, angle(horizontal)) `options'
        }
      if "`noline'"=="noline" {
        twoway (scatter meany grp, sort),  ///
          ylabel(, angle(horizontal)) `options'
        }
      }
    }
end
