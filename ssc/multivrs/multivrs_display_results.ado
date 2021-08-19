/*
Display Results
*/
program multivrs_display_results, rclass
syntax , time_taken(real) [ more full sig_only intervals noinfluence saveas(string) listwise inf_means margins]

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
	if "`margins'" == "margins" di as text`"`r(title)'"' " (displaying marginal effects);"
	else di as text `"`r(title)'"' ";"
	if "`margins'" == "margins" di _continue " displaying marginal effects:"
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
	
	if "`margins'" == "margins" di as text`"`r(title)'"' " (displaying marginal effects);"
	else di as text `"`r(title)'"' ";"
	di as text "Variable of interest " _col(29) as result r(intvar)
	
	if `r(Nmin)' != `r(Nmax)' {
		local nmin_9 : display  %9.0fc `r(Nmin)'
		local nmax_9 : display  %9.0fc `r(Nmax)'
		local nmin : subinstr local nmin_9 " " "", all
		local nmax : subinstr local nmax_9 " " "", all
		local num_obs_range `nmin'-`nmax'
		local len_range : length local num_obs_range
		local num_obs_range_colstart = 79-`len_range'
		
		di as text "Outcome variable  " _col(29) as result abbrev(r(depvar), 15)	_col(46) as text "Num. observations"  _col(`num_obs_range_colstart') as result "`num_obs_range'" //as result %9.0f r(Nmin) as text "-" as result %9.0f r(Nmax)
	}
	else {
		di as text "Outcome variable  " _col(29) as result abbrev(r(depvar), 15)	_col(46) as text "Number of observations"  _col(70) as result %9.0fc r(N)
	}
	
	
	di as text "Possible control terms   " _col(29) as result r(nterms)  _col(46) as text "Mean R-squared"  _col(70) as result %9.2f r(meanr2)
	di as text "Number of models" _col(29) as result %-15.0fc r(nmodels) _col(46) as text "Multicollinearity"  _col(70) as result %9.2f r(mc)
	di as text "{hline 79}"
	di "Multiverse Statistics:"  _col(46) "Significance Testing:"
	di _newline as text "Mean(b)" _col(19) as result %9.4f r(meanb) _col(46) as text "Sign Stability" _col (70) as result %9.0f `sigrates'[2,1] "%"
	di as text "Sampling SE" _col(19) as result %9.4f r(samplingSE) _col(46) as text "Significance rate"  _col (70) as result  %9.0f `sigrates'[3,1] "%"
	di as text "Modeling SE" _col(19) as result %9.4f r(modelingSE) _col(46) as text "{hline 34}"
	di as text "Total SE" _col(19) as result %9.4f r(totalSE)  _col(46) as text "Positive"  _col (70) as result %9.0f `sigrates'[4,1] "%"
	di as text "{hline 30}" _col(46) "Positive and Sig" _col (70) as result %9.0f `sigrates'[5,1] "%"
	di as text "Robustness Ratio:" _col(19) as result %9.4f r(rratio) _col(46) as text "Negative"  _col (70) as result %9.0f `sigrates'[6,1] "%"
	di as text _col(46) as text  "Negative and Sig" _col (70) as result  %9.0f `sigrates'[7,1] "%"
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
		local inf_titles1 _col(29) "Marginal Effect" _col(55) "Percent Change"
		local inf_titles2  _col(26) "of Variable Inclusion" _col(56) "From Mean(b)"
		if "`inf_means'" == "inf_means" {
			local inf_titles1 `inf_titles1' _col(75) "Mean Estimate When"
			local inf_titles2 `inf_titles2'  _col(75) "Variable Included"
		}
		di as text `inf_titles1'
		di as text `inf_titles2'
		local fmt_col2 "%9.1f"
	}
	local col1 2
	local col2 3
	local col3 4
	local infvars : rownames `infstats'	
	
	local iv 0
	foreach infvar of local infvars {
		local ++iv		
		if regexm("`infvar'", "^__|^r_") mata:  st_local("di`infvar'", asarray(multivrs_varnames, "`infvar'"))
		else if `: list infvar in model_idlist' {
			MakeDisplayModelID `infvar'
			local di`infvar' "model:  `r(display_name)'"
		}
		else if `: list infvar in depvarlist' local di`infvar' "depvar: `infvar'"
		else if `: list infvar in intvarlist' local di`infvar' "intvar: `infvar'"
		else local di`infvar' "`infvar'"
		
		if "`sig_only'" == "sig_only" {
			di _continue as text abbrev("`di`infvar''", 20) _col(29) as result %9.2f `infstats'[`iv', `col1']
			di _col(55) as result %9.2f `infstats'[`iv',`col2'] as text
		}
		else {
			di _continue as text abbrev("`di`infvar''", 20) _col(29) as result %9.4f `infstats'[`iv', `col1']			
			if "`inf_means'" == "inf_means" {
				di _continue _col(55) as result %9.1f `infstats'[`iv',`col2'] as text "%"
				di _col(75) as result %9.4f `infstats'[`iv',`col3'] 
			} 
			else {
				di _col(55) as result %9.1f `infstats'[`iv',`col2'] as text "%"
			}
		}
		local group_`infvar' `"`r(group_`infvar')'"'
		if "`group_`infvar''" != "" {
			foreach member of local group_`infvar' {
				mata:  st_local("di`infvar'", asarray(multivrs_varnames, "`infvar'"))
				di as text abbrev("`member'", 20) _col(30) "(Grouped with " abbrev("`di`infvar''", 20) ")"
			}
		}
	}
	di _newline _continue
	
	local final_inf1 as text "Constant" _col(29) as result %9.4f
	local final_inf2 as text "R-squared" _col(29) as result %9.4f
	
	if "`sig_only'" == "sig_only" {
	    di  `final_inf1' r(infcons_sig) _col(55) as result %9.4f r(infcons_pos)
		di  `final_inf2' r(infr2_sig) _col(55) as result %9.4f r(infr2_pos)
	}
	else if "`inf_means'" == "inf_means" {	
	
		di `final_inf1' r(infcons_b) _col(75) as text "Overall Mean(b):" 
		di  `final_inf2' r(infr2_b) _col(75) as result %9.4f r(meanb)
	} 
	else {
		di  `final_inf1' r(infcons_b)
		di  `final_inf2' r(infr2_b)
	}
	if "`sig_only'" == "sig_only" {
		if r(pos_rc) != 0 di as text "note: insufficient variation in sign for logistic regression"
		if r(sig_rc) != 0 di as text "note: insufficient variation in significance for logistic regression"
	}
	if `nmodeltypes' > 1  {
		local refmodel : word 1 of `model_idlist'
		MakeDisplayModelID `refmodel'
		local refmodel `"`r(display_name)'"'
		di as text "note: `refmodel' is the reference model."
	}
	
	if `: word count `intvarlist'' > 1 di as text "note: `: word 1 of `intvarlist'' is the reference interest variable."
	if `: word count `depvarlist'' > 1 di as text "note: `: word 1 of `depvarlist'' is the reference dependent variable."
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
local options_used `"`r(opts_command)' `r(opts_multivrs)'"'
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
		di as text "Type " as result "multivrs, more" as text " to see sign and significance results for each model type."
	}
}
else {
	local options_used `"`options_used' `r(opts1)'"'
	if `"`: list retok options_used'"' != "" di as text "Options used:  `options_used'"
}
}


return add
end
// End program DisplayResults

/*
Translates model ids of the form "reg_1", "reg_2" etc. into "reg(1)", "reg(2)" etc.
for display purposes.
*/
program MakeDisplayModelID, rclass
return add
	syntax name (name = model_id)
	if regexm("`model_id'", "_[0-9]$") == 1 {
		local display_name : subinstr local model_id "_" "(", all		
    	return local display_name `"`display_name')"'
    }
    else return local display_name `"`model_id'"'
end
