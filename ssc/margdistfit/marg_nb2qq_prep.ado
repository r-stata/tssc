*! version 1.3.0 14May2012 MLB
program define marg_nb2qq_prep, rclass
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
	
	tempvar lambda alpha xg first fw
	
	marksample touse
	sum `y' if `touse' , meanonly
	local l = r(min)
	local u = r(max)

	qui predict double `lambda' if `touse', xb eq(#1)
	qui replace `lambda' = exp(`lambda')
	qui predict double `alpha' if `touse', xb eq(#2)
	qui replace `alpha' = exp(`alpha')
	sort `lambda' `alpha'
	qui by `lambda' `alpha': gen byte `first' = cond(`touse', _n == 1, 0)
	qui by `lambda' `alpha' : gen double `fw' = _N if `touse'
	
	sort `touse' `y'
	qui gen `q' = .
	mata: marg_nb2qq("`pobs'", "`q'","`lambda'", "`alpha'", "`first'", "`fw'", "`touse'")
	
	
	if "`parsamp'" == "" {
		qui gen `xg'     = .
		tempname bname vname orig
		matrix `bname' = e(b)
		matrix `vname' = e(V)
		est store `orig'
		forvalues i = 1/`sims' {
			local nvar : word `i' of `simvars'
			drop `lambda' `alpha' `xg'
			marg_parsamp, bname(`bname') v(`vname')
			qui predict double `lambda' if `touse', xb eq(#1)
			qui replace `lambda' = exp(`lambda')
			qui predict double `alpha' if `touse', xb eq(#2)
			qui replace `alpha' = exp(`alpha')
			qui gen double `xg' = rgamma(1/`alpha', `alpha')
			qui gen `nvar' = rpoisson(`lambda'*`xg') if `touse'
			mata: marg_dangerous_sort("`nvar'", "`touse'")
			local gr "`gr' || scatter `nvar' `q', msymbol(oh) color(gs10) sort `simopts'"
		}
		qui est restore `orig'
	}
	else {
		qui predict double `alpha' if `touse', xb eq(#2)
		qui replace `alpha' = exp(`alpha')
		qui gen `xg' = .
		forvalues i = 1/`sims' {
			drop `xg'
			qui gen double `xg' = rgamma(1/`alpha', `alpha')
			local nvar : word `i' of `simvars'
			qui gen `nvar' = rpoisson(`lambda'*`xg') if `touse'
			mata: marg_dangerous_sort("`nvar'", "`touse'")
			local gr "`gr' || scatter `nvar' `q', msymbol(oh) color(gs10) sort `simopts'"
		}
	}
	return local gr `"`gr'"'
end
