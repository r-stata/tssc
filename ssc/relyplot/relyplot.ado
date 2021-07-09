*! version 3.0.2 JMGarrett 18Oct03
/* Graph reliablity plot of predictions from logistic regression model   */
/* Form:  relyplot, groups(#) or fractions(3, 4, 5, or 10)               */
/* Note: Uses estimates from prior run logistic regression model         */
/* Note: Renamed from "rely" to "relyplot"  19Nov17                      */  
program relyplot
  version 8.0
  syntax [if] [in], [, GRoups(int 0) FRActions(int 0) CI * ]
  marksample touse
  preserve
  capture assert `groups'>0 | `fractions'>0
  if _rc~=0 {
     disp as error " Either groups(#) or fractions(#) must be specified"
     exit
     }
  if `groups'>0 & `fractions'>0  {
     disp as error "Choose either groups(#) or fractions(#) -- both"  /*
       */ " should not be specified."
     exit
     }
  if `fractions'~=0 {
     capture assert `fractions'==3 | `fractions'==4 | `fractions'==5 | /*
          */ `fractions'==10
     if _rc~=0 {
        disp as error "Fractions can be 3, 4, 5, or 10" 
        exit 
        }
     }
  local d=e(depvar)
  quietly predict pred_d if `touse', p
  quietly keep if pred_d~=.
  keep `d' pred_d
  quietly gen x=1

* Create deciles of prediced risk; calculate observed proportions
  if `fractions'>0 {
    if `fractions'==10 { 
      quietly gen pred_grp=recode(pred_d,.1,.2,.3,.4,.5,.6,.7,.8,.9,1)
      quietly replace pred_grp=round(pred_grp*1000-50,1)
      local pclab "tenths"
      local pclabgr "Tenths"
      #delimit ;
        label define predlbl 50 "0-.1" 150 ".1-.2" 250 ".2-.3"
           350 ".3-.4" 450 ".4-.5" 550 ".5-.6" 650 ".6-.7"
           750 ".7-.8" 850 ".8-.9" 950 ".9-1.0" 1000 "1.0";
      #delimit cr
      local xlabval "50(100)950"
      } 
    if `fractions'==5 {
      quietly gen pred_grp=recode(pred_d,.2,.4,.6,.8,1)
      quietly replace pred_grp=round(pred_grp*1000-100,1)
      local pclab "fifths"
      local pclabgr "Fifths"
      #delimit ;
        label define predlbl 100 "0-.2" 300 ".2-.4" 500 ".4-.6"
           700 ".6-.8" 900 ".8-1.0" ;
      #delimit cr
      local xlabval "100 300 500 700 900"
        }
    if `fractions'==4 {
      qui gen pred_grp=recode(pred_d,.25,.5,.75,1)
      quietly replace pred_grp=round(pred_grp*1000-125,1)
      local pclab "forths"
      local pclabgr "Forths"
      #delimit ;
        label define predlbl 125 "0-.25" 375 ".25-.5" 625 ".5-.75"
           875 ".75-1.0" ;
      #delimit cr
      local xlabval "125(250)875"
      }
    if `fractions'==3 {
      qui gen pred_grp=recode(pred_d,.33,.67,1)
      quietly replace pred_grp=round(pred_grp*1000-165,1)
      local pclab "thirds"
      local pclabgr "Thirds"
      label define predlbl 165 "0-.33" 505 ".33-.67" 835 ".67-1.0"
      local xlabval "165 505 835"
      }
    sort pred_grp
    collapse (mean) obs_prop="`d'" (sum) n=x obs_d="`d'", by(pred_grp)
    }

* Create percentiles of predicted risk; calculate observed proportions
  if `groups'>0 {
    sort pred_d
    quietly gen pred_grp=group(`groups')
    quietly egen max=max(pred_d), by(pred_grp)
    quietly replace max=max[_n-1] if pred_d==pred_d[_n-1]
    #delimit  ;
      collapse (mean) obs_prop="`d'" (min) min_pred=pred_d
         (max) max_pred=pred_d (count) n=pred_d (sum) obs_d="`d'",
          by(pred_grp) ;
    #delimit cr
    quietly gen diffpred=(max_pred-min_pred)/2
    quietly replace pred_grp=min_pred+diffpred
    quietly egen maxpred=max(max_pred)
    quietly egen minpred=min(min_pred)
    quietly egen maxobs=max(obs_prop)
    quietly egen minobs=min(obs_prop)
    local maxmax=max(maxpred,maxobs)
    local minmin=min(minpred,minobs)
    drop maxpred minpred maxobs minobs
    }

