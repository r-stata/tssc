*!version 1.0.0 5Feb2011
*! Pesaran (2004) CD test 
* Bugs:
*
* For feedback please email me at markus.eberhardt@economics.ox.ac.uk
* Visit https://sites.google.com/site/medevecon/ for macro panel data and other Stata routines

capture program drop xtcd
program define xtcd, rclass prop(xt) 

version 10
	
	syntax varlist(max=6 numeric) [if] [in] [, OFF RESID]

	preserve

quietly{

	qui tsset 
	local ivar "`r(panelvar)'"
	local tvar "`r(timevar)'"
	marksample touse

/* Tokenize varlist */
	tokenize `varlist'
*     local ind `varlist'
      local ind "`*'"
      local dep : word count `varlist'
	if `dep'>9{
		di as error "A maximum of 9 variable series can be tested at any one point."
		exit
	}
*     local ind "`r(varlist)'"

/* Create group variable */
	tempvar g 
	egen `g' = group(`ivar') if `touse'
	sum `g' if `touse'
	local ng = r(max)

/* Modifying the data set to get a column of residuals for each cross-section */
	drop if missing(`g')
	qui keep `ind' `g' `tvar'
	qui reshape wide `ind', i(`tvar') j(`g') 

/* Creating the covariance matrix */
	tempname E ABS Nobs COR
	forvalues m=1/`dep'{
		tokenize `varlist'
		local name : word `m' of `varlist'
		tempname `E'`name' `ABS'`name' `Nobs'`name' `COR'`name'
		mat `Nobs'`name' = J(`ng',`ng',1)
		mat `E'`name' = J(`ng',`ng',1)
		mat `ABS'`name' = J(`ng',`ng',1)
		mat `COR'`name' = J(`ng',`ng',1)
	}
* whilst just testing keep this!
*		mat `Nobs' = J(`ng',`ng',1)
*		mat `E' = J(`ng',`ng',1)
*		mat `ABS' = J(`ng',`ng',1)
*		mat `COR' = J(`ng',`ng',1)

	forvalues i = 1/`ng' {
		forvalues j = 1/`ng' {
				forvalues m = 1/`dep'{
					local ind : word `m' of `varlist'
					if "`resid'" != "" {
						tempvar `ind'`i'M `ind'`j'N `ind'`i'M `ind'`j'U
						egen `ind'`i'M=mean(`ind'`i') if !missing(`ind'`i') & !missing(`ind'`j')
						gen `ind'`i'U=`ind'`i'-`ind'`i'M if !missing(`ind'`i'M)
						if `i'==`j'{
							qui cap corr `ind'`i'U `ind'`i'U	
							drop `ind'`i'U `ind'`i'M
						}
						else{
							egen `ind'`j'M=mean(`ind'`j') if !missing(`ind'`i') & !missing(`ind'`j')
							gen `ind'`j'U=`ind'`j'-`ind'`j'M if !missing(`ind'`j'M) 
 							qui cap corr `ind'`i'U `ind'`j'U
							if _rc==2000 | `r(N)'==2 {
								di " "
								di in red "Error: The panel is highly unbalanced." 
								di in red "Not enough common observations across panel to perform Pesaran's test."
								error 2001
                  					}
							drop `ind'`i'U `ind'`j'U `ind'`i'M `ind'`j'M
						}
					}
					if "`resid'" == "" {
						qui cap corr `ind'`i' `ind'`j'
						if _rc==2000 | `r(N)'==2 {
							di " "
							di in red "Error: The panel is highly unbalanced." 
							di in red "Not enough common observations across panel to perform Pesaran's test."
							error 2001
                  				}
					}
					local name : word `m' of `varlist'
					mat `E'`name'[`i',`j'] = `r(rho)'*sqrt(`r(N)')
					mat `Nobs'`name'[`i',`j'] = `r(N)'
					mat `ABS'`name'[`i',`j'] = abs(`r(rho)')
					mat `COR'`name'[`i',`j'] = `r(rho)'
				} 
* end of variable loop
		} 
* end of j loop
	} 
* end of i loop

