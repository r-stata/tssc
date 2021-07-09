*! version 1.1.2 12Jun2018 

// checked RMST DM and Mest with bootstrapping

// work on other scales 
// make certain transformations the default
// check rel surv models work for M-estimation
// error check for factor variables??

// error checks for centiles
// test ifs....
// weights for extenal standardisation.

// add weights

program define stpm2_standsurv, rclass
	version 12.2
	syntax [if] [in],			 							///
		[													///	
		ATVars(string)										/// list or stub for at variables
		CONTRASTVars(string)								/// list or stub for contrasts
		LINCOMVar(string)									///	name of new variables for linear combination
		USERFUNCTIONVar(string)								///	name of new variables for userfunction
		ATReference(integer 1)								/// reference at() - default 1
		TImevar(varname) 									/// timepoints for predictions
		CONtrast(string)	 								/// type of contrast
		TRansform(string)									/// Transformation for variance calculation
		CENTILE(numlist)									///	centiles of standardized curve
		HAZard												/// standardized hazard function
		RMST												/// restricted mean survival time
		SURVival											/// standardized survival function (default)
		CI 													/// request CI to be calculated
		PER(integer 1)										/// per option (multiply to give pys etc)
		FAILure												/// calculate failure function
		CENTVar(string)										/// name of new centile variable (default _centvar)
		CENTILEUpper(real -99)								/// starting value for upper bound of centile search
		NOdes(integer 30)									/// number of nodes for numerical integration
		MESTimation											/// use M-estimation
		LEVel(real `c(level)')								/// level for CIs
		SE													/// calculate standard error
		LINCOM(string)										///
		INDWeights(string)									/// multiply observations by weights
		VERBOSE												/// show what is happening (speed tests)
		RUNMATA												///
		USERFunction(string)								/// user defined function
		*													/// atn() options
		]
	
	tempvar touse_time touse_model xb expxb dxb  expxb0
	marksample touse, novarlist
// default to standardized survival function
	if wordcount("`centile' `hazard' `survival' `rmst' `failure'") == 0 local survival "survival"
	if wordcount("`hazard' `survival' `rmst' `failure'") + ("`centile'" != "") > 1 {
		di as error "You can only specify one of the survival, hazard, centile and rmst options"
		exits 198
	}
	if "`e(cmd)'" != "stpm2" {
		di as error "You need to fit an stpm2 model to use stpm2_standsurv"
		exit 198
	}
// check moremata installed	
	capture findfile lmoremata.mlib	
	if _rc {
		display in yellow "You need to install moremata to use stpm2_stand"
		display in yellow "Type {stata ssc install moremata}, or just click on the link"
        exit  198
	}	
	summ _t if _d==1 & e(sample), meanonly
	local maxt `r(max)'
	
// Check no factor variables
	fvexpand `e(varlist)'
	if "`r(fvops)'" == "true" {
		di as error "stpm2_standsurv does not allow factor variables" 
		di as error "Refit the model using dummy variables etc"
		exit 198
	}
	
	
// M-estimation for centiles
	if "`centile'" != "" local mestimation mestimation
	
// Extract at() options
	local optnum 1
	local end_of_ats 0
	local 0 ,`options'
	while `end_of_ats' == 0 {
		capture syntax [,] AT`optnum'(string) [*]
		if _rc {
			local N_at_options = `optnum' - 1
			local end_of_ats 1
			continue, break
		}
		else local 0 ,`options'
		local optnum = `optnum' + 1
	}
	local N_at_options = `optnum' - 1
	if "`0'" != "," {
		di as error "Illegal option: `0'"
		exit 198
	}
	local hasatoptions = `N_at_options' > 0
	if !`hasatoptions' local N_at_options 1

// Parse at() options	
// Probably does not work with factor variables
	if `hasatoptions' > 0 {
		forvalues i = 1/`N_at_options' {
	// parse "if" suboption
			tokenize "`at`i''", parse(",")
			local at`i'opt  `1'
			local atoptif `3'
			local 0 ,`3'
			syntax ,[if2(string)]
			if `"`if'"' != "" & `"`atoptif'"' != "" {
				di as error "You can either use an if statement or the if suboptions" _newline ///
							"of the at() options"
				exit 198
			}
			tempvar touse_at`i'
			if `"`atoptif'"' == "" {
				gen byte `touse_at`i'' = `touse'
			}
			else {
				gen byte `touse_at`i'' = (`if2')
			}

			tokenize `at`i'opt'
			while "`1'"!="" {
				if "`1'" == "." continue, break
				fvunab tmpfv: `1'
				local 1 `tmpfv'
				cap confirm var `1'
				if _rc {
					di "`1' is not in the data set"
				}
				local at`i'vars `at`i'vars' `1'
				if "`2'" != "=" {
					cap confirm num `2'
					if _rc {
						di as err "invalid at(... `1' `2' ...)"
						exit 198
					}
					local at`i'_`1'_value `2'
					mac shift 2
					
				}
				else {
					cap confirm var `3'
					if _rc {
						di as err "`var' is not in the data set"
						exit 198
					}				
					local at`i'_`1'_value .
					local at`i'_`1'_variable `3'
					mac shift 3
				}
			}
		}
	}
	else {
		tempvar touse_at1
		gen byte `touse_at1' = `touse'
	}

// Number of observations for each at() option	
	local varsinmodel = subinstr(strtrim(stritrim("`e(varlist)' `e(tvc)'"))," ",",",.)
	forvalues i = 1/`N_at_options' {
		quietly count if `touse_at`i'' == 1 & !missing(`varsinmodel')
		local Nobs_predict_at`i' `r(N)'
		local touse_at_list `touse_at_list' `touse_at`i''
	}
// names of new variables
	if "`atvars'" == "" {
		forvalues i = 1/`N_at_options' {
			local at_varnames `at_varnames' _at`i'
		}
	}
	else {
		capture _stubstar2names double `atvars', nvars(`N_at_options') 
		local at_varnames `s(varlist)'
		if _rc>0 {
			di as error "atvars() option should either give `N_at_options' new variable names " ///
				"or use the {it:stub*} option. The specified variable(s) probably exists."
			exit 198
		}
	}
	if "`contrastvars'" == "" {
		forvalues i = 1/`N_at_options' {
			if `i' == `atreference' continue
			local contrast_varnames `contrast_varnames' _contrast`i'_`atreference'
		}
	}
	else {
		capture _stubstar2names double `contrastvars', nvars(`=`N_at_options'-1') 
		local contrast_varnames  `s(varlist)'
		if _rc>0 {
			di as error "contrastvars() option should either give `=`N_at_options'-1' new variable names " ///
				"or use the {it:stub*} option. The specified variable(s) probably exists."
			exit 198
		}
	}
	if "`lincomvar'" == "" {
		local lincom_varname _lincom
	}
	else local lincom_varname `lincomvar'
	
	if "`userfunctionvar'" == "" {
		local userfunction_varname _userfunc
	}
	else local userfunction_varname `userfunctionvar'	
	
	if `atreference' != 1 {
		if !inrange(`atreference',1,`N_at_options') {
			di as error "atreference option out of range"
			exit 198
		}
	}
// Transform option
	if "`transform'" == "" local transform log
	if !inlist("`transform'","loglog","logit","log","none") {
		di as error "Transform options are none, log, loglog or logit"
		exit 198
	}
// Number of observations used in the model	
	quietly gen `touse_model' = e(sample)
	quietly count if `touse_model' == 1
	local Nobs_model `r(N)'

// time variable
	if "`timevar'" == "" local timevar _t
	gen byte `touse_time' = `timevar' != .

// currently only work with scale(hazard)
if "`e(scale)'" != "hazard" {
	di as error "stpm2_standsurv only currently works with scale(hazard) models."
	exit 198
}	
	
// Check contrast option	
	if "`contrast'" != "" {
		if !inlist("`contrast'","difference","ratio","pchange") {
			di as error "contrast option should either be difference or ratio"
			exit 198
		}
	}

// **** CHECK THESE ARE NEEDED WITH DELTA METHOD *****
// Use meansurv for point estimates
	if "`indweights'" != "" {
		local weight_option meansurvwt(`indweights')
	}

// exception if using meansurv with no contrast (use predict, meansurv as faster)	
	if "`survival'" != "" & "`mestimation'" == "" & "`contrast'" == "" & "`lincom'" == "" & "`userfunction'" == "" & "`runmata'" == "" local meansurv_nomata 1
	
	if "`verbose'" != "" di in yellow "Predicting point estimates using meansurv"
	if "`meansurv_nomata'" == "" {
		if "`survival'" != "" | "`hazard'" != "" | "`failure'" != "" {
			forvalues i = 1/`N_at_options' {
				tempvar S`i'
				if `hasatoptions' {
					if ("`at`i'opt'" == ".") local tempatopt
					else local tempatopt at(`at`i'opt')
				}
				quietly predict `S`i'' if `touse_at`i'', meansurv `tempatopt' timevar(`timevar') `weight_option'
				local Smean_list `Smean_list' `S`i''
			}
		}
		if "`hazard'" != "" {
			forvalues i = 1/`N_at_options' {
				tempvar h`i' f`i'
				if `hasatoptions' {
					if ("`at`i'opt'" == ".") local tempatopt
					else local tempatopt at(`at`i'opt')
				}
				quietly predict `f`i'' if `touse_at`i'', meanft `tempatopt' timevar(`timevar') `weight_option'
				local fmean_list `fmean_list' `f`i''
			}
		}

		if "`rmst'" != "" {
			forvalues i = 1/`N_at_options' {
				tempvar rmst`i'
				if `hasatoptions' {
					if ("`at`i'opt'" == ".") local tempatopt
					else local tempatopt at(`at`i'opt')
				}
				local rmst_newvarname `rmst`i''
				mata: rmst_stand()
				local rmstmean_list `rmstmean_list' `rmst`i''
			}
		}
		// Need rootfinder to get centiles of standardized curves
		if "`centile'" != "" {
			if `centileupper' == -99 local centileupper = `maxt'*2
			if "`centvar'" == "" local centvar _centvals
			confirm new var `centvar'
			qui gen `centvar' = .
			local i = 1
			foreach c of numlist `centile' {
				qui replace `centvar' = `c' in `i'
				local ++i
			}
			tempvar touse_centiles
			gen byte `touse_centiles' = `centvar' != .
			
			forvalues i = 1/`N_at_options' {
				tempvar c`i'
				if `hasatoptions' {
					if ("`at`i'opt'" == ".") local tempatopt
					else local tempatopt at(`at`i'opt')
				}
				local newcentvar `c`i''
				mata: stand_centile()
				local centile_list `centile_list' `c`i''
			}
		}

	// predict xb and dxb (need for CIs)	
		if ("`ci'" != "" | "`se'" != "") & "`mestimation'" != "" {
			if "`verbose'" != "" di in yellow "Predicting xb and dxb"
			quietly predict `xb'  if e(sample), xb
			quietly predict `dxb' if e(sample) , dxb
			if `e(del_entry)' & "`mestimation'" != "" {
				qui _predict `expxb0' if _t0>0 & e(sample), eq(xb0)
				qui replace `expxb0' = exp(`expxb0') if _t0>0 & e(sample)
				qui replace `expxb0' = 0 if _t0==0 & e(sample) 
			}
		}
		if "`verbose'" != "" di in yellow "Calling main mata program"
		mata: standsurv()
	}
	else {
		forvalues i = 1/`N_at_options' {
			if `hasatoptions' {
				if ("`at`i'opt'" == ".") local tempatopt
				else local tempatopt at(`at`i'opt')
			}
			local newv = word("`at_varnames'",`i')
			quietly predict `newv' if `touse_at`i'', meansurv `tempatopt' timevar(`timevar') `weight_option' `ci'
		}	
	}
