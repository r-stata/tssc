*! version 1.0.2     15jul2001     C F Baum
*  Performs multivariate augmented Dickey-Fuller (MADF) test on long format data
*  per L. Sarno and M. Taylor, Economics Letters 60, 131-137 (1998)
*  1.0.2: implement ts operators

program define madfuller, rclass
	version 7.0
	syntax varname(ts) [if] [in] , Lags(numlist int >0) /* [ Trend ]  */

	qui tsset
	local id `r(panelvar)'
	local time `r(timevar)'
   	marksample touse
	markout `touse' `time'
	tsreport if `touse', report panel
	if r(N_gaps) {
		di in red "sample may not contain gaps"
		error 198
	}
	qui xtsum `id' if `touse'
	local N `r(n)'
	local T `r(Tbar)'
	if int(`T')*`N' ~= r(N) {
		di in red "panel must be balanced"
		error 198
		}
	if `T' <= `N' {
		di in red "T must exceed N for sureg"
		error 198
		}
	preserve
	tempvar vvar
	qui gen `vvar' = `varlist' if `touse'
	keep `id' `time' `vvar' `touse'
	tempname Vals 
	qui tab `id' if `touse', matrow(`Vals') 
    local nvals = r(r)
    local i = 1
    while `i' <= `nvals' {
    	local val = `Vals'[`i',1]
    	local vals "`vals' `val'"
    	local i = `i' + 1
    	}
    qui drop if `touse'==0
	qui reshape wide `vvar', i(`time') j(`id')
	di as text _n "Multivariate Augmented Dickey-Fuller test for " as result "`varlist'"
	di as text "with " as result "`T'" as text " observations on "/*
	*/ as result "`N'" as text " cross-sectional units"
	di as text "{hline 59}"
	di as text "       Obs    Lags        MADF      Approx 5% CV"
	di as text "{hline 59}" 
	foreach k of local lags {
		local rhs ""	
	foreach i of local vals {
		local rhs "`rhs' (`vvar'`i' L(1/`k').`vvar'`i')"
		}
	qui tsset `time'
	qui sureg "`rhs'", not
	local kn `e(N)'
	scalar fpc = 11.12 + 720.82/`kn' - 15646.71 / (`kn'*`kn') + 246820.8 / (`kn'*`kn'*`kn')
	local j 0
	foreach i of local vals {
		local j = `j' + 1
		local test`j' ""
		local lm1 = `k' - 1
		forv m= 1/`lm1' {
			local test`j' "`test`j'' [`vvar'`i']L`m'.`vvar'`i' +"
		}
		local test`j' "`test`j'' [`vvar'`i']L`k'.`vvar'`i'== 1, not"
		if `j'>1 { local test`j' "`test`j'' accum" }
		qui test `test`j''
		}
		qui test
		di as result _col(6) %5.0f `kn' _col(17) %2.0f `k' _col(22) %9.3f `r(chi2)' /*
		*/ _col(39) %7.3f fpc
	}
	di as text "{hline 59}" 
	di as text "H0: all `N' timeseries in the panel are I(1) processes" 
	restore
end
exit

