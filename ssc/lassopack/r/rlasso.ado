*! rlasso 1.0.10 13jan2019
*! lassopack package 1.3.1
*! authors aa/cbh/ms

* Also see lassoutils.ado notes for details of code updates.
* Updates (release date):
* 1.0.05  (30jan2018)
*         First public release.
*         Added seed(.) option to rlasso/lassoutils to control rnd # seed for xdep & sup-score.
*         Fixed bug in DisplayCoefs (didn't accommodate both e(notpen) and e(pnotpen)).
*         Promoted to require version 13 or higher.
*         Added dots option.
*         Fixed displaynames bug (wrong dictionaries used for partialled-out vars).
*         Recoding of cons and demeaning flags.
*         partial and nocons no longer compatible.
*         Removed hdm version of sup-score stat.
*         Removed misc debug code.
* 1.0.06  (10feb2018)
*         Support for Sergio Correia's FTOOLS FE transform (if installed).
* 1.0.07  (29aug2018)
*         Added support for string cluster variable.
*         Added support for aweights and pweights (equivalent) by preweighting.
*         Fixed display bug when no penalized or unpenalized vars selected.
* 1.0.08  (26nov2018)
*         Added saved value of objective function (pmse for lasso, prmse for sqrt-lasso).
*         Added two undocumented options: sigma(.) to override lasso estimation of initial sigma
*           and ssiid to override use of multiplier bootstrap for sup-score test.
* 		  changed "partial" to "PARtial" option
* 1.0.09  (11dec2018)
*         Added support for combination of partial(.) + nocons
*         Bug fix that would cause exit with error if cluster + no penalized vars.
* 1.0.10  (13jan2019)
*         Replaced pols option with ols option; fixed reporting of e(estimator) macro; more use of flag macros.
*         Replace Ups terminology with Psi (penalty loadings). Dropped usage of gammad.
*         Bug fix - FE + weights would fail if data were not sorted on xtset panel var.

* to do - noftools + weights

program rlasso, eclass sortpreserve

	version 13
	
	syntax [anything] [if] [in] [aw pw]	///
		[,								///
		displayall						///
		varwidth(int 17)				///
		VERsion							///
		supscore						///
		testonly						///
		*								///
		]
		
	local lversion 1.0.09
	local pversion 1.1.01

	if "`version'" != "" {							//  Report program version number, then exit.
		di in gr "rlasso version `lversion'"
		di in gr "lassopack package version `pversion'"
		ereturn clear
		ereturn local version		`lversion'
		ereturn local pkgversion	`pversion'
		exit
	}

	if ~replay() {									//  not replay so estimate
		_rlasso `anything'							///
			`if' `in' [`weight' `exp'],				///
			`options' `supscore' `testonly'
	}
	else if e(cmd)~="rlasso" {						//  replay, so check that rlasso results exist
		di as err "last estimates not found"
		exit 301
	}
	
	if "`e(method)'"~="" {
		DisplayCoefs, `displayall' varwidth(`varwidth')
	}
	
	// temp measure
	if e(supscore) < . {
		DisplaySupScore
	}

end

program _rlasso, eclass sortpreserve

	version 13

	syntax varlist(numeric fv ts min=2)					///
		[aw pw/] [if] [in]								///
		[,												///
														/// specify options with varlists to be used by marksample/markout
		PNOTPen(varlist fv ts numeric)					/// list of variables not penalised
		PARtial(string)									/// string so that list can contain "_cons"
		fe												/// do within-transformation
		NOCONStant										///  
		CLuster(varlist max=1)							/// penalty level/loadings allow for within-panel dependence & heterosk.
		ols												/// post-lasso coefs in e(b) (default=lasso)
		pols											/// legacy option (equivalent to ols)
		prestd											///
		dm												/// treat data as having zero mean (for debugging use)
		VERbose											/// pass to lassoutils
		VVERbose										/// pass to lassoutils
		dots											///
		displaynames_o(string)							/// dictionary with names of vars as supplied in varlist
		displaynames_d(string)							/// corresponding display names of vars
		pminus(int 0)									/// overrides calculation of pminus
		debug											/// used for debugging
		postall											/// full coef vector in e(b) (default=selected only)
		testonly										/// obtain supscore test only
		NOFTOOLS										///
		*												/// additional options to be passed to lassoutils
		]

	*** rlasso-specific
	//  to distinguish between lasso2 and rlasso treatment of notpen,
	//  rlasso option is called pnotpen
	//  to keep lasso2 and rlasso code aligned, rename to notpen here
	//  and at end of program save macros as pnotpen
	//  temporary measure until lasso2 and rlasso code is merged
	local notpen	`pnotpen'

	//  flags
	local olsflag		=("`ols'`pols'"~="")	// pols is a legacy option equivalent to ols
	local testonlyflag	=("`testonly'"~="")
	local debugflag		=("`debug'"~="")
	local postallflag	=("`postall'"~="")
	*

	*** Record which observations have non-missing values
	marksample touse
	markout `touse' `varlist' `cluster' `ivar', strok
	sum `touse' if `touse', meanonly
	local N		= r(N)
	*
	
	*** FEs. Create 1/0 flag.
	// Get panel id
	local feflag=("`fe'"~="")
	if `feflag' {
		cap _xt
		if _rc ~= 0 {
			di as err "Error: fe option requires data to be xtset"
			exit 459
		}
		else {
			local ivar	`r(ivar)'
		}
		// fe transformation may expect data to be sorted on ivar
		local sortvar	: sortedby
		local sortvar	: word 1 of `sortvar'				// in case sorted on multiple variables
		if "`ivar'"~="`sortvar'" {
			di as text "(sorting by xtset panelvar `ivar')"
			sort `ivar'
		}
	}
	*
	
	*** prestd flag
	// nb: if model has constant, prestd will demean (i.e. partial it out)
	local prestdflag	=("`prestd'"~="")
	*
	
	*** weight flag
	local weightflag	=("`weight'"~="")
	*
	
	*** constant, partial, etc.
	// conmodel: constant in original model
	// consflag: constant in transformed equation to estimate
	// dmflag:   treat data as zero-mean
	if `weightflag' & ("`noconstant'"~="") {
		// incompatible options - with weights, must have a constant to partial out or remove by FE
		di as err "incompatible options - weights + noconstant"
		exit 198
	}
	local consmodel		=("`noconstant'"=="")
	if `feflag' {
		local consmodel	0									//  if fe, then consmodel=0 always
	}
	// model with weights must have a constant before partialling out or FE transformation
	// weighting implies special treatment of constant - must be partialled-out
	// will be automatic if fe
	if `weightflag' & ~`feflag' {
		local partial		`partial' _cons					//  duplicate _cons not a problem since removed below
	}
	local partialflag	=("`partial'"~="")					//  =1 even if just cons is being partialled out
	// tell estimation code if cons will have been partialled out or there isn't one in the first place
	// note that prestandardizing always implies the constant, if present, is to be calculated by the calling program
	if `feflag' | `partialflag' | `prestdflag' | (`consmodel'==0) {
		local consflag	0
	}
	else {
		local consflag	1
	}
	// "_cons" allowed as an argument to partial(.) - remove it
	local partial		: subinstr local partial "_cons" "", all word count(local pconscount)
	local notpen		: subinstr local notpen "_cons" "", all word count(local notpenconscount)
	if "`dm'"~="" {
		// dmflag tells estimation code to treat data as zero-mean; user can force this with dm option
		local dmflag	1
	}
	else if `consmodel' {
		// model has an constant that will be partialled out or treated as unpenalized
		local dmflag	0
	}
	else {
		// special case - nocons and no FEs means treat vars as if demeaned
		local dmflag	1
	}
	*

	*** weights ***
	// create weight variable wvar
	if `weightflag' {
		// pw = aw + robust ... and more commands allow aw
		local wtexp `"[aw=`exp']"'
		tempvar wvar
		qui gen double `wvar'=`exp'
		sum `wvar' if `touse' `wtexp', meanonly
		if r(min)<0 {
			di as err "error - negative weights encountered"
			exit 101
		}
		// Weight statement
		di as text "(sum of wgt is " %14.4e `r(sum_w)' ")"
		// normalize to have unit mean
		qui replace `wvar' = `wvar' * `N'/r(sum_w)
	}
	if "`weight'"=="pweight" {
		// pw => robust
		local options	`options' robust
		local options	: list uniq options
	}
	*

	*** create main varlist and tempvars
	// remove duplicates from varlist
	// _o list is vars with original names
	fvexpand `varlist' if `touse'
	local varlist_o	`r(varlist)'
	// check for duplicates has to follow expand
	local dups			: list dups varlist_o
	if "`dups'"~="" {
		di as text "Dropping duplicates: `dups'"
	}
	local varlist_o		: list uniq varlist_o
	*

	*** Create separate _o varlists: Y, X, notpen, partial
	// Y, X
	local varY_o		: word 1 of `varlist_o'
	local varX_o		: list varlist_o - varY_o				//  incl notpen/partial
	// notpen
	fvexpand `notpen' if `touse'
	local notpen_o		`r(varlist)'
	local dups			: list dups notpen_o
	if "`dups'"~="" {
		di as text "Dropping duplicates: `dups'"
	}
	local notpen_o		: list uniq notpen_o
	// partial
	fvexpand `partial' if `touse'
	local partial_o		`r(varlist)'
	local dups			: list dups partial_o
	if "`dups'"~="" {
		di as text "Dropping duplicates: `dups'"
	}
	local partial_o		: list uniq partial_o
	// "model" = vars without partialled-out
	local varXmodel_o	: list varX_o - partial_o
	*
	
	*** syntax checks
	// check that notpen vars are in full list
	local checklist	: list notpen_o - varX_o
	local checknum	: word count `checklist'
	if `checknum' {
		di as err "syntax error - `checklist' in notpen(.) but not in list of regressors"
		exit 198
	}
	// check that partial vars are in full list
	local checklist	: list partial_o - varX_o
	local checknum	: word count `checklist'
	if `checknum' {
		di as err "syntax error - `checklist' in partial(.) but not in list of regressors"
		exit 198
	}
	// check that ivar (FE) is not a used variable
	if `feflag' {
		fvrevar `varY_o' `varX_o', list					//  list option means we get only base vars
		local vlist `r(varlist)'
		local checklist	: list ivar - vlist
		local checknum	: word count `checklist'
		if `checknum'==0 {
			di as err "syntax error - `ivar' is xtset variable and cannot be used in model"
			exit 198
		}
	}
	// other checks
	if `pconscount' & `feflag' {
		di as err "error: incompatible options, partial(_cons) and fe"
		exit 198
	}
	if `feflag' & "`noconstant'"~="" {
		di as err "error: incompatible options, fe and nocons"
		exit 198
	}
	*
	
	*** Create _t varlists: Y, X, notpen, partial
	// _o list is vars with original names
	// _t list is temp vars if transform needed, original vars if not
	if `feflag' | `weightflag' {								//  everything needs to be transformed including partial
		local temp_ct : word count `varlist_o'
		mata: s_maketemps(`temp_ct')
		local varlist_t `r(varlist)'
	}
	else if `partialflag' | `prestdflag' {						//  everything except partial_o needs to be transformed
		local varYXmodel_o `varY_o' `varXmodel_o'
		local temp_ct : word count `varYXmodel_o'
		mata: s_maketemps(`temp_ct')
		local varYXmodel_t `r(varlist)'
		matchnames "`varlist_o'" "`varYXmodel_o'" "`varYXmodel_t'"
		local varlist_t		`r(names)'
	}
	else {														//  no transformation needed but still need temps
		fvrevar `varlist_o' if `touse'							//  fvrevar creates temps only when needed
		local varlist_t		`r(varlist)'
	}
	// dictionary is now varlist_o / varlist_t
	// now create separate _o and _t varlists using dictionary
	foreach vlist in varY varX varXmodel notpen partial {
		matchnames "``vlist'_o'" "`varlist_o'" "`varlist_t'"
		local `vlist'_t		`r(names)'						//  corresponding tempnames; always need this because of possible fvs
	}
	*

	******************* Display names ***********************************************************
	//  may be called by another program with tempvars and display names for them
	//  if display names option not used, use _o names as provided in rlasso command
	//  if display names option used, use display names matched with _o names
	//  if display names macros are empty, has no effect
	matchnames "`varY_o'" "`displaynames_o'" "`displaynames_d'"
	local varY_d		`r(names)'
	matchnames "`varXmodel_o'" "`displaynames_o'" "`displaynames_d'"
	local varXmodel_d	`r(names)'
	matchnames "`varX_o'" "`displaynames_o'" "`displaynames_d'"
	local varX_d		`r(names)'
	matchnames "`notpen_o'" "`displaynames_o'" "`displaynames_d'"
	local notpen_d		`r(names)'
	matchnames "`partial_o'" "`displaynames_o'" "`displaynames_d'"
	local partial_d		`r(names)'
	*

	*** summary varlists and flags:
	* varY_o		= dep var
	* varY_t		= dep var, temp var
	* varX_o		= full, expanded set of RHS, original names, includes partial
	* varX_t		= as above but with temp names for all variables
	* varXmodel_o	= full, expanded set of RHS, original names, excludes partial
	* varXmodel_t	= as above but with temp names for all variables
	* notpen_o		= full, expanded set of not-penalized
	* notpen_t		= as above but with temp names for all variables
	
	//  p is number of penalized vars in the model; follows convention in BCH papers
	//  p is calculated in lassoutils/_rlasso as number of model vars excluding constant
	//  here we calculate which of the model vars are unpenalized or omitted/base vars
	//  to provide as `pminus' to lassoutils/_rlasso (unless provided by user)
	//  do here so that code above is compatible with lasso2
	//  use _o names / display names since they have info on whether var is omitted/base/etc.
	if ~`pminus' {
		foreach vn of local varXmodel_d {								//  display names
			_ms_parse_parts `vn'
			// increment pminus if model variable is MISSING
			if r(omit) {
				local ++pminus
			}
		}
		foreach vn of local notpen_d {									//  display names
			_ms_parse_parts `vn'
			// increment pminus if notpen variable is NOT MISSING
			if ~r(omit) {
				local ++pminus
			}
		}
	}
	//  p0 here is total number of variables provided to model EXCLUDING constant
	local p0	: word count `varXmodel_o'
	local p		=`p0'-`pminus'
	// warn
	if `p'<=0 {
		di as text "warning: no penalized variables; estimates are OLS"
	}
	//  now for error-checking below, p0 should INCLUDE constant unless partialled-out etc.
	local p0	=`p0'+`consflag'
	*

	******************* FE, partialling out, standardization, weighting *****************************
	//  varX are all X vars including partial
	//  varXmodel are model vars excluding partial
	//  FE transform applies to varX; incorporates weighting in FE transform but does not weight transformed vars.
	//  Partialling applies to varXmodel; same treatment of weights and vars as with FE.
	//  Weights transform applies to varXmodel after possible FE/partial; multiplies vars by sqrt(wvar).
	//  Prestd transform applies to varX model after possible FE/partial/weighting; standardizes vars.
	//  If FE:    partial-out FEs from Xmodel temp variables, then preserve,
	//            then partial-out low-dim ctrls from temp variables
	//            restore will restore all temp vars with only FEs partialled-out
	//  If no FE: leave original variables unchanged.
	//            partial-out low-dim ctrls from Xmodel temp variables.
	//            if no FE/low-dim ctrls, no transform needed
	//  NB: unpartial routine expects unweighted vars and recovers partialled-out coeffs from weighted OLS.
	//      hence with FE, preserve after FE transformation but before weighting.

	if `feflag' {												//  FE-transform all variables including those to partial-out
		// first FE transformation
		fvrevar `varY_o' `varX_o' if `touse'					//  in case any FV or TS vars in _o list
		local vlist		`r(varlist)'
		local vlist_t	`varY_t' `varX_t'						//  everything including partialling Xs
		lassoutils `vlist',										/// call on _o list
						touse(`touse')							///
						tvarlist(`vlist_t')						/// initialize _t vars
						wvar(`wvar')							/// weighted demeaning but vars left unweighted
						`noftools'								///
						fe(`ivar')								//  triggers branching to FE utility
		local dmflag	=1										//  data are now demeaned
		local N_g	=r(N_g)										//  N_g will be empty if no FEs
		local noftools `r(noftools)'							//  either not installed or user option
		// now partialling-out if any
		if `partialflag' {										//  And then partial out any additional vars	
			preserve											//  preserve the original values of tempvars before partialling out
			local vlist		`varY_t' `varXmodel_t'				//  model vars have been FE-transformed already
			local vlist_t	`varY_t' `varXmodel_t'				//  corresponding temp vars
			local pvlist	`partial_t'							//  partial vars have been FE-transformed already
			lassoutils `vlist',									///
							touse(`touse')						/// don't need tvarlist because vars already created
							tvarlist(`vlist_t')					/// overwrite these (were initialized by FE utility)
							partial(`pvlist')					/// partial vars are already FE-transformed
							partialflag(`partialflag')			/// triggers branching to partial utility
							wvar(`wvar')						/// weight vars if necessary
							dmflag(1)							//  FE => data already demeaned
		}
		if `weightflag' {										//  applies only to Y and Xmodel vars
			lassoutils `varY_t' `varXmodel_t',					/// _t vars have been created and filled so use here
							touse(`touse')						/// don't need tvarlist because vars already created
							tvarlist(`varY_t' `varXmodel_t')	/// overwrite these (were initialized by FE utility)
							wvar(`wvar')						//  triggers branching to weighting utility
		}
		if `prestdflag' {										//  applies only to Y and Xmodel vars
			tempname prestdY prestdX
			lassoutils `varY_t',								/// _t vars have been created and filled so use here
							touse(`touse')						/// don't need tvarlist because vars already created
							tvarlist(`varY_t')					/// overwrite this (was initialized by FE utility)
							std									///
							dmflag(1)							//  FE => data already demeaned
			mat `prestdY'=r(stdvec)
			lassoutils `varXmodel_t',							/// 
							touse(`touse')						/// 
							tvarlist(`varXmodel_t')				/// overwrite this (was initialized by FE utility)
							std									///
							dmflag(1)							//  FE => data already demeaned 
			mat `prestdX'=r(stdvec)
		}
	}
	else if `partialflag' {										//  no FE but partial out from Y and Xmodel vars
																//  always enter with weights unless no cons in model
		fvrevar `varY_o' `varXmodel_o' if `touse'				//  in case any FV or TS vars in _o list
		local vlist		`r(varlist)'							//  Y and Xmodel _o lists after fvrevar-ing
		local vlist_t	`varY_t' `varXmodel_t'					//  corresponding temp vars; Y and Xmodel onlyu
		fvrevar `partial_o' if `touse'							//  in case any FV or TS vars in _o list
		local pvlist	`r(varlist)'							//  partial_o list after fvrevar-ing
		lassoutils `vlist',										/// apply to Y and Xmodel_o list after fvrevar-ing
						touse(`touse')							///
						partial(`pvlist')						/// use partial_o list after fvrevar-ing
						wvar(`wvar')							/// use weights when partialling out
						tvarlist(`vlist_t')						/// initialize the tempvars
						partialflag(`partialflag')				/// triggers branching to partial utility
						dmflag(`dmflag')						//  treat data as not yet demeaned unless nocons
		local dmflag	=1										//  data are now demeaned
		if `weightflag' {										//  initialized tempvars now need to be weighted by sqrt(wvar)
			lassoutils `vlist_t',								/// applies to Y and Xmodel only
							touse(`touse')						///
							tvarlist(`vlist_t')					/// overwrite these
							wvar(`wvar')						//  triggers branching to weighting utility
		}
		if `prestdflag' {										//  applies to Y and Xmodel only
			tempname prestdY prestdX
			lassoutils `varY_t',								/// apply to varY_t vars (already initialized by partialling)
							touse(`touse')						/// 
							tvarlist(`varY_t')					/// overwrite _t var
							std									///
							dmflag(1)							//  partial => data already demeaned
			mat `prestdY'=r(stdvec)
			lassoutils `varXmodel_t',							/// apply to varXmodel_t vars (already initialized by partialling)
							touse(`touse')						/// 
							tvarlist(`varXmodel_t')				/// overwrite _t vars
							std									///
							dmflag(1)							//  partial => data already demeaned
			mat `prestdX'=r(stdvec)
		}
	}
	else if `weightflag' & `prestdflag' {						//  should not enter here since weights => constant => partial
		di as err "internal rlasso error - weightflag+prestdflag"
		exit 499
	}
	else if `prestdflag' {										//  nothing partialled out so varXmodel = varX
																//  data are unweighted
		tempname prestdY prestdX
		fvrevar			`varY_o' if `touse'						//  first standardize varY
		local vlist		`r(varlist)'							//  varY_o list after fvrevar-ing
		local vlist_t	`varY_t'								//  corresponding temp var
		lassoutils `vlist',										///
						touse(`touse')							///
						std										///
						tvarlist(`vlist_t')						/// initialize these
						consmodel(`consmodel')					///
						dmflag(`dmflag')						//  data not mean zero unless overridden by user
		mat `prestdY'=r(stdvec)
		fvrevar			`varXmodel_o' if `touse'				//  now standardize varXmodel_o
		local vlist		`r(varlist)'							//  varXmodel_o list after fvrevar-ing
		local vlist_t	`varXmodel_t'							//  corresponding temp vars
		lassoutils `vlist',										///
						touse(`touse')							///
						std										///
						tvarlist(`vlist_t')						/// initialize these
						consmodel(`consmodel')					///
						dmflag(`dmflag')						//  data not mean zero unless overridden by user
		mat `prestdX'=r(stdvec)
	}
	else if `weightflag' {										//  nothing partialled out, no std, varXmodel=varX
																//  only reach here if no constant (since cons is partialled out)
		fvrevar			`varY_o' `varXmodel_o' if `touse'		//  in case any FV or TS vars in _o list
		local vlist		`r(varlist)'							//  _o list after fvrevar-ing
		local vlist_t	`varY_t' `varXmodel_t'					//  corresponding temp vars
		lassoutils `vlist',										/// call on _o list after fvrevar-ing
						touse(`touse')							///
						tvarlist(`vlist_t')						/// initialize the tempvars
						wvar(`wvar')							//  triggers branching to weighting utility
	}

	************* Partialling/standardization END ***********************************************

	************* Lasso estimation with transformed/partialled-out vars *************************
	if "`verbose'`vverbose'`dots'"=="" {
		local quietly "quietly"							//  don't show lassoutils output
	}

	`quietly' lassoutils `varY_t',						///
						rlasso							/// branch to _rlasso subroutine
														/// nocons, no penloads, etc. all assumed
						touse(`touse')					///
						xnames_o(`varXmodel_d')			/// display names for lassoutils output
						xnames_t(`varXmodel_t')			///
						cluster(`cluster')				///
						notpen_o(`notpen_d')			///
						notpen_t(`notpen_t')			///
						consflag(`consflag')			/// =0 if cons already partialled out or if no cons
						dmflag(`dmflag')				/// =1 if data have been demeaned
						pminus(`pminus')				///
						stdy(`prestdY')					///
						stdx(`prestdX')					///
						`verbose' `vverbose' `dots'		///
						`testonly'						///
						`options'
	*

	************* Finish up ********************************************************
	*** e-return lasso estimation results
	tempname b beta betaOLS Psi sPsi ePsi
	tempname betaAll betaAllOLS
	tempname lambda slambda lambda0 rmse rmseOLS objfn
	tempname c gamma
	tempname supscore supscore_p supscore_cv supscore_gamma

	if ~`testonlyflag' {
	
		if "`cluster'" ~= "" {
			local N_clust		=r(N_clust)
		}
		mat `beta'			=r(beta)		//  may be empty!
		mat `betaOLS'		=r(betaOLS)		//  may be empty!
		mat `betaAll'		=r(betaAll)
		mat `betaAllOLS'	=r(betaAllOLS)
		mat `Psi'			=r(Psi)
		mat `sPsi'			=r(sPsi)
		mat `ePsi'			=r(ePsi)
		scalar `lambda'		=r(lambda)
		scalar `slambda'	=r(slambda)
		scalar `lambda0'	=r(lambda0)
		scalar `c'			=r(c)
		scalar `gamma'		=r(gamma)
		scalar `rmse'		=r(rmse)		//  Lasso RMSE
		scalar `rmseOLS'	=r(rmseOLS)		//  post-Lasso RMSE
		scalar `objfn'		=r(objfn)
		local selected		`r(selected)'	//  EXCL NOTPEN/CONS
		local selected0		`r(selected0)'	//  INCL NOTPEN, EXCL CONS
		local s				=r(s)			//  EXCL NOTPEN/CONS; number of elements in selected
		local s0			=r(s0)			//  INCL NOTPEN, EXCL CONS; number of elements in selected0
		local clustvar		`r(clustvar)'
		local robust		`r(robust)'
		local center		=r(center)
		local method		`r(method)'		//  lasso or sqrt-lasso
		local niter			=r(niter)
		local maxiter		=r(maxiter)
		local npsiiter		=r(npsiiter)
		local maxpsiiter	=r(maxpsiiter)
		// these can be missings
		scalar `supscore'		=r(supscore)
		scalar `supscore_p'		=r(supscore_p)
		scalar `supscore_cv'	=r(supscore_cv)
		scalar `supscore_gamma'	=r(supscore_gamma)
		local ssnumsim			=r(ssnumsim)

		// flag for empty beta (consflag=0 means rlasso didn't estimate a constant)
		local betaempty		=(`s0'==0 & `consflag'==0)
		// error check
		if `betaempty' {
			if ~(colsof(`beta')==1 & `beta'[1,1]==.) {
				di as err "internal _rlasso error - beta should be empty (no vars estimated) but isn't
				exit 499
			}
		} 
		// issue warning if lasso max iteration limit hit
		if `niter'==`maxiter' {
			di as text "Warning: reached max shooting iterations w/o achieving convergence."
		}
		// error check - p0s and ps should match
		if `p0'~=r(p0) {					//  number of all variables in betaAll INCL NOTPEN/CONS (if present or not partialled etc.)
			di as err "internal _rlasso error - p0 count of model vars `p0' does not match returned value `r(p0)'"
			exit 499
		}
		if `p'~=r(p) {						//  number of penalized variables in model
			di as err "internal _rlasso error - p count of penalized vars `p' does not match returned value `r(p)'"
			exit 499
		}
		// fix depvar (rownames) of beta vectors to use _o (or _d if display names provided) not _t
		mat rownames `beta'			= `varY_d'
		mat rownames `betaOLS'		= `varY_d'
		mat rownames `betaAll'		= `varY_d'
		mat rownames `betaAllOLS'	= `varY_d'
		if ~`betaempty' {								// cnames should stay empty if beta has a single missing value
			local cnames_o	: colnames `beta'
			fvstrip `cnames_o'							//  colnames may insert b/n/o operators - remove
			local cnames_o	`r(varlist)'
			matchnames "`cnames_o'" "`varlist_o'" "`varlist_t'"
			local cnames_t	`r(names)'
		}
		else {
			local cnames_o
			local cnames_t
		}
		*
	
		*********** Get coeff estimates for partialled-out vars/std intercept. ********************
		if `feflag' & `partialflag' {					//  FE case and there are partialled-out notpen vars
			restore										//  Restores dataset with tempvars after FE transform but before notpen partialled out
		}
		if `partialflag' | (`prestdflag' & `consmodel') {	//  standardization removes constant so must enter for that
			if `feflag' {
				local depvar `varY_t'					//  use FE-transformed depvar and X vars before any weighting
				local scorevars `cnames_t'
				local partialvars `partial_t'
			}
			else {
				local depvar `varY_o'					//  use original depvar and X vars
				local scorevars `cnames_o'
				local partialvars `partial_o'
			}
			lassoutils `depvar',						///
				unpartial								///
				touse(`touse')							///
				beta(`beta')							///
				scorevars(`scorevars')					///
				partial(`partialvars')					///
				wvar(`wvar')							/// unpartial routine expects UNWEIGHTED vars + weight vector
				names_o(`varX_d')						/// dictionary
				names_t(`varX_t')						///	dictionary
				consmodel(`consmodel')
			mat `beta'			= r(b)
			mat `betaAll'		= `betaAll', r(bpartial)
			lassoutils `depvar',						///
				unpartial								///
				touse(`touse')							///
				beta(`betaOLS')							///
				scorevars(`scorevars')					///
				partial(`partialvars')					///
				wvar(`wvar')							///
				names_o(`varX_d')						/// dictionary
				names_t(`varX_t')						///	dictionary
				consmodel(`consmodel')
			mat `betaOLS'		= r(b)
			mat `betaAllOLS'	= `betaAllOLS', r(bpartial)
			// for unknown reasons, _ms_build_info doesn't add info here (e.g. "base")
			_ms_build_info	`beta' if `touse'
			_ms_build_info	`betaAll' if `touse'
			_ms_build_info	`betaOLS' if `touse'
			_ms_build_info	`betaAllOLS' if `touse'
			// finish by setting betaempty to 0
			local betaempty	=0
		}
		*
	
		*** Prepare and post results
		if ~`olsflag' & ~`postallflag' {										//  selected lasso coefs by default
			mat `b' = `beta'
		}
		else if `olsflag' & ~`postallflag' {								//  selected post-lasso coefs
			mat `b' = `betaOLS'
		}
		else if ~`olsflag' {												//  full lasso coef vector
			mat `b' = `betaAll'
		}
		else {																	//  full post-lasso coef vector
			mat `b' = `betaAllOLS'
		}
		if `betaempty' & ~`postallflag' {										//  no vars in b
			ereturn post    , obs(`N') depname(`varY_d') esample(`touse')		//  display name
		}
		else {																	//  b has some selected/nonpen/cons
			ereturn post `b', obs(`N') depname(`varY_d') esample(`touse')		//  display name
		}	
		// additional returned results
		ereturn local noftools		`noftools'
		ereturn local postall		`postall'
		ereturn scalar niter		=`niter'
		ereturn scalar maxiter		=`maxiter'
		ereturn scalar npsiiter		=`npsiiter'
		ereturn scalar maxpsiiter	=`maxpsiiter'
		ereturn local robust		`robust'
		ereturn local ivar			`ivar'
		ereturn local selected		`selected'			//  selected only
		ereturn local varXmodel		`varXmodel_d'		//  display name
		ereturn local varX			`varX_d'			//  display name
		if `olsflag' {
			ereturn local estimator	ols
		}
		else {
			ereturn local estimator	`method'
		}
		ereturn local method		`method'
		ereturn local predict		rlasso_p
		ereturn local cmd			rlasso
		ereturn scalar center		=`center'
		ereturn scalar cons			=`consmodel'
		ereturn scalar lambda		=`lambda'
		ereturn scalar lambda0		=`lambda0'
		ereturn scalar slambda		=`slambda'
		ereturn scalar c			=`c'
		ereturn scalar gamma		=`gamma'
	
		if `supscore' < . {
			ereturn scalar ssnumsim			=`ssnumsim'
			ereturn scalar supscore			=`supscore'
			ereturn scalar supscore_p		=`supscore_p'
			ereturn scalar supscore_cv		=`supscore_cv'
			ereturn scalar supscore_gamma	=`supscore_gamma'
		}
	
		if "`N_clust'" ~= "" {
			ereturn local clustvar	`clustvar'
			ereturn scalar N_clust	=`N_clust'
		}
		if "`N_g'" ~= "" {
			ereturn scalar N_g		=`N_g'
		}
		ereturn scalar fe			=`feflag'
		ereturn scalar rmse			=`rmse'
		ereturn scalar rmseOLS		=`rmseOLS'
		if "`method'"=="sqrt-lasso" {
			ereturn scalar prmse	=`objfn'
		}
		else {
			ereturn scalar pmse		=`objfn'
		}
		ereturn scalar pminus		=`pminus'
		ereturn scalar p			=`p'					//  number of all penalized vars; excludes omitteds etc.
		ereturn scalar s0			=`s0'					//  number of all estimated coefs (elements of beta)
		ereturn scalar s			=`s'					//  number of selected
	
		ereturn matrix sPsi 		=`sPsi'
		ereturn matrix ePsi 		=`ePsi'
		ereturn matrix Psi 			=`Psi'
		ereturn matrix betaAllOLS	=`betaAllOLS'
		ereturn matrix betaAll		=`betaAll'
		ereturn matrix betaOLS		=`betaOLS'
		ereturn matrix beta			=`beta'
	
		// rlasso-specific:
		// selected0 and s0 included partialled-out.
		// If cons exists and was not partialled out, add to notpen and selected0.
		// Otherwise if cons exists and was partialled out, add to to partial list.
		if `consmodel'  & ~`partialflag' {
			local selected0			`selected0' _cons
			local notpen_d			`notpen_d' _cons			//  display name
		}
		else if `consmodel' & `partialflag' {
			local partial_d			`partial_d' _cons			//  display name
			local selected0			`selected0' `partial_d'		//  display name
		}
		else if `partialflag' {
			local selected0			`selected0'	`partial_d'		//  display name
		}
		// remaining results
		ereturn local selected0		`selected0'
		ereturn local partial		`partial_d'					//  display name
		ereturn scalar partial_ct	=`: word count `partial_d''	//  (display name) number of partialled-out INCLUDING CONSTANT
		ereturn scalar s0			=`: word count `selected0''	//  (update) selected or notpen, INCL CONS
		// rlasso-specific - save as "pnotpen" (vs lasso2 "notpen")
		ereturn local pnotpen		`notpen_d'					//  display name
		ereturn scalar pnotpen_ct	=`: word count `notpen_d''	//  (display name) number of notpen INCLUDING CONSTANT (if not partialled-out)
		*
	}
	else {

		// sup-score test only - no lasso results
		ereturn clear

		ereturn scalar N				=r(N)
		ereturn scalar N_clust			=r(N_clust)
		ereturn scalar gamma			=r(gamma)
		ereturn scalar c				=r(c)
		ereturn scalar p				=`p'
		ereturn scalar ssnumsim			=r(ssnumsim)
		ereturn scalar supscore			=r(supscore)
		ereturn scalar supscore_p		=r(supscore_p)
		ereturn scalar supscore_cv		=r(supscore_cv)
		ereturn scalar supscore_gamma	=r(supscore_gamma)
		
		ereturn local cmd				rlasso
		ereturn scalar cons				=`consmodel'
	
	}
	
end

prog DisplaySupScore

	di
	di as text "{help rlasso##supscore:Sup-score} test H0: beta=0"
	di as text "CCK sup-score statistic" _col(25) as res %6.2f e(supscore) _c
	if e(supscore_p) < . {
		di as text _col(32) "p-value=" _col(39) as res %6.3f e(supscore_p)
	}
	else {
		di
	}
	di as text "CCK "  as res 100*e(supscore_gamma) as text "% critical value" _c
	di as res _col(25) %6.2f e(supscore_cv) _col(32) as text "(asympt bound)"

end


// Used in rlasso and lasso2.
// version  2017-12-20
// updated 31dec17 to accommodate e(pnotpen)
prog DisplayCoefs

	syntax	,								///
		[									///
		displayall							///  full coef vector in display (default=selected only)
		varwidth(int 17)					///
		NORecover 							///
		]
	
	local cons			=e(cons)
	if ("`norecover'"=="") {
		local partial		`e(partial)'
		local partial_ct	=e(partial_ct)
	}
	else {
		local partial
		local partial_ct	=0
	}

	// varlists
	local selected		`e(selected)'
	fvstrip `selected'
	local selected		`r(varlist)'
	local notpen		`e(notpen)'`e(pnotpen)'
	fvstrip `notpen'
	local notpen		`r(varlist)'
	local selected0		`e(selected0)'
	fvstrip `selected0'
	local selected0		`r(varlist)'
	// coef vectors
	tempname beta betaOLS
	if "`displayall'"~="" {						//  there must be some vars specified even if nothing selected
		mat `beta'		=e(betaAll)
		mat `betaOLS'	=e(betaAllOLS)
		local col_ct	=colsof(`beta')
		local vlist		: colnames `beta'
		local vlistOLS	: colnames `betaOLS'
		local baselevels baselevels
	}
	else if e(s0)>0 {							//  display only selected, but only if there are any
		mat `beta'		=e(beta)
		mat `betaOLS'	=e(betaOLS)
		local col_ct	=colsof(`beta')
		local vlist		: colnames `beta'
		local vlistOLS	: colnames `betaOLS'
	}
	else {										//  nothing selected, zero columns in beta
		local col_ct	=0
	}
	if e(s0)>0 {
		_ms_build_info `beta' if e(sample)
		_ms_build_info `betaOLS' if e(sample)
	}

	*** (Re-)display coefficients including constant/partial
	local varwidth1		=`varwidth'+1
	local varwidth3		=`varwidth'+3
	local varwidth4		=`varwidth'+4
	local varwidthm7	=`varwidth'-7
	local varwidthm13	=`varwidth'-13
	di
	di as text "{hline `varwidth1'}{c TT}{hline 32}"
	if "`e(method)'"=="sqrt-lasso" {
		di as text _col(`varwidthm7') "Selected {c |}      Sqrt-lasso   Post-est OLS"
	}
	else if "`e(method)'"=="ridge" {
		di as text _col(`varwidthm7') "Selected {c |}           Ridge   Post-est OLS"
	}
	else if "`e(method)'"=="elastic net" {
		di as text _col(`varwidthm7') "Selected {c |}     Elastic net   Post-est OLS"
		di as text _col(`varwidthm7') "         {c |}" _c
		di as text "   (alpha=" _c
		di as text %4.3f `e(alpha)' _c
		di as text ")"
	}
	else if "`e(method)'"=="lasso" {
		di as text _col(`varwidthm7') "Selected {c |}           Lasso   Post-est OLS"
	}
	else {
		di as err "internal DisplayCoefs error. unknown method."
		exit 1
	}
	di as text "{hline `varwidth1'}{c +}{hline 32}"
	local anynotpen = 0
	local i 1
	local lastcol = `col_ct' - `partial_ct'
	tokenize `vlist'								//  put elements of coef vector into macros 1, 2, ...
	while `i' <= `lastcol' {
		local vn ``i''
		fvstrip `vn'								// get rid of o/b/n prefix for display purposes
		local vn		`r(varlist)'
		_ms_display, element(`i') matrix(`beta') width(`varwidth') `baselevels'
		// in selected or notpen list?
		local isselnotpen	: list posof "`vn'" in selected0
		local isnotpen		: list posof "`vn'" in notpen
		local anynotpen		= `anynotpen' + `isnotpen'
		// note attached? base, empty, omitted
		qui _ms_display, element(`i') matrix(`beta')
		local note `r(note)'
		qui _ms_display, element(`i') matrix(`betaOLS')
		local noteOLS `r(note)'
		// if notpen, add footnote
		if `isnotpen' & "`note'"=="" {
			di as text "{helpb rlasso##notpen:*}" _c
		}
		if `isselnotpen' {
			// lasso coef
			if "`note'"=="" {
				di _col(`varwidth4') as res %15.7f el(`beta',1,`i') _c
			}
			else {
				di _col(`varwidth4') as text %15s "`note'" _c
			}
			// post-lasso coef - can be omitted if collinear
			if "`noteOLS'"=="" {
				di as res %15.7f el(`betaOLS',1,`i')
			}
			else {
				di as text %15s "`noteOLS'"
			}
		}
		else if "`note'"=="(omitted)" {
			// not selected
			di _col(`varwidth4') as text %15s "(not selected)" _c
			di                   as text %15s "(not selected)"
		}
		else {
			// other eg base var
			di as text %15s "`note'" _c
			di as text %15s "`noteOLS'"
		}
		local ++i
	}
	if `partial_ct' {
		di as text "{hline `varwidth1'}{c +}{hline 32}"
		di as text _col(`varwidthm13') "Partialled-out{help lasso2##notpen:*}{c |}"
		di as text "{hline `varwidth1'}{c +}{hline 32}"
		local i = `lastcol'+1
		while `i' <= `col_ct' {
			local vn ``i''
			fvstrip `vn'								// get rid of o/b/n prefix for display purposes
			local vn		`r(varlist)'
			_ms_display, element(`i') matrix(`beta') width(`varwidth') `baselevels'
			// note attached? base, empty, omitted
			qui _ms_display, element(`i') matrix(`beta')
			local note `r(note)'
			qui _ms_display, element(`i') matrix(`betaOLS')
			local noteOLS `r(note)'
			// lasso coef
			if "`note'"=="" {
				di _col(`varwidth4') as res %15.7f el(`beta',1,`i') _c
			}
			else {
				di _col(`varwidth4') as text %15s "`note'" _c
			}
			// post-lasso coef - can be omitted if collinear
			if "`noteOLS'"=="" {
				di as res %15.7f el(`betaOLS',1,`i')
			}
			else {
				di as text %15s "`noteOLS'"
			}
			local ++i
		}
	}
	di as text "{hline `varwidth1'}{c BT}{hline 32}"
	
	if `anynotpen' {
		di "{help rlasso##notpen:*Not penalized}"
	}
	
end

*************************** Stata utilities ******************************

// internal version of fvstrip 1.01 ms 24march2015
// takes varlist with possible FVs and strips out b/n/o notation
// returns results in r(varnames)
// optionally also omits omittable FVs
// expand calls fvexpand either on full varlist
// or (with onebyone option) on elements of varlist

program define fvstrip, rclass
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
			di as err "fvstrip error - type=product for `vn'"
			exit 198
		}
		else if "`r(type)'"=="error" {
			di as err "fvstrip error - type=error for `vn'"
			exit 198
		}
		else {
			di as err "fvstrip error - unknown type for `vn'"
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

// Internal version of matchnames
// Sample syntax:
// matchnames "`varlist'" "`list1'" "`list2'"
// takes list in `varlist', looks up in `list1', returns entries in `list2', called r(names)
program define matchnames, rclass
	version 11.2
	args	varnames namelist1 namelist2

	local k1 : word count `namelist1'
	local k2 : word count `namelist2'

	if `k1' ~= `k2' {
		di as err "namelist error"
		exit 198
	}
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

// Display varlist with specified indentation
program define Disp 
	version 11.2
	syntax [anything] [, _col(integer 15) ]
	local maxlen = 80-`_col'
	local len = 0
	local first = 1
	foreach vn in `anything' {
* Don't display if base or omitted variable
		_ms_parse_parts `vn'
		if ~`r(omit)' {
			local vnlen		: length local vn
			if `len'+`vnlen' > `maxlen' {
				di
				local first = 1
				local len = `vnlen'
			}
			else {
				local len = `len'+`vnlen'+1
			}
			if `first' {
				local first = 0
				di in gr _col(`_col') "`vn'" _c
				}
			else {
				di in gr " `vn'" _c
			}
		}
	}
* Finish with a newline
	di
end

version 13
mata:

void s_maketemps(real scalar p)
{
	(void) st_addvar("double", names=st_tempname(p), 1)
	st_global("r(varlist)",invtokens(names))
}


// END MATA SECTION
end
