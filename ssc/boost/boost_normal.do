* A boosted linear regression example 
* Matthias Schonlau

* copy the plugin boost.dll into a directory of your choosing
* copy the boost.hlp and boost.ado files in one of the ado directories,
* for example c:\ado\personal\boost.ado

* a plugin has to be explicitly loaded (unlike an ado file)
* "capture" means that if the boost plugin is not yet loaded  
* this line won't give an error
* you can specify a different path for the boost.dll

* capture program drop boost_plugin
* cap program drop boost_plugin
* program boost_plugin, plugin using(".\boost64.dll")

clear 
set more off
set scheme        s1color    
set copycolor     asis   

log using "boost_normal" , replace text


* generate some data
set obs 2000
set seed 345678

gen x1= uniform()
gen x2= uniform()
gen x3= uniform()
gen x4= uniform() 
local SNR=4  /* signal to noise ratio*/
gen y= 30 *(x1-0.5)^2 + 2*(x2^(-.5)) +x3
qui sum y
local sigma = sqrt(r(Var)/`SNR')
replace y=y+ uniform() * `sigma'


*scatter plots
scatter y x1 
graph save "x1", replace
scatter y x2 
graph save "x2",replace
scatter y x3 
graph save "x3",replace
scatter y x4 
graph save "x4",replace
graph combine x1.gph x2.gph x3.gph x4.gph
graph save "normal_scatter", replace 
erase "x1.gph" 
erase "x2.gph" 
erase "x3.gph" 
erase "x4.gph"




* Explore various numbers of interactions 
gen bestiter=.
gen Rsquared=.
gen myinter=.
local i=0
foreach inter of numlist 1/5  {
	local i=`i'+1
        replace myinter= `inter' in `i'
	boost y x1 x2 x3 x4, distribution(normal) train(0.5) bag(0.5) maxiter(4000) interaction(`inter') shrink(0.01)  seed(1)
	replace Rsquared=e(test_R2) in `i'
	replace bestiter=e(bestiter) in `i'

}
rename myinter interaction
label var Rsquared " R squared (on a test data set)"
twoway connected Rsquared inter, xtitle("Number of interactions")  
graph save "normal_Rsquared", replace


***************************************************************************
profiler on
boost y x1 x2 x3 x4, distribution(normal) train(0.5) bag(0.5) maxiter(4000) interaction(1) shrink(0.01) pred("boost_pred") influence  seed(1)
global trainn=e(trainn)
profiler off 
profiler report 


***************************************************************************
*compare the R^2 of boosted (with appropriate number of iterations ) and linear models 
regress y x1 x2 x3 x4 in 1/$trainn
predict regress_pred

* compute Rsquared on test data - lin regression
gen regress_eps=y-regress_pred 
gen regress_eps2= regress_eps*regress_eps 
replace regress_eps2=0 if _n<=$trainn  
gen regress_ss=sum(regress_eps2)
local mse=regress_ss[_N] / (_N-$trainn)
sum y if _n>$trainn
local var=r(Var)
local regress_r2= (`var'-`mse')/`var'
di "Linear regression : mse=" `mse' " var=" `var'  " regress r2="  `regress_r2'

* compute Rsquared on test data - boosting
* This yields the same number as e(test_R2) after the boost command
gen boost_eps=y-boost_pred 
gen boost_eps2= boost_eps*boost_eps 
replace boost_eps2=0 if _n<=$trainn  
gen boost_ss=sum(boost_eps2)
local mse=boost_ss[_N] / (_N-$trainn)
sum y if _n>$trainn
local var=r(Var)
local boost_r2= (`var'-`mse')/`var'
di "Boosting:  mse=" `mse' " var=" `var'  " boost r2="  `boost_r2'



***************************************************************************
* Calibration plot
* scatter plot of predicted versus actual values of y
* a straight line would indicate a perfect fit
drop if _n>$trainn
capture drop straight 
capture drop pred
capture drop method 
local count=_N
preserve
expand 2
gen pred=regress_pred
replace pred=boost_pred if _n>`count'
gen method="Linear Regression"
replace method="Boosting" if _n>`count'
label var method "Regression Method"
gen straight=.
replace straight=y

twoway (scatter  pred  y) (lfit straight y) , by(method, legend(off))  xtitle("Actual y Values")  ytitle("Fitted y Values") xsize(8) ysize(4)  ylab(0 10 20 to 50) xlab(0 10 20 to 50) 
graph save "normal_calibration" , replace 
restore
 

***************************************************************************
* visualize the effect of x2 on y 
* the following computations assume that trainn=1000
drop if _n>1000
set obs 1400
replace x1=0.5 if _n>1000
replace x2=0.5 if _n>1000
replace x3=0.5 if _n>1000
replace x4=0.5 if _n>1000
replace x1= (_n-1000)/100 if _n>1000 & _n<=1100
replace x2= (_n-1100)/100 if _n>1100 & _n<=1200
replace x3= (_n-1200)/100 if _n>1200 & _n<=1300
replace x4= (_n-1300)/100 if _n>1300 & _n<=1400
capture drop pred 
boost y x1 x2 x3 x4 in 1/1000 , distribution(normal) maxiter(4000) bag(0.5)  interaction(1) shrink(0.01) pred("pred")  
line pred x1 if _n>1000 & _n<=1100, ylabel(0 5 10 to 25) ytitle("Predicted Value")
graph save "x1_pred", replace
line pred x2 if _n>1100 & _n<=1200, ylabel(0 5 10 to 25) ytitle("Predicted Value")
graph save "x2_pred", replace 
line pred x3 if _n>1200 & _n<=1300, ylabel(0 5 10 to 25) ytitle("Predicted Value")
graph save "x3_pred", replace 
line pred x4 if _n>1300 & _n<=1400, ylabel(0 5 10 to 25) ytitle("Predicted Value")
graph save "x4_pred", replace 

graph combine  x1_pred.gph x2_pred.gph x3_pred.gph x4_pred.gph
graph save "normal_visualize", replace 
erase "x1_pred.gph" 
erase "x2_pred.gph" 
erase "x3_pred.gph" 
erase "x4_pred.gph"
***************************************************************************
log close
