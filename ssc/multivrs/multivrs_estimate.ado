/*
Parse the user input, estimate all of the possible models, store the results in
the results_tempfile.
*/
program multivrs_estimate, rclass
syntax anything (name = model_and_varlist id = "varlist") [if] [in] ///
[,  fe re be mle pa irr offset(passthru) exposure(passthru) absorb(passthru) vce(passthru) ///
noplot plotbs savelist(string) saveas(string) weights(string) alpha(passthru) ///
sample(passthru) size(passthru) bs(passthru) pref(passthru)  ///
estonly compare normal nozero nolistwise ///
 other(passthru) ///
noinfluencecalcs inf_means /// 
noinfluence replace sig_only nosig bs_reps(integer 50) results_tempfile(string) intervals ///
margins marginsopts(string)]
//set up data file to store estimation results
tempname memhold
tempname mem_var_combos
tempfile temp_nonpar_bs_results
local results `"`results_tempfile'"'

tempfile tempfile_var_combos

//local tempfile_var_combos "temp\var_combos"

gettoken model_namelist varlist : model_and_varlist, bind match(par)
multivrs_parse_models `model_namelist'
local nmodeltypes `"`r(nmodeltypes)'"'
local model_namelist_uniq `"`r(model_namelist_uniq)'"'
local model_idlist `"`r(model_idlist)'"'
local model_namelist `"`r(model_namelist)'"'
forvalues i = 1/`nmodeltypes' {
	local model`i'_name `"`r(model`i'_name)'"'
	local model`i'_opts `"`r(model`i'_opts)'"'
	local model`i'_id `"`r(model`i'_id)'"'
}
return local model `model_namelist'
return local model_idlist `model_idlist'

return local varlist `varlist'
return scalar nmodeltypes = `nmodeltypes'
//If the user has not specified a sig_only option or marginal effects then assign it based on the model choices
if "`sig_only'" == "" & "`sig'" != "nosig" & "`margins'" =="" local sig_only `"`r(sig_only_models)'"'
//Otherwise it will stay as "sig_only" or not as the user specified
if "`weights'" == "" local weights "uniform"
// BIC does not work for rreg
if "`weights'" == "bic" & strmatch("`model_namelist_uniq'", "*rreg*") {
	di as error "BIC cannot be calculated for rreg; please select another type of weights (inf, r2, no, or uniform)." 
	exit 198
}

//If the weighting option is not specified then set it to uniform

