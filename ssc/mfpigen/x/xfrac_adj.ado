*! version 1.0.1 PR 01Mar1999.
program define xfrac_adj, rclass
	version 6
	* Inputs: 1=macro `adjust', 2=varlist, 3=case filter.
	* Returns adjustment values in r(adj1),...
	* Returns number of unique values in r(uniq1),...

	args adjust rhs touse
	if "`adjust'"=="" { xfrac_dis mean adjust "`rhs'" }
	else		    xfrac_dis "`adjust'" adjust "`rhs'"
	tokenize `rhs'
	tempname u
	local i 1
	while "``i''"!="" {
		fvexpand ``i''
		if "`r(fvops)'" == "true" {
			local a
		}
		else {
			quietly inspect ``i'' if `touse'
			scalar `u'=r(N_unique)
			local a ${S_`i'}
			if "`a'"=="" | "`adjust'"=="" {	/* identifies default cases */
				if `u'==1 {		/* no adjustment */
					local a
				}
				else if `u'==2 {	/* adjust to min value */
					quietly summarize ``i'' if `touse', meanonly
					if r(min)==0 { local a }
					else local a=r(min)
				}
				else local a mean
			}
			else if "`a'"=="no" {
				local a
			}
			else if "`a'"!="mean" {
				confirm num `a'
			}
			return scalar uniq`i'=`u'
		}
		return local adj`i' `a'
		local i=`i'+1
	}
end
