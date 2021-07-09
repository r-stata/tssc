*! version 1.3.0 14May2012 MLB
program define marg_zinbqq_prep, rclass
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
	
	tempvar lambda xg pr first fw
	tempname alpha
	
	marksample touse
	sum `y' if `touse' , meanonly
	local l = r(min)
	local u = r(max)

	qui predict double `lambda' if `touse', xb eq(#1)
	qui replace `lambda' = exp(`lambda')
	scalar `alpha' = exp([lnalpha]_b[_cons])
	qui predict double `pr', pr
	sort `lambda' `pr'
	qui by `lambda' `pr': gen byte `first' = cond(`touse', _n == 1, 0)
	qui by `lambda' `pr' : gen double `fw' = _N if `touse'
	
	sort `touse' `y'
	qui gen `q' = .
	mata: marg_zinbqq("`pobs'", "`q'","`lambda'", `=`alpha'', "`pr'", "`first'", "`fw'", "`touse'")
	
	
	if "`parsamp'" == "" {
		qui gen `xg'     = .
		tempname bname vname orig
		matrix `bname' = e(b)
		matrix `vname' = e(V)
		est store `orig'
		forvalues i = 1/`sims' {
			local nvar : word `i' of `simvars'
			drop `lambda' `xg' `pr'
			marg_parsamp, bname(`bname') v(`vname')
			qui predict double `lambda' if `touse', xb eq(#1)
			qui replace `lambda' = exp(`lambda')
			scalar `alpha' = exp([lnalpha]_b[_cons])
			qui predict double `pr', pr
			qui gen double `xg' = rgamma(1/`alpha', `alpha')
			qui gen `nvar' = cond(runiform() < `pr', 0, rpoisson(`lambda'*`xg')) if `touse'
			mata: marg_dangerous_sort("`nvar'", "`touse'")
			local gr "`gr' || scatter `nvar' `q', msymbol(oh) color(gs10) sort `simopts'"
		}
		qui est restore `orig'
	}
	else {
		qui gen `xg' = .
		forvalues i = 1/`sims' {
			drop `xg'
			qui gen double `xg' = rgamma(1/`alpha', `alpha')
			local nvar : word `i' of `simvars'
			qui gen `nvar' = cond(runiform()<`pr', 0, rpoisson(`lambda'*`xg')) if `touse'
			mata: marg_dangerous_sort("`nvar'", "`touse'")
			local gr "`gr' || scatter `nvar' `q', msymbol(oh) color(gs10) sort `simopts'"
		}
	}
	return local gr `"`gr'"'
end
