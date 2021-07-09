*! version 1.0.0 ?????2014

program define rcsgen2, rclass
	version 10.0
	syntax  [varlist(default=none)] [if] [in] ,	[							///
													Gen(string) 			///
													Knots(numlist) 			///
													RMATrix(name) 			///
												]

	marksample touse

	quietly gen double `gen'1 = 0 if `touse'

	local d2rcslist `gen'1 

	local nk : word count `knots'
	if "`knots'" == "" {
		local interior  = 0
	}
	else {
		local interior  = `nk' - 2
	}
	local nparams = `interior' + 1

	if "`knots'"!="" {
		local i = 1 
		tokenize "`knots'"
		while "``i''" != "" {
			local k`i' ``i''
			local i = `i' + 1
		}

		local kmin = `k1'
		local kmax = `k`nk''

		forvalues j=2/`nparams' {
			local lambda = (`kmax' - `k`j'')/(`kmax' - `kmin')
		
			quietly gen double `gen'`j' = (6*(`varlist'- `k`j''))*(`varlist'>`k`j'') - ///
							`lambda'*(6*(`varlist'-`kmin'))*(`varlist'>`kmin') - ///
							(1-`lambda')*(6*(`varlist'-`kmax'))*(`varlist'>`kmax') 
			local d2rcslist `d2rcslist' `gen'`j'		
		}
	}
	
	/* orthogonlise */      
	if "`rmatrix'" != "" {
		tempname Rinv 
		matrix `Rinv' = inv(`rmatrix')
		mata st_store(.,tokens(st_local("d2rcslist")), ///
			"`touse'",st_data(.,tokens(st_local("d2rcslist")), ///
			"`touse'")*st_matrix("`Rinv'")[1..`nparams',1..`nparams'])
	}
	return local d2rcslist `d2rcslist'
end

