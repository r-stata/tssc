*! version 1.5 31DEC2019  Benjamin Daniels bbdaniels@gmail.com

// Betterbar - Stata module to produce bar graphs with standard error bars and cross-group comparisons.

cap prog drop betterbar
prog def betterbar

	// Version compatibility
	if `c(version)' >= 15 local la "la(center)"
	version 13.1

syntax anything 				    /// Variable list
	[if] [in] [fw iw aw pw], 	///
  [by(varname)]				      /// Separate variables across higher groups
	[Over(varname)]				    /// Determines groups for comparison at the lowest level
	///
  [n]							          /// Adds sample sizes in legend
  [ci]						          /// Plots standard error bars
  [vce(passthru)]           /// Allow any VCE options in [mean]
	[BARlab]					        /// Labels bars with means
  [BARColor(string asis)]   /// Specify list of bar colors
  [pct]                     /// Bar labels as percentages
	[format(string asis)]		  /// Formats for bar means
  [Vertical]					      /// Horizontal bar is the default
	[*]							          /// Allows any normal options for twoway graphs


// Prep

qui {
preserve
marksample touse , novarlist
	keep if `touse'

// Setup

	// Clean for weights
	local anything = subinstr("`anything'","[]","",.)

  // Set up bar colors
  if "`barcolor'" != "" {
    local colorCounter = 0
    foreach color in `barcolor' {
      local ++colorCounter
      local barColor`colorCounter' = ///
        "fc(`: word `=`: list sizeof barcolor' - `colorCounter' + 1' of `barcolor'')"
    }
  }

	// If no by or over - fill in
		if "`by'" == "" {
			tempname fakebyvar
			gen `fakebyvar' = 1
			local by = "\`fakebyvar'"
			local byoff = 1
		}
		else local byoff = 0

		if "`over'" == "" {
			tempname fakeovervar
			gen `fakeovervar' = 1
			local over = "\`fakeovervar'"
			label def fakeover 1 "Total"
				label val `fakeovervar' fakeover
		}

	// Save this dataset for loops
	tempfile allData
		save `allData' , replace

	// Initialize results dataset
	clear
		tempfile results
		save `results' , emptyok

	// Horizonal-vertical settings
	if "`vertical'" == "" local horizontal "horizontal"
	if "`horizontal'" != "" {
		local axis y
	}
	else {
		local axis x
	}

// Get means and bounds

	// Loop over by-groups
	use `allData' , clear
  unab theVarlist: `anything'
	levelsof `by' , local(bylevels)
	foreach bylevel in `bylevels' {
		// Mean respecting over-groups
		use `allData' , clear
    unab anything : `anything'
		foreach var of varlist `anything' {
			count if `by' == `bylevel' & `var' < .
			if `r(N)' == 0 replace `var' = 0 if `by' == `bylevel'
		}
		keep if `by' == `bylevel'

    tempname a
    cap mat drop `a'
    foreach var of varlist `anything' {
  		mean `var' [`weight'`exp'] ///
        , over(`over' , nolabel) `vce'

      mat theseStats = r(table)
      mat `a' = nullmat(`a') ///
        , theseStats
    }

		clear
		svmat `a' , n(eqcol)

    foreach var in `theVarlist' {
      foreach lab in `e(over_labels)' {
        rename `var'`lab' `var'_`lab'
      }
    }
		rename * stat_*

		gen `by' = `bylevel'

		local x = 0
		foreach var of varlist stat_* {
			replace `var' = `x' in 9
			local ++x
		}

		append using `results'
		save `results' , replace
	}

