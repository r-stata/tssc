*! inorm.ado JCG 05jul2007
* Note: read INORM ado files with tab set equal to 6 spaces
*--------------------------------------------------------------------------------------------------------
* program inorm, rclass
* syntax: inorm cmd cmdline
* where cmd is em or da.
*--------------------------------------------------------------------------------------------------------
program define inorm, rclass
	version 9
	set more off					/* shall remain off for all commands */

	* EXTRACT CMD FROM COMMAND LINE
	gettoken cmd 0 : 0				/* extract command */

	* EXTRACT IRAND OPTION FROM COMMAND LINE AND LOAD IRAND PLUGIN, IF NECESSARY
	syntax [varlist] [if] [in] [using/] [, IRAND * ]
	if "`irand'"!="" {
		cap irandpi load				/* load irand plugin, if it exists */
		if ( _rc==199 | _rc==601 ) {
			display as error "irand plugin not found"
			exit 198
		}
	}

	* EXPLICITLY DROP AND RELOAD INORM PLUGIN, IF IT EXISTS
	* (THIS IS TO OVERCOME A SUBTLE PROBLEM WITH NORM3)
	if ( "`cmd'"=="em" | "`cmd'"=="da" ) {
		cap program drop inormpi		/* this will explicity drop the plugin */
		cap inormpi load				/* load plugin, if it exists */
		if ( _rc==199 | _rc==601 ) {		/* if inormpi.ad or inormdll.plugin do not exist */
			local hasplugin "hasplugin(-1)"
		}
		else {
			local hasplugin "hasplugin(0)"
		}
		if ( `"`irand'"'=="" & `"`options'"'=="" ) {
			local hasplugin ", `hasplugin'"
		}
	}

	* PROCESS CMD
	if ( "`cmd'"=="em" | "`cmd'"=="da" ) {
		if ( "`cmd'" == "em" ) {
			em `0' `hasplugin'
			return add
		}
		else {
			da `0' `hasplugin'
			return add
		}
	}
	else {
		display as error "subcommand em or da expected"
		exit 198
	}
