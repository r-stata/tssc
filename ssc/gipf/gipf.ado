*! Date    : 29 Sep 2004
*! Version : 1.06
*! Author  : Adrian Mander
*! Email   : adrian.p.mander@gsk.com

*! e.g.  gipf, m(l1*l2+l4*l8+l3+l2*l6*l7+l5)

prog def gipf
syntax , Model(string) [ NOlegend Gap(integer 0) Order(string) Nodelabel(string asis) Saving(passthru) LWidth(integer 1)]

preserve
clear

/* 
  Parse the model syntax and get the unique varlist 
  Then nloc holds the number of nodes in the dag
*/

local mod "`model'"
while "`model'"~="" {
  gettoken term model: model , parse("+*")
  if "`term'"~="*" & "`term'"~="+" local vlist "`vlist' `term'"
}
local vlist: list uniq vlist
local nloc : list sizeof vlist
local vlist: list sort vlist

if `"`nodelabel'"'~="" {
  local nolab:list sizeof nodelabel
  if `nloc'~=`nolab' {
    di as error "Number of labels (`nolab') does not equal number of nodes (`nloc')!"
    exit(198)
  }
}

/* 
  if the user specifies the order then replace the vlist with a list that the user specifies 
  NOTE: No check is made on whether the order is sensible or whether the variables exist...!
*/

if "`order'"~="" local vlist "`order'"

/* Just create dataset of size number of nodes */

local nloc `nloc'
qui set obs `nloc'

/* 
 To create a gap the number of loci increases... hence gaps occur at the top of the plot 
*/

local nloc_gap = `nloc'+`gap'
qui gen x = sin(_n*2*_pi/`nloc_gap')
qui gen y = cos(_n*2*_pi/`nloc_gap')


/* 
 Generate the labels for the graph nodes.. either from vlist OR the order() option OR nodelabel option
 Put node names  in var name
 Put node labels in var nlab
*/

qui gen name = ""
qui gen nlab = ""

local  i 1
foreach nam of local vlist {
  qui replace name = "`nam'" in `i++'
}

if `"`nodelabel'"'~="" {
  local  i 1
  foreach nam of local nodelabel {
    qui replace nlab = "`nam'" in `i++'
  }
}
else qui replace nlab = name

/* Now create the text statement for the future graph Note it will use node labels if specified*/

forv i=1/`nloc' {
  if `"`nodelabel'"'=="" {
    local x = x[`i']*1.25
    local y = y[`i']*1.25
    local name = name[`i']
    local text `"`text' text(`y' `x' "`name'")"'
  }
  else {
    local x = x[`i']*1.3
    local y = y[`i']*1.3
    local name = nlab[`i']
    local text `"`text' text(`y' `x' "`name'")"'
  }
}


/* Now drawing lines between points -- initialise the nodes*/

local graphi 1
local legord ""
local leglab ""


local model "`mod'"
while "`model'"~="" {
  gettoken term model:model, parse("+")
  /* this gets the independence out now need to join up all these variables */
  local list ""
  while "`term'"~="" {
    gettoken l term:term, parse("*") 
    if "`l'"~="*" {
      if "`list'"=="" local list "`l'"
      else local list "`list' `l'"
    }
  } 
  local slist : list sizeof list
  _binary `slist'
  local temp "`r(bin)'"
  local size = (`slist'-1)*`lwidth'-(`lwidth'-1)

  if `slist'>3 local color "black" /* Might want maroon */
  else local color "black"
  if `slist'>3 local style "######_"
  else local style "solid"

  else local color "black"
  foreach blin of local temp {
    local first = index("`blin'","1")
    local blin = subinstr("`blin'","1","0",1)
    local sec = index("`blin'","1")
    local var1 : word `first' of `list'
    local var2 : word `sec' of `list'
    local graph `"`graph'(line y x if name=="`var1'" | name=="`var2'", clw(*`size') clc(`color') clp(`"`style'"')  graphregion(c(white)) ) || "'
    if "``color'`slist''"=="" {
      local legord "`legord' `graphi'"
      local leglab "`leglab' label(`graphi' "`slist'-way interaction")"
      local `color'`slist' "done"
    }
    local `graphi++'
  }
}


if "`nolegend'"=="" local legend "legend(order(`legord') `leglab')"
else local legend "legend(off)"

twoway `graph' scatter y x, msize(*5) m(O) mc(emidblue) `text' xscale(noline range(-1.4,1.4)) yscale(noline range(-1.4,1.4)) `legend' graphr(margin(l+13 r+13) fc(white)) xmtick(none, notick) ytick(none, nolab) xlab(none, nolab notick) ylab(none, nolab notick) xti(" ") yti(" ") `saving'

restore

end

prog def _binary, rclass
args n

local last = 2^`n'-1
forv nb =1/`last' {
  local bin ""
  local sum 0
  local ade `nb'
  forv j = 1/`n' {
   if mod(`nb',2)==1 {
     local bin "1`bin'"
     local `sum++'
   }
   else local bin "0`bin'"
   local nb = (`nb'-mod(`nb',2))/2
 }
if `sum'==2 local allbin "`allbin' `bin'"
}
return local bin "`allbin'"

end

