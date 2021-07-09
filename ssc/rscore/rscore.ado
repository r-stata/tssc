********************************************************************************
* PROGRAM "rscore"
********************************************************************************
*! rscore v3 GCerulli 15nov2016
program rscore , eclass
version 14
syntax varlist [if] [in] [fweight pweight iweight] , model(string) rs_name(string)  ///
[factors(varlist) xlist(varlist) graph(numlist max=2)   ///
radar(numlist) id_string(varname) save_graph1(string) save_graph2(string) vce(string)] 
marksample touse
markout `touse' `factors' `xlist'
********************************************************************************
* Standardize variables
********************************************************************************
local yxstd
foreach v of local varlist{
cap drop `v'_std
qui egen double `v'_std=std(`v')
local yxstd `yxstd' `v'_std
}
local varlist "`yxstd'"
********************************************************************************
tokenize "`varlist'"
local y "`1'"
macro shift 1
local xvars "`*'"
local N : word count `xvars'
********************************************************************************
if `N'==1{
di _newline(2)
di as error "**************************************************************"
di as error "WARNING: you need to specify at least 2 independent variables."
error 102
di as error "**************************************************************"
}
********************************************************************************
quietly{                        // start quietly
forvalues i=1/`N' {
tempvar x`i'
}
local i=1
foreach var of local xvars{
qui gen `x`i''=`var' if `touse'
local i=`i'+1
}
forvalues i=1/`N' {
tempvar z`i'
}
forvalues i=1/`N' {
qui gen `z`i''=. if `touse'
}
qui replace `z1'=`x1'
forvalues j=1/`N'{
qui replace `z`j''=`x`j''  
qui replace `x1'=`z`j''
qui replace `x`j''=`z1'
*****************************************************
local N=_N
forvalues i=1/`N'{
local c`i'=`id_string'[`i']
}
*****************************************************
* Body
*****************************************************
local x_curr 
forvalues i=1/`N'{
local x_curr `x_curr' `x`i'' 
}
foreach var of local x_curr {
tempvar m_`var'
}
foreach var of local x_curr {
qui egen `m_`var''=mean(`var') if `touse'
}
foreach var of local x_curr  {
tempvar s_`var'
}
foreach var of local x_curr {
qui gen `s_`var''=(`var'- `m_`var'') if `touse'
}
tokenize `x_curr'
local first "`1'"
macro shift 1
local xvars2 "`*'"
local s_xvars
foreach var of local xvars2{
local s_xvars `s_xvars' `s_`var''
}
foreach var of local s_xvars {
tempvar x1`var'
}
foreach var of local s_xvars {
qui gen `x1`var''=`x1'*`var' if `touse'
qui sum `x1`var''
}
local x_1
forvalues i=2/`N'{
local x_1 `x_1' `x`i''
}
local x1s_x_1
foreach var of local s_xvars {
local x1s_x_1 `x1s_x_1' `x1`var''
}
**** Baseline regression ****
local f=1
local facs
foreach v of local factors{
local facs `facs' i.`v'
}
********************************************************************************
if "`model'" == "fe"{
xi: xtreg `y'  `x_1'  `x1' `x1s_x_1' `facs' `xlist' if `touse' [`weight'`exp'] , vce(`vce') fe 
scalar R2_`j'=e(r2)
}
else if "`model'" == "re"{
xi: xtreg `y'  `x_1'  `x1' `x1s_x_1' `facs' `xlist' if `touse' [`weight'`exp'] , vce(`vce') re
scalar R2_`j'=e(r2) 
}
else if "`model'" == "ols"{
xi: reg `y'  `x_1'  `x1' `x1s_x_1' `facs' `xlist' if `touse' [`weight'`exp'] , vce(`vce')
scalar R2_`j'=e(r2)
}
********************************************************************************
local m=2
foreach var of local xvars2{
*di _b[`x1`s_`var''']
scalar d`m'=_b[`x1`s_`var''']
local m=`m'+1
*di "d`m'"
}
tempvar k1
qui gen `k1'=0 if `touse'
local m=2
foreach var of local xvars2{
qui replace `k1'=`k1'+d`m'*`m_`var'' if `touse'
local m=`m'+1
}
qui sum `k1' 
scalar k1=r(mean)
scalar d1=_b[`x1']
scalar delta0=d1-k1
tempvar delta0
qui gen `delta0'=delta0 if `touse'
tempvar b1
qui gen `b1'=`delta0' if `touse'
local m=2
foreach var of local xvars2{
qui replace `b1'=`b1'+d`m'*`var' if `touse'
local m=`m'+1
}
********************************************************************************
* End of the Body
********************************************************************************
cap drop `rs_name'`j'
qui gen `rs_name'`j'=`b1' if `touse'
forvalues k=1/`j'{
qui replace `x`k''=`z`k'' if `touse'
}
}
}                                     // end quietly
local i=0
local sum
foreach var of local xvars{
local i=`i'+1
la var `rs_name'`i' "Responsiveness scores for variable `var'"
local sum `sum' `rs_name'`i'
}
di _newline(2)
di as result "**********************************************************************"
di as result "*** DESCRIPTIVE STATISTICS FOR SINGLE FACTOR RESPONSIVENESS SCORES ***"
di as result "**********************************************************************"
sum `sum' , d
di as text "{hline 61}"
qui cap drop _rscore_id
qui gen _rscore_id=_n
qui order _rscore_id `sum'
********************************************************************************
* DISTRIBUTION GRAPH
********************************************************************************
if "`graph'"==""{
* do nothing
}
else if "`graph'"!="" & `graph'>0 {
preserve
local coeff `sum'
local i=1
local new_coef
foreach v of local coeff{
local k: word `i' of `xvars'
rename `v' b_`k'
local new_coef `new_coef' "b_`k'"
local i=`i'+1
}
local tot
foreach v of local new_coef{
local tot `tot' (kdensity `v' if `v'>=-`graph' & `v'<=`graph')
}
tw `tot' , title(Distributions of Responsiveness Scores , size(medlarge)) legend(size(small))
if "`graph'"!="" & "`save_graph1'"!=""{
qui graph save `save_graph1' , replace
}
restore
}
********************************************************************************
* RADAR GRAPH
********************************************************************************
if "`radar'"!="" & "`id_string'"==""{
di _newline(2)
di as error "*************************************************************************************"
di as error "WARNING: to use the radar() option you need to specify jointly the id_string() option"
di as error "*************************************************************************************"
}
else if "`radar'"!="" & "`id_string'"!=""{ 
preserve 
qui keep `sum'
qui xpose , clear
forvalues i=1/`N'{
rename v`i' _U`i'
} 
qui cap drop _id
qui gen _id="."
local M: word count `sum'
forvalues i=1/`M'{
local s: word `i' of `xvars'
qui replace _id="`s'" in `i'
}
qui keep in 1/`M'
forvalues i=1/`N'{
la var _U`i' "`c`i''" 
}  
* Build the legend
local lab
local rad
local i=1
foreach v of numlist `radar'{
local rad `rad' _U`v'
local lb`v' : variable label _U`v'
local L`v' "label(`i' `lb`v'')"
local lab `lab' `L`v''
local i=`i'+1
}
radar _id `rad' , title("") ///
legend(on) legend(size(small)) legend(`lab') labsize(*0.8) 
if "`save_graph2'"!=""{
qui graph save `save_graph2' , replace
}
restore
}
********************************************************************************
* RSCORE GOODNESS-OF-FIT
********************************************************************************
local K : word count `xvars'
forvalues j=1/`K'{
ereturn scalar R2_`j'=R2_`j'
}
scalar sumR2=0
forvalues j=1/`K'{
scalar sumR2 = sumR2 + R2_`j'
}
ereturn scalar R2=(1/`K')*sumR2
********************************************************************************
di _newline(2)
di as result "*************************************************************"
di as result "*************** RSCORE GOODNESS-OF-FIT **********************"
di as result "*************************************************************"
di as text "{hline 61}"
local h=1
foreach v of local xvars{
di as result "The R-squared for `v' is: " 
di as result R2_`h'
di as text "{hline 61}"
local h=`h'+1
}
di as result "The mean R-squared is: " 
di as result e(R2)
di as text "{hline 61}"
********************************************************************************
end
