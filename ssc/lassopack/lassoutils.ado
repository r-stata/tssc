*! lassoutils 1.1.04 14oct2019
*! lassopack package 1.3.1
*! authors aa/cbh/ms

* Adapted/expanded from lassoShooting version 12, cbh 25/09/2012
* mm_quantile from moremata package by Ben Jann:
*   version 1.0.8  20dec2007  Ben Jann

* Notes:
* Partialling out, temp vars, factor vars, FE transform all handled
* by calling programs.
* names_o and names_t (via options) are original and (possibly) temp names of Xs
* lassoutils branches to internal _rlasso, _lassopath, _fe, _unpartial, _partial, _std
* current cluster code is memory-intensive since it works with a full n x p matrix instead of cluster-by-cluster

* Updates (release date):
* 1.0.05  (30jan2018)
*         First public release.
*         Added seed(.) option to rlasso to control rnd # seed for xdep & sup-score.
*         Fixed up return code for lassoutils (method, alpha).
*         Promoted to required version 13 or higher.
*         Introduced centerpartial(.) Mata program for use with rlasso; returns X centered and with Xnp partialled-out.
*         Separate fields in datastruct: sdvec, sdvecpnp, sdvecp, sdvecnp. Latter two conformable with Xp and Xnp.
*         Added dots option for simulations (supscore, xdep).
*         Recoding relating to different treatment of cross-validation.
*         Changes to _std, _fe, _partial relating to holdout vs full sample.
*         Recoding of cons flag; now also dmflag to indcate zero-mean data.
* 1.0.06  (10feb2018)
*         Misc Mata speed tweaks following advice at http://scorreia.com/blog/2016/10/06/mata-tips.html,
*         e.g., evaluating for limits before loop; referring to vector elements with a single subscript.
*         Rewrite of FE transform to use Sergio Correia's FTOOLS package (if installed).
* 1.0.07  (17feb2018)
*         Bug fix related to ftools - leaves matastrict set to on after compilation, causing rest of lassoutils
*         to fail to load. Fix is to reset matastrict to what it was before calling ftools,compile.
* 1.0.08  (5apr2018)
*	      Changed the default maximum lambda for the elastic net: it was 2*max(abs(X'y)),
*		  and is now 2*max(abs(X'y))/max(0.001,alpha); see Friedman et al (2010, J of Stats Software). 
*		  Added Mata programs getInfoCriteria() and getMinIC(). getInfoCriteria() calculates information criteria
*		  along with RSS and R-squared. getMinIC() obtains minimum IC values and corresponding lambdas.
*		  Degrees of freedom calculation was added to DoLassoPath() and DoSqrtLassoPath().
* 		  Misc changes to the initial beta (= Ridge estimate), which in some cases didn't account for 
*		  penalty loadings.
* 		  Added lglmnet option to facilitate comparison with glmnet (was dysfunctional 'ladjust' option).
*         Restructured calc of lambda with cluster to match JBES paper; prev used sqrt(nclust) rather than sqrt(N),
*         now always 2c*sqrt(N)*invnormal(1-(gamma/log(N))/(2*p))). Fixed bug in calc of lambda for sqrt-lasso with cluster.
*         Definition of xdep lambda + cluster also changed slightly (by factor of sqrt(nclust/(nclust-1)).
*         Undocumented nclust1 option mimics behavior of CBH lassoCluster.ado; uses (nclust-1)*T rather than nclust*T.
* 1.0.14  (04sep2018)
*         Bug with initial (ridge) beta if XX+lambda2/2*diag(Ups2) singular, caused by using lusolve.
*         Fixed with subroutine luqrsolve(.). Uses lusolve by default; if singular, then uses qrsolve.
*         Dropped unpenalized variables now has more informative error message.
*         Modified code to accommodate cluster variables that are strings.
*         Added weighting subroutine (data assumed to be preweighted).
*         Consistent use of d.dmflag and d.cons:
*           dmflag=1 => treat data as zero mean
*           cons=1 => constant in model to be recovered by estimation code; also used in variable counts
*           dmflag=1 => cons=0 but cons=0 /=> dmflag=1 because model may not have a constant
*		  Fixed wrong formula for R-squared in getInfoCriteria(). RSQ =1:-RSS:/TSS (was ESS:/TSS).
*         Fixed initial resids routine for rlasso for model with no constant.
*         Fixed bug in sup score test + prestd. Fixed bug that didn't allow sup score test + pnotpen(.).
*         Added separate storage of prestandardization SDs on data struct as prestdx and prestdy.
*		  Added "ebicgamma" option. Default choice is now ebicgamma=1-1/(2*kappa) and p=n^kappa.
*			See Chen & Chen (2008, Sec. 5, p. 768).
* 1.1.01  (08nov2018)
*         Rewrite of supscore code. Now reports sqrt(n)*[] rather than n*[] version as per CCK.
*           Bug fix in cluster version (was using nclust*[] rather than n*[]).
*           Now handles weighted/demeaned data, center option correctly.
*         Rewrite of lambdacalc code. Shares subroutines with supscore code.
*         Rewrite of xdep and lasso/sqrt-lasso weights code. Shares subroutines with supscore code.
*           sqrt-lasso xdep simulation now normalizes by empirical SD of simulated N(0,1).
*           Bug fix in xdep gamma; distribution was based on max(Xe) instead of max(abs(Xe));
*           effect was appx equivalent to using a gamma 1/2 times the value specified; now fixed.
*         Rewrite of cluster weights code to use panelsum(.) and avoid large temp matrices.
*         Added saved value of minimized objective function (standardized).
*         Initial weights for sqrt-lasso + inid data as per BCW 2014 p. 769 = colmax(abs(X))
*           now available as undocumented maxabsx option.  For cluster, use colmax(panelmean(abs(X)).
*           maxabsx => default maxupsiter=3 in line with BCW 2014 recommendation to iterate.
*         Bug fix in reporting of sqrt-lasso with vverbose (wasn't reporting correct value of obj fn).
*         Bug fix in sqrt-lasso with nocons (was demeaning despite no constant present).
*         Bug fix in rlasso verbose reporting - wasn't reporting selected variables.
*         Removed factor of 0.5 from initial penalty (loadings) for lasso + post-lasso OLS resids.
*         Added undocumented c0(.) option to replicate previous factor of 0.5 for initial penalty loadings.
*         Added undocumented sigma(.) option for std lasso to override estimation of initial sigma.
*         Added undocumented ssiid option for supscore test to override use of mult bootstrap in iid case.
* 1.1.02  (2jan2018)
*         Saved value of minimized objective function is now in y units (not standardized).
* 		  Adaptive lasso: added check for zeros in e(b). Use univariate OLS instead.
* 1.1.03 (13jan2019)
*         Updated options and terminology from Ups to Psi (penalty loadings).
*         gamma option now controls overall level, = 0.1/log(N) or 0.1/log(N_clust) by default
*         gammad option now undocumented
* 1.1.04 (14oct2019)
*         Bug fix - lambda0(.) option was being ignored for standard lasso.
*         Algorithm update for rlasso - now maxupsiter=1 will exit with the initial penalty loadings,
*         initial lambda, and lasso estimates based on this.
*         NB: Also specifying lambda0(.) will control the initial lambda.


program lassoutils, rclass sortpreserve
	version 13
	syntax [anything] ,							/// anything is actually a varlist but this is more flexible - see below
		[										/// 
		rlasso									/// branches to _rlasso
		path									/// branches to _lassopath
		unpartial								/// branches to _unpartial
		fe(string)								/// branches to _fe
		std										/// branches to _std
		wvar(string)							/// branches to _wt
		partialflag(int 0)						/// branches to _partial if =1
		partial(string)							/// used by _partial and _unpartial
		tvarlist(string)						/// used by _partial, _fe, _std; optional list of temp vars to fill
		tpvarlist(string)						/// used by _partial; optional list of temp partial vars to file
												///
		ALPha(real 1) 							/// elastic net parameter
		SQRT									/// square-root-lasso
		ols 									///
		adaptive								///
												///
												/// verbose options will be transformed to 0/1/2 before passing to subs
		VERbose									/// shows additional detail
		VVERbose								/// even more detail
		*										///
		]

	*** `anything' is actually a varlist but this is more flexible.
	// avoids problems with uninitialized vars, unwanted parsing of factor vars, etc.
	// ... so immediately rename.
	local varlist `anything'
	*

	** verbose
	if ("`vverbose'"!="") {
		local verbose=2							//  much detail
	} 
	else if ("`verbose'"!="") {
		local verbose=1							//  some additional detail
	}
	else {
		local verbose=0							//  no additional output
	}
	*

	************* SUBROUTINES: shoot, path, CV **************************************

	if "`rlasso'" ~= "" {
		_rlasso `varlist',							 	/// branch to _rlasso
			verbose(`verbose')							///
			`sqrt'										///
			`options'									//  no penloads etc.
	}
	else if "`path'" != "" {
		_lassopath `varlist',							///  branch to _ lassopath
			verbose(`verbose')							///
			`sqrt'										///
			alpha(`alpha')								///
 			`adaptive'									///
			`ols'										///
			`options'
	}
	else if "`unpartial'" ~= "" {
		_unpartial `varlist',							/// branch to _unpartial
			partial(`partial')							///
			wvar(`wvar')								///
			`options'
	}
	else if `partialflag' {
		_partial `varlist',							 	/// branch to _partial
			partial(`partial')							///
			tvarlist(`tvarlist')						///
			wvar(`wvar')								///
			`options'
	}
	else if "`fe'" ~= "" {
		_fe `varlist',								 	/// branch to _fe
			tvarlist(`tvarlist')						///
			fe(`fe')									///
			wvar(`wvar')								///
			`options'
	}
	else if "`std'" ~= "" {
		_std `varlist',								 	/// branch to _std
			tvarlist(`tvarlist')						///
			`options'
	}
	else if "`wvar'" ~= "" {
		_wt `varlist',								 	/// branch to _wt
			tvarlist(`tvarlist')						///
			wvar(`wvar')								///
			`options'
	}
	else {
		di as err "internal lassoutils error"
		exit 499
	}

	*** return
	// so subroutine r(.) detail passed on
	// can add additional items to r(.) here
	return add

	// if estimation, return method etc.
	if "`rlasso'`path'`cv'" ~= "" {
		return scalar alpha			= `alpha'
		return scalar sqrt			= ("`sqrt'"!="")
		
		if ("`sqrt'" ~= "") {
			return local method		"sqrt-lasso"
		}
		else if `alpha'==1 {
			return local method		"lasso"
		}
		else if `alpha'==0 {
			return local method		"ridge"
		}
		else if (`alpha'<1) & (`alpha'>0)  {
			return local method		"elastic net"
		}
		else {
			di as err "internal lassoutils error - alpha outside allowed range"
			exit 499
		}
	}

end

// Subroutine for BCH _rlasso
program define _rlasso, rclass sortpreserve
	version 13
	syntax anything ,							/// anything is actually a varlist but this is more flexible - see below
		touse(varlist numeric max=1)			/// required `touse' variable (so marksample unneeded)
		[										///
		verbose(int 0)							///
												///
		ROBust									/// penalty level/loadings allow for heterosk. [homoskedasticity is the default]
		CLuster(varlist max=1)					/// penalty level/loadings allow for within-panel dependence & heterosk.
		XDEPendent								/// penalty level is estimated depending on X (default: No)
		numsim(integer 5000)					/// number of simulations with xdep (default=5,000)
												/// 
		TOLOpt(real 1e-10)						/// was originally 1e-5 but 1e-10 gives good equiv between xstd and stdloadings
		TOLPsi(real 1e-4)						///
		TOLZero(real 1e-4)						///
		MAXIter(integer 10000)					/// max number of iterations in estimating lasso
		MAXPSIIter(int 2)						/// max number of lasso-based iterations in est penalty loadings; default=2
		CORRNumber(int 5) 						/// number of regressors used in InitialResiduals(); default=5
		maxabsx									/// initial loadings for sqrt-lasso as per BCW 2014 p. 769 = colmax(abs(X))
												///
		LASSOPSI								/// use lasso residuals to estimate penalty loadings (post-lasso is default)
												///
		c(real 1.1)								/// "c" in lambda function; default = 1.1
		c0(real 0)								/// when iterating, initial value of c in lambda function; default set below
		gamma(real 0)							/// "gamma" in lambda function (default 0.1/log(N) or 0.1/log(N_clust))
		gammad(real 0)							/// undocumented "gamma" denominator option (default log(N) or log(N_clust)
		lambda0(real 0)							/// optional user-supplied lambda0
		LALTernative 							/// use alternative, less sharp lambda0 formula
		PMINus(int 0)							/// dim(X) adjustment in lambda0 formula
		nclust0									/// no longer in use as of 1.0.08; replaced by nclust1
		nclust1									/// use (nclust-1)*T instead of nclust*T in cluster-lasso
		center									/// center x_i*e_i or x_ij*e_ij in cluster-lasso
		sigma(real 0)							/// user-specified sigma for rlasso
												///
		supscore								///
		ssgamma(real 0.05)						/// default gamma for sup-score test
		ssnumsim(integer 500)					///
		testonly								///
		ssiid									/// undocumented option - override use of mult bootstrap in iid case
												///
		seed(real -1)							/// set random # seed; relevant for xdep and supscore
		dots									/// display dots for xdep and supscore repetitions
												///
		xnames_o(string)						/// original names in varXmodel if tempvars used (string so varlist isn't processed)
		xnames_t(string)						/// temp names in varXmodel
		notpen_o(string)						/// used in checking
		notpen_t(string)						///
		consflag(int 0)							/// =0 if no cons or already partialled out
		dmflag(int 0)							/// data have been demeaned or should be treated as demeaned
												///
		stdy(string)							///
		stdx(string)							///
												///
		SQRT									/// square-root lasso
												///
												/// LEGACY OPTIONS
		TOLUps(real 1e-4)						///
		MAXUPSIter(int 2)						/// max number of lasso-based iterations in est penalty loadings; default=2
		LASSOUPS								/// use lasso residuals to estimate penalty loadings (post-lasso is default)
		]

	*** `anything' is actually a varlist but this is more flexible.
	// avoids problems with uninitialized vars, unwanted parsing of factor vars, etc.
	// ... so immediately rename.
	local varlist `anything'
	*

	*** count number of obs
	_nobs `touse'
	local nobs = r(N)
	*

	*** cluster
	// create numeric clustvar in case cluster variable is string
	// sort needed if cluster option provided; sortpreserve means sort restored afterwards
	if "`cluster'"~="" {
		tempvar clustvar
		qui egen `clustvar' = group(`cluster') if `touse'
		sort `clustvar'
	}
	*

	*** define various parameters/locals/varlists
	local varY			`varlist'							// now is only element in varlist
	local varXmodel		`xnames_t'							// including notpen if any; may include tempnames
	local pen_t			: list xnames_t - notpen_t			// list of penalized regressors
	local p0			: word count `varXmodel' 			// #regressors incl notpen but excl constant
	local p				= `p0' - `pminus'					// p defined by BCH
	local p0			= `p0' + `consflag'					// #regressors but now incl constant
	*
	
	*** define various flags
	local clustflag		=("`cluster'"!="")					// =1 if cluster
	local hetero		=("`robust'"!="") & ~`clustflag'	// =1 if het-robust but NOT cluster
	local sqrtflag		=("`sqrt'"!="")
	local xdep			=("`xdependent'"!="")
	local lassopsiflag	=("`lassopsi'`lassoups'"!="")		// lassoups is the equivalent legacy option
	local lalternative	=("`lalternative'"!="")				// =1 if alternative, less sharp lambda0 should be used
	local nclust1		=("`nclust1'"!="")
	local center		=("`center'"!="")
	local supscoreflag	=("`supscore'`testonly'"!="")
	local testonlyflag	=("`testonly'"!="")
	local dotsflag		=("`dots'"!="")
	local prestdflag	=("`stdy'"!="")
	local ssiidflag		=("`ssiid'"!="")
	local maxabsxflag	=("`maxabsx'"!="")
	*
	
	*** defaults
	if `maxabsxflag' {
		// implement BCW 2014 p. 769 recommendation for sqrt lasso initial weights = colmax(abs(X))
		local corrnumber -1
		local maxpsiiter 3		// since BCW say to iterate
	}
	if `c0'==0 {
		// allow initial value of c in iterated penalties to vary; matches treatment in CBH and hdm code
		local c0 `c'
	}
	*

	*** legacy options
	if `tolups' ~= 1e-4 {
		local tolpsi `tolups'
	}
	if `maxupsiter' ~= 2 {
		local maxpsiiter `maxupsiter'
	}
	*

	tempname lambda slambda rmse rmseOLS objfn		//  note lambda0 already defined as a macro
	tempname b bOLS sb sbOLS Psi sPsi ePsi stdvec
	tempname bAll bAllOLS
	tempname supscoremat CCK_ss CCK_p CCK_cv CCK_gamma
	// initialize so that returns don't crash in case values not set
	local k				=0						//  used as flag to indicate betas are non-missing
	local N				=.
	local N_clust		=.
	local s				=.
	local s0			=.
	local niter			=.
	local npsiiter		=.
	scalar `lambda'		=.
	scalar `slambda'	=.
	scalar `rmse'		=.
	scalar `rmseOLS'	=.
	scalar `objfn'		=.
	mat `b'				=.
	mat `bAll'			=.
	mat `bOLS'			=.
	mat `bAllOLS'		=.
	mat `sb'			=.
	mat `sbOLS'			=.
	mat `Psi'			=.
	mat `sPsi'			=.
	mat `ePsi'			=.
	mat `stdvec'		=.
	mat `supscoremat'	=.
	scalar `CCK_ss'		=.
	scalar `CCK_p'		=.
	scalar `CCK_cv'		=.
	scalar `CCK_gamma'	=.

	if `p' & ~`testonlyflag' {					//  there are penalized model variables; estimate
	
		*** BCH rlasso
		mata:	EstimateRLasso(					///
							"`varY'",			///
							"`varXmodel'",		///
							"`xnames_o'",		///
							"`pen_t'",			///
							"`notpen_t'",		///
							"`touse'",			///
							"`clustvar'",		///
							"`stdy'",			///
							"`stdx'",			///
							`sqrtflag',			///
							`hetero',			///
							`xdep',				///
							`numsim',			///
							`lassopsiflag',		///
							`tolopt',			///
							`maxiter',			///
							`tolzero',			///
							`maxpsiiter',		///
							`tolpsi',			///
							`verbose',			///
							`c',				///
							`c0',				///
							`gamma',			///
							`gammad',			///
							`lambda0',			///
							`lalternative',		///
							`corrnumber',		///
							`pminus',			///
							`nclust1',			///
							`center',			///
							`sigma',			///
							`supscoreflag',		///
							`ssnumsim',			///
							`ssgamma',			///
							`seed',				///
							`dotsflag',			///
							`consflag',			///
							`dmflag',			///
							`prestdflag')

		*** Via ReturnResults(.)
		// coefs are returned as column vectors
		// convert to row vectors (Stata standard)
		mat `b'				=r(b)'					//  in original units
		mat `bOLS'			=r(bOLS)'
		mat `sb'			=r(sb)'					//  in standardized units
		mat `sbOLS'			=r(sbOLS)'
		mat `bAll'			=r(bAll)'
		mat `bAllOLS'		=r(bAllOLS)'
		mat `Psi'			=r(Psi)
		mat `sPsi'			=r(sPsi)
		mat `ePsi'			=r(ePsi)
		mat `stdvec'		=r(stdvecp)				//  stdvec for penalized vars only
		local selected0		`r(sel)'				//  selected variables INCL NOTPEN, EXCL CONSTANT
		local s0			=r(s)					//	number of selected vars INCL NOTPEN, EXCL CONSTANT; may be =0
		local k				=r(k)					//  number of all vars in estimated parameter vector INC CONSTANT; may be =0
		local niter			=r(niter)
		local npsiiter		=r(npsiiter)
		local N				=r(N)
		local N_clust		=r(N_clust)
		scalar `lambda'		=r(lambda)				//  relates to depvar in original units
		scalar `slambda'	=r(slambda)				//  relates to standardized depvar
		scalar `rmse'		=r(rmse)				//  lasso rmse
		scalar `rmseOLS'	=r(rmsePL)				//  post-lasso rmse
		scalar `objfn'		=r(objfn)				//  minimized objective function
		if `supscoreflag' {
			mat `supscoremat'	=r(supscore)			//  sup-score row vector of results
			scalar `CCK_ss'		=`supscoremat'[1,colnumb(`supscoremat',"CCK_ss")]
			scalar `CCK_p'		=`supscoremat'[1,colnumb(`supscoremat',"CCK_p")]
			scalar `CCK_cv'		=`supscoremat'[1,colnumb(`supscoremat',"CCK_cv")]
			scalar `CCK_gamma'	=`supscoremat'[1,colnumb(`supscoremat',"CCK_gamma")]
		}
		// these may overwrite existing locals
		tempname lambda0 c gamma gammad
		scalar `lambda0'	=r(lambda0)				//  BCH definition of lambda; overwrites existing/default macro
		scalar `c'			=r(c)
		scalar `gamma'		=r(gamma)
		scalar `gammad'		=r(gammad)
		*
	}
	else if ~`testonlyflag' {						//  there are no penalized model vars; just do OLS

		if `p0' {									//  there are unpenalized vars and/or constant
			di as text "warning: no penalized variables; estimates are OLS"
		}
		if ~`consflag' {
			local noconstant noconstant
		}
		else {
			local consname _cons
		}
		qui regress `varY' `varXmodel' if `touse', `noconstant' cluster(`clustvar')

		mat `b'					=e(b)
		local k					=colsof(`b')
		foreach m in `b' `bOLS' `bAll' `bAllOLS' {
			mat `m'				=e(b)
			mat colnames `m'	=`xnames_o' `consname'
		}
		scalar `rmse'			=e(rmse)
		scalar `rmseOLS'		=e(rmse)
		local selected0			`xnames_o'
		local N					=e(N)
		if `clustflag' {
			local N_clust		=e(N_clust)
		}
		else {
			local N_clust		=0
		}
	}
	else if `testonlyflag' {					//  supscore test only

		mata:	EstimateSupScore(				///
							"`varY'",			///
							"`varXmodel'",		///
							"`xnames_o'",		///
							"`pen_t'",			///
							"`notpen_t'",		///
							"`touse'",			///
							"`clustvar'",		///
							"`stdy'",			///
							"`stdx'",			///
							`hetero',			///
							`nclust1',			///
							`center',			///
							`verbose',			///
							`ssnumsim',			///
							`ssiidflag',		///
							`c',				///
							`ssgamma',			///
							`pminus',			///
							`seed',				///
							`dotsflag',			///
							`consflag',			///
							`dmflag',			///
							`prestdflag')

		mat  `supscoremat'	=r(supscore)
		scalar `CCK_ss'		=`supscoremat'[1,colnumb(`supscoremat',"CCK_ss")]
		scalar `CCK_p'		=`supscoremat'[1,colnumb(`supscoremat',"CCK_p")]
		scalar `CCK_cv'		=`supscoremat'[1,colnumb(`supscoremat',"CCK_cv")]
		scalar `CCK_gamma'	=`supscoremat'[1,colnumb(`supscoremat',"CCK_gamma")]
		local N				=r(N)
		local N_clust		=r(N_clust)

	}
	else {										//  shouldn't reach here
		di as err "internal _rlasso error"
		exit 499
	}

	*** check notpen is in selected0
	if ~`testonlyflag' {
		fvstrip `selected0'							//  fvstrip removes b/n/o prefixes (shouldn't need dropomit)
		local list1			`r(varlist)'
		fvstrip `notpen_o', dropomit				//  use dropomit option here
		local list2			`r(varlist)'
		local missing		: list list2 - list1
		local missing_ct	: word count `missing'
		if `missing_ct' {
			di as err "internal _rlasso error - unpenalized `missing' missing from selected vars"
			di as err "may be caused by collinearities in unpenalized variables or by tolerances"
			di as err "set tolzero(.) or other tolerances smaller or use partial(.) option"
			exit 499
		}
	}
	*

	*** conventions
	// k			= number of selected/notpen INCLUDING constant; k>0 means estimated coef vector is non-empty
	// s0			= number of selected/notpen EXCLUDING constant
	// s			= number of selected (penalized)
	// p0			= number of all variables in model INCLUDING constant
	// selected0	= varlist of selected and unpenalized EXCLUDING constant; has s0 elements
	// selected		= varlist of selected; has s elements
	// cons			= 1 if constant, 0 if no constant
	// notpen_ct	= number of unpenalized variables in the model EXCLUDING CONSTANT
	// coef vectors b, bOLS, sb, sbOLS have k elements
	// coef vectors bAll, bAllOLS have p0 elements
	// Psi, sPsi have p0-cons elements
	// stdvec has p0 - notpen_ct - cons elements (=#penalized)
	// Note that full set of regressors can including omitteds, factor base categories, etc.
	*

	*** fix colnames of beta vectors to include omitted "o." notation
	// includes post-lasso vector in case of collinearity => a selected variable was omitted
	// trick is to use _ms_findomitted utility but give it
	// diag(bAll) as vcv matrix where it looks for zeros
	// also build in fv info
	tempname tempvmat
	if `k' & ~`testonlyflag' {							//  if any vars in est coef vector (k can be zero)
		mat `tempvmat'	= diag(`bOLS')
		_ms_findomitted	`bOLS' `tempvmat'
		_ms_build_info	`bOLS' if `touse'
	}
	if `p0' & ~`testonlyflag' {							//  if any variables in model (p0 can be zero)
		mat `tempvmat'	= diag(`bAll')
		_ms_findomitted	`bAll' `tempvmat'
		_ms_build_info	`bAll' if `touse'
		mat `tempvmat'	= diag(`bAllOLS')
		_ms_findomitted	`bAllOLS' `tempvmat'
		_ms_build_info	`bAllOLS' if `touse'
	}
	*

	*** manipulate variable counts and lists
	// selected0 and s0 are selected+notpen (excluding constant)
	// selected and s are selected only
	local notpen_ct		: word count `notpen_o'			//  number of notpen EXCL CONSTANT
	local selected		: list selected0 - notpen_o		//  selected now has only selected/penalized variables
	local s				: word count `selected'			//  number of selected/penalized vars EXCL NOTPEN/CONSTANT
	*
	*** error checks
	// check col vector of b (selected) vs. k
	local col_ct		=colsof(`b')
	if `col_ct'==1 & el(`b',1,1)==. & ~`testonlyflag' {
		// coef vector is empty so k should be zero
		if `k'~=0 {
			di as err "internal _rlasso error - r(k)=`k' does not match number of selected vars/coefs=`col_ct'"
			exit 499
		}
	}
	else if `k'~=`col_ct' & ~`testonlyflag' {
		// coef vector not empty so k should match col count
		di as err "internal _rlasso error - r(k)=`k' does not match number of selected vars/coefs=`col_ct'"
		exit 499
	}
	// check col vector of bAll vs. p0
	local col_ct		=colsof(`bAll')
	if `p0'~=`col_ct' & ~`testonlyflag' {
		// full coef vector not empty so p0 should match col count
		di as err "internal _rlasso error - p0=`p0' does not match number of model vars/coefs=`col_ct'"
		exit 499
	}
	*

	*** return results
	// coef vectors are row vectors (Stata standard)
	return matrix beta		=`b'
	return matrix betaOLS	=`bOLS'
	return matrix sbeta		=`sb'
	return matrix sbetaOLS	=`sbOLS'
	return matrix betaAll	=`bAll'
	return matrix betaAllOLS=`bAllOLS'
	return matrix Psi		=`Psi'
	return matrix sPsi		=`sPsi'
	return matrix ePsi		=`ePsi'
	return matrix stdvec	=`stdvec'					//  penalized vars only
	return scalar lambda	=`lambda'					//  relates to depvar in original units
	return scalar slambda	=`slambda'					//  relates to standardized depvar
	return scalar lambda0	=`lambda0'					//  BCH definition of lambda
	return scalar rmse		=`rmse'						//  lasso rmse
	return scalar objfn		=`objfn'
	return scalar c			=`c'
	return scalar gamma		=`gamma'
	return scalar gammad	=`gammad'
	return scalar rmseOLS	=`rmseOLS'					//  post-lasso rmse
	return local  selected0	`selected0'					//  all selected/notpen vars INCLUDING NOTPEN (but excl constant)
	return local  selected	`selected' 					//  all selected (penalized) vars EXCLUDING NOTPEN & CONS
	return scalar k			=`k'						//  number of all vars in sel/notpen parameter vector INCLUDING CONSTANT
	return scalar s0		=`s0'						//  number of vars selected INCLUDING NOTPEN (but excl constant)
	return scalar s			=`s'						//  number of vars selected EXCLUDING NOTPEN & CONS
	return scalar p0		=`p0'						//  number of all vars in original model including constant
	return scalar p			=`p'						//  p defined by BCH; excludes notpen & cons
	return scalar N_clust	=`N_clust'
	return scalar N			=`N'
	return scalar center	=`center'

	return local  clustvar	`cluster'
	return local  robust	`robust'
	return scalar niter		=`niter'
	return scalar maxiter	=`maxiter'
	return scalar npsiiter	=`npsiiter'
	return scalar maxpsiiter=`maxpsiiter'
	
	return scalar ssnumsim		=`ssnumsim'
	return scalar supscore		=`CCK_ss'
	return scalar supscore_p	=`CCK_p'
	return scalar supscore_cv	=`CCK_cv'
	return scalar supscore_gamma=`CCK_gamma'
	*

end		// end _rlasso subroutine

// Subroutine for lassopath
program define _lassopath, rclass sortpreserve
	version 13
	syntax [anything] ,							/// anything is actually a varlist but this is more flexible - see below
		toest(varlist numeric max=1)			/// required `touse' variable (so marksample unneeded)
		[										/// 
		verbose(int 0)							///
		consflag(int 1)							/// default is constant specified
		dmflag(int 0)							/// data have been demeaned or should be treated as demeaned
		notpen_t(string) 						///
		notpen_o(string) 						///
												///
												/// lambda settings
		ALPha(real 1) 							/// elastic net parameter
		Lambda(string)							/// overwrite default lambda
		LCount(integer 100)						///
		LMAX(real 0) 							///
		LMINRatio(real 1e-4)					/// ratio of maximum to minimum lambda
												///
		TOLOpt(real 1e-10)						/// was originally 1e-5 but 1e-10 gives good equiv between xstd and stdloadings
		TOLZero(real 1e-4)						///
		MAXIter(integer 10000)					/// max number of iterations in estimating lasso
												///
		PLoadings(string)						/// set penalty loadings as Stata row vector
												///
		LGLMnet									/// lambda is divided by 2*n (to make results comparable with glmnet)
												///
		xnames_o(string)						/// original names in varXmodel if tempvars used (string so varlist isn't processed)
		xnames_t(string)						/// temp names in varXmodel
												///
		sqrt 									/// square-root lasso
		ols										///
												///
  		STDLflag(int 0) 						/// use standardisation loadings?
		STDCOEF(int 0) 							/// don't unstandardize coefs
		stdy(string)							///
		stdx(string)							///
												///
		ADAPTive  								/// adaptive lasso
		ADATheta(real 1) 						/// gamma paramater for adapLASSO
		ADALoadings(string)						///
		holdout(varlist) 						///
												///
		NOIC									///
		EBICGamma(real -99)						/// -99 leads to the default option
		]
		
	*** `anything' is actually a varlist but this is more flexible.
	// avoids problems with uninitialized vars, unwanted parsing of factor vars, etc.
	// ... so immediately rename to `varlist' (usual Stata convention).
	local varlist `anything'

	*** count number of obs
	_nobs `toest'
	local nobs = r(N)
	*

	*** define various parameters/locals/varlists
	local varY			`varlist'						// now is only element in varlist
	local varXmodel		`xnames_t'						// including notpen if any; may include tempnames
	local pen_t			: list xnames_t - notpen_t		// list of penalized regressors
	local pmodel		: word count `varXmodel' 		//  # regressors (excl. constant) minus partial
	local p0			: word count `varXmodel' 		// # all regressors incl notpen but excl constant
	local p0			= `p0' + `consflag'				// ditto but now incl constant
	*

	*** syntax checks
	if (`lminratio'<0) | (`lminratio'>=1) {
		di as err "lminratio should be greater than 0 and smaller than 1."
	}	
	if ("`lambda'"!="") & ((`lcount'!=100) | (`lmax'>0) | (`lminratio'!=1e-4)) {
		di as err "lcount | lmax | lminratio option ignored since lambda() is specified."
	}
	if (`ebicgamma'!=-99) & (`ebicgamma'<0) & (`ebicgamma'>1) {
		di as err "ebicgamma must be in the interval [0,1]. Default option is used."
	}
	*
	
	*** useful flags and counts
	local prestdflag	=("`stdy'"!="")
	local sqrtflag		=("`sqrt'"!="")
	local olsflag		=("`ols'"!="")
	local adaflag 		=("`adaptive'"!="")
	local lglmnetflag	=("`lglmnet'"!="")
	local noicflag		=("`noic'"!="")
	if (~`consflag') {
		local noconstant noconstant
	}
	*
	
	*********************************************************************************
	*** penalty loadings and adaptive lasso 									  ***
	*********************************************************************************
	
	*** syntax checks for penalty loadings
	if (`adaflag') & ("`ploadings'"!="") {
		di as error "ploadings() option not allowed with adaptive."
		exit 198
	}
	if (~`adaflag') & ("`adaloadings'"!="") {
		di as error "adaloadings(`adaloadings') ignored. specify adaptive option."
	}
	if (~`adaflag') & (`adatheta'!=1) {
		di as err "adatheta(`adatheta') ignored. specify adaptive option."
	}
	local pltest = ("`ploadings'"!="")+`adaflag'+`stdlflag'
	if (`pltest'>1) {
		di as error "only one of the following options allowed: ploadings, adaptive, stdloadings."
		exit 198
	}
	** check dimension of penalty loading vector
	if ("`ploadings'"!="") {
		// Check that ploadings is indeed a matrix
		tempname Psi
		cap mat `Psi' = `ploadings'
		if _rc != 0 {
			di as err "invalid matrix `ploadings' in ploadings option"
			exit _rc
		}
		// check dimension of col vector
		if (colsof(`Psi')!=(`pmodel')) | (rowsof(`Psi')!=1) {
			di as err "`ploadings' should be a row vector of length `pmodel'=dim(X) (excl constant)."
			exit 503
		}
	}
	else if (`adaflag') {
		if ("`adaloadings'"=="") {
			// obtain ols coefficients
			sum `toest', meanonly
			local nobs = r(N)
			tempname adaptivePsi
			if (`pmodel'<`nobs') { // is dim(X)>n ? if not, do full OLS
				di as text "Adaptive weights calculated using OLS."
				_regress `varY' `varXmodel' if `toest', `noconstant'
				mat `adaptivePsi' = e(b)
				mat list `adaptivePsi' 
				if (`consflag') {
					mat `adaptivePsi' = `adaptivePsi'[1,1..`pmodel']
				}
				*** check if there are any zeros in e(b)
				local zerosinada = 0
				forvalue i = 1(1)`pmodel' {
					local zerosinada = `zerosinada' + (abs(el(`adaptivePsi',1,`i'))<10e-10)
				}
			}
			if (`pmodel'>=`nobs') | (`zerosinada'>0) { // is dim(X)> n ? if yes, do univariate OLS
					di as text "Adaptive weights calculated using univariate OLS regressions." // since dim(X)>#Observation."
					mat `adaptivePsi' = J(1,`pmodel',0)
					local ip=1
					foreach var of varlist `varXmodel' {
						qui _regress `varY' `var' if `toest', `noconstant'
						mat `adaptivePsi'[1,`ip'] = _b[`var']
						local ip=`ip'+1
				}
				mat list `adaptivePsi'
			}
		} 
		else {
			tempname adaptivePsi0 adaptivePsi
			cap mat `adaptivePsi0' = `adaloadings'
			if _rc != 0 {
				di as err "invalid matrix `adaloadings' in adaloadings option"
				exit _rc
			}
			local ebnames: colnames `adaptivePsi0'
			local ebnamescheck: list varXmodel - ebnames
			if ("`ebnamescheck'"!="") {
				di as err "`ebnamescheck' do not appear in matrix `adaloadings' as colnames."
				exit 198
			}
			mat `adaptivePsi' = J(1,`pmodel',.)
			matrix colnames `adaptivePsi0' = varXmodel
			local j = 1
			foreach var of local varXmodel {
				local vi : list posof "`var'" in ebnames
				mat `adaptivePsi'[1,`j']=`adaptivePsi0'[1,`vi']
				local j=`j'+1
			}
		}
		// do inversion
		forvalue j = 1(1)`pmodel' {
			mat `adaptivePsi'[1,`j'] = abs((1/`adaptivePsi'[1,`j'])^`adatheta')
		}
		tempname Psi
		mat `Psi' = `adaptivePsi'
		mat list `Psi'
	}
	*

	*********************************************************************************
	*** penalty loadings and adaptive lasso END									  ***
	*********************************************************************************
	
	//egen test = rowmiss(`varXmodel') if `toest'
	//sum test

	mata:	EstimateLassoPath(			///
					"`varY'",			///
					"`varXmodel'",		///
					"`xnames_o'",		///
					"`notpen_o'",		///
					"`notpen_t'",		///
					"`toest'",			///
					"`holdout'", 		/// holdout for MSPE
					`consflag',			///
					`dmflag',			///
					`prestdflag',		///
					"`lambda'",			/// lambda matrix or missing (=> construct default list)
					`lmax',				/// maximum lambda (optional; only used if lambda not specified)
					`lcount',			/// number of lambdas (optional; only used if lambda not specified)
					`lminratio',		/// lmin/lmax ratio (optional; only used if lambda not specified)
					`lglmnetflag',		/// 
					"`Psi'",			///
					"`stdy'",			/// Stata matrix with SD of dep var
					"`stdx'",			/// Stata matrix with SDs of Xs
					`stdlflag',			/// use standardisation loadings  
					`sqrtflag',			/// sqrt lasso  
					`alpha',			/// elastic net parameter  
					`olsflag',			/// post-OLS estimation
					`tolopt',			///
					`maxiter',			///
					`tolzero',			///
					`verbose',			///
					`stdcoef',			///
					`noicflag',			///
					`ebicgamma'			///
					)

	
	if (`r(lcount)'>1) { //------- #lambda > 1 -----------------------------------------------//
	
		tempname Psi betas dof lambdamat l1norm wl1norm stdvec shat
		mat `Psi' 			= r(Psi)
		mat `betas' 		= r(betas)
		mat `dof'			= r(dof)
		mat `shat'			= r(shat)
		mat `lambdamat'		= r(lambdalist)
		mat `l1norm'		= r(l1norm)
		mat `wl1norm'		= r(wl1norm)
		mat `stdvec'		= r(stdvec)
		if ("`holdout'"!="") {
			tempname mspe0
			mat `mspe0' = r(mspe)	
		}
		else {
			tempname rss ess tss rsq aic aicc bic ebic
			mat `rss' = r(rss)
			mat `ess' = r(ess)
			mat `tss' = r(tss)
			mat `rsq' = r(rsq)
			mat `aic' = r(aic)
			mat `bic' = r(bic)
			mat `aicc' = r(aicc)
			mat `ebic' = r(ebic)
			return scalar aicmin = r(aicmin)
			return scalar laicid = r(laicid)
			return scalar aiccmin = r(aiccmin)
			return scalar laiccid = r(laiccid)
			return scalar bicmin = r(bicmin)
			return scalar lbicid = r(lbicid)
			return scalar ebicmin = r(ebicmin)
			return scalar lebicid = r(lebicid)
			return scalar ebicgamma = r(ebicgamma)
		}
		
		return scalar N				= r(N)
		return scalar lcount 		= r(lcount)
		return scalar olsflag		= `olsflag'
		return scalar lmax 			= r(lmax)
		return scalar lmin 			= r(lmin)
		return matrix betas 		= `betas'
		return matrix dof 			= `dof'
		return matrix shat 			= `shat'
		return matrix lambdalist 	= `lambdamat'
		return matrix Psi			= `Psi'
		return matrix l1norm		= `l1norm'
		return matrix wl1norm		= `wl1norm'
		return matrix stdvec 		= `stdvec'
		if ("`holdout'"!="") {
			return matrix mspe 		= `mspe0'
		}
		else {
			return matrix rss 		= `rss' 
			return matrix ess 		= `ess' 
			return matrix tss		= `tss' 
			return matrix rsq 		= `rsq' 
			return matrix aic 		= `aic' 
			return matrix aicc 		= `aicc' 
			return matrix bic 		= `bic' 
			return matrix ebic 		= `ebic' 
		}
	}
	else if (`r(lcount)'==1) { 
	
		*** Via ReturnResults(.)
		*** the following code is based on _rlasso
		tempname b bOLS sb sbOLS Psi sPsi stdvec
		tempname bAll bAllOLS
		tempname lambda slambda lambda0 rmse rmseOLS objfn
		// coefs are returned as column vectors
		// convert to row vectors (Stata standard)
		mat `b'				=r(b)'					//  in original units
		mat `bOLS'			=r(bOLS)'
		//*//mat `sb'			=r(sb)'					//  in standardized units
		//*//mat `sbOLS'			=r(sbOLS)'
		mat `bAll'			=r(bAll)'
		mat `bAllOLS'		=r(bAllOLS)'
		mat `Psi'			=r(Psi)
		//*//mat `sPsi'			=r(sPsi)
		mat `stdvec'		=r(stdvec)
		local selected0		`r(sel)'				//  selected variables INCL NOTPEN, EXCL CONSTANT
		local s0			=r(s)					//	number of selected vars INCL NOTPEN, EXCL CONSTANT; may be =0
		local k				=r(k)					//  number of all vars in estimated parameter vector INC CONSTANT; may be =0
		local niter			=r(niter)
		//*//local npsiiter		=r(npsiiter)
		local N				=r(N)
		local N_clust		=r(N_clust)
		scalar `lambda'		=r(lambda)				//  relates to depvar in original units
		//*//scalar `slambda'	=r(slambda)				//  relates to standardized depvar
		//*//scalar `lambda0'	=r(lambda0)				//  BCH definition of lambda
		scalar `rmse'		=r(rmse)				//  lasso rmse
		scalar `rmseOLS'	=r(rmsePL)				//  post-lasso rmse
		scalar `objfn'		=r(objfn)				//  minimized objective function
		*

		*** check notpen is in selected0
		fvstrip `selected0'							// fvstrip removes b/n/o prefixes.
		local list1			`r(varlist)'
		fvstrip `notpen_o', dropomit				// use dropomit option here
		local list2		`r(varlist)'
		local missing		: list list2 - list1
		local missing_ct	: word count `missing'
		if `missing_ct' {
			di as err "internal _lassopath error - unpenalized `missing' missing from selected vars"
			di as err "set tolzero(.) or other tolerances smaller or use partial(.) option"
			exit 499
		}
		*
		
		*** conventions
		// k			= number of selected/notpen INCLUDING constant; k>0 means estimated coef vector is non-empty
		// s0			= number of selected/notpen EXCLUDING constant
		// s			= number of selected (penalized)
		// p0			= number of all variables in model INCLUDING constant
		// selected0	= varlist of selected and unpenalized EXCLUDING constant; has s0 elements
		// selected		= varlist of selected; has s elements
		// cons			= 1 if constant, 0 if no constant
		// notpen_ct	= number of unpenalized variables in the model EXCLUDING CONSTANT
		// coef vectors b, bOLS, sb, sbOLS have k elements
		// coef vectors bAll, bAllOLS have p0 elements
		// Psi, sPsi have p0-cons elements
		// stdvec has p0 - notpen_ct - cons elements (=#penalized)
		// Note that full set of regressors can including omitteds, factor base categories, etc.
		*

		*** fix colnames of beta vectors to include omitted "o." notation
		// includes post-lasso vector in case of collinearity => a selected variable was omitted
		// trick is to use _ms_findomitted utility but give it
		// diag(bAll) as vcv matrix where it looks for zeros
		// also build in fv info
		tempname tempvmat
		mat `tempvmat'	= diag(`bOLS')
		_ms_findomitted	`bOLS' `tempvmat'
		_ms_build_info	`bOLS' if `toest'
		mat `tempvmat'	= diag(`bAll')
		_ms_findomitted	`bAll' `tempvmat'
		_ms_build_info	`bAll' if `toest'
		mat `tempvmat'	= diag(`bAllOLS')
		_ms_findomitted	`bAllOLS' `tempvmat'
		_ms_build_info	`bAllOLS' if `toest'
		*

		*** manipulate variable counts and lists
		// selected0 and s0 are selected+notpen (excluding constant)
		// selected and s are selected only
		local notpen_ct		: word count `notpen_o'			//  number of notpen EXCL CONSTANT
		local selected		: list selected0 - notpen_o		//  selected now has only selected/penalized variables
		local s				: word count `selected'			//  number of selected/penalized vars EXCL NOTPEN/CONSTANT
		*

		*** error checks
		// check col vector of b (selected) vs. k
		local col_ct		=colsof(`b')
		if colsof(`b')==1 & el(`b',1,1)==. {	//  coef vector is empty so k should be zero
			if `k'~=0 {
				di as err "internal _rlasso error - r(k)=`k' does not match number of selected vars/coefs=`col_ct'"
				exit 499
			}
		}
		else if `k'~=`col_ct' {					//  coef vector not empty so k should match col count
			di as err "internal _rlasso error - r(k)=`k' does not match number of selected vars/coefs=`col_ct'"
			exit 499
		}
		// check col vector of bAll vs. p0
		local col_ct		=colsof(`bAll')
		if `p0'~=`col_ct' {						// full coef vector not empty so k should match col count
			di as err "internal _rlasso error - p0=`p0' does not match number of model vars/coefs=`col_ct'"
			exit 499
		}
		*

		*** return results
		// coef vectors are row vectors (Stata standard)
		return matrix beta		=`b'
		return matrix betaOLS	=`bOLS'
		//*//return matrix sbeta		=`sb'
		//*//return matrix sbetaOLS	=`sbOLS'
		return matrix betaAll	=`bAll'
		return matrix betaAllOLS=`bAllOLS'
		return matrix Psi		=`Psi'
		//*//return matrix sPsi		=`sPsi'
		return matrix stdvec	=`stdvec'					//  penalized vars only
		return scalar lambda	=`lambda'					//  relates to depvar in original units
		//*//return scalar slambda	=`slambda'					//  relates to standardized depvar
		//*//return scalar lambda0	=`lambda0'					//  BCH definition of lambda
		return scalar rmse		=`rmse'						//  lasso rmse
		return scalar rmseOLS	=`rmseOLS'					//  post-lasso rmse
		return scalar objfn		=`objfn'
		return local  selected0	`selected0'					//  all selected/notpen vars INCLUDING NOTPEN (but excl constant)
		return local  selected	`selected' 					//  all selected (penalized) vars EXCLUDING NOTPEN & CONS
		return scalar k			=`k'						//  number of all vars in sel/notpen parameter vector INCLUDING CONSTANT
		return scalar s0		=`s0'						//  number of vars selected INCLUDING NOTPEN (but excl constant)
		return scalar s			=`s'						//  number of vars selected EXCLUDING NOTPEN & CONS
		return scalar p0		=`p0'						//  number of all vars in original model including constant
		return scalar N_clust	=`N_clust'
		return scalar N			=`N'
		//*//return scalar center	=`center'
		return local  clustvar	`cluster'
		return local  robust	`robust'
		return scalar niter		=`niter'
		return scalar maxiter	=`maxiter'
		//*//return scalar npsiiter	=`npsiiter'
		//*//return scalar maxpsiiter=`maxpsiiter'
		return scalar lcount 	= 1
		return scalar olsflag	= `olsflag'
	}
	else {
		di as err "internal _lassopath error - lcount=`lcount'"
		exit 499
	}
