**mrobust version 1.0, January 2014
**An Estimator for Model Robustness
**Cristobal Young and Kathy Kroeger


//wrapper program to make sure we clean up mata afterwards
program mrobust
	version 11.0
	capture noisily mrobust_u `0'
	local rc = _rc
	capture mata:  mata drop mrobust_varnames
	exit `rc'
end

//main program including all of the important subunits of the procedure
program mrobust_u, rclass
preserve
if !replay() {
	syntax anything [if] [in] ///
	[, noplot influence normal nozero plotbs intervals ///
	saveas(passthru) replace *]
	local timer_1 98
	timer clear `timer_1'
	timer on `timer_1'
	tempfile temp_model_results
	//If the input does not already contain a comma and options then add a comma
	if !strmatch(`"`0'"', "*,*") local 0 `"`0',"'
	MRobust `0' results_tempfile(`"`temp_model_results'"')
	// load file with bootstrap results and display output
	capture use `"`temp_model_results'"', clear
	if c(rc) {
		if inrange(c(rc),900,903) {
			di _newline as err ///
"insufficient memory to load file with mrobust results"
		}
		error c(rc)
	}
	CalcSummaryStats, `saveas' `replace'
	timer off `timer_1'
	quietly timer list `timer_1'
	local time_taken = r(t`timer_1')
	local sig_only `"`r(sig_only)'"'
	DisplayResults, full `sig_only' `influence' `intervals' time_taken(`time_taken') 
	if "`sig_only'" == "sig_only" local plot noplot
	if "`plot'" != "noplot" PlotMRobust , `rmal' `zero' `plotbs' bs(`r(bs_type)')
}
//replaying results
else {
	syntax [, more full sig_only intervals nosig]
	if "`sig'" == "nosig" local full full
	if `"`r(cmd)'"' != "mrobust" {
		di as err "To replay mrobust results, the last command must be a successful run of " as result "mrobust" as err "." 
		exit 198
	}
	local varlist `"`r(varlist)'"'
	ParseVarlist `varlist', display_only
	local time_taken = `r(time_taken)'
	DisplayResults, `more' `full' `sig_only' `intervals' time_taken(`time_taken')

}
return local sig_only `"`sig_only'"'
//return local saveas `"`saveas'"'
return add

restore 
end


/*
Parse the user input, estimate all of the possible models, store the results in
the results_tempfile. 
*/ 
program MRobust, rclass
syntax anything (name = model_and_varlist id = "varlist") [if] [in] ///
[,  fe re be mle pa irr offset(passthru) exposure(passthru) absorb(passthru) vce(passthru) ///
noplot plotbs savelist(string) saveas(string) alpha(passthru) ///
sample(passthru) size(passthru) bs(passthru) pref(passthru)  ///
estonly compare normal nozero nolistwise ///
 other(passthru) ///
noinfluence replace sig_only nosig bs_reps(integer 50) results_tempfile(string) intervals ]

//set up data file to store estimation results
tempname memhold
tempfile temp_nonpar_bs_results
local results `"`results_tempfile'"'

gettoken model_namelist varlist : model_and_varlist, bind match(par) 
ParseModels `model_namelist'
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
//If the user has not specified a sig_only option then assign it based on the model choices
if "`sig_only'" == "" & "`sig'" != "nosig"  local sig_only `"`r(sig_only_models)'"' 
//Otherwise it will stay as "sig_only" or not as the user specified

ParseVarlist `varlist'
local nSets `"`r(nSets)'"'
local n_var_combinations `"`r(n_var_combinations)'"'
local allvarnames `"`r(allvarnames)'"'
local allvarnames_clean `"`r(allvarnames_clean)'"'
local b_always_in_clean `"`r(b_always_in_clean)'"'
local always_in_varnames `"`r(always_in_varnames)'"'
local intvarlist `"`r(intvarlist)'"'
local depvarlist `"`r(depvarlist)'"'
local intvarlist_noline = subinstr("`intvarlist'", "|"," ",.)
local depvarlist_noline = subinstr("`depvarlist'", "|", " ", .)
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
		if wordcount("``list'_noline'") > 1 {
			local list_with_commas = subinstr("``list''", "|",", ",.)
			local ++nwarnings
			di as text " Warning:  Check that " as result `"`list_with_commas'"' as text " are on a comparable scale, "
			di as text "           so that the meaning of a one unit change is consistent."
		}
	}
	if `nwarnings' > 0 	di as text "           If not, consider standardizing the variables or use the " as result "sig_only" as text " option."
}

ParseEstimationOptions `model_namelist_uniq' , `fe' `re' `be' `mle' `pa' `irr' ///
`vce' `offset' `exposure' `absorb' `other'
local opts_command `"`r(opts_command)'"'

ParseMrobustOptions, nSets(`nSets') `sample' `size' `bs' `pref' `alpha'
local threshold `"`r(threshold)'"'
local sizemin `"`r(sizemin)'"'
local sizemax `"`r(sizemax)'"'
local bs_type `"`r(bs_type)'"'
if "`intervals'" == "intervals" & "`bs_type'" == "" local bs_type par
local bs_options_user `"`r(bs_options_user)'"'
local bs_opts_all `"`r(bs_opts_all)'"'
local prefb `"`r(prefb)'"'
local prefse `"`r(prefse)'"'
local alpha `"`r(alpha)'"'
local opts_mrobust `"`r(opts_mrobust)'"'

//identify observations meeting "if" and "in" criteria
tempvar touse
mark `touse' `if' `in'
quietly count if `touse' 
local total_N = r(N)
if `total_N' == 0 {
	error 2000
}

/*Listwise deletion:  mark out observations with any missing values.
Alert the user to how many observations have been marked out
*/
if "`listwise'" != "nolistwise" {
markout `touse' `allvarnames'
quietly count if `touse'
local N = r(N)
if `N' == 0 {
	error 2000
}
local nmissing = `total_N' - `N'
if (`nmissing' > 0) {
	di as text "note:  sample size varies across model specifications." 
	di  "Listwise deletion:  " `nmissing' as text " out of "  `total_N' as text " observations will not be used."
}
}
else local N = `total_N'

/*check on variables of interest for xtreg Fixed Effects*/
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
//save the user's dataset as a tempfile with touse
tempfile orig_touse
quietly save `orig_touse'

local nrotated = `nSets' - 2
local bs_reps = 50

/*
Estimate the time required for the mrobust command by timing 3 regressions, 
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
local sample_pct = `threshold'
local dot_interval 1000
if "`size'" == "" {
if `sample_pct' == 0 {
	local ndigits = ceil(log10(`nmodels')) + `extra_digits'
	di "Calculating " %-`ndigits'.0fc `nmodels' "models..."
	local time_est = `time_avgreg' * `nmodels'
	if `nmodels' > `large_threshold' local large_nmodels 1
}
else { 
	local nmodels_est = `nmodels'*`sample_pct'
	local ndigits = ceil(log10(`nmodels_est')) + `extra_digits'
	local time_est = `time_avgreg' * `nmodels_est'
	local nmodels_est = round(`nmodels_est')
	di "Calculating approximately " %-`ndigits'.0fc `nmodels_est' "models..."
	if `nmodels_est' > `large_threshold' local large_nmodels 1	
}

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

local postnames `allvarnames_clean' r2 df b_intvar `b_always_in_clean' sig pos ///
 variance pvalue odds_ratio_ind str40 (depvar intvar model opts) i_model i_bs 
 
if "`bs_type'" != "" local postnames `"`postnames' b_bs sig_bs pos_bs "'
quietly postfile `memhold' `postnames' using `results', replace

//save the list of control term combinations in a text file
if "`savelist'" != "" {
	quietly file open listfile using `savelist', write replace
	file write listfile "mrobust `model' `varlist'" 
	file write listfile _newline "generated control term combinations:"
}

//indicator vector for which sets are present in the model, sets 1 and 2 (depvar and intvar) always in
matrix curr_Sets_ind = J(1, `nSets', 0)
local Sets_always_in 1 2
foreach Set of local Sets_always_in {
	matrix curr_Sets_ind[1, `Set'] = 1
}
local first_rotated_set 3
local nrounds = 2^(`nSets'-2)
local nmodels_actual 0
//Main loop
forvalues i_model_type = 1/`nmodeltypes' {
	local model `model`i_model_type'_name'
	local model_id `model`i_model_type'_id'
	local opts_touse `"`opts_command' `model`i_model_type'_opts'"'
	local odds_ratio_ind 0
	local irr irr
	if "`model'" == "logistic" | `: list irr in opts_touse' local odds_ratio_ind 1
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
					local Set = word("`curr_Setlist'", `i_Set')
					local SetX = word("`SetXlist`i_SetXlist''", `i_Set')
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
				forvalues i_TermXlist = 1/`count_TermXlists' {		
					//Sample barrier
					local PassedSampleThreshold 0
					if `threshold' == 0 local PassedSampleThreshold 1
					else {
						local r = runiform()
						if `r' <= `threshold' local PassedSampleThreshold 1
					}
					if `PassedSampleThreshold' == 1 {
						local curr_varlist ""
						foreach TermX of local TermXlist`i_TermXlist' {
							local curr_varlist "`curr_varlist' ``TermX''"
						}
						local ++nmodels_actual
						/* Create indicator to denote included variables in the 
						dataset to post in the saved results file */
						local curr_varlist_ind ""
						foreach varname of local allvarnames {
							local IsIncludedVariable : list varname & curr_varlist
							if "`IsIncludedVariable'" != "" {
								local curr_varlist_ind `curr_varlist_ind' (1)
							}
							else local curr_varlist_ind `curr_varlist_ind' (0)
						}		
						if "`savelist'" != "" file write listfile _n "`curr_varlist'"
						local depvar = word("`curr_varlist'", 1)
						local intvar = word("`curr_varlist'", 2)
						//Estimate the model
				   		if "`bs_type'" == "nonpar" quietly bootstrap `bs_opts_all' ///
				   			saving(`temp_nonpar_bs_results', replace): ///
				   			`model' `curr_varlist' if `touse', `opts_touse'
				   		
						else quietly  `model' `curr_varlist' if `touse', `opts_touse'
						//Save the results
						if "`model'" == "xtreg"	local e_r2 = e(r2_o)
						else if inlist("`model'", "reg", "areg", "rreg") local e_r2 = e(r2) 
						else local e_r2 = e(r2_p)
						local b = _b[`intvar']
						local always_in_estimates ""
						foreach var of local always_in_varnames {
							capture local b_var = _b[`var']
							if _rc == 0 local always_in_estimates `always_in_estimates' (`b_var')
							else local always_in_estimates `always_in_estimates' (.)
						}
						local variance = (_se[`intvar'])^2
						if inlist("`e(model)'", "ols", "fe") & "`bs_type'" != "nonpar" ///
							local pval = (2*ttail(e(df_r), abs(_b[`intvar']/_se[`intvar'])))
						else local pval = 2*(1-normal(abs(_b[`intvar']/_se[`intvar'])))
						local sig = (`pval' <= `alpha')
						local pos = (`b' > 0)
						local topost `curr_varlist_ind' (`e_r2') (e(df_m)) (`b') ///
								`always_in_estimates'  ///
							(`sig') (`pos') (`variance') (`pval') (`odds_ratio_ind') ///
							("`depvar'") ("`intvar'") ("`model_id'") ///
							("`model`i_model_type'_opts'") (`nmodels_actual')	
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
						if `large_nmodels' == 1 {
							if mod(`nmodels_actual', `dot_interval') == 0 {
								di _continue "."
							}
						}
					}	
				}
			}	
		}
	}
}	
postclose `memhold'
if "`savelist'" != "" quietly file close listfile

/*calculate multicollinearity of var of interest
if there are >1 options for intvar, take the mean of the MCs*/
local mcsum = 0
local nintvar = wordcount("`intvarlist_noline'")
local xvars : list allvarnames - depvarlist_noline
local xvars : list xvars - intvarlist_noline
foreach intvar of local intvarlist_noline {
	quietly reg `intvar' `xvars' if `touse'
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
return local opts_mrobust `"`opts_mrobust'"'
forvalues im = 1/`nmodeltypes' {
	return local model`im'_name "`model`im'_name'"
	return local model`im'_opts "`model`im'_opts'"
	return local model`im'_id "`model`im'_id'"

}
return local intvar `"`intvarlist'"'
return local depvar `"`depvarlist'"'
return local model `"`model_namelist'"'
return local cmd mrobust
return scalar nmodels = `nmodels_actual'
return scalar nterms = `nrotated'
return scalar nvars = wordcount("`allvarnames'") - wordcount("`depvarlist_noline'")
return scalar N = `N'

end
/*
ParseModels function takes in the user's list of estimation commands
and returns the following local macros:  
sig_only_models ("sig_only" if the user has specified two or more model types
whose coefficient magnitudes are not directly comparable, "" else)
nmodeltypes (number of different estimation commands specified)
model_namelist (list of estimation commands)
model_namelist_uniq (list of unique estimation commands)
model_idlist (list of estimation commands, with repeated commands numbered)
for each model in the user's input list:
model`i'_name, model`i'_opts,model`i'_id
*/
program ParseModels, rclass
syntax anything(name = model_list_input)
local model_list_input = subinstr("`model_list_input'", "[", "(" , .)
local model_list_input = subinstr("`model_list_input'", "]", ")" , .)
local sig_only_list logit logistic probit nbreg poisson
local allowed reg logit logistic probit poisson nbreg areg rreg xtreg
local model_list_to_return ""
//i counts the number of distinct model types
local i 0
while `"`:list retok model_list_input'"' != "" {
	gettoken model_name model_list_input : model_list_input , bind parse(" |()")
	if !inlist("`model_name'","|","(",")") {
		if "`model_name'" == "regress" local model_name reg
		if `:list model_name in allowed' != 1 {
			di as err "Invalid model type.  Model options are reg, logit, logistic, probit, poisson, nbreg, areg, rreg, xtreg."
			exit 198
		}
		if `:list model_name in sig_only_list' == 1 {
			local sig_only sig_only
		}
		local ++i
		local model`i'_name `model_name'
		local model_list_to_return `model_list_to_return' `model_name'
		gettoken opts model_list_input : model_list_input, bind match(par) parse(" |")
		if "`par'" == "" {
			local model_list_input "`options' `model_list_input'"
		}
		else local model`i'_opts `opts'
	}
}
local model_list_to_return : list retok model_list_to_return
local dups_model_namelist : list dups model_list_to_return
foreach d of local dups_model_namelist {
	local n_repeats_`d' 0
}
local model_idlist ""
forvalues j = 1/`i' {
	local name `model`j'_name'
	if `:list name in dups_model_namelist' == 1 {
		local ++ n_repeats_`name'
		local model`j'_id `name'_`n_repeats_`name''
	}
	else local model`j'_id `name'
	local model_idlist `"`model_idlist' `model`j'_id'"'
}
if `i' == 1 local sig_only ""
return local sig_only_models "`sig_only'"
return local nmodeltypes = `i'
return local model_namelist_uniq : list uniq model_list_to_return
return local model_idlist `model_idlist'
return local model_namelist `model_list_to_return'	
forvalues j = 1/`i' {
	return local model`j'_name `model`j'_name'
	return local model`j'_opts `model`j'_opts'
	return local model`j'_id `model`j'_id'
}
end
/*
Parse the options that will be passed into the Stata command for every model
*/
program ParseEstimationOptions, rclass
syntax anything(name = model_namelist_uniq) [, fe re be mle pa vce(string) ///
offset(varname) exposure(varname) irr absorb(varname) other(string)]
local opts_command ""
local xtreg_option "`fe' `re' `be' `mle' `pa'"
local xtreg_option : list retok xtreg_option
if "`xtreg_option'" != "" {
	if "`model_namelist_uniq'" != "xtreg" {
		di as err "Invalid `xtreg_option'.  `xtreg_option' only allowed with xtreg."
		exit 198
	}
}
local absorb_option ""
if "`model_namelist_uniq'" == "areg" {
	if ("`absorb'" == "") {
		di as err "option absorb() required"
		exit 198
	}
	else {
		local absorb_option "absorb(`absorb')"
	}
} 
else if ("`absorb'" != "") {
	di as err "Invalid absorb option.  Absorb may only be used with areg."
	exit 198
}
local est_options irr offset exposure
local est_options_models_ok poisson nbreg
foreach opt of local est_options {
	if "``opt''" != "" {
		if `: list model_namelist_uniq in est_options_models_ok' != 1 {
			di as err "Invalid `opt' option.  `opt' should only be used " ///
			"with poisson or negative binomial regression."
			exit 198
		}
		else if "`opt'" != "irr" local `opt'_option "`opt(``opt'')'"
		else local `opt'_option "`opt'"
	}
}
local vce_option ""
if ("`vce'" != "") { 
	if !regexm("`vce'","robust|cluster*") {
		di as err "Invalid vce option.  Vce options are robust and cluster."
		exit 198
	}
	local rreg rreg
	if `: list rreg in model_namelist_uniq' == 1 {
		di as err "option vce() not allowed with rreg."
		exit 198
	}
	
	local vce_option "vce(`vce')"
}
local opts_command `xtreg_option' `absorb_option' `irr' `exposure_option' ///
	`offset_option' `vce_option' `other'
local opts_command : list retok opts_command
return local opts_command `"`opts_command'"'
end
/*
Parse the options that are specific to mrobust functionality and will not be 
passed into the actual commands.   
*/
program ParseMrobustOptions, rclass
syntax [,  nSets(integer 0) sample(integer 0) ///
size(numlist integer >=0 missingokay max=2 min=1) ///
alpha(real .05) bs(string) pref(numlist max=2 min=2)  ]


local opts_mrobust ""
local sample_option ""
if `sample' < 0 | `sample' > 100 {
	di as err "Sample percent should be an integer 1-99."
	exit 198
}
if `sample' == 0 {
	local threshold = 1
} 
else { 
	local threshold = `sample'/100
	local sample_option sample(`sample')
}

local size_opt_optput ""
if "`size'" == "" {
	local sizemin = 1
	local sizemax = `nSets'
}
else {
	gettoken sizemin sizemax : size, parse(" ,")
	if trim("`sizemin'") == "."  local sizemin = 1
	if `sizemin' == 0 local sizemin = 1
	if trim("`sizemax'") == "."  local sizemax = `nSets'
	if "`sizemax'" == "" local sizemax = `sizemin'
	if `sizemax' > `nSets' local sizemax = `nSets'
	if (`sizemin' > `sizemax') | (`sizemin' >= `nSets') {
		di as err "invalid size option"
		exit 198
	}
	if `sizemin' == 1 & `sizemax' == 1 {
		di as err "invalid size option"
		exit 198
	}
	local size_opt_output size(`sizemin', `sizemax')
}	

local alpha_opt_output "" 
if `alpha' < 0 | `alpha' >= 1 {
	di "note:  invalid alpha.  Default alpha = .05 will be used."
	local alpha = .05
}
else if `alpha' != .05 local alpha_opt_output alpha(`alpha')

local bs_types_allowed par nonpar
local bs_options_default nodots
local bs_options_user ""
local bs_type ""
local bs_opts_all ""
local bs_opt_output ""

if "`bs'" != "" {
	gettoken bs_type bs_options_user : bs, parse(" ,")
	if `: list bs_type in bs_types_allowed' != 1 {
		di as err "Allowed bs types are " as result "par" as text " or " as result "nonpar."
		exit 198
	}	
	if "`bs_type'" == "nonpar" {
        local bs_options_user `",`bs_options_user'"'
        if strmatch("`bs_options_user'", "saving(") {
            di as err "Bootstrap saving option not allowed."
            exit 198
        }
        local bs_opt_output "bs(`bs')" 

        local bs_opts_all : list bs_options_user | bs_options_default
    }
    else if "`bs_options_user'" != "" {
            di as err "Bootstrap options not allowed with parametric bootstrap."
            exit 198
    }
	else local bs_opt_output "bs(`bs_type')" 
}

if "`pref'" != "" {
	gettoken prefb prefse : pref 
		if wordcount("`prefse'") != 1 {
		di as err "Invalid preferred option.  Please enter one coefficient estimate and one standard error estimate."
		exit 198
	}
}

return local threshold = `sample'/100
return local sizemin = `sizemin'
return local sizemax = `sizemax'
return local bs_type `"`bs_type'"'
return local bs_options_user `"`bs_options_user'"'
return local bs_opts_all `"`bs_opts_all'"'
return local prefb `"`prefb'"'
return local prefse `"`prefse'"'
return local alpha = `alpha'
local opts_mrobust `"`sample_option' `size_opt_output' `bs_opt_output' `alpha_opt_output'"'
return local opts_mrobust : list retok opts_mrobust
end

/*
Parse out the list of control terms.  
The user can enter 2 layers of grouped variables including either/or options.
The outermost layer of grouped terms is called a Set. 
ex. Set 1 = ( (x1 (x2 | x3 )) | (x4 x5 ) )  
Sets are split up into SetX by the either/or symbol "|".
Only one SetX of each Set may appear in any given model.
ex. Set 1, SetX 1 = (x1 (x2 | x3 ))
    Set 1, SetX 2 =  (x4 x5 )  
SetX are split up into Terms by parentheses.
Each SetX contains one or more Terms.  Given that a SetX appears in the model,
all of the terms of the SetX must appear in that model.
ex. Set 1, SetX1, Term 1 = x1
    Set 1, SetX1, Term 2 = x2 | x3
    Set 1, SetX2, Term 1 = x4 x5
Terms are split up into TermX by the either/or symbol "|".
Only one TermX of each Term may appear in any given model.
ex. Set 1, SetX1, Term 1, TermX 1 = x1
ex. Set 1, SetX1, Term 2, TermX 1 = x2 
    Set 1, SetX1, Term 2, TermX 1 = x3
    Set 1, SetX2, Term 1, TermX 1 = x4 x5

ParseVarlist returns the following local macros:
s`i'NSX = number of SetX in Set i
s`i'sx`j'NT = number of Terms in Set i, SetX j
s`i'sx`j't`k'NTX = number of TermX in Set i, SetX j, Term k
s`i'sx`j't`k'tx`m' = the variable names that compose Set i, SetX j, Term k, TermX m
nSets = total number of Sets (including dependent var set (#1) and interest var set (#2))
n_var_combinations = total number of variable combinations meeting the 
	user's grouping and either/or criteria
allvarnames = list of all of the variable names
allvarnames_clean = list of all the variable names,
	with dependent and interest variables preceded by "__" and rotated variable
	names preceded by "r_" any extraneous characters e.g. "." converted to "_"
always_in_varnames = list of all the always in variable names
b_always_in_clean = list of all the always in variable names precede by "b_"
	with any extraneous characters e.g. "." converted to "_"
intvarlist = variable(s) of interest name(s), separated by | 
depvarlist = dependent variable(s) name(s), separated by |

If the display_only option is specified, ParseVarlist returns nothing.
*/
program ParseVarlist, rclass
return add
syntax anything (name = varlist_input) [ , display_only]
local nSets 0
local depvarlist ""
local intvarlist ""
local allvarnames ""
local allvarnames_clean ""
local always_in_varnames ""
local b_always_in_clean ""
mata:  mrobust_varnames = asarray_create()
while `"`:list retok varlist_input'"' != "" {
	//Isolate the first grouped set of the varlist
	gettoken set varlist_input : varlist_input, bind match(par)
	if "`par'" == "" {
		if !strmatch("`set'", "*.*") unab set : `set'
		if `:word count `set'' != 1 {
			gettoken set rest : set
			local varlist_input `"`rest' `varlist_input'"'
		}
	}
	local ++nSets
	local nsx 1
	while `"`:list retok set'"' != "" {
		//Build up setx by getting tokens until you reach | or the end of the set
		local setx ""
		gettoken setx0 set : set,  bind  parse(" |") 
		while `"`setx0'"' != "|" & `"`setx0'"' != "" {
			local setx `"`setx' `setx0'"'
			gettoken setx0 set : set, bind  parse(" |") 
		}
		local nt 0
		while `"`:list retok setx'"' != "" {
			gettoken term setx : setx, bind match(par) 
			local ++nt
			local ntx 1
			while `"`:list retok term'"' != "" {
				//There should be no more parentheses within the term so no need for bind option
				gettoken termx0 term : term, parse("|")  
				if "`termx0'" == "|" {
					local ++ntx
				}
				else {
					local termx ""
					//Build up termx by getting tokens until the end of the term
					while `"`:list retok termx0'"' != "" {
						gettoken tk termx0 : termx0
						if !strmatch("`tk'", "*.*") unab tk : `tk'
						local termx "`termx' `tk'"
					}
						//Build the depvarlist:  Set #1, every setx, Term #1, Word 1
						if `nSets' == 1 {
							if `nt' == 1 {
								local depvar0 = word("`termx'", 1)
								CheckIfSingleVariable `depvar0'
								if "`r(IsSingleVariable)'" == "false" {
									di as err "dependent variable must be a single variable"
									exit 198
								}
								if  "`depvarlist'" != "" local depvarlist "`depvarlist' | `depvar0'"
								else local depvarlist `depvar0'
							}
							//Each setx of Set 1 should contain only 1 term = 1 dependent variable. 
							else {
								di as err "depvar must be a single variable."
								exit 198
							}
						}
						//Build the intvarlist :  Set #2, every setx, Term #1, Word 1
						if `nSets' == 2 & `nt' == 1 {
							local intvar0 = word("`termx'", 1)
							CheckIfSingleVariable `intvar0'
							if "`r(IsSingleVariable)'" == "false" {
								di as err "variable of interest must be a single variable"
								exit 198
							}
							if "`intvarlist'" != "" local intvarlist "`intvarlist' | `intvar0'"
							else local intvarlist `intvar0'
						}
		    			local s`nSets'sx`nsx't`nt'tx`ntx' `termx'
		    			local allvarnames "`allvarnames' `termx'"
		    			foreach varname of local termx {
				 			local varname_clean = strtoname("`varname'")
				 			if `nSets' == 2  {
				 				local always_in_varnames `"`always_in_varnames' `varname'"'
				 				local b_always_in_clean `"`b_always_in_clean' b_`varname_clean'"'
				 			}
				 			if `nSets' > 2 local varname_clean = `"r_`varname_clean'"'
				 			else local varname_clean `"__`varname_clean'"'
				 			local allvarnames_clean `"`allvarnames_clean' `varname_clean'"'
				 			mata:  asarray(mrobust_varnames, "`varname_clean'", "`varname'")
						 }
		
					}			
				}
				//done parsing term:  Record # of termx  
				local s`nSets'sx`nsx't`nt'NTX `ntx'
			}
			//done parsing setx:  Record # of term
			local s`nSets'sx`nsx'NT `nt'
			if "`setx0'" == "|" {
				local ++nsx
			} 
		}
		//done parsing set:  Record # of setx
		local s`nSets'NSX `nsx'
	}


