*! version 1.2 P.MILLAR 22Feb2006
*! Copyright 2005-2006 Paul Millar
*! This software can be used for non-commercial purposes only. 
*! The copyright is retained by the developer.
*! Version 1.1 changed to allow proper handling of wieghts 
*! Verson 1.2 changed to fix bugs and to add maxcut and cttype options 

program define pre, rclass
  version 8.0
  syntax [anything] , [Cutoff(real 0.5) CTtype(string) Maxcut]

/* The approach of this procedure has three steps */
/* 1. find the errors when guessing the mean, median or mode = E1 */
/* 2. find the errors when guessing what the model predicts = E2 */
/* 3. PRE = (E1-E2)/E1 */

if `cutoff'<0 | `cutoff'>1 {
  display as error "*** pre: Value of Cutoff must be between 0 and 1"
  exit 198
  }

/* initialize */
local type=e(cmd)
tempvar yp ybar stot sres sreg sstot ssreg ssres ymode ymedian devscore sdevscore res reg yp2 fmode sfmode
local y=e(depvar)
local wtype="`e(wtype)'"
/* since we are not calculating standard deviations, we can use pweight as if aweight */
if "`e(wtype)'" == "pweight" {
  local wtype="aweight"
  }

/* get the predicted values (except for mlogit, ologit and oprobit) */
if "`type'"!="mlogit" & "`type'"!="ologit" & "`type'"!="oprobit" & "`type'"!="gologit2" {
 quietly predict `yp' if e(sample)
 }

/* get the predicted values (for mlogit, ologit and oprobit) */
if "`type'"=="mlogit" | "`type'"=="ologit"  | "`type'"=="oprobit" | "`type'"=="gologit2" {
      local ncats=colsof(e(cat))
      mat def temp=e(cat)
      /* Get predicted probabilities for each category of DV */
      forvalues i = 1/`ncats' {
        local catval=temp[1,`i']
        tempvar prob`catval'
        quietly predict `prob`catval'' if e(sample), outcome(`catval')
        }
      /* Find the maximum probability for each case */
      tempvar maxprob
      quietly gen `maxprob'=0
      forvalues i = 1/`ncats' {
        local catval=temp[1,`i']
        quietly replace `maxprob'=`prob`catval'' if `prob`catval'' > `maxprob'
        }
      /* Use the maximum probability to get the prediction of the DV for each case */ 
      qui gen `yp2'=.
      forvalues i = 1/`ncats' {
        local catval=temp[1,`i']
        quietly replace `yp2'=`catval' if `prob`catval'' == `maxprob' & e(sample)
        }
      qui gen `yp'=`yp2'
  }

/* ------------------------------------------- */
/* set the type of central tendency to be used */
/* ------------------------------------------- */
if "`cttype'" == "mean" | "`cttype'" == "median" | "`cttype'" == "mode" {
  // di " "
  }
else if "`type'"=="logistic" | "`type'"=="logit" | "`type'"=="probit" | "`type'"=="mlogit" {
  local cttype="mode"
  }
else if "`type'"=="ologit" | "`type'"=="oprobit" | "`type'"=="gologit2" {
  local cttype="median"
  }
else {
  local cttype="mean"
  }

/* ---------------------------- */
/* find first case in e(sample) */
/* ---------------------------- */
local firstcase=0
local i=0
tempvar yy
qui gen `yy'=`y' if e(sample)
while `firstcase'==0 {
  local i=`i'+1
  local yvalue=`yy' in `i'
  if `yvalue' !=. {
    local firstcase=`i'
    }
  }
if `firstcase' < 1 | `firstcase' > _N {
  di as error "*** error in PRE *** could not find first non-missing case"
  exit 198
  }

