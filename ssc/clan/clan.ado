*!version 1.0.2 24Sep2020

/* -----------------------------------------------------------------------------
** PROGRAM NAME: clan
** VERSION: 1.0.2
** DATE: 24 September 2020
** -----------------------------------------------------------------------------
** CREATED BY: STEPHEN NASH, JENNIFER THOMPSON, BAPTISTE LAURENT
** -----------------------------------------------------------------------------
** PURPOSE: To conduct cluster level analysis of a cluster randomised trial
** -----------------------------------------------------------------------------
** UPDATES: 
** -----------------------------------------------------------------------------

*/

	prog define clan , eclass
		version 14.2
		syntax varlist(numeric fv) [if] [in], arm(varname numeric) CLUSter(varname numeric) EFFect(string) [Level(cilevel) STRata(varname numeric) FUPtime(varname numeric) SAVing(string) plot]
		local outcome = word("`varlist'" , 1)

			*************************************
			**
			** DATA SECTION
			**
			*************************************
			qui {
				marksample touse
				preserve // We're going to change the data - drop rows and create new vars
				capture keep `if' // Get rid of un-needed obs now
				capture keep `in'
				
				* Sort out the factor variable nightmare
					cap drop _I*
					*xi `varlist' , noomit

				* Check no interactions
				if strmatch("`varlist'" , "*#*") {
					dis as error "Interactions are not permitted"
					exit 101
				}
				

				** Drop any row with missing data for any covariate, outcome, arm or strata
				local vlist_no_i_dot = subinstr("`varlist'" , "i." , "" , .)
					foreach v of varlist `vlist_no_i_dot' `trt' `strata' `cluster' {
						drop if missing(`v')
						}
				}

			*************************************
			**
			** SYNTAX SECTION - CHECK THE PARAMETERS and CREATE SOME LOCALS
			**
			*************************************
			qui {
				tempname adjusted stratified minarm maxarm
				
				if "`effect'"!="rr" & "`effect'"!="rd" & "`effect'"!="rater" & "`effect'"!="rated" & "`effect'"!="mean" {
					dis as error "Unrecognised effect estimator"
					exit 198
					}
				
				* Is arm coded 0, 1?
					tab `arm'
					if r(r) != 2 {
						dis as error "There must be exactly two arms"
						exit 198
						}
					levelsof `arm' , local(arm_levs)
					if "`arm_levs'" != "0 1" {
						dis as error "Arm must be coded 0/1"
						exit 198
						}
				* Arm not constant within cluster
					bysort `cluster': egen minarm=min(`arm')
					bysort `cluster': egen maxarm=max(`arm')
					if minarm!=maxarm {
							dis as error "Arm variable should not vary within cluster"
							exit 198
							}				
				* If binary or Poisson, outcome must be 0/1
					if ("`effect'"=="rr" | "`effect'"=="rd" ) {
						levelsof `outcome' , local(out_levs)
						if "`out_levs'" != "0 1" {
							dis as error "Outcome must be 0/1 with `effect' option"
							exit 198
							}
					}
				* If Poisson, must specify follow-up variable
					if ("`effect'"=="rater" | "`effect'"=="rated") & "`fuptime'"=="" {
						dis as error "You must specify fuptime to calculate a rate ratio or difference"
						exit 198
					}
				*
				** Is this an adjusted analysis?
					if wordcount("`varlist'")>1 scalar `adjusted'=1
						else if wordcount("`varlist'")==1 scalar `adjusted'=0
							else {
								dis as error "varlist required"
								exit 100
								}
				** Is this a stratified analysis
					scalar `stratified' = 1
					if "`strata'" == "" scalar `stratified' = 0
						else local istrata i.`strata'
						
				** Saving dataset option
					tokenize "`saving'", parse(",")
					local savingfile `1'
					local savingreplace `3'			
			
				** Get a local with the name of the effect measure
					if `adjusted'==0 & `stratified'==0 { // Unadjusted, unstratified
						if "`effect'"=="rd" local effmeasure "Risk difference"
						if "`effect'"=="rr" local effmeasure "Risk ratio"
						if "`effect'"=="mean" local effmeasure "Mean difference"
						if "`effect'"=="rated" local effmeasure "Rate difference"
						if "`effect'"=="rater" local effmeasure "Rate ratio"
					}
					else {
						if "`effect'"=="rd" local effmeasure "Adjusted risk difference"
						if "`effect'"=="rr" local effmeasure "Adjusted risk ratio"
						if "`effect'"=="mean" local effmeasure "Adjusted mean difference"
						if "`effect'"=="rated" local effmeasure "Adjusted rate difference"
						if "`effect'"=="rater" local effmeasure "Adjusted rate ratio"
					}
				** Shorter effect name for output table
					if `adjusted'==0 & `stratified'==0 { // Unadjusted, unstratified
						if "`effect'"=="rd" local effabbrev "Risk diff."
						if "`effect'"=="rr" local effabbrev "Risk ratio"
						if "`effect'"=="mean" local effabbrev "Mean diff."
						if "`effect'"=="rated" local effabbrev "Rate diff."
						if "`effect'"=="rater" local effabbrev "Rate ratio"
					}
					else {
						if "`effect'"=="rd" local effabbrev "Adj. risk diff."
						if "`effect'"=="rr" local effabbrev "Adj. risk ratio"
						if "`effect'"=="mean" local effabbrev "Adj. mean diff."
						if "`effect'"=="rated" local effabbrev "Adj. rate diff."
						if "`effect'"=="rater" local effabbrev "Adj. rate ratio"
					}

			} // end quitely

			*************************************
			**
			** COMMON SECTION - Common to all analyses
			**
			*************************************
			qui {
				tempname obs numstrata numstrat_minusone uppertail c0 c1 c df result0 result1
				tempvar clussiz
				*
				* Dummy variable so we can count observations
					gen byte `obs' = 1
				*
				* Number of clusters
					tab `cluster' if `arm' == 0
						scalar `c0' = r(r)
					tab `cluster' if `arm' == 1
						scalar `c1' = r(r)
					scalar `c' = `c0' + `c1'
					local num_clus = `c'
				* Number of observations and cluster size
					local num_obs = _N
					local clus_siz_avg = `num_obs' / `num_clus'
					bysort `cluster': gen `clussiz' = _N
					sum `clussiz'
					local clus_siz_min= r(min)
					local clus_siz_max= r(max)
				* Number of strata
					if `stratified'==1 {
						tab `strata'
						scalar `numstrata' = r(r)
						scalar `numstrat_minusone' = `numstrata' - 1
						}
						else {
							scalar `numstrata' = 0
							scalar `numstrat_minusone ' = 0
							}

				* Count cluster level covariates
					local num_cluster_covars = 0
					* Get list of clusters
					levelsof `cluster' , local(cluster_levels)
					foreach v in `varlist' {
						if substr("`v'", 2,1) == "." { // If factor var
							local num_clv_this_fv = 0
							local simple_var = substr("`v'" , 3 , . )
							levelsof `simple_var' , local(var_levels)
								local num_levs = r(r)
							foreach j of local var_levels { // Old
								local total_sd = 0
								foreach i of local cluster_levels {
									sum `j'.`simple_var' if `cluster' == `i'
									local total_sd = `total_sd' + r(Var)
									} // end i loop
								levelsof `simple_var' , local(var_levels)
								if `total_sd' == 0 { // We've found a cluster-level variable
								*noi dis "Got one : `v'" 
									local num_cluster_covars = `num_cluster_covars' + 1
									local num_clv_this_fv = `num_clv_this_fv' + 1
								} // end if
							} // end j loop
							if `num_clv_this_fv' >= 2 local num_cluster_covars = `num_cluster_covars' - 1
						} // end Factor variable if substr
							else { // normal var
								local total_sd = 0
								foreach i of local cluster_levels {
									sum `v' if `cluster'==`i'
									local total_sd = `total_sd' + r(Var)
								} // end i loop
								if `total_sd' == 0 local num_cluster_covars = `num_cluster_covars' + 1
							} // end else
					} // end v for loop
					
				* Degrees of freedom
					scalar `df' = `c0' + `c1' - 2 - `num_cluster_covars' - `numstrat_minusone'
					local dfm = `df'
					local df_noadj = (`c0' + `c1' - 2)   // To display in output
					local df_penal = (`num_cluster_covars' + `numstrat_minusone')  // To display in output
				** Calculate the upper tail area to use in the calculation of the CI
					scalar `uppertail' = 0.5 * (100 - `level') / 100
					
				} // end qui
