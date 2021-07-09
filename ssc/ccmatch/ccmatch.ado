* CCMATCH
* Daniel E. Cook 2015
program define ccmatch, sortpreserve
    version 11.0
    syntax varlist [if] [in] [, cc(name) id(varname)]
	tempvar match_vars match_vars_cc match_n match_c randorder match_count pairs 

// Group by match variables.
quietly egen `match_vars' = concat(`varlist'), punct("_")

//  Generate a random variable for sorting purposes.
generate `randorder' = runiform()

// Sorts data randomly.
sort `match_vars' `cc' `randorder'

quietly egen `match_vars_cc' = concat(`varlist' `cc') if `cc' != .
quietly by `match_vars_cc', sort: gen `match_n' = _n if `cc' != .
quietly egen `match_c' = group(`match_vars' `match_n') if `cc' != .
quietly by `match_c', sort: gen `pairs' = _N if `cc' != . // Count off pairs

// Drop the match variable if it exists.
qui capture confirm variable match, exact 
	if `=_rc' == 0 {
		drop match
	}
quietly egen match = group(`match_vars' `match_c') if `pairs' == 2
sort `match_vars' `match_n'

// Gen Match ID if id is specified.
if ("`id'" != "" ) {
qui capture confirm variable match_id, exact
	if `=_rc' == 0 {
		drop match_id
	}
	qui gen match_id = `id'[_n-1] if match[_n] == match[_n-1] & match != . 
	qui replace match_id = `id'[_n+1] if match[_n] == match[_n+1] & match != .

}

qui summarize match
local total_matches = `r(max)'
di "Total Matches: `total_matches'"

end
