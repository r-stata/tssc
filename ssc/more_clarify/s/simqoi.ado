*! simqoi v1.0 10may2014 JavierMarquez 
program define simqoi, rclass
   	version 11.2

//-----	Supported estimation commands
	if "`e(cmd)'"=="" error 301
	local suppcmd ///
		regress ///
		cnsreg ///
		eivreg ///
		tobit ///
		skewnreg ///
		skewtreg ///
		heckman ///
		poisson ///
		nbreg ///
		gnbreg ///
		zip ///
		zinb ///
		logistic ///
		logit ///
		blogit ///
		cloglog ///
		scobit ///
		probit ///
		bprobit ///
		hetprobit ///
		biprobit ///
		heckprob ///
		ologit ///
		oprobit ///
		mlogit //
	if !`:list posof "`e(cmd)'" in suppcmd' {
		di as err "simqoi is not allowed after `e(cmd)'"
		error 301
	}

//-----	Syntax
	syntax [if] [in] ///
		using/ ///
		[fw aw pw] ///
		[, ///
		ev pv diff ratio ///
		at(string) ///
		DEPvar(string) /// two-dependent variables
		noEsample ///
		noWeights ///
		noOffset ///
		seed(string) ///
		GENerate(name) ///
		Double ///
		Level(cilevel) ///
		noLabel ///
		noHeader ///
		noAttable ///
		]

//-----	Use [if] [in] as well as limiting to e(sample)
	marksample touse
	if "`esample'"=="" { // if no <noesample>
		tempvar cmdsample
		qui gen byte `cmdsample' = e(sample) 
		markout `touse' `cmdsample'
	}

//-----	Quantities of interest <qi>
	opts_exclusive "`ev' `pv' `diff' `ratio'"
	// default
	if mi("`ev'`pv'`diff'`ratio'") local ev ev
	// diff, ratio -> ev
	if "`diff'"=="diff" local ev ev
	if "`ratio'"=="ratio" local ev ev
	// qi
	local qi `ev' `pv'

//-----	Weights for computing summary statistics: <wtype> <wexp>
	// default
	local wtype `"`e(wtype)'"'
	local wexp  `"`e(wexp)'"'
	// ignore weights specified in estimation
	if "`weights'"=="noweights" {
		local wtype
		local wexp
	}
	// user weights
	if `"`weight'`exp'"' != "" {	
		local wtype `"`weight'"'
		local wexp  `"`exp'"'
	}

//----- Matrix <matrix at> <m_at> <atstats>
	GetAt `at' if `touse' [`wtype'`wexp']
	local drop at // local <at> no longer exists...
	tempname at // ...now is a matrix
	mat `at' = r(at)
	local m_at = r(m_at) //number of scenarios
	local atstats `"`r(atstats)'"'

//----- Check <m_at>==2 if <fd> or <rr>
	if !mi("`diff'`ratio'") & `m_at'!=2 {
		di as err "option {cmd:`diff'`ratio'} incorrectly specified; "
		di as err "only two scenarios are allowed"
		error 198
	}

//----- Which depvar? <depvar> <valslabs> <eq>
	EqNum `depvar'
	if `s(k_eq)' > 1 {
		local eq eq(`s(eqno)')
	}
	local depvar `s(depvar)'
	local valslabs: value label `depvar'

//----- Offset at mean
	if "`offset'"=="" & ("`e(offset)'" !="" | /*
                      */ "`e(offset1)'"!="" | /*
                      */ "`e(offset2)'"!="") {
		MeanOffset if `touse' [`wtype'`wexp']
		// collect offsets
		foreach x in "" "1" "2" {
			if "`r(avoff`x')'"!="" {
				local avoff`x' offset`x'(`=r(avoff`x')')
			}
		}
		// matrix for display
		tempname atoffset
		forvalues m = 1/`m_at' {
			mat `atoffset' = nullmat(`atoffset') \ r(atoffset)
		}
		local offstats `r(offstats)'
	}

//-----	Save simulated QOI? <generate>
	// Temporary file? <nosave>
	if "`generate'" == "" {
        local nosave "nosave"
		tempvar generate // get a stub
	}

