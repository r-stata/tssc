*!*** version 1.11.2 06012019

** L256 over(var) conditionn dans average 23/03
** L260 correction display average long_over: line 260 is now ignored and even deleted (29/05/15)  -- 16 apr 2015
** L 305 511 512 1443 proper dealing of missing values -- 23 apr 2015 and 29 may 2015
** L858-900: switching to matrix input in order to avoid string length limit -- 29/5/15
** L753-780: proper identification of varlists in the parser -- 29/5/15
** L268-270: correction average with over and display -- 2/6/15
** L164+142: correction echantillon vide -- 12/6/15
** L261 : improvement error message  -- 09/10/2015
** L88 : correction bug error message when no byvar   -- 09/10/2015		
** option pvalue  in  repest_post_memhold_bylevel and parser and repest_results_reshape and repest_compute_averages-- 25/11/2015
** Multiple over variables possible -- 08/01/2016
** L32,40 option SVYparms added, L710 option svyparms specified -- 06/01/2016
** L452 and following: bug with flags and factor variables fixed -- 06/01/2016

** L32,40 option SVYparms added, L710 option svyparms specified -- 06/01/2016
** L452 and following: bug with flags and factor variables fixed -- 06/01/2016
** PIAAC_variance: changed to 60 replicates if Australia -- 22/01/2016
** over vars: display labels in display, save labels to outfile -- 22/01/2016
** change in variable names in outfile, in the case of single over variable- 
****** no longer includes name of over var, only value (as prefix). Old format: coeff_overname_overvalue_b, New format: _overvalue_coeff_b -- 22/01/2016

** improvements in error messages - 27jan2016

** over, test: to request the opposite difference (first - last), add minus sign (over, -test) - 22 feb 2016
** improvements in error messages (aw vs pweights) - 22 feb 2016
** debugging of over with pvs - 22 feb 2016
** PIAAC eform?
*** betalog option - 22 feb 2016 modified on 22 aug 2016
* corrected bug for flags in combine - 					local name = strltrim(strrtrim("`name'"))
** quantiletable: added random noise to generate quarters 15 sep 2016 
*L254 Correction option fast not working with PV+over+test 21 fev 2017
*PISA 2015 parameters and identifying PISA2015 based on weights mar 2017

** added flags for TALIS in Line 742, 762; adding groupflag_name in TALIS options (L989-990) -- 02/10/2018
** added coverage option to report "coverage" of estimation sample -- 02/10/2018
** modified flagging rule for freq: check only denominator -- 02/10/2018
** corrected bug with coverage when tests are requested
** corrected flagging rule (minimum cases) for TALISSSCH - 29/1/2019
** coverage option with tests made compatible with earlier versions of stata.
**inclusion of TALIS3S - 18/4/2019
*condition on weights being not missing (FLAG) l 794-5

global regressions_command="cnsreg etregress glm intreg nl regress tobit truncreg" ///
	+" sem  stcox  streg biprobit cloglog  hetprobit logistic logit   probit scobit"  /// 
	+" clogit mlogit mprobit ologit oprobit slogit gnbreg nbreg poisson  tnbreg"  ///
	+" tpoisson zinb zip ivprobit ivregress ivtobit heckman heckoprobit heckprobit sureg" 

cap program drop repest
program define repest, eclass 
	gettoken left  right : 0,  parse(",")
	version 11	
	 // we must first deal with potential pv in the if statement in order to trick the syntax command
		local leftbis `:subinstr local left "@" "1", all'
		local nb_left: word count `left'
		forv k=1/`nb_left' {
			local step:word `k' of `left'
 			local list_with_arobas `"`list_with_arobas' `step'"'
			local list_without_arobas `"`list_without_arobas' `=subinstr(`"`step'"',"@","1", .)'"'
			}
	
	local 0 `"`leftbis' `right'"'
 	
 	syntax   name(name=svyname id="data name") [if] [in] ,  ESTimate(string) [ by(string) ///
		over(string) outfile(string) debug(string) results(string) flag display SVYparms(string) betalog(string) fast store(string) coverage pisacoverage]  
		
// ----------------------Parsing of parameters and definition of local variables
// -------------------------------------------------commmon to the whole program
	global svyname= "`svyname'"
	tempname bvar VCOV beta beta_copy VCOV_copy V flags VCOV_d beta_d
	tempfile base_dataset by_level_dataset
	if "`over'" != "" {
		forv i=1/10 {
			tempvar mygroup`i' 
			local list_mygroup "`list_mygroup' `mygroup`i''" 
			qui gen `mygroup`i''=.
			}
		}
	repest_parser  `svyname' `if' `in'  , list_mygroup(`list_mygroup') estimate(`estimate') by(`by') over(`over') outfile(`outfile')   `display'  ifarobas(`list_with_arobas')  svyparms(`svyparms') `fast' store(`store') `coverage' `flag' `pisacoverage'
	foreach local_var in pvalue long_over command_type list_weight over_first over_last  rep_weight_name	final_weight_name  	varlist_to_keep  list_weight  overlevels by_levels by_var variancefactor  ///
			 NBpv pv_here average_levels by_var over_test over_var	type_out display filename command_options  command 	NREP pvvarlist over_var_test store coverage dcoverage flag {
		local `local_var' `"`r(`local_var')'"'
		}
		if `=wordcount("`over_var_test'")'>1 {
			local several_over_var="several_over_var"
			}
	forv k=1/`nb_left' {  // we come back to the arobas syntax in the if statement when we have pv
			local step_wo:word `k' of `list_without_arobas'
			local step_wi:word `k' of `list_with_arobas'
			local if: subinstr local if `"`step_wo'"' `"`step_wi'"',all
			}	
 	foreach global_var in  groupflag_name {
 			global  `global_var' "`r(`global_var')'"
		}
	tempname memhold_all
	tempfile results_all
	local hasposted_ever=0
	foreach mat in bvar_d beta_d beta  bvar {
	local `mat'_list=""
	forval ip = 1(1)`NBpv' {
		if `pv_here'==0 local ip=""
		tempname `mat'`ip' 
		local `mat'_list "``mat'_list' ``mat'`ip''"
		}
	}
	preserve
	qui keep `varlist_to_keep'
	
	tempfile label_dofile
	label save using "`label_dofile'", replace
	if regexm("`if'","@")==0 & "`if'" != "" {
		qui keep `if'
		}
	if "`by_var'" != "" qui tostring `by_var', force replace
	qui save `base_dataset'
	
	**in case of several over variables:
	
	if "`several_over_var'"!="" {
		foreach var in `over_var_test' {
			local label_value_`var' : value label `var'
			foreach over_level in `overlevels' {
					qui levelsof `var'  if ``=regexr("`over_var'","@","1")'' == `over_level' ,  local(`var'_`over_level')
					}
				
			}
		dis "over var is `over_var'"	
		}
	else if  "`over_var'"!="" {
		dis "over var is `over_var'"	
		local label_value_`=regexr("`over_var'","@","PV")' : value label `=regexr("`over_var'","@","1")'
		}
		
// -----------------------------------------------------------------------------
// -----------------------------------------Beginning of the loop over by_levels
			
			//---------------------the loop runs once if the option is irrelevant
			//-------------------------------(by_level, over_levels, pv values),
			//-----------------------------------for all these nested loops 

