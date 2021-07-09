*! v 1.0.0 PR/WvP 24may2013
/*
	Simplified version of WvP ira.ado, last updated 26/10/2012.
	Temporary variables:
	 PART     to define the current partition in merged sets.
	 VIOL     to detect a violation of the required ordering
	          and the need for an additional merge.
	 M        mean of response variable.
*/
program define irax, sortpreserve
quietly {
	version 11.0
	syntax varlist(min=2 max=2 numeric) [if] [in] ///
	 [, COMbine GENerate(string) noPTs REVerse ci noGRaph *]
	if "`generate'" != "" {
		gettoken generate rest : generate, parse(" ,")
		tokenize `"`rest'"', parse(" ,")
		while "`1'" != "" {
			if "`1'" == "replace" {
				local gen_replace replace
				continue, break
			}
			mac shift
		}
	}
	marksample touse

	gettoken y xvar : varlist
	sum `y' if `touse', meanonly
	if r(min) == r(max) {
		di as err "`y' does not vary"
		exit 198
	}
	local mean_y = r(mean)
	count if (`touse'==1) & !inlist(`y', 0, 1)
	if (r(N)==0) local type LR 	// Logistic regression
	else local type LINR		// Linear regression
	noi di _n as txt "type = `type'"
	tempvar PART VIOL HR M x
	if "`reverse'"=="" {
		gen `x' = -`xvar' if `touse'
	}
	else gen `x' = `xvar' if `touse'
	gen int `PART' = 1 if `touse'==1
	sort `PART' `x' `y'
	replace `PART' = `PART'[_n-1] + (`x' > `x'[_n-1]) if !missing(`PART') & _n > 1
	if "`reverse'"=="" {
		replace `x' = -`x'
	}
	sort `PART'
	by `PART': gen `M' = sum(`y') if !missing(`PART')
	by `PART': replace `M' = `M'[_N] / _N
	gen int `VIOL' = sum((`M' >= `M'[_n-1]) & (`PART'>`PART'[_n-1]) & !missing(`PART'))
	while `VIOL'[_N] != 0 {
	   replace `PART' = `PART'[_n-1] + (`M' < `M'[_n-1]) if !missing(`PART') & _n > 1
	   sort `PART'
	   by `PART': replace `M' = sum(`y') if !missing(`PART')
	   by `PART': replace `M' = `M'[_N] / _N
	   replace `VIOL' = sum((`M' >= `M'[_n-1]) & (`PART' > `PART'[_n-1]) & !missing(`PART'))
	}
	if ("`type'"=="LR") label variable `M' "Event probability"
	else if ("`type'"=="LINR") label variable `M' "Mean of `y'"
	if "`combine'" != "" {
		// For the -combine- option, need to create the "other" curve
		if ("`reverse'" == "") local Reverse reverse
		tempvar tempfit
		irax `y' `xvar' if `touse', `Reverse' nograph generate(`tempfit', replace)
		replace `M' = `M' + `tempfit' - `mean_y'
		drop `tempfit' `tempfit'_p
		// Update partition to one based on the new mean-y groups
		drop `PART'
		egen int `PART' = group(`M') if `touse'
	/*
		// Not clear if we should best re-estimate mean for new partition. Can easily be done:
		drop `M'
		sort `PART'
		by `PART': gen `M' = sum(`y') if !missing(`PART')
		by `PART': replace `M' = `M'[_N] / _N		
	*/
	}
	if "`ci'" != "" {
		// Crude pointwise CI from partition model
		tempvar se lci uci
		tempname z
		scalar `z' = invnormal((100 + c(level))/200)
		if "`type'"=="LR" {
			local cmd logit
			local backtransf invlogit
			local transf logit
		}
		else {
			local cmd regress
		}
		`cmd' `y' ibn.`PART' if `touse'
		predict `se' if `touse', stdp
		gen `lci' = `backtransf'(`transf'(`M') - `z' * `se')
		gen `uci' = `backtransf'(`transf'(`M') + `z' * `se')
		drop `se'
	}
/*
	Create graph.
*/
	if "`graph'" != "nograph" {
		local title Isotonic Regression Analysis
		if ("`combine'" != "") local title `title' (extended)
		if "`type'" == "LINR" {
			local varlab: var lab `y'
			if ("`varlab'"=="" | index("`varlab'", ")") > 0) local varlab `y'
			local yplot = cond("`pts'" == "nopts", "", "`y'")
			if "`ci'" == "" {
				scatter `M' `yplot' `xvar' if `touse', sort connect(J .) msymbol(i oh) ///
				 title(`title') ytitle("`varlab'") `options'
			}
			else {
				scatter `M' `lci' `uci' `yplot' `xvar' if `touse', sort connect(J J J .) lpattern(l shortdash ..) ///
				 cmissing(y n n) msymbol(i i i oh) title(`title') ytitle("`varlab'") legend(off) `options'
			}
		}
		else {
			if "`ci'" == "" {
				line `M' `xvar' if `touse', sort connect(J) title(`title') `options'
			}
			else {
				line `M' `lci' `uci' `xvar' if `touse', sort connect(J J J) lpattern(l shortdash ..) ///
				 cmissing(y n n) title(`title') legend(off) `options'
			}
		}
	}
	if "`generate'" != "" {
		local lab : var lab `M'
		compute `generate' = `M', `gen_replace' label("`lab'")
		noi di as txt "[variable `generate' created]"
		compute `generate'_p = `PART', `gen_replace' label("partition of `xvar'")
		noi di as txt "[variable `generate'_p created]"
		if "`ci'" != "" {
			compute `generate'_lci = `lci', `gen_replace' label("lower CL for `lab'")
			compute `generate'_uci = `uci', `gen_replace' label("upper CL for `lab'")
			noi di as txt "[variables `generate'_lci and `generate'_uci created]"
		}
	}
}
end

