*! svrologit_p
*! Prediction for svrmodel with cmd(ologit) or cmd(oprobit)
*! Nicholas Winter version 1.0.0  31mar2004
*  Modified from official Stata's ologit_p, version 1.1.2  21oct2003

program define svrologit_p 
	version 6

/* Parse. */

	syntax newvarlist [if] [in] [, Outcome(string) /*
	*/ Index XB STDP Pr noOFFset ]

/* Check syntax. */

	local nopt : word count `index' `xb' `stdp' `pr'
	if `nopt' > 1 {
		di in red "only one of p, xb, or stdp can be specified"
		exit 198
	}

	local type "`index'`xb'`stdp'`pr'"

	if ("`type'"=="index" | "`type'"=="xb" | "`type'"=="stdp") /*
	*/ & `"`outcome'"'!="" {
		di in red "outcome() option cannot be " /*
		*/ "specified with `type' option"
		exit 198
	}

/* Index, XB, or STDP. */

	if "`type'"=="index" | "`type'"=="xb" | "`type'"=="stdp" {

		Onevar `type' `varlist'

		if e(df_m) != 0 | ("`e(offset)'"!="" & "`offset'"=="") {

			tempname bb bb2 VV VV2 hold		/* This lops off the cut points from 	*/
			tempvar h_esamp				/* the estimation results, in order  	*/
			mat `bb' = e(b)				/* to exclude them from the prediction 	*/
			mat `VV' = e(V)				/* of xb and stdp			*/
			local ncoef = e(df_m)
			mat `bb2' = `bb'[1,1..`ncoef']
			mat `VV2' = `VV'[1..`ncoef',1..`ncoef']
			estimates hold `hold' , restore varname(`h_esamp')
			est post `bb2' `VV2'

			_predict `typlist' `varlist' `if' `in', `type' `offset'
			
			estimates unhold `hold' 		/* put back the real estimates		*/
			
		}
		else	gen `typlist' `varlist' = . `if' `in'

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

/* If here we compute probabilities.  Do general preliminaries. */

	local cut "_cut" /* _b[_cut1] */


	if "`e(model)'"=="Ordered Logit" {
		local func  "1/(1+exp("
		local funcn "1-1/(1+exp("
	}
	else {
		local func  "normprob(-("
		local funcn "normprob(("
	}


	tempvar touse
	mark `touse' `if' `in'

	if e(df_m) != 0 | ("`e(offset)'"!="" & "`offset'"=="") {

		tempname bb bb2 VV VV2 hold		/* This lops off the cut points from 	*/
		tempvar h_esamp				/* the estimation results, in order  	*/
		mat `bb' = e(b)				/* to exclude them from the prediction 	*/
		mat `VV' = e(V)				/* of xb and stdp			*/
		local ncoef = e(df_m)
		mat `bb2' = `bb'[1,1..`ncoef']
		mat `VV2' = `VV'[1..`ncoef',1..`ncoef']
		estimates hold `hold' , restore varname(`h_esamp')
		est post `bb2' `VV2'

		tempvar xb
		qui _predict double `xb' if `touse', xb `offset'
					
		estimates unhold `hold' 		/* put back the real estimates		*/
	}
	else	local xb 0

/* Probability with outcome() specified: create one variable. */

	if ("`type'"=="pr" | "`type'"=="") & `"`outcome'"'!="" {
		if "`type'"=="" {
			di in gr "(option p assumed; predicted probability)"
		}
		Onevar "p with outcome()" `varlist'

		Eq `outcome'
		local i `s(icat)'
		local im1 = `i' - 1
		sret clear

		if `i' == 1 {
			gen `typlist' `varlist' = /*
			*/ `func'`xb'-_b[`cut'1])) /*
			*/ if `touse'
		}
		else if `i' < e(k_cat) {
			gen `typlist' `varlist' = /*
			*/   `func'`xb'-_b[`cut'`i'])) /*
			*/ - `func'`xb'-_b[`cut'`im1'])) /*
			*/ if `touse'
		}
		else {
			gen `typlist' `varlist' = /*
			*/ `funcn'`xb'-_b[`cut'`im1'])) /*
			*/ if `touse'
		}

		local val = el(e(cat),1,`i')
		label var `varlist' "Pr(`e(depvar)'==`val')"
		exit
	}

/* Probabilities with outcome() not specified: create e(k_cat) variables. */

	if "`type'"=="" {
		di in gr "(option p assumed; predicted probabilities)"
	}
	local n : word count `varlist'
	if `n' != e(k_cat) {
		capture noisily error cond(`n'<e(k_cat), 102, 103)
		di in red /*
		*/ "`e(depvar)' has `e(k_cat)' outcomes and so you " /*
		*/ "must specify `e(k_cat)' new variables, or " _n /*
		*/ "you can use the outcome() option and specify " /*
		*/ "variables one at a time"
		exit cond(`n'<e(k_cat), 102, 103)
	}

	tempname miss
	local same 1
	mat `miss' = J(1,`e(k_cat)',0)

	quietly {
		local i 1
		while `i' <= e(k_cat) {
			local typ : word `i' of `typlist'
			tempvar p`i'
			local im1 = `i' - 1

			if `i' == 1 {
				gen `typ' `p`i'' = /*
				*/ `func'`xb'-_b[`cut'1])) /*
				*/ if `touse'
			}
			else if `i' < e(k_cat) {
				gen `typ' `p`i'' = /*
				*/   `func'`xb'-_b[`cut'`i'])) /*
				*/ - `func'`xb'-_b[`cut'`im1'])) /*
				*/ if `touse'
			}
			else {
				gen `typ' `p`i'' = /*
				*/ `funcn'`xb'-_b[`cut'`im1'])) /*
				*/ if `touse'
			}

		/* Count # of missings. */

			count if `p`i''==.
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
