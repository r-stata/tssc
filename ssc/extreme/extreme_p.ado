*! extreme 1.1.0 20 January 2015
*! Copyright (C) 2015 David Roodman

* This program is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.

* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.

* You should have received a copy of the GNU General Public License
* along with this program. If not, see <http://www.gnu.org/licenses/>.

cap program drop extreme_p
program define extreme_p
	version 11.0
	syntax anything [if] [in], [xb EQuation(string) pr cdf ccdf invccdf(string)]
	if `:word count `xb' `pr' `cdf' `ccdf'' + (`"`invcdf'"'!="") > 1 {
		di as err "Only one statistic allowed per {cmd:predict} call."
		exit 198
	}
	marksample touse, novarlist
	local depvar `e(depvar)'
	if e(model)=="gpd" {
		if e(Nthresh)>1 {
			di as err "{cmd:predict} not available after multi-threshold estimation."
			exit 198
		}
		qui replace `touse'=0 if `depvar'<`e(threshold)'
	}
	else if e(Ndepvar)>1 {
		local depvar: word 1 of `e(depvar)'
		di as txt "Predicting for the maximum, `depvar'."
	}
	_score_spec `anything', equation(`equation')
	if "`s(eqspec)'"=="#1" & `"`equation'"'=="" di as txt "(" cond(e(model)=="gpd", "lnsig", "mu") " equation assumed)"
	local equation `s(eqspec)'
	local vartype: word 1 of `s(typlist)'
	local varlist `s(varlist)'
	qui if `"`pr'`cdf'`ccdf'`invccdf'"'!="" {
		tempvar mu sig xi gumbel f y x
		if e(model)=="gev" {
			if "`e(muvars)'"!="" _predict `mu' if `touse', eq(mu)
				else scalar `mu' = [mu]_cons
		}
			else gen double `mu' = `e(threshold)' if `touse'
		if "`e(sigvars)'"!="" {
			_predict `sig' if `touse', eq(lnsig)
			replace `sig' = exp(`sig') if `touse'
		}
			else scalar `sig' = exp([lnsig]_cons)
		if "`e(xivars)'"!="" {
			_predict `xi' if `touse', eq(xi)
			gen byte `gumbel' = abs(`xi')<1e-10 if `touse'
		}
		else {
			scalar `xi' = [xi]_cons
			scalar `gumbel' = abs(`xi')<1e-10
		}
		if `"`invccdf'"'!="" {
			tempvar yp
			gen double `yp' = cond(e(model)=="gpd", 1/(`invccdf'), -1/log(1-(`invccdf'))) if `touse'
			gen `vartype' `varlist' = `mu' + `sig' * cond(`gumbel', ln(`yp'), ((`yp')^(`xi')-1)/`xi') if `touse'
			label var `varlist' "Pr(`depvar'>`invccdf')"
		}
		else {
			gen double `x' = (`depvar' - `mu') / `sig' if `touse'
			gen double `y' = 1 + `xi' * `x' if `touse'
			gen double `f' = cond(`gumbel', exp(-`x'), `y'^(-1/`xi')) if `touse'
			if "`pr'"!="" {
				gen `vartype' `varlist' = cond(e(model)=="gpd", `f'/`y'/`sig', `f'/`y'/`sig'*exp(-`f')) if `touse'
				label var `varlist' "Pr(`depvar')"
			}
			else if "`cdf'"!="" {
				gen `vartype' `varlist' = cond(e(model)=="gpd", 1-`f', exp(-`f')) if `touse'
				label var `varlist' "Pr(<`depvar')"
			}
			else {
				gen `vartype' `varlist' = cond(e(model)=="gpd", `f', 1-exp(-`f')) if `touse'
				label var `varlist' "Pr(>`depvar')"
			}
		}
	}
	else {
		if "`xb'" == "" di as txt "(option xb assumed; fitted values)"
		_predict `vartype' `varlist' if `touse', eq(`equation')
	}
end
