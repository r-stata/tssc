*! v 1.0.0 PR 04sep2009
program define stepp_window, rclass
gettoken cmd 0 : 0
frac_chk `cmd' 
if `s(bad)' {
	di as err "invalid or unrecognised command, `cmd'"
	exit 198
}
local dist = s(dist)
if `dist'!=7 local minv 2
else local minv 1

syntax varlist(min=`minv') [if] [in] [aw fw pw iw] , ///
 gen(string) n1(int) n2(int) [ with(varlist) TReatment(varlist) sort(varname) * ]

if "`with'" != "" {
	if "`treatment'" != "" {
		di as err "cannot have both treatment() and with() - they are synonyms"
		exit 198
	}
	local treatment `with'
}
else local with `treatment'

if !(`n1'<`n2') {
	di as err "n1() must be less than n2()"
	exit 198
}
// If treatment() is not given, regress on zstar in zstar groups (`prognostic' effect of zstar)

quietly {
	if `dist'!=7 gettoken yvar varlist: varlist
	gettoken zstar varlist: varlist
	if "`with'"!="" {
		unab zvar: `with'
		local nzvar: word count `zvar'
	}
	else {
		local zvar `zstar'
		local nzvar 1
	}
	marksample touse
	markout `touse' `yvar' `zvar'
	frac_wgt "`exp'" `touse' "`weight'"
	local wgt `r(wgt)'				/* [`weight'`exp'] */
	
	tempvar zg	// zg is grouped version of zstar
	egen long `zg' = group(`zstar') if `touse'
	sum `zg', meanonly
	local ng = r(max)
	count if `touse'
	local n = r(N)

	* Compute cutoffs and population sizes for window-oriented procedure.
	* Step 2. Find eta_t as value s.t. #of values of zg<=eta_t is >= n2.
	local eta_t 0
	forvalues i = 1/`ng' {
		count if `zg'<=`i' & `touse'==1
		if r(N)>=`n2' {
			local eta_t `i'
			continue, break
		}
	}
	if `eta_t'==0 {
		di as err "n2 = `n2' is too large"
		exit 198
	}
	local eta_upp1 `eta_t'
	local eta_low1 0	// eta_0

	local b 2
	local done 0
	while !`done' {
		* Step 3(a). Find eta_lowb.
		local bminus1 = `b'-1
		forvalues i = 1/`ng' {
			count if `zg'<=`eta_upp`bminus1'' & `zg'>`i' & `touse'==1
			if r(N)<=`n1' {
				local eta_low`b' `i'
				continue, break
			}
		}
		* Step 3(b).
		local eta_upp`b' 0
		forvalues i = 1/`ng' {
			count if `zg'<=`i' & `zg'>`eta_low`b'' & `touse'==1
			if r(N)>=`n2' {
				local eta_upp`b' `i'
				continue, break
			}
		}
		if `eta_upp`b''==0 {
			* no such eta_upp`b'. Terminate
			local eta_upp`b' `ng'
			local done 1
		}
		else local ++b
	}
	* Compute regressions
	forvalues j = 1/`nzvar' {
		if `j'==1 local jj
		else local jj `j'
		foreach thing in b se mean lb ub {
			cap drop `gen'`thing'
			gen `gen'`thing' = .
		}
	}
	* Sort so results always stored in same obs - necessary for bootstrap
	if "`sort'"!="" sort `sort'
	local Z = -invnorm((100-c(level))/200)
	forvalues i = 1/`b' {
		`cmd' `yvar' `varlist' `zvar' if `zg'>`eta_low`i'' & `zg'<=`eta_upp`i'' & `touse'==1 `wgt', `options'
		forvalues j = 1/`nzvar' {
			if `j'==1 local jj
			else local jj `j'
			local zz: word `j' of `zvar'
			cap local b = _b[`zz']
			if _rc {
				foreach thing in b se lb ub {
					local `thing' .
				}
			}
			else {
				local se = _se[`zz']
				local lb = `b'-`Z'*`se'
				local ub = `b'+`Z'*`se'
			}
			foreach thing in b se lb ub {
				replace `gen'`thing'`jj' = ``thing'' in `i'
			}
		}
		sum `zstar' if `zg'>`eta_low`i'' & `zg'<=`eta_upp`i'' & `touse'==1, meanonly
		replace `gen'mean = r(mean) in `i'
		return scalar eta_low`i' = `eta_low`i''
		return scalar eta_upp`i' = `eta_upp`i''
		return scalar P`i' = r(N)
	}
}
return scalar b = `b'
end