//----- set seed
	if "`seed'"!="" {
		set seed `seed'
	}
	local seed `c(seed)'

//----- Load "using" data
	// Load data
	preserve
	qui use `"`using'"', clear

	// Default expression names <enames>
	if word("`: data label'",1) == "postsim:" local stub sim // postsim
	if word("`: data label'",1) == "bootstrap:" local stub bs // bootstrap
	if word("`: data label'",1) == "jackknife:" local stub jk // jackknife
	if word("`: data label'",1) == "permute" local stub pm // permute
	tempname b
	_prefix_expand `b', stub(_`stub'_) eexp(_b)
	local enames `"`s(enames)'"'
	qui desc, varlist
	if `"`enames'"' != `"`r(varlist)'"' {
		di as err "varlist in using data do not match default {it:exp_list} (_b) in estimation command"
		error 198
	}

	// define new <touse> (for dealing with possible failed replications)
	mark `touse'
	markout `touse' `enames'

//----- Compute QoI
	tempname X
	forvalues m = 1/`m_at' {
		if `m_at' > 1 local ATsuffix _at_`m'
		// Build X matrix
		GetX `at'[`m',1...]
		mat `X' = r(X)
		mat coln `X' = `enames'
		// Compute QI
		QI_`e(cmd)' `generate'`ATsuffix' if `touse', ///
			mat(`X') ///
			qi(`qi') ///
			`avoff' `avoff1' `avoff2' `eq' `double' //
		local varlist `varlist' `r(varlist)'
		local colnames `colnames' `r(levels)'
		_repeat `ATsuffix', times(`: word count `r(levels)'') local(foo)
		local coleq `coleq' `foo'
	}
	local title `r(title)'
	local exp `r(exp)'
	local coef `r(coef)'
	local levels `r(levels)'

//-----	Compute fd/rrs
	if !mi("`diff'`ratio'") {
		CompDiff `varlist' if `touse', ///
			qi(`diff'`ratio') ///
			stub(`generate') ///
			levels(`levels') ///
			exp(`exp')
		local varlist `r(varlist)'
		local colnames `r(levels)'
		local coleq `r(coleq)'
		local title `r(title)'
		local exp `r(exp)'
		local coef `r(coef)'
	}

//-----	Summarize QoI
	GetResults `varlist' if `touse', ///
		coef(`coef') ///
		level(`level') ///
		levels(`levels') //
	tempname Results
    local N = r(N)
	mat `Results' = r(Results)

	mat colnames `Results' = `colnames'
	mat coleq `Results' = `coleq'

//-----	Save variables
	if `"`nosave'"'=="" {
		// Label variables
		foreach var in `varlist' {
			label variable `var' `"`exp'"'
		}
		// Label values
		if "`coef'"=="Proportion" {
			label values `varlist' `valslabs'
		}
		// Merge
		keep `varlist'
		tempfile results
		qui save `results'
		restore
		confirm new var `varlist'
		qui merge 1:1 _n using `results', nogen
	}
	else restore

//-----	Display
	// Include offset in <at> matrix
	if "`e(offset)'" !="" | /*
	*/ "`e(offset1)'"!="" | /*
	*/ "`e(offset2)'"!="" {
		mat `at' = `at' , `atoffset'
		local atstats `atstats' `offstats'
	}

	Display `Results', ///
		at(`at') ///
		title(`title') ///
		n(`N') ///
		exp(`exp') ///
		depvar(`depvar') ///
		coef(`coef') ///
		atstats(`atstats') ///
		l(`level') ///
		`label' `header' `attable' //

//-----	Return
	return scalar N_reps = `N'

	return local  seed `"`seed'"'
	return local  wexp `"`wexp'"'
	return local  wtype `"`wtype'"'
	return local  atstats `"`atstats'"'
	return local  level	`"`level'"'
	return local  depvar `"`depvar'"'
	return local  qi `"`qi'"'
	return local  cmd "simqoi"

	tempname b se lb ub
	mat `b' = `Results'[1,1...]
	mat `se' = `Results'[2,1...]
	mat `lb' = `Results'[3,1...]
	mat `ub' = `Results'[4,1...]

	return matrix at = `at'
	return matrix Results = `Results'
	return matrix ub = `ub'
	return matrix lb = `lb'
	return matrix se = `se'
	return matrix b = `b'

end

*******************************************************************
*	Subroutines
*******************************************************************

*----------------------------
* At values
*----------------------------
program define GetAt, rclass
	syntax 	[anything(equalok)] ///
			[if] [in] ///
			[fweight aweight pweight] //
	marksample touse

 	_ms_at_parse `anything'
	tempname at
	mat `at'      = r(at)
	local m_at    = rowsof(`at')
	local atstats `"`r(statlist)'"'
	
	forvalues m = 1/`m_at' {
		local atrownames `atrownames' at_`m' 
		local i = 0
		foreach name in `: colnames `at'' {
			if substr(`"`: word `++i' of `atstats''"',1,5) == "value" {
				continue
			}
			else {
				_ms_parse_parts `name'
				if r(type) == "factor" {
					local name `r(level)'.`r(name)'
				}
				GetValues `name' if `touse' [`weight'`exp'], stat(`: word `i' of `atstats'')
				matrix `at'[`m',colnumb(`at',"`name'")] = r(value)
			}
		}
	}
	if `m_at' == 1 local atrownames at
	matrix rownames `at' = `atrownames'
	
	// return
	return matrix at     = `at'  
	return scalar m_at   = `m_at'
	return local atstats `atstats' 
end

program define GetValues, rclass
	syntax varname(numeric fv) ///
		[if] [in] ///
		[fweight aweight pweight], ///
		stat(string) //

	marksample touse

	if `"`stat'"'=="mean" {
      	if `"`weight'"' == "pweight" local weight aweight
      	qui sum `varlist' if `touse' [`weight'`exp'], meanonly
      	return scalar value = r(mean)
   	}
   	else if `"`stat'"' == "median" {
      	_pctile `varlist' if `touse' [`weight'`exp'], p(50)
      	return scalar value = r(r1)
   	}
   	else if inlist(`"`stat'"',"max","min") {
      	qui sum `varlist' if `touse'
      	return scalar value = r(`stat')
   	}
   	else if substr(`"`stat'"',1,1) == "p" {
      	_pctile `varlist' if `touse' [`weight'`exp'], p(`:subinstr local stat "p" ""')
      	return scalar value = r(r1)
   	}
   	else if `"`stat'"'=="zero" {
      	return scalar value = 0
   	}
   	else {
		di as err "`stat' is not supported by {cmd:simqoi}"
		exit 198   	
	}
end

program define MeanOffset, rclass
	syntax [if] [in] [fweight aweight pweight]
	marksample touse

	tempname atoffset
	foreach x in "" "1" "2" {
		if ("`e(offset`x')'" != "" ) {
			local offstats `offstats' offset`x' //offset id
			local offvar="`e(offset`x')'"
			cap confirm var `offvar'
			local colnames `colnames' `offvar'
			// exposure
			if _rc!=0 {
				local offvar = subinstr("`offvar'","ln(","",.)
				local offvar = subinstr("`offvar'",")","",.)
				qui sum `offvar' if `touse' [`wtype'`wexp'], meanonly
				ret scalar avoff`x' = ln(r(mean))
			}
			// offset
			else {
				qui sum `offvar' if `touse' [`wtype'`wexp'], meanonly
				ret scalar avoff`x' = r(mean)
			}
			// matrix
			mat `atoffset' = nullmat(`atoffset') , return(avoff`x')
		}
	}
	matrix colnames `atoffset' = `colnames'
	return matrix atoffset = `atoffset'
	return local offstats `offstats'
end

*----------------------------
* Equation number (depvar)
*----------------------------
program define EqNum, sclass
	
	local eqlist `"`e(depvar)'"'
	local k_eq: word count `eqlist'

	// Default (eq1)
	if "`0'"=="" local 0 #1
	
	// Get eq number
	if substr(`"`0'"', 1, 1)=="#" {
		local eqno = substr(`"`0'"',2,.)
		confirm integer number `eqno'
	}
	else {
		local eqno : list posof `"`0'"' in eqlist
	}

	// Check eq number
	if 1 > `eqno' | `eqno' > `k_eq' {
		di as err "invalid depvar()"
		error 198
	}
	
	// Get depvar
	local depvar : word `eqno' of `eqlist'
	
	// Return
	sreturn local k_eq `k_eq'
	sreturn local eqno `eqno'
	sreturn local depvar `depvar'
end

*----------------------------
* Get X
*----------------------------
program define GetX, rclass
	syntax anything(name=AT)
	
	tempname at b X
	mat `at'      = `AT'
	mat `b'       = e(b)
	mat `X'       = J(1,colsof(`b'),.)
	mat colna `X' = `: colfullnames `b''

	forval i = 1/`=colsof(`X')' {
		local name : word `i' of `: colnames `X''
		_ms_parse_parts `name'
		if r(omit) {
			mat `X'[1,`i'] = 0
		}
		else if inlist(r(type),"variable","error","factor") {
			if "`r(name)'" == "_cons" {
				mat `X'[1,`i'] = 1
			}
			else {
				mat `X'[1,`i'] = `at'[1,colnumb(`at',`"`name'"')]
			}
		}
		else if inlist(r(type),"interaction","product") {
			mat `X'[1,`i'] = 1
			forvalues k = 1/`r(k_names)' {
				mat `X'[1,`i'] = `X'[1,`i'] * `at'[1,colnumb(`at',`"`r(op`k')'.`r(name`k')'"')]
			}
		}	
	}
	// return
	return matrix X = `X'
end

*----------------------------
* Vector to local: mat2loc
*----------------------------
program define mat2loc
	syntax anything(name=m), local(name) [rows cols]
	tempname M
	matrix `M' = `m'
	forvalues i = 1/`=`cols'`rows'of(`M')' {
		if "`rows'"=="rows" local tmp = `M'[`i',1]
		if "`cols'"=="cols" local tmp = `M'[1,`i']
		local vals `vals' `tmp'
	}
	c_local `local' `"`vals'"'
end

*----------------------------
* Repeat strings
*----------------------------
program define _repeat
	syntax [namelist], [times(integer 1) local(name)]
	forvalues i = 1/`times' {
		local out `out' `namelist'
	}
	c_local `local' `"`out'"'
end

*----------------------------
* Sample from multinomial
*----------------------------
program define rmultinom
	syntax varlist [if] [in], newvar(name) cat(numlist)
	marksample touse
	
	tempvar psum u
	gen `newvar' = . if `touse'
	gen `psum' = 0 if `touse'
	gen `u' = runiform() if `touse'

	local k_cat: word count `cat'
	local k = 1
	while `k' < `k_cat' {
		qui replace `psum' = `psum' + `: word `k' of `varlist'' if `touse'
		qui replace `newvar' = `: word `k' of `cat'' if `u' <= `psum' & `newvar'==. & `touse'
		local k = `k' + 1
	}
	qui replace `newvar' = `: word `k_cat' of `cat'' if `newvar'==. & `touse'
end

*----------------------------
* Compute fd/rr
*----------------------------
program CompDiff, rclass
	syntax varlist [if] [in], ///
		qi(name) ///
		stub(name) ///
		levels(string) ///
		exp(string)

	marksample touse
	// parse QI
	if "`qi'" == "diff" local operator "-"
	if "`qi'" == "ratio" local operator "/"

	// Generate QI
	local K : word count `levels'
	forvalues k = 1/`K' {
		qui gen `stub'_`k' = `:word `=`k'+`K'' of `varlist'' `operator' `:word `k' of `varlist'' if `touse'
		local newvarlist `newvarlist' `stub'_`k'
	}

	// Return
	return local levels `levels'
	return local varlist `newvarlist'
	return local colnames `levels'
	return local coleq ""
	if "`qi'"=="diff" return local title "First differences"
	if "`qi'"=="ratio" return local title "Risk ratios"
	local exp : subinstr local exp ")" ""
	return local exp "`exp'|at_2) `operator' `exp'|at_1)"
	return local coef "Mean"	
end	

*----------------------------
* Get Results
*----------------------------
program GetResults, rclass
	syntax varlist [if] [in], ///
		coef(name) ///
		level(cilevel) ///
		levels(string)

	marksample touse
	tempname b se ci

	if "`coef'"=="Mean" | "`coef'"=="Probability" {
		// b
		qui tabstat `varlist' if `touse', s(mean) save
		mat `b' = r(StatTotal)
		// se
		qui tabstat `varlist' if `touse', s(sd) save
		mat `se'= r(StatTotal)
		// ci
		mat `ci' = J(2,colsof(`b'),.)
		local plo = (100-`level')/2
		local phi = `plo' + `level'
		local i 0
		foreach var of local varlist {
			qui _pctile `var' if `touse', p(`plo',`phi')
			mat `ci'[1,`++i'] = r(r1)
			mat `ci'[2,`i']   = r(r2)
		}
	}
	
	if "`coef'"=="Proportion" {
		// b
		_tabm `varlist' if `touse', levels(`levels')
		mat `b' = r(StatTotal)		
		// se		
		mat `se' = J(1,colsof(`b'),.)
		// ci
		mat `ci' = J(2,colsof(`b'),.)
	}

	// Observations
	tempname N
	qui count if `touse'
	scalar `N' = r(N)
	
	// Return
	tempname Results
	mat `Results' = `b' \ `se' \ `ci'
	mat rownames `Results' = b se lower upper
	mat coleq `Results' = ""
	mat roweq `Results' = ""
	return mat Results = `Results'
	return scalar N = `N'