if "`display_only'" != "display_only" {
forvalues is = 1/`nSets' {
	return local s`is'NSX = `s`is'NSX'
	forvalues isx = 1/`s`is'NSX' {
		return local s`is'sx`isx'NT = `s`is'sx`isx'NT'
		forvalues it = 1/`s`is'sx`isx'NT' {
			return local s`is'sx`isx't`it'NTX = `s`is'sx`isx't`it'NTX'
			forvalues itx = 1/`s`is'sx`isx't`it'NTX' {
				 return local s`is'sx`isx't`it'tx`itx' `"`s`is'sx`isx't`it'tx`itx''"'
				 //local TermX_varnames "`s`is'sx`isx't`it'tx`itx''"
				 //local allvarnames "`allvarnames' `TermX_varnames'"
				
			}
		}
	}	
}
local duplicates : list dups allvarnames
if "`duplicates'" != "" {
	di as err "Duplicate variables:  `duplicates'"
	di as err "Please enter each independent variable only once."
	exit 198
}

local n_var_combinations 1
local nmodels 1
forvalues is = 1/`nSets' {
	local n_combos_this_Set 0
	forvalues isx = 1/`s`is'NSX' {
		local n_combos_this_SetX 1
		forvalues nt = 1/`s`is'sx`isx'NT' {
			local n_combos_this_SetX = `n_combos_this_SetX' * `s`is'sx`isx't`nt'NTX'
		}
		local n_combos_this_Set = `n_combos_this_Set' + `n_combos_this_SetX'	
	}
	if `is' > 2 local ++n_combos_this_Set
	local n_var_combinations = `n_var_combinations' * `n_combos_this_Set'
}

