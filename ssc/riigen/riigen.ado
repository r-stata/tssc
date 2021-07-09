*! version 1.0.0, Lars Kroll, 20nov2013

program define riigen,  sortpreserve byable(onecall) 
syntax varlist(min=1) [if] [in] [fweight pweight iweight aweight] , [varprefix(string) riiname(string) replace RIIOrder(string)]
version 10.0

* Init
if "`riiname'"=="" {
	local riiname = "(RII)"
	}
if "`varprefix'" =="" {
	local varprefix = "RII"
	}
else	{
	local varprefix = strtoname("`varprefix'")
	}

* Weighting
/* Implementation: 
All weights are rescaled to add up to the number of cases in the dataset. 
Then, the individual share of a case (=1) on all cases (_N) is replaced by 
the rescaled weights. 
*/
quietly {
	tempvar caseposition
	capture : gen `caseposition'  `exp'
	if _rc !=0 & "`exp'"!="" {
		di as error "Error {help weight} incorrectly specified!"
		}
	if "`exp'"!="" {
		sum	`caseposition'  , mean
		replace `caseposition' = `caseposition'/(r(mean))   
		sum	`caseposition'  
		}
	else {
		gen `caseposition' = 1
		}
	}
	

* Byable
quietly {
	tempvar bygroups 
	egen `bygroups' = group(`_byvars')
	sum `bygroups' , mean
	local anzbygroups = r(max)
	}

* Apply Filters (in or if)
quietly {
	tempvar touse 
	tempvar obstouse
	gen `touse'  = 0
	replace `touse'  = 1 `if'
	gen `obstouse' = 1 `in'
	replace `touse'  = 0 if `obstouse' !=1
	}

* RII-Creation
foreach var of varlist `varlist' {
	* Preserve Label of source
	local vlabel : variable label `var'
	
	* Compute Fractions of Population for weights
	quietly {
		tempvar cumposition
		tempvar sumofpostions
		sort `touse' `bygroups' `var' , stable
		by `touse' `bygroups' : gen     `cumposition'   = `caseposition'
		by `touse' `bygroups' : replace `cumposition'   = `cumposition'+`cumposition'[_n-1] if _n>1
		by `touse' `bygroups' : gen   `sumofpostions'   = `cumposition'[_N]
	}
	
	* Generate or Replace the RII
	quietly {
	capture gen float `varprefix'_`var' = .
	}
	if _rc!=0 & "`replace'" =="" {
		di as error "Variable `varprefix'_`var' is already existing! (no changes made, use option {help replace})"
		}
	else {
		if _rc!=0 {
			di as text "  Replacing:  " as result "`varprefix'_`var'"
			}
		else {
			di as text "  Generating: " as result "`varprefix'_`var'"
			}
		quietly {
			capture drop `varprefix'_`var' 
			gen  float  `varprefix'_`var' = .
			lab var `varprefix'_`var' "`vlabel'`riiname'"
			sort `touse' `bygroups' `var' , stable 
			by `touse' `bygroups' :  replace `varprefix'_`var' = float(`cumposition'/`sumofpostions') if `touse' ==1 & `var' <.
			by `touse' `bygroups' `var' :  replace `varprefix'_`var' = `varprefix'_`var'[int(_N/2)] if `touse' ==1 & _N>1 & `var' <.
			}
		}
	if "`riiorder'"=="higher" {
		quietly: replace `varprefix'_`var' = float(1 - `varprefix'_`var')
		}
	}	
end 
