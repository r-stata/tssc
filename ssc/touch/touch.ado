/*============================================================================*/
/*                                  TOUCH                                     */
/*                               Version 1.1                                  */
/*----------------------------------------------------------------------------*/
/* This ado file performs a function similar to the UNIX "touch" command, in  */
/* that it will create a new empty file of the specified type suitable for    */
/* later using append in a loop.                                              */
/*----------------------------------------------------------------------------*/
/*          Version 1.1 Changes:                                              */
/* This program is a modification of touch.ado, by Ari Friedman               */
/* (abfriedman@gmail.com), which improves the program so that the user need   */
/* not cd to the desired directory before running the file.                   */
/*                                                                            */
/* Version 1.1 Author: Ben Lockwood <bbl2108@columbia.edu>     September 2009 */
/* Version 1.0 Author: Ari Friedman <abfriedman@gmail.com>       January 2008 */
/*============================================================================*/

program define touch
syntax [anything], [type(string)] [replace] [var(string)]
* `type' should be "txt" or "dta".  Defaults to "dta".
* If replace is specified, `replace' will contain "replace".
set more off
version 9

* Remove quotes from filename, if present
local file = `"`=subinstr(`"`anything'"', `"""', "", .)'"'

if "`file'" == "" {
	error 100
}

/* Save current dataset, then clear */
tempfile originaldata
qui save `originaldata', replace emptyok
drop _all // using clear is bad...just drop the dataset, not matrices, etc.

// Create some variables and then delete them to fix a bug (when outsheeting an empty CSV, Stata will use the last variables that existed, so we will make sure the last that existed is something innocuous)
gen x=1
drop x

/* Set defaults if not specified */
local txttypes `""txt", "csv", "tsv", "tab""'
if "`type'" == "" {
	/* Try to set based on final three characters */
	* remove quotes from filename, if present
    local type = substr("`file'",-3,.)
	// If file extension is a txttype, preceded by a period, set type to "txt"
	if inlist("`type'", `txttypes') & substr("`file'",-4,1) == "." {
		local type "txt"
	}
	// Otherwise, default to dta
	else {
		local type "dta"
	}
}

/* Generate a variable for use in merges if specified */
if "`var'" != "" {
	foreach v of local var {
		gen `v' = .
	}
	sort `var' // to avoid "not sorted" error when user attempts merge
}


/*============================================================================*/
/*                                Save                                        */
/*============================================================================*/
if "`type'" == "dta" {
	save "`file'", emptyok `replace'
}

if inlist("`type'", `txttypes') {
	outsheet using "`file'", `replace'
}

/* Restore original dataset */
qui use `originaldata', clear

end