return local nSets `nSets'
return local n_var_combinations `n_var_combinations'
return local allvarnames `"`allvarnames'"'
return local allvarnames_clean `"`allvarnames_clean'"'
return local b_always_in_clean `"`b_always_in_clean'"'
return local always_in_varnames `"`always_in_varnames'"'
return local intvarlist `"`intvarlist'"'
return local depvarlist `"`depvarlist'"'
}	
end
/*
Check the input of time-series operators to determine whether the name indicates one or
more variables
*/
program CheckIfSingleVariable, rclass
	return add
	if strmatch("`0'", "*.*") & regexm("`0'","^([LlDdSsFf]+[0-9LlDdSsFf]*\.[^.]+)$") == 0 {
		return local IsSingleVariable false
	}
	else return local IsSingleVariable true
end

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
	if `curr_length' == wordcount("`setlist'") {
		local ++count_Xlists
		return local count_Xlists `count_Xlists'
		return local `unit'Xlist`count_Xlists' `setXlist'	
	}
	else {
		local ++curr_length
		local curr_set = word("`setlist'", `curr_length')
		local nSX_this_set = word("`nSX_by_Set'", `curr_length')
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
/*
Use the saved results file to calculate the summary statistics.
*/
program CalcSummaryStats, rclass
syntax [, saveas(string) replace]
local model_namelist `"`r(model)'"'
local model_idlist `"`r(model_idlist)'"'
local nmodeltypes = wordcount("`model_namelist'") 
local depvarlist `"`r(depvar)'"'
local intvarlist `"`r(intvar)'"'
local intvarlist_noline = subinstr("`intvarlist'", "|"," ",.)
local nintvar = wordcount("`intvarlist_noline'")
local depvarlist_noline = subinstr("`depvarlist'", "|", " ", .)
local ndepvar = wordcount("`depvarlist_noline'")
local bs_type `"`r(bs_type)'"'
local bs_opts `"`r(bs_opts)'"'
local nterms `"`r(nterms)'"'
local N `"`r(N)'"'
local nmodels `"`r(nmodels)'"'
local prefb `"`r(prefb)'"'
local prefse `"`r(prefse)'"'
local alpha `"`r(alpha)'"'
local opts_command `"`r(opts_command)'"'
local odds_ratio = r(odds_ratio)
forvalues im = 1/`nmodeltypes' {
	local model`im'_name `"`r(model`im'_name)'"'
	local model`im'_opts `"`r(model`im'_opts)'"'
	
}
return add

