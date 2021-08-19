*! version 1.1.0  20nov2020
program def summarizeby
	version 8.0
	/*
		This program allows to perform statsby with summarize on all variables.
		Author: Ilya Bolotov, MBA Ph.D.
		Date: 15 November 2020
	*/
	syntax																	///
	[anything(name=exp_list equalok)] [fw iw pw aw] [if] [in]				///
	[, CLEAR SAving(string) *]
	tempfile tmpf

	// cummulate summarize results for each variable into `tmpf'
	foreach var of varlist * {
		/* preserve data */
		preserve
		/* perform statsby on summarize with `options' */
		qui statsby `exp_list' `if' `in' `weight', clear `options': sum `var'
		/* add varname of `var' */
		gen variable = "`var'"
		/* append saved data from `tmpf' (if it exists) */
		cap append using `tmpf'
		/* save the result in `tmpf' */
		qui save `tmpf', replace
		/* restore data */
		restore
	}

	// work with `tmpf'
	if "`clear'" != "" & "`saving'" != "" {
		di as err "clear and saving() are mutually exclusive options"
		exit 198
	}
	if "`clear'`saving'" != "" {
		/* preserve data (if `saving' is specified) */
		if "`saving'" != "" {
			preserve
		}
		/* use data from `tmpf' */
		use `tmpf', clear
		/* reverse sort observations */
		tempvar id
		gen `id' = _n
		gsort -`id'
		drop `id'
		order variable
		label var variable "variable name"
		/* save result (if `saving' is specified) */
		if "`saving'" != "" {
			save "`saving'", replace
		}
	}
	else {
		di as err "no; dataset in memory has changed since last saved"
		exit 4
	}
end
