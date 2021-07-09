*! version 1.0.1 13jul2012 MJC

program stmix_pred
	version 11.2
	
	syntax newvarname [if] [in], 	[									///
										Survival 						///
										Hazard 							///
										CUMHazard						///
										CI 								///
										STDP							///
										Level(cilevel) 					///
										TIMEvar(varname) 				///
										AT(string)						///
										ZEROS							///
									]

	marksample touse, novarlist
	local newvarname `varlist'
	qui count if `touse'
	if r(N)==0 {
		error 2000          /* no observations */
	}

/* Preserve data for out of sample prediction  */	
	tempfile newvars 
	preserve	
	
	tempvar t
	
/* Use _t if option timevar not specified */
	if "`timevar'" == "" {
		gen `t' = _t
	}
	else gen `t' = `timevar'

/*** Baseline predictions ***/
	if "`zeros'"!="" {
		foreach var in `e(varlist)' `e(lambda1)' `e(gamma1)' `e(lambda2)' `e(gamma2)' `e(pmix)' {
			if `"`: list posof `"`var'"' in at'"' == "0" { 
				qui replace `var' = 0 if `touse'
			}
		}
	}	
	
/* Out of sample predictions using at() */
	if "`at'" != "" {
		tokenize `at'
		while "`1'"!="" {
			unab 1: `1'
			cap confirm var `2'
			if _rc {
				cap confirm num `2'
				if _rc {
					di in red "invalid at(... `1' `2' ...)"
					exit 198
				}
			}
			qui replace `1' = `2' if `touse'
			mac shift 2
		}
	}	
	
/* CI option */
	if "`ci'"!="" {
		local ciopt "ci(`newvarname'_lci `newvarname'_uci)"
	}
	
	if "`stdp'"!="" {
		local ciopt "se(`newvarname'_se)"
	}
	
	if wordcount(`"`hazard' `survival' `cumhazard'"')>1 {
		di as error "Can only specify one of hazard/survival/cumhazard"
		exit 198
	}
	
	if wordcount(`"`hazard' `survival' `cumhazard'"')==0 {
		di as error "No statistic has been specified"
		exit 198
	}	
	
	if wordcount(`"`ci' `stdp'"')>1 {
		di as error "Can only specify one of ci/stdp"
		exit 198
	}
	
	/* Distribution */
	local dist "`e(distribution)'"
	if "`dist'"=="we" {
		local g2 = 1
	}
	else{
		local g2 "exp(xb(ln_gamma2))"
	}
	
	/* Prediction */
	
		local p "invlogit(xb(logit_p_mix))"
		local l1 "exp(xb(ln_lambda1))"
		local g1 "exp(xb(ln_gamma1))"
		local l2 "exp(xb(ln_lambda2))"
		if "`e(varlist)'"!="" local covs "* exp(xb(xb))"

		if "`hazard'"!="" {
			local numer "(`l1'*`g1'*`p'*`t'^(`g1'-1)*exp(-`l1'*`t'^`g1') + (1-`p')*`l2'*`g2'*`t'^(`g2'-1)*exp(-`l2'*`t'^`g2')) `covs'"
			local denom "`p'*exp(-`l1'*`t'^`g1') + (1-`p')*exp(-`l2'*`t'^`g2')"
			qui predictnl `newvarname' = (`numer')/(`denom') if `touse', `ciopt' level(`level')
		}
		
		if "`survival'"!="" {
			qui predictnl double `newvarname' = exp(log(`p'*exp(-`l1'*`t'^`g1') + (1-`p')*exp(-`l2'*`t'^`g2')) `covs') if `touse', `ciopt' level(`level')
		}
		
		if "`cumhazard'"!="" {
			qui predictnl double `newvarname' = -log(`p'*exp(-`l1'*`t'^`g1') + (1-`p')*exp(-`l2'*`t'^`g2')) `covs' if `touse', `ciopt' level(`level')
		}
	
	/* restore original data and merge in new variables */
		if "`hazard'"!="" | "`survival'"!="" | "`cumhazard'"!=""{
			local keep `newvarname'
		}
		if "`ci'" != "" { 
			local keep `keep' `newvarname'_lci `newvarname'_uci
		}
		if "`stdp'"!="" {
			local keep `keep' `newvarname'_se
		}

		keep `keep'
		qui save `newvars'
		restore
		merge 1:1 _n using `newvars', nogenerate noreport
	
end
