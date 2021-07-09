*! version 1.0.1  12sep2020
*! Sebastian Kripfganz, www.kripfganz.de
*! Jan F. Kiviet, sites.google.com/site/homepagejfk/

*==================================================*
****** Kinky least squares estimation ******

*** citation ***

/*	Kripfganz, S., and J. F. Kiviet. 2020.
	kinkyreg: Instrument-free inference for linear regression models with endogenous regressors.
	Manuscript submitted to the Stata Journal.		*/

*** version history at the end of the file ***

program define kinkyreg, eclass
	version 13.0
	if replay() {
		if "`e(cmd)'" != "kinkyreg" {
			error 301
		}
		kinkyreg_parse_display `0'
		loc diopts			`"`s(diopts)'"'
		loc 0				`", `s(options)'"'
		syntax , [CORRelation(numlist max=1 >=-1 <=1)]
		if "`correlation'" != "" {
			if `correlation' < e(grid_min) | `correlation' > e(grid_max) {
				di as err "correlation() invalid -- invalid number, outside of allowed range"
				exit 125
			}
			loc N_grid			= rowsof(e(b_kls))
			forv g = 1 / `N_grid' {
				loc corr			= e(grid_min) + (`g' - 1) * e(grid_step)
				if abs(`correlation' - `corr') <= e(grid_step) / 2 {
					tempname b V
					mat `b'				= e(b_kls)
					mat `b'				= `b'[`g', 1..`= colsof(`b')']
					cap conf mat e(V_`g')
					if _rc {
						error 301
					}
					mat `V'				= e(V_`g')
					eret repost b = `b' V = `V', resize
					eret sca corr		= `corr'
					continue, br
				}
			}
		}
		kinkyreg_display , `diopts'
	}
	else {
		syntax anything(id="varlist" equalok) [if] [in] [, *]
		kinkyreg_parse_display , `options'
		loc diopts			`"`s(diopts)'"'
		loc level			"`s(level)'"
		kinkyreg_init , `s(options)'
		loc mopt			"`s(mopt)'"
		kinkyreg_kls `anything' `if' `in', mopt(`mopt') `level' `s(options)'

		eret loc predict	"kinkyreg_p"
		eret loc estat_cmd	"kinkyreg_estat"
		eret loc cmdline 	`"kinkyreg `0'"'
		eret loc cmd		"kinkyreg"
// 		eret hidden loc mopt	"`mopt'"			// undocumented
		kinkyreg_display , `diopts'
	}
end

program define kinkyreg_kls, eclass
	version 13.0
	syntax anything(id="varlist" equalok) [if] [in] , MOPT(name) [	noCONStant									///
																	CONTrols(varlist num ts fv)					///
																	ENDOgeneity(numlist miss >=-1)				///
																	Range(numlist asc min=2 max=2 >=-1 <=1)		///
																	STEPsize(real 0.01)							///
																	EKurtosis(numlist max=1 >=1)				///
																	XKurtosis(numlist max=1 >=1)				///
																	SMall										///
																	INference(varlist num ts fv)				///
																	CORRelation(numlist max=1 >=-1 <=1)			///
																	Level(cilevel)								///
																	NAMEstub(name)								///
																	noGRaph										///
																	noVSTORE									///
																	*]											// parsed separately: LINCOM() TWoway() COEFPlot() CIPlot()
	kinkyreg_parse_varlist `anything'
	if `: word count `s(endovars)'' < 1 {
		di as err "too few endogenous variables specified"
		exit 102
	}
// 	if `: word count `s(endovars)'' > 1 {
// 		di as err "too many endogenous variables specified"
// 		exit 103
// 	}
	loc 0				`"`s(depvar)' `s(exovars)' `if' `in', endovars(`s(endovars)') ivvars(`s(ivvars)') `options'"'
	syntax varlist(num fv ts) [if] [in], [ENDOvars(varlist num fv ts) IVvars(varlist num fv ts) *]

	loc fv				= ("`s(fvops)'" == "true")
	if `fv' {
		fvexpand `varlist'
		loc varlist			"`r(varlist)'"
	}
	marksample touse
	markout `touse' `endovars' `ivvars'
	gettoken depvar exovars : varlist
	sum `touse', mean
	if r(sum) == 0 {
		error 2000
	}
	if `fv' {
		_fv_check_depvar `depvar'
// 		fvrevar `endovars' `exovars'
	}
	_rmdcoll `depvar' `exovars' if `touse', `constant'
	loc exovars			"`r(varlist)'"
	if "`controls'" != "" {
		_rmdcoll `depvar' `controls' if `touse', `constant'
		loc controls		"`r(varlist)'"
	}
	_rmdcoll `depvar' `endovars' if `touse', `constant'
	if r(k_omitted) {
		di as err "collinearity among endogenous variables"
		exit 459
	}
	foreach endovar in `endovars' {
		_rmdcoll `endovar' `exovars' `controls' if `touse', `constant'
	}
	mata: kinkyreg_init_touse(`mopt', "`touse'")		// marker variable
	tsrevar `depvar'
	mata: kinkyreg_init_depvar(`mopt', "`r(varlist)'")		// dependent variable
	mata: kinkyreg_init_indepvars(`mopt', 1, "`endovars'")		// endogenous independent variables
	mata: kinkyreg_init_indepvars(`mopt', 2, "`exovars'")		// exogenous independent and instrumental variables
	if "`controls'" != "" {
		mata: kinkyreg_init_indepvars(`mopt', 3, "`controls'")		// partialled-out exogenous independent variables
	}
	loc regnames		"`endovars' `exovars' `controls'"
	if "`constant'" != "" {
		mata: kinkyreg_init_cons(`mopt', "off")			// constant term
	}
	else {
		loc regnames		"`regnames' _cons"
	}
	loc K				: word count `regnames'

	*--------------------------------------------------*
	*** endogeneity correlations ***
	loc K_endo			: word count `endovars'
	if "`endogeneity'" != "" {
		if `: word count `endogeneity'' < `K_endo' {
			di as err "endogeneity() invalid -- invalid numlist has too few elements"
			exit 122
		}
		if `: word count `endogeneity'' > `K_endo' {
			di as err "endogeneity() invalid -- invalid numlist has too many elements"
			exit 123
		}
		tempname endocorr
		loc corrmiss		= 0
		forv k = 1 / `K_endo' {
			loc corr			: word `k' of `endogeneity'
			if `corr' > 1 & `corr' < . {
				di as err "endogeneity() invalid -- invalid numlist has elements outside of allowed range"
				exit 125
			}
			if `corr' >= . {
				if `corrmiss' {
					di as err "endogeneity() invalid -- invalid numlist has too many missing values"
					exit 121
				}
				loc klsvar			"`: word `k' of `endovars''"
				loc ++corrmiss
			}
			mat `endocorr'		= (nullmat(`endocorr'), `corr')
		}
		if !`corrmiss' {
			di as err "endogeneity() invalid -- invalid numlist has no missing value"
			exit 121
		}
		mat coln `endocorr'	= `endovars'
		mata: kinkyreg_init_corr(`mopt', st_matrix("`endocorr'"))
	}
	else if `K_endo' > 1 {
		di as err "option endogeneity() required"
		exit 198
	}
	else {
		loc klsvar		"`endovars'"
		mata: kinkyreg_init_corr(`mopt', .)
	}
	if "`range'" != "" {
		gettoken rangemin rangemax : range
		if `stepsize' <= epsfloat() | `stepsize' > `rangemax' - `rangemin' {
			di as err "stepsize() invalid -- invalid numnber, outside of allowed range"
			exit 125
		}
	}
	else {
		loc rangemin		= -1
		loc rangemax		= 1
	}
	mata: kinkyreg_init_grid(`mopt', (`rangemin', `stepsize', `rangemax'))
	if "`correlation'" != "" {
		if `correlation' < `rangemin' | `correlation' > `rangemax' {
			di as err "correlation() invalid -- invalid number, outside of allowed range"
			exit 125
		}
	}
	else {
		loc correlation		= .
	}

	*--------------------------------------------------*
	*** linear combinations ***
	kinkyreg_parse_lincom , `options'
	loc options			`"`s(options)'"'
	while `"`s(lincom)'"' != "" {
		loc lincomnums		"`lincomnums' `s(lincomnum)'"
		loc lincom`s(lincomnum)' `"`s(lincom)'"'
		kinkyreg_parse_lincom , `options'
		loc options			`"`s(options)'"'
	}
	if "`lincomnums'" != "" {
		tempname b_lincom C_lincom
		mat `b_lincom'		= J(1, `K', 0)
		mat coln `b_lincom'	= `regnames'
		eret post `b_lincom'
		foreach lincomnum of num `lincomnums' {
			cons free
			loc cons`lincomnum'	= `r(free)'
			cons de `cons`lincomnum'' `lincom`lincomnum'' = 0
			loc consnums		"`consnums' `cons`lincomnum''"
		}
		makecns `consnums', nocnsnote
		if "`r(clist)'" != "`: list retok consnums'" {
			cons drop `consnums''
			di as err "option lincom() incorrectly specified"
			exit 198
		}
		tempname aux1 aux2 C_lincom
		cap matcproc `aux1' `aux2' `C_lincom'
		mata: kinkyreg_init_lincom(`mopt', st_matrix("`C_lincom'"))
		if _rc {
			mat drop `C_lincom'
		}
		else {
			mat drop `aux1' `aux2' `C_lincom'
		}
		cons drop `consnums'
	}

	*--------------------------------------------------*
	*** kurtosis ***
	if "`ekurtosis'" != "" {
		mata: kinkyreg_init_ekurt(`mopt', `ekurtosis')
	}
	if "`xkurtosis'" != "" {
		mata: kinkyreg_init_xkurt(`mopt', `xkurtosis')
	}

	*--------------------------------------------------*
	*** graph options ***
	if "`inference'" == "" & "`lincomnums'" == "" {
		loc inference		"`endovars'"
	}
	else if !`: list inference in regnames' {
		di as err "option inference() incorrectly specified - `: list inference - regnames' not found"
		exit 198
	}
	while `"`options'"' != "" {
		kinkyreg_parse_options `inference' `lincomnums', `options'
		loc optname			"`s(varname)'"
		_ms_parse_parts `optname'
		if "`r(type)'" != "variable" | "`r(op)'" != "" {
			loc optname			: subinstr loc optname "." "_", all
			loc optname			: subinstr loc optname "#" "_", all
		}
		if `"`s(twopt)'"' != "" {
			loc twopt_`optname'	`"`twopt_`optname'' `s(twopt)'"'
			loc order_`optname'	"`s(order)'"
		}
		if `"`s(twname)'"' != "" {
			loc twname_`optname' `"`s(twname)'"'
		}
		if `"`s(addplot)'"' != "" {
			loc addplot_`optname' `"`s(addplot)'"'
			if "`s(before)'" != "" {
				loc addplot_before_`optname' "`s(before)'"
			}
		}
		if "`s(yrange)'" != "" {
			loc twrange_`optname' "`s(yrange)'"
		}
		if `"`s(coefopt)'"' != "" {
			loc coefopt_`s(estimator)'_`optname' `"`coefopt_`s(estimator)'_`optname'' `s(coefopt)'"'
		}
		else if `"`s(ciopt)'"' != "" {
			loc ciopt_`s(estimator)'_`optname' `"`ciopt_`s(estimator)'_`optname'' `s(ciopt)'"'
		}
		loc options			`"`s(options)'"'
	}
	if "`namestub'" == "" {
		loc namestub		"kinkyreg"
	}

	*--------------------------------------------------*
	*** IV estimation ***
	loc K_iv			: word count `ivvars'
	if `K_iv' {
		tempname b_iv se_iv
		qui ivregress 2sls `depvar' (`endovars' = `ivvars') `exovars' `controls' if `touse', `constant' `small' l(`level')

	mat `b_iv'			= e(b)
		mat `se_iv'			= vecdiag(e(V))
		mata: st_replacematrix("`se_iv'", sqrt(st_matrix("`se_iv'")))
		tempname mopt_iv
		if "`lincomnums'" != "" {
			foreach lincomnum of num `lincomnums' {
				qui lincom `lincom`lincomnum''
				loc b_iv_lincom`lincomnum' = r(estimate)
				loc se_iv_lincom`lincomnum' = r(se)
			}
		}
	}

	*--------------------------------------------------*
	*** KLS estimation ***
	mata: kinkyreg(`mopt')
	mata: st_numscalar("r(N)", kinkyreg_result_N(`mopt'))
	mata: st_numscalar("r(xkurtosis)", kinkyreg_result_xkurt(`mopt'))
	loc N				= r(N)
	loc xkurtosis		= r(xkurtosis)
	if `correlation' < . {
		tempname b V
	}
	tempname sigma2 ekurtosis b_kls se_kls
	if "`lincomnums'" != "" {
		tempname b_kls_lincom se_kls_lincom
	}
	mata: st_numscalar("r(N_grid)", kinkyreg_result_gridpoints(`mopt'))
	loc N_grid			= r(N_grid)
	loc rank			= 0
	loc miss			= 0
	loc j				= 1
	forv g = 1 / `N_grid' {
		mata: st_numscalar("r(rank)", kinkyreg_result_rank(`mopt', `g'))
		mata: st_numscalar("r(sigma2)", kinkyreg_result_sigma2(`mopt', `g'))
		mata: st_numscalar("r(ekurtosis)", kinkyreg_result_ekurt(`mopt', `g'))
		mata: st_matrix("r(b)", kinkyreg_result_coefs(`mopt', `g'))
		mata: st_matrix("r(V)", kinkyreg_result_V(`mopt', `g'))
		mata: st_matrix("r(corr)", kinkyreg_result_corr(`mopt', `g'))
		if missing(el(r(b), 1, 1)) {
			loc ++miss
			if "`gid'" == "" {
				loc rangemin		= `rangemin' + `stepsize'
			}
			continue
		}
		if "`vstore'" == "" {
			tempname V`j'
			mat `V`j''			= r(V)
			mat rown `V`j''		= `regnames'
			mat coln `V`j''		= `regnames'
		}
		loc corr			= el(r(corr), 1, 1)
		if missing(`correlation') {
			loc rank			= max(`rank', r(rank))
		}
		else if abs(`correlation' - `corr') <= `stepsize' / 2 {
			loc correlation		= `corr'
			mat `b'				= r(b)
			mat `V'				= r(V)
			loc rank			= r(rank)
			if "`small'" != "" {
				mat `V'				= `N' / (`N' - `rank') * `V'
			}
			mat coln `b'		= `regnames'
			mat rown `V'		= `regnames'
			mat coln `V'		= `regnames'
		}
		mat `b_kls'			= (nullmat(`b_kls') \ r(b))
		if "`small'" == "" {
			mat `se_kls'		= (nullmat(`se_kls') \ vecdiag(r(V)))
		}
		else {
			mat `se_kls'		= (nullmat(`se_kls') \ `N' / (`N' - r(rank)) * vecdiag(r(V)))
		}
		if "`lincomnums'" != "" {
			mata: st_matrix("r(b_lincom)", kinkyreg_result_lincom_coefs(`mopt', `g'))
			mata: st_matrix("r(V_lincom)", kinkyreg_result_lincom_V(`mopt', `g'))
			mat `b_kls_lincom'	= (nullmat(`b_kls_lincom') \ r(b_lincom))
			if "`small'" == "" {
				mat `se_kls_lincom'	= (nullmat(`se_kls_lincom') \ vecdiag(r(V_lincom)))
			}
			else {
				mat `se_kls_lincom'	= (nullmat(`se_kls_lincom') \ `N' / (`N' - r(rank)) * vecdiag(r(V_lincom)))
			}
		}
		mat `sigma2'		= (nullmat(`sigma2') \ r(sigma2))
		mat `ekurtosis'		= (nullmat(`ekurtosis') \ r(ekurtosis))
		if c(stata_version) < 14 {
			loc gid				"`gid' `j'"
		}
		else {
			loc gid				"`gid' `: di %5.4f `corr''"
		}
		loc ++j
	}
	loc N_grid			= `N_grid' - `miss'
	loc rangemax		= `corr'
	mata: st_replacematrix("`se_kls'", sqrt(st_matrix("`se_kls'")))
	mat rown `b_kls'	= `gid'
	mat coln `b_kls'	= `regnames'
	mat rown `se_kls'	= `gid'
	mat coln `se_kls'	= `regnames'
	if "`lincomnums'" != "" {
		mata: st_replacematrix("`se_kls_lincom'", sqrt(st_matrix("`se_kls_lincom'")))
		mat rown `b_kls_lincom' = `gid'
		mat coln `b_kls_lincom' = `lincomnums'
		mat rown `se_kls_lincom' = `gid'
		mat coln `se_kls_lincom' = `lincomnums'
	}
	mat rown `sigma2'	= `gid'
	mat rown `ekurtosis' = `gid'

	*--------------------------------------------------*
	*** KLS graphs ***
	if "`graph'" == "" {
		tempvar gridrange b1_kls b1_ukls b1_lkls
		qui gen `gridrange' = `rangemin' + (_n - 1) * `stepsize' in 1 / `N_grid'
		la var `gridrange' "postulated endogeneity of `klsvar'"
		qui gen double `b1_kls' = .
		la var `b1_kls' "KLS estimate"
		qui gen double `b1_ukls' = .
		la var `b1_ukls' "KLS >=`level'% CI"
		qui gen double `b1_lkls' = .
		la var `b1_lkls' "KLS >=`level'% CI"
		if "`small'" == "" {
			loc critval			= invnormal((100 + `level') / 200)
		}
		else {
			loc critval			= invt(`N' - `rank', (100 + `level') / 200)
		}
		if "`inference'" != "" {
			foreach var in `inference' {
				loc varpos			: list posof "`var'" in regnames
				loc varname			"`var'"
				_ms_parse_parts `var'
				if "`r(type)'" != "variable" | "`r(op)'" != "" {
					loc var				: subinstr loc var "." "_", all
					loc var				: subinstr loc var "#" "_", all
				}
				if "`twrange_'" != "" & "`twrange_`var''" == "" {
					loc twrange_`var'	"`twrange_'"
				}
				if "`twrange_`var''" != "" {
					loc twif_`var'		"if inrange(`b1_ukls', `twrange_`var'') & inrange(`b1_lkls', `twrange_`var'')"
				}
				mata: st_store((1, `N_grid'), "`b1_kls'", st_matrix("`b_kls'")[., `varpos'])
				mata: st_store((1, `N_grid'), "`b1_ukls'", st_matrix("`b_kls'")[., `varpos'] + `critval' * st_matrix("`se_kls'")[., `varpos'])
				mata: st_store((1, `N_grid'), "`b1_lkls'", st_matrix("`b_kls'")[., `varpos'] - `critval' * st_matrix("`se_kls'")[., `varpos'])
				loc tw_kls			"line `b1_kls' `gridrange' `twif_`var'', `coefopt_kls_' `coefopt_kls_`var''"
				loc tw_kls_ci		"rarea `b1_ukls' `b1_lkls' `gridrange' `twif_`var'', asty(ci) `ciopt_kls_' `ciopt_kls_`var''"
				if `K_iv' {
					tempvar b1_iv b1_uiv b1_liv
					qui gen double `b1_iv' = el(`b_iv', 1, `varpos') in 1 / `N_grid'
					la var `b1_iv' "IV estimate"
					qui gen double `b1_uiv' = el(`b_iv', 1, `varpos') + `critval' * el(`se_iv', 1, `varpos') in 1 / `N_grid'
					la var `b1_uiv' "IV `level'% CI"
					qui gen double `b1_liv' = el(`b_iv', 1, `varpos') - `critval' * el(`se_iv', 1, `varpos') in 1 / `N_grid'
					la var `b1_liv' "IV `level'% CI"
					if "`twrange_`var''" == "" {
						loc twif_`var'		"if `b1_kls' < ."
					}
					else {
						loc twif_`var'		"if inrange(`b1_uiv', `twrange_`var'') & inrange(`b1_liv', `twrange_`var'') & `b1_kls' < ."
					}
					loc tw_iv			"line `b1_iv' `gridrange' `twif_`var'', `coefopt_iv_' `coefopt_iv_`var''"
					loc tw_iv_ci		"rarea `b1_uiv' `b1_liv' `gridrange' `twif_`var'', asty(ci2) `ciopt_iv_' `ciopt_iv_`var''"
				}
				if `"`twname_`var''"' == "" {
					loc twname_`var'	"name(`namestub'_`var', replace)"
				}
				if "`order_`var''" == "" {
					loc order_`var'		= cond("`order_'" == "", "iv_ci kls_ci iv kls", "`order_'")
				}
				loc tw				""
				foreach twplot in `order_`var'' {
					if "`addplot_before_'" == "`twplot'" | "`addplot_before_`var''" == "`twplot'" {
						loc tw				`"`tw' `addplot_' || `addplot_`var'' ||"'
					}
					loc tw				`"`tw' `tw_`twplot'' ||"'
				}
				if "`addplot_'" != "" & "`addplot_before_'" == "" {
					loc tw				`"`tw' `addplot_' ||"'
				}
				if "`addplot_`var''" != "" & "`addplot_before_`var''" == "" {
					loc tw				`"`tw' `addplot_`var'' ||"'
				}
				tw `tw', yti("`varname' coefficient estimate") `twopt_' `twopt_`var'' `twname_`var''
			}
		}
		if "`lincomnums'" != "" {
			loc j				= 0
			foreach lincomnum of num `lincomnums' {
				loc ++j
				if "`twrange_'" != "" & "`twrange_`lincomnum''" == "" {
					loc twrange_`lincomnum'	"`twrange_'"
				}
				if "`twrange_`lincomnum''" != "" {
					loc twif_`lincomnum'		"if inrange(`b1_ukls', `twrange_`lincomnum'') & inrange(`b1_lkls', `twrange_`lincomnum'')"
				}
				mata: st_store((1, `N_grid'), "`b1_kls'", st_matrix("`b_kls_lincom'")[., `j'])
				mata: st_store((1, `N_grid'), "`b1_ukls'", st_matrix("`b_kls_lincom'")[., `j'] + `critval' * st_matrix("`se_kls_lincom'")[., `j'])
				mata: st_store((1, `N_grid'), "`b1_lkls'", st_matrix("`b_kls_lincom'")[., `j'] - `critval' * st_matrix("`se_kls_lincom'")[., `j'])
				loc tw_kls			"line `b1_kls' `gridrange' `twif_`lincomnum'', `coefopt_kls_' `coefopt_kls_`lincomnum''"
				loc tw_kls_ci		"rarea `b1_ukls' `b1_lkls' `gridrange' `twif_`lincomnum'', asty(ci) `ciopt_kls_' `ciopt_kls_`lincomnum''"
				if `K_iv' {
					tempvar b1_iv b1_uiv b1_liv
					qui gen double `b1_iv' = `b_iv_lincom`lincomnum'' in 1 / `N_grid'
					la var `b1_iv' "IV estimate"
					qui gen double `b1_uiv' = `b_iv_lincom`lincomnum'' + `critval' * `se_iv_lincom`lincomnum'' in 1 / `N_grid'
					la var `b1_uiv' "IV `level'% CI"
					qui gen double `b1_liv' = `b_iv_lincom`lincomnum'' - `critval' * `se_iv_lincom`lincomnum'' in 1 / `N_grid'
					la var `b1_liv' "IV `level'% CI"
					if "`twrange_`lincomnum''" == "" {
						loc twif_`lincomnum'		"if `b1_kls' < ."
					}
					else {
						loc twif_`lincomnum'		"if inrange(`b1_uiv', `twrange_`lincomnum'') & inrange(`b1_liv', `twrange_`lincomnum'') & `b1_kls' < ."
					}
					loc tw_iv			"line `b1_iv' `gridrange' `twif_`lincomnum'', `coefopt_iv_' `coefopt_iv_`lincomnum''"
					loc tw_iv_ci		"rarea `b1_uiv' `b1_liv' `gridrange' `twif_`lincomnum'', asty(ci2) `ciopt_iv_' `ciopt_iv_`lincomnum''"
				}
				if `"`twname_`lincomnum''"' == "" {
					loc twname_`lincomnum'	"name(`namestub'_`lincomnum', replace)"
				}
				if "`order_`lincomnum''" == "" {
					loc order_`lincomnum' = cond("`order_'" == "", "iv_ci kls_ci iv kls", "`order_'")
				}
				loc tw				""
				foreach twplot in `order_`lincomnum'' {
					if "`addplot_before_`lincomnum''" == "`twplot'" {
						loc tw				`"`tw' `addplot_`lincomnum'' ||"'
					}
					loc tw				`"`tw' `tw_`twplot'' ||"'
				}
				if "`addplot_`lincomnum''" != "" & "`addplot_before_`lincomnum''" == "" {
					loc tw				`"`tw' `addplot_`lincomnum'' ||"'
				}
				tw `tw', yti("lincom `lincomnum' estimate") `twopt_' `twopt_`lincomnum'' `twname_`lincomnum''
			}
		}
	}

	*--------------------------------------------------*
	*** current estimation results ***
	if "`small'" != "" {
		loc small			"dof(`= `N' - `rank'')"
	}
	if `fv' {
		loc fvopt			"buildfv"
	}
	if `correlation' < . {
		eret post `b' `V', dep(`depvar') o(`N') `small' e(`touse') `fvopt' findomitted
	}
	else {
		eret post, dep(`depvar') o(`N') `small' e(`touse')
	}
	eret sca rank		= `rank'
	eret sca xkurtosis	= `xkurtosis'
	eret sca grid_min	= `rangemin'
	eret sca grid_max	= `rangemax'
	eret sca grid_step	= `stepsize'
	if `correlation' < . {
		eret sca corr		= `correlation'
	}
	eret loc namestub	"`namestub'"
	if "`constant'" == "" {
		loc controls		"`controls' _cons"
	}
	eret loc ivvars		"`ivvars'"
	eret loc controls	"`: list retok controls'"		// undocumented
	eret loc exovars	"`: list retok exovars'"
	eret loc endovars	"`endovars'"
	eret loc klsvar		"`klsvar'"
	eret mat ekurtosis	= `ekurtosis'
	eret mat sigma2e	= `sigma2'
	if `K_endo' > 1 {
		eret mat endogeneity = `endocorr'
	}
	eret mat se_kls		= `se_kls'
	eret mat b_kls		= `b_kls'

	*--------------------------------------------------*
	*** hidden estimation results ***
	if "`vstore'" == "" {
		forv g = 1 / `N_grid' {
			eret hidden mat V_`g' = `V`g''
		}
	}
end

*==================================================*
**** display of estimation results ****
program define kinkyreg_display
	version 13.0
	syntax [, noOMITted noHEader noTABle *]

	if "`header'" == "" {
		di _n as txt "Kinky least squares estimation" _col(51) as txt "Number of obs" _col(67) "=" _col(69) as res %10.0f e(N)
	}
	if e(corr) < . & "`table'" == "" {
		di _n as txt "Postulated endogeneity of `e(klsvar)' = " %5.4f e(corr)
		_coef_table, `options'
	}
// 	if "`footnote'" == "" {
// 		di as txt "Variables partialled out:"
// 		loc p				= 1
// 		loc piece			: piece 1 77 of "`e(controls)'", nobreak
// 		while "`piece'" != "" {
// 			di _col(2) "`piece'"
// 			loc ++p
// 			loc piece			: piece `p' 77 of "`e(controls)'", nobreak
// 		}
// 	}
end

*==================================================*
**** syntax parsing of additional display options ****
program define kinkyreg_parse_display, sclass
	version 13.0
	sret clear
	syntax , [noHEader noTABle PLus Level(cilevel) *]
	_get_diopts diopts options, level(`level') `options'

	sret loc diopts		`"`header' `table' `plus' `diopts'"'
	sret loc level		"level(`level')"
	sret loc options	`"`options'"'
end

*==================================================*
**** syntax parsing of the optimization options ****
program define kinkyreg_init, sclass
	version 13.0
	sret clear
	syntax [, *]

	loc mopt			"kinkyreg_kls"
	mata: `mopt' = kinkyreg_init()

	sret loc mopt		"`mopt'"
	sret loc options	`"`options'"'
end

*==================================================*
**** syntax parsing of the variable list ****
// (inspired by _iv_parse.ado)
program define kinkyreg_parse_varlist, sclass
	version 13.0
	gettoken depvar 0 : 0, p(" ,[") m(paren) bind

	if inlist(`"`depvar'"', "[", ",", "if", "in") | `"`depvar'"' == "" {
		error 198
	}
	_fv_check_depvar `depvar'
	gettoken var 0 : 0, p(" ,[") m(paren) bind
	while !inlist(`"`var'"', "[", ",", "if", "in") & `"`var'"' != "" {
		if "`paren'" == "(" {
			if `"`endovars'"' != "" | `"`ivvars'"' != "" {
				error 198
			}
			gettoken endovar var : var, parse(" =") bind
			while `"`endovar'"' != "" & `"`endovar'"' != "=" {
				loc endovars		`"`endovars' `endovar'"'
				gettoken endovar var : var, parse(" =") bind
			}
			loc ivvars			`"`var'"'
		}
		else {
			loc exovars			`"`exovars' `var'"'
		}
		gettoken var 0 : 0, p(" ,[") m(paren) bind
	}

	sret loc rest		`"`0'"'
	sret loc ivvars		`"`: list retok ivvars'"'
	sret loc endovars	`"`: list retok endovars'"'
	sret loc exovars	`"`: list retok exovars'"'
	sret loc depvar		`"`depvar'"'
end

*==================================================*
**** syntax parsing of linear combinations ****
program define kinkyreg_parse_lincom, sclass
	version 13.0
	sret clear
	syntax , [LINCOM(string asis) *]

	if `"`lincom'"' != "" {
		gettoken lincomnum lincom : lincom, parse(":")
		cap conf integer n `lincomnum'
		if _rc {
			di as err "option lincom() incorrectly specified"
			exit 198
		}
		if `lincomnum' < 0 {
			di as err "option lincom() incorrectly specified"
			exit 198
		}
		gettoken colon lincom : lincom, parse(":")
		if `"`colon'"' != ":" {
			di as err "option lincom() incorrectly specified"
			exit 198
		}

		sret loc lincomnum	= `lincomnum'
		sret loc lincom		`"`lincom'"'
	}

	sret loc options	`"`options'"'
end

*==================================================*
**** syntax parsing of graph options ****
program define kinkyreg_parse_options, sclass
	version 13.0
	sret clear
	syntax anything(id="plot identifier"), [TWoway(string asis) COEFPlot(string asis) CIPlot(string asis) *]

	if `"`twoway'"' != "" {
		kinkyreg_parse_twoway `twoway'
		loc twvar			`"`s(varname)'"'
		if !`: list twvar in anything' {
			di as err `"option twoway() incorrectly specified -- `twvar' not found"'
			exit 198
		}
		if `"`ciplot'"' != "" {
			loc options			`"ciplot(`ciplot') `options'"'
		}
		if `"`coefplot'"' != "" {
			loc options			`"coefplot(`coefplot') `options'"'
		}
	}
	else {
		if `"`coefplot'"' != "" {
			kinkyreg_parse_coefplot `coefplot'
			loc coefvar			`"`s(varname)'"'
			if !`: list coefvar in anything' {
				di as err `"option coefplot() incorrectly specified -- `coefvar' not found"'
				exit 111
			}
			if `"`ciplot'"' != "" {
				loc options			`"ciplot(`ciplot') `options'"'
			}
		}
		else {
			if `"`ciplot'"' != "" {
				kinkyreg_parse_ciplot `ciplot'
			}
			else if `"`options'"' != "" {
				di as err `"`options' invalid"'
				exit 198
			}
		}
	}

	sret loc options	`"`options'"'
end

*==================================================*
**** syntax parsing of twoway graph options ****
program define kinkyreg_parse_twoway, sclass
	version 13.0
	syntax [anything(id="plot identifier")], [	NAME(passthru)							///
												SAVING(passthru)						///
												ORDER(string)							///
												ADDPLOT(string asis)					///
												YRANGE(numlist miss min=2 max=2)		///
												*]

	gettoken varname anything : anything
	if `"`: list retok anything'"' != "" | (`"`varname'"' == "" & (`"`name'"' != "" | `"`saving'"' != "")) {
		di as err "option twoway() incorrectly specified"
		exit 198
	}
	if "`order'" != "" {
		loc dups			: list dups order
		if "`dups'" != "" {
			di as err "option order() incorrectly specified"
			exit 198
		}
		foreach twplot in `order' {
			if !inlist("`twplot'", "kls", "kls_ci", "iv", "iv_ci") {
				di as err "option order() incorrectly specified"
				exit 198
			}
		}
	}
	if `"`addplot'"' != "" {
		kinkyreg_parse_twoway_addplot `addplot'
	}

	if "`yrange'" != "" {
		loc yrange1			: word 1 of `yrange'
		loc yrange2			: word 2 of `yrange'
		if `yrange1' < . & `yrange1' > `yrange2' {
			di as err "yrange() invalid -- invalid numlist has elements out of order)
			exit 124"
		}
		sret loc yrange		"`yrange1', `yrange2'"
	}

	sret loc varname	`"`varname'"'
	sret loc twname		`"`name'"'
	sret loc twopt		`"`saving' `options'"'
	sret loc order		"`order'"
end

*==================================================*
**** syntax parsing of addplot option ****
program define kinkyreg_parse_twoway_addplot, sclass
	version 13.0
	syntax anything(id="graph twoway plot"), [BEFORE(name local) *]

	if "`before'" != "" {
		if !inlist("`before'", "kls", "kls_ci", "iv", "iv_ci") {
			di as err "option before() incorrectly specified"
			exit 198
		}
	}
	if `"`options'"' != "" {
		loc anything		`"`anything', `options'"'
	}

	sret loc before		"`before'"
	sret loc addplot	`"`anything'"'
end

*==================================================*
**** syntax parsing of graph options for coefficient plots ****
program define kinkyreg_parse_coefplot, sclass
	version 13.0
	syntax anything(id="plot identifier"), [*]

	gettoken estimator varname : anything
	if !inlist(`"`estimator'"', "kls", "iv") {
		di as err `"option coefplot() incorrectly specified -- `estimator' invalid"'
		exit 198
	}

	sret loc varname	`"`: list retok varname'"'
	sret loc estimator	"`estimator'"
	sret loc coefopt	`"`options'"'
end

*==================================================*
**** syntax parsing of graph options for confidence interval plots ****
program define kinkyreg_parse_ciplot, sclass
	version 13.0
	syntax anything(id="plot identifier"), [*]

	gettoken estimator varname : anything
	if !inlist(`"`estimator'"', "kls", "iv") {
		di as err `"option ciplot() incorrectly specified -- `estimator' invalid"'
		exit 198
	}

	sret loc varname	`"`: list retok varname'"'
	sret loc estimator	"`estimator'"
	sret loc ciopt		`"`options'"'
end

*==================================================*
*** version history ***
* version 1.0.1  12sep2020  updated reference in the help files
* version 1.0.0  10sep2020  available online at www.kripfganz.de
* version 0.2.0  01sep2020
* version 0.1.5  15aug2020
* version 0.1.4  09jun2020
* version 0.1.3  02jun2020
* version 0.1.2  01jun2020
* version 0.1.1  29may2020
* version 0.1.0  28apr2020
* version 0.0.6  17apr2020
* version 0.0.5  15feb2020
* version 0.0.4  13feb2020
* version 0.0.3  27nov2019
* version 0.0.2  20nov2019
* version 0.0.1  08oct2019
