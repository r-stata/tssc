*! v 2.0.0 PR 14may2013
program define str2d, eclass
	version 11.0
	local cmdline : copy local 0
	mata: _parse_colon("hascolon", "rhscmd")
	if !`hascolon' error 198

	_str2d `"`0'"' `"`rhscmd'"'

	ereturn local cmdline `"str2d2 `cmdline'"'
end

program define _str2d, rclass
version 11.0
args 0 statacmd

gettoken cmd statacmd: statacmd
if substr("`cmd'", -1, .) == "," {
	local cmd = substr("`cmd'", 1, length("`cmd'") - 1)
	local statacmd ,`statacmd'
}
// currently supported commands
if !inlist("`cmd'", "stcox", "stpm", "stpm2", "streg") {
	if missing("`cmd'") di as error "survival command required"
	else di as error "unsupported or unrecognised command, `cmd'"
	exit 198
}

// Parse str2d options from first argument
syntax [, ADJust VALidate(varname) EXClude(varlist) ///
 BOotreps(int 0) noDOTs RANDomness BSample MODeldim(int 0)]
if "`validate'" != "" & "`adjust'" != "" {
	di as err "you may not use validate and adjust options together"
	exit 198
}
if (`modeldim' < 0) | (`modeldim' > 0 & "`adjust'" == "") {
	di as txt "[modeldim(`modeldim') ignored]"
	local modeldim 0
}
quietly {
	// Parse Stata command
	local 0 `statacmd'
	syntax varlist(min=1 numeric) [if] [in] [, DEAD(string) noCONStant * ]
	if !missing("`dead'") local options `options' dead(`dead')
	if !missing("`constant'") local options `options' `constant'
	marksample touse
	if "`validate'" != "" {
		// estimate on lower value of varname, predict index, validate index on higher value
		markout `touse' `validate', strok
		sum `validate' if `touse', meanonly
		local val_lo = r(min)
		local val_hi = r(max)
		tempvar valgrp
		egen byte `valgrp' = group(`validate') if `touse'
		sum `valgrp', meanonly
		if r(max) != 2 {
			di as err "validate() variable `validate' must have exactly 2 distinct values"
			exit 198
		}
		local if1 if `valgrp'==1 & `touse'==1
		local if2 if `valgrp'==2 & `touse'==1
	}
	else {
		local if1 if `touse'==1
		local if2 if `touse'==1
	}
	// Estimate model
	if "`bsample'" != "" {
		preserve
		bsample
	}
	`cmd' `varlist' `exclude' `if1', `options'
	if ("`cmd'"=="streg" & !("`e(cmd)'"=="ereg" | "`e(cmd)'"=="weibull"  | "`e(cmd)'"=="gompertz")) ///
		 | ("`cmd'"=="stpm" & "`e(scale)'" != "0") ///
		 | ("`cmd'"=="stpm2" & "`e(scale)'" != "hazard") {
		noi di as txt "[warning: not a proportional hazards model]"
	}
	tempname vce sigma2
	// Extract VCE matrix
	matrix `vce' = e(V)
	if "`cmd'"=="stpm" {
		matrix `vce' = `vce'["xb:","xb:"]
		if "`e(scale)'"=="0" 		local scale hazard
		else if "`e(scale)'"=="1" 	local scale normal
		else 				local scale odds
		local model "Flexible parametric model with scale `scale'"
		local eqxb [xb]
	}
	else if "`cmd'"=="stpm2" {
		matrix `vce' = `vce'["xb:","xb:"]
		local scale `e(scale)'
		local model "Flexible parametric model with scale `scale'"
		local eqxb [xb]
	}
	else if "`cmd'"=="streg" {
		if "`e(cmd)'"=="ereg" | "`e(cmd)'"=="weibull"  | "`e(cmd)'"=="gompertz" ///
						local scale hazard
		else if "`e(cmd)'"=="llogistic" local scale odds
		else if "`e(cmd)'"=="lnormal" 	local scale normal
		else {
			noi di as err "distribution `e(cmd)' not supported"
			exit 198
		}
		matrix `vce' = `vce'["_t:","_t:"]
		local model `e(title)'
		local eqxb
	}
	else if "`cmd'"=="stcox" {
		local scale hazard
		local model Cox model
		local eqxb
	}
	if "`randomness'"=="" 	local scale1 `scale'
	else 			local scale1 1		// sigma2 = 1 for explained randomness

	// Find model dimension
	local rn: rownames `vce'
	if "`cmd'"=="stpm2" {
		// Remove spline variables from list of vars in eqn [xb]
		unab rcs: _rcs*
		local rn: list rn - rcs
	}
	local cons _cons
	local rn: list rn - cons	// has no effect on cox model
	if "`adjust'" != "" & `modeldim' == 0 local modeldim: word count `rn'

	tempvar xb
	// if bsample done, predict on original sample
	if "`bsample'" != "" restore
	if "`cmd'"=="stpm2" predict `xb', xbnobaseline
	else predict `xb', xb

	// if `exclude' is requested, exclude the cited varlist from xb
	if "`exclude'"  !=  "" {
		if ("`eqxb'"  !=  "") local eq eq(xb)
		tempvar xxb
		xpredict `xxb', with(`exclude') `eq'
		replace `xb' = `xb' - `xxb'
		drop `xxb'
	}

	tempname tmp
	estimates store `tmp'
	count `if2'
	local n = r(N)
	count `if2' & _d==1
	local ev0 = r(N)

	// Variance of index
	sum `xb' `if2'
	local A = r(Var)

	// Compute D and its standard error
	tempvar zxb
	snscore `zxb' = `xb' `if2'

	// If xb has near-zero variance, quit. !! This test could be improved.
	sum `zxb'
	if r(sd) < 1.0e-06 {
		noi di as txt _n "[x*beta has near-zero variance]"
		return scalar r2 = 0
		return scalar r2aw = 0
		return scalar r2pm = 0
		return scalar D = 0
		return scalar sD = 0
		return scalar events = `ev0'
		return scalar N = `n'
		return scalar r2ll = 0
		return scalar r2ul = 0
		return scalar r2se = 0
		exit
	}
	`cmd' `zxb' `exclude', `options'
/*
	Due to parameterisation used by streg, need to divide D by
	scale factor for log-logistic and lnormal models
*/
	tempname scalefactor
	scalar `scalefactor' = 1
	if "`cmd'"=="streg" {
		if "`scale'"=="odds" scalar `scalefactor' = e(gamma)		// llogistic
		else if "`scale'"=="normal" scalar `scalefactor' = e(sigma)	// lnormal
	}
	// Get D, Dadj and CI for D and Dadj via noncentral chisquare for D^2
	tempname D sD Da sDa adjfac lbD ubD lbDa ubDa
	scalar `D' = `eqxb'_b[`zxb']/`scalefactor'
	scalar `sD' = `eqxb'_se[`zxb']/`scalefactor'
	scalar `adjfac' = 1/(1-`modeldim'/`ev0')
	dtodaci `D' `sD' `adjfac' $S_level  `Da' `sDa'  `lbD' `ubD'  `lbDa' `ubDa'
	if "`adjust'" != "" {
		scalar `D' = `Da'
		scalar `sD' = `sDa'
	}

	// Convert to R^2
	dtor2 `scale1' `D'
	local r2 = r(r2)
	scalar `sigma2' = r(sigma2)
	if `bootreps'>0 {
		local setit = " Boot S.E." 		// bootstrap se
		tempname pf
		tempfile tf
		postfile `pf' r2 using `"`tf'"', replace
		forvalues j = 1/`bootreps' {
			preserve
			bsample
			if "`validate'"=="" {
				str2d, `adjust' `randomness' : `cmd' `varlist' `if1', `options'
			}
			else {
				str2d, `randomness' : `cmd' `xb' `if2', `options'
			}
			post `pf' (r(r2))
			restore
			if "`dots'" != "nodots" {
				if mod(`j',100)==0 noi di as txt "." _cont
			}
		}
		if "`dots'" != "nodots" noi di
		postclose `pf'
		local pl = (100-$S_level)/2
		local pu = 100-`pl'
		preserve
		use `"`tf'"', replace
		centile r2, centile(`pl' `pu')
		local r2ll = r(c_1)
		local r2ul = r(c_2)
		sum r2
		local se = r(sd)
		restore
	}
	else {
		local setit = "Std. err."
		if "`adjust'" != "" {
			dtor2 `scale1' `lbDa'
			local r2ll = r(r2)
			dtor2 `scale1' `ubDa'
			local r2ul = r(r2)
		}
		else {
			dtor2 `scale1' `lbD'
			local r2ll = r(r2)
			dtor2 `scale1' `ubD'
			local r2ul = r(r2)
		}
		local sk = `sigma2'*8/_pi				// sigma-squared * kappa-squared
		local se = `sD'*abs(`D')*2*`sk'/(`D'^2+`sk')^2	// delta method