end

program _tabm, rclass
	version 11.2
	syntax varlist(numeric) [if] [in], levels(numlist)
	marksample touse

	tempname M cell row
	mat `M' = J(`: word count `levels'',`: word count `varlist'' ,0)
	mat rownames `M' = `levels'
	mat colnames `M' = `varlist'
	foreach var of varlist `varlist' {
		qui tab `var' if `touse', matcell(`cell') matrow(`row')
		forvalues i = 1/`=r(r)' {
			mat `M'[rownumb(`M',"`=`row'[`i',1]'"),colnumb(`M',"`var'")] = `cell'[`i',1]/`=r(N)'
		}
	}
	mat `M' = vec(`M')'
	return matrix StatTotal = `M'
end

*----------------------------
* Display
*----------------------------
program Display
	syntax name(name=Results), ///
		at(name) ///
		title(string) ///
		n(integer) ///
		exp(string) ///
		depvar(string) ///
		coef(name) ///
		l(cilevel) ///
		atstats(namelist) ///
		[noLABel ///
		noHEADer ///
		noATtable]

	local namelist: colnames `Results'
	local eqlist: coleq `Results'
	local k: word count `namelist'

	// header
	if "`header'"=="" {
		//title
		di as text _n `"`title'"' _c
		//number of reps
		di as text  "{col 37}Number of reps{col 54}= " as res %7.0f `n'
		//expression
		di
		di as text "Expression{col 14}: " as res `"`exp'"'
	}
	di

	// format table
	tempname mytab
    .`mytab' = ._tab.new, col(5) lmargin(0)
    .`mytab'.width    13   |12    12    12    12
    .`mytab'.titlefmt  .     .     .  %24s     .
    .`mytab'.pad       .     2     1     3     3
    .`mytab'.numfmt    . %9.0g %9.0g %9.0g %9.0g
    .`mytab'.sep, top
    .`mytab'.titles	"" "" "" "Percentile-based  " ""  
    .`mytab'.titles	"`= abbrev("`depvar'",12)'" /// 1
					"`coef'"                    /// 2
					"Std. Err."                 /// 3
					"[`l'% Conf. Interval]" ""  //  4 5
    // fill table
	forvalues i = 1/`k' {
		local name: word `i' of `namelist'
		if "`name'" != "_cons" {
			if "`label'"=="" {
				local name=abbrev("`:label (`depvar') `name''",12)
			}
		}
		local eq  : word `i' of `eqlist'
		if "`eq'" != "_" {
			if "`eq'" != "`eq0'" {
                .`mytab'.sep
                local eq0 `"`eq'"'
                .`mytab'.strcolor result  .  .  .  .
                .`mytab'.strfmt    %-12s  .  .  .  .
                .`mytab'.row      "`eq'" "" "" "" ""
                .`mytab'.strcolor   text  .  .  .  .
                .`mytab'.strfmt     %12s  .  .  .  .
            }
        }
        else if `i' == 1 {
			local eq
			.`mytab'.sep
        }
        .`mytab'.row "`name'" ///
			`Results'[1,`i'] ///
			`Results'[2,`i'] ///
			`Results'[3,`i'] ///
			`Results'[4,`i']
	}

	// end
	.`mytab'.sep, bottom
	
	// at table
	if ("`attable'"=="") {
		// stats
		foreach name in `atstats' {
			local stats `stats' (`name')
		}
		// matrix
		tempname at_table
		mat `at_table' = `at'
		mat coleq `at_table' = `: colnames `at''
		mat colnames `at_table' = `stats'
		matlist `at_table', ///
			title(Evaluated at:) ///
			lines(oneline) ///
			showcoleq(rcombined)
	}
end

*******************************************************************
*	Statistical models
*******************************************************************

*----------------------------
* QI_regress
*----------------------------
program define QI_regress, rclass
	syntax name(name=stub) [if] [in], mat(name) qi(name) [offset(real 0) double]
	marksample touse
	tempname X
	mat `X' = `mat'

	// xb=E(Y)
	tempvar ev
	qui matrix score `ev' = `X' if `touse', eq(#1)
	qui replace `ev' = `ev' + `offset' if `touse'

	// Pred(Y)
	if "`qi'"=="pv" {
		tempvar sigma pv
		// simulate sigma from scaled inverse chi-squared (Gelman & Hill, 2007, p. 143)
		if e(rmse)==.  {
			di as error "root mean squared error not found"
			error 498
		}
		if e(df_r)==.  {
			di as error "residual degrees of freedom not found"
			error 498
		}
		qui gen `sigma' = e(rmse)*sqrt( e(df_r)/rchi2(e(df_r)) ) if `touse'
		// simulate pv
		qui gen `pv' = rnormal(`ev',`sigma') if `touse'
	}

	// generate variables and info
	return local levels _cons
	if "`qi'"=="ev" {
		qui gen `double' `stub' = `ev'
		return local varlist `stub'
		return local title "Expected values"
		return local exp "E(`e(depvar)')"
		return local coef "Mean"
	}
	if "`qi'"=="pv" {
		qui gen `double' `stub' = `pv'
		return local varlist `stub'
		return local title "Predicted values"
		return local exp "Pred(`e(depvar)')"
		return local coef "Mean"
	}
