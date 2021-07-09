*! 1.3.0 MLB 14Feb2017
*  1.2.2 MLB 11Okt2011
*  1.0.0 MLB 11 Nov 2008

program define fmlogit_p
        version 8.2

	syntax [anything] [if] [in] [,  ///
		PR                          ///
        XB	                        ///
		STDP		                ///
		SCores                      ///
		EQuation(passthru)          ///
		OUTcome(string)             ///
		*                           ///  
		]
	/*Parsing new variables*/
	sreturn clear
	local depvars "`e(depvars)'"
	local k : word count `depvars'
	
	if "`xb'`stdp'`scores'" != "" {
		local ncat = `k' - 1
	}
	else {
		local ncat = `k'
	}

	* scores */
	local types "double float"
	local newvar : list anything - types
	if "`score'" != "" {
		GenScores `newvar' `if' `in', `eqn'
		sret clear
		exit
	}
/* XB, or STDP. */
	if c(stata_version) < 9 & "`xb'`stdp'`score'" == "" {
		local xb "xb"
	}
	if "`xb'"!= "" | "`stdp'" != "" {
		_predict `anything' `if' `in', `xb' `stdp' `equation'
		if "`xb'" != ""  {
			label var `newvar' /*
			*/ "Linear prediction for equation `eq'"
		}
		else { /* stdp */
			label var `newvar' /*
			*/ "S.E. of linear prediction for equation `eq'"
		}
		exit
	}
	if c(stata_version) < 9 & "`pr'" != "" {
		di as err "the pr option is only available after stata version 9"
		exit 198
	}
	_stubstar2names `anything', nvars(`ncat') singleok
	local varlist    "`s(varlist)'"
	local typelist   "`s(typlist)'"
	
	if "`xb'`stdp'`scores'" != "" & "`outcome'" != "" {
		di as err "option outcome() may not be combined with option `xb'`stdp'`scores'"
		exit 198
	}
	if ("`xb'`stdp'`scores'`pr'" == "" | "`pr'" != "") & "`equation'" != "" {
		di as err "option equation() may not be combined with option pr"
		exit 198
	}

/* single pr*/
	if ("`pr'" != "" | "`pr'`xb'`stdp'`scores'" == "") & `: word count `varlist'' == 1 {
		gettoken ref rest : depvars
		if "`outcome'" == "" {
			// the default outcome is the first depvar, i.e. the reference category
			local outcome "`ref'"
		}
		if !`: list outcome in depvars' {
			di as err ///
			"variable specified in outcome() must be one of `depvars'"
			exit 198
		}
		local i = 1
		tempvar denom
		qui gen double `denom' = 1
		foreach eq of local rest {
			tempvar xb`i'
			qui _predict double `xb`i'', xb equation(#`i')
			qui replace `denom' = `denom' + exp(`xb`i'')
			local `i++'
		}
		local k : list posof "`outcome'" in depvars
		if `k' == 1 {
			gen `typelist' `varlist' = 1/`denom'
			label variable `varlist' "predicted proportion for outcome `outcome'"
		}
		else {
			gen `typelist' `varlist' = exp(`xb`=`k'-1'')/`denom'
			label variable `varlist' "predicted proportion for outcome `outcome'"
		}
		exit
	}
/* multiple pr*/
	if ("`pr'" != "" | "`pr'`xb'`stdp'`scores'" == "") & `: word count `varlist'' > 1 {
		gettoken ref rest : depvars
		local i = 1
		tempvar denom
		qui gen double `denom' = 1
		foreach eq of local rest {
			tempvar xb`i'
			qui _predict double `xb`i'', xb equation(#`i')
			qui replace `denom' = `denom' + exp(`xb`i'')
			local `i++'
		}
		tokenize `typelist'
		local j = 1
		foreach var of local varlist {
			if `j' == 1 {
				gen ``j'' `var' = 1/`denom'
				label variable `var' "predicted proportion for outcome `: word `j' of `depvars''"
			}
			else {
				gen ``j'' `var' = exp(`xb`=`j'- 1'')/`denom'
				label variable `var' "predicted proportion for outcome `: word `j' of `depvars''"
			}
			local `j++'
		}
		exit
	}

	exit 198
end

program GenScores
        version 8.2
        syntax [newvarlist] [if] [in] [, equation(passthru) ]
        marksample touse, novarlist
        
        ml score `varlist' if `touse', `equation'
end
