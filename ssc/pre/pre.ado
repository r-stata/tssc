*! version 1.51 P.MILLAR 14Apr2011
*! Copyright 2005-2011 Paul Millar
*! This software can be used for non-commercial purposes only. 
*! The copyright is retained by the developer.
*! Version 1.1 changed to allow proper handling of weights 
*! Version 1.2 changed to fix bugs and to add maxcut and cttype options 
*! Version 1.5 added new algorithm to max cut, added propcut feature 27 Jan 2009
*! Version 1.51 changed to reflect new versions of Stata 

program define pre, rclass
  syntax [anything] , [Cutoff(real 0.5) CTtype(string) Maxcut PROPcut ROUNDmaxcut(integer 4) WEIGHTone(real 1.0)] 

/* The approach of this procedure has three steps */
/* 1. find the errors when guessing the mean, median or mode = E1 */
/* 2. find the errors when guessing what the model predicts = E2 */
/* 3. PRE = (E1-E2)/E1 */

local ver=c(version)

if `ver' < 9.0 {
  local ver="8.0"
  version 8.0
  local outname="outcomes"
  }
else {
  local outname="out"
  local vername=round(`ver',1)
  version `vername'
  }


if `cutoff'<0 | `cutoff'>1 {
  display as error "*** pre: Value of Cutoff must be between 0 and 1"
  exit 198
  }
if "`maxcut'" == "maxcut" & "`propcut'"=="propcut" {
  di as error "*** pre: maxcut and propcut cannot be specified together"
  exit 198
  }
if `roundmaxcut'<1 | `roundmaxcut'>9 {
  local roundmaxcut=8
  }

/* initialize */
local type=e(cmd)
if substr("`e(cmd)'",1,2) == "xt" {
  local type=substr("`e(cmd)'",3,8)
  local xt="xt"
  }

tempvar yp ybar stot sres sreg sstot ssreg ssres ymode ymedian devscore sdevscore res reg yp2 fmode sfmode sortord yy 
tempvar totcorrect correct cuts yyp2

/* get the dependent variable */
local y=e(depvar)
qui gen `yy'=`y' if e(sample)
if ("`type'"=="logistic" | "`type'"=="logit" | "`type'"=="probit" | "`type'"=="cloglog") {
  qui replace `yy'=1 if `yy'~=0
  }
local wtype="`e(wtype)'"
/* since we are not calculating standard deviations, we can use pweight as if aweight */
if "`e(wtype)'" == "pweight" {
  local wtype="aweight"
  }

/* get the predicted values (except for mlogit, mprobit, ologit and oprobit) */
if "`type'"!="mlogit" & "`type'"!="mprobit" & "`type'"!="ologit" & "`type'"!="oprobit" & "`type'"!="gologit2" {
  quietly predict `yp' if e(sample)
  }
if "`type'" == "ereg" {
  qui drop `yp'
  quietly predict `yp' if e(sample), `cttype'
  }
if "`e(cmd)'" == "xtlogit" {
  quietly replace `yp'=exp(`yp')/(1+exp(`yp')) if e(sample)
  }

/* get the predicted values (for mlogit, mprobit, ologit and oprobit) */
if "`type'"=="mlogit" | "`type'"=="mprobit" | "`type'"=="ologit"  | "`type'"=="oprobit" | "`type'"=="gologit2" {
  if "`type'"=="mprobit" {
    local ncats=colsof(e(outcomes))
    mat def tempprobit=e(outcomes)
    mat temp=J(1,`ncats',0) 
    forvalues i = 1/`ncats' {
      mat temp[`i',1]=tempprobit[1,`i']
      }
    mat drop tempprobit
  }
  else if "`type'"=="ologit" | "`type'"=="oprobit" | "`type'"=="gologit2" {
    local ncats=colsof(e(cat))
    mat def temp=e(cat)
    }
  else {
    local ncats=colsof(e(out))
    mat def temp=e(out)
  }
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
if "`type'" != "factor" {
  local firstcase=0
  local i=0
  while `firstcase'==0 {
    local i=`i'+1
    local yvalue=`yy' in `i'
    if `yvalue' !=. {
      local firstcase=`i'
      }
    }
  }
else {
  local firstcase=1
  }
if `firstcase' < 1 | `firstcase' > _N {
  di as error "*** error in PRE *** could not find first non-missing case"
  exit 198
  }

