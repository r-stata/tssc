*Version September 2013

program drop _all
program define norm
version 9
syntax varlist(min=1) [if] [in][, by(varlist) method(string)]

marksample touse

tokenize `if' `in'

if "`method'"~="zee" & "`method'"~="mmx" & "`method'"~="softmax" & "`method'"~="sigmoid"  {
	di as err "Please select appropriate normalization method from available options zee, mmx, softmax & sigmoid"
	exit 198
	}


if "`method'"=="zee" {

foreach var of local varlist  {
tempvar mean sd
qui  egen `mean'_`var' = mean(`var'), by( `by'),  `if' `in'
qui  egen `sd'_`var' = sd(`var'), by( `by'),  `if' `in'
qui  gen zee_`var' = (`var' - `mean'_`var') / `sd'_`var' `if' `in'
}
}

if "`method'"=="mmx" {

foreach var of local varlist  {
tempvar min max
qui  egen `min'_`var' = min(`var'), by( `by'),  `if' `in'
qui  egen `max'_`var' = max(`var'), by( `by'),  `if' `in'
qui  gen mmx_`var' = ((`var' - `min'_`var') / (`max'_`var' - `min'_`var')) `if' `in'
}
}

if "`method'"=="softmax" {

foreach var of local varlist  {
tempvar mean sd x
qui  egen `mean'_`var' = mean(`var'), by( `by'),  `if' `in'
qui  egen `sd'_`var' = sd(`var'), by( `by'),  `if' `in'
qui  gen `x'_`var' = (`var' - `mean'_`var') / `sd'_`var' `if' `in'
qui  gen softmax_`var' = 1/(1+exp(-`x'_`var')) `if' `in'
}
}

if "`method'"=="sigmoid" {

foreach var of local varlist  {
tempvar mean sd z
qui  egen `mean'_`var' = mean(`var'), by( `by'),  `if' `in'
qui  egen `sd'_`var' = sd(`var'), by( `by'),  `if' `in'
qui  gen `z'_`var' = (`var' - `mean'_`var') / `sd'_`var' `if' `in'
qui  gen sigmoid_`var' = (1-exp(-`z'_`var')) /(1+exp(-`z'_`var')) `if' `in'
}
}

end
