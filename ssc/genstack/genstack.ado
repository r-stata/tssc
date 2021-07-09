*! gentack v1.0.2 gimpavido@imf.org 26jun2015
*! gentack v1.0.0 11mar2014
*! gentack v1.0.1 11mar2015 copies labels of original variables to stacked variables
*! gentack v1.0.1 26jul2015 uses stub for newvars and performs newvar checks 
capture program drop genstack
program genstack
	version 10.0
	syntax varlist(min=2 numeric) [if] [in], GENerate(string) [DOUBLE]

************************* Perform user error checks ***************************
	* check that you have observations
	marksample touse
	quietly count if `touse'
	if `r(N)' == 0 error 2000
	*check that new vars are are not in use
	foreach var of local varlist {
		confirm new var `generate'`var'
	}
*/

************* Cycle through varlist creating tempvar for each variable ********
local varlist_p 
local varlist_n
foreach var of local varlist {
	* split the plane in >0 and <=0
	tempvar `var'_p `var'_n 
	qui gen `double' ``var'_p' = `var' if `var'>0
	local varlist_p = "`varlist_p'" + " ``var'_p'"
	qui gen `double' ``var'_n' = `var' if `var'<=0
	local varlist_n = "`varlist_n'" + " ``var'_n'"
	* construct separate stacked vars for >0 and <0
	tempvar `var'_sp `var'_sn
	qui egen `double' ``var'_sp' = rowtotal(`varlist_p')
	qui egen `double' ``var'_sn' = rowtotal(`varlist_n')
	qui gen `double' `generate'`var' = .
	qui replace `generate'`var' = ``var'_sp' if `var'>0
	qui replace `generate'`var' = ``var'_sn' if `var'<=0
	* pass the varlabel to the stacked vars
	local varlabel : var label `var'
	label var `generate'`var' "`varlabel'"
	}
end
