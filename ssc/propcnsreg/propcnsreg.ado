*! version 1.7.2 MLB 25 Jan 2013
// makes sure vce() option is also passed on to initial values and Wald test calculations
*! version 1.7.0 MLB 23 Okt 2012
// quicker starting values
// clean up estimation results at the end 
// avoid overwriting existing stored estimation results
// Wald test optional or when lr test not appropriat
// allow vce(bootstrap) and vce(jackknife)
*! version 1.6.0 MLB 06 Sep 2012
*! version 1.5.1 MLB 22 Jun 2011
*! version 1.5.0 MLB 15 Mar 2010
*! version 1.3.1 MLB 05 Jan 2010
*! version 1.3.0 MLB 18 Dec 2009
*! version 1.2.0 MLB 30 Aug 2009
*! version 1.1.0 MLB 21 Mar 2009
*! version 1.0.4 MLB 31 Aug 2008
*! version 1.0.3 MLB 24 Aug 2008
*! version 1.0.2 MLB 31 Aug 2007
*! version 1.0.1 MLB 09 Aug 2007
*! version 1.0.0 MLB 28 Jul 2007
program propcnsreg, eclass byable(onecall) properties(irr or)
	if c(stata_version) >= 11 {
		version 11
	}
	else {
		version 9
	}
	if _by() {
		local BY `"by `_byvars'`_byrc0':"'
	}
	`BY' _vce_parserun propcnsreg : `0'
	if "`s(exit)'" != "" {
		ereturn local cmdline `"propcnsreg `0'"'
		exit
	}
	
	if replay() {
		if "`e(cmd)'" != "propcnsreg" {
			di as err "results for propcnsreg not found"
			exit 301
		}
		if _by() error 190 
		Display `0'
		exit `rc'
	}
	`BY' Estimate `0'
end

