//! version 1.0 31DEC2018  DIME Analytics bbdaniels@gmail.com

// makeid - Stata module to create a unique ID for every observation in the dataset.

cap prog drop makeid
prog def makeid

syntax anything , GENerate(string asis) PROJECT(string asis)

version 13.1

	// Check these variables are unique
	isid `anything' , sort

	// Setup
	tempvar temp
	tempvar temp_string

	tempfile next

	gen `generate' = substr("`project'",1,1)

	// Loop through levels
	tokenize `anything'
	qui while "`1'" != "" {
		levelsof `generate' , local(glevels)
		foreach glevel in `glevels' {

			// Uniquely idenfity each level -within- all higher levels
			preserve
				keep `generate' `1'
				duplicates drop
				bys `generate' : gen `temp' = _n
				save `next' , replace
			restore

			// Transfer to main dataset
			merge m:1 `generate' `1' using `next' , nogen update replace
			su `temp'
			local length = length("`r(max)'")
		}

		// Extend the new ID variable to this level
		tostring `temp' , gen(`temp_string') format(%0`length'.0f)
			replace `generate' = `generate' + `temp_string'
			drop `temp_string'

	mac shift
	}

	// Cleanup
	local label = subinstr("`anything'"," "," + ",.)
		label var `generate' "`project' ID: `label'"
		isid `generate', sort
		order `generate' , first

// End
end

// Have a lovely day!
