*! 	-powersimplot- version 1.0.0 JL 3July2013
*	Plotting results from -powersim-

program define powersimplot, rclass

	version 11.2

	syntax [ , Esize NOgrid * ]
	
	// Check for powersim results
	if "`r(cmd)'" != "powersim" {
		di as err "-powersim- results not found"
		exit 499
	}
	
	// Twoway options
	_get_gropts , graphopts(`options') gettwoway
	
	// Pick up results
	tempname power
	mat `power' = r(power)
	local b = r(effects)
	local s = r(samples)
	local a = r(alpha)
	local n = r(niter)
	local inis = r(iseed)
	local cmd = r(model)
	
	preserve
	
		clear
		
		qui svmat double `power', names(col)
					
		if "`esize'" == "" {
			label var n "Sample size"
			qui levelsof esize_id, local(lev)
			local line "line power n if esize_id == "
			foreach u of local lev {
				loc b`u' : word `u' of `b'
				loc b`u' `u' " b = `b`u''"
				loc bf `bf' `b`u''
			}
			local xla `s'
		}
		else {
			label var esize "Effect size"
			bys esize_id : gen int samsi = _n
			qui levelsof samsi, local(lev)
			local line "line power esize if n == "
			foreach u of local lev {
				loc b`u' : word `u' of `s'
				loc b`u' `u' " N = `b`u''"
				loc bf `bf' `b`u''
			}
			local xla `b'
			qui levelsof n, local(lev)
		}
				
		local sep " || "
				
		foreach m of local lev {
			loc line`m' `line`m'' `line' `m' `sep' 
			loc lines `lines' `line`m''
		}
		
		if "`nogrid'" == "" {
			local grid grid
		}
				
		// Plot
		`lines' ,						///
		legend(order(`bf')) 			///
		xlabel(`xla', `grid')			///
		ylabel(0(.1)1, angle(0) `grid')	///
		ytitle("Power")					///
		note(" " "alpha = `a'; N of replications per sample and effect size: `n'", pos(6)) ///
		`s(twowayopts)'

	restore
	
	// Saved results
	return local iseed "`inis'"
	return local samples "`s'"
	return local effects "`b'"
	return local cmd "powersim"	
	return local model "`cmd'"
	return scalar alpha = `a'
	return scalar niter = `n'
	return mat power = `power'

end
