*! 1.1.0 MLB 06 March 2013
*! 1.0.0 MLB 27 February 2013
program qenvbeta, sort rclass
	version 9 
	syntax varname(numeric) [if] [in], GENerate(str) [ reps(int 100) Level(real 95) Overall ///
	Alpha(numlist min=1 max=1 >0) Beta(numlist min=1 max=1 >0)]

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

	tokenize "`generate'"
	args lower upper garbage 
	if "`upper'" == "" | "`garbage'" != "" {
        	di as err "two names required in generate()"
	        exit 198
	}

	confirm new var `generate'
	if "`alpha'" != "" & "`beta'" == "" {
		di as err "cannot specify the alpha() option without specifying the beta() option"
		exit 198
	}
	if "`alpha'" == "" & "`beta'" != "" {
		di as err "cannot specify the beta() option without specifying the alpha() option"
		exit 198
	}
	if "`alpha'`beta'" == "" {
		capture which betafit
		if _rc {
			di as err ///
"{p}qenvbeta without the alpha() and beta() options requires betafit; betafit can be installed by typing: " as input "ssc install betafit {p_end}"
			exit 111
		}
		qui betafit `varlist' if `touse'
		local alpha = e(alpha)
		local beta  = e(beta)
		local n = e(N)
	}
	
	if c(stata_version) < 10.1 {
		local dist "&qenv_rbeta9()"
		local v = 9
	}
	else {
		local dist "&qenv_rbeta10()"
		local v = 10
	}
	
	sort `touse' `varlist' 
	mata : qenv_bound`v'("`touse'", "`generate'", `reps', `level', `dist', `n', `alpha', `beta',  `= "`overall'" != "" ')
	
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
	
	return scalar alpha = `alpha'
	return scalar beta  = `beta'
end
