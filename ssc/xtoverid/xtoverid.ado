*! xtoverid version 2.1.8   04Jan2016
*! Authors Mark Schaffer and Steve Stillman
*! Derived from overidxt and overid
* V1.3: add handling of weights, guard against use with robust
* V1.35: correct handling of inst list 
* V1.4.0: adds support for xtivreg, fe
* V1.4.1: standard error msg re xtivreg
* V1.4.2: move to ivreg 5.00.09 for collinear instruments correction 
* V1.4.3: fixed bug with lagged covariates in xtivreg
* V1.4.4: suppress constant in aux reg if no constant in orig eqn, per ivreg2
* V1.4.5: 80-byte bug looking for _cons
* V1.5.0: support only xtivreg, fe
* V2.0.0: name changed from overidxt to xtoverid, fixes incorrect dof for fe results,
*         and adds support for xtivreg2 and fd and re effects options
* V2.1.0: adds support for Hausman-type RE vs FE test after xtivreg,re
*         fixed bug where empty local macro for varnames had "." instead of nothing
*         added "exactly identified" output message
* V2.1.1: fixed xtreg RE vs FE bug for handing case of time-invariant regressors
* V2.1.2: added handling of time-series operators
* V2.1.3: recoded HT section (TVendog, TVexog, TIendog, TIexog) to account for possible empty lists
* V2.1.4: added check for ivreg2 or ivreg28.  added noid option to calls to ivreg2/8 to speed performance.
* V2.1.5: allow for multi-level clustering as supported by ivreg2.
*         added support for ivreg29.  fixed bug that required xtivreg2 to be installed.
* V2.1.6: fixed bug with undocumented noisily (related to noid option); updated noi to imply first instead of ffirst
* V2.1.7: update to accommodate version handling for new ivreg2; added support for ivreg210;
*         opt name gmm if invoked by version 8, gmm2s if version 9 or later
* v2.1.8: fixed bug with long/float id var (was being caught by check with original xtivreg results)
*         added singleton count to noisily option
* Doesn't yet handle weights

// tweaked by cfb 20100307 to deal with problems with xtivreg2, gmm2s

program define xtoverid, rclass sortpreserve
	version 8.2
	local lversion 2.1.7

