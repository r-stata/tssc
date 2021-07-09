********************************************************************************
*! combreg, v4, GCerulli, 12/10/2018
********************************************************************************
program combreg, eclass
version 14
#delimit ;     
syntax varlist [if] [in] [fweight pweight iweight] ,
model(string)
s(numlist max=1 integer)
k(numlist max=1 integer)
seed(numlist max=1)
[
factors(varlist numeric)
vce(string)
graph
];
#delimit cr
********************************************************************************
quietly{ // open quietly  
********************************************************************************
marksample touse
markout `touse' `factors'
********************************************************************************
* Keep only the "if", and save the initial dataset into "mydata"
********************************************************************************
tempfile mydata
qui save `mydata' , replace
keep if `touse' 
********************************************************************************
* Generate dummies for factor variables
********************************************************************************
foreach V of local factors{
levelsof `V' , local(L)
local M: word count of `L'
local H=`M'-1
forvalues i=1/`M'{
cap drop _`V'`i'
}
qui tab `V' if `touse' , gen(_`V') mis
local sum_`V' ""
forvalues i=1/`H'{
local sum_`V' `sum_`V'' _`V'`i'
}
}
********************************************************************************
local sum_tot ""
foreach V of local factors{
local sum_tot `sum_tot' `sum_`V''
}
********************************************************************************
tokenize `varlist' `sum_tot'
local y `1'
local w `2'
macro shift
macro shift
local xvars `*'
********************************************************************************
local m=`s'
********************************************************************************
preserve
set seed `seed'
local varlist `xvars' 
local N : word count `varlist'  //   N = # of covariates
********************************************************************************
* Warning 1
********************************************************************************
if `s'>=`N'{
break
di _newline(2)
di as result in red "**********************************************************"
di as result in red "Warning: 's' must be lower than the number of covariates  "
di as result in red "considered in the benchmark model.                        "
di as result in red "**********************************************************"
exit 
}
********************************************************************************
clear
********************************************************************************
set obs `N'
tempvar X
gen `X'="."
********************************************************************************
local i=1
foreach x of local varlist{
replace `X'="`x'" in `i'
local i=`i'+1
}
replace `X'="" if `X'=="."
qui save `X' , replace
levelsof `X' , local(L) clean
di `"`L'"'
********************************************************************************
* K = number of re-samples 
********************************************************************************
forvalues j=`s'/`m'{
tempfile D`j'
}
********************************************************************************
forvalues j=`s'/`m'{
forvalues i=1/`k'{
tempfile S_`j'_`i'
}
}
********************************************************************************
forvalues j=`s'/`m'{
use `X' , clear
sample `j' , count
cap drop id
gen id = _n
drop `X'
save `D`j'' , replace
forvalues i=1/`k'{
use `X' , clear
sample `j' , count
cap drop id
gen id = _n
rename `X' `X'`j'`i'
save `S_`j'_`i'' , replace
use `D`j'' , clear
merge 1:1 id using `S_`j'_`i''
drop _merge
save `D`j'' , replace
}
}
********************************************************************************
forvalues j=`s'/`m'{
use `D`j'' , clear
forvalues i=1/`k'{
levelsof `X'`j'`i' , local(" L`j'`i'")  clean 
di `"L`j'`i'"'
}
}
cap erase `X'.dta
restore
********************************************************************************
* Model with all variables (Baseline model)
********************************************************************************
if "`model'"=="reg"{
xi: reg `y' `w' `varlist' if `touse' [`weight'`exp'] ,  vce(`vce') 
local ATET_original=_b[`w']
local se_att=_se[`w']
local Tstud_original=abs(_b[`w']/_se[`w'])
local lim=1.96*_se[`w']  
local upper=_b[`w']+`lim'   
local lower=_b[`w']-`lim'   
********************************************************************************
local B=`k'*(`m'-`s'+1)
********************************************************************************
tempname J
mat `J'=J(`B',2,.)
********************************************************************************
* Run the regressions/matchings for estimating ATET
local h=1
forvalues j=`s'/`m'{
forvalues i=1/`k'{
xi: reg `y' `w' `L`j'`i'' if `touse' [`weight'`exp'] ,  vce(`vce') 
******************************************************************************** 
mat `J'[`h',1] = _b[`w']
mat `J'[`h',2] = abs(_b[`w']/_se[`w'])
local h=`h'+1
}
}
}
********************************************************************************
else if "`model'"=="match"{
xi: psmatch2 `w' `varlist' if `touse' , out(`y') ate
local ATET_original=r(att)
local se_att=r(seatt)
local Tstud_original=r(att)/r(seatt)
local lim=1.96*`se_att'  
local upper=`ATET_original'+`lim'   
local lower=`ATET_original'-`lim' 
********************************************************************************
local B=`k'*(`m'-`s'+1)
********************************************************************************
tempname J
mat `J'=J(`B',2,.)
********************************************************************************
* Run the regressions/matchings for estimating ATET
local h=1
forvalues j=`s'/`m'{
forvalues i=1/`k'{
xi: psmatch2 `w' `L`j'`i'' if `touse' , out(`y') ate
*cap drop near_obs*
*teffects psmatch (`y') (`w' `L`j'`i'' , probit) , atet generate(near_obs) atet  
mat `J'[`h',1] = r(att)
mat `J'[`h',2] = r(att)/r(seatt)
local h=`h'+1
}
}
}
********************************************************************************
* Simulation results
********************************************************************************
cap drop _ATET*
svmat `J', names(_ATET)
local ate_bench=round(`ATET_original',0.01)
local Tstud_bench=round(`Tstud_original',0.01)
if "`graph'"=="graph"{
kdensity _ATET1 if `touse' , xline(`ATET_original',lpattern(dash)) xtitle("ATET") note("Number of simulations: `k'" ///
"Number of covariates: `s' out of `N'" "Reference ATET: `ate_bench'" ) scheme(s1mono) title("")
}
********************************************************************************
* Testing whether there are differences between model Ho and the 
* average of the simulated models
********************************************************************************
qui reg _ATET1  if `touse'
test _cons=`ATET_original'
********************************************************************************
* Returns
********************************************************************************
ereturn clear
qui sum _ATET1 if `touse' , d
local mean_b_sim=r(mean)
ereturn scalar mean_b_sim = r(mean)
ereturn scalar median_b_sim = r(p50)
ereturn scalar sd_b_sim = r(sd)
ereturn scalar b_bench = `ate_bench' 
ereturn scalar t_bench = `Tstud_bench'
local delta=abs((`mean_b_sim'-`ate_bench')/`ate_bench')
ereturn scalar delta = `delta'
ereturn scalar upci = `upper'
ereturn scalar lowci = `lower'
cap drop _ATET1
********************************************************************************
qui sum _ATET2 if `touse' , d
local mean_Tstud_sim=r(mean)
ereturn scalar mean_Tstud_sim = r(mean)
cap drop _ATET2
********************************************************************************
} // end quietly
********************************************************************************
qui use `mydata' , clear
end
********************************************************************************
* END
********************************************************************************
