*! version 1.0.1 14mai2012 Johannes N. Blumenberg

program def valtovar
	version 11 
	syntax varlist, [DISplay] [NOreport] [Drop]

	local variables `varlist'
	quietly ds `variables', has(vallabel)

* Locals for report
local i=0
local j=0
local total=0

* Display ValToVar Matching
if "`display'"=="display" {
dis as text "{hline 35}{c +}"	
dis as text " ValToVar Matching"
dis as text "{hline 35}{c +}"
dis as text ""
}

* Real procedure to change variable labs
foreach var of varlist `r(varlist)' {
	local valnames `: val l `var'' // Fetch 'old' value label name
	if "`valnames'" != "`var'" { // Check if names are inconsistent
	label copy `valnames' `var', replace // Copy old value label to new value label with the same name as the variable
	la val `var' `var'
	local i=`i'+1 // For the report: Matched +1
	local total=`total'+1 // For the report: Total +1
	if "`display'"=="display" { // Display what was changed
	dis "`valnames' => `var'"
	}
	}
	else if "`valnames'" == "`var'" { // If the names are already consistent, no action is needed.
	local j=`j'+1
	local total=`total'+1
	if "`display'"=="display" {
	dis "`valnames' => Not changed." // For the report: Disregarded +1
	}
	}
}
* Drop unused labels
if "`drop'"=="drop" {
quietly {
labelbook, problems
la drop `r(notused)'
}
}
* Just the report
if "`noreport'"!="noreport" {
dis as text ""
dis as text "{hline 35}{c +}"
dis as text " ValToVar Report"
dis as text "{hline 35}{c +}"
dis as text ""
dis as text " Value labels matched: `i'/`total'"
dis as text " Value labels disregarded: `j'/`total'"
}
end
exit
