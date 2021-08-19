/* WORKING EXAMPLE version 1.1 */

* Load and prepare data
webuse nlswork, clear
keep if inlist(year, 69,71,73,75,77)
gen pre_2=year==69
gen pre_1=year==71
gen post_1=year==75
gen post_2=year==77


* Examples of specifications comparison

* Periods can be included in the preferred way in window()
eventcoefplot ln_wage, window(pre_2 pre_1 post_1 post_2) noconstant legend(off) ///
controls(race birth_yr collgrad south)  

* Command is a first-time-users friendly option to show in the console a draft of the regression being run. Signalling the event(), adds a zero estimate before the event (not needed depending on the lags)
eventcoefplot ln_wage, window(pre_2 pre_1 post_1 post_2) noconstant legend(off) command ///
controls(race birth_yr collgrad south) event(post_1)  xline(3, lpattern(dash) lcolor(gray))

* adding labels, eventcoepflot automatically uses them for the xlabels
label var pre_2 "-3"
label var pre_1 "-2"
label var post_1 "0"
label var post_2 "1"

* We compare here a second spec with robust S.E.. Gapname changes the name of the zero estimate.
eventcoefplot ln_wage, window(pre_2 pre_1 post_1 post_2) noconstant  event(post_1) gapname(-1)  xline(3, lpattern(dash) lcolor(gray)) command ///
controls1(race birth_yr collgrad south) speccolor1(black) ///
controls2(race birth_yr collgrad south) speccolor2(red) vce2(robust) 

* We compare here a third spec with more FE's. Symbols is a black and white friendly option.
eventcoefplot ln_wage, window(pre_2 pre_1 post_1 post_2) noconstant   event(post_1) gapname(-1)  xline(3, lpattern(dash) lcolor(gray)) command symbols ///
controls1(race birth_yr collgrad south) vce1(robust) ///
controls2(race birth_yr collgrad south) absorb2(idcode)  vce2(robust) ///
controls3(race birth_yr collgrad south) absorb3(idcode occ) vce3(robust) ///
legend(1 "Baseline" 2 "ID FE's" 3 "ID + Occupation FE's")


* Tests

* Tuplestest runs all the tuples of the included controls, separately
eventcoefplot ln_wage, window(pre_2 pre_1 post_1 post_2) noconstant legend(off) event(post_1)  xline(3, lpattern(dash) lcolor(gray)) command ///
controls(age) ///
tuplestest(race birth_yr collgrad south)

* Leaveoneouttest leaves out one of the controls at the time
eventcoefplot ln_wage, window(pre_2 pre_1 post_1 post_2) noconstant legend(off) event(post_1)  xline(3, lpattern(dash) lcolor(gray)) command ///
controls(age) ///
leaveoneouttest(race birth_yr collgrad south)

* Multitest includes one set of controls at the time
global cov1 "race birth_yr"
global cov2 "collgrad south"
eventcoefplot ln_wage, window(pre_2 pre_1 post_1 post_2) noconstant legend(off) event(post_1)  xline(3, lpattern(dash) lcolor(gray)) command ///
controls(age) ///
multitest(cov1 cov2)

* Perturbationtest excludes one sub-sample at the time, based on the levelsof() of the variable. Tests look can be adjusted
eventcoefplot ln_wage, window(pre_2 pre_1 post_1 post_2) noconstant legend(off) event(post_1)  xline(3, lpattern(dash) lcolor(gray)) command ///
controls(age race birth_yr collgrad south) ///
perturbationtest(age) testcicolor(navy) testcoefcolor(black)

* Looking at the Diagnostics Table of the Perturbationtest, we see that the minimum sample drop required to change the significance of estimates is roughly 10% of the sample
eventcoefplot ln_wage, window(pre_2 pre_1 post_1 post_2) noconstant legend(off) event(post_1)  xline(3, lpattern(dash) lcolor(gray)) command ///
controls(age race birth_yr collgrad south) ///
perturbationtest(birth_yr) testcicolor(navy) testcoefcolor(black)


