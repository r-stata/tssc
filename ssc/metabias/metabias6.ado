*! metabias version 1.2.4  08sep03 TJS   fixed stratified Egger p-value
program define metabias6, rclass
version 6.0
*  version 1.0.0  24oct97 TJS   STB-41 sbe19
*  version 1.1.2  21apr98 TJS   Unweighted Egger analysis only STB-44 sbe19.1
*  version 1.1.3   1oct99 TJS   fixed stratified bug STB-44 sbe19.1
*  version 1.2.0  17feb00 TJS   Version 6 and gweight option (STB-57: sbe19.2)
*  version 1.2.1  31jan01 TJS   touched for version 7.0
*  version 1.2.2  07feb01 TJS   touched (again) for version 7.0
*
*! syntax: metabias varlist [if] [in]
*!     [ , Graph(str) GWeight Vari CI BY(varname) LEvel(real 95) * ]

if ("`*'" == "") {
  di "Syntax is:"
  di in wh "metabias " in gr "{ theta { se | var } | " _c
  di in gr "exp(theta) | ll ul [cl] } [" _c
  di in wh "if " in gr "exp] [" in wh "in " in gr "range]"
  di in gr "             [ " in wh ", by(" in gr "by_var"in wh ")" _c
  di in gr " { " in wh "v" in gr "ar | " in wh "ci" in gr " } " _c
  di in wh "g" in gr "raph" in wh "(" in gr "{ " in wh "b" _c
  di in gr "egg | " in wh "e" in gr "gger }" in wh ")"
  di in wh "                 gw" in gr "eight" in wh " lev" _c
  di in gr "el" in wh "(" in gr "#" in wh ") " in gr "graph_options ]"
  di _n in gr "           where { a | b |...} means choose" _c
  di in gr " one and only one of {a, b, ...}"
  exit
}

* Setup
syntax varlist(numeric min=2 max=4) [if] [in] /*
  */ [ ,  Graph(str) Vari CI BY(varname) LEvel(real 95) * ]
* Note: option GWeight is passed via * directly to the graphics subs
marksample touse
tokenize `varlist'

tempvar byg theta setheta var w sw vt wtheta swtheta
tempvar zz Ts wl swl RRm bylabel
tempname k ks sdks p zu pcc zcc c sks svks sk oe sbv sv
tempvar bylabl

local theta `1'
if "`3'" == "" { local setheta `2' }
else {
  tempvar ll ul cl
  local ll `2'
  local ul `3'
  local cl `4'
}

* input error traps
if "`ci'" != "" & "`vari'" != "" {
  di _n in re "Error: options 'ci' and 'var' cannot " _c
  di in re "be specified together."
  exit
}
if "`ci'" == "ci" & "`ul'" != "" {
  di _n in bl "Note: option 'ci' specified."
}
if "`ci'" == "ci" & "`ul'" == "" {
  di _n in re "Error: option 'ci' specified but varlist " _c
  di in re "has only 2 variables."
  exit
}
if "`ci'" != "ci" & "`vari'" != "vari" & "`ul'" != "" {
  di _n in bl "Warning: varlist has 3 variables but option " _c
  di in bl "'ci' not specified; 'ci' assumed."
  local ci "ci"
  local vari ""
}
if "`vari'" == "vari" & "`ul'" != "" {
  di _n in re "Error: option 'var' specified but varlist " _c
  di in re "has more than 2 variables."
  exit
}
if "`vari'" == "vari" & "`ul'" == "" {
  di _n in bl "Note: option 'var' specified."
}
if "`vari'" != "vari" & "`ul'" == "" {
  di _n in bl "Note: default data input format (theta, " _c
  di in bl "se_theta) assumed."
}