end

*----------------------------
* QI_cnsreg
*----------------------------
program define QI_cnsreg
  QI_regress `0'
end

*----------------------------
* QI_eivreg
*----------------------------
program define QI_eivreg
	QI_regress `0'
end

*----------------------------
* QI_tobit
*----------------------------
program define QI_tobit, rclass
  syntax name(name=stub) [if] [in], mat(name) qi(name) [offset(real 0) double]
	marksample touse
	tempname X
	mat `X' = `mat'

	// xb=E(Y)
	tempvar ev
	qui matrix score `ev' = `X' if `touse', eq(#1)
	qui replace `ev' = `ev' + `offset' if `touse'

	// Pred(Y)
	if "`qi'"=="pv" {
		tempvar sigma pv
		// simulate sigma from scaled inverse chi-squared
		qui gen `sigma' = [sigma]_cons*sqrt( e(df_r)/rchi2(e(df_r)) ) if `touse'
		// simulate pv
		qui gen `pv' = rnormal(`ev',`sigma') if `touse'
		//censored
		if !mi(e(llopt)) qui replace `pv'=e(llopt) if `pv'<=e(llopt) & `touse'
		if !mi(e(ulopt)) qui replace `pv'=e(ulopt) if `pv'>=e(ulopt) & `touse'
	}

	// generate variables and info
	return local levels _cons
	if "`qi'"=="ev" {
		qui gen `double' `stub' = `ev'
		return local varlist `stub'
		return local title "Expected values"
		return local exp "E(`e(depvar)')"
		return local coef "Mean"
	}
	if "`qi'"=="pv" {
		qui gen `double' `stub' = `pv'
		return local varlist `stub'
		return local title "Predicted values"
		return local exp "Pred(`e(depvar)')"
		return local coef "Mean"
	}
end