multivrs_parse_varlist `varlist'

local nSets `"`r(nSets)'"'
local n_var_combinations `"`r(n_var_combinations)'"'
local allvarnames `"`r(allvarnames)'"'
local allvarnames_clean `"`r(allvarnames_clean)'"'
local b_always_in_clean `"`r(b_always_in_clean)'"'
local always_in_varnames `"`r(always_in_varnames)'"'
local intvarlist `"`r(intvarlist)'"'
local depvarlist `"`r(depvarlist)'"'
local intvarlist_noline : subinstr local intvarlist "|" " ", all 
local depvarlist_noline : subinstr local depvarlist "|" " ", all 
forvalues is = 1/`nSets' {
	local s`is'NSX `"`r(s`is'NSX)'"'
	forvalues isx = 1/`s`is'NSX' {
		local s`is'sx`isx'NT = `"`r(s`is'sx`isx'NT)'"'
		forvalues it = 1/`s`is'sx`isx'NT' {
		 local s`is'sx`isx't`it'NTX = `"`r(s`is'sx`isx't`it'NTX)'"'
			forvalues itx = 1/`s`is'sx`isx't`it'NTX' {
				local s`is'sx`isx't`it'tx`itx' `"`r(s`is'sx`isx't`it'tx`itx')'"'
			}
		}
	}
}
if "`sig_only'" == "" {
	local nwarnings 0
	local lists_to_check intvarlist depvarlist
	foreach list of local lists_to_check {
		if `: word count ``list'_noline'' > 1 {
			local list_with_commas : subinstr local `list'  "|" " ", all 
			//local list_with_commas = subinstr("``list''", "|",", ",.)
			local ++nwarnings
			di as text " Warning:  Check that " as result `"`list_with_commas'"' as text " are on a comparable scale, "
			di as text "           so that the meaning of a one unit change is consistent."
		}
	}
	if `nwarnings' > 0 	di as text "           If not, consider standardizing the variables or use the " as result "sig_only" as text " option."
}

multivrs_parse_est_options `model_namelist_uniq' , `fe' `re' `be' `mle' `pa' `irr' ///
`vce' `offset' `exposure' `absorb' `other'
local opts_command `"`r(opts_command)'"'
multivrs_parse_multivrs_options, nSets(`nSets') `sample' `size' `bs' `pref' `alpha' weights(`weights')
local sample_pct `"`r(sample_pct)'"'
local sizemin `"`r(sizemin)'"'
local sizemax `"`r(sizemax)'"'
local bs_type `"`r(bs_type)'"'
if "`intervals'" == "intervals" & "`bs_type'" == "" local bs_type par
local bs_options_user `"`r(bs_options_user)'"'
local bs_opts_all `"`r(bs_opts_all)'"'
local prefb `"`r(prefb)'"'
local prefse `"`r(prefse)'"'
local alpha `"`r(alpha)'"'
local weights `"`r(weights)'"'
local opts_multivrs `"`r(opts_multivrs)'"'


//identify observations meeting "if" and "in" criteria
tempvar touse
mark `touse' `if' `in'
quietly count if `touse'
local total_N = r(N)
if `total_N' == 0 {
	error 2000
}

/*Listwise deletion:  mark out observations with any missing values.
Alert the user to how many observations have been marked out.
TODO: "Sample size varies across model specifications" may not be strictly true, e.g. if the only var
with missing values is always-in. 
*/
if "`listwise'" == "nolistwise" {	
	tempvar touse_temp
	gen `touse_temp' = `touse'
}

markout `touse' `allvarnames'
quietly count if `touse'
local N = r(N)
if `N' == 0 {
	error 2000
}
local nmissing = `total_N' - `N'
if (`nmissing' > 0) di as text "note:  sample size varies across model specifications."
if "`listwise'" != "nolistwise" {
	if (`nmissing' > 0) di  "Listwise deletion:  " `nmissing' as text " out of "  `total_N' as text " observations will not be used."
}
if "`listwise'" == "nolistwise" {
	local N = `total_N'	
	drop `touse'
	gen `touse' = `touse_temp'
	drop `touse_temp' 
}	

//save the list of control term combinations in a text file
if "`savelist'" != "" {
	quietly file open listfile using `savelist', write append
	* if there are options specified to drop any variables, then included this section. 
	if !("`if'" == "" & "`in'" == "" & "`listwise'" == "nolistwise") {		
		file write listfile _n _n "* Generate the indicator variable for observations to use (incorporating any listwise delete, [if] and/or [in] statements)."
		file write listfile _n "tempvar touse"
		file write listfile _n "mark \`touse' `if' `in'"
		if "`listwise'" != "nolistwise"	{
			file write listfile _n "markout \`touse' `allvarnames'"
		}
	}
	file write listfile _n _n "* The number preceding each model corresponds to the variable model_id in the results dataset."
}


*check on variables of interest for xtreg Fixed Effects
forvalues im = 1/`nmodeltypes' {
	local fe fe
	local estimation_options `"`model`im'_opts' `opts_command'"'
	if "`model`im'_name'" == "xtreg" & `: list fe in estimation_options' == 1 {
		foreach intvar of local intvarlist_noline {
			quietly xtsum `intvar' if `touse'
			if r(sd_w)==0 {
				di as err "Variable of interest `intvar0' has 0 within standard deviation."
				exit 198
			}
		}
	}
}

//set margins option
// default for 1 model type : no margins. 
// but it can be overriden by specifying margins or marginopts. 

