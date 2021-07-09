*! version 1.0.10   31jul2015   C F Baum
*  from RATS procedure clemao2.src
* 1.0.1 : mod to version 8.2, fix trim option
* 1.0.2 : add graph option
* 1.0.3 : samp correction
* 1.0.4 : enable onepanel
* 1.0.5 : correct breakpoint timing
* 1.0.6 : corrected for v9
* 1.0.7 : corrrected for cv
* 1.0.8 : add byable(recall)
* 1.0.9 : remove OSX code
* 1.0.10: guard against zero variance
* 1.0.11: fix SMCL

program define clemao2, rclass byable(recall)
	version 8.2

	syntax varname(ts) [if] [in] [ , Maxlag(integer 12) Trim(real 0.05) graph]  

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
	tempvar count samp dvar du1 dtb1 du2 dtb2 ytilde t 
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
		gen `du2' = .
		gen `dtb1' = .
		gen `dtb2' = .
*		gen `sampn' = _n if `samp'==1
*		sum `sampn', meanonly
* onepanel per zandrews
		sum `count' if `samp', meanonly
		}
	local first = r(min)
	local last = r(max)
	local last2 = `last'-2
	local newnobs = `last' - `first' + 1
	forv i = `first'/`last2' {
		qui {
*			replace `du1' = (_n > `i')
*			replace `dtb1' = (_n == `i' + 1)
* onepanel
			replace `du1' = (`count' > `i')
			replace `dtb1' = (`count' == `i' + 1)
			}
			local ip2 = `i' + 2
			forv j = `ip2'/`last' {
				qui {
*					replace `du2' = (_n > `j')
*					replace `dtb2' = (_n == `j' + 1)
* onepanel
					replace `du2' = (`count' > `j')
					replace `dtb2' = (`count' == `j' + 1)
					regress `varlist' `du1' `du2' if `samp'
					capt drop `ytilde'
					predict double `ytilde' if e(sample), r
					regress `ytilde' L.`ytilde' L.`dtb1' L.`dtb2' LD.`ytilde', noc
					}
				local tdu = (_b[L.`ytilde'] - 1.0) / _se[L.`ytilde']
				if `tdu' < `tmin' {
					local tmin = `tdu'
					local bobsmin1 = `i'
					local bobsmin2 = `j'
					su `t' if `count' == `i', meanonly
					local minobs1 = r(mean)
					su `t' if `count' == `j', meanonly
					local minobs2 = r(mean)
					}
				}
		}

	local topt = `tmin'
	local Tb1 = `bobsmin1'
	local Tb2 = `bobsmin2'
	qui {
*		replace `du1' = (_n > `Tb1')
*		replace `du2' = (_n > `Tb2')
*		replace `dtb1' = (_n == `Tb1' + 1)
*		replace `dtb2' = (_n == `Tb2' + 1)
* onepanel
		replace `du1' = (`count' > `Tb1')
		replace `du2' = (`count' > `Tb2')
		replace `dtb1' = (`count' == `Tb1' + 1)
		replace `dtb2' = (`count' == `Tb2' + 1)
		}
	qui regress `varlist' `du1' `du2' if `touse'
	drop `ytilde'
	qui predict double `ytilde' if e(sample), r
	return scalar coef1 = _b[`du1']
	return scalar tstv1 = _b[`du1'] / _se[`du1']
	return scalar coef2 = _b[`du2']
	return scalar tstv2 = _b[`du2'] / _se[`du2']
	return scalar coef3 = _b[_cons]

	qui regress `ytilde' L.`ytilde' L(1/`kmax').`dtb1' L(1/`kmax').`dtb2' L(1/`kmax')D.`ytilde' if `touse', noc
	
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
			qui test L`ii'.`dtb2',accum
			}
		local fset`i' = r(p)
		}

	forv i = `kmax'(-1)1 {
		qui {
			regress `ytilde' L.`ytilde' L(1/`i').`dtb1' L(1/`i').`dtb2' L(1/`i')D.`ytilde' if `touse'
			test L`i'D.`ytilde'
			test L`i'.`dtb1',accum
			test L`i'.`dtb2',accum
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
		qui regress `ytilde' L.`ytilde' L.`dtb1' L.`dtb2' if `touse', noc
		}
	else {
		qui regress `ytilde' L.`ytilde' L(1/`kopt').`dtb1' L(1/`kopt').`dtb2' L(1/`kopt')D.`ytilde' if `touse', noc
		}
	local en e(df_r)		
	return scalar effN = `newnobs'
	return scalar kopt = `kopt'
*	return scalar Tb1 = `timevar'[`Tb1']
*	return scalar Tb2 = `timevar'[`Tb2']
	return scalar Tb1 = `timevar'[`minobs1']
	return scalar Tb2 = `timevar'[`minobs2']
	return scalar rho   = _b[L.`ytilde'] - 1.0	
	return scalar tst   = return(rho) / _se[L.`ytilde']	
	local pu1 = 2*ttail(`en',abs(return(tstv1)))
	local pu2 = 2*ttail(`en',abs(return(tstv2)))	
	local ne = char(241)+char(233)
// not needed for OS X
//	if "$S_OS" == "MacOSX" {
//		local ne = char(150)+char(142)
//		}
	di in gr _n "Clemente-Monta{c n~}{c e'}s-Reyes unit-root test with double mean shifts, AO model"
	di in ye _n "`varlist'" in gr "    T =" %5.0f return(effN)  _col(25) " optimal breakpoints : " in ye `rts' return(Tb1) /*
	*/ " , " `rts' return(Tb2) 
	di in gr _n  "AR(" in ye %2.0f return(kopt) in gr ")" _col(22) "du1" _col(37) "du2" _col(49) "(rho - 1)" _col(65) "const"
	di as text "{hline 73}" 
	di in gr "Coefficients: " in ye _col(17) %12.5f return(coef1) _col(32) %12.5f return(coef2) _col(45) %12.5f return(rho) /*
	*/ _col(63) %10.5f return(coef3)
	di in gr "t-statistics: " in ye _col(20) %9.3f return(tstv1)  _col(35) %9.3f return(tstv2) _col(48) %9.3f return(tst) 
	di in gr "P-values: " _col(20) %9.3f `pu1' _col(35) %9.3f `pu2' _col(49) "  -5.490 (5% crit. value)"

* graph option
if "`graph'" ~= "" {
	label var `dvar' "D.`varlist'"
	local minx1 = return(Tb1)
	local minx2 = return(Tb2)
	local minp1 = string(return(Tb1),"`rts'")
	local minp2 = string(return(Tb2),"`rts'")
	tsline `varlist' if `samp', ti("Test on `varlist': breaks at `minp1',`minp2'") xline(`minx1' `minx2') nodraw name(ser,replace)
	tsline `dvar' if `samp', ti("D.`varlist'") nodraw xline(`minx1' `minx2') name(ddv,replace)
	graph combine ser ddv, col(1) ti("Clemente-Monta{c n~}{c e'}s-Reyes double AO test for unit root")
}

	end
	exit
		