*----------------------------
* QI_skewnreg
*----------------------------
program define QI_skewnreg, rclass

	// Check if DIRECT parameterization
	if e(skew_dp) != 1 {
		di as err "{cmd:simqoi} supports only direct parameterization"
		di as err "rerun the estimation command using the {opt postdp} option"
		exit 198
	}
	
	syntax name(name=stub) [if] [in], mat(name) qi(name) [double]
	marksample touse
	tempname X
	mat `X' = `mat'

	// xb
	tempvar xb alpha omega
	qui matrix score `xb'    = `X' if `touse', equation(#1)
	qui matrix score `alpha' = `X' if `touse', equation(#2)
	qui matrix score `omega' = `X' if `touse', equation(#3)

	// E(Y) (Azzalini, 2014 p.30)
	if "`qi'"=="ev" {
		tempvar delta ev
		qui gen `delta' = `alpha'/sqrt(1+`alpha'^2) if `touse'
		qui gen `ev' = `xb' + `omega'*sqrt(2/c(pi))*`delta' if `touse'
	}

	// Pred(Y) (http://azzalini.stat.unipd.it/SN/faq-r.html); rsn function in R
	if "`qi'"=="pv" {
		tempvar u1 u2 z pv
		qui gen `u1' = rnormal() if `touse'
		qui gen `u2' = rnormal() if `touse'
		qui replace `u1' = -`u1' if (`u2' > `alpha'*`u1') & `touse'
		qui gen `z' = `u1'*`omega' if `touse'
		qui gen `pv' = `xb' + `z' if `touse'
	}

	// generate variables and info
	return local levels _cons
	if "`qi'"=="ev" {
		qui gen `double' `stub' = `ev'
		return local varlist `stub'
		return local title "Expected values"
		return local exp "E(`e(depvar)')"
		return local coef "Mean"
	}
	if "`qi'"=="pv" {
		qui gen `double' `stub' = `pv'
		return local varlist `stub'
		return local title "Predicted values"
		return local exp "Pred(`e(depvar)')"
		return local coef "Mean"
	}
end

*----------------------------
* QI_skewtreg
*----------------------------
program define QI_skewtreg, rclass

	syntax name(name=stub) [if] [in], mat(name) qi(name) [double]
	marksample touse
	tempname X
	mat `X' = `mat'

	// xb
	tempvar xb alpha omega nu
	qui matrix score `xb'    = `X' if `touse', equation(#1)
	qui matrix score `alpha' = `X' if `touse', equation(#2)
	qui matrix score `omega' = `X' if `touse', equation(#3)
	qui matrix score `nu'    = `X' if `touse', equation(#4)
	// Transform into direct parameterization if needed
	if e(skew_dp) == 0 {
		qui replace `omega' = exp(`omega') if `touse'
		qui replace `nu' = exp(`nu') if `touse'	
	}
		
	// E(Y) (Azzalini, 2014 p.103)
	if "`qi'"=="ev" {
		tempvar b delta ev
		qui gen `b' = ( sqrt(`nu') * exp(lngamma((`nu'-1)/2)) ) / ///
		              ( sqrt(c(pi))* exp(lngamma( `nu'   /2)) ) if `touse'
		qui gen `delta' = `alpha'/sqrt(1+`alpha'^2) if `touse'
		qui gen `ev' = `xb' + `omega'*`b'*`delta' if `touse'
	}

	// Pred(Y) (http://azzalini.stat.unipd.it/SN/faq-r.html) function rst in R
	if "`qi'"=="pv" {
		tempvar u1 u2 z v pv
		qui gen `u1' = rnormal() if `touse'
		qui gen `u2' = rnormal() if `touse'
		qui replace `u1' = -`u1' if (`u2' > `alpha'*`u1') & `touse'
		qui gen `z' = `u1'*`omega' if `touse'
		qui gen `v' = rchi2(`nu')/`nu' if `touse'
		qui gen `pv' = `xb' + `z'/sqrt(`v')  if `touse'
	}

	// generate variables and info
	return local levels _cons
	if "`qi'"=="ev" {
		qui gen `double' `stub' = `ev'
		return local varlist `stub'
		return local title "Expected values"
		return local exp "E(`e(depvar)')"
		return local coef "Mean"
	}
	if "`qi'"=="pv" {
		qui gen `double' `stub' = `pv'
		return local varlist `stub'
		return local title "Predicted values"
		return local exp "Pred(`e(depvar)')"
		return local coef "Mean"
	}
end

*----------------------------
* QI_heckman
*----------------------------
program define QI_heckman, rclass
	syntax name(name=stub) [if] [in], mat(name) qi(name) [eq(integer 1) offset1(real 0) offset2(real 0) double]
	marksample touse
	tempname X
	mat `X' = `mat'

	// xb, xbsel
	tempvar xb xbsel
	qui matrix score `xb' = `X' if `touse', equation(#1)
	qui replace `xb' = `xb' + `offset1' if `touse'
	qui matrix score `xbsel' = `X' if `touse', equation(#2)
	qui replace `xbsel' = `xbsel' + `offset2' if `touse'

	// E(Y)
	//----------------
	*Outcome Equation
	if `eq'==1 {
		tempvar rho sigma mills ev
		//rho
		qui matrix score `rho' = `X' if `touse', equation(athrho)
		qui replace `rho' = (exp(2*`rho')-1) / (exp(2*`rho')+1) if `touse'
		//sigma		
		qui matrix score `sigma' = `X' if `touse', equation(lnsigma)
		qui replace `sigma' = exp(`sigma') if `touse'
		//mills
		qui gen `mills' = normalden(`xbsel') / normal(`xbsel') if `touse'
		//E(Y)
		qui gen `ev' = normal(`xbsel') * (`xb' + `mills' * `sigma' * `rho') if `touse'
	}
	*Selection Equation
	if `eq'==2 {
		tempvar ev0 ev1
		qui gen `ev1' = normal(`xbsel') if `touse'
		qui gen `ev0' = 1-`ev1' if `touse'
	}

	// Pred(Y)
	//----------------
	if "`qi'"=="pv" {
		tempvar pv
		*Outcome Equation
		if `eq'==1 {
			qui gen `pv' = rnormal(`ev',`sigma') if `touse'
		}
		*Selection Equation
		if `eq'==2 {
			qui gen `pv' = rbinomial(1,`ev1') if `touse'
		}
	}

	// generate variables and info
	if `eq' == 1 return local levels _cons
	if `eq' == 2 return local levels 0 1
	if "`qi'"=="ev" {
		if `eq' == 1 {
			qui gen `double' `stub' = `ev'
			return local varlist `stub'
			return local title "Expected values"
			return local exp "E(`: word `eq' of `e(depvar)''|Prob(observed))"
			return local coef "Mean"
		}
		if `eq' == 2 {
			qui gen `double' `stub'_0 = `ev0'
			qui gen `double' `stub'_1 = `ev1'
			return local varlist `stub'_0 `stub'_1
			return local title "Expected values"
			return local exp "Pr(`: word `eq' of `e(depvar)'')"
			return local coef "Probability"
		}
	}
	if "`qi'"=="pv" {
		if `eq' == 1 {
			qui gen `double' `stub' = `pv'
			return local varlist `stub'
			return local title "Predicted values"
			return local exp "Pred(`: word `eq' of `e(depvar)'')"
			return local coef "Mean"
		}
		if `eq' == 2 {
			qui gen `double' `stub' = `pv'
			return local varlist `stub'
			return local title "Predicted values"
			return local exp "Pred(`: word `eq' of `e(depvar)'')"
			return local coef "Proportion"
		}
	}
end

*----------------------------
* QI_poisson
*----------------------------
program define QI_poisson, rclass
	syntax name(name=stub) [if] [in], mat(name) qi(name) [offset(real 0) double]
	marksample touse
	tempname X
	mat `X' = `mat'

	// xb
	tempvar xb
	qui matrix score `xb' = `X' if `touse'
	qui replace `xb' = `xb' + `offset' if `touse'

	// E(Y)
	tempvar ev
	qui gen `ev' = exp(`xb') if `touse'
	
	// Pred(Y)
	if "`qi'"=="pv" {
		tempvar pv
		qui gen `pv'= rpoisson(`ev') if `touse'
	}

	// generate variables and info
	return local levels _cons
	if "`qi'"=="ev" {
		qui gen `double' `stub' = `ev'
		return local varlist `stub'
		return local title "Expected values"
		return local exp "E(`e(depvar)')"
		return local coef "Mean"
	}
	if "`qi'"=="pv" {
		qui gen `double' `stub' = `pv'
		return local varlist `stub'
		return local title "Predicted values"
		return local exp "Pred(`e(depvar)')"
		return local coef "Mean"
	}
end

