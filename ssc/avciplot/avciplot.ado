*! version 1.0.1  23apr2019
program define avciplot, rclass sort
version 11

	_isfit cons newanovaok // check for compatibility with -anova-

	syntax varname (fv ts) [, Level(cilevel) 	///
		noci noCOef CIUnder GENerate(namelist min=2 max=2) ///
		ylim(numlist max=2 ascending) xlim(numlist max=2 ascending) ///
		noDisplay DEBUG *] // undocumented DEBUG option calculates 
			// coefficient from residuals and saves in r(b_check)
			// to verify calculation of residuals

	local v `varlist'
	// see if added variable is included in rhs
	capture _ms_extract_varlist `v'
	local inorig = (c(rc)==0) // included in -xtreg- varlist
	// see if v is a simple variable name
	_ms_parse_parts `v'
	local isvar = (r(type) == "variable")
	// if not, expand fv to use x as dependent variable
	if `isvar' local x `v'
	else {
		fvrevar `v'
		local x `r(varlist)'
	}

	if "`generate'" != "" {
		capture confirm new variable `generate'
		if c(rc) {
			di as err "variable names in {bf:generate(`generate')} option already exist"
			exit 110
		}
	}
	
	_get_gropts , graphopts(`options') ///
		getallowed(Rlopts CIOpts CIPLot addplot)
	local options `"msize(*.75) pstyle(p1) `s(graphopts)'"'
	local rlopts `"lwidth(medthick) pstyle(p2) `s(rlopts)'"'
	local ciplot `"`s(ciplot)'"'
	if ("`ciplot'" == "") {
		local ciplot "rline"
		local ciopts `"lpattern(shortdash) pstyle(p2) `s(ciopts)'"'
	}
	else local ciopts `"pstyle(p7) `s(ciopts)'"'
	local addplot `"`s(addplot)'"'
	_check4gropts rlopts, opt(`rlopts')
	_check4gropts ciopts, opt(`ciopts')

	local v `varlist'
	local wgt "[`e(wtype)' `e(wexp)']"
	tempvar touse e_y e_x hat
	tempname b se_b df_r prev_est

			/* determine if v in original varlist	*/
	if "`e(depvar)'"=="`v'" { 
		di in red "cannot include dependent variable"
		exit 398
	}
	local lhs "`e(depvar)'"
	if "`e(vcetype)'"=="Robust" {
		local robust="robust"
	}
	_getrhs rhs
	gen byte `touse' = e(sample)

	if !`inorig' {	 /* not originally in regression */
		if "`lhs'"=="`v'" { 
			di in red "cannot include dependent variable"
			exit 398
		}
		capture assert `v'!=. if `touse'
		if c(rc) {
			di in red "`v' has missing values" _n ///
				"you must reestimate including `v'"
			exit 398
		}
		// check for collinearity of new variable `x' with 
		// depvar or rhs
		capture _rmdcoll `x' `lhs' `rhs', expand normcoll
		if c(rc) {
			di in red "new variable `v' collinear with variables in" _n ///
			"   `lhs' `rhs' `ivar'"
			exit 459
		}
		quietly _predict double `e_y' if `touse', resid		
		_estimates hold `prev_est'
		quietly { 
			regress `x' `rhs' `wgt' if `touse'
			_predict double `e_x' if `touse', resid
			regress `lhs' `x' `rhs' `wgt' if `touse',	///
				`robust' `cluster'
		}
		scalar `b'    = _b[`x']
		scalar `se_b' = _se[`x']
		scalar `df_r' = e(df_r)
	}
	else {		/* v originally in -regress- rhs */
		local rhs : list rhs - v // remove v from rhs
		if _b[`v']==0 { 
			di in gr "(`v' was dropped from model)"
			exit 399
		}
		scalar `b'    = _b[`v']
		scalar `se_b' = _se[`v']
		scalar `df_r' = e(df_r)
		_estimates hold `prev_est'
		quietly { 
			regress `lhs' `rhs' `wgt' if `touse'
			_predict double `e_y' if `touse', resid
			regress `x' `rhs' `wgt' if `touse'
			_predict double `e_x' if `touse', resid
		}
	}

	ret scalar coef = `b'
	ret scalar se = `se_b'
	gen `hat' = `b'*`e_x'

	if "`debug'"!="" {
		qui _regress `e_y' `e_x', nocons
		return scalar b_check = _b[`e_x']
	}

	_estimates unhold `prev_est'
	
	capture local xttl : var label `v'  // capture because v could be factor variable
	local yttl : var label `lhs'
	if "`xttl'"=="" local xttl `v'
	if "`yttl'"=="" local yttl `lhs'
	label var `e_x' "e( `xttl' | X )"
	label var `e_y' "e( `yttl' | X )"
	local xttl : var label `e_x'
	local yttl : var label `e_y'
	if "`generate'"!="" {
		local exvar : word 1 of `generate'
		local eyvar : word 2 of `generate'
		generate double `exvar' = `e_x'
		generate double `eyvar' = `e_y'
		label variable `exvar' "`xttl'"
		label variable `eyvar' "`yttl'"
	}
	if "`display'"=="" { // only show graph if not -nodisplay-
		if ("`robust'"=="robust") local robust "(robust) "
		if ("`coef'" == "") {
			local t : display %5.2f `=return(coef)/return(se)'
			local b : display %9.0g return(coef)
			local se : display %9.0g return(se)
			local note `"note("coef = `b', `robust'se = `se', t = `t'")"'
		}
	
		if `"`addplot'"' == "" {
			local legend legend(nodraw)
		}
		if ("`ylim'`xlim'"!="") {
			local yn : word count `ylim'
			if (`yn'>0) {
				if (`yn'==2) local ifyx ///
				   "`e_y' > `:word 1 of `ylim'' & `e_y' < `:word 2 of `ylim''"
				else local ifyx "`e_y' > `ylim'"
			}
			local xn : word count `xlim'
			if (`xn'>0) {
				if ("`ifyx'"!="") local ifyx "`ifyx' &"
				if (`xn'==2) local ifyx ///
				   "`ifyx' `e_x' > `:word 1 of `xlim'' & `e_x' < `:word 2 of `xlim''"
				else local ifyx "`ifyx' `e_x' > `xlim'"
			}
			local ifyx "if `ifyx'"
		}
		if ("`ci'"=="") { // create confidence intervals
			tempvar dev ci_l ci_u			
			tempname t_a
			scalar `t_a'  = invttail(`df_r',(1-`level'/100)/2)
			gen `dev' = `t_a'*`se_b'*`e_x'
			gen `ci_l' = `hat' - `dev'
			gen `ci_u' = `hat' + `dev'
			if ("`ciunder'"!="") /// create confidence intervals
				local gr_ci_und "|| `ciplot' `ci_l' `ci_u' `e_x' `ifyx', pstyle(p2) `ciopts' "	
			else local gr_ci_ovr "|| `ciplot' `ci_l' `ci_u' `e_x' `ifyx', pstyle(p2) `ciopts' "
		}
		sort `e_x', stable
	
		graph twoway									///
			`gr_ci_und'									///
			|| scatter `e_y' `e_x' `ifyx', 				///
				ytitle(`"`yttl'"') xtitle(`"`xttl'"')	///
				`note' `legend' `options'				///
			`gr_ci_ovr'									///
			|| line `hat' `e_x' `ifyx', `rlopts'		///
			|| `addplot'
	}
end
