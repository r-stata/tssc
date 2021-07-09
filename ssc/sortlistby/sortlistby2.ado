*! version 1.00, Ben Jann, 01mar2004

program define sortlistby2, rclass
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
	if "`random'"!="" {
		forv i=1/`n' {
			local by "`by'`=uniform()' "
		}
	}
	else if `n'!=`: word count `by'' {
		di as error "unmatched number of elements"
		exit 198
	}
	forv i=1/`n' {
	 local pos "`pos'`i' "
	 }
	forv i=1/`n' {
		local k 1
		foreach j of local pos {
			if `k++'==1 {
				local tempa `j'
				local tempb: word `j' of `by'
			}
			else if `: word `j' of `by''<`tempb' {
				local tempa `j'
				local tempb: word `j' of `by'
			}
		}
		local tempc: word `tempa' of `anything'
		local slist "`slist'`tempc' "
		local pos: list pos - tempa
	}
	local slist: list retok slist
	ret local list `"`slist'"'
	if "`noisily'"!="" di `"`slist'"'
end