/*
█████▄░██░██▄░██░░▄███▄░░████▄░██▄░░▄██
██▄▄█▀░██░███▄██░██▀░▀██░██░██░░▀████▀░
██░░██░██░██▀███░███████░████▀░░░░██░░░
█████▀░██░██░░██░██░░░██░██░██░░░░██░░░
*/
			*************************************
			**
			** RISK SECTION (both ratio and difference)
			**
			*************************************
			qui {
				if "`effect'"=="rr" | "`effect'"=="rd" {
					tempname A expected cellcases zero howmanyzeros cprev 
					tempname prev_lb prev_ub prev0 prev1 logprev logprev0 logprev1
					tempname beta logbeta beta_lci beta_uci ts pval sd se s0 s1 tvalue s_pooled_log
					tempname actual_cprev actual_prev0 actual_prev1
					tempname b V
					tempfile cldata

					* Put effect type into a local for displaying results
						local efftype Risk

					* GET CLUSTER LEVEL SUMMARIES BY COLLAPSING THE DATA
					* If adjusted analysis, we need to get expected number from a logistic
					* regression WITHOUT the treatment arm BEFORE we collapse data
					if `adjusted'==1 {
						logistic `varlist' `istrata' 
						predict `expected' , pr
						collapse (sum) `outcome' `obs' `expected', by(`cluster' `strata' `arm')
					}
						else {
							collapse (sum) `outcome' `obs' , by(`cluster' `strata' `arm')
							}
					
					* If we'll be taking logs, add 0.5 to all if one cluster prev is zero
					if "`effect'" == "rr" {
						bysort `cluster' `strata' `arm' : gen `cellcases'=sum(`outcome')
						gen byte `zero' = 1 if `cellcases'==0 // Marks cells with zero cases
						gen `howmanyzeros' = sum(`zero') // Makes a running total of number of cells with zero prev
						if `howmanyzeros'[_N] > 0.5  { // Look at just the end of the running total
							replace `outcome' = `outcome' + 0.5 
							noi dis as text "Warning: at least one cluster has zero prevalence, so 0.5 will be added to every cluster total" 
						}
					}
					*
					* Calculate cluster prevalences
					gen `actual_cprev' = `outcome' / `obs' // For graphical display
						sum `actual_cprev' if `arm' == 0
							scalar `actual_prev0' = r(mean)
							scalar `result0' = `actual_prev0'
						sum `actual_cprev' if `arm' == 1
							scalar `actual_prev1' = r(mean)
							scalar `result1' = `actual_prev1'
					
					if `adjusted'==0 gen `cprev' = `outcome' / `obs'
						else if "`effect'"=="rr" gen `cprev' = `outcome' / `expected'
							else gen `cprev' = (`outcome' - `expected') / `obs'
					*
					* Summarise by treatment arm
						sum `cprev' if `arm' == 0
							scalar `prev0' = r(mean)
						sum `cprev' if `arm' == 1
							scalar `prev1' = r(mean)				
					*
					* PERFORM ANALYSIS ON THE CLUSTER SUMMARIES
					if "`effect'" == "rd" { // NATURAL SCALE, RISK DIFFERENCE
						regress `cprev' i.`arm' `istrata'
						mat `A' = r(table)
						mat `b' = e(b)
						mat `V' = e(V)
						*scalar `se' = r(se)
						scalar `se' = `A'[2,2]
						scalar `beta' = `A'[1,2]
							 scalar `beta' = `prev1' - `prev0'
						scalar `beta_lci' = `beta' - (invttail(`df', `uppertail') * `se')
						scalar `beta_uci' = `beta' + (invttail(`df', `uppertail') * `se')
						scalar `ts' = sign(`beta')*(`beta' / (`se'))
						scalar `pval'=2*ttail(`df',`ts')
						}
					else { // LOG SCALE, RISK RATIO
							gen `logprev' = log(`cprev')
							regress `logprev' i.`arm' `istrata'
							mat `A' = r(table)
							mat `b' = e(b)
							mat `V' = e(V)
							scalar `se' = `A'[2,2]
							sum `cprev' if `arm' == 1
							scalar `prev1' = r(mean)
							sum `cprev' if `arm' == 0
							scalar `prev0' = r(mean)
							scalar `beta' = exp(`A'[1,2])
								* scalar `beta' = `prev1' / `prev0'
							scalar `logbeta' = `A'[1,2]
							scalar `beta_lci' = exp(`logbeta' - invttail(`df', `uppertail') * `se')
							scalar `beta_uci' = exp(`logbeta' + invttail(`df', `uppertail') * `se')
							scalar `ts' = sign(`logbeta')*(`logbeta' / (`se'))
							scalar `pval'=2*ttail(`df',`ts')
						}
						
					** PLOT AND SAVING OPTIONS
						
						* Plot of cluster prevelances
							if "`plot'" != "" dotplot `cprev' , over(`arm') center nx(10) xtitle("") xlabel(0 "Arm 0" 1 "Arm 1") xtick( , notick) xmtick( , notick) ytitle("Cluster summaries") legend(off)
						
						* Saving cluster-level dataset				
							if "`saving'" != ""  {
								local savevars `cluster' `arm' `strata' `outcome'  `obs' `actual_cprev'
								if `adjusted'==1  local savevars `savevars' `cprev'
								if "`effect'"=="rr" local savevars `savevars' `logprev'
								keep `savevars'
								rename `obs' obs
								rename `actual_cprev' clus_prev
								cap: rename `cprev' clus_summ
								cap: rename `logprev' log_clus_summ
								save `cldata'
								}
															
					** RESTORE DATA AND RETURN VALUES
						restore	
						ereturn post `b' `V' , obs(`num_clus') depname(`outcome') esample(`touse') dof(`dfm')
						ereturn local depvar "`outcome'"
						ereturn scalar p = `pval'
						ereturn scalar lb = `beta_lci'
						ereturn scalar ub = `beta_uci'
						if "`effect'" == "rd" ereturn scalar rd = `beta'
							else ereturn scalar rr = `beta'
						
				} // end if RR | RD
			} // end quitely

/*
████▄░░▄███▄░░██░▄███▄░▄███▄░░▄███▄░░██▄░██
██░██░██▀░▀██░██░▀█▄▀▀░▀█▄▀▀░██▀░▀██░███▄██
████▀░██▄░▄██░██░▄▄▀█▄░▄▄▀█▄░██▄░▄██░██▀███
██░░░░░▀███▀░░██░▀███▀░▀███▀░░▀███▀░░██░░██
*/
			*************************************
			**
			** POISSON COUNT SECTION
			**
			*************************************
			qui {
				if "`effect'"=="rater" | "`effect'"=="rated" {
					tempname expected cellcases zero howmanyzeros 
					tempname crate rate_lb rate_ub ci_se rate0 rate1 
					tempname logcrate lograte0 lograte1 beta logbeta beta_lci beta_uci
					tempname ts pval sd se s0 s1 mu0 mu1 
					tempname actual_crate actual_rate0 actual_rate1
					tempname A b V
					tempfile cldata
					
					* Put effect type into a local for displaying results
						local efftype Rate

					* GET CLUSTER LEVEL SUMMARIES BY COLLAPSING THE DATA
					* If adjusted analysis, we need to get expected number from a logistic
					* regression WITHOUT the treatment arm BEFORE we collapse data
					if `adjusted'==1 {
						if `stratified'==1 poisson `varlist' i.`strata' , exp(`fuptime') irr
							else poisson `varlist' , exp(`fuptime') irr
						predict `expected' , n
						collapse (sum) `outcome' `obs' `expected' `fuptime', by(`cluster' `strata' `arm')
					}
						else collapse (sum) `outcome' `obs' `fuptime' , by(`cluster' `strata' `arm') 
					pause
					*replace know = 0 if commu==1 // Unstar this to test the code below
					
					* If we'll be taking logs, add 0.5 to all if one cluster prev is zero
					if "`effect'" == "rater" {
						bysort `cluster' `strata' `arm' : gen `cellcases'=sum(`outcome')
						gen byte `zero' = 1 if `cellcases'==0 // Marks cells with zero cases
						gen `howmanyzeros' = sum(`zero') // Makes a running total of number of cells with zero prev
						if `howmanyzeros'[_N] > 0.5 {
							replace `outcome' = `outcome' + 0.5
							noi dis as text "Warning: at least one cluster has zero prevalence, so 0.5 will be added to every cluster total" 
						}
					}
					*
					* Calculate cluster prevalences
					** Summarise overall and by arm for reporting
					gen `actual_crate' = `outcome' / `fuptime'
						sum `actual_crate' if `arm' == 0
							scalar `actual_rate0' = r(mean)
							scalar `result0' = `actual_rate0'
						sum `actual_crate' if `arm' == 1
							scalar `actual_rate1' = r(mean)
							scalar `result1' = `actual_rate1'

					if `adjusted'==0 gen `crate' = `outcome' / `fuptime' 
						else if "`effect'"=="rater" gen `crate' = `outcome' / `expected'
							else gen `crate' = (`outcome' - `expected') / `fuptime'
					*

					* Summarise by treatment arm
						sum `crate' if `arm' == 0
							scalar `rate0' = r(mean)
						sum `crate' if `arm' == 1
							scalar `rate1' = r(mean)
					*
					* PERFORM ANALYSIS ON THE CLUSTER SUMMARIES
					if "`effect'" == "rated" { // NATURAL SCALE, RATE DIFFERENCE
						regress `crate' i.`arm' `istrata'
						mat `A' = r(table)
						mat `b' = e(b)
						mat `V' = e(V)
						scalar `se' = `A'[2,2]
						scalar `beta' = `A'[1,2]
						scalar `beta_lci' = `beta' - (invttail(`df', `uppertail') * `se')
						scalar `beta_uci' = `beta' + (invttail(`df', `uppertail') * `se')
						scalar `ts' = sign(`beta')*(`beta' / (`se'))
						scalar `pval'=2*ttail(`df',`ts')
						}
						else { // LOG SCALE, RATE RATIO
							gen `logcrate' = log(`crate')
							regress `logcrate' i.`arm' `istrata'
							mat `A' = r(table)
							mat `b' = e(b)
							mat `V' = e(V)
							scalar `se' = `A'[2,2]

							sum `logcrate' if `arm' == 1
							scalar `lograte1' = r(mean)
							sum `logcrate' if `arm' == 0
							scalar `lograte0' = r(mean)
							scalar `logbeta' = `A'[1,2]
							scalar `beta' = exp(`logbeta')
							scalar `beta_lci' = exp(`logbeta' - invttail(`df', `uppertail') * `se')
							scalar `beta_uci' = exp(`logbeta' + invttail(`df', `uppertail') * `se')
							scalar `ts' = sign(`logbeta')*(`logbeta' / (`se'))
							scalar `pval'=2*ttail(`df',`ts')
						}
					
					** PLOT AND SAVING OPTIONS
					
						* Plot
							if "`plot'" != "" dotplot `crate' , over(`arm') center nx(10) xtitle("") xlabel(0 "Arm 0" 1 "Arm 1") xtick( , notick) xmtick( , notick) ytitle("Cluster summaries") legend(off)
							
						* Saving cluster-level dataset	
							if "`saving'" != ""  {
								local savevars `cluster' `arm' `strata' `outcome'  `obs' `actual_crate'
								if `adjusted'==1  local savevars `savevars' `crate'
								if "`effect'"=="rater" local savevars `savevars' `logcrate'
								keep `savevars' 
								rename `obs' obs 
								rename `actual_crate' clus_rate
								cap: rename `crate' clus_summ
								cap: rename `logcrate' log_clus_summ
								save `cldata'
								}	
										
					** RESTORE DATA AND RETURN VALUES
						restore	

						ereturn post `b' `V' , obs(`num_clus') depname(`outcome') esample(`touse') dof(`dfm')
						ereturn local depvar "`outcome'"
						ereturn scalar p = `pval'
						ereturn scalar lb = `beta_lci'
						ereturn scalar ub = `beta_uci'
						if "`effect'"=="rater" ereturn scalar rater = `beta'
							else ereturn scalar rated = `beta'
								
								
				} // end if RATER | RATED
			} // end quitely
					
					
					

/*
██▄░▄██░████░░▄███▄░░██▄░██░▄███▄
██▀█▀██░██▄░░██▀░▀██░███▄██░▀█▄▀▀
██░░░██░██▀░░███████░██▀███░▄▄▀█▄
██░░░██░████░██░░░██░██░░██░▀███▀
*/
			*************************************
			**
			** CONTINUOUS OUTCOME SECTION
			** Difference in means
			**
			*************************************
			qui {
				if "`effect'"=="mean" {
					tempname expected beta ts pval sd pval se s0 s1 mu0 mu1
					tempname mn mn0 mn1 beta beta_lci beta_uci ts pval
					tempname csd mn_lb mn_ub critval 
					tempname actual_cmean actual_mean0 actual_mean1
					tempname A b V
					tempfile cldata
					
					* Put effect type into a local for displaying results
						local efftype Mean

					* Calc the standard eviation within each cluster, as a constant
						egen `csd' =sd(`outcome') , by(`cluster')
					* If adjusted analysis, we need to get expected number from a
					* regression WITHOUT the treatment arm BEFORE we collapse data
					if `adjusted'==1 {
						if `stratified'==1 regress `varlist' i.`strata'
							else regress `varlist'
						predict `expected' , xb
						collapse (sum) `outcome' `obs' `expected' (first) `csd', by(`cluster' `strata' `arm')  // adjusted
					}
						else collapse (sum) `outcome' `obs' (first) `csd', by(`cluster' `strata' `arm')  // unadjusted
					*
					* Calculate cluster summaries, actual and usign the adjusted residuals
					gen `actual_cmean' = `outcome' / `obs'
						sum `actual_cmean' if `arm' == 0
							scalar `actual_mean0' = r(mean)
							scalar `result0' = `actual_mean0'
						sum `actual_mean' if `arm' == 1
							scalar `actual_mean1' = r(mean)
							scalar `result1' = `actual_mean1'
					
					if `adjusted'==0 gen `mn' = `outcome' / `obs' 
						else gen `mn' = (`outcome' - `expected') / `obs'

					sum `mn' if `arm' ==0
						scalar `mn0' = r(mean)
					sum `mn' if `arm' == 1
						scalar `mn1' = r(mean)

					regress `mn' i.`arm' `istrata'
					* 95% CI, p-value
						mat `A' = r(table)
						mat `b' = e(b)
						mat `V' = e(V)
						scalar `beta' = `A'[1,2]
						scalar `se' = `A'[2,2]
					
						scalar `beta_lci' = `beta' - (invttail(`df', `uppertail')*`se')
						scalar `beta_uci' = `beta' + (invttail(`df', `uppertail')*`se')
						scalar `ts' = sign(`beta')*(`beta' / `se')
						scalar `pval'=2*ttail(`df',`ts')
					
					** PLOT AND SAVING OPTIONS
					
						* Plot of cluster means
							if "`plot'" != "" dotplot `mn' , over(`arm') center nx(10) xtitle("") xlabel(0 "Arm 0" 1 "Arm 1") xtick( , notick) xmtick( , notick) ytitle("Cluster summaries") legend(off)

						* Saving cluster-level dataset					
							if "`saving'" != ""  {
							    local savevars `cluster' `arm' `strata' `outcome'  `obs' `actual_cmean'
								if `adjusted'==1  local savevars `savevars' `mn'
								keep `savevars'
								rename `obs' obs 
								rename `actual_cmean' clus_mean
								cap: rename `mn' clus_summ
								save `cldata'
							}	
					
					** RESTORE DATA AND RETURN VALUES
						restore	

						ereturn post `b' `V' , obs(`num_clus') depname(`outcome') esample(`touse') dof(`dfm')
						ereturn local depvar "`outcome'"
						ereturn scalar p = `pval'
						ereturn scalar lb = `beta_lci'
						ereturn scalar ub = `beta_uci'
						ereturn scalar meand = `beta'
														
				} // end if continuous
			} // end quitely

	/*

░▄███▄░░▄███▄░░██▄░▄██░██▄░▄██░░▄███▄░░██▄░██░░
██▀░▀▀░██▀░▀██░██▀█▀██░██▀█▀██░██▀░▀██░███▄██░░
██▄░▄▄░██▄░▄██░██░░░██░██░░░██░██▄░▄██░██▀███░░
░▀███▀░░▀███▀░░██░░░██░██░░░██░░▀███▀░░██░░██░░

▄███▄░████░░▄███▄░████░██░░▄███▄░░██▄░██░▄███▄
▀█▄▀▀░██▄░░██▀░▀▀░░██░░██░██▀░▀██░███▄██░▀█▄▀▀
▄▄▀█▄░██▀░░██▄░▄▄░░██░░██░██▄░▄██░██▀███░▄▄▀█▄
▀███▀░████░░▀███▀░░██░░██░░▀███▀░░██░░██░▀███▀

*/
	*************************************
	**
	** COMMON SECTION
	**
	*************************************
		** Clean saving dataset
			qui {
			if "`saving'" != ""  {
				preserve
				use `cldata', clear
				label data ""
				foreach var of varlist _all {
					label var `var' ""
				}
				compress
				save "`savingfile'", `savingreplace'
				restore
				}	
			}
	
		** COMMON ERETURN VALUES
			ereturn scalar level = `level'
			ereturn local cmdline `"`0'"'
			ereturn local cmd "clan"
			

		** TEXT OUTPUT FOR ALL OUTCOME TYPES - the program always reaches these lines
		
			
		**BLAug20: Try new ouput display:	
			noi dis as text _n "Cluster-level analysis"		
			noi dis as text _n "Number of clusters (total): " as result `c'	_col(48) as text "Number of obs     = " as result %8.0gc `num_obs'
			noi dis as text "Number of clusters (arm 0): " as result `c0'	_col(48) as text "Obs per cluster:"                                
			noi dis as text "Number of clusters (arm 1): " as result `c1'	_col(62) as text "min = " as result %8.1gc `clus_siz_min'         
			noi dis as text 												_col(62) as text "avg = " as result %8.1gc `clus_siz_avg'          
			noi dis as text													_col(62) as text "max = " as result %8.1gc `clus_siz_max'         			
			
			** JT covert BL text version output table to a stata output table
			
			tempname Tab

			.`Tab' = ._tab.new, col(6) lmargin(0) 

			// column           1      2     3     4     5     6
			.`Tab'.width       20    |12     8     10     12    12
			.`Tab'.titlefmt %12s      .     .     .   %24s	    .
			.`Tab'.pad          .      2     0     0      3     3
			.`Tab'.numfmt       .  %9.0g %7.0g %9.4f  %9.0g %9.0g  

			.`Tab'.sep, top
			.`Tab'.titles  "" "Estimate" "df" "P-val"  `"[`level'% Conf. Interval]"' ""
			.`Tab'.sep, middle

			*if length("`statistic'")>18 local ab_statistic = substr("`statistic'",1,11)+".."
			*else local ab_statistic "`statistic'"

			.`Tab'.row `"`efftype' by arm"' /*
					*/ "" /*
					*/ "" /*
					*/ "" /*
					*/ ""/*
					*/ ""
			
			.`Tab'.row `"0"' /*
					*/ `result0' /*
					*/ "" /*
					*/ "" /*
					*/ ""/*
					*/ ""
					
			.`Tab'.row `"1"' /*
					*/ `result1' /*
					*/ "" /*
					*/ "" /*
					*/ ""/*
					*/ ""
					
			.`Tab'.sep, middle
			
			.`Tab'.row `"`effabbrev'"' /*
					*/ `beta' /*
					*/`df' /*
					*/ `pval' /*
					*/ `beta_lci' /*
					*/ `beta_uci'  

			.`Tab'.sep, bottom
			
			/* Comment out BL original output
			noi dis as text "`efftype' in arm 0 = " as result `result0'
			noi dis as text "`efftype' in arm 1 = " as result `result1'		
			noi dis _n as text "{hline 19}{c TT}{hline 55}"
			noi dis as text %18s "Effect" " {c |} " _col(25)  "Estimate      df     P-val     [95% Conf. Interval]" 
			noi dis as text "{hline 19}{c +}{hline 55}"	
			noi dis as text %18s "`effabbrev'" " {c |}   " as result  %9.0g `beta' "   " %5.0g `df' "    " %5.4f `pval' "     " %9.0g `beta_lci'  "  " %9.0g `beta_uci' 
			noi dis as text "{hline 19}{c BT}{hline 55}"		
			*/
			
			if (`df_penal'>0)  noi dis as text "Note: Adjusted degrees of freedom = " as result `df_noadj' as text " - " as result `df_penal'  //as text " = "as result `df' 
			
		
		
end

