* ************************************************************************************* *
*                                                                                       *
*   goprobit_p                                                                          *
*   Version 1.1 - last revised September 05, 2006                                       *
*                                                                                       *
*   Author: Stefan Boes, boes@sts.unizh.ch                                              *
*                                                                                       *
*                                                                                       *
* ************************************************************************************* *
*                                                                                       *
*                                                                                       *
*   goprobit is a user-written procedure to estimate generalized ordered probit models  *
*   in Stata. It is a rewritten version of Vincent Fu's and Richard Williams' gologit   *
*   routines that assumes normally instead of logistically distributed error terms.     *
*   The current version of Richard Williams' gologit2 allows to estimate the            *
*   generalized ordered probit model using the link(probit) option and therefore        *
*   produces results equivalent to goprobit.                                            *
*                                                                                       *
*                                                                                       *
* ************************************************************************************* *
*                                                                                       *
*   This is the "predict" subroutine of goprobit.                                       *
*                                                                                       *
* ************************************************************************************* *



program define goprobit_p
	version 8
	syntax newvarlist [if] [in] [, Equation(string) ///
		Outcome(string) Index XB STDP STDDP Pr noOFFset ]

	marksample touse, novarlist


	* Check syntax **************************************************************** *
	local nopt: word count `index' `xb' `stdp' `stddp' `pr'
	if `nopt' > 1 {
		di in red "only one of p, xb, index, stdp, stddp can " ///
			"be specified"
		exit 198
	}

	if `"`outcome'"'!="" {
		if `"`equation'"'!="" {
			di in red "only one of outcome() or equation() can " ///
				"be specified"
			exit 198
		}
		local equation `"`outcome'"'
	}

	local type = trim("`index'`xb'`stdp'`stddp'`pr'")

	if ("`type'"=="index" | "`type'"=="xb" | "`type'"=="stdp" ///
		| "`type'"=="stddp") & `"`equation'"'=="" {
		di in red "must specify outcome() option with `type' option"
		exit 198
	}


	* Process equation or outcome ************************************************* *
	* You can use the equation # or the DV value when specifying
	* equations. The next few lines will convert everything to the
	* correspong equation #.
	if `"`equation'"'!="" {
		local eq_original `"`equation'"'   /* Save original spec. */
		EqNo "`type'" `equation'
		local equation `"`s(eqno)'"'
		if "`s(stddp)'"=="stdp" {
			local stddp "stdp"
			// local stddp is changed to stdp if
			// basecategory selected as one of the
			// equations
		}
		else if `"`type'"' == "stddp" {
			EqNo2 "`type'" `equation'
			local equation `"`s(eqno)'"'
		}
		local eqopt `"equation(`"`equation'"')"'
	}


	* Linear indices ************************************************************** *
	if "`type'"=="xb"  {

		Onevar `type' `varlist'

		if "`equation'"!="" {
			_predict `typlist' `varlist' if `touse', /*
			*/ ``type'' `eqopt' `offset'
		}
		else Zero `typlist' `varlist' if `touse', `offset'

		Outcome `eq_original'
		label var `varlist' `"Linear prediction, `e(depvar)'==`s(outcome)'"'

		sret clear
		exit
	}


	* Probabilities *************************************************************** *
	* Probability with outcome() specified
	* -> create one variable
	if ("`type'"=="pr" | "`type'"=="") & `"`eqopt'"'!="" {
		if "`type'"=="" {
			di in gr "(option p assumed; predicted probability)"
		}
		Onevar "p with outcome()" `varlist'
		Predict_Pr `typlist' `varlist' `if' `in', `eqopt' `offset' onep

		Outcome `eq_original'
		label var `varlist' `"Pr(`e(depvar)'==`s(outcome)')"'
		sret clear
		exit
	}

	* Probabilities with outcome() not specified
	* -> create e(k_cat) variables.

	if ("`type'"=="pr" | "`type'"=="") & `"`eqopt'"'=="" {
		di in gr "(option p assumed; predicted probabilities)"
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

		Predict_Pr `typlist' `varlist' `if' `in', `offset'
		sret clear
		exit
	}


	* Standard Error of linear prediction(s) ************************************** *
	if "`type'"=="stdp" | "`type'"=="stddp" {

		Onevar `type' `varlist'
		* Note:
		* The double-single quotes around '`type'' is intentional.
		* If the user specified stdp, it will expand to stdp.
		* BUT, it may also expand to stdp if the user specified stddp
		* but used the base category when specifying the equations.
		_predict `typlist' `varlist' `if' `in', ``type'' `eqopt' `offset'
		if "`type'"=="stdp"  {
			Outcome `equation'
			label var `varlist' `"S.E. of linear prediction, `e(depvar)'==`s(outcome)'"'
		}
		else label var `varlist' `"stddp(`eq_original')"'

		sret clear
		exit
	}
end




