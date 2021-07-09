*! 1.0.1 NJC 17 Aug 2011
*! 1.0.0 NJC & SPJ 15 Dec 2006
* Fit two-parameter inverse gamma distribution by ML 

/*------------------------------------------------ playback request */
program invgammafit, eclass byable(onecall)
	version 8.1
	if replay() {
		if "`e(cmd)'" != "invgammafit" {
			di as err "results for invgammafit not found"
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
	syntax varlist(max=1) [if] [in] [fw aw] [,  ///
		ALPHAvar(varlist numeric) BETAvar(varlist numeric) ///
		Robust Cluster(varname) Level(integer $S_level) noLOG * ]
		
	local y "`varlist'"
	marksample touse 
	markout `touse' `varlist' `alphavar' `betavar' `cluster'
	
	qui count if `y' <= 0 & `touse'
	if r(N) {
		noi di " "
		noi di as txt "warning: {res:`y'} has `r(N)' values <= 0;" _c
		noi di as txt " not used in calculations"
	}
	qui replace `touse' = 0 if `y' <= 0

	qui count if `touse' 
	if r(N) == 0 error 2000 

	local title "ML fit of two-parameter inverse gamma dist'n"
	local nalpha : word count `alphavar'
	local nbeta : word count `betavar'

	local wtype `weight'
	local wtexp `"`exp'"'
	if "`weight'" != "" local wgt `"[`weight'`exp']"'  
	
	if "`cluster'" != "" { 
		local robust "robust"
		local clopt "cluster(`cluster')" 
	}

	if "`level'" != "" local level "level(`level')"
        local log = cond("`log'" == "", "noisily", "quietly") 
			
	mlopts mlopts, `options'
	global S_MLy "`y'"
	`log' ml model lf invgammafit_lf (alpha: `alphavar') (beta: `betavar') ///
		`wgt' if `touse' , maximize 				  ///
		collinear title(`title') `robust'       		  ///
		search(on) `clopt' `level' `mlopts' `stdopts' `modopts'

	eret local cmd "invgammafit"
	eret local depvar "`y'"

	tempname b balpha bbeta
	mat `b' = e(b)
	mat `balpha' = `b'[1,"alpha:"] 
	mat `bbeta' = `b'[1,"beta:"]
	eret matrix b_alpha = `balpha'
	eret matrix b_beta = `bbeta'
	eret scalar length_b_alpha = 1 + `nalpha'
	eret scalar length_b_beta = 1 + `nbeta'

	if "`alphavar'`betavar'" == ""  {
		tempname e		
		mat `e' = e(b)
		eret scalar alpha = `e'[1,1]
		eret scalar beta = `e'[1,2]
	}	
	
	Display, `level' `diopts'
end

program Display
	syntax [, Level(int $S_level) *]
	local diopts "`options'"
	ml display, level(`level') `diopts'
	if `level' < 10 | `level' > 99 local level = 95
end

*! NJC 1.0.0 15 Dec 2006 
program invgammafit_lf
	version 8.1
	args lnf alpha beta 
	qui replace `lnf' = ///
	-(`alpha' + 1) * ln($S_MLy) - (`beta' / $S_MLy) ///
	- (lngamma(`alpha') -`alpha' * ln(`beta'))
end 		