/*
if `nmodeltypes' == 1 {
	if "`margins'" == "margins" | "`marginsopts'" != "" local margins "margins"
	else local margins "nomargins"
} 
else if `nmodeltypes' > 1 {
	/*if "`margins'" == "nomargins" {
		di "Note: Coefficient estimates from different model types may not be directly comparable." 
		di "The -margins- option is recommended to compare estimated effects across the specified models."
	}
	else {*/
		local margins "margins"
	//}
}
*/

// prepare margin options : make sure there is exactly 1 "post" included. 
if "`margins'" == "margins" {
	local marginsopts_nopost : subinstr local marginsopts "post" "", all
	local marginsopts_post "`marginsopts_nopost' post"
}

//save the user's dataset as a tempfile with touse
tempfile orig_touse
quietly save `orig_touse'

local nrotated = `nSets' - 2
local bs_reps = 50

/*
Estimate the time required for the multivrs command by timing 3 regressions,
averaging the time required and multiplying by the number of models.
*/
local timer_2 99
local timesum 0
local ntests 5
local time_multiplier 1.3
local curr_varlist ""
forvalues is = 1/`nSets' {
	forvalues it = 1/`s`is'sx1NT' {
		local curr_varlist `"`curr_varlist' `s`is'sx1t`it'tx1'"'
	}
}
forvalues im = 1/`nmodeltypes' {
	local model `"`model`im'_name'"'
	forvalues iv = 1/`ntests' {
		timer clear `timer_2'
		timer on `timer_2'

		if "`bs_type'" == "nonpar" quietly bootstrap `bs_opts_all' : ///
			`model' `curr_varlist' if `touse', `opts_command' `opts`im''
		else {
			quietly `model' `curr_varlist' if `touse', `opts_command' `opts`im''
			forvalues ib = 1/`bs_reps' {
				local x = rnormal(0,1)
			}
		}
		timer off `timer_2'
		quietly timer list `timer_2'
		local timesum = `timesum' + r(t`timer_2')
	}
}
local time_avgreg = `time_multiplier'*`timesum'/(`ntests'*`nmodeltypes')
di _newline _continue
local nmodels = `n_var_combinations' * `nmodeltypes'
local large_nmodels 0
local large_threshold 1000

