/***************************************************************************
* Title: Example of the use of Stata command 'swindex' using data from Blattman, Fiala, and Martinez 2013, "Generating Skilled Self-Employment in Developing Countries: Experimental Evidence from Uganda"  (herafter "BFM")
	
	* Original Replication code for BFM: Date: October 2014
	*Code Available here: https://dataverse.harvard.edu/dataset.xhtml;jsessionid=b09da1bd44138069102978fd5c2a?persistentId=doi%3A10.7910/DVN/27898&version=1.0
	

*Description: This code replicates Table 3 of BFM (2013), which provides outcome estimates from the YOP program in Uganda.
		In the original analysis, BFM group their outcomes into several categories, and estimate impacts on each outcome variable within that category.
		For this analysis, we replicate the indvidual outcomes, but also calculate an index of the outcomes in each category.  
		We then also provide outcome estimates on the index.
****************************************************************************/

///////////////
// 1.0 SETUP //
////////////////

	// 1.1 DIRECTORIES
					
			clear
			clear matrix 
			clear mata
			set more off  
			
		// SET PERSONAL DIRECTORY
		
				
// OPEN DATASET
			use "yop_data"

		// SET SURVEY DESIGN 
			svyset [pw=w_sampling_e], strata(district) psu(group_endline)	
			
		
	// 1.2 SET ANALYSIS GLOBALS 
		
		// BASELINE CONTROLS
		

			gl districts "d_1-d_13"
			gl ctrl_indiv "age age_2 age_3 urban ind_found_b risk_aversion"
			gl H "education literate voc_training numeracy_numcorrect_m adl"
			gl K "wealthindex savings_6mo_p99 cash4w_p99 loan_100k loan_1mil"
			gl E "lowskill7da_zero lowbus7da_zero skilledtrade7da_zero highskill7da_zero acto7da_zero aghours7da_zero chores7da_zero zero_hours nonag_dummy emplvoc inschool"
			gl G "admin_cost_us groupsize_est_e grantsize_pp_us_est3 group_existed group_age ingroup_hetero ingroup_dynamic grp_leader grp_chair avgdisteduc"
			gl controls "$ctrl_indiv $H $K $E $G $districts"
	 	
			// OUTCOMES
			
			*manually generate skilled trade >30 hours
			gen skilledtrade7da_30_e=0
			replace skilledtrade7da_30_e=1 if skilledtrade7da_zero_e>=30 & trade_dummy_e==1
			replace skilledtrade7da_30_e=. if trade_dummy_e==.

			//CONTROL VARIABLE
			*recode the treatment variable ("assigned") to create a dummy for the control group
			recode assigned (1=0) (0=1), gen(control)
			
//////////////////////////////////
// 2.0 In Text Examples from SJ //
/////////////////////////////////

	
	*Example 1: Business Formality
		swindex bizlog_e bizregister_e biztaxes_e, g(IND_biz) normby(control) displayw
			drop IND_biz
	
	
	*Example 2: Employment
		local work totalhrs7da_zero nonaghours7da_zero_e skilledtrade7da_zero_e zero_hours_e trade_dummy_e skilledtrade7da_30_e
			swindex `work', g(IND_work) normby(control) displayw flip(zero_hours_e)
				drop IND_work

//////////////////////////////////
// 3.0 Table 1 from SJ //
/////////////////////////////////
	
	**REPLICATION OF TABLE 3: SUMMARY STATISTICS, MAJOR OUTCOMES FROM BLATTMAN ET AL. (2014)
	
		*Outcome macros
		local outgrp "outcomes_formalize outcomes_income outcomes_work outcomes_migrate "
		gl outcomes "$outcomes_formalize $outcomes_income $outcomes_work  $outcomes_migrate "
			loc controls female $controls
	*Biz
	
			local biz bizlog_e bizregister_e biztaxes_e
		swindex `biz', g(IND_biz) normby(control)  displayw
		svy: regress IND_biz assigned `controls' if e2==1
			foreach y in `biz' {
			svy: regress `y' assigned `controls' if e2==1
			}


*Income
	
			local inc profits4w_real_p99_e wealthindex_e consumption_real_p99_z_e
		swindex `inc', g(IND_inc) normby(control)  displayw 
		svy: regress IND_inc assigned `controls' if e2==1
		foreach y in `inc' {
			svy: regress `y' assigned `controls' if e2==1
			}
	
*Work		
		local work totalhrs7da_zero nonaghours7da_zero_e skilledtrade7da_zero_e zero_hours_e trade_dummy_e skilledtrade7da_30_e
			swindex `work', g(IND_work) normby(control) displayw flip(zero_hours_e)
			
		svy: regress IND_work assigned `controls' if e2==1
		foreach y in `work' {
			svy: regress `y' assigned `controls' if e2==1
			}
		
	
	
*Migration
			local mig_urb migrate_e urban_e
		swindex `mig_urb', g(IND_mig_urb) normby(control) displayw 
		svy: regress IND_inc assigned `controls' if e2==1
		foreach y in `mig_urb' {
			svy: regress `y' assigned `controls' if e2==1
			}
	
	
	

	