* Needed for call to ivreg2
	local ver = _caller()
	local ver : di %6.1f `ver'

	syntax [, Robust CLuster(varlist) NOIsily ]

	if ("`e(cmd)'" ~= "xtivreg") & ("`e(cmd)'" ~= "xtivreg2") & ("`e(cmd)'" ~= "xthtaylor") & /*
		*/	("`e(cmd)'" ~= "xtreg") {
		di in red "xtoverid works only after xtreg, xtivreg, xtivreg2 or xthtaylor"
		error 301
	} 

	if "`e(fwlcons)'" != ""  | (e(partial_ct)>0 & e(partial_ct)<.) {
di in r "xtoverid not allowed after xtivreg2 with partialling-out option"
		error 499
	}

	tempname regest
	capture _estimates hold `regest', restore
	local ivreg2_cmd "ivreg2"
	capture `ivreg2_cmd', version
	if _rc != 0 {
* No ivreg2, check for ivreg210, ivreg29 or ivreg28
		local ivreg2_cmd "ivreg210"
		capture `ivreg2_cmd', version
		if _rc != 0 {
			local ivreg2_cmd "ivreg29"
			capture `ivreg2_cmd', version
			if _rc != 0 {
				local ivreg2_cmd "ivreg28"
				capture `ivreg2_cmd', version
				if _rc != 0 {	
	di as err "Error - must have ivreg2/ivreg29/ivreg28 version 2.1.15 or greater installed"
				exit 601
				}
			}
		}
	}
	local vernum "`e(version)'"
	capture _estimates unhold `regest'
	if ("`vernum'" < "02.1.15") | ("`vernum'" > "09.9.99") {
di as err "Error - must have `ivreg2_cmd' version 2.1.15 or greater installed"
		exit 601
	}

	if ("`e(cmd)'" == "xtivreg2") {
		capture _estimates hold `regest', restore
		capture xtivreg2, version
 		if _rc != 0 {
di as err "Error - must have xtivreg2 version 1.0.03 or greater installed"
			exit 601
		}
		local vernum "`e(version)'"
		capture _estimates unhold `regest'
		if ("`vernum'" < "01.0.03") | ("`vernum'" > "01.9.99") {
di as err "Error - this version of xtoverid incompatible with installed xtivreg2"
			exit 601
		}
	}

	if "`e(cmd)'" == "xtreg" {
		if "`e(model)'" == "re" {
			local model "re"
		}
		else {
			di in red "xtoverid not compatible with xtreg model `e(model)'"
			exit 198
		}
		local desc "fixed vs random effects"
	}

	if "`e(cmd)'" == "xtivreg" {
		if "`e(model)'" == "g2sls" {
			local model "g2sls"
		}
		else if "`e(model)'" == "ec2sls" {
			local model "ec2sls"
		}
		else if "`e(model)'" == "fe" {
			local model "fe"
		}
		else if "`e(model)'" == "be" {
			local model "be"
		}
		else if "`e(model)'" == "fd" {
			local model "fd"
		}
		else {
			di in red "xtoverid not compatible with xtivreg model `e(model)'"
			exit 198
		}
	}

	if "`e(cmd)'" == "xtivreg2" {
// cfb must keep track of whether gmm2s has been invoked
		if "`e(model)'" == "gmm2s" {
			local gmm2s "gmm2s"
		}
// called gmm in ivreg28, gmm2s in ivreg29 and later
		if "`gmm2s'"=="gmm2s" & `ver'<9 {
			local gmm2s "gmm"
		}
		if "`e(xtmodel)'" == "fe" {
			local model "fe"
		}
		else if "`e(xtmodel)'" == "fd" {
			local model "fd"
		}
		else {
// cfb xtmodel not model
			di in red "xtoverid not compatible with xtivreg2 model `e(xtmodel)'"
			exit 198
		}
	}

	if "`e(cmd)'" == "xthtaylor" {
		if "`e(title)'" == "Hausman-Taylor" {
			local model "htaylor"
		}
		else if "`e(title)'" == "Amemiya-MaCurdy" {
			local model "amacurdy"
		}
		else {
			di in red "xtoverid not compatible with xthtaylor model `e(title)'"
			exit 198
		}
	}

	if "`e(wtype)'`e(wexp)'"~="" {
			di in red "current version of xtoverid does not support weights"
			exit 198
	}

	if "`noisily'"=="" {
		local qui "qui"
		local noid "noid"
	}
	else {
		local first "first"
	}
	
	if "`e(vcetype)'"=="Robust" {
		local robust "robust"
	}

* Don't overwrite if user specifies cluster with xtoverid
	if "`cluster'"=="" & "`e(clustvar)'"~="" {
		local cluster "`e(clustvar)'"
	}

	if "`cluster'"!="" {
		local clopt "cluster(`cluster')"
		if "`robust'"=="" {
			local robust "robust"
		}
	}

	tempname j regest b bivreg2
	tempvar touse i_obs theta
	tempname sig_e2 sig_u2 mean omean

	mat `b'=e(b)
	local depvar "`e(depvar)'"
	local instd  "`e(instd)'"
	local insts  "`e(insts)'"

	if "`e(cmd)'"=="xtivreg" & "`model'"=="fd" {
* xtivreg does NOT save variable names with d. operator appended
* ...except, oddly, the dependent variable
* xtivreg2 DOES for all vars
		local instd_nots "`instd'"
		local instd ""
		foreach var of varlist `instd_nots' {
			local instd "`instd' D.`var'"
		}
		local insts_nots "`insts'"
		local insts ""
		foreach var of varlist `insts_nots' {
		local insts "`insts' D.`var'"
		}
	}

