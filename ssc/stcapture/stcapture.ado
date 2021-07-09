*! v 1.0.3 PR 09mar2017
program define stcapture, rclass sortpreserve
version 13.1
/*
	Stores estimated survival curves and optionally hazard ratios
	from RP model. Can be used to provide input to stpower_ct and the like.

	Optional varlist is a treatment indicator, 2 levels only.
*/
st_is 2 analysis
syntax [varlist(max=1 default=none)] [if] [in] , NPeriod(integer) ///
 [ SCale(string) df(int 5) DFTvc(int 5) dp(int 3) TScale(real 1) ]

if `df' < 1 | `df' > 10 {
	di as err "df() must be between 1 and 10"
	exit 198
}
if `nperiod' < 1 {
	di as err "ntimes() must be at least 1"
	exit 198
}
if "`scale'"=="" local scale hazard
quietly {
	if "`varlist'" != "" {
		tempvar trt
		egen int `trt' = group(`varlist') `if' `in'
		sum `trt', meanonly
		if r(max) != 2 {
			di as err "{it:trtvar} must contain exactly two distinct values, `varlist' has " r(max)
			exit 198
		}
		replace `trt' = `trt' - 1 // coded 0,1
		if `dftvc' > 0 local tdstuff dftvc(`dftvc') tvc(`trt')
	}
	marksample touse
	replace `touse' = 0 if _st==0
	count if `touse'
	local nobs = r(N)

	// If necessary, change timescale
	if `tscale' != 1 {
		replace _t = _t * `tscale'
		replace _t0 = _t0 * `tscale'
	}
	// Fit model and predict survival and hr at `nperiod' integer time-points
	stpm2 `trt' if `touse', df(`df') `tdstuff' scale(`scale') failconvlininit
	forvalues i = 1/`nperiod' {
		local periods `periods' `i'
	}
	tempvar t s0
	s_to_var `t', s(`periods')
	predict double `s0', survival timevar(`t') zeros
	var_to_s `s0', local(surv0) dp(`dp')
	// If necessary, recover timescale
	return local periods `periods'
	if "`trt'" != "" {
		tempvar s1 hrat
		predict double `s1', survival timevar(`t') at(`trt' 1)
		predict double `hrat', hrnumerator(`trt' 1) timevar(`t')
		var_to_s `s1', local(surv1) dp(`dp')
		var_to_s `hrat', local(hr) dp(`dp')
		return local surv0 `surv0'
		return local surv1 `surv1'
		return local hr `hr'
	}
	else {
		return local surv `surv0'
	}
	if `tscale' != 1 {
		replace _t = _t / `tscale'
		replace _t0 = _t0 / `tscale'
	}
	return scalar tscale = `tscale'
	return scalar nobs = `nobs'
	return scalar nperiod = `nperiod'
}
end


program define var_to_s, sortpreserve
version 12.1
/*
	Copy nonmissing values of variable to string of numbers;
	optionally round to dp decimal places
*/
syntax varname [if] [in], Local(string) [ Dp(numlist >0 max=1) ]
quietly {
	marksample touse
	// Organise nonmissing values of var to come first, preserving order of obs
	tempvar o
	gen long `o' = _n if `touse'==1
	sort `o'
	count if `touse'==1
	local n = r(N)
	local vals
	forvalues i = 1/`n' {
		if "`dp'" == "" {
			local v = `varlist'[`i']
		}
		else {
			local v = trim("`: display %20.`dp'f `varlist'[`i']'")
		}
		local vals `vals' `v'
	}
}
c_local `local' `vals'
end

program define s_to_var
version 12.1
// Copy string of numbers to new variable
syntax newvarname, s(string)
quietly {
	gen double `varlist' = .
	tokenize `s'
	local i 1
	while "``i''" != "" {
		replace `varlist' = ``i'' in `i'
		local ++i
	}
	compress `varlist'
}
end
