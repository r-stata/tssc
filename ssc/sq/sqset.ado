*! version 1.2 Januar 5, 2012 @ 14:06:56 UK
*! SQset data

* 1.0.0 Initial version
* 1.1. Additional check for misspecfied data
* 1.2. keeplongest not sort stable. Fixed.

program sqset
version 9
	syntax [varlist(max=3 default=none)] [,	clear trim ltrim rtrim keeplongest]
	
	if "`clear'" != "" { 
		syntax [, clear]
		Clear
		exit
	}

	if "`varlist'"=="" {
		Query
		Check
		exit
	}
	
	syntax varlist(min=3 max=3) [, trim ltrim rtrim keeplongest]
	
	if "`trim'" == "trim" {
		local rtrim rtrim
		local ltrim ltrim
	}
	
	// Sequence
	tokenize `varlist'
	char _dta[SQis] `1' 
	char _dta[SQiis] `2' 
	char _dta[SQtis] `3'
	Check, `ltrim' `keeplongest' `rtrim'
end

program define Clear
	char _dta[SQtis]
	char _dta[SQiis]
	char _dta[SQis]
end
	
program define Query
	local sqvar `_dta[SQis]'
	local ivar `_dta[SQiis]'
	local tvar `_dta[SQtis]'

	if `"`sqvar'"'=="" {
		noi di as error "element variable not set, use -sqset elementvar sqid ordervar"
		exit 111
	}
	
	if `"`ivar'"'=="" {
		noi di as error "identifier variable not set, use -sqset sqvar sqid ordervar-"
		exit 111
	}
	
	if `"`tvar'"'=="" {
		noi di as error "order variable not set, use -sqset sqvar sqid ordervar-"
		exit 111
	}
end
	
program define Check, rclass
	syntax [, ltrim keeplongest rtrim]
	local sqvar `_dta[SQis]'
	local tvar `_dta[SQtis]'
	local ivar `_dta[SQiis]'

	quietly {

		// Check order variable
		capture assert `tvar' < . 
		if _rc {
			noi di as error "order variable has missings"
			exit 9
		}

		tempvar control
		by `ivar' (`tvar'), sort: gen `control' = `tvar' - `tvar'[_n-1]
		sum `control', meanonly
		capture assert r(min) == r(max)
		if _rc {
			noi di as error "order variable has gaps"
			exit 9
		}

		capture assert `tvar'==int(`tvar')
		if _rc { 
			noi di as error "order variable has non integer values"
			exit 9
		}

		by `ivar' (`tvar'), sort: replace `control' = `tvar'[1]
		sum `control'
		capture assert r(Var) == 0
		if _rc {
			noi di as error "sequences start at different positions; consider fillin"
			exit 9
		}

		// Check sequence-identifier Variable
		capture assert !mi(`ivar')
		if _rc {
			noi di as error "identifier variable has missings"
			exit 9
		}
		capture by `ivar' `tvar': assert _n==1
		if _rc {
			noi di as error "identifier variable not unique within ordervar"
			exit 9
		}


		// Check gaptypes
		tempvar lcensor rcensor gap
		by `ivar' (`tvar'), sort: gen `lcensor' = sum(!mi(`sqvar'))
		by `ivar' (`tvar'): gen `rcensor' = sum(mi(`sqvar'))
		by `ivar' (`tvar'): ///
		  replace `rcensor' = ((_N-_n) == (`rcensor'[_N]-`rcensor'[_n])) & mi(`sqvar')
		gen `gap' = mi(`sqvar') & `lcensor' & !`rcensor'

		// Process Gaps
		capture assert !`gap'
		if _rc & "`keeplongest'" == "" {
			noi di as text _n /// 
			"Note: Some sequences contains gaps" _n ///
			"Consider option -keeplongest- " 
		}
		else if _rc & "`keeplongest'" == "keeplongest" {
			tempvar block blockcount
			by `ivar' (`tvar'), sort: gen `block' = sum(mi(`sqvar'))
			by `ivar' `block' (`tvar'), sort: gen `blockcount'= _N
			by `ivar' (`blockcount' `block'), sort: ///
			  keep if `blockcount' == `blockcount'[_N] ///
			        & `block'==`block'[_N] & !mi(`sqvar')
			sum `tvar', meanonly
			by `ivar' (`tvar'), sort: replace `tvar' = r(min)+_n-1
			noi di as text _n ///
			"Note: dataset has been changed due to the use of option -keeplongest-" 
		}
		capture assert !`rcensor' 
		if _rc & "`rtrim'" == "" {
			noi di as text _n ///
			"Note: Some sequences have missings at the end" _n ///
			"Consider option -rtrim- " 
		}
		else if _rc & "`rtrim'" == "rtrim" {
			drop if `rcensor'
			noi di as text _n ///
			"Note: dataset has changed due to the use of option -rtrim-" 
		}
		capture assert `lcensor' 
		if _rc & "`ltrim'" == "" {
			noi di as text _n ///
			"Note: Some sequences doesn't start at position 1." _n ///
			"Consider option -ltrim-" 
		}
		else if _rc & "`ltrim'" == "ltrim" {
			drop if !`lcensor'
			sum `tvar', meanonly
			by `ivar' (`tvar'), sort: replace `tvar' = r(min)+_n-1
			noi di as text _n ///
			"Note: dataset has been changed due to the use of option -ltrim-" 
		}

		
		// Sequence range
		capture confirm numeric variable `sqvar'
		if !_rc {
			sum `sqvar', meanonly
			ret scalar sqmin = r(min)
			ret scalar sqmax = r(max)
			capture assert `sqvar' <  .
			if _rc local missflag ", and missings"
			noi di as text _n _col(8)  "element variable:  " ///
			  as result "`sqvar', " r(min) " to " r(max) "`missflag'"
		}
		else noi di as text _col(8)  "element variable:  " ///
			  as result "is string"

		
		// idenfier range
		capture confirm numeric variable `ivar'
		if !_rc {
			sum `ivar', meanonly
			ret scalar imin = r(min)
			ret scalar imax = r(max)
			noi di as text _col(8)  "identifier variable:  " ///
			  as result "`ivar', " r(min) " to " r(max)
		}
		else noi di as text _col(8)  "idenifier variable:  " ///
			  as result "is string"
		
		// order range
		capture confirm numeric variable `tvar'
		if !_rc {
			sum `tvar' , meanonly
			ret scalar tmin = r(min)
			ret scalar tmax = r(max)
			noi di as text _col(8)  "order variable:  " ///
			  as result "`tvar', " r(min) " to " r(max)
		}
		else noi di as text _col(8)  "order variable:  " ///
		  as result "is string"
	}
		
end

