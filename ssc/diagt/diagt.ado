*! diagt 2.032, 30 June 2003
*! by PT Seed (paul.seed@kcl.ac.uk)
*! based on diagtest.ado (Aurelio Tobias, STB-56: sbe36)

*! and further suggestions from Tom Steichen
* incorporate sf option 

* bugfix to preserve matrices.

program define diagt , rclass
version 6.0

* Syntax

	syntax varlist(min=2 max=2 numeric) [if] [in] [fweight] , /*
*/ [Prev(passthru) dp(passthru) Level(real $S_level) sf sf0 noTable woolf tb Display Bamber Hanley odds *]
	tokenize "`varlist'"
	local true `1'
	local test `2'	

	preserve
	if "`if'`in'" ~= ""  { qui keep `if' `in' }
	qui drop if `true' == . | `test' == .
	qui summ `true', meanonly
	cap assert `true' == r(min) | `true' == r(max)
	if _rc { 
		di in ye "All (non-missing) values of `true' other than " r(max) "will be treated as controls"
	}

	qui replace `true' = `true' == r(max)
	local case = r(max)
	local caselab : label (`true') `case'
	if "`caselab'" ~= "`case'" { local caselab "`case' (labelled `caselab')" }

	qui summ `test'
	cap assert `test' == r(min) | `test' == r(max)
	if _rc { 
		di in ye "All (non-missing) values of `test' other than " r(max) "will be treated as negative test results"
	}

	qui replace `test' = `test' == r(max)

* Table
	qui replace `test'  = 1 - `test' 
	qui replace `true'  = 1 - `true'  

	tempname labtest
	label define `labtest' 0 "Pos." 1 "Neg."
	label values `test' `labtest'

	tempname labtrue
	label define `labtrue' 0 "Abnormal" 1 "Normal"
	label values `true' `labtrue'

	if "`table'" ~= "" {
		local qui "qui"
	}
	tempname T
	`qui' tabulate `true' `test' [`weight'`exp'], matcell(`T') `options' 
	local a=`T'[1,1]
	local b=`T'[1,2]
	local c=`T'[2,1]
	local d=`T'[2,2]    

	di in gr "True abnormal diagnosis defined as `true' = `caselab'" _n

if "`display'" ~= "" {
	di "	diagti `a' `b' `c' `d' , `sf' `prev' level(`level') `sf0' notable `woolf' `tb' 
}
	diagti `a' `b' `c' `d' , `sf' `prev' level(`level') `sf0' notable `woolf' `tb' `bamber' `hanley' `odds' `dp'

	local retlist "oneg opos oprev roc or lrn lrp npv ppv prev spec sens "
	foreach ret in `retlist' {
		cap ret scalar `ret'_ub = r(`ret'_ub)
		cap ret scalar `ret'_lb = r(`ret'_lb)
		cap ret scalar `ret' = r(`ret')
	}






end
exit

