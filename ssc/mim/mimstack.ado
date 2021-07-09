*! mimstack.ado JCG 12feb2006
* Note: read MIM Tools ado files with tab set equal to 6 spaces
*--------------------------------------------------------------------------------------------------------
program define mimstack
	version 9
	set more off

	syntax, m(integer) SOrtorder(string) [ istub(string) ifiles(string) NOMJ0 clear ]

	if ( `"`clear'"' != "" ) local clear ", clear"
	if ( `"`nomj0'"' == "" ) local first = 0
	else local first = 1
	local numfiles = `m' + 1 - `first'
	if ( `"`istub'"' != "" ) {
		if ( `"`ifiles'"' != "" ) {
			display as error "istub and ifiles options not allowed together"
			exit 198
		}
		forvalues i = `first'/`m' {
			local ifiles `"`ifiles' `istub'`i' "'
		}
	}
	else if ( `"`ifiles'"' != "" ) {
		local num : word count `ifiles'
		if ( `num' != `numfiles' ) {
			display as error "incorrect number of filenames in ifiles option; " _cont
			display as error "`num' names found, but `numfiles' filenames are required"
			exit 198
		}
	}
	else {
		display as error "one of istub and ifiles options is required"
		exit 198
	}

	// check variable(s) in original and imputed datasets
	preserve
	local tempfiles `"`ifiles'"'
	forvalues i = `first'/`m' {
		gettoken nextfile tempfiles : tempfiles
		quietly use `nextfile' `clear'
		capture confirm variable `sortorder'
		if ( c(rc) ) {
			local wc : word count `sortorder'
			if ( `wc' == 1 ) local vars "the variable"
			if ( `wc' > 1 ) local vars "at least one of the variables"
			display as error "`vars' `sortorder' not found in imputed dataset `i'"
			exit 498
		}
		capture isid `sortorder'
		if ( c(rc) ) {
			local wc : word count `sortorder'
			if ( `wc' == 1 ) local vars "the variable `sortorder' does"
			if ( `wc' > 1 ) local vars "the variables `sortorder' do"
			display as error "`vars' not uniqely identify " _cont
			display as error "the observations in imputed dataset `i'"
			exit 498
		}
		if ( `i' == `first' ) {
			local vars
			foreach var of varlist _all {
				local vars `"`vars' `var'"'
			}
		}
		else {
			foreach var in `vars' {
				capture confirm variable `var'
				local rc = _rc
				if ( `rc' != 0 ) {
					display as error "variable `var' not found in imputed dataset number `i'"
					exit `rc' 
				}
			}
		}
	}

	// stack the datasets
	forvalues i = `first'/`m' {
		gettoken nextfile ifiles : ifiles
		if ( `i' == `first' ) {
			use `nextfile' `clear'
			capture drop _mj
			quietly generate byte _mj = `first'
		}
		else { 
			quietly append using `nextfile'
			quietly replace _mj = `i' if _mj >= .
		}
	}

	// sort and compress stacked dataset and generate _mi var
	sort _mj `sortorder'
	tempvar t
	quietly generate byte `t' = .
	quietly by _mj : replace `t' = _n
	capture drop _mi
	rename `t' _mi
	order _mj _mi
	sort _mj _mi
	label variable _mj "imputation identifier"
	label variable _mi "observation identifier"

	restore, not
end
