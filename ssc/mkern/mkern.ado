* ! MKER-Multivariate Kernel regression - 09oct2017 - GCerulli
********************************************************************************
*Mata function "mf_kernel_reg.mata"
********************************************************************************
mata: mata clear
mata: mata set matastrict off
version 14
mata:
// mf_kernel_reg 1.2 GCerulli 06may2017  (including cross-validation)
void function mf_kernel_reg(
string scalar xvars,
string scalar response,
string scalar fit,
real scalar bandh,
string scalar touse,
string scalar kernel,
string scalar model)
{
real matrix X, Z, mc, y, ystar, X0, X0WX0, X0WY
real colvector W , W1, wstar, d, b , d_std , d_h , C, ONE
real scalar n, k, i, j
string rowvector vars, v
st_view(X, ., tokens(xvars), touse)
// standardize vars with mm_meancolvar from moremata
mc = mm_meancolvar(X)
Z = (X :- mc[1,.]) :/ sqrt(mc[2,.])
n = rows(X)
k = cols(X)
st_view(y, ., response, touse)
st_view(ystar, ., fit, touse)
wstar=J(n,1,.)
// loop over observations
for(i = 1; i <= n; i++) {
// loop over vars
d = J(n, 1, 0)
for(j = 1; j <= k; j++) {
d = d + ( Z[., j] :- Z[i, j] ) :^2
}
d_std = (d :-min(d)):/(max(d)-min(d)) // 0<=d_std<=1
// bandh = bandwidth
d_h=d_std:/bandh // (x-x0)/h
W=mm_kern(kernel,d_h) // kern((x-x0)/h)
W1=W:/colsum(W)  // W1=Kernel weights sum-up to 1
// WLS
if (model=="linear"){  // begin linear
X0=X[.,.]:-X[i,.]
X0WX0 = cross(X0, 1, W1, X0, 1)
X0WY = cross(X0, 1, W1, y,0)
//b
b = cholsolve(X0WX0,X0WY)
ystar[i] = b[k+1] // it is the regression constant
wstar[i]=W1[i]  // this is the w_ii in the cross-validation formula
} // end linear
if (model=="mean"){  // begin mean
yw=y:*W1
ystar[i] = colsum(yw)
wstar[i]=W1[i]
} // end mean
}
ONE=J(n,1,1)
C=(y-ystar):/(ONE-wstar)
cv=(1/n)*C'C
st_eclear()
st_numscalar("r(CV)", cv)
st_numscalar("r(bandh)", bandh)
}
end
********************************************************************************
* PROGRAM "mkern"
********************************************************************************
program mkern , eclass
version 14
syntax varlist(numeric) [if] [in], y(varname numeric) y_fit(string) h(real) k(string) model(string) [graph]
marksample touse
qui gen `y_fit'=.
mata: mf_kernel_reg("`varlist'", "`y'", "`y_fit'",`h',"`touse'","`k'","`model'")
if "`graph'"!=""{
qui count if `touse'
local N=r(N)
tempvar id
gen `id'=_n if `touse'
local h2=round(`h',0.003)
tw (line `y' `id' if `touse' & `id'<=`N', xtitle("") clpattern(dash) clwidth(thin) clcolor(black)) ///
(line y_fitted `id' if `touse' & `id'<=`N', clpattern(solid) clwidth(thin) clcolor(red)) ,  ///
legend(ring(0) pos(5) order(1 "Row data" 2 "MKERN fit")) ///
note("Bandwidth = `h2'" "Kernel = `k'" "Model = Local `model'")
}
ereturn scalar CV=r(CV)
ereturn scalar band=r(bandh)
ereturn local kern="`k'"
end
********************************************************************************
* PROGRAM "min_cv_mkern"
********************************************************************************
*! min_cv_mkern v2.0.0 GCerulli 11jul2016
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