/* Creating a 1x1 ``matrix'' with the sum of the matrix E (including element by element multiplication by T_{ij}) */
	tempname A B C D F
	forvalues m = 1/`dep'{
		local name : word `m' of `varlist'
		tempname `A'`name' `B'`name' `C'`name' `D'`name' `F'`name'
		mat `A'`name' = J(colsof(`E'`name'),1,1)
    		mat `B'`name' = `A'`name''*`E'`name'*`A'`name'
		mata: `C'`name' = st_matrix("`Nobs'`name'")
		mata: `C'`name' = vec(`C'`name')
		mata: `C'`name' = colsum(`C'`name')
		mata: st_matrix("`C'`name'", `C'`name')
		mat `D'`name' = `A'`name''*`ABS'`name'*`A'`name'
		mat `F'`name' = `A'`name''*`COR'`name'*`A'`name'

	}


/* Compute Test */
	tempname pesaranM pesaranabsM vmM absvmM avg_obsM numb_coeffM n_obsM
	mat `pesaranM'	= J(`dep',1,0)
	mat `pesaranabsM'	= J(`dep',1,0)
	mat `vmM'		= J(`dep',1,0)
	mat `absvmM'		= J(`dep',1,0)
	mat `avg_obsM'	= J(`dep',1,0)
	mat `numb_coeffM'	= J(`dep',1,0)
	mat `n_obsM'		= J(`dep',1,0)


*	tempname pesaran pesaranabs v vm absv absvm nobs avg_obs corr_coeff
	forvalues m = 1/`dep'{
		local name : word `m' of `varlist'
*		tempname `pesaran'`name' `pesaranabs'`name' `v'`name' `vm'`name' `absv'`name' `absvm'`name' `nobs'`name' `avg_obs'`name' `corr_coeff'`name'
		local pesaran = sqrt( 2/(`ng'*(`ng'-1))) *(`B'`name'[1,1]-trace(`E'`name'))/2
		local pesaranabs = abs(`pesaran')
		mat `pesaranM'[`m',1] = `pesaran'
		mat `pesaranabsM'[`m',1]= `pesaranabs'
		local v =  (`F'`name'[1,1]-trace(`COR'`name'))/2
		local vm = `v'*2/(`ng'*(`ng'-1))
		local absv =  (`D'`name'[1,1]-trace(`ABS'`name'))/2
		local absvm = `absv'*2/(`ng'*(`ng'-1))
		mat `vmM'[`m',1]	= `vm' 
		mat `absvmM'[`m',1]= `absvm'
		local nobs = `C'`name'[1,1]
		local avg_obs = `nobs'/(`ng'*(`ng'-1))
		local corr_coeff = `ng'*(`ng'-1)
		mat `avg_obsM'[`m',1]	= `avg_obs'
		mat `numb_coeffM'[`m',1]	= `corr_coeff' 
		mat `n_obsM'[`m',1]= `nobs'

	}

	restore  
} 
* end of quietly

	di ""
	di ""
	di in gr _col(2) "Average correlation coefficients & Pesaran (2004) CD test"
	di ""
	if ("`resid'")!=""{
		di in gr _col(2) "Residual series tested: " in ye _col(20) "`varlist'" 
		local var_or_res = "variables"
	}
	else {
		di in gr _col(2) "Variables series tested: " in ye _col(20) "`varlist'" 
		local var_or_res = "residuals"
	}

	di in gr  										    _col(32) "Group variable: " in ye _col(47) "`ivar'"    
	di in gr 										    _col(30) "Number of groups: " in ye _col(47) "`ng'"
	di in gr 										    _col(21) "Average # of observations: " in ye _col(47) %-4.2f `avg_obsM'[1,1]
	if `avg_obsM'[1,1]!= round(`avg_obsM'[1,1]){
	di in gr 				   						                      _col(38) "Panel is: " in ye _col(47) "unbalanced" 
	}
	else di in gr 									                      _col(38) "Panel is: " in ye _col(47) "balanced" 
	di ""
	di as text "{hline 13}{c TT}{hline 43}"
	di as text _col(2) "   Variable" " {c |}" _col(19) "CD-test" _col(28) "p-value" _col(40) "corr" _col(46) "abs(corr)"  
	di as text "{hline 13}{c +}{hline 43}"
		forvalues m=1/`dep'{
			local name : word `m' of `varlist'
			di as text %12s abbrev("`name'",12) " {c |}" as result _col(19) %7.2f  `pesaranM'[`m',1]  _continue
			di as result _col(28) %7.3f 2*(1-normal(`pesaranabsM'[`m',1])) _col(39) %5.3f `vmM'[`m',1] _continue
			di as result _col(48) %5.3f `absvmM'[`m',1]  
			if (`m' < `dep') {
     				di as text "{hline 13}{c +}{hline 43}"
      			}
			else {
     				di as text "{hline 13}{c BT}{hline 43}"
			}
		}
	di in gr _col(2) "Notes: Under the null hypothesis of cross-section "
	di in gr _col(9) "independence CD ~ N(0,1)"

	return matrix avg_obs = `avg_obsM'
	return matrix numb_coeff = `numb_coeffM'
	return scalar N_g = `ng'
	return matrix pesaran = `pesaranM'
	return matrix avgcorr = `vmM'
	return matrix abscorr = `absvmM'
	return matrix nobs = `n_obsM'
	return local variables `var_or_res'
	return local varname `varlist'

end

