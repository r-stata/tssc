*! version 1.0.5  22jul2003 TJS  added flip, mixed, logical switches
program define metatrim
version 6.0
* version 1.0.3  30jan2001 TJS  touched for version 7.0
* version 1.0.2  17mar2000 TJS
*
*! syntax: metatrim varlist [if] [in] [ , Vari CI REffect PRint Funnel
*!         EForm LEvel(real 95) ESTimat(R|L|Q) GRaph IDvar(varname)
*!         FLIP MIXED SAve(filename [, REPLACE]) * ]

if "`*'" == "" {
  di _n "Syntax is:"
  di in wh "metatrim " in gr "{ theta { se | var } | " _c
  di in gr "exp(theta) ll ul [cl] } [" in wh "if " _c
  di in gr "exp] [" in wh "in " in gr "range]"
  di in gr "                    [" in wh ", "  _c
  di in gr "{ " in wh "v" in gr "ar | " in wh "ci" in gr " } " _c
  di in wh "re" in gr "ffect " in wh "pr" in gr "int " in wh "est" _c
  di in gr "imator" in wh "(" in gr "{ r | L | q }" in wh ")"
  di in gr "                       lev" in gr "el " in wh "f" _c
  di in gr "unnel" in wh " flip mixed id" in gr "var" _c
  di in wh "(" in gr "var" in wh ") gr" in gr "aph graph_options]"
  di _n in gr "           where { a | b |...} means choose" _c
  di in gr " one and only one of {a, b, ...}"
  exit
}

* Setup

syntax varlist(numeric min=2 max=4) [if] [in]  /*
  */ [ , Vari CI REffect Funnel LEvel(real 95) FLIP MIXED /*
  */     ESTimat(str) GRaph IDvar(varname) SAve(string) * ]
marksample touse
tokenize `varlist'

tempvar theta setheta var zz effect sr delta ceffect order em
tempvar sgnrank tn minsrnk diff sdiff fill fillse id

local theta `1'
if "`3'" == "" { local setheta `2' }
  else {
    tempvar ll ul cl
    local ll `2'
    local ul `3'
    local cl `4'
  }

* convert switches to logicals
local    vari = "`vari'"    == "vari"
local      ci = "`ci'"      == "ci"
local reffect = "`reffect'" == "reffect"
local  funnel = "`funnel'"  == "funnel"
local    flip = "`flip'"    == "flip"
local   mixed = "`mixed'"   == "mixed"
local   graph = "`graph'"   == "graph"
local   eform = "`eform'"   == "eform"
local   print = "`print'"   == "print"
local   no_ul = "`ul'"      == ""

* input error traps

if `ci' & `vari' {
  di _n in re "Error: options 'ci' and 'var' cannot " _c
  di    in re "be specified together."
  exit
}
if `ci' & !`no_ul' {
  di _n in bl "Note: option 'ci' specified."
}
if `ci' & `no_ul' {
  di _n in re "Error: option 'ci' specified but varlist " _c
  di    in re "has only 2 variables."
  exit
}
if !`ci' & !`vari' & !`no_ul' {
  di _n in bl "Warning: varlist has 3 variables but option " _c
  di    in bl "'ci' not specified; 'ci' assumed."
  local ci 1
  local vari 0
}
if `vari' & !`no_ul' {
  di _n in re "Error: option 'var' specified but varlist " _c
  di    in re "has more than 2 variables."
  exit
}
if `vari' & `no_ul' {
  di _n in bl "Note: option 'var' specified."
}
if !`vari' & `no_ul' {
  di _n in bl "Note: default data input format (theta, " _c
  di    in bl "se_theta) assumed."
}
if "`estimat'" == "" { local est = "L" }
if "`estimat'" != "" {
  local est = substr(upper(trim("`estimat'")), 1, 1)
  if index("RLQ", "`est'") == 0 {
    di _n in bl "Warning: invalid parameter for estimat(); " _c
    di    in bl "default linear estimator used."
    local est = "L"
  }
}

* Select data to analyze

if `no_ul' { markout `touse' `theta' `setheta' }
      else { markout `touse' `theta' `ll' `ul' }

preserve                /* Note: data preserved here */
qui drop if !`touse'
if _N == 0 { error 2000 }

* Do calculations

if `vari' { qui replace `setheta' = sqrt(`setheta')}

if `ci' {
  capture confirm variable `cl'
  if _rc ~= 0 { qui gen `zz' = invnorm(.975) }
  else { qui replace `cl' = `cl' * 100 if `cl' < 1
    qui gen `zz' = -1 * invnorm((1 - `cl' / 100) / 2 )
    qui replace `zz' = invnorm(.025) if `zz' == .
  }
  qui gen   `setheta' = (ln(`ul') - ln(`ll')) / 2 / `zz'
  qui replace `theta' = ln(`theta')
}

if `flip' { qui replace `theta' = -`theta' }

