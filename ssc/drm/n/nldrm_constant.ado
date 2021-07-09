*==============================*
*Evaluator for constant weights 
*==============================*
cap program drop nldrm_constant
program nldrm_constant
	version 12
	syntax varlist [aw fw iw] if, at(name) 
		
	gettoken depvar varlist	: varlist	// gets depvar 
	gettoken rowvar varlist	: varlist	// gets rowvar	
	gettoken colvar controls : varlist	// gets colvar, leaves controls
	
	marksample touse
	
	// Handle BYVAR global cases
	if "$DRMBYVAR" != "" local drmbyvar = "$DRMBYVAR"
	else {
		tempvar drmbyvar  
		gen `drmbyvar' = 1
	}
	
	// Find NROWS and NBYVAR
	qui sum `rowvar' 
	local NROWS = `r(max)'

	qui sum `drmbyvar'
	local NBYVAR = `r(max)'		
	
	// Set counter for position in "at" matrix
	local NPARM = 1 
	
	// Gamma -> If p is constrained
	if "$DRMCONSTRAIN" == "yes" {
		tempname gamma1 
		scalar `gamma1' = `at'[1,`NPARM']
		local ++NPARM
		tempname p
		scalar `p'=exp(`gamma1')/(1+exp(`gamma1'))
	}
	// P -> If p is not constrained
	else {
		tempname p 
		scalar `p' = `at'[1,`NPARM']
		local ++NPARM
	}
	
	// Mu
	forvalues i=1/`NBYVAR' {
		forvalues j=1/`NROWS' {
			tempname mu_parm`j'`j'_`i'
			scalar  `mu_parm`j'`j'_`i'' = `at'[1,`NPARM']
			local ++NPARM 
		}
	}
	
	// Controls
	local NCONTROLS : word count `controls'
	forvalues i=1/`NCONTROLS' {
		tempname control_parm`i'
		scalar `control_parm`i'' = `at'[1,`NPARM']
		local ++NPARM 
	}
	
	// Intervars (if relevant)
	if "$DRMINTERVARS" != "" {
		local COUNTER = 1
		foreach i of global DRMINTERVARS { 
			*Rho
			tempname rho_`COUNTER'
			scalar `rho_`COUNTER'' = `at'[1,`NPARM']
			local ++NPARM
			local intervar_`COUNTER' = "`i'"
			local interweight  `interweight' `rho_`COUNTER'' * `intervar_`COUNTER'' +  
			local ++COUNTER
		}
	}
	
	// Create the mu vars
	forvalues i=1/`NBYVAR' {
		forvalues j=1/`NROWS' {  
			tempvar `rowvar'`j'_`i'
			qui gen ``rowvar'`j'_`i'' = 0
			qui replace ``rowvar'`j'_`i'' = 1 if `rowvar' == `j' & `drmbyvar' == `i'
			
			tempvar `colvar'`j'_`i'
			qui gen  ``colvar'`j'_`i'' = 0
			qui replace ``colvar'`j'_`i'' = 1 if `colvar' == `j' & `drmbyvar' == `i'
		}
	}
	
	// Create intermediate locals and scalars
	*Controls
	tokenize `controls'
	forvalues i=1(1)`NCONTROLS'{
		local estimate_controls "`estimate_controls' ``i'' * `control_parm`i'' +"
	}
	
	*Mu
	forvalues i=1/`NBYVAR' {
		forvalues j=1/`NROWS' { 
			local mu_row "`mu_row' ``rowvar'`j'_`i'' * `mu_parm`j'`j'_`i'' +"
			local mu_col "`mu_col' ``colvar'`j'_`i'' * `mu_parm`j'`j'_`i'' +"
		}
	}

	// Create intermediate results 
	tempvar row_weight 
	if "$DRMINTERVARS" != "" 	gen double `row_weight' = (`p'+(`interweight' 0)) * (`mu_row' 0) if `touse'
	else 						gen double `row_weight' = (`p') * (`mu_row' 0) if `touse'
	
	tempvar col_weight
	if "$DRMINTERVARS" != "" 	gen double `col_weight' = ((1-`p')-(`interweight' 0)) * (`mu_col' 0) if `touse'
	else 						gen double `col_weight' = (1-`p') * (`mu_col' 0) if `touse'
	
	tempvar controls
	gen double `controls' = `estimate_controls' 0   if `touse'
	
	// Replace depvar
	replace `depvar' = `row_weight' + `col_weight' + `controls'  if `touse'
end