* Select data to analyze
if "`ul'" == "" { markout `touse' `theta' `setheta' }
           else { markout `touse' `theta' `ll' `ul' }

preserve                /* Note: data preserved here */

* Generate `by' groups
if "`by'" != "" {
  confirm var `by'
  sort `by'
  qui by `by': gen byte `byg' = _n==1
  qui replace `byg' = sum(`byg')
  local byn = `byg'[_N]
}
else {
  qui gen byte `byg' = 1
  local byn = 1
}

* Generate `by' labels -- if required (corrected code)
if "`by'" != "" {
  local vallab : value label `by'
  if "`vallab'" == "" {
   local type : type `by'
     if substr("`type'",1,3) != "str" {
       qui gen `bylabl' = `by'
       numvlab `bylabl'
     }
     else {
       encode `by', gen(`bylabl')
     }
  }
  else {
    qui gen `bylabl' = `by'
    label val `bylabl' `vallab'
  }
}

* Do calculations
* initial calculations...
if "`vari'" == "vari" { qui replace `setheta' = sqrt(`setheta')}

if "`ci'" == "ci" {
  capture confirm variable `cl'
  if _rc~=0 { qui gen `zz'  = invnorm(.975) }
  else {
    qui replace `cl' = `cl' * 100 if `cl' < 1
    qui gen `zz' = -1 * invnorm((1- `cl' / 100) / 2 )
    qui replace `zz' = invnorm(.025) if `zz'==.
  }
  qui gen   `setheta' = ( ln(`ul') - ln(`ll')) / 2 / `zz'
  qui replace `theta' = ln(`theta')
}

if "`if'" != "" { ifexp "`if'" }

