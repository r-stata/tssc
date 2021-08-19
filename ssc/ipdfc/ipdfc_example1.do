* Example 1. Guyot's example
cap erase temp0.dta
cap erase temp1.dta

* risk table available
import delimited using "Head_and_neck_arm0.txt", clear
ipdfc_update, surv(s) tstart(ts) trisk(trisk) nrisk(nrisk) isotonic generate(t_ipd event_ipd) saving(temp0)

import delimited using "Head_and_neck_arm1.txt", clear
ipdfc_update, surv(s) tstart(ts) trisk(trisk) nrisk(nrisk) isotonic generate(t_ipd event_ipd) saving(temp1)

 use temp0, clear
 gen byte arm = 0
 append using temp1
 replace arm = 1 if missing(arm)
 stset t_ipd, failure(event_ipd)
 label define ARM 0 "Radiotherapy" 1 "Radiotherapy plus Cetuximab"
 label values arm ARM    
 label data "Example1, reconstructed IPD"
 save "example1.dta", replace

stcox arm

* median survival time with 95% confidence interval
stci, by(arm) median

sts graph, by(arm) title("") xlabel(0(10)70) ylabel(0(0.2)1) ///
risktable(0(10)50, order(2 "Radiotherapy" 1 "Radiotherapy plus" bottom(msize(5)) )) ///
    xtitle("Months") l2title("Locoregional Control") ///
	scheme(s2color) graphregion(fcolor(white)) ///
	plot1opts(lpattern(solid) lcolor(gs12)) ///
	plot2opts(lpattern(solid) lcolor(black)) ///
	text(-0.38 -9.4 "Cetuximab") ///
	legend(off) ///
	title("With risk table") ///
	text (0.52 53 "Radiotherapy plus Cetuximab")  text(0.20 60 "Radiotherapy") ///
	saving("km_guyot2012.gph",replace)
graph export "km_guyot2012.pdf", replace


* risk table not available, only the number of participant is known at the time origin
import delimited using "Head_and_neck_arm0_no_risk_table.txt", clear
ipdfc_update, surv(s) tstart(ts) trisk(trisk) nrisk(nrisk) isotonic generate(t_ipd event_ipd) saving(temp0, replace)

import delimited using "Head_and_neck_arm1_no_risk_table.txt", clear
ipdfc_update, surv(s) tstart(ts) trisk(trisk) nrisk(nrisk) isotonic generate(t_ipd event_ipd) saving(temp1,replace)

use temp0, clear
gen byte arm = 0
append using temp1
replace arm = 1 if missing(arm)
stset t_ipd, failure(event_ipd)
label define ARM 0 "Radiotherapy" 1 "Radiotherapy plus Cetuximab"
label values arm ARM    
label data "Example1, reconstructed IPD, no risk table"
save "example1_no_risk_table.dta", replace

stcox arm

sts graph, by(arm) title("") xlabel(0(10)70) ylabel(0(0.2)1) ///
risktable(0(10)50, order(2 "Radiotherapy" 1 "Radiotherapy plus" bottom(msize(5)) )) ///
    xtitle("Months") l2title("Locoregional Control") ///
	scheme(s2color) graphregion(fcolor(white)) ///
	plot1opts(lpattern(solid) lcolor(gs12)) ///
	plot2opts(lpattern(solid) lcolor(black)) ///
	text(-0.38 -9.4 "Cetuximab") ///
	legend(off) ///
	title("Without risk table") ///
	text (0.52 53 "Radiotherapy plus Cetuximab")  text(0.20 60 "Radiotherapy") ///
	saving("km_guyot2012_no_risk_table.gph",replace)
graph export "km_guyot2012_no_risk_table.pdf", replace

graph combine km_guyot2012 km_guyot2012_no_risk_table
