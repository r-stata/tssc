*! version 1.0 March 23, 2007 @ 10:32:21
*! Generates Variable holding the frequency of respective sequence-type
program _gsqranks
version 9.2

	gettoken type 0 : 0
	gettoken h    0 : 0
	gettoken eqs  0 : 0

	syntax [varname(default=none)] [if] [in] ///
		  [, so se gapinclude SUBSEQuence(string) * ]


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
	if "`subsequence'" != "" quietly replace `touse' = 0 if !inrange(`_dta[SQtis]',`subsequence')

	quietly {

		tempfile orig reshaped
		save `orig'
	
		// Drop Sequences with Gaps 
		if "`gapinclude'" == "" {
			tempvar lcensor rcensor gap
			by `_dta[SQiis]' (`_dta[SQtis]'), sort: gen `lcensor' = sum(!mi(`_dta[SQis]'))
			by `_dta[SQiis]' (`_dta[SQtis]'): gen `rcensor' = sum(mi(`_dta[SQis]'))
			by `_dta[SQiis]' (`_dta[SQtis]'): ///
			  replace `rcensor' = ((_N-_n) == (`rcensor'[_N]-`rcensor'[_n])) & mi(`_dta[SQis]')
			by `_dta[SQiis]' (`_dta[SQtis]'): ///
			  gen `gap' = sum(mi(`_dta[SQis]')  & `lcensor' & !`rcensor')
			by `_dta[SQiis]' (`_dta[SQtis]'): ///
			  replace `touse' = 0 if `gap'[_N]>0
		}
		keep if `touse'
		if _N == 0 {
			noi di as text "(No observations)"
			exit
		}

		if "`so'" == "so" {
			by `_dta[SQiis]' (`_dta[SQtis]'), sort: ///
			  keep if `_dta[SQis]' ~= `_dta[SQis]'[_n-1]
			by `_dta[SQiis]' (`_dta[SQtis]'): replace `_dta[SQtis]' = _n
		}
		
		if "`se'" == "se" {
			by `_dta[SQiis]' `_dta[SQis]', sort: keep if _n == 1
			by `_dta[SQiis]' (`_dta[SQis]'): replace `_dta[SQtis]' = _n
		}
			
		// Reshape to Wide
		keep `_dta[SQiis]' `_dta[SQtis]' `_dta[SQis]'  
		reshape wide `_dta[SQis]', i(`_dta[SQiis]') j(`_dta[SQtis]')

		// Generate Variable
		tempvar freq 
		by `_dta[SQis]'*, sort: gen `freq' = _N * (-1)
		by `freq' `_dta[SQis]'*, sort: gen int `h' = _n==1
		replace `h' = sum(`h')
		by `freq', sort: replace `h' = `h'[1]

		// Store and merge back
		keep `_dta[SQiis]' `h'
		sort `_dta[SQiis]'
		save `reshaped'
		use `orig'
		tempvar sorter
		gen `sorter' = _n
		sort `_dta[SQiis]'
		merge `_dta[SQiis]' using `reshaped'
		assert _merge != 2
		drop _merge
		sort `sorter'

		// Labels 
		if "`so'" == "" & "`ss'" == "" {
			label variable `h' "Rank of sequence-pattern"
		}
		if "`so'" != "" & "`ss'" == "" {
			label variable `h' "Rank of SO sequence-pattern"
		}
		if "`so'" == "" & "`ss'" != "" {
			label variable `h' "Rank of SS sequence-pattern"
		}
		char _dta[SQlength] "`_dta[SQlength]' $EGEN_Varname"
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
