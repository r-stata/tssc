*! 1.0.0 Ariel Linden 02Aug2020

program define diagsampsi, rclass
version 11.0

			syntax anything  [, 					///
				Prev(numlist max=1 >0.00 <=1.00)  	/// prevalance
				Width(numlist max=1 >0.00 <=1.00)  	///	width of CI			
				LEVel(cilevel) ]      
			
				gettoken classtype anything : anything, parse(" ")
				local lcmd = length("`classtype'")
   
				// Confirm arguments, depending on classification type 
				if "`classtype'" == substr("sensitivity", 1, max(4,`lcmd')) { 
					numlist "`anything'", max(1) range(>=0.00 <1.00)
					tokenize `anything', parse(" ")
					local sn `1'
					return scalar sens = `sn'
				}
				else if "`classtype'" == substr("specificity", 1, max(4,`lcmd')) { 
					numlist "`anything'", max(1) range(>=0.00 <1.00)
					tokenize `anything', parse(" ")
					local sp `1'
					return scalar spec = `sp'
				}
				else {
					di as err `"unknown subcommand of {bf:classampsi}: `classtype'"'
					exit 198
				}
				
				// Set defaults
				if "`prev'" == "" local prev 0.50
				if "`width'" == "" local width 0.10

				
				// compute Z
				tempname zval
				scalar `zval' = abs(invnormal((100 - `level')/200))


				****************************
				***      Sensitivity     *** 
				****************************
				if "`classtype'" == substr("sensitivity", 1, max(4,`lcmd')) { 
				
					local a_c = `zval'^2 * `sn' * (1-`sn') / (`width'^2)
					local n = `a_c' / `prev'
				
					// display results
					di 
					di as txt "Estimated sample size needed for sensitivity, assuming the following: " _n
					di as txt "   Sensitivity: " as result %4.2f `sn'
					di as txt "   Prevalance: " as result %4.2f `prev' 
					di as txt "   Width of confidence interval: " as result %4.2f `width' 
					di as txt "   Confidence level: " as result %4.1f `level' " %"
					
					di _n as txt "Estimated required sample size for sensitivity:" 
					di _n as txt "       n = " as result ceil(`n')
				
				}
				
				****************************
				***      Specificity     *** 
				****************************
				else if "`classtype'" == substr("specificity", 1, max(4,`lcmd')) { 
				
					local b_d = `zval'^2 * `sp' * (1-`sp') / (`width'^2)
					local n = `b_d' / (1-`prev')
				
					// display results
					di 
					di as txt "Estimated sample size needed for specificity, assuming the following: " _n
					di as txt "   Specificity: " as result %4.2f `sp'
					di as txt "   Prevalance: " as result %4.2f `prev' 
					di as txt "   Width of confidence interval: " as result %4.2f `width' 
					di as txt "   Confidence level: " as result %4.1f `level' " %"
					
					di _n as txt "Estimated required sample size for specificity:" 
					di _n as txt "       n = " as result ceil(`n')
				
				}
				
				***********************
				***  Saved results  *** 
				***********************
				return scalar prev = `prev'
				return scalar width = `width'
				return scalar level = `level'
				return scalar N = `n'
				
			
end	