program define Outcome, sclass
	* s(outcome) contains the value of the DV
	local o = trim(`"`0'"')
	if substr(`"`o'"',1,1)=="#" {
		local i = substr(`"`o'"',2,.)
		if `i' >= e(ibasecat)  local i = `i' + 1
		sret local outcome = el(e(cat),1,`i')
	}
	else	sret local outcome `"`o'"'
end




program define Onevar
	* This routine checks to make sure that only one new variable
	* has been specified when using the outcome option
	gettoken option 0 : 0
	local n : word count `0'
	if `n'==1 exit
	di in red "option `option' requires that you specify 1 new variable"
	error cond(`n'==0,102,103)
end




program define Eq_Convert, sclass
	* Users can specify equations by # or the DV value. However the
	* user has done it, this will save the corresponding
	* equation # in s(eqno).
	sret clear
	local eqlab = trim(`"`0'"')

	* For when equation # has been specified
	if substr(`"`eqlab'"',1,1)=="#" {
		sret local eqno `"`eqlab'"'
		exit
	}

	* For when DV value has been specified
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

	display in red `"equation `eqlab' not found"'
	exit 303
end




program define Match, sclass
	args i
	* Called by Eq_Convert; converts DV values to
	* the corresponding equation #s
	if `i' != e(ibasecat) {
		local i = cond(`i'<e(ibasecat),`i',`i'-1)
		sret local eqno "#`i'"
	}
end




program define Zero
	* Creates a variable containing only 0 or missing when
	* user has asked for XB on the base category
	syntax newvarname [if] [in] [, noOFFset ]
	marksample touse, novarlist
	tempvar xb
	qui _predict double `xb' if `touse', `offset'
	gen `typlist' `varlist' = 0 if `xb'<.
end




program define Predict_Pr
	// Generates the predicted probabilities for goprobit
	// Adapted from gologit2_p

	syntax newvarlist(min=1) [if] [in] [, Equation(string) noOFFset ONEP ]
	marksample touse, novarlist


	local Numeqs = e(k_eq)
	local Numcats = e(k_cat)
	tempname miss cat cati

	tempvar touse
	mark `touse' `if' `in'

	// Compute XBs
	forval j = 1/`Numeqs' {
		tempvar xb`j'
		quietly _predict double `xb`j'' if `touse', eq(#`j') xb `offset'
	}

// Probability with outcome() specified: create one variable.

	if "`onep'"!="" {

		local equation = substr(`"`equation'"',2,.)
		// Equation is blank for base category
		if "`equation'"=="" local equation `Numcats'

		local j `equation'
		local i = `j' - 1

		if `j' == 1 {
			gen `typlist' `varlist' = /*
			*/ normprob(-((`xb1'))) /*
			*/ if `touse'
		}
		else if `j' < `Numcats' {
			gen `typlist' `varlist' = /*
			*/   normprob(-((`xb`j''))) /*
			*/ - normprob(-((`xb`i''))) /*
			*/ if `touse'
		}
		else {
			gen `typlist' `varlist' = /*
			*/ normprob(((`xb`i''))) /*
			*/ if `touse'
		}

		exit
	}

// Probabilities with outcome() not specified: create e(k_cat) variables.

	tempname miss
	local same 1
	mat `miss' = J(1,`Numcats',0)
	quietly {
		local j 1
		forval j = 1/`Numcats' {
			local typ : word `j' of `typlist'
			tempvar p`j'
			local i = `j' - 1

			if `j' == 1 {
				gen `typ' `p1' = /*
				*/ normprob(-((`xb1'))) /*
				*/ if `touse'
			}
			else if `j' < `Numcats' {
				gen `typ' `p`j'' = /*
				*/   normprob(-((`xb`j''))) /*
				*/ - normprob(-((`xb`i''))) /*
				*/ if `touse'
			}
			else {
				gen `typ' `p`j'' = /*
				*/ normprob(((`xb`i''))) /*
				*/ if `touse'
			}

		/* Count # of missings. */
			count if `p`j''>=.
			mat `miss'[1,`j'] = r(N)
			if `miss'[1,`j']!=`miss'[1,1] {
				local same 0
			}

		/* Label variable. */

			local val = el(e(cat),1,`j')
			label var `p`j'' "Pr(`e(depvar)'==`val')"

		}
	}

	tokenize `varlist'
	local j 1
	forval j = 1/`Numcats' {
		rename `p`j'' ``j''
	}
	ChkMiss `same' `miss' `varlist'

end




*****************************************************************************************
*****************************************************************************************
program define ChkMiss
	* This routine checks for # of MD cases generated
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
	* This routine reports the # of MD cases generated
	args nmiss varname
	if `nmiss' == 0 exit
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




program define EqNo2, sclass
	* This checks if stddp equations are ok
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
		Eq_Convert `0'
		exit
	}

	* Provides special treatment for stddp if needed
	gettoken eq1 0 : 0, parse(",")
	gettoken comma eq2 : 0, parse(",")
	if "`comma'"!="," {
		di in red "second equation not found"
		exit 303
	}

	Eq_Convert `eq1'
	local eq1 `"`s(eqno)'"'
	Eq_Convert `eq2'
	if `"`eq1'"'!="" & `"`s(eqno)'"'!="" {
		sret local eqno `"`eq1',`s(eqno)'"'
	}
	else {
		sret local eqno `"`eq1'`s(eqno)'"'
		sret local stddp "stdp"
	}
end

