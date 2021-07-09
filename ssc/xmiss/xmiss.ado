* tabulate missing values of second variable by levels of first variable
* phil clayton, phil@anzdata.org.au

*! -xmiss- version 1.1 Phil Clayton    2014-09-08

* version history
* 2014-09-08	v1.1	Make program byable
* 2014-09-03	v1.0	Initial version

capture program drop xmiss
program define xmiss, rclass byable(recall)
	version 11
	syntax varlist(min=2 max=2) [if] [in], [Sort replace]
	local by: word 1 of `varlist'
	local var: word 2 of `varlist'
	marksample touse, novarlist
	
	* ensure we have observations
	quietly count if `touse'
	if r(N)==0 error 2000
	
	tempvar n total missing missperc order group
	gen long `n'=_n

	* determine total #, missing # and missing proportion within each category
	quietly egen `total'=total(1) if `touse', by(`by')
	quietly egen `missing'=total(missing(`var')) if `touse', by(`by')
	quietly gen `missperc'=100 * `missing' / `total'

	* order the groups if requested
	if "`sort'"=="sort" {
		quietly egen `order'=rank(`missperc') if `touse', track
	}
	else {
		gen byte `order'=1
	}
	quietly egen `group'=group(`order' `by') if `touse', missing

	* now display table
	display
	display as text _col(35) "`var'"
	display as text _col(25) "{hline 29}"
	display as text "`by'" _col(25) "Missing" _col(35) "Total" _col(45) "% missing"
	display as text "{hline 53}"
	
	sum `group', meanonly
	forvalues i=1/`r(max)' {
		sum `n' if `group'==`i', meanonly
		local example=r(min)
		capture confirm string variable `by'
		if !_rc { // string
			local level: display `: format `by'' `by'[`example']
		}
		else { // numeric
			* if a value label is present use that, otherwise use the number
			* with its format
			local label: value label `by'
			if "`label'"=="" {
				local level: display `: format `by'' `by'[`example']
			}
			else {
				local level `"`: label `label' `=`by'[`example']''"'
			}
		}
		display as text abbrev("`level'", 20) ///
			as result _col(25) `missing'[`example'] ///
			_col(35) `total'[`example'] ///
			_col(45) %5.1f `missperc'[`example']
	}
	
	display as text "{hline 53}"
	quietly count if `touse'
	local total_all=r(N)
	quietly count if missing(`var') & `touse'
	local missing_all=r(N)
	display as text "All" ///
		as result _col(25) `missing_all' _col(35) `total_all' ///
		_col(45) %5.1f 100*`missing_all'/`total_all'
	
	* replace dataset if requested
	if "`replace'"=="replace" {
		local missvarlab: variable label `var'
		if "`missvarlab'"=="" local missvarlab `var'

		collapse (mean) missing=`missing' total=`total' percent=`missperc' ///
			if `touse', by(`by')
				
		lab var missing "Frequency missing `missvarlab'"
		lab var total "Total frequency in group"
		lab var percent "Percent missing `missvarlab'"
		
		if "`sort'"=="sort" sort percent `by'
	}
end
