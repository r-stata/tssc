*! version 1.3.0 17Mar2012 MLB
program define marg_poissonpp_prep, rclass
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
	
	tempvar mu first fw
	qui predict double `mu' if `touse', n
	
	sort `y' `pobs'
	qui gen `ptheor' = .

	if "`parsamp'" == "" {
		tempvar mu2 y2
		tempname bname vname orig
		matrix `bname' = e(b)
		matrix `vname' = e(V)
		est store `orig'
		qui gen `mu2' = .
		
		forvalues i = 1/`sims' {
			tempvar y`i'
			marg_parsamp, bname(`bname') v(`vname')
			drop `mu2' 
			qui predict `mu2' if `touse', n
	
			local nvar : word `i' of `simvars'
			local npobs : word `i' of `pobsvars'
			qui gen `nvar' = .
	
			qui gen long `y`i'' = rpoisson(`mu2') if `touse'
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
		forvalues i = 1/`sims' {
			tempvar y`i'
			qui gen long `y`i'' = rpoisson(`mu') if `touse'
			sort `y`i''
			qui gen `npobs' = sum(`touse')
			qui replace `npobs' = cond(`touse',`npobs'/(`npobs'[_N]+1),.)
			qui bys `y`i'' `touse' (`npobs'): replace `npobs' = `npobs'[_N] 
			
			local ys "`ys' `y`i''"
			local gr "`gr' || scatter `nvar' `npobs', msymbol(oh) color(gs10) `simopts'"

		}
	}
	
	sort `mu'
	by `mu' : gen byte `first' = cond(`touse', _n == 1, 0)
	qui by `mu' : gen float `fw' = _N if `touse'

	qui bys `y' `touse' (`pobs'): replace `pobs' = `pobs'[_N]
	sort `y' `pobs'
	
	
	mata marg_poissonpp("`y' `ys'", "`ptheor' `simvars'", "`mu'", "`first'", "`fw'", "`touse'")
	
	return local gr `"`gr'"'
end
