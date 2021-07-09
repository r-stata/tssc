*! version 1.0.0  10dec2013
program smvcir_p
	version 13.0
        if "`e(cmd)'" != "smvcir" {
                error 301
        }
	syntax [anything] [if] [in] [, COordinates]
	local k = e(k)
	_stubstar2names `anything', nvars(`k')
	local typlist `s(typlist)'
	local varlist `s(varlist)'

	marksample touse, novarlist
	forvalues i = 1/`k' {
		tempvar smvcir`i'
		qui gen double `smvcir`i'' = .
		local smvcirlist `"`smvcirlist' `smvcir`i''"'
	}

        // transform data
	local i = 1
	tempname m Sndiag
	matrix `m' = e(m)
	matrix `Sndiag' = e(Sndiag)
	
	foreach var of varlist `e(predictors)' {
		tempvar std_`var'
		gen double `std_`var'' = (`var'-`m'[`i',1])* ///
			`Sndiag'[`i',`i'] if `touse'
		local stdpreds `stdpreds' `std_`var''
		local i = `i' + 1
	}
	if ("`e(noeigen)'" != "noeigen") {
		local evpassin 2_eigvecs
	}
	else {
		local evpassin _U
	}
        mata: st_store(., tokens(`"`smvcirlist'"'), 		///
			`"`touse'"',				///
			st_data(.,tokens(`"`stdpreds'"'), 	///
			"`touse'")*st_matrix("e(Spanset`evpassin')"))

	forvalues i = 1/`k' {
		local t`i': word `i' of `typlist'
		local v`i': word `i' of `varlist'
		local s`i': word `i' of `smvcirlist'
		gen `t`i'' `v`i'' = `s`i'' if `touse'
		label variable `v`i'' "SMVCIR `i'"
	}
end
exit
