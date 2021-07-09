*! version 1.1 February 1, 2007 @ 11:22:32
*! Generates Variable holding the (person specific) length of the observed sequences (of type)

* version 1.0: SJ contribution
* version 1.1: New Option subsequence

program _gsqlength
version 9

	gettoken type 0 : 0
	gettoken h    0 : 0
	gettoken eqs  0 : 0

	syntax [varname(default=none)] [if] [in] ///
	  [, Element(string) gapinclude SUBSEQuence(string) ]

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
		
		// Counter
		local counter = cond("`element'"=="","sum(1)","sum(`_dta[SQis]'==`element')")

		// Generate Variable
		by `touse' `_dta[SQiis]' (`_dta[SQtis]'), sort: gen `h' = `counter' if `touse'
		by `touse' `_dta[SQiis]' (`_dta[SQtis]'): replace `h' = `h'[_N] if `touse'
		
		
		if "`element'" == "" {
			label variable `h' "Length of sequence"
		}
		if "`element'" != "" {
			label variable `h' "Length of episodes of element `element'"
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
