*! version 2.4 07Jul2019
/*	
Notes
SI: Fixed error calling stpm2cr_rml_pred.ado
SI: Including cause-specific hazards FPMs
SI: Added weights to initial values to help convergence
SI: noorthog option and rmatrix() for del_entry added
*/ 


program stpm2cr, eclass byable(onecall)

version 14.1
	if _by() {
		local by "by `_byvars'`_byrc0':"
	}
	
	if replay() {
		syntax  [, DF(string) *]
		if "`df'`knots_c`n''" != "" {
			`by' Estimate `0'
			ereturn local cmdline `"stpm2cr `0'"'
		}
		else {
			if "`e(cmd)'" != "stpm2cr" {
				error 301
			}
			if _by() {
				error 190
			}
			Replay `0' 
		}	
		exit
	}

	/* Set up estimation for all equations */
	`by' Estimate `0'
	
	ereturn local cmdline `"stpm2cr `0'"'
	
end



program Estimate, eclass byable(recall)
	syntax [anything] [if] [in], 												///
		Events(varname)															///
		[																		///
		MODel(string)															///
		CENSvalue(numlist integer)												///
		Cause(numlist integer)													///
		LININIT																	///
		EFORM																	///		
		OLDest																	///
		ALLEQ																	///
		MLMethod(string)														///
		noORTHog																///
		initweight(int 0)														///
		usercommand(string)														///
		Level(cilevel) 															/// -Replay- option
		*																		///
		noLOg																	///
		]
	
	di "new version 1" 
	st_is 2 analysis															// Check if data is stset

	_get_diopts diopts options, `options'   
	mlopts mlopts, `options'
	local extra_constraints `s(constraints)'
	
	qui capture drop _status
	
	qui gen _status = cond(_d==0,0,`events')
	local events _status
	if `initweight' == 0 {
		local cmdline `"stpm2cr `0'"'
	}
	if `initweight' > 0 & "`usercommand'" != "" {
		local cmdline `usercommand'
	}
	
	if "`censvalue'" == "" {													// Default censoring value = 0
		local censvalue 0
	}
	
	if "`model'" == "" {
		local model "cif"
	}

	/* Check rcsgen is installed */
	capture which rcsgen
	if _rc >0 {
		display in yellow "You need to install the command rcsgen. This can be installed using,"
		display in yellow ". {stata ssc install rcsgen}"
		exit  198
	}
	/* Check stpm2 is installed */
	capture which stpm2
	if _rc >0 {
		display in yellow "You need to install the command stpm2. This can be installed using,"
		display in yellow ". {stata ssc install stpm2}"
		exit  198
	}
	/* Check stcompet is installed */
	capture which stpm2
	if _rc >0 {
		display in yellow "You need to install the command stcompet. This can be installed using,"
		display in yellow ". {stata ssc install stcompet}"
		exit  198
	}
	
	/* Use old estimation commands if Stata version <14.1 */
    if `c(stata_version)' < 14.1 {
		local oldest oldest
    }

	/* Mark the estimation sample */	
	marksample touse
	qui replace `touse' = 0  if _st==0 | `touse' == .
	
	qui count if `touse' != 0
	local nobs=r(N)
	if `r(N)' == 0 {
		display in red "No observations"
		exit 2000
	}
	
	qui count if `touse' & _d
	if `r(N)' == 0 {
		display in red "No failures"
		exit 198
	}
	
	/* Check time origin for delayed entry models */
	local del_entry = 0
	qui summ _t0 if `touse' , meanonly
	if r(max)>0 {
		display in green  "Note: delayed entry models are being fitted"
		local del_entry = 1
	}	
	
	/* Check that the events match with _d */	
	qui count if _d == 0 & `events' != `censvalue' & `touse'						// Change for more than one censoring value
	if `r(N)' > 0 {
		display as error "Events (`events') and event indicator (_d) do not match"
		exit 198
	}
	qui count if _d == 0 & `touse'
	if `r(N)'==	0 {
		di as error "No individuals are observed to be censored"
		exit 198
	}
	tempvar touse_obs
	gen `touse_obs' = `touse'
	
	/* Orthogonal retricted cubic splines */
		if "`orthog'"=="noorthog" {
			local orthog
		}
		else {
			local orthog orthog
		}
	
	/* Find number of causes */
	if "`cause'" == "" {
		qui tab `events'
		local nCauses  = `r(r)' - 1													// Number of causes (minus 1 for the censored/alive)
		qui levelsof `events', local(causelist)
		
		local causelist: subinstr local causelist "`censvalue'" "c", word			// Number list of the labelled causes 
		gettoken list causelist : causelist, parse("c ")
		local causelist: subinstr local causelist " " ""
	}
	else {
		local nCauses : word count `cause'
		local causelist "`cause'"
	}
	
	quietly {																	// create event indicator for each cause _d1, _d2, ...
		/* Drop previous model created variables */
		capture drop _rcs* 
		capture drop _d_rcs*    
		capture drop s0_rcs*
		
		foreach i in `causelist' {
			tempvar _d`i'
			gen `_d`i'' = 1 if `events' == `i'
			replace `_d`i'' = 0 if `events' != `i'
		}
	}
	
	local neq `nCauses'
	
	/* Extract causes, equations and options from command line description */
	local open: subinstr local anything "[" "[", all count(local nClose)
	local close: subinstr local anything "]" "]", all count(local nOpen)
	mata: st_local("anyind", substr("`anything'",1,1))
	
	if "`anyind'" != "[" {
		di as error "At least one equation must be specified: possible missing parenthesis ["
		exit 198
	}
	if "`nOpen'" > "`nCauses'" & "`nClose'" > "`nCauses'" {
		di as error "Number of equations do not match up with number of causes: Can only specify up to `nCauses' equation(s)"
		exit 198
	}
	
	gettoken check_p check_lhs : anything, parse("[")
	
	foreach i in `causelist' {
		gettoken cause_`i' check_lhs : check_lhs, parse(":")
		
		local nWord : word count `cause_`i''
		//di "Number of words: `nWord'"
		if `nWord' != 1 {
			di as error "Error in '`anything'': Possible missing ':'."
			exit 198
		}
		
		gettoken check_p check_lhs : check_lhs, parse(":")
		gettoken syntax_c`i' check_lhs : check_lhs, parse("]")
		gettoken check_p check_lhs : check_lhs, parse("[")
		gettoken check_p check_lhs : check_lhs, parse("[")
		
		local causewordlist `causewordlist' `cause_`i''
		local causecode `causecode' `cause_`i'' = `i'
		
	}
	
	
	/****************** CSH FPM *************************/
	if "`model'" == "csh" {
		display in yellow "Fitting FPMs on cause-specific hazards scale..."
		di in red "Note that post-estimation for these models are still in beta"
		foreach n in `causelist' {	
			qui stset `_dta[st_bt]', failure(`_dta[st_bd]' == `n') scale(`_dta[st_bs]') id(`_dta[st_id]') `_dta[st_show]' exit(`_dta[st_exit]') time0(`_dta[st_bt0]') enter(`_dta[st_enter]') origin(`_dta[st_orig]')  
			qui stpm2_prefix `syntax_c`n'' rcsprefix(_`cause_`n'')
			estimates store `cause_`n''
		}
		estimates replay `causewordlist', `eform'
		qui stset `_dta[st_bt]', failure(`_dta[st_bd]' == `cause') scale(`_dta[st_bs]') id(`_dta[st_id]') `_dta[st_show]' exit(`_dta[st_exit]') time0(`_dta[st_bt0]') enter(`_dta[st_enter]') origin(`_dta[st_orig]')  
		
		//csh model ereturns
		ereturn local modelType `model'
		ereturn local causeNames `causewordlist'
		ereturn local predict stpm2cr_pred_csh
		ereturn local causeList `causelist'		
	}
	if "`model'" == "cif" {
		/****************** CIF FPM *************************/
		/*** START LOOP OVER EACH EQUATION ***/
		display in yellow "Fitting FPMs on cumulative incidence scale..."
		
		foreach n in `causelist' {
		
			local 0 `syntax_c`n''
			syntax [varlist(default=empty)], [df(int 0) scale(string) tvc(varlist fv) dftvc(string) BKnots(numlist ascending min=2 max=2) KNOTS(numlist ascending) BKNOTSTVC(string) KNOTSTVC(string) rcsbaseoff noCONStant CURE REVerse ]
			local varlist_c`n' `varlist'
			local scale_c`n' `scale'
			local df_c`n' `df'
			local dftvc_c`n' `dftvc'
			local tvc_c`n' `tvc'
			local cure_c`n' `cure'
			local rcsbaseoff_c`n' `rcsbaseoff'
			local bknots_c`n' `bknots'
			local bknotstvc_c`n' `bknotstvc'
			local knots_c`n' `knots'
			local knotstvc_c`n' `knotstvc'
			
			tempvar missobs_c`n'
			qui egen `missobs_c`n'' = rowmiss(`varlist_c`n'')
			qui replace `touse_obs' = 0 if `missobs_c`n'' != 0  
			qui count if `touse_obs' != 0
			local nobs=r(N)
			
			/* Create temporary variables */
			tempvar Z xb lnt lnt0 coxindex S Sadj cons touse2 touse_t0 cons
			tempname R_bh_c`n' Rinv_bh_c`n'
			
			/* use of all option to calculate spline variables out of sample */
			if "`all'" != "" {
				gen `touse2' = 1
			}
			else {
				gen `touse2' = `touse'
			}
			
			
			/* Generate log time */
			qui gen `lnt' = ln(_t) if `touse2'
			
			/* knots given on which scale */
			if "`knscale_c`n''" == "" {
					local knscale_c`n' time
			}
			
			/* rcsbaseoff option */
			if "`rcsbaseoff_c`n''" != "" & "`tvc'" == "" {
				display as error "You must specify the tvc() option if you use the rcsbaseoff option"
				exit 198
			}
			
			/* Ignore options associated with time-dependent effects if specified without the tvc option */
			if "`tvc_c`n''" == "" {
				local opt dftvc
				if "``opt''" != "" {
					display as txt _n "[`opt'() used without specifying tvc(), option ignored]"
					local `opt'
				}
			}
			
			/* set up spline variables */
			tokenize `knots_c`n''
			local nbhknots : word count `knots_c`n''

			/* Only one of df and knots can be specified */
			if "`df'" != "0" & `nbhknots'>0 {
				display as error "Only one of DF OR KNOTS can be specified"
				exit
			}
		
			/* df must be specified */
			if (`nbhknots' == 0 & "`df'" == "0") & "`rcsbaseoff_c`n''" == "" {
				display as error "Use of either the df or knots option is compulsory"
				exit 198
			}
			
			
			/* df for time-dependent variables */
			if "`tvc_c`n''" != "" {
				if "`dftvc_c`n''" == "" & "`knotstvc_c`n''" == "" {
					display as error "The dftvc option or the knotstvc option must be specified if you use the tvc option in equation `n'"
					exit 198
				}
				
				if "`knotstvc_c`n''" == "" {
					local ntvcdf: word count `dftvc_c`n''
					local lasttvcdf : word `ntvcdf' of `dftvc_c`n''
					capture confirm number `lasttvcdf'
					if `ntvcdf' == 1 | _rc == 0 {										// if there is one word in dftvc or if the last word is a number
						foreach tvcvar in  `tvc_c`n'' {											
							if _rc==0 {													// if the last word is a number
								local tmptvc = subinstr("`1'",".","_",1)				// store 
								//di "tmptvc = `tmptvc'"
								//di "1 = `1'"
								local tvc_`tvcvar'_df_c`n' `lasttvcdf'						// store the df for tvcvar
							}
						}
					}
					if `ntvcdf' > 1 | _rc > 1 {											// if there is more than one word and the last 
						tokenize "`dftvc_c`n''"
						forvalues i = 1/`ntvcdf' {
							local tvcdflist`i' ``i''
						}
						forvalues i = 1/`ntvcdf' {
							capture confirm number `tvcdflist`i''
							if _rc > 0 {
								tokenize "`tvcdflist`i''", parse(":")
								confirm var `1'
								if `"`: list posof `"`1'"' in tvc'"' == "0" {				
									display as error "`1' is not listed in the tvc option"
									exit 198
								}
								local tmptvc `1'
								local tvc_`tmptvc'_df_c`n' 1
							}
							local `1'_df_c`n' `3'	
						}
					}
				}
					
					/* Check all time-dependent effects have been specified */
				if "`knotstvc_c`n''" == "" {	
					foreach tvcvar in `tvc' {
						if "`tvc_`tvcvar'_df_c`n''" == "" {
							display as error "df for time-dependent effect of `tvcvar' are not specified"
							exit 198
						}
					}
					forvalues i = 1/`ntvcdf' {
						tokenize "`tvcdflist`i''", parse(":")
						local tvc_`1'_df `3'
					}
				}
			}
			/* knotstvc option */
			if "`knotstvc_c`n''" != "" {
				if "`dftvc_c`n''" != "" {
					display as error "You can not specify the dftvc and knotstvc options"
					exit 198
				}
				tokenize `knotstvc_c`n''
				cap confirm var `1'
				if _rc >0 {
					display as error "Specify the tvc variable(s) when using the knotstvc() option"
					exit 198
				}
				while "`2'"!="" {
					cap confirm var `1'
					if _rc == 0 {
						if `"`: list posof `"`1'"' in tvc'"' == "0" {				
							display as error "`1' is not listed in the tvc option"
							exit 198
						}
						local tmptvc `1'
						local tvc_`tmptvc'_df_c`n' 1
					}

					cap confirm num `2'
					if _rc == 0 {
						local tvcknots_`tmptvc'_user_c`n' `tvcknots_`tmptvc'_user_c`n'' `2' 
						local tvc_`tmptvc'_df_c`n' = `tvc_`tmptvc'_df_c`n'' + 1
					}
					else {
						cap confirm var `2'
						if _rc {
							display as error "`2' is not a variable"
							exit 198
						}
					}
					macro shift 1
				}
			}
			
			/* Boundary Knots */
			if "`bknots_c`n''" == "" {
					summ `lnt' if `touse' & `_d`n'' == 1, meanonly
					local lowerknot_c`n' `r(min)'
					local upperknot_c`n' `r(max)'
			}
			else {
				local lowerknot_c`n' = ln(real(word("`bknots_c`n''",1)))
				local upperknot_c`n' = ln(real(word("`bknots_c`n''",2)))
			}
			local exp_lowerknot_c`n' = exp(`lowerknot_c`n'')
			local exp_upperknot_c`n'= exp(`upperknot_c`n'')
			
			if "`bknotstvc_c`n''" != "" {
					tokenize `bknotstvc_c`n''
							while "`1'"!="" {
							cap confirm var `1'
							if _rc == 0 {
									if `"`: list posof `"`1'"' in tvc'"' == "0" {                           
											display as error "`1' is not listed in the tvc option"
											exit 198
									}
									local tmptvc_c`n' `1'
							}
							cap confirm num `2'
							if _rc == 0 {
									if substr("`knscale_c`n''",1,1) == "t" {
											local lowerknot_`tmptvc_c`n''_c`n' = ln(`2') 
									}
									else if substr("`knscale_c`n''",1,1) == "l" {
											local lowerknot_`tmptvc_c`n''_c`n' `2' 
									}
									else if substr("`knscale_c`n''",1,1) == "c" {
											qui centile `lnt' if `touse' & `_d`n''==1, centile(`2') 
											local lowerknot_`tmptvc_c`n''_c`n' `r(c_1)'
									}
							}
							cap confirm num `3'
							if _rc == 0 {
									if substr("`knscale_c`n''",1,1) == "t" {
											local upperknot_`tmptvc_c`n''_c`n' = ln(`3') 
									}
									else if substr("`knscale_c`n''",1,1) == "l" {
											local upperknot_`tmptvc_c`n''_c`n' `3' 
									}
									else if substr("`knscale_c`n''",1,1) == "c" {
											qui centile `lnt' if `touse' & `_d`n''==1, centile(`3') 
											local upperknot_`tmptvc_c`n''_c`n' `r(c_1)'
									}
							}
							else {
									cap confirm var `3'
									if _rc {
											display as error "bknotstvc option incorrectly specified"
											exit 198
									}
							}
							macro shift 3
					}
			}
			foreach tvcvar in `tvc_c`n'' {       
					if "`lowerknot_`tvcvar'_c`n''" == "" {
							local lowerknot_`tvcvar'_c`n' = `lowerknot_c`n''
							local upperknot_`tvcvar'_c`n' = `upperknot_c`n''
					}
					local exp_lowerknot_`tvcvar'_c`n' = exp(`lowerknot_`tvcvar'_c`n'')
					local exp_upperknot_`tvcvar'_c`n' = exp(`upperknot_`tvcvar'_c`n'')
			}
			
			if `nbhknots'>0 & "`rcsbaseoff'" == "" {
				local bhknots_c`n' `lowerknot_c`n''

				forvalues i=1/`nbhknots' {
					if substr("`knscale_c`n''",1,1) == "t" {
						local addknot = ln(real(word("`knots_c`n''",`i')))
					}

					local bhknots_c`n' `bhknots_c`n'' `addknot'
				}
				local bhknots_c`n' `bhknots_c`n'' `upperknot_c`n''
			}


			
			
			/* Ensure that the hazard scale is specified if using the cure option*/
			if "`cure_c`n''" != "" {
				if "`scale_c`n''" != "hazard" {
					display as err "The cure option should only be used with the scale(hazard) option"
					exit 198	
				}
			}
			/* if the cure option os specified, reverse should always be used for rcsgen*/	
			if "`cure_c`n''" != "" {
				local reverse_c`n' reverse
			}
			
			di as text "Generating Spline Variables for Cause `n'"
			
			/* Generate splines for baseline hazard */
			if `nbhknots' == 0 & "`rcsbaseoff_c`n''" == "" & "`cure_c`n''" == "" { 
				qui rcsgen `lnt' if `touse', df(`df_c`n'') gen(_rcs_c`n'_) dgen(_d_rcs_c`n'_) if2(`_d`n'') bknots(`bknots_c`n'')  `orthog' `reverse_c`n''
				local rknots_c`n' `r(knots)'
			}
			else if `nbhknots' > 0 & "`rcsbaseoff_c`n''" == "" & "`cure_c`n''" == "" {
				qui rcsgen `lnt' if `touse', knots(`bhknots_c`n'') gen(_rcs_c`n'_) dgen(_d_rcs_c`n'_) if2(`_d`n'')  `orthog' `reverse_c`n''
				local rknots_c`n' `r(knots)'
				tokenize `bhknots_c`n''
				local df : word count `bhknots_c`n''
				local df = `df' - 1
				//di `df'
				//local df_c`n' : word count `knots_c`n''
				local df_c`n' = `df'
			}
			/* Default knot placement for baseline hazard, if cure is specified. Add an extra knot at the 95th centile */
			if `nbhknots' == 0 & "`rcsbaseoff_c`n''" == "" & "`cure_c`n''" != "" {
				tempvar rcs_`n'_ d_rcs_`n'_
				local `df_c`n''_temp = `df_c`n'' - 1
				if ``df_c`n''_temp' == 0 {
					display as error "DF must be more than 1"
					exit
				}
				qui rcsgen `lnt' if `touse', df(``df_c`n''_temp') gen(`rcs_`n'_') dgen(`d_rcs_`n'_') if2(`_d`n'') bknots(`bknots_c`n'')  `orthog' `reverse_c`n''
				local rknots `r(knots)'
				
				tokenize `rknots'

				forvalues i = 1/`df_c`n'' {
					if `i' == 1 {
						local first = "``i''"
					}
					if `i' == `df_c`n'' {
						local last = ``i''*1.1 //1.01 works with stage but not 1.001, but then 1.01 doesn't work with tde
					}
					if `i' != 1 {
						if `i' != `df_c`n''  {
							local middle = "`middle'" + " " + "``i''"
						}
					}
				}
				
				qui _pctile `lnt' if `_d`n''==1, p(95)
				local cure_knots = "`first'" + "`middle'" + " " + "`r(r1)'" + " " + "`last'"
				
				qui rcsgen `lnt' if `touse', knots(`cure_knots') gen(_rcs_c`n'_) dgen(_d_rcs_c`n'_) if2(`_d`n'')  `orthog' `reverse_c`n''
				local rknots_c`n' `r(knots)'
			}
			if `nbhknots' > 0 & "`rcsbaseoff_c`n''" == "" & "`cure_c`n''" != "" {
				display as error "Cure option not currently compatible with user-defined knot placements. Use df()."
				exit
			}
			
			
			if "`orthog'" != "" {
				matrix `R_bh_c`n'' = r(R)
				local rmatrix rmatrix(`R_bh_c`n'')
			}
				
			/* Generate splines for time-varying covariates */
						
			if "`tvc'" != "" {
				foreach tvcvar in  `tvc_c`n'' {
					/*if "`tvc_`tvcvar'_df_c`n''" == "" {
						display as error "dftvc(`dftvc') incorrectly specified. For example missing ':' or missing df for a variable in tvc(). Also ensure that there are no spaces before or after the ':' e.g. dftvc(var:3) NOT dftvc(var: 3) "
						exit 198
					}*/
					if "`rcsbaseoff_c`n''" == "" & "`cure_c`n''" == "" {
						if "`tvcknots_`tvcvar'_user'" == "" {
							qui rcsgen `lnt' if `touse', df(`tvc_`tvcvar'_df_c`n'') gen(_rcs_`tvcvar'_c`n'_) dgen(_d_rcs_`tvcvar'_c`n'_) if2(`_d`n'') `orthog' `reverse_c`n''
							local rknotstvc_`tvcvar'_c`n' `r(knots)'
						}
						else if "`tvcknots_`tvcvar'_user'" != "" & `tvc_`tvcvar'_df_c`n'' != 1 {
							local n_`tvcvar': word count `tvcknots_`tvcvar'_user'
							local tvcknots_`tvcvar'_c`n' `lowerknot'
		 
							forvalues i=1/`n_`tvcvar'' {
								if substr("`knscale_c`n''",1,1) == "t" {
									local addknot = ln(real(word("`tvcknots_`tvcvar'_user_c`n''",`i')))
								}
								else if substr("`knscale_c`n''",1,1) == "l" {
									local addknot = word("`tvcknots_`tvcvar'_user_c`n''",`i')
								}
								else if substr("`knscale_c`n''",1,1) == "c" {
									local tmpknot = word("`tvcknots_`tvcvar'_user_c`n''",`i')
									qui centile `lnt' if `touse' & _d==1, centile(`tmpknot') 
									local addknot = `r(c_1)'
								}
								local tvcknots_`tvcvar'_c`n' `tvcknots_`tvcvar'_c`n'' `addknot'
							}
							local tvcknots_`tvcvar'_c`n' `tvcknots_`tvcvar'_c`n'' `upperknot'	
							if  "`:list dups tvcknots_`tvcvar'_c`n''" != "" {
								display as error "You have duplicate knots positions for the time-dependent effect of `tvcvar'"
								exit 198
							}		
							qui rcsgen `lnt' if `touse2', knots(`tvcknots_`tvcvar'_c`n'') gen(_rcs_`tvcvar'_c`n'_) dgen(_d_rcs_`tvcvar'_c`n'_) if2(`_d`n'') `orthog' `reverse_c`n''
							local rknotstvc_`tvcvar'_c`n' `r(knots)'
					}
					else if "`rcsbaseoff_c`n''" == "" & "`cure_c`n''" != "" {
						if "`tvcknots_`tvcvar'_user'" == "" {
							tempvar rcs_`tvcvar'_`n'_ d_rcs_`tvcvar'_`n'_
							local `tvc_`tvcvar'_df_c`n''_temp = `tvc_`tvcvar'_df_c`n'' - 1
							if ``tvc_`tvcvar'_df_c`n''_temp' == 0 {
								display as error "DF must be more than 1"
								exit
							}
							qui rcsgen `lnt' if `touse', df(``tvc_`tvcvar'_df_c`n''_temp') gen(`rcs_`tvcvar'_`n'_') dgen(`d_rcs_`tvcvar'_`n'_') if2(`_d`n'') bknots(`lowerknot_`tvcvar'_c`n'' `upperknot_`tvcvar'_c`n'')  `orthog' `reverse_c`n''
							local rknotstvc_`tvcvar'_c`n' `r(knots)'
							
							tokenize `rknotstvc_`tvcvar'_c`n''

							forvalues i = 1/`tvc_`tvcvar'_df_c`n'' {
								if `i' == 1 {
									local first_`tvcvar' = "``i''"
									//di "first_`tvcvar'= " `first_`tvcvar''
								}
								if `i' == `tvc_`tvcvar'_df_c`n'' {
									local last_`tvcvar' = ``i''*1.01 //1.01 works with stage but not 1.001, but then 1.01 doesn't work with tde
									//di "last_`tvcvar' = "`last_`tvcvar''
								}
								if `i' != 1 {
									if `i' != `tvc_`tvcvar'_df_c`n''  {
										local middle_`tvcvar' = "`middle_`tvcvar''" + " " + "``i''"
										//di "middle_`tvcvar' = " `middle_`tvcvar''
									}
								}
							}
							
							qui _pctile `lnt' if `_d`n''==1, p(95)
							local cure_knots_`tvcvar' = "`first_`tvcvar''" + "`middle_`tvcvar''" + " " + "`r(r1)'" + " " + "`last_`tvcvar''"
							
							qui rcsgen `lnt' if `touse', knots(`cure_knots_`tvcvar'') gen(_rcs_`tvcvar'_c`n'_) dgen(_d_rcs_`tvcvar'_c`n'_) if2(`_d`n'')  `orthog' `reverse_c`n''
							local rknotstvc_`tvcvar'_c`n' `r(knots)'
						}
						if "`tvcknots_`tvcvar'_user'" != "" {
							display as error "Cure option not currently compatible with user-defined tvc knot placements. Use dftvc()."
							exit
						}
					}
					if "`orthog'" != "" {
						tempname R_`tvcvar'_c`n' Rinv_`tvcvar'_c`n'
						matrix `R_`tvcvar'_c`n'' =  r(R)
						local rmatrix_tvc rmatrix(`R_`tvcvar'_c`n'')
					}
				}
			}
			}
			
			/* Generate splines for delayed entry */
			if `del_entry' == 1 {
				qui gen double `lnt0' = ln(_t0) if `touse2' & _t0>0
				if "`df_c`n''" == "1" & "`rcsbaseoff_c`n''" == "" {
					qui rcsgen `lnt0' if `touse2' & _t0>0, gen(s0_rcs_c`n'_) if2(`_d`n'') `reverse' `nosecondder' `nofirstder'
				}
				else {
					qui rcsgen `lnt0' if `touse2' & _t0>0, knots(`rknots_c`n'') gen(s0_rcs_c`n'_) if2(`_d`n'') `reverse' `nosecondder' `nofirstder' `rmatrix'
				}
				foreach tvcvar in  `tvc' {
					if `tvc_`tvcvar'_df_c`n'' == 1 {
						qui rcsgen `lnt0' if `touse2' & _t0>0, gen(s0_rcs_`tvcvar'_c`n'_) if2(`_d`n'') `reverse' `nosecondder' `nofirstder'
					}
					else if `tvc_`tvcvar'_df_c`n'' != 1 {
						qui rcsgen `lnt0' if `touse2' & _t0>0, knots(`rknotstvc_`tvcvar'_c`n'') gen(s0_rcs_`tvcvar'_c`n'_) if2(`_d`n'') `reverse' `nosecondder' `nofirstder' `rmatrix_tvc'
					}
				}		
			}
			
							
			/* multiply time-dependent _rcs and _drcs terms by time-dependent covariates */
			if "`tvc'" != "" {
				foreach tvcvar in `tvc_c`n'' {
					forvalues i = 1/`tvc_`tvcvar'_df_c`n'' {
						qui replace _rcs_`tvcvar'_c`n'_`i' = _rcs_`tvcvar'_c`n'_`i'*`tvcvar' if `touse'
						qui replace _d_rcs_`tvcvar'_c`n'_`i' = _d_rcs_`tvcvar'_c`n'_`i'*`tvcvar' if `touse'
					}
				}
			}
			
			/* Create list of spline terms and their derivatives for use when orthogonalizing and in model equations */
			
			forvalues i = 1/`df_c`n'' {
				local rcsterms_base_c`n' "`rcsterms_base_c`n'' _rcs_c`n'_`i'"
				local drcsterms_base_c`n' "`drcsterms_base_c`n'' _d_rcs_c`n'_`i'"
			}
				
			local rcs_list_c`n' `rcsterms_base_c`n''
			local drcs_list_c`n' `drcsterms_base_c`n''	
			
			local s0_rcs_list_c`n' : subinstr local rcs_list_c`n' "_rcs_c`n'_" "s0_rcs_c`n'_", all 
			local s0_rcs_list_base_c`n' `s0_rcs_list_c`n''
				
			if "`tvc'" != "" {
				foreach tvcvar in  `tvc_c`n'' {
					forvalues i = 1/`tvc_`tvcvar'_df_c`n'' {
						local rcs_list_c`n'_`tvcvar' "`rcs_list_c`n'_`tvcvar'' _rcs_`tvcvar'_c`n'_`i'"
						local drcs_list_c`n'_`tvcvar' "`drcs_list_c`n'_`tvcvar'' _d_rcs_`tvcvar'_c`n'_`i'"
						local rcs_list_c`n' "`rcs_list_c`n'' _rcs_`tvcvar'_c`n'_`i'"
						local drcs_list_c`n' "`drcs_list_c`n'' _d_rcs_`tvcvar'_c`n'_`i'"
					}
				}
			}
			
			
			
			if "`tvc_c`n''" != "" {
				foreach tvcvar in  `tvc_c`n'' {
					forvalues i = 1/`tvc_`tvcvar'_df_c`n'' {
						local s0_rcs_list_`tvcvar'_c`n' `s0_rcs_list_`tvcvar'_c`n'' s0_rcs_`tvcvar'_c`n'_`i'
					}
					local s0_rcs_list_c`n' `s0_rcs_list_c`n'' `s0_rcs_list_`tvcvar'_c`n''
				}
			}
			
			/* replace missing values for delayed entry with -99 as ml will omit these cases. -99 is not included in the likelihood calculation */
			if `del_entry' == 1 {
				forvalues i = 1/`df' {
					qui replace s0_rcs_c`n'_`i' = -99 if `touse2' & _t0 == 0 & "`rcsbaseoff_c`n''" == ""
				}
				foreach tvcvar in `tvc' {
					forvalues i = 1/`tvc_`tvcvar'_df_c`n'' {
					qui replace s0_rcs_`tvcvar'_c`n'_`i' = -99 if `touse2' & _t0 == 0
					}
				}
			}
			
		 
			/* Spline variable labels */
			if "`rcsbaseoff_c`n''" == "" {
				forvalues j = 1/`df_c`n'' {
					label var _rcs_c`n'_`j' "restricted cubic spline `j' for cause `n'"
					label var _d_rcs_c`n'_`j' "derivative of restricted cubic spline `j' for cause `n'"
					if `del_entry' == 1 {
						label var s0_rcs_c`n'_`j' "restricted cubic spline `i' (delayed entry) for cause `n'"
					}
				}
			}
			if "`tvc_c`n''" != "" {
				foreach tvcvar in  `tvc_c`n'' {
					forvalues i = 1/`tvc_`tvcvar'_df_c`n'' {
						label var _rcs_`tvcvar'_c`n'_`i' "restricted cubic spline `i' for tvc `tvcvar'"
						label var _d_rcs_`tvcvar'_c`n'_`i' "derivative of restricted cubic spline `i' for tvc `tvcvar'"
						if `del_entry' == 1 {
							label var s0_rcs_`tvcvar'_c`n'_`i' "restricted cubic spline `i' for tvc `tvcvar' (delayed entry) for cause `n'"
						}
					}
				}
			}


			/* Fit linear term to log(time) for initial values. LININIT */
			if "`lininit'" != "" {
				if inlist("`scale'","hazard","odds") {
					if "`rcsbaseoff_c`n''" == "" { 
						local initrcslist_c`n' _rcs_c`n'_1
						local initdrcslist_c`n' _d_rcs_c`n'_1
						constraint free
						constraint `r(free)' [`cause_`n''][_rcs_c`n'_1] = [`cause_`n''_dxb][_d_rcs_c`n'_1]
					}
					local initconslist_c`n' `r(free)'
					if "`tvc'" != "" {
						foreach tvcvar in `tvc' {
							local initrcslist_c`n' `initrcslist_c`n'' _rcs_`tvcvar'_c`n'_1
							local initdrcslist_c`n' `initdrcslist_c`n'' _d_rcs_`tvcvar'_c`n'_1
							constraint free
							constraint `r(free)' [`cause_`n''][_rcs_`tvcvar'_c`n'_1] = [`cause_`n''_dxb][_d_rcs_`tvcvar'_c`n'_1]
							local initconslist_c`n' `initconslist_c`n'' `r(free)'
						}
					}
					if `del_entry' == 1 {
						local `cause_`n''_xb0 `"(`cause_`n''_xb0: `varlist_c`n''"' 
						if "`rcsbaseoff_c`n''" == "" {
							local `cause_`n''_xb0 ``cause_`n''_xb0' s0_rcs_c`n'_1 
						}
						if "`tvc'" != "" {
							foreach tvcvar in `tvc' {
								local `cause_`n''_xb0 ``cause_`n''_xb0' s0_rcs_`tvcvar'_c`n'_1
							}
						}
						local `cause_`n''_xb0 ``cause_`n''_xb0', `constant' `offopt')

						if "`constant'" == "" {
							local addconstant _cons
						}
						foreach var in `initrcslist_c`n'' `varlist_c`n'' `addconstant' {
							constraint free
							if substr("`var'",1,8) == "_rcs_c`n'_" {
								constraint `r(free)' [`cause_`n''][`var'] = [`cause_`n''_xb0][s0`var']
							}
							else {
								constraint `r(free)' [`cause_`n''][`var'] = [`cause_`n''_xb0][`var']
							}
							local initconslist_c`n' `initconslist_c`n'' `r(free)'
						}
					}
					
				}
				
				local mleq_xb `mleq_xb' (`cause_`n'': =  `varlist_c`n'' `initrcslist_c`n'', `constant' `offopt')
				
				local mleq_dxb `mleq_dxb' (`cause_`n''_dxb: `initdrcslist_c`n'', nocons)
				
				local mleq_xb0 `mleq_xb0' ``cause_`n''_xb0'
			}
			
			local initconslist `initconslist' `initconslist_c`n''
				
		}
		/*** END LOOP FOR EQUATIONS ***/
		
		local mleq `mleq_xb' `mleq_dxb' `mleq_xb0'
		
		di in green "Note: Causes have been coded as '`causecode''. If incorrect, please ensure"
		di in green "equations are specified in the same order as the indicator(s) in events()."
		
		if `del_entry' == 1 & "`scale'" == "odds" {
			local oldest oldest 
			display as txt "Delayed entry models are being fitted using oldest"
		}
		
		//global causelist `causelist'
		//global nCauses `nCauses'
		mata: causelist = st_local("causelist")
		mata: nCauses = st_local("nCauses")
		mata: events = st_local("events")
		
		foreach n in `causelist' {
			mata: cause_`n' = st_local("cause_`n'")
			mata: scale_c`n' = st_local("scale_c`n'")
		}
		
		
		/* initial values use stcompet to estimate CIF with no-covarites */
		if inlist("`scale'","hazard","odds") {
			display as txt "Obtaining Initial Values"
			quietly {
				if "`lininit'" == "" {
					//local main_cause = substr("`causelist'",1,1)
					//local causelist_o: subinstr local causelist "`main_cause' " "" 
					
					//sts gen skm = s 
					
					tokenize "`causelist'"
					local main_cause = `1'
					macro shift
					local causelist_o `*'
					
					preserve
					
					stset `_dta[st_bt]', failure(`_dta[st_bd]' == `main_cause') scale(`_dta[st_bs]') id(`_dta[st_id]') `_dta[st_show]' exit(`_dta[st_exit]') time0(`_dta[st_bt0]') enter(`_dta[st_enter]') origin(`_dta[st_orig]')  
					
					foreach m in `causelist_o' {											// m = n - 1 causes
						local i = `i' + 1
						local compet `compet' compet`i'(`m')
					}
					
					stcompet CIF=ci, `compet'
					
					foreach n in `causelist' {
						qui gen CIF`n' = CIF if `_d`n'' == 1
					}
					gen totcif = 0
					
					foreach n in `causelist' {

						tempname initmat_`n' initmat initmatend_`n'
										
						if "`scale'" == "hazard" {
							qui gen Z`n' = log(-log(1 - CIF`n'))										// transform
							if "`cure_c`n''" != "" {
								if "`rcsbaseoff_c`n''" == "" {
								constraint free
								constraint `r(free)' _rcs_c`n'_`df_c`n'' = 0
								local cns_c`n' `cns_c`n'' `r(free)'
								}
							}
							
							if "`cure_c`n''" != "" {
								cnsreg Z`n' `varlist_c`n'' `rcs_list_c`n'' if `_d`n'' == 1, `constant' constraints(`cns_c`n'')
							}
							else {
								if `initweight' != 0 {
								
									gen double weight = 1
									noi sum Z`n' if `_d`n'' == 1
									replace weight = `initweight' if Z`n' > (`r(max)' - 0.000001)
									noisily sum weight
									regress Z`n' `varlist_c`n'' `rcs_list_c`n'' if `_d`n'' == 1 [iw=weight], `constant'
									capture drop weight
								}
								else {
									regress Z`n' `varlist_c`n'' `rcs_list_c`n'' if `_d`n'' == 1, `constant'
								}
								
								//predict xb`n' if `_d`n'' == 1, xb
								//gen CIFinit`n' = 1 - exp(-exp(xb`n'))
								//twoway (line xb`n' `lnt' if cov == 0 & `lnt' > 0.5, sort) (scatter Z`n' `lnt' if cov == 0 & `lnt' > 0.5, sort), name(g1`n', replace)
								//twoway (line xb`n' `lnt', sort) (scatter Z`n' `lnt', sort), name(g2`n', replace) xline(`rknots_c`n'') 
								//twoway (line CIFinit`n' _t if cov == 0, sort) (line CIFinit`n' _t if cov == 1, sort), name(cif`n', replace)
							}
							
							matrix `initmat_`n'' = e(b)
						}
						if "`scale'" == "odds" {
							qui gen Z`n' = log(CIF`n'/(1 - CIF`n'))										// transform
							qui regress Z`n' `varlist_c`n'' `rcs_list_c`n'' if `_d`n'' == 1, `constant'
							matrix `initmat_`n'' = e(b)
						}
						
						if inlist("`scale'","hazard","odds") {
			
							local ncopy_`n' : word count `rcs_list_c`n''
							local nstart_`n' : word count `varlist_c`n''
							local nstart_`n' = `nstart_`n'' + 1
							local ncopy_`n' = `nstart_`n'' + `ncopy_`n'' -1
							
							matrix `initmatend_`n'' = `initmat_`n''[1, `nstart_`n'' ..`ncopy_`n'']

							//mat list `initmatend_`n''
							//mat list `initmat_`n''
							
							mat coln `initmat_`n'' = `cause_`n'':
							local initmat_setup `initmat_setup' `initmat_`n'',
							//local initmat_set = substr("`initmat_setup'",1,length("`initmat_setup'") - 1)
							
							mat coln `initmatend_`n'' = `cause_`n''_dxb:
							local initmatend_setup `initmatend_setup' `initmatend_`n'',
							local initmatend_set = substr("`initmatend_setup'",1,length("`initmatend_setup'") - 1)
						}
					}	
					
					if inlist("`scale'","hazard","odds") {
						mat `initmat' = (`initmat_setup' `initmatend_set')
						mat list `initmat'
						restore
					}				
				}
			}
			
				if "`lininit'" != "" {
					if "`oldest'" == "" {
						if "`mlmethod'" == "" {
							if inlist("`scale'","hazard","odds") {
								local mlmethod lf2
							
							}
							else {
								local mlmethod lf
							}
						}
					
						tempname stpm2cr_struct
						local userinfo userinfo(`stpm2cr_struct')
					
						mata stpm2cr_setup("`stpm2cr_struct'")		
						qui ml model `iml' stpm2cr_ml`addlf'_`scale'() /// 
							`mleq' ///
							if `touse' ///
							`wt', ///
							`mlopts' ///
							`userinfo' ///
							collinear ///
							constraints(`initconslist') ///
							diff search(norescale) ///
							maximize

							display in green "Initial Values Obtained"
							matrix `initmat' = e(b)
							constraint drop `initconslist'
						}
					else {
						if "`mlmethod'" == "" {
							if inlist("`scale'","hazard"/*,"odds"*/) {
								local mlmethod lf2
							}
						}	
						if inlist("`mlmethod'","lf0","lf1","lf1debug","lf2","lf2debug") {
							local addlf _lf
						}
						
						foreach n in `causelist' {
							local mult `mult' `scale_c`n''
						}
						
						tokenize `mult'
						
						forvalues i = 1/`nCauses' {
							forvalues j = 1/`nCauses' {
								if `i' != `j' & "``i''" != "``j''" {
									local scale multi
								}
							}
						}
						
						//di "`mleq'"
						
						if inlist("`scale'","multi") {
							if "`mlmethod'" == "lf2" {
								display as txt "mlmethod(lf2) not available when using different scales for each equation - Now using mlmethod(lf1)"
								local mlmethod lf1
							}
						}
						if inlist("`scale'","hazard","odds","multi") {
	
							ml model `mlmethod' stpm2cr_ml`addlf'_`scale' /// 			
								`mleq'  ///
								if `touse' ///
								`wt', ///
								`mlopts' ///
								collinear ///
								constraints(`initconslist') ///
								search(norescale) ///
								maximize
	
								
						}
						display in green "Initial Values Obtained"
						tempname initmat
						matrix `initmat' = e(b)
						//mat list `initmat'
						constraint drop `initconslist'	
					}
				}

			/* The bit after getting initial values */
			foreach n in `causelist' {													/*** START LOOP OVER ALL THE CAUSES ***/
			
				/* Define constraints */					
				local conslist_c`n'
				local fplist_c`n'
				local dfplist_c`n'

				/* constraints for baseline */
				forvalues k = 1/`df_c`n'' {
					constraint free
					constraint `r(free)' [`cause_`n''][_rcs_c`n'_`k'] = [`cause_`n''_dxb][_d_rcs_c`n'_`k']
					local conslist_c`n' `conslist_c`n'' `r(free)'
				}
	//di "baseline: `conslist_c`n''"
				/* add constraint for baseline if cure option is specified*/
				if "`cure_c`n''" != "" {
					if "`rcsbaseoff_c`n''" == "" {
						constraint free
						constraint `r(free)' [`cause_`n''][_rcs_c`n'_`df_c`n''] = 0
						local conslist_c`n' `conslist_c`n'' `r(free)'
					}
				}
				
				/* constraints for time-dependent effects */
				if "`tvc_c`n''" != "" {
					foreach tvcvar in `tvc_c`n'' {
						forvalues k = 1/`tvc_`tvcvar'_df_c`n'' {
							constraint free
							constraint `r(free)' [`cause_`n''][_rcs_`tvcvar'_c`n'_`k'] = [`cause_`n''_dxb][_d_rcs_`tvcvar'_c`n'_`k']
							local conslist_c`n' `conslist_c`n'' `r(free)'
						}
					}
				}
				
				/* add constraints for time-dependent effects if cure option is specified*/ 
				if "`tvc'" != "" & "`cure_c`n''" != ""{
					foreach tvcvar in  `tvc' {
						constraint free
						constraint `r(free)' [`cause_`n''][_rcs_`tvcvar'_c`n'_`tvc_`tvcvar'_df_c`n''] = 0
						local conslist_c`n' `conslist_c`n'' `r(free)'
					}
				}
				local conslist `conslist' `conslist_c`n''
			}
			
			

			foreach n in `causelist' {
				/* constraints for extra equation if delayed entry models are being fitted */	
				if `del_entry' == 1 {
					
					local `cause_`n''_xb0 (`cause_`n''_xb0: `varlist_c`n'' `s0_rcs_list_c`n'', `constant' `offopt')
					local xbvarlist_c`n' `varlist_c`n'' `rcs_list_c`n'' 
					local xbvarlist_c`n'_omitted `varlist_c`n'_omitted' `rcs_list_c`n'' 
					if "`constant'" == "" {
						local xbvarlist_c`n' `xbvarlist_c`n'' _cons
						local xbvarlist_c`n'_omitted `xbvarlist_c`n'_omitted' _cons
					}
					foreach term in `xbvarlist_c`n'' {
						constraint free
						local termlen = ustrlen("_rcs_") 
						if substr("`term'",1,`termlen') == "_rcs_" {
							local addterm_c`n' = "s0" + "`term'"
						}
						else {
							local addterm_c`n' = "`term'"
						}
	//di "`addterm_c`n''"
						constraint free
						constraint `r(free)' [`cause_`n''][`term'] = [`cause_`n''_xb0][`addterm_c`n'']
						local conslist `conslist' `r(free)'
	//di "delayed entry `n': `conslist'"
					}
					
					if "`lininit'" == "" {
						tempvar dEntry
						local nxbterms_c`n': word count `xbvarlist_c`n''
						matrix `dEntry' = `initmat'[1,1..`nxbterms_c`n'']
						mat coln `dEntry' = `cause_`n''_xb0:
						matrix `initmat' = `initmat', `dEntry'
						//mat list `initmat'
						//mat list `dEntry'
					}
				}
				
				local dropconslist_c`n' `conslist_c`n''
								
				//local conslist `conslist' `conslist_c`n''
				
				local mleqfit_xb `mleqfit_xb' (`cause_`n'': =  `varlist_c`n'' `rcs_list_c`n'', `constant' `offopt')
				local mleqfit_dxb `mleqfit_dxb' (`cause_`n''_dxb: `drcs_list_c`n'', nocons)
				local mleqfit_xb0 `mleqfit_xb0' ``cause_`n''_xb0'
				
			}
			
			local mleqfit `mleqfit_xb' `mleqfit_dxb' `mleqfit_xb0'			
			
		}
		
		/*
		/* If further constraints are listed stpm2 then remove this from mlopts and add to conslist */
		if "`extra_constraints'" != "" {
			local mlopts : subinstr local mlopts "constraints(`extra_constraints')" "",word
			local conslist `conslist' `extra_constraints'
		}
		*/
		
		/* Fit Model */
		/* !! PR addition for initialisation from `from' */
		if "`from'" == "" {
			if "`lininit'" == "" {
				local initopt "init(`initmat',copy)"
			}
			else {
				local initopt "init(`initmat')"
			}
		}
		else local initopt "init(`from')"
		
		//mat list `initmat'

		display as txt "Starting to Fit Model"
		
		foreach n in `causelist' {
			local mult `mult' `scale_c`n''
		}
			
		tokenize `mult'
		
		forvalues i = 1/`nCauses' {
			forvalues j = 1/`nCauses' {
				if `i' != `j' & "``i''" != "``j''" {
					local scale multi
				}
			}
		}
		
		if "`oldest'" == "" & "`scale'" != "multi" {
			
			if "`mlmethod'" == "" {
				if inlist("`scale'","hazard","odds") {
					local mlmethod lf2
				}
			}
			/*if inlist("`scale'","odds") & `del_entry' == 1 {
				display in red "Delayed entry models on odds scale is currently unavailable. Will be available soon."
				exit 198
			}*/

		/*
		/* try lininit if convergence fails */	
			if "`failconvlininit'" != "" {
				local captureml capture
			}
		*/
			
			qui findfile stpm2cr_matacode.mata
			capture do `"`r(fn)'"'

			
			tempname stpm2cr_struct
			mata stpm2cr_setup("`stpm2cr_struct'")
			local userinfo userinfo(`stpm2cr_struct')
		
			noi ml model `mlmethod' stpm2cr_ml_`scale'() /// 
				`mleqfit' ///
				if `touse' ///
				`wt', ///
				`mlopts' ///
				`userinfo' ///
				collinear ///
				constraints(`conslist') ///
				`initopt'  ///	
				search(off) ///
				waldtest(0) ///
				`log' ///
				maximize 
			
			if (c(rc) == 1400) {
			
				if (`initweight' == 0) {
					noi di as txt "[initial values infeasible, retrying with -initweight(10)- option]"
					`cmdline' initweight(10) usercommand("`cmdline'")
					exit
				}
				if (`initweight' > 0) {
					local nextweightN = `initweight' + 10
					noi di as txt "[initial values infeasible, retrying with -initweight(`nextweightN')- option]"
					//di "`cmdline'"
					
					`cmdline' initweight(`nextweightN') usercommand("`cmdline'")
					exit
				}
			}
		}
		
		/* old ML estimation */
		else {
			
			if "`mlmethod'" == "" {
				if inlist("`scale'","hazard","odds") {
					local mlmethod lf2
				}
			}
			
			/*if inlist("`scale'","odds") & `del_entry' == 1 {
				display in red "Delayed entry models on odds scale is currently unavailable. Will be available soon."
				exit 198
			}*/
			
			
			if inlist("`mlmethod'","lf0","lf1","lf1debug","lf2","lf2debug") {
							local addlf _lf
			}
			
			//di "`conslist'"
			
			if inlist("`scale'","multi") {
				if `del_entry' == 1 {
					display in red "Delayed entry models on different scales is currently unavailable. Will be available soon."
					exit 198
				}
				display as txt "Fitting model using different scales for cause-specific equations."
				if "`mlmethod'" == "lf2" {
					display as txt "mlmethod(lf2) not available when using different scales for each equation - Now using mlmethod(lf1)"
					local mlmethod lf1
				}
			}
			

		/*
		/* try lininit if convergence fails */	
			if "`failconvlininit'" != "" {
				local captureml capture
			}
		*/	
		
			capture ml model `mlmethod' stpm2cr_ml`addlf'_`scale' /// 
				`mleqfit'  ///
				if `touse' ///
				`wt', ///
				`mlopts' ///
				collinear ///
				constraints(`conslist') ///
				`initopt'  ///	
				waldtest(0) ///
				`log' /// 
				search(off) maximize
				
				if (c(rc) == 1400) {
				
					if (`initweight' == 0) {
						noi di as txt "[initial values infeasible, retrying with -initweight(10)- option]"
						`cmdline' initweight(10) usercommand("`cmdline'")
						exit
					}
					if (`initweight' > 0) {
						local nextweightN = `initweight' + 10
						noi di as txt "[initial values infeasible, retrying with -initweight(`nextweightN')- option]"
						di "`cmdline'"
						
						`cmdline' initweight(`nextweightN') usercommand("`cmdline'")
						exit
					}
				}
				
			/*
			if (c(rc) == 1400) & "`lininit'" == "" {
				noi di as txt "[initial values infeasible, retrying with -lininit- option]"
				`cmdline' lininit
				exit
			}
			*/
		}
		
		

		
		
		ereturn scalar k_eform = `nCauses'*2
		ereturn scalar n_causes = `nCauses'
		ereturn local cmd stpm2cr 
		if "`model'" != "csh" {
			ereturn local predict stpm2cr_pred
		}
		ereturn local scale `scale'
		ereturn local events `events'
		ereturn local causeList `causelist'
		ereturn scalar AIC = -2*e(ll) + 2 * e(rank) 
		qui count if `touse' == 1 & _d == 1
		ereturn scalar BIC = -2*e(ll) + ln(r(N)) * e(rank)

		
		foreach n in `causelist' {
			ereturn local dfbase_c`n' `df_c`n''
			ereturn local cause_`n' `cause_`n''
			ereturn local varlist_c`n' `varlist_c`n''
			ereturn local ln_bhknots_c`n' `rknots_c`n''
		
			ereturn local cure_c`n' `cure_c`n''
			ereturn local reverse_c`n' `reverse_c`n''
			ereturn local rcsbaseoff_c`n' `rcsbaseoff_c`n''
			ereturn local tvc_c`n' `tvc_c`n''
			if "`orthog'" != "" & "`rcsbaseoff'" == "" {
				ereturn matrix R_bh_c`n' = `R_bh_c`n''
			}
			ereturn local orthog `orthog'
			ereturn local boundary_knots_c`n' "`exp_lowerknot_c`n'' `exp_upperknot_c`n''"
			foreach tvcvar in  `tvc_c`n'' {
					ereturn local boundary_knots_`tvcvar'_c`n' "`exp_lowerknot_`tvcvar'_c`n'' `exp_upperknot_`tvcvar'_c`n''"
			}
			if `df_c`n'' >1 {
					forvalues i = 2/`df_c`n'' {
							local addknot_c`n' = exp(real(word("`rknots_c`n''",`i')))
							local exp_bhknots_c`n' `exp_bhknots_c`n'' `addknot_c`n'' 
					}
					ereturn local bhknots_c`n' `exp_bhknots_c`n''
			}
			
			foreach tvcvar in  `tvc_c`n'' {
				ereturn local ln_tvcknots_`tvcvar'_c`n' `rknotstvc_`tvcvar'_c`n'' 
				ereturn scalar df_`tvcvar'_c`n' = `tvc_`tvcvar'_df_c`n''
				ereturn local rcs_list_`tvcvar'_c`n' `rcs_list_c`n'_`tvcvar''
				ereturn local drcs_list_`tvcvar'_c`n' `drcs_list_c`n'_`tvcvar''
				if "`orthog'" != "" {
					ereturn matrix R_`tvcvar'_c`n' = `R_`tvcvar'_c`n''
				}
				
			}
			
			if `initweight' != 0 {
				foreach n in `causelist' {
					if testing[1,`n'] > 0 {
						 ereturn scalar nonmon_c`n' = 1
					}
					else {
						ereturn scalar nonmon_c`n' = 2
					}
				}
				ereturn scalar weight_initial = `initweight'
			}
			else {
				ereturn scalar weight_initial = 1
				foreach n in `causelist' {
					ereturn scalar nonmon_c`n' = 0
				}
				
			}

			
		}
		ereturn local noconstant `constant'
		
		Replay, level(`level') `alleq' `eform' `showcons' `diopts' 
		
		//tidy up
		cap mata: rmexternal("`stpm2cr_struct'")
		cap mata mata drop stpm2cr_state() stpm2cr_setup() stpm2cr_ml_hazard() stpm2cr_ml_odds()
		capture erase lstpm2cr.mlib
		//macro dir
	}

end







********************************************************************************
	
/* Replay command to review previous estimates by typing stpm2cr only */
program Replay
	syntax [, EFORM ALLEQ SHOWcons Level(int `c(level)') ]
	
	_get_diopts diopts, `options'
	
	if "`alleq'" == "" {
		local neq neq(`e(n_causes)')
	}
	
	/* Don't show constraints unless cnsreport option is used */
	if "`showcons'" == "" {
		local showcons nocnsreport
	}
	else {
		local showcons
	}

	ml display, `eform' `neq' `showcons' level(`level') `diopts'
	
end

********************************************************************************




