*! version 1.4.3  26feb2017
*! Sebastian Kripfganz, www.kripfganz.de

*==================================================*
****** quasi-maximum likelihood linear dynamic panel data estimation ******

*** citation ***

/*	Kripfganz, S. 2016.
	Quasi-maximum likelihood estimation of linear dynamic short-T panel-data models.
	Stata Journal 16: 1013-1038.		*/

*** version history at the end of the file ***

program define xtdpdqml, eclass prop(xt)
	version 12.1
	if replay() {
		if "`e(cmd)'" != "xtdpdqml" {
			error 301
		}
		xtdpdqml_display `0'
	}
	else {
		_xt, treq
		syntax anything [if] [in] [, FE RE *]
		xtdpdqml_parse_display , `options'
		loc diopts			"`s(diopts)'"
		xtdpdqml_ml_init , `s(options)'
		loc method			"`s(method)'"
		if "`re'" != "" {
			if "`fe'" != "" {
				di as err "options fe and re may not be combined"
				exit 184
			}
			loc model			"re"
		}
		else {
			loc model			"fe"
		}
		xtdpdqml_`model' `anything' `if' `in', `s(options)'

		eret loc ml_method	"`method'"
		eret loc model		"`model'"
		eret loc predict	"xtdpdqml_p"
		eret loc estat_cmd	"xtdpdqml_estat"
		eret loc tvar		"`_dta[_TStvar]'"
		eret loc ivar		"`_dta[_TSpanel]'"
		eret loc cmdline 	`"xtdpdqml `0'"'
		eret loc cmd		"xtdpdqml"
		xtdpdqml_display , noreplay `diopts'
	}
end

*==================================================*
***** fixed-effects QML estimation *****
program define xtdpdqml_fe, eclass sort
	version 12.1
	syntax varlist(num ts) [if] [in] [,	noCONStant							///
										STAtionary							///
										FROM(passthru)						///
										STOreinit(name)						///
										INITVal(numlist max=2 >0 miss)		///
										INITIter(integer 0)					///
										CONCentration						///
										VCE(passthru)						///
										MLParams							///
										*]									// parsed separately (repeated occurence possible): PROjection()
	marksample touse

	*--------------------------------------------------*
	*** variable identification ***
	xtdpdqml_vars `varlist', touse(`touse') difference `constant'
	loc depvar			"`s(depvar)'"					// dependent variable
	loc indepvars		"`s(indepvars)'"				// independent variables
	loc tvindepvars		"`s(tvindepvars)'"				// time-varying independent variables
	loc tiindepvars		"`s(tiindepvars)'"				// time-invariant independent variables
	loc regnames		"`s(regnames)'"					// regressor names (including omitted variables)
	loc regpos			"`s(tvindeppos)' `s(tiindeppos)' `s(omitpos)'"
	loc ddepvar			"D.`depvar'"					// first-differenced dependent variable
	loc dtvindepvars	"`s(dtvindepvars)'"				// first-differenced time-varying independent variables

	*--------------------------------------------------*
	*** sample determination ***
	markout `touse' `ddepvar' `dtvindepvars'
	tempvar dtouse dtouse0
	xtdpdqml_sample `touse', generate(`dtouse0' `dtouse')
	loc maxlead			= r(maxlead)
	qui _rmcoll `dtvindepvars' if `dtouse', nocons
	loc collvars		"`r(varlist)'"
	loc domitvars		: list dtvindepvars - collvars
	foreach dvar of loc domitvars {
		loc pos				: list posof "`dvar'" in dtvindepvars
		loc var				: word `pos' of `tvindepvars'
		loc omitvars		"`omitvars' `var'"
		di as txt "note: `var' omitted because of collinearity"
		loc pos				: list posof "`var'" in regnames
		loc ++pos
		loc regpos			"`: list regpos - pos' `pos'"
	}
	loc tvindepvars		: list tvindepvars - omitvars
	loc dtvindepvars	: list dtvindepvars - domitvars

	*--------------------------------------------------*
	*** syntax parsing for the initial observations ***
	while `"`options'"' != "" {
		xtdpdqml_parse `exovars', maxlead(`maxlead') `options'
		loc exovars			"`exovars' `s(varlist)'"
		loc leads			"`leads' `s(leads)'"
		loc lags			"`lags' `s(lags)'"
		loc options			`"`s(options)'"'
	}
	loc dtvindepvars0	"`: list dtvindepvars - exovars'"
	forv i = 1 / `: word count `dtvindepvars0'' {
		loc leads			"`maxlead' `leads'"
		loc lags			". `lags'"
	}
	loc dtvindepvars0	"`dtvindepvars0' `exovars'"
	if `: word count `dtvindepvars0'' > 0 {
		xtdpdqml_initvars `dtvindepvars0' if `dtouse0', leads(`leads') lags(`lags')
		loc dtvindepvars0	"`s(varlist)'"
	}

	loc stationary		= ("`stationary'" != "")
	loc concentration	= ("`concentration'" != "")
	if !`stationary' {
		loc dtvindepvars0	"`dtvindepvars0' `dtouse0'"		// add constant term to initial-observations regressors (irrespective of whether option noconstant is specified)
	}
	else if `: word count `dtvindepvars0'' == 0 {
		if `: word count `dtvindepvars'' > 0 {
			loc dtvindepvars0	"`dtouse0'"
			di as txt "note: option stationary ignored"
		}
		else {
			if `concentration' {
				di as txt "note: option concentration ignored"
			}
			if `inititer' > 0 {
				di as txt "note: option inititer(`inititer') ignored"
			}
		}
	}

	*--------------------------------------------------*
	*** lagged dependent variable ***
	loc regnames		"L.`depvar' `regnames'"
	loc tvexovars		"`tvindepvars'"
	loc tvindepvars		"L.`depvar' `tvindepvars'"
	loc dtvindepvars	"L.`ddepvar' `dtvindepvars'"
	tsunab dtvindepvars	: `dtvindepvars'
	_rmdcoll `tvindepvars' if `touse', `constant' normcoll

	*--------------------------------------------------*
	*** constant term for the level equation ***
	if "`constant'" == "" {
		if `: word count `tiindepvars'' > 1 {
			di as txt "note: coefficients of time-invariant regressors are not identified"
		}
		loc tiindepvars		"`touse'"
		loc varlist			"`varlist' _cons"
	}
	else {
		loc tiindepvars		""
	}

	*--------------------------------------------------*
	*** type of the variance-covariance matrix ***
	_vce_parse , opt(OIM OPG Robust) : , `vce'
	if "`r(vce)'" == "" {
		loc vce 			"oim"
	}
	else {
		loc vce				"`r(vce)'"
	}
	loc vcetype			= ("`vce'" == "robust") + 2 * ("`vce'" == "opg")
	loc mlparams		= ("`mlparams'" != "")

	*--------------------------------------------------*
	*** initial estimates ***
	tempname b b_aux
	if `"`from'"' == "" {								// GMM estimation
		if `: word count `tvexovars'' > 0 {
			loc iv				"div(`tvexovars')"
		}
		if "`vce'" == "robust" & "`storeinit'" != "" {
			loc robust			"vce(robust)"
		}
		qui xtdpd `depvar' `tvindepvars' if `touse', dgmmiv(`depvar', l(2)) `iv' `constant' hascons `robust'
		mat `b'				= e(b)
		mat `b'				= `b'[1, 1..`: word count `tvindepvars'']
		if "`storeinit'" != "" {
			est title: initial estimates for xtdpdqml
			est sto `storeinit', nocopy
		}
	}
	else {
		if "`storeinit'" != "" {
			di as err "options from and storeinit may not be combined"
			exit 184
		}
		mat `b_aux'			= J(1, `: word count `tvindepvars'', 0)
		_mkvec `b', `from' col(`tvindepvars') first err("from()")		// initial estimates (parameters from level equation)
		if mreldif(`b', `b_aux') == 0 {
			mat drop `b'
			_mkvec `b', `from' col(`dtvindepvars') first err("from()")		// initial estimates (parameters from first-differenced equation)
		}
	}
	if `stationary' > 0 & abs(el(`b', 1, 1)) >= 1 {
		di as txt "note: initial values inconsistent with option stationary"
	}

	if "`initval'" == "" {
		loc sigma2e			= 0
		loc omega			= 0
	}
	else {
		loc sigma2e			: word 1 of `initval'
		if `sigma2e' >= . {
			loc sigma2e			= 0
		}
		if `: word count `initval'' == 2 {
			loc omega			: word 2 of `initval'
			if `omega' >= . {
				loc omega			= 0
			}
		}
		else {
			loc omega			= 0
		}
	}

	*--------------------------------------------------*
	*** estimation ***
	mata: xtdpdqml_est(	"`ddepvar'",					/// dependent variable
						"`dtvindepvars'",				/// regressor variables for first-differenced equation
						"`dtvindepvars0'",				/// regressor variables for initial observations
						"`_dta[_TSpanel]'",				/// panel identifier
						"`dtouse'",						/// marker variable for first-differenced equation
						"`dtouse0'",					/// marker variable for initial observations
						"`b'",							/// coefficient vector of initial estimates
						(`sigma2e', `omega'),			/// initialization with specific value of the initial-observations variance parameter
						`inititer',						/// iterative initialization
						`concentration',				/// concentrated or non-concentrated log-likelihood
						`vcetype',						/// variance-covariance matrix type
						xtdpdqml_qml)
	tempname V g b_ml V_ml g_ml V_oim log
	mat `b'				= r(b)
	mat `V'				= r(V)
	mat `g'				= r(gradient)
	mat `b_ml'			= r(b_ml)
	mat `V_ml'			= r(V_ml)
	mat `g_ml'			= r(gradient_ml)
	mat `V_oim'			= r(V_oim)
	mat `log'			= r(log)
	loc N				= r(N)
	loc N_g				= r(N_g)
	loc T_min			= r(T_min)
	loc T_max			= r(T_max)
	loc ll				= r(ll)
	loc	rank			= r(rank)
	loc iterations		= r(iterations)
	loc converged		= r(converged)

	foreach var of loc dtvindepvars {
		loc params			"`params' _model:`var'"
	}
	loc varlist0		: subinstr loc dtvindepvars0 "`dtouse0'" "_cons", w
	foreach var of loc varlist0 {
		loc params			"`params' _initobs:`var'"
	}
	loc params			"`params' _sigma2e:_cons _omega:_cons"
	mat coln `b_ml'		= `params'
	mat rown `V_ml'		= `params'
	mat coln `V_ml'		= `params'
	mat coln `g_ml'		= `params'
	mat rown `V_oim'	= `params'
	mat coln `V_oim'	= `params'

	*--------------------------------------------------*
	*** coefficients of time-invariant regressors ***
	if !`mlparams' {
		if `: word count `regnames'' > `: word count `tvindepvars'' {
			tempname sigma
			mat `sigma'			= (`b_ml'[1, "_sigma2e:"], `b_ml'[1, "_omega:"])
			tempvar du du0
			mat sco double `du' = `b_ml' if `dtouse', eq(#1)
			mat sco double `du0' = `b_ml' if `dtouse0', eq(#2)
			qui replace `du' = `ddepvar' - `du' if `dtouse'
			qui replace `du' = `ddepvar' - `du0' if `dtouse0'
			mata: xtdpdqml_cons("`depvar'",				/// dependent variable
								"`tvindepvars'",		/// independent time-varying variables
								"`tiindepvars'",		/// independent time-invariant regressor variables
								"`dtvindepvars'",		/// regressor variables for first-differenced equation
								"`dtvindepvars0'",		/// regressor variables for initial observations
								"`du'",					/// residuals for first-differenced equation
								"`_dta[_TSpanel]'",		/// panel identifier
								"`_dta[_TStvar]'",		/// time identifier
								"`touse'",				/// marker variable for whole sample
								"`b'",					/// first-stage coefficient vector
								"`V'",					/// first-stage covariance matrix
								"`V_oim'",				/// first-stage inverse negative Hessian matrix
								"`sigma'",				/// first-stage variance components
								(`vcetype' == 1),		/// robust variance-covariance matrix
								"`regpos'")				// variable positions as specified in command syntax
			drop `du' `du0'
			mat `b'				= r(b)
			mat `V'				= r(V)
			mat `g'				= (`g', J(1, `: word count `regnames'' - `: word count `tvindepvars'', 0))
		}
		mat coln `b'		= `regnames'
		mat rown `V'		= `regnames'
		mat coln `V'		= `regnames'
		mat coln `g'		= `regnames'
	}

	*--------------------------------------------------*
	*** return estimation results ***
	if `mlparams' {
		eret post `b_ml' `V_ml', dep(`ddepvar') o(`N') e(`touse')
	}
	else {
		eret post `b' `V', dep(`depvar') o(`N') e(`touse')
	}
	eret sca N_g		= `N_g'
	eret sca g_min		= `T_min'
	eret sca g_avg		= `N' / `N_g'
	eret sca g_max		= `T_max'
	if `mlparams' {
		eret sca k_aux		= 2
		if `: word count `dtvindepvars0'' > 0 {
			eret sca k_eq		= 4
			eret hidden loc diparm_opt4 "noprob"
		}
		else {
			eret sca k_eq		= 3
		}
		eret hidden loc diparm_opt3 "noprob"
	}
	else {
		eret sca k_aux		= 0
		eret sca k_eq		= 1
	}
	eret sca ll			= `ll'
	eret sca rank		= `rank'
	eret sca ic			= `iterations'
	eret sca converged	= `converged'
	eret sca stationary	= `stationary'
	if "`vce'" == "robust" {
		eret loc vcetype	"Robust"
	}
	eret loc vce		"`vce'"
	eret mat ilog		= `log'
	if `mlparams' {
		eret mat gradient	= `g_ml'
	}
	else {
		eret mat gradient	= `g'
	}
	if `vcetype' == 1 & `mlparams' {
		eret mat V_modelbased	= `V_oim'
	}
end

*==================================================*
***** random-effects QML estimation *****
program define xtdpdqml_re, eclass sort
	version 12.1
	syntax varlist(num ts) [if] [in] [,	noCONStant						///
										STAtionary						///
										noEFfects						///
										FROM(passthru)					///
										STOreinit(name)					///
										INITVal(numlist max=4 miss)		///
										VCE(passthru)					///
										MLParams						///
										*]								// parsed separately (repeated occurence possible): PROjection()
	marksample touse

	*--------------------------------------------------*
	*** variable identification ***
	xtdpdqml_vars `varlist', touse(`touse') `constant'
	loc depvar			"`s(depvar)'"					// dependent variable
	loc indepvars		"`s(indepvars)'"				// independent variables
	loc tvindepvars		"`s(tvindepvars)'"				// time-varying independent variables
	loc tiindepvars		"`s(tiindepvars)'"				// time-invariant independent variables
	loc regnames		"`s(regnames)'"					// regressor names (including omitted variables)
	loc regpos			"`s(indeppos)' `s(omitpos)'"

	*--------------------------------------------------*
	*** sample determination ***
	tempvar touse0 ltouse
	xtdpdqml_sample `touse', generate(`touse0' `ltouse')
	loc maxlead			= r(maxlead)
	qui _rmcoll `indepvars' if `ltouse', `constant'
	loc collvars		"`r(varlist)'"
	loc omitvars		: list indepvars - collvars
	foreach var of loc omitvars {
		di as txt "note: `var' omitted because of collinearity"
		loc pos				: list posof "`var'" in regnames
		loc ++pos
		loc regpos			"`: list regpos - pos' `pos'"
	}
	loc indepvars		: list indepvars - omitvars
	loc tvindepvars		: list tvindepvars - omitvars
	loc tiindepvars		: list tiindepvars - omitvars

	*--------------------------------------------------*
	*** syntax parsing for the initial observations ***
	while `"`options'"' != "" {
		xtdpdqml_parse `exovars', maxlead(`maxlead') nodifference `options'
		loc exovars			"`exovars' `s(varlist)'"
		loc leads			"`leads' `s(leads)'"
		loc options			`"`s(options)'"'
	}
	loc tiindepvars0	"`: list tiindepvars - exovars'"
	forv i = 1 / `: word count `tiindepvars0'' {
		loc leads			"0 `leads'"
	}
	loc indepvars0		"`tiindepvars0' `exovars'"
	loc tvindepvars0	"`: list tvindepvars - exovars'"
	forv i = 1 / `: word count `tvindepvars0'' {
		loc leads			"`maxlead' `leads'"
	}
	loc indepvars0		"`tvindepvars0' `indepvars0'"
	if `: word count `indepvars0'' > 0 {
		xtdpdqml_initvars `indepvars0' if `touse0', leads(`leads')
		loc indepvars0		"`s(varlist)'"
	}

	loc stationary		= ("`stationary'" != "")
	if "`constant'" == "" {
		if `stationary' & (`: word count `tvindepvars'' > 0 | !`: list indepvars0 === tiindepvars') {
			loc stationary		= 2
		}
		loc indepvars0		"`indepvars0' `touse0'"
	}
	else if `stationary' {
		if `: word count `tvindepvars'' > 0 | !`: list indepvars0 === tiindepvars' {
			loc stationary		= 2
		}
	}
	else {
		loc indepvars0		"`indepvars0' `touse0'"
	}
	loc indepvars0		"`: list retok indepvars0'"

	*--------------------------------------------------*
	*** lagged dependent variable ***
	loc regnames		"L.`depvar' `regnames'"
	loc indepvars		"L.`depvar' `indepvars'"
	loc tvexovars		"`tvindepvars'"
	loc tvindepvars		"L.`depvar' `tvindepvars'"
	_rmdcoll `indepvars' if `ltouse', `constant' normcoll

	*--------------------------------------------------*
	*** type of the variance-covariance matrix ***
	_vce_parse , opt(OIM OPG Robust) : , `vce'
	if "`r(vce)'" == "" {
		loc vce 			"oim"
	}
	else {
		loc vce				"`r(vce)'"
	}
	loc vcetype			= ("`vce'" == "robust") + 2 * ("`vce'" == "opg")
	loc mlparams		= ("`mlparams'" != "")

	*--------------------------------------------------*
	*** initial estimates ***
	tempname b
	if `"`from'"' == "" {								// GMM estimation
		if `: word count `tvexovars'' > 0 {
			loc iv				"div(`tvexovars')"
		}
		if `: word count `tiindepvars'' > 0 {
			loc iv				"`iv' liv(`tiindepvars')"
		}
		if "`vce'" == "robust" & "`storeinit'" != "" {
			loc robust			"vce(robust)"
		}
		capture qui xtdpd `depvar' `indepvars' if `ltouse', dgmmiv(`depvar', l(2)) `iv' `constant' hascons `robust'
		if _rc != 0 {
			error 2001
		}
		mat `b'				= e(b)
		if "`storeinit'" != "" {
			est title: initial estimates for xtdpdqml
			est sto `storeinit', nocopy
		}
	}
	else {
		if "`storeinit'" != "" {
			di as err "options from and storeinit may not be combined"
			exit 184
		}
		if "`constant'" == "" {
			loc hascons			"_cons"
		}
		_mkvec `b', `from' col(`indepvars' `hascons') first err("from()")		// initial estimates
	}
	if `stationary' > 0 & abs(el(`b', 1, 1)) >= 1 {
		di as txt "note: initial values inconsistent with option stationary"
	}

	if "`initval'" == "" {
//		if "`initnoeffects'" == "" {
			loc sigma2u			= .
			loc phi				= .
//		}
//		else {
//			loc sigma2u			= 0
//			loc phi				= 0
//		}
		loc sigma2e			= .
		loc sigma2e0		= .
	}
	else {
//		if "`initnoeffects'" != "" {
//			di as err "options initval() and initnoeffects may not be combined"
//			exit 184
//		}
		loc sigma2u			: word 1 of `initval'
		if `sigma2u' <= 0 {
			di as err "initval() invalid -- invalid numlist has elements outside of allowed range"
			exit 125
		}
		if `: word count `initval'' >= 2 {
			loc sigma2e			: word 2 of `initval'
			if `sigma2e' <= 0 {
				di as err "initval() invalid -- invalid numlist has elements outside of allowed range"
				exit 125
			}
		}
		else {
			loc sigma2e			= .
		}
		if `: word count `initval'' >= 3 {
			loc sigma2e0		: word 3 of `initval'
			if `sigma2e0' <= 0 {
				di as err "initval() invalid -- invalid numlist has elements outside of allowed range"
				exit 125
			}
		}
		else {
			loc sigma2e0		= .
		}
		if `: word count `initval'' == 4 {
			loc phi				: word 4 of `initval'
		}
		else {
			loc phi				= .
		}
	}
	if "`effects'" != "" {
		loc sigma2u			= 0
		loc phi				= 0
	}
	if "`constant'" == "" {
		loc indepvars		"`indepvars' `ltouse'"
	}

	*--------------------------------------------------*
	*** estimation ***
	mata: xtdpdqml_re_est(	"`depvar'",										/// dependent variable
							"`indepvars'",									/// regressor variables
							"`indepvars0'",									/// regressor variables for initial observations
							"`_dta[_TSpanel]'",								/// panel identifier
							"`ltouse'",										/// marker variable
							"`touse0'",										/// marker variable for initial observations
							"`b'",											/// coefficient vector of initial estimates
							(`sigma2u', `sigma2e', `sigma2e0', `phi'),		/// initialization with specific value of the initial-observations variance parameter
							`stationary',									/// initial observations from stationary distribution
							`vcetype',										/// variance-covariance matrix type
							"`regpos'",										/// variable positions as specified in command syntax
							xtdpdqml_qml)
	tempname V g b_ml V_ml g_ml log
	mat `b'				= r(b)
	mat `V'				= r(V)
	mat `g'				= r(gradient)
	mat `b_ml'			= r(b_ml)
	mat `V_ml'			= r(V_ml)
	mat `g_ml'			= r(gradient_ml)
	mat `log'			= r(log)
	if `vcetype' == 1 & `mlparams' {
		tempname V_oim
		mat `V_oim'			= r(V_oim)
	}
	loc N				= r(N)
	loc N_g				= r(N_g)
	loc T_min			= r(T_min)
	loc T_max			= r(T_max)
	loc ll				= r(ll)
	loc rank			= r(rank)
	loc iterations		= r(iterations)
	loc converged		= r(converged)

	mat coln `b'		= `regnames'
	mat rown `V'		= `regnames'
	mat coln `V'		= `regnames'
	mat coln `g'		= `regnames'
	foreach var of loc indepvars {
		if "`var'" == "`ltouse'" {
			loc params			"`params' _model:_cons"
		}
		else {
			loc params			"`params' _model:`var'"
		}
	}
	loc varlist0		: subinstr loc indepvars0 "`touse0'" "_cons", w
	foreach var of loc varlist0 {
		loc params			"`params' _initobs:`var'"
	}
	loc params			"`params' _sigma2u:_cons _sigma2e:_cons _sigma2e0:_cons _phi:_cons"
	mat coln `b_ml'		= `params'
	mat rown `V_ml'		= `params'
	mat coln `V_ml'		= `params'
	mat coln `g_ml'		= `params'
	if `vcetype' == 1 & `mlparams' {
		mat rown `V_oim'	= `params'
		mat coln `V_oim'	= `params'
	}

	*--------------------------------------------------*
	*** return estimation results ***
	if `mlparams' {
		eret post `b_ml' `V_ml', dep(`depvar') o(`N') e(`touse')
	}
	else {
		eret post `b' `V', dep(`depvar') o(`N') e(`touse')
	}
	eret sca N_g		= `N_g'
	eret sca g_min		= `T_min'
	eret sca g_avg		= `N' / `N_g'
	eret sca g_max		= `T_max'
	if `mlparams' {
		eret sca k_aux		= 4
		if `: word count `indepvars0'' > 0 {
			eret sca k_eq		= 6
			eret hidden loc diparm_opt6 "noprob"
		}
		else {
			eret sca k_eq		= 5
		}
		eret hidden loc diparm_opt5 "noprob"
		eret hidden loc diparm_opt4 "noprob"
		eret hidden loc diparm_opt3 "noprob"
	}
	else {
		eret sca k_aux		= 0
		eret sca k_eq		= 1
	}
	eret sca ll			= `ll'
	eret sca rank		= `rank'
	eret sca ic			= `iterations'
	eret sca converged	= `converged'
	eret sca stationary	= (`stationary' > 0)
	if "`vce'" == "robust" {
		eret loc vcetype	"Robust"
	}
	eret loc vce		"`vce'"
	eret mat ilog		= `log'
	if `mlparams' {
		eret mat gradient	= `g_ml'
	}
	else {
		eret mat gradient	= `g'
	}
	if `vcetype' == 1 & `mlparams' {
		eret mat V_modelbased	= `V_oim'
	}
end

*==================================================*
**** display of estimation results ****
program define xtdpdqml_display
	version 12.1
	syntax [, noREPLAY noHEader noTABle *]

	if "`replay'" == "" {
		di _n as txt "Quasi-maximum likelihood estimation"
	}
	if "`header'" == "" {
		di _n as txt "Group variable: " as res abbrev("`e(ivar)'", 12) as txt _col(46) "Number of obs" _col(68) "=" as res %10.0f e(N)
		di as txt "Time variable: " as res abbrev("`e(tvar)'", 12) as txt _col(46) "Number of groups" _col(68) "=" as res %10.0f e(N_g)
	}
	if "`e(model)'" == "fe" {
		di _n as txt "Fixed effects" _c
	}
	else {
		di _n as txt "Random effects" _c
	}
	if "`header'" == "" {
		di _col(46) "Obs per group:" _col(64) "min =" _col(70) as res %9.0g e(g_min)
		di as txt _col(64) "avg =" _col(70) as res %9.0g e(g_avg)
		if "`e(model)'" == "fe" & `e(k_eq)' == 1 {
			di as txt "(Estimation in first differences)" _c
		}
		di as txt _col(64) "max =" _col(70) as res %9.0g e(g_max)
	}
	else {
		di ""
	}
	if "`table'" == "" {
		_coef_table, `options'
	}
end

*==================================================*
**** syntax parsing of additional display options ****
program define xtdpdqml_parse_display, sclass
	version 12.1
	sret clear
	syntax , [noHEader noTABle First NEQ(integer -1) PLus SEParator(integer 0) *]
	_get_diopts diopts options, `options'

	sret loc diopts		`"`header' `table' `first' neq(`neq') `plus' sep(`separator') `diopts'"'
	sret loc options	`"`options'"'
end

*==================================================*
**** syntax parsing of the optimization options ****
program define xtdpdqml_ml_init, sclass
	version 12.1
	sret clear
	loc maxiter			= c(maxiter)
	syntax [,	METHOD(string)						///
				ITERate(integer `maxiter')			///
				TECHnique(string)					///
				noLOg								///
				SHOWSTEP							///
				SHOWTOLerance						///
				TOLerance(real 1e-6)				///
				LTOLerance(real 1e-7)				///
				NRTOLerance(real 1e-5)				///
				NONRTOLerance						///
				First								///
				*]

	capture mata: mata drop xtdpdqml_qml
	mata: xtdpdqml_qml = optimize_init()

	if `"`method'"' == "" {
		loc method			"d2"
	}
	else {
		loc method			: subinstr loc method "derivative" "d", all
		loc methods			"d0 d1 d2 d1debug d2debug"
		if `: word count `method'' > 1 | !`: list method in methods' {
			di as err "option method() incorrectly specified -- invalid evaluator type"
			exit 198
		}
	}
	mata: optimize_init_evaluatortype(xtdpdqml_qml, "`method'")
	if `"`technique'"' != "" {
		mata: optimize_init_technique(xtdpdqml_qml, `"`technique'"')
	}
	mata: optimize_init_conv_maxiter(xtdpdqml_qml, `iterate')
	mata: optimize_init_conv_ptol(xtdpdqml_qml, `tolerance')
	mata: optimize_init_conv_vtol(xtdpdqml_qml, `ltolerance')
	if "`nonrtolerance'" == "" {
		mata: optimize_init_conv_nrtol(xtdpdqml_qml, `nrtolerance')
	}
	else {
		mata: optimize_init_conv_ignorenrtol(xtdpdqml_qml, "on")
	}
	if "`log'" != "" {
		mata: optimize_init_tracelevel(xtdpdqml_qml, "none")
	}
	if "`showstep'" != "" {
		mata: optimize_init_trace_step(xtdpdqml_qml, "on")
	}
	if "`showtolerance'" != "" {
		mata: optimize_init_trace_tol(xtdpdqml_qml, "on")
	}

	sret loc method		`"`method'"'
	sret loc diopts		"`first'"
	sret loc options	`"`options'"'
end

*==================================================*
**** variable identification ****
program define xtdpdqml_vars, sclass
	version 12.1
	sret clear
	syntax varlist(num ts) , touse(varname num) [DIfference noCONStant]

	*--------------------------------------------------*
	*** dependent variable and regressors ***
	gettoken depvar indepvars : varlist
	_rmdcoll `varlist' if `touse', `constant'
	loc regnames		"`r(varlist)'"
	loc indepvars		: list indepvars & regnames

	*--------------------------------------------------*
	*** time-invariant regressors ***
	loc regnum			: word count `regnames'
	if `regnum' > 0 {
		tempvar aux sd
		forv i = 1/`regnum' {
			loc var				: word `i' of `regnames'
			loc pos				= `i' + 1
			if `: list var in indepvars' {
				qui gen `aux' = `var' if `touse'
				qui by `_dta[_TSpanel]': egen `sd' = sd(`aux') if `touse'
				sum `sd' if `touse', mean
				if r(mean) == 0 {
					loc tiindepvars		"`tiindepvars' `var'"
					loc tiindeppos		"`tiindeppos' `pos'"
				}
				else {
					loc tvindeppos		"`tvindeppos' `pos'"
				}
				loc indeppos		"`indeppos' `pos'"
				drop `aux' `sd'
			}
			else {
				loc omitpos			"`omitpos' `pos'"
			}
		}
		loc tvindepvars		: list indepvars - tiindepvars
	}
	if "`constant'" == "" {
		loc regnames		"`regnames' _cons"
		loc pos				= `regnum' + 2
		if "`difference'" != "" {
			loc tiindepvars		"`tiindepvars' `touse'"
			loc omitpos			"`omitpos' `tiindeppos'"
			loc tiindeppos		"`pos'"
		}
		loc indeppos		"`indeppos' `pos'"
	}

	*--------------------------------------------------*
	*** first-differenced regressors ***
	if "`difference'" != "" & "`tvindepvars'" != "" {
		foreach var of loc tvindepvars {
			loc dtvindepvars	"`dtvindepvars' D.`var'"
		}
		tsunab dtvindepvars		: `dtvindepvars'
		sret loc dtvindepvars	"`: list retok dtvindepvars'"
	}

	sret loc omitpos		"`: list retok omitpos'"
	sret loc indeppos		"`: list retok indeppos'"
	sret loc tiindeppos		"`: list retok tiindeppos'"
	sret loc tvindeppos		"`: list retok tvindeppos'"
	sret loc regnames		"`regnames'"
	sret loc tiindepvars	"`: list retok tiindepvars'"
	sret loc tvindepvars	"`tvindepvars'"
	sret loc indepvars		"`indepvars'"
	sret loc depvar			"`depvar'"
end

*==================================================*
**** sample identification ****
program define xtdpdqml_sample, rclass
	version 12.1
	syntax varname(num) , GENerate(namelist max=2)

	gettoken touse0 dtouse : generate
	tempvar consec maxconsec obstotal
	qui gen `consec' = .
	qui by `_dta[_TSpanel]': replace `consec' = cond(L.`consec' == ., 1, L.`consec' + 1) if `varlist'
	qui by `_dta[_TSpanel]': egen `maxconsec' = max(`consec')
	qui by `_dta[_TSpanel]': egen `obstotal' = total(`varlist')
	capture xtdes if `varlist'
	if _rc == 459 {
		error 2000
	}
	loc N_g				= r(N)
	qui replace `varlist' = 0 if `maxconsec' != `obstotal'							// markout groups with gaps
	qui replace `varlist' = 0 if `obstotal' < 2										// markout groups with insufficient number of observations
	qui gen byte `touse0' = 0
	qui by `_dta[_TSpanel]': replace `touse0' = 1 if `varlist' & `consec' == 1		// marker variable for initial observations
	if "`dtouse'" != "" {
		qui gen byte `dtouse' = `varlist' - `touse0'								// marker variable for first-differenced equation
	}
	qui xtdes if `varlist'
	if r(N) != `N_g' {
		di as txt "note: " as res `N_g' - r(N) as txt " groups are dropped due to gaps or insufficient number of observations"
	}
	sum `obstotal' if `varlist', mean
	if r(N) == 0 {
		error 2000
	}
	ret sca maxlead		= r(min) - 1				// maximum number of leads for initial-observations regressors