// Warnings
	if "`centile'" != "" {
		foreach var in `at_varnames' {
			quietly count if (`var'>`maxt') & (`touse_centiles')
			if `r(N)'>0 {
				di as result "Warning: centile point estimate for `var' > maximum event time"
			}
			if "`ci'" != "" {
				quietly count if (`var'_uci>`maxt') & (`touse_centiles')
				if `r(N)'>0 {
					di as result "Warning: CI for centile for `var' > maximum event time"
				}	
			}
		}
	}
	
// Return stuff
	return local varmethod=cond("`mestimation'" == "","delta-method","M-estimation")
end

// note need to run build_ado to put mata programs at the end of this file
mata


	


//======================================================================================================================================//
// Main structure for main analysis
struct stpm2_standardisation {
		real scalar		N_at_options, 		// number of at options
						hasatoptions,		// has at options
						Nobs_model,			// N in model
						calchazard,			// calculate hazard
						calcsurvival,		// calculate survival
						calcfailure,		// calculate failure function
						calcrmst,			// calculate rmst
						calccentile,		// calculate centiles
						deltamethod,		// use delta method
						mestimation,		// use M estimation
						verbose,			// display stage of estimation (speed tests)
						loopmax,			// loop for calculating centiles
						at_reference,		// reference at level
						hascontrast,		// contrast option
						haslincom,			// has linear combination
						hasuserfunction,	// has userfunction combination
						hasweights,			// as indweight option
						se,					// calculate standard error
						ci,					// indicator to calculate CIs
						per,				// multiply estimates by per
						level,				// level for CI (default 95%)
						dots,				// print dots as loop over t
						hasfailure,			// has the failure option,
						hascons,			// has a constant term in the model
						hastvc,				// has time-dependent effects
						hasdel_entry,		// has delayed entry
						hasbhazard,			// has bhazard option
						orthog,				// orthogonalisation of splines
						rcsbaseoff,			// rcsbaseoff option specified
						Ntvc,				// Number of tvc variables
						Nt,					// Number of time points to predict at
						Nvarlist,			// Number of main effects (excluding constant)
						hasvarlist,			// Has a varlist
						Nparameters,		// Number of parameters
						df,					// df for baseline
						Ncentiles,
						Nnodes,				// Number of nodes for integration for rmst
						j
						

		string scalar	touse_time,			// indicator for timevar
						touse_model,		// touse e(sample)
						touse_centiles,
						contrast,			// type of contrast
						transform,			// type of transformation for CI
						scale				// scale option for model
	
		real matrix 	Nobs_predict_at,	// Number of observations for each at() option
						Smean,				// Standardised survival
						hmean,				// Standardised hazard
						fmean,				// mean of f(t)
						rmstmean,			// rmst of standardized survival
						centmean,
						xb,					// linear predictor
						expxb,				// exp of linear predictor
						dxb,				// derivative of linear predictor
						expxb0,				// exp of linear predictor for delayed entry
						d,					// event indicator
						obst,				// observed time (_t)
						t,					// times to predict at
						bhazard,			// expected hazard rate
						touse_at,			// touse option for each at option
						X,					// design matrix
						Xdrcs,				// derivative for design matrix
						nodeweights,		// weights for numerical integration
						nodes,				// nodes for numerical integration
						beta,				// beta coefficients
						betarcs,			// spline coefficients
						dftvc,				// df for time-dependent effects
						V,					// Variance matrix
						tj,					// current value of time
						Si,					// Individual contribution to mean survival
						hi,					// Individual contribution to mean hazard
						fi,					// Contribution to density
						rmsti,				// contribution to RMST				
						ResVcov,			// Variance 
						Vest,				//
						lincom,				// linear combination of at options
						weights				// weight (for external standardization)

		string matrix	at_vars,			// Name of variables for each at() option.	
						at_varnames,		// Names of new variables
						tvcnames,			// Names of tvc variables
						contrast_varnames,	// Names of contrast variables
						lincom_varname,		// Names of linear combination
						userfunction_varname // Name of user_functions
					
	transmorphic matrix	knots,				// array for knot locations	
						Rmatrix,			// Array for Rmatrix
						X_at,				// Change in X matrix for at() options
						X_at_index,			// Index of covariate that needs to change
						X_at_tvc,			// Changed  tvc covariates for at() options
						X_at_t,				// change for at within loop
						Xrcstvc,			// tvc splines while looping over t
						Xdrcstvc,			// spline derivatives while looping over t
						Xdrcs_at_t,			// spline derivatives while looping over t
						Sti_nodes,			// survival function at nodes
						dxbi_nodes,
						Xrcsbase,			// Used when looping over t
						Xdrcsbase,			// Used when looping over t
						rcs_nodes
						
	pointer				GenA11,				// Generate A11 depending on standardisation option
						GenA22,				// Generate A22 depending on standardisation option
						GenA12,				// Generate A12 depending on standardisation option
						GenU,				
						Stgen,				// generate survival depending on scale
						htgen,				// generate hazard depending on scale
						RMSTgen,			// generate RMST depending on scale
						Gen_Sderiv,			// derivative of survival function
						GenUbeta,
						Gen_fderiv,
						Gen_RMSTderiv
}


//======================================================================================================================================//
// Structure for Results 
struct stpm2_standardisation_results {
	real matrix CI_at_lci,				// array for at CI
				CI_at_uci,
				at_est,
				se,
				CI_contrast_lci,
				CI_contrast_uci,
				contrast_est,
				CI_lincom_lci,
				CI_lincom_uci,	
				lincom_est,
				userfunction_est,
				CI_userfunction_lci,
				CI_userfunction_uci
				
	pointer scalar userfunction
}

