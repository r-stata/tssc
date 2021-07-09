*! 1.0.2 MLB 01 Aug 2012
*! 1.0.1 MLB 25 May 2010
*! 1.0.0 MLB 26 Apr 2008
* Fit a zero one inflated beta

/*------------------------------------------------ playback request */
program zoib, eclass byable(onecall)
	if c(stata_version) >= 11 {
		version 11
		global fv "fv"
	}
	else if c(stata_version) >= 9 {
		version 9
	}
	else {
		version 8.2
	}
	if replay() {
		if "`e(cmd)'" != "zoib" {
			di as err "results for zoib not found"
			exit 301
		}
		if _by() error 190 
		Display `0'
		exit `rc'
	}
	if _by() by `_byvars'`_byrc0': Estimate `0'
	else Estimate `0'
end

/*------------------------------------------------ estimation */
program Estimate, eclass byable(recall)
	syntax varlist(numeric $fv) [if] [in] [fw pw aw] [,  ///
		noONE noZERO ZEROInflate(varlist $fv) ONEInflate(varlist $fv) ///
		PHIvar(varlist $fv) Cluster(varname) Level(integer $S_level) noLOG Robust * ]

	if "`one'" != "" & "`oneinflate'"!= "" {
		di as err "cannot specify both noone and oneinflate"
		exit 198 
	}	
	
	if "`zero'" != "" & "`zeroinflate'"!= "" {
			di as err "cannot specify both nozero and zeroinflate"
			exit 198 
	}
	
	gettoken y x: varlist
	if c(stata_version) >= 11 {
		_fv_check_depvar `y'
	}
	marksample touse 
	markout `touse' `varlist' `zeroinflate' `oneinflate' `cluster'
	
	qui count if (`y' < 0 | `y' > 1) & `touse'
	if r(N) {
		noi di " "
		noi di as txt "warning: {res:`y'} has `r(N)' values < 0 or > 1;" _c
		noi di as txt " not used in calculations"
	}
	qui replace `touse' = 0 if `y' < 0 | `y' > 1 

// No inflate equation when there are no zeros or ones in the dependent variable	
	qui count if `y' == 0 & `touse'
	if r(N) == 0 {
		if "`zeroinflate'" != "" {
			di as err "the zeroinflate() option can only be specified if the dependent variable contains zeros"
			exit 198
		}
		local zero "zero"
	}
	qui count if `y' == 1 & `touse'
	if r(N) == 0 {
		if "`oneinflate'" != "" {
			di as err "the oneinflate() option can only be specified if the dependent variable contains ones"
			exit 198
		}
		local one "one"
	}
	
	local param = cond("`one'"  != "",                   /*
	           */ cond("`zero'" != "", "beta", "zib"), /*
	           */ cond("`zero'" != "","oib","zoib"))

	if "`one'" != "" {
		qui count if `y' == 1
		if r(N) > 0 {
			noi di as txt "warning: {res:`y'} has `r(N)' values == 1;" _c
			noi di as txt " not used in calculations"
		}
		qui replace `touse' = 0 if `y' == 1
	}

	if "`zero'" != "" {
		qui count if `y' == 0
		if r(N) > 0 {
			noi di as txt "warning: {res:`y'} has `r(N)' values == 0;" _c
			noi di as txt " not used in calculations"
		}
		qui replace `touse' = 0 if `y' == 0
	}
	
	qui count if `touse' 
	if r(N) == 0 error 2000 
	
	
	local title "ML fit of `param'"
	
	local wtype `weight'
	local wtexp `"`exp'"'
	if "`weight'" != "" local wgt `"[`weight'`exp']"'  
	
	if "`cluster'" != "" { 
		local clopt "cluster(`cluster')" 
	}

	if "`level'" != "" local level "level(`level')"
    local log = cond("`log'" == "", "noisily", "quietly") 
	
	mlopts mlopts, `options'

	Init `y' if `touse' `wgt', param("`param'")

	tempname init
	matrix `init' = r(init)
	
	if "`param'" == "zib" {	
		`log' ml model lf zib_lf (proportion: `y' = `x')       ///
		                          (zeroinflate: `zeroinflate')  ///
		                          (ln_phi: `phivar')            ///
		                	  `wgt' if `touse' , maximize   ///
			                  collinear title(`title')      ///
			                  search(off) `clopt' `level'    ///
			                  `mlopts' `stdopts' `modopts'  ///
			                  init(`init') `robust'
	}
	if "`param'" == "oib" {	
		`log' ml model lf oib_lf (proportion: `y' = `x')       ///
		                          (oneinflate: `oneinflate')    ///
		                          (ln_phi: `phivar')            ///
		                	  `wgt' if `touse' , maximize   ///
			                  collinear title(`title')      ///
			                  search(off) `clopt' `level'    ///
			                  `mlopts' `stdopts' `modopts'   ///
			                  init(`init') `robust'
	}
	if "`param'" == "zoib" {
		`log' ml model lf zoib_lf (proportion: `y' = `x')       ///
		                           (oneinflate: `oneinflate')    ///
		                           (zeroinflate: `zeroinflate')  ///
		                           (ln_phi: `phivar')            ///
		                 	   `wgt' if `touse' , maximize   ///
			                   collinear title(`title')      ///
			                   search(off) `clopt' `level'    ///
			                   `mlopts' `stdopts' `modopts'  ///
			                   init(`init') `robust'
	}
	if "`param'" == "beta" {	
		`log' ml model lf zoib_beta_lf (proportion: `y' = `x')       ///
		                        (ln_phi: `phivar')            ///
		                 	`wgt' if `touse' , maximize   ///
			                collinear title(`title')      ///
			                search(off) `clopt' `level'    ///
			                `mlopts' `stdopts' `modopts'   ///
			                init(`init') `robust'
	}
	eret local cmd "zoib"
	eret local depvar "`y'"
	ereturn local predict "zoib_p"
	Display, `level' `diopts'
end

program Init, rclass
	syntax varname [if] [aw pw fw], param(string) 
	tempname init mu phi m var
	marksample touse
	
	if "`weight'" == "pweight" {
		local wgt "[aweight`exp']"
	}
	else {
		local wgt "[`weight'`exp']"
	}
	
	qui sum `varlist' `wgt' if `touse' & `varlist' > 0 & `varlist' < 1
	scalar `m' = r(mean)
	scalar `var' = r(Var)	
	if "`param'" == "beta" {
		scalar `mu' = ln(`m'/(1-`m'))
		scalar `phi' = ln((`m'*(1-`m'))/`var' - 1)
		matrix `init' = `mu', `phi'
		matrix colnames `init' = proportion:_cons ln_phi:_cons
	}
	else if "`param'" == "zib" {
		scalar `mu' = ln(`m'/(1-`m'))
		scalar `phi' = ln((`m'*(1-`m'))/`var' - 1)
		tempvar zero
		tempname zi
		qui gen byte `zero' = `varlist' == 0 if `touse'
		sum `zero', meanonly
		scalar `zi' = ln(`r(mean)'/(1-`r(mean)'))
		matrix `init' = `mu', `zi', `phi'
		matrix colnames `init' = proportion:_cons zeroinflate:_cons ln_phi:_cons
	}
	else if "`param'" == "oib" {
		scalar `mu' = ln(`m'/(1-`m'))
		scalar `phi' = ln((`m'*(1-`m'))/`var' - 1)
		tempvar one
		tempname oi
		qui gen byte `one' = `varlist' == 1 if `touse'
		sum `one', meanonly
		scalar `oi' = ln(`r(mean)'/(1-`r(mean)'))
		matrix `init' = `mu', `oi', `phi'
		matrix colnames `init' = proportion:_cons oneinflate:_cons ln_phi:_cons
	}
	else if "`param'" == "zoib" {
		scalar `mu' = ln(`m'/(1-`m'))
		scalar `phi' = ln((`m'*(1-`m'))/`var' - 1)
		tempvar zero
		tempname zi
		qui gen byte `zero' = `varlist' == 0 if `touse'
		sum `zero', meanonly
		scalar `zi' = ln(`r(mean)'/(1-`r(mean)'))
		tempvar one
		tempname oi
		qui gen byte `one' = `varlist' == 1 if `touse'
		sum `one', meanonly
		scalar `oi' = ln(`r(mean)'/(1-`r(mean)'))
		matrix `init' = `mu', `zi', `oi', `phi'
		matrix colnames `init' = proportion:_cons zeroinflate:_cons oneinflate:_cons ln_phi:_cons	
	}
	
	return matrix init = `init'
end 

program Display
	syntax [, Level(int $S_level) *]
	local diopts "`options'"
	if `level' < 10 | `level' > 99 local level = 95
	ml display, level(`level') `or' `diopts'
end
