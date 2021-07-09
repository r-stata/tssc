** Adrien B 16/04/2015
cap program drop varmi
program define varmi
version 13.1
set more off
syntax varlist   ,GENerate(name) [LABel(namelist)]
dis "`varlist'"
	foreach i of varlist `varlist' {
		quiet {
			capture confirm string variable `i'
			 if !_rc {
				replace `i'="" if `i'=="."
				replace `i'="" if `i'==" "
				replace `i'="" if `i'=="`=char(160)'"
			}
		}
	}
quiet {
		local c=0
		foreach i of varlist `varlist' {
			local c=`c'+1
		}
		ds `varlist'
		egen `generate'= rowmiss(`r(varlist)')
		replace `generate'=(`generate'==`c')

		if "`label'"!="" {
		label var `generate' "`label'"
		}
}
end
e
