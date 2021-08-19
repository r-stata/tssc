*! version 1.0 9jul2021
*! See end of ado file for version history

program define hetsar_p, sortpreserve

	version 10

	syntax [anything] [if] [in] [, 			   ///
			RForm 				   ///  default
			NAive				   ///
			RESiduals ///
			]

	local vvcheck = max(10,c(stata_version))

	marksample touse 	// this is not e(sample)
	tempvar esample
	qui gen byte `esample' = (e(sample) & `touse')

	*** Check for panel setup
	_xt, trequired
	local id: char _dta[_TSpanel]
	local time: char _dta[_TStvar]
	tempvar temp_id temp_t
	qui egen `temp_id'=group(`id') if `esample'==1
	sort `temp_id' `time'
	qui by `temp_id': g `temp_t' = _n if `esample'==1

	ParseStats stat stat_res : `"`rform' `naive' `residuals'"'

	gettoken type pvar : anything
	qui generate `type' `pvar' = .
	if "`pvar'"=="" local pvar `type'

	*** Sort data to get the same ordering in _hetsar_predict()
	sort `temp_t' `temp_id'

	m _hetsar_predict("`pvar'",r,"`stat'","`stat_res'")

	if "`stat_res'"=="" {
		if "`stat'"=="rform" label var `pvar' "Reduced form fitted values"
		if "`stat'"=="naive" label var `pvar' "Naive fitted values"
	}
	else {
		if "`stat'"=="rform" label var `pvar' "Reduced form residuals"
		if "`stat'"=="naive" label var `pvar' "Naive residuals"
	}

end



program define ParseStats
	args returmac returmac_res colon stat

	local 0 ", `stat'"
	syntax [, RForm NAive RESiduals * ]

	if `"`options'"' != "" {
		di as error "`options' not allowed"
		exit 198
	}

	local wc : word count `rform' `naive'

	if `wc' > 1 {
		di as error "rform and naive are mutually exclusive."
		exit 198
	}

	if `wc' == 0 {
		c_local `returmac' rform
		c_local `returmac_res' `residuals'
	}
	else {
		c_local `returmac' `rform' `naive'
		c_local `returmac_res' `residuals'
	}

end

exit

*! version 1.0 10oct2012
*! version 1.1 23jan2013 - Bug fixes
*! version 1.2 12feb2013 - Check for banded matrices added
*! version 1.3 14may2013 - The command gives now an error when fixed-effects postestimation and type(time) or type(both)
*! version 1.4 10may2016 - Added -full- option to compute full information prediction aftre SAC
*! version 1.5 27jun2016 - Added -noie- to allow predictions without individual effects
*! version 1.6 12sep2016 - Not documented: Added direct, indirect and total (also in lr versions) to allow delta-method se computation
