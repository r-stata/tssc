*! Date        : 4 Jan 2019
*! Version     : 1.03
*! Authors     : Adrian Mander
*! Email       : adrian.mander@mrc-bsu.cam.ac.uk
*!
*! Sample size calculations for linear regression

/*
v1.01 16Oct07  Trying to correct the limitations of command .. I haven't finished this
v1.02  2Jun11  Found an error with function
v1.03  4Jan19  Found a bug on the (`alt'*`alt'*`sx'*`sx')>(`sy'*`sy') check
*/

/* START HELP FILE
title[Calculates Sample Size or Power for Simple Linear Regression]

desc[
{cmd:sampsi_reg} calculates the power and sample size for a simple linear regression. The theory behind
this command is described in Dupont and Plummer (1998) Power and Sample Size Calculations for Studies
involving Linear Regression, Controlled Clinical Trials 19:589-601.

The calculations require an estimate of the residual standard error. There are three methods for
doing this: enter the estimate directly; enter the standard deviation of the Y's; or enter the
correlation between Y and X values.

This command can be combined with samplesize in order to look at multiple calculations and to plot
the results.

]

opt[null() specifies the "null slope".]
opt[alt() specifies the "alternative slope".]
opt[n1() size of sample.]
opt[sd1() standard deviation of the residuals.]
opt[alpha() significance level of test.]
opt[power() power of test.]
opt[solve() specifies whether to solve for the sample size or power; default is s(n) solves for n
and the only other choice is s(power) solves for power.]
opt[sx() the standard deviation of the X's.]
opt[sy() the standard deviation of the Y's.]
opt[yxcorr() the correlation between Y's and X's.]
opt[varmethod() specifies the method for calculating the residual standard deviation.  varmethod(r)
uses the Y-X correlation and varmethod(sdy) uses the standard deviation of the Y's, the default uses
a direct estimate of the residual sd sd1(#).]
opt[onesided one-sided test; default is two-sided.]

example[

Calculate power for a two-sided test:

  {stata sampsi_reg, null(0) alt(0.25) n(100) sx(0.25) yxcorr(0.2) varmethod(r) s(power)}

Compute sample size:

{stata  sampsi_reg, null(0) alt(0.25) sx(0.25) sy(1) varmethod(r) s(n)}

When specifying the variance of the y's you must have a varmethod option
  WRONG: {stata sampsi_reg, null(0) alt(5) sx(0.5) sy(12.3)}
  CORRECT: {stata sampsi_reg, null(0) alt(5) sx(0.5) sy(12.3) var(sdy)}

]

author[Dr Adrian Mander]
institute[MRC Biostatistics Unit, University of Cambridge]
email[adrian.mander@mrc-bsu.cam.ac.uk]

return[N_2 the second arm sample size]
return[N_1 the first arm sample size]
return[power the power]


seealso[

{help samplesize} (if installed){stata ssc install samplesize} (to install this command)
{help sampsi_fleming} (if installed)  {stata ssc install sampsi_fleming} (to install this command)
{help simon2stage} (if installed)   {stata ssc install simon2stage} (to install this command)

]

END HELP FILE */


prog def sampsi_reg, rclass
 /* Allow use on earlier versions of stata that have not been fully tested */
 local version = _caller()
 if `version' < 15.1 {
    di "{err}WARNING: Tested only for Stata version 15.1 and higher."
    di "{err}Your Stata version `version' is not officially supported."
 }
 else {
   version 15.1
 }
syntax [varlist] [, NULL(real 0) ALT(real 0.5) N1(real 100) SD1(real 1) Alpha(real 0.05) Power(real 0.9) ///
Solve(string) ONESIDED  SX(real 1) SY(real 1) VARmethod(string) YXCORR(real 0.75) ]

/*
 Set two defaults :
  1) that the residual SD is SD1()
  2) that we are solving for n

Problem
sampsi_reg, null(0) alt(5) sx(0.5) sy(12.3)
sampsi_reg, null(0) alt(22.6) sy(16.7) varmethod(sdy)
*/

if "`varmethod'"=="" local varmethod "res"
if "`varmethod'"~="sdy" & "`sy'"~="1" {
  di "{error}Warning: If you have specified the variance of the Y's then you should use the {res}varmethod(sdy) {err}option"
  exit(196)
}

