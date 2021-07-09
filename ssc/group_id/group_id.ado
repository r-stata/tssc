*! version 1.0  15aug2009  Robert Picard
program define group_id

	version 9.2

	syntax varname, MATCHby(varlist)
		
	local id_var `varlist'
	
	preserve
	
	keep `id_var' `matchby'
	qui drop if mi(`id_var')
	foreach v of varlist `matchby' {
		qui drop if mi(`v')
	}
	sort `matchby' `id_var'
	qui by `matchby' `id_var': keep if _n == 1
	qui by `matchby': keep if _N > 1
	if _N == 0 {
		dis as txt "No identifier change within matching record groups"
		exit
	}
	
	tempvar new_id test
	clonevar `new_id' = `id_var'
	
	local more 1
	while `more' {
	
		qui by `matchby': replace `new_id' = `new_id'[1]
		sort `id_var' `new_id'
		qui by `id_var': replace `new_id' = `new_id'[1]
		
		sort `matchby' `new_id'
		qui by `matchby': gen byte `test' = `new_id' != `new_id'[1]
		qui sum `test', meanonly
		local more = r(max)
		drop `test'
		
	}
	
	sort `id_var'
	qui by `id_var': keep if _n == 1
	tempfile f
	qui save "`f'", replace
	restore, preserve
	sort `id_var'
	qui merge `id_var' using "`f'"
	
	qui count if `id_var' ~= `new_id' & _merge == 3
	qui replace `id_var' = `new_id' if _merge == 3
	drop _merge
	
	restore, not
	dis as txt "Records grouped with a different identifier = " as res `r(N)'

end
