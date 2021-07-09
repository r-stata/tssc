*! 1.1.19 MLB 17Mar2013
*! 1.1.16 MLB 24Apr2012
*! 1.1.15 MLB 22Mar2012
*! 1.1.1 MLB 14 Jul 2009
* letting the levels be specified in -seqlogit- rather than -predict-
*! 1.0.2 MLB 09 Sep 2007
* adding residuals
*! 1.0.1 MLB 10 Aug 2007
*! 1.0.0 MLB 28 Jan 2007

program define seqlogit_p
        version 9.2

	syntax anything [if] [in] [, pr * ]

	/*Parsing new variables*/
	sreturn clear
	local ncat = cond("`pr'" != "", `e(k_cat)',`e(k_eq)')	
	_stubstar2names `anything', nvars(`ncat') singleok
	local varlist    "`s(varlist)'"
	local typelist   "`s(typlist)'"
	
	/*Parsing options*/
	ParseOptions , `pr' `options'
	local type       "`s(type)'"
	local eqspec     "`s(eqspec)'"
	if `"`eqspec'"' != "" {
		local eqn `"equation(`eqspec')"'
	}
	local eqnum       `s(eqnum)'
	local outcome    "`s(outcome)'"
	if "`outcome'" != "" {
		local out `"outcome(`outcome')"'
	}
	local transition "`s(transition)'"
	if "`transition'" != "" {
		local trans `"transition(`transition')"'
	}
	local choice     "`s(choice)'"
	
	local treelevels "`e(treelevels)'"
	foreach lev of local treelevels {
		local l`lev' "`s(l`lev')'"
	}

	/*Checking number of new variables*/
	CheckVars `varlist', `type' `eqn' `out' `trans'
	
	local nvars : word count `varlist'

/* scores */
	if `"`type'"' == "score" {
		GenScores `varlist' `if' `in', `eqn'
		sret clear
		exit
	}
/* XB, or STDP. */
	if "`type'"=="xb" | "`type'"=="stdp" {
		_predict `typlist' `varlist' `if' `in', `type' `eqn'
		if "`type'"=="xb"  {
			label var `varlist' /*
			*/ "Linear prediction for equation `eq'"
		}
		else { /* stdp */
			label var `varlist' /*
			*/ "S.E. of linear prediction for equation `eq'"
		}
		exit
	}
/* single TRPr */
	if "`type'" == "trpr" & `nvars' == 1{
		/*The numerator*/
		if "`transition'" == "" | "`choice'" == "" {
			di as err ///
			"options transition() and choice() must be specified when using the trpr option and only one variable"
			exit 198
		}
		local eqnsdenom "`e(eqstr`transition')'"
		tempvar denom
		qui gen double `denom' = 1 `if' `in'
		foreach equ of local eqnsdenom {
			tempvar xb`equ'
			qui _predict double `xb`equ'', xb equation(#`equ')
			qui replace `denom' = `denom' + exp(`xb`equ'')
		}
		/*probability*/
		if `choice' == 0 {
			gen `typelist' `varlist' = 1/`denom' `if' `in'
			label var `varlist' /*
			*/ "Probability of choosing `choice' in transition `trans'"
		}
		else {
			local eqnum = `e(eqtr`transition'c`choice')'
			gen `typelist' `varlist' = exp(`xb`eqnum'')/(`denom')
			label var `varlist' /*
			*/ "Probability of choosing `choice' in transition `trans'"
		}
		exit
	}