* v7 fix
sort `theta' `setheta'
qui gen `order' = _n

local estname = "Linear"
if "`est'" == "R" { local estname = "Run" }
if "`est'" == "Q" { local estname = "Quadratic" }

local modname = "Fixed-effects model"
if `reffect' { local modname = "Random-effects model" }

if "`idvar'" != "" {
  local sf : format `idvar'
  local sf = substr("`sf'", 2, length("`sf'") - 2)
  local sn = max(int(real("`sf'")), 5)
  qui gen str`sf' `id'=`idvar'
}
  else {
    local len = int(log10(_n)) + 8
    qui gen str`len' `id' = "study " + string(_n)
  }

local          n = _N
local       trim = 0
local       flag = 1
local          i = 0
qui gen     `sr' = 0
qui gen `effect' = `theta'

* Looped Calculations

if `flip' {
  qui gen `em' = -`theta'
  meta `em' `setheta' `if'
  qui drop `em'
  local q "qui"
}

while `flag' {
  `q' meta `effect' `setheta' `if'
  if mod(`reffect'+`mixed', 2) { local d = $S_7 }
    else                       { local d = $S_1 }
  qui {
    gen     `delta'   = `d'
    gen     `ceffect' = `theta' - `delta'
    egen    `sgnrank' = rank(abs(`ceffect'))
    replace `sgnrank' = `sgnrank' * sign(`ceffect')
    egen    `minsrnk' = min(`sgnrank')
    egen    `tn'      = sum(`sgnrank') if `sgnrank' > 0
    sort `order'
    local Tn = `tn'[_N]
    if "`est'" == "R" { local trim = `n' - abs(`minsrnk') - 1.5 }
      else if "`est'" == "Q" {
        local trim = `n' -0.5 - sqrt(2 * `n'^2 - 4 * `Tn' + 0.25) }
      else {
        local trim = (4 * `Tn' - `n' * (`n' + 1)) / (2 * `n' - 1) }
    local trim = int(max(0, `trim' + 0.5))
    gen     `diff'  = `sr' - `sgnrank'
    replace `sr'    = `sgnrank'
    egen    `sdiff' = sum(abs(`diff'))
    if `sdiff' == 0 | `i' > 9 { local flag = 0 }
    local i = `i' + 1
    local q "qui"
    sort `order'
    qui replace `effect' = . if _n > _N - `trim'
  }
  if `i' == 1 {
    di
    di in gr "Trimming estimator: " in ye "`estname'"
    if `mixed' { di in gr "Meta-analysis type: " in ye "`modname' initially, but mixed mode" }
    else       { di in gr "Meta-analysis type: " in ye "`modname'" }
    di
    di in gr "iteration |  estimate    Tn    # to trim     diff"
    di in gr "----------+--------------------------------------"
  }

  if `flip' { local df = -`d' }
       else { local df =  `d' }

  di in ye %5.0f `i' in gr "     |" in ye %9.3f `df' %7.0f `Tn' _c
  di in ye %10.0f `trim' %12.0f `sdiff'[_N]

  cap drop `delta' `ceffect' `sgnrank' `tn' `diff' `sdiff' `minsrnk'
}

* Filled analysis setup

if `trim' == 0 { di _n in bl "Note: no trimming performed; data unchanged" }
if `i' > 9     { di _n in bl "Warning: iterative algorithm did not converge" }
local new = _N + `trim'
sort `order'
qui {
  if `trim' > 0 { set obs `new' }
  gen       filled = `theta'
  gen     `fillse' = `setheta'
  gen       `fill' = .
  gen      `delta' = `d'
  replace   filled = 2 * `delta' - filled[_n - `trim'] if _n > _N - `trim'
  replace `fillse' =             `fillse'[_n - `trim'] if _n > _N - `trim'
  replace   `fill' =                            filled if _n > _N - `trim'
  replace     `id' =     "fill " + string(_N - _n + 1) if _n > _N - `trim'
}
sort filled `order'
label var filled "theta, filled"
if `graph' {
  if `reffect' { local gr = "gr(r)" }
          else { local gr = "gr(f)" }
}
di _n in gr "Filled " _c

* Do filled meta-analysis

if `flip' {
  qui replace `fill' = -`fill'
  qui replace filled = -filled
}

