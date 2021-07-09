*! version 2.1.0 ?????2013 MJC

//adding aft's 

/*
History
MJC 29jul2013: version 2.1.0 - some doubles were missing on predictnl lines
							 - rcs predictions added
							 - bug in undocumented derivs missed time interactions
MJC 14feb2013: version 2.0.3 - synched with tvc's
MJC 15nov2012: version 2.0.2 - synched with nocoefficient
MJC 15aug2012: version 2.0.1 - erroneous sort caused fulldata to be invoked when unnecessary, now fixed
MJC 11aug2012: version 2.0.0 - Synched with stjm version 2.0.0
MJC 02Feb2012: version 1.3.0 - xb survival predictions now average of m draws from random effects plus fixed effects. reses predictions added. 
							 - Syntax for reffects/reses changed to stub* or newvarlist
MJC 02Nov2011: version 1.2.0 - added exponential and Gompertz
MJC 14Oct2011: version 1.1.0 - added Weibull survival submodel predictions
MJC 10Oct2011: version 1.0.0
*/

program stjm_pred,sortpreserve
	version 12.1
	syntax anything(name=vlist) [if] [in],	[						///
												XB					///		-linear predictor for the fixed portion of the model-
												FITted				///		-linear predictor of the fixed portion plus predicted random effects-
																	///
												REFfects			///		-Empirical Bayes predictions of the random effects-							
												RESEs				/// 	-Standard errors of BLUPS-													
																	///
												Residuals			///		-Observed minus fitted-														
												RSTAndard			/// 	-Residuals/sigma_e-															
																	///
												Longitudinal		/// 	-fitted longitudinal submodel based on fixed/full portion of joint model- 	
												DLongitudinal		///		-fitted 1st derivative of longitudinal submodel-  UNDOCUMENTED
												DDLongitudinal		///		-fitted 2nd derivative of longitudinal submodel-  UNDOCUMENTED
																	///
												Hazard				///		-fitted hazard function based on fixed/full portion of joint model- 				
												Survival			///		-fitted survival function based on fixed/full portion of joint model- 				
												CUMHazard			///		-fitted cumulative hazard function based on fixed/full portion of joint model- 		
																	///
												MARTingale			///		-Martingale residuals-
												DEViance			/// 	-Deviance residuals-
																	///
												TIMEvar(varname)	///		-Evaluate predictions using a user specified time variable-
												ZEROs				///		-baseline predictions-
												AT(string)			/// 	-Out of sample predictions-
												CI					///		-Calculate confidence intervals-
																	///
												MEASTime			/// 	-Evaluate predictions at measurement times-
												SURVTime			///		-Evaluate predictions at survival time-
																	///
												M(string)			///		-Number of draws from MVN for survival predictions-
																	///
												NOPRESERVE			///		-UNDOCUMENTED-
												GETBLUPSGH(int 30)	///		-UNDOCUMENTED-
												BLUPS(string)		///		-UNDOCUMENTED-
												condsurv(string)	///
											]
	
		marksample touse, novarlist
		local newvarname `vlist'
		qui count if `touse'
		local Nobs = `r(N)'
		if `Nobs'==0 {
			exit 2000
		}
	
	//=======================================================================================================================================================//
	// Error checks

		if wordcount(`"`hazard' `survival' `cumhazard' `longitudinal' `dlongitudinal' `ddlongitudinal' `reffects' `reses' `residuals' `rstandard' `martingale' `deviance'"') > 1 {
			di as error "You have specified more than one form of prediction"
			exit 198
		}
		
		if wordcount(`"`hazard' `survival' `cumhazard' `longitudinal' `dlongitudinal' `ddlongitudinal' `reffects' `reses' `residuals' `rstandard' `martingale' `deviance'"') == 0 {
			di as error "You must specify a form of prediction"
			exit
		}
		
		if wordcount(`"`xb' `fitted'"') > 1 {
			di as error "Only one of xb and fitted may be specified"
			exit 198
		}
		
		if ("`reffects'"!="" | "`reses'"!="") & ("`xb'"!="" | "`fitted'"!="" | "`survtime'"!="") {
			di as error "Cannot specify xb/fitted/survtime with reffects/reses"
			exit 198
		}
		
		if ("`residuals'"!="" | "`rstandard'"!="") & "`survtime'"!="" {
			di as error "Cannot specify survtime for longitudinal residuals"
			exit 198
		}
		
		if wordcount(`"`meastime' `survtime'"') > 1 {
			di as error "Can specify only one of meastime and survtime"
			exit 198
		}
		
		if wordcount(`"`meastime' `survtime'"') > 0 & "`timevar'"!="" {
			di as error "Cannot specify meastime/survtime with timevar"
			exit 198
		}

		if wordcount(`"`hazard' `survival' `cumhazard'"') > 0 & "`fitted'"=="" & "`m'"!="" {
			cap confirm integer number `m'
			if _rc>0 {
				di as error "m() must be an integer"
				exit 198
			}
		}		
		
		local nnewvars : word count `newvarname'
		if `nnewvars'>1 & ("`reffects'"=="" & "`reses'"=="") {
			gettoken dub else : newvarname
			if "`dub'"=="double" & `nnewvars'==2 {
				local newvarname `else'
			}
			else {
				di as error "Only one new variable name can be specified"
				exit 198
			}
		}
		
		local lengthlist = length("`newvarname'")
		local star = substr("`newvarname'",`lengthlist',`lengthlist')
		local stub = substr("`newvarname'",1,`=`lengthlist'-1')
		if ("`reffects'"=="" & "`reses'"=="") & "`star'"=="*" {
			di as error "Invalid variable name"
			exit 198
		}
		
		if "`star'"!="*" & ("`reffects'"!="" | "`reses'"!="") & `nnewvars'!=`e(n_re)' {
			di as error "Number of new variables specified does not match number of random effects"
			exit 198
		}
		
		if "`longitudinal'"=="" & "`ci'"!="" {
			di as error "Confidence intervals not available"
			exit 198
		}
		
	//======================================================================================================================================================//
	// Defaults
		
		local smodel "`e(survmodel)'"
		
		//aft models
		local aft = 0
		if "`smodel'"=="gamma" | "`smodel'"=="lnormal" | "`smodel'"=="llogistic" local aft = 1
		
		if ("`smodel'"=="w" | "`smodel'"=="e" | "`smodel'"=="g") & "`martingale'"!="" {
			di as error "martingales not available"
			exit 198
		}
		
		if wordcount(`"`xb' `fitted'"') == 0 & wordcount(`"`longitudinal' `dlongitudinal'"') > 0 {
			local predopt "xb"
		}

		if wordcount(`"`xb' `fitted'"') == 0 & wordcount(`"`residuals' `rstandard' `martingale'"') > 0 {
			local predopt "fitted"
		}
		
		if wordcount(`"`xb' `fitted'"') == 0 & wordcount(`"`survival' `hazard' `cumhazard'"') > 0 {
			local predopt "xb"
		}		
	
		if wordcount(`"`xb' `fitted'"') > 0 {
			local predopt = trim("`xb' `fitted'")
		}
		
		/* Longitudinal default time is meastime */
		if wordcount(`"`meastime' `survtime'"') == 0 & "`timevar'"=="" & wordcount(`"`longitudinal' `dlongitudinal' `ddlongitudinal' `residuals' `rstandard'"') > 0 {
			local predtime "meastime"
		}
		
		/* Survival default time is event time */
		if wordcount(`"`meastime' `survtime'"') == 0 & "`timevar'"=="" & wordcount(`"`hazard' `survival' `cumhazard' `martingale' `deviance'"') > 0 {
			local predtime "survtime"
		}
		
		if wordcount(`"`meastime' `survtime'"') > 0 {
			local predtime = trim("`meastime' `survtime'")
		}

		if wordcount(`"`hazard' `survival' `cumhazard'"') > 0 & "`predopt'"=="xb" & "`m'"=="" {
			scalar m = 250
			local nm  = 250
		}
		else if wordcount(`"`hazard' `survival' `cumhazard'"') > 0 & "`predopt'"=="xb" & "`m'"!="" {
			scalar m = `m'
			local nm = `m'
		}

		if "`ci'"!="" local seciopt "ci(`newvarname'_lci `newvarname'_uci)"
		else if "`stdp'"!="" local seciopt "se(`newvarname'_se)"
		else local seciopt
		
		if "`predopt'"=="fitted" & "`ci'"!="" {
			di as error "ci cannot be used with fitted"
			exit 198
		}
		
		if "`timevar'"!="" {
			local predtime "timevar(`timevar')"
		}
		
*quietly {		
		tempvar _tempidp
		qui egen `_tempidp' = group(`e(panel)')	if e(sample)==1

		tempvar surv_ind_pred
		qui bys `_tempidp' (_t0) : gen `surv_ind_pred'= _n==_N	if e(sample)==1		// final row indicator per panel
		qui replace `surv_ind_pred' = 0 if `surv_ind_pred'==.

		if "`nopreserve'"=="" {
			/* Preserve data for out of sample prediction  */	
			tempfile newvars 
			preserve		
		}		
		
		
	//==============================================================================================//
	// BLUPS and se(BLUPS)
	
		if ("`reffects'"!="" | "`reses'"!="" | "`predopt'"=="fitted") & "`blups'"=="" {
				
			// Create new variables to store predictions 
			if "`predopt'"!="fitted" {
				if "`star'"=="*" {
					forvalues i=1/`e(n_re)' {
						qui gen double `stub'`i' = . if `touse'==1
						local newnames `newnames' `stub'`i'
					}
				}
				else {
					foreach var in `newvarname' {
						qui gen double `var' = .  if `touse'==1
					}
					local newnames `newvarname'
				}
			}
			else {
				forvalues i=1/`e(n_re)' {
					tempvar tempblups`i'
					qui gen double `tempblups`i'' = . if `touse'==1
					local newnames `newnames' `tempblups`i''
				}
				local tempblupnames `newnames'
			}
			
			//get blups
			if "`reses'"!="" local reise reise
			`e(cmdline)' getblups(`newnames') `reise' posttouse(`surv_ind_pred') getblupsgh(`getblupsgh') condsurv(`condsurv')
			
			// replicate final row 
			foreach var in `newnames' {	
				qui bys `_tempidp' (_t0): replace `var' = `var'[_N]	if `touse'==1
			}
			//cap sort `e(panel)' _t0
			// label variables
			if "`reses'"!="" {
				local sd " std. errors"
			}
			local i = 1
			if "`e(rand_timevars)'"!="" {
				foreach name in `e(rand_timevars)' { 
					local newvar : word `i' of `newnames'
					label variable `newvar' "BLUP r.e.`sd' for `name'"
					local `++i'
				}
			}
			local nintvar : word count `newnames'
			local intvar : word `nintvar' of `newnames'
			label variable `intvar' "BLUP r.e.`sd' for intercept"
		}
	
	if "`blups'"!="" local tempblupnames `blups'
	
	//====================================================================================================================================================//
	// Baseline predictions //
	
		if "`zeros'"!="" {
			foreach var in `e(long_varlist)' `e(surv_varlist)' `e(tvc)' {
				if `"`: list posof `"`var'"' in at'"' == "0" { 
					qui replace `var' = 0 if `touse'
				}
			}
		}	
		
	//====================================================================================================================================================//
	// Out of sample predictions using at() 
	
		if "`at'" != "" {
			local atlist at(`at')
			tokenize `at'
			while "`1'"!="" {
				unab 1: `1'
				if "`1'"=="`e(longdepvar)'" {
					di as error "Cannot specify longitudinal response in at()"
					exit 198
				}
				cap confirm var `1'
				if _rc {
					cap confirm num `2'
					if _rc {
						di in red "invalid at(... `1' `2' ...)"
						exit 198
					}
				}
				qui replace `1' = `2' if `touse'
				mac shift 2
			}
		}
	
	//====================================================================================================================================================//
	// Essentials

		if "`reffects'"=="" & "`reses'"=="" {	
			// polynomials of time
			if (`e(fpind)') {
				tempname rand_ind fp_pows
				mat `rand_ind' 	= e(rand_ind)		// Indicator matrix to denote random FP's 
				mat `fp_pows' 	= e(fp_pows)		// Matrix to store FP powers 
			}
			// splines of time
			else {
				local frcs_knots `e(frcs_knots)'
				local rrcs_knots `e(rrcs_knots)'
			}
			
			//VCV matrix
			tempname vcv
			matrix `vcv' = e(vcv)
		}

	//====================================================================================================================================================//
	// Basis longitudinal and survival time variables
		
		if "`reffects'"=="" & "`reses'"=="" {	
			if "`e(shift)'"!="" local shift + `e(shift)'
			else local shift + 0
			
			// Longitudinal
			tempvar basetime basesurvtime
			if "`predtime'"=="meastime" {
				qui gen double `basetime' = _t0 `shift' if `touse'==1
				qui gen double `basesurvtime' = _t0 if `touse'==1
			}
			else if "`timevar'"!="" {
				qui gen double `basetime' = `timevar' `shift' if `touse'==1
				qui gen double `basesurvtime' = `timevar' if `touse'==1
			}
			else if "`predtime'"=="survtime" {
				qui gen double `basetime' = _t `shift' if `touse'==1
				qui gen double `basesurvtime' = _t if `touse'==1
			}

			// Splines for fpm/rcs
			if "`smodel'"=="fpm" | "`smodel'"=="rcs" {
				tempvar lnt 
				qui gen double `lnt' = ln(`basesurvtime') if `touse'==1
					
				if "`smodel'"=="fpm" {
					local knots `e(ln_bhknots)'
					cap drop _rcs* _d_rcs*
					local newrcsnames _rcs
					local newdrcsnames dgen(_d_rcs)
				}
				else {
					local knots `e(bhknots)'
					cap drop _rcs*
					local newrcsnames _rcs
				}
				
				if "`e(noorthog)'"=="" {
					tempname rmatrix
					matrix `rmatrix' = e(rmatrix)
					local rmat rmatrix(`rmatrix')
				}
				qui rcsgen `lnt' if `touse', knots(`knots') gen(`newrcsnames') `newdrcsnames' `rmat'
			}
		
		}			
	
	//====================================================================================================================================================//
	// Build longitudinal time variables
	
		if "`reffects'"=="" & "`reses'"=="" {
		
			cap drop _time_*
			// Polynomials of time
			if `e(fpind)' {
				// Generate timevars 
				local j = 1
				foreach i of numlist `e(fps_list)' {
					if (`i'!=0) qui gen double _time_`j' = `basetime'^(`i') if `touse'==1	
					else qui gen double _time_`j' = log(`basetime') if `touse'==1	

					// time and covariate interactions
					if "`e(timeinteraction)'"!="" {
						foreach cov of varlist `e(timeinteraction)' {
							qui gen double _time_`j'_`cov' = `cov' * _time_`j' if `touse'==1
						}
					}	
					local `++j'
				}
			}
			// Splines
			else {
				qui rcsgen `basetime', gen(_time_) knots(`frcs_knots')
				if "`e(random_time)'"!="" qui rcsgen `basetime', gen(_time_re_) knots(`rrcs_knots')
				// time and covariate interactions
				if "`e(timeinteraction)'"!="" {
					forvalues i=1/`e(fixed_time)' {
						foreach cov of varlist `e(timeinteraction)' {
							qui gen double _time_`i'_`cov' = `cov' * _time_`i' if `touse'==1
						}
					}
				}				
			}	
			
			//time-dependent effects
			if "`e(tvc)'"!="" {
				//for hazard function
				tempvar foft1
				local texpcopy `e(texp)'
				local texpfunc : subinstr local texpcopy "_t" "`basesurvtime'", all				
				qui gen double `foft1' = `texpfunc' if `touse'

				foreach tvcvar in `e(tvc)' {
					cap drop `tvcvar'_tvc
					qui gen double `tvcvar'_tvc = `tvcvar' * `foft1' if `touse'
				}
							
			}
		}
	

	//====================================================================================================================================================//
																	// Predictions
	//====================================================================================================================================================//
	
	// Longitudinal xb/fitted values

		if "`longitudinal'"!="" {
		
			if "`predopt'"=="xb" {
				qui predictnl double `newvarname' = xb(Longitudinal) if `touse', `seciopt'
				label variable `newvarname' "Longitudinal prediction - xb"
			}
		
			if "`predopt'"=="fitted" {
							
				// Build string to multiply BLUPS and appropriate _time* variables
				// FPs
				if (`e(fpind)') {
					local ind = 1
					if `e(n_re)' > 1 {
						forvalues i = 1/`e(npows)' {
							if (`rand_ind'[1,`i']==1) {
								local revar : word `ind' of `tempblupnames'
								local eb_adds "+ `revar'*_time_`i' `eb_adds'"
								local `++ind'
							}
						}
					}
				}
				// Splines
				else {
					if "`e(random_time)'"!="" {
						forvalues i=1/`e(random_time)' {
							local revar : word `i' of `tempblupnames'
							local eb_adds "+ `revar'*_time_re_`i' `eb_adds'"
						}	
					}
				}
				// add random intercept
				local finaladd : word `e(n_re)' of `tempblupnames'
				local eb_adds "+ `finaladd' `eb_adds'"
				
				qui predictnl double `newvarname' = xb(Longitudinal) `eb_adds' if `touse'
				label variable `newvarname' "Longitudinal prediction (including BLUPS)"
			}	
			
		}
	
	//====================================================================================================================================================//
	// Longitudinal residuals
	
		if "`residuals'"!="" {
			tempvar long_pred
			qui predict `long_pred' if `touse', fitted longitudinal meastime `zeros' `atlist' blups(`tempblupnames')
			gen double `newvarname' = (`e(longdepvar)' - (`long_pred')) if `touse'
			label variable `newvarname' "Residuals"
		}
		
		if "`rstandard'"!="" {
			tempvar long_pred
			qui predict `long_pred' if `touse', fitted longitudinal meastime `zeros' `atlist'
			gen double `newvarname' = (`e(longdepvar)' - (`long_pred'))/exp([lns_e][_cons]) if `touse'
			label variable `newvarname' "Standardised residuals"
		}	

	//====================================================================================================================================================//
	// 1st derivative of longitudinal submodel - fitted

		if "`dlongitudinal'"!="" {
			
			local ind = 1
			forvalues i=1/`e(npows)' {
				/* First derivative of time variables */
				if (`rand_ind'[1,`i']==1 & "`predopt'"=="fitted" ) {
					if (`fp_pows'[1,`i']!=0) {
						local diff`i' "(`fp_pows'[1,`i']*`basetime'^(`fp_pows'[1,`i']-1))"
					}
					else {
						local diff`i' "(1/`basetime')"
					}
					local add`ind' : word `ind' of `tempblupnames'
					local linpred_time_diff "`linpred_time_diff' ([Longitudinal][_time_`i']+`add`ind'')*`diff`i''+"
					local `++ind'						
				}
				else {
					if (`fp_pows'[1,`i']!=0) {
						local diff`i' "(`fp_pows'[1,`i']*`basetime'^(`fp_pows'[1,`i']-1))"
					}
					else {
						local diff`i' "(1/`basetime')"
					}
					local linpred_time_diff "`linpred_time_diff' ([Longitudinal][_time_`i'])*`diff`i'' +"	
				}
				
				if "`e(timeinteraction)'"!="" {
					foreach var in `e(timeinteraction)' {
						local linpred_time_diff "`linpred_time_diff' ([Longitudinal][_time_`i'_`var']*`diff`i''*`var') +"
					}
				}
				
			}	
			qui gen double `newvarname' = `linpred_time_diff' 0 if `touse'
		}
		
	//====================================================================================================================================================//
	// 2nd derivative of longitudinal submodel - fitted 
	
		if "`ddlongitudinal'"!="" {
			
			local ind = 1
			forvalues i=1/`e(npows)' {
				if (`rand_ind'[1,`i']==1 & "`predopt'"=="fitted") {
				
					if (`fp_pows'[1,`i']==0) {
						local 2diff`i' "(-1/(`basetime'^2))"
						local add`ind' : word `ind' of `tempblupnames'
						local linpred_time_diff2 "`linpred_time_diff2' ([Longitudinal][_time_`i']+`add`ind'')*`2diff`i'' +"	
						local `++ind'						
					}
					else if (`fp_pows'[1,`i']==1) {
						local 2diff`i' "0"
						local `++ind'
					}
					else {
						local 2diff`i' "(`fp_pows'[1,`i']*(`fp_pows'[1,`i']-1)*`basetime'^(`fp_pows'[1,`i']-2))"
						local add`ind' : word `ind' of `tempblupnames'
						local linpred_time_diff2 "`linpred_time_diff2' ([Longitudinal][_time_`i']+`add`ind'')*`2diff`i'' +"	
						local `++ind'					
					}
				}
				else {
					if (`fp_pows'[1,`i']==0) {
						local 2diff`i' "(-1/(`basetime'^2))"
						local linpred_time_diff2 "`linpred_time_diff2' ([Longitudinal][_time_`i'])*`2diff`i'' +"	
					}
					else if (`fp_pows'[1,`i']==1) {
						local 2diff`i' "0"
					}
					else {
						local 2diff`i' "(`fp_pows'[1,`i']*(`fp_pows'[1,`i']-1)*`basetime'^(`fp_pows'[1,`i']-2))"
						local linpred_time_diff2 "`linpred_time_diff2' ([Longitudinal][_time_`i'])*`2diff`i'' +"	
					}
				}
				
				if "`e(timeinteraction)'"!="" {
					foreach var in `e(timeinteraction)' {
						local linpred_time_diff2 "`linpred_time_diff2' ([Longitudinal][_time_`i'_`var']*`2diff`i''*`var') +"
					}
				}			
				
			}	
			
			if "`linpred_time_diff2'"=="" {
				local linpred_time_diff2 "0 +"
			}
			qui gen double `newvarname' = `linpred_time_diff2' 0 if `touse'
		}
	
	//====================================================================================================================================================//
	// Hazard function - fitted 
	
		if "`hazard'"!="" & "`predopt'"=="fitted" {
			
			// Hazard scale model prediction 
			if "`smodel'"!="fpm" {
				local alpha_ith = 1
				if `e(current)' {			
					local assoc_pred "xb(alpha_`alpha_ith')*(predict(longitudinal fitted `predtime' `zeros' `atlist' blups(`tempblupnames'))) +"
					local `++alpha_ith'	
				}
				if `e(deriv)' {			
					local assoc_pred "`assoc_pred' xb(alpha_`alpha_ith')*(predict(dlongitudinal fitted `predtime' `zeros' `atlist' blups(`tempblupnames'))) +"
					local `++alpha_ith'	
				}		
				if `e(intassoc)' {
					local finaladd : word `e(n_re)' of `tempblupnames'
					if `e(nocoefficient)' {
						local assoc_pred "`assoc_pred' xb(alpha_`alpha_ith')*(`finaladd') +"
					}
					else local assoc_pred "`assoc_pred' xb(alpha_`alpha_ith')*([Longitudinal][_cons] + `finaladd') +"
					local `++alpha_ith'	
				}
				if `e(timeassoc)' {	//not available with splines
					local i = 1
					foreach re of numlist `e(sepassoc_timevar_index)' {
						local ind : word `i' of `e(sepassoc_timevar_pows)'
						local i2 = 1
						foreach fp of numlist `e(random_time)' {
							if `ind'==`fp' {
								local add`i2' : word `i2' of `tempblupnames'
								if `e(nocoefficient)' {
									local assoc_pred "`assoc_pred' xb(alpha_`alpha_ith')*(`add`i2'') +"
								}
								else local assoc_pred "`assoc_pred' xb(alpha_`alpha_ith')*([Longitudinal][_time_`re'] + `add`i2'') +"
								local `++alpha_ith'
							}
							local `++i2'
						}
						local `++i'
					}
				}
			
				if "`e(tvc)'"!="" local tvclinpred + xb(tvc)
			
				if "`smodel'"=="e" {		//Exponential
					qui predictnl double `newvarname' = exp(`assoc_pred' xb(ln_lambda) `tvclinpred') if `touse', `seciopt'			
				}
				else if "`smodel'"=="w" {	//Weibull
					qui predictnl double `newvarname' = exp(xb(ln_gamma)) * (`basesurvtime') ^ (exp(xb(ln_gamma))-1) *exp(`assoc_pred' xb(ln_lambda) `tvclinpred') if `touse', `seciopt'			
				}
				else if "`smodel'"=="g" {	//Gompertz
					qui predictnl double `newvarname' = exp(xb(gamma)*`basesurvtime') * exp(`assoc_pred' xb(ln_lambda) `tvclinpred') if `touse', `seciopt'			
				}
				else if "`smodel'"=="ww" {
					local xbcovs 0
					if "`e(surv_varlist)'"!="" local xbcovs xb(xb)
					local pmix invlogit(xb(logit_p_mix))
					local l1 exp(xb(ln_lambda1))
					local g1 exp(xb(ln_gamma1))
					local l2 exp(xb(ln_lambda2))
					local g2 exp(xb(ln_gamma2))				
					qui predictnl double `newvarname' = exp(`assoc_pred' `xbcovs' `tvclinpred') * (`pmix'*`l1'*`g1'*`basesurvtime'^(`g1'-1)*exp(-`l1'*`basesurvtime'^(`g1'))+(1-`pmix')*`l2'*`g2'*`basesurvtime'^(`g2'-1)*exp(-`l2'*`basesurvtime'^`g2'))/(`pmix'*exp(-`l1'*`basesurvtime'^`g1') + (1-`pmix')*exp(-`l2'*`basesurvtime'^`g2'))			
				}
				else if "`smodel'"=="we" {
					local xbcovs 0
					if "`e(surv_varlist)'"!="" local xbcovs xb(xb)
					local pmix invlogit(xb(logit_p_mix))
					local l1 exp(xb(ln_lambda1))
					local g1 exp(xb(ln_gamma1))
					local l2 exp(xb(ln_lambda2))
					qui predictnl double `newvarname' = exp(`assoc_pred' `xbcovs' `tvclinpred') * (`pmix'*`l1'*`g1'*`basesurvtime'^(`g1'-1)*exp(-`l1'*`basesurvtime'^(`g1'))+(1-`pmix')*`l2'*exp(-`l2'*`basesurvtime'))/(`pmix'*exp(-`l1'*`basesurvtime'^`g1') + (1-`pmix')*exp(-`l2'*`basesurvtime'))			
				}
				else if "`smodel'"=="rcs" {
					qui predictnl double `newvarname' = exp(`assoc_pred' xb(xb) `tvclinpred') if `touse', `seciopt'			
				}
			}
			// FPM prediction 
			else {
				local alpha_ith = 1
				local assoc_pred2
				if `e(current)' {
					local assoc_pred2 "xb(alpha_`alpha_ith')*predict(dlongitudinal fitted `predtime' `zeros' `atlist' blups(`tempblupnames')) +"
					local `++alpha_ith'	
				}
				if `e(deriv)' {
					local assoc_pred2 "`assoc_pred2' xb(alpha_`alpha_ith')*predict(ddlongitudinal fitted `predtime' `zeros' `atlist' blups(`tempblupnames')) +"
					local `++alpha_ith'	
				}
				qui predictnl double `newvarname' = (1/`basetime'*predict(cumhazard fitted `predtime' `zeros' `atlist' blups(`tempblupnames')))*(`assoc_pred2' xb(dxb)) if `touse', `seciopt'
			}
		}
	
	//==========================================================================================================================================================//
	// Cumulative hazard - fitted
	
		if ("`cumhazard'"!="" &"`predopt'"=="fitted") {

			// hazard scale -> quadrature
			if "`smodel'"!="fpm" & !`aft' {
				
				//get GK nodes and weights
				local Ngk = `e(gk)'`e(gl)'
				tempname knodes kweights
				if "`e(gk)'"!="" {
					gausskronrod`Ngk'
					mat `knodes' = r(knodes)
					mat `kweights' = r(kweights)
				}
				else {
					stjm_gaussquad, n(`e(gl)') legendre
					mat `knodes' = r(nodes)'
					mat `kweights' = r(weights)'
				}
				
				if (`e(current)' | `e(deriv)') | "`smodel'"=="rcs" {
					//timevars at each node
					forvalues i=1/`Ngk' {
						tempvar temptime`i'
						qui gen double `temptime`i'' = 0.5*`basetime'*(el(`knodes',1,`i')) + 0.5*`basetime' if `touse'
					}
				}
				
				//need other set of nodes at basesurvtime, then transformed for texp()
				if "`e(tvc)'"!="" {
					forvalues i=1/`Ngk' {
						tempvar temptimetvc`i'
						qui gen double `temptimetvc`i'' = 0.5*`basesurvtime'*(el(`knodes',1,`i')) + 0.5*`basesurvtime' if `touse'
												
						local texpfunc : subinstr local texpcopy "_t" "`temptimetvc`i''", all				
						qui replace `temptimetvc`i'' = `texpfunc' if `touse'
						local tvcnodevars `tvcnodevars' `temptimetvc`i''
					}									
				
				}				
				
				local a = 1
				if (`e(current)' | `e(deriv)') {
					
					if (`e(current)')  {
						tempvar alpha_`a'
						qui predictnl double `alpha_`a'' = xb(alpha_`a') if `touse'==1
					
						//calculate longitudinal fitted values at each set of GK nodes
						forvalues i=1/`Ngk' {
							local eb_adds
							tempvar tempfitvals`i'
							//fixed component
							qui predict `tempfitvals`i'' if `touse', xb longitudinal timevar(`temptime`i'') `zeros' `atlist'
							//add blups * timevars
							//FPs
							if (`e(fpind)') {
								local ind = 1
								if `e(n_re)' > 1 {
									forvalues j = 1/`e(npows)' {
										if (`rand_ind'[1,`j']==1) {
											local revar : word `ind' of `tempblupnames'
											if (`fp_pows'[1,`j']!=0) {
												local eb_adds "+ `revar'*`temptime`i''^(`fp_pows'[1,`j']) `eb_adds'"
											}
											else {
												local eb_adds "+ `revar'*log(`temptime`i'') `eb_adds'"
											}										
											local `++ind'
										}
									}
								}
							}
							// Splines
							else {
								if "`e(random_time)'"!="" {
									tempvar rand_spline_
									qui rcsgen `temptime`i'', knots(`e(rrcs_knots)') gen(`rand_spline_')
									forvalues j=1/`e(random_time)' {
										local revar : word `j' of `tempblupnames'
										local eb_adds "+ `revar'*`rand_spline_'`j' `eb_adds'"
									}
								}
							}
							// add random intercept
							local finaladd : word `e(n_re)' of `tempblupnames'
							local eb_adds "+ `finaladd' `eb_adds'"
							qui replace `tempfitvals`i'' = `tempfitvals`i'' `eb_adds' if `touse'
							//multiply by association parameter
							qui replace `tempfitvals`i'' = `tempfitvals`i'' * `alpha_`a''
							local templongnames "`templongnames' `tempfitvals`i''"
						}
						local `++a'
					}
					
					if (`e(deriv)') {
						/* alpha */
						tempvar alpha_`a'
						qui predictnl double `alpha_`a'' = xb(alpha_`a') if `touse'==1
					
						/* Calculate dlongitudinal fitted values at each set of GK nodes */
						forvalues i=1/`Ngk' {
							tempvar tempdfitvals`i'
							qui predict `tempdfitvals`i'' , fitted dlongitudinal timevar(`temptime`i'')	 `zeros' `atlist' blups(`tempblupnames')
							qui replace `tempdfitvals`i'' = `tempdfitvals`i'' * `alpha_`a''
							local tempdlongnames "`tempdlongnames' `tempdfitvals`i''"
						}
						local `++a'
					}
					
				}
				
				if (`e(intassoc)' | `e(timeassoc)') {
					if (`e(intassoc)') {				
						tempvar intassoc
						local finaladd : word `e(n_re)' of `tempblupnames'
						if `e(nocoefficient)' {
							qui predictnl double `intassoc' = xb(alpha_`a')*(`finaladd') if `touse'==1
						}
						else qui predictnl double `intassoc' = xb(alpha_`a')*([Longitudinal][_cons] + `finaladd') if `touse'==1
						local `++a'
					}	
					if (`e(timeassoc)') {
						local i = 1
						foreach re of numlist `e(sepassoc_timevar_index)' {
							local ind : word `i' of `e(sepassoc_timevar_pows)'
							local i2 = 1
							foreach fp of numlist `e(random_time)' {
								if `ind'==`fp' {
									local add`i2' : word `i2' of `tempblupnames'
									if `e(nocoefficient)' {
										local assoc_pred4 "`assoc_pred4' xb(alpha_`a')*(`add`i2'') +"
									}
									else local assoc_pred4 "`assoc_pred4' xb(alpha_`a')*([Longitudinal][_time_`re'] + `add`i2'') +"
									local `++a'
								}
								local `++i2'
							}
							local `++i'
						}
						tempvar timeassoc
						qui predictnl double `timeassoc' = `assoc_pred4' 0 if `touse'==1					
					}		
				}
				
				if ("`smodel'"=="e" | "`smodel'"=="g" | "`smodel'"=="w") {
					// Lambda and gamma
					tempvar l1tempvar
					qui predictnl double `l1tempvar' = xb(ln_lambda) if `touse'==1
					qui replace `l1tempvar' = exp(`l1tempvar') if `touse'==1
					if "`smodel'"=="w" {
						tempname g1
						scalar `g1' = exp([ln_gamma][_cons])
					}
					else if "`smodel'"=="g" {
						tempname g1
						scalar `g1' = [gamma][_cons]
					}
				}
				else if "`smodel'"=="ww" {
					if "`e(surv_varlist)'"!="" {
						tempvar l1tempvar
						qui predictnl double `l1tempvar' = xb(xb) if `touse'==1
					}
					tempname l1 l2 g1 g2 pmix
					scalar `l1'   = exp([ln_lambda1][_cons])
					scalar `l2'   = exp([ln_lambda2][_cons])
					scalar `g1'   = exp([ln_gamma1][_cons])
					scalar `g2'   = exp([ln_gamma2][_cons])
					scalar `pmix' = invlogit([logit_p_mix][_cons])
				}
				else if "`smodel'"=="we" {
					if "`e(surv_varlist)'"!="" {
						tempvar l1tempvar
						qui predictnl double `l1tempvar' = xb(xb) if `touse'==1
					}
					tempname l1 l2 g1 g2 pmix
					scalar `l1'   = exp([ln_lambda1][_cons])
					scalar `l2'   = exp([ln_lambda2][_cons])
					scalar `g1'   = exp([ln_gamma1][_cons])
					scalar `pmix' = invlogit([logit_p_mix][_cons])
				
				}
				else if "`smodel'"=="rcs" {
					forvalues j = 1/`Ngk' {
						cap drop _rcs*
						tempvar logtemptime`j' splinepred`j'
						qui gen double `logtemptime`j'' = log(0.5*`basesurvtime'*(el(`knodes',1,`j')) + 0.5*`basesurvtime') if `touse'
						qui rcsgen `logtemptime`j'', knots(`e(bhknots)') gen(_rcs) `rmat'
						qui predictnl double `splinepred`j'' = xb(xb)
						local splinevars `splinevars' `splinepred`j''
					}
				}
				qui gen double `newvarname' = .
				mata: stjm_cumhaz_fitted()
			}
			/* FPM prediction */
			else {			
				local alpha_ith = 1
				if `e(current)' {			
					local assoc_pred3 "xb(alpha_`alpha_ith')*(predict(longitudinal fitted `predtime' `zeros' `atlist' blups(`tempblupnames'))) +"
					local `++alpha_ith'	
				}
				if `e(deriv)' {			
					local assoc_pred3 "`assoc_pred3' xb(alpha_`alpha_ith')*(predict(dlongitudinal fitted `predtime' `zeros' `atlist' blups(`tempblupnames'))) +"
					local `++alpha_ith'	
				}		
				if `e(intassoc)' {
					local finaladd : word `e(n_re)' of `tempblupnames'				
					if `e(nocoefficient)' {
						local assoc_pred3 "`assoc_pred3' xb(alpha_`alpha_ith')*(`finaladd') +"
					}
					else local assoc_pred3 "`assoc_pred3' xb(alpha_`alpha_ith')*([Longitudinal][_cons] + `finaladd') +"
					local `++alpha_ith'	
				}
				if `e(timeassoc)' {
					local i = 1
					foreach re of numlist `e(sepassoc_timevar_index)' {
						local ind : word `i' of `e(sepassoc_timevar_pows)'
						local i2 = 1
						foreach fp of numlist `e(random_time)' {
							if `ind'==`fp' {
								local add`i2' : word `i2' of `tempblupnames'
								if `e(nocoefficient)' { 
									local assoc_pred3 "`assoc_pred3' xb(alpha_`alpha_ith')*(`add`i2'') +"
								}
								else local assoc_pred3 "`assoc_pred3' xb(alpha_`alpha_ith')*([Longitudinal][_time_`re'] + `add`i2'') +"
								local `++alpha_ith'
							}
							local `++i2'
						}
						local `++i'
					}
				}
				
				if "`smodel'"=="fpm" {
					qui predictnl double `newvarname' = `assoc_pred3' xb(xb) if `touse'==1	
					qui replace `newvarname' = exp(`newvarname') if `touse'==1
				}
				else {
				
					if "`smodel'"=="llogistic" {
						local aftsurv (1 + (exp(-xb(beta))*`basesurvtime')^(1/exp(xb(ln_gamma))))^(-1)
						predictnl double `newvarname' = -log(`aftsurv') if `touse'==1
					}
					else if "`smodel'"=="lnormal" {
						local aftsurv 1 - normal((log(`basesurvtime')-xb(mu))/exp(xb(ln_sigma)))
						predictnl double `newvarname' = -log(`aftsurv') if `touse'==1
					}
					else if "`smodel'"=="gamma" {
						tempvar kapp2
						predictnl double `kapp2' = xb(kappa)
						
						local gamma2 abs(`kapp2')^(-2)
						local z2 sign(`kapp2')*(log(`basesurvtime')-xb(mu))/exp(ln_sigma)
						local u2 (`gamma2')*exp(abs(`kapp2'*(`z2')))
						
						predictnl double `newvarname' = -log(1 - gammap(`gamma2',`u2')) if `touse'==1 & `kapp2'>0
						predictnl double `newvarname' = -log(1-normal(`z2')) if `touse'==1 & `kapp2'==0
						predictnl double `newvarname' = -log(gammap(`gamma2',`u2')) if `touse'==1 & `kapp2'<0
					}			
					
				}
			}
		}
	
	//==========================================================================================================================================================//
	// Martingales and deviance - fitted 
	
		if ("`martingale'"!="" | "`deviance'"!="") {
			if "`predopt'"=="fitted" local useblups blups(`tempblupnames')
			else local useblups
			if "`smodel'"!="fpm" {
				tempvar ch res
				qui predictnl double `res' = _d + log(predict(survival `predopt' `predtime' `zeros' `atlist' `useblups')) if `touse'==1
				if "`deviance'"!="" {
					qui gen double `newvarname' = sign(`res')*sqrt( -2*(`res' + _d*(log(_d -`res')))) if `touse'==1
				}
				else rename `res' `newvarname'	//martingales
			}
			else {
				tempvar ch res
				qui predictnl double `res' = _d + log(predict(survival `predopt' `predtime' `zeros' `atlist' `useblups')) if `touse'==1
				if "`deviance'"!="" {
					qui gen double `newvarname' = sign(`res')*sqrt( -2*(`res' + _d*(log(_d -`res')))) if `touse'==1
				}
				else rename `res' `newvarname'
			}	
		}
	
	//==========================================================================================================================================================//
	// Survival function - fitted 

		if "`survival'"!="" & "`predopt'"=="fitted" & !`aft' {
			qui predictnl double `newvarname' = predict(cumhazard fitted `predtime' `zeros' `atlist' `postblups' blups(`tempblupnames')) if `touse'==1
			qui replace `newvarname' = exp(-`newvarname') if `touse'==1
		}
		else if "`survival'"!="" & "`predopt'"=="fitted" & `aft' {
		
		
		}
		
	//==========================================================================================================================================================//
	// Cumhazard/Survival predictions - xb 

	if wordcount(`"`survival' `cumhazard'"') > 0 & "`predopt'"=="xb" {
	
		local prediction "`survival'`cumhazard'"
		qui gen double `newvarname' = . if `touse'

		// MVN draws
		forvalues i=1/`e(n_re)' {
			tempvar draw`i'
			local draws "`draws' `draw`i''"
		}
		cap set obs `m'
		qui replace `touse' = 0 if `touse'!=1
		qui drawnorm `draws', cov(`vcv') 
		
		tempvar sim_ind
		qui gen `sim_ind' = _n<=`nm'	// DO NOT PUT TOUSE HERE 

		// Matrix to hold random FP powers
		if `e(n_re)'>1 & `e(fpind)' {
			tempname fp_randpows
			mat `fp_randpows' = J(1,`=`e(n_re)'-1',.)
			local j = 1
			forvalues i = 1/`e(npows)' {
				if `rand_ind'[1,`i']==1 {
					mat `fp_randpows'[1,`j'] = `fp_pows'[1,`i']
					local j = `j' + 1
				}
			}
		}
		
		//hazard scale models
		if "`smodel'"!="fpm" & !`aft' {

			//get GK nodes and weights
			local Ngk = `e(gk)'`e(gl)'
			tempname knodes kweights
			if "`e(gk)'"!="" {
				gausskronrod`e(gk)'
				mat `knodes' = r(knodes)
				mat `kweights' = r(kweights)
			}
			else {
				stjm_gaussquad, n(`e(gl)') legendre
				mat `knodes' = r(nodes)'
				mat `kweights' = r(weights)'
			}			
			
			if (`e(current)' | `e(deriv)') | "`smodel'"=="rcs" {
				//timevars at each node
				forvalues i=1/`Ngk' {
					tempvar temptime`i'
					qui gen double `temptime`i'' = 0.5*`basetime'*(el(`knodes',1,`i')) + 0.5*`basetime' if `touse'
				}
			}		
						
			//need other set of nodes at basesurvtime, then transformed for texp()
			if "`e(tvc)'"!="" {
				forvalues i=1/`Ngk' {
					tempvar temptimetvc`i'
					qui gen double `temptimetvc`i'' = 0.5*`basesurvtime'*(el(`knodes',1,`i')) + 0.5*`basesurvtime' if `touse'
											
					local texpfunc : subinstr local texpcopy "_t" "`temptimetvc`i''", all				
					qui replace `temptimetvc`i'' = `texpfunc' if `touse'
					local tvcnodevars `tvcnodevars' `temptimetvc`i''
				}
			
			}				
			
			// Predict survival parameters 
			if "`smodel'"=="e" {
				tempvar l1tempvar
				qui predictnl double `l1tempvar' = xb(ln_lambda) if `touse'
				qui replace `l1tempvar' = exp(`l1tempvar')
			}
			else if "`smodel'"=="w" {
				tempvar l1tempvar
				qui predictnl double `l1tempvar' = xb(ln_lambda) if `touse'
				qui replace `l1tempvar' = exp(`l1tempvar')
				tempname g1
				scalar `g1' = exp([ln_gamma][_cons])
			}
			else if "`smodel'"=="g" {
				tempvar l1tempvar
				qui predictnl double `l1tempvar' = xb(ln_lambda) if `touse'
				qui replace `l1tempvar' = exp(`l1tempvar')
				tempname g1
				scalar `g1' = [gamma][_cons]
			}
			else if "`smodel'"=="ww" {
				if "`e(surv_varlist)'"!="" {
					tempvar l1tempvar
					qui predictnl double `l1tempvar' = xb(xb) if `touse'==1
				}
				tempname l1 l2 g1 g2 pmix
				scalar `l1'   = exp([ln_lambda1][_cons])
				scalar `l2'   = exp([ln_lambda2][_cons])
				scalar `g1'   = exp([ln_gamma1][_cons])
				scalar `g2'   = exp([ln_gamma2][_cons])
				scalar `pmix' = invlogit([logit_p_mix][_cons])
			}
			else if "`smodel'"=="we" {
				if "`e(surv_varlist)'"!="" {
					tempvar l1tempvar
					qui predictnl double `l1tempvar' = xb(xb) if `touse'==1
				}
				tempname l1 l2 g1 pmix
				scalar `l1'   = exp([ln_lambda1][_cons])
				scalar `l2'   = exp([ln_lambda2][_cons])
				scalar `g1'   = exp([ln_gamma1][_cons])
				scalar `pmix' = invlogit([logit_p_mix][_cons])
			}
			else if "`smodel'"=="rcs" {
				forvalues j = 1/`Ngk' {
					cap drop _rcs*
					tempvar logtemptime`j' splinepred`j'
					qui gen double `logtemptime`j'' = log(0.5*`basesurvtime'*(el(`knodes',1,`j')) + 0.5*`basesurvtime') if `touse'
					qui rcsgen `logtemptime`j'' if `touse', knots(`e(bhknots)') gen(_rcs) `rmat'
					qui predictnl double `splinepred`j'' = xb(xb) if `touse'
					local splinevars `splinevars' `splinepred`j''
				}
			}
			
			// Temporary variables to hold longitudinal xb predictions multiplied by associations and passed to Mata
			local alpha_ith = 1
			if `e(current)' | `e(deriv)' {
							
				if `e(current)' {
					tempvar alpha_`alpha_ith'
					qui predictnl double `alpha_`alpha_ith'' = xb(alpha_`alpha_ith') if `touse'==1
					local alphas "`alpha_`alpha_ith''"
					//Calculate longitudinal fixed values at each set of GK nodes
					forvalues i=1/`Ngk' {
						tempvar tempfitvals`i'
						qui predict `tempfitvals`i'' , xb longitudinal timevar(`temptime`i'') `zeros' `atlist'
						qui replace `tempfitvals`i'' = `tempfitvals`i'' * `alpha_`alpha_ith''
						local templongnames "`templongnames' `tempfitvals`i''"
					}
					local `++alpha_ith'
				}
				
				if `e(deriv)' {
					tempvar alpha_`alpha_ith'
					qui predictnl double `alpha_`alpha_ith'' = xb(alpha_`alpha_ith') if `touse'==1
					local alphas "`alphas' `alpha_`alpha_ith''"

					//Calculate dlongitudinal fitted values at each set of GK nodes 
					forvalues i=1/`Ngk' {
						tempvar tempdfitvals`i'
						qui predict `tempdfitvals`i'' , xb dlongitudinal timevar(`temptime`i'') `zeros' `atlist'
						qui replace `tempdfitvals`i'' = `tempdfitvals`i'' * `alpha_`alpha_ith''
						local tempdlongnames "`tempdlongnames' `tempdfitvals`i''"
					}
					local `++alpha_ith'
				}
				
			}

			if `e(intassoc)' {
				tempvar alpha_`alpha_ith' fixed_coef_int
				qui predictnl double `alpha_`alpha_ith'' = xb(alpha_`alpha_ith') if `touse'==1
				local alphas "`alphas' `alpha_`alpha_ith''"
				if `e(nocoefficient)' {
					qui gen double `fixed_coef_int' = 0 if `touse'
				}
				else qui gen double `fixed_coef_int' = [Longitudinal][_cons] * `alpha_`alpha_ith'' if `touse'
				local `++alpha_ith'
			}
			
			if `e(timeassoc)' {
				tempvar fixed_coef
				gen double `fixed_coef' = 0 if `touse'
				foreach var in `e(sepassoc_timevar_index)' {
					tempvar alpha_`alpha_ith' fixed_coef_`alpha_ith'
					qui predictnl double `alpha_`alpha_ith'' = xb(alpha_`alpha_ith') if `touse'==1
					local alphas "`alphas' `alpha_`alpha_ith''"
					if !`e(nocoefficient)' {
						qui replace `fixed_coef' = `fixed_coef' + [Longitudinal][_time_`var'] * `alpha_`alpha_ith'' if `touse'==1
					}
					local `++alpha_ith'
				}
			}
			
			mata: stjm_cumhaz_surv_xb()
		}
		// FPM prediction
		else if "`smodel'"=="fpm" & !`aft' {
			// spline linear predictor
			tempvar xb
			qui predictnl double `xb' = xb(xb) if `touse'==1

			local alpha_ith = 1
			if (`e(current)') {
				tempvar alpha_`alpha_ith'
				qui predictnl double `alpha_`alpha_ith'' = xb(alpha_`alpha_ith') if `touse'==1
				local alphas "`alpha_`alpha_ith''"
				
				// Calculate longitudinal fixed values at basetime
				tempvar tempfitvals
				qui predict `tempfitvals' , xb longitudinal timevar(`basetime') `zeros' `atlist'
				qui replace `tempfitvals' = `tempfitvals' * `alpha_`alpha_ith''
				// Random effects design matrix in e(rand_timevars)
				tempvar cons
				gen byte `cons' = 1 if `touse'
				local templongvars "`e(rand_timevars)' `cons'"
				local `++alpha_ith'
			}
			if `e(deriv)' {
				tempvar alpha_`alpha_ith'
				qui predictnl double `alpha_`alpha_ith'' = xb(alpha_`alpha_ith') if `touse'==1
				local alphas "`alphas' `alpha_`alpha_ith''"

				// Calculate dlongitudinal xb values
				tempvar tempdfitvals
				qui predict `tempdfitvals' , xb dlongitudinal timevar(`basetime') `zeros' `atlist'
				qui replace `tempdfitvals' = `tempdfitvals' * `alpha_`alpha_ith''
				
				// Build and pass derivative of random time powers DM to Mata
				forvalues i=1/`=`e(n_re)'-1' {
					tempvar deriv_dm_`i'
					if (`fp_randpows'[1,`i']!=0) {
						gen double `deriv_dm_`i'' = (`fp_randpows'[1,`i'])*(`basetime')^(`fp_randpows'[1,`i']-1)
					}
					else gen double `deriv_dm_`i'' = 1/`basetime'
					local  deriv_var_names "`deriv_var_names' `deriv_dm_`i''"
				}
				tempvar null
				gen byte `null' = 0 if `touse'
				local deriv_var_names "`deriv_var_names' `null'"				
				local `++alpha_ith'
			}
			if `e(intassoc)' {
				tempvar alpha_`alpha_ith' fixed_coef_int
				qui predictnl double `alpha_`alpha_ith'' = xb(alpha_`alpha_ith') if `touse'==1
				local alphas "`alphas' `alpha_`alpha_ith''"
				if `e(nocoefficient)' {
					qui gen double `fixed_coef_int' = 0 if `touse'
				}
				else qui gen double `fixed_coef_int' = [Longitudinal][_cons] * `alpha_`alpha_ith'' if `touse'
				local `++alpha_ith'
			}
			if `e(timeassoc)' {
				tempvar fixed_coef
				gen double `fixed_coef' = 0 if `touse'
				foreach var in `e(sepassoc_timevar_index)' {
					tempvar alpha_`alpha_ith'
					qui predictnl double `alpha_`alpha_ith'' = xb(alpha_`alpha_ith') if `touse'==1
					local alphas "`alphas' `alpha_`alpha_ith''"
					if !`e(nocoefficient)' {
						qui replace `fixed_coef' = `fixed_coef' + [Longitudinal][_time_`var'] * `alpha_`alpha_ith'' if `touse'==1
					}
					local `++alpha_ith'
				}
			}
			mata: stjm_cumhaz_surv_xb_fpm()
		}
		//AFT survival function
		else {
		
			//survival parameters
			tempvar xb
			tempname g1
			if "`smodel'"=="llogistic" {
				qui predictnl double `xb' = exp(-xb(beta)) if `touse'==1
				scalar `g1' = exp([ln_gamma][_cons])
			
			}
			else if "`smodel'"=="lnormal" {
				qui predictnl double `xb' = xb(mu) if `touse'==1
				scalar `g1' = exp([ln_sigma][_cons])
			}
			else {
				qui predictnl double `xb' = xb(mu) if `touse'==1
				scalar `g1' = exp([ln_sigma][_cons])
				tempname kapp
				scalar `kapp' = [kappa][_cons]
			}
			
			//associations
			local alpha_ith = 1
			if (`e(current)') {
				tempvar alpha_`alpha_ith'
				qui predictnl double `alpha_`alpha_ith'' = xb(alpha_`alpha_ith') if `touse'==1
				local alphas "`alpha_`alpha_ith''"
				
				// Calculate longitudinal fixed values at basetime
				tempvar tempfitvals
				qui predict `tempfitvals' , xb longitudinal timevar(`basetime') `zeros' `atlist'
				qui replace `tempfitvals' = `tempfitvals' * `alpha_`alpha_ith''
				// Random effects design matrix in e(rand_timevars)
				tempvar cons
				gen byte `cons' = 1 if `touse'
				local templongvars "`e(rand_timevars)' `cons'"
				local `++alpha_ith'
			}
			if `e(deriv)' {
				tempvar alpha_`alpha_ith'
				qui predictnl double `alpha_`alpha_ith'' = xb(alpha_`alpha_ith') if `touse'==1
				local alphas "`alphas' `alpha_`alpha_ith''"

				// Calculate dlongitudinal xb values
				tempvar tempdfitvals
				qui predict `tempdfitvals' , xb dlongitudinal timevar(`basetime') `zeros' `atlist'
				qui replace `tempdfitvals' = `tempdfitvals' * `alpha_`alpha_ith''
				
				// Build and pass derivative of random time powers DM to Mata
				forvalues i=1/`=`e(n_re)'-1' {
					tempvar deriv_dm_`i'
					if (`fp_randpows'[1,`i']!=0) {
						gen double `deriv_dm_`i'' = (`fp_randpows'[1,`i'])*(`basetime')^(`fp_randpows'[1,`i']-1)
					}
					else gen double `deriv_dm_`i'' = 1/`basetime'
					local  deriv_var_names "`deriv_var_names' `deriv_dm_`i''"
				}
				tempvar null
				gen byte `null' = 0 if `touse'
				local deriv_var_names "`deriv_var_names' `null'"				
				local `++alpha_ith'
			}
			if `e(intassoc)' {
				tempvar alpha_`alpha_ith' fixed_coef_int
				qui predictnl double `alpha_`alpha_ith'' = xb(alpha_`alpha_ith') if `touse'==1
				local alphas "`alphas' `alpha_`alpha_ith''"
				if `e(nocoefficient)' {
					qui gen double `fixed_coef_int' = 0 if `touse'
				}
				else qui gen double `fixed_coef_int' = [Longitudinal][_cons] * `alpha_`alpha_ith'' if `touse'
				local `++alpha_ith'
			}
			if `e(timeassoc)' {
				tempvar fixed_coef
				gen double `fixed_coef' = 0 if `touse'
				foreach var in `e(sepassoc_timevar_index)' {
					tempvar alpha_`alpha_ith'
					qui predictnl double `alpha_`alpha_ith'' = xb(alpha_`alpha_ith') if `touse'==1
					local alphas "`alphas' `alpha_`alpha_ith''"
					if !`e(nocoefficient)' {
						qui replace `fixed_coef' = `fixed_coef' + [Longitudinal][_time_`var'] * `alpha_`alpha_ith'' if `touse'==1
					}
					local `++alpha_ith'
				}
			}
			mata: stjm_surv_xb_aft()
		
		}
				
	}	
		
	//======================================================================================================================================================//
	// Hazard function - xb

	if "`hazard'"!="" & "`predopt'"=="xb" {
	
		qui gen double `newvarname' = . if `touse'

		// MVN draws
		forvalues i=1/`e(n_re)' {
			tempvar draw`i'
			local draws "`draws' `draw`i''"
		}
		cap set obs `m'
		qui replace `touse' = 0 if `touse'!=1
		qui drawnorm `draws', cov(`vcv') 
		
		tempvar sim_ind
		qui gen `sim_ind' = _n<=`nm'	// DO NOT PUT TOUSE HERE 
		
		// Matrix to hold random FP powers
		if (`e(n_re)'>1 & `e(fpind)') {
			tempname fp_randpows
			mat `fp_randpows' = J(1,`=`e(n_re)'-1',.)
			local j = 1
			forvalues i = 1/`e(npows)' {
				if `rand_ind'[1,`i']==1 {
					mat `fp_randpows'[1,`j'] = `fp_pows'[1,`i']
					local j = `j' + 1
				}
			}
		}

		if "`smodel'"!="fpm" & !`aft' {
			
			//TVC's
			if "`e(tvc)'"!="" {
				tempvar tvctempvar
				qui predictnl double `tvctempvar' = xb(tvc) if `touse'
				qui replace `tvctempvar' = exp(`tvctempvar') if `touse'			
			}
						
			// Predict survival parameters 
			if "`smodel'"=="e" {
				tempvar l1tempvar
				qui predictnl double `l1tempvar' = xb(ln_lambda) if `touse'
				qui replace `l1tempvar' = exp(`l1tempvar')
			}
			else if "`smodel'"=="w" {
				tempvar l1tempvar
				qui predictnl double `l1tempvar' = xb(ln_lambda) if `touse'
				qui replace `l1tempvar' = exp(`l1tempvar')
				tempname g1
				scalar `g1' = exp([ln_gamma][_cons])
			}
			else if "`smodel'"=="g" {
				tempvar l1tempvar
				qui predictnl double `l1tempvar' = xb(ln_lambda) if `touse'
				qui replace `l1tempvar' = exp(`l1tempvar')
				tempname g1
				scalar `g1' = [gamma][_cons]
			}
			else if "`smodel'"=="ww" {
				if "`e(surv_varlist)'"!="" {
					tempvar l1tempvar
					qui predictnl double `l1tempvar' = xb(xb) if `touse'==1
				}
				tempname l1 l2 g1 g2 pmix
				scalar `l1'   = exp([ln_lambda1][_cons])
				scalar `l2'   = exp([ln_lambda2][_cons])
				scalar `g1'   = exp([ln_gamma1][_cons])
				scalar `g2'   = exp([ln_gamma2][_cons])
				scalar `pmix' = invlogit([logit_p_mix][_cons])
			}
			else if "`smodel'"=="we" {
				if "`e(surv_varlist)'"!="" {
					tempvar l1tempvar
					qui predictnl double `l1tempvar' = xb(xb) if `touse'==1
				}
				tempname l1 l2 g1 pmix
				scalar `l1'   = exp([ln_lambda1][_cons])
				scalar `l2'   = exp([ln_lambda2][_cons])
				scalar `g1'   = exp([ln_gamma1][_cons])
				scalar `pmix' = invlogit([logit_p_mix][_cons])
			}
			else if "`smodel'"=="rcs" {
				tempvar xb
				qui predictnl double `xb' = xb(xb) if `touse'
			}

			//get alphas and longitudinal fixed predicitons
			local alpha_ith = 1
			if `e(current)'  {
				tempvar alpha_`alpha_ith'
				qui predictnl double `alpha_`alpha_ith'' = xb(alpha_`alpha_ith') if `touse'==1
				local alphas "`alpha_`alpha_ith''"
				// Calculate longitudinal fixed fitted values at basetime
				tempvar tempfitvals
				qui predict `tempfitvals' , xb longitudinal timevar(`basetime') `zeros' `atlist'
				qui replace `tempfitvals' = `tempfitvals' * `alpha_`alpha_ith''
				// Random effects design matrix in e(rand_timevars)
				tempvar cons
				gen byte `cons' = 1 if `touse'
				local templongvars "`e(rand_timevars)' `cons'"
				local `++alpha_ith'
			}
			if `e(deriv)' {
				tempvar alpha_`alpha_ith'
				qui predictnl double `alpha_`alpha_ith'' = xb(alpha_`alpha_ith') if `touse'==1
				local alphas "`alphas' `alpha_`alpha_ith''"
				// Calculate dlongitudinal xb values
				tempvar tempdfitvals
				qui predict `tempdfitvals' , xb dlongitudinal timevar(`basetime') `zeros' `atlist'
				qui replace `tempdfitvals' = `tempdfitvals' * `alpha_`alpha_ith''		//multiply by association parameter
				
				// Build and pass derivative of random time powers DM to Mata
				forvalues i=1/`=`e(n_re)'-1' {
					tempvar deriv_dm_`i'
					if (`fp_randpows'[1,`i']!=0) {
						gen double `deriv_dm_`i'' = (`fp_randpows'[1,`i'])*(`basetime')^(`fp_randpows'[1,`i']-1)
					}
					else gen double `deriv_dm_`i'' = 1/`basetime'
					local  deriv_var_names "`deriv_var_names' `deriv_dm_`i''"
				}				
				tempvar null
				gen byte `null' = 0 if `touse'
				local deriv_var_names "`deriv_var_names' `null'"				
				local `++alpha_ith'
			}
			if `e(intassoc)' {
				tempvar alpha_`alpha_ith' fixed_coef_int
				qui predictnl double `alpha_`alpha_ith'' = xb(alpha_`alpha_ith') if `touse'==1
				local alphas "`alphas' `alpha_`alpha_ith''"
				if `e(nocoefficient)' {
					qui gen double `fixed_coef_int' = 0 if `touse'
				}
				else qui gen double `fixed_coef_int' = [Longitudinal][_cons] * `alpha_`alpha_ith'' if `touse'
				local `++alpha_ith'
			}
			if `e(timeassoc)' {
				tempvar fixed_coef
				gen double `fixed_coef' = 0 if `touse'
				foreach var in `e(sepassoc_timevar_index)' {
					tempvar alpha_`alpha_ith'
					qui predictnl double `alpha_`alpha_ith'' = xb(alpha_`alpha_ith') if `touse'==1
					local alphas "`alphas' `alpha_`alpha_ith''"
					if !`e(nocoefficient)' {
						qui replace `fixed_coef' = `fixed_coef' + [Longitudinal][_time_`var'] * `alpha_`alpha_ith'' if `touse'==1
					}
					local `++alpha_ith'
				}
			}
			mata: stjm_haz_xb()
		}
		else if "`smodel'"=="fpm" &  & !`aft' {
		
			local alpha_ith = 1
			// Predict survival parameters 
			tempvar xb dxb
			qui predictnl double `xb' = xb(xb)  if `touse'==1
			qui predictnl double `dxb' = xb(dxb) if `touse'==1

			if `e(current)' | `e(deriv)' {
			
				tempvar tempdfitvals
				qui predict `tempdfitvals' , xb dlongitudinal timevar(`basetime') `zeros' `atlist'
				
				// Build and pass derivative of random time powers DM to Mata
				if `e(n_re)'>1 {
					forvalues i=1/`=`e(n_re)'-1' {
						tempvar deriv_dm_`i'
						if (`fp_randpows'[1,`i']!=0) {
							qui gen double `deriv_dm_`i'' = (`fp_randpows'[1,`i'])*(`basetime')^(`fp_randpows'[1,`i']-1)
						}
						else qui gen double `deriv_dm_`i'' = 1/`basetime'
						local  deriv_var_names "`deriv_var_names' `deriv_dm_`i''"
					}
				}
				tempvar null
				gen byte `null' = 0 if `touse'
				local deriv_var_names "`deriv_var_names' `null'"				

				if `e(current)' {
					tempvar alpha_`alpha_ith'
					qui predictnl double `alpha_`alpha_ith'' = xb(alpha_`alpha_ith') if `touse'==1
					local alphas "`alpha_`alpha_ith''"
					/* Calculate longitudinal fixed fitted values at basetime */
					tempvar tempfitvals
					qui predict `tempfitvals' , xb longitudinal timevar(`basetime') `zeros' `atlist'
					qui replace `tempfitvals' = `tempfitvals' * `alpha_`alpha_ith''
					/* derivative */
					tempvar tempdfitvalsc
					qui gen double `tempdfitvalsc' = `tempdfitvals' * `alpha_`alpha_ith''
					// Random effects design matrix in e(rand_timevars)
					tempvar cons
					qui gen byte `cons' = 1 if `touse'
					local templongvars "`e(rand_timevars)' `cons'"
					local `++alpha_ith'
				}

				if `e(deriv)' {
					tempvar alpha_`alpha_ith'
					qui predictnl double `alpha_`alpha_ith'' = xb(alpha_`alpha_ith') if `touse'==1
					local alphas "`alphas' `alpha_`alpha_ith''"
					
					/* derivative */
					tempvar tempdfitvalsd
					qui gen double `tempdfitvalsd' = `tempdfitvals' * `alpha_`alpha_ith''		//multiply by association parameter

					/* Calculate second derivative longitudinal fixed fitted values at basetime */
					tempvar tempddfitvals
					qui predict `tempddfitvals' , xb ddlongitudinal timevar(`basetime') `zeros' `atlist'
					qui replace `tempddfitvals' = `tempddfitvals' * `alpha_`alpha_ith''		//multiply by association parameter

					/* Build and pass second derivative of random time powers DM to Mata */
					if `e(n_re)'>1 {
						forvalues i=1/`=`e(n_re)'-1' {
							tempvar deriv2_dm_`i'
							if (`fp_randpows'[1,`i']==0) {
								qui gen double `deriv2_dm_`i'' = -1/(`basetime'^2)
							}
							else if (`fp_randpows'[1,`i']==1) {
								qui gen double `deriv2_dm_`i'' = 0
							}
							else {
								qui gen double `deriv2_dm_`i'' = (`fp_randpows'[1,`i']-1)*(`fp_randpows'[1,`i'])*(`basetime')^(`fp_randpows'[1,`i']-2)
							}
							local deriv2_var_names "`deriv2_var_names' `deriv2_dm_`i''"
						}
					}
					local deriv2_var_names "`deriv2_var_names' `null'"
					local `++alpha_ith'
				}
				
			}
			
			if `e(intassoc)' {
				tempvar alpha_`alpha_ith' fixed_coef_int
				qui predictnl double `alpha_`alpha_ith'' = xb(alpha_`alpha_ith') if `touse'==1
				local alphas "`alphas' `alpha_`alpha_ith''"
				if `e(nocoefficient)' {
					qui gen double `fixed_coef_int' = 0 if `touse'
				}
				else qui gen double `fixed_coef_int' = [Longitudinal][_cons] * `alpha_`alpha_ith'' if `touse'
				local `++alpha_ith'
			}
			
			if `e(timeassoc)' {
				tempvar fixed_coef
				gen double `fixed_coef' = 0 if `touse'
				foreach var in `e(sepassoc_timevar_index)' {
					tempvar alpha_`alpha_ith'
					qui predictnl double `alpha_`alpha_ith'' = xb(alpha_`alpha_ith') if `touse'==1
					local alphas "`alphas' `alpha_`alpha_ith''"
					if !`e(nocoefficient)' {
						qui replace `fixed_coef' = `fixed_coef' + [Longitudinal][_time_`var'] * `alpha_`alpha_ith'' if `touse'==1
					}
					local `++alpha_ith'
				}
			}
			mata: stjm_haz_xb_fpm()
		}
		//aft
		else {
		
			//survival parameters
			tempvar xb
			tempname g1
			if "`smodel'"=="llogistic" {
				qui predictnl double `xb' = exp(-xb(beta)) if `touse'==1
				scalar `g1' = exp([ln_gamma][_cons])
			
			}
			else if "`smodel'"=="lnormal" {
				qui predictnl double `xb' = xb(mu) if `touse'==1
				scalar `g1' = exp([ln_sigma][_cons])
			}
			else {
				qui predictnl double `xb' = xb(mu) if `touse'==1
				scalar `g1' = exp([ln_sigma][_cons])
				tempname kapp
				scalar `kapp' = [kappa][_cons]
			}
			
			//associations
			local alpha_ith = 1
			if (`e(current)') {
				tempvar alpha_`alpha_ith'
				qui predictnl double `alpha_`alpha_ith'' = xb(alpha_`alpha_ith') if `touse'==1
				local alphas "`alpha_`alpha_ith''"
				
				// Calculate longitudinal fixed values at basetime
				tempvar tempfitvals
				qui predict `tempfitvals' , xb longitudinal timevar(`basetime') `zeros' `atlist'
				qui replace `tempfitvals' = `tempfitvals' * `alpha_`alpha_ith''
				// Random effects design matrix in e(rand_timevars)
				tempvar cons
				gen byte `cons' = 1 if `touse'
				local templongvars "`e(rand_timevars)' `cons'"
				local `++alpha_ith'
			}
			if `e(deriv)' {
				tempvar alpha_`alpha_ith'
				qui predictnl double `alpha_`alpha_ith'' = xb(alpha_`alpha_ith') if `touse'==1
				local alphas "`alphas' `alpha_`alpha_ith''"

				// Calculate dlongitudinal xb values
				tempvar tempdfitvals
				qui predict `tempdfitvals' , xb dlongitudinal timevar(`basetime') `zeros' `atlist'
				qui replace `tempdfitvals' = `tempdfitvals' * `alpha_`alpha_ith''
				
				// Build and pass derivative of random time powers DM to Mata
				forvalues i=1/`=`e(n_re)'-1' {
					tempvar deriv_dm_`i'
					if (`fp_randpows'[1,`i']!=0) {
						gen double `deriv_dm_`i'' = (`fp_randpows'[1,`i'])*(`basetime')^(`fp_randpows'[1,`i']-1)
					}
					else gen double `deriv_dm_`i'' = 1/`basetime'
					local  deriv_var_names "`deriv_var_names' `deriv_dm_`i''"
				}
				tempvar null
				gen byte `null' = 0 if `touse'
				local deriv_var_names "`deriv_var_names' `null'"				
				local `++alpha_ith'
			}
			if `e(intassoc)' {
				tempvar alpha_`alpha_ith' fixed_coef_int
				qui predictnl double `alpha_`alpha_ith'' = xb(alpha_`alpha_ith') if `touse'==1
				local alphas "`alphas' `alpha_`alpha_ith''"
				if `e(nocoefficient)' {
					qui gen double `fixed_coef_int' = 0 if `touse'
				}
				else qui gen double `fixed_coef_int' = [Longitudinal][_cons] * `alpha_`alpha_ith'' if `touse'
				local `++alpha_ith'
			}
			if `e(timeassoc)' {
				tempvar fixed_coef
				gen double `fixed_coef' = 0 if `touse'
				foreach var in `e(sepassoc_timevar_index)' {
					tempvar alpha_`alpha_ith'
					qui predictnl double `alpha_`alpha_ith'' = xb(alpha_`alpha_ith') if `touse'==1
					local alphas "`alphas' `alpha_`alpha_ith''"
					if !`e(nocoefficient)' {
						qui replace `fixed_coef' = `fixed_coef' + [Longitudinal][_time_`var'] * `alpha_`alpha_ith'' if `touse'==1
					}
					local `++alpha_ith'
				}
			}
			mata: stjm_haz_xb_aft()		
		
		}
		
	}			
		
	//======================================================================================================================================================//
	
	if "`nopreserve'"=="" {

	/* restore original data and merge in new variables */
		if "`reffects'"=="" & "`reses'"=="" & "`stdp'"=="" {
			local keep `newvarname'
		}
		if "`ci'" != "" { 
			local keep `keep' `newvarname'_lci `newvarname'_uci
		}
		if "`stdp'"!="" {
			local keep `keep' `newvarname'_se
		}
		if "`reffects'"!="" | "`reses'"!="" {
			local keep `keep' `newnames'
		}
		keep `e(panel)' `keep' `tomerge'
		qui save `newvars'
		restore
		merge 1:1 _n using `newvars', nogenerate noreport 
	}
*}
end	

program gausskronrod15, rclass
	tempname knodes kweights
	mat `knodes'	= J(1,15,.)
	mat `kweights' 	= J(1,15,.)

	local i=1
	foreach n of numlist 0.991455371120813 -0.991455371120813 0.949107912342759 -0.949107912342759 0.864864423359769 -0.864864423359769 0.741531185599394 -0.741531185599394 0.586087235467691 -0.586087235467691 0.405845151377397 -0.405845151377397 0.207784955007898 -0.207784955007898 0 {
		mat `knodes'[1,`i'] = `n'
		local `++i'
	}
	local i=1
	foreach n of numlist 0.022935322010529 0.022935322010529 0.063092092629979 0.063092092629979 0.104790010322250 0.104790010322250 0.140653259715525 0.140653259715525 0.169004726639267 0.169004726639267 0.190350578064785 0.190350578064785 0.204432940075298 0.204432940075298 0.209482141084728  {
		mat `kweights'[1,`i'] = `n'
		local `++i'
	}
	return matrix knodes = `knodes'
	return matrix kweights = `kweights'
end

program gausskronrod7, rclass
	tempname knodes kweights
	mat `knodes' 	= J(1,7,.)
	mat `kweights' 	= J(1,7,.)

	local i=1
	foreach n of numlist 0.949107912342759 -0.949107912342759 0.741531185599394 -0.741531185599394 0.405845151377397 -0.405845151377397 0 {
		mat `knodes'[1,`i'] = `n'
		local `++i'
	}
	local i=1
	foreach n of numlist 0.129484966168870 0.129484966168870 0.279705391489277 0.279705391489277 0.381830050505119 0.381830050505119 0.417959183673469  {
		mat `kweights'[1,`i'] = `n'
		local `++i'
	}
	return matrix knodes = `knodes'
	return matrix kweights = `kweights'
end
