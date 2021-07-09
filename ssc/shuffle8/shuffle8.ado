*! version 1.01, Ben Jann, 10may2005
program define shuffle8, rclass
	version 8.2
	syntax anything [, num NOIsily ]
	if "`num'"!="" {
		numlist "`anything'"
		local anything `r(numlist)'
	}
	local n: word count `anything'
	forv i=1/`n' {
		local u "`u'`=uniform()' "
		local pos "`pos'`i' "
	}
	forv i=1/`n' {
		local k 1
		foreach j of local pos {
			if `k++'==1 {
				local tempa `j'
				local tempb: word `j' of `u'
			}
			else if `: word `j' of `u''<`tempb' {
				local tempa `j'
				local tempb: word `j' of `u'
			}
		}
		local tempc: word `tempa' of `anything'
		local slist `"`slist'`"`tempc'"' "'
		local pos: list pos - tempa
	}
	local slist: list clean slist
	ret local list `"`slist'"'
	if "`noisily'"!="" di as txt `"`slist'"'
end
