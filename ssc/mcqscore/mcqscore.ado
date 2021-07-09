program define mcqscore

version 8.0

syntax varlist(min=27 max=27), id(string) saving(string) [nojk]

capture ssc install levels

preserve

tempfile master opfile

mcq2long `varlist', id(`id')

qui gen lk_small=.
qui gen lk_medium=.
qui gen lk_large=.
qui gen bs1=.
qui gen bs2=.
qui gen bm1=.
qui gen bm2=.
qui gen bh1=.
qui gen bh2=.
qui gen b1=.
qui gen b2=.
qui gen lkhat=.

if "`jk'"~="nojk" {
qui gen lk_se=.
qui gen lk_unbiased=.
}

qui levels `id', local(idnlevs)

qui save "`master'"

di "Starting  " c(current_time)

foreach i of local idnlevs {

qui use "`master'",clear

qui egen iprank=rank(far), by(`id') tr

replace iprank=ceil(iprank/9.001)

di "ID Number  " `i'

qui keep if `id'==`i'

sort `id' ip1

capture ml model d0 mcq_lik (choice = ip1 time, nocons) if iprank==1, max
scalar rc2=_rc
if rc2==0 {
	capture matrix myb=e(b)
	capture replace bs1 = myb[1,1] 
	capture replace bs2 = myb[1,2] 
	capture replace lk_small = log(bs2/bs1) 
}

capture ml model d0 mcq_lik (choice = ip1 time, nocons) if iprank==2, max
scalar rc2=_rc
capture matrix myb=e(b)
if rc2==0 {
	capture replace bm1 = myb[1,1] 
	capture replace bm2 = myb[1,2] 
	capture replace lk_medium = log(bm2/bm1) 
}

capture ml model d0 mcq_lik (choice = ip1 time, nocons) if iprank==3, max
scalar rc2=_rc
capture matrix myb=e(b)
if rc2==0 {
	capture replace bh1 = myb[1,1] 
	capture replace bh2 = myb[1,2] 
	capture replace lk_large = log(bh2/bh1) 
}

capture ml model d0 mcq_lik (choice = ip1 time, nocons), max
scalar rc2=_rc
capture matrix myb=e(b)
if rc2==0 {
	capture replace b1 = myb[1,1] 
	capture replace b2 = myb[1,2] 
	capture replace lkhat = log(b2/b1) 
}

if "`jk'"~="nojk" {
capture jknife "ml model d0 mcq_lik (choice = ip1 time, nocons),max iterate(100)" bias=(log(_b[time]/_b[ip1])),e 
scalar rc3=_rc
di "RC3  " rc3
if rc3==0 {
	capture replace lk_unbiased=$S_3 
	capture replace lk_se=$S_4 
}
}


collapse b1 b2 lk*, by(`id')

capture append using "`opfile'"
qui save "`opfile'", replace
qui save "`saving'", replace

di c(current_time)

}

qui use "`opfile'", clear

qui sort `id'

order `id' lk_small lk_medium lk_large b1 b2 lkhat 
label var `id' "ID number"
label var lk_small "MCQ: Natural log of K for small rewards."
label var lk_medium "MCQ: Natural log of K for medium rewards."
label var lk_large "MCQ: Natural log of K for large rewards."
label var b1 "MCQ: Logit beta for transformed reward ratio across all reward sizes."
label var b2 "MCQ: Logit beta for time across all reward sizes."
label var lkhat "MCQ: Natural log of K across all reward sizes."

if "`jk'"~="nojk" {
label var lkhat "MCQ: Jackknife standard error for estimate of natural log of K across all reward sizes."
label var lkhat "MCQ: Unbiased natural log of K across all reward sizes."
}

compress
save "`saving'", replace
list
restore


end

