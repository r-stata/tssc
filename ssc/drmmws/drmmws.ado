*! 1.00 Ariel Linden 14Dec2016

program drmmws, rclass 

version 13 

	syntax varlist [if] [in] [,						///
			Ovars(string)							/// covariates in outcome model
			Pvars(string)							/// covariates in pscore model 
			NSTRata(integer 5) 						/// number of strata to generate, default 5
			COMMon									/// implement common support
			ATT										/// Estimate ATT rather than the default ATE
			Family(string)							/// family in GLM outcome model
			Link(string)							/// link in GLM outcome model
			MEDian									/// estimate median treatment effects
			SEED(string)							/// seed for bootstrap
			REPS(integer 200)]						// reps in bootstraop						
		
	quietly {	
			local orig `0'
			tokenize `varlist'
			local outcome `1'
			macro shift
			local treat `1'
			macro shift
			local preds `*'
			
			marksample touse 
			count if `touse' 
			if r(N) == 0 error 2000
			local N = r(N) 
			replace `touse' = -`touse'
						
			
			 // type of treatment effect
			if "`att'" != "" & "`median'" != "" {
				local effect MTT
				}
			else if "`att'" != "" & "`median'" == "" {	
				local effect ATT
				}
			else if "`att'" == "" & "`median'" != "" {	
				local effect MTT
				}
			else {	
				local effect ATE
			}
			
			// title for bootstrap table
			if "`common'" != "" {
				local title "Estimation of `effect' with common support"
				}
			else {
				local title "Estimation of `effect'"
			}
			
	} // end quietly
	
			bootstrap poms1=r(poms1) poms0=r(poms0) teffect=r(drmmws) , reps(`reps') title(`title') seed(`seed') nodrop: drmmws_bs `varlist' if `touse', ovars(`ovars') pvars(`pvars') ///
				nstrata(`nstrata') `att' `common' family(`family') link(`link') `median'
					
end
