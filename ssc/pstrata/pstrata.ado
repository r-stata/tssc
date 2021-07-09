*! 1.1.1 touched NJC 22Nov2016 
*! 1.1.0 Ariel Linden 26Oct2016 
* added fix to ensure no treatment groups have zero observations in any stratum
*! 1.00 Ariel Linden 16Aug2016
program define pstrata, rclass
	version 11.0

	syntax varlist(min=1 max=1 numeric) [if] [in], ///
	PScore(varlist min=1 numeric) /// propensity score(s) provided by user
	[ Plevel(real 0.05) 	      /// p-value level used for determining balance
	COMmon				          /// common support
	SMIn(int 5) 		          /// minimum # of strata to start with
	SMAx(int 50)		          /// maximum # of strata to try
	REPLace PREfix(str) *]
	
	
	* parse varlist and call it treat
	gettoken treat : varlist

	quietly {
		marksample touse 
		count if `touse' 
		if r(N) == 0 error 2000
		local N = r(N) 
		replace `touse' = -`touse'
	
		* drop program variables if option "replace" is chosen 
		if "`replace'" != "" {
			local pstrata : char _dta[`prefix'pstrata] 
			if "`pstrata'" != "" {
				foreach v of local pstrata { 
					capture drop `v' 
				}
			}
		}

		* data verification 
		local Npscore : word count `pscore'
	
		tabulate `treat' if `touse'
		local treatcnt = r(r)
	
		* verify minimum number of treatment groups 
		if `treatcnt' < 2 { 
      		di as err "There must be at least two levels of `treat'"
		    exit 420  
		} 
	
		* verify there is a matching number of treatment levels and 
		* pscores (if not a binary treatment) 
		if `treatcnt' > 2 & `treatcnt' != `Npscore' {
			di as err "For `treatcnt' treatments, there should be " ///
			"`treatcnt' propensity scores, one for each treatment group"
		    exit 198
    	}
	
		***********************
		**** common support ***
		***********************
		tempvar support
		if "`common'" != "" {
			local supp1 & `support' == 1
		}
	
		if "`common'" != "" & `treatcnt' == 2 {		// binary treatments
			gen `support' = 1 if `touse'
			sum `pscore' if `treat' ==0 & `touse', meanonly
			replace `support' = 0 if (`pscore' <r(min) | `pscore' >r(max)) ///
			& `treat'==1 & `touse'
			sum `pscore' if `treat' ==1 & `touse', meanonly
			replace `support' = 0 if (`pscore' <r(min) | `pscore' >r(max)) ///
			& `treat'==0 & `touse'
		
		    * get min/max support for return scalar
    	    sum `pscore' if `support'==1 & `touse', meanonly
        	ret scalar suppmin = r(min)
	        ret scalar suppmax = r(max)
		}

		else if "`common'" != "" & `treatcnt' > 2 {	// multiple treatments	
			gen `support' = 1 if `touse'
			levelsof `treat', local(levels)
			foreach tr of local levels {
				foreach p of varlist `pscore' {
					sum `p' if `treat' ==`tr' & `touse', meanonly
					replace `support' = 0 if (`p'<r(min) | `p'>r(max)) ///
					& `treat' !=`tr' & `touse'
				}
			}
	
			* get min/max support for return scalar
    	    forval i = 1/`Npscore' {
        		local v : word `i' of `pscore'
		        sum `v' if `support'==1 & `touse', meanonly
        		ret scalar suppmin`i' = r(min)
		        ret scalar suppmax`i' = r(max)
	        }
		}
		***** end common support *****
	
		*****************************************************
		*** generate optimized number of strata by pscore ***
		*****************************************************

		local smin1 = `smin' 										
		* call it smin1 for resetting smin to default after each ps loop
	
		tempname thismin 	
		forval n = 1/`Npscore' {
			local ps : word `n' of `pscore'
			tempvar pvals`n'
		
			xtile `prefix'strata`n' = `ps' if `touse' `supp1', nq(`smin1') 
			local bag `bag' `prefix'strata`n'
			generate `pvals`n'' = .
	
			* ensures no treatments have zero observatations in any strata
			tempname run`n'
			tab `prefix'strata`n' `treat' if `touse' `supp1',  matcell(`run`n'')

			mata : st_numscalar("`thismin'", min(st_matrix("`run`n''")))
	
			if `thismin' < 1 {
				di as err "{p}At least one treatment group has zero "     ///
				"observations in `prefix'strata`n'. Consider collapsing " ///
				"treatments and/or setting a lower smin() value.{p_end}"
				 exit 2001
			}
	
			while `smin1' <= `smax' { 	
			* default min is 5 and max of 50 strata
  
				* get number of strata for following loops
		    	tab `prefix'strata`n' if `touse' `supp1'
				local r = r(r)											
    	
				forvalues i = 1/`r' {
				* ensures no treatments have zero observations in any stratum 
 					tab `prefix'strata`n' `treat' ///
					if `prefix'strata`n'==`i' & `touse' `supp1'
					if r(c) < `treatcnt' {
						di as err "{p}At least one treatment group has "   ///
						"zero observations in `prefix'strata`n'. Consider" ///
						" collapsing treatments and/or setting a lower "   ///
						"plevel().{p_end}"
						exit 2001
					}
			
					capture anova `ps' `treat' if `prefix'strata`n'==`i' ///
					& `touse' `supp1'

					local pvalue = 1-F(e(df_m), e(df_r), e(F))

					* for cases in which means and sd are exactly the same 
					* in each treatment level, and therefore an ANOVA model 
					* cannot be estimated. This equates to perfect balance
					if e(F) == . local pvalue = 1									
					* no observations or insufficient observations
					* this equates to no balance, and the code moves on  
					if inlist(_rc, 2000, 2001) local pvalue = 0									
				    replace `pvals`n'' = `pvalue' in `i' if `touse' `supp1'
				} // end forval i
	
				* evaluate the pvals across the strata to see if the min  
				* < the level (default 0.05)  
				sum `pvals`n'' if `touse' `supp1', meanonly
				local min = r(min)
	
				* if the min pval is < the level (0.05), 
				* then drop the strata and try again with nq+1
				if `min' < `plevel' {
					drop `prefix'strata`n'
					replace `pvals`n'' =.
					local smin1 = `smin1' + 1
		
					* terminates code when a solution to any of the 
					* PS strata cannot be found
					if `smin1' > `smax' {
						* to get the last stratum level tested
						local test = `smin1' - 1	
						di as err "{p}`test' strata on `ps' were evaluated " ///
						"and no solution could be found. Consider "          ///
						"re-estimating the propensity score; "               ///
						"see help for details.{p_end}"
						exit 498
					}	
					xtile `prefix'strata`n' = `ps' if `touse' `supp1', ///
					nq(`smin1') 
			    	local bag `bag' `prefix'strata`n'
				} // end if min
	
				* if the min pval >= level (0.05), end loop for these strata 
				* and move on to next pscore
				else if `min' >= `plevel' {
					tempname pval`n'
					mkmat `pvals`n'' if `pvals`n'' !=., matrix(pval`n')
					return matrix pval`n' = pval`n'
					local smin1 = `smin'
					continue, break
				} // end else min
			} //end while
		} // end forvals

		char def _dta[`prefix'pstrata] "`prefix'strata`n' `bag'strata'"
  
	} // end quietly

end


