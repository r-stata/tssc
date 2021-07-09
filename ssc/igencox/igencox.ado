*! version 1.0.0  12dec2011
program igencox, eclass byable(onecall) prop(irr)
	version 12
		
	local version : di "version " string(_caller()) ":"

	if replay() {
		if "`e(cmd)'" != "igencox" {
			error 301
		}
		if _by() { 
			error(190)
		}
		Display `0'
		exit
	}
	
	if _by() {
		local BY `"by `_byvars'`_byrc0':"'
	}
	
	// must parse vce option yourself
	
	syntax varlist(fv) [if] [in] [, vce(string) SAVESPace 		///
		baseq(passthru) sebaseq(passthru) nocov SAVESIgma(string) * ]
	
	if "`cov'"=="nocov" {
		if `"`baseq'"' != `""' {
			di "{err}{bf:baseq()} not allowed with {bf:nocov}"
			exit 198
		}
		if `"`sebaseq'"' != `""' {
			di "{err}{bf:sebaseq()} not allowed with {bf:nocov}"
			exit 198
		}
	}
	
	if `"`vce'"' != `""' {
		gettoken vcetype vcerest : vce , parse(", ")
		local lsub = length("`vcetype'")
		
		if "`vcetype'"!=substr("bootstrap", 1, max(4,`lsub')) {
			di "{err}vcetype 'vcetype' not allowed"
			exit 198
		}
		
		if `"`savesigma'"' != `""' {
			di "{err}option savesigma() not allowed with vce(bootstrap)"
			exit 198
		}
		
		if `"`baseq'"' != `""' {
			di "{err}{bf:baseq()} not allowed with {bf:vce(bootstrap)}"
			exit 198
		}
		if `"`sebaseq'"' != `""' {
			di "{err}{bf:sebaseq()} not allowed with {bf:vce(bootstrap)}"
			exit 198
		}
		
		`version' `BY' bootstrap `vcerest' : igencox ///
			`varlist' `if' `in', `options' `savespace' nocov
		ereturn local cmdline `"igencox `0'"'
		exit
	}
	
	if "`savespace'" != "" {
di "{txt}note: standard errors not available with the {cmd:savespace} option"
	}
	`version' `BY' Estimate `0'
	ereturn local cmdline `"igencox `0'"'
end

program define Estimate, eclass byable(recall)

	version 11
	
	syntax varlist(fv) [if] [in] , 	  		  ///
		[ 					  ///
		TRANSform(string)			  ///
		Level(cilevel)				  ///
		ITERate(numlist min=1 max=1 >=0 <=16000)  ///
		TOLerance(numlist min=1 max=1 >0 <1)	  ///
		from(name)				  ///
		SAVESPace				  ///
		nolog					  ///
		noSHow					  ///
		baseq(string)				  ///
		sebaseq(string)				  ///  UNDOCUMENTED
		nocov					  ///  UNDOCUMENTED
		SAVESIgma(string)			  ///
		*					  ///
		]
	
	st_is 2 analysis
	st_show `show'
	
	marksample touse
	if "`offset'" != "" markout `touse' `offset'
	
	tempvar rsk
	
	qui su _d if `touse', meanonly
	local fail `r(sum)'
	local N `r(N)'
	qui gen double `rsk' = _t - _t0
	qui su `rsk', meanonly
	drop `rsk'
	local risk `r(sum)'
	if "`_dta[st_id]'" != "" {
		mata: igencox_unique("`_dta[st_id]'","`touse'")
		local sub = `r(sub)'
	}
	else local sub `N'
	
	_get_diopts diopts other, `options'
	if `"`other'"' != `""' {
		di `"{err}option {cmd:`other'} not allowed"'
		exit 198
	}
	
	if "`iterate'" == "" local iterate 1000
	if "`tolerance'" == "" local tolerance = 1e-6
	if `"`from'"' != "" {
		confirm matrix `from'
		local hasb0 1
	}
	else local hasb0 0
	
	tempname b V omz omx
	
	_rmcoll `varlist', expand
	local z `r(varlist)'
	local w : word count `z'
	mat `b' = J(1,`w',0)
	mat colnames `b' = `z'
	_ms_omit_info `b'
	mat `omz' = r(omit)
	
	gettoken tran rho : transform
	_check_transform , `tran'
	local trn `s(tran)'
	local tr `s(trans)'
	if "`rho'" == "" local rho 1
	capture confirm number `rho'
	if _rc {
		di "{err}invalid # in transform()"
		exit 198
	}
	
	if `"`baseq'"' != `""' {
		local w : word count `baseq'
		if `w' > 1 {
			di "{err}only one newvarname allowed in baseq()"
			exit 198
		}
		confirm new variable `baseq', exact
		qui gen double `baseq' = .
		label var `baseq' "Jump size of Lambda (q_i)"
	}
	if `"`sebaseq'"' != `""' {
		local w : word count `sebaseq'
		if `w' > 1 {
			di "{err}only one newvarname allowed in sebaseq()"
			exit 198
		}
		confirm new variable `sebaseq', exact
		qui gen double `sebaseq' = .
		label var `sebaseq' "S.E. of jump size of Lambda (q_i)"
		
		tempvar seq
		qui gen byte `seq' = `touse'*_d
	}
	
	if "`savespace'" != "" local cov nocov
	
	if `"`savesigma'"' != `""' {
		if "`savespace'" != "" {
			di "{err}option savesigma() not allowed with savespace"
			exit 198
		}
		gettoken file replace : savesigma , parse( ,) quotes
		local replace : subinstr local replace "," "", all
		local replace = trim("`replace'")
		if "`replace'"=="" {
			capture confirm new file `"`file'"'
			local rc = _rc
			if `rc' {
				capture drop `baseq'
				capture drop `sebaseq'
				di `"{err}file `file' already exists"'
				exit `rc'
			}
		}
		else capture erase `"`file'"'
	}
	
	mata: igencoxem_main("_t","_d","`tvc'","`z'","`touse'",	///
		`trn',`rho',`tolerance',`iterate',`hasb0')
	
	if "`baseq'" != "" qui replace `baseq' = . if _d==0
	
	local conv = `r(converged)'
	local iter = `r(iter)'
	local crit = `r(crit)'
	local ll   = `r(ll)'
	local rank = `r(rank)'
	local ties = `r(ties)'
	
	mat `b'  = r(b)
	mat `V'  = r(V)
	
	mat colnames `b' = `z'
	mat rownames `V' = `z'
	mat colnames `V' = `z'
	
	ereturn post `b' `V', e(`touse') depname(_t) buildfvinfo
		
	capture test `z'
	if !_rc {
		local chisq = `r(chi2)'
		local df = `rank'
		local pval = chi2tail(`df',`chisq')
	}
	else {
		local chisq .
		local df .
		local pval .
	}
	
	ereturn scalar N = `N'
	ereturn scalar N_sub = `sub'
	ereturn scalar N_fail = `fail'
	ereturn scalar risk = `risk'
	ereturn scalar ties = `ties'
	ereturn scalar k_eq_model = 1
	ereturn scalar df_m = `df'
	ereturn scalar ll = `ll'
	ereturn scalar chi2 = `chisq'
	ereturn scalar p = `pval'
	ereturn scalar rank = `rank'
	ereturn scalar rho = `rho'
	ereturn scalar iter = `iter'
	ereturn scalar crit = `crit'
	ereturn scalar tol = `tolerance'
	ereturn scalar converged = `conv'
	
	if `"`file'"' != `""' ereturn local sigma `"`file'"'
	ereturn local baseq "`baseq'"
	ereturn local predict "igencox_p"
	ereturn local chi2type = "Wald"
	ereturn local transformation  "`tr'"
	ereturn local t0 "_t0"
	ereturn local covariates "`z'"
	ereturn local depvar "_t"
	ereturn local cmd "igencox"
	
	Display , level(`level') conv(`conv') `diopts' `irr'
	
end

program _check_transform, sclass
	syntax [ , BOXcox LOGarithmic * ]
	
	if "`options'" != "" {
		di "{err}transform(`options') not allowed"
		exit 198
	}
	
	if "`boxcox'" != "" 	  local tran 1
	if "`logarithmic'" != ""  local tran 2
	if "`tran'" == ""	  local tran 1
	
	local trans "`boxcox'`logarithmic'"
	if "`trans'"=="" local trans boxcox
	
	sreturn local tran `tran'
	sreturn local trans `trans'
