*! 1.1 Alvaro Carril 09apr2018
program define multimport, rclass
version 11
syntax anything(name=importmethod id="import_method") [using], ///
	[ ///
		EXTensions(string) ///
		DIRectory(string) ///
		IMPORToptions(string asis) ///
		APPENDoptions(string asis) ///
		EXClude(string asis) ///
		INClude(string asis) ///
		force clear ///
	]

*-------------------------------------------------------------------------------
* Check valid program input
*-------------------------------------------------------------------------------

// Check valid importmethod
if "`importmethod'" != "excel" & "`importmethod'" != "delimited" {
	di as error `"multimport: unknown subcommand "`importmethod'""'
	exit 198
}

// Assert that either directory() or include() are specified
/* if "`directory'" == "" & `"`include'"' == "" {
	di as error "you must either specify a directory() or specific files to include()"
	exit 198
} */

// Check that current data is saved or that 'clear' is specified
local clearpos = strpos(`"`importoptions'"', "clear")
if `c(changed)' == 1 & ("`clear'" != "clear" & `clearpos' == 0) {
	di as error "no; data in memory would be lost"
	exit 4
}

*-------------------------------------------------------------------------------
* Parse program options
*-------------------------------------------------------------------------------

// Add final forward slash to directory if not empty and it doesn't have it
local lastdirchar = substr("`directory'", -1, .)
if "`lastdirchar'" != "/" & "`directory'" != "" local directory `directory'/

// Add default extensions according to import_method, if they weren't specified
if "`extensions'" == "" {
	if "`importmethod'" == 	   "excel" 	local extensions xls xlsx
	if "`importmethod'" == "delimited" 	local extensions csv
}

// Parse files to import, collecting all files with `extensions' of `directory'
foreach ext of local extensions {
	local add : dir "`directory'" files "*.`ext'", respectcase
	local Nadd : list sizeof add
	if `Nadd' > 0 local files `files' `"`add'"'
}

// Sort elements in list
local files : list sort files

// Of all files in directory(), use only those in include()
if "`include'" != "" local files : list include & files

// Exclude any specific files
local files : list files - exclude

// Check that final files list is not empty
local Nfiles : list sizeof files
if `Nfiles' == 0 {
	di as error "no files to import"
	exit 198
}

// List files to import
di as text "Files to import:"
foreach f of local files {
	di "`f'"
}

// Confirm import if force is not specified
if "`force'" != "force" {
	di as result "Proceed? (yes/no)" _request(_yesno) // it doesn't produce a local without underscore
	if "`yesno'" != "yes" exit 1
}

// Add 'clear' option to `importoptions' if `clear' is specified
if "`clear'" == "clear" & `clearpos' == 0  {
	local importoptions `importoptions' clear
}


*-------------------------------------------------------------------------------
* Import and append
*-------------------------------------------------------------------------------

// Create final dataset
clear
tempfile alldata
qui save `alldata', emptyok

// Create dataset with all data sources
foreach f of local files {
	di as text "importing '`f''..."
	// Import
	import `importmethod' "`directory'`f'" , `importoptions'
	// Generate _filename variable identifying data source
	local i = `i' + 1
	local valuelabs `valuelabs' `i' `"`f'"'
	gen _filename = `i'
	// Append with accumulated data
	append using `alldata' , `appendoptions'
	qui save `alldata', replace
}
// Define and apply value label to _filename
label define _filename `valuelabs'
label values _filename _filename

return local files `files'
if "`directory'" == "" local directory .
return local directory `directory'

end
