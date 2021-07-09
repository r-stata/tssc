*! version 1.3 Oktober 11, 2011 @ 10:15:59 UK
*! List information on (person specific) sequences

* 1.1 Does not use firstpos and allpos variable -> fixed
* 1.2 Clean Charlists, Options -not()- and exclude0 implemented
* 1.3 A -replace- was noisily, now quietly; option listwise added

program sqstattab1
version 9
	syntax [varlist(default=none)] [if] [in] [, NOt(varlist) exclude0  * ]
	
	// Sq-Data
	if "`_dta[SQis]'" == "" {
		di as error "data not declared as SQ-data; use -sqset-"
		exit 9
	}
	
	preserve
	
	// if/in
	if "`if'" != "" {
	tokenize "`if'", parse(" =+-*/^~!|&<>(),.")
		while "`1'" != "" {
			capture confirm variable `1'
			if !_rc {
				local iflist  "`iflist' `1'"
			}
			macro shift
		}
	}
	if "`iflist'" != "" CheckConstant `iflist', stop
	marksample touse, novarlist
	
	// Check if hand made varlist are constants above time
	if "`varlist'" != "" CheckConstant `varlist'
	local varlist `r(checked)'
	
	// Use egen-erated sequence-information
	if "`varlist'" == "" {
		CleanChars
		local varlist `r(sqegennames)' 
		if "`not'" != "" local varlist: list varlist - not
		format `varlist' %4.0f
	}
	
	// Fast wide
	keep `_dta[SQiis]' `_dta[SQis]' `varlist' `touse'
	quietly by `_dta[SQiis]': keep if _n==1 & `touse'

	// Exclude0
	if "`exclude0'" != "" {
		foreach var of local varlist {
			if "`listwise'" != "" quietly replace `touse' = 0 if `var'==0
			else quietly replace `var' = .x if `var'==0
		}
	}

	// Output
	foreach var of local varlist {
		di as text _n "-> tabulation of " as result "`var'"
		tab `var' if `touse', `options'
	}
end
	
program CheckConstant, rclass
	syntax varlist(default=none) [, stop]
	sort `_dta[SQiis]'
	foreach var of local varlist {
		capture by `_dta[SQiis]': assert `var' == `var'[_n-1] if _n != 1
		if _rc & "`stop'" == "" {
			di as res "`var'" as text " is not constant over time; not used"
			local varlist: subinstr local varlist "`var'" "", word
		}
		if _rc & "`stop'" != "" {
			di as error "`var' is not constant over time"
			exit 9
		}
		if "`stop'" == "" {
			return local checked "`varlist'"
		}
	}
end

// Deleate dropped SQ-generated variables from charlists
program define CleanChars, rclass
	foreach char in                                         /// 
	  SQlength SQelemcount SQepicount SQgapcount SQgaplength  ///
	  SQfirstpos SQallpos {
		local names: char _dta[`char']
		foreach var of local names {
			capture confirm numeric variable `var', exact
			if _rc local droplist `droplist' `var' 
		}
		char _dta[`char'] `:list names - droplist'
		macro drop _droplist
	}
	local SQlength: char _dta[SQlength]
	local SQelemcount: char _dta[SQelemcount]
	local SQepicount: char _dta[SQepicount]
	local SQgapcount: char _dta[SQgapcount]
	local SQgaplength: char _dta[SQgaplength]
	local SQfirstpos: char _dta[SQfirstpos]
	local SQallpos: char _dta[SQallpos]
	
	local sqegennames `SQlength' `SQelemcount' `SQepicount'         ///
	  `SQgapcount' `SQgaplength' `SQfirstpos' `SQallpos'
	return local sqegennames `sqegennames'
end
exit
