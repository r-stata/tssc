*! Version 1.0.2, Ben Jann, 16feb2005

program define duncan2, rclass byable(onecall) sortpreserve
	version 8.2
	syntax varlist(min=2 max=2) [fw aw/] [if] [in] [, ///
	 Missing Format(passthru) d(name) ncat(name) nobs(name) dj(name) ]

//variables
	tokenize `varlist'
	if `:word count `_byvars''>3 {
		di as err "too many by-variables specified " ///
		 "(duncan2 can only handle up to 3 by-variables)"
		exit 103
	}

//case selection
	if "`missing'"!="" {
		marksample touse, novarlist
		markout `touse' `2', strok
	}
	else marksample touse, strok

//groupvar 0/1
	capt assert `2'==0 | `2'==1 if `touse'
	if _rc {
		di as err "groupvar not 0/1"
		exit 198
	}

//take care of weights
	if "`exp'"=="" local exp "`touse'"

//sort
	sort `touse' `_byvars' `1'

//compute cell totals ad n of categories
	tempvar cell0 cell1 iid
	qui by `touse' `_byvars' `1': gen byte `iid' = _n==_N & `touse'
	qui by `touse' `_byvars' `1': gen `cell0' = sum(`exp'*(1-`2')) if `touse'
	qui by `touse' `_byvars' `1': replace `cell0' = `cell0'[_N] if `touse'
	qui by `touse' `_byvars' `1': gen `cell1' = sum(`exp'*`2') if `touse'
	qui by `touse' `_byvars' `1': replace `cell1' = `cell1'[_N] if `touse'

//compute column totals and n of cases
	tempvar col0 col1 id Ncat Nobs
	qui by `touse' `_byvars': gen byte `id' = _n==_N & `touse'
	qui by `touse' `_byvars': gen `col0' = sum(`exp'*(1-`2')) if `touse'
	qui by `touse' `_byvars': replace `col0' = `col0'[_N] if `touse'
	qui by `touse' `_byvars': gen `col1' = sum(`exp'*`2') if `touse'
	qui by `touse' `_byvars': replace `col1' = `col1'[_N] if `touse'
	qui by `touse' `_byvars': gen `Ncat' = sum(`iid') if `touse'
	qui by `touse' `_byvars': replace `Ncat' = `Ncat'[_N] if `touse'
	if "`weight'"=="fweight" {
		qui gen `Nobs' = `col0' + `col1' if `touse'
	}
	else {
		qui by `touse' `_byvars': gen `Nobs' = _N if `touse'
	}

//compute summands
	tempvar sum
	qui gen `sum' = 0.5 * abs( `cell0'/`col0' - `cell1'/`col1' )
	drop `cell0' `col0' `cell1' `col1'

//compute D
	tempvar D
	qui by `touse' `_byvars': gen `D' = sum(`sum') if `iid'
	qui by `touse' `_byvars': replace `D' = `D'[_N] if `iid'
*	drop `sum' `iid'

//display
	lab var `D' "Dissimilarity"
	lab var `Ncat' "Categories"
	lab var `Nobs' "Observations"
	if "`_byvars'"=="" {
		local labl: var l `2'
		if `"`labl'"'=="" local labl "`2'"
		lab var `touse' `"`labl'"'
		qui tostring `touse', replace
		qui replace `touse' = "0/1"
		tabdisp `touse' if `id', cell(`D' `Ncat' `Nobs') `format'
	}
	else {
		tabdisp `_byvars' if `id', cell(`D' `Ncat' `Nobs') `format'
	}

//returns
	if "`d'"!="" {
		qui replace `D' = . if !`id'
		rename `D' `d'
	}
	if "`ncat'"!="" {
		qui replace `Ncat' = . if !`id'
		rename `Ncat' `ncat'
	}
	if "`nobs'"!="" {
		qui replace `Nobs' = . if !`id'
		rename `Nobs' `nobs'
	}
	if "`dj'"!="" {
		qui replace `sum' = . if !`iid'
		rename `sum' `dj'
	}

end
