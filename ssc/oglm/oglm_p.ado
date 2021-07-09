*! version 2.3.0 30aug2016  Richard Williams, rwilliam@nd.edu

* Adapted from ologit_p version 1.2.5  30mar2005
program define oglm_p 
	version 9, missing
	// link gives link fnc used.  oglmx = 1 if there are x vars,
	// 0 if not.  oglmh = 1 if there arw hetero vars, 0 otherwise.  
	// This info is needed for computing probabilities and/or scores.
	macro drop oglmx oglmh Link dv_*
	local link `e(link)'
	local oglmx = "`e(xvars)'" != ""
	local oglmh = "`e(hetero)'" != ""

//Parse.

	syntax [anything] [if] [in] [, * ]
	if index(`"`anything'"',"*") {
		ParseNewVars `0'
		local varspec `s(varspec)'
		local varlist `s(varlist)'
		local typlist `s(typlist)'
		local if `"`s(if)'"'
		local in `"`s(in)'"'
		local options `"`s(options)'"'
	}
	else {
		local varspec `anything'
		syntax [newvarlist] [if] [in] [, * ]
	}
	local nvars : word count `varlist'

	ParseOptions, `options'
	local type `s(type)'
	local outcome `s(outcome)'
	if "`type'" != "" {
		local `type' `type'
	}
	else {
		if `"`outcome'"' != "" {
			di in gr "(option pr assumed; predicted probability)"
		}
		else {
			di in gr "(option pr assumed; predicted probabilities)"
		}
	}
	version 6, missing

// Check syntax.

	if `nvars' > 1 {
		MultVars `varlist'
		if `"`outcome'"' != "" {
			di as err ///
"option outcome() is not allowed when multiple new variables are specified"
			exit 198
		}
	}
	else if inlist("`type'","","pr","scores") & `"`outcome'"' == "" {
		local outcome "#1"
	}
	else if !inlist("`type'","","pr","scores") & `"`outcome'"' != "" {
		di in smcl as err ///
"{p 0 0 2}option outcome() cannot be specified with option `type'{p_end}"
		exit 198
	}

// scores - this section modified for oglm. Other score-related code was dropped.

	if `"`type'"' == "scores" {
		// Need to recreate global macros
		global Link `link'
		global oglmh `oglmh'
		global oglmx `oglmx'
		tempname ycat
		matrix `ycat' = e(cat)
		forval i = 1/`e(k_cat)' {
			global dv_`i' = `ycat'[1, `i']
		}
	        ml_p `0'
	        macro drop Link dv_* oglmh oglmx
		sret clear
		exit
	}

// sigma - this code adapted from hetpr_p to use for oglm

	if "`type'"=="sigma" {
		if !`oglmh' {
			display as error "Warning! All values are missing " ///
				"because there was no hetero/scale equation"
			gen `typlist' `varlist' = . `if' `in'
		}
		else {
			tempvar lnvar
			_predict double `lnvar' `if' `in', xb eq(#`=e(k_eq_model)')
			qui gen `typlist' `varlist' = exp(`lnvar')
			label var `varlist' "Sigma"
		}
		exit
	}


// Index, XB, or STDP - has oglm modifications

	if "`type'"=="index" | "`type'"=="xb" | "`type'"=="stdp" {

		Onevar `type' `varlist'
		
		// If no X vars, i.e. no Location equation, the xb and stdp
		// predicted values will just be missing - same as in ologit
		// when you have a constant-only model

		if `oglmx' | ("`e(offset)'"!="" & "`offset'"=="") {
			_predict `typlist' `varlist' `if' `in', `type' `offset'
		}
		else	{
			display as error "Warning! All values are missing because " ///
				"there was no location equation, i.e. no X variables"
			gen `typlist' `varlist' = . `if' `in'
		}

		if "`type'"=="index" | "`type'"=="xb"  {
			label var `varlist' /*
			*/ "Linear prediction (cutpoints excluded)"
		}
		else { /* stdp */
			label var `varlist' /*
			*/ "S.E. of linear prediction (cutpoints excluded)"
		}
		exit
	}

