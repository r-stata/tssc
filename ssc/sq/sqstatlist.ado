*! version 1.4 März 1, 2016 @ 09:03:18
*! List information on (person specific) sequences

* 1.0 -> SJ Version
* 1.1 -> tempfiles in compount double quotes
* 1.2 Does not use firstpos and allpos variable -> fixed
* 1.3 Clean Charlist, Option -not()- implemented
* 1.4 New option sort implemented

program define sqstatlist, rclass
version 9
	syntax [varlist(default=none)] [if] [in] [,  ///  
	  ranks(numlist) replace NOt(varlist) exclude0 sort(varname) * ]

	// Sq-Data
	if "`_dta[SQis]'" == "" {
		di as error "data not declared as SQ-data; use -sqset-"
		exit 9
	}

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

	// Don't replace
	if "`replace'" == "" {
		preserve
	}

	// Option ranks
	if "`ranks'" != "" {
		quietly { 
			tempfile original frequency
			save `"`original'"'
			tempvar n
			keep `_dta[SQiis]' `_dta[SQtis]' `_dta[SQis]' `touse'
			keep if `touse'
			reshape wide `_dta[SQis]', i(`_dta[SQiis]') j(`_dta[SQtis]')
			bysort `_dta[SQis]'*: gen `n' = _N
			char `n'[varname] "Freq."
			bysort `_dta[SQis]'*: keep if _n==1
			keep `_dta[SQiis]' `n'
			KeepRanks `n', ranks(`ranks') 
			sort `_dta[SQiis]'
			save `"`frequency'"'
			use `"`original'"', clear
			sort `_dta[SQiis]'
			merge `_dta[SQiis]' using `"`frequency'"'
			keep if _merge==3
			drop _merge
		}
	}

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
	
		
	// Output
	// ------
	
	keep `_dta[SQiis]' `_dta[SQis]' `varlist' `touse' `n' 
	quietly bysort `_dta[SQiis]': keep if _n==1

	if "`replace'" != "" & "`ranks'" != "" {
		replace `_dta[SQiis]' = `n'
		di as text "Note: `_dta[SQiis]' now contains nobs that share specified sequence"
	}

	if "`replace'" == "" {
		if "`sort'" == "" ///
		  local identifier = cond("`ranks'"=="","`_dta[SQiis]'","`n'")
		else local identifier `sort'
		sort `identifier'
		list `identifier' `varlist' if `touse', noobs subvarname `options' 
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


// Selects Ranks according to rank-Options
program KeepRanks
	syntax varname, ranks(string)
	tempvar rank tieshelp tiesrank select
	by `varlist', sort: gen int `rank' = _n==1
	gen int `tieshelp' = _N+1 - _n
	replace `rank' = sum(`rank')
	replace `rank' = `rank'[_N] +1  - `rank'
	sort `tieshelp'
	gen `tiesrank' = `tieshelp' if `rank'!=`rank'[_n-1] & `rank' <= `tieshelp'
	by `rank', sort: replace `rank' = `tiesrank'[1]
	gen int `select' = 0
	foreach r of local ranks {
		replace `select' = 1 if `rank'  == `r'
	}
	keep if `select'
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