/* ------------------------------------------------------------------------ */
/* find the maximum cutoff point (if specified) for logistic regression pre */
/* ------------------------------------------------------------------------ */
if ("`type'"=="logistic" | "`type'"=="logit" | "`type'"=="probit"| "`type'"=="cloglog") & "`maxcut'" == "maxcut" {
  local nobs=_N
  qui gen `correct'=0
  qui gen `sortord'=_n
  qui gen `cuts'=.
  sort `yp'
  local nobs=_N
  local prevval=0
  local maxright=0
  local savecut=0
  local i=`firstcase'-1
  local ncuts=0
  local cut0=0
  local endit=0

  /* Make a first pass, recording all unique values of potential cutpoints */
  while `endit'==0 {
    local i=`i'+1
    local curval=`yp' in `i'
    /* check to see if we have reached the end */
    if "`curval'" == "." | `i'==`nobs' {
      local ncuts=`ncuts'+1
      local curcut=(1+`prevval')/2
      local cut`ncuts'=`curcut'
      local morenobs=`nobs'+1
      qui set obs `morenobs'
      qui replace `cuts'=1 in `ncuts'
      local endit=1
      }
    else if "`curval'" != "`prevval'" {
      local ncuts=`ncuts'+1
      local curcut=(`curval'+`prevval')/2
      local cut`ncuts'=`curcut'
      qui replace `cuts'=`curcut' in `ncuts'
      }
    local prevval=`curval' 
    }


/* now find the most predictive cutpoint by successive approximations */ 
  local prevcut=0
  local decimal=1
  local lower=0
  local upper=1
  local start=1
  local end=`ncuts'
  while `start' < `end' {
    local maxright=0
    forvalues i=`start'/`end' {
      local rawcut=`cuts' in `i'
      local curcut=round(`rawcut',10^(-`decimal'))
      if `curcut' >= `lower' & `curcut' < `upper' {
        if `prevcut' != `curcut' {
          local saveend=`i'
          local prevcut=`curcut'
          qui replace `correct' = abs(1-abs(`y'-int(`yp'+(1-`curcut'))))   if e(sample)
          if `weightone' != 1 {
            qui replace `correct'=`correct'*`weightone' if e(sample) & `correct'==1 & `y'==1
            }
          qui egen `totcorrect'=sum(`correct') if e(sample)
          local numright=`totcorrect' in `firstcase'
          if `numright' > `maxright' {
            local maxright=`numright'
            local savecut=`curcut'
            local saverawcut=`rawcut'
            local savestart=`i'
            }
          qui drop `totcorrect'
          }
        }
      local prevcut=`curcut'
      }
    local lower=`savecut'-(.5/10^(`decimal'))
    local upper=`savecut'+(.5/10^(`decimal'))
    local start=`savestart'
    local end=`saveend'
    local decimal=`decimal'+1
    local maxright=0
    }

  local decimal=`decimal'-1
  qui drop in `morenobs'
  di as text  _newline "The cutpoint for maximum predictiveness is " as result %8.`decimal'f `saverawcut'
  local cutoff=`saverawcut'
  }
/* --------- end of maxcut ----------- */

/* ----------------------------------------------------------------------------- */
/* find the proportional cutoff point (if specified) for logistic regression pre */
/* ----------------------------------------------------------------------------- */
if ("`type'"=="logistic" | "`type'"=="logit" | "`type'"=="probit"| "`type'"=="cloglog") & "`propcut'" == "propcut" {
  local nobs=_N
  qui gen `sortord'=_n
  sort `yp'
  local ncases=0  
  local endit=0
  local nsuccess=0

  /* Make a first pass, recording all unique values of potential cutpoints */
  while `endit'==0 {
    local i=`i'+1
    local curyp=`yp' in `i'
    local cury=`y' in `i'
    /* check to see if we have reached the end */
    if `i'==`nobs' {
      local ncases=`ncases'+1
      local endit=1
      local nsuccess=`nsuccess'+`cury'
      }
    else if "`curyp'" == "." {
      local endit=1
      }
    else {
      local ncases=`ncases'+1
      local nsuccess=`nsuccess'+`cury'
      }
    }

  local prop=`nsuccess'/`ncases'
  if `nsuccess'==0 {
    local cut1=`yp' in `ncases'
    local cut2=1
    }
  else if `nsuccess'>=`ncases' {
    local cut1=0
    local cut2=`yp' in 1
    }
  else {
    local locone=`ncases'-`nsuccess'+1
    local loctwo=`locone'+1
    local cut1=`yp' in `locone'
    local cut2=`yp' in `loctwo'
    }

  local propcut=(`cut1'+`cut2')/2
  qui sort `sortord'
  local cutoff=`propcut'
//  di "`ncases' cases found, of which `nsuccess' were successes'"
//  di "locone=`locone'; loctwo=`loctwo'; cut1=`cut1'; cut2=`cut2';"
  di as text _newline "Proportional cut is " as result %6.4f `propcut'
  }
/* --------- end of propcut ----------- */


/* ------------ */
/* Calculate E1 */
/* ------------ */
if "`cttype'" == "mode" {
  quietly summ `yy' if e(sample) [`wtype' `e(wexp)']
  local nobs=r(N)
  qui egen `ymode' = mode(`yy') if e(sample),minmode
  qui summ `yy' if e(sample) & `yy' == `ymode'  [`wtype' `e(wexp)']
  local modef=r(N)
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
if "`e(cmd)'" == "factor" {
  local e1=`e(df_m)'*`e(f)'
  }

/* ------------ */
/* Calculate E2 */
/* ------------ */
if "`cttype'" == "mode" {
  if "`type'"=="logistic" |  "`type'"=="logit" | "`type'"=="probit" | "`type'"=="cloglog" {
    qui gen `yyp2'=int(`yp'+(1-`cutoff'))  if e(sample)
    quietly summ `y' [`wtype' `e(wexp)'] if `y' != `yyp2' & e(sample)
    local e2=r(N)
    }
  else if "`type'"=="mlogit" | "`type'"=="ologit"  | "`type'"=="oprobit" | "`type'"=="gologit2" {
      quietly summ `y' [`wtype' `e(wexp)'] if (`y'!= `yp2') & e(sample)
      qui gen `yyp2'=`yp2'
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
  qui gen `yyp2'=`yp'
  qui gen `sres' = (`y' - `yp' )^2 if e(sample)
  qui gen `sreg' = `stot' - `sres' if e(sample)
  qui egen `ssreg' = sum(`sreg') if e(sample)
  qui egen `ssres' = sum(`sres') if e(sample)
  local e2=`ssres' in `firstcase'
  }
