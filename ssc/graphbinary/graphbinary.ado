*! Date    : 12 July 2005
*! Version : 1.02
*! Author  : Adrian Mander
*! Email   : adrian.mander@mrc-hnr.cam.ac.uk


prog def graphbinary
version 8.2
preserve

syntax varlist [, OR RR Legend(string) Sort(string) SIZE(int 40) Level(int 95) *]
local gopt "`options'"

/* Check if you want risk ratio or odds ratio default is risk ratio */
if "`rr'"=="" & "`or'"=="" local rr "rr"

/* how to sort the lines of the graph */
if "`sort'"=="effect" local sort "`rr' `or'"
else if "`sort'"=="yes" local sort "aa"
else if "`sort'"=="no" local sort "bb"
else if "`sort'"=="name" local sort "b"
else if "`sort'"=="upper" {
  if "`or'"=="" local sort "ur"
  else local sort "uo"
}
else if "`sort'"=="lower" {
  if "`or'"=="" local sort "lr"
  else local sort "lo"
}
else local sort "`rr' `or'"


if "`legend'"~="" local legend "legend(`legend')"

/*Get dependent variable*/
local step 1
foreach var of local varlist {
  if `step++'==1 local depv "`var'"
  else local rest "`rest' `var'"
}

tempfile ade
local step 1
foreach var of local rest {
  qui save "`ade'", replace
  qui inspect `var'
  if `r(N_unique)'>2 {
    di as text "NOTE: `var' is not a binary variable and will be dichotomised at the median"
    qui su `var',de
    if `r(p50)'==`r(min)' {
         di as error "`var' cannot be dichotomised because median = the minimum"
         qui use "`ade'",replace
         continue
    }
    local lab:variable label `var'
    qui gen n`var' = `var'>=`r(p50)'
    lab var n`var' "`lab' (Dichotomised)"
    local var "n`var'"
  }

  /*Calculate the ratios*/
  if "`rr'"~="" {
    qui cs `depv' `var', level(`level')
    qui gen rr = `r(rr)' 
    qui gen lr = `r(lb_rr)' 
    qui gen ur = `r(ub_rr)' 
    local arr "ur lr"
  }
  if "`or'"~="" {
    qui cc `depv' `var', level(`level')
    qui gen or = `r(or)'
    qui gen lo =`r(lb_or)'
    qui gen uo =`r(ub_or)'
    local aor "uo lo"
  }

  qui bysort `depv': gen a= sum(`var'==1)/_N
  qui bysort `depv': gen str b= "`var'"
  local lab : variable label `var'
  qui bysort `depv': gen str blab= "`lab'"
  qui bysort `depv': keep if _n==_N

  qui keep `depv' a b blab `rr' `or' `arr' `aor'

  if `step++'==1 qui save app,replace
  else {
    qui append using app
    qui save app,replace
  }
  qui use "`ade'",replace
}

/* generate the line numbers of the effects */

qui use app,replace
sort b `depv'
qui by b: gen aa=a[2]
qui by b: gen bb=a[1]
qui bysort `sort' b: gen c = _n==1
qui replace c=sum(c)
qui compress

/* Set up the y-axis labels using the variable labels first then variable names if no labels */
local j 1
local lab "ylab("
foreach i of numlist 1(2)`=_N' {
  local nam = blab[`i']
  if "`nam'"=="" local nam = b[`i']
  local lab `"`lab'`j++' "`nam'" "' 
}
local lab `"`lab', angle(0)) ytitle(" ") "'


qui replace a = 100*a

qui twoway (scatter c a if `depv'==0, ms(T)) || (scatter c a if `depv'==1, ms(S)), `lab' xtitle(Percent) legend(ring(0) pos(7) lab(1 No/Low) lab(2 Yes/High)) saving(perc,replace) nodraw plotr(m(l r b+10 t)) `legend'

local files "perc.gph"
if "`rr'"~="" {
  qui twoway (scatter c `rr') || (rcap `arr' c, hor), `lab' xtitle(Risk Ratio (`level'%CI))  xscale(range(0.4 4.1) log) saving(rr,replace) xline(1, lp(dash)) xlab(0.5 1 2 4) yscale(off) fxsize(`size') nodraw legend(off)  plotr(m(l r b+10 t))
  local files "`files' rr.gph"
}
if "`or'"~="" {
  qui twoway (scatter c `or') || (rcap `aor' c, hor), `lab' xtitle(Odds Ratio (`level'%CI))  xscale(range(0.4 4.1) log) saving(or,replace) xline(1, lp(dash)) xlab(0.5 1 2 4) yscale(off) fxsize(`size') nodraw legend(off)  plotr(m(l r b+10 t))
  local files "`files' or.gph"
}

graph combine `files', rows(1) ycommon imargin(0 1 b t) `gopt'

restore
end


