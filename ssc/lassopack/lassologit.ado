*! lassologit (v0.3)
*! part of lassopack v1.3.1
*! last edited: 15oct2019
*! authors: aa/ms/cbh

* Updates 	(release date):
* v0.2		(10oct2019)
*			fixed exp.exp bug that was affecting Stata 13
* v0.3		(15oct2019)
*			fixed remaining exp.exp bug that was affecting Stata 13

program lassologit, eclass sortpreserve

	version 13
	
	syntax [anything]  [if] [in] [fw aw pw]					///
						[, lic(string) ic(string)			///+
						newlambda(numlist >0 min=1 max=1)	///~
						POSTRESults							///
						version								///
						long								///
						PLOTpath(string)					///
						PLOTOpt(string)						///
						PLOTVar(varlist)					///
						PLOTLabel							///
						lambdan	nopath settingup			///
						* ]
							
	if "`version'" != "" {							//  Report program version number, then exit.
		di in gr "lassologit.ado version `lversion'"
		di in gr "lassologit package version `pversion'"
		ereturn clear
		ereturn local version		`lversion'
		ereturn local pkgversion	`pversion'
		exit
	}
	//
	
	*** initialise local that saves whether est results are in hold
	local inhold=0
	
	if (!replay()) {
	
		tokenize "`0'", parse(",")
		_lassologit `1', `options' newlambda(`newlambda') `lambdan'  
		ereturn local cmdoptions `options'
	
	}
	if (replay()) & ("`lic'"=="") & ("`newlambda'"!="") { 

		// re-estimate
		local cmdoptions0 `e(cmdoptions)'
		local depvar `e(depvar)'
		local varX `e(varX)'
		tempvar esample
		qui gen byte `esample' = e(sample)
		_lassologit `depvar' `varX' 						///
							if `esample' 					///
							[`weight' `exp'] , 				///
							`options' 						///
							newlambda(`newlambda') 			///
							`cmdoptions0' 					///
							`lambdan'
		ereturn local cmdoptions `cmdoptions0'
	
	}
	if (replay()) & ("`lic'"!="") & ("`newlambda'"=="") { 
	
		// set lambda
		if ("`lic'"=="ebic") {
			local newlambda = `e(ebiclambda)'
		}
		else if ("`lic'"=="bic") {
			local newlambda = `e(biclambda)'
		}
		else if ("`lic'"=="aic") {
			local newlambda = `e(aiclambda)'
		}
		else if ("`lic'"=="aicc") {
			local newlambda = `e(aicclambda)'
		}
		else if ("`lic'"!="") {
			di as err "lic(`lic') not allowed."
			di as err "Allowed options: 'ebic', 'bic', 'aic', 'aicc'." 
			exit 198
		}
		//

		// re-estimate
		local cmdoptions0 `e(cmdoptions)'
		local depvar `e(depvar)'
		local varX `e(varX)'
		tempvar esample
		gen byte `esample' = e(sample)
		local licstrupper=strupper("`lic'")
		//di as text ""
		di as text "Use lambda=`newlambda' (selected by `licstrupper')."
		if ("`postresults'"=="") {
			tempname model0
			_estimates hold `model0'
			local inhold = 1
		}
		_lassologit `depvar' `varX'  						///
							if `esample'					///
							[`weight' `exp'] , 				///
							`options' 						///
							newlambda(`newlambda') 			///
							`cmdoptions0' 					///
							`lambdan'
		ereturn local cmdoptions `cmdoptions0'
	
	}	
	else if (replay()) & ("`lic'"!="") & ("`newlamba'"!="") {
	
		di as err "Internal error."
		di as err "lic() and newlambda() not allowed at the same time."
		exit 301
	
	}
	//

	*** show output if lambda is a list
	if (`e(lcount)'>1) {
		// display should be the same as lic()
		if "`lic'"!="" {
			local ic `lic'
		}
		*
		if "`nopath'"=="" & "`settingup'"=="" {
			DisplayPath, `long' ic(`ic') `notypemessage' ///
							`lambdan'
		}
		if ("`plotpath'`plotvar'`plotopt'"!="")  {
			plotpath2, 		  plotpath(`plotpath') 		///
							  plotvar(`plotvar')   		///
							  plotopt(`plotopt') 		///
							  `plotlabel'				///
							  `wnorm' 					///
							  logistic
		}
	}
	*
		
	*** second run of _lassologit
	// only applicable if lassologit is called with lic option
	// re-estimate for single lambda	
	if (~replay()) & ("`lic'"!="") {
	
		* check that lambda was a list in previous estimation
		if (`e(lcount)'==1) {
			di as err "lic() only allowed if lambda() is a list."
			exit 198
		}
		* set newlambda to lambda selected by IC
		if ("`lic'"=="aic") {
			local newlambda = e(aiclambda)
		}
		else if ("`lic'"=="bic") {
			local newlambda = e(biclambda)
		} 
		else if ("`lic'"=="aicc") {
			local newlambda = e(aicclambda)
		}
		else if ("`lic'"=="ebic") {
			local newlambda = e(ebiclambda)
		}
		else {
			di as err "lic(`lic') not allowed. Select aic, bic, aicc or ebic."
			exit 198		
		}

		local cmdoptions `e(cmdoptions)'
		local depvar `e(depvar)'
		local varX `e(varX)'
		local licstrupper=strupper("`lic'")
		di as text ""
		di as text "Use lambda=`newlambda' (selected by `licstrupper')."
		tempvar esample
		qui gen byte `esample' = e(sample) // ensure same sample is used
		if ("`postresults'"=="") {
			tempname model0
			_estimates hold `model0'
			local inhold = 1
		}
		_lassologit `depvar' `varX' 					/// 
								if `esample' 			///
								[`weight' `exp'] , 		///
								`cmdoptions' 			///
								newlambda(`newlambda') 	///
								`lambdan'
		ereturn local cmdoptions `cmdoptions' 
	}
	*
 
	*** Show ouput if lambda is a scalar
	if (`e(lcount)'==1) {
		DisplayCoefs, `displayall' `norecover'
		if ("`plotpath'`plotvar'`plotopt'`plotlabel'"!="") {
			di as error "Plotting only supported for list of lambda values."
			di as error "Plotting options ignored."
		}
	}
	*
		
	*** unhold estimation results
	if ("`postresults'"=="") & (`inhold'==1) {
		_estimates unhold `model0'
	}
end


