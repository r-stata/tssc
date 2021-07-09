*******************************************************
* Function for transforming integrand
* u(x) = exp(-x) 
* July 1999, Henrik Støvring
*******************************************************

program define iexp_xtr 
	syntax varlist(min = 2 max = 2) [if] [in], /* 
			*/ fcnname(string) [gparm(passthru) gpvars(passthru)]
	tokenize `varlist'
	local tval "`1'"
	local trfval "`2'"

	tempvar xval
qui{
	gen double `xval' = - log(`tval') `if' `in'
	`fcnname' `xval' `trfval' `if' `in', `gparm' `gpvars'
	replace `trfval' = `trfval' / (- `tval') `if' `in'
}
end

