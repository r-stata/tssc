*! version 1.05  22apr2013
* author: Paulo Guimaraes
* 
program define scoregrp, rclass
version 11

************************************************************
syntax [varlist(default=none)],group(varname) [nocons]

* check if matdelrc installed

capture matdelrc
if _rc != 0 {
di as err "Error - Please install the user-written command matdelrc"
di "type -findit matdelrc-"
exit 601
}

tempvar groups score y one

quietly {

if "`varlist'"==""&"`cons'"!="" {
    noisily di "No variable to test"
    error 301
}

if "`cons'"!="" {
    local xx0="`varlist'"
}
else {
    local addone "`one'"
    local xx0: list varlist|addone
}

************************************************************
* Obtain information from last regression
************************************************************
local vcetype=e(vce)
local command=e(cmd)
if "`command'"=="poisson"|"`command'"=="logit"|"`command'"=="logistic"|"`command'"=="probit" {
    if "`vcetype'"!="oim" {
        noisily di as err "Not valid with vce(`vcetype')"
    	error 111
	}
noisily di
noisily di as text "Score test for `command' regression"
}
else if "`command'"=="regress" {
	if "`vcetype'"!="ols" {
        noisily di as err "Not valid with vce(`vcetype')"
        error 111
    }
noisily di
noisily di as text "Score test for Linear regression"
    local mse=e(df_r)/e(N)*(e(rmse)^2)
}
else {
noisily di "Only valid after Regress, Poisson, Probit, Logit or Logistic command"
    error 111
}

local xx1 : rownames e(V)  /*all variables in the regression*/
* Test if variables belong to varlist
local dummy: list varlist in xx1
if `dummy'==0 {
    noisily di as err "Error: at least one of the variables in `varlist'" 
    di as err "does not belong to list of predictors or is repeated"
    error 111
}
local constant "_cons"         
local xx2: list xx1-constant   
local xx3: list xx2|one      /*all vars with constant */
local xx4: list xx3-xx0      /*vars not tested*/
***********************************************************
* Do validity checks
***********************************************************
qui sum `group'
	if `r(min)' == `r(max)' {
	noisily di as err "The group variable `group' must have at least two different values!"
	error 198
} 
************************************************************
* Restrict the sample to valid observations
***********************************************************
preserve
keep `xx2' `e(depvar)' `group' 
qui keep if e(sample)
***********************************************************
* Compute Preliminary variables/constants
gen int `one'=1
matrix B=e(V)
local maxg=`e(N)'-colsof(B)  /*Maximum nb of degrees of freedom*/
************************************************************
* Computing scores
************************************************************
tempname s_

if "`command'"=="poisson"|"`command'"=="logit"|"`command'"=="logistic"|"`command'"=="regress" {
tempvar yhat
qui predict double `yhat'
}

if "`command'"=="probit" {
tempvar xbhat lami
qui predict double `xbhat', xb
gen double `lami'=(2*`e(depvar)'-1)*normalden((2*`e(depvar)'-1)*`xbhat')/normal((2*`e(depvar)'-1)*`xbhat')
}

foreach var in `xx0' {
    if "`command'"=="poisson"|"`command'"=="logit"|"`command'"=="logistic" {
    gen double `s_'`var'=(`e(depvar)'-`yhat')*`var'
    }
    if "`command'"=="probit" {
    gen double `s_'`var'=`lami'*`var'
    }
    if "`command'" == "regress" {
    gen double `s_'`var'=(`e(depvar)'-`yhat')/(`mse')*`var'
    }
}
*************************************************************
* Computing Crossed Derivatives
*************************************************************
tempname haa_
local dum "`xx0'"
foreach var1 in `xx0' {
foreach var2 in `dum' {
        if "`command'" == "poisson" {
        gen double `haa_'`var1'_`var2'=`var1'*`var2'*`yhat'
        }
        if "`command'" == "logit"|"`command'"=="logistic" {
    gen double `haa_'`var1'_`var2'=`var1'*`var2'*`yhat'*(1-`yhat')
        }
        if "`command'" == "probit" {
    gen double `haa_'`var1'_`var2'=`var1'*`var2'*`lami'*(`lami'+`xbhat')
        }
        if "`command'" == "regress" {
    gen double `haa_'`var1'_`var2'=`var1'*`var2'/(`mse')
        }
}
local dum: list dum-var1
}
tempname hab_
foreach var1 in `xx4' {
foreach var2 in `xx0' {
        if "`command'" == "poisson" {
            gen double `hab_'`var1'_`var2'=`var1'*`var2'*`yhat'
        }
        if "`command'" == "logit"|"`command'"=="logistic" {
            gen double `hab_'`var1'_`var2'=`var1'*`var2'*`yhat'*(1-`yhat')
        }
        if "`command'" == "probit" {
            gen double `hab_'`var1'_`var2'=`var1'*`var2'*`lami'*(`lami'+`xbhat')
        }
        if "`command'" == "regress" {
            gen double `hab_'`var1'_`var2'=`var1'*`var2'/(`mse')
        }
}
}
egen long `groups'=group(`group') /*Compute unique id for groups*/

