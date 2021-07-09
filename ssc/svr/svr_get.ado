*! version 3.0  05sep2002 NJGW
program define svr_get, rclass
	version 7

	syntax , [ pw ]

	local mainw : char _dta[svrpw]

	if "`pw'"=="pw" & "`mainw'"=="" {
		di as error "Must specify main analysis weight with {help svrset}"
		exit 198
	}
	if "`mainw'"!="" {
		capture confirm numeric variable `mainw'
		if _rc {
			di as error "Invalid main analysis weight.  See {help svrset}"
			exit 198
		}
	}

	local rw : char _dta[svrrw]
	if "`rw'"=="" {
		di as error "Must specify replicate weights with {help svrset}"
		exit 198
	}
	unab rw : `rw'
	capture confirm numeric variable `rw'
	if _rc {
		di as error "Invalid replicate weights.  See {help svrset}"
		exit 198
	}
	local n_rw : word count `rw'

	local meth : char _dta[svrmeth]
	if "`meth'"=="" {
		di as error "Must specify replicate weights with {help svrset}"
		exit 198
	}
	if !inlist("`meth'","brr","jk1","jk2","jkn") {
		di as error "Invalid method `meth'.  See {help svrset}"
	}
	if "`meth'"=="jkn" {
		local psusz : char _dta[svrpsun]
		if "`psusz'"=="" {
			di as error "Must specify PSU counts with {help svrset} for method JKn"
			exit 198
		}
	}


	local fay : char _dta[svrfay]
	if "`fay'"=="" {
		local fay 0
	}


	local dof : char _dta[svrdof]
	if "`dof'"==""  {
		di as error "Must specify degrees of freedom for analysis with {help svrset}"
		exit 198
	}

	return local pw `mainw'
	return local rw `rw'
	return local n_rw `n_rw'
	return local meth `meth'
	return local psun `psusz'
	return local fay `fay'
	return local dof `dof'

end
