*! nehurdle v1.1.0
*! 29 June 2018
*! Alfonso Sanchez-Penalver
*! Version history at the bottom

/*******************************************************************************
*	Program to estimate tobit, truncated hurdle, and type II tobit models via  *
*	maximum likelihood for data with corner solutions at 0.					   *
********************************************************************************/

capture program drop nehurdle
program define nehurdle, byable(onecall) properties(svyb svyj svyr)
	version 11
	if replay() {
		if "`e(cmd)'" != "nehurdle"	{
			di as error "Your previous estimation command was not {bf: nehurdle}"
			exit 301
		}
		if _by() error 190
		Replay `0'
	}
	else {
		global neh_cmdline "`0'"
		syntax varlist(min=1 numeric fv) [if] [in] [fweight pweight iweight]	///
		[,																		///
			{TRunc | TObit | HEckman} *											///
		]
		if _by() local by "by `_byvars' `byrc0':"
		if "`tobit'" != ""														///
			`by' nehurdle_est_tobit `0'
		else if "`heckman'" != ""												///
			`by' nehurdle_est_heckman `0'
		else																	///
			`by' nehurdle_est_trunc `0'
	}
end

/*------------------------------------------------------------------------------

	DISPLAY PROGRAMS

------------------------------------------------------------------------------*/

// HEADER
capture program drop nehurdle_display_header
program define nehurdle_display_header
	if "`e(chi2)'" == "." 														///
		local ov_txt "{help j_robustsingular##|_new:Wald chi2(`e(df_m)')}"
	else 																		///
		local ov_txt "Wald chi2({bf:`e(df_m)'})"
	if ("`e(vce)'" != "oim" & "`e(vce)'" != "opg") | "`e(cmd_opt)'" ==			///
		"twopart" local lltext "Log Pseudolikelihood"
	else local lltext "Log Likelihood"
	
	// Displaying
	di as text "`e(title)'" _col(49) as text "Number of Obs." _col(67) "= "		///
		_col(69) as result %9.0g e(N)
	di as text _col(49) as text "Censored Obs." _col(67) "= " _col(69) as		///
		result %9.0g e(N_c)
	di as text _col(49) as text "Uncensored Obs." _col(67) "= " _col(69) as		///
		result %9.0g (e(N) - e(N_c))
	di ""
	di _col(49) as text "`ov_txt'" _col(67) "= " _col(69) as result %9.2f		///
		e(chi2)
	di _col(49) as txt "Prob > chi2" _col(67) "= " _col(69) as result %9.4f		///
		e(p)
	di as txt "`lltext'" _col(22) "= " as result %12.3f e(ll) _col(49) as txt	///
		"Pseudo R-squared" _col(67) "= " _col(69) as result %9.4f e(r2)
	di ""
end

