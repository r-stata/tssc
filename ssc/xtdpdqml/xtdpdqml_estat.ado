*! version 1.4.3  26feb2017
*! Sebastian Kripfganz, www.kripfganz.de

*==================================================*
***** postestimation statistics after xtdpdqml *****

*** Citation ***

/*	Kripfganz, S. 2016.
	Quasi-maximum likelihood estimation of linear dynamic short-T panel-data models.
	Stata Journal 16: 1013-1038.		*/

program define xtdpdqml_estat, rclass
	version 12.1
	if "`e(cmd)'" != "xtdpdqml" {
		error 301
	}
	gettoken subcmd rest : 0, parse(" ,")
	if "`subcmd'" == substr("serial", 1, max(3, `: length loc subcmd')) {
		tempname eresults
		est sto `eresults'
		xtdpdqml_estat_serial `rest'
		qui est res `eresults'
	}
	else {
		estat_default `0'
	}
	ret add
end

program define xtdpdqml_estat_serial, rclass
	version 12.1
	syntax [,	AR(numlist int >0)					///
				noRobust]							// undocumented

	if e(k_eq) == 1 {
		di as err "estat serial not allowed after xtdpdqml without option mlparams"
		exit 198
	}
	if  e(stationary) {
		di as err "estat serial not allowed after xtdpdqml with option stationary"
		exit 198
	}
	if "`ar'" == "" {
		loc ar				"1 2"
	}
	tempvar smpl dsmpl e
	qui gen byte `smpl' = e(sample)
	qui predict double `e' if `smpl', e
	tempname b V
	mat `b'				= e(b)
	loc eqnames			: coleq `b', q
	loc eqnames			: list uniq eqnames
	mat `V'				= e(V)
	mat `V'				= `V'["_model:", "_model:"]
	if "`robust'" != "" {
		if "`e(vce)'" == "robust" {
			di as err "option norobust not allowed after xtdpdqml with option vce(robust)"
			exit 198
		}
		loc sigma2e			= _b[_sigma2e:_cons]
		mat `b'				= `b'[1, "_model:"]
		loc indepvars		: coln `b'
		loc indepvars		: subinstr loc indepvars "_cons" "`smpl'", w
		if "`e(model)'" == "re" {
			foreach var of loc indepvars {
				loc dindepvars		"`dindepvars' D.`var'"
			}
		}
		else {
			loc dindepvars		"`indepvars'"
		}
	}
	else {
		tempname be V0
		if "`e(vce)'" == "robust" {
			mat `V0'			= e(V_modelbased)
		}
		else {
			mat `V0'			= e(V)
		}
		loc sigma2e			= .
		forv eq = 1/`= e(k_eq)' {
			tempname score`eq'
			qui predict double `score`eq'' if `smpl', score eq(#`eq')
			loc eqname			: word `eq' of `eqnames'
			mat `be'			= `b'[1, `"`eqname':"']
			loc coefnames		: coln `be'
			loc coefnames		: subinstr loc coefnames "_cons" "`smpl'", w
			loc K				: word count `coefnames'
			forv k = 1/`K' {
				tempvar score`eq'_`k'
				loc var				: word `k' of `coefnames'
				qui gen double `score`eq'_`k'' = `var' * `score`eq'' if `smpl'
				loc scores		"`scores' `score`eq'_`k''"
				if `eq' == 1 {
					loc influence		"`influence' `score`eq'_`k''"
					if "`e(model)'" == "re" {
						loc dindepvars		"`dindepvars' D.`var'"
					}
					else {
						loc dindepvars		"`dindepvars' `var'"
					}
				}
			}
		}
	}
	if "`e(model)'" == "re" {
		loc de				"D.`e'"
	}
	else {
		loc de				"`e'"
	}
	di _n as txt "Arellano-Bond test for autocorrelation of the first-differenced residuals"
	foreach order of num `ar' {
		qui gen byte `dsmpl' = `smpl'
		markout `dsmpl' `de' L`order'.`de'
		mata: xtdpdqml_serial(	"`de'",					///
								"L`order'.`de'",		///
								"`dindepvars'",			///
								"`scores'",				///
								"`influence'",			///
								"`e(ivar)'",			///
								"`e(tvar)'",			///
								"`smpl'",				///
								"`dsmpl'",				///
								"`V'",					///
								"`V0'",					///
								`sigma2e')
		loc z`order'		= r(z)
		loc p`order'		= 2 * normal(- abs(`z`order''))
		qui drop `dsmpl'
		if "`scores'" != "" {
			loc scores			""
		}
		di as txt "H0: no autocorrelation of order " as res `order' as txt ":" _col(40) "z = " as res %9.4f `z`order'' _col(56) as txt "Prob > |z|" _col(68) "=" _col(73) as res %6.4f `p`order''
	}

	foreach order of num `ar' {
		ret sca p_`order'	= `p`order''
		ret sca z_`order'	= `z`order''
	}
end

/*
program define xtdpdqml_estat_serial, rclass
	version 12.1
	syntax [, noDIfference]

	tempvar e
	qui predict `e', e
	if "`e(model)'" == "fe" & e(k_eq) > 1 {
		if "`difference'" != "" {
			di as err "option nodifference not allowed"
			exit 198
		}
		qui reg L(0/1).`e', nocons vce(cluster `e(ivar)')
		qui test L.`e' = -.5
	}
	else if "`difference'" == "" {
		qui reg L(0/1)D.`e', nocons vce(cluster `e(ivar)')
		qui test LD.`e' = -.5
	}
	else {
		qui reg L(0/1).`e', nocons vce(cluster `e(ivar)')
		qui test L.`e'
	}

	di _n as txt "H0: no first-order autocorrelation of e_it" _col(56) "F(" %1.0f r(df) "," %6.0f r(df_r) _col(20) ") =" as res %8.2f r(F)
	if "`difference'" == "" {
		di _col(5) as txt "(autocorrelation of D.e_it equals -0.5)" _c
	}
	di as txt _col(59) "Prob > F =" as res %10.4f r(p)

	ret add
end
*/
