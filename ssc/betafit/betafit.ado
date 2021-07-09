*! 1.1.7 MLB 07 Apr 2011
*! 1.1.6 MLB 06 Apr 2011
*! 1.1.3 MLB 31 Aug 2008
*! 1.1.2 MLB 05 Jan 2008
*! 1.1.1 MLB 04 Sep 2006
*! 1.1.0 MLB & NJC 16 Nov 2005
*! 1.0.0 NJC & SPJ 17 Nov 2003
* Fit two-parameter beta distribution by ML in either of two parameterizations

/*------------------------------------------------ playback request */
program betafit, eclass byable(onecall)
	if c(stata_version) >= 11 {
		version 11
		global fv "fv"
	}
	else if c(stata_version) >= 9 {
		version 9
	}
	else {
		version 8.2
	}
	if replay() {
		if "`e(cmd)'" != "betafit" {
			di as err "results for betafit not found"
			exit 301
		}
		if _by() error 190 
		Display `0'
		exit `rc'
	}
	if _by() by `_byvars'`_byrc0': Estimate `0'
	else Estimate `0'
end

/*------------------------------------------------ estimation */
program Estimate, eclass byable(recall)
	syntax varname [if] [in] [fw aw pw] [,  ///
		ALTernative ALPHAvar(varlist numeric $fv) BETAvar(varlist numeric $fv) ///
		MUvar(string) PHIvar(string) ///
		Robust Cluster(varname) Level(integer $S_level) noLOG rpr * ]

	if "`alphavar'`betavar'" != "" & "`alternative'`muvar'`phivar'" != "" {
		di as err "must choose one parameterization"
		exit 198 
	}	
	
	// parse muvar phivar
	if `"`muvar'"' != "" {
		Parse_mu `muvar'
		local muvar "`s(muvar)'"
		local munocons "`s(mu_nocons)'"
	}
	if `"`phivar'"' != "" {
		Parse_phi `phivar'
		local phivar "`s(phivar)'"
		local phinocons "`s(phi_nocons)'"
		local phieform "`s(phi_eform)'"
	}
	if "`phieform'" != "" & "`rpr'" == "" {
		di as txt "Note: specifying the eform sub-option in phivar() implies specifying the rpr option"
		local rpr "rpr"
	}
	
	local y "`varlist'"
	marksample touse 
	markout `touse' `varlist' `betavar' `alphavar' `muvar' `phivar' `cluster'
	
	qui count if (`y' <= 0 | `y' >= 1) & `touse'
	if r(N) {
		noi di " "
		noi di as txt "warning: {res:`y'} has `r(N)' values <= 0 or >= 1;" _c
		noi di as txt " not used in calculations"
	}
	qui replace `touse' = 0 if `y' <= 0 | `y' >= 1 

	qui count if `touse' 
	if r(N) == 0 error 2000 

	local param = cond("`alternative'`phivar'`muvar'" != "", "mu, phi", "alpha, beta") 
	local title "ML fit of beta (`param')"
	
	local wtype `weight'
	local wtexp `"`exp'"'
	if "`weight'" != "" local wgt `"[`weight'`exp']"'  
	
	if "`cluster'" != "" { 
		local robust "robust"
		local clopt "cluster(`cluster')" 
	}

	if "`level'" != "" local level "level(`level')"
        local log = cond("`log'" == "", "noisily", "quietly") 

	foreach var of local muvar {
		capture assert `var' == 1
		if !_rc {
			local hascons "`var'"
		}
	}
	foreach var of local phivar {
		capture assert `var' == 1
		if !_rc {
			local phihascons "`var'"
		}
	}
	if ( "`munocons'" == "" | "`hascons'" != "" ) & ("`phinocons'" == "" | "`phihascons'" != ""){
		Init `y' if `touse' `wgt', param("`param'") hascons(`hascons') phihascons(`phihascons')
		tempname init
		matrix `init' = r(init)
		local initopt `"init(`init') search(off)"'
	}
	
	mlopts mlopts, `options'
	global S_MLy "`y'"
	
	if "`param'" == "mu, phi" {	
		local nmu : word count `muvar'
		local nphi : word count `phivar'
		`log' ml model lf betareg_lf           /// 
		    (mu:     `muvar' , `munocons')     ///
			(ln_phi: `phivar', `phinocons')    ///
			`wgt' if `touse' ,                 ///
			maximize `initopt' 	               ///
			title(`title') `robust' `clopt'    ///
			`level' `mlopts' `stdopts' `modopts'

		eret local depvar "`y'"

		tempname b bmu bphi
		mat `b' = e(b)
		mat `bmu' = `b'[1,"mu:"]
		mat `bphi' = `b'[1,"ln_phi:"]
		eret matrix b_mu = `bmu'
		eret matrix b_phi = `bphi'
		if "`phieform'" == "" {
			eret scalar k_eform = 1
		}
		else {
			eret scalar k_eform = 2
		}
		if "`munocons'" != "" eret local munocons "noconstant"
		if "`phinocons'" != "" eret local phinocons "noconstant"
		
		eret scalar length_b_mu = 1 + `nmu'
		eret scalar length_b_phi = 1 + `nphi'
		ereturn local predict "betafit_p"
		if `nphi' == 0 eret scalar k_aux = 1

        if "`muvar'`phivar'" == ""  {
			tempname e
			mat `e' = e(b)
			eret scalar mu = `e'[1,1]
			eret scalar ln_phi = `e'[1,2]
		}

		Display_reg, `level' `diopts' `rpr' `phieform'
	}
	
	else { 
		local nalpha : word count `alphavar'
		local nbeta : word count `betavar'
		`log' ml model lf betafit_lf (alpha: `alphavar') (beta: `betavar') ///
			`wgt' if `touse' , maximize init(`init')  	   	 ///
			collinear title(`title') `robust'       		 ///
			search(off) `clopt' `level' `mlopts' `stdopts' `modopts'

		eret local depvar "`y'"

		tempname b bbeta balpha
		mat `b' = e(b)
		mat `bbeta' = `b'[1,"beta:"]
		mat `balpha' = `b'[1,"alpha:"]
		eret matrix b_beta = `bbeta'
		eret matrix b_alpha = `balpha'
		eret scalar length_b_beta = 1 + `nbeta'
		eret scalar length_b_alpha = 1 + `nalpha'
		ereturn local predict "betafit_p"

		if "`betavar'`alphavar'" == ""  {
			tempname e
			mat `e' = e(b)
			eret scalar alpha = `e'[1,1]
			eret scalar beta = `e'[1,2]
		}
		
		Display, `level' `diopts'
    }
	eret local cmd "betafit"
end

program define Parse_phi, sclass
	syntax [varlist(numeric $fv)], [noCONStant eform]
	if `"`varlist'"' == "" & "`constant'" != "" {
		di as err "one or more variables must be specified in the phivar() option when the nocons suboption is specified"
		exit 198
	}
	if "`eform'" != "" & "`varlist'" == "" {
		local eform ""
	}
	if "`eform'" != "" local eform "phieform"
	sreturn local phivar "`varlist'"
	sreturn local phi_eform "`eform'"
	sreturn local phi_nocons "`constant'"
end

program define Parse_mu, sclass
	syntax [varlist(numeric $fv)], [noCONStant]
	if `"`varlist'"' == "" & "`constant'" != "" {
		di as err "one or more variables must be specified in the muvar() option when the nocons suboption is specified"
		exit 198
	}
	sreturn local muvar "`varlist'"
	sreturn local mu_nocons "`constant'"
end

program Init, rclass
	syntax varname [if] [aw pw fw], param(string) [ hascons(varname) phihascons(varname) ]
	tempname init alpha beta mu phi m var
	marksample touse
	
	if "`hascons'" == "" {
		local hascons "_cons"
	}
	if "`phihascons'" == "" {
		local phihascons "_cons"
	}
	
	if "`weight'" == "pweight" {
		local wgt "[aweight`exp']"
	}
	else {
		local wgt "[`weight'`exp']"
	}
	
	qui sum `varlist' `wgt' if `touse'
	scalar `m' = r(mean)
	scalar `var' = r(Var)	
	if "`param'" ==  "alpha, beta" {
		scalar `alpha' = `m'*((`m'*(1-`m'))/(`var')-1)
		scalar `beta' = (1-`m')*((`m'*(1-`m'))/(`var')-1)
		matrix `init' = `alpha', `beta'
		matrix colnames `init' = alpha:_cons beta:_cons
	}
	else if "`param'" == "mu, phi" {
		scalar `mu' = ln(`m'/(1-`m'))
		scalar `phi' = ln((`m'*(1-`m'))/`var' - 1)
		matrix `init' = `mu', `phi'
		matrix colnames `init' = mu:`hascons' ln_phi:`phihascons'
	}
	return matrix init = `init'
end 

program Display
	syntax [, Level(int $S_level) *]
	local diopts "`options'"
	if `level' < 10 | `level' > 99 local level = 95
	ml display, level(`level') `or' `diopts'
	if "`e(title)'" == "ML fit of beta (mu, phi)" {
		if e(length_b_phi) == 1 {
			_diparm ln_phi, exp label(phi)
			di in text "{hline 13}{c BT}{hline 64}
		}	
	}
end


program Display_reg
	syntax [, Level(int $S_level) rpr phieform *]
	local diopts "`options'"
	if `level' < 10 | `level' > 99 local level = 95
	if e(length_b_phi) == 1 local plus "plus"
	if "`rpr'" != "" {
		local rpr "eform(RPR)"
	}
	ml display, level(`level') `diopts' `plus' `rpr'
	if e(length_b_phi) == 1 {
		_diparm ln_phi, exp label(phi)
		di in text "{hline 13}{c BT}{hline 64}
	}
	if "`phieform'" != "" | c(stata_version) < 9 {
		di as txt "the coefficients of the ln_phi equation are exponentiated"
	}
end