* v 1.0.1 PR 03mar2013
program define compute
version 8.0
gettoken type 0 : 0, parse("= ") bind
// Process putative type
local ok 0
foreach t in byte int long float double {
	if "`t'" == "`type'" {
		local ok 1
		continue, break
	}
}
if !`ok' {
	if substr("`type'", 1, 3) == "str" {
		local strn = substr("`type'", 4, .)
		confirm integer number `strn'
		local ok 1
	}
}
if !`ok' {
	local newvar `type'
	local type
}
else gettoken newvar 0 : 0, parse("= ") bind
gettoken eqs 0 : 0, parse("= ")
if "`eqs'" != "=" {
	di "{p}{err}syntax is {cmd:compute [{it:type}] {it:existing_var}|{it:newvar} = {it:exp}}" ///
	 " [, {cmd:replace} {cmd:force} {cmd:label(}{it:label}{cmd:)}]{p_end}"
	 exit 198
}
gettoken Exp 0 : 0, parse(", ") bind
syntax [if] [in] [, replace LABel(string) force ]
if "`type'" != "" {
	local ok 0
	foreach t in byte int long float double {
		if "`t'" == "`type'" {
			local ok 1
			continue, break
		}
	}
	if !`ok' {
		if substr("`type'", 1, 3) == "str" {
			local strn = substr("`type'", 4, .)
			confirm integer number `strn'
			local ok 1
		}
	}
	if !`ok' {
		di as err "type `type' not recognized"
		exit 198
	}
}
capture confirm var `newvar', exact
local rc = c(rc)
if `rc' != 0 {
	// `newvar' does not exist; safe to create it from `Exp'
	generate `type' `newvar' = `Exp' `if' `in'
}
else {
	// `newvar' exists
	if "`replace'" != "" {
		// safe to recreate `newvar'
		replace `newvar' = `Exp' `if' `in'
		if "`type'" != "" {
			recast `type' `newvar', `force'
		}
	}
	else {
		di as err "`newvar' already defined"
		exit 110
	}
}
if "`label'" != "" {
	label var `newvar' "`label'"
}
end

