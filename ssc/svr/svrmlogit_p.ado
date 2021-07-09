*! svrmlogit_p
*! Prediction for svrmodel with cmd(mlogit) 
*! Nicholas Winter version 1.0.0  31mar2004
*  Modified from official Stata's mlogit_p, version 1.1.2  18dec2002

program define svrmlogit_p /* predict for mlogit and svymlogit */

	version 6

/* Parse. */

	syntax newvarlist [if] [in] [, Equation(string) Outcome(string) /*
	*/ Index XB STDP STDDP Pr noOFFset ]
		/* Note: mlogit/svymlogit do not currently allow offset */

/* Check syntax. */

	local nopt : word count `index' `xb' `stdp' `stddp' `pr'
	if `nopt' > 1 {
		di in red "only one of p, xb, stdp, or stddp can be specified"
		exit 198
	}

	local type "`index'`xb'`stdp'`stddp'`pr'"

	if `"`outcome'"'!="" {
		if `"`equatio'"'!="" {
			di in red "only one of outcome() or equation() can " /*
			*/ "be specified"
			exit 198
		}
		local equatio `"`outcome'"'
	}

	if ("`type'"=="index" | "`type'"=="xb" | "`type'"=="stdp" /*
	*/ | "`type'"=="stddp") & `"`equatio'"'=="" {
		di in red "must specify outcome() option with `type' option"
		exit 198
	}

/* Process equation/outcome. */

	if `"`equatio'"'!="" {
		local eqorig `"`equatio'"'

*		if "`e(cmd)'"=="svymlogit" {			/* Eliminated -if-, b/c always -svr- version */

			EqNo "`type'" `equatio'
			local equatio `"`s(eqno)'"'
				/* this is empty if basecategory selected */
			if "`s(stddp)'"=="stdp" {
				local stddp "stdp"
			}
				/* local stddp is changed to stdp if
				   basecategory selected as one of the
				   equations
				*/

*		}						/* Eliminated: this is for -mlogit- */
*		else if `"`type'"' == "stddp" {
*			EqNo2 "`type'" `equatio'
*			local equatio `"`s(eqno)'"'
*		}

		local eqopt `"equation(`"`equatio'"')"'
	}

/* Index, XB, or STDP. */

	if "`type'"=="index" | "`type'"=="xb" | "`type'"=="stdp" /*
	*/ | "`type'"=="stddp" {

		Onevar `type' `varlist'

		if "`equatio'"!="" {
			_predict `typlist' `varlist' `if' `in', /*
			*/ ``type'' `eqopt' `offset'
					/* note: `type' may be stddp,
					   but ``type'' may be stdp
					*/
		}
		else	Zero `typlist' `varlist' `if' `in', `offset'

		if "`type'"=="index" | "`type'"=="xb"  {
			Outcome `equatio'
			label var `varlist' /*
		*/ `"Linear prediction, `e(depvar)'==`s(outcome)'"'
		}
		else if "`type'"=="stdp"  {
			Outcome `equatio'
			label var `varlist' /*
		*/ `"S.E. of linear prediction, `e(depvar)'==`s(outcome)'"'
		}
		else /* stddp */ label var `varlist' `"stddp(`eqorig')"'

		sret clear
		exit
	}

/* Probability with outcome() specified: create one variable. */

	if ("`type'"=="pr" | "`type'"=="") & `"`eqopt'"'!="" {
		if "`type'"=="" {
			di in gr "(option p assumed; predicted probability)"
		}
		Onevar "p with outcome()" `varlist'

		if "`e(cmd)'"=="mlogit" {
			_predict `typlist' `varlist' `if' `in', `eqopt' `offset'
		}
		else { /* svymlogit */
			OnePsvy `typlist' `varlist' `if' `in', `eqopt' `offset'
		}

		Outcome `equatio'
		label var `varlist' `"Pr(`e(depvar)'==`s(outcome)')"'
		sret clear
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

	tempvar touse
	mark `touse' `if' `in'

	if "`e(cmd)'"=="mlogit" {
		AllPmlog "`typlist'" "`varlist'" `touse' `offset'
	}
	else { /* svymlogit */
		AllPsvy "`typlist'" "`varlist'" `touse' `offset'
	}
