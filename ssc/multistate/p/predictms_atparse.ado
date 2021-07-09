program predictms_atparse, rclass
	syntax, [	corevar(string) 	///
				colindex(real 0) 	///
				dmmat(string) 		///
				i(real 0) 			///
				Ntrans(real 1) 		///
				at(string) 			///
				stacked 			///
				out(real 0)]
	
	if "`stacked'"=="" local index = 1
	else local index = `i'
	
	local inat = 0
	tokenize `at'
	while "`1'"!="" {
		if `out' {
			cap gen `1' = . in 1								//to sync with out of data predictions (for unab)
			local todrop `todrop' `1'
		}
		unab 1: `1'
		if "`corevar'"=="`1'_trans`i'" | "`corevar'"=="`1'" {
			mat `dmmat'[`index',`colindex'] = `2'
			local inat = 1
		}
		mac shift 2
	} 
	if "`corevar'"=="_trans`i'" {
		mat `dmmat'[`index',`colindex'] = 1
	}
	//this makes sure you can't use any of the _trans# vars in at(), at2() or standardising
	forvalues j=1/`ntrans' {
		if "`corevar'"=="_trans`j'" {
			local inat = 1
		}
	}
	return scalar inat = `inat'
	return local todrop `todrop'
end





