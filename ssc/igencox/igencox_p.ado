*! version 1.0.0  12dec2011
program define igencox_p, sortpreserve
	version 12, missing
	
	syntax [anything] [if] [in] [, 			///
		XB					///
		STDP					///
		BASESurv 				///
		SURVival				///
		BASEChazard				///
		CUMHaz 					///
		at(string)				///
		se(string)				///
		*					///
		]
	
	if (`"`options'"'!="") {
		di as err `"`options' not allowed"'
		exit 198
	}
	
	// at() allowed only with survival and cumhaz
	if "`at'"!="" & "`survival'`cumhaz'"=="" {
		di "{err}option at() allowed only with {bf:survival} or {bf:cumhaz}"
		exit 198
	}
	
	// se() allowed only with basesurv and survival
	if "`se'"!="" & "`basesurv'`survival'"=="" {
		di "{err}option se() allowed only with {bf:basesurv} or {bf:survival}"
		exit 198
	}
	
	// only one predict option allowed
	local propt "`xb' `stdp' `basesurv' `survival' `basechazard' `cumhaz'"
	local propt = trim(itrim("`propt'"))
	local w : word count `propt'
	if `w' > 1 {
		di "{err}only one of {bf:`propt'} is allowed"
		exit 198
	}
		
	// concatenate switch options together
	local type "`basesurv'`survival'`basechazard'`cumhaz'"
	local args `"`xb'`stdp'"'
	
	if ("`type'`args'"=="") {
		local args xb
		di as txt "(option xb assumed; fitted values)"
	}
	if "`args'"!="" {
		_predict `anything' `if' `in', `args'
		exit
	}

	// check <anything>
	local k : word count `anything'
	if (`k'>3) {
		di as err "varlist not allowed"
		exit 101
	}
        if (`k'==2) {
		tokenize `anything'
                local vtyp `1'
                local varn `2'
        }
        else {
                local vtyp float
                local varn `anything'
        }

	if "`type'"!="" & "`e(baseq)'" == "" {
di "{err}cannot calculate predicted values, e(baseq) not set;"
di "{err}you should specify option {bf:baseq()} with {bf:igencox}"
exit 198
	}
	else if ("`type'"!="") {
		confirm variable `e(baseq)'
	}
		
	if `"`se'"' != `""' {
		if `"`e(sigma)'"'==`""' {
di "{err}cannot calculate standard errors, e(sigma) not set;"
di "{err}you should specify option {bf:savesigma()} with {bf:igencox}"
exit 198
		}
		confirm new variable `se', exact
		confirm file `"`e(sigma)'"'
	}
	
	// mark sample - this is not e(sample)
	marksample touse
	
	tempvar esample
	qui gen byte `esample' = e(sample)
	if `"`if'`in'"' == `""' qui replace `touse' = e(sample)
	capture assert `touse'==`esample'
	if _rc {
di "{err}{cmd:`type'} must be calculated for the estimation sample"
exit 198
	}
	
	qui replace `esample' = `touse'*_d
	
	tempname b omz
	mat `b' = e(b)
	_ms_omit_info `b'
	mat `omz' = r(omit)
	
	// handle switch options
	if "`type'"=="basesurv" {
		qui gen `vtyp' `varn' = .
		label var `varn' "Baseline survivor function"
		if "`se'"!="" {
			qui gen double `se' = .
			label var `se' "Std. err. of baseline survivor function"
		}
		mata: igencox_em_predict("`varn'","`esample'")
		if "`se'"!="" {
			qui gsort _t -`varn'
			qui replace `varn' = `varn'[_n-1] if `varn'==. & `touse'
			qui replace `se' = `se'[_n-1] if `se'==. & `touse'
		}
		exit
	}
	
	if "`type'"=="survival" {
		qui gen `vtyp' `varn' = .
		label var `varn' "Survivor function"
		if "`se'"!="" {
			qui gen double `se' = .
			label var `se' "Std. err. of survivor function"
		}
		mata: igencox_em_predict("`varn'","`esample'")
		if "`se'"!="" {
			qui gsort _t -`varn'
			qui replace `varn' = `varn'[_n-1] if `varn'==. & `touse'
			qui replace `se' = `se'[_n-1] if `se'==. & `touse'
		}
		exit
	}
	
	if "`type'"=="basechazard" {
		qui sort _t
		qui gen `vtyp' `varn' = .
		label var `varn' "Baseline cumulative hazard function"
		mata: igencox_em_predict("`varn'","`esample'")
		qui gsort _t -`varn'
		qui replace `varn' = `varn'[_n-1] if `varn'==. & `touse'
		exit
	}
	
	if "`type'"=="cumhaz" {
		qui sort _t
		qui gen `vtyp' `varn' = .
		label var `varn' "Cumulative hazard function"
		mata: igencox_em_predict("`varn'","`esample'")
		qui gsort _t -`varn'
		qui replace `varn' = `varn'[_n-1] if `varn'==. & `touse'
		exit
	}
	
	error 198
end
exit