end

*==================================================*
**** syntax parsing of additional options ****
program define xtdpdqml_parse, sclass
	version 12.1
	sret clear
	syntax [varlist(num ts default=none)] , MAXLead(integer) [noDIfference PROjection(string asis) *]

	loc difference		= ("`difference'" == "")
	if `"`projection'"' != "" {
		if `difference' {
			xtdpdqml_parse_fe_projection `projection'
			if "`s(dvarlist)'" != "" {
				loc exovars			"`s(dvarlist)'"
				sret loc varlist	"`exovars'"
			}
			else {
				loc exovars			"`s(varlist)'"
			}
		}
		else {
			xtdpdqml_parse_re_projection `projection'
			loc exovars			"`s(varlist)'"
		}
		if "`: list varlist & exovars'" != "" {
			di as err "option projection() incorrectly specified"
			exit 198
		}
		if `s(omit)' {
			loc lead			= .
		}
		else {
			loc lead			= min(`s(leads)', `maxlead')
		}
		forv i = 1 / `: word count `exovars'' {
			loc leads			"`leads' `lead'"
			if "`s(dvarlist)'" == "" & `difference' & !`s(difference)' {
				loc lags			"`lags' 1"
			}
			else {
				loc lags			"`lags' 0"
			}
		}
		sret loc leads		"`leads'"
		sret loc lags		"`lags'"
	}
	else {
		di as err `"`options' invalid"'
		exit 198
	}

	sret loc options	`"`options'"'