// If here we compute probabilities.  Do general preliminaries. Modified for oglm

	local cut "/cut" /* _b[/cut1] */

	if "`link'"=="logit"  {
		local func  "invlogit(-("
		local funcn "invlogit(("
	}
	else if "`link'"=="probit" {
		local func  "normprob(-("
		local funcn "normprob(("
	}
	else if "`link'"=="cloglog" {
		local func "(1 - invcloglog("
		local funcn "invcloglog(("
	}
	else if "`link'"=="loglog" {
		local func "invcloglog(-("
		local funcn "1 - invcloglog(-("
	}
	else if "`link'"=="cauchit" {
		local func "(.5 + (1/_pi) * atan(-"
		local funcn "(1 - .5 - (1/_pi) * atan(-"
	}
	else if "`link'"=="log" {
		local func "(1-exp("
		local funcn "exp(("
	}
	else {
		display as error "link `link' is not supported"
		exit 198
	}


	tempvar touse
	mark `touse' `if' `in'

	// If no Xs, i.e. no location equation, we just set xb to 0, otherwise
	// we compute the predicted value.
	if `oglmx' | ("`e(offset)'"!="" & "`offset'"=="") {
		tempvar xb
		qui _predict double `xb' if `touse', xb `offset'
	}
	else	local xb 0

// Probability with outcome() specified: create one variable. modified for oglm

	if ("`type'"=="pr" | "`type'"=="") & `"`outcome'"'!="" {
		Onevar "p with outcome()" `varlist'
		
		// Adjust for hetero if necessary
		if `oglmh' {
			tempvar lnsigma sigma
			quietly _predict double `lnsigma' if `touse', xb eq(#`=e(k_eq_model)')
			quietly gen double `sigma' = exp(`lnsigma') if `touse'
		}
		else {
			local lnsigma = 0
			local sigma = 1
		}

		Eq `outcome'
		local i `s(icat)'
		local im1 = `i' - 1
		sret clear

		if `i' == 1 {
			gen `typlist' `varlist' = /*
			*/ `func'(`xb'-_b[`cut'1])/`sigma')) /*
			*/ if `touse'
		}
		else if `i' < e(k_cat) {
			gen `typlist' `varlist' = /*
			*/   `func'(`xb'-_b[`cut'`i'])/`sigma')) /*
			*/ - `func'(`xb'-_b[`cut'`im1'])/`sigma')) /*
			*/ if `touse'
		}
		else {
			gen `typlist' `varlist' = /*
			*/ `funcn'(`xb'-_b[`cut'`im1'])/`sigma')) /*
			*/ if `touse'
		}

		local val = el(e(cat),1,`i')
		label var `varlist' "Pr(`e(depvar)'==`val')"
		exit
	}

// Probabilities with outcome() not specified: create e(k_cat) variables. modified for oglm

	tempname miss
	local same 1
	mat `miss' = J(1,`e(k_cat)',0)
		// Adjust for hetero if necessary
		if `oglmh' {
			tempvar lnsigma sigma
			quietly _predict double `lnsigma' if `touse', xb eq(#`=e(k_eq_model)')
			quietly gen double `sigma' = exp(`lnsigma') if `touse'
		}
		else {
			local lnsigma = 0
			local sigma = 1
		}

	quietly {
		local i 1
		while `i' <= e(k_cat) {
			local typ : word `i' of `typlist'
			tempvar p`i'
			local im1 = `i' - 1

			if `i' == 1 {
				gen `typ' `p`i'' = /*
				*/ `func'(`xb'-_b[`cut'1])/`sigma')) /*
				*/ if `touse'
			}
			else if `i' < e(k_cat) {
				gen `typ' `p`i'' = /*
				*/   `func'(`xb'-_b[`cut'`i'])/`sigma')) /*
				*/ - `func'(`xb'-_b[`cut'`im1'])/`sigma')) /*
				*/ if `touse'
			}
			else {
				gen `typ' `p`i'' = /*
				*/ `funcn'(`xb'-_b[`cut'`im1'])/`sigma')) /*
				*/ if `touse'
			}

		/* Count # of missings. */

			count if `p`i''>=.
			mat `miss'[1,`i'] = r(N)
			if `miss'[1,`i']!=`miss'[1,1] {
				local same 0
			}

		/* Label variable. */

			local val = el(e(cat),1,`i')
			label var `p`i'' "Pr(`e(depvar)'==`val')"

			local i = `i' + 1
		}
	}

	tokenize `varlist'
	local i 1
	while `i' <= e(k_cat) {
		rename `p`i'' ``i''
		local i = `i' + 1
	}
	ChkMiss `same' `miss' `varlist'
