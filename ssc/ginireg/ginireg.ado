*! ginireg 1.0.05  24Jan2015
*! author mes
*  General notes:
*    Supports time series operators but not factor variables.
*    Requires ginicumul fn for empirical CDF that handles ties using midpoint method.

program define ginireg, eclass

	version 10.1
	local lversion 01.0.05
	if replay() {
		syntax [, 												///
			VERsion replay usemodel(name)						///
			*													///
			]

		if "`version'" != "" {					// Reports program version number, then exits
			di in gr "`lversion'"
			ereturn clear
			ereturn local version `lversion'
			exit
		}
	}
	else {
		syntax [anything(name=0)] [if] [in] [aw pw fw]  ,				///
				[														///
					extended(varlist ts)								///
					nu(real 2)											///
					nogini(varlist ts)									///
					VCE(passthru)										///
					NOConstant											///
				]

		parse_iv `0'
		local depvar	"`r(depvar)'"
		local inexog 	"`r(inexog)'"
		local exexog	"`r(exexog)'"
		local endo		"`r(endo)'"
		capture tsunab nogini	: `nogini'
		capture tsunab extended	: `extended'

* Variables come back from parse_iv tsunab-ed.  Save order for final results.
* Standard Stata order: [endogenous exogenous _cons]
		local varorder	"`endo' `inexog'"
		if "`noconstant'"=="" {
			local varorder	"`varorder' _cons"
		}

* Weight support.
* For estimation, fw, aw and pw supported.
* BUT ... some internal Stata commands (e.g., sum, cumul) do NOT support pw but DO support aw.
* So we need wexp for estimation, and wexpa for these special commands.
		if "`weight'"~="" {
			tempvar wvar
			qui gen double `wvar' `exp'
			local wexp [`weight'`exp']
			if "`weight'"=="pweight" {
				local wexpa [aw`exp']	// note hack - for some commands, aw mimics what pw would report if supported
			}
			else if "`weight'"=="fweight" {
				local wexpa [fw`exp']
			}
			else if "`weight'"=="aweight" {
				local wexpa [aw`exp']
			}
			else {		// should never reach this point
di as err "internal ginireg error - unsupported weight type `weight'"
				exit 198
			}
		}

********************************************************************************

		marksample touse
		markout `touse' `depvar' `inexog' `exexog' `endo' `wvar', strok
		
		local cons = ("`noconstant'"=="")
		
* Calculate N.  N=sum(weights).
* sum does not support pw so use `wexpa' instead of `wexp'.
		qui sum `touse' `wexpa', meanonly
		local N = r(sum)

* Confirm gini vars are in inexog or exexog
* Confirm extended gini is in inexog and not in nogini
* Should check for dups at some point
		local gini_inexog	: list inexog - nogini
		local gini_inexog	: list gini_inexog - extended
		local gini_exexog	: list exexog - nogini
		local gini_all		: list gini_inexog | gini_exexog
		local nogini_inexog	: list inexog - gini_inexog
		local nogini_inexog	: list nogini_inexog - extended
		local nogini_exexog	: list exexog - gini_exexog
		local nogini_all	: list nogini_inexog | nogini_exexog
		local nogini_endo	"`endo'"						// explicitly endogenous regressors are untransformed

		local check			: list extended - inexog
		local check_ct		: word count `check'
		if `check_ct' {
di as err "error: `check' in extended(.) but not specified as exogenous regressor(s)"
			exit 198
		}

		local check			: list extended & nogini
		local check_ct		: word count `check'
		if `check_ct' {
di as err "error: `check' in extended(.) and in nogini(.)"
			exit 198
		}

		local check			: list nogini - nogini_all
		local check_ct		: word count `check'
		if `check_ct' {
di as err "error: `check' in nogini(.) but not specified as exogenous regressor(s) or instrument(s)"
			exit 198
		}

* Counts. Include constant.
		local gini_inexog_ct	: word count `gini_inexog'
		local gini_exexog_ct	: word count `gini_exexog'
		local nogini_inexog_ct	: word count `nogini_inexog'
		local nogini_exexog_ct	: word count `nogini_exexog'
		local extended_ct		: word count `extended'
		local endo_ct			: word count `endo'
		local inexog_ct			: word count `inexog'
		local inexog_ct			= `inexog_ct' + `cons' - `gini_inexog_ct'

* Gini inexog regressors => endogenous with Gini transform as exexog IVs.
* Extended Gini regressors the same as Gini regressors.
* Gini exexog IV => exexog IVs replaced by Gini transform as exexog IVs.

		foreach var of local gini_inexog {
			local inexog	: list inexog - var
			local endo		"`endo' `var'"
			tempvar rankvar ginivar
			qui ginicumul `var' if `touse' `wexpa', gen(`ginivar')
			local exexog	"`exexog' `ginivar'"
		}
		foreach var of local gini_exexog {
			local exexog	: list exexog - var
			tempvar rankvar ginivar
			qui ginicumul `var' if `touse' `wexpa', gen(`ginivar')
			local exexog	"`exexog' `ginivar'"
		}
		foreach var of local extended {
			local inexog	: list inexog - var
			local endo		"`endo' `var'"
			tempvar rankvar ginivar
			qui ginicumul `var' if `touse' `wexpa', gen(`ginivar') extended nu(`nu')
			local exexog	"`exexog' `ginivar'"
		}


		tempname b V
		if `:length local vce' {
			 _vce_parserun ginireg, eq(NOConstant) noeqlist : 						///
			 	`0' `wexpa' `if' `in', 												///
			 	nogini(`nogini') `vce' `noconstant' extended(`extended')
		}
		else {
			qui reg `depvar' `endo' `inexog' (`exexog' `inexog') if `touse' `wexp', `noconstant'
		}

		mat `b'=e(b)
		mat `V'=e(V)

* Put variables in original/standard Stata order: [ endog exog ]
		tempname newb newV col newcol row newrow
		local k = colsof(`b')
		mat `newb'=J(1,`k',0)
		mat `newV'=J(`k',`k',0)
		mat colnames `newV' = `varorder'
		mat rownames `newV' = `varorder'
		mat colnames `newb' = `varorder'
		mat rownames `newb' = y1
		foreach vname of local varorder {				//  column loop
			scalar `col' = colnumb(`b',"`vname'")
			scalar `newcol' = colnumb(`newb',"`vname'")
			mat `newb'[1,`newcol'] = el(`b',1,`col')
			foreach vname2 of local varorder {			//  row loop
				scalar `row' = rownumb(`V',"`vname2'")
				scalar `newrow' = rownumb(`newV',"`vname2'")
				mat `newV'[`newrow',`newcol'] = el(`V',`row',`col')
			}
		}