* Time series operators - replace vars using them with temporary variables
	tsrevar `depvar'
	local depvar `r(varlist)'
	tsrevar `instd'
	local instd `r(varlist)'
	tsrevar `insts'
	local insts `r(varlist)'

	local inexog : colnames `b'
	local inexog : subinstr local inexog "_cons" "", word count(local hascons)
	tsrevar `inexog'
	local inexog `r(varlist)'

	local inexog : list inexog - instd
	local exexog : list insts - inexog

	qui gen byte `touse' = e(sample)
// fix 04.01.16 - was generating ivar
	local ivar `e(ivar)'

	if "`e(cmd)'"=="xtreg" & "`model'"=="re" {
* Check if RE estimate was degenerate and = pooled OLS
		if e(sigma_u)==0 {
di as err "Error - saved RE estimates are degenerate (sigma_u=0) and equivalent to pooled OLS"
			exit 198
		}
		local sa "`e(sa)'"
		preserve
		_estimates hold `regest', restore
		sort `ivar' `touse'

		foreach var of varlist `inexog' {
			tempname `var'_md `var'_m
			local vmd `"`vmd' ``var'_md'"'
			local vm  `"`vm'  ``var'_m'"'
			qui by `ivar' `touse' : gen double ``var'_m'=sum(`var')/_N if `touse'
			qui by `ivar' `touse' : replace    ``var'_m'=``var'_m'[_N] if `touse' & _n<_N
			qui by `ivar' `touse' : gen double ``var'_md'=`var'-``var'_m'[_N] if `touse'
		}
*		qui xtreg `depvar' `inexog' `vm' if `touse', `robust' `clopt' `sa' re
*		qui test `vm'
		`qui' xtreg `depvar' `inexog' `vmd' if `touse', `robust' `clopt' `sa' re
		tempname b
		mat `b'=e(b)
		local vn1 : colnames `b'
		local vn0 "`inexog' `vmd'"
		local vndropped : list vn0 - vn1
		local vmd1 : list vmd - vndropped
		tempname j jp jdf
		`qui' test `vmd1'
		scalar `j'=r(chi2)
		scalar `jdf'=r(df)
		scalar `jp'= chiprob(`jdf',`j')
		_estimates unhold `regest'
		return scalar j=`j'
		return scalar jp=`jp'
		return scalar jdf=`jdf'
		restore
	}
	
	if "`model'" == "be" {
		preserve
		_estimates hold `regest', restore

		if `hascons'==0 {
			local nocons "nocons"
		}

		sort `ivar' `touse'
		foreach var of varlist `depvar' `instd' `inexog' `exexog' {
			capture drop `mean'
			qui by `ivar' `touse': gen double `mean'=sum(`var') if `touse'
			qui by `ivar' `touse': replace `var' = `mean'[_N]/_N if `touse'
			qui by `ivar' `touse': replace `var' = . if _n~=1
		}

		version `ver': `qui' `ivreg2_cmd' `depvar' `inexog' (`instd' = `exexog') if `touse', `nocons' `robust' `clopt' `first' `noid'
* Save coefficient vector excluding constant
		mat `bivreg2'=e(b)
		local cn : colnames `bivreg2'
		local cn : subinstr local cn "_cons" "", word count(local hascons2)
		if `hascons2'==1 {
			mat `bivreg2'=`bivreg2'[1,1..colsof(`bivreg2')-1]
		}

		if "`robust'`cluster'" == "" {
			return scalar j=e(sargan)
			return scalar jp=e(sarganp)
			return scalar jdf=e(sargandf)
		}
		else {
			return scalar j=e(j)
			return scalar jp=e(jp)
			return scalar jdf=e(jdf)
		}

		_estimates unhold `regest'
		restore
	}

	if "`model'" == "fe" {
		preserve
		_estimates hold `regest', restore

		sort `ivar' `touse'

		foreach var of varlist `depvar' `instd' `inexog' `exexog' {
			capture drop `mean'
			qui by `ivar' `touse': gen double `mean'=sum(`var') if `touse'
			qui by `ivar' `touse': replace `mean' = `mean'[_N]/_N if `touse'
			qui replace `var' = `var'-`mean'
		}

		tempvar T_i

