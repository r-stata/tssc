*! -rsort- version 1.0 Phil Clayton 2013-04-22
* reproducible random sorting of dataset

capture program drop rsort
program define rsort, rclass
	version 12
	syntax, [id(varlist)    /// variable/s uniquely identifying observations
			 seed(string)   /// random number seed to use
			 by(varlist)    /// variable/s defining groups within which to sort
			 GENerate(name) /// variable containing new observation number
			 replace]       //  replace existing variable

	* if generate() but not replace specified, confirm new variable doesn't exist
	if "`generate'"!="" & "`replace'"=="" confirm new variable `generate'

	* provide a warning if id & seed not specified
	if "`id'"=="" | "`seed'"=="" {
		di as result "Note: For reproducible sorting you should specify id() and seed()"
	}
	
	* confirm ID is unique (within by-groups) and sort by ID
	if "`id'"!="" {
		quietly isid `by' `id', sort missok
	}
	
	* set seed if specified
	if "`seed'"!="" set seed `seed'
	
	* generate up to 10 random numbers to sort the dataset
	* (should be vanishingly rare to need >2)
	local success=0
	local i=1 // iteration
	while `success'==0 & `i'<=10 {
		tempvar rs`i'
		gen double `rs`i''=runiform()
		local sortvars `sortvars' `rs`i++''
		capture isid `by' `sortvars', sort missok
		if !_rc {
			local success=1
			if "`by'"!="" local bytext " within groups defined by `by'"
			di as text "(data now sorted randomly`bytext')"
		}
	}

	* error if sorting not successful
	if `success'==0 {
		di as error "Unable to sort dataset using 10 random variables"
		error 498
	}
	
	* create new variable containing new obs number if requested
	if "`generate'"!="" {
		capture drop `generate' // safe because we already checked for variable
		gen long `generate'=_n
		quietly compress `generate'
	}
end
