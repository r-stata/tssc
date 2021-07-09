* Exponential survivor function
* Henrik Støvring, Dec 3, 1999

program define iexptl
	syntax varlist(min = 2 max = 2) [if] [in], gparm(string)
	tokenize `varlist'
	local t0 `1'
	local fval `2'
	tempname ebeta
	scalar `ebeta' = exp(`gparm'[1,1])
	qui replace `fval' = exp( - (`ebeta' * `t0') ) `if' `in'
end

