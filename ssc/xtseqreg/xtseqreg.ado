*! version 1.1.2  04jun2017
*! Sebastian Kripfganz, www.kripfganz.de

*==================================================*
****** sequential linear panel data estimation ******

*** citation ***

/*	Kripfganz, S., and C. Schwarz (2015).
	Estimation of linear dynamic panel data models with time-invariant regressors.
	ECB Working Paper 1838. European Central Bank.		*/

*** version history at the end of the file ***

program define xtseqreg, eclass prop(xt)
	version 12.1
	if replay() {
		if "`e(cmd)'" != "xtseqreg" {
			error 301
		}
		syntax [, Level(passthru) Combine noHEader noOMITted noTABle]
	}
	else {
		_xt, treq
		syntax anything(id="varlist") [if] [in] [, Level(passthru) Combine noHEader noOMITted noTABle *]
		gettoken depvar anything : anything , match(paren) bind
		if `: word count `depvar'' != 1 | `"`paren'"' != "" {
			error 198
		}
		gettoken indepvars1 anything : anything, match(paren) bind
		if `"`paren'"' == "" {
			loc anything		`"`indepvars1' `anything'"'
			loc indepvars1		""
		}
		xtseqreg_gmm (`indepvars1') `depvar' `anything' `if' `in', `options'

		eret loc predict	"xtseqreg_p"
		eret loc estat_cmd	"xtseqreg_estat"
		eret loc tvar		"`_dta[_TStvar]'"
		eret loc ivar		"`_dta[_TSpanel]'"
		eret loc cmdline 	`"xtseqreg `0'"'
		eret loc cmd		"xtseqreg"
	}

	xtseqreg_combine , `combine' `header' `omitted'
	loc header			"`r(header)'"
	loc omitted			"`r(omitted)'"
	if r(combine) {
		tempname b b2 V V2
		mat `b'				= r(b)
		mat `V'				= r(V)
		mat `b2'			= e(b)
		mat `V2'			= e(V)

		eret repost b = `b', ren
		eret repost V = `V'
		eret hidden mat V2	= `V2'
		eret hidden mat b2	= `b2'
	}
	xtseqreg_display , `level' `header' `omitted' `table'
end

*==================================================*
***** estimation *****
program define xtseqreg_gmm, eclass sort
	version 12.1
	gettoken firstvars 0 : 0, match(paren) bind
	syntax varlist(num ts) [if] [in] [,	noCONStant			///
										TEffects			///
										TWOstep				///
										Wmatrix(string)		///
										VCE(passthru)		///
										First(string)		///
										Both				///
										noCOMMONesample		///
										*]					// GMMIV() IV() parsed separately
	marksample touse
	gettoken depvar indepvars : varlist
	if "`indepvars'" == "" & "`constant'" != "" {
		error 102
	}
	if "`both'" != "" {
		if `"`first'"' != "" {
			di as err "options first() and both may not be combined"
			exit 184
		}
		if "`firstvars'" == "" {
			error 102
		}
		if "`commonesample'" == "" {
			qui xtseqreg `depvar' `firstvars' if `touse', `gmm' `constant' `teffects' `twostep' wmatrix(`wmatrix') `vce' `options'
		}
		else {
			qui xtseqreg `depvar' `firstvars' `if' `in', `gmm' `constant' `teffects' `twostep' wmatrix(`wmatrix') `vce' `options'
		}
		if "`constant'" != "" {
			loc first			", `constant'"
		}
	}
	tempvar dtouse
	qui gen byte `dtouse' = `touse'
	markout `dtouse' D.(`varlist')

	*--------------------------------------------------*
	*** time effects ***
	if "`teffects'" != "" {
		if "`both'" != "" {
			sum `_dta[_TStvar]' if e(sample), mean
		}
		else {
			sum `_dta[_TStvar]' if `touse', mean
		}
		loc tdelta			= int(`_dta[_TSdelta]')
		cap _rmcoll i(`= r(min)+`tdelta'*("`constant'" == "")'(`tdelta')`= r(max)')bn.`_dta[_TStvar]' if `touse', exp `constant'
		if _rc != 0 {
			error 451
		}
		loc teffects		"`r(varlist)'"
		if "`both'" != "" {
			loc firstvars		"`firstvars' `teffects'"
		}
		else {
			loc indepvars		"`indepvars' `teffects'"
		}
	}

	*--------------------------------------------------*
	*** syntax parsing of options for instruments ***
	if `"`options'"' == "" {
		loc ivvars			"`indepvars'"
	}
	else {
		tempvar obs
		qui by `_dta[_TSpanel]': gen `obs' = _n `if' `in'
		sum `obs', mean
		loc maxlag			= r(max) - 1
		drop `obs'
		while `"`options'"' != "" {
			xtseqreg_parse_options , maxlag(`maxlag') `both' `options'
			loc options			`"`s(options)'"'
			if `s(equation)' == 1 & "`firstvars'" != "" {
				if "`both'" == "" {
					di as txt "note: specified instruments for equation #1 ignored"
				}
				continue
			}
			else if `s(equation)' == 2 & "`firstvars'" == "" {
				di as txt "note: specified instruments for equation #2 ignored"
				continue
			}
			if "`s(model)'" == "" {
				loc gmmivvars		"`gmmivvars' `s(gmmiv)'"
				loc ivvars			"`ivvars' `s(iv)'"
			}
			else if `s(ec)' {
				loc ecgmmivvars		"`ecgmmivvars' `s(gmmiv)'"
				loc ecivvars		"`ecivvars' `s(iv)'"
			}
			else {
				loc dgmmivvars		"`dgmmivvars' `s(gmmiv)'"
				loc divvars			"`divvars' `s(iv)'"
			}
		}
		if "`teffects'" != "" & "`both'" == "" {
			loc ivvars "`ivvars' `teffects'"
		}
	}
	if "`constant'" == "" {
		loc indepvars		"`indepvars' `touse'"
		loc ivvars			"`ivvars' `touse'"
	}
	loc gmmivvars		: list retok gmmivvars
	loc ivvars			: list retok ivvars
	loc dgmmivvars		: list retok dgmmivvars
	loc divvars			: list retok divvars
	loc ecgmmivvars		: list retok ecgmmivvars
	loc ecivvars		: list retok ecivvars
	
	*--------------------------------------------------*
	*** type of weighting matrix ***
	xtseqreg_parse_wmatrix `wmatrix'
	loc wmatrix			"`s(wmatrix)'"
	loc ratio			= `s(ratio)'

	*--------------------------------------------------*
	*** type of variance-covariance matrices ***
	if `"`vce'"' != "" {
		xtseqreg_parse_vce , `vce' `twostep'
		loc vce				"`s(vce)'"
		loc vcediff			= `s(vcediff)'
		loc inconsistent	= `s(inconsistent)'
	}
	else {
		loc vce				"conventional"
		loc vcediff			= 0
		loc inconsistent	= 0
	}
	loc twostep			= ("`twostep'" != "")

	*--------------------------------------------------*
	*** syntax parsing of first-stage regression ***
	xtseqreg_parse_first (`firstvars') `first'
	loc eqname			`"`s(eqname)'"'
	loc firstvars		"`s(varlist)'"
	if "`firstvars'" != "" {
		if "`s(depvar)'" != "`depvar'" {
			di as txt "note: dependent variable `e(depvar)' from `e(cmd)' does not match with `depvar'"
		}
		tempname b1 V1
		mat `b1'			= `s(b)'
		mat `V1'			= `s(V)'
		if `"`eqname'"' != "" {
			mat `b1'			= `b1'[1, `"`eqname':"']
			mat `V1'			= `V1'[`"`eqname':"', `"`eqname':"']
		}
		loc coeflist		"`s(coeflist)'"
		if `: word count `coeflist'' < colsof(`b1') {
			tempname aux
			foreach coef of loc coeflist {
				mat `aux'			= (nullmat(`aux'), `b1'[1, `"`eqname':`coef'"'])
			}
			mat `b1'			= `aux'
		}
		if `: word count `firstvars'' < colsof(`V1') {
			tempname aux
			foreach coef of loc coeflist {
				mat `aux'			= (nullmat(`aux'), `V1'[`"`eqname':"', `"`eqname':`coef'"'])
			}
			mat `V1'			= `aux'
			mat drop `aux'
			foreach coef of loc coeflist {
				mat `aux'			= (nullmat(`aux') \ `V1'[`"`eqname':`coef'"', `"`eqname':"'])
			}
			mat `V1'			= `aux'
		}
		loc firstvars		: subinstr loc firstvars "_cons" "`touse'", all w
		markout `touse' `firstvars'
		tempvar touse1
		qui gen byte `touse1' = e(sample)
		if "`commonesample'" == "" {
			qui replace `touse' = 0 if !`touse1'
			qui replace `dtouse' = 0 if !`touse1'
		}
		if "`vce'" == "robust" & !(inlist("`e(vce)'", "robust", "cluster") | inlist("`e(vcetype)'", "Robust")) {
			di as txt "note: first-stage standard errors may not be robust"
		}
	}
	else if `inconsistent' {
		di as err "vcetype `vce' not allowed with argument 'inconsistent'"
		exit 198
	}
	sum `touse', mean
	if r(sum) == 0 {
		error 2000
	}

	*--------------------------------------------------*
	*** influence function ***
	if "`firstvars'" != "" & !`inconsistent' {
		if "`s(influence)'" == "" {
			loc V0				"`s(V_modelbased)'"
			if "`e(cmd)'" == "xtseqreg" {
				if `: word count `s(eqnames)'' > 1 {
					di as err "cannot compute scores after xtseqreg with two equations"
					exit 321
				}
				forv k = 1/`: word count `s(coefs1)'' {
					tempvar influence`k'
					loc influence_all	"`influence_all' `influence`k''"
					loc var				: word `k' of `s(coefs1)'
					if `: list var in coeflist' {
						loc influence		"`influence' `influence`k''"
					}
				}
				qui predict double `influence_all' if `touse1', score
			}
			else {
				loc scores			"`s(scores)'"
				loc eqnames			`"`s(eqnames)'"'
				loc coeflist		: subinstr loc coeflist "_cons" "`touse1'", all w
				forv e = 1/`: word count `eqnames'' {
					loc coefs`e'		"`s(coefs`e')'"
					if "`scores'" == "" {
						tempvar score`e'
						loc scorevars		"`scorevars' `score`e''"
					}
					else {
						loc score`e'		: word `e' of `scores'
					}
				}
				if "`scorevars'" != "" {
					cap predict double `scorevars' if `touse1', score
					if _rc != 0 {
						di as err "cannot compute scores after `e(cmd)'"
						exit 321
					}
				}
				forv e = 1/`: word count `eqnames'' {
					loc eq				: word `e' of `eqnames'
					loc coefs`e'		: subinstr loc coefs`e' "_cons" "`touse1'", all w
					forv k = 1/`: word count `coefs`e''' {
						loc var				: word `k' of `coefs`e''
						tempvar influence`e'_`k'
						qui gen double `influence`e'_`k'' = `var' * `score`e'' if `touse1'
						loc influence_all	"`influence_all' `influence`e'_`k''"
						if (`"`eq'"' == `"`eqname'"' & `: list var in coeflist') | `"`eqname'"' == "" {
							loc influence		"`influence' `influence`e'_`k''"
						}
					}
				}
				if "`scores'" == "" {
					drop `scorevars'
				}
			}
			mata: xtseqreg_influence("`influence_all'", "`V0'", "", "`touse1'")
			cap drop `: list influence_all - influence'
		}
		else {
			loc influence		"`s(influence)'"
		}
	}
	else {
		loc influence		""
	}

	*--------------------------------------------------*
	*** estimation ***
	mata: xtseqreg_est(	"`depvar'",						/// dependent variable
						"`indepvars'",					/// regressor variables
						"`ivvars'",						/// standard instruments
						"`gmmivvars'",					/// GMM instruments
						"`divvars'",					/// standard instruments for first-differenced model
						"`dgmmivvars'",					/// GMM instruments for first-differenced model
						"`ecivvars'",					/// collapsed GMM homoskedasticity instruments for first-differenced model
						"`ecgmmivvars'",				/// GMM homoskedasticity instruments for first-differenced model
						"`firstvars'",					/// first-stage regressor variables
						"`influence'",					/// first-stage influence function variables
						"`_dta[_TSpanel]'",				/// panel identifier
						"`_dta[_TStvar]'",				/// time identifier
						"`touse'",						/// marker variable
						"`dtouse'",						/// marker variable for first-differenced model
						"`b1'",							/// first-stage coefficient vector
						"`V1'",							/// first-stage variance-covariance matrix
						"`vce'",						/// type of the variance-covariance matrix
						`vcediff',						/// error variance from first-differenced residuals
						"`wmatrix'",					/// type of the weighting matrix
						`ratio',						/// random-effects variance ratio
						`twostep',						/// two-step estimation
						`inconsistent')
	tempname b V W
	mat `b'				= r(b)
	mat `V'				= r(V)
	if "`firstvars'" == "" {
		if !("`vce'" != "robust" & `twostep') {
			tempname V0
			mat `V0'			= r(V0)
		}
		if `twostep' & "`vce'" == "robust" {
			tempname b1 W1 V01
			mat `b1'			= r(b1)
			mat `V01'			= r(V1)
			mat `W1'			= r(W1)
		}
	}
	mat `W'				= r(W)
	loc N				= r(N)
	loc N_g				= r(N_g)
	loc T_min			= r(T_min)
	loc T_max			= r(T_max)
	loc	k_all			= r(rank)
	loc	k				= r(rank2)
	loc k_Z				= r(zrank)
	loc sigma2e			= r(sigma2e)
	loc sigma2u			= r(sigma2u)
	loc J				= r(J)

	loc indepvars		: subinstr loc indepvars "`touse'" "_cons", w
	if "`firstvars'" != "" {
		loc firstvars		: subinstr loc firstvars "`touse'" "_cons", w
		foreach var of loc firstvars {
			loc regnames		"`regnames' _first:`var'"
		}
		foreach var of loc indepvars {
			loc regnames		"`regnames' _second:`var'"
		}
	}
	else {
		loc regnames		"`indepvars'"
	}
	mat coln `b'		= `regnames'
	mat rown `V'		= `regnames'
	mat coln `V'		= `regnames'
	loc firstvars		= ("`firstvars'" != "")
	if !`firstvars' {
		if !("`vce'" != "robust" & `twostep') {
			mat rown `V0'		= `regnames'
			mat coln `V0'		= `regnames'
		}
		if `twostep' & "`vce'" == "robust" {
			mat coln `b1'		= `regnames'
			mat rown `V01'		= `regnames'
			mat coln `V01'		= `regnames'
		}
	}
	loc ivvars			: subinstr loc ivvars "`touse'" "_cons", w

	*--------------------------------------------------*
	*** prior estimation results ***
	if `firstvars' {
		loc k1				= e(rank)
		if "`both'" != "" | "`e(cmd)'" == "xtseqreg" {
			loc ecgmmivvars1	"`e(ecgmmivvars_1)'"
			loc ecivvars1		"`e(ecivvars_1)'"
			loc dgmmivvars1		"`e(dgmmivvars_1)'"
			loc divvars1		"`e(divvars_1)'"
			loc gmmivvars1		"`e(gmmivvars_1)'"
			loc ivvars1			"`e(ivvars_1)'"
		}
		tempvar ttouse1
		qui by `_dta[_TSpanel]': egen `ttouse1' = total(`touse1') if `touse1'
		qui xtsum `ttouse1'
		loc N1				= r(N)
		loc N_g1			= r(n)
		loc T_min1			= r(min)
		loc T_max1			= r(max)
		if "`both'" == "" {
			qui replace `ttouse1' = `touse'
			qui replace `ttouse1' = `touse1' if `touse1' & !`touse'
			qui xtsum `ttouse1' if `ttouse1'
		}
		else {
			qui replace `touse' = `touse1' if `touse1' & !`touse'
			qui xtsum `touse' if `touse'
		}
		loc N12				= r(N)
		loc N_g12			= r(n)
	}
	else {
		loc N12				= `N'
	}
	tempname stats
	if `firstvars' {
		if "`both'" == "" & "`e(cmd)'" != "xtseqreg" {
			mat `stats'			= (`N1', `N_g1', `T_min1', `N1' / `N_g1', `T_max1', `k1', ., .)
		}
		else {
			mat `stats'			= e(stats)
		}
	}
	mat `stats'			= (nullmat(`stats') \ `N', `N_g', `T_min', `N' / `N_g', `T_max', `k', `k_Z', `J')
	loc statistics		"N N_g g_min g_avg g_max rank zrank chi2_J"
	mat coln `stats'	= `statistics'

	*--------------------------------------------------*
	*** current estimation results ***
	eret post `b' `V', dep(`depvar') o(`N12') e(`touse')
	if `firstvars' {
		eret sca N_g		= `N_g12'
		eret sca rank		= `k_all'
	}
	else {
		eret sca N_g		= `N_g'
		eret sca rank		= `k'
	}
	if "`vce'" != "robust" & !(`twostep' & "`vce'" == "conventional") {
		eret sca sigma2e		= `sigma2e'
		eret sca sigma2u		= `sigma2u'
	}
	eret sca twostep	= `twostep'
	if `inconsistent' {
		eret loc vcetype	"Inconsistent"
	}
	else if `twostep' & "`vce'" == "robust" {
		eret loc vcetype	"WC-Robust"
	}
	else if "`vce'" == "robust" {
		eret loc vcetype	"Robust"
	}
	eret loc vce		"`vce'"
	eret loc wmatrix	"`wmatrix', ratio(`ratio')"
	if `firstvars' {
		eret loc ecgmmivvars_2 "`ecgmmivvars'"
		eret loc ecivvars_2	"`ecivvars'"
		eret loc dgmmivvars_2 "`dgmmivvars'"
		eret loc divvars_2	"`divvars'"
		eret loc gmmivvars_2 "`gmmivvars'"
		eret loc ivvars_2	"`ivvars'"
		if "`both'" != "" {
			eret loc ecgmmivvars_1 "`ecgmmivvars1'"
			eret loc ecivvars_1	"`ecivvars1'"
			eret loc dgmmivvars_1 "`dgmmivvars1'"
			eret loc divvars_1	"`divvars1'"
			eret loc gmmivvars_1 "`gmmivvars1'"
			eret loc ivvars_1	"`ivvars1'"
		}
	}
	else {
		eret loc ecgmmivvars_1 "`ecgmmivvars'"
		eret loc ecivvars_1	"`ecivvars'"
		eret loc dgmmivvars_1 "`dgmmivvars'"
		eret loc divvars_1	"`divvars'"
		eret loc gmmivvars_1 "`gmmivvars'"
		eret loc ivvars_1	"`ivvars'"
	}
	eret loc teffects	"`teffects'"
	eret mat stats		= `stats'
	if !`firstvars' & (`twostep' & "`vce'" == "robust") {
		eret mat W_onestep		= `W1'
		eret mat V_onestep		= `V01'
		eret mat b_onestep		= `b1'
	}
	eret mat W			= `W'
	if !`firstvars' & !("`vce'" != "robust" & `twostep') {
		eret mat V_modelbased	= `V0'
	}
end

*==================================================*
**** display of estimation results ****
program define xtseqreg_display
	version 12.1
	syntax [, Level(cilevel) noHEader noOMITted noTABle]

	if "`header'" == "" {
		di _n as txt "Group variable: " as res abbrev("`e(ivar)'", 12) _col(46) as txt "Number of obs" _col(68) "=" _col(70) as res %9.0f e(N)
		di as txt "Time variable: " as res abbrev("`e(tvar)'", 12) _col(46) as txt "Number of groups" _col(68) "=" _col(70) as res %9.0f e(N_g)
		if rowsof(e(stats)) == 1 {
			di _n _col(46) as txt "Obs per group:" _col(64) "min =" _col(70) as res %9.0g el(e(stats), 1, 3)
			di _col(64) as txt "avg =" _col(70) as res %9.0g el(e(stats), 1, 4)
			di _col(64) as txt "max =" _col(70) as res %9.0g el(e(stats), 1, 5)
			di _n _col(46) as txt "Number of instruments =" _col(70) as res %9.0f el(e(stats), 1, 7)
		}
		else {
			di _n as txt "{hline 78}"
			di as txt "Equation " as res "_first" _col(46) as txt "Equation " as res "_second"
			di as txt "Number of obs" _col(23) "=" _col(25) as res %9.0f el(e(stats), 1, 1) _col(46) as txt "Number of obs" _col(68) "=" _col(70) as res %9.0f el(e(stats), 2, 1)
			di as txt "Number of groups" _col(23) "=" _col(25) as res %9.0f el(e(stats), 1, 2) _col(46) as txt "Number of groups" _col(68) "=" _col(70) as res %9.0f el(e(stats), 2, 2)
			di _n as txt "Obs per group:" _col(19) "min =" _col(25) as res %9.0g el(e(stats), 1, 3) _col(46) as txt "Obs per group:" _col(64) "min =" _col(70) as res %9.0g el(e(stats), 2, 3)
			di _col(19) as txt "avg =" _col(25) as res %9.0g el(e(stats), 1, 4) _col(64) as txt "avg =" _col(70) as res %9.0g el(e(stats), 2, 4)
			di _col(19) as txt "max =" _col(25) as res %9.0g el(e(stats), 1, 5) _col(64) as txt "max =" _col(70) as res %9.0g el(e(stats), 2, 5)
			if el(e(stats), 1, 7) < . {
				di _n as txt "Number of instruments =" _col(25) as res %9.0f el(e(stats), 1, 7) _col(46) as txt "Number of instruments =" _col(70) as res %9.0f el(e(stats), 2, 7)
			}
			else {
				di _n _col(46) as txt "Number of instruments =" _col(70) as res %9.0f el(e(stats), 2, 7)
			}
		}
	}
	if "`table'" == "" {
		di ""
		eret di, l(`level') `omitted'
	}
end

*==================================================*
**** syntax parsing of options for instruments ****
program define xtseqreg_parse_options, sclass
	version 12.1
	sret clear
	syntax , MAXLAG(integer) [Both GMMiv(string) IV(string) *]

	*--------------------------------------------------*
	*** GMM instruments ***
	if `"`gmmiv'"' != "" {
		gettoken gmmivvars gmmiv : gmmiv, p(",")
		if "`gmmiv'" == "" {
			loc gmmiv			","
		}
		xtseqreg_parse_gmmiv `gmmivvars' `gmmiv' maxlag(`maxlag')
		if "`both'" != "" & `"`s(equation)'"' == "" {
			di as err "option gmmiv() incorrectly specified -- equation() required"
			exit 198
		}
	}

	*--------------------------------------------------*
	*** standard instruments ***
	if "`gmmivvars'" == "" {
		if `"`iv'"' != "" {
			xtseqreg_parse_iv `iv'
			if "`both'" != "" & `"`s(equation)'"' == "" {
				di as err "option iv() incorrectly specified -- equation() required"
				exit 198
			}
		}
		else if `"`options'"' == "" {
			error 198
		}
		else {
			di as err `"`options' invalid"'
			exit 198
		}
	}
	else if `"`iv'"' != "" {
		loc options			`"iv(`iv') `options'"'
	}

	*--------------------------------------------------*
	*** equation for sequential estimation ***
	if `"`s(equation)'"' == "" {
		loc eq				= .
	}
	else if `: word count `s(equation)'' > 1 {
		di as err "option equation() incorrectly specified"
		exit 198
	}
	else if substr(`"`s(equation)'"', 1, 1) == "#" {
		loc eq				= substr(`"`s(equation)'"', 2, .)
		cap conf integer num `eq'
		if _rc != 0 | (`eq' != 1 & `eq' != 2) {
			di as err "option equation() incorrectly specified -- equation `s(equation)' not found"
			exit 303
		}
	}
	else if `"`s(equation)'"' == "_first" {
		loc eq				= 1
	}
	else if `"`s(equation)'"' == "_second" {
		loc eq				= 2
	}
	else {
		di as err "option equation() incorrectly specified -- equation `s(equation)' not found"
		exit 303
	}

	sret loc equation		= `eq'
	sret loc options		`"`options'"'
