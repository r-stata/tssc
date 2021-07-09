*! 1.0.0 Ariel Linden 13apr2015 
program randtreatseq, rclass
	version 13.0
	syntax , Sample(integer)  					///
	[ TReatments(numlist min=1  max=1 integer) 	///
	VALues(string asis)								/// 
	SEED(string) 								///
	REPLace ]

quietly {
	// check if data exists in memory and has not been changed 
	if c(N) > 0 & "`replace'" == "" & c(changed) {
		di as err "data in memory would be lost" 
		exit 602 
	} 

	clear
		
	// set the seed
	if "`seed'" != "" set seed `seed'
	local seed `c(seed)'

	// test whether treatments or values specified
	if "`treatments'`values'" == "" {
		di as err "either treatments or values must be specified"
		exit 198
	}
	
	if "`treatments'" != "" & "`values'" != "" {
		di as err "specify either treatments or values, not both"
		exit 198
	}

	// set the number of observations
	if "`treatments'" != "" { 
		local N = `treatments'
	}
	else if "`values'" != "" {
		local N : word count `values'
	}
	
	set obs `N'

	// randomize treatments and then reshape to wide 
	gen j = _n 
	expand `sample' 
	sort j, stable  
	by j: gen id = _n 
	tempvar rand
	gen double `rand' = runiform()
	bysort id (`rand') : gen treat = _n 
	drop `rand'
	reshape wide treat, i(id) j(j)  
	label var id "subject identifier" 

	// label values with those provided by user
	if "`values'" != "" { 
		tokenize `values'
		forval i = 1/`N' { 
			label define values `i' `"``i''"', add 
		} 

		forval j = 1/`N' { 
			label val treat`j' values 
		} 
	}
	
	// group the treatment orders 
	egen sequence = group(treat*), label
	label var sequence "treatment sequence"
	order sequence id, first
	tab sequence
	return scalar N = r(N)
	return scalar Nseq = r(r)
} 

end
