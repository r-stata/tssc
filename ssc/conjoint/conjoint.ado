*! conjoint 1.0.0 22may2021
*! author Michael J. Frith
 
program conjoint, eclass
	version 16
	
	if replay() {
		if ("`e(cmd)'" != "conjoint") error 301
		syntax , [NOtable graph GRAPH2(integer -1)]
		
		local subgroup `e(subgroupvar)'
		local xvars `e(indepvars)'
		local estimate `e(estimate)'
		local depvar `e(depvar)'
		if ("`id'" != "") local id `e(clustvar)'
		if ("`estimate'" == "amce") local constraints `e(constraints)'
		if ("`estimate'" == "amce") local baselevels `e(baselevels)'
		if ("`estimate'" == "mm") local h0 `e(h0)'
		
		/* collects data from ereturn needed for replay */
		if "`subgroup'" != "" {
			foreach sub_label in `e(subgroup_labels)' {
				if ("`id'" != "") local N_clust `e(N_clust_`sub_label')'
				else local N_clust .
				if ("`estimate'" == "amce") matrix modelstats_`sub_label' = ///
				`e(N_`sub_label')' \ `e(df_m_`sub_label')' \ ///
				`e(df_r_`sub_label')' \ `e(r2_`sub_label')' \ ///
				`e(F_`sub_label')' \ `N_clust'
				else matrix modelstats_`sub_label' = `e(N_`sub_label')' \ . ///
				\ `e(df_r_`sub_label')' \ . \ . \ `N_clust'
				ereturn matrix modelstats_`sub_label' modelstats_`sub_label'
			}
		}
		else {
			if ("`id'" != "") local N_clust `e(N_clust)'
			else local N_clust .		
			if ("`estimate'" == "amce") matrix modelstats = `e(N)' \  ///
			`e(df_m)' \ `e(df_r)' \ `e(r2)' \ `e(F)' \ `N_clust'
			else matrix modelstats = `e(N)' \ . \ `e(df_r)' \ . \ . \ `N_clust'
			ereturn matrix modelstats modelstats
		}
	}
	else {
		syntax varlist(min=2) [if] [in], ESTimate(string) [ID(varname) ///
		SUBgroup(varname) BASElevels(numlist int) CONstraints(varlist fv) ///
		h0(real -1) NOtable graph GRAPH2(integer -1)]
		marksample touse
		gettoken depvar xvars: varlist

		/* prepare and check inputs */
		conjoint_prep , xvars(`xvars') estimate(`estimate') h0(`h0') ///
		constraints(`constraints') baselevels(`baselevels') rawcmd(`0') ///
		subgroup(`subgroup') graph("`graph'") graph2("`graph2'")

		/* estimate effects */
		if "`estimate'" == "mm" {
			conjoint_est_mm, depvar(`depvar') xvars(`xvars') ///
			resmat_size(`e(resmat_size)') subgroup(`subgroup') h0(`h0') ///
			id(`id') touse(`touse') 
		}
		else if "`estimate'" == "amce" {
			conjoint_est_amce, depvar(`depvar') xvars(`xvars') ///
			resmat_size(`e(resmat_size)') regress_xvars(`e(regress_xvars)') ///
			baselevels(`e(baselevels)') subgroup(`subgroup') id(`id') ///
			touse(`touse') 
		}
	}
	
	/* display results, allowed for replay */
	conjoint_disp , subgroup(`subgroup') xvars(`xvars')	notable("`notable'") ///
	graph("`graph'") graph2("`graph2'") estimate("`estimate'") rawcmd(`0') ///
	depvar(`depvar') clustvar(`id') constraints(`constraints') ///
	baselevels(`e(baselevels)') h0(`h0')
end

program conjoint_prep, eclass
	syntax , xvars(varlist) estimate(string) [h0(real -1) ///
	constraints(string) baselevels(numlist int) rawcmd(string) ///
	subgroup(varname) graph(string) graph2(string)]
	
	/* if estimating amces */
	if "`estimate'"=="amce" {
	    /* check if h0 is specified as not valid for amce */
		if `h0' != -1 {
			di as error "h0 cannot be specified when estimating amce"
			exit 198
		}
		
		/* check constraints */
		/* error if full-factorial interaction (in constraints) */
		if strpos("`rawcmd'","##") {
			di as error "full-factorial interactions (##) not allowed in constraints"
			exit 198
		}
		/* error if spaces are found in constraints */
		if strpos("`rawcmd'"," #") | strpos("`rawcmd'","# ") {
			di as error "spaces between # and variables not allowed in constraints"
			exit 198
		}	
		/* ensures constraints is suitably formatted */
		local constraints: subinstr local constraints "i." "", all
		local constraints_cln: subinstr local constraints "#" " ", all
		if strpos("`constraints_cln'",".") {
			di as error "unary operators not allowed in constraints"
			exit 198
		}
		/* checks for multiple occurrences of the same var in constraints */
		local dup_constraints : list dups constraints_cln
		if "`dup_constraints'" != "" {
			di as error "repeated variables in constraints not allowed"
			exit 198
		}	
		/* find non-constrained vars, add them to constraint list */
		local missing_xvars : list xvars - constraints_cln
		local regress_xvars : list constraints | missing_xvars
		
		/* check and clean baselevels */
		/* if baselevels entered */
		if "`baselevels'" != "" {
			local base_count : word count `baselevels'
			local var_count : word count `xvars'
			/* if incorrect number of baselevels are specified */
			if `base_count' != `var_count' {
				di as error "incorrect number of baselevels specified"
				exit 198
			}
			/* if correct number of baselevels, check those levels exist */
			else {
				forvalues i = 1/`var_count' {
					local base : word `i' of `baselevels'
					local xvar : word `i' of `xvars'
					quietly levelsof `xvar', local(xvar_levels)
					local base_check: list base in xvar_levels
					if `base_check' != 1 {
						di as error "baselevel `base'.`xvar' not found"
						exit 198
					}
				}
			}
		}
		/* if baselevels are not entered, use first value of each variable */
		else {
			foreach xvar of local xvars {
				quietly levelsof `xvar'
				local base: word 1 of `r(levels)'
				local baselevels `baselevels' `base'
			}
		}
	}
	/* if estimating mms */
	else if "`estimate'"=="mm" {
	    /* check if constraints are specified as not valid for mm */
		if "`constraints'" != "" {
			di as error "constraints cannot be specified when estimating mm"
			exit 198
		}
		
		/* check if baselevels are specified as not valid for mm */
		if "`baselevels'" != "" {
			di as error "baselevels cannot be specified when estimating mm"
			exit 198
		}
	}
	/* otherwise unknown */
	else {
		di as error "unknown metric in estimate"
		exit 198
	}
	
	/* check for duplicate xvars */
	local dup_vars : list dups xvars
	if "`dup_vars'" != "" {
		di as error "repeated variables in varlist"
		exit 198
	}
	
	/* check graph settings */
	if "`graph'`graph2'" != "-1" {
		if "`subgroup'" != ""  {
			quietly levelsof `subgroup'
			local subgroup_count : word count `r(levels)'
			if `subgroup_count' < `graph2' {
				di as error "graph() value is too large for the number of subgroups"
				exit 198
			}
		}
		else if `graph2' > 0 {
			di as error "graph() value incorrect as no subgroups specified"
			exit 198
		}
	}

	/* calculate size of matrix for results */
	foreach xvar of local xvars {
		quietly levelsof `xvar', local(xvar_levels)
		local resmat_size = `resmat_size' + `r(r)'
	}
	
	ereturn local regress_xvars `regress_xvars'
	ereturn local baselevels `baselevels'
	ereturn scalar resmat_size = `resmat_size'

end

program conjoint_est_mm, eclass
	syntax , depvar(varname) xvars(varlist) resmat_size(int) ///
	[subgroup(varname) h0(real -1) id(varname) touse(string)]
	
	/* revert default value of H0 */
	if (`h0' == -1) local h0 = 0.5

	/* if subgroups, generate if conditions and result matrix names */
 	if "`subgroup'" != "" {
 	    quietly levelsof `subgroup'
 		foreach sub in `r(levels)' {
 			local if_conditions `if_conditions' `subgroup'==`sub'&`touse'
 			local subgroup_label : label (`subgroup') `sub'
			local subgroup_label = strtoname("`subgroup_label'")			
 			local resmat_names `resmat_names' results_`subgroup_label'
			local modelstatsmat_names `modelstatsmat_names' modelstats_`subgroup_label'
 		}
 	}
	/* if no subgroups, use touse as if condition and use generic matrix name */
 	else {
 	    local if_conditions `touse'
		local resmat_names results
		local modelstatsmat_names modelstats 
 	}

	/* main code */
	local num_models : word count `if_conditions'
	forvalues model_num = 1/`num_models' {
		local if_condition : word `model_num' of `if_conditions'
		local resmat_name : word `model_num' of `resmat_names'
		local modelstats_name : word `model_num' of `modelstatsmat_names'
		matrix `resmat_name' = J(`resmat_size',6,.)
		local matrix_rownum = 1
		
		/* original r code computes models seperately for each var (and sub) */
		foreach xvar of local xvars {
			quietly regress `depvar' i.`xvar' if `if_condition', cluster(`id')
			if ("`id'"!= "") local N_clust = `e(N_clust)'
			quietly margins i.`xvar', post
			mat tempres = r(table)
			
			local matpos 1
			quietly levelsof `xvar'
			foreach xvar_level in `r(levels)' {
				quietly lincom "(_b[`xvar_level'.`xvar'] - `h0')"
				matrix `resmat_name'[`matrix_rownum',1] = ///
				tempres[1,`matpos'], tempres[2,`matpos'], r(t), r(p),  ///
				tempres[5,`matpos'], tempres[6,`matpos']
				local ++matpos
				local ++matrix_rownum
			}
		}
		if "`id'"!= "" {
			matrix `modelstats_name' = `e(N)' \ . \ `e(df_r)' \ . \ . \ `N_clust'
		}
		else {
			matrix `modelstats_name' = `e(N)' \ . \ `e(df_r)' \ . \ . \ .
		}
	}

	ereturn clear
	forvalues model_num = 1/`num_models' {
		local resmat_name : word `model_num' of `resmat_names'
		local modelstats_name : word `model_num' of `modelstatsmat_names'
		ereturn matrix `resmat_name' `resmat_name'
		ereturn matrix `modelstats_name' `modelstats_name'	
	}
end

program conjoint_est_amce, eclass
	syntax , depvar(varname) xvars(varlist) resmat_size(int) ///
	[regress_xvars(string) baselevels(numlist int) subgroup(varname) ///
	id(varname) touse(string)]
	
	/* if subgroups, generate if conditions and result matrix names */
 	if "`subgroup'" != "" {
 	    quietly levelsof `subgroup'
 		foreach sub in `r(levels)' {
 			local if_conditions `if_conditions' `subgroup'==`sub'&`touse'
 			local subgroup_label : label (`subgroup') `sub'
			local subgroup_label = strtoname("`subgroup_label'")			
 			local resmat_names `resmat_names' results_`subgroup_label'
			local modelstatsmat_names `modelstatsmat_names' modelstats_`subgroup_label'
 		}
 	}
	/* if no subgroups, use touse as if condition and use generic matrix name */
 	else {
 	    local if_conditions `touse'
		local resmat_names results
		local modelstatsmat_names modelstats 
 	}

	/* main code */
	local num_models : word count `if_conditions'
	forvalues model_num = 1/`num_models' {
		local if_condition : word `model_num' of `if_conditions'
		local resmat_name : word `model_num' of `resmat_names'
		local modelstats_name : word `model_num' of `modelstatsmat_names'
		matrix `resmat_name' = J(`resmat_size',6,.)
		local matrix_rownum = 1
		
		quietly regress `depvar' i.(`regress_xvars') if `if_condition', cluster(`id')
		quietly margins `regress_xvars'
		mat reg_errors = r(error)
		
		local xvar_count : word count `xvars'
		forvalues i = 1/`xvar_count' {
			local focal_xvar : word `i' of `xvars'
			local focal_xvar_baselevel : word `i' of `baselevels'
			
			/* find focal_var in regress xvar list */
			foreach regress_xvar of local regress_xvars {

				local regress_xvar: subinstr local regress_xvar "#" " ", all
				/* check if the focal var is in regress xvar */
				local found : list focal_xvar in regress_xvar

				/* found the focal xvar in the regress xvar */
				if `found' ==1 { 
					
					/* all other xvars interacted with focal xvar */
					local other_xvars : list regress_xvar - focal_xvar
					
					/* iterate through all other levels of focal var */
					quietly levelsof `focal_xvar', local(focal_xvar_levels)
					foreach focal_xvar_level of local focal_xvar_levels {

						/* if that level is not the baselevel */
						if "`focal_xvar_level'" != "`focal_xvar_baselevel'" {
							local list `focal_xvar'

							/* loop through all other vars in the regress_xvar */
							foreach other_xvar of local other_xvars {					

								/* create all combinations */
								quietly levelsof `other_xvar', local(other_xvar_levels)
								foreach other_xvar_level of local other_xvar_levels {
									foreach element of local list {
										local list_latest `list_latest' ///
										`element'#`other_xvar_level'.`other_xvar'
									}
								}
								local list `list_latest'
								local list_latest ""
							}
							local count 0
							local base_string 0
							local focal_string 0
							foreach element of local list {
								if reg_errors["r1","`focal_xvar_level'.`element'"] ==0 & ///
								reg_errors["r1","`focal_xvar_baselevel'.`element'"] == 0 {
									local ++count
									local focal_string ///
									"`focal_string'+`focal_xvar_level'.`element'"
									local base_string ///
									"`base_string'+`focal_xvar_baselevel'.`element'"
								}
							}

							quietly lincom "(((`focal_string')/`count')-((`base_string')/`count'))"
							matrix `resmat_name'[`matrix_rownum',1] =  ///
							r(estimate),r(se),r(t),r(p),r(lb),r(ub)
						}
						else {
							matrix `resmat_name'[`matrix_rownum',1] =  ///
							0, ., ., ., ., .
						}
						local ++matrix_rownum
					}
					
				}
				
			}
		}

		/* saves the model statistics */
		if "`id'"!= "" {
			matrix `modelstats_name' = `e(N)' \ `e(df_m)' \ `e(df_r)' \ `e(r2)' \ ///
			`e(F)' \ `e(N_clust)'
		}
		else {
			matrix `modelstats_name' = `e(N)' \ `e(df_m)' \ `e(df_r)' \ `e(r2)' \ ///
			`e(F)' \ .			
		}
	}
	
	ereturn clear
	forvalues model_num = 1/`num_models' {
		local resmat_name : word `model_num' of `resmat_names'
		local modelstats_name : word `model_num' of `modelstatsmat_names'
		ereturn matrix `resmat_name' `resmat_name'
		ereturn matrix `modelstats_name' `modelstats_name'	
	}
	ereturn local regress_xvars `regress_xvars'
	ereturn local baselevels `baselevels'
end

program conjoint_disp, eclass
	syntax , xvars(varlist) [subgroup(varname) notable(string) ///
	graph(string) graph2(string) estimate(string) rawcmd(string) ///
	depvar(varname) clustvar(varname) constraints(string) ///
	baselevels(numlist) h0(string)]

 	/* revert default value of H0 */
 	if ("`estimate'" == "mm" & "`h0'" == "-1") local h0 0.5

	//create labels for table (and graph)
	foreach var in `xvars' {
		local var_label: variable label `var'
		if ("`var_label'"=="") local var_label = "`var'"
		local mat_var_label = strtoname("`var_label'")
		local plot_var_labels "`plot_var_labels' "{bf:`var_label'}""
		quietly levelsof `var'
		foreach var_level in `r(levels)' {
			local level_label : label (`var') `var_level'
			local mat_level_label = strtoname("`level_label'")
			local mat_var_labels `mat_var_labels' `mat_var_label'
			local mat_level_labels `mat_level_labels' `mat_level_label'
			local plot_level_labels "`plot_level_labels' `mat_level_label'=	"`level_label'" "
		}
	}
	
	/* create correct titles and graph xline for the est */
	if "`estimate'"=="amce" {
		local tabletitle "Estimated average marginal component effects (AMCEs)"
		local plottitle "Estimated AMCEs"
		local plotxline 0
	}
	else {
		local tabletitle "Estimated marginal means (MMs)"
		local plottitle "Estimated MMs"
		local plotxline `h0'
	}
	
	
	/* convert e(matrics) for results and stats to local to avoid being cleared */
	if "`subgroup'" != "" {
 	    quietly levelsof `subgroup', local(subgroups)
 		foreach sub of local subgroups {
		    local subgroup_label : label (`subgroup') `sub'
			local subgroup_label = strtoname("`subgroup_label'")
			matrix results_`subgroup_label' = e(results_`subgroup_label')
			matrix colnames results_`subgroup_label' = "Est." "SE" "t" "P>|t|" "LCI" "UCI"
			matrix roweq results_`subgroup_label' = `mat_var_labels'
			matrix rownames results_`subgroup_label' = `mat_level_labels'
			matrix modelstats_`subgroup_label' = e(modelstats_`subgroup_label')
		}
	}
	else {
	    matrix results = e(results)
		matrix colnames results = "Est." "SE" "t" "P>|t|" "LCI" "UCI"
		matrix roweq results = `mat_var_labels'
		matrix rownames results = `mat_level_labels'
		matrix modelstats = e(modelstats)
	}	

	/* display table if notable is not entered */
	if "`notable'" == "" {
	    if "`subgroup'" != "" {
			foreach sub of local subgroups {
				local subgroup_label : label (`subgroup') `sub'
				local subgroup_label = strtoname("`subgroup_label'")
				di as text "{hline}"
				di ""
				di as result "`tabletitle' " 
				di as text "`subgroup' = `subgroup_label'"
				di "Number of observations = " modelstats_`subgroup_label'[1,1]
				if ("`clustvar'" != "") di "Number of respondents = " ///
				modelstats_`subgroup_label'[6,1]
				if ("`estimate'" == "mm") di as text "H0 = `h0'"
				matlist results_`subgroup_label', border(rows) ///
				rowtitle(Variable / Levels) format(%8.4f) twidth(25) underscore		
				if "`estimate'" == "amce" & "`constraints'" != "" {
					local newconstraints: subinstr local constraints "i." "", all
					di "Note: constraints between `newconstraints'"
				}
				di ""
			}
		}
		else {
			di ""
			di as result "`tabletitle' " 
			di as text "Number of observations = " modelstats[1,1]
			if ("`clustvar'" != "") di "Number of respondents = " modelstats[6,1]
			if ("`estimate'" == "mm") di as text "H0 = `h0'"
			matlist results, border(rows) rowtitle(Variable / Levels) ///
			format(%8.4f) twidth(25) underscore
			if "`estimate'" == "amce" & "`constraints'" != "" {
				local newconstraints: subinstr local constraints "i." "", all
				di "Note: constraints between `newconstraints'"
			}
		}
	}

	/* display graph if specified */
	if "`graph'`graph2'" != "-1" {
		/* if one plot */
		if "`graph'"=="graph" | "`graph2'"=="0" | "`subgroup'"=="" {
		    /* if one model */
			if ("`subgroup'"=="") local graph_code "(matrix(results[,1])) "
			/* multiple models (one plot) */
			else {
				foreach sub of local subgroups {
					local subgroup_label : label (`subgroup') `sub'
					local subgroup_label = strtoname("`subgroup_label'")
					local graph_code ///
					"`graph_code' (matrix(results_`subgroup_label'[,1]), label(`subgroup_label')) "
				}
			}
			/* plot the single plot */
			quietly coefplot `graph_code', ci((5 6)) keep(*:) xline(`plotxline', ///
			lpattern(-) lcolor(black)) coeflabels(`plot_level_labels') ///
			eqlabels(`plot_var_labels', asheadings) graphregion(col(white)) ///
			scale(0.7) xtitle({bf:`plottitle'})
						
			local graph_output_code "coefplot `graph_code', ci((5 6)) keep(*:) " ///
			"xline(`plotxline', lpattern(-) lcolor(black)) " ///
			"coeflabels("`"`plot_level_labels'"'") eqlabels("`"`plot_var_labels'"'", asheadings) " ///
			"graphregion(col(white)) scale(0.7) xtitle({bf:`plottitle'})"
		}
		/* multiple plots (and models) */
		else {
			foreach sub of local subgroups {
				local subgroup_label : label (`subgroup') `sub'
				local subgroup_label = strtoname("`subgroup_label'")
				local graph_code ///
				"`graph_code' matrix(results_`subgroup_label'[,1]), bylabel(`subgroup_label') ||"
			}
			/* plot the multiple plots */
			quietly coefplot `graph_code', ci((5 6)) keep(*:) xline(`plotxline', lpattern(-) ///
			lcolor(black)) coeflabels(`plot_level_labels') ///
			eqlabels(`plot_var_labels', asheadings) byopts(graphregion(col(white)) ///
			cols(`graph2')) subtitle(, fcolor(gs15)) scale(0.7) xtitle({bf:`plottitle'})
			
			local graph_output_code "coefplot `graph_code', ci((5 6)) keep(*:) " ///
			"xline(`plotxline', lpattern(-) lcolor(black)) coeflabels("`"`plot_level_labels'"'") " ///
			"eqlabels("`"`plot_var_labels'"'", asheadings) byopts(graphregion(col(white)) " ///
			"cols(`graph2')) subtitle(, fcolor(gs15)) scale(0.7) xtitle({bf:`plottitle'})"
		}
	}

	ereturn clear
	/* ereturn results */
	if "`subgroup'" != "" {
		foreach sub of local subgroups {			
			local subgroup_label : label (`subgroup') `sub'
			local subgroup_label = strtoname("`subgroup_label'")
			local subgroup_labels `subgroup_labels' `subgroup_label'
			ereturn scalar N_`subgroup_label' = modelstats_`subgroup_label'[1,1]
			ereturn scalar df_r_`subgroup_label' = modelstats_`subgroup_label'[3,1]
			if "`estimate'" == "amce" {
				ereturn scalar df_m_`subgroup_label' = modelstats_`subgroup_label'[2,1]
				ereturn scalar r2_`subgroup_label' = modelstats_`subgroup_label'[4,1]	
				ereturn scalar F_`subgroup_label' = modelstats_`subgroup_label'[5,1]
			}
			ereturn matrix results_`subgroup_label' results_`subgroup_label'
			/* if clustering used */
			if "`clustvar'" != "" {
				ereturn scalar N_clust_`subgroup_label' = modelstats_`subgroup_label'[6,1]
			}
		}
		ereturn local subgroupvar `subgroup'
		ereturn local subgroups `subgroups'
		ereturn local subgroup_labels `subgroup_labels'
	}
	else {
		ereturn scalar N = modelstats[1,1]
		ereturn scalar df_r = modelstats[3,1]
		ereturn matrix results results
		/* if mm are estimated, seperate models so some stats not reported */
		if "`estimate'" == "amce" {
			ereturn scalar df_m = modelstats[2,1]
			ereturn scalar r2 = modelstats[4,1]
			ereturn scalar F = modelstats[5,1]
		}
		/* if clustering used */
		if "`clustvar'" != "" {
			ereturn scalar N_clust = modelstats[6,1]
		}
	}
	
	ereturn local cmd "conjoint"
	ereturn local cmdline "conjoint `rawcmd'"
	ereturn local depvar `depvar'
	ereturn local title `tabletitle'
	ereturn local model "ols"
	ereturn local indepvars `xvars'
	ereturn local estimate `estimate'
	if "`clustvar'" != "" {
		ereturn local clustvar `clustvar'
		ereturn local vce "cluster"
	}
	else {
		ereturn local vce "ols"
	}
	if ("`graph'`graph2'" != "-1") ereturn local graph_code `graph_output_code'
	if ("`estimate'" == "amce") ereturn local baselevels `baselevels'
	if ("`estimate'" == "amce") ereturn local constraints `constraints'
	if ("`estimate'" == "mm") ereturn scalar h0 = `h0'		
end