end

program define Outcome, sclass
	if "`e(cmd)'"=="mlogit" {
		local o = trim(`"`0'"')
		if substr(`"`o'"',1,1)=="#" {
			local i = substr(`"`o'"',2,.)
			if `i' >= e(ibasecat) { local i = `i' + 1 }
			sret local outcome = el(e(cat),1,`i')
		}
		else	sret local outcome `"`o'"'
		exit
	}

/* If here, command is svymlogit.

   Either "`0'"=="#`i'" (no spaces) or "`0'"=="" (meaning basecategory).
*/
	if "`0'"=="" {
		sret local outcome = substr(`"`e(baselab)'"',1,8)
		exit
	}
	local i = substr("`0'",2,.)
	if `i' >= e(ibasecat) { local i = `i' + 1 }
	tempname cat
	mat `cat' = e(cat)
	mat `cat' = `cat'[1,`i'..`i']
	sret local outcome : coleq `cat'
end

program define Onevar
	gettoken option 0 : 0
	local n : word count `0'
	if `n'==1 { exit }
	di in red "option `option' requires that you specify 1 new variable"
	error cond(`n'==0,102,103)
end

program define EqNo2, sclass
	sreturn clear
	gettoken type 0 : 0
	if `"`type'"' != "stddp" {
		sreturn local eqno `"`0'"'
		exit
	}

	gettoken eq1 0 : 0, parse(" ,")
	gettoken comma eq2 : 0, parse(",")
	if `"`comma'"' != "," {
		di in red "second equation not found"
		exit 303
	}
	sreturn local eqno `"`eq1',`eq2'"'
end

program define EqNo, sclass
	sret clear
	gettoken type 0 : 0
	if "`type'"!="stddp" {
		Eq `0'
		exit
	}

/* If here, "`type'"=="stddp". */

	gettoken eq1 0 : 0, parse(",")
	gettoken comma eq2 : 0, parse(",")
	if "`comma'"!="," {
		di in red "second equation not found"
		exit 303
	}

	Eq `eq1'
	local eq1 `"`s(eqno)'"'
	Eq `eq2'
	if `"`eq1'"'!="" & `"`s(eqno)'"'!="" {
		sret local eqno `"`eq1',`s(eqno)'"'
	}
	else {
		sret local eqno `"`eq1'`s(eqno)'"'
		sret local stddp "stdp"
	}
end

program define Eq, sclass /* returns nothing if basecategory */
	sret clear
	local eqlab = trim(`"`0'"')
	if substr(`"`eqlab'"',1,1)=="#" {
		sret local eqno `"`eqlab'"'
		exit
	}
	capture confirm number `eqlab'
	if _rc == 0 {
		local i 1
		while `i' <= e(k_cat) {
			if `eqlab' == el(e(cat),1,`i') {
				Match `i'
				exit
			}
			local i = `i' + 1
		}
	}
	else {
		tempname cat cati
		mat `cat' = e(cat)
		local i 1
		while `i' <= e(k_cat) {
			mat `cati' = `cat'[1,`i'..`i']
			local eqi : coleq `cati'

			if `"`eqlab'"'==trim(`"`eqi'"') {
				Match `i'
				exit
			}
			local i = `i' + 1
		}
	}

	di in red `"equation `eqlab' not found"'
	exit 303
end

program define Match, sclass /* returns nothing if basecategory */
	args i
	if `i' != e(ibasecat) {
		local i = cond(`i'<e(ibasecat),`i',`i'-1)
		sret local eqno "#`i'"
	}
end

