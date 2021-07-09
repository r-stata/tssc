*! Date        : 17 Oct 2019
*! Version     : 1.13
*! Authors     : Adrian Mander
*! Email       : mandera@cardiff.ac.uk
*! Description : Bland-Altman plots with trend adjustment

/*
17/5/06  v1.3  Add-in the middle line
6/10/06  v1.4  Handle multiple data points at the same point by using frequency option
                 Also add Scatter option just to add options to the scatter part of the plot
2/9/07   v1.5  Changed version from 8 to 9.2
11/12/07 v1.6  Extended the shaded area
14/12/07 v1.7  Add limits of agreement into the info option
11/2/08  v1.8  BUGs fixed and extended the shading to the xlimits
17/4/08  v1.9  BUG fix.. the info limits were the wrong way round!
9/5/08   v1.10 Allowing shading to extend beyond data to any limit you like
11/5/08  v1.11 Added the range to be displayed for the averages
19/5/09  v1.12 Changed email address
11/6/12  v1.13 Added extra option for titles and number of decimal places in display
17/10/19 v1.14 Sorting out options on the xlabel
*/

/* START HELP FILE
title[Produces a Bland-Altman plot when there is a relationship between paired differences and their
    average]
 
opt[info() specifies that the percentage of points outside the limits of agreement are
                            displayed as a subtitle.]
opt[valabel() pecifies that the points outside the limits of agreement be labelled using
                            the variable varname.]
opt[shading() specifies the extent of shading beyond the range of the data.]
opt[dp() specifies the precision of the numbers in the title of the graph.]
opt[notrend() specifies that the original Bland-Altman plot (without a trend) be plotted.]
opt[moptions() specifies options for the markers that lie outside the limits of agreement.]
opt[scatter() specifies options for the scatter part of the final plot.]
opt[star specifies options for example titles and labels.]
opt[xlabel() specifies the labels for the x-axis.]
opt[nograph() specifies that the graph is not displayed to the graphics window.]

return[mean is the mean.]       
return[b0 is the intercept.]
return[b1 is the slope.]
return[c0 is the intercept for the trend line.]
return[c1 is the slope for the trend line.]
return[eqn is the equation.]
return[upper is the upper limit equation.]
return[lower is the lower limit equation.]

desc[
    batplot produces a Bland-Altman plot adjusted (or not) for trend.

    The standard Bland-Altman plot is between the difference of paired variables versus the average,
    this is produced using the notrend option. The main addition that this command handles is when
    there is a linear relationship between the the paired difference and the paired average. A
    regression model is used to adjust the limits of agreement accordingly.  This is particularly
    useful when the two variables might be measured on different scales and hence a straight conversion
    factor would recalibrate the two variables.
]

opt2[info() specifies that the percentage of points outside the limits of agreement are displayed as a
        subtitle. Additionally when using the notrend option the limits of agreement and mean
        difference are included in the subtitle.]
opt2[ valabel() specifies that the points outside the limits of agreement be labelled using the
        variable varname.]
opt2[shading() specifies the extent of shading beyond the range of the data. The default is that
        the limits of shading is determined by the values in the xlabel option.]
opt2[dp() specifies the precision of the numbers in the title of the graph. The default is 2 decimal
        places.]

opt2[notrend() specifies that the original Bland-Altman plot (without a trend) be plotted.]

opt2[moptions() specifies options for the markers that lie outside the limits of agreement, the options
        can be anything from the scatter marker options.]
opt2[scatter() specifies options for the scatter part of the final plot.]

example[
    Using the auto.dta dataset supplied with STATA 8 this command can check whether there is agreement
    between turning circle (ft) and miles per gallon, click the highlighted text in order,

    {stata sysuse auto, clear}

    {stata batplot mpg turn}

    This is the most basic graphic and using twoway options the look can be improved by clicking below,

    {stata batplot mpg turn, title(Agreement between mpg and turn) xlab(26(4)38)}

    By specifying extra options the outlying points can be labelled and identified by the car make,

    {stata batplot mpg turn, title(Agreement between mpg and turn) info valabel(make) xlab(26(4)38)}

    To obtain the original Bland Altman plot use the notrend option,

    {stata batplot mpg turn, title(Agreement between mpg and turn) info valabel(make) notrend xlab(26(4)38)}

    To improve the labelling of the point VW it may be preferable to change the clock position of the
    label i.e.  labels could appear to the left of the point. This is handled below with moptions().

    {stata batplot mpg turn, title(Agreement between mpg and turn) info valabel(make) notrend xlab(26(4)38) moptions(mlabp(9))}

    Additionally in the case of multiple scatter points by using the scatter() option the user can
    specify to "jitter" datapoints

    {stata batplot mpg turn, notrend xlab(26(4)38) moptions(mlabp(9)) sc(jitter(4))}

]

author[Prof Adrian Mander]
institute[Cardiff University]
email[mandera@cardiff.ac.uk]

freetext[]

END HELP FILE */


prog def batplot, rclass

