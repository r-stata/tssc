*! version 1.2.0 February 1, 2007 @ 11:07:11
*! Describe Sequences 

* 1.0: distributed on SSC
* 1.1: "feasible %" added (proposed by SJ-Reviewer)
* 1.2: New options subsequence

program define sqdes, rclass
version 9

	syntax [if] [in] [, GAPinclude so se graph SUBSEQuence(string) * ]

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
	marksample touse
	if "`subsequence'" != "" quietly replace `touse' = 0 if !inrange(`_dta[SQtis]',`subsequence')
	
	// Other options only wiht -graph-
	if "`graph'" == "" & `"`options'"' != "" {
		di as error `"`options' not allowed"' _n "invalid syntax"
                exit 198
	}

	quietly {
		preserve

		// Drop Sequences with Gaps 
		if "`gapinclude'" == "" {
			tempvar lcensor rcensor gap
			by `_dta[SQiis]' (`_dta[SQtis]'), sort: gen `lcensor' = sum(!mi(`_dta[SQis]'))
			by `_dta[SQiis]' (`_dta[SQtis]'): gen `rcensor' = sum(mi(`_dta[SQis]'))
			by `_dta[SQiis]' (`_dta[SQtis]'): ///
			  replace `rcensor' = ((_N-_n) == (`rcensor'[_N]-`rcensor'[_n])) & mi(`_dta[SQis]')
			by `_dta[SQiis]' (`_dta[SQtis]'): ///
			gen `gap' = sum(mi(`_dta[SQis]') & `lcensor' & !`rcensor')
			by `_dta[SQiis]' (`_dta[SQtis]'): ///
			replace `touse' = 0 if `gap'[_N]>0
		}
		keep if `touse'
		if _N == 0 {
			noi di as text "(No observations)"
			exit
		}

		// Option so
		keep if `touse'
		if "`so'" == "so" {
			by `_dta[SQiis]' (`_dta[SQtis]'), sort: keep if `_dta[SQis]' ~= `_dta[SQis]'[_n-1]
			by `_dta[SQiis]' (`_dta[SQtis]'): replace `_dta[SQtis]' = _n
		}

		// Option se
		if "`se'" == "se" {
			by `_dta[SQiis]' `_dta[SQis]', sort: keep if _n == 1
			by `_dta[SQiis]' (`_dta[SQis]'): replace `_dta[SQtis]' = _n
		}

		// Keep Quantities for table header
		tempvar count n fo ff fc
		levelsof `_dta[SQis]', missing
		local K: word count `r(levels)'
		levelsof `_dta[SQtis]'
		local T: word count `r(levels)'
		levelsof `_dta[SQiis]'
		local F: word count `r(levels)'

		// Prepare Dataset for Output
		keep `varlist' `iflist' `_dta[SQiis]' `_dta[SQtis]' `_dta[SQis]' 
		reshape wide `_dta[SQis]', i(`_dta[SQiis]') j(`_dta[SQtis]')
		bysort `_dta[SQis]'*: gen `count' = _N
		bysort `_dta[SQis]'*: keep if _n==1
		local Kobs = _N

		// Calculate Fractions
		bysort `count': gen `n' = _N
		bysort `count': keep if _n==1
		gen `fo' = `n'/`Kobs'*100
		gen `ff' = `n'/`F'*100
		gen `fc' = sum(`ff')

		count
		set obs `=r(N)+1'
		replace `n' = `Kobs' in -1
		replace `ff' = 100*`Kobs'/`F' in -1

		label var `count' "Observations"
		label var `n' "Sequences"
		label var `ff' "% of observed"
		label var `fc' "Cum."


	}

	// Output
	
	// Header
	di "{txt}{ralign 27:# of observed sequences:}{res} " `F'
	di "{txt}{ralign 27:overall # of obs. elements:}{res} `K'"
	di "{txt}{ralign 27:max sequence length:}{res} `T'"
	di "{txt}{ralign 27:# of producible sequences:}{res} " `K'^`T'

	// Table
	tabdisp `count', cell(`n' `ff' `fc') totals stubwidth(12)
	
	// Return
	return scalar elem = `K'
	return scalar pos = `T'
	return scalar S_p = `K'^`T'
	return scalar S_o = `F'
	return scalar S_d = `Kobs'
	return scalar r = _N

	// Option graph
	if "`graph'" != "" {
		graph twoway bar `n' `count', title(Sequence-Concentration Plot) `options'
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
	
