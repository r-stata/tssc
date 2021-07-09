*! version 1.0.0  10oct2007
program scoretest_cox, rclass
	version 10

	// check for unsupported estimation results
	if `"`e(cmd2)'"' != "stcox" {
		error 301
	}
	if `"`e(cmd)'"' == "stcox_fr" {
		di as err "score test not allowed with shared frailty"
		exit 322
	}
	if `"`e(vce)'"' != "oim" {
		di as err "score test not allowed with vce(`e(vce)')"
		exit 322
	}
	if `"`e(texp)'"' != "" {
		di as err "score test not allowed with the option tvc()"
		exit 322
	}
	if `"`e(prefix)'"' != "" {
		di as err "score test not allowed with `e(prefix)' results"
		exit 322
	}

	// these variable identify which coefficients are going to be tested
	syntax varlist [, showcox ]

	tempvar touse
	mark `touse' if e(sample)

	// building the options to be passed directly to -cox-
	if `"`e(wtype)'"' != "" {
		local wt [`e(wtype)'`e(wexp)']
	}
	if `"`e(strata)'"' != "" {
		local strata strata(`e(strata)')
	}
	if `"`e(offset)'"' != "" {
		local offset offset(`e(offset)')
	}
	if `"`e(method)'"' == "partial" {
		local ties exactp
	}
	else if `"`e(method)'"' == "marginal" {
		local ties exactm
	}
	else	local ties `e(method)'

	tempname matb results b1 b0 b g h
	mat `b1' = e(b)
	local cmdline `"`e(cmdline)'"'

	// hold the current results and auto-restore when we exit
	_est hold `results', restore nullok

	* full contains variables in the full model
	* tst contains the variables to test
	* rest contains variables in the restricted model
	local full : colnames `b1'
	local tst : list uniq varlist
	local rest : list full - tst

	* check that tested variables are in the model
	local invalid : list tst - full
	if `"`invalid'"' != "" {
		gettoken invalid : invalid
		di as err "`invalid' not found in the model"
		exit 111
	}

	* fit cox model on the rest, and construct the matrix
	* of coefficients b for the restricted model
	* parse options first
	ParseOpt `cmdline'
	local options `"`r(options)'"'
	qui stcox `rest' if `touse', `options'
	mat `b0' = e(b)
	local npar = colsof(`b1')
	local rnames : colfullnames `b0'

	// fill in the parameter matrix for the null Hypothesis
	mat `b' = J(1, `npar', 0)
	foreach nm in `rnames'{
		local j0 = colnumb(`b0', "`nm'")
		local j1 = colnumb(`b1', "`nm'")
		matrix `b'[1,`j1'] = `b0'[1,`j0']
	}

	* get the gradient and the Hessian for the Cox model at H0
	local coxcmd cox _t `full' `wt' if `touse',	///
				t0(_t0)			///
				dead(_d)		///
				matfrom(`b')		///
				gradient(`g')		///
				hessian(`h')		///
				`ties'			///
				`strata' 
	if "`showcox'" != "" {
		di as txt "{p 0 0 2}calling cox -> "	///
		   in white `"`coxcmd'"'		///
		   "{p_end}"
	}
	quietly `coxcmd'

	// compute the score test statistic
	tempname val pval
	mata: sctest_util()
	local  df = `npar' - colsof(`b0')
	scalar `val'  = r(val)
	scalar `pval' = chi2tail(`df', r(val))
	
	* display results
	local i 0
	di
	foreach var of local tst {
		di as txt " (" %2.0f `++i' ")" as res _col(8) "`var' = 0"
	}
	di
	di as txt _col(12) "chi2(" %3.0f `df' ") ="	as res %8.2f `val'
	di as txt _col(10) "Prob > chi2 =  "		as res %8.4f `pval'

	* return results
	return scalar df = `df'
	return scalar chi2 = `val'
	return scalar p = `pval'
end

program ParseOpt, rclass
	syntax anything [,*]
	return local options `"`options'"'
end

mata:
void sctest_util()
{
	real matrix u1
	real matrix H
	real matrix V

	u1 = st_matrix(st_local("g"))
	H = st_matrix(st_local("h"))
	V = cholinv(H)
	m = u1*V*u1'
	a  = m[1,1]
	st_numscalar("r(val)", a)
}
end

exit