cap program drop _lassologit
program _lassologit, eclass sortpreserve

	version 13
	
	syntax varlist(numeric min=1 fv ts)				/// just y if x vars provided separately
			[if] [in] [fw aw pw] [,					///
			NOCONstant								///+
			Lambda(numlist >0 min=1 descending) 	///+ 
			newlambda(numlist >0 min=1 max=1)		///~
			VERBose									///+
			///vverbose								///+
			stdcoef									///+
			NOStd									///+
			stdfly									///~
			stdsmart								///~
			RIGorous								///~
			c(real -1) 								///+
			gamma(real -1)							///+ the gamma of the rigorous lamba
			EBICXi(real -1)							///+ EBIC gamma
													///
			vary_t(varlist numeric min=1)			///~ y var already parsed
			varx_o(string)							///~ X vars already parsed
			varx_t(varlist numeric min=1)			///~ X vars already parsed
			bytelist(string)						///~ X vars already parsed
			toest(varlist numeric min=1 max=1)		///~ estimation sample  
			holdout(varlist numeric min=1 max=1) 	///+ holdout sample
			touse(varlist numeric min=1 max=1)	 	///~ full sample
			wvar(name)								///~
													/// for out-of-sample prediction
			psi(name)								///+ vector of (unstandardized) penalty loadings
			spsi(name)								/// vector of (standardized) penalty loadings
			NOTPen(string)							///+
			///Alpha(real 0)						/// elastic net parameter [not implemented]
			LOSSMeasure(string)						///+
			///
			/// optimisation
			TOLOpt(real 10e-7)						///+
			TOLZero(real 10e-10)					///+
			MAXIter(int 10000) 						///+
			///
			/// lambda
			LCount(int 50)							///+
			LMINRatio(real 10e-3)					///+
			LMAX(real -1)							///+
			LAMBDAN									///+ use as input/report as output lambda that incorporates 1/n
			///
			SETUPSTRUCT(name)						///~ don't estimate. return populated data struct and default lambda.
			STRUCTNAME(name)						///~ use provided Mata data struct.
			POSTLogit								///+
			SAVEPred 								///~
			NOSEQRule								///~ use sequential rule
			nopreserve 								///~
			debug									///~
			QUADPrecision							///+
			SUBSETRatio(real .5)					///~
			NOPROgressbar 							///+
			hdmlambda 								///  use gamma as in hdm package
			]

	*** binary parameters
	local debugflag		= "`debug'"~=""
	local weightflag	= ("`weight'"~="")
	local fweightflag	= ("`weight'"=="fweight")
	// by default _lassologit internally uses lambda that incorporates 1/n
	// but reports lambda that does not incorporate 1/n
	// lambdanflag=0 (default): reported lambdas need to be rescaled by n at the end
	//                          and user=provided lambdas need to be deflated by 1/n before use
	// lambdanflag=1          : no rescaling necessary
	local lambdanflag	= ("`lambdan'"~="")
	local stdflyflag	= ("`stdfly'"~="")
	local stdsmartflag	= ("`stdsmart'"~="")
	local nodatastruct	= ("`structname'"=="")
	local cons			= ("`noconstant'"=="")
	local xstd			= ("`nostd'"=="")
	local stdcoef		= ("`stdcoef'"!="")
	local plogit		= ("`postlogit'"!="")
	local srule			= ("`noseqrule'"=="")
	local verb			= ("`verbose'`vverbose'"!="")+("`vverbose'"!="")
	local quadprec 		= ("`quadprecision'"!="")
	local progbar 		= ("`noprogressbar'"=="") 
	local hdmlambda 		= ("`hdmlambda'"!="")
	
	**
	if (`cons'==0) {
		local srule = 0
	}
	//
	
	** no progress bar if verbose
	if (`verb'>0) {
		local progbar = 0
	}
	//
	
	*** set default loss measure
	if ("`lossmeasure'"=="") {
		local lossmeasure deviance
	}
	//
	
	*** initialize preserved flag to 0
	local preserved = 0
	
	*** syntax checks
	// touse, toest and wvar allowed only with setting up data struct
	if "`touse'`toest'`wvar'"~="" & "`setupstruct'"=="" {
		di as err "error: touse(.) toest(.) wvar(.) can be used only with setupstruct option"
		exit 198
	}
	if "`psi'"~="" & "`epsi'"~="" {
		di as err "error: incompatible options psi(.) and epsi(.)"
		exit 198
	}
	local stdoptcount : word count `stdfly' `stdsmart' `nostd'
	if `stdoptcount'>1 {
		di as err "error: incompatible options `stdfly' `stdsmart' `nostd'"
		exit 198
	}
	
	// execute code for setting up data struct if none provided
	if `nodatastruct' {
	
		if "`varx_o'"=="" {
			tokenize `varlist'
			local varY_o `1'
			macro shift
			local varX_o `*'
		}
		else {
			// if varlists provided, macro varlist has just y in it
			local varY_o `varlist'
			local varX_o `varx_o'
		}

		*** sample markers
		
		*** mark full sample
		if ("`touse'"=="") {
			// marksample sets=0 if any vars in varlist are missing etc.
			marksample touse
		}
		if ("`holdout'"=="") {
			tempvar holdout
			qui gen byte `holdout'=0 if `touse'
		}
		if ("`toest'"=="") {
			tempvar toest 
			qui gen byte `toest' = 1-`holdout' if `touse'
		}
		// check
		assert `holdout'==0  | `holdout'==1 if `touse'
		assert `toest'==0  | `toest'==1 if `touse'
		assert `toest'+`holdout'==1 if `touse'

		*** check dependent variable
		if "`vary_t'"=="" {
			tempvar varY_t
			gen byte `varY_t' = `varY_o'~=0
			qui replace `varY_t' = . if `varY_o'==.
			// varies within estimation sample?
			sum `varY_t' if `toest', meanonly
			cap assert r(mean)>0 & r(mean)<1
			if _rc==9 {
				di as err "error: outcome does not vary in estimation sample"
				exit 2000
			}
		}
		else {
			local varY_t `vary_t'
		}
		//
	
		*** weights
		// `exp' includes the =
		if `fweightflag' {
			// fweights
			if "`wvar'"=="" {
				tempvar wvar
				qui gen long `wvar' = .
			}
			qui replace `wvar' `exp'
		}
		else if `weightflag' {
			// aweights and pweights
			if "`weight'"=="aweight" {
				// Stata's logit won't accept aweights
				local weight pweight
			}
			if "`wvar'"=="" {
				tempvar wvar
				qui gen double `wvar' = .
			}
			qui replace `wvar' `exp'
			sum `wvar' if `touse' `wtexp', meanonly
			// Weight statement
			di as text "(sum of wgt is " %14.4e `r(sum)' ")"
			// normalize to have unit mean
			qui replace `wvar' = `wvar' * r(N)/r(sum)
		}
		else {
			// unweighted
			if "`wvar'"=="" {
				tempvar wvar
				qui gen byte `wvar' = .
			}
			qui replace `wvar' = 1
		}
		
		**** settings (in this order)
		**** precision, max iterations, logit (1) or linear (0), verbose
		tempname settings
		mata: `settings' = (`tolopt',`maxiter',1,`verb',`tolzero',`srule',`quadprec',`subsetratio',`progbar',`ebicxi',`hdmlambda')
		// add to list of mata globals created
		local mnamelist `mnamelist' `settings'
	
		*** preserve
		// preserve not needed if standardizing-on-the-fly
//		if (("`nostd'"=="") | (`cons')) & ("`nopreserve'"=="") & (`stdflyflag'==0) {
		if (`xstd') & ("`nopreserve'"=="") & (`stdflyflag'==0) {
			preserve
			local preserved = 1
		}
		//
		
		*** ereturn clear
		ereturn clear
		//
		
		*** duplicates, factor and time-series variables, temp vars
		if "`varx_o'"=="" {
			// expand and replace macro
			fvexpand `varX_o' if `touse'
			local varX_o	`r(varlist)'
			// check for duplicates has to follow expand
			local dups			: list dups varX_o
			if "`dups'"~="" {
				di as text "Dropping duplicates: `dups'"
			}
			local varX_o		: list uniq varX_o
			// make X temp doubles unless using stdsmart
			if `stdsmartflag' {
				foreach var of local varX_o {
					// determine whether variable exists
					_ms_parse_parts `var'
					if "`r(op)'`r(op1)'"=="" {
						// no fv or ts operator, variable exists
						// determine variable type
						local stype : type `var'
						if "`stype'"=="byte" {
							// create byte temp var
							tempvar v
							qui gen byte `v' = `var'
							local varX_t `varX_t' `v'
							local bytelist `bytelist' 1
						}
						else {
							// create double temp var
							tempvar v
							qui gen double `v' = `var'
							local varX_t `varX_t' `v'
							local bytelist `bytelist' 0
						}				
					}
					else {
						// fv or ts operator, use fvrevar
						fvrevar `var'
						local rv `r(varlist)'
						local stype : type `rv'
						if "`stype'"=="byte" {
							local varX_t `varX_t' `rv'
							local bytelist `bytelist' 1
						}
						else {
							tempvar v
							qui gen double `v' = `rv'
							local varX_t `varX_t' `v'
							local bytelist `bytelist' 0
						}				
					}	
				}
			}
			else {
				// default - all temps are doubles
				foreach var of local varX_o {
					tempvar v
					qui gen double `v' = `var'
					local varX_t `varX_t' `v'
					local bytelist `bytelist' 0
				}
			}
		}
		else {
			local varX_o `varx_o'
			local varX_t `varx_t'
			// bytelist already provided
		}

		*** notpen list	
		// expand and check if all notpen() vars are in varX_o list
		if ("`notpen'"!="") {
			fvexpand `notpen' if `touse'
			local notpen_o	`r(varlist)'
			local NotpNotVarX : list notpen_o - varX_o
			if ("`NotpNotVarX'"!="") {
				di as err "Error in notpen(): `NotpNotVarX' not in list of predictors"
				exit 198
			}
		} 
		//
	
	}	// end code that is required for setting up the data struct
	else {
		// if populated data struct is provided, preserve Stata data in case of standardization etc.
		// preserve not needed if standardizing-on-the-fly
//		if (("`nostd'"=="") | (`cons')) & ("`nopreserve'"=="") & (`stdflyflag'==0) {
		if (`xstd') & ("`nopreserve'"=="") & (`stdflyflag'==0) {
			preserve
			local preserved = 1
		}
		// and restore saved locals from data struct
		mata: st_local("wvar",dataStructSelect(`structname',"Wname"))
		mata: st_local("touse",dataStructSelect(`structname',"tousename"))
		mata: st_local("toest",dataStructSelect(`structname',"toestname"))
		mata: st_local("holdout",dataStructSelect(`structname',"holdoutname"))

	}
	
	*** prepare data, store in structure
	*** MakeData() creates views of full dataset etc.
	*** SelectData() creates subviews of estimation and holdout samples etc.
	*** StandardizeData() standardizes the estimation sample.
	
	if "`setupstruct'"~="" {
		// setupstruct sets up data struct and lambdas; no estimation
		mata: `setupstruct'=MakeData("`varX_o'","`varX_t'","`bytelist'","`wvar'","`weight'","`exp'","`varY_t'","`touse'","`toest'","`holdout'","`notpen_o'",`cons',`xstd',`stdflyflag',`stdsmartflag',`plogit',`settings')
		mata: SelectData(`setupstruct')
		// StandardizeData also sets up ploadings
		mata: StandardizeData(`setupstruct',"`psi'","`spsi'")
		tempname lambdas
		// _lassologit internal lambdas already incorporate factor of 1/n
		mata: `lambdas' = calcDefLambdas(`setupstruct',`lmax',`lcount',`lminratio')
		// add to list of mata globals created
		local mnamelist `mnamelist' `lambdas'
		mata: st_matrix("e(lambdas)",`lambdas')
		mata: st_numscalar("e(lcount)",cols(`lambdas'))
		mata: st_numscalar("e(N)",dataStructSelect(`setupstruct',"total_trials"))
		ereturn local structname `setupstruct'

		if (`preserved') {
			restore
		}

	}
	else {
		// estimate
		if "`structname'"=="" {
			// if data struct not provided, create it
			tempname data
			mata: `data'=MakeData("`varX_o'","`varX_t'","`bytelist'","`wvar'","`weight'","`exp'","`varY_t'","`touse'","`toest'","`holdout'","`notpen_o'",`cons',`xstd',`stdflyflag',`stdsmartflag',`plogit',`settings')
			// and since created here, add to list of mata objects to clear at the end
			local mnamelist `mnamelist' `data'
		}
		else {
			// data struct provided
			local data `structname'
		}
		mata: SelectData(`data')
		// StandardizeData also sets up ploadings
		mata: StandardizeData(`data',"`psi'","`spsi'")


		*** lambda
		if ("`newlambda'"!="") {
			local lambda = `newlambda'
		}
		// list of lambdas (can be length=1)
		tempname lambdas
		// add to list of mata globals created
		local mnamelist `mnamelist' `lambdas'
		if ("`rigorous'"!="") & ("`lambda'"=="") {
		
			// calculate "rigorous" lambda
			tempname lam_params
			mata: `lam_params' = (`c',`gamma')
			// add to list of mata globals created
			local mnamelist `mnamelist' `lam_params'
			// _lassologit internal lambdas already incorporate factor of 1/n
			mata: `lambdas' = calcRigorousLambda(`data',`lam_params')
			local lcount = 1
	
		}
		else if ("`rigorous'"=="") & ("`lambda'"=="") {
		
			// calculate default lambda
			// _lassologit internal lambdas already incorporate factor of 1/n
			mata: `lambdas' = calcDefLambdas(`data',`lmax',`lcount',`lminratio')
	
		}
		else if ("`rigorous'"=="") & ("`lambda'"!="") {
		
			// take user-specified lambda
			local lcount : word count `lambda'
			mata: `lambdas' = strtoreal(tokens("`lambda'"))
			// by default _lassologit internally uses lambda that incorporates 1/n
			// but reports lambda that does not incorporate 1/n
			// if user provides lambda that does not incorporate 1/n, need to rescale it
			if `lambdanflag'==0 {
				mata: `lambdas' = `lambdas' * 1/dataStructSelect(`data',"total_trials")
			}
		}
		else {
			di as err "Options rigorous and lambda() not allowed as the same time."
		}
		//
	
		//
		
		*** estimation & output

		// fit model	
		tempname fitResults
		mata: `fitResults'=fit(`data',`lambdas')
		// add to list of mata globals created
		local mnamelist `mnamelist' `fitResults'
		
		// prepare output:
		// unstandardise beta, post results, 
		// calculate out-of-sample prediction (if there is a holdout sample)
		// etc.. 
		local savepredmat = ("`savepred'"!="")

		// note Stata logit uses toest marker
		// use "if `toest'==1" (rather than "if `touse'") in case of missings
		mata: MakeOutput(`data',`fitResults',"`lossmeasure'",`savepredmat',"if `toest'==1")

		*** ereturn post
		// initialize ereturned results with depname
		ereturn post , depname(`varY_o')
		// Mata routine to post all results except e(b)
		mata: PostResults(`data',`fitResults',"`lossmeasure'",`savepredmat')
		// post e(b) only
		if (`lcount'==1) {
			tempname theb
			if ("`postlogit'"=="") {
				mat `theb' = e(beta_dense)
			}
			else {
				mat `theb' = e(beta_post_dense)
			}
			ereturn repost b=`theb', resize rename
		}
		// finally, post esample(.); do it here to avoid ereturn+esample
		// bug in Stata that can corrupt any live Mata views
		// first need to restore, otherwise e(sample) will disappear
		if (`preserved') {
			restore
		}
		// use a copy of touse so that it stays in memory
		tempvar esample
		qui gen byte `esample'=`touse'
		ereturn repost, esample(`esample')

	}

	if `lambdanflag'==0 {
		// _lassologit internal lambdas incorporate factor of 1/n
		// by default rescale lambda here so that factor of 1/n is removed
		// unless overridden with lambdan option
		rescale_lambda
	}
	
	// tidy up mata memory
	mata: mata drop `mnamelist'

end

// utility for rescaling lambda
program define rescale_lambda, eclass

	version 13
	
	// rescale scalars
	foreach s in aiclambda aicclambda biclambda ebiclambda lambda {
		if e(`s')<. {
			ereturn scalar `s'	= e(`s')*e(N)
		}
	}
	
	// rescale lambdas
	tempname lambdas
	mat `lambdas' = e(lambdas)
	if `lambdas'[1,1] ~= . {
		mat `lambdas' = `lambdas' * e(N)
		ereturn matrix lambdas = `lambdas'
	}

end


program define plotpath2

	syntax [anything] [, 	plotvar(string)		///
							plotpath(string)	///
							plotopt(string)		///
							plotlabel			///
							wnorm				///
							LOGistic			///
							]
	
	version 12
	
	if (("`plotpath'"!="lambda") & ("`plotpath'"!="norm") & ("`plotpath'"!="lnlambda")) {
			di as err "Plotpath() allows 'lambda', `lnlambda' or 'norm'."
			error 198
	}
	//

	
	****************************************************************************
	*** Contents of b matrix and lambda vector made into Stata variables for plotting.
	tempname b lambdas l1norm
	mat `b' = e(betas)
	if ("`logistic'"!="") {
		mat `lambdas' = e(lambdas)'
		if "`wnorm'"=="" {
			mat `l1norm' = e(l1norm)'
		}
		else {
			mat `l1norm' = e(wl1norm)
		}
	}
	else {
		mat `lambdas' = e(lambdamat)
		if "`wnorm'"=="" {
			mat `l1norm' = e(l1norm)
		}
		else {
			mat `l1norm' = e(wl1norm)
		}
	}
	tempvar touse
	gen `touse'=e(sample)
	local lcount = e(lcount)


		
	****************************************************************************
	*** Strip out constant (if it's there) since creating a variable called _cons not alllowed.
	local cons = e(cons)
	if `cons' {
			local rb1 = colsof(`b') - 1	//  constant is in the last column
			mat `b' = `b'[1...,1..`rb1']
	}
	//
			
			
	
	****************************************************************************
	*** Varnames taken from colnames of b matrix.

		local bnames : colnames `b'
		fvstrip `bnames'				//  annoying - Stata inserts b/n etc. in first factor variable etc.
		local bnames `r(varlist)'
	// process pv names
		if "`plotvar'"=="" {
			local pvnames `bnames'		//  plot all
		}
		else {							//  plot user-provided
			fvstrip `plotvar' if `touse', expand dropomit
			local pvnames	`r(varlist)'
		}
		foreach pvn in `pvnames' {		//  unab one-by-one to standardise, get i prefix etc.
			fvunab pvn_unab	: `pvn'
			local pvnames_unab `pvnames_unab' `pvn_unab'
		}
	// process b names
		foreach bn in `bnames' {		//  unab one-by-one to standardise, get i prefix etc.
			fvunab bn_unab	: `bn'
			local bnames_unab `bnames_unab' `bn_unab'
		}
		//
		

		
	****************************************************************************
	*** now that unabbreviated varlists are prepared
	*** check that plotvars are in regressors
	*** If `plotvar' macro is empty, graph all regressors.
			if "`plotvar'"~="" {
				local nplotvarcheck	 : list pvnames_unab - bnames_unab
				if ("`nplotvarcheck'"!="") {								
					di as error "Variable(s) `nplotvarcheck' of plotvar() not listed as regressor(s)." 
					exit 198
				}
			}
	// in case there are any . operators included, change to "_"
			local bnames	: subinstr local bnames_unab "." "_", all count(local numsubs)
			local pvnames	: subinstr local pvnames_unab "." "_", all count(local numsubs)
	// check for max number of variables to plot
			local npv : word count `pvnames'
			if `npv' >= 100 {
				di as err "Error: lassopath can graph at most 99 regressors"
				di as err "       use plotvar(.) option to specify subset of regressors"
				exit 103
			}
	//



	****************************************************************************
	*** create graphing data and then plot
														
	preserve	//  do preserve here so that above vars exist
	clear
	
		qui svmat `b'
		foreach var of varlist * {
			tokenize `bnames'
			rename `var' `1'
			mac shift
			local bnames `*'
		}
		//

			if "`plotpath'"=="lnlambda" {
			
				qui svmat `lambdas', names("lambda")
				replace lambda = ln(lambda)
				if ("`plotlabel'"!="") {
					local txt
					local xcoord = lambda[1]-abs(lambda[_N]-lambda[1])*1.03
					local xcoordminus = lambda[1]-abs(lambda[_N]-lambda[1])*1.1
					foreach var of varlist `pvnames' {	
						local ycoord = `var'[_N] 
						local vn = abbrev("`var'",8)
						local txt `txt' text(`ycoord' `xcoord' `"`vn'"', place(w) just(left) size(small))	
					}
					local yscalealt yscale(alt)
					local xscale xscale(range(`xcoordminus'))		//  extend plot area on left to allow room for varnames
				}  
				twoway line `pvnames' lambda, `plotopt' `txt' `yscalealt' xtit("ln(Lambda)") `graphr' `xscale'
				
			}
			else if "`plotpath'"=="lambda" {
			
				qui svmat `lambdas', names("lambda")
				if ("`plotlabel'"!="") {
					local txt
					local xcoord = -abs(lambda[1])*0.03
					local xcoordminus = -abs(lambda[1])*0.15
					foreach var of varlist `pvnames' {	
						local ycoord = `var'[_N] 
						local vn = abbrev("`var'",8)
						local txt `txt' text(`ycoord' `xcoord' `"`vn'"', place(w) just(left) size(small))	
					}
					local yscalealt yscale(alt)
					local xscale xscale(range(`xcoordminus'))		//  extend plot area on left to allow room for varnames
				}  
				twoway line `pvnames' lambda, `plotopt' `txt' `yscalealt' xtit("Lambda") `graphr' `xscale'
				
			}
			else {
			
				qui svmat `l1norm', names("l1norm")
				sort l1norm1
				if ("`plotlabel'"!="") {
					local txt
					local xcoord = l1norm1[_N]*1.02		//  extend plot area on right to allow room for varnames
					local xcoordplus = l1norm1[_N]*1.1
					foreach var of varlist `pvnames' {
						local ycoord = `var'[_N]
						local vn = abbrev("`var'",8)
						local txt `txt' text(`ycoord' `xcoord' `"`vn'"', place(e) just(left) size(small))
					}
					local xscale xscale(range(`xcoordplus'))
				}
				if "`wnorm'"=="" {
					local xtitle L1 Norm
				}
				else {
					local xtitle Weighted L1 Norm
				}

				line `pvnames' l1norm, `plotopt' `txt' xtit("`xtitle'") `graphr' `xscale'
				
			}
		//
		
	restore
	
end

// Used in rlasso and lasso2 rlasso.
// adapted for lassologits
prog DisplayCoefs

	syntax	,								///
		[									///
		displayall							///  full coef vector in display (default=selected only)
		varwidth(int 17)					///
		NORecover 						///
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
	local notpen		`e(notpen)'
	fvstrip `notpen'
	local notpen		`r(varlist)'
	local selected0		`e(selected0)'
	fvstrip `selected0'
	local selected0		`r(varlist)'
	// coef vectors
	tempname beta betaOLS
// 	if "`displayall'"~="" {						//  there must be some vars specified even if nothing selected
// 		mat `beta'		=e(beta) //e(betaAll)
// 		mat `betaOLS'	=e(beta_post) //betaAllOLS)
// 		local col_ct	=colsof(`beta')
// 		local vlist		: colnames `beta'
// 		local vlistOLS	: colnames `betaOLS'
// 		local baselevels baselevels
// 	}
	//else if 1 {							//  display only selected, but only if there are any
		mat `beta'		=e(beta_dense)
		mat `betaOLS'	=e(beta_post_dense)
		local col_ct	=colsof(`beta')
		local vlist		: colnames `beta'
		local vlistOLS	: colnames `betaOLS'
	//}
// 	else {										//  nothing selected, zero columns in beta
// 		local col_ct	=0
// 	}
// 	if e(k)>0 {
// 		_ms_build_info `beta' if e(sample)
// 		_ms_build_info `betaOLS' if e(sample)
// 	}

	*** (Re-)display coefficients including constant/partial
	local varwidth1		=`varwidth'+1
	local varwidth3		=`varwidth'+3
	local varwidth4		=`varwidth'+4
	local varwidthm7	=`varwidth'-7
	local varwidthm13	=`varwidth'-13
	di
	di as text "{hline `varwidth1'}{c TT}{hline 32}"
	//if "`e(method)'"=="sqrt-lasso" {
		di as text _col(`varwidthm7') "Selected {c |}       Logistic       Post"
		di as text _col(`varwidthm7') "         {c |}       Lasso          logit"

	//}
	/*else if "`e(method)'"=="ridge" {
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
	}*/
	di as text "{hline `varwidth1'}{c +}{hline 32}"
	local anynotpen = 0
	local i 1
	local lastcol = `col_ct' //- `partial_ct'
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
	/*if `partial_ct' {
		di as text "{hline `varwidth1'}{c +}{hline 32}"
		di as text _col(`varwidthm13') "Partialled-out{help lasso2##examples_partialling:*}{c |}"
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
	*/
	di as text "{hline `varwidth1'}{c BT}{hline 32}"
	
	if `anynotpen' {
		di "{help lasso2##examples_partialling:*Not penalized}"
	}
	
end

// Display table of path with knots, lambda, vars added/removed etc.
program define DisplayPath
	//syntax [anything] [, stdcoef(int 0)]
	syntax [anything] [, wnorm long ic(string) NOTYpemessage lambdan ]

	version 12
	tempname betas r1 r2 vnames d addedM removedM lambdas dof l1norm vnames0 allselected allsec
	tempname icmat rsq
	
	***** information criteria *************************************************
	if ("`ic'"=="") {
		local ic ebic
	}
	if ("`ic'"!="aic") & ("`ic'"!="bic") & ("`ic'"!="aicc") & ("`ic'"!="ebic") & ("`ic'"!="none") {
		di as err "Option ic(`ic') not allowed. Using the default ic(ebic)."
		local ic ebic
	}
	if ("`ic'"=="ebic") {
		mat `icmat' 	=e(ebic)
		local icmin 	=e(ebicmin)
		local ic EBIC
	}
	else if ("`ic'"=="aic") {
		mat `icmat' 	=e(aic)
		local icmin 	=e(aicmin)
		local ic AIC
	}
	else if ("`ic'"=="bic") {
		mat `icmat' 	=e(bic)
		local icmin 	=e(bicmin)
		local ic BIC
	}
	else if ("`ic'"=="aicc") {
		mat `icmat' 	=e(aicc)
		local icmin 	=e(aiccmin)	
		local ic AICc
	}
	else {
		mat `icmat' 	=.
		local icmin 	=.
		local ic IC
	}
	****************************************************************************
	
	mat `lambdas'	=e(lambdas)'
	mat `dof'		= e(shat)'
	mat `rsq' 		= e(r2_p)'
	mata: `vnames'	=st_matrixcolstripe("e(betas)")		// starts as k x 2
	mata: `vnames'	=(`vnames'[.,2])'					// take 2nd col and transpose into row vector
	mata: `betas'	=st_matrix("e(betas)")
	mata: `r1'		=(`betas'[1,.] :!= 0)
	mata: `addedM'	=select(`vnames', (`r1' :== 1))
	mata: st_local("added",invtokens(`addedM'))
	local knot		=0
	mata: `r1'		=J(1,cols(`betas'),0)
	di
	if "`wnorm'"=="" & "`lambdan'"=="" {
		mat `l1norm' = e(l1norm)'
		di as text "  Knot{c |}  ID     Lambda    s      L1-Norm     `ic'" _c
	}
	else if "`wnorm'"!="" & "`lambdan'"=="" {
		mat `l1norm' = e(wl1norm)'
		di as text "  Knot{c |}  ID     Lambda    s     wL1-Norm     `ic'" _c
	}
	else if "`wnorm'"!="" & "`lambdan'"!="" {
		mat `l1norm' = e(wl1norm)'
		di as text "  Knot{c |}  ID    Lambda/n    s     wL1-Norm     `ic'" _c
	}
	else if "`wnorm'"=="" & "`lambdan'"!="" {
		mat `l1norm' = e(l1norm)'
		di as text "  Knot{c |}  ID    Lambda/n    s     L1-Norm     `ic'" _c
	}
	di as text _col(55) "Pseudo-R2 {c |} Entered/removed"  
	di as text "{hline 6}{c +}{hline 57}{c +}{hline 16}"
	forvalues i=1/`e(lcount)' {
		mata: `r2'			=(`betas'[`i',.] :!= 0)
		mata: `d'			=`r2'-`r1'
		mata: `addedM'		=select(`vnames',(`d' :== 1))
		mata: `allselected' = (sum(`r2':==0))==0 // = 1 if all selected
		mata: st_numscalar("`allsec'",`allselected')
		mata: st_local("added",invtokens(`addedM'))
		mata: `removedM'	=select(`vnames',(`d' :== -1))
		mata: st_local("removed",invtokens(`removedM'))
		if ("`added'`removed'" ~= "") | ("`long'"!="") { 
			if ("`added'`removed'" ~= "") {
				local ++knot
				di as res %6.0f `knot' _c
			}
			di as text _col(7) "{c |}" _c
			di as res %4.0f `i' _c
			di as res _col(13) %10.5f el(`lambdas',`i',1) _c
			di as res _col(25) %4.0f el(`dof',`i',1) _c
			di as res _col(31) %10.5f el(`l1norm',`i',1) _c
			di as res _col(43) %11.5f el(`icmat',`i',1) _c			//  can be negative so add a space
			if ("`long'"!="") & (reldif(`icmin',el(`icmat',`i',1))<10^-5) & ("`icmin'"!=".") {
				di as text "*" _c
			}
			else {
				di as text " " _c
			}
			di as res _col(56) %7.4f el(`rsq',`i',1) _c
			di as text _col(65) "{c |}" _c
			// clear macro
			macro drop _dtext
			if (`i'==1) & (`allsec') {
				local dtext All selected.
			}
			else {
				if "`added'" ~= "" {
					local dtext Added `added'.
				}
				if "`removed'" ~= "" {
					local dtext `dtext' Removed `removed'.
				}
			}
			DispVars `dtext', _lc1(7) _lc2(65) _col(67)
		}
		mata: `r1'		=`r2'
	}
	local iclower = strlower("`ic'")
	if ("`long'"=="") {
		di as text "Use 'long' option for full output." _c
	}
	else if ("`ic'"!="IC") {
		di as text "{helpb lassologit##informationcriteria:*}indicates minimum `ic'." _c
	}
	if ("`ic'"!="IC") & ("`notypemessage'"=="") {
		di as text " "
		di as text "Type e.g. '" _c
		di in smcl "{stata lassologit, lic(`iclower')}" _c
		di as text "' to run the model selected by `ic'."
	}

	// tidy up mata memory
	mata: mata drop `betas' `r1' `r2' `vnames' `d' `addedM' `removedM' `allselected'

end



// Display varlist with specified indentation
program define DispVars
	version 11.2
	syntax [anything] [, _col(integer 15) _lc1(integer 0) _lc2(integer 0) ]
	local maxlen = c(linesize)-`_col'
	local len = 0
	local first = 1
	foreach vn in `anything' {
		local vnlen		: length local vn
		if `len'+`vnlen' > `maxlen' {
			di
			local first = 1
			local len = `vnlen'
			if `_lc1' {
				di as text _col(`_lc1') "{c |}" _c
			}
			if `_lc2' {
				di as text _col(`_lc2') "{c |}" _c
			}
		}
		else {
			local len = `len'+`vnlen'+1
		}
		if `first' {
			local first = 0
			di as res _col(`_col') "`vn'" _c
			}
		else {
			di as res " `vn'" _c
		}
	}
* Finish with a newline
	di
end


/*##############################################################################
#################  STATA UTILITIES #############################################
##############################################################################*/

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


/*##############################################################################
#################  MATA SECTION ################################################
##############################################################################*/

mata: 

mata clear

struct dataStruct {
	
	// data
	pointer matrix X // predictor matrix, full sample
	pointer matrix X1 // predictor matrix, estimation sample
	pointer matrix X0 // corresponds to holdout sample
	pointer colvector y // outcome vector, full sample
	pointer colvector y1 // outcome vector, estimation sample
	pointer colvector y0 // corresponds to holdout sample
	pointer colvector w // weight vector, full sample
	pointer colvector w1 // weight vector, estimation sample
	pointer colvector w0 // weight vector, holdout sample
	real scalar holdout_n //number of obs in the holdout sample
	pointer colvector toest // indicator variable for estimation sample
	pointer colvector holdout // indicator variable for holdout sample
	
	// standardisation and loadings
	real rowvector sdvec
	real rowvector unsdvec
	real rowvector mvec	// = mean(X)
	real scalar ymean
	real rowvector ploadings // penalty loadings
	real rowvector Psi // penalty loadings in metric of unstandardized X
	real rowvector sPsi // penalty loadings in metric of standardized X
	real rowvector Xbyte // =1 if X is a byte, =0 if not (double)
	
	// names
	string scalar Xnames_o
	string scalar XnamesCons_o
	string scalar Xnames_t
	string scalar XnamesCons_t
	string scalar Yname
	string scalar Wname
	string scalar tousename
	string scalar toestname
	string scalar holdoutname
	string scalar NPnames_o
	
	// Stata
	string scalar wtype
	string scalar wexp
	
	// data dimension
	real scalar total_success //sum(y)
	real scalar num_feat // cols(X) incl constant
	real scalar total_trials //sum(w) = number of observations
	real scalar data_rows // rows(X)=rows(y)
	
	// settings
	real scalar postlogit
	real scalar max_iter // maximum number of iterations for the shooting algorithm 
	real scalar tol_opt  // tolerance for shooting algorithm
	real scalar logit // logit or linear; always 1
	real scalar verb
	real scalar cons
	real scalar std
	real scalar stdfly
	real scalar stdsmart
	real scalar srule // sequential rule 
	real scalar tol_zero // minimum below which coeffs are rounded down to zero
	real scalar quadprec
	real scalar subset_ratio
	real scalar progbar
	real scalar ebicxi
	real scalar hdmlambda
}
// end

struct outStruct {

	real matrix betas 
	real matrix betas_std
	real matrix betas_std_post
	real matrix betas_post

	// lcount == 1
	real rowvector beta_post_dense // post-logit without zeros  
	real rowvector beta_dense // without zeros  
	real rowvector beta // logitic lasso estimates  
	real rowvector beta_post
	
	real scalar Xnames
	real scalar Yname
	real scalar cons
	real matrix xb
	real matrix xb0
	real matrix prob // in-sample predicted probabilities
	real matrix prob0 // out-of-sample predicted probabilities
	real rowvector shat // including constant
	real rowvector shat0 // excluding constant
	real rowvector logLik
	real scalar logLikNull // ll of null model
	real rowvector loss
	real rowvector AIC
	real rowvector AICC
	real rowvector BIC
	real rowvector EBIC
	real rowvector r2_p
	real rowvector lambdas
	real rowvector L1norm
	real scalar lcount
	string scalar sel // selected [only used if lcount==1]
	string scalar sel0 // selected exl constant [only used if lcount==1]
	real colvector ix	// index of selected
}
// end


// standardizes data, sets up penalty loadings
void StandardizeData(struct dataStruct d, string scalar matpsi, string scalar matspsi)
{

	// calc mean vector
	if (d.cons) {
		mvec = mean(*d.X1,*d.w1)
		mvec_sd = mvec
		mvec[d.num_feat]=0
		mvec_sd[d.num_feat]=0
	}
	else {
		mvec = 0
		mvec_sd = mean(*d.X1,*d.w1)
	}
	// calc sd vector
	// note that mvec_sd = mean(X) is used even if nocons is assumed
	sdvec = sqrt(mean(((*d.X1):-mvec_sd):^2,*d.w1))
	if (d.cons) {
		sdvec[d.num_feat]=1  // for constant
	}
	// if any element SD of sdvec is 0 (constant var), convention is to set SD to 1
	if (sum(sdvec:==0)) {
		_editvalue(sdvec,0,1)
	}

	// penalty loadings
	if ((matpsi=="") & (matspsi=="") & (d.std)) {
		// default case with standardization
		sPsi = J(1,d.num_feat-d.cons,1)
		Psi = sdvec[1,1..d.num_feat-d.cons]
	}
	else if ((matpsi=="") & (matspsi=="")) {
		// default case without standardization
		sPsi = J(1,d.num_feat-d.cons,1)
		Psi = sPsi
	}
	else if (matpsi~="") {
		// unstandardized penalty loadings provided
		Psi = st_matrix(matpsi)
		// convention is for loadings not to include constant
		if ((rows(Psi)!=1)|(cols(Psi)!=(d.num_feat-d.cons))) {
			printf("{err}dimension of psi vector does not match number of regressors\n")
			exit(3200)
		}
		sPsi = Psi :/ sdvec[1,1..d.num_feat-d.cons]
	}
	else if (matspsi~="") {
		// standardized penalty loadings provided
		sPsi = st_matrix(matspsi)
		// convention is for loadings not to include constant
		if ((rows(sPsi)!=1)|(cols(sPsi)!=(d.num_feat-d.cons))) {
			printf("wrong dimension of ploadings vector\n")
			exit(3200)
		}
		Psi = sPsi :* sdvec[1,1..d.num_feat-d.cons]
	}
	else {
		printf("internal lassologit error\n")
		exit(1)
	}

	if (d.cons) {
		// constant is not penalized
		Psi = Psi , 0
		sPsi = sPsi , 0
	}

	//  need to set loadings of notpen vars = 0
	if (d.NPnames_o~="") {
		// d.NPnames_o is a string that needs to be tokenized; d.XnamesCons_o is already tokenized
		NPnames=tokens(d.NPnames_o)
		forbound = cols(NPnames)	//  faster
		for (i=1; i<=forbound; i++) {
				Psi  =Psi   :* (1:-(d.XnamesCons_o':==NPnames[i]))
				sPsi =sPsi  :* (1:-(d.XnamesCons_o':==NPnames[i]))
		}
	}

	if ((d.std) & (d.stdfly)) {
		// data standardized on the fly
		d.ploadings = Psi
	}
	else if ((d.std) & (d.stdsmart)) {
		// standardize all but byte columns
		prestdindex = selectindex(1:- d.Xbyte)
		(*d.X1)[.,prestdindex] = ( (*d.X1)[.,prestdindex]  :-mvec[prestdindex]  )  :/  sdvec[prestdindex]
		d.ploadings = Psi :* d.Xbyte + sPsi :* (1:-d.Xbyte)
		d.unsdvec = sdvec :* (1:-d.Xbyte) + d.Xbyte
	}
	else if (d.std) {
		// do pre-standardization
		(*d.X1)[.,.] = ((*d.X1):-mvec):/sdvec
		d.ploadings = sPsi
		d.unsdvec = sdvec
	}
	else {
		// data not standardized
		d.ploadings = Psi
	}
	
	// store in d	
	d.sdvec = sdvec
	d.mvec = mvec
	d.ymean = mean(*d.y1,*d.w1)
	d.Psi = Psi
	d.sPsi = sPsi

}

// sets up subviews of estimation and holdout samples
void SelectData(			
					struct dataStruct d
				)
{
	
	// estimation
	st_select(y1,*d.y,*d.toest)
	st_select(X1,*d.X,*d.toest)
	st_select(w1,*d.w,*d.toest)
	
	// holdout
	st_select(y0,*d.y,*d.holdout)
	st_select(X0,*d.X,*d.holdout)
	st_select(w0,*d.w,*d.holdout)
	
	// dimensions
	d.total_success =sum(y1:*w1)
	d.holdout_n = sum(w0)
	d.num_feat =cols(X1)
	if (d.wtype=="fweight") {
		d.total_trials =sum(w1)
	}
	else {
		// avoid sum(.) since non-integer non-fweights could lead to rounding error
		d.total_trials =rows(y1)
	}
	
	// store in d
	d.y1 = &y1
	d.X1 = &X1
	d.w1 = &w1
	d.y0 = &y0
	d.X0 = &X0
	d.w0 = &w0

}
// end

// needed for Stata 14.0 and earlier (probably also 14.1/14.2 pre-19 May 2016)
// in order to select from a data struct from a Stata call
transmorphic dataStructSelect(struct dataStruct d, string scalar obj) {
	if (obj=="total_trials")	return(d.total_trials)
	if (obj=="Wname")			return(d.Wname)
	if (obj=="tousename")		return(d.tousename)
	if (obj=="toestname")		return(d.toestname)
	if (obj=="holdoutname")		return(d.holdoutname)
}

// sets up data struct with main views on data etc.
struct dataStruct scalar MakeData(string scalar nameX_o,    
							string scalar nameX_t,
							string scalar bytelist,
							string scalar nameW,
							string scalar wtype,
							string scalar wexp,
							string scalar nameY,
							string scalar nameTouse,
							string scalar nameToest,
							string scalar nameHoldout,
							string scalar nameNP_o,
							real scalar cons,
							real scalar xstd,
							real scalar stdflyflag,
							real scalar stdsmartflag,
							real scalar postlogit,
							real rowvector settings)
{

	struct dataStruct scalar d

	// full sample
	st_view(y,.,nameY,nameTouse)
	st_view(w,.,nameW,nameTouse)
	// touse variable doubles as the constant
	if (cons) {
		st_view(X,.,nameX_t+" "+nameTouse,nameTouse)
	}
	else {
		st_view(X,.,nameX_t,nameTouse)
	}
	
	// datatypes
	Xbyte = strtoreal(tokens(bytelist))
	if (cons) {
		Xbyte = (Xbyte, 1)
	}

	// sample indicators
	st_view(toest,.,nameToest,nameTouse)
	st_view(holdout,.,nameHoldout,nameTouse)
	
	// Stata
	d.wtype=wtype
	d.wexp=wexp

	// dimensions
	d.num_feat =cols(X)
	
	// store in d
	d.y = &y
	d.X = &X
	d.Xbyte = Xbyte
	d.w = &w
	d.toest = &toest
	d.holdout = &holdout
	d.cons = cons
	d.std = xstd
	d.stdfly = stdflyflag
	d.stdsmart = stdsmartflag

	d.Xnames_o = nameX_o
	d.Xnames_t = nameX_t
	d.NPnames_o = nameNP_o
	if (d.cons) {
		d.XnamesCons_o = (tokens(d.Xnames_o),"_cons")'
		d.XnamesCons_t = (tokens(d.Xnames_t),nameTouse)'
	}
	else {
		d.XnamesCons_o = (tokens(d.Xnames_o))'
		d.XnamesCons_t = (tokens(d.Xnames_t))'
	}
	d.Yname = nameY
	d.Wname = nameW
	d.tousename = nameTouse
	d.toestname = nameToest
	d.holdoutname = nameHoldout
	
	// settings
	d.postlogit = postlogit
	d.max_iter = settings[2]
	d.tol_opt = settings[1]
	d.logit = settings[3]
	d.verb = settings[4]
	d.tol_zero=settings[5]
	d.srule = settings[6]
	d.quadprec = settings[7]
	d.subset_ratio = settings[8]
	d.progbar = settings[9]
	d.ebicxi = settings[10]
	d.hdmlambda = settings[11]
	
	return(d)
}
// end


real colvector calc_prob_xb(struct dataStruct d, ///	
						real colvector xb
						) 
{
	// description: calculates term exp(X*b)/exp(1+exp(X*b))
	// params: X matrix, betas colvector
	// returns: prob colvector

	prob = 1:/(1:+exp(-xb))

	// see 2nd bullet point, p. 9 in Friedman
	//prob = mm_cond(prob :>= .9999, 1, prob)
	//prob = mm_cond(prob :<= .0001, 0, prob)
	
	return(prob)
}
// end

real colvector calc_xb(struct dataStruct d, ///	
						real colvector betas
						) 
{

	power = quadcross((*d.X1)',betas)
	return(power)

}
// end

real colvector calc_prob_pt(struct dataStruct d, ///	
						real colvector betas
						) 
{
	// description: calculates term exp(X*b)/exp(1+exp(X*b))
	// params: X matrix, betas colvector
	// returns: prob colvector

	power = quadcross((*d.X1)',betas)
	//prob = exp(power):/(1:+exp(power))
	prob = 1:/(1:+exp(-power))

	// see 2nd bullet point, p. 9 in Friedman
	//prob = mm_cond(prob :>= .9999, 1, prob)
	//prob = mm_cond(prob :<= .0001, 0, prob)
	
	return(prob)
}
// end

real colvector calc_new_weights(struct dataStruct d,	
						real colvector prob
						) 
{
	// description:
	// eq. (17) in Friedman et al.
	// calculates term p*(1-p)
	// returns:
	// new_weight
	
	new_weight = (*d.w1):*prob:*(1:-prob) 
	
	// see 2nd bullet point, p. 9 in Friedman
	// new_weight = mm_cond(new_weight :<= .0001, .0001, new_weight)
	
	// see 3rd bullet point, p. 9 in Friedman
	//new_weight= J(rows(prob),1,0.25)
	
	return(new_weight)
}
// end

real colvector calc_z_response(struct dataStruct d,	
								real colvector prob,
								real colvector weight1, 
								real colvector power)
{ 
	// Params: y, weight, X, betas
	// Returns: new "working response" z
	// eq. (16) in Friedman et al.
	
	y = (*d.y1):*(*d.w1)
	
	z = power :+ (y :- (*d.w1) :* prob) :/ weight1	

	return(z)
}
// end

real scalar soft_thresholding(real scalar aj,
						real scalar S,
						real scalar lam,
						real scalar ploadj) 
{
	// implements soft-thresholding operator
	// eq. (6) in Friedman et al.
	
	pen = lam*ploadj
		
	// soft-thresholding
    if (S < -pen) {
		bj = (-pen - S) / aj
	}
    else if (S > pen) {
        bj = (pen - S) / aj
	}
	else {
		bj = 0
	}
	
	return(bj)
}
// end


real colvector calc_optimal_betas(struct dataStruct d,	
									real colvector init_betas,
									real scalar lam
									)
{ 

    // For each lambda iteration, determine the converged betas.
    // Stop once the pct change of betas is less than
    // the precision.
	
	// parameters
	init_weights = *d.w1
	num_feat = d.num_feat
	total_trials = d.total_trials
	max_iter=d.max_iter
	tol_opt=d.tol_opt
	
	old_betas = init_betas
	new_betas = init_betas
	new_weights=init_weights
	beta_pct_diff = 1
	iter = 0
	while ((beta_pct_diff > tol_opt) & (iter <= max_iter)) {

		// update weights
		new_xb = calc_xb(d,new_betas)
		new_prob = calc_prob_xb(d,new_xb)	
		new_weights = calc_new_weights(d,new_prob)
		
		// calculate response
		z = calc_z_response(d,new_prob,new_weights,new_xb)
		
		// for S0 term
		c1 = quadcross((*d.X1),new_weights,z) / total_trials // X'y/n
		
		c2 = quadcross((*d.X1),new_weights,(*d.X1)) / total_trials // X'X/n
					
		// loop over j (features)
		for (j=1;j<=num_feat;j++) {

				// S term
				S0 = quadcolsum(c2[j,.]*new_betas) - c2[j,j]*new_betas[j] - c1[j]				

				// soft thresholding
				new_betas[j] = soft_thresholding(c2[j,j],S0,lam,d.ploadings[j]) 		
		
		}
		
		if (sum(abs(new_betas))==0) {
			// break if all zero
			break
		}
		else {
			// calc percentage difference
			beta_pct_diff = mean(abs(new_betas-old_betas))/mean(abs(new_betas))
		}
		
		// iteration count
		iter = iter+1
		// update beta
		old_betas = new_betas
	
	}
	
	// warning if convergence not achieved
	if (d.verb) {
		if (iter<max_iter) {
			printf("Lambda/n="+strofreal(lam)+". Convergence achieved. Iterations="+strofreal(iter)+".\n")
		}
		else {
			printf("Warning: reached max shooting iterations w/o achieving convergence.\n")
		}
	}
	
	return(new_betas)
}
// end


real colvector calc_optimal_betas_cross(struct dataStruct d,	
									real colvector init_betas,
									real scalar lam
									)
{ 

    // For each lambda iteration, determine the converged betas.
    // Stop once the pct change of betas is less than
    // the precision.
	
	// parameters
	init_weights = *d.w1
	num_feat = d.num_feat
	total_trials = d.total_trials
	max_iter=d.max_iter
	tol_opt=d.tol_opt
	
	old_betas = init_betas
	new_betas = init_betas
	new_weights=init_weights
	beta_pct_diff = 1
	iter = 0
	while ((beta_pct_diff > tol_opt) & (iter <= max_iter)) {

		// update weights
		new_xb = calc_xb(d,new_betas)
		new_prob = calc_prob_xb(d,new_xb)	
		new_weights = calc_new_weights(d,new_prob)
		
		// calculate response
		z = calc_z_response(d,new_prob,new_weights,new_xb)
		
		// for S0 term
		c1 = cross((*d.X1),new_weights,z) / total_trials // X'y/n
		
		c2 = cross((*d.X1),new_weights,(*d.X1)) / total_trials // X'X/n
					
		// loop over j (features)
		for (j=1;j<=num_feat;j++) {

				// S term
				S0 = colsum(c2[j,.]*new_betas) - c2[j,j]*new_betas[j] - c1[j]				

				// soft thresholding
				new_betas[j] = soft_thresholding(c2[j,j],S0,lam,d.ploadings[j]) 		
		
		}
		
		if (sum(abs(new_betas))==0) {
			// break if all zero
			break
		}
		else {
			// calc percentage difference
			beta_pct_diff = mean(abs(new_betas-old_betas))/mean(abs(new_betas))
		}
		
		// iteration count
		iter = iter+1
		// update beta
		old_betas = new_betas
	
	}
	
	// warning if convergence not achieved
	if (d.verb) {
		if (iter<max_iter) {
			printf("Lambda/n="+strofreal(lam)+". Convergence achieved. Iterations="+strofreal(iter)+".\n")
		}
		else {
			printf("Warning: reached max shooting iterations w/o achieving convergence.\n")
		}
	}
	
	return(new_betas)
}
// end


real colvector calc_optimal_betas_srule(struct dataStruct d,	
									real colvector init_betas,
									real scalar lam,
									real rowvector srule)
{ 

    // For each lambda iteration, determine the converged betas.
    // Stop once the pct change of betas is less than
    // the precision.
	
	// parameters
	num_feat 		= d.num_feat
	total_trials 	= d.total_trials
	max_iter		= d.max_iter
	tol_opt			= d.tol_opt
	
	do_subsetting =  (sum(srule)/num_feat)<=d.subset_ratio
	
	old_betas 		= init_betas
	new_betas 		= init_betas
	new_weights 	= *d.w1
	beta_pct_diff 	= 1
	iter			= 0
	
	if (do_subsetting) {
	
		while ((beta_pct_diff > tol_opt) & (iter <= max_iter)) {

			// update weights
			new_xb = calc_xb(d,new_betas)
			new_prob = calc_prob_xb(d,new_xb)	
			new_weights = calc_new_weights(d,new_prob)
			
			// update response
			z = calc_z_response(d,new_prob,new_weights,new_xb)
			
			// subset matrix		
			st_select(XT,(*d.X1),srule)
			
			// for S0 term
			c1 = cross(XT,new_weights,z) / total_trials // X'y/n
					
			c2 = cross(XT,new_weights,(*d.X1)) / total_trials // X'X/n
						
			// loop over j (features)
			k=0
			for (j=1;j<=num_feat;j++) {
			
				// seq strong rule
				if (!srule[j])  {
				
					new_betas[j] = 0
					
				}
				else {
				
					k=k+1
					
					// S term
					S0 = colsum(c2[k,.]*new_betas) - c2[k,j]*new_betas[j] - c1[k]				

					// soft thresholding
					new_betas[j] = soft_thresholding(c2[k,j],S0,lam,d.ploadings[j]) 		
				
				}
			
			}
			
			if (sum(abs(new_betas))==0) {
				// break if all zero
				break
			}
			else {
				// calc percentage difference
				beta_pct_diff = mean(abs(new_betas-old_betas))/mean(abs(new_betas))
			}
			
			// iteration count
			iter = iter+1
			// update beta
			old_betas = new_betas
		
		}
		
	} 
	else {	
			
		while ((beta_pct_diff > tol_opt) & (iter <= max_iter)) {

			// update weights
			new_xb = calc_xb(d,new_betas)
			new_prob = calc_prob_xb(d,new_xb)	
			new_weights = calc_new_weights(d,new_prob)
			
			// update response
			z = calc_z_response(d,new_prob,new_weights,new_xb)
			
			// for S0 term
			c1 = cross((*d.X1),new_weights,z) / total_trials // X'y/n
			
			c2 = cross((*d.X1),new_weights,(*d.X1)) / total_trials // X'X/n
						
			// loop over j (features)
			for (j=1;j<=num_feat;j++) {
			
				// seq strong rule
				if (!srule[j])  {
				
					new_betas[j] = 0
					
				}
				else {
				
					// S term
					S0 = colsum(c2[j,.]*new_betas) - c2[j,j]*new_betas[j] - c1[j]				

					// soft thresholding
					new_betas[j] = soft_thresholding(c2[j,j],S0,lam,d.ploadings[j]) 		
				
				}
			
			}
			
			if (sum(abs(new_betas))==0) {
				// break if all zero
				break
			}
			else {
				// calc percentage difference
				beta_pct_diff = mean(abs(new_betas-old_betas))/mean(abs(new_betas))
			}
			
			// iteration count
			iter = iter+1
			// update beta
			old_betas = new_betas
		
		}
	
	}
	
	// warning if convergence not achieved
	if (d.verb) {
		if (iter<max_iter) {
			printf("Lambda/n="+strofreal(lam)+". Convergence achieved. Iterations="+strofreal(iter)+". Seq strong rule dismisses "+strofreal(sum(srule))+" predictors.\n")
		}
		else {
			printf("Warning: reached max shooting iterations w/o achieving convergence.\n")
		}
	}
	
	return(new_betas)
}
// end


struct outStruct scalar fit(struct dataStruct d,			 
					real rowvector lambda_grid
					)
{ 

	struct outStruct scalar r
	
	// get data
	cons = d.cons
	//w = d.w
	
	// dimensions
	total_success = d.total_success //sum(y)
	num_feat = d.num_feat // cols(X); includes constant
	total_trials = d.total_trials //sum(w)

	// lambda_grid
	lambda_num = cols(lambda_grid)
	
	// initial beta
	if (cons) {
		global_rate = total_success / total_trials
		beta_guess = J(num_feat,1,0)
		beta_guess[num_feat] = log(global_rate / (1 - global_rate))
	}
	else {
		beta_guess = J(num_feat,1,0)
	}

	// empty beta_path matrix
	beta_path = J(num_feat,lambda_num,.)
	
	// loop over lambdas
	//if (d.verb==0) {
	//	printf("Loop over lambda values.\n")
	//	printf("----+--- 1 ---+--- 2 ---+--- 3 ---+--- 4 ---+--- 5\n")
	//}
	
	if (lambda_num==1) {
		d.progbar = 0
	}
	if (d.progbar) {
	    dotscmd = "_dots 0 0, title(Obtaining solution for " + strofreal(lambda_num) + " lambdas)"
		stata(dotscmd)
	}

	// estimate beta for given lambda
	// using warm starts (i.e. previous beta estimate)
		
	if ((d.srule) & (!d.quadprec)) {
		
		prob_guess = calc_prob_pt(d,beta_guess)
		svec = calc_score(d,prob_guess)
		
		for (i=1;i<=lambda_num;i++) {
		
		    if (d.progbar) {
                dotscmd = "_dots " + strofreal(i) + " 0"
				stata(dotscmd)
            }
	
			// use sequential strong rule
			
			// index of previous lambda or lambda_max = lambda_grid[1]
			iminus=max((1,i-1))
			
			// sequential rule
			// exclude predictor if
			srule = svec' :< (2*lambda_grid[i]-lambda_grid[iminus])
			// account for not-pen predictors
			srule = srule :* (abs(d.ploadings):>0)
			// srule is now 1 for all included predictors
			srule = 1:-srule
			
			// with sequential rule
			beta_guess=calc_optimal_betas_srule(d,beta_guess,lambda_grid[i],srule)
			
			// check KKT
			if (1) {
				prob_guess = calc_prob_pt(d,beta_guess)
				svec = calc_score(d,prob_guess)
				kkt = svec' :> lambda_grid[i]
				kkt = kkt :- srule
				if (sum(kkt)>0) {
					if (d.verb) {
						printf("  KKT violated. Run again.\n")
					}
					srule = kkt :+ srule
					srule = srule :> 0
					beta_guess=calc_optimal_betas(d,beta_guess,lambda_grid[i])
				}
			}
		
			// save
			beta_path[,i]=beta_guess

		}
	}
	else if (d.quadprec) {	
	
		for (i=1;i<=lambda_num;i++) {
		
			if (d.progbar) {
                dotscmd = "_dots " + strofreal(i) + " 0"
				stata(dotscmd)
            }
		
			beta_guess=calc_optimal_betas(d,beta_guess,lambda_grid[i])
			
			// save
			beta_path[,i]=beta_guess
		
			
		}
			
	}
	else {	
	
		for (i=1;i<=lambda_num;i++) {
		
			if (d.progbar) {
                dotscmd = "_dots " + strofreal(i) + " 0"
				stata(dotscmd)
            }
		
			beta_guess=calc_optimal_betas_cross(d,beta_guess,lambda_grid[i])
			
			// save
			beta_path[,i]=beta_guess
			
		}
			
	}
	//
	
	if (d.progbar) {
		printf("\n")
	}
	
	// return beta path
	r.betas_std = beta_path 
	r.lambdas = lambda_grid
	r.lcount = cols(lambda_grid)

	return(r)

}
// end

void PostResults(struct dataStruct d,			 
						struct outStruct r, 
						string scalar losstype,
						real scalar savephat
						)
{
	// return beta in e() objects
	ereturn_beta(d,r)
	
	// return other parameters
	ereturn_params(d,r)
	
	// return misc
	ereturn_misc(d,r,losstype,savephat)

}

void MakeOutput(struct dataStruct d,			 
						struct outStruct r, 
						string scalar losstype,
						real scalar savephat, // not used
						string scalar stataif
						)
{ 
	
	// calc post-estimation logit
	if (r.lcount==1) {
		// always get post logit if only one lambda
		post_logit(d,r,stataif)
	} 
	else if (d.postlogit) {
		// if many lambdas, 
		// only get post logit if asked for (using "postlogit" option)
		post_logit(d,r,stataif)
	}
	
	// unstandardize logitic lasso coefficients
	if (r.lcount==1) {
		r.betas = unstd_coefs(r.betas_std,d,r)
		r.betas_post = unstd_coefs(r.betas_std_post,d,r)		
	}
	else {
		r.betas = unstd_coefs(r.betas_std,d,r)
	}

	// sparsity
	r.ix = (abs(r.betas):>d.tol_zero)
	r.shat0 = colsum(r.ix)
	r.shat = r.shat0 :- d.cons
	
	// L1-Norm
	r.L1norm = colsum(abs(r.betas))

	// get predicted values
	predict_insample(d,r)
	
	// holdout sample
	if ((d.holdout_n)>0) {
	
		// get out-of-sample predicted values		
		predict_outsample(d,r)
	
		// MSPE etc
		calcLoss(d,r,losstype)
		
	}
		
	// calc Log likelihood
	calcLogLik(d,r)
	
	// calc ICs
	calcICs(d,r)

}
//

real scalar calcRigorousLambda(struct dataStruct d,			 
				real rowvector lam_params)
{
	
	// calculate optimal lambda
	c=lam_params[1]
	gamma = lam_params[2]
	n=d.total_trials
	p = d.num_feat
	if (gamma<=0) {
		if (d.hdmlambda) {
			gamma = 0.1/(log(n)*2*p) // as in rlassologit.R
		}
		else {
			gamma = 0.05/max((p*log(n),n))	
		}
	}
	if (c<=0) {
		c = 1.1
	}
	rlambda = c/2*sqrt(n)*invnormal(1-gamma) 
	rlambda = rlambda / (2*n)
	
	return(rlambda)
}
//end 

real matrix unstd_coefs(real matrix betas_std,
						struct dataStruct d,
						struct outStruct r) 
{	
	// convert beta matrix to original units

	p = d.num_feat - d.cons

	// all but intercept
	if ((d.std) & (d.stdfly==0)) {
		betas_unstd = betas_std[1..p,.]   :/ (d.unsdvec[1..p])'
	}
	else {
		betas_unstd = betas_std[1..p,.]
	}

	// intercept
	if ((d.cons) & (d.stdfly | (d.std==0))) {
		// all vars unstandardized
		betas_unstd = (betas_unstd \ betas_std[d.num_feat,.])
	}
	else if ((d.cons) & (d.stdsmart==0)) {
		// all vars standardized
		// calculate intercept in original units
		cons_est = betas_std[d.num_feat,] :- (d.mvec[1..p] :/ d.unsdvec[1..p])*(betas_std[1..p,.])
		// add intercept in last row
		betas_unstd = (betas_unstd \ cons_est)
	}
	else if (d.cons) {
		// some vars standardized, some not
		cons_est = betas_std[d.num_feat,.]
		// standardized vars
		stdindex = selectindex(1:- d.Xbyte)
		cons_est = cons_est :- (d.mvec[stdindex] :/ d.unsdvec[stdindex])*(betas_std[stdindex,.])
		betas_unstd = (betas_unstd \ cons_est)
	}
	
//	if ((d.std) & (d.stdfly==0) & (!d.cons)) {
//	
//		betas_unstd = betas_std :/ (d.unsdvec)'
//	
//	}
//	else if ((d.std) & (d.stdfly==0) & (d.cons)){
//	
//		//d.betas_std
//	
//		p = d.num_feat-1
//		
//		// convert to original units
//		betas_temp = betas_std[1..p,]   :/ (d.unsdvec[1..p])'
//		
//		// calculate intercept in original units
//		cons_est = betas_std[d.num_feat,] :- (d.mvec[1..p] :/ d.unsdvec[1..p])*(betas_std[1..p,]) 
//				
//		// add intercept in last row
//		betas_unstd = (betas_temp \ cons_est)
//		
//	}
//	else {
//	
//		betas_unstd = betas_std
//
//	}
	
	return(betas_unstd)
	
}
// end


real colvector calc_score(struct dataStruct d,
							real colvector prob)
{	

	S = abs(quadcross(((*d.X1) :- mean(*d.X1,*d.w1)) :/ (editvalue(d.ploadings,0,1)),(*d.w1),((*d.y1)):- prob)):/ d.total_trials	
	return(S)
	
}
//

real rowvector calcDefLambdas(struct dataStruct d,
						real scalar lmax,
						real scalar lcount,
						real scalar lminratio)
{	
	// calculates default lambda grid
	// if no lambda(s) are specified
	
	// lambda-max is defined in Section 5, Tibshirani et al (2011)
	// https://doi.org/10.1111/j.1467-9868.2011.01004.x
	
	// elastic net parameter
	// alpha = 1

	if (lmax <= 0) {
	
		// lmax needs to incorporate penalty loadings
		if (d.cons) {
			ymean = mean(*d.y1)
			// lmax = max(abs(quadcross((*d.X1) :- mean(*d.X1,*d.w1),(*d.w1),((*d.y1)):- ymean/(1- ymean))))/(d.total_trials * alpha)
			lmax = max(abs(quadcross(((*d.X1) :- mean(*d.X1,*d.w1)) :/ (editvalue(d.ploadings,0,1)),(*d.w1),((*d.y1)):- ymean/(1- ymean))))/(d.total_trials)
		}
		else {	
			// lmax = max(abs(quadcross((*d.X1),(*d.w1),(*d.y1):-.5)))/(d.total_trials * alpha)	
			lmax = max(abs(quadcross((*d.X1) :/ (editvalue(d.ploadings,0,1)),(*d.w1),(*d.y1):-.5)))/(d.total_trials)	
		}
	}
	
	lmin = lminratio*lmax
	lambda_grid = exp(rangen(log(lmax),log(lmin),lcount))'

	return(lambda_grid)
	
}
// end

void predict_insample(struct dataStruct d,
					struct outStruct r)
{	
	// obtain predicted values
	if ((r.lcount == 1) & (d.postlogit)) {
		r.xb = quadcross((*d.X1)',r.betas_std_post)
	}
	else {
		r.xb = quadcross((*d.X1)',r.betas_std)	
	}
	r.prob = 1 :/ (1:+exp(-r.xb))

}
// end

void predict_outsample(struct dataStruct d,
					struct outStruct r)
{	
	// obtain predicted values
	// this is using beta-hat in original units
	// X0 was not changed in the memory
	if ((r.lcount == 1) & (d.postlogit)) {
		r.xb0 = quadcross((*d.X0)',r.betas_post)
	}
	else {
		r.xb0 = quadcross((*d.X0)',r.betas)
	}
	r.prob0 = 1 :/ (1:+exp(-r.xb0))
}
// end

void calcLogLik(struct dataStruct d,
						struct outStruct r) 
{
	// log-likelihood of null model
	bNull = ln( d.ymean / (1-d.ymean))
	// weighted
	llNull = ((*d.w1) :* (*d.y1) :* bNull) :- ((*d.w1):*ln(1:+exp(bNull)))
	r.logLikNull = quadcolsum(llNull)

	// same as above
	//r.logLik0 
	//quadcolsum((*d.y):*ln( exp(b0)  :/ (1+exp(b0))) + (1:-(*d.y)) :*ln( 1  :/ (1+exp(b0))) )
	
	// calculates log-likelihood
	// see eq (13)-(14) in Friedman et al. 
	// weighted
	ll = ((*d.w1) :* (*d.y1) :* r.xb) :- ((*d.w1) :* log(1:+exp(r.xb)))
	r.logLik = quadcolsum(ll)  //:/ (d.total_trials)
	//r.plogLik = ll :- r.lambdas :* r.L1norm
	
	//r.logLik1
	//quadcolsum((*d.y):*ln( exp(r.xb)  :/ (1:+exp(r.xb))) + (1:-(*d.y)) :*ln( 1  :/ (1:+exp(r.xb))) )

}
//end

void calcLoss(struct dataStruct d,
						struct outStruct r, 
						string scalar measure) 
{
	// calc root-mean-squared prediction error
	if (measure == "mspe") {
		// r.loss = mean(((r.prob0 :- (*d.y0))):^2)
		// weighted
		r.loss = quadcolsum(((*d.w0):*(r.prob0 :- (*d.y0))))/quadsum(*d.w0)
		//st_matrix("e(loss)",r.rmspe)
		// this is currently wrong. not sure what glmnet is doing.
	}
	else if (measure == "deviance") {
		// Friedman et al, p 10
		// minus twice the log-likelihood on the left-out data (p. 17)
		// cvlognet uses -2*((y==2)*log(predmat)+(y==1)*log(1-predmat))
		dev = (-2*  ( (*d.y0) :* log(r.prob0) :+ (1:-(*d.y0)):*log(1:-r.prob0) ))  
		// r.loss = mean(dev)
		// weighted
		r.loss = quadcolsum( (*d.w0) :* dev ) / quadsum(*d.w0)
	}
	else if (measure == "class") {
		// number of misclassification divided by number of predictions
		pred_class = r.prob0 :> 0.5 // predicted classification
		// r.loss = mean((*d.y0) :!= pred_class)  // mean loss as in glmnet
		// weighted
		r.loss = quadcolsum( (*d.w0) :* ((*d.y0) :!= pred_class) ) / quadsum(*d.w0)
	} 
	else {
		printf("error message. lossmeasure() not supported.")
		printf("only 'deviance', 'class' and 'rmspe' supported.\n")
		exit(198)
	}

}
//end


void calcICs(struct dataStruct d,
						struct outStruct r) 
{
	// takes logLikelihood vector 
 	// and calculated ICs 
	
	// McFadden's pseudo R-squared
	r.r2_p = 1 :- (r.logLik :/ r.logLikNull )
	
	// AIC
	r.AIC = -2 :* r.logLik :+ 2 :*  r.shat

	// corrected AIC
	//r.AICC = -2 :* r.logLik :+ 2 :*  r.shat :* ((d.num_feat):/(d.num_feat :- r.shat:+1))
	// Burnham & Anderson 2004, p. 270 
	r.AICC = r.AIC :+ (2:*(r.shat):*((r.shat):+1)):/((d.total_trials):-(r.shat):-1)
	
	// BIC
	// Burnham & Anderson 2004, p. 275	
	r.BIC = -2 :* r.logLik :+ r.shat :* log(d.num_feat)  	
	
	// see p. 761 in Chen & Chen for EBIC formula
	// and Section 5 for default gamma
	if ((d.ebicxi<0) | (d.ebicxi>1)) {
		ebic_kappa = log(d.num_feat)/log(d.total_trials)
		ebic_xi = 1-1/(2*ebic_kappa)
	}
	r.EBIC = r.BIC :+ 2 :* (r.shat) :* log(d.num_feat) :* ebic_xi
		
}
//end

real rowvector getMinIC(real rowvector IC,
						real rowvector lam)		
{
	// based on getMinIC in lassoutils.ado	
	licid=.
	minindex(IC,1,licid,.)	// returns index of lambda that minimises ic
		if (rows(licid)>1) {    // no unique lopt -- just take first
			licid=licid[1,1] 	
			icmin=IC[1,licid]
			licunique=0
		}
		else {
			icmin=IC[1,licid]
			licunique=1
		}
	lopt = lam[licid] // = the lambda that minimises IC
	return((licid,icmin,licunique,lopt))
}
// end 

void post_logit(struct dataStruct d,
						struct outStruct r,
						string scalar stataif) 
{
	// loop over lambda
	betas_post = J(d.num_feat,r.lcount,0)
	for (j=1;j<=r.lcount;j++) {
		ix = selectindex(r.betas_std[,j])
		vars_token = (d.XnamesCons_t)
		sel=vars_token[ix]
		shat = rows(sel)
		if (shat>0) {
			sel=invtokens(sel')
			bhat = logit_est(d,sel,stataif)
			bigbhat = J(d.num_feat,1,0)
			bigbhat[ix] = bhat
			betas_post[,j]=bigbhat
		}
	}

	if (r.lcount == 1) {
		r.betas_std_post = betas_post // save both post-logit and logistic lasso.
	}
	else {
		r.betas_std = betas_post // overwrite logistic lasso. only report post-logit.
	}
}
//

real colvector logit_est(struct dataStruct d,
						string scalar selected,
						stataif) 
{

	// _logit drops variable if they predict failure perfectly => mismatch in #predictors
	// use logit so that the coefficient vector has a 0 if it the var was dropped
	// ms: still to do - capture what happens if logit fails completely, e.g., if outcome doesn't vary
	//     also - what happens if vars and obs are dropped because failure is predicted perfectly

	statawt = "["+d.wtype+d.wexp+"]"
	// max iterations set to 100; to code an option for overriding.
	if (!d.cons) {
		// nocons => logit Xvarlist is jsut selected; use nocons option
		options = " " + statawt + " " + stataif + ", nocons"
		Xvarlist = selected
	}
	else {
		// constant => remove by-hand constant from selected to get logit Xvarlist
		options = " " + statawt + " " + stataif + ","
		if (cols(tokens(selected))>1) {
			Xvarlist = invtokens(tokens(selected)[1,1..cols(tokens(selected))-1])
		}
		else {
			// if constant then #cols=1 => nothing selected besides the constant
			Xvarlist = ""
		}
	}
	options = options + " iterate(100)"
	stata("qui logit "+" "+d.Yname+" " +Xvarlist +options)
	if (st_numscalar("e(converged)")==0) {
		ic = st_numscalar("e(ic)")
		printf("warning: post-logit did not converge after %f iterations.\n",ic)
	}

	b = st_matrix("e(b)")

	return(b')
}
// end

void ereturn_beta(struct dataStruct d,
						struct outStruct r)
{

	// set colnames of beta
	brnames = (J(d.num_feat,1,""),(d.XnamesCons_o))
		
	// store lambda
	if (r.lcount==1) {
	
		if ((sum(r.ix)==0) & (!d.cons)) {
			printf("Nothing selected. Reduce lambda and/or add constant.\n")
			exit(error(1))
		}
	
		// selected vars
		selected0 = select(d.XnamesCons_o,r.ix)
		selected0 = invtokens(selected0')
		if (d.cons) {
			selected = subinstr(selected0," _cons","")
		}
		else {
			selected = selected0
		}
		dense_names = (J(r.shat0,1,""),tokens(selected0)')
		r.sel=selected
		r.sel0=selected0
		
		// sparsity
		st_numscalar("e(shat)",r.shat)
		st_numscalar("e(shat0)",r.shat0)
	
		// store lambda
		st_numscalar("e(lambda)",r.lambdas)
		
		// store beta
		st_matrix("e(beta)",r.betas')
		st_matrix("e(beta_std)",r.betas_std')
		st_matrix("e(beta_dense)",select(r.betas,r.ix)')
		
		// return post-logit 
		st_matrix("e(beta_post)",r.betas_post')
		st_matrix("e(beta_std_post)",r.betas_std_post')
		st_matrix("e(beta_post_dense)",select(r.betas_post,r.ix)')
			
		// set col names
		st_matrixcolstripe("e(beta)",brnames)
		st_matrixcolstripe("e(beta_std)",brnames)
		st_matrixcolstripe("e(beta_post)",brnames)
		st_matrixcolstripe("e(beta_std_post)",brnames)
		st_matrixcolstripe("e(beta_dense)",dense_names)
		st_matrixcolstripe("e(beta_post_dense)",dense_names)
	}
	else {
		
		// sparsity
		st_matrix("e(shat)",r.shat)
		st_matrix("e(shat0)",r.shat0)
		
		// store lambda
		st_matrix("e(lambdas)",r.lambdas)
		
		st_matrix("e(l1norm)",r.L1norm)
		
		// store beta
		st_matrix("e(betas)",r.betas')
		st_matrix("e(betas_std)",r.betas_std')
		
		// set row names
		st_matrixcolstripe("e(betas)",brnames)
		st_matrixcolstripe("e(betas_std)",brnames)
		
	}
	
	// by convention, we don't save the loadings etc. for the constant
	st_matrix("e(sdvec)",d.sdvec[1,1..d.num_feat-d.cons])
	st_matrix("e(ploadings)",d.ploadings[1,1..d.num_feat-d.cons])
	st_matrix("e(Psi)",d.Psi[1,1..d.num_feat-d.cons])
	st_matrix("e(sPsi)",d.sPsi[1,1..d.num_feat-d.cons])

	// set col names
	st_matrixcolstripe("e(sdvec)",brnames[1..d.num_feat-d.cons,.])
	st_matrixcolstripe("e(ploadings)",brnames[1..d.num_feat-d.cons,.])
	st_matrixcolstripe("e(Psi)",brnames[1..d.num_feat-d.cons,.])
	st_matrixcolstripe("e(sPsi)",brnames[1..d.num_feat-d.cons,.])

}
//


void ereturn_params(struct dataStruct d,
						struct outStruct r)
{
	st_numscalar("e(p)",d.num_feat-d.cons)
	st_numscalar("e(cons)",d.cons)
	st_numscalar("e(std)",d.std)
	st_numscalar("e(total_success)",d.total_success)
	st_numscalar("e(total_trials)",d.total_trials)		// duplicates
	st_numscalar("e(N)",d.total_trials)					// duplicates
	st_numscalar("e(lcount)",r.lcount)
	st_numscalar("e(N_holdout)",d.holdout_n)
}
//

void ereturn_misc(struct dataStruct d,
						struct outStruct r,
						string scalar measure,
						real scalar savephat
						)
{
	// from predict_insample
	if (savephat) {
		st_matrix("e(phat)", r.prob )
	}

	// if holdout sample
	if ((d.holdout_n)>0) {
	
		// from predict_outsample
		if (savephat) {
			st_matrix("e(phat0)",r.prob0)
		}
	
		// from calcLoss
		st_matrix("e(loss)",r.loss)
		
	}

	// from calcLogLik
	if (r.lcount==1) {
		st_numscalar("e(ll)",r.logLik)
	}
	else {
		st_matrix("e(ll)",r.logLik')
	}
	// LogLik of null model
	st_numscalar("e(ll0)",r.logLikNull)
		
	// from calcICs
	st_numscalar("e(ebic_xi)")
	
	if (r.lcount == 1) {
		st_numscalar("e(aic)",r.AIC)
		st_numscalar("e(bic)",r.BIC)
		st_numscalar("e(aicc)",r.AICC)
		st_numscalar("e(ebic)",r.EBIC)	
		st_numscalar("e(r2_p)",r.r2_p)
	}
	else {
	
		st_matrix("e(r2_p)",r.r2_p)
	
		st_matrix("e(aic)",r.AIC')
		st_matrix("e(bic)",r.BIC')
		st_matrix("e(aicc)",r.AICC')
		st_matrix("e(ebic)",r.EBIC')
		
		AICinfo=getMinIC(r.AIC,r.lambdas)	
		st_numscalar("e(aicid)",AICinfo[1])
		st_numscalar("e(aicmin)",AICinfo[2])
		st_numscalar("e(aiclambda)",AICinfo[4])
		
		AICCinfo=getMinIC(r.AICC,r.lambdas)	
		st_numscalar("e(aiccid)",AICCinfo[1])
		st_numscalar("e(aiccmin)",AICCinfo[2])
		st_numscalar("e(aicclambda)",AICCinfo[4])
		
		BICinfo=getMinIC(r.BIC,r.lambdas)	
		st_numscalar("e(bicid)",BICinfo[1])
		st_numscalar("e(bicmin)",BICinfo[2])
		st_numscalar("e(biclambda)",BICinfo[4])	
		
		EBICinfo=getMinIC(r.EBIC,r.lambdas)	
		st_numscalar("e(ebicid)",EBICinfo[1])
		st_numscalar("e(ebicmin)",EBICinfo[2])
		st_numscalar("e(ebiclambda)",EBICinfo[4])
		
		st_numscalar("e(lmin)",min(r.lambdas))
		st_numscalar("e(lmax)",r.lambdas[1])
		
	}

	if (r.lcount == 1) {
		st_global("e(selected)",r.sel)
		st_global("e(selected0)",r.sel0)
	}
	st_global("e(varX)",d.Xnames_o)
	st_global("e(predict)","lassologit_p")
	st_global("e(cmd)","lassologit")
	st_global("e(wtype)",d.wtype)
	st_global("e(wexp)",d.wexp)

}


void s_maketemps(real scalar p)
{
	(void) st_addvar("double", names=st_tempname(p), 1)
	st_global("r(varlist)",invtokens(names))
}

end		
