*! version 1.2.0 30Nov2011 MLB
program define marg_betahangroot_prep
	version 10.1
	syntax , sims(integer)     ///
	        [                  ///
			hangr_opts(string) ///	
			noPArsamp          ///
			*                  /// 
			]
	
	tempvar touse alpha beta

	qui gen byte `touse' = e(sample)

	if "`parsamp'" == "" {
		qui gen `alpha' = .
		qui gen `beta' = .
		tempname bname vname orig
		matrix `bname' = e(b)
		matrix `vname' = e(V)
		est store `orig'
		
		forvalues i = 1/`sims' {
			tempvar sim`i'
			qui drop `alpha' `beta'
			marg_parsamp, bname(`bname') v(`vname')
			qui predict double `alpha' if `touse' , alpha 
			qui predict double `beta' if `touse' , beta			
			qui gen `sim`i'' = rbeta(`alpha', `beta') if `touse'
			local simvars "`simvars' `sim`i''"
		}
		qui est restore `orig'
	}
	else {
		qui predict double `alpha' if `touse' , alpha 
		qui predict double `beta' if `touse' , beta
		
		forvalues i = 1/`sims' {
			tempvar sim`i'
			qui gen `sim`i'' = rbeta(`alpha', `beta') if `touse'
			local simvars "`simvars' `sim`i''"
		}
	}
	hangroot , sims(`simvars') `hangr_opts' `options'

end
