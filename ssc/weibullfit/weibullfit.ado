*! 1.1.0 NJC 22 Sept 2014 
*! 1.0.0 NJC & SPJ 9 Nov 2007
* Fit two-parameter Weibull distribution by ML 

/*------------------------------------------------ playback request */
program weibullfit, eclass byable(onecall)
	version 8.1
	if replay() {
		if "`e(cmd)'" != "weibullfit" {
			di as err "results for weibullfit not found"
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
		Bvar(varlist numeric) Cvar(varlist numeric) ///
		Robust Cluster(varname) Level(integer $S_level) noLOG * ]
		
	local y "`varlist'"
	marksample touse 
	markout `touse' `varlist' `bvar' `cvar' `cluster'
	
	qui count if `y' < 0 & `touse'
	if r(N) {
		noi di " "
		noi di as txt "warning: {res:`y'} has `r(N)' values < 0;" _c
		noi di as txt " not used in calculations"
	}
	qui replace `touse' = 0 if `y' < 0

	qui count if `touse' 
	if r(N) == 0 error 2000 

	local title "ML fit of two-parameter Weibull distribution"
	local nb : word count `bvar'
	local nc : word count `cvar'

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
	`log' ml model lf weibullfit_lf (bpar: `bvar') (cpar: `cvar') ///
		`wgt' if `touse' , maximize 				  ///
		collinear title(`title') `robust'       		  ///
		search(on) `clopt' `level' `mlopts' `stdopts' `modopts'

	eret local cmd "weibullfit"
	eret local depvar "`y'"

	tempname b bb bc
	mat `b' = e(b)
	mat `bb' = `b'[1,"bpar:"] 
	mat `bc' = `b'[1,"cpar:"]
	eret matrix b_b = `bb'
	eret matrix b_c = `bc'
	eret scalar length_b_b = 1 + `nb'
	eret scalar length_b_c = 1 + `nc'

	if "`bvar'`cvar'" == ""  {
		tempname e		
		mat `e' = e(b)
		eret scalar bpar = `e'[1,1]
		eret scalar cpar = `e'[1,2]
	}	
	
	Display, `level' `diopts'
end

program Display
	syntax [, Level(int $S_level) *]
	local diopts "`options'"
	ml display, level(`level') `diopts'
	if `level' < 10 | `level' > 99 local level = 95
end

*! NJC 1.0.0 9 Nov 2007 
program weibullfit_lf
	version 8.1
	args lnf b c 
	qui replace `lnf' = ///
	ln(`c') - ln(`b') + (`c' - 1) * (ln($S_MLy) - ln(`b')) - ($S_MLy / `b')^`c' 
end 		

