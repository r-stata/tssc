*! 1.3.1 MLB 6 March 2013
*! 1.3.0 MLB 26 February 2013
*! 1.2.1 NJC 11 February 2013
*! 1.2.0 MLB 6 February 2013
*! 1.0.1 NJC 3 July 2012
*! 1.0.0 NJC 21 March 2012
program qenvnormal, sort rclass
	version 9
	syntax varname(numeric) [if] [in], GENerate(str) [ reps(int 100) Level(real 95) Overall ///
	Mean(numlist min=1 max=1) sd(numlist min=1 max=1 > 0) ]

	marksample touse
	qui count if `touse'
	if r(N) == 0 error 2000
	local n = r(N)

	if `level' <= 0 { 
		di as err "level() must be positive" 
		exit 198 
	} 
	else if `level' > 100 { 
		di as err "level() must not exceed 100" 
		exit 198 
	} 

	if "`mean'" != "" & "`sd'" == "" {
		di as err "cannot specify the mean() option without specifying the sd() option"
		exit 198
	} 
	if "`mean'" == "" & "`sd'" != "" {
		di as err "cannot specify the sd() option without specifying the mean() option"
		exit 198
	}
	if "`mean'`sd'" == "" {
		qui sum `varlist' if `touse'
		local mean = r(mean)
		local sd = r(sd)
	}
	
	tokenize "`generate'"
	args lower upper garbage 
	if "`upper'" == "" | "`garbage'" != "" {
        	di as err "two names required in generate()"
	        exit 198
	}

	confirm new var `generate'

	if c(stata_version) < 10.1 {
		local dist "&qenv_rnormal9()"
		local v = 9
	}
	else {
		local dist "&qenv_rnormal10()"
		local v = 10
	}
	sort `touse' `varlist' 
	mata : qenv_bound`v'("`touse'", "`generate'", `reps', `level', `dist', `n', `mean', `sd', `= "`overall'" != "" ')
	
	if "`overall'" != "" {
		if (`orate' * 100) > (100 - `level') {
			di as txt ///
"{p}not enough replications to compute overall bounds; the returned bounds have an approximate overall error rate of" as result %6.3f `orate' "{p_end}" 
		}
	}
	
	quietly { 
		count if `lower' > `lower'[_n+1] & `touse' 
		if r(N) > 0 { 
			noi di "warning: `lower' not weakly monotone increasing" 
		} 
		count if `upper' > `upper'[_n+1] & `touse' 
		if r(N) > 0 { 
			noi di "warning: `upper' not weakly monotone increasing" 
		} 
	} 
	
	return scalar mean = `mean'
	return scalar sd   = `sd'
end

