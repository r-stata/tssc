* Exponential forward recurrence density
* Henrik Støvring, Dec 2001


program define frexp
	syntax varlist(min = 2 max = 2) [if] [in], gparm(string)
	tokenize `varlist'
	local x `1'
	local fval `2'
	tempname alpha beta
	scalar `beta' = exp(`gparm'[1,1])
	qui replace `fval' = `beta' * exp( - (`beta' * `x')) `if' `in'
end

