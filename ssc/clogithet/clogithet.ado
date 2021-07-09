*! clogithet 1.2.1  06Feb2009
*! author arh

*  1.1.0:  	clogithet now allows weights 
*  1.2.0:  	clogithet replays previous estimation 
*		results if called without arguments
*  1.2.1:  	`newgr' and `newclust' variables are 
*		now stored as doubles 

program clogithet
	version 9.2
	if replay() {
		if (`"`e(cmd)'"' != "clogithet") error 301
		Replay `0'
	}
	else	Estimate `0'
end

program Estimate, eclass sortpreserve
	version 9.2
	syntax varlist [if] [in]		/// 
		[fweight pweight iweight/],	///
		GRoup(varname) 			///
		HET(varlist) [			///
		Robust				///
		CLuster(varname)			///
		CLOGit				///
		LM					///
		OPG					///
		NOPREserve				///
		TRace					///
		GRADient				///
		HESSian				///
		SHOWSTEP				///
		ITERate(passthru)			///
		TOLerance(passthru)		///
		LTOLerance(passthru)		///
		GTOLerance(passthru)		///
		NRTOLerance(passthru)		///
		TECHnique(passthru)		///
		DIFficult				///
	]

	local mlopts `trace' `gradient' `hessian' `showstep' `iterate' `tolerance' ///
	`ltolerance' `gtolerance' `nrtolerance' `technique' `difficult'

	if ("`technique'" == "technique(bhhh)") {
		di in red "technique(bhhh) is not allowed."
		exit 498
	}

	tempvar cho alt newgr newclust countobs countgr dup
	tempname nobs ngroup b0 b1 k_0 ll_0 grad vce V ll chi2 p df_m

	gettoken lhs rhs : varlist

	global CLHET_X `rhs'
	global CLHET_HET `het'

	** Mark the estimation sample **
	marksample touse
	markout `touse' `group' `het' `cluster'

	** Mark groups with more than one/no chosen alternatives **
	sort `group'
	qui by `group': egen `cho' = sum(`lhs'*`touse') 
	qui replace `cho' = . if `cho' == 0 | `cho' > 1  
	markout `touse' `cho'

	** Generate new group/cluster variable **
	qui gen double `newgr' = `group'
	qui replace `newgr' = . if `touse' == 0
	sort `newgr'
	global CLHET_ID `newgr'
	global CLHET_CLUSTID

	if "`cluster'" != "" {
		qui gen double `newclust' = `cluster'
		qui replace `newclust' = . if `touse' == 0
		global CLHET_CLUSTID `newclust'
	}

	** Check if het vars are constant within groups **
	sort `newgr' 
	quietly by `newgr': egen `alt' = sum(1) if `touse'
	sort `newgr' `het'
	quietly by `newgr' `het': egen `dup' = sum(1) if `touse'
	capture assert `dup' == `alt' if `touse'  
	if _rc != 0 {
		di in r "At least one variable in het() is not constant within groups"
		exit 498
	}

	** Use robust SEs with pweight even if not specified **
	if "`weight'" == "pweight" & "`robust'" == "" & "`cluster'" == "" {
		local robust robust
	}

	** Define globals for weights **
	if "`weight'" != "" { 
		global CLHET_WGT `exp'
		global CLHET_WGTTYP `weight'
		local wgt "[`weight' = `exp']"
		if "`weight'" == "fweight" local swgt "[fw = `exp']"
	}
	else {
		global CLHET_WGT 1
		global CLHET_WGTTYP
	}

	** Calculate number of observations **
	gen double `countobs' = 1	
	qui sum `countobs' if `touse' `swgt', meanonly
	scalar `nobs' = r(sum)

	** Calculate number of groups **
	by `newgr': gen double `countgr' = cond(_n==_N,1,0)	
	qui sum `countgr' if `touse' `swgt', meanonly
	scalar `ngroup' = r(sum)

	** Calculate number of clusters **
	if "`cluster'" != "" {
		tempname nclust
		qui duplicates report `cluster' if `touse'
		scalar `nclust' = r(unique_value)	
	}

	if "`clogit'" != "" {
		di as txt _n "Fitting conditional logit model:"
		if "`cluster'" == "" {
			if "`opg'" != "" {
				local vcetype vce(opg)
			}
			if "`robust'" != "" {
				local vcetype vce(robust)			
			}
			clogit `lhs' `rhs' if `touse' `wgt', group(`group') `vcetype'
		}
		else {
			clogit `lhs' `rhs' if `touse' `wgt', group(`group') cluster(`cluster')
		}
	}
	else {
		qui clogit `lhs' `rhs' if `touse' `wgt', group(`group')
	}

	local k_0  = e(k)
	local ll_0 = e(ll)

	matrix `b0' = e(b)
	matrix coleq `b0' = variables

	** Calculate Hessian based LM statistic **
	if "`robust'" == "" & "`cluster'" == "" & "`opg'" == "" {
	tempname lm_h
	ml model d1 clhet_d2						///
		(variables: `lhs' = `rhs', noconst)			///
		(het: `het', noconst)					///
		if `touse', search(off)				///
		init(`b0') iter(0) missing maximize nowarning 	///
		nolog `nopreserve'			
		matrix `vce'  = e(V)
		matrix `grad' = e(gradient) 
		matrix `lm_h' = `grad'*`vce'*`grad''				
	}

	** Calculate OPG based LM statistic **
	if "`opg'" != "" {
	tempname lm_opg opgm 
	ml model d2 clhet_d2						///
		(variables: `lhs' = `rhs', noconst)			///
		(het: `het', noconst)					///
		if `touse', search(off)					///
		init(`b0') iter(0) missing maximize nowarning 	///
		nolog `nopreserve'
		matrix `opgm'   = e(V)
		matrix `grad'   = e(gradient) 
		matrix `lm_opg' = `grad'*`opgm'*`grad''	
	}

	** Calculate robust LM statistic **
	if "`robust'" != "" | "`cluster'" != "" { 
	tempname lm_rob opgm rob
	ml model d1 clhet_d2						///
		(variables: `lhs' = `rhs', noconst)			///
		(het: `het', noconst)					///
		if `touse', search(off)					///
		init(`b0') iter(0) missing maximize nowarning 	///
		nolog `nopreserve'			
		matrix `vce'  = e(V)
		matrix `grad' = e(gradient) 

	ml model d2 clhet_d2						///
		(variables: `lhs' = `rhs', noconst)			///
		(het: `het', noconst)					///
		if `touse', search(off)					///
		init(`b0') iter(0) missing maximize nowarning 	///
		nolog `nopreserve'
		matrix `opgm' = e(V)
		if "`robust'" != "" { 
			matrix `rob' = (`ngroup'/(`ngroup'-1))* 	///
						`vce'*inv(`opgm')*`vce'
		}	
		if "`cluster'" != "" { 
			matrix `rob' = (`nclust'/(`nclust'-1))* 	///
						`vce'*inv(`opgm')*`vce'
		}
		matrix `lm_rob' = `grad'*`rob'*`grad''	
	}
	
	** Estimate heteroscedastic logit model **
	di as txt _n "Fitting heteroscedastic model:"
	ml model d1 clhet_d2						///
		(variables: `lhs' = `rhs', noconst)			///
		(het: `het', noconst)					///
		if `touse', search(off)	`mlopts' 			///
		init(`b0') missing maximize lf0(`k_0' `ll_0') 	///
		`nopreserve'				 
		matrix `b1'  = e(b)
		matrix `vce' = e(V)

	** Calculate OPG matrix **
	if "`robust'" != "" | "`cluster'" != "" | "`opg'" != "" {
	ml model d2 clhet_d2						///
		(variables: `lhs' = `rhs', noconst)			///
		(het: `het', noconst)					///
		if `touse', search(off)					///
		init(`b1') iter(0) missing maximize nowarning 	///	    
		nolog	lf0(`k_0' `ll_0') `nopreserve'
		matrix `opgm' = e(V)
	}

	if "`robust'" == "" & "`cluster'" == "" & "`opg'" == "" {
		matrix `V' = `vce'
	}
	if "`opg'" != "" {
		matrix `V' = `opgm'
	}
	if "`robust'" != "" { 
		matrix `V' = (`ngroup'/(`ngroup'-1))* ///
					`vce'*inv(`opgm')*`vce'
	}	
	if "`cluster'" != "" { 
		matrix `V' = (`nclust'/(`nclust'-1))* ///
					`vce'*inv(`opgm')*`vce'
	}

	di
	di in g "Heteroscedastic logistic regression" /*
			*/ _col(49) in g "Number of obs" _col(67) in g "="   /*
			*/ _skip(3) in y %8.0f `nobs'

	di _col(49) in g "Number of groups" _col(67) in g "="   /*
			*/ _skip(3) in y %8.0f `ngroup'

	di _col(49) in g "LR chi2(" in y e(df_m) in g ")" _col(67) in g "="   /*
			*/ _skip(6) in y %5.2f e(chi2)

	di in g "Log likelihood = "   /*
			*/ _col(15) in y e(ll) /* 
			*/ _col(49) in g "Prob > chi2" _col(67) in g "=" /*
			*/ _skip(5) in y %5.4f e(p)

	scalar `ll' = e(ll)
	scalar `chi2' = e(chi2)
	scalar `p' = e(p)
	scalar `df_m' = e(df_m)

	ereturn post `b1' `V', esample(`touse') depname(`lhs') 

	ereturn local depvar `lhs'
	ereturn local indepvars `rhs'
	ereturn local group `group'
	ereturn local het `het'
	ereturn scalar ll = `ll'
	ereturn scalar N = `nobs'
	ereturn scalar N_g = `ngroup'
	ereturn scalar chi2 = `chi2'
	ereturn scalar p = `p'
	ereturn scalar df_m = `df_m'
	ereturn local title Heteroscedastic logistic regression

	if "`weight'" != "" { 
		ereturn local wexp `exp'
		ereturn local wtype `weight'
	}

	if "`robust'" == "" & "`cluster'" == "" & "`opg'" == "" {
		if "`lm'" != "" {
			ereturn scalar lm = `lm_h'[1,1]
			ereturn scalar lm_p = chi2tail(`df_m',e(lm))
		}
	}
	if "`opg'" != "" {
		ereturn local vcetype OPG		
		if "`lm'" != "" {
			ereturn scalar lm_opg = `lm_opg'[1,1]
			ereturn scalar lm_opg_p = chi2tail(`df_m',e(lm_opg))
		}
	}
	if "`robust'" != "" {
		ereturn local vcetype Robust
		if "`lm'" != "" {
			ereturn scalar lm_rob = `lm_rob'[1,1]
			ereturn scalar lm_rob_p = chi2tail(`df_m',e(lm_rob))
		}
	}
	if "`cluster'" != "" {	
		ereturn scalar N_clust = `nclust'
		ereturn local clustvar `cluster'
		ereturn local vcetype Robust
		if "`lm'" != "" {
			ereturn scalar lm_rob = `lm_rob'[1,1]
			ereturn scalar lm_rob_p = chi2tail(`df_m',e(lm_rob))
		}
	}

	di
	ereturn display

	if "`lm'" != "" { 
		if "`robust'" == "" & "`cluster'" == "" & "`opg'" == "" {
			di in g "LM test for heteroscedasticity chi2("  /*
				*/ in y `df_m' in g ") = " in y %5.2f e(lm) /*
				*/ _skip(11) in g " Prob > chi2" in g " = " /*
				*/ in y %5.4f chi2tail(`df_m',e(lm))
		}
		if "`opg'" != "" {
			di in g "OPG based LM test for heteroscedasticity chi2("  /*
				*/ in y `df_m' in g ") = " in y %5.2f e(lm_opg) /*
				*/ _skip(1) in g " Prob > chi2" in g " = " /*
				*/ in y %5.4f chi2tail(`df_m',e(lm_opg))
		}
		if "`robust'" != "" | "`cluster'" != "" {
			di in g "Robust LM test for heteroscedasticity chi2(" /*
				*/ in y `df_m' in g ") = " in y %5.2f e(lm_rob) /*
				*/ _skip(4) in g " Prob > chi2" in g " = " /*
				*/ in y %5.4f chi2tail(`df_m',e(lm_rob))
		}
	}
	ereturn local cmd clogithet
end

program Replay
	di
	di in g "Heteroscedastic logistic regression" /*
			*/ _col(49) in g "Number of obs" _col(67) in g "="   /*
			*/ _skip(3) in y %8.0f e(N)

	di _col(49) in g "Number of groups" _col(67) in g "="   /*
			*/ _skip(3) in y %8.0f e(N_g)

	di _col(49) in g "LR chi2(" in y e(df_m) in g ")" _col(67) in g "="   /*
			*/ _skip(6) in y %5.2f e(chi2)

	di in g "Log likelihood = "   /*
			*/ _col(15) in y e(ll) /* 
			*/ _col(49) in g "Prob > chi2" _col(67) in g "=" /*
			*/ _skip(5) in y %5.4f e(p)

	di
	ereturn display

	if "`e(lm)'" != "" {
		di in g "LM test for heteroscedasticity chi2("  /*
			*/ in y e(df_m) in g ") = " in y %5.2f e(lm) /*
			*/ _skip(11) in g " Prob > chi2" in g " = " /*
			*/ in y %5.4f chi2tail(e(df_m),e(lm))
	}
	if "`e(lm_opg)'" != "" {
		di in g "OPG based LM test for heteroscedasticity chi2("  /*
			*/ in y e(df_m) in g ") = " in y %5.2f e(lm_opg) /*
			*/ _skip(1) in g " Prob > chi2" in g " = " /*
			*/ in y %5.4f chi2tail(e(df_m),e(lm_opg))
	}
	if "`e(lm_rob)'" != "" {
		di in g "Robust LM test for heteroscedasticity chi2(" /*
			*/ in y e(df_m) in g ") = " in y %5.2f e(lm_rob) /*
			*/ _skip(4) in g " Prob > chi2" in g " = " /*
			*/ in y %5.4f chi2tail(e(df_m),e(lm_rob))
	}
end

exit
