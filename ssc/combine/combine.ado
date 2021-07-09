*! version 1.0.2 19dec2017 \ Philip M Jones (Copyright), pjones8@uwo.ca
/* combine: Program to combine two groups' mean, n, and SDs together */
/* the formulae used are taken from the Cochrane handbook version 5.1.0, Table 7.7.a */
/* No claims about the accuracy of this program are stated or implied. */




capture program drop combine
program define combine, rclass

	version 11
	
	args n1 m1 sd1 n2 m2 sd2
	
	if ("`n1'" == "") | ("`m1'" == "") | ("`sd1'" == "") | ("`n2'" == "") | ("`m2'" == "") | ("`sd2'" == "")  {
		display ""
		display ""
		display in yellow "combine: Combine n, mean, and SDs for meta-analysis purposes"
		display in yellow "Version 1.0.1. Copyright 2011 Philip M Jones"
		display ""
		display in red "syntax:  combine n1 mean1 sd1 n2 mean2 sd2"
		display in red "example: combine 20 36.1  2.1 22 25.2  1.1"
		exit
	}	

local combined_sample_size = `n1' + `n2'

local combined_mean = (`n1'*`m1' + `n2'*`m2') / `combined_sample_size'

local a = (`n1' - 1) * `sd1'^2
local b = (`n2' - 1) * `sd2'^2
local c = (`n1' * `n2') / (`n1' + `n2')
local d = abs(`m1')^2 + abs(`m2')^2 - (2 * abs(`m1')* abs(`m2'))

local combined_SD = sqrt( (`a' + `b' + (`c' * `d')) / (`combined_sample_size' - 1) )

display ""
display in green "Combine has calculated the following values:"
display in green "--------------------------------------------"

display in yellow "{col 5}combined n = " `combined_sample_size'
display in yellow "{col 5}combined mean = " `combined_mean'
display in yellow "{col 5}combined SD = " `combined_SD'

return scalar n = `combined_sample_size'
return scalar mean = `combined_mean'
return scalar SD = `combined_SD'

end