* Catch singletons.
		qui by `ivar' `touse': gen long `T_i' = _N if _n==_N & `touse'
		qui count if `T_i' == 1
		local singleton=r(N)
		if `singleton' > 0 {
			`qui' di in ye "Warning - singleton groups detected.  " `singleton' " observation(s) not used."
		}
		sort `ivar' `touse'
		qui by `ivar' `touse': replace  `T_i' = .  if _n~=_N
		qui replace `touse'=0 if `T_i'==1

		qui count if `T_i' < . & `touse'
		local N_g=r(N)
		drop `T_i'

* Always run with nocons
* Need correction for lost degrees of freedom
// cfb add `gmm2s' to command
		version `ver': `qui' `ivreg2_cmd' `depvar' `inexog' (`instd' = `exexog') if `touse', /*
			*/	nocons dofminus(`N_g') `robust' `clopt' `first' `noid' `gmm2s'
* Save coefficient vector.  No constant estimated.
		mat `bivreg2'=e(b)

		if e(j)==. {
			return scalar j=e(sargan)
			return scalar jp=e(sarganp)
			return scalar jdf=e(sargandf)
		}
		else {
			return scalar j=e(j)
			return scalar jp=e(jp)
			return scalar jdf=e(jdf)
		}
		
		_estimates unhold `regest'
		restore
	}

	if "`model'" == "fd" {

		preserve
		_estimates hold `regest', restore

		if `hascons'==0 {
			local nocons "nocons"
		}
		version `ver': `qui' `ivreg2_cmd' `depvar' `inexog' (`instd' = `exexog') if `touse', /*
			*/	`nocons' `robust' `clopt' `first' `noid' `gmm2s'
