// postestimation command of boost : delete variables with no influence (or influence below a threshold)
// command uses e(influence) from the preceding boost command
// creates variable 

// Uses the first variable of the influence matrix. Not yet working for multiple categories (multinomial outcomes)

cap program drop influence_delete
program influence_delete
	version 14.0
	syntax  , [ MIN_influence(real 0)  ]

		matrix influence = e(influence)
		confirm matrix e(influence)
		local mynames : rownames influence

		local k : word count `mynames' 

		qui describe, short
		di "Number of variables:" `r(k)'
		forvalues i = 1(1)`k' {
			local aword : word `i' of `mynames'
			local this_i=influence[`i',1]
			if (`this_i'<=`min_influence') {
				// di "dropping  `aword' " influence[`i',1]  
				drop `aword' 
			}
		}
		qui describe, short
		di "Number of variables after deleting variables with zero influence:" `r(k)'

		notes : variables with influence `min_influence' or less deleted

end
