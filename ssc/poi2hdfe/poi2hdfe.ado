*! version 2.3
* Estimates Poisson regression with two fixed effects
* Author: Paulo Guimaraes
* Date: Sep 16, 2016
* Allows estimation without explanatory variables
* Estimates algorithm using IRLS 
* Requires reghdfe (Sergio Correia)

program poi2hdfe, eclass
version 12

if replay() {
    if ("`e(cmd)'"!="poi2hdfe") error 301
    Display
}
else Estimate `0'
end

program define Estimate, eclass
************************************************************************************
syntax varlist [if] [in],           ///
        ID1(varname)                ///
        ID2(varname)                ///
        [tol1(real 1.000e-08)       /// convergence criteria for coefficients
        tol2(real 1.000e-08)        /// converge criteria for hdfe iterations
        cluster(varname)            /// cluster variable
        fe1(str)                    /// fixed effect for id1
        fe2(str)                    /// fixed effect for id2
        VERBose                     /// reports more info during estimation
        SAMPLE(str)                 /// new variable to capture sample used in estimation
        ]

************************************************************
* COLLECT LIST OF VARIABLES
************************************************************
tokenize `varlist'
local lhs `1'
mac shift
local rhs `*'
local nbvars: length local rhs
if `nbvars'>0 {
unab rhs: `*'
}
*********************************************************************
* CHECK SYNTAX
*********************************************************************
if "`cluster'"!="" {
local vtype: type `cluster'
if substr("`vtype'",1,3)=="str" {
di in red "Error: Cluster variable must be numeric! "
error 198
}
local clust "cluster(`cluster')"
}

if ("`fe1'"!=""&"`fe2'"=="")|("`fe2'"!=""&"`fe1'"=="") {
di in red "Error: You must specify both options fe1 and fe2"
error 198
}

if `"`fe1'"'!=`""' confirm new var `fe1' 
if `"`fe2'"'!=`""' confirm new var `fe2'
if `"`sample'"'!=`""' confirm new var `sample'

************************************************************
* TEMP VARS 
************************************************************
tempvar dev olddev mu eta W z res touse uid1 uid2
tempvar  sumy1 sumy2 off temp xb order f1 f2 NN
tempname v1 b bb bbb
************************************************************
* RESTRICT SAMPLE 
************************************************************
gen long `order'=_n
qui count
local BigN=r(N)
if "`verbose'"!="" {
di "Preserving original data"
di
}
preserve
mark `touse' `if' `in'
markout `touse' `lhs' `rhs' `id1' `id2' `cluster'
qui keep if `touse'

* Check fixed effects which have zero variation
if "`verbose'"!="" {
di "Check for fixed effects which zero variation"
di
}
qui gengroup `id1' `uid1'
qui gengroup `id2' `uid2'
qui gen `sumy1'=.
mata: fastsum("`lhs'","`sumy1'","`uid1'")
qui sum `sumy1', meanonly
if r(min)==0 {
di
di "Dropping `id1' groups for which `lhs' is always zeros"
qui drop if `sumy1'==0
}

qui gen `sumy2'=.
mata: fastsum("`lhs'","`sumy2'","`uid2'")
qui sum `sumy2', meanonly
if r(min)==0 {
di
di "Dropping `id2' groups for which `lhs' is always zeros"
qui drop if `sumy2'==0
}

local c1=1
local c2=2
* Dropping singletons
while `c1'>0|`c2'>0 {
bys `uid1': gen long `NN'=_N
qui count if `NN'==1
local c1=r(N)
if `c1'>0 {
di
di "Dropping `c1' groups for `id1' with a single observation"
qui drop if `NN'==1
}
drop `NN'
bys `uid2': gen long `NN'=_N
qui count if `NN'==1
local c2=r(N)
if `c2'>0 {
di
di "Dropping `c2' groups for `id2' with a single observation"
qui drop if `NN'==1
}
drop `NN'
}
qui count
di
di "Total Number of observations used in the regression -> " r(N)
di

if r(N)<`BigN' {
drop `uid1' `uid2'
qui gengroup `id1' `uid1'
qui gengroup `id2' `uid2'
}

