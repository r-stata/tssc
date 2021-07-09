*! version 1.3 November 27, 2009 @ 15:07:12 UK
*! kohler@wzb.eu luniak@wzb.eu 
* Returns position on which subsequence is first found in sequence

* 1.0: initial version
* 1.1: program didn't stored variable names -> fixed
* 1.2: program didn't used "touse" -> fixed
*      Option so allowed
* 1.3: Egenerated Vars starting with stups as sqvar can create a error -> fixed

program _gsqfirstpos
	version 9.2
        gettoken type 0 : 0
        gettoken h    0 : 0 
        gettoken eqs  0 : 0

	syntax [varname(default=none)] [if]  ///
	  , PATtern(string) [  SUBSEQuence(string) gapinclude so ]

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

	preserve
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
		keep if `touse'
		if _N == 0 {
			noi di as text "(No observations)"
			exit
		}

		if "`so'" == "so" {
			by `_dta[SQiis]' (`_dta[SQtis]'), sort: keep if `_dta[SQis]' ~= `_dta[SQis]'[_n-1]
			by `_dta[SQiis]' (`_dta[SQtis]'): replace `_dta[SQtis]' = _n
		}

		// Handle pattern()
		local i 1
		local counter 1
		foreach epi in `pattern' {
			if strpos("`epi'",":") {
				gettoken element times: epi, parse(:)
					local times: subinstr local times ":" "", all
				}
				else {
					local element `epi'
					local times 1
			}
			forv j = 1/`times' {
				local vecpattern "`vecpattern' `element'"
			}
		}
		
		// Reshape Wide
		levelsof `_dta[SQis]', local(alphabet) missing

		// pattern as a variable
			tempvar vecpat
			gen `vecpat' = .
			
			local i = 1
			foreach v of local vecpattern{
				replace `vecpat' =`v' if _n==`i'	
				local i =`++i'
			}

		// and alphabet as a variable
			tempvar alpha
			gen `alpha' = .
			
			local i = 1
			foreach a of local alphabet{
				replace `alpha' =`a' if _n==`i'	
				local i =`++i'
			}


		// Mata
		mata: BMFirst("`_dta[SQis]'","`vecpat'","`alpha'", "`_dta[SQiis]'")

		// Bring Back Mata-Results to Orignal Data
		keep `_dta[SQiis]' _SQBMFirst
		sort `_dta[SQiis]'
		tempfile x
		save `x'


		restore 
		merge `_dta[SQiis]' using `x'
		drop _merge
		gen `h' = _SQBMFirst
		drop _SQBMFirst

		label variable `h' "Position of first occurance of `pattern'"
		char _dta[SQfirstpos] "`_dta[SQfirstpos]' $EGEN_Varname"
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

exit
	
