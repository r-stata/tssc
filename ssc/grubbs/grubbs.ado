**************************************
* This is grubbs.ado beta version
* Date: Jan, 20,2007
* Version: 1.1
* 
* Questions, comments and bug reports : 
* couderc@univ-paris1.fr
*
* Version history :
* v1.1: - Bug correction (odd behavior when -if- is specified). 
*       - Changes in the default variable names (grubbs_xx2, ...)
* v1.0: Initial release. 
* Initial code by A.-C. Disdier and K. Head (available at http://strategy.sauder.ubc.ca/head/grubbs.ado)
**************************************

set more off
cap prog drop grubbs
program grubbs
version 8.0

syntax [varlist(default=none)] [if] [in], [GENerate(string)] [DRop] [LOg] [ITer(integer 16000)] [LEVel(real 95.0)] 

********************
* Verifying syntax
********************
if "`varlist'"=="" {
	di as error "varlist required"
	exit 198
}
if `level'>100 | `level'<1 {
	di as error "level() specifies the confidence level, as a percentage. It must be between 1.0 and 100.0"
	exit
}
scalar conf=(100-`level')/100
if `iter'<0 {
	di as error "iter() must be an integer above 0"
	exit
}
if "`drop'"!="" & "`generate'"!="" {
	di as error "drop skipped because of generate()"
	local drop=""
}
marksample touse

********************
* Grubbs procedure
********************

scalar nbvar=wordcount("`varlist'")
scalar nbnewvar=wordcount("`generate'")
if nbnewvar!=nbvar & nbnewvar!=0 {
	di as error "Number of variable names in generate() not equal to number of var, skip to default names"
	local generate=""
}
tokenize `"`generate'"'
foreach var of local varlist {
	di as result "Variable: `var' " _continue
	tempvar centred varmq
	local varname="grubbs_`var'"
	if ("`generate'"!="") local varname="`1'"
	capture confirm new var `varname'
	local tempvarname="`varname'"
	local i=1
	while _rc==110 {
		local varname="`tempvarname'`i'"
		local i=`i'+1
		capture confirm new var `varname'
	}
	di "(0/1 variable recording which observations are outliers: `varname')."
	gen byte `varname'=0
	local i = 1
	gen byte `varmq' =(`var'==. | `touse'!=1)
	scalar cutoff = 10
	scalar G = cutoff +1
        while G > cutoff & `i'<= `iter' {
		qui sum `var' if `varname' == 0 & `touse'
		gen `centred' = (abs(`var' -r(mean)))/r(sd)
		gsort -`varmq' -`varname' `centred'
		scalar cutoff = (r(N)-1)*sqrt(invttail(r(N)-2,conf/(2*r(N)))^2/(r(N)*(r(N)-2+invttail(r(N)-2,conf/(2*r(N)))^2)))
		scalar G = `centred'[_N]
		if ("`log'"!="" & G > cutoff) {
			di as txt "Iteration = " `i' ". T-value: " %5.4f G " so " `var'[_N] " is an outlier"
		}
		qui replace `varname'= 1 if `centred' == G & G > cutoff
		local i = `i'+1
		drop `centred' 
	}
	local j=`i'-2
	if (`i'<=`iter') di as result "`j' outliers. No more outliers"
	else di as error "more than `j' outliers. Increase number of iterations"
	drop `varmq'
	mac shift
}
if "`drop'"!="" {
	tempvar del
	egen `del'=rowtotal(grubbs_*)
	drop if `del'!=0
	drop `del' 
	capture drop grubbs_*
}
end
