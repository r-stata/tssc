*! version 1.0.11   31jul2015   C F Baum
*  from RATS procedure clemao1.src and clemao2.ado
* 1.0.1 : correct trim option
* 1.0.2 : add graph option
* 1.0.3 : samp correction
* 1.0.4 : permit onepanel
* 1.0.5 : correct breakpoint timing
* 1.0.6 : hidden option eps
* 1.0.7 : corrected for v9 
* 1.0.8 : corrected for cv
* 1.0.9 : add byable(recall)
* 1.0.10: remove OSX code
* 1.0.11: guard against zero variance
* 1.0.12: fix SMCL

program define clemao1, rclass byable(recall)
	version 8.2

	syntax varname(ts) [if] [in] [ , Maxlag(integer 12) Trim(real 0.05) graph eps]  

   	marksample touse
* guard against bozos analyzing a constant
	summ `varlist' if `touse', mean
	if `r(max)' == `r(min)' {
		di as err _n "Error: variable `varlist' has no variance."
		exit 198
	}
			/* get time variables; enable onepanel */
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
	tempvar count samp dvar du1 dtb1 ytilde mint t
	if `maxlag' < 1 {
		di in r _n "Error: maxlag must be positive."
		exit 198
		}
	local kmax `maxlag'
* ADD
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
	qui {
		gen `du1' = .
		gen `dtb1' = .
*		gen `sampn' = _n if `samp'==1
*		sum `sampn', meanonly
* onepanel per zandrews
		sum `count' if `samp', meanonly
		if "`graph'" ~= "" gen `mint' = .
		}
	local first = r(min)
	local last = r(max)
*   di in r "`first' `last'"
	local newnobs = `last' - `first' + 1
	forv i = `first'/`last' {
		qui {
*			replace `du1' = (_n > `i')
*			replace `dtb1' = (_n == `i' + 1)
* onepanel
			replace `du1' = (`count' > `i')
			replace `dtb1' = (`count' == `i' + 1)
			}
			qui {
				regress `varlist' `du1' if `touse'
				capt drop `ytilde'
				predict double `ytilde' if e(sample), r
				regress `ytilde' L.`ytilde' L.`dtb1' LD.`ytilde', noc
				}
			local tdu = (_b[L.`ytilde']-1.0) / _se[L.`ytilde']
* onepanel	if "`graph'" ~= "" qui replace `mint' = `tdu' in `i'/`i'
			if "`graph'" ~= "" qui replace `mint' = `tdu' if `count'==`i'
			if `tdu' < `tmin' {
				local tmin = `tdu'
				local bobsmin1 = `i'
* ADD
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
	qui regress `varlist' `du1' if `touse'
	drop `ytilde'
	qui predict double `ytilde' if e(sample), r
	return scalar coef1 = _b[`du1']
	return scalar tstv1 = _b[`du1'] / _se[`du1']
	return scalar coef2 = _b[_cons]

	qui regress `ytilde' L.`ytilde' L(1/`kmax').`dtb1' L(1/`kmax')D.`ytilde' if `touse', noc
	
	forv i = `kmax'(-1)1 {
		forv ii = `i'/`kmax' {
			if `ii' == `i' {
				 qui test L`ii'D.`ytilde'
				}
			else {
				 qui test L`ii'D.`ytilde',accum
				}
			}
		forv ii = `i'/`kmax' {
			qui test L`ii'.`dtb1',accum
			}
		local fset`i' = r(p)
		}

	forv i = `kmax'(-1)1 {
		qui {
			regress `ytilde' L.`ytilde' L(1/`i').`dtb1' L(1/`i')D.`ytilde' if `touse'
			test L`i'D.`ytilde'
			test L`i'.`dtb1',accum
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
		qui regress `ytilde' L.`ytilde' L.`dtb1' if `touse', noc
		}
	else {
		qui regress `ytilde' L.`ytilde' L(1/`kopt').`dtb1' L(1/`kopt')D.`ytilde' if `touse', noc
		}
	local en e(df_r)		
	return scalar effN = `newnobs'
	return scalar kopt = `kopt'
* ADD	return scalar Tb1 = `timevar'[`Tb1']
	return scalar Tb1 = `timevar'[`minobs']
	return scalar rho   = _b[L.`ytilde'] - 1.0	
	return scalar tst   = return(rho) / _se[L.`ytilde']	
	local pu1 = 2*ttail(`en',abs(return(tstv1)))	
	local ne = char(241)+char(233)
* NOT NEEDED FOR OS X disable following for eps production
//	if "$S_OS" == "MacOSX" & "`eps'"=="" {
//		local ne = char(150)+char(142)
//		}
	di in gr _n "Clemente-Monta{c n~}{c e'}s-Reyes unit-root test with single mean shift, AO model"
	di in ye _n "`varlist'" in gr "    T =" %5.0f return(effN)  _col(25) " optimal breakpoint : " in ye `rts' return(Tb1) 
	di in gr _n  "AR(" in ye %2.0f return(kopt) in gr ")" _col(22) "du1" _col(37) "(rho - 1)" _col(51) "const"  
	di as text "{hline 73}" 
	di in gr "Coefficient: " in ye _col(17) %12.5f return(coef1) _col(32) %12.5f return(rho) _col(48)  /*
	*/  %10.5f return(coef2)
	di in gr "t-statistic: " in ye _col(20) %9.3f return(tstv1)  _col(35) %9.3f return(tst) _col(48) %9.3f  
	di in gr  "P-value:"_col(20) %9.3f `pu1' _col(35) "   -3.560  (5% crit. value)"
* CV from Perron-Vogelsang JBES 1992 Table 3 for T=150

* graph option
if "`graph'" ~= "" {
	label var `dvar' "D.`varlist'"
	label var `mint' "breakpoint t-statistic"
	local minx = return(Tb1)
	local minp = string(return(Tb1),"`rts'")
	tsline `mint' if `mint'<., ti("Breakpoint t-statistic: min at `minp'") xline(`minx') nodraw name(mint,replace)
	tsline `dvar' if `mint'<., ti("D.`varlist'") nodraw xline(`minx') name(ddv,replace)
	graph combine ddv mint, col(1) ti("Clemente-Monta{c n~}{c e'}s-Reyes single AO test for unit root") ///
		subti("in series: `varlist'")
}

	end
	exit