/* Multiple TRPr */
	if "`type'" == "trpr" & `nvars' > 1{
		/*The numerator*/
		forvalues i = 1/`e(Ntrans)' {
			tempvar denom`i' 
			qui gen double `denom`i'' = 1
			local eqnsdenom "`e(eqstr`i')'"
			foreach j of local eqnsdenom {
				tempvar xb`j'
				qui _predict double `xb`j'', xb equation(#`j')
				qui replace `denom`i'' = `denom`i'' + exp(`xb`j'')
			}
		}
		/*The probabilities*/
		gettoken typlist : typelist
		tokenize `varlist'
		forvalues i = 1/`e(Ntrans)' {
			local end = `e(Nchoice`i')' - 1
			forvalues j = 1/`end' {
				gen `typelist' ``e(eqtr`i'c`j')'' = exp(`xb`e(eqtr`i'c`j')'')/`denom`i'' `if' `in'
				label var ``e(eqtr`i'c`j')'' /*
				*/ "probability of choosing `j' in transition `i'"
			}
		}
		exit
	}
	/* single TRVar */
	if "`type'" == "trvar" & `nvars' == 1{
		tempvar p
		qui predict double `p', trpr transition(`transition') choice(`choice')
		gen `typelist' `varlist' = `p'*(1-`p')
		label var `varlist' /*
		*/ "variance of choice `choice' in transition `trans'"	
		exit
	}
	/* multiple TRVar */
	if "`type'" == "trvar" & `nvars' > 1 {
		forvalues i = 1/`e(k_eq)' {
			tempvar p`i'
			local p "`p' `p`i''"
			local double "`double' double"
		}
		qui predict `double' `p', trpr 
		gettoken typlist : typelist
		tokenize `varlist'
		forvalues i = 1/`e(k_eq)' {
			gen `typelist' ``i'' = `p`i''*(1-`p`i'')
			label var ``i'' /*
			*/ "variance of equation `i'"
		}
		exit
	}
/* single TRAtrisk*/
	if "`type'" == "tratrisk" & `nvars' == 1 {
		/*collect levels of transition*/
		local end = `e(Nchoice`transition')'-1
		forvalues i = 0/`end' {
			local levs "`levs' `e(tr`transition'choice`i')'"
		}
		local levs : list retokenize levs
		
		tempvar p
		qui gen double `p' = 1
		forvalues i = 1/`=`transition'-1' {
			local end = `e(Nchoice`i')' - 1
			forvalues j = 0/`end'{
				local temp `e(tr`i'choice`j')'
				local intersection : list levs & temp
				if "`intersection'" != "" {
					tempvar p`i'
					qui predict double `p`i'', trpr transition(`i') choice(`j')
					qui replace `p' = `p'*`p`i''
				}
			}
		}
		gen `typelist' `varlist' = `p' `if' `in'
		label var `varlist' /*
		*/ "Proportion at risk at transition `trans'"
		exit
	}
/*multiple TRAtrisk*/
	if "`type'" == "tratrisk" & `nvars' > 1 {
		local l = 0
		forvalues i = 1/`e(Ntrans)' {
			foreach j in `e(eqstr`i')' {
				local l = `l' + 1
				local var : word `l' of `varlist'
				local type : word `l' of `typelist'
				predict `type' `var', tratrisk transition(`i')
			}
		}
		exit
	}
