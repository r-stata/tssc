*! version 1.3.0 17Mar2012 MLB
program define marg_nb1hangroot_prep
	version 10.1
	syntax , sims(integer)     ///
	        [                  ///
			hangr_opts(string) ///	
			noPArsamp          ///
			*                  /// 
			]
	
	tempvar touse lambda idelta xg

	qui gen byte `touse' = e(sample)

	if "`parsamp'" == "" {
		qui gen `lambda' = .
		qui gen `idelta' = .
		qui gen `xg'     = .
		tempname bname vname orig
		matrix `bname' = e(b)
		matrix `vname' = e(V)
		est store `orig'
		
		forvalues i = 1/`sims' {
			tempvar sim`i'
			qui drop `lambda' `idelta' `xg'
			marg_parsamp, bname(`bname') v(`vname')
			qui predict double `lambda' if `touse' , xb eq(#1)
			qui replace `lambda' = exp(`lambda')
			qui predict double `idelta' if `touse', xb eq(#2)
			qui replace `idelta' = 1/exp(`idelta')*`lambda'
			qui gen double `xg' = rgamma(`idelta', 1/`idelta')
			qui gen `sim`i'' = rpoisson(`lambda'*`xg') if `touse'
			local simvars "`simvars' `sim`i''"
		}
		qui est restore `orig'
	}
	else {
		qui predict double `lambda' if `touse' , xb eq(#1)
		qui replace `lambda' = exp(`lambda')
		qui predict double `idelta' if `touse', xb eq(#2)
		qui replace `idelta' = 1/exp(`idelta')*`lambda'
		qui gen double `xg' = .
				
		forvalues i = 1/`sims' {
			qui replace `xg' = rgamma(`idelta', 1/`idelta') if `touse'
			tempvar sim`i'
			qui gen `sim`i'' = rpoisson(`lambda'*`xg') if `touse'
			local simvars "`simvars' `sim`i''"
		}
	}
	hangroot , sims(`simvars') `hangr_opts' `options'
end
