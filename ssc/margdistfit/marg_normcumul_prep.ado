*! version 1.2.1 22Dec2011 MLB
*  version 1.0.1 21Nov2011 MLB
*  version 1.0.0 14Nov2011 MLB
program define marg_normcumul_prep, rclass 
	version 10.1
	
	syntax [if] ,   ///
	[               ///
	simvars(string) ///
	pi(string)      ///
	simopts(string) ///
	noPArsamp       ///
	]               ///
	ptheor(string)  ///
	ytheor(string)  ///
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

	if "`parsamp'" == "" {
		tempname sdy bname vname orig rmse sd2 cf n
		qui sum `y' if `touse'
		local min = r(min)
		local max = r(max)
		scalar `sdy' = r(sd)
		
		matrix `bname' = e(b)
		matrix `vname' = e(V)
		scalar `rmse' = e(rmse)
		scalar `cf' = sqrt(e(N) - e(df_m) - 1 )/sqrt(e(N))
		scalar `n' = e(N)
		est store `orig'
			
		tempvar mu2 
		qui gen `mu2' = .

		forvalues i = 1/`sims' {
			local nvar : word `i' of `simvars'
			local pvar : word `i' of `pi'

			drop `mu2'
			marg_parsamp, bname(`bname') v(`vname') rmse(`=`rmse'') sd(`=`sdy'') cf(`=`cf'') n(`=`n'')
			qui predict double `mu2' if `touse', xb
			scalar `sd2' = e(rmse)
			qui gen `nvar' = rnormal(`mu2', `sd2') if `touse'

			sum `nvar' , meanonly
			local min = min(`min', `r(min)')
			local max = max(`max', `r(max)')
			sort `nvar'
			qui gen `pvar' = sum(`touse')
			qui replace `pvar' = cond(`touse',`pvar'/(`pvar'[_N]+1),.)

			local gr "`gr' || line `pvar' `nvar', lpattern(solid) lcolor(gs10) sort `simopts'"
		}
		qui est restore `orig'
	}
	else {
		sum `y' if `touse', meanonly
		local min = r(min)
		local max = r(max)

		forvalues i = 1/`sims' {
			local nvar : word `i' of `simvars'
			local pvar : word `i' of `pi'
			qui gen `nvar' = rnormal(`mu', `sd') if `touse'

			sum `nvar' , meanonly
			local min = min(`min', `r(min)')
			local max = max(`max', `r(max)')
			sort `nvar'
			qui gen `pvar' = sum(`touse')
			qui replace `pvar' = cond(`touse',`pvar'/(`pvar'[_N]+1),.)

			local gr "`gr' || line `pvar' `nvar', lpattern(solid) lcolor(gs10) sort `simopts'"
		}
	}
	
	sort `mu'
	by `mu' : gen byte `first' = cond(`touse', _n == 1, 0)
	qui by `mu' : gen float `fw' = _N if `touse'

	qui gen `ptheor' = .

	sort `y' `pobs'
	qui range `ytheor' `min' `max' `=min(300, _N)'
	tempvar touse2
	gen byte `touse2' = !missing(`ytheor')
	mata marg_normpp("`ytheor'", "`ptheor'", "`mu'", `=`sd'', "`first'", "`fw'", "`touse2'", `e')
	return local gr `"`gr'"'
end
