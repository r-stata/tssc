*! version 1.3, Chao Wang, 21/05/2019
* calculates median survival time using Cox/Poisson regression
program medsurv

version 13.1
syntax [, id(varname numeric) riskset(varname numeric)]

tempvar medsurv_int haz hazc cumhaz surv surv_diff
tempfile medsurv timeintervals


/* run model like this:
stsplit, at(failures) riskset(interval)

generate time_exposed = _t - _t0
poisson _d ibn.interval protect age calcium, exposure(time_exposed) noconstant irr

*/

preserve
quietly drop if `riskset'==.  // some of these are censored

// save the interval-time relationship
local exposure=substr(e(offset),4,length(e(offset))-4)
keep `riskset' `exposure' _t
rename _t medsurv
label variable medsurv "Median survival time"
bysort `riskset': egen _max_time_exposed=max(`exposure')
drop `exposure'
ren _max_time_exposed `exposure'
quietly duplicates drop
quietly save `timeintervals'

restore, preserve

sort `id' _t
quietly sum `riskset'
local max_interval=r(max)
quietly levelsof `id', local(ids)
quietly foreach i of local ids {
  
 // expand the data
 count if `id'==`i'
 if r(N)<`max_interval' {
  sum _t if `id'==`i'
  expand `max_interval'-r(N)+1 if `id'==`i' & _t==r(max)
  replace `riskset'=1 if `id'==`i'
  replace `riskset'=sum(`riskset') if `id'==`i'
 }
 
 // predict: this is to save data size
 merge m:1 `riskset' using `timeintervals', update replace nogen
 predict `haz' if `id'==`i'
 gen `cumhaz'=sum(`haz') if `id'==`i'
 
 gen `surv'=exp(-`cumhaz')
 gen `surv_diff'=0.5-`surv'
 replace `surv_diff'=. if `surv_diff'<0
 
 sum `surv_diff' if `id'==`i'
 drop if (`surv_diff'>r(min) & `id'==`i') | (`surv_diff'==. & `id'==`i')
 
 drop `haz' `cumhaz' `surv' `surv_diff'

} 

/* alternatively, sth similar
stcox protect age calcium
predict double bhc, basehc
gen hazc=bhc*exp(xb)
*/

/* cal also try below for non time-varying covaraite:
stcox protect age calcium
predict bchaz, basechazard
gen cumhaz1=bchaz*exp(xb)
*/

/* extract baseline hazard function
matrix b=e(b)'
svmat b
gen bh=exp(b1)

sum interval
local max=r(max)
keep in 1/`max'
keep bh
gen interval=_n

save ttt.dta, replace

restore

merge m:1 interval using ttt.dta
 gen haz=bh*exp(xb)
*/

* create a datset containing the predicted median survival for each subject
keep `id' `riskset'
quietly merge m:1 `riskset' using `timeintervals',keep(match) nogen
quietly save `medsurv'
restore

* now merge median survival into main dataset
quietly merge m:1 `id' using `medsurv', nogen keep(master match)

end
