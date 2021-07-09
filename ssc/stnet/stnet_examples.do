cd "D:\stnet\SJsubmission\Paper\Data"
* sjlog using "D:\stnet\SJsubmission\Paper\Latex\listpop"
use popmort, clear
list in 1/5, noobs
* sjlog close

* sjlog using "D:\stnet\SJsubmission\Paper\Latex\example1"
use colon_net,clear
qui stset exit, origin(dx) f(status) scale(365.24)
stnet using popmort if yydx>=1980 & yydx<1985, mergeby(_year  sex  _age) ///
	br(0(.083333333)10) diagdate(dx) birthdate(birthdate) /// 
	list(n d cns locns upcns secns) listyearly 
*sjlog close

* sjlog using "D:\stnet\SJsubmission\Paper\Latex\example2"
egen agegr =cut(age), at(0 45(10)75 100) icodes
lab def agegr 0 "0-44" 1 "45-54" 2 "55-64" 3 "65-74" 4 "75+"
lab val agegr agegr
qui stnet using popmort if yydx>=1980 & yydx<1985, ///
	mergeby(_year  sex  _age) br(0(.083333333)10) ///
	diagdate(dx) birthdate(birthdate) /// 
	by(sex agegr) ederer saving(age_sex_NS,replace)
use age_sex_NS,clear
bys sex agegr (end) : gen n0=n[1]
list sex agegr n0 cs cns locns upcns if end==5, sepby(sex) noobs
* sjlog close

use colon_net,clear
stset exit, origin(dx) f(status) scale(365.24)
egen agegr =cut(age), at(0 45(10)75 100) icodes
lab def agegr 0 "0-44" 1 "45-54" 2 "55-64" 3 "65-74" 4 "75+"
lab val agegr agegr
* sjlog using "D:\stnet\SJsubmission\Paper\Latex\example3"
recode agegr 0=0.07 1=0.12 2=0.23 3=0.29 4=0.29, gen(standw)
stnet using popmort if yydx>=1980 & yydx<1985 [iw=standw], ///
	mergeby(_year  sex  _age) br(0(.083333333)10) ///
	diagdate(dx) birthdate(birthdate) /// 
	standstrata(agegr) listyearly by(sex) ///
	savst(agestand_sex_NS,replace)
* sjlog close

* sjlog using "D:\stnet\SJsubmission\Paper\Latex\example4"
use agestand_sex_NS, clear
gen agegr = 5
append using age_sex_NS
label define agegr 5 "Age-standardised", modify
label val agegr agegr
* sjlog close

* Adding 1 observation for each age group and sex to show survival estimates from 0
local nobs = c(N) + 12 // 6 age groups * 2 sex
set obs `nobs'
replace end = 0 in -12/l
replace sex = 1 in -12/-7
replace sex = 2 in -6/l
foreach var of varlist cns locns upcns {
	replace `var' = 1 in -12/l
}
bysort sex end : replace agegr = _n-1 if agegr==.
sort sex agegr end
set scheme sj
* sjlog using "D:\stnet\SJsubmission\Paper\Latex\example4",append
twoway (rarea locns upcns end if sex==1, col(gs10)) ///
	(line cns end if sex==1, lc(black) lw(medthick) lp(l)) , ///
	by(agegr, legend(off)) xla(0(2)10) xtitle("Years from diagnosis") ///
	yti("Net survival") yla(0(.2)1, format(%2.1f)) 
* sjlog close, replace
graph export "D:\stnet\SJsubmission\Paper\Latex\Figstnet.eps", replace
graph export "D:\stnet\SJsubmission\Paper\Latex\Figstnet.pdf", replace
