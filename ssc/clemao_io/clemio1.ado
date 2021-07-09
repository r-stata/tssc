*! version 1.0.10  31jul2015   C F Baum
*  from RATS procedure clemio2.src and clemio2.ado
* 1.0.1 : mod to version 8.2, correct trim option
* 1.0.2 : add graph option
* 1.0.3 : samp correction
* 1.0.4 : permit onepanel
* 1.0.5 : correct breakpoint timing
* 1.0.6 : corrected for v9
* 1.0.7 : corrected for cv
* 1.0.8 : add byable(recall)
* 1.0.9 : remove OS X code
* 1.0.10: guard against zero variance
* 1.0.11: fix SMCL

program define clemio1, rclass byable(recall)
	version 8.2

	syntax varname(ts) [if] [in] [ , Maxlag(integer 12) Trim(real 0.05) graph]  

   	marksample touse
* guard against bozos analyzing a constant
	summ `varlist' if `touse', mean
	if `r(max)' == `r(min)' {
		di as err _n "Error: variable `varlist' has no variance."
		exit 198
	}
			/* get time variables; permit onepanel */
*	_ts timevar, sort
    _ts timevar panelvar if `touse', sort onepanel
	markout `touse' `timevar'
	tsreport if `touse', report
	if r(N_gaps) {
		di in red "sample may not contain gaps"
		exit
	}
	qui tsset
	local rts = r(tsfmt)
	tempvar count samp sampn dvar du1 dtb1 mint t 
	if `maxlag' < 1 {
		di in r _n "Error: maxlag must be positive."
		exit 198
		}
	local kmax `maxlag'
	g `t' = _n
	qui	gen `count' = sum(`touse')
	qui gen `samp' = `touse'
	local nobs = `count'[_N]
	local ntrim=int(`trim'*`nobs'+0.49)
	qui replace `samp' = 0  if `count' <= `ntrim' | `count' > `nobs'-`ntrim'
	qui gen `dvar' = D.`varlist' if `touse'
	local tmin 10^99
* pick up level from system setting
	local lev `=c(level)'
	scalar _cv = (100 - `lev')/100
	qui{
		gen `du1' = .
		gen `dtb1' = .
		gen `sampn' = _n if `samp'==1
*		sum `sampn', meanonly
* onepanel per zandrews
		sum `count' if `samp', meanonly
		if "`graph'" ~= "" gen `mint' = .
		}
	local first = r(min)
	local last = r(max)
	local newnobs = `last' - `first' + 1
	forv i = `first'/`last' {
		qui {
*			replace `du1' = (_n > `i')
*			replace `dtb1' = (_n == `i' + 1)
* onepanel
			replace `du1' = (`count' > `i')
			replace `dtb1' = (`count' == `i' + 1)
			regress `varlist' L.`varlist' `dtb1' `du1'  L.`dvar' if `samp'
			}
			local tdu = (_b[L.`varlist']-1.0) / _se[L.`varlist']
*			if "`graph'" ~= "" qui replace `mint' = `tdu' in `i'/`i'
			if "`graph'" ~= "" qui replace `mint' = `tdu' if `count'==`i'
			if `tdu' < `tmin' {
				local tmin = `tdu'
				local bobsmin1 = `i'
				su `t' if `count'==`i', meanonly
				local minobs = r(mean)
					}
		}
	local topt = `tmin'
	local Tb1 = `bobsmin1'
	qui {
*		replace `du1' = (_n > `Tb1')
*		replace `dtb1' = (_n == `Tb1' + 1)
* onepanel
		replace `du1' = (`count' > `Tb1')
		replace `dtb1' = (`count' == `Tb1' + 1)
		}
	local rhs "L.`varlist' `dtb1' `du1'"
	qui regress `varlist' `rhs' L(1/`kmax').`dvar' if `touse'
	forv i = `kmax'(-1)1 {
		forv ii = `i'/`kmax' {
			if `ii' == `i' {
				 qui test L`ii'.`dvar'
				}
			else {
				 qui test L`ii'.`dvar',accum
				}
			}
		local fset`i' = r(p)
		}

	forv i = `kmax'(-1)1 {
		qui {
			regress `varlist' `rhs' L(1/`i').`dvar' if `touse'
			test L`i'.`dvar'
			}
		local find`i' = r(p)
		}
		
	local kopt 0
	forv i = `kmax'(-1)1 {
		if (`fset`i'' < _cv | `find`i'' < _cv) {
			local kopt `i'
			continue, break
			}
	}

	if `kopt' == 0 {
		qui regress `varlist' `rhs' if `touse'
		}
	else {
		qui regress `varlist' `rhs' L(1/`kopt').`dvar' if `touse'
		}
	local en e(df_r)	
	return scalar effN = `newnobs'
	return scalar kopt = `kopt'
*	return scalar Tb1 = `timevar'[`Tb1']
	return scalar Tb1 = `timevar'[`minobs']
	return scalar coef1 = _b[`du1']
	return scalar tstv1 = _b[`du1'] / _se[`du1']
	return scalar coef2 = _b[_cons]
	return scalar rho   = _b[L.`varlist'] - 1.0	
	return scalar tst   = return(rho) / _se[L.`varlist']	
	local pu1 = 2*ttail(`en',abs(return(tstv1)))
	local ne = char(241)+char(233)
// not needed
//	if "$S_OS" == "MacOSX" {
//		local ne = char(150)+char(142)
//		}
	di in gr _n "Clemente-Monta{c n~}{c e'}s-Reyes unit-root test with single mean shift, IO model"
	di in ye _n "`varlist'" in gr "    T =" %5.0f return(effN)  _col(25) " optimal breakpoint : " in ye `rts' return(Tb1) 
	di in gr _n  "AR(" in ye %2.0f return(kopt) in gr ")" _col(22) "du1" _col(37) "(rho - 1)" _col(51) "const"  
	di as text "{hline 73}" 
	di in gr "Coefficient: " in ye _col(17) %12.5f return(coef1) _col(32) %12.5f return(rho) _col(48)  /*
	*/  %10.5f return(coef2)
	di in gr "t-statistic: " in ye _col(20) %9.3f return(tstv1)  _col(35) %9.3f return(tst) _col(48) %9.3f  
	di in gr "P-value:" _col(20) %9.3f `pu1' _col(35) "   -4.270  (5% crit. value)"
* CV from Perron-Vogelsang JBES 1992 Table 4 for T=150

* graph option
if "`graph'" ~= "" {
	label var `dvar' "D.`varlist'"
	label var `mint' "breakpoint t-statistic"
	local minx = return(Tb1)
	local minp = string(return(Tb1),"`rts'")
	tsline `mint' if `mint'<., ti("Breakpoint t-statistic: min at `minp'") xline(`minx') nodraw name(mint,replace)
	tsline `dvar' if `mint'<., ti("D.`varlist'") nodraw xline(`minx') name(ddv,replace)
	graph combine ddv mint, col(1) ti("Clemente-Monta{c n~}{c e'}s-Reyes single IO test for unit root") ///
		subti("in series: `varlist'")
}
	end
	exit