end

*==================================================*
**** syntax parsing for GMM instruments ****
program define xtseqreg_parse_gmmiv, sclass
	version 12.1
	syntax varlist(num ts), MAXLag(integer) [Lagrange(numlist max=2 int miss) Difference Collapse EC Model(string) EQuation(string)]

	if "`ec'" == "" {
		if "`difference'" != "" {
			loc --maxlag
		}
		gettoken lag1 lag2 : lagrange
		if "`lag1'" == "" {
			loc lag1			= 1
		}
		else if `lag1' == . {
			loc lag1			= - `maxlag'
		}
		if "`lag2'" == "" {
			loc lag2			= `maxlag'
		}
		else if `lag2' == . {
			loc lag2			= `maxlag'
		}
		if `lag1' > `lag2' {
			di as err "option lagrange() incorrectly specified -- invalid numlist has elements out of order"
			exit 124
		}
		foreach var of loc varlist {
			if "`difference'" == "" {
				loc gmmivvars		"`gmmivvars' L(`lag1'/`lag2').`var'"
			}
			else {
				loc gmmivvars		"`gmmivvars' L(`lag1'/`lag2')D.`var'"
			}
		}
	}
	else if "`lagrange'" != "" {
		di as err "options ec and lagrange() may not be combined"
		exit 184
	}
	else if "`difference'" == "" {
		loc gmmivvars		"`varlist'"
	}
	else {
		foreach var of loc varlist {
			loc gmmivvars		"`gmmivvars' D.`var'"
		}
	}
	xtseqreg_parse_model , `model' `ec'

	if ("`collapse'" == "") {
		sret loc gmmiv		"`gmmivvars'"
	}
	else {
		sret loc iv			"`gmmivvars'"
	}
	sret loc equation	`"`equation'"'
