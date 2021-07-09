*! version 2.0 August 26, 2013 @ 17:11:01
*! Sequence-Index-Plot

* Version 1.1: Original SJ contribution
* Version 1.2: Some new default settings  (proposed by m.kaulisch@utwente.nl)
*              New option subsequence	
* Version 1.3: tempfiles with compount double quotes
* Version 1.4: Option -order()- allows varlist
* Version 1.5: Option -order()- uses automatic order at lower levels
* Version 1.6: Option -by(var, options)- gives an error when used with option -> fixed
* Version 1.7: Option se issued an error when used with by -> fixed
* Version 1.8: Impements Halpins propsals to fight against over-plotting
* Version 1.9: Option rbar implemented
* Version 1.9a: color(string asis)
* Version 2: Wrong scaling if minimum time > 1 -> fixed

program define sqindexplot
version 9
	syntax [if] [in] ///
	  [, ranks(numlist) so se order(varlist) by(string)  /// 
	  gapinclude SUBSEQuence(string)  ///
      color(string asis) xtitle(string asis) yscale(string) 	/// 
	  xsize(passthru) ysize(passthru) overplot(real 60) rbar * ]

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

	marksample touse
	if "`subsequence'" != "" quietly replace `touse' = 0 if !inrange(`_dta[SQtis]',`subsequence')

	// by
	if `"`by'"' != `""' {
		gettoken byvars byopts: by, parse(",")
	}

	// Set Device
	local device = cond("`rbar'"=="","rspike","rbar")

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

		tempvar episode begin end ordervar pointer

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

		// Option ranks (Remember: different than in other programs)
		if "`ranks'" != "" {
			tempfile original wide frequency
			tempvar n
			save `"`original'"'
			keep `_dta[SQiis]' `_dta[SQtis]' `_dta[SQis]'
			reshape wide `_dta[SQis]', i(`_dta[SQiis]') j(`_dta[SQtis]')
			save `"`wide'"'
			bysort `_dta[SQis]'*: gen `n' = _N
			bysort `_dta[SQis]'*: keep if _n==1
			KeepRanks `n', ranks(`ranks')
			sort `_dta[SQis]'*
			save `"`frequency'"'
			use `"`wide'"', clear
			sort `_dta[SQis]'*
			merge `_dta[SQis]'* using `"`frequency'"'
			keep if  _merge==3
			keep `_dta[SQiis]'
			sort `_dta[SQiis]'
			save `"`wide'"', replace
			use `"`original'"'
			sort `_dta[SQiis]' 
			merge `_dta[SQiis]' using `"`wide'"'
			keep if _merge==3
			drop _merge
		}

		// Sort-Order 
		tempfile original sorted
		save `"`original'"'
		keep `_dta[SQis]' `_dta[SQtis]' `_dta[SQiis]' `order' `byvars'
		reshape wide `_dta[SQis]', j(`_dta[SQtis]') i(`_dta[SQiis]')
		if "`byvars'"=="" {
			sort `order' `_dta[SQis]'* `_dta[SQiis]'
			gen long `ordervar' = _n
		}
		else by `byvars' (`order' `_dta[SQis]'* `_dta[SQiis]'), sort: gen long `ordervar' = _n
		keep `ordervar' `_dta[SQiis]'
		sort `_dta[SQiis]'
		save `"`sorted'"'
		use `"`original'"', clear
		sort `_dta[SQiis]'
		merge `_dta[SQiis]' using `"`sorted'"'

		// Number episodes
		by `_dta[SQiis]' (`_dta[SQtis]'), sort: gen `episode' = 1 ///
		  if `_dta[SQis]' ~= `_dta[SQis]'[_n-1]
		by `_dta[SQiis]' (`_dta[SQtis]'): replace `episode' = sum(`episode')
		
		// Keep 1st and last observation of each `Episode'
		by `_dta[SQiis]' `episode'  (`_dta[SQtis]'), sort: keep if _n==1 | _n==_N
		// Expand if 1st and last is the same
		by `_dta[SQiis]' `episode'  (`_dta[SQtis]'): gen byte `pointer' = _N==1
		expand 2 if `pointer'

		// generate the  time of `begin' and `end' of `episode'
		by `_dta[SQiis]' `episode' (`_dta[SQtis]'), sort: gen `begin' = `_dta[SQtis]'[1] -.5 
		by `_dta[SQiis]' `episode' (`_dta[SQtis]'), sort: gen `end' = `_dta[SQtis]'[2] + .5

		// Generate ghost-variables (for legend)
		sum `_dta[SQtis]', meanonly
		tempvar legend1 legend2
		gen byte `legend1'=r(min)
		gen byte `legend2'=r(min)

		// Check graph size
		scatter `_dta[SQis]' `_dta[SQis]' in 1/10, `xsize' `ysize' nodraw
		local xdim `.Graph._scheme.graphsize.x'
		local ydim `.Graph._scheme.graphsize.y'
		if `ydim' > `xdim' local ydim = `ydim' * `ydim'/`xdim'
		
		// procede as shown in Kohler/Brzinsky (2005)
		levelsof `_dta[SQis]', local(K)
		local i 1
		local j 2
		foreach k of local K {
			local suffix: subinstr local k "-" "M", all
			local suffix: subinstr local suffix "." "X", all
			tempvar bsq`suffix' esq`suffix'
			gen `bsq`suffix'' = `begin' if `_dta[SQis]' == `k'
			gen `esq`suffix'' = `end' if `_dta[SQis]' == `k'
			local legorder  `"`legorder' `j' `"`:label (`_dta[SQis]') `k''"'"'

			if `"`color'"' != `""' {
				local colopt1 `"lcolor(`:word `i' of `color'')"'
				local colopt2 `"color(`:word `i' of `color'')"'
			}
			else local colopt2 bstyle(p`i')

			if "`device'" == "rspike" {
				local deviceopt 		///  
				  lwidth(`=1/_N*`overplot'*`ydim'') lstyle(p`i'bar) `colopt1'
			}
			else if "`device'" == "rbar" {
				local deviceopt  `colopt2'
			}
			
			local rbars `rbars' 		/// 
			  ||  `device' `bsq`suffix'' `esq`suffix'' `ordervar'  ///
			  , horizontal `deviceopt'                             ///
			  ||  rbar `legend1' `legend2' `ordervar'              ///
			  , horizontal `colopt2'
			local j = `j'+2
			local i = `i'+1
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

		if `"`xtitle'"' == "" local xtitle `"xtitle("")"'
		else local xtitle `"xtitle(`xtitle')"'

		if `"`legend'"' == `""' 		/// 
		  local legend `"legend(order(`legorder') col(1) pos(2))"'
		if `"`by'"' != `""' {
			if `"`byopts'"' == `""' local byopts `", legend(pos(2) yrescale)"'
			local by `"by(`byvars' `byopts')"'
		}

		
		// The graph
		graph twoway `rbars' , ///
		  `legend' `by' ///
		  `yscale' ylab(, angle(horizontal)) ytitle(`""') ///
		  `xscale' `options' `xtitle' `ysize' `xsize'
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


