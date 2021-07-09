*! nehurdle_p v1.0.0
*! 09 August 2017
*! Alfonso Sanchez-Penalver

/*******************************************************************************
*	Program that collects -predict- options after nehurdle					   *
*******************************************************************************/

// DISTRIBUTION
capture program drop nehurdle_p
program define nehurdle_p
	version 11
	if "`e(cmd_opt)'" == "trunc"												///
		nehurdle_trunc_p `0'
	else if "`e(cmd_opt)'" == "tobit"											///
		nehurdle_tobit_p `0'
	else if "`e(cmd_opt)'" == "heckman"											///
		nehurdle_heckman_p `0'
	else {
		di as error "No valid predict command"
		exit 198
	}
end

// TRUNCATED
capture program drop nehurdle_trunc_p
program define nehurdle_trunc_p, eclass
	syntax anything(id="newvarname") [if] [in]									///
	[, {																		///
		YCen		|															///
		RESCen		|															///
		YTrun		|															///
		RESTrun		|															///
		XBVal		|															///
		RESVal		|															///
		PSel		|															///
		RESSel		|															///
		SCores		|															///
		XBSel		|															///
		XBSIG		|															///
		SIGma		|															///
		SELSIGma	|															///
		XBSELSig																///
	} * ]
	
	if "`scores'" != "" {
		local bvar "`e(depvar)'"
		tempvar dy y1
		quiet gen byte `dy' = `bvar' > 0
		if "`e(est_model)'" == "exponential" 									///
			quiet gen double `y1' = ln(`bvar')
		else quiet gen double `y1' = `bvar'
		ereturn local depvar "`dy' `y1'"
		
		marksample touse
		marksample touse2
		local xvars : colna e(b)
		local cons _cons _cons _cons _cons
		local xvars : list xvars - cons
		markout `touse2' `xvars'
		quietly replace `touse' = 0 if `dy' & !`touse2'
		ml score `anything' if `touse', `scores' missing `options'
		ereturn local depvar "`bvar'"
		exit
	}
	
	local myopts "YCen RESCen YTrun RESTrun XBVal RESVal PSel RESSel XBSel"
	local myopts "`myopts' XBSIG SIGma SELSIGma XBSELSig"
	_pred_se "`myopts'" `0'
	if `s(done)' exit
	local vtyp  `s(typ)'
	local varn `s(varn)'
	local 0 `"`s(rest)'"'
	
	// ycen is the default and is done last
	if "`rescen'" != "" {
		tempvar zg selsig sig
		_predict `vtyp' `zg' `if' `in', equation(#1)
		_predict `vtyp' `varn' `if' `in', equation(#2)
		if "`e(selhet)'" != "" {
			_predict `vtyp' `selsig' `if' `in', equation(#3)
			quiet replace `selsig' = exp(`selsig') `if' `in'
			_predict `vtyp' `sig' `if' `in', equation(#4)
		}
		else {
			quiet generate `vtyp' `selsig' = 1 `if' `in'
			_predict `vtyp' `sig' `if' `in', equation(#3)
		}
		quiet replace `sig' = exp(`sig')
		if "`e(est_model)'" == "linear"											///
			quiet replace `varn' = `varn' + `sig' * normalden(`varn' / ///
				`sig') / normal(`varn' / `sig') `if' `in'
		else quiet replace `varn' = exp(`varn' + `sig'^2 / 2) `if' `in'
		quiet replace `varn' = `e(depvar)' -  normal(`zg' / `selsig') *		///
			`varn' `if' `in'
		label var `varn' "Residuals of censored mean E(`e(depvar)'|x,z)"
		exit
	}
	if "`ytrun'" != "" {
		tempvar sig
		_predict `vtyp' `varn' `if' `in', equation(#2)
		if "`e(selhet)'" != "" local eqnum = 4
		else local eqnum = 3
		_predict `vtyp' `sig' `if' `in', equation(#`eqnum')
		quiet replace `sig' = exp(`sig') 
		if "`e(est_model)'" == "linear"											///
			quiet replace `varn' = `varn' + `sig' * normalden(`varn' / ///
				`sig') / normal(`varn' / `sig') `if' `in'
		else quiet replace `varn' = exp(`varn' + `sig'^2 / 2) `if' `in'
		label var `varn' "Prediction of truncated mean E(`e(depvar)'|x,z,`e(depvar)' > 0)"
		exit
	}
	if "`restrun'" != "" {
		tempvar sig
		_predict `vtyp' `varn' `if' `in', equation(#2)
		if "`e(selhet)'" != "" local eqnum = 4
		else local eqnum = 3
		_predict `vtyp' `sig' `if' `in', equation(#`eqnum')
		quiet replace `sig' = exp(`sig') 
		if "`e(est_model)'" == "linear"											///
			quiet replace `varn' = `varn' + `sig' * normalden(`varn' / ///
				`sig') / normal(`varn' / `sig') `if' `in'
		else quiet replace `varn' = exp(`varn' + `sig'^2 / 2) `if' `in'
		quiet replace `varn' = `e(depvar)' - `varn' `if' `in'
		label var `varn' "Residuals of truncated mean E(`e(depvar)'|x,z,`e(depvar)' > 0)"
		exit
	}
	if "`xbval'" != "" {
		_predict `vtyp' `varn' `if' `in', equation(#2)
		if "`e(est_model)'" == "linear"											///
			label var `varn' "Linear prediction of uncensored mean E(`e(depvar)'*|x)"
		else																	///
			label var `varn' "Linear prediction of uncensored mean E(ln(`e(depvar)')*|x)"
		exit
	}
	if "`resval'" != "" {
		_predict `vtyp' `varn' `if' `in', equation(#2)
		if "`e(est_model)'" == "linear"	{
			quiet replace `varn' = `e(depvar)' - `varn' `if' `in'
			label var `varn' "Residual of uncensored mean E(`e(depvar)'*|x)"
		}
		else {
			quiet replace `varn' = ln(`e(depvar)') - `varn' `if' `in'
			label var `varn' "Residual of uncensored mean E(ln(`e(depvar)')*|x)"
		}
		exit
	}
	if "`psel'" != "" {
		tempvar selsig
		_predict `vtyp' `varn' `if' `in', equation(#1)
		if "`e(selhet)'" != "" {
			_predict `vtyp' `selsig' `if' `in', equation(#3)
			quiet replace `selsig' = exp(`selsig') `if' `in'
		}
		else quiet generate `vtyp' `selsig' = 1 `if' `in'
		quiet replace `varn' = normal(`varn' / `selsig') `if' `in'
		label var `varn' "Prediction of Pr(`e(depvar)' > 0|z)"
		exit
	}
	if "`ressel'" != "" {
		tempvar selsig dy
		quiet gen byte `dy' = `e(depvar)' > 0
		_predict `vtyp' `varn' `if' `in', equation(#1)
		if "`e(selhet)'" == "" {
			_predict `vtyp' `selsig' `if' `in', equation(#3)
			quiet replace `selsig' = exp(`selsig') `if' `in'
		}
		else quiet generate `vtyp' `selsig' = 1 `if' `in'
		quiet replace `varn' = `dy' - normal(`varn' / `selsig') `if' `in'
		label var `varn' "Residuals of Pr(`e(depvar)' > 0|z)"
		exit
	}
	if "`xbsel'" != "" {
		_predict `vtyp' `varn' `if' `in', equation(#1)
		label var `varn' "Linear prediction of the selection"
		exit
	}
	if "`xbsig'" != "" {
		if "`e(selhet)'" != "" local eqn = 4
		else local eqn = 3
		_predict `vtyp' `varn' `if' `in', equation(#`eqn')
		label var `varn' "Linear prediction of ln(SE)"
		exit
	}
	if "`sigma'" != "" {
		if "`e(selhet)'" != "" local eqnum = 4
		else local eqnum = 3
		_predict `vtyp' `varn' `if' `in', equation(#`eqnum')
		quiet replace `varn' = exp(`varn') `if' `in'
		label var `varn' "Prediction of SE"
		exit
	}
	if "`selsigma'" != "" {
		if "`e(selhet)'" == "" {
			di as error "{bf: selsigma} not valid"
			exit 198
		}
		_predict `vtyp' `varn' `if' `in', equation(#3)
		quiet replace `varn' = exp(`varn') `if' `in'
		label var `varn' "Prediction of selection SE"
		exit
	}
	if "`xbselsig'" != "" {
		if "`e(selhet)'" == ""{
			di as error "{bf:selsigxb} not valid"
			exit 198
		}
		_predict `vtyp' `varn' `if' `in', equation(#3)
		label var `varn' "Linear prediction of selection ln(SE)"
		exit
	}
	// The default is ycen
	if "`ycen'" == "" noi di as txt "(option ycen assumed)"
	tempvar zg selsig sig
	_predict `vtyp' `zg' `if' `in', equation(#1)
	_predict `vtyp' `varn' `if' `in', equation(#2)
	if "`e(selhet)'" != "" {
		_predict `vtyp' `selsig' `if' `in', equation(#3)
		quiet replace `selsig' = exp(`selsig') `if' `in'
		_predict `vtyp' `sig' `if' `in', equation(#4)
	}
	else {
		quiet generate `vtyp' `selsig' = 1 `if' `in'
		_predict `vtyp' `sig' `if' `in', equation(#3)
	}
	quiet replace `sig' = exp(`sig')
	if "`e(est_model)'" == "linear"												///
		quiet replace `varn' = `varn' + `sig' * normalden(`varn' / `sig') /		///
		normal(`varn' / `sig') `if' `in'
	else quiet replace `varn' = exp(`varn' + `sig'^2 / 2) `if' `in'
	quiet replace `varn' = normal(`zg' / `selsig') * `varn' `if' `in'
	label var `varn' "Prediction of censored mean E(`e(depvar)'|x,z)"
end

// TOBIT
capture program drop nehurdle_tobit_p
program define nehurdle_tobit_p, eclass
	syntax anything(id="newvarname") [if] [in]									///
	[, {																		///
		YCen		|															///
		RESCen		|															///
		YTrun		|															///
		RESTrun		|															///
		XBVal		|															///
		RESVal		|															///
		PSel		|															///
		RESSel		|															///
		SCores		|															///
		XBSIG		|															///
		SIGma																	///
	} * ]
		
	if "`scores'" != "" {
		local bvar "`e(depvar)'"
		tempvar y1
		if "`e(est_model)'" == "exponential" 									///
			quiet gen double `y1' = ln(`bvar')
		else quiet gen double `y1' = `bvar'
		ereturn local depvar "`y1'"
		
		marksample touse
		marksample touse2
		local xvars : colna e(b)
		local cons _cons _cons _cons _cons
		local xvars : list xvars - cons
		markout `touse2' `xvars'
		quietly replace `touse' = 0 if `bvar' > 0 & !`touse2'
		ml score `anything' if `touse', `scores' missing `options'
		ereturn local depvar "`bvar'"
		exit
	}
	
	local myopts "YCen RESCen YTrun RESTrun XBVal RESVal PSel RESSel XBSIG SIGma"
	_pred_se "`myopts'" `0'
	if `s(done)' exit
	local vtyp  `s(typ)'
	local varn `s(varn)'
	local 0 `"`s(rest)'"'
	
	// ycen is the default so it will be done last.
	if "`rescen'" != "" {
		tempvar sig
		_predict `vtyp' `varn' `if' `in', equation(#1)
		_predict `vtyp' `sig' `if' `in', equation(#2)
		quiet replace `sig' = exp(`sig') `if' `in'
		if "`e(est_model)'" == "linear"	{
			quiet replace `varn' = normal(`varn'/`sig') *`varn' + `sig' *		///
				normalden(`varn' / `sig') `if' `in'
		}
		else {
			quiet replace `varn' = exp(`varn' + `sig'^2/2) *					///
				normal((`sig'^2 + `varn' - e(gamma))/`sig') `if' `in'
		}
		quiet replace `varn' = `e(depvar)' - `varn' `if' `in'
		label var `varn' "Residual of censored mean E(`e(depvar)'|x)"
		exit
	}
	if "`ytrun'" != "" {
		tempvar sig
		_predict `vtyp' `varn' `if' `in', equation(#1)
		_predict `vtyp' `sig' `if' `in', equation(#2)
		quiet replace `sig' = exp(`sig') `if' `in'
		if "`e(est_model)'" == "linear" {
			quiet replace `varn' = `varn' + `sig' * normalden(`varn' / `sig') /	///
				normal(`varn' / `sig') `if' `in'
		}
		else {
			quiet replace `varn' = exp(`varn' + `sig'^2/2) * normal((`sig'^2 +	///
				`varn' - e(gamma))/`sig') /	 normal((`varn' - e(gamma))/`sig')	///
				`if' `in'
		}
		label var `varn' "Prediction of truncated mean E(`e(depvar)'|x,`e(depvar)' > 0)"
		exit
	}
	if "`restrun'" ! = "" {
		// The first set of code is identical to the one in YTRUN. Remember to
		// change if you change that
		tempvar sig
		_predict `vtyp' `varn' `if' `in', equation(#1)
		_predict `vtyp' `sig' `if' `in', equation(#2)
		quiet replace `sig' = exp(`sig') `if' `in'
		if "`e(est_model)'" == "linear" {
			quiet replace `varn' = `varn' + `sig' * normalden(`varn' / `sig') /	///
				normal(`varn' / `sig') `if' `in'
		}
		else {
			quiet replace `varn' = exp(`varn' + `sig'^2/2) * normal((`sig'^2 +	///
				`varn' - e(gamma))/`sig') /	 normal((`varn' - e(gamma))/`sig')	///
				`if' `in'
		}
		quiet replace `varn' = `e(depvar)' - `varn' `if' `in'
		label var `varn' "Residuals of truncated mean E(`e(depvar)'|x,`e(depvar)' > 0)"
		exit
	}
	if "`xbval'" != "" {
		_predict `vtyp' `varn' `if' `in', equation(#1)
		if "`e(est_model)'" == "linear"											///
			label var `varn' "Linear prediction of uncensored mean E(`e(depvar)'*|x)"
		else																	///
			label var `varn' "Linear prediction of uncensored mean E(ln(`e(depvar)')*|x)"
		exit
	}
	if "`resval'" != "" {
		_predict `vtyp' `varn' `if' `in', equation(#1)
		if "`e(est_model)'" == "linear"	{
			quiet replace `varn' = `e(depvar)' - `varn' `if' `in'
			label var `varn' "Residual of uncensored mean E(`e(depvar)'*|x)"
		}
		else {
			quiet replace `varn' = ln(`e(depvar)') - `varn' `if' `in'
			label var `varn' "Residual of uncensored mean E(ln(`e(depvar)')*|x)"
		}
		exit
	}
	if "`psel'" != "" {
		tempvar sig
		_predict `vtyp' `varn' `if' `in', equation(#1)
		_predict `vtyp' `sig' `if' `in', equation(#2)
		quiet replace `sig' = exp(`sig') `if' `in'
		quiet replace `varn' = normal(`varn'/`sig')
		label var `varn' "Prediction of Pr(`e(depvar)' > 0|x)"
		exit
	}
	if "`ressel'" != "" {
		tempvar sig dy
		quiet gen byte `dy' = `e(depvar)' > 0
		_predict `vtyp' `varn' `if' `in', equation(#1)
		_predict `vtyp' `sig' `if' `in', equation(#2)
		quiet replace `sig' = exp(`sig') `if' `in'
		quiet replace `varn' = `dy' - normal(`varn'/`sig')
		label var `varn' "Residual of Pr(`e(depvar)' > 0|x)"
		exit
	}
	if "`xbsig'" != "" {
		_predict `vtyp' `varn' `if' `in', equation(#2)
		label var `varn' "Linear prediction of ln(SE)"
		exit
	}
	if "`sigma'" != "" {
		_predict `vtyp' `varn' `if' `in', equation(#2)
		quiet replace `varn' = exp(`varn') `if' `in'
		label var `varn' "Prediction of SE"
		exit
	}
	// ycen is the default
	if "`ycen'" == "" noi di as txt "(option ycen assumed)"
	tempvar sig
	_predict `vtyp' `varn' `if' `in', equation(#1)
	_predict `vtyp' `sig' `if' `in', equation(#2)
	quiet replace `sig' = exp(`sig') `if' `in'
	if "`e(est_model)'" == "linear" {
		quiet replace `varn' = normal(`varn'/`sig') *`varn' + `sig' *			///
			normalden(`varn' / `sig') `if' `in'
	}
	else {
		quiet replace `varn' = exp(`varn' + `sig'^2/2) * normal((`sig'^2 +		///
			`varn' - e(gamma))/`sig') `if' `in'
	}
	label var `varn' "Prediction of censored mean E(`e(depvar)'|x)"
