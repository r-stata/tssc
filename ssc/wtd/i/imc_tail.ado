*********************************************************
* Program for numerical tail integration using stratified MC
* antithetical 
* Henrik Støvring, Dec 2001
*********************************************************

program define imc_tail
version 7.0
	syntax varlist(min = 1 max = 1) [if] [in], /* 
			*/ fcnname(string) /*
			*/ ain(real) gparm(passthru) /*
			*/ transf(string)
	tokenize `varlist'
	local MC "`1'"
qui{
	tempfile orgdat
	save `orgdat'
	use $utaidat, clear
	tempvar a b
	gen double `b' = 0 
	if "`transf'" == "iexp_xtr" {
		gen double `a' = exp(- `ain') 
		}
	if "`transf'" == "iinv_xtr" {
		gen double `a' = 1 / `ain' 
		}

	tempvar x_eval x_eval2 delta MCtmp1 MCtmp2
	gen double `MCtmp1' = 0
	gen double `MCtmp2' = 0
	gen double `delta' = (`b' - `a') / _N 
	gen double `x_eval' = sum(`delta') + `delta' * (_unifv - 1) + `a' 
	gen double `x_eval2' = sum(`delta') + `delta' * (- _unifv) + `a' 
	`transf' `x_eval' `MCtmp1' , fcnname("`fcnname'") /*
				*/  `gparm'
	`transf' `x_eval2' `MCtmp2' , fcnname("`fcnname'") /*
				*/  `gparm'

        tempname MCtint1 MCtint
        su `MCtmp1', meanonly
	scalar `MCtint1' = r(sum) * `delta'
        su `MCtmp2', meanonly
	scalar `MCtint' = (r(sum) * `delta' + `MCtint1') / 2
	use `orgdat', clear
	replace `MC' = `MCtint' `if' `in'


}

end

