*! version 2.1.0 Stephen P. Jenkins, March 2020
*!  add reporting of rho_f to results table & saved results
*! version 2.0.0 Stephen P. Jenkins, March 2009
*!  update to version 8.2
*! version 1.0.0 Stephen P. Jenkins, Dec 1998
*! Decomposition of inequality of total income by
*! factor components (after Shorrocks, 1982, 1984)

program define ineqfac, sortpreserve rclass

	version 8.2

	
	syntax varlist(min=2 numeric) [aweight fweight pweight iweight] [if] [in] ///
		[, i2 Stats TOTal(string) ]
	
	local nfac : word count `varlist'
	return local nfactor = `nfac'
	return local varlist `varlist'
	tempvar wi  
	tokenize `varlist'


quietly {	

	if "`weight'" == "" ge `wi' = 1
	else ge `wi' `exp'

	if "`total'" != "" confirm new variable `total' 
	else tempvar total

	marksample touse
	markout `touse' `varlist' 
	set more off

	count if `touse'
	if `r(N)' == 0 error 2000 

	if "`i2'" != "" { 	
		forvalues i = 1/`nfac' {
			su ``i'' [w = `wi'] if `touse', meanonly
			if r(mean) <= 0 {
				di as error "Mean of ``i'' <= 0"
				exit 411
			}
		}
	}



	egen double `total' = rsum(`varlist') if `touse'
	label var `total' "Total"

	su `total' [w = `wi'] if `touse'
	local meantot = r(mean)
	local vartot =  r(Var)
	local sdtot = r(sd)
	local cvtot = `sdtot'/`meantot'

	return local mean_total = `meantot'
	return local var_total = `vartot'
	return local sd_total = `sdtot'
	return local cv_total = `cvtot'
	return local N = r(N)

	noisily {	
    		di " "
    		di as txt "Inequality decomposition by factor components (Shorrocks' method)"
	    	di as txt in smcl "{hline 20}{c TT}{hline 58}"
    		di as txt "Factor" _col(21) in smcl "{c |}" _c 
			di as txt _skip(2) "100*s_f     S_f" _c
	
		if "`i2'" == "" {
			di as txt _skip(1) "  100*m_f/m  rho_f   CV_f" _c
			di as txt _skip(1) "CV_f/CV(Total)"
		}

		else if "`i2'" != "" {
			di as txt _skip(1) "  100*m_f/m  rho_f   I2_f" _c
			di as txt _skip(1) "I2_f/I2(Total)"
		}
	    	di as txt in smcl "{hline 20}{c +}{hline 58}"
	}


	forvalues i = 1/`nfac' {

		su ``i'' [w = `wi'] if `touse'

		local mean`i' = r(mean)
		local var`i' =  r(Var)
		local sd`i' = r(sd)
		local cv`i' = `sd`i''/(`mean`i'')
		regress ``i'' `total'  [w = `wi'] if `touse'
		local sf`i' = _b[`total']
		corr `total' ``i''
		local rho`i' = r(rho)		
		
		return local mean_``i'' = `mean`i''
		return local var_``i'' = `var`i''
		return local sd_``i'' = `sd`i''
		return local cv_``i'' = `cv`i''		
		return local sf_``i'' = `sf`i''
		return local share_``i'' = `mean`i''/`meantot'
		return local rho_``i'' = `rho`i''

		noi di as txt "``i''" _col(21) in smcl "{c |}" _c
		noi di _skip(3) as res %6.3f 100*`sf`i'' _c
		if "`i2'" == "" {
			noi di _skip(3) as res %6.3f `sf`i''*`cvtot' _c
			noi di _skip(3) as res %6.3f 100*`mean`i''/`meantot' _c
			noi di _skip(2) as res %6.3f  `rho`i'' _c	
			noi di _skip(2) as res %6.3f `cv`i'' _c
			noi di _skip(3) as res %6.3f `cv`i''/`cvtot'
		
		}
		if "`i2'" != "" {	
			noi di _skip(3) as res %6.3f `sf`i''*.5*(`cvtot')^2 _c
			noi di _skip(3) as res %6.3f 100*`mean`i''/`meantot' _c
			noi di _skip(2) as res %6.3f  `rho`i'' _c
			noi di _skip(2) as res %6.3f .5*(`cv`i'')^2 _c
			noi di _skip(3) as res %6.3f (`cv`i''/`cvtot')^2 
			
		}

	}

		noisily {
		    di as txt in smcl "{hline 20}{c +}{hline 58}"
			di as txt "Total" _col(21) in smcl "{c |}" _c
			di _skip(2) as res %6.3f "100.000" _c
	
			if "`i2'" == "" {
				di _skip(3) as res %6.3f `cvtot' _c
				di _skip(2) as res %6.3f "100.000" _c
				di _skip(3) as res %6.3f "1.000" _c
				di _skip(2) as res %6.3f `cvtot' _c
			}
			if "`i2'" != "" {
				di _skip(3) as res %6.3f .5*(`cvtot')^2 _c
				di _skip(2) as res %6.3f "100.000" _c
				di _skip(3) as res %6.3f "1.000" _c				
				di _skip(2) as res %6.3f .5*(`cvtot')^2 _c
			}
			di _skip(4) as res %6.3f "1.000"

		    di as txt in smcl "{hline 20}{c BT}{hline 58}"

			di as txt "Note: s_f is the proportionate contribution of factor f"
			di as txt _skip(1) "to inequality of Total, where ..."
			di as txt " s_f = rho_f*sd(f)/sd(Total) "
			di as txt "     = rho_f*[m(factor_f)/m(totvar)]*[CV(factor_f)/CV(totvar)]." 
			if "`i2'" == "" {
				di as txt _skip(1) "S_f = s_f*CV(Total). rho_f = corr(f,Total). "
				di as txt _skip(1) "m_f = mean(f). sd(f) = std.dev. of f." _c 
				di as txt _skip(1) "CV_f = sd(f)/m_f."
			}
			if "`i2'" != "" {
				di as txt _skip(1) "S_f = s_f*CV(Total). rho_f = corr(f,Total). "
				di as txt _skip(1) "m_f = mean(f). sd(f) = std.dev. of f." _c 
				di as txt _skip(1) "I2_f = .5*[sd(f)/m_f]^2."
			}

		}

	* Optionally Produce correlations, means, and std deviations 

	if "`stats'" != "" {
	 	nobreak {
		   	rename `total' Total
		   	noi di " "
	   		noi di "Means, s.d.s and correlations for factors and total income"
	   		noi corr `varlist' Total [w = `wi'] if `touse', means
	   		rename Total `total'
         	}
	}


}  /* end of quietly block */


end


