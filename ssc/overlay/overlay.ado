*! Date    : 13 May 2002
*! Version : 1.40
*! Author  : Adrian Mander
*! Email   : adrian.p.mander@gsk.com

program define overlay
version 7.0
syntax [varlist] [if] [in], BY(varlist) [SAVING(string) FUNCtion(string) YLAB(numlist) XLAB(numlist) DEBUG ROUND(real 0.001) PEN(string) *]
local gopt "`options'"

marksample touse, s
markout `touse' `by', s

tokenize "`varlist'"

* Error checking for users that insist on not selecting own xlab and ylab

tokenize "`varlist'"
while "`2'"~="" {
  local yvarlist "`yvarlist' `1'"
  mac shift 1
}
local xvar "`1'"

if "`xvar'"=="" { local onevar 1}
else { local onevar 0 }

if `onevar'==1 {
  qui su `yvarlist'
  local xmin = `r(min)'
  local xmax = `r(max)'
}
if `onevar'==0 {
  local ymin 1000000
  local ymax -1000000
  foreach var of local yvarlist {
    qui su `var'
    if `r(min)'< `ymin' { local ymin = `r(min)' }
    if `r(max)'> `ymax' { local ymax = `r(max)' }
  }
  local xmin 100000000
  local xmax -100000000

  foreach var of local xvar {
    qui su `var'
    local xmin = cond(`r(min)'<`xmin',`r(min)',`xmin') 
    local xmax = cond(`r(max)'>`xmax',`r(max)',`xmax') 
  }
}

if "`ylab'"~="" & `onevar'==0{
  tokenize "`ylab'"
  if abs(`ymin'-`1')>0.0001 & `ymin'<`1'{
    di as error "ylab() lower bound error:"
    di "data minimum=`ymin' < ylab minimum=`1'"
    exit(198)
  }
  while "`2'"~="" { mac shift 1}
  if abs(`ymax'-`1')>0.0001 & `ymax'>`1'{
    di as error "ylab() upper bound error:"
    di "data maximum `ymax' > ylab maximum=`1'"
    exit(198)
  }
}
if "`xlab'"~="" {
  tokenize "`xlab'"
  if abs(`xmin'-`1')>0.0001 & `xmin'<`1' {
    di as error "xlab() lower bound error:"
    di "data minimum=`xmin' < xlab minimum=`1'"
    exit(198)
  }
  while "`2'"~="" { mac shift 1}
  if abs(`xmax'-`1')>0.0001 & `xmax'>`1'{
    di as error "xlab() upper bound error:"
    di "data maximum `xmax' > xlab maximum=`1'"
    exit(198)
  }
}

preserve

if "`by'"~="" {
  sort `by'
  tempvar number
  qui by `by': gen `number'=_N
  qui count if `number'<=1
  if `r(N)'>0 {
    di in red "Some groups defined by `by' contain only one member"
    di in red "This may cause the axes to be wrong!"
  }
}
  
if "`if'"~="" {
   keep `if'
}

if "`func'"~="" {
   di "Sometimes overlay.ado will fail to give you the correct graph"
   di "This is due to selecting a function that is not graph"
   di 
   di " The user may have to select XLAB and YLAB options that do not change by group"
   di "See also the end Diagnostics"
}

***********************************************
* How many levels does the by variable have 
* and put them into the matrix mine
***********************************************

tempvar bygrp

if "`by'"~="" {
   sort `by'
   qui by `by': gen `bygrp'=cond(_n==1,1,.)
   qui replace `bygrp'=sum(`bygrp')
   local bylev = `bygrp'[_N]
}

***********************************************
* Saving the file or not.
* NB if file exists it is deleted!!
***********************************************


if ("`saving'"~="") {
   cap confirm new file `saving'.gph
   if _rc~=0 {
      di "Deleteing file...`saving'.gph"
      !rm `saving'.gph
   }
   di "Saving file... `saving'.gph"
   gph open, saving(`saving')
}
else { gph open }

if "`debug'"~="" { gph close }

***********************************************
* Loop through all the levels of the 
* by variable
***********************************************

local bypen 1

local i 1
while `i' <= `bylev' {

   local bypen=`bypen'+1
   local bypen= mod(`bypen',9)
 

   if "`ylab'"=="" & `onevar'==1 {
     local ymin 0
     local ymax 1
   }
   if "`ylab'"=="" {
      *summ `yvar'
      local min=string(round(`ymin',`round'))
      local max=string(round(`ymax',`round' ))
      local mid=string(round(`ymin'+(`ymax'-`ymin')/2,`round' ))
      local ylab = "`min',`mid',`max'"
   }

   if "`xlab'"=="" {
     *summ `xvar'
     local min=string(round(`xmin',`round' ))
     local max=string(round(`xmax',`round' ))
     local mid=string(round(`xmin'+(`xmax'-`xmin')/2,`round' ))
     local xlab = "`min',`mid',`max'"
   }

   if "`pen'"=="" { local pente = `bypen' }
   else { local pente = `pen' }

   if "`debug'"~="" {
      list `bygrp' `by' if `bygrp'==`i'
      di "graph `varlist' if `bygrp'==`i', xlab(`xlab') ylab(`ylab') pen(`pente') `gopt'"
      pause
   }

   if "`function'"=="" { 
     graph `varlist' if `bygrp'==`i' & `touse', xlab(`xlab') ylab(`ylab') pen(`pente') `gopt'
   }
   else {
     cap `function' `varlist' if `bygrp'==`i' & `touse', pen(`pente') xlab(`xlab') ylab(`ylab') `gopt'
     if _rc~=0 {
       local warning "Pen option not working Lines will not be distinct"
       cap `function' `varlist' if `bygrp'==`i' & `touse', xlab(`xlab') ylab(`ylab') `gopt'
       if _rc~=0 {
         local warning "Pen and xlab/ylab options do not work hence the y and x scales might be wrong in the composite graph"
         di "`function' `varlist' if `bygrp'==`i', `gopt'"

         
          `function' `varlist' if `bygrp'==`i' & `touse', `gopt'
        
       }
     }
   }

local i = `i'+1
}

gph close

restore

if "`warning'"~="" {
  di "Extra Diagnostic errors"
  di "-----------------------"
  di "`warning'"
}
end