end

*==================================================*
**** syntax parsing for the fixed-effects projection variables ****
program define xtdpdqml_parse_fe_projection, sclass
	version 12.1
	syntax varlist(num ts) [,	Leads(numlist max=1 miss int >=0)		///
								noDIfference							///
								OMIT]									//

	if "`leads'" == "" {
		loc leads			= .
	}
	loc difference		= ("`difference'" == "")
	if `difference' {
		foreach var of loc varlist {
			loc dvarlist		"`dvarlist' D.`var'"
		}
		tsunab dvarlist		: `dvarlist'
	}

	sret loc omit		= ("`omit'" != "")
	sret loc difference	= `difference'
	sret loc leads		= `leads'
	sret loc dvarlist	"`dvarlist'"
	sret loc varlist	"`varlist'"
end

*==================================================*
**** syntax parsing for the random-effects projection variables ****
program define xtdpdqml_parse_re_projection, sclass
	version 12.1
	syntax varlist(num ts) [,	Leads(numlist max=1 miss int >=0)		///
								OMIT]									//

	if "`leads'" == "" {
		loc leads			= .
	}

	sret loc omit		= ("`omit'" != "")
	sret loc difference	= 0
	sret loc leads		= `leads'
	sret loc dvarlist	"`dvarlist'"
	sret loc varlist	"`varlist'"
