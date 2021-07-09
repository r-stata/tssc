program define cs_exp
* Exponential conditional survivorfunction
* Henrik Støvring, Jan 20, 2004
	syntax varlist(min = 2 max = 2) [if/] [in], beta(string)
	tokenize `varlist'
	local x `1'
	local Sval `2'

	if "`if'" == "" {
		local if = "1 == 1"
		}
	qui replace `Sval' = (exp( - `beta' * `x')  - exp(- `beta')) /*
*/                           / ( 1 - exp(- `beta') ) /*
			*/ if `if' & `x' >= 0 `in'

end
