*! version 1.21 March 23, 2007 @ 17:05:47
*! Roger Harbord
	/*
		code based on example in _pred_se.hlp
		v1.21 fixed  stdxbu
	*/
	
program define metareg_p
version 7
	local myopts "STDF U USTAndard XBU STDXBU Hat"
	_pred_se "`myopts'" `0'					 /* handles xp and stdp */
	if `s(done)' {
		exit
		}
	local typ `s(typ)'
	local varn `s(varn)'
	local 0    `"`s(rest)'"'
	syntax [if] [in] [, `myopts' noOFFset]

	/* concatenate switch options together */
	local type "`stdf'`u'`ustandard'`xbu'`stdxbu'`hat'"

	/* quickly process default case        */
	if "`type'"==""  {
		di as txt "(option xb assumed; fitted values)"
		_predict `typ' `varn' `if' `in', xb `offset'
		exit
		}

	/* mark sample                         */
	marksample touse
	
	if "`type'"=="u" | "`type'"=="xbu" | "`type'" == "ustandard" {
		tempvar xb
		qui _predict double `xb' if `touse', xb  `offset'
		}

	if "`type'" == "stdf" | "`type'" == "stdxbu" | "`type'" == "ustandard"  /*
*/	  | "`type'" == "hat" {
		tempvar stdp
		qui _predict double `stdp' if `touse', stdp `offset'
		}

	if "`type'" == "u" | "`type'" == "xbu" | "`type'" == "stdxbu"  /*
*/	  | "`type'" =="ustandard" | "`type'" =="hat" {
		tempvar wsvar
		if "`e(wsvar)'" !="" {
			qui gen `wsvar' = `e(wsvar)' if `touse'
			}
		else {
			qui gen `wsvar' = `e(wsse)'^2 if `touse'
			}
		}

	if "`type'" == "u" | "`type'" == "xbu" | "`type'" == "stdxbu" {
		tempvar B   /* Bayes shrinkage factor */
		qui gen double `B' =  e(tau2) / ( e(tau2) + `wsvar' ) if `touse'
		}


	if "`type'" == "u" {
		gen `typ' `varn' = `B' * ( `e(depvar)' - `xb' ) if `touse'
		label var `varn' "Predicted random effects"
		exit
		}

	if "`type'" == "xbu" {
		gen `typ' `varn' = `B' * `e(depvar)' + (1-`B') * `xb' if `touse'
		label var `varn' "Prediction including random effects"
		exit
		}

	if "`type'" == "stdf" {
		gen `typ' `varn' =  sqrt( `stdp'^2 + e(tau2) ) if `touse'
		label var `varn' "S.E. of the forecast"
		exit
		}

	if "`type'" == "stdxbu" {
		gen `typ' `varn' =  sqrt( `B'^2 * ( `wsvar' + e(tau2) )  ///
		  + (1-`B'^2) * `stdp'^2 ) if `touse'
			label var `varn' "S.E. of prediction incl. random effects"
		exit
		}

	if "`type'" == "ustandard" {
		gen `typ' `varn' =  ( `e(depvar)' - `xb' ) / /*
*/		  sqrt( `wsvar' + e(tau2) - `stdp'^2 ) if `touse'
			label var `varn' "Standardized predicted random effects"
		exit
		}

	if "`type'" == "hat" {
		gen `typ' `varn' =  `stdp'^2 / ( `wsvar' + e(tau2) ) if `touse'
			label var `varn' "Leverage"
		exit
		}
	
			
	error 198
end
