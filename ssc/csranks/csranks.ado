*! version 1.0 13jan2021 Evan Soltas esoltas@mit.edu

cap program drop csranks

program define csranks, rclass 
syntax, id(varname) mean(varname) se(varname) [SIMULtaneous Boot(integer 1000)]

	version 14.1

	quietly {
	
	* Check for potential issues before code runs
	
		* Missing values
		
		capture assert !missing(`mean')
		if _rc != 0 {
			display as error "Error: `mean' cannot contain missing values"
			exit 416
		}
		
		capture assert !missing(`se')
		if _rc != 0 {
			display as error "Error: `se' cannot contain missing values"
			exit 416
		}
		
		* Non-unique identifier
		
		capture isid `id'
		if _rc != 0 {
			display as error "Error: `id' must be a unique identifier"
			exit 459
		}
		
		* Problematic variable names
		
		capture confirm variable `mean'_2
		if _rc == 0 {
			display as error "Error: Remove or rename variable `mean'_2"
			exit 110
		}
		
		capture confirm variable `se'_2
		if _rc == 0 {
			display as error "Error: Remove or rename variable `se'_2"
			exit 110
		}
		
		capture confirm variable `id'_2
		if _rc == 0 {
			display as error "Error: Remove or rename variable `id'_2"
			exit 110
		}
		
		capture confirm variable `id'_rk_min
		if _rc == 0 {
			display as error "Error: Remove or rename variable `id'_rk_min"
			exit 110
		}
		
		capture confirm variable `id'_rk_max
		if _rc == 0 {
			display as error "Error: Remove or rename variable `id'_rk_max"
			exit 110
		}
		
		capture confirm variable `id'_rk_mean
		if _rc == 0 {
			display as error "Error: Remove or rename variable `id'_rk_mean"
			exit 110
		}
		
	* Reshape N-vector to N x N matrix
	
		gen temp_csranks_n1 = _n

		tempfile temp
		save `temp'
		
		local N = _N
		expand `N'
		
		gsort temp_csranks_n1

		gen temp_csranks_n2 = 1
		replace temp_csranks_n2 = temp_csranks_n2[_n-1]+1 if !missing(temp_csranks_n2[_n-1]) & `id' == `id'[_n-1]
		rename (temp_csranks_n1 temp_csranks_n2) (temp_csranks_n2 temp_csranks_n1)

		rename `mean' `mean'_2
		rename `se' `se'_2
		rename `id' `id'_2

		merge m:1 temp_csranks_n1 using `temp', nogen
	
	* Obtain critical level of test statistic
	
		local lev = 1.96
		
		* Update critical level for simultaneous case
		
		if "`simultaneous'" == "simultaneous" {
				
			local Nnew = _N
			
			preserve
			
			expand `boot'
						
			gen temp_csranks_sim = `se'*rnormal()
			gen temp_csranks_sim_2 = `se'_2*rnormal()
	
			gen temp_csranks_t_diff = abs(temp_csranks_sim_2 - temp_csranks_sim) / sqrt(`se'^2 + `se'_2^2)
						
			gen b = 1+floor((_n-1)/`Nnew')
			
			gcollapse (max) temp_csranks_t_diff, by(b)
			
			summ temp_csranks_t_diff, d
			local lev = r(p95)
			
			restore
		
		}


	* Define t-ratio
	
		gen temp_csranks_t_diff = (`mean'_2 - `mean') / sqrt(`se'^2 + `se'_2^2)
		
	* Address edge cases
	
		replace temp_csranks_t_diff = 0 if `mean' == `mean'_2
		replace temp_csranks_t_diff = 1e6 if `mean' < `mean'_2 & missing(temp_csranks_t_diff)
		replace temp_csranks_t_diff = -1e6 if `mean' > `mean'_2 & missing(temp_csranks_t_diff)

	* Initialize upper/lower bounds on rnaks
		
		gen `id'_rk_max = .
		gen `id'_rk_min = .

	* Save ids to locals as list
	
		levelsof `id', local(ids)

	* Compute upper bound on rank
		
		foreach i in `ids' {

			capture confirm string var `id'
			
			if _rc==0 {
				count if `id' == "`i'" & temp_csranks_t_diff > -`lev'
				local max = r(N)
				replace `id'_rk_max = `max' if `id' == "`i'"
			}
			else {
				count if `id' == `i' & temp_csranks_t_diff > -`lev'
				local max = r(N)
				replace `id'_rk_max = `max' if `id' == `i'
			}
	
			
		}

	* Compute lower bound on rank
	
		foreach i in `ids' {
		
			capture confirm string var `id'
			
			if _rc==0 {
				count if `id' == "`i'" & temp_csranks_t_diff < `lev'
				local min = r(N)
				replace `id'_rk_min = `N' + 1 - `min' if `id' == "`i'"
			}
			else {
				count if `id' == `i' & temp_csranks_t_diff < `lev'
				local min = r(N)
				replace `id'_rk_min = `N' + 1 - `min' if `id' == `i'
			}

		}

		duplicates drop `id' `mean' `se' `id'_rk_max `id'_rk_min, force

	* Compute rank for mean of variable

		egen `id'_rk_mean = rank(`mean'), field
		
	drop temp_csranks_n1 temp_csranks_n2 `id'_2 `mean'_2 `se'_2 temp_csranks_t_diff
	
	* Quality check
	
	capture assert (`id'_rk_mean <= `id'_rk_max) & (`id'_rk_mean >= `id'_rk_min) & (`id'_rk_max >= `id'_rk_min)
	
	if _rc != 0 {
		display as error "Error: Bounds on ranks are invalid."
		exit 9
	}
		
	return scalar critval = `lev'
		
	}
	
end
