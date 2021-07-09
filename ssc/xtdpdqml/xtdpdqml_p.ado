*! version 1.4.3  26feb2017
*! Sebastian Kripfganz, www.kripfganz.de

*==================================================*
***** predictions and residuals after xtdpdqml *****

*** Citation ***

/*	Kripfganz, S. 2016.
	Quasi-maximum likelihood estimation of linear dynamic short-T panel-data models.
	Stata Journal 16: 1013-1038.		*/

program define xtdpdqml_p, sort
	version 12.1
	syntax [anything] [if] [in] [, SCores *]
	if "`scores'" != "" & e(k_eq) > 1 & !e(stationary) {		// score
		xtdpdqml_p_scores `0'
		exit
	}

	if e(k_eq) > 1 {
		if "`e(model)'" == "fe" {
			loc options			"E"
		}
		else {
			loc options			"UE E U XBU"
		}
	}
	else {
		loc options			"UE E U XBU"
	}
	_pred_se "`options'" `0'
	if `s(done)' {
		exit
	}
	loc vtype			"`s(typ)'"
	loc varn			"`s(varn)'"
	loc 0				`"`s(rest)'"'
	syntax [if] [in] [, `options']
	marksample touse

	loc prediction		"`ue'`e'`u'`xbu'"
	if e(k_eq) > 1 & "`e(model)'" == "fe" & "`prediction'" == "e" {
		loc prediction		"ue"
	}
	if "`prediction'" == "" {						// linear prediction excluding unit-specific error component (default)
		di as txt "(option xb assumed; fitted values)"
		_predict `vtype' `varn' if `touse', xb
		exit
	}
	if "`prediction'" == "ue" {						// combined residual
		tempvar xb
		qui _predict double `xb' if `touse', xb
		gen `vtype' `varn' = `e(depvar)' - `xb' if `touse'
		if e(k_eq) > 1 & "`e(model)'" == "fe" {
			lab var `varn' "D.e[`e(ivar)',`e(tvar)']"
		}
		else {
			lab var `varn' "u[`e(ivar)'] + e[`e(ivar)',`e(tvar)']"
		}
		exit
	}
	qui replace `touse' = 0 if !e(sample)
	if "`prediction'" == "e" {						// idiosyncratic error component
		tempvar xb u
		qui _predict double `xb' if `touse', xb
		qui predict double `u' if `touse', u
		gen `vtype' `varn' = `e(depvar)' - `xb' - `u' if `touse'
		lab var `varn' "e[`e(ivar)',`e(tvar)']"
		exit
	}
	tempvar smpl
	qui gen byte `smpl' = e(sample)
	if "`prediction'" == "u" | "`prediction'" == "xbu" {
		tempvar xb u y_bar xb_bar
		qui _predict double `xb' if `smpl', xb
		qui by `e(ivar)': egen double `y_bar' = mean(`e(depvar)') if `smpl'
		qui by `e(ivar)': egen double `xb_bar' = mean(`xb') if `smpl'
		qui gen double `u' = `y_bar' - `xb_bar' if `smpl'
		if "`prediction'" == "u" {					// unit-specific error component
			gen `vtype' `varn' = `u' if `touse'
			lab var `varn' "u[`e(ivar)']"
		}
		else {										// linear prediction including unit-specific error component
			gen `vtype' `varn' = `xb' + `u' if `touse'
			lab var `varn' "Xb + u[`e(ivar)']"
		}
		exit
	}
	error 198
end

*==================================================*
**** computation of scores ****
program define xtdpdqml_p_scores, rclass
	version 12.1
	syntax [anything] [if] [in] [, *]
	marksample touse

	tempvar smpl e tmp
	qui gen byte `smpl' = e(sample)
	if "`e(model)'" == "fe" {
		qui predict double `e' if `smpl', e
	}
	else {
		qui predict double `e' if `smpl', ue
	}
	qui predict double `tmp' if `smpl' & (L.`smpl' != 1), xb eq(#2)
	qui replace `e' = `e(depvar)' - `tmp' if `tmp' != .
	_score_spec `anything', `options'
	if "`s(eqname)'" == "" {
		loc eqnames			"`s(coleq)'"
	}
	else {
		loc eqnames			"`s(eqname)'"
	}

	forv i = 1/`: word count `eqnames'' {
		loc vtyp			: word `i' of `s(typlist)'
		loc varn			: word `i' of `s(varlist)'
		loc eq				: word `i' of `eqnames'
		qui replace `tmp' = .
		if "`e(model)'" == "fe" {
			mata: xtdpdqml_score(	"`e'",												///
									"`tmp'",											///
									"`e(ivar)'",										///
									"`smpl'",											///
									(`= _b[_sigma2e:_cons]', `= _b[_omega:_cons]'),		///
									"`eq'")
		}
		else {
			mata: xtdpdqml_re_score("`e'",																								///
									"`tmp'",																							///
									"`e(ivar)'",																						///
									"`smpl'",																							///
									(`= _b[_sigma2u:_cons]', `= _b[_sigma2e:_cons]', `= _b[_sigma2e0:_cons]', `= _b[_phi:_cons]'),		///
									"`eq'")
		}
		gen `vtyp' `varn' = `tmp' if `touse'
		lab var `varn' "equation-level score from `e(cmd)'"
	}

	ret loc scorevars	`varn'
end
