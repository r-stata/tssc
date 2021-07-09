*! version 1.0.0  April 2012	J. Blauth & M. Daigl AO Clinical Investigation and Documentation
*! Domain : Data analysis	Description: Scoring algorithm for Oswestry Disability Index (ODI) 

*************************************************************************************************
* Every effort is made to test code as thoroughly as possible but user must accept
* responsibility for use
*************************************************************************************************

version 11

capture program drop odi
program define odi
syntax varlist(min=10 max=10 numeric) [if] [in] , GENerate(name)
marksample touse, novarlist
set varabbrev off


*************************************************************************************************
*	1. Define Range
*************************************************************************************************

scalar rangelow = 0
scalar rangehigh = 5


*************************************************************************************************
*	2. Check For Out Of Range Values
*************************************************************************************************

tempvar alarm
qui gen `alarm' = .

foreach x in `varlist' {
	qui replace `alarm' = 1 if `x' ~= . & ( `x' < rangelow | `x' > rangehigh)
	}

qui summ `alarm'
local r1 = `r(N)'
if `r1' ~= 0 {
	display in red "Out of range values found. Permitted range is 5-0"
	exit 198
	}


*************************************************************************************************
*	3. Generate ODI
*************************************************************************************************

tempvar odimean odimissing
qui egen `odimissing' = rowmiss(`varlist')
qui egen `odimean' = rowmean(`varlist')
qui replace `odimean' = . if `odimissing' > 1

gen `generate' if `touse' = round((`odimean' / rangehigh) * 100)

end
