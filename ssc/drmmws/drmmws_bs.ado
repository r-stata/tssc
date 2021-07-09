*! 1.00 Ariel Linden 14Dec2016

program drmmws_bs, rclass 

version 13 

	syntax varlist [if] [in] [,						///
			Ovars(string) Pvars(string)				///
			NSTRata(string) 						///
			COMMon									///
			ATT										///
			Family(string)							///
			Link(string)							///
			MEDian									///
			SEED(string)							///
			REPS(string)]							//						
			
			
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
		
		
			// Give values to options that were not set in the outcome or pscore models
			if "`ovars'" == "" {
				local ovars `preds'
			}
			if "`pvars'" == "" {
				local pvars `preds'
			}
			if "`family'" == "" {
				local family gaussian
			}
			if "`link'" == "" {
				local link   identity
			}

			// Fit propensity score model
			tempvar pscore
	
			tabulate `treat' if `touse' 
				if r(r) != 2 { 
				di as err "With a binary treatment, `treat' must have exactly two values (coded 0 or 1)."
			exit 420  
			} 
			else if r(r) == 2 { 
				capture assert inlist(`treat', 0, 1) if `touse' 
				if _rc { 
				di as err "With a binary treatment, `treat' must be coded as either 0 or 1."
			exit 450 
				}
			}
			logit `treat' `pvars' if `touse'
			predict `pscore' if `touse'
		
			
			mmws `treat' if `touse', pscore(`pscore') nstrata(`nstrata') `att' `common' replace
			
					
			// Fit outcome model
			tempvar pom1 pom0 pomdiff
					
			// median treatment effects (MTE)
			if "`median'" != "" {
			
				qreg `outcome' `ovars' [pw = _mmws] if `treat' == 1 & `touse'
			
				if "`common'" != "" { 
					predict `pom1' if _support==1 & `touse'
				}
				else {
					predict `pom1' if `touse'
				}
		
				sum `pom1', meanonly
				return scalar poms1 = r(mean)
			
				qreg `outcome' `ovars' [pw = _mmws] if `treat' == 0 & `touse'
		
				if "`common'" != "" { 
					predict `pom0' if _support==1 & `touse'
				}
				else {
					predict `pom0' if `touse'
				}
			} // end median
			
			// average treatment effects
			else { 
				glm `outcome' `ovars' [pw = _mmws] if `treat' == 1 & `touse', link(`link') family(`family')
		
				if "`common'" != "" { 
					predict `pom1' if _support==1 & `touse'
				}
				else {
					predict `pom1' if `touse'
				}
		
				sum `pom1', meanonly
				return scalar poms1 = r(mean)
		
				glm `outcome' `ovars' [pw = _mmws] if `treat' == 0 & `touse', link(`link') family(`family')
		
				if "`common'" != "" { 
					predict `pom0' if _support==1 & `touse'
					}
				else {
					predict `pom0' if `touse'
				}
			} // end else (glm)
			
			sum `pom0', meanonly
			return scalar poms0 = r(mean)
				
			gen `pomdiff' = `pom1' - `pom0'
		
			if "`att'" != "" {
				sum `pomdiff' if `treat' == 1, meanonly
			}
			else {
				sum `pomdiff', meanonly
			}
			return scalar drmmws = r(mean)

		} //end quietly

end
