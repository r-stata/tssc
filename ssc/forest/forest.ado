*! version 2.3: 3 Feb 2020 Benjamin Daniels bbdaniels@gmail.com

// Forest - Stata module to visualize results from multiple regressions on a single independent variable.

cap prog drop forest
prog def forest

// Syntax --------------------------------------------------------------------------------------
syntax anything /// syntax – forest reg d1 d2 d3
	[if] [in] [fw pw iw aw] ///
	, ///
    Treatment(string asis) /// Open-ended to allow things like ivregress inputs
    [Controls(string asis)] /// Any variable list of controls
    [or] /// odds-ratios: passes to regression command and orders log scale on chart
    [d]  /// cohen's d: standardizes all dependent variables before regression
    [sort(string asis)] /// Allow ordering of results by size: global, family
    [Bonferroni] [bh] /// FWER corrections
    [GRAPHopts(string asis)] /// Open-ended options for tw command
    [CRITical(real 0.05)] /// Allow changing critical value: 0.05 as default
    [*] /// regression options


version 13.1
qui {
// Setup ---------------------------------------------------------------------------------------
preserve
  marksample touse, novarlist
  keep if `touse'

	tempvar dv
  cap mat drop results

  // Prefix when cohen's d ordered
	if "`d'" == "d" local std "Standardized "

  // Labels for OR (binary variable assumed)
	if "`or'" == "or" {
		local l0 : label (`treatment') 0
		local l1 : label (`treatment') 1
	}
	else {
	  local tlab : var label `treatment'
	}

  // Get regression model
  local cmd = substr( ///
    "`anything'",1, ///
    strpos("`anything'","(")-1)

  // Parse dependent variable lists
  parenParse `anything'
  forvalues i = 1/`r(nStrings)' {
    local string`i' = "`r(string`i')'"
    unab string`i' : `string`i''
  }

// Loop over dependent variable lists ----------------------------------------------------------
local labpos = 1
local nStrings = `r(nStrings)'
forvalues i = 1/`nStrings' {

  // Set up FWER correction
	if "`bonferroni'" != "" {
    // Get Bonferroni critical value
		local level = round(`=100-(5/`=`: word count `string`i'''-1')',0.01)
    // Round to 2 digits (required by reg)
    local level : di %3.2f `level'
    // Implement using level() option NOTE: Do other specs use different options?
		local thisBonferroni = "level(`level')"
		local note `"`note' "Family `i' Bonferroni correction showing confidence intervals for: `level'%""'
	}

	// Loop over depvars
  tokenize `string`i''
	qui while "`1'" != "" {

		// Get label
		local theLabel : var lab `1'
    if ("`bonferroni'`bh'" != "") & (`nStrings' > 1) local fwerlab " [F`i']"
		local theLabels = `"`theLabels' "`theLabel'`fwerlab'""'

		// Standardize dependent variable if d option
		if "`d'" == "d" {
			cap drop `dv'
			egen `dv' = std(`1')
			local 1 = "`dv'"
		}

    // Replace any self-referenced controls here
    local theseControls = subinstr("`controls'","@","`1'",.)

		// Regression
		`cmd' `1' `treatment' ///
      `theseControls' ///
      [`weight'`exp'] ///
      , `options' `or' `thisBonferroni'

    // Store results
		mat a = r(table)'
		mat a = a[1,....]
    if "`bh'" != "" mat a = `i' , a

		mat results = nullmat(results) ///
			\ a

	local ++labpos
	mac shift
	}
}

// Graph ---------------------------------------------------------------------------------------
clear
svmat results , n(col)

  // Input labels
  qui count
  gen label = ""
  forv i = 1/`r(N)' {
    local thisLabel : word `i' of `theLabels'
    replace label  = "`thisLabel'" in `i'
  }

  // Implement Benjamini-Hochberg
  gen bh_sig = ""
  if "`bh'" != "" {
    bys c1 : egen bh_rank = rank(pvalue)
    bys c1 : gen bh_crit = (bh_rank/_N)*`critical' // BH crit at selected alpha
    gen bh_elig = pvalue if (pvalue < bh_crit)
    bys c1 : egen bh_max = max(bh_elig)
    replace bh_sig = "*" if (pvalue <= bh_max) & (bh_max != .)
    local bhplot = `"(scatter pos b if bh_sig == "*", ms(O) mlc(black) mfc(red) msize(medlarge) mlw(thin) )"'
    local note `"`note' "Colored markers indicate signifcant Benjamini-Hochberg p-value at FWER {&alpha} = `critical'.""'
  }
  else {
    gen sig = "*" if (pvalue <= `critical')
    local bhplot = `"(scatter pos b if sig == "*", ms(O) mlc(black) mfc(red) msize(medlarge) mlw(thin) )"'
    local note `"`note' "Colored markers indicate signifcant p-value at {&alpha} = `critical'.""'
  }

  // Allow family-wise sorting
  cap gen c1 = 1
  if "`sort'" == "local" {
    sort c1 b
  }
  if "`sort'" == "global" {
    sort b
  }

  // Set up labels
  qui count
  local theLabels = ""
  forv i = 1/`r(N)' {
    local thisLabel = label[`i']
    local theLabels = `"`theLabels' `i' "`thisLabel'""'
  }

  // Logarithmic outputs for odds ratios, otherwise linear effects
	if "`or'" == "or" {
		local log `"xline(1,lc(black) lw(thin)) xscale(log) xlab(.01 "1/100" .1 `""1/10" "{&larr} Favors `l0'""' 1 "1" 10 `""10" "Favors `l1'{&rarr}""' 100 "100")"'
		gen x1=100
		gen x2=1/100
	}
	else {
		local log `"xtit({&larr} `std'Effect of `tlab' {&rarr}) xline(0,lc(black) lw(thin) lp(dash))"'
		gen x1=0
		gen x2=0
	}

	// Graph ----------------------------------------------------------------------------------
  gen pos = _n
	gen y1 = 0
	gen y2 = `labpos'

	tw ///
		(scatter y1 x1 , m(none)) ///
		(scatter y2 x2 , m(none)) ///
		(rspike  ll ul pos , horizontal lc(gs12) lw(thin)) ///
		(scatter pos b if bh_sig != "*", ms(O) mlc(black) mfc(white) msize(medlarge) mlw(thin) ) ///
    `bhplot' ///
		, `log' yscale(reverse) ///
      ylab(`theLabels',angle(0) notick nogrid) ytit(" ") legend(off) ///
      note(`note' , span) `graphopts'

}
end
// End -----------------------------------------------------------------------------------------

// Program to parse on parenthesis -------------------------------------------------------------
cap prog drop parenParse
program def parenParse , rclass

  syntax anything

  local N = length(`"`anything'"')

  local x = 0
  local parCount = 0

  // Run through string
  forv i = 1/`N' {
    local char = substr(`"`anything'"',`i',1) // Get next character

    // Increment unit and counter when encountering open parenthesis
    if `"`char'"' == "(" {
      if `parCount' == 0 {
        local ++x // Start next item when encountering new block
      }
      else {
        local string`x' = `"`string`x''`char'"'
      }
      local ++parCount
    }
    // Otherwise de-increment counter if close parenthesis
    else if `"`char'"' == ")" {
      local --parCount
      if `parCount' != 0 local string`x' = `"`string`x''`char'"'
    }
    // Otherwise add character to string block
    else {
      local string`x' = `"`string`x''`char'"'
    }
  }

  // Return strings to calling program
  return scalar nStrings = `x'
  forv i = 1/`x' {
    return local string`i' = `"`string`i''"'
  }

end
// End -----------------------------------------------------------------------------------------

// End of adofile