if "`by'" != "" {
  scalar `sk'   = 0
  scalar `sks'  = 0
  scalar `svks' = 0
  scalar `sbv'  = 0
  scalar `sv'   = 0
}

* loop through by-values
local j = 1
while `j' <= `byn' {      /* start of loop for each `by' group */

  summ `touse' if `touse' & `byg' == `j', meanonly
  local data = _result(1)

* Calculate stats
  qui {
    gen  `var'     = `setheta'^2
    gen  `w'       = 1/`var'
    egen `sw'      = sum(`w') if `touse' & `byg' == `j'
    gen  `vt'      = `var' - 1 / `sw'
    gen  `wtheta'  = `w' * `theta'
    egen `swtheta' = sum(`wtheta') if `touse' & `byg' == `j'
    gen  `Ts'      = (`theta' - `swtheta' / `sw') / sqrt(`vt')
    gen  `wl'      = `w' * `theta'
    egen `swl'     = sum(`wl') if `touse' & `byg' == `j'
    gen  `RRm'     = `swl' / `sw'
    scalar `oe'    = `RRm'
  }

  qui capture ktau2 `var' `Ts' if `touse' & `byg' == `j'
  if _rc == 0 {
    scalar `k'    = $S_1
    scalar `ks'   = $S_4
    scalar `sdks' = $S_5
    scalar `p'    = $S_6
    scalar `zu'   = $S_7
    scalar `pcc'  = $S_8
    scalar `zcc'  = $S_9
    scalar `c'    = $S_10
  }
  else if _rc == 2001 {
    scalar `k'    = `data'
    scalar `ks'   = .
    scalar `sdks' = .
    scalar `p'    = .
    scalar `zu'   = .
    scalar `pcc'  = .
    scalar `zcc'  = .
    scalar `c'    = .
  }
  else {
    di in re "error " _rc " in call to ktau2"
    exit
  }

  if "`by'" != "" & `k' > 1 {
    scalar `sk'   = `sk'   + `k'
    scalar `sks'  = `sks'  + `ks'
    scalar `svks' = `svks' + `sdks'^2
  }

* Egger's bias test
  tempvar prec snd
  qui gen `prec'= 1 / `setheta'
  qui gen `snd' = `theta' / `setheta'
  qui regr `snd' `prec' if `touse' & `byg' == `j'
  capture matrix b = get(_b)
  if _rc == 0 {
    local df = e(N) - 2
    local bias = b[1,2]
    capture matrix V = get(VCE)
    if _rc == 0 {
      local pb = tprob(`df', b[1,2] / sqrt(V[2,2]))
      if "`by'" != "" & V[2,2] != 0 & `data' > 0 {
        scalar `sbv' = `sbv' + `bias' / V[2,2]
        scalar `sv'  = `sv' + 1 / V[2,2]
      }
    }
  }
  else {
    local bias = .
    local pb = .
  }

* Display results
  if "`by'" != "" {
* use this display if a by_var was specified...
* .....display output header
    if `j' == 1 {
      di " "
      di in gr "Tests for Publication Bias"
      di " "
      local sp = 8 - length("`by'")
      #delimit ;
      di in gr "-------------------------------------------------"
         "------------------------------" ;
      di in gr "         |      |    Begg's           Begg's"
         "       cont. corr.  |    Egger's " ;
      di in gr _skip(`sp') "`by' |    n | score    s.d.      z"
        "      p        z      p   |  bias     p" ;
      di in gr "---------+------+--------------------------------"
         "---------------+--------------" ;
      #delimit cr
      local scs " "
    }
    local blab: label (`bylabl') `j'
    local sp = 8 - length("`blab'")

    if `c' == 1 {
      local cs  "*"
      local scs "*"
    }
    else {local cs " "}
* .....display results for each by-value
    if `data' > 0 {
      di in gr _skip(`sp')     "`blab' | " in ye %4.0f `k' _c
      di in gr " |" in ye %4.0f `ks' in gr "`cs'   " _c
      di in ye %6.3f `sdks' "  " %6.2f `zu' "  " %6.3f `p' "  " _c
      di in ye %6.2f `zcc'  "  " %6.3f `pcc' in gr " |" _c
      di in ye %6.2f `bias' "  " %6.3f `pb'
    }
* .....do stratified calculations
    if `j' == `byn' {
      scalar `zu'   = `sks' / sqrt(`svks')
      scalar `p'    = 2 * (1 - normprob(abs(`zu')))
      scalar `zcc'  = sign(`sks')*(abs(`sks') - 1) / sqrt(`svks')
      scalar `pcc'  = 2 * (1 - normprob(abs(`zcc')))
      scalar `k'    = `sk'
      scalar `ks'   = `sks'
      scalar `sdks' = sqrt(`svks')
      drop `sw' `wl' `swl' `RRm'
      qui egen  `sw' = sum(`w') if `touse'
      qui gen   `wl' = `w' * `theta'
      qui egen `swl' = sum(`wl') if `touse'
      qui gen  `RRm' = `swl' / `sw'
      scalar    `oe' = `RRm'

      local bias = `sbv' / `sv'
      local pb   = 2 * (1 - normprob(abs(`sbv' / sqrt(`sv'))))

* .....and display overall (stratified) results
      di in gr "---------+------+----------------------------" _c
      di in gr "-------------------+--------------"
      di in gr " overall | " in ye %4.0f `sk' _c
      di in gr " |" in ye %4.0f `sks' in gr "`scs'   " _c
      di in ye %6.3f sqrt(`svks') "  " %6.2f `zu' "  " %6.3f `p' _c
      di in ye "  " %6.2f `zcc'  "  " %6.3f `pcc' in gr " |" _c
      di in ye %6.2f `bias' "  " %6.3f `pb'
      di in gr "---------------------------------------------" _c
      di in gr "----------------------------------"
      if "`scs'" == "*" {
        di in gr _skip(21) "`scs' (corrected for ties)"
      }
    }
  }

  else {

* use this display if no by_var was specified...
* Begg's
    di _n in gr "Tests for Publication Bias"
    di _n in gr "Begg's Test"
    di " "
    di    in gr "  adj. Kendall's Score (P-Q) = " in ye %7.0f `ks'
    di _c in gr "          Std. Dev. of Score = " in ye %7.2f `sdks'
    if `c' == 1 { di in gr " (corrected for ties)" }
           else { di " " }
    di    in gr "           Number of Studies = " in ye %7.0f `k'
    di    in gr "                          z  = " in ye %7.2f `zu'
    di    in gr "                    Pr > |z| = " in ye %7.3f `p'
    di _c in gr "                          z  = " in ye %7.2f `zcc'
    di    in gr " (continuity corrected)"
    di _c in gr "                    Pr > |z| = " in ye %7.3f `pcc'
    di    in gr " (continuity corrected)"

* Egger's
    tempvar prec snd
    qui gen `prec'= 1 / `setheta'
    qui gen `snd' = `theta' / `setheta'
    qui regr `snd' `prec' if `touse'
    capture matrix b = get(_b)
    if _rc == 0 {
      matrix V = get(VCE)
      local obs = e(N)
      local df = `obs' - 2
      matrix colnames b = slope bias
      matrix rownames V = slope bias
      matrix colnames V = slope bias
      matrix post b V, dep(Std_Eff) dof(`df') obs(`obs')
      di _n in gr "Egger's test"
      matrix mlout, level(`level')
    }
    else {
      di _n in gr "Egger's Test" _n
      di    in ye "  - undefined for only 1 study"
    }
  }

  cap drop `var' `w' `sw' `vt' `wtheta' `swtheta'
  cap drop `Ts' `wl' `swl' `RRm'
  local j = `j' + 1

}                            /* end of loop for each `by' group */

* Graph a bias plot
local g = lower(substr("`graph'",1,1))
if "`g'" == "b" {
  beggph `theta' `setheta' `touse', level(`level') `ci' `options'
}
if "`g'" == "e" {
  egggph `theta' `setheta' `touse', level(`level') `options'
}

* Save globals
global S_1 = `k'
global S_2 = `ks'
global S_3 = `sdks'
global S_4 = `p'
global S_5 = `pcc'
global S_6 = `bias'
global S_7 = `pb'
global S_8 = `oe'

* return globals
return scalar k        = `k'
return scalar score    = `ks'
return scalar score_sd = `sdks'
return scalar Begg_p   = `p'
return scalar Begg_pcc = `pcc'
return scalar Egger_bc = `bias'
return scalar Egger_p  = `pb'
return scalar effect   = `oe'

exit
end

* ***************************************************

program define beggph
version 6.0

* creates the Begg funnel plot graph

* Setup

syntax varlist(min=3 max=3) [if] [in] [, CI L1title(str) /*
  */ L2title(str) Connect(str) Symbol(str) SOrt Pen(str) /*
  */ T2title(str) B2title(str) YLAbel(str) XLAbel(str)   /*
  */ LEVel(integer $S_level) GAp(str) GWeight * ]
tokenize `varlist'

tempvar touse theta setheta

local theta    `1'
local setheta  `2'
local touse    `3'

preserve

* Graph options
if "`connect'" == "" { local connect "lll." }
else {
  local lll = length("`connect'")
  if      `lll' == 1 { local connect "`connect'll." }
  else if `lll' == 2 { local connect "`connect'l." }
  else if `lll' == 3 { local connect "`connect'." }
}
local connect "co(`connect')"

if "`symbol'" == "" { local symbol "iiio" }
else {
  local lll = length("`symbol'")
  if      `lll' == 1 { local symbol "`symbol'iio" }
  else if `lll' == 2 { local symbol "`symbol'io" }
  else if `lll' == 3 { local symbol "`symbol'o" }
}
local symbol "sy(`symbol')"

if "`pen'" == "" { local pen "3552" }
else {
  local lll = length("`pen'")
  if      `lll' == 1 { local pen "`pen'552" }
  else if `lll' == 2 {
    local pen = "`pen'" + substr("`pen'",2,1) + "2"
  }
  else if `lll' == 3 { local pen "`pen'2" }
}
local pen "pen(`pen')"

if "`l2title'" == "" {
  local l2title : variable label `theta'
  if "`l2title'" == "" { local l2title "`theta'" }
}
if "`ci'" == "" { local l2title "l2(`l2title')" }
           else { local l2title "l2(log[`l2title'])" }

if "`l1title'" == "" { local l1title "" "" }
local l1title "l1(`l1title')"

if "`b2title'" == "" {
  local b2title : variable label `theta'
  if "`b2title'" == "" { local b2title "`theta'" }
}
if "`ci'" == "" { local b2title = "b2(s.e. of: `b2title')" }
           else { local b2title = "b2(s.e. of: log[`b2title'])" }

if `"`t2title'"' == `""' {
  local t2title = "Begg's funnel plot with pseudo"
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

tempvar ll2 ul2 z mmm var w sw wl swl RRm
tempname oe

qui {
  if `level' < 1 { local `level' =`level' * 100 }
  local z  = -1 * invnorm((1 - `level' / 100) / 2)
  local obs1=_N+1
  set obs `obs1'
  replace `setheta'=0 in `obs1'
  replace `theta' = . in `obs1'
  gen     `var' = `setheta'^2
  gen     `w'   = 1/`var'
  egen    `sw'  = sum(`w') if `touse'
  gen     `wl'  = `w' * `theta'
  egen    `swl' = sum(`wl') if `touse'
  gen     `RRm' = `swl' / `sw'
  scalar  `oe'  = `RRm'
  egen    `mmm' = min(`RRm')
  replace `RRm' = `mmm' if `setheta' == 0
  gen     `ll2' = `RRm' - `z' * `setheta'
  gen     `ul2' = `RRm' + `z' * `setheta'
}

if "`gweight'" != "" {
  tempvar ww
  qui gen `ww' = `w'
  qui replace `ww' = 1 if `setheta' == 0
  local gw "[w=`ww']"
}
else { local gw "" }

#delimit ;
  graph `RRm' `ll2' `ul2' `theta' `setheta' `gw' if `touse',
    `connect' `symbol' `t2title' `l2title' `b2title'
    `l1title' `xlabel' `ylabel' `sort' `pen' `gap' `options';
#delimit cr

exit
end

* ***************************************************

program define egggph
version 6.0

* creates the Egger regression asymmetry plot graph

* Setup

syntax varlist(min=3 max=3) [if] [in] [, LEVel(integer 95) GWeight /*
  */ GAp(str) Connect(str) Symbol(str) SOrt Pen(str) T2title(str)  /*
  */ B2title(str) YLAbel(str) XLAbel(str) L1title(str) L2title(str) *]

tokenize `varlist'

tempvar touse theta setheta

local theta   `1'
local setheta `2'
local touse   `3'

preserve

* Graph options
if "`connect'" == "" { local connect ".ll" }
else {
  local lll = length("`connect'")
  if      `lll' == 1 { local connect "`connect'll" }
  else if `lll' == 2 { local connect "`connect'l" }
}
local connect "co(`connect')"

if "`symbol'" == "" { local symbol "oid" }
else {
  local lll = length("`symbol'")
  if      `lll' == 1 { local symbol "`symbol'id" }
  else if `lll' == 2 { local symbol "`symbol'd" }
}
local symbol "sy(`symbol')"

if "`pen'" == "" { local pen "233" }
else {
  local lll = length("`pen'")
  if      `lll' == 1 { local pen "`pen'33" }
  else if `lll' == 2 {local pen = "`pen'" + substr("`pen'",2,1)}
}
local pen "pen(`pen')"

if "`l2title'" == "" { local l2title "standardized effect" }
local l2title "l2(`l2title')"

if "`l1title'" == "" { local l1title "" "" }
local l1title "l1(`l1title')"

if "`b2title'" == "" { local b2title "precision" }
local b2title = "b2(`b2title')"

if `"`t2title'"' == `""' {
  local t2title = "Egger's publication bias plot"
  local t2title "t2(`"`t2title'"')"
}
else if `"`t2title'"' == `"."' { local t2title t2(" ")}
else { local t2title "t2(`"`t2title'"')" }


if "`xlabel'" == "" { local xlabel "xla" }
               else { local xlabel "xlabel(`xlabel')" }

if "`ylabel'" == "" { local ylabel "yla" }
               else { local ylabel "ylabel(`ylabel')" }

if "`sort'" == "" { local sort "sort" }

if "`gap'" == "" { local gap "gap(3)" }
            else { local gap "gap(`gap')" }

qui {
  local obs1 = _N + 1
  local obs2 = _N + 2
  local obs3 = _N + 3
  set obs `obs3'
  replace `setheta' = 0 in `obs1'/`obs3'
  replace `theta'   = . in `obs1'/`obs3'
  tempvar prec snd
  gen `prec' = 1 / `setheta' if `setheta' > 0
  gen `snd' = `theta' / `setheta' if `setheta' > 0
  replace `prec' = 0 if `prec' == .
  regr `snd' `prec' if `touse'
  tempvar reg ci
  capture matrix b = get(_b)
  if _rc == 0 {
    matrix V = get(VCE)
    local df = e(N) - 2
    gen `reg' = b[1,2] + `prec' * b[1,1]
    gen `ci' = .
    #delimit ;
      replace `ci' = b[1,2] - sqrt(V[2,2])
        * invt(`df', `level'/100) in `obs2' ;
      replace `ci' = b[1,2] + sqrt(V[2,2])
        * invt(`df', `level'/100) in `obs3' ;
    #delimit cr
  }
  else {
    gen `reg' = .
    gen `ci' = .
  }
}

if "`gweight'" != "" {
  tempvar ww
  qui gen `ww' = 1 / `setheta'^2
  qui replace `ww' = 1 if `setheta' == 0
  local gw "[w=`ww']"
}
else { local gw "" }

#delimit ;
  graph `snd' `reg' `ci' `prec' `gw' if `touse', yli(0) xli(0)
    `connect' `symbol' `t2title' `l2title' `b2title'
    `l1title' `xlabel' `ylabel' `sort' `pen' `gap' `options';
#delimit cr

exit
end

* ***************************************************

*! ktau2 version 4.1.0  26sep97 TJS
program define ktau2
version 4.0

*  modification of ktau to allow N==2, un-continuity-corrected
*  z and p values, and to pass more parameters

local varlist "req ex min(2) max(2)"
local if "opt"
local in "opt"
parse "`*'"
parse "`varlist'", parse(" ")
local x "`1'"
local y "`2'"
tempname k N NN pval score se tau_a tau_b
tempname xt xt2 xt3 yt yt2 yt3
tempvar doit nobs order work
mark `doit' `in' `if'
markout `doit' `x' `y'
quietly count if `doit'
scalar `N' = _result(1)
if `N' < 2 { error 2001 }
local Nmac = `N'
qui {
  gen long `order' = _n       /* restore ordering at end */
  replace `doit' = -`doit'
  sort `doit'           /* put obs for computation first */
  gen double `work' = 0  /* using type double is fastest */
  scalar `k' = 2
  while (`k' <= `N') {
    local kk = `k' - 1
    #delimit ;
      replace `work' = `work'
         + sign((`x' - `x'[`k'])*(`y' - `y'[`k']))
         in 1/`kk' ;  /* using "in" is fastest */
    #delimit cr
    scalar `k' = `k' + 1
  }
  replace `work' = sum(`work') in 1/`Nmac'
  scalar `score' = `work'[`N']
/* Calculate ties on `x' */
  egen long `nobs' = count(`x') in 1/`Nmac', by(`x')
  tempvar nobsxm
  egen `nobsxm' = max(`nobs')
/* Calculate correction term for ties on `x' */
  replace `work' = sum((`nobs' - 1)*(2*`nobs' + 5)) in 1/`Nmac'
  scalar `xt' = `work'[`N']
/* Calculate correction term for pairs of ties on `x' */
  replace `work' = sum(`nobs' - 1) in 1/`Nmac'
  scalar `xt2' = `work'[`N']
