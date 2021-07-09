*! version 3.0.3 Timothy Mak Mar2015.
* Version 3.0.3: Corrected bug in that weights are not passed to collapse in the presence of errortype. 
* Version 3.0.3: Corrected bug in that one needs to put in an extra || if adding options under addplot. 
* Version 3.0.2: Corrected bug in the err(`ci') option introduced in version 3.0.0
program define lgraph, rclass
version 9

// Known bug: If more than 1 axis is used, the legend may not be correct

// Parse
syntax varlist(num min=2) [if] [in] [aweight pweight iweight fweight] [, Statistic(string) ERRortype(string) ///
	LOPtions(string) EOPtions(string) LEOPtions(string) FOPtions(string) ///
	fit(string) COLORGradient(string) SEParate(real 0) by(varname numeric) /// 
	bw noMarker noLegend nopreserve ALSOcollapse(string) wide PLOTorderoptions swap ///
	addplot(string asis) SCHeme(passthru) ///
	median Quantile(numlist min=2 max=2) minmax /* Obsolete options - included for backward compatibility 
	*/ *]

// Save weights
local WeightExp `weight' `exp'

// Preserve original data
if "`preserve'" != "nopreserve" preserve
		
// Selecting subsample
marksample touse, novarlist

// Deal with the old options	
if "`quantile'" != "" local errortype quantile(`quantile')	
if "`median'" == "median" local statistic median
if "`minmax'" == "minmax" local errortype minmax
cap display `errortype' > 0
if _rc == 0 local errortype ci(`errortype')

// Wide format
if "`wide'" == "wide" {
	qui keep if `touse' 
	local nvars : word count `varlist'
	local xvar : word `nvars' of `varlist'
	local nvars2 = `nvars' - 1
	forval i=1/`nvars2' {
		local var : word `i' of `varlist'
		qui gen _dummyvar`i' = `var'
		local label`i' : variable label `var'
		if `"`label`i''"' == "" local label`i' `var'
		local labeldefine `labeldefine' `i' `"`label`i''"'
	}
	tempvar index
	qui gen `index' = _n 
	qui reshape long _dummyvar, i(`index')
	tempname labelname
	label define `labelname' `labeldefine'
	label values _j `labelname'
	lgraph _dummyvar `xvar' _j [`WeightExp'], statistic(`statistic') errortype(`errortype') `legend' separate(`separate') ///
		loptions(`loptions') eoptions(`eoptions') leoptions(`leoptions') foptions(`foptions') `bw' fit(`fit') `plotorderoptions' ///
		colorgradient(`colorgradient') `marker' by(`by') alsocollapse(`alsocollapse') nopreserve addplot(`addplot') `scheme' `options'
	return local command `r(command)'
	return local options `r(options)'
	exit
}
	

// Parse
gettoken depvar xvar : varlist 
gettoken xvar1 xvar2 : xvar
local colorg_by : word 1 of `colorgradient'
if "`by'" != "" {
	if `"`colorg_by'"' != "by" {
		local xvar3 `xvar2'
		local xvar2 `by'
	}
	else {
		local xvar3 `by'
	}
}
if "`swap'" == "swap" & "`by'" != "" {
	local oldxvar2 `xvar2'
	local xvar2 `xvar3'
	local xvar3 `oldxvar2'
}

qui replace `touse' = 0 if `xvar1' == . | `depvar' == .
local nvars : word count `xvar2' 
if `nvars' > 1 error 103
local Options `options'

// Parse options and store them in loption`level' & eoption`level' OR loption & eoption

tempvar dummy 

if "`xvar2'" == "" { 
	qui gen `dummy' = 1 if `touse' 
	local xvar2 `dummy' 
}

qui levelsof `xvar2' if `touse'
local xvar2levels `r(levels)' 
local firstxvar2level : word 1 of `xvar2levels'
foreach le in le l e f { 
	tokenize `"``le'options'"', parse(";")
	foreach level in `xvar2levels' { 
		local i = 1
		while "``i''" != "" { 
			if "``i''" == ";" {
				local i = `i' + 1
				continue
			}
			
			// Take out the numlist part
			local `i'_test : subinstr local `i' "to" "" 
			local numlist_n = indexnot(`"``i'_test'"', "1234567890()/:.-,[] ")
			local numlist = substr(`"``i''"', 1,`=`numlist_n'-1')
			local op = substr(`"``i''"', max(1, `numlist_n'), length(`"``i''"'))
			if "`numlist'" == "" | "`numlist'" == "." {
				if "`le'" == "le" {
					local loption`level' `loption`level'' ``i''
					local eoption`level' `eoption`level'' ``i''
					local foption`level' `foption`level'' ``i''
				}
				else {
					local `le'option`level' ``le'option`level'' ``i''
				}
				if "`plotorderoptions'" == "`plotorderoptions'" & "`level'" == "`firstxvar2level'" {
					if "`le'" == "le" {
						local lOption `lOption' ``i''
						local eOption `eOption' ``i''
						local fOption `fOption' ``i''
					}
					else {
						local `le'Option ``le'Option' ``i''
					}
				}
			}
			else {
				numlist "`numlist'"
				foreach levelo in `r(numlist)' {
					if "`level'" == "`levelo'" { 
						if "`le'" == "le" {
							local loption`level' `loption`level'' `op'
							local eoption`level' `eoption`level'' `op'
							local foption`level' `foption`level'' `op'
						}
						else {
							local `le'option`level' ``le'option`level'' `op'
						}
					}
					if "`plotorderoptions'" == "`plotorderoptions'" & "`level'" == "`firstxvar2level'" {
						if "`le'" == "le" {
							local lOption`levelo' `lOption`levelo'' `op'
							local eOption`levelo' `eOption`levelo'' `op'
							local fOption`levelo' `fOption`levelo'' `op'
						}
						else {
							local `le'Option`levelo' ``le'Option`levelo'' `op'
						}
					}
				}
			}
			local i = `i' + 1
		}
	}	
}

// Parse Other options
if "`statistic'" == "" local statistic mean
if "`bw'" == "bw" local scheme scheme(s2mono)
local nomarker = cond("`marker'" == "", "", "msymbol(none)")
if `"`addplot'"' != "" local argument4 `"|| `addplot' ||"'

// Parse errortype
if "`errortype'" != "" {
	local 0 , `errortype'
	syntax , [ci(numlist min=1 max=1) Collapse(varlist min=2 max=2) Quantile(numlist min=2 max=2) minmax sd SEmean SEBinomial SEPoisson iqr]
	
	if "`ci'" != "" local scaleparam semean
	if "`quantile'" != "" {
		tokenize `quantile'
		local extratocollapse (p`1') lbound = `depvar' (p`2') ubound = `depvar' 
	}
	
	if "`minmax'" != "" {
		local extratocollapse (min) lbound = `depvar' (max) ubound = `depvar'
	}
	
	if "`collapse'" != "" {
		local var1 : word 1 of `collapse'
		local var2 : word 2 of `collapse'
		local extratocollapse (mean) lbound = `var1' (mean) ubound = `var2'
	}
	
	foreach type in sd semean sebinomial sepoisson {
		if "``type''" == "`type'" {
			local scaleparam `type'
		}
	}
	
	if `"`iqr'"' == "iqr" local extratocollapse (p25) lbound = `depvar' (p75) ubound = `depvar'

}

if `"`scaleparam'"' != "" local scale_collapse (`scaleparam') scaleparam=`depvar'

// Variable label
local ylabel : variable label `depvar'

// Collapse 
qui collapse `alsocollapse' (`statistic') statistic=`depvar' `scale_collapse' (count) count=`depvar' /// 
	`extratocollapse' if `touse' [`WeightExp'], by(`xvar1' `xvar2' `xvar3')

tempvar scaleparam2
if "`ci'" != "" & `"`scaleparam'"' == "semean" qui gen `scaleparam2' = invttail(count - 1,((100-`ci')/2)/100)*scaleparam
else if "`ci'" != "" & (`"`scaleparam'"' == "sepoisson" | `"`scaleparam'"' == "sebinomial") {
	qui gen `scaleparam2' = invnormal(1 - ((100-`ci')/2)/100)*scaleparam
}
else if `"`scaleparam'"' != "" qui gen `scaleparam2' = scaleparam

if `"`scaleparam'"' != "" {
	qui gen lbound = statistic - `scaleparam2'
	qui gen ubound = statistic + `scaleparam2'
}

// Setting colors
gr_setscheme, `scheme'
foreach colorpattern in color linepattern {
	foreach try in lineplot line "" {
		if "``colorpattern'order'" == "" {
			local `colorpattern'order `.__SCHEME.`colorpattern'.p1`try'' `.__SCHEME.`colorpattern'.p2`try'' `.__SCHEME.`colorpattern'.p3`try'' `.__SCHEME.`colorpattern'.p4`try'' `.__SCHEME.`colorpattern'.p5`try'' `.__SCHEME.`colorpattern'.p6`try'' ///
				`.__SCHEME.`colorpattern'.p7`try'' `.__SCHEME.`colorpattern'.p8`try'' `.__SCHEME.`colorpattern'.p9`try'' `.__SCHEME.`colorpattern'.p10`try'' `.__SCHEME.`colorpattern'.p11`try'' `.__SCHEME.`colorpattern'.p12`try'' ///
				`.__SCHEME.`colorpattern'.p13`try'' `.__SCHEME.`colorpattern'.p14`try'' `.__SCHEME.`colorpattern'.p15`try'' 
		}
		if "``colorpattern'order'" == "" local `colorpattern'order `.__SCHEME.`colorpattern'.p`try'' 
	}
	if "``colorpattern'order'" == "" {
		if "`colorpattern'" == "color" local `colorpattern'order black
		if "`colorpattern'" == "linepattern" local `colorpattern'order solid
		
		di "{txt}The current scheme does not have a default `colorpattern'"
		di "{txt}`colorpattern' set as {res}``colorpattern'order'"
	}
}

local colornumber : word count `colororder' 
local patternnumber : word count `linepatternorder' 

// Determining the look of the lines

qui tab `xvar2' 
local max = r(r)

// Parse colorgradient 
if "`colorgradient'" != "" { 
	gettoken Color else : colorgradient
	if "`Color'" == "on" local Color : word 1 of `colororder'
	gettoken startcol endcol : else
	if lower(substr("`startcol'",1,3)) == "neg" {
		local startcol 1
		local endcol 0.1
	}
	else {
		if "`startcol'" == "" local startcol 0.1
		if "`endcol'" == "" local endcol 1
	}
	local interval = (`endcol' - `startcol')/(`max' - 1)
}

if "`xvar3'" != "" {
	qui levelsof `xvar3'
	local xvar3levels `r(levels)'
	local nlevels3 : word count `r(levels)'
	matrix yesno = J(`max', `nlevels3', 0)

}

local i = 1
local count = 0
local counter = 1
foreach level in `xvar2levels' { 
	local ii = mod(`i'- 1,`colornumber' ) + 1
	local iii = mod(`i'- 1,`patternnumber' ) + 1
	if "`colorgradient'" != "" {
		local factor = `startcol' + (`i' - 1)*`interval'
		local precolor `Color'*`factor'
	}
	else local precolor : word `ii' of `colororder' 
	local prepattern : word `iii' of `linepatternorder' 

	if "`fit'" != "" {
		local line_option color(`precolor') lpat(blank)
	}
	else {
		local line_option color(`precolor') lpat(`prepattern')
	}

	if "`xvar3'" != "" {
		local line_option_copy `line_option'
		local j = 1
		foreach level3 in `xvar3levels' {
			qui count if `xvar3' == `level3' & `xvar2' == `level'
			if r(N) > 0 {
				if "`Color'" == "by" {
					local jj = mod(`j' - 1, `colornumber') + 1
					local C : word `jj' of `colororder'
					local line_option : subinstr local line_option_copy "color(by*" "color(`C'*"
				}
				if "`plotorderoptions'" == "plotorderoptions" local extraoptions `lOption' `lOption`counter''
				else local extraoptions `loption`level''
				local argument `argument' (connect statistic `xvar1' if `xvar2' == `level' & `xvar3' == `level3', `line_option' `nomarker' `extraoptions') 
				local x3label`i'_`j' : label (`xvar3') `level3'
				local count = `count' + 1
				local counter = `counter' + 1
				matrix yesno[`i', `j'] = 1
			}
			local j = `j' + 1
		}
	}
	else 	{
		if "`plotorderoptions'" == "plotorderoptions" local extraoptions `lOption' `lOption`counter''
		else local extraoptions `loption`level''
		local argument `argument' (connect statistic `xvar1' if `xvar2' == `level', `line_option' `nomarker' `extraoptions') 
		local counter = `counter' + 1
	}
	
	// generate labels for legend
	local x2label`i' : label (`xvar2') `level'
	local i = `i' + 1 
}


// Determine look of errorbars

local argument2 


if "`errortype'" != "" {
	 
	local i = 1
	local counter = 1 
	foreach level in `xvar2levels' {
		local ii = mod(`i'- 1,`colornumber' ) + 1
		local iii = mod(`i'- 1,`patternnumber' ) + 1
		if "`colorgradient'" != "" {
			local factor = `startcol' + (`i' - 1)*`interval'
			local precolor `Color'*`factor'
		}
		else local precolor : word `ii' of `colororder' 
		local prepattern : word `iii' of `linepatternorder' 

		local line_option color(`precolor') lpat(`prepattern')
		
		if "`xvar3'" != "" {
			local line_option_copy `line_option'
			local j = 1
			foreach level3 in `xvar3levels' {
				if yesno[`i',`j'] == 1 {
					if "`Color'" == "by" {
						local jj = mod(`j' - 1, `colornumber') + 1
						local C : word `jj' of `colororder'
						local line_option : subinstr local line_option_copy "color(by*" "color(`C'*"
					}
					if "`plotorderoptions'" == "plotorderoptions" local extraoptions `eOption' `eOption`counter''
					else local extraoptions `eoption`level''
					local argument2 `argument2' (rcap ubound lbound `xvar1' if `xvar2' == `level' & `xvar3' == `level3', `line_option' `extraoptions')
					local counter = `counter' + 1 
				}
				local j = `j' + 1
			}
		}
		else {
			if "`plotorderoptions'" == "plotorderoptions" local extraoptions `eOption' `eOption`counter''
			else local extraoptions `eoption`level''
			local argument2 `argument2' (rcap ubound lbound `xvar1' if `xvar2' == `level' , `line_option' `extraoptions')
			local counter = `counter' + 1
		}
		local i = `i' + 1
	}
}

// Separating error bars

tempvar rank

qui egen `rank' = group(`xvar2' `xvar3')
qui sum `rank'
local nlevels = r(max)
qui sum `xvar1', meanonly
qui replace `xvar1' = `xvar1' + (`rank' - (`nlevels' + 1)/2) *  `separate' * (r(max) - r(min))

// Determine line of best fit 

if "`fit'" != "" {

	local 0 `fit'
	syntax anything [, noWeight]
	if "`weight'" == "" & "`statistic'" == "mean" local aw aw=count

	qui tab `xvar2'
	local max = r(r)

	// generate argument for twoway command + labels for legend
	local i = 1
	local counter = 1
	foreach level in `xvar2levels' { 
				
		local ii = mod(`i'- 1,`colornumber' ) + 1
		local iii = mod(`i'- 1,`patternnumber' ) + 1
		if "`colorgradient'" != "" {
			local factor = `startcol' + (`i' - 1)*`interval'
			local precolor `Color'*`factor'
		}
		else local precolor : word `ii' of `colororder' 
		local prepattern : word `iii' of `linepatternorder' 

		local line_option color(`precolor') lpat(`prepattern')
		
		if "`xvar3'" != "" {
			local j = 1
			local line_option_copy `line_option'
			foreach level3 in `xvar3levels' {
				if yesno[`i',`j'] == 1 {
					if "`Color'" == "by" {
						local jj = mod(`j' - 1, `colornumber') + 1
						local C : word `jj' of `colororder'
						local line_option : subinstr local line_option_copy "color(by*" "color(`C'*"
					}
					if "`plotorderoptions'" == "plotorderoptions" local extraoptions `fOption' `fOption`counter''
					else local extraoptions `foption`level''
					local argument3 `argument3' (`anything' statistic `xvar1' [`aw'] if `xvar2' == `level' & `xvar3' == `level3', `line_option' `extraoptions') 
					local counter = `counter' + 1
				}
				local j = `j' + 1
			}
		}
		else {
			if "`plotorderoptions'" == "plotorderoptions" local extraoptions `fOption' `fOption`counter''
			else local extraoptions `foption`level''
			local argument3 `argument3' (`anything' statistic `xvar1' [`aw'] if `xvar2' == `level', `line_option' `extraoptions') 
			local counter = `counter' + 1
		}
		
		local i = `i' + 1
	}
}


// Drawing the graph 
sort `xvar1'
local properstat = proper("`statistic'")
local options_def `"ytitle(`"`properstat' `ylabel'"')"'

if `"`legend'"' == "nolegend" | `max' == 1 { 
	local options_def `options_def' legend(off)
}
else {
	// Create default legend
	local options_def `options_def' legend(on order(

	if "`xvar3'" != "" {
	
		local k = 1
		forvalues i = 1/`max' { 
			local labelled = 0
			forval j = 1/`nlevels3' {
				if `"`colorg_by'"' != "by" local extracond if `labelled' == 0
				else local include_x3label  , `x3label`i'_`j''

				if yesno[`i',`j'] == 1 {
					local labelled = 1
					if "`fit'" != "" { 
						local l = `k' + `count'
						`extracond' local options_def `options_def' `l' `"Fitted line for `x2label`i''`include_x3label'"'
					}
					`extracond' local options_def `options_def' `k' `"`x2label`i''`include_x3label'"'
					local k = `k' + 1
				}
			}
		}
	}
	else {
		forvalues i = 1/`max' { 
			if "`fit'" != "" { 
				local j = `i' + `max'
				local options_def `options_def' `j' `"Fitted line for `x2label`i''"'
			}
			local options_def `options_def' `i' `"`x2label`i''"'
		}
	}
		
	local options_def `options_def' ))
}

foreach i in "" 2 3 {		// Get rid of the dummy variable
	local argument`i' : subinstr local argument`i' "if `dummy' == 1" "", all
}

twoway `argument' `argument3'  `argument2' `argument4', `options_def' `Options' `scheme'
return local command `argument' `argument3' `argument2' `argument4' 
return local options `options_def' `Options' `scheme'

end