end

// HECKMAN
capture program drop nehurdle_heckman_p
program define nehurdle_heckman_p, eclass
	syntax anything(id="newvarname") [if] [in]									///
	[, {																		///
		YCen		|															///
		RESCen		|															///
		YTrun		|															///
		RESTrun		|															///
		XBVal		|															///
		RESVal		|															///
		PSel		|															///
		RESSel		|															///
		SCores		|															///
		XBSel		|															///
		XBSIG		|															///
		SIGma		|															///
		SELSIGma	|															///
		XBSELSig	|															///
		LAMbda																	///
	} * ]
	
	if "`scores'" != "" {
		local bvar "`e(depvar)'"
		tempvar dy y1
		quiet gen byte `dy' = `bvar' > 0
		if "`e(est_model)'" == "exponential" 									///
			quiet gen double `y1' = ln(`bvar')
		else quiet gen double `y1' = `bvar'
		ereturn local depvar "`dy' `y1'"
		
		marksample touse
		marksample touse2
		local xvars : colna e(b)
		local cons _cons _cons _cons _cons
		local xvars : list xvars - cons
		markout `touse2' `xvars'
		quietly replace `touse' = 0 if `dy' & !`touse2'
		ml score `anything' if `touse', `scores' missing `options'
		ereturn local depvar "`bvar'"
		exit
	}
	
	local myopts "YCen RESCen YTrun RESTrun XBVal RESVal PSel RESSel XBSel"
	local myopts "`myopts' XBSIG SIGma SELSIGma XBSELSig LAMbda"
	_pred_se "`myopts'" `0'
	if `s(done)' exit
	local vtyp  `s(typ)'
	local varn `s(varn)'
	local 0 `"`s(rest)'"'
	
	// ycen is the default and is done last
	if "`rescen'" != "" {
		tempvar zg selsig sig rho
		_predict `vtyp' `zg' `if' `in', equation(#1)
		_predict `vtyp' `varn' `if' `in', equation(#2)
		if "`e(selhet)'" != "" {
			_predict `vtyp' `selsig' `if' `in', equation(#3)
			quiet replace `selsig' = exp(`selsig') `if' `in'
			_predict `vtyp' `sig' `if' `in', equation(#4)
			_predict `vtyp' `rho' `if' `in', equation(#5)
		}
		else {
			quiet generate `vtyp' `selsig' = 1 `if' `in'
			_predict `vtyp' `sig' `if' `in', equation(#3)
			_predict `vtyp' `rho' `if' `in', equation(#4)
		}
		quiet replace `sig' = exp(`sig') `if' `in'
		quiet replace `rho' = tanh(`rho') `if' `in'
		if "`e(est_model)'" == "linear"											///
			quiet replace `varn' = `varn' + `sig' * `rho' *				///
			normalden(`zg' / `selsig') / normal(`zg' / `selsig') `if' `in'
		else																	///
			quiet replace `varn' = exp(`varn' + `sig'^2 / 2) *			///
				normal(`zg' / `selsig' + `rho' * `sig') / normal(`zg' /			///
				`selsig') `if' `in'
		quiet replace `varn' = `e(depvar)' - normal(`zg' / `selsig') *		///
			`varn' `if' `in'
		label var `varn' "Residual of censored mean E(`e(depvar)'|x,z)"
		exit
	}
	if "`ytrun'" != "" {
		tempvar zg selsig sig rho
		_predict `vtyp' `zg' `if' `in', equation(#1)
		_predict `vtyp' `varn' `if' `in', equation(#2)
		if "`e(selhet)'" != "" {
			_predict `vtyp' `selsig' `if' `in', equation(#3)
			quiet replace `selsig' = exp(`selsig') `if' `in'
			_predict `vtyp' `sig' `if' `in', equation(#4)
			_predict `vtyp' `rho' `if' `in', equation(#5)
		}
		else {
			quiet generate `vtyp' `selsig' = 1 `if' `in'
			_predict `vtyp' `sig' `if' `in', equation(#3)
			_predict `vtyp' `rho' `if' `in', equation(#4)
		}
		quiet replace `sig' = exp(`sig') `if' `in'
		quiet replace `rho' = tanh(`rho') `if' `in'
		if "`e(est_model)'" == "linear"											///
			quiet replace `varn' = `varn' + `sig' * `rho' *	 normalden(`zg' /	///
			`selsig') / normal(`zg' / `selsig') `if' `in'
		else																	///
			quiet replace `varn' = exp(`varn' + `sig'^2 / 2) *			///
				normal(`zg' / `selsig' + `rho' * `sig') / normal(`zg' /			///
				`selsig') `if' `in'
		label var `varn' "Prediction of truncated mean E(`e(depvar)'|x,z,`e(depvar)' > 0)"
		exit
	}
	if "`restrun'" != "" {
		tempvar zg selsig sig rho
		_predict `vtyp' `zg' `if' `in', equation(#1)
		_predict `vtyp' `varn' `if' `in', equation(#2)
		if "`e(selhet)'" != "" {
			_predict `vtyp' `selsig' `if' `in', equation(#3)
			quiet replace `selsig' = exp(`selsig') `if' `in'
			_predict `vtyp' `sig' `if' `in', equation(#4)
			_predict `vtyp' `rho' `if' `in', equation(#5)
		}
		else {
			quiet generate `vtyp' `selsig' = 1 `if' `in'
			_predict `vtyp' `sig' `if' `in', equation(#3)
			_predict `vtyp' `rho' `if' `in', equation(#4)
		}
		quiet replace `sig' = exp(`sig') `if' `in'
		quiet replace `rho' = tanh(`rho') `if' `in'
		if "`e(est_model)'" == "linear"											///
			quiet replace `varn' = `varn' + `sig' * `rho' *				///
			normalden(`zg' / `selsig') / normal(`zg' / `selsig') `if' `in'
		else																	///
			quiet replace `varn' = exp(`varn' + `sig'^2 / 2) *			///
				normal(`zg' / `selsig' + `rho' * `sig') / normal(`zg' /			///
				`selsig') `if' `in'
		quiet replace `varn' = `e(depvar)' - `varn' `if' `in'
		label var `varn' "Residual of truncated mean E(`e(depvar)'|x,z,`e(depvar)' > 0)"
		exit
	}
	if "`xbval'" != "" {
		_predict `vtyp' `varn' `if' `in', equation(#2)
		if "`e(est_model)'" == "linear"											///
			label var `varn' "Linear prediction of uncensored mean E(`e(depvar)'*|x)"
		else																	///
			label var `varn' "Linear prediction of uncensored mean E(ln(`e(depvar)')*|x)"
		exit
	}
	if "`resval'" != "" {
		_predict `vtyp' `varn' `if' `in', equation(#2)
		if "`e(est_model)'" == "linear"	{
			quiet replace `varn' = `e(depvar)' - `varn' `if' `in'
			label var `varn' "Residual of uncensored mean E(`e(depvar)'*|x)"
		}
		else {
			quiet replace `varn' = ln(`e(depvar)') - `varn' `if' `in'
			label var `varn' "Residual of uncensored mean E(ln(`e(depvar)')*|x)"
		}
		exit
	}
	if "`psel'" != "" {
		tempvar sig
		_predict `vtyp' `varn' `if' `in', equation(#1)
		if "`e(selhet)'" != "" {
			_predict `vtyp' `sig' `if' `in', equation(#3)
			quiet replace `sig' = exp(`sig') `if' `in'
		}
		else quiet generate `vtyp' `sig' = 1 `if' `in'
		quiet replace `varn' = normal(`varn' / `sig') `if' `in'
		label var `varn' "Prediction of Pr(`e(depvar)'> 0|z)"
		exit
	}
	if "`ressel'" != "" {
		tempvar sig dy
		gen byte `dy' = `e(depvar)' > 0
		_predict `vtyp' `varn' `if' `in', equation(#1)
		if "`e(selhet)'" != "" {
			_predict `vtyp' `sig' `if' `in', equation(#3)
			quiet replace `sig' = exp(`sig') `if' `in'
		}
		else quiet generate `vtyp' `sig' = 1 `if' `in'
		quiet replace `varn' = `dy' - normal(`varn' / `sig') `if' `in'
		label var `varn' "Residual of Pr(`e(depvar)' > 0|z)"
		exit
	}
	if "`xbsel'" != "" {
		_predict `vtyp' `varn' `if' `in', equation(#1)
		label var `varn' "Linear prediction of selection"
		exit
	}
	if "`xbsig'" != "" {
		if "`e(selhet)'" != "" local eqn = 4
		else local eqn = 3
		_predict `vtyp' `varn' `if' `in', equation(#`eqn')
		label var `varn' "Linear prediction of ln(SE)"
		exit
	}
	if "`sigma'" != "" {
		if "`e(selhet)'" != "" local eqn = 4
		else local eqn = 3
		_predict `vtyp' `varn' `if' `in', equation(#`eqn')
		quiet replace `varn' = exp(`varn') `if' `in'
		label var `varn' "Prediction of SE"
		exit
	}
	if "`selsigma'" != "" {
		if "`e(selhet)'" == "" {
			di as error "{bf:selsigma} not valid"
			exit 198
		}
		_predict `vtyp' `varn' `if' `in', equation(#3)
		quiet replace `varn' = exp(`varn') `if' `in'
		label var `varn' "Prediction of selection SE"
		exit
	}
	if "`xbselsig'" != "" {
		if "`e(selhet)'" == ""{
			di as error "{bf:selsigxb} not valid"
			exit 198
		}
		_predict `vtyp' `varn' `if' `in', equation(#3)
		label var `varn' "Linear prediction of selection ln(SE)"
		exit
	}
	if "`lambda'" != "" {
		tempvar rho
		if "`e(selhet)'" != "" {
			tempvar ss
			_predict `vtyp' `ss' `if' `in', equation(#3)
			_predict `vtyp' `varn' `if' `in', equation(#4)
			_predict `vtyp' `rho' `if' `in', equation(#5)
			quiet replace `varn' = exp(`ss') * exp(`varn') * tanh(`rho') `if' `in'
		}
		else {
			_predict `vtyp' `varn' `if' `in', equation(#3)
			_predict `vtyp' `rho' `if' `in', equation(#4)
			quiet replace `varn' = exp(`varn') * tanh(`rho') `if' `in'
		}
		label var `varn' "Prediction of coefficient on inverse mills ratio"
		exit
	}
	// ycen is the default
	if "`ycen'" == "" noi di as txt "(option ycen assumed)"
	tempvar zg selsig sig rho
	_predict `vtyp' `zg' `if' `in', equation(#1)
	_predict `vtyp' `varn' `if' `in', equation(#2)
	if "`e(selhet)'" != "" {
		_predict `vtyp' `selsig' `if' `in', equation(#3)
		quiet replace `selsig' = exp(`selsig') `if' `in'
		_predict `vtyp' `sig' `if' `in', equation(#4)
		_predict `vtyp' `rho' `if' `in', equation(#5)
	}
	else {
		quiet generate `vtyp' `selsig' = 1 `if' `in'
		_predict `vtyp' `sig' `if' `in', equation(#3)
		_predict `vtyp' `rho' `if' `in', equation(#4)
	}
	quiet replace `sig' = exp(`sig') `if' `in'
	quiet replace `rho' = tanh(`rho') `if' `in'
	if "`e(est_model)'" == "linear"											///
		quiet replace `varn' = `varn' + `sig' * `rho' *				///
		normalden(`zg' / `selsig') / normal(`zg' / `selsig') `if' `in'
	else																	///
		quiet replace `varn' = exp(`varn' + `sig'^2 / 2) *			///
			normal(`zg' / `selsig' + `rho' * `sig') / normal(`zg' /			///
			`selsig') `if' `in'
	quiet replace `varn' = normal(`zg' / `selsig') * `varn' `if' `in'
	label var `varn' "Prediction of censored mean E(`e(depvar)'|x,z)"
