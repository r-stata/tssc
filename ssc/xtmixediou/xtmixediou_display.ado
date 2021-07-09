* V1
capture program drop xtmixediou_display
program xtmixediou_display
	version 11.0
	
	tempname g_max g_avg g_min N_g table_beta table_theta 
	
	matrix `g_max' = e(g_max)
	matrix `g_avg' = e(g_avg)
	matrix `g_min' = e(g_min)
	matrix `N_g' = e(N_g)
	matrix `table_beta' = e(table_beta)
	matrix `table_theta' = e(table_theta)
	
	local y `e(depvar)'
	local numberOfObs `e(N)'
	local fe_names `e(fevars)'
	local re_names `e(revars)'
	local numRE : list sizeof re_names
	local numberOfGparas `e(k_r)'
	local R_names `e(R_names)'
	local numberOfRparas `e(k_res)'	
	local exp_fenames `e(exp_fenames)'
	local Weffects `e(Weffects)'
	local ll_reml `e(ll)'
	local errorCode `e(errorCode)'
	
	local numberOfPanels = `N_g'[1,1]
	local min_ni = `g_min'[1,1]
	local avg_ni = `g_avg'[1,1]
	local max_ni = `g_max'[1,1]
	
	* CONSTANTS FOR LAYOUT OF DISPLAY
	local reportbase "false"
	local fe_varlength 14
	local fe_resultslength 63
	local totallength = `fe_varlength' + `fe_resultslength' 
	local fe_ralign = `fe_varlength' - 1
	local fe_vline = `fe_varlength' + 1
	local fe_coef = `fe_vline' + 5
	local fe_se = `fe_vline' + 15
	local fe_z = `fe_vline' + 28
	local fe_p = `fe_vline' + 35
	local fe_ci = `fe_vline' + 44
	local fe_coef_result = `fe_vline' + 2
	local fe_se_result = `fe_vline' + 13
	local fe_z_result = `fe_vline' + 26
	local fe_p_result = `fe_vline' + 35
	local fe_lci_result = `fe_vline' + 43
	local fe_uci_result = `fe_vline' + 55
	local fe_factorlength
	
	local re_varlength = `fe_varlength' + 15
	local re_resultslength = `totallength' - `re_varlength'
	local re_ralign = `re_varlength' - 1
	local re_vline = `re_varlength' + 1
	local re_coef = `re_vline' + 4
	local re_se = `re_vline' + 15
	local re_ci = `re_vline' + 29
	local re_coef_result = `re_vline' + 3
	local re_se_result = `re_vline' + 14
	local re_lci_result = `fe_lci_result' 
	local re_uci_result = `fe_uci_result' 

	local header1 = `totallength' - 33
	local header2 = `totallength' - 13
	local header3 = `totallength' - 8
	
	noi di _newline(2)
	noi di as text "Linear mixed IOU REML regression"                        _col(`header1') "Number of obs	 "    _col(`header2') "="  ///
	                                                                         _col(`header3') as result "{ralign 10:`numberOfObs'}"                                                                                           
	noi di                                                                   _col(`header1') as text "Number of groups" _col(`header2') "="  ///
	                                                                         _col(`header3') as result "{ralign 10:`numberOfPanels'}"
	noi di _newline
	
	noi di                                                                   _col(`header1') as text "Obs per group : min " _col(`header2') "="  ///
	                                                                         _col(`header3') as result "{ralign 10:`min_ni'}"
	noi di                                                                   _col(`header1') as text "                avg " _col(`header2') "="  ///
	                                                                         _col(`header3') as result "{ralign 10:`avg_ni'}"
	noi di as text "Restricted log likelihood = " as result %10.0g `ll_reml' _col(`header1') as text "                max " _col(`header2') "="  ///
	                                                                         _col(`header3') as result "{ralign 10:`max_ni'}"
	/******************************
	     FIXED EFFECTS RESULTS	
	******************************/
	// FE HEADER
	noi di as text "{hline `fe_varlength'}{c TT}{hline `fe_resultslength'}"
	local abbreviated = abbrev("`y'",`fe_varlength')
	noi di as text  "{ralign `fe_ralign':`abbreviated'}" _col(`fe_vline') "{c |}" _col(`fe_coef') "Coef." _col(`fe_se') "Std. Err." _col(`fe_z') "z" _col(`fe_p') "P >|z|" _col(`fe_ci') "[95% Conf. Interval]"
	noi di as text "{hline `fe_varlength'}{c +}{hline `fe_resultslength'}"
	
	// LOOP THROUGH ALL OF THE EXPANDED FIXED EFFECTS
	tokenize `exp_fenames'
	local varnum 1
	local row_tb 0
	while "``varnum''" != "" {
		* EXTRACTS INFORMATION ABOUT variable
		local variable = "``varnum''"
		_ms_parse_parts `variable'
		local name "`r(name)'"
		local base = r(base)
        local level = r(level) 
        local omit = r(omit)
        local op = "`r(op)'"
		local vartype = "`r(type)'"
		
		if "`vartype'"=="variable" & `omit'==0 {								// STANDARD VARIABLE
			local row_tb = `row_tb' + 1
			
			local abbreviated = abbrev("`name'",`fe_varlength')
			
			noi di as text "{ralign `fe_ralign':`abbreviated'}" _col(`fe_vline') "{c |}" _col(`fe_coef_result') as result %9.0g `table_beta'[`row_tb',1] ///
				_col(`fe_se_result') %9.0g `table_beta'[`row_tb',2] _col(`fe_z_result') %4.2f `table_beta'[`row_tb',3] _col(`fe_p_result') %4.3f `table_beta'[`row_tb',4] ///
				_col(`fe_lci_result') %9.0g `table_beta'[`row_tb',5]  _col(`fe_uci_result') %9.0g `table_beta'[`row_tb',6] 
				
			local space "false"			
		}
		else if "`vartype'"=="variable" & `omit'==1 {							// OMITTED VARIABLE DUE TO COLLINEARITY 
			if "`space'"=="false" {
				noi di as text _col(`fe_vline') "{c |}" 
			}

			local abbreviated = abbrev("`name'",`fe_varlength')
			noi di as text "{ralign `fe_ralign':`abbreviated'}" _col(`fe_vline') "{c |}" _col(`fe_coef_result') as result %9.0g 0 _col(`fe_se_result') as text "(omitted)" 
			
			noi di as text _col(`fe_vline') "{c |}" 
			local space "true"		
		}
		else if "`vartype'"=="factor" {											// FACTOR VARIABLE (ESTIMATED; OMITTED; REFERENCE)  
			if "`space'"=="false" {
				noi di as text _col(`fe_vline') "{c |}" 
			}
			
			local abbreviated = abbrev("`name'",`fe_varlength')
			noi di as text "{ralign `fe_ralign':`abbreviated'}" _col(`fe_vline') "{c |}" 

			* NAME OF VARIABLE'S VALUE LABEL
			local name_valuelabel: value label `name'	
			
			* LOOP THROUGH ALL THE FACTOR LEVELS OF variable
			while ("`name'"=="`r(name)'") {
				* EXTRACT VALUE LABEL
				if "`name_valuelabel'"!="" local name_value: label `name_valuelabel' `r(level)'
				else local name_value "`r(level)'"

				if r(base)==0 & r(omit)==0 {									// ESTIMATED FACTOR LEVEL
					local row_tb = `row_tb' + 1
					
					local abbreviated = abbrev("`name_value'",`fe_varlength')
				
					noi di as text "{ralign `fe_ralign':`abbreviated'}" _col(`fe_vline') "{c |}" _col(`fe_coef_result') as result %9.0g `table_beta'[`row_tb',1] ///
						_col(`fe_se_result') %9.0g `table_beta'[`row_tb',2] _col(`fe_z_result') %4.2f `table_beta'[`row_tb',3] _col(`fe_p_result') %4.3f `table_beta'[`row_tb',4] ///
						_col(`fe_lci_result') %9.0g `table_beta'[`row_tb',5]  _col(`fe_uci_result') %9.0g `table_beta'[`row_tb',6] 
				}
				else if r(base)==0 & r(omit)==1 {								// OMITTED FACTOR LEVEL
					local abbreviated = abbrev("`name_value'",`fe_varlength')
				
					noi di as text "{ralign `fe_ralign':`abbreviated'}" _col(`fe_vline') "{c |}" _col(`fe_coef_result') as result %9.0g 0 _col(`fe_se_result') as text "(omitted)" 
				}
				else if r(base)==1 & "`reportbase'" == "true" {
					
					local abbreviated = abbrev("`name_value'",`fe_varlength')

					noi di as text "{ralign `fe_ralign':`abbreviated'}" _col(`fe_vline') "{c |}" _col(`fe_coef_result') as result %9.0g 0 _col(`fe_se_result') as text "(base)" 				
				}			
				
				* PROCESS THE NEXT VARIABLE
				local varnum = `varnum' + 1
				local factorvariable = "``varnum''"
				_ms_parse_parts `factorvariable'
			
			} // END OF while LOOP THROUGH FACTOR LEVELS OF variable
			
			// UPDATED varnum UNTIL ``varnum'' IS NO LONGER A FACTOR LEVEL OF variable; NEED TO DE-INCREMENT varnum TO AVOID SKIPPING THE NEXT VARIABLE
			local varnum = `varnum' - 1
			
			noi di as text _col(`fe_vline') "{c |}" 
			local space "true"	
		
		} // END OF if else STATEMENT FOR FACTOR VARIABLES	
		else if "`vartype'"=="interaction" {
			
			if "`space'"=="false" {
				noi di as text _col(`fe_vline') "{c |}" 
			}
			
			* LOOP THROUGH THE VARIABLES OF THE INTERACTION TO DERIVE AN INTERACTION NAME AND VALUE LABELS
			local k_names = r(k_names)
			local abbrev_length = round(`fe_varlength'/`k_names')
			local intername ""
			forvalues i=1(1)`k_names' {
				
				* GENERATE INTERACTION NAME 
				local name`i' `r(name`i')'
				if strmatch("`r(op`i')'","*c*")==1 local name`i' = "c." + "`name`i''"	   // ADDS c. IF A CONTINUOUS VARIABLE	
				local abbreviated = abbrev("`name`i''",`abbrev_length')
				if `i' == 1 local intername = "`abbreviated'"
				else local intername = "`intername'" + "#" + "`abbreviated'"
				
				* NAME OF VALUE LABELS
				local inter_valuelabel`i': value label `r(name`i')'
			}	
			local displayed_interactionName 0

			* LOOP THROUGH THE INTERACTION LEVELS OF ``varnum'' UNTIL A NON-INTERACTION VARIABLE OR AN INTERACTION BETWEEN DIFFERENT VARIABLES
			local new_intername "`intername'"
			while ("`new_intername'"=="`intername'" & "`r(type)'"=="interaction") {
				
				* LOOP THROUGH THE VARIABLES OF THE INTERACTION 
					* COUNT THE NUMBER OF base ENTRIES, BUILD THE APPROPRIATE COUNT STATEMENT, BUILD THE INTERACTION VALUE LABEL
				local counting = "quietly count if "			
				local inter_N 0
				local base 0
				local inter_op 0
				local inter_levels ""
				local inter_omit = r(omit)
				forvalues i=1(1)`k_names' {
				
					* IF `r(name`i')' IS NOT A CONTINUOUS VARIABLE
					if strmatch("`r(op`i')'","*c*")==0 {
						
						* COUNT THE NUMBER OF base ENTRIES
						local base = `base' + r(base`i')
						
						* EXTRACT VALUE LABEL
						if "`inter_valuelabel`i''"!="" local inter_value`i': label `inter_valuelabel`i'' `r(level`i')'
						else local inter_value`i' "`r(level`i')'"
						
						*  BUILD THE APPROPRIATE COUNT STATEMENT AND INTERACTION VALUE LABEL
						local inter_abbrevalue`i' = abbrev("`inter_value`i''",`abbrev_length')
						if `i' == 1 {
							local inter_levels = "`inter_abbrevalue`i''"
						    local counting = "`counting'" + "`r(name`i')'==`r(level`i')' "
						}
						else {
							local inter_levels = "`inter_levels'" + "#" + "`inter_abbrevalue`i''"
							local counting = "`counting'" + "& `r(name`i')'==`r(level`i')' "
						}
					} 
					else {
						local inter_op = `inter_op' + 1
					}
				} // END OF LOOP THROUGH k_names OF ``varnum''
					
				// DISPLAY RESULTS OF AN INTERACTION BETWEEN CONTINUOUS VARIABLES ONLY
				if `inter_op' == `k_names' {
					if `inter_omit'==0 {												// ESTIMATED INTERACTION BETWEEN CONTINUOUS VARIABLES ONLY
						local row_tb = `row_tb' + 1
					
						noi di as text "{ralign `fe_ralign':`intername'}" _col(`fe_vline') "{c |}" _col(`fe_coef_result') as result %9.0g `table_beta'[`row_tb',1] ///
							_col(`fe_se_result') %9.0g `table_beta'[`row_tb',2] _col(`fe_z_result') %4.2f `table_beta'[`row_tb',3] _col(`fe_p_result') %4.3f `table_beta'[`row_tb',4] ///
							_col(`fe_lci_result') %9.0g `table_beta'[`row_tb',5]  _col(`fe_uci_result') %9.0g `table_beta'[`row_tb',6] 
					}
					else if `inter_omit'==1 {		     								// OMITTED INTERACTION BETWEEN CONTINUOUS VARIABLES
						noi di as text "{ralign `fe_ralign':`intername'}" _col(`fe_vline') "{c |}" _col(`fe_coef_result') as result %9.0g 0 _col(`fe_se_result') as text "(omitted)" 
					}
				}
				else { // DISPLAY RESULTS OF AN INTERACTION WHERE AT LEAST ONE VARIABLE IS CATEGORICAL
					if `displayed_interactionName'==0 { 
						noi di as text "{ralign `fe_ralign':`intername'}" _col(`fe_vline') "{c |}" 
						local displayed_interactionName 1
					}
						
					* COUNT THE NUMBER OF OBSERVATIONS WITHIN THE INTERACTION CELL UNLESS INTERACTION BETWEEN ONLY CONTINUOUS VARIABLES
					if `inter_op' != `k_names' {
						`counting'
						local freq = r(N)
					}
					else {
						local freq 1000
					}
					
					if `base'!=`k_names' & `inter_omit'==0 {						// ESTIMATED INTERACTION LEVEL
						local row_tb = `row_tb' + 1
						
						local abbreviated = abbrev("`inter_levels'",`fe_varlength')
					
						noi di as text "{ralign `fe_ralign':`abbreviated'}" _col(`fe_vline') "{c |}" _col(`fe_coef_result') as result %9.0g `table_beta'[`row_tb',1] ///
							_col(`fe_se_result') %9.0g `table_beta'[`row_tb',2] _col(`fe_z_result') %4.2f `table_beta'[`row_tb',3] _col(`fe_p_result') %4.3f `table_beta'[`row_tb',4] ///
							_col(`fe_lci_result') %9.0g `table_beta'[`row_tb',5]  _col(`fe_uci_result') %9.0g `table_beta'[`row_tb',6] 
					}
					else if `base' == 0 & `inter_omit'==1 & `freq' > 0 {		     // OMITTED INTERACTION BUT NOT BECAUSE IT IS A REFERENCE CATEGORY
						local abbreviated = abbrev("`inter_levels'",`fe_varlength')
					
						noi di as text "{ralign `fe_ralign':`abbreviated'}" _col(`fe_vline') "{c |}" _col(`fe_coef_result') as result %9.0g 0 _col(`fe_se_result') as text "(omitted)" 
					}
					else if `base' == 0 & `inter_omit'==1 & `freq'==0 {			   // EMPTY INTERACTION CELL
						local abbreviated = abbrev("`inter_levels'",`fe_varlength')
					
						noi di as text "{ralign `fe_ralign':`abbreviated'}" _col(`fe_vline') "{c |}" _col(`fe_coef_result') as result %9.0g 0 _col(`fe_se_result') as text "(empty)" 
					}
				} // END OF IF/ELSE STATEMENT
				
				* DERIVE THE INTERACTION NAME OF THE NEXT VARIABLE
				local varnum = `varnum' + 1
				_ms_parse_parts ``varnum''
				
				local new_intername ""
				if "`r(type)'"=="interaction" {
					local k_names = r(k_names)
					local abbrev_length = round(`fe_varlength'/`k_names')
					forvalues i=1(1)`k_names' {
						local name`i' `r(name`i')'
						if strmatch("`r(op`i')'","*c*")==1 local name`i' = "c." + "`name`i''"	   // ADDS c. IF A CONTINUOUS VARIABLE	
						local abbreviated = abbrev("`name`i''",`abbrev_length')
						if `i' == 1 local new_intername = "`abbreviated'"
						else local new_intername = "`new_intername'" + "#" + "`abbreviated'"
					}					
				}
				
			} // END OF while LOOP THROUGH INTERACTION LEVELS OF ``varnum''
			
			// UPDATED varnum UNTIL ``varnum'' IS NO LONGER THE REQUIRED INTERACTION LEVEL OF variable; NEED TO DE-INCREMENT varnum TO AVOID SKIPPING THE NEXT VARIABLE
			local varnum = `varnum' - 1
			
			noi di as text _col(`fe_vline') "{c |}" 
			local space "true"		

		} // END OF else if STATEMENT FOR INTERACTION VARIABLES
		  
		local varnum = `varnum' + 1
	} // END OF while LOOP THROUGH exp_fenames
	
	noi di as text "{hline `fe_varlength'}{c BT}{hline `fe_resultslength'}"

	/*********************
	   VARIANCE RESULTS
	*********************/
	// HEADER
	noi di as text "{hline `re_varlength'}{c TT}{hline `re_resultslength'}"
	noi di as text "{center `re_varlength':Variance parameters}" _col(`re_vline') "{c |}" _col(`re_coef') "Estimate" _col(`re_se') "Std. Err." _col(`re_ci') "[95% Conf. Interval]"
	noi di as text "{hline `re_varlength'}{c +}{hline `re_resultslength'}"

	// RANDOM-EFFECTS
	tokenize `re_names'
	noi di _col(1) as text "Random-effects:" _col(`re_vline') "{c |}"
	local counter 0
	forvalues row=1(1)`numRE' {
		// VARIANCE
		local counter = `counter' + 1
		local abbreviatedRErow = abbrev("``row''",12)
		noi di as text "{ralign `re_ralign':Var(`abbreviatedRErow')}"  _col(`re_vline') "{c |}" _col(`re_coef_result') as result %9.0g `table_theta'[`counter',1] ///
		_col(`re_se_result') %9.0g `table_theta'[`counter',2] ///
		_col(`re_lci_result') %9.0g `table_theta'[`counter',3]  _col(`fe_uci_result') %9.0g `table_theta'[`counter',4]  

		local rowplus1 = `row'+1 
		forvalues column=`rowplus1'(1)`numRE' {
			// COVARIANCE
			local counter = `counter' + 1
			local abbreviatedREcol = abbrev("``column''",12)
			noi di as text "{ralign `re_ralign':Cov(`abbreviatedRErow',`abbreviatedREcol')}"  _col(`re_vline') "{c |}" _col(`re_coef_result') as result %9.0g `table_theta'[`counter',1] ///
			_col(`re_se_result') %9.0g `table_theta'[`counter',2] ///
			_col(`re_lci_result') %9.0g `table_theta'[`counter',3]  _col(`re_uci_result') %9.0g `table_theta'[`counter',4]  
		}
	}	
	noi di as text "{hline `re_varlength'}{c +}{hline `re_resultslength'}"
	
	// IOU PARAMETERS
	noi di _col(1) as text "`Weffects':" _col(`re_vline') "{c |}"
	local numW = `numberOfRparas' - 1
	tokenize `R_names'
	forvalues column=1(1)`numW' {
		local row =  `numberOfGparas' + `column'
		local Wparameter "``column''"
		noi di as text "{ralign `re_ralign':`Wparameter'}"  _col(`re_vline') "{c |}" _col(`re_coef_result') as result %9.0g `table_theta'[`row',1] ///
			_col(`re_se_result') %9.0g `table_theta'[`row',2] ///
			_col(`re_lci_result') %9.0g `table_theta'[`row',3]  _col(`re_uci_result') %9.0g `table_theta'[`row',4]  
	}
	noi di as text "{hline `re_varlength'}{c +}{hline `re_resultslength'}"
	local row =  `numberOfGparas' + `numberOfRparas'
	noi di as text "{ralign `re_ralign':Var(Measure. Err.)}"  _col(`re_vline') "{c |}" _col(`re_coef_result') as result %9.0g `table_theta'[`row',1] ///
		_col(`re_se_result') %9.0g `table_theta'[`row',2] ///
		_col(`re_lci_result') %9.0g `table_theta'[`row',3]  _col(`re_uci_result') %9.0g `table_theta'[`row',4]  
	noi di as text "{hline `re_varlength'}{c BT}{hline `re_resultslength'}"
	
	if `errorCode' == 3360 {
		di as text "Warning: Convergence not achieved within the maximum number of iterations"	
	}
	
	if `errorCode' == 3353 {
		di as text "Warning: Unable to compute standard errors because the Hessian matrix is not positive definite"	
	}
end
