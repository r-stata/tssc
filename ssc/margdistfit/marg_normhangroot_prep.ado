*! version 1.2.1 22Dec2011 MLB
*  version 1.2.0 13Dec2011 MLB
program define marg_normhangroot_prep
	version 10.1
	syntax , sims(integer)     ///
	        [                  ///
			hangr_opts(string) ///	
			simci              ///
			level(cilevel)     ///
			*                  /// 
			]
	
	tempvar touse mu
	tempname sigma
	
	qui gen byte `touse' = e(sample)
	if "`parsamp'" == "" {
		qui gen `mu' = .
		tempname bname vname orig sdy rmse cf n
		matrix `bname' = e(b)
		matrix `vname' = e(V)
		scalar `rmse' = e(rmse)
		scalar `cf' = sqrt(e(N) - e(df_m) - 1 )/sqrt(e(N))
		scalar `n' = e(N)
		est store `orig'
			
		qui sum `e(depvar)' if `touse'
		scalar `sdy' = r(sd)

		forvalues i = 1/`sims' {
			tempvar sim`i'

			qui drop `mu'
			marg_parsamp, bname(`bname') v(`vname') rmse(`=`rmse'') sd(`=`sdy'') cf(`=`cf'') n(`=`n'')
			qui predict double `mu' if `touse', xb
			scalar `sigma' = e(rmse)

			qui gen `sim`i'' = rnormal(`mu', `sigma') if `touse'
			local simvars "`simvars' `sim`i''"
		}
		qui est restore `orig'
	}
	else {
		qui predict double `mu' if `touse' , xb
		scalar `sigma' = e(rmse)
		forvalues i = 1/`sims' {
			tempvar sim`i'
			qui gen `sim`i'' = rnormal(`mu', `sigma') if `touse'
			local simvars "`simvars' `sim`i''"
		}
	}
	hangroot , sims(`simvars') `hangr_opts' `options' `simci' level(`level')

end