local results_to_return totalParLB totalParUB extremeLB extremeUB modeling95LB modeling95UB  ///
p1 p5 p10 p90 p95 p99 kurtosis skew  ///
 rratio totalSE samplingSE modelingSE meanb meanr2 
if "`bs_type'" != "" local results_to_return  total95LB total95UB `results_to_return'
if "`prefb'" != "" local results_to_return prefLB prefUB prefpctile preftotalSE `results_to_return'
tempname `results_to_return'

//Summarize the point estimates:  modeling distribution
quietly sum b_intvar if i_bs == 1, detail
scalar `meanb' = r(mean)
scalar `modelingSE' = r(sd)
scalar `extremeLB' = r(min)
scalar `extremeUB' = r(max)
local percentiles 1 5 10 90 95 99
foreach pct of local percentiles {
	scalar `p`pct'' = r(p`pct')
}
scalar `skew' = r(skewness)
scalar `kurtosis' = r(kurtosis)
quietly centile b_intvar if i_bs == 1, centile(2.5 97.5)
scalar `modeling95LB' = r(c_1)
scalar `modeling95UB' = r(c_2)
quietly summarize r2 if i_bs == 1
scalar `meanr2' = r(mean)
quietly summarize variance if i_bs == 1, meanonly
scalar `samplingSE' = sqrt(r(mean))

