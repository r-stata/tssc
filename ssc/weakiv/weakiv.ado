*! weakiv 2.4.07 1Oct2015
*! authors Finlay-Magnusson-Schaffer
* Usage:
* <eqn>, <options>         = estimate equation as model=linear/ivprobit/ivtobit.
* <nothing>, <options>     = uses model estimated by ivregress/ivreg2/etc. in memory
*                            if no such model in memory, works as Stata replay and
*                            replays last weakiv estimates. useful for graph tweaking.
* <nothing>, estusewald(*) = same as above but uses stored model
* <nothing>, version       = reports version number, does nothing else

* Version notes:
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
* 1.0.11    23May2014   Fixed contourshade bugs; can now control starting/ending color.
*                       Fixed minor contourlevel bugs (was ignoring additional specified levels)
* 2.0.00    26Jun2014   Major internal rewrite to accommodate xtabond2 and aribtrary number of endogenous vars.
*                       Changes include: always preserve/restore; always partial-out in linear models;
*                       support for factor variables; use of sclass programs for parsing;
*                       promoted to requiring Stata 11.2 (because of _rmcollright bug under version control v=10.1);
*                       tests reported for arbitrary number of weakly and strongly identified coeffs;
*                       CIs and graphs available for #weak=1 and #weak=2 and arbitrary number of strongly IDed;
*                       specification of null options changed to single numlist;
*                       misc minor changes to saved results
* 2.0.01	28Jun2014   Fix in xtabond2 parsing code to catch whether data in levels, diffs or both are used.
*                       xtabond2 parsing catches whether there are zero endogenous regressors.
*                       Fixed bug in npd flag not being set to 1 if npd matrix encountered in test of specific null.
*                       Fixed bug in use of marksample.
* 2.0.02	30Jun2014   Bug fixes: levels vs. diffs data with xtabond2; whether xtabond2 has K>0; output formatting;
*                       saved matrices to enable xtabond2 to work as postestimation command.
*                       Report various ob and var counts with xtabond2.  Report list of strongly identified.
*                       Added EQxtabond2(.) option to override default of diff/level/sys data.
*                       Added md option. Default method now LM for linear models, MD for others.
* 2.0.03	4July2014   Errors in pre-weakiv estimation command now capture-d rather than quietly-ed.
*                       Stata's built-in _rmcollright provided with Stata 12.1 (version 1.3.0  07apr2009) has
*                       a bug that doesn't allow it to accept weights, so replaced it with weakiv_rmcollright
*                       that has same functionality but with bug fixed.
*                       Mikusheva-Poi CLR code revised to assuming partialling-out.
*                       Fixed bug that arose if the weighting variable was also a regressor.
*                       Added support for xtabond2 with weights and with classical VCE.
*                       Added support for xtabond2 with non-panel-id clustering variable (version forthcoming)
* 2.0.04	5July2014   Fixed bug in reported names of endog/inexog regressors with xtabond2 and eq(.) option meant
*                       subset of data (just diff or lev out of total sys estimation) used.
* 2.0.05	5July2014   Caught minor bug where weakiv would crash with xtabond2 if #endog=0
* 2.0.06	17July2014  Catch and warn if graphs requested when #endog>2. Added g_min, g_max, g_avg macros.
*                       Recoded CI table in Mata to avoid Stata max matsize limit.  Total #points in output.
* 2.1.00    28July2014  Rewrite of code to allow grid searches in arbitrary number of dimensions.
*                       Rewrite of code to report projection-based inference
*                       Changes of options: gridpoints, gridlist, gridmin, gridmax
*                       Macro name change to grid_desc; new macro added points_desc
*                       Fixed bug in column order of stored nulls
*                       Fixed bug in reporting of CIs if interval started on last gridpoint
* 2.2.00    5Aug2014    Added subset AR test.  Added projection-based inference.  More code rewrites.
*                       Added cuestrong option for LIML and CUE estimation for strongly-IDed coeffs.
*                       Fixed bug in CIs with LM option - was using MD.  Strongly-IDed coeffs now saved in citable.
* 2.2.01    7Aug2014    Added scatter option for 2-way CI sets.  Added 2-way projection inference option.
*                       Projection-based CIs saved as e(.) matrices.
* 2.3.00    11Aug2014   rk statistic (K-P rank test) now always available.  CLR stat now always available.
*                       Added p-values for rk statistic.
*                       p-values for CLR stat available through simulation.
*                       Fixed bug in replay with project(.)
*                       Rationalized code (single routine for computing tests).
*                       Contourshade now default for 2-D graphs.
* 2.3.01    21Aug2014   Added testexog(.) option for including exogenous regressors in tests
* 2.3.02    24Aug2014   Fixed bug: 2-way graphs were leaving behind temporary variable
*                       Added testid option to report tests of underidentification
* 2.3.03    9Sept2014   Added cuepoint option for reporting CUE point estimates
*                       Added CUE-MD method for CUE with Wald/MD tests
* 2.3.04    12Sept2014  Fixed bug where project2(.) didn't trigger grid construction
*                       cuepoint option triggers centering of grid on CUE rather than original Wald estimator
*                       Allow spec with one gridpoint in a dimension
*                       (NB: first public release of version 2)
* 2.3.05    2Oct2014    Fixed bug in reporting of #exexog with xtabond2 - was reporting 0
*                       Added saved macro for #exexog
* 2.4.00    1Jan2015    Fixed bug in unsaved macro with list of CI tests.
*                       Changed replay to use saved macro list of tests.
*                       Added Wald to list of projection-based tests.
*                       Minor recoding to separate Wald CI code from CI code for rest of tests.
*                       Rewrite of code for extracting CIs; rejection indicators no longer saved;
*                       replay mode now triggers recalculation of CIs and rejection indicators.
*                       Minor changes to names of saved matrices (betas and VCEs)
*                       Rewrite of code for storing and working with CI tables; now only exist in Mata
*                       until end of program, when stored as e(.) if #rows <= 32,767.
*                       If citable is too large to start as e(citable),
*                       split into separate e(.) matrices of 10k rows each.
* 2.4.01    18Jan2015   Changed call to (xt)ivreg2 to use nooutput option so that warning messages are displayed.
*                       Checks whether ivreg2h is called with panel-data option (not currently supported)
* 2.4.02    9Feb2015    Fixed bug in gridlist option; was ignoring supplied list.
*                       Changed cuepoint option so that it triggers inclusion of CUE beta in grid
* 2.4.03    11Feb2015   Added support for updated xtabond2 - e(clustid) became e(clustid1)
*                       Fixed bugs causing tokenize to choke if string had commas, e.g., "l(1,2).somevar"
* 2.4.04    26Mar2015  	Added support for ivreg2 with factor variables; also general recoding of support
*                       for factor vars using -fvstrip- utility.
*                       Fixed bug in xtabond2 parsing code; now allows possibly-empty inexog list
*                       Fixed small bug in xtabond2 - wasn't reporting correct number of clusters in rare cases
*                       Fixed reporting of stats when encountering NPDs - negative stats are changed to missing
* 2.4.05    15Jun2015   Update to internal utility fvstrip
* 2.4.06    1July2015   Bug fix - projection intervals were not accepting non-integer K-J test level.
*                       Code tweak - "capture drop __wt" changed to "capture drop __wt1"
* 2.4.07    1Oct2015    Rewrite of code to parse xtabond2.
* 2.4.08    16Feb2016   Bug fix - cuepoint option with exactly-IDed model was causing LIML code to crash.
* 2.4.09    15Oct2016   Fix to catch new Stata 14 behavior of ivprobit - "twostep" now saved in e(method).

* to do: possibly allow non-integer test levels e.g. arlevel(85.5)
*        note possible upper limit to points that contour can render; use scatter option instead
*        use mat colnames from saved matrices with xtabond2
*        recommend using LIML or CUE with cuepoint so that automatic graph grid is centred correctly.
*        fix bug that disallows using a string variable for the cluster option
*        consider replacing cholesky(invsym(psi)) with rspi_inv = matpowersym(psi, -0.5)
*        allow override of graph combine title (=stat) in graph2

program define weakiv, eclass byable(recall) sortpreserve
	version 11.2
	local lversion 02.4.08
	local avarversion 01.0.04
	local ranktestversion 01.3.03

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

		if	"`e(cmd)'"=="weakiv" &				/// If previous e(cmd) was weakiv, and Wald model is NOT provided,
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
	local cmdline "weakiv `0'"

