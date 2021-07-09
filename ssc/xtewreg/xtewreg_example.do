clear all
set more off
capture log close

global workfold = "C:\\Users\\robert.parham\\OneDrive\\Documents\Code\\"
cd ${workfold}
adopath + "${workfold}"

sjlog using "output", replace

use "EPW.dta", clear

xtset gvkey

summarize fyear gvkey lever mtb tangib logsales oi

regress lever mtb tangib , vce(cluster gvkey) nocons

xtewreg lever mtb tangib , maxdeg(5) mismeasured(2) nocons

regress lever mtb tangib logsales oi , vce(cluster gvkey) nocons

xtewreg lever mtb tangib logsales oi , maxdeg(5) mismeasured(2) nocons

xtewreg lever mtb tangib logsales oi , maxdeg(8) mismeasured(2) nocons

xtewreg lever mtb tangib logsales oi , maxdeg(5) mismeasured(2) centmom(set) nocons
bootstrap t_mtb=(_b[mtb]/el(e(serr),1,1)) t_tangib=(_b[tangib]/el(e(serr),2,1)) t_logsales=(_b[logsales]/el(e(serr),3,1)) ///
		  t_oi=(_b[oi]/el(e(serr),4,1)) , rep(100) seed(1337) cluster(gvkey) notable: ///
	xtewreg lever mtb tangib logsales oi , maxdeg(5) mismeasured(2) centmom(use) nocons
estat bootstrap, p

sjlog close
