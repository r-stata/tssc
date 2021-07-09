clear all
set more off

*example 1 - Fit a Cox proportional hazards model

use va, clear
igencox status type1 type2 type3

*Replay results with 90% confidence intervals
igencox, level(90)


*example 2 - Fit a proportional odds model
sysuse cancer, clear

*Map values for drug into 0 for placebo and 1 for nonplacebo
replace drug = drug == 2 | drug == 3

*Declare data to be survival-time data
stset studytime, failure(died)

*Fit a proportional odds model
igencox drug age, transform(log)

*Fit a proportional odds model
igencox drug age, transform(log)

*Fit a Box-Cox model with rho = 0.5
igencox drug age, transform(boxcox 0.5)


*example 3 - Compute covariate-adjusted survivor function and its standard error
use va, clear
igencox status type1 type2 type3, trans(log 1) baseq(bq) savesigma(mysigma)

*Predict survivor function and its standard errors at specified values of the covariates
predict surv, survival se(sesurv) at(status=.4 type1=0 type2=0 type3=0)

*Calculate the 95% pointwise confidence intervals of the survivor function
gen tmp = 1.96*sesurv / (surv*log(surv))
gen lb = surv^exp(-tmp)
gen ub = surv^exp(tmp)
label var ub "95 % confidence interval"
label var lb "95 % confidence interval"

*Plot the results
gsort _t surv
twoway line surv lb ub _t, connect(J J J) lcolor(black black black) ///
	lpattern(solid dash_dot dash_dot) legend(order(1 2)) ///
	ylabel(,angle(0) format("%2.1f"))

*Clean up
erase mysigma
