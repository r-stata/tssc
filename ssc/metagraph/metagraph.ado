*! Date    : 20 October 2008
*! Version : 1.07
*! Author  : Adrian Mander
*! Email   : adrian.mander@mrc-hnr.cam.ac.uk

/*

12/12/07   v1.05  made sure noline nocombined were options
30/04/08   v1.06  Added in OR lor uor,  NNAME(option)  so more than or se..
20/10/08   v1.07  sort out the label problem, add an if statement
*/


prog def metagraph
version 8.0
preserve
syntax varlist(min=2 max=3) [if] , Id(varname) [ NNAME(varname) eform X(numlist) Textscale(real 0.7) MScale(real 0.19) MLine Level(integer 95) Combined(numlist) NOCOMBINED NOLINE *]

if "`if'"~="" keep `if'

local xtraopt "`options'"

/* Make sure the user inputs the combined estimate */
if "`combined'"=="" & "$S_1"=="" {
  di as error "You either must specify the combined estimate using the combined() option "
  di as error "OR you must have used the meta command to create a combined estimate"
  exit(198)
}
if "`combined'"~="" {
  local i 1
  foreach val of numlist `combined' {
    if `i'==1 global S_1 "`val'" 
    if `i'==2 global S_3 "`val'"
    if `i++'==3 global S_4 "`val'"
  }
  if $S_1 < $S_3 | $S_1 > $S_4 {
    di as error "The pooled estimate $S_1 is not inside the confidence interval ($S_3,$S_4)"
    di as error "Please specify the estimates in combined in the correct order"
    di as error " i.e.  combined( pooled_estimate   lower_limit   upper_limit )"
    exit(198)
  }
}

/* Maintain the original order */
qui gen origord = _n

/* Check out the variable list */
local i 1
foreach var of varlist `varlist' {
  if `i'==1 { 
    local rname "`var'"
    di as text "The variable `rname' contains the parameter estimate"
  }
  if `i'==2 {
    local sname "`var'"
    di as text "The variable `sname' contains the standard error of the  estimate"
  }
  if `i++'==3 {
    local uname "`var'"
    local lname "`sname'"
    di as text "The variable `lname'& `uname' contains lower & upper confidence interval"
  }
}

/* NNAME contains extra information to be printed per line e.g. sample size */

/* 
Now check if any of the riskratios are missing i.e. there are titles and also 
indicate whether there is another variable to be added to the y-label 
rname is the risk
sname is the se
nname is the extra
elsename is another extra
*/


local naxis 1
local idaxis 1
qui count if `rname'==.

/*
 Not sure what this is trying to do BUT it has something to do with subheadings
 Probably need a dataset with subheadings in a column and spaces in parts..
*/

if `r(N)'>0 {
  di
  di as error "NOTE: there are missing values in the parameter estimates! this indicates "
  di as error "that this line of data will be used as a TITLE!"
  local sublab "on"
  local subaxis 2
  local `naxis++'
}
if "`nname'"~="" {
  local nlab "on"
  local var3naxis 1
  local `naxis++'
  if "`subaxis'"=="" local subaxis 2
  else local `subaxis++'
  local `idaxis++'
}
if "`nname'"~="" & "`sublab'"=="" {
  local elab "off"
  local xtra " yscale(off axis(3)) "
}

