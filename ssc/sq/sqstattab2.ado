*! version 1.3 Oktober 11, 2011 @ 10:17:46 UK
*! List information on (person specific) sequences

* 1.1 Does not use firstpos and allpos variable -> fixed
* 1.2 Clean Charlist, Options -not()- and exclude0 implemented
* 1.3 A -replace- was noisily, now quietly; option listwise added

program sqstattab2
version 9
	syntax varlist(min=1 max=2) [if] [in] [,  NOt(varlist) exclude0 * ]

	// Sq-Data
	if "`_dta[SQis]'" == "" {
		di as error "data not declared as SQ-data; use -sqset-"
		exit 9
	}

	// Catch varnames of if
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
	preserve

	// Check if hand made varlist are constants above time
	if "`varlist'" != "" CheckConstant `varlist'
	local varlist `r(checked)' 

	// Use egen-erated sequence-information
	if `:word count `varlist'' == 1 {
		CleanChars
		local autolist `r(sqegennames)' 
		if "`not'" != "" local autolist: list autolist - not
		format `autolist' %4.0f
	}
		
	// Fast wide
	keep `_dta[SQiis]' `_dta[SQis]' `varlist' `autolist'  `touse'
	quietly by `_dta[SQiis]': keep if _n==1 & `touse'

	// Exclude0
	if "`exclude0'" != "" {
		foreach var of local autolist {
			if "`listwise'" != "" quietly replace `touse' = 0 if `var'==0
			else quietly replace `var' = .x if `var'==0
		}
	}

	// Output
	if `:word count `varlist'' == 1 {
		foreach var of local autolist {
			tabulate `var' `varlist', `options'
		}
	}
	else {
		tabulate `varlist', `options'
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
	}
	return local checked "`varlist'"
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