end

// subroutine for partialling out
program define _partial, rclass sortpreserve
	version 13
	syntax anything ,							/// anything is actually a varlist but this is more flexible - see below
		touse(varlist numeric max=1)			/// required `touse' variable (so marksample unneeded)
		[										/// 
		toest(varlist numeric max=1)			/// optional `toest' variable (subset on which standardization is based)
		PARtial(string)							/// string so that fv operators aren't inserted
		tvarlist(string)						/// optional list of temp model vars - may be "unfilled" (NaNs)
		wvar(string)							/// optional weight variable
		dmflag(int 0)							/// =0 if cons and not demeaned; =1 if no cons, already demeaned or treat as demeaned
		solver(string)							/// svd, qr or empty
		]

	*** `anything' is actually a varlist but this is more flexible.
	// avoids problems with uninitialized vars, unwanted parsing of factor vars, etc.
	// ... so immediately rename.
	local varlist `anything'
	*

	*** toest vs touse
	// touse = all data
	// toest = estimation sample
	// if toest is missing, set equal to touse
	if "`toest'"=="" {
		tempvar toest
		qui gen byte `toest' = `touse'
	}
	*

	*** Error check - if tvarlist provided, should have same number of elements as varlist
	local v_ct	: word count `varlist'
	local tv_ct	: word count `tvarlist'
	if `tv_ct' & (`v_ct'~=`tv_ct') {
		di as err "internal lassoutils partialling error - mismatched lists"
		exit 198
	}
	*

	*** recode solver macro into numeric 1/2/3
	if "`solver'"=="" {
		local solver 0			//  default method (SVD, QR if collinearities - see below)
	}
	else if "`solver'"=="svd" {
		local solver 1			//  force use of SVD solver
	}
	else if "`solver'"=="qr" {
		local solver 2			//  force use of QR solver
	}
	else {
		di as err "Syntax error: solver `solver' not allowed"
		exit 198
	}
	*
	
	*** partial out
	mata: s_partial("`varlist'", 			/// y and X
					"`partial'",          	/// to be partialled out
					"`tvarlist'",			///
					"`touse'",				/// touse
					"`toest'",				/// toest
					"`wvar'",				/// optional weight variable
					`dmflag', 				/// treatment of constant/demeaned or not
					`solver')				//  choice of solver (optional)
	return scalar rank	=`r(rank)'			//  rank of matrix P of partialled-out variables 
	return local dlist	`r(dlist)'			//  list of dropped collinear variables in P
	*

end


// subroutine for fe transformation
program define _fe, rclass sortpreserve
	version 13
	syntax anything ,							/// anything is actually a varlist but this is more flexible - see below
		touse(varlist numeric max=1)			/// required `touse' variable (so marksample unneeded)
		tvarlist(string)						/// optional list of temp vars - may be "unfilled" (NaNs)
		FE(varlist numeric min=1 max=1) 		/// fe argument is ivar
		[										///
		wvar(varlist numeric max=1)				/// optional weight variable
		toest(varlist numeric max=1)			/// optional `toest' variable (subset on which standardization is based)
		NOFTOOLS								///
		]

	*** `anything' is actually a varlist but this is more flexible.
	// avoids problems with uninitialized vars, unwanted parsing of factor vars, etc.
	// ... so immediately rename.
	local varlist `anything'
	*

	*** toest vs touse
	// toest = estimation sample
	// touse = all data
	// if toest is missing, set equal to touse
	if ("`toest'"=="") {
		tempvar toest
		qui gen `toest'=`touse'
	}
	*

	*** ftools
	// do not use ftools if (a) specifcally not requested; (b) not installed
	// use "which ftools" to check - faster, plus compile was already triggered
	// in conditional load section at end of this ado
	if "`noftools'"=="" {
		cap which ftools
		if _rc {
			// fails check, likely not installed, so use (slower) Stata code
			local noftools "noftools"
		}
	}
	*
	
	*** error check - weights support requires ftools
	if "`noftools'"~="" & "`wvar'"~="" {
		di as err "error - fe option with weights requires " _c
		di as err `"{rnethelp "http://fmwww.bc.edu/RePEc/bocode/f/ftools.sthlp":ftools} package to be installed"'
		di as err `"see {rnethelp "http://fmwww.bc.edu/RePEc/bocode/f/ftools.sthlp":help ftools} for details"'
		exit 198
	}
	*
	
	*** Error check - if tvarlist provided, should have same number of elements as varlist
	local v_ct	: word count `varlist'
	local tv_ct	: word count `tvarlist'
	if (`v_ct'~=`tv_ct') {
		di as err "internal lassoutils FE error - mismatched lists"
		exit 198
	}
	*

	if "`noftools'"~="" {
		// timer on 1
		*** Within-transformation / demeaning
		// varlist should be all doubles so no recast needed
		// xtset is required for FEs so this check should never fail
		cap xtset
		if _rc {
			di as err "internal lassoutils xtset error"
			exit 499
		}
		// panelvar always exists; timevar may be empty
		// if data xtset by panelvar only, may not be sorted
		// if data xtset by panelvar and time var, will be sorted by both
		// resorting can be triggers by simple call to xtset
		local panelvar `r(panelvar)'
		local timevar `r(timevar)'
		// sort by panel and estimation sample; put latest observation last
		sort `panelvar' `toest' `timevar'
		// toest_m is indicator that this ob will have the mean
		// N_est is number of obs in panel and in estimation sample
		tempvar toest_m N_est
		// last ob in panel and estimation sample tagged to have mean
		qui by `panelvar' `toest' : gen `toest_m' = (_n==_N) & `toest'
		qui by `panelvar' `toest' : gen `N_est' = sum(`toest')
		// count is of panels used in estimation
		qui count if `toest_m'
		local N_g	=r(N)
		// if xtset by panel and time vars, restore sort
		cap xtset
		// create means for each variable
		foreach var of varlist `varlist' {
			tempvar `var'_m
			local mlist `mlist' ``var'_m'
			// use only training/estimation data to calculate mean (toest)
			qui by `panelvar' : gen double ``var'_m'=sum(`var')/`N_est' if `toest'
			qui by `panelvar' : replace ``var'_m' = . if ~`toest_m'
		}
		// sort so that last ob in each panel has the mean in it
		sort `panelvar' `toest_m'
		// and propagate to the rest of the panel
		foreach var of varlist `mlist' {
			qui by `panelvar' : replace `var' = `var'[_N] if _n<_N
		}
		// if xtset by panel and time vars, restore sort
		// need to do this if e.g. any time-series operators in use
		cap xtset
		// finally, demean data
		local i 1
		foreach var of varlist `varlist' {
			local tvar	: word `i' of `tvarlist'
			qui replace `tvar'=`var'-``var'_m' if `touse'
			local ++i
		}
		return scalar N_g = `N_g'
		*
		// timer off 1
	}
	else {
		// Mata routine; uses Sergio Correia's FTOOLS package.
		// timer on 2
		mata: s_fe("`varlist'", 				/// 
					"`tvarlist'",				///
					"`wvar'",					///
					"`fe'",         		 	///
					"`touse'",					///
					"`toest'")
		local N_g	=r(N_g)
		return scalar N_g = `N_g'
		// timer off 2
	}
	// indicate whether FTOOLS not used
	return local noftools `noftools'
