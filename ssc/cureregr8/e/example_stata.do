
cd C:\data

use example_stata.dta,clear

stset efsyrs,failure(exit==1)

label define l500 1 ">500 IU" 0 "le 500 IU",modify
label val l500 l500

label define m23 1 "M2|M3" 0 "M1",modify
label val m23 m23

cureregr ib0.m23,sc(ib0.l500 ib0.m23) sh() ///
link(lml) distribution(lognorm) class(nonm)nolog
estimate store A

cureregr ib0.l500 ib0.m23,sc(ib0.l500 ib0.m23) sh() ///
link(lml) distribution(lognorm) class(nonm)nolog
estimate store B

lrtest B A

cureregr ib0.l500 ib0.m23,sc(ib0.l500 ib0.m23) sh() ///
link(lml) distribution(logns1) class(nonm)nolog aux
estimate store C

lrtest C B,force

/*on predict with continuous c.age*/
cureregr c.age ib0.l500 ib0.m23,sc(ib0.l500 ib0.m23) sh() ///
link(lml) distribution(logns1) class(nonm)nolog aux
clonevar age_copy=age

/* with option ’detail’ summarize returns the following percentiles: */
/* 1 5 10 25 50 75 90 95 99 */
foreach i of numlist 5 50 95 {
summarize age , detail
qui replace age= r(p`i')
di `""'
di `"{res}===== age percentile = `i' ====={txt}"'
predict , at(1(0.5)4)
di `"{res}==end age percentile = `i' ====={txt}"'
drop age
clonevar age=age_copy
}
*
**********************************************************************
**********************************************************************
cureregr ib0.l500 ib0.m23,sc(ib0.l500 ib0.m23) sh() ///
link(lml) distribution(lognv) class(nonm)nolog aux tech(nr) vce(opg) ///
cformat(%6.4f) sformat(%3.2f) pformat(%5.4f)

cureregr ib0.l500 ib0.m23,sc(ib0.l500 ib0.m23) sh() ///
link(lml) distribution(lognv) class(nonm)nolog aux tech(nr) vce(opg) ///
cformat(%6.4f) sformat(%3.2f) pformat(%5.4f)
**********************************************************************
**********************************************************************

