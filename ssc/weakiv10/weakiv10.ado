*! weakiv10 1.0.11  23Mar2014
*! authors Finlay-Magnusson-Schaffer

* Notes:
* 1.0.01	31Jul2013.	First complete working version
* 1.0.02	04Aug2013.	Bug fix in kwt (was ignoring option)
* 1.0.03	05Aug2013.	Renamed weakiv with modified syntax. Minor program restructuring.
* 1.0.04	07Aug2013.	J cset reported. Open-ended and entire-grid csets noted in output.
*						Hyperlinks in output table added; link to sections of help file.
*						"all" option added for graph(.).
* 1.0.05	11Aug2013.	Added support for ivreg2h (Lewbel-type generated IVs).
*						Fixed bug in combination of replay() and graph(all).
* 1.0.06	22Sep2013.	Major update.  Added support for 2-endog-regressor case.
*						Graphing for K=2 case requires Stata 12 (contour) and -surface-.
*						Switch from use of ranktest to use of avar.
*						level option for graphing now allows multiple levels;
*						  with replay can change level vs. estimation table.
*						Various coding reorganizations, fixes and tidying up.
*						Bug fix for iid closed-form CIs when only included exog is constant.
*						Minor bug fix for CLR - numerical precision issues mean it can be
*						  very small and <0, so now take abs(.)
* 1.0.07	11Nov2013.	Minor bug fix for K=2 (would crash in grid search if exactly IDed)
* 1.0.08	15Jan2014.  Added support for FE and FD estimation by xtivreg2 and xtivreg.
*                       Included recoding for temporary variables to support TS operators.
*                       Added number of observations to table output.
*                       Added contourline (default) and contourshade to contour options
*                       Added kjlevel(.), arlevel(.), jlevel(.) options.
*                       Saved level macros now level and levellist (if >1 specified)
*                       Behavior of level(.) option is now that first (not highest) is used for tests.
*                       Added check for Stata-legal confidence levels (>=10, <=99.99)
*                       Save cluster numbers and variables as e(.) macros
*                       Add support for Kleibergen LM method, both iid and non-iid cases.  Implies partialling-out.
*                       NB: Kleibergen non-iid formulae do not reduce to iid formula when iid covariances used.
*                       Fixed bug in closed-form CIs with dofminus
* 1.0.09	16Feb2014	Fixed bug in user-set levels for J and AR tests.
*						Fixed display of excessive precision for kwt.
* 1.0.10	23Mar2014	Added strong(.) option.  Various code tweaks.
*						Fixed minor contouronly/surfaceonly bug (ignored in interactive mode)
* 1.0.10	4Aug2014	Fixed bug in CIs with LM option - was using MD
* 1.0.10				Fixed bug in CIs with strongly-ID coeffs - was ignoring #sendog in dof
* 1.0.11    9Sep2014    Fixed minor bug in reporting endpoint of CI if same as endpoint of grid
*                       First weakiv10 release

program define weakiv10, eclass byable(recall) sortpreserve
	version 10.1
	local lversion 01.0.11
	local avarversion 01.0.04

	checkversion_avar `avarversion'				//  Confirm avar is installed (necessary component).

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

		if "`estusewald'" != "" {				//  Wald model is provided by user so make current,
			est restore `estusewald'			//  then proceed to weak-IV-robust estimation.
		}

		if "`e(cmd)'"=="weakiv" {				//  Replay last weakiv results, then exit.
			weakiv_replay `0'					//  Useful for tweaking graph options.
			exit								//  weakiv_replay syntax will catch illegals.
 		}

	}
	else {										//  Estimate model specified by user before ",".
		estimate_model `0'						//  Estimate model, then proceed to weak-IV-robust estimation.
	}	// end replay()

************************* ASSEMBLE MODEL AND OPTION SPECS *****************************************
* Model in memory is now main model for Wald tests etc.
* Weak IV-robust estimation inherits same characteristics (robust etc.).

* Save command line and store model results.
* Will use later for Wald tests and delete unless eststorewald specified.
	local cmdline "weakiv `0'"