* Save coefficient vector excluding constant
		mat `bivreg2'=e(b)
		local cn : colnames `bivreg2'
		local cn : subinstr local cn "_cons" "", word count(local hascons2)
		if `hascons2'==1 {
			mat `bivreg2'=`bivreg2'[1,1..colsof(`bivreg2')-1]
		}

		if e(j)==. {
			return scalar j=e(sargan)
			return scalar jp=e(sarganp)
			return scalar jdf=e(sargandf)
		}
		else {
			return scalar j=e(j)
			return scalar jp=e(jp)
			return scalar jdf=e(jdf)
		}
		
		_estimates unhold `regest'
		restore
	}

	if "`model'" == "g2sls" | "`model'" == "ec2sls" {

		scalar `sig_e2'=(e(sigma_e))^2
		scalar `sig_u2'=(e(sigma_u))^2

		sort `ivar' `touse'
		qui by `ivar': egen `i_obs'=count(`touse') if `touse'
		qui sum `i_obs' if `touse'
		local balanced = (r(min)==r(max))

		qui gen double `theta' = 1- /*
		 	*/ sqrt( `sig_e2'/(`sig_u2'*`i_obs' +`sig_e2' ) ) if `touse'

		preserve
		
		if `hascons'==1 {
			tempvar cons
			qui gen double `cons' = 1 -`theta' if `touse'
		}

		tempvar mean
		qui by `ivar' `touse': gen double `mean'=sum(`depvar') if `touse'
		qui by `ivar' `touse': replace `mean' =`mean'[_N]/_N if `touse'
		tempvar depvar_g
		qui gen double `depvar_g' =`depvar'-`theta'*`mean'

		foreach var of varlist `instd' {
			tempvar mean
			qui by `ivar' `touse': gen double `mean'=sum(`var') if `touse'
			qui by `ivar' `touse': replace `mean' =`mean'[_N]/_N if `touse'
			tempvar gls
			qui gen double `gls' =`var'-`theta'*`mean'
			local instd_g "`instd_g' `gls'"
		}
		foreach var of varlist `exexog' {
			qui sum `var' if `touse', meanonly
			scalar `omean'=r(mean)
			tempvar mean
			qui by `ivar' `touse': gen double `mean'=sum(`var') if `touse'
			qui by `ivar' `touse': replace `mean' =`mean'[_N]/_N if `touse'
* Don't add group-invariant vars to m list - causes collinearity problems
			qui sum `mean' if `touse'
			if r(sd) ~= 0 {
				local exexog_m "`exexog_m' `mean'"
			}
			tempvar dm
			qui gen double `dm' = `var' - `mean' + `omean' if `touse'
* Don't add time-invariant vars to dm list if balanced panel - causes collinearity problems
			qui sum `dm' if `touse'
			if ~`balanced' | (r(sd) ~= 0) {
				local exexog_dm "`exexog_dm' `dm'"
			}
			tempvar gls
			qui gen double `gls' =`var'-`theta'*`mean'
			local exexog_g "`exexog_g' `gls'"
		}
		if "`inexog'" ~= "" {
			foreach var of varlist `inexog' {
				qui sum `var' if `touse', meanonly
				scalar `omean'=r(mean)
				tempvar mean
				qui by `ivar' `touse': gen double `mean'=sum(`var') if `touse'
				qui by `ivar' `touse': replace `mean' =`mean'[_N]/_N if `touse'
* Don't add group-invariant vars to m OR dm lists - causes collinearity problems
				qui sum `mean' if `touse'
				if r(sd) ~= 0 {
					local inexog_m "`inexog_m' `mean'"
					tempvar dm
					qui gen double `dm' = `var' - `mean' + `omean' if `touse'
* Don't add time-invariant vars to dm list if balanced - causes collinearity problems
* nb: can also cause collinearity in SOME unbalanced panels, e.g., 2 time-invariant vars, but OK
					qui sum `dm' if `touse'
					if ~`balanced' | r(sd) ~= 0 {
						local inexog_dm "`inexog_dm' `dm'"
					}
				}
				tempname gls
				qui gen double `gls' =`var'-`theta'*`mean'
				local inexog_g "`inexog_g' `gls'"
			}
		}

		_estimates hold `regest', restore

		if "`model'"=="g2sls" {
			version `ver': `qui' `ivreg2_cmd' `depvar_g' `inexog_g' `cons' /*
			 	*/	(`instd_g' = `exexog_g') if `touse', nocons `robust' `clopt' `first' `noid'
		}
		else if "`model'"=="ec2sls" {
			if `balanced' {
				version `ver': `qui' `ivreg2_cmd' `depvar_g' `inexog_g' `cons' /*
				*/	(`instd_g' = `exexog_dm' `exexog_m' `inexog_dm') if `touse', /*
				*/	nocons `robust' `clopt' `first' `noid'
			}
			else {
				version `ver': `qui' `ivreg2_cmd' `depvar_g' `cons' /*
				*/	(`inexog_g' `instd_g' = `exexog_dm' `exexog_m' `inexog_m' `inexog_dm') if `touse', /*
				*/	nocons `robust' `clopt' `first' `noid'
			}
		}
		else {
			di in red "xtoverid error: unknown model `model'"
			exit 198
		}