end

program Display
	syntax [, Level(cilevel) conv(numlist) IRr *]
	if "`irr'"!="" {
		local eopt "eform(IRR)"
	}
	_get_diopts diopts, `options'
	
	if "`conv'"=="" local conv 1
	
	if (`e(ties)') local ties " -- no correction for ties"
	
	if "`e(transformation)'" == "boxcox" local trans Box-Cox
	else local trans Logarithmic
	
	if (!`conv') di "{txt}convergence not achieved"
	di _n as txt "Generalized Cox regression`ties'"
	di in gr "Transformation: `trans'(" in ye `e(rho)' in gr ")"
	_igencox_header
	di
	_coef_table, level(`level') `eopt' `diopts'
	if (!`conv') di "{txt}Warning: convergence not achieved"
end

program _igencox_header
	local crtype = upper(substr(`"`e(crittype)'"',1,1)) + ///
		substr(`"`e(crittype)'"',2,.)
	local crlen = max(15,length(`"`crtype'"'))
	
	di _n in gr %-`crlen's "No. of subjects" " = " ///
		in ye %12.0g e(N_sub) ///
		_col(55) in gr "No. of obs   =" in ye %10.0g e(N)
	
	di in gr %-`crlen's "No. of failures" " = " in ye %12.0g e(N_fail)
	di in gr %-`crlen's "Time at risk" " = " in ye %12.0g e(risk)
	
	di _col(52) in gr "`e(chi2type)' chi2(" in ye e(df_m) in gr ")" ///
		_col(68) "=" in ye %10.2f e(chi2)
	di in gr %-`crlen's "Log likelihood" " = " in ye %12.0g e(ll) ///
		_col(52) in gr "Prob > chi2" _col(68) "=" in ye %10.4f e(p)
end

exit
