*! version 1.0.2 June 2012	M. Daigl, J. Honeysett & J. Blauth AO Clinical Investigation and Documentation
*! Domain : Data analysis	Description : Scoring algorithm for DASH score (Disabilities of the arm, shoulder and hand)

version 10
capture program drop dash
program define dash
syntax varlist(numeric) [if] [in] , GENerate(string) [OPtional] [Quick]
marksample touse, novarlist
set varabbrev off

/*Verify that varlist contains only values that range from 1 to 5*/
/* alarmcnt counts number of range violations and exits if one exists*/
local alarmcnt = 0
foreach var of varlist `varlist' {
		quietly su `var'
		if (`r(min)' < 1 | `r(max)' > 5) {
		local alarmcnt = `alarmcnt' + 1
			if `alarmcnt' == 1 {
				display in red "DASH score cannot be calculated"
				display in red "Out-of range values found as described below:"
			}
			display ("     `var' ranges from `r(min)' to `r(max)'")
		}
}
if (`alarmcnt' !=0) exit 198

/*Verify number of variables according to option specified*/
local nvar: word count `varlist'

if ("`optional'"=="" & "`quick'"=="" & `nvar'~=30) {
	display in red "Variable list incorrectly specified. DASH requires 30 items. `nvar' referenced."
		exit 198
}

else if ("`optional'"=="" & "`quick'"~="" & `nvar'~=11) {
	display in red "Variable list incorrectly specified. Quick DASH requires 11 items. `nvar' referenced."
		exit 198
}

else if ("`optional'"!="" & `nvar'~=4) {
	display in red "Variable list incorrectly specified. Optional module requires 4 items. `nvar' referenced."
		exit 198
}


/* Calculate score */
/* dash score= ((sum of n responses/n)-1)*25 where n=number of completed responses*/

tempvar cmiss rmean 
qui egen `cmiss'=rowmiss(`varlist') if `touse'
qui egen `rmean'=rowmean(`varlist') if `touse'

if ("`optional'"=="" & "`quick'"=="") {
	gen `generate'=(`rmean'-1)*25 if (`touse' & `cmiss'<=3) /*missing data imputation disability component DASH*/
	}

else if ("`optional'"=="" & "`quick'"~="") {
	gen `generate'=(`rmean'-1)*25 if (`touse' & `cmiss'<=1) /*missing data imputation disability component Quick DASH*/
	} 

else {
	gen `generate'=(`rmean'-1)*25 if (`touse' & `cmiss'==0) /*no imputation of missing data for optional components*/
	}

end

