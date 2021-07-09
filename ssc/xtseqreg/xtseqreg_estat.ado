*! version 1.1.2  04jun2017
*! Sebastian Kripfganz, www.kripfganz.de

*==================================================*
***** postestimation statistics after xtseqreg *****

*** Citation ***

/*	Kripfganz, S., and C. Schwarz (2015).
	Estimation of linear dynamic panel data models with time-invariant regressors.
	ECB Working Paper 1838. European Central Bank.		*/

program define xtseqreg_estat, rclass
	version 12.1
	if "`e(cmd)'" != "xtseqreg" {
		error 301
	}
	gettoken subcmd rest : 0, parse(" ,")
	if "`subcmd'" == substr("serial", 1, max(3, `: length loc subcmd')) {
		xtseqreg_estat_serial `rest'
	}
	else if "`subcmd'" == substr("overid", 1, max(4, `: length loc subcmd')) {
		xtseqreg_estat_overid `rest'
	}
	else if "`subcmd'" == substr("hausman", 1, max(4, `: length loc subcmd')) {
		xtseqreg_estat_hausman `rest'
	}
	else {
		estat_default `0'
	}
	ret add
end

*==================================================*
**** computation of serial-correlation test statistics ****
program define xtseqreg_estat_serial, rclass
	version 12.1
	syntax [, AR(numlist int >0)]

	if rowsof(e(stats)) == 2 {
		di as err "estat serial not allowed after xtseqreg with two equations"
		exit 198
	}
	if "`ar'" == "" {
		loc ar				"1 2"
	}
	tempvar smpl dsmpl e
	qui gen byte `smpl' = e(sample)
	qui predict double `e' if `smpl', e
	tempname b
	mat `b'				= e(b)
	loc indepvars		: coln `b'
	loc indepvars		: subinstr loc indepvars "_cons" "`smpl'", w
	loc K				: word count `indepvars'
	forv k = 1/`K' {
		tempname influence`k'
		loc influence		"`influence' `influence`k''"
		loc var				: word `k' of `indepvars'
		_ms_parse_parts `var'
		if "`r(type)'" == "factor" {
			fvrevar `var'
			loc var				"`r(varlist)'"
		}
		loc dindepvars		"`dindepvars' D.`var'"
	}
	loc sigma2e			= e(sigma2e)
	if `sigma2e' == . {
		qui predict double `influence' if `smpl', score
		cap conf mat e(V_modelbased)
		if _rc == 0 {
			loc V				"e(V_modelbased)"
		}
		else {
			loc V				"e(V)"
		}
		mata: xtseqreg_influence("`influence'", "`V'", "", "`smpl'")
	}
	di _n as txt "Arellano-Bond test for autocorrelation of the first-differenced residuals"
	foreach order of num `ar' {
		qui gen byte `dsmpl' = `smpl'
		markout `dsmpl' D.`e' L`order'D.`e'
		mata: xtseqreg_serial(	"D.`e'",				///
								"L`order'D.`e'",		///
								"`dindepvars'",			///
								"`influence'",			///
								"`e(ivar)'",			///
								"`smpl'",				///
								"`dsmpl'",				///
								"e(V)",					///
								`sigma2e')
		loc z`order'		= r(z)
		loc p`order'		= 2 * normal(- abs(`z`order''))
		qui drop `dsmpl'
		di as txt "H0: no autocorrelation of order " as res `order' as txt ":" _col(40) "z = " as res %9.4f `z`order'' _col(56) as txt "Prob > |z|" _col(68) "=" _col(73) as res %6.4f `p`order''
	}

	foreach order of num `ar' {
		ret sca p_`order'	= `p`order''
		ret sca z_`order'	= `z`order''
	}
end

