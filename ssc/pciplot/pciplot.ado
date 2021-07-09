*! v 1.1.0 PR 14may2013
program define pciplot
version 11.0
/*
	Plot pointwise confidence intervals.
	Vars are y y_lci y_uci x or y y_se x.
	Default for the reference line is lstyle(refline).
	Lwidth() etc supplant the default if any is specified.
*/
syntax varlist(min=3 max=4 numeric) [if] [in] [, ADDplot(string asis) ///
 LWidth(string) LColor(string) LPattern(string) *]
tokenize `varlist'
local i 1
while "``i''" != "" {
	confirm var ``i''
	local ++i
}
local y `1'
if `i' == 4 { // 3 arguments
	tempname z
	tempvar lci uci
	scalar `z' = invnormal((100 + c(level))/200)
	local x `3'
	gen `lci' = `y' - `z' * `2'
	gen `uci' = `y' + `z' * `2'
	lab var `lci' "lower conf limit"
	lab var `uci' "upper conf limit"
}
else { // 4 arguments
	local x `4'
	local lci `2'
	local uci `3'
}
marksample touse
if ("`lwidth'`lcolor'`lpattern'" != "") local lstyle lwidth(`lwidth') lcolor(`lcolor') lpattern(`lpattern')
else local lstyle lstyle(refline)
twoway (rarea `lci' `uci' `x' if `touse', sort pstyle(ci)) ///
 (line `y' `x' if `touse', sort pstyle(p2) `lstyle') ///
 (`addplot') , `options'
end