*----------------------------
* QI_nbreg
*----------------------------
program define QI_nbreg, rclass
	syntax name(name=stub) [if] [in], mat(name) qi(name) [offset(real 0) double]
	marksample touse
	tempname X
	mat `X' = `mat'

	// xb
	tempvar xb
	qui matrix score `xb' = `X' if `touse', equation(#1)
	qui replace `xb' = `xb' + `offset' if `touse'

	// E(Y)
	tempvar ev
	qui gen `ev' = exp(`xb') if `touse'
	
	// Pred(Y)
	if "`qi'"=="pv" {
		if "`e(dispers)'"=="mean" | "`e(cmd)'"=="gnbreg" { //NB2 --[R]v13.0 p.1395
			tempvar alpha gamma
			qui matrix score `alpha' = `X' if `touse', equation(lnalpha)
			qui replace `alpha' = exp(`alpha') if `touse'
			qui gen `gamma' = rgamma(1/`alpha',`alpha'*`ev') if `touse'
		}
		if "`e(dispers)'"=="constant" { //NB1 --[R]v13.0 p.1395
			tempvar delta gamma
			qui matrix score `delta' = `X' if `touse', equation(lndelta)
			qui replace `delta' = exp(`delta') if `touse'
			qui gen `gamma' = rgamma(`ev'/`delta',`delta') if `touse'
		}
		tempvar pv
		qui gen `pv' = rpoisson(`gamma') if `touse'
	}

	// generate variables and info
	return local levels _cons
	if "`qi'"=="ev" {
		qui gen `double' `stub' = `ev'
		return local varlist `stub'
		return local title "Expected values"
		return local exp "E(`e(depvar)')"
		return local coef "Mean"
	}
	if "`qi'"=="pv" {
		qui gen `double' `stub' = `pv'
		return local varlist `stub'
		return local title "Predicted values"
		return local exp "Pred(`e(depvar)')"
		return local coef "Mean"
	}
end

*----------------------------
* QI_gnbreg
*----------------------------
program define QI_gnbreg
  QI_nbreg `0'
end

*----------------------------
* QI_zip
*----------------------------
program define QI_zip, rclass
	syntax name(name=stub) [if] [in], mat(name) qi(name) [offset1(real 0) offset2(real 0) double]
	marksample touse
	tempname X
	mat `X' = `mat'

	// xb, pr
	tempvar xb pr
	qui matrix score `xb' = `X' if `touse', eq(#1)
	qui replace `xb' = `xb' + `offset1' if `touse'

	qui matrix score `pr' = `X' if `touse', eq(#2)
	qui replace `pr' = `pr' + `offset2' if `touse'
	if "`e(inflate)'" == "logit" {
		qui replace `pr' = exp(`pr')/(1+exp(`pr')) if `touse'
	}
	if "`e(inflate)'" == "probit" {
		qui replace `pr' = normal(`pr') if `touse'
	}

	// E(Y)
	tempvar ev
	qui gen `ev' = exp(`xb')*(1-`pr') if `touse'
	
	// Pred(Y)
	if "`qi'"=="pv" {
		tempvar pv
		qui gen `pv'= rpoisson(`ev') if `touse'
	}

	// generate variables and info
	return local levels _cons
	if "`qi'"=="ev" {
		qui gen `double' `stub' = `ev'
		return local varlist `stub'
		return local title "Expected values"
		return local exp "E(`e(depvar)')"
		return local coef "Mean"
	}
	if "`qi'"=="pv" {
		qui gen `double' `stub' = `pv'
		return local varlist `stub'
		return local title "Predicted values"
		return local exp "Pred(`e(depvar)')"
		return local coef "Mean"
	}
end

*----------------------------
* QI_zinb
*----------------------------
program define QI_zinb, rclass
	syntax name(name=stub) [if] [in], mat(name) qi(name) [offset1(real 0) offset2(real 0) double]
	marksample touse
	tempname X
	mat `X' = `mat'

	// xb, pr
	tempvar xb pr
	qui matrix score `xb' = `X' if `touse', eq(#1)
	qui replace `xb' = `xb' + `offset1' if `touse'

	qui matrix score `pr' = `X' if `touse', eq(#2)
	qui replace `pr' = `pr' + `offset2' if `touse'
	if "`e(inflate)'" == "logit" {
		qui replace `pr' = exp(`pr')/(1+exp(`pr')) if `touse'
	}
	if "`e(inflate)'" == "probit" {
		qui replace `pr' = normal(`pr') if `touse'
	}

	// E(Y)
	tempvar ev
	qui gen `ev' = exp(`xb')*(1-`pr') if `touse'
	
	// Pred(Y)
	if "`qi'"=="pv" {
		tempvar pv alpha gamma
		qui matrix score `alpha' = `X' if `touse', equation(lnalpha)
		qui replace `alpha' = exp(`alpha') if `touse'
		qui gen `gamma' = rgamma(1/`alpha',`alpha'*`ev') if `touse'
		qui gen `pv' = rpoisson(`gamma') if `touse'
	}

	// generate variables and info
	return local levels _cons
	if "`qi'"=="ev" {
		qui gen `double' `stub' = `ev'
		return local varlist `stub'
		return local title "Expected values"
		return local exp "E(`e(depvar)')"
		return local coef "Mean"
	}
	if "`qi'"=="pv" {
		qui gen `double' `stub' = `pv'
		return local varlist `stub'
		return local title "Predicted values"
		return local exp "Pred(`e(depvar)')"
		return local coef "Mean"
	}
end

