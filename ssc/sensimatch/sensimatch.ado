********************************************************************************
*! sensimatch, v4, GCerulli, 12/10/2018
********************************************************************************
program sensimatch , eclass
version 14
#delimit ;     
syntax varlist [if] [in] [fweight pweight iweight] ,
mod(string)
sims(numlist max=1 integer)
seed(numlist max=1)
[
fac(varlist numeric)
save_sens(string)
vce(string)
gr1_title(string)
gr1_xtitle(string)
gr1_ytitle(string)
gr1_xsize(string)
gr1_ysize(string)
gr1_tsize(string)
gr1_save(string)
gr2_title(string)
gr2_xtitle(string)
gr2_ytitle(string)
gr2_xsize(string)
gr2_ysize(string)
gr2_tsize(string)
gr2_save(string)
gr_dep_var(string)
]
;
#delimit cr
********************************************************************************
* Generate dummies for factor variables
********************************************************************************
marksample touse
markout `touse' `fac'
********************************************************************************
di _newline(1)
di as result in red "************************************************************************"
di as result in red `"Wait please, computation can take time! "sensimatch" is working for you!"'
di as result in red "************************************************************************"
********************************************************************************
quietly{ // open quietly  
********************************************************************************
foreach V of local fac{
levelsof `V' , local(L)
local M: word count of `L'
local H=`M'-1
forvalues i=1/`M'{
cap drop _`V'`i'
}
qui tab `V' if `touse', gen(_`V') mis
local sum_`V' ""
forvalues i=1/`H'{
local sum_`V' `sum_`V'' _`V'`i'
}
}
********************************************************************************
local sum_tot ""
foreach V of local fac{
local sum_tot `sum_tot' `sum_`V''
}
********************************************************************************
local vars `varlist' 
tokenize `vars'
local y `1'
local w `2'
macro shift
macro shift
local xvars `*'
********************************************************************************
local varlist `xvars' `sum_tot'
local N : word count `varlist'  //   N = # of covariates
********************************************************************************
tempname J
local N=`N'-1
mat `J'=J(`N',7,.)
forvalues i=1/`N'{
xi: combreg  `y' `w' `xvars' if `touse' [`weight'`exp'] , s(`i') k(`sims') model(`mod') factors(`fac') seed(`seed') vce(`vce')
cap drop ATE1
mat `J'[`i',1]=`i'
mat `J'[`i',2]=e(delta)
mat `J'[`i',3]=e(b_bench)
mat `J'[`i',4]=e(mean_b_sim)
mat `J'[`i',5]=e(sd_b_sim)
mat `J'[`i',6]=e(mean_Tstud_sim)
mat `J'[`i',7]=e(t_bench)
}
********************************************************************************
qui count if `touse'
ereturn scalar N=r(N)
********************************************************************************
preserve
********************************************************************************
keep in 1/`N'
********************************************************************************
forvalues i=1/7{
tempvar `C`i''
}
tempvar C
svmat `J' , name(`C')
********************************************************************************
* Graph preparation
********************************************************************************
qui sum `C'3 if `touse'
local A=r(mean)
qui sum `C'6 if `touse'
local B=r(mean)
di `B'
qui sum `C'7 if `touse'
local D=r(mean)
di `D'
local G=round(`D', 0.01)
local N=`N'+1
local F=round(`A', 0.01) 
if "`mod'"=="match"{
local mymod "Propensity-score Matching"
}
else if "`mod'"=="reg"{
local mymod "Regression"
}
********************************************************************************
* Graph 1 - ATET
********************************************************************************
serrbar `C'4 `C'5 `C'1 , yline(`A', lpattern(dash)) scheme(s1mono) ///
xlabel(0(1)`N',labsize(vsmall)) xtitle(`gr1_xtitle' , size(`gr1_xsize')) ///
ytitle(`gr1_ytitle' , size(`gr1_ysize')) ylabel(, labsize(vsmall)) ///
title(`gr1_title' , size(`gr1_tsize')) ///
note("Number of simulations: `sims'" "Reference ATET: `F'" "Model: `mymod'" ///
"Number of baseline covariates: `N'" "Dependent variable: `gr_dep_var'", size(vsmall)) ///
plotregion(style(none)) msymbol(o) saving(`gr1_save' , replace)
********************************************************************************
tw connected `C'6 `C'1 , yline(`D', lpattern(dash) lwidth(medthick)) scheme(s1mono) ///
yline(1.645 , lwidth(thin) lpattern(dot)) yline(1.960 , lwidth(thin) lpattern(shortdash)) yline(2.576 , lwidth(thin) lpattern(longdash)) ///
xlabel(0(1)`N',labsize(vsmall))  ylabel(1.64 1.96 2.58  ,labsize(vsmall))  xtitle(`gr2_xtitle' , size(`gr2_xsize')) ///
ytitle(`gr2_ytitle' , size(`gr2_ysize')) ylabel(, labsize(vsmall)) ///
title(`gr2_title' , size(`gr2_tsize')) ///
note("Number of simulations: `sims'" "Reference T-student: `G'" "Model: `mymod'" ///
"Number of baseline covariates: `N'" "Dependent variable: `gr_dep_var'", size(vsmall)) ///
plotregion(style(none)) msymbol(o) saving(`gr2_save' , replace)
********************************************************************************
rename `C'4 _mean_sim
rename `C'5 _sd_sim
rename `C'1 _num_covs
keep _mean_sim _sd_sim _num_covs
save `save_sens' , replace
********************************************************************************
restore
********************************************************************************
} // end quietly
********************************************************************************
end
********************************************************************************