if "`varmethod'"!="res" & ((`alt'*`alt'*`sx'*`sx')>(`sy'*`sy')) {
  di "{error}Warning alt^2 * Sx^2 > Sy^2!)"
  di "{res}     alt^2 * Sx^2 ="`alt'*`alt'*`sx'*`sx'
  di "             Sy^2 ="`sy'*`sy'
  exit(196)
}

if "`solve'"=="" local solve "n"

/*
 Need to calculate the residual variance 
 EITHER by 
*/


if "`varmethod'"=="res" local sres = `sd1'
if "`varmethod'"=="sdy" local sres = sqrt(`sy'^2-(`alt'-`null')^2*`sx'^2)
if "`varmethod'"=="r" local sres = (`alt'-`null')*`sx'*sqrt( (1/`yxcorr'^2)-1 )

if "`onesided'"~="" local localalpha = `alpha'
else local localalpha = `alpha'/2

if "`solve'"=="n" {
  /* Calculate the sample size */
  local temp 0
  local oldn 10
  local niter 1
  local relaxiter 0
  while abs(`temp'-`oldn')>`relaxiter' {
    local t1 = invttail(`oldn'-2, 1-`power')
    local t2 = invttail(`oldn'-2, `localalpha')
    local newn = ( (`t1'+`t2')^2 * `sres'^2 )/( (`alt'-`null')^2*`sx'^2 )
    local temp = `oldn'
    local oldn = int(`newn')+1
    if `niter'>2000 {
      di as error "Over 2000 iterations in sampsi_reg and still no solution"
      di "{error}Warning alt^2 * Sx^2 ~= Sy^2!)"
      di "{res}     alt^2 * Sx^2 ="`alt'*`alt'*`sx'*`sx'
      di "             Sy^2 ="`sy'*`sy'
      di "{error}Please lower sx or increase alt or increase sy"
      exit(198)
    }
    if `niter++'>100 	  local relaxiter 1
	
  }

  di
  di as text "Estimated sample size for linear regression
  di "Test Ho: slope alt = slope null, usually null slope is 0
  di "Assumptions:"
  di
  if "`oneside'"==""  di as text "          Alpha = " as res %9.4f `alpha' as text "  (two-sided)"
  else  di as text "          Alpha = " as res %9.4f `alpha' as text "  (one-sided)"
  di as text "          Power = " as res %9.4f `power'
  di as text "     Null Slope = " as res %9.4f `null'
  di as text "      Alt Slope = " as res %9.4f `alt'
  di as text "    Residual sd = " as res %9.4f `sres'
  di as text "      SD of X's = " as res %9.4f `sx'
  if "`varmethod'"=="sdy"   di as text "      SD of Y's = " as res %9.4f `sy'
  if "`varmethod'"=="r"   di as text   "Corr(Y's & X's) = " as res %9.4f `yxcorr'
  di
  di
  di as text "Estimated required sample size:"
  di
  di "          n = " as res `oldn'

  return local power=`power'
  return local N_1 =`oldn'
  return local N_2 =`oldn'
}

/* Calculate the power */
if "`solve'"=="power" {

  local t = invttail(`n1'-2, 1-`localalpha')
  local delta = ((`alt'-`null')*`sx')/`sres'
  local power = ( ttail(`n1'-2, `delta'*sqrt(`n1')-`t' )  + ttail(`n1'-2, -1*`delta'*sqrt(`n1')-`t' ))

  di
  di as text "Estimate power for linear regression
  di "Test Ho: Alt. Slope = Null Slope, usually Null Slope is 0
  di
  di "Assumptions:"
  di
  if "`oneside'"==""  di as text "          Alpha = " as res %9.4f `alpha' as text "  (two-sided)"
  else  di as text "          Alpha = " as res %9.4f `alpha' as text "  (one-sided)"
  di as text "              N = " as res %9.4f `n1'
  di as text "     Null Slope = " as res %9.4f `null'
  di as text "      Alt Slope = " as res %9.4f `alt'
  di as text "    Residual sd = " as res %9.4f `sres'
  di as text "      SD of X's = " as res %9.4f `sx'
  if "`varmethod'"=="sdy"   di as text "      SD of Y's = " as res %9.4f `sy'
  if "`varmethod'"=="r"   di as text   "Corr(Y's & X's) = " as res %9.4f `yxcorr'
  di
  di
  di as text "Estimated power:"
  di
  di "       Power = " as res `power'

  return local power=`power'
  return local N_1 =`n1'
  return local N_2 =`n1'


}



end

