*! v 1.1.3 PR 08feb2007
program define str2ph, rclass
version 8
gettoken cmd 0 : 0, parse(" ,")
* currently supported commands
if !("`cmd'"=="stcox" | "`cmd'"=="stpm" | "`cmd'"=="streg") {
	if missing("`cmd'") di as error "survival command required"
	else di as error "unsupported or unrecognised command, `cmd'"
	exit 198
}
syntax [varlist(default=none numeric)] [if] [in] [, ///
 ADJust DENominator VALidate(varname) BOotreps(int 0) bootdf(int 0) ///
 OFFset(varname) CALibrate noDOTs RANDomness BSample *]
if "`validate'"!="" & "`adjust'"!="" {
	di as err "you may not use validate() and adjust options together"
	exit 198
}
if "`offset'"!="" local OFF offset(`offset')
quietly {
	marksample touse
	if "`validate'"!="" {
		// estimate on lower value of varname, predict index, validate index on higher value
		markout `touse' `validate' `offset', strok
		tempvar valgrp
		egen byte `valgrp'=group(`validate') if `touse'
		sum `valgrp', meanonly
		if r(max)!=2 {
			di as err "validate() variable `validate' must have exactly 2 distinct values"
			exit 198
		}
		local if1 if `valgrp'==1 & `touse'==1
		local if2 if `valgrp'==2 & `touse'==1
	}
	else {
		markout `touse' `offset'
		local if1 if `touse'==1
		local if2 if `touse'==1
	}
	// Estimate model
	if "`cmd'"=="stcox" local EST estimate
	if "`bsample'"!="" {
		preserve
		bsample
	}
	`cmd' `varlist' `if1', `options' `EST' `OFF'
	local dev=-2*e(ll)
	if ("`cmd'"=="streg" & !("`e(cmd)'"=="ereg" | "`e(cmd)'"=="weibull"  | "`e(cmd)'"=="gompertz")) ///
		 | ("`cmd'"=="stpm" & "`e(scale)'"!="0") {
		noi di as txt "[warning: not a proportional hazards model]"
	}
	tempname vce sigma2
	if "`randomness'"=="" 	scalar `sigma2'=_pi^2/6
	else 			scalar `sigma2'=1
	* Extract VCE matrix
	matrix `vce'=e(V)
	if "`cmd'"=="stpm" {
		matrix `vce'=`vce'["xb:","xb:"]
		if "`e(scale)'"=="0" 		local scale hazard
		else if "`e(scale)'"=="1" 	local scale normal
		else 				local scale odds
		local model "Flexible parametric model with scale `scale'"
		local eqxb [xb]
	}
	else if "`cmd'"=="streg" {
		matrix `vce'=`vce'["_t:","_t:"]
		local model `e(title)'
		local eqxb
	}
	else if "`cmd'"=="stcox" {
		local scale hazard
		local model Cox model
		local eqxb
	}
	* If hidden option bootdf is >0, adjust is ignored. Needed for bootstrap calcs.
	if `bootdf'==0 & "`adjust'"!="" {
		* Find model dimension to adjust chisquared with
		if "`calibrate'"!="" local bootdf 1
		else {
			local rn: rownames `vce'
			local cons _cons
			local rn: list rn - cons	// has no effect on cox model
			local bootdf: word count `rn'
		}
	}

	* Predict index on all available obs
	// if bsample done, predict on original sample
	if "`bsample'"!="" restore
	tempvar xb
	predict `xb', xb
/*
	// Probably should not recalibrate in boot sample
	if "`bsample'"!="" {
		`cmd' `xb' `if2', `options' `EST' `OFF'
		replace `xb' = `xb'*`eqxb'_b[`xb']
	}
*/
	tempname tmp
	estimates store `tmp'
	count `if2'
	local n=r(N)
	count `if2' & _d==1
	local ev0=r(N)
	if "`denominator'"!="" {
		tempname alpha
		scalar `alpha'=5/6	// provisional: see c216\r2adjust.do/sto
		local ev0=`n'*(`ev0'/`n')^`alpha'
	}

	* Variance of index
	sum `xb' `if2'
	local A=r(Var)

	* Compute R2
	* Fit null model
	`cmd' `if2', `EST' `options'
	local dev0=-2*e(ll)

/*
	Fit index on appropriate sample (all; or validation sample).
	Note: in non-validation case, both cmds below give the same deviance,
	which equals that obtained when fitting the original model.

	Strictly speaking, don't need to refit the model in the
	non-validation case, but needed for validation case, and complicated
	to get things right with the bootrep() option unless refit.
*/
	if "`calibrate'"!="" {
		`cmd' `xb' `if2', `options'
		local c=`eqxb'_b[`xb']
		local cse=`eqxb'_se[`xb']
	}
	else `cmd' `if2', `EST' offset(`xb') `options'
	local dev=-2*e(ll)
	local chi2=(`dev0'-`dev')-`bootdf'
	local nag=1-exp(-`chi2'/`ev0')
	local v=`nag'/(1-`nag')
	if "`randomness'"=="" 	local r2=`v'/(`sigma2'+`v')
	else			local r2 `nag'
	if `bootreps'>0{		// bootstrap se
		tempname pf
		tempfile tf
		postfile `pf' r2 using `tf', replace
		forvalues j=1/`bootreps' {
			preserve
			bsample
			if "`validate'"=="" {
				str2ph `cmd' `varlist' `if1', `options' bootdf(`bootdf') `randomness' `OFF'
			}
			else {
				if "`calibrate'"!="" str2ph `cmd' `xb' `if2', `options' `randomness'
				else str2ph `cmd' `if2', `options' `randomness' offset(`xb')
			}
			post `pf' (r(r2))
			restore
			if "`dots'"!="nodots" {
				if mod(`j',100)==0 noi di as txt "." _cont
			}
		}
		if "`dots'"!="nodots" noi di
		postclose `pf'
		local pl=(100-$S_level)/2
		local pu=100-`pl'
		preserve
		use `tf', replace
		centile r2, centile(`pl' `pu')
		local r2ll=r(c_1)
		local r2ul=r(c_2)
		sum r2
		local se=r(sd)
		restore
	}
	else {
		local se .
		local r2ll .
		local r2ul .
	}
	estimates restore `tmp'
}
if "`randomness'"!="" local title "R^2 (explained randomness)"
else local title "R^2 (explained variation)"
if "`adjust'"=="" local r2tit "  R^2"
else local r2tit "Adj. R^2"
di _n as text "`title': `model'"
di as text _n _col(4) "Obs" _col(11) "Events" ///
 _col(20) "`r2tit'" _col(32) "Boot. SE" _col(43) "${S_level}% conf. interval" _n ///
 "{hline 60}"
di as res %6.0f `n' %9.0f `ev0' %12.6f `r2' %12.6f `se' %11.6f `r2ll' %10.6f `r2ul'
di as text "{hline 60}"
if "`validate'"!="" {
	di as txt "Note: model estimated at low value of `validate', evaluated at high value"
	if "`calibrate'"!="" di as text "Note: calibrated on index in validation sample"
	else di as text "Note: index offset from linear predictor in validation sample"
}
return scalar r2=`r2'
return scalar r2aw=`A'/(1+`A')
return scalar r2pm=`A'/(_pi^2/6+`A')
return scalar chi2=`chi2'
return scalar V=`v'
return scalar Dprime=sqrt(`v'*8/_pi)
return scalar events=`ev0'
return scalar N=`n'
return scalar r2ll=`r2ll'
return scalar r2ul=`r2ul'
return scalar r2se=`se'
if "`calibrate'"!="" {
	return scalar c=`c'
	return scalar cse=`cse'
}
end
