*! version 2.1.0 09oct2013 MJC

/*
History
MJC 09oct2013: version 2.1.0 - tvc() and texp() added for time-dependent effects in hazard scale PH survival submodels
							 - rcs survival submodel added (splines on log hazard scale)
							 - noshowadapt changed to showadapt, adaptive iterations now not shown by default
							 - bug in predictions missed time interactions in undocumented deriv predictions
							 - bug in exponential submodel when using adaptive quadrature (quick) now fixed
MJC 14jan2013: version 2.0.2 - Gauss-Legendre quadrature added for hazard scale models
							 - assoccovariates() no longer allowed in intassoc and association() linear predictors
							 - knots of rrcs() on _t0 were not passed to _t, now fixed
							 - nolog didn't suppress adaptive log, now fixed
							 - e(BIC) was incorrect, now fixed
							 - atol() changed from 1E-05 to 1E-08
							 - nocoefficient added for intassoc and assoc()
							 - frcs() and rrcs() now allowed with survmodel(fpm)
							 - fixed bug in hazard xb predictions with survm(ww/weibexp), formula was incorrect
MJC 15aug2012: version 2.0.1 - fixed erroneous sort causing fulldata to be invoked when unnecessary
MJC 11aug2012: version 2.0.0 - Adaptive quadrature algorithms improved, now use a convergence scheme
							 - Adaptive iterations shown by default, option noshowadapt suppresses display of log-likelihood, default adaptit() now 5
							 - Added ww/we survival models
							 - ffracpoly()/rfracpoly() renamed to ffp()/rfp()
							 - atol() option added which declares the tolerance used under the adaptive quadrature sub-iterations, default is 1.0E-5
							 - stjm_dmvnorm() Mata function added for PDF of node contributions in adaptive lnl functions
							 - Longitudinal splines have been added, through options frcs() and rrcs()
							 - noxtem option added (default -xtmixed- fit uses emonly option for speed)
MJC 02feb2012: version 1.3.0 - Implemented adaptive GH quadrature which is now the default. timeinteraction, assoccovariates options added.
MJC 20oct2011: version 1.2.0 - Added Gompertz and Exponential survival submodels. Added covariance options consistent with xtmixed.
MJC 14oct2011: version 1.1.0 - Weibull survival submodel now allowed. Delayed entry re-written, now allowing time-varying covariates in survival submodel.							 
							 - Fixed error when rfracp or ffracp was 0 with min(_t0) = 0
MJC 10oct2011: version 1.0.0
*/

program stjm, eclass sortpreserve properties(st)
	version 12.1
	if replay() {
		if (`"`e(cmd)'"' !="stjm") error 301
		Replay `0'
	}
	else {
		Estimate `0'
		syntax [anything] [if] [in] [, GETBLUPS(string) *]
		if "`getblups'"=="" ereturn local cmdline `"stjm `0'"'
	}
end

