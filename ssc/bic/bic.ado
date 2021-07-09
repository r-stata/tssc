*! version 1.0 P.MILLAR 17Mar2005
*! version 1.1 23Feb2006 fixed bug with the largest option
*! version 1.2 minor revisions to handle event history models
*! This software can be used for non-commercial purposes only. 
*! The copyright is retained by the developer.
*! Copyright 2005-2006 Paul Millar
program bic, byable(recall) rclass
  version 8.0
  syntax [anything] , [Smallest(integer 1) Largest(integer 999999)  MINProb(real .65) MAXModels(integer 9999999) ESTProb(real 0) best(integer 10) dots ]

tempvar sampal

_est clear
_est hold model1, copy restore

/* calculate basic info on the full model */
local cmd=e(cmd)
local saveN=e(N)
local savedf=e(df_m)
local wtype=e(wtype)
if "`wtype'"=="." {
  local wtype=" "
  }
local wexp=e(wexp)
if "`wexp'"=="." {
  local wexp=" "
  }
if "`cmd'" == "regress" {
  local saveF=e(F)
  local savedfr=e(df_r)
  local savemss=e(mss)
  local saverss=e(rss)
  local savermse=e(rmse)
  local ms1=e(mss)/e(df_m)
  local ms2=e(rss)/e(df_r)
  local ftail=Ftail(e(df_m),e(df_r),e(F))
  local totss=e(mss)+e(rss)
  local totdf=e(df_m)+e(df_r)
  local ms3=`totss'/`totdf'
  local saver2=e(r2)
  local saver2a=e(r2_a)
  }
else {
  local pchi2=chi2tail(e(df_m),e(chi2))
  local saver2=(e(ll_0)-e(ll))/e(ll_0)
  local savechi2=e(chi2)
  }

/* run bicdrop1 to get the drop1 probabilities, variable list, and some parms */
qui bicdrop1

_est unhold model1
_est hold model2, copy restore

qui gen `sampal'=0
qui replace `sampal'=1 if e(sample)
mat bdprobs=r(prob)
mat bicdrop=r(bic)
mat varnum=r(varnum)
local depvar = e(depvar)
local wgtexp= "`e(wgtexp)'"
local xnames `r(xnames)'
local vnames `r(vnames)'
local nconst=r(nconst)
local totnvars=r(totnvars)
local nvars=r(nvars)
local bicfull=r(bicfull)

/* check to see if the minimum probability will include some models */
local highest=0
local second=0
forvalues i=1/`nvars' {
  local prob= 1-bdprobs[`i',1]
  if `prob'>`highest' {
    local second=`highest'
    local highest=`prob'
    }
  else {
    if `prob'>`second' {
      local second=`prob'
      }
    }
  }
if `minprob'>`second' & `minprob'==0.65 {
  local minprob=(`highest'*`second')^.5
  local minprob=round(`minprob',.01)
  di as text "Minimum probability reset to " as result %5.2f `minprob'
  }