end

/*
// TWOPART LINEAR
capture program drop nehurdle_twopart_p
program define nehurdle_twopart_p
	syntax anything(id="newvarname") [if] [in]									///
	[,																			///
		XB																		///
		XBSel																	///
		XBSIGma2																///
		XBSELSIGma2																///
		YTrun																	///
		YTDuan																	///
		YStar																	///
		YSDuan																	///
		PSel																	///
		SIGma																	///
		SELSIGma																///
	]
	if "`xb'" != "" {
		syntax newvarname [if] [in] [, XB]
		_predict `typlist' `varlist' `if' `in', equation(#2)
		label var `varlist' "Prediction of latent mean E(y*)"
		exit
	}
	if "`xbsel'" != "" {
		syntax newvarname [if] [in] [, XBSel]
		_predict `typlist' `varlist' `if' `in', equation(#1)
		label var `varlist' "Linear prediction of the selection"
		exit
	}
	if "`xbsigma2'" != "" {
		syntax newvarname [if] [in] [, XBSIGma2]
		if "`e(het)'" == "" {
			di as error "{bf:xbsigma2} not valid without heteroskedasticity"
			exit 198
		}
		if "`e(selhet)'" != "" local eqn = 4
		else local eqn = 3
		_predict `typlist' `varlist' `if' `in', equation(#`eqn')
		label var `varlist' "Linear prediction of ln(SE^2)"
		exit
	}
	if "`xbselsigma2'" != "" {
		syntax newvarname [if] [in] [, XBSELSIGma2]
		if "`e(selhet)'" == "" {
			di as error "{bf:xbselsigma2} not valid without selection heteroskedasticity"
			exit 198
		}
		_predict `typlist' `varlist' `if' `in', equation(#3)
		label var `varlist' "Linear prediction of selection ln(SE^2)"
		exit
	}
	if "`ytrun'" != "" {
		syntax newvarname [if] [in] [, YTrun]
		tempname sig
		scalar `sig' = _b[sigma:_cons]
		_predict `typlist' `varlist' `if' `in', equation(#2)
		if "`e(est_model)'" != "linear" {
			tempvar sig2
			if "`e(het)'" == ""													///
				quiet generate `typlist' `sig2' = `e(sigma)'^2 `if' `in'
			else {
				if "`e(selhet)'" != "" local eqn = 4
				else local eqn = 3
				_predict `typlist' `sig2' `if' `in', equation(#`eqn')
				quiet replace `sig2' = exp(`sig2') `if' `in'
			}
			quiet replace `varlist' = exp(`varlist' + `sig2' / 2)
		}
		label var `varlist' "Prediction of truncated mean E(y|y > 0)"
		exit
	}
	if "`ytduan'" != "" {
		syntax newvarname [if] [in] [, YTDuan]
		// this is only valid if the model is exponential. Let's check it
		if "`e(est_model)'" != "exponential"									///
			error 198 "option {bf:ytduan} not allowed"
		tempname sig
		scalar `sig' = _b[duan:_cons]
		_predict `typlist' `varlist' `if' `in', equation(#2)
		quiet replace `varlist' = `sig' * exp(`varlist') `if' `in'
		label var `varlist' "Duan smeared prediction of E(y|y > 0)"
		exit
	}
	if "`ystar'" != "" {
		syntax newvarname [if] [in] [, YStar]
		tempvar sig2 zg
		
		
		tempname sig
		tempvar zg
		scalar `sig' = _b[sigma:_cons]
		_predict `typlist' `zg' `if' `in', equation(#1)
		_predict `typlist' `varlist' `if' `in', equation(#2)
		if "`e(est_model)'" != "linear"											///
			quiet replace `varlist' = exp(`varlist' + `sig'^2 / 2)
		if "`e(sel_estim)'" == "Logit"											///
			quiet replace `varlist' = invlogit(`zg') * `varlist'
		else quiet replace `varlist' = normal(`zg') * `varlist'
		label var `varlist' "Prediction of censored mean E(y)"
		exit
	}
	if "`ysduan'" != "" {
		syntax newvarname [if] [in] [, YSDuan]
		// this is only valid if the model is exponential. Let's check it
		if "`e(est_model)'" != "exponential"									///
			error 198 "option {bf:ysduan} not allowed"
		tempname sig
		tempvar zg
		scalar `sig' = _b[duan:_cons]
		_predict `typlist' `zg' `if' `in', equation(#1)
		_predict `typlist' `varlist' `if' `in', equation(#2)
		quiet replace `varlist' = `sig' * exp(`varlist')
		if "`e(sel_estim)'" == "Logit"											///
			quiet replace `varlist' = invlogit(`zg') * `varlist'
		else quiet replace `varlist' = normal(`zg') * `varlist'
		label var `varlist' "Duan smeared prediction of E(y)"
		exit
	}
	if "`psel'" != "" {
		syntax newvarname [if] [in] [, PSel]
		_predict `typlist' `varlist' `if' `in', equation(#1)
		if "`e(sel_estim)'" == "Logit"											///
			quiet replace `varlist' = invlogit(`varlist')
		else quiet replace `varlist' = normal(`varlist')
		label var `varlist' "Prediction of probability of selection Pr(y > 0)"
		exit
	}
end
*/
