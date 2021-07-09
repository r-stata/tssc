// This program renames and labels variables using an external data sets.
capture program drop renamefrom

program define renamefrom, nclass
	syntax using/, filetype(string) raw(string) clean(string) ///
		[delimiters(string)] [sheet(string)]	///
		[if(string)]			///
		[label(string)]  		///
		[keepx] [dropx]  		///
		[keeplabel] [namelabel] ///
		[CASEignore] ///

	version 8.0

	// declare error codes
	local syntaxError 198
	local otherError  102
		
	// display process comment
	display ""
	display "renaming variables from workbook `using'"
	display ""
	
	// preserve the existing data
	preserve
	
	**************************************************************************************
	
	*** DEFINE MAPPING FROM RAW TO CLEAN VARIABLE NAMES ***
		
	// sheet can be specified only if using excel
	// delimiters can be specified only if using delimited file
	if ("`sheet'" != "") & ("`filetype'" != "excel") {
		display as error "Cannot specify sheet unless using excel filetype"
		exit `syntaxError'
	} 
	if ("`delimiters'" != "") & ("`filetype'" != "delimited") {
		display as error "Cannot specify delimiters unless using delimited filetype"
		exit `syntaxError'
	}
	
	// get variable names
	if "`filetype'" == "excel" {
		import excel `"`using'"', sheet(`sheet') firstrow clear
	}
	else if "`filetype'" == "delimited" {
		insheet using `"`using'"', delimiter("`delimiters'") names case clear
	}
	else if "`filetype'" == "stata" {
		use `"`using'"', clear
	}
	else {
		display as error "`filetype' is not a valid filetype"
		exit `syntaxError'
	}
	
	quietly keep if !missing(`raw') & !missing(`clean')
	
	// restrict based on "if" option
	if `"`if'"' != "" {  //"
		keep if `if'
	}
	
	// if caseignore option, rename all "old" vars to lowercase
	// keep a copy of "old" variables with original capitalization if needed later for variable labels
	tempvar raw_preserved
	gen `raw_preserved' = `raw'
	if "`caseignore'" == "caseignore" {
		replace `raw' = lower(`raw')
	}
	
	// verify that old and new variable names are unique
	foreach name in raw clean {
		tempvar N
		bysort ``name'': gen `N' = _N
		cap assert (`N' == 1)
		if _rc {
			display as error `"The function call was "renamefrom `0'" "'  //"
			display as error "The `name' column contains duplicate variable names.  Please specify a 1:1 mapping from old names to new names."
			list ``name'' if (`N' > 1)
			exit _rc
		}
	}
	
	// store the variable names and labels as locals
	local n_vars = _N
	forvalues i = 1/`n_vars' {
		local new_`i' = `clean'[`i']
		local old_`i' = `raw'[`i']
		local old_preserved_`i' = `raw_preserved'[`i']
		
		if "`label'" != "" {
			local label_`i' = `label'[`i']
		}
		
	}
	
	**************************************************************************************
	
	*** RENAME VARIABLES ***
	
	// restore the master data
	restore
	
	//if caseignore option on, convert var to lower
	if "`caseignore'" == "caseignore" {
		
		// keep whole variable list to later keep capitalization of vars that were not renamed
		qui ds
		local old_vars `r(varlist)'
		
		foreach var of varlist _all {	
			local lower = lower("`var'")
			if "`var'" != "`lower'" {
				qui rename `var' `lower'
			}
		}
	}
	
	// assert that all old variables in excel column are actually in dataset.
	forvalues i = 1/`n_vars' {
		capture confirm variable `old_`i''
		if _rc {
			local missing_list `missing_list' `old_`i''
		}
	}
		// print missing variables
		if "`missing_list'" != "" & "`dropx'" == ""  {
			display as error `"The function call was "renamefrom `0'" "'  //"
			display as error "The raw column contains the following variables not found in the master dataset."
			display ""
			display "`missing_list'"
			exit `otherError'
		}	

	// order variables so that the ones you want to keep are first
	forvalues i = `n_vars'(-1)1 {
		order `old_`i''
	}
	
	// rename vars, drop if indicated, and collect leftover vars otherwise
	local i = 1
	local n_extra = 0
	foreach v of varlist _all {
		if `i' <= `n_vars' {
			tempvar `new_`i''
			if "`v'" != "``new_`i'''" {
				qui rename `v' ``new_`i'''
			}
		}
		else {
			if "`dropx'" == "dropx" {
				drop `v'
			}
			else {
				local extras `extras' `v'
				local ++n_extra
			}
		}
		local ++i	
	} 
	
	// this loop and the one above it have to happen separately because
	// tempvars and variable names have different caps on character length
	local i = 1
	foreach v of varlist _all {
		if `i' <= `n_vars' {
			if "``new_`i'''" != "`new_`i''" {
				qui rename  ``new_`i''' `new_`i''
			}
			local ++i
		}
	}

	// revert to non-lowercased names for variables that were not renamed
	if (`n_extra' > 0) & ("`caseignore'" == "caseignore") {
		foreach extra_var of local extras {
			foreach old_var of local old_vars {	

				if lower("`old_var'") == "`extra_var'" {
					local extras_cap `extras_cap' `old_var'
					if "`old_var'" != "`extra_var'" {
						rename `extra_var' `old_var'					
					}
					break
				}
				
			} 
		}
	}
	
	// label variables 
	forvalues i = 1/`n_vars' {
	
		if "`label_`i''" != "" {						// use Excel value if provided
			label var `new_`i'' "`label_`i''"
		}
		else if ("`keeplabel'" == "") {					// If no Excel value, and keep label is not specified,
			label var `new_`i'' ""						// overwrite existing label.
		}
		
		local varlab : variable label `new_`i''			// If label is left missing,
		if ("`varlab'" == "") & ("`namelabel'" != "") {	// and name label option is specified,
			label var `new_`i'' "`old_preserved_`i''"				// apply old name as new label.
		}
	}
	
	// list variables you haven't renamed yet
	if ("`keepx'" != "keepx") & (`n_extra' > 0) { 
		display as error "The following variables were not assigned a clean name.  Please provide a name for each in the supporting spreadsheet, or specify option 'keepx'"
		describe `extras_cap'
		exit `otherError'
	}

end	

**************************************************************************************
**************************************************************************************
**************************************************************************************
