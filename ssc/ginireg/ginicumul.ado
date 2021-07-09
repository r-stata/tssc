*! ginicumul.ado for ginireg

program define ginicumul, sort
	version 10.1
	syntax varname(ts) [fw aw pw/] [if] [in] ,GENerate(name) [ extended nu(real 2) ]

	marksample touse
	tempvar wgt

* Resolve TS operators if any
* variable provided now in macro `var_t'
	tsrevar `varlist'
	local var_t `r(varlist)'

* Raw weight variable
	if `"`exp'"' != "" {
		qui gen double `wgt' = `exp' if `touse'
	}
	else {
		qui gen double `wgt' = 1
	}
* Normalized weight var; sum=1
	sum `wgt' if `touse', meanonly
	qui replace `wgt' = `wgt'/r(sum)

	tempvar RESULT

* Start by sorting.
* Ties possible.
	sort `var_t'

	qui gen double	`RESULT' = sum(`wgt') if `touse'
	qui replace		`RESULT' = `RESULT' - `wgt'/2 if `touse'
* In case of ties, assign AVERAGE to all members of the group
	by `var_t': egen double `generate' = mean(`RESULT')
* Extended Gini CDF
	if "`extended'" ~= "" {
		qui replace `generate'=(1-`generate')^(`nu'-1)
	}

end
