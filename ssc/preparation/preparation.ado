*! version 1.0.0 14december2012 Johannes N. Blumenberg

program def preparation
	version 11 
	syntax varlist, [NUMlabels] [STRings] [LIMit(numlist)] [NOMiss]
	
	local variables `varlist'

* Setting up the missing option	
if "`nomiss'"=="nomiss" {
	local miss ""
} 
else {
	local miss ", m"
}

* Adding numlabels to VARIABLES. More of a "quick and dirty" rather than a good solution.
* To obtain the container names all variables except the varlist become dumbed, then a dir
* delivers the necessary container names.
if "`numlabels'"=="numlabels" {
	quietly {
		preserve 
		keep `variables'
		labelbook, problems
		la drop `r(notused)'
		label dir
		restore
		preserve
		numlabel `r(names)', add force
	}
}

* If the string option is not set, string variables become automatically stripped of the varlist here.	
if "`strings'"=="strings" {
	quietly ds `variables'
}
if "`strings'"!="strings" {
	quietly ds `variables', not(type string)
}

* The "real" function of the script
foreach var of varlist `r(varlist)' { 
	if "`limit'"!="" { // here starts the limit option
		quietly tab1 `var' `miss' // quietly tab to get the number of rows of each variable
		local wert = "`r(r)'"
			if `wert'<=`limit' { 
			set more on
			more
			set more off
			di _newline(`=c(pagesize)') 
			tab1 `var' `miss'
		}
			if `r(r)'>`limit' { 
		}
	} 
	else { // if no limit is set, just display the tabs
		set more on
		more
		set more off
		di _newline(`=c(pagesize)') 
		tab1 `var' `miss'
	}
}

if "`numlabels'"=="numlabels" { // reload the old dataset after settings the numlabels. Only used when the option is set.
restore
}

end
exit