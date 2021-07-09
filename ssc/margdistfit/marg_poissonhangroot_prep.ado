*! version 1.3.0 17Mar2012 MLB
program define marg_poissonhangroot_prep
	version 10.1
	syntax , sims(integer)     ///
	        [                  ///
			hangr_opts(string) ///	
			noPArsamp          ///
			simci              ///
			level(cilevel)     ///
			*                  /// 
			]
	
	tempvar touse mu

	qui gen byte `touse' = e(sample)

	if "`parsamp'" == "" {
		qui gen `mu' = .
		tempname bname vname orig
		matrix `bname' = e(b)
		matrix `vname' = e(V)
		est store `orig'
		
		forvalues i = 1/`sims' {
			tempvar sim`i'
			qui drop `mu'
			marg_parsamp, bname(`bname') v(`vname')
			qui predict double `mu' if `touse' , n
			qui gen `sim`i'' = rpoisson(`mu') if `touse'
			local simvars "`simvars' `sim`i''"
		}
		qui est restore `orig'
	}
	else {
		qui predict double `mu' if `touse' , n 
		
		forvalues i = 1/`sims' {
			tempvar sim`i'
			qui gen `sim`i'' = rpoisson(`mu') if `touse'
			local simvars "`simvars' `sim`i''"
		}
	}
	hangroot , sims(`simvars') `hangr_opts' `options' `simci' level(`level')

end
