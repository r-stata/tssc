*! version 1.2.2 15Feb2012 MLB
*  version 1.0.1 21Nov2011 MLB
*  version 1.0.0 14Nov2011 MLB
program define marg_betacumul_prep, rclass 
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
	
	tempvar alpha beta first fw
	qui predict double `alpha' if `touse', alpha
	qui replace `alpha' = cond(`alpha' < 0.05, .05, ///
			              cond(`alpha' > 1e5, 1e5, `alpha')) if `touse'
	qui predict double `beta' if `touse', beta
	qui replace `beta' = cond(`beta' < 0.15, .15, ///
                         cond(`beta' > 1e5, 1e5, `beta')) if `touse'
	qui gen `ptheor' = .

	sum `y' if `touse', meanonly
	local min = r(min)
	local max = r(max)
		
	if "`parsamp'" == "" {
		tempname bname vname orig
		matrix `bname' = e(b)
		matrix `vname' = e(V)
		est store `orig'
		
		tempvar alpha2 beta2
		qui gen `alpha2' = .
		qui gen `beta2' = .
		
		forvalues i = 1/`sims' {
			local nvar : word `i' of `simvars'
			local pvar : word `i' of `pi'
			drop `alpha2' `beta2'
			marg_parsamp, bname(`bname') v(`vname')
			qui predict double `alpha2' if `touse', alpha
			qui replace `alpha2' = cond(`alpha2' < 0.05, .05, ///
			                       cond(`alpha2' > 1e5, 1e5, `alpha2')) if `touse'
			qui predict double `beta2' if `touse', beta
			qui replace `beta2' = cond(`beta2' < 0.15, .15, ///
			                      cond(`beta2' > 1e5, 1e5, `beta2')) if `touse'
			qui gen `nvar' = rbeta(`alpha2', `beta2') if `touse'
			
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
		forvalues i = 1/`sims' {
			local nvar : word `i' of `simvars'
			local pvar : word `i' of `pi'
			qui gen `nvar' = rbeta(`alpha', `beta') if `touse'
			sum `nvar' , meanonly
			local min = min(`min', `r(min)')
			local max = max(`max', `r(max)')
			sort `nvar'
			qui gen `pvar' = sum(`touse')
			qui replace `pvar' = cond(`touse',`pvar'/(`pvar'[_N]+1),.)

			local gr "`gr' || line `pvar' `nvar', lpattern(solid) lcolor(gs10) sort `simopts'"
		}
	}
	
	sort `alpha' `beta'
	by `alpha' `beta' : gen byte `first' = cond(`touse', _n == 1, 0)
	qui by `alpha' `beta' : gen float `fw' = _N if `touse'

	sort `y' `pobs'
	qui range `ytheor' `min' `max' `=min(300, _N)'
	tempvar touse2
	gen byte `touse2' = !missing(`ytheor')
	mata marg_betapp("`ytheor'", "`ptheor'", "`alpha'", "`beta'", "`first'", "`fw'", "`touse2'", `e')
	return local gr `"`gr'"'
end
