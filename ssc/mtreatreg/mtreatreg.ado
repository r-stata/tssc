*! version 2.0.0 09jul2009
*! author: Partha Deb
* version 1.1.3 15may2009
* version 1.1.2 16mar2009
* version 1.1.1 09mar2009
* version 1.1.0 25feb2009
* version 1.0.0 04feb2009

*** program for NB2 with multinomial endogeneity           ***
*** 5 parts: 1. this routine; 2. ml for mixed mlogit;      ***
*** 3. ml for joint mmlogit and nb2 (mtreatreg);            ***
*** 4. mata mmlogit; 5; mata mtreatreg;                     ***


program mtreatreg, sortpreserve
	version 10.1

	if replay() {
		if ("`e(cmd)'" != "mtreatreg") error 301
		Replay `0'
	}
	else Estimate `0'
end

program Estimate, eclass

	// parse the command
	syntax varlist [fweight pweight iweight] [if] [in] ///
		, MTREATment(string) DENsity(string) SIMulationdraws(integer) ///
		[BASEcategory(string) Robust CLuster(varname) ///
		FRom(string) FACFRom(string) PREfix(string) ///
		FACSCale(real 1) STARTpoint(integer 20) VERbose *]

	mata: mata clear

	mlopts mlopts, `options'

	if "`prefix'"=="" local prefix _T

	if "`cluster'" != "" {
		local clopt cluster(`cluster')
	}

	if "`weight'" != "" {
		tempvar wvar
		quietly gen double `wvar' `exp'
		local wgt "[`weight'=`wvar']"
	}

	// check syntax for the outcome density
	if  "`density'"!="normal" ///
		& "`density'"!="logit" ///
		& "`density'"!="gamma" ///
		& "`density'"!="negbin1" ///
		& "`density'"!="negbin2" {
		di in red "invalid syntax: outcome density incorrectly specified"
		exit 198
	}

	// define variable lists
	gettoken lhs rhs : varlist
	gettoken mtreat mtreatment : mtreatment, parse("=")
	gettoken equal mrhs : mtreatment, parse("=")
	if "`equal'" != "=" {
		di in red "invalid syntax: equal sign is needed in the treatment equation"
		exit 198
	}

	// mark the estimation sample
	marksample touse
	markout `touse' `mtreat'
	markout `touse' `mrhs'
	markout `touse' `wvar'
	markout `touse' `cluster', strok

	// test collinearity
	_rmcoll `rhs' `wgt' if `touse', `constant'
	local rhs `r(varlist)'
	_rmcoll `mrhs' `wgt' if `touse', `constant'
	local mrhs `r(varlist)'

	tempvar mtvar 
	tempname mlabel

	qui egen `mtvar' = group(`mtreat') if `touse', lname(`mlabel')

	tempname N altlevels
	local tabwgt  "`weight'"
	if ("`tabwgt'" == "pweight") local tabwgt "iweight"
	qui tabulate `mtreat' [`tabwgt'`exp'] if `touse', matcell(`N') matrow(`altlevels')
	local nalt = r(r)
	if `nalt' < 3 {
		di as error "there are `=`nalt'-1' treatments in `mtreat'; the minimum " ///
		 "number of treatments is 2"
		exit 148
	}

	if "`basecategory'" == "" {
		/* mimic -mlogit-: use maximum frequency as default base treatment */
		local ni = `N'[1,1]
		local ibase = 1
		local basecategory = `altlevels'[1,1]
		forvalues i=2/`nalt' {
			if `N'[`i',1] > `ni' {
				local ni = `N'[`i',1]
				local ibase = `i'
				local basecategory = `altlevels'[`i',1]
			}
		}
	}
	else {
		local altlabels : value label `mtreat'
		AlternativeIndex "`altlevels'" "`altlabels'" "`basecategory'" "`mtreat'" 
		local ibase = r(index)
	}

	tempname bintvar
	qui tab `mtvar' if `touse', gen(`bintvar')

	_labels2names `mtreat' if `touse', stub(category) noint
	local altlabels `"`s(names)'"'
	local nalt = `s(n_cat)'

	forvalues i=1/`nalt' {
		if (`i' == `ibase') continue
		local ai : word `i' of `altlabels'
		local bintvarname`i' `"`prefix'`ai'"'
		capture drop `bintvarname`i''
		rename `bintvar'`i' `bintvarname`i''
		label variable `bintvarname`i''
		local yTnames `"`yTnames' `bintvarname`i''"'
		local mmlmodel `"`mmlmodel' (`bintvarname`i'': `bintvarname`i'' = `mrhs')"'
		local mtvars `"`mtvars' `bintvarname`i''"'
		local lam`i' "/lambda_`ai'"
		local lamname `" `lamname' `lam`i'' "'
	}


	qui sum `touse'
	scalar nobs = r(sum)
	scalar neq = `nalt'-1
	scalar neqall = 2*`neq' + 2
	scalar sim = `simulationdraws'

	mata: yT = st_data(., tokens("`yTnames'"), "`touse'")
	mata: xT = st_data(., tokens("`mrhs'"), "`touse'")
	mata: yO = st_data(., ("`lhs'"), "`touse'")
	mata: xO = st_data(., tokens("`mtvars' `rhs'"), "`touse'")

	mata: _mtreatreg_nobs = st_numscalar("nobs")
	mata: _mtreatreg_rnd = `facscale'*invnormal(halton(_mtreatreg_nobs ///
						*`simulationdraws',`=neq',`startpoint',0))
	mata: _mtreatreg_rmat=.

	forvalues i=1/`=neq' {
		mata: _mtreatreg_rnd`i'=colshape(_mtreatreg_rnd[,`i'],`simulationdraws')
		if (`i'==1) mata: _mtreatreg_rmat = _mtreatreg_rnd`i'
		else mata: _mtreatreg_rmat = (_mtreatreg_rmat, _mtreatreg_rnd`i')
		mata: mata drop _mtreatreg_rnd`i'
	}
	mata: mata drop _mtreatreg_rnd

	tempname s gb
	qui mlogit `mtvar' `mrhs' `wgt' if `touse', base(`ibase')
	mat `s'=e(b)
	local contin init(`s',copy) search(off)

	di in green _n "Fitting mixed multinomial logit regression for treatments:"
	ml model d2 mtreatreg_mmlogit_lf `mmlmodel' `wgt' if `touse' ///
		, `robust' `clopt' `mlopts' `contin' missing maximize
	if "`verbose'"=="verbose" {
		ml display
		}
	mat `s'=e(b)
	scalar ll_mtreat = e(ll)

	if "`density'"=="logit" {
		local densityname "logit"
		di in green _n "Fitting Logit regression for outcome:"
		if "`verbose'"=="verbose" {
			logit `lhs' `mtvars' `rhs' `wgt' if `touse', `robust' `clopt'
		}
		else {
			logit `lhs' `mtvars' `rhs' `wgt' if `touse', `robust' `clopt' ///
				nocoef
		}
	}
	if "`density'"=="normal" {
		local densityname "Normal"
		local scale "sigma"
		di in green _n "Fitting Normal regression for outcome:"
		qui reg `lhs' `mtvars' `rhs' `wgt' if `touse'
		matrix `gb' = e(b), ln(e(rmse))
		local contin init(`gb',copy) search(off)
		ml model d2 normalreg_lf (`lhs': `lhs' = `mtvars' `rhs') /ln`scale' ///
			`wgt' if `touse', `contin' `robust' `clopt' `mlopts' missing maximize
		if "`verbose'"=="verbose" {
			ml display
		}
	}
	if "`density'"=="gamma" {
		local densityname "Gamma"
		local scale "alpha"
		di in green _n "Fitting Gamma regression for outcome:"
		qui glm `lhs' `mtvars' `rhs' if `touse', family(gamma) link(log)
		matrix `gb' = e(b), 0
		local contin init(`gb',copy) search(off)
		ml model d2 gammareg_lf (`lhs': `lhs' = `mtvars' `rhs') /ln`scale' ///
			`wgt' if `touse', `contin' `robust' `clopt' `mlopts' missing maximize
		if "`verbose'"=="verbose" {
			ml display
		}
	}

	if "`density'"=="negbin1" {
		local densityname "Negative Binomial-1"
		local scale "delta"
		di in green _n "Fitting Negative Binomial-1 regression for outcome:"
		if "`verbose'"=="verbose" {
			nbreg `lhs' `mtvars' `rhs' `wgt' if `touse', `robust' `clopt' ///
				disp(constant)
		}
		else {
			nbreg `lhs' `mtvars' `rhs' `wgt' if `touse', `robust' `clopt' ///
			disp(constant) nodisplay
		}
	}
	if "`density'"=="negbin2" {
		local densityname "Negative Binomial-2"
		local scale "alpha"
		di in green _n "Fitting Negative Binomial-2 regression for outcome:"
		if "`verbose'"=="verbose" {
			nbreg `lhs' `mtvars' `rhs' `wgt' if `touse', `robust' `clopt'
		}
		else {
			nbreg `lhs' `mtvars' `rhs' `wgt' if `touse', `robust' `clopt' nodisplay
		}
	}
	scalar ll_outcome = e(ll)
	if "`density'"=="logit" {
		local mtreatregmodel `"`mmlmodel' (`lhs': `lhs' = `mtvars' `rhs') `lamname' "'
	}
	else {
		local mtreatregmodel `"`mmlmodel' (`lhs': `lhs' = `mtvars' `rhs') /ln`scale' `lamname' "'
	}

	if "`from'"=="" {
		if "`facfrom'"=="" {
			mat `s'=(`s',e(b),J(1,neq,0))
		}
		else mat `s'=(`s',e(b),`facfrom')
	}
	else mat `s'=`from'
	local contin init(`s',copy) search(off)

	local title "Multinomial treatment-effects regression"
	di in green _n "Fitting full model for treatments and outcome:"
//	ml model d2debug mtreatreg_`density'_lf `mtreatregmodel' if `touse', max `contin' // gradient hessian
	ml model d2 mtreatreg_`density'_lf `mtreatregmodel' `wgt' if `touse' ///
			, title(`title') `robust' `clopt' `mlopts' `contin' missing ///
			maximize waldtest(`=neq+1')

	if "`density'"=="logit" {
		ereturn scalar k_aux = `=neq'
	}
	else {
		ereturn scalar k_aux = `=neq+1'
	}
	ereturn scalar i_base = `ibase'
	ereturn scalar simulationdraws = sim
	ereturn scalar ll_exog = ll_mtreat + ll_outcome
	ereturn local density `density'
	ereturn local facscale `facscale'
	ereturn local predict "mtreatreg_`density'_p"
	ereturn local cmd mtreatreg
	ereturn local outcome `lhs'
	ereturn local mtreatment `mtreat'

	Replay `mtreat'

end 


program Replay

	if "`e(density)'"=="normal" {
		local scale "sigma"
	}
	if "`e(density)'"=="gamma" {
		local scale "alpha"
	}
	if "`e(density)'"=="negbin1" {
		local scale "delta"
	}
	if "`e(density)'"=="negbin2" {
		local scale "alpha"
	}

	if `e(k_aux)' {
		local `scale' diparm(ln`scale', exp label(`scale'))
	}
	ml display, ``scale''

	local i = `e(i_base)'
	_labels2names `e(mtreatment)', stub(category) noint
	local altlabels `"`s(names)'"'
	local b : word `i' of `altlabels'

	di in yellow `"{p}Notes:{p_end}"'
	di in gr `"{p}1. `b' is the control group (base category){p_end}"'
	di in gr `"{p}2. `e(simulationdraws)' Halton sequence-based quasirandom draws per observation{p_end}"'
	di in gr `"{p}3. Outcome density is `e(density)'{p_end}"'
	di in gr `"{p}4. Standard deviation of factor density is `e(facscale)'{p_end}"'

end


program AlternativeIndex, rclass
	args altlevels altlabels level choice

	local index = .
	local nalt = rowsof(`altlevels')
	if "`level'"!="" {
		local i = 0
		while `++i'<=`nalt' & `index'>=. {
			local ialt = `altlevels'[`i',1]
			if (`"`level'"'==`"`ialt'"') local index = `i'
		}
		if `index'>=. & "`altlabels'"!="" {
			local i = 0
			while `++i'<=`nalt' & `index'>=. {
				local label : label `altlabels' `=`altlevels'[`i',1]'
				if (`"`level'"'==`"`label'"') local index = `i'
			}
		}
		if `index'>=. {
			di as error "{p}basetreatment(`level') is not an "   ///
	"outcome of `choice'; use {help tabulate##|_new:tabulate} for a " ///
			 "list of values{p_end}"
			exit 459
		}
	}
	return local index = `index'
end 
