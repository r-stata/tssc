/* Programme to re-sample the data respecting survey desing
R.E. De Hoyos and Jaime Ruiz-Tagle, University of Cambridge */

program define svybsamp2, sortpreserve
version 8

	_svy_newrule , `weight' `strata' `psu' `fpc'

	syntax [anything] [if] [in]	

	qui {
	tempvar str fstr fpsu
	svydes
	g `fpsu' = _n
	local nstr = `r(N_strata)'
	svyset
	if "`r(strata)'"=="" {
		g `str' = 1
	}
	else {
		g `str' = `r(strata)'
	}
	if "`r(psu)'" == "" {
		noi di in red "PSU is equal to the number of observations, svybsamp2 is not necessary. Use -bsample-"
		exit 198
	}
	else {
		g `fstr' = `r(psu)'
	}
	tempvar str_id
	egen `str_id' = group(`str')
	sort `str_id'
	preserve
	keep if `str_id'==1
	bsample, strata(`fstr') cluster(`fpsu')
	tempfile base
	save `base'
	local i=2
	while `i'<=`nstr' {
		restore, preserve
		keep if `str_id'==`i'
		bsample, strata(`fstr') cluster(`fpsu')
		append using `base'
		save `base', replace
		local i=`i'+1
	}
	restore, not
	}
end
		
	