****************************************************************************
* MAIN
****************************************************************************
di "Starting Estimation of coefficients"
di
gen double `off'=0
gen double `dev'=0
gen double `olddev'=0 
qui sum `lhs'
local meany=r(mean)
gen double `mu'=(`lhs'+`meany')/2
gen double `eta'=ln(`mu')
gen double `W'=0
gen double `z'=0
gen double `temp'=0
local dif=1
local counter=0
while abs(`dif')>`tol1' {
qui replace `W'=`mu'
qui replace `z'=`eta'+(`lhs'-`mu')/`mu'
capture drop `res'
qui hdfe `z' `rhs' [pw=`W'], absorb(`uid1' `uid2') gen(_RES_) tol(`tol2') keepsingletons 
qui _regress _RES_* [pw=`W'], nocons `clust'
_predict double `res', res
capture drop _RES_*
qui replace `eta'=`z'-`res'
qui replace `mu'=exp(`eta')
qui replace `olddev'=`dev'
qui replace `dev'=2*`mu'
qui replace `dev'=2*(ln(`lhs'/`mu')-(`lhs'-`mu')) if `lhs'>0
qui replace `temp'=sum(reldif(`dev',`olddev'))
local dif=`temp'[_N]/_N
local counter=`counter'+1
di "`counter' dif is -> " `dif'
}
di
di "Coefficients converged after `counter' reghdfe calls "
di
matrix `b'=e(b)
matrix `v1'=e(V)
local N=e(N)
* Prepare estimation results
ereturn clear
matrix rownames `b' = `lhs' 
matrix colnames `b' = `rhs'
matrix rownames `v1' = `rhs' 
matrix colnames `v1' = `rhs'
ereturn post `b' `v1', depname(`lhs') obs(`N') 
*ereturn scalar ll=`ll'
*ereturn scalar ll_0=`ll0'
ereturn scalar dev=`dev'
ereturn local cmdline "poi2hdfe `0'"
ereturn local cmd "poi2hdfe"
ereturn local crittype "log likelihood"
ereturn local vcetype "Robust"
ereturn local vce "robust"
ereturn local crittype "log pseudolikelihood"
if "`cluster'"!="" {
ereturn local vcetype "Robust"
ereturn local vce "cluster"
ereturn local clustvar "`cluster'"
ereturn local crittype "log pseudolikelihood"
sort `cluster'
qui count if `cluster'!=`cluster'[_n-1]
ereturn scalar N_clust=r(N)
}
Display
if (`"`fe1'"'!=`""' & `"`fe2'"'!=`""') { 
qui reghdfe `z' `rhs' [pw=`W'], absorb(`f1'=`uid1' `f2'=`uid2')
rename `f1' `fe1'
rename `f2' `fe2'
label var `fe1' "Fixed effect for `id1'"
label var `fe2' "Fixed effect for `id2'"
}
if ("`sample'"!="") { 
capture gen byte `sample'=1
label var `sample' "Sample indicator"
}
if (`"`fe1'"'!=`""' & `"`fe2'"'!=`""')|("`sample'"!="") { 
tempfile fes
keep `order' `fe1' `fe2' `sample'
sort `order'
qui save `fes', replace
restore
sort `order'
qui merge 1:1 `order' using `fes'
capture replace `sample'=0 if `sample'==. 
sort `order'
drop _m 
}
drop `order' 
end

************************************************************************
* DISPLAY 
************************************************************************
program define Display
_coef_table_header, title( ******* Poisson Regression with Two High-Dimensional Fixed Effects ********** )
_coef_table, level(95)
end
************************************************************************
* GENGROUP
************************************************************************
program define gengroup
args v1 v2
local vtype: type `v1'
sort `v1'
gen long `v2'=.
if substr("`vtype'",1,3)=="str" {
replace `v2'=1 in 1 if `v1'!="" 
replace `v2'=`v2'[_n-1]+(`v1'!=`v1'[_n-1]) if (`v1'!=""&_n>1)
}
else {
replace `v2'=1 in 1 if `v1'<. 
replace `v2'=`v2'[_n-1]+(`v1'!=`v1'[_n-1]) if (`v1'<.&_n>1)
}
end
************************************************************************
* FASTSUM (by Sergio Correia)
************************************************************************
mata:
mata set matastrict on
function fastsum(string scalar varname, string scalar sumvar, string scalar groupid)
{
	real colvector Var, Newvar, ID
	real colvector Summ
	real scalar G, N, i, k
	st_view(Var=., ., varname)
	st_view(ID=., ., groupid)
	G = max(ID)
	N = rows(Var)
	Summ = J(G,1, 0)
	Newvar = J(N,1, .)
	assert(G<N)
	for (i=1; i<=N; i++) {
		k = ID[i]
		Summ[k] = Summ[k] + (Var[i])
	}
	for (i=1; i<=N; i++) {
		k = ID[i]
		Newvar[i] = Summ[k]
	}
	st_store(.,sumvar, Newvar)
}
end

