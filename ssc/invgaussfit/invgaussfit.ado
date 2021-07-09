*! 1.0.0 NJC & SPJ 13 Dec 2006
* Fit two-parameter inverse Gaussian distribution by ML 

/*------------------------------------------------ playback request */
program invgaussfit, eclass byable(onecall)
	version 8.1
	if replay() {
		if "`e(cmd)'" != "invgaussfit" {
			di as err "results for invgaussfit not found"
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
		MUvar(varlist numeric) LAMBDAvar(varlist numeric) ///
		Robust Cluster(varname) Level(integer $S_level) noLOG * ]
		
	local y "`varlist'"
	marksample touse 
	markout `touse' `varlist' `muvar' `lambdavar' `cluster'
	
	qui count if `y' <= 0 & `touse'
	if r(N) {
		noi di " "
		noi di as txt "warning: {res:`y'} has `r(N)' values <= 0;" _c
		noi di as txt " not used in calculations"
	}
	qui replace `touse' = 0 if `y' <= 0

	qui count if `touse' 
	if r(N) == 0 error 2000 

	local title "ML fit of two-parameter inverse Gaussian dist'n"
	local nmu : word count `muvar'
	local nlambda : word count `lambdavar'

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
	`log' ml model lf invgaussfit_lf (mu: `muvar') (lambda: `lambdavar') ///
		`wgt' if `touse' , maximize 				  ///
		collinear title(`title') `robust'       		  ///
		search(on) `clopt' `level' `mlopts' `stdopts' `modopts'

	eret local cmd "invgaussfit"
	eret local depvar "`y'"

	tempname b bmu blambda
	mat `b' = e(b)
	mat `bmu' = `b'[1,"mu:"] 
	mat `blambda' = `b'[1,"lambda:"]
	eret matrix b_mu = `bmu'
	eret matrix b_lambda = `blambda'
	eret scalar length_b_mu = 1 + `nmu'
	eret scalar length_b_lambda = 1 + `nlambda'

	if "`muvar'`lambdavar'" == ""  {
		tempname e		
		mat `e' = e(b)
		eret scalar mu = `e'[1,1]
		eret scalar lambda = `e'[1,2]
	}	
	
	Display, `level' `diopts'
end

program Display
	syntax [, Level(int $S_level) *]
	local diopts "`options'"
	ml display, level(`level') `diopts'
	if `level' < 10 | `level' > 99 local level = 95
end

*! NJC 1.0.0 7 Dec 2006 
program invgaussfit_lf
	version 8.1
	args lnf mu lambda 
	qui replace `lnf' = ///
	0.5 * ln(`lambda') - ln(2 * _pi) - 3 * ln($S_MLy) ///
	- (`lambda'/(2 * `mu'^2 * $S_MLy) * ($S_MLy - `mu')^2)
end 		

