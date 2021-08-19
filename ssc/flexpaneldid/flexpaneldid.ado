*! flexpaneldid v1.3.0	2020-12-04

capture program drop flexpaneldid
program flexpaneldid, rclass
	version 13
	syntax varlist(max = 1 numeric), 											///
						id(varname)												///
						treatment(varname numeric) 								///
						time(varname numeric)									///
						[cemmatching(string)]									///
						[statmatching(string)]									///
						[test]													///
						[outcometimerelstart(integer -999999)]					///
						[outcometimerelend(integer -999999)]					///
						[outcomedev(numlist <=0 min=1 max=2 integer ascending)]	///
						[savematches(string)]									///
						[outcomemissing]										///
						[didmodel]												///
						[prepdataset(string)]									///
	
	* check if all needed packages are installed
	foreach package in cem psmatch2 pstest {
		capture which `package'
		if _rc==111 {
		display as error "`package' package needs to be installed"
		exit 198
		}
	}	
	
	* check if only one matching method was chosen
	if ("`cemmatching'" != "") {
		local c = 1
	} 
	else {
		local c = 0
	}

	if ("`statmatching'" != "") {
		local s = 1
	}
	else {
		local s = 0
	}

	if (`c' + `s' != 1) {
				display as error "Please choose either " as result "statmatching()" as error " or " as result "cemmatching()" as error " as matching method."

		exit 198
	}

						
	* options in options as string -> parse_statmatching
	if ("`statmatching'" != "") {
		* add artificial comma to parse string as program options
		local statmatching = ", " + "`statmatching'"
		parse_statmatching `statmatching'
		
		local statmatching_con `s(statmatch_con)'
		local statmatching_cat `s(statmatch_cat)'
		local statmatching_radius `s(statmatch_radius)'
		local statmatching_ties `s(statmatch_ties)'
			
		* check that variables are not defined categorical and continuous at the same time
		foreach v of local statmatching_con {
			if `: list v in statmatching_cat' {
				display as error "The matching variable `v' has to be either a continuous or categorical variable!"
				exit 198
			}
		}

		if ("`statmatching_radius'" != "" & "`statmatching_ties'" != "") {
			display as error "Please choose only one matching estimator (" as result "ties" as error " or " as result "radius()" as error")."
			exit 198
		}
	}
	
	if ("`cemmatching'" != "") {
		
		* check if k2k option is set and remove from the cem command
		if (strpos("`cemmatching'", "k2k") > 0 ) {
			local k2k "k2k"
			local cemmatching = subinstr("`cemmatching'", "k2k", "", 1)
		}
		else {
			local k2k ""
		}

		local cem_input_str = "`cemmatching'"
		
		* Parse
		local more 1
		while `more' > 0 {
			gettoken currvar cem_input_str : cem_input_str, parse("() ") match(paren)
			if "`currvar'" == "" {
				local more 0
			}
			else {
				local cem_varlist `cem_varlist' `currvar'
				* check for parentheses
				local par_check = substr(strltrim("`cem_input_str'"),1,1)
				if "`par_check'" == "(" {
					gettoken currcut cem_input_str : cem_input_str, parse("() ") match(paren)
				}
			}
		}
	
		
	* check if all matching vars for cem are in varlist
	foreach v of local cem_varlist {
				capture confirm variable `v'
                if _rc {
                    display as error "`v' is not a variable in dataset."
					exit 198   
                }
        }

	}
		
	* check if either outcometimerelstart or outcometimerelend is defined
	if `outcometimerelstart' == -999999 & `outcometimerelend' == -999999 {
		di as text ""
		di as error "Please define a relative time option based either on treatment start " as result "outcometimerelstart()" ///
			as error " or treatment end " as result "outcometimerelend()" as error ", when the outcome should be analysed."
		exit 198
	}
	else if `outcometimerelstart' != -999999 & `outcometimerelend' != -999999 {
		di as text
		di as error "Please define only one of the relative time options " as result "outcometimerelstart()" ///
			as error " or " as result "outcometimerelend()" as error ", when the outcome should be analysed."
		exit 198
	}
	
	if `outcometimerelstart' == -999999 {
		local outcometimerelstart_show = .
		local outcometimerelend_show = `outcometimerelend'
	}
	
	if `outcometimerelend' == -999999 {
		local outcometimerelend_show = .
		local outcometimerelstart_show = `outcometimerelstart'
	}
	
	* parse outcomedev 
	if "`outcomedev'" != "" {
		
		local var_outcomedev = "outcome_dev"
		
		local outcomedev_nr : list sizeof local(outcomedev)
				
		if `outcomedev_nr' == 1 {
			local outcomedev_level = `outcomedev'
		}
		else if `outcomedev_nr' == 2 {
			local cod = 0	// counter for outcomediff numlist
			foreach num of numlist `outcomedev' {
				local ++cod
				* since numlist is in ascending order, first element is always start 
				if `cod' == 1 {
					local outcomedev_start = `num'
				}
				else if `cod' == 2 {
					local outcomedev_end = `num'
				} 
			}
		}
	}
	else {
		local outcomedev_nr = 0
		local var_outcomedev = ""
	}
	
	* check if at least one obs. is defined as treatment
	quietly count if `treatment' == 1
	if `r(N)' == 0 {
		di as text
		di as error "There is no treatment information defined in `treatment' variable."
		exit 198
	}
	
	
	di as text ""
	di as text ""
	di as text "{bf:********************************************************************************}"
	di as text "{bf:************************* flexpaneldid *****************************************}"
	di as text "{bf:********************************************************************************}"
	di as text ""
	
	di as text "{hline 80}"
	di as text "outcome:" _col(25) as result "`varlist'"
	di as text "id:" _col(25) as result "`id'"
	di as text "treatment:" _col(25) as result "`treatment'"
	di as text "time:" _col(25) as result "`time'"
	di as text "outcome_time_start:" _col(25) as result "`outcometimerelstart_show'"
	di as text "outcome_time_end:" _col(25) as result "`outcometimerelend_show'"
	di as text "outcome_dev:" _col(25) as result "`outcomedev'"
	di as text "cemmatching:" _col(25) as result "`cemmatching'`k2k'"
	di as text "statmatching:" _col(25) as result substr("`statmatching'", 3, .)
	di as text "test:" _col(25) as result "`test'"
	di as text "outcomemissing:" _col(25) as result "`outcomemissing'"
	di as text "didmodel:" _col(25) as result "`didmodel'"
	di as text "{hline 80}"
	
	local outtimerel = 0
	local group = 0
	local matched_0 = 0
	local matched_1 = 0
	local is_string_id = 0
	tempfile bak
	tempfile preselection		
	tempfile matching_result
	tempfile tmp_matching_partner
	tempfile string_id_merge
	tempfile tmp_matched_sample
	tempfile tmp_panel_matchvars
	tempfile tmp_panel_matchvars_controls
	tempfile tmp_controls_std_dev


	* rename outcome variable to distinguish between outcome and matching var
	rename `varlist' o_`varlist'
	
	* summarise matching method in a more general local
	local matchvars `cem_varlist' `statmatching_con' `statmatching_cat'
		
	quietly keep o_`varlist' `id' `treatment' `time'
	
	quietly save `tmp_panel_matchvars', replace

	
	* gen var for treated
	quietly bysort `id': egen treated = max(`treatment')
	
	* gen stats for matching summary - num of treated and nontreated ids in panel
	quietly egen _all_0 = group(`id') if treated != 1
	quietly egen _all_1 = group(`id') if treated == 1
	quietly sum _all_0
	local all_0 = "`r(max)'"
	quietly sum _all_1
	local all_1 = "`r(max)'"
	
	quietly drop _all_0 _all_1 `treatment' treated
	
	quietly compress
	quietly save `bak'
	
	* `id' and `matchvarsexact' could be strings -> convert to numerical vars
	capture confirm string variable `id'
	if !_rc {
        local is_string_id = 1
		
		rename `id' `id'_tmp
		egen `id' = group(`id'_tmp)
		
		preserve
		keep `id' `id'_tmp
		quietly duplicates drop
	
		quietly save `string_id_merge'
		restore
    }
    
	* drop obs. with missing information
	quietly drop if `id' == .
	quietly drop if `time' == .
	
	* check for duplicates in `id' `time'
	quietly duplicates report `id' `time'
	if r(N) != r(unique_value) {
		di as text
		di as error "There are duplicates in `id' `time''"
		exit 198
	}
	

	* locals with varnames of matching and outcome vars for further processing
	local diff_outcome_vars

	* when id is a string -> merge over string version of variable
	if `is_string_id' == 1 {
		rename `id' `id'_bac
		rename `id'_tmp `id'
	}
	
	joinby `id' using "`prepdataset'", unmatched(both)
	drop _merge
	
	* undo renaming that was used for joinby
	if `is_string_id' == 1 {
		rename `id' `id'_tmp
		rename `id'_bac `id'
	}
	
	* check if all needed variables can be found in the merged dataset
	capture confirm variable selection_group treated first_treatment last_treatment o_`varlist' `id' `time' `matchvars'
	if _rc {
        di as error "Not all variables needed for flexpaneldid are available in the preprocessed dataset."
    }
	
	* create variable for outcomedev
	if `outcomedev_nr' != 0 {
		quietly gen h_treat_time_rel = `time' - first_treatment

		if `outcomedev_nr' == 1 {
			quietly bysort selection_group `id': egen h_o_level = max(o_`varlist') if h_treat_time_rel == `outcomedev_level'
			quietly bysort selection_group `id': egen `var_outcomedev' = max(h_o_level)
			quietly drop h_o_level

		}
		else if `outcomedev_nr' == 2 {
			quietly bysort selection_group `id': egen h_o_dev_start = max(o_`varlist') if h_treat_time_rel == `outcomedev_start'
			quietly bysort selection_group `id': egen outcome_dev_start = max(h_o_dev_start)

			quietly bysort selection_group `id': egen h_o_dev_end = max(o_`varlist') if h_treat_time_rel == `outcomedev_end'
			quietly bysort selection_group `id': egen outcome_dev_end = max(h_o_dev_end)

			quietly gen `var_outcomedev' = outcome_dev_end - outcome_dev_start
			quietly drop h_treat_time_rel h_o_dev_start outcome_dev_start h_o_dev_end outcome_dev_end

		}

		if `outcomedev_nr' == 1 {
			label variable `var_outcomedev' "outcome (at treatment time `outcomedev')"
		}
		else if `outcomedev_nr' == 2 {
			label variable `var_outcomedev' "outcome development (between treatment time `outcomedev')"
		}
	}
	
	
	* create variables for start and end of observed outcome difference within selection group
	* start is always defined as treatment start
	quietly bysort selection_group `id': egen h_o_start = max(o_`varlist') if `time' == first_treatment
	quietly bysort selection_group `id': egen o_`varlist'_start = max(h_o_start)
	
	* end could be referenced to treatment start or treatment end 
	if `outcometimerelstart' != -999999 {
		quietly gen h_out_time_rel = `time' - first_treatment
		local outtimerel = `outcometimerelstart'
	}
	else if `outcometimerelend' != -999999 {
		quietly gen h_out_time_rel = `time' - last_treatment
		local outtimerel = `outcometimerelend'
	}

	quietly bysort selection_group `id': egen h_o_end = max(o_`varlist') if h_out_time_rel == `outtimerel'
	quietly bysort selection_group `id': egen o_`varlist'_end = max(h_o_end)
	quietly drop h_o_start h_out_time_rel h_o_end
	
	local diff_outcome_vars o_`varlist'_start o_`varlist'_end
	
	* shrink the dataset to one obs per `id' and selection group
	quietly bysort selection_group `id': gen h = _n
	quietly keep if h == 1
	quietly drop o_`varlist' `time' h
	

	if ("`outcomemissing'" == "") {
		quietly egen h = rowmiss(`matchvars' `var_outcomedev' `diff_outcome_vars')
	}
	else if ("`outcomemissing'" != "") {
		quietly egen h = rowmiss(`matchvars' `var_outcomedev')
	}
	
	quietly keep if h == 0
	quietly drop h
	
	* check, if still obs. in dataset
	quietly count
	if r(N) == 0 {
		di as text ""
		di as error "There are no groups with observable outcome for treated and non-treatet"
		exit 198
	}
	
	* keep only selection_groups containing one treated
	quietly bysort selection_group: egen h = sum(treated)
	quietly keep if h == 1
	quietly drop h
	
	* check, if still obs. in dataset
	quietly count
	if r(N) == 0 {
		di as text ""
		di as error "There are no groups left containing at least one treated"
		exit 198
	}

	* keep only selection_groups containing at least 2 objects
	quietly bysort selection_group: gen h = _N
	quietly keep if h > 1
	quietly drop h
	
	* check if there are still observations in dataset
	quietly count
	if r(N) == 0 {
		di as text ""
		di as error "No observations remaining for matching"
		exit 198
	}
	else {
		quietly save `preselection'
	}
	
	
	if "`cemmatching'" != "" {
		
		di as text ""
		di as text ""
		di as text "{bf:********************************************************************************}"
		di as text "{bf:************************* Matching: CEM ****************************************}"
		di as text "{bf:********************************************************************************}"
		di as text ""
		
		
		* expand cem command from input by rel. matching time  
		local cem_command = "`cemmatching'" + " " + "`var_outcomedev'"
		
		cem selection_group(#0) `cem_command', treatment(treated) `k2k' showbreaks
		
		* further processing of CEM matching results
		quietly keep if cem_matched == 1
		
		* if there are still observations in dataset -> temporary save as matching results
		quietly count
		if r(N) > 0 {
			quietly save `matching_result'
		}
		else {
			display as error "No matching partners found by CEM"
			exit 198
		}
	}
	
	
	else if "`statmatching'" != "" {
		
		di as text ""
		di as text ""
		di as text "{bf:********************************************************************************}"
		di as text "{bf:************************* Matching: STAT ***************************************}"
		di as text "{bf:********************************************************************************}"
		di as text ""
		
		* define continuous and categorical matching vars
		local matchvars_con `statmatching_con' `var_outcomedev'
		local matchvars_cat `statmatching_cat'
		
		* save all levels of selection groups
		quietly levelsof selection_group, local(lvl_group)
		
		local counter = 0
		
		foreach l of local lvl_group {
			
			quietly use `preselection', clear
			
			quietly keep if selection_group == `l'
			
			* sort order is important when calling _stat_dist
			* -> treated id must be the first obs in selection group
			gsort -treated `id' 
			
			* calculating statistical distance
			quietly gen dist = .
			mata: _stat_dist("`matchvars_con'", "`matchvars_cat'")
			
			* gen artificial outcome to allow missings in outcome variables (is not interpreted)
			gen hh = 1
						
			* command for nearest neighbor
			if ("`statmatching_radius'" == "" & "`statmatching_ties'" == "") {
				quietly psmatch2 treated, outcome(hh) neighbor(1) pscore(dist)
			}

			* command for ties option
			if ("`statmatching_ties'" != "") {
				quietly psmatch2 treated, outcome(hh) neighbor(1) pscore(dist) ties
			}

			* command for radius option
			if ("`statmatching_radius'" != "") {
				quietly psmatch2 treated, outcome(hh) pscore(dist) radius caliper(`statmatching_radius')
			}
			
			drop hh _hh

			local ++counter
			quietly keep if _weight != .
			
			if `counter' == 1 {
				quietly save `matching_result', replace
			}
			else {
				quietly append using `matching_result'
				quietly save `matching_result', replace
			}
			
			gsort selection_group -treated
		}				
	}

	
	* tag non treated ids selected multiple times
	quietly bysort `id': gen h = _N if treated == 0
	quietly gen nt_multi_select = h if treated == 0 & h > 1
	quietly drop h
	

	* display matching summary
	quietly egen _matched_0 = group(`id') if treated != 1
	quietly sum _matched_0
	local matched_0 = "`r(max)'"
	quietly drop _matched_0
	
	quietly egen _matched_1 = group(`id') if treated == 1
	quietly sum _matched_1
	local matched_1 = "`r(max)'"
	quietly drop _matched_1

		
	di as text ""
	di as text ""
	di as text "{bf:********************************************************************************}"
	di as text "{bf:************************* flexpaneldid - Matching Summary **********************}"
	di as text "{bf:********************************************************************************}"
	di as text ""
	di as text _col(16) as text "{c |}" _col(27) as text "NT" _col(40) as text "T"
	di as text "{hline 15}{c +}{hline 30}"
	di as text "All" _col(16) as text "{c |}" _col(21) as result %8.0g `all_0' _col(33) as result %8.0g `all_1'
	di as text "Matched sample" _col(16) as text "{c |}" _col(21) as result %8.0g `matched_0' _col(33) as result %8.0g `matched_1'
	di as text
	
	
	
	if "`test'" == "test" {
				
		di as text ""
		di as text ""
		di as text "{bf:********************************************************************************}"
		di as text "{bf:************************* ps-test **********************************************}"
		di as text "{bf:********************************************************************************}"
		di as text ""
		
		* pstest needs _weight variable generated by psmatch2 -> is 1 for all obs if k2k matching
		capture gen _weight = 1 
		
		capture noisily pstest `matchvars' `var_outcomedev', treated(treated)
		
		
		*** QQ-Plot ***
		foreach y of varlist `matchvars' `var_outcomedev'{
			
			quietly gen h_`y'_0 = `y' if treated == 0
			quietly gen h_`y'_1 = `y' if treated == 1
			
			if "`y'" == "outcome_dev" & `outcomedev_nr' == 2 {
				local y_label = "`y'*"
				local outcome_dev_note = "* Outcome development from `outcomedev_start' to `outcomedev_end' before treatment"
			}
			else if "`y'" == "outcome_dev" & `outcomedev_nr' == 1 {
				local y_label = "outcome_level*"
				local outcome_dev_note = "* Outcome level at `outcomedev_level' before treatment"
			}
			else {
				local y_label = reverse(substr(reverse("`y'"), (strpos(reverse("`y'"), "_")) + 1, .))
			}	
			
			qqplot h_`y'_0 h_`y'_1, xtitle(treated units) ytitle(control units) title("`y_label'") ylabel(, angle(0)) name(`y', replace) nodraw
			local graphnames `graphnames' `y'
		}
		graph combine `graphnames', title("QQ-Plot - matching variables at matching time") note("`outcome_dev_note'", size(tiny))
		
		quietly drop h_*
				
		
		if "`statmatching'" != "" {
		
			local count_con: word count `matchvars_con'
			local count_cat: word count `matchvars_cat'
						
			if `count_con' > 0 {
				
				di as text ""
				di as text ""
				di as text "{bf:********************************************************************************}"
				di as text "{bf:************************* KS-Test **********************************************}"
				di as text "{bf:********************************************************************************}"
				di as text ""
			
				local ks_test_vars `matchvars_con'
				foreach v of local ks_test_vars {
					display "ksmirnov `v' , by(treated)"
					ksmirnov `v' , by(treated)
				}
			}
			
			
			if `count_cat' > 0 {
			
				di as text ""
				di as text ""
				di as text "{bf:********************************************************************************}"
				di as text "{bf:************************* Chi2-Test ********************************************}"
				di as text "{bf:********************************************************************************}"
				di as text ""
			
				foreach x of local matchvars_cat {
					display "tabulate `x' treated, chi2"
					tabulate `x' treated, chi2
				}
			}
						
		}
		
	}
		

	if "`savematches'" != "" {
		quietly save "`savematches'", replace
	}
	
	* temporary save the matching results to recreate panel later 
	quietly save `tmp_matching_partner', replace
	
	
	
	
	*** Diff-in-Diff ***********************************************************
		
	* to calculate conditional diff-in-diff -> no missings in outcome vars allowed
	if "`outcomemissing'" != "" {
		quietly egen h = rowmiss(`diff_outcome_vars')
		
		quietly bysort selection_group: egen h_sel_group = max(h)
		quietly drop if h_sel_group != 0
		quietly drop h h_sel_group
		
	}

	* keep only selection_groups containing at least one treated
	quietly count
	if r(N) == 0 {
		di as text ""
		di as error "After matching, there are no observable outcomes to calculate outcome difference"
		exit 198
	}
	else {
		quietly bysort selection_group: egen h1 = sum(treated)
		quietly keep if h1 > 0
		quietly drop h1
	}

	* keep only selection_groups containing beside treated at least one non treated 
	quietly count
	if r(N) == 0 {
		di as text ""
		di as error "After matching, there are no observable outcomes to calculate outcome difference"
		exit 198
	}
	else {		
		quietly bysort selection_group: egen h2 = min(treated)
		quietly keep if h2 == 0
		quietly drop h2
	}

	* check if there are still observations in dataset
	quietly count
	if r(N) == 0 {
		di as text ""
		di as error "After matching, there are no observable outcomes to calculate outcome difference"
		exit 198
	}
	

	*** bias correction according to Abadie & Imbens (2006, 2011) ***
	quietly reg o_`varlist'_start `matchvars' `var_outcomedev' if treated == 0
	
	mat coeff0_start = get(_b)
	quietly predict y_nontreated0_start if treated == 0
	mat score y_treated0_start = coeff0_start if treated == 1
	
	quietly bysort selection_group: egen h_y_treated0_start = max(y_treated0_start)
	quietly gen o_corr_start = o_`varlist'_start if treated == 1
	quietly replace o_corr_start = o_`varlist'_start + h_y_treated0_start - y_nontreated0_start if treated == 0

	
	quietly reg o_`varlist'_end `matchvars' `var_outcomedev' if treated == 0
	
	mat coeff0_end = get(_b)
	quietly predict y_nontreated0_end if treated == 0
	mat score y_treated0_end = coeff0_end if treated == 1
	
	quietly bysort selection_group: egen h_y_treated0_end = max(y_treated0_end)
	quietly gen o_corr_end = o_`varlist'_end if treated == 1
	quietly replace o_corr_end = o_`varlist'_end + h_y_treated0_end - y_nontreated0_end if treated == 0
	
	* corrected outcome means within selection groups
	quietly bysort selection_group treated: egen o_corr_start_mean = mean(o_corr_start)
	quietly bysort selection_group treated: egen o_corr_end_mean = mean(o_corr_end)
	
	* outcome means within selection group without bias correction
	quietly bysort selection_group treated: egen o_start_mean = mean(o_`varlist'_start)
	quietly bysort selection_group treated: egen o_end_mean = mean(o_`varlist'_end)

	* outcome difference
	* if cem matiching -> no outcome bias correction
	if "`cemmatching'" != "" {
		quietly gen diff_out_to_tt = o_end_mean - o_start_mean		// without bias correction
	}
	else {
		quietly gen diff_out_to_tt = o_corr_end_mean - o_corr_start_mean
	}
		
	* when id is a string use string version of variable
	if `is_string_id' == 1 {
		rename `id' `id'_bac
		rename `id'_tmp `id'
	}
	
	quietly save `tmp_matched_sample', replace
	
	if ("`statmatching'" != "") {

		*** standard errors
		** Var_1
		
		* individual treatment effect
		* treated
		quietly bysort selection_group: egen h_mean_diff_t = max(diff_out_to_tt) if treated == 1
		quietly bysort selection_group: egen mean_diff_t = max(h_mean_diff_t)

		* non treated
		quietly bysort selection_group: egen h_mean_diff_nt = max(diff_out_to_tt) if treated == 0
		quietly bysort selection_group: egen mean_diff_nt = max(h_mean_diff_nt)

		quietly gen indiv_treatment_effect = mean_diff_t - mean_diff_nt
		
		* mean treatment effect
		keep selection_group indiv_treatment_effect
		quietly duplicates drop
		
		quietly egen mean_treatment_effect = mean(indiv_treatment_effect)
		
		local diff = mean_treatment_effect[1]
				
		quietly count
		local n =  `r(N)'

		quietly gen h_var1 = (indiv_treatment_effect - mean_treatment_effect)^2
		quietly egen h_var1_sum = sum(h_var1)
		quietly gen var1 = h_var1_sum / `n'
		local var1 = var1[1]


		* for all controls in matched sample -> matching again
		* -> look for similar control
		* -> calc difference with corrected outcomes
		
		* identify unique controls and reconstruct panel for these ids 
		use `tmp_matched_sample', clear

		quietly keep if treated == 0
		
		quietly sum first_treatment
		local min_t_start = `r(min)'
		local max_t_start = `r(max)'

		* extract matching time from var label
		foreach v of var `matchvars' {
			local match_vars_label : var label `v'
			local match_time_rel = reverse(substr(reverse("`match_vars_label'"), 2, 2))
		}
				
		local min_start = `min_t_start' + `match_time_rel'
		local max_start = `max_t_start' + `match_time_rel'

		if (`min_start' == `max_start') {
			local random_start = `min_start'
		}
		else {
			* draw random time in range (earliest treatment start, latest treatment start)
			* -> matching time for all controls
			* stata13 compatibility
			local random_start = round(`min_start' + (`max_start' - `min_start') * runiform())
			
		}
		
		keep `id' `matchvars'
	
		quietly duplicates drop `id', force
		
		quietly merge 1:n `id' using `tmp_panel_matchvars', keep(1 3)
		quietly drop _merge
		
		quietly keep if `time' == `random_start'

		quietly drop `time' `treatment'

		quietly gen _line = _n
		order _line
		
		quietly sum _line
		local lines = `r(max)'
	
		quietly save `tmp_panel_matchvars_controls', replace
		
		* loop over controls and search for every control the nearest neighbor 
		forvalues i = 1/`lines' {

			use `tmp_panel_matchvars_controls', clear

			* gen pseudo treated to use _stat_dist and psmatch2
			quietly gen treated = 0
			quietly replace treated = 1 if _line == `i'
			gsort -treated
			
			* calculating statistical distance
			quietly gen dist = .
			
			mata: _stat_dist("`statmatching_con'", "`statmatching_cat'")

			quietly psmatch2 treated, outcome(o_`varlist') neighbor(2) pscore(dist)
			
			quietly gen std_dev = (2/3) * (`r(att)')^2
			
			quietly keep if _pdif != .
			keep `id' std_dev
			
			if `i' == 1 {
				quietly save `tmp_controls_std_dev', replace
			}
			else {
				append using `tmp_controls_std_dev'
				quietly save `tmp_controls_std_dev', replace
			}
			
		}
		
		
		** Var_2
		use `tmp_matched_sample', clear

		quietly merge m:1 `id' using `tmp_controls_std_dev', keep(1 3)
		quietly drop _merge
		
		quietly bysort selection_group: egen indiv_std_dev = mean(std_dev)
		
		keep selection_group indiv_std_dev
		quietly duplicates drop
		
		quietly egen mean_std_dev = mean(indiv_std_dev)
		
		local var2 = mean_std_dev[1]

		local variance = `var1' + `var2'
		
		local se = ((`variance')^(1/2) / (`n')^(1/2))
				
		* mean number of matches per treated
		use `tmp_matched_sample', clear

		quietly collapse (count) treated, by(selection_group)
		quietly replace treated = treated - 1
		quietly egen mean_no_of_matches = mean(treated)
		local mean_no_of_matches = mean_no_of_matches[1]
		


		use `tmp_matched_sample', clear

		keep selection_group treated diff_out_to_tt
		quietly duplicates drop
		quietly reshape wide diff_out_to_tt, i(selection_group) j(treated)
		quietly gen diff = diff_out_to_tt1 - diff_out_to_tt0
		quietly egen mean_diff = mean(diff)

		quietly ttest diff_out_to_tt1 == diff_out_to_tt0

		local t = sqrt(`n') * (mean_diff[1] / sqrt(`variance'))
		
		local p = tprob(`n'-1,`t')
	}
	else {
		* if cemmatching no standard errors were calculated

		* number of unique controls
		use `tmp_matched_sample', clear
		keep if treated == 0
		keep `id'
		quietly duplicates drop

		quietly gen _unique_nt = _n
		quietly sum _unique_nt
		local unique_nt = `r(max)'

		* mean number of matches per treated
		use `tmp_matched_sample', clear

		quietly collapse (count) treated, by(selection_group)
		quietly replace treated = treated - 1
		quietly egen mean_no_of_matches = mean(treated)
		local mean_no_of_matches = mean_no_of_matches[1]

	
		* DiD (in case of cem matching)
		use `tmp_matched_sample', clear
		keep selection_group treated diff_out_to_tt
		quietly duplicates drop
		quietly reshape wide diff_out_to_tt, i(selection_group) j(treated)
		quietly gen diff = diff_out_to_tt1 - diff_out_to_tt0
		quietly egen mean_diff = mean(diff)

		quietly ttest diff_out_to_tt1 == diff_out_to_tt0
		
		local diff_tt = `r(mu_1)' - `r(mu_2)'

	}
		
	* create locals for display in table
	local metric = ""
	if ("`statmatching'" != "") {
		local metric = "Statistical DF"
	}
	else if ("`cemmatching'" != "") {
		local metric = "CEM"
	}


	local estimator = ""
	if ("`metric'" == "Statistical DF" & "`statmatching_radius'" != "") {
		local estimator = "Radius"
	}
	else if ("`metric'" == "Statistical DF" & "`statmatching_ties'" != "") {
		local estimator = "Ties"
	}
	else if ("`metric'" == "Statistical DF" & "`statmatching_radius'" == "" & "`statmatching_ties'" == "") {
		local estimator = "Nearest neighbor"
	}
	else if ("`metric'" == "CEM") {
		local estimator = "`k2k'"
	}
	

	di as text ""
	di as text ""
	di as text "{bf:********************************************************************************}"
	di as text "{bf:************************* Conditional Diff-in-Diff *****************************}"
	di as text "{bf:********************************************************************************}"
	di as text ""
	
	if ("`statmatching'" != "") {
		di as text "Average treatment effect for the treated"
		di as text "Estimator" _col(17) ": `estimator'" _col(45) "No. of treated obs" _col(70) "=" _col(75) as result %6.0g `n'
		di as text "Distance metric" _col(17) ": `metric'" _col(45) "No. of unique controls" _col(70) "=" _col(75) as result %6.0g `lines'
		di as text _col(45) "Mean no. of matches" _col(70) "=" _col(75) as result %6.0g `mean_no_of_matches'
		di as text "{hline 12}{c TT}{hline 22}{c TT}{hline 10}{c TT}{hline 10}{c TT}{hline 22}"
		di as text "Outcome" _col(13) "{c |}" _col(21) "mean Diff" _col(36) "{c |}" _col(40) "DiD*" _col(47) "{c |}" /*
			*/ _col(48) "AI robust" _col(58) "{c |}" _col(64) "z" _col(73) "P>|z|"
		di as text _col(13) "{c |}" _col(16) "treated" _col(25) "{c |}" _col(27) "controls" _col(36) "{c |}" _col(47) "{c |}" /*
			*/ _col(51) "S.E." _col(58) "{c |}" _col(69) "{c |}"
		di as text "{hline 12}{c +}{hline 11}{c +}{hline 10}{c +}{hline 10}{c +}{hline 10}{c +}{hline 10}{c +}{hline 11}"
		di as text %-10s abbrev("`varlist'", 10) _col(13) "{c |}" /*
			*/ _col(16) as result %6.4f `r(mu_1)' _col(25) "{c |}" /*
			*/ _col(27) as result %6.4f `r(mu_2)' _col(36) "{c |}" /*
			*/ _col(39) as result %6.4f `diff' _col(47) "{c |}" /*
			*/ _col(50) as result %6.4f `se' _col(58) "{c |}" /*
			*/ _col(61) as result %6.4f `t' _col(69) "{c |}" /*
			*/ _col(72) as result %6.4f `p'
		di as text "{hline 12}{c BT}{hline 11}{c BT}{hline 10}{c BT}{hline 10}{c BT}{hline 10}{c BT}{hline 10}{c BT}{hline 11}"
		di as text "* Consistent bias-corrected estimator as proposed in Abadie & Imbens (2006,2011)."
		
		return scalar num_treated = `n'
		return scalar num_controls = `lines'
		return scalar did = `diff'
		return scalar se = `se'
		return scalar z = `t'
		return scalar p = `p'
	}
	else {
		di as text "Average treatment effect for the treated"
		di as text "Estimator" _col(17) ": `estimator'" _col(45) "No. of treated obs" _col(70) "=" _col(75) as result %6.0g `r(N_2)'
		di as text "Distance metric" _col(17) ": `metric'" _col(45) "No. of unique controls" _col(70) "=" _col(75) as result %6.0g `unique_nt'
		di as text _col(45) "Mean no. of matches" _col(70) "=" _col(75) as result %6.0g `mean_no_of_matches'
		di as text "{hline 12}{c TT}{hline 22}{c TT}{hline 10}{c TT}{hline 10}{c TT}{hline 22}"
		di as text "Outcome" _col(13) "{c |}" _col(21) "mean Diff" _col(36) "{c |}" _col(40) "DiD" _col(47) "{c |}" /*
			*/ _col(51) "S.E" _col(58) "{c |}" _col(64) "z" _col(73) "P>|z|"
		di as text _col(13) "{c |}" _col(16) "treated" _col(25) "{c |}" _col(27) "controls" _col(36) "{c |}" _col(47) "{c |}" /*
			*/ _col(58) "{c |}" _col(69) "{c |}"
		di as text "{hline 12}{c +}{hline 11}{c +}{hline 10}{c +}{hline 10}{c +}{hline 10}{c +}{hline 10}{c +}{hline 11}"
		di as text %-10s abbrev("`varlist'", 10) _col(13) "{c |}" /*
			*/ _col(16) as result %6.4f `r(mu_1)' _col(25) "{c |}" /*
			*/ _col(27) as result %6.4f `r(mu_2)' _col(36) "{c |}" /*
			*/ _col(39) as result %6.4f `diff_tt' _col(47) "{c |}" /*
			*/ _col(50) as result %6.4f `r(se)' _col(58) "{c |}" /*
			*/ _col(61) as result %6.4f `r(t)' _col(69) "{c |}" /*
			*/ _col(72) as result %6.4f `r(p)'
		di as text "{hline 12}{c BT}{hline 11}{c BT}{hline 10}{c BT}{hline 10}{c BT}{hline 10}{c BT}{hline 10}{c BT}{hline 11}"
		
		return scalar num_treated = `r(N_2)'
		return scalar num_controls = `unique_nt'
		return scalar did = `diff_tt'
		return scalar se = `r(se)'
		return scalar z = `r(t)'
		return scalar p = `r(p)'
	}
	
	return local estimator = "`estimator'"
	return local metric = "`metric'"
	return scalar num_mean_matches = `mean_no_of_matches'
	
	return local outcome_var = "`varlist'"
	return scalar mean_dif_treated = `r(mu_1)'
	return scalar mean_dif_controls = `r(mu_2)'
	
	

		
	quietly use `tmp_matching_partner', clear

	*** didmodel ***
	* didmodel the panel structure of matching results has to be restored
	quietly keep `id' treated first_treatment last_treatment nt_multi_select 

	* non treated could be selected more than once in matched sample -> take earliest treatment time
	quietly bysort `id': egen h_min = min(first_treatment)
	quietly keep if first_treatment == h_min
	quietly drop h_*
	quietly duplicates drop `id', force
	
	* remerge, if string ids in original data set
	if `is_string_id' == 1 {
		
	* ids
	quietly merge m:1 `id' using `string_id_merge', keep(3)
	quietly drop `id' _merge
	rename `id'_tmp `id'
	order `id'
	}
	
	quietly merge 1:n `id' using `bak', keep(1 3)
	quietly drop _merge

	quietly bysort `id': egen h_treated = max(treated)
	quietly replace treated = h_treated if treated == .
	
	quietly bysort `id': egen h_first_treatment = max(first_treatment)
	quietly replace first_treatment = h_first_treatment if first_treatment == .
	quietly drop h_*

	quietly egen panel_id = group(`id')
	
	* define and describe panel
	quietly xtset panel_id `time'
	quietly xtdes
	
	* post treatment dummy
	quietly gen post_treat_dummy = 1 if `time' > first_treatment
	quietly recode post_treat_dummy (.=0)
	
	* post treatment dummy rel. time - depends on outcometimerelstart or outcometimerelend
	if `outcometimerelstart' != -999999 {
		local outtimerel = `outcometimerelstart'
		quietly gen post_treat_dummy_rel_time = `time' - first_treatment
		quietly replace post_treat_dummy_rel_time = 0 if post_treat_dummy_rel_time < 0
	}
	else if `outcometimerelend' != -999999 {
		local outtimerel = `outcometimerelend'
		quietly gen post_treat_dummy_rel_time = `time' - last_treatment
		quietly replace post_treat_dummy_rel_time = 0 if post_treat_dummy_rel_time < 0
	}

	* re-rename outcome varlist
	rename o_`varlist' `varlist'

	* label variables
	label variable treated "panel item is treated (=1) or non treated (=0)"
	label variable first_treatment "time of treatment begin"
	label variable last_treatment "time of treatment end"
	label variable nt_multi_select "how often non treated was selected as matching partner"
	label variable panel_id "automatically generated temporary panel id"
	label variable post_treat_dummy "dummy = 1 after treatment start"
	label variable post_treat_dummy_rel_time "dummy with relative difference to treatment start "

	if "`didmodel'" != "" {
		
		di as text ""
		di as text ""
		di as text "{bf:********************************************************************************}"
		di as text "{bf:*** Fixed Effects Diff-in-Diff - robustness check of Conditional Diff-in-Diff **}"
		di as text "{bf:********************************************************************************}"
		di as text ""
		display "xtreg `varlist' i.treated##i.post_treat_dummy_rel_time i.`time' if post_treat_dummy_rel_time == `outtimerel' | first_treatment == `time', fe vce(cluster panel_id)"
		xtreg `varlist' i.treated##i.post_treat_dummy_rel_time i.`time' if post_treat_dummy_rel_time == `outtimerel' | first_treatment == `time', fe vce(cluster panel_id)

		di as text ""
		di as text ""
		di as text "{bf:********************************************************************************}"
		di as text "{bf:*** Fixed Effects Diff-in-Diff - mean treatment effect *************************}"
		di as text "{bf:********************************************************************************}"
		di as text ""
		display "xtreg `varlist' i.treated##i.post_treat_dummy i.`time' if post_treat_dummy_rel_time <= `outtimerel' , fe vce(cluster panel_id)"
		xtreg `varlist' i.treated##i.post_treat_dummy i.`time' if post_treat_dummy_rel_time <= `outtimerel' , fe vce(cluster panel_id)
	}

	
end



* program for parsing continuous / categorical variables and different modes for statmatching
capture program drop parse_statmatching						
program parse_statmatching, sclass
	version 13
	syntax [, 									///
			con(varlist min = 1 numeric)		///
			cat(varlist min = 1 numeric) 		///
			radius(numlist >0 <=1 min=1 max=1)	///
			ties]
	
	sreturn local statmatch_con `con'
	sreturn local statmatch_cat `cat'
	sreturn local statmatch_radius `radius'
	sreturn local statmatch_ties `ties'
end


* mata function for calculating statistical distance between treated and non-treated within selection group 
mata:
mata clear

void function _stat_dist(string scalar X_con, string scalar X_cat) 
{
	st_view(M_con=., ., X_con)
	st_view(M_cat=., ., X_cat)
	st_view(M_a=., ., "treated")
	st_view(distance=., ., "dist")
	
	M = (M_a, M_con, M_cat)
		
	indT = select(M[.,1], M[.,1]:== 1)
	indNT = select(M[.,1], M[.,1]:~= 1)
	
	// number of treated and non-treated
	m = rows(indT)
	n = rows(indNT)
	
	// number of continuous and categorical matching vars
	a = cols(M_con)
	b = cols(M_cat)
	
	// continuous matching vars
	distance_m = J(m+n, m, 0)
		
	// if continous matching vars are defined
	if (a > 0) {
		
		// range between min and max of continuous matching vars
		varmax = colmax(M_con)
		varmin = colmin(M_con)
		diff_max = varmax - varmin
		
		// difference for treated and all obs
		Q = J(m+n, a, 0)
		for (i=1; i<=m+n; i++) {
			for (j=1; j<=a; j++) {
				Q[i,j] = abs(M_con[m,j] - M_con[i,j])
			}
		}
		
		// normalized by range
		Q_norm = Q:/diff_max
		
		// mean distance of continuous matching vars
		distance_m = rowsum(Q_norm):/a
	}
	
	// categorical matching vars
	distance_n = J(m+n, m, 0)
	Match = J(m+n, b, 0)
	match = J(m+n, m, 0)
	
	// if categorical matching vars are defined
	if (b > 0) {
		
		for (i=1; i<=m+n; i++) {
			for (j=1; j<=b; j++) {
				if (M_cat[i,j] == M_cat[m,j]) Match[i,j] = 1
			}
			match[i,m] = rowsum(Match[i,.]) / b
			distance_n[i,m] = 1 - match[i,m]
		}
	}
	distance = ((distance_m * a) :+ (distance_n * b)) :/ (a + b)
	
	st_store(., "dist", distance)
		
}

end
