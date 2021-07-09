discard

**********************************************************************************
* Open the example dataset (discrete time), ordinary WTD analysis with event dates
**********************************************************************************

use wtddat_dates, clear
hist rx1time /* WTD analysis only works, when the histogram
                looks like this */

wtdttt rx1time, disttype(lnorm) start(1jan2014) end(31dec2014)


**********************************************************************************
* Open the example dataset (continuous time), reverse WTD analysis with covariates
**********************************************************************************

use wtddat_covar, clear

* Apply the parametric WTD model to obtain estimate of percentile
* after which only 20% of prevalent users will have a subsequent
* prescription redemption

* The Exponential model (a poor fit in this situation)
* Note that this is an example with continuous time and hence we need to add the
* option -conttime- and -start- and -end- are numbers and not dates.
wtdttt last_rxtime, disttype(exp) start(0) end(1) conttime reverse

* The Log-Normal model
wtdttt last_rxtime, disttype(lnorm) start(0) end(1) conttime reverse

* Assess fit of Log-Normal model - fits well
wtdtttdiag last_rxtime

* And with a Weibull distribution
wtdttt last_rxtime, disttype(wei) start(0) end(1) conttime reverse
ereturn list

* Use covariate in all three parameter equations
wtdttt last_rxtime, disttype(lnorm) start(0) end(1) conttime reverse allcovar(i.packsize)

* Since covariate appears to have little influence on the
* lnsigma parameter, we estimate a model where number of
* pills only affect median parameter (mu) and the prevalence
* (logitp).
wtdttt last_rxtime, disttype(lnorm) start(0) end(1) conttime reverse ///
							mucovar(i.packsize) logitpcovar(i.packsize)

*********************************************************************
* A small example showing how treatment probability can be predicted 
* based on the distance between index dates and date of last 
* prescription redemption, while taking covariates (here: pack size) 
* into account. The last fitted WTD is used for this prediction.
*********************************************************************

preserve									  

use lastRx_index, clear /* Open dataset in which we predict treatment
                    probabilities */

wtdtttpredprob probttt, distrx(distlast)

sort packsize distlast
la var distlast "Time since last prescription (years)"
la var probttt "Probability of being exposed"

twoway scatter probttt distlast, c(L L) msy(i i)

restore

**********************************************************************
* Another example, where we predict duration of observed prescription 
* redemptions based on an estimated WTD. Here the predicted duration 
* corresponds to the 90th percentile of the IAD.
**********************************************************************

preserve
wtdttt last_rxtime, disttype(lnorm) start(0) end(1) conttime reverse /// 
							mucovar(i.packsize) logitpcovar(i.packsize)
return list

use lastRx_index, clear /* Open dataset in which we predict treatment
                    durations */


wtdtttpreddur predrxdur, iadp(.9)
la var predrxdur "Predicted duration of Rx"
bys packsize: list predrxdur if _n == 1
restore

******************************************************************
* Predict mean duration
******************************************************************

wtdttt last_rxtime, disttype(lnorm) start(0) end(1) conttime reverse ///
							mucovar(i.packsize) logitpcovar(i.packsize)

use lastRx_index, clear /* Open dataset in which we predict treatment
                    durations */


wtdtttpreddur predmeanrxdur, iadmean
la var predmeanrxdur "Predicted mean duration of Rx"
bys packsize: list predmeanrxdur if _n == 1
