*! version 1.5 September 5, 2013 @ 16:39:52
*! Sumarize information on (person specific) sequences

* version 1.0 Original SJ contribution
* version 1.1 GraphWithWlines crashed if sqvar had no value labels -> fixed
* version 1.2 By-option didn't worked -> fixed
* version 1.3 By-option still don't worked -> fixed
* version 1.4 Oh my god: By-option still doesn't worked -> fixed
* version 1.5 Allowing line options lpattern, lcolor, lstyle 
	
program define sqparcoord
version 9
	syntax [if] [in] ///
	  [, ranks(numlist) so * by(string) offset(string)  ///
	  wlines(string) gapinclude SUBSEQuence(string)  ///
	  lcolor(string) lwidth(string) lpattern(string) lstyle(string) ]

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

	// Option
	if "`by'" != "" {
		gettoken byvars byopt: by, parse(,)
		if `"`byopt'"' == `""' local byopt ,
		local by "by(`byvars' `byopt' legend(off))"
	}

	// Wlines andoption
	if "`wlines'" != "" local wlinesoption wlines(`wlines')
	
	// Other line options
	if `"`lwidth'"' != `""' & `"`wlines'"' != `""' {
		di `"{err} Option lwidth() cannot be combined with option wlines()"'
		exit 198
	}

	if `"`lcolor'"' != `""' local usercolor lcolor(`lcolor')
	if `"`lpattern'"' != `""' local userpattern lpattern(`lpattern')
	if `"`lstyle'"' != `""' local userstyle lstyle(`lstyle')
	if `"`lwidth'"' != `""' local userwidth lwidth(`lwidth')

	local otherlineoptions `usercolor' `userpattern' `userstyle' `userwidth'

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
		
		// Stretch Scale for option SO
		if "`so'" == "so" {
			tempvar order howmany
			by `_dta[SQiis]' (`_dta[SQtis]'), sort: ///
			  keep if `_dta[SQis]' ~= `_dta[SQis]'[_n-1]
			by `_dta[SQiis]' (`_dta[SQtis]'), sort: gen `howmany' = _N
			expand 2 if `howmany' == 1
			by `_dta[SQiis]' (`_dta[SQtis]'), sort: replace `_dta[SQtis]' = _n
			by `_dta[SQiis]', sort: gen `order' = (_n-1)/(_N-1)
		}
		
		// Sequence-Frequency Data
		tempvar n
		keep `_dta[SQiis]' `_dta[SQtis]' `_dta[SQis]' `order' `byvars'
		reshape wide `_dta[SQis]' `order' , i(`_dta[SQiis]') j(`_dta[SQtis]')
		bysort `_dta[SQis]'*: gen `n' = _N
		bysort `_dta[SQis]'*: keep if _n==1

		// Option ranks
		if "`ranks'" != "" KeepRanks `n', ranks(`ranks')

		// Prepare random number for option offset
		if "`offset'" != "" {
			tempvar noise
			gen `noise' = uniform()*`offset'-`offset'/2
		}
		
		// Reshape long
		reshape long `_dta[SQis]' `order', i(`_dta[SQiis]') j(`_dta[SQtis]')

		// Relabel timevar for Option SO
		if "`so'" != "" {
			replace `_dta[SQtis]' = `order'
			label variable `_dta[SQtis]' "Order"
		}

		// Add random noise
		if "`offset'" != "" replace `_dta[SQis]' = `_dta[SQis]' + `noise'

		// Graphs
		sort  `_dta[SQiis]' `_dta[SQtis]' 
		GraphWithWlines `n' ///
		  , `wlinesoption' `otherlineoptions' `options' `by' 
	}
end
		

// Subprogram for graphs with lines proportional to frequency
program GraphWithWlines
	syntax varname, [ wlines(string)  ///
	   lcolor(string) lpattern(string) lstyle(string) lwidth(string) *]


	sum `varlist', meanonly
	local max = r(max)
	local label: value label `_dta[SQis]'
	local label = cond("`label'" == "","",":`label'")
	levelsof `varlist', local(K)
	local levels : word count `K'

	local i 1
	foreach k of local K {

		// Take options backwards
		local l = `levels'+1-`i++'

		foreach loption in color pattern width {
			if `"`l`loption''"' != `""' {
				if strpos("`l`loption''"',"..") {
					local user`loption' l`loption'(`l`loption'')
				}
				else {
					local user`loption' l`loption'(`: word `l' of `l`loption''')
				}
			}
		}

		if `"`lstyle'"' != `""' local userstyle lstyle(`lstyle')
		else if "`lstyle'" == "" local userstyle lstyle(p1)
		
		if `"`wlines'"' != `""' {
			local userwidth lwidth(`= `k'/`max' * `wlines'')
		}
		
		tempvar sq`k'
		gen `sq`k''`label' =  `_dta[SQis]' if `varlist' == `k'
		local line `line' || line `sq`k'' `_dta[SQtis]',  ///
		  c(L) `usercolor' `userpattern' `userstyle' `userwidth'
	}
	graph twoway `line' || , legend(off) `by' `options' 
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

