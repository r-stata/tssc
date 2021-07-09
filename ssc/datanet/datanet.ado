program define datanet
*! 27/02/2017
version 14
syntax [varlist]  , save(string) [DUPlicate]
********************************************************************************
tokenize "`varlist'"
local id "`1'"
macro shift 1
local x "`*'"
********************************************************************************
preserve
********************************************************************************
qui{
tempvar idn id1 id2 y id1s id2s id_new1 id_new2 id_new3 id_in id_out
sort `id'
tempvar prova
gen `prova'=`id' 
encode `prova', gen(_id_label3012)
encode `id', gen (`idn') 
label list
drop `id'
rename `idn' `id'
order `id' `x'
global n=_N
expand $n
bys `id': gen `id2'=_n
label values `id2' `idn'
rename `id' `id1'
order `id1' `id2'
global N=_N
gen `y'=.
forvalues i=1($n)$N{
    local k=1
    forvalues j=1/$n {
       local m=`j'+`i'-1
	   if `x'[`m']==`x'[`k']{
				             replace `y'=`x' in `m'  
				             }
	   else{
	                         replace `y'=0 in `m'
	
	       }
	local k = `k'+$n	   
	
	 }
	
}
drop if `y'==0
drop if `id1' == `id2'
drop `y'
order   `id1' `id2' `x'
replace `id2'=. if `x'==.

if "`duplicate'"!="duplicate"{
tostring `id1' `id2' , gen(`id1s' `id2s')
gen `id_new1'=`id1s'+`id2s'
gen `id_new2'=`id2s'+`id1s'
qui count 
global n_new=r(N)
cap drop `id_new3'
gen `id_new3'=.
forvalues i=1/$n_new{
forvalues j=1/$n_new{
if (`id_new1'[`i']==`id_new2'[`j']){
replace `id_new3'=1 in `i'
replace `id_new3'=0 in `j'
}
}
}
drop if `id_new3'==1
cap drop _id_1
decode `id1' , generate(_id_1)
cap drop _id_2
decode `id2' , generate(_id_2)
order  _id_1 _id_2
drop `x'
encode _id_1 , gen(_d_1n)
encode _id_2 , gen(_d_2n)
rename _d_1n IN
rename _d_2n OUT
cap drop _id_1 _id_2
cap drop _id_label3012
}
else{
cap drop _id_1
gen _id_1 = `id1'
cap drop _id_2
gen _id_2 =`id2'
order  _id_1 _id_2
drop `x'
rename _id_1 IN
rename _id_2 OUT
label values IN _id_label3012
label values OUT _id_label3012
cap drop _id_label3012
}
keep IN OUT
save `save' , replace
}
restore
end
********************************************************************************