* Save coefficient vector excluding constant
		mat `bivreg2'=e(b)
		local cn : colnames `bivreg2'
		local cn : subinstr local cn "`cons'" "", word count(local hascons2)
		if `hascons2'==1 {
			mat `bivreg2'=`bivreg2'[1,1..colsof(`bivreg2')-1]
		}

		if e(j)==. {
			return scalar j=e(sargan)
			return scalar jp=e(sarganp)
			return scalar jdf=e(sargandf)
		}
		else {
			return scalar j=e(j)
			return scalar jp=e(jp)
			return scalar jdf=e(jdf)
		}

		_estimates unhold `regest'
		restore
	}

	if "`model'" == "htaylor" | "`model'" == "amacurdy" {

* Everything else is instrumented
		local TVexog   = e(TVexogenous)
		local TVendog  = e(TVendogenous)
		local TIexog   = e(TIexogenous)
		local TIendog  = e(TIendogenous)

		capture tsrevar `TVexog'
		if _rc==0 {
			local TVexog `r(varlist)'
		}
		else {
			local TVexog
		}
		capture tsrevar `TVendog'
		if _rc==0 {
			local TVendog `r(varlist)'
		}
		else {
			local TVendog
		}
		capture tsrevar `TIexog'
		if _rc==0 {
			local TIexog `r(varlist)'
		}
		else {
			local TIexog
		}
		capture tsrevar `TIendog'
		if _rc==0 {
			local TIendog `r(varlist)'
		}
		else {
			local TIendog
		}

		scalar `sig_e2'=(e(sigma_e))^2
		scalar `sig_u2'=(e(sigma_u))^2

		sort `ivar' `touse'
		qui by `ivar' `touse': egen `i_obs'=count(`touse') if `touse'
		qui sum `i_obs' if `touse'
		local balanced = (r(min)==r(max))

		qui gen double `theta' = 1- /*
		 	*/ sqrt( `sig_e2'/(`sig_u2'*`i_obs' +`sig_e2' ) ) if `touse'

		preserve

		if `hascons'==1 {
			tempvar cons
			qui gen double `cons' = 1 -`theta' if `touse'
		}
* Dep var
		tempvar depvar_g
		tempvar mean
		qui by `ivar' `touse': gen double `mean'=sum(`depvar') if `touse'
		qui by `ivar' `touse': replace `mean' =`mean'[_N]/_N if `touse'
		qui gen double `depvar_g' =`depvar'-`theta'*`mean' if `touse'

* Time-varying exog => demeaned and mean (HT)
*                   => demeaned and current/leads/lags (AM) (balanced panels only)
		if "`TVexog'"~="" {
			foreach var of varlist `TVexog' {
				tempvar mean
				qui by `ivar' `touse': gen double `mean'=sum(`var') if `touse'
				qui by `ivar' `touse': replace `mean' =`mean'[_N]/_N if `touse'
* Don't add group-invariant vars to m list - causes collinearity problems
				qui sum `mean' if `touse'
				if r(sd) ~= 0 {
					local TVexog_m "`TVexog_m' `mean'"
				}
				tempvar dm
				qui gen double `dm' = `var' - `mean' if `touse'
* Don't add group-invariant vars to dm list if balanced - causes collinearity problems
				if ~`balanced' | r(sd) ~= 0 {
					local TVexog_dm "`TVexog_dm' `dm'"
				}
				tempvar gls
				qui gen double `gls' =`var'-`theta'*`mean' if `touse'
				local TVexog_g "`TVexog_g' `gls'"
			}
		}

		if "`model'" == "amacurdy" {
			local Tbar=e(Tbar)
			local tvar `e(tvar)'
			sort `ivar' `touse' `tvar'
			if "`TVexog'"~="" {
				foreach var of varlist `TVexog' {
					forvalues i = 1/`Tbar' {
						tempvar t
						qui by `ivar' `touse': gen double `t'=`var'[`i'] if `touse'
* Don't add group-invariant vars to t list - causes collinearity problems
						qui sum `t' if `touse'
						if r(sd) ~= 0 {
							local TVexog_t "`TVexog_t' `t'"
						}
					}
				}
			}
		}

* TVendog => demeaned and gls only only
		if "`TVendog'"~="" {
			foreach var of varlist `TVendog' {
				tempvar mean
				qui by `ivar' `touse': gen double `mean'=sum(`var') if `touse'
				qui by `ivar' `touse': replace `mean' =`mean'[_N]/_N if `touse'
				tempvar dm
				qui gen double `dm' = `var' - `mean' if `touse'
				local TVendog_dm "`TVendog_dm' `dm'"
				tempvar gls
				qui gen double `gls' =`var'-`theta'*`mean' if `touse'
				local TVendog_g "`TVendog_g' `gls'"
			}
		}

* TIexog are rescaled by theta
		if "`TIexog'"~="" {
			foreach var of varlist `TIexog' {
				tempvar gls
				qui gen double `gls' =`var'-`theta'*`var' if `touse'
				local TIexog_g "`TIexog_g' `gls'"
			}
		}

