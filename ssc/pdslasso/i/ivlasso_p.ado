*! ivlasso_p 1.0.00 26/09/2017
*! pdslasso package 1.1 15jan2019
*! authors aa/cbh/ms
* postestimation predict for ivlasso and pdslasso

program define ivlasso_p, rclass

	version 12.1

	syntax namelist(min=1 max=2) [if] [in], ///
											///
				[XB 						/// [default]
				Residuals 					///
											///
				]

	* create variable here
	tokenize `namelist'
	if "`2'"=="" {					//  only new varname provided
		local varlist `1'
		qui gen `1' = .
	}
	else {							//  datatype also provided
		local vtype `1'
		local varlist `2'
		qui gen `1' `2' = .
	}
	*

	if ("`e(cmd)'"~="ivlasso") & ("`e(cmd)'"~="pdlasso") {
		di as err "error: ivlasso_p supports only ivlasso and pdslasso commands"
		exit 198
	}
	*
	
	if "`e(post)'" ~= "pds" {
		di as err "error: predict currently supported only for default post(pds) option"
		exit 198
	}
	
	marksample touse, novarlist
	
	*** warning messages
	if ("`xb'`residuals'"=="") {
		di as text "No xb or residuals options specified. Assume xb (fitted values)."
		local xb xb
	}
	*** fe currently not supported.
	if `e(fe)' {
		di as err "predict not currently supported after FE estimation"
		exit 198
	}
	*
	
	*** obtain prediction/residuals
	tempname b
	tempvar xbvar
	mat `b'=e(b)
	qui matrix score `typlist' `xbvar'= `b'  `if'
	if ("`xb'"!="") {
		qui replace `varlist' = `xbvar' `if'
		label var `varlist' "Predicted values"
	}
	else if ("`residuals'"!="") {
		qui replace `varlist' = `e(depvar)' - `xbvar' `if'
		label var `varlist' "Residuals"
	}
	*

end