/*TRGain*/
	if "`type'" == "trgain" & `nvars' == 1{
		local gain `e(tr`transition'choice`choice')'
		local end = `e(Nchoice`transition')' - 1
		forvalues i = 0/`end' {
			if `i' != `choice' {
				foreach j in `e(tr`transition'choice`i')' {
					local cl`j' = `i'
				}
				local loss "`loss' `e(tr`transition'choice`i')'"
				
			}
		}
		tempvar g l
		qui gen double `g' = 0 `if' `in'
		qui gen double `l' = 0 `if' `in'
		local begin = `transition' + 1
		foreach c of local gain {
			tempvar p`c'
			qui gen double `p`c'' = 1
			forvalues t = `begin'/`e(Ntrans)' {
				local end = `e(Nchoice`t')' - 1
				forvalues i = 0/ `end' {
					local temp `e(tr`t'choice`i')'
					local step : list c in temp
					if `step' {
						tempvar p`c'`t'
						qui predict double `p`c'`t'', trpr transition(`t') choice(`i')
						qui replace `p`c'' = `p`c'' * `p`c'`t''
					}
				}
			}
			qui replace `g' = `g' + `p`c''*`l`c''
		}
		
		foreach c of local loss {
			tempvar p`c'
			qui gen double `p`c'' = 1
			if `e(Nchoice`transition')' > 2 {
				tempvar p`c'`transition'
				qui predict double `p`c'`transition'', trpr transition(`transition') choice(`cl`c'')
				qui replace `p`c'' = `p`c'' * `p`c'`transition''
			}
			forvalues t = `begin'/`e(Ntrans)' {
				local end = `e(Nchoice`t')' - 1
				forvalues i = 1/ `end' {
					local temp `e(tr`t'choice`i')'
					local step : list c in temp
					if `step' {
						tempvar p`c'`t'
						qui predict double `p`c'`t'', trpr transition(`t') choice(`i')
						qui replace `p`c'' = `p`c'' * `p`c'`t''
					}
				}
			}
			if `e(Nchoice`transition')' > 2{
				/*In case of mlogit the probabilities in the loss function are*/
				/*conditional on not haveing choses the choice of interest*/
				tempvar pchoice
				qui predict double `pchoice' , trpr trans(`transition') choice(`choice')
				qui replace `p`c'' = `p`c''/(1-`pchoice')
			}
			qui replace `l' = `l' + `p`c''*`l`c''
		}
		gen `typelist' `varlist' = `g' - `l' `if' `in'
		label var `varlist' /*
		*/ "Expected gain from chosing `choice' in transition `transition'"
		exit
	}
	
/*multiple TRGain*/
	if "`type'" == "trgain" & `nvars' > 1{
		gettoken typelist : typelist
		tokenize `varlist'
		forvalues i = 1/`e(Ntrans)' {
			local end = `e(Nchoice`i')' - 1
			forvalues j = 1/`end' {
				predict `typelist' ``e(eqtr`i'c`j')'' `if' `in', trgain trans(`i') choice(`j') 
			}
		}
		exit
	}
/* single TRMWeight */
	if "`type'" == "trmweight" & `nvars' == 1 {
		tempvar a g
		qui predict double `a', tratrisk transition(`transition')
		qui predict double `g', trgain transition(`transition') choice(`choice') 
		gen `typelist' `varlist' = `a'*`g' `if' `in'
		label var `varlist' /*
		*/ "weight assigned to transition `transition' choice `choice'"
		exit
	}
/* multiple TRMWeight */
	if "`type'" == "trmweight" & `nvars' > 1 {
		forvalues i = 1/`e(k_eq)' {
			tempvar a`i' g`i'
			local a "`a' `a`i''"
			local g "`g' `g`i''" 
			local double "`double' double"
		}
		qui predict `double' `a', tratrisk 
		qui predict `double' `g', trgain 
		
		gettoken typlist : typelist
		tokenize `varlist'
		forvalues i = 1/`e(k_eq)' {
			gen `typelist' ``i'' = `a`i''*`g`i'' `if' `in'
			label var ``i'' /*
			*/ "weight assigned equation `i'"
		}
		exit
	}
	
/* single TRWeight */
	if "`type'" == "trweight" & `nvars' == 1 {
		tempvar a v g
		qui predict double `a', tratrisk transition(`transition')
		qui predict double `v', trvar transition(`transition') choice(`choice')
		qui predict double `g', trgain transition(`transition') choice(`choice') 
		gen `typelist' `varlist' = `a'*`v'*`g' `if' `in'
		label var `varlist' /*
		*/ "weight assigned to transition `transition' choice `choice'"
		exit
	}
/* multiple TRWeight */
	if "`type'" == "trweight" & `nvars' > 1 {
		forvalues i = 1/`e(k_eq)' {
			tempvar a`i' v`i' g`i'
			local a "`a' `a`i''"
			local v "`v' `v`i''"
			local g "`g' `g`i''" 
			local double "`double' double"
		}
		qui predict `double' `a', tratrisk 
		qui predict `double' `v', trvar 
		qui predict `double' `g', trgain 
		
		gettoken typlist : typelist
		tokenize `varlist'
		forvalues i = 1/`e(k_eq)' {
			gen `typelist' ``i'' = `a`i''*`v`i''*`g`i'' `if' `in'
			label var ``i'' /*
			*/ "weight assigned equation `i'"
		}
		exit
	}
