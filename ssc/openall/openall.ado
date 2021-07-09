/* openall.ado */

*! Version 1.0.0

/* This file clears the currently active dataset, then appends together all the files listed at the command line */
/* Ari Friedman ari_friedman@harvard.edu 11/05/06 */

capture program drop openall
program define openall
syntax [anything], [directory(string)] [storefilename(string)] [insheet] [verbose]
version 9

clear

local files "`anything'"
if "`verbose'" == ""	{
	local qui "qui"
}

if "`insheet'"!="" {
	local extension "csv"
	`qui' di "Insheet specified. Setting extension to CSV"
}
else {
	local extension "dta"
}

// Set input vars to defaults if not specified
if "`directory'" == "" {
	`qui' di in yellow "Directory not specified"
	local directory "."
}
if "`files'" == "" {
`qui' di in yellow "Files not specified"
	local files "*"
}
// Fix input vars if not in proper format
if substr("`directory'",-1,1) != "/" & substr("`directory'",-1,1) != `"\"' {
	di in yellow "Directory variable does not contain trailing slash.  Adding."
	local directory = `"`directory'"' + "/"
}

/* Loop through all the files specified in `files' */
local filecount = wordcount(`"`files'"')
forvalues filewordnum = 1/`filecount' {
	/* Prepare all files for merging */
	local file = word(`"`files'"',`filewordnum')
	`qui' di `"~f: `file'"'
	`qui' di `"~d: `directory'"'
	`qui' di `"~e: `extension'"'
	local newfilelist: dir "`directory'" files `"`file'.`extension'"'
	`qui' di `"nfl: `newfilelist'"'
	local filelist `"`filelist' `newfilelist'"'
}

if "`verbose'"=="verbose"		di in red `"`directory'"'
if "`verbose'"=="verbose"		di in red `"~~ `filelist'"'

if "`verbose'"=="verbose"		di in yellow "MERGING"

/* Now merge the file pairs together */
// Create merge file so append doesn't fail later
tempfile merged
clear
gen openallid=.
`qui' save `merged'
// Loop through the file pairs and perform the merge
foreach fl of local filelist {
  //Open the file (CSV or DTA)
  if "`insheet'" == "insheet" {
    `qui' di `"`directory'`fl'"'
    `qui' insheet using `"`directory'`fl'"', clear
  }
  else {
  	`qui' use `"`directory'`fl'"',clear
  }
  
  //Store the filename as a variable if specified
  if "`storefilename'" != "" {
  	`qui' gen `storefilename' = "`fl'"
	}
  
  // Now append and save
	`qui' append using `merged'
	`qui' save `merged', replace
}

`qui' use `merged', clear

`qui' drop openallid

end