end


// subroutine for standardizing in Stata
program define _std, rclass
	version 13
	syntax anything ,							/// anything is actually a varlist but this is more flexible - see below
		touse(varlist numeric max=1)			/// required `touse' variable (so marksample unneeded)
		[										///
		toest(varlist numeric max=1)			/// optional `toest' variable (subset on which standardization is based)
		tvarlist(string)						/// optional list of temp vars - may be "unfilled" (NaNs)
		consmodel(int 1)						/// =1 if constant in model (=> data are to be demeaned)
		dmflag(int 0)							/// =1 if data already demeaned or treat as demeaned
		NOChange								/// don't transform the data; just return the std vector
		]

	*** `anything' is actually a varlist but this is more flexible.
	// avoids problems with uninitialized vars, unwanted parsing of factor vars, etc.
	// ... so immediately rename.
	local varlist `anything'
	*
	
	local transform = ("`nochange'"=="")
	
	*** toest vs touse
	// touse = all data
	// toest = estimation sample
	// if toest is missing, set equal to touse
	if "`toest'"=="" {
		tempvar toest
		qui gen byte `toest' = `touse'
	}
	*

	tempname stdvec mvec
	mata: s_std("`varlist'","`tvarlist'","`touse'","`toest'",`consmodel',`dmflag',`transform') 
	mat `stdvec' = r(stdvec)
	mat `mvec' = r(mvec)
	// these will be tempnames if std program called with tempvars
	mat colnames `stdvec' = `varlist'
	mat colnames `mvec' = `varlist'
	return matrix stdvec = `stdvec'
	return matrix mvec = `mvec'	
end


// subroutine for weighting in Stata
program define _wt, rclass
	version 13
	syntax anything ,							/// anything is actually a varlist but this is more flexible - see below
		touse(varlist numeric max=1)			/// required `touse' variable (so marksample unneeded)
		wvar(varlist numeric max=1)				/// required `wvar' variable
		tvarlist(string)						/// required list of temp vars - may be "unfilled" (NaNs)
		[										///
		NOChange ///
		]

	*** `anything' is actually a varlist but this is more flexible.
	// avoids problems with uninitialized vars, unwanted parsing of factor vars, etc.
	// ... so immediately rename.
	local varlist `anything'
	*
	
	local transform = ("`nochange'"=="")
	
	mata: s_wt("`varlist'","`tvarlist'","`touse'","`wvar'",`transform')
	
end


// subroutine for recovering coefs of partialled-out vars
program define _unpartial, rclass sortpreserve
	version 13
	syntax anything ,							/// anything is actually a varlist but this is more flexible - see below
		touse(varlist numeric max=1)			/// required `touse' variable (so marksample unneeded)
		[										///
		beta(string)							///
		depvar(string)							///
		scorevars(string)						///
		wvar(string)							///
		names_t(string)							/// string so that fv operators aren't inserted
		names_o(string)							/// ditto
		PARtial(string)							/// ditto
		consmodel(int 1)						/// include constant when recovering coefs
		]

	*** `anything' is actually a varlist but this is more flexible.
	// avoids problems with uninitialized vars, unwanted parsing of factor vars, etc.
	// ... so immediately rename.
	local varlist `anything'
	*

	local depvar `varlist'
	tempname b
	tempvar xb yminus
	if "`scorevars'" ~= "" {
		mat `b' = `beta'
		mat colnames `b' = `scorevars'
		qui mat score double `xb' = `b' if `touse'
		qui gen double `yminus' = `depvar' - `xb' if `touse'
	}
	else {
		qui gen double `yminus' = `depvar'
	}
	// weights; note that since we use regress+weights, all vars here are unweighted
	if "`wvar'"~="" {
		local wexp [aw=`wvar']
	}
	//  partial uses _tnames; use _t names and then convert to _o names
	//  _t names will be FE-transformed or just the values of the original vars (without i/b/n etc.)
	if ~`consmodel' {
		local noconstant noconstant
	}
	qui reg `yminus' `partial' if `touse' `wexp', `noconstant'
	tempname bpartial
	mat `bpartial' = e(b)
	// replace temp names with original names
	local cnames_t	: colnames `bpartial'				//  may have _cons at the end already
	fvstrip `cnames_t'									//  regress output may have omitted vars
	local cnames_t	`r(varlist)'
	matchnames "`cnames_t'" "`names_t'" "`names_o'"
	local cnames_o	`r(names)'
	mat colnames `bpartial' = `cnames_o'
	// may be omitteds so need to reinsert o. notation
	// trick is to use _ms_findomitted utility but give it
	// diag(bAll) as vcv matrix where it looks for zeros
	tempname tempvmat
	mat `tempvmat'	= diag(`bpartial')
	_ms_findomitted `bpartial' `tempvmat'
	// build in fv info
	_ms_build_info `bpartial' if `touse'
	// attach to b matrix if b not empty
	if `beta'[1,1] ~= . {
		mat `b' = `beta' , `bpartial'
	}
	else {
		mat `b' = `bpartial'
	}
	
	return matrix b = `b'
	return matrix bpartial = `bpartial'

end

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

********************************************************************************
*** Mata section															 ***
********************************************************************************

version 13
mata:

// data structure
struct dataStruct {
	pointer colvector y
	pointer matrix X
	pointer colvector clustid	// cluster id
	string colvector nameX		// names of actual variables (can be tempvars)
	string colvector nameX_o	// original names of variables
	real scalar cons			// =1 if model also has a constant, =0 otherwise
	real scalar dmflag			// =1 if data have mean zero or should be treated as demeaned, =0 otherwise
	real scalar n				// number of observations
	real scalar nclust			// number of clusters; 0 if no clustering
	real scalar p				// number of columns in X (may included constant)
	real rowvector sdvec		// vector of SDs of X
	real rowvector varvec		// vector of variances of X
	real scalar ysd				// standard deviation of y
	real scalar prestdflag		// flag indicating data have been pre-standardized
	real rowvector prestdx		// prestandaridization vector of SDs for X
	real scalar prestdy			// prestandaridization SD for y
	real rowvector mvec			// vector of means
	real scalar ymvec			// mean of y (not actually a vector)
	real matrix pihat			// used for partialling out with rlasso
	real matrix ypihat			// used for partialling out with rlasso
	real matrix XX				// cross prod of all Xs
	real matrix Xy				// cross prod of all Xs and y
	pointer matrix Xp			// used by rlasso - penalized Xs
	pointer matrix Xnp			// used by rlasso - unpenalized Xs
	real scalar np				// used by rlasso - number of unpenalized Xs; also used as flag
	string colvector nameXp		// used by rlasso - names of actual variables (can be tempvars)
	string colvector nameXnp	// used by rlasso - names of actual variables (can be tempvars)
	real rowvector selXp		// used by rlasso - selection row vector for penalized vars
	real rowvector selXnp		// used by rlasso - selection row vector for unpenalized vars
	real rowvector selindXp		// used by rlasso - selection index row vector for penalized vars
	real rowvector selindXnp	// used by rlasso - selection index row vector for unpenalized vars
	real rowvector mvecp		// used by rlasso - vector of means of penalized Xs
	real rowvector mvecnp		// used by rlasso - vector of means of unpenalized Xs
	real rowvector sdvecp		// used by rlasso - sdvec of penalized vars after partialling-out unpenalized vars
	real rowvector sdvecpnp		// used by rlasso - same as sdvecp except conformable with full set of Xs (p and np)
	real scalar ysdp			// used by rlasso - SD of y after partialling out unpenalized vars
	}

struct outputStruct {
	real colvector beta			// beta in original units
	//real colvector sbeta		// beta in standardized units
	real colvector betaPL		// OLS (post-lasso) beta in std units 
	//real colvector sbetaPL
	real colvector betaAll		// full beta vector
	real colvector betaAllPL	// full OLS (post-lasso) beta vector
	real colvector beta_init
	real scalar cons			// flag =1 if cons in regression, =0 if no cons
	real scalar intercept		// estimated intercept
	real scalar interceptPL		// estimated OLS (post-lasso) intercept
	string colvector nameXSel	// vector of names of selected Xs
	real colvector index		// index of selected vars
	real rowvector Psi			// penalty loadings
	real rowvector sPsi			// standardized penalty loadings
	real rowvector ePsi			// estimated penalty loadings (rlasso only)
	real scalar prestdflag		// flag indicating data have been pre-standardized
	real colvector v			// residuals
	real colvector vPL			// OLS (post-lasso) residuals
	real scalar lambda			// penalty scalar
	real scalar slambda			// standardized
	real scalar lambda0			// lambda without estimate of sigma (rlasso only)
	real scalar c				// part of BCH lambda
	real scalar gamma			// part of BCH lambda
	real scalar gammad			// part of BCH lambda
	real scalar rmse			// rmse using estimated beta
	real scalar rmsePL			// rmse using OLS (post-lasso) beta
	real scalar n				// number of obs
	real scalar s				// number of selected vars
	real scalar nclust			// number of clusters (rlasso only)
	real scalar niter			// number of iterations
	real scalar npsiiter		// number of rlasso penalty loadings iterations
	real rowvector supscore		// sup-score stats: BCH stat, p-value, crit-value, signif; rlasso stat, p-value
	real scalar ssgamma			// gamma for sup-score conservative critical value
	real scalar objfn			// value of minimized objective function
	}
// end outputStruct
	
struct outputStructPath {
	real colvector lambdalist
	real matrix betas
	real matrix sbetas
	real rowvector Psi
	real rowvector sdvec
	real rowvector sPsi
	real colvector dof // "effective" degrees of freedom
	real colvector shat // number of non-zero parameters
	real scalar cons // yes/no
	real rowvector intercept
	real rowvector interceptPL
	real scalar n
	real scalar nclust
	}
// end outputStructPath