* esample = touse, except for xtabond2 where esample = original e(sample) in estimation
* use touse unless need to refer explicitly to original sample (e.g. when expanding factor vars)
	tempvar esample
	qui gen byte `esample'=e(sample)

* If data already preserved, OK; if preserve fails for other reasons, exit with error
	capture preserve
	if _rc > 0 & _rc~=621 {
di as err "Internal weakiv error - preserve failed"
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

	local cnames		: colnames(e(b))							//  not colfullnames since ivtobit has eqn names we don't want
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
			 			wbeta(`wbeta')					///	row vector
						var_wbeta(`var_wbeta'))

	local level				"`r(level)'"
	local levellist			"`r(levellist)'"
	local ar_level			"`r(ar_level)'"
	local wald_level		"`r(wald_level)'"
	local clr_level			"`r(clr_level)'"
	local k_level			"`r(k_level)'"
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
	tempname rk ar_p ar_chi2 ar_df k_p k_chi2 k_df j_p j_chi2 j_df kj_p ///
		clr_p clr_stat clr_df ar_r k_r j_r kj_dnr kj_r clr_r			///
		wald_p wald_chi2 wald_df wald_r
	tempname nullvec del_z pi_z var_del var_pidel_z var_pi_z bhat del_v
	tempname S S11 S12 S22 zz zzinv x2z xx zx xy x1x1 x2x2 x1x2 zx1 zx2 zy x1y x2y yy
	tempname sbeta iv_sbeta0 pi2hat
	tempname bhat pi_z1 pi_z2 var_pidel_z1 var_pidel_z2 var_pi_z11 var_pi_z12 var_pi_z22
	tempname syy see sxx sxy sxe syv sve svv AA
	tempname citable
	tempname nullvector wnullvector
	tempvar vhat vhat1 vhat2 uhat uhat1 uhat2 ehat

* Misc
	local npd=0


******************************** CUE point estimator if requested **************************
	if `cuepoint' {

		tempname ecuebeta wcuebeta

		if ~`overid' {								//  if exactly-ID, CUE=LIML=IV
			mat `ecuebeta'	= `ebeta'
			mat `wcuebeta'	= `wbeta'
		}
		else {
			computecrossprods, touse(`touse') wtexp(`wtexp') exexog(`exexog_t') wendo(`endo_t') depvar(`depvar_t')
			mat `zz'	= r(zz)
			mat `xx'	= r(x1x1)
			mat `zx'	= r(zx1)
			mat `xy'	= r(x1y)
			mat `zy'	= r(zy)
			mat `yy'	= r(yy)
	
			if `iid' {
				mata: s_liml(							///
									`N',				///
									"`zz'",				///
									"`xx'",				///
									"`zx'",				///
									"`xy'",				///
									"`zy'",				///
									"`yy'"				///
								)
			}
			else {
		
				tempvar cuewvar ehat
				qui gen double `ehat' = . if `touse'
				local avarcmd	"avar (`ehat') (`exexog_t') if `touse' `wtexp', `vceopt' nocons"
		
				qui gen double `cuewvar' = `wf'*`wvar' if `touse'
		
				di as text "Obtaining CUE point estimates..."
				mata: s_cue_beta(							///
										`N',				///
										"`depvar_t'",		///
										"`endo_t'",			///
										"`exexog_t'",		///
										"`ehat'",			///
										"`touse'",			///
										"`ebeta'",			/// use all Wald endog for starting values
										"`cuewvar'",		///
										"`zz'",				///
										"`avarcmd'",		///
										`lm',				///
										"on"				/// show CUE trace log
								)
			}
	
			mat `ecuebeta'=r(beta)								//  CUE estimate for all endogenous
			mat `ecuebeta'=`ecuebeta''							//  row vector (Stata convention)
			mat colnames `ecuebeta' = `endo'
			foreach vn of local wendo {							//  CUE estimate for weakly-ID only
				mat `wcuebeta' = nullmat(`wcuebeta') , `ecuebeta'[1,"`vn'"]
			}
		
		}	// end CUE (overid) block

	}	// end cuepoint block

***************** PREPARE VECTOR OF NULLS INCLUDING PREP FOR WEAK/STRONG ************************

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
		
		if `iid' & `cuestrong' {
			local s1method	"liml"
		}
		else if `iid' {
			local s1method	"iv"
		}
		else if `cuestrong' {
			local s1method	"iv"
			local s2method	"cue"
		}
		else {
			local s1method	"iv"
			local s2method	"gmm2s"
		}

* Always need to use an iid method (LIML or IV), either for final strong beta or for initial value for non-iid strong beta
		get_strong_beta,							///
							`s1method'				/// either LIML or IV
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
							yy(`yy')

		mat `sbeta'		= r(sbeta)
* Next 2 will be missing if LIML
		mat `iv_sbeta0'	= r(iv_sbeta0)				//  IV beta for strongly-idenfified send at null=0 (used in grid search)
		mat `pi2hat'	= r(pi2hat)					//  RF coeffs matrix (used in grid search)

		if ~`iid' {										//
			get_strong_beta,							///
								`s2method'				/// gmm2s or cue
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

		mat colnames `sbeta' = `sendo'
		mat `nullvector' = `wnullvector' , `sbeta'							//  append coeffs for strong to nullvector
	}

************************************ TEST SPECIFIED NULL *****************************

