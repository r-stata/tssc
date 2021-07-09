*! version 1.3.0 14May2012 MLB
program define marg_zippp_prep, rclass
	version 10.1
	
	syntax [if] ,    ///
	[                ///
	simvars(string)  ///
	simopts(string)  ///
	noPArsamp        ///
	pobsvars(string) ///
	]                ///
	infl(string)     ///
	ptheor(string)   ///
	pobs(varname)    ///
	sims(integer)    ///
	n(integer)       ///
	y(varname)       ///
	e(real)
	
	marksample touse 
	
	tempvar lambda pr first fw
	qui predict double `lambda' if `touse', xb
	qui replace `lambda' = exp(`lambda')
	qui predict double `pr', pr
	
	sort `y' `pobs'
	qui gen `ptheor' = .

	if "`parsamp'" == "" {
		tempvar lambda2 pr2 
		tempname bname vname orig
		matrix `bname' = e(b)
		matrix `vname' = e(V)
		est store `orig'
		qui gen `lambda2' = .
		qui gen `pr2' = .
		
		forvalues i = 1/`sims' {
			tempvar y`i'
			marg_parsamp, bname(`bname') v(`vname')
			drop `lambda2' `pr2' 
			qui predict double `lambda2' if `touse', xb
			qui replace `lambda2' = exp(`lambda2')
			qui predict double `pr2', pr
	
			local nvar : word `i' of `simvars'
			local npobs : word `i' of `pobsvars'
			qui gen `nvar' = .
	
			qui gen long `y`i'' = cond(runiform()< `pr2', 0, rpoisson(`lambda2'))
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
			qui gen long `y`i'' = cond(runiform()< `pr', 0, rpoisson(`lambda')) if `touse'
			sort `y`i''
			qui gen `npobs' = sum(`touse')
			qui replace `npobs' = cond(`touse',`npobs'/(`npobs'[_N]+1),.)
			qui bys `y`i'' `touse' (`npobs'): replace `npobs' = `npobs'[_N] 
			
			local ys "`ys' `y`i''"
			local gr "`gr' || scatter `nvar' `npobs', msymbol(oh) color(gs10) `simopts'"

		}
	}
	
	sort `lambda' `pr'
	by `lambda' `pr' : gen byte `first' = cond(`touse', _n == 1, 0)
	qui by `lambda' `pr' : gen float `fw' = _N if `touse'

	qui bys `y' `touse' (`pobs'): replace `pobs' = `pobs'[_N]
	sort `y' `pobs'
	
	
	mata marg_zippp("`y' `ys'", "`ptheor' `simvars'", "`lambda'", "`pr'", "`first'", "`fw'", "`touse'")
	
	return local gr `"`gr'"'
end