* Get model specs from active model
	tempvar touse wvar						//  vars defined by estimation
	get_model_specs,				 		/// Gets model specs from prev model. Catches some illegals.
					touse(`touse')			/// Also sets values for temp var `touse'
					wvar(`wvar')			//  Also sets values for temp var `wvar'

	local model			"`r(model)'"
	local xtmodel		"`r(xtmodel)'"		//  empty if not estimated using panel data estimator
	local ivtitle		"`r(ivtitle)'"
	local depvar		"`r(depvar)'"
	local inexog		"`r(inexog)'"
	local endo			"`r(endo)'"
	local exexog		"`r(exexog)'"
	local noconstant	"`r(noconstant)'"	//  "noconstant" if no constant in origial model specification
	local cons			=r(cons)			//  0 if no constant in model (including after any partialling-out)
	local nendog		"`r(nendog)'"
	local nexexog		"`r(nexexog)'"
	local ninexog		"`r(ninexog)'"
	local overid		=r(overid)	
	local partial		"`r(partial)'"
	local partialcons	=r(partialcons)		//  0 if no partialling out or if no cons partialled out
	local npartial		=r(npartial)		//  0 if no partialling out. # includes constant.
	local small			"`r(small)'"
	local robust		"`r(robust)'"
	local cluster		"`r(cluster)'"
	local bw			"`r(bw)'"
	local kernel		"`r(kernel)'"
	local llopt			"`r(llopt)'"
	local ulopt			"`r(ulopt)'"
	local asis			"`r(asis)'"
	local wtexp			"`r(wtexp)'"
	local wexp			"`r(wexp)'"
	local wtype			"`r(wtype)'"
	local exp			"`r(exp)'"
	local wf			=r(wf)
	local N				=r(N)
	local N_clust		"`r(N_clust)'"
	local N_clust1		"`r(N_clust1)'"
	local N_clust2		"`r(N_clust2)'"
	local clustvar		"`r(clustvar)'"
	local N_g			=r(N_g)				//  #panel groups; 0 if not XT estimator
	local singleton		=r(singleton)		//  #panel singletons' 0 if not XT estimator or if no singleton groups
	local dofminus		=r(dofminus)		//  0 unless set by ivreg2
	local psd			"`r(psd)'"
	local vceopt		"`r(vceopt)'"
	local note1			"`r(note1)'"
	local note2			"`r(note2)'"
	local note3			"`r(note3)'"
	local iid			"`r(iid)'"

* Store Wald model
	tempname waldmodel
	_estimates hold `waldmodel'

* Get weakiv options from command line
* Pass additional args to get_option_specs
	gettoken first opts : 0 , parse(",")
	if "`first'"~="," {									//  args in macro `first' so run again
		gettoken first opts : opts , parse(",")			//  to get rid of comma
	}
	get_option_specs,	`opts'							/// 
						 weakiv_iid(`iid')				/// pass iid info along with options
						 weakiv_model(`model')			/// pass info on model along with options
						 weakiv_overid(`overid')		/// pass overid info along with options
						 weakiv_nendog(`nendog')		/// pass #endog info along with options
						 weakiv_endo(`endo')			//  pass names of endog
	local level			"`r(level)'"
	local levellist		"`r(levellist)'"
	local ar_level		"`r(ar_level)'"
	local wald_level	"`r(wald_level)'"
	local clr_level		"`r(clr_level)'"
	local k_level		"`r(k_level)'"
	local j_level		"`r(j_level)'"
	local kj_level		"`r(kj_level)'"
	local kjk_level		"`r(kjk_level)'"
	local kjj_level		"`r(kjj_level)'"
	local null			"`r(null)'"
	local null1			"`r(null1)'"
	local null2			"`r(null2)'"
	local kwt			"`r(kwt)'"
	local lm			"`r(lm)'"						//  now =0 or 1
	local nsendog		=r(nsendog)						//  #strongly identified endog
	local nwendog		=r(nwendog)						//  #weakly identified endog
	local sendo			"`r(sendo)'"					//  name of strongly identified endog
	local wendo			"`r(wendo)'"					//  name of weakly identified endog
	local endo1			"`r(endo1)'"
	local endo2			"`r(endo2)'"
	local ci			"`r(ci)'"						//  =0 or 1
	local usegrid		"`r(usegrid)'"					//  now =0 or 1
	local grid			"`r(grid)'"
	local points		"`r(points)'"
	local points1		"`r(points1)'"
	local points2		"`r(points2)'"
	local gridmult		"`r(gridmult)'"
	local gridlimits	"`r(gridlimits)'"
	local gridlimits1	"`r(gridlimits1)'"
	local gridlimits2	"`r(gridlimits2)'"
	local exportmats	"`r(exportmats)'"
	local eststorewald	"`r(eststorewald)'"
	local estadd		=r(estadd)						//	=0 or 1
	local estaddname	"`r(estaddname)'"
	local graph			"`r(graph)'"
	local graphxrange	"`r(graphxrange)'"
	local graphopt		"`r(graphopt)'"
	local contouropt	"`r(contouropt)'"
	local surfaceopt	"`r(surfaceopt)'"
	local contouronly	"`r(contouronly)'"
	local surfaceonly	"`r(surfaceonly)'"
	local displaywald	"`r(displaywald)'"
	local forcerobust	"`r(forcerobust)'"
	//  end assembly of model and option specs

*********** LM method and strong option imply partialling-out *****
	if `lm' | `nsendog'>0 {
		if "`model'" ~= "linear" {				//  Should have been caught in get_option_specs but add here anyway
							 					//  LM (Kleibergen 2002, 2005) valid only for linear IV
							 					//  strongly-IDed endog currently supported only for linear IV
di as err "illegal option - supported only for linear IV models"
		exit 198
		}
		if "`inexog'"~="" {						//  Included exogenous Xs to partial out (may include constant)
			local partial "`inexog'"
			local npartial : word count `partial'
			local npartial		=`npartial'+`cons'+`partialcons'	//  Either cons=1 or partialcons=1, never both
			local partialcons	=`cons'+`partialcons'
			local cons 			=0
		}
		else if `cons' | `partialcons' {		//  Only constant to partial out
			local partial		"_cons"
			local npartial		=1
			local partialcons	=1
			local cons			=0
		}
		else {									//  No Xs or constant at all; only endogenous regressors
			local partial		""
			local npartial		=0
			local partialcons	=0
			local cons			=0
		}
	}

************************* Prep for any transformations **************************************

* If TS operators used, replace with temporary variables.
* Ensures that any transformation are applied to temporary vars.
* Extension "_t" is list with temp vars.
* No support yet for partial list.

	foreach vlist in depvar inexog exexog endo endo1 endo2 wendo sendo {
		tsrevar ``vlist'', substitute
		local `vlist'_t "`r(varlist)'"
	}

***************************** XT TRANSFORMS *************************************************
* Transform data (FE or FD) if required.
	if "`xtmodel'" == "fe" {
	
* If data already preserved, OK; if preserve fails for other reasons, exit with error
		capture preserve
		if _rc > 0 & _rc~=621 {
di as err "Internal weakiv error - preserve failed"
			exit 498
		}

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
* Handled by tsrevar above - varlists have D. operator in them.
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
* Transform data (partialling-out) if required.

* `npartial' is #vars to be partialled out; includes constant in count.
* `partial' has either varlist or "_cons" in it.
* `partialvars' has all to be partialled out except for constant.
	if `npartial' {
		if "`partial'"=="_cons" {
			local partialvars ""
		}
		else {
			local partialvars "`partial'"
		}
* Ready to transform data, so preserve
* If data already preserved, OK; if preserve fails for other reasons, exit with error
		capture preserve
		if _rc > 0 & _rc~=621 {
di as err "Internal weakiv error - preserve failed"
			exit 498
		}
* No support yet for TS varis in partial list
		local inexog   : list inexog   - partialvars
		local inexog_t : list inexog_t - partialvars
* Loop through variables to transform
* Use tempvars if any so that they are transformed
		tempname partial_resid
		foreach var of varlist `depvar_t' `inexog_t' `endo_t' `exexog_t'  {
			qui regress `var' `partialvars' if `touse' `wtexp', `noconstant'
			qui predict double `partial_resid' if `touse', resid
			qui replace `var' = `partial_resid'
			drop `partial_resid'
		}
* constant always partialled out
		local noconstant "noconstant"
* update count of included exogenous
		local ninexog = `ninexog'-`npartial'
	}

	// end partial-out block

***************************** PREPARATION (K=1 or K=2) ********************

* Small-sample adjustsment.  Includes #partialled-out vars.
	if "`small'"~="" & "`cluster'"=="" {
		local ssa=(`N'-`dofminus')/(`N'-(`nexexog'+`ninexog'+`npartial')-`dofminus')		//  iid, robust, ac or HAC
	}
	else if "`small'"~="" & "`cluster'"~="" {
		local ssa=(`N_clust')/(`N_clust'-1) *						/// cluster
			(`N'-1)/(`N'-(`nexexog'+`ninexog'+`npartial'))			//  no dofminus here
	}
	else {
		local ssa=1													//  no small
	}

* Shared tempnames
	tempname rk ar_p ar_chi2 ar_df k_p k_chi2 k_df j_p j_chi2 j_df kj_p ///
		clr_p clr_stat clr_df ar_r k_r j_r kj_dnr kj_r clr_r			///
		wald_p wald_chi2 wald_df wald_r
	tempname nullvec del_z pi_z var_del var_pidel_z var_pi_z bhat del_v var_beta
	tempname S S11 S12 S22 zz zzinv x2z x1x2 zx1 zy b2hat pi2hat
	tempname bhat pi_z1 pi_z2 var_pidel_z1 var_pidel_z2 var_pi_z11 var_pi_z12 var_pi_z22
	tempname syy see sxx sxy sxe syv sve svv AA
	tempvar vhat vhat1 vhat2 uhat uhat1 uhat2 ehat
	tempname citable


* Misc
	local alpha=1-`level'/100
	local npd=0

************************************ ESTIMATE *****************************

*********************************** K=1weak/1strong ******************************************************
* Code assumes all exogenous regressors have been partialled out
* So no inexog list, no constant

	if `nwendog'==1 & `nsendog'==1 {

* For Wald tests and construction of stats and grids
		_estimates unhold `waldmodel'
		local ivbeta1=_b[`wendo']
		local ivbeta2=_b[`sendo']
		local ivbetase1=_se[`wendo']
		local ivbetase2=_se[`sendo']
		mat `var_beta'=e(V)
		mat `var_beta'=`var_beta'[1..2,1..2]
		_estimates hold `waldmodel'

* Various cross-products
		qui mat accum `AA'  = `exexog_t' `wendo_t' `sendo_t' `depvar_t' if `touse' `wtexp', nocons
		mat `zz'    = `AA'[1..`nexexog',1..`nexexog']
		mat `x2z'   = `AA'[`nexexog'+2,1..`nexexog']
		mat `x1x2'  = `AA'[`nexexog'+1,`nexexog'+2]
		mat `zx1'   = `AA'[1..`nexexog',`nexexog'+1]
		mat `zy'    = `AA'[1..`nexexog',`nexexog'+3]
		mat `zzinv' = syminv(`zz')

		mat `b2hat'  = syminv(`x2z'*`zzinv'*`x2z'')*`x2z'*`zzinv'*`zy'
		mat `pi2hat' = syminv(`x2z'*`zzinv'*`x2z'')*`x2z'*`zzinv'*`zx1'

* RF estimations, IID case
		if `iid' & (`forcerobust'==0) {

			qui reg `wendo_t' `exexog_t' if `touse' `wtexp', nocons
			qui predict double `vhat1' if `touse', residuals
			mata: `pi_z1' = st_matrix("e(b)")
			mata: `pi_z1' = `pi_z1''
			qui reg `sendo_t' `exexog_t' if `touse' `wtexp', nocons
			qui predict double `vhat2' if `touse', residuals
			mata: `pi_z2' = st_matrix("e(b)")
			mata: `pi_z2' = `pi_z2''
			mata: `pi_z' = `pi_z1' , `pi_z2'
			mata: st_matrix("r(`pi_z')",`pi_z')
			mat `pi_z'=r(`pi_z')
			mata: mata drop `pi_z'
* Above as in ET paper p. 9 step 1 to obtain.  Notation for pi_z and vhat1, vhat2 matches.
			local df_r=`e(df_r)' - `npartial'							//  df_r needs to exclude #partialled-out vars
			local reg_df_r=`e(df_r)'									//  reg_df_r is used for recovering large-sample V
* avar automatically handles dofminus adjustment
			cap avar (`vhat1' `vhat2') (`exexog_t') if `touse' `wtexp', nocons dofminus(`dofminus')
			if _rc>0 {
				di "error - internal call to avar failed"
				exit _rc
			}

			mata: `S'=st_matrix("r(S)")
			mata: `zz'=st_matrix("`zz'")
			mata: `zzinv'=invsym(`zz')
			mata: `var_pi_z' = `N' * makesymmetric(I(2)#`zzinv'*`S'*I(2)#`zzinv')
			mata: st_matrix("r(`var_pi_z')",`var_pi_z')
			mat `var_pi_z'=r(`var_pi_z')
			mata: mata drop `var_pi_z' `zz' `zzinv'

* Only linear model currently supported
			qui reg `depvar_t' `exexog_t' `vhat1' `vhat2' if `touse' `wtexp', nocons

			mat `var_del'=e(V)
			mat `var_del'= `var_del'[1..`nexexog',1..`nexexog']
			mat `var_del' = ((`reg_df_r'-2)/`N')*`var_del'				//  recover large-sample V; (df_r-2) because
																		//  of inclusion of vhat1 and vhat2 in RF regression
			mat `var_del' = `var_del' * `N'/(`N'-`dofminus')			//  dofminus (large-sample) adjustment
			mat `bhat'=e(b)
			mat `del_z'=`bhat'[1...,1..`nexexog']
			mat `del_z'=`del_z''
			mat `del_v'=`bhat'[1...,`nexexog'+1..`nexexog'+2]
			mat `del_v'=`del_v''

			mat `var_pi_z' = `var_pi_z'	* `ssa'							//  ssa is small-sample adjustment or 1
			mat `var_del' = `var_del' * `ssa'
			if `lm' {													//  all of inexog will have been partialled out for LM method
				qui reg `depvar_t' `exexog_t' if `touse' `wtexp', noconstant
				qui predict double `ehat' if `touse', resid
				qui mat accum `AA' = `depvar_t' `wendo_t' `sendo_t' `vhat1' `vhat2' `ehat'  if `touse' `wtexp', noconstant
				matrix `syy'	= `AA'[1,1]       * 1/(`N'-`dofminus') * `ssa'
				matrix `see'	= `AA'[6,6]       * 1/(`N'-`dofminus') * `ssa'
				matrix `sxx'	= `AA'[2..3,2..3] * 1/(`N'-`dofminus') * `ssa'
				matrix `sxy'	= `AA'[2..3,1..1] * 1/(`N'-`dofminus') * `ssa'
				matrix `syv'	= `AA'[4..5,1..1] * 1/(`N'-`dofminus') * `ssa'
				matrix `svv'	= `AA'[4..5,4..5] * 1/(`N'-`dofminus') * `ssa'
				matrix `sve'	= `AA'[4..5,6..6] * 1/(`N'-`dofminus') * `ssa'
*				matrix `sxe'	= `AA'[2..3,6..6] * 1/(`N'-`dofminus') * `ssa'		//  same as sve
			}
		}																// end iid code
		else {															// robust/non-iid case
			qui reg `depvar_t' `exexog_t' if `touse' `wtexp', nocons
			mata: `del_z' = st_matrix("e(b)")
* COLUMN vector
			mata: `del_z' = `del_z''
			qui predict double `uhat' if `touse', resid

			qui reg `wendo_t' `exexog_t' if `touse' `wtexp', nocons
			qui predict double `vhat1' if `touse', resid
			mata: `pi_z1' = st_matrix("e(b)")
* COLUMN vector
			mata: `pi_z1' = `pi_z1''
			qui reg `sendo_t' `exexog_t' if `touse' `wtexp', nocons
			qui predict double `vhat2' if `touse', resid
			mata: `bhat' = st_matrix("e(b)")
			mata: `pi_z2' = `bhat'[| 1,1 \ .,`nexexog' |]
* COLUMN vector
			mata: `pi_z2' = `pi_z2''
* COMBINED
			mata: `pi_z' = `pi_z1' , `pi_z2'

			if `lm' {
				cap avar (`depvar_t' `wendo_t' `sendo_t') (`exexog_t') if `touse' `wtexp', `vceopt' nocons dofminus(`dofminus')			
			}
			else {
				cap avar (`uhat' `vhat1' `vhat2') (`exexog_t') if `touse' `wtexp', `vceopt' nocons dofminus(`dofminus')
			}
			if _rc>0 {
				di "error - internal call to avar failed"
				exit _rc
			}
	
			mata: `S'=st_matrix("r(S)")
			mata: `S11'=`S'[| 1,1 \ `nexexog',`nexexog' |]
			mata: `S12'=`S'[| `nexexog'+1,1 \ rows(`S'),`nexexog' |]
			mata: `S22'=`S'[| `nexexog'+1, `nexexog'+1 \ rows(`S'),cols(`S') |]
	
			mata: `zz'=st_matrix("`zz'")
			mata: `zzinv'=invsym(`zz')
	
			mata: `var_del' = `N' * makesymmetric(`zzinv'*`S11'*`zzinv') * `ssa'		// ssa is small-sample adjustment or 1
			mata: `var_del'=`var_del'[| 1,1 \ `nexexog',`nexexog' |]
	
* Kronecker structure
			mata: `var_pi_z' = `N' * makesymmetric(I(2)#`zzinv'*`S22'*I(2)#`zzinv') * `ssa'
			mata: `var_pi_z11' = `var_pi_z'[| 1,1 \ `nexexog',`nexexog' |]
			mata: `var_pi_z22' = `var_pi_z'[| `nexexog'+1,`nexexog'+1 \ 2*`nexexog',2*`nexexog' |]
			mata: `var_pi_z12' = `var_pi_z'[| `nexexog'+1,1 \ 2*`nexexog',`nexexog' |]
			mata: `var_pi_z' = (`var_pi_z11', `var_pi_z12'') \ (`var_pi_z12', `var_pi_z22')
	
* Kronecker structure
			mata: `var_pidel_z' = `N' * I(2)#`zzinv'*`S12'*`zzinv' * `ssa'
			mata: `var_pidel_z1' = `var_pidel_z'[| 1,1 \ `nexexog',`nexexog' |]
			mata: `var_pidel_z2' = `var_pidel_z'[| `nexexog'+1,1 \ 2*`nexexog',`nexexog' |]
			mata: `var_pidel_z' = `var_pidel_z1' \ `var_pidel_z2'
	
			mata: st_matrix("r(`del_z')",`del_z')
			mata: st_matrix("r(`pi_z')",`pi_z')
			mata: st_matrix("r(`var_del')",`var_del')
			mata: st_matrix("r(`var_pi_z')",`var_pi_z')
			mata: st_matrix("r(`var_pidel_z')",`var_pidel_z')
			mat `del_z'=r(`del_z')
			mat `pi_z'=r(`pi_z')
			mat `var_del'=r(`var_del')
			mat `var_pi_z'=r(`var_pi_z')
			mat `var_pidel_z'=r(`var_pidel_z')
	
			mata: mata drop `zz' `zzinv' `S' `S11' `S12' `S22' `bhat'			// clean up Mata memory
			mata: mata drop `del_z' `var_del' `var_pi_z' `var_pi_z11' `var_pi_z12' `var_pi_z22'
			mata: mata drop `pi_z' `pi_z1' `pi_z2' `var_pidel_z' `var_pidel_z1' `var_pidel_z2'

		}		// end robust/non-iid code

		if `ci' | `usegrid' {				//  default is to construct CI

			construct_ci1w1s,				///
				iid(`iid')					///
				usegrid(`usegrid')			///
				depvar(`depvar_t')			///
				wendo(`wendo_t')			///
				sendo(`sendo_t')			///
				exexog(`exexog_t')			///  no inexog, no constant - partialled out
				touse (`touse')				///
				wtexp(`wtexp')				///
				vceopt(`vceopt')			///
				nexexog(`nexexog')			///
				nendog(`nendog')			///
				nsendog(`nsendog')			///
				ssa(`ssa')					///
				dofminus(`dofminus')		///
				overid(`overid')			///
				level(`level')				///
				kj_level(`kj_level')		///
				j_level(`j_level')			///
				ar_level(`ar_level')		///
				alpha(`alpha')				///
				kwt(`kwt')					///
				n(`N')						///
				grid(`grid')				///
				gridlimits(`gridlimits')	///
				gridmult(`gridmult')		///
				points(`points')			///
				ivbeta1(`ivbeta1')			///
				ivbetase1(`ivbetase1')		///
				ivbeta2(`ivbeta2')			///
				var_beta(`var_beta')		///
				b2hat(`b2hat')				///
				pi2hat(`pi2hat')			///
				var_pi_z(`var_pi_z')		///
				pi_z(`pi_z')				///
				var_del(`var_del')			///
				del_z(`del_z')				///
				del_v(`del_v')				///
				var_pidel_z(`var_pidel_z')	///
				x2z(`x2z')					///
				syy(`syy')					///
				see(`see')					///
				sxy(`sxy')					///
				sve(`sve')					///
				sxx(`sxx')					///
				svv(`svv')					///
				lm(`lm')					///
				forcerobust("`forcerobust'")
			local ar_cset "`r(ar_cset)'"
			local clr_cset "`r(clr_cset)'"
			local k_cset "`r(k_cset)'"
			local kj_cset "`r(kj_cset)'"
			local j_cset "`r(j_cset)'"
			mat `citable'=r(citable)
	
			local grid_description "`r(grid_description)'"
			local points "`r(points)'"		//  In case grid provided, points=#elements in grid
	
		}	//  end construction of confidence interval


* Test specified null
* IV estimator; used for iid or for 1st step in 2-step GMM if non-iid
* Needs to be passed as a local
		mat `AA' = `b2hat' - `null'*`pi2hat'
		local beta2hat = `AA'[1,1]
* calculate test stats
		if `iid' & (`forcerobust'==0) {
			computeivtests_iid2,			///
				var_pi_z(`var_pi_z')		///
				pi_z(`pi_z')				///
				var_del(`var_del')			///
				del_z(`del_z')				///
				del_v(`del_v')				///
				ivbeta1(`ivbeta1')			///
				ivbeta2(`ivbeta2')			///
				var_beta(`var_beta')		///
				null1(`null')				///
				null2(`beta2hat')			///
				nexexog(`nexexog')			///
				syy(`syy')					///
				see(`see')					///
				sxy(`sxy')					///
				sve(`sve')					///
				sxx(`sxx')					///
				svv(`svv')					///
				lm(`lm')

		}
		else {
		
			tempvar ytilda ehat
			tempname Sgmm2s W
			qui gen double `ytilda' = `depvar_t' - `null1'*`wendo_t'
			qui gen double `ehat'   = `ytilda' - `beta2hat'*`sendo_t'
			cap avar (`ehat') (`exexog_t') if `touse' `wtexp', `vceopt' nocons
			if _rc>0 {
di as err "error - internal call to avar failed"
				exit _rc
			}
			mat `Sgmm2s' = r(S)
			mat `W' = syminv(`Sgmm2s')
			qui mat accum `AA'  = `exexog_t' `ytilda' if `touse' `wtexp', nocons
			mat `zy'    = `AA'[1..`nexexog',`nexexog'+1]
* 2-step efficient GMM estimator
			mat `AA'  = syminv(`x2z'*`W'*`x2z'')*`x2z'*`W'*`zy'
			local beta2hat=`AA'[1,1]
			
			mata: computeivtests_robust2(						///
											"`del_z'",			///
											"`var_del'",		///
											"`pi_z'",			///
											"`var_pi_z'",		///
											"`var_pidel_z'",	///
											"`var_beta'",		///
											`ivbeta1',			///
											`ivbeta2',			///
											`null',				///
											`beta2hat')
		}
		scalar `ar_chi2'=r(ar_chi2)
		scalar `k_chi2'=r(k_chi2)
		scalar `j_chi2'=r(j_chi2)
		scalar `clr_stat'=r(clr_stat)
		scalar `rk'=r(rk)
*		scalar `wald_chi2'=r(wald_chi2)
		scalar `wald_chi2' = ((`ivbeta1'-(`null'))/`ivbetase1')^2
		local nullstring "`null'"

* calculate test statistics, p-values, and rejection indicators from above matrices
		compute_pvals,								///
						null("`nullstring'")		///
						rk(`rk')					///
						nexexog(`nexexog')			///
						nendog(`nendog')			///
						nsendog(`nsendog')			///
						level(`level')				///
						kj_level(`kj_level')		///
						j_level(`j_level')			///
						ar_level(`ar_level')		///
						ar_p(`ar_p')				///
						ar_chi2(`ar_chi2')			///
						k_p(`k_p')					///
						k_chi2( `k_chi2' )			///
						j_p(`j_p')					///
						j_chi2(`j_chi2')			///
						clr_p(`clr_p')				///
						clr_stat(`clr_stat')		///
						ar_df(`ar_df')				///
						k_df(`k_df')				///
						j_df(`j_df')				///
						clr_df(`clr_df')			///
						ar_r(`ar_r')				///
						k_r(`k_r')					///
						j_r(`j_r')					///
						kj_dnr(`kj_dnr')			///
						kj_r(`kj_r')				///
						kj_p(`kj_p')				///
						clr_r(`clr_r')				///
						wald_p(`wald_p')			///
						wald_chi2(`wald_chi2')		///
						wald_r(`wald_r')			///
						wald_df(`wald_df')			///
						kwt(`kwt')
		if `ci' {
			local wald_x1=`ivbeta1'-`ivbetase1'*invnormal((100+`level')/200)
			local wald_x2=`ivbeta1'+`ivbetase1'*invnormal((100+`level')/200)
			local wald_cset : di "["  %8.0g `wald_x1' "," %8.0g `wald_x2' "]"
		}

	}	// end K=1weak/1strong block

*********************************** K=2 ******************************************************

	if `nendog'==2 & `nsendog'==0 {

		local endo1   : word 1 of `endo'
		local endo2   : word 2 of `endo'
		local endo1_t : word 1 of `endo_t'
		local endo2_t : word 2 of `endo_t'

* For Wald tests and construction of stats and grids
		_estimates unhold `waldmodel'
		local ivbeta1=_b[`endo1']
		local ivbeta2=_b[`endo2']
		local ivbetase1=_se[`endo1']
		local ivbetase2=_se[`endo2']
		mat `var_beta'=e(V)
		mat `var_beta'=`var_beta'[1..2,1..2]
		_estimates hold `waldmodel'

		if `cons' {													//  cons=1 if constant in model after partialling-out
			tempvar ones											//  cons=0 if no constant or constant has been partialled out
			qui gen byte `ones' = 1 if `touse'
		}

* RF estimations, IID case
		if `iid' & (`forcerobust'==0) {
			qui reg `endo1_t' `exexog_t' `inexog_t' if `touse' `wtexp', `noconstant'
			qui predict double `vhat1' if `touse', residuals
			mata: `bhat' = st_matrix("e(b)")
			mata: `pi_z1' = `bhat'[| 1,1 \ .,`nexexog' |]
			mata: `pi_z1' = `pi_z1''
			qui reg `endo2_t' `exexog_t' `inexog_t' if `touse' `wtexp', `noconstant'
			qui predict double `vhat2' if `touse', residuals
			mata: `bhat' = st_matrix("e(b)")
			mata: `pi_z2' = `bhat'[| 1,1 \ .,`nexexog' |]
			mata: `pi_z2' = `pi_z2''
			mata: `pi_z' = `pi_z1' , `pi_z2'
			mata: st_matrix("r(`pi_z')",`pi_z')
			mat `pi_z'=r(`pi_z')
			mata: mata drop `pi_z'
* Above as in ET paper p. 9 step 1 to obtain.  Notation for pi_z and vhat1, vhat2 matches.
			local df_r=`e(df_r)' - `npartial'							//  df_r needs to exclude #partialled-out vars
			local reg_df_r=`e(df_r)'									//  reg_df_r is used for recovering large-sample V
* avar automatically handles dofminus adjustment
			cap avar (`vhat1' `vhat2') (`exexog_t' `inexog_t' `ones') if `touse' `wtexp', nocons dofminus(`dofminus')
			if _rc>0 {
				di "error - internal call to avar failed"
				exit _rc
			}

			mata: `S'=st_matrix("r(S)")
			qui mat accum `zz' = `exexog_t' `inexog_t' `ones' if `touse' `wtexp', noconstant
			mata: `zz'=st_matrix("`zz'")
			mata: `zzinv'=invsym(`zz')
			mata: `var_pi_z' = `N' * makesymmetric(I(2)#`zzinv'*`S'*I(2)#`zzinv')
			mata: `var_pi_z11' = `var_pi_z'[| 1,1 \ `nexexog',`nexexog' |]
			mata: `var_pi_z22' = `var_pi_z'[| `ninexog'+`nexexog'+1,`ninexog'+`nexexog'+1 \ `ninexog'+2*`nexexog',`ninexog'+2*`nexexog' |]
			mata: `var_pi_z12' = `var_pi_z'[| `ninexog'+`nexexog'+1,1 \ `ninexog'+2*`nexexog',`nexexog' |]
			mata: `var_pi_z' = (`var_pi_z11', `var_pi_z12'') \ (`var_pi_z12', `var_pi_z22')
			mata: st_matrix("r(`var_pi_z')",`var_pi_z')
			mat `var_pi_z'=r(`var_pi_z')
			mata: mata drop `var_pi_z' `var_pi_z11' `var_pi_z22' `var_pi_z12' `zz' `zzinv'
* Above as in ET paper, p. 9 step 1 to obtain.  Notation for var_pi_z in paper is Lambda_piz_piz.

* Below matches ET paper, p. 9 step 2 control function. W in paper is inexog here.
* Do not need to save coeff or variance of W.  Coeffs and variance match notation in paper.
* delta_z and delta_v are column vectors of coeffs on exexog Z and vhats, respectively.
* var_del is variance of delta_z ONLY, so dim is nexexog x nexexog
			if "`model'" == "ivtobit" {
				qui tobit `depvar_t' `exexog_t' `vhat1' `vhat2' `inexog_t' if `touse' `wtexp', `llopt' `ulopt'
			}
			else if "`model'" == "ivprobit" {
				qui probit `depvar_t' `exexog_t' `vhat1' `vhat2' `inexog_t' if `touse' `wtexp', `asis'
			}
			else {
				qui reg `depvar_t' `exexog_t' `vhat1' `vhat2' `inexog_t' if `touse' `wtexp', `noconstant'
			}
			mat `var_del'=e(V)
			mat `var_del'= `var_del'[1..`nexexog',1..`nexexog']
			mat `var_del' = ((`reg_df_r'-2)/`N')*`var_del'				//  recover large-sample V; (df_r-2) because
																		//  of inclusion of vhat1 and vhat2 in RF regression
			mat `var_del' = `var_del' * `N'/(`N'-`dofminus')			//  dofminus (large-sample) adjustment
			mat `bhat'=e(b)
			mat `del_z'=`bhat'[1...,1..`nexexog']
			mat `del_z'=`del_z''
			mat `del_v'=`bhat'[1...,`nexexog'+1..`nexexog'+2]
			mat `del_v'=`del_v''

			mat `var_pi_z' = `var_pi_z'	* `ssa'							//  ssa is small-sample adjustment or 1
			mat `var_del' = `var_del' * `ssa'
			if `lm' {													//  all of inexog will have been partialled out for LM method
				qui reg `depvar_t' `exexog_t' if `touse' `wtexp', noconstant
				qui predict double `ehat' if `touse', resid
				qui mat accum `AA' = `depvar_t' `endo1_t' `endo2_t' `vhat1' `vhat2' `ehat'  if `touse' `wtexp', noconstant
				matrix `syy'	= `AA'[1,1]       * 1/(`N'-`dofminus') * `ssa'
				matrix `see'	= `AA'[6,6]       * 1/(`N'-`dofminus') * `ssa'
				matrix `sxx'	= `AA'[2..3,2..3] * 1/(`N'-`dofminus') * `ssa'
				matrix `sxy'	= `AA'[2..3,1..1] * 1/(`N'-`dofminus') * `ssa'
				matrix `syv'	= `AA'[4..5,1..1] * 1/(`N'-`dofminus') * `ssa'
				matrix `svv'	= `AA'[4..5,4..5] * 1/(`N'-`dofminus') * `ssa'
				matrix `sve'	= `AA'[4..5,6..6] * 1/(`N'-`dofminus') * `ssa'
*				matrix `sxe'	= `AA'[2..3,6..6] * 1/(`N'-`dofminus') * `ssa'		//  same as sve
			}
		}																// end iid code
		else {															// robust/non-iid case
			qui reg `depvar_t' `exexog_t' `inexog_t' if `touse' `wtexp', `noconstant'
			mata: `bhat' = st_matrix("e(b)")
			mata: `del_z' = `bhat'[| 1,1 \ .,`nexexog' |]
* COLUMN vector
			mata: `del_z' = `del_z''
			qui predict double `uhat' if `touse', resid

			qui reg `endo1_t' `exexog_t' `inexog_t' if `touse' `wtexp', `noconstant'
			qui predict double `vhat1' if `touse', resid
			mata: `bhat' = st_matrix("e(b)")
			mata: `pi_z1' = `bhat'[| 1,1 \ .,`nexexog' |]
* COLUMN vector
			mata: `pi_z1' = `pi_z1''
			qui reg `endo2_t' `exexog_t' `inexog_t' if `touse' `wtexp', `noconstant'
			qui predict double `vhat2' if `touse', resid
			mata: `bhat' = st_matrix("e(b)")
			mata: `pi_z2' = `bhat'[| 1,1 \ .,`nexexog' |]
* COLUMN vector
			mata: `pi_z2' = `pi_z2''
* COMBINED
			mata: `pi_z' = `pi_z1' , `pi_z2'

			if `lm' {
				cap avar (`depvar_t' `endo1_t' `endo2_t') (`exexog_t' `inexog_t' `ones') if `touse' `wtexp', `vceopt' nocons dofminus(`dofminus')			
			}
			else {
				cap avar (`uhat' `vhat1' `vhat2') (`exexog_t' `inexog_t' `ones') if `touse' `wtexp', `vceopt' nocons dofminus(`dofminus')
			}
			if _rc>0 {
				di "error - internal call to avar failed"
				exit _rc
			}
	
			mata: `S'=st_matrix("r(S)")
			mata: `S11'=`S'[| 1,1 \ `nexexog'+`ninexog',`nexexog'+`ninexog' |]
			mata: `S12'=`S'[| `nexexog'+`ninexog'+1,1 \ rows(`S'),`nexexog'+`ninexog' |]
			mata: `S22'=`S'[| `nexexog'+`ninexog'+1, `nexexog'+`ninexog'+1 \ rows(`S'),cols(`S') |]
	
			qui mat accum `zz' = `exexog_t' `inexog_t' `ones' if `touse' `wtexp', noconstant
			mata: `zz'=st_matrix("`zz'")
			mata: `zzinv'=invsym(`zz')
	
			mata: `var_del' = `N' * makesymmetric(`zzinv'*`S11'*`zzinv') * `ssa'		// ssa is small-sample adjustment or 1
			mata: `var_del'=`var_del'[| 1,1 \ `nexexog',`nexexog' |]
	
* Kronecker structure
			mata: `var_pi_z' = `N' * makesymmetric(I(2)#`zzinv'*`S22'*I(2)#`zzinv') * `ssa'
			mata: `var_pi_z11' = `var_pi_z'[| 1,1 \ `nexexog',`nexexog' |]
			mata: `var_pi_z22' = `var_pi_z'[| `ninexog'+`nexexog'+1,`ninexog'+`nexexog'+1 \ `ninexog'+2*`nexexog',`ninexog'+2*`nexexog' |]
			mata: `var_pi_z12' = `var_pi_z'[| `ninexog'+`nexexog'+1,1 \ `ninexog'+2*`nexexog',`nexexog' |]
			mata: `var_pi_z' = (`var_pi_z11', `var_pi_z12'') \ (`var_pi_z12', `var_pi_z22')
	
* Kronecker structure
			mata: `var_pidel_z' = `N' * I(2)#`zzinv'*`S12'*`zzinv' * `ssa'
			mata: `var_pidel_z1' = `var_pidel_z'[| 1,1 \ `nexexog',`nexexog' |]
			mata: `var_pidel_z2' = `var_pidel_z'[| `ninexog'+`nexexog'+1,1 \ `ninexog'+2*`nexexog',`nexexog' |]
			mata: `var_pidel_z' = `var_pidel_z1' \ `var_pidel_z2'
	
			mata: st_matrix("r(`del_z')",`del_z')
			mata: st_matrix("r(`pi_z')",`pi_z')
			mata: st_matrix("r(`var_del')",`var_del')
			mata: st_matrix("r(`var_pi_z')",`var_pi_z')
			mata: st_matrix("r(`var_pidel_z')",`var_pidel_z')
			mat `del_z'=r(`del_z')
			mat `pi_z'=r(`pi_z')
			mat `var_del'=r(`var_del')
			mat `var_pi_z'=r(`var_pi_z')
			mat `var_pidel_z'=r(`var_pidel_z')
	
			mata: mata drop `zz' `zzinv' `S' `S11' `S12' `S22' `bhat'			// clean up Mata memory
			mata: mata drop `del_z' `var_del' `var_pi_z' `var_pi_z11' `var_pi_z12' `var_pi_z22'
			mata: mata drop `pi_z' `pi_z1' `pi_z2' `var_pidel_z' `var_pidel_z1' `var_pidel_z2'

		}		// end robust/non-iid code

* Construct table for confidence sets if requested or needed for graphs
		if `usegrid' {
			construct_ci2,					///
				iid(`iid')					///
				usegrid(`usegrid')			///
				depvar(`depvar_t')			///
				endo1(`endo1_t')			///
				endo2(`endo2_t')			///
				exexog(`exexog_t')			///
				inexog(`inexog_t')			///
				touse (`touse')				///
				wtexp(`wtexp')				///
				`noconstant'				///
				nexexog(`nexexog')			///
				nendog(`nendog')			///
				nsendog(`nsendog')			///
				overid(`overid')			///
				level(`level')				///
				kj_level(`kj_level')		///
				j_level(`j_level')			///
				ar_level(`ar_level')		///
				alpha(`alpha')				///
				kwt(`kwt')					///
				n(`N')						///
				grid(`grid')				///
				gridlimits1(`gridlimits1')	///
				gridlimits2(`gridlimits2')	///
				gridmult(`gridmult')		///
				points1(`points1')			///
				points2(`points2')			///
				ivbeta1(`ivbeta1')			///
				ivbeta2(`ivbeta2')			///
				ivbetase1(`ivbetase1')		///
				ivbetase2(`ivbetase2')		///
				var_pi_z(`var_pi_z')		///
				pi_z(`pi_z')				///
				var_del(`var_del')			///
				del_z(`del_z')				///
				del_v(`del_v')				///
				var_pidel_z(`var_pidel_z')	///
				var_beta(`var_beta')		///
				syy(`syy')					///
				see(`see')					///
				sxy(`sxy')					///
				sve(`sve')					///
				sxx(`sxx')					///
				svv(`svv')					///
				lm(`lm')					///
				forcerobust("`forcerobust'")
	
			mat `citable'=r(citable)
			local grid_description "`r(grid_description)'"
			local points1 "`r(points1)'"
			local points2 "`r(points2)'"
		}

* Test specified null
		if `iid' & (`forcerobust'==0) {
			computeivtests_iid2,			///
				var_pi_z(`var_pi_z')		///
				pi_z(`pi_z')				///
				var_del(`var_del')			///
				del_z(`del_z')				///
				del_v(`del_v')				///
				ivbeta1(`ivbeta1')			///
				ivbeta2(`ivbeta2')			///
				var_beta(`var_beta')		///
				null1(`null1')				///
				null2(`null2')				///
				nexexog(`nexexog')			///
				syy(`syy')					///
				see(`see')					///
				sxy(`sxy')					///
				sve(`sve')					///
				sxx(`sxx')					///
				svv(`svv')					///
				lm(`lm')
		}
		else {
				mata: computeivtests_robust2(	///
					"`del_z'",					///
					"`var_del'",				///
					"`pi_z'",					///
					"`var_pi_z'",				///
					"`var_pidel_z'",			///
					"`var_beta'",				///
					`ivbeta1',					///
					`ivbeta2',					///
					`null1',					///
					`null2')
		}
		scalar `wald_chi2'=r(wald_chi2)
		scalar `ar_chi2'=r(ar_chi2)
		scalar `k_chi2'=r(k_chi2)
		scalar `j_chi2'=r(j_chi2)
		scalar `clr_stat'=r(clr_stat)
		scalar `rk'=r(rk)
		local nullstring "`null'"

* calculate test statistics, p-values, and rejection indicators from above matrices
		compute_pvals,					///
			null("`nullstring'")		///
			rk(`rk')					///
			nexexog(`nexexog')			///
			nendog(`nendog')			///
			nsendog(`nsendog')			///
			level(`level')				///
			kj_level(`kj_level')		///
			j_level(`j_level')			///
			ar_level(`ar_level')		///
			ar_p(`ar_p')				///
			ar_chi2(`ar_chi2')			///
			k_p(`k_p')					///
			k_chi2(`k_chi2' )			///
			j_p(`j_p')					///
			j_chi2(`j_chi2')			///
			clr_p(`clr_p')				///
			clr_stat(`clr_stat')		///
			ar_df(`ar_df')				///
			k_df(`k_df')				///
			j_df(`j_df')				///
			clr_df(`clr_df')			///
			ar_r(`ar_r')				///
			k_r(`k_r')					///
			j_r(`j_r')					///
			kj_dnr(`kj_dnr')			///
			kj_r(`kj_r')				///
			kj_p(`kj_p')				///
			clr_r(`clr_r')				///
			wald_p(`wald_p')			///
			wald_chi2(`wald_chi2')		///
			wald_r(`wald_r')			///
			wald_df(`wald_df')			///
			kwt(`kwt')

	}	// end K=2 block

*********************************** K=1 ******************************************************

	if `nendog'==1 {
* For Wald tests and construction of stats
		_estimates unhold `waldmodel'
		local ivbeta=_b[`endo']
		local ivbetase=_se[`endo']
		_estimates hold `waldmodel'
	
* RF estimations, IID case
		if `iid' & (`forcerobust'==0) {
			qui reg `endo_t' `exexog_t' `inexog_t' if `touse' `wtexp', `noconstant'
			qui predict double `vhat' if `touse', residuals
* Not needed?
*			local df_r=`e(df_r)' - `npartial'							//  df_r needs to exclude #partialled-out vars
			local reg_df_r=`e(df_r)'									//  reg_df_r is used for recovering large-sample V
			mat `var_pi_z'=e(V)
			mat `var_pi_z' = `var_pi_z'[1..`nexexog',1..`nexexog']
			mat `var_pi_z' = `reg_df_r'/`N'*`var_pi_z'					//  recover large-sample V
			mat `var_pi_z' = `var_pi_z' * `N'/(`N'-`dofminus')
* pi_z is big pi_z in paper
			mat `pi_z'=e(b)
			mat `pi_z'=`pi_z'[1...,1..`nexexog']
			if "`model'" == "ivtobit" {
				qui tobit `depvar_t' `exexog_t' `vhat' `inexog_t' if `touse' `wtexp', `llopt' `ulopt'
			}
			else if "`model'" == "ivprobit" {
				qui probit `depvar_t' `exexog_t' `vhat' `inexog_t' if `touse' `wtexp', `asis'
			}
			else {
				qui reg `depvar_t' `exexog_t' `vhat' `inexog_t' if `touse' `wtexp', `noconstant'
			}
			mat `var_del'=e(V)
			mat `var_del'= `var_del'[1..`nexexog',1..`nexexog']
			mat `var_del' = ((`reg_df_r'-1)/`N')*`var_del'				//  recover large-sample V; (df_r-1) because
																		//  of inclusion of vhat in RF regression
			mat `var_del' = `var_del' * `N'/(`N'-`dofminus')			//  dofminus (large-sample) adjustment
			mat `bhat'=e(b)
* del_z is little pi_z in paper
			mat `del_z'=`bhat'[1...,1..`nexexog']
			mat `del_v'=`bhat'[1...,`nexexog'+1..`nexexog'+1]
			mat `var_pi_z' = `var_pi_z'	* `ssa'							//  ssa is small-sample adjustment or 1
			mat `var_del' = `var_del' * `ssa'
			if `lm' {													//  all of inexog will have been partialled out for LM method
				qui reg `depvar_t' `exexog_t' if `touse' `wtexp', noconstant
				qui predict double `ehat' if `touse', resid
				qui mat accum `AA' = `depvar_t' `endo_t' `vhat' `ehat'  if `touse' `wtexp', noconstant
				scalar `syy'	= `AA'[1,1] * 1/(`N'-`dofminus') * `ssa'
				scalar `see'	= `AA'[4,4] * 1/(`N'-`dofminus') * `ssa'
				scalar `sxx'	= `AA'[2,2] * 1/(`N'-`dofminus') * `ssa'
				scalar `sxy'	= `AA'[2,1] * 1/(`N'-`dofminus') * `ssa'
				scalar `syv'	= `AA'[3,1] * 1/(`N'-`dofminus') * `ssa'
				scalar `svv'	= `AA'[3,3] * 1/(`N'-`dofminus') * `ssa'
				scalar `sve'	= `AA'[3,4] * 1/(`N'-`dofminus') * `ssa'
*				scalar `sxe'	= `AA'[2,4] * 1/(`N'-`dofminus') * `ssa'		// same as sve
			}
		}
		else {
* RF estimations, non-iid case (linear model only)
			if `cons' {													//  cons=1 if constant in model after partialling-out
				tempvar ones											//  cons=1 if no constant or constant has been partialled out
				qui gen byte `ones' = 1 if `touse'
			}
			qui reg `depvar_t' `exexog_t' `inexog_t' if `touse' `wtexp', `noconstant'
			mata: `bhat' = st_matrix("e(b)")
			mata: `del_z' = `bhat'[| 1,1 \ .,`nexexog' |]
			qui predict double `uhat' if `touse', residuals
			qui reg `endo_t' `exexog_t' `inexog_t' if `touse' `wtexp', `noconstant'
			qui predict double `vhat' if `touse', residuals
			mata: `bhat' = st_matrix("e(b)")
			mata: `pi_z' = `bhat'[| 1,1 \ .,`nexexog' |]
			if `lm' {
				cap avar (`depvar_t' `endo_t') (`exexog_t' `inexog_t' `ones') if `touse' `wtexp', `vceopt' nocons dofminus(`dofminus')
			}
			else {
				cap avar (`uhat' `vhat') (`exexog_t' `inexog_t' `ones') if `touse' `wtexp', `vceopt' nocons dofminus(`dofminus')
			}
			if _rc>0 {
				di "error - internal call to avar failed"
				exit _rc
			}
			mata: `S'=st_matrix("r(S)")
			mata: `S11'=`S'[| 1,1 \ `nexexog'+`ninexog',`nexexog'+`ninexog' |]
			mata: `S12'=`S'[| `nexexog'+`ninexog'+1,1 \ rows(`S'),`nexexog'+`ninexog' |]
			mata: `S22'=`S'[| `nexexog'+`ninexog'+1, `nexexog'+`ninexog'+1 \ rows(`S'),cols(`S') |]
			qui mat accum `zz' = `exexog_t' `inexog_t' `one' if `touse' `wtexp', `noconstant'
			mata: `zz'=st_matrix("`zz'")
			mata: `zzinv'=invsym(`zz')
			mata: `var_del' = `N' * makesymmetric(`zzinv'*`S11'*`zzinv') * `ssa'		// ssa is small-sample adjustment or 1
			mata: `var_del'=`var_del'[| 1,1 \ `nexexog',`nexexog' |]
			mata: `var_pi_z' = `N' * makesymmetric(`zzinv'*`S22'*`zzinv') * `ssa'
			mata: `var_pi_z'=`var_pi_z'[| 1,1 \ `nexexog',`nexexog' |]
			mata: `var_pidel_z' = `N' * `zzinv'*`S12'*`zzinv'
			mata: `var_pidel_z'=`var_pidel_z'[| 1,1 \ `nexexog',`nexexog' |] * `ssa'
			mata: st_matrix("r(del_z)",`del_z')
			mata: st_matrix("r(pi_z)",`pi_z')
			mata: st_matrix("r(var_del)",`var_del')
			mata: st_matrix("r(var_pi_z)",`var_pi_z')
			mata: st_matrix("r(var_pidel_z)",`var_pidel_z')
			mat `del_z'=r(del_z)
			mat `pi_z'=r(pi_z)
			mat `var_del'=r(var_del)
			mat `var_pi_z'=r(var_pi_z)
			mat `var_pidel_z'=r(var_pidel_z)
			mata: mata drop `zz' `zzinv' `S' `S11' `S12' `S22' `bhat'			// clean up Mata memory
			mata: mata drop `del_z' `pi_z' `var_del' `var_pi_z' `var_pidel_z'
		}

		if `ci' | `usegrid' {				//  default is to construct CI
	
			construct_ci,					///
				iid(`iid')					///
				usegrid(`usegrid')			///
				depvar(`depvar_t')			///
				endo(`endo_t')				///
				exexog(`exexog_t')			///
				inexog(`inexog_t')			///
				touse (`touse')				///
				wtexp(`wtexp')				///
				`noconstant'				///
				nexexog(`nexexog')			///
				nendog(`nendog')			///
				nsendog(`nsendog')			///
				ssa(`ssa')					///
				dofminus(`dofminus')		///
				overid(`overid')			///
				level(`level')				///
				kj_level(`kj_level')		///
				j_level(`j_level')			///
				ar_level(`ar_level')		///
				alpha(`alpha')				///
				kwt(`kwt')					///
				n(`N')						///
				grid(`grid')				///
				gridlimits(`gridlimits')	///
				gridmult(`gridmult')		///
				points(`points')			///
				ivbeta(`ivbeta')			///
				ivbetase(`ivbetase')		///
				var_pi_z(`var_pi_z')		///
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
				forcerobust("`forcerobust'")
			local ar_cset "`r(ar_cset)'"
			local clr_cset "`r(clr_cset)'"
			local k_cset "`r(k_cset)'"
			local kj_cset "`r(kj_cset)'"
			local j_cset "`r(j_cset)'"
			mat `citable'=r(citable)
	
			local grid_description "`r(grid_description)'"
			local points "`r(points)'"		//  In case grid provided, points=#elements in grid
	
		}	//  end construction of confidence interval

* Test specified null
* calculate test stats
		if `iid' & (`forcerobust'==0) {
			computeivtests_iid,				///
				var_pi_z(`var_pi_z')		///
				pi_z(`pi_z')				///
				var_del(`var_del')			///
				del_z(`del_z')				///
				del_v(`del_v')				///
				ivbeta(`ivbeta')			///
				ivbetase(`ivbetase')		///
				null(`null')				///
				syy(`syy')					///
				see(`see')					///
				sxy(`sxy')					///
				sve(`sve')					///
				sxx(`sxx')					///
				svv(`svv')					///
				lm(`lm')
		}
		else {
			mata: computeivtests_robust(	///
				"`del_z'",					///
				"`var_del'",				///
				"`pi_z'",					///
				"`var_pi_z'",				///
				"`var_pidel_z'",			///
				`ivbeta',					///
				`ivbetase',					///
				`null')
			local `npd'=max(`npd',r(npd))
		}
		scalar `ar_chi2'=r(ar_chi2)
		scalar `k_chi2'=r(k_chi2)
		scalar `j_chi2'=r(j_chi2)
		scalar `clr_stat'=r(clr_stat)
		scalar `rk'=r(rk)
		scalar `wald_chi2'=r(wald_chi2)
		local nullstring "`null'"

* calculate test statistics, p-values, and rejection indicators from above matrices
		compute_pvals,					///
			null("`nullstring'")		///
			rk(`rk')					///
			nexexog(`nexexog')			///
			nendog(`nendog')			///
			nsendog(`nsendog')			///
			level(`level')				///
			kj_level(`kj_level')		///
			j_level(`j_level')			///
			ar_level(`ar_level')		///
			ar_p(`ar_p')				///
			ar_chi2(`ar_chi2')			///
			k_p(`k_p')					///
			k_chi2(`k_chi2' )			///
			j_p(`j_p')					///
			j_chi2(`j_chi2')			///
			clr_p(`clr_p')				///
			clr_stat(`clr_stat')		///
			ar_df(`ar_df')				///
			k_df(`k_df')				///
			j_df(`j_df')				///
			clr_df(`clr_df')			///
			ar_r(`ar_r')				///
			k_r(`k_r')					///
			j_r(`j_r')					///
			kj_dnr(`kj_dnr')			///
			kj_r(`kj_r')				///
			kj_p(`kj_p')				///
			clr_r(`clr_r')				///
			wald_p(`wald_p')			///
			wald_chi2(`wald_chi2')		///
			wald_r(`wald_r')			///
			wald_df(`wald_df')			///
			kwt(`kwt')

		if `ci' {
			local wald_x1=`ivbeta'-`ivbetase'*invnormal((100+`level')/200)
			local wald_x2=`ivbeta'+`ivbetase'*invnormal((100+`level')/200)
			local wald_cset : di "["  %8.0g `wald_x1' "," %8.0g `wald_x2' "]"
		}

	}	// end K=1 block

************************ RESTORE IF PRESERVED ***************************************
* If partialling out or XT-transformed, will have preserved pre-transformation data.
	if `npartial'>0 | "`xtmodel'"~="" {
		capture restore
	}

************************ DISPLAY/POST/GRAPH RESULTS *********************************
	ereturn post , dep(`depvar') obs(`N') esample(`touse')

	ereturn scalar	endog_ct			=`nendog'
	ereturn scalar	wendog_ct			=`nwendog'		// also used as flag for K=1 or K=2 case
	ereturn scalar	sendog_ct			=`nsendog'
	ereturn local	cmd 				"weakiv"
	ereturn local	depvar				"`depvar'"
	ereturn local	endo				"`endo'"
	ereturn local	wendo				"`wendo'"
	ereturn local	sendo				"`sendo'"
	ereturn local	endo1				"`endo1'"
	ereturn local	endo2				"`endo2'"
	ereturn local	exexog				"`exexog'"
	ereturn local	inexog				"`inexog'"
	ereturn scalar	wald_chi2			=`wald_chi2'
	ereturn scalar	wald_p				=`wald_p'
	ereturn scalar	wald_df				=`wald_df'
	ereturn scalar	ar_chi2				=`ar_chi2'
	ereturn scalar	ar_p				=`ar_p'
	ereturn scalar	ar_df				=`ar_df'
	ereturn scalar	ar_level			=`ar_level'
	ereturn scalar	wald_level			=`wald_level'
	if `overid' {
		ereturn scalar	clr_stat		=`clr_stat'
		ereturn scalar	clr_p			=`clr_p'
		ereturn scalar	k_chi2			=`k_chi2'
		ereturn scalar	k_p				=`k_p'
		ereturn scalar	k_df			=`k_df'
		ereturn scalar	j_chi2			=`j_chi2'
		ereturn scalar	j_p				=`j_p'
		ereturn scalar	j_df			=`j_df'
		ereturn scalar	kj_p			=`kj_p'
		ereturn scalar	clr_level		=`clr_level'
		ereturn scalar	k_level			=`k_level'
		ereturn scalar	j_level			=`j_level'
		ereturn scalar	kj_level		=`kj_level'
		ereturn scalar	kjk_level		=`kjk_level'
		ereturn scalar	kjj_level		=`kjj_level'
		ereturn scalar	kwt				=`kwt'
	}
	ereturn scalar	rk					=`rk'
	ereturn scalar	N					=`N'
	if "`N_clust'"~="" {
		ereturn scalar	N_clust			=`N_clust'
		ereturn local	clustvar		"`clustvar'"
	}
	if "`N_clust1'"~="" {
		ereturn scalar	N_clust1		=`N_clust1'
		ereturn scalar	N_clust2		=`N_clust2'
	}
	if "`xtmodel'"~="" {
		ereturn local	xtmodel			"`xtmodel'"
		ereturn scalar	N_g				=`N_g'
		ereturn scalar singleton		=`singleton'
	}
	if `e(wendog_ct)'==1 {
		ereturn scalar	null			=`null'
	}
	else {
		ereturn scalar	null1			=`null1'
		ereturn scalar	null2			=`null2'
	}
	if `ci' {
		ereturn local	wald_cset		"`wald_cset'"
		ereturn local	ar_cset			"`ar_cset'"
		if `overid' {
			ereturn local	clr_cset	"`clr_cset'"
			ereturn local	k_cset		"`k_cset'"
			ereturn local	j_cset		"`j_cset'"
			ereturn local	kj_cset		"`kj_cset'"
		}
	}
	if `usegrid' {
		ereturn matrix	citable				=`citable'
		ereturn local	grid_description	"`grid_description'"
		if `e(wendog_ct)'==1 {
			ereturn scalar	points			=`points'
		}
		else {
			ereturn scalar	points1			=`points1'
			ereturn scalar	points2			=`points2'
		}
	}
	ereturn scalar	overid				=`overid'
	ereturn scalar	alpha				=`alpha'
	ereturn local	level				"`level'"
	ereturn local	levellist			"`levellist'"			// level used for tests (if more than one level provided)
	ereturn local	ivtitle				"`ivtitle'"
	ereturn local	note1				"`note1'"
	ereturn local	note2				"`note2'"
	ereturn local	note3				"`note3'"
	ereturn local	model				"`model'"
	ereturn scalar	grid				=`usegrid'
	ereturn scalar	ci					=`ci'
	ereturn scalar	small				=("`small'"~="")
	ereturn scalar	npd					=`npd'
	if `lm'	{
		ereturn local method			"lm"
	}
	else {
		ereturn local method			"md"
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
		if `e(wendog_ct)'==1 {
			do_graphs,						///
				graph(`graph')				///
				graphxrange(`graphxrange')	///
				graphopt(`graphopt')		///
				levellist(`levellist')
		}
		else {
			do_graphs2,						///
				graph(`graph')				///
				contouronly(`contouronly')	///
				surfaceonly(`surfaceonly')	///
				contouropt(`contouropt')	///
				surfaceopt(`surfaceopt')	///
				graphopt(`graphopt')		///
				levellist(`levellist')		///
				arlevel(`ar_level')			///
				jlevel(`j_level')			///
				kjlevel(`kj_level')
		}
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

program checkversion_avar
	version 10.1
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

*********************************************************************************

program define weakiv_estadd, eclass
	version 10.1
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

* Make Wald model the current set of estimates
	_estimates unhold `waldmodel'

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
	version 10.1
	syntax [,												///
				graph(string)								///
				graphxrange(numlist ascending min=2 max=2)	///
				graphopt(string asis)						///			
				levellist(numlist min=0 max=3)				///
			]

		tempname citable
		mat `citable'=e(citable)
		if `citable'[1,1]==. {
di as err "error: missing saved CI table e(citable) - cannot generate graphs"
			exit 1000
		}
		
* Graph list can be mixed or upper case; convert to lower case
		local graph = lower("`graph'")
* "all" means all 6 or all 2
		local all : list posof "all" in graph
		if `all'>0 {
			if `e(overid)' {
				local graph "ar clr k j kj wald"
			}
			else {
				local graph "ar wald"
			}
		}

		if `e(overid)' {
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

		local points = `e(points)'
* To be graphed, stats need to be variables. Check to see if #obs in current dataset is sufficient.
		qui desc, short
		if `points' > `r(N)' {
			preserve
			qui set obs `points'
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
		local counter = 1
		while `counter' <= `points' {
			local gridnull = `citable'[`counter',colnumb(`citable',"null")]
				qui replace `xvar'    = `gridnull'                                           in `counter'
				qui replace `ar_rf'   = 1 - `citable'[`counter',colnumb(`citable',"ar_p")]   in `counter'
				qui replace `wald_rf' = 1 - `citable'[`counter',colnumb(`citable',"wald_p")] in `counter'
			if `e(overid)' {
				qui replace `k_rf'    = 1 - `citable'[`counter',colnumb(`citable',"k_p")]    in `counter'
				qui replace `clr_rf'  = 1 - `citable'[`counter',colnumb(`citable',"clr_p")]  in `counter'
				qui replace `j_rf'    = 1 - `citable'[`counter',colnumb(`citable',"j_p")]    in `counter'
				qui replace `kj_rf'   = 1 - `citable'[`counter',colnumb(`citable',"kj_p")]   in `counter'
			}
		local ++counter
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
		scatter `allstats' `xvar' if _n<`counter' `xrange',		///
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
	version 10.1
	syntax [,												///
				graph(string)								///
				CONTOURonly(string)							///
				SURFACEonly(string)							///
				contouropt(string asis)						///
				surfaceopt(string asis)						///
				graphopt(string asis)						///
				levellist(numlist min=0 max=3)				///
				arlevel(numlist min=1 max=1)				/// AR, KJ and J can have their own levels
				jlevel(numlist min=1 max=1)					///
				kjlevel(numlist min=1 max=1)				/// Graphing KJ allows specification of composite KJ level only
			]

		local contour	=( ("`contouronly'"=="contouronly") | ("`contouronly'`surfaceonly'"=="") )
		local surface	=( ("`surfaceonly'"=="surfaceonly") | ("`contouronly'`surfaceonly'"=="") )

* Check software for K=2 graphing
* Stata version 12 or greater required for contour	
* surface by Adrian Mander required for surface

		if `contour' {
			if c(stata_version)<12 {
di as err "error - must have Stata version 12 or later for contour plot of confidence set"
di as err "Use -surfaceonly- option to skip contour plot"
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

		tempname citable
		mat `citable'=e(citable)
		if `citable'[1,1]==. {
di as err "error: missing saved CI table e(citable) - cannot generate graphs"
			exit 1000
		}
		
* Graph list can be mixed or upper case; convert to lower case
* CLR NOT CURRENTLY SUPPORTED
		local graph = lower("`graph'")
* "all" means all 5 or all 2
		local all : list posof "all" in graph
		if `all'>0 {
			if `e(overid)' {
				local graph "ar k j kj wald"
			}
			else {
				local graph "ar wald"
			}
		}

		if `e(overid)' {
			local legalgraphs "wald ar k j kj"
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

		local rows = `e(points1)' * `e(points2)'
* To be graphed, stats need to be variables. Check to see if #obs in current dataset is sufficient.
		qui desc, short
		if `rows' > `r(N)' {
			preserve
			qui set obs `rows'
			local pflag 1
		}
		else {
			local pflag 0
		}

		tempvar xvar yvar
		tempvar ar_rf k_rf clr_rf j_rf wald_rf kj_rf
		qui gen `xvar'		= .
		qui gen `yvar'		= .
		qui gen `ar_rf'		= .
		qui gen `k_rf'		= .
*		qui gen `clr_rf'	= .
		qui gen `j_rf'		= .
		qui gen `kj_rf'		= .
		qui gen `wald_rf'	= .
		label var `xvar'    "H0: beta1=x (beta2=y)"
		label var `yvar'	"H0: beta2=y (beta1=x)"
		label var `ar_rf'   "AR"
		label var `k_rf'   	"K"
*		label var `clr_rf'  "CLR"
		label var `j_rf'    "J"
		label var `kj_rf'	"K-J"
		label var `wald_rf' "Wald"
		local counter = 1
		while `counter' <= `rows' {
			local gridnull1 = `citable'[`counter',colnumb(`citable',"null1")]
			local gridnull2 = `citable'[`counter',colnumb(`citable',"null2")]
				qui replace `xvar'    = `gridnull1'                                           in `counter'
				qui replace `yvar'    = `gridnull2'                                           in `counter'
				qui replace `ar_rf'   = 1 - `citable'[`counter',colnumb(`citable',"ar_p")]    in `counter'
				qui replace `wald_rf' = 1 - `citable'[`counter',colnumb(`citable',"wald_p")]  in `counter'
			if `e(overid)' {
				qui replace `k_rf'    = 1 - `citable'[`counter',colnumb(`citable',"k_p")]     in `counter'
*				qui replace `clr_rf'  = 1 - `citable'[`counter',colnumb(`citable',"clr_p")]   in `counter'
				qui replace `j_rf'    = 1 - `citable'[`counter',colnumb(`citable',"j_p")]     in `counter'
				qui replace `kj_rf'   = 1 - `citable'[`counter',colnumb(`citable',"kj_p")]    in `counter'
			}
		local ++counter
		}

* twoway contour fails when called on Stata temporary varibles, so must create own temps
		tempname x y z
		capture drop weakiv`x'
		qui gen weakiv`x'=`xvar'
		capture drop weakiv`y'
		qui gen weakiv`y'=`yvar'
		capture drop weakiv`z'
		qui gen weakiv`z'=.

		local endo1 "`e(endo1)'"
		local endo2 "`e(endo2)'"

		if "`levellist'"=="" {							//  if not provided as argument,
			local levellist "`e(levellist)'"			//  default is levels saved with estimation
		}
		numlist "`levellist'", descending				//  put in descending order
		if "`arlevel'"=="" {							//  if not provided as argument,
			local arlevel "`e(ar_level)'"				//  default is levels saved with estimation
		}
		if "`jlevel'"=="" {								//  if not provided as argument,
			local jlevel "`e(j_level)'"					//  default is levels saved with estimation
		}
		if "`kjlevel'"=="" {							//  if not provided as argument,
			local kjlevel "`e(kj_level)'"				//  default is levels saved with estimation
		}

* Contour plot type: contourline (default) or contourshade (optional)
* Code sets macro cline=1 if default (using contourline graph command), =0 if contourshade (using contour graph command)
* and removes contourline or contourshade from list of contour options
		local cline "contourshade"
		local cline : list cline - contouropt
		local cline	: list sizeof cline
		local tstring "contourline contourshade"
		local contouropt	:	list contouropt - tstring

		label var weakiv`x' `endo1'
		label var weakiv`y' `endo2'
		label var weakiv`z' "Rejection prob. = 1-pval"
		foreach stat of local graph {
			qui replace weakiv`z'=``stat'_rf'
			tempname graphc graphs graph_`stat'

* Put this in loop since treatment of graph depends whether it is AR, J or KJ, when level can be set separately
			if "`stat'"=="ar" & "`arlevel'"~="" {
				local looplevellist	"`arlevel'"
			}
			else if "`stat'"=="j" & "`jlevel'"~="" {
				local looplevellist	"`jlevel'"
			}
			else if "`stat'"=="kj" & "`kjlevel'"~="" {
				local looplevellist	"`kjlevel'"
			}
			else {											//  All others or AR/J/KJ not set separately
				local looplevellist "`levellist'"
			}
			
			local level_ct : word count `looplevellist'
			tokenize `looplevellist'
			if `level_ct'==1 {
				if `cline' {
					local ccoloropt "red"
				}
				else {
					local ccoloropt "gs5"
				}
				local ccut1 = `1'/100
			}
			else if `level_ct'==2 {
				if `cline' {
					local ccoloropt "dkgreen red"
				}
				else {
					local ccoloropt "gs5 gs9"
				}
				local ccut1 = `1'/100
				local ccut2 = `2'/100
			}
			else {
				if `cline' {
					local ccoloropt "blue dkgreen red"
				}
				else {
					local ccoloropt "gs6 gs9 gs12"
				}
				local ccut1 = `1'/100
				local ccut2 = `2'/100
				local ccut3 = `3'/100
			}
			local ccutsopt "`ccut1' `ccut2' `ccut3'"
			if `level_ct'==1 {
				local plegendopt "plegend(off)"			// 	only show legend if more than one level (contourline)
				local clegendopt "clegend(off)"			// 	only show legend if more than one level (contour)
				local ctitle "`1'% Confidence set"
			}
			else {
				local ctitle "Confidence sets"
			}

			if `contour' {
				if `cline' {
					graph twoway contourline weakiv`z' weakiv`y' weakiv`x'		///
						if _n<`counter',										///
						title("`ctitle'")										///
						ccuts("`ccutsopt'")										///
						colorlines												///
						ccolor(`ccoloropt')										///
						name(`graphc', replace)									///
						nodraw													///
						`contouropt'
				}
				else {
					graph twoway contour weakiv`z' weakiv`y' weakiv`x'			///
						if _n<`counter',										///
						title("`ctitle'")										///
						ccuts("`ccutsopt'") 									///
						ccolor(`ccoloropt' white)								/// 	so that area above last confidence level is white
						zlabel(0 `ccut3' `ccut2' `ccut1' 1)						/// 	to guarantee that label goes from 0 to 1
						name(`graphc', replace)									///
						nodraw													///
						`clegendopt'											///
						`contouropt'
				}
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

* In case we had to increase the number of obs to accommodate gridpoints > _N
		if `pflag' {
			restore
		}

end


program define display_output
	version 10.1

* print combined test and confidence set results
* column specs
	local testnamelen = 5
	local testcollen = 1 + `testnamelen' + 1
	local pvalcol = 46
	local csetcol = 58
	local nociline = 45
* testnames
	local name_clr	: di "{txt}{ralign `testnamelen':{helpb weakiv10##CLR:CLR}}"
	local name_ar	: di "{txt}{ralign `testnamelen':{helpb weakiv10##AR:AR}}"
	local name_k	: di "{txt}{ralign `testnamelen':{helpb weakiv10##K:K}}"
	local name_j	: di "{txt}{ralign `testnamelen':{helpb weakiv10##J:J}}"
	local name_kj	: di "{txt}{ralign `testnamelen':{helpb weakiv10##K-J:K-J}}"
	local name_wald	: di "{txt}{ralign `testnamelen':{helpb weakiv10##Wald:Wald}}"

* calculate length of result parts
	if `e(overid)' {
		local testlist "ar k j kj clr wald"
	}
	else {
		local testlist "ar wald"
	}
	foreach testname in `testlist' {
		if "`testname'"=="clr" {
			local dist_clr "stat"
			local stattxt_clr : di "{txt}{lalign 8:stat(.)} = {res}" ///
	   			%8.2f `e(`testname'_stat)'
		}
		else if "`testname'"=="kj" {
			local dist_kj "stat"
			local stattxt_kj : di "{txt}{center 19:<n.a.>}"
		}
		else {
			local dist_`testname' "chi2"
			local stattxt_`testname' : di "{txt}{lalign 8:`dist_`testname''({res:`=`e(`testname'_df)''})} = {res}" ///
	   			%8.2f `e(`testname'_chi2)'
		}

	   	local pvaltxt_`testname' : di "{txt}{ralign 14:Prob > `dist_`testname''} = {res}" %8.4f `e(`testname'_p)'
	   	local testtxt_`testname' "`stattxt_`testname''`pvaltxt_`testname''"
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
	if `e(ci)' {
		di as txt "{p}{helpb weakiv10##interpretation:Weak instrument robust tests and confidence sets for `e(ivtitle)' `modeltext'}{p_end}"
	}
	else {
		di as txt "{p}{helpb weakiv10##interpretation:Weak instrument robust tests for `e(ivtitle)'}{p_end}"
	}
	if `e(wendog_ct)'==1 {		// K=1
		di in yellow "H0: beta[`e(depvar)':`e(wendo)'] = `e(null)'"
	}
	else {						// K=2
		di in yellow "H0: beta[`e(depvar)':`e(endo1)'] = `e(null1)' & beta[`e(depvar)':`e(endo2)'] = `e(null2)'"
	}
	if `e(ci)' {
		di
		di as txt "{hline `testnamelen'}{hline 1}{c TT}{hline `pvalcol'}{c TT}{hline}"
		di as txt "{ralign `testnamelen':Test} {c |} {center 20:Statistic}{center 25:p-value}{c |}{center 16:Conf. level}{center :{helpb weakiv10##cset:Confidence Set}}"
		di as txt "{hline `testnamelen'}{hline 1}{c +}{hline `pvalcol'}{c +}{hline}"
		if `e(overid)' {
			if `e(clr_stat)'!=. {
				local clr_level	: di %2.0f e(clr_level) "%"
				di "`name_clr' {c |} `testtxt_clr' {c |}{center 16:`clr_level'}{res}{center :`e(clr_cset)'}"
			}
			local k_level	: di %2.0f e(k_level) "%"
			di "`name_k' {c |} `testtxt_k' {c |}{center 16:`k_level'}{res}{center :`e(k_cset)'}"
			local j_level	: di %2.0f e(j_level) "%"
			di "`name_j' {c |} `testtxt_j' {c |}{center 16:`j_level'}{res}{center :`e(j_cset)'}"
*			local kj_level "`e(kj_level)'"
			local kj_level	: di %2.0f e(kj_level) "% (" %2.0f e(kjk_level) "%," %2.0f e(kjj_level) "%)"
			di "`name_kj' {c |} `testtxt_kj' {c |}{center 16:`kj_level'}{res}{center :`e(kj_cset)'}"
		}
		local ar_level : di %2.0f e(ar_level) "%"
		di "`name_ar' {c |} `testtxt_ar' {c |}{center 16:`ar_level'}{res}{center :`e(ar_cset)'}"
		di as txt "{hline `testnamelen'}{hline 1}{c +}{hline `pvalcol'}{c +}{hline}"
		local wald_level : di %2.0f e(wald_level) "%"
		di "`name_wald' {c |} `testtxt_wald' {c |}{center 16:`wald_level'}{res}{center :`e(wald_cset)'}"
		di as txt "{hline `testnamelen'}{hline 1}{c BT}{hline `pvalcol'}{c BT}{hline}"
	}
	else {
		di as txt "{hline `testnamelen'}{hline 1}{c TT}{hline `nociline'}"
		di as txt "{ralign `testnamelen':Test} {c |} {center 20:Statistic}{center 25:p-value}"
		di as txt "{hline `testnamelen'}{hline 1}{c +}{hline `nociline'}"
		if `e(overid)' {
			if `e(clr_stat)'!=. {
				di "`name_clr' {c |} `testtxt_clr'"
			}
			di "`name_k' {c |} `testtxt_k'"
			di "`name_j' {c |} `testtxt_j'"
			di "`name_kj' {c |} `testtxt_kj'"
		}
		di "`name_ar' {c |} `testtxt_ar'"
		di as txt "{hline `testnamelen'}{hline 1}{c +}{hline `nociline'}"
		di "`name_wald' {c |} `testtxt_wald'"
		di as txt "{hline `testnamelen'}{hline 1}{c BT}{hline `nociline'}"
	}
	if `e(grid)' {
		if `e(wendog_ct)'==1 {
			local pointstext "`e(points)'"
		}
		else {
			local pointstext "(`e(points1)' x `e(points2)')"
		}
		di as txt "Confidence sets estimated for `pointstext' points in `e(grid_description)'."
	}
	else if `e(overid)' & `e(ci)' {
		di as txt "J/K-J conf. sets unavailable with closed-form estimation (use usegrid option)."				
	}
	local Ntext "`e(N)'"
	di as text "Number of observations N  = `Ntext'.  " _continue
	if `e(overid)' {
		di as text "Weight on K in K-J test = " %5.3f e(kwt) ". " _continue
	}
	if "`e(xtmodel)'"~="" {
		local N_gtext "`e(N_g)'"
		di as text "Number of groups N_g  = `N_gtext'."
		if `e(singleton)'>0 & `e(singleton)'<. {
			di as text "Warning - singleton groups detected.  `e(singleton)' observation(s) not used."
		}
	}
	if "`e(method)'"=="md" & "`e(model)'"=="linear" {
		di as txt "{p}Notes: Method = {helpb weakiv10##method:minimum distance/Wald}." _continue
	}
	else if "`e(method)'"=="md" {
		di as txt "{p}Notes: Method = {helpb weakiv10##method:minimum distance (MD)}." _continue
	}
	else {
		di as txt "{p}Notes: Method = {helpb weakiv10##method:lagrange multiplier (LM)}." _continue
	}
	di as txt " `e(note1)' `e(note2)' `e(note3)' " _continue
	if `e(npd)' {
		di in red "Some matrices are not positive definite, so reported tests should be treated with caution. " _continue
	}
	di as txt "{p_end}"
end

program define estimate_model
	version 10.1

			syntax anything(everything) [if] [in] [fw aw pw iw] [,		///
			NULL1(real 0) NULL2(real 0) kwt(real 0) NOCI				/// weakiv options stripped out...
			usegrid grid(numlist ascending)								///
			grid1(numlist ascending) grid2(numlist ascending)			///
			POINTS1(integer 0) POINTS2(integer 0)						///
			gridmult(real 0) GRIDLIMits(numlist ascending min=2 max=2)	///
			GRIDLIMITS1(numlist ascending min=2 max=2)					///
			GRIDLIMITS2(numlist ascending min=2 max=2)					///
			LEVELlist(numlist min=0 max=3)								///
			arlevel(numlist min=1 max=1)								///
			jlevel(numlist min=1 max=1)									///
			kjlevel(numlist min=1 max=2)								///
			lm															///
			strong(varname)												///
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

	tokenize `anything'
	local estimator `1'
	
	if "`estimator'"=="ivprobit" {
		di as text "Estimating model for Wald tests using ivprobit..."
	}
	else if "`estimator'"=="ivtobit" {
		di as text "Estimating model for Wald tests using ivtobit..."
	}
	else if "`estimator'"=="ivregress" {
		di as text "Estimating model for Wald tests using ivregress..."
	}
	else if "`estimator'"=="ivreg2" {
		di as text "Estimating model for Wald tests using ivreg2..."
	}
	else if "`estimator'"=="ivreg2h" {
		di as text "Estimating model for Wald tests using ivreg2h..."
	}
	else if "`estimator'"=="xtivreg" {
		di as text "Estimating model for Wald tests using xtivreg..."
	}
	else if "`estimator'"=="xtivreg2" {
		di as text "Estimating model for Wald tests using xtivreg2..."
	}
	else {
di as err "error - unsupported estimator `estimator'"
		exit 198
	}
	
	qui `anything' `if' `in' `wtexp' `optexp'

end

program define get_option_specs, rclass
	version 10.1
			syntax [anything(everything)] [if] [in] [fw aw pw iw] [,			/// <= estimation specs aren't used
			NULL1(real 0) NULL2(real 0) NOCI									/// weakiv options start here
			usegrid grid(numlist ascending)										///
			grid1(numlist ascending) grid2(numlist ascending)					///
			points(integer 0) POINTS1(integer 0) POINTS2(integer 0)				///
			gridmult(real 0) GRIDLIMits(numlist ascending min=2 max=2)			///
			GRIDLIMITS1(numlist ascending min=2 max=2)							///
			GRIDLIMITS2(numlist ascending min=2 max=2)							///
			LEVELlist(numlist min=0 max=3)										///
			arlevel(numlist min=1 max=1)										///
			jlevel(numlist min=1 max=1)											///
			kjlevel(numlist min=1 max=2)										///
			kwt(real 0)															///
			lm																	///
			strong(varname ts)													///
			exportmats															///
			ESTSTOREwald(name) DISPLAYwald ESTUSEwald(name)						///
			ESTADD1 ESTADD2(name)												///
			graph(string) graphxrange(numlist ascending min=2 max=2)			///
			graphopt(string asis)												///
			contouropt(string asis) surfaceopt(string asis)						///
			CONTOURonly SURFACEonly												///
			forcerobust															///
			weakiv_iid(integer 0) weakiv_model(string) weakiv_overid(integer 0)	/// <= additional arguments related to options
			weakiv_nendog(integer 0) weakiv_endo(varlist ts)					///
			retmat ci lmwt(numlist max=1 >0 <1)									/// <= legacy options from rivtest
			*																	///
			]

	local endo		"`weakiv_endo'"
	tokenize `endo'
	local endo1		: word 1 of `endo'
	local endo2		: word 2 of `endo'
	local sendo		"`strong'"
	local wendo		: list endo - sendo
	local nendog	=`weakiv_nendog'
	local nsendog	: word count `sendo'
	local nwendog	: word count `wendo'
	
	if `nendog' > 2 {
di as err "weakiv does not support estimation with >2 endogenous regressors"
		exit 198
	}
	if `nendog' == 0 {
di as err "error - model must specify at least one endogenous regressor"
		exit 198
	}
	if `nsendog' > 1 {
di as err "weakiv currently can handle only one strongly-identified endogenous variable"
		exit 198
	}
	if `nwendog'==0 {
di as err "syntax error - no weakly endogenous regressors specified"
		exit 198
	}
	if `nwendog' ~= `nendog'-`nsendog' {
di as err "syntax error - `sendo' listed in strong(.) but not as endogenous"
		exit 198
	}

* Check all provided confidence levels.
* Stata's definition of a legal level is >=10 and <=99.99
	foreach lev in `levellist' `arlevel' `jlevel' `kjlevel' {
		if `lev'<10 | `lev'>=99.99	{									//  Stata's definition of a legal level
di as err "illegal confidence level `lev': must be >=10 and <=99.99"
			exit 198
		}
	}

* lm currently allowed only with linear models
	if ("`lm'"=="lm") & ("`weakiv_model'" ~= "linear") {						//  LM (Kleibergen 2002, 2005) valid only for linear IV
di as err "illegal option - lm method supported only for linear IV models"
		exit 198
	}

* strongly-id endog currently allowed only with linear models
	if (`nsendog'>0) & ("`weakiv_model'" ~= "linear") {
di as err "illegal option - strong(.) option supported only for linear IV models"
		exit 198
	}


* Default level is system-determined
* `levellist' is list of significance levels provided by user (max 3)
* `level' is the first and the one used for testing
	if "`levellist'"=="" {
		local level		"`c(level)'"
		local levellist	"`c(level)'"
	}
	else {
		tokenize `levellist'						//  order provided
		local level		"`1'"						//  first level provided used for tests
*		numlist "`levellist'", descending			//  descending order when saved as macro
*		local levellist	"`r(numlist)'"
	}
* AR and J levels
	if "`arlevel'"=="" {							//  not specified, use default
		local ar_level	"`level'"
	}
	else {											//  must be legal
		local ar_level	"`arlevel'"
	}
	if "`jlevel'"=="" {								//  not specified, use default
		local j_level	"`level'"
	}
	else {											//  must be legal
		local j_level	"`jlevel'"
	}

* If just points provided, means both points1 & points2
	if `points'>0 & `points1'==0 {
		local points1=`points'
	}
	if `points'>0 & `points2'==0 {
		local points2=`points'
	}

* Convert to boolean
	local usegrid		=("`usegrid'"=="usegrid")
	local forcerobust	=("`forcerobust'"=="forcerobust")

* CIs not reported for K=2 case
	if `nwendog'==2 {
		local noci "noci"
	}
* No CI means do not construct grid, unless grid construction triggered by other options
	local ci = ("`noci'"=="")

* Various options trigger usegrid.
* If grid used and no points or gridmult provided, set points=100 & gridmult=2
	if "`grid'`gridlimits'`graph'" ~= "" {
		local usegrid	=1
	}
	if (`ci'==1) & (`weakiv_iid'==0)  {									//  use grid for non-robust case unless no CIs to report
		local usegrid	=1
	}
	if (`ci'==1) & (`nsendog'>0) {										//  use grid for CI if strong endog specified
		local usegrid	=1												//  (but only if CI needed)
	}
	if (`ci'==1) & ("`weakiv_model'" ~= "linear") {						//  use grid for CI if ivprobit or ivtobit
		local usegrid	=1												//  (but only if CI needed)
	}
	if `points1'>0 | `points2'>0 | `gridmult'>0 {
		local usegrid	=1
	}
	if (`ci'==1) & (`weakiv_nendog'==2) {								//  always use grid for K=2 case unless no CIs to report
		local usegrid	=1
	}
	if (`forcerobust'==1) {
		local usegrid	=1
	}
	if `usegrid' {
		if `nwendog'==1 & `points'==0 {
			local points=100
		}
		if `nwendog'==2 & `points1'==0 {
			local points1=10
		}
		if `nwendog'==2 & `points2'==0 {
			local points2=10
		}
		if `gridmult'==0 {
			local gridmult=2
		}
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

* Legacy rivtest options
	if "`kwt'"=="" {
		local kwt "`lmwt'"
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

	return local null			"`null1'"
	return local null1			"`null1'"
	return local null2			"`null2'"
	return local kwt			"`kwt'"
	return local lm				=("`lm'"=="lm")
	return local sendo			"`sendo'"
	return local wendo			"`wendo'"
	return local endo1			"`endo1'"
	return local endo2			"`endo2'"
	return local nwendog		"`nwendog'"				//  currently 1 or 2
	return local nsendog		"`nsendog'"				//  currently 0 or 1
	return local level			"`level'"
	return local levellist		"`levellist'"
	return local ar_level		"`ar_level'"
	return local wald_level		"`level'"
	return local clr_level		"`level'"
	return local k_level		"`level'"
	return local j_level		"`j_level'"
	return local kj_level		"`kj_level'"
	return local kjk_level		"`kjk_level'"
	return local kjj_level		"`kjj_level'"
	return local ci				"`ci'"
	return local usegrid		"`usegrid'"
	return local grid			"`grid'"
	return local grid1			"`grid1'"
	return local grid2			"`grid2'"
	return local points			"`points'"
	return local points1		"`points1'"
	return local points2		"`points2'"
	return local gridmult		"`gridmult'"
	return local gridlimits		"`gridlimits'"
	return local gridlimits1	"`gridlimits1'"
	return local gridlimits2	"`gridlimits2'"
	return local exportmats		"`exportmats'"
	return local eststorewald	"`eststorewald'"
	return local displaywald	"`displaywald'"
	return local estadd			=("`estadd1'`estadd2'"~="")
	return local estaddname		"`estadd2'"
	return local graph			"`graph'"
	return local graphxrange	"`graphxrange'"
	return local graphopt		"`graphopt'"
	return local contouropt		"`contouropt'"
	return local surfaceopt		"`surfaceopt'"
	return local contouronly	"`contouronly'"
	return local surfaceonly	"`surfaceonly'"
	return local forcerobust	"`forcerobust'"

end		// end get_option_specs

********************************************************************************

program define get_model_specs, rclass
	version 10.1
	syntax [,								///
				touse(name)					///
				wvar(name)					///
				*							///
			]

* verify estimation model: test can only run after ivregress, ivreg2, ivreg2h, xtivreg2, ivtobit, and ivprobit
	local legalcmd	"ivregress ivreg2 ivreg2h xtivreg xtivreg2 ivprobit ivtobit"
	local cmd		"`e(cmd)'"
	local legal		: list cmd in legalcmd
	if ~`legal' {
di as err "weakiv not supported for command `e(cmd)'"
		error 301
	}

	qui gen byte `touse'=e(sample)
	
******* zeros by default or if not supported  ********
* Overidden below by estimators which support or use these
	local npartial=0
	local partialcons=0
	local N_g=0
	local singleton=0
	local dofminus=0

************** ivtobit parsing block *****************
	if "`e(cmd)'" == "ivtobit" {
		local model "ivtobit"
		local ivtitle "IV tobit"
* verify that robust or cluster covariance estimation not used
		if "`e(vce)'" == "robust" | "`e(vce)'" == "cluster" {
			di in red "with ivtobit, weakiv requires an assumption of homoskedasticity (no robust or cluster)"	
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
	}	// end ivtobit parsing block

************** ivprobit parsing block ******************
	if "`e(cmd)'" == "ivprobit" {
		local model "ivprobit"
		local ivtitle "IV probit"
* verify that robust or cluster covariance estimation not used
		if "`e(vce)'" == "robust" | "`e(vce)'" == "cluster" {
di as err "with ivprobit, weakiv requires an assumption of homoskedasticity (no robust or cluster)"	
			exit 198
		}
		if "`e(vce)'" ~= "twostep" {
di as err "For endogenous probit, Wald statistics are comparable with weak-IV-robust statistics"
di as err "only when the Newey two-step estimator is used for original ivprobit estimation."
di as err "Re-estimate using the -twostep- option."
			exit 198
		}
		local small "small"				// ivprobit => small
		local cons=1					// ivprobit => always a constant
		local asis "`e(asis)'"
		local depvar=trim(subinword("`e(depvar)'","`e(instd)'","",.))
		local endo "`e(instd)'"
* get instrument lists
		local x : colnames(e(b))
		local x : subinstr local x "_cons" ""
		local insts "`e(insts)'"
		local inexog : list x - endo
		local exexog : list insts - inexog
	}	// end ivprobit parsing block

************* ivregress parsing block ****************
	if "`e(cmd)'" == "ivregress" {
		local model "linear"
		local ivtitle "linear IV"
		tokenize `e(vce)'
		if "`1'" == "hac" {
			local kernel "`e(hac_kernel)'"
			local bw=`3'+1
			local robust "robust"
		}
		if "`e(vce)'" == "robust" {
			local robust "robust"
		}
		local cluster "`e(clustvar)'"
		local noconstant "`e(constant)'"
		local cons = ~("`noconstant'"=="noconstant")
		local small "`e(small)'"
		local depvar "`e(depvar)'"
		local endo "`e(instd)'"
		local inexog "`e(exogr)'"
		local insts "`e(insts)'"
		local exexog : list insts - inexog
	}	// end ivregress parsing block

**************** ivreg2/ivreg2h/xtivreg2 parsing block ***************
	if "`e(cmd)'"=="ivreg2" | "`e(cmd)'"=="ivreg2h" | "`e(cmd)'"=="xtivreg2" {
		local model "linear"
		local ivtitle "linear IV"
		local kernel "`e(kernel)'"
		local bw "`e(bw)'"
		local cluster "`e(clustvar)'"
		if "`e(vcetype)'"=="Robust" {
			local robust "robust"
		}
		if (`e(cons)'+`e(partialcons)')==0 {
			local noconstant "noconstant"	// spec of ORIGINAL model, not after cons partialled out
		}
		local cons "`e(cons)'"
		local partialcons "`e(partialcons)'"
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
* semibug in ivreg2 - if partialling-out constant only,
* macro partial is missing but arg should be "_cons"
		local partial "`e(partial1)'"
		if "`partial'"=="" & `e(partialcons)'==1 {
			local partial "_cons"
		}
		local partial "`partial'"
		local npartial "`e(partial_ct)'"

* misc
		if "`e(vce'"=="psd0" | "`e(vce'"=="psda" {
			local psd "`e(vce)'"
		}
		local dofminus=e(dofminus)
	}

*********** xtivreg2 only *************************
* Rest captured above with ivreg2 et al. block

	if "`e(cmd)'"=="xtivreg2" {
		local xtmodel	"`e(xtmodel)'"
		local N_g		"`e(N_g)'"
		local singleton	"`e(singleton)'"
		if "`xtmodel'"=="fe" {
			local dofminus	"`N_g'"				//  For iid FE case sigmas, adjustment for #groups needed
		}	
		if "`xtmodel'"~="fe" & "`xtmodel'"~="fd" {
di as err "error - weakiv supports only FD and FD estimation with xtivreg2"
			exit 198
		}
	}

************* xtivreg parsing block ****************
	if "`e(cmd)'" == "xtivreg" {
		local model			"linear"
		local xtmodel		"`e(model)'"
		if "`xtmodel'"~="fe" & "`xtmodel'"~="fd" {
di as err "error - unsupported xtivreg model `xtmodel'"
			exit 198
		}
		local ivtitle		"linear IV"
		local N_g			"`e(N_g)'"
		if "`xtmodel'"=="fe" {
			local dofminus	"`N_g'"				//  For iid FE case sigmas, adjustment for #groups needed
		}
* xtivreg uses small-sample adjustment; "small" option changes only z or t etc.
		local small			"small"
* Bizarrely, xtivreg,fd puts a D operator in front of depvar but nowhere else
		local depvar		"`e(depvar)'"
		tsunab depvar 		: `depvar'
		if "`xtmodel'"=="fd" {
			local endo		"d.(`e(instd)')"
			tsunab endo		: `endo'
			local insts			"d.(`e(insts)')"
			tsunab insts		: `insts'
		}
		else {
			local endo		"`e(instd)'"
			local insts		"`e(insts)'"
		}
* Full colnames have TS operators in front of them already
		local x				: colfullnames(e(b))
		local x				: subinstr local x "_cons" "", count(local cons)
		local inexog		: list x - endo
		local exexog		: list insts - inexog
* xtivreg supports only conventional SEs (+ bootstrap etc)
		if "`xtmodel'"=="fe" {					//	We use impose no constant in FE model
			local cons 		=0					//  Overrides cons created by count above
		}
	}	// end ivregress parsing block

*********** common parsing block ******************

* Stata 11: remove omitted variables or base levels of factor variables 
	if `c(stata_version)'>=11 {
		foreach var in `exexog' `inexog' `endo' {
			_ms_parse_parts `var'
			if `r(omit)' {
				local remove "`var'"
				local inexog : list inexog - remove
				local exexog : list exexog - remove
				local endo   : list endo   - remove
			}	
		}
	}

****************** Weights, counts and #obs ******************
	local N "`e(N)'"
	local N_clust "`e(N_clust)'"
	local N_clust1 "`e(N_clust1)'"		//  in case of 2-way clustering
	local N_clust2 "`e(N_clust2)'"
	local clustvar "`e(clustvar)'"
	local wtype "`e(wtype)'"			//  fweight, aweight, etc.
	if "`wtype'"=="" {					//  no weights in use
		qui gen byte `wvar'=1			//  define neutral weight variable
	}
	else {								//  weights in use
		local wexp "`e(wexp)'"			//  "=wvar" or "=<exp>"
		qui gen double `wvar' `wexp'	//  calculate weight var contents
		local wtexp "[`wtype'`wexp']"	//  e.g. "[aw=1/w]"
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
	if `N'==0 {
di as err "no observations"
		exit 2000
	}

* Assemble options spec for vce calc by avar
* omit noconstant, partial
* small omitted because avar doesn't accept it.
	local vceopt "`robust' cluster(`cluster') bw(`bw') kernel(`kernel') `psd'"
* Assemble notes for table output
	if "`robust'`cluster'`kernel'"=="" {
		local note1 "Tests assume i.i.d. errors."
	}
	else {
		if "`robust'`cluster'"~="" {
			local note1 "Tests robust to heteroskedasticity"
			if "`cluster'"~="" {
				local note1 "`note1' and clustering on `cluster'"
			}
			local note1 "`note1'."
		}
		if "`kernel'"~="" {
			local note2 "Tests robust to autocorrelation: kernel=`kernel', bw=`bw'."
			}
	}
	if "`small'"~="" {
		local note3 "Small sample adjustments were used."
	}

	local iid = ("`robust'`cluster'`kernel'"=="")

* Counts
	local nendog	: word count `endo'
	local nexexog	: word count `exexog'
	local ninexog	: word count `inexog'
* Count modified to include constant if appropriate
* (cons=1 if cons not partialled out, partialcons=1 if cons partialled out, both=0 if no constant in model)
	local ninexog	= `ninexog' + `cons' + `partialcons'
	local overid	= `nexexog' - `nendog'

* Return values

	return local depvar			"`depvar'"
	return local endo			"`endo'"
	return local inexog			"`inexog'"
	return local exexog			"`exexog'"
	return local wf				"`wf'"
	return local N				"`N'"
	return local N_clust		"`N_clust'"
	return local N_clust1		"`N_clust1'"
	return local N_clust2		"`N_clust2'"
	return local clustvar		"`clustvar'"
	return local N_g			"`N_g'"
	return local singleton		"`singleton'"
	return local wtype			"`wtype'"
	return local wexp			"`wexp'"
	return local wtexp			"`wtexp'"
	return local kernel			"`kernel'"
	return local bw				"`bw'"
	return local partial		"`partial'"
	return local npartial		"`npartial'"
	return local dofminus		"`dofminus'"
	return local psd			"`psd'"
	return local cons			"`cons'"
	return local nendog			"`nendog'"
	return local nexexog		"`nexexog'"
	return local ninexog		"`ninexog'"
	return local overid			"`overid'"
	return local noconstant		"`noconstant'"
	return local partialcons	"`partialcons'"
	return local small			"`small'"
	return local robust			"`robust'"
	return local cluster		"`cluster'"
	return local asis			"`asis'"
	return local llopt			"`llopt'"
	return local ulopt			"`ulopt'"
	return local iid			"`iid'"

	return local model			"`model'"
	return local xtmodel		"`xtmodel'"
	return local ivtitle		"`ivtitle'"
	return local vceopt			"`vceopt'"
	return local note1			"`note1'"
	return local note2			"`note2'"
	return local note3			"`note3'"

end		// end get_model_specs

******************************************************************

program define weakiv_replay, rclass
	version 10.1
	cap noi syntax [,											///
			replay												///	<option ignored - here to enable auto option checking>
			/* estusewald(name) */								/// <currently not supported for replay>
			/* displaywald */									/// <currently not supported for replay>
			/* estadd */										/// <currently not supported for replay>
			LEVELlist(numlist min=0 max=3)						/// for plots only - doesn't affect estimation
			arlevel(numlist min=1 max=1)						///
			jlevel(numlist min=1 max=1)							///
			kjlevel(numlist min=1 max=1)						///
			graph(string)										///
			graphxrange(numlist ascending min=2 max=2)			///
			graphopt(string asis)								///
			CONTOURonly SURFACEonly								///
			contouropt(string asis) surfaceopt(string asis)		///
		]

	if _rc~=0 {
di as err "weakiv replay error: " _c
		error 198
	}
	
	if `"`e(cmd)'"' != "weakiv"  {
		error 301
	}

	display_output

	if "`graph'" ~= "" {
		if `e(wendog_ct)'==1 {
			do_graphs, graph(`graph') graphxrange(`graphxrange') graphopt(`graphopt') levellist(`levellist')
		}
		else {
			do_graphs2,						///
				graph(`graph')				///
				contouronly(`contouronly')	///
				surfaceonly(`surfaceonly')	///
				contouropt(`contouropt')	///
				surfaceopt(`surfaceopt')	///
				graphopt(`graphopt')		///
				levellist(`levellist')		///
				arlevel(`arlevel')			///
				jlevel(`jlevel')			///
				kjlevel(`kjlevel')
		}
	}

end		// end weakiv_replay

***********************************************************************************
program define get_gridlist, rclass
	version 10.1
	syntax [,							///
				grid(numlist)			///
				gridlimits(numlist)		///
				gridmult(real 0)		///
				points(integer 0)		///
				ivbeta(real 0)		///
				ivbetase(real 0)		///
				alpha(real 0)			///
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
				local gridradius = abs(`gridmult') * `ivbetase' * invnormal(1-`alpha'/2)
* create grid for confidence sets
				local gridmin = `ivbeta' - `gridradius'
				local gridmax = `ivbeta' + `gridradius'
		}
		else {
* shouldn't reach this point - should be trapped when options are parsed
			di as err "Option -gridlimits- misspecified; must specify lower and upper limit only"
			exit 198
		}
		local gridinterval = .999999999*(`gridmax'-`gridmin')/(`points'-1)
		local grid "`gridmin'(`gridinterval')`gridmax'"		//  grid is in numlist form
		numlist "`grid'"
		local gridlist "`r(numlist)'"						//  gridlist is actual list of #s to search over
	}
	else {
		numlist "`grid'"									//  grid is user-provided numlist of grid entries
		local gridlist "`r(numlist)'"						//  gridlist is actual list of #s to search over
	}
	local points : word count `gridlist'
	
	return local gridlist "`gridlist'"
	return scalar points=`points'
	return scalar gridmin=`gridmin'
	return scalar gridmax=`gridmax'

end		// end get_gridlist

***********************************************************************************

program define construct_ci1w1s, rclass
	version 10.1
	syntax [,							///
				iid(integer 0)			///
				usegrid(integer 0)		///
				depvar(varname ts)		///
				wendo(varname ts)		///
				sendo(varname ts)		///
				exexog(varlist ts)		///
				touse(varname ts)		///
				wtexp(string)			///
				vceopt(string)			///
				nexexog(integer 0)		///
				nendog(integer 0)		///
				nsendog(integer 0)		///
				ssa(real 0)				///
				dofminus(real 0)		///
				overid(integer 0)		///
				level(real 0)			///
				kj_level(real 0)		///
				j_level(real 0)			///
				ar_level(real 0)		///
				alpha(real 0)			///
				kwt(real 0)				///
				n(integer 0)			///
				grid(numlist)			///
				gridlimits(numlist)		///
				gridmult(real 0)		///
				points(integer 0)		///
				ivbeta1(real 0)			///
				ivbetase1(real 0)		///
				ivbeta2(real 0)			///
				b2hat(name local)		///
				pi2hat(name local)		///
				var_pi_z(name local)	///
				pi_z(name local)		///
				var_del(name local)		///
				del_z(name local)		///
				del_v(name local)		///
				var_pidel_z(name local)	///
				var_beta(name local)	///
				x2z(name local)			///
				lm(integer 0)			///
				syy(name)				///
				see(name)				///
				sxy(name)				///
				sve(name)				///
				sxx(name)				///
				svv(name)				///
				forcerobust(string)		///
			]

		if `overid' {
		 	local testlist "ar k j kj clr"
		 }
		else {
			local testlist "ar"
		}

* construct confidence intervals if requested

		get_gridlist,						///
			grid(`grid')					///
			gridlimits(`gridlimits')		///
			gridmult(`gridmult')			///
			points(`points')				///
			ivbeta(`ivbeta1')				///
			ivbetase(`ivbetase1')			///
			alpha(`alpha')

		local gridlist	"`r(gridlist)'"
		local points	=r(points)
		local gridmin	=r(gridmin)
		local gridmax	=r(gridmax)

* create a matrix to store test results for confidence interval
		tempname citable
		if `overid' {
			mat `citable' = J(`points', 20, 0)
			mat colnames `citable' =				///
										null		///
										beta2		///
										wald_chi2	///
										ar_chi2		///
										k_chi2		///
										j_chi2		///
										clr_stat	///
										wald_p		///
										ar_p		///
										k_p			///
										j_p			///
										kj_p		///
										clr_p		///
										wald_r		///
										ar_r		///
										k_r			///
										j_r			///
										kj_r		///
										clr_r		///
										rk
		}
		else {
			mat `citable' = J(`points', 9, 0)
			mat colnames `citable' =				///
										null		///
										beta2		///
										wald_chi2	///
										ar_chi2		///
										wald_p		///
										ar_p		///
										wald_r		///
										ar_r		///
										rk
		}

* create macros for storing confidence sets
		foreach testname in `testlist' {
			local `testname'_cset ""
			local `testname'_rbegin=0
			local `testname'_rend=0
			local `testname'_rbegin_null=0
			local `testname'_rend_null=0
		}
		tempname rk ar_p ar_chi2 ar_df k_p k_chi2 k_df j_p j_chi2 j_df kj_p kj_chi2 ///
			clr_p clr_stat clr_df ar_r k_r j_r kj_dnr kj_r kj_p clr_r				///
			wald_chi2 wald_p wald_r wald_df AA
		tempname Sgmm2s W zy
		tempvar ytilda ehat
		qui gen double `ytilda'=. if `touse'
		qui gen double `ehat'=.   if `touse'
* npd is flag set to 1 if npd matices encountered
		local npd = 0
		local counter = 0
		_dots `counter' 0, title(Estimating confidence sets over grid points)
		foreach gridnull in `gridlist' {
			local ++counter
			_dots `counter' 0
* IV estimator.  Used if iid, used as 1st step in 2-step GMM if not iid
			mat `AA' = `b2hat' - `gridnull'*`pi2hat'
			local beta2hat = `AA'[1,1]
* calculate test stats
			if `iid' & (`forcerobust'==0) {
				computeivtests_iid2,		///
					var_pi_z(`var_pi_z')	///
					pi_z(`pi_z')			///
					var_del(`var_del')		///
					del_z(`del_z')			///
					del_v(`del_v')			///
					ivbeta1(`ivbeta1')		///
					ivbeta2(`ivbeta2')		///
					var_beta(`var_beta')	///
					null1(`gridnull')		///
					null2(`beta2hat')		///
					nexexog(`nexexog')		///
					syy(`syy')				///
					see(`see')				///
					sxy(`sxy')				///
					sve(`sve')				///
					sxx(`sxx')				///
					svv(`svv')				///
					lm(`lm')
			}
			else {
				qui replace `ytilda' = `depvar' - `gridnull'*`wendo' if `touse'
				qui replace `ehat'   = `ytilda' - `beta2hat'*`sendo' if `touse'
				cap avar (`ehat') (`exexog') if `touse' `wtexp', `vceopt' nocons
				if _rc>0 {
di as err "error - internal call to avar failed"
					exit _rc
				}
				mat `Sgmm2s' = r(S)
				mat `W' = syminv(`Sgmm2s')
				qui mat accum `AA'  = `exexog' `ytilda' if `touse' `wtexp', nocons
				mat `zy'    = `AA'[1..`nexexog',`nexexog'+1]
* 2-step efficient GMM estimator
				mat `AA'  = syminv(`x2z'*`W'*`x2z'')*`x2z'*`W'*`zy'
				local beta2hat=`AA'[1,1]
				mata: computeivtests_robust2(	///
							"`del_z'",			///
							"`var_del'",		///
							"`pi_z'",			///
							"`var_pi_z'",		///
							"`var_pidel_z'",	///
							"`var_beta'",		///
							`ivbeta1',			///
							`ivbeta2',			///
							`gridnull',			///
							`beta2hat')
				local npd=max(`npd',r(npd))
			}
			scalar `ar_chi2'=r(ar_chi2)
			scalar `k_chi2'=r(k_chi2)
			scalar `j_chi2'=r(j_chi2)
			scalar `clr_stat'=r(clr_stat)
			scalar `rk'=r(rk)
*				scalar `wald_chi2'=r(wald_chi2)
			scalar `wald_chi2' = ((`ivbeta1'-(`gridnull'))/`ivbetase1')^2
			local nullstring "[`gridnull']"
* calculate test statistics, p-values, and rejection indicators from above matrices
			compute_pvals,					///
				null("`nullstring'")		///
				rk(`rk')					///
				nexexog(`nexexog')			///
				nendog(`nendog')			///
				nsendog(`nsendog')			///
				level(`level')				///
				kj_level(`kj_level')		///
				j_level(`j_level')			///
				ar_level(`ar_level')		///
				ar_p(`ar_p')				///
				ar_chi2(`ar_chi2')			///
				k_p(`k_p')					///
				k_chi2( `k_chi2' )			///
				j_p(`j_p')					///
				j_chi2(`j_chi2')			///
				kj_p(`kj_p')				///
				kj_chi2(`kj_chi2')			///
				clr_p(`clr_p')				///
				clr_stat(`clr_stat')		///
				ar_df(`ar_df')				///
				k_df(`k_df')				///
				j_df(`j_df')				///
				clr_df(`clr_df')			///
				ar_r(`ar_r')				///
				k_r(`k_r')					///
				j_r(`j_r')					///
				kj_dnr(`kj_dnr')			///
				kj_r(`kj_r')				///
				kj_p(`kj_p')				///
				clr_r(`clr_r')				///
				wald_chi2(`wald_chi2')		///
				wald_p(`wald_p')			///
				wald_r(`wald_r')			///
				wald_df(`wald_df')			///
				kwt(`kwt')
	
			tempname civec
			if `overid' {
				mat `civec' = (					///
								`gridnull',		///
								`beta2hat',		///
								`wald_chi2',	///
								`ar_chi2',		///
								`k_chi2',		///
								`j_chi2',		///
								`clr_stat',		///
								`wald_p',		///
								`ar_p',			///
								`k_p',			///
								`j_p',			///
								`kj_p',			///
								`clr_p',		///
								`wald_r',		///
								`ar_r',			///
								`k_r',			///
								`j_r',			///
								`kj_r',			///
								`clr_r',		///
								`rk'			///
								)
				mat `citable'[`counter',1] = `civec'
			}
			else {
				mat `civec' = (					///
								`gridnull',		///
								`beta2hat',		///
								`ar_chi2',		///
								`wald_chi2',	///
								`wald_p',		///
								`ar_p',			///
								`wald_r',		///
								`ar_r',			///
								`rk'			///
								)
				mat `citable'[`counter',1] = `civec'
			}

* write out confidence sets from rejection indicators
			if `clr_stat'==. {
				local clr_cset "."
			}
			foreach testname in `testlist' {
				if "``testname'_cset'"!="." { 
					if ``testname'_r'==0 {
						if ``testname'_rbegin'==0 {
							local `testname'_rbegin=`counter'
							if `counter'==1 {
								local `testname'_rbegin_null "   ...  "
							}
							else {
								local `testname'_rbegin_null : di %8.0g `gridnull'
							}
						}
						local `testname'_rend=`counter'
						if `counter'==`points' {
							local `testname'_rend_null "   ...  "
							}
							else {
								local `testname'_rend_null : di %8.0g `gridnull'
							}
					}
					if ``testname'_r'==1 | (``testname'_r'==0 & `counter'==`points') {
						if ``testname'_rbegin'>0 & ``testname'_rend'>0 & (``testname'_rbegin'==``testname'_rend' & `counter'<`points') {
							local rnull : di %8.0g "``testname'_rbegin_null'"
							if length("``testname'_cset'")==0	local `testname'_cset "`rnull'"
							else								local `testname'_cset "``testname'_cset' U `rnull'"
							local `testname'_rbegin=0
							local `testname'_rend=0
						}
						else if ``testname'_rbegin'>0 & ``testname'_rend'>0 & (``testname'_rbegin'<``testname'_rend' | `counter'==`points') {
							local rnull1 "``testname'_rbegin_null'"
							local rnull2 "``testname'_rend_null'"
							if length("``testname'_cset'")==0	local `testname'_cset "[`rnull1',`rnull2']"
							else								local `testname'_cset "``testname'_cset' U [`rnull1',`rnull2']"
							local `testname'_rbegin=0
							local `testname'_rend=0
						}
					}
				}
			}
		}	// end loop over grid points

* Finish up
		foreach testname in `testlist' {
			if length("``testname'_cset'")==0 {
				local `testname'_cset "null set"
			}
			tokenize "``testname'_cset'", parse(",[] ")
			local wcount : word count `*'
* If cset is "[   ...  ,   ...  ]" then it has 5 tokenized elements and #2=#4="..."
			if `wcount'==5 & "`2'"=="..." & "`4'"=="..." {
				local `testname'_cset "entire grid"
			}
			return local `testname'_cset "``testname'_cset'"
		}

		return scalar points=`points'
		return matrix citable=`citable'
		return scalar npd=`npd'
		local gridmin : di %8.0g `gridmin'
		local gridmax : di %8.0g `gridmax'
		return local grid_description "[`gridmin',`gridmax']"

end		// end construct_ci1w1s

program define construct_ci, rclass
	version 10.1
	syntax [,							///
				iid(integer 0)			///
				usegrid(integer 0)		///
				depvar(varname ts)		///
				endo(varname ts)		///
				exexog(varlist ts)		///
				inexog(varlist ts)		///
				touse(varname ts)		///
				wtexp(string)			///
				NOConstant				///
				nexexog(integer 0)		///
				nendog(integer 0)		///
				nsendog(integer 0)		///
				ssa(real 0)				///
				dofminus(real 0)		///
				overid(integer 0)		///
				level(real 0)			///
				kj_level(real 0)		///
				j_level(real 0)			///
				ar_level(real 0)		///
				alpha(real 0)			///
				kwt(real 0)				///
				n(integer 0)			///
				grid(numlist)			///
				gridlimits(numlist)		///
				gridmult(real 0)		///
				points(integer 0)		///
				ivbeta(real 0)			///
				ivbetase(real 0)		///
				var_pi_z(name local)	///
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
				lm(integer 0)			///
				forcerobust(string)		///
			]

		if `overid' {
		 	local testlist "ar k j kj clr"
		 }
		else {
			local testlist "ar"
		}

* construct confidence intervals if requested
* has user specified grid or numerical estimation of confidence sets? (numerical estimation only for homoskedastic 2sls)
		if `iid' & (`usegrid'==0) & (`forcerobust'==0) {
			invertivtests_closedform,		///
				ry1(`depvar')				///
				ry2(`endo')					///
				rinst(`exexog')				///
				exog(`inexog')				///
				touse(`touse')				///
				wtexp(`wtexp')				///
				consopt(`noconstant')		///
				df(`nexexog')				///
				level(`level')				///
				n(`n')						///
				ssa(`ssa')					///
				dofminus(`dofminus')
			foreach testname in `testlist' {
				if length("`r(`testname'_cset)'")==0 {
					local `testname'_cset "null set"
				}
				return local `testname'_cset "`r(`testname'_cset)'"
			}
		}
		else {

			get_gridlist,						///
				grid(`grid')					///
				gridlimits(`gridlimits')		///
				gridmult(`gridmult')			///
				points(`points')				///
				ivbeta(`ivbeta')				///
				ivbetase(`ivbetase')			///
				alpha(`alpha')

			local gridlist	"`r(gridlist)'"
			local points	=r(points)
			local gridmin	=r(gridmin)
			local gridmax	=r(gridmax)

* create a matrix to store test results for confidence interval
			tempname citable
			if `overid' {
				mat `citable' = J(`points', 19, 0)
				mat colnames `citable' =				///
											null		///
											wald_chi2	///
											ar_chi2		///
											k_chi2		///
											j_chi2		///
											clr_stat	///
											wald_p		///
											ar_p		///
											k_p			///
											j_p			///
											kj_p		///
											clr_p		///
											wald_r		///
											ar_r		///
											k_r			///
											j_r			///
											kj_r		///
											clr_r		///
											rk
			}
			else {
				mat `citable' = J(`points', 8, 0)
				mat colnames `citable' =				///
											null		///
											wald_chi2	///
											ar_chi2		///
											wald_p		///
											ar_p		///
											wald_r		///
											ar_r		///
											rk
			}
	
* create macros for storing confidence sets
			foreach testname in `testlist' {
				local `testname'_cset ""
				local `testname'_rbegin=0
				local `testname'_rend=0
				local `testname'_rbegin_null=0
				local `testname'_rend_null=0
			}
			tempname rk ar_p ar_chi2 ar_df k_p k_chi2 k_df j_p j_chi2 j_df kj_p kj_chi2 ///
				clr_p clr_stat clr_df ar_r k_r j_r kj_dnr kj_r kj_p clr_r				///
				wald_chi2 wald_p wald_r wald_df
* npd is flag set to 1 if npd matices encountered
			local npd = 0
			local counter = 0
			_dots `counter' 0, title(Estimating confidence sets over grid points)
			foreach gridnull in `gridlist' {
				local ++counter
				_dots `counter' 0
* calculate test stats
				if `iid' & (`forcerobust'==0) {
					computeivtests_iid,				///
						var_pi_z(`var_pi_z')		///
						pi_z(`pi_z')				///
						var_del(`var_del')			///
						del_z(`del_z')				///
						del_v(`del_v')				///
						ivbeta(`ivbeta')			///
						ivbetase(`ivbetase')		///
						null(`gridnull')			///
						syy(`syy')					///
						see(`see')					///
						sxy(`sxy')					///
						sve(`sve')					///
						sxx(`sxx')					///
						svv(`svv')					///
						lm(`lm')

				}
				else {
					mata: computeivtests_robust(	///
								"`del_z'",			///
								"`var_del'",		///
								"`pi_z'",			///
								"`var_pi_z'",		///
								"`var_pidel_z'",	///
								`ivbeta',			///
								`ivbetase',			///
								`gridnull')
					local npd=max(`npd',r(npd))
				}
				scalar `ar_chi2'=r(ar_chi2)
				scalar `k_chi2'=r(k_chi2)
				scalar `j_chi2'=r(j_chi2)
				scalar `clr_stat'=r(clr_stat)
				scalar `rk'=r(rk)
				scalar `wald_chi2'=r(wald_chi2)
				local nullstring "[`gridnull']"
* calculate test statistics, p-values, and rejection indicators from above matrices
				compute_pvals,					///
					null("`nullstring'")		///
					rk(`rk')					///
					nexexog(`nexexog')			///
					nendog(`nendog')			///
					nsendog(`nsendog')			///
					level(`level')				///
					kj_level(`kj_level')		///
					j_level(`j_level')			///
					ar_level(`ar_level')		///
					ar_p(`ar_p')				///
					ar_chi2(`ar_chi2')			///
					k_p(`k_p')					///
					k_chi2(`k_chi2')			///
					j_p(`j_p')					///
					j_chi2(`j_chi2')			///
					kj_p(`kj_p')				///
					kj_chi2(`kj_chi2')			///
					clr_p(`clr_p')				///
					clr_stat(`clr_stat')		///
					ar_df(`ar_df')				///
					k_df(`k_df')				///
					j_df(`j_df')				///
					clr_df(`clr_df')			///
					ar_r(`ar_r')				///
					k_r(`k_r')					///
					j_r(`j_r')					///
					kj_dnr(`kj_dnr')			///
					kj_r(`kj_r')				///
					kj_p(`kj_p')				///
					clr_r(`clr_r')				///
					wald_chi2(`wald_chi2')		///
					wald_p(`wald_p')			///
					wald_r(`wald_r')			///
					wald_df(`wald_df')			///
					kwt(`kwt')
		
				tempname civec
				if `overid' {
					mat `civec' = (					///
									`gridnull',		///
									`wald_chi2',	///
									`ar_chi2',		///
									`k_chi2',		///
									`j_chi2',		///
									`clr_stat',		///
									`wald_p',		///
									`ar_p',			///
									`k_p',			///
									`j_p',			///
									`kj_p',			///
									`clr_p',		///
									`wald_r',		///
									`ar_r',			///
									`k_r',			///
									`j_r',			///
									`kj_r',			///
									`clr_r',		///
									`rk'			///
									)
					mat `citable'[`counter',1] = `civec'
				}
				else {
					mat `civec' = (					///
									`gridnull',		///
									`ar_chi2',		///
									`wald_chi2',	///
									`wald_p',		///
									`ar_p',			///
									`wald_r',		///
									`ar_r',			///
									`rk'			///
									)
					mat `citable'[`counter',1] = `civec'
				}
	
* write out confidence sets from rejection indicators
				if `clr_stat'==. {
					local clr_cset "."
				}
				foreach testname in `testlist' {
					if "``testname'_cset'"!="." { 
						if ``testname'_r'==0 {
							if ``testname'_rbegin'==0 {
								local `testname'_rbegin=`counter'
								if `counter'==1 {
									local `testname'_rbegin_null "   ...  "
								}
								else {
									local `testname'_rbegin_null : di %8.0g `gridnull'
								}
							}
							local `testname'_rend=`counter'
							if `counter'==`points' {
								local `testname'_rend_null "   ...  "
								}
								else {
									local `testname'_rend_null : di %8.0g `gridnull'
								}
						}
						if ``testname'_r'==1 | (``testname'_r'==0 & `counter'==`points') {
							if ``testname'_rbegin'>0 & ``testname'_rend'>0 & (``testname'_rbegin'==``testname'_rend' & `counter'<`points') {
								local rnull : di %8.0g "``testname'_rbegin_null'"
								if length("``testname'_cset'")==0	local `testname'_cset "`rnull'"
								else								local `testname'_cset "``testname'_cset' U `rnull'"
								local `testname'_rbegin=0
								local `testname'_rend=0
							}
							else if ``testname'_rbegin'>0 & ``testname'_rend'>0 & (``testname'_rbegin'<``testname'_rend' | `counter'==`points') {
								local rnull1 "``testname'_rbegin_null'"
								local rnull2 "``testname'_rend_null'"
								if length("``testname'_cset'")==0	local `testname'_cset "[`rnull1',`rnull2']"
								else								local `testname'_cset "``testname'_cset' U [`rnull1',`rnull2']"
								local `testname'_rbegin=0
								local `testname'_rend=0
							}
						}
					}
				}
			}	// end loop over grid points

* Finish up
			foreach testname in `testlist' {
				if length("``testname'_cset'")==0 {
					local `testname'_cset "null set"
				}
				tokenize "``testname'_cset'", parse(",[] ")
				local wcount : word count `*'
* If cset is "[   ...  ,   ...  ]" then it has 5 tokenized elements and #2=#4="..."
				if `wcount'==5 & "`2'"=="..." & "`4'"=="..." {
					local `testname'_cset "entire grid"
				}
				return local `testname'_cset "``testname'_cset'"
			}
	
			return scalar points=`points'
			return matrix citable=`citable'
			return scalar npd=`npd'
			local gridmin : di %8.0g `gridmin'
			local gridmax : di %8.0g `gridmax'
			return local grid_description "[`gridmin',`gridmax']"
		}	// end non-closed-form code

end		// end construct_ci

program define construct_ci2, rclass
	version 10.1
	syntax [,							///
				iid(integer 0)			///
				usegrid(integer 0)		///
				depvar(varname ts)		///
				endo1(varname ts)		///
				endo2(varname ts)		///
				exexog(varlist ts)		///
				inexog(varlist ts)		///
				touse(varname ts)		///
				wtexp(string)			///
				NOConstant				///
				nexexog(integer 0)		///
				nendog(integer 0)		///
				nsendog(integer 0)		///
				overid(integer 0)		///
				level(real 0)			///
				kj_level(real 0)		///
				j_level(real 0)			///
				ar_level(real 0)		///
				alpha(real 0)			///
				kwt(real 0)				///
				n(integer 0)			///
				grid(numlist)			///
				gridlimits1(numlist)	///
				gridlimits2(numlist)	///
				gridmult(real 0)		///
				points1(integer 0)		///
				points2(integer 0)		///
				ivbeta1(real 0)			///
				ivbeta2(real 0)			///
				ivbetase1(real 0)		///
				ivbetase2(real 0)		///
				var_pi_z(name local)	///
				pi_z(name local)		///
				var_del(name local)		///
				del_z(name local)		///
				del_v(name local)		///
				var_pidel_z(name local)	///
				var_beta(name local)	///
				syy(name)				///
				see(name)				///
				sxy(name)				///
				sve(name)				///
				sxx(name)				///
				svv(name)				///
				lm(integer 0)			///
				forcerobust(string)		///
			]

		if `overid' {
		 	local testlist "ar k j kj clr"
		 }
		else {
			local testlist "ar"
		}

* Construct grid
		get_gridlist,						///
			grid(`grid1')					///
			gridlimits(`gridlimits1')		///
			gridmult(`gridmult')			///
			points(`points1')				///
			ivbeta(`ivbeta1')				///
			ivbetase(`ivbetase1')			///
			alpha(`alpha')

		local gridlist1	"`r(gridlist)'"
		local points1	=r(points)
		local gridmin1	=r(gridmin)
		local gridmax1	=r(gridmax)

		get_gridlist,						///
			grid(`grid2')					///
			gridlimits(`gridlimits2')		///
			gridmult(`gridmult')			///
			points(`points2')				///
			ivbeta(`ivbeta2')				///
			ivbetase(`ivbetase2')			///
			alpha(`alpha')

		local gridlist2	"`r(gridlist)'"
		local points2	=r(points)
		local gridmin2	=r(gridmin)
		local gridmax2	=r(gridmax)

* create a matrix to store test results for confidence interval
		tempname citable
		local rows = `points1'*`points2'
		if `overid' {
			mat `citable' = J(`rows', 16, 0)
			mat colnames `citable' =				///
										null1		///
										null2		///
										wald_chi2	///
										ar_chi2		///
										k_chi2		///
										j_chi2		///
										wald_p		///
										ar_p		///
										k_p			///
										j_p			///
										kj_p		///
										wald_r		///
										ar_r		///
										k_r			///
										j_r			///
										kj_r
		}
		else {
			mat `citable' = J(`rows', 8, 0)
			mat colnames `citable' =				///
										null1		///
										null2		///
										wald_chi2	///
										ar_chi2		///
										wald_p		///
										ar_p		///
										wald_r		///
										ar_r
		}
	
		tempname rk ar_p ar_chi2 ar_df k_p k_chi2 k_df j_p j_chi2 j_df kj_p kj_chi2 ///
			clr_p clr_stat clr_df ar_r k_r j_r kj_dnr kj_r kj_p clr_r				///
			wald_p wald_chi2 wald_df wald_r
* npd is flag set to 1 if npd matices encountered
		local npd = 0
		local counter = 0
		_dots `counter' 0, title(Estimating confidence sets over grid points)
		foreach gridnull1 in `gridlist1' {
			foreach gridnull2 in `gridlist2' {
				local ++counter
				_dots `counter' 0
* calculate test stats
				if `iid' & (`forcerobust'==0) {
					computeivtests_iid2,			///
						var_pi_z(`var_pi_z')		///
						pi_z(`pi_z')				///
						var_del(`var_del')			///
						del_z(`del_z')				///
						del_v(`del_v')				///
						ivbeta1(`ivbeta1')			///
						ivbeta2(`ivbeta2')			///
						var_beta(`var_beta')		///
						null1(`gridnull1')			///
						null2(`gridnull2')			///
						nexexog(`nexexog')			///
						syy(`syy')					///
						see(`see')					///
						sxy(`sxy')					///
						sve(`sve')					///
						sxx(`sxx')					///
						svv(`svv')					///
						lm(`lm')
				}
				else {
					mata: computeivtests_robust2(	///
								"`del_z'",			///
								"`var_del'",		///
								"`pi_z'",			///
								"`var_pi_z'",		///
								"`var_pidel_z'",	///
								"`var_beta'",		///
								`ivbeta1',			///
								`ivbeta2',			///
								`gridnull1',		///
								`gridnull2')
				}
				local npd=max(`npd',r(npd))
				scalar `wald_chi2'=r(wald_chi2)
				scalar `ar_chi2'=r(ar_chi2)
				scalar `k_chi2'=r(k_chi2)
				scalar `j_chi2'=r(j_chi2)
				scalar `clr_stat'=r(clr_stat)
				scalar `rk'=r(rk)
				local nullstring "[`gridnull1', `gridnull2']"
* calculate test statistics, p-values, and rejection indicators from above matrices
				compute_pvals,					///
					null("`nullstring'")		///
					rk(`rk')					///
					nexexog(`nexexog')			///
					nendog(`nendog')			///
					nsendog(`nsendog')			///
					level(`level')				///
					kj_level(`kj_level')		///
					j_level(`j_level')			///
					ar_level(`ar_level')		///
					ar_p(`ar_p')				///
					ar_chi2(`ar_chi2')			///
					k_p(`k_p')					///
					k_chi2(`k_chi2')			///
					j_p(`j_p')					///
					j_chi2(`j_chi2')			///
					kj_p(`kj_p')				///
					kj_chi2(`kj_chi2')			///
					clr_p(`clr_p')				///
					clr_stat(`clr_stat')		///
					ar_df(`ar_df')				///
					k_df(`k_df')				///
					j_df(`j_df')				///
					clr_df(`clr_df')			///
					ar_r(`ar_r')				///
					k_r(`k_r')					///
					j_r(`j_r')					///
					kj_dnr(`kj_dnr')			///
					kj_r(`kj_r')				///
					kj_p(`kj_p')				///
					clr_r(`clr_r')				///
					wald_chi2(`wald_chi2')		///
					wald_p(`wald_p')			///
					wald_r(`wald_r')			///
					wald_df(`wald_df')			///
					kwt(`kwt')

				tempname civec
				if `overid' {
					mat `civec' = (					///
									`gridnull1',	///
									`gridnull2',	///
									`wald_chi2',	///
									`ar_chi2',		///
									`k_chi2',		///
									`j_chi2',		///
									`wald_p',		///
									`ar_p',			///
									`k_p',			///
									`j_p',			///
									`kj_p',			///
									`wald_r',		///
									`ar_r',			///
									`k_r',			///
									`j_r',			///
									`kj_r'			///
									)
					mat `citable'[`counter',1] = `civec'
				}
				else {
					mat `civec' = (					///
									`gridnull1',	///
									`gridnull2',	///
									`ar_chi2',		///
									`wald_chi2',	///
									`wald_p',		///
									`ar_p',			///
									`wald_r',		///
									`ar_r'			///
									)
					mat `citable'[`counter',1] = `civec'
				}
			}
		}	// end loop over grid points

* Finish up	
		return scalar points1=`points1'
		return scalar points2=`points2'
		return matrix citable=`citable'
		return scalar npd=`npd'
		local gridmin1 : di %8.0g `gridmin1'
		local gridmin2 : di %8.0g `gridmin2'
		local gridmax1 : di %8.0g `gridmax1'
		local gridmax2 : di %8.0g `gridmax2'
		return local grid_description "[`gridmin1',`gridmax1'] and [`gridmin2',`gridmax2']"

end		// end construct_ci2



program computeivtests_iid, rclass
	syntax [,							///
				var_pi_z(name)			///
				pi_z(name)				///
				var_del(name)			///
				del_z(name)				///
				del_v(name)				///
				ivbeta(real 0)			///
				ivbetase(real 0)		///
				null(string)			///
				syy(name)				///
				see(name)				///
				sxy(name)				///
				sve(name)				///
				sxx(name)				///
				svv(name)				///
				lm(real 0)				///
				 *]

	tempname r invpsi pi_beta rk ar_chi2 k_chi2 j_chi2 clr_stat wald_chi2
	tempname s2 s2lm

* matrices for test stats
		mat `r' = `del_z' - `pi_z' * (`null')
		mat `invpsi' = invsym(`var_del' + (`del_v'[1,1] - (`null'))^2 * `var_pi_z')
		mat `pi_beta' = `pi_z'' - `var_pi_z'*`invpsi'*`r''*(`del_v'[1,1] - (`null'))
		mat `rk' = `pi_beta''*inv(`var_pi_z'-(`del_v'[1,1]-(`null'))^2 * `var_pi_z'*`invpsi'*`var_pi_z')*`pi_beta'
		scalar `rk' = `rk'[1,1]
		mat `ar_chi2' = `r'*`invpsi'*`r''
		scalar `ar_chi2' = `ar_chi2'[1,1]
		mat `k_chi2' = `r'*`invpsi'*`pi_beta'*inv(`pi_beta''*`invpsi'*`pi_beta')*`pi_beta''*`invpsi'*`r''
		scalar `k_chi2' = `k_chi2'[1,1]
		scalar `j_chi2' = `ar_chi2' - `k_chi2'
		scalar `clr_stat' = .5*(`ar_chi2'-`rk'+sqrt((`ar_chi2'+`rk')^2 - 4*`j_chi2'*`rk'))
* Can get CLR<0 because of numerical precision issues, hence abs(.)
		scalar `clr_stat' = abs(`clr_stat')
		scalar `wald_chi2' = ((`ivbeta'-(`null'))/`ivbetase')^2
		if `lm' {
* In iid case with K=1, LM versions of AR, K and J are just rescalings of MD/Wald versions
* CLR does not change.
			scalar `s2lm' = `syy' - 2*`null'*`sxy' + (`null')^2*`sxx'
			scalar `s2'   = `see' - 2*`null'*`sve' + (`null')^2*`svv'
			scalar `ar_chi2' = `ar_chi2' * `s2'/`s2lm'
			scalar `k_chi2'  = `k_chi2'  * `s2'/`s2lm'
			scalar `j_chi2' = `ar_chi2' - `k_chi2'
		}
* return tests in r()
		return scalar rk=`rk'
		return scalar ar_chi2=`ar_chi2'
		return scalar k_chi2=`k_chi2'
		return scalar j_chi2=`j_chi2'
		return scalar clr_stat=`clr_stat'
		return scalar wald_chi2=`wald_chi2'
end

program computeivtests_iid2, rclass
	syntax [,							///
				var_pi_z(name)			///
				pi_z(name)				///
				var_del(name)			///
				del_z(name)				///
				del_v(name)				///
				ivbeta1(real 0)			///
				ivbeta2(real 0)			///
				var_beta(name)			///
				null1(real 0)			///
				null2(real 0)			///
				nexexog(integer 0)		///
				syy(name)				///
				see(name)				///
				sxy(name)				///
				sve(name)				///
				sxx(name)				///
				svv(name)				///
				lm(real 0)				///
				*]
	tempname r rwald ivbeta null kron psi invpsi vecD pi_beta rk ar_chi2 k_chi2 j_chi2 clr_stat wald_chi2 bracket
	tempname s2 s2lm
* matrices for test stats
		mat `ivbeta' = `ivbeta1' \ `ivbeta2'
		mat `null' = `null1' \ `null2'
		mat `r' = `del_z' - `pi_z' * `null'
		mat `rwald' = `ivbeta' - `null'
		mat `kron' = (`del_v' - `null') # I(`nexexog')
		mat `psi' = `var_del' + `kron'' * `var_pi_z' * `kron'
		mat `invpsi' = invsym(`psi')
		mat `bracket' = `invpsi' * `r' * (`del_v' - `null')'
		mat `vecD' = -vec(`pi_z') + `var_pi_z'*vec(`bracket')
		mat `pi_beta' = `vecD'[1..`nexexog',1] , `vecD'[`nexexog'+1..2*`nexexog',1]
		mat `ar_chi2' = `r''*`invpsi'*`r'
		scalar `ar_chi2' = `ar_chi2'[1,1]
		mat `k_chi2' = `r''*`invpsi'*`pi_beta'*inv(`pi_beta''*`invpsi'*`pi_beta')*`pi_beta''*`invpsi'*`r'
		scalar `k_chi2' = `k_chi2'[1,1]
		if `lm' {
			matrix `s2lm' = `syy' - 2*`null''*`sxy' + `null''*`sxx'*`null'
			scalar `s2lm' = `s2lm'[1,1]
			matrix `s2'   = `see' - 2*`null''*`sve' + `null''*`svv'*`null'
			scalar `s2'   = `s2'[1,1]
			scalar `ar_chi2' = `ar_chi2' * `s2'/`s2lm'
			scalar `k_chi2'  = `k_chi2'  * `s2'/`s2lm'
		}
		mat `j_chi2' = `ar_chi2' - `k_chi2'
		scalar `j_chi2' = `j_chi2'[1,1]
		mat `wald_chi2' = `rwald'' * invsym(`var_beta') * `rwald'
		scalar `wald_chi2' = `wald_chi2'[1,1]
* return tests in r()
		return scalar ar_chi2=`ar_chi2'
		return scalar k_chi2=`k_chi2'
		return scalar j_chi2=`j_chi2'
		return scalar wald_chi2=`wald_chi2'
end


mata:
void computeivtests_robust2(								///
							string scalar del_z_name,		///
							string scalar var_del_name,		///
							string scalar pi_z_name,		///
							string scalar var_pi_z_name,	///
							string scalar var_pidel_z_name,	///
							string scalar var_beta_name,	///
							scalar ivbeta1,					///
							scalar ivbeta2,					///
							scalar null1,					///
							scalar null2					///
							)
{

		del_z		=st_matrix(del_z_name)
		var_del		=st_matrix(var_del_name)
		pi_z		=st_matrix(pi_z_name)
		var_pi_z	=st_matrix(var_pi_z_name)
		var_pidel_z	=st_matrix(var_pidel_z_name)
		var_beta	=st_matrix(var_beta_name)

		nexexog=rows(pi_z)
		ivbeta=(ivbeta1 \ ivbeta2)
		null=(null1 \ null2)
		r = del_z - pi_z*null
		rwald = ivbeta - null

		aux0 = cholsolve(var_beta,rwald)
		if (aux0[1,1]==.) {
			npd = 1
			aux0 = qrsolve(var_beta,rwald)
		}

// Assemble psi
		kron = (null#I(nexexog))
		psi=var_del - kron'*var_pidel_z - (kron'*var_pidel_z)' + kron' * var_pi_z * kron

		aux1 = cholsolve(psi,r)
		if (aux1[1,1]==.) {
			npd = 1
			aux1 = qrsolve(psi,r)
		}

		bracket = var_pidel_z - var_pi_z*kron
		psi_inv=invsym(psi)
		vecD = -vec(pi_z) + bracket*psi_inv*r
		D1 = vecD[|1,1 \ nexexog,1|]
		D2 = vecD[|nexexog+1,1 \ 2*nexexog,1|] 
		pi_beta=(D1,D2)

// rk - not yet supported
//		xi_bracket = var_pidel_z' - kron' * var_pi_z
//		xi = var_pi_z - xi_bracket' * psi_inv * xi_bracket
//		xi_inv = invsym(xi)
//		rk = (vec(pi_beta))' * xi_inv * vec(pi_beta)
// Cholesky method for rk - same result
		aux2 = var_pidel_z - var_pi_z*kron
		aux3 = cholsolve(psi,aux2')
		if (aux3[1,1]==.) {
			npd = 1
			aux3 = qrsolve(psi,aux2')
		}
		aux4 = var_pi_z - aux2 * aux3
		rk = cholsolve(aux4, vec(pi_beta))
		rk = vec(pi_beta)' * rk
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

// calculate test stats
		wald_chi2 = rwald' * aux0
		ar_chi2 = r' * aux1
		k_chi2 = r' * aux5 * aux6 * aux1
		j_chi2 = ar_chi2 - k_chi2
// CLR and rk calculated but not yet supported
		clr_stat = .5*(ar_chi2-rk+sqrt((ar_chi2+rk)^2 - 4*j_chi2*rk))
		if (rk[1,1]<=0)			clr_stat=.		
// return test stats in r()
// currently rk and CLR not supported so return missing
		st_numscalar("r(wald_chi2)", wald_chi2[1,1])
		st_numscalar("r(ar_chi2)", ar_chi2[1,1])
		st_numscalar("r(k_chi2)", k_chi2[1,1])
		st_numscalar("r(j_chi2)", j_chi2[1,1])
//		st_numscalar("r(clr_stat)", clr_stat[1,1])
//		st_numscalar("r(rk)", rk[1,1])
		st_numscalar("r(clr_stat)", .)
		st_numscalar("r(rk)", .)
		st_numscalar("r(npd)", npd)
}
end

mata:
void computeivtests_robust(									///
							string scalar del_z_name,		///
							string scalar var_del_name,		///
							string scalar pi_z_name,		///
							string scalar var_pi_z_name,	///
							string scalar var_pidel_z_name,	///
							scalar ivbeta,					///
							scalar ivbetase,				///
							scalar null						///
							)
{

	del_z		=st_matrix(del_z_name)
	var_del		=st_matrix(var_del_name)
	pi_z		=st_matrix(pi_z_name)
	var_pi_z	=st_matrix(var_pi_z_name)
	var_pidel_z	=st_matrix(var_pidel_z_name)

// calculate matrices for test stats
		npd=0
		r=del_z - pi_z * (null)
		psi=var_del-(null)*var_pidel_z-(null)*var_pidel_z'+((null)^2)*var_pi_z
		aux1 = cholsolve(psi,r')
		if (aux1[1,1]==.) {
			npd = 1
			aux1 = qrsolve(psi,r')
		}
		pi_beta = pi_z' - (var_pidel_z-(null)*var_pi_z)*aux1
		aux2 = var_pidel_z - (null)*var_pi_z
		aux3 = cholsolve(psi,aux2')
		if (aux3[1,1]==.) {
			npd = 1
			aux3 = qrsolve(psi,aux2')
		}
		aux4 = var_pi_z - aux2 * aux3
		rk = cholsolve(aux4, pi_beta)
		if (rk[1,1]==.) {
			npd = 1
			rk = qrsolve(aux3,pi_beta)
		}
		rk = pi_beta' * rk
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
// calculate test stats
		wald_chi2 = ((ivbeta-null)/ivbetase)^2
		ar_chi2 = r * aux1
		k_chi2 = r * aux5 * aux6 * aux1
		j_chi2 = ar_chi2 - k_chi2
		clr_stat = .5*(ar_chi2-rk+sqrt((ar_chi2+rk)^2 - 4*j_chi2*rk))
		if (rk[1,1]<=0)			clr_stat=.
// return test stats in r()
		st_numscalar("r(wald_chi2)", wald_chi2[1,1])
		st_numscalar("r(ar_chi2)", ar_chi2[1,1])
		st_numscalar("r(k_chi2)", k_chi2[1,1])
		st_numscalar("r(j_chi2)", j_chi2[1,1])
		st_numscalar("r(clr_stat)", clr_stat[1,1])
		st_numscalar("r(rk)", rk[1,1])
		st_numscalar("r(npd)", npd)
}
end


program compute_pvals
	syntax [,						///
				null(string)		///
				rk(name)			///
				nexexog(string)		///
				nendog(string)		///
				nsendog(string)		///
				level(string)		///
				kj_level(string)	///
				j_level(string)		///
				ar_level(string)	///
				ar_p(name)			///
				ar_chi2(name)		///
				ar_df(name)			///
				ar_r(name)			///
				k_p(name)			///
				k_chi2(name)		///
				k_df(name)			///
				k_r(name)			///
				j_p(name)			///
				j_chi2(name)		///
				j_df(name)			///
				j_r(name)			///
				kj_dnr(name)		///
				kj_r(name)			///
				kj_p(name)			///
				kwt(string)			///
				clr_p(name)			///
				clr_stat(name)		///
				clr_df(name)		///
				clr_r(name)			///
				wald_p(name)		///
				wald_chi2(name)		///
				wald_r(name)		///
				wald_df(name)		///
				 *]
	scalar `wald_df' = `nendog' - `nsendog'
	scalar `wald_p' = chi2tail(`nendog',`wald_chi2')
	scalar `ar_df' = `nexexog' - `nsendog'
	scalar `ar_p'= chi2tail(`ar_df',`ar_chi2')
	if `nexexog'>`nendog' {
		scalar `k_df' = `nendog' - `nsendog'
		scalar `k_p'= chi2tail(`k_df',`k_chi2')
		scalar `j_df' = `nexexog'-`nendog'
		scalar `j_p'= chi2tail(`j_df',`j_chi2')
		scalar `clr_df' = .
	}
* Poi and Mikusheva's method of estimating CLR p-value (subprogram below-taken directly from Mikusheva and Poi's code)
	if `nexexog'>`nendog' {
		if `clr_stat'==.		scalar `clr_p'=.
		else {
			new_try `nexexog' `rk' `clr_stat' `clr_p'
* fix negative p-value approximations that occur because of rounding near zero 
			if `clr_p'<=-0.00001 & `clr_p'>-9999999	{
noi di as err "error when approximating CLR p-value for null = `null'"
			}	
			if `clr_p'<0 {
				scalar `clr_p'=0.000000
			}
		}
	}
* compute reject/dn reject binary
	scalar `ar_r' = cond(`ar_p'<=1-`ar_level'/100,1,0)
	scalar `wald_r' = cond(`wald_p'<=1-`level'/100,1,0)
	if `nexexog'>`nendog' {
		scalar `k_r' = cond(`k_p'<=1-`level'/100,1,0)
		scalar `j_r' = cond(`j_p'<=1-`j_level'/100,1,0)
* Uses R = (1-p1)(1-p2) ~= p1+p2 (since p1*p2 negligible for small alphas/ps)
*		scalar `kj_dnr' = cond((`k_p'>=(1-`level'/100)*`kwt')&(`j_p'>=(1-`level'/100)*(1-`kwt')),1,0)			
*		scalar `kj_r' = cond(`kj_dnr'==0,1,0)
*		scalar `kj_p' = min(`k_p'/`kwt',`j_p'/(1-`kwt'),0.995)
* Exact:
		local p1=`k_p'/`kwt'		*	(1 - (1-`kwt')*`k_p')
		local p2=`j_p'/(1-`kwt')	*	(1 - `kwt'*`j_p')
		scalar `kj_p' = min(`p1',`p2')
		scalar `kj_r' = cond(`kj_p'<=1-`kj_level'/100,1,0)
		if `clr_stat'==.		scalar `clr_r' = .
		else					scalar `clr_r' = cond(`clr_p'<=1-`level'/100,1,0)
	}
end

************************************************************************************
*** Subroutines from Mikusheva and Poi's condivreg:								 ***
*** 	invertivtests_closedform (adaptation), new_try, mat_inv_sqrt, inversefun ***
************************************************************************************

/* The following is an adaptation of the inversion code in Mikusheva and Poi's condivreg program */
/* NB: includes fixes related to df in denominator of omega and use of doubles */
program invertivtests_closedform, rclass
	syntax [,						///
				ry1(varname ts)		///
				ry2(varname ts)		///
				rinst(varlist ts)	///
				exog(varlist ts)	///
				touse(varname)		///
				wtexp(string)		///
				consopt(string)		///
				df(string)			///
				level(string)		///
				n(string)			///
				ssa(real 0)			///
				dofminus(real 0)	///
				* ]

* ry1 is depvar
* ry2 is endogenous regressor
* inst is excluded exogenous only with included exog partialled out
* local "k" is #exexog
* exog is included exogenous only BUT DOES NOT INCLUDE CONSTANT
* local "p" is #inexog NOT COUNTING CONSTANT
* local "cons" is 0/1 depending on whether constant is included
	tempvar y1 y2
	local cons=("`consopt'"=="")
	local k : word count `rinst'
	local p : word count `exog'
			
* generate projections
		if (`p'+`cons')>0 {									// something to partial out, even if only constant
				foreach v in y1 y2 {
					qui reg `r`v'' `exog' if `touse' `wtexp', `consopt'
					qui predict double ``v'' if `touse', residuals
				}
			}
			else {											// special case of no excl exog & no constant
				qui gen double `y1' = `ry1' if `touse'
				qui gen double `y2' = `ry2' if `touse'
			}
* regress instruments on exogenous 
		tempname ehold
		local inst = ""
		local j = 1
		foreach v in `rinst' {
			tempvar inst`j'
			if (`p'+`cons')>0 {								// something to partial out, even if only constant
				qui reg `v' `exog' if `touse' `wtexp', `consopt'
				qui predict double `inst`j'' if `touse', residuals
			}
			else {
				qui gen double `inst`j'' = `v' if `touse'	// special case of no excl exog & no constant
			}
			local inst "`inst' `inst`j''"
		}
* compute omega
		tempname mzy1 mzy2 omega
		qui reg `y1' `inst' if `touse' `wtexp', `consopt'
		qui predict double `mzy1' if `touse', residuals
		qui reg `y2' `inst' if `touse' `wtexp', `consopt'
		qui predict double `mzy2' if `touse', residuals
		qui mat accum `omega' = `mzy1' `mzy2' if `touse' `wtexp', noconstant
		mat `omega' = `omega' / (`n'-`dofminus') * `ssa'

* make stuff
		tempname cross zpz sqrtzpzi zpy MM ypz sqrtomegai v d M N alpha C A D aa x1 x2 g type
		local k=`df'
		qui mat accum `cross' = `inst' `y1' `y2' if `touse' `wtexp'
		mat `zpz' = `cross'[1..`k', 1..`k']
		mat `zpy' = `cross'[1..`k', (`k'+1)..(`k'+2)]
		mat_inv_sqrt `zpz' `sqrtzpzi'
		mat_inv_sqrt `omega' `sqrtomegai'
		mat `ypz'=`zpy''
		mat `MM' = `sqrtomegai'*`ypz'*inv(`zpz')*`zpy'*`sqrtomegai'
		mat symeigen `v' `d' = `MM'
		sca `M' = `d'[1,1]
		sca `N' =`d'[1,2]
		sca `alpha' = 1-`level'/100
* inversion of CLR
		inversefun `M' `df' `alpha' `C'
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
	 	*ereturn local LR_type `"`=`type''"'
	 	if `type' == 2 | `type' == 4 {
	 		*eret scalar LR_x1 = `x1'
	 		*eret scalar LR_x2 = `x2'
	 	}
* inversion of K
		tempname kcv q1 q2 A1 A2 D1 D2 y1 y2 y3 y4 type1
		sca `kcv' = invchi2tail(1, (1-`level'/100))
		if (`df'==1) {
			sca `q1' = `M'-`kcv'
			mat `A1' =inv(`omega')*`ypz'*inv(`zpz')*`zpy'*inv(`omega')-`q1'*inv(`omega')
			sca `D1' = -4*det(`A1')
			sca `y1'= (-2*`A1'[1,2]+sqrt(`D1'))/2/`A1'[1,1]
			sca `y2'= (-2*`A1'[1,2]-sqrt(`D1'))/2/`A1'[1,1]
			if (`A1'[1,1]>0) { 
				if (`D1'>0) {
					sca `type1'=4 
						/* two infinite intervals*/
					*eret scalar K_x1 = `y2'
					*eret scalar K_x2 = `y1'
					local k_cset : di "( -inf," %8.0g `y2' "] U [" %8.0g `y1' ", +inf )"
				}
				else {
					sca `type1'=3
					local k_cset : di "( -inf,  +inf )"
				}
			}
			else{
				if (`D1'>0) {
					sca `type1'=2 /*one interval */
					*eret scalar K_x1 = `y1'
					*eret scalar K_x2 = `y2'
					local k_cset : di "[" %8.0g `y1' "," %8.0g `y2' "]"
				}
				else {
					sca `type1'=3
					local k_cset : di "( -inf,  +inf )"
				}
			}
		}
		else {
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
							*eret scalar K_x1 = `y4'
							*eret scalar K_x2 = `y2'
							*eret scalar K_x3 = `y1'
							*eret scalar K_x4 = `y3'
							local k_cset : di "( -inf," %9.0g `y1' "] U [" %9.0g `y3' "," %9.0g `y4' "] U [" %9.0g `y2' ", +inf )"
						}
			  			else {
							sca `type1' = 6
							sca `y1' = (-2*`A1'[1,2] + sqrt(`D1'))/2/`A1'[1,1]
							sca `y2' = (-2*`A1'[1,2] - sqrt(`D1'))/2/`A1'[1,1]
							sca `y3' = (-2*`A2'[1,2] + sqrt(`D2'))/2/`A2'[1,1]
							sca `y4' = (-2*`A2'[1,2] - sqrt(`D2'))/2/`A2'[1,1]
							*eret scalar K_x1 = `y3'
							*eret scalar K_x2 = `y4'
							*eret scalar K_x3 = `y2'
							*eret scalar K_x4 = `y1'
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
						*eret scalar K_x1 = `y1'
						*eret scalar K_x2 = `y3'
						*eret scalar K_x3 = `y4'
						*eret scalar K_x4 = `y2'
						local k_cset : di "( -inf," %9.0g `y1' "] U [" %9.0g `y3' "," %9.0g `y4' "] U [" %9.0g `y2' ", +inf )"
			  		}
			    }
			}
		}
		*eret local K_type `"`=`type1''"'
* inversion of AR
		tempname kcv1  AAA type2 xx1 xx2 DDD aaa
		sca `kcv1' = invchi2tail(`df', (1-`level'/100))
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
				*eret scalar AR_x1 = `xx1'
				*eret scalar AR_x2 = `xx2'
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
				*eret scalar AR_x1 = `xx1'
				*eret scalar AR_x2 = `xx2'
				local ar_cset : di "[" %9.0g `xx1' "," %9.0g `xx2' "]"
 			}
	 	}
		*eret local AR_type `"`=`type2''"'
	/* formatting for confidence sets
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
* format and return confidence intervals
		return local clr_cset="`clr_cset'"
		return local k_cset="`k_cset'"
		return local ar_cset="`ar_cset'"

end

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
