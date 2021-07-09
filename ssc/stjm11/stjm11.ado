*! version 1.3.2 15aug2012 MJC

/*
History
MJC 15aug2012: version 1.3.2 - erroneous sort caused fulldata to be invoked when unnecessary, now fixed
MJC 11aug2012: version 1.3.1 - renamed to stjm11
							 - bug with delayed entry fpm models fixed
							 - fulldata option added
							 - adaptit() default changed to 5
MJC 02feb2012: version 1.3.0 - Implemented adaptive GH quadrature which is now the default. timeinteraction, assoccovariates options added.
MJC 20oct2011: version 1.2.0 - Added Gompertz and Exponential survival submodels. Added covariance options consistent with xtmixed.
MJC 14oct2011: version 1.1.0 - Weibull survival submodel now allowed. Delayed entry re-written, now allowing time-varying covariates in survival submodel.							 
							 - Bug fix: fixed error when rfracp or ffracp was 0 with min(_t0) = 0
MJC 10oct2011: version 1.0.0
*/

program stjm11
	version 11.2
	
	if replay() {
			if (`"`e(cmd)'"' !="stjm11") error 301
			Replay `0'
	}
	else 	Estimate `0'
	
end

program Estimate, eclass sortpreserve
	st_is 2 analysis
		syntax varlist(min=1 numeric) 	[if] [in] ,											///
													Panel(varname) 							///			-Patient identifier-
													SURVModel(string)						///			-Survival submodel choice-
																							///
													[										///
													/* Longitudinal model options */		///
														RFRACPoly(numlist max=5 asc)		///			-Random time power variables-
														FFRACPoly(numlist max=5 asc)		///			-Fixed time power variables-
														TIMEINTERACtion(varlist numeric)	///			-Covariates to interact with fixed time variables-
														COVariance(string)					///			-Covariance structure-
																							///
													/* Survival model options */			///
														SURVCov(varlist numeric)			///			-Covariates to include in the survival submodel-
														DF(string) 		 					///			-Degrees of freedom for FPM-
														KNOTS(numlist) 						///			-Knot locations for baseline hazard function-
														NOORTHog							///			-Do not orthoganalise splines-
																							///
													/* Association options */				///
														ASSOCCOVariates(varlist)			///			-Adjust association parameters by covariates-
														NOCurrent							///			-Assciation not based on current value-
														DERIVASSOCiation					///			-Association based on derivatives-
														INTASSOCiation						///			-Association based on random intercept-
														ASSOCiation(numlist max=5)			///			-Association based on random slope/etc.-
																							///
													/* Results display options */			///
														SHOWINITial							///			-Show output from fitting initial value models-
														VARiance							///			-Display variances-covariances in random effects table-
														SHOWCons							///			-Show spline constraints-
														KEEPCons							///			-Do not drop constraints used in ml routine-
														Level(cilevel)						///			-Statistical significance level-
																							///
													/* Maximisation options */				///
														GH(string) 							///			-Number of Gauss-Hermite nodes-
														GK(string)							///			-Number of Gauss-Kronrod nodes-
														ADAPTIT(string)						///			-Number of adaptive iterations to do-
														NONADAPT							///			-Use non-adaptive quadrature-
														NULLAssoc							///			-Initial values for association parameters set to zero-
														FULLdata							///			-Use all rows of survival data in estimation-
														NOLOG								///			-Suppress log-likelihood iteration log-
														* 									///			-ML options-
													] 
						
	
	/******************************************************************************************************************************************************************************************/
	/* ERROR CHECKS */
		
		local l = length("`survmodel'")
		if substr("exponential",1,max(1,`l')) == "`survmodel'" {
			local smodel "e"
		}
		else if substr("weibull",1,max(1,`l')) == "`survmodel'" {
			local smodel "w"
		}
		else if substr("gompertz",1,max(1,`l')) == "`survmodel'" {
			local smodel "g"
		}
		else if "fpm" == "`survmodel'" {
			local smodel "fpm"
		}
		else {
			di as error "Unknown survival submodel"
			exit 198
		}
		global smodel "`smodel'"

		if "`covariance'"=="" {
			local cov "unstr"
			global labtextvcv "Unstructured"
		}
		else {
			local l = length("`covariance'")
			if substr("independent",1,max(3,`l')) == "`covariance'" {
				local cov "ind"
				global labtextvcv "Independent"
			}
			else if substr("exchangeable",1,max(2,`l')) == "`covariance'" {
				local cov "exch"
				global labtextvcv "Exchangeable"
			}
			else if substr("identity",1,max(2,`l')) == "`covariance'" {
				local cov "iden"
				global labtextvcv "Identity"
			}
			else if substr("unstructured",1,max(2,`l')) == "`covariance'" {
				local cov "unstr"
				global labtextvcv "Unstructured"
			}
			else {
				di as error "Unknown variance-covariance structure"
				exit 198
			}
		}
		global cov "`cov'"		
		
		/*  Weights not allowed */
		if "`weight'" != "" {
			display as err "weights not allowed"
			exit 198
		}
		local wt: char _dta[st_w]       
		if "`wt'" != "" {
			display as err "weights not allowed"
			exit 198
		}
		
		/* Factor variables not allowed */
		fvexpand `varlist' `survcov' `timeinteraction' `assoccovariates'
		if "`r(fvops)'" != "" {
			display as error "Factor variables not allowed. Create your own dummy varibles."
			exit 198
		}
		
		if "`smodel'"=="fpm" {
			capture which stpm2
			if _rc >0 {
				display in yellow "You need to install the command stpm2. This can be installed using,"
				display in yellow ". {stata ssc install stpm2}"
				exit 198
			}
			capture which rcsgen
			if _rc >0 {
				display in yellow "You need to install the command rcsgen. This can be installed using,"
				display in yellow ". {stata ssc install rcsgen}"
				exit 198
			}
			
			/* Check stpm2 is up to date */
			qui findfile stpm2.ado
			mata: fh = fopen(st_global("r(fn)"),"r")
			mata: st_local("line1",fget(fh))
			mata: fclose(fh)
			local line1 = trim("`line1'")
			local l = length("`line1'")
			local date = lower(substr("`line1'",`=`l'-9',`l'))
			local datenum = td("`date'")
			if `datenum'<18879 {
				di as error "You need to update the command stpm2. This can be installed using,"
				display in yellow ". {stata ssc install stpm2, replace}"
				exit 198
			}
		}
		
		if "`smodel'"!="fpm" & ("`df'"!="" | "`knots'"!="") {
			di as error "Can only specify df/knots when survmodel = fpm"
			exit 198
		}
		
		if "`rfracpoly'"=="" & "`ffracpoly'"=="" {
			di as error "One of rfracpoly and ffracpoly must be specified"
			exit 198
		}		
		
		if "`rfracpoly'"=="" & "`decomp'"!="" {
			di as error "Decomposition can only be used when multiple random effects are specified"
			exit 198
		}
		
		if ("`nocurrent'"!="" & "`intassociation'"=="" & "`association'"=="" & "`derivassociation'"=="") {
			di as error "No association between submodels has been specified"
			exit 198
		}
		
		if ("`derivassociation'"!="" & "`rfracpoly'"=="") {
			di as error "Random time variables must be specified for derivative association."
			exit 198
		}
		
		if ("`association'"!="" & "`rfracpoly'"=="") {
			di as error "Random time variables must be specified for separate association."
			exit 198
		}
		
		if "`rfracpoly'"!="" {
			foreach re of numlist `rfracpoly' {
				if (`re'!=-5 & `re'!=-4 & `re'!=-3 & `re'!=-2 & `re'!=-1 & `re'!=-0.5 & `re'!=0 & `re'!=0.5 & `re'!=1 & `re'!=2 & `re'!=3 & `re'!=4 & `re'!=5) {
					di as error "FP1 powers must be one of -2, -1, -.5, 0, .5, 1, 2, 3"
					exit 198
				}
			}
		}
		
		if "`ffracpoly'"!="" {
			foreach fe of numlist `ffracpoly' {
				if (`fe'!=-5 & `fe'!=-4 & `fe'!=-3 & `fe'!=-2 & `fe'!=-1 & `fe'!=-0.5 & `fe'!=0 & `fe'!=0.5 & `fe'!=1 & `fe'!=2 & `fe'!=3 & `fe'!=4 & `fe'!=5) {
					di as error "FP1 powers must be one of -2, -1, -.5, 0, .5, 1, 2, 3"
					exit 198
				}
			}
		}
		
		local dumcheck = 0
		if "`rfracpoly'"!="" & "`ffracpoly'"!="" {
			foreach re of numlist `rfracpoly' {
				foreach fe of numlist `ffracpoly' {
					if "`re'"=="`fe'" {
						local dumcheck = 1
					}
				}
			}
		}
		if `dumcheck'==1 {
			di as error "You cannot specify both a fixed and random fracpoly with the same power"
			exit 198
		}
		
		if ("`association'"!="" & "`rfracpoly'"!="") {		/*check separate associations are specified in rfracpoly */
			local dumcheck   = 0
			local finalcheck = 0
			foreach a of numlist `association' {
				foreach b of numlist `rfracpoly' {
					if `a'==`b' {
						local dumcheck = 1
					}
				}
				if `dumcheck'==0 {
					local finalcheck = 1
				}
			}
			if `finalcheck'==1 {
				di as error "Elements of association must be in rfracpoly"
				exit 198
			}			
		}

		if "`showcons'"!="" & "`smodel'"!="fpm" {
			di as error "showcons only allowed when survmodel = fpm"
			exit 198
		}		

		if "`gk'"!="" {
			if "`gk'"!="15" & "`gk'"!="7" {
				di as error "gk must be 7 or 15"
				exit 198
			}
		}
		
		if "`smodel'"=="fpm" & "`df'"=="" & "`knots'"=="" {
			di as error "One of df or knots must be specified"
			exit 198
		}
		
		if "`smodel'"=="fpm" {
			if "`df'"!="" & "`knots'"!="" {
				di as error "Only one of df and knots can be specified"
				exit 198
			}
		}
	
		if "`adaptit'"!="" {
			cap confirm integer number `adaptit'
			if _rc>0 {
				di as error "adaptit must be an integer"
				exit 198
			}
			if `adaptit'<0 {
				di as error "adaptit must be >0"
				exit 198
			}			
		}
		else local adaptit = 5
		
		if "`gh'"!="" {
			cap confirm integer number `gh'
			if _rc>0 {
				di as error "gh must be an integer"
				exit 198
			}
			if `gh'<2 {
				di as error "gh must be > 1"
				exit 198
			}
		}
		else {
			if "`nonadapt'"=="" {
				local gh = 5
			}
			else {
				local gh = 15
			}
		}
				
	/******************************************************************************************************************************************************************************************/
	/* DEFAULTS */	
			
		if "`showinitial'"!="" {
			local noisily "noisily"
		}
		
		if "`noorthog'"!="" {
			local orthog "noorthog"
		}
		else {
			local orthog
		}	

		if "`smodel'"!="fpm" & "`gk'"==""{
			local gk = 15		
		}

		if "`timeinteraction'"!="" {
			global timeinterac yes
		}
		else {
			global timeinterac no
		}
		
		
	/******************************************************************************************************************************************************************************************/
	/* Preliminaries */
	
		/* Mark estimation sample */
		marksample touse
		markout `touse' `survcov' `timeinteraction' `assoccovariates'
		
		global touse `touse'
		qui replace `touse' = 0  if _st==0
		
		/* Extract longitudinal outcome and any fixed covariates in long. submodel */
		gettoken lhs rhs : varlist					
		
		/* Extract any ml options to pass to ml model */
		mlopts mlopts , `options'	
		local extra_constraints `s(constraints)'

		/* Generate temporary patient ID variable */
		tempvar _tempid
		qui egen `_tempid' = group(`panel')	if `touse'==1			
		global MY_panel "`_tempid'"
		
		/* Calculate number of repeated measurements */
		qui count if `touse'==1
		global nmeasures = `r(N)'						
		
		/* Generate final row indicator variable */
		tempvar surv_ind 
		qui bys `_tempid' (_t0): gen `surv_ind'= (_n==_N & `touse'==1)	
		global surv_indlab "`surv_ind'"
		
		/* Calculate number of patients */
		qui count if `surv_ind'==1
		global Npat = `r(N)'		
		
		/* Number of covariates in each submodel */
		local n_scovs : word count `survcov'			//list sizeof in extended macros
		local n_lcovs : word count `rhs'
		
		/* Number of measurements per patient */
		tempvar n_meas
		qui bys `_tempid' (_t0): gen `n_meas' = _N if `touse'==1											
		global nmeasvar `n_meas'

		/* Numbers */
		global n_ftime : word count `ffracpoly'													/* Number of fixed fractional polynomials of time - d0 and results table */
		global n_rtime : word count `rfracpoly'													/* Number of random fractional polynomials of time - results table */
		global n_tot_long_eqns = $n_rtime + $n_ftime +1											/* Number of model equations in longitudinal submodel - results table */
		global npows = $n_ftime + $n_rtime														/* Number of time variables */
		global n_re = $n_rtime + 1																/* Total number of random effects */

		/* Drop previously created timevars */
		cap drop _time_*
		
		/* Put fixed and random FP's in ascending order */
		numlist "`ffracpoly' `rfracpoly'", sort
		local fps `r(numlist)'
		
		/* Use fracgen to extract `shift' if needed */
		local firstpow : word 1 of `fps'
		if `firstpow' <= 0 {
			qui fracgen _t0 `fps' if `touse',  noscaling nogen
			local shift = `r(shift)'
		}
		else {
			local shift = 0
		}
		mata: shift = `shift'
		
		/* Adjust _t and _t0 for centring of FP's using tempvars */
		tempvar stime basetime
		qui gen double `stime'		= _t + `shift' if `touse'==1										
		qui gen double `basetime' 	= _t0 + `shift' if `touse'==1		
		local survtimevar `stime'										/* To read into Mata */
		local basetimevar `basetime'
		
		/* Check time origin for delayed entry models */
		global del_entry = 0
		tempvar del_surv_ind
		cap sort `_tempid' _t0
		by `_tempid': gen `del_surv_ind' = (_n==1 & `touse'==1)	//summary passed to below quick/slow check

		if "`association'"!="" {
			global n_time_assoc : word count `association'
			mat timeassoc_fixed_ind = J($n_time_assoc,1,.)
		}		
		
	/******************************************************************************************************************************************************************************************/
	/* Things to pass to results table */
	
		global panel `panel'																	/* Name of panel variable */
		
		if "`cov'"=="ind" | "`cov'"=="iden" {
			global n_cov_params = 0
		}
		else if "`cov'"=="unstr" {
			local cov_list "0 1 3 6 10 15"
			global n_cov_params : word $n_re of `cov_list'											/* Number of covariance parameters */
		}
		else {
			global n_cov_params = 1
		}

	/******************************************************************************************************************************************************************************************/
	/* Quick or slow */
		
		if "`fulldata'"=="" & "`survmodel'"!="fpm" {
			if "`survcov'"!="" | "`assoccovariates'"!="" {
				local nvardiffs = 0
				foreach var of varlist `survcov' `assoccovariates' {
					tempvar ind_`var'
					qui bys `_tempid' (_t0): gen `ind_`var'' = (`var'[_n]==`var'[_n+1]) if _n<_N & _N>1
					qui bys `_tempid' (_t0): replace `ind_`var'' = (`var'[_n]==`var'[_n-1]) if _n==_N & _N>1
					qui count if `ind_`var''==0
					local nvardiffs = `nvardiffs' + `r(N)'
				}
				if `nvardiffs'==0 {
					local quick quick
				}
			}
			else local quick quick
		}
		
		if "`quick'"=="" | "`survmodel'"=="fpm" {
			local newdelsurvtouse "`touse'"
			local newsurvtouse "`touse'"
			local nsurvrows = $nmeasures
			global quick
			di in yellow "Warning -> all rows of data are being used in the survival component of the likelihood."
			di in yellow "        -> care must be taken if missing data is present, see the help file for details."
			di ""
		}
		else {
			local newdelsurvtouse "`del_surv_ind'"
			local newsurvtouse "`surv_ind'"
			local nsurvrows = $Npat
			global quick _quick
		}
		global newsurvtouse "`newsurvtouse'"
		
		qui summ _t0 if `newdelsurvtouse'==1, meanonly
		
		if `r(max)'>0 | "`survmodel'"=="fpm" {
			display in green  "note: delayed entry models are being fitted"
			global del_entry 1
			global del_survindlab "`del_surv_ind'"
		}		

	/******************************************************************************************************************************************************************************************/
	/* Create time variables */
		
		/* Indicator matrix to denote random FP's */
		mat rand_ind = J(1,$npows,0)
		/* Matrix to store FP powers */
		mat fp_pows  = J(1,$npows,.)
		
		/* Generate timevars */
		local j = 1
		local tassoc_ind = 1
		local tfi_ind = 1
		foreach i of numlist `fps' {
		
			mat fp_pows[1,`j'] = `i'																			/* Store powers in matrix for Mata */
			
			/* Generate timevars for dataset and display text*/
			/* Generate timevars at survival times for d0, including d/dt for hazard function */
			tempvar time_surv_`j'
			if (`i'!=0) {
				qui gen double _time_`j' 			= (`basetime')^(`i') 	if `touse'==1	
				qui gen double `time_surv_`j'' 		= (`stime')^(`i') 		if `touse'==1
				
				/* first derivative of time variables d/dt*/
				if "`smodel'"=="fpm" | "`derivassociation'"!="" {
					tempvar diff_time_`j' diff_time_surv_`j'
					qui gen double `diff_time_`j''		= `i'*(`basetime')^(`=`i'-1') 	if `touse'==1
					qui gen double `diff_time_surv_`j'' 	= `i'*(`stime')^(`=`i'-1') 	if `touse'==1
					local diff_fp_timevar_names "`diff_fp_timevar_names' `diff_time_`j''"
					local diff_fp_timevar_names_surv "`diff_fp_timevar_names_surv' `diff_time_surv_`j''"			
				}
				
				/* second derivative of time variables d2/dt2*/
				if "`smodel'"=="fpm" & "`derivassociation'"!="" {
					tempvar 2_diff_time_`j' 2_diff_time_surv_`j'
					if `i'!=1 {
						qui gen double `2_diff_time_`j'' 		= (`=`i'-1')*(`i')*(`basetime')^(`=`i'-2') 	if `touse'==1
						qui gen double `2_diff_time_surv_`j'' 	= (`=`i'-1')*(`i')*(`stime')^(`=`i'-2') 	if `touse'==1
					}
					else {
						qui gen double `2_diff_time_`j'' 		= 0 if `touse'==1
						qui gen double `2_diff_time_surv_`j'' 	= 0 if `touse'==1
					}
					local 2_diff_fp_timevar_names "`2_diff_fp_timevar_names' `2_diff_time_`j''"
					local 2_diff_fp_timevar_names_surv "`2_diff_fp_timevar_names_surv' `2_diff_time_surv_`j''"
				}
				n di in green "-> gen double _time_`j' = X^(`i')"
				label variable _time_`j' "_time_`j' = X^(`i') `xtxt'"
			}
			else {
				qui gen double _time_`j' 				= log(`basetime') 	if `touse'==1	
				qui gen double `time_surv_`j'' 			= log(`stime') 		if `touse'==1
				if "`smodel'"=="fpm" | "`derivassociation'"!="" {
					tempvar diff_time_`j' diff_time_surv_`j'
					qui gen double `diff_time_`j''			= 1/(`basetime') 	if `touse'==1
					qui gen double `diff_time_surv_`j'' 	= 1/(`stime') 		if `touse'==1
					local diff_fp_timevar_names "`diff_fp_timevar_names' `diff_time_`j''"
					local diff_fp_timevar_names_surv "`diff_fp_timevar_names_surv' `diff_time_surv_`j''"			
				}
				if "`smodel'"=="fpm" & "`derivassociation'"!="" {
					tempvar 2_diff_time_`j' 2_diff_time_surv_`j'
					qui gen double `2_diff_time_`j'' 		= -1/((`basetime')^2) 	if `touse'==1
					qui gen double `2_diff_time_surv_`j'' 	= -1/((`stime')^2) 		if `touse'==1
					local 2_diff_fp_timevar_names "`2_diff_fp_timevar_names' `2_diff_time_`j''"
					local 2_diff_fp_timevar_names_surv "`2_diff_fp_timevar_names_surv' `2_diff_time_surv_`j''"
				}
				n di in green "-> gen double _time_`j' = log(X)"
				label variable _time_`j' "_time_`j' = log(X) `xtxt'"
			}

			local fp_timevar_names "`fp_timevar_names' _time_`j'"												/* Timevar variable names for Mata */
			local fp_timevar_names_surv "`fp_timevar_names_surv' `time_surv_`j''"								/* Variable names to read into Mata */
			
			if "`rfracpoly'"!=""{
				foreach re of numlist `rfracpoly' {
					if `re'==`i' {
						mat rand_ind[1,`j'] = 1																	/* Ref matrix for mata to identify which ones are random */
						local re_timevars "`re_timevars' _time_`j'"											/* Time variable names of random time variables for xtmixed call and for predictions */
						local re_timevars_surv "`re_timevars_surv' `time_surv_`j''"
						if "`smodel'"=="fpm" | "`derivassociation'"!="" {
							local diff_re_timevars "`diff_re_timevars' `diff_time_`j''"
							local diff_re_timevars_surv "`diff_re_timevars_surv' `diff_time_surv_`j''"
						}
						if "`smodel'"=="fpm" & "`derivassociation'"!="" {
							local 2_diff_re_timevars "`2_diff_re_timevars' `2_diff_time_`j''"
							local 2_diff_re_timevars_surv "`2_diff_re_timevars_surv' `2_diff_time_surv_`j''"
						}
					}
				}
			}
			
			if "`association'"!="" {
				local dumtest = 0
				foreach ass in `association' {
					if `i'==`ass' {
						mat timeassoc_fixed_ind[`tfi_ind',1] = `tassoc_ind'
						local `++tfi_ind'
					}
				}				
				local `++tassoc_ind'
			}
			
			/****************************************************************************************************************************************/
			/* time and covariate interactions */
			if "`timeinteraction'"!="" {
			
				foreach covtime of varlist `timeinteraction' {
					tempvar interac_t0_`j'_`covtime' interac_t_`j'_`covtime'
					qui gen double _time_`j'_`covtime'		= `covtime' * _time_`j' 		if `touse'==1
					qui gen double `interac_t_`j'_`covtime'' 	= `covtime' * `time_surv_`j'' 	if `touse'==1
					local covinterlist1 "`covinterlist1' _time_`j'_`covtime'"
					local covinterlist2 "`covinterlist2' `interac_t_`j'_`covtime''"
					n di in green "-> gen double _time_`j'_`covtime' = `covtime' * _time_`j'"
					label variable _time_`j'_`covtime' "_time_`j'_`covtime' = `covtime' * _time_`j'"
					local `++tassoc_ind'
				}
				
				if "`smodel'"=="fpm" | "`derivassociation'"!="" {
					foreach covtime of varlist `timeinteraction' {
						tempvar  deriv_interac_t_`j'_`covtime'
						qui gen double `deriv_interac_t_`j'_`covtime'' 	= `covtime' * `diff_time_surv_`j'' 	if `touse'==1
						local deriv_covinterlist_surv "`deriv_covinterlist_surv' `deriv_interac_t_`j'_`covtime''"
						if "`smodel'"=="fpm"{
							tempvar  deriv_interac_t0_`j'_`covtime'
							qui gen double `deriv_interac_t0_`j'_`covtime'' 	= `covtime' * `diff_time_`j'' 	if `touse'==1
							local deriv_covinterlist_long "`deriv_covinterlist_long' `deriv_interac_t0_`j'_`covtime''"
						}
					}
				}
				
				if "`smodel'"=="fpm" & "`derivassociation'"!="" {
					foreach covtime of varlist `timeinteraction' {
						tempvar  deriv2_interac_t_`j'_`covtime'
						qui gen double `deriv2_interac_t_`j'_`covtime'' 	= `covtime' * `2_diff_time_surv_`j'' 	if `touse'==1
						local deriv2_covinterlist_surv "`deriv2_covinterlist_surv' `deriv2_interac_t_`j'_`covtime''"
					}
				}
			
			}	
			
			local `++j'
		}
		
		global ninterac : word count `timeinteraction'
		scalar ntimecovinterac = $ninterac
		
		mat rand_ind_gk = J(1,$n_re,`=$npows+1+$ninterac+`n_lcovs'')
		
		local nj=1
		forvalues i=1/$npows {
			if rand_ind[1,`i']==1 {
				mat rand_ind_gk[1,`nj']=`i'
				local `++nj'
			}
		}
		mata: rand_ind_gk = st_matrix("rand_ind_gk")

		if `shift'==0 {	
			n di in green "(where X = _t0)"
		}
		else {
			n di in green "(where X = _t0 + `shift')"
		}
		
		/* Variance ml equation names */
		if "`cov'"=="ind" | "`cov'"=="unstr" {
			forvalues i=1/$n_re {
				local var_re_eqn_names "`var_re_eqn_names' /lns_`i'"											
			}
		}
		else {
			local var_re_eqn_names "/lns_1"
		}
		
		local fp_eqn_names "(Longitudinal: `lhs'= `fp_timevar_names' `covinterlist1' `rhs')"				/* Longitudinal ml equation */
		global retimelabelnames2 "`re_timevars' _cons"														/* For results table */

	/******************************************************************************************************************************************************************************************/
	/* Pass design matrices of timevars to Mata */
	
		/* Fixed effect design matrices at exit times */
			local longparams_surv "`fp_timevar_names_surv' `covinterlist2' `rhs'"								
			mata: X_dm_surv = st_data(.,tokens(st_local("longparams_surv")),st_local("newsurvtouse")),J(`nsurvrows',1,1)
			if "`rfracpoly'"!="" {
				mata: Z_dm = st_data(.,tokens(st_local("re_timevars")),st_local("touse")),J($nmeasures,1,1)
				mata: Z_dm_surv = st_data(.,tokens(st_local("re_timevars_surv")),st_local("newsurvtouse")),J(`nsurvrows',1,1)
			}
			else {
				mata: Z_dm = J($nmeasures,1,1)
				mata: Z_dm_surv = J(`nsurvrows',1,1)
			}			
			
			if "`smodel'"=="fpm" | "`derivassociation'"!="" {
				local ntemp = `n_lcovs' + 1
				local diff_fp_timevar_names "`diff_fp_timevar_names' `deriv_covinterlist_long'"
				local diff_fp_timevar_names_surv "`diff_fp_timevar_names_surv' `deriv_covinterlist_surv'"
				mata: diff_X_dm = st_data(.,tokens(st_local("diff_fp_timevar_names")),st_local("newdelsurvtouse")),J(`nsurvrows',`ntemp',0)
				mata: diff_X_dm_surv = st_data(.,tokens(st_local("diff_fp_timevar_names_surv")),st_local("newsurvtouse")),J(`nsurvrows',`ntemp',0)
				if "`rfracpoly'"!="" {
					mata: diff_Z_dm = st_data(.,tokens(st_local("diff_re_timevars")),st_local("newdelsurvtouse")),J(`nsurvrows',1,0)
					mata: diff_Z_dm_surv = st_data(.,tokens(st_local("diff_re_timevars_surv")),st_local("newsurvtouse")),J(`nsurvrows',1,0)
				}
				else {
					mata: diff_Z_dm = diff_Z_dm_surv = J(`nsurvrows',1,0)
				}
			}
			else {
				mata: diff_X_dm = diff_X_dm_surv = diff_Z_dm = diff_Z_dm_surv = J(`nsurvrows',1,0)
			}
			
			if "`smodel'"=="fpm" & "`derivassociation'"!="" {
				local 2_diff_fp_timevar_names_surv "`2_diff_fp_timevar_names_surv' `deriv2_covinterlist_surv'"
				mata: diff2_X_dm_surv = st_data(.,tokens(st_local("2_diff_fp_timevar_names_surv")),st_local("newsurvtouse")),J(`nsurvrows',`ntemp',0)
				if "`rfracpoly'"!="" {
					mata: diff2_Z_dm_surv = st_data(.,tokens(st_local("2_diff_re_timevars_surv")),st_local("newsurvtouse")),J(`nsurvrows',1,0)
				}
				else {
					mata: diff2_Z_dm_surv = J(`nsurvrows',1,0)
				}
			}
			else {
				mata: diff2_X_dm_surv = 0
				mata: diff2_Z_dm_surv = 0
			}
			
		
	/******************************************************************************************************************************************************************************************/
	/* ASSOCIATION PARAMETERISATION */
	
		global n_sepassoc : word count `association'
		local alpha_ith = 1
		
		if "`nocurrent'"=="" {
			global current "yes"
			local alphaequation "`alphaequation' (alpha_`alpha_ith': `assoccovariates')"				/* current association - default */
			local `++alpha_ith'
		}
		else {
			global current "no"
		}
		
		if "`derivassociation'"!="" {
			global deriv "yes"
			local alphaequation "`alphaequation'(alpha_`alpha_ith': `assoccovariates')"					/* association based on derivatives */
			local `++alpha_ith'
		}
		else {
			global deriv "no"
		}
		
		if "`intassociation'"!="" {																		/* association based on random intercept */
			global intassoc "yes"
			local alphaequation "`alphaequation'(alpha_`alpha_ith': `assoccovariates')"
			local `++alpha_ith'
		}
		else {
			global intassoc "no"
		}
		
		if "`association'"!="" {																		/* association based on random coefficient */
			global timeassoc "yes"
			foreach assoc of numlist `association' {
				local alphaequation "`alphaequation'(alpha_`alpha_ith': `assoccovariates')"	
				local `++alpha_ith'
			}
		}
		else {
			global timeassoc "no"
		}
		
		global n_alpha = `alpha_ith' - 1																/* Number of association parameters */
	
	/******************************************************************************************************************************************************************************************/
	/* INITIAL VALUES */
		
quietly{

		noisily di
		noisily di as txt "Obtaining initial values:"
		noisily di	
		
		tempname initmat
		/* Longitudinal model initial values */
		`noisily' xtmixed `lhs' `fp_timevar_names' `covinterlist1' `rhs' if `touse' || `_tempid': `re_timevars', cov(`cov') `variance'
		matrix `initmat' = e(b)
				
		/* predict RE's and seRE's */
		forvalues i=1/$n_re {
			tempvar blup`i' seblup`i'
			local blupnames "`blupnames' `blup`i''"
			local seblupnames "`seblupnames' `seblup`i''"
		}
		predict `blupnames' if `touse', reffects
		predict `seblupnames' if `touse', reses

		if "`nocurrent'"=="" {
			tempvar fitvals	
			predict `fitvals' if `touse', fitted
			if "`assoccovariates'"!="" {
				foreach var of varlist `assoccovariates' {
					tempvar assocint_`var'
					qui gen double `assocint_`var'' = `fitvals'*`var'
					local associntlist1 "`associntlist1' `assocint_`var''"
				}
			}
			local alpha_di_txt "assoc:value"
		}
		
		if "`intassociation'"!="" | "`association'"!="" | "`derivassociation'"!=""{
			/* predict RE's */
			forvalues i=1/$n_re {
				tempvar sepassoc`i'
				local refnames "`refnames' `sepassoc`i''"
			}
			predict `refnames' if `touse', reffects
			
			if "`derivassociation'"!="" {
					
				local i = 1
				foreach pow of numlist `fps' {
					local basis_pow`i' = `pow'
					local `++i'
				}
				tempvar deriv_1
				qui gen `deriv_1' = 0
				local stub 		= 1
				local re_stub 	= 1
				foreach pow of numlist `fps' {
					if `pow'!=0 {
						if rand_ind[1,`stub']==1 {
							local derivadd "(([`lhs'][_time_`stub'] + `sepassoc`re_stub'')*(`pow')*`basetime'^(`pow'-1))"
							local `++re_stub'
						}
						else {
							local derivadd "([`lhs'][_time_`stub']*(`pow')*`basetime'^(`pow'-1))"	
						}
					}
					else {
						if rand_ind[1,`stub']==1 {
							local derivadd "(([`lhs'][_time_`stub'] + `sepassoc`re_stub'')/`basetime')"
							local `++re_stub'
						}
						else {
							local derivadd "([`lhs'][_time_`stub']/`basetime')"
						}
					}
					if "`timeinteraction'"!="" {
						foreach var of varlist `timeinteraction' {
							local derivadd2 "`derivadd2' + `derivadd'*`var' "
						}
					}
					replace `deriv_1' = `deriv_1' + (`derivadd') `derivadd2'
					local `++stub'
				}
				
				if "`assoccovariates'"!="" {
					foreach var of varlist `assoccovariates' {
						tempvar assocderivint_`var'
						qui gen double `assocderivint_`var'' = `deriv_1'*`var'
						local associntlist2 "`associntlist2' `assocderivint_`var''"
					}
				}
				local derivlist "`deriv_1'"
				
				local alpha_di_txt "`alpha_di_txt' assoc:slope"		
					
			}				
			
			if "`intassociation'"!="" {
				local sepassocnameint "`sepassoc$n_re'"
				if "`assoccovariates'"!="" {
					foreach var of varlist `assoccovariates' {
						tempvar associntint_`var'
						qui gen double `associntint_`var'' = `sepassoc$n_re'*`var'
						local associntlist3 "`associntlist3' `associntint_`var''"
					}
				}				
				local alpha_di_txt "`alpha_di_txt' assoc:int"
			}
			
			if "`association'"!="" {
				//need to extract random time variables whose coefficients are specified for the association
				//index random time variables 
				mat timeassoc_re_ind = J($n_time_assoc,1,.)
				local re  = 1
				local ind = 1
				foreach repow of numlist `rfracpoly' {
					foreach ass of numlist `association' {
						if `repow'==`ass' {
							mat timeassoc_re_ind[`ind',1] = `re'
							local `++ind'
						}				
					}	
					local `++re'
				}
				local ind_row = 1
				foreach a of numlist `association' { 
					local ind_re  = 1
					foreach b of numlist `fps' {
						if `a'==`b' {
							if "`assoccovariates'"!="" {
								foreach var of varlist `assoccovariates' {
									tempvar associntsep_`var'
									qui gen double `associntsep_`var'' = `sepassoc`ind_row''*`var'
									local sepassocnames "`sepassocnames' `associntsep_`var''"
								}
							}
							local sepassocnames "`sepassocnames' `sepassoc`ind_row''"
							local sepassocpred "`sepassocpred' `ind_re'"
							local alpha_di_txt "`alpha_di_txt' a:_time_`ind_re'"
						}
						local `++ind_re'
					}
					local `++ind_row'
				}
			}
		}
		global alpha_di_txt `alpha_di_txt'
	
		if "`cov'"=="exch" & $n_re>1 {
			local corr_eqn_names "/art_1_1"
			local corr_eqn_names2 "art_1_1"		
		}
		else if "`cov'"=="unstr" {
			local subind = 1
			while (`subind'<$n_re) {
				forvalues i=`=`subind'+1'/$n_re {
					local corr_eqn_names  "`corr_eqn_names' /art_`subind'_`i'"
					local corr_eqn_names2 "`corr_eqn_names2' art_`subind'_`i'"
				}
				local `++subind'
			}
		}
		
		local longequation "`fp_eqn_names' `var_re_eqn_names' `corr_eqn_names' /lns_e"
		
		local nvcvparams : word count `var_re_eqn_names' `corr_eqn_names'
	
		/*********************************/
		/* Survival model initial values */
		
		local searchopt "search(off)"
		tempname initmatsurv
		/* Flexible parametric model */
		if "`smodel'"=="fpm" {
			if "`df'"!="" {
				local splines "df(`df')"
			}
			else {
				local splines "knots(`knots')"
			}
			
			`noisily' stpm2 `associntlist1' `fitvals' `associntlist2' `derivlist' `associntlist3' `sepassocnameint' `sepassocnames' `survcov' if `touse', `splines' scale(hazard) `orthog' failconvlininit	/* initial values from stpm2 fit, keeping constraints */

			local ln_bhknots `e(ln_bhknots)'
			
			local nalphacovs : word count `assoccovariates'
			local n1 = $n_alpha * (`nalphacovs' +1 ) + `n_scovs' + 2*`df' + 1 
			local n2 = `n1' + $n_alpha * (`nalphacovs' +1 ) + 1
			
			tempname mat1
			mat `mat1' = e(b)
			mat `initmatsurv' = `mat1'[1,1..`n1']
			mat `initmatsurv' = `initmatsurv',`mat1'[1,`n2'..colsof(`mat1')]
			tempname R_bh
			mat `R_bh' = e(R_bh)
			
			/* rcs and drcs names */
			local rcsnames "`e(rcsterms_base)'"
			local drcsnames "`e(drcsterms_base)'"
			
			if "`df'"=="" {
				local df : word count `rcsnames'
			}
			
			/* Constraints */
				forvalues i=1/`df' {
					local r`i' : word `i' of `rcsnames'
					local dr`i' : word `i' of `drcsnames'
					constraint free
					constraint `r(free)' [xb][`r`i'']=[dxb][`dr`i'']
					local conslist "`conslist' `r(free)'"
					/* Delayed entry */
					local srcsnames "`srcsnames' _s0_rcs`i'"
					constraint free
					constraint `r(free)' [xb][`r`i'']=[xb0][_s0_rcs`i']
					local conslist "`conslist' `r(free)'"
				}
	
				local xb0_eqn "(xb0: `survcov' `srcsnames')"				
				constraint free
				constraint `r(free)' [xb][_cons]=[xb0][_cons]
				local conslist "`conslist' `r(free)'"

				if "`survcov'"!="" {
					foreach var in `survcov' {
						constraint free
						constraint `r(free)' [xb][`var']=[xb0][`var']
						local conslist "`conslist' `r(free)'"
					}
				}
				
			local dropconslist `conslist'
			/* If further constraints are listed stpm2 then remove this from mlopts and add to conslist */
				if "`extra_constraints'" != "" {
					local mlopts : subinstr local mlopts "constraints(`extra_constraints')" "", word
					local conslist `conslist' `extra_constraints'
				}	
										
			global constnums `conslist'
			local constopts "constraints($constnums)"

			local collinopt "collinear"																		/* pass collinear option as ml can drop spline variables when it shouldn't */
			local survequation "(xb: `survcov' `rcsnames') (dxb: `drcsnames', nocons) `xb0_eqn'"			/* rcs and drcs equations to pass to ml model */
				
		}
		/* Exponential PH model */
		else if "`smodel'"=="e" {
		
			`noisily' streg `associntlist1' `fitvals' `associntlist2' `derivlist' `associntlist3' `sepassocnameint' `sepassocnames' `survcov' if `touse', dist(exp) nohr 					/* initial values from streg fit */
			mat `initmatsurv' = e(b)
			
			local survequation "(ln_lambda: `survcov')"	
		
		}
		/* Weibull PH model */
		else if "`smodel'"=="w" {
		
			`noisily' streg `associntlist1' `fitvals' `associntlist2' `derivlist' `associntlist3' `sepassocnameint' `sepassocnames' `survcov' if `touse', dist(weibull) nohr 					/* initial values from streg fit */
			mat `initmatsurv' = e(b)
			
			local survequation "(ln_lambda: `survcov') /ln_gamma"	
		
		}
		/* Gompertz PH model */
		else if "`smodel'"=="g" {
		
			`noisily' streg `associntlist1' `fitvals' `associntlist2' `derivlist' `associntlist3' `sepassocnameint' `sepassocnames' `survcov' if `touse', dist(gompertz) nohr 					/* initial values from streg fit */
			mat `initmatsurv' = e(b)
			
			local survequation "(ln_lambda: `survcov') /gamma"	
		
		}
		
		if ("`nullassoc'"!="" & "`nocurrent'"=="") {
			forvalues i=1/$n_alpha {
				mat `initmatsurv'[1,`i']=0
			}
		}		

		matrix `initmat' = `initmat',`initmatsurv'
		
		/* Generate quadrature node and weight matrices */
		ghquadm `gh' nodes weights

}	

	/******************************************************************************************************************************************************************************************/
	/* Mata */
		
		mata: y_ij = st_data(.,st_local("lhs"),st_local("touse"))											/* Response */

		mata: del_entry_time = st_data(.,st_local("basetimevar"),st_local("newdelsurvtouse"))
		mata: stime = st_data(.,st_local("survtimevar"),st_local("newsurvtouse"))							/* Survival time */
		mata: d = st_data(.,"_d",st_local("newsurvtouse"))													/* Event indicator */

		if "`nonadapt'"=="" {
			mata: weights = J($n_re,1,st_matrix("weights"))
			mata: nodes = J($n_re,1,st_matrix("nodes"))
			mata: mu_i = st_data(.,tokens(st_local("blupnames")),st_local("touse"))
			mata: tau_i = st_data(.,tokens(st_local("seblupnames")),st_local("touse"))
			mata: basisreps = cols(nodes):^$n_re																/* No. of permutations for node sequences */
			mata: nodesfinal = weightsfinal = basis =  basis2 = J($n_re,basisreps,.)							/* Basis matrix to store completed sequences of nodes; rows = no. of RE's */
				/* Create nodesfinal and weightsfinal */
				mata: nodes_weights($n_re,$Npat,nodes,weights,nodesfinal,weightsfinal,basis2)
			global first_call -1 		
			mata: firstit = -1
			mata: adaptit = `adaptit'
			mata: aghnodes = asarray_create("real",1)
			mata: aghweights = asarray_create("real",1)
			mata: adapt("`smodel'", aghnodes,aghweights,mu_i,tau_i,nodesfinal,weightsfinal,$n_re)
		}
		else {
			mata: nodes = sqrt(2):*J($n_re,1,st_matrix("nodes"))
			mata: weights = J($n_re,1,st_matrix("weights")):/sqrt(pi())
			mata: basisreps = cols(nodes):^$n_re																/* No. of permutations for node sequences */
			mata: nodesfinal = weightsfinal = basis =  basis2 = J($n_re,basisreps,.)							/* Basis matrix to store completed sequences of nodes; rows = no. of RE's */
			/* Create nodesfinal and weightsfinal */
			mata: nodes_weights($n_re,$Npat,nodes,weights,nodesfinal,weightsfinal,basis2)
		}
		

		mata: survlike = longlike = J($Npat,basisreps,0)
		mata: jlnodes = J($Npat,basisreps,.)

		mata: id = st_data(.,st_local("_tempid"),st_local("touse"))	
		mata: info = panelsetup(id, 1)
		mata: nmeas = info[.,2]:-info[.,1] :+ 1
		mata: nres = $n_re
		mata: N = $Npat
		mata: Nmeas = $nmeasures
		
		if "`rhs'"!=""{
			mata: covariates = st_data(.,tokens(st_local("rhs")),st_local("newsurvtouse"))
		}
		else {
			mata: covariates = 0
		}
		
		if "`timeinteraction'"!="" {
			mata: timecovariates = st_data(.,tokens(st_local("timeinteraction")),st_local("newsurvtouse"))		
		}
		else {
			mata: timecovariates = 0
		}		
		
		
		mata: newweights = J($Npat, `gh', 0)     //??
		
		/* Gauss-Kronrod nodes */
		if "`smodel'"!="fpm" {
			gausskronrod`gk'	
			mata: kweights = ((stime:-del_entry_time):/2):*J(`nsurvrows',1,st_matrix("kweights"))
			mata: knewnodes = J(`nsurvrows',1,st_matrix("knodes")):*((stime:-del_entry_time):/2) :+ ((stime:+del_entry_time):/2)
			mata: gknodes = asarray_create("real",2)
			mata: gknodes_deriv = asarray_create("real",2)
			if "`quick'"=="" {	
				mata: gknodes(nodesfinal,weightsfinal,$n_re,knewnodes,gknodes,gknodes_deriv, covariates, timecovariates)
			}
			else {
				mata: gknodes_quick(nodesfinal,weightsfinal,$n_re,knewnodes,gknodes,gknodes_deriv, covariates, timecovariates)			
			}
			mata: ngk = `gk'
		
			//reset knewnodes and stime to remove shift
			mata: stime = stime:-shift
			mata: del_entry_time = del_entry_time:-shift
			mata: knewnodes = J(`nsurvrows',1,st_matrix("knodes")):*((stime:-del_entry_time):/2) :+ ((stime:+del_entry_time):/2)
		}

		global rescale 0
		
		if "`nonadapt'"!="" {
			local nonadapt "_na"
			local ghtext "Gauss-Hermite quadrature"
		}
		else {
			local ghtext "Adaptive Gauss-Hermite quadrature"
		}
		
	/******************************************************************************************************************************************************************************************/
	/* MAXIMIZATION */

		di as txt "Fitting full model:"
		if "`nonadapt'"=="" {
			di 
			di in yellow "-> Conducting adaptive Gauss-Hermite quadrature"
		}

		//n di "`longequation' 	`alphaequation'	`survequation'"
		//n mat list `initmat'
		ml model d0 stjm11_d0_`smodel'`nonadapt'						///
							`longequation' 								///
							`alphaequation'								///
							`survequation'								///
							if `touse'									///
							, init(`initmat', copy) 					///
							`options' 									///
							waldtest(0) 								///					
							`searchopt'									///
							`collinopt'									///
							`constopts'									///	
							`nolog'										///
							maximize

	/*** NEED TO CREATE MATA CLEARUP PROGRAM ***/
							
		ereturn local predict stjm11_pred
		ereturn local title "Joint model estimates"
		ereturn local cmd stjm11
		ereturn local survmodel "`smodel'"
		ereturn local longdepvar "`lhs'"
		ereturn local survdepvar "_t _d"
		ereturn local rcsterms_base `rcsnames'
		ereturn local drcsterms_base `drcsnames'
		ereturn local long_varlist `rhs'
		ereturn local surv_varlist `survcov'
		ereturn local panel `panel'
		ereturn local Npat $Npat
		ereturn local intmethod "`ghtext'"
		ereturn scalar dev = -2*e(ll)
		ereturn scalar AIC = -2*e(ll) + 2 * e(rank) 
		ereturn scalar BIC = -2*e(ll) + ln(r(N)) * e(rank)

		/* Stuff for predictions */
		ereturn local fixed_time `ffracpoly'
		ereturn local random_time `rfracpoly'
		ereturn local current $current
		ereturn local deriv $deriv
		ereturn local intassoc $intassoc
		ereturn local timeassoc $timeassoc
		ereturn local sepassoc_timevar_index `sepassocpred'
		ereturn local sepassoc_timevar_pows `association'
		ereturn local npows $npows
		ereturn local rand_timevars `re_timevars'
		ereturn local n_re $n_re
		ereturn local df `df'
		ereturn local shift `shift'
		ereturn local fps_list `fps'
		ereturn local nassoc $n_alpha
		ereturn local ln_bhknots `ln_bhknots'
		ereturn local orthog `orthog'
		ereturn local gh `gh'
		ereturn local gk `gk'
		ereturn local timecovvars `covinterlist1'
		ereturn local timeinteraction `timeinteraction'
		ereturn local assoccovariates `assoccovariates'
		ereturn local nvcvparams = `nvcvparams'
		
		ereturn matrix vcv = vcv
		ereturn matrix fp_pows = fp_pows
		ereturn matrix rand_ind = rand_ind
		if "`smodel'"=="fpm" {
			ereturn matrix rmatrix = `R_bh'
		}
		if "`association'"!="" {
			ereturn matrix timeassoc_re_ind = timeassoc_re_ind
			ereturn matrix timeassoc_fixed_ind = timeassoc_fixed_ind
		}
		if "`keepcons'" == "" {
			constraint drop `dropconslist'
		}
		else {
			ereturn local sp_constraints `dropconslist'
		}		
		
		Replay, level(`level') smodel(`smodel') `showcons' `variance'
		
end

program Replay
		syntax [, Level(cilevel) Smodel(string) SHOWCons VARiance]
		Display, level(`level') smodel(`smodel') `showcons' `variance'
end

	***************ADD ABBREV TO VAR NAME DISPLAYS
	
	/******************************************************************************************************************************************************************************************/
	/* DISPLAY TABLE */
		
program Display
		syntax [, Level(cilevel) Smodel(string) Panel(string) SHOWCons VARiance]
		
		tempname ests vars ses lci uci pvals zvals results
		mat `ests' = e(b)'
		mat `vars' = e(V)
		local nparams = colsof(`vars')
		
		mat `ses' = J(`nparams',1,0)
		forvalues i=1/`nparams' {
			mat `ses'[`i',1] = sqrt(`vars'[`i',`i'])
		}
		
		tempname siglev
		scalar `siglev' = abs(invnormal((100-`level')/200)) 
		
		mat `lci' = `ests' - `siglev' * `ses'
		mat `uci' = `ests' + `siglev' * `ses'
		
		mat `zvals' = J(`nparams',1,0)
		mat `pvals' = J(`nparams',1,0)
		forvalues i=1/`nparams' {
			mat `zvals'[`i',1] = `ests'[`i',1]/`ses'[`i',1]
			mat `pvals'[`i',1] = (1-normal(abs(`zvals'[`i',1])))*2
		}		
		
		mat `results' = `ests',`ses',`zvals',`pvals',`lci',`uci'
		
		local k = length("`level'")
		
		if "`variance'"=="" {
			local sdtxt "sd"
			local corrtxt "corr"
		}
		else {
			local sdtxt "var"
			local corrtxt "cov"
		}
		
			di
		di as txt "Joint model estimates"											///
					as txt _col(50) "Number of obs.   = "							///
					as res _col(`=79-length("$nmeasures")') $nmeasures				
		di as txt "Panel variable: " as res abbrev("$panel",12) 					///
					as txt _col(50) "Number of panels = "							///
					as res _col(`=79-length("$Npat")') $Npat
		
			di
		di as txt "Log-likelihood = " as res e(ll)
			di
			
		/*Show constraints if asked */
		if "`showcons'"=="" {
			local nocnsreport nocnsreport
		}
			
			local labind = 1
			if $n_ftime>0 {
				forvalues i=1/$n_ftime {
					local `++labind'
				}
			}
			if $n_rtime>0 {
				forvalues i=1/$n_rtime {
					local `++labind'
				}
			}			
			
			/* time covariate interactions */
			if "`e(timecovvars)'"!="" {
				foreach var of varlist `e(timecovvars)' {																		
					local `++labind'
				}			
			}
			
			if "`e(long_varlist)'"!="" {
				foreach var of varlist `e(long_varlist)' {																			//fixed covariates in longitudinal model (rhs)
					local `++labind'
				}
			}
			
			ml di, neq(1) noheader showeqn nofootnote plus `nocnsreport'
			local `++labind'
			local labind = `labind' + `e(nvcvparams)' + 1
		
		/* Association parameters */
		di as res "Survival" as txt _col(14) "{c |}"
		
			forvalues i = 1/`e(nassoc)' {
				local lab : word `i' of $alpha_di_txt
				local p = 13 - length("`lab'")
				di as res _col(`p') "`lab'" as txt _col(14) "{c |}"
				if "`e(assoccovariates)'"!="" {
					foreach cov in `e(assoccovariates)' {
						forvalues j = 1/6 {
							local coef`j' = `results'[`labind',`j']
						}
						local cov = abbrev("`cov'",12)
						Di_param, label(`cov') coef1(`coef1') coef2(`coef2') coef3(`coef3') coef4(`coef4') coef5(`coef5') coef6(`coef6')
						local `++labind'		
					}
				}		
				_diparm alpha_`i', label("_cons")
				local `++labind'		
			}
		
		/* Survival parameters */
		if "`e(survmodel)'"=="fpm" {
		
					di as res _col(11) "xb" as txt _col(14) "{c |}"
					local scovs_names "`e(surv_varlist)' `e(rcsterms_base)'"
					foreach var of local scovs_names {																			//fixed covariates in survival model (survcov)
						forvalues i = 1/6 {
							local coef`i' = `results'[`labind',`i']
						}
						local var = abbrev("`var'",12)
						Di_param, label(`var') coef1(`coef1') coef2(`coef2') coef3(`coef3') coef4(`coef4') coef5(`coef5') coef6(`coef6')
						local `++labind'
					}
					_diparm xb, label("_cons")
					local `++labind'
			
		}
		else if "`e(survmodel)'"=="e" {
		
					di as res _col(4) "ln_lambda" as txt _col(14) "{c |}"
					local scovs_names "`e(surv_varlist)'"		
					foreach var of local scovs_names {																			//fixed covariates in survival model (survcov)
						forvalues i = 1/6 {
							local coef`i' = `results'[`labind',`i']
						}
						local var = abbrev("`var'",12)
						Di_param, label(`var') coef1(`coef1') coef2(`coef2') coef3(`coef3') coef4(`coef4') coef5(`coef5') coef6(`coef6')
						local `++labind'
					}
					_diparm ln_lambda, label("_cons")		/*ln_lambda baseline */
					local `++labind'	

		}
		else if "`e(survmodel)'"=="w" {
		
					di as res _col(4) "ln_lambda" as txt _col(14) "{c |}"
					local scovs_names "`e(surv_varlist)'"		
					foreach var of local scovs_names {																			//fixed covariates in survival model (survcov)
						forvalues i = 1/6 {
							local coef`i' = `results'[`labind',`i']
						}
						local var = abbrev("`var'",12)
						Di_param, label(`var') coef1(`coef1') coef2(`coef2') coef3(`coef3') coef4(`coef4') coef5(`coef5') coef6(`coef6')
						local `++labind'
					}
					_diparm ln_lambda, label("_cons")		/*ln_lambda baseline */
					local `++labind'	
					local p = 13 - length("ln_gamma")
					di as res _col(`p') "ln_gamma" as txt _col(14) "{c |}"
					_diparm ln_gamma, label("_cons")
					local `++labind'

		}
		else if "`e(survmodel)'"=="g" {
		
					di as res _col(4) "ln_lambda" as txt _col(14) "{c |}"
					local scovs_names "`e(surv_varlist)'"		
					foreach var of local scovs_names {																			//fixed covariates in survival model (survcov)
						forvalues i = 1/6 {
							local coef`i' = `results'[`labind',`i']
						}
						local var = abbrev("`var'",12)
						Di_param, label(`var') coef1(`coef1') coef2(`coef2') coef3(`coef3') coef4(`coef4') coef5(`coef5') coef6(`coef6')
						local `++labind'
					}
					_diparm ln_lambda, label("_cons")		/*ln_lambda baseline */
					local `++labind'	
					local p = 13 - length("gamma")
					di as res _col(`p') "gamma" as txt _col(14) "{c |}"
					_diparm gamma, label("_cons")
					local `++labind'		
		
		}
		
			di as txt "{hline 13}{c BT}{hline 64}
		
		/* Random effects table title*/
			di 
			di as txt "{hline 29}{c TT}{hline 48}
			di as txt _col(3) "Random effects Parameters" _col(30) "{c |}" _col(34) "Estimate" _col(45) "Std. Err." _col(`=61-`k'') ///
			`"[`=strsubdp("`level'")'% Conf. Interval]"'
			di as txt "{hline 29}{c +}{hline 48}
			if "$n_re"!="1"{
				local labtextvcv $labtextvcv
			}
			else local labtextvcv "Independent"
			di as res abbrev("$panel",12) as txt ": `labtextvcv'" _col(30) "{c |}"

		/* Std. dev./Variances of random effects */
			if "`labtextvcv'"=="Independent" | "`labtextvcv'"=="Unstructured" {
				local test = 1
				forvalues i=1/$n_re {
					local lab : word `test' of $retimelabelnames2
					Var_display, param("lns_`i'") label("`sdtxt'(`lab')") `variance'
					local `++test'
				}
			}
			else {
				local name = abbrev(trim("$retimelabelnames2"),19)
				local n2 = length("$retimelabelnames2")
				if `n2'>19 {
					local n1 "(1)"
				}
				Var_display, param("lns_1") label("`sdtxt'(`name')`n1'") `variance'
			}
			
		/* Corrs/Covariances of random effects */
			if "`labtextvcv'"=="Unstructured" & $n_re>1 {
				local firstindex = 1
				local txtindex = 1
				while (`firstindex'<$n_re) {
					local test = `firstindex' + 1
					local test2 = 1
					forvalues i=`test'/$n_re {
						local ind2 = `i'-1
						local lab1 : word `txtindex' of $retimelabelnames2
						local lab2 : word `=`txtindex'+`test2'' of $retimelabelnames2
						if "`variance'"=="" {
							Covar_display, param1("art_`firstindex'_`test'") label("`corrtxt'(`lab1',`lab2')") `variance'
						}
						else {
							Covar_display, param1("art_`firstindex'_`test'") param2("lns_`firstindex'") param3("lns_`test'") label("`corrtxt'(`lab1',`lab2')") `variance'
						}
						local `++test'
						local `++test2'
					}
					local `++firstindex'
					local `++txtindex'
				}
			}
			else if "`labtextvcv'"=="Exchangeable" & $n_re>1 {
				local name = abbrev(trim("$retimelabelnames2"),19)
				local n2 = length("$retimelabelnames2")
				if `n2'>19 {
					local n1 "(1)"
				}
				if "`variance'"=="" {
					Covar_display, param1("art_1_1") label("`corrtxt'(`name')`n1'") `variance'
				}
				else {
					Covar_display, param1("art_1_1") param2("lns_1") param3("lns_1") label("`corrtxt'(`name')`n1'") `variance'
				}
			}
			
		/* Residual variance */	
			di as txt "{hline 29}{c +}{hline 48}					
			Var_display, param(lns_e) label("`sdtxt'(Residual)") `variance'
			di as txt "{hline 29}{c BT}{hline 48}					
		
		local l = length(trim("$retimelabelnames2"))	
		if `l'>19 {
			di in green "(1) $retimelabelnames2"
		}
		
		/* Summary text */
		
		if "`e(survmodel)'"=="w" {
			local smodeltxt "Weibull proportional hazards model"
		}
		else if "`e(survmodel)'"=="e" {
			local smodeltxt "Exponential proportional hazards model"
		}
		else if "`e(survmodel)'"=="g" {
			local smodeltxt "Gompertz proportional hazards model"
		}
		else {
			local smodeltxt "Flexible parametric model"
		}
		
		di ""
		di in green " Longitudinal submodel: Linear mixed effects model"
		di in green "     Survival submodel: `smodeltxt'"
		di in green "    Integration method: `e(intmethod)' using `e(gh)' nodes"
	if "`e(survmodel)'"!="fpm" {
		di in green "     Cumulative hazard: Gauss-Kronrod quadrature using `e(gk)' nodes"
	}
	
end


program Var_display
	syntax, PARAM(string) LABEL(string) [VARiance]
	if "`variance'"=="" {
		_diparm `param', exp notab
	}
	else {
		_diparm `param', f(exp(2*@)) d(2*exp(2*@)) notab
	}
	Di_re_param, label("`label'")
end

program Covar_display
	syntax, param1(string) [PARAM2(string) PARAM3(string) LABEL(string) VARiance]
	if "`variance'"=="" {
		_diparm `param1', tanh notab
	}
	else {
		_diparm `param1' `param2' `param3', f(tanh(@1)*exp(@2)*exp(@3)) d((1-(tanh(@1)^2))*exp(@2+@3) tanh(@1)*exp(@2+@3) tanh(@1)*exp(@2+@3)) notab
	}
	Di_re_param, label("`label'")
end

program Di_re_param
	syntax, LABEL(string)
	local p = 29 - length("`label'")
	di as txt _col(`p') "`label'" _col(30) "{c |}" ///
			as res _col(33) %9.0g r(est) ///
			as res _col(44) %9.0g r(se)  ///
			as res _col(58) %9.0g cond(missing(r(se)),.,r(lb))  ///
			as res _col(70) %9.0g cond(missing(r(se)),.,r(ub))
end

program Di_param
	syntax, LABEL(string) COEF1(string) COEF2(string) COEF3(string) COEF4(string) COEF5(string) COEF6(string)
	local p = 13 - length("`label'")
	di as txt _col(`p') "`label'" _col(14) "{c |}" 	///
				as res _col(17) %9.0g `coef1' 		///
				as res _col(28) %9.0g `coef2'		///
				as res _col(38) %8.2f `coef3'		///
				as res _col(49) %4.3f `coef4'		///
				as res _col(58) %9.0g `coef5'		///
				as res _col(70) %9.0g `coef6'	
end

program gausskronrod15

	mat knodes 		= J(1,15,.)
	mat kweights 	= J(1,15,.)

	local i=1
	foreach n of numlist 0.991455371120813 -0.991455371120813 0.949107912342759 -0.949107912342759 0.864864423359769 -0.864864423359769 0.741531185599394 -0.741531185599394 0.586087235467691 -0.586087235467691 0.405845151377397 -0.405845151377397 0.207784955007898 -0.207784955007898 0 {
		mat knodes[1,`i'] = `n'
		local `++i'
	}
	local i=1
	foreach n of numlist 0.022935322010529 0.022935322010529 0.063092092629979 0.063092092629979 0.104790010322250 0.104790010322250 0.140653259715525 0.140653259715525 0.169004726639267 0.169004726639267 0.190350578064785 0.190350578064785 0.204432940075298 0.204432940075298 0.209482141084728  {
		mat kweights[1,`i'] = `n'
		local `++i'
	}

end

program gausskronrod7

	mat knodes 		= J(1,7,.)
	mat kweights 	= J(1,7,.)

	local i=1
	foreach n of numlist 0.949107912342759 -0.949107912342759 0.741531185599394 -0.741531185599394 0.405845151377397 -0.405845151377397 0 {
		mat knodes[1,`i'] = `n'
		local `++i'
	}
	local i=1
	foreach n of numlist 0.129484966168870 0.129484966168870 0.279705391489277 0.279705391489277 0.381830050505119 0.381830050505119 0.417959183673469  {
		mat kweights[1,`i'] = `n'
		local `++i'
	}

end

/* Mata program to calculate nodes and weights matrices */
mata:
mata set matastrict off
	void nodes_weights(										///
							real scalar nres,				///
							numeric scalar N,				///
							numeric matrix nodes,			///
							numeric matrix weights,			///
							numeric matrix nodesfinal,		///
							numeric matrix weightsfinal,	///
							numeric matrix basis2)
	{	

		nres1 = nres:-1
		repind = 1																	/* Index for multiplying node sequences */

		/* Node and weight sequences for random effects */
		if (nres>1) {
			for (i=1; i<=nres1; i++) { 
				reps = (cols(nodes):^(nres:-i))										/* no. of times to repeat each node */
				noderepeat = J(reps,1,nodes[i,(1::cols(nodes))])'					/* replicate each ith row of nodes, "reps" times, so now have "reps" rows -> then transpose */
				weightrepeat = J(reps,1,weights[i,(1::cols(nodes))])'
				rep1 = noderepeat[1,.]
				rep2 = weightrepeat[1,.]
				for (j=2; j<=cols(nodes); j++) {
					rep1=rep1,noderepeat[j,.]
					rep2=rep2,weightrepeat[j,.]
				}
				nodesfinal[i,.] = J(1,repind,rep1)
				basis2[i,.] = J(1,repind,rep2)
				repind = repind:*cols(nodes)
			}
		}
		nodesfinal[nres,.] = J(1,repind,nodes[nres,.])								/* final nodes sequences */
		basis2[nres,.] = J(1,repind,weights[nres,.])							/* final weights sequences */

		if (nres>1){
			weightsfinal = J(1,1,basis2[1,.])
			for (i=2; i<=nres; i++) {
				weightsfinal = weightsfinal:*J(1,1,basis2[i,.])
			}
		}
		else {
			weightsfinal = J(1,1,basis2[1,.])
		}				

	}
end

mata:
mata set matastrict off
	void adapt(string scalar smodel, transmorphic aghnodes, transmorphic aghweights,numeric matrix mu_i,numeric matrix tau_i,numeric matrix nodesfinal, ///
	numeric matrix weightsfinal,real scalar nres)
{
		
		decomp_i = J(nres,nres,0) 		//cholesky(st_matrix("vcv"))
		id = st_data(.,st_local("_tempid"),st_local("touse"))	
		info = panelsetup(id, 1)	
		nmeas = info[.,2]:-info[.,1] :+ 1

		fp_pows = st_matrix("fp_pows")
		nres1 = nres:+1
		npows = cols(fp_pows)
		npows1 = npows :+1
		
		for (i=1; i<=rows(info); i++) {
			
			/* adapt GH nodes and weights */
			
				shift = panelsubmatrix(mu_i,i,info)[1,.]'
				scale = panelsubmatrix(tau_i,i,info)[1,.]	
					
				for(j=1;j<=nres;j++){
					decomp_i[j,j] = scale[1,j]
				}		
				
				nodes_i = shift :+ decomp_i * (sqrt(2):*nodesfinal)
				
				newweights = (2):^(nres:/2):*sqrt(det(decomp_i*(decomp_i'))):*exp(quadcolsum(nodesfinal:^2)) :* weightsfinal
				
				asarray(aghnodes,i,nodes_i)
				asarray(aghweights,i,newweights)
				
		}
		
}
end

mata:
mata set matastrict off
	void gknodes(numeric matrix nodesfinal, ///
	numeric matrix weightsfinal,real scalar nres,|	///
	numeric matrix knewnodes, transmorphic gknodes, ///
	transmorphic gknodes_deriv,
	numeric matrix covariates, numeric matrix timecovariates)
{
		
		id = st_data(.,st_local("_tempid"),st_local("touse"))	
		info = panelsetup(id, 1)	
		nmeas = info[.,2]:-info[.,1] :+ 1
		fp_pows = st_matrix("fp_pows")
		nres1 = nres:+1
		npows = cols(fp_pows)
		npows1 = npows :+1
		
		for (i=1; i<=rows(info); i++) {
				
			knewnodes_i = panelsubmatrix(knewnodes,i,info)
			
			if (st_global("timeinterac")=="yes") {
				timecovs_i = panelsubmatrix(timecovariates,i,info)
			}
			if (rows(covariates)>1) {
				cov_i = panelsubmatrix(covariates,i,info)
			}
			
			for (j=1; j<=nmeas[i,1];j++) {
				
				if (st_global("current")=="yes" | st_global("intassoc")=="yes" | st_global("timeassoc")=="yes") {
					dm_knewnodes = J(npows,cols(knewnodes),.)
					for(k=1;k<=npows;k++){
						if (fp_pows[1,k]!=0) {
							dm_knewnodes[k,.] = knewnodes_i[j,]:^fp_pows[1,k] 
						}
						else {
							dm_knewnodes[k,.] = log(knewnodes_i[j,])
						}
					}	
					
					/* time covariate interactions */
					if (st_global("timeinterac")=="yes") {
						temp = dm_knewnodes
						ntimecovinterac = st_numscalar("ntimecovinterac")
						for(f=1;f<=ntimecovinterac;f++){
							interac = timecovs_i[j,f]:*temp
							dm_knewnodes = dm_knewnodes\interac		
						}
					}
					
					/* covariates */
					if (rows(covariates)>1) {
						for(d=1;d<=cols(covariates);d++){
							dm_knewnodes = dm_knewnodes\J(1,cols(knewnodes),cov_i[j,d])
						}						
					}
					
					dm_knewnodes = dm_knewnodes\J(1,cols(knewnodes),1)
					asarray(gknodes,(i,j),dm_knewnodes')
				}
				
				if (st_global("deriv")=="yes") {
					dm_knewnodes_deriv = J(npows,cols(knewnodes),0)
					for(k=1;k<=npows;k++){
						if (fp_pows[1,k]!=0) {
							dm_knewnodes_deriv[k,.] = fp_pows[1,k] :* knewnodes_i[j,.]:^(fp_pows[1,k] :-1)
						}
						else {
							dm_knewnodes_deriv[k,.] = 1:/knewnodes_i[j,.]
						}
					}	
					
					/* time covariate interactions */
					if (st_global("timeinterac")=="yes") {
						temp = dm_knewnodes_deriv
						ntimecovinterac = st_numscalar("ntimecovinterac")
						for(c=1;c<=ntimecovinterac;c++){
							test = temp :* timecovs_i[j,c]
							dm_knewnodes_deriv = dm_knewnodes_deriv\test
						}
					}
					
					if (rows(covariates)>1) {
						for(d=1;d<=cols(covariates);d++){
							dm_knewnodes_deriv = dm_knewnodes_deriv\J(1,cols(knewnodes),0)
						}						
					}
				
					dm_knewnodes_deriv = dm_knewnodes_deriv\J(1,cols(knewnodes),0)
					asarray(gknodes_deriv,(i,j),dm_knewnodes_deriv')
				}
				
			}
		
		}
		
}
end

mata:
mata set matastrict off
	void gknodes_quick(numeric matrix nodesfinal, ///
	numeric matrix weightsfinal,real scalar nres,|	///
	numeric matrix knewnodes, transmorphic gknodes, ///
	transmorphic gknodes_deriv,
	numeric matrix covariates, numeric matrix timecovariates,string scalar quick)
{
		
		id = st_data(.,st_local("_tempid"),st_local("newsurvtouse"))	
		npat = rows(id)
		fp_pows = st_matrix("fp_pows")
		nres1 = nres:+1
		npows = cols(fp_pows)
		npows1 = npows :+1
		
		for (i=1; i<=npat; i++) {
			
				
				if (st_global("current")=="yes" | st_global("intassoc")=="yes" | st_global("timeassoc")=="yes") {
					dm_knewnodes = J(npows,cols(knewnodes),.)
					for(k=1;k<=npows;k++){
						if (fp_pows[1,k]!=0) {
							dm_knewnodes[k,.] = knewnodes[i,.]:^fp_pows[1,k] 
						}
						else {
							dm_knewnodes[k,.] = log(knewnodes[i,])
						}
					}	
					
					/* time covariate interactions */
					if (st_global("timeinterac")=="yes") {
						temp = dm_knewnodes
						ntimecovinterac = st_numscalar("ntimecovinterac")
						for(f=1;f<=ntimecovinterac;f++){
							interac = timecovariates[i,f]:*temp
							dm_knewnodes = dm_knewnodes\interac		
						}
					}
					
					/* covariates */
					if (rows(covariates)>1) {
						for(d=1;d<=cols(covariates);d++){
							dm_knewnodes = dm_knewnodes\J(1,cols(knewnodes),covariates[i,d])
						}						
					}
					
					dm_knewnodes = dm_knewnodes\J(1,cols(knewnodes),1)
					asarray(gknodes,(i,1),dm_knewnodes')
				}
				
				if (st_global("deriv")=="yes") {
					dm_knewnodes_deriv = J(npows,cols(knewnodes),0)
					for(k=1;k<=npows;k++){
						if (fp_pows[1,k]!=0) {
							dm_knewnodes_deriv[k,.] = fp_pows[1,k] :* knewnodes[i,.]:^(fp_pows[1,k] :-1)
						}
						else {
							dm_knewnodes_deriv[k,.] = 1:/knewnodes[i,.]
						}
					}	
					
					/* time covariate interactions */
					if (st_global("timeinterac")=="yes") {
						temp = dm_knewnodes_deriv
						ntimecovinterac = st_numscalar("ntimecovinterac")
						for(c=1;c<=ntimecovinterac;c++){
							test = temp :* timecovariates[i,c]
							dm_knewnodes_deriv = dm_knewnodes_deriv\test
						}
					}
					
					if (rows(covariates)>1) {
						for(d=1;d<=cols(covariates);d++){
							dm_knewnodes_deriv = dm_knewnodes_deriv\J(1,cols(knewnodes),0)
						}						
					}
				
					dm_knewnodes_deriv = dm_knewnodes_deriv\J(1,cols(knewnodes),0)
					asarray(gknodes_deriv,(i,1),dm_knewnodes_deriv')
				}

		}
		
}
end




/* Thanks to G. R. Frechette for permission to include ghquadm (taken from rfprobit update)*/

program define ghquadm
* stolen from gllamm6 who stole it from rfprobit (Bill Sribney)
	version 4.0

	parse "`*'", parse(" ")
	local n = `1'
	if `n' + 2 > _N  {
		di in red  /*
		*/ "`n' + 2 observations needed to compute quadrature points"
		exit 2001
	}

	tempname x w xx ww a b
	local i 1
	local m = int((`n' + 1)/2)
	matrix x = J(1,`m',0)
	matrix w = x
	while `i' <= `m' {
		if `i' == 1 {
			scalar `xx' = sqrt(2*`n'+1)-1.85575*(2*`n'+1)^(-1/6)
		}
		else if `i' == 2 { scalar `xx' = `xx'-1.14*`n'^0.426/`xx' }
		else if `i' == 3 { scalar `xx' = 1.86*`xx'-0.86*x[1,1] }
		else if `i' == 4 { scalar `xx' = 1.91*`xx'-0.91*x[1,2] }
		else { 
			local im2 = `i' -2
			scalar `xx' = 2*`xx'-x[1,`im2']
		}
		hermite `n' `xx' `ww'
		matrix x[1,`i'] = `xx'
		matrix w[1,`i'] = `ww'
		local i = `i' + 1
	}
	if mod(`n', 2) == 1 { matrix x[1,`m'] = 0}
/* start in tails */
	matrix `b' = (1,1)
	matrix w = w#`b'
	matrix w = w[1,1..`n']
	matrix `b' = (1,-1)
	matrix x = x#`b'
	matrix x = x[1,1..`n']
/* other alternative (left to right) */
/*
	above: matrix x = J(1,`n',0)
	while ( `i'<=`n'){
		matrix x[1, `i'] = -x[1, `n'+1-`i']
		matrix w[1, `i'] = w[1, `n'+1-`i']
		local i = `i' + 1
	}
*/
	matrix `2' = x
	matrix `3' = w
end


program define hermite  /* integer n, scalar x, scalar w */
* stolen from gllamm6 who stole it from rfprobit (Bill Sribney)
	version 4.0
	local n "`1'"
	local x "`2'"
	local w "`3'"
	local last = `n' + 2
	tempname i p
	matrix `p' = J(1,`last',0)
	scalar `i' = 1
	while `i' <= 10 {
		matrix `p'[1,1]=0
		matrix `p'[1,2] = _pi^(-0.25)
		local k = 3
		while `k'<=`last'{
			matrix `p'[1,`k'] = `x'*sqrt(2/(`k'-2))*`p'[1,`k'-1] /*
			*/	- sqrt((`k'-3)/(`k'-2))*`p'[1,`k'-2]
			local k = `k' + 1
		}
		scalar `w' = sqrt(2*`n')*`p'[1,`last'-1]
		scalar `x' = `x' - `p'[1,`last']/`w'
		if abs(`p'[1,`last']/`w') < 3e-14 {
			scalar `w' = 2/(`w'*`w')
			exit
		}
		scalar `i' = `i' + 1
	}
	di in red "hermite did not converge"
	exit 499
end