**********************************************************
unab haa: `haa_'*
unab sco: `s_'*

if "`xx4'"!="" {
unab hab: `hab_'*
matrix H=invsym(e(V))
if "`command'"=="regress" {
matrix V=H
matrix H=(e(N)/e(df_r))*V
}
foreach var in `xx0' {
local pos: list posof `"`var'"' in xx3
matdelrc H, row(`pos') col(`pos')
local xx3: list xx3-var
}
}
collapse (sum) `haa' `hab' `sco', by(`groups')
local nbtvars: list sizeof xx0
local df=min((_N-1)*`nbtvars',`maxg')
***************************************************************************

if "`xx4'"!="" {
noisily mata: testever("`sco'","`haa'","`hab'")
}
else {
noisily mata: testever("`sco'","`haa'")
}
}
**************************************************************************

local xx5: list xx1-xx4
if "`cons'"!="" {
    local xx5: list xx5-constant   
}
di as txt "Testing variables: `xx5'"
di as txt "Group variable: `group'"
di
di as txt %6.0f "Test result is chi(`df') = " as res %-9.4f `r(test)' as txt ///
" Pr = " as res %-9.4f chi2tail(`df',`r(test)')
return scalar pval=chi2tail(`df',`r(test)')
return scalar test=`r(test)'
set trace off
end

mata:
function testever(string scalar vars1, string scalar vars2 ,|string scalar vars3)
{
string rowvector scoresv
scoresv=tokens(vars1)
st_view(scores1=.,.,scoresv)
string rowvector haav
haav=tokens(vars2)
st_view(haa1=.,.,haav)
if (args()==3) {
string rowvector habv
habv=tokens(vars3)
st_view(hab1=.,.,habv)
mv=st_matrix("H")
k2=cols(mv)
}
k1=cols(scoresv)
g=rows(scoresv)
if (k1==1) {
saH=scores1:/haa1
s1=cross(saH,scores1)
s2=0
if (args()==3) {
habw=hab1:/haa1
d1=cross(hab1,habw)
d2=invsym(mv-d1)
d3=cross(scores1,habw)
s2=d3*d2*d3'
}
}
if (k1>1) {
s1=crossblock(scores1,haa1,scores1)
s2=0
if (args()==3) {
P1=J(1,k2,0)
P2=J(k2,k2,0)
for (i=1;i<=k2;i++) {
p12=hab1[.,(((i-1)*k1+1)::i*k1)]
P1[1,i]=crossblock(scores1,haa1,p12)
}
for (i=1;i<=k2;i++) {
p12=hab1[.,(((i-1)*k1+1)::i*k1)]
for (j=i;j<=k2;j++) {
p13=hab1[.,(((j-1)*k1+1)::j*k1)]
P2[i,j]=crossblock(p13,haa1,p12)
P2[j,i]=P2[i,j]
}
}
P=mv-P2
s2=P1*invsym(P)*P1'
}
}	
lm=s1+s2
test=lm[1,1]
st_numscalar("r(test)",test)
}

real scalar crossblock( numeric matrix L, numeric matrix B, numeric matrix R)
{
real scalar g, k1, k2, s1
real matrix temp1,ll,rr,bb,BB
g=rows(B)
k1=cols(L)
k2=k1*(k1-1)/2+k1
temp1=J(g,1,0)
ll=J(k1,1,0)
rr=J(k1,1,0)
bb=J(k2,1,0)
for (i=1;i<=g;i++) {
for (j=1;j<=k1;j++) {
ll[j,.]=L[i,j]
rr[j,.]=R[i,j]
}
for (j=1;j<=k2;j++) {
bb[j,.]=B[i,j]
}
BB=invvech(bb)
temp1[i,1]=ll'*invsym(BB)*rr
}
s1=sum(temp1)
return(s1)
}
end
