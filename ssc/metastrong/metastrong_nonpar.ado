*! 1.0.0 Ariel Linden 05Sep2020

program define metastrong_nonpar, rclass
	version 16
	
	syntax anything [,		///
		above				/// proportion of effects above q
		exp	]				// exponentiated values


				
				// Ensure that data are meta set/esize
				cap confirm variable _meta_es _meta_se
				if _rc {
					di as err "data not {bf:meta} set"
					di as err "{p 4 4 2}You must declare your meta-analysis " "data using {helpb meta esize} or {helpb meta set}.{p_end}"
					exit 119
                }

				// model is random
				if "`_dta[_meta_model]'" != "random" {
					di as err "{bf:metastrong} works only with random effects models"
					exit					
				} 
				
				tokenize `anything', parse(" ")
				numlist "`anything'", min(1) max(1)
                
				local q `anything'
				
				// deal with exponentiated q
				if "`exp'" != "" {
					local q = log(`q')
				}
				
				tempvar phat mu se calib

				// Calibrate predicted effect estimates based on Wang and Lee (2019)
				qui meta regress _cons, random(dlaird)
				qui predict `mu', xb
				qui gen `calib' = `mu' + sqrt(e(tau2) / (e(tau2) + _meta_se^2)) * ( _meta_es - `mu')
			
	
				if "`above'" != "" {
					qui count if `calib' > `q' & `calib' !=.
					local num =  r(N)
					local den =  "`_dta[_meta_K]'"
					scalar `phat' = `num'/`den'
				} //  end above
				if "`above'" == "" {
					qui count if `calib' < `q' & `calib' !=.
					local num =  r(N)
					local den =  "`_dta[_meta_K]'"
					scalar `phat' = `num'/`den'
				} //  end below

				return scalar phat = `phat'

end