* TIendog are rescaled by theta
		if "`TIendog'"~="" {
			foreach var of varlist `TIendog' {
				tempvar gls
				qui gen double `gls' =`var'-`theta'*`var' if `touse'
				local TIendog_g "`TIendog_g' `gls'"
			}
		}

		_estimates hold `regest', restore

		if "`model'" == "htaylor" {
			if `balanced' {
				version `ver': `qui' `ivreg2_cmd' `depvar_g' `TVexog_g' `TIexog_g' `cons' 						/*
					*/	(`TVendog_g' `TIendog_g' = 		/*
					*/	`TVexog_dm' `TVendog_dm') 		/*
					*/	if `touse', nocons small `robust' `clopt' `first' `noid'
			}
			else {
				version `ver': `qui' `ivreg2_cmd' `depvar_g' `cons' 						/*
					*/	(`TVexog_g' `TVendog_g' `TIexog_g' `TIendog_g' = 	/*
					*/	`TVexog_dm' `TVendog_dm' `TVexog_m' `TIexog') 		/*
					*/	if `touse', nocons small `robust' `clopt' `first' `noid'
			}
		}
		else if "`model'" == "amacurdy" {
			version `ver': `qui' `ivreg2_cmd' `depvar_g' `TVexog_g' `TIexog_g' `cons' 						/*
				*/	(`TVendog_g' `TIendog_g' = 		/*
				*/	`TVexog_t' `TVendog_dm') if `touse', /*
				*/	nocons small `robust' `clopt' `first' `noid'
		}
		else {
			di in red "xtoverid error: unknown model `model'"
			exit 198
		}
* Save coefficient vector excluding constant
		mat `bivreg2'=e(b)
		local cn : colnames `bivreg2'
		if `hascons'==1 {
			local cn : subinstr local cn "`cons'" "", word count(local hascons2)
			if `hascons2'==1 {
				mat `bivreg2'=`bivreg2'[1,1..colsof(`bivreg2')-1]
			}
		}

		if e(j)==. {
			return scalar j=e(sargan)
			return scalar jp=e(sarganp)
			return scalar jdf=e(sargandf)
		}
		else {
			return scalar j=e(j)
			return scalar jp=e(jp)
			return scalar jdf=e(jdf)
		}

		_estimates unhold `regest'

		restore
	}

* Check that original coefficient vector matches coefficient vector generated by internal call to ivreg2
* Remove constant from original beta if there
	if `hascons'==1 {
		mat `b'=`b'[1,1..colsof(`b')-1]
	}
	if "`e(cmd)'"~="xtreg" {
* Sort so coeffs are ordered low to high and check vs. original estimation (not necess for xtreg)
		vecsort `b'
		vecsort `bivreg2'
		local cob=colsof(`b')
		forvalues i=1/`cob' {
			if reldif(`b'[1,`i'],`bivreg2'[1,`i']) > 1e-5 {
di in red "xtoverid error: internal reestimation of eqn differs from original"
				exit 198
			}
		}
	}
di
di in gr "Test of overidentifying restrictions: `desc'"
// cfb add gmm2s
di in gr "Cross-section time-series model: `e(cmd)' `model' `gmm2s' `robust' `clopt'"
di in gr  _c in gr "Sargan-Hansen statistic" in ye _col(25) %7.3f return(j) in gr
	if return(j)==0 {
di in gr "  (equation exactly identified)"
	}
	else {
di in gr "  Chi-sq(" %1.0f in ye return(jdf) in gr ")" _col(47) "P-value = " in ye %5.4f return(jp)
	}

end

program define vecsort		/* Also clears col/row names */
	version 8.2
	args vmat
	tempname hold
	mat `vmat'=`vmat'+J(rowsof(`vmat'),colsof(`vmat'),0)
	local lastcol = colsof(`vmat')
	local i 1
	while `i' < `lastcol' {
		if `vmat'[1,`i'] > `vmat'[1,`i'+1] {
			scalar `hold' = `vmat'[1,`i']
			mat `vmat'[1,`i'] = `vmat'[1,`i'+1]
			mat `vmat'[1,`i'+1] = `hold'
			local i = 1
		}
		else {
			local i = `i' + 1
		}
	}
end
