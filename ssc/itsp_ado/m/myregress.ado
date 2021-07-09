
*! myregress v1.0.0  CFBaum 11aug2008
program myregress, rclass
version 10.1
syntax varlist(ts) [if] [in], LAGVar(string) NLAGs(integer)
regress `varlist' `if' `in'
local nl1 = `nlags' - 1
forvalues i = 1/`nl1' {
	local lv "`lv' L`i'.`lagvar' + "
}
local lv "`lv'  L`nlags'.`lagvar'"
lincom `lv'
return scalar sum = `r(estimate)'
return scalar se = `r(se)'
end