if "`bs_type'" != "" {
	quietly summarize b_bs
	scalar `totalSE' = r(sd)
	quietly centile b_bs, centile(2.5 97.5)
	scalar 	`total95LB' = r(c_1)
	scalar 	`total95UB' = r(c_2)
}
else scalar `totalSE' = sqrt(`modelingSE'^2 + `samplingSE'^2)
scalar `rratio' = `meanb'/`totalSE'
scalar `totalParLB' = `meanb' - 2*`totalSE'
scalar `totalParUB' = `meanb' + 2*`totalSE' 

/*
Calculate statistics for preferred estimate:  percentile of modeling distribution,
total standard error (= sqrt of sum of squares of preferred SE and modeling SE),
semi-parametric confidence interval 
*/
if "`prefb'" != "" {
	if `odds_ratio' == 1 local prefb = log(`prefb')
	quietly count if b_intvar <= `prefb' & i_bs == 1
	scalar `prefpctile' = 100 * (r(N)/`nmodels')
	if `prefpctile' == 0 | `prefpctile' >= 100 scalar `prefpctile' = .
	scalar `preftotalSE' = sqrt(`prefse'^2 + `modelingSE'^2)
	scalar `prefLB' = `prefb' - 2*`preftotalSE'
	scalar `prefUB' = `prefb' + 2*`preftotalSE'
}

GenerateSigRatesMatrix, model_namelist("`model_idlist'") depvarlist("`depvarlist_noline'") intvarlist("`intvarlist_noline'") alpha(`alpha')
return add
GenerateInfStatsMatrix, modellist("`model_idlist'") depvarlist("`depvarlist_noline'") intvarlist("`intvarlist_noline'") 
return add
generate se = sqrt(variance)
drop variance
	quietly replace b_intvar= exp(b_intvar)  if odds_ratio_ind == 1
	quietly replace se = b_intvar*se if odds_ratio_ind == 1
	quietly count if odds_ratio_ind == 0
	if r(N) == 0 {
		local to_exp meanb  totalParLB totalParUB modeling95LB modeling95UB extremeLB extremeUB 
		if "`bs_type'" != "" local to_exp `"`to_exp' total95LB total95UB "'
		if "`prefb'" != "" local to_exp `"`to_exp' prefLB prefUB"'
		foreach t of local to_exp {
			scalar ``t'' = exp(``t'')
		}
		local to_multiply samplingSE modelingSE totalSE
		foreach t of local to_multiply {
			scalar ``t'' = `meanb'*``t''
		}
	}

if "`bs_type'" == "" {
	//quietly drop if i_bs != 1
	quietly drop i_model i_bs 
}


if `"`saveas'"' != "" quietly save `"`saveas'"' , `replace'
return local saveas `"`saveas'"'
//Return the regression type for display
local reg_type ""
forvalues im = 1/`nmodeltypes' {
	local m = "`model`im'_name'"
	if `im' > 1 local reg_type "`reg_type'/"
	if ("`m'" == "logit") local reg_type "`reg_type'Logit"
	else if ("`m'" == "logistic") local reg_type "`reg_type'Logistic"
	else if ("`m'" == "probit") local reg_type "`reg_type'Probit"
	else if ("`m'" == "poisson") local reg_type "`reg_type'Poisson"
	else if ("`m'" == "nbreg") local reg_type "`reg_type'Negative Binomial"
	else if ("`m'" == "areg") local reg_type "`reg_type'Absorbing"
	else if ("`m'" == "rreg") local reg_type "`reg_type'Robust"
	else if ("`m'" == "xtreg") {
		local m_opts = `"`opts_command' `opts`im'' "'
		local fe fe 
		local be be 
		if `: list fe in m_opts' == 1 local reg_type "`reg_type'Fixed-effects (within)"
		else if `: list be in m_opts' == 1 local reg_type "`reg_type'Between (group means)"
		else local reg_type "`reg_type'Random-effects GLS"
	}
	else local reg_type "`reg_type'Linear"
}