end

*==================================================*
**** syntax parsing for standard instruments ****
program define xtseqreg_parse_iv, sclass
	version 12.1
	syntax varlist(num ts) [, Difference Model(string) EQuation(string)]

	if "`difference'" == "" {
		loc ivvars			"`varlist'"
	}
	else {
		foreach var of loc varlist {
			loc ivvars			"`ivvars' D.`var'"
		}
	}
	xtseqreg_parse_model , `model'

	sret loc iv			"`ivvars'"
	sret loc equation	`"`equation'"'
end

*==================================================*
**** syntax parsing for the model equations ****
program define xtseqreg_parse_model, sclass
	version 12.1
	syntax [, Level Difference EC]

	if "`difference'" != "" {
		if "`level'" != "" {
			di as err "option model() incorrectly specified"
			exit 198
		}
	}
	else if "`ec'" != "" {
		if "`level'" != "" {
			di as err "options ec and model(level) may not be combined"
			exit 184
		}
		loc difference		"difference"
	}

	sret loc model		"`difference'"
	sret loc ec			= ("`ec'" != "")
end

*==================================================*
**** syntax parsing for weighting matrix ****
program define xtseqreg_parse_wmatrix, sclass
	version 12.1
	syntax [anything] , [Ratio(numlist max=1 >=0)]

	loc length			: length loc anything
	if `"`anything'"' == "" | `"`anything'"' == substr("unadjusted", 1, max(2, `length')) {
		loc anything		"unadjusted"
	}
	else if `"`anything'"' == substr("independent", 1, max(3, `length')) {
		loc anything		"independent"
	}
	else if `"`anything'"' == substr("separate", 1, max(3, `length')) {
		loc anything		"separate"
	}
	else if `"`anything'"' == substr("identity", 1, max(2, `length')) {		// undocumented wmat_type
		if "`ratio'" != "" {
			di as err "option ratio() not allowed with wmatrix(identity)"
			error 198
		}
		loc anything		"identity"
	}
	else {
		di as err "option wmatrix() incorrectly specified"
		exit 198
	}
	if "`ratio'" == "" {
		loc ratio			= 0
	}

	sret loc wmatrix	"`anything'"
	sret loc ratio		= `ratio'
end

*==================================================*
**** syntax parsing for variance-covariance matrix ****
program define xtseqreg_parse_vce, sclass
	version 12.1
	syntax , [VCE(passthru) TWOstep]

	loc vcediff			= 0
	loc inconsistent	= 0
	cap _vce_parse , opt(CONVENTIONAL EC Robust) : , `vce'
	if "`r(vce)'" == "" {
		cap _vce_parse , : , `vce'
	}
	if _rc != 0 {
		cap _vce_parse , argopt(CONVENTIONAL EC Robust) : , `vce'
		if _rc != 0 {
			_vce_parse , : , `vce'
		}
		loc vceargs			"`r(vceargs)'"
		loc vceargs			: subinstr loc vceargs "," ""
		loc vceargs			: list retokenize vceargs
		foreach vcearg of loc vceargs {
			if "`vcearg'" == substr("difference", 1, max(1, `: length loc vcearg')) & ("`r(vce)'" == "" | "`r(vce)'" == "conventional") {
				if "`twostep'" != "" {
					di as err "invalid vce() option"
					exit 198
				}
				loc vcediff			= 1
			}
			else if "`vcearg'" == "inconsistent" {		// undocumented vce argument
				loc inconsistent	= 1
			}
			else {
				di as err "invalid vce() option"
				exit 198
			}
		}
	}

	if "`r(vce)'" == "" {
		sret loc vce		"conventional"
	}
	else {
		sret loc vce		"`r(vce)'"
	}
	sret loc vcediff		= `vcediff'
	sret loc inconsistent	= `inconsistent'
end

*==================================================*
**** syntax parsing of the first-stage regression ****
program define xtseqreg_parse_first, sclass
	version 12.1
	sret clear
	gettoken indepvars 0 : 0, match(paren) bind
	syntax [name] , [noCONStant EQuation(string) COPY B(name) V(namelist max=2) SCores(varlist num) INFluence(varlist num)]

	*--------------------------------------------------*
	*** first-stage variables ***
	if "`indepvars'" == "" {
		if `: word count `0'' > 0 {
			error 102
		}
		exit
	}
	else {
		qui _rmcoll `indepvars', exp `constant'
		loc indepvars		"`r(varlist)'"
	}

	*--------------------------------------------------*
	*** first-stage estimation results ***
	if "`namelist'" != "" {
		qui est res `namelist'
	}
	tempvar touse
	qui gen byte `touse' = e(sample)
	sum `touse', mean
	if r(mean) == 0 {
		error 301
	}
	if "`b'" == "" {
		loc b				"e(b)"
	}
	tempname b1
	mat `b1'			= `b'
	loc copy			= ("`copy'" != "")
	if `copy' {
		loc eqnames			: coleq e(b), q
	}
	else {
		loc eqnames			: coleq `b1', q
	}
	loc eqnames			: list uniq eqnames
	if "`influence'" == "" {
		if "`v'" == "" {
			loc v1				"e(V)"
			cap conf mat e(V_modelbased)
			if _rc == 0 {
				loc v0				"e(V_modelbased)"
			}
			else {
				if inlist("`e(vce)'", "robust", "cluster", "bootstrap", "jackknife") | inlist("`e(vcetype)'", "Robust", "WC-Robust", "Bootstrap", "Jackknife") {
					di as err `"cannot compute scores based on `= cond("`e(vce)'" != "", "vce(`e(vce)')", lower("`e(vcetype)' std. err."))' after `e(cmd)'"'
					exit 322
				}
				loc v0				"e(V)"
			}
		}
		else {
			foreach vname of loc v {
				conf mat `vname'
				if rowsof(`vname') != colsof(`vname') | colsof(`vname') != colsof(`b1') {
					di as err "option v() incorrectly specified -- conformability error"
					exit 503
				}
				if "`v1'" == "" {
					loc v1				"`vname'"
				}
				else {
					loc v0				"`vname'"
				}
			}
			if "`v0'" == "" {
				loc v0				"`v1'"
			}
		}
		if ("`: colf `v1''" != "`: colf `b1''" | "`: colf `v0''" != "`: colf `b1''") & !`copy' {
			di as err "option b() or v() incorrectly specified -- column names do not match"
			exit 322
		}
	}

	*--------------------------------------------------*
	*** first-stage scores ***
	if "`scores'" != "" {
		if "`influence'" != "" {
			di as err "options scores() and influence() may not be combined"
			exit 184
		}
		if `: word count `scores'' < `: word count `eqnames'' {
			di as err "option scores() incorrectly specified -- too few variables specified"
			exit 102
		}
		if `: word count `scores'' > `: word count `eqnames'' {
			di as err "option scores() incorrectly specified -- too many variables specified"
			exit 103
		}
	}

	*--------------------------------------------------*
	*** first-stage coefficients and variables ***
	if `"`equation'"' == "" {
		if !`copy' {
			loc eqname			: word 1 of `eqnames'
		}
	}
	else if `copy' {
		di as err "options equation() and copy may not be combined"
		exit 184
	}
	else if `: word count `equation'' > 1 {
		di as err "option equation() incorrectly specified"
		exit 198
	}
	else if substr(`"`equation'"', 1, 1) == "#" {
		loc eq				= substr(`"`equation'"', 2, .)
		cap conf integer num `eq'
		loc eqname			: word `eq' of `eqnames'
		if _rc != 0 | "`eqname'" == "" {
			di as err "option equation() incorrectly specified -- equation `equation' not found"
			exit 303
		}
	}
	else if `: list equation in eqnames' {
		loc eqname			`"`equation'"'
		loc eq				: posof `"`eqname'"' in eqnames
	}
	else {
		di as err "option first() incorrectly specified -- equation `equation' not found"
		exit 303
	}
	if `: word count `e(depvar)'' > 1 {
		loc depvar			: word `eq' of `e(depvar)'
	}
	else {
		loc depvar			"`e(depvar)'"
	}
	tempname beq
	if `copy' {
		if "`constant'" == "" {
			loc indepvars		"`indepvars' _cons"
		}
		loc bvars			: coln `b1'
		if `: word count `indepvars'' != `: word count `bvars'' {
			di as err "option first() incorrectly specified"
			exit 322
		}
	}
	else {
		mat `beq'			= `b1'[1, `"`eqname':"']
		loc bvars			: coln `beq'
		loc cons			"_cons"
		if `: list cons in bvars' {
			loc indepvars		"`indepvars' _cons"
		}
		if (`: word count `indepvars'' < `: word count `bvars'' & !`: list indepvars in bvars') | (`: word count `indepvars'' > `: word count `bvars'') {
			di as err "option first() incorrectly specified -- variable names do not match"
			exit 322
		}
		if "`constant'" != "" {
			loc indepvars		: list indepvars - cons
			loc bvars			: list bvars - cons
		}
		if `: word count `indepvars'' == `: word count `bvars'' & !`: list indepvars === bvars' {
			di as txt "note: first-stage variable names do not match with coefficient list from `e(cmd)'"
		}
		else {
			loc drop			: list bvars - indepvars
			loc indepvars		: list bvars - drop
			loc bvars			"`indepvars'"
		}
	}

	*--------------------------------------------------*
	*** first-stage influence functions ***
	if "`influence'" == "" {
		loc e				= 1
		foreach eq of loc eqnames {
			mat `beq'			= `b1'[1, "`eq':"]
			loc coefs`e'		: coln `beq'
			sret loc coefs`e'	"`coefs`e''"
			loc ++e
		}
		sret loc scores		"`scores'"
		sret loc eqnames	`"`eqnames'"'
		sret loc V_modelbased "`v0'"
	}
	else {
		if `: word count `influence'' < `: word count `indepvars'' {
			di as err "option influence() incorrectly specified -- too few variables specified"
			exit 102
		}
		if `: word count `influence'' > `: word count `indepvars'' {
			di as err "option influence() incorrectly specified -- too many variables specified"
			exit 103
		}
		sret loc influence	"`influence'"
	}
	sret loc V			"`v1'"
	sret loc b			"`b'"
	sret loc depvar		"`depvar'"
	sret loc varlist	"`indepvars'"
	sret loc coeflist	"`bvars'"
	sret loc eqname		`"`eqname'"'
end

*==================================================*
**** combine first-stage and second-stage results ****
program define xtseqreg_combine, rclass
	version 12.1
	syntax , [Combine noHEader noOMITted]
	loc combine			= ("`combine'" != "")

	if `combine' & rowsof(e(stats)) != 2 {
		di as err "option combine not allowed"
		exit 198
	}
	if `combine' {
		loc header			"noheader"
		loc omitted			"noomitted"
	}

	tempname b V
	cap conf mat e(b2)
	if _rc != 0 & !`combine' {
		loc combine			= 0
	}
	else if _rc == 0 {
		mat `b'				= e(b2)
		loc eqnames			: coleq `b', q
		loc eqnames			: list uniq eqnames
		if `: word count `eqnames'' + `combine' != 2 {
			loc combine			= 0
		}
		else {
			loc combine			= 1
			mat `V'				= e(V2)
		}
	}
	else {
		tempname b1 b2
		mat `b'				= e(b)
		mat `b1'			= `b'[1, "_first:"]
		mat `b2'			= `b'[1, "_second:"]
		mat coleq `b'		= ""
		loc regnames		: coln `b'
		loc dupnames		: list dups regnames
		if "`dupnames'" != "" {
			if "`dupnames'" != "_cons" {
				di as err "cannot combine equations -- repeated variable names"
				exit 321
			}
			mat coleq `b1'		= ""
			mat coleq `b2'		= ""
			loc regnames1		: coln `b1'
			loc regnames2		: coln `b2'
			loc regnum1			: word count `regnames1'
			loc regnum2			: word count `regnames2'
			if "`: word `regnum1' of `regnames1''" != "_cons" {
				di as err "option combine not allowed -- _cons is not ordered last in equation #1"
				exit 198
			}
			if `regnum1' > 1 {
				mat `b'				= `b1'[1, "`: word 1 of `regnames1''" .. "`: word `= `regnum1' - 1' of `regnames1''"]
				if `regnum2' > 1 {
					mat `b'				= (`b', `b2'[1, "`: word 1 of `regnames2''" .. "`: word `= `regnum2' - 1' of `regnames2''"])
				}
				mat `b'				= (`b', `b1'[1, "_cons"] + `b2'[1, "_cons"], 0)
			}
			else if `regnum2' > 1 {
				mat `b'				= (`b2'[1, "`: word 1 of `regnames2''" .. "`: word `= `regnum2' - 1' of `regnames2''"], `b1'[1, "_cons"] + `b2'[1, "_cons"], 0)
			}
			else {
				mat `b'				= (`b1'[1, "_cons"] + `b2'[1, "_cons"], 0)
			}
			tempname g
			mat `g'				= (I(`= `regnum1' - 1'), J(`= `regnum1' - 1', `= 1 + `regnum2'', 0) \ J(1, `= `regnum1' + `regnum2' - 2', 0), 1, 0 \ J(`regnum2', `= `regnum1' - 1', 0), I(`regnum2'), J(`regnum2', 1, 0))
			mat `V'				= `g'' * e(V) * `g'
			loc cons			"_cons"
			loc regnames		"`: list regnames1 - cons' `regnames2' o._cons"
			mat coln `b'		= `regnames'
			mat coln `V'		= `regnames'
			mat rown `V'		= `regnames'
		}
		else {
			mat `V'				= e(V)
			mat coleq `V'		= ""
			mat roweq `V'		= ""
		}
	}

	ret sca combine		= `combine'
	ret loc header		"`header'"
	ret loc omitted		"`omitted'"
	if `combine' {
		ret mat b			= `b'
		ret mat V			= `V'
	}
end

*==================================================*
*** version history ***
* version 1.1.2  04jun2017  reported weighting matrix rescaled by number of groups
* version 1.1.1  31may2017  option scores replaces option influence for predict; difference-in-Hansen test added to estat overid; documentation for estat hausman added; improved display options; bug fixed for predict with Windmeijer-corrected scores
* version 1.1.0  11apr2017  predict computes influence functions now with additional Windmeijer correction term; undocumented postestimation command estat hausman added
* version 1.0.3  28mar2017  bug fixed with option noconstant and zero instruments; suboption copy added for option first()
* version 1.0.2  27feb2017  postestimation command estat serial added; bug fixed with second-stage standard-error correction after first-stage one-step GMM estimation
* version 1.0.1  15feb2017  option teffects added; covariance between first-stage and second-stage coefficients corrected
* version 1.0.0  12feb2017  available online at www.kripfganz.de
* version 0.2.0  04nov2015
* version 0.1.1  07feb2014
* version 0.1.0  14oct2013
* version 0.0.5  16may2013
* version 0.0.4  07may2012
* version 0.0.3  25apr2012
* version 0.0.2  20apr2012
* version 0.0.1  13apr2012