/* single Pr */
	if "`type'" == "pr" & `nvars' == 1 {
		forvalues i = 1/`e(Ntrans)' {
			local end = `e(Nchoice`i')' - 1
			forvalues j = 1/`end' {
				tempvar p`e(eqtr`i'c`j')'
				local p "`p' `p`e(eqtr`i'c`j')''"
				local double "`double' double"
			}
		}
		
		qui predict `double' `p', trpr 
		
		forvalues i = 1/`e(Ntrans)' {
			tempvar pt`i'c0
			qui predict double `pt`i'c0', trpr transition(`i') choice(0)
		}

		tempvar p
		qui gen double `p' = 1
		forvalues j = 1/`e(Ntrans)' {
			local end = `e(Nchoice`j')' - 1
			forvalues k = 0/`end' {
				local tr`j'choice`k' "`e(tr`j'choice`k')'"
				di ""
				local step : list outcome in tr`j'choice`k'
				if `step' {
					if `k' == 0 {
						/*choice 0 is the reference category*/
						qui replace `p' = `p'*`pt`j'c0'
					}
					else {
						qui replace `p' = `p'*`p`e(eqtr`j'c`k')''
					}
				}
			}
		}
		gen `typelist' `varlist' = `p'
		label var `varlist' /*
		*/ "probability of achieving outcome `outcome'"
		exit
	}
/* multiple Pr */
	if "`type'" == "pr" & `nvars' > 1 {
		forvalues i = 1/`e(Ntrans)' {
			local end = `e(Nchoice`i')' - 1
			forvalues j = 1/`end' {
				tempvar p`e(eqtr`i'c`j')'
				local p "`p' `p`e(eqtr`i'c`j')''"
				local double "`double' double"
			}
		}
		
		qui predict `double' `p', trpr 
		
		forvalues i = 1/`e(Ntrans)' {
			tempvar pt`i'c0
			qui predict double `pt`i'c0', trpr transition(`i') choice(0)
		}
		
		local level = 0
		local treelevels `e(treelevels)'
		foreach i of local treelevels{
			tempvar pr`++level'
			qui gen double `pr`level'' = 1
			forvalues j = 1/`e(Ntrans)' {
				local end = `e(Nchoice`j')' - 1
				forvalues k = 0/`end' {
					local tr`j'choice`k' "`e(tr`j'choice`k')'"
					local step : list i in tr`j'choice`k'
					if `step' {
						if `k' == 0 {
							/*choice 0 is the reference category*/
							qui replace `pr`level'' = `pr`level''*`pt`j'c0'
						}
						else {
							qui replace `pr`level'' = `pr`level''*`p`e(eqtr`j'c`k')''
						}
					}
				}
			}
			/*for variable label*/
			local o`i' "`i'"
		}
					
		
		gettoken typlist : typelist
		tokenize `varlist'
		forvalues i = 1/`e(k_cat)' {
			gen `typelist' ``i'' = `pr`i'' `if' `in'
			label var ``i'' /*
			*/ "probability of achieving outcome `o`i''"
		}
		exit
	}
