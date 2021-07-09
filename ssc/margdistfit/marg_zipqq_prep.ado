*! version 1.3.0 14May2012 MLB
program define marg_zipqq_prep, rclass
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
	
	tempvar lambda pr first fw
	
	marksample touse
	sum `y' if `touse' , meanonly
	local l = r(min)
	local u = r(max)

	qui predict double `lambda' if `touse', xb eq(#1)
	qui replace `lambda' = exp(`lambda')
	qui predict double `pr', pr
	sort `lambda' `pr' 
	qui by `lambda' `pr': gen byte `first' = cond(`touse', _n == 1, 0)
	qui by `lambda' `pr' : gen double `fw' = _N if `touse'
	
	sort `touse' `y'
	qui gen `q' = .
	mata: marg_zipqq("`pobs'", "`q'","`lambda'", "`pr'", "`first'", "`fw'", "`touse'")
	
	
	if "`parsamp'" == "" {
		tempname bname vname orig
		matrix `bname' = e(b)
		matrix `vname' = e(V)
		est store `orig'
		forvalues i = 1/`sims' {
			local nvar : word `i' of `simvars'
			drop `lambda' `pr'
			marg_parsamp, bname(`bname') v(`vname')
			qui predict double `lambda' if `touse', xb eq(#1)
			qui replace `lambda' = exp(`lambda')
			qui predict double `pr', pr
			qui gen `nvar' = cond(runiform()< `pr', 0, rpoisson(`lambda')) if `touse'
			mata: marg_dangerous_sort("`nvar'", "`touse'")
			local gr "`gr' || scatter `nvar' `q', msymbol(oh) color(gs10) sort `simopts'"
		}
		qui est restore `orig'
	}
	else {
		forvalues i = 1/`sims' {
			local nvar : word `i' of `simvars'
			qui gen `nvar' = cond(runiform()< `pr', 0, rpoisson(`lambda')) if `touse'
			mata: marg_dangerous_sort("`nvar'", "`touse'")
			local gr "`gr' || scatter `nvar' `q', msymbol(oh) color(gs10) sort `simopts'"
		}
	}
	return local gr `"`gr'"'
end
