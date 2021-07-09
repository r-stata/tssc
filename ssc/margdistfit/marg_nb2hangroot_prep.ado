*! version 1.3.0 17Mar2012 MLB
program define marg_nb2hangroot_prep
	version 10.1
	syntax , sims(integer)     ///
	        [                  ///
			hangr_opts(string) ///	
			noPArsamp          ///
			simci              ///
			level(cilevel)     ///
			*                  /// 
			]
	
	tempvar touse lambda alpha xg

	qui gen byte `touse' = e(sample)

	if "`parsamp'" == "" {
		qui gen `lambda' = .
		qui gen `alpha'  = .
		qui gen `xg'     = .
		tempname bname vname orig
		matrix `bname' = e(b)
		matrix `vname' = e(V)
		est store `orig'
		
		forvalues i = 1/`sims' {
			tempvar sim`i'
			qui drop `lambda' `alpha' `xg'
			marg_parsamp, bname(`bname') v(`vname')
			qui predict double `lambda' if `touse' , xb eq(#1)
			qui replace `lambda' = exp(`lambda')
			qui predict double `alpha' if `touse', xb eq(#2)
			qui replace `alpha' = exp(`alpha')
			qui gen double `xg' = rgamma(1/`alpha', `alpha')
			qui gen `sim`i'' = rpoisson(`lambda'*`xg') if `touse'
			local simvars "`simvars' `sim`i''"
		}
		qui est restore `orig'
	}
	else {
		qui predict double `lambda' if `touse' , xb eq(#1)
		qui replace `lambda' = exp(`lambda')
		qui predict double `alpha' if `touse', xb eq(#2)
		qui replace `alpha' = exp(`alpha')
		qui gen double `xg' = .
				
		forvalues i = 1/`sims' {
			qui replace `xg' = rgamma(1/`alpha', `alpha')
			tempvar sim`i'
			qui gen `sim`i'' = rpoisson(`lambda'*`xg') if `touse'
			local simvars "`simvars' `sim`i''"
		}
	}
	hangroot , sims(`simvars') `hangr_opts' `options' `simci' level(`level')
end
