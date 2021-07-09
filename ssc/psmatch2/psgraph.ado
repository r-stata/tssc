*! version 1.0.2 17dec2008 E. Leuven, B. Sianesi
program define psgraph
version 8.0
syntax [iweight] [, BIN(integer 20) Treated(varname) SUPport(varname) Pscore(varname) *]

	if "`weight'" != "" {
		local wgt "[`weight'`exp']"
	}

	if `bin'<2 {
		di as error "Error: bin must be larger than 2"
		exit 198
	}

	capture confirm var _treated
	if _rc & "`treated'"=="" {
		di as error "Error: provide treatment indicator variable"
		exit 198
	}
	else if !_rc & "`treated'"=="" {
		tempvar treated
		qui g double `treated' = _treated
	}

	if ("`support'"=="") {
		tempvar support
		capture confirm var _support
		if _rc {
			qui g byte `support' = 1
		}
		else qui g byte `support'= _support
	}
	
	capture confirm var _pscore
	if _rc & "`pscore'"=="" {
		di as error "Error: provide propensity score"
		exit 198
	}
	else if !_rc & "`pscore'"=="" {
		tempvar pscore
		qui g double `pscore' = _pscore
	}

	cap assert `treated'==1 | `treated'==0 | `treated'==.
	if _rc {
		di as error "Error: treatment indicator variable should take on values 0, 1 (and missing)"
		exit 198
	}

	marksample touse
	capture markout `touse' `pscore' `treated'

	preserve

	quietly {
		tempvar pbin
		g `pbin' = autocode(`pscore', `bin', 0, 1)
		replace `pbin' = `pbin' - (1/(2*`bin'))

		collapse (count) `pscore' `wgt' if `touse' , by(`pbin' `treated' `support')
		tempvar t s
		egen `s' = sum(`pscore'), by(`treated')
		replace `pscore' = `pscore'/`s'
		g `t' = 10*`treated' + `support'
		
		drop `treated' `support' `s'
		
		reshape wide `pscore', i(`pbin') j(`t')
		mvencode `pscore'*, mv(0) override

    // controls off support (may not exist)
		cap replace `pscore'0 = -`pscore'0 - `pscore'1
		// controls on support
		replace `pscore'1 = -`pscore'1
		cap replace `pscore'10 = `pscore'10 + `pscore'11

		local w = 0.8/`bin' // bar width

		local l1 "label(1 `"Untreated"')"
		local l2 "label(2 `"Treated"')"

		cap confirm var `pscore'0
		if !_rc {
			local vlist0 "(rbar  `pscore'1 `pscore'0 `pbin', barw(`w'))"
			local l1 "label(1 `"Untreated: Off support"')"
			local l2 "label(2 `"Untreated: On support"')"
			local l3 "label(3 `"Treated"')"
		}

		cap confirm var `pscore'10
		if (!_rc) {
			local vlist1 "(rbar `pscore'10 `pscore'11 `pbin', barw(`w'))"
			if ("`l3'"=="") {
				local l2 "label(2 `"Treated: On support"')"
				local l3 "label(3 `"Treated: Off support"')"
			}
			else {
				local l3 "label(3 `"Treated: On support"')"
				local l4 "label(4 `"Treated: Off support"')"
			}
		}

	}
	tempvar zero
	g `zero' = 0
	twoway `vlist0' ///
		   (rbar `pscore'1 `zero' `pbin', barw(`w')) ///
		   (rbar `pscore'11 `zero' `pbin', barw(`w')) ///
		   `vlist1' ,  ///
		   yline(0, lstyle(foreground) extend) ///
		   ylabel(none) xtitle("Propensity Score") ytitle("") ///
		   legend(`l1' `l2' `l3' `l4')  `options'

	restore

end