//======================================================================================================================================//
// GetStuff() - get options and data and store in struct		
function GetStuff() {
	struct stpm2_standardisation scalar S
	S.verbose = st_local("verbose") != ""
	if(S.verbose) display("Reading in things to set up structure")
	S.N_at_options = strtoreal(st_local("N_at_options"))	
	S.hasatoptions = S.N_at_options >1
	S.touse_time = st_local("touse_time")							
	S.touse_model = st_local("touse_model")	
	S.Nobs_model = strtoreal(st_local("Nobs_model"))
	S.calchazard = st_local("hazard") != ""
	S.calcsurvival = st_local("survival") != ""
	S.calcfailure = st_local("failure") != ""
	S.calcrmst = st_local("rmst") != ""
	S.calccentile = st_local("centile") != ""
	S.deltamethod = st_local("mestimation") == ""
	S.mestimation = 1- S.deltamethod
	if(S.calccentile) S.loopmax = S.N_at_options
	else S.loopmax = 1
	S.Nobs_predict_at = J(1,S.N_at_options,.)
	S.at_vars = J(1,S.N_at_options,"")
	for(i=1;i<=S.N_at_options;i++) {
		S.Nobs_predict_at[1,i] = strtoreal(st_local("Nobs_predict_at"+strofreal(i)))
		S.at_vars[1,i] = st_local("at"+strofreal(i)+"vars")
	}
	S.at_reference = strtoreal(st_local("atreference"))
	S.at_varnames = tokens(st_local("at_varnames"))
	S.hascontrast = st_local("contrast") != ""
	S.haslincom = st_local("lincom") != ""
	S.hasuserfunction = st_local("userfunction") != ""
	S.hasweights = st_local("indweights") != ""
	S.contrast = st_local("contrast")
	S.ci = st_local("ci") != ""	
	S.se = st_local("se") != ""
	S.level = strtoreal(st_local("level"))
	S.per = strtoreal(st_local("per"))
	S.transform = st_local("transform")
	S.hasfailure = st_local("failure") != ""
	S.hascons = st_global("e(noconstant)") == ""
	S.hastvc = st_global("e(tvc)") != ""
	S.hasdel_entry = st_numscalar("e(del_entry)")
	S.hasbhazard = st_global("e(bhazard)") != ""
	S.orthog = st_global("e(orthog)") != ""
    S.rcsbaseoff = st_global("rcsbaseoff") != ""
	S.df = st_numscalar("e(dfbase)")
	S.scale = st_global("e(scale)")
	if (S.hastvc) {
		S.tvcnames = tokens(st_global("e(tvc)"))
		S.Ntvc = cols(S.tvcnames)
	}
	else S.Ntvc = 0
	if(S.hascontrast) S.contrast_varnames = tokens(st_local("contrast_varnames"))
	if(S.haslincom)	S.lincom_varname = st_local("lincom_varname")
	if(S.hasuserfunction) S.userfunction_varname = st_local("userfunction_varname")
//======================================================================================================================================//
// Variables created in Stata
	if(S.calcsurvival | S.calchazard | S.calcfailure) S.Smean = st_data(.,(st_local("Smean_list")),S.touse_time)	
	if(S.calchazard) {
		S.fmean = st_data(.,(st_local("fmean_list")),S.touse_time)	
		S.hmean = S.fmean:/S.Smean
	}
	if(S.calcrmst) {
		S.rmstmean = st_data(.,(st_local("rmstmean_list")),S.touse_time)	
	}
	if(S.calccentile) {
		S.touse_centiles = st_local("touse_centiles")							
		S.centmean = st_data(.,(st_local("centile_list")),S.touse_centiles)
		S.Ncentiles = rows(S.centmean)
	}
	S.t = st_data(.,st_local("timevar"),S.touse_time)
	S.Nt = rows(S.t)
	if(S.ci | S.se) {
		if(S.mestimation) {
			S.xb = st_data(.,st_local("xb"),S.touse_model)	
			S.expxb = exp(S.xb)								
			S.dxb = st_data(.,st_local("dxb"),S.touse_model)
			S.d = st_data(.,"_d",S.touse_model)
			if(S.hasbhazard) {
				S.bhazard = st_data(.,st_global("e(bhazard)"),S.touse_model)
				S.obst = st_data(.,"_t",S.touse_model)
			}
			if(S.hasdel_entry) S.expxb0 = st_data(.,st_local("expxb0"),S.touse_model)

		}
		S.touse_at = st_data(.,st_local("touse_at_list"),S.touse_model)

		if(S.hasweights) S.weights = st_data(.,st_local("indweights"),S.touse_model)
		else S.weights = 1

		//======================================================================================================================================//
// get knot locations and df for each knot
		S.knots = asarray_create()
		S.dftvc = J(1,S.Ntvc,.)
		if(!S.rcsbaseoff) asarray(S.knots,"baseline",strtoreal(tokens(st_global("e(ln_bhknots)"))))
		if(S.hastvc) {
			for(i=1;i<=S.Ntvc;i++) {
				asarray(S.knots,S.tvcnames[i],strtoreal(tokens(st_global("e(ln_tvcknots_"+S.tvcnames[i]+")")))) 
				S.dftvc[1,i] = st_numscalar("e(df_"+S.tvcnames[i]+")")
			}
		}

//======================================================================================================================================//
// get R matrices	
		S.Rmatrix = asarray_create()
		if(S.orthog & !S.rcsbaseoff) asarray(S.Rmatrix,"baseline",st_matrix("e(R_bh)"))
		else asarray(S.Rmatrix,"baseline",J(0,0,.))
		if(S.hastvc) {
			for(i=1;i<=S.Ntvc;i++) {
				if(S.orthog) asarray(S.Rmatrix,S.tvcnames[i],st_matrix("e(R_"+S.tvcnames[i]+")"))
				else asarray(S.Rmatrix,S.tvcnames[i],J(0,0,.))
			}
		}	

//======================================================================================================================================//
// Observed X matrix and derivative of spline functions
		S.Nvarlist = cols(tokens(st_global("e(varlist)")))
		S.hasvarlist = S.Nvarlist>0
		covariates = J(1,0,"")
		drcsvars = J(1,0,"")
		if(S.Nvarlist > 0) covariates = covariates, tokens(st_global("e(varlist)")) 
			if(!S.rcsbaseoff) {
			covariates = covariates, tokens(st_global("e(rcsterms_base)"))
			drcsvars = drcsvars, tokens(st_global("e(drcsterms_base)"))
		}
		if(S.hastvc) {
			for(i=1;i<=S.Ntvc;i++) {
				covariates = covariates, tokens(st_global("e(rcsterms_"+S.tvcnames[i]+")"))
				drcsvars = drcsvars, tokens(st_global("e(drcsterms_"+S.tvcnames[i]+")"))
			}
		}
		S.X = st_data(.,covariates,S.touse_model) // 
		if(S.hascons) S.X = S.X,J(S.Nobs_model,1,1)
		S.Xdrcs = st_data(.,drcsvars,S.touse_model)

		S.Nparameters = cols(S.X)
		S.Nparameters = cols(covariates) + S.hascons
		S.beta = st_matrix("e(b)")'[1..S.Nparameters,1]
		S.betarcs = S.beta[(S.Nvarlist+1)..(S.Nparameters - S.hascons)]
		S.V = st_matrix("e(V)")[1..S.Nparameters,1..S.Nparameters]
	
//======================================================================================================================================//
// changes to X matrix needed for at() options
		S.X_at = asarray_create()
		S.X_at_index = asarray_create()
		if(S.hastvc) S.X_at_tvc = asarray_create() 
		for(i=1;i<=S.N_at_options;i++) {
			ati = "at" + strofreal(i)
			asarray(S.X_at_index,ati,J(1,0,.))
			asarray(S.X_at,ati,J(S.Nobs_model,0,.))
			// main effects
			for(j=1;j<=S.Nvarlist;j++) {
				if(subinword(S.at_vars[1,i],covariates[j],"") != S.at_vars[1,i]) {
					asarray(S.X_at_index,ati, (asarray(S.X_at_index,ati), j))
					atval_macro = st_local("at" + strofreal(i) + "_" + covariates[j]+"_value")
					if(atval_macro != ".") {
						asarray(S.X_at,ati,(asarray(S.X_at,ati), J(S.Nobs_model,1,strtoreal(atval_macro))))
					}
					else {
						asarray(S.X_at,ati,(asarray(S.X_at,ati), st_data(.,st_local("at" + strofreal(i) + "_" + covariates[j]+"_variable"),S.touse_model)))
					}
				}
			}
			// tvcs
			if(S.hastvc) {
				asarray(S.X_at_tvc,ati, J(S.Nobs_model,0,.))
				for(j=1;j<=S.Ntvc;j++) {
					if(subinword(S.at_vars[1,i],S.tvcnames[j],"") != S.at_vars[1,i]) {
						atval_macro = st_local("at" + strofreal(i) + "_" + S.tvcnames[j]+"_value")
						asarray(S.X_at_tvc, ati, (asarray(S.X_at_tvc, ati),J(S.Nobs_model,1,strtoreal(atval_macro)))) 
					}
					else {
						asarray(S.X_at_tvc,ati, (asarray(S.X_at_tvc,ati), st_data(.,S.tvcnames[j],S.touse_model)))
					}
				}
			}
		}
	}
// linear combination
	if(S.haslincom) {
		S.lincom = strtoreal(tokens(st_local("lincom")))
	}
	
// nodes for rmst
	if(S.calcrmst) {
		S.Nnodes = strtoreal(st_local("nodes"))
		gq(S.nodeweights,S.nodes)
	}
	if(S.verbose) display("Finished setting up structure")
	return(S)
}

//======================================================================================================================================//	
// Get DeclarePointers - declare all pointers

function DeclarePointers(struct stpm2_standardisation scalar S)
{
	if(S.calcsurvival) {
		S.GenA11 = &GenA11_surv()
		S.GenA22 = &GenA22_surv()
		S.GenA12 = &GenA12_surv()
		S.GenU = &GenU_surv()
	}
	if(S.calcfailure) {
		S.GenA11 = &GenA11_surv()
		S.GenA22 = &GenA22_surv()
		S.GenA12 = &GenA12_surv()
		S.GenU = &GenU_failure()
	}	
	else if(S.calchazard) {
		S.GenA11 = &GenA11_hazard()
		S.GenA22 = &GenA22_hazard()
		if(S.mestimation) S.GenA12 = &GenA12_hazard_mestimation()
		else S.GenA12 = &GenA12_hazard_deltamethod()
		S.GenU = &GenU_hazard()
	}
	else if(S.calcrmst) {
		S.GenA11 = &GenA11_surv()		// same as survival
		S.GenA22 = &GenA22_surv()		// same as survival
		S.GenA12 = &GenA12_rmst()
		S.GenU = &GenU_rmst()			
	}
	else if(S.calccentile) {
		S.GenA11 = &GenA11_centile()
		S.GenA22 = &GenA22_surv()		// same as survival
		S.GenU = &GenU_centile()
		S.GenA12 = &GenA12_surv()		// same as survival
	}
// scale option
	if(S.scale == "hazard") {
		S.Stgen = &Stgen_hazard()
		S.htgen = &htgen_hazard()
		S.RMSTgen = &RMSTgen_hazard()
		S.Gen_Sderiv = &Gen_Sderiv_hazard()
		S.Gen_fderiv = &Gen_fderiv_hazard()
		S.Gen_RMSTderiv = &Gen_RMSTderiv_hazard()

		if(S.hasbhazard) {
			S.GenUbeta = &GenUbeta_hazard_rs()
		}
		else S.GenUbeta = &GenUbeta_hazard()
	}
	else if(S.scale == "odds") {
		S.Stgen = &Stgen_odds()
		S.htgen = &htgen_odds()
		S.RMSTgen = &RMSTgen_odds()
		S.Gen_Sderiv = &Gen_Sderiv_odds()
		if(S.hasbhazard) {
			S.GenUbeta = &GenUbeta_odds_rs()
		}
		else S.GenUbeta = &GenUbeta_odds()
	}
}



//======================================================================================================================================//
// main functions


//======================================================================================================================================//
// standsurv() - main function
void function standsurv()
{
	struct stpm2_standardisation scalar S
	struct stpm2_standardisation_results scalar R
	S = GetStuff()
	R = CreateResultsMat(S)
	DeclarePointers(S)
	if(S.ci) {
		if(S.deltamethod) standsurv_deltamethod(S,R)
		else if(S.mestimation) standsurv_Mestimation(S,R)
	}
	WriteResults(S,R)
}

