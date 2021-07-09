*! version 3.02 13may2016
*---------------------------------------------------------*
* Counts the number of restrictions needed to identify
* fixed effects in a 3-way high-dimensional model
* Identifies a set with only two restrictions
* Author: Paulo Guimaraes
*---------------------------------------------------------*

program define group3hdfe, rclass sortpreserve
syntax varlist(min=3 max=3), [largest(str) VERBose initi(str) initj(str) initk(str)]
version 10
local verb="`verbose'"!=""
if "`largest'"!="" {
confirm new var `largest'
}
tokenize `varlist'
local i `1'
local j `2'
local k `3'
if `verb' {
di
di "Saving original data set..." 
}
preserve
if `verb' {
di
di "Done..." 
}
if `verb' {
di
di "Starting analysis" 
}
 
quietly {
bys `varlist': keep if _n == _N
gengroup `i' gi
gengroup `j' gj
gengroup `k' gk
}
matrix start=[0,0,0]
if "`initi'"!=""|"`initj'"!=""|"`initk'"!="" {
if (("`initi'"!=""&"`initj'"!="")|("`initi'"!=""&"`initk'"!="")|("`initj'"!=""&"`initk'"!="")) {
if ("`initi'"!=""&"`initj'"!="") {
testvalue  `i' `initi' `j' `initj'
matrix start[1,1]=gi[_N]
matrix start[1,2]=gj[_N]
}
if ("`initi'"!=""&"`initk'"!="") {
testvalue  `i' `initi' `k' `initk'
matrix start[1,1]=gi[_N]
matrix start[1,3]=gk[_N]
}
if ("`initj'"!=""&"`initk'"!="") {
testvalue `j' `initj' `k' `initk'
matrix start[1,2]=gj[_N]
matrix start[1,3]=gk[_N]
}
}
else {
di
di in red "Error: You must specify two valid initial values
error 198
}
}

tempvar ll Ngi Ngj Ngk
if (start[1,1]==0)&(start[1,2]==0)&(start[1,3]==0) {
if `verb' {
di
di "Selecting starting values" 
}

bys gi: gen `Ngi'=_N
bys gj: gen `Ngj'=_N
bys gk: gen `Ngk'=_N
gen `ll'=log(`Ngi')*log(`Ngj')*log(`Ngk')
sort `ll' `Ngi' `Ngj'
matrix start[1,1]=gi[_N]
matrix start[1,2]=gj[_N]
}
if "`largest'"!="" {
tempfile tmp0 tmp1 tmp2
gen long _ord=_n
if `verb' {
di
di "Starting Mata routine" 
}
mata: makelarge("gi","gj","gk","_ord")
if `verb' {
di
di "Done with Mata..." 
}
keep  `i' `j' `k' _ord _ord1
quietly { 
if `verb' {
di
di "Saving files..." 
}
save `tmp0', replace
keep _ord1
keep if _ord1>0
rename _ord1 _ord
sort _ord
save `tmp1', replace
use `tmp0', clear
drop _ord1
sort _ord
merge _ord using `tmp1'
keep if _merge==3
drop _merge _ord
sort `i' `j' `k'
save `tmp2', replace
}
}
else {
if `verb' {
di
di "Starting Mata routine" 
}
mata: mainloop("gi","gj","gk") 
return scalar rest=`r(rest)'
}
restore
if "`largest'"!="" {
if `verb' {
di
di "Merging data..." 
}
sort `i' `j' `k'
qui merge `i' `j' `k' using `tmp2'
gen byte `largest'=(_merge==1)
drop _merge
if `verb' {
di
di "Done..." 
}

}
end

***************************

mata:
function mainloop(string scalar i, string scalar j, string scalar k)
{
real matrix b, start, rest
real scalar caserow, stop, nrows1, nrows2, verb
b=st_data(.,(i,j,k))
verb=st_local("verb")
rest=J(1,3,0)
start=st_matrix("start")
rest=rest:+(start:>0)
setozero(b,start)
stop=rows(b)
while (stop>0) {
caserow=checkcase(b)
if (caserow==1) {
b=docase1(b,3)
}
if (caserow==21) {
b=docase1w2(b,1,2,3,3)
}
if (caserow==22) {
b=docase1w2(b,1,3,2,3)
}
if (caserow==23) {
b=docase1w2(b,3,2,1,3)
}
if (caserow==2) {
nrows1=rows(b)
b=dropsingletons(b,rest)
nrows2=rows(b)
if (nrows1==nrows2) {
b=docase2(b,rest)
}
}
if (caserow==3) {
b=docase3(b)
rest=rest:+(1,1,0)
}
stop=rows(b)
if (caserow==0) {
stop=0
}
printf("# of rows is: %f, # of restrictions is: %f \n", stop, sum(rest))
st_numscalar("r(rest)",sum(rest))
}
}
end