/* Y, the default */
	if "`type'" == "y" | "`type'" == "" {
		forvalues i = 1/`e(k_cat)' {
			tempvar pr`i'
			local p "`p' `pr`i''"
			local double "`double' double"
		}
		qui predict `double' `p', pr 
	
		local treelevels "`e(treelevels)'"
	
		tempvar y
		qui gen double `y' = 0
		tokenize `e(treelevels)'
		forvalues i = 1/`e(k_cat)' {
			/*probabilities are created in the same order as treelevels*/
			qui replace `y' = `y' + `pr`i''*`l``i'''
		}
		gen `typelist' `varlist' = `y' `if' `in'
		label var `varlist' /*
		*/ "expected value"
		exit
	}
/* single TReffect */
	if "`type'" == "treffect" & `nvars' == 1 {
		local eq = e(eqtr`transition'c`choice')
		tempvar w lodds
		qui predict double `w', trweight transition(`transition') choice(`choice')
		qui gen double `lodds' = [#`eq']_b[`e(ofinterest)']
		if `"`e(over)'"' != "" {
			_ms_extract_varlist `e(over)'
			local overvars `r(varlist)'
			foreach var in `overvars' {
				qui replace  `lodds' = ///
					`lodds' + [#`eq']_b[c.`e(ofinterest)'#`var']*`var'
			}
		}
		gen `typelist' `varlist' = `w' * `lodds' `if' `in'
		label var `varlist' /*
		*/ "contribution of equation `eq' to the effect of `e(ofinterest)' on the expected value"
		exit
	}
/* multiple treffect */	
	if "`type'" == "treffect" & `nvars' > 1 {
		forvalues i = 1/`e(k_eq)' {
			tempvar w`i'
			local w "`w' `w`i''"
			local double "`double' double"
		}
		qui predict `double' `w', trweight 
		forvalues i = 1/`e(k_eq)' {
			tempvar lodds`i'
			qui gen double `lodds`i'' = [#`i']_b[`e(ofinterest)']
			if `"`e(over)'"' != "" {
				_ms_extract_varlist `e(over)'
				local overvars `r(varlist)'
				foreach var in `overvars' {
					qui replace  `lodds`i'' = ///
						`lodds`i'' + [#`i']_b[c.`e(ofinterest)'#`var']*`var'
				}
			}
		}
		tokenize `varlist'
		forvalues i = 1/`e(k_eq)' {
			gen `typelist' ``i'' = `w`i'' * `lodds`i'' `if' `in'
			label var ``i'' /*
			*/ "contribution of equation `i' to the effect of `e(ofinterest)' on the expected value"
		}
		exit
	}
/* effect */	
	if "`type'" == "effect" {
		forvalues i = 1/`e(k_eq)' {
			tempvar w`i'
			local w "`w' `w`i''"
			local double "`double' double"
		}
		qui predict `double' `w', trweight 
		forvalues i = 1/`e(k_eq)' {
			tempvar lodds`i'
			qui gen double `lodds`i'' = [#`i']_b[`e(ofinterest)']
			if `"`e(over)'"' != "" {
				_ms_extract_varlist `e(over)'
				local overvars `r(varlist)'
				foreach var in `overvars' {
					qui replace  `lodds`i'' = ///
					`lodds`i'' + [#`i']_b[c.`e(ofinterest)'#`var']*`var'
				}
			}
		}
		tempvar eff
		qui gen double `eff' = `w1' * `lodds1'
		forvalues i = 2/`e(k_eq)' {
			qui replace `eff' = `eff' + `w`i'' * `lodds`i''
		}
		gen `typelist' `varlist' = `eff' `if' `in'
		label var `varlist' "effect of `e(ofinterest)' on expected value"
		exit
	}
/*residuals*/
	if "`type'" == "residuals"{
		tempvar y
		qui predict double `y', y
		gen `typelist' `varlist' = `e(depvar)' - `y' if e(sample)
		exit
	}
    error 198
end

