program define cf_exp
* Exponential conditional density
* Henrik Støvring, Jan 20, 2004
	syntax varlist(min = 2 max = 2) [if/] [in], beta(string)
	tokenize `varlist'
	local x `1'
	local fval `2'

	if "`if'" == "" {
		local if = "1 == 1"
		}
	qui replace `fval' = `beta' * exp( - `beta' * `x' ) /*
*/                           / ( 1 - exp(- `beta')) /*
			*/ if `if' & `x' >= 0 `in'

end
