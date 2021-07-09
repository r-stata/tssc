*! version 1.0.2  24jan2012
program define _spreg_ml, eclass sortpreserve

	version 11.1
	
	syntax varlist(numeric) [if] [in] ,		///
		id(varname numeric)			///
		[					///
		DLmat(string)				///
		ELmat(string)				///
		noCONstant				///
		robust					///  UNDOCUMENTED
		UNconcentrated				///  UNDOCUMENTED
		CONSTraints(string)			///
		noCNSReport				///
		Level(cilevel)				///
		GRIDsearch(numlist max=1 >=.001 <=.1)	///
		from(passthru)				///
		DIFFicult				///
		TECHnique(string asis)			///
		ITERate(numlist max=1 integer >=0)	///
		TRace					///
		GRADient				///
		showstep				///
		HESSian					///
		SHOWTOLerance				///
		TOLerance(real 1e-6)			///
		LTOLerance(real 1e-7)			///
		NRTOLerance(real 1e-5)			///
		NONRTOLerance				///
		noLOG					///
		*					///
		]
	
	if "`gridsearch'" == "" local gridsearch = .1
	if "`iterate'" == "" local iterate = c(maxiter)
	if "`technique'" == "" local technique = "nr"
	
	marksample touse, //!!novarlist
	
	preserve
	qui keep if `touse'
	
	qui count if `touse'
	local N = r(N)
	
	_get_diopts diopts options, `options'
	
	gettoken depvar indeps: varlist
	
	_rmcoll `indeps' if `touse', `constant'
        local indeps `r(varlist)'
	local indeps0 `indeps'
	
	if "`dlmat'`elmat'" == "" { 			// +++++ regress: case 1
		
		qui regress `depvar' `indeps', `constant' `robust'
		Results `depvar', case(1) level(`level') id(`id')  ///
			iv(`indeps0') `constant' `robust'
		ereturn repost, esample(`touse')
		restore
		exit 0
	}
	
	// initial values should be specified in the order 
	// the parameters are reported: beta, lambda, rho, sigma2
	// for the concentrated ll only lambda, rho
	
	if `"`from'"' != "" {
		tempname initb init
		_mkvec `initb', `from' error("from()")
		local names : colnames `initb'
		mata:`init'=st_matrix("`initb'")
	}
	
	// SPMAT_ML_ops_parse parses optimize options in Mata and
	// returns a structure which is in turn passed to SPREG_ml_main()
	
	tempname mlopts
	
	// pass the tempnames used by Mata to the caller
	c_local matanames `mlopts' `init'
	
	mata: `mlopts' = SPMAT_ML_opts_parse("`difficult'", "`technique'",   ///
		"`log'", "`trace'", "`showstep'", "`gradient'","`hessian'",  ///
		"`showtolerance'", "`nonrtolerance'",`iterate', `tolerance', ///
		`ltolerance', `nrtolerance',`init')
	
	if "`constant'" == "" {
		tempvar cons
		qui gen double `cons' = 1
		local indeps `indeps0' `cons'
	}
	
	if "`dlmat'" != "" {
		gettoken dlmat dleig: dlmat, parse(", ")
		gettoken junk dleig: dleig, parse(",")
		local dleig = strtrim("`dleig'")
	}
	
	if "`elmat'" != "" {
		gettoken elmat eleig: elmat, parse(", ")
		gettoken junk eleig: eleig, parse(",")
		local eleig = strtrim("`eleig'")
	}
	
	if "`dlmat'" != "" & "`elmat'" == "" {	       // +++++++++++++++ case 2
		
		ObjCheck, objname(`dlmat') id(`id') touse(`touse') 	///
			y(`depvar') x(`indeps0')
		
		CnsCheck, dv(`depvar') iv(`indeps0') constr(`constraints')  ///
			  case(2) `constant' `cnsreport'
		
		mata: SPREG_ml_main("`depvar'","`indeps'","`touse'",2, 	///
			"`dlmat'","`dleig'","`elmat'","`eleig'",	///
			"`unconcentrated'","`gridsearch'",`mlopts')
		
		local tech "`technique'"
		
		Results `depvar', iv(`indeps0') case(2) `constant' `log'    ///
			level(`level') constr(`constraints') diopt(`diopts') ///
			dlmat(`dlmat') tech(`tech') id(`id') `robust'
	}
	else if "`dlmat'" == "" & "`elmat'" != "" {	// ++++++++++++++ case 3
		
		ObjCheck, objname(`elmat') id(`id') touse(`touse') 	///
			y(`depvar') x(`indeps0')
		
		CnsCheck, dv(`depvar') iv(`indeps0') constr(`constraints')  ///
			  case(3) `constant' `cnsreport'
		
		mata: SPREG_ml_main("`depvar'","`indeps'","`touse'",3,	///
			"`dlmat'","`dleig'","`elmat'","`eleig'",	///
			"`unconcentrated'","`gridsearch'",`mlopts')
		
		local tech "`technique'"
		
		Results `depvar', iv(`indeps0') case(3) `constant' `log'    ///
			level(`level') constr(`constraints') diopt(`diopts') ///
			elmat(`elmat') tech(`tech') id(`id') `robust'
	}
	else {				       	       // +++++++++++++++ case 4
		
		ObjCheck, objname(`dlmat') o2(`elmat') id(`id') 	///
			touse(`touse') y(`depvar') x(`indeps0')
		
		CnsCheck, dv(`depvar') iv(`indeps0') constr(`constraints')  ///
			  case(4) `constant' `cnsreport'
		
		mata: SPREG_ml_main("`depvar'","`indeps'","`touse'",4,	///
			"`dlmat'","`dleig'","`elmat'","`eleig'",	///
			"`unconcentrated'","`gridsearch'",`mlopts')
		
		local tech "`technique'"
		
		Results `depvar', iv(`indeps0') case(4) `constant' `log'    ///
			level(`level') constr(`constraints') diopt(`diopts') ///
			dlmat(`dlmat') elmat(`elmat') tech(`tech') id(`id') ///
			`robust'
	}
	
	restore
	
	ereturn repost, esample(`touse')

end

program define ObjCheck
	
	syntax , Objname(string) 	///
		[ 			///
		id(varname) 		///
		Touse(varname) 		///
		y(varname) 		///
		x(string) 		///
		o2(string) 		///
		]

	capture mata: SPMAT_assert_object("`objname'")
	if _rc {
		di "{inp}`objname' {err}is not a valid {help spmat} object"
		exit 498
	}
	mata: SPMAT_check_if_banded("`objname'",1)
	
	if "`o2'"!="" {
		capture mata: SPMAT_assert_object("`o2'")
		if _rc {
			di "{inp}`o2' {err}is not a valid {help spmat} object"
			exit 498
		}
		mata: SPMAT_check_if_banded("`o2'",1)
	}
	
	if "`id'"!="" {
		mata: SPMAT_idmatch("`objname'","`id'","`y'","`x'","`o2'")
	}

end

program define CnsCheck, eclass

	syntax , case(integer)			///
		 dv(varname)			///
		 [				///
		  iv(string)			///
		  CONSTRaints(numlist) 		///
		  noCONStant			///
		  noCNSReport			///
		 ]
	
	if "`constraints'"=="" exit 0
	
	tempname bcns vcns
		
	GetNames `dv', iv(`iv') case(`case') `constant'
	
	local lbl `r(lbl)'
	local dim : word count `lbl'
	
	mat `bcns' = J(1,`dim',0)
	matrix colnames `bcns' = `lbl'
	
	mat `vcns' = `bcns''*`bcns'
	
	ereturn post `bcns' `vcns'
	mat `vcns' = get(VCE)
	
	local constraints : subinstr local constraints "," " ", all
	
	if "`cnsreport'"=="" local display "display"
	
	makecns `constraints', nocnsnotes `display'
	tempname C
	capture matrix `C' = get(Cns)
	if _rc {
		di "{err}invalid constraint"
		exit 303
	}
	
	ereturn matrix cns `C'
	
end

program define Results, eclass
	
	syntax varname, case(real) [ 			///
		iv(string) 				///
		id(varname numeric)			///
		UNconcentrated				///
		robust					///
		noCONStant 				///
		noLOG 					///
		Level(cilevel)				///
		CONSTraints(string)			///
		DIopts(string)				///
		dlmat(string)				///
		elmat(string)				///
		tech(string asis)			///
		]
	
	if `case'==1 {
				
		di
		
		di as txt "Spatial autoregressive model " 	///
		"{col 51}Number of obs {col 67}= " as res %8.0f e(N)
		
		local df1 = e(df_m)
		local df2 = e(df_r)
		local p =  Ftail(`df1',`df2',e(F))
		
		di as txt "(Maximum likelihood estimates)"		/// 
			"{col 51}F(" as res %3.0f `df1' as txt "," 	///
			as res %6.0f `df2' as txt ")" 			///
			"{col 67}= " as res %8.7g e(F)
		di as txt "{col 51}Prob > F" "{col 67}= " as res %8.4f `p'
		
		di
		
		_coef_table, level(`level')
		
		tempname eb ev
		matrix `eb' = e(b)
		matrix `ev' = e(V)
		local n = e(N)
		local ll = e(ll)
		
		ereturn post `eb' `ev', obs(`n')
		
		ereturn scalar ll = `ll'
		ereturn local idvar "`id'"
		if "`iv'"!= "" ereturn local indeps "`iv'"
		ereturn local depvar "`varlist'"
		
		if "`constant'"=="" {
			ereturn local constant hasconstant
		}
		else ereturn local constant noconstant
		
		if "`robust'" != "" {
			ereturn local het heteroskedastic
		}
		else ereturn local het homoskedastic
		
		ereturn local model lr
	}
	else {
	
		tempname eb ev Cns grad iterlog
		matrix `eb' = r(bhat)
		matrix `ev' = r(Vhat)
		matrix `grad' = r(gradient)
		matrix `iterlog' = r(ilog)
		local n = r(N)
		local k = r(k)
		local ll = r(ll)
		local rank = r(rank)
		local iters = r(iters)
		local converged = r(converged)
		local tech = r(technique)
		
		if "`constraints'"!="" {
			matrix `Cns' = get(Cns)
		}
		else local Cns ""
		
		GetNames `varlist', case(`case') iv(`iv') `constant'
		local lbl `r(lbl)'
		
		matrix rownames `eb' = y1
		matrix colnames `eb' = `lbl'
		matrix rownames `ev' = `lbl'
		matrix colnames `ev' = `lbl'
				
		ereturn post `eb' `ev' `Cns'
				
		//ereturn local gof "spreg_gof"
		ereturn local estat_cmd "spreg_estat"
		ereturn local predict "spreg_p"
		
		ereturn local user "SPREG_unml_eval`case'"
		
		ereturn local vce "oim"
		ereturn local chi2type "Wald"
		ereturn local technique `tech'
		ereturn local crittype "log likelihood"
		
		ereturn matrix gradient = `grad'
		ereturn matrix ilog = `iterlog'
		
		ereturn scalar N = `n'
		ereturn scalar k = `k'
		
		if (`case'==4) {
			ereturn scalar df_m = e(k)-4
		}
		else ereturn scalar df_m = e(k)-3
		
		ereturn scalar rank = `rank'
		ereturn scalar ll = `ll'
		
		if "`dlmat'" != "" ereturn local dlmat "`dlmat'"
		if "`elmat'" != "" ereturn local elmat "`elmat'"
				
		capture {
			qui test `iv'
			ereturn scalar chi2 = `r(chi2)'
			ereturn scalar p = chi2tail(e(df_m),e(chi2))
		}
		ereturn scalar iterations = `iters'
		ereturn scalar converged = `converged'
						
		ereturn local idvar "`id'"
		if "`iv'"!= "" ereturn local indeps "`iv'"
		ereturn local depvar "`varlist'"
		
		if "`constant'"=="" {
			ereturn local constant hasconstant
		}
		else ereturn local constant noconstant
		
		if "`robust'" != "" {
			ereturn local het heteroskedastic
		}
		else ereturn local het homoskedastic
		
		if (`case'==2) ereturn local model sar
		if (`case'==3) ereturn local model sare
		if (`case'==4) ereturn local model sarar
		
		if ("`log'"=="log" | "`log'"=="") di
		
		di as txt "Spatial autoregressive model " 		///
			"{col 51}Number of obs {col 67}= " 		///
			as res %8.0f e(N)
		
		local df = e(df_m)
		di as txt "(Maximum likelihood estimates)"		/// 
			"{col 51}Wald chi2(" as res "`df'" as txt")" 	///
			"{col 67}= " as res %8.7g e(chi2)
		di as txt "{col 51}Prob > chi2" "{col 67}= " as res %8.4f e(p)
		
		di
		
		ereturn display, level(`level')
	}
	
	ereturn local title "Spatial autoregressive model"
	ereturn local estimator "ml"
	ereturn local cmd "spreg"
	
end

program define GetNames, rclass
	
	syntax varname, case(real) [ iv(string) noCONStant ]
	
	//confirm integer number `case'
	
	local lbl
	foreach v of local iv {
		local lbl `lbl' `varlist':`v'
	}
	if "`constant'"=="" local lbl `lbl' `varlist':_cons
	
	if `case'==2 local lbl `lbl' lambda:_cons sigma2:_cons
	if `case'==3 local lbl `lbl' rho:_cons sigma2:_cons
	if `case'==4 local lbl `lbl' lambda:_cons rho:_cons sigma2:_cons
	
	return local lbl `lbl'
	
end

exit
