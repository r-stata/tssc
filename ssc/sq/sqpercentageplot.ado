*! version 1.0.0 April 1, 2016 @ 11:58:36
*! Percentages of elements by position
program sqpercentageplot
version 14

	syntax [if] [,  ///
	  nobars ///
	  ENTropy nosecond by(string) ///
	  xtitle(string)  ///
	  ytitle(string) ///
	  baropts(string) lopts(string) l2opts(string) * ///
	  legend(passthru) ///
	  ]

	preserve
	
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
	if "`iflist'" != "" CheckConstant `iflist', stop
	quietly keep `if' 
	}

	// by
	if `"`by'"' != `""' {
		gettoken byvars byopts: by, parse(",")
		local by by(`by')
	}

	// Defaults
	if `"`xtitle'"' == `""' {
		local xtitle = ///
		  cond(`"`: var lab `_dta[SQtis]''"'==`""' ///
		  ,`"`_dta[SQtis]'"' ///
		  ,`"`: variable label `_dta[SQtis]''"' ///
		  )
	}
	
	if `"`ytitle'"' == `""' {
		local ytitle = `"Cumulated % of "' +  ///
		  cond(`"`: var lab `_dta[SQis]''"'==`""' ///
		  ,`"`_dta[SQis]'"' ///
		  ,`"`: variable label `_dta[SQis]''"' ///
		  )
	}

	local axis = cond("`bars'"=="nobars",1,2)
	
	quietly {

		// Cumulative Percentages
		// ----------------------
		
		tempvar freq cfreq percent cpercent
		contract `_dta[SQis]' `_dta[SQtis]' `byvars' ///
		  , nomiss freq(`freq')

		sort `byvars' `_dta[SQtis]' `_dta[SQis]'
		
		by `byvars' `_dta[SQtis]' (`_dta[SQis]'): ///
		  gen `cfreq' = sum(`freq')
			
		if `"`bars'"' != `"nobars"' {

			by `byvars' `_dta[SQtis]' (`_dta[SQis]'): ///
			  gen `cpercent' = `cfreq'/`cfreq'[_N] * 100
			
			levelsof (`_dta[SQis]'), local(K)
			local i 1
			foreach k of local K {
				tempvar bar`k' 
				gen `bar`k'' = `cpercent' if  `_dta[SQis]'==`k'
				label variable `bar`k'' `"`: label (`_dta[SQis]') `k''"'
				local bars `bar`k'' `bars'
				local orderinfo `i++' `orderinfo'
			}
		}
	
	// Entropy
	// -------

	if `"`entropy'"' != `""' {
		tempvar frac evar

		by `byvars' `_dta[SQtis]' (`_dta[SQis]'): ///
		  gen `frac' = `freq'/`cfreq'[_N] 
		
		by `byvars' `_dta[SQtis]' (`_dta[SQis]'):  ///
		  gen `evar' =  (-1) *  ///
		  sum(cond( ///
		  !mi(`frac' * log(`frac')), ///
		  `frac' * log(`frac'), ///
		  0))
		by `byvars' `_dta[SQtis]' (`_dta[SQis]'):   ///
		  replace `evar' = `evar'[_N]
		label variable `evar' "Entropy"

		if `"`second'"' != `"nosecond"' {
			if `"`l2opts'"' == `""' {
				local line2 || line `evar' `_dta[SQtis]', yaxis(`axis') sort ///
				  lcolor(white) lwidth(*1.5)
				local i = `i' + 1
			}
			else {
				local line2 || line `evar' `_dta[SQtis]', yaxis(`axis') sort ///
				  `l2opts' 
			}
		}
		local orderinfo `orderinfo' `i'
		local line || line `evar' `_dta[SQtis]', yaxis(`axis') sort `lopts'
		local y2title ytitle("Entropy", axis(`axis'))
	}

	// Default legend
	if `"`legend'"' == `""' local legend legend(order(`orderinfo'))

	}

	if `"`bars'"' != `"nobars"' ///
		local  barplot || bar `bars' `_dta[SQtis]', `baropts'
	

	// Display the graph
	graph twoway ///
	  `barplot' ///
	  `line2' `line' ///
	  || , xtitle(`"`xtitle'"') ytitle(`"`ytitle'"') `y2title' `options' ///
	  `legend' `by'
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
