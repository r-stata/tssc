* Weibull forward recurrence density
* Henrik Støvring, Dec 2001


program define frwei
	syntax varlist(min = 2 max = 2) [if] [in], gparm(string)
	tokenize `varlist'
	local x `1'
	local fval `2'
	tempname alpha beta
	scalar `alpha' = exp(`gparm'[1,1])
	scalar `beta' = exp(`gparm'[1,2])
	qui replace `fval' = exp( - (`beta' * `x') ^ `alpha' /* 
		*/ - lngamma(1 + 1/`alpha')) * `beta' `if' `in'
end

