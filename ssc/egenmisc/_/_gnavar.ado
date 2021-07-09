program define _gnavar

	syntax newvarname =/exp [if] [in] [, BY(varlist) min(string)]
	quietly {
		/* standardize expression vs varlist */
		local gen `varlist'
		local type `typelist'
		confirm new variable `gen'
		if "`min'"==""{
			local min 0
		}
		tempvar touse count mean var
		mark `touse' `if' `in'


		bys `touse' `by': gen `count' = sum(!missing(`exp'))
		by `touse' `by' : gen `mean' = sum(`exp')/`count'
		by `touse' `by' : gen `var' = sum((`exp'-`mean'[_N])^2)/(`count'[_N]-1)
		by `touse' `by' : gen `type' `gen' = `var'[_N] if `count'[_N] >= `min' & `touse'
	}

end 