local firstrun = 1			
foreach by_level in `by_levels' {

	qui use `base_dataset',clear
	local error_everywhere_level="yes"
	local error_test=0
	tempname memhold_errors memhold_bylevel
	if "`flag'"!="" tempname flag_bylevel flag_bylevel_d
	tempfile by_level_dataset results_bylevel errors_bylevel   results_todisplay
	if "`by_var'" != "" {
		qui postfile `memhold_errors' str20(`by_var' over_value)  using `errors_bylevel', replace
		}
	else {
 			qui postfile `memhold_errors' str20(_pooled over_value)  using `errors_bylevel', replace
		}
	
	if "`by_var'" != "" qui keep if `by_var' == "`by_level'" //by_var must be string
 	qui save `by_level_dataset', replace
	
	// -------------------------------------------------------------------------
	// -----------------------------------Beginning of the loop over over_levels
local firstover = 1 
	foreach over_level in `overlevels' {
		if "`over_level'" == "NoOver"  {
			qui use `by_level_dataset', clear
			dis as result _n "`by_level'" _c
		}
		else dis as result _n "`by_level'" " - `over_var' = " "`over_level'" " " _c
		// ---------------------------------------------------------------------
		// --------------------------Beginning of the loop over plausible values
		 
		forval ip = 1(1)`NBpv' {
			if `pv_here'==0 local ip=""
			di "." _c
			foreach param in command command_options results over_var if {
				local `param'_loop: subinstr local `param' "@"  "`ip'", all
				}
			if  "`several_over_var'"!=""  {
				local over_var_loop= "``over_var_loop''"
				}
			if regexm("`if'","@")==1 {
				qui keep `if_loop'
				}
			if regexm("`over_var'","@") == 1 { // if over_var is pvvar change sample at each pv
				qui use `by_level_dataset', clear
				qui keep  if `over_var_loop' == `over_level'
				}
			else if "`over_level'" != "NoOver"  {	// else load sample at first pv only
				if "`ip'" == "1" | "`ip'" == ""{					
					qui use `by_level_dataset', clear
					if  "`several_over_var'"==""  {
						qui keep  if `over_var' == `over_level'
						}
					else {
						qui keep  if ``over_var'' == `over_level'
						}	
					}
				}
			// -----------------------------------------------------------------	
			// -------------------------------Beginning of the loop over weights
									
									//We build here the (nb PV) matrices of (nb BRR) 
									//replicated estimates which are the raw material
									//for the computation of SE (bvar). Same for point 
									//estimates, done with the final  weight (beta)
									//We pass the flag option only for the first
									//turn of this loop and for the first PV
			if "`ip'" != "" {
				if "`fast'" == "fast" & `ip' > 1 local list_weight2 = "`final_weight_name'"
				else local list_weight2 = "`list_weight'"
				} 
			else local list_weight2 = "`list_weight'"
			foreach current_weight in `list_weight2' {
				ereturn clear
									//n_commands compute themselves flags and coverage
						local flag_loop=""
						if "`command_type'"=="special"  {
							if "`command_options_loop'"!="" {
								if "`current_weight'"=="`final_weight_name'" & ("`ip'"=="" | "`ip'"=="1") & "`flag'"!="" {
									local flag_loop="flag"
									}
								}
							else {
								if "`current_weight'"=="`final_weight_name'" & ("`ip'"=="" | "`ip'"=="1") & "`flag'"!="" {
									local flag_loop=", flag"
									}
								} 
							}
  				  cap qui    `command_loop'   `in' [aw = `current_weight'] `command_options_loop' `flag_loop' //Core of the program
				if _rc==101 {
   				 cap qui `command_loop'  `in' [pw = `current_weight'] `command_options_loop' `flag_loop' //Core of the program
				}
				local error_estimate=(_rc!=0 | _N==0)
				local typ_er=_rc
				if `error_estimate'==0 {
					local error_everywhere_level="no"
									//flags for e_commands are computed based on 
									//e(sample) with a special consideration for
									// dummies in regressions.
					if "`current_weight'"=="`final_weight_name'" & ("`ip'"=="" | "`ip'"=="1") & "`flag'"!="" local flag_loop="flag"
					else local flag_loop=""
 					repest_read_flag_results , beta(`beta`ip'') bvar(`bvar`ip'') results(`results_loop') ip("`ip'") pv_here(`pv_here')  current_weight(`current_weight') rep_weight_name(`rep_weight_name') final_weight_name(`final_weight_name')  `flag_loop' pvvarlist(`pvvarlist') `coverage'
					if "`current_weight'"!="`final_weight_name'" matrix `bvar`ip'' = r(bvar_post)
					else if "`current_weight'"=="`final_weight_name'" {
						if "`colnames'"=="" local colnames "`r(colnames)'"
						matrix `beta`ip'' = r(beta_post)
 						if ("`ip'"=="" | "`ip'"=="1") & "`flag'"!="" matrix `flag_bylevel'=r(flags)
						if "${svyname}" == "PIAAC" & ("`ip'"=="" | "`ip'"=="1") & ( "`over_level'"=="`over_first'" | "`over_var'"=="") {
							repest_PIAAC_variancefactor `if_loop' `in' [aw = `current_weight'], nrep(`NREP') by_level(`by_level') // check if JK1, JK2 or pooled
							local variancefactor = r(variancefactor)
							}
						
						}
 					if "`colnames'"=="" local colnames "`r(colnames)'"
					}
					
				else if `error_estimate'==1 {
					if "`over_level'"=="`over_last'" | "`over_level'"=="`over_first'" local error_test=1
					continue, break	
					}
				}
			// -------------------------------------End of the loop over weights
			// -----------------------------------------------------------------
			
									//We create the difference between extreme
									//values of over if requested and 
									//return matrices of BRRs
									// two steps here: 1st, when over_level=first
									// ; when over_level=last
									
			if "`over_test'"=="test" | "`over_test'"=="-test" {
				if "`error_test'"!="1" & ( "`over_level'"=="`over_first'" | "`over_level'"=="`over_last'") {
					if "`fast'"=="fast" {
						 if "`ip'"!="" matrix `bvar`ip''=`bvar1'
						}
					repest_create_diff,overlevel(`over_level') overfirst(`over_first') overlast(`over_last') beta(`beta`ip'') bvar(`bvar`ip'') beta_diff(`beta_d`ip'') bvar_diff(`bvar_d`ip'') flag_d(`flag_bylevel_d')  flag(`flag_bylevel') test(`over_test') `dcoverage'
					matrix `bvar_d`ip''= r(bvar_return)
					matrix `beta_d`ip''= r(beta_return)
 					if "`flag'"!="" matrix `flag_bylevel_d'= r(flags)
					}
				}
			else if "`over_test'"!="" {
				di as error "option over( , `over_test') not allowed"
				error 198
				}
			}	

		// --------------------------------End of the loop over plausible values
		// ---------------------------------------------------------------------
 									//we gather all BRRs to compute estimates and 
									//their standard errors and post these estimates
									//in a  by-level specific dta temporary file
		if  "`error_estimate'"!="1" {
			if "`betalog'" != "" {
				repest_create_betalog, bvarlist("`bvar_list'") betalist("`beta_list'") pvhere("`pv_here'") nbpv(`NBpv') nrep(`NREP') over_level(`over_level') pvvarlist(`pvvarlist')
				if `firstover' == 1 {
					tempname betalogmatrix
					matrix `betalogmatrix' = r(betalog)
					local firstover = 0
					}
				else matrix `betalogmatrix' = (`betalogmatrix' \ r(betalog))
				}
 			repest_create_beta_vcov, bvarlist("`bvar_list'") betalist("`beta_list'") pvhere("`pv_here'") nbpv(`NBpv') variancefactor(`variancefactor') `fast' 
			matrix `VCOV' = r(VCOV)
			matrix `beta' = r(beta)
				local eform=""
				foreach eform_options in `" eform\("' `" eform "' `" hr "' `" shr "' `" irr "' `" or "' `" rrr "' {
				if regexm(" `command_options' ","`eform_options'")==1 local eform="eform"
				}
			repest_post_memhold_bylevel, vcov("`VCOV'") beta("`beta'") memname("`memhold_bylevel'") by_level(`by_level') over_level(`over_level')  tempdata("`results_bylevel'") colnames(`colnames') by_var(`by_var') flag(`flag_bylevel') `pvalue' `eform'
			}
		else if  "`error_estimate'"=="1" post `memhold_errors' ("`by_level'") ("`over_level'") 
		}
		
	// -----------------------------------------End of the loop over over_levels
	// -------------------------------------------------------------------------
	
									//If requested, we compute estimates and 
									//their standard errors for the difference
									//and post them
												
		if "`over_test'"!="" & "`error_test'"!="1" {
			repest_create_beta_vcov, bvarlist("`bvar_d_list'") betalist("`beta_d_list'") pvhere("`pv_here'") nbpv(`NBpv') variancefactor(`variancefactor') `fast'
			matrix `VCOV_d' = r(VCOV)
			matrix `beta_d' = r(beta)
			repest_post_memhold_bylevel, vcov("`VCOV_d'") beta("`beta_d'") memname("`memhold_bylevel'") by_level(`by_level') over_level(d) flag(`flag_bylevel_d') `pvalue' `eform'
			}
		else if "`over_test'"!=""	post `memhold_errors' ("`by_level'") ("d") 
									
									//If there has been any successful estimation
									//for the by_level we reshape the results 
									// database (all statistics for all over_levels
									// in a given by_level in one line
									// and display them if requested
									
	if "`error_everywhere_level'"=="no" {
		postclose `memhold_bylevel' 
		postclose `memhold_errors'
		qui use `results_bylevel', clear
		append using `errors_bylevel'
		if "`over_var'"==""	 drop over_value
		qui save `results_bylevel', replace
		qui save `results_todisplay', replace




		if "`over_var'"!="" {
			if "`by_var'" == "" local by_var "_pooled"
		
			if "`several_over_var'"!="" { // records the correspondence of "over" groups to their meaning in a local string overlabels
			 
				qui levelsof over_value , local(over_levels)
				foreach level in `over_levels' {
					local value_label=""
					foreach var in `over_var_test' {
						local value_label="`value_label'*`var'=``var'_`level''"
						}
					local overlabels="`overlabels' `=substr("`value_label'",2,.)'"
					}
				}
			else {
				qui levelsof over_value , local(over_levels)
				foreach level in `over_levels' {
 						local value_label="`over_var'=`level'"
						local overlabels="`overlabels' `value_label'"
					}
				}

			repest_results_reshape, over_var(`over_var') by_var(`by_var')  `pvalue' //replacefile(`results_bylevel')  
			qui save `results_todisplay', replace 
		
			}
		if "`display'"=="display" {
			repest_display_bylevel, results_bylevel(`results_todisplay') over_var(`over_var') by_var(`by_var') by_level(`by_level') vcov(`VCOV')  overlabels(`overlabels')  `several_over_var'  
			if "`store'"!="" {
				ereturn local cmd="N/A"
				estimates store `store'`=strtoname("`by_level'")'
				}
			}
		if "`long_over'"=="" 		qui save `results_bylevel', replace

		clear
		tempfile betalog`=strtoname("`by_level'")'
		if "`betalog'" != "" {
			qui {
				svmat double `betalogmatrix', names(col)
				gen `by_var' = "`by_level'"
				qui compress
				save `betalog`=strtoname("`by_level'")'', replace
				}
			}
		if	"`hasposted_ever'"=="1" {
			qui use `results_all', clear
			append using `results_bylevel'
			qui save `results_all',replace
			if "`betalog'" != "" {
				qui {
					use `betalog', clear
					append using `betalog`=strtoname("`by_level'")''
					save `betalog', replace
					}
				}
			}
		else if "`hasposted_ever'"=="0" {
			qui use `results_bylevel', replace
			qui	save `results_all', replace
			if "`betalog'" != "" {
					use `betalog`=strtoname("`by_level'")'', clear
					save `betalog', replace
				}
			local hasposted_ever=1
			}		

		}
	else if	"`error_everywhere_level'"=="yes" {
				display " "
				display "   There were no successful estimates for `by_var' = `by_level'."
				display " Consider debugging the command within the estimate option:"
				cap   qui `command_loop'   `in' [aw = `final_weight_name'] `command_options_loop' `flag_loop'
				if _rc==101 {
					display  "`command_loop'   `in' [pw = `final_weight_name'] `command_options_loop' `flag_loop'"
					cap noisily `command_loop'  `in' [pw = `final_weight_name'] `command_options_loop' `flag_loop' //Core of the program
					}
				else {
					display  "`command_loop'   `in' [aw = `final_weight_name'] `command_options_loop' `flag_loop'"
					cap   noisily `command_loop'   `in' [aw = `final_weight_name'] `command_options_loop' `flag_loop'
					}
		}
	}		

// -----------------------------------------------End of the loop over by_levels
// -----------------------------------------------------------------------------
									//If requested we computed averages of stats
									// over by_levels and post it
if "`average_levels'"!="" {
 	tempfile results_average
	repest_compute_averages, data_source(`results_all') data_output(`results_average') average_levels(`average_levels') by_var(`by_var') `long_over' `pvalue' `eform'
	qui use `results_all', clear
	append using `results_average'
	qui save `results_all',replace
	if "`display'"=="display" {
		qui use `results_average', clear
		if "`over_var'"!="" & "`several_over_var'"!=""   {
		repest_results_reshape, over_var(`over_var') by_var(`by_var')  replacefile(`results_todisplay') `pvalue'
		}
		qui save `results_todisplay', replace 
		repest_display_bylevel, results_bylevel(`results_todisplay') over_var(`over_var') by_var(`by_var') by_level(`average_levels') average overlabels(`overlabels')  `several_over_var'  
	if "`store'"!="" {
				ereturn local cmd=" `command_loop'   `in' [aw = `current_weight'] `command_options_loop' if "
				estimates store `store'`=strtoname("`by_level'")'
				}
		}
 	}
	

	if "`outfile'" != ""  {
		qui use `results_all', clear
			 qui do `label_dofile'
 			if  "`several_over_var'"!=""    & "`long_over'"!=""{
				foreach var in `over_var_test' {
						gen `var'=""
					foreach over_level in `overlevels' {
							qui replace `var'=  "``var'_`over_level''"  if over_value == "`over_level'"
						}
						qui destring `var', replace
						label value `var' `label_value_`var''
					}
					drop over_value
				}
				if "`over_var'"!=""	& "`long_over'"!="" &  "`several_over_var'"=="" {
					local var_name= "`=subinstr("`over_var'","@","PV",.)'"
					rename over_value `var_name'
					qui destring `var_name', replace
					label value `var_name' `label_value_`var_name''

					}
 		qui save "`filename'", replace
		if "`pisacoverage'" != "" qui repest_pisacoverage , outfile(`filename')
 		
	}

restore	

end
	
	

* *******************
* Auxiliary Macros *
* *******************


cap program drop repest_compute_averages
program define repest_compute_averages	
	syntax,  data_source(string) data_output(string) average_levels(string) by_var(string) [ long_over eform pvalue]
	if "`long_over'"!="" {
		local by=",by(over_value)"
	}
	
	qui use `data_source'
 	keep if regexm("`average_levels'",`by_var')
 	foreach var of varlist *_se {
				qui replace `var'=`var'*`var'
		qui gen `var'_nb=(missing(`var') == 0)
	}
	collapse (mean) *_b (sum) *_se *_se_nb `by'
	
	foreach var of varlist *_se {
		qui replace `var'=sqrt(`var')/`var'_nb
		}
	drop *_se_nb
	if "`pvalue'"!="" & "`eform'"=="" {
		foreach var of varlist *_se {
			local rad=substr("`var'",1,`=length("`var'")-3')
			qui gen `rad'_pv=2*normal(-abs(`rad'_b/`rad'_se))
			}
		}
	if "`pvalue'"!="" & "`eform'"!="" {
		foreach var of varlist *_se {
			local rad=substr("`var'",1,`=length("`var'")-3')
			qui gen `rad'_pv=2*normal(-abs((`rad'_b-1)/`rad'_se))
			}
		}
	qui gen `by_var'="average"
 	qui save `data_output',replace
	
