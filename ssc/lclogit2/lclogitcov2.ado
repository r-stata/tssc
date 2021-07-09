*! Author: Hong Il Yoo (h.i.yoo@durham.ac.uk) 
*! HIY 1.1.0 24 February 2019

program define lclogitcov2, sortpreserve
	version 13.1
	if ("`e(cmd)'" != "lclogit2")&("`e(cmd)'" != "lclogitml2") error 301
	local indepvars_rand "`e(indepvars_rand)'"
	local K : word count `indepvars_rand'
	syntax varlist(max=`K') [if] [in] [, NOkeep VARname(name) COVname(name) MATrix(name)] 
	tempname up CB
	tempvar ncm 
	**Check varlist includes indepvars in the choice model**
	local check : list varlist in indepvars_rand 
	if `check' != 1 {
		display as error "some of specified variables do not have heterogeneous coefficients."
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
	foreach v of varlist `e(group)' `e(id)' `e(indepvars_rand)' `e(indepvars_share)' {
		capture confirm numeric variable `v'
		if _rc != 0 {
			display as error "variable `v' is not numeric."
			exit 498
		}
	}	
	
	**Mark prediction sample**
	marksample touse, novarlist
	
	**Generate variables to hold means, variances and covariances**
	forvalues j = 1/`i' {
		tempvar mean`var`j''
		qui gen double `mean`var`j''' = 0 if `touse'
	}
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
	
	**Predict class shares**
	lclogitpr2 double `up' if `touse', up

	qui {
		**Compute mean taste parameter estimates**
		foreach v of varlist `varlist' {
			forvalues c = 1/`e(nclasses)' {
				replace `mean`v'' = `mean`v'' + `up'`c'*_b[Class`c':`v'] if `touse'
			}		
			local coefname `coefname' `v'
		}

		**Compute variances and covariances**
		forvalues j = 1/`i' {
			forvalues c = 1/`e(nclasses)' {
				replace `varname'`j' = `varname'`j' + `up'`c'*(_b[Class`c':`var`j''] - `mean`var`j''')^2 if `touse'
			}
			label variable `varname'`j' `"variance of coef on `var`j''"'
			if (`j'<`i') {
				forvalues k = `=`j'+1'/`i' {
					forvalues c = 1/`e(nclasses)' {
						replace `covname'`j'`k' = `covname'`j'`k' + `up'`c'*(_b[Class`c':`var`j''] - `mean`var`j''')*(_b[Class`c':`var`k''] - `mean`var`k''') if `touse'
					}
					label variable `covname'`j'`k' `"cov b/w coefs on `var`j'' and `var`k''"'
				}
			}
		}	 
	}
	
	**Create the covariance matrix of choice model parameters**	
	mat `CB' = J(`i',`i',.)
	forvalues j = 1/`i' {
		qui sum `varname'`j' if `ncm' == 1, meanonly
		matrix `CB'[`j', `j'] = r(mean)
		if (`j'<`i') {
			forvalues k = `=`j'+1'/`i' {
				qui sum `covname'`j'`k' if `ncm' == 1, meanonly
				matrix `CB'[`j', `k'] = r(mean)
				matrix `CB'[`k', `j'] = r(mean)
			}
		}		
	}
	mat colnames `CB' = `coefname' 	
	mat rownames `CB' = `coefname'
	di as txt ""
	di as txt "	Implied variances and covariances of random coefficients"  
	di as txt "	   	averaged across `e(id)' in the prediction sample." 
	mat list `CB', noheader 
	if ("`matrix'" != "") mat `matrix' = `CB'
	
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
