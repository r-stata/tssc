*! version 1.01, Ben Jann, 06jul2004

program define sortlistby, rclass
	version 8.2
	syntax anything [, by(numlist) Random Asis Noisily ]
	
	if ("`by'"!=""&"`random'"!="")|("`by'"==""&"`random'"=="") {
		di as error "specify either by() or random (but not both)"
		exit 198
	}
	if "`asis'"=="" {
		numlist "`anything'"
		local anything `r(numlist)'
	}
	local n: word count `anything'
	if "`by'"!="" {
		if `n'!=`: word count `by'' {
			di as error "unmatched number of elements"
			exit 198
		}
	}
	local N=_N
	if `N'<`n' qui set obs `n' 
	tempvar rank By
	qui gen `rank'=_n in 1/`n'
	if "`by'"!="" {
		qui gen double `By'=.
		forv i=1/`n' {
			qui replace `By'=`: word `i' of `by'' in `i'
		}
	}
	else qui gen double `By'=uniform() in 1/`n'
	sort `By' in 1/`n'
	forv i=1/`n' {
		local list `"`list'`: word `=`rank'[`i']' of `anything'' "'
	}
	sort `rank' in 1/`n'
	if `N'<`n' qui drop in `=`N'+1'/`n' 
	local list: list retok list
	ret local list `"`list'"'
	if "`noisily'"!="" di `"`list'"'
end