//======================================================================================================================================//
// standsurv() - Delta Method
void function standsurv_deltamethod(struct stpm2_standardisation scalar S, struct stpm2_standardisation_results scalar R) 
{
	if(S.verbose) timer_clear()

	S.ResVcov = asarray_create("real")
	for(j=1;j<=S.Nt;j++) {
		if(S.verbose) display("Time point " + strofreal(j))
		S.tj = S.t[j]
		S.j = j
		lnt = ln(S.tj)
		if(S.verbose) timer_on(1)
		GenSplines(S,lnt)
		if(S.verbose) timer_off(1)
		if(S.verbose) timer_on(2)
		GenX_at(S)
		if(S.verbose) timer_off(2)	
		if(S.calchazard) {
			GenDerivSplines(S,lnt)
			Gen_Xdrcs_at(S)
		}
		if(S.verbose) timer_on(3)
		GenUind(S)
		if(S.verbose) timer_off(3)
		if(S.verbose) timer_on(4)
		A12 = (*S.GenA12)(S)
		if(S.verbose) timer_off(4)
		asarray(S.ResVcov,j,(A12*S.V*A12')) 
		if(S.verbose) timer_on(5)
		CalcCI_at(S,R,j)
		if(S.hascontrast) CalcContrasts(S,R,j)
		if(S.haslincom) CalcLincom(S,R,j)
		if(S.hasuserfunction) CalcUserfunction(S,R,j)
		if(S.verbose) timer_off(5)
	}
	
}

//======================================================================================================================================//
// standsurv() - M estimation
void function standsurv_Mestimation(struct stpm2_standardisation scalar S, struct stpm2_standardisation_results scalar R) {
// Get matrices needed for all measures	that do not depend on t
	Ubeta = (*S.GenUbeta)(S)
	(*S.GenA22)(S,A22,zeros)
	S.ResVcov = asarray_create("real")
	if(S.calcsurvival | S.calcrmst | S.calcfailure) (*S.GenA11)(S,A11)	// does not vary over t
	if(S.calccentile) S.Nt = S.Ncentiles
	for(j=1;j<=S.Nt;j++) {
		if(S.calccentile) S.tj = S.centmean[j,]
		else S.tj = S.t[j]
		lnt = ln(S.tj)
		GenSplines(S,lnt)
		if(S.calchazard | S.calccentile) {
			GenDerivSplines(S,lnt)
			Gen_Xdrcs_at(S)
		}
		GenX_at(S)
		GenUind(S)
		if(S.calchazard | S.calccentile) (*S.GenA11)(S,j,A11)
		// A12 and U depend on what is standardized.
		U = (*S.GenU)(S,j) 
		A12 = (*S.GenA12)(S)
		// Now put everything together	
		VarU = quadvariance((U,Ubeta))
		Ainv = luinv((A11, A12 \ zeros, A22))
		asarray(S.ResVcov,j,((Ainv*VarU*Ainv'):/S.Nobs_model)[1..S.N_at_options,1..S.N_at_options])
		// Calculate CI for at() options & contrasts
		CalcCI_at(S,R,j)
		if(S.hascontrast) CalcContrasts(S,R,j) 		
		if(S.haslincom) CalcLincom(S,R,j)
		if(S.hasuserfunction) CalcUserfunction(S,R,j)
	}
}

//======================================================================================================================================//	
// Get U_beta (derivative of score function) as does not depend on t.
// Same for all options
// Need to add h_star....

function GenUbeta_hazard(struct stpm2_standardisation scalar S)
{
	Ubeta = (S.d :- S.expxb):*S.X
	dxb_select=(S.Nvarlist+1..S.Nparameters-S.hascons)
	Ubeta[,dxb_select] = Ubeta[,dxb_select] :+ (S.d:/S.dxb):*S.Xdrcs
	if(S.hasdel_entry) Ubeta = Ubeta + S.expxb0:*S.X 
	return(Ubeta)
}

void function GenUbeta_odds(struct stpm2_standardisation scalar S)
{
	Ubeta = (S.d :- S.expxb):/(1:+S.expxb):*S.X
	dxb_select=(S.Nvarlist+1..S.Nparameters-S.hascons)
	Ubeta[,dxb_select] = Ubeta[,dxb_select] + (S.d:/S.dxb):*S.Xdrcs
	if(S.hasdel_entry) Ubeta = Ubeta + S.expxb0:/(1:+S.expxb0):*S.X 
	return(Ubeta)
}

function GenUbeta_hazard_rs(struct stpm2_standardisation scalar S)
{
	Ubeta = (S.expxb:*(S.d:*S.dxb :/ (S.expxb:*S.dxb:+S.obst:*S.bhazard):-1)):*S.X
	dxb_select=(S.Nvarlist+1..S.Nparameters-S.hascons)
	Ubeta[,dxb_select] = Ubeta[,dxb_select] + (S.d:*S.expxb:/(S.expxb:*S.dxb:+S.obst:*S.bhazard)):*S.Xdrcs
	if(S.hasdel_entry) Ubeta = Ubeta + S.expxb0 :*S.X 
	return(Ubeta)
}


function GenUbeta_odds_rs(struct stpm2_standardisation scalar S)
{
	Ubeta = -(S.expxb:*(-S.d:*S.dxb:+S.obst:*S.bhazard:+
				S.expxb:*(S.dxb:+S.t:*S.bhazard))):/
				((1:+S.expxb):*(S.t:*S.bhazard :+ S.expxb:*(S.dxb:+ S.obst:*S.bhazard))):*S.X
	dxb_select=(S.Nvarlist+1..S.Nparameters-S.hascons)
	Ubeta[,dxb_select] = Ubeta[,dxb_select] + S.d:*S.expxb:/(S.t:*S.bhazard :+ S.expxb:*(S.dxb :+ S.obst:*S.bhazard)):*S.Xdrcs
	if(S.hasdel_entry) Ubeta = Ubeta + S.expxb0:/(1:+S.expxb0):*S.X  
	return(Ubeta)
}


//======================================================================================================================================//	
// A11 and A22 do not depend on t for survival
real matrix function GenA11_surv(struct stpm2_standardisation scalar S,A11)
{
	A11 = -1*I(S.N_at_options)
}

real matrix function GenA22_surv(struct stpm2_standardisation scalar S,A22,zeros)
{
	A22 = -luinv(S.V):/ S.Nobs_model
	zeros = J(S.Nparameters,S.N_at_options,0)
}

//======================================================================================================================================//	
// A11 varies by t for hazard, but not A22
real matrix function GenA11_hazard(struct stpm2_standardisation scalar S, real scalar j, A11)
{
//	A11 =  diag((S.Smean[j,],-mean(S.touse_at),-mean(S.touse_at)))
	A11 =  diag((S.Smean[j,],J(1,S.N_at_options,-1),J(1,S.N_at_options,-1)))
	index_start = S.N_at_options + 1
	index_stop = index_start + S.N_at_options - 1
	A11[1..S.N_at_options,index_start..index_stop] = (-I(S.N_at_options))
	index_start = 2*S.N_at_options + 1
	index_stop = index_start + S.N_at_options - 1
	A11[1..S.N_at_options,index_start..index_stop] = diag(S.hmean[j,])
}

real matrix function GenA22_hazard(struct stpm2_standardisation scalar S,A22,zeros)
{
	A22 = -luinv(S.V):/ S.Nobs_model
	zeros = J(S.Nparameters,S.N_at_options:*3,0)
}

//======================================================================================================================================//	
// A11 varies by centile, but not A22
real matrix function GenA11_centile(struct stpm2_standardisation scalar S, real scalar j, A11) 
{
	A11 = -diag(colsum(S.weights:*S.fi:*S.touse_at):/S.Nobs_predict_at)
}

//======================================================================================================================================//
// GenSplines function - generate baseline and tvc splines (at different t values for centile options).
// Within arrays for splines use "0" for survival, hazard and rmst "at"+i for centiles

void function GenSplines(struct stpm2_standardisation scalar S,lnt) 
{	
	if(!S.rcsbaseoff) S.Xrcsbase = asarray_create()
	if(S.hastvc) S.Xrcstvc = asarray_create("string",2)
	for(i=1;i<=S.loopmax;i++) {
		ati = "at" + strofreal(i)
		if(S.calccentile) asarray_index = ati
		else asarray_index = "0"
		if(!S.rcsbaseoff) {
			if(S.orthog) asarray(S.Xrcsbase,asarray_index,rcsgen_core(lnt[i],asarray(S.knots,"baseline"),0,asarray(S.Rmatrix,"baseline")))
			else asarray(S.Xrcsbase,asarray_index,rcsgen_core(lnt[i],asarray(S.knots,"baseline"),0))
		}
		if(S.hastvc) {
			for(k=1;k<=S.Ntvc;k++) {
				if(S.orthog) asarray(S.Xrcstvc,(asarray_index,S.tvcnames[k]),rcsgen_core(lnt[i],asarray(S.knots,S.tvcnames[k]),0,asarray(S.Rmatrix,S.tvcnames[k])))
				else asarray(S.Xrcstvc,(asarray_index,S.tvcnames[k]),rcsgen_core(lnt[i],asarray(S.knots,S.tvcnames[k]),0))
			}
		}
	}
}

//======================================================================================================================================//
// GenDerivSplines function - loops over at options and calculates derivative of spline functions
// Within arrays for splines use "0" for survival, hazard and rmst "at"+i for centiles
void function GenDerivSplines(struct stpm2_standardisation scalar S,real matrix lnt) 
{	
	S.Xdrcsbase = asarray_create()
	if(S.hastvc) S.Xdrcstvc = asarray_create("string",2)
	for(i=1;i<=S.loopmax;i++) {
		ati = "at" + strofreal(i)
		if(S.calccentile) asarray_index = ati
		else asarray_index = "0"
		if(S.orthog) asarray(S.Xdrcsbase,asarray_index,rcsgen_core(lnt[i],asarray(S.knots,"baseline"),1,asarray(S.Rmatrix,"baseline")))
		else asarray(S.Xdrcsbase,asarray_index,rcsgen_core(lnt[i],asarray(S.knots,"baseline"),1))
		if(S.hastvc) {
			for(k=1;k<=S.Ntvc;k++) {
				if(S.orthog) asarray(S.Xdrcstvc,(asarray_index,S.tvcnames[k]),rcsgen_core(lnt[i],asarray(S.knots,S.tvcnames[k]),1,asarray(S.Rmatrix,S.tvcnames[k])))
				else asarray(S.Xdrcstvc,(asarray_index,S.tvcnames[k]),rcsgen_core(lnt[i],asarray(S.knots,S.tvcnames[k]),1))
			}
		}
	
	}
}

//======================================================================================================================================//
// Different X matrices for each at() option
// returns S.X_at_t
void function GenX_at(struct stpm2_standardisation scalar S)
{
	S.X_at_t = asarray_create()
	for(i=1;i<=S.N_at_options;i++) {
		ati = "at" + strofreal(i)
		if(S.calccentile) asarray_index = ati
		else asarray_index = "0"
		
		X_tmp = J(S.Nobs_model,S.Nparameters,.)
		if(S.hasvarlist) X_tmp[,1..S.Nvarlist] = S.X[,1..S.Nvarlist]
		X_tmp[,asarray(S.X_at_index,ati)] = asarray(S.X_at,ati)

		Xstart = S.Nvarlist + 1
		Xstop = Xstart + S.df - 1

		if(!S.rcsbaseoff) X_tmp[,Xstart..Xstop] = J(S.Nobs_model,1,asarray(S.Xrcsbase,asarray_index))
		if(S.hastvc) {
			for(k=1;k<=S.Ntvc;k++) {
				Xstart = Xstop + 1
				Xstop = Xstart + S.dftvc[k] - 1
				X_tmp[,Xstart..Xstop] = asarray(S.Xrcstvc,(asarray_index,S.tvcnames[k])) # asarray(S.X_at_tvc,ati)[,k]
			}
		}
		if(S.hascons) X_tmp[,S.Nparameters] = J(S.Nobs_model,1,1)
		asarray(S.X_at_t,ati,X_tmp)
	}
}

//======================================================================================================================================//
// Different spline derivative matrix for each at() option
// returns S.Xdrcs_at_t
// could speed up (see function above)

void function Gen_Xdrcs_at(struct stpm2_standardisation scalar S) {
	S.Xdrcs_at_t = asarray_create()
	for(i=1;i<=S.N_at_options;i++) {
		ati = "at" + strofreal(i)
		if(S.calccentile) asarray_index = ati
		else asarray_index = "0"		
		X_tmp = J(S.Nobs_model,0,.)			
		if(!S.rcsbaseoff) X_tmp = X_tmp,J(S.Nobs_model,1,asarray(S.Xdrcsbase,asarray_index))
		if(S.hastvc) {
			for(k=1;k<=S.Ntvc;k++) {
				X_tmp = X_tmp,J(S.Nobs_model,1,asarray(S.Xdrcstvc,(asarray_index,S.tvcnames[k]))):*asarray(S.X_at_tvc,ati)[,k]
			}
		}
		asarray(S.Xdrcs_at_t,ati,X_tmp)
	}	
}


//======================================================================================================================================//
// generates survival and hazard functions for each at option
// uses pointers to call appropraite survial/hazard functions
void function GenUind(struct stpm2_standardisation scalar S)
{
	if(!S.calcrmst) S.Si = J(S.Nobs_model,S.N_at_options,.)
	if(S.calchazard | S.calccentile) {
		S.hi = J(S.Nobs_model,S.N_at_options,.)
		S.fi = J(S.Nobs_model,S.N_at_options,.)
	}
	if(S.calcrmst) {
		S.rmsti = J(S.Nobs_model,S.N_at_options,.)
		S.Sti_nodes = asarray_create() // create as needed for A12
	}
	for(i=1;i<=S.N_at_options;i++) {
		ati = "at" + strofreal(i)
		if(S.calccentile) tt = S.tj[i]
		else tt = S.tj
		if(!S.calcrmst) S.Si[,i] = (*S.Stgen)(S,ati) 
		if(S.calchazard | S.calccentile) {
			S.hi[,i] = (*S.htgen)(S,ati,tt) 
			S.fi[,i] = S.Si[,i]:*S.hi[,i]
		}
		if(S.calcrmst) {
			S.rmsti[,i] = (*S.RMSTgen)(S,ati)
		}
	}
}

//======================================================================================================================================//
// survival and hazard function for each scale 
// need to add other scales
function Stgen_hazard(struct stpm2_standardisation scalar S,string scalar ati) 
{
	return(exp(-exp(asarray(S.X_at_t,ati)*S.beta)))
}	
function Stgen_odds(struct stpm2_standardisation scalar S,string scalar ati) 
{
	return((1 :+ exp(asarray(S.X_at_t,ati)*S.beta)):^(-1))
}

// Note that also creates S.Sti_nodes for use when calculating A12
real matrix function RMSTgen_hazard(struct stpm2_standardisation scalar S,string scalar ati) 
{
	nodes_t = (0.5:*S.tj:*S.nodes :+ 0.5:*S.tj)
	xb_tmp = J(S.Nobs_model,S.Nnodes,.)
	S.rcs_nodes = J(S.Nparameters-S.Nvarlist-S.hascons,S.Nnodes,.)
	for(n=1;n<=S.Nnodes;n++) {
		tn = nodes_t[n]
		lntn = ln(tn)
		if(S.hasvarlist) X_tmp = S.X[,1..S.Nvarlist]
		else X_tmp = J(S.Nobs_model,0,.)
		if(S.hasvarlist) X_tmp[,asarray(S.X_at_index,ati)] = asarray(S.X_at,ati)
		if(!S.rcsbaseoff) {
			if(S.orthog) rcstmp = rcsgen_core(lntn,asarray(S.knots,"baseline"),0,asarray(S.Rmatrix,"baseline"))
			else rcstmp = rcsgen_core(lntn,asarray(S.knots,"baseline"),0)
			S.rcs_nodes[1..S.df,n] = rcstmp'
			X_tmp = X_tmp, J(S.Nobs_model,1,rcstmp)
		}
		p_index = S.df + 1 
		if(S.hastvc) {
			for(k=1;k<=S.Ntvc;k++) {
				if(S.orthog) rcstmp = rcsgen_core(lntn,asarray(S.knots,S.tvcnames[k]),0,asarray(S.Rmatrix,S.tvcnames[k]))
				else rcstmp = rcsgen_core(lntn,asarray(S.knots,S.tvcnames[k]),0,)
				cols_select = (p_index..p_index + cols(rcstmp) - 1)
				S.rcs_nodes[cols_select,n] = rcstmp'
				X_tmp = X_tmp, J(S.Nobs_model,1,rcstmp):*asarray(S.X_at_tvc,ati)[,k]
				p_index = p_index + S.dftvc[1,k]
			}
		}
		if(S.hascons) X_tmp = X_tmp,J(S.Nobs_model,1,1)
		xb_tmp[,n] = (X_tmp*S.beta)
	}
	asarray(S.Sti_nodes,ati,exp(-exp(xb_tmp)))
	return(0.5:*S.tj:*quadrowsum(S.nodeweights':*asarray(S.Sti_nodes,ati),1))
}
	
function htgen_hazard(struct stpm2_standardisation scalar S,string scalar ati,tt) {
	return((asarray(S.Xdrcs_at_t,ati)*S.betarcs):/tt :* (exp(asarray(S.X_at_t,ati)*S.beta)))
}
function htgen_odds(struct stpm2_standardisation scalar S,string scalar ati,tt) {
	return((asarray(S.Xdrcs_at_t,ati)*S.betarcs):/tt :* (exp(asarray(S.X_at_t,ati)*S.beta)):*(1:+exp(asarray(S.X_at_t,ati)*S.beta)):^(-1))
}

	
//======================================================================================================================================//
// A12 matrix
// returns A12
// Survival

// generic functions for scales using pointers
real matrix function GenA12_surv(struct stpm2_standardisation scalar S)
{
	A12 = J(S.N_at_options,S.Nparameters,.)
	for(i=1;i<=S.N_at_options;i++) 	{
		A12[i,] = (*S.Gen_Sderiv)(S,i)
	}
	if(S.calcfailure) _negate(A12)
	return(A12)
}

real matrix function Gen_Sderiv_hazard(struct stpm2_standardisation scalar S,i) {
	ati = "at" + strofreal(i)
	return(colsum(S.weights:*S.Si[,i] :* log(S.Si[,i]):*asarray(S.X_at_t,ati):*S.touse_at[,i]):/S.Nobs_predict_at[,i])
}
real matrix  function Gen_Sderiv_odds(struct stpm2_standardisation scalar S,i) {
	ati = "at" + strofreal(i)
	return(mean(S.weights:*S.Si[,i] :* log(S.Si[,i]):*asarray(S.X_at_t,ati):*S.touse_at[,i]))
}

// Hazard
// odds need updating
// generic functions for scales using pointers

real matrix function GenA12_hazard_mestimation(struct stpm2_standardisation scalar S)
{
	A12 = J(S.N_at_options:*3,S.Nparameters,.)
	A12[1..S.N_at_options,1..S.Nparameters] = J(S.N_at_options,S.Nparameters,0)
	for(i=1;i<=S.N_at_options;i++) {
		ati = "at" + strofreal(i)
		findex = i :+ S.N_at_options
		Sindex = i :+ 2*S.N_at_options
		A12[findex,] = (*S.Gen_fderiv)(S,i)
		A12[Sindex,] = (*S.Gen_Sderiv)(S,i) 
	}
	return(A12)
}



real matrix function GenA12_hazard_deltamethod(struct stpm2_standardisation scalar S)
{
	A12 = J(S.N_at_options,S.Nparameters,.)
	for(i=1;i<=S.N_at_options;i++) {
		ati = "at" + strofreal(i)
		A12[i,] =((*S.Gen_fderiv)(S,i):*S.Smean[S.j,i] - (*S.Gen_Sderiv)(S,i):*S.fmean[S.j,i]):/(S.Smean[S.j,i]:^2)
	}
	return(A12)
}

// derivative of f(t) for scale(hazard) models
real matrix function Gen_fderiv_hazard(struct stpm2_standardisation scalar S,i) {
	ati = "at" + strofreal(i)
	dxb_select=(S.Nvarlist+1..S.Nparameters-S.hascons)
	A12f = colsum(S.weights:*S.fi[,i]:*asarray(S.X_at_t,ati):*(log(S.Si[,i]) :+ 1):*S.touse_at[,i]):/S.Nobs_predict_at[,i]
	A12f[,dxb_select] = A12f[,dxb_select] :- colsum(S.weights:*(asarray(S.Xdrcs_at_t,ati):*S.Si[,i] :* log(S.Si[,i]):/S.tj):*S.touse_at[,i]):/S.Nobs_predict_at[,i]
	return(A12f)
}



// Just here for placement
// currently just a copy of hazard scale
function Gen_fderiv_odds(struct stpm2_standardisation scalar S,i) {
/*	ati = "at" + strofreal(i)
	dxb_select=(S.Nvarlist+1..S.Nparameters-S.hascons)
	A12f = mean(S.fi[,i]:*asarray(S.X_at_t,ati):*(1 - 2:*:/S.Si[,i])   :*(log(S.Si[,i]) :+ 1):*S.touse_at[,i])
	A12f[,dxb_select] = A12f[,dxb_select] :- mean((asarray(S.Xdrcs_at_t,ati):*S.Si[,i] :* log(S.Si[,i]):/S.tj):*S.touse_at[,i])
	return(A12f)
*/
}

// RMST
real matrix function GenA12_rmst(struct stpm2_standardisation scalar S)
{
	A12 = J(S.N_at_options,S.Nparameters,.)
	for(i=1;i<=S.N_at_options;i++) {
		A12[i,] = (*S.Gen_RMSTderiv)(S,i)
	}
	return(A12)
}

real matrix function Gen_RMSTderiv_hazard(struct stpm2_standardisation scalar S,real scalar i)
{
	ati = "at" + strofreal(i)
	A12i = J(1,S.Nparameters,.) 
	rcs_index = tvc_index = 1
	for(k=1;k<=S.Nparameters;k++) {
		if(k<=S.Nvarlist | (k==S.Nparameters & S.hascons)) {
			A12i[1,k] = 0.5:*S.tj:*quadrowsum(S.nodeweights':*mean(S.weights:*asarray(S.Sti_nodes,ati):*log(asarray(S.Sti_nodes,ati)):*asarray(S.X_at_t,ati)[,k]:*S.touse_at[,i]),1) 
		}
		else if (k>S.Nvarlist & k<=(S.Nvarlist +  S.df)){
			A12i[1,k] = 0.5:*S.tj:*quadrowsum(S.nodeweights':*mean(S.weights:*asarray(S.Sti_nodes,ati):*log(asarray(S.Sti_nodes,ati)):*S.rcs_nodes[rcs_index,]:*S.touse_at[,i]),1)
			rcs_index++
		}
		else {
			A12i[1,k] = 0.5:*S.tj:*quadrowsum(S.nodeweights':*mean(S.weights:*asarray(S.Sti_nodes,ati):*log(asarray(S.Sti_nodes,ati)):*S.rcs_nodes[rcs_index,]:*asarray(S.X_at_tvc,ati)[,tvc_index]:*S.touse_at[,i]),1) 
			rcs_index++
			if (k>=(S.Nvarlist +  S.df + rowsum(S.dftvc[1..tvc_index]))) tvc_index++
		}
	}	
	return(A12i)
}

//======================================================================================================================================//
// U matrix
// Survival
real matrix function GenU_surv(struct stpm2_standardisation scalar S,real scalar j)
{	
	return((S.weights:*S.Si:*S.touse_at :- S.Smean[j,]))
}

real matrix function GenU_failure(struct stpm2_standardisation scalar S,real scalar j)
{	
	return((S.Smean[j,] :- S.weights:*S.Si:*S.touse_at))
}
	
// Hazard
real matrix function GenU_hazard(struct stpm2_standardisation scalar S,real scalar j)
{	
	return((J(S.Nobs_model,1,S.Smean[j,]:*S.hmean[j,] :- S.hmean[j,]),(S.weights:*S.fi :- S.fmean[j,]):*S.touse_at,(S.weights:*S.Si :- S.Smean[j,]):*S.touse_at))
}
// RMST 
real matrix function GenU_rmst(struct stpm2_standardisation scalar S,real scalar j)
{	
	return((S.weights:*S.rmsti:*S.touse_at :- S.rmstmean[j,]))
}

// centile
real matrix function GenU_centile(struct stpm2_standardisation scalar S,real scalar j)
{	
	return((S.weights:*S.Si:*S.touse_at :- S.centmean[j,]))
}



// This file contins the following functions
//
// mm_root_vec()	- Brent's root finder
// epsilon_vec()	- check if root found to degree of accuracy
// gq()				- guassian quadrature nodes and weights
// rcsgen_core()	- generate restricted cubic splines

//======================================================================================================================================//
// mm_root_vec - adpated form Michael Crowther's adaption of Ben Jann mm_root.
real colvector mm_root_vec(transmorphic x,      // bj: will be replaced by solution
						 pointer(real scalar function) scalar f,
											  // Address of the function whose zero will be sought for
						 real scalar ax,      // Root will be sought for within a range [ax,bx]
						 real scalar bx,      //
						 | real scalar tol,   // Acceptable tolerance for the root value (default 0)
						   real scalar maxit, // bj: maximum # of iterations (default: 1000)
						   o1, o2, o3, o4, o5, o6, o7, o8, o9, o10)            // bj: additional args to pass on to f
{
    transmorphic  fs            // setup for f
    real colvector   a, b, c       // Abscissae, descr. see above
    //real scalar   fa, fb, fc    // f(a), f(b), f(c)
    real scalar   prev_step     // Distance from the last but one
    real scalar   tol_act       // Actual tolerance
    real scalar   p             // Interpolation step is calcu-
    real scalar   q             // lated in the form p/q; divi-
                                // sion operations is delayed
                                // until the last moment
    real scalar   new_step      // Step at this iteration
    real scalar   t1, cb, t2
    real scalar   itr

	real scalar nobs 
	real colvector index
	real colvector   fa, fb, fc    // f(a), f(b), f(c)
	
    if (args()<5) tol = 0       // bj: set tolerance
    if (args()<6) maxit = 1000  // bj: maximum # of iterations

//  fs = mm_callf_setup(f, args()-6, `opts') // bj: prepare function call
    fs = mm_callf_setup(f, args()-6, o1, index) // bj: prepare function call
	nobs = rows(x)
	index = 1::nobs

	result = J(nobs,1,.)	
	x = J(nobs,1,.)
    a = J(nobs,1,ax);  b = J(nobs,1,bx);  fa = mm_callf(fs, a);  fb = mm_callf(fs, b)
    c = a;  fc = fa

    //if ( fa==. ) return(0)      // bj: abort if fa missing
	tempindex = selectindex(fa:==.)
	nti = rows(tempindex)
	if (nti & cols(tempindex)) result[tempindex,] = J(nti,1,0)

	//remove tempindex as they are done 
	index = select(index,fa:!=.)

	if (rows(index)) { //not done
		tempindex = select(index,((fa[index]:>0) :* (fb[index]:>0))) 
		if (cols(tempindex)) {			
			
			flag1 = abs(fa[tempindex]) :< abs(fb[tempindex])
			flag2 = 1:-flag1
			tempindex2 = select(tempindex,flag1)
			nti = rows(tempindex2)
			if (nti) {
				result[tempindex2] = J(nti,1,2)
				x[tempindex2] = a[tempindex2]
			}
			tempindex2 = select(tempindex,flag2)
			nti = rows(tempindex2)
			if (nti) {
				result[tempindex2] = J(nti,1,3)
				x[tempindex2] = b[tempindex2]
			}
			//update index
			index = select(index,x:==.)					//better way to do this?
			if (rows(index)==0) return(result)
		}
		tempindex = select(index,((fa[index]:<0) :* (fb[index]:<0)))
		if (cols(tempindex)) {			

			flag1 = abs(fa[tempindex]) :< abs(fb[tempindex])
			flag2 = 1:-flag1
			tempindex2 = select(tempindex,flag1)
			nti = rows(tempindex2)
			if (nti) {
				result[tempindex2] = J(nti,1,2)
				x[tempindex2] = a[tempindex2]
			}
			tempindex2 = select(tempindex,flag2)
			nti = rows(tempindex2)
			if (nti) {
				result[tempindex2] = J(nti,1,3)
				x[tempindex2] = b[tempindex2]
			}
			//update index
			index = select(index,x:==.)					//better way to do this?
			if (rows(index)==0) return(result)
		}
	}
	else return(result)

	for (itr=1; itr<=maxit; itr++) {
		tempindex = index[selectindex(fb[index]:==.)]

		if (cols(tempindex)) result[tempindex] = J(rows(tempindex),1,0)

		//remove tempindex as they are done 
		index = select(index,fb[index]:!=.)
		if (!cols(index)) return(result)

		tempindex = select(index,abs(fc[index]) :< abs(fb[index]))
		
		if (cols(tempindex)) {
			a[tempindex] = b[tempindex];  b[tempindex] = c[tempindex];  c[tempindex] = a[tempindex];         // best approximation
            fa[tempindex] = fb[tempindex];  fb[tempindex] = fc[tempindex];  fc[tempindex] = fa[tempindex]
		}

		tol_act = 2:*epsilon_vec(b[index]) :+ tol:/2
        new_step = (c[index]:-b[index]):/2

		flag1 = (abs(new_step):<=tol_act) :+ (fb[index]:==0)
		flag2 = (flag1:==0)
		tempindex = select(index,flag1)

		if (cols(tempindex)) {
			x[tempindex] = b[tempindex]
			result[tempindex] = J(rows(tempindex),1,0)
		}

		index = select(index,flag2)  
		if (!cols(index) | !rows(index)) return(result)

		//update stuff
		tol_act = select(tol_act,flag2)
		new_step = select(new_step,flag2)

        // Decide if the interpolation can be tried
		prev_step = b[index]:-a[index]
	
		tempindex11 = (abs(prev_step) :>= tol_act) :* (abs(fa[index]) :> abs(fb[index]))
		tempindex = select(index,tempindex11)

		if (cols(tempindex)) {
		
			cb = c[tempindex] :- b[tempindex]
			
			p = q  = cb:*0					//fix

			flag1 = a[tempindex] :== c[tempindex]
			flag2 = 1:-flag1
			tempindex2 = select(tempindex,flag1)
			if (cols(tempindex2)) {
				t1 = fb[tempindex2]:/fa[tempindex2]
				p[selectindex(flag1)] = select(cb,flag1) :* t1
				q[selectindex(flag1)] = 1:- t1
			}
			tempindex2 = select(tempindex,flag2)
			if (cols(tempindex2)) {			
				q[selectindex(flag2)] = fa[tempindex2]:/fc[tempindex2]; t1 = fb[tempindex2]:/fc[tempindex2]; t2 = fb[tempindex2]:/fa[tempindex2]
				p[selectindex(flag2)] = t2 :* ( select(cb,flag2) :* q[selectindex(flag2)] :* (q[selectindex(flag2)] :- t1) :- (b[tempindex2]:-a[tempindex2]):*(t1:-1) )
                q[selectindex(flag2)] = (q[selectindex(flag2)]:-1) :* (t1:-1) :* (t2:-1)
			}
			flag1 = p:>0
			flag2 = 1:-flag1
			tempindex = selectindex(flag1)
			if (cols(tempindex)) q[tempindex] = -q[tempindex]
			tempindex = selectindex(flag2)
			if (cols(tempindex)) p[tempindex] = -p[tempindex]

			tempindex = (p :< (0.75:*cb:*q:-abs(select(tol_act,tempindex11):*q):/2))  :* (p :< abs(select(prev_step,tempindex11):*q:/2))
			if (cols(tempindex)) {
				//update tempindex11
				tempindex22 = select(selectindex(tempindex11),tempindex)
				if (cols(tempindex22) & rows(tempindex22)) new_step[tempindex22] = p[selectindex(tempindex)]:/q[selectindex(tempindex)]
			}
			
		}
		
		tempindex = selectindex(abs(new_step) :< tol_act)

		if (rows(tempindex)) {
			flag1 = new_step[tempindex] :> 0
			flag2 = 1:-flag1
			tempindex2 = select(tempindex,flag1)
			if (rows(tempindex2)) new_step[tempindex2] = tol_act[tempindex2]
			tempindex2 = select(tempindex,flag2)
			if (rows(tempindex2)) new_step[tempindex2] = -tol_act[tempindex2]
        }

        a[index] = b[index];  fa[index] = fb[index]                   // Save the previous approx.
        b[index] = b[index] + new_step

		fb[index] = mm_callf(fs, b[index]) // Do step to a new approxim.

		tempindex1 = select(index,((fb[index]:>0) :* (fc[index]:>0)))
		tempindex2 = select(index,((fb[index]:<0) :* (fc[index]:<0)))

		if (cols(tempindex1)) {			
			c[tempindex1] = a[tempindex1]
			fc[tempindex1] = fa[tempindex1]
		}
		if (cols(tempindex2)) {			
			c[tempindex2] = a[tempindex2]
			fc[tempindex2] = fa[tempindex2]
		}
    }
	x[index] = b[index]
	result[index] = J(rows(index),1,0)
    return(result)                             // bj: convergence not reached
}


//======================================================================================================================================//
// epsilon_vec - 
real colvector epsilon_vec(real colvector y)
{
	res = J(rows(y),1,.)
	for (i=1;i<=rows(y);i++) res[i] = epsilon(y[i])
	return(res)
}


//======================================================================================================================================//
// gq() - gauss/Legenrde nodes and weights

void gq(real matrix weights, real matrix nodes)
{
	n =  strtoreal(st_local("nodes"))

        i = range(1,n,1)'
        i1 = range(1,n-1,1)'
        muzero = 2
        a = J(1,n,0)
        b = i1:/sqrt(4 :* i1:^2 :- 1)   
        A= diag(a)
        for(j=1;j<=n-1;j++){
                A[j,j+1] = b[j]
                A[j+1,j] = b[j]
        }       
        symeigensystem(A,vec,nodes)
        weights = (vec[1,]:^2:*muzero)'
        weights = weights[order(nodes',1)]
        nodes = nodes'[order(nodes',1)']
}

//======================================================================================================================================//
// rcsgen_core function - calculate splines with provided knots

real matrix rcsgen_core(	real colvector variable,	///
							real rowvector knots, 		///
							real scalar deriv,|			///
							real matrix rmatrix			///
						)
{
	real scalar  Nobs, Nknots, kmin, kmax, interior, Nparams
	real matrix splines, knots2
	//======================================================================================================================================//
	// Extract knot locations

	Nobs 	= rows(variable)
	Nknots 	= cols(knots)
	if(Nknots==0) {
		if (deriv==0) splines = variable
		else splines = J(Nobs,1,0)
		Nparams = 1
	}
	else {
		kmin 	= knots[1,1]
		kmax 	= knots[1,Nknots]

		if (Nknots==2) interior = 0
		else interior = Nknots - 2
		Nparams = interior + 1
		
		splines = J(Nobs,Nparams,.)

		//======================================================================================================================================//
		// Calculate splines

		if (Nparams>1) {
			lambda = J(Nobs,1,(kmax:-knots[,2..Nparams]):/(kmax:-kmin))
			knots2 = J(Nobs,1,knots[,2..Nparams])
		}

		if (deriv==0) {
			splines[,1] = variable
			if (Nparams>1) {
				splines[,2..Nparams] = (variable:-knots2):^3 :* (variable:>knots2) :- lambda:*((variable:-kmin):^3):*(variable:>kmin) :- (1:-lambda):*((variable:-kmax):^3):*(variable:>kmax) 
			}
		}
		else if (deriv==1) {
			splines[,1] = J(Nobs,1,1)
			if (Nparams>1) {
				splines[,2..Nparams] = 3:*(variable:-knots2):^2 :* (variable:>knots2) :- lambda:*(3:*(variable:-kmin):^2):*(variable:>kmin) :- (1:-lambda):*(3:*(variable:-kmax):^2):*(variable:>kmax) 	
			}
		}
		else if (deriv==2) {
			splines[,1] = J(Nobs,1,0)
			if (Nparams>1) {
				splines[,2..Nparams] = 6:*(variable:-knots2) :* (variable:>knots2) :- lambda:*(6:*(variable:-kmin)):*(variable:>kmin) :- (1:-lambda):*(6:*(variable:-kmax)):*(variable:>kmax) 	
			}
		}
		else if (deriv==3) {
			splines[,1] = J(Nobs,1,0)
			if (Nparams>1) {
				splines[,2..Nparams] = 6:*(variable:>knots2) :- lambda:*6:*(variable:>kmin) :- (1:-lambda):*6:*(variable:>kmax)
			}
		}
	}

	//orthog
	if (args()==4) {
		real matrix rmat
		rmat = luinv(rmatrix)
		if (deriv==0) splines = (splines,J(Nobs,1,1)) * rmat[,1..Nparams]
		else splines = splines * rmat[1..Nparams,1..Nparams]
	}
	return(splines)
}


//======================================================================================================================================//
// stand_centile - obtain standardized centiles

// Define structure
struct struct_centile_stand 
{
	string scalar	atoption,
					wtoption,
					touse_centiles,
					centvar
					
	real scalar		t_start,		// lower starting time
					t_stop,			// upper starting time
					hasweights,
					Ncentiles		// Number of centiles listed

	real matrix		centiles
}

// Main program
function stand_centile() {
	struct struct_centile_stand scalar C
	C = CentileGetStruct()
	callBrent = mm_root_vec(CentResults=J(C.Ncentiles,1,.),&centile_calc(),C.t_start,C.t_stop,1E-8,1000,C,index) 
	(void) st_addvar("double",st_local("newcentvar"))
	st_store(.,st_local("newcentvar"),C.touse_centiles,CentResults)	
}

// CentileGetStruct()
// Information need for calculation of centiles
function CentileGetStruct() {
	struct struct_centile_stand scalar C
	C.centvar = st_local("centvar")
	C.centiles = 1 :- (strtoreal(tokens(st_local("centile"))):/100)'
	C.Ncentiles = rows(C.centiles)
	C.atoption = st_local("tempatopt")
	C.touse_centiles = st_local("touse_centiles")
	C.t_start = 0
	C.t_stop = strtoreal(st_local("centileupper"))
	C.hasweights = st_local("indweights") != ""
	if(C.hasweights) C.wtoption = "meansurvwt(" + st_local("indweights") + ")"
	else C.wtoption = ""
	return(C)
}

// function called by mm_root_vec()
function centile_calc(tmpc,struct struct_centile_stand scalar C, index) {

	(void) st_addvar("double","_tmp_t")
	(void) st_addvar("double","_tmp_centiles")
	
	readrows = (1,rows(tmpc))
	st_store(readrows,"_tmp_t",.,tmpc)
	stata("qui predict double ms_cent, meansurv timevar(_tmp_t) " + C.atoption + C.wtoption)
	st_store(readrows,"_tmp_centiles",.,C.centiles[index])

	stata("qui replace ms_cent = ms_cent - (_tmp_centiles)")
	update_cent = st_data(readrows,"ms_cent",.)
	stata("capture drop _tmp_t ms_cent _tmp_centiles")
	return(update_cent)
}


//======================================================================================================================================//
// rmst - calculate rmst at all timevar points.
// structure
struct struct_rmst_stand  {
	string scalar	atoption,			// current at option
					wtoption,			// external weights option
					touse_time,
					newvarname
					
	real scalar		Nt,
					Nnodes,
					hasweights


	real matrix		t,
					nodes,
					nodeweights,
					nodes_t,
					rmst
}

// main function
function rmst_stand() {
	struct struct_rmst_stand scalar R
	R = RMSTGetStruct()
	RMST_calcstand(R)
	(void) st_addvar("double",R.newvarname)
	st_store(.,R.newvarname,R.touse_time,R.rmst)
}

function RMSTGetStruct() {
	struct struct_rmst_stand scalar R
	R.newvarname = st_local("rmst_newvarname")
	R.touse_time = st_local("touse_time")
	R.t = st_data(.,st_local("timevar"),R.touse_time)
	R.Nt = rows(R.t)
	R.Nnodes = strtoreal(st_local("nodes"))
	gq(R.nodeweights,R.nodes)
	R.atoption = st_local("tempatopt")
	if(R.hasweights) R.wtoption = "meansurvwt(" + st_local("indweights") + ")"
	else R.wtoption = ""	
	return(R)
}	

function RMST_calcstand(struct struct_rmst_stand scalar R)
{	
	R.rmst = J(R.Nt,1,.)
	for(j=1;j<=R.Nt;j++) {
		tj = R.t[j]
		nodes_t = (0.5:*tj:*R.nodes :+ 0.5:*tj)
		(void) st_addvar("double",tmpt_var = st_tempname())
		ms_var = st_tempname()
		st_store((1,R.Nnodes),tmpt_var,.,nodes_t)
		stata("predict double "+ms_var+", meansurv timevar("+tmpt_var+")" + R.atoption + R.wtoption)
		R.rmst[j] = 0.5:*tj:*quadcolsum(R.nodeweights:*st_data((1,R.Nnodes),ms_var,.))
		stata("capture drop" + invtokens(tmpt_var,ms_var))
	}
}

//======================================================================================================================================//
// Calculate CIs, transformations and write results
//
// CreateResultsMat() - results matrix
// CalcCI_at() - calculate CIS for each at() option
// CalcContrasts() calculate contrast and CIs
// CalcFailure() - 1 - S(t)
// WriteResults() - write results to new variables

//======================================================================================================================================//
// Create Empty Results Matices
function CreateResultsMat(struct stpm2_standardisation scalar S)
{
	struct stpm2_standardisation_results scalar R
	if(S.calccentile) N = S.Ncentiles
	else N=S.Nt

	if(S.ci) R.CI_at_lci = R.CI_at_uci = J(N,S.N_at_options,.)
	if(S.se) R.se = J(N,S.N_at_options,.)
	R.at_est = J(N,S.N_at_options,.)

	// set-up for contrasts
	if(S.hascontrast) {
		if(S.ci) R.CI_contrast_lci = R.CI_contrast_uci = J(N,S.N_at_options,.)
		R.contrast_est = J(N,S.N_at_options,.)
	}
	if(S.haslincom) {
		if(S.ci) R.CI_lincom_lci = R.CI_lincom_uci = J(N,1,.)
		R.lincom_est = J(N,1,.)
	}
	if(S.hasuserfunction) {
		if(S.ci) R.CI_userfunction_lci = R.CI_userfunction_uci = J(N,1,.)
		R.userfunction_est = J(N,1,.)
		stata("mata: pf = &"+st_local("userfunction")+"()")
		external pf
		R.userfunction = pf	
	}
	return(R)
}





//======================================================================================================================================//
// Calculate CIs for at() option
real matrix function CalcCI_at(struct stpm2_standardisation scalar S,struct stpm2_standardisation_results scalar R,j)
{
	// transform to scale to calculate CIs
	if(S.calcsurvival) R.at_est[j,] = S.Smean[j,]:*S.per
	else if(S.calcfailure) R.at_est[j,] = (1 :- S.Smean[j,]):*S.per
	else if(S.calchazard) R.at_est[j,] = (S.fmean[j,]:/S.Smean[j,]):*S.per
	else if(S.calccentile) R.at_est[j,] = S.centmean[j,]:*S.per
	else if(S.calcrmst) R.at_est[j,] = S.rmstmean[j,]:*S.per

	S.Vest = S.per:^2:*(asarray(S.ResVcov,j)[1..S.N_at_options,1..S.N_at_options])
	if(S.transform == "none") {
		est_trans = R.at_est[j,]
		dtransform = I(S.N_at_options)
	}
	else if(S.transform == "log") {
		dtransform = diag(1:/R.at_est[j,])
		est_trans = log(R.at_est[j,])
	}
	else if(S.transform == "logit") {
		dtransform = diag(1:/(R.at_est[j,]:*(1:-R.at_est[j,])))
		est_trans = logit(R.at_est[j,])
	}
	else if(S.transform == "loglog") {
		dtransform = diag(1:/(R.at_est[j,]:*ln(R.at_est[j,]))) // Update this
		est_trans = log(-log(R.at_est[j,]))
	}	
	
	
	Vest_trans = dtransform' * S.Vest * dtransform
	// return CIs of mean survival for each at() option 
	theta = invnormal(1-(1-S.level/100)/2)*sqrt(diagonal(Vest_trans))
	if(S.ci) {
		at_lci = est_trans - theta'
		at_uci = est_trans + theta'

		if(S.transform == "none") {
			R.CI_at_lci[j,] = (at_lci)  
			R.CI_at_uci[j,] = (at_uci)
		}
		else if(S.transform == "log") {
			R.CI_at_lci[j,] = exp(at_lci) 
			R.CI_at_uci[j,] = exp(at_uci) 
		}
		else if(S.transform == "logit") {
			R.CI_at_lci[j,] = invlogit(at_lci) 
			R.CI_at_uci[j,] = invlogit(at_uci)			
		}
		else if(S.transform == "loglog") {
			R.CI_at_lci[j,] = exp(-exp(at_lci))
			R.CI_at_uci[j,] = exp(-exp(at_uci))
		}
	}
	if(S.se) R.se[j,] = sqrt(diagonal(Vest_trans))'
}

//======================================================================================================================================//
// Calculate contrasts and CIs when using contrast() option.
function CalcContrasts(struct stpm2_standardisation scalar S,struct stpm2_standardisation_results scalar R,j)
{
	if(S.contrast == "difference") {
		dcontrast_dtransform = I(S.N_at_options)
		dcontrast_dtransform[,S.at_reference] = J(S.N_at_options,1,-1)
		dcontrast_dtransform[S.at_reference,S.at_reference] = 0
		R.contrast_est[j,] = R.at_est[j,] :- R.at_est[j,S.at_reference]
	}
	if(S.contrast == "ratio") {	// calculate on log scale
		dcontrast_dtransform = I(S.N_at_options):/R.at_est[j,]
		dcontrast_dtransform[,S.at_reference] = J(S.N_at_options,1,-1:/R.at_est[j,S.at_reference])
		dcontrast_dtransform[S.at_reference,S.at_reference] = 0
		R.contrast_est[j,] = ln(R.at_est[j,]) :- ln(R.at_est[j,S.at_reference])
	}
	if(S.contrast == "pchange") {	// calculate on absolute scale
		dcontrast_dtransform = 	-I(S.N_at_options) :/( R.at_est[j,S.at_reference])
		dcontrast_dtransform[,S.at_reference] = (R.at_est[j,])':/(R.at_est[j,S.at_reference]:^2)
		dcontrast_dtransform[S.at_reference,S.at_reference] = 0
		R.contrast_est[j,] = ( R.at_est[j,S.at_reference] :-R.at_est[j,]) :/ (R.at_est[j,S.at_reference])
	}	
	Vcont = dcontrast_dtransform*S.Vest*dcontrast_dtransform'
	
	if(S.contrast == "difference" | S.contrast == "pchange") {
		R.CI_contrast_lci[j,] = R.contrast_est[j,] - invnormal(1-(1-S.level/100)/2)*sqrt(diagonal(Vcont)')
		R.CI_contrast_uci[j,] = R.contrast_est[j,] + invnormal(1-(1-S.level/100)/2)*sqrt(diagonal(Vcont)')
	}
	else if(S.contrast == "ratio") {
		R.CI_contrast_lci[j,] = exp((R.contrast_est[j,]) - invnormal(1-(1-S.level/100)/2)*sqrt(diagonal(Vcont)'))
		R.CI_contrast_uci[j,] = exp((R.contrast_est[j,]) + invnormal(1-(1-S.level/100)/2)*sqrt(diagonal(Vcont)'))
		R.contrast_est[j,] = exp(R.contrast_est[j,])
	}
}

//======================================================================================================================================//
// Calculate contrasts and CIs when using lincom() option.
function CalcLincom(struct stpm2_standardisation scalar S,struct stpm2_standardisation_results scalar R,j)
{
	R.lincom_est[j] = S.lincom*R.at_est[j,]'
	lincom_se = sqrt(S.lincom*S.Vest*S.lincom')
	R.CI_lincom_lci[j] = 	R.lincom_est[j] - invnormal(1-(1-S.level/100)/2)*lincom_se
	R.CI_lincom_uci[j] = 	R.lincom_est[j] + invnormal(1-(1-S.level/100)/2)*lincom_se
}

//======================================================================================================================================//
// Calculate contrasts and CIs when using userfunction option.
function CalcUserfunction(struct stpm2_standardisation scalar S,struct stpm2_standardisation_results scalar R,j)
{	
	R.userfunction_est[j] = (*R.userfunction)(R.at_est[j,])

	if(S.ci) {
		Var_user = J(S.N_at_options,1,.)
		eps = 1.0x-1a
		hh = J(1,S.N_at_options,0)
		for(i=1;i<=S.N_at_options;i++) {
			grad = J(1,S.N_at_options,.)
			for(k=1;k<=S.N_at_options;k++) {
				hh[1,k] = eps
				grad[k] = ((*R.userfunction)(R.at_est[j,] + hh) - (*R.userfunction)(R.at_est[j,] - hh)) / (2*eps)				
				hh[1,k] = 0
			}
			Var_user[i] = grad*S.Vest*grad'
		}
		R.CI_userfunction_lci[j] = 	R.userfunction_est[j] - invnormal(1-(1-S.level/100)/2)*sqrt(Var_user[1])	
		R.CI_userfunction_uci[j] = 	R.userfunction_est[j] + invnormal(1-(1-S.level/100)/2)*sqrt(Var_user[1])	
	}
}



//======================================================================================================================================//
// Store results in Stata
// Need to change Smean to make more general

void function WriteResults(struct stpm2_standardisation scalar S,struct stpm2_standardisation_results scalar R)
{
	if(!S.ci) {
		if(S.calcsurvival) R.at_est = S.Smean
		else if(S.calcfailure) R.at_est = 1 :- S.Smean
		else if(S.calchazard) R.at_est = S.fmean:/S.Smean
		else if(S.calccentile) R.at_est = S.centmean
		else if(S.calcrmst) R.at_est = S.rmstmean
	}

	if(S.calccentile) touse_tmp = S.touse_centiles
	else touse_tmp = S.touse_time

	for(i=1;i<=S.N_at_options;i++) {
		(void) st_addvar("double",S.at_varnames[1,i])
		st_store(.,S.at_varnames[1,i],touse_tmp,R.at_est[,i])
		
		if(S.ci) {
			(void) st_addvar(("double","double"),(S.at_varnames[1,i]+"_lci",S.at_varnames[1,i]+"_uci"))
			st_store(.,S.at_varnames[1,i]+"_lci",touse_tmp,R.CI_at_lci[,i])
			st_store(.,S.at_varnames[1,i]+"_uci",touse_tmp,R.CI_at_uci[,i])
		}
		if(S.se) {
			(void) st_addvar(("double"),S.at_varnames[1,i]+"_se")
			st_store(.,S.at_varnames[1,i]:+"_se",touse_tmp,R.se[,i])
		}
	}
	if(S.hascontrast) {
		cont_index = 1
		for(i=1;i<=S.N_at_options;i++) {
			if(i != S.at_reference) {  // do not write for reference
				(void) st_addvar("double",S.contrast_varnames[1,cont_index])
				st_store(.,S.contrast_varnames[1,cont_index],touse_tmp,R.contrast_est[,i])
				if(S.ci) {
					(void) st_addvar(("double","double"),(S.contrast_varnames[1,cont_index]+"_lci",S.contrast_varnames[1,cont_index]+"_uci"))
					st_store(.,S.contrast_varnames[1,cont_index]+"_lci",touse_tmp,R.CI_contrast_lci[,i])
					st_store(.,S.contrast_varnames[1,cont_index]+"_uci",touse_tmp,R.CI_contrast_uci[,i])
				}
				cont_index = cont_index + 1
			}
		}
	}
	if(S.haslincom) {
		(void) st_addvar("double",S.lincom_varname)
		st_store(.,S.lincom_varname,touse_tmp,R.lincom_est)
		if(S.ci) {
			(void) st_addvar(("double","double"),(S.lincom_varname+"_lci",S.lincom_varname+"_uci"))
			st_store(.,S.lincom_varname+"_lci",touse_tmp,R.CI_lincom_lci)
			st_store(.,S.lincom_varname+"_uci",touse_tmp,R.CI_lincom_uci)
		}		
	}
	
	if(S.hasuserfunction) {
		(void) st_addvar("double",S.userfunction_varname)
		st_store(.,S.userfunction_varname,touse_tmp,R.userfunction_est)
		if(S.ci) {
			(void) st_addvar(("double","double"),(S.userfunction_varname+"_lci",S.userfunction_varname+"_uci"))
			st_store(.,S.userfunction_varname+"_lci",touse_tmp,R.CI_userfunction_lci)
			st_store(.,S.userfunction_varname+"_uci",touse_tmp,R.CI_userfunction_uci)
		}	
	}
}

end
