* Authors: Ercio Munoz & Mariel Siravegna 
*! version 1.0.0 22August2020

*** predict command for qregsel ***
cap program drop qregsel_p

program define qregsel_p
	version 16.0
	
	syntax newvarlist(min=2 max=2 generate) [if] [in]
	
	marksample touse, novarlist
	
	local copula  "`e(copula)'"
	local selection_eq = "`e(select_eq)'"
	local outcome_eq = "`e(outcome_eq)'"
	local depvar = "`e(depvar)'"
	local indepvars = "`e(indepvars)'"
	
	local noconstant: list indepvars- outcome_eq
	if ("`noconstant'"=="") local noconstant "noconstant" 
	
	if ("`e(rescale)'"=="rescaled") local rescale = "rescale"
	if ("`e(rescale)'"=="non-rescaled") local rescale = ""
	local rho = e(rho)
	local kendall = e(kendall)
	local spearman = e(spearman)
		
	tempname coefs grid
	tempvar v pZ sorting sample

	g `sample' = e(sample)
	mat `grid' = e(grid)
	local newvar1 = "`1'"
	local newvar2 = "`2'"
	
quietly {
tokenize `selection_eq', parse("=")
	if "`2'" != "=" {
		local x_s `selection_eq'
		tempvar y_s
		qui gen `y_s' = (`depvar'!=.)
	}
	else {
		local y_s `1'
		local x_s `3'
	}
	capture unab x_s : `x_s'
qui: probit `y_s' `selection_eq'
qui: predict `pZ'
	
#delimit ;
_qregsel `outcome_eq' if `sample', select(`selection_eq') quantile(
 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20
 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 
 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 
 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 
 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99)
 copula(`copula') rho(`rho') `rescale' `noconstant'
 egrid(`grid') kendall(`kendall') spearman(`spearman');
#delimit cr
mat `coefs' = e(coefs)' 

tempvar q1 q2
gen `q1' = uniform()
gen `q2' = uniform()
g `sorting' = _n

if "`copula'" == "frank" {
gen `v'  = (-1/`rho')*log(1+(`q2'*(exp(-`rho')-1))/(1+(1-`q2')*(exp(-`rho'*`q1')-1)))
}
if "`copula'" == "gaussian" {
gen `v' = rnormal(.5+`rho'*(`q1'-.5),sqrt((1-`rho'^2)/12))
}
replace `newvar2'  = (`v'<=`pZ') if !missing(`pZ')
replace `q1' = (int(`q1'*99 + 1))

tempname X b Y output

local myvars "`e(indepvars)'"
local not "_cons"
local nv1 : word count `myvars'
local myvars: list myvars- not
local nv2 : word count `myvars'
	if "`rescale'"!="" {
	mata: `X'  = st_data(., "`myvars'")
	mata: `X'  = (`X':-mean(`X')):/sqrt(mm_colvar(`X'))
	}
	else {
	mata: `X'  = st_data(., "`myvars'")
	}
if (`nv1'!=`nv2') mata: `X' = `X',J(rows(`X'),1,1)

preserve
clear
svmat `coefs', names(a)
gen `q1' = _n
tempfile temp1
save "`temp1'"
restore

preserve
keep `q1' `sorting'
merge m:1 `q1' using "`temp1'", nogenerate
sort `sorting'
mata: `b'  = st_data(., "a*")
restore

mata: `Y' = rowsum(`X':*`b',1)
mata: `output' = J(rows(`X'),1,.)

mata: st_view(`output', ., "`newvar1'")
mata: `output'[.,.] = `Y'

}
end