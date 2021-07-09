*! 1.0.0                15apr2020
*! Wouter Wakker     	wouter.wakker@outlook.com
program define peerreview
	version 10.0
	
	capt mata mata which mm_invtokens()
    if _rc {
        di as error "mm_invtokens() from -moremata- is required; type {stata ssc install moremata}"
        exit 499
    }
	
	capture syntax varname
	if _rc == 100 {
		syntax , Reviewers(string) Papers(string) [CLEAR]
		
		parse_name_opt `reviewers'
		local reviewers `s(integer)'
		local var_reviewer `s(newvarname)'
		if "`var_reviewer'" == "" local var_reviewer "reviewer" // Default value
		
		parse_name_opt `papers'
		local papers `s(integer)'
		local var_papers `s(newvarname)'
		if "`var_papers'" == "" local var_papers "review" // Default value
		
		local isvar 0
		local isstring 0
		local syntax1 1
	}
	else {
		syntax varname, Papers(string) [NUMber(name)]
		
		parse_name_opt `papers'
		local papers `s(integer)'
		local var_papers `s(newvarname)'
		if "`var_papers'" == "" local var_papers "review" // Default value
		
		cap confirm string variable `varlist'
		if _rc local isstring 0
		else local isstring 1
		local reviewers `=_N'
		local syntax1 0
		if "`number'" != "" {
			local var_reviewer `number'
			confirm new variable `var_reviewer'
			local isvar 0
		}
		else {
			local var_reviewer `varlist'
			local isvar 1
		}
	}
	
	// Argument conditions
	if "`var_papers'" == "`var_reviewer'" {
		di as error "Define different names for reviewer and paper variables"
		exit 110
	}	
	
	if `isvar' {
	qui tab `varlist'
		if `r(r)' != `=_N' & "`number'" == "" {
			di as error "Duplicate or missing values in variable {bf:`varlist'}"
			di "Possible solution: assign unique number to variable {bf:`varlist'} by specifying the {it:number()} option"
			exit 499
			}
	}

	if `papers' < 1 {
		di as error "Number of papers to review must be at least 1"
		exit 119
	}
	
	if `reviewers' < 2 {
		di as error "Number of reviewers must be at least 2"
		exit 119
	}
	
	if `reviewers' <= `papers' {
		di as error "Number of papers to review must be smaller than number of reviewers"
		exit 119
	}
	
	// Prepare data dependent on syntax
	if `syntax1' {
		qui describe
		if r(changed) == 1 {
			if "`clear'" == "" {
				error 4
			}
		}
		// Create dataset
		clear
		qui set obs `reviewers'
	}
	
	// Create list of papers based on varname
	if `isvar' {
		if !`isstring' {
			qui levelsof `varlist', local(levels) clean
			forval i = 1/`papers' {
				local paper_pool `paper_pool' `levels'
			}
		}
		else {
			qui levelsof `varlist', local(levels)
			forval i = 1/`papers' {
				local paper_pool `"`paper_pool' `levels'"'
			}
		}
	}
	// Check whether variables to be created don't yet exist
	else {
		confirm new variable `var_reviewer'
		qui gen `var_reviewer' = _n
	}
	
	if `papers' == 1 confirm new variable `var_papers'
	forval i = 1/`papers' {
		confirm new variable `var_papers'`i'	
	}																	

	// Mata: create inlist conditions and reviewer/author combination matrix
	mata {
		rvws  = strtoreal(st_local("papers"))
		rvwrs = strtoreal(st_local("reviewers"))
		
		// Create empty matrices
		inlist_mat = J(1, rvws, ".")
		rev_auth_comb_mat = J(rvws * rvwrs, 2, .)
		
		row_nr = 1
		for (i=1; i<=rvws; i++) {
			// Create author/review combination matrix
			for (j=1; j<=rvwrs; j++) {
				rev_auth_comb_mat[row_nr, 1] = j
				rev_auth_comb_mat[row_nr, 2] = i
				row_nr++
			}
			// Create inlist conditions for inlist below (conditions are different for different number of reviews)
			inlist_mat[i] = ", `var_papers'" + strofreal(i) + "[\`i']"
		}
		st_local("inlist_cond", invtokens(inlist_mat))
	}

	// Shuffle list of papers and assign to reviewers
	// Papers are put at the end of the list of one of the conditions is not satisfied
	// In some cases, the papers that are left cannot satisfy the conditions for the last couple of reviewers
	// If this is the case, the loop breaks and the list of papers is reshuffled
	local iterations = 1
	local counter = 1
	while `counter' != `= `reviewers' * `papers' + 1' { // Only false when succesfully assigned papers to all reviewers
		
		// Randomize list of papers and assignment order
		mata : A = strofreal(jumble(rev_auth_comb_mat))
		mata : st_local("reviewer_nr", invtokens(A[1...,1]'))
		mata : st_local("author_nr", invtokens(A[1...,2]'))
		
		if !`isvar' {
			mata : st_local("paper_list", invtokens(jumble(A[1...,1]')))
		}
		else {
			mata : st_local("paper_list", mm_invtokens(jumble(tokens(st_local("paper_pool"))')'))
		}
		
		// Generate author variables
		forval i = 1/`papers' {
			capture drop `var_papers'`i'
			if `isvar' & `isstring' qui gen `var_papers'`i' = "."
			else qui gen `var_papers'`i' = .	
		}
		
		// Assign papers to reviewers
		local counter = 1
		local cond_not_satisf = 0
		foreach paper of local paper_list {
			local i : word `counter' of `reviewer_nr'
			local j : word `counter' of `author_nr'
			if `isvar' & `isstring' {
				if `var_reviewer'[`i'] == "`paper'" | inlist("`paper'" `inlist_cond') { // Conditions: Student cannot read own paper or same paper more than once
					local paper_list `"`paper_list' "`paper'""' // Add paper to the end of the list
					local ++cond_not_satisf // Count times condition not satisfied
					if `cond_not_satisf' == `= `papers' * 2 ' {
						local ++iterations
						continue, break // Break and reshuffle if condition is repeatedly not satisfied
					}
					continue
				}
				qui replace `var_papers'`j' = "`paper'" in `i' // Assign paper to reviewer
				local cond_not_satisf = 0 // Reset count condition not satisfied
				local ++counter
			}
			else {
				if `var_reviewer'[`i'] == `paper' | inlist(`paper' `inlist_cond') { // Conditions: Student cannot read own paper or same paper more than once
					local paper_list `paper_list' `paper' // Add paper to the end of the list
					local ++cond_not_satisf // Count times condition not satisfied
					if `cond_not_satisf' == `= `papers' * 2 ' {
						local ++iterations
						continue, break // Break and reshuffle if condition is repeatedly not satisfied
					}
					continue
				}
				qui replace `var_papers'`j' = `paper' in `i' // Assign paper to reviewer
				local cond_not_satisf = 0 // Reset count condition not satisfied
				local ++counter
			}
		}
	}
	
	if `papers' == 1 rename `var_papers'1 `var_papers'
		
	di "Succesfully assigned all papers"
	di "Number of iterations: `iterations'"
end

// Parser for options with name suboption
cap program drop parse_name_opt
program parse_name_opt, sclass
    version 10.0
    
    syntax anything(id="integer") [, Name(name)]
	
	confirm integer number `anything'
    
	sreturn local integer `anything'
    sreturn local newvarname `name'
end