* Matrix A contains i,j,k,other
* Matrix B is 1x3 and contains values for i,j,k
* It replaces by zero the elements of A that show up in B

mata:
real matrix setozero(numeric matrix A, numeric matrix B)
{
A[.,1]=A[.,1]:*(A[.,1]:!=B[1,1])
A[.,2]=A[.,2]:*(A[.,2]:!=B[1,2])
A[.,3]=A[.,3]:*(A[.,3]:!=B[1,3])
A=uniqrows(select(A,rowsum(A):>0))
}
end

mata:
real scalar checkcase(numeric matrix B)
{
real matrix A, C
real scalar caseis
verb=st_local("verb")
A=B[.,1::3]
caseis=3-max(rowsum(A:==0))
if (caseis==2) {
C=uniqrows(select(A,rowsum(A:==0):<2))
if (rows(C)>0)  { 
z=J(rows(C),1,0)
_sort(C,(1,2,3))
for (j=2;j<=rows(z);j++) {
z[j,1]=(C[j,1]==C[j-1,1])*(C[j,2]==C[j-1,2])*((C[j-1,3]==0)+(z[j-1,1]==1))
}
if (sum(z)>0) {
caseis=21
}
else {
z=J(rows(C),1,0) 
C=sort(C,(1,3,2))
for (j=2;j<=rows(z);j++) {
z[j,1]=(C[j,1]==C[j-1,1])*(C[j,3]==C[j-1,3])*((C[j-1,2]==0)+(z[j-1,1]==1))
}
if (sum(z)>0) {
caseis=22
}
else {
z=J(rows(C),1,0)
C=sort(C,(3,2,1))
for (j=2;j<=rows(z);j++) {
z[j,1]=(C[j,3]==C[j-1,3])*(C[j,2]==C[j-1,2])*((C[j-1,1]==0)+(z[j-1,1]==1))
}
if (sum(z)>0) {
caseis=23
}
}
}
}
}
if (verb[1,1]=="1") {
printf("checkcase: case is : %f \n", caseis)
}
return(caseis)
}
end

mata:
real matrix docase1(numeric matrix A,real scalar k)
{
real matrix z,c
real scalar m
m=k+1
for (j=1;j<=3;j++) {
z=J(rows(A),1,3)-rowsum(A[.,1::3]:==0)
c=J(rows(A),1,0)
A=sort((A[.,1::k],z),(j,m))
c[1,1]=(A[1,m]==1)*(A[1,j]!=0)
for (i=2;i<=rows(A);i++) {
c[i,1]=(c[i-1,1]*(A[i,j]==A[i-1,j])+(A[i,m]==1)*(A[i,j]!=A[i-1,j]))*(A[i,j]!=0)
}
A[.,j]=(c:!=1):*A[.,j]
}
return(uniqrows(select(A[.,1::k],rowsum(A[.,1::3]:!=0))))
}
end

mata:
real matrix docase1w2(numeric matrix A, real scalar col1, real scalar col2, real scalar col3, real scalar k)
{
real matrix z
z=J(rows(A),2,0)
_sort(A,(col1,col2,col3))
for (j=1;j<=rows(A);j++) {
z[j,2]=A[j,col3]==0
}
z[.,1]=z[.,2]
for (j=2;j<=rows(A);j++) {
z[j,1]=z[j,1]+(z[j-1,1]==1)*((A[j-1,col1]==A[j,col1])*(A[j-1,col2]==A[j,col2]))
}
z[.,1]=z[.,1]:-z[.,2]
A=sort((A,z),(col3,-4))
for (j=2;j<=rows(A);j++) {
A[j,4]=A[j,4]+((A[j-1,4]>0)*(A[j-1,col3]==A[j,col3]))
}
for (j=2;j<=rows(A);j++) {
A[j,col3]=A[j,col3]*(1-(A[j,4]>0))
}
return(uniqrows(select(A[.,1::k],rowsum(A[.,1::3]:!=0))))
}
end

