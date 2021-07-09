*! Version 1, June 2017 Andreas Hartung

program aggind

version 10

syntax varlist(numeric) using/, metr(string) rad(real) [sum crcl]
tokenize `varlist'
local id `1'
macro shift 1
local variables `*'

if "`metr'" == "dist" {

tempfile master_temp
quietly: save "`master_temp'"

use `using'

qui ds
local id_origin: word 1 of `=r(varlist)'
qui ds
local id_target: word 2 of `=r(varlist)'
qui ds
local proximity: word 3 of `=r(varlist)'

rename `id_origin' start_aggind

gen double `id'=`id_target'

tempfile matrix_temp
quietly: save "`matrix_temp'"

use "`master_temp'"

tempvar context_index
bys `id': gen `context_index'=_n
quietly: keep if `context_index'==1

quietly: merge 1:m `id' using "`matrix_temp'"
quietly: drop if _merge==2
drop _merge

keep `id' `variables' start_aggind `id_target' `proximity'

sort start_aggind `proximity'

quietly: drop if `proximity'>`rad'

foreach vname in `variables' {
capture drop `vname'_`rad'_mean
bys start_aggind: egen `vname'_`rad'_mean=mean(`vname') 
label variable `vname'_`rad'_mean "average `vname' radius `rad'"
}

foreach vname in `variables' {
capture drop `vname'_`rad'_sum
bys start_aggind: egen `vname'_`rad'_sum=total(`vname')
label variable `vname'_`rad'_sum "sum `vname' radius `rad'"
}

tempvar total
bys start_aggind: gen `total'=_N
tempvar total_1
gen `total_1'=`total'-1

quietly: foreach vname in `variables' {
capture drop `vname'_`rad'_mean_noor
gen `vname'_sum_1=`vname'_`rad'_sum-`vname'
gen `vname'_`rad'_mean_noor=`vname'_sum_1/`total_1'
drop `vname'_sum_1
label variable `vname'_`rad'_mean_noor "average `vname' radius `rad', no origin"
}

quietly: keep if start_aggind==`id_target'

drop start_aggind `id_target' `proximity' `variables'

if "`sum'"==""{
foreach vname in `variables' {
drop `vname'_`rad'_sum
}
}

if "`crcl'"==""{
foreach vname in `variables' {
drop `vname'_`rad'_mean_noor
}
}

quietly: bys `id': keep if _n==1

tempfile master_temp2
quietly: save "`master_temp2'"

use "`master_temp'"

quietly: merge m:1 `id' using "`master_temp2'"
quietly: drop if _merge==2
drop _merge
}

if "`metr'" == "kn" {

tempfile master_temp
quietly: save "`master_temp'"

use `using'

qui ds
local id_origin: word 1 of `=r(varlist)'
qui ds
local id_target: word 2 of `=r(varlist)'
qui ds
local proximity: word 3 of `=r(varlist)'

rename `id_origin' start_aggind

gen double `id'=`id_target'

tempfile matrix_temp
quietly: save "`matrix_temp'"

use "`master_temp'"

tempvar context_index
bys `id': gen `context_index'=_n
quietly: keep if `context_index'==1

quietly: merge 1:m `id' using "`matrix_temp'"
quietly: drop if _merge==2
drop _merge

keep `id' `variables' start `id_target' `proximity'

sort start `proximity'

tempvar index
bys start_aggind: gen `index'=_n-1

quietly: drop if `index' > `rad'

foreach vname in `variables' {
capture drop `vname'_kn`rad'_mean
bys start_aggind: egen `vname'_kn`rad'_mean=mean(`vname')
label variable `vname'_kn`rad'_mean "average `vname' closest `rad'"
}

foreach vname in `variables' {
capture drop `vname'_kn`rad'_sum
bys start_aggind: egen `vname'_kn`rad'_sum=total(`vname')
label variable `vname'_kn`rad'_sum "sum `vname' closest `rad'"
}

tempvar total
bys start_aggind: gen `total'=_N
tempvar total_1
gen `total_1'=`total'-1

quietly: foreach vname in `variables' {
capture drop `vname'_kn`rad'_mean_noor
gen `vname'_sum_1=`vname'_kn`rad'_sum-`vname'
gen `vname'_kn`rad'_mean_noor=`vname'_sum_1/`total_1'
drop `vname'_sum_1
label variable `vname'_kn`rad'_mean_noor "average `vname' closest `rad', no origin"
}

quietly: keep if start_aggind==`id_target'

drop start_aggind `id_target' `proximity' `variables'

if "`sum'"==""{
foreach vname in `variables' {
drop `vname'_kn`rad'_sum
}
}

if "`crcl'"==""{
foreach vname in `variables' {
drop `vname'_kn`rad'_mean_noor
}
}

quietly: bys `id': keep if _n==1

tempfile master_temp2
quietly: save "`master_temp2'"

use "`master_temp'"

quietly: merge m:1 `id' using "`master_temp2'"
quietly: drop if _merge==2
drop _merge

}

if "`metr'" == "dist kn"  |  "`metr'" == "kn dist" {
di as error "proximity specifications cannot be combined"
}

if "`metr'" != "dist kn"  & "`metr'" != "kn dist" & "`metr'" != "kn" & "`metr'" != "dist" {
di as error "unknown proximity specification"
}

end
exit





	
