*! version 1.0.1  12sep2020
*! Sebastian Kripfganz, www.kripfganz.de
*! Jan F. Kiviet, sites.google.com/site/homepagejfk/

*==================================================*
***** predictions and residuals after kinkyreg *****

*** citation ***

/*	Kripfganz, S., and J. F. Kiviet. 2020.
	kinkyreg: Instrument-free inference for linear regression models with endogenous regressors.
	Manuscript submitted to the Stata Journal.		*/

program define kinkyreg_p, sort
	version 13.0
	syntax [anything] [if] [in] [, XBGrid RESGrid XGrid *]		// undocumented
	if "`xbgrid'" != "" | "`resgrid'" != "" | "`xgrid'" != "" {
		if `: word count `xbgrid' `resgrid' `xgrid'' > 1 {
			error 198
		}
		if `"`options'"' != "" {
			loc options			`", `options'"'
		}
		kinkyreg_p_`xbgrid'`resgrid'`xgrid' `anything' `if' `in' `options'
		exit
	}

	loc options			"Residuals"
	_pred_se "`options'" `0'
	if `s(done)' {
		exit
	}
	loc vtype			"`s(typ)'"
	loc varn			"`s(varn)'"
	loc 0				`"`s(rest)'"'
	syntax [if] [in] [, `options']
	marksample touse
	if "`residuals'" != "" {
		tempvar xb
		qui predict double `xb' if `touse', xb
		gen `vtype' `varn' = `e(depvar)' - `xb' if `touse'
		lab var `varn' "Residuals"
	}
	else {
		di as txt "(option xb assumed; fitted values)"
		_predict `vtype' `varn' if `touse', xb
	}
end

*==================================================*
**** generation of endogeneity-corrected fitted values ****
program define kinkyreg_p_xbgrid, rclass
	version 13.0
	syntax [anything] [if] [in]
	marksample touse

	tempname b
	mat `b'				= e(b_kls)
	loc N_grid			= rowsof(`b')
	_stubstar2names `anything', nvars(`N_grid') noverify
	loc vtypes			"`s(typlist)'"
	loc varn			"`s(varlist)'"
	if `: word count `varn'' != `N_grid' {
		error 102
	}

	foreach var in `e(exovars)' {
		_ms_parse_parts `var'
		if "`r(type)'" != "variable" | "`r(op)'" != "" {
			fvrevar `var'
			loc var				"`r(varlist)'"
			qui replace `var' = .
			loc exovars		"`exovars' `var'"
		}
		else {
			tempvar `var'
			qui gen double ``var'' = .
			loc exovars		"`exovars' ``var''"
		}
	}
	loc K				= colsof(`b')
	loc controls		"`e(controls)'"
	mat `b'				= `b'[., 1..`=`K'-`: word count `controls''']
	loc controls		: subinstr loc controls "_cons" "", w c(loc hascons)
	mata: kinkyreg_partial("`e(exovars)'", "`controls'", "`exovars'", "`touse'", `hascons')
	loc i				= 0
	foreach var in `e(endovars)' {
		loc ++i
		tempname xgrid_`i'
		forv g = 1 / `N_grid' {
			tempvar `xgrid_`i''_`g'
		}
		predict double `xgrid_`i''_* if `touse', xgrid endovar(`var')
	}
	loc corr			= e(grid_min)
	forv g = 1 / `N_grid' {
		loc i				= 0
		foreach var in `e(endovars)' {
			loc ++i
			loc xgrid`g'		"`xgrid`g'' `xgrid_`i''_`g'"
		}
		tempname bg
		mat `bg'			= `b'[`g'..`g', .]
		mat coln `bg'		= `xgrid`g'' `exovars'
		loc var				: word `g' of `varn'
		loc vtyp			: word `g' of `vtypes'
		qui mat sco `vtyp' `var' = `bg' if `touse'
		la var `var' "Linear prediction (corr=`: di %5.4f `corr'')"
		loc corr			= `corr' + e(grid_step)
	}

	ret loc varlist		"`varn'"
end

*==================================================*
**** generation of residuals ****
program define kinkyreg_p_resgrid, rclass
	version 13.0
	syntax [anything] [if] [in]
	marksample touse

	tempname b
	mat `b'				= e(b_kls)
	loc N_grid			= rowsof(`b')
	_stubstar2names `anything', nvars(`N_grid') noverify
	loc vtypes			"`s(typlist)'"
	loc varn			"`s(varlist)'"
	if `: word count `varn'' != `N_grid' {
		error 102
	}

	loc corr			= e(grid_min)
	forv g = 1 / `N_grid' {
		tempname bg fit
		mat `bg'			= `b'[`g'..`g', .]
		qui mat sco double `fit' = `bg' if `touse'
		loc var				: word `g' of `varn'
		loc vtyp			: word `g' of `vtypes'
		qui gen `vtyp' `var' = `e(depvar)' - `fit' if `touse'
		la var `var' "Residuals (corr=`: di %5.4f `corr'')"
		loc corr			= `corr' + e(grid_step)
	}

	ret loc varlist		"`varn'"
end

*==================================================*
**** generation of endogeneity-corrected regressors ****
program define kinkyreg_p_xgrid, rclass
	version 13.0
	syntax [anything] [if] [in] , [ENDOvar(varname num ts fv)]
	marksample touse

	tempname b
	mat `b'				= e(b_kls)
	loc N_grid			= rowsof(`b')
	if "`endovar'" == "" {
		loc endovar			"`e(klsvar)'"
	}
	loc endovars		"`e(endovars)'"
	loc endopos			: list posof "`endovar'" in endovars
	if !`endopos' {
		di as err "option endovar() incorrectly specified"
		exit 198
	}
	if `: word count `endovars'' > 1 {
		loc correlation		= el(e(endogeneity), 1, `endopos')
	}
	else {
		loc correlation		= .
	}

	_stubstar2names `anything', nvars(`N_grid') noverify
	loc vtypes			"`s(typlist)'"
	loc varn			"`s(varlist)'"
	if `: word count `varn'' != `N_grid' {
		error 102
	}
	foreach var of loc varn {
		tempvar gen`var'
		qui gen double `gen`var'' = .
		loc xvars			"`xvars' `gen`var''"
	}
	loc K				= colsof(`b')
	loc controls		"`e(controls)'"
	mat `b'				= `b'[., 1..`=`K'-`: word count `controls''']
	loc controls		: subinstr loc controls "_cons" "", w c(loc hascons)
	mata: kinkyreg_xcorr("`e(depvar)'", "`e(endovars)' `e(exovars)'", "`controls'", "`xvars'", "`touse'", "`b'", "e(sigma2e)", `endopos', (`e(grid_min)', `e(grid_step)', `e(grid_max)'), `correlation', `hascons')
	loc corr			= `e(grid_min)'
	forv g = 1 / `N_grid' {
		loc var				: word `g' of `varn'
		loc vtyp			: word `g' of `vtypes'
		qui gen `vtyp' `var' = `gen`var'' if `touse'
		la var `var' "`endovar' (corr=`: di %5.4f `corr'')"
		loc corr			= `corr' + e(grid_step)
	}

	ret loc varlist		"`varn'"
end
