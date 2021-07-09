*! lclogitpr version 1.00 - Last update: Mar 26, 2012 
*! Authors: Daniele Pacifico (daniele.pacifico@tesoro.it)
*!			Hong il Yoo 	 (h.yoo@unsw.edu.au)	

program define lclogitcov, sortpreserve
	version 11.2
	if ("`e(cmd)'" != "lclogit")&("`e(cmd)'" != "lclogitml") error 301
	local indepvars "`e(indepvars)'"
	local K : word count `indepvars'
	syntax varlist(max=`K') [if] [in] [,NOkeep VARname(name) COVname(name) MATrix(name)] 
	tempname up pr ac coefs covc
	tempvar ncm 
	**Check varlist includes indepvars in the choice model**
	local check : list varlist in indepvars 
	if `check' != 1 {
		display as error "no lclogit estimate exists for the specified variables."
		error 197
	}

	**Define macros to facilitate naming the covariance variable**
	local i = 0
	foreach v of varlist `varlist' {
		local i = `i' + 1
		local var`i' `v'		
	}
	
	**Check variable names are not in use**
	if ("`varname'" == "") local varname var_
	if ("`covname'" == "") local covname cov_

	forvalues j = 1/`i' {
		capture confirm new variable `varname'`j'
		if (_rc != 0) {
			di as error "`varname'`j' already defined."  
			exit 110 
		}
		if (`j'<`i') {
			forvalues k = `=`j'+1'/`i' {
				capture confirm new variable `covname'`j'`k' 
				if (_rc != 0) {
					di as error "`covname'`j'`k'  already defined."  
					exit 110 
				}
			}
		}
	}	
	
	** Check that group, id and other explanatory variables are numeric **
	foreach v of varlist `e(group)' `e(id)' `e(indepvars)' `e(indepvars2)' {
		capture confirm numeric variable `v'
		if _rc != 0 {
			display as error "variable `v' is not numeric."
			exit 498
		}
	}	
	
	**Mark prediction sample**
	marksample touse, novarlist
	
	**Generate variables to hold variances and covariances**
	forvalues j = 1/`i' {
		qui gen double `varname'`j' = 0 if `touse' 
	}
	forvalues j = 1/`i' {
		if (`j'<`i') {
			forvalues k = `=`j'+1'/`i' {
				qui gen double `covname'`j'`k' = 0 if `touse'
			}
		}
	}
	
	**Generate a binary indicator which equals one for the last obs on each agent** 
	sort `e(id)' `e(group)'
	qui by `e(id)' : gen byte `ncm' = [_n==_N] if `touse'
	
	**Predict class shares and their averages**
	lclogitpr double `up' if `touse', up
	forvalues c = 1/`e(nclasses)' {
		qui sum `up'`c' if `ncm' == 1, meanonly
		local p`c' = r(mean)
		matrix `pr' = nullmat(`pr') \ `p`c'' 
	}
	
	**Compute average taste parameter estimates**
	**NOTE: Also collect items helpful for construction of the covariance matrix later.**
	**		These items are marked by //L. 
	matrix `coefs' = J(`e(nclasses)',`i',.) //L
	local h = 0	//L
	foreach v of varlist `varlist' {
		local mu`v' = 0
		local h = `h' + 1 //L 
		forvalues c = 1/`e(nclasses)' {
			local mu`v' = `mu`v'' + `p`c''*_b[choice`c':`v']
			matrix `coefs'[`c',`h'] = _b[choice`c':`v'] //L
		}		
		matrix `ac' = nullmat(`ac') , `mu`v'' //L
		local coefname `coefname' `v' //L
	}
qui {
	**Compute variance**
	forvalues j = 1/`i' {
		forvalues c = 1/`e(nclasses)' {
			replace `varname'`j' = `varname'`j' + `up'`c'*(`=_b[choice`c':`var`j'']-`mu`var`j'''')^2 if `touse'
		}
		label variable `varname'`j' `"variance of coeff on `var`j''"'
		if (`j'<`i') {
			forvalues k = `=`j'+1'/`i' {
				forvalues c = 1/`e(nclasses)' {
					replace `covname'`j'`k' = `covname'`j'`k' + `up'`c'*(`=_b[choice`c':`var`j'']-`mu`var`j'''')*(`=_b[choice`c':`var`k'']-`mu`var`k'''') if `touse'
				}
				label variable `covname'`j'`k' `"cov b/w coeffs on `var`j'' and `var`k''"'
			}
		}
	}	 
}
	**Create the covariance matrix of choice model parameters**	
	mat `covc' = `coefs''*`coefs' 
	mata: st_replacematrix("`covc'",(st_matrix("`pr'"):*(st_matrix("`coefs'"):-st_matrix("`ac'")))'*(st_matrix("`coefs'"):-st_matrix("`ac'")))
	mat colnames `covc' = `coefname' 	
	mat rownames `covc' = `coefname'
	di as txt ""
	di as txt "	Implied variances and covariances of choice model coefficients"  
	di as txt "	   	averaged across `e(id)' in the prediction sample." 
	mat list `covc', noheader 
	if ("`matrix'" != "") mat `matrix' = `covc'
	
	**Drop variance and covariance variables if option nokeep is specified**
	if "`nokeep'" != "" {	
		forvalues j = 1/`i' {
				drop `varname'`j' 
			if (`j'<`i') {
				forvalues k = `=`j'+1'/`i' {
					drop `covname'`j'`k' 
				}
			}
		}		
	}
end
