*! version 1.3.0 17Mar2012 MLB
program define marg_ziphangroot_prep
	version 10.1
	syntax , sims(integer)     ///
	        [                  ///
			hangr_opts(string) ///	
			noPArsamp          ///
			simci              ///
			level(cilevel)     ///
  			*                  /// 
			]
	
	tempvar touse lambda pr

	qui gen byte `touse' = e(sample)

	if "`parsamp'" == "" {
		qui gen `lambda' = .
		qui gen `pr' = .
		tempname bname vname orig
		matrix `bname' = e(b)
		matrix `vname' = e(V)
		est store `orig'
		
		forvalues i = 1/`sims' {
			tempvar sim`i'
			qui drop `lambda' `pr'
			marg_parsamp, bname(`bname') v(`vname')
			qui predict double `lambda' if `touse' , xb eq(#1)
			qui replace `lambda' = exp(`lambda')
			qui predict double `pr' if `touse', pr
			qui gen `sim`i'' = cond(runiform()< `pr', 0, rpoisson(`lambda')) if `touse'
			local simvars "`simvars' `sim`i''"
		}
		qui est restore `orig'
	}
	else {
		qui predict double `lambda' if `touse' , xb eq(#1)
		qui replace `lambda' = exp(`lambda')
		qui predict double `pr', pr
		
		forvalues i = 1/`sims' {
			tempvar sim`i'
			qui gen `sim`i'' = cond(runiform()< `pr', 0, rpoisson(`lambda')) if `touse'
			local simvars "`simvars' `sim`i''"
		}
	}
	hangroot , sims(`simvars') `hangr_opts' `options' `simci' level(`level')

end