/*------------------------------------------- start estimation */
program Estimate, eclass byable(recall)
	syntax varlist(numeric ) [if] [in] [pw fw aw iw /] ,  ///
		CONstrained(string) LAMBDA(varlist numeric ) ///
		[Robust Cluster(varname) Level(integer $S_level) ///
		unit(varname) lcons STANDardized mimic logit poisson ///
		noLOG  bic method(string) or IRr wald * ]

	Parseconstrained `constrained'
	local constrained `s(constrained)'
	local key `s(key)'
	local minuskey `s(minuskey)'

	gettoken y unconstrained: varlist
	marksample touse 
	markout `touse' `varlist' `constrained' `lambda' `cluster'
	
	if "`logit'" != "" {
		qui count if !inrange(`y',0,1) & `touse'
		if r(N) > 0 {
			di as txt r(N) " observations on `y' take values other than 0 or 1, these will be ignored"
			qui replace `touse' = 0 if !inrange(`y',0,1) & `touse'
		}
	}
	if "`poisson'" != "" {
		qui count if `y' < 0 & `touse'
		if r(N) > 0 {
			di as txt r(N) " observations on `y' take values less than 0, these will be ignored"
			qui replace `touse' = 0 if `y' < 0 & `touse'
		}
		qui count if mod(`y',1) != 0 & `touse' // check whether `y' contains only integers
		if r(N) > 0 {
			di as txt "note: you are responsible for interpretation of noncount dep. variable"
		}
	}
	qui count if `touse' 
	if r(N) == 0 error 2000 
	
	if "`weight'" != "" local wgt `"[`weight' = `exp']"'
	
	if "`wald'" != "" & "`mimic'" != "" {
		di as err "options wald and mimic may not be combined"
		exit 198
	}
	mlopts mlopts, `options' 
	robust_chk, `mlopts'
	if "`cluster'" != ""  | "`weight'" == "pweight" | "`robust'" != "" ///
	 | "`r(robust)'" != "" {
		// Wald test is default when using robust standard errors
		local wald "wald"
	}
	
	
	_rmcoll `lambda' `wgt' if `touse'
	local lambda "`r(varlist)'"

	_rmcoll `constrained' `wgt' if `touse'
	local constrained "`r(varlist)'"

	qui _rmcoll `lambda' `unconstrained' `wgt' if `touse'
	if r(k_omitted) == 0 {
		di as txt "Warning: Propcnsreg estimates a model with an interaction effect."
		di as txt "         The main effects of the variables specified in constrained()"
		di as txt "         are automatically entered, but the main effects of the" 
	    di as txt "         variables specified in lambda() need to be entered in indepvars."
		di as txt "         This appears not to have happened."
	}
	
	if "`logit'`poisson'" == "" {
		local reg "reg"
	}
	
	if "`mimic'" != "" {
		local title "ML fit of MIMIC model"
	}
	else if "`logit'`poisson'" == "" {
		local title "ML fit of linear regression with a proportionality constrained"
	}
	else {
		local title "ML fit of `logit'`poisson' regression with a proportionality constrained"
	}
	
	local ok : list unit in constrained
	if !`ok' {
		di as err "variable specified in unit must also be specified in constrained"
		exit 198
	}
	
	/*Only one identifying constraint allowed*/
	if "`lcons'" != "" & "`unit'" != "" & "`standardized'" != ""{
		di as err "options lcons, unit(), and standardized may not be combined"
		exit 198
	}
	if "`lcons'" != "" & "`unit'" != "" {
		di as err "options lcons and unit() may not be combined"
		exit 198
	}
	if "`lcons'" != "" & "`standardized'" != "" {
		di as err "options lcons and standardized may not be combined"
		exit 198
	}
	if "`standardized'" != "" & "`unit'" != "" {
		di as err "options standardized and unit() may not be combined"
		exit 198
	}

	/*Option standardized is default*/
	if "`lcons'`unit'`standardized'" == "" {
		local standardized "standardized"
	}
	
	if "`standardized'" == "" & "`key'" != "" {
		di as err "a key variable can only be specified in the lambda() option when the standardized option is also specified"
		exit 198
	}
	
	/*I don't know how to identify a mimic model within a logit or poisson model*/
	if "`mimic'" != "" & "`logit'`poisson'" != "" {
		di as err "options mimic may not be combined with logit or poisson"
		exit 198
	}
	
	/*option standardized depends on first estimating the model with the lcons option*/
	if "`standardized'" != "" {
		local lcons "lcons"
	}
	
	if "`unit'" != "" {
		local unitopt "unit(`unit')"
	}
	
	if "`cluster'" != "" { 
		local robust "robust"
		local clopt "cluster(`cluster')" 
	}

	/*option or only with logit; option irr only with poisson*/
	if "`or'" != "" & "`poisson'`reg'" != "" {
		di as err "option or can only be specified in combination with option logit"
		exit 198
	}
	if "`irr'" != "" & "`logit'`reg'" != "" {
		di as err "option irr can only be specified in combination with option poisson"
		exit 198
	}
	
	if "`level'" != "" local level "level(`level')"
    local log = cond("`log'" == "", "noisily", "quietly") 
	
	local lunc : word count `unconstrained'
	local lc : word count `constrained'
	local lla : word count `lambda'

	tempname cns uncns
	
	Geninit `varlist' `wgt' if `touse', ///
	    cmd(`reg'`logit'`poisson') ///
		constrained(`constrained') lambda(`lambda') ///
		`robust' `clopt' `unitopt' `lcons'  ///
		uncns(`uncns') `mlopts'
	
	tempname ll_u ll_0 init w_df w_p
	scalar `ll_u'   = r(ll_u)
	scalar `ll_0'   = r(ll_0)
	matrix `init'   = r(init)
	
	// local waldtest will be passed on as options to Display
	scalar `w_df'   = r(w_df)
	scalar `w_p'    = r(w_p)
	if "`r(w_chi2)'" != "" {
		tempname w_chi2
		scalar `w_chi2' = r(w_chi2)
		local waldtest "w_chi2(`=`w_chi2'') w_df(`=`w_df'') w_p(`=`w_p'')"
	}
	else {
		tempname w_f w_df_r
		scalar `w_f'    = r(w_f)
		scalar `w_df_r' = r(w_df_r)
		local waldtest "w_f(`=`w_f'') w_df_r(`=`w_df_r'') w_df(`=`w_df'') w_p(`=`w_p'')"
	}

	if "`unit'" != "" {
		local constr "[constrained]`unit' = 1"
	}
	else {
		local constr "[lambda]_cons = 1"
	}
	constraint free
	local c = r(free)
	constraint `c' `constr'

	if c(stata_version) >= 11 {
		local negh "negh"
		if "`method'" == "" {
			local method "e2"
		}
		else {
			if `: word count `method'' > 1 {
				di as err "method() can only contain one method"
				exit 198
			}
			local valid "lf d0 e1 e2"
			local ok : list method in valid
			if !`ok' {
				di as err "method() can contain only lf, d0, e1, or e2"
				exit 198
			}
		}
	}
	else {
		if "`method'" == "" {
			local method "d2"
		}
		else {
			if `: word count `method'' > 1 {
				di as err "method() can only contain one method"
				exit 198
			}
			local valid "lf d0 d1 d2"
			local ok : list method in valid
			if !`ok' {
				di as err "method() can contain only lf, d0, d1, or d2"
				exit 198
			}
		}
	}
	if "`method'" == "lf" {
		local progn "lf"
	}
	else {
		local progn "e2"
	}
	if "`logit'`poisson'" == "" {
		local ln_sigma "/ln_sigma"
	}
	
	if "`mimic'" == "" {
		`log' ml model `method' propcns`reg'`logit'`poisson'_`progn' /*
		               */ (unconstrained: `y' = `unconstrained' )   /*
        	           */ (lambda: `lambda') (constrained: `constrained', nocons)      /*
        	           */  `ln_sigma' /*
        	           */ `wgt' if `touse', maximize search(off)  title(`title') /*
        	           */ init(`init') constraint(`c') `negh' waldtest(0) /*
        	           */ `robust' `clopt' `level' `mlopts' `stdopts' `modopts' 
    }
    else {
		`log' ml model `method' mimic_`progn' (unconstrained: `y' = `unconstrained' )   /*
	     	           */ (lambda: `lambda') (constrained: `constrained', nocons)      /*
	       	           */ /ln_sigma /ln_sigma_latent /*
	       	           */ `wgt' if `touse', maximize search(off)  title(`title') /*
	       	           */ init(`init') constraint(`c') `negh' waldtest(0) /*
	       	           */ `robust' `clopt' `level' `mlopts' `stdopts' `modopts' 
    }
	est store `cns'
	
	if "`standardized'" != "" {
		if "`key'" == "" {
			local sign = 1
		}
		else {
			local sign = cond(`minuskey', -1, 1)*sign([constrained]_b[`key'])
		}
		tempname b v
		noi {
			mata : Standardize()
		}
		
		local unconstrained2 : subinstr local unconstrained " " " unconstrained:", all
		local constrained2 : subinstr local constrained " " " constrained:", all
		local lambda2 : subinstr local lambda " " " lambda:", all
		if "`logit'`poisson'" == "" {
			local sigma "sigma:_cons"
		}
		if "`mimic'" != "" {
			local sigma "`sigma' sigma_latent:_cons"
		}
		
		if "`or'`irr'" != "" & c(stata_version) < 12 { // add an extra underscore to the constant of the lambda equation
			matrix colnames `b' = `unconstrained2' unconstrained:_cons lambda:`lambda2' lambda:__cons constrained:`constrained2' `sigma'
			matrix colnames `v' = `unconstrained2' unconstrained:_cons lambda:`lambda2' lambda:__cons constrained:`constrained2' `sigma'
			matrix rownames `v' = `unconstrained2' unconstrained:_cons lambda:`lambda2' lambda:__cons constrained:`constrained2' `sigma'
		}
		else {
			matrix colnames `b' = `unconstrained2' unconstrained:_cons lambda:`lambda2' lambda:_cons constrained:`constrained2' `sigma'
			matrix colnames `v' = `unconstrained2' unconstrained:_cons lambda:`lambda2' lambda:_cons constrained:`constrained2' `sigma'
			matrix rownames `v' = `unconstrained2' unconstrained:_cons lambda:`lambda2' lambda:_cons constrained:`constrained2' `sigma'
		}
	
		Post, b(`b') v(`v') cns(`cns')
	}
	if "`unit'" != "" & "`or'`irr'" != "" & c(stata_version) < 12 { // add an extra underscore to the constant of the lambda equation
		tempname b v
		matrix `b' = e(b)
		matrix `v' = e(V)
		local unconstrained2 : subinstr local unconstrained " " " unconstrained:", all
		local constrained2 : subinstr local constrained " " " constrained:", all
		local lambda2 : subinstr local lambda " " " lambda:", all
		if "`logit'`poisson'" == "" {
			local sigma "sigma:_cons"
		}
		if "`mimic'" != "" {
			local sigma "`sigma' sigma_latent:_cons"
		}
		matrix colnames `b' = `unconstrained2' unconstrained:_cons lambda:`lambda2' lambda:__cons constrained:`constrained2' `sigma'
		matrix colnames `v' = `unconstrained2' unconstrained:_cons lambda:`lambda2' lambda:__cons constrained:`constrained2' `sigma'
		matrix rownames `v' = `unconstrained2' unconstrained:_cons lambda:`lambda2' lambda:__cons constrained:`constrained2' `sigma'

		Post, b(`b') v(`v') cns(`cns')
	}
	
	
	if "`logit'`poisson'" == "" {
		ereturn scalar df_m = `lunc' + `lc' + `lla' + 1
	}
	else {
		ereturn scalar df_m = `lunc' + `lc' + `lla'
	}
	
	ereturn scalar ll_0 = `ll_0'
	ereturn scalar ll_u = `ll_u'
	if "`lcons'" != "" & "`standardized'" == ""  {
		ereturn scalar k_eform = 3
	}
	else {
		ereturn scalar k_eform = 2
	}
	
	ereturn local model `"`=cond("`mimic'"=="","`reg'","`mimic'")'`poisson'`logit'"'
	
	if "`standardized'" != "" {
		local id_constr "sd of latent variables = 1"
	}
	else if "`unit'" != "" {
		local id_constr "[constrained]`unit' = 1"
	}
	else {
		local id_constr "[lambda]_cons = 1"		
	}
	ereturn local id_constr "`id_constr'"
	if "`key'" != "" {
		ereturn local key "`key'"
		ereturn scalar keysign = `=cond(`minuskey',-1,1)'
	}
	*ereturn local chi2type "LR"
	ereturn local predict       "propcnsreg_p"
	ereturn local lambda        "`lambda'"
	ereturn local constrained   "`constrained'"
	ereturn local unconstrained "`unconstrained'"
	constraint drop `c'
	
	Display `wgt', `clopt' `level' `mimic' ///
	`bic' `or' `irr' `logit' `poisson' ///
	cns(`cns') uncns(`uncns') `waldtest' `wald'
	
	if "`wald'" == "" & "`mimic'" == "" {
		ereturn scalar lr_chi2 = r(lr_chi2)
		ereturn scalar lr_df   = r(lr_df)
		ereturn scalar lr_p    = r(lr_p)
	}
	if "`mimic'" == "" {
		if "`w_chi2'" != "" {
			ereturn scalar w_chi2 = `w_chi2'
		}
		else {
			ereturn scalar w_f = `w_f'
			ereturn scalar w_df_r = `w_df_r'
		}
		ereturn scalar w_df = `w_df'
		ereturn scalar w_p = `w_p'
	}
	ereturn local cmd "propcnsreg"
	
	estimates drop `uncns' `cns'
	
end

/*---------------------------------------------- end estimation */

/*------------------------------------- start Parse constrained */
program define Parseconstrained, sclass
	local constrained `"`0'"'
	local plus "+"
	local minus "-"
	local k : word count `constrained'
	tokenize `constrained'
	forvalues i = 1/`k' {
		local `i' : subinstr local `i' "+" " + ", all
		local `i' : subinstr local `i' "-" " - ", all
		local minuskey : list minus in `i'
		local pluskey : list plus in `i'
		if `minuskey' | `pluskey' {
			local `i' : subinstr local `i' " + " "", all
			local `i' : subinstr local `i' " - " "", all
			${fv}unab var : ``i''
			local key "`key' `var'"
		}
	}
	if `:word count `key'' > 1 {
		di as err "More than one variable in option lambda() was defined as a key variable"
		exit 198
	}
	local constrained : subinstr local constrained "+" "", all
	local constrained : subinstr local constrained "-" "", all
	confirm numeric variable `constrained'
	
	sreturn local constrained `constrained'
	sreturn local key `key'
	sreturn local minuskey `minuskey'
end
/*--------------------------------------- end Parse constrained */

/*---------------------------------------- start initial values */
program Geninit, rclass
	syntax varlist(numeric ) [if] [pw fw aw iw], ///
	constrained(varlist) lambda(varlist) cmd(string) ///
	[Robust Cluster(varname) unit(varname) lcons     ///
	uncns(string) vce(passthru) *]
	
	gettoken y unconstrained: varlist

	marksample touse 
	markout `touse' `varlist' `constrained' `lambda' `cluster'
	
	if "`weight'" != "" local wgt `"[`weight'`exp']"'  

	if "`cluster'" != "" { 
		local robust "robust"
		local clopt "cluster(`cluster')" 
	}

	if "`cmd'" == "logit" {
		qui count if `touse' & (`y' > 0 & `y' < 1) 
		if r(N) > 0 {
			local cmd "glm"
			local link "family(binomial) link(logit)"
		}
	}

	gettoken y unconstrained : varlist

	local nc : word count `constrained'
	local nl : word count `lambda'
	local nu : word count `unconstrained'

	tempvar lat eff
	tempname init ll_e ll_l           ///
	              ll_old_e ll_old_l   ///
				  b_old crit_b        ///
				  crit_ll_e crit_ll_l ///
				  ll_u ll_0 w_df w_p

// prepare matrix init
	local ncols = `nc' + 1 + `nl' + 1 + `nu' + ("`cmd'" == "reg")
	matrix `init' = J(1,`ncols', .)

	
	foreach var of local unconstrained {
		local coln "`coln' unconstrained:`var'"
	}
	local coln "`coln' unconstrained:_cons"
	foreach var of local lambda {
		local coln "`coln' lambda:`var'"
	}
	local coln "`coln' lambda:_cons"
	foreach var of local constrained {
		local coln "`coln' constrained:`var'"
	}
	if "`cmd'" == "reg" {
		local coln "`coln' ln_sigma:_cons"
	}
	matrix colnames `init' = `coln'