*==================================================*
**** computation of Hansen's J-test statistics ****
program define xtseqreg_estat_overid, rclass
	version 12.1
	syntax [name(id="estimation results")]

	tempname b stats
	mat `b'				= e(b)
	loc eqnames			: coleq `b', q
	loc eqnames			: list uniq eqnames
	mat `stats'			= e(stats)
	mat `stats'			= `stats'[., "rank" .. "chi2_J"]
	if rowsof(`stats') != `: word count `eqnames'' {
		di as err "estat overid not available after xtseqreg, combine"
		exit 321
	}
	loc J1				= el(`stats', 1, 3)
	loc both			= (`J1' < .)
	if `both' {
		loc df1				= el(`stats', 1, 2) - el(`stats', 1, 1)
		loc p1				= chi2tail(`df1', `J1')
	}

	loc miss			= 0
	if "`namelist'" == "" {
		loc title			"Hansen's J-test"
	}
	else if rowsof(`stats') == 2 {
		di as err "estat overid {it:name} not allowed after xtseqreg with two equations"
		exit 322
	}
	else {
		tempname xtseqreg_e
		est sto `xtseqreg_e'
		qui est res `namelist'
		if "`e(cmd)'" != "xtseqreg" {
			qui est res `xtseqreg_e'
			est drop `xtseqreg_e'
			di as err "`namelist' is not supported by estat overid"
			exit 322
		}
		tempname b2 stats2
		mat `b2'			= e(b)
		loc eqnames			: coleq `b2', q
		loc eqnames			: list uniq eqnames
		mat `stats2'		= e(stats)
		mat `stats2'		= `stats2'[., "rank" .. "chi2_J"]
		if rowsof(`stats2') == 2 {
			qui est res `xtseqreg_e'
			est drop `xtseqreg_e'
			di as err "estat overid {it:name} not allowed after xtseqreg with two equations"
			exit 322
		}
		loc df2				= el(`stats2', 1, 2) - el(`stats2', 1, 1)
		if `df2' > `df1' {
			loc df1				= `df2' - `df1'
			loc J1				= el(`stats2', 1, 3) - `J1'
		}
		else {
			loc df1				= `df1' - `df2'
			loc J1				= `J1' - el(`stats2', 1, 3)
		}
		if `df1' == 0 | `J1' < 0 {
			loc miss			= 1
		}
		qui est res `xtseqreg_e'
		est drop `xtseqreg_e'
		loc p1				= chi2tail(`df1', `J1')
		loc title			"Difference-in-Hansen test"
	}

	if rowsof(`stats') == 2 {
		loc J2				= el(`stats', 2, 3)
		loc df2				= el(`stats', 2, 2) - el(`stats', 2, 1)
		loc p2				= chi2tail(`df2', `J2')
		loc eq				= 2 - `both'
		di _n as txt "Hansen's J-test for equation " as res "`: word `eq' of `eqnames''" _c
	}
	else {
		loc both			= 0
		loc eq				= 1
		di _n as txt "`title'" _c
	}
	di as txt _col(56) "chi2(" as res `df`eq'' as txt ")" _col(68) "=" _col(70) as res %9.4f `J`eq''
	if `miss' {
		di as txt "note: assumptions not satisfied" _c
	}
	else if `df`eq'' == 0 {
		di as txt "note: coefficients are exactly identified" _c
	}
	else {
		di as txt "H0: overidentifying restrictions are valid" _c
	}
	di _col(56) "Prob > chi2" _col(68) "=" _col(73) as res %6.4f `p`eq''
	if `both' {
		di _n as txt "Hansen's J-test for equation " as res "`: word 2 of `eqnames''" _c
		di as txt _col(56) "chi2(" as res `df2' as txt ")" _col(68) "=" _col(70) as res %9.4f `J2'
		if `df2' == 0 {
			di as txt "note: coefficients are exactly identified" _c
		}
		else {
			di as txt "H0: overidentifying restrictions are valid" _c
		}
		di _col(56) "Prob > chi2" _col(68) "=" _col(73) as res %6.4f `p2'
	}

	if `both' {
		ret sca p_J_2		= `p2'
		ret sca df_J_2		= `df2'
		ret sca chi2_J_2	= `J2'
	}
	ret sca p_J_`eq'	= `p`eq''
	ret sca df_J_`eq'	= `df`eq''
	ret sca chi2_J_`eq'	= `J`eq''
end

*==================================================*
**** computation of generalized Hausman test statistic ****
program define xtseqreg_estat_hausman, rclass
	version 12.1
	syntax anything(id="estimation results") , [DF(integer 0) noNEsted]
	gettoken estname anything : anything , match(paren) bind
	if `: word count `estname'' != 1 | `"`paren'"' != "" {
		error 198
	}
	gettoken varlist anything : anything, match(paren) bind
 	if (`"`paren'"' == "" & `"`varlist'"' != "") | (`"`paren'"' != "" & `"`anything'"' != "") {
		error 198
	}
	if `df' < 0 {
		di as err "option df() incorrectly specified"
		exit 198
	}
	if "`nested'" != "" & `df' > 0 {
		di as err "options df() and nonested may not be combined"
		exit 184
	}

	forv e = 1/2 {
		if `e' == 2 {
			tempname xtseqreg_e
			est sto `xtseqreg_e'
			qui est res `estname'
			if "`e(cmd)'" != "xtseqreg" {
				qui est res `xtseqreg_e'
				est drop `xtseqreg_e'
				di as err "`estname' is not supported by estat hausman"
				exit 322
			}
		}
		if rowsof(e(stats)) == 2 {
			if `e' == 2 {
				qui est res `xtseqreg_e'
				est drop `xtseqreg_e'
			}
			di as err "estat hausman not allowed after xtseqreg with two equations"
			exit 322
		}
		tempname b`e'
		mat `b`e''			= e(b)
		loc bvars`e'		: coln `b`e''
		if `e' == 1 {
			if `"`varlist'"' == "" {
				loc teffects		"`e(teffects)' _cons"
				loc varlist			: list bvars`e' - teffects
			}
			else {
				tsunab varlist		: `varlist'
			}
			if `df' > `: word count `varlist'' {
				di as err "option df() incorrectly specified -- outside of allowed range"
				exit 198
			}
			tempvar touse
			qui gen byte `touse' = e(sample)
		}
		else {
			tempvar aux
			qui gen byte `aux' = e(sample)
			qui replace `aux' = `aux' - `touse'
			sum `aux', mean
			if r(max) | r(min) {
				qui est res `xtseqreg_e'
				est drop `xtseqreg_e'
				di as err "estimation samples must coincide"
				exit 322
			}
			drop `aux'
		}
		if !`: list varlist in bvars`e'' {
			if `e' == 2 {
				qui est res `xtseqreg_e'
				est drop `xtseqreg_e'
			}
			di as err "`: list varlist - bvars`e'' not found"
			exit 111
		}
		forv k = 1/`: word count `bvars`e''' {
			tempvar influence`e'_`k'
			loc influence_all`e' "`influence_all`e'' `influence`e'_`k''"
		}
		qui predict double `influence_all`e'' if `touse', score
		cap conf mat e(V_modelbased)
		if _rc == 0 {
			loc V				"e(V_modelbased)"
		}
		else {
			loc V				"e(V)"
		}
		mata: xtseqreg_influence("`influence_all`e''", "`V'", "", "`touse'")
		tempname aux
		foreach var of loc varlist {
			loc k				: list posof "`var'" in bvars`e'
			loc influence`e'	"`influence`e'' `: word `k' of `influence_all`e'''"
			mat `aux'			= (nullmat(`aux'), `b`e''[1, "`var'"])
		}
		mat `b`e''			= `aux'
		cap drop `: list influence_all`e' - influence`e''
		if `df' == 0 {
			tempname stats
			mat `stats'			= e(stats)
			mat `stats'			= `stats'[1, "rank" .. "zrank"]
			loc df`e'			= el(`stats', 1, 2) - el(`stats', 1, 1)
		}
	}
	qui est res `xtseqreg_e'
	est drop `xtseqreg_e'

	mata: xtseqreg_hausman(	"`influence1'",			///
							"`influence2'",			///
							"`e(ivar)'",			///
							"`touse'",				///
							"`b1'",					///
							"`b2'")
	loc chi2			= r(chi2)
	if `df' == 0 & "`nested'" == "" {
		loc df				= min(abs(`df1' - `df2'), r(df_max))
	}
	else if "`nested'" != "" {
		loc df				= r(df_max)
	}
	loc p				= chi2tail(`df', `chi2')
	di _n as txt "Generalized Hausman test" _col(56) "chi2(" as res `df' as txt ")" _col(68) "=" _col(70) as res %9.4f `chi2'
	di as txt _col(56) "Prob > chi2" _col(68) "=" _col(73) as res %6.4f `p'

	ret sca p			= `p'
	ret sca df			= `df'
	ret sca chi2		= `chi2'
end
