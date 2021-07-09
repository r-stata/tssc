program frep 
	syntax varname =/exp [if] [in] 
	replace  `varlist'=`exp' 
    if strlen("`exp'")<75 label var `varlist' "`exp'"
	else {
		qui:notes drop `varlist'	
		label var `varlist' "See notes"
		qui:notes drop fer
		note `varlist': "`exp'"
	}
end