/* Allow use on earlier versions of stata that have not been fully tested */
 local version = _caller()
 local myversion = 16.0
 if `version' < `myversion' {
    di "{err}WARNING: Tested only for Stata version `myversion' and higher."
    di "{err}Your Stata version `version' is not officially supported."
 }
 else {
   version `myversion'
 }

syntax varlist (min=2 max=2) [if] [in] [,NOtrend INFO VALabel(varname) MOPTIONS(string asis) XLABel(passthru) SHADING(numlist min=2 max=2) SCatter(string asis) NOGraph DP(int 2) *]
local gopt "`options'"

if "`moptions'"~="" local mopt `"moptions(`moptions')"'

preserve
tempvar touse
mark `touse' `if' `in'
markout `touse' `m1' `m2'
qui keep if `touse'

/* If people put in text in the xlabel then this will fail */
if "`xlabel'"~="" {
  local glab `"`xlabel'"'
  local i 0
  /* Just in case xlabel contains things after the comma */
  tokenize `"`xlabel'"', parse(",")
  local xlabel_numbers `"`1'"'
  /* if no comma I need to strip out the last bracket */
  if "`3'"==""   local xlabel_numbers = substr( `"`xlabel_numbers'"', 1,strrpos(`"`xlabel_numbers'"', ")")-1)
  local xlabel_numbers = substr( `"`xlabel_numbers'"',strpos(`"`xlabel_numbers'"', "xlabel(")+7,.)
  foreach xv of numlist `xlabel_numbers' {
    if `i++'==0 local sxmin "`xv'"
    local sxmax "`xv'"
  }
  local shade "shade(`sxmin' `sxmax')"
}

/* To stop the shading going the whole length of the x-axis */
if "`shading'"~="" {
  local i 0
  foreach s of local shading {
    if `i++'==0 local smin "`s'"
    else local smax "`s'"
  }
  if `smin'<`smax' local shade "shade(`smin' `smax')"
  else local shade "shade(`smax' `smin')"
}


/* NOW do the trend version */

if "`valabel'"~="" local add "val(`valabel')"

_calctrend `varlist', `gopt' `notrend' `info' `add' `mopt' sc(`scatter') `glab' `shade' `nograph' dp(`dp')


  return local mean = "`r(mean)'"
  return local b0 = "`r(b0)'"
  return local b1 = "`r(b1)'"
  return local c0 = "`r(c0)'"
  return local c1 = "`r(c1)'"
  return local eqn = "`r(eqn)'"
  return local upper = "`r(upper)'"
  return local lower = "`r(lower)'"

restore
end


/* calculate trend and do a BA plot with trend */

prog def _calctrend,rclass
syntax [varlist] [,NOTREND INFO VALabel(varname) MOPTIONS(string asis) SCatter(string asis) shade(numlist) NOGraph DP(int 2) *]
local xopt "`options'"

if "`shade'"~="" {
  local i 0
  foreach s of local shade {
    if `i++'==0 local a "`s'"
    local b "`s'"
  }
  local sxmin = `a'
  local sxmax = `b'
}

local i 1
foreach var of varlist `varlist' {
  local v`i++' "`var'"
}

tempvar av diff

qui gen `av' = (`v1' + `v2')/2 
qui gen `diff' = `v1' - `v2'
local ytit "Difference (`v1'-`v2')"
local xtit "Average of `v1' and `v2'"

lab var `diff' "Diff"
lab var `av' "Mean"

