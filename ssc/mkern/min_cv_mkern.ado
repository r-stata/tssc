********************************************************************************
* PROGRAM "min_cv_mkern"
********************************************************************************
*! min_cv_mkern v2.0.0 GCerulli 11jul2017
capture program drop min_cv_mkern
program min_cv_mkern, eclass
version 14
#delimit;     
syntax varlist [if] [in] [fweight iweight pweight] [,
kern(string)
cvfile(string)
modeltype(string)
graph];
#delimit cr
********************************************************************************
marksample touse
tokenize `varlist'
local y `1'        // y = outcome
macro shift
local xvars `*'    // xvars = covariates
********************************************************************************
qui count
local N_obs=r(N)
qui count if `touse'
local N=r(N)
********************************************************************************
* COMPUTE THE "CROSS-VALIDATION" PROCEDURE BY GENERATING A GRID 
* MADE OF 500 BANDWIDTHS (FROM 0.01 TO 0.5, BY A STEP OF 0.001)
********************************************************************************
tempname M
mat `M'=J(500,3,.)
local j=1
forvalues b=0.01(0.01)0.5{   
cap drop y_fitted
mkern `xvars' if `touse' , y(`y') y_fit(y_fitted) h(`b') k(`kern') model(`modeltype')
*
mat `M'[`j',1]=`j'
mat `M'[`j',2]=`b'
mat `M'[`j',3]=e(CV)
local j=`j'+1
}
svmat `M' , names(__M)
rename __M1 _step
rename __M2 _bandw
rename __M3 _CV
qui sum _CV , d
ereturn scalar min_CV = r(min)
qui sum _bandw if _CV==r(min)
ereturn scalar opt_bandw = r(mean)
********************************************************************************
* PUT THE RESULT OF THE CROSS-VALIDATION INTO A DATASET CALLED "cvfile"
********************************************************************************
if "`cvfile'"!=""{
preserve
keep _step _bandw _CV 
save `cvfile' , replace
restore
drop _step _bandw _CV
}
else{
drop _step _bandw _CV
}
********************************************************************************
end
********************************************************************************