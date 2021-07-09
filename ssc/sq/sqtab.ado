*! version 1.6 Juni 4, 2013 @ 21:43:14
*! Sumarize information on (person specific) sequences

* version 1.0 SJ contribution
* version 1.1 New Option: subsequence()
* version 1.2 Tempfiles in compount double quotes
* version 1.3 -keepranks- with -so- and -ss- resulted in error. This is fixed.
* version 1.4
* version 1.5 bug with some Window's -> fixed
* version 1.6 change string representation 

program define sqtab, rclass
version 9
	syntax [varname(default=none)] [if] [in] ///
	  [, nosort ranks(numlist) so se gapinclude SUBSEQuence(string) * ]
	
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
	
	
	// Options
	if "`varlist'" == "" local sort = cond("`sort'"=="nosort","","sort")
	else local sort = "" 
	
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
		
		if "`so'" == "so" {
			by `_dta[SQiis]' (`_dta[SQtis]'), sort: keep if `_dta[SQis]' ~= `_dta[SQis]'[_n-1]
			by `_dta[SQiis]' (`_dta[SQtis]'): replace `_dta[SQtis]' = _n
		}
		
		if "`se'" == "se" {
			by `_dta[SQiis]' `_dta[SQis]', sort: keep if _n == 1
			by `_dta[SQiis]' (`_dta[SQis]'): replace `_dta[SQtis]' = _n
		}
		
		// Option ranks
		if "`ranks'" != "" {
			tempfile original frequency
			save `"`original'"'
			tempvar freq rank select
			keep `_dta[SQiis]' `_dta[SQtis]' `_dta[SQis]' `touse'
			keep if `touse'
			reshape wide `_dta[SQis]', i(`_dta[SQiis]') j(`_dta[SQtis]')
			by `_dta[SQis]'*, sort: gen `freq' = _N * (-1)
			by `freq' `_dta[SQis]'*, sort: gen int `rank' = _n==1
			replace `rank' = sum(`rank')
			by `freq', sort: replace `rank' = `rank'[1]
			gen int `select' = 0
			foreach r of local ranks {
				replace `select' = 1 if `rank'  == `r'
			}
			keep if `select'
			replace `freq' = `freq' * -1
			sort `_dta[SQiis]'
			save `"`frequency'"'
			use `"`original'"', clear
			sort `_dta[SQiis]'
			merge `_dta[SQiis]' using `"`frequency'"'
			keep if _merge==3
			drop _merge

			count
			if r(N) == 0 {
				noisily di "{err} No observations for rank(s) `ranks'. Choose different ranks"
				exit 198
			}
		}
		
		// Create building blocks for string representation
		// -------------------------------------------------
		
		tempvar stringpiece episode

		by `_dta[SQiis]' (`_dta[SQtis]'), sort:  ///
		  gen byte `episode' = 1 if `_dta[SQis]' != `_dta[SQis]'[_n-1]

		by `_dta[SQiis]' (`_dta[SQtis]'), sort:  ///
		  replace `episode' = sum(`episode') 

		by `_dta[SQiis]' `episode' (`_dta[SQtis]'), sort: ///
		  gen `stringpiece'  ///
		  = string(`_dta[SQis]')+ cond(_N>1,":" +string(_N),"")  ///
		  if _n==1

		// Reshape to Wide
		// ---------------

		keep `varlist' `iflist' `_dta[SQiis]' `_dta[SQtis]' `_dta[SQis]' `freq' `touse' `stringpiece'
		reshape wide `_dta[SQis]' `stringpiece', i(`_dta[SQiis]') j(`_dta[SQtis]')
		sort `_dta[SQis]'*
		
		
		// Generate Display-Variable
		// -------------------------
		
		tempvar pattern
		
		// Create string representation (from egen-concat)
		gen str1 `pattern' = "" 
		foreach var of varlist `stringpiece'* {
			replace `pattern' = trim(`pattern') + " " + trim(`var')
		}
		replace `pattern' = trim(`pattern')
		
		// I want labels
		local label = ////
		  cond("`se'"=="" & "`so'"=="","Sequence-Pattern",  ///
		  cond("`se'"=="" & "`so'"!="","Sequence-Order", ///
		  cond("`se'"!="" & "`so'"=="","Sequence-Elements","")))
		label variable `pattern' "`label'"
		
	}
		
		// Output
		// ------
		
		local fweight = cond("`ranks'"=="","","")
		tab `pattern' `varlist' `fweight', `sort' `options'
		
		// Return
		// ------
		
		return scalar N = r(N)
		return scalar r = r(r)
		if "`varlist'" != "" return scalar c = r(c)
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


