*! ginireg_estat - estat command for ginireg
*! initial code taken from regress_estat

program ginireg_estat, rclass
	version 10.1

	if "`e(cmd)'" != "ginireg" {
		error 301
	}

* Parse, leave pre-comma contents in macro 0 and * in macro options
	syntax anything(name=0) [ , nlma * ]

	gettoken key rest : 0
	local lkey = length(`"`key'"')

	local gini_inexog	`e(gini_inexog)'

	if "`nlma'"=="" {
		local titletext "LMA"
	}
	else {
		local titletext "NLMA"
	}

	local varlab : variable label `e(depvar)'
	if "`varlab'"=="" {
		local varlab "`e(depvar)'"
	}

	if `"`key'"' == substr("lmaresid",1,max(4,`lkey')) {
		tempvar resid
		qui predict double `resid' if e(sample), resid
		label var `resid' "Residuals"
		local yvars `resid'
		local titletext "`titletext': Residuals"
	}
	else if `"`key'"' == substr("lmayyhat",1,max(4,`lkey')) {
		tempvar yhat
		qui predict double `yhat' if e(sample), xb
		label var `yhat' "Predicted value"
		local yvars `e(depvar)' `yhat'
		local titletext "`titletext': `varlab' and fitted values"
		local lpstyle "lpattern(solid dash)"
		local subtitle "solid = `varlab'; dash = fitted values"
	}
	else {
di as err "error - estat `key' not supported for ginireg"
			exit 601
	}
	
	foreach var of varlist `gini_inexog' {
		tempname g`var'
		ginilma `yvars' `var' if e(sample) ,		///
			`nlma'									///
			`lpstyle'								/// solid/dash if y/yhat, solid (omitted) for ehat
			title("")								/// not needed
			ytitle("")								/// not needed
			legend(off)								///
			nodraw									///
			name(`g`var'', replace)
		local glist `glist' `g`var''
	}
	graph combine `glist', title("`titletext'") subtitle("`subtitle'") `options'
	
end