struct dataStruct scalar MakeData(	string scalar nameY,
									string scalar nameX,
									string scalar nameX_o,
									string scalar touse,
									real scalar cons,
									real scalar dmflag,
									real scalar prestdflag,		///
									|							///  optional arguments
									string scalar stdymat,		///
									string scalar stdxmat,		///
									string scalar nameclustid,	///  optional arguments - rlasso-specific
									string scalar nameP,		///
									string scalar nameNP)
{

	if (args()<=7) {
		stdymat		= ""
		stdxmat		= ""
		nameclustid	= ""
	}
	if (args()<=10) {
		nameP		= ""			//  default list is empty
		nameNP		= ""			//  default list is empty
	}

	struct dataStruct scalar d
	

	// dep var
	st_view(y,.,nameY,touse)
	d.y			=&y

	// X vars
	st_view(X,.,nameX,touse)
	d.X			=&X
	d.nameX		=tokens(nameX)
	d.nameX_o	=tokens(nameX_o)
	d.n			=rows(X)
	d.p			=cols(X)
	d.cons		=cons			//  model has constant to be recovered by estimation code; also used in variable counts
	d.dmflag	=dmflag			//  treat data as zero mean
	d.prestdflag=prestdflag

	// cluster var
	if (nameclustid!="") {
		st_view(cid,.,nameclustid,touse)
		d.clustid	= &cid
		info		= panelsetup(cid, 1)
		d.nclust	= rows(info)
	} 
	else {
		d.nclust	= 0
	}

	// mean vectors
	if (dmflag) {
		// already demeaned or treat as demeaned
		d.mvec		= J(1,d.p,0)
		d.ymvec		= 0
	}
	else {
		// calculate means
		d.mvec		= mean(*d.X)
		d.ymvec		= mean(*d.y)
	}

	// SDs used to prestandardize
	if (prestdflag) {
		// data are prestandardized so just store these
		d.prestdy	=st_matrix(stdymat)
		d.prestdx	=st_matrix(stdxmat)
	}

	// standardization vectors
	// nb: d.ysd may be unused in code
	if (prestdflag) {
		// data are prestandardized so all unit vectors
		d.ysd		=1
		d.sdvec		=J(1,d.p,1)
		d.varvec	=J(1,d.p,1)
	}
	else if (dmflag) {
		// already demeaned (mean zero) or treat as demeaned
		d.ysd		= sqrt(mean((*d.y):^2))
		d.varvec	= mean((*d.X):^2)
		d.sdvec		= sqrt(d.varvec)
	}
	else {
		// not mean zero so need to demean
		d.ysd		= sqrt(mean(((*d.y):-d.ymvec):^2))
		d.varvec	= mean(((*d.X):-d.mvec):^2)
		d.sdvec		= sqrt(d.varvec)
	}

	// X'X and X'y
	if (cons) {
		// unpenalized constant present so X'X is in mean-devation form
		d.XX = quadcrossdev(*d.X,d.mvec,*d.X,d.mvec)
		d.Xy = quadcrossdev(*d.X,d.mvec,*d.y,d.ymvec)
	}	
	else {
		// either data are already zero-mean or no constant is present in the model
		d.XX = quadcross(*d.X,*d.X)
		d.Xy = quadcross(*d.X,*d.y)
	}

	// rlasso section
	// Note that rlasso code requires uses SDs for additional purposes, and the SDs are after partialling out.  
	// These are saved as d.ysdp, d.sdvecp, d.sdvecpnp (inserted into a vector conformable with X).
	// sdvecpnp has the SDs of the Xs after partialling out + 0s for the SDs of the partialled vars
	if (nameNP!="") {
		// unpenalized regressors in rlasso
		st_view(Xp,.,nameP,touse)
		st_view(Xnp,.,nameNP,touse)
		d.Xp		=&Xp
		d.Xnp		=&Xnp
		d.np		=cols(Xnp)
		d.nameXp	=tokens(nameP)
		d.nameXnp	=tokens(nameNP)
		selXp		= J(1,cols(*d.X),1)
		forbound	= cols(d.nameXnp)		//  faster
		for (i=1;i<=forbound;i++) {
			selXp = selXp - (d.nameX :== d.nameXnp[1,i])
		}
		d.selXp		=selXp
		d.selXnp	=1:-selXp
		d.selindXp	=selectindex(d.selXp)
		d.selindXnp	=selectindex(d.selXnp)

		if (cons) {
			// standard case - model has a constant, data are not demeaned
			// model has a constant (unpenalized) so cross-prods etc are in mean-dev form
			d.mvecp		= mean(*d.Xp)
			d.mvecnp	= mean(*d.Xnp)
			d.ypihat	= qrsolve((*d.Xnp):-d.mvecnp,(*d.y):-d.ymvec)
			d.pihat		= qrsolve((*d.Xnp):-d.mvecnp,(*d.Xp):-d.mvecp)
			d.ysdp		= sqrt(mean((((*d.y):-d.ymvec)-((*d.Xnp):-mean(*d.Xnp))*d.ypihat):^2))
			// std vector for just the Xp variables.
			d.sdvecp	= sqrt(mean((((*d.Xp):-d.mvecp)-((*d.Xnp):-mean(*d.Xnp))*d.pihat):^2))
		}
		else if (dmflag) {
			// zero-mean data and no constant is present in the model
			// means are zero vectors, cross-prods don't need demeaning, SDs don't need demeaning
			d.mvecp		= J(1,cols(*d.Xp),0)
			d.mvecnp	= J(1,cols(*d.Xnp),0)
			d.ypihat	= qrsolve(*d.Xnp,*d.y)
			d.pihat		= qrsolve(*d.Xnp,*d.Xp)
			d.ysdp		= sqrt(mean(((*d.y)-(*d.Xnp)*d.ypihat):^2))
			// std vector for just the Xp variables.
			d.sdvecp	= sqrt(mean(((*d.Xp)-(*d.Xnp)*d.pihat):^2))
		}
		else {
			// model has no constant but means may be nonzero
			// hence cross-prods don't need demeaning but SDs do
			d.mvecp		= mean(*d.Xp)
			d.mvecnp	= mean(*d.Xnp)
			d.ypihat	= qrsolve(*d.Xnp,*d.y)
			d.pihat		= qrsolve(*d.Xnp,*d.Xp)
			d.ysdp		= sqrt(	mean(																			///
								(centerpartial(d.y,d.ymvec,d.cons,d.Xnp,d.mvecnp,d.ypihat)						///
									:- mean(centerpartial(d.y,d.ymvec,d.cons,d.Xnp,d.mvecnp,d.ypihat))):^2		///
								 ) )
			// std vector for just the Xp variables.
			d.sdvecp	= sqrt( mean(																			///
								(centerpartial(d.Xp,d.mvecp,d.cons,d.Xnp,d.mvecnp,d.pihat)						///
									:- mean(centerpartial(d.Xp,d.mvecp,d.cons,d.Xnp,d.mvecnp,d.pihat))):^2		///
								) )
		}

		// Now create blank full-size std vector of zeros for all X variables.
		d.sdvecpnp					= J(1,cols(*d.X),0)
		// Then insert values in appropriate columns.
		d.sdvecpnp[1,(d.selindXp)]	= d.sdvecp
	}
	else {													//  no unpenalized regressors (in rlasso)
		d.Xp		= d.X									//  penalized = all
		d.nameXp	= d.nameX
		d.selXp		= J(1,cols(*d.X),1)
		d.selindXp	= selectindex(d.selXp)
		d.np		= 0
		d.pihat		= 0
		d.ypihat	= 0
		d.mvecp		= d.mvec
		d.ysdp		= d.ysd									//  can just reuse these
		d.sdvecp	= d.sdvec
		d.sdvecpnp	= d.sdvecp								//  since all penalized, pnp=p (penalized-not penalized = penalized)

	}

	return(d)
}
// end MakeData



