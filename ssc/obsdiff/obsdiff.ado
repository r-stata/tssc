*! obsdiff.ado
*! Eric A. Booth  <ebooth@tamu.edu>
*! Version 1.0.1  Modified: Apr 2010
*! Syntax:  obsdiff [varlist], Rows(numlist)
** Variables with differences stored in `r(diff_vars)'

program define obsdiff, rclass
syntax [varlist] [if] [using/] [, Rows(numlist) ALL REPlace]
version 9.2

local originalrows "`rows'"


**error checking for [all]**
if "`all'" != "" & "`rows'" != "" {
	di as err  "Cannot specify both {bf:rows()} and {bf:all}"
	exit 198
	}
if "`all'" == "" & "`rows'" == "" {
	di as err "Must specify at least one option:  {bf:rows()} or {bf:all}"
	exit 198
	}
	
**set up macros**
	**update:  create `rows' if `all' specified
				*noi di in yellow "`all'"
				*noi di in yellow "`rows'"
		if "`all'" != ""   {
			numlist "1/`=_N'"
			local rows `r(numlist)'
			**noi di in yellow  "`rows'"
			}
	**update:  remove last number in `rows'
		local length:word count `rows'
		*di "`length'"
		local subout:word `length' of `rows'
		*di "`subout'"
		local rows:subinstr local rows "`subout'" ""
		*di in r "`rows'"
		
	**update: add & to `if'
		if "`if'" != ""  {
			local if2 "& `if'"
			local if2:subinstr local if2 "if" ""
			}
		*di in red "`rows' new" 

*! update: add log file for `using' option
if "`using'" != "" {
	local using:subinstr local using ".log" ""  
	local using:subinstr local using ".txt" ""
	local using "`using'.txt"
	cap log close obsdifflog
	log using `"`using'"', `replace' name(obsdifflog) text
			}

** report header**
	if "`varlist'" != "" {
		di    _n
		di in green as smcl "{hline}"
		di as smcl in white "Reporting differences for variables {stata describe `varlist':`varlist'} on rows {bf:`if'}:" in yellow " `originalrows' "
		di in green as smcl "{hline}"
		di    _n

	}
	if "`varlist'" == "" {
		di    _n
		di in green as smcl "{hline}"
		di as smcl "Showing differences for {stata describe: All Variables} on rows {bf: `if'}:" in yellow " `originalrows' "
		di in green as smcl "{hline}"
		di    _n
	}


**list differences**
qui ds `varlist'
	foreach v in `r(varlist)' {
	foreach n in `rows' {
	local next `n++'
			*! update: cleanup if2 !*
			if "`if2'" != ""  {
			*****noi di in white "`if2'"
			local if`v'`n':subinstr local if2 `"=="' `" [`n'] == "' , all /* count(local cc)*/ 
			*****noi di "count--> `cc'"
			local if`v'`n':subinstr local if`v'`n'  `"!="' `" [`n'] != "'
			local if`v'`n':subinstr local if`v'`n'  `" ["' `"["'
			local if`v'`n':subinstr local if`v'`n'  `" ["' `"["'
			local if`v'`n':subinstr local if`v'`n'  `" ["' `"["'
			*****noi di in red "current `if`v'`n''"
			*****noi di in yellow "last `if`v'`next''"
			}
			
			
	if `v'[`next'] != `v'[`n'] & `n'<`=_N' & `next'<`n' `if`v'`n'' `if`v'`next'' { 
		 di as smcl "Differences in {stata describe `v', fulln : `v'} in rows `next' and `n'"
	 	 li `v' in `next'/`n'  , sep(1) div nocompress   //update: added opt. use of [if]
		*+
			loc dvv  `dvv' `v'
					}
		}
	}
cap log close obsdifflog
if "`using'" != "" di in white as smcl `"obsdiff log/report written to {browse `using':`using'} (click to open)"'
**save variable in macro**
		loc dvv:list uniq local(dvv)
		return local diff_vars `dvv'

end

** version 1.0.1 update: added [all], [using], and [if] options



/* EXAMPLES

sysuse auto, clear
obsdiff make for rep78 , r(8/12)
di "`r(diff_vars)'"

obsdiff for rep78, all
obsdiff rep78 if for==0, r(1/10)
obsdiff rep78 if for==1 using "obsdiff_log", all replace
*/

