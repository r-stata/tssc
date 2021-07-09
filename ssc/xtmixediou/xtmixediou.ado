*! xtmixediou: V3; Rachael Hughes; 26th June 2017 
capture program drop xtmixediou
program xtmixediou, eclass
	version 11
if !replay() {
	local cmdline `0'
	syntax varlist(fv min=1 numeric) [if] [in], ID(varname) TIME(varname numeric) ///
		[noFEConstant REffects(varlist min=1 max=2 numeric) noREConstant ///
		BROWNian IOU(string) SVDATAderived ///
		ITERate(integer 16000) ALGorithm(string) DIFficult ///
		noLOg TRace GRADient HESSian SHOWSTEP ]
	
	tempvar intercept
	tempname startingValues G Rparameters b V B ll_restricted table_beta table_theta g_max g_avg g_min N_g scheme omit noomit_b noomit_V sv

*****************************************************************************************************************************************************************************************************
*                                                                         PARSING SECTION		
	* ADD COMMAND NAME TO cmdline
	local cmd "xtmixediou "
	local cmdline : list cmd | cmdline
	
	if `iterate' < 0 {
		di as error "Maximum number of iterations must be greater than 0"
		error 198	
	}
	
	* IDENTIFIES THOSE OBSERVATIONS DEFINED BY if AND in
		* RETURNS AN ERROR IF THE NUMBER OF ANALYSIS OBSERVATIONS IS LESS THAN 2
	marksample touse, strok
	quietly count if `touse'
	local N = r(N)
	if `N' < 2 {
		error 2001
	}
	
	gettoken y xvars : varlist
	local num_xvars : list sizeof xvars
	
	/***********************************
	         OUTCOME VARIABLE
	 ***********************************/	
	* ABORTS WITH ERROR IF THERE ARE FACTOR VARIABLES IN THE DEPENDENT VARIABLE
	_fv_check_depvar `y'
	
	/************************************
	           FIXED EFFECTS
	************************************/	
	* DEFAULT SETTING ADDS A CONSTANT TERM TO THE LIST OF FIXED EFFECTS; CAN BE OVERRIDDEN BY SPECIFYING OPTION nofeconstant 
		* CONSTANT TERM NOT YET ADDED TO LIST OF FIXED EFFECTS DUE TO CHECKING OF COLLINEARITY 
	quietly gen `intercept' = 1 if `touse'
	if "`feconstant'" != "nofeconstant" {
		local feintercept `intercept'
		local fecons "_cons"
	}
	else {
		local feintercept ""
		local fecons ""
		
		if `num_xvars'==0 {
			di as error "No variables specfied for the fixed effects"
			error 102	
		}
	}
		
	* DETECTING COLLINEARITY IN THE FIXED EFFECTS (AND WITH THE DEPENDENT VARIABLE)
		* ALSO EXPANDS ANY FACTOR VARIABLES
		* INTERCEPT NEEDS TO BE PLACED FIRST TO STOP IT BEING FLAGGED AS "OMITTED" DUE TO POSSIBLE COLLINEARITY WITH OTHER VARIABLES (E.G. BASE REFERENCE CATEGORY)
	_rmdcoll `y' `feintercept' `xvars' if `touse', noconstant
	local exp_fevars `r(varlist)'

	* MOVE THE CONSTANT TERM (IF NEEDED) TO THE END OF THE LIST OF FIXED EFFECTS
		* REMOVE THE CONSTANT TERM (IF INCLUDED) FROM THE BEGINNING OF THE LIST OF exp_fevars
	local exp_fevars : list exp_fevars - feintercept
			* ADD _cons (IF NEEDED) TO THE END OF THE LIST OF NAMES OF exp_fevars
	local exp_fenames : list exp_fevars | fecons
		* ADD `intercept' (IF NEEDED) TO END OF THE LIST OF exp_fevars
	local exp_fevars : list exp_fevars | feintercept
		
	* NUMBER OF EXPANDED VARIABLES; 
		* exp_fenames ARE THE COLUMN (AND ROW) NAMES OF e(b) (AND e(V))
	local colsb_fe : list sizeof exp_fenames
	
	* CREATE VECTOR omit WHICH LABELS WHICH VARIABLES OF exp_fevars ARE (AND ARE NOT) OMITTED
	matrix `omit' = J(1,`colsb_fe',0)
	local tempcounter 0
	local column 0
	foreach variable of local exp_fevars {
		local column = `column' + 1
		
		* EXTRACTS INFORMATION ABOUT variable
		_ms_parse_parts `variable'
		
		* LABEL THE OMITTED VARIABLE	
		if r(omit)==1 matrix `omit'[1,`column'] = 1		
		
	} // END OF foreach LOOP
	
	* CREATE TEMPORARY VARIABLES FOR THE FACTORS - USE THE EXPANDED LIST WITHOUT OMITTED VARIABLES DUE TO COLLINEARITY
	fvrevar `exp_fevars' if `touse'
	local fevars `r(varlist)'
		* STRIP OFF THE BASE CATEGORY 
	version 10: quietly _rmcoll `fevars', noconstant
	local fevars `r(varlist)'
	local numFE : list sizeof fevars
	
	/************************************
	           RANDOM EFFECTS
	************************************/	
	* ERROR CHECKING
	if "`reffects'"=="" & "`reconstant'" == "noreconstant" {
		di as error "No variables specfied for the random effects"
		error 102	
	}

	* DEFAULT SETTING ADDS A CONSTANT TERMS TO THE LIST OF RANDOM EFFECTS; CAN BE OVERRIDDEN BY SPECIFYING OPTION noreconstant 
	if "`reconstant'" != "noreconstant" {
		local reintercept `intercept'
		local recons "_cons"
	}
	else {
		local reintercept ""
		local recons ""
	}
	
	* DETECTING COLLINEARITY IN THE RANDOM EFFECTS 
	* INTERCEPT NEEDS TO BE ADDED FIRST TO STOP IT BEING DROPPED DUE TO POSSIBLE COLLINEARITY WITH OTHER VARIABLES
	version 10: _rmcoll `reintercept' `reffects' if `touse', noconstant
	local reffects `r(varlist)'
	local numRE : list sizeof reffects

	* MOVE THE CONSTANT TERM (IF NEEDED) TO THE END OF THE LIST OF RANDOM EFFECTS
		* REMOVE THE CONSTANT TERM (IF INCLUDED) FROM THE BEGINNING OF THE LIST OF reffects
	local reffects : list reffects - reintercept
			* ADD _cons (IF NEEDED) TO THE END OF THE LIST OF NAMES OF renames
	local renames : list reffects | recons
		* ADD `intercept' (IF NEEDED) TO END OF THE LIST OF reffects
	local reffects : list reffects | reintercept

	local arctanGnames ""	
	local G_names ""	
	forvalues row=1(1)`numRE' {
		local entry "ln_sd[RE`row']"
		local arctanGnames : list arctanGnames | entry
		local entry "var[RE`row']"
		local G_names : list G_names | entry

		local rowplus1 = `row'+1
		forvalues column=`rowplus1'(1)`numRE' {
			local entry "at_corr[RE`row',RE`column']"
			local arctanGnames : list arctanGnames | entry
			local entry "cov[RE`row',RE`column']"
			local G_names : list G_names | entry
		}
	}
	local numberOfGparas = 0.5*`numRE'*(`numRE'+1)

	/************************************************************************
	                  IOU PARAMETERIZATION OR BROWNIAN MOTION
	   IF BROWNIAN MOTION AND IOU ARE SPECIFIED BROWNIAN MOTION IS ASSUMED
	 ************************************************************************/
	if "`brownian'" == "" {						// IOU DEFAULT MODEL 
		local numberOfRparas 3
		local lnRnames "ln_alpha ln_tau ln_sigma"
		local R_names "alpha tau var[ME]"
		local Weffects "IOU-effects"
		
		if "`iou'"=="at" | "`iou'"=="" {		// DEFAULT IOU PARAMETERIZATION IS alphatau
			local Rparameterization 1
			local iou_parameters "alpha, tau"						
		}
		else if "`iou'"=="ao" {		
			local Rparameterization 2
			local iou_parameters "alpha, omega"						
		}
		else if "`iou'"=="et" {		
			local Rparameterization 3
			local iou_parameters "eta, tau"		
		}
		else if "`iou'"=="eo" {		
			local Rparameterization 4
			local iou_parameters "eta, omega"		
		}
		else if "`iou'"=="it" {		
			local Rparameterization 5
			local iou_parameters "iota, tau"		
		}
		else if "`iou'"=="io" {		
			local Rparameterization 6
			local iou_parameters "iota, omega"		
		}	
		else {
			di as error "`iou' is an invalid IOU parameterization"
			error 198	
		}
	}
	else {
		local numberOfRparas 2
		local lnRnames "ln_phi ln_sigma"
		local R_names "phi var[ME]"
		local Weffects "BM-effects"

		local Rparameterization 8
		local iou_parameters "Brownian-motion"			
	}
	
	// PARAMETER EQUATION NAMES FOR MATRICES b AND V
		// FIRST, ADD THE NAMES OF THE FIXED EFFECTS
	local b_eqnames ""
	forvalues i=1(1)`colsb_fe' {
		local b_eqnames = `"`b_eqnames' `y'"'
	}
		// SECOND, ADD _anc FOR THETA PARAMETERS 
		// APPLICATION OF b_eqnames ASSUMES THAT _anc IS APPLIED FOR THE REMAINDER OF THE coleq OR roweq
	local anc "_anc"
	local b_eqnames = `"`b_eqnames' `anc'"'
	
	local numTheta = `numberOfGparas' + `numberOfRparas'

	* PARAMETER NAMES FOR MATRICES b AND V
	local b_names : list exp_fenames | arctanGnames			// ADD G PARAMETERS
	local b_names : list b_names | lnRnames      			// ADD THE NAMES OF THE R PARAMETERS	
	local colsb : list sizeof b_names						
	
	* PARAMETER NAMES FOR MATRIX sv 
	local sv_names : list G_names | R_names
	
	* LABEL ALL VARIANCE PARAMETERS AS NOT TO BE OMITTED - THIS DOES NOT HANDLE COLLINEAR RE-EFFECTS
	matrix `omit' = (`omit',J(1,`numTheta',0))
	
	/******************************
	       MAXIMIZE OPTIONS
	*******************************/
	capture matrix drop `scheme'
	local numWords = wordcount("`algorithm'")
	if `numWords' == 0 {
		matrix `scheme' = (1,`iterate')
	}
	else {
		local nth_word 1
		while `nth_word' < = `numWords' {
			local word1 = word("`algorithm'",`nth_word')
			local word2 = word("`algorithm'",`nth_word'+1)
			local real_word2 = real("`word2'")
		
			// ASSUME 5 ITERATIONS IF NONE SPECIFIED
			if `real_word2' ==. local real_word2 5 
			else local nth_word = `nth_word' + 1
		
			if "`word1'"=="nr" {
				matrix `scheme' = nullmat(`scheme') \ (1,`real_word2')
			}
			else if "`word1'"=="fs" {
				matrix `scheme' = nullmat(`scheme') \ (2,`real_word2')
			}	 
			else if "`word1'"=="ai" {
				matrix `scheme' = nullmat(`scheme') \ (3,`real_word2')
			} 
			else {
				di as error "`word1' is not a valid argument of algorithm() option"
				exit(198)
			}
			local nth_word = `nth_word' + 1
		}
		// IF ONLY ONE ALGORITHM IS SPECIFIED THEN SET THE NUMBER OF ITERATIONS TO THE MAXIMUM LEVEL
			// EVEN IF THE USER HAS SPECIFIED THE NUMBER OF ITERATIONS THAT IS LESS THAN THE MAXIMUM LEVEL 
			// e.g. FS 3 IS EQUIVALENT OF FS WITH 3 ITERATIONS ON A CONTINUOUS LOOP UNTIL CONVERGENCE OR MAXIMUM LEVEL IS REACHED
		local numSchemes = rowsof(`scheme')
		if `numSchemes' == 1 {
			matrix `scheme'[1,2] = `iterate'
		}
		else {
			matrix `scheme'[1,2] = `scheme'[1..`numSchemes', 2] - J(`numSchemes',1,1)
		}		
	} // END OF else STATEMENT
	//matrix list `scheme'
	
	if "`difficult'" == "" local singularHmethod "m-marquardt"
	else local singularHmethod "hybrid"
		
	foreach tracelevel in trace gradient showstep hessian {
		if "``tracelevel''" == "" local tr_`tracelevel' "off"
		else local tr_`tracelevel' "on"
	}	

	if "`log'" != "nolog" local tr_log "value"
	else local tr_log "none"

	/****************************
	      STARTING VALUES
	*****************************/
	if "`svdataderived'" == "" local svmethod 1
	else {
		local svmethod 2 
	
		if `numRE' > 2 {
			di as error "option svdataderived allows a maximum of 2 random effects; a random intercept and/or a random slope"
			error 103
		}	
	}
		
*****************************************************************************************************************************************************************************************************
*                                                                       ESTIMATION 
	/*******************************
	 CALCULATION OF STARTING VALUES
	*******************************/ 
	preserve
	quietly keep if `touse' == 1                                                                  	
	quietly xtmixediou_sv `y' "`fevars'" "`reffects'" "`id'" `time' `svmethod' `Rparameterization'
	matrix `startingValues' = r(sv_thetastar)
	matrix `sv' = r(sv_theta)
	matrix colnames `sv' = `sv_names'
	restore, preserve
	quietly keep if `touse' == 1     

	/************************
	        ESTIMATION
	************************/ 
	sort `id' `time'
	mata: xtmixediou_estimation("`id'", "`y'", "`fevars'", "`reffects'", "`time'", `Rparameterization', "`startingValues'", ///
	                       "`scheme'", "`singularHmethod'", "`tr_log'", "`tr_trace'", "`tr_gradient'", "`tr_showstep'", ///
						   "`tr_hessian'", `iterate')
	local converged = r(converged)
	local errorCode = r(errorCode)
	local ll_reml = r(ll_reml)
	local numberOfObs = r(numberOfObs)
	local numberOfPanels = r(numberOfPanels)
	local min_ni = r(min_ni)
	local max_ni = r(max_ni)
	local avg_ni = round(`numberOfObs'/`numberOfPanels', 0.1)

	matrix `g_max' = (`max_ni')
	matrix `g_avg' = (`avg_ni')
	matrix `g_min' = (`min_ni')
	matrix `N_g'   = (`numberOfPanels')
	matrix `G' = r(G)
	matrix `Rparameters' = r(Rparameters)
	matrix `noomit_b' = r(b)								// ESTIMATES; DOES NOT INCLUDE COLUMNS FOR OMITTED OR REFERENCE VARIABLES
	matrix `noomit_V' = r(V)								// COVARIANCES; DOES NOT INCLUDE ROWS NOR COLUMNS FOR OMITTED OR REFERENCE VARIABLES
	matrix `table_beta' = r(table_beta)
	matrix `table_theta' = r(table_theta)
	local k_v = rowsof(`table_theta')
	
	* FILL IN e(b) AND e(V) WITH ENTRIES FOR THE OMITTED VARIABLES
	matrix `b' = J(1,`colsb',0)
	matrix `V' = J(`colsb',`colsb',0)
		* LABEL ROWS AND COLUMNS OF e(b) AND e(V)
	matrix colnames `b' = `b_names'
	matrix coleq `b' = `b_eqnames'
	matrix rownames `V' = `b_names'
	matrix colnames `V' = `b_names'
	matrix roweq `V' = `b_eqnames'
	matrix coleq `V' = `b_eqnames'

	local col_entry 0
	forvalues column=1(1)`colsb' {
		local omitting = `omit'[1,`column']
		
		if `omit'[1,`column']==0 {
			local col_entry = `col_entry' + 1
			
			matrix `b'[1,`column'] = `noomit_b'[1,`col_entry'] 
			matrix `V'[`column',`column'] = `noomit_V'[`col_entry',`col_entry']		
			
			local colplus1 = `column'+1
			local row_entry = `col_entry'
			forvalues row=`colplus1'(1)`colsb' {
				local omitting = `omit'[1,`row']
				
				if `omit'[1,`row']==0 {
					local row_entry = `row_entry' + 1
					
					matrix `V'[`row',`column'] = `noomit_V'[`row_entry',`col_entry']					
					matrix `V'[`column',`row'] = `V'[`row',`column']
				}
			}
		}
	}
	
	* TOTAL NUMBER OF PARAMETERS (EXCLUDING OMITTED AND REFERENCE CATEGORIES)
	local k = `numFE' + `numTheta'