/* handle event history models */
if "`e(cmd)'"=="cox" {
  if "`e(cmd2)'"!="" {
    local cmd `e(cmd2)'
    local depvar
    } 
  else {
    di as text "Please use stcox instead of cox in the last model."
    exit
    }
  }
if "`e(cmd2)'"=="streg" {
  local cmd="`e(cmd2)'"
  local depvar=""
  local dist="dist(`e(cmd)')"
  if "`e(cmd)'" == "ereg" {
    local dist="dist(exponential)"
    }
  }

if "`e(offset)'"!="" {
  tempvar off 
  gen `off'=`e(offset)'
  lab var `off' "`e(offset)'"
  local offset offset(`off')
  }
if "`e(vcetype)'"!="" { 
  local vcetype=lower("vcetype(`e(vcetype)')")
  }
if "`e(cmd)'"!="regress" & "`e(cmd)'"!="tobit" & substr("`e(cmd)'",1,2)!="xt" & "`e(cmd)'"!="factor" & "`e(cmd)'"!="xtreg" {
  local iter="iter(50)"
  }
if substr("`e(cmd)'",1,2)=="xt" & "`e(model)'" != "" {
  local modtype = "`e(model)'"
  }
if substr("`e(cmd)'",1,2)=="xt" & "`e(link)'" != "" {
  local linktype = "link(`e(link)')"
  }
if substr("`e(cmd)'",1,2)=="xt" & "`e(corr)'" != "" & substr("`e(corr)'",1,2) != "no" {
  local corrtype = lower("corr(`e(corr)')")
  if substr("`corrtype'",1,17)=="panel-specific ar" {
    local corrtype ="corr(psar"+substr("`corrtype'",19,1)+")"
    }
  if substr("`e(corr)'",1,2) =="AR" |  substr("`e(corr)'",1,2) =="ar" {
    local corrtype = "corr(ar"+substr("`e(corr)'",4,1)+")"
    }
  }
if substr("`e(cmd)'",1,2)=="xt" & "`e(family)'" != "" {
  local famtype = lower("family(`e(family)')")
  }
if substr("`e(cmd)'",1,2)=="xt" & "`e(vt)'" != "" {
  local vttype = "panels(`e(vt)')"
  }
local ops `offset' `vcetype' `cluster' `dist' `iter' `modtype' `vttype' `linktype' `corrtype' `famtype'

/* Tobit Options */
if "`e(cmd)'" == "tobit" {
  local ops `offset' `robust' `cluster' 
  if "'e(ulopt)'" != "" {
    local ops= "`ops' ul(`e(ulopt)')"
    }
  if "'e(llopt)'" != "" {
    local ops= "`ops' ll(`e(llopt)')"
    }
  } 

/* parse the full or expanded from xi ivs */
tokenize `xnames'
local nxvars=1
local word  ="``nxvars''"
while "`word'" !="" {
  local xvar`nxvars'="`word'"
  local nxvars=`nxvars'+1
  local word="``nxvars''"
  }
local nxvars=`nxvars'-1

/* parse the non-expanded ivs */
tokenize `vnames'
local nvars=1
local word  ="``nvars''"
while "`word'" !="" {
  local var`nvars'="`word'"
  local nvars=`nvars'+1
  local word="``nvars''"
  }
local nvars=`nvars'-1


/* create an indicator for xi variables */
forvalues i=1/`totnvars' {
  local j=varnum[`i',1]
  local k=varnum[`i',2]
  local xi`k'=0
  if "`xvar`j''" != "`var`k''" {
    local xi`k'=1
    }
  }

/* calculate the pvalues for each variable */
quietly summ `depvar' if e(sample)
local sy=r(sd)

forvalues i=1/`nvars' {
  if `xi`i'' == 0 {
    quietly summ `var`i'' if e(sample)
    local sx=r(sd)
    local b`i'=_b[`var`i'']
    if "`cmd'" == "regress" | "`cmd'" == "reg" {
      local beta`i'=_b[`var`i'']*`sx'/`sy'
      }
    else {
      local beta`i'=exp(_b[`var`i''])
      }
    local pvalue`i'=ttail(e(N)-1,abs(_b[`var`i'']/ _se[`var`i'']))*2  
    }
  else {
    local beta`i'="."
    local b`i'="."
    local pvalue`i'="."
    }
  }


/* set up parameters */
if `smallest' < 1 {
  local smallest = 1
  }
else if `smallest' > `nvars' {
  local smallest = `nvars'
  }
if `largest' > `nvars' {
  local largest = `nvars'
  }
else if `largest' < `smallest' {
  local largest = `smallest'
  }

local sum=0
local maxcomb=0
forvalues i=`smallest'/`largest' {
  local combs=comb(`nvars',`i')
  local sum=`sum'+`combs'
  if `combs' > `maxcomb' {
    local maxcomb=`combs'
    }
  }
local nmodels=`sum'
di " "
di as text "There are a total of " as result "`nmodels'" as text " possible models"

/* check for enough memory, matsize */
local matsize=c(matsize)
local maxmat =c(max_matsize)
if `matsize' < `nvars' {
  if `nvars' > `maxmat' {
    di as error "matzise too small for the number of independent variables:`nvars'"
    exit 103
    }
  else {
    set matsize `nvars'
    }
  }

/* for every model, we will save the bicp, R2 (or PRE), Adj R2 (or Pseudo R2), and which variables were in the model */
if `best'>0 {
  matrix bestmodels=J(`best',5,0)
  matrix varsin=J(1,`nvars',0)
  }

/* initialize the accumulation variables */
local sum_m=0
forvalues i=1/`nvars' {
  local sum_m`i'=0
  local bma_b`i'=0
  }

di as text " "
di "Considering models containing from `smallest' to `largest' explanatory variables"

/* this is the main loop */
local maxbicp=0
local minbic=0
local modelno=0
local totmodp=0
local totp=0
local goodmods=0
forvalues size=`smallest'/`largest' {
  local count=0
  local rejects=0
  local width=`nvars'+3

  forvalues i=1/`size' {
    local digit`i'=`i'
    local max`i'=`nvars'-`size'+`i'
    local min`i'=`i'
    }
  local digit`size'=`digit`size''-1

  while `digit1' <= `max1' {
    local digit`size'= `digit`size''+1
    if `digit`size'' > `nvars' {
      local inc=0
      local j=`size'
      while `inc' ==0 {
        local j=`j'-1
        if `j' <= 0 {
          local digit1 = `digit1' + 1
          local inc = 1
          }
        else if `digit`j'' < `max`j'' { 
          local digit`j'=`digit`j''+1
          local inc=1
          }
        }
        local next=`j'+1
        if `next' > 1 {
          forvalues k=`next'/`size' {
            local prev=`k'-1
            local digit`k'=`digit`prev''+1
            }
          local digit`size' = `digit`size'' - 1
          }
      }
    else {
      local modelno=`modelno'+1
      /* compute the probability for this model from drop1 probabilities */
      local modelp=1
      forvalues i=1/`size' {
        local varp=(1-bdprobs[`digit`i'',1])
        local modelp=`modelp'*`varp'
        }
      local totp=`totp'+((`modelp')^(1/`size'))
      if `modelp' > `minprob'^`size' | `goodmods' < `best' {
        local totmodp=`totmodp'+((`modelp')^(1/`size'))
        forvalues j=1/10 {
          local ivl`j'=" "
          }
        local nivl=1
        local vars = " "
        local goodmods=`goodmods'+1
        forvalues i=1/`size' {
          forvalues j=1/`nxvars' {
            if varnum[`j',2] == `digit`i'' {
              local lstr=length("`ivl`nivl''")+length("`xvar`j''")
              if `lstr' > 80 {
                local nivl=`nivl'+1
                }
              if "`xvar`j''" != "_cons" {
                local ivl`nivl'="`ivl`nivl'' `xvar`j''"
                }
              if "`var`digit`i''' " != "`prevvar'" {
                local vars = "`vars'" + "`var`digit`i''' "
                }
              local prevvar="`var`digit`i''' "
              }
            }
            matrix varsin[1,`digit`i'']=1
          }
        qui `cmd' `depvar'  `ivl1' `ivl2' `ivl3' `ivl4' `ivl5' `ivl6' `ivl7' `ivl8' `ivl9' `ivl10' [`wtype'`wexp']  if `sampal'==1 , `ops' 
        local mdf=e(df_m)+`nconst'
        if "`e(df_m)'" == "" {
          if "`e(df)'" == "" {
            di as error "Cannot find degrees of freedom for this model"
            exit 198
            }
          local mdf=`e(df)'+`nconst'
          }
        local bic=-2*e(ll) - ( e(N)-`e(df_m)'-`nconst'-1) * ln(e(N)) 
        if "`cmd'" == "cox" | "`cmd'" == "ereg" {
          local bic=-2*e(ll) - ( (e(N_fail)-(e(df_m)+`nconst'-1)) * ln(e(N_fail)) )
          }
        local m=exp(-0.5*(`bic'-`bicfull'))
        local sum_m=`sum_m'+`m'
        forvalues ii=1/`nvars' {
          if varsin[1,`ii']==1 {
            local sum_m`ii'=`sum_m`ii''+`m'
            if `xi`ii'' == 0 {
              local bma_b`ii'=`bma_b`ii''+_b[`var`ii'']*`m'
              }
            }
          matrix varsin[1,`ii']=0
          }
        local varlist`goodmods'="`vars'"
        qui pre
        local pre=r(pre)
        if `minbic'>`bic' {
          local minbic=`bic'
         }
        local pseudo=(e(ll_0)-e(ll))/e(ll_0)
        if "`cmd'" == "regress" {
          local pseudo=e(r2_a)
          }


/* see if the model is one that should be saved for display later */
        if `best'>0 {
          if `best'>=`goodmods' {
            mat bestmodels[`goodmods',1]=`bic'
            mat bestmodels[`goodmods',2]=`pre'
            mat bestmodels[`goodmods',3]=`pseudo'
            mat bestmodels[`goodmods',4]=`size'
            mat bestmodels[`goodmods',5]=`goodmods'
            }
          else { 
          
            local max= -2147483647
            local found=0
            forvalues ii=1/`best' {
              if `max' < bestmodels[`ii',1] {
                local max=bestmodels[`ii',1]
                local found=`ii'
                 }
              }
            if `bic' < bestmodels[`found',1] {
              mat bestmodels[`found',1]=`bic'
              mat bestmodels[`found',2]=`pre'
              mat bestmodels[`found',3]=`pseudo'
              mat bestmodels[`found',4]=`size'
              mat bestmodels[`found',5]=`goodmods'
              }
            if "`dots'" == "dots" {
              local star=round(`goodmods'/10-int(`goodmods'/10),.00001)
              if `star'==0 {
                di _continue as input "*"
                }
              else {
                di _continue as input "."
                }
              }
            }
          }
        }
      }
    }
  }

/* ------------------------------------------------------- */
/* we have completed going through all the possible models */
/* ------------------------------------------------------- */

local pcttotp=`totmodp'/`totp'*100
di " "
di as text "Minimum probability standard: " as result "`minprob'" 
di as result "`goodmods'" as text " of " as result "`nmodels'" as text " models considered, capturing " as result %6.2f `pcttotp' "% " as text "of the estimated total probability"
local minbic=`minbic'+100  /* a bicdiff of more than 100 is enormous */

/* restore full model */
_est unhold model2

/* print out headings */
if "`cmd'" == "regress" | "`cmd'" == "reg" {
  di " "
  di as text %12s "Source" " {c |}       SS       df       MS              Number of obs =" as result %8.0f `saveN'
  di as text "{hline 13}{c +}{hline 30}           F(" %3.0f `savedf' "," %6.0f `savedfr' ") =" as result %8.2f `saveF'
  di as text %12s    "Model" " {c |}" as result %12.0g `savemss' %6.0f `savedf' %12.0g `ms1'  as text "           Prob > F      =" as result %8.4f `ftail'
  di as text %12s "Residual" " {c |}" as result %12.0g `saverss' %6.0f `savedfr' %12.0g `ms2' as text "           R-squared     =" as result %8.4f `saver2'
  di as text "{hline 13}{c +}{hline 30}"                                                  as text "           Adj R-squared =" as result %8.4f `saver2a'
  di as text %12s    "Total" " {c |}" as result %12.0g `totss' %6.0f `totdf' %12.0g `ms3' as text "           Root MSE      =" as result %8.4f `savermse'
  di " "
  di as text "{hline 13}{c TT}{hline 30}{c TT}{hline 11}{c TT}{hline 21}"
  di as text _col(14) "{c |}" _col(20) "Conventional" _col(45) "{c |} BICdrop1  {c |}    BMA Posterior"
  di as text %12s "`depvar'" %2s " {c |}" %10s "Coef." %9s "Beta " "  P>|t|    {c |}   Prob.   {c |}    Coef.    Prob."
  di as text "{hline 13}{c +}{hline 30}{c +}{hline 11}{c +}{hline 21}"
  }
else {
  local pchi2=chi2tail(e(df_m),e(chi2))
  di " "
  di as text %12s "`cmd'" " regression                                Number of obs =" as result %8.0f `saveN'
  di as text  "                                                       LR chi2("  %4.0f `savedf' ") =" as result %8.2f `savechi2'
  di as text  "                                                       Prob > chi2   =" as result %8.4f `pchi2'
  di as text  "                                                       Pseudo R2     =" as result %8.4f `saver2'
  di " "
  di as text "{hline 13}{c TT}{hline 30}{c TT}{hline 11}{c TT}{hline 21}"
  di as text _col(14) "{c |}" _col(20) "Conventional" _col(45) "{c |} BICdrop1  {c |}    BMA Posterior"
  di as text %12s "`depvar'" %2s " {c |}" %10s "Coef." %9s "exp(b) " "  P>|t|    {c |}   Prob.   {c |}   Coef.     Prob."
  di as text "{hline 13}{c +}{hline 30}{c +}{hline 11}{c +}{hline 21}"
  } 

/* Calulcate some values, the print output for each variable */
forvalues i=1/`nvars' {
  local beta=`beta`i''
  local pval0=`pvalue`i''
  local stars="   "
  if `pval0' <= .001 {
    local stars="***"
    }
  else if `pval0' <= .01 {
    local stars="** "
    }
  else if `pval0' <= .05 {
    local stars="*  "
    }
  if `xi`i''==0 {
    local bicprob=1-(`sum_m`i''/`sum_m')
    local slope`i'=`bma_b`i''/`sum_m`i''
    local bicstars="   "
    if `bicprob' <= .001 {
      local bicstars="***"
      }
    else if `bicprob' <= .01 {
      local bicstars="** "
      }
    else if `bicprob' <= .05 {
      local bicstars="*  "
      }
    }
  else {
    local bicprob=.
    local slope`i'=.
    local bicstars="   "
    }
  local bddiff=bicdrop[`i'+1,1]-bicdrop[1,1]
  local bdprob=bdprobs[`i',1]
  local bdstars="   "
  if `bdprob' <= .001 {
    local bdstars="***"
    }
  else if `bdprob' <= .01 {
    local bdstars="** "
    }
  else if `bdprob' <= .05 {
    local bdstars="*  "
    }
  di as text %12s "`var`i''" %2s " {c |}" as result %10.4f  `b`i'' %9.4f `beta' %7.3f `pval0' %4s "`stars' " as text "{c |}" as result %7.4f `bdprob'  %4s "`bdstars' " as text "{c |}" as result  %10.4f `slope`i''  %8.4f `bicprob' %3s "`bicstars'"
  }


di as text "{hline 13}{c BT}{hline 30}{c BT}{hline 11}{c BT}{hline 21}"

di " "
/* list out the best models, if requested */
if `best' > 0 {
  di " "
  di " Listing the `best' most probable models, given the data"
  matsort bestmodels 1 "up"
  di " "
  di "{hline 78}"
  if "`cmd'" == "regress" {
    di "                          Adj "
    }
  else {
    di "                        Pseudo "
    }
  di " No.      BIC      PRE     R2    k  Variables"
  di "{hline 78}"
  if `best' > `goodmods' {
    local best=`goodmods'
    }
  forvalues i=1/`best' {
    local colour="as result"
    if `i' < `goodmods' {
      local bicdiff= bestmodels[`i'+1,1]- bestmodels[`i',1]
      if `bicdiff' < 13.8 & bestmodels[`i',4] >  bestmodels[`i'+1,4] {
        local colour="as text"
        }
      }
    local n=bestmodels[`i',5]
    di as text %4.0f `i' `colour' %12.2f bestmodels[`i',1] " " %6.3f bestmodels[`i',2] " "  %6.3f bestmodels[`i',3] " "  %3.0f bestmodels[`i',4] as text %-40s "  `varlist`n''"
    }
  di "{hline 78}"
  }

_est drop _all


if `best'>0 {
  return matrix bestmodels bestmodels
  }

end

