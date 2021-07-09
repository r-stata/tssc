*! version 1.1 February 1, 2007 @ 11:22:27
*! Generates Variable holding the (person specific) number of different items of sequence

* version 1.0: SJ contribution
* version 1.1: New Option subsequence
	
program define _gsqitemcount
version 9

	gettoken type 0 : 0
	gettoken h    0 : 0 
	gettoken eqs  0 : 0

	syntax varname [if] [in] , [i(varname) t(varname) sq(varname) align keeplongest MISsing SUBSEQuence(string) ] 
	
	marksample touse, novarlist
	if "`subsequence'" != "" quietly replace `touse' = 0 if !inrange(`_dta[SQtis]',`subsequence')


	// Sq-Data
	capture _sqset `varlist' `i' `t', `align' `keeplongest'
	if _rc {
		di as error "data not declared as SQ-data; use -sqset-"
		exit 9
	}

	quietly {

		// Options
		tempvar valid
		gen byte `valid' = cond("`missing'"=="",!mi(`_dta[SQis]'),1)
		
		// Generate Variable
		by `valid' `touse' `_dta[SQiis]' `_dta[SQis]', sort: gen `h' = 1 if _n==1 & `touse' & `valid'
		by `touse' `_dta[SQiis]', sort: replace `h' = sum(`h') if `touse' 
		by `touse' `_dta[SQiis]', sort: replace `h' = `h'[_N] if `touse'
		char _dta[SQitemcount] "$EGEN_Varname"
		label variable `h' "Overall number of different items in sequence"
	}
end

	
