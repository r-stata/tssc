*! twostepweakiv 1.0.02 03Jan2019
*! author: Sun 
*! version: 1.0.02 03Jan2019
* Usage:
* twostepweakiv <estimator> <eqn>, <options>         = estimate equation as model=linear
* Version notes:
* 1.0.01	01Jan2018.	First complete working versionm largely based on Finlay-Magnusson-Schaffer's weakiv
* 1.0.02	03Jan2019.	Fix code for just-identified models and report distortion cutoff as well


program define twostepweakiv, eclass byable(recall) sortpreserve
	version 11.2
	local lversion 02.4.08
	local avarversion 01.0.04
	local ranktestversion 01.3.03
	

	checkversion_avar `avarversion'				//  Confirm avar is installed (necessary component).
	check_packages								//  Confirm ivreg2 and moremata are installed

	if replay() {								//  No model provided before ",", but possibly options
		syntax [, 								///
			VERsion ESTUSEwald(name)			///
			*									///
			]

		if "`version'" != "" {					//  Report program version number, then exit.
			di in gr "`lversion'"
			ereturn clear
			ereturn local version `lversion'
			exit
		}

		if	"`e(cmd)'"=="twostepweakiv" &				/// If previous e(cmd) was weakiv, and Wald model is NOT provided,
			"`estusewald'" == "" {				//  then replay last weakiv results with any new options, then exit.
			weakiv_replay `0'					//  Useful for tweaking graph options.
			exit								//  weakiv_replay syntax will catch illegals.
 		}

		if "`estusewald'" != "" {				//  Wald model is provided by user in estusewald(.) option,
			est restore `estusewald'			//  so make current and then proceed to weak-IV-robust estimation.
		}
												//  If Wald model is NOT provided then it must already be in memory
												//  as e(.) results, so proceed to weak-IV-robust estimation.
	}
	else {										//  Estimate model specified by user before ",".
		estimate_model `0'						//  Estimate model, then proceed to weak-IV-robust estimation.
	}	// end replay()

************************* ASSEMBLE MODEL AND OPTION SPECS *****************************************
* Model in memory is now main model for Wald tests etc.
* Weak IV-robust estimation inherits same characteristics (robust etc.).

* Save command line
	local cmdline "twostepweakiv `0'"

* esample = touse, except for xtabond2 where esample = original e(sample) in estimation
* use touse unless need to refer explicitly to original sample (e.g. when expanding factor vars)
	tempvar esample
	qui gen byte `esample'=e(sample)

* If data already preserved, OK; if preserve fails for other reasons, exit with error
	capture preserve
	if _rc > 0 & _rc~=621 {
di as err "Internal twostepweakiv error - preserve failed"
		exit 498
	}

* Create temp variables that will be changed by subroutines
	tempvar touse wvar clustvar1_t clustvar2_t
	qui gen byte `touse'=.
	qui gen double `wvar'=.
	qui gen long `clustvar1_t'=.
	qui gen long `clustvar2_t'=.

* Get weakiv options from command line
* Pass additional args to get_option_specs; bind needed in case of constructs like "l(1,2).abmi"
	gettoken first opts : 0 , parse(",") bind
	if "`first'"~="," {									//  args in macro `first' so run again
		gettoken first opts : opts , parse(",") bind	//  to get rid of comma
	}

* Get model specs from active model
* Clear any extraneous sreturn macros first
	sreturn clear
	get_model_specs,				 		/// Gets model specs from prev model. Catches some illegals.
		`opts'								/// Will need to pick up strong(.) from options and check vs. endo
		touse(`touse')						/// Applies to possibly-expanded current estimation sample
		esample(`esample')					/// Applies to original data estimation sample
		wvar(`wvar')						///
		clustvar1_t(`clustvar1_t')			///
		clustvar2_t(`clustvar2_t')

	local waldcmd		"`s(waldcmd)'"		//  command for original Wald (non-weak-ID-robust) estimation
	local model			"`s(model)'"
	local xtmodel		"`s(xtmodel)'"		//  empty if not estimated using panel data estimator
	local ivtitle		"`s(ivtitle)'"
	local depvar		"`s(depvar)'"
	local depvar_t		"`s(depvar_t)'"
	local inexog		"`s(inexog)'"
	local inexog_t		"`s(inexog_t)'"
	local tinexog		"`s(tinexog)'"
	local tinexog_t		"`s(tinexog_t)'"
	local endo			"`s(endo)'"
	local endo_t		"`s(endo_t)'"
	local wendo			"`s(wendo)'"
	local wendo_t		"`s(wendo_t)'"
	local sendo			"`s(sendo)'"
	local sendo_t		"`s(sendo_t)'"
	local csendo		"`s(csendo)'"
	local csendo_t		"`s(csendo_t)'"
	local pwendo		"`s(pwendo)'"		//  Projection-based inference. Don't need _t version.
	local pwendo2		"`s(pwendo2)'"
	local csendo		"`s(csendo)'"		//  Not in subset AR test(complement to set).  Don't need _t version.
	local exexog		"`s(exexog)'"		//  Empty if xtabond2
	local exexog_t		"`s(exexog_t)'"
	local gmminsts1		"`s(gmminsts1)'"	//  Specific to xtabond2
	local gmminsts2		"`s(gmminsts2)'"	//  Specific to xtabond2
	local ivinsts1		"`s(ivinsts1)'"		//  Specific to xtabond2
	local ivinsts2		"`s(ivinsts2)'"		//  Specific to xtabond2
	local noconstant	"`s(noconstant)'"	//  "noconstant" if no constant in original model specification
	local cons			"`s(cons)'"			//  0 if no constant in original model
	local nendog		"`s(nendog)'"		//  These counts will be overwritten after collinears etc. are removed
	local nsendog		"`s(nsendog)'"		//  #strongly identified endog; also boolean for strongly-IDed
	local nwendog		"`s(nwendog)'"		//  #weakly identified endog
	local npwendog		"`s(npwendog)'"		//  #wendo to construct project-based CIs; also boolean for projection method
	local ncsendog		"`s(ncsendog)'"		//  #wendo in complement to subset test; also boolean for subset test
	local nexexog		"`s(nexexog)'"
	local ninexog		"`s(ninexog)'"
	local ntinexog		"`s(ntinexog)'"
	local nexog			"`s(nexog)'"
	local small			"`s(small)'"
	local robust		"`s(robust)'"
	local cluster		"`s(cluster)'"		// = cluster( <varname> ) or cluster( <varlist> )
	local clustvar		"`s(clustvar)'"		//  ="clustvar1" if 1-way, ="clustvar1 clustvar2" if 2-way
	local clustvar1		"`s(clustvar1)'"	//  clustvar1_t already defined
	local clustvar2		"`s(clustvar2)'"	//  clustvar2_t already defined
	local bw			"`s(bw)'"
	local kernel		"`s(kernel)'"
	local llopt			"`s(llopt)'"
	local ulopt			"`s(ulopt)'"
	local asis			"`s(asis)'"
	local wtexp			"`s(wtexp)'"
	local wtype			"`s(wtype)'"
	local exp			"`s(exp)'"
	local wf			"`s(wf)'"
	local N				"`s(N)'"
	local N_clust		"`s(N_clust)'"			//  With 2-way clustering, is min(N_clust1,N_clust2)
	local N_clust1		"`s(N_clust1)'"
	local N_clust2		"`s(N_clust2)'"
	local N_g			"`s(N_g)'"				//  #panel groups
	local g_min			"`s(g_min)'"
	local g_max			"`s(g_max)'"
	local g_avg			"`s(g_avg)'"
	local singleton		"`s(singleton)'"		//  #panel singletons
	local dofminus		"`s(dofminus)'"			//  0 unless set by ivreg2
	local psd			"`s(psd)'"
	local vceopt		"`s(vceopt)'"
	local note1			"`s(note1)'"
	local note2			"`s(note2)'"
	local note3			"`s(note3)'"
	local iid			"`s(iid)'"

************************* Prep for transformations **************************************

* If TS or FV operators used, replace with temporary variables.
* Ensures that any transformation are applied to temporary vars.
* Must do at this level since if done in subroutines, temp vars would disappear after return
* Extension "_t" is list with temp vars.
* xtabond2 _t varlists are already transformed
* other _t lists are original varlists and will be overwritten

* Varlists come with full set of factor variables
* fvrevar will create a full set, so some can be all zeros,
* including the base variable.
* Call fvrevar 1 variable at a time so that repetitions lead to same tempvar.
* varlist will have full original set of variables
* varlist1 will have variables with collinear and zeroed-out vars dropped
* varlist_t will have varlist1 with tempvar equivalents
* nvarlist will have number of variables after collinears dropped

* Process depvar
	fvrevar `depvar_t', substitute
	local depvar_t	"`r(varlist)'"

* Process endogenous
	local templist
	forvalues i=1/`nendog' {
		local vn : word `i' of `endo_t'
		fvrevar `vn', substitute
		local templist "`templist' `r(varlist)'"
		}
	local endo_t : list clean templist			//  new varlist with tempvars
* Now remove collinears and zeroed-out factor variables etc.
	clean_varlist `wtexp' if `touse', vlist(`endo') vlist_t(`endo_t') `noconstant'
	local endo_c	"`r(vlist_c)'"				//  cleaned original vlist with collinears removed etc.
	local endo_t	"`r(vlist_c_t)'"			//  corresponding temp vars
	local nendog	=r(nvars_c)					//  update count

* Process excluded exogenous
	local templist
	forvalues i=1/`nexexog' {
		local vn : word `i' of `exexog_t'
		fvrevar `vn', substitute
		local templist "`templist' `r(varlist)'"
		}
	local exexog_t : list clean templist		// new varlist with tempvars
* Now remove collinears and zeroed-out factor variables etc.
	clean_varlist `wtexp' if `touse', vlist(`exexog') vlist_t(`exexog_t') `noconstant'
	local exexog_t	"`r(vlist_c_t)'"
	local nexexog	=r(nvars_c)					//  update count

* Process included exogenous
	local templist
	forvalues i=1/`ninexog' {
		local vn : word `i' of `inexog_t'
		fvrevar `vn', substitute
		local templist "`templist' `r(varlist)'"
		}
	local inexog_t : list clean templist		// new varlist exexog_t with tempvars

* Now remove collinears and zeroed-out factor variables etc.
	clean_varlist `wtexp' if `touse', vlist(`inexog') vlist_t(`inexog_t') `noconstant'
	local inexog_t	"`r(vlist_c_t)'"
	local ninexog	=r(nvars_c)+`cons'			//  update count

* Now overid will be correct
	local overid	= `nexexog' - `nendog'

* Finally, varlists that appear via options.  tempvars will already exist.
	local templist
	foreach var in `wendo_t' {
		fvrevar `var', substitute
		local templist "`templist' `r(varlist)'"
	}
	local wendo_t	: list clean templist

	local templist
	foreach var in `sendo_t' {
		fvrevar `var', substitute
		local templist "`templist' `r(varlist)'"
	}
	local sendo_t	: list clean templist

	local templist
	foreach var in `csendo_t' {
		fvrevar `var', substitute
		local templist "`templist' `r(varlist)'"
	}
	local csendo_t	: list clean templist

	local nwendog	: word count `wendo_t'		//  update count
	local nsendog	: word count `sendo_t'		//  update count
	local ncsendog	: word count `csendo_t'		//  update count
	local nexog		= `nexexog'+`ninexog'		//  update count

* If dropped from endo, drop from wendo and sendo as well
	local todrop	: list endo - endo_c
	local wendo		: list wendo - todrop
	local sendo		: list sendo - todrop
	local csendo	: list csendo - todrop

***************************** WALD MODEL **********************************************

* Will use later for Wald tests and delete unless eststorewald specified.
* Also used for grid options
	tempname waldmodel fullbeta var_fullbeta ebeta wbeta var_wbeta var1 var2

* For Wald tests and construction of stats and grids.
* Extract #nendog subvector of coeffs and corresp submatrix of VCV:

	local cnames		: colnames(e(b))				//  not colfullnames since ivtobit has eqn names we don't want
	local cnames		: subinstr local cnames "bn." ".", all		//  strip out base notation
	local cnames		: subinstr local cnames "b." ".", all
	local cnames		: subinstr local cnames "o." ".", all
	local cnames		: list clean cnames							//  list of all regressors

	foreach vn of local endo {
		local pos   : list posof `"`vn'"' in cnames
		local endopos "`endopos' `pos'"
	}
	local endopos	: list clean endopos							//  list of columns in which all endog coeffs appear
	foreach vn of local wendo {
		local pos   : list posof `"`vn'"' in cnames
		local wendopos "`wendopos' `pos'"
	}
	local wendopos	: list clean wendopos							//  list of columns in which weakly-IDed coeffs appear
* Assemble parameter vector and VCE for weakly-identified coeffs
* ebeta is full set of Wald estimates; wbeta is weakly-ID only
	mat `fullbeta' = e(b)											//  fullbeta has all coeffs including exogenous
	mat `var_fullbeta'=e(V)

	foreach cn of local endopos {									//  ebeta has all endog coeffs
		mat `ebeta' = nullmat(`ebeta') , `fullbeta'[1,`cn']
	}
	mat colnames `ebeta' = `endo'
	foreach cn of local wendopos {									//  wbeta has only weakly-ID coeffs
		mat `wbeta' = nullmat(`wbeta') , `fullbeta'[1,`cn']
		mat `var1' = nullmat(`var1') , `var_fullbeta'[1...,`cn']
	}
	foreach cn of local wendopos {
		mat `var2' = nullmat(`var2') \ `var1'[`cn',1...]
	}
	mat colnames `wbeta' = `wendo'
	mat `var_wbeta'=`var2'											//  and var_wbeta is the corresponding VCV

	_estimates hold `waldmodel'

****************************** GET OPTION SPECS *************************************
* Now all varlists and counts are complete, so get option specs

	get_option_specs,									///
						`opts'							/// 
						model(`model')					/// pass info on model along with options
						iid(`iid')						/// pass iid boolean along with options
						overid(`overid')				/// pass overid boolean along with options
						nendog(`nendog')				/// pass #endog info along with options
						nwendog(`nwendog')				///
						nsendog(`nsendog')				/// #strongly IDed endog; also boolean
						ncsendog(`ncsendog')			/// #not in subset test
						npwendog(`npwendog')			/// #weakd IDed for projection-based inference; also boolean
						waldcmd(`waldcmd')				/// estimator type
			 			wbeta(`wbeta')					///	row vector
						var_wbeta(`var_wbeta'))

	local level				"`r(level)'"
	local levellist			"`r(levellist)'"
	local ar_level			"`r(ar_level)'"
	local wald_level		"`r(wald_level)'"
	local clr_level			"`r(clr_level)'"
	local k_level			"`r(k_level)'"
	local gamma_level		"`r(gamma_level)'"
	local j_level			"`r(j_level)'"
	local kj_level			"`r(kj_level)'"
	local kjk_level			"`r(kjk_level)'"
	local kjj_level			"`r(kjj_level)'"
	local clrsims			"`r(clrsims)'"
	local testlist			"`r(testlist)'"					//  testlist for table
	local citestlist		"`r(citestlist)'"				//  testlist for CI table
	local ptestlist			"`r(ptestlist)'"				//  testlist for projection-based inference
	local gridcols			"`r(gridcols)'"
	local gridmult			"`r(gridmult)'"
	local gridmin			"`r(gridmin)'"
	local gridmax			"`r(gridmax)'"
	local gridpoints		"`r(gridpoints)'"
	local null				"`r(null)'"
	local wnull				"`r(wnull)'"
	local kwt				"`r(kwt)'"
	local lm				"`r(lm)'"						//  =0 or 1
	local cuepoint			"`r(cuepoint)'"					//  =0 or 1
	local cuestrong			"`r(cuestrong)'"				//  =0 or 1
	local ci				"`r(ci)'"						//  =0 or 1
	local usegrid			"`r(usegrid)'"					//  =0 or 1
	local closedform		"`r(closedform)'"				//  =0 or 1
	local testid			"`r(testid)'"					//  =0 or 1
	local gridlist			"`r(gridlist)'"
	local gridpoints		"`r(gridpoints)'"
	local exportmats		"`r(exportmats)'"
	local eststorewald		"`r(eststorewald)'"
	local estadd			=r(estadd)						//	=0 or 1
	local estaddname		"`r(estaddname)'"
	local graph				"`r(graph)'"
	local graphxrange		"`r(graphxrange)'"
	local graphopt			"`r(graphopt)'"
	local contouropt		"`r(contouropt)'"
	local surfaceopt		"`r(surfaceopt)'"
	local contouronly		"`r(contouronly)'"
	local surfaceonly		"`r(surfaceonly)'"
	local displaywald		"`r(displaywald)'"
	local forcerobust		"`r(forcerobust)'"				//  boolean
	//  end assembly of model and option specs

***************************** XT TRANSFORMS *************************************************
* Transform data (FE or FD) if required.  Data already preserved.
	if "`xtmodel'" == "fe" {

		capture xtset
		if _rc > 0 {
di as err "Fixed-effects estimation requires data to be -xtset-"
			exit 459
		}
		local ivar "`r(panelvar)'"
		local tvar "`r(timevar)'"

		tempvar T_i
		sort `ivar' `touse'
* Catch singletons.  Must use unweighted data
		qui by `ivar' `touse': gen long `T_i' = _N if _n==_N & `touse'
		qui replace `touse'=0 if `T_i'==1
		drop `T_i'

		qui {
			sort `ivar' `touse'
* Only iw and fw use weighted observation counts
			if "`weight'" == "iweight" | "`weight'" == "fweight" {
				by `ivar' `touse': gen long `T_i' = sum(`wvar') if `touse'
			}
			else {
				by `ivar' `touse': gen long `T_i' = _N if `touse'
			}
			by `ivar' `touse': replace  `T_i' = . if _n~=_N

* Demean. Create new vars as doubles (reusing existing non-double vars loses accuracy)
* Apply to TS temp vars if any so use _t list
			local allvars_t "`depvar_t' `inexog_t' `endo_t' `exexog_t'"
			foreach var of local allvars_t {
				tempvar `var'_m
* To get weighted means
				by `ivar' `touse' : gen double ``var'_m'=sum(`var'*`wvar')/sum(`wvar') if `touse'
				by `ivar' `touse' : replace    ``var'_m'=``var'_m'[_N] if `touse' & _n<_N
* This guarantees that the demeaned variables are doubles and have correct names
				by `ivar' `touse' : replace ``var'_m'=`var'-``var'_m'[_N] if `touse'
				drop `var'
				rename ``var'_m' `var'
			}
		}
* Restore xtset-ing of data before leaving transform block
		qui xtset `ivar' `tvar'
	}

	if "`xtmodel'" == "fd" {
* No transformation required!
* Handled by fvrevar above - varlists have D. operator in them.
* Code below is in case ivar or tvar are ever required.
		capture xtset
		if _rc > 0 {
di as err "Fixed-effects estimation requires data to be -xtset-"
			exit 459
		}
		local ivar "`r(panelvar)'"
		local tvar "`r(timevar)'"
	}

******************************* PARTIAL-OUT *************************************************
* Always partial out exogenous regressors in linear models.
* `npartial' is #vars partialled out; includes constant in count
* `partialcons' =0 if no constant partialled out, =1 if it was
* `ninexog' = 0 if inexog all partialled out, otherwise unchanged
* `cons' = 0 if inexog all partialled out, otherwise unchanged
* `noconstant' = "noconstant" if exexog all partialled out, otherwise unchanged
* `inexog' = original varlist; unchanged
* `inexog_t' = empty if all inexog partialled out, otherwise unchanged

	local npartial=0							//  Default
	local partialcons=0							//  Default
	
	if "`model'" == "linear" {

* Loop through variables to transform
* Use tempvars if any so that they are transformed
		tempname partial_resid
		foreach var of varlist `depvar_t' `endo_t' `exexog_t'  {
			qui regress `var' `inexog_t' if `touse' `wtexp', `noconstant'		//  `noconstant' here is from original model spec
			qui predict double `partial_resid' if `touse', resid
			qui replace `var' = `partial_resid'
			drop `partial_resid'
		}
* constant always partialled out
		local noconstant "noconstant"
		local partialcons	=`cons'
		local cons			=0
* update count of included exogenous
		local npartial		=`ninexog'
		local ninexog		=0
* inexog_t list now empty but original inexog list unchanged
		local inexog_t		""

	}	// end partial-out block

***************************** MISC PREPARATION ********************
* Small-sample adjustsment.  Includes #partialled-out vars.
	if "`small'"~="" & "`cluster'"=="" {
		local ssa=(`N'-`dofminus')/(`N'-(`nexexog'+`ninexog'+`npartial')-`dofminus')	//  iid, robust, ac or HAC
	}
	else if "`small'"~="" & "`cluster'"~="" {
		local ssa=(`N_clust')/(`N_clust'-1) *											/// cluster
			(`N'-1)/(`N'-(`nexexog'+`ninexog'+`npartial'))								//  no dofminus here
	}
	else {
		local ssa=1																		//  no small
	}

* Shared tempnames
	tempname rk ar_p ar_chi2 ar_df k_p k_chi2 k_df k_2sls lc_2sls lc_2sls_r j_p j_chi2 j_df kj_p ///
		clr_p clr_stat clr_df ar_r k_r j_r kj_dnr kj_r clr_r			///
		wald_p wald_chi2 wald_df wald_r
	tempname nullvec del_z pi_z var_del var_pidel_z var_pi_z bhat del_v
	tempname S S11 S12 S22 zz zzinv x2z xx zx xy x1x1 x2x2 x1x2 zx1 zx2 zy x1y x2y yy
	tempname sbeta cueinitbeta iv_sbeta0 pi2hat ecuebeta wcuebeta var_ecuebeta var_wcuebeta var3 // for cuepoint; var3 is used for variance estimates
	if "`waldcmd'" != "" & "`waldcmd'" != "cue" {
		tempname var_w`waldcmd'beta var_e`waldcmd'beta e`waldcmd'beta w`waldcmd'beta // for point estimates 
	}
	tempname F // F statistics
	tempname bhat pi_z1 pi_z2 var_pidel_z1 var_pidel_z2 var_pi_z11 var_pi_z12 var_pi_z22
	tempname syy see sxx sxy sxe syv sve svv AA
	tempname citable
	tempname nullvector wnullvector
	tempvar vhat vhat1 vhat2 uhat uhat1 uhat2 ehat 

* Misc
	local npd=0

	// tabulate the 1-alpha (k_level) quantile of chi2 with dg nendog - nsendog
	local invchi2_k_df = invchi2(`nendog'-`nsendog', `k_level'/100)
	// tabulate the 1-alpha quantile of chi2 with dg 1 for projection test (for each component)
	local invchi2_1_df = invchi2(1, `k_level'/100)

******************************** CUE point estimator/MD estimator if requested **************************
		mat `sbeta' = `ebeta' // in case ebeta gets used in get_strong_beta	
		mat `cueinitbeta' = `ebeta' // in case ebeta gets used in get_strong_beta						

		if ~`overid' & `cuepoint' {								//  if exactly-ID, CUE=LIML=IV
di as text "Exactly identified: CUE point estimates are the same as IV estimates..."
			mat `ecuebeta'	= `ebeta'
			mat `wcuebeta'	= `wbeta'
		}
		// Calculate point estimates and variance for specified estimator
	 if "`waldcmd'" == "2sls" {
di as text "Obtaining 2SLS point estimates..."
//point estimates should be identical to Wald, but VCE may be different (because we use robust VCE formula)
		computecrossprods, touse(`touse') wtexp(`wtexp') exexog(`exexog_t') wendo(`endo_t') depvar(`depvar_t')
			mat `zz'     = r(zz)
			mat `x1x1'   = r(x1x1)
			mat `zx1'    = r(zx1)
			mat `x1y'    = r(x1y)
			mat `zy'     = r(zy)
			mat `yy'     = r(yy)

		mat `wnullvector' = J(1,`nendog',0) // set to zero so iv_s_beta goes through
		get_strong_beta,							///
							iv				///  IV
							varflag			///
							nobs(`N')				///
							b0(`wnullvector')		///
							zz(`zz')				///
							x1x1(`x1x1')			///
							x1x2(`x1x1')			///
							x2x2(`x1x1')			///
							zx1(`zx1')				///
							zx2(`zx1')				///
							x1y(`x1y')				///
							x2y(`x1y')				///
							zy(`zy')				///
							yy(`yy')				///
							depvar(`depvar_t')		///
							wendo("")		/// now calculating 2sls estimates for all endo
							sendo(`endo_t')		///
							exexog(`exexog_t')		///
							touse(`touse')			///
							vceopt(`vceopt')		/// doesn't quite matter because of s_iv_beta doesn't need this
							wtexp(`wtexp')			///
							wvar(`wvar')			///
							wf(`wf')

		mat `sbeta'		= r(sbeta)
		mat `var_e2slsbeta'      = r(var_beta)

		mat colnames `var_e2slsbeta' = `endo'
		mat rownames `var_e2slsbeta' = `endo'
		foreach vn of local wendo {
			mat `var3' = nullmat(`var3'),`var_e2slsbeta'[1...,"`vn'"] // select the columns
		} // var3 is a temp name, var1 and var2 got used previously
		foreach vn of local wendo {
			mat `var_w2slsbeta' = nullmat(`var_w2slsbeta') \ `var3'["`vn'",1...] // select the rows
		}
		// Replace previous VCE estimator in Wald model (e.g. ivreg2) with MD 2SLS VCE estimator - just the variance is different
		mat `var_wbeta' = `var_w2slsbeta'
		
	} 
	else if  "`waldcmd'" != "" {
di as text "Obtaining `waldcmd' point estimates..."		
				get_strong_beta,							///
							`waldcmd'						/// 
							`varflag'				///
							nobs(`N')				///
							lm(`lm')				///
							sbeta(`sbeta')			/// 1st-step IV estimator for strong endog at specified null
							depvar(`depvar_t')		///
							wendo("")				///
							sendo(`endo_t')			///
							exexog(`exexog_t')		///
							touse(`touse')			///
							vceopt(`vceopt')		///
							wtexp(`wtexp')			///
							wvar(`wvar')			///
							wf(`wf')				///
							traceonoff("on") 
			mat `e`waldcmd'beta'=r(sbeta)							//  estimates for all endogenous - row vector
			mat colnames `e`waldcmd'beta' = `endo'
			foreach vn of local wendo {							//  estimates for weakly-ID only
				mat `w`waldcmd'beta' = nullmat(`w`waldcmd'beta') , `e`waldcmd'beta'[1,"`vn'"]
			}
			// Also obtain VCE for all parameters
			mat `var_e`waldcmd'beta'=r(var_beta)
			mat colnames `var_e`waldcmd'beta' = `endo'
			mat rownames `var_e`waldcmd'beta' = `endo'
			foreach vn of local wendo {
				mat `var3' = nullmat(`var3'),`var_e`waldcmd'beta'[1...,"`vn'"] // select the columns
			} // var3 is a temp name, var1 and var2 got used previously
			foreach vn of local wendo {
				mat `var_w`waldcmd'beta' = nullmat(`var_w`waldcmd'beta') \ `var3'["`vn'",1...] // select the rows
			}
				
			// Replace previous estimates in Wald model (i.e. ivreg2)
			mat `ebeta' = `e`waldcmd'beta'
			mat `wbeta' = `w`waldcmd'beta'
			mat `var_wbeta' = `var_w`waldcmd'beta'
	
		
	}
	if  "`waldcmd'" != "cue" & `cuepoint' & `overid' {
di as text "Obtaining CUE point estimates for cuepoint..."
					local varflag ""				// if just cuepoint, then don't calculate variance
						
				get_strong_beta,					///
							cue						/// 
							`varflag'				///
							nobs(`N')				///
							lm(`lm')				///
							sbeta(`cueinitbeta')			/// 1st-step IV estimator for strong endog at specified null
							depvar(`depvar_t')		///
							wendo("")				///
							sendo(`endo_t')			///
							exexog(`exexog_t')		///
							touse(`touse')			///
							vceopt(`vceopt')		///
							wtexp(`wtexp')			///
							wvar(`wvar')			///
							wf(`wf')				///
							traceonoff("on") 
								

			mat `ecuebeta'=r(sbeta)								//  CUE estimate for all endogenous - row vector
			mat colnames `ecuebeta' = `endo'
			foreach vn of local wendo {							//  CUE estimate for weakly-ID only
				mat `wcuebeta' = nullmat(`wcuebeta') , `ecuebeta'[1,"`vn'"]
			}
	}
	

	// end cuepoint/point estimates block
	

***************** PREPARE VECTOR OF NULLS INCLUDING PREP FOR WEAK/STRONG ************************CHANGE
* This section now calculates iv_sbeta0 for get_strong_beta (needs this input to pass into construct_citable)
	if "`wnull'"=="" {
		mat `wnullvector' = J(1,`nwendog',0)
		forvalues i=1/`nwendog' {
			local wnull "`wnull' 0"
		}
		local wnull : list clean wnull
	}
	else {
		foreach num in `wnull' {
			mat `wnullvector' = nullmat(`wnullvector') , `num'
		}
	}
	mat `nullvector' = `wnullvector'			//  null vector is weak nullvector
												//  followed by coeffs for strongly IDed (added later)
* Check that #nulls matches #weak endog
	if `nwendog' ~= colsof(`wnullvector') {
di as err "error: number of weakly endogenous (`nwendog') doesn't match number of hypothesized values (" colsof(`wnullvector') ")"
		exit 198
	}

* weak/strong estimation - need efficient estimator of strongly-identified coeffs under null.
* Currently implemented for linear models only so inexog and constant already partialled out.

	if `nsendog' > 0 {

* x1 is weakly identified (wendo), x2 is strongly identified (sendo)
		computecrossprods, touse(`touse') wtexp(`wtexp') exexog(`exexog_t') wendo(`wendo_t') other(`sendo_t') depvar(`depvar_t')
		mat `zz'     = r(zz)
		mat `x1x2'   = r(x1x2)
		mat `x1x1'   = r(x1x1)
		mat `x2x2'   = r(x2x2)
		mat `zx1'    = r(zx1)
		mat `zx2'    = r(zx2)
		mat `x1y'    = r(x1y)
		mat `x2y'    = r(x2y)
		mat `zy'     = r(zy)
		mat `yy'     = r(yy)

* Always need to use an iid method (IV), either for final strong beta or for initial value for non-iid strong beta
		get_strong_beta,							///
							iv				///  IV
							nobs(`N')				///
							b0(`wnullvector')		///
							zz(`zz')				///
							x1x1(`x1x1')			///
							x1x2(`x1x2')			///
							x2x2(`x2x2')			///
							zx1(`zx1')				///
							zx2(`zx2')				///
							x1y(`x1y')				///
							x2y(`x2y')				///
							zy(`zy')				///
							yy(`yy')				///
							depvar(`depvar_t')		///
							wendo(`wendo')		/// 
							sendo(`sendo')		///
							exexog(`exexog_t')		///
							touse(`touse')			///
							vceopt(`vceopt')		/// doesn't quite matter because of s_iv_beta doesn't need this
							wtexp(`wtexp')			///
							wvar(`wvar')			///
							wf(`wf')
							

		mat `sbeta'		= r(sbeta)
		mat `iv_sbeta0'	= r(iv_sbeta0)				//  IV beta for strongly-idenfified send at null=0 (used in grid search)
		// if b0=0, then sbeta=iv_sbeta0
		mat `pi2hat'	= r(pi2hat)					//  RF coeffs matrix (used in grid search)
/*
		if ~`iid' {										//
			get_strong_beta,							///
								`s2method'				/// md2s or cue
								lm(`lm')				///
								nobs(`N')				///
								b0(`wnullvector')		///
								sbeta(`sbeta')			/// 1st-step IV estimator for strong endog at specified null
								zz(`zz')				///
								x1x2(`x1x2')			///
								zx1(`zx1')				///
								zx2(`zx2')				///
								zy(`zy')				///
								depvar(`depvar_t')		///
								wendo(`wendo_t')		///
								sendo(`sendo_t')		///
								exexog(`exexog_t')		///
								touse(`touse')			///
								vceopt(`vceopt')		///
								wtexp(`wtexp')			///
								wvar(`wvar')			///
								wf(`wf')

			mat `sbeta' = r(sbeta)						//  new sbeta based on efficient GMM
		}
*/
		mat colnames `sbeta' = `sendo'
		mat `nullvector' = `wnullvector' , `sbeta'							//  append coeffs for strong to nullvector
	}

************************************ PREPARE VARIANCE COVARIANCE ESTIMATOR FOR DEL_Z AND PI_Z *****************************

	// `ncsendog' subset AR test; requires IID and linearity does not work anymore CHANGE
														
*** inexog and cons partialled out everywhere ***
		computematrices_robust,						///
			touse(`touse')							///
			wtexp(`wtexp')							///
			vceopt(`vceopt')						///
			depvar(`depvar_t')						///
			endo(`wendo_t' `sendo_t')				/// first weak, then strong (if any)
			exexog(`exexog_t')						///
			nendog(`nendog')						///
			nexexog(`nexexog')						///
			npartial(`npartial')					/// #inexog partialled-out
			nobs(`N')								///
			dofminus(`dofminus')					///
			ssa(`ssa')								/// small-sample adjustment
			lm(`lm')

		mat `del_z'			= r(del_z)
		mat `var_pi_z'		= r(var_pi_z)
		mat `zzinv'	=r(zzinv)	
		mat `pi_z'			= r(pi_z)
		mat `var_del'		= r(var_del)
		mat `var_pidel_z'	= r(var_pidel_z)
		
		tempname first i // pi_z and var_pi_z have already been declared as tempname in twostepweakiv shared tempnames
			mata: `pi_z'		=st_matrix("r(pi_z)")
			mata: `var_pi_z'	=st_matrix("r(var_pi_z)")

			mata: `first'		= J(`nendog',1,.)
			mata: for (`i'=1; `i'<=`nendog'; `i'++) `first'[`i',1] = `pi_z'[.,`i']' * invsym(`var_pi_z'[(`i'-1)*`nexexog'+1..(`i')*`nexexog',(`i'-1)*`nexexog'+1..(`i')*`nexexog'])* `pi_z'[.,`i']/`nexexog'
			// need to fit mata loop in one line
			mata: st_matrix("r(first)", `first')
			mata: mata drop `first' `i'
			mata: mata drop `pi_z' `var_pi_z'
			mat `F'			= r(first)




* The df are calculated to ereturn list. compute_pvals do not output these anymore to save space of citable. so just calculate them
	local wald_df	= `nendog' - `nsendog' - `ncsendog'
	local ar_df	=`nexexog' - `nsendog' - `ncsendog'
	local k_df	= `nendog' - `nsendog'
	local j_df	= `nexexog'-`nendog'
	local rk_df	= `nexexog' - `nendog' + 1

******************** Anderson/Kleibergen-Paap LM test of underid of Wald model *************

* Need ranktest installed
	if `testid' {
		capture ranktest, version
		local vernum "`r(version)'"
		if (_rc == 0) & ("`vernum'" >= "`ranktestversion'") {
			qui ranktest (`wendo_t' `sendo_t' `csendo_t') (`exexog_t') if `touse' `wtexp',		///
				partial(`inexog_t') fullrank `vceopt' nocons dofminus(`dofminus')
		}
		local idstat	=r(chi2)
		local idstat_df	=r(df)
		local idstat_p	=r(p)
* Just in case...
		if `idstat_df' ~= `rk_df' {
di as err "Warning: degrees of freedom for underidentification statistics differ"
di as err "         weakiv rk stat df=`rk_df'; ranktest id stat df=`idstat_df'
		}
	}

************************************ CONSTRUCT CONFIDENCE SETS *****************************

* Recursive approach to construct grid
	if `usegrid' {

		if `cuepoint' {
			local wgridbeta		"`wcuebeta'"
			local usecue		1								//  option to trigger inclusion of CUE beta in grid
		}
		else {
			local wgridbeta		"`wbeta'"
			local usecue		0
		}

		construct_grid, 				///
			gridlist(`gridlist')		///
			gridpoints(`gridpoints')	///
			gridmin(`gridmin')			///
			gridmax(`gridmax')			///
			gridmult(`gridmult')		///
			nwendog(`nwendog')			///
			wbeta(`wgridbeta')			///
			var_wbeta(`var_wbeta')		///
			wald_level(`wald_level')	///
			usecue(`usecue')

		local gridlist			"`r(gridlist)'"					//  list of gridpoints, dimensions separated by "|"
		local grid_descript		"`r(grid_descript)'"
		local points_descript	"`r(points_descript)'"
		local points			"`r(points)'"					//  total number of points in grid, or empty
		local gridpoints		"`r(gridpoints)'"				//  numlist of grid points in each dimension; overwrites default
		tempname citable										//  set local name at top level so will persist until program exit
														//  same name is used for Mata matrix
		construct_citable,				///
			citable(`citable')			///
			gridcols(`gridcols')		///
			iid(`iid')					///
			closedform(`closedform')	///
			clrsims(`clrsims')			///
			usegrid(`usegrid')			///
			depvar(`depvar_t')			///
			wendo(`wendo_t')			///
			sendo(`sendo_t')			///
			exexog(`exexog_t')			///
			inexog(`inexog_t')			///
			touse (`touse')				///
			wtexp(`wtexp')				///
			`noconstant'				///
			nexexog(`nexexog')			///
			nendog(`nendog')			///
			nwendog(`nwendog')			///
			nsendog(`nsendog')			///
			ncsendog(`ncsendog')		///
			alpha(`k_level')		/// for calculating distortion cutoff, we need alpha
			gamma(`gamma_level')		///
			invchi2_k_df(`invchi2_k_df')	///
			invchi2_1_df(`invchi2_1_df')	///
			overid(`overid')			///
			kwt(`kwt')					///
			nobs(`N')					///
			gridlist(`gridlist')		///
			points(`points')			///
			wbeta(`wbeta')				///
			var_wbeta(`var_wbeta')		///
			var_pi_z(`var_pi_z')		///
			zzinv(`zzinv')			///
			iv_sbeta0(`iv_sbeta0')		///
			pi2hat(`pi2hat')			///
			pi_z(`pi_z')				///
			var_del(`var_del')			///
			del_z(`del_z')				///
			del_v(`del_v')				///
			var_pidel_z(`var_pidel_z')	///
			syy(`syy')					///
			see(`see')					///
			sxy(`sxy')					///
			sve(`sve')					///
			sxx(`sxx')					///
			svv(`svv')					///
			lm(`lm')					///
			cuestrong(`cuestrong')		///
			nexog(`nexog')				///
			zz(`zz')					///
			x1x1(`x1x1')				///
			x1x2(`x1x2')				///
			x2x2(`x2x2')				///
			zx1(`zx1')					///
			zx2(`zx2')					///
			x1y(`x1y')					///
			x2y(`x2y')					///
			zy(`zy')					///
			yy(`yy')					///
			depvar_t(`depvar_t')		///
			wendo_t(`wendo_t')			///
			sendo_t(`sendo_t')			///
			sendo(`sendo')				/// needed for column names in citable
			exexog_t(`exexog_t')		///
			touse(`touse')				///
			vceopt(`vceopt')			///
			wtexp(`wtexp')				///
			wvar(`wvar')				///
			wf(`wf')					///
			forcerobust(`forcerobust')

		local npd					=max(`npd',r(npd))		//  promote to 1 if npd matrix ever encountered
		local citable_cnames		"`r(cnames)'"			//  aligns with columns of Mata matrix `citable'
		local gamma_hat = r(gamma_hat)			// distortion cutoff
		forvalues i=1/`nwendog' {		
			local gamma_hat`i' = r(gamma_hat`i')			// distortion cutoff for projection test
		}
* Summary:
* Mata matrix `citable' has full CI table (no size limit)
* Stata macro `citable_cnames' has column names

	}	//  end of block to construct CI table

	
	if `ci' & `nwendog'==1 {				//  default for single endog regressor is to construct CI

* has user specified grid or closed-form estimation of confidence sets? (closed-form estimation only for homoskedastic 2sls)
* code assumes all exexog have been partialled out
		if `closedform' {					//  closed form - iid, nsendog=0, non-subset only

			get_ci_closedform,				///
				testlist(`citestlist')		///
				ry1(`depvar_t')				///
				ry2(`wendo_t')				///
				rinst(`exexog_t')			///
				touse(`touse')				///
				wtexp(`wtexp')				///
				nexexog(`nexexog')			///
				ar_level(`ar_level')		///
				k_level(`k_level')			///
				clr_level(`clr_level')		///
				nobs(`N')					///
				ssa(`ssa')					///
				dofminus(`dofminus')

		}									//  end closed-form iid block
		else {								//  non-iid, #sendo>0, or force grid use

			get_ci_from_table,				///
				testlist(`citestlist')		///
				citable(`citable')			///
				cnames(`citable_cnames')	///
				ar_level(`ar_level')		///
				k_level(`k_level')			///
				j_level(`j_level')			///
				kj_level(`kj_level')		///
				clr_level(`clr_level')
		}

* Save CIs as local macros
		foreach testname in `citestlist' {
			local `testname'_cset "`r(`testname'_cset)'"
		}

* Also get and save Wald CI as local macro
		get_ci_from_vcv,				///
			wbeta(`wbeta')				///
			var_wbeta(`var_wbeta')		///
			wald_level(`wald_level')	///
			vnum(1)						//  default vnum is 1 but provide anyway
		local wald_cset	"`r(wald_cset)'"
				
	}	//  end construction of confidence interval

**************** PROJECTION-BASED INFERENCE ********************
* construct 1-D projection-based CIs
	if `npwendog' & `usegrid' {

		foreach vname of local pwendo {
		
			local vnum			: list posof "`vname'" in wendo
			local pwendo_nlist	"`vnum' `pwendo_nlist'"				//  in REVERSE order now; will sort before storing in e(.)

			tempname p`vnum'citable									//  set local name at top level so will persist until program exit
																//  name is used for Mata matrix

			construct_pcitable,						///
				vnum(`vnum')						///
				testlist(`ptestlist')				/// get projection-based tests from grid
				citable(`citable')					/// if wald is in ptestlist, test will be projection-based
				cnames(`citable_cnames')			///
				pcitable(`p`vnum'citable')			///
				points(`points')					///
				gridpoints(`gridpoints')			///
				ar_level(`ar_level')				///
				k_level(`k_level')					///
				j_level(`j_level')					///
				kj_level(`kj_level')				///
				clr_level(`clr_level')				///
				wald_level(`wald_level')

			local p`vnum'citable_cnames		"`r(cnames)'"

			get_ci_from_table,						///
				testlist(`ptestlist')				/// if wald is in ptestlist, CI will be projection-based
				citable(`p`vnum'citable')			/// pass the projection-based table for variable `vnum'
				cnames(`p`vnum'citable_cnames')		///
				hasrejections						//  projection-based tables are 1/0 rejection indicators
													//  so no need to provide test levels
			local p`vnum'_vname		"`vname'"
			foreach tname in `ptestlist' {			//  save all projection-based CIs constructed from table
				local p`vnum'_`tname'_cset	"`r(`tname'_cset)'"
			}

			
			* Also get and save Wald CI as local macro
					get_ci_from_vcv,				///
						wbeta(`wbeta')				///
						var_wbeta(`var_wbeta')		///
						wald_level(`wald_level')	///
						vnum(`vnum')			
					local p`vnum'_wald_cset	"`r(wald_cset)'"
			* use Wald's cset instead
	
				
		}
	}		//  end construction of projection-based CIs

* Summary:
* Mata matrices `p[#]citable' have CI rejection tables (no size limit)
* Stata macros `p[#]citable_cnames' have column names

* construct 2-D projection CIs
	if "`pwendo2'"~="" & `usegrid' {

		tempname pcitable2										//  set local name at top level so will persist until program exit
																//  name is used for Mata matrix
		tempname vnums

		tokenize `pwendo2'
		local vname1		"`1'"
		local vname2		"`2'"
		local vnum1			: list posof "`vname1'" in wendo
		local vnum2			: list posof "`vname2'" in wendo
		mat `vnums'			= `vnum1', `vnum2'					//  vector of variable numbers of wendo

		construct_pcitable2,						///
			vnums(`vnums')							///
			testlist(`ptestlist')					/// get projection-based tests from grid
			citable(`citable')						/// if wald is in ptestlist, CI will be projection-based
			cnames(`citable_cnames')				///
			pcitable(`pcitable2')					///
			points(`points')						///
			gridpoints(`gridpoints')				///
			ar_level(`ar_level')					///
			k_level(`k_level')						///
			j_level(`j_level')						///
			kj_level(`kj_level')					///
			clr_level(`clr_level')					///
			wald_level(`wald_level')

		local pcitable2_cnames		"`r(cnames)'"

	}		//  end prep for 2-D projection

* Summary:ing
* Mata matrix `pcitable2' has 2-D CI rejection table (no size limit)
* Stata macro `pcitable2_cnames' has column names

************************ RESTORE IF PRESERVED ***************************************

	capture restore

********************* OBTAIN ADDITIONAL INFO FROM WALD MODEL ************************

	if "`waldcmd'"=="xtabond2" {									//  need to store extra info for replay to work
		_estimates unhold `waldmodel'
		tempname X Y Z ideqt ivequation gmmequation
		foreach m in X Y Z ideqt ivequation gmmequation {
			mat ``m'' = e(`m')
		}
		if "`displaywald'"~="" | `estadd' | "`eststorewald'"~="" {	//  xtabond2 data matrices can be very large
			_estimates hold `waldmodel'								//  so avoid storing twice if possible
		}
	}

************************ DISPLAY/POST/GRAPH RESULTS *********************************
* `esample' is same as `touse', except with xtabond2 when `esample' = e(sample) from original estimation
	ereturn post , dep(`depvar') obs(`N') esample(`esample')

	ereturn scalar	endo_ct				=`nendog'		//  #all lendogenous
	ereturn scalar	wendo_ct			=`nwendog'		//  #weak endog, also used as flag for K=1 or K=2 case
	ereturn scalar	sendo_ct			=`nsendog'		//  #strong endog
	ereturn scalar	tinexog_ct			=`ntinexog'		//  #exogenous regressors included in tests
	ereturn scalar	exexog_ct			=`nexexog'		//  #excluded exogenous (IVs)
	ereturn local	cmd 				"twostepweakiv"
	ereturn local	waldcmd				"`waldcmd'"
	ereturn local	depvar				"`depvar'"
	ereturn local	endo				"`endo'"
	ereturn local	wendo				"`wendo'"
	ereturn local	sendo				"`sendo'"
	ereturn local	inexog				"`inexog'"
	ereturn local	tinexog				"`tinexog'"
	ereturn local	exexog				"`exexog'"		//  missing if xtabond2
	ereturn local	gmminsts1			"`gmminsts1'"	//  specific to xtabond2
	ereturn local	gmminsts2			"`gmminsts2'"	//  specific to xtabond2
	ereturn local	ivinsts1			"`ivinsts1'"	//  specific to xtabond2
	ereturn local	ivinsts2			"`ivinsts2'"	//  specific to xtabond2
* we don't test specific null anymore. So remove the null p-val and test stat. The level and df are reported only when used	
	ereturn scalar	wald_level			=`wald_level'
	ereturn scalar	wald_df				=`wald_df'

	ereturn scalar	ar_level			=`ar_level'
	ereturn scalar	ar_df				=`ar_df'


		//ereturn scalar	kjj_level		=`kjj_level'
		//ereturn scalar	kjk_level		=`kjk_level'
		//ereturn scalar	kj_level		=`kj_level'
		//ereturn scalar	kwt				=`kwt'
		
		//ereturn scalar	j_level			=`j_level'
		//ereturn scalar	j_df			=`j_df'

		ereturn scalar	k_level			=`k_level'
		ereturn scalar	k_df			=`k_df'

		ereturn scalar	gamma_level			=`gamma_level'
		ereturn scalar  gamma_hat			=`gamma_hat'

		//ereturn scalar	clr_level		=`clr_level'


	if `testid' {
		ereturn scalar	idstat_df		=`idstat_df'
		ereturn scalar	idstat_p		=`idstat_p'
		ereturn scalar	idstat			=`idstat'
	}
	ereturn scalar	rk_df				=`rk_df'

	ereturn scalar	testid				=`testid'
	ereturn scalar	N					=`N'
	ereturn local   robust				"`robust'"
	if "`clustvar2'"~="" {	
									//  save additional macros for 2-way clustering
		ereturn scalar	N_clust2		=`N_clust2'
		ereturn scalar	N_clust1		=`N_clust1'				//  with 2-way, N_clust=min(N_clust1, N_clust2)
		ereturn local	clustvar2		"`clustvar2'"
		ereturn local	clustvar1		"`clustvar1'"
	}
	if "`cluster'"~="" {	
		ereturn scalar	N_clust			=`N_clust'
		ereturn local	clustvar		"`clustvar'"			//  with 1-way, clustvar = "clustvar1"
		ereturn local   cluster			"cluster(`clustvar')"	//  with 2-way, clustvar = "clustvar1 clustvar2"
	}
	if "`xtmodel'"~="" {
		ereturn scalar singleton		=`singleton'
		ereturn scalar	g_avg			=`g_avg'
		ereturn scalar	g_max			=`g_max'
		ereturn scalar	g_min			=`g_min'
		ereturn scalar	N_g				=`N_g'
		ereturn local	xtmodel			"`xtmodel'"
	}
	if `ci' {
		ereturn local	wald_cset		"`wald_cset'"
		ereturn local	ar_cset			"`ar_cset'"
//		if `overid' {
			ereturn local	kj_cset		"`kj_cset'"
			ereturn local	j_cset		"`j_cset'"
			ereturn local	k_cset		"`k_cset'"
			ereturn local	k_2sls_cset	"`k_2sls_cset'"
			ereturn local	lc_2sls_cset	"`lc_2sls_cset'"
			ereturn local	lc_cset		"`lc_cset'"
			ereturn local	clr_cset	"`clr_cset'"
//		}
	}

	*ereturn local	testlist			"`testlist'" // redundant with citestlist
	ereturn local	citestlist			"`citestlist'"
	ereturn local	ptestlist			"`ptestlist'"
	ereturn scalar	clrsims				=`clrsims'
	ereturn scalar	closedform			=`closedform'
			

	if "`pwendo2'"~="" & `usegrid' {										//  save only if grid also constructed
		ereturn local pwendo2						"`pwendo2'"
	}		
	if `npwendog' & `usegrid' {												//  save only if grid also constructed
		foreach vnum of local pwendo_nlist {								//  in REVERSE order so stored in right order

			mata: st_numscalar("r(rows)",rows(`p`vnum'citable'))
			if r(rows) <= 32767 {											//  can be saved as e(matrix)
				mata: st_matrix("`p`vnum'citable'",`p`vnum'citable')
				mat colnames `p`vnum'citable'		= `p`vnum'citable_cnames'
				ereturn mat p`vnum'citable			= `p`vnum'citable'
			}
			mata: mata drop `p`vnum'citable'								//  no longer needed, drop

			ereturn local p`vnum'_wald_cset			"`p`vnum'_wald_cset'"
			ereturn local p`vnum'_ar_cset			"`p`vnum'_ar_cset'"
//			if `overid' {
				ereturn local p`vnum'_kj_cset			"`p`vnum'_kj_cset'"
				ereturn local p`vnum'_j_cset			"`p`vnum'_j_cset'"
				ereturn local p`vnum'_k_cset			"`p`vnum'_k_cset'"
				ereturn local p`vnum'_k_2sls_cset		"`p`vnum'_k_2sls_cset'"
				ereturn local p`vnum'_lc_2sls_cset		"`p`vnum'_lc_2sls_cset'"
				ereturn local p`vnum'_lc_cset		"`p`vnum'_lc_cset'"
				ereturn local p`vnum'_clr_cset			"`p`vnum'_clr_cset'"
//			}
			ereturn scalar gamma_hat_p`vnum' = `gamma_hat`vnum''		// distortion cutoff for projection test
		}
		ereturn local	pwendo			"`pwendo'"
		local			pwendo_nlist	: list sort pwendo_nlist			//  put in correct order before storing in e(.)
		ereturn local	pwendo_nlist	"`pwendo_nlist'"
		ereturn scalar	pwendo_ct		=`npwendog'							//  #wendo with projection-based CIs

	}
	else {
		ereturn scalar	pwendo_ct		=0									//  no grid, so #wendo with projection-based CIs = 0
	}
	if `ncsendog' {
		ereturn local	csendo			"`csendo'"
	}
	ereturn scalar	csendo_ct			=`ncsendog'				//  #endo NOT in subset set ("c"=complement)
	if `usegrid' {												//  don't return citable just yet - needed for graphs
		ereturn local	grid_descript		"`grid_descript'"
		ereturn local	points_descript		"`points_descript'"
		ereturn local	gridpoints			"`gridpoints'"
		ereturn scalar	points				=`points'
	}
	//if e(sendo_ct) { //  save strongly-identified beta at specified null (obsolete- no longer calculate beta at null
	//	ereturn matrix	sbeta			=`sbeta'
	//}

	if `cuepoint' {
		ereturn matrix	cuebeta			=`ecuebeta'
	}
	//if hitting an error msg below, coult be that ebeta is not returned because used in get_strong_beta"
	ereturn matrix	ebeta				=`ebeta'
	ereturn matrix	var_wbeta			=`var_wbeta'
	ereturn matrix	wbeta				=`wbeta'
	//if hitting an error msg below, could be that does not have F matrix calculated because did not call 2sls"
	ereturn matrix  F				=`F'
	ereturn scalar	overid				=`overid'
	//ereturn scalar	iid				=`iid'
	ereturn local	level				"`level'"
	ereturn local	levellist			"`levellist'"			//  level used for tests (if more than one level provided)
	ereturn local	ivtitle				"`ivtitle'"
	ereturn local	note3				"`note3'"
	ereturn local	note2				"`note2'"
	ereturn local	note1				"`note1'"
	ereturn local	model				"`model'"
	ereturn scalar	grid				=`usegrid'
	ereturn scalar	ci					=`ci'
	ereturn scalar	small				=("`small'"~="")
	ereturn scalar	npd					=`npd'
	//if `lm'	{
	//	ereturn local method			"lm"
	//}
	//else {
		ereturn local method			"md"
	//}
	
	if "`waldcmd'"=="xtabond2" {									//  need to store extra info for replay to work
		foreach m in X Y Z ideqt ivequation gmmequation {
			ereturn matrix `m' = ``m''
		}
	}

	if "`displaywald'"~="" {
		tempname weakiv_estimates
		_est hold `weakiv_estimates'
		_est unhold `waldmodel'
		`e(cmd)'
		_est hold `waldmodel'
		_est unhold `weakiv_estimates'
	}

	display_output

	if "`graph'" ~= "" {
		if e(wendo_ct)==1 {
			do_graphs,								///
				graph(`graph')						///
				citable(`citable')					/// Use Mata matrix `citable' and corresponding col names
				cnames(`citable_cnames')			///
				graphxrange(`graphxrange')			///
				graphopt(`graphopt')				///
				levellist(`levellist')
		}
		else if e(wendo_ct)==2 {
			do_graphs2,								///
				graph(`graph')						///
				citable(`citable')					/// Use Mata matrix `citable' and corresponding col names
				cnames(`citable_cnames')			///
				`contouronly'						///
				`surfaceonly'						///
				contouropt(`contouropt')			///
				surfaceopt(`surfaceopt')			///
				graphopt(`graphopt')				///
				levellist(`levellist')				///
				level(`level')						/// Default level
				arlevel(`ar_level')					///
				klevel(`k_level')					///
				jlevel(`j_level')					///
				kjlevel(`kj_level')					///
				clrlevel(`clr_level')				///
				waldlevel(`wald_level')
		}
		else if "`e(pwendo2)'"~="" {				//  projection-based inference
			do_graphs2,								///
				graph(`graph')						///
				citable(`pcitable2')				/// use Mata matrix pcitable2 and corresponding col names
				cnames(`pcitable2_cnames')			///
				hasrejections						/// table has 1/0 rejection indicators rather than p-vals
				contouronly							///
				contouropt(scatter `contouropt')	/// add scatter to contouropt
				surfaceopt(`surfaceopt')			///
				graphopt(`graphopt')				///
				levellist(`levellist')				///
				level(`level')						/// Default level
				arlevel(`ar_level')					///
				klevel(`k_level')					///
				jlevel(`j_level')					///
				kjlevel(`kj_level')					///
				clrlevel(`clr_level')				///
				waldlevel(`wald_level')
		}
	}
	
* Save grids used for graphing here in e(.) macros (wasteful of memory if done earlier)
	if `usegrid' {
		local maxrows	= 32767
		local blocksize	= 10000									//  if have to break up, size of each block
		mata: st_numscalar("r(rows)",rows(`citable'))
		if r(rows) <= `maxrows' {								//  can be saved as e(.) matrix
			tempname m
			mata: st_matrix("`m'",`citable')
			mat colnames `m'					= `citable_cnames'
			ereturn matrix	citable				= `m'
			ereturn scalar	citblocks			= 1
		}
		else {													//  break up and save as separate e(.) matrices
			local rowsleft					= r(rows)
			local citblock					= 0
			while `rowsleft' > 0 {
				local ++citblock
				tempname citable_`citblock'						//  temp name for Stata matrix holding block
				if `rowsleft' <= `blocksize' {
					mata: st_matrix("`citable'_`citblock'",`citable'[((`citblock'-1)*`blocksize'+1)::(rows(`citable')),.])
				}
				else {
					mata: st_matrix("`citable'_`citblock'",`citable'[((`citblock'-1)*`blocksize'+1)::(`citblock'*`blocksize'),.])
				}
				mat colnames `citable'_`citblock'	= `citable_cnames'
				ereturn matrix	citable_`citblock'	= `citable'_`citblock'
				local rowsleft						= `rowsleft' - `blocksize'		
			}		
			ereturn scalar	citblocks			= `citblock'
		}
		mata: mata drop `citable'							//  no longer needed, drop
	}
	else {
			ereturn scalar	citblocks			= 0			// so that it always exists; =0 if no grid used
	}
	if `usegrid' & "`e(pwendo2)'"~="" {
		mata: st_numscalar("r(rows)",rows(`pcitable2'))
		if r(rows) <= 32767 {								//  can be saved as e(matrix)
			tempname m
			mata: st_matrix("`m'",`pcitable2')
			mat colnames `m'					= `pcitable2_cnames'
			ereturn mat p`vnum1'`vnum2'citable	= `m'
		}
		mata: mata drop `pcitable2'							//  no longer needed, drop
	}

	if `estadd' {											//  Add weakiv macros to Wald model
		weakiv_estadd,										///
			waldmodel(`waldmodel')							/// waldmodel = temp name of Wald model
			estaddname(`estaddname')						//  estaddname = prefix for saving macros etc. in e()
						 									//  Exit with Wald + estadded results in memory
	}
	else {													//  No estadd.  Just weakiv results will be left in memory
		if "`eststorewald'"~=""						{		//  Store Wald model as per user option...
			tempname weakiv_estimates
			_estimates hold `weakiv_estimates'
			_estimates unhold `waldmodel'
			est store `eststorewald',						///
				title("weakiv model used for Wald tests and CIs")
			_estimates unhold `weakiv_estimates'			//  ...and leave weakiv results as current
			ereturn local waldmodel "`eststorewald'"
		}
	}

	// end main estimation block

end		// end weakiv

********************************************************************************

program define checkversion_avar
	version 11.2
	args avarversion

* Check that -avar- is installed
		capture avar, version
		if _rc != 0 {
di as err "Error: must have avar version `avarversion' or greater installed"
di as err "To install, from within Stata type " _c
di in smcl "{stata ssc install avar :ssc install avar}"
			exit 601
		}
		local vernum "`r(version)'"
		if ("`vernum'" < "`avarversion'") | ("`vernum'" > "09.9.99") {
di as err "Error: must have avar version `avarversion' or greater installed"
di as err "Currently installed version is `vernum'"
di as err "To update, from within Stata type " _c
di in smcl "{stata ssc install avar, replace :ssc install avar, replace}"
			exit 601
		}

end

program define check_packages

* Check that -ivreg2- is installed
		capture ivreg2, version 
		if _rc != 0 {
di as err "Error: must have ivreg2 installed"
di as err "To install, from within Stata type " _c
di in smcl "{stata ssc install ivreg2 :ssc install ivreg2}"
			exit 601
		}
* Check that -moremata- library is installed
		capture mata: mata which mm_quantile()
		if _rc != 0 {
di as err "Error: must have moremata installed"
di as err "To install, from within Stata type " _c
di in smcl "{stata ssc install moremata :ssc install moremata}"
			exit 601
		}

end

*********************************************************************************

program define weakiv_estadd, eclass
	version 11.2
	syntax [,												///
				waldmodel(name)								/// waldmodel is temp name
				estaddname(name)							/// estaddname is prefix for saving macros
			]

* Temporarily store macros to add to estimation results

	local overid "`e(overid)'"
	local allstats "wald ar"
	if `overid' {
		local allstats "`allstats' k j kj clr"
	}
	foreach stat of local allstats {
		local `stat'_cset "`e(`stat'_cset)'"					//  All have confidence sets
		local `stat'_p "`e(`stat'_p)'"							//  All have p-values
		local `stat'_chi2 "`e(`stat'_chi2)'"					//  No chi2 for KJ
		local `stat'_df "`e(`stat'_df)'"						//  No df for KJ and CLR
		local `stat'_stat "`e(`stat'_stat)'"					//  "stat", not "chi2", for CLR
	}

* Will need to recreate and repost e(sample)
	tempvar esample
	qui gen byte `esample'=e(sample)

* Make Wald model the current set of estimates
	_estimates unhold `waldmodel'
* Repost e(sample)
	ereturn repost , esample(`esample')

* Add the weakiv stats, prefixed by `estaddname'
	foreach stat of local allstats {
		ereturn local `estaddname'`stat'_cset "``stat'_cset'"		//  All have confidence sets
		ereturn scalar `estaddname'`stat'_p =``stat'_p'				//  All have p-values
		if "`stat'"~="kj" & "`stat'"~="clr" {						//  No chi2 and df for KJ and CLR
			ereturn scalar `estaddname'`stat'_chi2 =``stat'_chi2'
			ereturn scalar `estaddname'`stat'_df =``stat'_df'
		}
		if "`stat'"=="clr" {										//  "stat" but not "chi2" for CLR
			ereturn scalar `estaddname'`stat'_stat =``stat'_stat'
		}
	}
																//  Exit with Wald model as current
																//  estimation with weakiv results added
end

program define do_graphs
	version 11.2
	syntax [,												///
				citable(name)								///
				cnames(string)								///
				graph(string)								///
				graphxrange(numlist ascending min=2 max=2)	///
				graphopt(string asis)						///			
				levellist(numlist min=0 max=3)				///
			]

* Graph list can be mixed or upper case; convert to lower case
		local graph = lower("`graph'")
* "all" means all 6 or all 2
		local all : list posof "all" in graph
		if `all'>0 {
			if e(overid) & ~e(csendo_ct) {
				local graph "ar clr k j kj wald"
			}
			else {
				local graph "ar wald"
			}
		}

		if e(overid) & ~e(csendo_ct) {
			local legalgraphs "wald ar k j kj clr"
		}
		else {
			local legalgraphs "wald ar"
		}
		local illegalgraphs : list graph - legalgraphs
		local nillegalgraphs : list sizeof illegalgraphs
		if `nillegalgraphs' > 0 {
			di as err "illegal option: graph(`illegalgraphs')
			exit 198
		}

		mata: st_numscalar("r(rows)",rows(`citable'))
		local rows = r(rows)
* To be graphed, stats need to be variables. Check to see if #obs in current dataset is sufficient.
		if `rows' > _N {
			preserve
			qui set obs `rows'
			local pflag 1
		}
		else {
			local pflag 0
		}
		
		tempvar xvar
		tempvar ar_rf k_rf clr_rf j_rf wald_rf kj_rf
		qui gen `xvar'		= .
		qui gen `ar_rf'		= .
		qui gen `k_rf'		= .
		qui gen `clr_rf'	= .
		qui gen `j_rf'		= .
		qui gen `kj_rf'		= .
		qui gen `wald_rf'	= .
		label var `xvar'    "H0: beta=x"
		label var `ar_rf'   "AR"
		label var `k_rf'   	"K"
		label var `clr_rf'  "CLR"
		label var `j_rf'    "J"
		label var `kj_rf'	"K-J"
		label var `wald_rf' "Wald"

		mata: st_store( (1,rows(`citable')) , "`xvar'" , `citable'[.,1] ) 	//  populate Stata x-axis variable with nulls
																			//  null is in col 1

		foreach stat of local graph {										//  populate Stata rejection frequency variables
																			//  using CI table in Mata
			local testcol		: list posof "`stat'_p" in cnames			//  get right col of CI matrix
			mata: st_store( (1,rows(`citable')) , "``stat'_rf'" , 1 :- `citable'[.,`testcol'] )
		}

		foreach stat of local graph {
			local allstats "`allstats' ``stat'_rf'"
			local msymbolarg "`msymbolarg' none"
			local connectarg "`connectarg' l"
			if "`stat'"=="wald" {
				local lcoloropt "`lcoloropt' gray"
				}
			if "`stat'"=="ar" {
				local lcoloropt "`lcoloropt' red"
				}
			if "`stat'"=="clr" {
				local lcoloropt "`lcoloropt' green"
				}
			if "`stat'"=="k" {
				local lcoloropt "`lcoloropt' blue"
				}
			if "`stat'"=="kj" {
				local lcoloropt "`lcoloropt' orange"
				}
			if "`stat'"=="j" {
				local lcoloropt "`lcoloropt' maroon"
				}
		}
		if "`graphxrange'"~="" {
			tokenize `graphxrange'
			local xrange = "& `xvar' >= `1' & `xvar' <= `2'"
		}

* If level not provided, use level used in table of output
		if "`levellist'"=="" {
			local levellist "`e(levellist)'"
		}
		foreach levpct of numlist `levellist' {
			local lev = `levpct'/100
			local yline "`yline' `lev'"
		}
		scatter `allstats' `xvar' if _n<`rows' `xrange',		///
			ytitle("Rejection probability = 1-pval")			///
			yline(`yline', lcolor(black) lpattern(shortdash))	///
			yline(0, lc(black))									///
			ylabel(0(.1)1)										///
			msymbol(`msymbolarg')								///
			connect(`connectarg')								///
			lcolor(`lcoloropt')									///
			`graphopt'

* In case we had to increase the number of obs to accommodate gridpoints > _N
		if `pflag' {
			restore
		}

end

program define do_graphs2
	version 11.2
	syntax [,												///
				citable(name)								///
				cnames(string)								///
				hasrejections								/// says whether table has p-values or 1/0 rejection indicators
				graph(string)								///
				contouronly									///
				surfaceonly									///
				contouropt(string asis)						///
				surfaceopt(string asis)						///
				graphopt(string asis)						///
				levellist(numlist min=0 max=3)				///
				level(numlist min=1 max=1)					/// Default test level
				arlevel(numlist min=1 max=1)				///
				klevel(numlist min=1 max=1)					///
				jlevel(numlist min=1 max=1)					///
				kjlevel(numlist min=1 max=1)				///
				clrlevel(numlist min=1 max=1)				///
				waldlevel(numlist min=1 max=1)				///
			]

		local hasrejections		=("`hasrejections'"~="")													//  Convert to boolean
		local contour			=( ("`contouronly'"=="contouronly") | ("`contouronly'`surfaceonly'"=="") )
		local surface			=( ("`surfaceonly'"=="surfaceonly") | ("`contouronly'`surfaceonly'"=="") )

* Contour plot type: contourshade (default), contourline or scatter
* Code sets macro contourshade=1 if default (using contour graph command), =0 if contourline (using contourline graph command)
* and removes contourline or contourshade from list of contour options
		local contourline	: list posof "contourline" in contouropt
		local contourshade	: list posof "contourshade" in contouropt
		local scatter		: list posof "scatter" in contouropt
		if		(`contourline' & `contourshade')				///
			|	(`contourline' & `scatter')						///
			|	(`scatter' & `contourshade')					///
			{
di as err "error - must specify at most one type of contour plot (contourline, contourshade, scatter)"
			exit 198
		}
		if ~ (`contourline' | `contourshade' | `scatter') {
			local contourshade	=1								//  default is contourshade
		}
		local tstring "contourline contourshade scatter"		//  and remove names from contour options
		local contouropt	:	list contouropt - tstring

* Check software for K=2 graphing
* Stata version 12 or greater required for contour	
* surface by Adrian Mander required for surface

		if `contourline' | `contourshade' {
			if c(stata_version)<12 {
di as err "error - must have Stata version 12 or later for contourline or contourshade graph of confidence set"
di as err "Use -surfaceonly- option to skip contour plot or -contouropt(scatter)- option"
			exit 601
			}
		}
		if `surface' {
			capture which surface
			if _rc~=0 {
di as err "error - must have -surface- (Mander 2005) installed for 3-D plot of rejection probabilities"
di as err "To install, " in smcl "{stata ssc install surface :ssc install surface}" _c
di as err " or use -contouronly- option to skip surface plot"
			exit 601
			}
		}
		
* Graph list can be mixed or upper case; convert to lower case
		local graph = lower("`graph'")
* "all" means all 6 or all 2
		local all : list posof "all" in graph
		if `all'>0 {
			if e(overid) & ~e(csendo_ct) {
				local graph "ar clr k j kj wald"
			}
			else {
				local graph "ar wald"
			}
		}

		if e(overid) & ~e(csendo_ct) {
			local legalgraphs "wald ar clr k j kj"
		}
		else {
			local legalgraphs "wald ar"
		}
		local illegalgraphs : list graph - legalgraphs
		local nillegalgraphs : list sizeof illegalgraphs
		if `nillegalgraphs' > 0 {
			di as err "illegal or unavailable graph: `illegalgraphs'"
			exit 198
		}

		mata: st_numscalar("r(rows)",rows(`citable'))
		local rows = r(rows)
		
* To be graphed, stats need to be variables. Check to see if #obs in current dataset is sufficient.
		qui desc, short
		if `rows' > r(N) {
			preserve
			qui set obs `rows'
			local pflag 1
		}
		else {
			local pflag 0
		}

		tempvar xvar yvar
		tempvar ar_rf k_rf clr_rf j_rf wald_rf kj_rf
		tempvar ar_r  k_r  clr_r  j_r  wald_r  kj_r

* grid axis variables
		qui gen `xvar'		= .
		qui gen `yvar'		= .
		label var `xvar'    "H0: beta1=x (beta2=y)"
		label var `yvar'	"H0: beta2=y (beta1=x)"
		
		qui gen `ar_rf'		= .
		qui gen `k_rf'		= .
		qui gen `clr_rf'	= .
		qui gen `j_rf'		= .
		qui gen `kj_rf'		= .
		qui gen `wald_rf'	= .
		label var `ar_rf'   "AR"
		label var `k_rf'   	"K"
		label var `clr_rf'  "CLR"
		label var `j_rf'    "J"
		label var `kj_rf'	"K-J"
		label var `wald_rf' "Wald"
* need rejection boolean for scatterplot
		qui gen `ar_r'		= .
		qui gen `k_r'		= .
		qui gen `clr_r'		= .
		qui gen `j_r'		= .
		qui gen `kj_r'		= .
		qui gen `wald_r'	= .
		label var `ar_r'   "AR"
		label var `k_r'   	"K"
		label var `clr_r'  "CLR"
		label var `j_r'    "J"
		label var `kj_r'	"K-J"
		label var `wald_r' "Wald"

		mata: st_store( (1,rows(`citable')) , "`xvar'" , `citable'[.,1] ) 	//  populate Stata x-axis variable with nulls
		mata: st_store( (1,rows(`citable')) , "`yvar'" , `citable'[.,2] ) 	//  populate Stata y-axis variable with nulls

* z variable is either rejection freq = 1-pval or 1/0 rejection indicator.
* 1/0 rejection indicator works with/needed for scatter-type graph only.
* if rejection indicators provided, need to create z vars with 1/0 rej indicators.
* If p-values provided and rej freq needed, need to create z vars with 1-pvals.
* If p-values provided and rejections needed, need to create 1/0 rejection variables.

		if `hasrejections' {													//  (projection-based) CI table comes with 1/0 rejection vars
		
			foreach stat of local graph {										//  populate Stata rejection frequency variables
																				//  using CI table in Mata
				local testcol		: list posof "`stat'_r" in cnames			//  get right col of CI matrix
				mata: st_store( (1,rows(`citable')) , "``stat'_r'" , `citable'[.,`testcol'] )
			}
		}
		else if `scatter' {														//  CI table has p-vals, create 1/0 rejection indicators
																				//  AND 1-p rejection frequencies (for surface if called)

			foreach stat of local graph {

				local testcol		: list posof "`stat'_p" in cnames			//  get right col of CI matrix
				mata: st_store( (1,rows(`citable')) , "``stat'_r'" , ((`citable'[.,`testcol']) :< (1 :- ``stat'level'/100 )) )
				mata: st_store( (1,rows(`citable')) , "``stat'_rf'" , (1 :- `citable'[.,`testcol']) )
			}

		}
		else {																	//  CI table has p-vals, create 1-p rejection frequencies

			foreach stat of local graph {

				local testcol		: list posof "`stat'_p" in cnames			//  get right col of CI matrix
				mata: st_store( (1,rows(`citable')) , "``stat'_rf'" , (1 :- `citable'[.,`testcol']) )
				
			}
		
		}

* twoway contour fails when called on Stata temporary variables, so must create own temps
		tempname x y z
		capture drop weakiv`x'
		qui gen weakiv`x'=`xvar'
		capture drop weakiv`y'
		qui gen weakiv`y'=`yvar'
		capture drop weakiv`z'
		qui gen weakiv`z'=.
		capture drop weakiv`z'_r
		qui gen weakiv`z'_r=.

* Get variable labels for x and y from # of null
		tokenize `cnames'
* x-axis variable
		local vnumx				"`1'"
		local vnumx				: subinstr local vnumx "null" ""
		local wendox			: word `vnumx' of `e(wendo)'
		_ms_parse_parts `wendox'						//  in case of TS operators etc.
		local wendox			"`r(name)'"
		local vlabx				: variable label `wendox'
		if "`vlabx'"~="" {
			label var weakiv`x'		"beta: `vlabx'"
		}
		else {
			label var weakiv`x'		"beta: `wendox'"
		}
* y-axis variable
		local vnumy				"`2'"
		local vnumy				: subinstr local vnumy "null" ""
		local wendoy			: word `vnumy' of `e(wendo)'
		_ms_parse_parts `wendoy'						//  in case of TS operators etc.
		local wendoy			"`r(name)'"
		local vlaby				: variable label `wendoy'
		if "`vlaby'"~="" {
			label var weakiv`y'		"beta: `vlaby'"
		}
		else {
			label var weakiv`y'		"beta: `wendoy'"
		}
*z-axis
		label var weakiv`z'		"Rejection prob. = 1-pval"

		if "`levellist'"=="" {							//  if not provided as argument,
			local levellist "`e(levellist)'"			//  default is levels saved with estimation
		}
		numlist "`levellist'", descending				//  put in descending order
		foreach stat in ar k j kj clr wald {			//  loop through stats
			if "``stat'level'"=="`level'"				/// if stat level = default level
					& ~`scatter' {						//  and not a scatter plot
				local `stat'level	"`levellist'"		//  then use full list of default levels as contours
			}
		}

		foreach stat of local graph {

			qui replace weakiv`z'	=``stat'_rf'
			qui replace weakiv`z'_r	=``stat'_r'
			tempname graphc graphs graph_`stat'
		
			local level_ct : word count ``stat'level'		//  Can be a single level or up to 3
			tokenize ``stat'level'
			if `level_ct'==1 {
				if `contourline' {
					local ccoloropt "red"
				}
				else {
					local ccoloropt "gs5"
				}
				local ccut1 = `1'/100
				local ccutsopt "`ccut1'"
			}
			else if `level_ct'==2 {
				if `contourline' {
					local ccoloropt "dkgreen red"
				}
				else {
					local ccoloropt "gs5 gs9"
				}
				local ccut1 = `1'/100
				local ccut2 = `2'/100
				local ccutsopt "`ccut1' `ccut2'"
			}
			else {
				if `contourline' {
					local ccoloropt "blue dkgreen red"
				}
				else {
					local ccoloropt "gs5 gs9 gs12"
				}
				local ccut1 = `1'/100
				local ccut2 = `2'/100
				local ccut3 = `3'/100
				local ccutsopt "`ccut1' `ccut2' `ccut3'"
			}

			if `level_ct'==1 {
				local plegendopt "plegend(off)"			// 	only show legend if more than one level (contourline)
				local clegendopt "clegend(off)"			// 	only show legend if more than one level (contour)
				local ctitle "`1'% Confidence set"		//  include % in graph title if only one contour
			}
			else {
				local ctitle "Confidence sets"
			}

			if `contourline' {
				graph twoway contourline weakiv`z' weakiv`y' weakiv`x'		///
					if _n<`rows',											///
					title("`ctitle'")										///
					ccuts("`ccutsopt'")										///
					colorlines												///
					ccolor(`ccoloropt')										///
					name(`graphc', replace)									///
					nodraw													///
					`contouropt'
			}
			if `contourshade' {
				graph twoway contour weakiv`z' weakiv`y' weakiv`x'			///
					if _n<`rows',											///
					title("`ctitle'")										///
					ccuts("`ccutsopt'") 									///
					crule(linear) scolor(gs5) ecolor(white)					/// 	so that area above last confidence level is white
					zlabel(1 `ccutsopt' 0)									/// 	to guarantee that label goes from 0 to 1
					name(`graphc', replace)									///
					nodraw													///
					`clegendopt'											///
					`contouropt'
			}
			if `scatter' {
				graph twoway												///
					(scatter weakiv`y' weakiv`x' if weakiv`z'_r==0,			///
						 msymbol(s))										///		interior of confidence set
					(scatter weakiv`y' weakiv`x' if weakiv`z'_r==1,			///
						 mcolor(none))										///		plotted so that axes cover full range of x and y values
					,														///
					legend(off)												///
					title("`ctitle'")										///
					name(`graphc', replace)									///
					nodraw													///
					`contouropt'
			}
			if `surface' {
				surface weakiv`x' weakiv`y' weakiv`z',						///		surface 1.05 does NOT support -if-
					title("Rejection surface")								///
					name(`graphs', replace) nodraw							///
					zlabel(0 0.25 0.5 0.75 1)								///
					`surfaceopt'
			}
			local gtitle = upper("`stat'")
			if `contour' & `surface' {
				graph combine `graphc' `graphs',							///
					title(`gtitle')											///
					rows(1)													///
					name(`graph_`stat'', replace) nodraw
			}
			else if `contour' {
				graph combine `graphc',										///
					title(`gtitle')											///
					name(`graph_`stat'', replace) nodraw				
			}
			else if `surface' {
				graph combine `graphs',										///
					title(`gtitle')											///
					name(`graph_`stat'', replace) nodraw				
			}
			else {				//  shouldn't reach this point
di as err "weakiv graph error"
				exit 198
			}
			local combineall "`combineall' `graph_`stat''"
		}
		graph combine `combineall',										///
				cols(1)													///
				`graphopt'
				
		capture drop weakiv`x'
		capture drop weakiv`y'
		capture drop weakiv`z'
		capture drop weakiv`z'_r

* In case we had to increase the number of obs to accommodate gridpoints > _N
		if `pflag' {
			restore
		}

end


program define display_output
	version 11.2

* print combined test and confidence set results
* test tnames
	local name_clr		: di "{txt}{ralign 7:{helpb twostepweakiv##CLR:CLR}}"
	local name_ar		: di "{txt}{ralign 7:{helpb twostepweakiv##AR:AR}}"
	local name_k		: di "{txt}{ralign 7:{helpb twostepweakiv##K:K}}"
	local name_k_2sls	: di "{txt}{ralign 7:{helpb twostepweakiv##K_2sls:K_2sls}}"
	local name_lc_2sls	: di "{txt}{ralign 7:{helpb twostepweakiv##LC_2sls:LC_2sls}}"
	local name_lc		: di "{txt}{ralign 7:{helpb twostepweakiv##LC:LC}}"
	local name_j		: di "{txt}{ralign 7:{helpb twostepweakiv##J:J}}"
	local name_kj		: di "{txt}{ralign 7:{helpb twostepweakiv##K-J:K-J}}"
	local name_wald		: di "{txt}{ralign 7:{helpb twostepweakiv##Wald:Wald}}"
* test levels
	local level_clr		: di %2.0f e(clr_level) "%"
	local level_ar		: di %2.0f e(ar_level) "%"
	local level_k		: di %2.0f e(k_level) "%"
	local level_k_2sls		: di %2.0f e(k_level) "%"
	local level_lc_2sls	: di %2.0f e(k_level) "%"
	local level_lc		: di %2.0f e(k_level) "%"
	local level_j		: di %2.0f e(j_level) "%"
	local level_kj		: di %2.0f e(kj_level) "% (" %2.0f e(kjk_level) "%," %2.0f e(kjj_level) "%)"
	local level_wald	: di %2.0f e(wald_level) "%"

* CI text (full confidence sets table)

	foreach testname in clr ar k k_2sls lc_2sls lc j kj wald {
	
		local cset		"`e(`testname'_cset)'"
		local csetlen	: length local cset
		if `csetlen' <= 56 {
* Fits so center it in a line of 22 chars (78-22=56 = what's left from default of 78)
			local ci_`testname'		: di " {center 15:`level_`testname''}{res}{lalign 22:`e(`testname'_cset)'}"
		}
		else {
* Doesn't fit so right-align it on the next line
			local ci_`testname'		: di " {center 15:`level_`testname''}{break}{res}{ralign 78:`e(`testname'_cset)'}"
		}
	}
* Override above since (*) always fits
	if e(closedform) {
		local ci_kj		: di " {c |}{center 15:`level_kj'}{res}{center 22:{helpb twostepweakiv##closedform:(*)}}"
		local ci_j		: di " {c |}{center 15:`level_j'}{res}{center 22:{helpb twostepweakiv##closedform:(*)}}"
	}

* print
* title of output including any additional text
	if "`e(xtmodel)'"=="fe" {
		local modeltext "(fixed effects)"
	}
	if "`e(xtmodel)'"=="fd" {
		local modeltext "(first differences)"
	}
	di
//if "`e(citestlist)'" != "" & e(wendo_ct) == 1 {

	if e(ci) {
		di as txt "{p}{helpb twostepweakiv##interpretation:Weak instrument robust tests and confidence sets for `e(ivtitle)' `modeltext'}{p_end}"
		if "`e(citestlist)'" != "" {
			di as txt "{p}Confidence sets based on `e(citestlist)' tests are shown below.{p_end}"
		}
	} 
	if "`e(citestlist)'" != "" & e(wendo_ct) > 1 {
		di as txt "{p}{helpb twostepweakiv##interpretation:Weak instrument robust tests for `e(ivtitle)'}{p_end}"
		di as txt "{p}Full confidence sets based on `e(citestlist)' tests are stored in e(citable).{p_end}"
	}
	if "`e(citestlist)'" == "" & e(pwendo_ct) > 0&e(pwendo_ct)!= .& "`e(ptestlist)'" != "" {
		di as txt "{p}{helpb twostepweakiv##interpretation:Weak instrument robust tests for `e(ivtitle)'}{p_end}"
		di as txt "{p}Marginal confidence sets based on `e(ptestlist)' tests using projection methods are shown below.{p_end}"
	}

	if e(sendo_ct) {
		di as text "{p 0 4}Assumed strongly identified: `e(sendo)'{p_end}"
	}
	if e(csendo_ct) {
		di as text "{p 0 4}Also endogenous: `e(csendo)'.  Test is {helpb twostepweakiv##SSAR:subset-AR}.{p_end}"
	}
	if e(tinexog_ct) {
		di as text "{p 0 4}Regressors assumed exogenous: `e(tinexog)'{p_end}"
	}

	if e(ci) {
	* header
		di as txt "{hline 8}{c TT}{hline 33}" _c
		di as txt "{hline 37}" _c
		di
		di as txt "{ralign 7:Test} {c |}" _c
		di as txt " {center 15:Conf. level}{lalign 22:{helpb twostepweakiv##cset:Conf. Set}}" _c
		di
		di as txt "{hline 8}{c +}{hline 33}" _c
		di as txt "{hline 37}" _c
		di
	* weak-ID stats
		foreach testname in `e(citestlist)' {
			di "`name_`testname'' {c |}" _c
			di "`ci_`testname''" _c
			di
		}
	* separating line
		di as txt "{hline 8}{c +}{hline 33}" _c
		di as txt "{hline 37}" _c
		di	
	* wald
		di "`name_wald' {c |}" _c
		di "`ci_wald'" _c
		di
	* last separating line
		di as txt "{hline 8}{c BT}{hline 33}" _c
		di as txt "{hline 37}" _c
		di
	}

* footer information
	tempname ecuebeta
	mat `ecuebeta'=e(cuebeta)
	if `ecuebeta'[1,1] ~= . {								//  Display CUE beta
		if ~e(overid) {
			local cue	"IV (exactly-identified)"
		}
	//	else if e(iid) {
	//		local cue	"LIML"
	//	}
	//	else if e(method)=="lm" {
	//		local cue	"CUE"
	//	}
		else {
			local cue	"CUE-MD"
		}
		di as txt "{p}`cue' point estimate(s) for weakly-identified regressor(s):{p_end}"
		local vnames	"`e(wendo)'"
		foreach vn of local vnames {
			di %12s "`vn'" _col(15) %9.0g `ecuebeta'[1,colnumb(`ecuebeta',"`vn'")]
		}
	}

	if e(grid) {
		if e(wendo_ct)==1 {
			local pointstext "`e(points)'"
		}
		else {
			local pointstext "(`e(points_descript)')"
		}
		di as txt "{p}Confidence sets (if calculated) based on `pointstext' points in `e(grid_descript)'.{p_end}"
	}
	else if e(overid) & ~e(csendo_ct) & e(ci) {
		di as txt "{p}{helpb twostepweakiv##closedform:(*)}J/K-J conf. sets {helpb twostepweakiv##closedform:unavailable with closed-form estimation}.{p_end}"				
	}
	if e(clrsims)>0 {
		di as txt "{p}CLR distribution and p-values obtained by simulation (`e(clrsims)' draws).{p_end}"
	}
	if e(grid) & strpos("`e(citestlist)'", "lc") {
		di as text "{p}LC test gamma_min is" %5.0g e(gamma_level) "%; distortion cutoff is " %5.0f e(gamma_hat) "%  based on the given grid, obtained by 10^6 simulation draws.{p_end}"

	}
	local Ntext "`e(N)'"
	di as text "{p}Number of obs N  = `Ntext'."
	if "`e(xtmodel)'"~="" {
		di as text " Number of groups = " e(N_g) "; avg obs per group = " %3.1f e(g_avg) "."
		if e(singleton)>0 & e(singleton)<. {
			di as text "Warning - singleton groups detected.  `e(singleton)' observation(s) not used."
		}
	}
	di "{p_end}"
	if "`e(method)'"=="md" & "`e(model)'"=="linear" {
		di as txt "{p}Method = {helpb twostepweakiv##method:minimum distance/Wald}."
	}
	else if "`e(method)'"=="md" | "`e(method)'"=="lm" { // Now forcing it to display MD
		di as txt "{p}Method = {helpb twostepweakiv##method:minimum distance (MD)}."
	}
	else {
		di as txt "{p}Method = {helpb twostepweakiv##method:lagrange multiplier (LM)}."
	}
	if e(k_chi2)<. & strpos("`e(citestlist)'","kj") {
		di as text " Weight on K in K-J test = " %5.3f e(kwt) "."
	}
	di as txt "{p_end}"
	di as txt "{p}`e(note1)' `e(note2)' `e(note3)'"
	di as txt "{p_end}"
	di as txt "{p}Wald confidence set is based on `e(waldcmd)' estimates and is not robust to weak instruments.{p_end}"
	if e(npd) {
		di in red "{p}Some matrices are not positive definite, so reported tests should be treated with caution.{p_end}"
	}
	
	if e(testid) {					//  tests of underidentification to display
		di
		di "{helpb twostepweakiv##underid:Tests of underidentification:}"
		local rank=`e(endo_ct)'-`e(tinexog_ct)'
		di as res "H0: rank(E(zi'xi))=" `rank'-1 "     Ha: rank(E(zi'xi))=" `rank' " (full rank)"
		di as text "Rank test for weak-identification-robust estimation:"
		di as text "  chi2(" as res e(rk_df) as text ") = " _col(12) as res %6.2f e(rk) _col(25) as text "p-value = " _col(35) as res %5.4f e(rk_p)
		di as text "Rank test for Wald model:"
		di as text "  chi2(" as res e(idstat_df) as text ") = " _col(12) as res %6.2f e(idstat) _col(25) as text "p-value = " _col(35) as res %5.4f e(idstat_p)
	}
	
	
	if e(pwendo_ct)!= .& e(pwendo_ct)>0 {				//  projection-based CIs to display
		di
		di "{helpb twostepweakiv##project:Projection-based inference:}"

		local pwendo_nlist	"`e(pwendo_nlist)'"
		local wendo			"`e(wendo)'"
		local ptestlist		"`e(ptestlist)'"

		foreach vnum of local pwendo_nlist {
			local vname		: word `vnum' of `wendo'
			di as text "Variable: `vname'"
			di
			di as txt "{ralign 7:Test}{center 20:Conf. level}{lalign 22:{helpb twostepweakiv##cset:Confidence Set}}"
			di as txt "{hline 71}"
			foreach testname in `ptestlist' {
				if "`e(p`vnum'_`testname'_cset)'"~="" {
					di "`name_`testname''{center 20:`level_`testname''}{res}{lalign 22:`e(p`vnum'_`testname'_cset)'}"
				}
			}
			di as txt "{hline 71}"
			di "{ralign 7:{helpb twostepweakiv##Wald:Wald}}{center 20:`level_wald'}{res}{lalign 22:`e(p`vnum'_wald_cset)'}"
			di as txt "{hline 71}"
			di as txt "{p} Wald confidence set for the parameter of interest is based on `e(waldcmd)' point estimate and its standard error, rather than grid search.{p_end}"
			di as text "{p}LC test gamma_min is " ///
				%5.0f e(gamma_level) "%; distortion cutoff is " %5.0f e(gamma_hat_p`vnum') "% based on the given grid, obtained by 10^6 simulation draws.{p_end}"
			di
		}

	}

end

program define estimate_model, eclass
	version 11.2
			syntax anything(everything) [if] [in] [fw aw pw iw] [,		///
			null(numlist) kwt(real 0) NOCI								/// weakiv options stripped out...
			usegrid grid(string) gridlist(string)						///
			gridmult(real 0) GRIDLIMits(numlist ascending min=2 max=2)	///
			gridmin(numlist missingok) gridmax(numlist missingok)		///
			gridpoints(numlist missingok)								///
			grid1(numlist ascending) grid2(numlist ascending)			/// legacy options
			POINTS1(integer 0) POINTS2(integer 0)						/// legacy options
			GRIDLIMITS1(numlist ascending min=2 max=2)					/// legacy options
			GRIDLIMITS2(numlist ascending min=2 max=2)					/// legacy options
			testlist(string)					/// list of tests for full vector - to be taken out
			ptestlist(string)					/// list of tests for one endogenous variable using projection method
			citestlist(string)					/// list of tests for full vector
			LEVELlist(numlist min=0 max=3)								///
			arlevel(numlist min=1 max=1)								///
			jlevel(numlist min=1 max=1)									///
			kjlevel(numlist min=1 max=2)								///
			waldlevel(numlist min=1 max=1)								/// illegal option - capture it
			klevel(numlist min=1 max=1)									/// illegal option - capture it
			clrlevel(numlist min=1 max=1)								/// illegal option - capture it
			gammalevel(numlist min=1 max=1)								///
			lm md														///
			cuepoint													///
			strong(varlist fv ts) cuestrong								///
			project(string)												/// string since must accept _all
			project2(varlist fv ts min=2 max=2)							///
			clrsims(integer -1)										///
			subset(varlist fv ts)										///
			testexog(varlist fv ts)										///
			testid														///
			EQxtabond2(string)											/// weakiv option specific to xtabond2
			ESTSTOREwald(name) DISPLAYwald ESTADD1 ESTADD2(name)		///
			forcerobust													///
			retmat ci lmwt(numlist max=1 >0 <1) exportmats				/// <= legacy options from rivtest
			graph(string) graphxrange(numlist ascending min=2 max=2)	///
			graphopt(string asis)										///
			contouropt(string asis) surfaceopt(string asis)				///
			CONTOURonly SURFACEonly										///
			*															///	...so that "*" = macro `options'
			]															//   has only estimation options in it

* Clean command line of extraneous weight [] and option ,
	if "`weight'"~="" {
		local wtexp "[`weight'`exp']"								//  so if no weights, empty rather than "[]"
	}
	if "`options'"~="" {
		local optexp ", `options'"									//  note comma
	}
	else {															//  note comma
		local optexp ","
	}

	tokenize `"`anything'"'											//  need quotes since main command could include commas,
																	//  e.g., in lag ranges such as l(1,2).abmi
	local cmd `1'
* Verify estimation command: only these are allowed/parsed
	local legalcmd	"ivregress ivreg2 ivreg2h xtivreg xtivreg2 ivprobit ivtobit xtabond2"
* Verify estimator if no command is specified
	local legalestimator "2sls liml md2s cue"
	local legal_cmd		: list cmd in legalcmd
	local legal_estimator   : list cmd in legalestimator
	if `legal_estimator' {
		di as text "Estimating model using `cmd' estimator ..."
	}
	else {
di as err "error - unsupported estimator `cmd'"
		error 301
	}

* Some commands support versionoption
	local vercmd	"ivreg2 xtivreg2 ivreg2h xtabond2"
	local legal		: list cmd in vercmd
	if `legal' {
		cap `cmd', version
		local vernum "`e(version)'"
	}

	if "`cmd'" == "ivreg2" {											//  exploit ivreg2 nooutput option; means
 																		//  warning messages will be reported
		local optexp	: subinstr local optexp "nooutput" ""			//  remove it in case it's already there
		`anything' `if' `in' `wtexp' `optexp' nooutput					//  and now force use
	}
	else if `legal_estimator' {
		local anything = subinword("`anything'","`cmd'","ivreg2",1) // still need to use ivreg2 for parsing and initial beta
		local optexp	: subinstr local optexp "nooutput" ""			//  remove it in case it's already there
		`anything' `if' `in' `wtexp' `optexp' nooutput					//  and now force use
		ereturn local cmd "`cmd'" // manually overwrite/pass on the cmd for get_model_specs
	}
	else if "`cmd'" == "xtivreg2" & ("`vernum'" >= "01.0.14") {			//  xtivreg2 ver 01.0.14 or greater
		local optexp	: subinstr local optexp "nooutput" ""			//  also supports nooutput option
		`anything' `if' `in' `wtexp' `optexp' nooutput
	}
	else if "`cmd'" == "ivreg2h" & ("`vernum'" >= "01.1.00") {			//  ivreg2h ver 01.1.00 or greater
		local optexp	: subinstr local optexp "nooutput" ""			//  also supports nooutput option
		`anything' `if' `in' `wtexp' `optexp' nooutput gen(, replace)	//  ivreg2h requires generated IVs to be left behind
	}
	else if "`cmd'" == "ivreg2h" {
		local optexp	: subinstr local optexp "nooutput" ""
		qui `anything' `if' `in' `wtexp' `optexp' gen(, replace)		//  ivreg2h requires generated IVs to be left behind
	}
	else if "`cmd'" ~= "xtabond2" {			//  all other estimation commands except xtabond2 
		qui `anything' `if' `in' `wtexp' `optexp'			//  more informative error messages with qui than cap
	}
	else if "`cmd'" == "xtabond2" {						//  xtabond2 requires special treatment

		if c(matafavor)~="speed" {
di as err "error - weakiv support for xtabond2 requires matafavor to be set for speed"
di as err "        to do this type " in smcl "{stata mata mata set matafavor speed : mata mata set matafavor speed}"
			error 198
		}

		local svmat : list posof "svmat" in options						//  svmat needed to save matrices
		if `svmat'==0 {
			local optexp "`optexp' svmat"
		}

		cap `anything' `if' `in' `wtexp' `optexp'						//  xtabond2 error messages don't go through with qui so use cap
		if _rc > 0 {													//  estimation failed
di as err "error - estimation by weakiv/`cmd' failed."
di as err "to diagnose, try estimating by `cmd' and then use weakiv as a postestimation command"
			exit _rc
		}

	}	// end xtabond2 specials

end // end of estimate_model

program define get_option_specs, rclass
	version 11.2
			syntax [anything(everything)] [if] [in] [fw aw pw iw] [,			/// <= estimation specs aren't used
			null(numlist) NOCI													/// weakiv options start here
			usegrid grid(string)												///
			gridlist(string)													///
			gridmult(real 0)													///
			gridmin(numlist missingok) gridmax(numlist missingok)				///
			gridpoints(numlist missingok)										///
			grid(numlist ascending)												/// legacy options
			grid1(numlist ascending) grid2(numlist ascending)					/// legacy options
			points(integer 0) POINTS1(integer 0) POINTS2(integer 0)				/// legacy options
			GRIDLIMits(numlist ascending min=2 max=2)							/// legacy options
			GRIDLIMITS1(numlist ascending min=2 max=2)							/// legacy options
			GRIDLIMITS2(numlist ascending min=2 max=2)							/// legacy options
			testlist(string)					/// list of tests for full vector - to be taken out
			ptestlist(string)					/// list of tests for one endogenous variable using projection method
			citestlist(string)					/// list of tests for full vector
			level(numlist min=1 max=1)				/// confidence level
			gammalevel(numlist min=1 max=1)				/// distortion level
			kwt(real 0)															///
			lm md																///
			cuepoint															///
			strong(string) cuestrong											///
			subset(string)														///
			testexog(string)													///
			testid																///
			project(string)														///
			project2(string)													///
			clrsims(integer -1)									///
			exportmats															///
			ESTSTOREwald(name) DISPLAYwald ESTUSEwald(name)						///
			ESTADD1 ESTADD2(name)												///
			graph(string) graphxrange(numlist ascending min=2 max=2)			///
			graphopt(string asis)												///
			contouropt(string asis) surfaceopt(string asis)						///
			CONTOURonly SURFACEonly												///
			forcerobust															///
			model(string)														/// <= starting here, additional arguments related to options
			iid(integer 0) overid(integer 0)									///
			nendog(integer 0) nwendog(integer 0) nsendog(integer 0)				///
			ncsendog(integer 0) npwendog(integer 0)								///
			waldcmd(string) wbeta(name) var_wbeta(name)											///
			retmat ci lmwt(numlist max=1 >0 <1)									/// <= legacy options from rivtest
			*																	///
			]

	if `nendog' == 0 {
di as err "error - model must specify at least one endogenous regressor"
		exit 198
	}

* Underidentification can arise with xtabond2 via eq(.) option
	if `overid'<0 {
di as err "error - equation not identified; #excluded exog must be >= #endog"
		exit 198
	}

	if `nwendog'==0 {
di as err "syntax error - no weakly-identified coefficients specified"
		exit 198
	}

	if "`graph'"~="" & `nwendog' > 2 & "`project2'"=="" {
di as res "warning - graph option valid only for 1 or 2 weakly-identified coeffs, or"
di as res "          for 2-variable projection-based inference; graph option ignored"
		local graph	""
	}


* LM vs MD indicated by `lm' macro. `lm'=="lm" => LM, `lm'=="" => MD.
* Check legality
	if ("`lm'"=="lm") & ("`md'" == "md") {
di as err "incompatible options - lm and md"
		exit 198
	}
* Set default: LM for linear models, MD for others
	if "`lm'`md'"=="" {
		if "`model'"=="linear" {
			local lm "lm"
		}
	}
* lm currently allowed only with linear models
	if ("`lm'"=="lm") & ("`model'" ~= "linear") {						//  LM (Kleibergen 2002, 2005) valid only for linear IV
di as err "illegal option - lm method supported only for linear IV models"
		exit 198
	}

* strongly-id endog currently allowed only with linear models
	if (`nsendog'>0) & ("`model'" ~= "linear") {
di as err "illegal option - strong(.) option supported only for linear IV models"
		exit 198
	}

* subset AR currently allowed only with linear iid models
	if `ncsendog' & ( ~`iid' | ("`model'" ~= "linear")) {
di as err "illegal option - subset(.) option supported only for linear iid IV models"
		exit 198
	}

* strong and subset options incompatible
	if `nsendog' & `ncsendog' {
di as err "syntax error - incompatible options strong(.) and subset(.)"
		exit 198
	}

* CUE option allowed only with linear models
	if ("`cuepoint'"~="") & ("`model'" ~= "linear") {
di as err "illegal option - cuepoint option supported only for linear IV models"
		exit 198
	}

******* Test levels ************
* Default level is system-determined at 95%, gamma is set to 5%
* level and gammalevel may be supplied by the user, but need to check legality
* LC weights a_min is calculated for the following range.
	if "`level'" == "" {
		local level = 95
	} 
	else if inlist(`level', 99,95,90) == 0 {
di as text "weight for LC test is not pre-tabulated for this confidence level - need to simulate it and can take a while" // alpha_level not in a_min.csv
		local level = `level'
	}
	else {
		local level = `level'
	}

	if "`gammalevel'" == "" {
		local gamma_level = 5 
	}
	else if	inlist(`gammalevel', 1,2,5,10,15,20) == 0 {
di as text "weight for LC test is not pre-tabulated for this gamma - need to simulate it and can take a while" // gamma_level not in a_min.csv
		local gamma_level = `gammalevel' 
	}
	else {
		local gamma_level = `gammalevel'
	}
	

* AR, J, K, CLR and Wald test levels are the default test level - all are tests of parameter only
* Capture if attempted to set separately
	local ar_level		"`level'"
	local j_level		"`level'"
	local k_level		"`level'"
	local clr_level		"`level'"
	local wald_level	"`level'"
	if "`arlevel'`jlevel'`klevel'`clrlevel'`waldlevel'" ~= "" {
di as err "illegal option: test level for AR, J, K, CLR and Wald cannot be set separately"
di as err "use -level(.)- option to set test level for these tests"
		exit 198
	}

	tokenize `kjlevel'
	local kjlevelinput : list sizeof kjlevel
	if `kjlevelinput'==0 {								//  No list of levels provided
		local kj_level	"`level'"						//  so default level used for total test
		if `kwt'==0 {									//  No kwt provided so use default=0.8
			local kwt = 0.8
		}
		local kjk_level = 100 * (1 - (1 - sqrt(1-4*`kwt'*(1-`kwt')*(1-`kj_level'/100)))/(2*(1-`kwt')))
		local kjj_level = 100 * (1 - (1 - sqrt(1-4*`kwt'*(1-`kwt')*(1-`kj_level'/100)))/(2*`kwt'))
	}
	else if `kjlevelinput'==1 {							//  Separate total kj level provided
		local kj_level	"`1'"
		if `kwt'==0 {									//  No kwt provided so use default=0.8
			local kwt = 0.8
		}
		local kjk_level = 100 * (1 - (1 - sqrt(1-4*`kwt'*(1-`kwt')*(1-`kj_level'/100)))/(2*(1-`kwt')))
		local kjj_level = 100 * (1 - (1 - sqrt(1-4*`kwt'*(1-`kwt')*(1-`kj_level'/100)))/(2*`kwt'))
	}
	else {												//  2 arguments to kjlevel(.) provided, k and j levels
		local kj_level = `1'*`2'/100					//  KJ level = K level * J level
		local kjk_level "`1'"
		local kjj_level "`2'"
		if `kwt'>0 {									//  Check incompatible options specifed
di as err "incompatible options: kjlevel(.) and kwt(.)"
		exit 198
		}
		local kwt = (100-`kjk_level')/(200-`kjk_level'-`kjj_level')
	}
*******************************************

* Convert to boolean
	local usegrid		=("`usegrid'"=="usegrid")
	local forcerobust	=("`forcerobust'"=="forcerobust")



* Default: CIs reported for K=1 case
	local ci			=(`nwendog'==1)
* ... unless overridden by noci option
	if "`noci'"=="noci" {
		local ci		=0
	}

* Various options trigger usegrid.
	if ("`gridlist'`gridpoints'`gridmin'`gridmax'`grid'`gridlimits'`gridlimits1'`gridlimits2'" ~= "") {
		local usegrid	=1												//  string/numlist grid options trigger grid
	}
	if `gridmult' | `points' | `points1' | `points2' {					//  numerical grid options trigger grid
		local usegrid	=1												//  (works b/c these options default to 0)
	}
	if ("`graph'" ~= "") {
		local usegrid	=1												//  graphs always require grid
	}
	if `npwendog' {														//  projection-based-inference always requires grid
		local usegrid	=1
	}
	if ("`project2'" ~= "") {											//  projection-based-inference always requires grid
		local usegrid	=1
	}
	if `ci' & ( ~`iid' | `forcerobust' ) {								//  robust code for CIs requires grid
		local usegrid	=1
	}
	if `ci' & `ncsendog' {												//  subset CIs require grid
		local usegrid	=1
	}
	if `ci' & `nsendog' {												//  CIs with weak/strong endog require grid
		local usegrid	=1
	}
	if `ci' & ("`model'" ~= "linear") {									//  use grid for CI if ivprobit or ivtobit
		local usegrid	=1
	}


* closedform code for CIs uses Mikusheva-Poi method rather than grid search
* works for iid linear models with #wendog=1, no strong and not subset-AR
* overridden if usegrid is already indicated
	local closedform	=(~`usegrid' & "`model'"=="linear" & `iid' & `nwendog'==1 & ~`nsendog' & ~`ncsendog')
	
* Since we do not perform point hypothesis test, we require the user to specify usegrid (if not using closedform).
	if `usegrid' == 0 & `closedform' == 0 {
di as err "Please specify usegrid or other grid options to calculate confidence intervals and sets."
di as err "If you have  more than one weak endogenous variables, either specify project() to calculate marginal confidence sets (recommended),"
di as err "or specify citestlist() to calculate full confidence sets."
	exit 198
	}
* Check if test lists provided by the users are legal
	if "`citestlist'" != "" {
		local citestlist 	= lower("`citestlist'")+" " // add a space for parsing list
		local legalcitest 	"clr k_2sls k lc_2sls lc j kj ar"
		local legal_citest 	: list citestlist in legalcitest
		if !`legal_citest' {
di as err "citestlist option error - can construct CI based on CLR, K, K_2sls, LC, LC_2sls, J, KJ, AR tests" 
		exit 198
		}
		
		if strpos("`citestlist'","kj") & !strpos(subinstr("`citestlist'","kj","",.),"k") & !strpos(subinstr("`citestlist'","kj","",.),"j") {
di as err "citestlist option error - to do K-J test, you need to specify both K ant J tests"
		exit 198
		}
		if !strpos("`citestlist'","lc") {
di as err "citestlist option error - LC_2sls or LC is recommended" // some bug in collapse_citable - having LC_2sls saves some code
		exit 198
		}
		local lc_concurr "lc_2sls lc"
		local legal_lc : list lc_concurr in citestlist
		local k_concurr "k_2sls k"
		local legal_k : list k_concurr in citestlist
		if `legal_lc' > 0 | `legal_k' > 0 {
di as err "ptestlist option error - tests with 2sls and efficient weight matrix need to be run separately." 
		exit 198
		}
	}
	
	if "`ptestlist'" != "" {
		local ptestlist = lower("`ptestlist'") + " "
		local legal_ptest "lc_2sls lc k_2sls k" // legal ptestlist options
		local legal : list ptestlist in legal_ptest
		if `legal' == 0 {
di as err "ptestlist option error - can construct projection CI based on K, K_2sls, LC and LC_2sls" 
		exit 198
		}
		local lc_concurr "lc_2sls lc"
		local legal_lc : list lc_concurr in ptestlist
		local k_concurr "k_2sls k"
		local legal_k : list k_concurr in ptestlist
		if `legal_lc' > 0 | `legal_k' > 0 {
di as err "ptestlist option error - tests with 2sls and efficient weight matrix need to be run separately." 
		exit 198
		}
		local lc_k_concurr "lc_2sls k"
		local k_lc_concurr "k_2sls lc"
		local legal_k_lc : list k_lc_concurr in ptestlist
		local legal_lc_k : list lc_k_concurr in ptestlist
		if `legal_lc_k' > 0 | `legal_k_lc' > 0 {
di as err "ptestlist option error - only allow LC and K tests with same weight matrix to be calculated together." 
		exit 198
		}		
	}

* Default test lists and CI methods
* CI method is grid-based except if K=1, iid and no strong
* when closed-form CIs are available
	if `closedform' {		//  closed form - iid, nsendog=0, non-subset only
		*local testlist			"clr k j kj ar"
		local citestlist		"clr k ar"
		local testlist  "`citestlist'"									//  j and kj CIs not available for closed-form method
		local ptestlist			""											//  projection-based inference unavailable if closed-form
	}

	else {
		if `nwendog' == 1 {
	* if #wendog=1, then  ptestlist is empty
			if "`citestlist'" == "" {
				if "`waldcmd'"=="2sls" | "`waldcmd'"=="liml"  {
						local citestlist			"k_2sls lc_2sls ar"
				}
				else if "`waldcmd'"=="md2s" | "`waldcmd'"=="cue"  {
						local citestlist			"k lc ar"
				} 
				else {
						local citestlist			"k_2sls lc_2sls ar"
				}
			}
		local testlist   "`citestlist'"
		local ptestlist			""
			if "`project'" != "" {
di as err "projection option error - there is only one endogenous variable."
di as err "to calculate confidence set, you do not need to specify project()."
			exit 198
			}
		}
	* if #wendog>1, the default is to calculate only lc_2sls or lc. 
	* if the user specifies citestlist, then we calculate confidence sets for the full vector	
		if `nwendog' >1 {
			if "`ptestlist'" == "" & "`project'" != ""  {
				if "`waldcmd'"=="2sls" | "`waldcmd'"=="liml"  {
						local ptestlist			"lc_2sls"
				}
				else if "`waldcmd'"=="md2s" | "`waldcmd'"=="cue"  {
						local ptestlist			"lc"
				} 
				else {
						local ptestlist			"lc_2sls"
				}
			}
		local testlist  "`citestlist'"
		* if project() is empty, prompt the user to specify
			if "`project'" == "" & "`citestlist'" == "" {
di as err "projection option error - there are more than one endogenous variables."
di as err "either specify project() to calculate marginal confidence sets (recommended)," 
di as err "or specify citestlist() to calculate full confidence sets." 

		exit 198		
			}
		}
	
		if `usegrid' {
			local gridcols "ar_chi2 k_chi2 lc_2sls j_chi2 clr_stat ar_p k_p lc_2sls_r j_p kj_p clr_p rk rk_p a_diff_f"
			* we do not neet point wald test statistics, only for LC_2sls, even though, we don't need to save it in gridcols
			* construct a full list of stats that will be stored in citable - drop them if not specified in citestlist
			* add the rejection indicator for LC_2sls projection tests, and the a_minp (for distortion cutoff)
			if "`ptestlist'" != "" {
				foreach test of local ptestlist { // loop over all potest (which have been verified legal
					forvalues i = 1/`nwendog' {
						local gridcols "`gridcols' `test'p`i'_r"
					}
				}
				if strpos("`ptestlist'", "lc") { // indicator for either is on ptestlist
					forvalues i = 1/`nwendog' {
						local gridcols "`gridcols' a_diffp`i'"
					}
				}
			}
			// edit citestlist
			if !strpos("`citestlist'", "ar") {
				local gridcols =subinstr("`gridcols'", "ar_chi2", "", .)
				local gridcols =subinstr("`gridcols'", "ar_p", "", .)
			}
			local k_in_citest: list posof "k" in citestlist
			if `k_in_citest' == 0 { // k is not on the citestlist
				local gridcols =subinstr("`gridcols'", "kj_p", "", .)
				local gridcols =subinstr("`gridcols'", "k_chi2", "", .)
				local gridcols =subinstr("`gridcols'", " k_p ", " ", .) // so that rk_p is not cut off and k_p1_r

			}
			if !strpos("`citestlist'", "j") {
				local gridcols =subinstr("`gridcols'", "kj_p", "", .)
				local gridcols =subinstr("`gridcols'", "j_chi2", "", .)
				local gridcols =subinstr("`gridcols'", "j_p", "", .)
			}
			if !strpos("`citestlist'", "clr") {
				local gridcols =subinstr("`gridcols'", "clr_stat", "", .)
				local gridcols =subinstr("`gridcols'", "clr_p", "", .)
			}
			if !strpos("`citestlist'", "rk") {
				local gridcols =subinstr("`gridcols'", "rk_p", "", .)
				local gridcols =subinstr("`gridcols'", "rk", "", .)
			}
			if !strpos("`citestlist'", "lc_2sls") {
				local gridcols =subinstr("`gridcols'", "lc_2sls ", " ", .) // need to include the space otw lc_2slsp1 gets replaced
				local gridcols =subinstr("`gridcols'", "lc_2sls_r", "", .)
				local gridcols =subinstr("`gridcols'", "a_diff_f", "", .)
			} 
			if strpos("`citestlist'", "lc ") {
				local gridcols "`gridcols' lc lc_r a_diff_f"
			} 
			if strpos("`citestlist'", "k_2sls") {
				local gridcols "`gridcols' k_2sls k_2sls_r"
			} 
		}
	}
* Stata default clrsims = -1 => user hasn't provided value, use Mikusheva-Poi method (leave at -1) or 10k reps
* clrsims = 0 => user doesn't want sim method used, use Mikusheva-Poi method (set to -1) or nothing (leave at 0)
* clrsims > 0 => user wants sim method used with specified #sims, don't use Mikusheva-Poi method even if possible
* if CLR stat not needed, set =-1
	if !strpos("`citestlist'", "clr") {		//  If CLR test is not specified, then set to 0
		local clrsims		= 0					//  neither sims nor M-P method needed
	}
	else if `clrsims'==-1 & strpos("`citestlist'", "clr") {					//  user didn't provide value, so go to default behavior, sims or M-P
		if `nwendog'==1 & `nsendog'==0 {						//  M-P method is default for K=1 case and no strong endog
			local clrsims	= -1
		}
		if `nwendog'>1 | `nsendog'>0 {							//  must use simulation method
			local clrsims	= 10000							//  default is 10k simulations
		}										
	}

* So now:
* clrsims=-1 => don't use sim method, use Mikusheva-Poi method for CLR p-value
* clrsims=0  => don't use simulation method, no p-value provided; or CLR test is not requested
* clrsims>0  => use simulation method 

* Grid settings
	if `usegrid' {
		if "`gridpoints'"=="" {											//  no gridpoints provided, so either
																		//  assign default or base on legacy options
			if `points'>0 {
				local gridpoints "`points'"								//  legacy option
			}
			else if `points1'>0 & `points2'>0 {
				local gridpoints "`points1' `points2'"					//  legacy option
			}
			else if `nwendog'==1 {										//  default=100, #wendog=1
				local gridpoints "100"
			}
			else if `nwendog'==2 {										//  default=25, #wendog=2
				local gridpoints "25 25"
			}
			else if `nwendog'==3 {										//  default=11, #wendog=3
				local gridpoints "11 11 11"
			}
			else if `nwendog'==4 {										//  default=7, #wendog=4
				local gridpoints "7 7 7 7"
			}
			else if `nwendog'==5 {										//  default=5, #wendog=5
				local gridpoints "5 5 5 5 5"
			}
			else {
display as res "warning - must specify number of points using {helpb weakiv##gridpoints:gridpoints(.)} option "
display as res "          if number of weakly endogenous is >5 and grid is required; "
display as res "          grid not constructed"
				local usegrid	=0
			}
		}
		else {															//  check validity
			local pcount : word count `gridpoints'
			if `pcount'~=`nwendog' {
di as err "Error: number of gridpoints (`pcount') differs from number of weakly-identified regressors (`nwendog')"
				exit 198
			}
			if `nwendog'==1 {											
				local gridpoints : subinstr local gridpoints "." "100"	//  OK, so if any missing (=.), replace with 
			}															//  default points, either 100 for nwendog=1
			else {														//  or 25 for nwendog>1
				local gridpoints : subinstr local gridpoints "." "25"
			}	
		}
	}

	if `usegrid' & `gridmult'==0 {										//  default gridmult=5
			local gridmult=5
	}

* Check legality
	if `kwt'>1 | `kwt'<0 {
di as error "error: kwt must be between 0 and 1"
		exit 198
	}
	if "`estadd1'" != "" & "`estadd2'" != "" {
di as error "options estadd and estadd({it:name}) may not be combined"
		exit 184
	}


********************************************************
* Legacy rivtest options
	if "`kwt'"=="" {
		local kwt "`lmwt'"
	}
* Legacy weakiv options
	if "`gridmin'`gridmax'"=="" {
		if "`gridlimits'"~="" {
			local gridmin	: word 1 of `gridlimits'
			local gridmax	: word 2 of `gridlimits'
		}
		if "`gridlimits1'"~="" {
			local gridmin	: word 1 of `gridlimits1'
			local gridmax	: word 2 of `gridlimits'
		}
		if "`gridlimits2'"~="" {
			local gridmin2	: word 1 of `gridlimits2'
			local gridmax2	: word 2 of `gridlimits2'
		}
		if "`gridlimits1'"~="" & "`gridlimits2'"=="" {
			local gridmin	"`gridmin' ."
			local gridmax	"`gridmax' ."
		}
		if "`gridlimits1'"=="" & "`gridlimits2'"~="" {
			local gridmin	". `gridmin'"
			local gridmax	". `gridmax'"
		}
		if "`gridlimits1'"~="" & "`gridlimits2'"~="" {
			local gridmin	"`gridmin' `gridmin2'"
			local gridmax	"`gridmax' `gridmax2'"
		}
	}
	if "`gridlist'"=="" {
		if "`grid'"~="" {
			local gridlist	"`grid'"
		}
		if "`grid1'`grid2'"~="" {
			local gridlist "`grid1' | `grid2'"
		}
	}
********************************************************

	return local wnull				"`null'"
	return local kwt				"`kwt'"
	return local lm					=("`lm'"=="lm")					//  convert to boolean
	return local cuepoint			=("`cuepoint'"=="cuepoint")		//  convert to boolean
	return local cuestrong			=("`cuestrong'"=="cuestrong")	//  convert to boolean
	return local testid				=("`testid'"=="testid")			//  convert to boolean
	return local level				"`level'"
	return local alpha				"`alpha'"
	return local levellist			"`levellist'"
	return local ar_level			"`ar_level'"
	return local wald_level			"`wald_level'"			//  wald, clr and k levels are default
	return local clr_level			"`clr_level'"			//  wald, clr and k levels are default
	return local k_level			"`k_level'"				//  wald, clr and k levels are default
	return local gamma_level		"`gamma_level'"			//  gamma_min, minimal value of coverage distortion
	return local j_level			"`j_level'"
	return local kj_level			"`kj_level'"
	return local kjk_level			"`kjk_level'"
	return local kjj_level			"`kjj_level'"
	return local clrsims			"`clrsims'"
	return local ci					"`ci'"
	return local closedform			=`closedform'
	return local usegrid			"`usegrid'"
	return local ptestlist			"`ptestlist'"
	return local citestlist			"`citestlist'"
	return local testlist			"`testlist'"			// to be taken out
	return local gridcols			"`gridcols'"
	return local gridmult			"`gridmult'"
	return local gridlist			"`gridlist'"
	return local gridpoints			"`gridpoints'"
	return local gridmin			"`gridmin'"
	return local gridmax			"`gridmax'"
	return local exportmats			"`exportmats'"
	return local eststorewald		"`eststorewald'"
	return local displaywald		"`displaywald'"
	return local estadd				=("`estadd1'`estadd2'"~="")		//  convert to boolean
	return local estaddname			"`estadd2'"
	return local graph				"`graph'"
	return local graphxrange		"`graphxrange'"
	return local graphopt			"`graphopt'"
	return local contouropt			"`contouropt'"
	return local surfaceopt			"`surfaceopt'"
	return local contouronly		"`contouronly'"
	return local surfaceonly		"`surfaceonly'"
	return local forcerobust		"`forcerobust'"

end		// end get_option_specs

********************************************************************************

program define get_model_specs, sclass
	version 11.2
	syntax  [ ,											///
				esample(varname)						/// specifically refers to original estimation sample
				touse(varname)							/// may refer to created sample with more obs as in xtabond2
				wvar(varname)							///
				clustvar1_t(varname)					///
				clustvar2_t(varname)					///
				strong(varlist fv ts)					///
				project(string)							/// string since must accept _all
				project2(varlist fv ts min=2 max=2)		///
				subset(varlist fv ts)					///
				testexog(varlist fv ts)					///
				EQxtabond2(string)						/// specific to xtabond2
				*										///
		]

* verify estimation model: test can only run after ivregress, ivreg2, ivreg2h, xtivreg2, ivtobit, and ivprobit
	local legalcmd	"ivregress ivreg2 ivreg2h xtivreg xtivreg2 ivprobit ivtobit xtabond2"
* Verify estimator if no command is specified
	local legalestimator "2sls liml md2s cue"
	local cmd		"`e(cmd)'"
	local legal_cmd		: list cmd in legalcmd
	local legal_estimator   : list cmd in legalestimator
	if !`legal_estimator' {
di as err "error - unsupported for command `e(cmd)'"
		error 301
	}

* Clear any extraneous sreturn macros before parsing
	sreturn clear
	if "`e(cmd)'" == "xtabond2" {
* Need if `esample' since xtabond2 sample is created sample with poss more obs vs original
* Need to pass `wvar' so that values saved by xtabond2 in e(wt) can be assigned to it
		parse_xtabond2, wvar(`wvar') esample(`esample') touse(`touse') strong(`strong') subset(`subset') testexog(`testexog') clustvar1_t(`clustvar1_t') eq(`eqxtabond2')
	}
	if "`e(cmd)'"=="ivreg2" | "`e(cmd)'"=="ivreg2h" | `legal_estimator' { // syntax for manually calculate estimator is closest to ivreg2
		parse_ivreg2, touse(`touse') strong(`strong') subset(`subset') testexog(`testexog') clustvar1_t(`clustvar1_t') clustvar2_t(`clustvar2_t')
	}
	if "`e(cmd)'"=="ivregress" {
		parse_ivregress, touse(`touse') strong(`strong') subset(`subset') testexog(`testexog') clustvar1_t(`clustvar1_t')
	}
	if "`e(cmd)'"=="ivtobit" {
		parse_ivtobit, touse(`touse') strong(`strong') subset(`subset') testexog(`testexog')
	}
	if "`e(cmd)'"=="ivprobit" {
		parse_ivprobit, touse(`touse') strong(`strong') subset(`subset') testexog(`testexog')
	}
	if "`e(cmd)'"=="xtivreg2" {
		parse_xtivreg2, touse(`touse') strong(`strong') subset(`subset') testexog(`testexog') clustvar1_t(`clustvar1_t') clustvar2_t(`clustvar2_t')
	}
	if "`e(cmd)'"=="xtivreg" {
		parse_xtivreg, touse(`touse') strong(`strong') subset(`subset') testexog(`testexog')
	}

* Treatment of project list same for all estimators
	if "`project'"=="_all" {										//  1-D projection-based inference for all weak endog
		local pwendo	"`s(wendo)'"
	}
	else if "`project'"~="" {										//  1-D projection-based inference for selected weak endog
		local pwendo	"`project'"									//  May have factor variables or ts variables, so fvexpand needed
		fvexpand `pwendo' if `esample'								//  Need to limit to original sample so that correct specific list created
		local pwendo	"`r(varlist)'"
		local pwendo	: subinstr local pwendo "bn." ".", all		//  strip out base notation
		local pwendo	: subinstr local pwendo "b." ".", all		//  strip out base notation
		local pwendo	: subinstr local pwendo "o." ".", all		//  strip out omitted notation
		local pwendo	: list clean pwendo
		local wendo		"`s(wendo)'"								//  and check legality here
		local check		: list pwendo - wendo
		local check		: word count `check'
		if `check' > 0 {
di as err "syntax error - variable listed in project(.) but not in weakly endogenous"
			exit 198
		}
		vorder, vlist1(`pwendo') vlist2(`wendo')									//  put pwendo in order to match wendo
		local pwendo	"`r(varlist)'"
	}
	
	if "`project2'"~="" {											//  2-D projection-based inference for all weak endog
		local pwendo2	"`project2'"								//  May have factor variables or ts variables, so fvexpand needed
		fvexpand `pwendo2' if `esample'								//  Need to limit to original sample so that correct specific list created
		local pwendo2	"`r(varlist)'"
		local pwendo2	: subinstr local pwendo2 "bn." ".", all		//  strip out base notation
		local pwendo2	: subinstr local pwendo2 "b." ".", all		//  strip out base notation
		local pwendo2	: subinstr local pwendo2 "o." ".", all		//  strip out omitted notation
		local pwendo2	: list clean pwendo2
		local wendo		"`s(wendo)'"								//  and check legality here
		local check		: list pwendo2 - wendo
		local check		: word count `check'
		if `check' > 0 {
di as err "syntax error - variable listed in project(.) but not in weakly endogenous"
			exit 198
		}
		vorder, vlist1(`pwendo2') vlist2(`wendo')									//  put pwendo in order to match wendo
		local pwendo2	"`r(varlist)'"
	}

* Counts
	local nendog	: word count `s(endo)'
	local nwendog	: word count `s(wendo)'
	local nsendog	: word count `s(sendo)'
	local npwendog	: word count `pwendo'
	local ncsendog	: word count `s(csendo)'
	local nexexog	: word count `s(exexog_t)'		// xtabond2 does not have an exexog list since all IVs are temp vars
	local ninexog	: word count `s(inexog)'
	local ntinexog	: word count `s(tinexog)'

* Count modified to include constant if appropriate
	local ninexog	= `ninexog' + `s(cons)'
	local nexog		= `nexexog' + `ninexog'

* Weights
	local wtype "`e(wtype)'"				//  fweight, aweight, etc.
	if "`wtype'"=="pweight" {				//  pweight is equivalent to aweight+robust
		local wtype "aweight"				//    ...but some Stata commands don't accept pweight (e.g., summarize)
	}										//    ...and robust will already be caught in s(robust)
	if "`wtype'"=="" {						//  no weights in use
		qui replace `wvar'=1				//  define neutral weight variable
	}
	else {									//  weights in use
		if "`e(cmd)'" ~= "xtabond2" {		//  saved xtabond2 weights are retrieved by parse_xtabond2 and assigned to `wvar';
											//    in all other cases, `wvar' is calculated here
			qui replace `wvar' `e(wexp)'	//  calculate weight var contents; e(wexp) has e.g. " = 1/var"
		}
		local wtexp "[`wtype'=`wvar']"		//  e.g. "[aw=<name of wvar>]"
	}

* Every time a weight is used, must multiply by scalar wf ("weight factor")
* wf=1 for no weights, fw and iw, wf = scalar that normalizes sum to be N if aw or pw
	sum `wvar' if `touse' `wtexp', meanonly
* Weight statement
	if "`wtype'" ~= "" {
di in gr "(sum of wgt is " %14.4e `r(sum_w)' ")"
	}
	if "`wtype'"=="" | "`wtype'"=="fweight" | "`wtype'"=="iweight" {
* Effective number of observations is sum of weight variable.
* If weight is "", weight var must be column of ones and N is number of rows
		local wf=1
	}
	else if "`wtype'"=="aweight" | "`wtype'"=="pweight" {
		local wf=r(N)/r(sum_w)
	}
	else {
* Should never reach here
di as err "error - misspecified weights"
		exit 198
	}

* Assemble options spec for vce calc by avar
* omit noconstant, partial
* small omitted because avar doesn't accept it.
* `cluster' = "cluster( <varlist> )"
* `clustvar' = "`clustvar1' `clustvar2'"
	//local iid = ("`s(robust)'`s(cluster)'`s(kernel)'"=="")
	local iid = 0
	//dis "iid is `iid' always set to 0 for syntax reason - no longer supports tests under homo assumption"
	if "`s(cluster)'`s(bw)'`s(kernel)'"=="" {
		local vceopt "robust" 
	} 
	else {
		local vceopt "`s(robust)' `s(cluster)' bw(`s(bw)') kernel(`s(kernel)') `s(psd)'"
	}
	//dis "vceopt is `vceopt' default use robust avar for test statistics - only consider heteroskedasticity for now - CHANGE"
* Assemble notes for table output
	//if `iid' { // Forces to display tests robust to heteroskedasticity
	//	//local note1 "Tests assume i.i.d. errors."
	//	local note1 "Tests robust to heteroskedasticity"
	//}
	//else {
	//	if "`s(robust)'`s(cluster)'"~="" {
			local note1 "Tests robust to heteroskedasticity"
			if "`s(cluster)'"~="" {
				local note1 "`note1' and clustering on `s(clustvar1)'"
				if "`s(clustvar2)'"=="" {
					local note1 "`note1' (N_clust=`s(N_clust)')"
				}
				else {
					local note1 "`note1' (N_clust=`s(N_clust1)') and `s(clustvar2)' (N_clust=`s(N_clust2)')"
				}
			}
			else {
				local note1 "`note1'."
			}
	//	}
		if "`s(kernel)'"~="" {
			local note2 "Tests robust to autocorrelation: kernel=`s(kernel)', bw=`s(bw)'."
			}
	//}

	if "`s(small)'"~="" {
		local note3 "Small sample adjustments were used."
	}

	sreturn local waldcmd		"`cmd'"

	sreturn local pwendo		"`pwendo'"			//  varlist of endog for projection-based inference
	sreturn local pwendo2		"`pwendo2'"
	sreturn local nendog		"`nendog'"
	sreturn local nwendog		"`nwendog'"
	sreturn local nsendog		"`nsendog'"
	sreturn local npwendog		"`npwendog'"
	sreturn local ncsendog		"`ncsendog'"
	sreturn local nexexog		"`nexexog'"
	sreturn local ninexog		"`ninexog'"
	sreturn local ntinexog		"`ntinexog'"
	sreturn local nexog			"`nexog'"
	
	sreturn local wf			"`wf'"
	sreturn local wtype			"`wtype'"
	sreturn local wtexp			"`wtexp'"

	sreturn local vceopt		"`vceopt'"
	sreturn local note1			"`note1'"
	sreturn local note2			"`note2'"
	sreturn local note3			"`note3'"
	sreturn local iid			"`iid'"

end		// end get_model_specs

program define parse_ivreg2, sclass
	version 11.2
	syntax	[ ,								///
				touse(varname)				///
				strong(varlist fv ts)		///
				subset(varlist fv ts)		///
				testexog(varlist fv ts)		///
				clustvar1_t(varname)		///
				clustvar2_t(varname)		///
		]

	qui replace `touse'=e(sample)

	local model				"linear"
	local ivtitle			"linear IV"
	local kernel			"`e(kernel)'"
	local bw				"`e(bw)'"
	if "`e(vcetype)'"=="Robust" {
		local robust		"robust"
	}
	if "`e(clustvar)'"~="" {							//  enter if 1- or 2-way clustering
		local cluster		"cluster(`e(clustvar)')"	//  = "cluster( <varlist> )"
		local clustvar		"`e(clustvar)'"				//  = <varlist> (1- or 2-way clustering)
		if "`e(clustvar1)'"=="" {
			local clustvar1		"`clustvar'"			//  1-way clustering
		}
		else {
			local clustvar1		"`e(clustvar1)'"		//  var1 of 2-way clustering
		}
		qui replace `clustvar1_t' = `clustvar1'
		if "`e(clustvar2)'"~="" {						//  2-way clustering
			local clustvar2		"`e(clustvar2)'"
			qui replace `clustvar2_t' = `clustvar2'
		}
	}

	local cons		= e(cons) + e(partialcons)		// spec of ORIGINAL model, not after cons possibly partialled out
	if ~`cons' {
		local noconstant "noconstant"
	}
	local small "`e(small)'"
	local depvar "`e(depvar)'"
* use collinearity and duplicates checks
* inexog needs to include vars later partialled out
	if "`e(collin)'`e(dups)'`e(partial)'"=="" {
		local endo "`e(instd)'"
		local inexog "`e(inexog)'"
		local exexog "`e(exexog)'"
	}
	else {
		local endo "`e(instd1)'"
		local exexog "`e(exexog1)'"
		local inexog "`e(inexog1)' `e(partial1)'"
		local inexog : list retokenize inexog
	}
* ivreg2h generated instruments
	if "`e(cmd)'"=="ivreg2h" {
		local exexog "`exexog' `e(geninsts)'"
	}
* ivreg2h panel option(s) not currently supported
	if "`e(cmd)'"=="ivreg2h" & "`e(xtmodel)'"~="" {
di as err "Error: ivreg2h panel-data estimation not currently supported"
		exit 601
	}

	weakiv_fvstrip `endo', dropomit						//  dropomit to get rid of b. and o. vars etc.
	local endo				`r(varlist)'				//  no need to fvexpand since ivreg2 stores
	weakiv_fvstrip `exexog', dropomit					//  expanded varlists;
	local exexog			`r(varlist)'				//  and since no fvexpand, "if `touse'" also
	weakiv_fvstrip `inexog', dropomit					//  not needed
	local inexog			`r(varlist)'

* strong(.), subset(.) and textexog(.) options
* use fvstrip to process FVs and TSs
* need to use expand and if `touse' since options may not have expanded varlists
* do NOT use dropomit since fvstrip call to fvexpand can assign incorrect base etc.
* but requires user to correctly provide the specific varlist in the option
	weakiv_fvstrip `strong' if `touse', expand
	local sendo				"`r(varlist)'"				//  may be empty
	local wendo				: list endo - sendo
	local check				: list sendo - endo
	local check				: word count `check'
	if `check' > 0 {
di as err "syntax error - variable listed in strong(.) but not in endogenous"
		exit 198
	}
* see above on fvstrip
	if "`subset'"~="" {
		weakiv_fvstrip `subset' if `touse', expand
		local wendo				"`r(varlist)'"			//  overwrite and set wendo=subset list
		local csendo			: list endo - wendo
		local check				: word count `csendo'
		if `check' == 0 {
di as err "syntax error - variable(s) listed in subset(.)"
di as err "comprise entire set of endogenous regressors"
			exit 198
		}
		local check				: list wendo - endo
		local check				: word count `check'
		if `check' > 0 {
di as err "syntax error - variable listed in subset(.) but not in endogenous"
			exit 198
		}
	}
* see above on fvstrip
	weakiv_fvstrip `testexog' if `touse', expand
	local tinexog			"`r(varlist)'"
	local check				: list tinexog - inexog
	local check				: word count `check'
	if `check' > 0 {
di as err "syntax error - variable listed in testexog(.) but not in exogenous regressors"
		exit 198
	}
	local inexog			: list inexog - tinexog		// remove from inexog and add to endo, wendo and exexog
	local endo				: list endo   | tinexog
	local wendo				: list wendo  | tinexog
	local exexog			: list exexog | tinexog

* misc
	if "`e(vce'"=="psd0" | "`e(vce'"=="psda" {
		local psd "`e(vce)'"
	}

* Return values
	sreturn local depvar		"`depvar'"
	sreturn local endo			"`endo'"
	sreturn local inexog		"`inexog'"
	sreturn local exexog		"`exexog'"
	sreturn local depvar_t		"`depvar'"			//  _t vars with ts or fv ops will replaced by temps by main program
	sreturn local endo_t		"`endo'"
	sreturn local inexog_t		"`inexog'"
	sreturn local exexog_t		"`exexog'"
	sreturn local wendo			"`wendo'"
	sreturn local wendo_t		"`wendo'"
	sreturn local sendo			"`sendo'"
	sreturn local sendo_t		"`sendo'"
	sreturn local csendo		"`csendo'"
	sreturn local csendo_t		"`csendo'"
	sreturn local tinexog		"`tinexog'"
	sreturn local tinexog_t		"`tinexog'"
	sreturn local N				"`e(N)'"
	sreturn local N_clust		"`e(N_clust)'"			//  in case of 2-way clustering, N_clust=min(N_clust1,N_clust2)
	sreturn local N_clust1		"`e(N_clust1)'"
	sreturn local N_clust2		"`e(N_clust2)'"
	sreturn local cluster		"`cluster'"			//  = "cluster( <varlist> )"
	sreturn local clustvar		"`clustvar'"		//  = <varlist> = list of cluster variables (can be 1 or 2)
	sreturn local clustvar1		"`clustvar1'"		//  = <varname 1>
	sreturn local clustvar2		"`clustvar2'"		//  = <varname 2>
	sreturn local kernel		"`kernel'"
	sreturn local bw			"`bw'"
	sreturn local dofminus		"`e(dofminus)'"
	sreturn local psd			"`psd'"
	sreturn local cons			"`cons'"
	sreturn local noconstant	"`noconstant'"
	sreturn local small			"`small'"
	sreturn local robust		"`robust'"

	sreturn local model			"`model'"
	sreturn local ivtitle		"`ivtitle'"

end			//  end parse_ivreg2

program define parse_xtivreg2, sclass
	version 11.2
	syntax	[ ,								///
				touse(varname)				///
				strong(varlist fv ts)		///
				subset(varlist fv ts)		///
				testexog(varlist fv ts)		///
				clustvar1_t(varname)		///
				clustvar2_t(varname)		///
		]

	local xtmodel		"`e(xtmodel)'"
	if "`xtmodel'"~="fe" & "`xtmodel'"~="fd" {
di as err "error - weakiv supports only FE and FD estimation with xtivreg2"
		exit 198
	}

* Most of the parsing is done by parse_ivreg2
	parse_ivreg2, touse(`touse') strong(`strong') subset(`subset') clustvar1_t(`clustvar1_t') clustvar2_t(`clustvar2_t')

	if "`xtmodel'"=="fe" {
		local singleton		"`e(singleton)'"
	}
	else {
		local singleton		=0
	}

* Add s(.) macros to those returned by parse_ivreg2
	sreturn local singleton		"`singleton'"
	sreturn local xtmodel		"`xtmodel'"
	sreturn local N_g			"`e(N_g)'"
	sreturn local g_min			"`e(g_min)'"
	sreturn local g_max			"`e(g_max)'"
	sreturn local g_avg			"`e(g_avg)'"
	sreturn local dofminus		"`e(dofminus)'"		//  For iid FE case sigmas, adjustment for #groups needed

end			//  end parse_xtivreg2

program define parse_xtivreg, sclass
	version 11.2
	syntax	[ ,								///
				touse(varname)				///
				strong(varlist fv ts)		///
				subset(varlist fv ts)		///
				testexog(varlist fv ts)		///
		]

	qui replace `touse'=e(sample)		
	
	local model			"linear"
	local xtmodel		"`e(model)'"
	if "`xtmodel'"~="fe" & "`xtmodel'"~="fd" {
di as err "error - unsupported xtivreg model `xtmodel'"
		exit 198
	}
	local ivtitle		"linear IV"
	if "`xtmodel'"=="fe" {
		local dofminus	"`e(N_g)'"			//  For iid FE case sigmas, adjustment for #groups needed
	}
	else {
		local dofminus	=0
	}
* xtivreg uses small-sample adjustment; "small" option changes only z or t etc.
	local small			"small"
* Bizarrely, xtivreg,fd puts a D operator in front of depvar but nowhere else
	local depvar		"`e(depvar)'"
	tsunab depvar 		: `depvar'
	if "`xtmodel'"=="fd" {
		local endo		"d.(`e(instd)')"
		tsunab endo		: `endo'
		local insts		"d.(`e(insts)')"
		tsunab insts	: `insts'
		fvexpand d.(`strong') if `touse'					//  supports TS vars
		local sendo				"`r(varlist)'"				//  may be empty
		local wendo				: list endo - sendo
		if "`subset'"~="" {
			fvexpand d.(`subset') if `touse'
			local wendo			"`r(varlist)'"
			local csendo		: list endo - wendo
		}
		fvexpand d.(`testexog') if `touse'
		local tinexog			"`r(varlist)'"
	}
	else {
		local endo		"`e(instd)'"
		tsunab endo		: `endo'
		local insts		"`e(insts)'"
		tsunab insts	: `insts'
		fvexpand `strong' if `touse'						//  supports TS vars
		local sendo				"`r(varlist)'"				//  may be empty
		local wendo				: list endo - sendo
		if "`subset'"~="" {
			fvexpand `subset' if `touse'
			local wendo			"`r(varlist)'"
			local csendo		: list endo - wendo
		}
		fvexpand `testexog' if `touse'
		local tinexog			"`r(varlist)'"
	}

* Full colnames have TS operators in front of them already
	local x					: colfullnames(e(b))
	local x					: subinstr local x "_cons" "", count(local cons)
	local inexog			: list x - endo
	local exexog			: list insts - inexog

* Exog to include in tests ... but check first
	local check				: list tinexog - inexog
	local check				: word count `check'
	if `check' > 0 {
di as err "syntax error - variable listed in testexog(.) but not in exogenous regressors"
		exit 198
	}
	local inexog			: list inexog - tinexog		// remove from inexog and add to endo, wendo and exexog
	local endo				: list endo   | tinexog
	local wendo				: list wendo  | tinexog
	local exexog			: list exexog | tinexog

* xtivreg supports only conventional SEs (+ bootstrap etc)
	if "`xtmodel'"=="fe" {					//	We impose no constant in FE model
		local cons 			=0					//  Overrides cons created by count above
	}
	if ~`cons' {
		local noconstant	"noconstant"		
	}

* Return values
	sreturn local depvar		"`depvar'"
	sreturn local depvar_t		"`depvar'"			//  _t vars with ts or fv ops will replaced by temps by main program
	sreturn local endo			"`endo'"
	sreturn local endo_t		"`endo'"
	sreturn local inexog		"`inexog'"
	sreturn local inexog_t		"`inexog'"
	sreturn local exexog		"`exexog'"
	sreturn local exexog_t		"`exexog'"
	sreturn local wendo			"`wendo'"
	sreturn local wendo_t		"`wendo'"
	sreturn local sendo			"`sendo'"
	sreturn local sendo_t		"`sendo'"
	sreturn local csendo		"`csendo'"
	sreturn local csendo_t		"`csendo'"
	sreturn local tinexog		"`tinexog'"
	sreturn local tinexog_t		"`tinexog'"
	sreturn local N				"`e(N)'"
	sreturn local dofminus		"`dofminus'"
	sreturn local cons			"`cons'"
	sreturn local noconstant	"`noconstant'"
	sreturn local small			"`small'"
	sreturn local N_g			"`e(N_g)'"
	sreturn local g_min			"`e(g_min)'"
	sreturn local g_max			"`e(g_max)'"
	sreturn local g_avg			"`e(g_avg)'"
	sreturn local dofminus		"`dofminus'"
	sreturn local model			"`model'"
	sreturn local xtmodel		"`xtmodel'"
	sreturn local ivtitle		"`ivtitle'"

******* zeros by default or if not supported  ********
	sreturn local singleton		=0

end			//  end parse_xtivreg

program define parse_ivregress, sclass
	version 11.2
	syntax	[ ,								///
				touse(varname)				///
				strong(varlist fv ts)		///
				subset(varlist fv ts)		///
				testexog(varlist fv ts)		///
				clustvar1_t(varname)		///
		]

	qui replace `touse'=e(sample)

	local model				"linear"
	local ivtitle			"linear IV"
	tokenize `e(vce)'
	if "`1'" == "hac" {
		local kernel		"`e(hac_kernel)'"
		local bw			=`3'+1
		local robust		"robust"
	}
	if "`e(vce)'" == "robust" {
		local robust		"robust"
	}
	if "`e(clustvar)'"~="" {							//  1-way clustering
		local cluster		"cluster(`e(clustvar)')"	//  = "cluster( <varname> )"
		local clustvar1		"`e(clustvar)'"				//  = <varname>
		qui replace `clustvar1_t' = `clustvar1'
		local robust		"robust"					//  cluster=>robust
	}

	local noconstant		"`e(constant)'"
	local cons				= ~("`noconstant'"=="noconstant")
	local small				"`e(small)'"
	local depvar			"`e(depvar)'"				//  not allowed by ivregress to be a FV

	weakiv_fvstrip `e(instd)', dropomit					//  dropomit to get rid of b. and o. vars etc.
	local endo				`r(varlist)'				//  no need to fvexpand since ivregress stores
	weakiv_fvstrip `e(exogr)', dropomit					//  expanded varlists;
	local inexog			`r(varlist)'				//  and since no fvexpand, "if `touse'" also
	weakiv_fvstrip `e(insts)', dropomit					//  not needed
	local insts				`r(varlist)'
	local exexog			: list insts - inexog

* strong(.), subset(.) ant textexog(.) options
* use fvstrip to process FVs and TSs
* need to use expand and if `touse' since options may not have expanded varlists
* do NOT use dropomit since fvstrip call to fvexpand can assign incorrect base etc.
* but requires user to correctly provide the specific varlist in the option
	weakiv_fvstrip `strong' if `touse', expand
	local sendo				"`r(varlist)'"				//  may be empty
	local wendo				: list endo - sendo
	local check				: list sendo - endo
	local check				: word count `check'
	if `check' > 0 {
di as err "syntax error - variable listed in strong(.) but not in endogenous"
		exit 198
	}
* see above on fvstrip
	if "`subset'"~="" {
		weakiv_fvstrip `subset' if `touse', expand
		local wendo				"`r(varlist)'"			//  overwrite and set wendo=subset list
		local csendo			: list endo - wendo
		local check				: word count `csendo'
		if `check' == 0 {
di as err "syntax error - variable(s) listed in subset(.)"
di as err "comprise entire set of endogenous regressors"
			exit 198
		}
		local check				: list wendo - endo
		local check				: word count `check'
		if `check' > 0 {
di as err "syntax error - variable listed in subset(.) but not in endogenous"
			exit 198
		}
	}
* see above on fvstrip
	weakiv_fvstrip `testexog' if `touse', expand
	local tinexog			"`r(varlist)'"
	local check				: list tinexog - inexog
	local check				: word count `check'
	if `check' > 0 {
di as err "syntax error - variable listed in testexog(.) but not in exogenous regressors"
		exit 198
	}
	local inexog			: list inexog - tinexog		// remove from inexog and add to endo, wendo and exexog
	local endo				: list endo   | tinexog
	local wendo				: list wendo  | tinexog
	local exexog			: list exexog | tinexog

* Return values
	sreturn local depvar		"`depvar'"
	sreturn local depvar_t		"`depvar'"			//  _t vars with ts or fv start as original vars
	sreturn local endo			"`endo'"
	sreturn local endo_t		"`endo'"			//  will be replaced by temps by main program
	sreturn local inexog		"`inexog'"
	sreturn local inexog_t		"`inexog'"
	sreturn local exexog		"`exexog'"
	sreturn local exexog_t		"`exexog'"
	sreturn local wendo			"`wendo'"
	sreturn local wendo_t		"`wendo'"
	sreturn local sendo			"`sendo'"
	sreturn local sendo_t		"`sendo'"
	sreturn local csendo		"`csendo'"
	sreturn local csendo_t		"`csendo'"
	sreturn local tinexog		"`tinexog'"
	sreturn local tinexog_t		"`tinexog'"
	sreturn local N				"`e(N)'"
	sreturn local N_clust		"`e(N_clust)'"
	sreturn local cluster		"`cluster'"			//  = "cluster( <varname> )"
	sreturn local clustvar		"`clustvar1'"		//  = <varname>
	sreturn local clustvar1		"`clustvar1'"		//  = <varname>
	sreturn local kernel		"`kernel'"
	sreturn local bw			"`bw'"
	sreturn local dofminus		=0
	sreturn local cons			"`cons'"
	sreturn local noconstant	"`noconstant'"
	sreturn local small			"`small'"
	sreturn local robust		"`robust'"

	sreturn local model			"`model'"
	sreturn local ivtitle		"`ivtitle'"

end			//  end parse_ivregress


program define parse_xtabond2, sclass
	version 11.2
	syntax [ ,								///
				wvar(varname)				///
				esample(varname)			/// original estimation sample
				touse(varname)				/// will refer to created sample with more obs
				strong(varlist fv ts)		///
				subset(varlist fv ts)		///
				testexog(varlist fv ts)		///
				clustvar1_t(varname)		///
				eq(string)					/// specific to xtabond2
		]

* All these will need to be created based on saved xtabond2 matrix:
*   depvar endo inexog insts exexog clustvar1
* Should be no need to use _ms_parse_parts - omitted vars should already be dropped by xtabond2

	tempname b V Y X Z ideqt wt clustid		//  used for matrices
* Y, X and Z will be present because of previous check for matafavor=speed
	mat `Y'=e(Y)
	mat `X'=e(X)
	mat `Z'=e(Z)
* If one of Y, X or Z is missing, it's because svmat option wasn't used.
	if rowsof(`Y')==1 & `Y'[1,1]==. {
di as err "Error: xtabond2 requires svmat option if using weakiv as"
di as err "       postestimation command after xtabond2 estimation."
		exit 198
	}
* ideqt matrix added in xtabond2 version 03.04.00. Catch if not present.
	mat `ideqt'=e(ideqt)
	if rowsof(`ideqt')==1 & `ideqt'[1,1]==. {
di as err "Error: xtabond2 saved matrix e(ideqt) not found"
di as err "Must have xtabond2 version 03.04.00 or greater installed"
di as err "To install, from within Stata type " _c
di in smcl "{stata ssc install xtabond2 :ssc install xtabond2}"
		exit 111
	}

* Panel id, equation number, and time variable
	capture drop __ideqt*
	qui svmat long `ideqt', names(__ideqt)
	
* Weight variable
	local wtype "`e(wtype)'"
* Some Stata commands don't like pweights but aweights will yield same results
	if "`wtype'"=="pweight" {
		local wtype "aweight"
	}
	if "`wtype'" ~= "" {						
		qui replace `wvar' `e(wexp)' if `esample'		//  xtabond2 saved normalized weights for pw and aw
		if "`wtype'"=="aweight" | "`e(robust)'"=="robust" {
			sum `wvar' if `esample', meanonly			//  so get mean of original for later de-normalizing
			local wvarmean = r(mean)
		}
		else {											//  ...but not for fweights + classical VCE.
			local wvarmean = 1
		}
		mat `wt'=e(wt)									//  retrieve saved weight variable
		if rowsof(`wt')==1 & `wt'[1,1]==. {				//  and put values into tempvar `wvar'
di as err "Error: xtabond2 weights variable e(wt) missing from saved results"
			exit 198
		}
		capture drop __wt1
		qui svmat double `wt', names(__wt)				//  xtabond2 weight variable has been normalized to mean=1;
		qui replace `wvar' = __wt1						//  will fix this below using `wvarmean'
		local wtexp "[`wtype'=`wvar']"					//  e.g. "[aw=<name of wvar>]"; used below
	}
	else {												//  no weights, so wvar = 1
		qui replace `wvar' = 1
	}

* Work out whether to use levels data, diffs data or both.
	tempname iv gmm ivgmm
	mat `iv'=e(ivequation)
	mat `gmm'=e(gmmequation)
	mat `ivgmm' = nullmat(`iv') , nullmat(`gmm')
	local uselevel=0
	local usediff=0
	local eqs=colsof(`ivgmm')
	forvalues i=1/`eqs' {
		if `ivgmm'[1,`i']==0 {
			local uselevel=1
		}
		if `ivgmm'[1,`i']==1 {
			local usediff=1
		}
		if `ivgmm'[1,`i']==2 {
			local uselevel=1
			local usediff=1
		}
	}
* Save this info about the original xtabond2 estimation.
	if `usediff' & `uselevel' {
		local xtbond2model	"sys"
	}
	else if `usediff' {
		local xtbond2model	"diff"
	}
	else if `uselevel' {
		local xtbond2model	"lev"
	}
	else {						// should never reach here
di as erro "internal weakiv error in parsing xtabond2"
			exit 198
	}
* Above is overridden by user-provided eq(.) if provided
	if "`eq'" ~= "" {
		if "`eq'"=="diff" {
			local usediff =1
			local uselevel=0
		}
		else if "`eq'"=="lev" {
			local usediff =0
			local uselevel=1
		}
		else if "`eq'"=="sys" {
			local usediff =1
			local uselevel=1
		}
		else {
di as err "illegal option: eq(`eq')"
			exit 198
		}
	}
* Set touse and xtmodel macro.
* xtmodel corresponds to weakiv estimation; xtabond2model to original xtabond2 estimation.
	if `usediff' {
		qui replace `touse'=1 if __ideqt2==0
	}
	if `uselevel' {
		qui replace `touse'=1 if __ideqt2==1
	}
	qui replace `touse'=0 if `touse'==.
	if `usediff' & `uselevel' {
		local xtmodel	"sys"
	}
	else if `usediff' {
		local xtmodel	"diff"
	}
	else if `uselevel' {
		local xtmodel	"lev"
	}
	else {						// should never reach here
di as erro "internal weakiv error in parsing xtabond2"
			exit 198
	}
		
* Clustering
	if ("`e(clustvar)'"=="") & ("`e(robust)'"=="") {		//  no clustering unusual in xtabond2 estimation but allowed
		local clustvar1	""									//  ... so do nothing
	}
	else if ("`e(clustvar)'"=="") & ("`e(robust)'"~="") {	//  in xtabond2, robust => cluster on default id variable
		local clustvar1				"`e(ivar)'"				//  varname for clustering in output
		qui replace `clustvar1_t' 	=__ideqt1				//  use saved ideqt1 = panel id = cluster variable
	}
	else if ("`e(clustvar)'"=="`e(ivar)'") {				//  explicit clustering by xtabond2 on id variable
		local clustvar1				"`e(ivar)'"
		qui replace `clustvar1_t' 	=__ideqt1
	}
	else if (`: word count `e(clustvar)'') > 1 {			//  weakiv does not support 2-way clustering by xtabond2
di as err "Error: weakiv does not support 2-way clustering by xtabond2"
		exit 198
	}
	else {													//  clustering on a non-id variable
		mat `clustid' = e(clustid)							//  earlier versions of xtabond2 save e(clustid);
															//  later versions save e(clustid1); check for both
		if rowsof(`clustid')==1 & `clustid'[1,1]==. {		//  check e(clustid); if not saved, try e(clustid1)
			mat `clustid' = e(clustid1)
		}
		if rowsof(`clustid')==1 & `clustid'[1,1]==. {		//  if neither e(clustid) nor e(clustid1) exit, exit with error
di as err "Error: xtabond2 cluster id variable e(clustid) missing from saved results"
di as err "       try clustering on the panel identifier `e(ivar)' or update your xtabond2"
		exit 198
		}
		capture drop __clustid1
		qui svmat long `clustid', names(__clustid)
		local clustvar1				"`e(clustvar)'"
		qui replace `clustvar1_t' 	=__clustid1
	}
* Now clustering, set remaining vars
	if "`clustvar1'" ~= "" {
		local cluster				"cluster(`clustvar1_t')"	//  = "cluster( <varname> )"
		local N_clust				"`e(N_clust)'"
		if "`N_clust'"=="" {									//  May be missing if xtabond2 used some default settings
			tempvar clustcount
			qui egen `clustcount'=group(`clustvar1_t') if `touse'
			sum `clustcount' if `touse', meanonly
			local N_clust = r(max)
		}
	}

* Y (depvar)
	capture drop __Y1
	qui svmat double `Y', names(__Y)
	local depvar_t "__Y1"
* X (regressors)
	capture drop __X*
	qui svmat double `X', names(__X)
* Z (IVs)
	capture drop __Z*
	qui svmat double `Z', names(__Z)

	if "`e(wtype)'" ~= "" {								//  xtabond2 incorporates weights in Y and Xs, so remove
		foreach var of varlist __Y1 __X* {
			qui replace `var' = `var'/`wvar'
		}
		if ~("`e(wtype)'"=="fweight" & "`e(robust)'"=="") {
			qui replace `wvar' = `wvar' * `wvarmean'	//  and now finally recreate weight var by de-normalizing
		}
	}

* Create lists of names of new X and Z vars. (Doesn't actually unabbreviate anything.)
	unab Xnames : __X*
	unab Znames : __Z*

* Create lists of col names of X and Z matrices.
* NB: xtabond2 e(Z) matrix may have empty (all zeros) column at the RHS.
*     These may NOT have column names.
*     Hence the number of columns of Z may > number of colnames of Z.
	local Xcnames	: colnames `X'
	local Zcnames	: colnames `Z'
* In case there are factor variables in either list, strip out extraneous b/n/o:
	weakiv_fvstrip `Xcnames'
	local Xcnames	`r(varlist)'
	weakiv_fvstrip `Zcnames'
	local Zcnames	`r(varlist)'

* Get original Stata names of endo and inexog variables from e(b).
	mat `b'=e(b)
	mat `V'=e(V)
	local cfn : colfullnames `b'
* xtabond2 may have a bug that means omitteds aren't always correctly flagged,
* so remove them by hand.  Also remove factor variable b/n/o notation.
	local colsofb=colsof(`b')
	forvalues i=1/`colsofb' {
		local cn	: word `i' of `cfn'
		if el(`V',`i',`i') ~= 0 {
			local tokeep	`tokeep' `cn'
		}
	}
	local cfn	: list clean tokeep
	weakiv_fvstrip `cfn'
	local cfn	`r(varlist)'

* Process Xs and Zs.

* First Xs.
* Check: does original number of coeffs match number of Xs?
	if colsof(`X') ~= colsof(`b') {
di as err "weakiv/xtabond2 error - number of coefficients does not match number of columns in e(X)"
		exit 103
	}
* Some Xs saved by xtabond2 may be all 0s and not used (e.g. omitted or fv base vars).
* Xindex will be row vector of 0/1 indicating whether X col is used.
	tempname Xindex
	mata:	st_view(`X'=., ., "`Xnames'", "`touse'")
	mata:	st_matrix("`Xindex'",colsum(`X':==0) :< rows(`X'))
	mata:	mata drop `X'
* Now assemble list of not-all-zeros regressor temp variables
	local i 1
	foreach vn of varlist `Xnames' {
		if el(`Xindex',1,`i') {
			local tlist	`tlist' `vn'
		}
		local ++i
	}
* New Xnames are temp vars that are used and not omitted.
* New Xcnames are corresponding col names in e(b) and e(X).
	weakiv_matchnames "`tlist'" "`Xnames'" "`Xcnames'"
	local Xcnames	`r(names)'
	local Xnames	: list clean tlist

/*
di "Xnames=`Xnames'"
di "Xcnames=`Xcnames'"
*/

* Now partition Xs into endogenous and included exogenous.
* Do this by removing Xs that also appear in Z and hence are included exogenous.
	local endocnames	: list Xcnames - Zcnames
	local inexogcnames	: list Xcnames - endocnames
* Create lists of endo and inexog, respecting the order in e(b).
* Note: if just diff or lev data are used, it is possible
* that the order may NOT be <endo> <inexog>, as in e(b).
	local endo			: list cfn - inexogcnames
	local inexog		: list cfn - endocnames
* Check: does number in two lists match number of coeffs?
/*
di "endo=`endo'"
di "inexog=`inexog'"
di "cnf=`cfn'"
*/
	if `: word count `endo'' + `: word count `inexog'' ~= `: word count `cfn'' {
di as err "weakiv/xtabond2 error - number of coefficients does not match number endo + inexog"
		exit 103
	}
* Finally, create lists of temp vars endo_t and inexog_t,
* again respecting the original order in e(b).
* weakiv_matchnames
	weakiv_matchnames "`endocnames'" "`Xcnames'" "`Xnames'"
	local endo_t	`r(names)'
	weakiv_matchnames "`inexogcnames'" "`Xcnames'" "`Xnames'"
	local inexog_t	`r(names)'
	local nendog	: word count `endo_t'
	local ninexog	: word count `inexog_t'

* Now Zs.
* No need to keep lists of "original" Z names; just the temp _t names are needed.
* So just work with __Z* aka _t temp names
* First remove inexog_t variables from Znames.
* Look up inexog (original names) to find corresponding temp names, then remove.
	weakiv_matchnames "`inexog'" "`Zcnames'" "`Znames'"
	local todrop		`r(names)'
	local exexognames	: list Znames - todrop
* Some Zs saved by xtabond2 may be all 0s and not used.
* Zindex will be row vector of 0/1 indicating whether Z col is used.
	tempname Zindex
	mata:	st_view(`Z'=., ., "`exexognames'", "`touse'")
	mata:	st_matrix("`Zindex'",colsum(`Z':==0) :< rows(`Z'))
	mata:	mata drop `Z'
* Now assemble list of not-all-zeros exexog temp variables
	local i 1
	foreach vn of varlist `exexognames' {
		if el(`Zindex',1,`i') {
			local exexog_t	`exexog_t' `vn'
		}
		local ++i
	}
	local exexog_t	: list clean exexog_t
* Last issue with Z is collinearities within instruments.
* xtabond2 saves #IVs including collinears as e(j0) and #IVs excluding as e(j).
* Remove collinears from exexog_t if xtabond2 indicates collinearities
* or if information not saved by xtabond2.  -forcedrop- works because these are
* temp names with no factor variables in them.
	if (e(j)~=e(j0)) | (e(j)==.) | (e(j0)==.) {
		qui _rmcoll `exexog_t' if `touse', nocons forcedrop
		local exexog_t	`r(varlist)'
	}
	local nexexog	: word count `exexog_t'
* Check: does final number of excluded IVs match xtabond2's e(j)?
* We can do this only if the original xtabond2 estimation uses the same eqns
* as the weakiv estimation (diff, lev, sys).
	if ("`xtmodel'"=="`xtabond2model'") & (`nexexog' ~= e(j)) & (e(j)<.) {
di as err "weakiv/xtabond2 error - number of instruments in e(j) does not match number of exexog"
		exit 103
	}

/*
di "nendog=`nendog'"
di "ninexog=`ninexog'"
di "nexexog=`nexexog'"
di "endo=`endo'"
di "endo_t=`endo_t'"
di "inexog=`inexog'"
di "inexog_t=`inexog_t'"
di "exexog_t=`exexog_t'"
*/

/*
* Use _rmcollright to deduce which are Xs and which are Zs; here, the Xs.
* No need to use weights.
	qui _rmcollright (`Znames') (`Xnames') if `touse', noconstant
	local todrop "`r(dropped)'"
	local endo_t	: list Xnames - todrop
	local inexog_t	: list Xnames - endo_t
	local nendog	: word count `endo_t'
	local ninexog	: word count `inexog_t'
*/

/*
* Get positions of endo and inexog in list of regressors.
* Note: if just diff or lev data are used, it is possible
* that the order may NOT be <endo> <inexog>, as in e(b).
* Positions are obtained simply from svmat varnames.
* Result is (should be!) a possibly-empty numlist
	local endopos	"`endo_t'"
	local endopos	: subinstr local endopos "__X" "", all
	local inexogpos	"`inexog_t'"
	local inexogpos	: subinstr local inexogpos "__X" "", all

* Collect names of endo and inexog
	tokenize `cfn'												//  varnames now in macros `1', `2', etc.
	foreach pos of local endopos {
		local endo "`endo' ``pos''"								//  varname, poss including ts or fv operators
	}
*/
/*
* fvstrip to remove bn, b, o FV notation if present
* no need for dropomit because xtabond2 e(b) has only used variables
	weakiv_fvstrip `endo'
	local endo	`r(varlist)'
	foreach pos of local inexogpos {							//  possibly empty!
		local inexog "`inexog' ``pos''"							//  inexog varnames, poss including ts or fv operators
	}
	local inexog	: list clean inexog

* Use _rmcollright to deduce which are Xs and which are Zs; here, the Zs.
* No need to use weights.
	qui _rmcollright (`Xnames') (`Znames') if `touse', noconstant
	local todrop "`r(dropped)'"
	local exexog_t	: list Znames - todrop
	local nexexog	: word count `exexog_t'
*/


* Match varnames in sendo with corresponding varnames in endo & endo_t,
* and assemble corresponding sendo_t.  Loop through endo so that we can
* reassemble sendo so order matches endo, endo_t and sendo_t.
* Also define wendo and wendo_t varlists.
* use fvstrip to process FVs and TSs
* need to use expand and if `esample' so that correct specific list is created
* do NOT use dropomit since fvstrip call to fvexpand can assign incorrect base etc.
	weakiv_fvstrip `strong' if `esample', expand
	local templist			"`r(varlist)'"							//  may be empty
	forvalues i=1/`nendog' {
		local vn    : word `i' of `endo'
		local pos   : list posof `"`vn'"' in templist
		if `pos'>0 {
			local vn_t			: word `i' of `endo_t'
			local sendo			"`sendo' `vn'"
			local sendo_t		"`sendo_t' `vn_t'"
		}
	}
	local sendo		: list clean sendo
	local sendo_t	: list clean sendo_t
	local wendo		: list endo   - sendo
	local wendo_t	: list endo_t - sendo_t
	local check		: list templist - sendo
	local check		: word count `check'
	if `check' > 0 {
di as err "syntax error - variable listed in strong(.) but not in endogenous"
		exit 198
	}

* As above, for subset wendo.  Subset wendo is wendo; rest is csendo.
* Overrides (incompatible) wendo options set above.
	if "`subset'"~="" {
		local wendo			""												//  clear and recreate below
		local wendo_t		""
* See remarks above on fvstrip
		weakiv_fvstrip `subset' if `esample', expand
		local templist			"`r(varlist)'"								//  may be empty
		forvalues i=1/`nendog' {
			local vn    : word `i' of `endo'
			local pos   : list posof `"`vn'"' in templist
			if `pos'>0 {
				local vn_t			: word `i' of `endo_t'
				local wendo			"`wendo' `vn'"
				local wendo_t		"`wendo_t' `vn_t'"
			}
		}
		local wendo		: list clean wendo
		local wendo_t	: list clean wendo_t
		local csendo	: list endo   - wendo
		local csendo_t	: list endo_t - wendo_t
		local check		: word count `csendo'
		if `check' == 0 {
di as err "syntax error - variable(s) listed in subset(.)"
di as err "comprise entire set of endogenous regressors"
			exit 198
		}
		local check		: list templist - wendo
		local check		: word count `check'
		if `check' > 0 {
di as err "syntax error - variable listed in subset(.) but not in endogenous"
			exit 198
		}
	}

* Prepare and report basic xtabond2 estimation details
* Do this BEFORE testexog so that counts refer to xtabond2 estimation
	sum `touse' `wtexp' if `touse', meanonly
	local N = r(N)
* Observation counts reported to user
	if `usediff' {
		sum `touse' if __ideqt2==0 `wtexp', meanonly
		local N_diff = r(N)
	}
	else {
		local N_diff = 0
	}
	if `uselevel' {
		sum `touse' if __ideqt2==1 `wtexp', meanonly
		local N_lev = r(N)
	}
	else {
		local N_lev = 0
	}
di as text "Estimation using xtabond2-transformed data:"
di as text "Number of obs:    diff eqn = " `N_diff' ", lev eqn = " `N_lev' ", total = " `N'
di as text "Number of vars:   #endog = " `nendog' ", #inexog = " `ninexog' ", #exexog = " `nexexog'
di as text "{p 0 18}Endog regressors: `endo'{p_end}"
di as text "{p 0 18}Exog regressors:  `inexog'{p_end}"

* If testexog(.), remove vars from inexog and add to endo, wendo and exexog
* see remarks above on fvstrip
	weakiv_fvstrip `testexog' if `touse', expand
	local templist				"`r(varlist)'"						//  may be empty
	forvalues i=1/`ninexog' {
		local vn    : word `i' of `inexog'
		local pos   : list posof `"`vn'"' in templist
		if `pos'>0 {
			local vn_t			: word `i' of `inexog_t'
			local tinexog		"`tinexog' `vn'"
			local tinexog_t		"`tinexog_t' `vn_t'"
		}
	}
	local tinexog	: list clean tinexog
	local tinexog_t	: list clean tinexog_t
	local check		: list tinexog - inexog
	local check		: word count `check'
	if `check' > 0 {
di as err "syntax error - variable listed in testexog(.) but not in exogenous regressors"
		exit 198
	}
	local inexog			: list inexog   - tinexog		// remove from inexog and add to endo, wendo and exexog
	local inexog_t			: list inexog_t - tinexog_t
	local endo				: list endo     | tinexog
	local endo_t			: list endo_t   | tinexog_t
	local wendo				: list wendo    | tinexog
	local wendo_t			: list wendo_t  | tinexog_t
	local exexog_t			: list exexog_t | tinexog_t		//  no exexog, only exexog_t

	sreturn local depvar		"`e(depvar)'"
	sreturn local depvar_t		"`depvar_t'"
	sreturn local endo			"`endo'"
	sreturn local endo_t		"`endo_t'"
	sreturn local wendo			"`wendo'"
	sreturn local wendo_t		"`wendo_t'"
	sreturn local sendo			"`sendo'"
	sreturn local sendo_t		"`sendo_t'"
	sreturn local csendo		"`csendo'"
	sreturn local csendo_t		"`csendo_t'"
	sreturn local inexog		"`inexog'"
	sreturn local inexog_t		"`inexog_t'"
	sreturn local tinexog		"`tinexog'"
	sreturn local tinexog_t		"`tinexog_t'"
	sreturn local exexog_t		"`exexog_t'"		//  No exexog; info in GMM and IV inst lists
	sreturn local gmminsts1		"`e(gmminsts1)'"	//  Specific to xtabond2
	sreturn local gmminsts2		"`e(gmminsts2)'"	//  Specific to xtabond2
	sreturn local ivinsts1		"`e(ivinsts1)'"		//  Specific to xtabond2
	sreturn local ivinsts2		"`e(ivinsts2)'"		//  Specific to xtabond2
	sreturn local touse			"`touse'"
	sreturn local wvar			"`wvar'"
	sreturn local cluster		"`cluster'"
	sreturn local clustvar		"`clustvar1'"
	sreturn local clustvar1		"`clustvar1'"
	sreturn local clustvar1_t	"`clustvar1_t'"
	sreturn local N				"`N'"
	sreturn local N_clust		"`N_clust'"
	sreturn local N_g			"`e(N_g)'"
	sreturn local g_min			"`e(g_min)'"
	sreturn local g_max			"`e(g_max)'"
	sreturn local g_avg			"`e(g_avg)'"

* noconstant always empty so do not return

	sreturn local model			"linear"
	sreturn local xtmodel		"`xtmodel'"
	sreturn local ivtitle		"linear IV"
	sreturn local robust		"`e(robust)'"		//  always ="robust" under clustering
	sreturn local cons			= 0					//  xtabond2 will have a constant column in the data matrix
	sreturn local noconstant	"noconstant"
	sreturn local small			"`e(small)'"

******* zeros by default or if not supported  ********
	sreturn local singleton		=0
	sreturn local dofminus		=0

end		//  end parse_xtabond2


program define parse_ivtobit, sclass
	version 11.2
	syntax	[ ,								///
				touse(varname)				///
				strong(varlist fv ts)		///
				subset(varlist fv ts)		///
				testexog(varlist fv ts)		///
		]

	qui replace `touse'=e(sample)

	local model "ivtobit"
	local ivtitle "IV tobit"
* verify that robust or cluster covariance estimation not used
	if "`e(vce)'" == "robust" | "`e(vce)'" == "cluster" {
		di as err "with ivtobit, weakiv requires an assumption of homoskedasticity (no robust or cluster)"	
		exit 198
	}
* parse ivtobit options
	if "`e(llopt)'" ~= "" {
		local llopt "ll(`e(llopt)')"
	}
	if "`e(ulopt)'" ~= "" {
		local ulopt "ul(`e(ulopt)')"
	}
	local small "small"				// ivtobit => small
	local cons=1					// ivtobit => always a constant
	local depvar=trim(subinword("`e(depvar)'","`e(instd)'","",.))
	local endo "`e(instd)'"
* get instrument lists; tricky because ivtobit is multiple-eqn estimator
	local cmdline "`e(cmdline)'"
	gettoken lhs 0 : cmdline , parse("=")
	gettoken 0 rhs : 0 , parse(")")
	local 0 : subinstr local 0 "=" ""
	tsunab rawinst : `0'
	local exexog ""
	local insts "`e(insts)'"
	foreach v of local rawinst {
		local insts : subinstr local insts "`v'" "", all word count(local subct)
		if `subct'>0 {
			local exexog "`exexog' `v'"
		}
	}
	local inexog "`insts'"

* strong(.) and subset(.) options
* factor vars in endog list not supported,
* but use fvexpand anyway since it supports ts vars
	fvexpand `strong' if `touse'
	local sendo				"`r(varlist)'"				//  may be empty
	local wendo				: list endo - sendo
	local check				: list sendo - endo
	local check				: word count `check'
	if `check' > 0 {
di as err "syntax error - variable listed in strong(.) but not in endogenous"
		exit 198
	}
	if "`subset'"~="" {
		fvexpand `subset' if `touse'
		local wendo				"`r(varlist)'"			//  overwrite and set wendo=subset list
		local csendo			: list endo - wendo
		local check				: word count `csendo'
		if `check' == 0 {
di as err "syntax error - variable(s) listed in subset(.)"
di as err "comprise entire set of endogenous regressors"
			exit 198
		}
		local check				: list wendo - endo
		local check				: word count `check'
		if `check' > 0 {
di as err "syntax error - variable listed in subset(.) but not in endogenous"
			exit 198
		}
	}
	fvexpand `testexog' if `touse'
	local tinexog			"`r(varlist)'"
	local check				: list tinexog - inexog
	local check				: word count `check'
	if `check' > 0 {
di as err "syntax error - variable listed in testexog(.) but not in exogenous regressors"
		exit 198
	}
	local inexog			: list inexog - tinexog		// remove from inexog and add to endo, wendo and exexog
	local endo				: list endo   | tinexog
	local wendo				: list wendo  | tinexog
	local exexog			: list exexog | tinexog

* Return values

	sreturn local depvar		"`depvar'"
	sreturn local depvar_t		"`depvar'"			//  _t vars with ts or fv ops will replaced by temps by main program
	sreturn local endo			"`endo'"
	sreturn local endo_t		"`endo'"
	sreturn local inexog		"`inexog'"
	sreturn local inexog_t		"`inexog'"
	sreturn local exexog		"`exexog'"
	sreturn local exexog_t		"`exexog'"
	sreturn local wendo			"`wendo'"
	sreturn local wendo_t		"`wendo'"
	sreturn local sendo			"`sendo'"
	sreturn local sendo_t		"`sendo'"
	sreturn local csendo		"`csendo'"
	sreturn local csendo_t		"`csendo'"
	sreturn local tinexog		"`tinexog'"
	sreturn local tinexog_t		"`tinexog'"
	sreturn local N				"`e(N)'"
	sreturn local cons			"`cons'"
	sreturn local noconstant	"`noconstant'"
	sreturn local small			"`small'"
	sreturn local llopt			"`llopt'"
	sreturn local ulopt			"`ulopt'"
	sreturn local model			"`model'"
	sreturn local ivtitle		"`ivtitle'"

******* zeros by default or if not supported  ********
	sreturn local dofminus		=0

end			//  end parse_ivtobit


program define parse_ivprobit, sclass
	version 11.2
	syntax	[ ,								///
				touse(varname)				///
				strong(varlist fv ts)		///
				subset(varlist fv ts)		///
				testexog(varlist fv ts)		///
		]

	qui replace `touse'=e(sample)

	local model "ivprobit"
	local ivtitle "IV probit"
* verify that robust or cluster covariance estimation not used
	if "`e(vce)'" == "robust" | "`e(vce)'" == "cluster" {
		di as err "with probit, weakiv requires an assumption of homoskedasticity (no robust or cluster)"	
		exit 198
	}

	if "`e(vce)'" ~= "twostep" {
di as err "For endogenous probit, Wald statistics are comparable with weak-IV-robust statistics"
di as err "only when the Newey two-step estimator is used for original ivprobit estimation."
di as err "Re-estimate using the -twostep- option."
		exit 198
	}
	local small			"small"				// ivprobit => small
	local cons			=1					// ivprobit => always a constant
	local depvar=trim(subinword("`e(depvar)'","`e(instd)'","",.))
	local endo			"`e(instd)'"
* get instrument lists
	local x : colnames(e(b))
	local x : subinstr local x "_cons" ""
	local insts			"`e(insts)'"
	local inexog : list x - endo
	local exexog : list insts - inexog

* strong(.) and subset(.) options
* factor vars in endog list not supported,
* but use fvexpand anyway since it supports ts vars
	fvexpand `strong' if `touse'
	local sendo				"`r(varlist)'"				//  may be empty
	local wendo				: list endo - sendo
	local check				: list sendo - endo
	local check				: word count `check'
	if `check' > 0 {
di as err "syntax error - variable listed in strong(.) but not in endogenous"
		exit 198
	}
	if "`subset'"~="" {
		fvexpand `subset' if `touse'
		local wendo				"`r(varlist)'"			//  overwrite and set wendo=subset list
		local csendo			: list endo - wendo
		local check				: word count `csendo'
		if `check' == 0 {
di as err "syntax error - variable(s) listed in subset(.)"
di as err "comprise entire set of endogenous regressors"
			exit 198
		}
		local check				: list wendo - endo
		local check				: word count `check'
		if `check' > 0 {
di as err "syntax error - variable listed in subset(.) but not in endogenous"
			exit 198
		}
	}
	fvexpand `testexog' if `touse'
	local tinexog			"`r(varlist)'"
	local check				: list tinexog - inexog
	local check				: word count `check'
	if `check' > 0 {
di as err "syntax error - variable listed in testexog(.) but not in exogenous regressors"
		exit 198
	}
	local inexog			: list inexog - tinexog		// remove from inexog and add to endo, wendo and exexog
	local endo				: list endo   | tinexog
	local wendo				: list wendo  | tinexog
	local exexog			: list exexog | tinexog

* Return values

	sreturn local depvar		"`depvar'"
	sreturn local endo			"`endo'"
	sreturn local inexog		"`inexog'"
	sreturn local exexog		"`exexog'"
	sreturn local depvar_t		"`depvar'"			//  _t vars with ts or fv ops will replaced by temps by main program
	sreturn local endo_t		"`endo'"
	sreturn local inexog_t		"`inexog'"
	sreturn local exexog_t		"`exexog'"
	sreturn local wendo			"`wendo'"
	sreturn local wendo_t		"`wendo'"
	sreturn local sendo			"`sendo'"
	sreturn local sendo_t		"`sendo'"
	sreturn local csendo		"`csendo'"
	sreturn local csendo_t		"`csendo'"
	sreturn local tinexog		"`tinexog'"
	sreturn local tinexog_t		"`tinexog'"
	sreturn local N				"`e(N)'"
	sreturn local cons			"`cons'"
	sreturn local noconstant	"`noconstant'"
	sreturn local small			"`small'"
	sreturn local asis			"`asis'"
	sreturn local model			"`model'"
	sreturn local ivtitle		"`ivtitle'"

******* zeros by default or if not supported  ********
	sreturn local dofminus		=0

end			//  end parse_ivprobit

*******************************************************************************************

program define vorder, rclass
	version 11.2
	syntax , vlist1(string) vlist2(string)
	
* Takes vlist1 and puts it order as it appears in vlist2
* vlist1 is subset of vlist2

	foreach vn2 in `vlist2' {							//  loop through sorted list
		local pos   : list posof `"`vn2'"' in vlist1
		if `pos' {
			local vn1    : word `pos' of `vlist1'
			local sortedlist	"`sortedlist' `vn1'"
		}
	}
	local sortedlist		: list clean sortedlist	
	return local varlist	"`sortedlist'"
	
end		//  end vorder

************************************************************************************************

program define clean_varlist, rclass
	version 11.2
	syntax [if] [aw fw pw iw] [ , vlist(string) vlist_t(string) NOConstant ]

* `if' macro will be `if touse'

* Takes varlist of original vars and varlist of corresponding tempvars
* Returns varlists with collinears and zeroed out removed from both

	qui weakiv_rmcollright (`vlist_t') `if' [`weight' `exp'], `noconstant'
	local nvars	  : word count `vlist'

	if `nvars'>0 {			//  vlist is non-empty, so process	
		local todrop "`r(dropped)'"
		local templist
		local templist_t
		forvalues i=1/`nvars' {
			local vn    : word `i' of `vlist'
			local vn_t  : word `i' of `vlist_t'
			local pos   : list posof `"`vn_t'"' in todrop
			if `pos'==0 {
				local templist   "`templist'   `vn'"
				local templist_t "`templist_t' `vn_t'"
			}
		}
		local vlist_c	: list clean templist
		local vlist_c_t	: list clean templist_t
	}
	else {					//  vlist is empty, so return list with dups dropped
		local vlist_c_t "`r(varlist)'"
	}
	local nvars_c	: word count `vlist_c_t'

	return local vlist_c		"`vlist_c'"
	return local vlist_c_t	"`vlist_c_t'"
	return scalar nvars_c	=`nvars_c'

end			//  end clean_varlist

******************************************************************

program define weakiv_replay, eclass
	version 11.2
	cap noi syntax [,											///
			replay												///	<option ignored - here to enable auto option checking>
			/* estusewald(name) */								/// <currently not supported for replay>
			/* displaywald */									/// <currently not supported for replay>
			/* estadd */										/// <currently not supported for replay>
			project(string)										///
			project2(varlist fv ts min=2 max=2)					///
			LEVELlist(numlist min=0 max=3)						/// for plots only - doesn't affect estimation
			arlevel(numlist min=1 max=1)						///
			jlevel(numlist min=1 max=1)							///
			kjlevel(numlist min=1 max=1)						/// allow only 1 kjlevel in replay mode (can't change weights on K/J)
			waldlevel(numlist min=1 max=1)						/// illegal option - capture it
			klevel(numlist min=1 max=1)							/// illegal option - capture it
			clrlevel(numlist min=1 max=1)						/// illegal option - capture it
			gammalevel(numlist min=1 max=1)						///
			graph(string)										///
			graphxrange(numlist ascending min=2 max=2)			///
			graphopt(string asis)								///
			CONTOURonly SURFACEonly								///
			contouropt(string asis) surfaceopt(string asis)		///
		]

* General checks
	if _rc~=0 {
di as err "weakiv replay error: " _c
		error 198
	}
	if `"`e(cmd)'"' != "weakiv"  {
		error 301
	}

* Flag to indicate need to construct new CIs
* Triggered by setting new test levels
	local newci			=0

**************** Set and check test levels ************************
* Default test level.  Can be up to 3.
	if "`levellist'"=="" {							//  not provided, use saved default level and list
		local level		"`e(level)'"
		local levellist	"`e(levellist)'"
	}
	else {
		local newci			=1						//  Need to construct new CIs
		tokenize `levellist'						//  order is provided
		local level		"`1'"						//  first level provided is default
	}
* AR, KJ and J levels - can be set separately
	foreach stat in ar kj j {
		if "``stat'level'"=="" {
			local `stat'_level	"`level'"			//  not specified, use default
		}
		else {
			local newci			=1					//  Need to construct new CIs
			local `stat'_level	"``stat'level'"		//  use level provided
		}
	}
* Check legality
	local check "`levellist' `ar_level' `kj_level' `j_level'"
	foreach lev of local check {					//  check legality
		if `lev' < 10.00 | `lev' > 99.99 {			//  Stata legal levels limits
di as err "error - illegal test level `lev'"
			exit 198
		}
	}
	if "`gammalevel'" == "" {
		local gamma_level = 5 
	}
	else if	inlist(`gammalevel', 1, 5, 10, 15, 20) == 0 {
di as err "error - gamma is out of range - need to calculate it" // gamma_level not in a_min.csv
		exit 198
	}
	else {
		local gamma_level = `gammalevel'
	}
* Rest are default (parameter-only tests) and must be the same; can't be set separately by user.
	local k_level		"`level'"
	local clr_level		"`level'"
	local wald_level	"`level'"
	if "`klevel'`clrlevel'`waldlevel'" ~= "" {
di as err "illegal option: test level for K, CLR and Wald cannot be set separately"
di as err "use -level(.)- option to set test level for these parameter-only tests"
		exit 198
	}
	local kwt		= e(kwt)
	local kjk_level = 100 * (1 - (1 - sqrt(1-4*`kwt'*(1-`kwt')*(1-`kj_level'/100)))/(2*(1-`kwt')))
	local kjj_level = 100 * (1 - (1 - sqrt(1-4*`kwt'*(1-`kwt')*(1-`kj_level'/100)))/(2*`kwt'))

***************** End levels checks *****************************

**************** Prepare macros and matrices **********************

	if `newci' | "`project'`project2'`graph'"~="" {

* General prep if new CIs or graphs required
		local testlist		"`e(testlist)'"
		local citestlist	"`e(citestlist)'"
		local ptestlist		"`e(ptestlist)'"
		tempname			wbeta var_wbeta
		mat `wbeta'			=e(wbeta)
		mat `var_wbeta'		=e(var_wbeta)

* New CIs and projections require grid; exit if not present
		if ~e(grid) {
di as err "error: missing saved grid e(citable)"
			exit 1000
		}
* Grid will reside in Mata in a tempname called `citable'.
* Names of columns will be in a macro `citable_cnames'.
* Full CI table will not reside in Stata because may be too large for Stata matrix limit.
* Large grids may be split across multiple saved e(.) matrices;
* if so, will need to loop through and append.
* e(citblocks) indicates how many blocks the CI table is split across.
* e(citblocks)=1 means it is in one matrix called e(citable).
* e(citblocks)>1 means it's split across e(citable_1), e(citable_2), etc.
		tempname citable
		if e(citblocks)==1 {
			mata: `citable' = st_matrix("e(citable)")
			local citable_cnames	: colnames e(citable)
		}
		else {
			mata: `citable' = st_matrix("e(citable_1)")				//  initialize
			forvalues i=2/`e(citblocks)' {
				mata: `citable' = `citable' \ st_matrix("e(citable_`i')")
			}
			local citable_cnames	: colnames e(citable_1)			
		}
		local matadroplist	"`citable'"
	}

***************** Construct new CIs *****************************

	if `newci' {

		get_ci_from_table,				///
			testlist(`citestlist')		///
			citable(`citable')			///
			cnames(`citable_cnames')	///
			ar_level(`ar_level')		///
			k_level(`k_level')			///
			j_level(`j_level')			///
			kj_level(`kj_level')		///
			clr_level(`clr_level')

		foreach testname in `citestlist' {
			local `testname'_cset "`r(`testname'_cset)'"
		}
* Also get and save Wald CI as local macro
		get_ci_from_vcv,				///
			wbeta(`wbeta')				///
			var_wbeta(`var_wbeta')		///
			wald_level(`wald_level')	///
			vnum(1)						//  default vnum is 1 but provide anyway
		local wald_cset	"`r(wald_cset)'"

* And replace existing CIs with new ones
* along with test levels
		ereturn local	wald_cset			"`wald_cset'"
		ereturn local	ar_cset				"`ar_cset'"
		ereturn scalar	wald_level			=`wald_level'
		ereturn scalar	ar_level			=`ar_level'
		if e(overid) {
			ereturn local	kj_cset			"`kj_cset'"
			ereturn local	j_cset			"`j_cset'"
			ereturn local	k_cset			"`k_cset'"
			ereturn local	lc_2sls_cset		"`lc_2sls_cset'"
			ereturn local	clr_cset		"`clr_cset'"
			ereturn scalar	kjj_level		=`kjj_level'
			ereturn scalar	kjk_level		=`kjk_level'
			ereturn scalar	kj_level		=`kj_level'
			ereturn scalar	j_level			=`j_level'
			ereturn scalar	k_level			=`k_level'
			ereturn scalar	clr_level		=`clr_level'
		}
	}
	
***************** End new CIs ***********************************

************** 1-D projection-based inference *******************
	if "`project'"~="" {

		if e(wendo_ct)==1 {
di as err "error - projection-based inference available for 2 or more weakly-identified endogenous only"
			exit 198
		}
		if ~e(grid) {
di as err "error - projection-based inference available only if grid used in estimation"
			exit 198
		}

		local wendo			"`e(wendo)'"
		if "`project'"=="_all" {										//  projection-based inference for all weak endog
			local pwendo	"`wendo'"
		}
		else {
			local pwendo	"`project'"									//  May have factor variables or ts variables, so fvexpand needed
			fvexpand `pwendo' if e(sample)								//  Need to limit to original sample so that correct specific list created
			local pwendo	"`r(varlist)'"
			local pwendo	: subinstr local pwendo "bn." ".", all		//  strip out base notation
			local pwendo	: subinstr local pwendo "b." ".", all		//  strip out base notation
			local pwendo	: subinstr local pwendo "o." ".", all		//  strip out omitted notation
			local pwendo	: list clean pwendo
			local check		: list pwendo - wendo						//  and check legality here
			local check		: word count `check'
			if `check' > 0 {
di as err "syntax error - variable listed in project(.) but not in endogenous"
				exit 198
			}
		}
		vorder, vlist1(`pwendo') vlist2(`wendo')						//  put pwendo in order to match wendo
		local pwendo	"`r(varlist)'"
		local npwendo	: word count `pwendo'

		tempname m														//  Stata matrix used to store saved e(.) if they exist
		local points		"`e(points)'"
		local gridpoints	"`e(gridpoints)'"

		foreach vname of local pwendo {									//  loop through all vars to project
		display "`vname'"
			local vnum			: list posof "`vname'" in wendo
			local pwendo_nlist	"`pwendo_nlist' `vnum'"
			
			tempname p`vnum'citable										//  name used for Mata matrix

			mat `m' = e(p`vnum'citable)									//  may be missing

			if `newci' | `m'[1,1]==. {									//  missing or needs to be created, so create,
																		//  put into mata and also save it in e(.) if not too big
				construct_pcitable,					///
					vnum(`vnum')					///
					testlist(`ptestlist')			///
					citable(`citable')				/// if wald is in ptestlist, test will be projection-based
					cnames(`citable_cnames')		///
					pcitable(`p`vnum'citable')		///
					points(`points')				///
					gridpoints(`gridpoints')		///
					ar_level(`ar_level')			///
					k_level(`k_level')				///
					j_level(`j_level')				///
					kj_level(`kj_level')			///
					clr_level(`clr_level')			///
					wald_level(`wald_level')

				local p`vnum'citable_cnames			"`r(cnames)'"
				mata: st_numscalar("r(rows)",rows(`p`vnum'citable'))
				if r(rows) <= 32767 {									//  can be saved as e(matrix)
					mata: st_matrix("`m'",`p`vnum'citable')
					mat colnames `m'				= `p`vnum'citable_cnames'
					ereturn mat p`vnum'citable		= `m'
				}
			}
			else {														//  not missing
				mata: `p`vnum'citable' = st_matrix("`m'")				//  so put into Mata under correct name
				local p`vnum'citable_cnames	: colnames `m'				//  and save cnames
			}

			get_ci_from_table,						///
				testlist(`ptestlist')				/// if wald is in list, CI will be projection-based
				citable(`p`vnum'citable')			/// pass the projection-based table for variable `vnum'
				cnames(`p`vnum'citable_cnames')		///
				hasrejections						//  projection-based tables are 1/0 rejection indicators

			local p`vnum'_vname		"`vname'"
			foreach tname in `ptestlist' {
				ereturn local p`vnum'_`tname'_cset	"`r(`tname'_cset)'"
			}
				* Also get and save Wald CI as local macro
			get_ci_from_vcv,				///
				wbeta(`wbeta')				///
				var_wbeta(`var_wbeta')		///
				wald_level(`wald_level')	///
				vnum(`vnum')		
			local p`vnum'_wald_cset	"`r(wald_cset)'"
			* use Wald's cset instead	

			
			local matadroplist		"`matadroplist' `p`vnum'citable'"
		}
		local pwendo_nlist	: list clean pwendo_nlist			//  get rid of extra spaces etc.
		ereturn local pwendo		"`pwendo'"
		ereturn local pwendo_nlist	"`pwendo_nlist'"
		ereturn scalar pwendo_ct	=`npwendo'

	}

***************** End 1-D projections ***********************************

************** 2-D projection-based inference ***************************

	if "`project2'`e(pwendo2)'"~="" {

		if e(wendo_ct)<=2 {
di as err "error - 2-D projection-based inference available for 3 or more weakly-identified endogenous only"
			exit 198
		}

		if ~e(grid) {
di as err "error - projection-based inference available only if grid used in estimation"
			exit 198
		}

		local wendo		"`e(wendo)'"
		local pwendo2	"`project2'"								//  May have factor variables or ts variables, so fvexpand needed
		if "`pwendo2'"=="" {
			local pwendo2	"`e(pwendo2)'"
		}
		fvexpand `pwendo2' if e(sample)								//  Need to limit to original sample so that correct specific list created
		local pwendo2	"`r(varlist)'"
		local pwendo2	: subinstr local pwendo2 "bn." ".", all		//  strip out base notation
		local pwendo2	: subinstr local pwendo2 "b." ".", all		//  strip out base notation
		local pwendo2	: subinstr local pwendo2 "o." ".", all		//  strip out omitted notation
		local pwendo2	: list clean pwendo2
		local check		: list pwendo2 - wendo						//  and check legality here
		local check		: word count `check'
		if `check' > 0 {
di as err "syntax error - variable listed in project2(.) but not in endogenous"
			exit 198
		}

		tempname m vnums											//  m used for temp Stata storage of e(.) matrix
		tempname pcitable2											//  name of Mata matrix
		local points		"`e(points)'"
		local gridpoints	"`e(gridpoints)'"

* Check legal graph
		local badgraphs		: list graph - ptestlist
		local check			: word count `badgraphs'
		if `check' > 0 {
di as err "syntax error - illegal graph `badgraphs'"
			exit 198
		}

		tokenize `pwendo2'
		local vname1		"`1'"
		local vname2		"`2'"
		local vnum1			: list posof "`vname1'" in wendo
		local vnum2			: list posof "`vname2'" in wendo
		mat `vnums'			= `vnum1', `vnum2'

		mat `m' = e(p`vnum1'`vnum2'citable)				//  may be missing

		if `newci' | `m'[1,1]==. {						//  it needs to be created or is missing, so create
														//  put in Mata and also and save in e(.) if not too large
			construct_pcitable2,						///
				vnums(`vnums')							///
				testlist(`ptestlist')					///
				citable(`citable')						///
				cnames(`citable_cnames')				///
				pcitable(`pcitable2')					///
				points(`points')						///
				gridpoints(`gridpoints')				///
				ar_level(`ar_level')					///
				k_level(`k_level')						///
				j_level(`j_level')						///
				kj_level(`kj_level')					///
				clr_level(`clr_level')					///
				wald_level(`wald_level')

			local pcitable2_cnames					"`r(cnames)'"
			mata: st_numscalar("r(rows)",rows(`pcitable2'))
			if r(rows) <= 32767 {									//  can be saved as e(matrix)
				mata: st_matrix("`m'",`pcitable2')
				mat colnames `m'					= `pcitable2_cnames'
				ereturn mat p`vnum1'`vnum2'citable	= `m'
			}
		}
		else {														//  not missing
			mata: `pcitable2' = st_matrix("`m'")					//  so put into Mata
			local pcitable2_cnames		: colnames `m'				//  and save cnames
		}

		ereturn local pwendo2		"`pwendo2'"

		local matadroplist			"`matadroplist' `pcitable2'"
	}

***************** End 2-D projections ***********************************

*********************** DISPLAY TABLES ******************

	display_output

********************* 1-D and 2-D graphs ***********************

	if "`graph'" ~= "" {

		if e(wendo_ct)==1 {							//  standard inference for 1 endog
			do_graphs,								///
				graph(`graph')						///
				citable(`citable')					///
				cnames(`citable_cnames')			///
				graphxrange(`graphxrange')			///
				graphopt(`graphopt')				///
				levellist(`levellist')
		}
		else if e(wendo_ct)==2 {					//  standard inference for 2 endog
			do_graphs2,								///
				graph(`graph')						///
				citable(`citable')					///
				cnames(`citable_cnames')			///
				`contouronly'						///
				`surfaceonly'						///
				contouropt(`contouropt')			///
				surfaceopt(`surfaceopt')			///
				graphopt(`graphopt')				///
				levellist(`levellist')				///
				level(`level')						/// Default level
				arlevel(`ar_level')					///
				klevel(`k_level')					///
				jlevel(`j_level')					///
				kjlevel(`kj_level')					///
				clrlevel(`clr_level')				///
				waldlevel(`wald_level')
		}
		else if "`project2'"~="" {					//  projection-based inference using provided varlist
			do_graphs2,								///
				graph(`graph')						///
				citable(`pcitable2')				/// use pcitable2
				cnames(`pcitable2_cnames')			///
				hasrejections						/// table has 1/0 rejection indicators rather than p-vals
				contouronly							///
				contouropt(scatter `contouropt')	/// add scatter to contouropt
				surfaceopt(`surfaceopt')			///
				graphopt(`graphopt')				///
				levellist(`levellist')				///
				level(`level')						/// Default level
				arlevel(`ar_level')					///
				klevel(`k_level')					///
				jlevel(`j_level')					///
				kjlevel(`kj_level')					///
				clrlevel(`clr_level')				///
				waldlevel(`wald_level')
		}
		else if "`e(pwendo2)'"~="" {				//  projection-based inference using previous varlist
			do_graphs2,								///
				graph(`graph')						///
				citable(`pcitable2')				/// use pcitable2
				cnames(`pcitable2_cnames')			///
				hasrejections						/// table has 1/0 rejection indicators rather than p-vals
				contouronly							///
				contouropt(scatter `contouropt')	/// add scatter to contouropt
				surfaceopt(`surfaceopt')			///
				graphopt(`graphopt')				///
				levellist(`levellist')				///
				level(`level')						/// Default level
				arlevel(`ar_level')					///
				klevel(`k_level')					///
				jlevel(`j_level')					///
				kjlevel(`kj_level')					///
				clrlevel(`clr_level')				///
				waldlevel(`wald_level')
		}
		else {
di as err "warning - graph option valid only for 1 or 2 weakly-identified coeffs,"
di as err "or for 2-variable projection-based inference; graph option ignored"
		}
	}

******************* End 1-D and 2-D graphs ***********************

******************* Clean up in Mata *****************************
	cap mata: mata drop `matadroplist'
******************************************************************

end		//  end weakiv_replay

***********************************************************************************
program define construct_grid, rclass
	version 11.2
	syntax [,									///
				gridlist(string)				///
				gridpoints(numlist missingok)	///
				gridmin(numlist missingok)		///
				gridmax(numlist missingok)		///
				gridmult(real 0)				///
				nwendog(integer 0)				///
				wbeta(name local)				///
				var_wbeta(name local)			///
				wald_level(real 0)				///
				usecue(integer 0)				///
			]

* Construct grid
* set up points, grid, etc. as single strings
	local points		=1								//  has total number of points in grid = gridpoints1 x gridpoints2 x ...
	tokenize "`gridlist'", parse("|")					//  gridlist if provided will look like "... , ... , ..."
														//  and after tokenizing will be 1=... 2=, 3=... 4=, 5=... etc.
														//  so odd number macros will have tokens
	forvalues i=1/`nwendog' {
		local b			=`wbeta'[1,`i']					//  endog #i
		local se		=sqrt(`var_wbeta'[`i',`i'])
		local gridpos	= 2*`i'-1
		local pointsi	: word `i' of `gridpoints'
		local gridmini	: word `i' of `gridmin'
		local gridmaxi	: word `i' of `gridmax'
		if "`gridmini'"~="." & "`gridmaxi'"~="." {		//  if min and max specified, use, otherwise will default to gridmult
			local gridlimits	"`gridmini' `gridmaxi'"
		}
		else {
			local gridlimits	""
		}
		get_gridlist,									///
			grid(``gridpos'')							/// gridlist if provided; may be numlist
			gridlimits(`gridlimits')					///
			gridmult(`gridmult')						///
			points(`pointsi')							///
			wbeta(`b')									///
			betase(`se')								///
			wald_level(`wald_level')					///
			usecue(`usecue')							//  option to incude CUE in grid points
		local gridmini	: di %8.0g `r(gridmin)'
		local gridmaxi	: di %8.0g `r(gridmax)'
		local pointsi	"`r(points)'"

		if `i'==1 {
			local newgridlist		"`r(gridlist)'"
			local grid_descript		"[`gridmini',`gridmaxi']"
			local points_descript	"`pointsi'"
		}
		else {
			local newgridlist		"`newgridlist' | `r(gridlist)'"	//  NOTE LIST IS IN REVERSE ORDER - REQUIRED BY RECURSION CODE
			local grid_descript		"`grid_descript', [`gridmini',`gridmaxi']"
			local points_descript	"`points_descript' x `pointsi'"
		}
		local points				=`points' * `pointsi'
		local newgridpoints			"`newgridpoints' `pointsi'"		//  newgridpoints will overwrite defaults etc.
	}																//  gridlist now looks like "... , ... , ... " etc.
																	//  i.e. explicit numlists separated by comma
	local gridpoints				: list clean newgridpoints		//  update gridpoints

	return local gridlist			"`newgridlist'"
	return local grid_descript		"`grid_descript'"
	return local points_descript	"`points_descript'"
	return local gridpoints			"`gridpoints'"					//  updated gridpoints that match grid; overrides any default
	return local points				"`points'"						//  total number of gridpoints

end		//  end construct_grid



program define get_gridlist, rclass
	version 11.2
	syntax [,								///
				grid(numlist sort)			///
				gridlimits(numlist)			/// (lower uppper) or empty
				gridmult(real 0)			///
				points(integer 0)			///
				wbeta(real 0)				///
				betase(real 0)				///
				wald_level(real 0)			///
				usecue(integer 0)			///
			]

	local gridinput : length local grid
	if `gridinput'==0 {						//  No list of grid entries provided
		local numlimits : word count `gridlimits'
		if `numlimits'==2 {
			local gridmin : word 1 of `gridlimits'
			local gridmax : word 2 of `gridlimits'							
		}
		else if `numlimits'==0 {
* default grid radius is twice that of the confidence interval from the original estimation
				local alpha = 1-`wald_level'/100
				local gridradius = abs(`gridmult') * `betase' * invnormal(1-`alpha'/2)
* create grid for confidence sets
				local gridmin = `wbeta' - `gridradius'
				local gridmax = `wbeta' + `gridradius'
		}
		else {
* shouldn't reach this point - should be trapped when options are parsed
			di as err "error - misspecified grid limits"
			exit 198
		}
		if `points'>1 {
			local gridinterval = .999999999*(`gridmax'-`gridmin')/(`points'-1)	// multiply by .999999999 so the interval doesnt take up end points in numlist
			local grid "`gridmin'(`gridinterval')`gridmax'"						//  grid is in numlist form
			if `usecue' & `numlimits'==2	{									/// add CUE to grid
				//& `wbeta'>`gridmin' & `wbeta'<`gridmax' { //always add CUE point //  ...but only if an interior point
				local grid		"`grid' `wbeta'"								//  wbeta is CUE beta
				local points	=`points'+1										//  and add 1 to points
			}
			numlist "`grid'", sort	 								            //  sort required in case CUE beta appended at end
			local gridlist	"`r(numlist)'"										//  gridlist is actual list of #s to search over
		}
		else if `points' == 1 & `gridmax' == `gridmin' {								// special case of 1 gridpoint because min=max
			local gridlist	"`gridmin'"											//  in which case it's just the Wald beta		
		}
		else {																	//  special case of 1 gridpoint in this dimension
			local gridlist	"`wbeta'"											//  in which case it's just the Wald beta
			local gridmin	= `wbeta'
			local gridmax	= `wbeta'
		}
	}
	else {													//  grid is user-provided numlist of grid entries-CHANGE-grid is outdated?
		numlist "`grid'", sort
		local gridlist "`r(numlist)'"						//  gridlist is actual list of #s to search over
		local points : word count `gridlist'				//  and count points in it
		local gridmin : word 1 of `gridlist'
		local gridmax : word `points' of `gridlist'
		if `usecue'											///  add CUE to grid
			& `wbeta'>`gridmin' & `wbeta'<`gridmax' {		//  ...but only if an interior point
			local grid		"`grid' `wbeta'"				//  wbeta is CUE beta
			numlist "`grid'", sort							//  sort required becuase CUE beta appended at end
			local points	=`points'+1						//  and add 1 to points
		}
	}

	return local	gridlist	"`gridlist'"
	return scalar	points		=`points'
	return scalar	gridmin		=`gridmin'
	return scalar	gridmax		=`gridmax'

end		//  end get_gridlist

***********************************************************************************


program define computecrossprods, rclass
	version 11.2
	syntax [ ,										///
			touse(varname)							///
			wtexp(string)							///
			exexog(varlist)							///
			wendo(varlist)							///
			other(varlist)							/// other endogenous, either strongly-identified or not in wendo subset
			depvar(varname)							///
			]

* y is depvar, z is exexog, x1 is weakly identified (wendo), x2 is other endogenous
	tempname AA zz x2z x1x1 x2x2 x1x2 zx1 zx2 zy x1y x2y yy

	local nexexog	: word count `exexog'
	local nwendog	: word count `wendo'
	local nother	: word count `other'

	qui mat accum `AA'  = `exexog' `wendo' `other' `depvar' if `touse' `wtexp', nocons
	mat `zz'	= `AA'[1..`nexexog',1..`nexexog']
	mat `x1x1'	= `AA'[`nexexog'+1..`nexexog'+`nwendog',`nexexog'+1..`nexexog'+`nwendog']
	mat `zx1'	= `AA'[1..`nexexog',`nexexog'+1..`nexexog'+`nwendog']
	mat `x1y'	= `AA'[`nexexog'+1..`nexexog'+`nwendog',`nexexog'+`nwendog'+`nother'+1]
	mat `zy'	= `AA'[1..`nexexog',`nexexog'+`nwendog'+`nother'+1]
	mat `yy'	= `AA'[`nexexog'+`nwendog'+`nother'+1,`nexexog'+`nwendog'+`nother'+1]
	return mat zz	=`zz'
	return mat x1x1	=`x1x1'
	return mat zx1	=`zx1'
	return mat x1y	=`x1y'
	return mat zy	=`zy'
	return mat yy	=`yy'
			
	if `nother' {
		mat `x1x2'	= `AA'[`nexexog'+1..`nexexog'+`nwendog',`nexexog'+`nwendog'+1..`nexexog'+`nwendog'+`nother']
		mat `x2z'	= `AA'[`nexexog'+`nwendog'+1..`nexexog'+`nwendog'+`nother',1..`nexexog']
		mat `x2x2'	= `AA'[`nexexog'+`nwendog'+1..`nexexog'+`nwendog'+`nother',`nexexog'+`nwendog'+1..`nexexog'+`nwendog'+`nother']
		mat `zx2'	= `AA'[1..`nexexog',`nexexog'+`nwendog'+1..`nexexog'+`nwendog'+`nother']
		mat `x2y'	= `AA'[`nexexog'+`nwendog'+1..`nexexog'+`nwendog'+`nother',`nexexog'+`nwendog'+`nother'+1]
		return mat x1x2	=`x1x2'
		return mat x2z	=`x2z'
		return mat x2x2	=`x2x2'
		return mat zx2	=`zx2'
		return mat x2y	=`x2y'
	}

end		// end of computecrossprods

program define computematrices_iid, rclass
	version 11.2
	syntax [ ,										///
			cons(integer 0)							///
			touse(varname)							///
			wtexp(string)							///
			model(string)							///
			depvar(varname)							///
			endo(varlist)							///
			exexog(varlist)							///
			inexog(varlist)							///
			nendog(integer 0)						///
			nexexog(integer 0)						///
			ntinexog(integer 0)						///
			npartial(integer 0)						///
			nobs(real 0)							///
			dofminus(integer 0)						///
			ssa(real 0)								///
			lm(integer 0)							///
			llopt(string)							///
			ulopt(string)							///
			asis(string)							///
			]
	tempname pi_z bhat AA zz zzinv var_pi_z var_del del_z del_v ehat
	tempname syy see sxx sxy syv svv sve sxe
//change lm to md: ntinexog `ntinexog'"
local lm = 0
	local N = `nobs'
			
	if `cons' {													//  cons=1 if constant in model after partialling-out
		tempvar ones											//  cons=0 if no constant or constant has been partialled out
		qui gen byte `ones' = 1 if `touse'
	}
	else {
		local noconstant "noconstant"
	}

* RF estimations
* Accumulate pi_z matrix and list of RF residuals Vhat
	mata: `pi_z' = J(`nexexog',0,.)
	foreach var of varlist `endo' {
		tempvar vhat_`var'
		qui reg `var' `exexog' `inexog' if `touse' `wtexp', `noconstant'
		qui predict double `vhat_`var'' if `touse', resid
		local Vhat "`Vhat' `vhat_`var''"
		mata: `bhat' = st_matrix("e(b)")
		mata: `bhat' = `bhat'[| 1,1 \ .,`nexexog' |]
		mata: `bhat' = `bhat''
		mata: `pi_z' = `pi_z' , `bhat'
	}
	mata: st_matrix("r(`pi_z')",`pi_z')
	mat `pi_z'=r(`pi_z')
	mata: mata drop `bhat' `pi_z'

* Above as in ET paper p. 9 step 1 to obtain
	local df_r = e(df_r) - `npartial'							//  df_r needs to exclude #partialled-out vars
	local reg_df_r = e(df_r)									//  reg_df_r is used for recovering large-sample V

	if `lm' {													//  all of inexog will have been partialled out for LM method
		qui reg `depvar' `exexog' if `touse' `wtexp', noconstant
		qui predict double `ehat' if `touse', resid
		qui mat accum `AA' = `depvar' `ehat' `endo' `Vhat' if `touse' `wtexp', noconstant
		local rc1	=3
		local rc2	=3+`nendog'-1
		local rc3	=3+`nendog'
		local rc4	=3+2*`nendog'-1
		matrix `syy'	= `AA'[1,1]                       * 1/(`N'-`dofminus') * `ssa'
		matrix `see'	= `AA'[2,2]                       * 1/(`N'-`dofminus') * `ssa'
		matrix `sxx'	= `AA'[`rc1'..`rc2',`rc1'..`rc2'] * 1/(`N'-`dofminus') * `ssa'
		matrix `sxy'	= `AA'[`rc1'..`rc2',1..1]         * 1/(`N'-`dofminus') * `ssa'
		matrix `syv'	= `AA'[`rc3'..`rc4',1..1]         * 1/(`N'-`dofminus') * `ssa'
		matrix `svv'	= `AA'[`rc3'..`rc4',`rc3'..`rc4'] * 1/(`N'-`dofminus') * `ssa'
		matrix `sve'	= `AA'[`rc3'..`rc4',2..2]         * 1/(`N'-`dofminus') * `ssa'
*		matrix `sxe'	= `AA'[`rc1'..`rc2',2..2] * 1/(`N'-`dofminus') * `ssa'		//  same as sve
	}
	else {				
																//  need only svv for Wald/MD version
		qui mat accum `AA' = `Vhat' if `touse' `wtexp', noconstant
		mat `svv' = `AA'  * 1/(`N'-`dofminus') * `ssa'								//  so same dfn as with LM version
	}
	mata: `svv' = st_matrix("`svv'")
	qui mat accum `zz' = `exexog' `inexog' `ones' if `touse' `wtexp', noconstant
	mata: `zz'=st_matrix("`zz'")
	mata: `zzinv'=invsym(`zz')
	mata: `zzinv' = `zzinv'[| 1,1 \ `nexexog',`nexexog' |]
	mata: st_matrix("r(`zzinv')",`zzinv')
	mata: `var_pi_z' = `svv' # `zzinv' * 1/`ssa'									//  need large-sample version
	mata: st_matrix("r(`var_pi_z')",`var_pi_z')
	mat `var_pi_z'=r(`var_pi_z')
	mat `zzinv'=r(`zzinv')

	mata: mata drop `var_pi_z' `svv' `zz' `zzinv'

* Above as in ET paper, p. 9 step 1 to obtain.  Notation for var_pi_z in paper is Lambda_piz_piz.

* Below matches ET paper, p. 9 step 2 control function. W in paper is inexog here.
* Do not need to save coeff or variance of W.  Coeffs and variance match notation in paper.
* delta_z and delta_v are column vectors of coeffs on exexog Z and vhats, respectively.
* var_del is variance of delta_z ONLY, so dim is nexexog x nexexog
	if "`model'" == "ivtobit" {
		qui tobit `depvar' `exexog' `Vhat' `inexog' if `touse' `wtexp', `llopt' `ulopt'
	}
	else if "`model'" == "ivprobit" {
		qui probit `depvar' `exexog' `Vhat' `inexog' if `touse' `wtexp', `asis'
	}
	else {
		qui reg `depvar' `exexog' `Vhat' `inexog' if `touse' `wtexp', `noconstant'
	}
	mat `var_del'	= e(V)												//  recover large-sample V
	mat `var_del'	= `var_del'[1..`nexexog',1..`nexexog']				//  (df_r-#endog+#tinexog) because of inclusion of 
	mat `var_del'	= `var_del'											/// vhats in RF regression (#endog) and because vhats
							* ((`reg_df_r'-`nendog'+`ntinexog')/`N')	//  are zeros for any inexog vars included in tests
	mat `var_del'	= `var_del' * `N'/(`N'-`dofminus')					//  dofminus (large-sample) adjustment
	mat `bhat'		= e(b)
	mat `del_z'		= `bhat'[1...,1..`nexexog']							//  row vector
	mat `del_v'		= `bhat'[1...,`nexexog'+1..`nexexog'+`nendog']
	mat `var_pi_z'	= `var_pi_z'	* `ssa'								//  ssa is small-sample adjustment or 1
	mat `var_del'	= `var_del'		* `ssa'

	return mat var_pi_z	= `var_pi_z'
	return mat zzinv	= `zzinv'
	return mat pi_z		= `pi_z'
	return mat var_del	= `var_del'
	return mat del_z	= `del_z'
	return mat del_v	= `del_v'
	return mat svv		= `svv'

	if `lm' {
		return mat syy		= `syy'
		return mat see		= `see'
		return mat sxy		= `sxy'
		return mat sve		= `sve'
		return mat sxx		= `sxx'
	}
	
end		// end computematrices_iid


program define computematrices_robust, rclass
	version 11.2
	syntax [ ,										///
			touse(varname)							///
			wtexp(string)							///
			vceopt(string)							///
			depvar(varname)							///
			endo(varlist)							///
			exexog(varlist)							///
			nendog(integer 0)						///
			nexexog(integer 0)						///
			npartial(integer 0)						///
			nobs(real 0)							///
			dofminus(integer 0)						///
			ssa(real 0)								///
			lm(integer 0)							///
			]
timer on 5		
	tempname pi_z bhat uhat zz zzinv del_z var_pi_z var_del var_pidel_z
	tempname S S11 S12 S22
//change lm to md"
local lm = 0
	local N = `nobs'

	qui reg `depvar' `exexog' if `touse' `wtexp', nocons
	mat `bhat'=e(b)
	mat `del_z'=`bhat'[1...,1..`nexexog']						//  row vector
	qui predict double `uhat' if `touse', resid

* RF estimations
* Accumulate pi_z matrix and list of RF residuals Vhat
	mata: `pi_z' = J(`nexexog',0,.)
	foreach var of varlist `endo' {
		tempvar vhat_`var'
		qui reg `var' `exexog' if `touse' `wtexp', nocons
		qui predict double `vhat_`var'' if `touse', resid
		local Vhat "`Vhat' `vhat_`var''"
		mata: `bhat' = st_matrix("e(b)")
		mata: `bhat' = `bhat'[| 1,1 \ .,`nexexog' |]
		mata: `bhat' = `bhat''
		mata: `pi_z' = `pi_z' , `bhat'
	}

	if `lm' {
		cap avar (`depvar' `endo') (`exexog') if `touse' `wtexp', `vceopt' nocons dofminus(`dofminus')			
	}
	else {
		cap avar (`uhat' `Vhat') (`exexog') if `touse' `wtexp', `vceopt' nocons dofminus(`dofminus')
	}
	if _rc>0 {
		di as err "error - internal call to avar failed"
		exit _rc
	}

	mata: `S'=st_matrix("r(S)")
	mata: `S11'=`S'[| 1,1 \ `nexexog',`nexexog' |]
	mata: `S12'=`S'[| `nexexog'+1,1 \ rows(`S'),`nexexog' |]
	mata: `S22'=`S'[| `nexexog'+1, `nexexog'+1 \ rows(`S'),cols(`S') |]

	qui mat accum `zz' = `exexog' if `touse' `wtexp', nocons
	mata: `zz'=st_matrix("`zz'")
	mata: `zzinv'=invsym(`zz')
	tempname aux1 aux2
	mata: `var_del' = `N' * makesymmetric(`zzinv'*`S11'*`zzinv') * `ssa'		// ssa is small-sample adjustment or 1
	mata: `var_del'=`var_del'[| 1,1 \ `nexexog',`nexexog' |]
* Kronecker structure
	mata: `var_pi_z' = `N' * makesymmetric(I(`nendog')#`zzinv'*`S22'*I(`nendog')#`zzinv') * `ssa'
	mata: `var_pidel_z' = `N' * I(`nendog')#`zzinv'*`S12'*`zzinv' * `ssa'
	mata: st_matrix("r(`pi_z')",`pi_z')
	mata: st_matrix("r(`var_del')",`var_del')
	mata: st_matrix("r(`var_pi_z')",`var_pi_z')
	mata: st_matrix("r(`var_pidel_z')",`var_pidel_z')
	mata: st_matrix("r(`zzinv')",`zzinv')
	mat `zzinv' = r(`zzinv')
	mat `pi_z'=r(`pi_z')
	mat `var_del'=r(`var_del')
	mat `var_pi_z'=r(`var_pi_z')
	mat `var_pidel_z'=r(`var_pidel_z')

	mata: mata drop `zz' `zzinv' `S' `S11' `S12' `S22' `bhat'			// clean up Mata memory
	mata: mata drop `var_del' `var_pi_z'
	mata: mata drop `pi_z' `var_pidel_z'

	return mat del_z		= `del_z'
	return mat var_pi_z		= `var_pi_z'
	return mat zzinv		= `zzinv'
	return mat pi_z			= `pi_z'
	return mat var_del		= `var_del'
	return mat var_pidel_z	= `var_pidel_z'
timer off 5
end		// end computematrices_robust

program define construct_citable, rclass						//  recursive approach
	version 11.2
	syntax [,							///
				citable(name)			///						//  name of local to use for Mata object
				gridcols(string)		///
				iid(integer 0)			///
				closedform(integer 0)	///
				clrsims(integer -1)		///
				usegrid(integer 0)		///
				depvar(varname ts)		///
				wendo(varlist ts)		///
				sendo(varlist ts)		///
				exexog(varlist ts)		///
				inexog(varlist ts)		///
				touse(varname ts)		///
				wtexp(string)			///
				NOConstant				///
				nexexog(integer 0)		///
				nendog(integer 0)		///
				nwendog(integer 0)		///
				nsendog(integer 0)		///
				ncsendog(integer 0)		///
				invchi2_k_df(real 0)		///
				invchi2_1_df(real 0)		///
				overid(integer 0)		///
				alpha(real 0)			///
				gamma(real 0)			/// alpha and gamma are used to calculate the maximal distortion coverage
				kwt(real 0)				///
				nobs(real 0)			///
				gridlist(string)		///
				points(integer 0)		///
				wbeta(name local)		/// row vector
				var_wbeta(name local)	///
				var_pi_z(name local)	///
				zzinv(name local)	///
				iv_sbeta0(name local)	///
				pi2hat(name local)		///
				pi_z(name local)		///
				var_del(name local)		///
				del_z(name local)		///
				del_v(name local)		///
				var_pidel_z(name local)	///
				syy(name)				///
				see(name)				///
				sxy(name)				///
				sve(name)				///
				sxx(name)				///
				svv(name)				///
				lm(real 0)				///
				cuestrong(real 0)		///
				nexog(integer 0)		///
				zz(name)				///
				x1x1(name)				///
				x1x2(name)				///
				x2x2(name)				///
				zx1(name)				///
				zx2(name)				///
				x1y(name)				///
				x2y(name)				///
				zy(name)				///
				yy(name)				///
				depvar_t(varname)		/// following used for 2-step GMM
				wendo_t(varlist)		///
				sendo_t(varlist)		///
				sendo(string)			/// needed for column names in citable
				exexog_t(varlist)		///
				touse(varname)			///
				vceopt(string)			///
				wtexp(string)			///
				wvar(varname)			///
				wf(real 1)				///
				forcerobust(integer 0)	///
			]

timer on 4
* npd is flag set to 1 if npd matrices encountered
		local npd = 0

* compute a(gamma) that is needed for calculating lc_2sls or lc in compute_test and compute_pvals
		tempname o needle // used to store the string of a_min 
		mata: compute_a_min(`nendog',`nsendog',`nexexog',`alpha',`gamma',"`o'","`needle'")
		
		local a_min = r(a_min)
		local lc_crit = r(lc_crit)
		local a_min_p = r(a_min_p)
		local lc_crit_p = r(lc_crit_p)
* cnames = column names for grid
* leading columns in grid: nulls and strong betas
		forvalues i=1/`nwendog' {
			local cnames "`cnames' null`i'"				//  used for columns of CI table
		}
		if `nsendog' {
			local cnames "`cnames' `sendo'"				//  additional columns for strongly-IDed betas
		}

		local cnames	"`cnames' `gridcols'"
		local cnames	: list clean cnames
		local cnum		: list sizeof cnames			//  number of columns for grid
*quietly{ // printing many lines of outputs and timers to speed up the process		
		mata: `citable' = J(0,`cnum',0)				//  initialize grid; use Mata (no limits on grid size)
		_dots 0 0, title(Estimating confidence sets over `points' grid points)

		grid_recurse,								///
						gridcols(`gridcols')		///
						citable(`citable')			///
						gridlist(`gridlist')		///
						counter(0)					///
						iid(`iid')					///
						closedform(`closedform')	///
						clrsims(`clrsims')			///
						nexexog(`nexexog')			///
						nendog(`nendog')			///
						nwendog(`nwendog')			///
						nsendog(`nsendog')			///
						ncsendog(`ncsendog')		///
						a_min(`a_min')				///
						a_min_p(`a_min_p')				///
						invchi2_k_df(`invchi2_k_df')		///
						invchi2_1_df(`invchi2_1_df')		///
						lc_crit(`lc_crit')		///
						lc_crit_p(`lc_crit_p')		///
						overid(`overid')			///
						kwt(`kwt')					///
						nobs(`nobs')				///
						wbeta(`wbeta')				/// row vector
						var_wbeta(`var_wbeta')		///
						var_pi_z(`var_pi_z')		///
						zzinv(`zzinv')			///
						iv_sbeta0(`iv_sbeta0')		///
						pi2hat(`pi2hat')			///
						pi_z(`pi_z')				///
						var_del(`var_del')			///
						del_z(`del_z')				///
						del_v(`del_v')				///
						var_pidel_z(`var_pidel_z')	///
						syy(`syy')					///
						see(`see')					///
						sxy(`sxy')					///
						sve(`sve')					///
						sxx(`sxx')					///
						svv(`svv')					///
						lm(`lm')					///
						cuestrong(`cuestrong')		///
						nexog(`nexog')				///
						zz(`zz')					///
						x1x1(`x1x1')				///
						x1x2(`x1x2')				///
						x2x2(`x2x2')				///
						zx1(`zx1')					///
						zx2(`zx2')					///
						x1y(`x1y')					///
						x2y(`x2y')					///
						zy(`zy')					///
						yy(`yy')					///
						depvar_t(`depvar_t')		///
						wendo_t(`wendo_t')			///
						sendo_t(`sendo_t')			///
						exexog_t(`exexog_t')		///
						touse(`touse')				///
						vceopt(`vceopt')			///
						wtexp(`wtexp')				///
						wvar(`wvar')				///
						wf(`wf')					///
						forcerobust(`forcerobust')
//dis "end of quiet"						
*}
* Finish up
		return scalar npd		= `npd'					//  flag to indicate NPD matrices encountered
		return local cnames			"`cnames'"			//  col names for CI table
* If any LC tests are on the test lists, we calculate the distortion cutoff
	if strpos("`gridcols'", "lc") {
		tempname a_max a_diff_col a_col lc_sim oldseed m 		// locals used in both places
		tempname K_size J_size P_size K_1_size  pr_k_df pr_1_df 
		mata: `m'		= 100000
		mata: `oldseed'	= rseed()					//  save existing seed
		mata: rseed(12345)     						//  set seed (replicability)
* Calculate \tilde{a} which is the maximum of weight a(gamma) that solves K+a*S=chi2_k_df, and solve for gamma_tilde
* Then gamma_hat is the maximum of gamma_tilde and gamma
		if strpos("`gridcols'", "lc_2sls_r") | strpos("`gridcols'", "lc_r"){
	
			local a_diff_col: list posof "a_diff_f" in cnames
			mata: `a_col' = `citable'[.,`a_diff_col']
			mata: `a_max'=colmax(`a_col')
		
			local k_df		= `nendog' - `nsendog'
			local j_df		= `nexexog'-`nendog'
			// simulation of (1+a)*chi2_p + a*chi2_k-p
			mata: `K_size'=rchi2(`m',1,`k_df')
			if 	(`j_df' > 0) {					
				mata: `J_size'=rchi2(`m',1,`j_df')
			}
			else {
				mata: `J_size'=J(`m',1,0)
			}
			
			mata: `lc_sim'	= (1+`a_max')*`K_size' + `a_max'*`J_size'
			mata: `pr_k_df'	= sum(`lc_sim' :<= `invchi2_k_df')/`m'	
			
			// the simulated probability that linear comb of chi-p and chi-k-p less than `alpha' quantile of chi-p
				
			mata: st_numscalar("`pr_k_df'",`pr_k_df')	        //  put into Stata
			mata: mata drop `K_size' `J_size' `pr_k_df'		//  and drop temp Mata vars 
		
			local gamma_tilde = `alpha' - 100*`pr_k_df'			
			local gamma_hat = max(`gamma_tilde', `gamma')

			// gamma_tilde is defined s.t. prelim CS with coverage `alpha'-`gamma_tilde' are contained in the non-robust CS
			return scalar gamma_hat= `gamma_hat'
		}
		
		if strpos("`gridcols'", "lc_2slsp") | strpos("`gridcols'", "lcp") {
		* Repeat the above procedure for projection test distortion cutoff
			forvalues i=1/`nwendog' {
				local a_diff_col: list posof "a_diffp`i'" in cnames
				mata: `a_col' = `citable'[.,`a_diff_col']
				mata: `a_max'=colmax(`a_col')
				mata: `P_size'=rchi2(`m',1,1)
				mata: `K_1_size'=rchi2(`m',1,`nexexog'-1)

				mata: `lc_sim'	= (1+`a_max')*`P_size' + `a_max'*`K_1_size'
				mata: `pr_1_df'	= sum(`lc_sim' :<= `invchi2_1_df')/`m'	
				
				mata: st_numscalar("`pr_1_df'",`pr_1_df')	//  put into Stata
				mata: mata drop `P_size' `K_1_size' `pr_1_df' 
				
				local gamma_tilde = `alpha' - 100*`pr_1_df'			
				local gamma_hat = max(`gamma_tilde', `gamma')
			// gamma_tilde is defined s.t. prelim CS CS with coverage `alpha'-`gamma_tilde' are contained in the non-robust CS
				return scalar gamma_hat`i'= `gamma_hat'
			}
		}
		mata: rseed(`oldseed')	
		mata: mata drop `a_max' `a_col' `lc_sim' `oldseed' `m' 
	}
timer off 4
end		// end construct_citable



program grid_recurse, rclass
	syntax [,							///
				gridcols(string)		///
				citable(name)			///
				nullvec(string)			///
				gridlist(string)		///
				counter(integer 0)		///
				iid(integer 0)			///
				closedform(integer 0)	///
				clrsims(integer -1)		///
				nexexog(integer 0)		///
				nendog(integer 0)		///
				nwendog(integer 0)		///
				nsendog(integer 0)		///
				ncsendog(integer 0)		///
				a_min(real 0)			///
				a_min_p(real 0)			///
				invchi2_k_df(real 0)		///				
				invchi2_1_df(real 0)		///
				lc_crit(real 0)		///
				lc_crit_p(real 0)		///
				overid(integer 0)		///
				kwt(real 0)				///
				nobs(real 0)			///
				wbeta(name local)		/// row vector
				var_wbeta(name local)	///
				var_pi_z(name local)	///
				zzinv(name local)	///
				iv_sbeta0(name local)	///
				pi2hat(name local)		///
				pi_z(name local)		///
				var_del(name local)		///
				del_z(name local)		///
				del_v(name local)		///
				var_pidel_z(name local)	///
				syy(name)				///
				see(name)				///
				sxy(name)				///
				sve(name)				///
				sxx(name)				///
				svv(name)				///
				lm(real 0)				///
				cuestrong(real 0)		///
				nexog(integer 0)		///
				zz(name)				///
				x1x1(name)				///
				x1x2(name)				///
				x2x2(name)				///
				zx1(name)				///
				zx2(name)				///
				x1y(name)				///
				x2y(name)				///
				zy(name)				///
				yy(name)				///
				depvar_t(varname)		/// following used for 2-step GMM
				wendo_t(varlist)		///
				sendo_t(varlist)		///
				exexog_t(varlist)		///
				touse(varname)			///
				vceopt(string)			///
				wtexp(string)			///
				wvar(varname)			///
				wf(real 1)				///
				forcerobust(integer 0)	///
			]
			
timer clear
timer on 3
	tempname rk ar_p ar_chi2 ar_df k_p k_chi2 k_2sls lc_2sls lc_2sls_r lc lc_r k_df j_p j_chi2 j_df kj_p kj_chi2 ///
		clr_p clr_stat clr_df ar_r k_r j_r kj_dnr kj_r kj_p clr_r				///
		wald_p wald_chi2 wald_df wald_r
	tempname wgridnullvector gridnullvector sbeta
	tempname cirow a_diff

* npd is flag set to 1 if npd matrices encountered
	local npd = 0

	tokenize "`gridlist'", parse("|")
	local this			"`1'"				//  this gridlist, i.e., a numlist
	macro shift								//  the separator
	macro shift								//  `*' is now the remaining gridlists separated by commas
	local rest			"`*'"
	local rest			: list clean rest
	local moregrids		: length local rest


	foreach null in `this' {				//  loop through points of this gridlist
	
		local newnullvec		"`nullvec' `null'"

		if `moregrids' {
			grid_recurse,								///
							gridcols(`gridcols')		///
							citable(`citable')			///
							nullvec(`newnullvec')		///
							gridlist(`rest')			///
							counter(`counter')			///
							iid(`iid')					///
							closedform(`closedform')	///
							clrsims(`clrsims')			///
							nexexog(`nexexog')			///
							nendog(`nendog')			///
							nwendog(`nwendog')			///
							nsendog(`nsendog')			///
							ncsendog(`ncsendog')		///
							a_min(`a_min')   			///
							a_min_p(`a_min_p')   			///
							invchi2_k_df(`invchi2_k_df')		///
							invchi2_1_df(`invchi2_1_df')		///
							lc_crit(`lc_crit')		///
							lc_crit_p(`lc_crit_p')		///
							overid(`overid')			///
							kwt(`kwt')					///
							nobs(`nobs')				///
							wbeta(`wbeta')				/// row vector
							var_wbeta(`var_wbeta')		///
							var_pi_z(`var_pi_z')		///
							zzinv(`zzinv')			///
							iv_sbeta0(`iv_sbeta0')		///
							pi2hat(`pi2hat')			///
							pi_z(`pi_z')				///
							var_del(`var_del')			///
							del_z(`del_z')				///
							del_v(`del_v')				///
							var_pidel_z(`var_pidel_z')	///
							syy(`syy')					///
							see(`see')					///
							sxy(`sxy')					///
							sve(`sve')					///
							sxx(`sxx')					///
							svv(`svv')					///
							lm(`lm')					///
							cuestrong(`cuestrong')		///
							nexog(`nexog')				///
							zz(`zz')					///
							x1x1(`x1x1')				///
							x1x2(`x1x2')				///
							x2x2(`x2x2')				///
							zx1(`zx1')					///
							zx2(`zx2')					///
							x1y(`x1y')					///
							x2y(`x2y')					///
							zy(`zy')					///
							yy(`yy')					///
							depvar_t(`depvar_t')		///
							wendo_t(`wendo_t')			///
							sendo_t(`sendo_t')			///
							exexog_t(`exexog_t')		///
							touse(`touse')				///
							vceopt(`vceopt')			///
							wtexp(`wtexp')				///
							wvar(`wvar')				///
							wf(`wf')					///
							forcerobust(`forcerobust')
				local counter		"`r(counter)'"		//  new total for next call
				local npd			=max(`npd',r(npd))	//  promote to 1 if npd matrices encountered
		}
		else {											//  we've stopped recursing so test nulls in current gridlist `this' 
timer on 9
			local counter = `counter'+1					//  about to do tests; increment by 1
			_dots `counter' 0

			mata: `gridnullvector' = strtoreal(tokens("`newnullvec'"))			//  easiest way to put string into a matrix is via Mata
			mata: st_matrix("`wgridnullvector'", `gridnullvector')
			mat `gridnullvector'  = `wgridnullvector' 							//  So gridnull vector is in Mata and Stata
timer off 9
			if `nsendog'>0 {	
				get_strong_beta, /// IV estimator used for strong coeffs; also init beta for md2s or cue
						iv						///
						b0(`wgridnullvector')	///
						iv_sbeta0(`iv_sbeta0')	///
						pi2hat(`pi2hat')		///
						zz(`zz')				///
						depvar(`depvar_t')		///
							wendo(`wendo_t')		///
							sendo(`sendo_t')		///
							exexog(`exexog_t')		///
							touse(`touse')			///
							vceopt(`vceopt')		///
							wtexp(`wtexp')			///
							wvar(`wvar')			///
							wf(`wf')
							
				mat `sbeta' = r(sbeta)	

				if `iid' & `cuestrong' {
				
					get_strong_beta,			///
							liml			/// LIML, using CUE approach
							nobs(`nobs')		///
							b0(`wgridnullvector')	///
							sbeta(`sbeta')		/// 1st-step IV estimator for strong endog at specified null
							lm(`lm')		///
							depvar(`depvar_t')	///
							wendo(`wendo_t')	///
							sendo(`sendo_t')	///
							exexog(`exexog_t')	///
							touse(`touse')		///
							wtexp(`wtexp')		///
							traceonoff("off")		

							mat `sbeta' = r(sbeta)			//  new sbeta based on efficient LIML-MD						

				}


				if ~`iid' {
					if `cuestrong' {
						local s2method	"cue"
					}
					else {
						local s2method	"md2s"
					}
					get_strong_beta,							///
							`s2method'				/// 2-step GMM or CUE used for strong coeffs
							nobs(`nobs')			///
							lm(`lm')				///
							b0(`wgridnullvector')	///
							sbeta(`sbeta')			/// 1st-step IV estimator for strong endog at specified null
							zz(`zz')				///
							x1x2(`x1x2')			///
							zx1(`zx1')				///
							zx2(`zx2')				///
							zy(`zy')				///
							depvar(`depvar_t')		///
							wendo(`wendo_t')		///
							sendo(`sendo_t')		///
							exexog(`exexog_t')		///
							touse(`touse')			///
							vceopt(`vceopt')		///
							wtexp(`wtexp')			///
							wvar(`wvar')			///
							wf(`wf')				///
							traceonoff("off")
							
					mat `sbeta' = r(sbeta)						//  new sbeta based on efficient GMM (2-step or CUE)
				}

				mat `gridnullvector' = `wgridnullvector' , `sbeta'		// new gridnullvector is weak null followed by strong beta
				mata: `gridnullvector' = st_matrix("`gridnullvector'")	// and replace Mata version as well

			}

* calculate test stats

* Wald test. Only needed when either LC_2sls (lc_2sls_r as a flag)
* or LC_2sls projection test is performed (lc_2slsp as a flag)
* The Wald statistics are used for distortion cutoff.
timer on 10
		if  strpos("`gridcols'",  "lc") {
			if strpos("`gridcols'",  "lc_2sls_r") {
				local lc_col: list posof "lc_2sls_r" in gridcols
			}
			else if strpos("`gridcols'",  "lc_r") {
				local lc_col: list posof "lc_r" in gridcols
			}
			else {
				local lc_col = 0
			}

			mata: s_wald(							///
							`lc_col',			/// flag for whether wald_chi2 is needed
							"`var_wbeta'",			///
							"`wbeta'",				/// row vector
							"`wgridnullvector'"		/// rowvector
							)
			if `lc_col' >0 {				
				local wald_chi2		=r(wald_chi2)
				local npd			=max(`npd',r(npd))	//  promote to 1 if npd matrix ever encountered
			}
			tempname wald_chi2p
			mat `wald_chi2p' 	=r(wald_chi2p)			// row vector that stores Wald stat for projection test
		}
timer off 10
* Weak-ID-robust tests

			if `ncsendog' {										/// subset AR test; requires IID and linearity

* x1 is subset weakly identified (wendo), x2 complement (not in subset, not tested, coeffs obtained by LIML)
				mata: s_sliml(									///
										`nobs',					///
										"`zz'",					///
										"`x1x1'",				///
										"`x1x2'",				///
										"`x2x2'",				///
										"`zx1'",				///
										"`zx2'",				///
										"`x1y'",				///
										"`x2y'",				///
										"`zy'",					///
										"`yy'",					///
										"`wgridnullvector'",	/// rowvector
										`nexog',				/// L = #exexog + #inexog; needed for AR but not LIML beta
										0,						/// flag=1 => calculate beta, =0 => calc only lambda and ar stat
										`lm'					/// flag LM=0, MD=1; needed for AR but not LIML beta
									)
			}
			else if `iid' & ~`forcerobust' {					//  iid-based test formulae
				mata: compute_tests(							///
										`nobs',					///
										1,						/// 1=iid code, 0=robust code
										`lm',					///
										`nendog',				///
										`nexexog',				///
										`a_min',			/// weight in linear combination of K_2sls and J
										`a_min_p',			/// weight in linear combination of K_2sls and J for projection test
										`lc_crit',			/// critical value of the linear combination distribution
										`lc_crit_p',			/// critical value of the linear combination distribution
										"`gridcols'",			///
										"`del_z'",				/// row vector
										"`var_del'",			///
										"`pi_z'",				///
										"`var_pi_z'",			///
										"`zzinv'",			///
										"`var_pidel_z'",		///
										"`del_v'",				/// row vector
										"`wgridnullvector'",	/// row vector
										"`gridnullvector'",		/// row vector; first weak, then strong (if any)
										"`syy'",				/// actually scalar
										"`see'",				/// actually scalar
										"`sxy'",				/// COLUMN VECTOR
										"`sve'",				/// COLUMN VECTOR
										"`sxx'",				/// KxK matrix
										"`svv'"					/// KxK matrix
										)
			}
			else {												//  robust test formulae

				mata: compute_tests(							///
										`nobs',					///
										0,						/// 1=iid code, 0=robust code
										`lm',					///
										`nendog',				///
										`nexexog',				///
										`a_min',			/// weight in linear combination of K_2sls and J
										`a_min_p',			/// weight in linear combination of K_2sls and J for projection test
										`lc_crit',			/// critical value of the linear combination distribution
										`lc_crit_p',			/// critical value of the linear combination distribution
										"`gridcols'",			///
										"`del_z'",				/// row vector
										"`var_del'",			///
										"`pi_z'",				///
										"`var_pi_z'",			///
										"`zzinv'",			///
										"`var_pidel_z'",		///
										"`del_v'",				/// row vector
										"`wgridnullvector'",	/// row vector
										"`gridnullvector'"		/// row vector; first weak, then strong (if any)
										)
			}
			local npd		=max(`npd',r(npd))	//  promote to 1 if npd matrix ever encountered
			if strpos("`gridcols'", "ar_chi2") {
				local ar_chi2		=r(ar_chi2)
			}
			if strpos("`gridcols'", "k_chi2") {
				local k_chi2		=r(k_chi2)
			}
			if strpos("`gridcols'", "lc_2sls_r") { // use lc_2sls_r in case lc_2sls picks up the projection test statistics
				local k_2sls		=r(k_2sls)
				local lc_2sls		=r(lc_2sls)	
				local ar_chi2		=r(ar_chi2) // need k_2sls and ar_chi2 to calculate a_min	
				//dis "k_2sls is `k_2sls' lc_2sls is `lc_2sls' ar_chi2 is `ar_chi2'"	
			}
			if strpos("`gridcols'", "lc_r") { // use lc_2sls_r in case lc_2sls picks up the projection test statistics
				local k_chi2		=r(k_chi2)
				local lc			=r(lc)
				local ar_chi2		=r(ar_chi2) // need k_chi2 and ar_chi2 to calculate a_min		
			}
			if strpos("`gridcols'", "j_chi2") {
				local j_chi2		=r(j_chi2)
			}
			if strpos("`gridcols'", "clr_stat") {
				local clr_stat		=r(clr_stat)
			}
			if strpos("`gridcols'", "rk") {
				local rk			=r(rk)
			}
			if `nwendog' > 1 & strpos("`gridcols'", "lc_2slsp") {	
				tempname k_2slsp lc_2slsp
				mat `k_2slsp'		=r(k_2slsp)
				mat `lc_2slsp'		=r(lc_2slsp)
				local ar_chi2		=r(ar_chi2) // need k_2sls and ar_chi2 to calculate a_min	
			}
			
			if `nwendog' > 1 & strpos("`gridcols'", "lcp") {	
				tempname k_chi2p lcp
				mat `k_chi2p'		=r(k_chi2p)
				mat `lcp'			=r(lcp)
				*matlist `lcp'
				local ar_chi2		=r(ar_chi2) // need k_chi2 and ar_chi2 to calculate a_min	
			}
			if `nwendog' > 1 & strpos("`gridcols'", "k_2slsp") {	
				tempname k_2slsp 
				mat `k_2slsp'		=r(k_2slsp)
				*dis "matrix k_2slsp is"
				*matlist `k_2slsp'
			}
			if `nwendog' > 1 & regexm("`gridcols'", "kp[0-9]_r") {	
				tempname kp 
				mat `kp'		=r(k_chi2p)
				*dis "matrix kp is"
				*matlist `kp'
			}


* calculate test statistics, p-values, and rejection indicators from above matrices
			compute_pvals,					///
				gridcols(`gridcols')			///
				closedform(`closedform')	///
				clrsims(`clrsims')			///
				overid(`overid')			///
				iid(`iid')					///
				nexexog(`nexexog')			///
				nendog(`nendog')			///
				nsendog(`nsendog')			///
				ncsendog(`ncsendog')		///
				a_min(`a_min')			///
				a_min_p(`a_min_p')			///
				invchi2_k_df(`invchi2_k_df')		///
				invchi2_1_df(`invchi2_1_df')		///
				lc_crit(`lc_crit')	///
				lc_crit_p(`lc_crit_p')	///
				ar_chi2(`ar_chi2')			///
				k_chi2(`k_chi2')			///
				k_2sls(`k_2sls')			///
				lc_2sls(`lc_2sls')			///
				lc(`lc')			///
				j_chi2(`j_chi2')			///
				clr_stat(`clr_stat')		///
				wald_chi2(`wald_chi2')		///
				lc_2slsp(`lc_2slsp')			///
				lcp(`lcp')			///
				k_2slsp(`k_2slsp')			///
				kp(`kp')				///
				rk(`rk')					///
				kwt(`kwt')

			local wald_p		        =r(wald_p)
			if strpos("`gridcols'", "ar_p") {
				local ar_p			=r(ar_p)
			}
			if strpos("`gridcols'", "clr_p") {
				local clr_p			=r(clr_p)
			}
			if strpos("`gridcols'", "kj_p") {
				local kj_p			=r(kj_p)
			}
			if strpos("`gridcols'", " k_p") {
				local k_p			=r(k_p)
			}
			if strpos("`gridcols'", "lc_2sls_r") {
				local k_2sls_r			=r(k_2sls_r)
				local lc_2sls_r			=r(lc_2sls_r)
				
				local a_diff_f= (`invchi2_k_df'-`k_2sls')/`ar_chi2'*cond(`wald_chi2'>`invchi2_k_df',1,0)
				// record a_diff for each grid to calculate a_max at the end of grid recurse
			}
			if strpos("`gridcols'", "lc_r") {
				local lc_r			=r(lc_r)
				local a_diff_f= (`invchi2_k_df'-`k_chi2')/`ar_chi2'*cond(`wald_chi2'>`invchi2_k_df',1,0)
				// record a_diff for each grid to calculate a_max at the end of grid recurse

			}
			if strpos("`gridcols'", " j_p") {
				local j_p			=r(j_p)
			}
			if strpos("`gridcols'", "rk_p") {
				local rk_p			=r(rk_p)
			}
			
			// store the rejection indicator for LC_2sls projection tests in gridcols
			if `nwendog' > 1 & strpos("`gridcols'", "lc_2slsp") {

				forvalues i=1/`nwendog' {
					local k_2slsp`i'_r = r(k_2slsp`i'_r)
					local lc_2slsp`i'_r = r(lc_2slsp`i'_r)
					
					// and record a_diff for each projection test - need to return k_2slsp and calculate invchi2_1_df
					local a_diffp`i'= (`invchi2_1_df'-`k_2slsp'[1,`i'])/`ar_chi2'*cond(`wald_chi2p'[1,`i']>`invchi2_1_df',1,0)
				}		
			}
			// store the rejection indicator for LC projection tests in gridcols
			if `nwendog' > 1 & strpos("`gridcols'", "lcp") {

				forvalues i=1/`nwendog' {
					local kp`i'_r = r(kp`i'_r)
					local lcp`i'_r = r(lcp`i'_r)
					
					// and record a_diff for each projection test - need to return k_chi2p and calculate invchi2_1_df
					local a_diffp`i'= (`invchi2_1_df'-`k_chi2p'[1,`i'])/`ar_chi2'*cond(`wald_chi2p'[1,`i']>`invchi2_1_df',1,0)
				}		
			}
			
timer on 8

			local gridcols_temp ""
			foreach gc in `gridcols' {
				local gridcols_temp "`gridcols_temp' ``gc''"
				
			}
			// gridcols is a nested local macro, containing test stats locals.
			// save all test stats in a local first and directly convert to mata is much faster
			// add gridnullvector to the first column and a_diff the last column
//dis "gridcols_temp is `gridcols_temp'"
			mata: `cirow' = `gridnullvector', strtoreal(tokens(st_local("gridcols_temp")))

timer off 8
timer on 6
/*			mata: `cirow' = J(1,0,.)
			foreach gc in `gridcols' {
				mata: `cirow' = `cirow', ``gc''				//  construct grid row with test stats
			}
			mata: `cirow' = `gridnullvector', `cirow',`a_diff'		//  save grid null and strong beta along with test stats

*/
timer off 6
timer on 7
			mata: `citable' = `citable' \ `cirow'
			mata: mata drop `cirow' `gridnullvector'
timer off 7
		}	
	}

	return scalar npd		=`npd'
	return local counter	=`counter'
timer off 3
//timer list
timer clear
end // end of grid_recurse

program define construct_pcitable, rclass
	version 11.2
	syntax [,							///
				vnum(integer 0)			///
				testlist(string)		/// ar, k, j, etc.
				citable(name local)		/// name of Mata CI table (and also Stata matrix if it exists i.e. not too big)
				cnames(string)			///
				pcitable(name local)	/// name to be used for Mata matrix
				points(integer 0)		///
				gridpoints(numlist)		///
				ar_level(integer 0)		///
				k_level(integer 0)		///
				j_level(integer 0)		///
				kj_level(real 0)		///
				clr_level(integer 0)	///
				wald_level(integer 0)	///
			]

	local rlist "lc_2sls lc k_2sls k" // these test have rejection indicators
	local ptestlist: list testlist - rlist // make a list of tests that have p-vals
	foreach test of local ptestlist {
		local testcol		: list posof "`test'_p" in cnames
	 	local gridcols		"`gridcols' `testcol'"
	 	local testlevels	"`testlevels' ``test'_level'"
	}
	local lc_cols "" // make a list of rejection indicator columns so we avoid them in project_test
	foreach rejection of local rlist {
		local testcol		: list posof "`rejection'p`vnum'_r" in cnames
		if `testcol' > 0 {
			local lc_cols 	"`lc_cols' `testcol'"
		}
	}
	//dis "ptestlist is `ptestlist' testlist is `testlist' cnames is `cnames'"
	//dis "lc_cols is `lc_cols' gridcols is `gridcols'"
	tempname p											//  name to use for pointer
	mata: `p' = &`citable'								//  pointer to Mata matrix (CI table)

	mata: `pcitable' = project_test(`vnum', "`lc_cols'", `p', `points',"`gridpoints'", "`gridcols'", "`testlevels'")

	foreach tname of local testlist {					//  add _r to end of testname to get colname
		local ptcnames			"`ptcnames' `tname'_r"		// in project_test, all rejection indicators are added to the end
	}									// assume all tests with rejection indicators are in the end
	local ptcnames				"null`vnum' `ptcnames'"	//  and add null+number to front of list of colnames

	mata: mata drop `p'									//  clean up
	
	return local cnames		"`ptcnames'"


end		//  end construct_pcitable

program define construct_pcitable2, rclass
	version 11.2
	syntax [,							///
				vnums(name)				/// row vector with vnums
				testlist(string)		/// ar, k, j, etc.
				citable(name local)		/// name of Mata CI table (and also Stata matrix if it exists i.e. not too big)
				cnames(string)			///
				pcitable(name local)	/// name to be used for Mata matrix			
				points(integer 0)		///
				gridpoints(numlist)		///
				ar_level(integer 0)		///
				k_level(integer 0)		///
				j_level(integer 0)		///
				kj_level(real 0)		///
				clr_level(integer 0)	///
				wald_level(integer 0)	///
			]


	foreach test of local testlist {
		local testcol		: list posof "`test'_p" in cnames
	 	local gridcols		"`gridcols' `testcol'"
	 	local testlevels	"`testlevels' ``test'_level'"
	}

	tempname p															//  name to use for Mata pointer
	mata: `p' = &`citable'												//  pointer to Mata matrix (CI table)

	mata: `pcitable' = project_test2("`vnums'", `p', `points', "`gridpoints'", "`gridcols'", "`testlevels'")

	foreach tname of local testlist {									//  add _r to end of testname to get colname
		local ptcnames			"`ptcnames' `tname'_r"
	}
	local vnum1					=el(`vnums',1,1)
	local vnum2					=el(`vnums',1,2)
	local ptcnames				"null`vnum1' null`vnum2' `ptcnames'"	//  and add nulls to front of list of colnames

	mata: mata drop `p'													//  clean up

	return local cnames			"`ptcnames'"
	
end		//  end construct_pcitable2



version 11.2
mata:
real matrix collapse_citable(									///
							pointer p,							///
							string scalar lc_cols,			/// has columns number of lc_2sls_r, lc_r, k_2sls_r
							string scalar colsvec,				///
							string scalar levelsvec				///
							)
{
	

	lc_col			=strtoreal(tokens(lc_cols)) // 0 is the case that only AR test is listed - eventually do AR with rejection, too?
	gridcols		=strtoreal(tokens(colsvec))
	levels			=strtoreal(tokens(levelsvec))

	rtable			= (100*(*p)[.,gridcols]) :< (100 :- levels)
	if (lc_col[1,1]>0) {
		rtable			= (*p)[.,1], rtable, (*p)[., lc_col]
	}
	else {
		rtable			= (*p)[.,1], rtable
	}

	//  append column 1 with grid nulls and last column lc_2sls_r, if lc_2sls is included in citestlist
	smat1			= rowsum(rtable[.,2..cols(rtable)])
	if (rows(smat1)>1) {
		smat2			= smat1[(2::rows(smat1)),1]
		smat1			= smat1[(1::rows(smat1)-1),1]
		smat			= (smat1-smat2) :~= 0
		smat			= (1 \ smat) :| (smat \ 1) // this block of code is used to delete rows that are exactly the same as rows before and after
		rtable			= select(rtable,smat)
	}
	// if only one row of rtable, then keep the entire table

	return(rtable)
}
end

version 11.2
mata:
real matrix collapse_pcitable(									///
							pointer p,							///
							string scalar colsvec				///
							)
{
	
	gridcols		=strtoreal(tokens(colsvec))
	smat1			= rowsum((*p)[.,2..cols(*p)])

	if (rows(smat1)>1) {
		smat2			= smat1[(2::rows(smat1)),1]
		smat1			= smat1[(1::rows(smat1)-1),1]
		smat			= (smat1-smat2) :~= 0
		smat			= (1 \ smat) :| (smat \ 1)
		return(select((*p),smat))
	} 
	else { 	// if only one row of rtable, then keep the entire table
		return((*p))
	}	

}
end

program get_ci_from_table, rclass
	syntax [,							///
				testlist(string)		///
				citable(name local)		///
				cnames(string)			///
				hasrejections			///
				ar_level(integer 0)		///
				k_level(integer 0)		///
				j_level(integer 0)		///
				kj_level(real 0)		///
				clr_level(integer 0)	///
				wald_level(integer 0)	///
			]

* Macro `citable' is name of Mata matrix with table of either p-values or rejections.
* Handling depends on whether table arrives with p-values (main CI table) or
* rejections (projection-based CI table).  If p-values, need to create rejections table.
* In both cases, rejections table is then collapsed in Mata to speed processing:
* "collapsed" = rows which are not on either side of CI border for any test are dropped.
* CIs are then constructed by looping through Stata rejections table `rtable'.

//dis "testlist is 	`testlist'"
	local hasrejections		=("`hasrejections'"~="")        	//  Convert to boolean
	tempname rtable								//  table of collapsed rejections
										//  name use for both Mata and Stata objects
	tempname p														//  name to use for Mata pointer
	mata: `p' = &`citable'											//  pointer to Mata matrix (CI table)

	if `hasrejections' {	
		//  Already in rejection 1/0 format
		local rtcnames			"null"
		foreach test of local testlist {
			local rtcnames		"`rtcnames' `test'_r"
			local testcol		: list posof "`test'_r" in cnames	//  table has rejections, hence "_r"
		 	local gridcols		"`gridcols' `testcol'"
		}
		mata: `rtable' = collapse_pcitable(`p', "`gridcols'")		//  create table of rejections and collapse (delete unneeded rows)
		mata: st_matrix("`rtable'",`rtable')						//  copy from Mata into Stata
		mat colnames `rtable'	=`rtcnames'							//  and name columns
		mata: mata drop `rtable'									//  don't need Mata version of rejections table
	}
	else {
		//  original CI table with p-values besides lc_2sls, so need to calc rejections
		local rtcnames			"null"
		local rlist "lc_2sls lc k_2sls" // list of test that has rejection indicators already
		local rtestlist : list testlist - rlist // we calculate rejection indicator for LC_2sls and LC in compute_pvals already
		// rtestlist is the list of tests that need rejection indicators
		foreach test of local rtestlist {
			local rtcnames		"`rtcnames' `test'_r"
			local testcol		: list posof "`test'_p" in cnames	//  table has p-values, hence "_p"
		 	local gridcols		"`gridcols' `testcol'"
		 	local testlevels	"`testlevels' ``test'_level'"
			}

		local lc_cols "" // column numbers of rejections
		foreach rejection of local rlist {
			local testcol		: list posof "`rejection'_r" in cnames	//  table has rejection, hence "_r"
		 	if `testcol' >0 { // if the test is in cnames, then append it
			local lc_cols		"`lc_cols' `testcol'"
				}
			}
		if "`lc_cols'" == "" { // if none of the rejection test is on the list (i.e. only AR test), then set to 0
			local lc_cols 		"0"
			}
		
		mata: `rtable' = collapse_citable(`p', "`lc_cols'", "`gridcols'", "`testlevels'")	//  create table of rejections and collapse
																				//  (delete unnecessary rows)
		mata: st_matrix("`rtable'",`rtable')	
		local rtcnames_full = "`rtcnames'" //  copy from Mata into Stata
		
		foreach rejection of local rlist {
			local testcol		: list posof "`rejection'_r" in cnames	//  table has rejection, hence "_r"
		 	if `testcol' >0 { // if the test is in cnames, then append it to rtcnaes
				local rtcnames_full = "`rtcnames_full' `rejection'_r"
				}
			}

		mat colnames `rtable'	= `rtcnames_full'									//  and name columns
		mata: mata drop `rtable'												//  don't need Mata version of rejections table
	} // end of getting rtable
	mata: mata drop `p'												//  clean up
* create macros for storing confidence sets
	foreach testname in `testlist' {
		local `testname'_cset ""
		local `testname'_rbegin=0
		local `testname'_rend=0
		local `testname'_rbegin_null=0
		local `testname'_rend_null=0
		local `testname'_flag=0
	}

	local rows		=rowsof(`rtable')

	foreach testname in `testlist' {			//  do this once at the beginning for all tests
												//  local is col number rej indicator appears for that test
		local `testname'_r_cn	= colnumb(`rtable', "`testname'_r")
	}
	forvalue i=1/`rows' {
		local gridnull	= el(`rtable',`i',1)
* write out confidence sets from rejection indicators
		foreach testname in `testlist' {
			if "`hasrejections'"=="" {														//  is a table of p-values
				local tentry_p = el(`rtable',`i',``testname'_p_cn')							//  p-value for test
				local `testname'_r = cond(													/// create rejection indicator
											missing(`tentry_p'), .,							///	=. if pval missing,
											cond(`tentry_p'<=1-``testname'_level'/100,1,0)	/// =1 if pval<sig, =0 otherwise
										)
			}
			else {																			//  is a table of rejection indicators
				local `testname'_r = el(`rtable',`i',``testname'_r_cn')						//  rejection indicator for test				
			}
			if ``testname'_r'< . {
				local `testname'_flag=1						//  at least one value not missing
			}
			if ``testname'_r'==0 {
				if ``testname'_rbegin'==0 {
					local `testname'_rbegin=`i'
					if `i'==1 {
						local `testname'_rbegin_null "   ...  "
					}
					else {
						local `testname'_rbegin_null : di %8.0g `gridnull'
					}
				}
				local `testname'_rend=`i'
				if `i'==`rows' {
					local `testname'_rend_null "   ...  "
					}
					else {
						local `testname'_rend_null : di %8.0g `gridnull'
					}
			}
			if ``testname'_r'==1 | (``testname'_r'==0 & `i'==`rows') {
				if ``testname'_rbegin'>0 & ``testname'_rend'>0 & (``testname'_rbegin'==``testname'_rend' & `i'<`rows') {
					local rnull : di %8.0g "``testname'_rbegin_null'"
					if length("``testname'_cset'")==0	local `testname'_cset "`rnull'"
					else								local `testname'_cset "``testname'_cset' U `rnull'"
					local `testname'_rbegin=0
					local `testname'_rend=0
				}
				else if ``testname'_rbegin'>0 & ``testname'_rend'>0 & (``testname'_rbegin'<``testname'_rend' | `i'==`rows') {
					local rnull1 "``testname'_rbegin_null'"
					local rnull2 "``testname'_rend_null'"
					if length("``testname'_cset'")==0	local `testname'_cset "[`rnull1',`rnull2']"
					else								local `testname'_cset "``testname'_cset' U [`rnull1',`rnull2']"
					local `testname'_rbegin=0
					local `testname'_rend=0
				}
			}
		}
	}	// end loop over grid points
* finish up non-closed-form case
	foreach testname in `testlist' {
		if ``testname'_flag'==0 {
			local `testname'_cset "."					//  all grid values missing, cset==.
		}
		else if length("``testname'_cset'")==0 {
			local `testname'_cset "null set"			//  never failed to reject
		}
		tokenize "``testname'_cset'", parse(",[] ")
		local wcount : word count `*'
* If cset is "[   ...  ,   ...  ]" then it has 5 tokenized elements and #2=#4="..."
		if `wcount'==5 & "`2'"=="..." & "`4'"=="..." {
			local `testname'_cset "entire grid"			//  never rejected
		}
		return local `testname'_cset "``testname'_cset'"

	}

end		//  end get_ci_from_table


program get_ci_from_vcv, rclass
	syntax [,							///
				vnum(integer 1)			/// vnum is position in beta and VCV; defaults to 1
				wbeta(name local)		/// if beta and var_wbeta are provided,
				var_wbeta(name local)	/// return wald test as well
				wald_level(integer 0)	///
			]

* Wald cset is done by hand
* vnum is position in beta/VCV; default is 1 and [1,1]
	local b					= `wbeta'[1,`vnum']
	local se				= sqrt(`var_wbeta'[`vnum',`vnum'])
	local wald_x1			=`b'-`se'*invnormal((100+`wald_level')/200)
	local wald_x2			=`b'+`se'*invnormal((100+`wald_level')/200)
	local wald_cset			: di "["  %8.0g `wald_x1' "," %8.0g `wald_x2' "]"
	return local wald_cset	"`wald_cset'"

end		//  end get_ci_from_vcv


mata:
void compute_a_min(
         scalar nendog, ///
         scalar nsendog, ///
         scalar nexexog, ///
         scalar alpha, ///
         scalar gamma, ///
		 string scalar o, ///
         string scalar needle ///

)
{
		 k_df = nendog - nsendog
		 a = 100-alpha
		 gamma_out = regexm(" 1 5 10 15 20 "," "+strofreal(gamma)+" ")
		 alpha_out = regexm(" 1 5 10 "," "+strofreal(a)+" ")
		 if (k_df > 5 | nexexog > 50 | gamma_out == 0 | alpha_out == 0) {
			printf("\n simulating weight for LC test...")
			}
		 if (k_df > 5 | nexexog > 50 | gamma_out == 0 | alpha_out == 0) {
			printf("\n simulating weight for LC test...")
			oldseed	= rseed()								//  save existing seed
			rseed(12345)										//  set seed (replicability)
			crit_sims = 10^5
			K_size	= rchi2(crit_sims,1,k_df)
			if (nexexog > nendog) {
				J_size	= rchi2(crit_sims,1,nexexog-nendog)
			}
			else {
				J_size = J(crit_sims,1,0)
			}
			target_quant = invchi2(k_df,alpha/100)
			v = simulate_a_min(K_size,J_size,target_quant,a/100, gamma/100)
			st_numscalar("r(a_min)",v[1,1])
		 	st_numscalar("r(lc_crit)",v[1,2])

			
			if (k_df == 1 & nendog == 1) { // then no need to re-simulate
				st_numscalar("r(a_min_p)",v[.,1])
				st_numscalar("r(lc_crit_p)",v[.,2])

			}
			else{
				P_size	= rchi2(crit_sims,1,1)
				K_1_size= rchi2(crit_sims,1,nexexog-1)
				target_quant_1 = invchi2(1,alpha/100)
				v = simulate_a_min(P_size,K_1_size,target_quant_1,a/100, gamma/100)
				st_numscalar("r(a_min_p)",v[.,1])
				st_numscalar("r(lc_crit_p)",v[.,2])

			}
			rseed(oldseed)	

		}
		else {
		 o = "Z1 1 1 1X0.22131X8.1484 Z1 1 2 1X0.17194X10.812 Z1 1 3 1X0.15119X13.047 Z1 1 4 1X0.13663X15.095 Z1 1 5 1X0.1263X16.988 Z1 1 1 2X0.18419X8.0965 Z1 1 2 2X0.17194X10.812 Z1 1 3 2X0.15119X13.047 Z1 1 4 2X0.13663X15.095 Z1 1 5 2X0.1263X16.988 Z1 1 1 3X0.15881X8.0676 Z1 1 2 3X0.15163X10.789 Z1 1 3 3X0.15119X13.047 Z1 1 4 3X0.13663X15.095 Z1 1 5 3X0.1263X16.988 Z1 1 1 4X0.13931X8.0522 Z1 1 2 4X0.13581X10.774 Z1 1 3 4X0.13644X13.028 Z1 1 4 4X0.13663X15.095 Z1 1 5 4X0.1263X16.988 Z1 1 1 5X0.12452X8.0303 Z1 1 2 5X0.12281X10.753 Z1 1 3 5X0.12463X13.022 Z1 1 4 5X0.12522X15.076 Z1 1 5 5X0.1263X16.988 Z1 1 1 6X0.11275X8.0218 Z1 1 2 6X0.11244X10.736 Z1 1 3 6X0.1145X13.002 Z1 1 4 6X0.11609X15.078 Z1 1 5 6X0.11706X16.973 Z1 1 1 7X0.10219X7.9988 Z1 1 2 7X0.1037X10.721 Z1 1 3 7X0.10631X12.993 Z1 1 4 7X0.10753X15.058 Z1 1 5 7X0.1088X16.95 Z1 1 1 8X0.094047X7.99 Z1 1 2 8X0.095969X10.716 Z1 1 3 8X0.098625X12.976 Z1 1 4 8X0.10059X15.046 Z1 1 5 8X0.10219X16.941 Z1 1 1 9X0.087094X7.9876 Z1 1 2 9X0.089438X10.705 Z1 1 3 9X0.092414X12.958 Z1 1 4 9X0.09425X15.03 Z1 1 5 9X0.09625X16.928 Z1 1 1 10X0.081406X7.9872 Z1 1 2 10X0.083797X10.7 Z1 1 3 10X0.087063X12.959 Z1 1 4 10X0.08875X15.019 Z1 1 5 10X0.090938X16.918 Z1 1 1 11X0.076234X7.9818 Z1 1 2 11X0.078906X10.693 Z1 1 3 11X0.082016X12.95 Z1 1 4 11X0.083906X15.006 Z1 1 5 11X0.086383X16.913 Z1 1 1 12X0.071688X7.9689 Z1 1 2 12X0.074391X10.682 Z1 1 3 12X0.077836X12.945 Z1 1 4 12X0.079703X15 Z1 1 5 12X0.082X16.903 Z1 1 1 13X0.067555X7.9655 Z1 1 2 13X0.070281X10.67 Z1 1 3 13X0.074039X12.932 Z1 1 4 13X0.075891X15.003 Z1 1 5 13X0.078094X16.898 Z1 1 1 14X0.063969X7.9632 Z1 1 2 14X0.06675X10.663 Z1 1 3 14X0.070609X12.936 Z1 1 4 14X0.072313X14.985 Z1 1 5 14X0.074563X16.888 Z1 1 1 15X0.0605X7.9547 Z1 1 2 15X0.063367X10.653 Z1 1 3 15X0.067359X12.934 Z1 1 4 15X0.069125X14.981 Z1 1 5 15X0.071531X16.89 Z1 1 1 16X0.05775X7.9508 Z1 1 2 16X0.060633X10.65 Z1 1 3 16X0.064391X12.924 Z1 1 4 16X0.066164X14.977 Z1 1 5 16X0.068609X16.889 Z1 1 1 17X0.055125X7.9456 Z1 1 2 17X0.057953X10.65 Z1 1 3 17X0.061836X12.923 Z1 1 4 17X0.06343X14.972 Z1 1 5 17X0.065844X16.874 Z1 1 1 18X0.052688X7.9441 Z1 1 2 18X0.055563X10.653 Z1 1 3 18X0.059344X12.917 Z1 1 4 18X0.061125X14.977 Z1 1 5 18X0.063344X16.873 Z1 1 1 19X0.050469X7.9439 Z1 1 2 19X0.053375X10.648 Z1 1 3 19X0.056977X12.918 Z1 1 4 19X0.058898X14.97 Z1 1 5 19X0.061063X16.875 Z1 1 1 20X0.048445X7.9388 Z1 1 2 20X0.051438X10.646 Z1 1 3 20X0.054828X12.91 Z1 1 4 20X0.056594X14.96 Z1 1 5 20X0.058828X16.866 Z1 1 1 21X0.046609X7.9369 Z1 1 2 21X0.0495X10.64 Z1 1 3 21X0.052813X12.904 Z1 1 4 21X0.054621X14.961 Z1 1 5 21X0.057047X16.87 Z1 1 1 22X0.044836X7.933 Z1 1 2 22X0.047875X10.644 Z1 1 3 22X0.051X12.901 Z1 1 4 22X0.052781X14.956 Z1 1 5 22X0.055199X16.864 Z1 1 1 23X0.043219X7.9349 Z1 1 2 23X0.046172X10.635 Z1 1 3 23X0.049391X12.901 Z1 1 4 23X0.051156X14.956 Z1 1 5 23X0.053469X16.865 Z1 1 1 24X0.041672X7.9293 Z1 1 2 24X0.044664X10.635 Z1 1 3 24X0.047688X12.894 Z1 1 4 24X0.049594X14.958 Z1 1 5 24X0.051781X16.857 Z1 1 1 25X0.040328X7.9323 Z1 1 2 25X0.04325X10.631 Z1 1 3 25X0.046219X12.893 Z1 1 4 25X0.048016X14.956 Z1 1 5 25X0.050289X16.86 Z1 1 1 26X0.039031X7.928 Z1 1 2 26X0.042X10.637 Z1 1 3 26X0.044844X12.893 Z1 1 4 26X0.046586X14.95 Z1 1 5 26X0.048875X16.86 Z1 1 1 27X0.03775X7.9285 Z1 1 2 27X0.040734X10.633 Z1 1 3 27X0.043504X12.893 Z1 1 4 27X0.045324X14.956 Z1 1 5 27X0.047539X16.861 Z1 1 1 28X0.036609X7.9274 Z1 1 2 28X0.039563X10.637 Z1 1 3 28X0.042289X12.891 Z1 1 4 28X0.044164X14.95 Z1 1 5 28X0.046301X16.86 Z1 1 1 29X0.035453X7.9209 Z1 1 2 29X0.038422X10.632 Z1 1 3 29X0.041082X12.887 Z1 1 4 29X0.042984X14.948 Z1 1 5 29X0.045X16.854 Z1 1 1 30X0.034402X7.9177 Z1 1 2 30X0.03732X10.637 Z1 1 3 30X0.04X12.887 Z1 1 4 30X0.041813X14.951 Z1 1 5 30X0.043777X16.848 Z1 1 1 31X0.033438X7.9136 Z1 1 2 31X0.036336X10.635 Z1 1 3 31X0.038883X12.886 Z1 1 4 31X0.040797X14.948 Z1 1 5 31X0.042656X16.846 Z1 1 1 32X0.032477X7.914 Z1 1 2 32X0.035352X10.633 Z1 1 3 32X0.038X12.887 Z1 1 4 32X0.039844X14.946 Z1 1 5 32X0.041555X16.841 Z1 1 1 33X0.031688X7.9149 Z1 1 2 33X0.034438X10.63 Z1 1 3 33X0.037055X12.888 Z1 1 4 33X0.038906X14.944 Z1 1 5 33X0.040535X16.84 Z1 1 1 34X0.030875X7.9124 Z1 1 2 34X0.033469X10.622 Z1 1 3 34X0.036172X12.888 Z1 1 4 34X0.037883X14.942 Z1 1 5 34X0.039594X16.846 Z1 1 1 35X0.030125X7.9124 Z1 1 2 35X0.032711X10.623 Z1 1 3 35X0.035313X12.884 Z1 1 4 35X0.037016X14.941 Z1 1 5 35X0.038781X16.843 Z1 1 1 36X0.029344X7.9104 Z1 1 2 36X0.03193X10.622 Z1 1 3 36X0.03452X12.885 Z1 1 4 36X0.036156X14.934 Z1 1 5 36X0.037895X16.843 Z1 1 1 37X0.02866X7.9111 Z1 1 2 37X0.031191X10.618 Z1 1 3 37X0.033648X12.881 Z1 1 4 37X0.035344X14.929 Z1 1 5 37X0.037031X16.844 Z1 1 1 38X0.027992X7.9089 Z1 1 2 38X0.030492X10.619 Z1 1 3 38X0.032973X12.881 Z1 1 4 38X0.034547X14.93 Z1 1 5 38X0.036188X16.84 Z1 1 1 39X0.027371X7.908 Z1 1 2 39X0.029789X10.62 Z1 1 3 39X0.032254X12.879 Z1 1 4 39X0.033859X14.932 Z1 1 5 39X0.035496X16.838 Z1 1 1 40X0.026844X7.9132 Z1 1 2 40X0.029203X10.621 Z1 1 3 40X0.031539X12.873 Z1 1 4 40X0.033188X14.936 Z1 1 5 40X0.034828X16.845 Z1 1 1 41X0.026281X7.9153 Z1 1 2 41X0.028578X10.615 Z1 1 3 41X0.030879X12.873 Z1 1 4 41X0.032422X14.929 Z1 1 5 41X0.034094X16.841 Z1 1 1 42X0.025727X7.9161 Z1 1 2 42X0.028004X10.618 Z1 1 3 42X0.030266X12.871 Z1 1 4 42X0.031844X14.933 Z1 1 5 42X0.033438X16.839 Z1 1 1 43X0.025125X7.9086 Z1 1 2 43X0.027441X10.618 Z1 1 3 43X0.029703X12.871 Z1 1 4 43X0.031141X14.924 Z1 1 5 43X0.032844X16.845 Z1 1 1 44X0.024625X7.9068 Z1 1 2 44X0.026906X10.62 Z1 1 3 44X0.029125X12.869 Z1 1 4 44X0.030531X14.922 Z1 1 5 44X0.032156X16.837 Z1 1 1 45X0.024109X7.9072 Z1 1 2 45X0.026426X10.625 Z1 1 3 45X0.028578X12.871 Z1 1 4 45X0.029977X14.924 Z1 1 5 45X0.031512X16.836 Z1 1 1 46X0.023672X7.9084 Z1 1 2 46X0.025906X10.622 Z1 1 3 46X0.028008X12.866 Z1 1 4 46X0.02948X14.924 Z1 1 5 46X0.030984X16.832 Z1 1 1 47X0.023203X7.9073 Z1 1 2 47X0.025438X10.617 Z1 1 3 47X0.027496X12.871 Z1 1 4 47X0.028914X14.923 Z1 1 5 47X0.030453X16.829 Z1 1 1 48X0.02275X7.9106 Z1 1 2 48X0.024965X10.617 Z1 1 3 48X0.027008X12.866 Z1 1 4 48X0.028406X14.923 Z1 1 5 48X0.029941X16.834 Z1 1 1 49X0.022363X7.9108 Z1 1 2 49X0.024555X10.62 Z1 1 3 49X0.026469X12.863 Z1 1 4 49X0.027832X14.918 Z1 1 5 49X0.029367X16.829 Z1 1 1 50X0.02193X7.9125 Z1 1 2 50X0.024156X10.62 Z1 1 3 50X0.025977X12.861 Z1 1 4 50X0.027379X14.92 Z1 1 5 50X0.028871X16.827 Z1 2 1 1X0.40725X9.3889 Z1 2 2 1X0.30872X12.074 Z1 2 3 1X0.26544X14.342 Z1 2 4 1X0.23619X16.418 Z1 2 5 1X0.21744X18.363 Z1 2 1 2X0.32375X9.201 Z1 2 2 2X0.30872X12.074 Z1 2 3 2X0.26544X14.342 Z1 2 4 2X0.23619X16.418 Z1 2 5 2X0.21744X18.363 Z1 2 1 3X0.2725X9.1022 Z1 2 2 3X0.26763X11.991 Z1 2 3 3X0.26544X14.342 Z1 2 4 3X0.23619X16.418 Z1 2 5 3X0.21744X18.363 Z1 2 1 4X0.23559X9.0332 Z1 2 2 4X0.235X11.91 Z1 2 3 4X0.23697X14.286 Z1 2 4 4X0.23619X16.418 Z1 2 5 4X0.21744X18.363 Z1 2 1 5X0.20788X8.972 Z1 2 2 5X0.21113X11.862 Z1 2 3 5X0.21391X14.228 Z1 2 4 5X0.21467X16.364 Z1 2 5 5X0.21744X18.363 Z1 2 1 6X0.18666X8.9395 Z1 2 2 6X0.1915X11.824 Z1 2 3 6X0.19533X14.195 Z1 2 4 6X0.19756X16.348 Z1 2 5 6X0.20039X18.325 Z1 2 1 7X0.16925X8.9 Z1 2 2 7X0.17481X11.784 Z1 2 3 7X0.17994X14.167 Z1 2 4 7X0.18288X16.313 Z1 2 5 7X0.18619X18.287 Z1 2 1 8X0.15503X8.8781 Z1 2 2 8X0.16081X11.751 Z1 2 3 8X0.16642X14.13 Z1 2 4 8X0.16989X16.278 Z1 2 5 8X0.1733X18.252 Z1 2 1 9X0.143X8.8489 Z1 2 2 9X0.14969X11.729 Z1 2 3 9X0.15478X14.094 Z1 2 4 9X0.15886X16.239 Z1 2 5 9X0.16234X18.212 Z1 2 1 10X0.1328X8.8313 Z1 2 2 10X0.13961X11.704 Z1 2 3 10X0.1453X14.086 Z1 2 4 10X0.14906X16.206 Z1 2 5 10X0.15259X18.18 Z1 2 1 11X0.12419X8.8302 Z1 2 2 11X0.13138X11.691 Z1 2 3 11X0.13653X14.059 Z1 2 4 11X0.14044X16.18 Z1 2 5 11X0.14406X18.154 Z1 2 1 12X0.11653X8.8159 Z1 2 2 12X0.12334X11.667 Z1 2 3 12X0.12911X14.036 Z1 2 4 12X0.13269X16.156 Z1 2 5 12X0.13645X18.131 Z1 2 1 13X0.10963X8.8037 Z1 2 2 13X0.11644X11.648 Z1 2 3 13X0.12206X14.007 Z1 2 4 13X0.12569X16.139 Z1 2 5 13X0.1297X18.114 Z1 2 1 14X0.1038X8.7907 Z1 2 2 14X0.11053X11.641 Z1 2 3 14X0.11578X13.987 Z1 2 4 14X0.11968X16.117 Z1 2 5 14X0.12369X18.095 Z1 2 1 15X0.098328X8.7787 Z1 2 2 15X0.10508X11.622 Z1 2 3 15X0.11033X13.977 Z1 2 4 15X0.11461X16.116 Z1 2 5 15X0.11813X18.081 Z1 2 1 16X0.093406X8.7651 Z1 2 2 16X0.099859X11.604 Z1 2 3 16X0.10549X13.969 Z1 2 4 16X0.10954X16.099 Z1 2 5 16X0.113X18.065 Z1 2 1 17X0.089016X8.7598 Z1 2 2 17X0.095656X11.601 Z1 2 3 17X0.1009X13.959 Z1 2 4 17X0.10496X16.097 Z1 2 5 17X0.10852X18.055 Z1 2 1 18X0.085086X8.7545 Z1 2 2 18X0.091625X11.6 Z1 2 3 18X0.096641X13.945 Z1 2 4 18X0.10088X16.086 Z1 2 5 18X0.1043X18.058 Z1 2 1 19X0.081273X8.7473 Z1 2 2 19X0.087859X11.587 Z1 2 3 19X0.092953X13.946 Z1 2 4 19X0.096813X16.07 Z1 2 5 19X0.10009X18.031 Z1 2 1 20X0.077922X8.7418 Z1 2 2 20X0.084313X11.575 Z1 2 3 20X0.089438X13.932 Z1 2 4 20X0.093156X16.06 Z1 2 5 20X0.096414X18.032 Z1 2 1 21X0.075008X8.7382 Z1 2 2 21X0.081234X11.57 Z1 2 3 21X0.085922X13.924 Z1 2 4 21X0.089844X16.059 Z1 2 5 21X0.092969X18.016 Z1 2 1 22X0.072094X8.7248 Z1 2 2 22X0.07825X11.561 Z1 2 3 22X0.083063X13.918 Z1 2 4 22X0.086641X16.053 Z1 2 5 22X0.089875X18.008 Z1 2 1 23X0.069508X8.7198 Z1 2 2 23X0.075555X11.559 Z1 2 3 23X0.080297X13.913 Z1 2 4 23X0.08375X16.044 Z1 2 5 23X0.086938X17.998 Z1 2 1 24X0.067047X8.7137 Z1 2 2 24X0.07293X11.552 Z1 2 3 24X0.077641X13.906 Z1 2 4 24X0.081035X16.04 Z1 2 5 24X0.084188X17.986 Z1 2 1 25X0.064813X8.7125 Z1 2 2 25X0.070492X11.54 Z1 2 3 25X0.075117X13.9 Z1 2 4 25X0.078547X16.033 Z1 2 5 25X0.081746X17.995 Z1 2 1 26X0.062617X8.7055 Z1 2 2 26X0.06825X11.538 Z1 2 3 26X0.072844X13.896 Z1 2 4 26X0.076141X16.029 Z1 2 5 26X0.079328X17.987 Z1 2 1 27X0.060625X8.7018 Z1 2 2 27X0.066172X11.535 Z1 2 3 27X0.070664X13.891 Z1 2 4 27X0.073848X16.023 Z1 2 5 27X0.077063X17.979 Z1 2 1 28X0.058781X8.7009 Z1 2 2 28X0.064328X11.535 Z1 2 3 28X0.068664X13.888 Z1 2 4 28X0.071742X16.016 Z1 2 5 28X0.074844X17.974 Z1 2 1 29X0.05707X8.703 Z1 2 2 29X0.062492X11.532 Z1 2 3 29X0.066703X13.874 Z1 2 4 29X0.069688X16.004 Z1 2 5 29X0.072875X17.967 Z1 2 1 30X0.055359X8.6945 Z1 2 2 30X0.060699X11.526 Z1 2 3 30X0.064961X13.875 Z1 2 4 30X0.067785X15.995 Z1 2 5 30X0.070828X17.958 Z1 2 1 31X0.053844X8.6955 Z1 2 2 31X0.059078X11.527 Z1 2 3 31X0.06325X13.885 Z1 2 4 31X0.066094X15.989 Z1 2 5 31X0.069066X17.964 Z1 2 1 32X0.052258X8.6857 Z1 2 2 32X0.057453X11.523 Z1 2 3 32X0.061578X13.877 Z1 2 4 32X0.064309X15.986 Z1 2 5 32X0.067344X17.956 Z1 2 1 33X0.050898X8.6842 Z1 2 2 33X0.05591X11.512 Z1 2 3 33X0.059977X13.872 Z1 2 4 33X0.062695X15.983 Z1 2 5 33X0.065688X17.956 Z1 2 1 34X0.049523X8.678 Z1 2 2 34X0.054453X11.513 Z1 2 3 34X0.058496X13.871 Z1 2 4 34X0.061219X15.976 Z1 2 5 34X0.064078X17.945 Z1 2 1 35X0.048309X8.6808 Z1 2 2 35X0.053129X11.508 Z1 2 3 35X0.057078X13.863 Z1 2 4 35X0.059852X15.977 Z1 2 5 35X0.062609X17.944 Z1 2 1 36X0.047063X8.6781 Z1 2 2 36X0.051969X11.512 Z1 2 3 36X0.055742X13.863 Z1 2 4 36X0.058375X15.97 Z1 2 5 36X0.061234X17.945 Z1 2 1 37X0.045965X8.6723 Z1 2 2 37X0.050758X11.506 Z1 2 3 37X0.054473X13.863 Z1 2 4 37X0.057117X15.964 Z1 2 5 37X0.059922X17.94 Z1 2 1 38X0.044875X8.6689 Z1 2 2 38X0.049563X11.5 Z1 2 3 38X0.053285X13.858 Z1 2 4 38X0.055875X15.964 Z1 2 5 38X0.058605X17.936 Z1 2 1 39X0.043883X8.6687 Z1 2 2 39X0.0485X11.503 Z1 2 3 39X0.052105X13.854 Z1 2 4 39X0.054594X15.958 Z1 2 5 39X0.057355X17.932 Z1 2 1 40X0.042895X8.6682 Z1 2 2 40X0.047469X11.503 Z1 2 3 40X0.050945X13.845 Z1 2 4 40X0.053438X15.957 Z1 2 5 40X0.056211X17.934 Z1 2 1 41X0.041984X8.665 Z1 2 2 41X0.046438X11.496 Z1 2 3 41X0.049906X13.851 Z1 2 4 41X0.052359X15.955 Z1 2 5 41X0.055031X17.93 Z1 2 1 42X0.041078X8.6615 Z1 2 2 42X0.045516X11.5 Z1 2 3 42X0.048828X13.844 Z1 2 4 42X0.051238X15.947 Z1 2 5 42X0.053859X17.926 Z1 2 1 43X0.040207X8.6556 Z1 2 2 43X0.044566X11.495 Z1 2 3 43X0.047832X13.84 Z1 2 4 43X0.050266X15.947 Z1 2 5 43X0.052814X17.927 Z1 2 1 44X0.039355X8.6521 Z1 2 2 44X0.043664X11.494 Z1 2 3 44X0.046867X13.836 Z1 2 4 44X0.049219X15.94 Z1 2 5 44X0.051781X17.921 Z1 2 1 45X0.038566X8.6565 Z1 2 2 45X0.042813X11.494 Z1 2 3 45X0.045984X13.835 Z1 2 4 45X0.04827X15.933 Z1 2 5 45X0.050789X17.918 Z1 2 1 46X0.037813X8.6555 Z1 2 2 46X0.041969X11.492 Z1 2 3 46X0.045117X13.832 Z1 2 4 46X0.047395X15.934 Z1 2 5 46X0.049859X17.915 Z1 2 1 47X0.037086X8.6585 Z1 2 2 47X0.04118X11.488 Z1 2 3 47X0.044234X13.825 Z1 2 4 47X0.046563X15.936 Z1 2 5 47X0.048938X17.91 Z1 2 1 48X0.036379X8.6568 Z1 2 2 48X0.040406X11.487 Z1 2 3 48X0.043453X13.824 Z1 2 4 48X0.045664X15.929 Z1 2 5 48X0.048047X17.903 Z1 2 1 49X0.035695X8.6545 Z1 2 2 49X0.039695X11.492 Z1 2 3 49X0.042688X13.822 Z1 2 4 49X0.044887X15.927 Z1 2 5 49X0.047258X17.903 Z1 2 1 50X0.035047X8.6584 Z1 2 2 50X0.03893X11.48 Z1 2 3 50X0.041941X13.82 Z1 2 4 50X0.044125X15.932 Z1 2 5 50X0.046414X17.9 Z1 5 1 1X0.87113X12.484 Z1 5 2 1X0.63481X15.083 Z1 5 3 1X0.52931X17.333 Z1 5 4 1X0.46647X19.476 Z1 5 5 1X0.42197X21.448 Z1 5 1 2X0.62356X11.657 Z1 5 2 2X0.63481X15.083 Z1 5 3 2X0.52931X17.333 Z1 5 4 2X0.46647X19.476 Z1 5 5 2X0.42197X21.448 Z1 5 1 3X0.49756X11.223 Z1 5 2 3X0.52119X14.67 Z1 5 3 3X0.52931X17.333 Z1 5 4 3X0.46647X19.476 Z1 5 5 3X0.42197X21.448 Z1 5 1 4X0.41741X10.971 Z1 5 2 4X0.44463X14.381 Z1 5 3 4X0.45756X17.07 Z1 5 4 4X0.46647X19.476 Z1 5 5 4X0.42197X21.448 Z1 5 1 5X0.36284X10.807 Z1 5 2 5X0.39031X14.179 Z1 5 3 5X0.40425X16.872 Z1 5 4 5X0.41488X19.273 Z1 5 5 5X0.42197X21.448 Z1 5 1 6X0.32056X10.678 Z1 5 2 6X0.34806X14.031 Z1 5 3 6X0.36284X16.719 Z1 5 4 6X0.37491X19.128 Z1 5 5 6X0.38222X21.283 Z1 5 1 7X0.28863X10.593 Z1 5 2 7X0.31481X13.916 Z1 5 3 7X0.32991X16.597 Z1 5 4 7X0.34152X18.98 Z1 5 5 7X0.34889X21.128 Z1 5 1 8X0.26216X10.505 Z1 5 2 8X0.28769X13.832 Z1 5 3 8X0.30216X16.49 Z1 5 4 8X0.31386X18.862 Z1 5 5 8X0.32203X21.025 Z1 5 1 9X0.24081X10.454 Z1 5 2 9X0.26488X13.743 Z1 5 3 9X0.27994X16.414 Z1 5 4 9X0.29094X18.755 Z1 5 5 9X0.29884X20.903 Z1 5 1 10X0.22268X10.401 Z1 5 2 10X0.24513X13.661 Z1 5 3 10X0.26008X16.342 Z1 5 4 10X0.27063X18.667 Z1 5 5 10X0.2786X20.803 Z1 5 1 11X0.20691X10.354 Z1 5 2 11X0.22906X13.614 Z1 5 3 11X0.24281X16.257 Z1 5 4 11X0.25356X18.598 Z1 5 5 11X0.26144X20.731 Z1 5 1 12X0.19355X10.311 Z1 5 2 12X0.21459X13.561 Z1 5 3 12X0.22795X16.188 Z1 5 4 12X0.23875X18.536 Z1 5 5 12X0.24588X20.654 Z1 5 1 13X0.18192X10.285 Z1 5 2 13X0.20228X13.52 Z1 5 3 13X0.21519X16.137 Z1 5 4 13X0.22538X18.481 Z1 5 5 13X0.23288X20.6 Z1 5 1 14X0.17154X10.256 Z1 5 2 14X0.1909X13.466 Z1 5 3 14X0.2035X16.081 Z1 5 4 14X0.2135X18.421 Z1 5 5 14X0.22106X20.538 Z1 5 1 15X0.16233X10.224 Z1 5 2 15X0.18119X13.439 Z1 5 3 15X0.19313X16.043 Z1 5 4 15X0.20278X18.376 Z1 5 5 15X0.21034X20.493 Z1 5 1 16X0.15398X10.207 Z1 5 2 16X0.17186X13.399 Z1 5 3 16X0.18388X16.019 Z1 5 4 16X0.19308X18.341 Z1 5 5 16X0.20066X20.456 Z1 5 1 17X0.1465X10.179 Z1 5 2 17X0.16381X13.378 Z1 5 3 17X0.17525X15.977 Z1 5 4 17X0.18438X18.306 Z1 5 5 17X0.19173X20.411 Z1 5 1 18X0.13972X10.168 Z1 5 2 18X0.15644X13.349 Z1 5 3 18X0.1675X15.937 Z1 5 4 18X0.17666X18.279 Z1 5 5 18X0.1835X20.373 Z1 5 1 19X0.13358X10.155 Z1 5 2 19X0.1499X13.331 Z1 5 3 19X0.16053X15.92 Z1 5 4 19X0.16944X18.254 Z1 5 5 19X0.176X20.346 Z1 5 1 20X0.12792X10.133 Z1 5 2 20X0.14367X13.309 Z1 5 3 20X0.15419X15.896 Z1 5 4 20X0.16278X18.23 Z1 5 5 20X0.16905X20.313 Z1 5 1 21X0.12281X10.127 Z1 5 2 21X0.13791X13.277 Z1 5 3 21X0.14807X15.86 Z1 5 4 21X0.15656X18.203 Z1 5 5 21X0.16292X20.278 Z1 5 1 22X0.11806X10.108 Z1 5 2 22X0.13281X13.265 Z1 5 3 22X0.14263X15.845 Z1 5 4 22X0.15077X18.176 Z1 5 5 22X0.15705X20.247 Z1 5 1 23X0.11365X10.087 Z1 5 2 23X0.12809X13.254 Z1 5 3 23X0.13766X15.823 Z1 5 4 23X0.14538X18.146 Z1 5 5 23X0.15181X20.236 Z1 5 1 24X0.10956X10.071 Z1 5 2 24X0.1235X13.243 Z1 5 3 24X0.13273X15.808 Z1 5 4 24X0.14059X18.135 Z1 5 5 24X0.14671X20.21 Z1 5 1 25X0.10573X10.063 Z1 5 2 25X0.11923X13.228 Z1 5 3 25X0.12842X15.789 Z1 5 4 25X0.13589X18.113 Z1 5 5 25X0.14195X20.188 Z1 5 1 26X0.1022X10.054 Z1 5 2 26X0.11527X13.215 Z1 5 3 26X0.1243X15.772 Z1 5 4 26X0.13167X18.097 Z1 5 5 26X0.13745X20.178 Z1 5 1 27X0.098914X10.052 Z1 5 2 27X0.1117X13.2 Z1 5 3 27X0.12042X15.749 Z1 5 4 27X0.12763X18.074 Z1 5 5 27X0.1333X20.164 Z1 5 1 28X0.095773X10.04 Z1 5 2 28X0.1082X13.187 Z1 5 3 28X0.11684X15.74 Z1 5 4 28X0.12383X18.065 Z1 5 5 28X0.12938X20.146 Z1 5 1 29X0.092875X10.029 Z1 5 2 29X0.105X13.173 Z1 5 3 29X0.11341X15.721 Z1 5 4 29X0.12034X18.052 Z1 5 5 29X0.12559X20.13 Z1 5 1 30X0.090227X10.026 Z1 5 2 30X0.10205X13.162 Z1 5 3 30X0.11024X15.703 Z1 5 4 30X0.11691X18.034 Z1 5 5 30X0.12213X20.111 Z1 5 1 31X0.087637X10.019 Z1 5 2 31X0.099227X13.152 Z1 5 3 31X0.10715X15.7 Z1 5 4 31X0.11364X18.011 Z1 5 5 31X0.11881X20.091 Z1 5 1 32X0.085172X10.009 Z1 5 2 32X0.096539X13.142 Z1 5 3 32X0.10435X15.695 Z1 5 4 32X0.1106X18.001 Z1 5 5 32X0.11568X20.076 Z1 5 1 33X0.082816X9.9884 Z1 5 2 33X0.093953X13.135 Z1 5 3 33X0.10159X15.681 Z1 5 4 33X0.10766X17.985 Z1 5 5 33X0.11281X20.066 Z1 5 1 34X0.08068X9.9938 Z1 5 2 34X0.091531X13.129 Z1 5 3 34X0.099X15.673 Z1 5 4 34X0.10494X17.972 Z1 5 5 34X0.10991X20.044 Z1 5 1 35X0.07857X9.9903 Z1 5 2 35X0.089242X13.117 Z1 5 3 35X0.096555X15.666 Z1 5 4 35X0.10234X17.954 Z1 5 5 35X0.10723X20.037 Z1 5 1 36X0.076633X9.9875 Z1 5 2 36X0.087043X13.11 Z1 5 3 36X0.094141X15.65 Z1 5 4 36X0.099945X17.939 Z1 5 5 36X0.10468X20.026 Z1 5 1 37X0.074711X9.9753 Z1 5 2 37X0.084949X13.103 Z1 5 3 37X0.091938X15.647 Z1 5 4 37X0.097664X17.928 Z1 5 5 37X0.10225X20.01 Z1 5 1 38X0.072953X9.9692 Z1 5 2 38X0.082938X13.098 Z1 5 3 38X0.089906X15.649 Z1 5 4 38X0.095438X17.921 Z1 5 5 38X0.099938X20.009 Z1 5 1 39X0.07125X9.9578 Z1 5 2 39X0.081109X13.089 Z1 5 3 39X0.087875X15.641 Z1 5 4 39X0.093336X17.91 Z1 5 5 39X0.097766X19.998 Z1 5 1 40X0.069625X9.9546 Z1 5 2 40X0.07925X13.075 Z1 5 3 40X0.085883X15.626 Z1 5 4 40X0.091297X17.899 Z1 5 5 40X0.095699X19.994 Z1 5 1 41X0.068125X9.9524 Z1 5 2 41X0.077531X13.068 Z1 5 3 41X0.08402X15.619 Z1 5 4 41X0.089406X17.89 Z1 5 5 41X0.093719X19.989 Z1 5 1 42X0.066641X9.9443 Z1 5 2 42X0.075883X13.068 Z1 5 3 42X0.08225X15.613 Z1 5 4 42X0.0875X17.882 Z1 5 5 42X0.091746X19.977 Z1 5 1 43X0.065172X9.9372 Z1 5 2 43X0.074293X13.059 Z1 5 3 43X0.080539X15.604 Z1 5 4 43X0.085742X17.877 Z1 5 5 43X0.089879X19.966 Z1 5 1 44X0.063859X9.9343 Z1 5 2 44X0.072781X13.051 Z1 5 3 44X0.078938X15.596 Z1 5 4 44X0.084051X17.874 Z1 5 5 44X0.088047X19.956 Z1 5 1 45X0.062563X9.934 Z1 5 2 45X0.071324X13.055 Z1 5 3 45X0.077375X15.583 Z1 5 4 45X0.082406X17.867 Z1 5 5 45X0.086367X19.95 Z1 5 1 46X0.061328X9.929 Z1 5 2 46X0.069949X13.05 Z1 5 3 46X0.075875X15.573 Z1 5 4 46X0.080859X17.865 Z1 5 5 46X0.08475X19.945 Z1 5 1 47X0.060078X9.9293 Z1 5 2 47X0.068625X13.043 Z1 5 3 47X0.074375X15.574 Z1 5 4 47X0.079313X17.858 Z1 5 5 47X0.083148X19.937 Z1 5 1 48X0.058953X9.9298 Z1 5 2 48X0.067318X13.044 Z1 5 3 48X0.072988X15.568 Z1 5 4 48X0.077773X17.843 Z1 5 5 48X0.081563X19.926 Z1 5 1 49X0.057828X9.9296 Z1 5 2 49X0.066063X13.035 Z1 5 3 49X0.071676X15.561 Z1 5 4 49X0.076316X17.837 Z1 5 5 49X0.080115X19.919 Z1 5 1 50X0.056766X9.9207 Z1 5 2 50X0.06482X13.026 Z1 5 3 50X0.070375X15.557 Z1 5 4 50X0.075035X17.839 Z1 5 5 50X0.078703X19.912 Z1 10 1 1X1.5932X17.301 Z1 10 2 1X1.0834X19.222 Z1 10 3 1X0.87741X21.278 Z1 10 4 1X0.75906X23.362 Z1 10 5 1X0.67763X25.304 Z1 10 1 2X0.989X14.741 Z1 10 2 2X1.0834X19.222 Z1 10 3 2X0.87741X21.278 Z1 10 4 2X0.75906X23.362 Z1 10 5 2X0.67763X25.304 Z1 10 1 3X0.74688X13.702 Z1 10 2 3X0.83644X18.046 Z1 10 3 3X0.87741X21.278 Z1 10 4 3X0.75906X23.362 Z1 10 5 3X0.67763X25.304 Z1 10 1 4X0.60678X13.116 Z1 10 2 4X0.68903X17.347 Z1 10 3 4X0.73075X20.539 Z1 10 4 4X0.75906X23.362 Z1 10 5 4X0.67763X25.304 Z1 10 1 5X0.51483X12.709 Z1 10 2 5X0.58981X16.854 Z1 10 3 5X0.62969X20.053 Z1 10 4 5X0.65653X22.793 Z1 10 5 5X0.67763X25.304 Z1 10 1 6X0.44925X12.434 Z1 10 2 6X0.51661X16.482 Z1 10 3 6X0.55431X19.66 Z1 10 4 6X0.58122X22.396 Z1 10 5 6X0.60156X24.87 Z1 10 1 7X0.39916X12.243 Z1 10 2 7X0.46127X16.223 Z1 10 3 7X0.49669X19.375 Z1 10 4 7X0.52241X22.07 Z1 10 5 7X0.54244X24.539 Z1 10 1 8X0.35975X12.07 Z1 10 2 8X0.41677X16.015 Z1 10 3 8X0.45028X19.142 Z1 10 4 8X0.47461X21.817 Z1 10 5 8X0.49334X24.248 Z1 10 1 9X0.32842X11.954 Z1 10 2 9X0.381X15.84 Z1 10 3 9X0.41241X18.925 Z1 10 4 9X0.4353X21.576 Z1 10 5 9X0.45333X23.991 Z1 10 1 10X0.30202X11.847 Z1 10 2 10X0.35105X15.705 Z1 10 3 10X0.38035X18.738 Z1 10 4 10X0.40253X21.394 Z1 10 5 10X0.41941X23.783 Z1 10 1 11X0.27975X11.75 Z1 10 2 11X0.32521X15.569 Z1 10 3 11X0.35308X18.59 Z1 10 4 11X0.37431X21.234 Z1 10 5 11X0.39016X23.614 Z1 10 1 12X0.26058X11.673 Z1 10 2 12X0.30356X15.469 Z1 10 3 12X0.32969X18.447 Z1 10 4 12X0.34981X21.091 Z1 10 5 12X0.36538X23.46 Z1 10 1 13X0.24398X11.608 Z1 10 2 13X0.28447X15.372 Z1 10 3 13X0.30952X18.342 Z1 10 4 13X0.32872X20.98 Z1 10 5 13X0.34397X23.347 Z1 10 1 14X0.22934X11.557 Z1 10 2 14X0.26779X15.289 Z1 10 3 14X0.29156X18.237 Z1 10 4 14X0.30984X20.862 Z1 10 5 14X0.32469X23.209 Z1 10 1 15X0.21678X11.514 Z1 10 2 15X0.25291X15.216 Z1 10 3 15X0.27595X18.155 Z1 10 4 15X0.29342X20.766 Z1 10 5 15X0.3073X23.096 Z1 10 1 16X0.20534X11.471 Z1 10 2 16X0.23973X15.152 Z1 10 3 16X0.26159X18.087 Z1 10 4 16X0.27838X20.685 Z1 10 5 16X0.29181X23.006 Z1 10 1 17X0.19515X11.435 Z1 10 2 17X0.22803X15.092 Z1 10 3 17X0.24884X18.016 Z1 10 4 17X0.26481X20.614 Z1 10 5 17X0.27813X22.917 Z1 10 1 18X0.18592X11.402 Z1 10 2 18X0.2173X15.044 Z1 10 3 18X0.23749X17.955 Z1 10 4 18X0.25269X20.532 Z1 10 5 18X0.26556X22.85 Z1 10 1 19X0.17753X11.372 Z1 10 2 19X0.20757X14.992 Z1 10 3 19X0.22696X17.905 Z1 10 4 19X0.24183X20.475 Z1 10 5 19X0.25419X22.785 Z1 10 1 20X0.16994X11.346 Z1 10 2 20X0.1989X14.959 Z1 10 3 20X0.21749X17.855 Z1 10 4 20X0.23174X20.417 Z1 10 5 20X0.24355X22.715 Z1 10 1 21X0.16306X11.324 Z1 10 2 21X0.19081X14.92 Z1 10 3 21X0.20866X17.792 Z1 10 4 21X0.22238X20.36 Z1 10 5 21X0.23381X22.637 Z1 10 1 22X0.15659X11.299 Z1 10 2 22X0.18316X14.879 Z1 10 3 22X0.20054X17.746 Z1 10 4 22X0.21394X20.312 Z1 10 5 22X0.22506X22.581 Z1 10 1 23X0.15073X11.274 Z1 10 2 23X0.17638X14.857 Z1 10 3 23X0.19309X17.712 Z1 10 4 23X0.20601X20.258 Z1 10 5 23X0.21673X22.54 Z1 10 1 24X0.14519X11.249 Z1 10 2 24X0.17X14.823 Z1 10 3 24X0.18624X17.685 Z1 10 4 24X0.19869X20.218 Z1 10 5 24X0.20913X22.482 Z1 10 1 25X0.1402X11.227 Z1 10 2 25X0.16409X14.801 Z1 10 3 25X0.17969X17.64 Z1 10 4 25X0.19187X20.174 Z1 10 5 25X0.20209X22.453 Z1 10 1 26X0.13544X11.214 Z1 10 2 26X0.15856X14.774 Z1 10 3 26X0.1738X17.596 Z1 10 4 26X0.18558X20.137 Z1 10 5 26X0.19545X22.416 Z1 10 1 27X0.13106X11.206 Z1 10 2 27X0.15328X14.755 Z1 10 3 27X0.16812X17.568 Z1 10 4 27X0.17963X20.105 Z1 10 5 27X0.18929X22.387 Z1 10 1 28X0.12693X11.184 Z1 10 2 28X0.14841X14.722 Z1 10 3 28X0.1628X17.54 Z1 10 4 28X0.17405X20.067 Z1 10 5 28X0.18346X22.352 Z1 10 1 29X0.12307X11.168 Z1 10 2 29X0.14388X14.71 Z1 10 3 29X0.1579X17.51 Z1 10 4 29X0.16894X20.039 Z1 10 5 29X0.17798X22.321 Z1 10 1 30X0.11937X11.157 Z1 10 2 30X0.13967X14.687 Z1 10 3 30X0.15338X17.491 Z1 10 4 30X0.16397X20.017 Z1 10 5 30X0.17279X22.279 Z1 10 1 31X0.11596X11.148 Z1 10 2 31X0.13566X14.664 Z1 10 3 31X0.14895X17.467 Z1 10 4 31X0.15929X19.991 Z1 10 5 31X0.16789X22.251 Z1 10 1 32X0.1127X11.142 Z1 10 2 32X0.13188X14.642 Z1 10 3 32X0.14478X17.459 Z1 10 4 32X0.155X19.966 Z1 10 5 32X0.16338X22.221 Z1 10 1 33X0.10966X11.132 Z1 10 2 33X0.12835X14.627 Z1 10 3 33X0.14098X17.445 Z1 10 4 33X0.15084X19.932 Z1 10 5 33X0.15913X22.197 Z1 10 1 34X0.10675X11.129 Z1 10 2 34X0.12489X14.608 Z1 10 3 34X0.13723X17.42 Z1 10 4 34X0.14697X19.906 Z1 10 5 34X0.15497X22.168 Z1 10 1 35X0.10402X11.118 Z1 10 2 35X0.12171X14.588 Z1 10 3 35X0.13371X17.399 Z1 10 4 35X0.14327X19.883 Z1 10 5 35X0.151X22.132 Z1 10 1 36X0.10143X11.103 Z1 10 2 36X0.1186X14.568 Z1 10 3 36X0.13032X17.381 Z1 10 4 36X0.13967X19.861 Z1 10 5 36X0.14736X22.112 Z1 10 1 37X0.098977X11.093 Z1 10 2 37X0.11573X14.564 Z1 10 3 37X0.12722X17.367 Z1 10 4 37X0.13635X19.846 Z1 10 5 37X0.14386X22.099 Z1 10 1 38X0.096629X11.084 Z1 10 2 38X0.11297X14.547 Z1 10 3 38X0.12419X17.349 Z1 10 4 38X0.13317X19.825 Z1 10 5 38X0.14041X22.066 Z1 10 1 39X0.094375X11.084 Z1 10 2 39X0.11039X14.536 Z1 10 3 39X0.12136X17.329 Z1 10 4 39X0.13008X19.802 Z1 10 5 39X0.13722X22.034 Z1 10 1 40X0.092156X11.075 Z1 10 2 40X0.10791X14.531 Z1 10 3 40X0.11861X17.312 Z1 10 4 40X0.12719X19.789 Z1 10 5 40X0.13406X22.016 Z1 10 1 41X0.090156X11.071 Z1 10 2 41X0.1055X14.508 Z1 10 3 41X0.11601X17.304 Z1 10 4 41X0.12441X19.773 Z1 10 5 41X0.13125X22.007 Z1 10 1 42X0.088195X11.058 Z1 10 2 42X0.10322X14.508 Z1 10 3 42X0.11345X17.282 Z1 10 4 42X0.12175X19.752 Z1 10 5 42X0.12849X21.984 Z1 10 1 43X0.086336X11.05 Z1 10 2 43X0.101X14.495 Z1 10 3 43X0.1111X17.276 Z1 10 4 43X0.11918X19.731 Z1 10 5 43X0.12575X21.961 Z1 10 1 44X0.084531X11.04 Z1 10 2 44X0.098867X14.483 Z1 10 3 44X0.10876X17.265 Z1 10 4 44X0.11667X19.725 Z1 10 5 44X0.12322X21.951 Z1 10 1 45X0.082801X11.036 Z1 10 2 45X0.096852X14.475 Z1 10 3 45X0.10652X17.243 Z1 10 4 45X0.11432X19.705 Z1 10 5 45X0.12076X21.943 Z1 10 1 46X0.081156X11.03 Z1 10 2 46X0.094914X14.46 Z1 10 3 46X0.10442X17.226 Z1 10 4 46X0.11207X19.688 Z1 10 5 46X0.11845X21.938 Z1 10 1 47X0.079547X11.025 Z1 10 2 47X0.09307X14.456 Z1 10 3 47X0.10242X17.218 Z1 10 4 47X0.10989X19.677 Z1 10 5 47X0.11617X21.922 Z1 10 1 48X0.078016X11.022 Z1 10 2 48X0.091316X14.45 Z1 10 3 48X0.10045X17.204 Z1 10 4 48X0.10783X19.665 Z1 10 5 48X0.11398X21.907 Z1 10 1 49X0.076578X11.018 Z1 10 2 49X0.089609X14.445 Z1 10 3 49X0.098563X17.193 Z1 10 4 49X0.10586X19.661 Z1 10 5 49X0.11188X21.896 Z1 10 1 50X0.075145X11.012 Z1 10 2 50X0.087938X14.428 Z1 10 3 50X0.096727X17.179 Z1 10 4 50X0.10394X19.651 Z1 10 5 50X0.10982X21.885 Z1 15 1 1X2.3541X22.378 Z1 15 2 1X1.5106X23.163 Z1 15 3 1X1.1938X24.864 Z1 15 4 1X1.0173X26.791 Z1 15 5 1X0.899X28.643 Z1 15 1 2X1.3124X17.582 Z1 15 2 2X1.5106X23.163 Z1 15 3 2X1.1938X24.864 Z1 15 4 2X1.0173X26.791 Z1 15 5 2X0.899X28.643 Z1 15 1 3X0.94928X15.797 Z1 15 2 3X1.1093X21.008 Z1 15 3 3X1.1938X24.864 Z1 15 4 3X1.0173X26.791 Z1 15 5 3X0.899X28.643 Z1 15 1 4X0.75359X14.845 Z1 15 2 4X0.88825X19.808 Z1 15 3 4X0.96425X23.55 Z1 15 4 4X1.0173X26.791 Z1 15 5 4X0.899X28.643 Z1 15 1 5X0.62897X14.205 Z1 15 2 5X0.74506X18.975 Z1 15 3 5X0.81313X22.661 Z1 15 4 5X0.86213X25.812 Z1 15 5 5X0.899X28.643 Z1 15 1 6X0.542X13.772 Z1 15 2 6X0.64563X18.419 Z1 15 3 6X0.70659X22.028 Z1 15 4 6X0.75081X25.122 Z1 15 5 6X0.78531X27.894 Z1 15 1 7X0.47794X13.469 Z1 15 2 7X0.57078X17.999 Z1 15 3 7X0.626X21.569 Z1 15 4 7X0.6665X24.576 Z1 15 5 7X0.69913X27.333 Z1 15 1 8X0.42803X13.208 Z1 15 2 8X0.51153X17.665 Z1 15 3 8X0.56219X21.164 Z1 15 4 8X0.59972X24.166 Z1 15 5 8X0.63005X26.846 Z1 15 1 9X0.38764X13 Z1 15 2 9X0.46464X17.401 Z1 15 3 9X0.5115X20.824 Z1 15 4 9X0.54641X23.789 Z1 15 5 9X0.57486X26.464 Z1 15 1 10X0.35509X12.857 Z1 15 2 10X0.42563X17.181 Z1 15 3 10X0.46925X20.554 Z1 15 4 10X0.50188X23.486 Z1 15 5 10X0.52878X26.135 Z1 15 1 11X0.32747X12.708 Z1 15 2 11X0.393X16.997 Z1 15 3 11X0.43369X20.329 Z1 15 4 11X0.46433X23.233 Z1 15 5 11X0.48975X25.869 Z1 15 1 12X0.30408X12.596 Z1 15 2 12X0.36539X16.835 Z1 15 3 12X0.40338X20.131 Z1 15 4 12X0.43234X23.029 Z1 15 5 12X0.45603X25.628 Z1 15 1 13X0.28403X12.499 Z1 15 2 13X0.34127X16.706 Z1 15 3 13X0.37709X19.961 Z1 15 4 13X0.40444X22.842 Z1 15 5 13X0.42707X25.431 Z1 15 1 14X0.26654X12.418 Z1 15 2 14X0.32017X16.57 Z1 15 3 14X0.35425X19.81 Z1 15 4 14X0.38021X22.678 Z1 15 5 14X0.40159X25.224 Z1 15 1 15X0.25122X12.349 Z1 15 2 15X0.3019X16.463 Z1 15 3 15X0.33409X19.68 Z1 15 4 15X0.35867X22.522 Z1 15 5 15X0.37913X25.044 Z1 15 1 16X0.23734X12.283 Z1 15 2 16X0.28575X16.372 Z1 15 3 16X0.31614X19.571 Z1 15 4 16X0.33969X22.397 Z1 15 5 16X0.35891X24.904 Z1 15 1 17X0.22531X12.237 Z1 15 2 17X0.27131X16.285 Z1 15 3 17X0.30011X19.467 Z1 15 4 17X0.32273X22.3 Z1 15 5 17X0.34094X24.768 Z1 15 1 18X0.21444X12.189 Z1 15 2 18X0.25784X16.205 Z1 15 3 18X0.28561X19.363 Z1 15 4 18X0.30713X22.172 Z1 15 5 18X0.32466X24.659 Z1 15 1 19X0.20455X12.131 Z1 15 2 19X0.24606X16.138 Z1 15 3 19X0.27257X19.302 Z1 15 4 19X0.29314X22.067 Z1 15 5 19X0.30997X24.548 Z1 15 1 20X0.19556X12.106 Z1 15 2 20X0.23514X16.061 Z1 15 3 20X0.26066X19.218 Z1 15 4 20X0.28022X21.972 Z1 15 5 20X0.29673X24.459 Z1 15 1 21X0.18734X12.073 Z1 15 2 21X0.22531X16.008 Z1 15 3 21X0.24972X19.136 Z1 15 4 21X0.26865X21.913 Z1 15 5 21X0.28456X24.351 Z1 15 1 22X0.17987X12.035 Z1 15 2 22X0.21623X15.964 Z1 15 3 22X0.23975X19.067 Z1 15 4 22X0.25804X21.836 Z1 15 5 22X0.27334X24.271 Z1 15 1 23X0.17293X12 Z1 15 2 23X0.20785X15.913 Z1 15 3 23X0.23056X19.01 Z1 15 4 23X0.24831X21.776 Z1 15 5 23X0.26305X24.209 Z1 15 1 24X0.1665X11.958 Z1 15 2 24X0.20013X15.873 Z1 15 3 24X0.222X18.962 Z1 15 4 24X0.23914X21.702 Z1 15 5 24X0.2535X24.137 Z1 15 1 25X0.16063X11.931 Z1 15 2 25X0.19301X15.84 Z1 15 3 25X0.21413X18.915 Z1 15 4 25X0.23077X21.654 Z1 15 5 25X0.24456X24.068 Z1 15 1 26X0.15506X11.907 Z1 15 2 26X0.18641X15.795 Z1 15 3 26X0.20675X18.855 Z1 15 4 26X0.22288X21.583 Z1 15 5 26X0.23634X24.011 Z1 15 1 27X0.14998X11.891 Z1 15 2 27X0.18016X15.777 Z1 15 3 27X0.1998X18.805 Z1 15 4 27X0.21563X21.535 Z1 15 5 27X0.22864X23.962 Z1 15 1 28X0.14514X11.864 Z1 15 2 28X0.17438X15.74 Z1 15 3 28X0.19344X18.763 Z1 15 4 28X0.20863X21.48 Z1 15 5 28X0.22141X23.915 Z1 15 1 29X0.14061X11.855 Z1 15 2 29X0.16897X15.71 Z1 15 3 29X0.18747X18.733 Z1 15 4 29X0.20219X21.429 Z1 15 5 29X0.21465X23.883 Z1 15 1 30X0.13641X11.841 Z1 15 2 30X0.16392X15.686 Z1 15 3 30X0.18191X18.701 Z1 15 4 30X0.19619X21.408 Z1 15 5 30X0.20839X23.834 Z1 15 1 31X0.1325X11.823 Z1 15 2 31X0.15906X15.646 Z1 15 3 31X0.17659X18.664 Z1 15 4 31X0.19051X21.363 Z1 15 5 31X0.2023X23.772 Z1 15 1 32X0.12874X11.811 Z1 15 2 32X0.15459X15.62 Z1 15 3 32X0.17158X18.635 Z1 15 4 32X0.18506X21.317 Z1 15 5 32X0.19658X23.738 Z1 15 1 33X0.12517X11.8 Z1 15 2 33X0.15039X15.593 Z1 15 3 33X0.16692X18.617 Z1 15 4 33X0.18005X21.286 Z1 15 5 33X0.19131X23.688 Z1 15 1 34X0.12188X11.794 Z1 15 2 34X0.14633X15.564 Z1 15 3 34X0.16243X18.585 Z1 15 4 34X0.17517X21.233 Z1 15 5 34X0.18629X23.658 Z1 15 1 35X0.1187X11.781 Z1 15 2 35X0.14244X15.543 Z1 15 3 35X0.1582X18.547 Z1 15 4 35X0.17064X21.189 Z1 15 5 35X0.18145X23.609 Z1 15 1 36X0.1157X11.768 Z1 15 2 36X0.13888X15.521 Z1 15 3 36X0.15414X18.527 Z1 15 4 36X0.16638X21.168 Z1 15 5 36X0.17682X23.568 Z1 15 1 37X0.11289X11.754 Z1 15 2 37X0.13545X15.503 Z1 15 3 37X0.15039X18.505 Z1 15 4 37X0.16232X21.154 Z1 15 5 37X0.17252X23.542 Z1 15 1 38X0.11018X11.742 Z1 15 2 38X0.13214X15.488 Z1 15 3 38X0.14678X18.483 Z1 15 4 38X0.15836X21.125 Z1 15 5 38X0.16832X23.509 Z1 15 1 39X0.10759X11.733 Z1 15 2 39X0.12902X15.467 Z1 15 3 39X0.14325X18.455 Z1 15 4 39X0.15468X21.092 Z1 15 5 39X0.1645X23.47 Z1 15 1 40X0.10514X11.731 Z1 15 2 40X0.12601X15.456 Z1 15 3 40X0.14003X18.429 Z1 15 4 40X0.15122X21.069 Z1 15 5 40X0.16077X23.443 Z1 15 1 41X0.10275X11.718 Z1 15 2 41X0.12323X15.438 Z1 15 3 41X0.13691X18.417 Z1 15 4 41X0.1478X21.041 Z1 15 5 41X0.1572X23.423 Z1 15 1 42X0.1005X11.702 Z1 15 2 42X0.12054X15.429 Z1 15 3 42X0.13397X18.403 Z1 15 4 42X0.14456X21.011 Z1 15 5 42X0.1537X23.389 Z1 15 1 43X0.098359X11.691 Z1 15 2 43X0.11794X15.414 Z1 15 3 43X0.13107X18.379 Z1 15 4 43X0.14149X20.987 Z1 15 5 43X0.15041X23.363 Z1 15 1 44X0.096313X11.682 Z1 15 2 44X0.11544X15.398 Z1 15 3 44X0.12831X18.36 Z1 15 4 44X0.13848X20.972 Z1 15 5 44X0.14724X23.338 Z1 15 1 45X0.094344X11.673 Z1 15 2 45X0.11308X15.389 Z1 15 3 45X0.12563X18.335 Z1 15 4 45X0.13567X20.963 Z1 15 5 45X0.14422X23.323 Z1 15 1 46X0.092496X11.668 Z1 15 2 46X0.11081X15.368 Z1 15 3 46X0.12313X18.321 Z1 15 4 46X0.13295X20.942 Z1 15 5 46X0.14134X23.3 Z1 15 1 47X0.090684X11.659 Z1 15 2 47X0.10861X15.356 Z1 15 3 47X0.12068X18.303 Z1 15 4 47X0.13038X20.917 Z1 15 5 47X0.13857X23.288 Z1 15 1 48X0.088926X11.654 Z1 15 2 48X0.10652X15.345 Z1 15 3 48X0.11834X18.292 Z1 15 4 48X0.12783X20.901 Z1 15 5 48X0.13596X23.265 Z1 15 1 49X0.087188X11.644 Z1 15 2 49X0.10448X15.336 Z1 15 3 49X0.11613X18.278 Z1 15 4 49X0.12542X20.877 Z1 15 5 49X0.1334X23.245 Z1 15 1 50X0.085609X11.644 Z1 15 2 50X0.10255X15.322 Z1 15 3 50X0.11398X18.262 Z1 15 4 50X0.12307X20.87 Z1 15 5 50X0.13093X23.219 Z1 20 1 1X3.216X28.128 Z1 20 2 1X1.9464X27.184 Z1 20 3 1X1.506X28.403 Z1 20 4 1X1.265X30.081 Z1 20 5 1X1.1076X31.788 Z1 20 1 2X1.6368X20.477 Z1 20 2 2X1.9464X27.184 Z1 20 3 2X1.506X28.403 Z1 20 4 2X1.265X30.081 Z1 20 5 2X1.1076X31.788 Z1 20 1 3X1.1392X17.815 Z1 20 2 3X1.3695X23.871 Z1 20 3 3X1.506X28.403 Z1 20 4 3X1.265X30.081 Z1 20 5 3X1.1076X31.788 Z1 20 1 4X0.88694X16.443 Z1 20 2 4X1.0719X22.094 Z1 20 3 4X1.1832X26.403 Z1 20 4 4X1.265X30.081 Z1 20 5 4X1.1076X31.788 Z1 20 1 5X0.72981X15.562 Z1 20 2 5X0.88441X20.909 Z1 20 3 5X0.98031X25.064 Z1 20 4 5X1.0518X28.605 Z1 20 5 5X1.1076X31.788 Z1 20 1 6X0.623X14.963 Z1 20 2 6X0.75684X20.118 Z1 20 3 6X0.84144X24.145 Z1 20 4 6X0.90442X27.593 Z1 20 5 6X0.955X30.701 Z1 20 1 7X0.54463X14.532 Z1 20 2 7X0.66391X19.538 Z1 20 3 7X0.73913X23.492 Z1 20 4 7X0.79544X26.838 Z1 20 5 7X0.841X29.875 Z1 20 1 8X0.48481X14.181 Z1 20 2 8X0.59183X19.116 Z1 20 3 8X0.65914X22.942 Z1 20 4 8X0.71059X26.251 Z1 20 5 8X0.7522X29.188 Z1 20 1 9X0.43769X13.918 Z1 20 2 9X0.53452X18.741 Z1 20 3 9X0.59594X22.482 Z1 20 4 9X0.64319X25.734 Z1 20 5 9X0.68167X28.665 Z1 20 1 10X0.39884X13.696 Z1 20 2 10X0.48777X18.449 Z1 20 3 10X0.54419X22.114 Z1 20 4 10X0.58766X25.312 Z1 20 5 10X0.62347X28.183 Z1 20 1 11X0.36666X13.515 Z1 20 2 11X0.44848X18.188 Z1 20 3 11X0.50116X21.819 Z1 20 4 11X0.54131X24.979 Z1 20 5 11X0.57478X27.814 Z1 20 1 12X0.33956X13.369 Z1 20 2 12X0.41569X17.977 Z1 20 3 12X0.46448X21.537 Z1 20 4 12X0.50228X24.699 Z1 20 5 12X0.53359X27.508 Z1 20 1 13X0.31646X13.24 Z1 20 2 13X0.38727X17.787 Z1 20 3 13X0.43309X21.315 Z1 20 4 13X0.46819X24.437 Z1 20 5 13X0.49813X27.232 Z1 20 1 14X0.2962X13.128 Z1 20 2 14X0.36269X17.63 Z1 20 3 14X0.40548X21.104 Z1 20 4 14X0.43888X24.189 Z1 20 5 14X0.46713X26.955 Z1 20 1 15X0.27856X13.028 Z1 20 2 15X0.34106X17.472 Z1 20 3 15X0.38152X20.939 Z1 20 4 15X0.41341X24.004 Z1 20 5 15X0.43981X26.713 Z1 20 1 16X0.26283X12.939 Z1 20 2 16X0.32195X17.344 Z1 20 3 16X0.36037X20.787 Z1 20 4 16X0.39042X23.831 Z1 20 5 16X0.4158X26.546 Z1 20 1 17X0.24891X12.869 Z1 20 2 17X0.30489X17.231 Z1 20 3 17X0.34136X20.643 Z1 20 4 17X0.36995X23.68 Z1 20 5 17X0.39394X26.35 Z1 20 1 18X0.2365X12.799 Z1 20 2 18X0.28976X17.133 Z1 20 3 18X0.32442X20.521 Z1 20 4 18X0.35166X23.521 Z1 20 5 18X0.37464X26.201 Z1 20 1 19X0.22531X12.732 Z1 20 2 19X0.27613X17.039 Z1 20 3 19X0.30913X20.414 Z1 20 4 19X0.33517X23.398 Z1 20 5 19X0.35681X26.053 Z1 20 1 20X0.21506X12.68 Z1 20 2 20X0.26356X16.964 Z1 20 3 20X0.29531X20.319 Z1 20 4 20X0.32002X23.274 Z1 20 5 20X0.34072X25.921 Z1 20 1 21X0.2058X12.639 Z1 20 2 21X0.25228X16.884 Z1 20 3 21X0.28254X20.24 Z1 20 4 21X0.30631X23.188 Z1 20 5 21X0.32629X25.777 Z1 20 1 22X0.19738X12.594 Z1 20 2 22X0.24184X16.814 Z1 20 3 22X0.27091X20.142 Z1 20 4 22X0.29384X23.09 Z1 20 5 22X0.31308X25.668 Z1 20 1 23X0.1897X12.553 Z1 20 2 23X0.23245X16.759 Z1 20 3 23X0.26025X20.064 Z1 20 4 23X0.2823X22.994 Z1 20 5 23X0.30094X25.59 Z1 20 1 24X0.1825X12.505 Z1 20 2 24X0.22361X16.702 Z1 20 3 24X0.25041X19.997 Z1 20 4 24X0.27165X22.908 Z1 20 5 24X0.28942X25.487 Z1 20 1 25X0.17582X12.465 Z1 20 2 25X0.21544X16.651 Z1 20 3 25X0.24129X19.931 Z1 20 4 25X0.26184X22.834 Z1 20 5 25X0.27909X25.403 Z1 20 1 26X0.16966X12.43 Z1 20 2 26X0.20784X16.601 Z1 20 3 26X0.23275X19.861 Z1 20 4 26X0.25267X22.758 Z1 20 5 26X0.26929X25.319 Z1 20 1 27X0.164X12.407 Z1 20 2 27X0.20081X16.565 Z1 20 3 27X0.22504X19.811 Z1 20 4 27X0.24409X22.682 Z1 20 5 27X0.2603X25.252 Z1 20 1 28X0.15867X12.384 Z1 20 2 28X0.19428X16.523 Z1 20 3 28X0.21766X19.755 Z1 20 4 28X0.23606X22.614 Z1 20 5 28X0.25183X25.184 Z1 20 1 29X0.15359X12.361 Z1 20 2 29X0.18803X16.481 Z1 20 3 29X0.21075X19.705 Z1 20 4 29X0.22863X22.555 Z1 20 5 29X0.24399X25.137 Z1 20 1 30X0.14891X12.345 Z1 20 2 30X0.18228X16.443 Z1 20 3 30X0.2043X19.659 Z1 20 4 30X0.22175X22.518 Z1 20 5 30X0.23664X25.073 Z1 20 1 31X0.1445X12.323 Z1 20 2 31X0.17688X16.406 Z1 20 3 31X0.19819X19.607 Z1 20 4 31X0.21523X22.46 Z1 20 5 31X0.22972X25.009 Z1 20 1 32X0.14038X12.301 Z1 20 2 32X0.17173X16.364 Z1 20 3 32X0.19252X19.566 Z1 20 4 32X0.20905X22.41 Z1 20 5 32X0.22308X24.944 Z1 20 1 33X0.13645X12.289 Z1 20 2 33X0.16696X16.331 Z1 20 3 33X0.18714X19.543 Z1 20 4 33X0.20325X22.361 Z1 20 5 33X0.21688X24.892 Z1 20 1 34X0.13269X12.273 Z1 20 2 34X0.16238X16.292 Z1 20 3 34X0.18205X19.501 Z1 20 4 34X0.1977X22.305 Z1 20 5 34X0.21098X24.834 Z1 20 1 35X0.12925X12.262 Z1 20 2 35X0.15808X16.267 Z1 20 3 35X0.17728X19.455 Z1 20 4 35X0.19244X22.254 Z1 20 5 35X0.20538X24.787 Z1 20 1 36X0.12592X12.245 Z1 20 2 36X0.15403X16.238 Z1 20 3 36X0.17267X19.437 Z1 20 4 36X0.18747X22.22 Z1 20 5 36X0.20016X24.728 Z1 20 1 37X0.12278X12.225 Z1 20 2 37X0.15016X16.222 Z1 20 3 37X0.16835X19.405 Z1 20 4 37X0.18278X22.175 Z1 20 5 37X0.19517X24.691 Z1 20 1 38X0.11982X12.214 Z1 20 2 38X0.1465X16.197 Z1 20 3 38X0.16423X19.369 Z1 20 4 38X0.17838X22.146 Z1 20 5 38X0.19045X24.654 Z1 20 1 39X0.11698X12.203 Z1 20 2 39X0.14298X16.175 Z1 20 3 39X0.1603X19.33 Z1 20 4 39X0.17402X22.11 Z1 20 5 39X0.18584X24.605 Z1 20 1 40X0.11426X12.188 Z1 20 2 40X0.13968X16.159 Z1 20 3 40X0.15655X19.297 Z1 20 4 40X0.16998X22.08 Z1 20 5 40X0.18158X24.576 Z1 20 1 41X0.11169X12.177 Z1 20 2 41X0.13656X16.147 Z1 20 3 41X0.15298X19.284 Z1 20 4 41X0.1662X22.054 Z1 20 5 41X0.1775X24.542 Z1 20 1 42X0.10923X12.158 Z1 20 2 42X0.13352X16.134 Z1 20 3 42X0.14953X19.25 Z1 20 4 42X0.16251X22.008 Z1 20 5 42X0.17354X24.507 Z1 20 1 43X0.10687X12.15 Z1 20 2 43X0.13053X16.104 Z1 20 3 43X0.14627X19.23 Z1 20 4 43X0.15898X21.987 Z1 20 5 43X0.16977X24.471 Z1 20 1 44X0.10461X12.136 Z1 20 2 44X0.12779X16.083 Z1 20 3 44X0.14317X19.212 Z1 20 4 44X0.15555X21.958 Z1 20 5 44X0.16613X24.443 Z1 20 1 45X0.10245X12.126 Z1 20 2 45X0.12512X16.075 Z1 20 3 45X0.14022X19.184 Z1 20 4 45X0.15229X21.94 Z1 20 5 45X0.16272X24.407 Z1 20 1 46X0.10037X12.112 Z1 20 2 46X0.12262X16.057 Z1 20 3 46X0.13739X19.16 Z1 20 4 46X0.1492X21.914 Z1 20 5 46X0.15938X24.385 Z1 20 1 47X0.098391X12.104 Z1 20 2 47X0.12018X16.038 Z1 20 3 47X0.13465X19.145 Z1 20 4 47X0.14623X21.885 Z1 20 5 47X0.15622X24.363 Z1 20 1 48X0.096484X12.094 Z1 20 2 48X0.1178X16.021 Z1 20 3 48X0.13203X19.134 Z1 20 4 48X0.14341X21.871 Z1 20 5 48X0.15312X24.344 Z1 20 1 49X0.094637X12.088 Z1 20 2 49X0.11557X16.013 Z1 20 3 49X0.12952X19.116 Z1 20 4 49X0.14064X21.844 Z1 20 5 49X0.15019X24.315 Z1 20 1 50X0.092875X12.086 Z1 20 2 50X0.11338X16.003 Z1 20 3 50X0.12705X19.092 Z1 20 4 50X0.13799X21.824 Z1 20 5 50X0.14739X24.288 Z5 1 1 1X0.083375X4.174 Z5 1 2 1X0.063438X6.3836 Z5 1 3 1X0.053438X8.2464 Z5 1 4 1X0.048X9.9586 Z5 1 5 1X0.043469X11.562 Z5 1 1 2X0.064063X4.1667 Z5 1 2 2X0.063438X6.3836 Z5 1 3 2X0.053438X8.2464 Z5 1 4 2X0.048X9.9586 Z5 1 5 2X0.043469X11.562 Z5 1 1 3X0.052313X4.1625 Z5 1 2 3X0.053688X6.3821 Z5 1 3 3X0.053438X8.2464 Z5 1 4 3X0.048X9.9586 Z5 1 5 3X0.043469X11.562 Z5 1 1 4X0.043969X4.157 Z5 1 2 4X0.046344X6.3778 Z5 1 3 4X0.047063X8.2441 Z5 1 4 4X0.048X9.9586 Z5 1 5 4X0.043469X11.562 Z5 1 1 5X0.038313X4.1567 Z5 1 2 5X0.041188X6.3748 Z5 1 3 5X0.041813X8.2413 Z5 1 4 5X0.043094X9.954 Z5 1 5 5X0.043469X11.562 Z5 1 1 6X0.033844X4.1557 Z5 1 2 6X0.037X6.3766 Z5 1 3 6X0.038047X8.2405 Z5 1 4 6X0.039281X9.9538 Z5 1 5 6X0.039688X11.558 Z5 1 1 7X0.030344X4.1542 Z5 1 2 7X0.033406X6.3733 Z5 1 3 7X0.034609X8.2363 Z5 1 4 7X0.035938X9.9505 Z5 1 5 7X0.0365X11.557 Z5 1 1 8X0.027438X4.1521 Z5 1 2 8X0.030547X6.3735 Z5 1 3 8X0.031813X8.2359 Z5 1 4 8X0.033219X9.9517 Z5 1 5 8X0.033688X11.557 Z5 1 1 9X0.025031X4.1511 Z5 1 2 9X0.028156X6.3731 Z5 1 3 9X0.029406X8.2347 Z5 1 4 9X0.03075X9.9481 Z5 1 5 9X0.031344X11.554 Z5 1 1 10X0.023109X4.1517 Z5 1 2 10X0.026063X6.3713 Z5 1 3 10X0.027344X8.2326 Z5 1 4 10X0.028688X9.9486 Z5 1 5 10X0.029328X11.555 Z5 1 1 11X0.021406X4.1504 Z5 1 2 11X0.024375X6.3729 Z5 1 3 11X0.025586X8.2316 Z5 1 4 11X0.026797X9.9453 Z5 1 5 11X0.027609X11.555 Z5 1 1 12X0.019969X4.1506 Z5 1 2 12X0.02275X6.3704 Z5 1 3 12X0.023969X8.2306 Z5 1 4 12X0.025219X9.944 Z5 1 5 12X0.025969X11.554 Z5 1 1 13X0.018734X4.1519 Z5 1 2 13X0.021289X6.3694 Z5 1 3 13X0.022625X8.2316 Z5 1 4 13X0.023922X9.9458 Z5 1 5 13X0.024563X11.551 Z5 1 1 14X0.017625X4.1522 Z5 1 2 14X0.020125X6.368 Z5 1 3 14X0.021375X8.231 Z5 1 4 14X0.022688X9.9445 Z5 1 5 14X0.023281X11.553 Z5 1 1 15X0.016625X4.1514 Z5 1 2 15X0.019023X6.3681 Z5 1 3 15X0.020234X8.2308 Z5 1 4 15X0.021609X9.9445 Z5 1 5 15X0.022188X11.552 Z5 1 1 16X0.015719X4.1514 Z5 1 2 16X0.018047X6.3664 Z5 1 3 16X0.019234X8.2298 Z5 1 4 16X0.020531X9.9436 Z5 1 5 16X0.021156X11.551 Z5 1 1 17X0.014906X4.1501 Z5 1 2 17X0.017203X6.3672 Z5 1 3 17X0.018391X8.2296 Z5 1 4 17X0.019633X9.944 Z5 1 5 17X0.02025X11.55 Z5 1 1 18X0.014188X4.1506 Z5 1 2 18X0.016328X6.3645 Z5 1 3 18X0.017625X8.2309 Z5 1 4 18X0.018742X9.943 Z5 1 5 18X0.019438X11.552 Z5 1 1 19X0.013609X4.1523 Z5 1 2 19X0.015625X6.3653 Z5 1 3 19X0.016828X8.2291 Z5 1 4 19X0.017922X9.9413 Z5 1 5 19X0.018656X11.552 Z5 1 1 20X0.013016X4.1509 Z5 1 2 20X0.014969X6.3652 Z5 1 3 20X0.016141X8.2288 Z5 1 4 20X0.017234X9.9413 Z5 1 5 20X0.017891X11.55 Z5 1 1 21X0.012453X4.1508 Z5 1 2 21X0.014391X6.3671 Z5 1 3 21X0.015563X8.2297 Z5 1 4 21X0.016578X9.9426 Z5 1 5 21X0.01725X11.55 Z5 1 1 22X0.011938X4.1504 Z5 1 2 22X0.013836X6.3658 Z5 1 3 22X0.014984X8.23 Z5 1 4 22X0.016016X9.9431 Z5 1 5 22X0.016586X11.549 Z5 1 1 23X0.011438X4.15 Z5 1 2 23X0.01332X6.3649 Z5 1 3 23X0.014391X8.2279 Z5 1 4 23X0.015477X9.9431 Z5 1 5 23X0.016063X11.55 Z5 1 1 24X0.011031X4.1505 Z5 1 2 24X0.012844X6.365 Z5 1 3 24X0.013891X8.2293 Z5 1 4 24X0.01493X9.9426 Z5 1 5 24X0.01552X11.55 Z5 1 1 25X0.010641X4.1503 Z5 1 2 25X0.012375X6.3638 Z5 1 3 25X0.013375X8.2273 Z5 1 4 25X0.014398X9.9401 Z5 1 5 25X0.014984X11.549 Z5 1 1 26X0.010281X4.1505 Z5 1 2 26X0.012X6.3638 Z5 1 3 26X0.012938X8.2269 Z5 1 4 26X0.013938X9.9397 Z5 1 5 26X0.014516X11.549 Z5 1 1 27X0.0098906X4.15 Z5 1 2 27X0.011586X6.3639 Z5 1 3 27X0.012516X8.227 Z5 1 4 27X0.013492X9.9392 Z5 1 5 27X0.014055X11.547 Z5 1 1 28X0.0095313X4.1488 Z5 1 2 28X0.011219X6.3634 Z5 1 3 28X0.012164X8.2294 Z5 1 4 28X0.013094X9.9392 Z5 1 5 28X0.013656X11.546 Z5 1 1 29X0.0092422X4.1496 Z5 1 2 29X0.010891X6.3648 Z5 1 3 29X0.011797X8.2287 Z5 1 4 29X0.012688X9.939 Z5 1 5 29X0.01325X11.546 Z5 1 1 30X0.0089688X4.1492 Z5 1 2 30X0.010547X6.3635 Z5 1 3 30X0.011469X8.2284 Z5 1 4 30X0.012359X9.9397 Z5 1 5 30X0.012891X11.547 Z5 1 1 31X0.0086992X4.1491 Z5 1 2 31X0.010246X6.3624 Z5 1 3 31X0.011164X8.2293 Z5 1 4 31X0.012031X9.9393 Z5 1 5 31X0.012539X11.546 Z5 1 1 32X0.0084219X4.1484 Z5 1 2 32X0.0099375X6.3613 Z5 1 3 32X0.010844X8.228 Z5 1 4 32X0.011703X9.9405 Z5 1 5 32X0.012211X11.547 Z5 1 1 33X0.0082031X4.1479 Z5 1 2 33X0.0096797X6.3613 Z5 1 3 33X0.010563X8.23 Z5 1 4 33X0.011383X9.9398 Z5 1 5 33X0.011891X11.546 Z5 1 1 34X0.0079375X4.1456 Z5 1 2 34X0.0094219X6.3616 Z5 1 3 34X0.010285X8.2288 Z5 1 4 34X0.011125X9.9408 Z5 1 5 34X0.011566X11.545 Z5 1 1 35X0.0077656X4.1478 Z5 1 2 35X0.0091953X6.361 Z5 1 3 35X0.010031X8.2283 Z5 1 4 35X0.010813X9.9392 Z5 1 5 35X0.011313X11.546 Z5 1 1 36X0.0075664X4.1483 Z5 1 2 36X0.0089766X6.3623 Z5 1 3 36X0.0097695X8.2284 Z5 1 4 36X0.01057X9.9408 Z5 1 5 36X0.011031X11.546 Z5 1 1 37X0.0073828X4.1487 Z5 1 2 37X0.0087578X6.362 Z5 1 3 37X0.0095313X8.227 Z5 1 4 37X0.010289X9.9381 Z5 1 5 37X0.010793X11.547 Z5 1 1 38X0.0072188X4.149 Z5 1 2 38X0.0085469X6.3621 Z5 1 3 38X0.0093047X8.2274 Z5 1 4 38X0.010063X9.9393 Z5 1 5 38X0.010539X11.548 Z5 1 1 39X0.007043X4.1478 Z5 1 2 39X0.0083359X6.3619 Z5 1 3 39X0.0090938X8.2274 Z5 1 4 39X0.0098203X9.9376 Z5 1 5 39X0.010281X11.546 Z5 1 1 40X0.006875X4.1477 Z5 1 2 40X0.008125X6.3617 Z5 1 3 40X0.0088867X8.226 Z5 1 4 40X0.0096016X9.9381 Z5 1 5 40X0.010051X11.545 Z5 1 1 41X0.006707X4.1474 Z5 1 2 41X0.0079688X6.3621 Z5 1 3 41X0.0087031X8.2284 Z5 1 4 41X0.0094063X9.9392 Z5 1 5 41X0.0098516X11.546 Z5 1 1 42X0.0065547X4.1469 Z5 1 2 42X0.0078125X6.3617 Z5 1 3 42X0.0085156X8.228 Z5 1 4 42X0.0092109X9.9384 Z5 1 5 42X0.0096445X11.545 Z5 1 1 43X0.0064258X4.1481 Z5 1 2 43X0.0076445X6.3627 Z5 1 3 43X0.0083398X8.2285 Z5 1 4 43X0.0090156X9.9371 Z5 1 5 43X0.0094453X11.544 Z5 1 1 44X0.0063008X4.1486 Z5 1 2 44X0.0075X6.3623 Z5 1 3 44X0.0081406X8.2271 Z5 1 4 44X0.0088438X9.9374 Z5 1 5 44X0.0092734X11.546 Z5 1 1 45X0.0061641X4.1477 Z5 1 2 45X0.0073281X6.3615 Z5 1 3 45X0.0079688X8.2261 Z5 1 4 45X0.0086563X9.9363 Z5 1 5 45X0.0090938X11.547 Z5 1 1 46X0.0060391X4.1481 Z5 1 2 46X0.0071563X6.3602 Z5 1 3 46X0.0078125X8.2262 Z5 1 4 46X0.0085X9.9384 Z5 1 5 46X0.008918X11.547 Z5 1 1 47X0.0059258X4.1486 Z5 1 2 47X0.0070156X6.3602 Z5 1 3 47X0.0076563X8.2262 Z5 1 4 47X0.0083281X9.9379 Z5 1 5 47X0.0087578X11.547 Z5 1 1 48X0.0058125X4.1488 Z5 1 2 48X0.0068984X6.3615 Z5 1 3 48X0.0075234X8.2269 Z5 1 4 48X0.0081875X9.9395 Z5 1 5 48X0.0085625X11.545 Z5 1 1 49X0.0056875X4.1474 Z5 1 2 49X0.0067617X6.3622 Z5 1 3 49X0.0073906X8.2265 Z5 1 4 49X0.008X9.9378 Z5 1 5 49X0.0084375X11.547 Z5 1 1 50X0.0055938X4.1489 Z5 1 2 50X0.0066328X6.3629 Z5 1 3 50X0.00725X8.2254 Z5 1 4 50X0.0078594X9.938 Z5 1 5 50X0.0082656X11.546 Z5 2 1 1X0.16763X4.4986 Z5 2 2 1X0.12481X6.7521 Z5 2 3 1X0.10559X8.6546 Z5 2 4 1X0.093438X10.39 Z5 2 5 1X0.084438X12.016 Z5 2 1 2X0.1255X4.4701 Z5 2 2 2X0.12481X6.7521 Z5 2 3 2X0.10559X8.6546 Z5 2 4 2X0.093438X10.39 Z5 2 5 2X0.084438X12.016 Z5 2 1 3X0.10131X4.4591 Z5 2 2 3X0.10444X6.7428 Z5 2 3 3X0.10559X8.6546 Z5 2 4 3X0.093438X10.39 Z5 2 5 3X0.084438X12.016 Z5 2 1 4X0.085125X4.4495 Z5 2 2 4X0.089625X6.7303 Z5 2 3 4X0.091859X8.6418 Z5 2 4 4X0.093438X10.39 Z5 2 5 4X0.084438X12.016 Z5 2 1 5X0.0735X4.4432 Z5 2 2 5X0.078844X6.7209 Z5 2 3 5X0.081688X8.6331 Z5 2 4 5X0.083609X10.384 Z5 2 5 5X0.084438X12.016 Z5 2 1 6X0.064656X4.4379 Z5 2 2 6X0.07025X6.7135 Z5 2 3 6X0.073313X8.6214 Z5 2 4 6X0.075625X10.375 Z5 2 5 6X0.076688X12.004 Z5 2 1 7X0.057969X4.4338 Z5 2 2 7X0.063422X6.7105 Z5 2 3 7X0.066563X8.6193 Z5 2 4 7X0.068969X10.367 Z5 2 5 7X0.070313X12.004 Z5 2 1 8X0.052375X4.4292 Z5 2 2 8X0.057625X6.7041 Z5 2 3 8X0.060969X8.614 Z5 2 4 8X0.063453X10.365 Z5 2 5 8X0.065063X12.003 Z5 2 1 9X0.047813X4.43 Z5 2 2 9X0.052969X6.7043 Z5 2 3 9X0.056422X8.6112 Z5 2 4 9X0.058906X10.362 Z5 2 5 9X0.060344X11.999 Z5 2 1 10X0.043813X4.4249 Z5 2 2 10X0.049094X6.7041 Z5 2 3 10X0.052563X8.6086 Z5 2 4 10X0.054813X10.358 Z5 2 5 10X0.056172X11.992 Z5 2 1 11X0.040438X4.4207 Z5 2 2 11X0.045578X6.6993 Z5 2 3 11X0.048969X8.6048 Z5 2 4 11X0.051375X10.356 Z5 2 5 11X0.05275X11.991 Z5 2 1 12X0.037719X4.4202 Z5 2 2 12X0.042688X6.6969 Z5 2 3 12X0.045813X8.599 Z5 2 4 12X0.048328X10.357 Z5 2 5 12X0.049656X11.986 Z5 2 1 13X0.035297X4.4182 Z5 2 2 13X0.040156X6.6959 Z5 2 3 13X0.043219X8.6012 Z5 2 4 13X0.045594X10.354 Z5 2 5 13X0.047016X11.988 Z5 2 1 14X0.033156X4.4184 Z5 2 2 14X0.037813X6.6935 Z5 2 3 14X0.040766X8.5993 Z5 2 4 14X0.043172X10.35 Z5 2 5 14X0.0445X11.984 Z5 2 1 15X0.03125X4.4179 Z5 2 2 15X0.035719X6.6888 Z5 2 3 15X0.038563X8.5979 Z5 2 4 15X0.040938X10.349 Z5 2 5 15X0.042375X11.985 Z5 2 1 16X0.029445X4.4134 Z5 2 2 16X0.033938X6.6874 Z5 2 3 16X0.036656X8.5966 Z5 2 4 16X0.038906X10.346 Z5 2 5 16X0.040367X11.983 Z5 2 1 17X0.027938X4.4139 Z5 2 2 17X0.032266X6.6875 Z5 2 3 17X0.03493X8.5948 Z5 2 4 17X0.037188X10.347 Z5 2 5 17X0.038516X11.98 Z5 2 1 18X0.026625X4.4121 Z5 2 2 18X0.030813X6.6879 Z5 2 3 18X0.033313X8.5929 Z5 2 4 18X0.035484X10.344 Z5 2 5 18X0.036891X11.979 Z5 2 1 19X0.025375X4.4121 Z5 2 2 19X0.02957X6.6905 Z5 2 3 19X0.031961X8.5951 Z5 2 4 19X0.034055X10.343 Z5 2 5 19X0.035445X11.981 Z5 2 1 20X0.024281X4.4119 Z5 2 2 20X0.028258X6.69 Z5 2 3 20X0.030609X8.5917 Z5 2 4 20X0.032688X10.343 Z5 2 5 20X0.034063X11.981 Z5 2 1 21X0.02325X4.4118 Z5 2 2 21X0.027086X6.6879 Z5 2 3 21X0.029406X8.591 Z5 2 4 21X0.031367X10.341 Z5 2 5 21X0.03275X11.979 Z5 2 1 22X0.022297X4.4115 Z5 2 2 22X0.026X6.6849 Z5 2 3 22X0.028359X8.5927 Z5 2 4 22X0.030219X10.338 Z5 2 5 22X0.031563X11.976 Z5 2 1 23X0.0215X4.4132 Z5 2 2 23X0.025063X6.6856 Z5 2 3 23X0.02725X8.5893 Z5 2 4 23X0.029117X10.337 Z5 2 5 23X0.030445X11.975 Z5 2 1 24X0.020656X4.4123 Z5 2 2 24X0.024148X6.6846 Z5 2 3 24X0.02632X8.589 Z5 2 4 24X0.028094X10.335 Z5 2 5 24X0.029406X11.974 Z5 2 1 25X0.01984X4.4088 Z5 2 2 25X0.023344X6.6858 Z5 2 3 25X0.025406X8.5879 Z5 2 4 25X0.027188X10.335 Z5 2 5 25X0.028398X11.972 Z5 2 1 26X0.019191X4.4113 Z5 2 2 26X0.022559X6.6841 Z5 2 3 26X0.024555X8.5876 Z5 2 4 26X0.026313X10.336 Z5 2 5 26X0.027445X11.97 Z5 2 1 27X0.018547X4.4124 Z5 2 2 27X0.021789X6.684 Z5 2 3 27X0.02375X8.5866 Z5 2 4 27X0.025492X10.335 Z5 2 5 27X0.026578X11.967 Z5 2 1 28X0.017969X4.4126 Z5 2 2 28X0.021094X6.6834 Z5 2 3 28X0.022977X8.5851 Z5 2 4 28X0.024719X10.336 Z5 2 5 28X0.02582X11.969 Z5 2 1 29X0.017391X4.4122 Z5 2 2 29X0.020438X6.6824 Z5 2 3 29X0.022359X8.5883 Z5 2 4 29X0.023957X10.332 Z5 2 5 29X0.025055X11.968 Z5 2 1 30X0.016844X4.4122 Z5 2 2 30X0.019813X6.6826 Z5 2 3 30X0.021688X8.5863 Z5 2 4 30X0.02325X10.33 Z5 2 5 30X0.024328X11.966 Z5 2 1 31X0.016344X4.4116 Z5 2 2 31X0.019289X6.6829 Z5 2 3 31X0.021063X8.5855 Z5 2 4 31X0.022621X10.333 Z5 2 5 31X0.023695X11.966 Z5 2 1 32X0.015852X4.4099 Z5 2 2 32X0.018688X6.6802 Z5 2 3 32X0.020492X8.5867 Z5 2 4 32X0.022039X10.333 Z5 2 5 32X0.023047X11.965 Z5 2 1 33X0.015414X4.4098 Z5 2 2 33X0.01818X6.68 Z5 2 3 33X0.019938X8.5853 Z5 2 4 33X0.02143X10.333 Z5 2 5 33X0.022457X11.965 Z5 2 1 34X0.014977X4.4094 Z5 2 2 34X0.017688X6.6808 Z5 2 3 34X0.019402X8.5866 Z5 2 4 34X0.020852X10.331 Z5 2 5 34X0.021836X11.96 Z5 2 1 35X0.014555X4.4078 Z5 2 2 35X0.017238X6.6794 Z5 2 3 35X0.018918X8.5863 Z5 2 4 35X0.020375X10.332 Z5 2 5 35X0.021305X11.962 Z5 2 1 36X0.014203X4.4083 Z5 2 2 36X0.016813X6.6802 Z5 2 3 36X0.018438X8.5847 Z5 2 4 36X0.019859X10.33 Z5 2 5 36X0.020781X11.962 Z5 2 1 37X0.013867X4.408 Z5 2 2 37X0.016387X6.679 Z5 2 3 37X0.018023X8.5854 Z5 2 4 37X0.019414X10.329 Z5 2 5 37X0.020297X11.961 Z5 2 1 38X0.013516X4.4083 Z5 2 2 38X0.016031X6.6799 Z5 2 3 38X0.017578X8.5832 Z5 2 4 38X0.018922X10.329 Z5 2 5 38X0.019813X11.96 Z5 2 1 39X0.013203X4.4082 Z5 2 2 39X0.015617X6.6794 Z5 2 3 39X0.017176X8.583 Z5 2 4 39X0.0185X10.33 Z5 2 5 39X0.019371X11.96 Z5 2 1 40X0.012891X4.4081 Z5 2 2 40X0.015262X6.6783 Z5 2 3 40X0.016762X8.5818 Z5 2 4 40X0.018109X10.329 Z5 2 5 40X0.01893X11.958 Z5 2 1 41X0.012594X4.4074 Z5 2 2 41X0.014906X6.6773 Z5 2 3 41X0.016391X8.5822 Z5 2 4 41X0.017723X10.33 Z5 2 5 41X0.018563X11.958 Z5 2 1 42X0.012328X4.4075 Z5 2 2 42X0.014582X6.6771 Z5 2 3 42X0.016031X8.5828 Z5 2 4 42X0.017359X10.329 Z5 2 5 42X0.018172X11.958 Z5 2 1 43X0.012063X4.4079 Z5 2 2 43X0.014273X6.6782 Z5 2 3 43X0.015688X8.5798 Z5 2 4 43X0.016969X10.328 Z5 2 5 43X0.017813X11.959 Z5 2 1 44X0.011811X4.4093 Z5 2 2 44X0.013984X6.6797 Z5 2 3 44X0.015359X8.5796 Z5 2 4 44X0.016625X10.328 Z5 2 5 44X0.017438X11.959 Z5 2 1 45X0.011555X4.4083 Z5 2 2 45X0.013707X6.6798 Z5 2 3 45X0.015031X8.5797 Z5 2 4 45X0.016301X10.328 Z5 2 5 45X0.017074X11.958 Z5 2 1 46X0.011313X4.4084 Z5 2 2 46X0.013406X6.6776 Z5 2 3 46X0.014766X8.5795 Z5 2 4 46X0.01598X10.327 Z5 2 5 46X0.01675X11.959 Z5 2 1 47X0.011094X4.4085 Z5 2 2 47X0.013164X6.6793 Z5 2 3 47X0.014469X8.578 Z5 2 4 47X0.01568X10.327 Z5 2 5 47X0.016434X11.96 Z5 2 1 48X0.010875X4.4085 Z5 2 2 48X0.012906X6.6783 Z5 2 3 48X0.014156X8.5774 Z5 2 4 48X0.015375X10.327 Z5 2 5 48X0.016109X11.956 Z5 2 1 49X0.01068X4.4097 Z5 2 2 49X0.012656X6.6773 Z5 2 3 49X0.01391X8.5781 Z5 2 4 49X0.015094X10.327 Z5 2 5 49X0.015813X11.956 Z5 2 1 50X0.010473X4.4086 Z5 2 2 50X0.012406X6.6765 Z5 2 3 50X0.013652X8.5782 Z5 2 4 50X0.014813X10.326 Z5 2 5 50X0.0155X11.955 Z5 5 1 1X0.41688X5.4589 Z5 5 2 1X0.29988X7.8029 Z5 5 3 1X0.248X9.7694 Z5 5 4 1X0.21838X11.578 Z5 5 5 1X0.19625X13.254 Z5 5 1 2X0.28888X5.3048 Z5 5 2 2X0.29988X7.8029 Z5 5 3 2X0.248X9.7694 Z5 5 4 2X0.21838X11.578 Z5 5 5 2X0.19625X13.254 Z5 5 1 3X0.22481X5.2344 Z5 5 2 3X0.24084X7.7231 Z5 5 3 3X0.248X9.7694 Z5 5 4 3X0.21838X11.578 Z5 5 5 3X0.19625X13.254 Z5 5 1 4X0.18531X5.1916 Z5 5 2 4X0.203X7.6701 Z5 5 3 4X0.21188X9.7151 Z5 5 4 4X0.21838X11.578 Z5 5 5 4X0.19625X13.254 Z5 5 1 5X0.15775X5.1566 Z5 5 2 5X0.17544X7.6239 Z5 5 3 5X0.18541X9.6728 Z5 5 4 5X0.19188X11.527 Z5 5 5 5X0.19625X13.254 Z5 5 1 6X0.1375X5.1313 Z5 5 2 6X0.15491X7.5949 Z5 5 3 6X0.16444X9.6345 Z5 5 4 6X0.17175X11.496 Z5 5 5 6X0.17647X13.219 Z5 5 1 7X0.12225X5.1089 Z5 5 2 7X0.13878X7.5743 Z5 5 3 7X0.14805X9.6083 Z5 5 4 7X0.15544X11.47 Z5 5 5 7X0.16016X13.194 Z5 5 1 8X0.11013X5.0983 Z5 5 2 8X0.12572X7.5575 Z5 5 3 8X0.13484X9.593 Z5 5 4 8X0.14209X11.448 Z5 5 5 8X0.14663X13.17 Z5 5 1 9X0.1X5.0861 Z5 5 2 9X0.11503X7.5438 Z5 5 3 9X0.12394X9.572 Z5 5 4 9X0.13075X11.427 Z5 5 5 9X0.13544X13.154 Z5 5 1 10X0.091813X5.0781 Z5 5 2 10X0.10595X7.5329 Z5 5 3 10X0.11447X9.5557 Z5 5 4 10X0.12116X11.412 Z5 5 5 10X0.12575X13.136 Z5 5 1 11X0.084688X5.0693 Z5 5 2 11X0.098281X7.5232 Z5 5 3 11X0.10658X9.5474 Z5 5 4 11X0.11286X11.397 Z5 5 5 11X0.11738X13.117 Z5 5 1 12X0.078664X5.061 Z5 5 2 12X0.091625X7.5103 Z5 5 3 12X0.09975X9.5365 Z5 5 4 12X0.10584X11.389 Z5 5 5 12X0.11013X13.107 Z5 5 1 13X0.073563X5.0564 Z5 5 2 13X0.085781X7.4984 Z5 5 3 13X0.093547X9.527 Z5 5 4 13X0.099594X11.383 Z5 5 5 13X0.10394X13.101 Z5 5 1 14X0.069078X5.0558 Z5 5 2 14X0.080773X7.494 Z5 5 3 14X0.088141X9.5196 Z5 5 4 14X0.093984X11.373 Z5 5 5 14X0.098188X13.086 Z5 5 1 15X0.065094X5.0506 Z5 5 2 15X0.07625X7.4864 Z5 5 3 15X0.083438X9.5137 Z5 5 4 15X0.088875X11.364 Z5 5 5 15X0.093031X13.077 Z5 5 1 16X0.061469X5.0463 Z5 5 2 16X0.072203X7.4782 Z5 5 3 16X0.079094X9.5085 Z5 5 4 16X0.084469X11.357 Z5 5 5 16X0.0885X13.068 Z5 5 1 17X0.058281X5.0422 Z5 5 2 17X0.068563X7.4758 Z5 5 3 17X0.075125X9.4977 Z5 5 4 17X0.080375X11.347 Z5 5 5 17X0.08432X13.059 Z5 5 1 18X0.055406X5.0373 Z5 5 2 18X0.065234X7.4677 Z5 5 3 18X0.071781X9.4965 Z5 5 4 18X0.076703X11.337 Z5 5 5 18X0.080547X13.052 Z5 5 1 19X0.05275X5.0334 Z5 5 2 19X0.06225X7.4629 Z5 5 3 19X0.068656X9.4935 Z5 5 4 19X0.073391X11.332 Z5 5 5 19X0.077078X13.043 Z5 5 1 20X0.050359X5.0303 Z5 5 2 20X0.059656X7.4633 Z5 5 3 20X0.065688X9.49 Z5 5 4 20X0.070375X11.329 Z5 5 5 20X0.073875X13.036 Z5 5 1 21X0.048234X5.0285 Z5 5 2 21X0.057172X7.4588 Z5 5 3 21X0.062984X9.4841 Z5 5 4 21X0.067508X11.322 Z5 5 5 21X0.070922X13.032 Z5 5 1 22X0.046258X5.0267 Z5 5 2 22X0.054813X7.4529 Z5 5 3 22X0.060547X9.4804 Z5 5 4 22X0.064914X11.319 Z5 5 5 22X0.06825X13.025 Z5 5 1 23X0.044484X5.0284 Z5 5 2 23X0.052711X7.4499 Z5 5 3 23X0.058281X9.4761 Z5 5 4 23X0.062438X11.314 Z5 5 5 23X0.065781X13.021 Z5 5 1 24X0.042813X5.0279 Z5 5 2 24X0.050789X7.4507 Z5 5 3 24X0.056188X9.476 Z5 5 4 24X0.060211X11.309 Z5 5 5 24X0.063438X13.017 Z5 5 1 25X0.041297X5.027 Z5 5 2 25X0.049004X7.4474 Z5 5 3 25X0.054203X9.4713 Z5 5 4 25X0.058141X11.305 Z5 5 5 25X0.061309X13.014 Z5 5 1 26X0.039875X5.0271 Z5 5 2 26X0.047313X7.4459 Z5 5 3 26X0.052344X9.468 Z5 5 4 26X0.056211X11.302 Z5 5 5 26X0.059266X13.012 Z5 5 1 27X0.038508X5.0248 Z5 5 2 27X0.045766X7.4452 Z5 5 3 27X0.050648X9.4637 Z5 5 4 27X0.054355X11.295 Z5 5 5 27X0.057438X13.011 Z5 5 1 28X0.037234X5.0246 Z5 5 2 28X0.044313X7.4432 Z5 5 3 28X0.049X9.4586 Z5 5 4 28X0.052703X11.294 Z5 5 5 28X0.055641X13.006 Z5 5 1 29X0.036031X5.0238 Z5 5 2 29X0.042926X7.4405 Z5 5 3 29X0.047531X9.4576 Z5 5 4 29X0.051094X11.288 Z5 5 5 29X0.054031X13.005 Z5 5 1 30X0.034922X5.0212 Z5 5 2 30X0.041641X7.4379 Z5 5 3 30X0.046109X9.4554 Z5 5 4 30X0.049625X11.287 Z5 5 5 30X0.052406X13 Z5 5 1 31X0.033836X5.0182 Z5 5 2 31X0.04041X7.4348 Z5 5 3 31X0.044785X9.4524 Z5 5 4 31X0.048219X11.286 Z5 5 5 31X0.050938X12.994 Z5 5 1 32X0.032867X5.0178 Z5 5 2 32X0.039262X7.4347 Z5 5 3 32X0.043547X9.4516 Z5 5 4 32X0.046906X11.287 Z5 5 5 32X0.049551X12.994 Z5 5 1 33X0.03191X5.016 Z5 5 2 33X0.038148X7.4322 Z5 5 3 33X0.042359X9.4495 Z5 5 4 33X0.045688X11.285 Z5 5 5 33X0.04825X12.99 Z5 5 1 34X0.031063X5.0157 Z5 5 2 34X0.037109X7.4315 Z5 5 3 34X0.041203X9.4462 Z5 5 4 34X0.044461X11.281 Z5 5 5 34X0.046969X12.987 Z5 5 1 35X0.030234X5.0155 Z5 5 2 35X0.036117X7.4272 Z5 5 3 35X0.040156X9.4447 Z5 5 4 35X0.043359X11.28 Z5 5 5 35X0.04575X12.983 Z5 5 1 36X0.029469X5.0154 Z5 5 2 36X0.035203X7.4277 Z5 5 3 36X0.039113X9.4403 Z5 5 4 36X0.042227X11.275 Z5 5 5 36X0.044664X12.982 Z5 5 1 37X0.02875X5.0162 Z5 5 2 37X0.034313X7.4267 Z5 5 3 37X0.038188X9.4413 Z5 5 4 37X0.041227X11.275 Z5 5 5 37X0.043582X12.979 Z5 5 1 38X0.028016X5.0143 Z5 5 2 38X0.033488X7.4229 Z5 5 3 38X0.03725X9.4376 Z5 5 4 38X0.040234X11.274 Z5 5 5 38X0.042531X12.976 Z5 5 1 39X0.027336X5.0145 Z5 5 2 39X0.032707X7.4233 Z5 5 3 39X0.036313X9.4338 Z5 5 4 39X0.039297X11.272 Z5 5 5 39X0.04157X12.975 Z5 5 1 40X0.026703X5.0123 Z5 5 2 40X0.031945X7.423 Z5 5 3 40X0.035484X9.4332 Z5 5 4 40X0.038422X11.271 Z5 5 5 40X0.040641X12.975 Z5 5 1 41X0.026063X5.01 Z5 5 2 41X0.031211X7.4219 Z5 5 3 41X0.034707X9.4337 Z5 5 4 41X0.037594X11.268 Z5 5 5 41X0.039727X12.972 Z5 5 1 42X0.025477X5.0118 Z5 5 2 42X0.030512X7.421 Z5 5 3 42X0.033953X9.432 Z5 5 4 42X0.036781X11.267 Z5 5 5 42X0.038875X12.971 Z5 5 1 43X0.024906X5.0087 Z5 5 2 43X0.029832X7.4177 Z5 5 3 43X0.033203X9.4294 Z5 5 4 43X0.035992X11.265 Z5 5 5 43X0.038055X12.968 Z5 5 1 44X0.024359X5.0077 Z5 5 2 44X0.029188X7.4165 Z5 5 3 44X0.032539X9.4296 Z5 5 4 44X0.03523X11.261 Z5 5 5 44X0.037297X12.969 Z5 5 1 45X0.023848X5.0072 Z5 5 2 45X0.028625X7.4169 Z5 5 3 45X0.031859X9.4279 Z5 5 4 45X0.034516X11.259 Z5 5 5 45X0.036555X12.967 Z5 5 1 46X0.023352X5.0058 Z5 5 2 46X0.028031X7.4172 Z5 5 3 46X0.03125X9.4282 Z5 5 4 46X0.033805X11.258 Z5 5 5 46X0.035871X12.967 Z5 5 1 47X0.022906X5.0063 Z5 5 2 47X0.027469X7.4161 Z5 5 3 47X0.030609X9.4254 Z5 5 4 47X0.03318X11.261 Z5 5 5 47X0.035172X12.967 Z5 5 1 48X0.022445X5.0043 Z5 5 2 48X0.026938X7.4147 Z5 5 3 48X0.030043X9.428 Z5 5 4 48X0.032527X11.257 Z5 5 5 48X0.0345X12.964 Z5 5 1 49X0.02202X5.0047 Z5 5 2 49X0.026422X7.4146 Z5 5 3 49X0.029453X9.4258 Z5 5 4 49X0.031941X11.256 Z5 5 5 49X0.033855X12.962 Z5 5 1 50X0.021625X5.0064 Z5 5 2 50X0.025934X7.4153 Z5 5 3 50X0.028891X9.4243 Z5 5 4 50X0.031367X11.258 Z5 5 5 50X0.033266X12.964 Z5 10 1 1X0.85019X7.1284 Z5 10 2 1X0.57744X9.4691 Z5 10 3 1X0.46813X11.493 Z5 10 4 1X0.40563X13.357 Z5 10 5 1X0.36169X15.087 Z5 10 1 2X0.51013X6.4933 Z5 10 2 2X0.57744X9.4691 Z5 10 3 2X0.46813X11.493 Z5 10 4 2X0.40563X13.357 Z5 10 5 2X0.36169X15.087 Z5 10 1 3X0.37875X6.2532 Z5 10 2 3X0.43975X9.1701 Z5 10 3 3X0.46813X11.493 Z5 10 4 3X0.40563X13.357 Z5 10 5 3X0.36169X15.087 Z5 10 1 4X0.30391X6.1145 Z5 10 2 4X0.35913X8.9987 Z5 10 3 4X0.38666X11.297 Z5 10 4 4X0.40563X13.357 Z5 10 5 4X0.36169X15.087 Z5 10 1 5X0.25556X6.0317 Z5 10 2 5X0.30406X8.8632 Z5 10 3 5X0.33009X11.154 Z5 10 4 5X0.34925X13.201 Z5 10 5 5X0.36169X15.087 Z5 10 1 6X0.22128X5.9674 Z5 10 2 6X0.26484X8.775 Z5 10 3 6X0.28888X11.042 Z5 10 4 6X0.30647X13.083 Z5 10 5 6X0.31931X14.96 Z5 10 1 7X0.19534X5.9204 Z5 10 2 7X0.23497X8.7127 Z5 10 3 7X0.2575X10.975 Z5 10 4 7X0.27413X13.001 Z5 10 5 7X0.28675X14.882 Z5 10 1 8X0.17528X5.8866 Z5 10 2 8X0.21119X8.662 Z5 10 3 8X0.23222X10.915 Z5 10 4 8X0.24784X12.934 Z5 10 5 8X0.25978X14.807 Z5 10 1 9X0.15902X5.8642 Z5 10 2 9X0.19216X8.6205 Z5 10 3 9X0.21175X10.861 Z5 10 4 9X0.22653X12.876 Z5 10 5 9X0.23773X14.738 Z5 10 1 10X0.14553X5.8408 Z5 10 2 10X0.17625X8.5913 Z5 10 3 10X0.1945X10.814 Z5 10 4 10X0.20834X12.823 Z5 10 5 10X0.21941X14.684 Z5 10 1 11X0.13425X5.8254 Z5 10 2 11X0.16275X8.5583 Z5 10 3 11X0.18X10.78 Z5 10 4 11X0.19294X12.78 Z5 10 5 11X0.20366X14.642 Z5 10 1 12X0.12452X5.8048 Z5 10 2 12X0.15138X8.5357 Z5 10 3 12X0.16745X10.744 Z5 10 4 12X0.17989X12.745 Z5 10 5 12X0.18981X14.599 Z5 10 1 13X0.11614X5.7928 Z5 10 2 13X0.14122X8.5096 Z5 10 3 13X0.15669X10.72 Z5 10 4 13X0.16864X12.719 Z5 10 5 13X0.17816X14.57 Z5 10 1 14X0.10888X5.7826 Z5 10 2 14X0.1325X8.4869 Z5 10 3 14X0.14722X10.696 Z5 10 4 14X0.15859X12.691 Z5 10 5 14X0.16766X14.536 Z5 10 1 15X0.10249X5.771 Z5 10 2 15X0.12478X8.4676 Z5 10 3 15X0.13884X10.674 Z5 10 4 15X0.1498X12.671 Z5 10 5 15X0.15841X14.507 Z5 10 1 16X0.096844X5.7633 Z5 10 2 16X0.11792X8.4498 Z5 10 3 16X0.13134X10.659 Z5 10 4 16X0.14192X12.647 Z5 10 5 16X0.15016X14.484 Z5 10 1 17X0.09175X5.7562 Z5 10 2 17X0.11178X8.4402 Z5 10 3 17X0.12466X10.641 Z5 10 4 17X0.13483X12.629 Z5 10 5 17X0.14263X14.464 Z5 10 1 18X0.087219X5.7517 Z5 10 2 18X0.10641X8.4324 Z5 10 3 18X0.11855X10.624 Z5 10 4 18X0.12844X12.605 Z5 10 5 18X0.13597X14.443 Z5 10 1 19X0.083063X5.7427 Z5 10 2 19X0.10147X8.4213 Z5 10 3 19X0.11307X10.605 Z5 10 4 19X0.12256X12.59 Z5 10 5 19X0.12999X14.428 Z5 10 1 20X0.079305X5.7353 Z5 10 2 20X0.096906X8.4112 Z5 10 3 20X0.10813X10.596 Z5 10 4 20X0.11708X12.573 Z5 10 5 20X0.12428X14.405 Z5 10 1 21X0.075875X5.7309 Z5 10 2 21X0.092734X8.3993 Z5 10 3 21X0.1035X10.583 Z5 10 4 21X0.11238X12.564 Z5 10 5 21X0.11906X14.386 Z5 10 1 22X0.072781X5.7266 Z5 10 2 22X0.088922X8.3894 Z5 10 3 22X0.099344X10.567 Z5 10 4 22X0.10783X12.548 Z5 10 5 22X0.11442X14.372 Z5 10 1 23X0.069922X5.7256 Z5 10 2 23X0.085438X8.3842 Z5 10 3 23X0.0955X10.562 Z5 10 4 23X0.10375X12.538 Z5 10 5 23X0.11013X14.362 Z5 10 1 24X0.067266X5.7213 Z5 10 2 24X0.082188X8.3746 Z5 10 3 24X0.092031X10.555 Z5 10 4 24X0.099914X12.527 Z5 10 5 24X0.10613X14.352 Z5 10 1 25X0.064766X5.718 Z5 10 2 25X0.079188X8.3674 Z5 10 3 25X0.088633X10.543 Z5 10 4 25X0.096344X12.513 Z5 10 5 25X0.10245X14.343 Z5 10 1 26X0.062469X5.7153 Z5 10 2 26X0.076398X8.3598 Z5 10 3 26X0.085625X10.537 Z5 10 4 26X0.093031X12.503 Z5 10 5 26X0.098953X14.331 Z5 10 1 27X0.060297X5.7114 Z5 10 2 27X0.073813X8.3538 Z5 10 3 27X0.082688X10.526 Z5 10 4 27X0.089984X12.498 Z5 10 5 27X0.095703X14.322 Z5 10 1 28X0.058359X5.7106 Z5 10 2 28X0.071391X8.3491 Z5 10 3 28X0.080063X10.52 Z5 10 4 28X0.087102X12.491 Z5 10 5 28X0.092672X14.315 Z5 10 1 29X0.056469X5.7082 Z5 10 2 29X0.069125X8.3426 Z5 10 3 29X0.077539X10.511 Z5 10 4 29X0.084391X12.477 Z5 10 5 29X0.089875X14.306 Z5 10 1 30X0.054727X5.7041 Z5 10 2 30X0.067047X8.3389 Z5 10 3 30X0.075172X10.507 Z5 10 4 30X0.081859X12.473 Z5 10 5 30X0.087156X14.3 Z5 10 1 31X0.053094X5.7048 Z5 10 2 31X0.064984X8.3324 Z5 10 3 31X0.072953X10.499 Z5 10 4 31X0.079438X12.465 Z5 10 5 31X0.084625X14.289 Z5 10 1 32X0.051516X5.7011 Z5 10 2 32X0.063063X8.3276 Z5 10 3 32X0.070945X10.496 Z5 10 4 32X0.07718X12.462 Z5 10 5 32X0.082219X14.282 Z5 10 1 33X0.050039X5.6976 Z5 10 2 33X0.061316X8.3266 Z5 10 3 33X0.068984X10.493 Z5 10 4 33X0.075055X12.455 Z5 10 5 33X0.08002X14.277 Z5 10 1 34X0.048656X5.6948 Z5 10 2 34X0.059602X8.3205 Z5 10 3 34X0.067117X10.492 Z5 10 4 34X0.073078X12.45 Z5 10 5 34X0.077844X14.264 Z5 10 1 35X0.047352X5.6941 Z5 10 2 35X0.058031X8.3188 Z5 10 3 35X0.065309X10.484 Z5 10 4 35X0.071117X12.439 Z5 10 5 35X0.075813X14.259 Z5 10 1 36X0.046109X5.6924 Z5 10 2 36X0.056531X8.3131 Z5 10 3 36X0.063641X10.479 Z5 10 4 36X0.069328X12.436 Z5 10 5 36X0.073906X14.254 Z5 10 1 37X0.044934X5.6893 Z5 10 2 37X0.055063X8.3096 Z5 10 3 37X0.062074X10.476 Z5 10 4 37X0.067566X12.432 Z5 10 5 37X0.072125X14.249 Z5 10 1 38X0.043828X5.6902 Z5 10 2 38X0.053723X8.3057 Z5 10 3 38X0.060516X10.469 Z5 10 4 38X0.065918X12.424 Z5 10 5 38X0.070438X14.246 Z5 10 1 39X0.042797X5.6887 Z5 10 2 39X0.052445X8.3045 Z5 10 3 39X0.059125X10.471 Z5 10 4 39X0.064313X12.419 Z5 10 5 39X0.06875X14.237 Z5 10 1 40X0.041766X5.6856 Z5 10 2 40X0.051219X8.3029 Z5 10 3 40X0.057719X10.463 Z5 10 4 40X0.062883X12.419 Z5 10 5 40X0.067172X14.232 Z5 10 1 41X0.040813X5.6843 Z5 10 2 41X0.05007X8.3009 Z5 10 3 41X0.056422X10.461 Z5 10 4 41X0.061477X12.415 Z5 10 5 41X0.065688X14.231 Z5 10 1 42X0.039891X5.6835 Z5 10 2 42X0.048938X8.2957 Z5 10 3 42X0.055156X10.459 Z5 10 4 42X0.060129X12.41 Z5 10 5 42X0.064234X14.226 Z5 10 1 43X0.03898X5.6803 Z5 10 2 43X0.047828X8.2923 Z5 10 3 43X0.053938X10.453 Z5 10 4 43X0.058836X12.407 Z5 10 5 43X0.062813X14.219 Z5 10 1 44X0.038152X5.6776 Z5 10 2 44X0.046824X8.2921 Z5 10 3 44X0.052781X10.446 Z5 10 4 44X0.057586X12.4 Z5 10 5 44X0.061469X14.214 Z5 10 1 45X0.037313X5.675 Z5 10 2 45X0.045813X8.2878 Z5 10 3 45X0.051699X10.443 Z5 10 4 45X0.056406X12.397 Z5 10 5 45X0.060219X14.211 Z5 10 1 46X0.036555X5.6735 Z5 10 2 46X0.044922X8.2884 Z5 10 3 46X0.050648X10.442 Z5 10 4 46X0.055219X12.39 Z5 10 5 46X0.059X14.205 Z5 10 1 47X0.035813X5.6719 Z5 10 2 47X0.044016X8.2875 Z5 10 3 47X0.049625X10.436 Z5 10 4 47X0.054164X12.389 Z5 10 5 47X0.057828X14.204 Z5 10 1 48X0.035133X5.6721 Z5 10 2 48X0.043141X8.2868 Z5 10 3 48X0.048688X10.436 Z5 10 4 48X0.053096X12.387 Z5 10 5 48X0.056758X14.203 Z5 10 1 49X0.034438X5.671 Z5 10 2 49X0.042313X8.2861 Z5 10 3 49X0.047734X10.433 Z5 10 4 49X0.052102X12.385 Z5 10 5 49X0.055656X14.198 Z5 10 1 50X0.033777X5.6691 Z5 10 2 50X0.04152X8.2832 Z5 10 3 50X0.046828X10.432 Z5 10 4 50X0.051125X12.382 Z5 10 5 50X0.054625X14.196 Z5 15 1 1X1.3344X8.9939 Z5 15 2 1X0.85881X11.158 Z5 15 3 1X0.68338X13.178 Z5 15 4 1X0.58269X15.039 Z5 15 5 1X0.51689X16.807 Z5 15 1 2X0.70881X7.6045 Z5 15 2 2X0.85881X11.158 Z5 15 3 2X0.68338X13.178 Z5 15 4 2X0.58269X15.039 Z5 15 5 2X0.51689X16.807 Z5 15 1 3X0.5035X7.1261 Z5 15 2 3X0.62213X10.526 Z5 15 3 3X0.68338X13.178 Z5 15 4 3X0.58269X15.039 Z5 15 5 3X0.51689X16.807 Z5 15 1 4X0.39619X6.8693 Z5 15 2 4X0.49319X10.165 Z5 15 3 4X0.5465X12.757 Z5 15 4 4X0.58269X15.039 Z5 15 5 4X0.51689X16.807 Z5 15 1 5X0.32825X6.712 Z5 15 2 5X0.41088X9.9227 Z5 15 3 5X0.4575X12.474 Z5 15 4 5X0.49088X14.725 Z5 15 5 5X0.51689X16.807 Z5 15 1 6X0.28159X6.6028 Z5 15 2 6X0.35375X9.7593 Z5 15 3 6X0.39525X12.27 Z5 15 4 6X0.42569X14.503 Z5 15 5 6X0.44944X16.564 Z5 15 1 7X0.247X6.5167 Z5 15 2 7X0.31134X9.6462 Z5 15 3 7X0.34888X12.134 Z5 15 4 7X0.37641X14.34 Z5 15 5 7X0.39831X16.38 Z5 15 1 8X0.22048X6.4574 Z5 15 2 8X0.278X9.5519 Z5 15 3 8X0.31203X12.014 Z5 15 4 8X0.33748X14.212 Z5 15 5 8X0.35781X16.24 Z5 15 1 9X0.19931X6.4195 Z5 15 2 9X0.25169X9.4816 Z5 15 3 9X0.28294X11.923 Z5 15 4 9X0.30647X14.104 Z5 15 5 9X0.32545X16.122 Z5 15 1 10X0.18188X6.3787 Z5 15 2 10X0.22975X9.4194 Z5 15 3 10X0.25873X11.846 Z5 15 4 10X0.28059X14.011 Z5 15 5 10X0.29858X16.021 Z5 15 1 11X0.16745X6.3512 Z5 15 2 11X0.21131X9.3644 Z5 15 3 11X0.23844X11.784 Z5 15 4 11X0.25903X13.939 Z5 15 5 11X0.27573X15.934 Z5 15 1 12X0.15522X6.3215 Z5 15 2 12X0.19594X9.3219 Z5 15 3 12X0.22131X11.728 Z5 15 4 12X0.24056X13.877 Z5 15 5 12X0.25633X15.87 Z5 15 1 13X0.14473X6.302 Z5 15 2 13X0.18272X9.2823 Z5 15 3 13X0.20647X11.681 Z5 15 4 13X0.22444X13.821 Z5 15 5 13X0.23952X15.805 Z5 15 1 14X0.13552X6.282 Z5 15 2 14X0.17107X9.2478 Z5 15 3 14X0.19345X11.635 Z5 15 4 14X0.21044X13.767 Z5 15 5 14X0.225X15.752 Z5 15 1 15X0.12737X6.2658 Z5 15 2 15X0.16093X9.2188 Z5 15 3 15X0.18194X11.595 Z5 15 4 15X0.19831X13.726 Z5 15 5 15X0.21173X15.697 Z5 15 1 16X0.1203X6.2525 Z5 15 2 16X0.15188X9.1925 Z5 15 3 16X0.17192X11.565 Z5 15 4 16X0.18727X13.688 Z5 15 5 16X0.20013X15.65 Z5 15 1 17X0.11397X6.2444 Z5 15 2 17X0.14388X9.1699 Z5 15 3 17X0.16288X11.531 Z5 15 4 17X0.17757X13.653 Z5 15 5 17X0.18986X15.61 Z5 15 1 18X0.10828X6.2343 Z5 15 2 18X0.13666X9.1528 Z5 15 3 18X0.15483X11.51 Z5 15 4 18X0.1688X13.614 Z5 15 5 18X0.18055X15.575 Z5 15 1 19X0.10313X6.226 Z5 15 2 19X0.13009X9.1323 Z5 15 3 19X0.14744X11.48 Z5 15 4 19X0.16091X13.584 Z5 15 5 19X0.17214X15.541 Z5 15 1 20X0.098445X6.2157 Z5 15 2 20X0.12406X9.1135 Z5 15 3 20X0.14072X11.459 Z5 15 4 20X0.15373X13.564 Z5 15 5 20X0.16449X15.507 Z5 15 1 21X0.094172X6.2073 Z5 15 2 21X0.11881X9.0998 Z5 15 3 21X0.13468X11.44 Z5 15 4 21X0.14713X13.54 Z5 15 5 21X0.15741X15.479 Z5 15 1 22X0.090273X6.1996 Z5 15 2 22X0.11381X9.0867 Z5 15 3 22X0.12916X11.419 Z5 15 4 22X0.1411X13.515 Z5 15 5 22X0.151X15.455 Z5 15 1 23X0.086688X6.1953 Z5 15 2 23X0.10928X9.0717 Z5 15 3 23X0.12406X11.406 Z5 15 4 23X0.13566X13.494 Z5 15 5 23X0.14522X15.44 Z5 15 1 24X0.083383X6.19 Z5 15 2 24X0.10511X9.0616 Z5 15 3 24X0.11928X11.39 Z5 15 4 24X0.13048X13.476 Z5 15 5 24X0.13981X15.419 Z5 15 1 25X0.080281X6.185 Z5 15 2 25X0.10127X9.0521 Z5 15 3 25X0.11494X11.374 Z5 15 4 25X0.12573X13.458 Z5 15 5 25X0.13477X15.399 Z5 15 1 26X0.077469X6.1836 Z5 15 2 26X0.097641X9.0425 Z5 15 3 26X0.11089X11.364 Z5 15 4 26X0.12138X13.443 Z5 15 5 26X0.13002X15.382 Z5 15 1 27X0.074852X6.1796 Z5 15 2 27X0.094258X9.0318 Z5 15 3 27X0.10713X11.35 Z5 15 4 27X0.11719X13.426 Z5 15 5 27X0.12569X15.363 Z5 15 1 28X0.072383X6.1764 Z5 15 2 28X0.091188X9.0257 Z5 15 3 28X0.10352X11.337 Z5 15 4 28X0.11333X13.412 Z5 15 5 28X0.12161X15.348 Z5 15 1 29X0.070047X6.1731 Z5 15 2 29X0.08825X9.0132 Z5 15 3 29X0.10027X11.325 Z5 15 4 29X0.10974X13.395 Z5 15 5 29X0.11778X15.333 Z5 15 1 30X0.067883X6.1693 Z5 15 2 30X0.085512X9.0043 Z5 15 3 30X0.097148X11.315 Z5 15 4 30X0.10641X13.386 Z5 15 5 30X0.11417X15.32 Z5 15 1 31X0.065844X6.1654 Z5 15 2 31X0.082875X8.9985 Z5 15 3 31X0.094211X11.301 Z5 15 4 31X0.10326X13.377 Z5 15 5 31X0.1108X15.304 Z5 15 1 32X0.06393X6.1642 Z5 15 2 32X0.080484X8.9937 Z5 15 3 32X0.091445X11.292 Z5 15 4 32X0.10023X13.365 Z5 15 5 32X0.10766X15.295 Z5 15 1 33X0.062117X6.1606 Z5 15 2 33X0.078188X8.9854 Z5 15 3 33X0.088906X11.283 Z5 15 4 33X0.097406X13.352 Z5 15 5 33X0.10466X15.285 Z5 15 1 34X0.060375X6.154 Z5 15 2 34X0.076X8.9792 Z5 15 3 34X0.086469X11.276 Z5 15 4 34X0.094742X13.346 Z5 15 5 34X0.10179X15.27 Z5 15 1 35X0.058758X6.1528 Z5 15 2 35X0.073969X8.9726 Z5 15 3 35X0.084125X11.268 Z5 15 4 35X0.092207X13.334 Z5 15 5 35X0.099055X15.259 Z5 15 1 36X0.057227X6.151 Z5 15 2 36X0.072X8.9656 Z5 15 3 36X0.081922X11.26 Z5 15 4 36X0.089797X13.323 Z5 15 5 36X0.096555X15.248 Z5 15 1 37X0.055797X6.1479 Z5 15 2 37X0.070211X8.963 Z5 15 3 37X0.079871X11.254 Z5 15 4 37X0.087563X13.317 Z5 15 5 37X0.094125X15.236 Z5 15 1 38X0.054406X6.1464 Z5 15 2 38X0.068453X8.9583 Z5 15 3 38X0.077914X11.247 Z5 15 4 38X0.085406X13.309 Z5 15 5 38X0.091797X15.226 Z5 15 1 39X0.053094X6.1427 Z5 15 2 39X0.066781X8.9537 Z5 15 3 39X0.076063X11.244 Z5 15 4 39X0.083344X13.3 Z5 15 5 39X0.089641X15.221 Z5 15 1 40X0.051844X6.1416 Z5 15 2 40X0.06523X8.9501 Z5 15 3 40X0.074266X11.237 Z5 15 4 40X0.081352X13.293 Z5 15 5 40X0.087547X15.212 Z5 15 1 41X0.050625X6.1367 Z5 15 2 41X0.063711X8.9451 Z5 15 3 41X0.072578X11.232 Z5 15 4 41X0.079484X13.285 Z5 15 5 41X0.085539X15.205 Z5 15 1 42X0.0495X6.1367 Z5 15 2 42X0.062281X8.9396 Z5 15 3 42X0.070938X11.228 Z5 15 4 42X0.07775X13.278 Z5 15 5 42X0.083652X15.198 Z5 15 1 43X0.048398X6.1355 Z5 15 2 43X0.060891X8.9369 Z5 15 3 43X0.069375X11.223 Z5 15 4 43X0.076008X13.27 Z5 15 5 43X0.081844X15.19 Z5 15 1 44X0.047359X6.1312 Z5 15 2 44X0.059586X8.9336 Z5 15 3 44X0.067875X11.217 Z5 15 4 44X0.074383X13.265 Z5 15 5 44X0.080082X15.183 Z5 15 1 45X0.046383X6.131 Z5 15 2 45X0.058344X8.9299 Z5 15 3 45X0.066473X11.212 Z5 15 4 45X0.072828X13.258 Z5 15 5 45X0.07841X15.174 Z5 15 1 46X0.045422X6.1287 Z5 15 2 46X0.057141X8.9272 Z5 15 3 46X0.065121X11.211 Z5 15 4 46X0.071375X13.252 Z5 15 5 46X0.076797X15.168 Z5 15 1 47X0.044492X6.1259 Z5 15 2 47X0.056X8.9249 Z5 15 3 47X0.063809X11.203 Z5 15 4 47X0.069945X13.247 Z5 15 5 47X0.075273X15.16 Z5 15 1 48X0.043621X6.1269 Z5 15 2 48X0.054875X8.9217 Z5 15 3 48X0.062543X11.201 Z5 15 4 48X0.068563X13.246 Z5 15 5 48X0.073828X15.157 Z5 15 1 49X0.042773X6.1263 Z5 15 2 49X0.053824X8.9207 Z5 15 3 49X0.061344X11.199 Z5 15 4 49X0.067234X13.237 Z5 15 5 49X0.072359X15.148 Z5 15 1 50X0.041938X6.1213 Z5 15 2 50X0.052793X8.9173 Z5 15 3 50X0.060156X11.193 Z5 15 4 50X0.065973X13.235 Z5 15 5 50X0.071016X15.146 Z5 20 1 1X1.8983X11.166 Z5 20 2 1X1.1578X12.953 Z5 20 3 1X0.89938X14.868 Z5 20 4 1X0.76078X16.732 Z5 20 5 1X0.66894X18.492 Z5 20 1 2X0.91013X8.7554 Z5 20 2 2X1.1578X12.953 Z5 20 3 2X0.89938X14.868 Z5 20 4 2X0.76078X16.732 Z5 20 5 2X0.66894X18.492 Z5 20 1 3X0.62125X7.971 Z5 20 2 3X0.79894X11.852 Z5 20 3 3X0.89938X14.868 Z5 20 4 3X0.76078X16.732 Z5 20 5 3X0.66894X18.492 Z5 20 1 4X0.47894X7.574 Z5 20 2 4X0.61875X11.281 Z5 20 3 4X0.70119X14.177 Z5 20 4 4X0.76078X16.732 Z5 20 5 4X0.66894X18.492 Z5 20 1 5X0.39163X7.3247 Z5 20 2 5X0.50722X10.9 Z5 20 3 5X0.57728X13.726 Z5 20 4 5X0.6285X16.209 Z5 20 5 5X0.66894X18.492 Z5 20 1 6X0.33288X7.1565 Z5 20 2 6X0.43189X10.642 Z5 20 3 6X0.49259X13.414 Z5 20 4 6X0.53731X15.845 Z5 20 5 6X0.57372X18.096 Z5 20 1 7X0.29X7.0325 Z5 20 2 7X0.37706X10.459 Z5 20 3 7X0.43075X13.186 Z5 20 4 7X0.47069X15.584 Z5 20 5 7X0.503X17.799 Z5 20 1 8X0.25739X6.9374 Z5 20 2 8X0.33469X10.325 Z5 20 3 8X0.38316X13.009 Z5 20 4 8X0.41925X15.39 Z5 20 5 8X0.44869X17.575 Z5 20 1 9X0.23173X6.8773 Z5 20 2 9X0.30164X10.216 Z5 20 3 9X0.34547X12.87 Z5 20 4 9X0.37819X15.22 Z5 20 5 9X0.40511X17.388 Z5 20 1 10X0.21088X6.8164 Z5 20 2 10X0.27448X10.128 Z5 20 3 10X0.31463X12.755 Z5 20 4 10X0.34461X15.079 Z5 20 5 10X0.36934X17.223 Z5 20 1 11X0.19359X6.7714 Z5 20 2 11X0.25191X10.05 Z5 20 3 11X0.28891X12.657 Z5 20 4 11X0.31656X14.965 Z5 20 5 11X0.34019X17.103 Z5 20 1 12X0.17906X6.7319 Z5 20 2 12X0.23305X9.9855 Z5 20 3 12X0.26725X12.579 Z5 20 4 12X0.29331X14.877 Z5 20 5 12X0.31508X17 Z5 20 1 13X0.1665X6.6996 Z5 20 2 13X0.21673X9.928 Z5 20 3 13X0.24853X12.501 Z5 20 4 13X0.27296X14.788 Z5 20 5 13X0.29356X16.903 Z5 20 1 14X0.15572X6.674 Z5 20 2 14X0.20256X9.8754 Z5 20 3 14X0.23238X12.438 Z5 20 4 14X0.25545X14.714 Z5 20 5 14X0.27469X16.82 Z5 20 1 15X0.14622X6.6471 Z5 20 2 15X0.19019X9.8377 Z5 20 3 15X0.21825X12.38 Z5 20 4 15X0.23981X14.645 Z5 20 5 15X0.25813X16.743 Z5 20 1 16X0.13789X6.6272 Z5 20 2 16X0.17935X9.8024 Z5 20 3 16X0.20592X12.336 Z5 20 4 16X0.22619X14.588 Z5 20 5 16X0.24367X16.679 Z5 20 1 17X0.13052X6.6144 Z5 20 2 17X0.16971X9.7699 Z5 20 3 17X0.19491X12.299 Z5 20 4 17X0.21415X14.537 Z5 20 5 17X0.23065X16.622 Z5 20 1 18X0.12391X6.5988 Z5 20 2 18X0.16092X9.739 Z5 20 3 18X0.18488X12.256 Z5 20 4 18X0.20327X14.486 Z5 20 5 18X0.21888X16.559 Z5 20 1 19X0.11791X6.5836 Z5 20 2 19X0.1532X9.7161 Z5 20 3 19X0.17591X12.219 Z5 20 4 19X0.19339X14.44 Z5 20 5 19X0.20856X16.517 Z5 20 1 20X0.11248X6.5709 Z5 20 2 20X0.14606X9.6911 Z5 20 3 20X0.16784X12.187 Z5 20 4 20X0.18438X14.4 Z5 20 5 20X0.19892X16.464 Z5 20 1 21X0.10756X6.561 Z5 20 2 21X0.13958X9.6688 Z5 20 3 21X0.16048X12.159 Z5 20 4 21X0.17631X14.366 Z5 20 5 21X0.19025X16.427 Z5 20 1 22X0.10306X6.5496 Z5 20 2 22X0.13374X9.6504 Z5 20 3 22X0.15373X12.128 Z5 20 4 22X0.16897X14.335 Z5 20 5 22X0.18227X16.391 Z5 20 1 23X0.098938X6.5447 Z5 20 2 23X0.12834X9.6335 Z5 20 3 23X0.14747X12.107 Z5 20 4 23X0.16216X14.306 Z5 20 5 23X0.17497X16.358 Z5 20 1 24X0.095109X6.5352 Z5 20 2 24X0.12334X9.6192 Z5 20 3 24X0.14169X12.084 Z5 20 4 24X0.1559X14.276 Z5 20 5 24X0.16819X16.325 Z5 20 1 25X0.091641X6.5314 Z5 20 2 25X0.11875X9.6042 Z5 20 3 25X0.13636X12.06 Z5 20 4 25X0.1501X14.254 Z5 20 5 25X0.16201X16.3 Z5 20 1 26X0.088391X6.5271 Z5 20 2 26X0.11449X9.5896 Z5 20 3 26X0.13148X12.043 Z5 20 4 26X0.14477X14.228 Z5 20 5 26X0.15625X16.276 Z5 20 1 27X0.085375X6.5233 Z5 20 2 27X0.1105X9.5784 Z5 20 3 27X0.12695X12.027 Z5 20 4 27X0.13982X14.207 Z5 20 5 27X0.15088X16.249 Z5 20 1 28X0.0825X6.5179 Z5 20 2 28X0.10684X9.5645 Z5 20 3 28X0.12274X12.01 Z5 20 4 28X0.13514X14.191 Z5 20 5 28X0.14582X16.222 Z5 20 1 29X0.079875X6.5117 Z5 20 2 29X0.10331X9.5487 Z5 20 3 29X0.11877X11.996 Z5 20 4 29X0.13075X14.163 Z5 20 5 29X0.14119X16.202 Z5 20 1 30X0.07743X6.5099 Z5 20 2 30X0.10008X9.5384 Z5 20 3 30X0.115X11.979 Z5 20 4 30X0.12674X14.152 Z5 20 5 30X0.13683X16.188 Z5 20 1 31X0.075109X6.5065 Z5 20 2 31X0.097016X9.5258 Z5 20 3 31X0.1115X11.959 Z5 20 4 31X0.12292X14.137 Z5 20 5 31X0.13266X16.164 Z5 20 1 32X0.072891X6.4994 Z5 20 2 32X0.094176X9.5206 Z5 20 3 32X0.10827X11.951 Z5 20 4 32X0.11933X14.12 Z5 20 5 32X0.1288X16.149 Z5 20 1 33X0.070789X6.4948 Z5 20 2 33X0.091453X9.5095 Z5 20 3 33X0.10515X11.937 Z5 20 4 33X0.11595X14.108 Z5 20 5 33X0.12513X16.132 Z5 20 1 34X0.068844X6.491 Z5 20 2 34X0.088875X9.5028 Z5 20 3 34X0.10222X11.925 Z5 20 4 34X0.11274X14.092 Z5 20 5 34X0.12166X16.108 Z5 20 1 35X0.066996X6.4867 Z5 20 2 35X0.086516X9.4926 Z5 20 3 35X0.099445X11.913 Z5 20 4 35X0.10969X14.077 Z5 20 5 35X0.11838X16.093 Z5 20 1 36X0.065258X6.4847 Z5 20 2 36X0.08425X9.4875 Z5 20 3 36X0.096875X11.905 Z5 20 4 36X0.10683X14.064 Z5 20 5 36X0.11525X16.08 Z5 20 1 37X0.063633X6.4819 Z5 20 2 37X0.082094X9.4812 Z5 20 3 37X0.094379X11.896 Z5 20 4 37X0.10413X14.055 Z5 20 5 37X0.11238X16.067 Z5 20 1 38X0.062047X6.4792 Z5 20 2 38X0.080055X9.4769 Z5 20 3 38X0.091957X11.884 Z5 20 4 38X0.10156X14.046 Z5 20 5 38X0.10955X16.051 Z5 20 1 39X0.060551X6.4749 Z5 20 2 39X0.078125X9.4725 Z5 20 3 39X0.089738X11.876 Z5 20 4 39X0.099047X14.032 Z5 20 5 39X0.10691X16.042 Z5 20 1 40X0.059105X6.4721 Z5 20 2 40X0.07625X9.4647 Z5 20 3 40X0.087605X11.866 Z5 20 4 40X0.096711X14.026 Z5 20 5 40X0.10439X16.028 Z5 20 1 41X0.05775X6.47 Z5 20 2 41X0.074445X9.4586 Z5 20 3 41X0.085559X11.86 Z5 20 4 41X0.094445X14.013 Z5 20 5 41X0.10195X16.016 Z5 20 1 42X0.056465X6.4703 Z5 20 2 42X0.072781X9.4509 Z5 20 3 42X0.083594X11.851 Z5 20 4 42X0.092281X14.001 Z5 20 5 42X0.09968X16.004 Z5 20 1 43X0.055219X6.467 Z5 20 2 43X0.071145X9.4451 Z5 20 3 43X0.08175X11.843 Z5 20 4 43X0.090242X13.994 Z5 20 5 43X0.097484X15.996 Z5 20 1 44X0.054016X6.4632 Z5 20 2 44X0.069625X9.4408 Z5 20 3 44X0.079938X11.837 Z5 20 4 44X0.088281X13.984 Z5 20 5 44X0.095344X15.985 Z5 20 1 45X0.052906X6.4623 Z5 20 2 45X0.068133X9.4349 Z5 20 3 45X0.078297X11.831 Z5 20 4 45X0.086441X13.977 Z5 20 5 45X0.093328X15.973 Z5 20 1 46X0.051809X6.4594 Z5 20 2 46X0.06673X9.4308 Z5 20 3 46X0.076688X11.827 Z5 20 4 46X0.084656X13.971 Z5 20 5 46X0.091387X15.965 Z5 20 1 47X0.050773X6.4567 Z5 20 2 47X0.065375X9.428 Z5 20 3 47X0.075094X11.819 Z5 20 4 47X0.082906X13.96 Z5 20 5 47X0.089531X15.954 Z5 20 1 48X0.049754X6.4553 Z5 20 2 48X0.06407X9.4262 Z5 20 3 48X0.073621X11.817 Z5 20 4 48X0.08125X13.952 Z5 20 5 48X0.087773X15.946 Z5 20 1 49X0.048766X6.454 Z5 20 2 49X0.062809X9.4219 Z5 20 3 49X0.072176X11.81 Z5 20 4 49X0.079676X13.948 Z5 20 5 49X0.086035X15.933 Z5 20 1 50X0.047852X6.4508 Z5 20 2 50X0.061578X9.4137 Z5 20 3 50X0.070813X11.807 Z5 20 4 50X0.078164X13.944 Z5 20 5 50X0.084395X15.926 Z10 1 1 1X0.057438X2.8669 Z10 1 2 1X0.041688X4.8014 Z10 1 3 1X0.034531X6.4781 Z10 1 4 1X0.030688X8.0264 Z10 1 5 1X0.027125X9.5053 Z10 1 1 2X0.040688X2.8634 Z10 1 2 2X0.041688X4.8014 Z10 1 3 2X0.034531X6.4781 Z10 1 4 2X0.030688X8.0264 Z10 1 5 2X0.027125X9.5053 Z10 1 1 3X0.031875X2.8636 Z10 1 2 3X0.03425X4.8021 Z10 1 3 3X0.034531X6.4781 Z10 1 4 3X0.030688X8.0264 Z10 1 5 3X0.027125X9.5053 Z10 1 1 4X0.026125X2.8623 Z10 1 2 4X0.02875X4.8003 Z10 1 3 4X0.029688X6.4779 Z10 1 4 4X0.030688X8.0264 Z10 1 5 4X0.027125X9.5053 Z10 1 1 5X0.022X2.8599 Z10 1 2 5X0.024813X4.7994 Z10 1 3 5X0.025969X6.4762 Z10 1 4 5X0.027X8.0242 Z10 1 5 5X0.027125X9.5053 Z10 1 1 6X0.019125X2.86 Z10 1 2 6X0.021781X4.7969 Z10 1 3 6X0.023141X6.4776 Z10 1 4 6X0.024156X8.0229 Z10 1 5 6X0.024484X9.506 Z10 1 1 7X0.016891X2.8597 Z10 1 2 7X0.019531X4.7984 Z10 1 3 7X0.02075X6.4764 Z10 1 4 7X0.021828X8.0209 Z10 1 5 7X0.022156X9.5042 Z10 1 1 8X0.015188X2.8599 Z10 1 2 8X0.017688X4.799 Z10 1 3 8X0.018813X6.4743 Z10 1 4 8X0.02X8.0218 Z10 1 5 8X0.020313X9.5047 Z10 1 1 9X0.013844X2.8604 Z10 1 2 9X0.016047X4.7972 Z10 1 3 9X0.017313X6.4736 Z10 1 4 9X0.018484X8.0225 Z10 1 5 9X0.018781X9.5042 Z10 1 1 10X0.012578X2.8592 Z10 1 2 10X0.014719X4.7963 Z10 1 3 10X0.016023X6.4744 Z10 1 4 10X0.017109X8.0224 Z10 1 5 10X0.017406X9.5033 Z10 1 1 11X0.011578X2.8587 Z10 1 2 11X0.013625X4.7962 Z10 1 3 11X0.014813X6.4738 Z10 1 4 11X0.015938X8.0228 Z10 1 5 11X0.016281X9.5033 Z10 1 1 12X0.010719X2.8587 Z10 1 2 12X0.012688X4.7964 Z10 1 3 12X0.013875X6.4738 Z10 1 4 12X0.014938X8.0233 Z10 1 5 12X0.015266X9.5037 Z10 1 1 13X0.010031X2.8599 Z10 1 2 13X0.011938X4.7972 Z10 1 3 13X0.012969X6.473 Z10 1 4 13X0.013969X8.0218 Z10 1 5 13X0.014375X9.5035 Z10 1 1 14X0.0093906X2.8596 Z10 1 2 14X0.01125X4.7974 Z10 1 3 14X0.01225X6.4742 Z10 1 4 14X0.013125X8.0202 Z10 1 5 14X0.013594X9.5033 Z10 1 1 15X0.0088438X2.8597 Z10 1 2 15X0.010609X4.7971 Z10 1 3 15X0.011602X6.4747 Z10 1 4 15X0.012438X8.0207 Z10 1 5 15X0.012844X9.5031 Z10 1 1 16X0.0083125X2.8592 Z10 1 2 16X0.010008X4.7973 Z10 1 3 16X0.010938X6.4729 Z10 1 4 16X0.011766X8.0201 Z10 1 5 16X0.012273X9.5044 Z10 1 1 17X0.007875X2.8591 Z10 1 2 17X0.0094688X4.7972 Z10 1 3 17X0.01043X6.4745 Z10 1 4 17X0.011227X8.0211 Z10 1 5 17X0.011727X9.5056 Z10 1 1 18X0.0074844X2.8595 Z10 1 2 18X0.0090469X4.7976 Z10 1 3 18X0.0099688X6.4749 Z10 1 4 18X0.010688X8.0206 Z10 1 5 18X0.011188X9.5048 Z10 1 1 19X0.0070938X2.8588 Z10 1 2 19X0.0086328X4.7978 Z10 1 3 19X0.0095X6.4734 Z10 1 4 19X0.010234X8.0214 Z10 1 5 19X0.010688X9.5043 Z10 1 1 20X0.0067656X2.8591 Z10 1 2 20X0.00825X4.7969 Z10 1 3 20X0.0090703X6.4727 Z10 1 4 20X0.0097813X8.0204 Z10 1 5 20X0.01025X9.5047 Z10 1 1 21X0.0064688X2.8588 Z10 1 2 21X0.0079063X4.7973 Z10 1 3 21X0.0086875X6.4722 Z10 1 4 21X0.0093672X8.0194 Z10 1 5 21X0.0098516X9.5048 Z10 1 1 22X0.0061875X2.8588 Z10 1 2 22X0.0075625X4.7961 Z10 1 3 22X0.0082969X6.4709 Z10 1 4 22X0.009X8.0184 Z10 1 5 22X0.0095X9.5053 Z10 1 1 23X0.0059453X2.8586 Z10 1 2 23X0.00725X4.7958 Z10 1 3 23X0.0079688X6.471 Z10 1 4 23X0.0086875X8.0192 Z10 1 5 23X0.0090859X9.5029 Z10 1 1 24X0.0057188X2.8586 Z10 1 2 24X0.0069375X4.795 Z10 1 3 24X0.0076875X6.4705 Z10 1 4 24X0.008375X8.0191 Z10 1 5 24X0.00875X9.5025 Z10 1 1 25X0.0055625X2.8602 Z10 1 2 25X0.0067109X4.796 Z10 1 3 25X0.0074531X6.4723 Z10 1 4 25X0.0080781X8.0187 Z10 1 5 25X0.0084766X9.5038 Z10 1 1 26X0.0053438X2.8595 Z10 1 2 26X0.0064609X4.795 Z10 1 3 26X0.0071641X6.4716 Z10 1 4 26X0.0077969X8.0178 Z10 1 5 26X0.0082031X9.5034 Z10 1 1 27X0.0051406X2.8591 Z10 1 2 27X0.00625X4.796 Z10 1 3 27X0.0069063X6.4719 Z10 1 4 27X0.0075313X8.0182 Z10 1 5 27X0.0079297X9.5019 Z10 1 1 28X0.0049531X2.859 Z10 1 2 28X0.006X4.7941 Z10 1 3 28X0.0067031X6.4723 Z10 1 4 28X0.0072813X8.0176 Z10 1 5 28X0.0076836X9.5027 Z10 1 1 29X0.0047969X2.8593 Z10 1 2 29X0.005875X4.796 Z10 1 3 29X0.0065X6.472 Z10 1 4 29X0.0070781X8.0182 Z10 1 5 29X0.0074531X9.5033 Z10 1 1 30X0.0046406X2.859 Z10 1 2 30X0.0056836X4.7955 Z10 1 3 30X0.0063125X6.4728 Z10 1 4 30X0.0068438X8.0176 Z10 1 5 30X0.0072266X9.5021 Z10 1 1 31X0.0045039X2.8592 Z10 1 2 31X0.0055156X4.7951 Z10 1 3 31X0.0061172X6.4714 Z10 1 4 31X0.0066563X8.0184 Z10 1 5 31X0.0070156X9.5026 Z10 1 1 32X0.0043711X2.8593 Z10 1 2 32X0.0053438X4.7951 Z10 1 3 32X0.0059492X6.4719 Z10 1 4 32X0.0064922X8.0186 Z10 1 5 32X0.0068086X9.5024 Z10 1 1 33X0.0042422X2.8591 Z10 1 2 33X0.0052031X4.7953 Z10 1 3 33X0.0057891X6.4716 Z10 1 4 33X0.0063047X8.018 Z10 1 5 33X0.006625X9.5018 Z10 1 1 34X0.004125X2.8589 Z10 1 2 34X0.0050508X4.7949 Z10 1 3 34X0.0056211X6.4712 Z10 1 4 34X0.0061289X8.0179 Z10 1 5 34X0.0064453X9.5021 Z10 1 1 35X0.0040156X2.8588 Z10 1 2 35X0.0049219X4.7948 Z10 1 3 35X0.0054648X6.4708 Z10 1 4 35X0.0059688X8.0174 Z10 1 5 35X0.0062813X9.5021 Z10 1 1 36X0.0039219X2.859 Z10 1 2 36X0.0047852X4.7948 Z10 1 3 36X0.0053281X6.4711 Z10 1 4 36X0.0058281X8.0178 Z10 1 5 36X0.0061172X9.5015 Z10 1 1 37X0.0038125X2.8584 Z10 1 2 37X0.0046719X4.7948 Z10 1 3 37X0.0051914X6.4713 Z10 1 4 37X0.0056641X8.017 Z10 1 5 37X0.0059688X9.5013 Z10 1 1 38X0.0037109X2.8583 Z10 1 2 38X0.0045547X4.7947 Z10 1 3 38X0.0050781X6.4719 Z10 1 4 38X0.0055469X8.0176 Z10 1 5 38X0.0058281X9.5014 Z10 1 1 39X0.0036172X2.8583 Z10 1 2 39X0.0044453X4.7945 Z10 1 3 39X0.0049492X6.4712 Z10 1 4 39X0.0054258X8.0181 Z10 1 5 39X0.0056875X9.501 Z10 1 1 40X0.0035625X2.8598 Z10 1 2 40X0.0043516X4.7952 Z10 1 3 40X0.0048281X6.471 Z10 1 4 40X0.0053125X8.0187 Z10 1 5 40X0.0055508X9.5006 Z10 1 1 41X0.0034492X2.8583 Z10 1 2 41X0.0042578X4.7956 Z10 1 3 41X0.0047031X6.4702 Z10 1 4 41X0.0051797X8.0179 Z10 1 5 41X0.0054297X9.5004 Z10 1 1 42X0.0033672X2.8579 Z10 1 2 42X0.0041563X4.7954 Z10 1 3 42X0.004625X6.4716 Z10 1 4 42X0.0050703X8.0179 Z10 1 5 42X0.0053203X9.5009 Z10 1 1 43X0.0032891X2.858 Z10 1 2 43X0.0040547X4.7952 Z10 1 3 43X0.0045156X6.471 Z10 1 4 43X0.0049531X8.017 Z10 1 5 43X0.0052031X9.5006 Z10 1 1 44X0.0031875X2.8566 Z10 1 2 44X0.0039688X4.7951 Z10 1 3 44X0.0044141X6.4704 Z10 1 4 44X0.0048594X8.0172 Z10 1 5 44X0.0051094X9.5016 Z10 1 1 45X0.003125X2.8574 Z10 1 2 45X0.0038906X4.7951 Z10 1 3 45X0.0043281X6.4712 Z10 1 4 45X0.0047617X8.0177 Z10 1 5 45X0.0049922X9.5009 Z10 1 1 46X0.0030781X2.8584 Z10 1 2 46X0.0038164X4.7954 Z10 1 3 46X0.0042344X6.471 Z10 1 4 46X0.0046563X8.0169 Z10 1 5 46X0.0048984X9.5012 Z10 1 1 47X0.0030195X2.8585 Z10 1 2 47X0.0037266X4.7948 Z10 1 3 47X0.0041602X6.4715 Z10 1 4 47X0.0045625X8.0168 Z10 1 5 47X0.0048125X9.5017 Z10 1 1 48X0.0029531X2.8581 Z10 1 2 48X0.0036445X4.7946 Z10 1 3 48X0.0040859X6.4719 Z10 1 4 48X0.0044688X8.0167 Z10 1 5 48X0.0047188X9.5017 Z10 1 1 49X0.0028984X2.8586 Z10 1 2 49X0.0035781X4.7948 Z10 1 3 49X0.0040078X6.4717 Z10 1 4 49X0.0043789X8.0163 Z10 1 5 49X0.0046289X9.5015 Z10 1 1 50X0.0028516X2.8591 Z10 1 2 50X0.0035X4.7946 Z10 1 3 50X0.0039297X6.4717 Z10 1 4 50X0.0043008X8.0165 Z10 1 5 50X0.0045469X9.5012 Z10 2 1 1X0.11838X3.0321 Z10 2 2 1X0.08475X4.9999 Z10 2 3 1X0.0705X6.7033 Z10 2 4 1X0.061938X8.2697 Z10 2 5 1X0.055438X9.7673 Z10 2 1 2X0.082625X3.0222 Z10 2 2 2X0.08475X4.9999 Z10 2 3 2X0.0705X6.7033 Z10 2 4 2X0.061938X8.2697 Z10 2 5 2X0.055438X9.7673 Z10 2 1 3X0.063688X3.0176 Z10 2 2 3X0.068125X4.9937 Z10 2 3 3X0.0705X6.7033 Z10 2 4 3X0.061938X8.2697 Z10 2 5 3X0.055438X9.7673 Z10 2 1 4X0.051594X3.012 Z10 2 2 4X0.057094X4.9898 Z10 2 3 4X0.059813X6.6962 Z10 2 4 4X0.061938X8.2697 Z10 2 5 4X0.055438X9.7673 Z10 2 1 5X0.0435X3.0092 Z10 2 2 5X0.049X4.9869 Z10 2 3 5X0.052375X6.696 Z10 2 4 5X0.054313X8.2651 Z10 2 5 5X0.055438X9.7673 Z10 2 1 6X0.037719X3.0082 Z10 2 2 6X0.043188X4.9856 Z10 2 3 6X0.046313X6.6934 Z10 2 4 6X0.048531X8.264 Z10 2 5 6X0.049656X9.764 Z10 2 1 7X0.033328X3.0069 Z10 2 2 7X0.038469X4.9826 Z10 2 3 7X0.041625X6.6922 Z10 2 4 7X0.043688X8.2581 Z10 2 5 7X0.044938X9.7602 Z10 2 1 8X0.029781X3.0055 Z10 2 2 8X0.034781X4.9817 Z10 2 3 8X0.03775X6.6899 Z10 2 4 8X0.039813X8.2568 Z10 2 5 8X0.040953X9.758 Z10 2 1 9X0.027X3.0047 Z10 2 2 9X0.031672X4.9817 Z10 2 3 9X0.034578X6.6889 Z10 2 4 9X0.036563X8.2549 Z10 2 5 9X0.037781X9.7572 Z10 2 1 10X0.024625X3.0036 Z10 2 2 10X0.029156X4.9814 Z10 2 3 10X0.03175X6.6859 Z10 2 4 10X0.033797X8.2534 Z10 2 5 10X0.034891X9.7529 Z10 2 1 11X0.022734X3.0042 Z10 2 2 11X0.027016X4.9811 Z10 2 3 11X0.0295X6.6841 Z10 2 4 11X0.031469X8.2542 Z10 2 5 11X0.032688X9.755 Z10 2 1 12X0.021X3.0026 Z10 2 2 12X0.025125X4.9795 Z10 2 3 12X0.027547X6.6835 Z10 2 4 12X0.029375X8.2524 Z10 2 5 12X0.030656X9.7539 Z10 2 1 13X0.019563X3.002 Z10 2 2 13X0.023453X4.9798 Z10 2 3 13X0.025781X6.6844 Z10 2 4 13X0.027648X8.2524 Z10 2 5 13X0.028828X9.7531 Z10 2 1 14X0.018297X3.0019 Z10 2 2 14X0.022X4.9789 Z10 2 3 14X0.02425X6.683 Z10 2 4 14X0.026063X8.253 Z10 2 5 14X0.02718X9.7517 Z10 2 1 15X0.017219X3.0022 Z10 2 2 15X0.02075X4.9778 Z10 2 3 15X0.022906X6.6832 Z10 2 4 15X0.024648X8.2528 Z10 2 5 15X0.025758X9.7523 Z10 2 1 16X0.016219X3.0014 Z10 2 2 16X0.019625X4.9788 Z10 2 3 16X0.021688X6.6821 Z10 2 4 16X0.023344X8.2507 Z10 2 5 16X0.024469X9.7523 Z10 2 1 17X0.015328X3.0008 Z10 2 2 17X0.018563X4.9783 Z10 2 3 17X0.020594X6.6816 Z10 2 4 17X0.022164X8.2497 Z10 2 5 17X0.023297X9.7521 Z10 2 1 18X0.014547X3.0004 Z10 2 2 18X0.017648X4.977 Z10 2 3 18X0.019625X6.6814 Z10 2 4 18X0.021156X8.2493 Z10 2 5 18X0.022266X9.7524 Z10 2 1 19X0.013852X3.0008 Z10 2 2 19X0.016844X4.9771 Z10 2 3 19X0.018766X6.6828 Z10 2 4 19X0.020211X8.2497 Z10 2 5 19X0.021234X9.7506 Z10 2 1 20X0.013219X3.0009 Z10 2 2 20X0.016063X4.9759 Z10 2 3 20X0.017945X6.6819 Z10 2 4 20X0.019328X8.2486 Z10 2 5 20X0.020313X9.7509 Z10 2 1 21X0.012625X3 Z10 2 2 21X0.015367X4.9753 Z10 2 3 21X0.017227X6.6824 Z10 2 4 21X0.018547X8.2479 Z10 2 5 21X0.019539X9.7509 Z10 2 1 22X0.012078X2.9994 Z10 2 2 22X0.014711X4.9745 Z10 2 3 22X0.016523X6.6806 Z10 2 4 22X0.017828X8.2474 Z10 2 5 22X0.01875X9.749 Z10 2 1 23X0.011563X2.9984 Z10 2 2 23X0.014156X4.9743 Z10 2 3 23X0.015906X6.6799 Z10 2 4 23X0.01718X8.2473 Z10 2 5 23X0.018063X9.7497 Z10 2 1 24X0.011094X2.9979 Z10 2 2 24X0.013609X4.9739 Z10 2 3 24X0.015313X6.6801 Z10 2 4 24X0.016516X8.2456 Z10 2 5 24X0.017383X9.7476 Z10 2 1 25X0.010688X2.9983 Z10 2 2 25X0.013117X4.975 Z10 2 3 25X0.014766X6.6798 Z10 2 4 25X0.015922X8.2455 Z10 2 5 25X0.016766X9.7463 Z10 2 1 26X0.010344X2.9993 Z10 2 2 26X0.012688X4.976 Z10 2 3 26X0.014262X6.6793 Z10 2 4 26X0.015367X8.2447 Z10 2 5 26X0.016242X9.7471 Z10 2 1 27X0.0099688X2.999 Z10 2 2 27X0.012234X4.9764 Z10 2 3 27X0.013773X6.6797 Z10 2 4 27X0.014844X8.244 Z10 2 5 27X0.015719X9.7465 Z10 2 1 28X0.0096367X2.9995 Z10 2 2 28X0.011844X4.9751 Z10 2 3 28X0.013328X6.6798 Z10 2 4 28X0.014359X8.244 Z10 2 5 28X0.015188X9.7452 Z10 2 1 29X0.0093125X2.9987 Z10 2 2 29X0.011484X4.9754 Z10 2 3 29X0.012902X6.6786 Z10 2 4 29X0.013906X8.2433 Z10 2 5 29X0.014742X9.745 Z10 2 1 30X0.0090117X2.9984 Z10 2 2 30X0.011141X4.9754 Z10 2 3 30X0.012531X6.6792 Z10 2 4 30X0.0135X8.2435 Z10 2 5 30X0.01432X9.7455 Z10 2 1 31X0.0087266X2.9981 Z10 2 2 31X0.010797X4.9744 Z10 2 3 31X0.012156X6.6784 Z10 2 4 31X0.013125X8.2443 Z10 2 5 31X0.013906X9.7464 Z10 2 1 32X0.0084766X2.9986 Z10 2 2 32X0.010469X4.9739 Z10 2 3 32X0.011805X6.6781 Z10 2 4 32X0.01275X8.2436 Z10 2 5 32X0.013516X9.7466 Z10 2 1 33X0.0082344X2.9983 Z10 2 2 33X0.010156X4.9728 Z10 2 3 33X0.011438X6.676 Z10 2 4 33X0.012406X8.2437 Z10 2 5 33X0.013141X9.7449 Z10 2 1 34X0.0080078X2.9979 Z10 2 2 34X0.0098906X4.9734 Z10 2 3 34X0.011164X6.678 Z10 2 4 34X0.012078X8.243 Z10 2 5 34X0.012766X9.7437 Z10 2 1 35X0.0077734X2.9969 Z10 2 2 35X0.0096172X4.9721 Z10 2 3 35X0.010875X6.6784 Z10 2 4 35X0.011773X8.2438 Z10 2 5 35X0.012453X9.745 Z10 2 1 36X0.0075547X2.9969 Z10 2 2 36X0.0093516X4.9712 Z10 2 3 36X0.010563X6.6771 Z10 2 4 36X0.011484X8.2434 Z10 2 5 36X0.012125X9.745 Z10 2 1 37X0.007375X2.9976 Z10 2 2 37X0.0091172X4.9713 Z10 2 3 37X0.010328X6.678 Z10 2 4 37X0.011215X8.2442 Z10 2 5 37X0.011844X9.7451 Z10 2 1 38X0.0071719X2.9966 Z10 2 2 38X0.008875X4.9713 Z10 2 3 38X0.010074X6.678 Z10 2 4 38X0.010938X8.2438 Z10 2 5 38X0.011555X9.745 Z10 2 1 39X0.0069922X2.9962 Z10 2 2 39X0.0086875X4.9718 Z10 2 3 39X0.009832X6.677 Z10 2 4 39X0.010688X8.2445 Z10 2 5 39X0.011281X9.7445 Z10 2 1 40X0.0068125X2.9955 Z10 2 2 40X0.0084844X4.9721 Z10 2 3 40X0.0095938X6.6768 Z10 2 4 40X0.010422X8.2439 Z10 2 5 40X0.011047X9.7456 Z10 2 1 41X0.0066641X2.996 Z10 2 2 41X0.008293X4.9728 Z10 2 3 41X0.009375X6.6768 Z10 2 4 41X0.010188X8.2427 Z10 2 5 41X0.010813X9.7456 Z10 2 1 42X0.0065X2.9954 Z10 2 2 42X0.0081016X4.9726 Z10 2 3 42X0.0091719X6.6774 Z10 2 4 42X0.0099531X8.2427 Z10 2 5 42X0.010594X9.746 Z10 2 1 43X0.0063672X2.9959 Z10 2 2 43X0.0079219X4.9732 Z10 2 3 43X0.0089688X6.6769 Z10 2 4 43X0.0097617X8.2427 Z10 2 5 43X0.010352X9.7451 Z10 2 1 44X0.0062383X2.9966 Z10 2 2 44X0.0077344X4.972 Z10 2 3 44X0.0087734X6.6759 Z10 2 4 44X0.0095547X8.2423 Z10 2 5 44X0.010133X9.7454 Z10 2 1 45X0.0061055X2.9971 Z10 2 2 45X0.0075859X4.9725 Z10 2 3 45X0.0085781X6.6763 Z10 2 4 45X0.0093594X8.2426 Z10 2 5 45X0.0099219X9.7446 Z10 2 1 46X0.0059766X2.9969 Z10 2 2 46X0.0074453X4.9732 Z10 2 3 46X0.0084375X6.6782 Z10 2 4 46X0.0091875X8.243 Z10 2 5 46X0.0097031X9.7434 Z10 2 1 47X0.0058438X2.9964 Z10 2 2 47X0.0072852X4.9729 Z10 2 3 47X0.0082344X6.6765 Z10 2 4 47X0.0089922X8.2424 Z10 2 5 47X0.0095273X9.7435 Z10 2 1 48X0.0057305X2.9964 Z10 2 2 48X0.007125X4.9723 Z10 2 3 48X0.0080625X6.6761 Z10 2 4 48X0.0088125X8.2412 Z10 2 5 48X0.0093438X9.7433 Z10 2 1 49X0.005625X2.9966 Z10 2 2 49X0.0070156X4.9735 Z10 2 3 49X0.0079063X6.6756 Z10 2 4 49X0.0086523X8.2426 Z10 2 5 49X0.0091719X9.7433 Z10 2 1 50X0.0055156X2.9968 Z10 2 2 50X0.006875X4.9733 Z10 2 3 50X0.0077656X6.6764 Z10 2 4 50X0.0084844X8.242 Z10 2 5 50X0.0090156X9.744 Z10 5 1 1X0.30306X3.5328 Z10 5 2 1X0.21247X5.5886 Z10 5 3 1X0.17441X7.354 Z10 5 4 1X0.15253X8.9752 Z10 5 5 1X0.13609X10.514 Z10 5 1 2X0.19513X3.46 Z10 5 2 2X0.21247X5.5886 Z10 5 3 2X0.17441X7.354 Z10 5 4 2X0.15253X8.9752 Z10 5 5 2X0.13609X10.514 Z10 5 1 3X0.14706X3.4338 Z10 5 2 3X0.16519X5.5527 Z10 5 3 3X0.17441X7.354 Z10 5 4 3X0.15253X8.9752 Z10 5 5 3X0.13609X10.514 Z10 5 1 4X0.11794X3.4132 Z10 5 2 4X0.13603X5.5271 Z10 5 3 4X0.14563X7.3252 Z10 5 4 4X0.15253X8.9752 Z10 5 5 4X0.13609X10.514 Z10 5 1 5X0.099X3.4032 Z10 5 2 5X0.11588X5.5135 Z10 5 3 5X0.12497X7.3038 Z10 5 4 5X0.13234X8.9567 Z10 5 5 5X0.13609X10.514 Z10 5 1 6X0.085125X3.3955 Z10 5 2 6X0.101X5.5018 Z10 5 3 6X0.1098X7.2911 Z10 5 4 6X0.117X8.9433 Z10 5 5 6X0.12056X10.493 Z10 5 1 7X0.074672X3.3855 Z10 5 2 7X0.089563X5.4907 Z10 5 3 7X0.098063X7.2832 Z10 5 4 7X0.10466X8.9273 Z10 5 5 7X0.10863X10.482 Z10 5 1 8X0.066594X3.3797 Z10 5 2 8X0.080469X5.4824 Z10 5 3 8X0.088406X7.2725 Z10 5 4 8X0.094781X8.918 Z10 5 5 8X0.098922X10.475 Z10 5 1 9X0.060313X3.3788 Z10 5 2 9X0.073188X5.4786 Z10 5 3 9X0.080688X7.2653 Z10 5 4 9X0.086844X8.9097 Z10 5 5 9X0.090625X10.464 Z10 5 1 10X0.054969X3.3752 Z10 5 2 10X0.066938X5.4722 Z10 5 3 10X0.074125X7.2583 Z10 5 4 10X0.079906X8.9017 Z10 5 5 10X0.083641X10.457 Z10 5 1 11X0.050563X3.3736 Z10 5 2 11X0.061688X5.4688 Z10 5 3 11X0.068609X7.2533 Z10 5 4 11X0.074031X8.8931 Z10 5 5 11X0.07775X10.45 Z10 5 1 12X0.046813X3.3716 Z10 5 2 12X0.057188X5.4635 Z10 5 3 12X0.063797X7.2474 Z10 5 4 12X0.068961X8.8865 Z10 5 5 12X0.072563X10.445 Z10 5 1 13X0.043547X3.3679 Z10 5 2 13X0.053375X5.461 Z10 5 3 13X0.059641X7.2437 Z10 5 4 13X0.064617X8.8834 Z10 5 5 13X0.068063X10.438 Z10 5 1 14X0.040734X3.3661 Z10 5 2 14X0.05X5.4557 Z10 5 3 14X0.056X7.2393 Z10 5 4 14X0.06075X8.8802 Z10 5 5 14X0.064172X10.434 Z10 5 1 15X0.038219X3.3639 Z10 5 2 15X0.047031X5.4528 Z10 5 3 15X0.052703X7.2341 Z10 5 4 15X0.057273X8.8764 Z10 5 5 15X0.060609X10.432 Z10 5 1 16X0.036X3.3619 Z10 5 2 16X0.044422X5.4509 Z10 5 3 16X0.049938X7.2338 Z10 5 4 16X0.05425X8.8736 Z10 5 5 16X0.057398X10.425 Z10 5 1 17X0.034094X3.3622 Z10 5 2 17X0.042063X5.4481 Z10 5 3 17X0.047313X7.23 Z10 5 4 17X0.051563X8.8709 Z10 5 5 17X0.054445X10.421 Z10 5 1 18X0.032313X3.3614 Z10 5 2 18X0.04X5.4485 Z10 5 3 18X0.044969X7.2274 Z10 5 4 18X0.049086X8.8689 Z10 5 5 18X0.051938X10.421 Z10 5 1 19X0.030688X3.3601 Z10 5 2 19X0.038117X5.4468 Z10 5 3 19X0.042906X7.2266 Z10 5 4 19X0.046938X8.8679 Z10 5 5 19X0.049563X10.416 Z10 5 1 20X0.02925X3.3583 Z10 5 2 20X0.036336X5.4446 Z10 5 3 20X0.041X7.2266 Z10 5 4 20X0.044875X8.8658 Z10 5 5 20X0.047297X10.412 Z10 5 1 21X0.027984X3.3593 Z10 5 2 21X0.034797X5.4433 Z10 5 3 21X0.03925X7.2246 Z10 5 4 21X0.042984X8.864 Z10 5 5 21X0.045414X10.411 Z10 5 1 22X0.026813X3.3585 Z10 5 2 22X0.033375X5.4426 Z10 5 3 22X0.037672X7.2237 Z10 5 4 22X0.041313X8.864 Z10 5 5 22X0.043625X10.408 Z10 5 1 23X0.025703X3.3578 Z10 5 2 23X0.032023X5.4414 Z10 5 3 23X0.036156X7.2219 Z10 5 4 23X0.03975X8.8643 Z10 5 5 23X0.042X10.408 Z10 5 1 24X0.024711X3.3563 Z10 5 2 24X0.03082X5.4413 Z10 5 3 24X0.03475X7.219 Z10 5 4 24X0.038211X8.8606 Z10 5 5 24X0.04043X10.405 Z10 5 1 25X0.023781X3.3562 Z10 5 2 25X0.029688X5.4405 Z10 5 3 25X0.033531X7.2168 Z10 5 4 25X0.036852X8.8592 Z10 5 5 25X0.038961X10.404 Z10 5 1 26X0.022922X3.3546 Z10 5 2 26X0.028625X5.4396 Z10 5 3 26X0.032391X7.2165 Z10 5 4 26X0.035531X8.8561 Z10 5 5 26X0.037688X10.402 Z10 5 1 27X0.022094X3.355 Z10 5 2 27X0.027656X5.4394 Z10 5 3 27X0.031297X7.216 Z10 5 4 27X0.034352X8.8548 Z10 5 5 27X0.036438X10.401 Z10 5 1 28X0.021352X3.354 Z10 5 2 28X0.02675X5.4389 Z10 5 3 28X0.030258X7.2153 Z10 5 4 28X0.03325X8.8523 Z10 5 5 28X0.035281X10.401 Z10 5 1 29X0.020672X3.3548 Z10 5 2 29X0.025883X5.438 Z10 5 3 29X0.029313X7.2145 Z10 5 4 29X0.032195X8.8507 Z10 5 5 29X0.034156X10.399 Z10 5 1 30X0.020035X3.3542 Z10 5 2 30X0.025031X5.4351 Z10 5 3 30X0.028414X7.2137 Z10 5 4 30X0.031234X8.8507 Z10 5 5 30X0.033164X10.398 Z10 5 1 31X0.019398X3.3535 Z10 5 2 31X0.024266X5.4339 Z10 5 3 31X0.027563X7.2118 Z10 5 4 31X0.030297X8.8498 Z10 5 5 31X0.032188X10.397 Z10 5 1 32X0.018844X3.354 Z10 5 2 32X0.023563X5.4345 Z10 5 3 32X0.026781X7.2114 Z10 5 4 32X0.029422X8.8489 Z10 5 5 32X0.031281X10.397 Z10 5 1 33X0.018277X3.3522 Z10 5 2 33X0.022875X5.4321 Z10 5 3 33X0.026063X7.2127 Z10 5 4 33X0.028594X8.8465 Z10 5 5 33X0.030418X10.396 Z10 5 1 34X0.01775X3.351 Z10 5 2 34X0.022273X5.4326 Z10 5 3 34X0.025328X7.2116 Z10 5 4 34X0.027805X8.8461 Z10 5 5 34X0.029594X10.395 Z10 5 1 35X0.017266X3.3511 Z10 5 2 35X0.021656X5.4323 Z10 5 3 35X0.02466X7.2121 Z10 5 4 35X0.027098X8.8455 Z10 5 5 35X0.028824X10.395 Z10 5 1 36X0.016789X3.3496 Z10 5 2 36X0.021063X5.4314 Z10 5 3 36X0.024X7.2106 Z10 5 4 36X0.026406X8.8448 Z10 5 5 36X0.028109X10.394 Z10 5 1 37X0.016359X3.3486 Z10 5 2 37X0.020531X5.4313 Z10 5 3 37X0.023387X7.2103 Z10 5 4 37X0.025727X8.8427 Z10 5 5 37X0.027414X10.394 Z10 5 1 38X0.015953X3.349 Z10 5 2 38X0.020047X5.432 Z10 5 3 38X0.022836X7.211 Z10 5 4 38X0.025109X8.8441 Z10 5 5 38X0.026719X10.392 Z10 5 1 39X0.01557X3.3501 Z10 5 2 39X0.019547X5.4313 Z10 5 3 39X0.022281X7.2107 Z10 5 4 39X0.024465X8.8394 Z10 5 5 39X0.026094X10.392 Z10 5 1 40X0.015195X3.3496 Z10 5 2 40X0.019102X5.4318 Z10 5 3 40X0.02175X7.2098 Z10 5 4 40X0.023898X8.8402 Z10 5 5 40X0.025457X10.389 Z10 5 1 41X0.014844X3.3494 Z10 5 2 41X0.018688X5.4332 Z10 5 3 41X0.021266X7.2109 Z10 5 4 41X0.023383X8.8399 Z10 5 5 41X0.024918X10.39 Z10 5 1 42X0.0145X3.3492 Z10 5 2 42X0.018242X5.4321 Z10 5 3 42X0.020813X7.2104 Z10 5 4 42X0.022867X8.8387 Z10 5 5 42X0.024344X10.388 Z10 5 1 43X0.014188X3.3495 Z10 5 2 43X0.017836X5.4324 Z10 5 3 43X0.020344X7.2096 Z10 5 4 43X0.022383X8.8394 Z10 5 5 43X0.023828X10.388 Z10 5 1 44X0.013875X3.3498 Z10 5 2 44X0.017438X5.4306 Z10 5 3 44X0.019898X7.2086 Z10 5 4 44X0.021891X8.8382 Z10 5 5 44X0.023313X10.387 Z10 5 1 45X0.013547X3.3476 Z10 5 2 45X0.017063X5.4299 Z10 5 3 45X0.019484X7.2092 Z10 5 4 45X0.021414X8.8361 Z10 5 5 45X0.022836X10.386 Z10 5 1 46X0.013266X3.3479 Z10 5 2 46X0.016711X5.4296 Z10 5 3 46X0.019086X7.2084 Z10 5 4 46X0.020965X8.8354 Z10 5 5 46X0.022375X10.384 Z10 5 1 47X0.012969X3.3461 Z10 5 2 47X0.016355X5.4294 Z10 5 3 47X0.018699X7.2077 Z10 5 4 47X0.020578X8.8347 Z10 5 5 47X0.021922X10.383 Z10 5 1 48X0.012727X3.3471 Z10 5 2 48X0.016039X5.4293 Z10 5 3 48X0.018336X7.2069 Z10 5 4 48X0.020172X8.8343 Z10 5 5 48X0.0215X10.382 Z10 5 1 49X0.01248X3.3472 Z10 5 2 49X0.015734X5.4295 Z10 5 3 49X0.017969X7.2065 Z10 5 4 49X0.019789X8.8347 Z10 5 5 49X0.021094X10.383 Z10 5 1 50X0.012234X3.3466 Z10 5 2 50X0.015438X5.4293 Z10 5 3 50X0.017625X7.2054 Z10 5 4 50X0.019422X8.8352 Z10 5 5 50X0.020703X10.382 Z10 10 1 1X0.64413X4.4575 Z10 10 2 1X0.42869X6.5852 Z10 10 3 1X0.34663X8.4324 Z10 10 4 1X0.29769X10.106 Z10 10 5 1X0.26559X11.712 Z10 10 1 2X0.35719X4.1287 Z10 10 2 2X0.42869X6.5852 Z10 10 3 2X0.34663X8.4324 Z10 10 4 2X0.29769X10.106 Z10 10 5 2X0.26559X11.712 Z10 10 1 3X0.25781X4.0205 Z10 10 2 3X0.31713X6.4379 Z10 10 3 3X0.34663X8.4324 Z10 10 4 3X0.29769X10.106 Z10 10 5 3X0.26559X11.712 Z10 10 1 4X0.20369X3.9624 Z10 10 2 4X0.25359X6.3462 Z10 10 3 4X0.28031X8.3236 Z10 10 4 4X0.29769X10.106 Z10 10 5 4X0.26559X11.712 Z10 10 1 5X0.16909X3.9288 Z10 10 2 5X0.21213X6.2912 Z10 10 3 5X0.23581X8.2465 Z10 10 4 5X0.25256X10.03 Z10 10 5 5X0.26559X11.712 Z10 10 1 6X0.14506X3.9078 Z10 10 2 6X0.18264X6.2502 Z10 10 3 6X0.20425X8.1982 Z10 10 4 6X0.21963X9.9686 Z10 10 5 6X0.23209X11.647 Z10 10 1 7X0.12703X3.8887 Z10 10 2 7X0.16056X6.2159 Z10 10 3 7X0.18069X8.1628 Z10 10 4 7X0.19461X9.9206 Z10 10 5 7X0.20647X11.6 Z10 10 1 8X0.11311X3.8737 Z10 10 2 8X0.14331X6.1913 Z10 10 3 8X0.16177X8.1331 Z10 10 4 8X0.17475X9.8861 Z10 10 5 8X0.18586X11.564 Z10 10 1 9X0.10213X3.8667 Z10 10 2 9X0.12969X6.1731 Z10 10 3 9X0.14663X8.1066 Z10 10 4 9X0.15913X9.8648 Z10 10 5 9X0.16909X11.53 Z10 10 1 10X0.093109X3.8581 Z10 10 2 10X0.11836X6.1576 Z10 10 3 10X0.13419X8.0884 Z10 10 4 10X0.14563X9.8358 Z10 10 5 10X0.15536X11.507 Z10 10 1 11X0.0855X3.8528 Z10 10 2 11X0.10869X6.1425 Z10 10 3 11X0.12358X8.0703 Z10 10 4 11X0.13438X9.8192 Z10 10 5 11X0.14344X11.481 Z10 10 1 12X0.079172X3.8488 Z10 10 2 12X0.10075X6.133 Z10 10 3 12X0.11468X8.054 Z10 10 4 12X0.12478X9.798 Z10 10 5 12X0.13318X11.457 Z10 10 1 13X0.073625X3.8423 Z10 10 2 13X0.093734X6.1233 Z10 10 3 13X0.10681X8.0397 Z10 10 4 13X0.11642X9.7804 Z10 10 5 13X0.12461X11.439 Z10 10 1 14X0.068719X3.8354 Z10 10 2 14X0.087797X6.1153 Z10 10 3 14X0.10013X8.0299 Z10 10 4 14X0.10928X9.7698 Z10 10 5 14X0.11711X11.427 Z10 10 1 15X0.064578X3.8327 Z10 10 2 15X0.082531X6.1088 Z10 10 3 15X0.094125X8.02 Z10 10 4 15X0.10295X9.7615 Z10 10 5 15X0.11023X11.414 Z10 10 1 16X0.060891X3.8306 Z10 10 2 16X0.077805X6.1016 Z10 10 3 16X0.088906X8.0111 Z10 10 4 16X0.097195X9.7489 Z10 10 5 16X0.10409X11.398 Z10 10 1 17X0.057563X3.8269 Z10 10 2 17X0.073688X6.0981 Z10 10 3 17X0.084195X8.0059 Z10 10 4 17X0.092188X9.742 Z10 10 5 17X0.098703X11.386 Z10 10 1 18X0.054563X3.8241 Z10 10 2 18X0.069961X6.0939 Z10 10 3 18X0.079969X7.9958 Z10 10 4 18X0.0875X9.7324 Z10 10 5 18X0.093938X11.377 Z10 10 1 19X0.051906X3.823 Z10 10 2 19X0.066531X6.0877 Z10 10 3 19X0.076125X7.9884 Z10 10 4 19X0.083406X9.7238 Z10 10 5 19X0.089625X11.373 Z10 10 1 20X0.049563X3.8233 Z10 10 2 20X0.063438X6.0813 Z10 10 3 20X0.072625X7.9814 Z10 10 4 20X0.079691X9.7175 Z10 10 5 20X0.085531X11.362 Z10 10 1 21X0.047305X3.8191 Z10 10 2 21X0.060578X6.0758 Z10 10 3 21X0.0695X7.9784 Z10 10 4 21X0.076281X9.7135 Z10 10 5 21X0.081984X11.357 Z10 10 1 22X0.045266X3.8168 Z10 10 2 22X0.058094X6.0761 Z10 10 3 22X0.066531X7.9713 Z10 10 4 22X0.073125X9.708 Z10 10 5 22X0.078609X11.351 Z10 10 1 23X0.043406X3.8134 Z10 10 2 23X0.055742X6.0723 Z10 10 3 23X0.063867X7.9657 Z10 10 4 23X0.070273X9.704 Z10 10 5 23X0.075547X11.345 Z10 10 1 24X0.041703X3.8114 Z10 10 2 24X0.053563X6.0682 Z10 10 3 24X0.061375X7.9595 Z10 10 4 24X0.067563X9.6981 Z10 10 5 24X0.072695X11.339 Z10 10 1 25X0.040117X3.8084 Z10 10 2 25X0.051547X6.0661 Z10 10 3 25X0.059145X7.9584 Z10 10 4 25X0.065094X9.6943 Z10 10 5 25X0.070031X11.333 Z10 10 1 26X0.038656X3.8068 Z10 10 2 26X0.049656X6.0605 Z10 10 3 26X0.057023X7.955 Z10 10 4 26X0.062781X9.691 Z10 10 5 26X0.067594X11.329 Z10 10 1 27X0.037281X3.8045 Z10 10 2 27X0.047906X6.0575 Z10 10 3 27X0.05507X7.9527 Z10 10 4 27X0.060602X9.6862 Z10 10 5 27X0.06525X11.321 Z10 10 1 28X0.036X3.8031 Z10 10 2 28X0.046281X6.0542 Z10 10 3 28X0.053266X7.9507 Z10 10 4 28X0.058625X9.6817 Z10 10 5 28X0.063133X11.319 Z10 10 1 29X0.034875X3.8046 Z10 10 2 29X0.044813X6.0534 Z10 10 3 29X0.051563X7.9479 Z10 10 4 29X0.056797X9.6814 Z10 10 5 29X0.061172X11.315 Z10 10 1 30X0.033719X3.8018 Z10 10 2 30X0.043375X6.05 Z10 10 3 30X0.049984X7.9469 Z10 10 4 30X0.055008X9.6753 Z10 10 5 30X0.059266X11.311 Z10 10 1 31X0.032688X3.802 Z10 10 2 31X0.042047X6.0486 Z10 10 3 31X0.048453X7.9434 Z10 10 4 31X0.053359X9.6723 Z10 10 5 31X0.057566X11.31 Z10 10 1 32X0.031719X3.8011 Z10 10 2 32X0.040781X6.046 Z10 10 3 32X0.047027X7.9416 Z10 10 4 32X0.051797X9.667 Z10 10 5 32X0.055875X11.305 Z10 10 1 33X0.030781X3.8008 Z10 10 2 33X0.039621X6.0458 Z10 10 3 33X0.045688X7.94 Z10 10 4 33X0.050375X9.6671 Z10 10 5 33X0.054281X11.301 Z10 10 1 34X0.029918X3.7989 Z10 10 2 34X0.038484X6.043 Z10 10 3 34X0.044438X7.939 Z10 10 4 34X0.048961X9.6625 Z10 10 5 34X0.052758X11.297 Z10 10 1 35X0.029102X3.7984 Z10 10 2 35X0.03743X6.0423 Z10 10 3 35X0.043234X7.9354 Z10 10 4 35X0.047656X9.661 Z10 10 5 35X0.051355X11.295 Z10 10 1 36X0.028332X3.7973 Z10 10 2 36X0.036484X6.0433 Z10 10 3 36X0.042102X7.9352 Z10 10 4 36X0.046383X9.6569 Z10 10 5 36X0.050055X11.292 Z10 10 1 37X0.027578X3.7946 Z10 10 2 37X0.035531X6.0409 Z10 10 3 37X0.041016X7.9324 Z10 10 4 37X0.045219X9.6548 Z10 10 5 37X0.048797X11.29 Z10 10 1 38X0.026891X3.7948 Z10 10 2 38X0.034625X6.0386 Z10 10 3 38X0.040016X7.9336 Z10 10 4 38X0.044102X9.653 Z10 10 5 38X0.04757X11.287 Z10 10 1 39X0.026211X3.7939 Z10 10 2 39X0.033781X6.0372 Z10 10 3 39X0.039063X7.9324 Z10 10 4 39X0.043047X9.6526 Z10 10 5 39X0.04643X11.285 Z10 10 1 40X0.025586X3.7935 Z10 10 2 40X0.032977X6.0364 Z10 10 3 40X0.038125X7.9305 Z10 10 4 40X0.042023X9.6493 Z10 10 5 40X0.045367X11.285 Z10 10 1 41X0.024996X3.7939 Z10 10 2 41X0.032234X6.0379 Z10 10 3 41X0.037262X7.9299 Z10 10 4 41X0.041059X9.6458 Z10 10 5 41X0.044305X11.281 Z10 10 1 42X0.024434X3.7945 Z10 10 2 42X0.031484X6.036 Z10 10 3 42X0.036398X7.9278 Z10 10 4 42X0.040117X9.6457 Z10 10 5 42X0.043332X11.28 Z10 10 1 43X0.023883X3.7941 Z10 10 2 43X0.030781X6.0362 Z10 10 3 43X0.035574X7.9257 Z10 10 4 43X0.039242X9.6427 Z10 10 5 43X0.042367X11.277 Z10 10 1 44X0.023375X3.7949 Z10 10 2 44X0.030117X6.0343 Z10 10 3 44X0.034801X7.9245 Z10 10 4 44X0.038391X9.6412 Z10 10 5 44X0.041488X11.276 Z10 10 1 45X0.022855X3.7938 Z10 10 2 45X0.029469X6.0316 Z10 10 3 45X0.03407X7.9242 Z10 10 4 45X0.037563X9.6393 Z10 10 5 45X0.040609X11.273 Z10 10 1 46X0.022375X3.7931 Z10 10 2 46X0.028844X6.0317 Z10 10 3 46X0.033313X7.9199 Z10 10 4 46X0.036836X9.6424 Z10 10 5 46X0.039801X11.273 Z10 10 1 47X0.021906X3.7916 Z10 10 2 47X0.02825X6.0316 Z10 10 3 47X0.032688X7.921 Z10 10 4 47X0.036102X9.6395 Z10 10 5 47X0.038969X11.269 Z10 10 1 48X0.021461X3.7906 Z10 10 2 48X0.027688X6.0305 Z10 10 3 48X0.032039X7.9193 Z10 10 4 48X0.035406X9.6399 Z10 10 5 48X0.038211X11.269 Z10 10 1 49X0.021031X3.7899 Z10 10 2 49X0.027125X6.0278 Z10 10 3 49X0.03141X7.9195 Z10 10 4 49X0.034688X9.6352 Z10 10 5 49X0.037469X11.266 Z10 10 1 50X0.020625X3.7894 Z10 10 2 50X0.026625X6.029 Z10 10 3 50X0.030785X7.9169 Z10 10 4 50X0.034051X9.6349 Z10 10 5 50X0.036781X11.264 Z10 15 1 1X1.0413X5.5342 Z10 15 2 1X0.6585X7.6445 Z10 15 3 1X0.51938X9.5141 Z10 15 4 1X0.44375X11.243 Z10 15 5 1X0.39241X12.886 Z10 15 1 2X0.50888X4.7848 Z10 15 2 2X0.6585X7.6445 Z10 15 3 2X0.51938X9.5141 Z10 15 4 2X0.44375X11.243 Z10 15 5 2X0.39241X12.886 Z10 15 1 3X0.35109X4.5427 Z10 15 2 3X0.46166X7.2937 Z10 15 3 3X0.51938X9.5141 Z10 15 4 3X0.44375X11.243 Z10 15 5 3X0.39241X12.886 Z10 15 1 4X0.27238X4.4297 Z10 15 2 4X0.35938X7.1034 Z10 15 3 4X0.40877X9.2872 Z10 15 4 4X0.44375X11.243 Z10 15 5 4X0.39241X12.886 Z10 15 1 5X0.22369X4.36 Z10 15 2 5X0.29584X6.9822 Z10 15 3 5X0.33794X9.13 Z10 15 4 5X0.36897X11.073 Z10 15 5 5X0.39241X12.886 Z10 15 1 6X0.19031X4.312 Z10 15 2 6X0.25244X6.9052 Z10 15 3 6X0.28934X9.026 Z10 15 4 6X0.31644X10.947 Z10 15 5 6X0.33788X12.745 Z10 15 1 7X0.16613X4.2808 Z10 15 2 7X0.22056X6.8446 Z10 15 3 7X0.25356X8.9521 Z10 15 4 7X0.27775X10.852 Z10 15 5 7X0.29706X12.643 Z10 15 1 8X0.14766X4.2573 Z10 15 2 8X0.19595X6.7989 Z10 15 3 8X0.22558X8.8967 Z10 15 4 8X0.24752X10.78 Z10 15 5 8X0.26519X12.567 Z10 15 1 9X0.13294X4.2401 Z10 15 2 9X0.17648X6.7626 Z10 15 3 9X0.20344X8.8462 Z10 15 4 9X0.22348X10.723 Z10 15 5 9X0.24008X12.503 Z10 15 1 10X0.12095X4.2244 Z10 15 2 10X0.16056X6.7334 Z10 15 3 10X0.18531X8.8082 Z10 15 4 10X0.20386X10.678 Z10 15 5 10X0.21895X12.445 Z10 15 1 11X0.11097X4.2105 Z10 15 2 11X0.14741X6.7118 Z10 15 3 11X0.17019X8.778 Z10 15 4 11X0.18744X10.641 Z10 15 5 11X0.20159X12.402 Z10 15 1 12X0.10261X4.2029 Z10 15 2 12X0.13619X6.6894 Z10 15 3 12X0.15738X8.7465 Z10 15 4 12X0.17359X10.609 Z10 15 5 12X0.18703X12.369 Z10 15 1 13X0.095438X4.1933 Z10 15 2 13X0.12659X6.6744 Z10 15 3 13X0.14634X8.7224 Z10 15 4 13X0.16145X10.576 Z10 15 5 13X0.17419X12.331 Z10 15 1 14X0.089219X4.1872 Z10 15 2 14X0.11834X6.6593 Z10 15 3 14X0.13687X8.7044 Z10 15 4 14X0.15109X10.549 Z10 15 5 14X0.16298X12.301 Z10 15 1 15X0.083719X4.1809 Z10 15 2 15X0.11103X6.6469 Z10 15 3 15X0.12856X8.684 Z10 15 4 15X0.14186X10.528 Z10 15 5 15X0.15311X12.272 Z10 15 1 16X0.078891X4.1774 Z10 15 2 16X0.10463X6.6361 Z10 15 3 16X0.12118X8.6684 Z10 15 4 16X0.13381X10.508 Z10 15 5 16X0.1445X12.252 Z10 15 1 17X0.074688X4.1751 Z10 15 2 17X0.098844X6.6238 Z10 15 3 17X0.11469X8.6551 Z10 15 4 17X0.12664X10.493 Z10 15 5 17X0.13688X12.232 Z10 15 1 18X0.070813X4.1704 Z10 15 2 18X0.093742X6.615 Z10 15 3 18X0.10875X8.6419 Z10 15 4 18X0.12017X10.477 Z10 15 5 18X0.12998X12.213 Z10 15 1 19X0.067391X4.1667 Z10 15 2 19X0.089156X6.6066 Z10 15 3 19X0.10351X8.6304 Z10 15 4 19X0.11419X10.458 Z10 15 5 19X0.12366X12.193 Z10 15 1 20X0.064172X4.1621 Z10 15 2 20X0.084977X6.5983 Z10 15 3 20X0.098648X8.6182 Z10 15 4 20X0.10895X10.449 Z10 15 5 20X0.11805X12.178 Z10 15 1 21X0.061344X4.1594 Z10 15 2 21X0.081156X6.5906 Z10 15 3 21X0.094273X8.6072 Z10 15 4 21X0.10413X10.435 Z10 15 5 21X0.11295X12.17 Z10 15 1 22X0.058734X4.1568 Z10 15 2 22X0.07775X6.5856 Z10 15 3 22X0.090195X8.5953 Z10 15 4 22X0.09975X10.424 Z10 15 5 22X0.10816X12.153 Z10 15 1 23X0.056289X4.1526 Z10 15 2 23X0.074531X6.5795 Z10 15 3 23X0.0865X8.5867 Z10 15 4 23X0.095703X10.412 Z10 15 5 23X0.10385X12.142 Z10 15 1 24X0.054109X4.1508 Z10 15 2 24X0.071594X6.5723 Z10 15 3 24X0.083133X8.5786 Z10 15 4 24X0.092016X10.405 Z10 15 5 24X0.09982X12.133 Z10 15 1 25X0.052125X4.1495 Z10 15 2 25X0.068875X6.568 Z10 15 3 25X0.079969X8.5714 Z10 15 4 25X0.088563X10.394 Z10 15 5 25X0.096125X12.124 Z10 15 1 26X0.050211X4.1461 Z10 15 2 26X0.066375X6.5636 Z10 15 3 26X0.077086X8.5645 Z10 15 4 26X0.085398X10.389 Z10 15 5 26X0.092672X12.112 Z10 15 1 27X0.04843X4.1431 Z10 15 2 27X0.064023X6.5585 Z10 15 3 27X0.074406X8.5601 Z10 15 4 27X0.082414X10.382 Z10 15 5 27X0.089422X12.101 Z10 15 1 28X0.046789X4.1405 Z10 15 2 28X0.061875X6.554 Z10 15 3 28X0.071883X8.5558 Z10 15 4 28X0.079672X10.376 Z10 15 5 28X0.0865X12.096 Z10 15 1 29X0.045281X4.1409 Z10 15 2 29X0.059859X6.5521 Z10 15 3 29X0.069539X8.5506 Z10 15 4 29X0.077141X10.374 Z10 15 5 29X0.083656X12.086 Z10 15 1 30X0.043852X4.1384 Z10 15 2 30X0.057953X6.5459 Z10 15 3 30X0.067344X8.5458 Z10 15 4 30X0.074703X10.365 Z10 15 5 30X0.081023X12.08 Z10 15 1 31X0.0425X4.1383 Z10 15 2 31X0.056141X6.542 Z10 15 3 31X0.065297X8.5414 Z10 15 4 31X0.07243X10.358 Z10 15 5 31X0.078598X12.074 Z10 15 1 32X0.041227X4.137 Z10 15 2 32X0.054469X6.5392 Z10 15 3 32X0.063336X8.5364 Z10 15 4 32X0.070313X10.354 Z10 15 5 32X0.076203X12.065 Z10 15 1 33X0.040016X4.135 Z10 15 2 33X0.052922X6.5374 Z10 15 3 33X0.061547X8.5349 Z10 15 4 33X0.068281X10.347 Z10 15 5 33X0.074078X12.06 Z10 15 1 34X0.038883X4.133 Z10 15 2 34X0.051414X6.5345 Z10 15 3 34X0.05975X8.5288 Z10 15 4 34X0.066398X10.344 Z10 15 5 34X0.072012X12.054 Z10 15 1 35X0.037813X4.1304 Z10 15 2 35X0.050008X6.5313 Z10 15 3 35X0.058125X8.5249 Z10 15 4 35X0.064613X10.34 Z10 15 5 35X0.070063X12.049 Z10 15 1 36X0.036809X4.1288 Z10 15 2 36X0.048664X6.5293 Z10 15 3 36X0.056555X8.5195 Z10 15 4 36X0.062891X10.336 Z10 15 5 36X0.06825X12.044 Z10 15 1 37X0.035852X4.1272 Z10 15 2 37X0.047398X6.5269 Z10 15 3 37X0.055125X8.5169 Z10 15 4 37X0.061297X10.332 Z10 15 5 37X0.066516X12.041 Z10 15 1 38X0.034938X4.1273 Z10 15 2 38X0.046211X6.525 Z10 15 3 38X0.053691X8.5125 Z10 15 4 38X0.059766X10.327 Z10 15 5 38X0.064859X12.036 Z10 15 1 39X0.03409X4.1272 Z10 15 2 39X0.045082X6.5224 Z10 15 3 39X0.052375X8.511 Z10 15 4 39X0.058289X10.322 Z10 15 5 39X0.063266X12.032 Z10 15 1 40X0.033285X4.1274 Z10 15 2 40X0.044X6.5203 Z10 15 3 40X0.051141X8.5104 Z10 15 4 40X0.056883X10.318 Z10 15 5 40X0.061766X12.028 Z10 15 1 41X0.032492X4.1263 Z10 15 2 41X0.042953X6.5213 Z10 15 3 41X0.049938X8.5082 Z10 15 4 41X0.055563X10.313 Z10 15 5 41X0.060313X12.024 Z10 15 1 42X0.031738X4.1253 Z10 15 2 42X0.041938X6.5172 Z10 15 3 42X0.048766X8.5041 Z10 15 4 42X0.054266X10.309 Z10 15 5 42X0.058891X12.016 Z10 15 1 43X0.031004X4.1231 Z10 15 2 43X0.041X6.516 Z10 15 3 43X0.047664X8.5027 Z10 15 4 43X0.05309X10.307 Z10 15 5 43X0.057641X12.015 Z10 15 1 44X0.030336X4.1237 Z10 15 2 44X0.040117X6.5145 Z10 15 3 44X0.046648X8.5019 Z10 15 4 44X0.051922X10.304 Z10 15 5 44X0.056375X12.011 Z10 15 1 45X0.029688X4.123 Z10 15 2 45X0.039254X6.511 Z10 15 3 45X0.04566X8.4998 Z10 15 4 45X0.050813X10.3 Z10 15 5 45X0.055188X12.01 Z10 15 1 46X0.029063X4.1237 Z10 15 2 46X0.038449X6.5113 Z10 15 3 46X0.044723X8.4991 Z10 15 4 46X0.049781X10.3 Z10 15 5 46X0.054047X12.006 Z10 15 1 47X0.028438X4.1212 Z10 15 2 47X0.037688X6.5134 Z10 15 3 47X0.043813X8.4973 Z10 15 4 47X0.04875X10.297 Z10 15 5 47X0.052938X12.002 Z10 15 1 48X0.027875X4.1205 Z10 15 2 48X0.036906X6.5094 Z10 15 3 48X0.042926X8.4934 Z10 15 4 48X0.047785X10.296 Z10 15 5 48X0.051906X12 Z10 15 1 49X0.027313X4.1191 Z10 15 2 49X0.03616X6.5075 Z10 15 3 49X0.042063X8.4909 Z10 15 4 49X0.04684X10.291 Z10 15 5 49X0.050875X11.997 Z10 15 1 50X0.026813X4.1201 Z10 15 2 50X0.035465X6.5073 Z10 15 3 50X0.041262X8.4903 Z10 15 4 50X0.045938X10.29 Z10 15 5 50X0.049867X11.99 Z10 20 1 1X1.5148X6.8179 Z10 20 2 1X0.90963X8.802 Z10 20 3 1X0.70319X10.665 Z10 20 4 1X0.59331X12.408 Z10 20 5 1X0.52125X14.078 Z10 20 1 2X0.66519X5.477 Z10 20 2 2X0.90963X8.802 Z10 20 3 2X0.70319X10.665 Z10 20 4 2X0.59331X12.408 Z10 20 5 2X0.52125X14.078 Z10 20 1 3X0.44056X5.0635 Z10 20 2 3X0.60575X8.1583 Z10 20 3 3X0.70319X10.665 Z10 20 4 3X0.59331X12.408 Z10 20 5 3X0.52125X14.078 Z10 20 1 4X0.33456X4.8677 Z10 20 2 4X0.46163X7.8456 Z10 20 3 4X0.53731X10.258 Z10 20 4 4X0.59331X12.408 Z10 20 5 4X0.52125X14.078 Z10 20 1 5X0.27144X4.7516 Z10 20 2 5X0.37419X7.6463 Z10 20 3 5X0.4365X9.9911 Z10 20 4 5X0.48397X12.111 Z10 20 5 5X0.52125X14.078 Z10 20 1 6X0.22931X4.6738 Z10 20 2 6X0.31581X7.5158 Z10 20 3 6X0.36947X9.8214 Z10 20 4 6X0.41017X11.899 Z10 20 5 6X0.44194X13.828 Z10 20 1 7X0.19867X4.6182 Z10 20 2 7X0.27395X7.4148 Z10 20 3 7X0.32088X9.6949 Z10 20 4 7X0.35675X11.751 Z10 20 5 7X0.38503X13.663 Z10 20 1 8X0.17578X4.5794 Z10 20 2 8X0.24236X7.348 Z10 20 3 8X0.28369X9.6013 Z10 20 4 8X0.31588X11.633 Z10 20 5 8X0.34125X13.534 Z10 20 1 9X0.15775X4.5492 Z10 20 2 9X0.21731X7.2869 Z10 20 3 9X0.25478X9.5251 Z10 20 4 9X0.2835X11.533 Z10 20 5 9X0.30638X13.421 Z10 20 1 10X0.14306X4.5223 Z10 20 2 10X0.19733X7.2454 Z10 20 3 10X0.23106X9.4637 Z10 20 4 10X0.25745X11.462 Z10 20 5 10X0.27863X13.336 Z10 20 1 11X0.13113X4.5044 Z10 20 2 11X0.18056X7.2082 Z10 20 3 11X0.21156X9.4137 Z10 20 4 11X0.23581X11.399 Z10 20 5 11X0.25558X13.267 Z10 20 1 12X0.12097X4.4882 Z10 20 2 12X0.16656X7.1755 Z10 20 3 12X0.19519X9.3692 Z10 20 4 12X0.21756X11.344 Z10 20 5 12X0.23619X13.205 Z10 20 1 13X0.11238X4.4736 Z10 20 2 13X0.15461X7.1509 Z10 20 3 13X0.18113X9.3327 Z10 20 4 13X0.20219X11.299 Z10 20 5 13X0.21923X13.148 Z10 20 1 14X0.10486X4.462 Z10 20 2 14X0.14419X7.1285 Z10 20 3 14X0.16894X9.2992 Z10 20 4 14X0.1885X11.258 Z10 20 5 14X0.20472X13.103 Z10 20 1 15X0.098438X4.4528 Z10 20 2 15X0.13514X7.1073 Z10 20 3 15X0.15853X9.2693 Z10 20 4 15X0.17681X11.224 Z10 20 5 15X0.19202X13.059 Z10 20 1 16X0.092656X4.4463 Z10 20 2 16X0.12725X7.0903 Z10 20 3 16X0.14917X9.244 Z10 20 4 16X0.1665X11.198 Z10 20 5 16X0.1808X13.023 Z10 20 1 17X0.087578X4.4403 Z10 20 2 17X0.12016X7.0743 Z10 20 3 17X0.14094X9.2223 Z10 20 4 17X0.15723X11.167 Z10 20 5 17X0.17092X12.991 Z10 20 1 18X0.083016X4.4334 Z10 20 2 18X0.11381X7.0619 Z10 20 3 18X0.1335X9.2019 Z10 20 4 18X0.14905X11.144 Z10 20 5 18X0.16188X12.956 Z10 20 1 19X0.078953X4.4276 Z10 20 2 19X0.10816X7.0489 Z10 20 3 19X0.12691X9.1836 Z10 20 4 19X0.14175X11.12 Z10 20 5 19X0.15394X12.931 Z10 20 1 20X0.075219X4.4222 Z10 20 2 20X0.10294X7.033 Z10 20 3 20X0.12088X9.1672 Z10 20 4 20X0.13494X11.1 Z10 20 5 20X0.14661X12.907 Z10 20 1 21X0.071906X4.4194 Z10 20 2 21X0.098336X7.0239 Z10 20 3 21X0.11536X9.1501 Z10 20 4 21X0.12881X11.08 Z10 20 5 21X0.14005X12.887 Z10 20 1 22X0.068828X4.4153 Z10 20 2 22X0.09407X7.0161 Z10 20 3 22X0.1104X9.135 Z10 20 4 22X0.12328X11.062 Z10 20 5 22X0.134X12.866 Z10 20 1 23X0.066X4.4101 Z10 20 2 23X0.090188X7.0069 Z10 20 3 23X0.10583X9.1227 Z10 20 4 23X0.11813X11.044 Z10 20 5 23X0.12852X12.847 Z10 20 1 24X0.063414X4.4073 Z10 20 2 24X0.086625X6.9993 Z10 20 3 24X0.10167X9.1098 Z10 20 4 24X0.11353X11.033 Z10 20 5 24X0.12353X12.834 Z10 20 1 25X0.061008X4.4029 Z10 20 2 25X0.083313X6.9917 Z10 20 3 25X0.097844X9.1013 Z10 20 4 25X0.10923X11.019 Z10 20 5 25X0.11888X12.819 Z10 20 1 26X0.058805X4.3995 Z10 20 2 26X0.08025X6.9846 Z10 20 3 26X0.094227X9.0918 Z10 20 4 26X0.10524X11.008 Z10 20 5 26X0.11451X12.8 Z10 20 1 27X0.056773X4.3985 Z10 20 2 27X0.077414X6.9792 Z10 20 3 27X0.090891X9.0814 Z10 20 4 27X0.10153X10.998 Z10 20 5 27X0.1105X12.789 Z10 20 1 28X0.054875X4.3972 Z10 20 2 28X0.074758X6.9725 Z10 20 3 28X0.08777X9.074 Z10 20 4 28X0.098086X10.988 Z10 20 5 28X0.10669X12.775 Z10 20 1 29X0.053086X4.3953 Z10 20 2 29X0.072262X6.965 Z10 20 3 29X0.084828X9.0652 Z10 20 4 29X0.09482X10.977 Z10 20 5 29X0.1032X12.763 Z10 20 1 30X0.051422X4.3925 Z10 20 2 30X0.069961X6.9591 Z10 20 3 30X0.082121X9.057 Z10 20 4 30X0.091844X10.967 Z10 20 5 30X0.099977X12.755 Z10 20 1 31X0.049828X4.3914 Z10 20 2 31X0.067813X6.9553 Z10 20 3 31X0.079586X9.0517 Z10 20 4 31X0.088984X10.958 Z10 20 5 31X0.096906X12.744 Z10 20 1 32X0.048344X4.39 Z10 20 2 32X0.065719X6.9485 Z10 20 3 32X0.077195X9.0468 Z10 20 4 32X0.086313X10.948 Z10 20 5 32X0.094063X12.735 Z10 20 1 33X0.046969X4.3883 Z10 20 2 33X0.06382X6.9454 Z10 20 3 33X0.074906X9.0388 Z10 20 4 33X0.083781X10.94 Z10 20 5 33X0.091313X12.727 Z10 20 1 34X0.045641X4.3864 Z10 20 2 34X0.062X6.9405 Z10 20 3 34X0.072773X9.0327 Z10 20 4 34X0.081426X10.932 Z10 20 5 34X0.088734X12.719 Z10 20 1 35X0.044406X4.385 Z10 20 2 35X0.060313X6.9391 Z10 20 3 35X0.070789X9.0269 Z10 20 4 35X0.079172X10.926 Z10 20 5 35X0.08625X12.708 Z10 20 1 36X0.043242X4.3834 Z10 20 2 36X0.058711X6.9355 Z10 20 3 36X0.068891X9.0242 Z10 20 4 36X0.077078X10.919 Z10 20 5 36X0.083922X12.699 Z10 20 1 37X0.042125X4.3824 Z10 20 2 37X0.057172X6.9334 Z10 20 3 37X0.067086X9.0182 Z10 20 4 37X0.075055X10.912 Z10 20 5 37X0.08175X12.689 Z10 20 1 38X0.041051X4.3817 Z10 20 2 38X0.055727X6.9281 Z10 20 3 38X0.065406X9.0156 Z10 20 4 38X0.073164X10.908 Z10 20 5 38X0.079734X12.686 Z10 20 1 39X0.040043X4.3806 Z10 20 2 39X0.054352X6.9243 Z10 20 3 39X0.063781X9.0108 Z10 20 4 39X0.071375X10.903 Z10 20 5 39X0.07775X12.678 Z10 20 1 40X0.039086X4.3797 Z10 20 2 40X0.053063X6.9214 Z10 20 3 40X0.062227X9.0067 Z10 20 4 40X0.069672X10.899 Z10 20 5 40X0.075859X12.671 Z10 20 1 41X0.038156X4.3786 Z10 20 2 41X0.051773X6.9185 Z10 20 3 41X0.060758X9.0041 Z10 20 4 41X0.068031X10.892 Z10 20 5 41X0.074094X12.667 Z10 20 1 42X0.037293X4.378 Z10 20 2 42X0.050566X6.9172 Z10 20 3 42X0.059375X9.0003 Z10 20 4 42X0.066484X10.888 Z10 20 5 42X0.072406X12.662 Z10 20 1 43X0.0365X4.3787 Z10 20 2 43X0.049438X6.9147 Z10 20 3 43X0.058X8.9965 Z10 20 4 43X0.06498X10.882 Z10 20 5 43X0.070813X12.66 Z10 20 1 44X0.035672X4.3783 Z10 20 2 44X0.048328X6.9114 Z10 20 3 44X0.056734X8.9941 Z10 20 4 44X0.063531X10.876 Z10 20 5 44X0.069219X12.652 Z10 20 1 45X0.034891X4.3767 Z10 20 2 45X0.047254X6.9066 Z10 20 3 45X0.05552X8.9922 Z10 20 4 45X0.062195X10.873 Z10 20 5 45X0.067766X12.649 Z10 20 1 46X0.034176X4.3756 Z10 20 2 46X0.04625X6.9047 Z10 20 3 46X0.054336X8.9892 Z10 20 4 46X0.060867X10.867 Z10 20 5 46X0.066313X12.643 Z10 20 1 47X0.033469X4.376 Z10 20 2 47X0.045313X6.9055 Z10 20 3 47X0.053242X8.985 Z10 20 4 47X0.059625X10.865 Z10 20 5 47X0.064969X12.638 Z10 20 1 48X0.032813X4.3757 Z10 20 2 48X0.044398X6.9014 Z10 20 3 48X0.052148X8.9813 Z10 20 4 48X0.058422X10.861 Z10 20 5 48X0.063688X12.634 Z10 20 1 49X0.032156X4.3739 Z10 20 2 49X0.043512X6.8995 Z10 20 3 49X0.051117X8.9797 Z10 20 4 49X0.05725X10.856 Z10 20 5 49X0.062406X12.63 Z10 20 1 50X0.031535X4.3731 Z10 20 2 50X0.042703X6.9011 Z10 20 3 50X0.050113X8.9753 Z10 20 4 50X0.056148X10.855 Z10 20 5 50X0.061203X12.625 "

		 needle = sprintf("Z%g %g %g %gX([\.0-9]+)X([\.0-9]+)",100-alpha, gamma, nendog - nsendog, nexexog) 
		 regexm_result = regexm(o, needle) 
		 st_numscalar("r(a_min)",strtoreal(regexs(1)))
		 st_numscalar("r(lc_crit)",strtoreal(regexs(2)))

		 needle = sprintf("Z%g %g %g %gX([\.0-9]+)X([\.0-9]+)", 100-alpha,gamma, 1, nexexog) 
		 regexm_result = regexm(o, needle) 
		 st_numscalar("r(a_min_p)",strtoreal(regexs(1)))
		 st_numscalar("r(lc_crit_p)",strtoreal(regexs(2)))

		}
}
end

mata:
// Define the crit_obj function
real scalar crit_obj(real scalar a, /// 
			real matrix K_size, ///
			real matrix J_size, ///
			real scalar target_quant, ///
			real scalar alpha, ///
			real scalar gamma_min
			)
{

	K_J = (1+a)*K_size+a*J_size

	crit_quant=mm_quantile(K_J, 1, 1-alpha-gamma_min)
	
	crit_obj=abs(target_quant-crit_quant)

	return(crit_obj)
}

// Minimize the crit_obj function
void eval_crit_obj(todo, a, K_size, J_size, target_quant, alpha, gamma_min, ///
			d, g, H)
{
	d = crit_obj(a, K_size, J_size, target_quant, alpha, gamma_min)
}

real matrix simulate_a_min(
			real matrix K_size, ///
			real matrix J_size, ///
			real scalar target_quant, ///
			real scalar alpha, ///
			real scalar gamma_min ///

)
{
	S = optimize_init() 
	optimize_init_evaluator(S, &eval_crit_obj()) 
	optimize_init_which(S, "min")
	optimize_init_params(S, 0)
	// We can only pass 5 parameters into the objective function
	optimize_init_argument(S,1,K_size)
	optimize_init_argument(S,2,J_size)
	optimize_init_argument(S,3,target_quant)
	optimize_init_argument(S,4,alpha)
	optimize_init_argument(S,5,gamma_min)
	// Specify the objective function has no derivative
	optimize_init_evaluatortype(S, "d0")
	// Use the Nelder-Mead method as Matlab's fminsearch
	optimize_init_technique(S, "nm")
	optimize_init_trace_value(S, "off")		//  turn on/off iteration msg with obj function value

	//default ptol (tolerance) is 1e-6 but we set it to matlab's default
	optimize_init_nmsimplexdeltas(S, 1e-3)
	optimize_init_conv_ptol(S, 1e-4)

	a_min = optimize(S)
	K_J     = (1+a_min)*K_size+a_min*J_size
	lc_crit = mm_quantile(K_J, 1, 1-alpha)
	return((a_min,lc_crit))
}
end

version 11.2
mata:
void compute_tests(												///
							scalar N,							///
							scalar iid,							/// boolean
							scalar lm,							/// boolean, =1 if LM, =0 if Wald
							scalar nendog,						///
							scalar nexexog,						///
							scalar a_min,						/// weight in linear combination  of K_2sls and J
							scalar a_min_p,						/// weight in linear combination of K_2sls and J for projection test statistics p=1
							scalar lc_crit,					/// dont need lc_crit in computing test stat
							scalar lc_crit_p,					/// dont need lc_crit in computing test stat for projection test
							string scalar gridcols,				///
							string scalar del_z_name,			/// row vector
							string scalar var_del_name,			///
							string scalar pi_z_name,			///
							string scalar var_pi_z_name,		///
							string scalar zzinv_name,			///
							string scalar var_pidel_z_name,		///
							string scalar del_v_name,			/// row vector
							string scalar wnullvector_name,		/// row vector
							string scalar nullvector_name,		/// row vector; first weak, then strong (if any)
							|									/// optional args start here
							string scalar syy_name,				/// actually scalar
							string scalar see_name,				/// actually scalar
							string scalar sxy_name,				///
							string scalar sve_name,				///
							string scalar sxx_name,				///
							string scalar svv_name				///
							)
{
timer_on(1)

		npd				=0										//  initialize

		del_z			=st_matrix(del_z_name)					//  row vector
		var_del			=st_matrix(var_del_name)
		pi_z			=st_matrix(pi_z_name)
		var_pi_z		=st_matrix(var_pi_z_name)
		zzinv			=st_matrix(zzinv_name)					
		var_pidel_z		=st_matrix(var_pidel_z_name)
		del_v			=st_matrix(del_v_name)					//  row vector
		nullvector		=st_matrix(nullvector_name)				//  row vector
		wnullvector		=st_matrix(wnullvector_name)			//  row vector

// Use to get LM stats in iid case
		//if (iid & lm) {
		//	syy				=st_matrix(syy_name)					//  scalar
		//	see				=st_matrix(see_name)					//  scalar
		//	sxy				=st_matrix(sxy_name)					//  COLUMN VECTOR
		//	sve				=st_matrix(sve_name)					//  COLUMN VECTOR
		//	sxx				=st_matrix(sxx_name)					//  KxK matrix 
		//	svv				=st_matrix(svv_name)					//  KxK matrix
		// }
// Change to column vectors
		del_z			=del_z'
		del_v			=del_v'
		nullvector		=nullvector'
		wnullvector		=wnullvector'

		r = del_z - pi_z*nullvector

// Assemble psi
		//if (iid) {
		//	kron		= (del_v - nullvector)#I(nexexog)
		//	psi			= var_del + kron' * var_pi_z * kron
		//	_makesymmetric(psi)
		//	psi_inv		= invsym(psi)
		//	bracket		= var_pi_z*kron
		//	shat		= var_pi_z - bracket*psi_inv*bracket'
		// }
		//else {
			kron		= (nullvector#I(nexexog))

			psi			= var_del - kron'*var_pidel_z - (kron'*var_pidel_z)' + kron' * var_pi_z * kron

			_makesymmetric(psi)
			psi_inv		= invsym(psi)
			bracket		= var_pidel_z - var_pi_z*kron
			shat		= var_pi_z - bracket*psi_inv*bracket'
		// }
		_makesymmetric(shat)

		aux1 = cholsolve(psi,r)
		if (aux1[1,1]==.) {
			npd = 1
			aux1 = qrsolve(psi,r)
		}
		
		// always calculate ar_chi2 because we need it for J, RK, CLR, LC_2sls, LC
		ar_chi2 = r' * aux1 
		
		st_numscalar("r(ar_chi2)", ar_chi2[1,1])
		if (strpos(gridcols, " k_p")|strpos(gridcols, "j_p")|strpos(gridcols, "lc")) {			
			//if (iid) {								//  iid
			//	aux0 = psi_inv * r * (del_v - nullvector)'
			//	vec_pi_beta = -vec(pi_z) + var_pi_z*vec(aux0)
			//}
			//else {									//  robust
				aux0 = var_pidel_z - var_pi_z*kron
				vec_pi_beta = -vec(pi_z) + aux0*psi_inv*r
			// }

						

			pi_beta=J(nexexog,0,.)					//  un-vec pi_beta
			for (i=1; i<=nendog; i++) {
				r1=(i-1)*nexexog+1
				r2=(i)  *nexexog
				pi_beta = pi_beta , vec_pi_beta[r1..r2,1]
			}
		}
		// k_chi2 stat is used in LC and K (full and projection), J and CLR
		if (strpos(gridcols, "lc_r")|strpos(gridcols, "lcp")|strpos(gridcols, " k_p")|strpos(gridcols, " kp")|strpos(gridcols, "j_p")|strpos(gridcols, "clr_stat")){
			aux5 = cholsolve(psi,pi_beta)

			if (aux5[1,1]==.) {
				npd = 1
				aux5 = qrsolve(psi,pi_beta)
			}
			aux6 = cholsolve(pi_beta'*aux5,pi_beta')

			if (aux6[1,1]==.) {
				npd = 1
				aux6 = qrsolve(pi_beta'*aux5,pi_beta')
			}

			k_chi2 = r' * aux5 * aux6 * aux1
			if (k_chi2[1,1]<0) {								//  can happen if matrices are npd
				k_chi2[1,1]=.
			}
			
			if (strpos(gridcols, " k_p")) {
				st_numscalar("r(k_chi2)", k_chi2[1,1])
			}
			if (strpos(gridcols, "j_p")) {
				j_chi2 = ar_chi2 - k_chi2
				st_numscalar("r(j_chi2)", j_chi2[1,1])
			}
		}


		if (strpos(gridcols, "rk_p") | strpos(gridcols, "clr_stat")) {
			rpsi_inv	= cholesky(psi_inv)						//  inv sqrt of psi
		//  Rank statistic of Kleibergen-Paap
			rk			= rk_kp(	pi_beta,					/// =D in alt. notation, dim nexexog x nendog (LxK)
									I(nendog),					///
									rpsi_inv,					/// = (V_ff)^(-1/2) = inv sqrt of V_ff in alt. notation
									shat,						/// = V_thetatheta_f = var(vec(D)) in alt. notation
									nendog-1					/// test that matrix is not full rank
									)
			if (rk[1,1]<=0) {
				clr_stat=.
				rk=.
			}
			
			if (strpos(gridcols, "rk_p")) {
				st_numscalar("r(rk)", rk[1,1])
			}
			if (strpos(gridcols, "clr_stat")) {
				clr_stat = .5*(ar_chi2-rk+sqrt((ar_chi2+rk)^2 - 4*j_chi2*rk))
				st_numscalar("r(clr_stat)", clr_stat[1,1])
			}

		}
// Need to disable LM to match with MD result
// LM versions of AR, K and J are just rescalings of MD/Wald versions
// CLR does not change.
		//if (iid & lm) {
		//printf ("HERE causes iid error")// try disable this adjustment since we switch to MD for iid case as well
		//	s2lm		= syy - 2*nullvector'*sxy + nullvector'*sxx*nullvector
		//	s2			= see - 2*nullvector'*sve + nullvector'*svv*nullvector
		//	ar_chi2		= ar_chi2 * s2/s2lm
		//	k_chi2		= k_chi2  * s2/s2lm
		//	j_chi2		= ar_chi2 - k_chi2
		//printf("HERE")	
		//}

// Calculate LC_2sls, which needs K with 2sls weight statistics
		if (strpos(gridcols, "lc_2sls")) {
			zz			=invsym(zzinv)
			aux4 = pi_beta'*zz*psi*zz*pi_beta // d'*w*sigma_r*w*d
			dwd			=invsym(pi_beta'*zz* pi_beta)
			bread 			=r'*zz* pi_beta *dwd
			meat			= dwd *aux4 * dwd


		}

		if (strpos(gridcols, "lc_2sls_r")|strpos(gridcols, "k_2sls_r")) {

// See documentation on what meat and bread are
			aux7 = cholsolve(meat,bread')
			if (aux7[1,1]==.) {
				npd = 1
				aux7 = qrsolve(meat,bread')
			}


			// Store k_2sls (K stat with 2sls in place of efficient weight matrix
			k_2sls			= bread * aux7
			// Calculate the linear combination test statistic
			lc_2sls			= k_2sls + a_min*ar_chi2
			//printf("lc_2sls and k_2sls are")
			//lc_2sls
			//k_2sls
			st_numscalar("r(k_2sls)",k_2sls[1,1])
			st_numscalar("r(lc_2sls)",lc_2sls[1,1])
		}

		if (strpos(gridcols, "lc_2slsp")| strpos(gridcols, "k_2slsp")) {
			// Calculate projection test statistic
			// endog first weak, then strong endog
			nwendog			=rows(wnullvector) // wnullvector is column vector of weakly-identified endog null
			k_2slsp = J(1, nwendog,0)
			lc_2slsp = J(1, nwendog,0)
			for (i=1; i<=nwendog; i++) {
				k_2slsp[1,i]=(1/meat[i,i])*bread[1,i]*bread[1,i]
				lc_2slsp[1,i]= k_2slsp[1,i] + a_min_p*ar_chi2
			}
			//printf("lc_2slsp and k_2slsp and ar_chi2 are")

			st_matrix("r(lc_2slsp)", lc_2slsp)
			st_matrix("r(k_2slsp)", k_2slsp)
		}
// Calculate LC, which needs K statistics
		if (strpos(gridcols, "lc_r")) {
			// Calculate the linear combination test statistic
			lc			= k_chi2 + a_min*ar_chi2
			//printf("lc and k_chi2 are")
			//lc
			//k_chi2
			st_numscalar("r(k_chi2)", k_chi2[1,1])
			st_numscalar("r(lc)",lc[1,1])
		}
		if (strpos(gridcols, "lcp")|strpos(gridcols, "kp")) {
			// Calculate projection test statistic
			dwd				=invsym(pi_beta'*aux5)
			bread 			=r'*aux5 *dwd
	// endog first weak, then strong endog
			nwendog			=rows(wnullvector) // wnullvector is column vector of weakly-identified endog null
			k_chi2p = J(1, nwendog,0)
			lcp = J(1, nwendog,0)
			for (i=1; i<=nwendog; i++) {
				k_chi2p[1,i]=(1/dwd[i,i])*bread[1,i]*bread[1,i]
				lcp[1,i]= k_chi2p[1,i] + a_min_p*ar_chi2
			}
			//printf("lcp and k_chi2p and ar_chi2 are")
			st_matrix("r(lcp)", lcp)
			st_matrix("r(k_chi2p)", k_chi2p)
		}
		
		st_numscalar("r(npd)", npd)

timer_off(1)

}
end		//  end compute_tests


program get_strong_beta, rclass
	syntax [,							///
				iv						///
				md2s					///
				liml					///
				cue						///
				varflag					/// flag for whether need VCV for point estimates
				lm(real 0)				///
				nobs(real 0)			///
				b0(name local)			/// null vector (Stata matrix)
				sbeta(name local)		/// optional, provided as 1st-step estimator for 2-step GMM etc.
				iv_sbeta0(name local)	/// if omitted, will need to calc IV coeffs
				pi2hat(name local)		/// if omitted, will need to calc IV coeffs
				zz(name local)			///
				x1x1(name local)		///
				x1x2(name local)		///
				x2x2(name local)		///
				zx1(name local)			///
				zx2(name local)			///
				x1y(name local)			///
				x2y(name local)			///
				zy(name local)			///
				yy(name local)			///
				depvar(varname)			/// following used for 2-step GMM
				wendo(varlist)			///
				sendo(varlist)			///
				exexog(varlist)			///
				touse(varname)			///
				vceopt(string)			///
				wtexp(string)			///
				wvar(varname)			///
				wf(real 1)				///
				traceonoff(string)      ///			
			]

	tempname S npd
	tempvar y0 ehat var_beta 
//dis "iv `iv' md2s `md2s' liml `liml' cue `cue'"
local varflag = "`varflag'"~="" // it looks like varflag is only for 2sls beta, otw y0 is generated twice in this program
	if `varflag' & "`liml'`md2s'`cue'"==""{

		tempname pi_z bhat uhat  del_z var_pi_z var_del var_pidel_z // take out zz and zzinv tempname because program syntax specifies in shared tempnames
		tempname S S11 S12 S22 

		qui gen double `y0' = `depvar' if `touse'			//  calc y0 = y at hypoth null; also used by CUE
		local i=1
		if "`wendo'"~= "" { // if wendo == "", then using get_strong_beta for all endo
			foreach var of varlist `wendo' {
				qui replace `y0' = `y0' - `b0'[1,`i']*`var'
				local ++i
			}
		}
		local nexexog : word count `exexog'
		local nendog : word count `sendo'

		computematrices_robust,						///
			touse(`touse')							///
			wtexp(`wtexp')							///
			vceopt(`vceopt')						///
			depvar(`y0')						///
			endo(`sendo')		/// 
			exexog(`exexog')						///
			nendog(`nendog')						///
			nexexog(`nexexog')						///
			npartial(0)					/// #inexog partialled-out (but not used in this program)
			nobs(`nobs')					///
			dofminus(0)					///
			ssa(1)								/// small-sample adjustment
			lm(0)

		mat `del_z'			= r(del_z)
		mat `var_pi_z'		= r(var_pi_z)
		mat `pi_z'			= r(pi_z)
		mat `var_del'		= r(var_del)
		mat `var_pidel_z'	= r(var_pidel_z)
			
	}
*************** ONE-STEP ESTIMATORS: LIML, IV **********************
	if "`iv'"~="" {
		tempname sbeta
		local calcflag		= ("`iv_sbeta0'"=="")	//  flag=0 => need to calculate iv_sbeta0 & pi2hat

		mata: s_iv_beta(							///
								`nobs',				///
								"`zz'",				///
								"`x1x2'",			///
								"`zx1'",			///
								"`zx2'",			///
								"`zy'",				///
								`calcflag',			/// flag to say will need to calculate iv_sbeta0 and pi2hat
								"`b0'",				/// rowvector
								"`iv_sbeta0'",		/// rowvector
								"`pi2hat'"			/// matrix
						)

		if `calcflag' {
			tempname iv_sbeta0 pi2hat
			mat `iv_sbeta0'			= r(iv_sbeta0)					//  col vector (Mata convention)
			mat `iv_sbeta0'			= `iv_sbeta0''					//  row vector (Stata convention)
			return mat iv_sbeta0	= `iv_sbeta0'					//  return strong IV beta at null=0 for later use
			mat `pi2hat'			= r(pi2hat)
			mat `pi2hat'			= `pi2hat''						//  also transpose (Stata convention)
			return mat pi2hat		= `pi2hat'						//  return RF matrix for later use
		}
		mat `sbeta'				= r(beta)							//  col vector (Mata convention)
							//  strong IV beta at specified null
		
		mat `sbeta'				= `sbeta''	//  row vector (Stata convention)
		return mat sbeta		= `sbeta'	
		scalar `npd'			= r(npd)
		return scalar npd	= `npd'
		
		if "`varflag'"=="1" & "`liml'`md2s'`cue'"=="" {
		tempname beta del_z var_del pi_Z var_pi_z var_pidel_z zz_copy kron psi aux1 aux2 var_beta // cannot reuse zz as tempname
			// also need to calculate variance for 2sls beta
			mata: `beta'		=st_matrix("r(beta)")
			mata: `del_z'		=st_matrix("r(del_z)")				//  row vector
			mata: `var_del'		=st_matrix("r(var_del)")
			mata: `pi_z'			=st_matrix("r(pi_z)")
			mata: `var_pi_z'		=st_matrix("r(var_pi_z)")
			mata: `var_pidel_z'	=st_matrix("r(var_pidel_z)")
			

			mata: `zz_copy'		= st_matrix("`zz'")
			mata: `kron'		= (`beta'#I(`nexexog'))
			//mata: kron
			//mata: var_del
			mata: `psi'		= `var_del' - `kron'' * `var_pidel_z' - (`kron'' * `var_pidel_z')' ///
						+ `kron'' * `var_pi_z'* `kron'
			
			mata: _makesymmetric(`psi')

			mata: `aux1'		= `psi' * `zz_copy'
			mata: `aux2'		= invsym(`pi_z'' * `zz_copy' * `pi_z')
			mata: `var_beta'	= `aux2' * `pi_z'' * `zz_copy' * `aux1' * `pi_z' * `aux2'

			mata: st_matrix("r(var_beta)", `var_beta')
			mata: mata drop `beta' `del_z' `var_del' `pi_z' `var_pi_z' `var_pidel_z' `zz_copy' `kron' `psi' `aux1' `aux2' `var_beta'

		mat `var_beta'				= r(var_beta)
		return mat var_beta			= `var_beta'
		}
	}	//  end calc of strong IV beta
* All LIML, 2step and CUE need y0 = y - b0*x1 = y at hypoth null
* and ehat = y0 - sbeta*x2 = resids from inefficient IV sbeta

	if "`liml'`md2s'`cue'"~="" {	
		tempname pi_z bhat uhat zz zzinv del_z var_pi_z var_del var_pidel_z
		tempname S S11 S12 S22
		
		qui gen double `y0' = `depvar' if `touse'			//  calc y0 = y at hypoth null; also used by CUE
		if "`wendo'"~= "" { // if wendo == "", then using get_strong_beta for all endo
			local i=1
			foreach var of varlist `wendo' {
				qui replace `y0' = `y0' - `b0'[1,`i']*`var'
				local ++i
			}
		}
		local nexexog : word count `exexog'
		local nendog : word count `sendo'
	
	}
	
	if "`liml'"~="" { // changing to MD CUE criterion function
		computematrices_robust,						///
			touse(`touse')							///
			wtexp(`wtexp')							///
			vceopt("")						/// Use VCV estimators under homoskedastic assumption for CUE criterion
			depvar(`y0')						///
			endo(`sendo')		/// 
			exexog(`exexog')						///
			nendog(`nendog')						///
			nexexog(`nexexog')						///
			npartial(0)					/// #inexog partialled-out (but not used in this program)
			nobs(`nobs')					///
			dofminus(0)					///
			ssa(1)								/// small-sample adjustment
			lm(0)

		mat `del_z'			= r(del_z)
		mat `var_pi_z'		= r(var_pi_z)
		mat `pi_z'			= r(pi_z)
		mat `var_del'		= r(var_del)
		mat `var_pidel_z'	= r(var_pidel_z)
//use CUE-MD for LIML so also need sbeta"

		mata: s_cue_beta(							///
								`nobs',				///
								`nexexog',		/// number of instruments
								"`del_z'",		/// row vector
								"`var_del'",		///
								"`pi_z'",		///
								"`var_pi_z'",		///
								"`var_pidel_z'",		///
								"`touse'",			///
								"`sbeta'",			/// 1st-step sbeta is provided to get_strong_beta
								"`traceonoff'"				///	suppress trace log in optimizatin for cuestrong						
						)
		mat `sbeta'			= r(beta)								//  strong IV beta at specified null
		mat `sbeta'			= `sbeta''								//  row vector (Stata convention)
		return mat sbeta	= `sbeta'
		if "`varflag'"~= "" {
			tempname beta del_z var_del pi_Z var_pi_z var_pidel_z zz_copy kron psi aux1 aux2 var_beta // cannot reuse zz as tempname

			mata: `beta'		=st_matrix("r(beta)")
			mata: `del_z'		=st_matrix("r(del_z)")				//  row vector
			mata: `var_del'		=st_matrix("r(var_del)")
			mata: `pi_z'			=st_matrix("r(pi_z)")
			mata: `var_pi_z'		=st_matrix("r(var_pi_z)")
			mata: `var_pidel_z'	=st_matrix("r(var_pidel_z)")
 
			//mata: zzinv		= st_matrix("r(zzinv)")
			mata: `zz_copy'		= invsym(st_matrix("r(zzinv)"))
			mata: `kron'		= (`beta'#I(`nexexog'))
			mata: `psi'		= `var_del' - `kron'' * `var_pidel_z' - (`kron'' * `var_pidel_z')' ///
						+ `kron'' * `var_pi_z'* `kron'
			
			mata: _makesymmetric(`psi')
			mata: `aux1'		= `psi' * `zz_copy'
			mata: `aux2'		= invsym(`pi_z'' * `zz_copy' * `pi_z')
			mata: `var_beta'	= `aux2' * `pi_z'' * `zz_copy' * `aux1' * `pi_z' * `aux2'
			mata: st_matrix("r(var_beta)", `var_beta')
			mata: mata drop `beta' `del_z' `var_del' `pi_z' `var_pi_z' `var_pidel_z' `zz_copy' `kron' `psi' `aux1' `aux2' `var_beta'

					mat `var_beta'				= r(var_beta)
					return mat var_beta			= `var_beta'				// VCV for LIML beta - only calculated when LIML point estimates are specified
		}
		scalar `npd'		= r(npd)
		return scalar npd	= `npd'

	}



*************** TWO-STEP ESTIMATORS: 2-STEP GMM, CUE **********************

* Both need y0 = y - b0*x1 = y at hypoth null
* and ehat = y0 - sbeta*x2 = resids from inefficient IV sbeta

	if "`md2s'`cue'"~="" {
		computematrices_robust,						///
			touse(`touse')							///
			wtexp(`wtexp')							///
			vceopt(`vceopt')						///
			depvar(`y0')						///
			endo(`sendo')		/// 
			exexog(`exexog')						///
			nendog(`nendog')						///
			nexexog(`nexexog')						///
			npartial(0)					/// #inexog partialled-out (but not used in this program)
			nobs(`nobs')					///
			dofminus(0)					///
			ssa(1)								/// small-sample adjustment
			lm(0)

		mat `del_z'			= r(del_z)
		mat `var_pi_z'		= r(var_pi_z)
		mat `pi_z'			= r(pi_z)
		mat `var_del'		= r(var_del)
		mat `var_pidel_z'	= r(var_pidel_z)

	}
	if "`md2s'"~="" {									// 2-step MD estimation
	local calcvarflag = "`varflag'"~= ""
		mata: s_md2s_beta(							///
								`nobs',			///
								`nexexog',		/// number of instruments
								"`sbeta'",		/// initial inefficient 1st-step sbeta is provided
								"`del_z'",		/// row vector
								"`var_del'",		///
								"`pi_z'",		///
								"`var_pi_z'",		///
								"`var_pidel_z'", 	///
								`calcvarflag'		/// turn off flag for calculating VCV
						)
		mat `sbeta'			= r(beta)
		mat `sbeta'			= `sbeta''										//  row vector (Stata convention)
		return mat sbeta	= `sbeta'										//  strong 2-step MD beta at specified null
		if "`varflag'"~= "" {
					mat `var_beta'				= r(var_beta)
					return mat var_beta			= `var_beta'				// VCV not needed in strong, VCV is calculated when  point estimates are specified
		}
		scalar `npd'		= r(npd)
		return scalar npd	= `npd'

	}	// end calc of strong 2-step GMM beta

	
	if "`cue'"~="" {							//  CUE estimation
										//  note 1st-step sbeta is provide
//dis "changed s_cue_beta to MD version"
		mata: s_cue_beta(							///
								`nobs',				///
								`nexexog',		/// number of instruments
								"`del_z'",		/// row vector
								"`var_del'",		///
								"`pi_z'",		///
								"`var_pi_z'",		///
								"`var_pidel_z'",		///
								"`touse'",			///
								"`sbeta'",			/// 1st-step sbeta is provided to get_strong_beta
								"`traceonoff'"				///	suppress trace log in optimizatin for cuestrong						
						)
		mat `sbeta'			= r(beta)
		mat `sbeta'			= `sbeta''					//  row vector (Stata convention)
		return mat sbeta	= `sbeta'					//  strong CUE beta at specified null
		if "`varflag'"~= "" {
					mat `var_beta'				= r(var_beta)
					return mat var_beta			= `var_beta'				// VCV for CUE beta - not needed in cuestrong, VCV for CUE is calculated when cue point estimates are specified
		}
		scalar `npd'		= r(npd)
		return scalar npd	= `npd'

	}	// end calc of strong CUE beta

end			//  end get_strong_beta


version 11.2
mata:
void s_md2s_beta(										///
						scalar N,						///
						scalar nexexog,						///
						string scalar sbeta_name,		///
						string scalar del_z_name,			/// row vector
						string scalar var_del_name,			///
						string scalar pi_z_name,			///
						string scalar var_pi_z_name,		///
						string scalar var_pidel_z_name,		///
						scalar calcvarflag		///
				)
{

	npd			= 0

	iv_sbeta		= st_matrix(sbeta_name)				// row vector of initial estimates
	del_z			=st_matrix(del_z_name)				//  row vector
	var_del			=st_matrix(var_del_name)
	pi_z			=st_matrix(pi_z_name)
	var_pi_z		=st_matrix(var_pi_z_name)
	var_pidel_z		=st_matrix(var_pidel_z_name)
	
	// MD version

	kron		= (iv_sbeta'#I(nexexog))
	psi		= var_del - kron' * var_pidel_z - (kron' * var_pidel_z)' + kron' * var_pi_z* kron
	_makesymmetric(psi)

	aux1		= pi_z'*psi*pi_z
	aux2		= pi_z'*psi*del_z'
	beta		= cholsolve(aux1,aux2) // closed-form solution for MD2s
	if (beta[1,1]==.) {
		beta	= qrsolve(aux1, aux2)
		npd = 1
	}
	if (calcvarflag) { // calculating VCV -  formula with efficient weight
		//aux3 = pi_z'*psi
		//aux4 = cholsolve(aux1, aux3)
		//if (aux4[1,1]==.) {
		//	aux4 = qrsolve(aux1,aux3)
		//	npd = 1
		//}
		kron2s = (beta#I(nexexog)) // at estimated beta
		psi2s  = var_del - kron2s' * var_pidel_z - (kron2s' * var_pidel_z)' + kron2s' * var_pi_z* kron2s
		//var_beta = aux4*psi2s*aux4'
		aux3 = cholsolve(psi2s, pi_z)
		if (aux3[1,1] == .) {
			aux3 = qrsolve(psi2s, pi_z)
			npd = 1
		}
		var_beta = invsym(pi_z'*aux3)
		//printf("MD2s beta is")
		//printf("variance var_beta is")

		st_matrix("r(var_beta)",var_beta)

	}
	st_numscalar("r(npd)",npd)					//  npd flag is kept in Stata space
	st_matrix("r(beta)",beta)

}
end


version 11.2
mata:
void s_iv_beta(											///
						scalar N,						///
						string scalar ZZ_name,			///
						string scalar X1X2_name,		///
						string scalar ZX1_name,			///
						string scalar ZX2_name,			///
						string scalar Zy_name,			///
						scalar calcflag,				///
						string scalar wnullvector_name,	///
						string scalar iv_sbeta0_name,	///
						string scalar pi2hat_name		///
				)
{
	npd			= 0

	b0			= st_matrix(wnullvector_name)			//  row vector
// Change to column vectors
	b0			= b0'

	if (calcflag) {										//  iv_sbeta0 and pi2hat not provided

		QZZ			= st_matrix(ZZ_name)/N
		QX1X2		= st_matrix(X1X2_name)/N
		QZX1		= st_matrix(ZX1_name)/N
		QZX2		= st_matrix(ZX2_name)/N
		QZy			= st_matrix(Zy_name)/N

		aux1		= cholsolve(QZZ, QZX2)
		if (aux1[1,1]==.) {
			aux1	= qrsolve(QZZ, QZX2)
			npd = 1
		}
		aux2		= makesymmetric(QZX2' * aux1)
		aux3		= cholsolve(QZZ, QZy)
		if (aux3[1,1]==.) {
			aux3	= qrsolve(QZZ, QZy)
			npd = 1
		}
		iv_sbeta0	= cholsolve(aux2, QZX2' * aux3)		//  beta is raw IV beta (null=0)
		if (iv_sbeta0[1,1]==.) {
			iv_sbeta0= qrsolve(aux2, QZX2' * aux3)
			npd = 1
		}
		aux4		= cholsolve(QZZ, QZX1)
		if (aux4[1,1]==.) {
			aux4	= qrsolve(QZZ, QZX1)
			npd = 1
		}
		pi2hat		= cholsolve(aux2, QZX2' * aux4)		//  RF matrix
		if (pi2hat[1,1]==.) {
			pi2hat	= qrsolve(aux2, QZX2' * aux4)
			npd = 1
		}
	}
	else {												//  matrices provided
		iv_sbeta0	= st_matrix(iv_sbeta0_name)			//  row vector (Stata convention)
		iv_sbeta0	= iv_sbeta0'						//  col vector (Mata convention)
		pi2hat		= st_matrix(pi2hat_name)
		pi2hat		= pi2hat'
	}

	beta			= iv_sbeta0 - pi2hat * b0			//  IV estimator at specified null

	st_matrix("r(beta)",beta)
	st_numscalar("r(npd)",npd)

	if (calcflag) {
		st_matrix("r(iv_sbeta0)",iv_sbeta0)
		st_matrix("r(pi2hat)",pi2hat)
	}

}
end

version 11.2
mata:
void s_sliml(											///
						scalar N,						///
						string scalar ZZ_name,			///
						string scalar X1X1_name,		///
						string scalar X1X2_name,		///
						string scalar X2X2_name,		///
						string scalar ZX1_name,			///
						string scalar ZX2_name,			///
						string scalar X1y_name,			///
						string scalar X2y_name,			///
						string scalar Zy_name,			///
						string scalar yy_name,			///
						string scalar wnullvector_name,	///
						scalar L,						///
						scalar betaflag,				/// 0 means return just lambda, 1 means beta as well
						scalar lmflag					///
			)
{	

// flag set to 0, promote to 1 if NPD matrices encountered
	npd			= 0
	
	b0			= st_matrix(wnullvector_name)			//  row vector
// Change to column vectors
	b0			= b0'

// Y = [y X2]
// y0 = y - X1*b0
	QZZ			= st_matrix(ZZ_name)/N
	QX1X1		= st_matrix(X1X1_name)/N
	QX1X2		= st_matrix(X1X2_name)/N
	QX2X2		= st_matrix(X2X2_name)/N
	QZX1		= st_matrix(ZX1_name)/N
	QZX2		= st_matrix(ZX2_name)/N
	QX1y		= st_matrix(X1y_name)/N
	QX2y		= st_matrix(X2y_name)/N
	QZy			= st_matrix(Zy_name)/N
	Qyy			= st_matrix(yy_name)/N
	QYY			= (Qyy , QX2y') \ (QX2y , QX2X2)
	QZY			= (QZy , QZX2)
	QYX1		= (QX1y , QX1X2)'
	JYX2		= J(rows(QYY),cols(QX2X2),0)
	JZX2		= J(rows(QZZ),cols(QX2X2),0)
	QY0Y0		= QYY - (QYX1*b0 , JYX2) - (QYX1*b0 , JYX2)' + diag(b0' * QX1X1 * b0 \ J(rows(QX2X2),1,0))
	QZY0		= QZY - (QZX1*b0, JZX2)
	QZy0		= QZy - QZX1*b0								//  QZy0 at hypoth null where y0 = y - b0*x1
	QX2y0		= QX2y - QX1X2'*b0							//  QX2y0 at hypoth null where y0 = y - b0*x1

	lambda		= m_liml_lambda(QY0Y0, QZY0, QZZ)
	st_numscalar("r(lambda)",lambda)
	npd			= st_numscalar("r(npd)")

// Basmann (LM) = (N-L)*(lambda-1)
// Sargan (Wald) = N*(1-1/lambda)
	if (lmflag) {
		ar_chi2	= (N-L)*(lambda-1)
	}
	else {
		ar_chi2	= N*(1-1/lambda)
	}
	st_numscalar("r(ar_chi2)",ar_chi2)

	if (betaflag) {
		beta		= m_liml_beta(lambda, QZZ, QZy0, QZX2, QX2X2, QX2y0)
		npd			= max((npd,st_numscalar("r(npd)")))
		st_matrix("r(beta)",beta)
		st_numscalar("r(npd)",npd)
	}
}
end

// Simple LIML estimator with no exogenous regressors
version 11.2
mata:
void s_liml(											///
						scalar N,						///
						string scalar ZZ_name,			///
						string scalar XX_name,			///
						string scalar ZX_name,			///
						string scalar Xy_name,			///
						string scalar Zy_name,			///
						string scalar yy_name			///
			)
{	

// flag set to 0, promote to 1 if NPD matrices encountered
	npd			= 0
	

// Y = [y X]
	QZZ			= st_matrix(ZZ_name)/N
	QXX			= st_matrix(XX_name)/N
	QZX			= st_matrix(ZX_name)/N
	QXy			= st_matrix(Xy_name)/N
	QZy			= st_matrix(Zy_name)/N
	Qyy			= st_matrix(yy_name)/N
	QYY			= (Qyy , QXy') \ (QXy , QXX)
	QZY			= (QZy , QZX)

	lambda		= m_liml_lambda(QYY, QZY, QZZ)
	st_numscalar("r(lambda)",lambda)
	npd			= st_numscalar("r(npd)")
	beta		= m_liml_beta(lambda, QZZ, QZy, QZX, QXX, QXy)
	npd			= max((npd,st_numscalar("r(npd)")))
	st_matrix("r(beta)",beta)
	st_numscalar("r(npd)",npd)
}
end

version 11.2
mata:
struct ms_cuestruct {
	real scalar		N, nexexog
	real matrix		del_z, var_del, pi_z, var_pi_z, var_pidel_z
}
end


version 11.2
mata:
void s_cue_beta(										///
						scalar N,					///
						scalar nexexog,						///
						string scalar del_z_name,			/// row vector
						string scalar var_del_name,			///
						string scalar pi_z_name,			///
						string scalar var_pi_z_name,		///
						string scalar var_pidel_z_name,		///
						string scalar touse,			///
						string scalar binit_name,		///
						string scalar traceonoff		///
				)
{

// Declare cuestruct
	struct ms_cuestruct scalar cuestruct

// Scalars
	cuestruct.N	= N
	cuestruct.nexexog	= nexexog
// Matrices
	cuestruct.del_z			=st_matrix(del_z_name)					//  row vector
	cuestruct.var_del		=st_matrix(var_del_name)
	cuestruct.pi_z			=st_matrix(pi_z_name)
	cuestruct.var_pi_z		=st_matrix(var_pi_z_name)
	cuestruct.var_pidel_z		=st_matrix(var_pidel_z_name)	


	beta_init = st_matrix(binit_name)				//  row vector (Stata convention)
									//  and Mata optimize also requires a row vector :(

// First, initialize the optimization structure in the variable S.
// Then tell Mata where the objective function is, that it's a minimization,
// that it's a "d0" type of objective function (no analytical derivatives or Hessians),
// and that the initial values for the parameter vector are in beta_init.
// Finally, optimize.
	S = optimize_init()

	optimize_init_evaluator(S, &m_cuecrit())
	optimize_init_which(S, "min")
	optimize_init_evaluatortype(S, "d0")
	optimize_init_params(S, beta_init)
	optimize_init_trace_value(S, traceonoff)		//  turn on/off iteration msg with obj function value
// CUE objective function takes extra arguments:
	optimize_init_argument(S, 1, cuestruct)
// Change maximum iterations
	//optimize_init_conv_maxiter(S, 10000)

	beta = optimize(S)								//  row vector
	beta = beta'									//  col vector

	st_matrix("r(beta)", beta)
	// calculate CUE VCV
	kron		= (beta#I(cuestruct.nexexog))
	psi		= cuestruct.var_del - kron' * cuestruct.var_pidel_z - (kron' * cuestruct.var_pidel_z)' ///
			+ kron' * cuestruct.var_pi_z* kron
	_makesymmetric(psi)
	aux1		= cholsolve(psi,cuestruct.pi_z)
	if (aux1[1,1]==.) {
		aux1 = qrsolve(psi,cuestruct.pi_z)
		st_numscalar("r(npd)",1)
	}
	var_beta	= invsym(cuestruct.pi_z' * aux1)

	st_matrix("r(var_beta)", var_beta)
	
}
end

version 11.2
mata:
void m_cuecrit(todo, beta, struct ms_cuestruct scalar cuestruct, j, g, H)
{
	kron		= (beta'#I(cuestruct.nexexog))
	psi		= cuestruct.var_del - kron' * cuestruct.var_pidel_z - (kron' * cuestruct.var_pidel_z)' ///
			+ kron' * cuestruct.var_pi_z* kron
	_makesymmetric(psi)
	
	rhat		= cuestruct.del_z'-cuestruct.pi_z * beta'

	aux1 = cholsolve(psi,rhat)
	if (aux1[1,1]==.) {
		aux1 = qrsolve(psi,rhat)
		st_numscalar("r(npd)",1)
	}
	j = cuestruct.N * rhat' * aux1

} // end program CUE criterion function
end


version 11.2
mata:
real scalar m_liml_lambda(						///
							real matrix QYY,	///
							real matrix QZY,	///
							real matrix QZZ		///
							)
{
	npd			= 0
	QWW			= QYY - QZY'*cholsolve(QZZ,QZY)
	if (QWW[1,1]==.) {
		QWW		= QYY - QZY'*qrsolve(QZZ,QZY)
		npd		= 1
	}
	_makesymmetric(QWW)

	M			= matpowersym(QWW, -0.5)
	Eval		= symeigenvalues(M*QYY*M)
	lambda		= rowmin(Eval)

	st_numscalar("r(npd)",npd)					//  npd flag is kept in Stata space
	return(lambda)

}
end

version 11.2
mata:
real matrix m_liml_beta(						///
							real scalar lambda,	///
							real matrix QZZ,	///
							real matrix QZy,	///
							real matrix QZX2,	///
							real matrix QX2X2,	///
							real matrix QX2y	///
							)
{
	npd			= 0
	aux1		= cholsolve(QZZ,QZX2)
	QXhXh		= (1-lambda)*QX2X2 + lambda*QZX2'*aux1
	_makesymmetric(QXhXh)
	aux2		= cholsolve(QZZ,QZy)
	aux3		= cholsolve(QXhXh,QZX2')
	aux4		= cholsolve(QXhXh,QX2y)
	beta		= aux4*(1-lambda) + lambda*aux3*aux2
	if ( (aux1[1,1]==.) | (aux1[2,1]==.) | (aux3[1,1]==.) | (aux4[1,1]==.) ) {
		npd = 1
	}

	st_numscalar("r(npd)",npd)					//  npd flag is kept in Stata space
	return(beta)								//  column vector (Mata convention)

}
end

version 11.2
mata:
void s_wald(									///
				scalar lc_col,		/// flag for whether wald_chi2 is needed
				string scalar var_wbeta_name,	///
				string scalar beta_name,		///
				string scalar wnullvector_name	///
			)
{	

// flag set to 0, promote to 1 if NPD matrices encountered
	npd			= 0

	var_wbeta	= st_matrix(var_wbeta_name)
	beta		= st_matrix(beta_name)					//  row vector
	b0			= st_matrix(wnullvector_name)			//  row vector
// Change to column vectors
	beta		= beta'
	b0			= b0'

// Wald test
	rwald = beta - b0
	//printf("var_wbeta might have dimension error")

	if (lc_col >0){	
		aux0 = cholsolve(var_wbeta,rwald)
		if (aux0[1,1]==.) {
			aux0 = qrsolve(var_wbeta,rwald)
			npd = 1
		}
		wald_chi2 = rwald' * aux0
		st_numscalar("r(wald_chi2)",wald_chi2)
		st_numscalar("r(npd)",npd)
	}
	// wald test statistic for each component's projection test
	nwendog = rows(var_wbeta)
	wald_chi2p = J(1,nwendog,0)
	for (i=1; i<=nwendog; i++) {
		wald_chi2p[1,i]=rwald[i,1]*(1/var_wbeta[i,i])*rwald[i,1]
	}


	st_matrix("r(wald_chi2p)", wald_chi2p)
}
end

version 11.2
mata:
real matrix project_test2(										///
							string scalar vnums_name,			/// has column numbers of 2 weak vars in question
							pointer p,							///
							scalar points,						///
							string scalar pointsvec,			///
							string scalar colsvec,				///
							string scalar levelsvec				///
							)
{

	vnums			=st_matrix(vnums_name)
	gridpoints		=strtoreal(tokens(pointsvec))
	gridcols		=strtoreal(tokens(colsvec))
	levels			=strtoreal(tokens(levelsvec))
	rtable			= (100*(*p)[.,gridcols]) :< (100 :- levels)				//  missings => zeros (thus included in CI)
	rtable			= (*p)[.,vnums], rtable									//  append columns 1 and 2 with grid nulls for sorting

	_sort(rtable, (1, 2))														//  ... and sort on nulls in cols 1 and 2
	
	pcitable2 = J(0, 2+cols(gridcols), 1)
	
	points1i=gridpoints[1,vnums[1,1]]											//  points in grid for variable vnum 1
	points2i=gridpoints[1,vnums[1,2]]											//  points in grid for variable vnum 2
	pointsi =points1i*points2i
	blocksize=points/pointsi


	 for (i=1; i<=pointsi; i++) {
		block = rtable [ ((i-1)*blocksize+1)::(i*blocksize), (3..cols(rtable)) ]
		pcitablei = floor(colsum(block) * 1/blocksize)							//  * 1/blocksize means cols with all ones
																				//  will sum=1 and other cols will sum<1.
																				//  floor(.) converts former to 1 and latter to 0.
		pcitable2 = pcitable2 \ (rtable[(i*blocksize),(1,2)] , pcitablei)		//  and append with nulls (vnums) to pcitable
	}
	st_matrix("r(pcitable2)", pcitable2)
	
	return(pcitable2)
}
end


version 11.2
mata:
real matrix project_test(										///
							scalar vnum,						/// has column number of weak var in question
							string scalar lc_cols,			/// has column numbers of LC_2sls or LC or K's rejection indicator
							pointer p,						///
							scalar points,						///
							string scalar pointsvec,			///
							string scalar colsvec,				///
							string scalar levelsvec				///
							)
{

	lc_col			=strtoreal(tokens(lc_cols))
	gridpoints		=strtoreal(tokens(pointsvec))
	gridcols		=strtoreal(tokens(colsvec))
	levels			=strtoreal(tokens(levelsvec))
	rtable			= (100*(*p)[.,gridcols]) :< (100 :- levels)	//  missings => zeros (thus included in CI)
//printf("hellow")
//lc_col
	if (lc_col[1,1]>0) {
		rtable			= (*p)[.,vnum], rtable, (*p)[., lc_col]	//  append column 1 with grid nulls for sorting and last column LC_2slsp`vnum'_r or LCp`vnum'_r
	}
	else {
		rtable			= (*p)[.,vnum], rtable
	}
	_sort(rtable, 1)															//  ... and sort on nulls in col 1

	pcitable = J(0, cols(rtable), 1)					//  initialize new CI table - column 1 with grid nulls (added from above) and the rest for rejection indicator
	pointsi=gridpoints[1,vnum]						//  points in grid for variable vnum
	blocksize=points/pointsi

//printf("hellow")
//points
//blocksize
//rtable
	 for (i=1; i<=pointsi; i++) {
		block = rtable [ ((i-1)*blocksize+1)::(i*blocksize), (2..cols(rtable)) ]
		pcitablei = floor(colsum(block) * 1/blocksize)							//  * 1/blocksize means cols with all ones																	//  will sum=1 and other cols will sum<1.
							//  floor(.) converts former to 1 and latter to 0.
		pcitable = pcitable \ (rtable[(i*blocksize),1] , pcitablei)				//  and append with null to pcitable

	}
	st_matrix("r(pcitable)", pcitable)
//pcitable
	return(pcitable)
}
end

version 11.2
mata:
// Rank statistic of Kleibergen-Paap
function rk_kp(				matrix mPi,							///  D, pi_beta, pihat=invsym(zhzh)*zhyh in ranktest
							matrix mF,							///  identity matrix I(K), or iryhat' in ranktest
							matrix mG,							///  V_ff^(-1/2), rpsi_inv, or irzhat' in ranktest
							matrix mW,							///  V_thetatheta_f, var_pi_z - bracket*psi_inv*bracket', shat in ranktest 
							scalar q							///  testing for rank=q, usually #endog-1 = K-1
							)
{
	L		= rows(mPi)
	K		= cols(mPi)

	that	= mG * mPi * mF'			//  that from ranktest.ado notation

	if (q==0) {							//  simple case, test rank=0
	
		vlab		= (mF#mG) * mW * (mF#mG)'
		_makesymmetric(vlab)
		vlabinv		= invsym(vlab)
		rk			= that' * vlabinv * that

	}
	else {

		fullsvd(that, ut, cc, vt)
		vt=vt'
		vecthat=vec(that)
		ev = cc:^2

		vhat = (mF#mG) * mW * (mF#mG)'
		_makesymmetric(vhat)

		u12=ut[(1::q),(q+1..L)]
		v12=vt[(1::q),(q+1..K)]
		u22=ut[(q+1::L),(q+1..L)]
		v22=vt[(q+1::K),(q+1..K)]

		symeigensystem(u22*u22', evec, eval)
		u22v=evec
		u22d=diag(eval)
		u22h=u22v*(u22d:^0.5)*u22v'

		symeigensystem(v22*v22', evec, eval)
		v22v=evec
		v22d=diag(eval)
		v22h=v22v*(v22d:^0.5)*v22v'

		aq=(u12 \ u22)*luinv(u22)*u22h
		bq=v22h*luinv(v22')*(v12 \ v22)'

		lab=(bq#aq')*vecthat
		vlab=(bq#aq')*vhat*(bq#aq')'
		_makesymmetric(vlab)
		vlabinv=invsym(vlab)
		rk=lab'*vlabinv*lab

	}
	
	return(rk)
}
end


program compute_pvals, rclass
	syntax [,							///
				gridcols(string)	///
				closedform(integer 0)	///
				clrsims(integer -1)		///
				overid(integer 0)		///
				iid(integer 0)			///
				nexexog(integer 0)		///
				nendog(integer 0)		///
				nsendog(integer 0)		/// also boolean for strongly-IDed vars
				ncsendog(integer 0)		/// also boolean for subset AR test
				a_min(real 0)			///
				a_min_p(real 0)			///
				invchi2_k_df(real 0)		///
				invchi2_1_df(real 0)		///
				lc_crit(real 0)            /// critical value of the linear combination distribution
				lc_crit_p(real 0)          /// critical value of the linear combination distribution
				ar_chi2(real 0)			///
				k_chi2(real 0)			///
				k_2sls(real 0)			///
				lc_2sls(real 0)			///
				lc(real 0)			///
				j_chi2(real 0)			///
				kwt(string)				///
				clr_stat(real 0)		///
				wald_chi2(real 0)		///
				lc_2slsp(name local)		/// row vector of lc_2sls test statistics for projection tests
				lcp(name local)		/// 
				k_2slsp(name local)		///
				kp(name local)			///
				rk(real 0)				///
				 *]
		 
timer on 2

	tempname wald_p ar_p clr_p kj_p k_p lc_2sls_r j_p rk_p
	
	local wald_df		= `nendog' - `nsendog' - `ncsendog'
	scalar `wald_p'		= chi2tail(`nendog',`wald_chi2')
	*return scalar wald_df	=`wald_df'
	return scalar wald_p	=`wald_p'
	

	if strpos("`gridcols'", "ar_p") {
		local ar_df		= `nexexog' - `nsendog' - `ncsendog'
		scalar `ar_p'		= chi2tail(`ar_df',`ar_chi2')
		return scalar ar_p		=`ar_p'
	}
	if strpos("`gridcols'", "rk_p") {
		local rk_df		= `nexexog' - `nendog' + 1			//  df = L-K+1; #strong endog net out
		scalar `rk_p'		= chi2tail(`rk_df',`rk')
		return scalar rk_p		=`rk_p'
	}
* K p-value
	if strpos("`gridcols'", "k_p")|strpos("`gridcols'", "j_p") {
		local k_df		= `nendog' - `nsendog'
		scalar `k_p'	= chi2tail(`k_df',`k_chi2')
		return scalar k_p		=`k_p'

		if strpos("`gridcols'", "j_p") {
			local j_df		= `nexexog'-`nendog'
			scalar `j_p'	= chi2tail(`j_df',`j_chi2')		
			return scalar j_p		=`j_p'		
		}
		if strpos("`gridcols'", "kj_p") {
			* Instead of R = (1-p1)(1-p2) ~= p1+p2 (since p1*p2 negligible for small alphas/ps), exact:
			local p1=`k_p'/`kwt'		*	(1 - (1-`kwt')*`k_p')
			local p2=`j_p'/(1-`kwt')	*	(1 - `kwt'*`j_p')
			scalar `kj_p' = min(`p1',`p2')
			return scalar kj_p		=`kj_p'
		}
	}

* CLR p-value
	if strpos("`gridcols'", "clr_p") {										//  overidentified and not subset-AR, so need CLR stat p-value
		if `clr_stat'==. {											//  clr stat missing
			scalar `clr_p'=.
		}
		else if `clrsims'==-1 {										//  Poi and Mikusheva's method of estimating CLR p-value
																	//  works for nwendog=1 only
																	//  subroutine new_try from Mikusheva and Poi's code
			new_try `nexexog' `rk' `clr_stat' `clr_p'
* fix negative p-value approximations that occur because of rounding near zero 
			if `clr_p'<0 {
				scalar `clr_p'=0.000000
			}
		}
		else if `clrsims'==0 {										//  simulation of clr p-value suppressed
			scalar `clr_p'=.
		}
		else {														//  distribution of CLR by simulation
			tempname m chi2_ar chi2_k m_rk clr_sim oldseed
			mata: `m'		= `clrsims'
			mata: `oldseed'	= rseed()								//  save existing seed
			mata: rseed(12345)										//  set seed (replicability)
			mata: `chi2_ar'	= rchi2(`m',1,`ar_df')					//  chi2 draw for AR
			mata: `chi2_k'	= rchi2(`m',1,`k_df')					//  chi2 draw for K
			mata: rseed(`oldseed')									//  restore seed to previous value
			mata: `m_rk'	= `rk' * J(`m',1,1)						//  vector of repeated values of rk
			mata: `clr_sim'	= 0.5 :* ( `chi2_ar' - `m_rk' + ( (`chi2_ar'+`m_rk'):^2  - 4*(`chi2_ar' - `chi2_k') :* `m_rk' ) :^(0.5) )
			mata: `clr_p'	= sum(`clr_sim' :> `clr_stat')/`m'		//  p-value = prop of simulated values > actual CLR stat
			mata: st_numscalar("`clr_p'",`clr_p')					//  put into Stata
			mata: mata drop `m' `chi2_ar' `chi2_k' `m_rk'			//  and drop temp Mata vars
			mata: mata drop `clr_sim' `clr_p' `oldseed'
		}
		return scalar clr_p		=`clr_p'

	}
	
* linear combination with 2sls weight matrix.
	if (strpos("`gridcols'", "lc_2sls_r")|strpos("`gridcols'", "k_2sls_r")) {	
	// rather than calculating p-value, we calculate rejection is test stat>critical value
		local lc_2sls_r = cond(`lc_2sls'>`lc_crit'	,1,0)	
		return scalar lc_2sls_r		=`lc_2sls_r'
		local k_2sls_r = cond(`k_2sls'>`invchi2_k_df'    ,1,0)    
		return scalar k_2sls_r = `k_2sls_r'
	}
	if (strpos("`gridcols'", "lc_2slsp")|strpos("`gridcols'", "k_2slsp")) {
	// also calculate rejection indicator for projection test for each component - save into a vector
	// loop over the row vector of projection test statistis - faster than reading matrix into mata
		local nwendog = `nendog' - `nsendog'
		forvalues i = 1/`nwendog' {
			local lc_2slsp`i'_r= cond(`lc_2slsp'[1,`i']>`lc_crit_p'	,1,0)
			return scalar lc_2slsp`i'_r= `lc_2slsp`i'_r'
			if (strpos("`gridcols'", "k_2slsp")) {
				local k_2slsp`i'_r= cond(`k_2slsp'[1,`i']>`invchi2_1_df'    ,1,0)
				return scalar k_2slsp`i'_r= `k_2slsp`i'_r'
			}
		}	
	}

* linear combination with efficient weight matrix.
	if strpos("`gridcols'", "lc_r") {	
	// rather than calculating p-value, we calculate rejection is test stat>critical value
		local lc_r = cond(`lc'>`lc_crit'	,1,0)	
		return scalar lc_r		=`lc_r'
	}
	if (strpos("`gridcols'", "lcp")|strpos("`gridcols'", "kp")) {
	// also calculate rejection indicator for projection test for each component - save into a vector
	// loop over the row vector of projection test statistis - faster than reading matrix into mata
		local nwendog = `nendog' - `nsendog'
		forvalues i = 1/`nwendog' {
			local lcp`i'_r= cond(`lcp'[1,`i']>`lc_crit_p'	,1,0)
			return scalar lcp`i'_r= `lcp`i'_r'
			if (strpos("`gridcols'", "kp")) {
				local kp`i'_r= cond(`kp'[1,`i']>`invchi2_1_df'    ,1,0)
				return scalar kp`i'_r= `kp`i'_r'
			}
		}	
	}

timer off 2
end // end of compute_pval

*****************************************************************************
*** Subroutines from Mikusheva and Poi's condivreg:						  ***
*** 	get_ci_closedform (adaptation), new_try, mat_inv_sqrt, inversefun ***
*****************************************************************************

/* The following is an adaptation of the inversion code in Mikusheva and Poi's condivreg program */
/* NB: includes fixes related to df in denominator of omega and use of doubles */
/*     also assumed all exogenous regressors have been partialled out          */
/*

Below are type / type1 / type2 returned by Mikusheva-Poi code.  Not used in weakiv.

		Test		Result type		Interval
		-----------------------------------------------------------------------
		CLR		1			Empty set
				2			[x1, x2]
				3			(-infty, +infty)
				4		    (-infty, x1] U [x2, infty)
				
		AR		1			Empty set
				2			[x1, x2]
				3			(-infty, +infty)
				4		    (-infty, x1] U [x2, infty)
				
		K		1			Not used (not possible)
				2			[x1, x2]                                
				3			(-infty, +infty)
				4		(-infty, x1] U [x2, infty)
				5		(-infty, x1] U [x2, x3] U [x4, infty)
				6		    [x1, x2] U [x3, x4]
		
		-----------------------------------------------------------------------
*/

program get_ci_closedform, rclass
	syntax [,							///
				testlist(string)		/// ar, k, clr, etc.
				ry1(varname)			///
				ry2(varname)			///
				rinst(varlist)			///
				touse(varname)			///
				wtexp(string)			///
				nexexog(integer 0)		///
				ar_level(integer 0)		///
				k_level(integer 0)		///
				clr_level(integer 0)	///
				nobs(real 0)			///
				ssa(real 0)				///
				dofminus(real 0)		///
				* ]

* set booleans for tests; will be 0 if not in list and >0 if in list
	local ar		: list posof "ar" in testlist
	local clr		: list posof "clr" in testlist
	local k			: list posof "k" in testlist

* ry1 is depvar
* ry2 is endogenous regressor
* inst is excluded exogenous only with included exog partialled out

* compute omega
		tempname mzy1 mzy2 omega
		qui reg `ry1' `rinst' if `touse' `wtexp', nocons
		qui predict double `mzy1' if `touse', residuals
		qui reg `ry2' `rinst' if `touse' `wtexp', nocons
		qui predict double `mzy2' if `touse', residuals
		qui mat accum `omega' = `mzy1' `mzy2' if `touse' `wtexp', nocons
		mat `omega' = `omega' / (`nobs'-`dofminus') * `ssa'

* make stuff
		tempname cross zpz sqrtzpzi zpy MM ypz sqrtomegai v d M N alpha C A D aa x1 x2 g type
		qui mat accum `cross' = `rinst' `ry1' `ry2' if `touse' `wtexp', nocons
		mat `zpz' = `cross'[1..`nexexog', 1..`nexexog']
		mat `zpy' = `cross'[1..`nexexog', (`nexexog'+1)..(`nexexog'+2)]
		mat_inv_sqrt `zpz' `sqrtzpzi'
		mat_inv_sqrt `omega' `sqrtomegai'
		mat `ypz'=`zpy''

		mat `MM' = `sqrtomegai'*`ypz'*inv(`zpz')*`zpy'*`sqrtomegai'
		mat symeigen `v' `d' = `MM'
		sca `M' = `d'[1,1]
		sca `N' =`d'[1,2]
* inversion of CLR
		if `clr' {
			sca `alpha' = 1-`clr_level'/100
			inversefun `M' `nexexog' `alpha' `C'
			mat `A' =inv(`omega')*`ypz'*inv(`zpz')*`zpy'*inv(`omega')- `C'*inv(`omega')
			sca `D' = -det(`A')
			sca `aa' = `A'[1,1]
			if (`aa'<0) {
		 		if (`D' <0) {
					sca `type'=1
					local clr_cset "null set"
				}
		 		else{
					sca `type'=2
					sca `x1'= (-`A'[1,2] + sqrt(`D'))/`aa'
					sca `x2' = (-`A'[1,2] - sqrt(`D'))/`aa'
					mat `g'=(`x1'\ `x2')
					local clr_cset : di "[" %8.0g `x1' "," %8.0g `x2' "]"
	 			}
	 		}
			else{
				if (`D'<0) {
			  		sca `type'=3
					local clr_cset : di "( -inf,  +inf )"
				}
		 		else {
			  		sca `type'=4
			  		sca `x1'= (-`A'[1,2]-sqrt(`D'))/`aa'
			  		sca `x2'= (-`A'[1,2]+sqrt(`D'))/`aa'
			  		mat `g'=(`x1' \ `x2')
					local clr_cset : di "( -inf," %8.0g `x1' "] U [" %8.0g `x2' ", +inf )"
	 			}
		 	}
		 	return scalar type=`type'
			return local clr_cset="`clr_cset'"
	 	}

* inversion of K; code assumes overidentified
		if `k' {
			tempname kcv q1 q2 A1 A2 D1 D2 y1 y2 y3 y4 type1
			sca `kcv' = invchi2tail(1, (1-`k_level'/100))
			if ((`M' +`N' - `kcv')^2-4*`M'*`N'<0) { 
		 		sca `type1' = 3
				local k_cset : di "( -inf,  +inf )"
		 	}
			else {
			    sca `q1' = (`M'+ `N' - `kcv' - sqrt((`M'+`N' - `kcv')^2 -	4*`M'*`N'))/2
	 		    sca `q2' = (`M'+`N' - `kcv' + sqrt((`M'+`N'-`kcv')^2 - 4*`M'*`N'))/2
	 		    if ((`q1' < `N') | (`q2' > `M')) {
	 				sca `type1' = 3
					local k_cset : di "( -inf,  +inf )"
	 		    }
	 		    else { 		
					mat `A1' = inv(`omega')*`ypz'*inv(`zpz')*`zpy'*inv(`omega')-`q1'*inv(`omega')
					mat `A2' = inv(`omega')*`ypz'*inv(`zpz')*`zpy'*inv(`omega')-`q2'*inv(`omega')
			 		sca `D1' = -4*det(`A1')
					sca `D2' = -4*det(`A2')
		 			if (`A1'[1,1]>0) { 
			  			if (`A2'[1,1]>0) { 
							sca `type1' = 5
							sca `y1' = (-2*`A1'[1,2] + sqrt(`D1'))/2/`A1'[1,1]
							sca `y2' = (-2*`A1'[1,2] - sqrt(`D1'))/2/`A1'[1,1]
							sca `y3' = (-2*`A2'[1,2] + sqrt(`D2'))/2/`A2'[1,1]
							sca `y4' = (-2*`A2'[1,2] - sqrt(`D2'))/2/`A2'[1,1]
							local k_cset : di "( -inf," %9.0g `y1' "] U [" %9.0g `y3' "," %9.0g `y4' "] U [" %9.0g `y2' ", +inf )"
						}
			  			else {
							sca `type1' = 6
							sca `y1' = (-2*`A1'[1,2] + sqrt(`D1'))/2/`A1'[1,1]
							sca `y2' = (-2*`A1'[1,2] - sqrt(`D1'))/2/`A1'[1,1]
							sca `y3' = (-2*`A2'[1,2] + sqrt(`D2'))/2/`A2'[1,1]
							sca `y4' = (-2*`A2'[1,2] - sqrt(`D2'))/2/`A2'[1,1]
							if `y1'<`y3' {
								local k_cset : di "[" %9.0g `y2' "," %9.0g `y1' "] U [" %9.0g `y3' "," %9.0g `y4' "]"
							}
							else {
								local k_cset : di "[" %9.0g `y3' "," %9.0g `y4' "] U [" %9.0g `y2' "," %9.0g `y1' "]"						
							}
				  		}
				  	}
					if (`A1'[1,1]<=0) {
						sca `type1' =5
				  		sca `y1' = (-2*`A1'[1,2] + sqrt(`D1'))/2/`A1'[1,1]
						sca `y2' = (-2*`A1'[1,2] - sqrt(`D1'))/2/`A1'[1,1]
						sca `y3' = (-2*`A2'[1,2] + sqrt(`D2'))/2/`A2'[1,1]
						sca `y4' = (-2*`A2'[1,2] - sqrt(`D2'))/2/`A2'[1,1]
						local k_cset : di "( -inf," %9.0g `y1' "] U [" %9.0g `y3' "," %9.0g `y4' "] U [" %9.0g `y2' ", +inf )"
			  		}
			    }
			}
		 	return scalar type1=`type1'
			return local k_cset="`k_cset'"
		}

* inversion of AR
		if `ar' {
			tempname kcv1  AAA type2 xx1 xx2 DDD aaa
			sca `kcv1' = invchi2tail(`nexexog', (1-`ar_level'/100))
			mat `AAA' =`ypz'*inv(`zpz')*`zpy'-`kcv1'*`omega'
			sca `DDD' = -det(`AAA')
			sca `aaa' = `AAA'[2,2]
			if (`aaa'<0) {
		 		if (`DDD' <0) {
					sca `type2'=3
					local ar_cset : di "( -inf,  +inf )"
				}
		 		else{
					sca `type2'=4
			 		sca `xx1'= (`AAA'[1,2] + sqrt(`DDD'))/`aaa'
			 		sca `xx2' = (`AAA'[1,2] - sqrt(`DDD'))/`aaa'
					local ar_cset : di "( -inf,  " %9.0g `xx1' "] U [" %9.0g `xx2' ",  +inf )"
	 			 }
			}
			else {
				if (`DDD'<0) {
					sca `type2'=1
					local ar_cset "null set"
				}
		 		else {
			  		sca `type2'=2
			  		sca `xx1'= (`AAA'[1,2]-sqrt(`DDD'))/`aaa'
			  		sca `xx2'= (`AAA'[1,2]+sqrt(`DDD'))/`aaa'
					local ar_cset : di "[" %9.0g `xx1' "," %9.0g `xx2' "]"
	 			}
		 	}
		 	return scalar type2=`type2'
			return local ar_cset="`ar_cset'"
	 	}

end		// end get_ci_closedform


/* Program from Moreira, Mikusheva, and Poi's condivreg program--for finding CLR p-value */
program new_try
	args k qt lrstat pval_new
	tempname gamma pval  u s2 qs farg1 farg2 farg wt
	sca `gamma' = 2*exp(lngamma(`k'/2)) / sqrt(_pi) / exp(lngamma((`k'-1)/2))
	if("`k'" == "1") {
		sca `pval' = 1 - chi2(`k', `lrstat')
	}
	else if ("`k'"== "2") {
		local ni 20
		mat `u' = J(`ni'+1,1,0)
		mat `s2' = J(`ni'+1,1,0)
		mat `qs' = J(`ni'+1,1,0)
		mat `wt' = J(1,`ni'+1,2)
		mat `farg1' = J(`ni'+1,1,0)
		mat `qs'[1,1] = (`qt'+`lrstat')
		mat `farg1'[1,1] = `gamma'*chi2(`k',`qs'[1,1])
		forv i =1(1)`ni'{
			mat `u'[`i'+1,1] = `i'*_pi/2/`ni'
			mat `s2'[`i'+1,1] = sin(`u'[`i'+1,1])
			mat `qs'[`i'+1,1] = (`qt'+`lrstat') / (1+(`qt'/`lrstat')*`s2'[`i'+1,1]*`s2'[`i'+1,1])
			mat `farg1'[`i'+1,1] = `gamma'*chi2(`k',`qs'[`i'+1,1])
		}
		mat `wt'[1,1] = 1
		mat `wt'[1,`ni'+1] = 1
		local ni = `ni'/2
		forv i =1(1)`ni'{
			mat `wt'[1,`i'*2] = 4
		}
		local ni = `ni'*2
		mat `wt' = `wt'*_pi/2/3/`ni'
		mat `pval' = `wt'*`farg1'
		sca `pval' = 1-trace(`pval')
	}
	else if ("`k'"== "3") {
		local ni 20
		mat `s2' = J(`ni'+1,1,0)
		mat `qs' = J(`ni'+1,1,0)
		mat `wt' = J(1,`ni'+1,2)
		mat `farg1' = J(`ni'+1,1,0)
		mat `qs'[1,1] = (`qt'+`lrstat')
		mat `farg1'[1,1] = `gamma'*chi2(`k',`qs'[1,1])
		forv i =1(1)`ni'{
			mat `s2'[`i'+1,1] = `i'/`ni'
			mat `qs'[`i'+1,1] = (`qt'+`lrstat') / (1+(`qt'/`lrstat')*`s2'[`i'+1,1]*`s2'[`i'+1,1])
			mat `farg1'[`i'+1,1] = `gamma'*chi2(`k',`qs'[`i'+1,1])
		}
		mat `wt'[1,1] = 1
		mat `wt'[1,`ni'+1] = 1
		local ni = `ni'/2
		forv i =1(1)`ni'{
			mat `wt'[1,`i'*2] = 4
		}
		local ni = `ni'*2
		mat `wt' = `wt'/3/`ni'
		mat `pval' = `wt'*`farg1'
		sca `pval' = 1-trace(`pval')
	}
	else if ("`k'"== "4") {
		local eps .02
		local ni 50
		mat `s2' = J(`ni'+1,1,0)
		mat `qs' = J(`ni'+1,1,0)
		mat `wt' = J(1,`ni'+1,2)
		mat `farg' = J(`ni'+1,1,0)
		mat `farg1' = J(`ni'+1,1,0)
		mat `farg2' = J(`ni'+1,1,1)
		mat `qs'[1,1] = (`qt'+`lrstat')
		mat `farg1'[1,1] = `gamma'*chi2(`k',`qs'[1,1])
		mat `farg'[1,1] = `farg1'[1,1]*`farg2'[1,1]
		forv i = 1(1)`ni'{
			mat `s2'[`i'+1,1] = `i'/`ni'*(1-`eps')
			mat `qs'[`i'+1,1] = (`qt'+`lrstat') / (1+(`qt'/`lrstat')*`s2'[`i'+1,1]*`s2'[`i'+1,1])
			mat `farg1'[`i'+1,1] = `gamma'*chi2(`k',`qs'[`i'+1,1])
			mat `farg2'[`i'+1,1] = sqrt(1-`s2'[`i'+1,1]*`s2'[`i'+1,1])
			mat `farg'[`i'+1,1] = `farg1'[`i'+1,1]*`farg2'[`i'+1,1]
		}
		mat `wt'[1,1] = 1
		mat `wt'[1,`ni'+1] = 1
		local ni = `ni'/2
		forv i = 1(1)`ni'{
			mat `wt'[1,`i'*2] = 4
		}
		local ni = `ni'*2
		mat `wt' = `wt'/3/`ni'*(1-`eps')
		mat `pval' = `wt'*`farg'
		sca `pval' = 1-trace(`pval')
		sca `s2' = 1-`eps'/2
		sca `qs' = (`qt'+`lrstat')/(1+(`qt'/`lrstat')*`s2'*`s2')
		sca `farg1' = `gamma'*chi2(`k',`qs')
		sca `farg2' = 0.5*(asin(1)-asin(1-`eps'))-(1-`eps') / 2*sqrt(1-(1-`eps')*(1-`eps'))
		sca `pval' = `pval'-`farg1'*`farg2'
	}
	else {
		local ni 20
		mat `s2' = J(`ni'+1,1,0)
		mat `qs' = J(`ni'+1,1,0)
		mat `wt' = J(1,`ni'+1,2)
		mat `farg' = J(`ni'+1,1,0)
		mat `farg1' = J(`ni'+1,1,0)
		mat `farg2' = J(`ni'+1,1,1)
		mat `qs'[1,1] = (`qt'+`lrstat')
		mat `farg1'[1,1] = `gamma'*chi2(`k',`qs'[1,1])
		mat `farg'[1,1] = `farg1'[1,1]*`farg2'[1,1]
		forv i =1(1)`ni'{
			mat `s2'[`i'+1,1] = `i'/`ni'
			mat `qs'[`i'+1,1] = (`qt'+`lrstat') / (1+(`qt'/`lrstat')*`s2'[`i'+1,1]*`s2'[`i'+1,1])
			mat `farg1'[`i'+1,1] = `gamma'*chi2(`k',`qs'[`i'+1,1])
			if "`i'" == "`ni'"			mat `farg2'[`i'+1,1] = 0
			else						mat `farg2'[`i'+1,1] = (1-`s2'[`i'+1,1]*`s2'[`i'+1,1])^((`k'-3)/2)
			mat `farg'[`i'+1,1] = `farg1'[`i'+1,1]*`farg2'[`i'+1,1]
		}
		mat `wt'[1,1] = 1
		mat `wt'[1,`ni'+1] = 1
		local ni = `ni'/2
		forv i = 1(1)`ni'{
			mat `wt'[1,`i'*2] = 4
		}
		local ni = `ni'*2
		mat `wt' = `wt'/3/`ni'
		mat `pval' = `wt'*`farg'
		sca `pval' = 1-trace(`pval')
	}
	sca `pval_new' = `pval'
end 

/* Other programs from Mikusheva and Poi's condivreg */
program mat_inv_sqrt
	args in out
	tempname v vpri lam srlam
	local k = rowsof(`in')
	mat symeigen `v' `lam' = `in'
	mat `vpri' = `v''
	/* Get sqrt(lam)	  */
	mat `srlam' = diag(`lam')
	forv i = 1/`k' {
		mat `srlam'[`i', `i'] = 1/sqrt(`srlam'[`i', `i'])
	}
	mat `out' = `v'*`srlam'*`vpri'
end

program inversefun
	args M k alpha C
	tempname eps a  b x fa fb lrstat fx
	sca `eps' = 0.000001
	sca `a' = `eps' 
	sca `b' = `M' - `eps'
	sca `lrstat'= `M' - `a'
	new_try `k' `a' `lrstat' `fa'
	sca `lrstat' = `M' - `b'
	new_try `k' `b' `lrstat' `fb'
	if(`fa' > `alpha')			sca `C' = `a'
	else  if ( `fb' <`alpha')	sca `C' = `b'
	else {
		while (`b'-`a'>`eps') {
			sca `x' = (`b'-`a')/2+`a'
			sca `lrstat'= `M'-`x'
			new_try `k' `x' `lrstat' `fx'
			if (`fx' >`alpha')		sca `b' = `x'
			else					sca `a' = `x'
		}
		sca `C' = `x'
	}
end

*******************************************************************************
************************* misc utilities **************************************
*******************************************************************************

// internal version of weakiv_fvstrip 1.01 ms 24march2015
// identical to ivreg2_fvstrip in ivreg2 4.1.01
// takes varlist with possible FVs and strips out b/n/o notation
// returns results in r(varnames)
// optionally also omits omittable FVs
// expand calls fvexpand either on full varlist
// or (with onebyone option) on elements of varlist

program define weakiv_fvstrip, rclass
	version 11.2
	syntax [anything] [if] , [ dropomit expand onebyone NOIsily ]
	if "`expand'"~="" {												//  force call to fvexpand
		if "`onebyone'"=="" {
			fvexpand `anything' `if'								//  single call to fvexpand
			local anything `r(varlist)'
		}
		else {
			foreach vn of local anything {
				fvexpand `vn' `if'									//  call fvexpand on items one-by-one
				local newlist	`newlist' `r(varlist)'
			}
			local anything	: list clean newlist
		}
	}
	foreach vn of local anything {									//  loop through varnames
		if "`dropomit'"~="" {										//  check & include only if
			_ms_parse_parts `vn'									//  not omitted (b. or o.)
			if ~`r(omit)' {
				local unstripped	`unstripped' `vn'				//  add to list only if not omitted
			}
		}
		else {														//  add varname to list even if
			local unstripped		`unstripped' `vn'				//  could be omitted (b. or o.)
		}
	}
// Now create list with b/n/o stripped out
	foreach vn of local unstripped {
		local svn ""											//  initialize
		_ms_parse_parts `vn'
		if "`r(type)'"=="variable" & "`r(op)'"=="" {			//  simplest case - no change
			local svn	`vn'
		}
		else if "`r(type)'"=="variable" & "`r(op)'"=="o" {		//  next simplest case - o.varname => varname
			local svn	`r(name)'
		}
		else if "`r(type)'"=="variable" {						//  has other operators so strip o but leave .
			local op	`r(op)'
			local op	: subinstr local op "o" "", all
			local svn	`op'.`r(name)'
		}
		else if "`r(type)'"=="factor" {							//  simple factor variable
			local op	`r(op)'
			local op	: subinstr local op "b" "", all
			local op	: subinstr local op "n" "", all
			local op	: subinstr local op "o" "", all
			local svn	`op'.`r(name)'							//  operator + . + varname
		}
		else if"`r(type)'"=="interaction" {						//  multiple variables
			forvalues i=1/`r(k_names)' {
				local op	`r(op`i')'
				local op	: subinstr local op "b" "", all
				local op	: subinstr local op "n" "", all
				local op	: subinstr local op "o" "", all
				local opv	`op'.`r(name`i')'					//  operator + . + varname
				if `i'==1 {
					local svn	`opv'
				}
				else {
					local svn	`svn'#`opv'
				}
			}
		}
		else if "`r(type)'"=="product" {
			di as err "ivreg2_fvstrip error - type=product for `vn'"
			exit 198
		}
		else if "`r(type)'"=="error" {
			di as err "ivreg2_fvstrip error - type=error for `vn'"
			exit 198
		}
		else {
			di as err "ivreg2_fvstrip error - unknown type for `vn'"
			exit 198
		}
		local stripped `stripped' `svn'
	}
	local stripped	: list retokenize stripped						//  clean any extra spaces
	
	if "`noisily'"~="" {											//  for debugging etc.
di as result "`stripped'"
	}

	return local varlist	`stripped'								//  return results in r(varlist)
end

************************* replacement _rmcollright ****************************
* Below based on Stata version of _rmcollright provided with Stata 12.1:
*   version 1.3.0  07apr2009
* The original version calls fvexpand with weights, which isn't allowed.
* Code below is identical except `wgt' macro is commented out, and programs
* are renamed weakiv_rmcollright and weakiv_Drop.
program weakiv_rmcollright, rclass
        version 11
        syntax anything(id="varblocklist" name=vblist)  ///
                [if] [in] [fw aw iw pw] [, noCONStant COLLinear]

        local rmopts expand `constant' `collinear'

        marksample touse, novarlist
        local wgt [`weight'`exp']

        local hold : copy local vblist
        while `"`:list retok hold'"' != "" {
                gettoken varblock hold : hold, bind match(par)
                markout `touse' `varblock'
        }

        local k 0
        while `"`:list retok vblist'"' != "" {
                local ++k
                gettoken varblock vblist : vblist, bind match(par)
                if "`par'" == "" {
                        fvunab varblock : `varblock'
                        gettoken varblock rest : varblock, bind
                        if `:length local rest' {
                                local vblist `"`rest' `vblist'"'
                        }
                }
                fvexpand `varblock' if `touse' `in' /* `wgt' */			//  <= CHANGE IS HERE
                local vb0_`k' `r(varlist)'
                _rmcoll `varblock' if `touse' `in' `wgt', `rmopts'
                local vb_`k' `r(varlist)'
                local drop_`k' : list vb0_`k' - vb_`k'
                local vlist `vlist' `vb_`k''
                local dlist `drop_`k'' `dlist'
        }

        _rmcoll `vlist' if `touse' `in' `wgt', `rmopts'
        local vlist2 `r(varlist)'
        local drop : list vlist - vlist2
        while `:list sizeof drop' {
                gettoken dvar drop : drop
                forval i = `k'(-1)1 {
                        if `:list dvar in vb_`i'' {
                                weakiv_Drop vb_`i' : `dvar' `vb_`i''
                                continue, break
                        }
                }
                local dlist `dvar' `dlist'
        }

        return scalar k = `k'
        return local dropped `dlist'
        forval i = 1/`k' {
                local newvblist `newvblist' (`vb_`i'')
                return local block`i' `vb_`i''
        }
        return local varblocklist `newvblist'
        return local varlist `vlist2'
end

* Called by weakiv_rmcollright
program weakiv_Drop
		version 11
        gettoken c_block 0 : 0
        gettoken COLON 0 : 0
        gettoken drop block : 0

        fvunab odrop : o.`drop'
        while `:list sizeof block' {
                gettoken var block : block
                local rlist `var' `rlist'
        }
        local rlist : subinstr local rlist "`drop'" "`odrop'", word
        while `:list sizeof rlist' {
                gettoken var rlist : rlist
                local block `var' `block'
        }
        c_local `c_block' `block'
end

* Utility to provide matching names.
* varnames is list of names to look up.
* namelist1 is where the names are looked for.
* namelist2 has the corresponding names that are selected/returned.
program define weakiv_matchnames, rclass
	version 11.2
	args	varnames namelist1 namelist2

	local k1 : word count `namelist1'
	local k2 : word count `namelist2'
/*
	if `k1' ~= `k2' {
		di as err "namelist error - lengths of two lists do not match"
		exit 198
	}
*/
	foreach vn in `varnames' {
		local i : list posof `"`vn'"' in namelist1
		if `i' > 0 {
			local newname : word `i' of `namelist2'
		}
		else {
* Keep old name if not found in list
			local newname "`vn'"
		}
		local names "`names' `newname'"
	}
	local names	: list clean names
	return local names "`names'"
end
