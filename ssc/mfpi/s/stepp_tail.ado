*! v 1.0.2 PR 04sep2009
program define stepp_tail, rclass
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
 gen(string) g(int) [ with(varlist) TReatment(varlist) sort(varname) * ]

if "`with'" != "" {
	if "`treatment'" != "" {
		di as err "cannot have both treatment() and with() - they are synonyms"
		exit 198
	}
	local treatment `with'
}
else local with `treatment'

if `g'<2 {
	di as err "g must be greater than 1"
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
	* tail oriented with g groups
	* Find g-1 cutoffs eta1,...,eta(g-1)
	local g1 = `g'-1
	forvalues i = 1/`g1' {
		local c = 100*`i'/`g'
		centile `zg', centile(`c')
		local eta`i' = r(c_1)
	}
	local eta`g' `ng'
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
	forvalues i = 1/`g' {
		`cmd' `yvar' `varlist' `zvar' if `zg'<=`eta`i'' & `touse'==1 `wgt', `options'
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
		sum `zstar' if `zg'<=`eta`i'', meanonly
		replace `gen'mean = r(mean) in `i'
		return scalar P`i' = r(N)
		return scalar eta`i' = `eta`i''
		if `i'<`g' {
			local k = `i'+`g'
			`cmd' `yvar' `varlist' `zvar' if `zg'>`eta`i'' & `touse'==1 `wgt', `options'
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
					replace `gen'`thing'`jj' = ``thing'' in `k'
				}
			}
			sum `zstar' if `zg'>`eta`i'' & `touse'==1, meanonly
			replace `gen'mean = r(mean) in `k'
			return scalar P`k' = r(N)
		}
	}
}
return scalar g = `g'
return scalar groups = 2*`g'-1
end