local reg_type "`reg_type' regression"
local reg_type : list retok reg_type
return local title `"`reg_type'"'
foreach r of local results_to_return {
	return scalar `r' = ``r''
}

end

/*
GenerateSigRatesMatrix calculates the rates of significant and 
positive coefficients for each functional form, depvar, and intvar, as well as 
the pooled rates, stores these numbers in the matrix sigrates and returns the
matrix sigrates.
*/
program GenerateSigRatesMatrix, rclass
syntax , model_namelist(string) depvarlist(string) intvarlist(string) alpha(real)
//Create sigrates matrix
local lists model_namelist depvarlist intvarlist
local ncols 0
local colnames "all_models"
foreach l of local lists {
if wordcount(`"``l''"') > 1 { 
	foreach entry of local `l' {
		local colnames `colnames' `entry'
		local ++ncols 
	}
}
}
local ++ncols
local rownames NModels SignStability SignificanceRate Positive PositiveandSig Negative NegativeandSig
local nrows = wordcount("`rownames'")
matrix sigrates = J(`nrows', `ncols', 0)
matrix colnames sigrates = `colnames'
matrix rownames sigrates = `rownames' 
local i_row = 0
foreach rowname of local rownames {
	local ++i_row
	local `rowname' = `i_row'
}
//Calculate significance rates and store in matrix sigrates
forvalues i_col = 1/`ncols' {
	local curr_colname = word("`colnames'", `i_col')
	if `:list curr_colname in model_namelist' == 1 local type model
	else if `:list curr_colname in depvarlist' == 1 local type depvar
	else local type intvar
	local ifcond ""
	if `i_col' > 1 local ifcond `"& `type' == "`curr_colname'""'
    quietly count if i_bs == 1 `ifcond' 
	local curr_nmodels = r(N)
	matrix sigrates[`NModels', `i_col'] = `curr_nmodels'
	quietly count if pvalue <= `alpha'  & i_bs == 1 `ifcond'
	matrix sigrates[`SignificanceRate', `i_col'] = 100*(r(N)/`curr_nmodels')	    
	quietly count if b_intvar> 0 & i_bs == 1 `ifcond'
	matrix sigrates[`Positive',`i_col'] = 100*(r(N)/`curr_nmodels')		
	quietly count if b_intvar> 0 & pvalue <= `alpha' & i_bs == 1 `ifcond'
	matrix sigrates[`PositiveandSig',`i_col'] = 100*(r(N)/`curr_nmodels')
	quietly count if b_intvar< 0 & i_bs == 1`ifcond'
	matrix sigrates[`Negative', `i_col'] = 100*(r(N)/`curr_nmodels')
	quietly count if b_intvar < 0 & pvalue <= `alpha' & i_bs == 1 `ifcond'
	matrix sigrates[`NegativeandSig',`i_col'] = 100*(r(N)/`curr_nmodels')
	matrix sigrates[`SignStability',`i_col'] = max(sigrates[`Positive',`i_col'], sigrates[`Negative', `i_col'])
}
return matrix sigrates = sigrates
end

/*
GenerateInfStatsMatrix 
*/
program GenerateInfStatsMatrix, rclass
syntax , modellist(string) depvarlist(string) intvarlist(string) 

quietly sum b_intvar if i_bs == 1
local meanb = r(mean)

/*Build the varlist for the influence regression, including the rotated control
variables and dummies for the functional form, depvar, and intvar.
*/
local inf_varnames ""
unab rotatedvars : r_*
local typelist model depvar intvar
foreach type of local typelist {
	local n`type' = wordcount("``type'list'")
	if `n`type'' > 1 {
		forvalues i = 2/`n`type'' {
			local curr = word("``type'list'", `i')
			quietly gen byte `curr' = (`type' == "`curr'")
			local inf_varnames `"`inf_varnames' `curr'"'
		}
	}
}
local inf_varnames `"`inf_varnames' `rotatedvars'"'

/*
Run the regression for the marginal effect of variable inclusion
on the estimate.  Store results.
*/
quietly reg b_intvar `inf_varnames' if i_bs == 1
return scalar infr2_b = e(r2)
return scalar infcons_b = _b[_cons]
local ngroups = e(df_m)

/*
Create the 2 matrices:  infstats_default, which stores the coefficients from the 
OLS influence regression, indicating the effect of inclusion of each variable
or functional form on the magnitude of the estimate, and infstats_sig_only, which 
stores the odds ratios from the logistic influence regression, indicating the
effect of inclusion of each variable or functional form on the
likelihood of a positive or significant estimate.
*/
tempname infstats_default infstats_sig_only
local colnames_default abs_coef coef pct_chg row_id
local colnames_sig_only abs_coef_sig coef_sig coef_pos row_id_sig
local ncols_default = wordcount("`colnames_default'") 
local ncols_sig_only = wordcount("`colnames_sig_only'") 
matrix `infstats_default' = J(`ngroups', `ncols_default', 0)
matrix `infstats_sig_only' = J(`ngroups', `ncols_sig_only', 0)
local groupleads ""