/*Publish number of models to calculate and calculate estimated time.
This is relevant only when the size option is not specified because
have not figured out how to calculate the number of models of each size
taking into account all of the potential for either/or sets.
However, it could be useful to publish an estimate not taking into account
either/or, just as an estimate, would definitely be closer than the full model space
and more useful than no output? */
local extra_digits 3
local two_minutes 120
local sec_per_min 60
local sec_per_hr 3600
//local sample_pct = `sample_pct'
local dot_interval 1000
if "`size'" == "" {
	if `sample_pct' == 0 {
		local ndigits = ceil(log10(`nmodels')) + `extra_digits'
		di "Calculating " %-`ndigits'.0fc `nmodels' "models..."
		local time_est = `time_avgreg' * `nmodels'
		if `nmodels' > `large_threshold' local large_nmodels 1
	}
	else {
		local nmodels_est = `nmodels'*(`sample_pct'/100)
		local ndigits = ceil(log10(`nmodels_est')) + `extra_digits'
		local time_est = `time_avgreg' * `nmodels_est'
		local nmodels_est = round(`nmodels_est')
		di "Calculating " %-`ndigits'.0fc `nmodels_est' "models..."
		if `nmodels_est' > `large_threshold' local large_nmodels 1
	}
if `time_est' < 10 local time_est 10
else local time_est = `time_est'*3

if `time_est' > `two_minutes' {
		local timeunit min
		local ndigits = ceil(log10(`time_est'/`sec_per_min')) + `extra_digits'
		di "Estimated time is " %-`ndigits'.0fc round(`time_est'/`sec_per_min', 1)  " minutes (" round(`time_est'/`sec_per_hr', .1) " hours)."
}

else {
	local timeunit sec
	di "Estimated time is " round(`time_est', 1)  " seconds (" round(`time_est'/`sec_per_min', .1) " minutes)."
}
}
if `large_nmodels' == 1 di "Each dot represents `dot_interval' models calculated"

// Setup to save the results in a dataset to return to the user.  
local postnames i_model str40 (model depvar intvar  )  `allvarnames_clean' str40 (opts) ///
	n r2 df b_intvar ///
	variance pvalue sig pos bic odds_ratio_ind  ///
	`b_always_in_clean'  i_bs

if "`bs_type'" != "" local postnames `"`postnames' b_bs sig_bs pos_bs "'
quietly postfile `memhold' `postnames' using `results', replace

// Setup to save the var combinations in a dataset just for internal use. 
quietly postfile `mem_var_combos' `allvarnames_clean' str40 (depvar intvar model) using `tempfile_var_combos', replace

//indicator vector for which sets are present in the model, sets 1 and 2 (depvar and intvar) always in
matrix curr_Sets_ind = J(1, `nSets', 0)
local Sets_always_in 1 2
foreach Set of local Sets_always_in {
	matrix curr_Sets_ind[1, `Set'] = 1
}
local first_rotated_set 3
local nrounds = 2^(`nSets'-2)
local nmodels_actual 0

*********************************************************
// Loop to list out and save the variable combinations
********************************************************
// First, loop over the number of rounds: number of combinations of presence/absence of Sets
forvalues i_round = 1/`nrounds' {
	/* Select the Sets present in this series of models by iterating through
	the binary numbers in the vector curr_Sets_ind */
	forvalues i = `first_rotated_set'/`nSets' {
		if curr_Sets_ind[1, `i'] == 0 {
			matrix curr_Sets_ind[1, `i'] = 1
			continue, break
		}
		else {
			matrix curr_Sets_ind[1, `i'] = 0
		}
	}
	local curr_n_control_terms = 1
	local curr_Setlist "`Sets_always_in'"

	//Track the number of SetX within each of the included sets
	local NSX_by_Set "`s1NSX' `s2NSX'"
	forvalues i_Set = `first_rotated_set'/`nSets' {
		if curr_Sets_ind[1, `i_Set'] == 1 {
			local ++curr_n_control_terms
			local curr_Setlist `"`curr_Setlist' `i_Set'"'
			local NSX_by_Set `NSX_by_Set' `s`i_Set'NSX'
		}
	}
	
	// Check whether the specified model meets the user-input model size criteria
	if `curr_n_control_terms' >= `sizemin' & `curr_n_control_terms' <= `sizemax' {
		local curr_n_sets = `curr_n_control_terms' + 1
		/* Subroutine to generate the list of all possible combinations of
		either/or subsets of the included sets.*/
		GenerateSetXList,  nSX_by_Set(`NSX_by_Set') setXlist("") count_Xlists(0) ///
			setlist(`curr_Setlist') unit(Set) curr_length(0)
		local count_Xlists = r(count_Xlists)
		forvalues i = 1/`count_Xlists' {
			local SetXlist`i' = r(SetXlist`i')
		}
		clear results
		/* Iterate through each of the SetXlists and generate the list of all
		the terms of each of the included SetX */
		forvalues i_SetXlist = 1/`count_Xlists' {
			local curr_Termlist ""
			forvalues i_Set = 1/`curr_n_sets' {
				local Set : word `i_Set' of `curr_Setlist'
				local SetX : word `i_Set' of `SetXlist`i_SetXlist''
				forvalues i_Term = 1/`s`Set'sx`SetX'NT' {
					local curr_Termlist "`curr_Termlist' s`Set'sx`SetX't`i_Term'"
				}
			}
			//track the number of Termx within each of the included Terms
			local NTX_by_Term ""
			foreach term of local curr_Termlist {
				local NTX_by_Term "`NTX_by_Term' ``term'NTX'"
			}
			/*Generate the list of all possible combinations of
			either/or variables of the included Terms */
			GenerateSetXList, curr_length(0) setlist(`curr_Termlist') ///
			 nSX_by_Set(`NTX_by_Term') setXlist("") count_Xlists(0) unit(Term)
			local count_TermXlists = r(count_Xlists)
			forvalues i = 1/`count_TermXlists' {
				local TermXlist`i' = r(TermXlist`i')
			}
			clear results
			
			// Save the variable combination to a dataset. 
			forvalues i_TermXlist = 1/`count_TermXlists' {
				local curr_varlist ""
				foreach TermX of local TermXlist`i_TermXlist' {
					local curr_varlist "`curr_varlist' ``TermX''"
				}			
				local depvar : word 1 of `curr_varlist'
				local intvar : word 2 of `curr_varlist'					
				local curr_varlist_ind ""
				foreach varname of local allvarnames {
					local IsIncludedVariable : list varname & curr_varlist
					if "`IsIncludedVariable'" != "" {
						local curr_varlist_ind `curr_varlist_ind' (1)
					}
					else local curr_varlist_ind `curr_varlist_ind' (0)
				}
				forvalues i_model_type = 1/`nmodeltypes' {
					quietly post `mem_var_combos' `curr_varlist_ind' ("`depvar'") ("`intvar'") ("`model`i_model_type'_id'")
				}
			}
		}
	}
}
postclose `mem_var_combos'
	
// Translate var combos to a stata matrix to iterate in the next loop
preserve
use `tempfile_var_combos', clear
quietly duplicates drop
quietly sample `sample_pct'
quietly gen i_model = _n
qui save `tempfile_var_combos', replace
local n_vars_considered : word count `allvarnames'
local n_var_combos = `c(N)'

