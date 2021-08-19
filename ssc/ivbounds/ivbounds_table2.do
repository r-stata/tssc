
clear 
clear mata
clear matrix
capture log close
capture drop _all
capture program drop _all
macro drop _all
set mem 200m
set matsize 3200
set seed 12345

/*
* Set here WHO is running the code
*global run "Denni" // Denni
global run "Denni"

*** For Denni

if "$run" == "Denni" {
* 1. load raw data

* 2. main path
global path 		"D:\Dropbox\1. Research\Research Lina\6. STATA command\ivbounds" // office
*global path			"C:\Users\denni\Dropbox\1. Research\Research Lina\6. STATA command\ivbounds" // home

* 3. input of the analysis
global in 		""D:\Dropbox\1. Research\Research Lina\6. STATA command\ivbounds"" // office
*global in		""C:\Users\denni\Dropbox\1. Research\Research Lina\6. STATA command\ivbounds"" // home

* 4. output of the analysis
global out 		""D:\Dropbox\1. Research\Research Lina\6. STATA command\ivbounds\output"" // office
*global out		""C:\Users\denni\Dropbox\1. Research\Research Lina\6. STATA command\ivbounds\output"" // home
}

*/

log using "table2_21JUN", replace

********************************************************************************
********************************************************************************
********************************************************************************
********************************************************************************
********************************************************************************
********************************************************************************

*** Load ura.dta. This has a continuous output variable, a binary treatment, 
*** a binary instrument, and a bunch of covariates.

clear all
// cd $in
use ivbounds_dataset, clear

*** Define global for covariates

global cov	"income age age2 marriage family"



********************************************************************************
********************************************************************************
********************************************************************************
*** Binary IV
********************************************************************************
********************************************************************************
********************************************************************************

* Strategy 1

ivbounds Y $cov, treat(T) iv(Z) strategy(1) order(1) seed(123)


* Strategy 2

ivbounds Y $cov, treat(T) iv(Z) strategy(2) order(1) seed(123)


********************************************************************************
*** Strategy 3
********************************************************************************


* Strategy 3

*only false negative
ivbounds Y $cov, treat(T) iv(Z) strategy(3) seed(123) lower(0.66) upper(0.83) // wn=0.17, lower(max{0, 1-2*wn}) upper(1-wn)

*only false positive
ivbounds Y $cov, treat(T) iv(Z) strategy(3) seed(123) lower(0) upper(0.80) // wp=0.10, lower(0) upper(1-2*wp)

*approx. false negative and false positive
ivbounds Y $cov, treat(T) iv(Z) strategy(3) seed(123) lower(0.73) upper(0.80) // wn=0.17 & wp=0.10, lower(1-(wn+wp)) upper(1-2*wp)

*exact false negative and false positive
ivbounds Y $cov, treat(T) iv(Z) strategy(3) seed(123) lower(0.73) upper(0.73)



********************************************************************************
********************************************************************************
********************************************************************************
*** Discrete IV
********************************************************************************
********************************************************************************
********************************************************************************

gen true_age = age+25

gen exposure = 10 if true_age>=35
replace exposure = 9 if true_age==34
replace exposure = 8 if true_age==33
replace exposure = 7 if true_age==32
replace exposure = 6 if true_age==31
replace exposure = 5 if true_age==30
replace exposure = 4 if true_age==29
replace exposure = 3 if true_age==28
replace exposure = 2 if true_age==27
replace exposure = 1 if true_age==26
replace exposure = 0 if true_age==25

*gen Z2 = Z*exp
*lab var Z2 "Z*exp"
*tab Z2,gen(exposure)

gen Z2=0 // I'm young and not eligible.
replace Z2=1 if (Z==1 & exposure<10) | (Z==0 & exposure==10) // I'm young and eligible or I'm old and not eligible
replace Z2=2 if (Z==1 & exposure==10) // I'm old and eligible



********************************************************************************
*** Strategy 1 & 2
********************************************************************************

* Strategy 1

ivbounds Y $cov, treat(T) iv(Z2) strategy(1) strata(3) order(1) seed(123)


* Strategy 2

ivbounds Y $cov, treat(T) iv(Z2) strategy(2) strata(3)  order(1) seed(123)



********************************************************************************
*** Strategy 3
********************************************************************************

* Strategy 3

*only false negative
ivbounds Y $cov, treat(T) iv(Z2) strategy(3) strata(3) seed(123) lower(0.66) upper(0.83) // wn=0.17, lower(max{0, 1-2*wn}) upper(1-wn)

*only false positive
ivbounds Y $cov, treat(T) iv(Z2) strategy(3) strata(3) seed(123) lower(0) upper(0.80) // wp=0.10, lower(0) upper(1-2*wp)

*approx. false negative and false positive
ivbounds Y $cov, treat(T) iv(Z2) strategy(3) strata(3) seed(123) lower(0.73) upper(0.80) // wn=0.17 & wp=0.10, lower(1-(wn+wp)) upper(1-2*wp)

*exact false negative and false positive
ivbounds Y $cov, treat(T) iv(Z2) strategy(3) strata(3) seed(123) lower(0.73) upper(0.73)




log close
