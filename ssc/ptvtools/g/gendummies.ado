/*
REQUIRES vallist
*/

capture program drop gendummies
program define gendummies
	version 9.0
	syntax varname, [PREfix(name)] [INCludemissing]
	
	local varname = "`varlist'"

	confirm numeric variable `varname'
	quietly levelsof `varname', local(values)
		
	local thePrefix = "`varname'"
	if ("`prefix'"!="") {
		local thePrefix = "`prefix'"
	}


	foreach v in `values' {
		//display `v'
		capture drop `thePrefix'`v'
		gen `thePrefix'`v' = (`varname'==`v')
		
		local labellist : value label `varname'
		local label : label (`varname') `v'
		
		label variable `thePrefix'`v' "`varname'==`v' `label'"
		
		
		if ("`includemissing'"=="includemissing") {
			foreach var of varlist `thePrefix'* {
				if ("`var'"!="`varname'") {
					replace `thePrefix'`v' = 0 if `varname'>=.
				}
			}
		}
		else {
			replace `thePrefix'`v'=. if `varname'>=.
		}
	}
end