// this function calculates lasso path for range of lambda values
struct outputStructPath DoLassoPath(struct dataStruct scalar d,
									real rowvector Psi,					//  vector of penalty loadings (L1 norm)
									real rowvector Psi2,				//  vector of penalty loadings (L2 norm)
									real rowvector lvec,				//  vector of lambdas (L1 norm)
									real rowvector lvec2,				//  vector of lambdas (L2 norm)
									real scalar post,
									real scalar verbose,
									real scalar optTol,
									real scalar maxIter,
									real scalar zeroTol,
									real scalar alpha,
									real scalar lglmnet,
									real scalar noic)
{

		struct outputStructPath scalar t

		p = cols(*d.X)
		n = rows(*d.y)
		
		XX = d.XX
		Xy = d.Xy
		
		if (verbose>=2) {
			printf("Lambda list: %s\n",invtokens(strofreal(lvec)))
		}
		
		lmax=max(lvec)
		lcount=cols(lvec)
		beta=luqrsolve(XX+lmax/2*diag(Psi2),Xy) // beta start	
		if (verbose==3) {
			printf("Initial beta:\n")
			beta'
		}
		
		XX2=XX*2
		Xy2=Xy*2
		
		lpath = J(lcount,p,.) // create empty matrix which stores coef path
		for (k = 1;k<=lcount;k++) { // loop over lambda
			
			// Separate blocks for lasso, ridge, elastic net.
			// Separate lambdas and penalty loadings for L1 and L2 norms to accommodate standardization.
			// If data were pre-standardized, then lambda=lambda2 and Psi=Psi2.
			// If standardization is on-the-fly and incorporated in penalty loadings,
			// then lambdas and penalty loadings for L1 and L2 norms are different.
			lambda=lvec[1,k]
			lambda2=lvec2[1,k]
			m=0
			change = optTol*2 // starting value
			// optimization for a given lambda value. 
			while ((m < maxIter) & (change>optTol)) { 
			
				beta_old = beta
				for (j = 1;j<=p;j++) // keep all beta fixed, except beta[j]. update estimate.
				{
					S0 = quadcolsum(XX2[j,.]*beta) - XX2[j,j]*beta[j] - Xy2[j]

					if (alpha==1) {					//  lasso
							if (S0 > lambda*Psi[j])
							{
								beta[j] = (lambda*Psi[j] - S0)/(XX2[j,j])
							}
							else if (S0 < -lambda*Psi[j])	
							{
								beta[j] = (-lambda*Psi[j] - S0)/(XX2[j,j]) 
							}
							else 
							{
								beta[j] = 0
							}
					}								//  end lasso
					else if (alpha>0) {				//  elastic net
							if (S0 > lambda*Psi[j]*alpha)
							{
								beta[j] = (lambda*Psi[j]*alpha - S0)/(XX2[j,j]+ lambda2*Psi2[j]*(1-alpha))
							}
							else if (S0 < -lambda*Psi[j]*alpha)	
							{
								beta[j] = (-lambda*Psi[j]*alpha - S0)/(XX2[j,j]+ lambda2*Psi2[j]*(1-alpha)) 
							}
							else 
							{
								beta[j] = 0
							}
					} 								//  end elastic net
					else if (alpha==0) {			//  ridge  
					
							if (S0 > 0)
							{
								beta[j] = (-S0)/(XX2[j,j] + lambda2*Psi2[j])
							}
							else if (S0 < 0)	
							{
								beta[j] = (-S0)/(XX2[j,j] + lambda2*Psi2[j]) 
							}
							else 
							{
								beta[j] = 0
							}
					}								//  end ridge
				}									//  end j loop over components of beta

				m++
				change = quadcolsum(abs(beta-beta_old)) 
			
			}
			lpath[k,.]=beta'
		}	
		
		if (verbose==3) {
			printf("beta after shooting:\n")
			lpath[1,.]
		}	
		
		// following code should be the same for DoLassoPath() and DoSqrtLassoPath()
		
		lpath=edittozerotol(lpath, zeroTol)
		
		if (post) { 
			betasPL = J(lcount,p,0)
			nonzero0 = J(1,p,0)
			for (k = 1;k<=lcount;k++) { // loop over lambda points
				nonzero = lpath[k,.]:!=0  // 0-1 vector
				sk = sum(nonzero)			
				if ((0<sk) & (sk<n)) { // only if 0<s<n
					if ((nonzero0==nonzero) & (k>=2)) { // no change in active set
						betasPL[k,.] = betasPL[k-1,.]
					}
					else { 
						ix = selectindex(nonzero)	// index of non-zeros
						// obtain beta-hat
						if (d.cons==0) {
							// data are mean zero or there is no constant in the model
							betak=qrsolve(select((*d.X),nonzero),*d.y)
						}
						else {
							betak=qrsolve(select((*d.X),nonzero):-select(d.mvec,nonzero),((*d.y):-d.ymvec))
						}
						betasPL[k,ix] = betak'
						nonzero0=nonzero
					}
				}
			}
			t.betas 		= betasPL	
		}
		else {
			t.betas 		= lpath
		}
		
		// use glmnet lambda
		if (lglmnet) {
			lvec=lvec/2/n
		}
		
		t.lambdalist	= lvec'
		t.Psi			= Psi
		if (d.cons==0) {
			// data are mean zero or there is no constant in the model
			t.intercept		= 0
		}
		else {
			t.intercept		= mean(*d.y):-mean((*d.X))*(t.betas')
		}
		t.cons 			= d.cons
		
		// degrees of freedom and dimension of the model (add constant)
		t.shat = quadrowsum(t.betas:!=0) :+ (d.cons | d.dmflag)
		if (!noic) {
			if (alpha==1) { 
				// lasso dof
				// need to add the constant / account for demeaning
				t.dof	= t.shat 
			}
			else if (alpha==0) {
				// ridge dof  
				df = J(lcount,1,.)
				if (d.cons) {
					Xt = (*d.X) :- d.mvec
				}
				else {
					Xt=(*d.X)
				}
				for (k=1;k<=lcount;k++) { // loop over lambda points
					df[k,1] =trace((Xt)*invsym(quadcross(Xt,Xt):+lvec2[1,k]/2*diag(Psi2))*(Xt)') 
				}
				// need to add the constant / account for demeaning
				df = df :+ (d.cons | d.dmflag)
				t.dof	= df  
			}
			else {
				// elastic net dof
				df = J(lcount,1,.)
				if (d.cons) {
					Xt = (*d.X) :- d.mvec
				}
				else {
					Xt=(*d.X)
				}				
				for (k=1;k<=lcount;k++) { // loop over lambda points
					nonzero = lpath[k,.]:!=0  // 0-1 vector
					XA=select((Xt),nonzero)
					Psi2A=select((Psi2),nonzero)
					df[k,1] =trace((XA)*invsym(quadcross(XA,XA):+(1-alpha)*lvec2[1,k]/2*diag(Psi2A))*(XA)')
				}
				// need to add the constant / account for demeaning
				df = df :+ (d.cons | d.dmflag)
				t.dof	= df  
			}
		}
				
		return(t)		

}
// end DoLassoPath

	
void ReturnResultsPath(		struct outputStructPath scalar t,	///  
							struct dataStruct scalar d,			///  
							string scalar Xnames,				///
							|									///
							real scalar sqrtflag,				///
							real scalar stdcoef)
{
		// default values
		if (args()<=3) sqrtflag = 0
		if (args()<=4) stdcoef = 0

		Xnamesall=tokens(Xnames)
		betas			= t.betas
		lambdalist		= t.lambdalist
		wl1norm			= rowsum(abs(betas :* t.Psi))

		// unstandardize unless overriden by stdcoef
		if (d.prestdflag & stdcoef==0) {
			// betas	= betas			:/ d.sdvec * d.ysd
			betas		= betas			:/ d.prestdx * d.prestdy
			if (sqrtflag==0) {
				// sqrt-lasso lambdas don't need unstandardizing (pivotal so doesn't depend on sigma/y)
				// lambdalist= lambdalist	* d.ysd
				lambdalist	= lambdalist	* d.prestdy
			}
			// wl1norm		= wl1norm		* d.ysd
			wl1norm		= wl1norm		* d.prestdy
		}

		// "L1 norm" excluding constant and unpenalized vars
		l1norm			= rowsum(abs(betas :* (t.Psi :> 0)))

		//dof				= quadrowsum(betas:!=0)
		pall			= cols(Xnamesall)

		if (t.cons) {
			betas		= (betas , (t.intercept'))		//  no intercept if pre-standardized
			Xnamesall	= (Xnamesall, "_cons")
			pall		= pall+1
		}
		st_numscalar("r(lmax)", max(lambdalist))
		st_numscalar("r(lmin)", min(lambdalist))
		st_numscalar("r(lcount)",rows(lambdalist))
		st_matrix("r(lambdalist)",lambdalist)
		st_matrix("r(l1norm)",l1norm)
		st_matrix("r(wl1norm)",wl1norm)
		st_matrix("r(betas)",betas)
		st_matrix("r(Psi)",t.Psi)
		st_matrix("r(sPsi)",t.sPsi)
		st_matrix("r(shat)",t.shat)
		st_matrix("r(stdvec)",d.sdvec)
		st_matrixcolstripe("r(betas)",(J(pall,1,""),Xnamesall'))
		st_matrixcolstripe("r(lambdalist)",("","Lambdas"))
		st_matrixcolstripe("r(l1norm)",("","L1norm"))
		st_matrixcolstripe("r(wl1norm)",("","wL1norm"))
}
// end ReturnResultsPath
	
void ReturnCVResults(real rowvector Lam, ///
					real rowvector MSPE,
					real rowvector SD, 
					real scalar minid,
					real scalar minseid)
{
	
	lnum=cols(Lam)
	
	printf("{txt}%10s{c |} {space 3} {txt}%10s {space 3} {txt}%10s {space 3} {txt}%10s\n","","Lambda","MSPE","st. dev.")
	printf("{hline 10}{c +}{hline 45}\n")
			
	for (j = 1;j<=lnum;j++) 	{
		
		if (j==minid) {
			marker="*"
		}
		else {
			marker=""
		}
		if (j==minseid) {
			marker=marker+"^"
		}
		printf("{txt}%10.0g{c |} {space 3} {res}%10.0g {space 3} {res}%10.0g {space 3} {res}%10.0g  %s\n",j,Lam[1,j],MSPE[1,j],SD[1,j],marker)
	
	}
}
// end ReturnCVResults


real scalar lambdaCalc(struct dataStruct scalar d,		///
						real scalar pminus,				/// adjustment to number of Xs in model
						real scalar gamma,				/// default is 0.1/log(N)
						real scalar c,					/// 
						real scalar R,					///
						real scalar hetero,				///
						real scalar xdep,				///
						real colvector v,				///
						real scalar rmse,				///
						real rowvector ScoreStdVec,		///
						real scalar lalt,				///
						|								///
						real scalar newseed,			///
						real scalar dotsflag,			///
						real scalar verbose,			///
						real scalar sqrtflag			///
						) 
{

	if (args()<=11)	newseed = -1
	if (args()<=12) dotsflag = 0
	if (args()<=13) verbose = 0
	if (args()<=14) sqrtflag = 0

	// lasso gets a factor of 2c; sqrt-lasso gets a factor of c
	if (sqrtflag)	lassofactor = c
	else			lassofactor = 2*c

	// model may have partialled-out var with coeffs estimated separately; subtract in formulae below
	p = d.p - pminus

	if (xdep==0) {									// X-independent
		if (lalt==0) {								// standard lambda
			lambda	= lassofactor * sqrt(d.n)*invnormal(1-gamma/(2*p))
		}
		else {										//  alternative lambda
			lambda	= lassofactor * sqrt(d.n) * sqrt(2 * log(2*p/gamma))
		}
	}												//  end X-independent block
	else {											//  X-dependent
		multbs	= 0 // don't override
		sim		= SimMaxScoreDist(d,v,rmse,ScoreStdVec,multbs,hetero,verbose,R,newseed,dotsflag,sqrtflag)
		// use quantile from simulated values to get lambda
		lambda	= lassofactor * d.n * mm_quantile(sim,1,1-gamma)
	}

	return(lambda)
}
// end lambdaCalc


real colvector InitialResiduals(	struct dataStruct scalar d,
									real scalar corrnumber) 
{ 
	// applies OLS to a reduced set of regressors exhibiting highest correlation with y
	// size of restricted set = corrnumber

	// in case corrnumber < dim(X)
	if (d.pihat==0) {
		dimX=cols(*d.X)
	}
	else {
		dimX=cols(*d.Xp)
	}
	corrnumber=min((corrnumber,dimX))

	// just return if corrnum = 0
	if (corrnumber <= 0) {
		// centerpartial(.) returns y centered and with Xnp partialled out.
		return(centerpartial(d.y,d.ymvec,d.cons,d.Xnp,d.mvecnp,d.ypihat))
	}
	else {
		dimZ=dimX+1
		// Z=abs(correlation(																///
		//					(centerpartial(d.y,d.ymvec,d.cons,d.Xnp,d.mvecnp,d.ypihat),		///
		//					 centerpartial(d.Xp,d.mvecp,d.cons,d.Xnp,d.mvecnp,d.pihat))		///
		//						))
		// instead of official correlation(.), use m_quadcorr(.) defined below
		// m_quadcorr(.) accommodates case of zero-mean data or no constant
		Z=abs(m_quadcorr(																	///
							(centerpartial(d.y,d.ymvec,d.cons,d.Xnp,d.mvecnp,d.ypihat),		///
							 centerpartial(d.Xp,d.mvecp,d.cons,d.Xnp,d.mvecnp,d.pihat))		///
							, d.cons	))
		z=Z[2..dimZ,1]
		ix=order(-z,1)
		ix=ix[1..corrnumber,1]

		if ((d.pihat==0) & (d.cons==0)) {				//  no notpen Xs, no constant in model or zero-mean data
			b	=qrsolve(								///
						(*d.X)[.,ix],					///
						 *d.y							///
						 )
			r	=(*d.y) :- ((*d.X)[.,ix])*b
		}
		else if (d.pihat==0) {							//  no notpen Xs, model has constant so demean in X'X
			b	=qrsolve(								///
						((*d.X)[.,ix]):-d.mvec[1,ix],	///
						(*d.y):-d.ymvec					///
						)
			r	=(*d.y) :- d.ymvec :- (((*d.X)[.,ix]):-d.mvec[1,ix])*b
		}
		else if (d.cons==0) {							//  notpen Xs, no constant in model or zero-mean data
			// ix has highest-correlation cols of Xp
			// replace with corresponding cols of X
			ix	= d.selindXp[1,ix]
			// and append np cols of X
			ix	= ix,d.selindXnp
			b	=qrsolve(								///
						 (*d.X)[.,ix],					/// selected cols of Xp plus all of Xnp
						 *d.y							///
						 )
			r	=(*d.y) :- ((*d.X)[.,ix])*b
		}
		else {											//  notpen Xs, model has constant so demean in X'X
			// ix has highest-correlation cols of Xp
			// replace with corresponding cols of X
			ix	= d.selindXp[1,ix]
			// and append np cols of X
			ix	= ix,d.selindXnp
			b	=qrsolve(								///
						 ((*d.X)[.,ix]):-d.mvec[1,ix],	/// selected cols of Xp plus all of Xnp
						 *d.y :- d.ymvec				///
						 )
			r	=(*d.y) :- d.ymvec :- (((*d.X)[.,ix]):-d.mvec[1,ix])*b
		}
		return(r)				// return residuals

	}
}
// end InitialResiduals


void EstimateRLasso(							///  Complete Mata code for RLasso.
				string scalar nameY,			///
				string scalar nameX,			///
				string scalar nameX_o,			///
				string scalar pen,				///
				string scalar notpen,			///
				string scalar touse,			///
				string scalar nameclustid, 		///
				string scalar stdymat,			///
				string scalar stdxmat,			///
				real scalar sqrtflag,			/// lasso or sqrt-lasso?
				real scalar hetero,				/// homosk or heteroskedasticity?
				real scalar xdep,				/// X-dependent or independent?
				real scalar R,					/// number of simulations with xdep
				real scalar lassoPsiflag,		/// use lasso or post-lasso residuals for estimating penalty loadings?
				real scalar optTol,				///
				real scalar maxIter,			///
				real scalar zeroTol,			///
				real scalar maxPsiIter,			///
				real scalar PsiTol,				///
				real scalar verbose,			///
				real scalar c,					///
				real scalar c0,					///
				real scalar gamma,				///
				real scalar gammad,				///
				real scalar lambda0,			///
				real scalar lalt, 				///
				real scalar corrnumber,			///
				real scalar pminus,				///
				real scalar nclust1,			/// use #nclust-1 instead of #nclust in cluster-lasso
				real scalar center,				/// center x_i*e_i or x_ij*e_ij in cluster-lasso
				real scalar sigma,				/// user-specified sigma for standard lasso
				real scalar supscoreflag,		///
				real scalar ssnumsim,			///
				real scalar ssgamma,			///
				real scalar newseed,			/// rnd # seed; relevant for xdep and supscore
				real scalar dotsflag,			///
				real scalar cons,				///
				real scalar dmflag,				///
				real scalar prestdflag)
{
	struct dataStruct scalar d
	d = MakeData(nameY,nameX,nameX_o,touse,cons,dmflag,prestdflag,stdymat,stdxmat,nameclustid,pen,notpen)

	struct outputStruct scalar OUT
	if (sqrtflag) {
		OUT	= RSqrtLasso(d,hetero,xdep,R,lassoPsiflag,optTol,maxIter,zeroTol,maxPsiIter,PsiTol,verbose,c,c0,gamma,gammad,lambda0,lalt,corrnumber,pminus,nclust1,center,supscoreflag,ssnumsim,ssgamma,newseed,dotsflag)
	}
	else {
		OUT	= RLasso(d,hetero,xdep,R,lassoPsiflag,optTol,maxIter,zeroTol,maxPsiIter,PsiTol,verbose,c,c0,gamma,gammad,lambda0,lalt,corrnumber,pminus,nclust1,center,sigma,supscoreflag,ssnumsim,ssgamma,newseed,dotsflag)
	}
	
	ReturnResults(OUT,d,sqrtflag)		//  puts results into r(.) macros
}	// end EstimateRLasso


struct outputStruct scalar RLasso(							/// Mata code for BCH rlasso
							struct dataStruct scalar d,		/// data
							real scalar hetero,				/// homosk or heteroskedasticity?
							real scalar xdep,				/// X-dependent or independent?
							real scalar R,					/// number of simulations with xdep
							real scalar lassoPsiflag,		/// use lasso or post-lasso residuals for estimating penalty loadings?
							real scalar optTol,				///
							real scalar maxIter,			///
							real scalar zeroTol,			///
							real scalar maxPsiIter,			///
							real scalar PsiTol,				///
							real scalar verbose,			///
							real scalar c,					///
							real scalar c0,					///
							real scalar gamma,				///
							real scalar gammad,				///
							real scalar lambda0,			///
							real scalar lalt, 				///
							real scalar corrnumber,			///
							real scalar pminus,				///
							real scalar nclust1,			/// use #nclust-1 instead of #nclust in cluster-lasso
							real scalar center,				/// center x_i*e_i or x_ij*e_ij in cluster-lasso
							real scalar sigma,				/// user-specified sigma (default=0)
							real scalar supscoreflag,		///
							real scalar ssnumsim,			///
							real scalar ssgamma,			///
							real scalar newseed,			///
							real scalar dotsflag			///
							)
{

	struct outputStruct scalar betas

	alpha=1 // elastic net parameter. always one.
	if (gammad<=0) {										//  not user-provided, so set here
		if (d.nclust==0)	gammad=log(d.n)					//  not cluster-lasso so #obs=n
		else				gammad=log(d.nclust)			//  cluster-lasso so #obs=nclust
	}
	if (gamma<=0) {											//  not user-provided, so set here
		gamma	= 0.1/gammad
	}
	sqrtflag	= 0		// easier to keep track of in arguments to functions
	
	if (sigma>0) {		// user-supplied sigma; assumes homoskedasticity

		if (verbose>=1) {
			printf("Estimation of penalty level/loadings with user-supplied sigma and i.i.d. data\n")
			printf("Obtaining lasso estimate...\n")
		}
		Psi		= d.sdvecpnp*sigma
		// note we use c and not c0
		lambda	= lambdaCalc(d,pminus,gamma,c,R,hetero,xdep,v,sigma,Psi,lalt,newseed,dotsflag,verbose,sqrtflag)
		betas	= DoLasso(d, Psi, Psi, lambda, lambda, verbose, optTol, maxIter, zeroTol, alpha)
		if (verbose>=1) {
			printf("Selected variables: %s\n\n",invtokens(betas.nameXSel'))
		}

	}
	else {				// standard code block to estimate rmse/lambda/penalty loadings
	
		// initial residuals
		v		= InitialResiduals(d,corrnumber)
		s1		= sqrt(mean(v:^2))
		
		// Create the score standardization vector using initial residuals.
		// Dim = 1 x p with zeros for unpenalized Xs. Last arg=0 is sqrtflag.
		Psi		= MakeScoreStdVec(d,v,s1,hetero,nclust1,center,0)
		
		// initialize lambda
		if (lambda0) {
			// user-supplied lambda0
			lambda=lambda0
		}
		else {
			// lambda does not incorporate rmse, does incorporate lasso factor of 2, last arg is sqrtflag
			// note we use c0 for the first lambda
			lambda	= lambdaCalc(d,pminus,gamma,c0,R,hetero,xdep,v,s1,Psi,lalt,newseed,dotsflag,verbose,sqrtflag)
		}

		// "iteration 1" - get first lasso estimate based on initial lambda/loadings
		iter = 1
		if (verbose>=1) {
			printf("Estimation of penalty level/loadings: Step %f.\n",iter)
			printf("Obtaining initial lasso estimate...\n")
		}
		betas	= DoLasso(d, Psi, Psi, lambda, lambda, verbose, optTol, maxIter, zeroTol, alpha)
		if (verbose>=1) {
			printf("Selected variables: %s\n\n",invtokens(betas.nameXSel'))
		}

		// initialize Delta
		Delta = 1e10
		
		while ((iter < maxPsiIter) & (Delta > PsiTol)) {

			s0	= s1
			// obtain residuals; based on betas(Psi)
			if (lassoPsiflag) {
				v	= betas.v		// lasso residuals
				s1	= betas.rmse 
			}
			else {
				v	= betas.vPL 	// post-lasso residuals
				s1	= betas.rmsePL
			}
			// change in RMSE used in loadings
			Delta = abs(s1-s0)
			// new loadings and lambda
			Psi	= MakeScoreStdVec(d,v,s1,hetero,nclust1,center,0)
			// note we use c and not c0 from now on
			lambda=lambdaCalc(d,pminus,gamma,c,R,hetero,xdep,v,s1,Psi,lalt,newseed,dotsflag,verbose,sqrtflag)

			// Reporting
			if (verbose>=1) {
				printf("Estimation of penalty level/loadings: Step %f.\n",iter)
				printf("RMSE: %f\n",s1)
				printf("Change in RMSE: %f\n",Delta)
				printf("Obtaining new lasso estimate...\n")
			}
			// new lasso estimate
			betas = DoLasso(d, Psi, Psi, lambda, lambda, verbose, optTol, maxIter, zeroTol, alpha)
			if (verbose>=1) {
				printf("Selected variables: %s\n\n",invtokens(betas.nameXSel'))
			}
		
			iter++
		
		}
	
	}	// end of code to iterate penalty loadings/lambda

	if (verbose>=1) {
		printf("Number of penalty loading iterations: %g\n",iter)
		if (iter == maxPsiIter) {
			printf("Warning: reached max penalty loading iterations w/o achieving convergence.\n")
		}
		else {
			printf("Penalty loadings (upsilon) convergence achieved.\n")
		}
	}

	// sup-score stat
	if (supscoreflag) {
		betas.supscore	= doSupScore(d, c, ssgamma, pminus, hetero, nclust1, center, verbose, ssnumsim, newseed, dotsflag)
		betas.ssgamma	= ssgamma
	}

	// convention is lambda0 = penalty without rmse (similar to sqrt-lambda);
	//               lambda = penalty including rmse;
	//               Psi = penalty loadings excluding rmse but standardizing;
	//               sPsi = penalty loadings excluding rmse and standardization; =1 under homoskedasticity.
	betas.lambda0	= lambda
	betas.lambda	= lambda * s1
	betas.slambda	= lambda * s1 / d.ysdp
	betas.Psi		= betas.Psi / s1
	betas.sPsi		= betas.Psi :/ d.sdvecpnp				//  should be =1 under homosk.
	betas.sPsi		= editmissing(betas.sPsi,0)				//  in case any unpenalized (div by 0)

	// Misc
	betas.n			= d.n
	betas.nclust	= d.nclust
	betas.npsiiter	= iter
	betas.c			= c
	betas.gamma		= gamma
	betas.gammad	= gammad

	return(betas)
}
// end RLasso	

void EstimateSupScore(							///  Complete Mata code for RLasso.
				string scalar nameY,			///
				string scalar nameX,			///
				string scalar nameX_o,			///
				string scalar pen,				///
				string scalar notpen,			///
				string scalar touse,			///
				string scalar nameclustid, 		///
				string scalar stdymat,			///
				string scalar stdxmat,			///
				real scalar hetero,				/// homosk or heteroskedasticity?
				real scalar nclust1,			///
				real scalar center,				///
				real scalar verbose,			///
				real scalar R,					///
				real scalar ssiidflag,			/// override use of multiplier bootstrap in iid case
				real scalar c,					///
				real scalar ssgamma,			///
				real scalar pminus,				///
				real scalar newseed,			///
				real scalar dotsflag,			///
				real scalar cons,				///
				real scalar dmflag,				///
				real scalar prestdflag)
{
	struct dataStruct scalar d
	d = MakeData(nameY,nameX,nameX_o,touse,cons,dmflag,prestdflag,stdymat,stdxmat,nameclustid,pen,notpen)

	struct outputStruct scalar OUT
	OUT.supscore	= doSupScore(d, c, ssgamma, pminus, hetero, nclust1, center, verbose, R, newseed, dotsflag, ssiidflag)
	// Misc
	OUT.n			= d.n
	OUT.nclust		= d.nclust
	OUT.c			= c
	OUT.ssgamma		= ssgamma

	ReturnResults(OUT,d)		//  puts results into r(.) macros

}	// end EstimateRLasso

real colvector SimMaxScoreDist(									///					
								struct dataStruct scalar d,		///
								real colvector v,				///
								real scalar rmse,				///
								real rowvector ScoreStdVec,		///
								|								///
								real scalar multbs,				///
								real scalar hetero,				///
								real scalar verbose,			///
								real scalar R,					///
								real scalar newseed,			///
								real scalar dotsflag,			///
								real scalar sqrtflag			///
								)
{

	// defaults
	// default is multbs=0 => use multiplier bootstrap for i.n.i.d. or cluster but not for i.i.d.
	if (args()<5)	multbs		= 0
	if (args()<6)	hetero		= 0
	if (args()<7)	verbose		= 0
	if (args()<8)	R			= 500
	if (args()<9)	newseed		= -1
	if (args()<10)	dotsflag	= 0
	if (args()<11)	sqrtflag	= 0
	//  set seed if requested
	if (newseed>-1)	rseed(newseed)

	if (dotsflag) {
		dotscmd = "_dots 0 0, title(Estimating score vector distribution using " + strofreal(R) + " repetitions)"
		stata(dotscmd)
	}
	sim=J(R,1,.)
	for (j=1; j<=R; j++) {
		if (dotsflag) {
			dotscmd = "_dots " + strofreal(j) + " 0"
			stata(dotscmd)
		}
		if (d.nclust==0) {
			// standard non-clustered case - g is iid standard normal
			g=rnormal(d.n,1,0,1)
		}
		else {
			// g is iid by cluster and repeated within clusters
			info	= panelsetup(*d.clustid, 1)
			// g is iid by cluster and repeated within clusters
			g=J(d.n,1,.)
			info = panelsetup(*d.clustid, 1)
			for (i=1; i<=d.nclust; i++) {
				g[info[i,1]..info[i,2],1] = J(info[i,2]-info[i,1]+1,1,rnormal(1,1,0,1))
			}
		}
		// centerpartial(.) returns Xp demeaned and with Xnp partialled-out.
		if (sqrtflag==0) {
			// standard lasso or score
			if ((multbs) | (hetero) | (d.nclust)) {
				// use multiplier bootstrap
				ScoreVec		= 1/(d.n) * quadcolsum( centerpartial(d.Xp,d.mvecp,d.cons,d.Xnp,d.mvecnp,d.pihat) :* (g:*v) )
			}
			else {
				// use i.i.d. version; rmse scales g so that it's the same scale as v
				ScoreVec		= 1/(d.n) * quadcolsum( centerpartial(d.Xp,d.mvecp,d.cons,d.Xnp,d.mvecnp,d.pihat) :* (g*rmse) )
			}
		}
		else {
			// sqrt lasso
			if ((multbs) | (hetero) | (d.nclust)) {
				// use multiplier bootstrap
				ScoreVec		= 1/(d.n) * quadcolsum( centerpartial(d.Xp,d.mvecp,d.cons,d.Xnp,d.mvecnp,d.pihat) :* (g:*v) * 1/rmse ) * 1/sqrt(mean(g:^2))
			}
			else {
				// pivotal so we don't need rmse, but we do need to normalize by sd of g (will be appx 1 anyway).
				ScoreVec		= 1/(d.n) * quadcolsum( centerpartial(d.Xp,d.mvecp,d.cons,d.Xnp,d.mvecnp,d.pihat) :* g ) * 1/sqrt(mean(g:^2))
			}
		}
			
		// Now create blank full-size score vector for all X variables.
		FullScoreVec					= J(1,cols(*d.X),0)
		// Then insert values in appropriate columns.
		FullScoreVec[1,(d.selindXp)]	= ScoreVec
		sim[j,1]						= max(abs(FullScoreVec:/ScoreStdVec))
	}

	return(sim)
}

// Score standardization vector:
// 1. Standard lasso + homosked = SD(x)*rmse
// 2. Sqrt lasso + homosked = SD(x)
// Robust versions are in the same metric.
real rowvector MakeScoreStdVec(								///
								struct dataStruct scalar d,	///
								real colvector v,			///
								real scalar rmse,			///
								real scalar hetero,			///
								|							///
								real scalar nclust1,		///
								real scalar center,			///
								real scalar sqrtflag		///
								)
{

	if (args()<5)	nclust1		= 0							//  default value of 0 serves as boolean below
	if (args()<6)	center		= 0
	if (args()<7)	sqrtflag	= 0

	real rowvector ScoreStd									//  will be partialled-out version with zero penalties inserted

	if (d.nclust==0) {										//  no cluster dependence
		if (hetero==0) {									//  homoskedastic
			if (sqrtflag) {
				// sqrt-lasso case
				ScoreStd = d.sdvecpnp
			}
			else {
				// standard case
				ScoreStd = d.sdvecpnp*rmse
			}
		}
		else {
			// heteroskedastic case
			St = J(1,cols(*d.X),0)
			if (center) {		
				// centerpartial(.) returns Xp demeaned and with Xnp partialled-out.
				centervec =	mean( centerpartial(d.Xp,d.mvecp,d.cons,d.Xnp,d.mvecnp,d.pihat) :* v)
				St[1,(d.selindXp)] = quadcolsum( ( (centerpartial(d.Xp,d.mvecp,d.cons,d.Xnp,d.mvecnp,d.pihat) :* v) :- centervec ):^2 )
			}
			else {
				St[1,(d.selindXp)] = quadcolsum( ( (centerpartial(d.Xp,d.mvecp,d.cons,d.Xnp,d.mvecnp,d.pihat) :* v)              ):^2 )
			}
			if (sqrtflag) {
				// sqrt-lasso version
				ScoreStd = sqrt(St/d.n) * 1/rmse
			}
			else {
				ScoreStd = sqrt(St/d.n)
			}
		}
	}
	else {													//  cluster dependence
		// relevant n is #clusters
		info = panelsetup(*d.clustid, 1)
		// ScoreStdTemp is n x p. Each row has the cluster-sum of x_it*e_it for cluster i.
		// First create blank n x p matrix of zeros to be populated.
		ScoreStdTemp = J(d.nclust,cols(*d.X),0)
		// Now populate correct columns, leaving other as zeros (unpenalized).
		// centerpartial(.) returns Xp demeaned and with Xnp partialled-out.
		ScoreStdTemp[.,(d.selindXp)] = panelsum(centerpartial(d.Xp,d.mvecp,d.cons,d.Xnp,d.mvecnp,d.pihat):*(v*J(1,cols(*d.Xp),1)),info)
		//  center ScoreStdTemp
		if (center) {
			ScoreStdTemp = ScoreStdTemp - J(d.nclust,1,1)*quadcolsum(ScoreStdTemp)/d.nclust
		}
		//  Default approach is simply to divide by nobs = nclust*T in a balanced panel.
		//  A finite-sample adjustment as in CBH's lassoCluster is to divide by (nclust-1)*T.
		//  In an unbalanced panel, we achieve this with 1/nobs * nclust/(nclust-1).
		//  In a balanced panel, 1/nobs * nclust/(nclust-1) = 1/(nclust*T) * nclust/(nclust-1) = 1/((nclust-1)*T).
		if (nclust1) {									//  override default: divide by (nclust-1)*T
			ScoreStd = sqrt(quadcolsum(ScoreStdTemp:^2)/(d.n)*(d.nclust)/(d.nclust-1))
		}
		else {											//  default: simply divide by n = nobs*T
			ScoreStd = sqrt(quadcolsum(ScoreStdTemp:^2)/(d.n))
		}
		if (sqrtflag) {
			// sqrt-lasso version
			ScoreStd = ScoreStd * 1/rmse
		}
	}
	return(ScoreStd)
}
// end MakeScoreStdVec


real rowvector doSupScore(								///
							struct dataStruct scalar d,	///
							real scalar c,				///
							real scalar ssgamma,		///
							real scalar pminus,			///
							real scalar hetero,			///
							real scalar nclust1,		///
							real scalar center,			///
							|							///
							real scalar verbose,		///
							real scalar R,				///
							real scalar newseed,		///
							real scalar dotsflag,		///
							real scalar ssiidflag		///	undocumented option - override use of mult bootstrap
							)
{

	// defaults
	if (args()<8)	verbose = 0
	if (args()<9)	R = 500
	if (args()<10)	newseed = -1
	if (args()<11)	dotsflag = 0
	if (args()<12)	ssiidflag = 0
	// makes code more transparent
	sqrtflag		= 0

// ******* sup-score test stat ********** //
// Matlab code from BCH.
// Loop over jj values of aVec: assemble ynull (="eTemp") then calc SupScore for that jj ynull
// % Sup-Score Test
// aVec = (-.5:.001:1.5)';
// SupScore = zeros(size(aVec));
// for jj = 1:size(aVec,1)
//     aT = aVec(jj,1);
//     eTemp = My-Md*aT;
//     ScoreVec = eTemp'*Mz;
//     ScoreStd = sqrt((eTemp.^2)'*(Mz.^2));
//     ScaledScore = ScoreVec./(1.1*ScoreStd);
//     SupScore(jj,1) = max(abs(ScaledScore));
// end
//
// hdm rlasso R code:
//     object$supscore <- sqrt(n)*max(abs(colMeans(object$model*as.vector(object$dev))))

// ******* sup-score crit values ********** //
// Following rlasso code:
//   object$supscore <- sqrt(n)*max(abs(colMeans(object$model*as.vector(object$dev))))
//    R <- 500
//    stat <- vector("numeric", length=R)
//    for (i in 1:R) {
//      g <- rnorm(n)
//      dev.g <- as.vector(g*object$dev)
//      mat <- object$model*dev.g
//      stat[i] <- sqrt(n)*max(abs(colMeans(mat)))
//    }
//    object$pvalue <- sum(stat>object$supscore)/R

	// First generate v = epsilon under H0: all betas=0, after partialling out constant and unpenalized vars.
	// rmse is just mean v^2.
	if (d.cons) {
		// standard case - y is demeaned and standardized
		if (d.np) {
			v		= ((*d.y) :- d.ymvec) - (((*d.Xnp):-mean(*d.Xnp))*d.ypihat)
		}
		else {
			v		= (*d.y) :- d.ymvec
		}
		rmse	= d.ysdp
	}
	else if (d.dmflag) {
		// zero-mean data and no constant is present in the model
		// means are zero vectors, cross-prods don't need demeaning, SDs don't need demeaning
		if (d.np) {
			v		= (*d.y)-(*d.Xnp)*d.ypihat
		}
		else {
			v		= *d.y
		}
		rmse	= d.ysdp
	}
	else {
		// model has no constant but means may be nonzero
		if (d.np) {
			v		= centerpartial(d.y,d.ymvec,d.cons,d.Xnp,d.mvecnp,d.ypihat)						///
						:- mean(centerpartial(d.y,d.ymvec,d.cons,d.Xnp,d.mvecnp,d.ypihat))
		}
		else {
			v		= *d.y
		}
		rmse	= sqrt(mean(v:^2))
	}

	// *** supscore statistic *** //
	// NB: can't use quadcross or mean with code below because a column can have (all) missing (e.g. if std dev=0).
	//     and quadcross and mean use rowwise deletion (all missing => all rows dropped!)
	//     use 1/n * quadcolsum instead
	// Create the score standardization vector. Dim = 1 x p with zeros for unpenalized Xs.
	ScoreStdVec	= MakeScoreStdVec(d,v,rmse,hetero,nclust1,center,sqrtflag)
	// Create the unstandardized score vector. Unpenalized vars only.
	ScoreVec	= 1/(d.n) * quadcolsum( centerpartial(d.Xp,d.mvecp,d.cons,d.Xnp,d.mvecnp,d.pihat) :* v )
	// Now create blank full-size score vector for all X variables.
	FullScoreVec					= J(1,cols(*d.X),0)
	// Then insert values in appropriate columns.
	FullScoreVec[1,(d.selindXp)]	= ScoreVec
	// Sup-score statistic
	supscore						= sqrt(d.n)*max(abs(FullScoreVec:/ScoreStdVec))

	// *** supscore pvalue/critical value *** //
	if (ssiidflag)	multbs	= 0		// override use of multiplier bootstrap for iid case
	else			multbs	= 1		// always use multiplier bootstrap for supscore unless overridden
	// simulate distribution of the maximal element of the score vector
	// returns a colvector with R obs from the simulated distribution
	sim = sqrt(d.n)*SimMaxScoreDist(d,v,rmse,ScoreStdVec,multbs,hetero,verbose,R,newseed,dotsflag,sqrtflag)
	supscore_pvalue = sum(supscore:<sim)/R
	supscore_critvalue	=c*invnormal(1-ssgamma/(2*((d.p)-pminus)))
	
	res = (supscore, supscore_pvalue, supscore_critvalue, ssgamma)
	return(res)
}


struct outputStruct scalar RSqrtLasso(						/// Mata code for BCH sqrt rlasso
							struct dataStruct scalar d,		/// data
							real scalar hetero,				/// homosk or heteroskedasticity?
							real scalar xdep,				/// X-dependent or independent?
							real scalar R,					/// number of simulations with xdep
							real scalar lassoPsiflag,		/// use lasso or post-lasso residuals for estimating penalty loadings?
							real scalar optTol,				///
							real scalar maxIter,			///
							real scalar zeroTol,			///
							real scalar maxPsiIter,			///
							real scalar PsiTol,				///
							real scalar verbose,			///
							real scalar c,					///
							real scalar c0,					///
							real scalar gamma,				///
							real scalar gammad,				///
							real scalar lambda0,			///
							real scalar lalt, 				///
							real scalar corrnumber,			///
							real scalar pminus,				///
							real scalar nclust1,			/// use #nclust-1 instead of #nclust in cluster-lasso
							real scalar center,				/// center x_i*e_i or x_ij*e_ij in cluster-lasso
							real scalar supscoreflag,		///
							real scalar ssnumsim,			///
							real scalar ssgamma,			///
							real scalar newseed,			///
							real scalar dotsflag			///
							)
{

	struct outputStruct scalar betas

	sqrtflag	= 1		// easier to keep track of in arguments to functions

	if (gammad<=0) {										//  not user-provided, so set here
		if (d.nclust==0)	gammad=log(d.n)					//  not cluster-lasso so #obs=n
		else				gammad=log(d.nclust)			//  cluster-lasso so #obs=nclust
	}
	if (gamma<=0) {											//  not user-provided, so set here
		gamma	= 0.1/gammad
	}

	iter	= 1
	if (verbose>=1) {
		printf("Obtaining penalty level/loadings: Step %f.\n",iter)
	}

	if (hetero | d.nclust) {
		if (corrnumber>=0) {
			// corrnumber specified so use initial residuals for initial loadings
			v		= InitialResiduals(d,corrnumber)
			s1		= sqrt(mean(v:^2))
			Psi		= MakeScoreStdVec(d,v,s1,hetero,nclust1,center,1)
			Psi		= (Psi :< d.sdvecpnp):*d.sdvecpnp + (Psi :>= d.sdvecpnp):*Psi
		}
		else {
			// corrnumber=-1 indicates use initial penalty loadings = colmax(abs(X)) as per BCW 2014 p. 769
			// Psi vector with zeros; cols corresponding to penalized vars updated below
			Psi		= J(1,cols(*d.X),0)
			if (d.nclust) {
				// initial loadings = colmax of panel means of abs(X)
				info					= panelsetup(*d.clustid, 1)
				psum					= panelsum(abs(centerpartial(d.Xp,d.mvecp,d.cons,d.Xnp,d.mvecnp,d.pihat)),info)
				pmean					= psum :/ (info[.,2]-info[.,1]:+1)
				Psi[1,(d.selindXp)]		= colmax(pmean)
			}
			else {
				// initial loadings = colmax(abs(X))
				Psi[1,(d.selindXp)]		= colmax(abs(centerpartial(d.Xp,d.mvecp,d.cons,d.Xnp,d.mvecnp,d.pihat)))
			}
			v		= .
			s1		= .
		}
	}
	else {
		// homoskedasticity: initial penalty loadings = vector of 1s after standardization
		Psi		= d.sdvecpnp
		v		= .
		s1		= .
	}

	// initialize lambda
	if (lambda0) {
		// user-supplied lambda0
		lambda=lambda0
	}
	else if ((xdep) & (hetero | d.nclust)) {
		// x-dep and inid => initial lambda is simple plug-in rather than simulated
		// 0 arg forces non-xdep.
		lambda=lambdaCalc(d,pminus,gamma,c,R,hetero,0,v,s1,Psi,lalt,newseed,dotsflag,verbose,sqrtflag)
	}
	else if (hetero | d.nclust) {
		// initial lambda if iterating penalty loadings; uses c0
	 	lambda=lambdaCalc(d,pminus,gamma,c0,R,hetero,xdep,v,s1,Psi,lalt,newseed,dotsflag,verbose,sqrtflag)
	}
	else {
		// lambda for iid case
	 	lambda=lambdaCalc(d,pminus,gamma,c,R,hetero,xdep,v,s1,Psi,lalt,newseed,dotsflag,verbose,sqrtflag)
	}
 
	if ((hetero==0) & (d.nclust==0)) {
		// homoskedasticity. No iteration necessary, even for x-dep.
		if (verbose>=1) {
			printf("Obtaining sqrt-lasso estimate...\n")
		}
		betas = DoSqrtLasso(d, Psi, lambda, verbose, optTol, maxIter, zeroTol)
		if (verbose>=1) {
			printf("Selected variables: %s\n\n",invtokens(betas.nameXSel'))
		}

	}
	else {
		// heteroskedasticity or clustering

		// get first lasso estimate based on initial lambda/loadings
		if (verbose>=1) {
			printf("Obtaining initial sqrt-lasso estimate...\n")
		}
		betas = DoSqrtLasso(d, Psi, lambda, verbose, optTol, maxIter, zeroTol)
		if (verbose>=1) {
			printf("Selected variables: %s\n\n",invtokens(betas.nameXSel'))
		}

		// initialize Delta
		Delta = 1e10

		while ((iter < maxPsiIter) & (Delta > PsiTol)) {

			if (verbose>=1) {
				printf("Estimation of penalty level/loadings: Step %f.\n",iter)
			}

			// old rmse (will be missing in iteration #1)
			s0		= s1
			// obtain residuals; based on betas(Psi)
			if (lassoPsiflag) {
				v	= betas.v		// lasso residuals
				s1	= betas.rmse 
			}
			else {
				v	= betas.vPL		// post-lasso residuals
				s1	= betas.rmsePL
			}
			// change in RMSE				
			Delta	= abs(s1-s0)

			// Psi update; last arg is sqrtflag
			// =max(Psi,1), see Alg 1 in Ann of Stat
			// but since X isn't pre-standardized, need to compare to standardization vector instead of unit vector
			// nb: this the the std vector after partialling and with zeros in place of the zero-pen variables
			Psi		= MakeScoreStdVec(d,v,s1,hetero,nclust1,center,1)
			Psi		= (Psi :< d.sdvecpnp):*d.sdvecpnp + (Psi :>= d.sdvecpnp):*Psi
			// xdep lambda update
			if (xdep) {
				lambda	= lambdaCalc(d,pminus,gamma,c,R,hetero,xdep,v,s1,Psi,lalt,newseed,dotsflag,verbose,1)
			}
			
			// Reporting
			if (verbose>=1) {
				printf("RMSE: %f\n",s1)
				printf("Change in RMSE: %f\n",Delta)
				printf("Obtaining new sqrt-lasso estimate...\n")
			}

			// new lasso estimate
			betas = DoSqrtLasso(d, Psi, lambda, verbose, optTol, maxIter, zeroTol)
			if (verbose>=1) {
				printf("Selected variables: %s\n\n",invtokens(betas.nameXSel'))
			}
		
			iter++

		}
		
		// when iteration concludes, final estimated betas consistent with (have used) final Psi and lambda.

		if (verbose>=1) {
			printf("Number of penalty loading iterations: %g\n",iter)
			if (iter == maxPsiIter) {
				printf("Warning: reached max penalty loading iterations w/o achieving convergence.\n")
			}
			else {
				printf("Penalty loadings (upsilon) convergence achieved.\n")
			}
		}

	}

	// sup-score stat
	if (supscoreflag) {
		betas.supscore	= doSupScore(d, c, gamma, pminus, hetero, nclust1, center, verbose, ssnumsim, newseed, dotsflag)
	}

	// Misc
	betas.n			= d.n
	betas.nclust	= d.nclust
	betas.npsiiter	= iter
	betas.sPsi		= betas.Psi :/ d.sdvecpnp		//  should be =1 under homosk.
	betas.sPsi		= editmissing(betas.sPsi,0)		//  in case any unpenalized (div by 0)
	betas.lambda0	= lambda						//  no diff between lambda and lambda0 with sqrt lasso
	betas.slambda	= lambda						//  no diff between lambda and std lambda with sqrt lasso
	betas.c			= c
	betas.gamma		= gamma
	betas.gammad	= gammad
	
	return(betas)

}
// end RSqrtLasso	


void EstimateLassoPath(							///  Complete Mata code for lassopath
				string scalar nameY,			///
				string scalar nameX,			///
				string scalar nameX_o,			///
				string scalar notpen_o,			///
				string scalar notpen_t,			///
				string scalar toest,			///
				string scalar holdout, 			/// validation data
				real scalar cons,				///
				real scalar dmflag,				///
				real scalar prestdflag,			///
				string scalar lambdamat,		/// single, list or missing (=> construct default list)
				real scalar lmax, 				///
				real scalar lcount,				///
				real scalar lminratio,			///
				real scalar lglmnet,			///
				string scalar PsiMat,			/// 
				string scalar stdymat,			/// 
				string scalar stdxmat,			///
				real scalar stdl, 				/// standardisation loadings?
				real scalar sqrtflag,			/// lasso or sqrt-lasso?
				real scalar alpha,				///
				real scalar post, 				///
				real scalar optTol,				///
				real scalar maxIter,			///
				real scalar zeroTol,			///
				real scalar verbose,			///
				real scalar stdcoef,			///
				real scalar noic, 				///
				real scalar ebicgamma			///
				)
{

	struct dataStruct scalar d
	d = MakeData(nameY,nameX,nameX_o,toest,cons,dmflag,prestdflag,stdymat,stdxmat)
	// p = cols(d.sdvec)
	
	// Estimation accommodates pre-standardized data and standardization on-the-fly.
	// Pre-standardized: lambdas and penalty loadings the same for L1 and L2 norms.
	// Standardization on-the-fly: standardization included in penalty loadings;
	//   L1 and L2 norm lambdas and penalties differ.
	
	if (PsiMat!="") {				//  overall pen loadings supplied
		Psi = st_matrix(PsiMat)
		Psi2 = Psi
	}
	else if (stdl) {				//  std loadings - standardize on the fly
		Psi = d.sdvec				//  L1 norm loadings - SDs
		Psi2 = d.varvec				//  L2 norm loadings - variances
	}
	else {
		// Psi = J(1,p,1)				//  default is 1
		Psi = J(1,d.p,1)				//  default is 1
		Psi2 = Psi
	}
	
	//  need to set loadings of notpen vars = 0
	if (notpen_o~="") {	
		npnames=tokens(notpen_o)
		forbound = cols(npnames)	//  faster
		for (i=1; i<=forbound; i++) {
				Psi		=Psi  :* (1:-(d.nameX_o:==npnames[1,i]))
				Psi2	=Psi2 :* (1:-(d.nameX_o:==npnames[1,i]))
		}
	}
	
	if (lambdamat=="") {
		if (lmax<=0) { // no lambda max given
			if (sqrtflag) {
				lmax = max(abs((d.Xy)):/((Psi)')) 
			}
			else {
				// see Friedman et al (J of Stats Software, 2010)  
				lmax = max(abs((d.Xy)):/((Psi)'))*2/max((0.001,alpha)) 
			}
		}
		lmin = lminratio*lmax
		lambda=exp(rangen(log(lmax),log(lmin),lcount))'
		lambda2=lambda
	} 
	else {
		lambda=st_matrix(lambdamat)
		lambda2=lambda
		if ((d.prestdflag) & (!sqrtflag)) {		//  data have been pre-standardized, so adjust lambdas accordingly
			// lambda	=lambda * 1/(d.ysd)
			lambda		=lambda * 1/(d.prestdy)
		}
		if (lglmnet) {
			lambda=lambda*2*d.n
		}
	}


	if ((cols(lambda)==1) & (!hasmissing(lambda))) {				//  one lambda
		struct outputStruct scalar OUT
		if (sqrtflag) {
			OUT = DoSqrtLasso(d,Psi,lambda,verbose,optTol,maxIter,zeroTol)
		}
		else {
			OUT = DoLasso(d,Psi,Psi2,lambda,lambda2,verbose,optTol,maxIter,zeroTol,alpha,lglmnet)
		}
		ReturnResults(OUT,d,sqrtflag,stdcoef)
	}
	else if ((cols(lambda)>1) & (!hasmissing(lambda))) {		//  lambda is a vector or missing (=> default list)
		struct outputStructPath scalar OUTPATH
		if (sqrtflag) {
			OUTPATH = DoSqrtLassoPath(d,Psi,lambda,post,verbose,optTol,maxIter,zeroTol)
		}
		else {
			OUTPATH = DoLassoPath(d,Psi,Psi2,lambda,lambda2,post,verbose,optTol,maxIter,zeroTol,alpha,lglmnet,noic)
		}
		ReturnResultsPath(OUTPATH,d,nameX_o,sqrtflag,stdcoef)
		if (holdout!="") { // used for cross-validation
			// getMSPE(OUTPATH,nameY,nameX,holdout,d.prestdflag,d.ysd)  
			getMSPE(OUTPATH,nameY,nameX,holdout,d)  
		}
		else if (!noic) { // calculate IC 
			getInfoCriteria(OUTPATH,d,sqrtflag,ebicgamma)
		}
	}
}
// end EstimateLassoPath

struct outputStruct scalar DoLasso(								///
							struct dataStruct scalar d,			/// data (y,X)
							real rowvector Psi,					///	penalty loading vector (L1 norm)
							real rowvector Psi2,				///	penalty loading vector (L2 norm)
							real scalar lambda,					/// lambda (single value) (L1 norm)
							real scalar lambda2,				/// lambda (single value) (L2 norm)
							real scalar verbose,				/// reporting
							real scalar optTol,					/// convergence of beta estimates
							real scalar maxIter,				/// max number of shooting iterations
							real scalar zeroTol, 				/// tolerance to set coefficient estimates to zero
							real scalar alpha, 					/// elastic net parameter
							| real scalar lglmnet					/// 1= use lambda definition from glmnet
							)
{

	struct outputStruct scalar t

	if (args()<=10) lglmnet = 0

	p = cols(*d.X)
	n = rows(*d.X)
	
	XX = d.XX
	Xy = d.Xy

	if (verbose>=1) {
		avgPsi=sum(abs(Psi))/sum(Psi:>0)
		printf("Lambda: %f\nAverage abs. loadings: %f\n", lambda,avgPsi)
	}

	beta_init=luqrsolve(XX+lambda2/2*diag(Psi2),Xy)
	beta=beta_init
	if (verbose==2){
		w_old = beta
		k=1
		wp = beta
		if (alpha==1) {
			// lasso verbose output
			printf("%8s %8s %10s %14s %14s\n","iter","shoots","n(w)","n(step)","f(w)")
		}
		else {
			// elastic net verbose output
			printf("%8s %8s %10s %14s %14s %14s %14s\n","iter","shoots","n1(w)","n1(step)","n2(w)","n2(step)","f(w)")
		}
	}

	m=0
	XX2=XX*2
	Xy2=Xy*2

	// Separate blocks for lasso, ridge, elastic net.
	// Separate lambdas and penalty loadings for L1 and L2 norms to accommodate standardization.
	// If data are pre-standardized, then lambda=lambda2 and Psi=Psi2.
	// If standardization is on-the-fly and incorporated in penalty loadings,
	// then lambdas and penalty loadings for L1 and L2 norms are different.
	while (m < maxIter)
	{
		beta_old = beta
		for (j = 1;j<=p;j++)
		{
			S0 = quadcolsum(XX2[j,.]*beta) - XX2[j,j]*beta[j] - Xy2[j]

			if (alpha==1) {					//  lasso
				if (S0 > lambda*Psi[j])
				{
					// beta[j,1] = (lambda*Psi[1,j] - S0)/(XX2[j,j])
					beta[j] = (lambda*Psi[j] - S0)/(XX2[j,j])
				}
				else if (S0 < -lambda*Psi[j])	
				{
					// beta[j,1] = (-lambda*Psi[1,j] - S0)/(XX2[j,j]) 
					beta[j] = (-lambda*Psi[j] - S0)/(XX2[j,j]) 
				}
				else 
				{
					// beta[j,1] = 0
					beta[j] = 0
				}
			}								//  end lasso
			else if (alpha>0) {				//  elastic net
				if (S0 > lambda*Psi[j]*alpha)
				{
					// beta[j,1] = (lambda*Psi[1,j]*alpha - S0)/(XX2[j,j] + lambda2*Psi2[1,j]*(1-alpha))
					beta[j] = (lambda*Psi[j]*alpha - S0)/(XX2[j,j] + lambda2*Psi2[j]*(1-alpha))
				}
				else if (S0 < -lambda*Psi[j]*alpha)
				{
					// beta[j,1] = (-lambda*Psi[1,j]*alpha - S0)/(XX2[j,j] + lambda2*Psi2[1,j]*(1-alpha))
					beta[j] = (-lambda*Psi[j]*alpha - S0)/(XX2[j,j] + lambda2*Psi2[j]*(1-alpha))
				}
				else
				{
					// beta[j,1] = 0
					beta[j] = 0
				}
			}								//  end elastic net
			else if ((alpha==0) & (1)) {	//  ridge (DISABLED)
			
				//		shooting not required for ridge since closed-formed solution exists
				// 		and is equal to initial beta.
	
				if (S0 > 0)
				{
					// beta[j,1] = (-S0)/(XX2[j,j] + lambda2*Psi2[1,j])
					beta[j] = (-S0)/(XX2[j,j] + lambda2*Psi2[j])
				}
				else if (S0 < 0)	
				{
					// beta[j,1] = (-S0)/(XX2[j,j] + lambda2*Psi2[1,j]) 
					beta[j] = (-S0)/(XX2[j,j] + lambda2*Psi2[j]) 
				}
				else 
				{
					// beta[j,1] = 0
					beta[j] = 0
				}
			}								//  end ridge
		}									//  end j loop over components of beta

       	m++

		if (verbose==2)
			{
				if (alpha==1) {
					// lasso
					fobj	= mean( (((*d.y):-d.ymvec) - ((*d.X):-d.mvec)*beta):^2 )	///
								+ lambda/n*Psi*abs(beta)
					printf("%8.0g %8.0g %14.8e %14.8e %14.8e\n",						///
						m,																///
						m*p,															///
						colsum(abs(beta)),												///
						colsum(abs(beta-w_old)),										///
						fobj															///
						)
					w_old = beta
					k=k+1
					wp =(wp, beta)
				}
				else {
					// elastic net
					fobj	= mean( (((*d.y):-d.ymvec) - ((*d.X):-d.mvec)*beta):^2 )	///
								+ lambda/n *alpha    *Psi*abs(beta)						///
								+ lambda2/n*(1-alpha)*Psi*(beta:^2)
					printf("%8.0g %8.0g %14.8e %14.8e %14.8e %14.8e %14.8e\n",		///
						m,															///
						m*p,														///
						colsum(abs(beta)),											///
						colsum(abs(beta-w_old)),									///
						colsum(beta:^2),											///
						colsum(beta:^2-w_old:^2),									///
						fobj														///
						)
					w_old = beta
					k=k+1
					wp =(wp, beta)
				
				}
			}
    
		if (quadcolsum(abs(beta-beta_old))<optTol) break
	}
	
	if (verbose>=1)
	{
		printf("Number of iterations: %g\nTotal Shoots: %g\n",m,m*p)
		if (m == maxIter) {
			printf("Warning: reached max shooting iterations w/o achieving convergence.\n")
		}
		else {
			printf("Convergence achieved.\n")
		}
	}
	
	if (verbose==2) {
		printf("Initial beta and beta after estimation:\n")
		(beta_init'\beta')
	}	
	
	// convert lambda
	if (lglmnet) {
		lambda=lambda/2/n
	}
	
	// save results in t struct
	// following code should be the same in DoLasso() and DoSqrtLasso()
	
	t.niter = m

	// full vector
	t.betaAll = beta
	
	// compare initial beta vs estimated beta
	//(beta,beta_init)

	t.index = abs(beta) :> zeroTol
	s = sum(abs(beta) :> zeroTol) // number of selected vars, =0 if no var selected
	
	// reduce beta vector to only non-zero coeffs
	if (s>0) {
		t.beta = select(beta,t.index)
	}
	else {
		t.beta = .
	}
	
	// obtain post-OLS estimates
	if ((s>0) & (s<n) & (d.cons==0)) {
		// data are zero mean or there is no constant
		betaPL			= qrsolve(select(*d.X,t.index'),*d.y)
	}
	else if ((s>0) & (s<n)) {
		// model has a constant
		betaPL			= qrsolve((select(*d.X,t.index'):-select(d.mvec,t.index')),(*d.y:-d.ymvec))
	}
	else if (s>0) {
		betaPL			= J(s,1,.)		// set post-OLS vector = missing if s-hat > n. 
	}
	else if (s==0) {
		betaPL			= .
	}
	t.betaPL = betaPL

	// obtain intercept
	if (d.cons==0) {
		// data are zero mean or there is no constant
		t.intercept 	= 0
		t.interceptPL	= 0
	}
	else if (s>0) {
		t.intercept		= mean(*d.y) - mean(select(*d.X,t.index'))*t.beta	//  something selected; obtain constant
		t.interceptPL	= mean(*d.y) - mean(select(*d.X,t.index'))*t.betaPL	// obtain constant
	}
	else {																	//  nothing selected; intercept is mean(y)
		t.intercept		= mean(*d.y)
		t.interceptPL	= mean(*d.y)
	}
	
	// "All" version of PL coefs
	t.betaAllPL = J(rows(beta),1,0)
	// need to look out for missing betaPL; if s=0 betaAllPL will just be a vector of zeros
	if (s>0) {
		t.betaAllPL[selectindex(t.index),1] = betaPL
	}

	// other objects
	if (s>0) {
		t.nameXSel	= select(d.nameX_o',t.index)
	}
	else {
		t.nameXSel	=""
	}
	t.Psi		= Psi
	t.lambda	= lambda
	t.cons		= d.cons
	t.n			= n
	t.beta_init	= beta_init
	t.s 		= s

	// obtain residuals
	if ((s>0) & (d.cons==0)) {
		// data are zero mean or there is no constant
		t.v		= *d.y - select(*d.X,t.index')*t.beta
		t.vPL	= *d.y - select(*d.X,t.index')*t.betaPL
	}
	else if (s>0) {
		// model has a constant
		t.v		= (*d.y:-d.ymvec) - (select(*d.X,t.index'):-select(d.mvec,t.index'))*t.beta
		t.vPL	= (*d.y:-d.ymvec) - (select(*d.X,t.index'):-select(d.mvec,t.index'))*t.betaPL
	}
	else if (d.cons==0) {
		// data are zero mean or no constant in model; nothing selected; residual is just y
		t.v		= *d.y
		t.vPL	= *d.y
	}
	else {
		// nothing selected; residual is demeaned y
		t.v		= (*d.y:-d.ymvec) 
		t.vPL	= (*d.y:-d.ymvec)
	}
	
	// RMSE
	t.rmse		=sqrt(mean(t.v:^2))
	t.rmsePL	=sqrt(mean(t.vPL:^2))
	
	// minimized objective function
	if (alpha==1) {
		// lasso
		t.objfn		= (t.rmse)^2 + lambda/d.n * quadcross(Psi',abs(beta))
	}
	else if (alpha==0) {
		// ridge
		t.objfn		= (t.rmse)^2
	}
	else {
		// elastic net
		t.objfn		= (t.rmse)^2											///
						+ lambda/d.n  *alpha    *quadcross(Psi',abs(beta))	///
						+ lambda2/d.n *(1-alpha)*quadcross(Psi2',beta:^2)
	}
	if (verbose>=1) {
		printf("Minimized objective function               : %f\n",t.objfn)
	}

	return(t)
}
// end DoLasso

struct outputStruct scalar DoSqrtLasso(							///
							struct dataStruct scalar d,			/// data (y,X)
							real rowvector Psi,					///	penalty loading vector
							real scalar lambda,					/// lambda (single value)
							real scalar verbose,				/// reporting
							real scalar optTol,					/// convergence of beta estimates
							real scalar maxIter,				/// max number of shooting iterations
							real scalar zeroTol					/// tolerance to set coefficient estimates to zero
							)
{

	struct outputStruct scalar t

	p = cols(*d.X)
	n = rows(*d.X)
	
	XX = d.XX
	Xy = d.Xy
	
	if (verbose>=1) {
		avgPsi=sum(abs(Psi))/sum(Psi:>0)
		printf("Lambda: %f\nAverage abs. loadings: %f\n", lambda,avgPsi)
	}

	beta_init=luqrsolve(XX+lambda*diag(Psi),Xy)
	beta=beta_init

	if (verbose==2){
		w_old = beta
		printf("%8s %8s %10s %14s %14s\n","iter","shoots","n(w)","n(step)","f(w)")
		k=1
		wp = beta
	}

	m=0
	XX=XX/n
	Xy=Xy/n

	// d.cons=1 if there is a constant, =0 otherwise.
	// Demeaning below throughout is needed only if a constant is present,
	// hence we multiply means by d.cons.
	ERROR = ((*d.y):-(d.ymvec*d.cons)) - ((*d.X):-(d.mvec*d.cons))*beta
	Qhat = mean(ERROR:^2)

	while (m < maxIter)
	{
		beta_old = beta
		for (j = 1;j<=p;j++)
		{
			S0 = quadcolsum(XX[j,.]*beta) - XX[j,j]*beta[j] - Xy[j]

			if ( abs(beta[j])>0 ) {
				ERROR = ERROR + ((*d.X)[.,j]:-(d.mvec*d.cons)[j])*beta[j]
				Qhat = mean(ERROR:^2)
			}
			
			if ( n^2 < (lambda * Psi[j])^2 / XX[j,j]) {
				beta[j] = 0
			}
			else if (S0 > lambda/n*Psi[j]*sqrt(Qhat))
			{
				beta[j]= ( ( lambda * Psi[j] / sqrt(n^2 - (lambda * Psi[j])^2 / XX[j,j] ) ) * sqrt(max((Qhat-(S0^2/XX[j,j]),0)))-S0)  / XX[j,j]
				ERROR = ERROR - ((*d.X)[.,j]:-(d.mvec*d.cons)[j])*beta[j]
			}
			else if (S0 < -lambda/n*Psi[j]*sqrt(Qhat))	
       		{
				beta[j]= ( - ( lambda * Psi[j] / sqrt(n^2 - (lambda * Psi[j])^2 / XX[j,j] ) ) * sqrt(max((Qhat-(S0^2/XX[j,j]),0)))-S0)  / XX[j,j]
				ERROR = ERROR - ((*d.X)[.,j]:-(d.mvec*d.cons)[j])*beta[j]
           	}
       		else 
			{
       			beta[j] = 0
			}
		}

		ERRnorm=sqrt( quadcolsum( (((*d.y):-(d.ymvec*d.cons))-((*d.X):-(d.mvec*d.cons))*beta):^2 ) )
		// sqrt-lasso objective function
		fobj = ERRnorm/sqrt(n) + (lambda/n)*Psi*abs(beta)
		
		if (ERRnorm>1e-10) {
			aaa = (sqrt(n)*ERROR/ERRnorm)
			dual = aaa'((*d.y):-(d.ymvec*d.cons))/n  - abs(lambda/n*Psi' - abs(((*d.X):-(d.mvec*d.cons))'aaa/n))'abs(beta)
		}
		else {
			dual = (lambda/n)*Psi*abs(beta)
		}
		
       	m++

		if (verbose==2) {
				printf("%8.0g %8.0g %14.8e %14.8e %14.8e\n",m,m*p,colsum(abs(beta)),colsum(abs(beta)),fobj)
				w_old = beta
				k=k+1
				wp =(wp, beta)
		}

		if (quadcolsum(abs(beta-beta_old))<optTol) {
			if (fobj - dual < 1e-6) {
				break
			}
		}
	}
	
	if (verbose>=1)
	{
		printf("Number of iterations: %g\nTotal Shoots: %g\n",m,m*p)
		if (m == maxIter) {
			printf("Warning: reached max shooting iterations w/o achieving convergence.\n")
		}
		else {
			printf("Convergence achieved.\n")
		}
	}

	// save results in t structure
	// following code should be the same in DoLasso() and DoSqrtLasso()
	
	t.niter = m
	
	// full vector
	t.betaAll = beta

	t.index = abs(beta) :> zeroTol
	s = sum(abs(beta) :> zeroTol) // number of selected vars, =0 if no var selected
	
	// reduce beta vector to only non-zero coeffs
	if (s>0) {
		t.beta = select(beta,t.index)
	}
	else {
		t.beta = .
	}
	
	// obtain post-OLS estimates
	if ((s>0) & (s<n) & (d.cons==0)) {
		// data are zero mean or there is no constant
		betaPL			= qrsolve(select(*d.X,t.index'),*d.y)
	}
	else if ((s>0) & (s<n)) {
		betaPL			= qrsolve((select(*d.X,t.index'):-select(d.mvec,t.index')),(*d.y:-d.ymvec))
	}
	else if (s>0) {
		betaPL			= J(s,1,.)		// set post-OLS vector = missing if s-hat > n. 
	}
	else if (s==0) {
		betaPL			= .
	}
	t.betaPL = betaPL
	
	// obtain intercept
	if (d.cons==0) {
		// data are zero mean or there is no constant
		t.intercept 	= 0
		t.interceptPL	= 0
	}
	else if (s>0) {
		// model has a constant
		t.intercept		= mean(*d.y) - mean(select(*d.X,t.index'))*t.beta	//  something selected; obtain constant
		t.interceptPL	= mean(*d.y) - mean(select(*d.X,t.index'))*t.betaPL	 // obtain constant
	}
	else {																	//  nothing selected; intercept is mean(y)
		t.intercept		= mean(*d.y)
		t.interceptPL	= mean(*d.y)
	}
	
	// "All" version of PL coefs
	t.betaAllPL = J(rows(beta),1,0)
	// need to look out for missing betaPL; if s=0 betaAllPL will just be a vector of zeros
	if (s>0) {
		t.betaAllPL[selectindex(t.index),1] = betaPL
	}

	// other objects
	if (s>0) {
		t.nameXSel	= select(d.nameX_o',t.index)
	}
	else {
		t.nameXSel	=""
	}
	t.Psi		= Psi
	t.lambda	= lambda
	t.cons		= d.cons
	t.n			= n
	t.beta_init	= beta_init
	t.s 		= s

	// obtain residuals
	if ((s>0) & (d.cons==0)) {
		// data are zero mean or there is no constant
		t.v		= *d.y - select(*d.X,t.index')*t.beta
		t.vPL	= *d.y - select(*d.X,t.index')*t.betaPL
	}
	else if (s>0) {
		// model has a constant
		t.v		= (*d.y:-d.ymvec) - (select(*d.X,t.index'):-select(d.mvec,t.index'))*t.beta
		t.vPL	= (*d.y:-d.ymvec) - (select(*d.X,t.index'):-select(d.mvec,t.index'))*t.betaPL
	}
	else if (d.cons==0) {
		// data are zero mean or model has no constant; nothing selected; residual is just y
		t.v		= *d.y
		t.vPL	= *d.y
	}
	else {
		// nothing selected; residual is demeaned y
		t.v		= (*d.y:-d.ymvec) 
		t.vPL	= (*d.y:-d.ymvec)
	}
	
	// RMSE
	t.rmse		=sqrt(mean(t.v:^2))
	t.rmsePL	=sqrt(mean(t.vPL:^2))	

	// minimized objective function
	t.objfn		= fobj

	if (verbose>=1) {
		printf("Minimized objective function: %f\n",t.objfn)
	}
	
	return(t)

}
// end DoSqrtLasso


struct outputStructPath scalar DoSqrtLassoPath(	struct dataStruct scalar d,
												real rowvector Psi,
												real rowvector lvec,
												real scalar post, 
												real scalar verbose, 
												real scalar optTol,
												real scalar maxIter,
												real scalar zeroTol)
{

		struct outputStructPath scalar t

		p = cols(*d.X)
		n = rows(*d.X)
		
		XX = d.XX
		Xy = d.Xy
		
		lmax=max(lvec)
		lcount=cols(lvec)
		beta=luqrsolve(XX+lmax*diag(Psi),Xy) // beta start	
		
		XX=XX/n
		Xy=Xy/n

		lpath = J(lcount,p,.) // create empty matrix which stores coef path
		for (k = 1;k<=lcount;k++) { // loop over lambda
		
			lambda=lvec[1,k]
			
			//beta=lusolve(XX*n+lmax/2*diag(Psi),Xy*n)	
			// more stable than only one initial beta at the top
				
			m=0
				
			// d.cons=1 if there is a constant, =0 otherwise.
			// Demeaning below throughout is needed only if a constant is present,
			// hence we multiply means by d.cons.
			ERROR = ((*d.y):-(d.ymvec*d.cons)) - ((*d.X):-(d.mvec*d.cons))*beta
			Qhat = mean(ERROR:^2)

			while (m < maxIter)
			{
				beta_old = beta
				for (j = 1;j<=p;j++)
				{
					S0 = quadcolsum(XX[j,.]*beta) - XX[j,j]*beta[j] - Xy[j]

					if ( abs(beta[j])>0 ) {
						ERROR = ERROR + ((*d.X)[.,j]:-(d.mvec*d.cons)[j])*beta[j]
						Qhat = mean(ERROR:^2)
					}
					
					if ( n^2 < (lambda * Psi[j])^2 / XX[j,j]) {
						beta[j] = 0
					}
					else if (S0 > lambda/n*Psi[j]*sqrt(Qhat))
					{
						beta[j]= ( ( lambda * Psi[j] / sqrt(n^2 - (lambda * Psi[j])^2 / XX[j,j] ) ) * sqrt(max((Qhat-(S0^2/XX[j,j]),0)))-S0)  / XX[j,j]
						ERROR = ERROR - ((*d.X)[.,j]:-(d.mvec*d.cons)[j])*beta[j]
					}
					else if (S0 < -lambda/n*Psi[j]*sqrt(Qhat))	
					{
						beta[j]= ( - ( lambda * Psi[j] / sqrt(n^2 - (lambda * Psi[j])^2 / XX[j,j] ) ) * sqrt(max((Qhat-(S0^2/XX[j,j]),0)))-S0)  / XX[j,j]
						ERROR = ERROR - ((*d.X)[.,j]:-(d.mvec*d.cons)[j])*beta[j]
					}
					else 
					{
						beta[j] = 0
					}
				}

				ERRnorm=sqrt( quadcolsum( (((*d.y):-(d.ymvec*d.cons))-((*d.X):-(d.mvec*d.cons))*beta):^2 ) )
				fobj = ERRnorm/sqrt(n) + (lambda/n)*Psi*abs(beta)
				
				if (ERRnorm>1e-10) {
					aaa = (sqrt(n)*ERROR/ERRnorm)
					dual = aaa'((*d.y):-(d.ymvec*d.cons))/n  - abs(lambda/n*Psi' - abs(((*d.X):-(d.mvec*d.cons))'aaa/n))'abs(beta)
				}
				else {
					dual = (lambda/n)*Psi*abs(beta)
				}
				
				m++

				if (quadcolsum(abs(beta-beta_old))<optTol) { 
					if (fobj - dual < 1e-6) {
						break
					}
				}
				//terminate = (quadcolsum(abs(beta-beta_old))<optTol)*((fobj - dual) < 1e-6)
			}
			lpath[k,.]=beta'
		}
		
		// following code should be the same for DoLassoPath() and DoSqrtLassoPath()
		
		lpath=edittozerotol(lpath, zeroTol)
		
		if (post) { 
			betasPL = J(lcount,p,0)
			nonzero0 = J(1,p,0)
			for (k = 1;k<=lcount;k++) { // loop over lambda points
				nonzero = lpath[k,.]:!=0  // 0-1 vector
				sk = sum(nonzero)			
				if ((0<sk) & (sk<n)) { // only if 0<s<n
					if ((nonzero0==nonzero) & (k>=2)) { // no change in active set
						betasPL[k,.] = betasPL[k-1,.]
					}
					else { 
						ix = selectindex(nonzero)	// index of non-zeros
						// obtain beta-hat
						if (d.cons==0) {
							// data are mean zero or no constant in model so cross-products don't demean
							betak=qrsolve(select((*d.X),nonzero),(*d.y))
						}
						else {
							betak=qrsolve(select((*d.X),nonzero):-select(d.mvec,nonzero),((*d.y):-d.ymvec))
						}
						betasPL[k,ix] = betak'
						nonzero0=nonzero
					}
				}
			}
			t.betas 		= betasPL	
		}
		else {
			t.betas 		= lpath
		}
		
		t.lambdalist	= lvec'
		t.Psi			= Psi
		if (d.cons==0) {
			// no constant or zero-mean data
			t.intercept	= 0
		}
		else {
			t.intercept	= mean(*d.y):-mean((*d.X))*(t.betas')
		}
		t.cons 			= d.cons
		
		// sqrt-lasso df
		t.shat	= quadrowsum(t.betas:!=0) :+ (d.cons | d.dmflag)
		t.dof 	= t.shat
				
		return(t)		
		
}
// end DoSqrtLassoPath


void ReturnResults(		struct outputStruct scalar t,		///
						struct dataStruct scalar d,			///
						|									///
						real scalar sqrtflag,				///
						real scalar stdcoef					///
						)
{
	// default values
	if (args()<=2) sqrtflag = 0
	if (args()<=3) stdcoef = 0

	if (rows(t.betaAll)) {					// estimation results to insert

		// initialize from results struct
		s			= t.s					// all vars in param vector incl notpen but EXCL constant
		k			= t.s+t.cons			// all vars in param vector incl notpen PLUS constant
		betaAll		= t.betaAll
		betaAllPL	= t.betaAllPL
		Psi			= t.Psi
		ePsi		= t.Psi					// rlasso only
		sPsi		= t.sPsi
		rmse		= t.rmse
		rmsePL		= t.rmsePL
		lambda		= t.lambda
		objfn		= t.objfn
		// initialize from data struct
		AllNames	= d.nameX_o'			// d.nameX_o is a row vector; AllNames is a col vector (to match coef vectors)

		// un-standardize unless overridden by stdcoef
		if (d.prestdflag & stdcoef==0) {
			betaAll		= betaAll		:/ d.prestdx' * d.prestdy	//  beta is col vector, prestdx is row vector, prestdy is scalar
			betaAllPL	= betaAllPL		:/ d.prestdx' * d.prestdy	//  beta is col vector, prestdx is row vector, prestdy is scalar
			ePsi		= ePsi			:* d.prestdx				//  rlasso only; ePsi and prestsdx both row vectors; Psi does not change
			rmse		= rmse			* d.prestdy
			rmsePL		= rmsePL		* d.prestdy
			if (sqrtflag==0) {
				// lasso => objfn is pmse
				objfn	= objfn			* (d.prestdy)^2
			}
			else {
				// sqrt lasso => objfn is prmse
				objfn	= objfn			* d.prestdy
			}
			if (sqrtflag==0) {										//  sqrt-lasso lambdas don't need unstandardizing
				lambda	= lambda		* d.prestdy
			}
		}

		if (t.cons) {											//  pre-standardized means no constant
			intercept	= t.intercept
			interceptPL	= t.interceptPL
		}
		if (s>0) {												//  do here so that we select from std/unstd vector
			beta		= select(betaAll,t.index)
			betaPL		= select(betaAllPL,t.index)
			Names		= select(AllNames,t.index)
		}
		else {
			beta		= .
			betaPL		= .
			Names		= ""
		}
	
		if ((s>0) & (t.cons)) {									//  add constant to end of vectors
			beta		= (beta			\ intercept)		
			betaPL		= (betaPL		\ interceptPL)	
			betaAll		= (betaAll		\ intercept)		
			betaAllPL	= (betaAllPL	\ interceptPL)	
			NamesCons	= (Names		\ "_cons")
			AllNamesCons= (AllNames 	\ "_cons")
		}
		else if ((s>0) & (!t.cons)) {							//  coef vectors already OK, just need names with _cons
			NamesCons	= Names
			AllNamesCons= AllNames
		}
		else if ((s==0) & (t.cons)) {
			beta		= intercept						
			betaPL		= interceptPL					
			NamesCons	= "_cons"
			AllNamesCons= (AllNames 	\ "_cons")
			betaAll		= (betaAll		\ intercept)			//  will be all zeros + intercept at end
			betaAllPL	= (betaAllPL	\ interceptPL)	
		}
		else {
			beta		= .					
			betaPL		= .				
			NamesCons	= ""
			AllNamesCons= AllNames
			betaAll		= betaAll								//  will be all zeros
			betaAllPL	= betaAllPL
		}

		st_rclear() 
		if ((s > 0) | (t.cons)) {
			// matrix stripes
			coln		=(J(rows(Names),1,""),Names)			//  Names is a col vector so need #rows
			colnCons	=(J(rows(NamesCons),1,""),NamesCons)	//  Names is a col vector so need #rows
			// row vector of names
			st_global("r(sel)",invtokens(Names'))				//  selected vars exclude cons but here may include notpen
			// column vectors
			st_matrix("r(b)",beta)
			st_matrix("r(bOLS)",betaPL)
			st_matrixrowstripe("r(b)",colnCons)
			st_matrixrowstripe("r(bOLS)",colnCons)
		}
		
		// matrix stripe
		AllcolnCons=(J(rows(AllNamesCons),1,""),AllNamesCons)
		// column vectors
		st_matrix("r(bAll)",betaAll)
		st_matrix("r(bAllOLS)",betaAllPL)
		st_matrixrowstripe("r(bAll)",AllcolnCons)
		st_matrixrowstripe("r(bAllOLS)",AllcolnCons)
	
		// matrix stripe
		coln=(J(rows(AllNames),1,""),AllNames)
		// row vectors
		st_matrix("r(stdvec)",d.sdvec)
		st_matrix("r(Psi)",Psi)
		st_matrix("r(ePsi)",ePsi)						//  rlasso only
		st_matrixcolstripe("r(stdvec)",coln)
		st_matrixcolstripe("r(Psi)",coln)
		st_matrixcolstripe("r(ePsi)",coln)				//  rlasso only
	
		if ((cols(sPsi)>0) & (cols(sPsi)<.)) {			//  "cols(t.sPsi)<." may be unnecessary - if missing, cols(.) = 0.
			st_matrix("r(sPsi)",sPsi)
			st_matrix("r(stdvecpnp)",d.sdvecpnp)
			st_matrixcolstripe("r(sPsi)",coln)
			st_matrixcolstripe("r(stdvecpnp)",coln)
		}
		
		st_matrix("r(beta_init)",t.beta_init)
	}

	// BCH stat, p-value, crit-value, signif; rlasso stat, p-value
	if (cols(t.supscore)) {
		st_matrix("r(supscore)",t.supscore)
		coln=(J(4,1,""),("CCK_ss" \ "CCK_p" \ "CCK_cv" \ "CCK_gamma"))
		st_matrixcolstripe("r(supscore)",coln)
	}
	
	// Can always return these; scalars will just be missing
	st_numscalar("r(lambda)",lambda)
	st_numscalar("r(rmse)",rmse)
	st_numscalar("r(rmsePL)",rmsePL)
	st_numscalar("r(objfn)",objfn)
	st_numscalar("r(s)",s)
	st_numscalar("r(k)",k)
	st_numscalar("r(lcount)",1)
	st_numscalar("r(lambda0)",t.lambda0)
	st_numscalar("r(slambda)",t.slambda)
	st_numscalar("r(c)",t.c)
	st_numscalar("r(gamma)",t.gamma)
	st_numscalar("r(gammad)",t.gammad)
	st_numscalar("r(N)",t.n)
	st_numscalar("r(N_clust)",t.nclust)
	st_numscalar("r(niter)",t.niter)
	st_numscalar("r(npsiiter)",t.npsiiter)
	
}
// end ReturnResults

real matrix getMinIC(real matrix IC)		//  =0 if nothing to partial out, =projection coefs if Zs.
{
 		licid=.
 		minindex(IC,1,licid,.)	// returns index of lambda that minimises ic
 		if (rows(licid)>1) {    // no unique lopt 
 			licid=licid[1,1] 	
 			icmin=IC[1,licid]
 			licunique=0
 		}
 		else {
 			icmin=IC[1,licid]
 			licunique=1
 		}
 	R = (licid,icmin,licunique)
	return(R)
}
// end get minimum IC

void getInfoCriteria(struct outputStructPath scalar t,
 			struct dataStruct scalar d,
			real scalar sqrtflag, 
			real ebicgamma)
{		
		// t.betas is lcount by p	
		// t.dof is 1 by lcount

 		XB  = quadcross((*d.X)',(t.betas)') :+ t.intercept 	// n by lcount
		
 		TSS = quadcolsum(((*d.y):-(d.ymvec)):^2)	// 1 by lcount
 		ESS = quadcolsum(((XB) :-(d.ymvec)):^2)	 	
		RSS = quadcolsum(((*d.y) :-(XB)):^2)
		if ((d.prestdflag) & (!sqrtflag)) {	
			TSS=TSS*(d.prestdy)^2
			ESS=ESS*(d.prestdy)^2
			RSS=RSS*(d.prestdy)^2
		}
		RSQ =1:-RSS:/TSS
		
		// ebic parameter
		// default choice is based on P=n^kappa and gamma=1-1/(2*kappa)
		// see Chen & Chen (2008, p. 768, Section 5)
		if ((ebicgamma<0) | (ebicgamma>1)) {
			ebicgamma = 1-log(d.n)/(2*log(d.p))
			ebicgamma = max((ebicgamma,0)) // ensures that ebicgamma are in [0,1]
			ebicgamma = min((ebicgamma,1))
		}

		// calculate aic and bic
		// For reference: in R the definitions would be
		// AIC = d.n + d.n*log(2*pi()) + d.n*log(RSS/d.n) + 2*(t.dof')
		// BIC = d.n + d.n*log(2*pi()) + d.n*log(RSS/d.n) + log(d.n)*(t.dof')
		AIC		= d.n*log(RSS/d.n) + (t.dof')*2 
		BIC 	= d.n*log(RSS/d.n) + (t.dof')*log(d.n) 
		EBIC 	= BIC :+ 2 * (t.dof') * log(d.p) * ebicgamma
		AICC	= d.n*log(RSS/d.n) + (t.dof')*2:*((d.n):/(d.n:-t.dof'))
		
		// obtain minimum IC and obtimal lambda
		AICinfo =  getMinIC(AIC)
		BICinfo = getMinIC(BIC)
		EBICinfo = getMinIC(EBIC)
		AICCinfo = getMinIC(AICC)
		laicid=AICinfo[1,1]
		aicmin=AICinfo[1,2]
		lbicid=BICinfo[1,1]
		bicmin=BICinfo[1,2]
		lebicid=EBICinfo[1,1]
		ebicmin=EBICinfo[1,2]
		laiccid=AICCinfo[1,1]
		aiccmin=AICCinfo[1,2]
		
		st_matrix("r(dof)",t.dof)
		st_matrixcolstripe("r(dof)",("","Df"))
		// return 
 		st_matrix("r(rsq)",RSQ')				
 		st_matrix("r(tss)",TSS')				
		st_matrix("r(ess)",ESS')				
		st_matrix("r(rss)",RSS')	
		/// aic
		st_matrix("r(aic)",AIC')
		st_numscalar("r(aicmin)",aicmin)
		st_numscalar("r(laicid)",laicid)
		/// bic
		st_matrix("r(bic)",BIC')
		st_numscalar("r(bicmin)",bicmin)
		st_numscalar("r(lbicid)",lbicid)	
		/// ebic
		st_matrix("r(ebic)",EBIC')
		st_numscalar("r(ebicmin)",ebicmin)
		st_numscalar("r(lebicid)",lebicid)
		st_numscalar("r(ebicgamma)",ebicgamma)
		/// aicc
		st_matrix("r(aicc)",AICC')
		st_numscalar("r(aiccmin)",aiccmin)
		st_numscalar("r(laiccid)",laiccid)	
}
// end 


void getMSPE(struct outputStructPath scalar t,
								string scalar varY,
								string scalar varX, 
								string scalar holdout, // marks validation data set
								struct dataStruct scalar d)
{		
		// get beta matrix
		bhat=t.betas 		// lcount by p	
		
		// get validation data
		st_view(y0,.,varY,holdout)
		st_view(X0,.,varX,holdout) 	// n by p
		
		// predicted values
		X0B=quadcross(X0',bhat') 	// n by lcount
 		
		// add intercepts
		if (t.cons) { 	
			X0B=X0B :+ t.intercept 	// t.intercept is 1 by lcount
 		}
		
		// mean squared prediction error
		//X0
		MSPE= mean((y0:-X0B):^2) 	// 1 by lcount vector
		
		if (d.prestdflag) (
			MSPE = MSPE :* (d.prestdy)^2
		)
		
		st_matrix("r(mspe)",MSPE)
}
// end getMSPE


// return the lambda id of the largest lambda at which the MSE
// is within one standard error of the minimal MSE.		
real scalar getOneSeLam(real rowvector mse, real rowvector sd, real scalar id) 
{
	minmse = mse[1,id] // minimal MSE
	minsd = sd[1,id]  // SE of minimal MSE
	criteria = mse[1,id]+sd[1,id] // max allowed MSE
	for (j=0; j<id; j++) {
		theid=id-j 
		thismspe= mse[1,theid]
		if (thismspe > criteria) { // if MSE is outside of interval, stop
				theid = id-j+1 // go back by one id and break
				break
		}
	} 
	return(theid)
}


// partial out program
void s_partial(	string scalar Ynames,
				string scalar Pnames,
				string scalar tYnames,
				string scalar touse,		//  indicates full sample
				string scalar toest,		//  indicates estimation subsample
				string scalar wvar,			//  optional weight variable
				scalar dmflag,				//  indicates data are already mean zero; no constant
				scalar solver)

{

// All varnames should be basic form, no FV or TS operators etc.
// Y = structural variables
// P = variables to be partialled out
// W = weight variable normalized to mean=1; vector of 1s if no weights
// touse = sample
// dmflag = 0 or 1
// solver = 0, 1 or 2
// Strategy is to demean (numerically more stable in case of scaling problems)
// and then use svqrsolve(.) Mata program:
//   svsolve if no collinearites (more accurate),
//   qrsolve if there are collinearities (drops columns/set coeffs to zero),
//   and svsolve if qrsolve can't find the collinearities that svsolve can.

	Ytokens=tokens(Ynames)
	Ptokens=tokens(Pnames)
	st_view(Y, ., Ytokens, touse)			//  full sample
	st_view(P, ., Ptokens, touse)
	st_view(Yest, ., Ytokens, toest)		//  estimation subsample
	st_view(Pest, ., Ptokens, toest)

	if (tYnames ~= "") {
		tYflag=1
		tYtokens=tokens(tYnames)
		st_view(tY, ., tYtokens, touse)		//  full sample
	}
	else {
		tYflag=0
	}
	
	if (wvar ~= "") {						//  weight variable provided
		st_view(W, ., wvar, touse)
	}
	else {									//  no weight variable => W is vector of 1s
		W = J(rows(Yest),1,1)
	}

	L = cols(P)

	// means are based on estimation subsample
	// weighted means using weight vector W; W is a vector of ones if unweighted
	// if dmflag=1, everything is already mean zero and there is no constant so means unneeded
	if ((!dmflag) & L>0) {					//  Vars to partial out including constant
		Ymeans = mean(Yest, W)
		Pmeans = mean(Pest, W)
	}
	else if (!dmflag) {						//  Only constant to partial out = demean
		Ymeans = mean(Yest, W)
	}

	//	Partial-out coeffs, incorporating weights in the projection matrix.
	//	Not necessary if no vars other than constant. r=rank.
	//  coef vector b is based on estimation subsample
	if ((!dmflag) & L>0) {
		b = svqrsolve((Pest :- Pmeans):*sqrt(W), (Yest :- Ymeans):*sqrt(W), r=., solver)	//  partial out P + cons
	}
	else if (L>0) {
		b = svqrsolve(Pest:*sqrt(W), Yest:*sqrt(W), r=., solver)							//  partial out P
	}
	else {
		r=1																					//  partial out cons (demean)
	}

	//	Replace with residuals.
	//  Use full sample (Y, P) and not estimation subsample (Yest, Pest).
	//  Use beta obtained with weighting but do not transform data.
	if ((!dmflag) & L>0) {					//  Vars to partial out including constant
		if (tYflag) {
			tY[.,.] = (Y :- Ymeans) - (P :- Pmeans)*b
		}
		else {
			Y[.,.] = (Y :- Ymeans) - (P :- Pmeans)*b
		}
	}
	else if (L>0) {							//  Vars to partial out NOT including constant
		if (tYflag) {
			tY[.,.] = Y - P*b
		}
		else {
			Y[.,.] = Y - P*b
		}

	}
	else {									//  Only constant to partial out = demean
		if (tYflag) {
			tY[.,.] = Y :- Ymeans
		}
		else {
			Y[.,.] = Y :- Ymeans
		}
	}
	
	// Return list of tokens of dropped collinear vars, if any
	if (r<cols(P)) {								//  something was dropped
		dsel = (b :== 0)							//  matrix, cols=#Y, rows=L, =1 if dropped
		dsel = (rowsum(dsel) :== cols(Y))			//  col vector, =1 if always dropped
		dlist = invtokens(select(Ptokens, dsel'))	//  string of names (tokens)
	}
	else {
		dlist = ""									//  empty list
	}
	st_global("r(dlist)",dlist)						//	Return list of dropped collinears.
	st_numscalar("r(rank)",r+(!dmflag))				//  Include constant in rank

}  
//end program s_partial


// Mata utility for sequential use of SVD & QR solvers
// Default is SVD;
// if rank-deficient, use QR (drops columns);
// if QR then doesn't catch reduced rank, use original SVD.
// override: solver=0 => above;
//           solver=1 => always use SVD;
//           solver=2 => always use QR.
function svqrsolve (	numeric matrix A,			///
						numeric matrix B,			///
						|							///
						rank,						///
						real scalar solver			///
						)
{
	if (args()<=3) solver = 0

	real matrix C
	real matrix Csv
	real matrix Cqr
	real scalar rsv
	real scalar rqr

	if (solver==0) {
		Csv = svsolve(A, B, rsv)
		if (rsv<cols(A)) {				//  not full rank, try QR
			Cqr = qrsolve(A, B, rqr)
			if (rsv<rqr) {				//  QR failed to detect reduced rank, use SVD after all
				C = Csv
			}
			else {						//  QR and SVD agree on reduced rank
				C = Cqr					//  QR dropped cols, use it
			}
		}
		else {
			C = Csv						//  full rank, use SVD (more accurate than QR)
		}
	}
	else if (solver==1) {
		C = svsolve(A, B, rsv)			//  override default, use SVD no matter what
	}
	else {
		C = qrsolve(A, B, rqr)			//  override default, use QR no mater whatt
	}
	if (solver<=1) {
		rank = rsv						//  rsv has rank
	}
	else {
		rank = rqr						//  forced use of QR so return QR rank
	}
	return(C)
}	// end svqrsolve


// Mata utility for sequential use of LU & QR solvers
// Default is LU (faster);
// if rank-deficient, use QR (drops columns).
// override: solver=0 => above;
//           solver=1 => always use LU;
//           solver=2 => always use QR.
function luqrsolve (	numeric matrix A,			///
						numeric matrix B,			///
						|							///
						real scalar solver			///
						)
{
	if (args()<=3) solver = 0

	real matrix Clu
	real matrix C

	if (solver==0) {
		Clu = lusolve(A, B)
		if (hasmissing(Clu)) {			//  not full rank, try QR
			C = qrsolve(A, B)
		}
		else {
			C = Clu						//  full rank, use LU (faster than QR)
		}
	}
	else if (solver==1) {
		C = lusolve(A, B)				//  override default, use LU no matter what
	}
	else {
		C = qrsolve(A, B, rqr)			//  override default, use QR no mater whatt
	}

	return(C)
}	// end luqrsolve


// Mata utility for standardizing; called from Stata.
// Behavior:
// "Standardize" means divide variable x by SD = mean((x-xbar)^2). If model has a constant, also demean x.
// dmflag=1 => treat data as demeaned. mvec set to 0 automatically.
//             means preweighted and demeaned data treated correctly (since weighted mean=0 even though mean is not)
// dmflag=0 => treatment depends on consmodel
//             consmodel=1 => mean is calculated and data are demeaned (hence not suitable for preweighted data)
//             consmodel=0 => just standardize without demeaning (so works with both unweighted and preweighted data)
void s_std(	string scalar Xnames,						//  names of original Stata variables
					string scalar tXnames,				//  names of optional Stata temp vars to initialize/modify
					string scalar touse,				//  full sample
					string scalar toest,				//  sample on which standardization is based
					real scalar consmodel,				//  =1 if constant in model (=> data to be demeaned)
					real scalar dmflag,					//  =1 if data already demeaned
					real scalar transform				//  flag to indicate that data are to be transformed
					)
{

// All varnames should be basic form, no FV or TS operators etc.
// Can include tempvars.

	Xtokens=tokens(Xnames)
	st_view(X, ., Xtokens, touse)		// full sample
	st_view(Xest, ., Xtokens, toest)	// estimation subsample
	
	if (tXnames ~= "") {
		tXflag=1
		tXtokens=tokens(tXnames)
		st_view(tX, ., tXtokens, touse)
	}
	else {
		tXflag=0
	}

	if (dmflag) {
		// treat data as already demeaned
		mvec			= J(1,cols(Xest),0)
		s				= sqrt(mean((Xest):^2))
		// if SD=0 (constant var), convention is to set SD to 1
		if (sum(s:==0)) {
			_editvalue(s,0,1)
		}
		if (transform) {
			if (tXflag) {
				tX[.,.]=X:/s
			}
			else {
				X[.,.]=X:/s
			}
		}
	}
	else {
		// mean and SD based on estimation subsample
		mvec			= mean(Xest)
		s				= sqrt(mean((Xest:-mvec):^2))

		// if SD=0 (constant var), convention is to set SD to 1
		if (sum(s:==0)) {
			_editvalue(s,0,1)
		}
		if (transform) {
			if ((tXflag) & (consmodel)) {
				tX[.,.]=(X:-mvec):/s			//  consmodel => demean temp vars before standardizing
			}
			else if (consmodel) {
				X[.,.]=(X:-mvec):/s				//  consmodel => demean orig vars before standardizing
			}
			else if (tXflag) {
				tX[.,.]=X:/s					//  no consmodel => just standardize temp vars
			}
			else {
				X[.,.]=X:/s						//  no consmodel => just standardize orig vars
			}
		}
	}

	st_matrix("r(stdvec)",s)
	st_matrix("r(mvec)",mvec)
	
}  
//end program s_std

// Mata utility for weighting; called from Stata.
// Weight by sqrt of weighting variable.
void s_wt(			string scalar Xnames,				//  names of original Stata variables
					string scalar tXnames,				//  names of Stata temp vars to initialize/modify
					string scalar touse,				//  full sample
					string scalar wvar,					//  weight variable
					real scalar transform				//  flag to indicate that data are to be transformed
					)
{

// All varnames should be basic form, no FV or TS operators etc.
// Can include tempvars.

	Xtokens=tokens(Xnames)
	st_view(X, ., Xtokens, touse)		// full sample
	
	tXtokens=tokens(tXnames)
	st_view(tX, ., tXtokens, touse)

	st_view(W, ., wvar, touse)
	
	tX[.,.]=X:*sqrt(W)

}  
//end program s_wt


// utility for rlasso
// returns X after centering (if cons present)
// and partialling-out (if any partialled-out vars present)
real matrix centerpartial(	pointer matrix X,		///
							real rowvector Xmvec,	///
							real scalar cons,		///
							pointer matrix Z,		///
							real matrix Zmvec,		///
							real matrix pihat)		//  =0 if nothing to partial out, =projection coefs if Zs.
{
	if ((pihat==0) & (cons==0)) {
		return(*X)
	}
	else if ((pihat==0) & (cons==1)) {
		return((*X) :- Xmvec)
	}
	else {
		return(((*X):-Xmvec) - (((*Z):-Zmvec)*pihat))
	}
}
// end program centerpartial



//********************* MODIFIED FROM OFFICIAL STATA/MATA *********************//
// quadcorrelation modified to allow for no intercept/means
// Based on official quadcorrelation(.):
// version 1.0.1  06jun2006
// version 9.0
// mata:

real matrix m_quadcorr(real matrix X, real scalar cons, |real colvector w)
{
		real rowvector  CP
		real rowvector  means
		real matrix	 res
		real scalar	 i, j
		real scalar	 n 

		if (args()==2) w = 1

		CP = quadcross(w,0, X,1)
		n  = cols(CP)
		if (cons) {
			means = CP[|1\n-1|] :/ CP[n]
			res = quadcrossdev(X,0,means, w, X,0,means)
		}
		else {
			res = quadcross(X,0, w, X,0)
		}

		for (i=1; i<=rows(res); i++) {
				res[i,i] = sqrt(res[i,i])
				for (j=1; j<i; j++) {
						res[i,j] = res[j,i] = res[i,j]/(res[i,i]*res[j,j])
				}
		}
		for (i=1; i<=rows(res); i++) res[i,i] = 1
		return(res)
}



//********************* FROM MOREMATA BY BEN JANN *********************//
// Based on:
// mm_quantile.mata
// version 1.0.8  20dec2007  Ben Jann

real matrix mm_quantile(real matrix X, | real colvector w,
 real matrix P, real scalar altdef)
{
	real rowvector result
	real scalar c, cX, cP, r, i

	if (args()<2) w = 1
	if (args()<3) P = (0, .25, .50, .75, 1)'
	if (args()<4) altdef = 0
	if (cols(X)==1 & cols(P)!=1 & rows(P)==1)
	 return(mm_quantile(X, w, P', altdef)')
	if (missing(P) | missing(X) | missing(w)) _error(3351)
	if (rows(w)!=1 & rows(w)!=rows(X)) _error(3200)
	r = rows(P)
	c = max(((cX=cols(X)), (cP=cols(P))))
	if (cX!=1 & cX<c) _error(3200)
	if (cP!=1 & cP<c) _error(3200)
	if (rows(X)==0 | r==0 | c==0) return(J(r,c,.))
	if (c==1) return(_mm_quantile(X, w, P, altdef))
	result = J(r, c, .)
	if (cP==1) for (i=1; i<=c; i++)
	 result[,i] = _mm_quantile(X[,i], w, P, altdef)
	else if (cX==1) for (i=1; i<=c; i++)
	 result[,i] = _mm_quantile(X, w, P[,i], altdef)
	else for (i=1; i<=c; i++)
	 result[,i] = _mm_quantile(X[,i], w, P[,i], altdef)
	return(result)
}

real colvector _mm_quantile(
 real colvector X,
 real colvector w,
 real colvector P,
 real scalar altdef)
{
	real colvector g, j, j1, p
	real scalar N

	if (w!=1) return(_mm_quantilew(X, w, P, altdef))
	N = rows(X)
	p = order(X,1)
	if (altdef) g = P*N + P
	else g = P*N
	j = floor(g)
	if (altdef) g = g - j
	else g = 0.5 :+ 0.5*((g - j):>0)
	j1 = j:+1
	j = j :* (j:>=1)
	_editvalue(j, 0, 1)
	j = j :* (j:<=N)
	_editvalue(j, 0, N)
	j1 = j1 :* (j1:>=1)
	_editvalue(j1, 0, 1)
	j1 = j1 :* (j1:<=N)
	_editvalue(j1, 0, N)
	return((1:-g):*X[p[j]] + g:*X[p[j1]])
}

real colvector _mm_quantilew(
 real colvector X,
 real colvector w,
 real colvector P,
 real scalar altdef)
{
	real colvector Q, pi, pj
	real scalar i, I, j, jj, J, rsum, W
	pointer scalar ww

	I  = rows(X)
	ww = (rows(w)==1 ? &J(I,1,w) : &w)
	if (altdef) return(_mm_quantilewalt(X, *ww, P))
	W  = quadsum(*ww)
	pi = order(X, 1)
	if (anyof(*ww, 0)) {
		pi = select(pi,(*ww)[pi]:!=0)
		I = rows(pi)
	}
	pj = order(P, 1)
	J  = rows(P)
	Q  = J(J, 1, .)
	j  = 1
	jj = pj[1]
	rsum = 0
	for (i=1; i<=I; i++) {
		rsum = rsum + (*ww)[pi[i]]
		if (i<I) {
			if (rsum<P[jj]*W) continue
			if (X[pi[i]]==X[pi[i+1]]) continue
		}
		while (1) {
			if (rsum>P[jj]*W | i==I) Q[jj] = X[pi[i]]
			else Q[jj] = (X[pi[i]] + X[pi[i+1]])/2
			j++
			if (j>J) break
			jj = pj[j]
			if (i<I & rsum<P[jj]*W) break
		}
		if (j>J) break
	}
	return(Q)
}

real colvector _mm_quantilewalt(
 real colvector X,
 real colvector w,
 real colvector P)
{
	real colvector Q, pi, pj
	real scalar i, I, j, jj, J, rsum, rsum0, W, ub, g

	W  = quadsum(w) + 1
	pi = order(X, 1)
	if (anyof(w, 0)) pi = select(pi, w[pi]:!=0)
	I  = rows(pi)
	pj = order(P, 1)
	J  = rows(P)
	Q  = J(J, 1, .)
	rsum = w[pi[1]]
	for (j=1; j<=J; j++) {
		jj = pj[j]
		if (P[jj]*W <= rsum) Q[jj] = X[pi[1]]
		else break
	}
	for (i=2; i<=I; i++) {
		rsum0 = rsum
		rsum = rsum + w[pi[i]]
		if (i<I & rsum < P[jj]*W) continue
		while (1) {
			ub = rsum0+1
			if (P[jj]*W>=ub | X[pi[i]]==X[pi[i-1]]) Q[jj] = X[pi[i]]
			else {
				g = (ub - P[jj]*W) / (ub - rsum0)
				Q[jj] = X[pi[i-1]]*g + X[pi[i]]*(1-g)
			}
			j++
			if (j>J) break
			jj = pj[j]
			if (i<I & rsum < P[jj]*W) break
		}
		if (j>J) break
	}
	return(Q)
}

// END MAIN MATA SECTION
end

*********** CONDITIONAL COMPILATION SECTION *****************
// Section is in Stata environment.

// FTOOLS
// Tell Stata to exit before trying to complile Mata function
// s_fe if required FTOOLS package is not installed.
// Note this runs only once, on loading, and if ftools has not
// been compiled, the check option will trigger compilation.

// ftools can flip matastrict to on, causing program to fail to load.
local mstrict `c(matastrict)'
cap ftools, check
if _rc {
	// fails check, likely not installed, so do not compile
	// _fe Stata program will use (slower) Stata code
	exit
}
else {
	// temporarily set matastrict off
	qui set matastrict off
}

// Compile Mata function s_fe.
version 13
mata:

// FE transformation.
// Uses Sergio Correia's FTOOLS package - faster and does not require the data to be sorted.
void s_fe(		string scalar Xnames,
				string scalar tXnames,
				string scalar Wname,
				string scalar fe,
				string scalar touse,
				string scalar toest)
{

	class Factor scalar F
	F = factor(fe, touse)
	F.panelsetup()

	Xtokens=tokens(Xnames)
	X = st_data( ., Xtokens, touse)
	tXtokens=tokens(tXnames)
	st_view(tX, ., tXtokens, touse)
	
	if (Wname~="") {
		st_view(Wvar, ., Wname, touse)
	}
	else {
		Wvar = J(rows(X),1,1)
	}

	w = F.sort(st_data(., toest, touse))				//  extract toest variable
	counts = panelsum(w:*Wvar, F.info)					//  weighted counts for just the toest subsample
	means = editmissing(panelsum(F.sort(X:*Wvar), w, F.info) :/ counts, 0)
	tX[.,.] = X - means[F.levels, .]

	N_g = F.num_levels
	st_numscalar("r(N_g)",N_g)

}

// End Mata section for s_fe
end

// reset matastrict to what it was prior to loading this file
qui set matastrict `mstrict'

// END CONDITIONAL COMPILATION SECTION

******************** END ALL PROGRAM CODE *******************
exit



**************** ADDITIONAL NOTES ***************************

// The code below is NOT implemented here but is for reference.
// Conditional coding section above works just once, for a single
// possibly uninstalled Mata package.
// To implement for multiple possibly uninstalled Mata packages,
// use the following comment-out trick (hat-tip to Sergio Correia).

// FTOOLS
// Set comment local to "*" before trying to complile Mata function
// s_fe if required FTOOLS package is not installed.
// Note this runs only once, on loading, and if ftools has not
// been compiled, the check option will trigger compilation.

// ftools can flip matastrict to on, causing program to fail to load.
local mstrict `c(matastrict)'
cap ftools, check
if _rc {
	// fails check, likely not installed, so do not complile
	// _fe Stata program will use (slower) Stata code
	loc c *
}
else {
	// temporarily set matastrict off
	qui set matastrict off
}

// Compile Mata function s_fe.
`c' version 13
`c' mata:

// FE transformation.
// Uses Sergio Correia's FTOOLS package - faster and does not require the data to be sorted.
`c' void s_fe(		string scalar Xnames,
`c' 				string scalar tXnames,
`c'					string scalar Wname,
`c' 				string scalar fe,
`c' 				string scalar touse,
`c' 				string scalar toest)
`c' {
`c' 
`c' 	class Factor scalar F
`c' 	F = factor(fe, touse)
`c' 	F.panelsetup()
`c' 
`c' 	Xtokens=tokens(Xnames)
`c' 	X = st_data( ., Xtokens, touse)
`c' 	tXtokens=tokens(tXnames)
`c' 	st_view(tX, ., tXtokens, touse)
`c' 
`c' 	w = F.sort(st_data(., toest, touse))				//  extract toest variable
`c' 	counts = panelsum(w, F.info)
`c' 	means = editmissing(panelsum(F.sort(X), w, F.info) :/ counts, 0)
`c' 	tX[.,.] = X - means[F.levels, .]
`c' 
`c' 	N_g = F.num_levels
`c' 	st_numscalar("r(N_g)",N_g)
`c' 
`c' }
`c' 
`c' // End Mata section for s_fe
`c' end

// reset matastrict
qui set matastrict `mstrict'

// Reset comment local for next package.
loc c

// ... further possibly uninstalled Mata packages ...

exit

