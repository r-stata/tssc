*! Version 1.0, October 2015, by Graham K. Brown

program bhatt, rclass
	version 10

syntax varlist [if] [in] , group(varname) [ bin(integer 10)]
preserve

*** First we jettison unusable obs and unused variables and check for out-of-range observations ***

if !missing("`in'") {
qui keep `in'
}
if !missing("`if'") {
qui keep `if'
}

qui regress `varlist' `group'
qui keep if e(sample)

tempvar bygroup
qui egen `bygroup'=group(`group')
qui sum `bygroup'

if r(max) !=2 {
	display in red "Error: Group variable `group' must contain exactly two values"
	exit 198
}

*** Generate bins ***

qui sum `varlist'
local rmin=r(min)
local rmax=r(max)
local binsize=(`rmax'-`rmin')/`bin'

tempvar binno

gen `binno' = 1

qui forvalues i = 2/`bin' {
	replace `binno' = `i' if `varlist'>(`rmin'+((`i'-1)*`binsize'))
}

*** Generate partition summaries in local macros ***


forvalues i=1/2 {
	qui count if `bygroup'==`i'
	local totpop=r(N)
	
	forvalues j=1/`bin' {
		qui count if `bygroup'==`i' & `binno'==`j'
		local g`i'b`j'=r(N)/`totpop'
	}
}

*** Generate BC and BD ***

local bc=0

forvalues i=1/`bin' {
	local bc=`bc'+sqrt(`g1b`i''*`g2b`i'')
}

local bd=-ln(`bc')

display as result "Bhattacharyya Coefficient = `bc'"
display as result "Bhattacharyya Distance = `bd'"

return scalar bc=`bc'
return scalar bd=`bd'

restore

end
