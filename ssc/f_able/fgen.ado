program fgen
	syntax newvarname =/exp [if] [in] 
	local typelist double
	gen `typelist' `varlist'=`exp' 
	if strlen("`exp'")<75 label var `varlist' "`exp'"
	else  {
	    label var `varlist' "See notes"
		note `varlist': "`exp'"
	}
end