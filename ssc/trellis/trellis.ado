*! Date    : 22 May 2006
*! Version : 1.04
*! Author  : Adrian Mander
*! Email   : adrian.mander@mrc-hnr.cam.ac.uk

/*

19/5/06 v1.03 Handle blank graphs
22/5/06 v1.04 Added labels for the by-variable values

*/

prog def trellis
version 8.2

syntax [if], BY(varlist numeric min=2 max=2) Function(string) [ SINGLEopt(string asis) FOPT(string asis) SR(int 1) SC(int 1) LABELS *]
local gopt "`options'"

marksample touse

/* The option for the single graph */
if `"`singleopt'"'=="" local singleopt `"`fopt'"'

/* a little check on the function() option rootg  has the graphics function word */
local iword 1
foreach item of local function {
  if `iword'==1 local root "`item'"
  if `iword++'==2 local rootg "`item'"
}

/*
 * Inspect the by variables  and make lev1 and lev2 containing the levels
 * put the labels in the macro llev1 llev2
 */
local i 1
foreach var of local by {
  local llev`i': value label `var'
  local var`i' "`var'"
  qui levels `var' if `touse'
  local lev`i' "`r(levels)'"
  local max`i' :list sizeof lev`i++'
}


/* i becomes the columns  and j are the rows */

local graphlist ""
local i 1
foreach c of local lev1 {
  local j 1
  foreach r of local lev2 {

  /* Put labels on the by-variables used to create the trellis
   * There is a scaling problem with this that isn't really sorted out..
   */
  if "`labels'"~="" {
    local temp: label `llev1' `c'
    local xtra1 `"title("`var1'" "`temp'", size(*0.7)) "'
    local temp: label `llev2' `r'
    if length("`temp'")>13 di _newline as error "WARNING: the value label `temp' for `var2' is over 13 characters and some text may be overlapping"
    local adjust 0.8
    local xtra2 `"subtitle("`var2'" "`temp'", orient(vertical) ring(1) pos(9) size(*`adjust')) "'
  }
  else {
    local xtra1 `"title("`var1' `c'") "'
    local xtra2 `"subtitle("`var2' `r'", ring(1) pos(9) size(*1.3))"'
  }

/* if i is 1 need the x-axis on the top 
 * Need to change some of the options according to the graph function.. some allow yscaling etc...
 */

    local mygo ""
    local blankgraph ""

    /* WHAT to do on row 1 i.e. make the sure the title has the levels of the variable */
    if `j'==1 {
      local blankgraph `"`xtra1' "'
      if "`rootg'"=="box"         local mygo `"`xtra1' xalt"'
      else if "`rootg'"=="hbox"   local mygo `"`xtra1' yalt"'
      else if "`rootg'"=="bar"    local mygo `"`xtra1' xalt"'
      else if "`rootg'"=="hbar"   local mygo `"`xtra1' yalt"'
      else if "`rootg'"=="dot"    local mygo `"`xtra1' yalt "'
      else if "`rootg'"=="pie"    local mygo `"`xtra1' "'
      else if "`rootg'"=="matrix" local mygo `"`xtra1' "'
      else                        local mygo `"xscale(alt) `xtra1' "'
    }

    /* What to do on every middle row */

    if `j'~=1 & `j'~=`max2' {
      if "`rootg'"=="box"           local mygo `"`mygo' "'
      else if "`rootg'"=="bar"      local mygo `"`mygo' "'
      else if "`rootg'"=="hbar"     local mygo `"`mygo' yscale(off)"'
      else if "`rootg'"=="hbox"     local mygo `"`mygo' yscale(off)"'
      else if "`rootg'"=="dot"      local mygo `"`mygo' yscale(off) "'
      else if "`rootg'"=="pie"      local mygo `"`mygo'  "'
      else if "`rootg'"=="matrix"   local mygo `"xscale(off) "'
      else local mygo `"xscale(off) "'
    }

/* 
  this doesn't work because it messes up the width of the plot!
    if `j'~=`max2' local mygo `"`mygo' legend(off) "'
*/

    if `i'~=`max1' & `i'~=1 {
       if "`rootg'"=="box"          local mygo `"`mygo' yscale(off) "'
       else if "`rootg'"=="bar"     local mygo `"`mygo' yscale(off) "'
       else if "`rootg'"=="hbar"    local mygo `"`mygo' yscale(off) "'
       else if "`rootg'"=="hbox"    local mygo `"`mygo' yscale(off) "'
       else if "`rootg'"=="dot"     local mygo `"`mygo' "'
       else if "`rootg'"=="pie"     local mygo `"`mygo' "'
       else if "`rootg'"=="matrix"  local mygo `"`mygo'"'
       else local mygo `"`mygo' yscale(off)"'
    }

/* last column */     
    if `i'==`max1' {
      if "`rootg'"=="box"          local mygo `"`mygo' yalt "'
      else if "`rootg'"=="bar"     local mygo `"`mygo' yalt "'
      else if "`rootg'"=="hbar"    local mygo `"`mygo' xalt "'
      else if "`rootg'"=="hbox"    local mygo `"`mygo' xalt "'
      else if "`rootg'"=="dot"     local mygo `"`mygo' xalt "'
      else if "`rootg'"=="pie"     local mygo `"`mygo' "'
      else if "`rootg'"=="matrix"  local mygo `"`mygo'"'
      else local mygo `"`mygo' yscale(alt)"'
    }
/* First column*/
    if `i'==1 {
      local mygo `"`mygo' `xtra2'"'
      local blankgraph `"`blankgraph' `xtra2' "'
    }

    local graphlist "`graphlist' trell`i'_`j'.gph"

/*
 The part that runs the graphs 
 Check if there is any data to draw
*/
    if `i'==`sc' & `j'==`sr' {
     qui count if `var1'==`c' & `var2'==`r' & `touse'
     if `r(N)'==0 {
        di _newline as red "There are no observations when `var1' is `c' and `var2' is `r' BLANK graph inserted"
        qui twoway function y=x,nodraw lc(white) xscale(off) yscale(off) graphr(c(white)) `blankgraph' saving(trell`i'_`j',replace)
     }
     else qui `function' if `var1'==`c' & `var2'==`r' & `touse' ,nodraw `mygo' saving(trell`i'_`j',replace)  `singleopt'
    }
    else {
     qui count if `var1'==`c' & `var2'==`r' & `touse'
     if `r(N)'==0 {
        di _newline as red "There are no observations when `var1' is `c' and `var2' is `r' BLANK graph inserted"
        qui twoway function y=x,nodraw lc(white) xscale(off) yscale(off) `blankgraph' saving(trell`i'_`j',replace)
     }
     else qui `function' if `var1'==`c' & `var2'==`r' & `touse',nodraw  `mygo' saving(trell`i'_`j',replace)  `fopt'
    }
    di as res _continue "."
    local `j++'
  }
  local `i++'
}

graph combine `graphlist', im(0 0 0 0) ycommon xcommon colfirst `gopt' rows(`max2')

end


