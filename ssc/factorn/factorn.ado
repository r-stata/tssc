*! version 8.2  7July2016 Author : Jay Dev Dubey 
*! factorn - to compute all the factors of an integer

cap prog drop factorn 
prog define factorn 

version 8.2
gettoken i 0 : 0
syntax 

local i = `i' 
if `i'==0 {
exit
}

if `i'==1 {
di as txt "1 is a prime number"
exit
}

cap assert mod(`i',1)==0 
if _rc!=0 {
di as err "only intergers allowed" 
exit 198
}

if `i'>= 107374179 {
di as err "obs must be less than  107374179" 
exit 198
}

qui des
if r(N) > 0 & r(k) > 4997 {
di as err "new varlist not allowed" 
exit 198
}

qui des
if r(N)==0 & r(k)==0 {
local j = `i'-1
qui set obs `j'
FACt1
}

qui des
if r(N) > 0  & r(k) <=4996 {
if r(N) > = `i'  {
local x = `i'
FACt2 `x'
}
}

qui des
if r(N) > 0  & r(k) <=4996 {
if `i' > r(N)  {
qui {
cou
local cou = r(N)
local j = `i'-1
set obs `j'
tempvar order 
gen `order' = _n 
noi FACt3
sort `order'
keep in 1/`cou'
}
}
}
end

cap prog drop FACt1
prog define FACt1
syntax 
tempvar quo dispvar length
qui {
gen `quo' = . 
gen `dispvar' =""
cou
local n = r(N)+1
local i = 1
while `i' < `n' {
replace `quo' = `n'/`i' in `i' 
local i = `i'+1
}
replace `quo'= 1 in f
drop if mod(`quo',1)!=0
sort `quo' 
replace `dispvar' = string(`quo')
gen `length' = length(`dispvar')
cou 
local cou = r(N)
qui su `length'  
local size = r(max)
noi DispPItr `dispvar' `cou' `size' 
qui su `quo'
if r(N)==1 {
noi di as txt "`n' is a prime number"
}
if r(sum)==`n' {
noi di as txt "Wow, `n' is a perfect number"
}
}
end


cap prog drop FACt2
prog define FACt2

gettoken cou 0 : 0
local n = `cou'

tempvar quo dispvar length order
qui {
gen `order' = _n
gen `quo' = . 
gen `dispvar' =""
local i = 1
while `i' < `n' {
replace `quo' = `n'/`i' in `i' 
local i = `i'+1
}
replace `quo' = 1 in f
replace `quo' = . if mod(`quo',1)!=0
replace `dispvar' = string(`quo')
cap replace `dispvar' = "" if `dispvar'=="."
sort `quo' 
gen `length' = length(`dispvar')
cou if `dispvar'!=""
local cou = r(N)
qui su `length'  
local size = r(max)
noi DispPItr `dispvar' `cou' `size' 
qui su `quo'
if r(N)==1 {
noi di as txt "`n' is a prime number"
}
if r(sum)==`n' {
noi di as txt "Wow, `n' is a perfect number"
}
sort `order'
}
end

cap prog drop FACt3
prog define FACt3

tempvar quo dispvar length 
qui {
gen `quo' = . 
gen `dispvar' =""
cou
local n = r(N)+1
local i = 1
while `i' < `n' {
replace `quo' = `n'/`i' in `i' 
local i = `i'+1
}
replace `quo' = 1 in f
replace `quo' = . if mod(`quo',1)!=0
replace `dispvar' = string(`quo')
cap replace `dispvar' = "" if `dispvar'=="."
sort `quo' 
gen `length' = length(`dispvar')
cou if `dispvar'!=""
local cou = r(N)
qui su `length'  
local size = r(max)
noi DispPItr `dispvar' `cou' `size' 
qui su `quo'
if r(N)==1 {
noi di as txt "`n' is a prime number"
}
if r(sum)==`n' {
noi di as txt "Wow, `n' is a perfect number"
}
}
end

cap prog drop DispPItr
prog define DispPItr

gettoken var 0 : 0
gettoken cou 0 : 0
gettoken size 0 : 0

local var = "`var'" 
local cou  = `cou'
local size = `size'
local size1 = `size'+1
local space = `cou'*`size1'
local lines = int(`space'/c(linesize)) 
local lines = int(cond(`lines'>int(`lines'), `lines'+1, `lines'))+1


forvalues i=1(1)`lines' { 
local sk = `i'-1
local a = int(c(linesize)/`size1')
local j = 1+(`i'-1)*`a'
local k = `i'*`a'
if min(`k',_N-`k') < 0 {
local k = _N
}
local col = 1
while `j'  < `k'+1 {
local tr = `var' in `j'
local lnt = length(`var') in `j'
di as txt _column(`col') _c "`tr'" _c
local col = `col'+`size'+1
local j = `j'+1
}
noi di _skip(`sk')
}
end 
