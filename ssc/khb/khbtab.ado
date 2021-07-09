*! version 2.1 Februar 20, 2019 @ 18:23:48 UK
*! Nested nonlinear probability models with khb-correction
*! Support: ukohler@uni-potsdam.de

* version 2.1: if/in allowed but not implemented. Fixed
* version 2.0: Version 1.0 produce wrong results for all models exepct first and last. This is fixt.
* version 1.0: Uploaded to SSC

// Caller Program
// ==============

program khbtab, rclass
local caller = c(version)

version 13
	
	// Low level parsing
	// -----------------
	
	syntax [anything] [if] [in] [aweight fweight pweight] 		/// 
	  [using] [, vce(passthru) esttab prefix(string)  ///
	  Tableoptions(string) nopreserve ape outcome(string) Verbose ]

	if "`preserve'" == "" {
		preserve
	}
	
	// Parse User Input
	gettoken model anything:anything
	gettoken Y anything:anything
	gettoken X Z0: anything, parse("||")
	local Zall `=subinstr("`Z0'","||","",.)'

	// Build weights
	if "`weight'"!="" {
		local wexp [`weight'`exp']
	}

	// Convenience options
	if "`verbose'" != "" local noi noisily
	if `"`stats'"' == `""' local stats stats(N)

	// Catch user's weight expression
	if "`prefix'" != "" local prefix `prefix':
	if strpos("`prefix'","svy") {
		svyset
		if "`r(wexp)'" != "" local khbwexp [`r(wtype)'`r(wexp)']
		if "`wexp'" != "" {
			di "{err} Weights set with -svyset-; do not specifiy weights"
			exit 101
		}
	}
	else local khbwexp `wexp'
	

	quietly {

		// Create calls to -khb- for each set of X, Z
		local i 1
		while "`Z0'" != "" {

			// Define the Z-Vars
			local Z0: subinstr local Z0 "||" ""
			gettoken Zthis Z0: Z0, parse("||")
			local Zrest `=subinstr("`Z0'","||","",.)'

			// Call -khb- 
			`noi' khb `model' `Y' `X' || `Zthis' `Zrest' `khbwexp'  ///
			  `if' `in' , concomitant(`concomitant') `vce' `ape' keep 
		
			unab residuals : _khb_res*
			local droplist `droplist' `residuals'
			local droplist: list uniq droplist
		
			if "`outcome'" != "" {
				local predict predict(outcome(`outcome'))
			}
*			else local predict predict(outcome(1))

			`noi' `prefix' `model' `Y' `X' `residuals' `wexp' `if' `in', `vce' 

			if "`ape'"=="ape" `noi' margins, dydx(*) post  ///
			  `continuous' `predict'
			
			estimates store _khb_`i++'
			local X `X' `Zthis'
		}

		// Full  Moodle now
		`noi' `prefix' `model' `Y' `X' `wexp' `if' `in', `vce'
		
		if "`ape'"=="ape" `noi' margins, dydx(*) post  ///
		  `continuous' `predict'
		
		estimates store _khb_`i'
	}

	// Caller for program to format the table
	khb_tab _khb_* `using' , `tableoptions'   ///
	  x(`X') z(`Zall') y(`Y') `esttab' droplist(`droplist')

	// Returns
	tempname bkhb Vkhb
	forv j=1/`i' {
		quietly estimates restore _khb_`j'
		matrix `bkhb' = e(b)
		matrix `Vkhb' = e(V)
		return matrix b`j' = `bkhb'
		return matrix V`j' = `Vkhb'
		return local N`j' = `e(N)'
		estimates drop _khb_`j'
	}
	
end

program khb_tab, rclass
	syntax anything [using] ///
	  , x(string) z(string) y(string)  ///
	  [ c(string) esttab keep(string) stats(passthru) droplist(string) drop(string) * ]

	unab residuals: _khb_*
	local drop drop(`drop' `droplist')

	if `"`keep'"' == "" local keep keep(`x' `z' `c') 
	if `"`stats'"' == "" local stats stats(N) 
	
	local cmd = cond("`esttab'"=="","estimates table","esttab")
	
	`cmd' _khb_* `using',  `drop' `stats' `options' 

	if "`cmd'" != "esttab" {
		return scalar nmodels = r(nmodels)
		return scalar ccols = r(ccols)
		return local m1_depname  `r(m1_depname)'
		return local cmdline  `r(cmdline)'
		matrix stats = r(stats)
		return matrix stats = stats
	}


end

exit
	
	