if "`e(cmd)'" == "factor" {
  mat fload=e(L)
  local k=`e(df_m)'
  local err=0
  forvalues i=1/`k' {
    local h=fload[`i',1]
    local U=1-(`h'*`h')
    local err=`err'+`U'
    }
  local e2=`err'
  }

/* --------------------------------- */
/* Now we are ready to calc PRE!!!   */
/* --------------------------------- */
local pre=(`e1'-`e2')/`e1'

/* cox regression does not produce predicted duration values (only hazard ratios) */
if "`type'" == "cox" {
  local e1="."
  local e2="."
  local pre="."
  }
else if "`type'"=="factor" {
  di as text _newline "Average Variance Explained of the factor is " as result %6.2f `pre'*100 "%"
  }
else {
 di as text _newline "Model reduces errors in the prediction of `y' by " as result %6.2f `pre'*100 "%"
 }

/* get matrix of predicted versus actual */
if ("`type'"=="logistic" |  "`type'"=="logit" | "`type'"=="probit" | "`type'"=="mlogit" | "`type'"=="mprobit") & "`cttype'"=="mode" {
  label variable `yyp2' "Prediction of `y'"
  label variable `yy' "`y'"
  tab `yy' `yyp2' if e(sample), matcell(temp0) matcol(temp1) matrow(temp2)
  }

if "`cttype'"=="mode" {
  if "`type'"=="logistic" |  "`type'"=="logit" | "`type'"=="probit"  | "`type'"=="cloglog" {
    local p0=temp0[1,1]/(temp0[1,1]+temp0[1,2])*100
    local p1=temp0[2,2]/(temp0[2,1]+temp0[2,2])*100
	if temp0[1,2]==. {
	  local p0=100
	  }
	if temp0[1,1]==. {
	  local p0=0
	  }
	if temp0[2,2]==. {
	  local p1=0
	  }
	if temp0[2,1]==. {
	  local p1=100
	  }
    di as text "Model predicts `y'=0 correctly " as result %2.0f `p0' "% " as text "of the time"
    di as text "Model predicts `y'=1 correctly " as result %2.0f `p1' "% " as text "of the time"
    }
  else if "`type'" != "cox" {
    local good=`nobs'-`e2'
    local good=`good'/`nobs'*100
    di as text "Model predicts `y' correctly " %2.0f `good' "% of the time"
    }
  }

return local pre=`pre'
if ("`type'"=="logistic" | "`type'"=="logit" | "`type'"=="probit") & "`maxcut'" == "maxcut" {
  return local cutoff=`cutoff'
  }
return local e1=`e1'
return local e2=`e2'

end
