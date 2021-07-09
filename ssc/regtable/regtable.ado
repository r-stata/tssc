****regtable*************************************************************************
****Version 3.0.0
****07Dec2012                                           
****John Ternovski (Analyst Institute)                                               
****johnt1@gmail.com
**************************************************************************************

program define regtable
version 11.0
 
*syntax:
*regtable [regression type] [dep. var.] [indep. var.], group(sub-group var) [covars(ccovars)] 

syntax anything [if] [in] [fweight pweight iweight] , group(varname)  [covars(string)] [vce(passthru)] [file(string)] [replace]


******tokenizing***********
tokenize `anything'
local model `1'
local dv `2'
local tvar `3' 

****error checking
if wordcount("`model' `dv' `tvar'")!=3 {
	disp as error "ERROR: Missing an argument!"
exit
} 

foreach w in dv tvar {
	cap confirm new var ``w'' 
	if !_rc {
		disp as error "ERROR: The variable ``w'' doesn't exist."
		exit
	}
}

foreach n in "`covars'" {
	local covarstype=substr("`n'",1,2)
	if "`covarstype'"!="i." & "`covarstype'"!="c." & "`covarstype'"!="" {
		disp as error "ERROR: For each control variable, you must specify if it is continuous or categorical." 
		exit
	}
}

******************

**********dropping missings
preserve
if "`in'"!="" {
	qui keep `in'
}
if "`if'"!="" { 
	qui keep `if'
}

foreach w in dv tvar group {
	cap confirm str var ``w'' 
	if !_rc {
		qui drop if ``w''==""
	}
	else {
		qui drop if ``w''==.
	}
}
****************************

**************cleaning up variables
tempvar t
egen `t'=group(`tvar')
tempvar groupnum
egen `groupnum'=group(`group')
qui sum `groupnum'
local groupend=`r(max)'


************first line generator
cap file close output
if "`file'"=="" {
	file open output using `model'_`dv'_`tvar'_across_`group'_table.csv, write `replace'
	local file "`model'_`dv'_`tvar'_across_`group'_table.csv"
}
else {
	file open output using "`file'.csv", write `replace'
}
file write output "Treatment Effects Across `group'" _n
file write output ","
disp in green "*********Outputting to `file'"
disp in green "***********************************"
disp in green "*********Group Categories**********"
qui levelsof `group'
foreach n in `r(levels)' {
	disp in green "group: `n'"
	file write output "`n',"
}
file write output _n

*****************first column generator
qui levelsof `tvar', clean
tokenize `r(levels)'
local tmax=wordcount("`r(levels)'")
forval i=2/`tmax' {
	local `tvar'=`"``i''"'
	disp "********Treatment CATEs**********"
	file write output "``tvar''," 
	******************generating betas

	forval j=1/`groupend' {

		cap xi: `model' `dv' i.`t' `covars' [`weight' `exp'] if `groupnum'==`j', `vce' 

		if _rc {
			local treat`k'_beta_`j'="NA"
			local treat`k'_se_`j'="NA"
		}
		else {
			local treat`k'_beta_`j'=_b[_I`t'_`k']
			local treat`k'_se_`j'=_se[_I`t'_`k']
		}
		disp "`treat`k'_beta_`j'',"
		file write output "`treat`k'_beta_`j'',"
	}
file write output _n
}
***********************************
file write output _n
file write output _n

file write output "Standard Errors" _n


forval i=2/`tmax' {
local `tvar'=`"``i''"'
disp "********Treatment S.E.s**********"
file write output "``tvar''," 
*********************


****************generating standard errors

forval j=1/`groupend' {
disp "`treat`k'_se_`j'',"

file write output "`treat`k'_se_`j'',"
}
file write output _n
}
******************************

disp "***********************************"
cap file close output

restore 

end

*