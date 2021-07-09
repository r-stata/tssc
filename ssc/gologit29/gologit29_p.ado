*! version 2.1.7 29sep2014  Richard Williams, rwilliam@nd.edu

* This adds support for the predict command to gologit29

* Adapted from mlogit_p version 1.1.3  27sep2004
* Also adapted from ologit_p and oglm_p
* In version 2.1.3, I changed the code for predicted probabilities,
* patterning it after oglm_p.  Marginal effects now seem to work ok.
* 2.1.6 - For predict, if you do not specify outcome(), 
*         pr (with one new variable specified), xb, and stdp assume outcome(#1).  
*         You must specify outcome() with the stddp option.

program define gologit29_p 
	if `c(stata_version)' < 9 {
		version 8.2
	}
	else {
		version 9
	}
	
// Handle scores
        syntax anything [if] [in] [, * SCores ]
        if "`scores'" != "" {
                if "`e(cmd)'" != "gologit29" {
                        error 322
                }
		global Link `e(link)'
		macro drop dv_*
		tempname ycat
		matrix `ycat' = e(cat)
		forval i = 1/`e(k_cat)' {
			global dv_`i' = `ycat'[1, `i']
		}
	        ml_p `0'
	        macro drop Link dv_*
		sret clear
		exit
        }

// Parse

	syntax newvarlist [if] [in] [, Equation(string) ///
		Outcome(string) Index XB STDP STDDP Pr noOFFset ]
	// Note: gologit does not currently allow offset

	marksample touse, novarlist

// Check syntax

	local nopt : word count `index' `xb' `stdp' `stddp' `pr'
	if `nopt' > 1 {
		di in red "only one of p, xb, index, stdp, stddp can be specified"
		exit 198
	}

	local type = trim("`index'`xb'`stdp'`stddp'`pr'")

	if `"`outcome'"'!="" {
		if `"`equation'"'!="" {
			di in red "only one of outcome() or equation() can " /*
			*/ "be specified"
			exit 198
		}
		local equation `"`outcome'"'
	}
	// Default to outcome 1 if outcome not specified and 
	// there is only one new var specified
	else {
		local n : word count `varlist'
		if `n' == 1 local equation #1
	}
	

	if ("`type'"=="index" | "`type'"=="xb" | "`type'"=="stdp" ///
		| "`type'"=="stddp") & `"`equation'"'=="" {
		di in red "must specify outcome() option with `type' option"
		exit 198
	}

// Process equation or outcome

	// You can use the equation #, the DV value, or the DV label
	// when specfying equations.  The next few lines will convert
	// everything to the corresponding equation #.
	if `"`equation'"'!="" {
		local eq_original `"`equation'"'   /* Save original specification */
		EqNo "`type'" `equation'
		local equation `"`s(eqno)'"'
			// this is empty if basecategory selected
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

// XB  

	if "`type'"=="xb"  {

		Onevar `type' `varlist'
		
		// Generate the XB values.  If the base category has been
		// chosen, the generated var will equal 0 or missing.

		if "`equation'"!="" {
			_predict `typlist' `varlist' if `touse', /*
			*/ ``type'' `eqopt' `offset'
		}
		else	Zero `typlist' `varlist' if `touse', `offset'

		Outcome `eq_original'
		label var `varlist' `"Linear prediction, `e(depvar)'==`s(outcome)'"'

		sret clear
		exit
	}

// Probability with outcome() specified: create one variable

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

// Probabilities with outcome() not specified: create e(k_cat) variables.

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

// STDP, STDDP
	if "`type'"=="stdp" | "`type'"=="stddp" {

		Onevar `type' `varlist'
		// note: The double-single quotes around '`type'' is intentional.
		// If the user specified stdp, it will expand to stdp.  BUT, it may
		// also expand to stdp if the user specified stddp but used the
		// base category when specifying the equations.
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

****************************************************************
program define Outcome, sclass

	// s(outcome) will contain either the value of the DV
	// or the label of the DV
	local o = trim(`"`0'"')
	if substr(`"`o'"',1,1)=="#" {
		local i = substr(`"`o'"',2,.)
		***if `i' >= e(ibasecat)  local i = `i' + 1*** This was an error
		sret local outcome = el(e(cat),1,`i')
	}
	else	sret local outcome `"`o'"'

end

****************************************************************
program define Onevar
	// This routine checks to make sure that only one new variable
	// has been specified when using the outcome option
	gettoken option 0 : 0
	local n : word count `0'
	if `n'==1 exit
	di in red "option `option' requires that you specify 1 new variable"
	error cond(`n'==0,102,103)
end

****************************************************************
program define Eq_Convert, sclass /* returns nothing if basecategory */

	// Users can specify equations by #, DV value, and DV value label.
	// However the user has done it, this will save the corresponding
	// equation # in s(eqno).
	sret clear
	local eqlab = trim(`"`0'"')
	
	// For when equation # has been specified
	if substr(`"`eqlab'"',1,1)=="#" {
		sret local eqno `"`eqlab'"'
		exit
	}
	
	// For when DV value has been specified
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
	
	// For when DV value label has been specified
	// Find the label and its corresponding value
	// and then convert to the equation #
	else {
		local y = e(depvar)
		local i 1
		while `i' <= e(k_cat) {
			local eqi = el(e(cat),1,`i')
			local vlabel: label(`y') `eqi'
			if `"`eqlab'"'==trim(`"`vlabel'"') {
				Match `eqi'
				exit
			}
			local i = `i' + 1
		}
	}

	display in red `"equation `eqlab' not found"'
	exit 303
end

****************************************************************
program define Match, sclass /* returns nothing if basecategory */
	args i
	// Called by Eq_Convert.  Converts DV values to
	// the corresponding equation #s
	if `i' != e(ibasecat) {
		local i = cond(`i'<e(ibasecat),`i',`i'-1)
		sret local eqno "#`i'"
	}
end

****************************************************************
program define Zero
	// Creates a variable containing only 0 or missing when
	// user has asked for XB on the base category
	syntax newvarname [if] [in] [, noOFFset ]
	marksample touse, novarlist
	tempvar xb
	qui _predict double `xb' if `touse', `offset'
	gen `typlist' `varlist' = 0 if `xb'<.
end

****************************************************************
program define Predict_Pr
	// Generates the predicted probabilities.
	// See the comments in gologit29_ll.ado for an explanation of
	// the formulas.
	syntax newvarlist(min=1) [if] [in] [, Equation(string) noOFFset ONEP ]
	marksample touse, novarlist
	
	
	local Numeqs = e(k_eq)
	local Numcats = e(k_cat)
	tempname miss cat cati
	// Determine what link function was used
	local link `e(link)'
	if "`link'"=="" local link "logit"
		
	// Any new links must be specified here
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
	else {
		display as error "link `link' is not supported"
		exit 198
	}

	tempvar touse
	mark `touse' `if' `in'

	// Compute XBs
	forval j = 1/`Numeqs' {
		tempvar xb`j'
		quietly _predict double `xb`j'' if `touse', eq(#`j') xb `offset'
	}
	// Sigma set at 1 for all cases.  The program may eventually allow for 
	// heteroskedasticity, but not yet
	local sigma = 1

// Probability with outcome() specified: create one variable.

	if "`onep'"!="" {
		
		local equation = substr(`"`equation'"',2,.)
		// Equation is blank for base category
		if "`equation'"=="" local equation `Numcats'

		local j `equation'
		local i = `j' - 1

		if `j' == 1 {
			gen `typlist' `varlist' = /*
			*/ `func'(`xb1')/`sigma')) /*
			*/ if `touse'
		}
		else if `j' < `Numcats' {
			gen `typlist' `varlist' = /*
			*/   `func'(`xb`j'')/`sigma')) /*
			*/ - `func'(`xb`i'')/`sigma')) /*
			*/ if `touse'
		}
		else {
			gen `typlist' `varlist' = /*
			*/ `funcn'(`xb`i'')/`sigma')) /*
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
				*/ `func'(`xb1')/`sigma')) /*
				*/ if `touse'
			}
			else if `j' < `Numcats' {
				gen `typ' `p`j'' = /*
				*/   `func'(`xb`j'')/`sigma')) /*
				*/ - `func'(`xb`i'')/`sigma')) /*
				*/ if `touse'
			}
			else {
				gen `typ' `p`j'' = /*
				*/ `funcn'(`xb`i'')/`sigma')) /*
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

****************************************************************
program define ChkMiss
	// This routine checks for # of MD cases generated
	args same miss
	macro shift 2
	if `same' {
		SayMiss `miss'[1,1]
		exit
	}
	local j 1
	while `j' <= e(k_cat) {
		SayMiss `miss'[1,`j'] ``j''
	}
end

****************************************************************
program define SayMiss
	// This routine reports the # of MD cases generated
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
****************************************************************

program define EqNo2, sclass
	// This checks stddp equations are ok
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

****************************************************************

program define EqNo, sclass
	// Provides special treatment for stddp if needed
	sret clear
	gettoken type 0 : 0
	if "`type'"!="stddp" {
		Eq_Convert `0'
		exit
	}

/* If here, "`type'"=="stddp". */

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
