*! 1.0.0 Ariel Linden 28Oct2019

program define fragility, rclass
version 11.0

			syntax anything  [,			///
				LEVel(real 0.05)		/// critical P
				CHI2					/// use Pearson's chi-squared instead of Fisher's exact test
				DETail					/// if user wants to see all analyses as they run
				]                    

				preserve
				numlist "`anything'", min(4) max(4)
				tokenize `anything', parse(" ")

				local y1 `1' // Group 1's number of events
				local n1 `2' // Group 1's sample size 
				local y2 `3' // Group 2's number of events
				local n2 `4' // Group 2's sample size

				confirm integer number `y1'
				confirm integer number `n1'
				confirm integer number `y2'
				confirm integer number `n2'
                        
				if `y1'<0 | `n1'<0 | `y2'<0 | `n2'<0 { 
					di in red "negative numbers invalid"
					exit 411
				}
				
				if `y1'>`n1' | `y2'>`n2' { 
					di in red "the number of events cannot be greater than the sample size"
					exit 198
				}

				local y1_1 = `n1' - `y1' // Group 1 count without event
				local y2_1 = `n2' - `y2' // Group 2 count without event
				local denom = `n1' + `n2' // total sample size

				// ensure group with lowest event count is first 
				if `y1' <= `y2' {
					local group "1"
					local a = `y1'
					local b = `y1_1'
					local c = `y2'
					local d = `y2_1'
				}
				else {
					local group "2"
					local a = `y2'
					local b = `y2_1'
					local c = `y1'
					local d = `y1_1'
				}
				
				if "`chi2'" != "" {
					local method chi2
					local test "Pearson's chi-squared test."
					local pval = r(p)
				} 
				else {
					local method exact
					local test "Fisher's exact test."
					local pval = r(p_exact)
				}

								
				if "`detail'" == "" local qui "quietly"
			
				// run original data to get starting p-value
				`qui' di _n %~50s `"Original Test Results"'
				`qui' tabi `a' `b' \ `c' `d' , `method'
				
				if "`chi2'" != "" {
					local pval = r(p)
				} 
				else {
					local pval = r(p_exact)
				}
				

				local i = 0

				// loop over 2 X 2 tables increasing the events by 1 in the group with lowest initial events
				`qui' {
					di _n
					di _n %~50s `"Increasing the event rate"'
					while `pval' <= `level' {
						local a = `a' + `i'
						local b = `b' - `i'
						tabi `a' `b' \ `c' `d' , `method'
						local i = 1

						if "`chi2'" != "" {
							local pval = r(p)
						} 
						else {
							local pval = r(p_exact)
						}
					}

					if `y1' <= `y2' {
						local fi = `a' - `y1'
					}
					else {
						local fi = `a' - `y2'
					}
				} // end quietly
				local fq = (`fi'/`denom')
				
				// output
				di _n
				di as txt "   Fragility index: " as result %1.0f `fi'
				di as txt "   Fragility quotient: " as result %5.3f `fq'
				di as txt "   {it:p}-value (`method'): " as result %5.3f `pval'
				
		
				// description of fragility index
				if `fi' > 0 { 
					di _n
					di as txt "   A fragility index of " %1.0f `fi' " indicates that group " %1.0f `group' " would require " %1.0f `fi' " additional events to obtain" 
					di as txt "   a {it:P}-value >= "  %5.3f `level' " using `test' "
				}
				else {
					di _n
					di as txt "   A fragility index of " %1.0f `fi' " indicates that neither group requires additional events to obtain"
					di as txt "   a {it:P}-value >= " %5.3f `level' " using `test' "
				}

				// return list
				return scalar pval = `pval'
				return scalar fq = `fq'
				return scalar fi = `fi'
				
end

				