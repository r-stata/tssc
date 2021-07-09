*! version 1.1  15 Mar 2017
*! Author: mark.chatfield@menzies.edu.au

* version 1.0  24 Feb 2017

program define labeldatasyntax
version 14.0
syntax [using/], SAVING(string) [REPLACE]
preserve
qui {

cap file close newdofile
noi file open newdofile using `"`saving'"', write `replace'
noi di as txt `"`saving' saved"'

capture generate value = .
capture generate label = ""
capture generate codeset = variable 
capture generate codeset = ""
capture replace codeset = codeset[_n-1] if codeset == "" // Fill in empty rows of codeset
replace codeset = "" if value==. | label == ""


**Define value labels
local N = _N
if "`N'" != "0" {
	levelsof codeset, local(set)
	foreach s of local set { 
		forv i = 1/`N' {
			local c : display codeset[`i']
			local d : display value[`i']
			local e : display label[`i']
			if "`c'" == "`s'" & "`d'" != "." & "`e'" != "" local coding `"`coding' `d' "`e'""'
		}
		if `"`coding'"' !="" file write newdofile `"label define `s'`coding'"' _newline // `"`coding'"' compound quotes change made 15/3/17
		local coding ""
	}
	file write newdofile _newline
}



* Optionally open second dataset (i.e. Format II, which involves two datasets)
if `"`using'"' != "" noi use `"`using'"', clear


local N = _N
if "`N'" != "0" {

	**Apply value labels 
	capture generate variable = ""
	capture generate codeset = ""
	forv i = 1/`N' {
		local a : display variable[`i']
		local c : display codeset[`i']
		if "`a'" != "" & "`c'" != "" & "`a'" != "`aprevious'" file write newdofile "label values `a' `c'" _newline
		local aprevious "`a'" // for the situation where variable is repeated down the rows
	}
	file write newdofile _newline


	**Label variables with description
	capture generate description = ""
	if _rc !=0 {
		forv i = 1/`N' {
			local a : display variable[`i']
			local b : display description[`i']
			if "`a'" != "" & "`b'" != ""  file write newdofile `"label variable `a' "`b'" "' _newline
		}
	}
}

file close newdofile
}
restore
end
