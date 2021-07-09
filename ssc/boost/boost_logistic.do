* A boosted logistic regression example 
* Matthias Schonlau

* copy the plugin boost.dll into a directory of your choosing
* copy the boost.hlp and boost.ado files in one of the ado directories,
* for example c:\ado\personal\boost.ado

* a plugin has to be explicitly loaded (unlike an ado file)
* "capture" means that if it's loaded already this line won't give an error

*capture program drop boost_plugin
*program boost_plugin, plugin using(".\boost.dll")


capture log close
log using "boost_logistic" , replace text

clear 
set scheme        s1color    
set copycolor     asis       
set memory 100m
set more off
set seed 12345678
set matsize 800
set obs 4000    /*generate  4000 observations  */
global max=50  /* generate 50 variables */
global trainn=2000    /* corresponds to trainfraction=0.5 */

********************************************************************************
* generate some data

forvalues i= 1 2 to $max {
	gen x`i'= uniform()
}
gen u=uniform()


gen z0=0
gen denom=0
forvalues j= 1 2 to 10 {
      replace denom=0
	forvalues i= 1 2 to 3 {
		qui replace  denom= denom +   (x`i'- `j'/10)^2 
	}
      replace z0=z0+ 1/(denom + .1 )
	replace z0=z0-10 if x4>.95
}
sum z0, detail 
replace z0=round(z0-35)

local SNR=1  /* signal to noise ratio*/
qui sum z0, detail
local sigma = sqrt(r(Var)/`SNR')
di "sigma= `sigma' "
replace z0=z0+ uniform() * `sigma'

gen z=exp(z0)/(1+exp(z0))
gen y=0
replace y=1 if u<z
tab y

********************************************************************************
* classification for the test data
tab y if _n>$trainn

********************************************************************************
* logistic regression
capture drop logit_pred logit_pred2
logistic  y x1-x$max in 1/$trainn
predict logit_pred 
gen logit_pred2=round( logit_pred)  
tab logit_pred2 y  if _n > $trainn, cell


********************************************************************************
* stepwise logistic regression
capture drop swlogit_pred swlogit_pred2
sw logistic y x1-x$max in 1/$trainn , pr(0.15)  
* stepwise regression does not improve predictive accuracy
predict swlogit_pred 
gen swlogit_pred2=round( swlogit_pred)  
tab swlogit_pred2 y  if _n > $trainn, cell

********************************************************************************

gen Rsquared=.
gen bestiter=.
gen myinter=.
local i=0
local maxiter=500
profiler on
local tempiter=`maxiter'
foreach inter of numlist 1/6 8 10 15 20 {
	local i=`i'+1
      replace myinter= `inter' in `i'
	boost y x1-x$max , dist(logistic) train(0.5) maxiter(`tempiter') bag(0.5) interaction(`inter') shrink(0.1) 
	local maxiter=e(bestiter) 
	replace bestiter=e(bestiter) in `i' 
	replace Rsquared=e(test_R2) in `i'
	* as the number of interactions increase the best number of iterations will decrease
	* to be safe I am allowing an extra 20% of iterations
	* when the number of interactions is large this can save a lot of time
	local tempiter = round( e(bestiter) * 1.2 )
}
profiler off 
profiler report
rename myinter interaction
twoway connected Rsquared inter, xtitle("Number of interactions")  
graph save logistic_Rsquared, replace 

********************************************************************************
* compare the R^2 of boosted and linear models 
* the training R^2 for the boosted is obtained from a linear logistic regression 

boost y x1-x$max , dist(logistic) train(0.5) maxiter(500) bag(0.5) interaction(5) shrink(0.1) pred("boost_pred") influence 
gen boost_pred2=round(boost_pred) 

********************************************************************************
* influence plot
matrix influence = e(influence)
svmat influence
gen id=_n
replace id=. if missing(influence)
#delimit ;
label define idlabel  
1 "1" 2 "2" 3 "3" 4 "4" 5 "." 6 "." 7 "." 8 "." 9 "."
 11 "." 12 "." 13 "." 14 "." 15 "." 16 "." 17 "." 18 "." 19 "."
20 "20"  21 "." 22 "." 23 "." 24 "." 25 "." 26 "." 27 "." 28 "." 29 "."
30 "30"  31 "." 32 "." 33 "." 34 "." 35 "." 36 "." 37 "." 38 "." 39 "."
40 "40"  41 "." 42 "." 43 "." 44 "." 45 "." 46 "." 47 "." 48 "." 49 "."
50 "50"  51 "." 52 "." 53 "." 54 "." 55 "." 56 "." 57 "." 58 "." 59 "."
;
#delimit cr;
label values id  idlabel
graph bar (mean) influence, over(id) ytitle(Percentage Influence)
graph save logistic_influence, replace

********************************************************************************
tab  boost_pred2 y if _n>$trainn, cell
tab logit_pred2 y  if _n > $trainn, cell
tab swlogit_pred2 y  if _n > $trainn, cell

********************************************************************************
* Calibration plot
* scatter plot of predicted versus actual values of y
* a straight line would indicate a perfect fit
gen straight=.
replace straight=y
twoway  (lowess y  logit_pred  in 1/$trainn, bwidth(0.2) clpattern(dot))        (lowess y boost_pred in 2001/4000 , bwidth(0.2) clpattern(dash))    (lfit straight y)  , xtitle("Fitted Values") legend(label(1 "Logistic Regression") label(2 "Boosting") label(3 "Fitted Values=Actual Values") ) xsize(4) ysize(4)
twoway  (lowess y  logit_pred  in 2001/4000, bwidth(0.2) clpattern(dot))        (lowess y boost_pred in 2001/4000 , bwidth(0.2) clpattern(dash))    (lfit straight y)  , xtitle("Fitted Values") legend(label(1 "Logistic Regression") label(2 "Boosting") label(3 "Fitted Values=Actual Values") ) xsize(4) ysize(4)
graph save logistic_calibration, replace
********************************************************************************
* Visualization - Boxplots
gen group= round(x4*20-.5) /20 
graph box  boost_pred in 1/$trainn    , over(group) 
graph save logistic_boxplots, replace 

* alternative plot (not shown in paper)
twoway lowess boost_pred x4 in 1/$trainn, bwidth(0.1) ylabel(0.2 0.4 to 1.0)

log close

