*! create added-variable plot after -xtreg-
*! version 1.0.1  3nov2019 by John Luke Gallup (jlgallup@pdx.edu)

program define xtavplot, rclass sort
	version 11

	local xtcmd = e(cmd)	// xtreg or xtgee
	local model = e(model) // i.e. fe, be, re, ml, pa, etc.
	if "`e(typ)'"!="" local wls "wls"

	if ("`model'"=="ml" | "`model'"=="pa") {
		di as error "not allowed after {cmd:xtreg, mle} or {cmd:xtreg, pa}"
		exit 198
	}
	if ("`xtcmd'"!="xtreg") {
		di as error "no xtreg estimates found"
		exit 301
	}
	local xtcmd `xtcmd'_`model'
	
	syntax varname (fv ts) [, Level(cilevel) ///
		noCI noCOef CIUnder GENerate(namelist min=2 max=2) ///
		ylim(numlist max=2 ascending) xlim(numlist max=2 ascending) ///
		Addmeans noDisplay DEBUG *] // undocumented DEBUG option  
			// calculates coefficient from residuals and saves 
			// in r(b_check) to verify calculation of residuals

	local v `varlist'
	// see if added variable is included in xtreg rhs
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
	
	// get y, rhs & weight variables
	local y "`e(depvar)'"
	_getrhs rhs
	local wgt "[`e(wtype)' `e(wexp)']"
	
	if "`e(vcetype)'"=="Robust" local robust="robust"
	if "`generate'" != "" {
		capture confirm new variable `generate'
		if c(rc) {
			di as err "variable names in {bf:generate(`generate')} option already exist"
			exit 110
		}
	}
	
	_get_gropts, graphopts(`options') ///
		getallowed(Rlopts CIOpts CIPLot addplot)
	local options `"msize(*.35) pstyle(p1) `s(graphopts)'"'
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

	tempvar touse e_y e_x hat
	tempname prev_est b se_b df_r
	
	preserve
	_estimates hold `prev_est', copy
	local ivar `e(ivar)'
	gen `touse' = e(sample)
	qui keep if `touse'
	if "`addmeans'"!="" { // capture means before they are modified
		tempname ybar xbar
		sum `y' `wgt', meanonly
		scalar `ybar' = r(mean)
		sum `x' `wgt', meanonly
		scalar `xbar' = r(mean)
	}

	if !`inorig' {	/* v not originally in xtreg rhs */
		if "`y'"=="`v'" { 
			di in red "cannot include dependent variable"
			exit 398
		}
		capture assert `v'!=.
		if c(rc) {
			di in red "`v' has missing values" _n ///
				"you must reestimate including `v'"
			exit 398
		}
		// check for collinearity of new variable `x' with 
		// depvar or rhs or ivar
		capture _rmdcoll `x' `y' `rhs' `ivar', expand normcoll
		if c(rc) {
			di in red "new variable `v' collinear with variables in" _n ///
			"   `y' `rhs' `ivar'"
			exit 459
		}

		if "`model'"=="fe" qui `e(predict)' double `e_y', e
		// get b and se_b from full regression
		qui `xtcmd' `y' `v' `rhs' `wgt', `model' `robust' `cluster' `wls'
	}
	scalar `b' 	  = _b[`v']
	scalar `se_b' = _se[`v']
	scalar `df_r' = e(df_r)

	if `inorig' {	/* v originally in xtreg rhs */
		local rhs : list rhs - v // remove v from rhs

		if _b[`v']==0 { 
			di in gr "(`v' was dropped from model)"
			exit 399
		}
		if "`model'"=="fe" {
			qui `xtcmd' `y' `rhs' `wgt', `model'
			qui `e(predict)' double `e_y', e
		}
	}

	quietly {
		if "`model'"=="fe" {
			// n.b. don't need `robust' or `cluster' because only using
			//		 _b, not the _se
			`xtcmd' `x' `rhs' `wgt', `model'
			`e(predict)' double `e_x', e
		}
		else if "`model'"=="re" {
			tempvar vdev one_thta
			tempname thta
			if e(Tcon) scalar `thta' = 1 - e(sigma_e) ///
					/ sqrt(e(Tbar)*e(sigma_u)^2 + e(sigma_e)^2)
			else by `ivar': gen double `thta' = 1 - e(sigma_e) ///
					/ sqrt(_N*e(sigma_u)^2 + e(sigma_e)^2)	
			foreach vr in `y' `x' `rhs' { // replace w/ deviations
				by `ivar': gen double `vdev' = sum(`vr')/_n
				by `ivar': replace `vdev' = `vr' - `vdev'[_N] * `thta'
				drop `vr'
				rename `vdev' `vr'
			}
			gen double `one_thta' = 1-`thta'
			_regress `y' `rhs' `one_thta', nocons
			_predict double `e_y', resid
			_regress `x' `rhs' `one_thta', nocons
			_predict double `e_x', resid				
		}
		else {  // i.e. model=be: between effects
			tempvar tn T
			foreach vr in `y' `x' `rhs' {
				by `ivar': gen double `tn' = sum(`vr')/_n
				drop `vr'
				rename `tn' `vr'
			}
			if ("`wls'"!="") by `ivar': gen `c(obs_t)' `T' = _N
			by `ivar': keep if _n==_N
			if ("`wls'"!="") local wgt "[aweight=`T']"
			_regress `y' `rhs' `wgt'
			_predict double `e_y', resid
			_regress `x' `rhs' `wgt'
			_predict double `e_x', resid
		}

		if "`debug'"!="" {
			_regress `e_y' `e_x', nocons
			return scalar b_check = _b[`e_x']
		}
		if "`generate'"!="" mata: exey = st_data(.,"`e_x' `e_y'")
	}

	capture local xttl : var label `v'  // capture because v could be factor variable
	local yttl : var label `y'
	if "`xttl'"=="" local xttl `v'
	if "`yttl'"=="" local yttl `y'
	if "`model'"=="be" local prelbl "av."
	else if "`model'"=="re" local postlbl "*"
	local xttl "e( `prelbl'`xttl'`postlbl' | `prelbl'X`postlbl' )"
	local yttl "e( `prelbl'`yttl'`postlbl' | `prelbl'X`postlbl' )"
	if "`display'"=="" {
		gen `hat' = `b'*`e_x' // regression line

		if ("`ylim'`xlim'"!="") { // limit displayed observations
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
			tempvar ci_l ci_u			
			tempname t_a
			if ("`model'"=="re") ///
				scalar `t_a'  = -invnormal((1-`level'/100)/2)
			else scalar `t_a'  = invttail(`df_r',(1-`level'/100)/2)
			gen `ci_l' = (`b' - `t_a'*`se_b')*`e_x'
			gen `ci_u' = (`b' + `t_a'*`se_b')*`e_x'
			if ("`ciunder'"!="") ///
				local gr_ci_und "(`ciplot' `ci_l' `ci_u' `e_x' `ifyx', pstyle(p2) `ciopts')"	
			else local gr_ci_ovr "(`ciplot' `ci_l' `ci_u' `e_x' `ifyx', pstyle(p2) `ciopts')"
		}
		if "`addmeans'"!="" { // add mean values on to e_x and e_y
			quietly {
				replace `e_y' = `e_y' + `ybar'
				replace `hat' = `hat' + `ybar'
				replace `ci_l' = `ci_l' + `ybar'
				replace `ci_u' = `ci_u' + `ybar'
				replace `e_x' = `e_x' + `xbar'
			}
			local meanlbl " + mean"
		}
		if ("`coef'" == "") {  // display coefficient estimate in note
			if ("`robust'"=="robust") local robust "(robust) "
			if ("`model'"=="re") local t_z "z"
			else local t_z "t"
			local tf : display %5.2f `b'/`se_b'
			local bf : display %9.0g `b'
			local sef : display %9.0g `se_b'
			local note `"note("coef = `bf', `robust'se = `sef', `t_z' = `tf'")"'
		}
		if (`"`addplot'"' == "") local legend legend(nodraw)
		
		sort `e_x', stable
	
		graph twoway							///
			`gr_ci_und'							///
			(scatter `e_y' `e_x' `ifyx', 		///
				ytitle(`"`yttl'`meanlbl'"') 	///
				xtitle(`"`xttl'`meanlbl'"')		///
				`note' `legend' `options')		///
			`gr_ci_ovr'							///
			(line `hat' `e_x' `ifyx', `rlopts')	///
			|| `addplot'
	}
	if "`addmeans'"!="" {
		ret scalar xbar = `xbar'
		ret scalar ybar = `ybar'
	}
	ret scalar se = `se_b'
	ret scalar coef = `b'
	_estimates unhold `prev_est'
	restore
	if "`generate'"!="" {
		local exvar : word 1 of `generate'
		local eyvar : word 2 of `generate'
		tempvar smpl
		gen long `smpl' = e(sample)
		if "`model'"=="be" {
			tempvar sortord
			gen long `sortord' = _n
			sort `ivar' `smpl'
			qui by `ivar' `smpl': replace `smpl' = 0 if _n>1 & `smpl'==1
			sort `sortord'
		}
		mata: st_store(.,st_addvar("double", ("`exvar'", "`eyvar'")), "`smpl'",exey)
		mata: mata drop exey
		label variable `exvar' "`xttl'"
		label variable `eyvar' "`tytl'"
	}
end