program ParseOptions, sclass
	version 8.2, missing
	syntax [,			///
		Outcome(string)		///
		TRANSition(numlist>0 integer max=1) ///
		Choice(numlist>=0 integer max=1) ///
		EQuation(string)        ///
		XB			///
		STDP			///
		TRPr                    ///
		TRVar                   ///
		TRAtrisk                ///
		TRGain                  /// 
		TRMWeight              ///
		TRWeight                ///
		Pr			///
		Y                       ///
		TREFFect                ///
		EFFect                  ///
		RESIDuals               ///
		SCore                   ///
	]

	// check options that take arguments

	if `"`equation'"' != "" & `"`outcome'"' != "" {
		di as err ///
		"options equation() and outcome() may not be combined"
		exit 198
	}
	if `"`equation'"' != "" & `"`transition'"' != "" {
		di as err ///
		"options equation() and transition() may not be combined"
		exit 198
	}
	if `"`equation'"' != "" & `"`choice'"' != "" {
		di as err ///
		"options equation() and choice() may not be combined"
		exit 198
	}


	
	if "`score'" != "" {
		if "`outcome'`transition'`choice'" != "" {
			di as err ///
			"option score may not be combined with options outcome(), transition(), or choice()"
			exit 198
		}
	}
	if `"`pr'"' != "" {
		if `"`equation'`choice'`transition'"' != "" {
			di as err ///
			"options pr may not be combined with the options equation(), choice(), or transition"
			exit 198
		}
	}
	if `"`trpr'"' != "" {
		if `"`transition'"'!="" &`"`choice'"'=="" {
			di as err ///
			"option choice must be specified when using options trpr and transition"
			exit 198
		}
		if `"`transition'"'=="" & `"`choice'"'!="" {
			di as err ///
			"options transition must be specified when using options trpr and choice"
			exit 198
		}
		if "`outcome'`equation'" != "" {
			di as err ///
			"options outcome() and equation() may not be combined with option trpr"
			exit 198
		}
	}
	if `"`trvar'"' != "" {
		if `"`transition'"'!="" & `"`choice'"'=="" {
			di as err ///
			"option choice must be specified when using options trvar and transition"
			exit 198
		}
		if `"`transition'"'=="" &`"`choice'"'!="" {
			di as err ///
			"option transition must be specified when using options trvar and choice "
			exit 198
		}
		if "`outcome'" != "" {
			di as err ///
			"options trvar and outcome() may not be combined"
			exit 198
		}	
	}
	if `"`tratrisk'"' != "" {
		if `"`choice'`outcome'"'!="" {
			di as err ///
			"options choice() and outcome() may not be combined with option tratrisk"
			exit 198
		}
	}
	if `"`trgain'"' != "" {
		if `"`transition'"'=="" & `"`choice'"'!="" {
			di as err ///
			"option choice must be specified when using options trgain and transition"
			exit 198
		}
		if `"`transition'"'!="" & `"`choice'"'=="" {
			di as err ///
			"option transition must be specified when using options trgain and choice"
			exit 198
		}
		if "`outcome'" != "" {
			di as err ///
			"options trgain and outcome() may not be combined"
			exit 198
		}
	}
	if `"`trweight'`trmweight'"' != "" {
		if `"`transition'"'!="" & `"`choice'"'=="" {
			di as err ///
			"option transition() must be specified when using options trweight and choice()"
			exit 198
		}
		if `"`transition'"'=="" & `"`choice'"'!="" {
			di as err ///
			"option choice() must be specified when using options trweight and transition()"
			exit 198
		}
		if `"`choice'"' == "0" {
			di as err ///
			"choice 0 represents the reference category and cannot be combined with option trweight"
			exit 198
		}
		if "`outcome'" != "" {
			di as err ///
			"options trweight and outcome() may not be combined"
			exit 198
		}
	}
	if `"`treffect'"' != "" {
		if `"`transition'"'!="" &`"`choice'"'=="" {
			di as err ///
			"option choice must be specified when using options treffect and transition"
			exit 198
		}
		if `"`transition'"'=="" & `"`choice'"'!="" {
			di as err ///
			"options transition must be specified when using options treffect and choice"
			exit 198
		}
		if "`outcome'`equation'" != "" {
			di as err ///
			"options outcome() and equation() may not be combined with option treffect"
			exit 198
		}
	}
	if `"`y'`residuals'`effect'"' != "" {
		if `"`outcome'`equation'`transition'`choice'"' != "" {
			di as err ///
			"options y, effect, and residuals may not be combined with options equation(), outcome(), transition(), or choice"
			exit 198
		}
	}
	
	// check switch options
	local type `xb' `stdp' `pr' `trpr' `trvar' `tratrisk' `trgain' `trmweight' `trweight' `treffect' `effect' `y' `scores' `score' `residuals'
	if `:word count `type'' > 1 {
		local type : list retok type
		di as err "the following options may not be combined: `type'"
		exit 198
	}

	// parse levels
	local treelevels "`e(treelevels)'"
	local levels "`e(levels)'"
	if "`levels'" == "" {
		foreach lev of local treelevels {
			sreturn local l`lev' = `lev'
		}
	}
	while "`levels'" != "" {
		gettoken exp levels : levels, parse(",")
		gettoken level value : exp, parse("=")
		sreturn local l`level' `value'
		gettoken comma levels : levels, parse(",")
	}

	// parse equation
	if `"`equation'"' != "" | (`"`transition'"' != "" & `"`choice'"' != "") {
		local coleq : coleq e(b), quote
		local coleq : list clean coleq
		local coleq : list uniq coleq
		local neq   : list sizeof coleq

		local eqspec `equation'
		gettoken POUND eqnum : eqspec, parse("#")
		if "`POUND'" == "#" {
			capture {
				confirm integer number `eqnum'
				assert 0 < `eqnum' & `eqnum' <= `neq'
			}
			if (!c(rc)) local eqname : word `eqnum' of `coleq'
		}
		else if `:list eqspec in coleq' {
			forval i = 1/`neq' {
				local eq : word `i' of `coleq'
				if "`eq'" == "`eqspec'" {
					local eqspec "#`i'"
					local eqname `equation'
					local eqnum `i'
					continue, break
				}
			}
		}
		else if "`eqspec'" != "" {
			di as err "equation `eqspec' invalid"
			exit 198
		}
	}

	// save results
	sreturn local type	  `type'
	sreturn local eqspec	`"`eqspec'"'
	sreturn local eqnum       `eqnum'
	sreturn local outcome	`"`outcome'"'
	sreturn local transition  `transition'
	sreturn local choice      `choice'
