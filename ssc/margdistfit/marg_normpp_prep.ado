*! version 1.2.1 22Dec2011 MLB
*  version 1.0.1 21Nov2011 MLB
*  version 1.0.0 14Nov2011 MLB
program define marg_normpp_prep, rclass
	version 10.1
	
	syntax [if] ,   ///
	[               ///
	simvars(string) ///
	simopts(string) ///
	noPArsamp       ///
	]               ///
	ptheor(string)  ///
	pobs(varname)   ///
	sims(integer)   ///
	n(integer)      ///
	y(varname)      ///
	e(real)
	
	marksample touse 
	
	tempvar mu first fw
	tempname sd
	qui predict double `mu' if `touse', xb
	scalar `sd' = e(rmse)


	sort `y' `pobs'
	qui gen `ptheor' = .
	local var "`y' `simvars'"
	local pvar "`ptheor' `simvars'"

	if "`parsamp'" == "" {
		tempvar mu2
		tempname bname vname orig sdy rmse cf n sd2
		
		qui gen `mu2' = .
		matrix `bname' = e(b)
		matrix `vname' = e(V)
		scalar `rmse' = e(rmse)
		scalar `cf' = sqrt(e(N) - e(df_m) - 1 )/sqrt(e(N))
		scalar `n' = e(N)
		est store `orig'
		
		qui sum `e(depvar)' if `touse'
		scalar `sdy' = r(sd)
		
		forvalues i = 1/`sims' {
			local nvar : word `i' of `simvars'
			
			drop `mu2'
			marg_parsamp, bname(`bname') v(`vname') rmse(`=`rmse'') sd(`=`sdy'') cf(`=`cf'') n(`=`n'')
			qui predict double `mu2' if `touse', xb
			scalar `sd2' = e(rmse)
			qui gen `nvar' = rnormal(`mu2', `sd2') if `touse'
			
			local gr "`gr' || line `nvar' `pobs', lpattern(solid) lcolor(gs10) `simopts'"
		}
		qui est restore `orig'
	}
	else {
		forvalues i = 1/`sims' {
			local nvar : word `i' of `simvars'
			qui gen `nvar' = rnormal(`mu', `sd') if `touse'
			local gr "`gr' || line `nvar' `pobs', lpattern(solid) lcolor(gs10) `simopts'"
		}
	}
	
	sort `mu' 
	by `mu' : gen byte `first' = cond(`touse', _n == 1, 0)
	qui by `mu' : gen float `fw' = _N if `touse'
	sort `y' `pobs'
	
	mata marg_normpp("`var'", "`pvar'", "`mu'", `=`sd'', "`first'", "`fw'", "`touse'", `e')
	return local gr `"`gr'"'
end
