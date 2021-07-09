program define findunique, rclass 
	version 13.0
	
	syntax varlist [if] [in], [SORTing] [first] [ssc]
	
	* installs required components if `ssc' option specified
	if "`ssc'" != "" {
		ssc install unique
		ssc install tuples
	}
	.
	* identifies sample restrictions (in/if) and missing observations
	tempvar touse
	mark touse

	quietly g N = .

	local K=0
	foreach var in `varlist' {
	local K=`K'+1
	}
	.

	* computes combinatorics for all possible combinations of unique identifiers
	quietly forvalues k = 1/`K' {
		quietly replace N = (round(exp(lnfactorial(`K')),1)) ///
			/((round(exp(lnfactorial(`k')),1))*(round(exp(lnfactorial(`K'-`k')),1))) in `k'
	}
	.

	quietly sum N
	scalar N_sum = `r(sum)'
	
	* stores local macros for each combination
	quietly tuples `varlist', display varlist
	
	quietly g count = 0
	
	* takes into account sample restrictions
	quietly count if touse
	local numerosity = r(N)
	
	* identifies "successful" combinations and displays results
	quietly forvalues i = 1/`=N_sum' { 
		quietly unique `tuple`i'' if touse
		if `r(sum)' == `numerosity' {
			noisily dis as result "`tuple`i''"
			quietly replace count = count + 1 in 1
		}
		if count[1] == 1 {
			local sort_new `tuple`i''
		}
		
		* stops the loop if `first' option specified
		if count[1] == 1 & "`first'" != "" {
		continue, break
		}
	} 
	
	* identifies the absence of any set of unique identifiers
	quietly if count[1] == 0 {
		noisily display as text "No unique combination found"
	}
	.
	
	* sorts data according to the specified option `sorting'
	if "`sorting'" != "" {
		sort `sort_new'
		dis as text "Data sorted by " as result "`sort_new'"
	}
	
	quietly drop count N touse

end