program define Zero
	syntax newvarname [if] [in] [, noOFFset ]
	tempvar xb
	qui _predict double `xb' `if' `in', `offset'
	gen `typlist' `varlist' = 0 if `xb'!=.
end

program define OnePsvy
	syntax newvarname [if] [in] [, Equation(string) noOFFset ]
	tempvar touse den xb
	mark `touse' `if' `in'

/* This command is only called with equation() in #eqno form, or
   with equation() empty signifying basecategory.
*/
	local equatio = substr(`"`equatio'"',2,.)

	quietly {

/* Compute denominator `den' = 1 + Sum(exp(`xb')). */

		gen double `den' = 1 if `touse'
		local i 1
		while `i' < e(k_cat) {
			_predict double `xb' if `touse', eq(#`i') xb `offset'
			replace `den' = cond(`xb'!=. & exp(`xb')==., /*
			*/ cond(`den'<0,`den'-1,-1), `den'+exp(`xb')) /*
			*/ if `touse'

			if "`i'"=="`equatio'" {
				tempvar xbsel
				rename `xb' `xbsel'
			}
			else	drop `xb'

					/* If `den'<0, then `den'==+inf.

					   If `den'==-1, then there is just
					   one +inf: p=0 if exp(`xbsel')!=.,
					   and p=1 if exp(`xbsel')==. (i.e.,
					   requested category gave the +inf).

					   If `den' < -1, then there are two
					   or more +inf: p=0 if exp(`xbsel')!=.;
					   and p=. if exp(`xbsel')==. (since we
					   cannot say what its value should be).
					*/

			local i = `i' + 1
		}
	}


/* Noisily compute probability of selected category. */

	if "`equatio'"=="" { /* basecategory */
		gen `typlist' `varlist' = cond(`den'>0,1/`den',0) if `touse'
	}
	else if "`xbsel'"=="" { /* equation not found */
		di in red `"equation #`equation' not found"'
		exit 303
	}
	else {
		gen `typlist' `varlist' = cond(`den'>0,exp(`xbsel')/`den', /*
		*/ cond(exp(`xbsel')!=.,0,cond(`den'==-1,1,.))) if `touse'
	}
end

program define AllPmlog
	args typlist varlist touse offset
	quietly {
		tempname miss
		local same 1
		mat `miss' = J(1,`e(k_cat)',0)
		local i 1
		while `i' <= e(k_cat) {
			tempvar p`i'
			local typ : word `i' of `typlist'
			local val = el(e(cat),1,`i')
			_predict `typ' `p`i'' if `touse', eq(`val') `offset'
			count if `p`i''==.
			mat `miss'[1,`i'] = r(N)
			if `miss'[1,`i']!=`miss'[1,1] {
				local same 0
			}
			label var `p`i'' `"Pr(`e(depvar)'==`val')"'
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

program define AllPsvy
	args typlist varlist touse offset
	quietly {
		tempvar den tmp
		tempname miss cat cati

	/* Compute denominator `den' = 1 + Sum(exp(`xb')). */

		gen double `den' = 1 if `touse'
		local i 1
		while `i' < e(k_cat) {
			tempvar xb
			_predict double `xb' if `touse', eq(#`i') xb `offset'
			replace `den' = cond(`xb'!=. & exp(`xb')==., /*
			*/ cond(`den'<0,`den'-1,-1), `den'+exp(`xb')) /*
			*/ if `touse'
					/* see comments in OnePsvy */

			if `i' < e(ibasecat) {
				local p`i' `xb'
				local i = `i' + 1
			}
			else {
				local i = `i' + 1
				local p`i' `xb'
			}
		}

	/* Compute probabilities. */

		local same 1
		mat `miss' = J(1,`e(k_cat)',0)
		mat `cat' = e(cat)
		local i 1
		while `i' <= e(k_cat) {
			local typ : word `i' of `typlist'

			if `i'==e(ibasecat) { /* basecategory */
				tempvar p`i'
				gen `typ' `p`i'' = cond(`den'>0,1/`den',0) /*
				*/ if `touse'
			}
			else {
				gen `typ' `tmp' = cond(`den'>0, /*
				*/ exp(`p`i'')/`den', /*
				*/ cond(exp(`p`i'')!=.,0, /*
				*/ cond(`den'==-1,1,.))) /*
				*/ if `touse'
				drop `p`i''
				rename `tmp' `p`i''
			}

		/* Count # of missings. */

			count if `p`i''==.
			mat `miss'[1,`i'] = r(N)
			if `miss'[1,`i']!=`miss'[1,1] {
				local same 0
			}

		/* Label variable. */

			mat `cati' = `cat'[1,`i'..`i']
			local eqi : coleq `cati'
			label var `p`i'' `"Pr(`e(depvar)'==`eqi')"'

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
