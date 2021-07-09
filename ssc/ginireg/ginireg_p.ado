*! ginreg_p 1.0.0 26Aug2013
*! author mes

program define ginireg_p
	version 10.1
	syntax newvarname [if] [in] , [XB Residuals stdp]
	marksample touse, novarlist

	local type "`xb'`residuals'`stdp'"

	if "`type'"=="" {
		local type "xb"
di in gr "(option xb assumed; fitted values)"
	}


	if "`type'" == "residuals" {
		tempname lhs lhs_t xb
		local lhs "`e(depvar)'"
		tsrevar `lhs', substitute
		local lhs_t "`r(varlist)'"
		qui _predict `typlist' `xb' if `touse'
		gen `typlist' `varlist'=`lhs_t'-`xb'
		label var `varlist' "Residuals"
	}
* Must be either xb or stdp
	else {
		_predict `typlist' `varlist' if `touse', `type'
	}

end
