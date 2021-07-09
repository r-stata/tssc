
*! _gpctrange v1.0.0  CFBaum 11aug2008
program _gpctrange 
	version 10.1
	syntax newvarname =/exp [if] [in] [, LO(integer 25) HI(integer 75)  *]
	
	if  `hi' > 99 | `lo' < 1 {
		display as error "Percentiles `lo' `hi' must be between 1 and 99."
		error 198
	}
	if `hi' <= `lo' {
		display as error "Percentiles `lo' `hi' must be in ascending order."
		error 198
	}
	tempvar touse phi plo
	mark `touse' `if' `in'
	quietly { 
		egen double `phi' = pctile(`exp') if `touse', `options' p(`hi')
		egen double `plo' = pctile(`exp') if `touse', `options' p(`lo')
		generate `typlist' `varlist' = `phi' - `plo' if `touse'
	}
end
