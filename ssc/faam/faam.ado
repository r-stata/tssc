*! version 1.0.0  April 2012	J. Blauth & M. Daigl AO Clinical Investigation and Documentation
*! Domain : Data analysis	Description: Scoring algorithm for Foot and Ankle Ability Measure (FAAM) 

*************************************************************************************************
* Every effort is made to test code as thoroughly as possible but user must accept
* responsibility for use
*************************************************************************************************

version 11

capture program drop faam
program define faam
syntax varlist [if] [in] , DIMension(string asis) GENerate(name)
marksample touse, novarlist
set varabbrev off


*************************************************************************************************
*	1. Check Whether Dimension Is Appropriate
*************************************************************************************************

if "`dimension'" ~= "adl" & "`dimension'" ~= "sport"{
	display in red "Dimension must be one of the following: adl, sport"
	exit 198
	}


*************************************************************************************************
*	2. Check Whether Number Of Variables Is Appropriate
*************************************************************************************************

local numvar: word count `varlist'

if "`dimension'" == "adl" & "`numvar'" ~= "21" {
	display in red "Number of variables must be 21 for adl subscale"
	exit 198
	}

else if "`dimension'" == "sport" & "`numvar'" ~= "8" {
	display in red "Number of variables must be 8 for sport subscale"
	exit 198
	}


*************************************************************************************************
*	3. Define Range
*************************************************************************************************

scalar rangelow = 0
scalar rangehigh = 4


*************************************************************************************************
*	4. Check For Out Of Range Values
*************************************************************************************************

tempvar alarm
qui gen `alarm' = .

foreach x in `varlist' {
	qui replace `alarm' = 1 if `x' ~= . & ( `x' < rangelow | `x' > rangehigh)
	}

qui summ `alarm'
local r1 = `r(N)'
if `r1' ~= 0 {
	display in red "Out of range values found. Permitted range is 4-0"
	exit 198
	}


*************************************************************************************************
*	5. Generate score
*************************************************************************************************

tempvar `dimension'mean `dimension'missing
egen ``dimension'missing' = rowmiss(`varlist')
qui egen ``dimension'mean' = rowmean(`varlist')

qui replace ``dimension'mean' = . if ``dimension'missing' > 2 & "`dimension'" == "adl"
qui replace ``dimension'mean' = . if ``dimension'missing' > 1 & "`dimension'" == "sport"

gen `generate' if `touse' = (``dimension'mean' / rangehigh) * 100

end
