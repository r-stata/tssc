**********************************************************************************
** ipfweight 1.0 
** 27oct2011 MB
**********************************************************************************

program ipfweight
   version 10
   syntax varlist(numeric) [if], GENerate(string) ///
      VALues(numlist) MAXITer(numlist>0) ///
	  [STartwgt(string)] [TOLerance(numlist)] [UPthreshold(numlist)] ///
	  [LOthreshold(numlist)] [MISrep]
	  
   * specify sample for optional if-condition (missings remain)
   marksample touse, novarlist
   
   * specify optional starting weight (1 otherwise) 
   if "`startwgt'"=="" {
      quietly gen `generate' = 1 if `touse'
   }
   else {
      quietly gen `generate' = `startwgt' if `touse'
   }

   * loop for iterations
   foreach i of numlist 1/`maxiter' {
   
      * specify counter for known margins
      local cnt 1
   
      * loop for varlist
      foreach var of local varlist { 
	 
	     * specify variable containing final weighting factors
		 tempvar `generate'`i'_`var'
		 quietly gen ``generate'`i'_`var'' = `generate' if `touse'
	 
	     * save N for var in varlist
	     quietly sum `var' [aweight=``generate'`i'_`var''] if `touse'
	     tempvar t_`var'
         quietly gen `t_`var'' = r(sum_w) if `touse'
		 
	     * save levels of var in varlist as local macro
         quietly levelsof `var' if `touse', local(K)
	  
	     * loop for levels of var in varlist
	     foreach k of local K {
			
			* save n of varlevels
		    quietly sum `var' if `var'==`k' & `touse' ///
			   [aweight=``generate'`i'_`var'']
		    tempvar t_`var'_`k'
            quietly gen `t_`var'_`k'' = r(sum_w) if `touse'
		 
		    * compute sample margins
		    tempvar t_ist_`var'_`k'
	        quietly gen `t_ist_`var'_`k'' = `t_`var'_`k''/`t_`var'' ///
			   if `touse'
		 
		    * compute weighting factors (known margins/sample margins)
		    local soll: word `cnt' of `values'
			quietly replace ``generate'`i'_`var'' = ///
			   (`soll'/`t_ist_`var'_`k'')*0.01 if `var'==`k' ///
			   & `touse'
			
			* optional replacement of missings with a value of 1
			if "`misrep'"=="misrep" {
			   quietly replace ``generate'`i'_`var'' = 1 if `var'==.
			}
			else {
			   quietly replace ``generate'`i'_`var'' = . if `var'==.
			}
			
			* specify tolerance criteria 
			* (=difference between known margins and sample margins)
		    quietly gen t_crit`i'_`var'_`k' = (`soll')-(`t_ist_`var'_`k''/0.01)
			
			* save maximum difference of var
			quietly egen t_crit`i'_`var'_`k'_max = max(abs(t_crit`i'_`var'_`k'))
		 
		    * add 1 to counter
		    local cnt = `cnt'+1
         }
		  
		 * save weighting factors for next round
	     quietly replace `generate' = `generate'*``generate'`i'_`var'' ///
		    if `touse'
		 
		 * optional trimming threshold for large weights with mean correction 
		 * (mean==1) before trimming
		 if "`upthreshold'"!="" {
		    quietly sum `generate' if `touse'
		    quietly replace `generate' = `generate'/r(mean) if `touse'
		    quietly replace `generate' = `upthreshold' ///
			   if `generate'>`upthreshold' & `generate'!=. & `touse'
	     }
		 
		 
		 * optional trimming threshold for small weights with mean correction 
		 * (mean==1) before trimming
		 if "`lothreshold'"!="" {
		    quietly sum `generate' if `touse'
		    quietly replace `generate' = `generate'/r(mean) if `touse'
		    quietly replace `generate' = `lothreshold' ///
			   if `generate'<`lothreshold' & `generate'!=. & `touse'
	     }
		 
		 * overall mean correction (mean==1)
		 quietly sum `generate' if `touse'
		 quietly replace `generate' = `generate'/r(mean) if `touse'
      }
	  
	  * save maximum difference as local macro
	  tempvar t_exititer`i'
	  quietly egen `t_exititer`i'' = rowmax(t_crit`i'_*_max)
	  local exititer = round(`t_exititer`i'', 0.001)
	  drop t_crit`i'_*
	  
	  * tolerance criteria reached?
      if `i'>=2 & "`tolerance'"!=`""' {
	     if `exititer'<=`tolerance' {
		    dis ""
            dis "Tolerance criteria (`tolerance') reached after `i' iterations" 
			dis "Maximum deviation: `exititer' percentage points"
			sum `generate' if `touse', d
	        continue, break
		 }
		 else if `exititer'>`tolerance' {
		    if `i'==`maxiter' {
			   dis ""
               dis "Tolerance criteria (`tolerance') not reached after `i' iterations"
			   dis "Maximum deviation: `exititer' percentage points"
			   sum `generate' if `touse', d
			}
		 }
	  }
	  else if `i'==`maxiter' & "`tolerance'"==`""' {
	     dis ""
		 dis "no tolerance criteria specified"
		 dis "Maximum deviation: `exititer' percentage points after `i' iterations"
		 sum `generate' if `touse', d
	  }	 
   } 
end
exit



