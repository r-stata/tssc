/*
Use the saved results file to calculate the summary statistics.
*/
program multivrs_calc_summary_stats, rclass
syntax [,   saveas(string) replace noinfluencecalcs inf_means margins]
	local model_namelist `"`r(model)'"'
	local model_idlist `"`r(model_idlist)'"'
	local nmodeltypes : word count `model_namelist'
	local depvarlist `"`r(depvar)'"'
	local intvarlist `"`r(intvar)'"'
	local intvarlist_noline : subinstr local intvarlist "|" " ", all
	local nintvar : word count `intvarlist_noline'
	local depvarlist_noline : subinstr local depvarlist "|" " ", all
	local ndepvar : word count `depvarlist_noline'
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
	local weights `"`r(weights)'"'
	forvalues im = 1/`nmodeltypes' {
		local model`im'_name `"`r(model`im'_name)'"'
		local model`im'_opts `"`r(model`im'_opts)'"'

	}
	return add
	
	local results_to_return totalParLB totalParUB extremeLB extremeUB ///
	modeling95LB modeling95UB  ///
	p1 p5 p10 p90 p95 p99 kurtosis skewness  bic_r2_cor ///
	 rratio totalSE samplingSE modelingSE /*modelingSE_biased modelingSE_unbiased_check*/ meanb meanr2
	if "`bs_type'" != "" local results_to_return  total95LB total95UB `results_to_return'
	if "`prefb'" != "" local results_to_return prefLB prefUB prefpctile preftotalSE ///
		`results_to_return'
	tempname `results_to_return'

	qui gen model_id = _n
	qui generate se = sqrt(variance)
	qui gen s2 = se^2
	
	* CALCULATE INFLUENCE STATISTICS *
	if "`influencecalcs'" != "noinfluencecalcs" {

		GenerateInfStatsMatrix, modellist("`model_idlist'") depvarlist("`depvarlist_noline'") ///
			intvarlist("`intvarlist_noline'") `inf_means'
			
		matrix inf_coef = r(infstats_default)		
		return add
		

	}

	* CALCULATE WEIGHTS *
	/* if weight = "no" then don't calculate any of them, but if it's
	 a specific option (or it's not specified, the default equal weighting),
	 then go ahead and calculate all of them */

	if ("`weights'" == "no" | "`weights'" == "uniform") local weights_option ""
	else local weights_option "[aweight=wt_`weights']"
		
	if "`weights'" != "no" {

		if "`influencecalcs'" != "noinfluencecalcs" {

			* Influence Weights: Proportional to absolute value of influence regression coefficient. 
			* Note that the coefficients measure the effect of binary indicators for the presence 
			* of the specified variable in the model. So they're on the same scale. 			
			/*   Each rotated variable has a weight, and the model weight is the sum of 
			  the weights of the included variables. */
			local num = r(nterms)
			mata: st_matrix("inf_sums", colsum(st_matrix("inf_coef")))
			mata: st_matrix("weight_matrix", st_matrix("inf_coef")[,1]/st_matrix("inf_sums")[1,1])
			
			local names : rownames inf_coef
			matrix rownames weight_matrix = `names'
			
			* Sum the weights of variables included in the model to arrive at the raw model weight. 
			local n = 0
			foreach variable of local names {
				local ++n
				local weight = weight_matrix[`n',1]				
				qui gen wt_inf_`variable' = `variable'*`weight'
			}
			egen wt_inf_raw = rowtotal(wt_inf_*)
			
			* Divide by the sum of all raw model weights to calculate weights that sum to 1 (wt_inf).  
			qui sum wt_inf_raw if i_bs == 1
			gen wt_inf = wt_inf_raw/`r(sum)'			
			drop wt_inf_raw
		}

		* BIC Weights: Approximation to posterior probabilities. 
		/* Proportional to exp((-1/2)*BICdelta) where BICdelta is the difference between the model's BIC
			and the minimum BIC over all the models considered */
		qui sum bic if i_bs == 1
		qui gen bic_min = r(min)
		qui gen bic_delta = bic - bic_min if i_bs == 1
		qui gen wt_bic_raw = exp(-0.5*bic_delta) if i_bs == 1
		qui egen wt_bic_raw_total = total(wt_bic_raw) if i_bs == 1
		qui gen wt_bic = wt_bic_raw / wt_bic_raw_total

		* R2 Weights: Simply proportional to the R2 value. 
		qui sum r2 if i_bs == 1
		qui gen wt_r2_total = r(sum)
		qui gen wt_r2 = r2 / wt_r2_total

		drop bic_min bic_delta wt_bic_raw* wt_r2_total
	}
	
	* (weighted) SUMMARY OF POINT ESTIMATES: MODELING DISTRIBUTION
	quietly sum b_intvar `weights_option' if i_bs == 1, detail
	* Return list at this point is (weighted) summary of b_intvar.
	* The following calculations all rely on this summary. 
	
	* (weighted) MEAN & VARIANCE 
	scalar `meanb' = r(mean) 

	if ("`weights'" == "no" | "`weights'" == "uniform") {
		scalar `modelingSE' = r(sd)*sqrt((_N-1)/_N)
	}
	else {
		* Calculate unbiased (weighted) observed variance across estimates
		* from https://en.wikipedia.org/wiki/Weighted_arithmetic_mean#cite_note-3
		qui gen wt_dif2 = wt_`weights'*(b_intvar - r(mean))^2
		qui sum wt_`weights', meanonly
		local v1 = r(sum)
		qui gen wt_`weights'2 = wt_`weights'^2
		qui sum wt_`weights'2
		local v2 = r(sum)
		qui sum wt_dif2
		scalar `modelingSE' = sqrt(r(sum)/(`v1' - (`v2'/`v1')))
		drop wt_dif2 wt_`weights'2
	}
	
	quietly sum b_intvar `weights_option' if i_bs == 1, detail
	* (weighted) SKEW & KURTOSIS
	scalar `skewness' = r(skewness)  
	scalar `kurtosis' = r(kurtosis)
	
	* (unaffected by weights) MIN and MAX
	scalar `extremeLB' = r(min)
	scalar `extremeUB' = r(max)
	
	* (unweighted) PERCENTILES, including EMPIRICAL 95% INTERVAL
	local percentiles 1 2.5 5 10 90 95 97.5 99
	quietly centile b_intvar if i_bs == 1, centile(`percentiles')
	local npercentiles : word count `percentiles'
	forvalues i = 1/`npercentiles' {
		local p : word `i' of `percentiles'
		if `p' == 2.5 scalar `modeling95LB' = r(c_`i')
		else if `p' == 97.5  scalar `modeling95UB' = r(c_`i')
		else scalar `p`p'' = r(c_`i')
	}
	
	* (weighted) AVERAGE R2
	quietly summarize r2 `weights_option' if i_bs == 1
	scalar `meanr2' = r(mean)
	
	* (weighted) AVERAGE SAMPLING VARIANCE
	quietly sum variance `weights_option' if i_bs == 1, meanonly
	scalar `samplingSE' = sqrt(r(mean))

	* DERIVED SUMMARY STATISTICS
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

	* (unweighted) BIC, R2 CORRELATION
	qui sum bic if i_bs == 1
	if `r(N)' > 0 {
		capture cor bic r2 if i_bs == 1
		scalar `bic_r2_cor' = r(rho)
	}
	else {
		scalar `bic_r2_cor' = .
	}
	
	* STATISTICS FOR PREFERRED ESTIMATE
	/* percentile of modeling distribution,
	total standard error (= sqrt of sum of squares of preferred SE and modeling SE),
	semi-parametric confidence interval 
	
	Note: because the raw unweighted percentile is calculated here, it may be 
	inconsistent with the weighted percentiles calculated above */
	if "`prefb'" != "" {
		if `odds_ratio' == 1 local prefb = log(`prefb')
		quietly count if b_intvar <= `prefb' & i_bs == 1
		scalar `prefpctile' = 100 * (r(N)/`nmodels')
		if `prefpctile' == 0 | `prefpctile' >= 100 scalar `prefpctile' = .
		scalar `preftotalSE' = sqrt(`prefse'^2 + `modelingSE'^2)
		scalar `prefLB' = `prefb' - 2*`preftotalSE'
		scalar `prefUB' = `prefb' + 2*`preftotalSE'
		scalar `rratio' = `prefb'/`preftotalSE'
	}
	GenerateSigRatesMatrix, model_namelist("`model_idlist'") depvarlist("`depvarlist_noline'") ///
		intvarlist("`intvarlist_noline'") alpha(`alpha') 
	return add

	drop variance


	// Case: everything uses the odds ratio (not log-OR coefficient) -->
	// Exponentiate the relevant values and multiply the SEs
	// See https://www.stata.com/manuals/rlogistic.pdf
	quietly replace b_intvar= exp(b_intvar)  if odds_ratio_ind == 1 & "`margins'" != "margins" 
	quietly replace se = b_intvar*se if odds_ratio_ind == 1 & "`margins'" != "margins" 
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


// End program CalcSummaryStats

/*
GenerateInfStatsMatrix
*/
program GenerateInfStatsMatrix, rclass
syntax , modellist(string) depvarlist(string) intvarlist(string) [inf_means]

	

	quietly sum b_intvar if i_bs == 1
	local meanb = r(mean)

	/*Build the varlist for the influence regression, including the rotated control
	variables and dummies for the functional form, depvar, and intvar.
	*/
	local inf_varnames ""
	local inf_references ""
	local groupleads ""
	
	capture unab rotatedvars : r_*
	local typelist model depvar intvar
	foreach type of local typelist {
		local n`type' : word count ``type'list'
		if `n`type'' > 1 {
			forvalues i = 1/`n`type'' {
				pause
				local curr : word `i' of ``type'list'
				quietly gen byte `curr' = (`type' == "`curr'")								
				if `i' == 1 {
					local inf_references `"`inf_references' `curr'"'
				}
				if `i' >= 2 {
					local inf_varnames `"`inf_varnames' `curr'"'
				}
			}						
		}
	}
	
	// Always-In variables 
	unab alwaysinlist0 : __*
	local alwaysinlist ""
	local nalwaysin : word count `alwaysinlist0'
	local dep_and_intvarlist `depvarlist' `intvarlist' 
	if `nalwaysin' > 1 {
		forvalues i = 1/`nalwaysin' {			
			local curr : word `i' of `alwaysinlist0'		
			local b_curr = regexr("`curr'", "^__", "b_")
			local curr_varname = regexr("`curr'", "^__", "")
			if !`: list curr_varname in dep_and_intvarlist' {
				capture confirm variable `curr' 
				if _rc == 0 {
					local alwaysinlist `"`alwaysinlist' `curr'"'
				}
			}
		}
	}		
	 
	local reference_grouplead `: word 1 of `alwaysinlist''
	local inf_references "`inf_references' `reference_grouplead'" 
	foreach var1 of local alwaysinlist {
		local part_of_group1 0 
		if "`var1'" != "`reference_grouplead'" {
			quietly count if `var1' != `reference_grouplead'
			if r(N) == 0 {
				local part_of_group1 1
				continue, break
			} 						
			if !`part_of_group1' {
				 local inf_varnames `"`inf_varnames' `var1'"'
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
	tempname inf_mem_default inf_mem_sig inf_mem_pos	
	tempfile inf_file_default inf_file_sig inf_file_pos	
	
	local postnames_default str32 var abs_coef coef pct_chg mean_b row_id
 	quietly postfile `inf_mem_default' `postnames_default' using `inf_file_default', replace
	
	local postnames_sig str32 var abs_coef_sig coef_sig row_id_sig
	quietly postfile `inf_mem_sig' `postnames_sig' using `inf_file_sig', replace

	local postnames_pos str32 var coef_pos
	quietly postfile `inf_mem_pos' `postnames_pos' using `inf_file_pos', replace
	
	tempname infstats_default infstats_sig_only
	if "`inf_means'" == "inf_means" {
		local colnames_default abs_coef coef pct_chg mean_b row_id
	} 
	else {
		local colnames_default abs_coef coef pct_chg row_id
	}
	
	local colnames_sig_only abs_coef_sig coef_sig coef_pos row_id_sig
	local ncols_default : word count `colnames_default'
	local ncols_sig_only : word count `colnames_sig_only'
	matrix `infstats_default' = J(`ngroups', `ncols_default', .)
	matrix `infstats_sig_only' = J(`ngroups', `ncols_sig_only', .)
	
	
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
	local b_colnames : colnames e(b)
	qui gen double b_with_var = .
	foreach var of local inf_varnames {		
		
		local omitted = regexm("`b_colnames'", "(^| )o\.`var'($| )")	
		local part_of_group 0
		if "`omitted'" == "0" { // variable not omitted
			local groupleads `"`groupleads' `var'"'
			local group_`var' ""			
			qui replace b_with_var = b_intvar if `var' == 1
			sum b_with_var, meanonly
			qui replace b_with_var = . 
			quietly post `inf_mem_default' ("`var'") (abs(_b[`var'])) (_b[`var']) (100*(_b[`var']/`meanb')) (`r(mean)') (`i_row')		

		}
		else if "`omitted'" == "1" { //variable omitted due to collinearity; it was either part of a group or a reference category
			foreach groupvar of local groupleads {
				quietly count if `var' != `groupvar'
				if r(N) == 0  { // this variable is part of a group with some other variable recorded in groupleads
					local part_of_group 1 
					mata:  st_local("displayname", asarray(multivrs_varnames, "`var'"))
					local group_`groupvar' `"`group_`groupvar'' `displayname'"'
					continue, break
				}
			}	
		}		
	}
	
	if "`inf_means'" == "inf_means" {
		foreach var of local inf_references {
			qui sum b_intvar if `var' == 1		
			qui replace b_with_var = b_intvar if `var' == 1
			qui sum b_with_var, meanonly
			qui replace b_with_var = . 
			quietly post `inf_mem_default' ("`var'") (.) (.) (.) (`r(mean)') (.)
		}		
	}
	
	postclose `inf_mem_default' 
	/*
	Run the regressions for marginal effect of variable inclusion
	on the probability of significant or positive estimate.
	Store results in the matrix.
	*/
	
	local dummies sig pos
	foreach d of local dummies {
		capture reg `d' `inf_varnames' if i_bs == 1
		
		local i_row 0
		foreach var of local groupleads {
			local ++i_row
			//matrix `infstats_sig_only'[`i_row', `coef_`d''] = _b[`var']				
			if "`d'" == "sig" {
				//matrix `infstats_sig_only'[`i_row', `abs_coef_sig'] = abs(`infstats_sig_only'[`i_row', `coef_sig'])
				//matrix `infstats_sig_only'[`i_row',`row_id_sig'] = `i_row'
				if _rc == 0 qui post `inf_mem_sig' ("`var'") (abs(_b[`var'])) (_b[`var']) (`i_row') 
				else qui post `inf_mem_sig' ("`var'") (.) (.) (`i_row') 
			} 
			else if "`d'" == "pos" {
				if _rc == 0 qui post `inf_mem_pos' ("`var'") (_b[`var'])
				else qui post `inf_mem_pos' ("`var'") (.)
			}
		}
		if _rc == 0 return scalar infr2_`d' = e(r2)
		else return scalar infr2_`d' = .
		
		if _rc == 0 return scalar infcons_`d' = _b[_cons]
		else return scalar infcons_`d' = .		
		
		return scalar `d'_rc = _rc
	}	
	postclose `inf_mem_sig'
	postclose `inf_mem_pos'
	
	/*
	Sort the rows of each infstats matrix in descending order of absolute value of the
	influence coefficient.  Iterate through the sorted row_ids and attach the rownames to matrices
	in the proper order
	*/
	preserve	
	use `inf_file_default', clear
	if "`inf_means'" == "inf_means" {
		qui gen abs_mean_b = abs(mean_b)
		gsort -abs_mean_b
		qui drop abs_mean_b
	} 
	else {
		gsort -abs_coef
	}
	mata: infstats_default = st_data(.,(2,3,4,5,6))
	mata: st_matrix("`infstats_default'", infstats_default)

	qui valuesof var
	matrix rownames `infstats_default'  = `r(values)' 
	qui ds, has(type numeric)
	matrix colnames `infstats_default' = `r(varlist)'
	return matrix infstats_default = `infstats_default'
	restore

	// sig_only 
	
	preserve	
	use `inf_file_pos', clear	
	merge 1:1 var using `inf_file_sig', nogenerate noreport
	gsort -abs_coef_sig
	mata: infstats_sig_only = st_data(.,("abs_coef_sig", "coef_sig", "coef_pos"))
	mata: st_matrix("`infstats_sig_only'", infstats_sig_only)
	
	qui valuesof var
	matrix rownames `infstats_sig_only'  = `r(values)' 
	qui  ds, has(type numeric)
	matrix colnames `infstats_sig_only' = abs_coef_sig coef_sig coef_pos	
	return matrix infstats_sig_only = `infstats_sig_only'	
	restore	
	foreach var of local groupleads {
		return local group_`var' `"`group_`var''"'
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
		if `: word count ``l''' > 1 {
			foreach entry of local `l' {
				local colnames `colnames' `entry'
				local ++ncols
			}
		}
	}
	local ++ncols
	local rownames NModels SignStability SignificanceRate Positive PositiveandSig Negative NegativeandSig
	local nrows : word count `rownames'
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
		local curr_colname : word `i_col' of `colnames'
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
* from ssc install valuesof
*! version 1.0.2  Ben Jann  20may2008
program valuesof
    version 9.1, born(20Jan2006)
    capt mata mata which mm_invtokens()
    if _rc {
        di as error "mm_invtokens() from -moremata- is required; type {stata ssc install moremata}"
        error 499
    }
    syntax varname [if] [in] [, Format(str) MISSing ]
    mata: st_rclear()
    if `"`missing'"'=="" marksample touse, strok
    else marksample touse, strok nov
    capt confirm string var `varlist'
    if _rc {
        local dp = c(dp)
        set dp period
        if `"`format'"'=="" local format "%18.0g"
        else confirm format `format'
        mata: st_global("r(values)", ///
         mm_invtokens(strofreal(st_data(.,"`varlist'","`touse'")', `"`format'"')))
        set dp `dp'
    }
    else {
        mata: st_global("r(values)", ///
         mm_invtokens(st_sdata(.,"`varlist'","`touse'")'))
    }
    di `"`r(values)'"'
end
*/