end

cap program drop regexr_allmatch
program define regexr_allmatch,rclass
syntax, expression(string)  toreplace(string) [replacement(string)]

while regexm("`expression'","`toreplace'")==1 {	
	local expression=regexr("`expression'","`toreplace'","`replacement'")
	}
return local expression="`expression'"
end
	
	 

cap program drop repest_display_bylevel
program define repest_display_bylevel
	syntax, results_bylevel(string)  by_level(string) [by_var(string) several_over_var over_var(string) vcov(string) average overlabels(string) ]
	if "`overlabels'"!="" & "`over_var'"!="" & "`several_over_var'"!="" {
		forv level=1/`=wordcount("`overlabels'")' {
			local label_`level'= word("`overlabels'",`level')
			}
		}
	else if "`overlabels'"!="" {
		foreach label in  `overlabels' {
			if regexm("`label'","(.*)=(.*)") {
				local label_`=regexr("`=regexs(2)'","-","m")'="`label'"
				}
			}
		}
	tempname beta_display se_display 
	qui use `results_bylevel'
 	mkmat *_b, matrix(`beta_display')
 	mkmat *_se, matrix(`se_display')
	local colfullnames=""
	forv i=1/`=colsof(`beta_display')' {
		local omit_flag=((`beta_display'[1,`i'])==. | (`beta_display'[1,`i'])==.f | (`se_display'[1,`i'])==.)
		if "`omit_flag'"=="1" matrix `beta_display'[1,`i']=0
		if "`omit_flag'"=="1" {
			matrix `se_display'[1,`i']=0
			if "`vcov'"!="" & "`over_var'"=="" {
				forv j=1/`=colsof(`beta_display')' {
					matrix `vcov'[`j',`i']=0
					matrix `vcov'[`i',`j']=0
					}
				}	
		}
		local mycolnames:colnames `beta_display'
		local mycolnames : subinstr local mycolnames "c."  "", all
 		local word: word `i' of `mycolnames'
		if regexm("`word'","^_(m?[d0-9]+)_(.*)(_b)")==1 & "`over_var'"!="" {
			if "`omit_flag'"=="1" local colfullnames "`colfullnames'`label_`=regexs(1)'':o.`=regexs(2)' "  
			if "`omit_flag'"=="0" local colfullnames "`colfullnames'`label_`=regexs(1)'':`=regexs(2)' " 
			}
		else if  "`omit_flag'"=="1" local colfullnames "`colfullnames'o.`=regexr(`"`word'"',"_b$","")' "
		else local colfullnames "`colfullnames'`=regexr(`"`word'"',"_b$","")' "
		}
	 
 	matrix `se_display'=diag(`se_display')*diag(`se_display')
 	matrix colnames `beta_display'= `colfullnames'
 	matrix colnames `se_display'= `colfullnames'
	matrix rownames `se_display'= `colfullnames'
	dis _n "`by_var'" " : " "`by_level'"
	if "`over_var'"=="" & "`average=='"=="" {
		 	matrix colnames `vcov'= `colfullnames'
			matrix rownames `vcov'= `colfullnames'
			
			ereturn post `beta_display' `vcov'
	}
	else{
		
		ereturn post `beta_display' `se_display'
	}
	
	if _rc == 504 di as error " ereturn post: matrix has missing values " _c
	else {
		
		ereturn display  
	}
end



cap program drop repest_results_reshape
program define repest_results_reshape,

	syntax, over_var(string) by_var(string) [replacefile(string) pvalue]
	local list_reshape=""
	local suffix_list "*_se *_b"
	if  "`pvalue'"!="" local suffix_list "*_se *_b *_pv"

		foreach var of varlist `suffix_list' {
			if regexm("`var'","(.*)((_b)|(_se)|(_pv))")==1 {
				qui rename `var' __`var' 
				local list_reshape "`list_reshape' _@_`var'"
				}
			}
	qui replace over_value=regexr(over_value,"-","m")
	qui reshape wide `list_reshape', i(`by_var') j(over_value)	string
	if "`replacefile'"!="" qui save `replacefile' ,replace
	
end

cap program drop repest_create_diff
program define repest_create_diff,rclass
syntax, overlevel(string) overfirst(string) overlast(string) beta(string) bvar(string) beta_diff(string) bvar_diff(string) test(string) [flag(string) flag_d(string) coverage]
	tempname bvar_return beta_return flags
		if "`test'" == "test" local t = 1
		else if "`test'" == "-test" local t = -1
				if "`overlevel'"== "`overfirst'" {
					matrix `bvar_return'= -`t'*`bvar'
					matrix `beta_return'= -`t'*`beta'
					if "`flag'"!="" matrix `flags'=`flag'
					}
				if "`overlevel'"== "`overlast'" {
					if "`coverage'" == "" {
						matrix `bvar_return'=  `bvar_diff'+`t'*`bvar'
						matrix `beta_return'= `beta_diff'+`t'*`beta'
						}
					else if "`coverage'" == "coverage" {
						*** make sure coverage of difference is not difference in coverage ****
							local names: colnames `beta', quoted
							local ncols=colsof(`beta')
							tokenize `"`names'"' 
							local dlist ""
							local xlist ""
							forval coeff = 1/`ncols' {
								if regexm("``coeff''","e_coverage") | regexm("``coeff''","^x_") | regexm("``coeff''","_x$") local xlist "`xlist' `coeff'"
								else local dlist "`dlist' `coeff'"
								}
							foreach x in `xlist' {
*								matrix `beta_diff'[1,`x'] = . 
								}
						matrix `bvar_return'=  `bvar_diff'+`t'*`bvar'
						matrix `beta_return'= `beta_diff'+`t'*`beta'	
							foreach x in `xlist' {
								tempname x1 x2 xmin`x'
								scalar `x1' = `beta_diff'[1,`x']
								scalar `x2' = `beta'[1,`x']
								if abs(`x1') < abs(`x2') scalar `xmin`x'' = 1
								else scalar `xmin`x'' = 2
								if `xmin`x'' == 1 {
									matrix `beta_return'[1,`x']= abs(`x1')
									local reps = rowsof(`bvar_return')
									forval i = 1/`reps' {
										matrix `bvar_return'[`i',`x']= `bvar_diff'[`i',`x']					
										}
								}	
								else if `xmin`x'' == 2 {
									matrix `beta_return'[1,`x']= abs(`x2')					
									local reps = rowsof(`bvar_return')
									forval i = 1/`reps' {
										matrix `bvar_return'[`i',`x']= `bvar'[`i',`x']					
										}
									}
							}
						}
					if "`flag'"!="" matrix `flags'=`flag'+`flag_d'
					}	
				return matrix bvar_return=`bvar_return'	
				return matrix beta_return=`beta_return'	
				if "`flag'"!="" return matrix flags=`flags'

	end
	
cap program drop repest_read_flag_results
 program define repest_read_flag_results ,rclass
 syntax, current_weight(string) rep_weight_name(string) final_weight_name(string) beta(string) bvar(string)  [ results(string) ip(string) pv_here(string) flag pvvarlist(string) coverage]
	tempname bvar_post	beta_post flags stats
		local error_everywhere_level="no"
		local results_pv : subinstr local results "@"  "`ip'", all
		if "`coverage'" != "" local coverage "coverage(`current_weight')"
		repest_getresults, est_list(b) `results_pv' `coverage' //format the previous ereturn
		local combine "`r(combine)'"
		local raw_statlab_list "`r(statlab_list)'"
		local colnames "`r(statlab_list)'"
		matrix `stats' = r(stats)
		if "`pv_here'"=="1" {
			foreach pvvar in `pvvarlist' {
				local pvparm = regexr("`pvvar'","@","`ip'")
				local pvlabel = regexr("`pvvar'","@","_")
				local colnames : subinstr local colnames "`pvparm'"  "`pvlabel'", all
				}
			}
		else local colnames "`r(statlab_list)'"
		local nbcol :  word count "`colnames'" 
		if "`current_weight'"=="`final_weight_name'" matrix `beta_post' = r(stats)
		else if "`current_weight'"=="`rep_weight_name'1" matrix `bvar_post' = r(stats) - `beta'
		else matrix `bvar_post' = [`bvar' \ r(stats) - `beta']
		if "`flag'"!="" &  "`e(flags)'"!="" matrix `flags'=e(flags)
 		else if "`flag'"!="" &  "`e(flags)'"=="" & regexm("${regressions_command}", "`e(cmd)'")==0 {
 			repest_flags if e(sample)==1
			matrix `flags'=J(1,`nbcol',`r(flag)')
			}
		else if "`flag'"!="" &  "`e(flags)'"=="" & regexm("${regressions_command}", "`e(cmd)'")==1 {
 			repest_flags   if e(sample)==1
			foreach stat in `raw_statlab_list' {
						local statname = strtoname("`stat'")
						scalar `statname'_f= `r(flag)'
						if "`flag_list'"=="" {
						local flag_list "`statname'_f"
							}
						else {
							local flag_list "`flag_list' , `statname'_f"
							}
						}
			foreach regressor in `:colnames e(b)' {
				foreach stat in `raw_statlab_list' {
					if regexm("`stat'","`regressor'")==1 & "`regressor'"!="_cons" {
						local statname = strtoname("`stat'")
						local regressor = regexr("`regressor'","b\.",".")
						repest_flags `regressor' if e(sample)==1, binarytest
						scalar `statname'_f= `r(flag)'
						}
					}
				}
 
 				matrix `flags'=[`flag_list']
 			}
			
 		if "`combine'" != "" & "`flag'"!="" {
 			tokenize "`combine'", parse(";")
			local current 1
			
			while "``current''" != "" {
				if "``current''" != ";" {
					gettoken name `current' : `current',  parse(":")
					local name = strltrim(strrtrim("`name'"))
					gettoken equals myexp : `current',  parse(":")
					local flag_combine=0
					if `"`name'"'==":" {
						di as error `"invalid name"'
						exit 198
						}
					capture confirm name `name'
					if _rc {
						di as err `"invalid name: `name'"'
						exit 198
						}
					local nstats:   word count `colnames'
					forval i = 1/`nstats' {
						local stat: word `i' of `colnames'
						if regexm(`"`myexp'"',"_b[`stat']")==1 	local flag_combine=`=max(`flag_combine', `flags'[1,`i'])'
						if "`stat'"=="`name'" {
							cap matrix `flags'[1,`i']=`flag_combine'
							if _rc==503  matrix `flags'=[`flags',`flag_combine']
							}
						}
				}
				local current = `current' + 1

			}
 			}
		if  "`flag'"!="" return matrix flags=`flags'
		if "`current_weight'"!="`final_weight_name'" return matrix bvar_post=`bvar_post'				
		if "`current_weight'"=="`final_weight_name'" return matrix beta_post=`beta_post'
		return local colnames "`colnames'"
		return matrix stats = `stats'
end

cap program drop repest_flags
program define repest_flags,rclass
	syntax [varlist(default=none fv)]  [if] [in] [pweight aweight]  ,    [mingroups(integer 5) minind(integer 30) binarytest] 
	if "${svyname}"=="TALISTCH" | "${svyname}"=="STAFF_TALISEC" | "${svyname}"=="TALISEC_LEADER" local mingroups = 10
	if "${svyname}"=="TALISSCH" | "${svyname}"=="LEADER_TALISEC" | "${svyname}"=="TALISEC_LEADER" local minind = 10
  	if "`varlist'"!="" {
		if "`if'"!="" local if="`if' & missing(`varlist')==0 & missing(`=substr("`exp'",2,.)')==0"
		if "`if'"=="" local if="if missing(`varlist')==0 & missing(`=substr("`exp'",2,.)')==0"
		}
	if  "`binarytest'"!="" & "`varlist'"!="" {
		qui su `varlist' `if'
		local min_value=r(min)
		local max_value=r(max)
		capture assert inlist(`varlist',`min_value',`max_value') `if'
		local isbinary= (_rc==0)
		}
	if "${svyname}"=="PISA" | "${svyname}"=="PISA2015" | "${svyname}"=="TALISTCH" | "${svyname}"=="IELS"  | "${svyname}"=="STAFF_TALISEC" | "${svyname}"=="TALISEC_LEADER" {	
		if "`binarytest'"!="" & "`isbinary'"=="1" & "`varlist'"!="" {
			qui count  `if' & `varlist'==`min_value'
			local nobs0 = r(N)
			cap tab ${groupflag_name}   `if' & `varlist'==`min_value', nofreq
			local ngrp0 = r(r)
			qui count  `if' & `varlist'==`max_value'
			local nobs1 = r(N)
			cap tab ${groupflag_name}  `if' &  `varlist'==`max_value', nofreq
			local ngrp1 = r(r)
			return local flag = (`nobs1' < `minind' | `ngrp1' < `mingroups' | `nobs0' < `minind' | `ngrp0' < `mingroups' )
			}
		else  {
			qui	count  `if'
			local nobs = r(N)
			qui tab ${groupflag_name} `if' , nofreq
			local ngrp = r(r)
			return local flag = (`nobs' < `minind' | `ngrp' < `mingroups'  )
			}
		}	
	if "${svyname}"=="PIAAC" | "${svyname}"=="TALISSCH" | "${svyname}"=="PISAOOS" | "${svyname}"=="LEADER_TALISEC" | "${svyname}"=="TALISEC_LEADER" {			
		if "`binarytest'"!="" & "`isbinary'"=="1" & "`varlist'"!="" {
			qui count  `if' & `varlist'==`min_value'
			local nobs0 = r(N)
			
			qui count  `if' & `varlist'==`max_value'
			local nobs1 = r(N)
			
			return local flag = (`nobs1' < `minind'  | `nobs0' < `minind')
			}
		else  {
			qui	count  `if'
			local nobs = r(N)
			return local flag = (`nobs' < `minind'   )
			}
		}	
 end