mata:
real matrix dropsingletons(numeric matrix A, numeric matrix R)
{
real matrix Z, B
real colvector z1,z2,z3, zz
real scalar nvars1, nrows1, nvars2, nrows2, rest
nvars1=sum(countvars(A))
nrows1=rows(A)
z1=mm_freq2(A[.,1]):*(A[.,1]:>0)
z2=mm_freq2(A[.,2]):*(A[.,2]:>0)
z3=mm_freq2(A[.,3]):*(A[.,3]:>0)
Z=(z1,z2,z3)
zz=rowsum(Z:==1)
B=uniqrows(select(A,zz:<1))
nvars2=sum(countvars(B))
nrows2=rows(B)
rest=nvars1-nvars2-nrows1+nrows2
R=R:+(rest,0,0)
if (rows(B)>0) {
return(B)
}
else {
return(J(0,0,0))
}
}
end

mata:
real matrix function expandvector(real colvector v)
{
real colvector A
real matrix C
A=uniqrows(select(v,v:>0))
C=v:==A[1,1]
if (rows(A)>1) {
for (j=2;j<=rows(A);j++) {
C=(C,v:==A[j,1])
}
}
return(C)
}
end

mata:
real matrix docase2(numeric matrix A, numeric matrix R)
{
real matrix B, M
real scalar z, nvars, rank, dif
z=rowsum(A[.,1::3]:!=0)
B=sort((A,z),(4,1,2,3))
A=B[.,1::3]
B=select(A,rowsum(A:==0):==1)
nvars=countvars(A)
if (nvars[1,1]==0) M=(expandvector(A[.,2]),expandvector(A[.,3]))
if (nvars[1,2]==0) M=(expandvector(A[.,1]),expandvector(A[.,3]))
if (nvars[1,3]==0) M=(expandvector(A[.,1]),expandvector(A[.,2]))
if ((nvars[1,1]>0)&(nvars[1,2]>0)&(nvars[1,3]>0)) M=(expandvector(A[.,1]),expandvector(A[.,2]),expandvector(A[.,3]))
rank=rank(M)
dif=sum(nvars)-rank
R=R:+(dif,0,0)
setozero(A,A[1,.])
}
end

mata:
real matrix docase3(numeric matrix A)
{
real matrix B,C
B=select(A,rowsum(A:==0):==0)
C=(B[1,1],B[1,2],0)
setozero(A,C)
return(A)
}
end

mata:
real matrix countvars(numeric matrix A)
{
real matrix B
B=J(1,3,0)
B[1,1]=rows(uniqrows(A[.,1]))-(min(A[.,1])==0)
B[1,2]=rows(uniqrows(A[.,2]))-(min(A[.,2])==0)
B[1,3]=rows(uniqrows(A[.,3]))-(min(A[.,3])==0)
return(B)
}
end

mata:
function makelarge(string scalar i, string scalar j, string scalar k, string scalar ord)
{
real matrix b, start, outvar
real scalar totob, caserow, nobs
b=st_data(.,(i,j,k,ord))
totob=rows(b)
start=st_matrix("start")
setozero(b,start)
caserow=1
while (caserow==1) {
caserow=checkcase(b)
if (caserow==1) {
b=docase1(b,4)
}
}
nobs=totob-rows(b)
outvar=(J(nobs,1,0)\b[.,4])
idx = st_addvar("long", "_ord1")
st_store(., idx, outvar)
}
end





*******************************************************************
* Stata routines
*******************************************************************

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

* Checks to see whether starting values are valid
program define testvalue
args var1 v1 var2 v2
tempvar dum1 dum2 dum3
gen byte `dum1'=(`var1'==`v1')
gen byte `dum2'=(`var2'==`v2')
gen byte `dum3'=`dum1'*`dum2'
qui count if `dum3'>0
if r(N)==0 {
di in red "Error: Invalid starting values!!! No observation found with `var1' = `v1' and `var2' = `v2' "
error 198
}
sort `dum3'
end