/* ------------------------------------------------------------------------ */
/* find the maximum cutoff point (if specified) for logistic regression pre */
/* ------------------------------------------------------------------------ */
if ("`type'"=="logistic" | "`type'"=="logit" | "`type'"=="probit") & "`maxcut'" == "maxcut" {
  tempvar correct savemax getmax
  qui gen `correct'=0
  qui gen `savemax'=0
  qui gen `yp2'=.
  local nobs=_N
  forvalues i=1/`nobs' {
    local cutp=`yp' in `i'
    qui replace `yp2' = int(`yp'+(1-`cutp')) if e(sample)
    tempvar totcorrect
    qui replace `correct'=0 if e(sample)
    qui replace `correct'=1 if `y'==`yp2' & e(sample)
    qui egen `totcorrect'=sum(`correct') if e(sample)
    local numright=`totcorrect' in `firstcase'
    qui replace `savemax'=`numright' in `i'
    qui drop `totcorrect'
    }
  qui egen `getmax' = max(`savemax')
  local maxcorrect =`getmax' in `firstcase'
  forvalues i=1/`nobs' {
    local numright=`savemax' in `i'
    if `maxcorrect' == `numright' {
      local maxcut=`yp' in `i'
      }
    }
  di as text _newline "maximum value for cutoff is " as result  %6.4f `maxcut'
  local cutoff=`maxcut'
  drop `yp2'
  }

/* ------------ */
/* Calculate E1 */
/* ------------ */
if "`cttype'" == "mode" {
  qui egen `ymode' = mode(`y') if e(sample)
  qui gen `fmode' = 0 if e(sample)
  qui replace `fmode'=1 if `y' == `ymode' & e(sample)
  qui egen `sfmode'=total(`fmode') if e(sample)
  local modev = `ymode' in `firstcase'
  local modef = `sfmode' in `firstcase'
  quietly summ `y' if e(sample)
  local nobs=r(N)
  local e1=`nobs'-`modef'
  }
if "`cttype'" == "median" {
  qui egen `ymedian'=median(`y') if e(sample)
  local median = `ymedian' in `firstcase'
  qui gen `devscore' = abs(`y' - `median') if e(sample)
  qui egen `sdevscore'=sum(`devscore') if e(sample)
  local e1=`sdevscore' in `firstcase'
  }
if "`cttype'" == "mean" {
  qui egen `ybar' = mean(`y') if e(sample)
  qui gen `stot' = (`y' - `ybar')^2 if e(sample)
  qui egen `sstot' = sum(`stot') if e(sample)
  local e1=`sstot' in `firstcase'
  }

/* ------------ */
/* Calculate E2 */
/* ------------ */
if "`cttype'" == "mode" {
  if "`type'"=="logistic" |  "`type'"=="logit" | "`type'"=="probit" {
    qui gen `yp2'=int(`yp'+(1-`cutoff'))  if e(sample)
    quietly summ `y' [`wtype' `e(wexp)'] if `y' != `yp2' & e(sample)
    local e2=r(N)
    }
  else if "`type'"=="mlogit" | "`type'"=="ologit"  | "`type'"=="oprobit" | "`type'"=="gologit2" {
      quietly summ `y' [`wtype' `e(wexp)'] if (`y'!= `yp2') & e(sample)
      local e2=r(N)
      mat drop temp 
      }
  else {
    tempvar wrong
    qui gen `wrong'=0
    qui replace `wrong'=1 if round(`yp') != round(`y')
    qui egen `sres' = sum(`wrong') if e(sample)
    local e2=`sres' in `firstcase'
    }
  }

if "`cttype'" == "median" {
  qui gen `res'=abs(`y'-`yp') if e(sample)
  qui egen `sres'=sum(`res') if e(sample)
  local e2=`sres' in `firstcase'
  }
if "`cttype'" == "mean" {
  qui gen `yp2'=`yp'
  qui gen `sres' = (`y' - `yp' )^2 if e(sample)
  qui gen `sreg' = `stot' - `sres' if e(sample)
  qui egen `ssreg' = sum(`sreg') if e(sample)
  qui egen `ssres' = sum(`sres') if e(sample)
  local e2=`ssres' in `firstcase'
  }

/* --------------------------------- */
/* Now we are ready to calc PRE!!!   */
/* --------------------------------- */
local pre=(`e1'-`e2')/`e1'
di as text _newline "Model reduces errors in the prediction of `y' by " as result %6.2f `pre'*100 "%"

/* get matrix of predicted versus actual */
if ("`type'"=="logistic" |  "`type'"=="logit" | "`type'"=="probit" | "`type'"=="mlogit") & "`cttype'"=="mode" {
  label variable `yp2' "Prediction of `y'"
  tab `y' `yp2' if e(sample), matcell(temp0) matcol(temp1) matrow(temp2)
  }

if "`cttype'"=="mode" {
  if "`type'"=="logistic" |  "`type'"=="logit" | "`type'"=="probit" {
    local pos=temp0[2,2]/(temp0[1,2]+temp0[2,2])*100
    di as text "If model predicts `y'=1, there is a " as result %2.0f `pos' "% " as text "chance of this being correct"
    }
  else {
    local good=`nobs'-`e2'
    local good=`good'/`nobs'*100
    di as text "Model predicts `y' correctly " %2.0f `good' "% of the time"
    }
  }

return local pre=`pre'
return local PRE=`pre'
if ("`type'"=="logistic" | "`type'"=="logit" | "`type'"=="probit") & "`maxcut'" == "maxcut" {
  return local cutoff=`cutoff'
  }
return local e1=`e1'
return local e2=`e2'

end
