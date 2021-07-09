*! version 1.0.1  12sep2020
*! Sebastian Kripfganz, www.kripfganz.de
*! Jan F. Kiviet, sites.google.com/site/homepagejfk/

*==================================================*
***** postestimation statistics after kinkyreg *****

*** citation ***

/*	Kripfganz, S., and J. F. Kiviet. 2020.
	kinkyreg: Instrument-free inference for linear regression models with endogenous regressors.
	Manuscript submitted to the Stata Journal.		*/

program define kinkyreg_estat, rclass
	version 13.0
	if "`e(cmd)'" != "kinkyreg" {
		error 301
	}
	gettoken subcmd rest : 0, parse(" ,")
	if "`subcmd'" == "test" {
		loc subcmd			"test"
	}
	else if "`subcmd'" == substr("exclusion", 1, max(4, `: length loc subcmd')) {
		loc subcmd			"exclusion"
	}
	else if "`subcmd'" == substr("hettest", 1, max(4, `: length loc subcmd')) {
		loc subcmd			"hettest"
	}
	else if "`subcmd'" == "reset" | "`subcmd'" == substr("ovtest", 1, max(3, `: length loc subcmd')) {
		loc subcmd			"reset"
	}
	else if "`subcmd'" == substr("durbinalt", 1, max(3, `: length loc subcmd')) {
		loc subcmd			"durbinalt"
	}
	else {
		loc subcmd			""
	}
	if "`subcmd'" != "" {
		kinkyreg_estat_`subcmd' `rest'
	}
	else {
		estat_default `0'
	}
	ret add
end

*==================================================*
**** computation of linear hypotheses tests ****
program define kinkyreg_estat_test, rclass
	version 13.0
	cap conf mat e(V_1)
	if _rc {
		error 301
	}
	syntax [anything(equalok)], [CORRelation(numlist max=1 >=-1 <=1) noGRaph *]		// parsed separately: TWoway() PVALPlot()

	if "`correlation'" != "" {
		if `correlation' < e(grid_min) | `correlation' > e(grid_max) {
			di as err "correlation() invalid -- invalid number, outside of allowed range"
			exit 125
		}
	}
	while `"`options'"' != "" {
		kinkyreg_estat_parse_options , test `options'
		if `"`s(twopt)'"' != "" {
			loc twopt			`"`twopt' `s(twopt)'"'
		}
		if `"`s(twname)'"' != "" {
			loc twname 			`"`s(twname)'"'
		}
		if `"`s(addplot)'"' != "" {
			loc addplot			`"`s(addplot)'"'
		}
		if `"`s(pvalopt)'"' != "" {
			loc pvalopt_		`"`pvalopt_' `s(pvalopt)'"'
		}
		if `"`s(test)'"' != "" {
			loc testopt			`"`s(test)'"'
		}
		loc options			`"`s(options)'"'
	}
	loc namestub		"`e(namestub)'"

	tempname b kinkyreg_e test p
	mat `b'				= e(b_kls)
	loc N_grid			= rowsof(`b')
	loc grid_min		= e(grid_min)
	loc grid_step		= e(grid_step)
	loc small			= (e(df_r) < .)
	est sto `kinkyreg_e'
	forv g = 1 / `N_grid' {
		qui kinkyreg, corr(`= `grid_min' + (`g' - 1) * `grid_step'')
		cap test `anything', `testopt'
		if _rc {
			cap noi test `anything', `testopt'
			qui est res `kinkyreg_e'
			est drop `kinkyreg_e'
			exit _rc
		}
		if `small' {
			mat `test'			= (nullmat(`test') \ r(F))
		}
		else {
			mat `test'			= (nullmat(`test') \ r(chi2))
		}
		mat `p'				= (nullmat(`p') \ r(p))
	}
	qui est res `kinkyreg_e'
	est drop `kinkyreg_e'
	loc gid				: rown `b'
	mat rown `test'		= `gid'
	mat rown `p'		= `gid'

	if "`graph'" == "" {
		tempvar gridrange p_test
		qui gen `gridrange' = e(grid_min) + (_n - 1) * e(grid_step) in 1 / `N_grid'
		la var `gridrange' "postulated endogeneity of `e(klsvar)'"
		qui gen double `p_test' = .
		la var `p_test' "linear hypotheses"
		mata: st_store((1, `N_grid'), "`p_test'", st_matrix("`p'")[., 1])
		loc tw_test			"(line `p_test' `gridrange', `pvalopt_')"
		if `"`twname'"' == "" {
			loc twname			"name(`namestub'_test, replace)"
		}
		tw `tw_test' `addplot' ||, yti("p-value") `twopt' `twname'
	}

	if "`correlation'" != "" {
		tempname kinkyreg_e
		est sto `kinkyreg_e'
		qui kinkyreg, corr(`correlation')
		di _n as txt "Test of linear hypotheses"
		di _n "Postulated endogeneity of `e(klsvar)' = " %5.4f e(corr) _c
		test `anything', `testopt'
		qui est res `kinkyreg_e'
		est drop `kinkyreg_e'
	}

	if `small' {
		ret mat F			= `test'
	}
	else {
		ret mat chi2		= `test'
	}
	ret mat p			= `p'
end

*==================================================*
**** computation of exclusion restriction tests ****
program define kinkyreg_estat_exclusion, rclass
	version 13.0
	syntax [varlist(num fv ts default=none)], [	noJOInt									///
												noINDividual							///
												CORRelation(numlist max=1 >=-1 <=1)		///
												EKurtosis(numlist max=1 >=1)			///
												XKurtosis(numlist max=1 >=1)			///
												Level(cilevel)							///
												noGRaph									///
												noTABle									///
												*]		// parsed separately: TWoway() PVALPlot()
	marksample touse

	if "`varlist'" == "" {
		if "`e(ivvars)'" == "" {
			di as err "varlist required"
			exit 100
		}
		else {
			markout `touse' `e(ivvars)'
			loc varlist			"`e(ivvars)'"
		}
	}
	foreach var in `varlist' {
		_ms_parse_parts `var'
		if "`r(type)'" != "variable" | "`r(op)'" != "" {
			loc var				: subinstr loc var "." "_", all
			loc var				: subinstr loc var "#" "_", all
		}
		loc varnames		"`varnames' `var'"
	}
	qui replace `touse' = 0 if !e(sample)
	sum `touse', mean
	if r(N) < e(N) {
		di as err "missing values encountered"
		exit 416
	}
	tempname b excl
	mat `b'				= e(b_kls)
	loc N_grid			= rowsof(`b')
	if "`correlation'" != "" {
		if `correlation' < e(grid_min) | `correlation' > e(grid_max) {
			di as err "correlation() invalid -- invalid number, outside of allowed range"
			exit 125
		}
		forv g = 1 / `N_grid' {
			if abs(`correlation' - (e(grid_min) + (`g' - 1) * e(grid_step))) <= e(grid_step) / 2 {
				loc g_corr			= `g'
				loc corr			= e(grid_min) + (`g' - 1) * e(grid_step)
			}
		}
	}

	kinkyreg_estat_init , `options'
	loc mopt			"`s(mopt)'"
	loc options			"`s(options)'"
	mata: kinkyreg_init_touse(`mopt', "`touse'")		// marker variable
	tsrevar `e(depvar)'
	mata: kinkyreg_init_depvar(`mopt', "`r(varlist)'")		// dependent variable
	mata: kinkyreg_init_indepvars(`mopt', 1, "`e(endovars)'")		// endogenous independent variables
	mata: kinkyreg_init_indepvars(`mopt', 2, "`e(exovars)'")		// exogenous independent and instrumental variables
	loc controls		"`e(controls)'"
	loc controls		: subinstr loc controls "_cons" "", w c(loc constant)
	if `: word count `controls'' {
		mata: kinkyreg_init_indepvars(`mopt', 3, "`controls'")		// partialled-out exogenous independent variables
	}
	if !`constant' {
		mata: kinkyreg_init_cons(`mopt', "off")			// constant term
	}
	mata: kinkyreg_init_ivvars(`mopt', "`varlist'")		// instrumental variables
	if `: word count `e(endovars)'' > 1 {
		mata: kinkyreg_init_corr(`mopt', st_matrix("e(endogeneity)"))
	}
	mata: kinkyreg_init_grid(`mopt', (`e(grid_min)', `e(grid_step)', `e(grid_max)'))
	if "`ekurtosis'" != "" {
		mata: kinkyreg_init_ekurt(`mopt', `ekurtosis')
	}
	if "`xkurtosis'" != "" {
		mata: kinkyreg_init_xkurt(`mopt', `xkurtosis')
	}
	loc K_excl			: word count `varlist'
	loc joint			= ("`joint'" == "")
	if !`joint' {
		if "`individual'" != "" {
			di as err "options nojoint and noindividual may not be combined"
			exit 184
		}
		if `K_excl' == 1 {
		    loc joint			= 1
		}
	}
	loc separate		= (`K_excl' > 1 & "`individual'" == "")
	if `separate' {
		foreach var in `varnames' {
			tempname mopt_`var'
			mata: `mopt_`var'' = kinkyreg_init_copy(`mopt')
		}
	}

	while `"`options'"' != "" {
		kinkyreg_estat_parse_options `varlist', `options'
		loc optname			"`s(varname)'"
		_ms_parse_parts `optname'
		if "`r(type)'" != "variable" | "`r(op)'" != "" {
			loc optname			: subinstr loc optname "." "_", all
			loc optname			: subinstr loc optname "#" "_", all
		}
		if `"`s(twopt)'"' != "" {
			loc twopt			`"`twopt' `s(twopt)'"'
		}
		if `"`s(twname)'"' != "" {
			loc twname 			`"`s(twname)'"'
		}
		if `"`s(addplot)'"' != "" {
			loc addplot			`"`s(addplot)'"'
		}
		if `"`s(pvalopt)'"' != "" {
			loc pvalopt_`optname' `"`pvalopt_`optname'' `s(pvalopt)'"'
		}
		loc options			`"`s(options)'"'
	}
	loc namestub		"`e(namestub)'"

	loc small			= (e(df_r) < .)
	if `joint' {
		mata: kinkyreg(`mopt')
		forv g = 1 / `N_grid' {
			mata: st_numscalar("r(rank)", kinkyreg_result_rank(`mopt', `g'))
			mata: st_numscalar("r(chi2)", kinkyreg_result_wald(`mopt', `g'))
			mata: st_matrix("r(corr)", kinkyreg_result_corr(`mopt', `g'))
			if `small' {
				mat `excl'			= (nullmat(`excl') \ (e(N) - r(rank)) / e(N) * r(chi2) / `K_excl')
			}
			else {
				mat `excl'			= (nullmat(`excl') \ r(chi2))
			}
		}
		if `K_excl' > 1 {
			loc testnames		"_all"
		}
		else {
			loc testnames		"`varnames'"
		}
	}
	if `separate' {
		loc k = 1
		foreach var in `varnames' {
			mata: kinkyreg_init_ivvars(`mopt_`var'', "`: word `k' of `varlist''")
			mata: kinkyreg(`mopt_`var'')
			tempname aux
			forv g = 1 / `N_grid' {
				mata: st_numscalar("r(rank)", kinkyreg_result_rank(`mopt_`var'', `g'))
				mata: st_numscalar("r(chi2)", kinkyreg_result_wald(`mopt_`var'', `g'))
				if `small' {
					mat `aux'			= (nullmat(`aux') \ (e(N) - r(rank)) / e(N) * r(chi2))
				}
				else {
					mat `aux'			= (nullmat(`aux') \ r(chi2))
				}
			}
			mat `excl'			= (nullmat(`excl'), `aux')
			loc ++k
		}
		loc testnames		"`testnames' `varnames'"
	}
	loc gid				: rown `b'
	mat coln `excl'		= `testnames'
	mat rown `excl'		= `gid'

	tempname p
	if `small' {
		if `joint' {
			mata: st_matrix("`p'", Ftail(`K_excl', `= e(N) - e(rank) - `K_excl'', st_matrix("`excl'")[., 1]))
		}
		else {
			mata: st_matrix("`p'", J(`N_grid', 0, .))
		}
		if `separate' {
			mata: st_matrix("`p'", (st_matrix("`p'"), Ftail(1, `= e(N) - e(rank) - 1', st_matrix("`excl'")[., 1+`joint'..`joint'+`K_excl'])))
		}
	}
	else {
		if `joint' {
			mata: st_matrix("`p'", chi2tail(`K_excl', st_matrix("`excl'")))
		}
		else {
			mata: st_matrix("`p'", J(`N_grid', 0, .))
		}
		if `separate' {
			mata: st_matrix("`p'", (st_matrix("`p'"), chi2tail(1, st_matrix("`excl'")[., 1+`joint'..`joint'+`K_excl'])))
		}
	}
	mat coln `p'		= `testnames'
	mat rown `p'		= `gid'

	loc siglevel		= (100 - `level') / 100
	tempvar gridrange
	qui gen `gridrange' = e(grid_min) + (_n - 1) * e(grid_step) in 1 / `N_grid'
	la var `gridrange' "postulated endogeneity of `e(klsvar)'"
	if `joint' {
		tempvar p_excl
		qui gen double `p_excl' = .
		if `K_excl' > 1 {
			la var `p_excl' "all instruments"
			loc tw_excl			"(line `p_excl' `gridrange', `pvalopt_')"
		}
		else {
			la var `p_excl' "`varlist'"
			loc tw_excl			"(line `p_excl' `gridrange', `pvalopt_' `pvalopt_`varnames'')"
		}
		mata: st_store((1, `N_grid'), "`p_excl'", st_matrix("`p'")[., 1])
	}
	tempname rho
	if `separate' {
		loc k = 1
		foreach var in `varnames' {
			tempvar p_excl_`var'
			qui gen double `p_excl_`var'' = .
			la var `p_excl_`var'' "`: word `k' of `varlist''"
			loc ++k
			mata: st_store((1, `N_grid'), "`p_excl_`var''", st_matrix("`p'")[., `=`k'-1+`joint''])
			loc tw_excl			"`tw_excl' line `p_excl_`var'' `gridrange', `pvalopt_`var'' ||"
			if "`individual'" == "" {
				tempvar aux aux_lb aux_ub aux_w aux_wb
				qui gen `aux' = `gridrange' if (`p_excl_`var'' >= `p_excl_`var''[_n-1] & (`p_excl_`var'' >= `p_excl_`var''[_n+1] | `p_excl_`var'' >= `p_excl_`var''[_n+2])) | (`p_excl_`var'' <= `p_excl_`var''[_n-1] & `p_excl_`var'' >= `p_excl_`var''[_n-2])
				qui gen double `aux_w' = 1 / (1 - `p_excl_`var'' + epsdouble()) if `aux' < .
				sum `aux' if `p_excl_`var'' >= `siglevel' & `p_excl_`var'' < . [aw = `aux_w'], mean
				if r(mean) < . {
					loc rho_e			= r(mean)
					qui gen `aux_lb' = `gridrange' if (`p_excl_`var'' <= `siglevel' & `p_excl_`var''[_n+1] >= `siglevel') | (`p_excl_`var'' >= `siglevel' & `p_excl_`var''[_n-1] <= `siglevel')
					qui gen double `aux_wb' = `siglevel' - `p_excl_`var''[_n-1] if `aux_lb' < . & `p_excl_`var'' >= `siglevel'
					qui replace `aux_wb' = `p_excl_`var''[_n+1] - `siglevel' if `aux_lb' < . & `p_excl_`var'' < `siglevel'
					sum `aux_lb' if `p_excl_`var''[_n+1] < . & `gridrange' < `rho_e' [aw = `aux_wb'], mean
					loc rho_lb			= r(mean)
					qui gen `aux_ub' = `gridrange' if (`p_excl_`var'' >= `siglevel' & `p_excl_`var''[_n+1] <= `siglevel') | (`p_excl_`var'' <= `siglevel' & `p_excl_`var''[_n-1] >= `siglevel')
					qui replace `aux_wb' = `siglevel' - `p_excl_`var''[_n+1] if `aux_ub' < . & `p_excl_`var'' >= `siglevel'
					qui replace `aux_wb' = `p_excl_`var''[_n-1] - `siglevel' if `aux_ub' < . & `p_excl_`var'' < `siglevel'
					sum `aux_ub' if `p_excl_`var''[_n-1] < . & `gridrange' > `rho_e' [aw = `aux_wb'], mean
					loc rho_ub			= r(mean)
					mat `rho'			= (nullmat(`rho') \ `rho_e', `rho_lb', `rho_ub')
				}
				else {
					mat `rho'			= (nullmat(`rho') \ ., ., .)
				}
			}
		}
	}
	else if "`individual'" == "" {
		tempname aux aux_lb aux_ub aux_w aux_wb
		qui gen `aux' = `gridrange' if (`p_excl' >= `p_excl'[_n-1] & (`p_excl' >= `p_excl'[_n+1] | `p_excl' >= `p_excl'[_n+2])) | (`p_excl' <= `p_excl'[_n-1] & `p_excl' >= `p_excl'[_n-2])
		qui gen double `aux_w' = 1 / (1 - `p_excl' + epsdouble()) if `aux' < .
		sum `aux' if `p_excl' >= `siglevel' & `p_excl' < . [aw = `aux_w'], mean
		if r(mean) < . {
			loc rho_e			= r(mean)
			qui gen `aux_lb' = `gridrange' if (`p_excl' < `siglevel' & `p_excl'[_n+1] >= `siglevel') | (`p_excl' >= `siglevel' & `p_excl'[_n-1] < `siglevel')
			qui gen double `aux_wb' = `siglevel' - `p_excl'[_n-1] if `aux_lb' < . & `p_excl' >= `siglevel'
			qui replace `aux_wb' = `p_excl'[_n+1] - `siglevel' if `aux_lb' < . & `p_excl' < `siglevel'
			sum `aux_lb' if `p_excl'[_n+1] < . & `gridrange' < `rho_e' [aw = `aux_wb'], mean
			loc rho_lb			= r(mean)
			qui gen `aux_ub' = `gridrange' if (`p_excl' >= `siglevel' & `p_excl'[_n+1] < `siglevel') | (`p_excl' < `siglevel' & `p_excl'[_n-1] >= `siglevel')
			qui replace `aux_wb' = `siglevel' - `p_excl'[_n+1] if `aux_ub' < . & `p_excl' >= `siglevel'
			qui replace `aux_wb' = `p_excl'[_n-1] - `siglevel' if `aux_ub' < . & `p_excl' < `siglevel'
			sum `aux_ub' if `p_excl'[_n-1] < . & `gridrange' > `rho_e' [aw = `aux_wb'], mean
			loc rho_ub			= r(mean)
			mat `rho'			= (`rho_e', `rho_lb', `rho_ub')
		}
		else {
			mat `rho'			= (., ., .)
		}
	}
	if "`individual'" == "" {
		loc colnames		`""Corr.:peak" "[`level'% Confid. Bounds]:lower bound" "[`level'% Confid. Bounds]:upper bound""'
		mat coln `rho'		= `colnames'
		mat rown `rho'		= `varlist'
	}
	if "`graph'" == "" {
		if `"`twname'"' == "" {
			loc twname			"name(`namestub'_excl, replace)"
		}
		tw `tw_excl' `addplot' ||, yti("p-value") `twopt' `twname'
	}

	if "`correlation'" != "" {
		di _n as txt "Kiviet test of exclusion restrictions"
		di "H0: exclusion restrictions are valid"
		di _n "Postulated endogeneity of `e(klsvar)' = " %5.4f `corr'
		loc j				= 1
		foreach var of loc varnames {
			loc df				= cond(`j' == 1, `K_excl', 1)
			if `small' {
				di as txt %12s "`var'" _col(30) "F(" as res `df' as txt ", " as res `= e(N) - e(rank) - `df'' as txt ")" _col(42) "=" as res %9.4f el(`excl', `g_corr', `j') _col(56) as txt "Prob > F" _col(68) "=" _col(73) as res %6.4f el(`p', `g_corr', `j')
			}
			else {
				di as txt %12s "`var'" _col(30) "chi2(" as res `df' as txt ")" _col(42) "=" as res %9.4f el(`excl', `g_corr', `j') _col(56) as txt "Prob > chi2" _col(68) "=" _col(73) as res %6.4f el(`p', `g_corr', `j')
			}
			loc ++j
		}
	}
	else if "`table'" == "" & "`individual'" == "" {
		di as txt _n "Endogeneity of `e(klsvar)' compatible with valid exclusion"
		matlist `rho', nob bor(row) lin(o) coleqonly showcoleq(r) noha
	}

	if "`individual'" == "" {
		ret mat corr		= `rho'
	}
	if `small' {
		ret mat F			= `excl'
	}
	else {
		ret mat chi2		= `excl'
	}
	ret mat p			= `p'
end

*==================================================*
**** computation of heteroskedasticity tests ****
program define kinkyreg_estat_hettest, rclass
	version 13.0
	syntax [anything(id="varlist")], [	XB										///
										RHS										///
										ENDOvars								/// undocumented
										EXOvars									/// undocumented
										CONTrols								/// undocumented
										IVvars									/// undocumented
										CORRelation(numlist max=1 >=-1 <=1)		///
										MINP									///
										noGRaph									///
										*]										// parsed separately: TWoway() PVALPlot()

	gettoken varlist anything : anything, p(",[") m(paren) bind
	if "`paren'" == "" {
	    if `"`varlist'"' != "" {
		    error 198
		}
		else if `"`endovars'`exovars'`controls'`ivvars'"' == "" {
		    loc xb				"xb"
		}
		else {
			loc paren			"("
		}
	}
	loc l = 1
	while "`paren'" == "(" {
		gettoken varlist varlistopt : varlist, p(",")
		if "`varlistopt'" == "" {
			loc varlistopt		","
		}
		kinkyreg_estat_parse_varlist `varlist' `varlistopt' `rhs' `endovars' `exovars' `controls' `ivvars'
		loc varlist_`l'		"`s(varlist)'"
		loc endovars_`l'	= ("`s(endovars)'" != "")
		loc xb_`l'			= 0
		loc varsets			"`varsets' `l'"
		gettoken varlist anything : anything, p(" ,[") m(paren) bind
		if "`paren'" == "" & `"`varlist'"' != "" {
			error 198
		}
		loc ++l
	}
	if "`xb'" != "" {
		loc endovars_`l'	= 0
		loc xb_`l'			= 1
		loc varsets			"`varsets' `l'"
	}
	while `"`options'"' != "" {
		kinkyreg_estat_parse_options `varsets' `xb', `options'
		if "`s(varname)'" == "xb" {
			loc listnum			= `l'
		}
		else {
			loc listnum			"`s(varname)'"
		}
		if `"`s(twopt)'"' != "" {
			loc twopt			`"`twopt' `s(twopt)'"'
		}
		if `"`s(twname)'"' != "" {
			loc twname 			`"`s(twname)'"'
		}
		if `"`s(addplot)'"' != "" {
			loc addplot			`"`s(addplot)'"'
		}
		if `"`s(pvalopt)'"' != "" {
			loc pvalopt_`listnum' `"`pvalopt_`listnum'' `s(pvalopt)'"'
		}
		loc options			`"`s(options)'"'
	}
	loc namestub		"`e(namestub)'"

	tempvar depvar
	qui gen double `depvar' = .
	foreach var in `e(endovars)' `e(exovars)' {
		_ms_parse_parts `var'
		if "`r(type)'" != "variable" | "`r(op)'" != "" {
			fvrevar `var'
			loc var				"`r(varlist)'"
			qui replace `var' = .
			loc regvars		"`regvars' `var'"
		}
		else {
			tempvar `var'
			qui gen double ``var'' = .
			loc regvars		"`regvars' ``var''"
		}
	}
	tempvar touse
	qui gen byte `touse' = e(sample)
	loc controls		"`e(controls)'"
	tempname b
	mat `b'				= e(b_kls)
	loc N_grid			= rowsof(`b')
	loc K				= colsof(`b')
	mat `b'				= `b'[., 1..`=`K'-`: word count `controls''']
	loc controls		: subinstr loc controls "_cons" "", w c(loc hascons)
	mata: kinkyreg_partial("`e(depvar)' `e(endovars)' `e(exovars)'", "`controls'", "`depvar' `regvars'", "`touse'", `hascons')
	if "`correlation'" != "" {
		if `correlation' < e(grid_min) | `correlation' > e(grid_max) {
			di as err "correlation() invalid -- invalid number, outside of allowed range"
			exit 125
		}
		forv g = 1 / `N_grid' {
			if abs(`correlation' - (e(grid_min) + (`g' - 1) * e(grid_step))) <= e(grid_step) / 2 {
				loc g_corr			= `g'
				loc corr			= e(grid_min) + (`g' - 1) * e(grid_step)
			}
		}
	}
	else {
		loc g_corr			= .
	}
	loc small			= (e(df_r) < .)
	if "`xb'" != "" {
		tempname xbgrid
		forv g = 1 / `N_grid' {
			tempvar `xbgrid'`g'
		}
		predict double `xbgrid'* if `touse', xbgrid
	}
	foreach l of num `varsets' {
		if `endovars_`l'' {
			loc i				= 0
			foreach var in `e(endovars)' {
				loc ++i
				tempname xgrid_`i'
				forv g = 1 / `N_grid' {
					tempvar `xgrid_`i''_`g'
				}
				predict double `xgrid_`i''_* if `touse', xgrid endovar(`var')
			}
			loc endovars		"`e(endovars)'"
			continue, br
		}
	}
	forv g = 1 / `N_grid' {
		tempname bg
		tempvar fit res2_`g'
		mat `bg'			= `b'[`g'..`g', .]
		mat coln `bg'		= `regvars'
		qui mat sco double `fit' = `bg' if `touse'
		qui gen double `res2_`g'' = (`depvar' - `fit')^2 if `touse'
	}
	tempname kinkyreg_e hett p
	est sto `kinkyreg_e'
	tempname hett p
	foreach l of num `varsets' {
		tempname aux1 aux2
		forv g = 1 / `N_grid' {
			if `xb_`l'' {
				loc regvars			"`xbgrid'`g'"
			}
			else if `endovars_`l'' {
				loc i				= 0
				foreach var in `endovars' {
					loc ++i
					loc regvars			: subinstr loc varlist_`l' "`var'" "`xgrid_`i''_`g'", w
				}
			}
			else {
				loc regvars			"`varlist_`l''"
			}
			cap reg `res2_`g'' `regvars' if `touse'
			if _rc {
				qui est res `kinkyreg_e'
				est drop `kinkyreg_e'
				qui reg `res2_`g'' `regvars' if `touse'
			}
			if "`minp'" == "" {
				qui test `regvars'
				if `small' {
					mat `aux1'			= (nullmat(`aux1') \ r(F))
					mat `aux2'			= (nullmat(`aux2') \ r(p))
				}
				else {
					loc chi2			= e(N) / e(df_r) * r(df) * r(F)
					mat `aux1'			= (nullmat(`aux1') \ `chi2')
					mat `aux2'			= (nullmat(`aux2') \ chi2tail(r(df), `chi2'))
				}
			}
			else {
				loc pmin			= .
				foreach var in `regvars' {
					qui test `var'
					if r(p) < `pmin' {
						loc Fmin			= r(F)
						loc pmin			= r(p)
					}
				}
				if `small' {
					mat `aux1'			= (nullmat(`aux1') \ `Fmin')
					mat `aux2'			= (nullmat(`aux2') \ `pmin')
				}
				else {
					loc chi2			= e(N) / e(df_r) * `Fmin'
					mat `aux1'			= (nullmat(`aux1') \ `chi2')
					mat `aux2'			= (nullmat(`aux2') \ chi2tail(1, `chi2'))
				}
			}
			if `g' == `g_corr' {
				loc df_r_`l'		= r(df_r)
				loc df_`l'			= r(df)
			}
		}
		mat `hett'			= (nullmat(`hett'), `aux1')
		mat `p'				= (nullmat(`p'), `aux2')
	}
	qui est res `kinkyreg_e'
	est drop `kinkyreg_e'
	loc gid				: rown `b'
	mat coln `hett'		= `varsets'
	mat rown `hett'		= `gid'
	mat coln `p'		= `varsets'
	mat rown `p'		= `gid'

	if "`graph'" == "" {
		tempvar gridrange
		qui gen `gridrange' = e(grid_min) + (_n - 1) * e(grid_step) in 1 / `N_grid'
		la var `gridrange' "postulated endogeneity of `e(klsvar)'"
		loc j				= 0
		foreach l of num `varsets' {
			tempname p_hett`l'
			qui gen double `p_hett`l'' = .
			if `xb_`l'' {
				la var `p_hett`l'' "xb"
			}
			else {
				la var `p_hett`l'' "varlist `l'"
			}
			loc ++j
			mata: st_store((1, `N_grid'), "`p_hett`l''", st_matrix("`p'")[., `j'])
			loc tw_hett			"`tw_hett' line `p_hett`l'' `gridrange', `pvalopt_`l'' ||"
		}
		if `"`twname'"' == "" {
			loc twname			"name(`namestub'_hett, replace)"
		}
		if "`minp'" == "" {
			tw `tw_hett' `addplot' ||, yti("p-value") `twopt' `twname'
		}
		else {
			tw `tw_hett' `addplot' ||, yti("minimum p-value") `twopt' `twname'
		}
	}

	if "`correlation'" != "" {
		if "`minp'" == "" {
			di _n as txt "Breusch-Pagan test for heteroskedasticity"
		}
		else {
			di _n as txt "Breusch-Pagan test for heteroskedasticity (minimum individual p-value)"
		}
		di "H0: constant variance"
		di _n "Postulated endogeneity of `e(klsvar)' = " %5.4f `corr'
		loc j				= 1
		foreach l of num `varsets' {
			if `xb_`l'' {
				loc listname		"xb"
			}
			else {
				loc listname		"varlist `l'"
			}
			if `small' {
				di as txt %12s "`listname'" _col(30) "F(" as res `df_`l'' as txt ", " as res `df_r_`l'' as txt ")" _col(42) "=" as res %9.4f el(`hett', `g_corr', `j') _col(56) as txt "Prob > F" _col(68) "=" _col(73) as res %6.4f el(`p', `g_corr', `j')
			}
			else {
				di as txt %12s "`listname'" _col(30) "chi2(" as res `df_`l'' as txt ")" _col(42) "=" as res %9.4f el(`hett', `g_corr', `j') _col(56) as txt "Prob > chi2" _col(68) "=" _col(73) as res %6.4f el(`p', `g_corr', `j')
			}
			loc ++j
		}
	}

	if `small' {
		ret mat F			= `hett'
	}
	else {
		ret mat chi2		= `hett'
	}
	ret mat p			= `p'
end

*==================================================*
**** computation of Ramsey's RESET / omitted-variables tests ****
program define kinkyreg_estat_reset, rclass
	version 13.0
	syntax , [	XB										///
				RHS										///
				Order(numlist int >=2)					///
				CORRelation(numlist max=1 >=-1 <=1)		///
				EKurtosis(numlist max=1 >=1)			///
				XKurtosis(numlist max=1 >=1)			///
				noGRaph									///
				*]										// parsed separately: TWoway() PVALPlot()

	if "`xb'" != "" & "`rhs'" != "" {
		di as err "options xb and rhs may not be combined"
		exit 184
	}
	if "`order'" == "" {
		loc order			"2 3 4"
		loc maxorder		= 4
	}
	else {
		loc orders			: list sort order
		loc maxorder		: word `: word count `orders'' of `orders'
	}
	while `"`options'"' != "" {
		kinkyreg_estat_parse_options `order', `options'
		if `"`s(twopt)'"' != "" {
			loc twopt			`"`twopt' `s(twopt)'"'
		}
		if `"`s(twname)'"' != "" {
			loc twname 			`"`s(twname)'"'
		}
		if `"`s(addplot)'"' != "" {
			loc addplot			`"`s(addplot)'"'
		}
		if `"`s(pvalopt)'"' != "" {
			loc pvalopt_`s(varname)' `"`pvalopt_`s(varname)'' `s(pvalopt)'"'
		}
		loc options			`"`s(options)'"'
	}
	loc namestub		"`e(namestub)'"

	tempvar touse depvar
	qui gen byte `touse' = e(sample)
	qui gen double `depvar' = .
	foreach var in `e(endovars)' {
		_ms_parse_parts `var'
		if "`r(type)'" != "variable" | "`r(op)'" != "" {
			fvrevar `var'
			loc var				"`r(varlist)'"
			qui replace `var' = .
			loc endovars	"`endovars' `var'"
		}
		else {
			tempvar `var'
			qui gen double ``var'' = .
			loc endovars	"`endovars' ``var''"
		}
	}
	foreach var in `e(exovars)' {
		_ms_parse_parts `var'
		if "`r(type)'" != "variable" | "`r(op)'" != "" {
			fvrevar `var'
			loc var				"`r(varlist)'"
			qui replace `var' = .
			loc exovars		"`exovars' `var'"
		}
		else {
			tempvar `var'
			qui gen double ``var'' = .
			loc exovars		"`exovars' ``var''"
		}
	}
	loc controls		"`e(controls)'"
	tempname b
	mat `b'				= e(b_kls)
	loc K				= colsof(`b')
	mat `b'				= `b'[., 1..`=`K'-`: word count `controls''']
	loc controls		: subinstr loc controls "_cons" "", w c(loc hascons)
	mata: kinkyreg_partial("`e(depvar)' `e(endovars)' `e(exovars)'", "`controls'", "`depvar' `endovars' `exovars'", "`touse'", `hascons')
	tempname mopt
	mata: `mopt' = kinkyreg_init()
	mata: kinkyreg_init_touse(`mopt', "`touse'")
	mata: kinkyreg_init_depvar(`mopt', "`depvar'")
	mata: kinkyreg_init_indepvars(`mopt', 1, "`endovars'")
	mata: kinkyreg_init_indepvars(`mopt', 2, "`exovars'")
	mata: kinkyreg_init_cons(`mopt', "off")
	if "`ekurtosis'" != "" {
		mata: kinkyreg_init_ekurt(`mopt', `ekurtosis')
	}
	if "`xkurtosis'" != "" {
		mata: kinkyreg_init_xkurt(`mopt', `xkurtosis')
	}
	if `: word count `e(endovars)'' > 1 {
		mata: kinkyreg_init_corr(`mopt', st_matrix("e(endogeneity)"))
	}
	mata: kinkyreg_init_grid(`mopt', (`e(grid_min)', `e(grid_step)', `e(grid_max)'))

	loc N_grid			= rowsof(`b')
	if "`correlation'" != "" {
		if `correlation' < e(grid_min) | `correlation' > e(grid_max) {
			di as err "correlation() invalid -- invalid number, outside of allowed range"
			exit 125
		}
		forv g = 1 / `N_grid' {
			if abs(`correlation' - (e(grid_min) + (`g' - 1) * e(grid_step))) <= e(grid_step) / 2 {
				loc g_corr			= `g'
				loc corr			= e(grid_min) + (`g' - 1) * e(grid_step)
			}
		}
	}
	else {
		loc g_corr			= .
	}
	if "`rhs'" != "" {
		loc i				= 0
		foreach var in `e(endovars)' {
			loc ++i
			tempname xgrid_`i'
			forv g = 1 / `N_grid' {
				tempvar `xgrid_`i''_`g'
			}
			predict double `xgrid_`i''_* if `touse', xgrid endovar(`var')
		}
	}
	else {
		tempname xbgrid
		forv g = 1 / `N_grid' {
			tempvar `xbgrid'`g'
		}
		predict double `xbgrid'* if `touse', xbgrid
	}
	foreach o of num `order' {
		tempname mopt`o'
		mata: `mopt`o'' = kinkyreg_init_copy(`mopt')
	}
	mata: mata drop `mopt'
    if "`rhs'" != "" {
		forv o = 2 / `maxorder' {
			foreach var of var `exovars' {
				tempvar `var'_`o'
				qui gen double `var'_`o' = `var'^`o'
				loc exovars`o'		"`exovars`o'' `var'_`o'"
				mata: kinkyreg_partial("`exovars`o''", "`controls'", "`exovars`o''", "`touse'", `hascons')
			}
		}
	}
	forv g = 1 / `N_grid' {
		loc powervars1		""
		forv o = 2 / `maxorder' {
		    if "`rhs'" != "" {
				loc xgrid`o'		""
				loc i				= 0
				foreach var in `e(endovars)' {
					loc ++i
					tempvar xgrid_`i'_`o'
					qui gen double `xgrid_`i'_`o'' = `xgrid_`i''_`g'^`o'
					mata: kinkyreg_partial("`xgrid_`i'_`o''", "`controls'", "`xgrid_`i'_`o''", "`touse'", `hascons')
					loc xgrid`o'		"`xgrid`o'' `xgrid_`i'_`o''"
				}
				loc powervars`o'	"`powervars`=`o'-1'' `xgrid`o'' `exovars`o''"
			}
			else {
				tempvar fit_`o'
				qui gen double `fit_`o'' = `xbgrid'`g'^`o'
				mata: kinkyreg_partial("`fit_`o''", "`controls'", "`fit_`o''", "`touse'", `hascons')
				loc powervars`o'	"`powervars`=`o'-1'' `fit_`o''"
			}
		}
		foreach o of num `order' {
			mata: kinkyreg_init_indepvars(`mopt`o'', 4, "`powervars`o''", `g')
		}
	}

	loc small			= (e(df_r) < .)
	tempname reset p
	foreach o of num `order' {
		mata: kinkyreg(`mopt`o'')
		tempname aux1 aux2
		forv g = 1 / `N_grid' {
			mata: st_numscalar("r(rank)", kinkyreg_result_rank(`mopt`o'', `g'))
			mata: st_numscalar("r(chi2)", kinkyreg_result_wald(`mopt`o'', `g'))
			loc df				= r(rank) - e(rank) + `: word count `e(controls)''
			if `g' == `g_corr' {
				loc df_r_`o'		= e(N) - r(rank)
				loc df_`o'			= `df'
			}
			if `small' {
				loc F				= (e(N) - r(rank)) / e(N) * r(chi2) / `df'
				mat `aux1'			= (nullmat(`aux1') \ `F')
				mat `aux2'			= (nullmat(`aux2') \ Ftail(`df', e(N) - r(rank), `F'))
			}
			else {
				mat `aux1'			= (nullmat(`aux1') \ r(chi2))
				mat `aux2'			= (nullmat(`aux2') \ chi2tail(`df', r(chi2)))
			}
		}
		mat `reset'			= (nullmat(`reset'), `aux1')
		mat `p'				= (nullmat(`p'), `aux2')
	}
	loc gid				: rown `b'
	mat coln `reset'	= `order'
	mat rown `reset'	= `gid'
	mat coln `p'		= `order'
	mat rown `p'		= `gid'

	if "`graph'" == "" {
		tempvar gridrange
		qui gen `gridrange' = e(grid_min) + (_n - 1) * e(grid_step) in 1 / `N_grid'
		la var `gridrange' "postulated endogeneity of `e(klsvar)'"
		loc j				= 0
		foreach o of num `order' {
			tempname p_reset`o'
			qui gen double `p_reset`o'' = .
			la var `p_reset`o'' "order `o'"
			loc ++j
			mata: st_store((1, `N_grid'), "`p_reset`o''", st_matrix("`p'")[., `j'])
			loc tw_reset		"`tw_reset' line `p_reset`o'' `gridrange', `pvalopt_`o'' ||"
		}
		if `"`twname'"' == "" {
			loc twname			"name(`namestub'_reset, replace)"
		}
		tw `tw_reset' `addplot' ||, yti("p-value") `twopt' `twname'
	}

	if "`correlation'" != "" {
		di _n as txt "Ramsey RESET test"
		di "H0: model correctly specified"
		di _n "Postulated endogeneity of `e(klsvar)' = " %5.4f `corr'
		loc j				= 1
		foreach o of num `order' {
			if `small' {
				di as txt %12s "order `o'" _col(30) "F(" as res `df_`o'' as txt ", " as res `df_r_`o'' as txt ")" _col(42) "=" as res %9.4f el(`reset', `g_corr', `j') _col(56) as txt "Prob > F" _col(68) "=" _col(73) as res %6.4f el(`p', `g_corr', `j')
			}
			else {
				di as txt %12s "order `o'" _col(30) "chi2(" as res `df_`o'' as txt ")" _col(42) "=" as res %9.4f el(`reset', `g_corr', `j') _col(56) as txt "Prob > chi2" _col(68) "=" _col(73) as res %6.4f el(`p', `g_corr', `j')
			}
			loc ++j
		}
	}

	if `small' {
		ret mat F			= `reset'
	}
	else {
		ret mat chi2		= `reset'
	}
	ret mat p			= `p'
end

*==================================================*
**** computation of Durbin's alternative serial correlation tests ****
program define kinkyreg_estat_durbinalt, rclass
	version 13.0
	syntax , [	Order(numlist int >=1)					///
				CORRelation(numlist max=1 >=-1 <=1)		///
				EKurtosis(numlist max=1 >=1)			///
				XKurtosis(numlist max=1 >=1)			///
				noGRaph									///
				*]										// parsed separately: TWoway() PVALPlot()
	_ts

	if "`order'" == "" {
		loc order			= 1
		loc maxorder		= 1
	}
	else {
		loc orders			: list sort order
		loc maxorder		: word `: word count `orders'' of `orders'
	}
	while `"`options'"' != "" {
		kinkyreg_estat_parse_options `order', `options'
		if `"`s(twopt)'"' != "" {
			loc twopt			`"`twopt' `s(twopt)'"'
		}
		if `"`s(twname)'"' != "" {
			loc twname 			`"`s(twname)'"'
		}
		if `"`s(addplot)'"' != "" {
			loc addplot			`"`s(addplot)'"'
		}
		if `"`s(pvalopt)'"' != "" {
			loc pvalopt_`s(varname)' `"`pvalopt_`s(varname)'' `s(pvalopt)'"'
		}
		loc options			`"`s(options)'"'
	}
	loc namestub		"`e(namestub)'"

	tempvar touse depvar
	qui gen byte `touse' = e(sample)
	qui gen double `depvar' = .
	foreach var of var `e(endovars)' {
		tempvar `var'
		qui gen double ``var'' = .
		loc endovars	"`endovars' ``var''"
	}
	foreach var of var `e(exovars)' {
		tempvar `var'
		qui gen double ``var'' = .
		loc exovars		"`exovars' ``var''"
	}
	loc controls		"`e(controls)'"
	tempname b
	mat `b'				= e(b_kls)
	loc K				= colsof(`b')
	mat `b'				= `b'[., 1..`=`K'-`: word count `controls''']
	loc controls		: subinstr loc controls "_cons" "", w c(loc hascons)
	mata: kinkyreg_partial("`e(depvar)' `e(endovars)' `e(exovars)'", "`controls'", "`depvar' `endovars' `exovars'", "`touse'", `hascons')
	tempname mopt
	mata: `mopt' = kinkyreg_init()
	mata: kinkyreg_init_touse(`mopt', "`touse'")
	mata: kinkyreg_init_depvar(`mopt', "`depvar'")
	mata: kinkyreg_init_indepvars(`mopt', 1, "`endovars'")
	mata: kinkyreg_init_indepvars(`mopt', 2, "`exovars'")
	mata: kinkyreg_init_cons(`mopt', "off")
	if "`ekurtosis'" != "" {
		mata: kinkyreg_init_ekurt(`mopt', `ekurtosis')
	}
	if "`xkurtosis'" != "" {
		mata: kinkyreg_init_xkurt(`mopt', `xkurtosis')
	}
	if `: word count `e(endovars)'' > 1 {
		mata: kinkyreg_init_corr(`mopt', st_matrix("e(endogeneity)"))
	}
	mata: kinkyreg_init_grid(`mopt', (`e(grid_min)', `e(grid_step)', `e(grid_max)'))

	loc N_grid			= rowsof(`b')
	if "`correlation'" != "" {
		if `correlation' < e(grid_min) | `correlation' > e(grid_max) {
			di as err "correlation() invalid -- invalid number, outside of allowed range"
			exit 125
		}
		forv g = 1 / `N_grid' {
			if abs(`correlation' - (e(grid_min) + (`g' - 1) * e(grid_step))) <= e(grid_step) / 2 {
				loc g_corr			= `g'
				loc corr			= e(grid_min) + (`g' - 1) * e(grid_step)
			}
		}
	}
	else {
		loc g_corr			= .
	}
	tempname resgrid
	forv g = 1 / `N_grid' {
		tempvar `resgrid'`g'
	}
	predict double `resgrid'* if `touse', resgrid
	foreach o of num `order' {
		tempname mopt`o'
		mata: `mopt`o'' = kinkyreg_init_copy(`mopt')
	}
	mata: mata drop `mopt'
	forv g = 1 / `N_grid' {
		loc resvars0		""
		forv o = 1 / `maxorder' {
			tempvar resgrid_`o'
			qui gen `resgrid_`o'' = L`o'.`resgrid'`g'
			qui replace `resgrid_`o'' = 0 if `resgrid_`o'' == . & `touse'
		    mata: kinkyreg_partial("`resgrid_`o''", "`controls'", "`resgrid_`o''", "`touse'", `hascons')
			loc resvars`o'		"`resvars`=`o'-1'' `resgrid_`o''"
		}
		foreach o of num `order' {
			mata: kinkyreg_init_indepvars(`mopt`o'', 4, "`resvars`o''", `g')
		}
	}

	loc small			= (e(df_r) < .)
	tempname durbin p
	foreach o of num `order' {
		mata: kinkyreg(`mopt`o'')
		tempname aux1 aux2
		forv g = 1 / `N_grid' {
			mata: st_numscalar("r(rank)", kinkyreg_result_rank(`mopt`o'', `g'))
			mata: st_numscalar("r(chi2)", kinkyreg_result_wald(`mopt`o'', `g'))
			loc df				= r(rank) - e(rank) + `: word count `e(controls)''
			if `g' == `g_corr' {
				loc df_r_`o'		= e(N) - r(rank)
				loc df_`o'			= `df'
			}
			if `small' {
				loc F				= (e(N) - r(rank)) / e(N) * r(chi2) / `df'
				mat `aux1'			= (nullmat(`aux1') \ `F')
				mat `aux2'			= (nullmat(`aux2') \ Ftail(`df', e(N) - r(rank), `F'))
			}
			else {
				mat `aux1'			= (nullmat(`aux1') \ r(chi2))
				mat `aux2'			= (nullmat(`aux2') \ chi2tail(`df', r(chi2)))
			}
		}
		mat `durbin'		= (nullmat(`durbin'), `aux1')
		mat `p'				= (nullmat(`p'), `aux2')
	}
	loc gid				: rown `b'
	mat coln `durbin'	= `order'
	mat rown `durbin'	= `gid'
	mat coln `p'		= `order'
	mat rown `p'		= `gid'

	if "`graph'" == "" {
		tempvar gridrange
		qui gen `gridrange' = e(grid_min) + (_n - 1) * e(grid_step) in 1 / `N_grid'
		la var `gridrange' "postulated endogeneity of `e(klsvar)'"
		loc j				= 0
		foreach o of num `order' {
			tempname p_durbin`o'
			qui gen double `p_durbin`o'' = .
			la var `p_durbin`o'' "order `o'"
			loc ++j
			mata: st_store((1, `N_grid'), "`p_durbin`o''", st_matrix("`p'")[., `j'])
			loc tw_durbin		"`tw_durbin' line `p_durbin`o'' `gridrange', `pvalopt_`o'' ||"
		}
		if `"`twname'"' == "" {
			loc twname			"name(`namestub'_dur, replace)"
		}
		tw `tw_durbin' `addplot' ||, yti("p-value") `twopt' `twname'
	}

	if "`correlation'" != "" {
		di _n as txt "Durbin's alternative serial correlation test"
		di "H0: no serial error correlation"
		di _n "Postulated endogeneity of `e(klsvar)' = " %5.4f `corr'
		loc j				= 1
		foreach o of num `order' {
			if `small' {
				di as txt %12s "order `o'" _col(30) "F(" as res `df_`o'' as txt ", " as res `df_r_`o'' as txt ")" _col(42) "=" as res %9.4f el(`durbin', `g_corr', `j') _col(56) as txt "Prob > F" _col(68) "=" _col(73) as res %6.4f el(`p', `g_corr', `j')
			}
			else {
				di as txt %12s "order `o'" _col(30) "chi2(" as res `df_`o'' as txt ")" _col(42) "=" as res %9.4f el(`durbin', `g_corr', `j') _col(56) as txt "Prob > chi2" _col(68) "=" _col(73) as res %6.4f el(`p', `g_corr', `j')
			}
			loc ++j
		}
	}

	if `small' {
		ret mat F			= `durbin'
	}
	else {
		ret mat chi2		= `durbin'
	}
	ret mat p			= `p'
end

*==================================================*
**** syntax parsing of the optimization options ****
program define kinkyreg_estat_init, sclass
	version 13.0
	sret clear
	syntax [, *]

	loc mopt			"kinkyreg_estat_kls"
	mata: `mopt' = kinkyreg_init()

	sret loc mopt		"`mopt'"
	sret loc options	`"`options'"'
end

*==================================================*
**** syntax parsing of the variable list ****
program define kinkyreg_estat_parse_varlist, sclass
	version 13.0
	sret clear
	syntax [varlist(num ts fv default=none)] [, RHS ENDOvars EXOvars CONTrols IVvars]		/// undocumented

	if "`rhs'" != "" {
		loc varlist			"`e(endovars)' `varlist'"
		loc varlist			"`e(exovars)' `varlist'"
	}
	else {
		if "`endovars'" != "" {
			loc varlist			"`e(endovars)' `varlist'"
		}
		if "`exovars'" != "" {
			loc varlist			"`e(exovars)' `varlist'"
		}
	}
	if "`controls'" != "" {
		loc controls		"`e(controls)'"
		loc controls		: subinstr loc controls "_cons" "", w
		loc varlist			"`varlist' `controls'"
	}
	if "`ivvars'" != "" {
		loc varlist			"`varlist' `e(ivvars)'"
	}
	if "`varlist'" == "" {
		di as err "varlist required"
		exit 100
	}

	sret loc endovars	"`rhs'`endovars'"
	sret loc varlist	"`varlist'"
end

*==================================================*
**** syntax parsing of graph options ****
program define kinkyreg_estat_parse_options, sclass
	version 13.0
	sret clear
	syntax [anything], [TEST TWoway(string asis) PVALPlot(string asis) *]

	if `"`twoway'"' != "" {
		kinkyreg_estat_parse_twoway `twoway'
		if `"`pvalplot'"' != "" {
			loc options			`"pvalplot(`pvalplot') `options'"'
		}
	}
	else {
		if `"`pvalplot'"' != "" {
			kinkyreg_estat_parse_pvalplot `pvalplot'
			loc pvalvar			`"`s(varname)'"'
			if !`: list pvalvar in anything' {
				di as err "`pvalvar' not found"
				exit 198
			}
		}
		else if `"`options'"' != "" {
			if "`test'" == "" {
				di as err `"`options' invalid"'
				exit 198
			}
			loc test			`"`options'"'
			loc options			""
		}
	}

	if "`test'" != "" {
		sret loc test		`"`test'"'
	}
	sret loc options	`"`options'"'
end

*==================================================*
**** syntax parsing of twoway graph options ****
program define kinkyreg_estat_parse_twoway, sclass
	version 13.0
	syntax , [NAME(passthru) ADDPLOT(string asis) *]

	sret loc twname		`"`name'"'
	sret loc addplot	`"`addplot'"'
	sret loc twopt		`"`options'"'
end

*==================================================*
**** syntax parsing of graph options for p-value plots ****
program define kinkyreg_estat_parse_pvalplot, sclass
	version 13.0
	syntax [anything(id="plot identifier")], [*]

	sret loc varname	`"`anything'"'
	sret loc pvalopt	`"`options'"'
end
