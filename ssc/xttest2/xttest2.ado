*! version 1.0.5  15aug2011  CFBaum   
* from xttest1 v1.0.3 and sureg
* following Greene, 2000, p. 601
* 1.0.1 published SJ-1, st0004
* 1.0.1: allow xtgls
* 1.0.2: mod to correct handling of unbalanced panels, trap errors of too few common obs
* 1.0.3: trap inadequate matsize
* 1.0.4: allow ivreg2
* 1.0.5: reduce criterion for singularity

program define xttest2, rclass
	version 6.0
	
	if "`e(cmd)'"=="xtreg" { local est 1 }
	if "`e(cmd)'"=="xtgls" { local est 2 }
	if "`e(cmd)'"=="ivreg2" { local est 3 }
	if "`est'" ==""	{ error 301 }
	if "`e(model)'" != "fe" & "`est'"=="1" {
		di in red "last estimates not xtreg, fe"
		exit 301
	}
	if "`*'"!="" { error 198 }
        
	tempvar touse  xb
	tempname cov cor CCp de

	qui gen byte `touse' = e(sample)
	preserve
	qui drop if `touse'==0
* cross-section indicator: get from tsset instead
*	local ivar "`e(ivar)'"
* number of cross sections
	if "`est'" == "1" | "`est'" == "2" {
		local ng "`e(N_g)'"
		}
* min length of time series
	local tb "`e(g_min)'"
* compute fixed effect e(i,t)
	if "`est'"   == "1" {
		qui predict double __e if `touse', e
	}
	else {
		qui predict double `xb' if `touse'
		qui gen double __e = `e(depvar)'-`xb'
	}
* reshape to wide so that VCE may be computed
* require that tsset has been executed to handle unbalanced panel properly
	qui tsset
	local tvar  "`r(timevar)'"
	local ivar  "`r(panelvar)'"
* for ivreg2, must calculate e(N_g) and e(g_min)
	if "`est'" == "3" {
		tempvar group Ti
        egen `group' = group(`ivar') if `touse'
        su `group', meanonly
        local ng = `r(max)'
        if `ng' == 1 {
        	di in r _n "Error: single-unit panel"
        	error 198
        	}
		qui by `ivar': gen long `Ti' = _N if _n==_N
		summ `Ti',meanonly
		local tb = `r(min)'
		}
	keep __e `ivar' `tvar'
	qui reshape wide __e, i(`tvar') j(`ivar')
*	keep __e `e(ivar)' `tvar'
*	qui reshape wide __e, i(`tvar') j(`e(ivar)')
* 4414: check to see that matsize is adequate
	local npanel = r(N)
	qui query memory
	if `npanel' > r(matsize) {
		di in r _n "Error: inadequate matsize; must be at least `npanel'"
		error 908
		}
	capt mat accum `cov' = __e*,dev noc
	if _rc == 2000 {
			di in r _n "Error: too few common observations across panel."
			error 2000
			}	
	mat `de' = det(`cov')
	local det = `de'[1,1]
	if abs(`det')<1.0e-37 {
			di in r _n "Correlation matrix of residuals is singular."
			error 131
			}
	local nbal "`r(N)'"
* code adapted from sureg BP test
	di " "
	di in gr "Correlation matrix of residuals:"
    mat `cor' = corr(`cov')
    mat list `cor', nohead format(%9.4f)

    mat `CCp' = `cor' * `cor''
    local tsig = (trace(`CCp') - `ng')*`tb' / 2
    local df = `ng' * (`ng' - 1) / 2
    di
    di in gr "Breusch-Pagan LM test of independence: chi2(`df') = " /*
    */ in ye %9.3f `tsig' in gr ", Pr = " %6.4f /*
    */ in ye chiprob(`df',`tsig')
	di in gr "Based on `nbal' complete observations over panel units"
    ret scalar chi2_bp = `tsig'
    ret scalar df_bp   = `df'
    ret scalar n_bp    = `nbal'	
end
exit