cap program drop repest_create_beta_vcov
program define repest_create_beta_vcov,rclass
		syntax , bvarlist(string) betalist(string) pvhere(string) nbpv(integer) variancefactor(real)  [fast]
			tempname bvar_bis beta VCOV
				forv ip = 1(1)`nbpv' {
					mata :	`bvar_bis' = (st_matrix("`=word(`"`bvarlist'"', `ip')'"))
					mata: st_matrix("`=word(`"`bvarlist'"', `ip')'",(`bvar_bis''*`bvar_bis')*`variancefactor')
					}
				if "`pvhere'"=="1" {
					
					repest_PVvariance, nbpv(`nbpv') betas(`betalist') vcovs(`bvarlist') `fast'
					matrix `VCOV'= r(VCOV)
					matrix `beta' = r(beta)
					return matrix VCOV = `VCOV'
					return matrix beta = `beta'
				}
				else {
					return matrix VCOV = `bvarlist'
					return matrix beta = `betalist'
				}
end

cap program drop repest_create_betalog
program define repest_create_betalog,rclass
		syntax , bvarlist(string) betalist(string) pvhere(string) nbpv(integer)  nrep(integer) over_level(string) [pvvarlist(string)]
		tempname pv weight betalog replog over
				forv ip = 1(1)`nbpv' {
					tempname betalog`ip'
					local b = word(`"`betalist'"', `ip')
					local rep = word(`"`bvarlist'"', `ip')
					matrix `replog' = J(`nrep',1,1)*`b'+ `rep'
					matrix `betalog`ip'' = (`b' \ `replog')
					if "`pvhere'"=="1" {
						matrix `pv' = J(rowsof(`betalog`ip''),1,`ip')
						matrix colnames `pv' = "pv"
						matrix `betalog`ip'' = (`betalog`ip'',`pv')
						}
					matrix `weight' = J(rowsof(`betalog`ip''),1,.)
					forval i = 0(1)`nrep' {
						local j = `i' + 1
						matrix `weight'[`j',1] = `i' 
						}
					matrix colnames `weight' = "weight"
					matrix `betalog`ip'' = (`betalog`ip'',`weight')
					if "`over_level'" != "NoOver" {
						matrix `over' = J(rowsof(`betalog`ip''),1,`over_level')
						matrix colnames `over' = "over_level"
						matrix `betalog`ip'' = (`betalog`ip'',`over')
						}
					if `ip' == 1 matrix `betalog' = `betalog`ip''
					else if "`pvhere'"=="1"  matrix `betalog' = (`betalog' \ `betalog`ip'')
					}
		if "`pvhere'"=="1" {
			local colnames : colnames `betalog'
			foreach pvvar in `pvvarlist' {
				local pvparm = regexr("`pvvar'","@","1")
				local pvlabel = regexr("`pvvar'","@","_")
				local colnames : subinstr local colnames "`pvparm'"  "`pvlabel'", all
				}
			}
			matrix colnames `betalog' = `colnames'
		return matrix betalog  = `betalog'
end

cap program drop repest_gen_memhold_bylevel	
program define repest_gen_memhold_bylevel,rclass
	syntax, tempdata(string) memname(string) colnames(string) [by_var(string) pvalue ]
	if "`by_var'" == "" local by_var "_pooled"
	local output_names ""
			foreach name in `colnames' {
				local lab=strtoname(abbrev("`name'",28)) //I have changed the limit here because of triple interactions
				if "`pvalue'"=="" {
					local output_names  "`output_names' `lab'_b `lab'_se "
					}
				if "`pvalue'"!="" {
					local output_names  "`output_names' `lab'_b `lab'_se `lab'_pv"
					}
 				}
		qui postfile `memname' str20 `by_var' str20 over_value  double(`output_names') using `tempdata', replace
	end		

cap program drop repest_post_memhold_bylevel	
program define repest_post_memhold_bylevel
	syntax, memname(string) beta(string) vcov(string) by_level(string) over_level(string) [tempdata(string) colnames(string) by_var(string) flag(string) pvalue eform]
	tempname se 
	mata: `se'= sqrt(diagonal(st_matrix("`vcov'")))
	mata: st_matrix("`se'",`se'') //we must transpose
	local output ""
	local nc = colsof(`beta')
	if "`flag'"!=""{
		forval i = 1/`nc' {
			if `flag'[1,`i'] {
				if !missing(`beta'[1,`i']) matrix `beta'[1,`i']==.f
				if !missing(`se'[1,`i']) matrix `se'[1,`i']==.f
				}
				
			}
		}
	forval i = 1/`nc' {
		if "`pvalue'"=="" {
			local output "`output' (`beta'[1,`i']) (`se'[1,`i'])"
			}
		if "`pvalue'"!="" & "`eform'"=="" {
		
			cap local output "`output' (`beta'[1,`i']) (`se'[1,`i']) (2*normal(-abs(`beta'[1,`i']/`se'[1,`i'])))"
			if _rc!=0 {
						cap local output "`output' (`beta'[1,`i']) (`se'[1,`i']) (.)"
				}
			}	
		if "`pvalue'"!="" & "`eform'"!="" {
		
			cap local output "`output' (`beta'[1,`i']) (`se'[1,`i']) (2*normal(-abs((`beta'[1,`i']-1)/`se'[1,`i'])))"
			if _rc!=0 {
						cap local output "`output' (`beta'[1,`i']) (`se'[1,`i']) (.)"
				}
			}		
		}
		
	cap post `memname' ("`by_level'") ("`over_level'") `output'  
	if _rc!=0 {
		repest_gen_memhold_bylevel , tempdata(`tempdata') memname(`memname') colnames(`colnames') by_var(`by_var') `pvalue'
		local over_label  "`over_level'"
		post `memname' ("`by_level'") ("`over_label'") `output'  	
		}
 end
		 
	 
cap program drop repest_parser
program define repest_parser, rclass
	syntax   name(name=svyname id="data name") [if] [in] [ , list_mygroup(namelist)  estimate(string) by(string) ///
	over(string) outfile(string)  display  ifarobas(string) svyparms(string) fast store(string) coverage flag pisacoverage]
	*estimate
	if "`pisacoverage'" != "" local coverage "coverage"
	if regexm("`over'","test") local dcoverage "coverage" // coverage always needed if over, test
	forv i=1/10 {
		local mygroup`i'=word("`list_mygroup'",`i')
		}
	if substr("`estimate'",1,5)=="stata" {
		gettoken trash  command  : estimate , parse( ":")
		gettoken command  command_options : command,  parse(",")
		gettoken trash  command : command,  parse( ":") // we get rid of the ":" in the command option

		}
	else if regexm("`estimate'","(^summarize)|(^freq)|(^means)|(^quantiletable)|(^corr)") {
	gettoken command  command_options :  estimate , parse( ",")
		local command  "repest_`command'"
 		local command_type="special"
		if "`coverage'" != "" {	// for n_cmds, coverage is a command option
			if "`command_options'"!="" {
				local command_options "`command_options' `coverage'" 
				}
			else  {
				local command_options ",  `coverage'"
				}
			local coverage "" // blank out overall coverage option
			}
		if regexm("`command'","repest_quantiletable") & regexm("`command_options'","( relr)|( odds)|( su)|( reg)") & "`flag'" != ""{
				di as err `"Warning: option "flag" has been suppressed!"'
				di as err `"         flags only work with quantiletable without options RELRisk ODDSratio SUmmarize REGress "'
				local flag ""
				}
		}	
	else {
		error 198
		}
	
	if regexm("`estimate'","^freq") & regexm("`command_options'", "levels\(")==0 {
			if regexm("`command'","(.*)(freq)(.*)") local varname=regexs(3)
			local varname=regexr("`varname'","@","1")
			qui levelsof `varname', local(temp) clean
			if "`command_options'"!="" local command_options "`command_options' levels(`temp')"
			else   local command_options ",levels(`temp')"
 			}
	*other parameters
	if  "`store'"!="" {
		local display="display"
		}
	gettoken filename type_out : outfile, parse(",")
	if "`filename'"=="" local display "display" // if no outfile requested, display results
	gettoken trash type_out : type_out, parse(",")	// we get rid of the "," in the type option
	gettoken over_var over_test : over, parse(",")
	gettoken trash over_test : over_test, parse(",") // we get rid of the "," in the over_levels option
	local over_test = strtrim("`over_test'") // get rid of leading and trailing blanks
	gettoken by_var by_options : by, parse(",")
	gettoken outfile outfile_options : outfile, parse(",")
	
	if regexm("`outfile_options'","long_over")==1 local long_over="long_over"
	if regexm("`outfile_options'","pvalue")==1 local pvalue="pvalue"

	if regexm("`by_options '","levels\(([^\)]*)")   local by_levels=regexs(1)
	if regexm("`by_options '","average\(([^\)]*)")   local average_levels=regexs(1)
 	local pv_here=regexm("`estimate' `ifarobas' `over_var'","@")
 	*we define here also PISA, PIAAC, TALIS, ALL and IALS parameters ** version 1.11.1:  PISAOOS and IELS added
		*NBpv tells how many turns the main loop has. it's only one loop when there are no variable with plausible values
		if "${svyname}"=="PISA" {
			tempname confirm_min confirm_maj

			cap confirm variable  w_fstuwt w_fstr1
			local `confirm_min'=_rc
			cap confirm variable  W_FSTUWT W_FSTR1
			local `confirm_maj'=_rc

 			if !(``confirm_maj''==0 |  ``confirm_min''==0) {
				global svyname="PISA2015"
				dis "Survey parameters have been changed to PISA2015"
				}
			}
		
		if "${svyname}"=="PISA" {
			local NBpv=5*(`pv_here'==1)+1*(`pv_here'==0)
			local final_weight_name="w_fstuwt"
			local rep_weight_name="w_fstr"	
			local variancefactor=1/20
			local NREP = 80
			local groupflag_name="schoolid"
			local keepsvy "cnt schoolid"
				}
		else if "${svyname}"=="TALISTCH" {
			local NBpv=1
			local final_weight_name="tchwgt"
			local rep_weight_name="trwgt"	
			local variancefactor=1/25
			local NREP = 100
			local groupflag_name="idschool"
			local keepsvy "cntry idschool"
			}
			
		else if "${svyname}"=="PISA2015" {
				local NBpv=10*(`pv_here'==1)+1*(`pv_here'==0)
			local final_weight_name="w_fstuwt"
			local rep_weight_name="w_fsturwt"	
			local variancefactor=1/20
			local NREP = 80
			local groupflag_name="cntschid"
			local keepsvy "cnt cntschid"
			}

		else if "${svyname}"=="TALISSCH" {
			local NBpv=1
			local final_weight_name="schwgt"
			local rep_weight_name="srwgt"	
			local variancefactor=1/25
			local NREP = 100
			}
		else if "${svyname}"=="PIAAC" {
			local NBpv=10*(`pv_here'==1)+1*(`pv_here'==0)
			local final_weight_name="spfwt0"
			local rep_weight_name="spfwt"	
			local variancefactor=. //set later
			local NREP = 80
			local keepsvy "vemethodn"
			}
		else if "${svyname}"=="ALL" | "${svyname}"=="IALS" {
			local NBpv=10*(`pv_here'==1)+1*(`pv_here'==0)
			local final_weight_name="weight"
			local rep_weight_name="REPLIC"	
			local variancefactor = 1 
			local NREP = 30
			}
		else if "${svyname}"=="IELS"  {
			local NBpv=5*(`pv_here'==1)+1*(`pv_here'==0)
			local final_weight_name="CHILDWGT"
			local rep_weight_name="SRWGT"	
			local variancefactor = 1/23
			local NREP = 92
			local groupflag_name="IDCENTRE"
			local keepsvy "IDCENTRE"
			}
		else if "${svyname}"=="PISAOOS" {
			local NBpv=10*(`pv_here'==1)+1*(`pv_here'==0)
			local final_weight_name="spfwt0"
			local rep_weight_name="spfwt"	
			local variancefactor = 29/30 
			local NREP = 30
			}
		else if "${svyname}"=="LEADER_TALISEC" | "${svyname}"=="TALISEC_LEADER"{
			local NBpv=1
			local final_weight_name="cntrwgt"
			local rep_weight_name="crwgt"	
			local variancefactor=1/23
			local NREP = 92
			}
		else if "${svyname}"=="STAFF_TALISEC" | "${svyname}"=="TALISEC_STAFF"{
			local NBpv=1
			
			local final_weight_name="staffwgt"
			local rep_weight_name="srwgt"	
			local variancefactor=1/23 
			local groupflag_name="idcentre"
			local keepsvy "idcentre"
			local NREP = 92
			}
		else if "${svyname}"!="SVY" error 198
		if "`svyparms'" != "" {
			foreach val in NBpv final_weight_name rep_weight_name variancefactor NREP {
			if regexm("`svyparms'","`val'\(([^\)]*)")  {
				local `val'=regexs(1)
				local modified "`modified'  `val'"
				}
			}
			local NBpv=`NBpv'*(`pv_here'==1)+1*(`pv_here'==0)
			if wordcount("`modified'") == 0 {
				di as error "warning: option svyparms contains unknown parameters as suboptions"
				di as error "          valid suboptions are:"
				di as error "          NBpv, final_weight_name, rep_weight_name, variancefactor, NREP"
				}
			}
		else if "${svyname}"=="SVY" {
			di as error "option svyparms required with repest SVY"
			error 198
			}
		
	if "`by_levels'"=="" {
		if "`by_var'" != "" {
			levelsof `by_var', local(by_levels) 
			}
		else local by_levels  = "_pooled"
		}
	local by_levels : list clean by_levels
	
	if "`over_var'" != "" & `=wordcount("`over_var'")'<2 {
		if regexm("`over_var'","@") == 1 	local over_var_test = regexr("`over_var'","@","1")
		else local over_var_test "`over_var'"
		cap confirm numeric variable `over_var_test'
		if !_rc {
			qui levelsof `over_var_test', local(overlevels)
			local over_first =  word("`overlevels'",1)
			local over_last =  word("`overlevels'",-1)
			di as result " over `over_var' = `overlevels' " 
			}
		else di as error "option over() only allows numeric variables"
		}
	else 	local overlevels="NoOver"
		
	*we get the list of all weights rep and final
		local list_weight "`final_weight_name'"
		forv i=1/`NREP'  { 
			local list_weight  "`list_weight' `rep_weight_name'`i'"
			}
		local 	varlist_to_keep "`list_weight'"
		
			***we define the list of variables to keep 
		*to be adapted to PIAAC and PISA
		
		*we screen the estimate and if options looking for variable names
		local list_words_command   `"`estimate' `ifarobas'"'

		// punctuation marks 
		local list_words_command: subinstr local list_words_command  " -"  "-", all			
		local list_words_command: subinstr local list_words_command  "- "  "-", all			
		foreach op in ( ) , != = & | <- -> < > { 
			local list_words_command: subinstr local list_words_command  "`op'"  " ", all			
			}
		// fvvarlist operators: 
		foreach op in c. i. # {
			local list_words_command: subinstr local list_words_command  "`op'"  " ", all
			}
		foreach word in `list_words_command' `over_var' {
			if regexm("`word'","(.*)\.(.*)") {
				local word=regexs(2)  
				}
			
		// fvvarlist operators: 
			
				
			* we expand lists of plausible values
			if regexm("`word'","@") == 1 {
				local pvvarlist   "`pvvarlist' `word'"
				forv i=1/`NBpv' { //we generate plausible value variables names
					local var_to_keep=subinstr("`word'","@","`i'", .) 
					local varlist_to_keep "`varlist_to_keep' `var_to_keep'"
					}
				}
				
			else {
				cap fvunab extended_word: `word'
				if _rc==0 {
					foreach subword in `extended_word' {
					
						if regexm("`subword'","(^[i|o|f|l|d][^\.]*)\.(.*)") {
							local subword=regexs(2)
						} 
						local varlist_to_keep "`varlist_to_keep' `subword'"
						}	
					}
				}		
			}
			// words with varlist operators are varlists, unless already kept as pv
			

		local varlist_to_keep "`varlist_to_keep' `by_var' `keepsvy' "
 		if "`over_var'" != "" & `=wordcount("`over_var'")'>1 {
			local long_over="long_over"
			if regexm("`over_var'","@") == 1 {
				 local over_var_test = subinstr("`over_var'","@","1",.)
 					 cap drop `mygroup1'
					 egen `mygroup1'=group(`over_var_test')
 					tempvar  tag
					local varlist_to_keep "`varlist_to_keep'  `mygroup1' "
					qui levelsof `mygroup1', local(overlevels)
					foreach var in `over_var_test' {
							foreach over_level in `overlevels' {
								qui levelsof `var'  if `mygroup1' == `over_level' ,  local(`var'_`over_level')
								}
						}
		
				forv i=2/`NBpv' {
						foreach over_level in `overlevels' {
							cap drop `tag'
							gen `tag'=1
							foreach var in  `over_var' {
									local varpv=regexr("`var'","@","`i'")
									local var1=regexr("`var'","@","1")

								qui replace `tag'=`tag'*(string(`varpv')=="``var1'_`over_level''")
								
								}
							qui replace `mygroup`i''=`over_level' if `tag'==1
							}
							local varlist_to_keep "`varlist_to_keep'  `mygroup`i'' "
						}
 						local over_var "mygroup@"

				}
 				
			else {
					cap drop `mygroup1'
					egen `mygroup1'=group(`over_var')
					local over_var_test "`over_var'"
					local over_var "mygroup1"
					local varlist_to_keep "`varlist_to_keep'  `mygroup1' "

				}
			if !_rc {
				qui levelsof `mygroup1', local(overlevels)
				local over_first =  word("`overlevels'",1)
				local over_last =  word("`overlevels'",-1)
				di as result " over `over_var' = `overlevels' " 
				}
			else di as error "option over() only allows numeric variables"
			}

	
	*string
	foreach output in long_over pvalue command_type groupflag_name overlevels by_levels by_var   rep_weight_name over_first over_last ///
			final_weight_name   average_levels by_var over_test over_var	type_out display filename command_options  over_var_test fast ///
			command	varlist_to_keep	list_weight pvvarlist store coverage dcoverage flag pisacoverage {
		return local `output' `"``output''"'
		}
	foreach output in		pv_here  variancefactor NBpv NREP {
			return local `output'=``output''
		}
end



cap program drop repest_PIAAC_variancefactor
program define repest_PIAAC_variancefactor, rclass
	syntax [if] [in] [aweight]  [,  nrep(integer 80) by_level(string)] // check if JK1, JK2 or pooled

	qui tab1 vemethodn `if' `in'
	if r(r) == 1 {		// if all obs are either JK1 or JK2
		if vemethodn[1] == 1 local variancefactor = (`nrep'-1)/`nrep'
		if vemethodn[1] == 1 & inlist("`by_level'","Australia","AUS","36")==1 {
			local variancefactor = (min(`nrep',60)-1)/min(`nrep',60)
			if `nrep'>60 di as res "warning: number of replicates for Australia in PIAAC = 60 (for Jacknife 1 calculations)"
			}
		if vemethodn[1] == 2 local variancefactor = 1 
		}
	else {				// if JK1 and JK2 countries are pooled
		tempvar sample
		cap gen `sample' = e(sample) `if' `in'
		qui levelsof `sample' `if' `in'
		if "`r(levels)'" == "0 1"  { 	// if estimation command sets sample, and some obs are excluded
			su vemethodn [aw `exp'] if `sample' `in', meanonly
			}
		else { 						// if estimation command does not set sample, or all obs are excluded
			su vemethodn [aw `exp'] `if' `in', meanonly
			}
		local variancefactor = (`nrep'-(2-r(mean)))/`nrep'
		}
	return scalar variancefactor = `variancefactor'
end


cap program drop repest_getresults
program define repest_getresults , rclass
	syntax , est_list(string) [Keep(string) Add(string) COMbine(string) coverage(string)]
	cap confirm matrix e(b)
	if _rc == 111 di as error "option estimate does not contain an estimation command; only eclass commands that set e(b) can be used"
 	local stats_list=""
	local statlab_list=""
	local quot `"""'
	local command= "`e(cmdline)'"
	gettoken trash cmdoptions : command ,parse(",")
	gettoken trash cmdoptions : cmdoptions ,parse(",")
	local eform=0
	foreach eform_options in `" eform\("' `" eform "' `" hr "' `" shr "' `" irr "' `" or "' `" rrr "' {
		if regexm(" `cmdoptions' ","`eform_options'")==1 local eform=1
		}
		
	***
	local b_names : colfullnames e(b)
	tempname res
	local res_names : subinstr local b_names ":"  "_", all
	matrix `res' = e(b)
	local n = colsof(`res')
	*we replace omitted estimation by a blank value
	forv i=1/`n' {
		local step :word `i' of `res_names'
		if regexm("`step'" , "o\.")==1 matrix `res'[1,`i']==.

		}	
		
 	local res_names :subinstr local res_names "o." ""  ,all 
	local res_names :subinstr local res_names "." "_"  ,all
	matrix colnames `res' = `res_names'
	matrix coleq `res' = ""
	***
	if  "`keep'"!="" {
		local res_names="`keep'"
		}
	tempname results
 
  	foreach stat in `est_list' `add'{
			if  "`stat'"=="`est_list'" { // `est_list' is always equal to "b"
			foreach coef in `res_names' {
			if `eform'==1 {
					local nb_word: word count `res_names'
					forval i = 1/`nb_word' {
						local step: word `i' of `res_names'
						if "`step'"=="`coef'" {
								local  lamf =exp(`res'[1,`i'])
								local stats_list "`stats_list' `lamf'" 
							}
						}
					}
				else {
				
						local lamf_temp= `" `res'[1,""' + `"`coef'"' +`""]"'
					matrix  lamf= [`lamf_temp']

					local stats_list `=`"`stats_list' "'+"`=lamf[1,1]'"' 
					}
				
			 
			}
			}
		else {	
				local lamf `=e(`stat')'
				local stats_list `"`stats_list' `lamf'"'
				local res_names "`res_names' e_`stat'"
			}
		}	
* 	local res_names `:subinstr local res_names "," ""  ,all' 
	local res_names `:subinstr local res_names "o." ""  ,all'
 	matrix input `results' =(`stats_list')
	matrix colnames  `results' = `res_names'	
	****
	* combination of results:
	if "`combine'" != "" {
			tokenize "`combine'", parse(";")
	
			local current 1
 			while "``current''" != "" {
				if "``current''" != ";" {
					gettoken name `current' : `current',  parse(":")
					gettoken equals myexp : `current',  parse(":")
					if `"`name'"'==":" {
						di as error `"invalid name"'
						exit 198
						}
					capture confirm name `name'
					if _rc {
						di as err `"invalid name: `name'"'
						exit 198
						}
					local nstats: word count `res_names'
					forval i = 1/`nstats' {
						local stat  :word `i' of `res_names'
						local myexp : subinstr local myexp "_b[`stat']" "`results'[1,`i']", all
						}
						
					tempvar `name'
					matrix ``name'' = `myexp'
					local colnames_results : colnames `results'
					matrix `results' = [`results',``name'']
					local res_names  "`res_names' `name'"
					matrix colnames `results'  = `colnames_results' `name'
					}
				local current = `current' + 1
				}
			}
 	****
 	****
	* coverage
	if "`coverage'" != "" {
					tempvar sample
					gen `sample' = e(sample) 
					su `sample' [aw = `coverage'], meanonly 
					tempname sample
					matrix `sample' = r(mean)
					local colnames_results : colnames `results'
					matrix `results' = [`results',`sample']
					local res_names  "`res_names' e_coverage"
					matrix colnames `results'  = `colnames_results' e_coverage
			}
****

	local coln= colsof(`results')
	return scalar ncoeff =`coln'
	return local combine "`combine'"
	return matrix stats =`results'
	return local statlab_list "`res_names'"
end
 

cap program drop repest_PVvariance
program define repest_PVvariance, rclass
 	syntax , nbpv(integer) betas(string) vcovs(string) [, fast] 
	
	if (wordcount("`betas'") !=  wordcount("`vcovs'")) | wordcount("`betas'") != `nbpv' {
		error 197
		}
	tokenize `vcovs'
 
 	local sum_beta = subinstr(trim("`betas'"), " ", " + ", .)
 	local sum_vcov = subinstr(trim("`vcovs'"), " ", " + ", .)
 
	tempname b b_dev IMPV SV VCOV
	matrix `b' = (`sum_beta') / `nbpv'
	foreach beta in `betas' {
		local dev_beta = "`dev_beta'" + "(`b' - `beta')" + " \ "
		}
	local dev_beta = regexr("`dev_beta'", "\\.$" ,"")
	matrix `b_dev' = (`dev_beta')
	matrix `IMPV' = (`b_dev'' * `b_dev') / (`nbpv' - 1)
	if "`fast'" == "" matrix `SV' = (`sum_vcov') / `nbpv'
 	else matrix `SV' = `1' 
	matrix `VCOV' = `SV' + ((`nbpv' + 1)/`nbpv') * `IMPV'
 	return matrix beta = `b'
	return matrix VCOV = `VCOV'
 end


cap program drop repest_replace_omit_res 
program repest_replace_omit_res , rclass
	syntax namelist(name = beta id = "beta")
	* we deal with omitted statistics:
	local nb_cols=colsof(`beta')
	local betanames : colfullnames `beta'
	local new_betanames=""
	forv i=1/`nb_cols' {
		local step: word `i' of `betanames'
		if `beta'[1,`i']==. {
			matrix `beta'[1,`i']=0
			if  regexm("`step'", "\:" ) {
					local new_betanames "`new_betanames' `=regexr("`step'", "\:", ":o.")' "
					}
				else {
					local new_betanames "`new_betanames' o.`step'"
					}
			}
		else local new_betanames "`new_betanames' `step'"
		}
	return matrix beta = `beta'
 

	return local betanames  "`new_betanames'"
 
end

* ***** *
* MEANS *
* ***** *

cap program drop  repest_means
program define  repest_means, eclass
	syntax varlist [if] [in] [aweight pweight] [, flag pct coverage]

	local pct =  ("`pct'"!="")
 
	foreach var in `varlist' {
	 
		cap confirm numeric variable `var'
		if !_rc {
			tempname `var'_m `var'_f
			qui: su `var' [aw `exp'] `if' `in' , meanonly 
			scalar ``var'_m' = (100^`pct')*r(mean)
			if "`stat_list'"=="" {
								local lamf `"``var'_m'"'
									}
								else {
									local lamf `", ``var'_m'"'
								}
								
			local stat_list   "`stat_list' `lamf'   "
 			local name_list   "`name_list' `var'_m"  
			if "`flag'" !=""  {
			 	repest_flags `var' `if' `in' [`weight' `exp'] 
				if "`flag_list'"=="" {
								local lamf `" `r(flag)'"'
									}
								else {
									local lamf `",  `r(flag)'"'
								}
								
				local flag_list   "`flag_list' `lamf'   "
				}	
		if "`coverage'" !=""  {
					tempvar sample
					gen `sample' = 1- missing(`var') `if' `in'
					su `sample' [aw `exp'], meanonly 
					tempname `var'_x 
					scalar ``var'_x' = r(mean)
					local stat_list   "`stat_list', ``var'_x'   "
					local name_list   "`name_list' `var'_x"  
					if "`flag'" !="" {	// repeat flag for mean on coverage index
						if regexm("`lamf'",",") local flag_list   "`flag_list' `lamf'   " 
						else local flag_list   "`flag_list', `lamf'   " 
						}
				}			
			}
		}
		
	// store stats
	tempname b flags
 	matrix  `b' = [`stat_list']
	matrix colnames  `b' = `name_list'
	if "`flag'" !="" {
 		matrix `flags'=[`flag_list']
		}
	repest_replace_omit_res `b'
	matrix  `b' = r(beta)
	matrix colnames  `b' = `r(betanames)'
	ereturn post `b' 
 	if "`flag'" !="" ereturn matrix flags=`flags'
end

* **** *
* FREQ *
* **** *

cap program drop repest_freq
program define repest_freq,eclass
	syntax varname [if] [in] [pweight aweight]  , levels(string) [flag count coverage] 
	
	tempname total cell tab uniqlevels
	
	if "`levels'" == "" qui levelsof `varlist', local(levels)

	if "`count'"=="" qui tab `varlist' [aw `exp'] `if' `in', matcell(`tab') matrow(`uniqlevels')
	else qui tab `varlist' `if' `in', matcell(`tab') matrow(`uniqlevels')
	foreach level in `levels' {
		local lev = regexr("`level'","-","m")
		tempname `varlist'_`lev'
		if "`stat_list'"=="" {
								local lamf `" ``varlist'_`lev''"'
									}
								else {
									local lamf `", ``varlist'_`lev''"'
								}
		local stat_list   "`stat_list' `lamf' "
		local name_list  "`name_list' `varlist'_`lev' "
 
		scalar ``varlist'_`lev'' = .
		if r(N) != 0 {
			if "`count'"=="" {
				matrix `total' =  (`tab'' * J(r(r),1,1))
				matrix `cell' = `tab' / `total'[1,1]
				matrix `cell' = 100*`cell'
				}
			else {
				matrix `cell' = `tab'
			}
			local max = rowsof(`uniqlevels')
			forval c = 1/`max' {
				if `level' == `uniqlevels'[`c',1] scalar ``varlist'_`lev'' = `cell'[`c',1]
				}
			if ``varlist'_`lev'' == . scalar ``varlist'_`lev'' = 0
			}
		}
*** OLD flags for freq: check numerator		
*		if "`flag'" !=""  {
*			foreach level in `levels' { 
*				repest_flags  if `varlist'==`level'
*				if "`flag_list'"=="" {
*								local lamf `" `r(flag)'"'
*									}
*								else {
*									local lamf `", `r(flag)'"'
*								}
*				local flag_list   "`flag_list' `lamf'  "
*				}
*		}	
** NEW flags for freq: check denominator	(gives consistent flags with means,pct)	
		if "`flag'" !=""  {
			repest_flags  `varlist' `if' `in'
			foreach level in `levels' { 
				if "`flag_list'"=="" {
								local lamf `" `r(flag)'"'
									}
								else {
									local lamf `", `r(flag)'"'
								}
				local flag_list   "`flag_list' `lamf'  "
				}
		}			
		if "`coverage'" !=""  {
					tempvar sample
					gen `sample' = 1- missing(`varlist') `if' `in'
					su `sample' [aw `exp'], meanonly 
					tempname `varlist'_x 
					scalar ``varlist'_x' = r(mean)
					local stat_list   "`stat_list', ``varlist'_x'   "
					local name_list   "`name_list' `varlist'_x"  
					if "`flag'" !="" {	// repeat flag for mean on coverage index
						if regexm("`lamf'",",") local flag_list   "`flag_list' `lamf'   " 
						else local flag_list   "`flag_list', `lamf'   " 
						}
				}	
	// store stats
	tempname b flags
 	matrix  `b' = [`stat_list']
	matrix colnames  `b' = `name_list'
	repest_replace_omit_res `b'
	if "`flag'" !="" {
 		matrix `flags'=[`flag_list']
		}
	matrix  `b' = r(beta)
	matrix colnames  `b' = `r(betanames)'
	ereturn post `b' 
  	if "`flag'" !="" ereturn matrix flags=`flags'

end


* ********* *
* SUMMARIZE *
* ********* *

cap program drop repest_summarize
program define repest_summarize,eclass
	syntax varlist [if] [in] [aweight pweight] , stats(string) [flag coverage]
	// check syntax
 	foreach stat in `stats' {
		if regexm("mean sd min max sum_w p1 p5 p10 p25 p50 p75 p90 p95 p99 skewness kurtosis sum N Var","`stat'") != 1 {
			di as error `"estimate suboption stats must contain elements computed in stata's summarize command"'
			error 198
			}
		}
	// summarize options	
	if "`stats'" == "mean" local sumoptions = ", meanonly"
	else if (regexm("`stats'","p") == 1 | regexm("`stats'","k") == 1)  local sumoptions = ", detail"
	// compute stats
	foreach outcome in `varlist' {
		qui: su `outcome' [aw `exp'] `if' `in' `sumoptions'
		foreach stat in `stats' {
			tempname `outcome'_`stat'  
			if "`stat_list'"=="" {
								local lamf `" ``outcome'_`stat''"'
									}
								else {
									local lamf `", ``outcome'_`stat''"'
								}
			local stat_list   "`stat_list' `lamf'   "
			local name_list   "`name_list' `outcome'_`stat'  "
			
 

			if `r(N)' == 0 scalar ``outcome'_`stat'' = .
			else if "`stat'" == "sd" & `r(N)' != 0 scalar ``outcome'_`stat'' = `r(sd)'*sqrt((`r(N)'-1)/`r(N)')
			else if "`stat'" == "Var" & `r(N)' != 0 scalar ``outcome'_`stat'' = `r(Var)'*(`r(N)'-1)/`r(N)'
			else scalar ``outcome'_`stat'' = r(`stat')
			}
			

		if "`flag'" !=""  {
			repest_flags `outcome'  `if' `in'
 			foreach stat in `stats' {
				if "`flag_list'"=="" {
								local lamf `" `r(flag)'"'
									}
								else {
									local lamf `", `r(flag)'"'
								}
				local flag_list  "`flag_list' `lamf'    "

				}
			}
		if "`coverage'" !=""  {
					tempvar sample
					gen `sample' = 1- missing(`outcome') `if' `in'
					su `sample' [aw `exp'], meanonly 
					tempname `outcome'_x 
					scalar ``outcome'_x' = r(mean)
					local stat_list   "`stat_list', ``outcome'_x'   "
					local name_list   "`name_list' `outcome'_x"  
					if "`flag'" !="" {	// repeat flag for mean on coverage index
						if regexm("`lamf'",",") local flag_list   "`flag_list' `lamf'   " 
						else local flag_list   "`flag_list', `lamf'   " 
						}
				}	
		}

	// store stats 
	tempname b flags
	matrix  `b' = [`stat_list']
	if "`flag'" !=""   	matrix `flags'=[`flag_list'] 
 	matrix colnames  `b' = `name_list'
	repest_replace_omit_res `b'
	matrix  `b' = r(beta)
	matrix colnames  `b' = `r(betanames)'
	ereturn post `b' 
  	if "`flag'" !="" ereturn matrix flags=`flags'
 
end


* ************** *
* QUANTILE TABLE *
* ************** *

cap program drop repest_quantiletable
program define repest_quantiletable,eclass
	syntax varlist(numeric min=2 max=2) [if/] [in] [pweight aweight] [, flag NQuantiles(integer 4) noINDEXQuantiles noOUTCOMEQuantiles RELRisk ODDSratio SUmmarize(varname) REGress(varlist numeric min=2 max=2) test coverage]

	if "`if'" != "" local if "& `if'"
	tokenize `varlist'
	local index "`1'"
	local outcome "`2'"
	*flags work only when  RELRisk ODDSratio SUmmarize REGress are unspecified
	if "`relrisk'"!="" | "`oddsratio'"!="" |  "`summarize'"!="" |  "`regress'"!="" {
		di as err `"Warning: option "flag" has been suppressed!"'
		di as err `"         flags only work with quantiletable without options RELRisk ODDSratio SUmmarize REGress "'
		local flag=""
		}

		// initialise names
	tempname rrisk oratio `outcome'_qd beta r2 `summarize'_mean `summarize'_sd `outcome'_qd_f

	forval i = 1/`nquantiles' {
		tempname `index'_q`i' `outcome'_q`i' `index'_q`i'_f `outcome'_q`i'_f
		if "`indexquantiles'" == "" local index_quantiles = "`index_quantiles'" + "`index'_q`i' "
		if "`outcomequantiles'" == "" local outcome_quantiles = "`outcome_quantiles'" + "`outcome'_q`i' "
		if "`flag'"!="" {
			if "`indexquantiles'" == "" local index_quantiles_f = "`index_quantiles_f'" + "`index'_q`i'_f "
			if "`outcomequantiles'" == "" local outcome_quantiles_f = "`outcome_quantiles_f'" + "`outcome'_q`i'_f "
			}
		}
		
	if "`test'" != "" {
		if "`outcomequantiles'" == "" local test "`outcome'_qd"
		else di as error "option test is ignored if option nooutcomequantiles is used"
		}
		
	if "`relrisk'" != "" 	local otherstats "rrisk"
	if "`oddsratio'" != "" 	local otherstats "`otherstats' oratio"
	if "`summarize'" != "" {
		local mean "`summarize'_mean"
		local sd "`summarize'_sd"
		}
	if "`regress'" != "" {
		local coeff "beta"
		local rsq   "r2"
		}

	// add random noise to index and outcome
	set seed 5094
	tempvar rindex
	gen `rindex' = `index' + 0.0001*runiform() if  missing(`index') == 0
		

	// compute percentile thresholds 
	_pctile `rindex' [`weight' `exp'] if _n>0 `if' &  missing(`index') == 0 `in' , nq(`nquantiles')
	// compute requested quantile stats
	if r(r1) != . {
		if "`oddsratio'" != "" | "`relrisk'" != "" {
			tempvar `index'_q 
			qui gen ``index'_q' = (`rindex' <= r(r1)) if  missing(`index') == 0
			}
		local last = `nquantiles' - 1
		forval thr = 1/`last' {
			local k`thr' = r(r`thr')
			}

		// means by quantile
		forval q = 1/`nquantiles' {
			local qq = `q' - 1
			if "`indexquantiles'" == "" { 
				qui {
					if `q' == 1 su `index' [aw `exp'] if _n>0 `if' & `rindex' <= `k`q'' &  missing(`index') == 0 `in', meanonly
					else if `q' == `nquantiles' su `index' [aw `exp'] if _n>0 `if' & `rindex' > `k`qq'' &  missing(`index') == 0`in', meanonly
					else su `index' [aw `exp'] if _n>0 `if' & `rindex' > `k`qq'' & `rindex' <= `k`q''`in' &  missing(`index') == 0, meanonly

					scalar ``index'_q`q'' = r(mean)
						if "`flag'"!="" {
							if `q' == 1 repest_flags if _n>0 `if' & `rindex' <= `k`q'' &  missing(`index') == 0 `in'
							else if `q' == `nquantiles' repest_flags if _n>0 `if' & `rindex' > `k`qq'' &  missing(`index') == 0 `in'
							else repest_flags if _n>0 `if' & `rindex' > `k`qq'' & `rindex' <= `k`q''`in' &  missing(`index') == 0
							scalar ``index'_q`q'_f' = r(flag)	
						}
					}
				}
			if "`outcomequantiles'" == "" { 
				qui {
					if `q' == 1 su `outcome' [aw `exp'] if _n>0 `if' & `rindex' <= `k`q'' &  missing(`index') == 0 `in', meanonly
					else if `q' == `nquantiles' su `outcome' [aw `exp'] if _n>0 `if' & `rindex' > `k`qq''  &  missing(`index') == 0 `in', meanonly
					else su `outcome' [aw `exp'] if _n>0 `if' & `rindex' > `k`qq'' & `rindex' <= `k`q''`in' &  missing(`index') == 0, meanonly


					scalar ``outcome'_q`q'' = r(mean)
					if "`flag'"!="" {
						if `q' == 1 repest_flags if _n>0 `if' & `rindex' <= `k`q'' &  missing(`index') == 0 &  missing(`outcome') == 0 `in' 
						else if `q' == `nquantiles' repest_flags if _n>0 `if' & `rindex' > `k`qq'' &  missing(`index') == 0 &  missing(`outcome') == 0 `in' 
						else repest_flags if _n>0 `if' & `rindex' > `k`qq'' & `rindex' <= `k`q''`in' &  missing(`index') == 0 &  missing(`outcome') == 0 `in' 
						scalar ``outcome'_q`q'_f' = r(flag)	
						}
					}	
				}
			}
			
		cap drop `rindex'
		// difference across quantiles
		if "`outcomequantiles'" == "" {
			scalar ``outcome'_qd' = ``outcome'_q`nquantiles'' - ``outcome'_q1'
			if "`flag'"!="" {
				scalar ``outcome'_qd_f' =max(real(``outcome'_q`nquantiles'_f'),real(``outcome'_q1_f'))
			}
			}

		// relative risk and odds ratio
		if "`oddsratio'" != "" | "`relrisk'" != "" {
			tempvar routcome
			gen `routcome' = `outcome' + 0.0001*runiform() if  missing(`outcome') == 0
			_pctile `routcome' [aw `exp'] if _n>0 `if' `in', nq(`nquantiles')
			local thr = r(r1)
			tempname tab quarters total q1q1 q1rest
			qui ta ``index'_q' [aw `exp'] if _n>0 `if' & `routcome' <= `thr' `in', matcell(`tab') matrow(`quarters')  
			matrix `total' =  (`tab'' * J(r(r),1,1))
			scalar `q1q1' = `tab'[2,1] / `total'[1,1]
			qui ta ``index'_q' [aw `exp'] if _n>0 `if' & `routcome' > `thr' `in', matcell(`tab') matrow(`quarters')  
			matrix `total' =  (`tab'' * J(r(r),1,1))
			scalar `q1rest' = `tab'[2,1] / `total'[1,1]
			scalar `oratio' = (`q1q1'/(1-`q1q1'))/(`q1rest'/(1-`q1rest'))
			scalar `rrisk'= (`q1q1')/(`q1rest')
			cap drop routcome
			}
	}

	else {
			foreach stat in  `colnames' {
				scalar  `stat' = .
				scalar  `stat'_f = 1
				}
			}
	// compute requested descriptives 
	if "`summarize'" != "" 	{
		qui su `summarize' [aw `exp'] if _n>0 `if' `in'
		scalar ``summarize'_mean' = `r(mean)'
		scalar ``summarize'_sd' = `r(sd)'*sqrt((`r(N)'-1)/`r(N)')
		}
	// compute requested regression 
	if "`regress'" != "" 	{
		tokenize `regress'
		local depvar "`1'"
		local indepvar "`2'"
		qui reg `regress' [aw `exp'] if _n>0 `if' `in'
		scalar `beta' = _b[`indepvar']
		scalar `r2' = 100*e(r2)
		}

	

	// store stats
	foreach stat in `mean' `index_quantiles' `sd' `outcome_quantiles' `coeff' `otherstats' `rsq' `test' {
		local stat_list "`stat_list' ``stat''  , "
		local name_list   "`name_list' `stat'  "
		}
	if "`flag'"!="" {
		foreach stat in  `index_quantiles_f' `outcome_quantiles_f' `outcome'_qd_f {
			local flag_list= "`flag_list' `=``stat'''  , " 
			}
		}
	if "`coverage'" !=""  {
				tempvar sample
				gen `sample' = 1- missing(`index',`outcome') `if' `in'
				su `sample' [aw `exp'], meanonly 
				tempname e_coverage 
				scalar `e_coverage' = r(mean)
				local stat_list   "`stat_list' `e_coverage'   "
				local name_list   "`name_list' e_coverage"  
			}	
	tempname b flags
	local stat_list=regexr("`stat_list'", "\,.$" ,"")
	if "`flag'"!=""  local flag_list=regexr("`flag_list'", "\,.$" ,"")
	matrix  `b' = [`stat_list']
	if "`flag'"!=""  matrix  `flags' = [`flag_list']
	matrix colnames  `b' = `name_list'
	repest_replace_omit_res `b'
	matrix  `b' = r(beta)
	matrix colnames  `b' = `r(betanames)'
	ereturn post `b' 
	// store stats
  	if "`flag'" !="" ereturn matrix flags=`flags'

end








* **** *
* CORR *
* **** *

cap program drop  repest_corr
program define  repest_corr, eclass
	syntax varlist(min = 2) [if] [in] [aweight pweight] [, pairwise flag coverage]
	marksample touse
	tempname corr
	local ncol : word count `varlist'
	
	
	if "`pairwise'" == "" {
		cap corr `varlist' [aw `exp'] `if' `in'
		if _rc != 2000 	matrix `corr' = r(C)
		else matrix `corr' = .

		forval i = 1/`ncol' {
			local z = `i' + 1 
			forval j = `z'/`ncol' {
				if "`stat_list'" == "" local stat_list   "`corr'[`j',`i']"
				else local stat_list   "`stat_list' , `corr'[`j',`i']"
				local name_list   "`name_list' c_`=substr(word("`varlist'",`i'),1,12)'_`=substr(word("`varlist'",`j'),1,12)' "
				}
			}
		if "`flag'"!="" {
			repest_flags if `touse' 
			forval i = 1/`ncol' {
				local z = `i' + 1 
				forval j = `z'/`ncol' {
					if "`flag_list'"=="" {
						local lamf `" `r(flag)'"'
						}
					else {
						local lamf `", `r(flag)'"'
						}
					local flag_list   "`flag_list' `lamf'   "
					}
				}
			}
			if "`coverage'" !=""  {
				su `touse' `if' `in' [aw `exp'], meanonly 
				tempname e_coverage 
				scalar `e_coverage' = r(mean)
				local stat_list   "`stat_list', `e_coverage'   "
				local name_list   "`name_list' e_coverage"  
					if "`flag'" !="" {	// repeat flag for mean on coverage index
						if regexm("`lamf'",",") local flag_list   "`flag_list' `lamf'   " 
						else local flag_list   "`flag_list', `lamf'   " 
						}
			}	
		}
	else {
		tokenize `varlist'
		forval i = 1/`ncol' {
			local z = `i' + 1 
			forval j = `z'/`ncol' {
				tempname corr_`i'_`j'
				cap corr ``i'' ``j'' [aw `exp'] `if' `in'
				if _rc != 2000 scalar `corr_`i'_`j'' = r(rho)
				else scalar `corr_`i'_`j'' = .
				if "`stat_list'"=="" {
								local lamf `"  `corr_`i'_`j''"'
									}
								else {
									local lamf `",  `corr_`i'_`j''"'
								}
				local stat_list   "`stat_list' `lamf'   "
				local name_list   "`name_list' pwc_`=substr(word("`varlist'",`i'),1,12)'_`=substr(word("`varlist'",`j'),1,12)' "
				}
			}
		if "`flag'"!="" {
					forval i = 1/`ncol' {
						local z = `i' + 1 
						forval j = `z'/`ncol' {
							repest_flags if missing(``i'') == 0 &  missing(``j'') == 0
							if "`flag_list'"=="" {
								local lamf `" `r(flag)'"'
									}
								else {
									local lamf `", `r(flag)'"'
								}
							local flag_list   "`flag_list' `lamf'   "
							}
						}
				}
		if "`coverage'" !=""  {
					forval i = 1/`ncol' {
						local z = `i' + 1 
						forval j = `z'/`ncol' {
							tempvar sample
							gen `sample' = 1- missing(``i'',``j'') `if' `in'
							su `sample' `if' `in' [aw `exp'], meanonly 
							tempname e_coverage 
							scalar `e_coverage' = r(mean)
							local stat_list   "`stat_list', `e_coverage'   "
							local name_list   "`name_list' x_`=substr(word("`varlist'",`i'),1,12)'_`=substr(word("`varlist'",`j'),1,12)'"  
							if "`flag'" !="" {	// repeat flag for mean on coverage index
								if regexm("`lamf'",",") local flag_list   "`flag_list' `lamf'   " 
								else local flag_list   "`flag_list', `lamf'   " 
								}
							}
						}
				}	
		}
		
	// store stats
	tempname b  flags 
	if "`flag'"!="" matrix  `flags' = [`flag_list']

	matrix  `b' = [`stat_list']
	matrix colnames  `b' = `name_list'
	repest_replace_omit_res `b'
	matrix  `b' = r(beta)
	matrix colnames  `b' = `r(betanames)'
	ereturn post `b' 
  	if "`flag'" !="" ereturn matrix flags=`flags'

end


* **** *
* PISA Coverage  - report coverage with daggers *
* **** *


cap program drop repest_pisacoverage
program define repest_pisacoverage
*set trace on
	syntax  , outfile(string) [level1(real 75) level2(real 50) ]
	if `level1'>1 local level1 = `level1'/100
	if `level2'>1 local level2 = `level2'/100
	if "`symbol1'" == "" local symbol1 "*"
	if "`symbol2'" == "" local symbol2 "**"
preserve
			use "`outfile'", clear
			foreach var of varlist *_b {
				if !(regexm("`var'","e_coverage_b") | regexm("`var'","_x_b$") | regexm("`var'","^x_")) {
					local sevar = reverse(regexr(reverse("`var'"),"b_","es_"))	// std err
					local cflagvar = reverse(regexr(reverse("`var'"),"b_","c_"))	// generate coverage flag
					gen `cflagvar' = ""
					order `cflagvar', after(`sevar')
					cap confirm variable e_coverage_b 
					if !_rc {
						local xvar "e_coverage_b"
						}
					else {
						cap ds *_e_coverage_b 
						if !_rc {
							local overcat =  ustrregexra(r(varlist),"_e_coverage_b","") 
							foreach cat in `overcat' {
								if regexm("`var'","^`cat'") local xvar "`cat'_e_coverage_b"
								}
							}
						else {
							local xvar = reverse(regexr(reverse("`var'"),"^b_","b_x_")) 
							cap confirm variable `xvar'
							if _rc == 111 {
								local xvar ""
								if regexm("`var'","_m_b$") | regexm("`var'","_mean_b$")| regexm("`var'","_sd_b$") | regexm("`var'","_kurtosis_b$") | regexm("`var'","_skewness_b$") | regexm("`var'","_min_b$") | regexm("`var'","_max_b$")  | regexm("`var'","_p[1|5]_b$")  | regexm("`var'","_p[1|2|5|7|9][0|5|9]_b$") | regexm("`var'","_Var_b$") | regexm("`var'","_Var_b$") | regexm("`var'","_N_b$") | regexm("`var'","_sum_w_b$") | regexm("`var'","_[m]*[0-9]+_b$") {
									local xvar = reverse(regexr(reverse("`var'"),"^b_[a-z0-9]+_","b_x_")) 
									cap confirm variable `xvar'
									if _rc == 111 di as err "coverage was not computed"
									}
								else if regexm("`var'","^pwc_") {
									local xvar = regexr("`var'","^pwc_","x_") 
									cap confirm variable `xvar'
									if _rc == 111 di as err "coverage was not computed"
									}
								}
							}
						}
					di "`var' `cflagvar' `xvar'"
					if "`xvar'" != "" {
						replace `cflagvar' = "†" if `xvar' < `level1' & `xvar' != 0
						replace `cflagvar' = "‡" if `xvar' < `level2' & `xvar' != 0
						}
					else {
						replace `cflagvar' = "."
						di as err `"coverage was not computed for `var'; `cflagvar'  is equal to "." "'
						}
					}
				}
			foreach var of varlist *_b *_se {
				if (regexm("`var'","e_coverage") | regexm("`var'","_x_[b|e|f|s]+$") | regexm("`var'","^x_")) {
					drop `var'
					}
				}
			qui save "`outfile'", replace
			di as res "dta file `outfile' replaced" 
restore
end
