*! version 1.2.1 22Dec2011 MLB
*  version 1.0.1 21Nov2011 MLB
*  version 1.0.0 14Nov2011 MLB
program define marg_normqq_prep, rclass
	version 10.1
	
	syntax [if] ,   ///
	[               ///
	simvars(string) ///
	simopts(string) ///
	noPArsamp       ///
	]               ///
	q(string)       ///
	pobs(varname)   ///
	sims(integer)   ///
	n(integer)      ///
	y(varname)      ///
	e(real)
	
	tempvar mu first fw
	tempname sd
	
	marksample touse
	sum `y' if `touse' , meanonly
	local l = r(min)
	local u = r(max)

	qui predict double `mu' if `touse', xb
	scalar `sd' = e(rmse)

	sort `mu'
	qui by `mu' : gen byte `first' = cond(`touse', _n == 1, 0)
	qui by `mu' : gen double `fw' = _N if `touse'
	
	sort `touse' `y'
	qui gen `q' = .
	
	mata : marg_norminvert("`mu'", `=`sd'', "`fw'", "`first'", "`pobs'", "`touse'", `l', `u', `e', "`q'" )
	sort `touse' `y' `q'
	
	if "`parsamp'" == "" {
		tempname bname vname orig rmse sdy cf n
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
			drop `mu'
			marg_parsamp, bname(`bname') v(`vname') rmse(`=`rmse'') sd(`=`sdy'') cf(`=`cf'') n(`=`n'')
			qui predict double `mu' if `touse', xb
			scalar `sd' = e(rmse)
			qui gen `nvar' = rnormal(`mu', `sd') if `touse'
			mata: marg_dangerous_sort("`nvar'", "`touse'")
			local gr "`gr' || line `nvar' `q', lpattern(solid) lcolor(gs10) sort `simopts'"
		}
		qui est restore `orig'
	}
	else {
		forvalues i = 1/`sims' {
			local nvar : word `i' of `simvars'
			qui gen `nvar' = rnormal(`mu', `sd') if `touse'
			mata: marg_dangerous_sort("`nvar'", "`touse'")
			local gr "`gr' || line `nvar' `q', lpattern(solid) lcolor(gs10) sort `simopts'"
		}
	}
	return local gr `"`gr'"'
end
