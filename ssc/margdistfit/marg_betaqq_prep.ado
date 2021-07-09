*! version 1.2.2 15Feb2012 MLB
*  version 1.0.1 21Nov2011 MLB
*  version 1.0.0 14Nov2011 MLB
program define marg_betaqq_prep, rclass
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
	
	tempvar alpha beta first fw
	
	marksample touse
	sum `y' if `touse' , meanonly
	local l = r(min)
	local u = r(max)

	qui predict double `alpha' if `touse', alpha
	qui replace `alpha' = cond(`alpha' < 0.05, .05, ///
			              cond(`alpha' > 1e5, 1e5, `alpha')) if `touse'	
	qui predict double `beta' if `touse', beta
	qui replace `beta' = cond(`beta' < 0.15, .15, ///
                         cond(`beta' > 1e5, 1e5, `beta')) if `touse'
	sort `alpha' `beta'
	qui by `alpha' `beta' : gen byte `first' = cond(`touse', _n == 1, 0)
	qui by `alpha' `beta' : gen double `fw' = _N if `touse'
	
	sort `touse' `y'
	qui gen `q' = .
	
	mata : marg_betainvert("`alpha'", "`beta'", "`fw'", "`first'", "`pobs'", "`touse'", `l', `u', `e', "`q'" )
	sort `touse' `y' `q'

	if "`parsamp'" == "" {
		tempname bname vname orig
		matrix `bname' = e(b)
		matrix `vname' = e(V)
		est store `orig'
		forvalues i = 1/`sims' {
			local nvar : word `i' of `simvars'
			drop `alpha' `beta'
			marg_parsamp, bname(`bname') v(`vname')
			qui predict double `alpha' if `touse', alpha
			qui replace `alpha' = cond(`alpha' < 0.05, .05, ///
								  cond(`alpha' > 1e5, 1e5, `alpha')) if `touse'			
			qui predict double `beta' if `touse', beta
			qui replace `beta' = cond(`beta' < 0.15, .15, ///
								 cond(`beta' > 1e5, 1e5, `beta')) if `touse'
			qui gen `nvar' = rbeta(`alpha', `beta') if `touse'
			mata: marg_dangerous_sort("`nvar'", "`touse'")
			local gr "`gr' || line `nvar' `q', lpattern(solid) lcolor(gs10) sort `simopts'"
		}
		qui est restore `orig'
	}
	else {
		forvalues i = 1/`sims' {
			local nvar : word `i' of `simvars'
			qui gen `nvar' = rbeta(`alpha', `beta') if `touse'
			mata: marg_dangerous_sort("`nvar'", "`touse'")
			local gr "`gr' || line `nvar' `q', lpattern(solid) lcolor(gs10) sort `simopts'"
		}
	}
	return local gr `"`gr'"'
end