/*If the term has meaningful influence coefficient then add it to the matrix.
otherwise, check which variable it is grouped with and it to that group
*/
local lists colnames_default colnames_sig_only
foreach namelist of local lists {
	local i_row 0
	foreach name of local `namelist' {
		local ++i_row
		local `name' = `i_row'

	}
}
local i_row 0
foreach var of local inf_varnames {
	if _se[`var'] != 0 {
	local ++i_row
		local groupleads `"`groupleads' `var'"'
		local group_`var' ""
		matrix `infstats_default'[`i_row',`abs_coef'] = abs(_b[`var'])
		matrix `infstats_default'[`i_row',`coef'] = _b[`var']
		matrix `infstats_default'[`i_row',`pct_chg'] = 100*(_b[`var']/`meanb')
		matrix `infstats_default'[`i_row',`row_id'] = `i_row'
	}
	else {
	foreach groupvar of local groupleads {
		quietly count if `var' != `groupvar'
		if r(N) == 0  {
			mata:  st_local("displayname", asarray(mrobust_varnames, "`var'"))
			local group_`groupvar' `"`group_`groupvar'' `displayname'"'
			continue, break
		}
	}
	}
}
/*
Run the regressions for marginal effect of variable inclusion
on the probability of significant or positive estimate.  
Store results in the matrix. 
*/
local dummies sig pos
foreach d of local dummies {
		capture reg `d' `inf_varnames' if i_bs == 1
		if _rc == 0 {
			local i_row 0
			foreach var of local groupleads {
				local ++i_row
				matrix `infstats_sig_only'[`i_row', `coef_`d''] = _b[`var']
				if "`d'" == "sig" {
					matrix `infstats_sig_only'[`i_row', `abs_coef_sig'] = abs(`infstats_sig_only'[`i_row', `coef_sig'])
					matrix `infstats_sig_only'[`i_row',`row_id_sig'] = `i_row'
				}
			}
			return scalar infr2_`d' = e(r2)
			return scalar infcons_`d' = _b[_cons]
		}
		return scalar `d'_rc = _rc
}
/*
Sort the rows of each infstats matrix in descending order of absolute value of the
influence coefficient.  Iterate through the sorted row_ids and attach the rownames to matrices 
in the proper order
*/	
local tosort default sig_only
local sortcol = -1
foreach t of local tosort {
	mata:  st_matrix("`infstats_`t''", sort(st_matrix("`infstats_`t''"), `sortcol'))
	local groupleads_sorted ""
	forvalues i_row = 1/`ngroups' {
		local nextgroup = word("`groupleads'", `infstats_`t''[`i_row', `ncols_`t''])
		local groupleads_sorted `"`groupleads_sorted' `nextgroup'"'
	}
	matrix rownames `infstats_`t'' = `groupleads_sorted'
	matrix colnames `infstats_`t'' = `colnames_`t''
	return matrix infstats_`t' = `infstats_`t''
}
foreach var of local groupleads {
	return local group_`var' `"`group_`var''"'
}
end
/*
Display Results
*/
program DisplayResults, rclass
syntax , time_taken(real) [ more full sig_only intervals influence saveas(string)]
local prefb `"`r(prefb)'"'
local model_namelist `"`r(model)'"'
local model_idlist `"`r(model_idlist)'"'
local depvarlist `"`r(depvar)'"'
local intvarlist `"`r(intvar)'"'
local nmodeltypes `"`r(nmodeltypes)'"'
local bs_type `"`r(bs_type)'"'
tempname sigrates
matrix `sigrates' = r(sigrates)
local ncols = colsof(`sigrates')
local nrows = rowsof(`sigrates')
di _newline _continue
if "`sig_only'" == "sig_only"  {
	local results_col 29
	di as text `"`r(title)'"' ";"
	di as text "Variable of interest " _col(`results_col') as result r(intvar) 
	di as text "Outcome variable  " _col(`results_col') as result r(depvar)	
	di as text "Possible control terms   " _col(`results_col') as result r(nterms)
	di as text "Number of models" _col(`results_col') as result %-15.0fc r(nmodels)
	di as text "Number of observations"  _col(`results_col') as result %-15.0fc r(N)
	di as text "{hline 35}"
}
if "`sig_only'" == "sig_only" | "`more'" == "more" {
	di as text "Significance Testing:"
	di _newline _continue
	local colstart 14
	local colinterval 13
	local line_length = round(`colstart' + (`ncols'+1) *`colinterval' )

	if `ncols' > 1 {
		di _continue as text "Estimation Command:  "
		local cnames : colfullnames `sigrates'
		local ic 0
		foreach c of local cnames {
			local ++ic
			if "`c'" == "all_models" local c all models
			local display_colname `"`c'"'
			if `: list c in model_idlist' {
				MakeDisplayModelID `c'
				local display_colname `"`r(display_name)'"'
			}		
			if `ic' == `ncols' local cont ""
			else local cont "_continue"
			local col_indent = `colstart' + `ic'*`colinterval'
			di `cont' as text _col(`col_indent') %12s abbrev("`display_colname'", 12)
		}
		di _continue as text "Number of Models:  "
		local colstart 20
		forvalues ic = 1/`ncols' {
			if `ic' == `ncols' local cont ""
			else local cont "_continue"
			local col_indent = `colstart'  + `ic'*`colinterval'
		    di `cont' as text _col(`col_indent') %5.0f `sigrates'[1,`ic'] 
		}
		di as text "{hline `line_length'}"	
	}
	local title2 "Sign Stability"
	local title3 "Significance Rate"
	local title4 "Positive"
	local title5 "Positive and Sig"
	local title6 "Negative"
	local title7 "Negative and Sig"
	
	 forvalues ir = 2/`nrows' {
		local colstart 20
		local pctsign "%"
		local asres "as result"
		if `ir' == 4 di as text "{hline `line_length'}"
		di _continue as text "`title`ir''"
		forvalues ic = 1/`ncols' {
			if `ic' == `ncols' local cont ""
			else local cont "_continue"
			local col_indent = `colstart'  + `ic'*`colinterval'
		    di `cont' as text _col(`col_indent') as result %5.0f `sigrates'[`ir',`ic'] "%"
		}
	}
	di as text "{hline `line_length'}"

}
/*
Display all of the coefficient summary statistics
*/
else if "`full'" == "full" {
	di as text `"`r(title)'"' ";"
	di as text "Variable of interest " _col(29) as result r(intvar) 
	di as text "Outcome variable  " _col(29) as result abbrev(r(depvar), 15)	_col(46) as text "Number of observations"  _col(70) as result %9.0f r(N)
	di as text "Possible control terms   " _col(29) as result r(nterms)  _col(46) as text "Mean R-squared"  _col(70) as result %9.2f r(meanr2)
	di as text "Number of models" _col(29) as result %-15.0fc r(nmodels) _col(46) as text "Multicollinearity"  _col(70) as result %9.2f r(mc)
	di as text "{hline 79}"
	di "Model Robustness Statistics:"  _col(46) "Significance Testing:"
	di _newline as text "Mean(b)" _col(19) as result %9.4f r(meanb) _col(46) as text "Sign Stability" _col (70) as result %9.0f `sigrates'[2,`ncols'] "%"
	di as text "Sampling SE" _col(19) as result %9.4f r(samplingSE) _col(46) as text "Significance rate"  _col (70) as result  %9.0f `sigrates'[3,`ncols'] "%"
	di as text "Modeling SE" _col(19) as result %9.4f r(modelingSE) _col(46) as text "{hline 34}"
	di as text "Total SE" _col(19) as result %9.4f r(totalSE)  _col(46) as text "Positive"  _col (70) as result %9.0f `sigrates'[4,`ncols'] "%"
	di as text "{hline 30}" _col(46) "Positive and Sig" _col (70) as result %9.0f `sigrates'[5,`ncols'] "%"
	di as text "Robustness Ratio:" _col(19) as result %9.4f r(rratio) _col(46) as text "Negative"  _col (70) as result %9.0f `sigrates'[6,`ncols'] "%"
	di as text _col(46) as text  "Negative and Sig" _col (70) as result  %9.0f `sigrates'[7,`ncols'] "%"
	di as text "{hline 79}"
	if "`prefb'" != "" {
		di as text "Statistics for Preferred Estimate:"
		di _continue as text "Pref. est." _col(19) as result %9.4f r(prefb) 
	    di _col(41) as text "Percentile of modeling dist." _col(19) as result %5.0f r(prefpctile) as text "%" 
		di as text "Sampling SE" _col(19) as result %9.4f r(prefse)
		di as text "Modeling SE" _col(19) as result %9.4f r(modelingSE)
		di as text "Total SE" _col(19) as result %9.4f r(preftotalSE)
		/*if "`model'" != "logistic" & "`irr'" != "irr" {
			di as text "Robustness Int." _col(21) "[" as result %-8.4f r(prefLB) as text "," ///
			as result %8.4f r(prefUB) as text "]"
		}
		*/
		di as text "{hline 79}"
	}
}

if "`influence'" != "noinfluence" & "`more'" != "more" {
	tempname infstats
	if "`sig_only'" == "sig_only" {
		di as text "Model Influence" _col(25) "{ul:Significance Regression}" _col(55) "{ul:Sign Regression}"
		matrix `infstats' = r(infstats_sig_only)
		di as text _col(29) "Marginal Effect" _col(55) "Marginal Effect"
		di as text _col(22) "on Significance Probability" _col(51) "on Positive Probability"
	
		local fmt_col2 "%9.4f" 
		
	}
	else {
		di as text "Model Influence"
		matrix `infstats' = r(infstats_default)
		di as text _col(29) "Marginal Effect" _col(55) "Percent Change"
		di as text _col(26) "of Variable Inclusion" _col(56) "From Mean(b)"
		local fmt_col2 "%9.1f"
	}
	local col1 2
	local col2 3
	local infvars : rownames `infstats'
	local iv 0
	foreach infvar of local infvars {
		local ++iv
		if strmatch("`infvar'", "r_*") mata:  st_local("di`infvar'", asarray(mrobust_varnames, "`infvar'"))
		else if `: list infvar in model_idlist' {
			MakeDisplayModelID `infvar'
			local di`infvar' "model:  `r(display_name)'"
		}
		else if `: list infvar in depvarlist' local di`infvar' "depvar: `infvar'"
		else local di`infvar' "intvar: `infvar'"
		if "`sig_only'" == "sig_only" {
			di _continue as text abbrev("`di`infvar''", 20) _col(29) as result %9.2f `infstats'[`iv', `col1'] 
			di _col(55) as result %9.2f `infstats'[`iv',`col2'] as text
		}
		else {
			di _continue as text abbrev("`di`infvar''", 20) _col(29) as result %9.4f `infstats'[`iv', `col1'] 
			di _col(55) as result %9.1f `infstats'[`iv',`col2'] as text "%"
		}
		local group_`infvar' `"`r(group_`infvar')'"'
		if "`group_`infvar''" != "" {
			foreach member of local group_`infvar' {
				mata:  st_local("di`infvar'", asarray(mrobust_varnames, "`infvar'"))
				di as text abbrev("`member'", 20) _col(30) "(Grouped with " abbrev("`di`infvar''", 20) ")"
			}
		}
	}
	di _newline _continue 
	if "`sig_only'" == "sig_only" {
	    di as text "Constant" _col(29) as result %9.4f r(infcons_sig) _col(55) as result %9.4f r(infcons_pos)
		di as text "R-squared" _col(29) as result %9.4f r(infr2_sig) _col(55) as result %9.4f r(infr2_pos)
	}
	else {
		di as text "Constant" _col(29) as result %9.4f r(infcons_b)
		di as text "R-squared" _col(29) as result %9.4f r(infr2_b)
	}
	if "`sig_only'" == "sig_only" {
		if r(pos_rc) != 0 di as text "note: insufficient variation in sign for logistic regression" 
		if r(sig_rc) != 0 di as text "note: insufficient variation in significance for logistic regression"
	}
	if `nmodeltypes' > 1  {
		local refmodel = word("`model_idlist'", 1)
		MakeDisplayModelID `refmodel'
		local refmodel `"`r(display_name)'"'
		di as text "note: `refmodel' is the reference model." 
	} 
	if wordcount("`intvarlist'") > 1 di as text "note: " word("`intvarlist'", 1) " is the reference interest variable."
	if wordcount("`depvarlist'") > 1 di as text "note: " word("`depvarlist'", 1) " is the reference dependent variable."
		di as text "{hline 79}"
}

