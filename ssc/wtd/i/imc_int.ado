
*********************************************************
* Program for numerical integration using stratified MC
* with antithetic coupling
* Henrik Støvring, Jan 2001
*********************************************************

program define imc_int
	syntax varlist(min = 3 max = 3) [if] [in], /* 
			*/ neval(int) fcnname(string) gparm(passthru) 
	tokenize `varlist'
	local a "`1'"
	local b "`2'"
	local MC "`3'"
qui{
	replace `MC' = 0 `if' `in'
	tempvar i x_eval x_eval2 ftih ftih2 delta MC2
	local i = 2
	gen double `ftih' = 0 `if' `in'
	gen double `ftih2' = 0 `if' `in'
	gen double `MC2' = 0 `if' `in'
	gen double `delta' = (`b' - `a') / `neval'
	gen double `x_eval' = _unifv1 * `delta' + `a' `if' `in'
	gen double `x_eval2' = (1 - _unifv1) * `delta' + `a' `if' `in'
	`fcnname' `x_eval' `MC' `if' `in', `gparm'
	`fcnname' `x_eval2' `MC2' `if' `in', `gparm'
        
	while `i' <= `neval' {
		replace `x_eval' = _unifv`i' * `delta' /*
			*/ + (`i' - 1) * `delta' + `a'
		replace `x_eval2' = (1 - _unifv`i') * `delta' /*
			*/ + (`i' - 1) * `delta' + `a'
		`fcnname' `x_eval' `ftih' `if' `in', /*
				*/ `gparm'
		replace `MC' = `MC' + `ftih' `if' `in'

		`fcnname' `x_eval2' `ftih2' `if' `in', /*
				*/ `gparm'
		replace `MC2' = `MC2' + `ftih2' `if' `in'
		local i = `i' + 1
        }
	replace `MC' = (`MC' + `MC2') / 2  `if' `in'
	replace `MC' = `MC' * `delta' `if' `in'
}
end