end

program CheckVars
	version 8.2, missing
	syntax [newvarlist] [,		///
		Outcome(string)		    ///
		TRANSition(numlist>0 integer max=1) ///
		EQuation(string)        ///
		XB			            ///
		STDP			        ///
		TRPr                    ///
		TRVar                   ///
		TRAtrisk                ///
		TRGain                  /// 
		TRWeight                ///
		TRMWeight               ///
		Pr			            ///
		Y                       ///
		TREFFect                ///
		EFFect                  ///
		RESIDuals               /// 
		SCore                   ///
	]
	local nvar : word count `varlist'
	if `nvar' > 1 {
		if "`pr'" != "" {
			if `nvar' != `e(k_cat)' {
				di as err /*
				*/ "`e(depvar)' has `e(k_cat)' outcomes and so you " /*
				*/ "must specify `e(k_cat)' new variables, or " _n /*
				*/ "you can use the outcome() option and specify " /*
				*/ "variables one at a time"
				exit cond(`nvar'<e(k_cat), 102, 103)"
			}				
		}
		else if "`y'`residuals'`xb'`stdp'`outcome'`transition'`equation'" != ""{
			di as err /*
			*/ "only one variable can be specified with the y, xb, stdp, " /*
			*/ "outcome(), transition(), or equation() option"
			exit 103
		}
		else {
			if `nvar' != `e(k_eq)' {
				di as err /*
				*/ "there are `e(k_eq)' transitions so you " /*
				*/ "must specify `e(k_eq)' new variables, or " _n /*
				*/ "you can use the transition(), choice(), or equation() " /*
				*/ "option and specify variables one at a time"
				exit cond(`nvar'<e(k_eq), 102, 103)"
			}
		}
	}
end

program GenScores
        version 8.2
        syntax [newvarlist] [if] [in] [, equation(passthru) ]
        marksample touse, novarlist
        
        ml score `varlist' if `touse', `equation'
end

