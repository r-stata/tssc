*! version 1.3.0 14May2012 MLB
program define marg_nb2pp_prep, rclass
	version 10.1
	
	syntax [if] ,    ///
	[                ///
	simvars(string)  ///
	simopts(string)  ///
	noPArsamp        ///
	pobsvars(string) ///
	]                ///
	ptheor(string)   ///
	pobs(varname)    ///
	sims(integer)    ///
	n(integer)       ///
	y(varname)       ///
	e(real)
	
	marksample touse 
	
	tempvar lambda alpha first fw
	qui predict double `lambda' if `touse', xb eq(#1)
	qui replace `lambda' = exp(`lambda')
	qui predict double `alpha' if `touse', xb eq(#2)
	qui replace `alpha' = exp(`alpha')
	 
	sort `y' `pobs'
	qui gen `ptheor' = .

	if "`parsamp'" == "" {
		tempvar lambda2 alpha2 xg2
		tempname bname vname orig
		matrix `bname' = e(b)
		matrix `vname' = e(V)
		est store `orig'
		qui gen `lambda2' = .
		qui gen `alpha2' = .
		qui gen `xg2'     = .
		
		forvalues i = 1/`sims' {
			tempvar y`i'
			marg_parsamp, bname(`bname') v(`vname')
			drop `lambda2' `alpha2' `xg2' 
			qui predict double `lambda2' if `touse', xb eq(#1)
			qui replace `lambda2' = exp(`lambda2')
			qui predict double `alpha2' if `touse', xb eq(#2)
			qui replace `alpha2' = exp(`alpha2')
			qui gen double `xg2' = rgamma(1/`alpha2', `alpha2')
	
			local nvar : word `i' of `simvars'
			local npobs : word `i' of `pobsvars'
			qui gen `nvar' = .
	
			qui gen long `y`i'' = rpoisson(`lambda2'*`xg2') if `touse'
			sort `y`i''
			qui gen `npobs' = sum(`touse')
			qui replace `npobs' = cond(`touse',`npobs'/(`npobs'[_N]+1),.)
			qui bys `y`i'' `touse' (`npobs'): replace `npobs' = `npobs'[_N] 
			
			local ys "`ys' `y`i''"
			local gr "`gr' || scatter `nvar' `npobs', msymbol(oh) color(gs10) `simopts'"
		}
		qui est restore `orig'
	}
	else {
		tempname xg
		qui gen double `xg' = .
		forvalues i = 1/`sims' {
			tempvar y`i'
			qui drop `xg'
			qui gen `xg' = rgamma(1/`alpha', `alpha')
			qui gen long `y`i'' = rpoisson(`lambda'*`xg') if `touse'
			sort `y`i''
			qui gen `npobs' = sum(`touse')
			qui replace `npobs' = cond(`touse',`npobs'/(`npobs'[_N]+1),.)
			qui bys `y`i'' `touse' (`npobs'): replace `npobs' = `npobs'[_N] 
			
			local ys "`ys' `y`i''"
			local gr "`gr' || scatter `nvar' `npobs', msymbol(oh) color(gs10) `simopts'"

		}
	}
	
	sort `lambda' `alpha'
	by `lambda' `alpha': gen byte `first' = cond(`touse', _n == 1, 0)
	qui by `lambda' `alpha': gen float `fw' = _N if `touse'

	qui bys `y' `touse' (`pobs'): replace `pobs' = `pobs'[_N]
	sort `y' `pobs'
	
	
	mata marg_nb2pp("`y' `ys'", "`ptheor' `simvars'", "`lambda'", "`alpha'", "`first'", "`fw'", "`touse'")
	
	return local gr `"`gr'"'
end