*----------------------------
* QI_logit
*----------------------------
program define QI_logit, rclass
	syntax name(name=stub) [if] [in], mat(name) qi(name) [offset(real 0) eq(integer 1) double]
	//**Option eq() ignored - used for parsing blogit, bprobit
	marksample touse
	tempname X
	mat `X' = `mat'

	// function
	if "`e(cmd)'"=="logit"    local func invlogit
	if "`e(cmd)'"=="blogit"   local func invlogit
	if "`e(cmd)'"=="logistic" local func invlogit
	if "`e(cmd)'"=="probit"   local func normal
	if "`e(cmd)'"=="bprobit"  local func normal

	// xb
	tempvar xb
	qui matrix score `xb' = `X' if `touse'
	qui replace `xb' = `xb' + `offset' if `touse'

	// E(Y)
	tempvar ev
	qui gen `ev' = `func'(`xb') if `touse'
	
	// Pred(Y)
	if "`qi'"=="pv" {
		tempvar pv
		qui gen `pv'= rbinomial(1,`ev') if `touse'
	}

	// generate variables and info
	if "`qi'"=="ev" {
		return local levels _cons
		qui gen `double' `stub' = `ev'
		return local varlist `stub'
		return local title "Expected values"
		return local exp "Pr(`e(depvar)')"
		return local coef "Probability"
	}
	if "`qi'"=="pv" {
		return local levels 0 1
		qui gen `double' `stub' = `pv'
		return local varlist `stub'
		return local title "Predicted values"
		return local exp "Pred(`e(depvar)')"
		return local coef "Proportion"
	}
end

*----------------------------
* QI_logistic
*----------------------------
program define QI_logistic
	QI_logit `0'
end

*----------------------------
* QI_blogit
*----------------------------
program define QI_blogit
	QI_logit `0'
end

*----------------------------
* QI_probit
*----------------------------
program define QI_probit
	QI_logit `0'
end

*----------------------------
* QI_bprobit
*----------------------------
program define QI_bprobit
	QI_logit `0'
end

*----------------------------
* QI_cloglog
*----------------------------
program define QI_cloglog, rclass
	syntax name(name=stub) [if] [in], mat(name) qi(name) [offset(real 0) double]
	marksample touse
	tempname X
	mat `X' = `mat'

	// xb
	tempvar xb
	qui matrix score `xb' = `X' if `touse'
	qui replace `xb' = `xb' + `offset' if `touse'

	// E(Y)
	tempvar ev
	qui gen `ev' = 1-exp(-exp(`xb')) if `touse'
	
	// Pred(Y)
	if "`qi'"=="pv" {
		tempvar pv
		qui gen `pv'= rbinomial(1,`ev') if `touse'
	}

	// generate variables and info
	if "`qi'"=="ev" {
		return local levels _cons
		qui gen `double' `stub' = `ev'
		return local varlist `stub'
		return local title "Expected values"
		return local exp "Pr(`e(depvar)')"
		return local coef "Probability"
	}
	if "`qi'"=="pv" {
		return local levels 0 1
		qui gen `double' `stub' = `pv'
		return local varlist `stub'
		return local title "Predicted values"
		return local exp "Pred(`e(depvar)')"
		return local coef "Proportion"
	}
end

*----------------------------
* QI_scobit
*----------------------------
program define QI_scobit, rclass
	syntax name(name=stub) [if] [in], mat(name) qi(name) [offset(real 0) double]
	marksample touse
	tempname X
	mat `X' = `mat'
	
	// xb
	tempvar xb alpha
	qui matrix score `xb' = `X' if `touse', equation(#1)
	qui replace `xb' = `xb' + `offset' if `touse'

	qui matrix score `alpha' = `X' if `touse', equation(lnalpha) 	
	qui replace `alpha' = exp(`alpha') if `touse'

	// E(Y)
	tempvar ev
	qui gen `ev' = 1 - 1/(1+exp(`xb'))^`alpha' if `touse'

	// Pred(Y)
	if "`qi'"=="pv" {
		tempvar pv
		qui gen `pv'= rbinomial(1,`ev') if `touse'
	}

	// generate variables and info
	if "`qi'"=="ev" {
		return local levels _cons
		qui gen `double' `stub' = `ev'
		return local varlist `stub'
		return local title "Expected values"
		return local exp "Pr(`e(depvar)')"
		return local coef "Probability"
	}
	if "`qi'"=="pv" {
		return local levels 0 1
		qui gen `double' `stub' = `pv'
		return local varlist `stub'
		return local title "Predicted values"
		return local exp "Pred(`e(depvar)')"
		return local coef "Proportion"
	}
end

*----------------------------
* QI_hetprobit
*----------------------------
program define QI_hetprobit, rclass
	syntax name(name=stub) [if] [in], mat(name) qi(name) [offset1(real 0) offset2(real 0) double]
	marksample touse
	tempname X
	mat `X' = `mat'
	
	// xb
	tempvar xb sigma
	qui matrix score `xb' = `X' if `touse', equation(#1)
	qui replace `xb' = `xb' + `offset1' if `touse'

	qui matrix score `sigma' = `X' if `touse', equation(#2) 
	qui replace `sigma' = `sigma' + `offset2' if `touse'
	qui replace `sigma' = exp(`sigma') if `touse'

	// E(Y)
	tempvar ev
	qui gen `ev' = normal(`xb'/`sigma') if `touse'

	// Pred(Y)
	if "`qi'"=="pv" {
		tempvar pv
		qui gen `pv'= rbinomial(1,`ev') if `touse'
	}

	// generate variables and info
	if "`qi'"=="ev" {
		return local levels _cons
		qui gen `double' `stub' = `ev'
		return local varlist `stub'
		return local title "Expected values"
		return local exp "Pr(`e(depvar)')"
		return local coef "Probability"
	}
	if "`qi'"=="pv" {
		return local levels 0 1
		qui gen `double' `stub' = `pv'
		return local varlist `stub'
		return local title "Predicted values"
		return local exp "Pred(`e(depvar)')"
		return local coef "Proportion"
	}
end

*----------------------------
* QI_biprobit
*----------------------------
program define QI_biprobit, rclass
	syntax name(name=stub) [if] [in], mat(name) qi(name) eq(integer) [offset1(real 0) offset2(real 0) double]
	marksample touse
	tempname X
	mat `X' = `mat'

	// xb
	tempvar xb zg r
	qui matrix score `xb' = `X' if `touse', equation(#1)
	qui replace `xb' = `xb' + `offset1' if `touse'

	qui matrix score `zg' = `X' if `touse', equation(#2) 
	qui replace `zg' = `zg' + `offset2' if `touse'

	qui matrix score `r' = `X' if `touse', equation(#3) 
	qui replace `r' = (exp(2*`r')-1)/(exp(2*`r')+1) if `touse'

	// E(Y)
	tempvar p00 p10 p01 p11 ev0 ev1 
	qui gen `p00' = binorm(-`xb',-`zg', `r') if `touse'
	qui gen `p10' = binorm( `xb',-`zg',-`r') if `touse'
	qui gen `p01' = binorm(-`xb', `zg',-`r') if `touse'
	qui gen `p11' = binorm( `xb', `zg', `r') if `touse'
	if `eq' == 1 {
		qui gen `ev0' = `p00' + `p01' if `touse' //P00+P01
		qui gen `ev1' = `p10' + `p11' if `touse' //P10+P11
	}
	if `eq' == 2 {
		qui gen `ev0' = `p00' + `p10' if `touse' //P00+P10
		qui gen `ev1' = `p01' + `p11' if `touse' //P01+P11
	}

	// Pred(Y)
	if "`qi'"=="pv" {
		tempvar pv
		if `eq' == 1 local cat 0 1 0 1
		if `eq' == 2 local cat 0 0 1 1
		qui rmultinom `p00' `p10' `p01' `p11' if `touse', newvar(`pv') cat(`cat')
	}	

	// generate variables and info
	return local levels 0 1
	if "`qi'"=="ev" {
		qui gen `double' `stub'_0 = `ev0'
		qui gen `double' `stub'_1 = `ev1'
		return local varlist `stub'_0 `stub'_1
		return local title "Expected values"
		return local exp "Pr(`: word `eq' of `e(depvar)'')"
		return local coef "Probability"
	}
	if "`qi'"=="pv" {
		qui gen `double' `stub' = `pv'
		return local varlist `stub'
		return local title "Predicted values"
		return local exp "Pred(`: word `eq' of `e(depvar)'')"
		return local coef "Proportion"
	}
