*! version 1.5.0 12Aug2011 MLB
program define hangr_parsesample
	syntax [varname]                       ///
	       , dist(string) touse(varname)   ///
		   [ groupvar(varname) sims(varlist)]
	
	local k : word count `sims'
	tokenize `sims'
	tempvar out
	//exponential, poisson, nb1, nb2, zip, zinb, geometric, lognormal, weibull, and gamma only valid for values >= 0
	if "`dist'" == "exponential" | ///
	   "`dist'" == "poisson"     | ///
	   "`dist'" == "nb1"         | /// 
	   "`dist'" == "nb2"         | ///
	   "`dist'" == "zip"         | /// 
	   "`dist'" == "zinb"        | ///
	   "`dist'" == "geometric"   | ///
	   "`dist'" == "lognormal"   | ///
	   "`dist'" == "weibull"     | ///
	   "`dist'" == "gamma"       | ///
	   "`dist'" == "chi2" {
		qui count if `varlist' < 0 & `touse'
		if r(N) > 0 {
			local s = cond(r(N)>1,"s","")
			local have = cond(r(N)>1,"have","has")
			local these = cond(r(N)>1,"these","this")
			di as txt "warning: `r(N)' observation`s' `have' a value less than 0"
			di as txt "`these' observation`s' will be ignored"
		}
		qui gen byte `out' = 0 if `varlist' >= 0 /* missing means do not use*/
		forvalues i = 1/`k' {
			qui count if ``i'' < 0 & `touse'
			if r(N) > 0 {
				di as err "simulation `i' has observations less than 0"
				exit 198
			}
		}
	}

	// pareto, invgamma, wald, fisk, dagum, sm, and gb2  only valid for values > 0
	if "`dist'" == "pareto"   | ///
	   "`dist'" == "invgamma" | ///
	   "`dist'" == "wald"     | ///
	   "`dist'" == "fisk"     | ///
	   "`dist'" == "dagum"    | ///
	   "`dist'" == "sm"       | ///
	   "`dist'" == "gb2" {
		qui count if `varlist' <= 0 & `touse'
		if r(N) > 0 {
			local s = cond(r(N)>1,"s","")
			local have = cond(r(N)>1,"have","has")
			local these = cond(r(N)>1,"these","this")
			di as txt "warning: `r(N)' observation`s' `have' a value less than"
			di as txt "or equal to 0, `these' observation`s' will be ignored"
		}
		qui gen byte `out' = 0 if `varlist' > 0 /* missing means do not use*/
		forvalues i = 1/`k' {
			qui count if ``i'' <= 0 & `touse'
			if r(N) > 0 {
				di as err "simulation `i' has observations less than or equal to 0"
				exit 198
			}
		}
	}
	
	// beta only valid for values > 0 & < 1
	if "`dist'" == "beta" {
		qui count if (`varlist' <= 0 | `varlist' >= 1) & `touse'
		if r(N) > 0 {
			local s = cond(r(N)>1,"s","")
			local have = cond(r(N)>1,"have","has")
			local these = cond(r(N)>1,"these","this")
			di as txt "warning: `r(N)' observation`s' `have' a value less than or equal to 0"
			di as txt "or more than or equal to 1, `these' observation`s' will be ignored"
		}
		qui gen byte `out' = 0 if  (`varlist' > 0 & `varlist' < 1) /* missing means do not use*/
		forvalues i = 1/`k' {
			qui count if ( ``i'' <= 0 | ``i'' >= 1 ) & `touse'
			if r(N) > 0 {
				di as err "simulation `i' has observations less than or equal to 0"
				di as err "or observations larger than or equal to 1"
				exit 198
			}
		}		
	}
	// zoib only valid for values >= 0 & <= 1
	if "`dist'" == "zoib" {
		qui count if (`varlist' < 0 | `varlist' > 1) & `touse'
		if r(N) > 0 {
			local s = cond(r(N)>1,"s","")
			local have = cond(r(N)>1,"have","has")
			local these = cond(r(N)>1,"these","this")
			di as txt "warning: `r(N)' observation`s' `have' a value less than 0"
			di as txt "or more than 1, `these' observation`s' will be ignored"
		}
		qui gen byte `out' = 0 if  (`varlist' >= 0 & `varlist' <= 1) /* missing means do not use*/
		forvalues i = 1/`k' {
			qui count if ( ``i'' < 0 | ``i'' > 1 ) & `touse'
			if r(N) > 0 {
				di as err "simulation `i' has observations less than 0"
				di as err "or observations larger than 1"
				exit 198
			}
		}		
	}
	// zib only valid for values >= 0 & < 1
	if "`dist'" == "zib" {
		qui count if (`varlist' < 0 | `varlist' >= 1) & `touse'
		if r(N) > 0 {
			local s = cond(r(N)>1,"s","")
			local have = cond(r(N)>1,"have","has")
			local these = cond(r(N)>1,"these","this")
			di as txt "warning: `r(N)' observation`s' `have' a value less 0"
			di as txt "or more than or equal to 1, `these' observation`s' will be ignored"
		}
		qui gen byte `out' = 0 if  (`varlist' >= 0 & `varlist' < 1) /* missing means do not use*/
		forvalues i = 1/`k' {
			qui count if ( ``i'' < 0 | ``i'' >= 1 ) & `touse'
			if r(N) > 0 {
				di as err "simulation `i' has observations less 0"
				di as err "or observations larger than or equal to 1"
				exit 198
			}
		}		
	}
	// oib only valid for values > 0 & <= 1
	if "`dist'" == "oib" {
		qui count if (`varlist' <= 0 | `varlist' > 1) & `touse'
		if r(N) > 0 {
			local s = cond(r(N)>1,"s","")
			local have = cond(r(N)>1,"have","has")
			local these = cond(r(N)>1,"these","this")
			di as txt "warning: `r(N)' observation`s' `have' a value less than or equal to 0"
			di as txt "or more than 1, `these' observation`s' will be ignored"
		}
		qui gen byte `out' = 0 if  (`varlist' > 0 & `varlist' <= 1) /* missing means do not use*/
		forvalues i = 1/`k' {
			qui count if ( ``i'' <= 0 | ``i'' > 1 ) & `touse'
			if r(N) > 0 {
				di as err "simulation `i' has observations less than or equal to 0"
				di as err "or observations larger than 1"
				exit 198
			}
		}		
	}	
	
	
	//poisson, geometric, negative binomial, zip, zinb only valid for discrete values (including 0)
	if "`dist'" == "poisson"    | ///
	   "`dist'" == "zip"        | ///
	   "`dist'" == "zinb"       | ///
	   "`dist'" == "geometric"  | ///
	   "`dist'" == "nb1"        | ///
	   "`dist'" == "nb2"        {
		qui count if mod(`varlist',1) != 0 & `touse'
		if r(N) > 0 {
			local s = cond(r(N)>1,"s","")
			local these = cond(r(N)>1,"these","this")
			di as txt "warning: `r(N)' observation`s' have a non-integer value"
			di as txt "`these' observation`s' will be ignored"
		}
		qui replace `out' = . if mod(`varlist',1) != 0  /* missing means do not use*/
		forvalues i = 1/`k' {
			qui count if mod(``i'', 1) != 0 & `touse'
			if r(N) > 0 {
				di as err "simulation `i' has non-integer observations"
				exit 198
			}
		}
	}
	if !inlist("`dist'", "normal", "logistic", "laplace", "uniform", "gev", "gumbel", "theoretical") {
		markout `touse' `out'
	}
	qui count if `touse'
	if r(N) == 0 {
		error 2000
	}
	if "`dist'" == "theoretical" {
		qui count if `touse' & `groupvar'
		if r(N) == 0 {
			di as err "No observations for `groupvar' is true (not 0)"
			exit 2000
		}
		qui count if `touse' & !`groupvar' 
		if r(N) == 0 {
			di as err "No observations for `groupvar' is false (0)"
			exit 2000
		}
	}
	
	end