* Goodness-of-Fit.  See Yitzhaki-Schechtman (2013), pp. 18, 53, 159-60.
		tempvar ranky giniy e ranke ginie yhat rankyhat giniyhat
		qui ginicumul `depvar' if `touse' `wexpa', gen(`giniy')
		qui predict double `e' if `touse', resid
		qui ginicumul `e' if `touse' `wexpa', gen(`ginie')
		qui gen double `yhat'=`depvar'-`e' if `touse'
		qui ginicumul `yhat' if `touse' `wexpa', gen(`giniyhat')
		tempname deltay deltayhat deltae covyfyhat covyhatfy gr gyyh gyhy
		qui correlate `depvar' `giniy' if `touse' `wexpa', cov
		scalar `deltay'=r(cov_12)
		qui correlate `yhat' `giniyhat' if `touse' `wexpa', cov
		scalar `deltayhat'=r(cov_12)
		qui correlate `e' `ginie' if `touse' `wexpa', cov
		scalar `deltae'=r(cov_12)
		qui correlate `depvar' `giniyhat' if `touse' `wexpa', cov
		scalar `covyfyhat'=r(cov_12)
		qui correlate `yhat' `giniy' if `touse' `wexpa', cov
		scalar `covyhatfy'=r(cov_12)
		scalar `gr'		= `deltayhat'/`deltay'
		scalar `gyyh'	= `covyfyhat'/`deltay'
		scalar `gyhy'	= `covyhatfy'/`deltayhat'

		ereturn post `newb' `newV', depname(`depvar') obs(`N') esample(`touse')
		ereturn scalar gr			=`gr'
		ereturn scalar gyyh			=`gyyh'
		ereturn scalar gyhy			=`gyhy'
		if `extended_ct' {
			ereturn scalar nu		=`nu'
		}
		ereturn local estat_cmd		"ginireg_estat"
		ereturn local predict		"ginireg_p"
		ereturn local gini_inexog	"`gini_inexog'"
		ereturn local gini_exexog	"`gini_exexog'"
		ereturn local nogini_inexog	"`nogini_inexog'"
		ereturn local nogini_exexog	"`nogini_exexog'"
		ereturn local extended		"`extended'"
		ereturn local endo			"`nogini_endo'"
		ereturn local cmd			"ginireg"
		ereturn local depvar		"`depvar'"

* Display output
		di										//  Blank line
		di as text "Gini regression"
		di
		di _col(56) as text "Number of obs = " as res %7.0f e(N)
		di _col(56) as text "GR            = " as res %7.3f e(gr)
		di _col(56) as text "Gamma YYhat   = " as res %7.3f e(gyyh)
		di _col(56) as text "Gamma YhatY   = " as res %7.3f e(gyhy)
		ereturn display

		di in gr "Gini regressors:" _c
		Disp `e(gini_inexog)', _col(28)
		if `cons' {
			local consdisp "_cons"
		}
		if `extended_ct'>0 {
			di in gr "Extended Gini regressors:" _c
			Disp `e(extended)', _col(28)
		}
		di in gr "Least squares regressors:" _c
		Disp `e(nogini_inexog)' `consdisp', _col(28)
		if `endo_ct'>0 {
			di in gr "Endogenous:" _c
			Disp `e(endo)', _col(28)
		}
		if `gini_exexog_ct'>0 {
			di in gr "Gini excluded IVs:" _c
			Disp `e(gini_exexog)', _col(28)
		}
		if `nogini_exexog_ct'>0 {
			di in gr "Other excluded IVs:" _c
			Disp `e(nogini_exexog)', _col(28)
		}
		di in gr "{hline 78}"

	}		
