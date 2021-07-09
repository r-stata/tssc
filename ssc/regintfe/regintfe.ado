*! version 1.04 10sep2012
* Estimates linear regression model with one high dimensional interacted fixed effect 
/*---------------------------------------------------------*/
/* Author: Paulo Guimaraes */
/*---------------------------------------------------------*/
*
program regintfe, eclass
version 9.1
if replay() {
    if ("`e(cmd)'"!="regintfe") error 301
    Display
}
else Estimate `0'
end

program define Estimate, eclass
syntax varlist [if] [in], id1(str) intvar(str) [cluster(str) VERBose]
*********************************************************************
* Checking syntax
*********************************************************************
if "`cluster'"!="" {
local vtype: type `cluster'
if substr("`vtype'",1,3)=="str" {
di in red "Error: Cluster variable must be numeric! "
error 198
}
}

tokenize `varlist'
local lhs `1'
mac shift
local rhs `*'
unab rhs: `*'
unab aux: `intvar'
local intvar "`aux'"

* Check to see if intvars already in rhs list
local check1: list varlist & intvar
if "`check1'"!="" {
di in red "Error: Interaction variables cannot be on lhs or rhs list! "
error 198
} 

local check2: list varlist & id1
if "`check2'"!="" {
di in red "Error: id variable cannot be on lhs or rhs list! "
error 198
} 

**********************************************************************
* Define Initial Values
**********************************************************************
tempfile origdata addvars
tempname name1

capture drop __touse
capture drop __uid
capture drop __fe*
capture drop _merge

gen long __uid = _n
sort __uid
if "`verbose'"!="" {
di in yellow "1 of 7 - Saving original file"
}
qui save `origdata'

***********************************************************************
* Do Main Loop
***********************************************************************

************ Mark usable sample and store all data
* Restrict data to usable sample
mark __touse `if' `in'
markout __touse `id1' `lhs' `rhs' `intvar' `cluster'
qui keep if __touse
keep __uid __touse `id1' `lhs' `rhs' `intvar' `cluster' 
*
***************************************
* Compute tss
qui sum `lhs', meanonly
tempvar yy sy
gen double `yy'=(`lhs'-r(mean))^2
gen double `sy'=sum(`yy')
local tss=`sy'[_N]
*
local nv : word count `intvar'
qui count
local N = r(N)
* Generate group variable
if "`verbose'"!="" {
di in yellow "2 of 7 - Creating group variable"
}
tempvar group
egen long `group'=group(`id1')
sort `group'
foreach var of varlist `varlist' {
recast double `var'
}
if "`verbose'"!="" {
di in yellow "3 of 7 - Transforming variables"
}
mata: transvar(1,"`varlist'","`intvar'","`group'")
if "`verbose'"!="" {
di in yellow "4 of 7 - Running the regression"
}

* Now do the regression
if "`cluster'"=="" {
quietly _regress `lhs' `rhs', nocons 
}
else {
quietly _regress `lhs' `rhs', nocons cluster(`cluster')
}
estimates store `name1'
keep __uid `group'
sort __uid
qui save `addvars', replace 
if "`verbose'"!="" {
di in yellow "5 of 7 - Reading original data"
}
use `origdata', clear
sort __uid
merge __uid using `addvars'
qui gen byte __touse=_merge==3
drop _merge

* Store the fixed effects
tempname xb res nn NN
qui predict double `xb' if __touse
qui gen double `res'=`lhs'-`xb'
qui gen double __fe0=0 if __touse
forval j=1/`nv' {
qui gen double __fe`j'=0 if __touse
local fes `fes' __fe`j'
}
local fes `fes' __fe0
sort __touse `group'
if "`verbose'"!="" {
di in yellow "6 of 7 - Calculating coefficients for fixed effects"
}

mata: transvar(2,"`res'","`intvar'","`group'","`fes'")
qui bys `group': gen long `nn'=_n if __touse
qui bys `group': gen long `NN'=_N if __touse

* Take care of unidentified fixed effects
tokenize `intvar'
tempvar dif
qui gen `dif'=`NN'-`nv' if __touse
sum `dif' if __touse, meanonly
local mindif=-r(min)
forval j=1/`nv' {
qui replace __fe`j'=0 if `dif'<0&__touse
}
qui replace __fe0=`res' if `dif'<0&__touse
forval j=1/`mindif' {
qui replace __fe0=__fe0-__fe`j'*``j'' if (`dif'<=-`j')&__touse
}

******************************************************************
* Count degrees of freedom
if "`verbose'"!="" {
di in yellow "7 of 7 - Counting degrees of freedom"
}
local ncoefint=0
forval j=0/`nv' {
qui count if (`nn'==`NN') & (__fe`j'<.) & (__fe`j'!=0)
local ncoefint=`ncoefint'+r(N)
}
local k : word count `rhs'
local dof = `N' - `k'-`ncoefint'
***************************************
qui estimates restore `name1'
local olddf_r=e(df_r)
local r=1-e(rss)/`tss'
ereturn scalar df_m = `k'+`ncoefint'-1
ereturn scalar mss=`tss'-e(rss)
ereturn scalar r2=`r'
ereturn scalar rmse=sqrt(e(rss)/(e(N)-e(df_m)-1))
if "`cluster'"=="" {
ereturn scalar df_r =e(N)-e(df_m)-1
ereturn scalar r2_a=1-(e(rss)/e(df_r))/(`tss'/(e(N)-1))
ereturn scalar F=(`r'/(1-`r'))*(e(df_r)/(`k'+`ncoefint'-1))
matrix V=(`olddf_r'/e(df_r))*e(V)
}
else {
ereturn scalar df_r =e(N_clust)-1
ereturn scalar F=.
ereturn scalar r2_a=.
matrix V=((`N'-`k')/(`N'-`k'-`ncoefint'))*e(V)
}
ereturn repost V=V
ereturn local cmdline "regintfe `0'"
ereturn local cmd "regintfe"
ereturn local predict ""
ereturn local estat_cmd ""
Display
sort __uid
capture drop __uid
capture drop __touse
capture drop `group'
end

program define Display
_coef_table_header, title( ********** Linear Regression with Interacted High-Dimensional Fixed Effect ********** )
_coef_table, level(95)
end

mata:
function transvar(real scalar vers, string scalar vars1, string scalar vars2, string scalar vars3,|string scalar vars4)
{
string rowvector v1n
v1n=tokens(vars1)
st_view(rhs=.,.,v1n,"__touse")
string rowvector v2n
v2n=tokens(vars2)
st_view(intvar=.,.,v2n,"__touse")
string rowvector v3n
v3n=tokens(vars3)
st_view(id1=.,.,v3n,"__touse")
if (vers==2) {
string rowvector v4n
v4n=tokens(vars4)
st_view(fes=.,.,v4n,"__touse")
}
info=panelsetup(id1,1)
for (i=1;i<=rows(info);i++) {
I=panelsubmatrix(intvar,i,info)
X=panelsubmatrix(rhs,i,info)
II=cross(I,1,I,1)
B=invsym(II)*(I,J(rows(I),1,1))'*X
if (vers==1) {
rhs[(info[i,1]::info[i,2]) ,. ]=X-(I,J(rows(I),1,1))*B
}
if (vers==2) {
for (j=info[i,1];j<=info[i,2];j++) {
fes[j,.]=B'
}
}
}
}
end