* Generate the binomial 95% CI for observed values
  if "`ci'"=="ci" {
     tempvar cise
     qui gen `cise'=sqrt(obs_prop*(1-obs_prop)/n)
     qui gen upper=obs_prop+1.96*`cise'
     qui gen lower=obs_prop-1.96*`cise'
     }
 
* Add two observations for diagonal line on plot
  tempfile diag
  quietly save `diag'
  drop _all
  quietly set obs 2
  if `fractions'>0 {
    quietly gen pred_grp=0 if _n==1
    quietly replace pred_grp=1000 if _n==2
    quietly gen diagy=0 if _n==1
    quietly replace diagy=1 if _n==2
    }
  if `groups'>0 {
    quietly gen pred_grp=`minmin' if _n==1
    quietly replace pred_grp=`maxmax' if _n==2
    quietly gen diagy=`minmin' if _n==1
    quietly replace diagy=`maxmax' if _n==2
    }
  append using `diag'
  label var obs_prop "Observed Proportions"
  label var diagy "Perfect Fit"
 
* Print prediction values and observed proportions
  format obs_prop %9.3f
  if "`ci'"=="ci" {
    format upper lower %9.3f
    }
  if `fractions'>0 {
    label define predlbl 1000 "1.0", modify 
    label val pred_grp predlbl
    disp " "
    disp as text "Reliability Plots: Predicted risks for " /*
       */ as result "`d'" as text " divided"
    disp as text "                      into " as result /*
       */ "`pclab'" as text " of predicted risk"
    disp as text "
    disp " "
    if "`ci'"=="ci" {
       list pred_grp obs_d n obs_prop lower upper     ///
          if pred_grp~=. & n~=., separator(0) noob
       }
    if "`ci'"=="" {
       list pred_grp obs_d n obs_prop if pred_grp~=. & n~=., ///
       separator(0) noob
       }
    }
  if `groups'>0 {
    format pred_grp max_pred min_pred %9.3f
    disp " "
    disp as text "Reliability Plots: Predicted risks for " /*
       */ as result "`d'" as text " divided"
    disp as text "                       into " as result /* 
       */ "`groups'" as text " equal size groups"
    disp " "
    if "`ci'"~="" {
      list pred_grp min_pred max_pred obs_d n obs_prop lower upper ///
         if n~=., separator(0) noob
      }
    if "`ci'"=="" {
      list pred_grp min_pred max_pred obs_d n obs_prop if n~=.,  ///
         separator(0) noob
      }
    }

* Graph results
  format obs_prop %10.2f
  format pred_grp %10.2f
  local title "Reliability of Predicted Values"

  if `fractions'>0 {
    lab var pred_grp "Predicted Risk Divided into `pclabgr'"
    local xtitle "Predicted Risk Divided into `pclabgr'"
    if "`ci'"~="" {
       twoway (scatter obs_prop pred_grp, sort)                    ///
              (rcap upper lower pred_grp, sort)                    ///            
              (line diagy pred_grp, sort),                         ///
              ytitle(Observed Proportions) yscale(range(. .))      ///
              xtitle("`xtitle'") title("`title'")                  ///
              xlabel(`xlabval',valuelabel)                         ///
              legend(order(1 2 "95% CI" 3) rows(1))                ///
              ylabel(, angle(horizontal)) `options'
       }
    if "`ci'"=="" {
       twoway (scatter obs_prop pred_grp, sort)                    ///
              (line diagy pred_grp, sort),                         ///
              ytitle(Observed Proportions) yscale(range(. .))      ///
              xtitle("`xtitle'") title("`title'")                  ///
              xlabel(`xlabval',valuelabel)                         ///
              ylabel(, angle(horizontal)) `options'
       }

  }
 
 if `groups'>0 {
    if "`ci'"~="" {
      twoway (scatter obs_prop pred_grp, sort)                    ///
             (rcap upper lower pred_grp, sort)                    ///            
             (line diagy pred_grp, sort),                         ///
             ytitle(Observed Proportions) yscale(range(. .))      ///
             xtitle("`xtitle'") title("`title'")                  ///
             legend(order(1 2 "95% CI" 3) rows(1))                ///
             ylabel(, angle(horizontal)) `options'
      }
    if "`ci'"=="" {
      twoway (scatter obs_prop pred_grp, sort)                    ///
             (line diagy pred_grp, sort),                         ///
             ytitle(Observed Proportions) yscale(range(. .))      ///
             xtitle("`xtitle'") title("`title'")                  ///
             ylabel(, angle(horizontal)) `options'
      }
   }
end
