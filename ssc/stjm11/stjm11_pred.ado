*! version 1.3.1 15aug2012 MJC

/*
History
MJC 15aug2012: version 1.3.1 - missing data incorrectly handled, now fixed
MJC 02Feb2012: version 1.3.0 - xb survival predictions now average of m draws from random effects plus fixed effects. reses predictions added. Syntax for reffects/reses changed to stub* or newvarlist
MJC 02Nov2011: version 1.2.0 - added exponential and Gompertz
MJC 14Oct2011: version 1.1.0 - added Weibull survival submodel predictions
MJC 10Oct2011: version 1.0.0
*/

program stjm11_pred, sortpreserve
	version 11.2
	
	syntax anything(name=vlist) [if] [in],	[							///
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
													DLongitudinal		///		-fitted 1st derivative of longitudinal submodel- 	/* UNDOCUMENTED */		
													DDLongitudinal		///		-fitted 2nd derivative of longitudinal submodel- 	/* UNDOCUMENTED */		
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
													M(string)			///		-Number of draws from MVN for marginal survival predictions-
													NOPRESERVE			///		-Undocumented-
													BLUPS(string)		///		-UNDOCUMENTED-
												]
	
	marksample touse, novarlist
	local newvarname `vlist'
	qui count if `touse'
	if r(N)==0 {
		error 2000          /* no observations */
		exit
	}
	
	/******************************************************************************************************************************************************/
	/*** Error checks ***/

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
				di as error "m must be an integer"
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
		
		
	/******************************************************************************************************************************************************/
	/*** Defaults ***/
		
		local smodel "`e(survmodel)'"
		
		if ("`smodel'"=="w" | "`smodel'"=="e" | "`smodel'"=="g") & "`martingale'"!="" {
			di as error "martingales not currently available under a Weibull/exponential/Gompertz submodel"
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

		if "`ci'"!="" {
			local seciopt "ci(`newvarname'_lci `newvarname'_uci)"
		}
		else if "`stdp'"!="" {
			local seciopt "se(`newvarname'_se)"
		}
		else {
			local seciopt
		}
		
		if "`predopt'"=="fitted" & "`ci'"!="" {
			di as error "ci cannot be used with fitted"
			exit 198
		}
		
		if "`timevar'"!="" {
			local predtime "timevar(`timevar')"
		}
		
*quietly {		
	
	/******************************************************************************************************************************************************/
	/* Essentials */

		/* Indicator matrix to denote random FP's */
		mat rand_ind = e(rand_ind)
		/* Matrix to store FP powers */
		mat fp_pows = e(fp_pows)
		
		if "`e(timeassoc)'"=="yes" {
			tempname timeassocmat
			mat `timeassocmat' = e(timeassoc_re_ind)
		}
		
		local fps `e(fps_list)'
		
		local timeinteraction `e(timeinteraction)'
		
		/* Variance-covariance matrix of random effects */
		matrix vcv = e(vcv)								
		mata: vcv = st_matrix("vcv")
		
		tempvar _tempidp
		qui egen `_tempidp' = group(`e(panel)')	if e(sample)==1

		tempvar surv_ind
		qui bys `_tempidp' (_t0) : gen `surv_ind'= _n==_N	if e(sample)==1		// final row indicator per panel
		qui replace `surv_ind' = 0 if `surv_ind'==.

		if "`nopreserve'"=="" {
			/* Preserve data for out of sample prediction  */	
			tempfile newvars 
			preserve		
		}	
		
	/******************************************************************************************************************************************************/
	/*** Empirical Bayes predictions ***/
	
	if ("`reffects'"!="" | "`reses'"!="" | "`predopt'"=="fitted") & "`blups'"=="" {
	
		/* Check whether adaptive or non-adaptive quadrature was used */
		local quadform : word 1 of `e(intmethod)'
		if "`quadform'"=="Adaptive" {
			mata: adapt = "yes"
		}
		else{
			mata: adapt = "no"
		}		
		
		
		// Create new variables to store predictions 
		if "`predopt'"!="fitted" {
			if "`star'"=="*" {
				forvalues i=1/`e(n_re)' {
					qui gen double `stub'`i' = . if `touse'==1
					local newnames "`newnames' `stub'`i'"
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
				local newnames "`newnames' `tempblups`i''"
			}
			local tempblupnames `newnames'
		}		
				
		if "`reffects'"!="" | "`predopt'"=="fitted" {
			if "`quadform'"=="Adaptive" {
				mata eb_preds("`newnames'","`surv_ind'",jlnodes,`e(n_re)', vcv, nodesfinal,adapt,aghnodes)
			}
			else {
				mata eb_preds("`newnames'","`surv_ind'",jlnodes,`e(n_re)', vcv, nodesfinal,adapt)
			}
		}
		else {
			if "`quadform'"=="Adaptive" {
				mata eb_sd_preds("`newnames'","`surv_ind'",jlnodes,`e(n_re)',vcv,nodesfinal,adapt,aghnodes)
			}
			else {
				mata eb_sd_preds("`newnames'","`surv_ind'",jlnodes,`e(n_re)',vcv,nodesfinal,adapt)
			}		
		}
		
		/* Replicate final row */
		foreach var in `newnames' {	
			qui bys `_tempidp' (_t0): replace `var' = `var'[_N]	if `touse'==1
		}
		
		/* Variable label names */
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
		
	/******************************************************************************************************************************************************/
	/*** Baseline predictions ***/
	
		if "`zeros'"!="" {
			foreach var in `e(long_varlist)' {
				if `"`: list posof `"`var'"' in at'"' == "0" { 
					qui replace `var' = 0 if `touse'
				}
			}
			foreach var in `e(surv_varlist)' {
				if `"`: list posof `"`var'"' in at'"' == "0" { 
					qui replace `var' = 0 if `touse'
				}
			}
		}	
		
	/******************************************************************************************************************************************************/
	/* Out of sample predictions using at() */
	
		if "`at'" != "" {
			local atlist at(`at')
			tokenize `at'
			while "`1'"!="" {
				unab 1: `1'
				cap confirm var `2'
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
		
		
	/******************************************************************************************************************************************************/
	/*** Timevars ***/
		
	if "`reffects'"=="" & "`reses'"=="" {	
	
		tempvar basetime
		
		/* Longitudinal */
		
			/* Evaluate predictions at measurement times */
				if "`predtime'"=="meastime" {
					qui gen double `basetime' = _t0 if `touse'==1
				}
			/* Evaluate predictions at variable specified by timevar */
				else if "`timevar'"!="" {
					qui gen double `basetime' = `timevar' if `touse'==1
				}
			/* Evaluate predictions at survival time */
				else if "`predtime'"=="survtime" {
					qui gen double `basetime' = _t if `touse'==1
				}

		/* Survival */
		
			if "`smodel'"=="fpm" {
				/* Evaluate predictions at either time of measurement/survival or timevar */
					tempvar lnt 
					qui gen double `lnt' = ln(`basetime') if `touse'==1
					
				/* Calculate new spline terms */
					cap drop _rcs* _d_rcs*
					tempname rmatrix
					matrix `rmatrix' = e(rmatrix)
					qui rcsgen `lnt' if `touse', knots(`e(ln_bhknots)') gen(_rcs) dgen(_d_rcs) rmatrix(`rmatrix')
			}
	}			
	
	/******************************************************************************************************************************************************/
	/* Re-create _time_* variables */
	
	if "`reffects'"=="" & "`reses'"=="" {
	
		cap drop _time_*
		
		/* Shift */
		local firstpow : word 1 of `fps'
		if `firstpow' <= 0 {
			qui fracgen `basetime' `fps' if `touse',  noscaling nogen
			local shift = `r(shift)'
		}
		else {
			local shift = 0
		}
		
		/* Generate timevars */
		local j = 1
		foreach i of numlist `fps' {
		
			if (`i'!=0) {
				qui gen double _time_`j' = (`basetime' + `shift')^(`i') 	if `touse'==1	
			}
			else {
				qui gen double _time_`j' = log(`basetime' + `shift') 	if `touse'==1	
			}
	
			/* time and covariate interactions */
			if "`e(timeinteraction)'"!="" {
				foreach cov of varlist `e(timeinteraction)' {
					qui gen double _time_`j'_`cov'		= `cov' * _time_`j' 		if `touse'==1
				}
			}	
			
			local `++j'
		}
	
	}
	

	/*******************/
	/*** PREDICTIONS ***/
	/*******************/
	

	/******************************************************************************************************************************************************/
	/*** Longitudinal xb/fitted values ***/
	
	if "`longitudinal'"!="" & "`predopt'"=="xb" {
		predictnl `newvarname' = xb(Longitudinal) if `touse', `seciopt'
		label variable `newvarname' "Longitudinal prediction"
	}
	
	if "`longitudinal'"!="" & "`predopt'"=="fitted" {
				
		/* Build string to multiply BLUPS and appropriate _time* variables */
		local ind = 1
		if `e(n_re)' > 1 {
			forvalues i = 1/`e(npows)' {
				if (rand_ind[1,`i']==1) {
					local revar : word `ind' of `tempblupnames'
					local eb_adds "+ `revar'*_time_`i' `eb_adds'"
					local `++ind'
				}
			}
		}
		/* add random intercept */
		local add : word `e(n_re)' of `tempblupnames'
		local eb_adds "+ `add' `eb_adds'"
		
		predictnl `newvarname' = xb(Longitudinal) `eb_adds' if `touse'
		label variable `newvarname' "Longitudinal prediction (including BLUPS)"
	}	
	
	/******************************************************************************************************************************************************/
	/*** Longitudinal residuals ***/
	
	if "`residuals'"!="" {
		tempvar long_pred
		predict `long_pred' if `touse', fitted longitudinal meastime blups(`tempblupnames')
		gen double `newvarname' = (`e(longdepvar)' - (`long_pred')) if `touse'
		label variable `newvarname' "Residuals"
	}
	
	if "`rstandard'"!="" {
		tempvar long_pred
		predict `long_pred' if `touse', fitted longitudinal meastime blups(`tempblupnames')
		gen double `newvarname' = (`e(longdepvar)' - (`long_pred'))/exp([lns_e][_cons]) if `touse'
		label variable `newvarname' "Standardised residuals"
	}	

	/******************************************************************************************************************************************************/
	/* 1st derivative of longitudinal submodel - fitted */

	if "`dlongitudinal'"!="" {
		
		local ind = 1
		forvalues i=1/`e(npows)' {
			/* First derivative of time variables */
			if (rand_ind[1,`i']==1 & "`predopt'"=="fitted" ) {
				if (fp_pows[1,`i']!=0) {
					local diff`i' "(fp_pows[1,`i']*`basetime'^(fp_pows[1,`i']-1))"
				}
				else {
					local diff`i' "(1/`basetime')"
				}
				local add`ind' : word `ind' of `tempblupnames'
				local linpred_time_diff "`linpred_time_diff' ([Longitudinal][_time_`i']+`add`ind'')*`diff`i''+"
				local `++ind'						
			}
			else {
				if (fp_pows[1,`i']!=0) {
					local diff`i' "(fp_pows[1,`i']*`basetime'^(fp_pows[1,`i']-1))"
				}
				else {
					local diff`i' "(1/`basetime')"
				}
				local linpred_time_diff "`linpred_time_diff' ([Longitudinal][_time_`i'])*`diff`i'' +"	
			}
			
			if "e(timeinteraction)"!="" {
				foreach var in `e(timeinteraction)' {
					local linpred_time_diff "`linpred_time_diff' ([Longitudinal][_time_`i'_`var']*`diff`i''*`var') +"
				}
			}
			
		}	

		qui gen double `newvarname' = `linpred_time_diff' 0 if `touse'			//0 is a fudge to account for final plus
		
	}
		
	/******************************************************************************************************************************************************/
	/* 2nd derivative of longitudinal submodel - fitted */
	
	if "`ddlongitudinal'"!="" {
				
		local ind = 1
		forvalues i=1/`e(npows)' {
			if (rand_ind[1,`i']==1 & "`predopt'"=="fitted") {
			
				if (fp_pows[1,`i']==0) {
					local 2diff`i' "(-1/(`basetime'^2))"
					local add`ind' : word `ind' of `tempblupnames'					
					local linpred_time_diff2 "`linpred_time_diff2' ([Longitudinal][_time_`i']+`add`ind'')*`2diff`i'' +"	
					local `++ind'						
				}
				else if (fp_pows[1,`i']==1) {
					local 2diff`i' "0"
					local `++ind'
				}
				else {
					local 2diff`i' "(fp_pows[1,`i']*(fp_pows[1,`i']-1)*`basetime'^(fp_pows[1,`i']-2))"
					local add`ind' : word `ind' of `tempblupnames'					
					local linpred_time_diff2 "`linpred_time_diff2' ([Longitudinal][_time_`i']+`add`ind'')*`2diff`i'' +"	
					local `++ind'					
				}
			}
			else {
				if (fp_pows[1,`i']==0) {
					local 2diff`i' "(-1/(`basetime'^2))"
					local linpred_time_diff2 "`linpred_time_diff2' ([Longitudinal][_time_`i'])*`2diff`i'' +"	
				}
				else if (fp_pows[1,`i']==1) {
					local 2diff`i' "0"
				}
				else {
					local 2diff`i' "(fp_pows[1,`i']*(fp_pows[1,`i']-1)*`basetime'^(fp_pows[1,`i']-2))"
					local linpred_time_diff2 "`linpred_time_diff2' ([Longitudinal][_time_`i'])*`2diff`i'' +"	
				}
			}
			
			if "e(timeinteraction)"!="" {
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
	
	/******************************************************************************************************************************************************/
	/*** Hazard function - fitted ***/		//hazard scale all work, fpm needs cumhazard and survival to be coded.
	
	if "`hazard'"!="" & "`predopt'"=="fitted" {
	
		/* Hazard scale model prediction */
		if "`smodel'"!="fpm" {		
		
			local alpha_ith = 1
			if "`e(current)'"=="yes" {			
				local assoc_pred "xb(alpha_`alpha_ith')*(predict(longitudinal fitted `predtime')) +"
				local `++alpha_ith'	
			}
		
			if "`e(deriv)'"=="yes" {			
				local assoc_pred "`assoc_pred' xb(alpha_`alpha_ith')*(predict(dlongitudinal fitted `predtime')) +"
				local `++alpha_ith'	
			}		
		
			if "`e(intassoc)'"=="yes" {
				local add : word `e(n_re)' of `tempblupnames'					
				local assoc_pred "`assoc_pred' xb(alpha_`alpha_ith')*([Longitudinal][_cons] + `add') +"
				local `++alpha_ith'	
			}
			
			if "`e(timeassoc)'"=="yes" {
				local i = 1
				foreach re of numlist `e(sepassoc_timevar_index)' {
					local ind : word `i' of `e(sepassoc_timevar_pows)'
					local i2 = 1
					foreach fp of numlist `e(random_time)' {
						if `ind'==`fp' {
							local add`i2' : word `i2' of `tempblupnames'
							local assoc_pred "`assoc_pred' xb(alpha_`alpha_ith')*([Longitudinal][_time_`re'] + `add`i2'') +"
							local `++alpha_ith'
						}
						local `++i2'
					}
					local `++i'
				}
			}
		
			/* Prediction */
			if "`smodel'"=="e" {		//Exponential
				qui predictnl double `newvarname' = exp(`assoc_pred' xb(ln_lambda)) if `touse', `seciopt'			
			}
			else if "`smodel'"=="w" {	//Weibull
				qui predictnl double `newvarname' = exp(xb(ln_gamma)) * (`basetime') ^ (exp(xb(ln_gamma))-1) *exp(`assoc_pred' xb(ln_lambda)) if `touse', `seciopt'			
			}
			else if "`smodel'"=="g" {	//Gompertz
				qui predictnl double `newvarname' = exp(xb(gamma)*`basetime') * exp(`assoc_pred' xb(ln_lambda)) if `touse', `seciopt'			
			}

		}
		/* FPM prediction */
		else {
		
			local alpha_ith = 1
			local assoc_pred2
			if "`e(current)'"=="yes" {
				local assoc_pred2 "xb(alpha_`alpha_ith')*predict(dlongitudinal fitted `predtime') +"
				local `++alpha_ith'	
			}
			
			if "`e(deriv)'"=="yes" {			
				local assoc_pred2 "`assoc_pred2' xb(alpha_`alpha_ith')*predict(ddlongitudinal fitted `predtime') +"
				local `++alpha_ith'	
			}
			
			qui predictnl double `newvarname' = (1/`basetime'*predict(cumhazard fitted `predtime'))*(`assoc_pred2' xb(dxb)) if `touse', `seciopt'

		}
			
	}
	
	/******************************************************************************************************************************************************/
	/*** Cumulative hazard - fitted ***/
	
	if ("`cumhazard'"!="" &"`predopt'"=="fitted") {
		
		if "`smodel'"!="fpm" {
			
			/* Number of obs */
			qui count if `touse'==1
			mata: N = `r(N)'
			
			/* Time variable */
			mata: basetime = st_data(.,"`basetime'",st_local("touse"))
			
			/* Put adjusted GK nodes and weights into Mata */
			gausskronrod`e(gk)'
			mata: kweights = st_matrix("kweights")
			mata: knewnodes = J(N,1,st_matrix("knodes")):*(basetime:/2) :+ (basetime:/2)

			
			/* Temporary variables to hold longitudinal fitted predictions multiplied by associations and passed to Mata */
			local alpha_ith = 1
			mata: alpha_longfit_mat = J(N,`e(gk)',0)
			
			
			
			if "`e(current)'"=="yes" | "`e(deriv)'"=="yes" {
			
				/* create time variables */
				forvalues i=1/`e(gk)' {
					tempvar temptime`i'
					qui gen double `temptime`i'' = .
					local temptimenames "`temptimenames' `temptime`i''"
				}
				mata: st_view(X=.,.,"`temptimenames'")
				mata: X[,] = knewnodes
				
				if "`e(current)'"=="yes"  {
					/* alpha */
					tempvar alpha_`alpha_ith'
					qui predictnl double `alpha_`alpha_ith'' = xb(alpha_`alpha_ith') if `touse'==1
				
					/* Calculate longitudinal fitted values at each set of GK nodes */
					forvalues i=1/`e(gk)' {
						tempvar tempfitvals`i'
						qui predict `tempfitvals`i'' , fitted longitudinal timevar(`temptime`i'')
						qui replace `tempfitvals`i'' = `tempfitvals`i'' * `alpha_`alpha_ith''		//multiply by association parameter
						local templongnames "`templongnames' `tempfitvals`i''"
					}
					/* Pass fitted values to Mata */
					mata: alpha_longfit_mat = st_data(.,"`templongnames'","`touse'")
					
					local `++alpha_ith'
					
				}
				
				if "`e(deriv)'"=="yes" {
					/* alpha */
					tempvar alpha_`alpha_ith'
					qui predictnl double `alpha_`alpha_ith'' = xb(alpha_`alpha_ith') if `touse'==1
				
					/* Calculate dlongitudinal fitted values at each set of GK nodes */
					forvalues i=1/`e(gk)' {
						tempvar tempdfitvals`i'
						qui predict `tempdfitvals`i'' , fitted dlongitudinal timevar(`temptime`i'')
						qui replace `tempdfitvals`i'' = `tempdfitvals`i'' * `alpha_`alpha_ith''		//multiply by association parameter
						local tempdlongnames "`tempdlongnames' `tempdfitvals`i''"
					}
					/* Pass fitted values to Mata */
					mata: alpha_longfit_mat = alpha_longfit_mat :+ st_data(.,"`tempdlongnames'","`touse'")
				
					local `++alpha_ith'
				}
				
			}
			
			if "`e(intassoc)'"=="yes" | "`e(timeassoc)'"=="yes" {
						
				if "`e(intassoc)'"=="yes" {
					
					tempvar alpha_`alpha_ith'
					local add : word `e(n_re)' of `tempblupnames'
					qui predictnl double `alpha_`alpha_ith'' = xb(alpha_`alpha_ith')*([Longitudinal][_cons] + `add') if `touse'==1
					mata: alpha_longfit_mat = alpha_longfit_mat :+ st_data(.,"`alpha_`alpha_ith''","`touse'")
					
					local `++alpha_ith'
					
				}	
				
				if "`e(timeassoc)'"=="yes" {
					local i = 1
					foreach re of numlist `e(sepassoc_timevar_index)' {
						local ind : word `i' of `e(sepassoc_timevar_pows)'
						local i2 = 1
						foreach fp of numlist `e(random_time)' {
							if `ind'==`fp' {
								local add`i2' : word `i2' of `tempblupnames'					
								local assoc_pred4 "`assoc_pred4' xb(alpha_`alpha_ith')*([Longitudinal][_time_`re'] + `add`i2'') +"
								local `++alpha_ith'
							}
							local `++i2'
						}
						local `++i'
					}
					
					tempvar alpha_`alpha_ith'
					qui predictnl double `alpha_`alpha_ith'' = `assoc_pred4' 0 if `touse'==1
					mata: alpha_longfit_mat = alpha_longfit_mat :+ st_data(.,"`alpha_`alpha_ith''","`touse'")
					
				}
			
			}
			
			/* Lambda and gamma */
			tempvar lambda gamma
			qui predictnl double `lambda' = exp(xb(ln_lambda)) if `touse'==1
			if "`smodel'"=="e" {
				gen `gamma' = 1 if `touse'==1
			}
			else if "`smodel'"=="w" {
				qui predictnl double `gamma' = exp(xb(ln_gamma)) if `touse'==1
			}
			else if "`smodel'"=="g" {
				qui predictnl double `gamma' = xb(gamma) if `touse'==1
			}
			mata: lambda = st_data(.,"`lambda'",st_local("touse"))
			mata: gamma = st_data(.,"`gamma'",st_local("touse"))				
			
			qui gen double `newvarname' = .
			mata weib_cumhaz("`smodel'","`newvarname'","`touse'",N,lambda,gamma,basetime,knewnodes,kweights,alpha_longfit_mat)

		}
		/* FPM prediction */
		else {
				
			local alpha_ith = 1
			if "`e(current)'"=="yes" {			
				local assoc_pred3 "xb(alpha_`alpha_ith')*(predict(longitudinal fitted `predtime')) +"
				local `++alpha_ith'	
			}
		
			if "`e(deriv)'"=="yes" {			
				local assoc_pred3 "`assoc_pred3' xb(alpha_`alpha_ith')*(predict(dlongitudinal fitted `predtime')) +"
				local `++alpha_ith'	
			}		
		
			if "`e(intassoc)'"=="yes" {
				local add : word `e(n_re)' of `tempblupnames'					
				local assoc_pred3 "`assoc_pred3' xb(alpha_`alpha_ith')*([Longitudinal][_cons] + `add') +"
				local `++alpha_ith'	
			}
			
			if "`e(timeassoc)'"=="yes" {
				local i = 1
				foreach re of numlist `e(sepassoc_timevar_index)' {
					local ind : word `i' of `e(sepassoc_timevar_pows)'
					local i2 = 1
					foreach fp of numlist `e(random_time)' {
						if `ind'==`fp' {
							local add`i2' : word `i2' of `tempblupnames'					
							local assoc_pred3 "`assoc_pred3' xb(alpha_`alpha_ith')*([Longitudinal][_time_`re'] + `add`i2'') +"
							local `++alpha_ith'
						}
						local `++i2'
					}
					local `++i'
				}
			}
			
			qui predictnl double `newvarname' = exp(`assoc_pred3' xb(xb)) if `touse'==1
			
		}

	}
	
	/******************************************************************************************************************************************************/
	/*** Martingales and deviance - fitted ***/
	
	if ("`martingale'"!="" | "`deviance'"!="") {
	
		if "`smodel'"!="fpm" {
		
			tempvar ch res
			qui predictnl `res' = _d + log(predict(survival `predopt' `predtime' `zeros' `atlist' blups(`tempblupnames'))) if `touse'==1
			if "`deviance'"!="" {
				qui gen double `newvarname' = sign(`res')*sqrt( -2*(`res' + _d*(log(_d -`res')))) if `touse'==1
			}
			else rename `res' `newvarname'	//martingales
		
		}
		else {
		
			tempvar ch res
			qui predictnl `res' = _d + log(predict(survival `predopt' `predtime' `zeros' `atlist' blups(`tempblupnames'))) if `touse'==1
			if "`deviance'"!="" {
				qui gen double `newvarname' = sign(`res')*sqrt( -2*(`res' + _d*(log(_d -`res')))) if `touse'==1
			}
			else rename `res' `newvarname'
		
		}	
	
	}
	
	/******************************************************************************************************************************************************/
	/*** Survival function - fitted ***/

	if "`survival'"!="" & "`predopt'"=="fitted" {
	
		qui predictnl double `newvarname' = exp(-predict(cumhazard fitted `zeros'  `predtime' blups(`tempblupnames') `atlist')) if `touse'==1
		
	}
		
		
		
		
		
		
	/******************************************************************************************************************************************************/
	/* Cumhazard/Survival predictions - xb */

	if wordcount(`"`survival' `cumhazard'"') > 0 & "`predopt'"=="xb" {
	
		/* Which prediction */
		local prediction "`survival'`cumhazard'"
		
		/* New variable to hold prediction */
		qui gen double `newvarname' = . if `touse'
		
		/* Time variable */
		mata: basetime = st_data(.,"`basetime'",st_local("touse"))

		/* Draw samples from random effects distribution */
		forvalues i=1/`e(n_re)' {
			tempvar draw`i'
			local draws "`draws' `draw`i''"
		}
		cap set obs `m'
		qui replace `touse' = 0 if `touse'!=1
		qui drawnorm `draws', cov(vcv) 
		
		/* Pass draws to Mata */
		tempvar sim_ind
		qui gen `sim_ind' = _n<=`nm'	/* DO NOT PUT TOUSE HERE */
		local sim_indname "`sim_ind'"
		mata: mvn = st_data(.,tokens(st_local("draws")),st_local("sim_indname"))'
		
		/* Number of obs */
		qui count if `touse'==1
		mata: N = `r(N)'
		
		/* Matrix to hold random FP powers */
		if `e(n_re)'>1 {
			tempname fp_randpows
			mat `fp_randpows' = J(1,`=`e(n_re)'-1',.)
			local j = 1
			forvalues i = 1/`e(npows)' {
				if rand_ind[1,`i']==1 {
					mat `fp_randpows'[1,`j'] = fp_pows[1,`i']
					local j = `j' + 1
				}
			}
			mata: fp_randpows = st_matrix(st_local("fp_randpows"))
		}
		else mata: fp_randpows = -99		
		
		if "`smodel'"!="fpm" {

			/* Put adjusted GK nodes and weights into Mata */
			gausskronrod`e(gk)'
			mata: kweights = st_matrix("kweights")
			mata: knewnodes = J(N,1,st_matrix("knodes")):*(basetime:/2) :+ (basetime:/2)
			
			/* Predict survival parameters */
			tempvar sp1 sp2
			if "`smodel'"=="e" {
				qui predictnl `sp1' = exp(xb(ln_lambda)) if `touse'
				qui gen `sp2' = 1 if `touse'
			}
			else if "`smodel'"=="w" {
				qui predictnl double `sp1' = exp(xb(ln_lambda)) if `touse'
				qui predictnl double `sp2' = exp(xb(ln_gamma)) 	if `touse'
			}
			else if "`smodel'"=="g" {
				qui predictnl double `sp1' = exp(xb(ln_lambda)) if `touse'
				qui predictnl double `sp2' = xb(gamma) if `touse'
			}
			mata: sp1 = st_data(.,"`sp1'","`touse'")
			mata: sp2 = st_data(.,"`sp2'","`touse'")
			
			/* Temporary variables to hold longitudinal fitted predictions multiplied by associations and passed to Mata */
			local alpha_ith = 1
			mata: alpha_longfit_mat = J(N,`e(gk)',0)

			if "`e(current)'"=="yes" | "`e(deriv)'"=="yes" {
			
				/* create time variables */
				forvalues i=1/`e(gk)' {
					tempvar temptime`i'
					qui gen double `temptime`i'' = .
					local temptimenames "`temptimenames' `temptime`i''"
				}
				mata: st_view(X=.,.,"`temptimenames'","`touse'")
				mata: X[,] = knewnodes
				
				if "`e(current)'"=="yes" {
				
					/* alpha */
					tempvar alpha_`alpha_ith'
					qui predictnl double `alpha_`alpha_ith'' = xb(alpha_`alpha_ith') if `touse'==1
					local alphas "`alpha_`alpha_ith''"
					
					/* Calculate longitudinal fitted values at each set of GK nodes */
					forvalues i=1/`e(gk)' {
						tempvar tempfitvals`i'
						qui predict `tempfitvals`i'' , xb longitudinal timevar(`temptime`i'') `zeros' `atlist'
						qui replace `tempfitvals`i'' = `tempfitvals`i'' * `alpha_`alpha_ith''		//multiply by association parameter
						local templongnames "`templongnames' `tempfitvals`i''"
					}
					/* Pass fitted values to Mata */
					mata: alpha_longfit_mat = st_data(.,"`templongnames'","`touse'")
					
					local `++alpha_ith'
					
				}
				
				if "`e(deriv)'"=="yes" {
					/* alpha */
					tempvar alpha_`alpha_ith'
					qui predictnl double `alpha_`alpha_ith'' = xb(alpha_`alpha_ith') if `touse'==1
					local alphas "`alphas' `alpha_`alpha_ith''"

					/* Calculate dlongitudinal fitted values at each set of GK nodes */
					forvalues i=1/`e(gk)' {
						tempvar tempdfitvals`i'
						qui predict `tempdfitvals`i'' , xb dlongitudinal timevar(`temptime`i'') `zeros' `atlist'
						qui replace `tempdfitvals`i'' = `tempdfitvals`i'' * `alpha_`alpha_ith''		//multiply by association parameter
						local tempdlongnames "`tempdlongnames' `tempdfitvals`i''"
					}
					/* Pass fitted values to Mata */
					mata: alpha_longfit_mat = alpha_longfit_mat :+ st_data(.,"`tempdlongnames'","`touse'")
				
					local `++alpha_ith'
				}
				
			}

			if "`e(intassoc)'"=="yes" {
				/* alpha */
				tempvar alpha_`alpha_ith' fixed_coef_int
				qui predictnl double `alpha_`alpha_ith'' = xb(alpha_`alpha_ith') if `touse'==1
				local alphas "`alphas' `alpha_`alpha_ith''"
				qui gen double `fixed_coef_int' = [Longitudinal][_cons] * `alpha_`alpha_ith'' if `touse'
				mata: alpha_longfit_mat = alpha_longfit_mat :+ st_data(.,"`fixed_coef_int'","`touse'")
				local `++alpha_ith'
			}
			
			if "`e(timeassoc)'"=="yes" {
				mata: time_assoc_ind = st_matrix("`timeassocmat'")
				foreach var in `e(sepassoc_timevar_index)' {
					tempvar alpha_`alpha_ith' fixed_coef_`alpha_ith'
					qui predictnl double `alpha_`alpha_ith'' = xb(alpha_`alpha_ith') if `touse'==1
					local alphas "`alphas' `alpha_`alpha_ith''"
					qui gen double `fixed_coef_`alpha_ith'' = [Longitudinal][_time_`var'] * `alpha_`alpha_ith'' if `touse'==1
					mata: alpha_longfit_mat = alpha_longfit_mat :+ st_data(.,"`fixed_coef_`alpha_ith''","`touse'")
					local `++alpha_ith'
				}
			}
			else mata: time_assoc_ind = -99
			
			/* Still need to pass alpha matrix */
			mata: alphas = st_data(.,"`alphas'","`touse'")
			mata: deriv_time_rand_dm = -99
		}
		/* FPM prediction */
		else {
		
			/* Temporary variables to hold longitudinal fitted predictions multiplied by associations and passed to Mata */
			local alpha_ith = 1
			mata: alpha_longfit_mat = J(N,1,0)
		
			/* Predict survival parameters */
			tempvar sp1
			qui predictnl double `sp1' = xb(xb) if `touse'==1
			mata: sp1 = st_data(.,"`sp1'","`touse'")
			mata: sp2 = -99

			if "`e(current)'"=="yes" {
			
				/* alpha */
				tempvar alpha_`alpha_ith'
				qui predictnl double `alpha_`alpha_ith'' = xb(alpha_`alpha_ith') if `touse'==1
				local alphas "`alpha_`alpha_ith''"
				
				/* Calculate longitudinal fixed fitted values at basetime */
				tempvar tempfitvals
				qui predict `tempfitvals' , xb longitudinal timevar(`basetime') `zeros' `atlist'
				qui replace `tempfitvals' = `tempfitvals' * `alpha_`alpha_ith''		//multiply by association parameter
				
				/* Pass fitted values to Mata */
				mata: alpha_longfit_mat = st_data(.,"`tempfitvals'","`touse'")
				
				/* Pass random time variabe DM to Mata */
				if "`e(rand_timevars)'"!="" {
					mata: fp_randpows = st_data(.,"`e(rand_timevars)'","`touse'"),J(N,1,1)				//fp_randpows is design matrix in this case
				}
				else mata: fp_randpows = J(N,1,1)
				
				local `++alpha_ith'
				
			}
			else mata: fp_randpows = -99

			if "`e(deriv)'"=="yes" {
				/* alpha */
				tempvar alpha_`alpha_ith'
				qui predictnl double `alpha_`alpha_ith'' = xb(alpha_`alpha_ith') if `touse'==1
				local alphas "`alphas' `alpha_`alpha_ith''"

				/* Calculate dlongitudinal xb values */
				tempvar tempdfitvals
				qui predict `tempdfitvals' , xb dlongitudinal timevar(`basetime') `zeros' `atlist'
				qui replace `tempdfitvals' = `tempdfitvals' * `alpha_`alpha_ith''		//multiply by association parameter

				/* Pass fitted values to Mata */
				mata: alpha_longfit_mat = alpha_longfit_mat :+ st_data(.,"`tempdfitvals'","`touse'")
				
				/* Build and pass derivative of random time powers DM to Mata */
				if `e(n_re)'>1 {
					forvalues i=1/`=`e(n_re)'-1' {
						tempvar deriv_dm_`i'
						if (`fp_randpows'[1,`i']!=0) {
							gen double `deriv_dm_`i'' = (`fp_randpows'[1,`i'])*(`basetime')^(`fp_randpows'[1,`i']-1)
						}
						else gen double `deriv_dm_`i'' = 1/`basetime'
						local  deriv_var_names "`deriv_var_names' `deriv_dm_`i''"
					}
					mata: deriv_time_rand_dm = st_data(.,"`deriv_var_names'","`touse'"),J(N,1,0)
				}
				else mata: deriv_time_rand_dm = J(N,1,0)
				
				local `++alpha_ith'
			}
			else mata: deriv_time_rand_dm = -99
				
			if "`e(intassoc)'"=="yes" {
				tempvar alpha_`alpha_ith' fixed_coef_int
				qui predictnl double `alpha_`alpha_ith'' = xb(alpha_`alpha_ith') if `touse'==1
				local alphas "`alphas' `alpha_`alpha_ith''"
				qui gen double `fixed_coef_int' = [Longitudinal][_cons] * `alpha_`alpha_ith'' if `touse'
				mata: alpha_longfit_mat = alpha_longfit_mat :+ st_data(.,"`fixed_coef_int'","`touse'")
				local `++alpha_ith'
			}
			
			if "`e(timeassoc)'"=="yes" {
				mata: time_assoc_ind = st_matrix("`timeassocmat'")
				foreach var in `e(sepassoc_timevar_index)' {
					tempvar alpha_`alpha_ith' fixed_coef_`alpha_ith'
					qui predictnl double `alpha_`alpha_ith'' = xb(alpha_`alpha_ith') if `touse'==1
					local alphas "`alphas' `alpha_`alpha_ith''"
					qui gen double `fixed_coef_`alpha_ith'' = [Longitudinal][_time_`var'] * `alpha_`alpha_ith'' if `touse'==1
					mata: alpha_longfit_mat = alpha_longfit_mat :+ st_data(.,"`fixed_coef_`alpha_ith''","`touse'")
					local `++alpha_ith'
				}
			}
			else mata: time_assoc_ind = -99
			
			/* Still need to pass alpha matrix to multiply with random effect draws */
			mata: alphas = st_data(.,"`alphas'","`touse'")
			
			/* Spare */
			mata: knewnodes = -99
			mata: kweights = -99
		}
		
		mata stjm_pred_marg(	"`newvarname'",		
								"`prediction'",
								"`e(survmodel)'",
								N,
								sp1,
								sp2,
								alpha_longfit_mat,
								alphas,
								mvn,
								basetime,
								knewnodes,
								kweights,
								"`e(current)'",
								"`e(deriv)'",
								"`e(intassoc)'",
								"`e(timeassoc)'",
								"`touse'",
								fp_randpows,
								time_assoc_ind,
								deriv_time_rand_dm)	

	}	
		
	/******************************************************************************************************************************************************/
	/* Hazard function - xb */

	if "`hazard'"!="" & "`predopt'"=="xb" {
	
		/* New variable to hold prediction */
		qui gen double `newvarname' = . if `touse'
		
		/* Draw samples from random effects distribution */
		forvalues i=1/`e(n_re)' {
			tempvar draw`i'
			local draws "`draws' `draw`i''"
		}
		cap set obs `m'
		qui replace `touse' = 0 if `touse'!=1
		qui drawnorm `draws', cov(vcv) 
		
		/* Pass draws to Mata */
		tempvar sim_ind
		qui gen `sim_ind' = _n<=`nm'	/* DO NOT PUT TOUSE HERE */
		mata: mvn = st_data(.,tokens(st_local("draws")),"`sim_ind'")'
		
		/* Number of obs */
		qui count if `touse'==1
		mata: N = `r(N)'
		
		/* Time variable */
		mata: basetime = st_data(.,"`basetime'",st_local("touse"))
	
		/* Matrix to hold random FP powers */
		if `e(n_re)'>1 {
			tempname fp_randpows
			mat `fp_randpows' = J(1,`=`e(n_re)'-1',.)
			local j = 1
			forvalues i = 1/`e(npows)' {
				if rand_ind[1,`i']==1 {
					mat `fp_randpows'[1,`j'] = fp_pows[1,`i']
					local j = `j' + 1
				}
			}
		}
		
		if "`smodel'"!="fpm" {

			/* Predict survival parameters */
			tempvar sp1 sp2
			if "`smodel'"=="e" {
				qui predictnl `sp1' = exp(xb(ln_lambda)) if `touse'
				qui gen `sp2' = 1 if `touse'
			}
			else if "`smodel'"=="w" {
				qui predictnl `sp1' = exp(xb(ln_lambda)) if `touse'
				qui predictnl `sp2' = exp(xb(ln_gamma)) if `touse'
			}
			else if "`smodel'"=="g" {
				qui predictnl `sp1' = exp(xb(ln_lambda)) if `touse'
				qui predictnl `sp2' = xb(gamma) if `touse'
			}
			mata: sp1 = st_data(.,"`sp1'","`touse'")
			mata: sp2 = st_data(.,"`sp2'","`touse'")
			
			/* Temporary variables to hold longitudinal fitted predictions multiplied by associations and passed to Mata */
			local alpha_ith = 1
			mata: alpha_longfit_mat = J(N,1,0)

			if "`e(current)'"=="yes"  {
			
				/* alpha */
				tempvar alpha_`alpha_ith'
				qui predictnl double `alpha_`alpha_ith'' = xb(alpha_`alpha_ith') if `touse'==1
				local alphas "`alpha_`alpha_ith''"
				
				/* Calculate longitudinal fixed fitted values at basetime */
				tempvar tempfitvals
				qui predict `tempfitvals' , xb longitudinal timevar(`basetime') `zeros' `atlist'
				qui replace `tempfitvals' = `tempfitvals' * `alpha_`alpha_ith''		//multiply by association parameter
				
				/* Pass fitted values to Mata */
				mata: alpha_longfit_mat = st_data(.,"`tempfitvals'","`touse'")
				
				/* Pass random time variabe DM to Mata */
				if "`e(rand_timevars)'"!="" {
					mata: time_rand_dm = st_data(.,"`e(rand_timevars)'","`touse'"),J(N,1,1)
				}
				else mata: time_rand_dm = J(N,1,1)
				
				local `++alpha_ith'
				
			}
			else mata: time_rand_dm = -99
			
			if "`e(deriv)'"=="yes" {
				/* alpha */
				tempvar alpha_`alpha_ith'
				qui predictnl double `alpha_`alpha_ith'' = xb(alpha_`alpha_ith') if `touse'==1
				local alphas "`alphas' `alpha_`alpha_ith''"

				/* Calculate dlongitudinal xb values */
				tempvar tempdfitvals
				qui predict `tempdfitvals' , xb dlongitudinal timevar(`basetime') `zeros' `atlist'
				qui replace `tempdfitvals' = `tempdfitvals' * `alpha_`alpha_ith''		//multiply by association parameter
				
				/* Pass fitted values to Mata */
				mata: alpha_longfit_mat = alpha_longfit_mat :+ st_data(.,"`tempdfitvals'","`touse'")
				
				/* Build and pass derivative of random time powers DM to Mata */
				if `e(n_re)'>1 {
					forvalues i=1/`=`e(n_re)'-1' {
						tempvar deriv_dm_`i'
						if (`fp_randpows'[1,`i']!=0) {
							gen double `deriv_dm_`i'' = (`fp_randpows'[1,`i'])*(`basetime')^(`fp_randpows'[1,`i']-1)
						}
						else gen double `deriv_dm_`i'' = 1/`basetime'
						local  deriv_var_names "`deriv_var_names' `deriv_dm_`i''"
					}
					mata: deriv_time_rand_dm = st_data(.,"`deriv_var_names'","`touse'"),J(N,1,0)
				}
				else mata: deriv_time_rand_dm = J(N,1,0)
				
				local `++alpha_ith'
			}
			else mata: deriv_time_rand_dm = -99
				
			if "`e(intassoc)'"=="yes" {
				tempvar alpha_`alpha_ith' fixed_coef_int
				qui predictnl double `alpha_`alpha_ith'' = xb(alpha_`alpha_ith') if `touse'==1
				local alphas "`alphas' `alpha_`alpha_ith''"
				qui gen double `fixed_coef_int' = [Longitudinal][_cons] * `alpha_`alpha_ith'' if `touse'
				mata: alpha_longfit_mat = alpha_longfit_mat :+ st_data(.,"`fixed_coef_int'","`touse'")
				local `++alpha_ith'
			}
			
			if "`e(timeassoc)'"=="yes" {
				mata: time_assoc_ind = st_matrix("`timeassocmat'")
				foreach var in `e(sepassoc_timevar_index)' {
					tempvar alpha_`alpha_ith' fixed_coef_`alpha_ith'
					qui predictnl double `alpha_`alpha_ith'' = xb(alpha_`alpha_ith') if `touse'==1
					local alphas "`alphas' `alpha_`alpha_ith''"
					qui gen double `fixed_coef_`alpha_ith'' = [Longitudinal][_time_`var'] * `alpha_`alpha_ith'' if `touse'==1
					mata: alpha_longfit_mat = alpha_longfit_mat :+ st_data(.,"`fixed_coef_`alpha_ith''","`touse'")
					local `++alpha_ith'
				}
			}
			else mata: time_assoc_ind = -99

			/* Still need to pass alpha matrix to multiply with random effect draws */
			mata: alphas = st_data(.,"`alphas'","`touse'")
			
			mata stjm_pred_marg_haz(	"`newvarname'",		
										"`e(survmodel)'",
										N,
										sp1,
										sp2,
										alpha_longfit_mat,
										alphas,
										mvn,
										basetime,
										"`e(current)'",
										"`e(deriv)'",
										"`e(intassoc)'",
										"`e(timeassoc)'",
										"`touse'",
										time_rand_dm,
										deriv_time_rand_dm,
										time_assoc_ind)	
				
		}
		else {
		
			/* Temporary variables to hold longitudinal fitted predictions multiplied by associations and passed to Mata */
			local alpha_ith = 1
			mata: alpha_longfit_mat = alpha_longfit_mat2 = J(N,1,0)
		
			/* Predict survival parameters */
			tempvar sp1 sp2
			qui predictnl double `sp1' = xb(xb)  if `touse'==1
			qui predictnl double `sp2' = xb(dxb) if `touse'==1
			mata: sp1 = st_data(.,"`sp1'","`touse'")
			mata: sp2 = st_data(.,"`sp2'","`touse'")

			if "`e(current)'"=="yes" | "`e(deriv)'"=="yes" {
			
				/* Calculate dlongitudinal xb values */
				tempvar tempdfitvals
				qui predict `tempdfitvals' , xb dlongitudinal timevar(`basetime')  `zeros' `atlist'
				
				/* Build and pass derivative of random time powers DM to Mata */
				if `e(n_re)'>1 {
					forvalues i=1/`=`e(n_re)'-1' {
						tempvar deriv_dm_`i'
						if (`fp_randpows'[1,`i']!=0) {
							gen double `deriv_dm_`i'' = (`fp_randpows'[1,`i'])*(`basetime')^(`fp_randpows'[1,`i']-1)
						}
						else gen double `deriv_dm_`i'' = 1/`basetime'
						local  deriv_var_names "`deriv_var_names' `deriv_dm_`i''"
					}
					mata: deriv_time_rand_dm = st_data(.,"`deriv_var_names'","`touse'"),J(N,1,0)
				}
				else mata: deriv_time_rand_dm = J(N,1,0)

				if "`e(current)'"=="yes" {
				
					/* alpha */
					tempvar alpha_`alpha_ith'
					qui predictnl double `alpha_`alpha_ith'' = xb(alpha_`alpha_ith') if `touse'==1
					local alphas "`alpha_`alpha_ith''"
					
					/* Calculate longitudinal fixed fitted values at basetime */
					tempvar tempfitvals
					qui predict `tempfitvals' , xb longitudinal timevar(`basetime') `zeros' `atlist'
					qui replace `tempfitvals' = `tempfitvals' * `alpha_`alpha_ith''		//multiply by association parameter
					
					/* Pass fitted values to Mata */
					mata: alpha_longfit_mat = st_data(.,"`tempfitvals'","`touse'")
					
					/* Pass random time variabe DM to Mata */
					if "`e(rand_timevars)'"!="" {
						mata: time_rand_dm = st_data(.,"`e(rand_timevars)'","`touse'"),J(N,1,1)				//fp_randpows is design matrix in this case
					}
					else mata: time_rand_dm = J(N,1,1)
					
					/* derivative */
					qui replace `tempdfitvals' = `tempdfitvals' * `alpha_`alpha_ith''		//multiply by association parameter

					/* Pass deriv fitted values to Mata */
					mata: alpha_longfit_mat2 = alpha_longfit_mat2 :+ st_data(.,"`tempdfitvals'","`touse'")
					
					local `++alpha_ith'
					
				}
				else mata: time_rand_dm = -99

				if "`e(deriv)'"=="yes" {
					/* alpha */
					tempvar alpha_`alpha_ith'
					qui predictnl double `alpha_`alpha_ith'' = xb(alpha_`alpha_ith') if `touse'==1
					local alphas "`alphas' `alpha_`alpha_ith''"
					
					/* derivative */
					qui replace `tempdfitvals' = `tempdfitvals' * `alpha_`alpha_ith''		//multiply by association parameter

					/* Pass deriv fitted values to Mata */
					mata: alpha_longfit_mat = alpha_longfit_mat :+ st_data(.,"`tempdfitvals'","`touse'")

					/* Calculate second derivative longitudinal fixed fitted values at basetime */
					tempvar tempddfitvals
					qui predict `tempddfitvals' , xb ddlongitudinal timevar(`basetime') `zeros' `atlist'
					qui replace `tempddfitvals' = `tempddfitvals' * `alpha_`alpha_ith''		//multiply by association parameter
					
					/* Pass fitted values to Mata */
					mata: alpha_longfit_mat2 = alpha_longfit_mat2 :+ st_data(.,"`tempddfitvals'","`touse'")

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
							local  deriv2_var_names "`deriv2_var_names' `deriv2_dm_`i''"
						}
						mata: deriv2_time_rand_dm = st_data(.,"`deriv2_var_names'","`touse'"),J(N,1,0)
					}
					else mata: deriv2_time_rand_dm = J(N,1,0)
					
					local `++alpha_ith'
				}
				else mata: deriv2_time_rand_dm = -99
				
			}
			else mata: deriv_time_rand_dm = -99
			
			if "`e(intassoc)'"=="yes" {
				tempvar alpha_`alpha_ith' fixed_coef_int
				qui predictnl double `alpha_`alpha_ith'' = xb(alpha_`alpha_ith') if `touse'==1
				local alphas "`alphas' `alpha_`alpha_ith''"
				qui gen double `fixed_coef_int' = [Longitudinal][_cons] * `alpha_`alpha_ith'' if `touse'
				mata: alpha_longfit_mat = alpha_longfit_mat :+ st_data(.,"`fixed_coef_int'","`touse'")
				local `++alpha_ith'
			}
			
			if "`e(timeassoc)'"=="yes" {
				mata: time_assoc_ind = st_matrix("`timeassocmat'")
				foreach var in `e(sepassoc_timevar_index)' {
					tempvar alpha_`alpha_ith' fixed_coef_`alpha_ith'
					qui predictnl double `alpha_`alpha_ith'' = xb(alpha_`alpha_ith') if `touse'==1
					local alphas "`alphas' `alpha_`alpha_ith''"
					qui gen double `fixed_coef_`alpha_ith'' = [Longitudinal][_time_`var'] * `alpha_`alpha_ith'' if `touse'==1
					mata: alpha_longfit_mat = alpha_longfit_mat :+ st_data(.,"`fixed_coef_`alpha_ith''","`touse'")
					local `++alpha_ith'
				}
			}
			else mata: time_assoc_ind = -99
		
		/* Still need to pass alpha matrix to multiply with random effect draws */
		mata: alphas = st_data(.,"`alphas'","`touse'")
		
		mata stjm_pred_marg_haz_fpm(	"`newvarname'",		
										"`e(survmodel)'",
										N,
										sp1,
										sp2,
										alpha_longfit_mat,
										alpha_longfit_mat2,
										alphas,
										mvn,
										basetime,
										"`e(current)'",
										"`e(deriv)'",
										"`e(intassoc)'",
										"`e(timeassoc)'",
										"`touse'",
										time_rand_dm,
										time_assoc_ind,
										deriv_time_rand_dm,
										deriv2_time_rand_dm)	
		
		}
		
	}			
		
		
		
	
	
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
		keep `keep'
		qui save `newvars'
		restore
		merge 1:1 _n using `newvars', nogenerate noreport
	}
*}
end	


/*** Mata program to calculate the empirical Bayes predictions of the random effects ***/
mata:
	mata set matastrict off
	void eb_preds(		string scalar ebvars, 			// Variable names to store EB predictions
						string scalar s_ind,			// Final row indicator variable
						numeric matrix jlnodes, 		// Joint likelihood evaluated at each GH node
						real scalar nres, 
						numeric matrix vcv, 
						numeric matrix nodesfinal,
						string scalar adapt,
						| transmorphic aghnodes)
						
{	
	st_view(final=.,.,tokens(ebvars),s_ind)
	like_j = quadrowsum(jlnodes,1)
	N = rows(jlnodes)

	if (adapt=="yes") {
		for(i=1;i<=N;i++) {
			mu_j_s2 = J(1,nres,.)
			for(j=1;j<=nres;j++) {
				numer_like_j = quadrowsum(asarray(aghnodes,i)[j,.] :* jlnodes[i,.],1)
				mu_j_s2[1,j] = numer_like_j:/like_j[i,.]
			}
			final[i,] = mu_j_s2
		}			
	}
	else {
		nodes = cholesky(vcv)*nodesfinal
		for(i=1;i<=N;i++) {
			for(j=1;j<=nres;j++) {
				numer_like_j = quadrowsum(nodes[j,.] :* jlnodes[i,.],1)
				final[i,j] 	= numer_like_j:/like_j[i,.]								
			}
		}
	}

}	
end

/*** Mata program to calculate the stadard errors of the empirical Bayes predictions of the random effects ***/
mata:
	mata set matastrict off
	void eb_sd_preds(		string scalar ebvars, 
							string scalar s_ind,		
							numeric matrix jlnodes, 
							real scalar nres, 
							numeric matrix vcv, 
							numeric matrix nodesfinal,
							string scalar adapt,
							| transmorphic aghnodes)
{	
	
	st_view(final=.,.,tokens(ebvars),s_ind)
	N = rows(jlnodes)
	like_j = quadrowsum(jlnodes,1)
	
	if (adapt=="yes") {
		for(i=1;i<=N;i++) {
			mu_j_s2 = J(1,nres,.)
			for(j=1;j<=nres;j++) {
				numer_like_j = quadrowsum(asarray(aghnodes,i)[j,.] :* jlnodes[i,.],1)
				mu_j_s2[1,j] = numer_like_j:/like_j[i,.]
			}
							
			nn=nres:^2
			basis1 = J(cols(jlnodes),nn,.)
			
			for (k=1;k<=cols(jlnodes);k++) {
				basis1[k,.] = rowshape(asarray(aghnodes,i)[.,k] * asarray(aghnodes,i)[.,k]',1)
			}
			
			vcv_new = ((jlnodes[i,.]:/like_j[i,.]) * basis1) :- rowshape(mu_j_s2[1,.]' * mu_j_s2[1,.],1)
			sd_new = cholesky(rowshape(vcv_new,nres))
			final[i,] = diagonal(sd_new)'
		}
	}
	else {
		mu_j_s2 = J(rows(jlnodes),nres,.)
		nodes = cholesky(vcv)*nodesfinal
		
		nn = nres:^2	
		vcv_blups = J(rows(jlnodes),nn,.)

		for(i=1;i<=N;i++) {
			for(j=1;j<=nres;j++) {
				numer_like_j = quadrowsum(nodes[j,.] :* jlnodes[i,.],1)
				mu_j_s2[i,j] = numer_like_j:/like_j[i,.]														
				final[i,j] = ((quadrowsum((nodes[j,.]:^2) :* jlnodes[i,.],1)):/like_j[i,.]) :- (mu_j_s2[i,j]:^2)
			}
			
			basis1 = J(cols(jlnodes),nn,.)
			for (k=1;k<=cols(jlnodes);k++) {
				basis1[k,.] = rowshape(nodes[.,k] * nodes[.,k]',1)
			}
			
			vcv_blups[i,.] = ((jlnodes[i,.]:/like_j[i,.]) * basis1)  - rowshape(mu_j_s2[i,.]' * mu_j_s2[i,.],1)
			final[i,.] = diagonal(cholesky(rowshape(vcv_blups[i,.],nres)))'
		}
	}
	
	/* Crash */
	//test = weights[1..i,2::2000]	
	
}	
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

mata:
mata set matastrict off
		void weib_cumhaz(	string scalar smodel,
							string scalar newvar, 
							string scalar touse, 
							numeric matrix N,	
							numeric matrix lambda, 
							numeric matrix gamma, 
							numeric matrix basetime,
							numeric matrix knewnodes, 
							numeric matrix kweights,
							numeric matrix alpha_longfit_mat)
								
{
	if (smodel=="e") {
		cumhaz_nodes = lambda :* exp(alpha_longfit_mat)
	}
	else if (smodel=="w") {
		cumhaz_nodes = lambda :* gamma :* knewnodes :^ (gamma:-1) :* exp(alpha_longfit_mat)
	}
	else if (smodel=="g") {
		cumhaz_nodes = lambda :* exp(gamma :* knewnodes) :* exp(alpha_longfit_mat)
	}
	st_view(final=.,.,newvar,touse)
	final[.,.] = basetime:*quadrowsum(J(N,1,kweights):*cumhaz_nodes,1):/2
}
end


























mata:
mata set matastrict off
		void stjm_pred_marg(	string scalar newvar, 	
								string scalar prediction,
								string scalar smodel,
								real scalar N,
								numeric matrix sp1, 		
								numeric matrix sp2, 	
								numeric matrix alpha_longfit_mat,	
								numeric matrix alphas,
								numeric matrix mvn,	
								numeric matrix basetime,
								numeric matrix knewnodes,
								numeric matrix kweights,
								string scalar current,
								string scalar deriv,
								string scalar intassoc,
								string scalar timeassoc,
								string scalar touse,
								numeric matrix fp_randpows,
								numeric matrix time_assoc_ind,
								numeric matrix deriv_time_rand_dm) 		
{

	m = cols(mvn)
	nres = rows(mvn)
	assoc1 = J(N,1,0)
	
	if (smodel!="fpm")  {

		nrandpows = nres:-1
		ch_basis = J(N,m,0)
		for (k=1;k<=m;k++) {	//loop over number of draws
		
			assoc_ch = alpha_longfit_mat
			alpha_ith = 1
			
			if (current=="yes") {
				basis_ind = 1
				if (nres>1) {
					for (i=1; i<=nrandpows; i++) {
						if (fp_randpows[1,i]==0) {
							assoc_ch = assoc_ch :+ alphas[,alpha_ith]:*J(N,cols(knewnodes),mvn[basis_ind,k]):*log(knewnodes)
						}
						else {
							assoc_ch = assoc_ch :+ alphas[,alpha_ith]:*J(N,cols(knewnodes),mvn[basis_ind,k]):*(knewnodes:^J(N,cols(knewnodes),fp_randpows[1,i]))
						}
						basis_ind = basis_ind :+ 1
					}
				}
				assoc_ch = assoc_ch :+ alphas[,alpha_ith]:*J(N,cols(knewnodes),mvn[nres,k])
				alpha_ith = alpha_ith :+ 1
			}

			if (deriv=="yes") {
				basis_ind = 1
				if (nres>1) {
					for (i=1; i<=nrandpows; i++) {
						if (fp_randpows[1,i]==0) {
							assoc_ch = assoc_ch :+ alphas[,alpha_ith]:*J(N,cols(knewnodes),mvn[basis_ind,k]):/knewnodes
						}
						else {
							assoc_ch = assoc_ch :+ alphas[,alpha_ith]:*J(N,cols(knewnodes),mvn[basis_ind,k]):*(J(N,cols(knewnodes),fp_randpows[1,i]):*knewnodes:^(J(N,cols(knewnodes),fp_randpows[1,i]):-1))
						}
						basis_ind = basis_ind :+ 1							
					}
				}				
				alpha_ith = alpha_ith :+ 1
			}			
	
			if (intassoc=="yes") {
				assoc_ch = assoc_ch :+ alphas[,alpha_ith]:*J(N,cols(knewnodes),mvn[nres,k])
				alpha_ith = alpha_ith :+ 1
			}			
			
			if (timeassoc=="yes") {		
				for(i=1; i<=rows(time_assoc_ind); i++) {
					assoc_ch = assoc_ch :+ alphas[,alpha_ith]:*(J(N,cols(knewnodes),mvn[time_assoc_ind[i,1],k]))
					alpha_ith = alpha_ith :+ 1
				}	
			}
			
			if (smodel=="e") {
				test = J(1,cols(knewnodes),sp1):*exp(assoc_ch)
			}
			else if (smodel=="w") {
				test = J(1,cols(knewnodes),sp1):*J(1,cols(knewnodes),sp2):*knewnodes:^(J(1,cols(knewnodes),sp2):-1):*exp(assoc_ch)
			}
			else {
				test = J(1,cols(knewnodes),sp1):*exp(assoc_ch):*exp(J(1,cols(knewnodes),sp2):*knewnodes)
			}
			
			ch_basis[,k] = quadrowsum(J(N,1,kweights):*test,1)
			
		}
		
		ch_basis = ((basetime):/2):* ch_basis
		
		if (prediction == "survival") {
			pred 	= exp(-ch_basis)							/* Survival*/
		}
		else {						
			pred = ch_basis										/* Cumulative hazard */
		}
	
	}
	/* FPM */
	else {
		
		alpha_ith = 1
		if (current=="yes") {
			alpha_longfit_mat = alpha_longfit_mat :+ alphas[,alpha_ith] :* (fp_randpows * mvn)
			alpha_ith = alpha_ith :+ 1
		}

		if (deriv=="yes") {
			alpha_longfit_mat = alpha_longfit_mat :+  alphas[,alpha_ith] :* (deriv_time_rand_dm * mvn)
			alpha_ith = alpha_ith :+ 1
		}
		
		if (intassoc=="yes") {
			alpha_longfit_mat = alpha_longfit_mat :+  (alphas[,alpha_ith] * mvn[nres,])
			alpha_ith = alpha_ith :+ 1
		}

		if (timeassoc=="yes") {	
			ntimeassoc = rows(time_assoc_ind)
			for(i=1; i<=ntimeassoc; i++) {
				alpha_longfit_mat = alpha_longfit_mat :+  (alphas[,alpha_ith] * mvn[time_assoc_ind[i,1],])
				alpha_ith = alpha_ith :+ 1
			}	
		}		
	
		if (prediction == "survival") {
			pred = exp((-1):*exp(sp1:+alpha_longfit_mat))							/* Survival*/
		}
		else {
			pred = exp(sp1:+alpha_longfit_mat)										/* Cumulative hazard */
		}
	}

	
	st_view(final=.,.,newvar,touse)
	final[,] = quadrowsum(pred,1):/m										

	/* CRASH CODE */	
	//test = weights[1..i,2::2000]	

}				
end

mata:
mata set matastrict off
		void stjm_pred_marg_haz(	string scalar newvar, 	
									string scalar smodel,
									real scalar N,
									numeric matrix sp1, 		
									numeric matrix sp2, 	
									numeric matrix alpha_longfit_mat,	
									numeric matrix alphas,
									numeric matrix mvn,	
									numeric matrix basetime,
									string scalar current,
									string scalar deriv,
									string scalar intassoc,
									string scalar timeassoc,
									string scalar touse,
									numeric matrix time_rand_dm,
									numeric matrix deriv_time_rand_dm,
									numeric matrix time_assoc_ind) 			
{

	m = cols(mvn)
	nres = rows(mvn)
	nrandpows = nres:-1
	
	assoc1 = assoc2 = J(N,1,0)
	
	alpha_ith = 1
	if (current=="yes") {
		alpha_longfit_mat = alpha_longfit_mat :+ alphas[,alpha_ith] :* (time_rand_dm * mvn)
		alpha_ith = alpha_ith :+ 1
	}

	if (deriv=="yes") {
		alpha_longfit_mat = alpha_longfit_mat :+ alphas[,alpha_ith] :* (deriv_time_rand_dm * mvn)
		alpha_ith = alpha_ith :+ 1
	}		
	
	if (intassoc=="yes") {
		alpha_longfit_mat = alpha_longfit_mat :+ (alphas[,alpha_ith] * mvn[nres,])
		alpha_ith = alpha_ith :+ 1
	}			
	
	if (timeassoc=="yes") {
		ntimeassoc = rows(time_assoc_ind)
		for(i=1; i<=ntimeassoc; i++) {
			alpha_longfit_mat = alpha_longfit_mat :+ (alphas[,alpha_ith] * mvn[time_assoc_ind[i,1],])
			alpha_ith = alpha_ith :+ 1
		}	
	}		
	
	if (smodel=="e") {
		pred = sp1:*exp(alpha_longfit_mat)			
	}
	else if (smodel=="w") {
		pred = sp1:*sp2:*basetime:^(sp2:-1):*exp(alpha_longfit_mat)			
	}
	else {
		pred = sp1:*exp(alpha_longfit_mat:+sp2)			
	}
	
	st_view(final=.,.,newvar,touse)
	final[,] = quadrowsum(pred,1):/m								

	/* CRASH CODE */	
	//test = weights[1..i,2::2000]	

}				
end

mata:
mata set matastrict off
		void stjm_pred_marg_haz_fpm(string scalar newvar, 	
									string scalar smodel,
									real scalar N,
									numeric matrix sp1, 		
									numeric matrix sp2, 	
									numeric matrix alpha_longfit_mat,	
									numeric matrix alpha_longfit_mat2,	
									numeric matrix alphas,
									numeric matrix mvn,	
									numeric matrix basetime,
									string scalar current,
									string scalar deriv,
									string scalar intassoc,
									string scalar timeassoc,
									string scalar touse,
									numeric matrix time_rand_dm,
									numeric matrix time_assoc_ind,
									numeric matrix deriv_time_rand_dm,
									numeric matrix deriv2_time_rand_dm) 		
{
										
	alpha_ith = 1
	if (current=="yes") {
		alpha_longfit_mat  = alpha_longfit_mat  :+ alphas[,alpha_ith] :* (time_rand_dm * mvn)
		alpha_longfit_mat2 = alpha_longfit_mat2 :+ alphas[,alpha_ith] :* (deriv_time_rand_dm * mvn)
		alpha_ith = alpha_ith :+ 1
	}

	if (deriv=="yes") {
		alpha_longfit_mat  = alpha_longfit_mat  :+ alphas[,alpha_ith] :* (deriv_time_rand_dm * mvn)
		alpha_longfit_mat2 = alpha_longfit_mat2 :+ alphas[,alpha_ith] :* (deriv2_time_rand_dm * mvn)
		alpha_ith = alpha_ith :+ 1
	}
	
	if (intassoc=="yes") {
		alpha_longfit_mat = alpha_longfit_mat :+  (alphas[,alpha_ith] * mvn[rows(mvn),])
		alpha_ith = alpha_ith :+ 1
	}

	if (timeassoc=="yes") {	
		for(i=1; i<=rows(time_assoc_ind); i++) {
			alpha_longfit_mat = alpha_longfit_mat :+  (alphas[,alpha_ith] * mvn[time_assoc_ind[i,1],])
			alpha_ith = alpha_ith :+ 1
		}	
	}		
	
	pred = exp(sp1:+alpha_longfit_mat):*((sp2:/basetime):+alpha_longfit_mat2)

	st_view(final=.,.,newvar,touse)
	final[,] = quadrowsum(pred,1):/cols(mvn)									

	/* CRASH CODE */	
	//test = weights[1..i,2::2000]	

}				
end