if "`notrend'"~="" {
  qui summ `diff'
  local xbar = `r(mean)'
  local sd = `r(Var)'^.5
  local n = `r(N)'
  local se = `sd'/`n'^.5
  local t = invttail(`n'-1, .95)
  local lrr = `xbar' - invnorm(0.975)*`sd'  /* 95% lower limit of agreement */
  local urr = `xbar' + invnorm(0.975)*`sd'  /* 95% upper limit of agreement */
  local mrr = `xbar'                        /* 95% mean agreement */

  di "{text}Mean difference     = {res}`mrr'"
  di "{text}Limits of agreement = ({res}`lrr'{text},{res}`urr'{text})"

  local min = `r(min)'
  local max = `r(max)'
  local lcb = `xbar' - `t'*`se'
  local ucb = `xbar' + `t'*`se'
  qui summ `av'
  local xmin = `r(min)'
  local xmax = `r(max)'
  local a : di %5.3f `xmin'
  local b : di %5.3f `xmax'
  local range = "Averages lie between `a' and `b'"
  di "{text}Averages lie between {res} `a' {text}and {res}`b'"
  qui corr `av' `diff'
  local r = `r(rho)'
  local n = `r(N)'
  local sig = ttail(`n'-2, `r'*((`n'-2)/(1-`r'^2))^.5)

  tempvar uy ly my

/* The bit to extend the shade */

  local obs =`c(N)'+2
  qui set obs `obs'
  if "`sxmin'"~="" qui replace `av'=`sxmin' in `obs--'
  if "`sxmax'"~="" qui replace `av'=`sxmax' in `obs'

  qui gen `uy' = `urr'
  qui gen `ly' = `lrr'
  qui gen `my' = `mrr'

  sort `av'

  if "`info'"~="" {
    local te1:di %6.3f `mrr'
    local te2:di %6.3f `lrr'
    local te3:di %6.3f `urr'

    qui count if (`diff'>`urr' | `diff'<`lrr' ) & `diff'~=.
    local nout = `r(N)'
    qui count if `diff'~=.
    local n = `r(N)'
    local pctout : di %6.2f `nout'/`n'*100
    local xopt `"`xopt' subtitle("`nout'/`n' = `pctout'% outside the limits of agreement" "Mean difference `te1'" "95% limits of agreement (`te2',`te3')" "`range'") "'
  }
  if "`valabel'"~="" {
    tempvar label
    qui gen `label' = ""
    cap confirm string variable `valabel'
    if _rc~=0 qui replace `label' = string(`valabel') if `diff'>`urr' | `diff'<`lrr'
    else qui replace `label' = `valabel' if `diff'>`urr' | `diff'<`lrr'
    local scatteropt "mlabel(`label') note(Points outside limits labelled by `valabel')"
  }

  tempvar freq
  qui bysort `diff' `av':gen  `freq'=_N
  local fopt "[fw=`freq']"
  if index("`scatter'","jitter")~=0 local fopt ""

if "`nograph'"=="" twoway (rarea `uy' `ly' `av', bc(gs13) sort) (scatter `diff' `av' `fopt', m(o) `scatteropt' `scatter' `moptions' ) (line `my' `av',lp(dash) sort ) , ////
 legend(off) ytitle(`ytit') xtitle(`xtit') xlabel(`xmin' `xmax') `xopt'

  return local lower = `lrr'
  return local upper = `urr'
  return local mean = `mrr'
}

else {
  qui reg `diff' `av'
  local b1 = _b[`av']
  local b0 = _b[_cons]
  local sd = `e(rmse)'
  qui predict resid , resid
  qui gen absresid = abs(resid)

  /* Analysis of the residuals */

  qui reg absresid `av'
  local c0 = _b[_cons]
  local c1=_b[`av']

  qui su `diff'
  local max = `r(max)'
  local min = `r(min)'
  qui su `av'
  local xmax = r(max)
  local xmin = r(min)

  local max: di %5.3f `xmax'
  local min: di %5.3f `xmin'

  tempvar y uy ly  x

/* The bit to extend the shade */

  local obs =`c(N)'+2
  qui set obs `obs'
  if "`sxmin'"~="" qui replace `av'=`sxmin' in `obs--'
  if "`sxmax'"~="" qui replace `av'=`sxmax' in `obs'

  sort `av'
  qui gen `y' = `b0'+`b1'*`av'
  qui gen `uy' = `b0'+`b1'*`av' + 2.46*(`c0'+`c1'*`av')
  qui gen `ly' = `b0'+`b1'*`av' - 2.46*(`c0'+`c1'*`av')

  if "`info'"~="" {
    qui count if (`diff'>`uy' | `diff'<`ly') & `diff'~=.
    local nout = `r(N)'
    qui count if `diff'~=.
    local n = `r(N)'
    local mdp = `dp'+3
    local mdp1 = `dp'+4
    
    local pctout : di %`mdp1'.`dp'f `nout'/`n'*100
    local te0 : di %`mdp'.`dp'f `b0'
    local te1 : di %`mdp'.`dp'f `b1'
    local te2 : di %`mdp'.`dp'f `c0'
    local te3 : di %`mdp'.`dp'f `c1'
    local xopt `"`xopt' subtitle("`nout'/`n' = `pctout'% outside the limits of agreement" "Mean Diff = `te0'+ `te1'*Average " "Limits +/- 2.46*(`te2' + `te3'*Average) ") "'
  }
  if "`valabel'"~="" {
    tempvar label
    qui gen `label' = ""
    cap confirm string variable `valabel'
    if _rc~=0 qui replace `label' = string(`valabel') if `diff'>`uy' | `diff'<`ly'
    else qui replace `label' = `valabel' if `diff'>`uy' | `diff'<`ly'
    local scatteropt "mlabel(`label') note(Points outside limits labelled by `valabel')"
  }

  tempvar freq
  qui bysort `diff' `av':gen  `freq'=_N
  local fopt "[fw=`freq']"
  if index("`scatter'","jitter")~=0 local fopt "" 

if "`nograph'"==""  {
   twoway (rarea `uy' `ly' `av', bc(gs13) sort)(scatter `diff' `av' `fopt', `scatteropt' `scatter') /*
*/(line `y' `av', lp(dash) sort) , legend(off) ytitle(`ytit') xtitle(`xtit') xlabel(`xmin' `xmax') `xopt'
}

  return local b0 = `b0'
  return local b1 = `b1'
  return local c0 = `c0'
  return local c1 = `c1'
  return local eqn = "`b0'+`b1'*av"
  return local upper = "`b0'+`b1'*Average + 2.46*(`c0'+`c1'*Average)"
  return local lower = "`b0'+`b1'*Average - 2.46*(`c0'+`c1'*Average)"

}

end