if "`more'" != "more" {
if "`intervals'" != "" & "`sig_only'" == "sig_only" di "note:  intervals option not allowed with sig_only."
else if "`intervals'" != "" | "`bs_type'" != "" {
	di as text "Robustness Intervals:" 
	di _newline as text "Modeling 95%" _col(29) "[" as result %-8.3f r(modeling95LB) as text "," ///
	as result %8.3f r(modeling95UB) as text "]"		
	di as text "Modeling Extreme Bounds"  _col(29) "[" as result %-8.3f r(extremeLB) as text "," ///
	as result %8.3f r(extremeUB) as text "]"
	di as text "Total Parametric" _col(29) "[" as result %-8.3f r(totalParLB) as text "," as result %8.3f r(totalParUB) as text "]"
	di as text "Total 95%" _col(29) "[" as result %-8.3f r(total95LB) as text "," as result %8.3f r(total95UB) as text "]"
	
}



if `time_taken' > 120 {
	local ndigits = ceil(log10(`time_taken'/60)) + 3
	di _newline as text "This command took " as result %-`ndigits'.0fc round(`time_taken'/60, 1)  as text " minutes (" as result round(`time_taken'/3600, .1) as text " hours) to complete."
}
else di _newline as text "This command took " as result round(`time_taken', .1) as text " seconds (" as result round(`time_taken'/60, .1) as text " minutes) to complete."
return scalar time_taken = `time_taken'
if `"`r(saveas)'"' != "" di as text "Model data saved in data file " r(saveas) "."
if `"`r(savelist)'"' != "" di as text "Model list saved in file " r(savelist) "."
local options_used `"`r(opts_command)' `r(opts_mrobust)'"'
if `nmodeltypes' > 1 {
	local opts_printed 0
	if `"`: list retok options_used'"' != "" {
		local opts_printed 1
		di as text "Options used:  `options_used'"
	}
	forvalues im = 1/`nmodeltypes' {
		if `"`r(opts`im')'"' != "" {
			if `opts_printed' == 0 	{
				di as text "Options used:"
				local opts_printed 1
			}
			MakeDisplayModelID `model`im'_id'
			di as text "`r(display_name)':  " r(model`im'_opts)
		}
	}
	if "`sig_only'" != "sig_only" & "`more'" != "more" {
		di as text "Type " as result "mrobust, more" as text " to see average results for each model type."
	}	
}
else {
	local options_used `"`options_used' `r(opts1)'"'
	if `"`: list retok options_used'"' != "" di as text "Options used:  `options_used'"
}
}
return add
end
/*
Translates model ids of the form "reg_1", "reg_2" etc. into "reg(1)", "reg(2)" etc. 
for display purposes.  
*/
program MakeDisplayModelID, rclass
return add
	syntax name (name = model_id)
	if regexm("`model_id'", "_[0-9]$") == 1 {
		local display_name = subinstr("`model_id'", "_", "(", .)
    	return local display_name `"`display_name')"'
    }
    else return local display_name `"`model_id'"'
end

/*
Plot the kdensity of the coefficient estimates according to user specifications.
*/
program PlotMRobust, rclass
syntax [,normal nozero plotbs bs(string)]
	local intvar `"`r(intvar)'"' 
	local prefb `"`r(prefb)'"'
	return add
	if "`bs'" == "" quietly sum b_intvar 
	else quietly sum b_intvar if i_bs == 1
	if "`rmal'" != "" local normal_opt || function normalden(x,`r(mean)',`r(sd)'), range(b_intvar)  legend(label(2 "normal density"))
	else local normal_opt "" 
	if "`zero'" != "" local zero_opt ""
	else local zero_opt xscale(range(0)) xlabel(#6)
	if "`prefb'" != "" local pref_opt xline(`prefb')
	else local pref_opt ""
	if "`plotbs'" != "" local kd_bs (kdensity b_bs)
    graph twoway `kd_bs' (kdensity b_intvar), xtitle("Coefficient on `intvar'") `normal_opt' `zero_opt' `pref_opt'


end

























