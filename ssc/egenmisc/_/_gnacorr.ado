program define _gnacorr

	gettoken type 0 : 0
    gettoken gen    0 : 0
    gettoken eqs  0 : 0

	syntax varlist [if] [, BY(varlist) min(string)]
	quietly {
		confirm new variable `gen'
		tokenize `varlist'

		if "`min'"==""{
			local min 1
		}
		tempvar touse count mean1 var1 mean2 var2 cov

		* don't use marksample since you also want to create when varlist is missing
		mark `touse' `if' `in'
		bys `by' `touse': gen `count' = sum(!missing(`1') * !missing(`2'))
		by `by' `touse' : gen `mean1' = sum(`1' * !missing(`2'))/`count' 
		by `by' `touse' : gen `mean2' = sum(`2' * !missing(`1'))/`count'
		by `by' `touse' : gen `type' `cov' = sum((`1'-`mean1'[_N])*(`2'-`mean2'[_N]))
		by `by' `touse' : gen `type' `gen' = sqrt(`cov'[_N]/(`count'[_N]-1)) if `count'[_N] >= `min' * `touse'
	}

end 

