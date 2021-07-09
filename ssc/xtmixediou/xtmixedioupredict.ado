*! xtmixedioupredict: V2; Rachael Hughes; 26th June 2017

cap program drop xtmixedioupredict
program xtmixedioupredict, eclass
	version 11
	syntax newvarname (generate) [if] [in] [, XB STDP FITted RESiduals]

capture noisily {	
	
	tempname G Wparameters noomit_b beta noomit_V varbeta
	tempvar dataorder p_xb p_stdp p_fitted p_values intercept
	
	* IDENTIFIES THOSE OBSERVATIONS DEFINED BY if AND in
		* xtmixed DOES NOT RETURN AN ERROR IF NO OBSERVATIONS MATCH; SIMPLY RETURNS A NEW VARIABLE WITH ALL MISSING VALUES
	marksample touse, novarlist
	
	local k = ("`xb'"!="") + ("`stdp'"!="") + ("`fitted'"!="") + ("`residuals'"!="")
	if `k' > 1 {
		di as err "only one of xb, stdp, fitted or residuals should be specified"
		error 198
	}
	else if `k' ==0 {
		local xb "xb"
		local txt "(option xb assumed)"
	}
	
	local id = e(id)
	local time = e(time)
	local y = e(depvar)
	
	/*****************************************
	         PROCESS THE FIXED EFFECTS
	*****************************************/
	// _cons IS NOT ALLOWED AS A VARIABLE NAME (DOES NOT DO ANYTHING IF exp_fevars DOES NOT CONTAIN _cons)
	local exp_fevars `e(exp_fenames)' 
	quietly gen `intercept' = 1
	local feconstant `e(feconstant)'	
	if "`feconstant'" != "nofeconstant" {
		local feintercept `intercept'
		local fecons "_cons"
	}
	else {
		local feintercept ""
		local fecons ""
	}

	* IF PRESENT REPLACE _cons WITH TEMPORARY VARIABLE intercept 
		* REMOVE _cons 
	local exp_fevars : list exp_fevars - fecons
		* ADD TEMPORARY VARIABLE intercept (IF NEEDED) TO THE END OF THE LIST 
	local exp_fevars : list exp_fevars | feintercept
	
	* CREATE TEMPORARY VARIABLES FOR THE FACTORS - USE THE EXPANDED LIST WITHOUT OMITTED VARIABLES DUE TO COLLINEARITY
	fvrevar `exp_fevars' if `touse'
	local fevars `r(varlist)'
		* STRIP OFF THE BASE CATEGORIES
	version 10: quietly _rmcoll `fevars', noconstant
	local fevars `r(varlist)'
	
	/*****************************************
	        PROCESS THE RANDOM EFFECTS
	*****************************************/
	local revars `e(revars)'

	* DEFAULT SETTING ADDS A CONSTANT TERMS TO THE LIST OF RANDOM EFFECTS; CAN BE OVERRIDDEN BY SPECIFYING OPTION noreconstant 
	local reconstant `e(reconstant)'	
	if "`reconstant'" != "noreconstant" {
		local reintercept `intercept'
		local recons "_cons"
	}
	else {
		local reintercept ""
		local recons ""
	}

	* IF PRESENT REPLACE _cons WITH TEMPORARY VARIABLE intercept 
		* REMOVE _cons (IF INCLUDED) FROM THE END OF THE LIST 
	local revars : list revars - recons
		* ADD `intercept' (IF NEEDED) TO END OF THE LIST
	local revars : list revars | reintercept
	
	* EXTRACTING THE VARIANCE PARAMETERS
	matrix `G' = e(re_covariance)
	local k_res = e(k_res)
	matrix `Wparameters' = e(res_parameters)
	local sigmaSquared = `Wparameters'[1, `k_res']
	matrix `Wparameters' = `Wparameters'[1,1..`k_res'-1]
	
	* EXTRACTING THE COEFFICIENTS AND STANDARD ERRORS FOR THE FIXED EFFECTS
	matrix `noomit_b' = e(noomit_b)
	matrix `noomit_V' = e(noomit_V)
	local numFE = e(k_f)
	
	matrix `beta' = `noomit_b'[1,1..`numFE']' 
	matrix `varbeta' = `noomit_V'[1..`numFE',1..`numFE']
	
	quietly gen `p_xb' = . 
	quietly gen `p_stdp' = .
	quietly gen `p_fitted' = .
	
	* DATA NEEDS TO BE SORTED ON id AND TIME BEFORE USING FUNCTION fitted
		* GENERATE dataorder TO KEEP A RECORD OF THE USER'S ORDERING OF THE DATASET
	quietly egen `dataorder' = seq()
	quietly sort `id' `time'
	
	mata: xtmixediou_predict("`id'", "`time'", /// 
						"`y'", "`fevars'", "`revars'", ///
						"`beta'", "`varbeta'", "`G'", ///
						"`Wparameters'", `sigmaSquared', ///
						"`p_xb'", "`p_stdp'", "`p_fitted'")
	
	* RE-INSTARTE THE USER'S ORDERING OF THE DATASET
	sort `dataorder'
	
	if "`xb'" != "" {
		quietly replace `varlist' = `p_xb' if `touse'
		label variable `varlist' "Linear prediction, fixed portion"
	}
	else if "`stdp'" != "" {
		quietly replace `varlist' = `p_stdp' if `touse'
		label variable `varlist' "S.E. of the linear prediction, fixed portion"
	}
	else if "`fitted'" != "" {
		quietly replace `varlist' = `p_fitted' if `touse'
		label variable `varlist' "Fitted values: xb + Zu + w"
	}
	else {
		quietly replace `varlist' = `y' - `p_fitted' if `touse'
		label variable `varlist' "Residuals"
	}
} // END OF CAPTURE

if _rc != 0 capture drop `varlist'

end
