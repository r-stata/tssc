*! experimental version 0.0.2  17sep2001  TJS 
*!   chiplot vary varx [if] [in] [, Hilite(string) CI(#) SAMple(%) graph_options]

program define chiplot
version 7

* syntax help

 if "`1'" == "" {
    di _n as txt "Syntax is:" _n
    di as inp "  chiplot" as txt " vary varx" _c
    di as txt " [" as inp "if" as txt " exp]" _c
    di as txt " [" as inp "in" as txt " range]" _c
    di as txt " [" as inp ", h" as txt "ilite" as inp "(" as txt "exp" as inp ")" _c 
    di as inp " ci(" as txt "#" as inp ")" _c 
    di as inp " sam" as txt "ple" as inp "(" as txt "%" as inp ")" _c
    di as txt " graph_options]"
    exit
 }

* setup

 syntax varlist(num min=2 max=2)[if][in][, Hilite(string) CI(real .95) /*
   */   SAMple(real 100) SYmbol(string) SAVing(str) *]
 marksample touse
 tokenize `varlist'

* preserve data

 preserve
 qui keep if `touse'

* sample? 

 if `sample' > 0 & `sample' < 100 {
    local t = "$S_TIME"
    local s = substr("`t'",1,2) + substr("`t'",4,2) + substr("`t'",7,2) 
    set seed `s'
    if "`hilite'" != "" {
       _isif if `hilite'
       tempvar higrp
       qui gen `higrp' = `hilite'
       sort `higrp'
       local byhigrp = "by `higrp':"
    }   
    qui `byhigrp' sample `sample'
 }

* do calculations
 tempvar ry rx Hi Fi Gi Si CHIi Li
 * Gi
 qui egen `ry' = rank(`1'), field
 gsort -`ry'
 qui gen `Gi' = (_N - `ry') / (_N - 1)
 * Fi
 qui egen `rx' = rank(`2'), field
 gsort -`rx'
 qui gen `Fi' = (_N - `rx') / (_N - 1)
 * Hi
 sort `ry'
 qui by `ry': replace `ry' = _N 
 sort `1'
 tempname xi
 qui gen `Hi' = 0
 local r1 = 1
 local N = _N 
 forvalues i = 1 / `N' { 
    if `1'[`i'] == `1'[`i'-1] { local r1 = `r1' + 1 }
    else { local r1 = 1 }
    local k = min(`N', `i' + `ry'[`i'] - `r1')
    scalar `xi' = `2'[`i']
    qui count if `2' <= `xi' & _n != `i' in 1/`k'
    qui replace `Hi' = r(N) in `i'       
 }
 qui replace `Hi' = `Hi' / (_N - 1)
 * Si, CHIi, Li
 qui gen `Si'   = sign((`Fi' - .5)*(`Gi' - .5))
 qui gen `CHIi' = (`Hi' - `Fi'*`Gi') / (`Fi'*(1 - `Fi')*`Gi'*(1 - `Gi'))^.5
 qui gen `Li'   = 4 * `Si' * max((`Fi' - .5)^2, (`Gi' - .5)^2)  
 label var `CHIi' "chi"
 label var `Li' "lambda"
 
* get scatterplot gap() 
 quietly summ `1', detail
 local ymin = r(min)
 local ymax = r(max)
 local gp = 1 + max( /*
    */ length(string(round(`ymin', 1))), /*
    */ length(string(round(`ymax', 1))))
    
 qui corr `varlist'
 local r = r(rho)
 local r: di "r = " %5.2f `r'
 
* graph

 * saving option
 if "`saving'" != "" {
    local c  = index("`saving'",",")
    local cs " "
    if index("`saving'",", ") { local cs "" }
    if `c' { local saving = substr("`saving'",1,`c' - 1) /*
       */  + "`cs'" + substr("`saving'",`c' + 1, .) }
    local savfile : word 1 of `saving'
    local replace : word 2 of `saving'
    if "`replace'" == "replace" { capture erase "`savfile'.gph" }
    capture confirm new file "`savfile'.gph"
    if _rc == 0 { local saving ", saving(`savfile')" }
    else {
       local rc = _rc
       di in re "  file `savfile'.gph exists."
       di in bl "use another filename or add 'replace' option."
       exit `rc'
    }
 }
 * hilite?
 if "`hilite'" != "" {
    _isif if `hilite'
    local symbol = cond("`symbol'"=="", "s(oo)", "s(`symbol')")
    tempvar Temp1 Temp2
    qui gen `Temp1' = `1' if (`hilite')
    _crcslbl `Temp1' `1'
    qui gen `Temp2' = `CHIi' if (`hilite')
    _crcslbl `Temp2' `CHIi'
    local hl = `"`hilite' highlighted"'
    local ls: variable label `1'
    if "`ls'" == "" { local ls = "`1'" }
    local lc = "chi"
    local cm =", "
 }
 * set t2title with if clause
 if "`if'" != "" { local t2 = "t2(`if'`cm'`hl')" }
 else if "`hl'" != "" { local t2 = "t2(`hl')" }
 
 gph open `saving'
 * scatterplot 
 gph text 2500 6500 0 1 `r'
 gra `1' `Temp1' `2', xla yla t1(`"scatterplot of `1' vs. `2'"') ga(`gp') /* 
     */ bbox(0,0,23063,15700,923,444,0) `symbol' `options' `t2' l1(`"`ls'"')
 * chi-plot
 gra `CHIi' `Temp2' `Li', xla(-1,-.5,0,.5,1) yla(-1,-.5,0,.5,1) /*
     */ xli(0) t1(`"chi-plot of `1' vs. `2'"') ga(2) `t2' yli(0) /*
     */ bbox(0,16300,23063,32000,923,444,0) l1(`"`lc'"') `symbol' `options'
 * cp lines
 if `ci' <= 1  { local ci = `ci' * 100 }
 if       `ci' == 90 { local cp = 1.54 }
 else if  `ci' == 99 { local cp = 2.18 }
 else                { local cp = 1.78 }
 local cp = `cp' / sqrt(_N)
 tempname ay by ax bx
 scalar `ay' = r(ay)
 scalar `by' = r(by)
 scalar `ax' = r(ax)
 scalar `bx' = r(bx)
 gph pen 1
 tempvar ys xs
 if 50 > _N { qui set obs 50 }
 qui gen `xs' = (-1 + 2 * _n / _N) * `ax' + `bx'
 qui gen `ys' = `cp' * `ay' + `by'
 gph vpoint `ys' `xs', size(1) symbol(0)
 qui replace `ys' = -`cp' * `ay' + `by'
 gph vpoint `ys' `xs', size(1) symbol(0)
 gph close
end

program define _isif
   syntax if
end