meta filled `fillse', id(`id') `gr' `options'

* Graph a funnel plot

if `funnel' {
  if `reffect' { global Xtheta = $S_7 }
          else { global Xtheta = $S_1 }
  if `graph' { more }
  fungph filled `fillse' `fill', level(`level') `options'
}

* Save filled data?

 if "`save'" != "" {
   local c = index("`save'", ",")
   if `c' != 0 {
     local save = substr("`save'", 1, `c' - 1) + substr("`save'", `c' + 1, .)
   }
   local save1 : word 1 of `save'
   local replace : word 2 of `save'
   if "`replace'" == "replace" { capture erase `save1'.dta }
   capture confirm new file `save1'.dta
   if _rc == 0 {
     qui keep `id' filled `fillse'
     rename `id' id
     rename `fillse' fillse
     lab var id "study ID"
     lab var fillse "S.E. of theta, filled"
     lab data "trimed and filled $S_FN"
     di
     save `save1'
   }
   else {
     local rc = _rc
     di _n in re "File `save1' exists. Use 'replace' option: save(filename, replace)."
     exit `rc'
   }
 }

exit
end

* ***************************************************

program define fungph
version 6.0

* creates a filled funnel plot graph

* Setup

syntax varlist(min=3 max=3) [if] [in] [, CI L1title(str)  /*
  */ L2title(str) Connect(str) Symbol(str) SOrt Pen(str)  /*
  */ T2title(str) B2title(str) XLAbel YLAbel YLAbel(str)  /*
  */ XLAbel(str) LEVel(integer $S_level) GAp(str) GWeight /*
  */ EForm /* ...the following are trapped but never used...
  */ GRaph(str) PRint CLine XLIne(str) FMult(str) EBayes  /*
  */ BOXYsca(str) BOXSHad(str) LTRunc(str) RTRunc(str)    /*
  */  * ]
tokenize `varlist'

tempvar theta setheta

local theta    `1'
local setheta  `2'
local fill     `3'

preserve        /* Note: data preserved here */

* Graph options

if "`connect'" == "" { local connect "lll.." }
  else {
    local lll = length("`connect'")
    if      `lll' == 1 { local connect "`connect'll.." }
    else if `lll' == 2 { local connect "`connect'l.." }
    else if `lll' == 3 { local connect "`connect'.." }
    else if `lll' == 4 { local connect "`connect'." }
  }
local connect "co(`connect')"

if "`symbol'" == "" { local symbol "iiioS" }
  else {
    local lll = length("`symbol'")
    if      `lll' == 1 { local symbol "`symbol'iioS" }
    else if `lll' == 2 { local symbol "`symbol'ioS" }
    else if `lll' == 3 { local symbol "`symbol'oS" }
    else if `lll' == 4 { local symbol "`symbol'S" }
  }
local symbol "sy(`symbol')"

if "`pen'" == "" { local pen "35522" }
  else {
    local lll = length("`pen'")
    if      `lll' == 1 { local pen "`pen'5522" }
    else if `lll' == 2 {
    local pen = "`pen'" + substr("`pen'", 2, 1) + "22"
  }
  else if `lll' == 3 { local pen "`pen'22" }
  else if `lll' == 4 {
    local pen = "`pen'" + substr("`pen'", 4, 1)
  }
}
local pen "pen(`pen')"

if "`l2title'" == "" {
  local l2title : variable label `theta'
  if "`l2title'" == "" { local l2title "`theta'" }
}
local titlel2 = "`l2title'"
if "`ci'" == "" { local l2title "l2(`l2title')" }
           else { local l2title "l2(log[`l2title'])" }

if "`l1title'" == "" { local l1title "" "" }
local l1title "l1(`l1title')"

if "`b2title'" == "" { local b2title "`titlel2'" }
if "`ci'" == "" { local b2title = "b2(s.e. of: `b2title')" }
           else { local b2title = "b2(s.e. of: log[`b2title'])" }

if `"`t2title'"' == `""' {
  local t2title = "Filled funnel plot with pseudo"
  local t2title = "`t2title' `level'% confidence limits"
  local t2title "t2(`"`t2title'"')"
}
  else if `"`t2title'"' == `"."' { local t2title }
  else { local t2title "t2(`"`t2title'"')" }

if "`xlabel'" == "" { local xlabel "xla" }
  else { local xlabel "xlabel(`xlabel')" }

if "`ylabel'" == "" { local ylabel "yla" }
  else { local ylabel "ylabel(`ylabel')" }

if "`sort'" == "" { local sort "sort" }

if "`gap'" == "" { local gap "gap(3)" }
  else { local gap "gap(`gap')" }

* calculations for plot

tempvar ll2 ul2 RRm

qui {
  if `level' < 1 { local `level' =`level' * 100 }
  local z  = -1 * invnorm((1 - `level' / 100) / 2)
  local obs1 = _N + 1
  set obs `obs1'
  replace `setheta'=0 in `obs1'
  replace `theta' = . in `obs1'
  if "`eform'" != "" { global Xtheta = log($Xtheta) }
  gen `RRm' = $Xtheta
  gen `ll2' = `RRm' - `z' * `setheta'
  gen `ul2' = `RRm' + `z' * `setheta'
}

if "`gweight'" != "" {
  tempvar ww
  qui gen `ww' = `w'
  qui replace `ww' = 1 if `setheta' == 0
  local gw "[w = `ww']"
}
  else { local gw "" }

* do plot

#delimit ;
graph `RRm' `ll2' `ul2' `theta' `fill' `setheta' `gw',
  `connect' `symbol' `t2title' `l2title' `b2title'
  `l1title' `xlabel' `ylabel' `sort' `pen' `gap' `options';
#delimit cr

exit
end
