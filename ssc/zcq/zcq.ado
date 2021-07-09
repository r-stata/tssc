*! version 1.0.0  June 2012	J. Blauth & M. Daigl AO Clinical Investigation and Documentation
*! Domain : Data analysis	Description: Scoring algorithm for the Zurich Claudication Questionnaire (ZCQ) 

*************************************************************************************************
* Every effort is made to test code as thoroughly as possible but user must accept
* responsibility for use
*************************************************************************************************

version 11

capture program drop zcq
program define zcq
syntax varlist [if] [in] , DIMension(string asis) GENerate(name) [PERcentage]
marksample touse, novarlist
set varabbrev off


*************************************************************************************************
*	1. Check Whether Dimension Is Appropriate
*************************************************************************************************

if "`dimension'" ~= "symptom" & "`dimension'" ~= "function" & "`dimension'" ~= "satisfaction"{
	display in red "Dimension must be one of the following: symptom, function, satisfaction"
	exit 198
	}


*************************************************************************************************
*	2. Check Whether Number Of Variables Is Appropriate
*************************************************************************************************

local numvar: word count `varlist'

if "`dimension'" == "symptom" & "`numvar'" ~= "7" {
	display in red "Number of variables must be 7 for symptom subscale"
	exit 198
	}

else if "`dimension'" == "function" & "`numvar'" ~= "5" {
	display in red "Number of variables must be 5 for function subscale"
	exit 198
	}

else if "`dimension'" == "satisfaction" & "`numvar'" ~= "6" {
	display in red "Number of variables must be 6 for satisfaction subscale"
	exit 198
	}


*************************************************************************************************
*	3. Define Range
*************************************************************************************************

if "`dimension'" == "symptom" {
	scalar rangelow = 1
	scalar rangehigh = 5
	}

else if "`dimension'" == "function" {
	scalar rangelow = 1
	scalar rangehigh = 4
	}

else if "`dimension'" == "satisfaction" {
	scalar rangelow = 1
	scalar rangehigh = 4
	}

*************************************************************************************************
*	4. Check For Out Of Range Values
*************************************************************************************************

tempvar alarm
qui gen `alarm' = .

tokenize `varlist'

foreach x in `varlist' {
	qui replace `alarm' = 1 if `x' ~= . & ( `x' < rangelow | `x' > rangehigh )
	}

if "`dimension'" == "symptom" {
	qui replace `alarm' = 1 if `7' == 2 | `7' == 4 
	}

qui summ `alarm'
local r1 = `r(N)'
if `r1' ~= 0 {
	display in red "Out of range values found. Permitted range is described in the help file."
	exit 198
	}

*************************************************************************************************
*	5. Generate score
*************************************************************************************************

tempvar `dimension'mean `dimension'missing
egen ``dimension'missing' = rowmiss(`varlist')
qui egen ``dimension'mean' = rowmean(`varlist')

qui replace ``dimension'mean' = . if ``dimension'missing' > 2 & "`dimension'" == "symptom"
qui replace ``dimension'mean' = . if ``dimension'missing' > 1 & "`dimension'" == "function"
qui replace ``dimension'mean' = . if ``dimension'missing' > 1 & "`dimension'" == "satisfaction"

if "`percentage'" == "" {
	gen `generate' if `touse' = ``dimension'mean'
	}

if "`percentage'" == "percentage" {
	gen `generate' if `touse' = round((``dimension'mean' / rangehigh) * 100)
	}

end
