program define _gnasum

	syntax newvarname =/exp [if] [in], [by(varlist) min(stromg)]
	quietly {
		/* standardize expression vs varlist */
		local gen `varlist'
		local type `typelist'
		confirm new variable `gen'
		if "`min'"==""{
			local min 0
		}
		tempvar touse count sum
		mark `touse' `if' `in'
	   	bys  `touse' `by': gen `sum' = sum(`exp') if `touse'
	   	by `touse' `by' : gen `count' = sum(!missing(`exp')) 
	   	by `touse' `by': gen  `type' `gen' = `sum'[_N] if `count'[_N] >= `min'
	}
end 

