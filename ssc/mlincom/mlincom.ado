*! 1.0.0                05may2020
*! Wouter Wakker        wouter.wakker@outlook.com
program mlincom, eclass
	version 8

	if replay() {
		if "`e(cmd)'" != "mlincom" {
			error 301
        }
        syntax [, EForm(string) 		   	   ///
					   OR            		   ///
					   HR 					   ///
					   SHR           		   ///
					   IRr 		     		   ///
					   RRr           		   ///
					   Level(integer $S_level) ///
					   ]
		
		// Only one display option allowed
		local eformopt : word count `eform' `or' `hr' `shr' `irr' `rrr' 
		if `eformopt' > 1 {
				di as error "only one display option can be specified"
				exit 198
		}
    }
	else {
		syntax anything [, EForm(string) 		   ///
						   OR            		   ///
						   HR 					   ///
						   SHR           		   ///
						   IRr 		     		   ///
						   RRr           		   ///
						   Level(integer $S_level) ///
						   DF(numlist max=1 >0)    ///
						   POST                    ///
						   COVZERO                 ///
						   noHEADer				   ///
						   ]
		
		// Only one display option allowed
		local eformopt : word count `eform' `or' `hr' `shr' `irr' `rrr' 
		if `eformopt' > 1 {
				di as error "only one display option can be specified"
				exit 198
		}
		
		// Header option
		if "`header'" != "" {
			local dont *
		}
		
		// Parse anything, must be within parentheses, return list of "[(name)] equation"
		local n_lc 0
		gettoken tok : anything, parse(" (")
		if `"`tok'"' == "(" { 
			while `"`tok'"' != "" {
				local ++n_lc
				gettoken tok anything : anything, parse(" (") match(paren)
				local tokens `"`tokens' `"`tok'"'"'
				gettoken tok : anything, parse(" (")
				if !inlist(`"`tok'"', "(", "") {
					di as error "equation must be contained within parentheses"
					exit 198
				}
			}
		}
		else di as error "equation must be contained within parentheses"
			
		// Store e(V) matrix
		tempname eV
		mat `eV' = e(V)
		local rownames : rowfullnames `eV'
		local n_eV = rowsof(`eV')
		
		// Extract estimation output (code based on Roger Newson's lincomest.ado)
		local depname `"`e(depvar)'"'
		tempvar esample
		local obs = e(N)
		if "`df'" == "" local dof = e(df_r)
		else local dof = `df' 
		gen byte `esample' = e(sample)
		
		// Define tempnames and matrices for results
		tempname estimate se variance beta vcov
		mat def `beta' = J(1, `n_lc',0)
		mat def `vcov' = J(`n_lc',`n_lc',0)	
		
		`dont' di
		
		// Start execution
		local i 1
		foreach name_eq in `tokens' {
			mlincom_parse_name_eq `"`name_eq'"' `i'
			local eq_names `eq_names' `s(eq_name)'
			local name `s(eq_name)'
			local eq `s(eq)'
			
			if "`post'" != "" & "`covzero'" == "" {
				mlincom_parse_eq_for_test `eq'
				qui lincom `s(eq_for_test)', level(`level') df(`df')
			}
			else qui lincom `s(eq)', level(`level') df(`df')
			
			`dont' di as txt %13s abbrev("`name':",13)  _column(16) as res "`eq' = 0"

			scalar `estimate' = r(estimate)
			scalar `se' = r(se)
			
			// Calculate transform se and var if previous command is logistic (from Roger Newson's lincomest.ado)
			if "`e(cmd)'" == "logistic" {
				scalar `se' = `se' / `estimate'
				scalar `estimate' = log(`estimate')
				if `"`eform'"' == "" {
					local eform "Odds Ratio"
				}
			}
			
			scalar `variance' = `se' * `se'
			mat `beta'[1, `i'] = `estimate'
			mat `vcov'[`i', `i'] = `variance'
			
			// Get column vectors for covariance calculations
			if "`post'" != "" & "`covzero'" == "" {
				mlincom_get_eq_vector `"`eq'"' `"`rownames'"' `n_eV'
				tempname c`i'
				mat `c`i'' = r(A)
			}
			
			local ++i
		}
		
		// Fill VCOV matrix with covariances
		if "`post'" != "" & "`covzero'" == "" {
			forval i = 1 / `n_lc' {
				forval j = 1 / `n_lc' {
					if `i' != `j' {
						mat `vcov'[`i',`j'] = `c`i''' * `eV' * `c`j''
					}
				}
			}	
		}
			
		// Name rows/cols matrices
		mat rownames `beta' = y1
		mat colnames `beta' = `eq_names'
		mat rownames `vcov' = `eq_names'
		mat colnames `vcov' = `eq_names'
	}
	
	// Eform options 
	if "`eform'" == "" {
		if "`or'" != "" local eform "Odds Ratio"
		if "`hr'" != "" local eform "Haz. Ratio"
		if "`shr'" != "" local eform "SHR"
		if "`irr'" != "" local eform "IRR"
		if "`rrr'" != "" local eform "RRR"
	}
	
	di
	
	// Display and post results
	if "`post'" != "" {
		ereturn post `beta' `vcov' , depname("`depname'") obs(`obs') dof(`dof') esample(`esample')
		ereturn local cmd "mlincom"
		ereturn local predict "mlincom_p"
		ereturn display, eform(`eform') level(`level')

	}
	else if replay() ereturn display, eform(`eform') level(`level')
	else {
		tempname hold
		nobreak {
			_estimates hold `hold'
			capture noisily break {
				ereturn post `beta' `vcov' , depname("`depname'") obs(`obs') dof(`dof') esample(`esample')
				ereturn local cmd "mlincom"
				ereturn display, eform(`eform') level(`level')
			}
			local rc = _rc
			_estimates unhold `hold'
			if `rc' {
					exit `rc'
			}
		}
	}
end

program mlincom_parse_name_eq, sclass
	version 8
	args eq n
	gettoken tok : eq, parse("(")
	if `"`tok'"' == "(" {
		gettoken tok 0 : eq, parse("(") match(paren)
		local wc : word count `tok'
		if `wc' > 1 {
			di as error "{bf:`tok'} invalid name"
			exit 7
		}
		confirm names `tok'
		local name `tok'
		local eq `"`0'"'
	}
	else local name "lc_`n'"
	
	sreturn local eq_name = `"`name'"'
	sreturn local eq = `"`eq'"'
end	

program mlincom_parse_eq_for_test, sclass
	version 8
	gettoken tok rest : 0 , parse(":")
	if `"`tok'"' == `"`0'"' local eq `"`0'"'
	else {
		tokenize `"`0'"', parse(" :+-/*")
		local i 1
		while "``i''" != "" {
			if "``=`i'+1''" == ":" local eq `"`eq' [``i'']"'
			else if "``=`i'-1''" == ":" local eq `"`eq'``i''"'
			else if "``i''" != ":" local eq `"`eq' ``i''"'
			local ++i
		}
	}
	
	sreturn local eq_for_test = `"`eq'"'
end

program mlincom_get_eq_vector, rclass
	version 8
	args eq rownames n
	
	local 0
	
	tokenize `eq', parse("+-*/ ")
	
	tempname A
	mat `A' = J(`n',1,0)
	mat rownames `A' = `rownames'
	
	local i 1
	while "``i''" != "" {
		cap confirm number ``i''
		if _rc {
			if inlist("``i''", "+", "-") {
				if inlist("``=`i'+1''", "-", "+") { 
					di as error "++, --, +-, -+ not allowed"
					exit 198
				}
			}
			else if inlist("``i''", "*", "/") {
				 if inlist("``=`i'+2''", "*", "/") | inlist("``=`i'+3''", "*", "/") { 
					di as error "maximum number of multiplications/divisions per estimate = 1"
					exit 198
				}
			}
			else if rownumb(`A',"``i''") == . {
				di as error "{bf:``i''} not found in matrix e(V)"
				exit 303
			}
			else { // IF VAR e(V)
				if inlist("``=`i'-1''", "+", "-", "") { 
					if inlist("``=`i'+1''", "+", "-", "") {
						if "``=`i'-1''" == "-" {
							if "``=`i'-2''" == "*" {
								if "``=`i'-4''" == "-" mat `A'[rownumb(`A',"``i''"),1] = `A'[rownumb(`A',"``i''"),1] + ``=`i'-3''
								else mat `A'[rownumb(`A',"``i''"),1] = `A'[rownumb(`A',"``i''"),1] - ``=`i'-3''
							}
							else mat `A'[rownumb(`A',"``i''"),1] = `A'[rownumb(`A',"``i''"),1] - 1
						}
						else mat `A'[rownumb(`A',"``i''"),1] = `A'[rownumb(`A',"``i''"),1] + 1
					}
					else if inlist("``=`i'+1''", "*", "/") {
						if "``=`i'+1''" == "*" {
							if "``=`i'-1''" == "-" {
								if "``=`i'+2''" == "-" mat `A'[rownumb(`A',"``i''"),1] = `A'[rownumb(`A',"``i''"),1] + ``=`i'+3''
								else if "``=`i'+2''" == "+" mat `A'[rownumb(`A',"``i''"),1] = `A'[rownumb(`A',"``i''"),1] - ``=`i'+3''
								else mat `A'[rownumb(`A',"``i''"),1] = `A'[rownumb(`A',"``i''"),1] - ``=`i'+2''
							}
							else {
								if "``=`i'+2''" == "-" mat `A'[rownumb(`A',"``i''"),1] = `A'[rownumb(`A',"``i''"),1] - ``=`i'+3''
								else if "``=`i'+2''" == "+" mat `A'[rownumb(`A',"``i''"),1] = `A'[rownumb(`A',"``i''"),1] + ``=`i'+3''
								else mat `A'[rownumb(`A',"``i''"),1] = `A'[rownumb(`A',"``i''"),1] + ``=`i'+2''
							}
						}
						else if "``=`i'+1''" == "/" {
							if "``=`i'-1''" == "-" {
								if "``=`i'+2''" == "-" mat `A'[rownumb(`A',"``i''"),1] = `A'[rownumb(`A',"``i''"),1] + 1 / ``=`i'+3''
								else if "``=`i'+2''" == "+" mat `A'[rownumb(`A',"``i''"),1] = `A'[rownumb(`A',"``i''"),1] - 1 / ``=`i'+3''
								else mat `A'[rownumb(`A',"``i''"),1] = `A'[rownumb(`A',"``i''"),1] - 1 / ``=`i'+2''
							}
							else {
								if "``=`i'+2''" == "-" mat `A'[rownumb(`A',"``i''"),1] = `A'[rownumb(`A',"``i''"),1] - 1 / ``=`i'+3''
								else if "``=`i'+2''" == "+" mat `A'[rownumb(`A',"``i''"),1] = `A'[rownumb(`A',"``i''"),1] + 1 / ``=`i'+3''
								else mat `A'[rownumb(`A',"``i''"),1] = `A'[rownumb(`A',"``i''"),1] + 1 / ``=`i'+2''
							}
						}
					}
				}
				else if inlist("``=`i'-1''", "*") {
					if inlist("``=`i'-3''", "-") mat `A'[rownumb(`A',"``i''"),1] = `A'[rownumb(`A',"``i''"),1] - ``=`i'-2''
					else mat `A'[rownumb(`A',"``i''"),1] = `A'[rownumb(`A',"``i''"),1] + ``=`i'-2''
				}
			}				
		}
		local ++i
	}
	
	return matrix A = `A'
end
