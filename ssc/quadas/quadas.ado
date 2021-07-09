*! version 1.00 October 7, 2010
*! Ben A. Dwamena: bdwamena@umich.edu 
capture drop quadas
program define quadas, rclass sortpreserve
version 10
syntax varlist(string min=2) [if] [in] [, id(varname) BAR SUM COLor scheme(string) *]
qui {
preserve
marksample touse, novarlist
keep if `touse'
}


if "`sum'" =="sum" {

tokenize `varlist'
qui {
local b 1
foreach var in `varlist' {
local critvar : variable label `var'
if  "`critvar'" == "" {
local critvar = "`var'"
}
gen str40 GQ`b'="`critvar'"
gen qq`b' = `var'
local b = `b' + 1
}
if "`scheme'"=="" {
set scheme s2mono
}
else if "`scheme'"!="" {
set scheme `scheme'
}


tempvar qmark qplus qminus studyid studdy Quality xvar

  if "`id'"=="" {
gen str10 `studyid'=string(_n)   
}
else if "`id'" != "" {
gen `studyid' =`id'
} 

gen `studdy'=_n
tempname obs 
gen `obs' = _n 
count
local max = r(N)
local maxx=`max'+0.5
label value `obs' obs
forval i = 1/`max'{
local value = `"`value' `i'"'
label define obs `i' "`=`studyid'[`i']'", modify
}

 
reshape long qq GQ, i(`studdy') j(`Quality')
gen `xvar'=0.05
generate `qmark' = "?"
generate `qplus' = "+"
generate `qminus'= "-"
local mscale "msize(*4)"

if "`color'" != "" {
tw (scatter `obs' `xvar', subtitle(, box nobex fcolor(none) lcolor(none) orientation(vertical) ///
placement(s)) by(GQ, compact rows(1) legend(off) noixl noixt note("") ///
title("", pos(12))) /// 
ymtick(0.5(1)`maxx', grid glc(black) tlcolor(none)) ylabel(`"`value'"', /// 
valuelabel angle(360) nogrid) ms(O) `mscale' mcol(midgreen)) ///
(scatter `obs' `xvar' if qq=="unclear",  ms(O)  `mscale' mcol(gold)) /// 
(scatter `obs' `xvar' if qq=="no", ms(O)  `mscale' mcol(red))  ///
(scatter `obs' `xvar' if qq=="yes", ms(none) mlabs(*2.5) mla(`qplus') mcol(black) mlabpos(0)) /// 
(scatter `obs' `xvar' if qq=="unclear", ms(none) mlabs(*2.5) mla(`qmark') mcol(black) mlabpos(0)) /// 
(scatter `obs' `xvar' if qq=="no", ms(none) mla(`qminus') mlabs(*2.5) mcol(black) mlabpos(0)), ///
yscale(rev) ytitle("") xtitle("") `options' 
}
else if "`color'" == "" {
tw (scatter `obs' `xvar', subtitle(, box nobex fcolor(none) lcolor(none) orientation(vertical) ///
placement(s)) by(GQ, compact rows(1) legend(off) noixl noixt note("") ///
title("", pos(12))) /// 
ymtick(0.5(1)`maxx', grid glc(black) tlcolor(none)) ylabel(`"`value'"', /// 
valuelabel angle(360) nogrid) ms(i)) ///
(scatter `obs' `xvar',  ms(O)  `mscale' mcol(white)) ///
(scatter `obs' `xvar' if qq=="yes", ms(none) mlabs(*2.5) mla(`qplus') mcol(black) mlabpos(0)) /// 
(scatter `obs' `xvar' if qq=="unclear", ms(none) mlabs(*2.5) mla(`qmark') mcol(black) mlabpos(0)) /// 
(scatter `obs' `xvar' if qq=="no", ms(none) mla(`qminus') mlabs(*2.5) mcol(black) mlabpos(0)), ///
yscale(rev) ytitle("") xtitle("") `options' 

}
}
}

if "`bar'" == "bar" { 

tokenize `varlist'
qui{
tempfile qualires
tempname qualifile
postfile `qualifile' str40 Criterion Yes Unclear No using qualires, replace
foreach var in `varlist' {
count if `var' == "yes"
local yesvar = r(N)
count if `var' == "unclear"
local unclear = r(N)
count if `var' == "no"
local novar = r(N)

local critvar: variable label `var'

if  "`critvar'" == "" {
 local critvar = "`var'"
}
post `qualifile' ("`critvar'") (`yesvar') (`unclear') (`novar')  

} 
postclose `qualifile'
postutil clear
use qualires, clear
if "`color'" != "" {
#delimit;
graph hbar (asis) Yes Unclear No, over(Criterion, sort(Total) descending)
nolabel bar(1, fcolor(midgreen)) bar(2, fcolor(gold)) bar(3, fcolor(red)) plotregion(lcolor(black) margin(zero))
legend(pos(6) order(3 2 1) row(1) size(*.50) symxsize(3)) 
stack percent lintensity(*.75) scale(0.85) `options';
#delimit cr 
}
else if "`color'" == "" {
#delimit;
graph hbar (asis) Yes No Unclear, over(Criterion, sort(Total) descending)
nolabel bar(1, fcolor(black)) bar(2, fcolor(white)) bar(3, fcolor(gray)) plotregion(lcolor(black) margin(zero))
legend(pos(6) order(3 2 1) row(1) size(*.50) symxsize(3)) 
stack percent lintensity(*.75) scale(0.85) `options';
#delimit cr 
}
}
}

end

