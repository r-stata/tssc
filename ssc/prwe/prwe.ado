*! version 1.0.0 March 2012	M. Daigl AO Clinical Investigation and Documentation
*! Domain : Data analysis		Description : Scoring algorithm for PRWE score (Patient Rated Wrist Evaluation)

version 11
capture program drop prwe
program define prwe
syntax varlist(numeric) [if] [in] , GENerate(string) [SUBscales]
marksample touse, novarlist
set varabbrev off

/*Verify that varlist contains only values that range from 1 to 5*/
/* alarmcnt counts number of range violations and exits if one exists*/
local alarmcnt = 0
foreach var of varlist `varlist' {
		quietly su `var'
		if (`r(min)' < 0 | `r(max)' > 10) {
		local alarmcnt = `alarmcnt' + 1
			if `alarmcnt' == 1 {
				display in red "PRWE cannot be calculated"
				display in red "Out-of range values found as described below:"
			}
			display ("     `var' ranges from `r(min)' to `r(max)'")
		}
}
if (`alarmcnt' !=0) exit 198

/*Verify number of variables according to option specified*/
local nvar: word count `varlist'
if ("`subscales'"=="" & `nvar'~=15) {
	display in red "Variable list incorrectly specified. 15 items required. `nvar' referenced."
		exit 198
}
else if ("`subscales'"!="" & (`nvar'~=5 & `nvar'~=10 & `nvar'~=15)) {
	display in red "Variable list incorrectly specified. Subscale pain requires 5 items, subscale function requires 10 items `nvar' referenced."
		exit 198
}


/* Calculate score */
/* PRWE total score = Pain subscale score + Function subscale score ((sum of n responses/n)-1)*25 where n=number of completed responses*/

tempvar cmiss_p cmiss_f rmean_p rmean_f pain function total

tokenize `varlist'
if `nvar'==15 | `nvar'==5 {
	qui egen `cmiss_p'=rowmiss(`1' `2' `3' `4' `5') if `touse'
	qui egen `rmean_p'=rowmean(`1' `2' `3' `4' `5') if `touse'
	if `nvar'==15 {
		qui egen `cmiss_f'=rowmiss(`6' `7' `8' `9' `10' `11' `12' `13' `14' `15') if `touse'
		qui egen `rmean_f'=rowmean(`6' `7' `8' `9' `10' `11' `12' `13' `14' `15') if `touse'
		}
	}	

else if `nvar'==10 {
	qui egen `cmiss_f'=rowmiss(`1' `2' `3' `4' `5' `6' `7' `8' `9' `10') if `touse'
	qui egen `rmean_f'=rowmean(`1' `2' `3' `4' `5' `6' `7' `8' `9' `10') if `touse'
	}

cap qui gen `pain'=`rmean_p'*5 if (`touse' & `cmiss_p'<=1) /*1 item allowed to be missing*/
cap qui gen `function'=`rmean_f'*5 if (`touse' & `cmiss_f'<=2) /*2 items allowed to be missing*/
cap qui gen `total'=`pain'+`function'

if "`subscales'"=="" {
	gen `generate'=`total' 
	} 
else {
	gen `generate'=`total' 
	if `nvar'==15 | `nvar'==5 {
		gen `generate'_pain=`pain'
		}
	if `nvar'==15 | `nvar'==10 {
		gen `generate'_function=`function'
		}
	}
end