/* Calculation of the study specific confidence intervals */
if "`eform'"~="" {
  local pre "exp("
  local aft ")"
}
local norm = 1-((100-`level')/200)
qui gen mean = `pre'`rname'`aft'
qui gen uci = `pre'`rname'+invnorm(`norm')*`sname'`aft'
qui gen lci = `pre'`rname'-invnorm(`norm')*`sname'`aft'

/*
Calculate the y-variable for the plot and construct the variable labels i.e. study labels
note that y goes from _N to 1 because of the plotting (goes from 1 to _N)
*/


qui gen y = _N-_n+1
forv i=1/`=_N' {
  local vname = `id'[`i']
  local yval = y[`i']
  local labb `"`labb' `yval' "`vname'""'

  if "`sublab'"=="on" & `rname'[`i']==. local yboldlist "`yboldlist' `yval'" 
  if `rname'[`i']~=. local ylist "`ylist' `yval'"
  if "`nlab'"=="on" {
    local ncell =`nname'[`i']
    cap confirm string variable `nname'
    if _rc==0 {
      if "`ncell'"~="" local labn `"`labn' `yval' "`ncell'""'
    }
    else{
      if `ncell'~=. local labn `"`labn' `yval' "`ncell'""'
    }
  }

}

lab def ylab `labb', modify
lab val y ylab

/* Hold the n-values in y2 with the labels above */
if "`nlab'"=="on" {
  qui gen y2 = y
  lab def y2lab `labn'
  lab val y2 y2lab
}


/* This is the fiddling to get the lines and boxes and box weights */
qui expand 3
sort origord
qui by origord: gen line = cond(_n==1, uci, cond(_n==2, lci,.))

/* Using inverse variance weights*/
qui gen myweight = 1/(`sname'*`sname')
qui su myweight
qui replace myweight = myweight/`r(max)'

qui su y
local ymin = `r(min)'
local ymax = `r(max)'
lab var y ""

/* 
The bit to do the diamond of the combined result remembering to add this into the y-axis!
These are all taken from the meta-command at the moment
 */
local obs =_N

local nocom ""
if "`nocombined'"=="" {
  local nobs = `obs'+5
  qui set obs `nobs'
  qui replace y =. in `obs'
  qui replace line =. in `obs++'
  qui replace y =-1 in `obs'
  qui replace line = $S_3 in `obs++'
  qui replace y =-0.5 in `obs'
  qui replace line = $S_1 in `obs++'
  qui replace y =-1 in `obs'
  qui replace line = $S_4 in `obs++'
  qui replace y =-1.5 in `obs'
  qui replace line = $S_1 in `obs++'
  qui replace y =-1 in `obs'
  qui replace line = $S_3 in `obs++'

  lab def ylab -1 "Combined" , add
  lab val y ylab
  local nocomb "-1"
}

/* How to deal with some of the options */

if "`x'"=="" local xl ""
else local xl "xlab(`x')"
if "`eform'"=="" {
  if "`noline'"=="" local xs "xline(0)"
}
else {
  if "`noline'"=="" local xs "xscale(log) xline(1)"
  else local xs "xscale(log)"
} 
if "`mline'"=="" & "`noline'"=="" local xl2 "xline($S_1, lp(dash))"
else local xl2 ""

/* The graph command */

lab var line "Please use xtitle() to change this  "
lab var mean " "
local ylabopt "labsize(*`textscale') tl(*0) val angle(horizontal) nogrid"

if "`nlab'"=="on" local ngraph `"(scatter y2 line, c(l) ms(i) cmiss(n) yaxis(1) ylabel(`ylist', `ylabopt' axis(1)) ytitle("", axis(1)) yscale(noline axis(1)) ) ||"'
else {
  local axe3 `" yscale(noline axis(3)) ylabel(none,axis(3)) ytitle("",axis(3))"'
  local addaxis "3"
}
if "`sublab'"=="on" local subgraph `"ylabel(`yboldlist', `ylabopt' axis(`subaxis')) yscale(noline axis(`subaxis')) ytitle("", axis(`subaxis')) "'
if "`xtra'"~="" {
  if "`nocombined'"~="" local xtra "ylabel(`ylist', `ylabopt' axis(3)) yscale(off axis(3)) "
  else local xtra "ylabel(-1 `ylist', `ylabopt' axis(3)) yscale(off axis(3)) "
}

twoway  `ngraph'  (scatter y line, c(l) clc(black) ms(i) cmiss(n) yaxis(`idaxis' `subaxis' `addaxis') `xtra') || ////
(scatter y mean [aweight=myweight], mc(black) ms(S) msize(*`mscale')), `xl' `xl2' `xs' ////
ylabel(`nocom' `ylist', `ylabopt' axis(`idaxis')) legend(off) ytitle("", axis(`idaxis')) graphregion(c(white)) ////
yscale(noline axis(`idaxis')) `xtraopt'  `subgraph' `axe3'



restore
end





