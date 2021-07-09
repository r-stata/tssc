*! 1.0.1 NJC & SPJ 25 Oct 2010
*! 1.0.0 NJC & SPJ 17 Nov 2003
* Fit two-parameter Gumbel distribution by ML 

/*------------------------------------------------ playback request */
program gumbelfit, eclass byable(onecall)
	version 8.1
	if replay() {
		if "`e(cmd)'" != "gumbelfit" {
			di as err "results for gumbelfit not found"
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
		MUvar(varlist numeric) ALPHAvar(varlist numeric) ///
		Robust Cluster(varname) Level(integer $S_level) noLOG * ]
		
	local y "`varlist'"
	marksample touse 
	markout `touse' `varlist' `muvar' `alphavar' `cluster'
	
	qui count if `touse' 
	if r(N) == 0 error 2000 

	local title "ML fit of two-parameter Gumbel distribution"
	local nmu : word count `muvar'
	local nalpha : word count `alphavar'

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
	`log' ml model lf gumbelfit_lf (alpha: `alphavar') (mu: `muvar') ///
		`wgt' if `touse' , maximize 				 ///
		collinear title(`title') `robust'       		 ///
		search(on) `clopt' `level' `mlopts' `stdopts' `modopts'

	eret local cmd "gumbelfit"
	eret local depvar "`y'"

	tempname b bmu balpha
	mat `b' = e(b)
	mat `bmu' = `b'[1,"mu:"] 
	mat `balpha' = `b'[1,"alpha:"]
	eret matrix b_mu = `bmu'
	eret matrix b_alpha = `balpha'
	eret scalar length_b_mu = 1 + `nmu'
	eret scalar length_b_alpha = 1 + `nalpha'

	if "`muvar'`alphavar'" == ""  {
		tempname e		
		mat `e' = e(b)
		eret scalar mu = `e'[1,2]
		eret scalar alpha = `e'[1,1]
	}	
	
	Display, `level' `diopts'
end

program Display
	syntax [, Level(int $S_level) *]
	local diopts "`options'"
	ml display, level(`level') `diopts'
	if `level' < 10 | `level' > 99 local level = 95
end