mata {
	n_vars_considered = strtoreal(st_local("n_vars_considered"))
	var_combos = st_data(.,1..n_vars_considered)	
	key_vars = st_sdata(., ("depvar", "intvar", "model"))		
}
restore	

*********************************************************				
// Main loop for estimation of all the models
*********************************************************	
// Loop over the var combos
forvalues i_var_combo = 1/`n_var_combos' {
	
	/*
	//Sample barrier
	local PassedSampleThreshold 0
	if `threshold' == 0 local PassedSampleThreshold 1
	else {
		local r = runiform()
		if `r' <= `threshold' local PassedSampleThreshold 1
	}
	if `PassedSampleThreshold' == 1 {
	*/
		// identify the model type (reg, logit, etc)
		mata: st_local("model_id", key_vars[strtoreal(st_local("i_var_combo")), 3])
		forvalues i_model_type = 1/`nmodeltypes' {
			if "`model_id'" == "`model`i_model_type'_id'" {
				local model `model`i_model_type'_name'				
				local opts_touse `"`opts_command' `model`i_model_type'_opts'"'
				local odds_ratio_ind 0
				local irr irr
				if "`model'" == "logistic" | `: list irr in opts_touse' local odds_ratio_ind 1	
			}
		}
	
		//Identify the variable names included in this model. 
		
		//mata: st_matrix("curr_row", var_combos[`i_var_combo',])
		//mata: st_local("curr_depvar", var_combos[`i_var_combo', 
		//matlist curr_row
		
		local curr_varlist ""				
		forvalues i_var = 1/`n_vars_considered' {
			//mata: var_combos[1,1] // column : this var name
		
			mata: st_local("var_in_model", /// assign to this local var
				 strofreal(var_combos[strtoreal(st_local("i_var_combo")), /// row : this var combo
						   strtoreal(st_local("i_var"))] )) // column : this var name		
			if  "`var_in_model'" == "1" { // build up the list of var names in this model. 
				local curr_varlist "`curr_varlist' `: word `i_var' of `allvarnames''"	
			}
		}	
		local ++nmodels_actual
		
		if "`savelist'" != "" {
			file write listfile _n "* `nmodels_actual'"
			file write listfile _n `"`model' `curr_varlist'"'
			// note: for some reason, would not write `touse' but would 
			// evaluate `touse' to __0000004 if the following was all on one line
			if !("`listwise'" == "nolistwise" & "`if'" == "" & "`in'" == "") {
				file write listfile " if \`touse'"
			}
			if (trim("`opts_touse'") != "") file write listfile `", `opts_touse'"'			
				
		}
		
		mata: st_local("depvar", key_vars[strtoreal(st_local("i_var_combo")), 1])
		mata: st_local("intvar", key_vars[strtoreal(st_local("i_var_combo")), 2])
		
		if strmatch("`intvar'", "i.*") {		
			local intvar_for_results : subinstr local intvar "i." "1."
		} 
		else {
			local intvar_for_results "`intvar'"
		}
		
		/*
		local depvar : word 1 of `curr_varlist'
		local intvar : word 2 of `curr_varlist'
		*/			
		
		//Estimate the model
		if "`bs_type'" == "nonpar" quietly bootstrap `bs_opts_all' ///
			saving(`temp_nonpar_bs_results', replace): ///
			`model' `curr_varlist' if `touse', `opts_touse'

		else quietly `model' `curr_varlist' if `touse', `opts_touse'
		mat results_table = r(table)
		// Calculate information criteria including BIC
		// note that estat ic does not work for rreg		
		capture estat ic
		if "`_rc'" == "0"  {
			local is_bic_ok 1
		}
		else {
			local is_bic_ok 0 
		}
		
		//Save the results
		if "`model'" == "xtreg"	{
			if ("`be'" == "be"| "`fe'" == "fe"  | "`re'" == "re") local e_r2 = e(r2_o)
			else local e_r2 = .				
		}
		else if inlist("`model'", "regress", "areg", "rreg") local e_r2 = e(r2)
		else local e_r2 = e(r2_p)
				
		if "`margins'" != "margins" {
			local b = _b[`intvar_for_results']
			local variance = (_se[`intvar_for_results'])^2
			local pval = results_table[rownumb(results_table, "pvalue"), colnumb(results_table, "`intvar_for_results'")]
		}
		else if "`margins'" == "margins" {
		
			capture margins , dydx(`intvar_for_results') `marginsopts_post'
			local marginsrc = _rc
			if `marginsrc' != 0 {
				di _newline
				di as error "Error with -margins- command."
				di as result "Last estimation result completed:"
				estimates replay
				di _newline
				di as result  "-margins- command that produced the error:"
				di as error `"margins, dydx(`intvar_for_results') `marginsopts_post' "'
				exit `marginsrc'		
			}
			mat margins_table = r(table)			
			local b = margins_table[rownumb(margins_table, "b"), colnumb(margins_table, "`intvar_for_results'")]
			local pval = margins_table[rownumb(margins_table, "pvalue"), colnumb(margins_table, "`intvar_for_results'")]
			local variance = margins_table[rownumb(margins_table, "se"), colnumb(margins_table, "`intvar_for_results'")]^2
			
			if "`savelist'" != "" file write listfile _n `"margins, dydx(`intvar_for_results') `marginsopts_post' "'
		
		}
		local always_in_estimates ""
		foreach var of local always_in_varnames {
			capture local b_var = _b[`var']
			if _rc == 0 local always_in_estimates `always_in_estimates' (`b_var')
			else local always_in_estimates `always_in_estimates' (.)
		}		
		
		
		/*
		if inlist("`e(model)'", "ols", "fe") & "`bs_type'" != "nonpar" ///
			local pval = (2*ttail(e(df_r), abs(_b[`intvar_for_results']/_se[`intvar_for_results'])))
		else local pval = 2*(1-normal(abs(_b[`intvar_for_results']/_se[`intvar_for_results'])))
		*/
		local sig = (`pval' <= `alpha')
		local pos = (`b' > 0)
		//Save the BIC
		matrix ic_mat = r(S)
		local bic = ic_mat[1,6]
		
		// Keep track of sample size range
		// useful when listwise delete is off and sample size varies across models
		local sampsize = e(N)
		if "`cur_max_sampsize'" != "" {
			if `sampsize' > `cur_max_sampsize' { 
				local cur_max_sampsize = `sampsize' 
			}
		} 
		else {
			local cur_max_sampsize = `sampsize'	
		}
		if "`cur_min_sampsize'" != "" {
			if `sampsize' < `cur_min_sampsize' { 
				local cur_min_sampsize = `sampsize' 
			}
		} 
		else {
			local cur_min_sampsize = `sampsize'
		}					
		// Prepare to post results in the results dataset. 
		local topost (`nmodels_actual') ("`model_id'") ("`depvar'") ("`intvar'") ///
			`curr_varlist_ind' ("`model`i_model_type'_opts'")  ///
			(`sampsize') (`e_r2') (e(df_m)) (`b') ///
			(`variance') (`pval')  (`sig') (`pos') (`bic') (`odds_ratio_ind') ///			
			`always_in_estimates'		
			 
		
		/* If user specified nonparametric bootstrap then open the saved
		results from the bootstrap routine and store them in the model
		results file */
		if "`bs_type'" == "nonpar" {
			capture use `temp_nonpar_bs_results', clear
			if inlist("`model'", "probit", "logit", "logistic", "poisson") ///
				local _bvar `depvar'_b_`intvar'
			else local _bvar _b_`intvar'
			local n_bsreps = _N
			forvalues i_bs = 1/`n_bsreps' {
				if 2*(1-normal(abs(`_bvar'[`i_bs']/_se[`intvar']))) <= `alpha' ///
					local sig_bs 1
				else local sig_bs 0
				local pos_bs = ( `_bvar'[`i_bs'] > 0 )
				post `memhold' `topost' (`i_bs') (`_bvar'[`i_bs']) (`sig_bs') (`pos_bs')
			}
			capture use `orig_touse', clear
		}
		/* Otherwise resample the coefficients with parametric bootstrap
		according to the normal distribution */
		else if "`bs_type'" == "par"{
			forvalues i_bs = 1/`bs_reps' {
				local bs_sample = rnormal(_b[`intvar'], _se[`intvar'])
				local pos_bs = ( `bs_sample' > 0 )
				if inlist("`e(model)'", "ols", "fe") {
					if (2*ttail(e(df_r), abs(`bs_sample'/_se[`intvar']))) <= `alpha' ///
						local sig_bs 1
					else local sig_bs 0
				}
				else if 2*(1-normal(abs(`bs_sample'/_se[`intvar']))) <= `alpha' ///
					local sig_bs 1
				else local sig_bs 0
				post `memhold' `topost'  (`i_bs') (`bs_sample') (`sig_bs') (`pos_bs')
			}
		}
		else post `memhold' `topost'  (1)
		
		// Display progress for user. 
		if `large_nmodels' == 1 {
			if mod(`nmodels_actual', `dot_interval') == 0 {
				di _continue "."
			}
		}
		
	//} // if sample threshold is met
} // loop over var combos

postclose `memhold'
if "`savelist'" != "" quietly file close listfile


//Merge the 2 datasets: results and var combos
preserve
use `tempfile_var_combos', clear
merge 1:1 i_model depvar intvar model using `results', nogenerate noreport
qui save `results', replace
restore

/*calculate multicollinearity of var of interest
if there are >1 options for intvar, take the mean of the MCs*/
local mcsum = 0
local nintvar : word count `intvarlist_noline'
local xvars : list allvarnames - depvarlist_noline
local xvars : list xvars - intvarlist_noline
foreach intvar of local intvarlist_noline {

	if strmatch("`intvar'", "i.*") {		
		local intvar_for_multicol : subinstr local intvar "i." ""
	} 
	else {
		local intvar_for_multicol "`intvar'"
	}
	
	quietly reg `intvar_for_multicol' `xvars' if `touse'
	local mcsum = `mcsum' + e(r2)
}
return scalar mc = `mcsum'/`nintvar'

/*calculate the SD of the variable of interest
if there are >1 options for intvar, take the mean of the SDs
*/
local sd2intvar 0
foreach intvar of local intvarlist_noline {
	quietly summarize `intvar' if `touse'
	local sd2intvar = `sd2intvar' + (r(sd)^2)
}
return scalar sdintvar = sqrt(`sd2intvar')
return local bs_type `"`bs_type'"'
return local bs_opts `"`bs_options_user'"'
return scalar bs_reps = `bs_reps'
return scalar alpha = `alpha'
if "`pref'" != "" {
	return scalar prefb = `prefb'
	return scalar prefse = `prefse'
}
return local sig_only "`sig_only'"
return local savelist "`savelist'"
return local opts_command `"`opts_command'"'
return local opts_multivrs `"`opts_multivrs'"'
forvalues im = 1/`nmodeltypes' {
	return local model`im'_name "`model`im'_name'"
	return local model`im'_opts "`model`im'_opts'"
	return local model`im'_id "`model`im'_id'"

}
return local intvar `"`intvarlist'"'
return local depvar `"`depvarlist'"'
return local model `"`model_namelist'"'
return local cmd multivrs
return scalar nmodels = `nmodels_actual'
return scalar nterms = `nrotated'
return scalar nvars = `: word count  `allvarnames'' - `: word count `depvarlist_noline''
return scalar N = `N'
return scalar Nmax = `cur_max_sampsize'
return scalar Nmin = `cur_min_sampsize'
return local weights `"`weights'"'
return local margins `margins'
return local marginsopts `marginsopts'

if "`listwise'" == "nolistwise" {
	return scalar listwise_delete = 0
}
else {
	return scalar listwise_delete = 1
}

end

// End program Multivrs_estimate

/*
Recursive branching subroutine to generate the list of all possible combinations of
of either/or SetX units of the included Sets.
We want exactly one SetX for each of the included n Sets.  The base case is we have
assembled a SetXlist to return containing n SetX ( 1 SetX for each Set ).
If the assembled SetXlist contains i SetX, i < n, then for each of the SetX j
in the next Set i+1, we add j to the SetXlist and pass this incremented SetXList
of length i+1 back into GenerateSetXList.
Arguments:
curr_length length of current SetXList to return
Setlist is the list of Sets included
NSX_by_set lists the number of setx in each of the included sets
SetXlist lists the current assembled setxlist to return
count_SetXlist holds the total number of generated setxlists so far
unit indicates whether we are dealing with Sets or Terms
Return values
r(count_Xlists) is the total number of distinct SetXlists generated
for values i = 1 to r(count_Xlists),
r(SetXlist`i') is a string indicating the components of the ith SetXlist
*/

//program GenerateUnitList

program GenerateSetXList, rclass
syntax [, setlist(string) nSX_by_Set(numlist) setXlist(string) count_Xlists(integer 0)  unit(string) curr_length(integer 0) ]

	if `curr_length' == `: word count `setlist'' {
		local ++count_Xlists
		return local count_Xlists `count_Xlists'
		return local `unit'Xlist`count_Xlists' `setXlist'
	}
	else {
		local ++curr_length
		local curr_set : word `curr_length' of `setlist'
		local nSX_this_set : word `curr_length' of `nSX_by_Set'
		forvalues i = 1/`nSX_this_set' {
			if "`unit'" == "Set" local curr_SetXlist "`setXlist' `i'"
			else local curr_SetXlist "`setXlist' `curr_set'tx`i'"
			local count = r(count_Xlists)
			if "`count'" == "."  local count = 0
			GenerateSetXList, curr_length(`curr_length') setlist("`setlist'") nSX_by_Set(`nSX_by_Set') setXlist(`curr_SetXlist') count_Xlists(`count') unit(`unit')
			foreach mac in `:r(macros)' {
				return local `mac' `=r(`mac')'
			}
		}
	}
end
