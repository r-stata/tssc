*! version 1.0.2, Ben Jann, 13jun2005
program define invcdf, byable(onecall) sort
	version 8.2
	syntax varname(numeric) [if] [in] [fw aw] , Reference(str) Generate(name) [ cdf(varname) ]
	marksample touse
	confirm new var `generate'
	capt assert inrange(`varlist',0,1) if `touse'
	if _rc {
		di as error "`varlist' not in [0,1]"
		exit 459
	}
	gettoken refvar refif: reference
	if _by() local by "by `_byvars':"
	if "`cdf'"=="" {
		tempvar cdf
		`by' cumul `refvar' `refif' [`weight'`exp'] , generate(`cdf') equal
	}
	else {
		capt assert inrange(`cdf',0,1) | ( `cdf'>=. & `refvar'>=. ) `refif'
		if _rc {
			di as error "`cdf' not in [0,1] or is incomplete"
			exit 459
		}
	}
	quietly {
		nobreak {
			tempvar id x u
			gen `: type `refvar'' `generate' = `refvar' `refif'
			expand 2 if `generate'<. & `touse'
			sort `_sortindex'
			by `_sortindex': gen byte `id' = _n
			replace `touse' = 0 if `id'==2
			replace `generate' = . if `touse'
			gen `: type `refvar'' `u' = `refvar' if `generate'<.
			gen `: type `varlist'' `x' = 1 - `varlist' if `touse'
			replace `x' = 1 - `cdf' if `generate'<. & !`touse'
			replace `generate' = -`generate' if `generate'<.
			sort `_byvars' `x' `id' `generate'
			`by' replace `u' = `u'[_n-1] if `touse'
			replace `x' = 1 - `x'
			replace `generate' = -`generate' if `generate'<.
			sort `_byvars' `x' `touse' `generate'
			`by' replace `generate' = `generate'[_n-1] if `x'==`x'[_n-1] & `touse'
			`by' replace `generate' = cond( `generate'>=. , `u' , ///
			     cond( `u'>=. , `generate', (`generate'+`u')/2 ) ) if `touse'
			replace `generate' = . if !`touse'
			drop if `id'==2
		}
	}
end
