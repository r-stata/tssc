*! 2.0.2 NJC 16 May 2011
*! 2.0.1 NJC 17 November 2003
*! 2.0.0 NJC 6 November 2003
* 1.1.3 NJC 24 April 1998
* 1.1.2 NJC 3 March 1998
* 1.1.1 NJC 27 Jan 1998
* 1.1.0 NJC 16 April 1997
program pgamma, sort
	version 8
	syntax varname [fweight aweight/] [if] [in] ///
	[, ALTernative Grid GENerate(namelist min=2 max=2) param(numlist max=2 min=2) show(str) * ]
	
	_get_gropts , graphopts(`options') getallowed(rlopts plot addplot)
	local options `"`s(graphopts)'"'
	local rlopts `"`s(rlopts)'"'
	local plot `"`s(plot)'"'
	local addplot `"`s(addplot)'"'
	_check4gropts rlopts, opt(`rlopts')

	if "`generate'" != "" { 
		capture confirm new var `generate' 
		if _rc { 
			di as err "generate() must name new variables"
			exit 198 
		}
	}

	marksample touse
	qui count if `varlist' < 0 & `touse' 
	if r(N) { 
		di " " 
		di as txt "warning: {res:`varlist'} has `r(N)' values < 0; " _c
		di as txt " not used"
		replace `touse' = 0 if `varlist' < 0 
	} 	

	qui count if `touse' 
	if r(N) == 0 error 2000
	
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

	if "`param'" != "" { 
		tokenize `param' 
		args A B 
		if `A' <= 0 | `B' <= 0 { 
			di as err "parameters must both be positive"
			exit 498 
		}	
		if "`alternative'" != "" local B = 1/`B' 
	} 	
	else { 
		if "`exp'" != "" {	
			qui gammafit `varlist' if `touse' [`weight' = `exp']
		} 
		else qui gammafit `varlist' if `touse'
		local A = e(alpha) 
		local B = e(beta) 
	} 

	tempvar F Psubi
	quietly {
		if "`exp'" == "" local exp = 1 
		sort `touse' `varlist'
		gen float `Psubi' = sum(`touse' * `exp') - 0.5 * `exp'
		su `touse' [w = `exp'], meanonly 
		replace `Psubi' = `Psubi' / r(sum) if `touse' 
		gen float `F' = gammap(`A',`varlist'/`B') if `touse'
	}
	
	local yttl "gamma F[`varlist']"
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
	|| `addplot'				
	// blank

	// user will see messages about missing values 
	if "`generate'" != "" { 
		tokenize `generate' 
		gen `1' = `F' if `touse' 
		label var `1' "gamma probabilities" 
		gen `2' = `Psubi' if `touse' 
		label var `2' "empirical probabilities" 
	}	
end