// REPLAY
capture program drop Replay
program define Replay
	syntax [, Level(cilevel) noHEader COEFLegend]
	
	di ""
	if "`header'" != "noheader"													///
		nehurdle_display_header
	ml display, level(`level') noheader `coeflegend'
end

/*------------------------------------------------------------------------------

	PARSING

------------------------------------------------------------------------------*/
capture program drop parse_select_opts
program define parse_select_opts, sclass
	syntax [varlist(numeric fv default=none)]									///
	[	,																		///
		noCONstant																///
		HET(varlist numeric fv)													///
		OFFset(passthru)														///
		EXPosure(passthru)														///
	]
	
	sreturn local vars `varlist'
	sreturn local constant `constant'
	sreturn local het `het'
	sreturn local off `offset'
	sreturn local exp `exposure'
end

capture program drop parse_het_opts
program define parse_het_opts, sclass
	syntax varlist(numeric fv)													///
	[,																			///
		noCONstant																///
	]
	
	sreturn local vars `varlist'
	sreturn local constant `constant'
end

/*------------------------------------------------------------------------------

	ESTIMATORS

------------------------------------------------------------------------------*/

// TRUNCATED HURDLE
capture program drop nehurdle_est_trunc
program define nehurdle_est_trunc, eclass byable(recall) sortpreserve
	syntax varlist(numeric fv) [if] [in] [fweight pweight iweight]				///
	[,																			///
		TRunc																	///
		SELect(string)															///
		HET(string)																///
		noHEader																///
		EXPONential																///
		COEFLegend																///
		noLOg																	///
		noCONStant																///
		vce(passthru)															///
		Level(passthru)															///
		OFFset(passthru)														///
		EXPosure(passthru) *													///
	]
	
	// Temporary variables and names
	tempvar y1 dy res res2
	tempname b b1 coeff varcov
	
	// Marking the sample
	marksample touse
	quiet count if `touse'
	if `r(N)' == 0 error 2000

	// Checking syntax of ml options
	mlopts mlopts, `options'
	local cns `s(constraints)'
	
	gettoken y x : varlist
	quiet gen double `y1' = `y'
	_fv_check_depvar `y1'
	
	quiet gen double `dy' = `y1' > 0
	
	// The user may have passed the explanatory variables for the selection
	// equation
	if "`select'" != "" {
		parse_select_opts `select'
		if "`s(vars)'" != "" 													{
			local selvars `s(vars)'
			local z `s(vars)'
		}
		else																	///
			local z `x'
		local selcons `s(constant)'
		local selhet `s(het)'
		local seloff `s(off)'
		local selexp `s(exp)'
	}
	else local z `x'
	
	if "`het'" != "" {
		parse_het_opts `het'
		local hetvars `s(vars)'
		local hetcons `s(constant)'
	}
	
	if "`weight'" != "" local wgt "[`weight' `exp']"
	
	// markout missing values
	markout `touse' `selvars' `selhet' `hetvars'
	_vce_parse `touse', opt(Robust oim opg) argopt(CLuster): `wgt', `vce'
	
	if "`exponential'" != "" {
		// transform the dependent variable to logs and trick max likelihood
		quiet replace `y1' = ln(`y1')
		local valname "ln`y'"
		// Set other string values
		local title "Exponential Truncated Hurdle"
		global neh_method "exponential"
	}
	else {
		local valname "`y'"
		local title "Truncated Hurdle"
		global neh_method "linear"
	}
	
	// Initial values
	// Estimates for selection equation
	quiet probit `dy' `z' if `touse' `wgt', `selcons'
	mat `b1' = e(b)
	mat coleq `b1' = selection
	mat `b' = `b1'
	// Estimates for selection heteroskedasticity
	if "`selhet'" != "" {
		quiet predict double `res', pr
		quiet replace `res' = ln((`dy' - `res')^2)
		quiet regress `res' `selhet' if `touse' `wgt', noconstant
		mat `b1' = e(b)
		mat coleq `b1' = sellnsigma
		mat `b' = `b', `b1'
	}
	// Estimates for value equation
	quiet reg `y1' `x' if `dy' & `touse' `wgt', `constant'
	mat `b1' = e(b)
	mat coleq `b1' = `valname'
	mat `b' = `b', `b1'
	// Estimates for value heteroskedasticity
	if "`het'" != "" {
		quiet predict double `res2', res
		quiet replace `res2' = ln(`res2'^2)
		quiet regress `res2' `hetvars' if `touse' `wgt', `hetcons'
		mat `b1' = e(b)
		mat coleq `b1' = lnsigma
	}
	else {
		mat `b1' = (ln(e(rmse)))
		mat colnames `b1' = lnsigma:_cons
	}
	mat `b' = `b' , `b1'
	
	if "`het'" != "" local anci = 0
	else {
		// To display the actual value for sigma
		local diparm diparm(lnsigma, exp label("sigma"))
		local anci = 1
	}
	
	// If there is a selection heteroskedasticity equation we need a different
	// likelihood valuator
	if "`selhet'" == "" {
		ml model lf2 nehurdle_trunc												///
			(selection: `dy'=`z', `selcons' `seloff' `selexp')					///
			(`valname':	 `y1'=`x', `constant' `offset' `exposure')				///
			(lnsigma: `het')													///
			if `touse' `wgt', `log' `mlopts' `vce' init(`b') missing `diparm'	///
			waldtest(-3) nopreserve maximize
	}
	else {
		ml model lf2 nehurdle_trunc_het											///
			(selection: `dy'=`z', `selcons' `seloff' `selexp')					///
			(`valname':	 `y1'=`x', `constant' `offset' `exposure')				///
			(sellnsigma: `selhet', noconstant)									///
			(lnsigma: `het')													///
			if `touse' `wgt', `log' `mlopts' `vce' init(`b') missing `diparm'	///
			waldtest(-4) nopreserve maximize
	}
	
	// Censored observations
	quiet sum `dy' if !`dy' & `touse', mean
	local numcen = r(N)
	
	// Tests of joint signficance
	if "`e(chi2)'" == "." {
		// Selection
		ereturn scalar sel_chi2 = .
		ereturn scalar sel_p = .
		ereturn scalar sel_df = .
		// Value
		ereturn scalar val_chi2 = .
		ereturn scalar val_p = .
		ereturn scalar val_df = .
		// Selection Heteroskedasticity
		if "`selhet'" != "" {
			ereturn scalar selhet_chi2 = .
			ereturn scalar selhet_p = .
			ereturn scalar selhet_df = .
		}
		// Heteroskedasticity
		if "`het'" != "" {
			ereturn scalar het_chi2 = .
			ereturn scalar het_p = .
			ereturn scalar het_df = .
		}
	}
	else {
		// Selection
		if "`z'" != "" {
			quiet testparm `z', eq(#1)
			ereturn scalar sel_chi2 = r(chi2)
			ereturn scalar sel_p = r(p)
			ereturn scalar sel_df = r(df)
		}
		// Value
		if "`x'" != "" {
			quiet testparm `x', eq(#2)
			ereturn scalar val_chi2 = r(chi2)
			ereturn scalar val_p = r(p)
			ereturn scalar val_df = r(df)
		}
		// Selection Heteroskedasticity
		if "`selhet'" != "" {
			quiet testparm `selhet', eq(#3)
			ereturn scalar selhet_chi2 = r(chi2)
			ereturn scalar selhet_p = r(p)
			ereturn scalar selhet_df = r(df)
			// Hetersokedasticity
			if "`het'" != "" {
				quiet testparm `hetvars', eq(#4)
				ereturn scalar het_chi2 = r(chi2)
				ereturn scalar het_p = r(p)
				ereturn scalar het_df = r(df)
			}
		}
		else if "`het'" != "" {
			quiet testparm `hetvars', eq(#3)
			ereturn scalar het_chi2 = r(chi2)
			ereturn scalar het_p = r(p)
			ereturn scalar het_df = r(df)
		}
	}

	ereturn local neh_cmdline = "nehurdle $neh_cmdline"
	if "`exponential'" != "" 													///
		ereturn local est_model = "exponential"
	else ereturn local est_model = "linear"
	macro drop neh_cmdline neh_method
	ereturn local het "`het'"
	ereturn local selhet "`selhet'"
	ereturn local title "`title'"
	ereturn local cmd_opt "trunc"
	// ereturn local marginsok = "XB default"
	ereturn local depvar = "`y'"
	ereturn scalar N_c = `numcen'
	ereturn scalar k_aux = `anci'
	ereturn local predict "nehurdle_p"
	ereturn local cmd = "nehurdle"
	// Predicting censored mean and calculating pseudo r-squared
	tempvar yhat zg selsig sig
	quiet {
		_predict double `zg' `if' `in', equation(#1)
		_predict double `yhat' `if' `in', equation(#2)
		if "`selhet'" != "" {
			_predict double `selsig' `if' `in', equation(#3)
			replace `selsig' = exp(`selsig') `if' `in'
			_predict double `sig' `if' `in', equation(#4)
		}
		else {
			generate double `selsig' = 1 `if' `in'
			_predict double `sig' `if' `in', equation(#3)
		}
		replace `sig' = exp(`sig')
		if "`exponential'" == ""												///
			replace `yhat' = `yhat' + `sig' * normalden(`yhat' / `sig') 		///
			/ normal(`yhat' / `sig') `if' `in'
		else replace `yhat' = exp(`yhat' + `sig'^2 / 2) `if' `in'
		replace `yhat' = normal(`zg' / `selsig') * `yhat' `if' `in'
	}
	capture correl `y' `yhat'
	ereturn scalar r2 = r(rho)^2
	// Display
	Replay, `level' `header' `coeflegend'
end

// TOBIT
program define nehurdle_est_tobit, eclass byable(recall) sortpreserve
	syntax varlist(numeric fv) [if] [in] [fweight pweight iweight],				///
		TObit																	///
		[																		///
			HET(string)															///
			noHEader															///
			EXPONential															///
			noLOg																///
			noCONStant															///
			COEFLegend															///
			vce(passthru)														///
			Level(passthru)														///
			OFFset(passthru)													///
			EXPosure(passthru) *												///
		]
	
	tempvar y1 res2
	tempname b b1 coeff varcov
	marksample touse
	quiet count if `touse'
	if `r(N)' == 0 error 2000

	// Checking syntax of ml options
	mlopts mlopts, `options'
	local cns `s(constraints)'
	
	// parse the varlist
	gettoken y x : varlist
	quiet gen double `y1' = `y'
	_fv_check_depvar `y1'
	
	if "`het'" != "" {
		parse_het_opts `het'
		local hetvars `s(vars)'
		local hetcons `s(constant)'
	}
	
	if "`weight'" != "" local wgt "[`weight' `exp']"
	
	// markout missing values
	markout `touse' `selection' `hetvars'
	_vce_parse `touse', opt(Robust oim opg) argopt(CLuster): `wgt', `vce'
	
	if "`exponential'" != "" {
		quiet replace `y1' = ln(`y1')
		quiet sum `y1', mean
		local gamma = r(min) - 1e-7
		quiet regress `y1' `x' if `touse' `wgt', `constant'
		global neh_method "exponential"												// This is set to use with the ml evaluator
		local etitle "Exponential "
		local ytit "ln`y'"
	}
	else {
		quiet regress `y1' `x' if `y' > 0 & `touse' `wgt', `constant'
		global neh_method "linear"													// This is set to use with the ml evaluator
		local ytit "`y'"
	}
	local numuncen = e(N)
	mat `b' = e(b)
	mat coleq `b' = `ytit'
	
	// Get estimates for heteroskedasticity
	if "`het'" != "" {
		quiet predict `res2', res
		quiet replace `res2' = ln(`res2'^2)
		quiet regress `res2' `hetvars' if `touse' `wgt', `hetcons'
		mat `b1' = e(b)
		mat coleq `b1' = lnsigma
	}
	else {
		mat `b1' = (ln(e(rmse)))
		mat colnames `b1' = lnsigma:_cons
	}
	mat `b' = `b', `b1'
	
	// To display the actual value for sigma
	if "`het'" != "" local anci = 0
	else {
		// To display the actual value for sigma
		local diparm diparm(lnsigma, exp label("sigma"))
		local anci = 1
	}
	
	// Estimation
	ml model lf2 nehurdle_tobit													///
		(`ytit': `y1'=`x', `constant' `offset' `exposure') (lnsigma: `het')		///
		if `touse' `wgt', `log' `mlopts' `vce' init(`b') missing `diparm'		///
		waldtest(-2) nopreserve maximize
	
	// Tests of joint signficance
	if "`e(chi2)'" == "." & "`het'" != "" {
		ereturn scalar val_chi2 = .
		ereturn scalar val_p = .
		ereturn scalar val_df = .
		
		ereturn scalar het_chi2 = .
		ereturn scalar het_p = .
		ereturn scalar het_df = .
	}
	else if "`het'" != "" {
		// Value
		quiet testparm `x', eq(#1)
		ereturn scalar val_chi2 = r(chi2)
		ereturn scalar val_p = r(p)
		ereturn scalar val_df = r(df)
	
		quiet testparm `hetvars', eq(#2)
		ereturn scalar het_chi2 = r(chi2)
		ereturn scalar het_p = r(p)
		ereturn scalar het_df = r(df)
	}
	local numcen = e(N) - `numuncen'
	
	ereturn local neh_cmdline = "nehurdle $neh_cmdline"
	macro drop neh_cmdline neh_method
	if "`het'" == ""  ereturn scalar sigma = exp(_b[lnsigma:_cons])
	ereturn local het "`het'"
	if "`exponential'" != ""													///
		ereturn local est_model = "exponential"
	else ereturn local est_model = "linear"
	// ereturn local marginsok = "XB default"
	ereturn local title "`etitle'Tobit"
	ereturn local cmd_opt "tobit"
	ereturn local depvar = "`y'"
	ereturn scalar N_c = `numcen'
	ereturn scalar k_aux = `anci'
	if "`gamma'" != "" ereturn scalar gamma = `gamma'
	// Predicting censored mean to get the pseudo R-squared
	tempvar yhat sig
	quiet {
		_predict double `yhat' `if' `in', equation(#1)
		_predict double `sig' `if' `in', equation(#2)
		replace `sig' = exp(`sig') `if' `in'
		if "`exponential'" == "" {
			replace `yhat' = normal(`yhat'/`sig') *`yhat' + `sig' *				///
				normalden(`yhat' / `sig') `if' `in'
		}
		else {
			replace `yhat' = exp(`yhat' + (`sig'^2)/2) * normal((`sig'^2 +		///
				`yhat' - `gamma')/`sig') `if' `in'
		}
	}
	capture correl `y' `yhat'
	ereturn scalar r2 = r(rho)^2
	ereturn local predict "nehurdle_p"
	ereturn local cmd = "nehurdle"
	
	// Display
	Replay, `level' `header' `coeflegend'
end

// HECKMAN
capture program drop nehurdle_est_heckman
program define nehurdle_est_heckman, eclass byable(recall) sortpreserve
	syntax varlist(min=1 numeric fv) [if] [in] [fweight pweight iweight] ,		///
		HEckman																	///
		[																		///
			SELect(string)														///
			HET(string)															///
			noHEader															///
			EXPONential															///
			COEFLegend															///
			noLOg																///
			noCONStant															///
			vce(passthru)														///
			Level(passthru)														///
			OFFset(passthru)													///
			EXPosure(passthru) *												///
		]
	// Temporary variables and names
	tempvar y1 dy res1 res1sq res2 res2sq
	tempname b b1 b2 coeff varcov ll0 chi2_c p_c
	
	gettoken y x : varlist
	quiet gen double `y1' = `y'
	_fv_check_depvar `y1'
	
	quiet gen double `dy' = `y1' > 0
	
	if "`select'" != "" {
		parse_select_opts `select'
		if "`s(vars)'" != "" {
			local selvars `s(vars)'
			local z `s(vars)'
		}
		else local z `x'
		local selcons `s(constant)'
		local selhet `s(het)'
		local seloff `s(off)'
		local selexp `s(exp)'
	}
	else local z `x'
	
	if "`het'" != "" {
		parse_het_opts `het'
		local hetvars `s(vars)'
		local hetcons `s(constant)'
	}
	// Marking the sample
	marksample touse
	quiet count if `touse'
	if `r(N)' == 0 error 2000

	// Checking syntax of ml options
	mlopts mlopts, `options'
	local cns `s(constraints)'
	
	if "`weight'" != "" local wgt "[`weight' `exp']"
	
	// markout missing values
	markout `touse' `selvars' `selhet' `hetvars'
	_vce_parse `touse', opt(Robust oim opg) argopt(CLuster): `wgt', `vce'
	
	if "`exponential'" != "" {
		// transform the dependent variable to logs and trick max likelihood
		quiet replace `y1' = ln(`y1')	
		local valname "ln`y'"
		local title "Exponential Type II Tobit"
		global neh_method "exponential"
	}
	else {
		local title "Type II Tobit"
		local valname "`y'"
		global neh_method "linear"
	}
	
	// Initial values
	// Estimates for selection equation
	quiet probit `dy' `z' if `touse' `wgt', `selcons'
	mat `b1' = e(b)
	mat coleq `b1' = selection
	mat `b' = `b1'
	quiet predict double `res1', pr
	quiet replace `res1' = `dy' - `res1'
	// Estimates for selection heteroskedasticity
	if "`selhet'" != "" {
		quiet gen double `res1sq' = ln(`res1'^2)
		quiet regress `res1sq' `selhet' if `touse' `wgt', noconstant
		mat `b1' = e(b)
		mat coleq `b1' = sellnsigma
		mat `b' = `b', `b1'
	}
	// Estimates for value equation
	quiet reg `y1' `x' if `dy' & `touse' `wgt', `constant'
	mat `b1' = e(b)
	mat coleq `b1' = `valname'
	mat `b' = `b', `b1'
	quiet predict double `res2', res
	// Get estimates for heteroskedasticity of value equation
	if "`het'" != "" {
		quiet gen double `res2sq' = ln(`res2'^2)
		quiet regress `res2sq' `hetvars' if `dy' & `touse' `wgt', `hetcons'
		mat `b1' = e(b)
		mat coleq `b1' = lnsigma
	}
	else {
		mat `b1' = (ln(e(rmse)))
		mat colnames `b1' = lnsigma:_cons
	}
	mat `b' = `b' , `b1'
	
	// Use the correlation of the probit and regression residuals for the
	// initial value of correlation
	quiet corr `res1' `res2'
	if r(rho) < 0 local st = -0.5
	else local st = 0.5
	mat `b1' = atanh(`st')
	mat colnames `b1' = athrho:_cons
	mat `b' = `b' , `b1'
	
	// To display the actual values of the ancilliary parameters
	local dip2 diparm(athrho, tanh label("rho"))
	if "`het'" != "" local anci = 1
	else {
		local dip1 diparm(lnsigma, exp label("sigma"))
		local dip3 diparm(athrho lnsigma,										///
			func(exp(@2)*(exp(@1)-exp(-@1))/(exp(@1)+exp(-@1)))					///
			der(exp(@2)*(1-((exp(@1)-exp(-@1))/(exp(@1)+exp(-@1)))^2)			///
			exp(@2)*(exp(@1)-exp(-@1))/(exp(@1)+exp(-@1))) label("lambda"))
		local anci = 2
	}
	
	// If there is a selection heteroskedasticity equation we need a different
	// likelihood valuator
	if "`selhet'" == ""															///
		ml model lf2 nehurdle_heckman											///
			(selection: `dy'=`z', `selcons' `seloff' `selexp')					///
			(`valname':	 `y1'=`x', `constant' `offset' `exposure')				///
			(lnsigma: `het') (athrho:)											///
			if `touse' `wgt', `log' `mlopts' `vce' init(`b') missing `dip1'		///
			`dip2' `dip3' waldtest(-4) nopreserve maximize
	else																		///
		ml model lf2 nehurdle_heckman_het										///
			(selection: `dy'=`z', `selcons' `seloff' `selexp')					///
			(`valname':	 `y1'=`x', `constant' `offset' `exposure')				///
			(sellnsigma: `selhet', noconstant)									///
			(lnsigma: `het') (athrho:)											///
			if `touse' `wgt', `log' `mlopts' `vce' init(`b') missing `dip1'		///
			`dip2' `dip3' waldtest(-5) nopreserve maximize
	
	quiet sum `dy' if !`dy' & `touse'
	local numcen = r(N)
	
	// Tests of joint signficance
	if "`e(chi2)'" == "." {
		// Selection
		ereturn scalar sel_chi2 = .
		ereturn scalar sel_p = .
		ereturn scalar sel_df = .
		// Value
		ereturn scalar val_chi2 = .
		ereturn scalar val_p = .
		ereturn scalar val_df = .
		// Selection Heteroskedasticity
		if "`selhet'" != "" {
			ereturn scalar selhet_chi2 = .
			ereturn scalar selhet_p = .
			ereturn scalar selhet_df = .
		}
		// Heteroskedasticity
		if "`het'" != "" {
			ereturn scalar het_chi2 = .
			ereturn scalar het_p = .
			ereturn scalar het_df = .
		}
	}
	else {
		// Selection
		if "`z'" != "" {
			quiet testparm `z', eq(#1)
			ereturn scalar sel_chi2 = r(chi2)
			ereturn scalar sel_p = r(p)
			ereturn scalar sel_df = r(df)
		}
		// Value
		if "`x'" != "" {
			quiet testparm `x', eq(#2)
			ereturn scalar val_chi2 = r(chi2)
			ereturn scalar val_p = r(p)
			ereturn scalar val_df = r(df)
		}
		// Selection Heteroskedasticity
		if "`selhet'" != "" {
			quiet testparm `selhet', eq(#3)
			ereturn scalar selhet_chi2 = r(chi2)
			ereturn scalar selhet_p = r(p)
			ereturn scalar selhet_df = r(df)
			// Hetersokedasticity
			if "`het'" != "" {
				quiet testparm `hetvars', eq(#4)
				ereturn scalar het_chi2 = r(chi2)
				ereturn scalar het_p = r(p)
				ereturn scalar het_df = r(df)
			}
		}
		else if "`het'" != "" {
			quiet testparm `hetvars', eq(#3)
			ereturn scalar het_chi2 = r(chi2)
			ereturn scalar het_p = r(p)
			ereturn scalar het_df = r(df)
		}
	}
	
	ereturn local neh_cmdline "nehurdle $neh_cmdline"
	macro drop neh_cmdline neh_method
	if "`exponential'" != "" ///
		ereturn local est_model "exponential"
	else ereturn local est_model "linear"
	ereturn local title "`title'"
	ereturn local cmd_opt "heckman"
	// ereturn local marginsok "XB default"
	ereturn local depvar "`y'"
	ereturn local het "`het'"
	ereturn local selhet "`selhet'"
	ereturn scalar rho = tanh(_b[athrho:_cons])
	if "`het'" == "" {
		ereturn scalar sigma = exp(_b[lnsigma:_cons])
		ereturn scalar lambda = exp(_b[lnsigma:_cons]) * tanh(_b[athrho:_cons])
	}
	ereturn scalar N_c = `numcen'
	ereturn scalar k_aux = `anci'
	// Predicting the censored mean and calculating the pseudo R-squared
	tempvar yhat zg selsig sig rho
	quiet {
		_predict double `zg' `if' `in', equation(#1)
		_predict double `yhat' `if' `in', equation(#2)
		if "`selhet'" != "" {
			_predict double `selsig' `if' `in', equation(#3)
			replace `selsig' = exp(`selsig') `if' `in'
			_predict double `sig' `if' `in', equation(#4)
			_predict double `rho' `if' `in', equation(#5)
		}
		else {
			generate double `selsig' = 1 `if' `in'
			_predict double `sig' `if' `in', equation(#3)
			_predict double `rho' `if' `in', equation(#4)
		}
		replace `sig' = exp(`sig') `if' `in'
		replace `rho' = tanh(`rho') `if' `in'
		if "`exponential'" == ""												///
			replace `yhat' = `yhat' + `sig' * `rho' * normalden(`zg' / `selsig') ///
				/ normal(`zg' / `selsig') `if' `in'
		else																	///
			replace `yhat' = exp(`yhat' + `sig'^2 / 2) * normal(`zg' / `selsig'	///
				+ `rho' * `sig') / normal(`zg' / `selsig') `if' `in'
		replace `yhat' = normal(`zg' / `selsig') * `yhat' `if' `in'
	}
	capture quiet correl `y' `yhat'
	ereturn scalar r2 = r(rho)^2
	ereturn local predict "nehurdle_p"
	ereturn local cmd "nehurdle"
	// Display
	di as txt ""
	Replay, `level' `header' `coeflegend'
end

// Version 1.0.0 uses lf evaluators for all models and specifications
// Version 1.1.0 uses lf2 evaluators for all models and specifications and
//		no longer performs the LR test for the correlation in the Heckman
