*! version 1.3.0 14May2012 MLB
program define marg_nb1qq_prep, rclass
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
	
	tempvar lambda idelta xg first fw
	tempname ln_delta
	
	marksample touse
	sum `y' if `touse' , meanonly
	local l = r(min)
	local u = r(max)

	qui predict double `lambda' if `touse', xb eq(#1)
	qui replace `lambda' = exp(`lambda')
	scalar `ln_delta' = [lndelta]_b[_cons]
	sort `lambda' 
	qui by `lambda' : gen byte `first' = cond(`touse', _n == 1, 0)
	qui by `lambda' : gen double `fw' = _N if `touse'
	
	sort `touse' `y'
	qui gen `q' = .
	mata: marg_nb1qq("`pobs'", "`q'","`lambda'", `=`ln_delta'', "`first'", "`fw'", "`touse'")
	
	
	if "`parsamp'" == "" {
		qui gen `idelta' = .
		qui gen `xg'     = .
		tempname bname vname orig
		matrix `bname' = e(b)
		matrix `vname' = e(V)
		est store `orig'
		forvalues i = 1/`sims' {
			local nvar : word `i' of `simvars'
			drop `lambda' `idelta' `xg'
			marg_parsamp, bname(`bname') v(`vname')
			qui predict double `lambda' if `touse', xb eq(#1)
			qui replace `lambda' = exp(`lambda')
			qui predict double `idelta' if `touse', xb eq(#2)
			qui replace `idelta' = 1/exp(`idelta')*`lambda'
			qui gen double `xg' = rgamma(`idelta', 1/`idelta')
			qui gen `nvar' = rpoisson(`lambda'*`xg') if `touse'
			mata: marg_dangerous_sort("`nvar'", "`touse'")
			local gr "`gr' || scatter `nvar' `q', msymbol(oh) color(gs10) sort `simopts'"
		}
		qui est restore `orig'
	}
	else {
		qui predict double `idelta' if `touse', xb eq(#2)
		qui replace `idelta' = 1/exp(`idelta')*`lambda'
		qui gen `xg' = .
		forvalues i = 1/`sims' {
			drop `xg'
			qui gen double `xg' = rgamma(`idelta', 1/`idelta')
			local nvar : word `i' of `simvars'
			qui gen `nvar' = rpoisson(`lambda'*`xg') if `touse'
			mata: marg_dangerous_sort("`nvar'", "`touse'")
			local gr "`gr' || scatter `nvar' `q', msymbol(oh) color(gs10) sort `simopts'"
		}
	}
	return local gr `"`gr'"'
end
