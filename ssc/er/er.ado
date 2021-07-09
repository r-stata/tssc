*! Pogram to compute ER index
*! Carlos Gradin
*! This version 1.1, April 2014


cap program drop er
program def er, rclass  byable(recall)
version 7
syntax varlist(min=1 max=1) [aweight iweight fweight]  [if] [in] [ , Alpha(string) Normalize(string) Nonaggregate ]

set more off

local var:  word 1 of `varlist'

tempname n income y w mean er index value
marksample touse


if "`alpha'" == "" {
	local alpha "1.0 1.3 1.6"
}

if "`nonaggregate'" == "" {
	qui: tab `var' [`weight' `exp'] if `touse', matrow(`income') matcell(`w') missing label
	svmat `income' , names(`income')
	svmat `w' , names(`w')
	ren `income'1 `income'
	ren `w'1  `w'
}

else {
	local income `var'
	if "`weight'" == "" {
		gen `w'=1
	}
	else {
		gen `w' `exp'
	}

}	

local t=0
foreach a in `alpha' {
	local t=`t'+1
}


qui range `index' . `t' `t'
qui range `value' . `t' `t'


if "`nonaggregate'" ~= "" {
	local sample `touse'
}
else {
	local sample "`income'~=."
}


qui: sum `income' [aw=`w'] if `sample'
local mean r(mean)

if "`normalize'" == "mean" {
	qui: gen `y'=`income'/`mean' 	if `sample'
	lab var `value' "`var'/mean"
}
if "`normalize'" == "none" {
	qui: gen `y'=`income' 		if `sample'
	lab var `value' "`var'"
}
if "`normalize'" == "ln" | "`normalize'" == "" {
	qui: gen `y'=ln(`income') 	if `sample'
	lab var `value' "ln(`var')"
}

qui gen `n'=_n
sort `y'

qui: sum `y' [aw=`w']
local rn = r(N)
local sw = r(sum_w)

lab def `index'  1 ""
local t=0

	* ER

foreach a in `alpha' {
	local t =`t'+1
	scalar `er'_`t'=0
	lab def `index'  `t' "ER(`a')"	, modify
	forvalues i = 1 / `rn' {
		forvalues j = 1 / `i' {
			scalar `er'_`t' = `er'_`t' + (     abs( `y'[`i'] - `y'[`j'] ) *(     ( (`w'[`i']/`sw')^(1+`a') )*(`w'[`j']/`sw')  + ( (`w'[`i']/`sw') )*(`w'[`j']/`sw')^(1+`a')   )      )
		}
	}
	qui replace `index'=`t' 		if _n==`t'
	qui replace `value'=`er'_`t' 		if _n==`t'
	return scalar er_`t'     =`er'_`t'
}

lab val `index' `index'
lab var `index' "ER(alpha)"

di ""
di as text "{hline 100}"
di "Polarization index: Esteban and Ray (Econometrica, 1994)"
di ""
if "`nonaggregate'" ~= "" {
	di "Each observation treated as a distinct group (option {cmdab:n:onaggregate} requested)"
}
else {
	di "All observations with same `var' treated as belonging to the same group"
}


if "`normalize'" == "ln" | "`normalize'" == "" {
	di "Requested normalization: natural log (only positive values of `var' are used)"
}
if "`normalize'" == "none" {
	di "Requested normalization: none"
}
if "`normalize'" == "mean" {
	di "Requested normalization: division by the mean"
}


tabdisp  `index' if `value'~=., c(`value') concise stubwidth(20) csepwidth(1) cellwidth(20) 
dis ""

di as text "{hline 100}"

sort `n'
end
