*! rlasso_p 1.0.01 15oct2019
*! lassopack package 1.3.1
*! authors aa/cbh/ms

* postestimation predict for rlasso

* Updates (release date):
* 1.0.00    first version, dated 30nov2017
* 1.0.01  	(14oct2019)
*           added support for fe
*			noisily now shows beta vector

program define rlasso_p, rclass

	version 12.1

	syntax namelist(min=1 max=2) [if] [in], ///
											///
				[XB 						/// [default]
				Residuals U E UE XBU		///
				lasso						///
				ols							///
				NOIsily						///
				]
				
	if "`noisily'"=="" {
		local qui qui 
	}
	*

	* get var type & name
	tokenize `namelist'
	if "`2'"=="" {					//  only new varname provided
		local varlist `1'
		//qui gen `1' = .
	}
	else {							//  datatype also provided
		local vtype `1'
		local varlist `2'
	}
	*

	local command=e(cmd)
	if ("`command'"~="rlasso") {
		di as err "error: -rlasso_p- supports only the -rlasso- command"
		exit 198
	}
	*
	
	if "`lasso'"~="" & "`ols'"~="" {
		di as err "error: incompatible options -lasso- and -ols-"
		exit 198
	}
	
	marksample touse, novarlist
	
	*** warning messages
	local fe = `e(fe)'
	if ("`xb'`residuals'`u'`e'`ue'`xbu'"=="") {
		di as gr "No xb or residuals options specified. Assume xb (fitted values)."
		local xb xb
	}
	if (("`u'`e'`ue'`xbu'"!="") & (`fe'!=1)) {
		di as err "u, e, ue and xbu only supported after fe"
		exit 198
	}
	else if `fe'==1 {
		* xtset is required for FEs so this check should never fail
		cap xtset
		if _rc {
			di as err "internal error - data not xtset"
			exit 499
		}
		local panelvar `r(panelvar)'
		local timevar `r(timevar)'
	}
	if `:  word count `u' `e' `ue' `xbu' ' > 1 {
		di as err "only one allowed: u, e or ue"
		exit 198
	}
	if (("`residuals'"!="") & (`fe'==1)) {
		di as err "residuals option not allowed after fe; select u, e or ue."
		exit 198
	}
	*
	
	*** obtain prediction/residuals
	local depvar `e(depvar)'
	if "`depvar'"=="" {
		di as err "internal rlasso_p error. no depvar found."
	}
	tempname b
	tempvar xbvar esample res
	qui gen byte `esample' = e(sample)
	if "`lasso'`ols'"=="" {					//  default = posted e(b) matrix
		mat `b'		=e(b)
	}
	else if "`lasso'"~="" {
		mat `b'		=e(beta)
	}
	else {
		mat `b'		=e(betaOLS)
	}
	
	qui matrix score `vtype' `xbvar' = `b'  if `touse'
	if ("`xb'"!="") {
		// enter if standard or FE
	    if (`fe'==1) {
			* need to add constant
			qui gen `vtype'  `res' = `depvar' - `xbvar' if `esample'
			qui sum `res' if `esample', meanonly
			local acons = `r(mean)'
		}
		else {
			local acons = 0
		}
		gen `vtype' `varlist' = `xbvar' + `acons' `if'
		label var `varlist' "Predicted values"
	}
	else if ("`residuals'"!="") {
		// enter if standard only
		gen `vtype'  `varlist' = `depvar' - `xbvar' `if'
		label var `varlist' "Residuals"
	}
	else if ("`u'"!="") {
		// enter if FE only
		// fixed effect component u
		* "if" ignored
		if ("`if'"!="") {
			di as err "Warning: if condition ignored. Residuals calculated for estimation sample."
		}
		qui gen `vtype' `res' = `depvar' - `xbvar' if `esample'
		* first get combined residuals u+e and put in `varlist'
		qui sum `res' if `esample', meanonly
		gen `vtype' `varlist' = `res' - `r(mean)' if `esample'
		* now de-factor combined residuals and put in `res'
		lassoutils `res', fe(`panelvar') touse(`esample') tvarlist(`res') `noftools'
		* u = ue - e
		qui replace `varlist' = `varlist' - `res' if `esample'
		label var `varlist' "Residuals u(i)"
	}
	else if ("`e'"!="") {
		// enter if FE only
		// idiosyncratic component e
		* "if" ignored
		if ("`if'"!="") {
			di as err "Warning: if condition ignored. Residuals calculated for estimation sample."
		}
		qui gen `vtype' `res' = `depvar' - `xbvar' if `esample'
		* de-factor combined residuals
		lassoutils `res', fe(`panelvar') touse(`esample') tvarlist(`res') `noftools'
		gen `vtype' `varlist' = `res' if `esample'
		label var `varlist' "Residuals e(it)"
	}
	else if ("`ue'"!="") {
		// enter if FE only
		// combined residual u+e
		qui gen `vtype' `res' = `depvar' - `xbvar' `if'
		* center combined residuals
		qui sum `res' if `esample', meanonly
		gen `vtype' `varlist' = `res' - `r(mean)' `if'
		label var `varlist' "(Centered) Combined residuals u(i) + e(it)"
	}
	else if ("`xbu'"!="") {
		// enter if FE only
		// fixed effect component u + xb + constant = y - e = prediction including fixed effect
		* "if" ignored
		if ("`if'"!="") {
			di as err "Warning: if condition ignored. Residuals calculated for estimation sample."
		}
		qui gen `vtype' `res' = `depvar' - `xbvar' if `esample'
		* de-factor combined residuals
		lassoutils `res', fe(`panelvar') touse(`esample') tvarlist(`res') `noftools'
		gen `vtype' `varlist' = `depvar' - `res' if `esample'
		label var `varlist' "Prediction including fixed effect u(i)"
	}
	else {
		di as err "internal rlasso_p error"
		exit 198
	}
	*

	`qui' di "Beta used for predict:"
	`qui' mat list `b', noblank  noheader
end
