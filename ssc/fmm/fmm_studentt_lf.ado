*! version 2.1.0 12feb2012
*! author: Partha Deb
* version 1.1.0  12jul2007
* version 1.1.0  12jul2007

program fmm_studentt_lf
	version 9.2

	forvalues i = 1/$fmm_components {
		local L_xb `"`L_xb' xb`i'"'
		local L_fxb `"`L_fxb' fxb`i'"'
		local L_pr `"`L_pr' pr`i'"'
		local L_z `"`L_z' z`i'"'
		local L_lsig `"`L_lsig' lnsigma`i'"'
		local L_sig `"`L_sig' sigma`i'"'
		local L_gb `"`L_gb' gb`i'"'
		local L_gs `"`L_gs' gs`i'"'
		local L_z2bydf `"`L_z2bydf' z2bydf`i'"'
		local L_inv1plz2bydf `"`L_inv1plz2bydf' inv1plz2bydf`i'"'
	}

	forvalues i = 1/`=3*$fmm_components-1' {
		local L_gL `"`L_gL' gL`i'"'
		forvalues j = `i'/`=3*$fmm_components-1' {
			local L_h `"`L_h' h`i'`j'"'
			local L_nh `"`L_nh' nh`i'`j'"'
		}
	}

	forvalues i = 1/`=$fmm_components-1' {
		local L_lpr `"`L_lpr' lpr`i'"'
		forvalues j = 1/`=$fmm_components-1' {
			local L_ga `"`L_ga' ga`i'`j'"'
		}
	}

	// model arguments and temporary variables
	args todo b lnf g negH `L_gL'
	tempname `L_xb' `L_fxb' `L_lsig' `L_sig' `L_lpr' `L_pr' `L_z' ///
						den prob gi `L_gb'  `L_ga' `L_gs' hij `L_h' `L_nh' ///
						dfpl1 `L_z2bydf' `L_inv1plz2bydf'

	// set up equations
	forvalues i=1/$fmm_components {
		mleval `xb`i'' = `b', eq(`i')
		mleval `lnsigma`i'' = `b', eq(`=2*$fmm_components-1+`i'')
		qui gen double `sigma`i'' = exp(`lnsigma`i'')
	}

	qui gen double `den' = 1
	forvalues i=1/`=$fmm_components-1' {
		mleval `lpr`i'' = `b', eq(`=$fmm_components+`i'')
		qui replace `den' = `den' + exp(`lpr`i'')
	}

	forvalues i=1/`=$fmm_components-1' {
		qui gen double `pr`i'' = exp(`lpr`i'')/`den'
	}

	qui gen double `pr$fmm_components' = 1
	forvalues i=1/`=$fmm_components-1' {
		qui replace `pr$fmm_components' = `pr$fmm_components' - `pr`i''
	}


	// calculate the likelihood function
	qui gen double `prob' = 0
	forvalues i=1/$fmm_components {
		qui gen double `z`i'' = ($ML_y-`xb`i'')/`sigma`i''
		qui gen double `z2bydf`i'' = (`z`i''^2)/$fmm_tdf
		qui gen double `inv1plz2bydf`i'' = 1/(1 + `z2bydf`i'')
		qui gen double `fxb`i'' = tden($fmm_tdf,`z`i'')/`sigma`i''
		qui replace `prob' = `prob' + `pr`i''*`fxb`i''
	}

	mlsum `lnf' = ln(`prob')


	// CALCULATE GRADIENT TERMS
	qui gen double `dfpl1' = $fmm_tdf + 1
	// gradient bi
	forvalues i = 1/$fmm_components {
		qui gen double `gb`i'' = `dfpl1' * `inv1plz2bydf`i'' ///
													* `z`i'' / ($fmm_tdf*`sigma`i'') // density specific
		qui replace `gL`i'' = (`pr`i'' * `fxb`i'' * `gb`i'')/`prob'
	}

	// gradient prj
	forvalues j = 1/`=$fmm_components-1' {
		local m = `=$fmm_components+`j''
		qui replace `gL`m'' = 0
		forvalues k = 1/`=$fmm_components-1' {
			qui gen double `ga`k'`j'' = ((`j'==`k') - `pr`j'')
			qui replace `gL`m'' = `gL`m'' + `pr`k''*`ga`k'`j'' ///
											*(`fxb`k'' - `fxb$fmm_components')/`prob'
		}
	}

	// gradient sigmai
	forvalues i=1/$fmm_components {
		local k = `=2*$fmm_components-1+`i''
		qui gen double `gs`i'' = `dfpl1' * `inv1plz2bydf`i'' ///
															* `z2bydf`i'' - 1 // density specific
		qui replace `gL`k'' = (`pr`i'' * `fxb`i'' * `gs`i'')/`prob'
	}

	// collect gradient terms into vector
	local np = colsof(`b')
	local c 1
	matrix `g' = J(1,`np',0)
	
	forvalues i = 1/`=3*$fmm_components-1' {
		mlvecsum `lnf' `gi' = `gL`i'', eq(`i')
		matrix `g'[1,`c'] = `gi'
		local c = `c' + colsof(`gi')
	}


	// CALCULATE HESSIAN TERMS
	// hessian - b terms
	local c 1
	qui gen double `hij' = .
	forvalues i = 1/$fmm_components {
		// hessian (bi,bi)
		qui replace `hij' = `dfpl1' * `inv1plz2bydf`i'' / ($fmm_tdf*(`sigma`i''^2)) ///
							* (`inv1plz2bydf`i'' * 2 * `z2bydf`i'' - 1) 		// density specific
		qui gen double `h`i'`i'' = `pr`i''/`prob'*`fxb`i'' ///
			*(-`gL`i''*`gb`i'' + `gb`i''^2 + `hij')
		mlmatsum `lnf' `nh`i'`i'' = -`h`i'`i'', eq(`i',`i')
		// hessian (bi,bj)
		if (`i'<$fmm_components) {
			forvalues j = `=`i'+1'/$fmm_components {
				qui gen double `h`i'`j'' = `pr`i''/`prob'*(-`gL`j''*`fxb`i''*`gb`i'')
				mlmatsum `lnf' `nh`i'`j'' = -`h`i'`j'', eq(`i',`j')
			}
		}

		// hessian (bi,prj)
		if (`i'<$fmm_components) {
			forvalues j = 1/`=$fmm_components-1' {
				local m = `=$fmm_components+`j''
				qui gen double `h`i'`m'' = -`gL`m''*`gL`i'' ///
						+ 1/`prob'*`fxb`i''*`gb`i''*`pr`i''*`ga`i'`j''
				mlmatsum `lnf' `nh`i'`m'' = -`h`i'`m'', eq(`i',`m')
			}
		}
		else {
			forvalues j = 1/`=$fmm_components-1' {
				local m = `=$fmm_components+`j''
				qui gen double `h`i'`m'' = -`gL`m''*`gL`i'' 
					forvalues k = 1/`=$fmm_components-1' {
						qui replace `h`i'`m'' = `h`i'`m'' ///
							- 1/`prob'*`fxb`i''*`gb`i''*`pr`k''*`ga`k'`j''
					}
				mlmatsum `lnf' `nh`i'`m'' = -`h`i'`m'', eq(`i',`m')
			}
		}


		// hessian (bi,sigma)
		forvalues j = 1/$fmm_components {
			local k = `=2*$fmm_components-1+`j''
			// hessian (bi,sigmai)
			if (`i'==`j') {
				qui replace `hij' = -2 * `dfpl1' * `inv1plz2bydf`i'' * `z`i'' ///
														/ ($fmm_tdf*`sigma`i'')           ///
														* (1 - `inv1plz2bydf`i'' * `z2bydf`i'')	// density specific
				qui gen double `h`i'`k'' = `pr`i''/`prob'*`fxb`i'' ///
					*(-`gL`k''*`gb`i'' + `gs`j''*`gb`i'' + `hij')
				mlmatsum `lnf' `nh`i'`k'' = -`h`i'`k'', eq(`i',`k')
			}
			else {
			// hessian (bi,sigmaj)
				qui gen double `h`i'`k'' = `pr`i''/`prob'*(-`gL`k''*`fxb`i''*`gb`i'')
				mlmatsum `lnf' `nh`i'`k'' = -`h`i'`k'', eq(`i',`k')
			}
		}
	}

	// hessian - pr terms
	// hessian (prj,pri)
	forvalues i = 1/`=$fmm_components-1' {
		forvalues j = `i'/`=$fmm_components-1' {
			local m = `=$fmm_components+`i''
			local n = `=$fmm_components+`j''
			qui gen double `h`m'`n'' = -`gL`m''*`gL`n''
			qui replace `hij' = -`pr`i''*((`i'==`j') - `pr`j'')
			forvalues k = 1/`=$fmm_components-1' {
				qui replace `h`m'`n'' = `h`m'`n'' ///
						+ 1/`prob'*`pr`k''*(`fxb`k'' - `fxb$fmm_components') ///
						*(`ga`k'`i''*`ga`k'`j'' + `hij')
			}
			mlmatsum `lnf' `nh`m'`n'' = -`h`m'`n'', eq(`m',`n')
		}
	}


	// hessian - sigma terms
	forvalues i = 1/$fmm_components {
		// hessian w.r.t. sigmai
		local m = `=2*$fmm_components-1+`i''
		qui replace `hij' = 2 * `dfpl1' * `inv1plz2bydf`i'' * `z2bydf`i''	///
												* (`inv1plz2bydf`i'' * `z2bydf`i'' - 1)		  // density specific
		qui gen double `h`m'`m'' = `pr`i''/`prob'*`fxb`i'' ///
			*(-`gL`m''*`gs`i'' + `gs`i''^2 + `hij')
		mlmatsum `lnf' `nh`m'`m'' = -`h`m'`m'', eq(`m',`m')
		// hessian w.r.t. sigmaj (cross partials)
		forvalues j = `=`i'+1'/$fmm_components {
			local n = `=2*$fmm_components-1+`j''
			qui gen double `h`m'`n'' = `pr`i''/`prob'*(-`gL`n''*`fxb`i''*`gs`i'')
			mlmatsum `lnf' `nh`m'`n'' = -`h`m'`n'', eq(`m',`n')
		}

	// hessian (sigmai,prj)
		if (`i'<$fmm_components) {
			forvalues j = 1/`=$fmm_components-1' {
				local n = `=2*$fmm_components-1+`i''
				local m = `=$fmm_components+`j''
				qui gen double `h`m'`n'' = -`gL`m''*`gL`n'' ///
						+ 1/`prob'*`fxb`i''*`gs`i''*`pr`i''*`ga`i'`j''
				mlmatsum `lnf' `nh`m'`n'' = -`h`m'`n'', eq(`m',`n')
			}
		}
		else {
			forvalues j = 1/`=$fmm_components-1' {
				local n = `=2*$fmm_components-1+`i''
				local m = `=$fmm_components+`j''
				qui gen double `h`m'`n'' = -`gL`m''*`gL`n'' 
					forvalues k = 1/`=$fmm_components-1' {
						qui replace `h`m'`n'' = `h`m'`n'' ///
							- 1/`prob'*`fxb`i''*`gs`i''*`pr`k''*`ga`k'`j''
					}
				mlmatsum `lnf' `nh`m'`n'' = -`h`m'`n'', eq(`m',`n')
			}
		}
	}

	// collect hessian terms into matrix
	local np = colsof(`b')
	local r 1
	matrix `negH' = J(`np',`np',0)
	
	forvalues i = 1/`=3*$fmm_components-1' {
		local c = `r'
		forvalues j = `i'/`=3*$fmm_components-1' {
			matrix `negH'[`r',`c'] = `nh`i'`j''
			if (`j'>`i') {
				matrix `negH'[`c',`r'] = `nh`i'`j'''
			}
			local c = `c' + colsof(`nh`i'`j'')
		}
		local r = `r' + rowsof(`nh`i'`i'')
	}

end
