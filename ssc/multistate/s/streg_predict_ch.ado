



program streg_predict_ch, sortpreserve
	syntax newvarname(max=1)	,	[									///
										zeros							///
										at(string)						///
										touse2(string)					///
										timevar(string)					///
										variance(passthru)				///
									]
				
	local newvarname `varlist'
	su `timevar'
	
	local cmdline `e(cmdline)'
	gettoken cmd 0 : cmdline
	syntax [varlist(default=empty)] [if] [in], [ANCillary(varlist) *]
	local vars `varlist' `ancillary'
	
	if "`zeros'" != "" {
		foreach var in `vars' {
			qui replace `var' = 0 if `touse2'
		}
	}
	
	if "`at'" != "" {
		tokenize `at'
		while "`1'"!="" {
			cap confirm var `2'
			if _rc {
				cap confirm num `2'
				if _rc {
						di as err "invalid at(... `1' `2' ...)"
						exit 198
				}
			}
			qui replace `1' = `2' if `touse2'
			mac shift 2
		}
	}

	if "`variance'"=="" {
		if "`e(cmd)'"=="ereg" {
			predictnl double `newvarname' = xb(_t) + log(`timevar') if `touse2'
		}
		else if "`e(cmd)'"=="weibull" {
			predictnl double `newvarname' = xb(_t) +  exp(xb(ln_p))*log(`timevar') if `touse2'
		}
		else if "`e(cmd)'"=="gompertz" {
			predictnl double `newvarname' = log(exp(xb(_t))/xb(gamma)*(exp(xb(gamma)*`timevar')-1)) if `touse2'
		}
		else if "`e(cmd)'"=="lnormal" {
			predictnl double `newvarname' = log(-log(1-normal((log(`timevar')-xb(_t))/exp(xb(ln_sig))))) if `touse2'
		}
		else if "`e(cmd)'"=="llogistic" {
			predictnl double `newvarname' = log(-log(1/(1+(exp(-xb(_t))*`timevar')^(1/exp(xb(ln_gam)))))) if `touse2'
		}
		replace `newvarname' = exp(`newvarname') if `touse2'
	}
	else {
		if "`e(cmd)'"=="ereg" {
			predictnl double `newvarname' = exp(xb(_t) + log(`timevar')) if `touse2', `variance'
		}
		else if "`e(cmd)'"=="weibull" {
			predictnl double `newvarname' = exp(xb(_t) +  exp(xb(ln_p))*log(`timevar')) if `touse2', `variance'
		}
		else if "`e(cmd)'"=="gompertz" {
			predictnl double `newvarname' = exp(xb(_t))/xb(gamma)*(exp(xb(gamma)*`timevar')-1) if `touse2', `variance'
		}
		else if "`e(cmd)'"=="lnormal" {
			predictnl double `newvarname' = -log(1-normal((log(`timevar')-xb(_t))/exp(xb(ln_sig)))) if `touse2', `variance'
		}
		else if "`e(cmd)'"=="llogistic" {
			predictnl double `newvarname' = -log(1/(1+(exp(-xb(_t))*`timevar')^(1/exp(xb(ln_gam))))) if `touse2', `variance'
		}
	}
						
							
end