// Set up graphing points

	// Find means and bounds
    tempvar type
		gen `type' = mod(_n,9)
		reshape long stat_ , i(`by' `type') j(n) string

	// Sort order
		tempvar temp
		gen `temp' = stat_ if `type' == 0
		bys n: egen order = min(`temp')
		drop `temp'

		gen so = 0
		local item_n = -1
		foreach item in `anything' {
			replace so = `item_n' if substr(n,1,strrpos(n,"_")-1) == "`item'"
			local --item_n
		}

    tempvar overvar
    gen `overvar' = real(substr(n,-1,.))

    if "`vertical'" != "" {
      gsort + `by' + so + `overvar' + n + order + `type'
    }
    else {
      gsort - `by' + so - `overvar' + n + order + `type'
    }

		keep if `type' == 1 | `type' == 5 | `type' == 6
		gen place = _n - mod(_n,3)
			replace place = place - 3 if mod(_n,3) == 0
			drop order

			reshape wide stat_ , i(n `by') j(`type')
			sort place

	// Gaps
		local x = 0
		count
		forvalues i = 1/`r(N)' {
			if `by'[`i'] != `by'[`=`i'-1'] local x = `x'+3
			replace place = place + `x' - 1 in `i'
		}

	// Save statistics dataset
	save `results' , replace

// Prep the graph

	// Graph commands with info from base dataset
	use `allData' , clear
		local x = 0
		levelsof `over' , local(olevels)
		foreach level in `olevels' {
			local ++x
			local theLabel : label (`over') `level'
			count if `over' == `level'
			if "`n'" != "" local theN " (N=`r(N)')"
			local theBars `"`theBars' (bar stat_1 place if n == "`level'" , `barColor`x'' barw(2) fi(100) lw(thin) `la' lc(white) `horizontal' ) "'
			local theLegend `"`theLegend' `x' "`theLabel'`theN'""'
		}
		// Get variable labels
		foreach var in `anything' {
			local `var' : var label `var'
		}
		// By-labels
		foreach level in `bylevels' {
			local `level' : label (`by') `level'
		}

	// Use statistics dataset for final graph
	use `results' , clear

		// Set up CI plot
		if "`ci'" == "ci" local ++x
		if "`ci'" == "ci" local ciplot `"(rspike stat_5 stat_6 place , lc(black) `horizontal' legend(label(`x' "95% CI")))"'
		local ++x

		// Set up bar labels
		gen lab = strofreal(stat_1,"%9.2f")
    if "`pct'" == "pct" replace lab = subinstr(lab,".0",".",.)
    if "`pct'" == "pct" replace lab = subinstr(lab,"0.","",.) + "%"
    if "`pct'" == "pct" replace lab = subinstr(lab,"1.","1",.)
		if "`format'" != "" replace lab = strofreal(stat_1,"`format'")
		if "`barlab'" != "" & "`ci'" == "ci" & "`vertical'" == "" local blabplot "(scatter place stat_6  , m(none) mlab(lab) mlabpos(3) mlabc(black) )"
		if "`barlab'" != "" & "`ci'" == ""   & "`vertical'" == "" local blabplot "(scatter place stat_1  , m(none) mlab(lab) mlabpos(3) mlabc(black) )"
		if "`barlab'" != "" & "`ci'" == "ci" & "`vertical'" != "" local blabplot "(scatter stat_6 place , m(none) mlab(lab) mlabpos(12) mlabc(black) )"
		if "`barlab'" != "" & "`ci'" == ""   & "`vertical'" != "" local blabplot "(scatter stat_1 place , m(none) mlab(lab) mlabpos(12) mlabc(black) )"
    if "`barlab'" != "" & "`ci'" == "ci" replace stat_6 = stat_1 if stat_6 == .

		// Set up variable names

		gen var = ""
		foreach var in `anything' {
			replace var = "``var''" if substr(n,1,strrpos(n,"_")-1) == "`var'"
			replace n = substr(n,strrpos(n,"_")+1,.) if substr(n,1,strrpos(n,"_")-1) == "`var'"
		}

		// Gaps
		count
		forvalues i = 2/`r(N)' {
			if var[`i'] != var[`=`i'-1'] replace place = place + 3 if _n >= `i'
		}

		// Set up by-levels
		foreach level in `bylevels' {
			foreach var in `anything' {
				su place if `by' == `level' & var == "``var''"
				if `byoff' != 1 & "`r(mean)'" != "" local varlabs `"`varlabs' `r(mean)' "``level'': ``var''"  "'
				else if "`r(mean)'" != "" local varlabs `"`varlabs' `r(mean)' "``var''"  "'
			}
		}

// Make the graph

	gen zero = 0

	tw ///
		`theBars' 	///
		`ciplot' 	///
		`blabplot' 	///
		(scatter zero zero , m (none) ) ///
		, xtitle(" ") ytitle(" ") legend(order(`theLegend')) ///
			`axis'lab(`varlabs' , angle(0) nogrid notick) ylab(,angle(0)) ///
			`options'

// end qui
}
end
// Have a lovely day!