/* Calculate correction term for triplets of ties on `x' */
  replace `work' = sum((`nobs' - 1)*(`nobs' - 2)) in 1/`Nmac'
  scalar `xt3' = `work'[`N']
/* Calculate ties on `y' */
  drop `nobs'
  egen long `nobs' = count(`y') in 1/`Nmac', by(`y')
  tempvar nobsym
  egen `nobsym' = max(`nobs')
/* Calculate correction term for ties on `y' */
  replace `work' = sum((`nobs' - 1)*(2*`nobs' + 5)) in 1/`Nmac'
  scalar `yt' = `work'[`N']
/* Calculate correction term for pairs of ties on `y' */
  replace `work' = sum(`nobs' - 1) in 1/`Nmac'
  scalar `yt2' = `work'[`N']
/* Calculate correction term for triplets of ties on `y' */
  replace `work' = sum((`nobs' - 1)*(`nobs' - 2)) in 1/`Nmac'
  scalar `yt3' = `work'[`N']
/* Compute Kendall's tau-a, tau-b, s.e. of score, and pval */
  scalar `NN'    = `N'*(`N' - 1)
  scalar `tau_a' = 2*`score'/`NN'
  scalar `tau_b' = 2*`score'/sqrt((`NN' - `xt2')*(`NN' - `yt2'))
  #delimit ;
    scalar `se' = `NN'*(2*`N' + 5);
    tempname tmax;
    scalar `tmax' = max(`nobsxm', `nobsym');
    if `tmax' > 1 { scalar `se' = `se'
                    - (`xt' - `yt')
                    + `xt3'*`yt3'/(9*`NN'*(`N' - 2))
                    + `xt2'*`yt2'/(2*`NN') } ;
    scalar `se' = sqrt((1/18)*`se');
  #delimit cr
  local zcc = (abs(`score') - 1) / `se'
  local z = `score '/ `se'
  tempname pvalcc
  if `score' == 0 {
    scalar `pval' = 1
    scalar `pvalcc' = 1
  }
  else scalar `pvalcc' = 2*(1 - normprob((abs(`score') - 1)/`se'))
  else scalar `pval'   = 2*(1 - normprob(abs(`score')/`se'))
/* Restore original ordering of data set */
  sort `order'
}
/* Print results */
#delimit ;
  di _n
    in gr "  Number of obs = " in ye  %7.0f `N' _n
    in gr "Kendall's tau-a = " in ye %12.4f `tau_a' _n
    in gr "Kendall's tau-b = " in ye %12.4f `tau_b' _n
    in gr "Kendall's score = " in ye  %7.0f `score' _n
    in gr "    SE of score = " in ye %11.3f `se' _c ;
  if `xt2' > 0 | `yt2' > 0 { di in gr "   (corrected for ties)" _c } ;
  di _n(2)
    in gr "Test of Ho: `x' and `y' independent" _n
    in gr "             z  = " in ye %12.2f `z' _n
    in gr "       Pr > |z| = " in ye %12.4f = `pval' _n(2)
    in gr "             z  = " in ye %12.2f sign(`score')*`zcc' _n
    in gr "       Pr > |z| = " in ye %12.4f = `pvalcc'
    in gr "  (continuity corrected)" ;
#delimit cr
local c = 0
if `xt2' > 0 | `yt2' > 0 { local c = 1 }
global S_1 = `N'
global S_2 = `tau_a'
global S_3 = `tau_b'
global S_4 = `score'
global S_5 = `se'
global S_6 = `pval'
global S_7 = `z'
global S_8 = `pvalcc'
global S_9 = `zcc'
global S_10 = `c'
end

* ***************************************************

*! ifexp version 1.2.1  19nov98 TJS
program define ifexp
version 5.0

while substr("`1'",1,2) != "if" {
  macro shift
}

local if "required"
local options "noVARlabel noVALlabel noUNabbrev noSPace Color(str)"
parse "`*'"
parse "`if'", parse(" ><=&|!()")

if "`color'" == "" {local color = "b"}    /* set display color */
local color = lower(substr("`color'",1,1))
if index("wbgyr","`color'") == 0 {local color = "b"}

if "`if'" != "" {
  local ifst "  if "                   /* handle leading "if " */
  local lif = 5
  macro shift

  if "`space'" != "nospace" {                 /* set up space  */
    local sp " "
    local sp1 = 1
  }
  else { local sp1 = 0 }

  di
  while "`1'" != "" {             /* start main loop on tokens */
    capture confirm variable `1'                 /* var name ? */
    local rc _rc

    local m = 0
    local n = length("`1'")
    if `n' + `lif' > 78 {               /* no room for token ? */
      di in `color' "`ifst'"
      local ifst ">    "
      local lif = 5
      local n = 0
    }
                                             /* is punctuation */
    if "`1'" == "==" { local ifst "`ifst'`1'`sp'" }
    else if "`1'" == "<=" { local ifst "`ifst'`1'`sp'" }
    else if "`1'" == ">=" { local ifst "`ifst'`1'`sp'" }
    else if "`1'" == "!=" { local ifst "`ifst'`1'`sp'" }
    else if "`1'" == "<"  { local ifst "`ifst'`1'`sp'" }
    else if "`1'" == ">"  { local ifst "`ifst'`1'`sp'" }
    else if "`1'" == "="  { local ifst "`ifst'`1'`sp'" }
    else if "`1'" == "&"  { local ifst "`ifst'`1'`sp'" }
    else if "`1'" == "|"  { local ifst "`ifst'`1'`sp'" }
    else if "`1'" == "!"  { local ifst "`ifst'`1'`sp'" }
    else if "`1'" == "("  { local ifst "`ifst'`1'`sp'" }
    else if "`1'" == ")"  { local ifst "`ifst'`1'`sp'" }

    else if `rc' == 0 {                  /* is a variable name */
      local tif "`1'"
      if "`unabbrev'" != "nounabbrev" {      /* allow unabbrev */
        unabbrev `1'
        local tif "$S_1"
      }
      if "`varlabel'" != "novarlabel" {   /* allow var label ? */
        local vrl : variable label `1'
        if "`vrl'" != "" { local tif "`vrl'" }  /* var label ? */
      }

      local wc: word count `tif'  /* process > 1 word in label */
      local w 1
      while `w' < `wc' {
        local wif: word `w' of `tif'
        local wm = length("`wif'")
        if `wm' + `lif' > 78 {
          di in `color' "`ifst'"
          local ifst ">    "
          local lif = 5
          local n = `m'
          local m = 0
        }
        else {
          local lif = `lif' + `wm' + `sp1'
          local ifst "`ifst'`wif'`sp'"
          local w = `w' + 1
        }
      }
      local tif: word `wc' of `tif'    /* do last or only word */

      local m = length("`tif'")         /* no room for token ? */
      if `m' + `lif' > 78 {
        di in `color' "`ifst'"
        local ifst ">    "
        local lif = 5
        local n = `m'
        local m = 0
      }
      local ifst "`ifst'`tif'`sp'"
      local vll : value label `1'
    }

    else {                                       /* is a value */
      local tif "`1'"                   /* allow value label ? */
      if "`vll'" != "" & "`vallabel'" != "novallabel" {
        local lv : label `vll' `1'
        if "`lv'" != "" { local tif "`lv'" }  /* value label ? */
      }

      local wc: word count `tif'  /* process > 1 word in label */
      local w 1
      while `w' < `wc' {
        local wif: word `w' of `tif'
        local wm = length("`wif'")
        if `wm' + `lif' > 78 {
          di in `color' "`ifst'"
          local ifst ">    "
          local lif = 5
          local n = `m'
          local m = 0
        }
        else {
          local lif = `lif' + `wm' + `sp1'
          local ifst "`ifst'`wif'`sp'"
          local w = `w' + 1
        }
      }
      local tif: word `wc' of `tif'    /* do last or only word */

      local m = length("`tif'")         /* no room for token ? */
      if `m' + `lif' > 78 {
        di in `color' "`ifst'"
        local ifst ">    "
        local lif = 5
        local n = `m'
        local m = 0
      }
      local ifst "`ifst'`tif'`sp'"
    }
                                        /* set new line length */
    if `m' > 0 { local lif = `lif' + `m' + `sp1' }
    else { local lif = `lif' + `n' + `sp1' }
    macro shift                                  /* next token */
  }                                 /* end main loop on tokens */

di in `color' "`ifst'"                  /* display expanded if */

global S_1 "`ifst'"
exit
end

* ***************************************************

program define numvlab
*! numvlab version 1.0.1  04sep03 TJS
version 6
syntax varname
tempvar byvar seq
egen `byvar' = group(`varlist')
sort `byvar'
by `byvar': gen `seq' = _n
sort `seq' `byvar'
qui count if `seq' == 1
local n = r(N)
local i 1
while `i' <= `n' {
  lab def `varlist' `i' "`i'", modify
  local i = `i' + 1
}
lab val `varlist' `varlist'
end
