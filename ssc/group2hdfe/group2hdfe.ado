*! version 1.01 03jul2014
*---------------------------------------------------------*
* fixed effects in a 2-way high-dimensional model
* Identifies the groups in the data
* Author: Paulo Guimaraes
* Mata version
* Based on Amine Quazad's a2reg program

*---------------------------------------------------------*
program define group2hdfe, rclass sortpreserve
syntax varlist(min=2 max=2), [largest(str) group(str) verbose]
version 10
if "`largest'"!="" {
confirm new var `largest'
}
if "`group'"!="" {
confirm new var `group'
}
tempfile temp
tokenize `varlist'
tempvar i j
qui gengroup `1' `i' 
qui gengroup `2' `j' 
if "`verbose'"!="" {
di "Saving original data"
}
preserve
contract `i' `j'
sort `i' `j'
if "`verbose'"!="" {
di "Starting Mata routine"
mata: mainloop("`i'","`j'","`verbose'")
di "Finished Mata routine"
}
else {
mata: mainloop("`i'","`j'")
}
quietly {
tempvar gr
keep `i' `j' _group
gengroup _group `gr'
drop _group
sort `i' `j'
save `temp'
restore
sort `i' `j'
merge `i' `j' using `temp'
}
if "`verbose'"!="" {
di "Almost there..."
}
drop _m
if "`largest'"!="" {
if "`verbose'"!="" {
di "Creating `largest' variable"
}
preserve
contract `gr'
sort _freq
local larg=`gr'[_N]
restore
gen byte `largest'=(`gr'==`larg')
}
qui sum `gr', meanonly
return scalar rest=r(max)
if "`group'"!="" {
rename `gr' `group'
}
if "`verbose'"!="" {
di "Done!"
}
di "There are " r(max) " mobility groups"
end

mata:
function mainloop(string scalar i, string scalar j,|string scalar verbose)
{
real colvector b1,b2,ord,group,ng1,ng2
real scalar stop, resindex, iter  
b1=st_data(.,i)
b2=st_data(.,j)
ord=range(1,rows(b1),1)
group=b1
stop=0
if (args()==3) {
iter=0
}
while (stop==0) {
if (args()==3) {
iter++
printf("Doing iteration--> %9.0f\n", iter)
}
ng1=calcminby(group,b2,ord)
ng2=calcminby(ng1,b1,ord)
stop=all((ng2:-group):==0)
group=ng2
}
resindex = st_addvar("long","_group")
st_store(.,resindex,group)
}
end

* returns a matrix C that contains the min of B1 by group B2
mata:
real matrix calcminby(numeric matrix B1,numeric matrix B2,numeric matrix B3)
{
real colvector ord1, ord2, C1, C2
ord1=order((B2,B1),(1,2))
C1=B1[ord1,.]
C2=B2[ord1,.]
ord2=order(B3[ord1,.],1)
for (i=2;i<=rows(C2);i++) {
if (C2[i,1]==C2[(i-1),1]) {
C1[i,1]=C1[(i-1),1]
}
}
return(C1[ord2,.])
}
end

* Equivalent to egen group function but faster
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