*****************************************************************************************************************************************************************************************************
*                                                              DISPLAY THE RESULTS 

	/***********************************
	         POST THE RESULTS
	************************************/
	ereturn post `b' `V', depname(`y') obs(`N') properties("b V") findomitted buildfvinfo /// NOT SPECIFYING DOF AS DIFFICULT TO CALCULATE FOR LMMs 

	ereturn scalar N = `numberOfObs'
	ereturn scalar k = `k'
	ereturn scalar k_f = `numFE'
	ereturn scalar k_r = `numberOfGparas'
	ereturn scalar k_res = `numberOfRparas'
	ereturn scalar ll = `ll_reml'
	ereturn scalar converged = `converged'
	ereturn hidden scalar errorCode = `errorCode'	
	
	ereturn local cmd "xtmixediou"				// STATA RECOMMENDS TO STORE THIS RESULT LAST
	ereturn local cmdline "`cmdline'"
	ereturn local title "Linear mixed IOU REML regression"
	ereturn local redim "`numRE'"
	ereturn local iou "`iou_parameters'"		
	ereturn local id "`id'"
	ereturn local time "`time'"
	ereturn local revars "`renames'"
	ereturn local method "REML"
	ereturn local algorithm "`algorithm'"
	ereturn local opt "optimize"
	ereturn local ml_method "d2"
	ereturn local predict xtmixedioupredict
	ereturn hidden local Weffects "`Weffects'"	
	ereturn hidden local R_names "`R_names'"	
	ereturn hidden local exp_fenames "`exp_fenames'"	
	ereturn hidden local feconstant "`feconstant'"	
	ereturn hidden local reconstant "`reconstant'"	
	
	ereturn matrix g_max `g_max'
	ereturn matrix g_avg `g_avg'
	ereturn matrix g_min `g_min'
	ereturn matrix N_g   `N_g'
	ereturn matrix sv    `sv'
	ereturn hidden matrix re_covariance `G'
	ereturn hidden matrix res_parameters `Rparameters'
	ereturn hidden matrix table_beta `table_beta'	
	ereturn hidden matrix table_theta `table_theta'	
	ereturn hidden matrix noomit_b `noomit_b'	
	ereturn hidden matrix noomit_V `noomit_V'	

	/**************************************
	   DISPLAY THE RESULTS TO THE SCREEN
	***************************************/
	noi xtmixediou_display 

	restore
	ereturn repost, esample(`touse')
}	
else { // REPLAY
	if "`e(cmd)'"!="xtmixediou" error 301
	
	/****************************************
	   RE-DISPLAY THE RESULTS TO THE SCREEN
	*****************************************/
	noi xtmixediou_display 
}
end
