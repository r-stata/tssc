*! version 1.0.3  12feb2021
*! Sebastian Kripfganz, www.kripfganz.de
*! Vasilis Sarafidis, sites.google.com/view/vsarafidis

*==================================================*
***** predictions and residuals after xtivdfreg *****

program define xtivdfreg_p, sort
	version 13.0
	syntax [anything] [if] [in] [, XB *]
	loc 0				`"`anything' `if' `in' , `options'"'
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

	loc prediction		"`residuals'"
	if "`prediction'" == "" {						// linear prediction (default)
		if "`xb'" == "" {
			di as txt "(option xb assumed; fitted values)"
		}
		_predict `vtype' `varn' if `touse', xb
		exit
	}
	if "`prediction'" == "residuals" {				// combined residual
		tempvar xb
		qui predict double `xb' if `touse', xb
		gen `vtype' `varn' = `e(depvar)' - `xb' if `touse'
		lab var `varn' "Residuals"
		exit
	}
	error 198
end
