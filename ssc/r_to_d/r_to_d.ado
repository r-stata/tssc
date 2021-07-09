*! 1.0.0 Ariel Linden 02Sep2020

program define r_to_d, rclass
version 11.0

		syntax anything  ,					///
			SX(numlist max=1 >0.00)			/// sample sd of X
			Delta(numlist max=1)			/// delta contrast in X for which to compute Cohen's D                     
			N(numlist max=1)				/// sample size used to estimate r   
			[ NS(numlist max=1)				/// sample size used to estimate sx if different from N
			KNOwn 							/// se is known rather than estimated
			 LEVel(cilevel) ]
			 
			tokenize `anything', parse(" ")
			numlist "`anything'", min(1) max(1)
		
			local r `anything'
			
			if `r'< -1.0 | `r' > 1.0  { 
				di in red "the correlation coefficient must be between -1.0 and 1.0"
				exit 198
			}
			
			local delta = abs(`delta')
			if "`ns'" =="" {
			    local ns = `n'				
			}

			* point estimate
			local d = (`delta' * `r') / (`sx' * sqrt(1- (`r'*`r')) )

			
			* standard error and CI
			local term1 = 1 / (`r'*`r' * (`n' - 3))
			local term2 = 1 / ( 2 * (`ns' - 1))
			
			if "`known'" != "" {
			    local term2 = 0
			}	
			local se = abs(`d') * sqrt(`term1' + `term2')

				
			* handle case where r = 0 exactly using the limit
			* see saved file "Limit as r -> 0"
			if `r' == 0  {
				`se' = (1/`sx') * `delta' * sqrt(1 / (`n'-3))
			}
			
			local iz = invnorm(1-(1-`level'/100)/2)
			local CohensD_Lower = `d' - `iz' * `se'
			local CohensD_Upper = `d' + `iz' * `se'

     		// Display Title
			disp _newline as text "Conversion of Pearson's r to Cohen's d"
	 	 
			// Display output table
			tempname mytab
			.`mytab' = ._tab.new, col(5) lmargin(0)
			.`mytab'.width    20   |11  12  12    12
			.`mytab'.titlefmt  .     .   . %24s   .
			.`mytab'.pad       .     1   1  3     3
			.`mytab'.numfmt    . %9.6f %9.6f %9.6f %9.6f
			.`mytab'.strcolor result  .  .  .  .
			.`mytab'.strfmt    %19s  .  .  .  .
			.`mytab'.strcolor   text  .  .  .  .
			.`mytab'.sep, top
			.`mytab'.titles "Effect Size"							/// 1
							"Estimate"								/// 2
							"Std. Err."								/// 3
							"[`level'% Conf. Interval]" ""          //  4 5
			.`mytab'.sep, middle
                .`mytab'.strfmt    %24s  .  .  .  .
                .`mytab'.row    "Cohen's {it:d}"        ///
                        `d' 	                      	///
                        `se'							///
						`CohensD_Lower'                 ///
                        `CohensD_Upper'
			.`mytab'.sep, bottom	

			// Return results
 			return scalar ub_d = `CohensD_Upper'
			return scalar lb_d = `CohensD_Lower'
			return scalar se_d = `se'
			return scalar d = `d'
			return scalar n = `n'
			return scalar sx = `sx'
			return scalar r = `r'
	
			// Make a c_local macro of d and se 
			c_local d = `d'
			c_local se = `se'

end