*noi di "pseudo-se = " (`r2ul'-`r2ll')/(-2*invnorm((100-$S_level)/200)) 
		*local se=(`r2ul'-`r2ll')/(-2*invnorm((100-$S_level)/200)) // pseudo-SE based on CI
	}
	estimates restore `tmp'
}
if "`randomness'"=="" local title "R^2 (explained variation - D method)"
else local title "R^2 (explained randomness - D method)"
if "`adjust'"=="" local r2tit "  R^2"
else local r2tit "Adj. R^2"
di _n as text "`title': `model'"
di as text _n _col(4) "Obs" _col(11) "Events" ///
 _col(20) "`r2tit'" _col(32) "`setit'" _col(43) "${S_level}% conf. interval" ///
 _col(65) "D" _col(71) "SE" _n "{hline 74}"
di as res %6.0f `n' %9.0f `ev0' %12.6f `r2' ///
 %12.6f `se' %11.6f `r2ll' %10.6f `r2ul' %7.3f `D' %7.3f `sD'
di as text "{hline 74}"
if "`validate'" != "" ///
 di as txt "[Model estimated at lower value (`val_lo') of " as inp "`validate'" ///
 as txt ", evaluated at higher value (`val_hi')]"
return scalar r2 = `r2'
return scalar r2aw = `A'/(1+`A')
return scalar r2pm = `A'/(`sigma2'+`A')
return scalar D = `D'
return scalar sD = `sD'
return scalar events = `ev0'
return scalar N = `n'
return scalar r2ll = `r2ll'
return scalar r2ul = `r2ul'
return scalar r2se = `se'
end

program define dtor2, rclass
version 8
// First arg is scale: hazard, normal or odds
// Second is D.
args scale D
tempname kappa sigma2
scalar `kappa' = sqrt(8/_pi)
if "`scale'"=="hazard"		scalar `sigma2' = _pi^2/6
else if "`scale'"=="normal"	scalar `sigma2' = 1
else if "`scale'"=="odds"	scalar `sigma2' = _pi^2/3
else scalar `sigma2' = 1
return scalar r2 = sign(`D')*(`D'/`kappa')^2/(`sigma2'+(`D'/`kappa')^2)
return scalar sigma2 = `sigma2'
end

* v 1.0.0 PR 08Jan2002.
program define dtodaci
version 6
args D sD r level  Da sDa  lbD ubD  lbDa ubDa
/*
	Inputs: D=D-statistic, sD=SE(D), r=factor in 1-r(1-R^2),
	level=confidence level (e.g. 95).

	Outputs: Da=adjusted D, sDa=(pseudo-)SE(Da), (lbD,ubD)=CI for D,
	(lbDa,ubDa)=CI for Da.
*/
if "`D'"=="" {
	di in green "dtodaci D sD r level  Da sDa  lbD ubD  lbDa ubDa"
	exit
}
if "`ubDa'"=="" {
	di in red "insufficient arguments provided"
	di in red "dtodaci D sD r level  Da sDa  lbD ubD  lbDa ubDa"
	exit 198
}
cap confirm var `D'
if _rc==0 {
	local temp tempvar
	local gen gen
	local replace replace
}
else {
	local temp tempname
	local gen scalar
	local replace scalar
}
quietly {
	tempname p pi8
	`temp' lbD2 ubD2
	scalar `pi8' = 8/_pi
	scalar `p' = (100-`level')/200
	`gen' `Da' = `pi8'*((1+`D'*`D'/`pi8')/`r'-1)
	`replace' `Da' = sign(`Da')*sqrt(abs(`Da'))
	// Get CI for D and Dadj via noncentral chisquare for D^2
	`gen' `lbD2' = `sD'^2*invnchi2(1,(`D'/`sD')^2,`p')
	`gen' `ubD2' = `sD'^2*invnchi2(1,(`D'/`sD')^2,1-`p')
	`gen' `lbD' = sqrt(`lbD2')
	`gen' `ubD' = sqrt(`ubD2')
	`gen' `lbDa' = `pi8'*((1+`lbD2'/`pi8')/`r'-1)
	`replace' `lbDa' = sign(`lbDa')*sqrt(abs(`lbDa'))
	`gen' `ubDa' = `pi8'*((1+`ubD2'/`pi8')/`r'-1)
	`replace' `ubDa' = sign(`ubDa')*sqrt(abs(`ubDa'))
	// Pseudo-SE for Dadj
	`gen' `sDa' = (`ubDa'-`lbDa')/(2*invnorm(1-`p'))
}
end

* version 1.0.1 PR 05Oct2002.
program define snscore	/* scaled Normal scores or unscaled half-Normal scores */
version 8
syntax newvarname [= /exp] [if] [in], [ BY(varlist) MEDian noTies Half ]
tempvar touse GRV
quietly {
	marksample touse, novarlist
	if "`exp'" != "" {
		gen double `GRV' = (`exp') if `touse'==1
	}
	else {	/* take ordering of scores from existing observations */
		gen long `GRV' = _n
	}
	markout `touse' `GRV' `by'
	replace `touse' = . if `touse'==0
	sort `touse' `by' `GRV'
	if "`half'"=="" {
		by `touse' `by': gen double `varlist' = /*
		 */ sqrt(_pi/8)*invnorm((_n-.375)/(_N+.25)) if `touse'==1
	}
	else {
/*
	McCullagh & Nelder 1989 p 407.
*/
		by `touse' `by': gen double `varlist' = /*
		 */ invnorm((_N+_n+.5)/(2*_N+1.125)) if `touse'==1
	}
	if "`ties'" != "noties" {
		if "`median'"=="" {
/*
	Replace Normal scores by their means in tie groups
*/
			by `touse' `by' `GRV': replace `varlist' = sum(`varlist') if `touse'==1
			by `touse' `by' `GRV': replace `varlist' = `varlist'[_N]/_N if `touse'==1
		}
		else {
/*
	Replace Normal scores by their medians in tie groups
	!! probably could be done more elegantly without use of -byvar-
*/
			byvar `touse' `by' `GRV', r(p50) generate: /*
			 */ summarize `varlist' if `touse'==1, detail
			local sumvar `r(R_1)'
			replace `varlist' = `sumvar'
			drop `sumvar'
		}
	}
}
end
exit
// Alternative formula:
		by `touse' `by': replace `varlist' = /*
		 */ invnorm(.5+.5*(`rank'-.375)/(_N+.25)) if `touse'==1
