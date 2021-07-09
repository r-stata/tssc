********************************************************************************
* PROGRAM "tfdiff"
********************************************************************************
*! tfdiff, v10, G.Cerulli, 25may2020
program tfdiff, eclass sortpreserve
version 14
#delimit;     
syntax varlist(numeric ts fv) [if] [in] [aweight fweight pweight] ,
t(numlist max=1)
tvar(varlist numeric max=1)
datatype(string)
model(string)
[
pvar(varlist numeric max=1)
ci(numlist max=1)
test_pt
vce(string)
save_graph(string)
save_results(string)
graph
];
#delimit cr
********************************************************************************
marksample touse
tokenize `varlist'
local y `1'  // outcome
local w `2'  // treatment
macro shift
macro shift
local xvars `*'
********************************************************************************
* Labels
********************************************************************************
la var `w' "Binary treatment variable"
la var `y' "Outcome variable"
********************************************************************************
* Warning 1
********************************************************************************
preserve // preserve the original dataset
qui keep if `touse' // consider just the subsample identified by the "if"
qui count if `w'==1 & `touse'
local N1=r(N)
qui count if `touse'
local N=r(N)
qui sum `w' if `touse'
if r(mean)!=(`N1'/`N'){
di as text in red  ""
di as text in red  ""
di as text in red  "{hline}"
di as text in red  "{bf:******************************************************************************}"
di as text in red  "{bf:********* WARNING: The treatment variable must be binary 0/1 *****************}"
di as text in red  "{bf:******************************************************************************}"
exit
}
restore
********************************************************************************
* Warning 2
********************************************************************************
if ("`datatype'"!="panel" & "`datatype'"!="cross-section") {
di _newline(2)
di as result in red "***************************************************************"
di as result in red "Warning: only one of the following datatype must be   "
di as result in red "declared into the option 'datatype()': 'panel', 'cross-section'"
di as result in red "***************************************************************"
exit
}
********************************************************************************
* Warning 3
********************************************************************************
if ("`datatype'"=="panel" & "`model'"!="ols" & "`model'"!="fe") {
di _newline(2)
di as result in red "********************************************************"
di as result in red "Warning: only one of the following models must be   "
di as result in red "declared into the option 'model()': 'ols', 'fe'"
di as result in red "********************************************************"
exit
}
********************************************************************************
* Warning 4
********************************************************************************
if ("`datatype'"=="cross-section" & "`model'"!="ols") {
di _newline(2)
di as result in red "*********************************************************"
di as result in red "Warning: with cross-section data, only one models must be"
di as result in red "declared into the option 'model()': 'ols'"
di as result in red "*********************************************************"
exit
}
********************************************************************************
* GENERATE THE TIME DUMMIES
********************************************************************************
qui sum `tvar'
********************************************************************************
local T = r(max) - r(min) +1  
local M = `t'-r(min)-1 // number of pre-treatment times minus one 
forvalues i=1/`T'{
cap drop _D`i'
} 
qui tab `tvar' , gen(_D) 
********************************************************************************
drop _D1 // Drop the first time dummy
********************************************************************************
* PANEL DATA ESTIMATION
********************************************************************************
if "`datatype'"=="panel"{
di _newline(1)
di as result in red "***********************************************************"
di as result in red "Data type: PANEL"
di as result in red "***********************************************************"
di _newline(1)
********************************************************************************
if "`model'"=="ols" & "`pvar'"==""{
di _newline(1)
di as result in red "*************************************************************"
di as result in red "Warning: the option 'pvar()' must be declared with panel data"
di as result in red "*************************************************************"
exit
}
else if "`model'"=="ols" & "`pvar'"!=""{
di as result in red "***********************************************************"
di as result in red "Model type: OLS"
di as result in red "***********************************************************"
tsset `pvar' `tvar'
reg `y' i.`w'##i._D* `xvars' [`weight' `exp'] if `touse' , vce(`vce') noomitted // ols
}
********************************************************************************
if "`model'"=="fe" & "`pvar'"==""{
di _newline(1)
di as result in red "*************************************************************"
di as result in red "Warning: the option 'pvar()' must be declared with panel data"
di as result in red "*************************************************************"
di _newline(1)
exit
}
else if "`model'"=="fe" & "`pvar'"!=""{
di as result in red "***********************************************************"
di as result in red "Model type: Fixed-effect"
di as result in red "***********************************************************"
tsset `pvar' `tvar'
xtreg `y' i.`w'##i._D* `xvars' [`weight' `exp'] if `touse' , vce(`vce') fe  noomitted // fixed effects
}
}
********************************************************************************
* CROSS-SECTION ESTIMATION
********************************************************************************
if "`datatype'"=="cross-section"{
di _newline(1)
di as result in red "***********************************************************"
di as result in red "Data type: CROSS-SECTION"
di as result in red "***********************************************************"
di _newline(1)
if "`model'"=="ols"{
di as result in red "***********************************************************"
di as result in red "Model type: OLS"
di as result in red "***********************************************************"
reg `y' i.`w'##i._D* `xvars' [`weight' `exp'] if `touse' , vce(`vce') noomitted // ols
}
}
********************************************************************************
* REST OF THE CODE
********************************************************************************
ereturn scalar phi=_b[1.`w']
qui count if `touse'
ereturn scalar N=r(N)
qui count if `w'==1 & `touse'
ereturn scalar N1=r(N)
qui count if `w'==0 & `touse'
ereturn scalar N0=r(N)
********************************************************************************
* TESTING THE "PARALLEL TREND"
********************************************************************************
*qui tsset `pvar' `tvar' 
qui sum `tvar'
local M = `t'-r(min)-1 // number of pre-treatment times minus one 
********************************************************************************
if "`test_pt'"!=""{
di as text ""
di as text ""
di as text "{hline}"
di as text "{bf:******************************************************************************}"
di as text "{bf:**************** TEST FOR 'PARALLEL TREND' ***********************************}"
di as text "{bf:******************************************************************************}"
local sum ""
forvalues i=2/`M'{
local sum `sum' _b[1.w#1._D`i']=
}
local sum _b[1.w]=`sum'0
di as text "{bf:Null to be tested:}"
di "`sum'"
test `sum'
if r(p)>=0.05{
di as text ""
di as result "RESULT: 'Parallel-trend' passed"
}
else{
di as result "RESULT: 'Parallel-trend' not passed"
}
di as text ""
di as text "{bf:******************************************************************************}"
di as text ""
}
********************************************************************************
* GENERATE CONFIDENCE INTERVALS FOR ATE(t)
********************************************************************************
tempname V
mat `V'=e(V)
********************************************************************************
scalar _b1=_b[1.`w']
mat _var_`w'=`V'["1.`w'","1.`w'"]
scalar _var_`w'=_var_`w'[1,1]
scalar _se_b1=sqrt(_var_`w')
mat _var_`w'_D2=`V'["1.`w'#1._D2","1.`w'#1._D2"]
mat _var_`w'_D3=`V'["1.`w'#1._D3","1.`w'#1._D3"]
********************************************************************************
* SETTING THE GRAPH CONFIDENCE INTERVAL SIGNIFICANCE
********************************************************************************
if "`ci'"=="" {
local cis=1.96 // default 5% significance
}
else if "`ci'"!="" & `ci'==1{
local cis=2.576
} 
else if "`ci'"!="" & `ci'==5{
local cis=1.96
} 
else if  "`ci'"!="" & `ci'==10{
local cis=1.645
}
else if  "`ci'"!="" & (`ci'!=1 |`ci'!=5 |`ci'!=10){
di in red "Warning: the option 'ci(#)' accepts only these values: 1, 5, or 10."
error 121
} 
********************************************************************************
tempname M
mat `M'=J(`T',3,.)
mat `M'[1,1]=_b1
mat `M'[1,2]=_b1+`cis'*_se_b1
mat `M'[1,3]=_b1-`cis'*_se_b1
********************************************************************************
forvalues i= 2/`T'{
mat _var_`w'_D`i'=`V'["1.`w'#1._D`i'","1.`w'#1._D`i'"]
scalar _var_`w'_D`i'=_var_`w'_D`i'[1,1]
mat _cov_`w'_D`i'=`V'["1.`w'#1._D`i'","1.`w'"]
scalar _cov_`w'_D`i'=_cov_`w'_D`i'[1,1]
mat _b`i' = (_b[1.`w'] + _b[1.`w'#1._D`i'])
scalar _b`i' =_b`i'[1,1]
mat _var_b`i' = _var_`w' + _var_`w'_D`i' + 2*_cov_`w'_D`i'
scalar _var_b`i'=_var_b`i'[1,1]
scalar _se_b`i' = sqrt(_var_b`i')
mat `M'[`i',1]=_b`i'
mat `M'[`i',2]=_b`i'+`cis'*_se_b`i'
mat `M'[`i',3]=_b`i'-`cis'*_se_b`i'
}
********************************************************************************
preserve
********************************************************************************
if "`graph'"=="" & "`save_graph'"!=""{
di as error "Warning: the option 'save_graph' requires to jointly specify the option 'graph'."
error 
}
********************************************************************************
svmat `M'
gen _id=`tvar'
qui keep in 1/`T'
********************************************************************************
cap gen __ATE_t=`M'1
la var __ATE_t "Average Treatment Effect at each time t"
cap gen __ATE_t_ub=`M'2
la var __ATE_t_ub "Upper bound confidence interval of ATE(t) - significance `ci'%"
cap gen __ATE_t_lb=`M'3
la var __ATE_t_lb "Lower bound confidence interval of ATE(t) - significance `ci'%"
********************************************************************************
if "`graph'"!=""{
twoway (rcap `M'2 `M'3 _id) ///
(scatter `M'1 _id , yline(0 , lpattern(dash)) xline(`t' ,lw(thick) lp(dash))) ///
(connected `M'1 _id) ///
, legend(off) xtitle(Time) ytitle(ATE(t)) note(Confidence interval significance level: `ci'%)  ///
graphregion(fcolor(white)) scheme(s1mono) 
}
********************************************************************************
if "`graph'"!="" & "`save_graph'"!=""{
twoway (rcap `M'2 `M'3 _id) ///
(scatter `M'1 _id , yline(0 , lpattern(dash)) xline(`t' ,lw(thick) lp(dash))) ///
(connected `M'1 _id) ///
, legend(off) xtitle(Time) ytitle(ATE(t)) note(Confidence interval significance level: `ci'%)  ///
graphregion(fcolor(white)) scheme(s1mono) saving(`save_graph', replace)
}
********************************************************************************
qui{
if "`save_results'" != ""{
keep `tvar' __ATE_t __ATE_t_lb __ATE_t_ub
save `save_results' , replace
}
}
********************************************************************************
restore
********************************************************************************
end
********************************************************************************
