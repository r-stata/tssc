* 1.0 John-Paul Ferguson 5Apr2011
capture program drop dyads
program dyads
	version 11
	syntax varname[, DYadvars(varlist)]
	tempvar matrix_dim column todrop
	quietly {
		count
		generate `matrix_dim' = `r(N)'
		expand `r(N)'
		sort `varlist'
		by `varlist': generate `column' = _n
		foreach var of varlist `varlist' `dyadvars' {
			generate `var'_d = `var'[_n+`column'*`matrix_dim']
		}
		drop if mi(`varlist'_d)
	}
end