end

*----------------------------
* QI_heckprob
*----------------------------
program define QI_heckprob, rclass
	syntax name(name=stub) [if] [in], mat(name) qi(name) eq(integer) [offset1(real 0) offset2(real 0) double]
	marksample touse
	tempname X
	mat `X' = `mat'

	// xb
	tempvar xb zg r
	qui matrix score `xb' = `X' if `touse', equation(#1)
	qui replace `xb' = `xb' + `offset1' if `touse'

	qui matrix score `zg' = `X' if `touse', equation(#2) 
	qui replace `zg' = `zg' + `offset2' if `touse'

	qui matrix score `r' = `X' if `touse', equation(#3) 
	qui replace `r' = (exp(2*`r')-1)/(exp(2*`r')+1) if `touse'

	// E(Y)
	tempvar pj0 p01 p11 ev0 ev1
	qui gen `pj0' = normal(-`zg') if `touse'
	qui gen `p01' = normal( `zg') - binorm( `xb', `zg', `r') if `touse'
	qui gen `p11' = binorm( `xb', `zg', `r') if `touse'
	if `eq' == 1 {
		qui gen `ev1' = `p11' if `touse'
		qui gen `ev0' = 1-`ev1' if `touse'
	}
	if `eq' == 2 {
		qui gen `ev0' = `pj0' if `touse'
		qui gen `ev1' = 1-`ev0' if `touse'		
	}

	// Pred(Y)
	if "`qi'"=="pv" {
		tempvar pv
		if `eq' == 1 local cat 0 0 1
		if `eq' == 2 local cat 0 1 1
		qui rmultinom `pj0' `p01' `p11' if `touse', newvar(`pv') cat(`cat')
	}	

	// generate variables and info
	return local levels 0 1
	if "`qi'"=="ev" {
		qui gen `double' `stub'_0 = `ev0'
		qui gen `double' `stub'_1 = `ev1'
		return local varlist `stub'_0 `stub'_1
		return local title "Expected values"
		return local exp "Pr(`: word `eq' of `e(depvar)'')"
		return local coef "Probability"
	}
	if "`qi'"=="pv" {
		qui gen `double' `stub' = `pv'
		return local varlist `stub'
		return local title "Predicted values"
		return local exp "Pred(`: word `eq' of `e(depvar)'')"
		return local coef "Proportion"
	}
end
	
*----------------------------
* QI_ologit
*----------------------------
program define QI_ologit, rclass
	syntax name(name=stub) [if] [in], mat(name) qi(name) [offset(real 0) double]
	marksample touse
	tempname X
	mat `X' = `mat'

	if "`e(cmd)'"=="ologit" local func invlogit
	if "`e(cmd)'"=="oprobit" local func normal
	
	// xb
	tempvar xb
	qui matrix score `xb' = `X' if `touse', equation(#1)
	qui replace `xb' = `xb' + `offset' if `touse'

	forvalues k = 1/`e(k_aux)' {
		tempvar cut`k'
		qui matrix score `cut`k'' = `X' if `touse', equation(#`=`k'+1')
	}

	// E(Y)
	tempvar ev1 ev`e(k_cat)'
	qui gen `ev1' = `func'(`cut1'-`xb') if `touse'
	forvalues k = 2/`=`e(k_cat)'-1' {
		tempvar ev`k'
		qui gen `ev`k''=`func'(`cut`k''-`xb')-`func'(`cut`=`k'-1''-`xb') if `touse'
	}
	qui gen `ev`e(k_cat)'' = 1-`func'(`cut`=`e(k_cat)'-1''-`xb') if `touse'

	// Pred(Y)
	if "`qi'"=="pv" {
		mat2loc e(cat), local(cat) cols
		tempvar pv
		qui rmultinom `ev1'-`ev`e(k_cat)'' if `touse', newvar(`pv') cat(`cat')
	}
	
	// generate variables and info
	mat2loc e(cat), local(levels) cols
	return local levels `levels'
	if "`qi'"=="ev" {
		forvalues k = 1/`e(k_cat)' {
			qui gen `double' `stub'_`k' = `ev`k''
			local varlist `varlist' `stub'_`k'
		}
		return local varlist `varlist'
		return local title "Expected values"
		return local exp "Pr(`e(depvar)')"
		return local coef "Probability"
	}
	if "`qi'"=="pv" {
		qui gen `double' `stub' = `pv'
		return local varlist `stub'
		return local title "Predicted values"
		return local exp "Pred(`e(depvar)')"
		return local coef "Proportion"
	}
end

*----------------------------
* QI_oprobit
*----------------------------
program define QI_oprobit
	QI_ologit `0'
end

*----------------------------
* QI_mlogit
*----------------------------
program define QI_mlogit, rclass
	syntax name(name=stub) [if] [in], mat(name) qi(name) [double]
	marksample touse
	tempname X
	mat `X' = `mat'
	
	// exp(xb), denom
	tempvar denom
	qui gen `denom' = 1 if `touse'
	forvalues k = 1/`e(k_out)' {
		if `k' == e(ibaseout) continue
		tempvar xb`k'
		qui matrix score `xb`k'' = `X' if `touse', equation(#`k')
		qui replace `xb`k'' = exp(`xb`k'') if `touse'
		qui replace `denom' = `denom' + `xb`k'' if `touse'
	}

	// E(Y)
	forvalues k = 1/`e(k_out)' {
		tempvar ev`k'
		if `k' == e(ibaseout) qui gen `ev`k'' = 1/`denom'
		else qui gen `ev`k'' = `xb`k''/`denom'
	}
	// Pred(Y)
	if "`qi'"=="pv" {
		mat2loc e(out), local(cat) cols
		tempvar pv
		qui rmultinom `ev1'-`ev`e(k_out)'' if `touse', newvar(`pv') cat(`cat')
	}
	
	// generate variables and info
	mat2loc e(out), local(levels) cols
	return local levels `levels'
	if "`qi'"=="ev" {
		forvalues k = 1/`e(k_out)' {
			qui gen `double' `stub'_`k' = `ev`k''
			local varlist `varlist' `stub'_`k'
		}
		return local varlist `varlist'
		return local title "Expected values"
		return local exp "Pr(`e(depvar)')"
		return local coef "Probability"
	}
	if "`qi'"=="pv" {
		qui gen `double' `stub' = `pv'
		return local varlist `stub'
		return local title "Predicted values"
		return local exp "Pred(`e(depvar)')"
		return local coef "Proportion"
	}
end

exit
