*! Pogram to compute RQ index
*! Carlos Gradin
*! This version 1.1, April 2014


cap program drop rq
program def rq, rclass  byable(recall)
version 7
syntax varlist(min=1 max=1) [aweight iweight fweight]  [if] [in]

local y:  word 1 of `varlist'

tempname w rq r c 
marksample touse

if "`weight'" == "" {
	gen `w'=1
}
else {
	gen `w' `exp'
}

set more off

qui: tab `y' [`weight' `exp'] if `touse' , matrow(`r') matcell(`c')
local rn = r(N)
local rr = r(r)

	* RQ

scalar `rq' = 0
forvalues i = 1 / `rr' {
	scalar `rq'  = `rq'  + ((`c'[`i',1]/`rn')^2 )*( 1 - (`c'[`i',1]/`rn'))
}
scalar `rq'=4*`rq'
return scalar rq     =`rq'

di ""
di as text "{hline 100}"
di "Reynal-Querol index (J of Conflict Resolution, 2002) = " as result %9.4f `rq'
di ""
di as text "{hline 100}"

end