* Wald test. Works for all cases.
	mata: s_wald(						///
					"`var_wbeta'",		///
					"`wbeta'",			/// row vector
					"`wnullvector'"		/// rowvector
					)
	local wald_chi2		=r(wald_chi2)
	local npd			=max(`npd',r(npd))		//  promote to 1 if npd matrix ever encountered

	if `ncsendog' {									/// subset AR test; requires IID and linearity
*** inexog and cons partialled out everywhere ***

* x1 is subset weakly identified (wendo), x2 complement (not in subset, not tested, coeffs obtained by LIML)
		computecrossprods, touse(`touse') wtexp(`wtexp') exexog(`exexog_t') wendo(`wendo_t') other(`csendo_t') depvar(`depvar_t')
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
* subset AR is simply the overid stat (LM=Basmann, Wald/MD=Sargan) from LIML estimation
* with y0 = y - x1*nullvector, x1=weak endog, x2=other endog
		mata: s_sliml(								///
								`N',				///
								"`zz'",				///
								"`x1x1'",			///
								"`x1x2'",			///
								"`x2x2'",			///
								"`zx1'",			///
								"`zx2'",			///
								"`x1y'",			///
								"`x2y'",			///
								"`zy'",				///
								"`yy'",				///
								"`wnullvector'",	/// rowvector
								`nexog',			/// L = #exexog + #inexog; needed for AR but not LIML beta
								0,					/// flag=1 => calculate beta, =0 => calc only lambda and ar stat
								`lm'				/// flag LM=0, MD=1; needed for AR but not LIML beta
							)
	}												//  end subset-AR code
	else if `iid' & ~`forcerobust' {			//  iid-based test formulae

		computematrices_iid ,						///
			cons(`cons')							/// cons=1 if constant in model (ivprobit/tobit)
			touse(`touse')							///
			wtexp(`wtexp')							///
			model(`model')							///
			depvar(`depvar_t')						///
			endo(`wendo_t' `sendo_t')				/// first weak, then strong
			exexog(`exexog_t')						///
			inexog(`inexog_t')						/// empty/partialled-out unless ivprobit/tobit
			nendog(`nendog')						///
			nexexog(`nexexog')						///
			ntinexog(`ntinexog')					/// #exogenous regressors included in tests
			npartial(`npartial')					/// #inexog partialled-out
			nobs(`N')								///
			dofminus(`dofminus')					///
			ssa(`ssa')								/// small-sample adjustment
			lm(`lm')								///
			llopt(`llopt')							/// ivtobit options
			ulopt(`ulopt')							///
			asis(`asis')							//  ivprobit options

		mat `var_pi_z'	=r(var_pi_z)	
		mat `pi_z'		=r(pi_z)
		mat `var_del'	=r(var_del)
		mat `del_z'		=r(del_z)
		mat `del_v'		=r(del_v)
		mat `syy'		=r(syy)
		mat `see'		=r(see)
		mat	`sxy'		=r(sxy)
		mat `sve'		=r(sve)
		mat `sxx'		=r(sxx)
		mat `svv'		=r(svv)

* Test specified null

		mata: compute_tests(								///
										1,					/// 1=iid code, 0=robust code
										`lm',				///
										`nendog',			///
										`nexexog',			///
										"`del_z'",			/// row vector
										"`var_del'",		///
										"`pi_z'",			///
										"`var_pi_z'",		///
										"`var_pidel_z'",	///
										"`del_v'",			/// row vector
										"`wnullvector'",	/// row vector
										"`nullvector'",		/// row vector; first weak, then strong (if any)
										"`syy'",			/// actually scalar
										"`see'",			/// actually scalar
										"`sxy'",			/// COLUMN VECTOR
										"`sve'",			/// COLUMN VECTOR
										"`sxx'",			/// KxK matrix
										"`svv'"				/// KxK matrix
										)

	}																//  end iid code
	else {															//  robust/non-iid case

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
		mat `pi_z'			= r(pi_z)
		mat `var_del'		= r(var_del)
		mat `var_pidel_z'	= r(var_pidel_z)

* Test specified null
		mata: compute_tests(								///
										0,					/// 1=iid code, 0=robust code
										`lm',				///
										`nendog',			///
										`nexexog',			///
										"`del_z'",			/// row vector
										"`var_del'",		///
										"`pi_z'",			///
										"`var_pi_z'",		///
										"`var_pidel_z'",	///
										"`del_v'",			/// row vector
										"`wnullvector'",	/// row vector
										"`nullvector'"		/// row vector; first weak, then strong (if any)
										)
	}		// end robust/non-iid code

************************** ASSEMBLE RESULTS FOR SPECIFIED NULL *****************************

* Collect test stats left behind by above
* If not overid or if subset, most will be missing
	local ar_chi2		=r(ar_chi2)
	local k_chi2		=r(k_chi2)
	local j_chi2		=r(j_chi2)
	local clr_stat		=r(clr_stat)
	local rk			=r(rk)
	local npd			=max(`npd',r(npd))		//  promote to 1 if npd matrix ever encountered

* calculate test statistics, p-values, and rejection indicators from above matrices
	compute_pvals,								///
					closedform(`closedform')	///
					clrsims(`clrsims')			///
					overid(`overid')			///
					iid(`iid')					///
					rk(`rk')					///
					nexexog(`nexexog')			///
					nendog(`nendog')			///
					nsendog(`nsendog')			///
					ncsendog(`ncsendog')		///
					ar_level(`ar_level')		///
					k_level(`k_level')			///
					j_level(`j_level')			///
					kj_level(`kj_level')		///
					clr_level(`clr_level')		///
					wald_level(`wald_level')	///
					ar_chi2(`ar_chi2')			///
					k_chi2( `k_chi2' )			///
					j_chi2(`j_chi2')			///
					clr_stat(`clr_stat')		///
					wald_chi2(`wald_chi2')		///
					kwt(`kwt')

	local wald_df	=r(wald_df)
	local wald_p	=r(wald_p)
	local wald_r	=r(wald_r)
	local ar_df		=r(ar_df)
	local ar_p		=r(ar_p)
	local ar_r		=r(ar_r)
	local clr_p		=r(clr_p)
	local clr_r		=r(clr_r)
	local kj_p		=r(kj_p)
	local kj_r		=r(kj_r)
	local k_df		=r(k_df)
	local k_p		=r(k_p)
	local k_r		=r(k_r)
	local j_df		=r(j_df)
	local j_p		=r(j_p)
	local j_r		=r(j_r)
	local rk_p		=r(rk_p)
	local rk_df		=r(rk_df)

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
			overid(`overid')			///
			kwt(`kwt')					///
			nobs(`N')					///
			gridlist(`gridlist')		///
			points(`points')			///
			wbeta(`wbeta')				///
			var_wbeta(`var_wbeta')		///
			var_pi_z(`var_pi_z')		///
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
	ereturn local	cmd 				"weakiv"
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
	ereturn local	null				"`wnull'"
	ereturn scalar	wald_level			=`wald_level'
	ereturn scalar	wald_p				=`wald_p'
	ereturn scalar	wald_df				=`wald_df'
	ereturn scalar	wald_chi2			=`wald_chi2'
	ereturn scalar	ar_level			=`ar_level'
	ereturn scalar	ar_df				=`ar_df'
	ereturn scalar	ar_p				=`ar_p'
	ereturn scalar	ar_chi2				=`ar_chi2'
	if `overid' {
		ereturn scalar	kjj_level		=`kjj_level'
		ereturn scalar	kjk_level		=`kjk_level'
		ereturn scalar	kj_level		=`kj_level'
		ereturn scalar	kj_p			=`kj_p'
		ereturn scalar	kwt				=`kwt'
		ereturn scalar	j_level			=`j_level'
		ereturn scalar	j_df			=`j_df'
		ereturn scalar	j_p				=`j_p'
		ereturn scalar	j_chi2			=`j_chi2'
		ereturn scalar	k_level			=`k_level'
		ereturn scalar	k_df			=`k_df'
		ereturn scalar	k_p				=`k_p'
		ereturn scalar	k_chi2			=`k_chi2'
		ereturn scalar	clr_level		=`clr_level'
		ereturn scalar	clr_p			=`clr_p'
		ereturn scalar	clr_stat		=`clr_stat'
	}
	if `testid' {
		ereturn scalar	idstat_df		=`idstat_df'
		ereturn scalar	idstat_p		=`idstat_p'
		ereturn scalar	idstat			=`idstat'
	}
	ereturn scalar	rk_df				=`rk_df'
	ereturn scalar	rk_p				=`rk_p'
	ereturn scalar	rk					=`rk'
	ereturn scalar	testid				=`testid'
	ereturn scalar	N					=`N'
	ereturn local   robust				"`robust'"
	if "`clustvar2'"~="" {										//  save additional macros for 2-way clustering
		ereturn scalar	N_clust2		=`N_clust2'
		ereturn scalar	N_clust1		=`N_clust1'				//  with 2-way, N_clust=min(N_clust1, N_clust2)
		ereturn local	clustvar2		"`clustvar2'"
		ereturn local	clustvar1		"`clustvar1'"
	}
	if "`cluster'"~="" {										//  save macros for 1- and 2-way clustering
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
		if `overid' {
			ereturn local	kj_cset		"`kj_cset'"
			ereturn local	j_cset		"`j_cset'"
			ereturn local	k_cset		"`k_cset'"
			ereturn local	clr_cset	"`clr_cset'"
		}
	}
	ereturn local	testlist			"`testlist'"
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
			if `overid' {
				ereturn local p`vnum'_kj_cset			"`p`vnum'_kj_cset'"
				ereturn local p`vnum'_j_cset			"`p`vnum'_j_cset'"
				ereturn local p`vnum'_k_cset			"`p`vnum'_k_cset'"
				ereturn local p`vnum'_clr_cset			"`p`vnum'_clr_cset'"
			}
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
	if e(sendo_ct) {											//  save strongly-identified beta at specified null
		ereturn matrix	sbeta			=`sbeta'
	}
	if `cuepoint' {
		ereturn matrix	cuebeta			=`ecuebeta'
	}
	ereturn matrix	ebeta				=`ebeta'
	ereturn matrix	var_wbeta			=`var_wbeta'
	ereturn matrix	wbeta				=`wbeta'
	ereturn scalar	overid				=`overid'
	ereturn scalar	iid					=`iid'
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
	if `lm'	{
		ereturn local method			"lm"
	}
	else {
		ereturn local method			"md"
	}
	
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
	local name_clr		: di "{txt}{ralign 5:{helpb weakiv##CLR:CLR}}"
	local name_ar		: di "{txt}{ralign 5:{helpb weakiv##AR:AR}}"
	local name_k		: di "{txt}{ralign 5:{helpb weakiv##K:K}}"
	local name_j		: di "{txt}{ralign 5:{helpb weakiv##J:J}}"
	local name_kj		: di "{txt}{ralign 5:{helpb weakiv##K-J:K-J}}"
	local name_wald		: di "{txt}{ralign 5:{helpb weakiv##Wald:Wald}}"
* test levels
	local level_clr		: di %2.0f e(clr_level) "%"
	local level_ar		: di %2.0f e(ar_level) "%"
	local level_k		: di %2.0f e(k_level) "%"
	local level_j		: di %2.0f e(j_level) "%"
	local level_kj		: di %2.0f e(kj_level) "% (" %2.0f e(kjk_level) "%," %2.0f e(kjj_level) "%)"
	local level_wald	: di %2.0f e(wald_level) "%"
* test text (LHS of table)
	local testtxt_clr	: di "{txt}{lalign 9:stat(.)} = {res}"					%8.2f `e(clr_stat)'		"{center 3:} {res}" %7.4f `e(clr_p)'
	local testtxt_ar	: di "{txt}{lalign 9:chi2({res:`e(ar_df)'})} = {res}"	%8.2f `e(ar_chi2)'		"{center 3:} {res}" %7.4f `e(ar_p)'
	local testtxt_k		: di "{txt}{lalign 9:chi2({res:`e(k_df)'})} = {res}"	%8.2f `e(k_chi2)'		"{center 3:} {res}" %7.4f `e(k_p)'
	local testtxt_j		: di "{txt}{lalign 9:chi2({res:`e(j_df)'})} = {res}"	%8.2f `e(j_chi2)'		"{center 3:} {res}" %7.4f `e(j_p)'
	local testtxt_kj	: di "{txt}{center 20:<n.a.>}"													"{center 3:} {res}" %7.4f `e(kj_p)'
	local testtxt_wald	: di "{txt}{lalign 9:chi2({res:`e(wald_df)'})} = {res}"	%8.2f `e(wald_chi2)'	"{center 3:} {res}" %7.4f `e(wald_p)'
* CI text (RHS of table)
	local ci_clr		: di " {c |}{center 15:`level_clr'}{res}{center 22:`e(clr_cset)'}"
	local ci_ar			: di " {c |}{center 15:`level_ar'}{res}{center 22:`e(ar_cset)'}"
	local ci_k			: di " {c |}{center 15:`level_k'}{res}{center 22:`e(k_cset)'}"
	local ci_wald		: di " {c |}{center 15:`level_wald'}{res}{center 22:`e(wald_cset)'}"
	if ~e(closedform) {
		local ci_kj			: di " {c |}{center 15:`level_kj'}{res}{center 22:`e(kj_cset)'}"
		local ci_j			: di " {c |}{center 15:`level_j'}{res}{center 22:`e(j_cset)'}"
	}
	else {
		local ci_kj			: di " {c |}{center 15:`level_kj'}{res}{center 22:(*)}"
		local ci_j			: di " {c |}{center 15:`level_j'}{res}{center 22:(*)}"
	}
	foreach testname in clr ar k j kj wald {
		local cset		"`e(`testname'_cset)'"
		local csetlen	: length local cset
		if `csetlen' <= 22 {
* Fits so center it in a line of 22 chars (78-56=22 = what's left from default of 78)
			local ci_`testname'		: di " {c |}{center 15:`level_`testname''}{res}{center 22:`e(`testname'_cset)'}"
		}
		else {
* Doesn't fit so right-align it on the next line
			local ci_`testname'		: di " {c |}{center 15:`level_`testname''}{break}{res}{ralign 78:`e(`testname'_cset)'}"
		}
	}
* Override above since (*) always fits
	if e(closedform) {
		local ci_kj		: di " {c |}{center 15:`level_kj'}{res}{center 22:{helpb weakiv##closedform:(*)}}"
		local ci_j		: di " {c |}{center 15:`level_j'}{res}{center 22:{helpb weakiv##closedform:(*)}}"
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
	if e(ci) {
		di as txt "{p}{helpb weakiv##interpretation:Weak instrument robust tests and confidence sets for `e(ivtitle)' `modeltext'}{p_end}"
	}
	else {
		di as txt "{p}{helpb weakiv##interpretation:Weak instrument robust tests for `e(ivtitle)'}{p_end}"
	}
	if e(wendo_ct)==1 {								// K=1
		di in yellow "H0: beta[`e(depvar)':`e(wendo)'] = `e(null)'"
	}
	else if e(wendo_ct)==2 {						// K=2
		local null1		: word 1 of `e(null)'
		local null2		: word 2 of `e(null)'
		local wendo1	: word 1 of `e(wendo)'
		local wendo2	: word 2 of `e(wendo)'
		di in yellow "H0: beta[`e(depvar)':`wendo1'] = `null1' & beta[`e(depvar)':`wendo2'] = `null2'"
	}
	else {
		di in yellow "H0: beta[`e(depvar)':`e(wendo)'] = [`e(null)']"
	}
	if e(sendo_ct) {
		di as text "{p 0 4}Assumed strongly identified: `e(sendo)'{p_end}"
	}
	if e(csendo_ct) {
		di as text "{p 0 4}Also endogenous: `e(csendo)'.  Test is {helpb weakiv##SSAR:subset-AR}.{p_end}"
	}
	if e(tinexog_ct) {
		di as text "{p 0 4}Regressors assumed exogenous: `e(tinexog)'{p_end}"
	}
* header
	di as txt "{hline 6}{c TT}{hline 33}" _c
	if e(ci) di as txt "{c TT}{hline 37}" _c
	di
	di as txt "{ralign 5:Test} {c |} {center 21:Statistic}{center 10:   p-value}" _c
	if e(ci) di as txt " {c |}{center 15:Conf. level}{center 22:{helpb weakiv##cset:Conf. Set}}" _c
	di
	di as txt "{hline 6}{c +}{hline 33}" _c
	if e(ci) di as txt "{c +}{hline 37}" _c
	di
* weak-ID stats
	foreach testname in `e(testlist)' {
		di "`name_`testname'' {c |} `testtxt_`testname''" _c
		if e(ci) di "`ci_`testname''" _c
		di
	}
* separating line
	di as txt "{hline 6}{c +}{hline 33}" _c
	if e(ci) di as txt "{c +}{hline 37}" _c
	di
* wald
	di "`name_wald' {c |} `testtxt_wald'" _c
	if e(ci) di "`ci_wald'" _c
	di
* last separating line
	di as txt "{hline 6}{c BT}{hline 33}" _c
	if e(ci) di as txt "{c BT}{hline 37}" _c
	di

* footer information
	tempname ecuebeta
	mat `ecuebeta'=e(cuebeta)
	if `ecuebeta'[1,1] ~= . {								//  Display CUE beta
		if ~e(overid) {
			local cue	"IV (exactly-identified)"
		}
		else if e(iid) {
			local cue	"LIML"
		}
		else if e(method)=="lm" {
			local cue	"CUE"
		}
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
		di as txt "{p}Confidence sets estimated for `pointstext' points in `e(grid_descript)'.{p_end}"
	}
	else if e(overid) & ~e(csendo_ct) & e(ci) {
		di as txt "{p}{helpb weakiv##closedform:(*)}J/K-J conf. sets {helpb weakiv##closedform:unavailable with closed-form estimation}.{p_end}"				
	}
	if e(clrsims)>0 {
		di as txt "{p}CLR distribution and p-values obtained by simulation (`e(clrsims)' draws).{p_end}"
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
		di as txt "{p}Method = {helpb weakiv##method:minimum distance/Wald}."
	}
	else if "`e(method)'"=="md" {
		di as txt "{p}Method = {helpb weakiv##method:minimum distance (MD)}."
	}
	else {
		di as txt "{p}Method = {helpb weakiv##method:lagrange multiplier (LM)}."
	}
	if e(k_chi2)<. {
		di as text " Weight on K in K-J test = " %5.3f e(kwt) "."
	}
	di as txt "{p_end}"
	di as txt "{p}`e(note1)' `e(note2)' `e(note3)'"
	di as txt "{p_end}"
	di as txt "{p}Wald statistic in last row is based on `e(waldcmd)' estimation and is not robust to weak instruments.{p_end}"
	if e(npd) {
		di in red "{p}Some matrices are not positive definite, so reported tests should be treated with caution.{p_end}"
	}
	
	if e(testid) {					//  tests of underidentification to display
		di
		di "{helpb weakiv##underid:Tests of underidentification:}"
		local rank=`e(endo_ct)'-`e(tinexog_ct)'
		di as res "H0: rank(E(zi'xi))=" `rank'-1 "     Ha: rank(E(zi'xi))=" `rank' " (full rank)"
		di as text "Rank test for weak-identification-robust estimation:"
		di as text "  chi2(" as res e(rk_df) as text ") = " _col(12) as res %6.2f e(rk) _col(25) as text "p-value = " _col(35) as res %5.4f e(rk_p)
		di as text "Rank test for Wald model:"
		di as text "  chi2(" as res e(idstat_df) as text ") = " _col(12) as res %6.2f e(idstat) _col(25) as text "p-value = " _col(35) as res %5.4f e(idstat_p)
	}
	if e(pwendo_ct) {				//  projection-based CIs to display
		di
		di "{helpb weakiv##project:Projection-based inference:}"
		di
		di as txt "{ralign 5:Test}{center 20:Conf. level}{center 50:{helpb weakiv##cset:Confidence Set}}"
		di as txt "{hline 71}"

		local pwendo_nlist	"`e(pwendo_nlist)'"
		local wendo			"`e(wendo)'"
		local ptestlist		"`e(ptestlist)'"

		foreach vnum of local pwendo_nlist {
			local vname		: word `vnum' of `wendo'
			di as text "Variable: `vname'"
			foreach testname in `ptestlist' {
				if "`e(p`vnum'_`testname'_cset)'"~="" {
					di "{ralign 5:`name_`testname''}{center 20:`level_`testname''}{res}{center 50:`e(p`vnum'_`testname'_cset)'}"
				}
			}
			di as txt "{hline 71}"
		}
	}

end

program define estimate_model
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
			LEVELlist(numlist min=0 max=3)								///
			arlevel(numlist min=1 max=1)								///
			jlevel(numlist min=1 max=1)									///
			kjlevel(numlist min=1 max=2)								///
			waldlevel(numlist min=1 max=1)								/// illegal option - capture it
			klevel(numlist min=1 max=1)									/// illegal option - capture it
			clrlevel(numlist min=1 max=1)								/// illegal option - capture it
			lm md														///
			cuepoint													///
			strong(varlist fv ts) cuestrong								///
			project(string)												/// string since must accept _all
			project2(varlist fv ts min=2 max=2)							///
			clrsims(integer -1)											///
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
	local legalcmd	"ivregress ivreg2 ivreg2h xtivreg xtivreg2 ivprobit ivtobit xtabond2"
	local legal		: list cmd in legalcmd
	if `legal' {
		di as text "Estimating model for Wald tests using `cmd'..."
	}
	else {
di as err "error - unsupported estimator `estimator'"
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
	else if "`cmd'" ~= "xtabond2" {										//  all other estimation commands except xtabond2
		qui `anything' `if' `in' `wtexp' `optexp'						//  more informative error messages with qui than cap
	}
	else {																//  xtabond2 requires special treatment

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

end

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
			LEVELlist(numlist min=0 max=3)										///
			arlevel(numlist min=1 max=1)										///
			jlevel(numlist min=1 max=1)											///
			kjlevel(numlist min=1 max=2)										///
			waldlevel(numlist min=1 max=1)										/// illegal option - capture it
			klevel(numlist min=1 max=1)											/// illegal option - capture it
			clrlevel(numlist min=1 max=1)										/// illegal option - capture it
			kwt(real 0)															///
			lm md																///
			cuepoint															///
			strong(string) cuestrong											///
			subset(string)														///
			testexog(string)													///
			testid																///
			project(string)														///
			project2(string)													///
			clrsims(integer -1)													///
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
			wbeta(name) var_wbeta(name)											///
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

* Check all provided confidence levels.
* Stata's definition of a legal level is >=10 and <=99.99
	foreach lev in `levellist' `arlevel' `jlevel' `kjlevel' {
		if `lev'<10 | `lev'>=99.99	{									//  Stata's definition of a legal level
di as err "illegal confidence level `lev': must be >=10 and <=99.99"
			exit 198
		}
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
* K, CLR and Wald test levels are the default test level - all are tests of parameter only
* Capture if attempted to set separately
	local k_level		"`level'"
	local clr_level		"`level'"
	local wald_level	"`level'"
	if "`klevel'`clrlevel'`waldlevel'" ~= "" {
di as err "illegal option: test level for K, CLR and Wald cannot be set separately"
di as err "use -level(.)- option to set test level for these parameter-only tests"
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

* Stata default clrsims = -1 => user hasn't provided value, use Mikusheva-Poi method (leave at -1) or 10k reps
* clrsims = 0 => user doesn't want sim method used, use Mikusheva-Poi method (set to -1) or nothing (leave at 0)
* clrsims > 0 => user wants sim method used with specified #sims, don't use Mikusheva-Poi method even if possible
* if CLR stat not needed, set =-1
	if ~`overid' | `ncsendog' {									//  exactly-IDed or subset AR so CLR not needed
		local clrsims		= 0									//  neither sims nor M-P method needed
	}
	else if `clrsims'==0 {										//  user doesn't want sim method, so use M-P or nothing
		if `nwendog'==1 & `nsendog'==0 {						//  M-P method is default for K=1 case and no strong endog
			local clrsims	= -1
		}
	}
	else if `clrsims'==-1 {										//  user didn't provide value, so go to default behavior, sims or M-P
		if `nwendog'>1 | `nsendog'>0 {							//  must use simulation method
			local clrsims	= 10000								//  default is 10k simulations
		}														//  otherwise leave at -1 => M-P
	}

* So now:
* clrsims=-1 => don't use sim method, use Mikusheva-Poi method for CLR p-value
* clrsims=0  => don't use simulation method, no p-value provided
* clrsims>0  => use simulation method

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
	if `ci' & (`clrsims'>0) {											//  use grid for CI if simulation method for CLR
		local usegrid	=1												//  since closed-form code won't work
	}

* closedform code for CIs uses Mikusheva-Poi method rather than grid search
* works for iid linear models with #wendog=1, no strong and not subset-AR
* overridden if usegrid is already indicated
	local closedform	=(~`usegrid' & "`model'"=="linear" & `iid' & `nwendog'==1 & ~`nsendog' & ~`ncsendog')

* Default test lists and CI methods
* CI method is grid-based except if K=1, iid and no strong
* when closed-form CIs are available
	if ~`ncsendog' & `iid' & ~`nsendog' & ~`usegrid' & ~`forcerobust' {		//  closed form - iid, nsendog=0, non-subset only
		local testlist			"clr k j kj ar"
		local citestlist		"clr k ar"									//  j and kj CIs not available for closed-form method
		local ptestlist			""											//  projection-based inference unavailable if closed-form
	}
	else {
		local testlist			"clr k j kj ar"
		local citestlist		"clr k j kj ar"
		local ptestlist			"clr k j kj ar wald"

		if `usegrid' {
			local gridcols				///
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
							rk			///
							rk_p
		}
	}
* And above overridden if exactly-ID or subset AR, when only AR is available
	if ~`overid' | `ncsendog' {
		local testlist		"ar"
	 	local citestlist	"ar"
	 	local ptestlist		"ar wald"
		if `usegrid' {
			local gridcols				///
							wald_chi2	///
							ar_chi2		///
							wald_p		///
							ar_p
		}
		if ~`ncsendog' {				//  exactly-ID but not subset AR, so rank test available
			local gridcols	`gridcols'	///
							rk			///
							rk_p
		}
	}

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

	if `usegrid' & `gridmult'==0 {										//  default gridmult=2
			local gridmult=2
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
	return local testlist			"`testlist'"
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
	local cmd		"`e(cmd)'"
	local legal		: list cmd in legalcmd
	if ~`legal' {
di as err "weakiv not supported for command `e(cmd)'"
		error 301
	}

* Clear any extraneous sreturn macros before parsing
	sreturn clear
	if "`e(cmd)'" == "xtabond2" {
* Need if `esample' since xtabond2 sample is created sample with poss more obs vs original
* Need to pass `wvar' so that values saved by xtabond2 in e(wt) can be assigned to it
		parse_xtabond2, wvar(`wvar') esample(`esample') touse(`touse') strong(`strong') subset(`subset') testexog(`testexog') clustvar1_t(`clustvar1_t') eq(`eqxtabond2')
	}
	if "`e(cmd)'"=="ivreg2" | "`e(cmd)'"=="ivreg2h" {
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
	local iid = ("`s(robust)'`s(cluster)'`s(kernel)'"=="")
	local vceopt "`s(robust)' `s(cluster)' bw(`s(bw)') kernel(`s(kernel)') `s(psd)'"

* Assemble notes for table output
	if `iid' {
		local note1 "Tests assume i.i.d. errors."
	}
	else {
		if "`s(robust)'`s(cluster)'"~="" {
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
			local note1 "`note1'."
		}
		if "`s(kernel)'"~="" {
			local note2 "Tests robust to autocorrelation: kernel=`s(kernel)', bw=`s(bw)'."
			}
	}
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
* In Stata 13 & earlier, saved in e(vce); in Stata 14+, saved in e(method).
	if "`e(vce)'" ~= "twostep" & "`e(method)'" ~= "twostep" {
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
			local gridinterval = .999999999*(`gridmax'-`gridmin')/(`points'-1)
			local grid "`gridmin'(`gridinterval')`gridmax'"						//  grid is in numlist form
			if `usecue' & `numlimits'==2										/// add CUE to grid
				& `wbeta'>`gridmin' & `wbeta'<`gridmax' {						//  ...but only if an interior point
				local grid		"`grid' `wbeta'"								//  wbeta is CUE beta
				local points	=`points'+1										//  and add 1 to points
			}
			numlist "`grid'", sort												//  sort required in case CUE beta appended at end
			local gridlist	"`r(numlist)'"										//  gridlist is actual list of #s to search over
		}
		else {																	//  special case of 1 gridpoint in this dimension
			local gridlist	"`wbeta'"											//  in which case it's just the Wald beta
			local gridmin	= `wbeta'
			local gridmax	= `wbeta'
		}
	}
	else {													//  grid is user-provided numlist of grid entries
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

end		// endo computecrossprods

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
	else {																			//  need only svv for Wald/MD version
		qui mat accum `AA' = `Vhat' if `touse' `wtexp', noconstant
		mat `svv' = `AA'  * 1/(`N'-`dofminus') * `ssa'								//  so same dfn as with LM version
	}
	mata: `svv' = st_matrix("`svv'")
	qui mat accum `zz' = `exexog' `inexog' `ones' if `touse' `wtexp', noconstant
	mata: `zz'=st_matrix("`zz'")
	mata: `zzinv'=invsym(`zz')
	mata: `zzinv' = `zzinv'[| 1,1 \ `nexexog',`nexexog' |]
	mata: `var_pi_z' = `svv' # `zzinv' * 1/`ssa'									//  need large-sample version
	mata: st_matrix("r(`var_pi_z')",`var_pi_z')
	mat `var_pi_z'=r(`var_pi_z')

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
		
	tempname pi_z bhat uhat zz zzinv del_z var_pi_z var_del var_pidel_z
	tempname S S11 S12 S22

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
	mat `pi_z'=r(`pi_z')
	mat `var_del'=r(`var_del')
	mat `var_pi_z'=r(`var_pi_z')
	mat `var_pidel_z'=r(`var_pidel_z')

	mata: mata drop `zz' `zzinv' `S' `S11' `S12' `S22' `bhat'			// clean up Mata memory
	mata: mata drop `var_del' `var_pi_z'
	mata: mata drop `pi_z' `var_pidel_z'

	return mat del_z		= `del_z'
	return mat var_pi_z		= `var_pi_z'
	return mat pi_z			= `pi_z'
	return mat var_del		= `var_del'
	return mat var_pidel_z	= `var_pidel_z'

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
				overid(integer 0)		///
				alpha(real 0)			///
				kwt(real 0)				///
				nobs(real 0)			///
				gridlist(string)		///
				points(integer 0)		///
				wbeta(name local)		/// row vector
				var_wbeta(name local)	///
				var_pi_z(name local)	///
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

* npd is flag set to 1 if npd matrices encountered
		local npd = 0

* cnames = column names for grid
* leading columns in grid: nulls and strong betas
		forvalues i=1/`nwendog' {
			local cnames "`cnames' null`i'"				//  used for columns of CI table
		}
		if `nsendog' {
			local cnames "`cnames' `sendo'"				//  additional columns for strongly-IDed betas
		}
* and append names of columns in gridcols
		local cnames	"`cnames' `gridcols'"
		local cnames	: list clean cnames
		local cnum		: list sizeof cnames			//  number of columns for grid
		mata: `citable' = J(0,`cnum',0)					//  initialize grid; use Mata (no limits on grid size)

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
						overid(`overid')			///
						kwt(`kwt')					///
						nobs(`nobs')				///
						wbeta(`wbeta')				/// row vector
						var_wbeta(`var_wbeta')		///
						var_pi_z(`var_pi_z')		///
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

* Finish up
		return scalar npd		= `npd'					//  flag to indicate NPD matrices encountered
		return local cnames			"`cnames'"			//  col names for CI table

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
				overid(integer 0)		///
				kwt(real 0)				///
				nobs(real 0)			///
				wbeta(name local)		/// row vector
				var_wbeta(name local)	///
				var_pi_z(name local)	///
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

	tempname rk ar_p ar_chi2 ar_df k_p k_chi2 k_df j_p j_chi2 j_df kj_p kj_chi2 ///
		clr_p clr_stat clr_df ar_r k_r j_r kj_dnr kj_r kj_p clr_r				///
		wald_p wald_chi2 wald_df wald_r
	tempname wgridnullvector gridnullvector sbeta
	tempname cirow

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
							overid(`overid')			///
							kwt(`kwt')					///
							nobs(`nobs')				///
							wbeta(`wbeta')				/// row vector
							var_wbeta(`var_wbeta')		///
							var_pi_z(`var_pi_z')		///
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

			local counter = `counter'+1					//  about to do tests; increment by 1
			_dots `counter' 0
			mata: `gridnullvector' = strtoreal(tokens("`newnullvec'"))			//  easiest way to put string into a matrix is via Mata
			mata: st_matrix("`wgridnullvector'", `gridnullvector')
			mat `gridnullvector'  = `wgridnullvector' 							//  So gridnull vector is in Mata and Stata
			if `nsendog'>0 {													//  append coeffs for strong (if any) to nullvector
		
				if `iid' & `cuestrong' {
					get_strong_beta,							///
										liml					/// LIML, from scratch
										nobs(`nobs')			///
										b0(`wgridnullvector')	///
										zz(`zz')				///
										x1x1(`x1x1')			///
										x1x2(`x1x2')			///
										x2x2(`x2x2')			///
										zx1(`zx1')				///
										zx2(`zx2')				///
										x1y(`x1y')				///
										x2y(`x2y')				///
										zy(`zy')				///
										yy(`yy')
				}
				else {
					get_strong_beta,							/// IV estimator used for strong coeffs; also init beta for gmm2s or cue
										iv						///
										b0(`wgridnullvector')	///
										iv_sbeta0(`iv_sbeta0')	///
										pi2hat(`pi2hat')
				}
				mat `sbeta' = r(sbeta)							//  either LIML or IV for strong coeffs

				if ~`iid' {
					if `cuestrong' {
						local s2method	"cue"
					}
					else {
						local s2method	"gmm2s"
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
										wf(`wf')
					mat `sbeta' = r(sbeta)						//  new sbeta based on efficient GMM (2-step or CUE)
				}
				mat `gridnullvector' = `wgridnullvector' , `sbeta'		// new gridnullvector is weak null followed by strong beta
				mata: `gridnullvector' = st_matrix("`gridnullvector'")	// and replace Mata version as well
			}

* calculate test stats

* Wald test. Works for all cases.
			mata: s_wald(							///
							"`var_wbeta'",			///
							"`wbeta'",				/// row vector
							"`wgridnullvector'"		/// rowvector
							)
			local wald_chi2		=r(wald_chi2)
			local npd			=max(`npd',r(npd))	//  promote to 1 if npd matrix ever encountered

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
										1,						/// 1=iid code, 0=robust code
										`lm',					///
										`nendog',				///
										`nexexog',				///
										"`del_z'",				/// row vector
										"`var_del'",			///
										"`pi_z'",				///
										"`var_pi_z'",			///
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
										0,						/// 1=iid code, 0=robust code
										`lm',					///
										`nendog',				///
										`nexexog',				///
										"`del_z'",				/// row vector
										"`var_del'",			///
										"`pi_z'",				///
										"`var_pi_z'",			///
										"`var_pidel_z'",		///
										"`del_v'",				/// row vector
										"`wgridnullvector'",	/// row vector
										"`gridnullvector'"		/// row vector; first weak, then strong (if any)
										)
			}
			local npd			=max(`npd',r(npd))	//  promote to 1 if npd matrix ever encountered
			local ar_chi2		=r(ar_chi2)
			local k_chi2		=r(k_chi2)
			local j_chi2		=r(j_chi2)
			local clr_stat		=r(clr_stat)
			local rk			=r(rk)
* calculate test statistics, p-values, and rejection indicators from above matrices
			compute_pvals,					///
				closedform(`closedform')	///
				clrsims(`clrsims')			///
				overid(`overid')			///
				iid(`iid')					///
				nexexog(`nexexog')			///
				nendog(`nendog')			///
				nsendog(`nsendog')			///
				ncsendog(`ncsendog')		///
				ar_chi2(`ar_chi2')			///
				k_chi2(`k_chi2')			///
				j_chi2(`j_chi2')			///
				clr_stat(`clr_stat')		///
				wald_chi2(`wald_chi2')		///
				rk(`rk')					///
				kwt(`kwt')

			local wald_df		=r(wald_df)
			local wald_p		=r(wald_p)
			local ar_df			=r(ar_df)
			local ar_p			=r(ar_p)
			local clr_p			=r(clr_p)
			local kj_p			=r(kj_p)
			local k_df			=r(k_df)
			local k_p			=r(k_p)
			local j_df			=r(j_df)
			local j_p			=r(j_p)
			local rk_p			=r(rk_p)
			local rk_df			=r(rk_df)

			mata: `cirow' = J(1,0,.)
			foreach gc in `gridcols' {
				mata: `cirow' = `cirow', ``gc''				//  construct grid row with test stats
			}
			mata: `cirow' = `gridnullvector', `cirow'		//  save grid null and strong beta along with test stats
			mata: `citable' = `citable' \ `cirow'
			mata: mata drop `cirow' `gridnullvector'
		}
	}

	return scalar npd		=`npd'
	return local counter	=`counter'

end

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

	foreach test of local testlist {
		local testcol		: list posof "`test'_p" in cnames
	 	local gridcols		"`gridcols' `testcol'"
	 	local testlevels	"`testlevels' ``test'_level'"
	}

	tempname p											//  name to use for pointer
	mata: `p' = &`citable'								//  pointer to Mata matrix (CI table)

	mata: `pcitable' = project_test(`vnum', `p', `points', "`gridpoints'", "`gridcols'", "`testlevels'")

	foreach tname of local testlist {					//  add _r to end of testname to get colname
		local ptcnames			"`ptcnames' `tname'_r"
	}
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
							string scalar colsvec,				///
							string scalar levelsvec				///
							)
{
	
	gridcols		=strtoreal(tokens(colsvec))
	levels			=strtoreal(tokens(levelsvec))

	rtable			= (100*(*p)[.,gridcols]) :< (100 :- levels)
	rtable			= (*p)[.,1], rtable

	smat1			= rowsum(rtable[.,2..cols(rtable)])
	smat2			= smat1[(2::rows(smat1)),1]
	smat1			= smat1[(1::rows(smat1)-1),1]
	smat			= (smat1-smat2) :~= 0
	smat			= (1 \ smat) :| (smat \ 1)
	rtable			= select(rtable,smat)
	
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
	smat2			= smat1[(2::rows(smat1)),1]
	smat1			= smat1[(1::rows(smat1)-1),1]
	smat			= (smat1-smat2) :~= 0
	smat			= (1 \ smat) :| (smat \ 1)
	return(select((*p),smat))

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

	local hasrejections		=("`hasrejections'"~="")				//  Convert to boolean
	tempname rtable													//  table of collapsed rejections
																	//  name use for both Mata and Stata objects
	
	tempname p														//  name to use for Mata pointer
	mata: `p' = &`citable'											//  pointer to Mata matrix (CI table)

	if `hasrejections' {											//  Already in rejection 1/0 format
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
	else {															//  original CI table with p-values, so need to calc rejections
		local rtcnames			"null"
		foreach test of local testlist {
			local rtcnames		"`rtcnames' `test'_r"
			local testcol		: list posof "`test'_p" in cnames	//  table has p-values, hence "_p"
		 	local gridcols		"`gridcols' `testcol'"
		 	local testlevels	"`testlevels' ``test'_level'"
		}
		mata: `rtable' = collapse_citable(`p', "`gridcols'", "`testlevels'")	//  create table of rejections and collapse
																				//  (delete unnecessary rows)
		mata: st_matrix("`rtable'",`rtable')									//  copy from Mata into Stata
		mat colnames `rtable'	=`rtcnames'										//  and name columns
		mata: mata drop `rtable'												//  don't need Mata version of rejections table
	}
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

version 11.2
mata:
void compute_tests(												///
							scalar iid,							/// boolean
							scalar lm,							/// boolean, =1 if LM, =0 if Wald
							scalar nendog,						///
							scalar nexexog,						///
							string scalar del_z_name,			/// row vector
							string scalar var_del_name,			///
							string scalar pi_z_name,			///
							string scalar var_pi_z_name,		///
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

		npd				=0										//  initialize

		del_z			=st_matrix(del_z_name)					//  row vector
		var_del			=st_matrix(var_del_name)
		pi_z			=st_matrix(pi_z_name)
		var_pi_z		=st_matrix(var_pi_z_name)
		var_pidel_z		=st_matrix(var_pidel_z_name)
		del_v			=st_matrix(del_v_name)					//  row vector
		nullvector		=st_matrix(nullvector_name)				//  row vector
		wnullvector		=st_matrix(wnullvector_name)			//  row vector

// Use to get LM stats in iid case
		if (iid & lm) {
			syy				=st_matrix(syy_name)					//  scalar
			see				=st_matrix(see_name)					//  scalar
			sxy				=st_matrix(sxy_name)					//  COLUMN VECTOR
			sve				=st_matrix(sve_name)					//  COLUMN VECTOR
			sxx				=st_matrix(sxx_name)					//  KxK matrix 
			svv				=st_matrix(svv_name)					//  KxK matrix
		}
// Change to column vectors
		del_z			=del_z'
		del_v			=del_v'
		nullvector		=nullvector'
		wnullvector		=wnullvector'

		r = del_z - pi_z*nullvector

// Assemble psi
		if (iid) {
			kron		= (del_v - nullvector)#I(nexexog)
			psi			= var_del + kron' * var_pi_z * kron
			_makesymmetric(psi)
			psi_inv		= invsym(psi)
			bracket		= var_pi_z*kron
			shat		= var_pi_z - bracket*psi_inv*bracket'
		}
		else {
			kron		= (nullvector#I(nexexog))
			psi			= var_del - kron'*var_pidel_z - (kron'*var_pidel_z)' + kron' * var_pi_z * kron
			_makesymmetric(psi)
			psi_inv		= invsym(psi)
			bracket		= var_pidel_z - var_pi_z*kron
			shat		= var_pi_z - bracket*psi_inv*bracket'
		}
		_makesymmetric(shat)

		aux1 = cholsolve(psi,r)
		if (aux1[1,1]==.) {
			npd = 1
			aux1 = qrsolve(psi,r)
		}

		if (iid) {								//  iid
			aux0 = psi_inv * r * (del_v - nullvector)'
			vec_pi_beta = -vec(pi_z) + var_pi_z*vec(aux0)
		}
		else {									//  robust
			aux0 = var_pidel_z - var_pi_z*kron
			vec_pi_beta = -vec(pi_z) + aux0*psi_inv*r
		}

		pi_beta=J(nexexog,0,.)					//  un-vec pi_beta
		for (i=1; i<=nendog; i++) {
			r1=(i-1)*nexexog+1
			r2=(i)  *nexexog
			pi_beta = pi_beta , vec_pi_beta[r1..r2,1]
		}

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

		ar_chi2 = r' * aux1
		k_chi2 = r' * aux5 * aux6 * aux1
		if (k_chi2[1,1]<0) {								//  can happen if matrices are npd
			k_chi2[1,1]=.
		}
		j_chi2 = ar_chi2 - k_chi2

		rpsi_inv	= cholesky(psi_inv)						//  inv sqrt of psi

//  Rank statistic of Kleibergen-Paap
		rk			= rk_kp(	pi_beta,					/// =D in alt. notation, dim nexexog x nendog (LxK)
								I(nendog),					///
								rpsi_inv,					/// = (V_ff)^(-1/2) = inv sqrt of V_ff in alt. notation
								shat,						/// = V_thetatheta_f = var(vec(D)) in alt. notation
								nendog-1					/// test that matrix is not full rank
								)
		clr_stat = .5*(ar_chi2-rk+sqrt((ar_chi2+rk)^2 - 4*j_chi2*rk))
		if (rk[1,1]<=0) {
			clr_stat=.
			rk=.
		}

// LM versions of AR, K and J are just rescalings of MD/Wald versions
// CLR does not change.
		if (iid & lm) {
			s2lm		= syy - 2*nullvector'*sxy + nullvector'*sxx*nullvector
			s2			= see - 2*nullvector'*sve + nullvector'*svv*nullvector
			ar_chi2		= ar_chi2 * s2/s2lm
			k_chi2		= k_chi2  * s2/s2lm
			j_chi2		= ar_chi2 - k_chi2
		}

// return test stats in r()
		st_numscalar("r(ar_chi2)", ar_chi2[1,1])
		st_numscalar("r(k_chi2)", k_chi2[1,1])
		st_numscalar("r(j_chi2)", j_chi2[1,1])
		st_numscalar("r(rk)", rk[1,1])
		st_numscalar("r(clr_stat)", clr_stat[1,1])
		st_numscalar("r(npd)", npd)
}
end		//  end compute_tests


program get_strong_beta, rclass
	syntax [,							///
				iv						///
				gmm2s					///
				liml					///
				cue						///
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
			]

	tempname S npd
	tempvar y0 ehat

*************** ONE-STEP ESTIMATORS: LIML, IV **********************

	if "`liml'"~="" {
		tempname sbeta
		mata: s_sliml(								///
								`nobs',				///
								"`zz'",				///
								"`x1x1'",			///
								"`x1x2'",			///
								"`x2x2'",			///
								"`zx1'",			///
								"`zx2'",			///
								"`x1y'",			///
								"`x2y'",			///
								"`zy'",				///
								"`yy'",				///
								"`b0'",				/// rowvector
								0,					/// L = #exexog + #inexog ... but not needed for LIML beta
								1,					/// flag=1 => calculate beta as well as lambda
								0					/// flag LM=0, MD=1 ... but not needed for LIML beta
							)
		mat `sbeta'			= r(beta)								//  strong IV beta at specified null
		mat `sbeta'			= `sbeta''								//  row vector (Stata convention)
		return mat sbeta	= `sbeta'
		scalar `npd'		= r(npd)
		return scalar npd	= `npd'
	}

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
		mat `sbeta'				= `sbeta''							//  row vector (Stata convention)
		return mat sbeta		= `sbeta'							//  strong IV beta at specified null
		scalar `npd'			= r(npd)
		return scalar npd	= `npd'
	}	//  end calc of strong IV beta

*************** TWO-STEP ESTIMATORS: 2-STEP GMM, CUE **********************

* Both need y0 = y - b0*x1 = y at hypoth null
* and ehat = y0 - sbeta*x2 = resids from inefficient IV sbeta

	if "`gmm2s'`cue'"~="" {

		qui gen double `y0' = `depvar' if `touse'							//  calc y0 = y at hypoth null; also used by CUE
		local i=1
		foreach var of varlist `wendo' {
			qui replace `y0' = `y0' - `b0'[1,`i']*`var'
			local ++i
		}
		qui gen double `ehat' = `y0' if `touse'								//  calc 1st-step residuals at hypoth null
		local i=1															//  using inefficient IV estimator in sbeta
		foreach var of varlist `sendo' {
			qui replace `ehat' = `ehat' - `sbeta'[1,`i']*`var'
			local ++i
		}

	}
		
	if "`gmm2s'"~="" {														//  2-step GMM estimation
																			//  note 1st-step sbeta is provided

		cap avar (`ehat') (`exexog') if `touse' `wtexp', `vceopt' nocons	//  get weighting matrix for efficient GMM
		if _rc>0 {
di as err "error - internal call to avar failed"
			exit _rc
		}
		mat `S' = r(S)

		mata: s_gmm2s_beta(							///
								`nobs',				///
								"`zx1'",			///
								"`zx2'",			///
								"`zy'",				///
								"`b0'",				/// rowvector
								"`S'"				///
						)
		mat `sbeta'			= r(beta)
		mat `sbeta'			= `sbeta''										//  row vector (Stata convention)
		return mat sbeta	= `sbeta'										//  strong 2-step GMM beta at specified null
		scalar `npd'		= r(npd)
		return scalar npd	= `npd'

	}	// end calc of strong 2-step GMM beta

	
	if "`cue'"~="" {														//  CUE estimation
																			//  note 1st-step sbeta is provided

		local avarcmd	"avar (`ehat') (`exexog') if `touse' `wtexp', `vceopt' nocons"

		tempvar cuewvar
		qui gen double `cuewvar' = `wf'*`wvar' if `touse'

		mata: s_cue_beta(							///
								`nobs',				///
								"`y0'",				///
								"`sendo'",			///
								"`exexog'",			///
								"`ehat'",			///
								"`touse'",			///
								"`sbeta'",			/// 1st-step sbeta is provided to get_strong_beta
								"`cuewvar'",		///
								"`zz'",				///
								"`avarcmd'",		///
								`lm',				///
								"off"				///	suppress trace log						
						)
		mat `sbeta'			= r(beta)
		mat `sbeta'			= `sbeta''					//  row vector (Stata convention)
		return mat sbeta	= `sbeta'					//  strong CUE beta at specified null
		scalar `npd'		= r(npd)
		return scalar npd	= `npd'

	}	// end calc of strong CUE beta

end			//  end get_strong_beta


version 11.2
mata:
void s_gmm2s_beta(										///
						scalar N,						///
						string scalar ZX1_name,			///
						string scalar ZX2_name,			///
						string scalar Zy_name,			///  "raw" Zy, i.e., using y=depvar
						string scalar wnullvector_name,	///
						string scalar S_name			///
				)
{

	npd			= 0

	b0			= st_matrix(wnullvector_name)			//  row vector of hypoth null
// Change to column vectors
	b0			= b0'

	QZX1		= st_matrix(ZX1_name)/N
	QZX2		= st_matrix(ZX2_name)/N
	QZy			= st_matrix(Zy_name)/N
	S			= st_matrix(S_name)

	QZy			= QZy - QZX1*b0							//  Now QZy0 at hypoth null where y0 = y - b0*x1

	aux1		= cholsolve(S, QZX2)
	if (aux1[1,1]==.) {
		aux1	= qrsolve(S, QZX2)
		npd = 1
	}
	aux2		= makesymmetric(QZX2' * aux1)
	aux3		= cholsolve(S, QZy)
	if (aux3[1,1]==.) {
		aux3	= qrsolve(S, QZy)
		npd = 1
	}
	beta		= cholsolve(aux2, QZX2' * aux3)
	if (beta[1,1]==.) {
		beta	= qrsolve(aux2, QZX2' * aux3)
		npd = 1
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
	string scalar	avarcmd
	real scalar		N, LM
	pointer matrix	e, y, Z, X, cuewvar
	real matrix		ZZ
}
end


version 11.2
mata:
void s_cue_beta(										///
						scalar N,						///
						string scalar y_name,			///
						string scalar X_names,			///
						string scalar Z_names,			///
						string scalar e_name,			///
						string scalar touse,			///
						string scalar binit_name,		///
						string scalar cuewvar_name,		///
						string scalar ZZ_name,			///
						string scalar avarcmd,			///
						scalar LM,						///
						string scalar traceonoff		///
				)
{

// Declare cuestruct
	struct ms_cuestruct scalar cuestruct

// Views
	st_view(e, ., e_name, touse)
	st_view(y, ., y_name, touse)
	st_view(X, ., (X_names), touse)
	st_view(Z, ., (Z_names), touse)
	st_view(cuewvar, ., cuewvar_name, touse)

// Pointers to views
	cuestruct.e			= &e
	cuestruct.Z			= &Z
	cuestruct.cuewvar	= &cuewvar
	cuestruct.y			= &y
	cuestruct.X			= &X
// Scalars
	cuestruct.N			= N
	cuestruct.LM		= LM
// Matrices
	cuestruct.ZZ		= st_matrix(ZZ_name)
// Strings
	cuestruct.avarcmd	= avarcmd

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

	beta = optimize(S)								//  row vector
	beta = beta'									//  col vector

	st_matrix("r(beta)", beta)
	
}
end

version 11.2
mata:
void m_cuecrit(todo, beta, struct ms_cuestruct scalar cuestruct, j, g, H)
{

	(*cuestruct.e)[.,.] = *cuestruct.y - *cuestruct.X * beta'	//  calc residuals given beta
																//  so that Stata variable (view) is changed

	Ze = quadcross(*cuestruct.Z, *cuestruct.cuewvar, *cuestruct.e)
	gbar = 1/cuestruct.N * Ze									//  mean of moments, 1/N * Z'e
	
	if (!cuestruct.LM) {										//  MD/Wald so must partial Z out of e
		pihat = cholsolve(cuestruct.ZZ, Ze)
		(*cuestruct.e)[.,.] = *cuestruct.e - *cuestruct.Z * pihat
	}

	_rc = _stata(cuestruct.avarcmd,1)							//  call avar (Stata program) to get S matrix using new resids
	if (_rc > 0) {												//  no output, get return code
errprintf("\nError: internal call to -avar- for CUE failed\n")
		exit(504)
	}

	omega = st_matrix("r(S)")

	aux1 = cholsolve(omega, gbar)

	if (aux1[1,1]==.) {
		aux1 = qrsolve(omega, gbar)
		st_numscalar("r(npd)",1)
	}

	j = cuestruct.N * gbar' * aux1

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
	aux0 = cholsolve(var_wbeta,rwald)
	if (aux0[1,1]==.) {
		aux0 = qrsolve(var_wbeta,rwald)
		npd = 1
	}
	wald_chi2 = rwald' * aux0

	st_numscalar("r(wald_chi2)",wald_chi2)
	st_numscalar("r(npd)",npd)
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
							pointer p,							///
							scalar points,						///
							string scalar pointsvec,			///
							string scalar colsvec,				///
							string scalar levelsvec				///
							)
{

	gridpoints		=strtoreal(tokens(pointsvec))
	gridcols		=strtoreal(tokens(colsvec))
	levels			=strtoreal(tokens(levelsvec))
	rtable			= (100*(*p)[.,gridcols]) :< (100 :- levels)					//  missings => zeros (thus included in CI)
	rtable			= (*p)[.,vnum], rtable										//  append column 1 with grid nulls for sorting
	_sort(rtable, 1)															//  ... and sort on nulls in col 1

	pcitable = J(0, 1+cols(gridcols), 1)										//  initialize new CI table
	
	pointsi=gridpoints[1,vnum]													//  points in grid for variable vnum
	blocksize=points/pointsi
	

	 for (i=1; i<=pointsi; i++) {
		block = rtable [ ((i-1)*blocksize+1)::(i*blocksize), (2..cols(rtable)) ]

		pcitablei = floor(colsum(block) * 1/blocksize)							//  * 1/blocksize means cols with all ones
																				//  will sum=1 and other cols will sum<1.
																				//  floor(.) converts former to 1 and latter to 0.
		pcitable = pcitable \ (rtable[(i*blocksize),1] , pcitablei)				//  and append with null to pcitable
	}

	st_matrix("r(pcitable)", pcitable)

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
				closedform(integer 0)	///
				clrsims(integer -1)		///
				overid(integer 0)		///
				iid(integer 0)			///
				nexexog(integer 0)		///
				nendog(integer 0)		///
				nsendog(integer 0)		/// also boolean for strongly-IDed vars
				ncsendog(integer 0)		/// also boolean for subset AR test
				ar_chi2(real 0)			///
				k_chi2(real 0)			///
				j_chi2(real 0)			///
				kwt(string)				///
				clr_stat(real 0)		///
				wald_chi2(real 0)		///
				rk(real 0)				///
				 *]

	tempname wald_p ar_p clr_p kj_p k_p j_p rk_p
	
	local wald_df		= `nendog' - `nsendog' - `ncsendog'
	scalar `wald_p'		= chi2tail(`nendog',`wald_chi2')
	local ar_df			= `nexexog' - `nsendog' - `ncsendog'
	scalar `ar_p'		= chi2tail(`ar_df',`ar_chi2')
	local rk_df			= `nexexog' - `nendog' + 1					//  df = L-K+1; #strong endog net out
	scalar `rk_p'		= chi2tail(`rk_df',`rk')

* K p-value
	if `overid' & ~`ncsendog' {
		local k_df		= `nendog' - `nsendog'
		scalar `k_p'	= chi2tail(`k_df',`k_chi2')
		local j_df		= `nexexog'-`nendog'
		scalar `j_p'	= chi2tail(`j_df',`j_chi2')
* Instead of R = (1-p1)(1-p2) ~= p1+p2 (since p1*p2 negligible for small alphas/ps), exact:
		local p1=`k_p'/`kwt'		*	(1 - (1-`kwt')*`k_p')
		local p2=`j_p'/(1-`kwt')	*	(1 - `kwt'*`j_p')
		scalar `kj_p' = min(`p1',`p2')
	}

* CLR p-value
	if `overid' & ~`ncsendog' {										//  overidentified and not subset-AR, so need CLR stat p-value
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
	}

	return scalar wald_df	=`wald_df'
	return scalar wald_p	=`wald_p'
	return scalar ar_df		=`ar_df'
	return scalar ar_p		=`ar_p'
	return scalar rk_p		=`rk_p'
	return scalar rk_df		=`rk_df'
	if `overid' & ~`ncsendog' {
		return scalar clr_p		=`clr_p'
		return scalar kj_p		=`kj_p'
		return scalar k_df		=`k_df'
		return scalar k_p		=`k_p'
		return scalar j_df		=`j_df'
		return scalar j_p		=`j_p'
	}

end

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
