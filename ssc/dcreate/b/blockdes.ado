*! blockdes 1.0.0  15Aug2015
*! author arh

program define blockdes, rclass
	version 11.1
	syntax newvarname, NBLOCK(integer) [NEVAL(integer 10) SEED(integer 435)]

	if (`nblock' < 2) {
		di in r "The number of blocks must be an integer greater than one"
		exit 498			
	}						

	if (`neval' < 1) {
		di in r "The number of evaluations must be an integer greater than zero"
		exit 498			
	}						

	qui duplicates report choice_set
	local nset = r(unique_value)
	if (round(`nset'/`nblock') != `nset'/`nblock') {
		di in r "The number of blocks must be a divisor of the number of choice sets"
		exit 498			
	}						
		
	set seed `seed'	
		
	tempname rnd temp

	qui gen `rnd' = 0
	qui gen `temp' = 0	
	qui gen `varlist' = 0

	local maxpsum = 0
	
	qui ds `varlist' `rnd' `temp' choice_set alt, not 
	local desvars `r(varlist)'
	
	forvalues i = 1(1)`neval' {
		qui bysort choice_set (alt): replace `rnd' = sum((_n==1)*runiform())

		local ll = 0
		forvalues j = 1(1)`nblock' {
			local centile = 100*(1/`nblock')*`j'
			qui centile `rnd', centile(`centile')
			local ul = r(c_1)
			qui replace `temp' = `j' if `rnd' > `ll' & `rnd' <= `ul'			
			local ll = `ul'
		}

		local psum = 0
		foreach var of varlist `desvars' {
			qui tab `temp' `var', chi2
			local psum = `psum' + r(p)
		}

		if (`psum' > `maxpsum') {
			qui replace `varlist' = `temp'
			local maxpsum = `psum'
		}	
	}
	return scalar psum = `maxpsum'
end	