program Estimate, eclass
		syntax varlist(min=1 numeric) 	[if] [in] ,											///
																							///
													Panel(varname) 							///			-Patient identifier-
													SURVModel(string)						///			-Survival submodel choice-
																							///
													[										///
													/* Longitudinal model options */		///
														FFP(numlist max=5 asc)				///			-Fixed time power variables-
														FRCS(string)						///			-Fixed splines of time-
														RFP(numlist max=5 asc)				///			-Random time power variables-
														RRCS(string)						///			-Random splines of time-
														TIMEINTERACtion(varlist numeric)	///			-Covariates to interact with fixed time variables-
														COVariance(string)					///			-Covariance structure-
																							///
													/* Survival model options */			///
														SURVCov(varlist numeric)			///			-Covariates to include in the survival submodel-
														TVC(varlist numeric)				///			-Time-dependent effects
														TEXP(string)						///			-Multiplier for time-varying covariates; default is texp(_t)-
														DF(string) 		 					///			-Degrees of freedom for FPM-
														KNOTS(numlist) 						///			-Knot locations for baseline hazard function-
														NOORTHog							///			-Do not orthoganalise splines-
																							///
													/* Association options */				///
														ASSOCCOVariates(varlist numeric)	///			-Adjust association parameters by covariates-
														NOCurrent							///			-Assciation not based on current value-
														DERIVASSOCiation					///			-Association based on derivatives-
														INTASSOCiation						///			-Association based on random intercept-
														ASSOCiation(numlist max=5)			///			-Association based on random slope/etc.-
														NOCOEFficient						///			-Do not include fixed component in intassoc or assoc()-
																							///
													/* Results display options */			///
														SHOWINITial							///			-Show output from fitting initial value models-
														VARiance							///			-Display variances-covariances in random effects table-
														SHOWCons							///			-Show spline constraints-
														KEEPCons							///			-Do not drop constraints used in ml routine-
														Level(cilevel)						///			-Statistical significance level-
														EFORM								///			-Exponentiate survival parameters-
																							///
													/* Maximisation options	*/				///
														GH(string) 							///			-Number of Gauss-Hermite nodes-
														GK(string)							///			-Number of Gauss-Kronrod nodes-
														GL(string)							///			-Number of Gauss-Legendre nodes-
														ADAPTIT(string)						///			-Number of adaptive iterations to do-
														SHOWAdapt							///			-Display adaptive log-likelihood-
														ATOL(real 1E-08)					///			-Tolerance for the log-likelihood under adaptive iterations-
														NONADAPT							///			-Use non-adaptive quadrature-
														FULLdata							///			-Use all rows of survival data in estimation-
														NULLAssoc							///			-Initial values for association parameters set to zero-
														NOXTEM								///			-Option for xtmixed initial values-
														NOLOG								///			-Suppress log-likelihood iteration log-
														INITMATSURV(string)					///			
														SKIP								///
														* 									///			-ML options-
																							///
													/* Undocumented for use by predict */	///
														GETBLUPS(string)					///			-UNDOCUMENTED-
														REISE								///			-UNDOCUMENTED-
														POSTTOUSE(varname)					///			-UNDOCUMENTED-
														GETBLUPSGH(int 30)					///			-UNDOCUMENTED-
																							///
														condsurv(string)					///
														LEAVE								///
													] 
		
	//===================================================================================================================================================//
	// Error checks //
		
		local l = length("`survmodel'")
		if substr("exponential",1,max(1,`l'))=="`survmodel'" local smodel "e"
		else if substr("weibull",1,max(1,`l'))=="`survmodel'" local smodel "w"
		else if substr("gompertz",1,max(1,`l'))=="`survmodel'" local smodel "g"
		else if "fpm" == "`survmodel'" local smodel "fpm"
		else if "rcs" == "`survmodel'" local smodel "rcs"
		else if ("ww"=="`survmodel'" | substr("weibweib",1,max(5,`l'))=="`survmodel'") local smodel "ww"
		else if substr("weibexp",1,max(5,`l'))=="`survmodel'" local smodel "we"
		else {
			di as error "Unknown survival submodel"
			exit 198
		}
		local aft = 0
		
		if "`covariance'"=="" {
			local cov "unstr"
			local covtype "Unstructured"
		}
		else {
			local l = length("`covariance'")
			if substr("independent",1,max(3,`l')) == "`covariance'" {
				local cov "ind"
				local covtype "Independent"
			}
			else if substr("exchangeable",1,max(2,`l')) == "`covariance'" {
				local cov "exch"
				local covtype "Exchangeable"
			}
			else if substr("identity",1,max(2,`l')) == "`covariance'" {
				local cov "iden"
				local covtype "Identity"
			}
			else if substr("unstructured",1,max(2,`l')) == "`covariance'" {
				local cov "unstr"
				local covtype "Unstructured"
			}
			else {
				di as error "Unknown variance-covariance structure"
				exit 198
			}
		}
				
		if "`weight'" != "" {
			display as err "weights not allowed"
			exit 198
		}
		local wt: char _dta[st_w]       
		if "`wt'" != "" {
			display as err "weights not allowed"
			exit 198
		}
		
		fvexpand `varlist' `survcov' `timeinteraction' `assoccovariates'
		if "`r(fvops)'" != "" {
			display as error "Factor variables not allowed. Create your own dummy variables."
			exit 198
		}
		
		if "`smodel'"=="fpm" {
			capture which stpm2
			if _rc >0 {
				display in yellow "You need to install the command stpm2. This can be installed using,"
				display in yellow ". {stata ssc install stpm2}"
				exit 198
			}
		}
		
		if "`smodel'"=="fpm" | "`smodel'"=="rcs" | "frcs"!="" | "`rrcs'"!="" {
			capture which rcsgen
			if _rc >0 {
				display in yellow "You need to install the command rcsgen. This can be installed using,"
				display in yellow ". {stata ssc install rcsgen}"
				exit 198
			}		
		}
		
		if "`smodel'"=="rcs" {
			capture which stgenreg
			if _rc>0 {
				display in yellow "You need to install the command stgenreg. This can be installed using,"
				display in yellow ". {stata ssc install stgenreg}"
				exit 198
			}		
			if "`knots'"!="" {
				di as error "knots() not allowed with survmodel(rcs), please use df()"
				exit 198			
			}
		}
		
		if "`smodel'"=="ww" | "`smodel'"=="ww" {
			capture which stmix
			if _rc>0 {
				display in yellow "You need to install the command stmix. This can be installed using,"
				display in yellow ". {stata ssc install stmix}"
				exit 198
			}		
		}	
		
		if ("`smodel'"!="fpm" & "`smodel'"!="rcs") & ("`df'"!="" | "`knots'"!="") {
			di as error "Can only specify df()/knots() with survmodel(fpm) or survmodel(rcs)"
			exit 198
		}
		
		if ("`smodel'"!="fpm" & "`smodel'"!="rcs") & "`noorthog'"!="" {
			di as error "Option noorthog only valid with survmodel(fpm) or survmodel(rcs)"
			exit 198
		}
		
		if "`rfp'"=="" & "`ffp'"=="" & "`frcs'"=="" {
			di as error "One of rfp()/ffp()/frcs() must be specified"
			exit 198
		}		
				
		if "`rrcs'"!="" & "`derivassociation'"!="" {
			di as error "derivassociation() and rrcs() not currently allowed"
			exit 198
		}
		
		if ("`nocurrent'"!="" & "`intassociation'"=="" & "`association'"=="" & "`derivassociation'"=="") {
			di as error "No association between submodels has been specified"
			exit 198
		}
		
		if ("`derivassociation'"!="" & "`rfp'"=="" & "`rrcs'"=="") {
			di as error "Random time variables must be specified for derivative association."
			exit 198
		}
		
		if ("`association'"!="" & "`rfp'"=="") {
			di as error "Random time variables must be specified for separate association."
			exit 198
		}
		
		if ("`association'"!="" & "`rrcs'"!="") {
			di as error "rrcs() cannot be used with association()"
			exit 198
		}
		
		if "`ffp'"!="" | "`rfp'"!="" {
			foreach fe of numlist `ffp' `rfp' {
				if (`fe'!=-5 & `fe'!=-4 & `fe'!=-3 & `fe'!=-2 & `fe'!=-1 & `fe'!=-0.5 & `fe'!=0 & `fe'!=0.5 & `fe'!=1 & `fe'!=2 & `fe'!=3 & `fe'!=4 & `fe'!=5) {
					di as error "ffp()/rfp() powers must be one of -5, -4, -3, -2, -1, -.5, 0, .5, 1, 2, 3, 4, 5"
					exit 198
				}
			}
		}
		
		local dumcheck = 0
		if "`rfp'"!="" & "`ffp'"!="" {
			foreach re of numlist `rfp' {
				foreach fe of numlist `ffp' {
					if "`re'"=="`fe'" {
						local dumcheck = 1
					}
				}
			}
		}
		if `dumcheck' {
			di as error "You cannot specify both a fixed and random fracpoly with the same power"
			exit 198
		}
		
		if ("`association'"!="" & "`rfp'"!="") {
			local dumcheck   = 0
			local finalcheck = 0
			foreach a of numlist `association' {
				foreach b of numlist `rfp' {
					if `a'==`b' {
						local dumcheck = 1
					}
				}
				if !`dumcheck' {
					local finalcheck = 1
				}
			}
			if `finalcheck' {
				di as error "Elements of association must be in rfp()"
				exit 198
			}			
		}

		if "`showcons'"!="" & "`smodel'"!="fpm" {
			di as error "showcons only allowed when survmodel = fpm"
			exit 198
		}		

		if "`gk'"!="" & "`gl'"!="" {
			di as error "gk() and gl() cannot both be specified"
			exit 198
		}
		
		if "`gk'"!="" {
			if "`gk'"!="15" & "`gk'"!="7" {
				di as error "gk() must be 7 or 15"
				exit 198
			}
		}
		
		if "`gl'"!="" {
			cap confirm integer number `gl'
			if _rc {
				di as error "gl() must be a positive integer >= 5"
				exit 198
			}		
			if `gl'<5 {
				di as error "gl() must be a positive integer >= 5"
				exit 198
			}
		}
		
		if ("`smodel'"=="fpm" | "`smodel'"=="rcs") & "`df'"=="" & "`knots'"=="" {
			di as error "One of df() or knots() must be specified"
			exit 198
		}
		
		if ("`smodel'"=="fpm" | "`smodel'"=="rcs" ) {
			if "`df'"!="" & "`knots'"!="" {
				di as error "Only one of df() and knots() can be specified"
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
		else if "`nonadapt'"=="" local adaptit 5
		
		if "`gh'"!="" {
			cap confirm integer number `gh'
			if _rc>0 {
				di as error "gh() must be an integer"
				exit 198
			}
			if `gh'<2 {
				di as error "gh() must be > 1"
				exit 198
			}
		}
		else {
			if "`nonadapt'"=="" local gh 5
			else local gh 15
		}
		
		if ("`ffp'"!="" | "`rfp'"!="") & ("`rrcs'"!="" | "`frcs'"!="") {
			di as error "ffp()/rfp() cannot be specified with frcs()/rrcs()"
			exit 198
		}
				
		if "`nonadapt'"!="" & "`adaptit'"!="" {
			di as error "Cannot specify adaptit() with nonadapt"
			exit 198
		}
		
        if `"`texp'"' != "" & "`tvc'" == "" {
			di as err "texp() only allowed with tvc()"
			exit 198
        }
		
		if "`tvc'"!="" & (`aft' | "`smodel'"=="fpm" | "`smodel'"=="rcs") {
			di as error "tvc() only allowed with hazard scale PH survival models (except survmodel(rcs))"
			exit 198
		}
		
		if `aft' & ("`gk'"!="" | "`gl'"!="") {
			di as error "gk()/gl() not allowed with an AFT survival sub model"
			error 198
		}
		
	//===================================================================================================================================================//
	// Preliminaries //
		
		if ("`getblups'"!="") local gbquietly quietly
		
		if "`nonadapt'"=="" {
			local dprolog derivprolog(stjm_prolog())
			local quadtype adapt
			local ghtext "Adaptive Gauss-Hermite quadrature"
		}
		else {
			local nonadapt _na
			local quadtype nonadapt
			local ghtext "Gauss-Hermite quadrature"
		}

		if "`showinitial'"!="" local noisily noisily
		if ("`smodel'"!="fpm" & !`aft' & "`gk'"=="" & "`gl'"=="") local gk 15		
		local usegk = "`gk'"!=""
		
		local emonly emonly
		if "`noxtem'"!="" local emonly 
		
		//set estimation sample
		marksample touse
		markout `touse' `survcov' `timeinteraction' `assoccovariates'		
		qui replace `touse' = 0 if _st==0
		
		//longitudinal variables
		gettoken lhs rhs : varlist					
		
		//parse ml options and extract any extra constraints
		mlopts mlopts , `options'	
		local extra_constraints `s(constraints)'

		//panel ID variable
		tempvar _tempid
		qui egen `_tempid' = group(`panel')	if `touse'==1
		//final row per panel indicator
		tempvar surv_ind 
		qui bys `_tempid' (_t0): gen byte `surv_ind'= (_n==_N & `touse'==1)	
		//# measurements per panel
		tempvar n_meas
		qui bys `_tempid' (_t0): gen `n_meas' = _N if `touse'==1											
				
		//Numbers
		qui count if `touse'==1
		local nmeasures = `r(N)'
		qui count if `surv_ind'==1
		local Npat = `r(N)'			
		qui count if _d==1 & `surv_ind'==1
		local Nevents = `r(N)'
		local n_scovs : list sizeof survcov
		local n_lcovs : list sizeof rhs
		if "`frcs'"!="" local n_ftime = `frcs'
		else local n_ftime : list sizeof ffp
		if "`rrcs'"!="" local n_rtime = `rrcs'
		else local n_rtime : list sizeof rfp
		local npows = `n_ftime' + `n_rtime'
		local n_re = `n_rtime' + 1
		
		if "`frcs'"=="" {
			numlist "`ffp' `rfp'", sort
			local fps `r(numlist)'
			local firstpow : word 1 of `fps'
			if `firstpow' <= 0 {
				qui fracgen _t0 `fps' if `touse',  noscaling nogen
				local shift = `r(shift)'
			}
			else local shift = 0
			
			tempvar stime basetime
			qui gen double `stime'		= _t + `shift' if `touse'==1										
			qui gen double `basetime' 	= _t0 + `shift' if `touse'==1		
		}
		
		//Check time origin for delayed entry models
		tempvar del_surv_ind
		qui bys `_tempid' (_t0): gen byte `del_surv_ind' = (_n==1 & `touse'==1)		//summary passed to below quick/slow check

		local n_time_assoc = 0
		if "`association'"!="" {
			local n_time_assoc : list sizeof association
			tempname timeassoc_fixed_ind
			mat `timeassoc_fixed_ind' = J(`n_time_assoc',1,.)
		}	

	//===================================================================================================================================================//
	// Quick or slow //
		
		if "`fulldata'"=="" {
			if "`survcov'"!="" | "`assoccovariates'"!="" {
				local nvardiffs = 0
				foreach var of varlist `survcov' `assoccovariates' {
					tempvar ind_`var'
					qui bys `_tempid' (_t0): gen byte `ind_`var'' = (`var'[_n]==`var'[_n+1]) if _n<_N & _N>1 & `touse'==1
					qui bys `_tempid' (_t0): replace `ind_`var'' = (`var'[_n]==`var'[_n-1]) if _n==_N & _N>1 & `touse'==1
					qui count if `ind_`var''==0
					local nvardiffs = `nvardiffs' + `r(N)'
				}
				if `nvardiffs'==0 {
					local quick _quick
				}
			}
			else local quick _quick
		}
		
		if "`quick'"=="" {	// Full data
			local delsurvtouse "`touse'"
			local survtouse "`touse'"
			local Nsurv = `nmeasures'
			di in yellow "Warning -> all rows of data are being used in the survival component of the likelihood."
			di in yellow "        -> care must be taken if missing data is present, see the help file for details."
			di ""
		}
		else {				// quick option
			tempvar quickindex
			qui gen `quickindex' = _n if `touse'==1
			local delsurvtouse "`del_surv_ind'"
			local survtouse "`surv_ind'"
			local Nsurv = `Npat'
		}

		qui summ _t0 if `delsurvtouse'==1, meanonly
		local delentry = 0
		if `r(max)'>0 local delentry = 1

	//======================================================================================================================================================//
	// Handle time-dependent effects //		
		
		if "`tvc'"!="" {
			tempvar foft1
			if `"`texp'"' == "" {
					local texp _t
			}
			local texp: subinstr local texp " " "", all
			cap gen double `foft1' = `texp' if `touse'
			if _rc {
					di as err "{p 0 4 2}texp() invalid{p_end}"
					exit 198
			}
			qui count if `touse' & missing(`foft1')
			if `r(N)' {
				di as err "{p 0 4 2}texp() evaluates to missing for "
				di as err "`r(N)' observations{p_end}"
				exit 459
			}
			//FunctionOfTime `foft1' if `touse'		//!!add later

			// tvc() has a limit of 100 variables
			local Ntvcvars : word count `tvc'
			if `Ntvcvars' > 100 {
				di as err "too many variables specified"
				di as err "option tvc() incorrectly specified"
				exit 198 
			}
			//version 11: _rmcoll `tvc', forcedrop
				
		}
		
		
	//======================================================================================================================================================//
	// Create time variables //
		
		cap drop _time_*
		local ninterac : list sizeof timeinteraction
		scalar ntimecovinterac = `ninterac'

		//====================================================//
		// FP's 
		if "`ffp'"!="" | "`rfp'"!="" {
			local longtimeform fps
			
			tempname rand_ind fp_pows
			mat `rand_ind' = J(1,`npows',0)
			mat `fp_pows'  = J(1,`npows',.)
			
			// Generate timevars
			local j = 1
			local tfi_ind = 1
			local tassoc_ind = 1
			foreach i of numlist `fps' {
				mat `fp_pows'[1,`j']  = `i'
				tempvar _time_surv_`j'
				if (`i'!=0) {
					qui gen double _time_`j' 			= (`basetime')^(`i') 	if `touse'==1	
					qui gen double `_time_surv_`j'' 	= (`stime')^(`i') 		if `touse'==1
					
					if "`smodel'"=="fpm" | "`derivassociation'"!="" {
						tempvar d1_time_`j' d1_time_surv_`j'
						qui gen double `d1_time_`j''		= `i'*(`basetime')^(`=`i'-1') 	if `touse'==1
						qui gen double `d1_time_surv_`j'' 	= `i'*(`stime')^(`=`i'-1') 		if `touse'==1
						local d1_fe_timevar_names 		`d1_fe_timevar_names' `d1_time_`j''
						local d1_fe_timevar_names_surv 	`d1_fe_timevar_names_surv' `d1_time_surv_`j''		
					}
					
					if "`smodel'"=="fpm" & "`derivassociation'"!="" {
						tempvar d2_time_`j' d2_time_surv_`j'
						if `i'!=1 {
							qui gen double `d2_time_`j'' 		= (`=`i'-1')*(`i')*(`basetime')^(`=`i'-2') 	if `touse'==1
							qui gen double `d2_time_surv_`j'' 	= (`=`i'-1')*(`i')*(`stime')^(`=`i'-2') 	if `touse'==1
						}
						else {
							qui gen byte `d2_time_`j'' 		= 0 if `touse'==1
							qui gen byte `d2_time_surv_`j'' = 0 if `touse'==1
						}
						local d2_fe_timevar_names 		`d2_fe_timevar_names' `d2_time_`j''
						local d2_fe_timevar_names_surv 	`d2_fe_timevar_names_surv' `d2_time_surv_`j''
					}
					n `gbquietly' di in green "-> gen double _time_`j' = X^(`i')"
					label variable _time_`j' "_time_`j' = X^(`i') `xtxt'"
				}
				else {
					qui gen double _time_`j' 					= log(`basetime') 	if `touse'==1	
					qui gen double `_time_surv_`j'' 			= log(`stime') 		if `touse'==1
					if "`smodel'"=="fpm" | "`derivassociation'"!="" {
						tempvar d1_time_`j' d1_time_surv_`j'
						qui gen double `d1_time_`j''			= 1/(`basetime') 	if `touse'==1
						qui gen double `d1_time_surv_`j'' 		= 1/(`stime') 		if `touse'==1
						local d1_fe_timevar_names 		`d1_fe_timevar_names' `d1_time_`j''
						local d1_fe_timevar_names_surv 	`d1_fe_timevar_names_surv' `d1_time_surv_`j''
					}
					if "`smodel'"=="fpm" & "`derivassociation'"!="" {
						tempvar d2_time_`j' d2_time_surv_`j'
						qui gen double `d2_time_`j'' 		= -1/((`basetime')^2) 	if `touse'==1
						qui gen double `d2_time_surv_`j'' 	= -1/((`stime')^2) 		if `touse'==1
						local d2_fe_timevar_names 		`d2_fe_timevar_names' `d2_time_`j''
						local d2_fe_timevar_names_surv 	`d2_fe_timevar_names_surv' `d2_time_surv_`j''
					}
					n `gbquietly' di in green "-> gen double _time_`j' = log(X)"
					label variable _time_`j' "_time_`j' = log(X) `xtxt'"
				}

				local fe_timevar_names 			`fe_timevar_names' _time_`j'
				local fe_timevar_names_surv 	`fe_timevar_names_surv' `_time_surv_`j''

				if "`rfp'"!=""{
					foreach re of numlist `rfp' {
						if `re'==`i' {
							mat `rand_ind'[1,`j'] = 1
							local re_timevar_names 			`re_timevar_names' _time_`j'
							local re_timevar_names_surv 	`re_timevar_names_surv' `_time_surv_`j''
							if "`smodel'"=="fpm" | "`derivassociation'"!="" {
								local d1_re_timevar_names 		`d1_re_timevar_names' `d1_time_`j''
								local d1_re_timevar_names_surv 	`d1_re_timevar_names_surv' `d1_time_surv_`j''
							}
							if "`smodel'"=="fpm" & "`derivassociation'"!="" {
								local d2_re_timevar_names 		`d2_re_timevar_names' `d2_time_`j''
								local d2_re_timevar_names_surv 	`d2_re_timevar_names_surv' `d2_time_surv_`j''
							}
						}
					}
				}
						
				if "`association'"!="" {
					local dumtest = 0
					foreach ass in `association' {
						if `i'==`ass' {
							mat `timeassoc_fixed_ind'[`tfi_ind',1] = `tassoc_ind'
							local `++tfi_ind'
						}
					}				
					local `++tassoc_ind'
				}
								
				// time-covariate interactions
				if "`timeinteraction'"!="" {
				
					foreach covtime of varlist `timeinteraction' {
						tempvar interac_t_`j'_`covtime'
						qui gen double _time_`j'_`covtime'			= `covtime' * _time_`j' 		if `touse'==1
						qui gen double `interac_t_`j'_`covtime'' 	= `covtime' * `_time_surv_`j'' 	if `touse'==1
						local covinterlist1 	`covinterlist1' _time_`j'_`covtime'
						local covinterlist2 	`covinterlist2' `interac_t_`j'_`covtime''
						n `gbquietly' di in green "-> gen double _time_`j'_`covtime' = `covtime' * _time_`j'"
						label variable _time_`j'_`covtime' "_time_`j'_`covtime' = `covtime' * _time_`j'"
					}
					if "`smodel'"=="fpm" | "`derivassociation'"!="" {
						foreach covtime of varlist `timeinteraction' {
							tempvar  d1_interac_t_`j'_`covtime'
							qui gen double `d1_interac_t_`j'_`covtime'' 	= `covtime' * `d1_time_surv_`j'' 	if `touse'==1
							local d1_covinterlist_surv "`d1_covinterlist_surv' `d1_interac_t_`j'_`covtime''"
							if "`smodel'"=="fpm"{
								tempvar  d1_interac_t0_`j'_`covtime'
								qui gen double `d1_interac_t0_`j'_`covtime'' 	= `covtime' * `d1_time_`j'' 	if `touse'==1
								local d1_covinterlist_long 	`d1_covinterlist_long' `d1_interac_t0_`j'_`covtime''
							}
						}
					}
					if "`smodel'"=="fpm" & "`derivassociation'"!="" {
						foreach covtime of varlist `timeinteraction' {
							tempvar  d2_interac_t_`j'_`covtime'
							qui gen double `d2_interac_t_`j'_`covtime'' 	= `covtime' * `d2_time_surv_`j'' 	if `touse'==1
							local d2_covinterlist_surv 	`d2_covinterlist_surv' `d2_interac_t_`j'_`covtime''
						}
					}
				
				}	
				
				local `++j'
			}				
				
			if `shift'==0 n `gbquietly' di in green "(where X = _t0)"
			else n `gbquietly' di in green "(where X = _t0 + `shift')"
		}
				
		//================================================================================//
		// Splines
		else {
			
			if "`smodel'"=="fpm" | "`derivassociation'"!="" {
				tempvar d1_time d1_time_surv
				local dgen1 dgen(`d1_time'_)
				local dgen2 dgen(`d1_time_surv'_)				
			}

			//fixed time rcs
			qui rcsgen _t0 if `touse', df(`frcs') gen(_time_) /*orthog*/ `dgen1'
			local knots_1 `r(knots)'
			/*tempname rmat_frcs
			mat `rmat_frcs' = r(R)*/
			forvalues i=1/`frcs' {
				local fe_timevar_names `fe_timevar_names' _time_`i'
				if "`smodel'"=="fpm" | "`derivassociation'"!="" {
					local d1_fe_timevar_names `d1_fe_timevar_names' `d1_time'_`i'
				}
			}
			`gbquietly' di as txt "-> Spline variables created: `fe_timevar_names'"
			tempvar _time_surv
			qui rcsgen _t if `touse', knots(`knots_1') gen(`_time_surv'_) /*rmat(`rmat_frcs')*/ `dgen2'
			forvalues i=1/`frcs' {
				local fe_timevar_names_surv `fe_timevar_names_surv' `_time_surv'_`i'
				if "`smodel'"=="fpm" | "`derivassociation'"!="" {
					local d1_fe_timevar_names_surv `d1_fe_timevar_names_surv' `d1_time_surv'_`i'
				}
			}

			if "`timeinteraction'"!="" {
				foreach covtime of varlist `timeinteraction' {
					forvalues j=1/`frcs'{
						tempvar interac_t_`j'_`covtime'
						qui gen double _time_`j'_`covtime'			= `covtime' * _time_`j' 		if `touse'==1
						qui gen double `interac_t_`j'_`covtime'' 	= `covtime' * `_time_surv'_`j' 	if `touse'==1
						local covinterlist1 `covinterlist1' _time_`j'_`covtime'
						local covinterlist2 `covinterlist2' `interac_t_`j'_`covtime''
						n `gbquietly' di in green "-> gen double _time_`j'_`covtime' = `covtime' * _time_`j'"
						label variable _time_`j'_`covtime' "_time_`j'_`covtime' = `covtime' * _time_`j'"
					}
				}
				
				if "`smodel'"=="fpm" | "`derivassociation'"!="" {
					foreach covtime of varlist `timeinteraction' {
						forvalues j=1/`frcs'{
							tempvar  d1_interac_t_`j'_`covtime'
							qui gen double `d1_interac_t_`j'_`covtime'' 	= `covtime' * `d1_time_surv'_`j' 	if `touse'==1
							local d1_covinterlist_surv `d1_covinterlist_surv' `d1_interac_t_`j'_`covtime''
							if "`smodel'"=="fpm"{
								tempvar  d1_interac_t0_`j'_`covtime'
								qui gen double `d1_interac_t0_`j'_`covtime'' 	= `covtime' * `d1_time'_`j' 	if `touse'==1
								local d1_covinterlist_long 	`d1_covinterlist_long' `d1_interac_t0_`j'_`covtime''
							}
						}
					}
				}
			}

			//random time rcs
			if "`rrcs'"!="" {
				if "`rrcs'"!="`frcs'"{
					if "`smodel'"=="fpm" | "`derivassociation'"!="" {
						tempvar d1_re_time d1_re_time_surv
						local dgen3 dgen(`d1_re_time'_)
						local dgen4 dgen(`d1_re_time_surv'_)				
					}				
					tempvar _re_time
					qui rcsgen _t0, df(`rrcs') gen(_time_re_) /*orthog*/ `dgen3'
					local knots_2 `r(knots)'
					/*tempname rmat_rrcs
					mat `rmat_rrcs' = r(R)*/
					forvalues i=1/`rrcs' {
						local re_timevar_names `re_timevar_names' _time_re_`i'
						if ("`smodel'"=="fpm" | "`derivassociation'"!="") local d1_re_timevar_names 	`d1_re_timevar_names' `d1_re_time'_`i'
					}
					`gbquietly' di as txt "-> Spline variables created: `re_timevar_names'"
					tempvar _re_time_surv
					qui rcsgen _t, knots(`knots_2') gen(`_re_time_surv'_) /*rmat(`rmat_rrcs')*/ `dgen4'
					forvalues i=1/`rrcs' {
						local re_timevar_names_surv `re_timevar_names_surv' `_re_time_surv'_`i'
						if ("`smodel'"=="fpm" | "`derivassociation'"!="") local d1_re_timevar_names_surv 	`d1_re_timevar_names_surv' `d1_re_time_surv'_`i'
					}
				}
				else {
					local knots_2 `knots_1'
					local re_timevar_names `fe_timevar_names'
					if ("`smodel'"=="fpm" | "`derivassociation'"!="") local d1_re_timevar_names `d1_fe_timevar_names'
					local re_timevar_names_surv `fe_timevar_names_surv'
					if ("`smodel'"=="fpm" | "`derivassociation'"!="") local d1_re_timevar_names_surv `d1_fe_timevar_names_surv'
				}
			}
			
		}	
					
		// Variance ml equation names //
		if "`cov'"=="ind" | "`cov'"=="unstr" {
			forvalues i=1/`n_re' {
				local var_re_eqn_names "`var_re_eqn_names' /lns_`i'"											
			}
		}
		else local var_re_eqn_names "/lns_1"
		
		local eqn_names "(Longitudinal: = `fe_timevar_names' `covinterlist1' `rhs')"				/* Longitudinal ml equation */

	//========================================================================================================================================================================================//	
	// Fixed effect design matrices at exit times 
	
		local longparams_surv "`fe_timevar_names_surv' `covinterlist2' `rhs'"
		
		if "`smodel'"=="fpm" | "`derivassociation'"!="" {
			local ntemp = `n_lcovs' + 1
			local d1_fe_timevar_names "`d1_fe_timevar_names' `d1_covinterlist_long'"
			local d1_fe_timevar_names_surv "`d1_fe_timevar_names_surv' `d1_covinterlist_surv'"
		}
		
		if "`smodel'"=="fpm" & "`derivassociation'"!="" local d2_fe_timevar_names_surv "`d2_fe_timevar_names_surv' `d2_covinterlist_surv'"
		
	//========================================================================================================================================================================================//
	// Association parameterisation
	
		local alpha_ith = 1
		local current 	= 0
		local deriv 	= 0
		local intassoc 	= 0
		local timeassoc = 0
		if "`nocurrent'"=="" {
			local current = 1
			local alphaequation "`alphaequation' (alpha_`alpha_ith': `assoccovariates')"
			local `++alpha_ith'
		}
		if "`derivassociation'"!="" {
			local deriv = 1
			local alphaequation "`alphaequation' (alpha_`alpha_ith': `assoccovariates')"
			local `++alpha_ith'
		}
		if "`intassociation'"!="" {
			local intassoc = 1
			local alphaequation "`alphaequation' /alpha_`alpha_ith'"
			local `++alpha_ith'
		}
		if "`association'"!="" {
			local timeassoc = 1
			foreach assoc of numlist `association' {
				local alphaequation "`alphaequation' /alpha_`alpha_ith'"
				local `++alpha_ith'
			}
		}
		local n_alpha = `alpha_ith' - 1
	
	//========================================================================================================================================================================================//
	// GK set-up including longitudinal splines and hazard splines
		
		if "`smodel'"!="fpm" & !`aft' {
		
			tempname gknodes gkweights
			//GK nodes and weights
			if `usegk' {
				if (`gk'==15) {
					mat `gknodes' 	= 0.991455371120813,-0.991455371120813,0.949107912342759,-0.949107912342759,0.864864423359769,-0.864864423359769,0.741531185599394,-0.741531185599394,0.586087235467691,-0.586087235467691,0.405845151377397,-0.405845151377397,0.207784955007898,-0.207784955007898,0
					mat `gkweights'	= 0.022935322010529,0.022935322010529,0.063092092629979,0.063092092629979,0.104790010322250,0.104790010322250,0.140653259715525,0.140653259715525,0.169004726639267,0.169004726639267,0.190350578064785,0.190350578064785,0.204432940075298,0.204432940075298,0.209482141084728
				}
				else {
					mat `gknodes' 	= 0.949107912342759,-0.949107912342759,0.741531185599394,-0.741531185599394,0.405845151377397,-0.405845151377397,0
					mat `gkweights'	= 0.129484966168870,0.129484966168870,0.279705391489277,0.279705391489277,0.381830050505119,0.381830050505119,0.417959183673469
				}
			}
			else {
				stjm_gaussquad, n(`gl') legendre
				mat `gknodes' = r(nodes)'
				mat `gkweights' = r(weights)'
			}
		
			if "`quick'"!="" {
				tempvar delt
				qui bys `_tempid' (_t0): gen `delt' = _t0[1] if `touse'==1
				local tvar `delt'
			}
			else local tvar _t0
			
			//create basis GK node variables
			local gk `gk'`gl'
			forvalues i=1/`gk' {
				tempvar node`i'
				qui gen double `node`i'' =  0.5*(_t - `tvar')*(el(`gknodes',1,`i')) + 0.5*(_t + `tvar') if `survtouse'
			}
			
			//tvc's
			if "`tvc'"!="" {
				
				//for hazard function
				foreach tvcvar in `tvc' {
					cap drop `tvcvar'_tvc
					gen double `tvcvar'_tvc = `tvcvar' * `foft1'
					n `gbquietly' di in green "-> gen double `tvcvar'_tvc = `tvcvar' * `texp'"
					local tvcvars `tvcvars' `tvcvar'_tvc							//for ml model
				}
				local tvcmleqn (tvc: `tvcvars',nocons)
				
				//for quadrature
				local texpcopy `texp'
				forvalues i=1/`gk' {
					local texpfunc : subinstr local texpcopy "_t" "`node`i''", all		//update tdefunc with node tempvar
					tempvar tvcnode`i'
					qui gen double `tvcnode`i'' =  `texpfunc' if `survtouse' 		//needs to include texp()
					local tvcquadvars `tvcquadvars' `tvcnode`i''
				}
				//need separate quad vars for each tvc()
				local tvcind = 1
				foreach tvcvar in `tvc' {
					forvalues i=1/`gk' {
						tempvar tvcnode`tvcvar'`i'
						qui gen double `tvcnode`tvcvar'`i'' = `tvcnode`i'' * `tvcvar'  if `survtouse' 		//needs to include texp()
						local tvcquadvars`tvcind' `tvcquadvars`tvcind'' `tvcnode`tvcvar'`i''
					}
					local tvcind = `tvcind' + 1
				}				
			
			}
			
			tempvar cons
			qui gen byte `cons' = 1 if `survtouse'	
		}

		//getblups and exit
		if "`getblups'"!="" {
			mata: stjm_setup()	
			capture mata: rmexternal("`stjm_struct'")
			exit
		}
			
	//========================================================================================================================================================================================//
	// Initial values

	quietly{

		noisily di
		noisily di as txt "Obtaining initial values:"
		noisily di	
		
		tempname initmat
		// Longitudinal model initial values
		`noisily' xtmixed `lhs' `fe_timevar_names' `covinterlist1' `rhs' if `touse' || `_tempid': `re_timevar_names', cov(`cov') `variance' `emonly'
		matrix `initmat' = e(b)

		// predict RE's and seRE's
		forvalues i=1/`n_re' {
			tempvar blup`i' seblup`i'
			local blupnames "`blupnames' `blup`i''"
			local seblupnames "`seblupnames' `seblup`i''"
		}
		qui predict `blupnames' if `touse', reffects
		qui predict `seblupnames' if `touse', reses

		if "`nocurrent'"=="" {
			tempvar fitvals	
			qui predict `fitvals' if `touse', fitted
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
			
			if "`derivassociation'"!="" {
				tempvar deriv_1
				//FP's
				if "`rfp'"!="" {
					qui gen double `deriv_1' = 0
					local stub 		= 1
					local re_stub 	= 1
					foreach pow of numlist `fps' {
						if `pow'!=0 {
							if `rand_ind'[1,`stub']==1 {
								local derivadd "(([`lhs'][_time_`stub'] + `blup`re_stub'')*(`pow')*`basetime'^(`pow'-1))"
								local `++re_stub'
							}
							else local derivadd "([`lhs'][_time_`stub']*(`pow')*`basetime'^(`pow'-1))"	
						}
						else {
							if `rand_ind'[1,`stub']==1 {
								local derivadd "(([`lhs'][_time_`stub'] + `blup`re_stub'')/`basetime')"
								local `++re_stub'
							}
							else local derivadd "([`lhs'][_time_`stub']/`basetime')"
						}
						if "`timeinteraction'"!="" {
							foreach var of varlist `timeinteraction' {
								local derivadd2 "`derivadd2' + `derivadd'*`var' "
							}
						}
						replace `deriv_1' = `deriv_1' + (`derivadd') `derivadd2'
						local `++stub'
					}
				}
				//splines -> error check not allowing this
				else {
					tempvar fitvalsd1
					qui predict `fitvalsd1' if `touse', fitted
					qui dydx `fitvalsd1' _t0, gen(`deriv_1')
					qui bys _t0 (`deriv_1'): replace `deriv_1' = `deriv_1'[1]
					cap sort `_tempid' _t0
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
				local sepassocnameint "`blup`n_re''"				
				local alpha_di_txt "`alpha_di_txt' assoc:int"
			}
			
			if "`association'"!="" {
				//need to extract random time variables whose coefficients are specified for the association
				//index random time variables 
				tempname timeassoc_re_ind
				mat `timeassoc_re_ind' = J(`n_time_assoc',1,.)
				local re  = 1
				local ind = 1
				foreach repow of numlist `rfp' {
					foreach ass of numlist `association' {
						if `repow'==`ass' {
							mat `timeassoc_re_ind'[`ind',1] = `re'
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
							local sepassocnames "`sepassocnames' `blup`ind_row''"
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
	
		if "`cov'"=="exch" & `n_re'>1 {
			local corr_eqn_names "/art_1_1"
			local corr_eqn_names2 "art_1_1"		
		}
		else if "`cov'"=="unstr" {
			local subind = 1
			while (`subind'<`n_re') {
				forvalues i=`=`subind'+1'/`n_re' {
					local corr_eqn_names  "`corr_eqn_names' /art_`subind'_`i'"
					local corr_eqn_names2 "`corr_eqn_names2' art_`subind'_`i'"
				}
				local `++subind'
			}
		}
		
		local longequation "`eqn_names' `var_re_eqn_names' `corr_eqn_names' /lns_e"
		
		local var_corr_eqn_names `var_re_eqn_names' `corr_eqn_names'
		local nvcvparams : list sizeof var_corr_eqn_names
	
		//================================//
		// Survival model initial values 
		
		local searchopt "search(off)"
		tempname initmatsurv
		
		// Flexible parametric model
		if "`smodel'"=="fpm" {
			if "`df'"!="" {
				local splines "df(`df')"
			}
			else {
				local splines "knots(`knots')"
				local df : word count `knots'
				local df = `df' + 1
			}
						
			`noisily' stpm2 `associntlist1' `fitvals' `associntlist2' `derivlist' `associntlist3' `sepassocnameint' `sepassocnames' `survcov' if `touse', `splines' scale(hazard) `noorthog' failconvlininit	

			local ln_bhknots `e(ln_bhknots)'
			
			local nalphacovs : list sizeof assoccovariates
			local n1 = `n_alpha' * (`nalphacovs' +1 ) + `n_scovs' + 2*`df' + 1 
			local n2 = `n1' + `n_alpha' * (`nalphacovs' +1 ) + 1
			
			tempname mat1
			mat `mat1' = e(b)
			mat `initmatsurv' = `mat1'[1,1..`n1']
			mat `initmatsurv' = `initmatsurv',`mat1'[1,`n2'..colsof(`mat1')]
			tempname R_bh
			mat `R_bh' = e(R_bh)
			
			/* rcs and drcs names */
			local rcsnames "`e(rcsterms_base)'"
			local drcsnames "`e(drcsterms_base)'"
						
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
			//if further constraints are listed stpm2 then remove this from mlopts and add to conslist 
			if "`extra_constraints'" != "" {
				local mlopts : subinstr local mlopts "constraints(`extra_constraints')" "", word
				local conslist `conslist' `extra_constraints'
			}	
										
			local constopts "constraints(`conslist')"

			local collinopt "collinear"																		//pass collinear option as ml can drop spline variables when it shouldn't
			local survequation "(xb: `survcov' `rcsnames') (dxb: `drcsnames', nocons) `xb0_eqn'"			//rcs and drcs equations to pass to ml model 
				
		}
		// Exponential
		else if "`smodel'"=="e" {
			`noisily' streg `associntlist1' `fitvals' `associntlist2' `derivlist' `associntlist3' `sepassocnameint' `sepassocnames' `tvcvars' `survcov' if `touse', dist(exp) nohr 					/* initial values from streg fit */
			mat `initmatsurv' = e(b)
			local survequation "`tvcmleqn' (ln_lambda: `survcov')"	
		}
		// Weibull
		else if "`smodel'"=="w" {
			`noisily' streg `associntlist1' `fitvals' `associntlist2' `derivlist' `associntlist3' `sepassocnameint' `sepassocnames' `tvcvars' `survcov' if `touse', dist(weibull) nohr 					/* initial values from streg fit */
			mat `initmatsurv' = e(b)
			local survequation "`tvcmleqn' (ln_lambda: `survcov') /ln_gamma"	
		}
		// Gompertz
		else if "`smodel'"=="g" {
			`noisily' streg `associntlist1' `fitvals' `associntlist2' `derivlist' `associntlist3' `sepassocnameint' `sepassocnames' `tvcvars' `survcov' if `touse', dist(gompertz) nohr 					/* initial values from streg fit */
			mat `initmatsurv' = e(b)
			local survequation "`tvcmleqn' (ln_lambda: `survcov') /gamma"	
		}
		// Spline hazard model 
		else if "`smodel'"=="rcs" {
			if "`df'"!="" {
				local splines "df(`df')"
			}
			else {
				local splines "knots(`knots')"
			}
			
			//`noisily' strcs `longinitvars' `survcov' if `touse', `splines' `noorthog'
			`noisily' stgenreg if `touse', loghazard([xb]) xb(`associntlist1' `fitvals' `associntlist2' `derivlist' 	///
							`associntlist3' `sepassocnameint' `sepassocnames' `survcov' | #rcs(`splines' `noorthog'))
			mat `initmatsurv' = e(b)
			local bhknots `e(eqn1comp2bhknots)'
			tempname rmat
			mat `rmat' = e(eqn1comp2rcsmat)
			cap drop _rcs*
			forvalues i=1/`df' {
				rename _eq1_cp2_rcs`i' _rcs`i'
				local rcsnames `rcsnames' _rcs`i'
			}
			local survequation (xb: `survcov' `rcsnames')
			local nrcsterms : list sizeof rcsnames
			
		}
		// Mixture Weibull
		else if "`smodel'"=="ww" {
			`noisily' stmix `associntlist1' `fitvals' `associntlist2' `derivlist' `associntlist3' `sepassocnameint' `sepassocnames' `tvcvars' `survcov' if `touse', dist(ww) nohr
			mat `initmatsurv' = e(b)
			if "`survcov'"!="" | "`tvc'"!="" {
				local ww_eqn `tvcmleqn' (xb: `survcov',nocons)
			}
			local survequation "`ww_eqn' /logit_p_mix /ln_lambda1 /ln_gamma1 /ln_lambda2 /ln_gamma2"	
		}
		// Mixture Weibull-exponential
		else if "`smodel'"=="we" {
			`noisily' stmix `associntlist1' `fitvals' `associntlist2' `derivlist' `associntlist3' `sepassocnameint' `sepassocnames' `tvcvars' `survcov' if `touse', dist(we) nohr
			mat `initmatsurv' = e(b)
			if "`survcov'"!="" | "`tvc'"!="" {
				local we_eqn `tvcmleqn' (xb: `survcov',nocons)
			}
			local survequation "`we_eqn' /logit_p_mix /ln_lambda1 /ln_gamma1 /ln_lambda2"	
		}
		
		if ("`nullassoc'"!="" & "`nocurrent'"=="") {
			forvalues i=1/`n_alpha' {
				mat `initmatsurv'[1,`i']=0
			}
		}		
		matrix `initmat' = `initmat',`initmatsurv'
	}	
		
	//=======================================================================================================================================================//
	// Maximisation

		//Mata setup 
		if "`getblups'"=="" mata: stjm_setup()
		
		di as txt "Fitting full model:"
		if "`nonadapt'"=="" {
			di
			di in yellow "-> Conducting adaptive Gauss-Hermite quadrature"
		}

		if "`leave'"!="" {
			cap drop _STJM_tb*
			forvalues i=1/`n_re' {
				qui gen double _STJM_tb`i' = 0 if `touse'			
			}		
			local nop nopreserve
		}
		
		ml model d0 stjm_d0()											///
								`longequation' 							///
								`alphaequation'							///
								`survequation'							///
								if `touse'								///
								, init(`initmat', copy) 				///
								`options' 								///
								waldtest(0) 							///
								`searchopt'								///
								`collinopt'								///
								`constopts'								///
								`nolog'									///
								userinfo(`stjm_struct')					///
								`dprolog'								///
								`nop'									///
								maximize

		//Tidy up
		capture mata: rmexternal("`stjm_struct'")
		if _rc {
			di as error "Error when removing Mata global object"
			exit 1986
		}
		
		if "`leave'"!="" {
			forvalues i=1/`n_re' {
				qui bys `_tempid': replace _STJM_tb`i' = _STJM_tb`i'[_N] if `touse'			
			}		
		}
		
		ereturn local predict stjm_pred
		ereturn local title "Joint model estimates"
		ereturn local cmd stjm
		ereturn local survmodel "`smodel'"
		ereturn local longdepvar "`lhs'"
		ereturn local survdepvar "_t _d"
		ereturn local longtimeform "`longtimeform'"
		ereturn local rcsterms_base `rcsnames'
		ereturn local drcsterms_base `drcsnames'
		ereturn local long_varlist `rhs'
		ereturn local surv_varlist `survcov'
		ereturn local tvc `tvc'
		ereturn local texp `texp'
		ereturn local tvcvars `tvcvars'
		ereturn local panel `panel'
		ereturn local Npat `Npat'
		ereturn local Nobs `nmeasures'
		ereturn local Nevents `Nevents'
		ereturn local intmethod "`ghtext'"
		ereturn scalar dev = -2*e(ll)
		ereturn scalar AIC = -2*e(ll) + 2 * e(rank) 
		qui count if `touse' == 1 & _d == 1
		ereturn scalar BIC = -2*e(ll) + ln(r(N)) * e(rank)

		//Stuff for predictions
		ereturn local delentry `delentry'
		ereturn local fpind = "`frcs'"==""		
		ereturn local fixed_time `ffp'`frcs'
		ereturn local random_time `rfp'`rrcs'
		ereturn local frcs_knots `knots_1'
		ereturn local rrcs_knots `knots_2'
		ereturn local current `current'
		ereturn local deriv `deriv'
		ereturn local intassoc `intassoc'
		ereturn local timeassoc `timeassoc'
		ereturn local sepassoc_timevar_index `sepassocpred'
		ereturn local sepassoc_timevar_pows `association'
		ereturn local nocoefficient = "`nocoefficient'"!=""
		ereturn local npows `npows'
		ereturn local rand_timevars `re_timevar_names'
		ereturn local n_re = `n_re'
		ereturn local df `df'
		ereturn local shift `shift'
		ereturn local fps_list `fps'
		ereturn local nassoc `n_alpha'
		ereturn local ln_bhknots `ln_bhknots'
		ereturn local bhknots `bhknots'
		ereturn local northog `northog'
		ereturn local gh `gh'
		if `usegk' {
			ereturn local gk `gk'
		}
		else {
			ereturn local gl `gl'
		}
		ereturn local timecovvars `covinterlist1'
		ereturn local timeinteraction `timeinteraction'
		ereturn local assoccovariates `assoccovariates'
		ereturn local nvcvparams = `nvcvparams'
		ereturn local covtype `covtype'
		ereturn local nftime `n_ftime'
		ereturn local nrtime `n_rtime'
		
		if "`ffp'"!="" | "`rfp'"!="" {
			ereturn matrix fp_pows = `fp_pows'
			ereturn matrix rand_ind = `rand_ind'
		}
		if ("`smodel'"=="fpm") ereturn matrix rmatrix = `R_bh'
		if ("`smodel'"=="rcs") ereturn matrix rmatrix = `rmat'
		
		if "`association'"!="" {
			ereturn matrix timeassoc_re_ind = `timeassoc_re_ind'
			ereturn matrix timeassoc_fixed_ind = `timeassoc_fixed_ind'
		}
	
		tempname tempvcv
		matrix `tempvcv' = J(`n_re',`n_re',0)
		if "`covtype'"=="Independent" | "`covtype'"=="Unstructured" {
			forvalues i=1/`n_re' {											
				mat `tempvcv'[`i',`i'] 	= exp([lns_`i'][_cons])^2
			}
		}
		else {
			forvalues i=1/`n_re' {				
				mat `tempvcv'[`i',`i'] 	= exp([lns_1][_cons])^2
			}
		}
		if "`covtype'"=="Exchangeable" & `n_re'>1 {
			local test=1												
			while (`test'<`n_re') {
				forvalues i=`=`test'+1'/`n_re' {
					mat `tempvcv'[`test',`i'] 	 = tanh([art_1_2][_cons])*exp([lns_1][_cons])^2
					mat `tempvcv'[`i',`test'] 	 = `tempvcv'[`test',`i']
				}
				local `++test'
			}	
		}
		else if "`covtype'"=="Unstructured" {
			local test=1												
			while (`test'<`n_re') {
				forvalues i=`=`test'+1'/`n_re' {
					mat `tempvcv'[`test',`i'] 	 = exp([lns_`test'][_cons])*exp([lns_`i'][_cons])*tanh([art_`test'_`i'][_cons])
					mat `tempvcv'[`i',`test'] 	 = `tempvcv'[`test',`i']
				}
				local `++test'
			}	
		}
		ereturn matrix vcv = `tempvcv'
	
		if "`keepcons'" == "" constraint drop `dropconslist'
		else ereturn local sp_constraints `dropconslist'
		
		Replay, level(`level') `showcons' `variance'
end

program Replay
		syntax [, Level(cilevel) SHOWCons VARiance EFORM]
		Display, level(`level') `showcons' `variance' `form'
end

			
program Display
	syntax [, Level(cilevel) VARiance EFORM]
	
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
				as txt _col(50) "Number of obs.     = "							///
				as res _col(`=79-length("`e(Nobs)'")') `e(Nobs)'				
	di as txt "Panel variable: " as res abbrev("`e(panel)'",12) 				///
				as txt _col(50) "Number of panels   = "							///
				as res _col(`=79-length("`e(Npat)'")') `e(Npat)'
	di as txt _col(50) "Number of failures = "									///
				as res _col(`=79-length("`e(Nevents)'")') `e(Nevents)'
	
		di
	di as txt "Log-likelihood = " as res e(ll)
		di
		
	/*Show constraints if asked */
	if "`showcons'"=="" {
		local nocnsreport nocnsreport
	}
		
		local labind = 1
		if `e(nftime)'>0 {
			forvalues i=1/`e(nftime)' {
				local `++labind'
			}
		}
		if `e(nrtime)'>0 & "`e(longtimeform)'"=="fps" {
			forvalues i=1/`e(nrtime)' {
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
		ml di, neq(1) noheader showeqn nofootnote plus `nocnsreport' nolstretch
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
	if "`e(survmodel)'"=="fpm" | "`e(survmodel)'"=="rcs" {

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
				local scovs_names "`e(tvcvars)' `e(surv_varlist)'"		
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
		local scovs_names "`e(tvcvars)' `e(surv_varlist)'"		
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
		local scovs_names "`e(tvcvars)' `e(surv_varlist)'"		
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
	else if "`e(survmodel)'"=="ww" {
	
		local scovs_names "`e(tvcvars)' `e(surv_varlist)'"		
		if "`scovs_names'"!="" {
			di as res _col(11) "xb" as txt _col(14) "{c |}"
			foreach var of local scovs_names {																			//fixed covariates in survival model (survcov)
				forvalues i = 1/6 {
					local coef`i' = `results'[`labind',`i']
				}
				local var = abbrev("`var'",12)
				Di_param, label(`var') coef1(`coef1') coef2(`coef2') coef3(`coef3') coef4(`coef4') coef5(`coef5') coef6(`coef6')
				local `++labind'
			}
		}
		local p = 13 - length("logit_p_mix")
		di as res _col(`p') "logit_p_mix" as txt _col(14) "{c |}"
		_diparm logit_p_mix, label("_cons")
		local `++labind'
		local p = 13 - length("ln_lambda1")
		di as res _col(`p') "ln_lambda1" as txt _col(14) "{c |}"
		_diparm ln_lambda1, label("_cons")
		local `++labind'
		local p = 13 - length("ln_gamma1")
		di as res _col(`p') "ln_gamma1" as txt _col(14) "{c |}"
		_diparm ln_gamma1, label("_cons")
		local `++labind'
		local p = 13 - length("ln_lambda2")
		di as res _col(`p') "ln_lambda2" as txt _col(14) "{c |}"
		_diparm ln_lambda2, label("_cons")
		local `++labind'
		local p = 13 - length("ln_gamma2")
		di as res _col(`p') "ln_gamma2" as txt _col(14) "{c |}"
		_diparm ln_gamma2, label("_cons")
		local `++labind'				
	}
	else if "`e(survmodel)'"=="we" {
	
		local scovs_names "`e(tvcvars)' `e(surv_varlist)'"		
		if "`scovs_names'"!="" {
			di as res _col(11) "xb" as txt _col(14) "{c |}"
			foreach var of local scovs_names {																			//fixed covariates in survival model (survcov)
				forvalues i = 1/6 {
					local coef`i' = `results'[`labind',`i']
				}
				local var = abbrev("`var'",12)
				Di_param, label(`var') coef1(`coef1') coef2(`coef2') coef3(`coef3') coef4(`coef4') coef5(`coef5') coef6(`coef6')
				local `++labind'
			}
		}
		local p = 13 - length("logit_p_mix")
		di as res _col(`p') "logit_p_mix" as txt _col(14) "{c |}"
		_diparm logit_p_mix, label("_cons")
		local `++labind'
		local p = 13 - length("ln_lambda1")
		di as res _col(`p') "ln_lambda1" as txt _col(14) "{c |}"
		_diparm ln_lambda1, label("_cons")
		local `++labind'
		local p = 13 - length("ln_gamma1")
		di as res _col(`p') "ln_gamma1" as txt _col(14) "{c |}"
		_diparm ln_gamma1, label("_cons")
		local `++labind'
		local p = 13 - length("ln_lambda2")
		di as res _col(`p') "ln_lambda2" as txt _col(14) "{c |}"
		_diparm ln_lambda2, label("_cons")
		local `++labind'
	}
	else if "`e(survmodel)'"=="llogistic" {
	
		di as res _col(9) "beta" as txt _col(14) "{c |}"
		local scovs_names "`e(tvcvars)' `e(surv_varlist)'"		
		foreach var of local scovs_names {																			//fixed covariates in survival model (survcov)
			forvalues i = 1/6 {
				local coef`i' = `results'[`labind',`i']
			}
			local var = abbrev("`var'",12)
			Di_param, label(`var') coef1(`coef1') coef2(`coef2') coef3(`coef3') coef4(`coef4') coef5(`coef5') coef6(`coef6')
			local `++labind'
		}
		_diparm beta, label("_cons")		/*ln_lambda baseline */
		local `++labind'	
		local p = 13 - length("ln_gamma")
		di as res _col(`p') "ln_gamma" as txt _col(14) "{c |}"
		_diparm ln_gamma, label("_cons")
		local `++labind'

	}
	else if "`e(survmodel)'"=="lnormal" {
	
		di as res _col(11) "mu" as txt _col(14) "{c |}"
		local scovs_names "`e(tvcvars)' `e(surv_varlist)'"		
		foreach var of local scovs_names {																			//fixed covariates in survival model (survcov)
			forvalues i = 1/6 {
				local coef`i' = `results'[`labind',`i']
			}
			local var = abbrev("`var'",12)
			Di_param, label(`var') coef1(`coef1') coef2(`coef2') coef3(`coef3') coef4(`coef4') coef5(`coef5') coef6(`coef6')
			local `++labind'
		}
		_diparm mu, label("_cons")		/*ln_lambda baseline */
		local `++labind'	
		local p = 13 - length("ln_sigma")
		di as res _col(`p') "ln_sigma" as txt _col(14) "{c |}"
		_diparm ln_sigma, label("_cons")
		local `++labind'

	}
	else if "`e(survmodel)'"=="gamma" {
	
		di as res _col(11) "mu" as txt _col(14) "{c |}"
		local scovs_names "`e(tvcvars)' `e(surv_varlist)'"		
		foreach var of local scovs_names {																			//fixed covariates in survival model (survcov)
			forvalues i = 1/6 {
				local coef`i' = `results'[`labind',`i']
			}
			local var = abbrev("`var'",12)
			Di_param, label(`var') coef1(`coef1') coef2(`coef2') coef3(`coef3') coef4(`coef4') coef5(`coef5') coef6(`coef6')
			local `++labind'
		}
		_diparm mu, label("_cons")		/*ln_lambda baseline */
		local `++labind'	
		local p = 13 - length("ln_sigma")
		di as res _col(`p') "ln_sigma" as txt _col(14) "{c |}"
		_diparm ln_sigma, label("_cons")
		local `++labind'
		local p = 13 - length("kappa")
		di as res _col(`p') "kappa" as txt _col(14) "{c |}"
		_diparm kappa, label("_cons")
		local `++labind'

	}	
	
	di as txt "{hline 13}{c BT}{hline 64}"
	
	/* Random effects table title*/
		di 
		di as txt "{hline 29}{c TT}{hline 48}"
		di as txt _col(3) "Random effects Parameters" _col(30) "{c |}" _col(34) "Estimate" _col(45) "Std. Err." _col(`=61-`k'') ///
		`"[`=strsubdp("`level'")'% Conf. Interval]"'
		di as txt "{hline 29}{c +}{hline 48}"
		if "`e(n_re)'"!="1"{
			local labtextvcv `e(covtype)'
		}
		else local labtextvcv "Independent"
		di as res abbrev("`e(panel)'",12) as txt ": `labtextvcv'" _col(30) "{c |}"

	/* Std. dev./Variances of random effects */
		local retimelabelnames2 `e(rand_timevars)' _cons
		if ("`labtextvcv'"=="Independent" | "`labtextvcv'"=="Unstructured") {
			local test = 1
			forvalues i=1/`e(n_re)' {
				local lab : word `test' of `retimelabelnames2'
				Var_display, param("lns_`i'") label("`sdtxt'(`lab')") `variance'
				local `++test'
			}
		}
		else {
			local name = abbrev(trim("`retimelabelnames2'"),19)
			local n2 = length("`retimelabelnames2'")
			if `n2'>19 {
				local n1 "(1)"
			}
			Var_display, param("lns_1") label("`sdtxt'(`name')`n1'") `variance'
		}
		
	/* Corrs/Covariances of random effects */
		if ("`labtextvcv'"=="Unstructured" & `e(n_re)'>1) {
			local firstindex = 1
			local txtindex = 1
			while (`firstindex'<`e(n_re)') {
				local test = `firstindex' + 1
				local test2 = 1
				forvalues i=`test'/`e(n_re)' {
					local ind2 = `i'-1
					local lab1 : word `txtindex' of `retimelabelnames2'
					local lab2 : word `=`txtindex'+`test2'' of `retimelabelnames2'
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
		else if ("`labtextvcv'"=="Exchangeable" & `e(n_re)'>1) {
			local name = abbrev(trim("`retimelabelnames2'"),19)
			local n2 = length("`retimelabelnames2'")
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
		di as txt "{hline 29}{c +}{hline 48}"
		Var_display, param(lns_e) label("`sdtxt'(Residual)") `variance'
		di as txt "{hline 29}{c BT}{hline 48}"
	
	local l = length(trim("`retimelabelnames2'"))	
	if `l'>19 & ("`labtextvcv'"=="Exchangeable" | "`labtextvcv'"=="Identity") {
		di in green "(1) `retimelabelnames2'"
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
	else if "`e(survmodel)'"=="rcs" {
		local smodeltxt "Restricted cubic spline hazard model"
	}
	else if "`e(survmodel)'"=="ww" {
		local smodeltxt "Mixture Weibull-Weibull hazard model"
	}
	else if "`e(survmodel)'"=="we" {
		local smodeltxt "Mixture Weibull-exponential hazard model"
	}
	else if "`e(survmodel)'"=="llogistic" {
		local smodeltxt "Log-logistic AFT model"
	}	
	else if "`e(survmodel)'"=="lnormal" {
		local smodeltxt "Log normal AFT model"
	}
	else if "`e(survmodel)'"=="gamma" {
		local smodeltxt "Generalised gamma AFT model"
	}	
	else {
		local smodeltxt "Flexible parametric model"
	}
	
	di ""
	di in green " Longitudinal submodel: Linear mixed effects model"
	di in green "     Survival submodel: `smodeltxt'"
	di in green "    Integration method: `e(intmethod)' using `e(gh)' nodes"
	if "`e(survmodel)'"!="fpm" & "`e(survmodel)'"!="llogistic" & "`e(survmodel)'"!="lnormal" & "`e(survmodel)'"!="gamma" {
		if "`e(gk)'"!="" di in green "     Cumulative hazard: Gauss-Kronrod quadrature using `e(gk)' nodes"
		if "`e(gl)'"!="" di in green "     Cumulative hazard: Gauss-Legendre quadrature using `e(gl)' nodes"
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
