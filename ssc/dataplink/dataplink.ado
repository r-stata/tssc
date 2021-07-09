/* 
SNP FETCH 
---------------------
	D. ELWOOD COOK
	Danielecook@gmail.com
	Elwoodcook.com
	Version 1.2
	
	// 1.0 -- Initial Release
	
	Feb 7, 2011
*/
program define dataplink
    version 11.0
    syntax using/[, sexlabel]

// Input the ped file.
insheet using "`using'.ped" 

// close `VARNAMES' if previously opened
tempname VARNAMES

file open `VARNAMES' using "`using'.map", read

// rename first 6 variables.
rename v1 Family_ID
rename v2 Individual_ID
rename v3 Paternal_ID
rename v4 Maternal_ID
rename v5 Sex
rename v6 Phenotype

capture confirm existence `sexlabel'
	if !_rc {
	label define sex 1 "Male" 2 "Female" 3 "unknown"
	label values Sex sex
	}

// Get variable number
quietly describe
local numvar = `r(k)' - 6
di "`numvar' SNPs"

file read `VARNAMES' line
local linenum = 0
while `numvar' > 0 {
	if `linenum' == 0 {
	file seek `VARNAMES' tof
	}
	local linenum = `linenum' + 1
	file read `VARNAMES' line 
	// Label RS numbers
	local found = regexm("`line'","(rs[0-9]*)")
	local variable_name = regexs(1)
	// Label CNVI Numbers
		if "`variable_name'" == "" {
		// Label with 'cnvi' if necessary.
		local found = regexm("`line'","(cnvi[0-9]*)")
		di "`line'"
		local variable_name = regexs(1)
			if "`variable_name'" == "" {
			// Label with 'cnvi' if necessary.
			local variable_name = "invalid_`linenum'"
			}
		}

	local varnum = `linenum' + 6 
	capture rename v`varnum' `variable_name'
	if _rc {
	rename v`varnum' `variable_name'
	}
	local numvar = `numvar' - 1
	}
	



end