end

*==================================================*
**** identification of the initial-observations variables ****
program define xtdpdqml_initvars, sclass
	version 12.1
	sret clear
	syntax varlist(num ts) [if] [in] , LEADs(numlist miss int >=0) [LAGs(numlist miss int >=0)]
	marksample dtouse0, nov

	loc initvars		"`varlist'"
	foreach var of loc varlist {
		loc pos				: list posof "`var'" in varlist
		loc lead			: word `pos' of `leads'
		if `lead' == . {
			loc initvars		: list initvars - var
		}
	}

	sum `dtouse0', mean
	loc N				= r(sum)
	loc varlist			""
	loc missing			= 0
	loc omitted			= 0
	foreach var of loc initvars {
		loc pos				: list posof "`var'" in initvars
		loc lead			= .
		while `lead' == . {
			loc lead			: word `= `pos' + `omitted'' of `leads'
			if `lead' == . {
				loc ++omitted
			}
			else if "`lags'" != "" {
				loc lag				: word `= `pos' + `omitted'' of `lags'
			}
			else {
				loc lag				= 0
			}
		}
		loc tsvarlist		""
		forv l = `= -(`lag' == 1)' / `lead' {
			sum F(`l').`var' if `dtouse0', mean
			if r(N) == `N' {
				loc tsvarlist		"`tsvarlist' F(`l').`var'"
			}
			else {
				loc missing			= 1
			}
		}
		qui _rmcoll `tsvarlist' if `dtouse0', force
		loc varlist			"`varlist' `r(varlist)'"
	}
	qui _rmcoll `varlist' if `dtouse0', force
	loc initvars		"`r(varlist)'"

	sret loc missing	= ("`: list varlist - initvars'" != "" | `missing')
	sret loc varlist	"`: list retok initvars'"
end

*==================================================*
*** version history ***
* version 1.4.3  26feb2017  estat serial now reports Arellano-Bond test; bug fixed in models without variables in the initial-observations equation
* version 1.4.2  14feb2017  covariance between constant term and other coefficients in FE model corrected
* version 1.4.1  12feb2017  option initnoeffects removed because of corner solution trap
* version 1.4.0  14jan2017  option initnoeffects added; postestimation command estat serial added
* version 1.3.1  08aug2016  Stata Journal version; degrees-of-freedom adjustment removed for standard error of the constant in FE model and initial variance estimates
* version 1.3.0  22may2016  xtdpd options lgmmiv() and twostep removed for initial GMM estimates; improved collinearity checks; projection() with subobtion nodifference adds further lag; additional display options
* version 1.2.4  04feb2016  improved help files
* version 1.2.3  28jan2016  Stata 12.1 required; bug with sample determination fixed for unbalanced panels with gaps; bug with prediction of scores in RE model fixed; help file viewer menues added
* version 1.2.2  29jun2015  bug with standard error computation fixed for the constant term in FE model; property xt added
* version 1.2.1  16jun2015  option scores for postestimation command predict added; separate equation for each ancillary parameter; bug with sample determination in RE model fixed; additional optimization results saved
* version 1.2.0  11jun2015  options vce(robust) and vce(opg) added; gradient vector saved in e(gradient); bug fixed when options noeffects and stationary are combined
* version 1.1.0  06jun2015  method(d1) and method(d2) compatible with all RE model specifications; bug in the RE log-likelihood formulation fixed
* version 1.0.4  24may2015  option noeffects added; bug with covariance matrix fixed related to option stationary in RE model
* version 1.0.3  23may2015  adjusted initialization for FE model with unbalanced panels; bugs fixed related to option stationary in RE model
* version 1.0.2  23apr2015  bug with postestimation command predict fixed that was introduced in version 1.0.1
* version 1.0.1  21apr2015  method(d2) compatible with option concentration in FE model; cleaned output display
* version 1.0.0  04apr2015  available online at www.kripfganz.de
* version 0.2.2  07feb2014
* version 0.2.1  23may2013
* version 0.2.0  21may2013
* version 0.1.3  13may2013
* version 0.1.2  15jan2013
* version 0.1.1  21dec2012
* version 0.1.0  17dec2012
* version 0.0.11 27apr2012
* version 0.0.10 10feb2012
* version 0.0.9  05dec2011
* version 0.0.8  02jun2011
* version 0.0.7  21may2011
* version 0.0.6  09may2011
* version 0.0.5  01may2011
* version 0.0.4  09apr2011
* version 0.0.3  21feb2011
* version 0.0.2  17jan2011
* version 0.0.1  08jan2011
