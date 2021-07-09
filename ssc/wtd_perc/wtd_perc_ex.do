version 14.0

discard
clear
set more off

* Open example dataset
use wtddat

* Apply the parametric WTD model to obtain estimate of percentile
* after which only 20% of prevalent users will have a subsequent
* prescription redemption

* The Exponential model (a poor fit in this situation)
wtd_perc rx1time, disttype(exp) iadpercentile(0.8)

* The Log-Normal model
wtd_perc rx1time, disttype(lnorm) iadpercentile(0.8)

* And with a Weibull distribution
wtd_perc rx1time, disttype(wei) iadpercentile(0.8)
ereturn list


* Be careful with scaling of time variable:
    gen rx1timedays = rx1time * 365
capture noi wtd_perc rx1timedays, disttype(wei) iadpercentile(0.8)


* Formatted results
wtd_perc rx1time, disttype(wei) iadpercentile(0.8) prevformat("%5.4f") ///
    percformat("%9.3g")


* To get bootstrap confidence intervals we can do the following:

bootstrap logtimeperc = r(logtimeperc), reps(50): ///
    wtd_perc rx1time, disttype(lnorm) iadpercentile(0.8)

* NB: the reported percentile above is on log-scale, so we use eform
* to exponentiate the coefficient:

bootstrap, eform
