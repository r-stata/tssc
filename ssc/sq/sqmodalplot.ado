*! version 1.0 Oktober 5, 2010 @ 13:50:56 UK
*! Sequence-Index-Plot showing the modal element at each position

* Version 1.0: First version, based on indexplot 1.7, 

program sqmodalplot
version 11
	syntax [if] [in] ///
	  [, so se over(varname) tie(string) by(string) gapinclude SUBSEQuence(string) barwidth(string)  ///
      color(string) xtitle(string asis) yscale(string) ylabel(string) ytitle(string) ysize(string) * ]

	// Sq-Data
	if `"`_dta[SQis]'"' == `""' {
		di as error "data not declared as SQ-data; use -sqset-"
		exit 9
	}

	// if/in
	if `"`if'"' != `""' {
		tokenize `"`if'"', parse(" =+-*/^~!|&<>(),.")
		while `"`1'"' != `""' {
			capture confirm variable `1'
			if !_rc {
				local iflist  "`iflist' `1'"
			}
			macro shift
		}
	}
	if `"`iflist'"' != `""' CheckConstant `iflist', stop

	// Over
	if `"`over'"' != `""' CheckConstant `over', stop
	else {
		tempvar over
		tempname olab
		gen byte `over':`olab'=1
		label define `olab' 1 "All sequences"
		if "`ysize'" == "" local ysize "ysize(2)"
	}
	
	marksample touse
	if "`subsequence'" != "" quietly replace `touse' = 0 if !inrange(`_dta[SQtis]',`subsequence')

	// by
	if `"`by'"' != `""' {
		gettoken byvars byopts: by, parse(",")
	}

	preserve

	quietly {

		// Drop Sequences with Gaps 
		if `"`gapinclude'"' == `""' {
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

		tempvar episode begin end pointer

		// Keep Order only
		if "`so'" == "so" {
			tempvar torder stepwidth
			by `_dta[SQiis]' (`_dta[SQtis]'), sort: ///
			  keep if `_dta[SQis]' ~= `_dta[SQis]'[_n-1]
			by `_dta[SQiis]' (`_dta[SQtis]'), sort: replace `_dta[SQtis]' = _n
		}
		
		// Construct Scale for option SE
		else if	"`se'" == "se" {
			by `_dta[SQiis]' `_dta[SQis]', sort: keep if _n == 1
			fillin `_dta[SQiis]' `_dta[SQis]'
			by `_dta[SQiis]' (`_dta[SQis]'), sort: replace `_dta[SQtis]' = _n
			*replace  `_dta[SQis]' = . if _fillin
			drop if _fillin
		}

		// Construct modal sequences
		tempvar n TIE
		gen byte `n'=1
		collapse (sum) `n', by(`_dta[SQtis]' `over' `_dta[SQis]' `byvars')
		bysort `byvars' `over' `_dta[SQtis]' (`n'): gen byte `TIE' = `n'==`n'[_n-1] | `n'==`n'[_n+1]
		capture	by `byvars' `over' `_dta[SQtis]' (`n'): assert `TIE'==0 if _n==_N
		if _rc {
			if "`tie'" == "gap" | "`tie'" == "" {
				tempvar GAP
				bysort `byvars' `over' `_dta[SQtis]' (`n'): replace `_dta[SQis]' = . if `TIE'==1 & _n==_N
				noi di as text "More than 1 mode found at some positions; tie(gap) applied"
			}
			else if "`tie'" == "mode" {
				tempvar MODE
				bysort `byvars' `over' (`n'): gen byte `MODE' = `_dta[SQis]'[_N]
				bysort `byvars' `over' `_dta[SQtis]' (`n'): replace `_dta[SQis]' = `MODE' if `TIE'==1 & _n==_N
				noi di as text "More than 1 mode found at some positions; tie(mode) applied"
			}
			else if "`tie'" == "highest" {
				bysort `byvars' `over' `_dta[SQtis]' `n' (`_dta[SQis]'):  /// 
				  replace `_dta[SQis]' = `_dta[SQis]'[_N] if `TIE'==1 
				noi di as text "More than 1 mode found at some positions; tie(highest) applied"
			}
			else if "`tie'" == "lowest" {
				bysort `byvars' `over' `_dta[SQtis]' `n' (`_dta[SQis]'):  /// 
				  replace `_dta[SQis]' = `_dta[SQis]'[1] if `TIE'==1 
				noi di as text "More than 1 mode found at some positions; tie(lowest) applied"
			}
		}

		by `byvars' `over' `_dta[SQtis]' (`n'): keep if _n==_N

		if "`tie'" == "lead" {
			bysort `byvars' `over' (`_dta[SQtis]'): replace `_dta[SQis]' = `_dta[SQis]'[_n+1] if `TIE'==1
			noi di as text "More than 1 mode found at some positions; tie(lead) applied"
		}
		else if "`tie'" == "lag" {
			bysort `byvars' `over' (`_dta[SQtis]'): replace `_dta[SQis]' = `_dta[SQis]'[_n-1] if `TIE'==1
			noi di as text "More than 1 mode found at some positions; tie(lag) applied"
		}
		
		// Number episodes
		by `byvars' `over' (`_dta[SQtis]'), sort: gen `episode' = 1 ///
		  if `_dta[SQis]' ~= `_dta[SQis]'[_n-1]
		by `byvars' `over' (`_dta[SQtis]'): replace `episode' = sum(`episode')
		
		// Keep 1st and last observation of each `Episode'
		by `byvars' `over' `episode'  (`_dta[SQtis]'), sort: keep if _n==1 | _n==_N

		// Expand if 1st and last is the same
		by `byvars' `over' `episode'  (`_dta[SQtis]'): gen byte `pointer' = _N==1
		expand 2 if `pointer'

		// generate the  time of `begin' and `end' of `episode'
		by `byvars' `over' `episode' (`_dta[SQtis]'), sort: gen `begin' = `_dta[SQtis]'[1] -.5 
		by `byvars' `over' `episode' (`_dta[SQtis]'), sort: gen `end' = `_dta[SQtis]'[2] + .5 

		// procede as shown in Kohler/Brzinsky (2005)
		if "`barwidth'" == "" local barwidth barwidth(.8)
		else local barwidth barwidth(`barwidth')
		
		levelsof `_dta[SQis]', local(K)
		local i 1
		foreach k of local K {
			local suffix: subinstr local k "-" "M", all
			local suffix: subinstr local suffix "." "X", all
			tempvar bsq`suffix' esq`suffix'
			gen `bsq`suffix'' = `begin' if `_dta[SQis]' == `k'
			gen `esq`suffix'' = `end' if `_dta[SQis]' == `k'
			local legorder  `"`legorder' `i' `"`:label (`_dta[SQis]') `k''"'"'
			local colopt `"color(`:word `i++' of `color'')"'
			local rbars "`rbars' (rbar `bsq`suffix'' `esq`suffix'' `over', horizontal `colopt' `barwidth')"
		}

		// Graph defaults
		if `"`xscale'"' == `""' {
			sum `begin', meanonly
			local min = r(min)
			sum `end', meanonly
			local max = r(min)
			local xscale "xscale(range(`min' `max'))"
		}

		if `"`yscale'"' == `""' local yscale `"yscale(reverse)"'
		else local yscale `"yscale(`yscale')"'

		if `"`ylabel'"' != `""' local ylabel `"ylabel(`ylabel')"'
		else if `"`ylabel'"' == `""' {
			levelsof `over', local(olevels)
			local ylabel ylabel(`olevels', valuelabel angle(0))
		}

		if `"`xtitle'"' == `""' local xtitle `"xtitle("")"'
		else local xtitle `"xtitle(`xtitle')"'

		if `"`ytitle'"' == `""' local ytitle `"ytitle("")"'
		else local ytitle `"ytitle(`ytitle')"'
		
		if `"`legend'"' == `""' local legend `"legend(order(`legorder') col(1) pos(2))"'
		if `"`by'"' != `""' {
			if `"`byopts'"' == `""' local byopts `", legend(pos(2) yrescale)"'
			local by `"by(`byvars' `byopts')"'
		}

		// The graph
		graph twoway `rbars' , ///
		  `legend' `by' ///
		  `yscale' `ylabel' `ytitle' `ysize' ///
		  `xscale' `xtitle' `options'
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