//  estimate unconstrained model
	foreach cvar of local constrained {
		foreach lvar of local lambda {
			tempvar `lvar'X`cvar'
			qui gen double ``lvar'X`cvar'' = `lvar'*`cvar'
			local int "`int' ``lvar'X`cvar''"
		}
	}
	qui `cmd' `y' `unconstrained' `constrained' `int' `wgt' if `touse', `robust' `clopt' `vce' `link'
	est store `uncns'
	scalar `ll_0' = e(ll_0)
	scalar `ll_u' = e(ll)
	
	/*
	// non-linear Wald test of the proportionality constraint
	// Commented out because this will be done in two steps: first -nlcom- and than -test-
	// to get the constrained coefficients
	gettoken base rest : constrained
	foreach lvar of local lambda {
		local test "`test' (  _b[``lvar'X`base'']/_b[`base']"
		foreach cvar of local rest {
			local test "`test' = _b[``lvar'X`cvar'']/_b[`cvar']"
		}
		local test "`test' )"
	}
	qui testnl `test'
	*/
		
	// build the lambdas
	foreach lvar of local lambda {
		local i = 1
		foreach cvar of local constrained {
			local nlcom "`nlcom' (`lvar'_`i': _b[``lvar'X`cvar'']/_b[`cvar'])"
			local i = `i' + 1
		}
	}
	qui nlcom `nlcom', post
	
	local t = ""
	foreach lvar of local lambda {
		local t "`t' ("
		forvalues i = 1/`nc' {
			if `i' == 1 {
				local t "`t' _b[`lvar'_`i']"
			}
			else {
				local t "`t' = _b[`lvar'_`i']"
			}
		}
		local t "`t' )"
	}
	qui test `t'
	if ("`r(chi2)'" != "") {
		tempname w_chi2
		scalar `w_chi2' = r(chi2)
	}
	else {
		tempname w_f w_df_r
		scalar `w_f'    = r(F)
		scalar `w_df_r' = r(df_r)
	}
	scalar `w_df'   = r(df)
	scalar `w_p'    = r(p)
	*** copied from the Table subroutine of the -test- command
	tempname R r Rr V b br VR

	mat `V'  = e(V)
	mat `b'  = e(b)
	mat `Rr' = get(Rr)

	loc nb  = rowsof(`V')
	mat `R' = `Rr'[1..., 1..`nb']
	mat `r' = `R'*`b'' - `Rr'[1..., `=`nb'+1']

	mat `VR' = syminv(`R' * `V' * `R'')
	mat `VR' = `VR' * `R' * `V'
	// constrained estimator
	mat `br' = `b' - `r'' * `VR'
	*** end copy
	
	
	// collect parameters that can be directly taken from the 
	// unconstrained model
	matrix `init'[1,colnumb(`init',"lambda:_cons")] = 1
	foreach var of local lambda {
		matrix `init'[1,colnumb(`init',"lambda:`var'")] = `br'[1,"`var'_1"]
	}

	// In principle it is possible to derive estimates for the unconstrained and 
	// constrained equations as well from this model, but the step below seems 
	// to provide much more accurate estimates, especially for the constrained
	// equation
	local g_eff "1"
	foreach var of varlist `lambda' {
		local g_eff `"`g_eff' + `=el(`init',1,colnumb(`init',"lambda:`var'"))'*`var'"'
	}
	qui gen double `eff' = `g_eff'

	foreach var of varlist `constrained' {
		tempvar effX`var'
		qui gen double `effX`var'' = `eff'*`var'
		local effvars "`effvars' `effX`var''"
	}	
	
	qui `cmd' `y' `unconstrained' `effvars'  if `touse'  `wgt', `robust' `clopt' `vce'
		
	matrix `init'[1, colnumb(`init',"unconstrained:_cons")]=_b[_cons]
	foreach var of varlist `unconstrained' {
		matrix `init'[1, colnumb(`init',"unconstrained:`var'")]=_b[`var']
	}
	foreach var of varlist `constrained' {
		matrix `init'[1, colnumb(`init',"constrained:`var'")]=_b[`effX`var'']
	}
	if "`cmd'" == "reg" {
		matrix `init'[1, colnumb(`init',"ln_sigma:_cons")]= ln(e(rmse))
	}
	
	if "`unit'" != "" {
		tempname l0 t
		scalar `l0' = el(`init',1,colnumb(`init',"constrained:`unit'"))
		matrix `init'[1, colnumb(`init',"lambda:_cons")] = `l0'
		foreach var of local constrained {
			scalar `t' = el(`init',1,colnumb(`init',"constrained:`var'"))
			matrix `init'[1, colnumb(`init',"constrained:`var'")] = `t'/`l0'
		}
		foreach var of local lambda{
			scalar `t' = el(`init',1,colnumb(`init',"lambda:`var'"))
			matrix `init'[1, colnumb(`init',"lambda:`var'")] = `t'*`l0'
		}
	}

	return matrix init   = `init'
	return scalar ll_0   = `ll_0'
	return scalar ll_u   = `ll_u'
	if "`w_chi2'" != "" {
		return scalar w_chi2 = `w_chi2'
	}
	else {
		return scalar w_f    = `w_f'
		return scalar w_df_r = `w_df_r'
	}
	return scalar w_df   = `w_df'
	return scalar w_p    = `w_p'
end
/*----------------------------------------- end initial values  */

/*---------------------------------------------- start display */
program Display, rclass
	syntax [pw fw aw iw] [, noTRANSform CLuster(varname) /*
	*/ Level(integer $S_level) /*
	*/ mimic bic or irr poisson logit uncns(string) cns(string) /*
	*/ wald w_chi2(numlist) w_f(numlist) w_df_r(numlist) w_df(numlist) w_p(numlist) ]

	if "`level'" != "" local level "level(`level')"

	_coef_table_header
	
	di _newline(1)
	di as txt "Constraint: " as result "`e(id_constr)'"
	
	if c(stata_version) > 10 {
		local nocnsreport "nocnsreport"
	}
	
	ml display, `level' noheader `nocnsreport' `or' `irr'
	
	if "`wald'" != "" & "`mimic'" == "" & !inlist("`e(vce)'", "bootstrap", "jackknife") {
		if "`w_chi2'" != "" {
			di as text "Wald test vs. unconstrained model: chi2(" _c
			di as result %3.0f `w_df' as text ") = " _c
			di as result %8.2f   `w_chi2' _c
			di _col(59) as text "Prob > chi2 = " as result %7.3f `w_p'	
		}
		else {
			di as text "Wald test vs. unconstrained model: F(" _c
			di as result %3.0f `w_df' as text ", " _c
			di as result %6.0f `w_df_r' as text ") = " _c
			di as result %8.2f   `w_f' _c
			di _col(62) as text "Prob > F = " as result %7.3f `w_p'	
		}
	}
	if "`wald'" == ""  & "`mimic'" == "" & !inlist("`e(vce)'", "bootstrap", "jackknife") {
		qui lrtest `uncns' `cns', force 
		
		if "`poisson'`logit'" == "" {
			// df + 1 for the error variance which is included in likelihood and excluded in the -regress-
			local df = `r(df)' + 1 
		}
		else local df = `r(df)'
			
		di as text "LR test vs. unconstrained model: chi2(" _c
		di as result %3.0f `df' as text ") = " _c
		di as result %9.2f    r(chi2) _c
		di _col(57) as text "Prob > chi2 = " as result %9.3f chi2tail(`df',`r(chi2)')
		
		return scalar lr_chi2 = r(chi2)
		return scalar lr_df = `df'
		return scalar lr_p = chi2tail(`df',`r(chi2)')
		
		if "`bic'" != "" {
			di _newline(1)
			qui est stats `uncns' `cns'
			tempname s dbic
			matrix `s' = r(S)
			scalar `dbic' = `s'[1,6]-`s'[2,6]
			#delim ;
			di as text "BIC(unconstrained) - BIC(constrained) = "
			as result %9.2f `dbic'  ;
			di as text "This difference suggests " 
				cond(abs(`dbic')<2,"weak",
				cond(abs(`dbic')<6,"positive",
				cond(abs(`dbic')<10,"strong", "very strong"))) 
				" evidence for the " 
				cond(`dbic'>0,"constrained", "unconstrained") 
				" model" ;
			#delim cr
		}
	}
end
/*------------------------------------------------ end display */

program define robust_chk, rclass
	syntax [, vce(string) *]
	local vce : word 1 of `vce'
	if inlist("`vce'", "robust", "cluster") {
		return local robust "robust"
	}
end

program define Post, eclass
	syntax , b(name) v(name) cns(string)
	qui estimates restore `cns'
	ereturn repost b=`b' V=`v', rename
end

/* creating the nlcom command for standardizing the latent variable */
mata:
void Standardize() {
	varsu = tokens(st_local("unconstrained"))
	varsc = tokens(st_local("constrained"))
	varsl = tokens(st_local("lambda"))
	logit = st_local("logit")
	poisson = st_local("poisson")
	w = st_local("exp")
	
	b = st_matrix("e(b)")
	V = st_matrix("e(V)")
	
	lu = length(varsu)
	lc = length(varsc)
	ll = length(varsl)
	
	ilat = (lu + ll + 3) .. (lu + ll + lc + 2)
	ilambda = (lu + 2) .. (lu + ll + 2)

// =============== Standardized coefficients ===============	
// standard deviation of the latent variable (p)
	p = .
	x = .
	st_view(x,.,(varsc),st_local("touse"))
	if (w != "") {
		weight = .
		st_view(weight,.,w, st_local("touse"))
		v = variance(x,weight)
	}
	else {
		v = variance(x)
	}
	p = v[1,1]* b[ilat[1]]^2
	for(i=2; i<=length(ilat); i++) {
		p = p + v[i,i] *b[ilat[i]]^2
	}
	for(i=1 ; i <=length(ilat) ; i++) {
		for(j=1; j < i; j++) {
			p = p + 2*v[i,j]*b[ilat[i]] * b[ilat[j]]
		}
	}
	p = strtoreal(st_local("sign"))*sqrt(p)

		
// effect OFF latent variable (lambda)

	l = J(1,ll+1,.)
	for(i=1; i <= (ll + 1) ; i++){
        	l[1,i] = b[ilambda[i]]*p
	}

// effect ON latent variable (constrained)

	
	a = J(1,lc,.)

	for(i=1; i <= lc ; i++){
        	a[i] = b[ilat[i]]/p
	}
	if (logit == "" & poisson == "") {
		newb =b[1..(lu+1)], l, a, exp(b[(lc+ll+lu+3)..length(b)])
	}
	else {
		newb =b[1..(lu+1)], l, a	
	}
//==================== standard errors ======================
	G = J(length(b), length(b), 0)

	iG = 1
// Unconstrained
	for(i = 1 ; i <= lu+1 ; i++) {
		G[i, i] = 1
		iG = iG + 1
	}

// Lambda	
	for(i = 1 ; i <= ll + 1 ; i++) {
		for (j = 1 ; j <= lc ; j++) {
			dldx = 0
			for(l=1; l <= lc ; l++) {
				dldx = dldx + v[j, l]*b[ilat[l]]
			}
			G[iG,ilat[j]] =   ( b[ilambda[i]]* dldx) / p
			G[iG,iG] = p
		}
		iG = iG+1
	}
	
// Constrained
	for(i = 1 ; i <= lc ; i++) {
		for (j = 1 ; j <= lc ; j++) {
			dadx = 0
			for(l=1; l <= lc ; l++) {
				dadx = dadx + v[j, l]*b[ilat[l]]
			}
			G[iG,ilat[j]] = (i==j)/p - ( b[ilat[i]]* dadx) / (p^3)
		}
		iG = iG+1
	}

// Sigma(s)
	if (logit == "" & poisson == "") {
		for(i = (lc+ll+lu+3) ; i <= length(b) ; i++) {
			G[i,i] = exp(b[i])
		}
	}
	
// Returning results
	st_matrix(st_local("b"), newb )
	st_matrix(st_local("v"), G*V*G')
	
}
end


exit
