*! 1.1.0 NJC 24 Nov 2003 
* 1.0.0 NJC 23 Nov 2003 
program pgb2, sort
	version 8 
	syntax varname [pweight fweight aweight iweight/] [if] [in] ///
	[, Grid GENerate(namelist min=2 max=2) param(numlist min=4 max=4) ///
	show(str) a(real 0.5) * ]
	
	if "`generate'" != "" { 
		capture confirm new var `generate' 
		if _rc { 
			di as err "generate() must name new variables"
			exit 198 
		}
	}

	if "`param'" != "" { 
		tokenize "`param'" 
		args A B P Q 
	} 
	else { 
		cap assert "`e(ba)'" != "" & "`e(bb)'" != "" & "`e(bp)'" != "" & "`e(bq)'" != ""
		if _rc {
                	di as err "needs parameter estimates for a, b, p and q" 
	                exit 198
        	}
		else { 
			local A = e(ba) 
			local B = e(bb)
			local P = e(bp) 
			local Q = e(bq) 
		}
	} 

	_get_gropts , graphopts(`options') getallowed(rlopts plot)
	local options `"`s(graphopts)'"'
	local rlopts `"`s(rlopts)'"'
	local plot `"`s(plot)'"'
	_check4gropts rlopts, opt(`rlopts')

	tempvar F Psubi
	quietly { 
		marksample touse            

		count if `varlist' <= 0 & `touse' 
		if r(N) { 
			noi di " " 
			noi di as txt "Warning: {res:`varlist'} has `r(N)' values <= 0." _c
			noi di as txt " Not used in graph"
			replace `touse' = 0 if `varlist' <= 0 
		} 	

		if `"`show'"' != ""  { 
			capture count if `show' 
			if _rc { 
				di as err "invalid show() option"
				exit 198 
			} 
			else { 
				count if (`show') & `touse' 
				if r(N) == 0 error 2000 
			}

			local show "& (`show')" 
		} 
		else { 
			qui count if `touse' 
			if r(N) == 0 error 2000 
		} 	

		if "`exp'" == "" local exp = 1 
	
		sort `touse' `varlist'
		gen float `Psubi' = sum(`touse' * `exp') 
		su `touse' [w = `exp'], meanonly 
		replace `Psubi' = ///
			(`Psubi' - `a') / (r(sum) - 2 * `a' + 1) if `touse' 
		gen float `F' = ///
	ibeta(`P',`Q', (`varlist' / `B')^`A' / (1 + (`varlist'/`B')^`A')) ///
		if `touse'
	}
	
	local yttl "GB2 F[`varlist']"
	label var `F' "`yttl'"
	local xttl "Empirical P[i]"
	format `F' `Psubi' %9.2f
	if `"`plot'"' == "" local legend legend(nodraw)
	
	graph twoway		        	///
	(scatter `F' `Psubi' if `touse' `show', ///
		sort				///
		ylabel(0(.25)1, nogrid `grid')	///
		xlabel(0(.25)1, nogrid `grid')	///
		ytitle(`"`yttl'"')		///
		xtitle(`"`xttl'"')		///
		`legend'			///
		`options'			///
	)					///
	(function y=x if `touse' `show',	///
		clstyle(refline)		///
		range(`Psubi')			///
		n(2)				///
		yvarlabel("Reference")		///
		`rlopts'			///
	)					///
	|| `plot'				///
	// blank

	// user will see messages about missing values 
	if "`generate'" != "" { 
		tokenize `generate' 
		gen `1' = `F' if `touse' 
		label var `1' "GB2 probabilities" 
		gen `2' = `Psubi' if `touse' 
		label var `2' "empirical probabilities" 
	}	
end