end

program MultVars
	syntax [newvarlist]
	local nvars : word count `varlist'
	if `nvars' != e(k_cat) {
		capture noisily error cond(`nvars'<e(k_cat), 102, 103)
		di in red /*
		*/ "`e(depvar)' has `e(k_cat)' outcomes and so you " /*
		*/ "must specify `e(k_cat)' new variables, or " _n /*
		*/ "you can use the outcome() option and specify " /*
		*/ "variables one at a time"
		exit cond(`nvars'<e(k_cat), 102, 103)
	}
end

program define ChkMiss
	args same miss
	macro shift 2
	if `same' {
		SayMiss `miss'[1,1]
		exit
	}
	local i 1
	while `i' <= e(k_cat) {
		SayMiss `miss'[1,`i'] ``i''
		local i = `i' + 1
	}
end

program define SayMiss
	args nmiss varname
	if `nmiss' == 0 { exit }
	if "`varname'"!="" {
		local varname "`varname': "
	}
	if `nmiss' == 1 {
		di in blu "(`varname'1 missing value generated)"
		exit
	}
	local nmiss = `nmiss'
	di in blu "(`varname'`nmiss' missing values generated)"
end

program define Eq, sclass
	sret clear
	local out = trim(`"`0'"')
	if substr(`"`out'"',1,1)=="#" {
		local out = substr(`"`out'"',2,.)
		Chk confirm integer number `out'
		Chk assert `out' >= 1
		capture assert `out' <= e(k_cat)
		if _rc {
			di in red "there is no outcome #`out'" _n /*
			*/ "there are only `e(k_cat)' categories"
			exit 111
		}
		sret local icat `"`out'"'
		exit
	}

	Chk confirm number `out'
	local i 1
	while `i' <= e(k_cat) {
		if `out' == el(e(cat),1,`i') {
			sret local icat `i'
			exit
		}
		local i = `i' + 1
	}

	di in red `"outcome `out' not found"'
	Chk assert 0 /* return error */
end

program define Chk
	capture `0'
	if _rc {
		di in red "outcome() must either be a value of `e(depvar)'," /*
		*/ _n "or #1, #2, ..."
		exit 111
	}
end

program define Onevar
	gettoken option 0 : 0
	local n : word count `0'
	if `n'==1 { exit }
	di in red "option `option' requires that you specify 1 new variable"
	error cond(`n'==0,102,103)
end

program ParseNewVars, sclass
	version 9, missing
	syntax [anything(name=vlist)] [if] [in] [, * ]

	if missing(e(version)) {
		local old oldologit
	}
	_score_spec `vlist', `old'
	sreturn local varspec `vlist'
	sreturn local if	`"`if'"'
	sreturn local in	`"`in'"'
	sreturn local options	`"`options'"'
end

program ParseOptions, sclass
// sigma option added for oglm
	version 9, missing
	syntax [,			///
		Outcome(string)		///
		EQuation(string)	///
		Index			///
		XB			///
		STDP			///
		Pr			///
		noOFFset		///
		SCores			///
		SCore(string)		///
		Sigma			///
	]

	// check options that take arguments
	if `"`equation'"' != "" & `"`score'"' != "" {
		di as err ///
		"options score() and equation() may not be combined"
		exit 198
	}
	if `"`score'"' != "" & `"`outcome'"' != "" {
		di as err ///
		"options score() and outcome() may not be combined"
		exit 198
	}
	if `"`equation'"' != "" & `"`outcome'"' != "" {
		di as err ///
		"options equation() and outcome() may not be combined"
		exit 198
	}
	local eq `"`score'`equation'`outcome'"'

	// check switch options
	local type `index' `xb' `stdp' `pr' `scores' `sigma'
	if `:word count `type'' > 1 {
		local type : list retok type
		di as err "the following options may not be combined: `type'"
		exit 198
	}
	if !inlist("`type'","","scores") & `"`score'"' != "" {
		di as err "options `type' and score() may not be combined"
		exit 198
	}
	if `"`score'"' != "" {
		local scores scores
	}

	// save results
	sreturn clear
	sreturn local type	`type'
	sreturn local outcome	`"`eq'"'
end