end
*--------------------------------------------------------------------------------------------------------
* subprogram em
*--------------------------------------------------------------------------------------------------------
program define em, rclass
	version 9
	syntax varlist [if] [in], [		///
		Xvars(varlist)			/// fully observed covariates
		MAXits(integer 1000)		/// aborts after this number of iterations (if convergence fails)
		CRIterion(real 0.000001)	///
		RIDge(real 0.0)			///
		MU(string)				/// the name of a Stata matrix containing starting values
		SIGma(string)			/// the name of a Stata matrix containing starting values
		Echo					/// echos log likelihood values to the screen
		MATA					/// use Mata version of norm 
		CASEORDER				/// for debuggin (generate caseorder variable to pass Mata da)
		Dump					/// for debugging
		DUMPAT(integer 1)			/// for debugging
		HASPlugin(integer -1)		/// for debugging
	]
	marksample touse, novarlist

	* CAPTURE VALUE OF MU OPTION
	if ( `"`mu'"' != "" ) local beta = "`mu'"

	* CHECK ARGUMENTS
	if ( `maxits' <= 0 ) {
		display as error "maxits option must be a positive integer value"
		exit 198
	}
	if ( `criterion' <= 0 ) {
		display as error "criterion option must be positive"
		exit 198
	}
	if ( `ridge' < 0 ) {
		display as error "ridge option must be positive"
		exit 198
	}
	if ( "`beta'" != "" ) {
		capture confirm matrix `beta'
		if _rc!=0 {
			display as error "matrix `beta' not found"
			exit 198
		}
		matrix INORM_beta = `beta'
		local usebeta = "usebeta"
	}
	if ( "`sigma'" != "" ) {
		capture confirm matrix `sigma'
		if _rc!=0 {
			display as error "matrix `sigma' not found"
			exit 198
		}
		matrix INORM_sigma = `sigma'
		local usesigma = "usesigma"
	}
	foreach yvar of varlist `varlist' {
		capture confirm numeric variable `yvar'
		if ( _rc != 0 ) {
			display as error "the variable `yvar' is not numeric""
			exit 198
		}

	}
	if ( "`xvars'" != "" ) {
		foreach xvar of varlist `xvars' {
			capture confirm numeric variable `xvar'
			if ( _rc != 0 ) {
				display as error "the variable `xvar' is not numeric"
				exit 198
			}
			capture assert ( `xvar' < . | `touse' == 0 )
			if _rc!=0 {
				display ///
					as error "the variable `xvar' has missing values; " ///
					as error " the xvars covariates must be fully observed"
				exit 198
			}
		}
	}

	* GENERATE ALL ONES VARIABLE
	tempvar allones
	qui gen byte `allones'=1
	local xvarnames "_cons `xvars'"
	local xvars "`allones' `xvars'"

	* DO EM
	display as text "Maximum-likelihood estimation for multivariate normal data with missing values"

	* RUN EM USING DLL IF PLUGIN IS AVAILABLE AND IF MATA OPTION WAS NOT SPECIFIED
	local rc=0
	if ( `hasplugin' == 0 & "`mata'" == "" ) {
		display as text "(using plugin)"

		* PASS PARAMETERS TO PLUGIN VIA SCALARS AND MATRICES
		local noofyvars : word count `varlist'
		scalar INORM_noofyvars = `noofyvars'
		local noofxvars : word count `xvars' 
		scalar INORM_noofxvars = `noofxvars'
		qui count if `touse'==1
		scalar INORM_noofobs = r(N)
		quietly count
		scalar INORM_nobs = r(N)
		scalar INORM_max_iter = `maxits'
		scalar INORM_criterion = `criterion'
		scalar INORM_ridge = `ridge'
		scalar INORM_useridge = 0
		scalar INORM_dumpat=`dumpat'
		scalar INORM_da = 0
		scalar INORM_echo = 0
		scalar INORM_dump = 0
		scalar INORM_usebeta = 0
		scalar INORM_usesigma = 0
		scalar INORM_gen_case_order = 0
		if ( `ridge' > 0 ) scalar INORM_useridge = 1
		if ( "`echo'"!="" ) scalar INORM_echo = 1
		if ( "`dump'"!="" ) scalar INORM_dump = 1
		if ( "`beta'"!="" ) scalar INORM_usebeta = 1
		else matrix INORM_beta = J( INORM_noofxvars, INORM_noofyvars, 0 )
		if ( "`sigma'"!="" ) scalar INORM_usesigma = 1
		else matrix INORM_sigma = J( INORM_noofyvars, INORM_noofyvars, 0 )
		if ( "`caseorder'"!="" ) {
			scalar INORM_gen_case_order = 1
			cap drop INORM_case_order
			qui gen double INORM_case_order = .
			local caseorder "INORM_case_order"
		}

		* CALL PLUGIN
		cap noi inormpi call `varlist' `xvars' `touse' `caseorder'
		local rc=_rc

		* CLEAN UP PARAMETERS
		scalar drop INORM_noofyvars
		scalar drop INORM_noofxvars
		scalar drop INORM_noofobs
		scalar drop INORM_nobs
		scalar drop INORM_max_iter
		scalar drop INORM_criterion
		scalar drop INORM_ridge
		scalar drop INORM_useridge
		scalar drop INORM_dumpat
		scalar drop INORM_da
		scalar drop INORM_echo
		scalar drop INORM_dump
		scalar drop INORM_usebeta
		scalar drop INORM_usesigma
		scalar drop INORM_gen_case_order
	}
	* ELSE RUN EM IN MATA
	else {
		display as text "(using mata)"
		mata: mata clear
		mata: run_norm_engine_em( ///
			"`xvars'", "`varlist'", "`touse'", `maxits', `criterion', ///
			`ridge', "`usebeta'", "`usesigma'", "`echo'", "`dump'", `dumpat')
	}

	* IF SUCCESSFUL
	if ( `rc' == 0 ) {
		* DISPLAY RESULTS
		if INORM_converged==1 local converged="true"
		else local converged="false"
		display as text "Converged:      " as result "`converged'"
		display as text "Iterations:     " as result INORM_iterations
		display as text "Log-likelihood: " as result INORM_loglik

		* RETURN RESULTS
		return scalar converged = INORM_converged
		return scalar iterations = INORM_iterations
		return scalar ll = INORM_loglik
		matrix colnames INORM_beta = `varlist'
		matrix rownames INORM_beta = `xvarnames'
		matrix colnames INORM_sigma = `varlist'
		matrix rownames INORM_sigma = `varlist'
		matrix rho = corr(INORM_sigma)
		return matrix rho = rho
		return matrix sigma = INORM_sigma
		return matrix mu = INORM_beta
	}

	* CLEAN UP SCALARS AND MATRICES
	cap scalar drop INORM_converged
	cap scalar drop INORM_iterations
	cap scalar drop INORM_loglik
	cap matrix drop INORM_beta
	cap matrix drop INORM_sigma

	exit `rc'
end
*--------------------------------------------------------------------------------------------------------
* subprogram da
*--------------------------------------------------------------------------------------------------------
program define da, rclass
	version 9

	* PRESERVE CURRENT DATASET
	preserve

	syntax varlist [if] [in] using/, [	///
		Xvars(varlist)			/// Fully observed covariates
		M(integer 2)			/// Number of imputed datasets to create
		BURNin(integer 0)			/// Number of iterations to execute first
		ITs(integer 50)			/// Number of iterations between draws of imputed datasets
		RIDge(real 0.0)			/// Ridge prior distribution value
		MU(string)				/// Starting mean vector values
		SIGma(string)			/// Starting covariance matrix values
		SEED1(integer 123)		/// First seed for random number generator
		SEED2(integer 459)		/// Second seed for random number generator
		REPLACE				/// Allows the using file to be overwritten
		MATA					/// Forces use of mata version of da
		Dump					/// For debugging
		DUMPIMP(integer 1)		/// For debugging
		DUMPAT(integer 1)			/// For debugging
		HASPlugin(integer -1)		/// For debugging
		CASEORDER				/// For debugging. Instructs Mata version of da to use the
							/// case order from the INORM_case_order variable generated
							/// by a call to the plugin version of em
		IRAND					/// For debugging. Instructs mata version of da to use the
							/// irand plugin random number generator instead of the Mata
							/// version
	]

	marksample touse, novarlist
	tempvar imps				// Used by mata to pass imputations back to Stata
	gen `imps'=`touse'

	* CAPTURE VALUE OF M AND MU OPTIONS
	local MI_m = `m'
	if ( `"`mu'"' != "" ) local beta = "`mu'"

	* CHECK ARGUMENTS
	if ( `burnin' < 0 ) {
		display as error "burnin option must be positive"
		exit 198
	}
	if ( `m' <= 0 ) {
		display as error "m option must be a positive integer value"
		exit 198
	}
	if ( `its' <= 0 ) {
		display as error "iter option must be a positive integer value"
		exit 198
	}
	if ( `ridge' < 0 ) {
		display as error "ridge option must be positive"
		exit 198
	}
	if ( "`beta'" != "" ) {
		capture confirm matrix `beta'
		if ( _rc != 0 ) {
			display as error "matrix `beta' not found"
			exit 198
		}
		matrix INORM_beta = `beta'
	}
	if ( "`sigma'" != "" ) {
		capture confirm matrix `sigma'
		if ( _rc != 0 ) {
			display as error "matrix `sigma' not found"
			exit 198
		}
		matrix INORM_sigma = `sigma'
	}
	if ( "`caseorder'" != "" ) {
		if ( `hasplugin'==0 & "`mata'"=="" ) {
			display as error "caseorder option not valid with plugin version of da; specify mata option"
			exit 198
		}
		capture confirm variable INORM_case_order
		if ( _rc != 0 ) {
			display as error "Case order variable INORM_case_order not found; rerun em with caseorder option"
			exit 198
		}
	}
	foreach yvar of varlist `varlist' {
		capture confirm numeric variable `yvar'
		if ( _rc != 0 ) {
			display as error "the variable `yvar' is not numeric""
			exit 198
		}
		local `yvar'type : type `yvar'
		if ( `"``yvar'type'"' != "double" & `"``yvar'type'"' != "float" ) {
			cap recast double `yvar'
			local rc = _rc
			if ( `rc' != 0 ) {
				display ///
					as error "unable to recast `yvar' to double; " ///
					as error "try {help set memory} to increase available memory"
				exit `rc'
			}
		}
	}
	if ( "`xvars'" != "" ) {
		foreach xvar of varlist `xvars' {
			capture confirm numeric variable `xvar'
			if ( _rc != 0 ) {
				display as error "the variable `xvar' is not numeric"
				exit 198
			}
			capture assert ( `xvar' < . | `touse' == 0 )
			if ( _rc != 0 ) {
				display ///
					as error "the variable `xvar' has missing values; " ///
					as error "the xvars covariates must be fully observed"
				exit 198
			}
		}
	}
	if ( "`replace'" != "" ) local replace ", `replace'"

	* MAKE SPACE FOR IMPUTED COMPIES OF THE DATA
	capture drop _mj
	capture drop _mi
	quietly generate byte _mi = .
	quietly replace _mi = _n
	tempfile t
	quietly save `t', replace
	capture drop _mj
	quietly generate byte _mj=0
	forvalues i=1/`MI_m' {
		quietly append using `t'
		quietly replace _mj=`i' if _mj>=.
	}
	quietly replace `touse'=0 if _mj>0
	quietly replace `imps'=0 if _mj==0

	* GENERATE ALL ONES VARIABLE
	tempvar allones
	qui gen byte `allones'=1
	local xvarnames "_cons `xvars'"
	local xvars "`allones' `xvars'"

	* DO DA
	display as text "Imputation by data-augmentation for multivariate normal data with missing values"

	* RUN DA USING DLL IF PLUGIN IS AVAILABLE AND IF MATA OPTION WAS NOT SPECIFIED
	local rc=0
	if ( `hasplugin'==0 & "`mata'"=="" ) {
		display as text "(using plugin)"

		* PASS PARAMETERS TO PLUGIN VIA SCALARS AND MATRICES
		local noofyvars : word count `varlist'
		scalar INORM_noofyvars = `noofyvars'
		local noofxvars : word count `xvars' 
		scalar INORM_noofxvars = `noofxvars'
		qui count if `touse'==1
		scalar INORM_noofobs = r(N)
		quietly count if _mj==0
		scalar INORM_nobs = r(N)
		scalar INORM_m = `MI_m'
		scalar INORM_ridge = `ridge'
		scalar INORM_useridge = 0
		scalar INORM_burnin = `burnin'
		scalar INORM_its = `its'
		scalar INORM_seed1 = `seed1'
		scalar INORM_seed2 = `seed2'
		scalar INORM_dumpat = `dumpat'
		scalar INORM_dumpimp = `dumpimp'
		scalar INORM_da = 1
		scalar INORM_echo = 0
		scalar INORM_dump = 0
		scalar INORM_usebeta = 0
		scalar INORM_usesigma = 0
		if ( `ridge' > 0 ) scalar INORM_useridge = 1
		if ( "`echo'"!="" ) scalar INORM_echo = 1
		if ( "`dump'"!="" ) scalar INORM_dump = 1
		if ( "`beta'"!="" ) scalar INORM_usebeta = 1
		else matrix INORM_beta = J( INORM_noofxvars, INORM_noofyvars, 0 )
		if ( "`sigma'"!="" ) scalar INORM_usesigma = 1
		else matrix INORM_sigma = J( INORM_noofyvars, INORM_noofyvars, 0 )

		* CALL PLUGIN
		cap noi inormpi call `varlist' `xvars' `touse'
		local rc=_rc

		* CLEAN UP PARAMETERS
		scalar drop INORM_noofyvars
		scalar drop INORM_noofxvars
		scalar drop INORM_noofobs
		scalar drop INORM_nobs
		scalar drop INORM_m
		scalar drop INORM_ridge
		scalar drop INORM_useridge
		scalar drop INORM_burnin
		scalar drop INORM_its
		scalar drop INORM_seed1
		scalar drop INORM_seed2
		scalar drop INORM_dumpat
		scalar drop INORM_dumpimp
		scalar drop INORM_da
		scalar drop INORM_echo
		scalar drop INORM_dump
		scalar drop INORM_usebeta
		scalar drop INORM_usesigma
	}
	* ELSE RUN DA IN MATA
	else {
		display as text "(using mata)"

		if ( "`irand'"=="" ) {
			* INITIALISE MATA VERSION OF IRAND NUMBER GENERATOR
			mata: mata clear
			mata: ran_setall( `seed1', `seed2' )
		}
		else {
			* PASS SEED PARAMETERS TO IRAND PLUGIN VIA SCALARS
			* Note: The irand plugin will extracts these scalar values from Stata each time
			* it is called, and sets its internal state accordingly. Prior to exit, the plugin
			* copies its internal state to these Stata scalars ready for the next call.
			scalar INORM_curr1 = `seed1'
			scalar INORM_curr2 = `seed2'
		}

		* RUN DA
		if ( `burnin' > 0 ) {
			mata: run_norm_engine_da( ///
				"`xvars'", "`varlist'", "`touse'", "`imps'", 1, `burnin', `ridge', ///
				"usebeta", "usesigma", `seed1', "`dump'", `dumpimp', `dumpat', ///
				"`caseorder'", "`irand'", "discard" )
		}

		mata: run_norm_engine_da( ///
			"`xvars'", "`varlist'", "`touse'", "`imps'", `MI_m', `its', `ridge', ///
			"usebeta", "usesigma", `seed1', "`dump'", `dumpimp', `dumpat', ///
			"`caseorder'", "`irand'", "" )

		* CLEAN UP PARAMETERS AND RESULTS SET BY IRAND PLUGIN,  IF NECESSARY
		if ("`irand'"!="") {
			scalar drop INORM_curr1
			scalar drop INORM_curr2
			scalar drop INORM_cmd
			scalar drop INORM_z
			scalar drop INORM_df
		}
	}

	* IF SUCCESSFUL
	if ( `rc' == 0 ) {

		* RETURN RESULTS
		matrix colnames INORM_beta = `varlist'
		matrix rownames INORM_beta = `xvarnames'
		matrix colnames INORM_sigma = `varlist'
		matrix rownames INORM_sigma = `varlist'
		matrix rho = corr(INORM_sigma)
		return matrix rho = rho
		return matrix sigma = INORM_sigma
		return matrix mu = INORM_beta

		* LABEL VARIABLES
		label variable _mj "imputation identifier"
		label variable _mi "observation identifier"
		order _mj _mi
		sort _mj _mi

		* SAVE RESULTS
		capture drop `allones'
		capture drop `imps'
		capture drop `touse'
		quietly save "`using'" `replace'
	}


	* CLEAN UP SCALARS AND MATRICES
	cap matrix drop INORM_beta
	cap matrix drop INORM_sigma

	exit `rc'
end