end	

*******************************************************************************
*******************************************************************************
*******************************************************************************

program define parse_iv, rclass
	version 10.1

		local n 0

		gettoken depvar 0 : 0, parse(" ,[") match(paren)
		IsStop `depvar'
		if `s(stop)' { 
			error 198 
		}
		while `s(stop)'==0 { 
			if "`paren'"=="(" {
				local n = `n' + 1
				if `n'>1 { 
capture noi error 198
di in red `"syntax is "(all instrumented variables = instrument variables)""'
exit 198
				}
				gettoken p depvar : depvar, parse(" =")
				while "`p'"!="=" {
					if "`p'"=="" {
						capture noi error 198 
di as err `"syntax is "(endogenous regressor = instrument variables)""'
di as err `"the equal sign "=" is required"'
						exit 198 
					}
					local endo `endo' `p'
					gettoken p depvar : depvar, parse(" =")
				}
				local temp_ct  : word count `endo'
				if `temp_ct' > 0 {
					tsunab endo : `endo'
				}
* ???
* To enable OLS estimator with (=) syntax, allow for empty exexog list
				local temp_ct  : word count `depvar'
				if `temp_ct' > 0 {
					tsunab exexog : `depvar'
				}
			}
			else {
				local inexog `inexog' `depvar'
			}
			gettoken depvar 0 : 0, parse(" ,[") match(paren)
			IsStop `depvar'
		}
		local 0 `"`depvar' `0'"'

		tsunab inexog : `inexog'
		tokenize `inexog'
		local depvar "`1'"
		local 1 " " 
		local inexog `*'

		return local depvar	"`depvar'"
		return local inexog	"`inexog'"
		return local exexog	"`exexog'"
		return local endo	"`endo'"

end

program define IsStop, sclass
				/* sic, must do tests one-at-a-time, 
				 * 0, may be very large */
	version 8.2
	if `"`0'"' == "[" {		
		sret local stop 1
		exit
	}
	if `"`0'"' == "," {
		sret local stop 1
		exit
	}
	if `"`0'"' == "if" {
		sret local stop 1
		exit
	}
* per official ivreg 5.1.3
	if substr(`"`0'"',1,3) == "if(" {
		sret local stop 1
		exit
	}
	if `"`0'"' == "in" {
		sret local stop 1
		exit
	}
	if `"`0'"' == "" {
		sret local stop 1
		exit
	}
	else	sret local stop 0
end

program define Disp 
	version 8.2
	syntax [anything] [, _col(integer 15) ]
	local len = 80-`_col'+1
	local piece : piece 1 `len' of `"`anything'"'
	local i 1
	while "`piece'" != "" {
		di in gr _col(`_col') "`first'`piece'"
		local i = `i' + 1
		local piece : piece `i' `len' of `"`anything'"'
	}
	if `i'==1 { 
		di 
	}
end
