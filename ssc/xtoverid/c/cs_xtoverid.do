* xtoverid cert script 1.0.2 MES 19Feb2015
set more off
cscript xtoverid adofile xtoverid
set matsize 800
capture log close
log using cs_xtoverid, replace

webuse nlswork, clear
tsset idcode year
gen age2=age^2
gen byte black = (race==2)
forvalues y=68/88 {
	gen t`y'=(year==`y')
}
drop t74 t76 t79 t81 t84 t86

* Create a balanced panel indicated by boolean variable bal.
gen notmiss=(ln_wage<. & age<. & age2<. & not_smsa<. & tenure<. & union<. & south<. & birth_yr<. & black<.)
gen byte bal=0
replace bal=1 if year==71 & notmiss==1
replace bal=0 if year==71 & F.notmiss~=1
replace bal=0 if year==71 & F2.notmiss~=1
replace bal=1 if year==72 & notmiss==1
replace bal=0 if year==72 & L.notmiss~=1
replace bal=0 if year==72 & F.notmiss~=1
replace bal=1 if year==73 & notmiss==1
replace bal=0 if year==73 & L.notmiss~=1
replace bal=0 if year==73 & L2.notmiss~=1

* For checking TS
capture drop Lage
capture drop Lage2
capture drop Lnot_smsa
capture drop Ltenure
capture drop Lunion
capture drop Lsouth
gen Lage=L.age
gen Lage2=L.age2
gen Lnot_smsa=L.not_smsa
gen Ltenure=L.tenure
gen Lunion=L.union
gen Lsouth=L.south

*** Begin certification ***
which xtoverid
which ivreg2
which xtivreg
which xthtaylor
which xtivreg2

*** FE ***

* Stata manual example
* Singleton groups are dropped, so to be correct, must catch these
* xtivreg has no nocons option
qui xtivreg ln_wage age* not_smsa (tenure = union south), fe
xtoverid
scalar j=r(j)
* xtivreg2, fe doesn't report a constant
qui xtivreg2 ln_wage age* not_smsa (tenure = union south), fe
xtoverid
scalar j2=r(j)
assert reldif(j,j2)<1e-6
scalar j=e(sargan)
assert reldif(j,j2)<1e-6

* Using TS operators
qui xtivreg ln_wage age* L.not_smsa (L.tenure = L.union L.south), fe
xtoverid
scalar j=r(j)
* xtivreg2, fe doesn't report a constant
qui xtivreg2 ln_wage age* L.not_smsa (L.tenure = L.union L.south), fe
xtoverid
scalar j2=r(j)
assert reldif(j,j2)<1e-6
scalar j=e(sargan)
assert reldif(j,j2)<1e-6

* robust
qui xtivreg ln_wage age* not_smsa (tenure = union south), fe
xtoverid, robust
scalar j=r(j)
qui xtivreg2 ln_wage age* not_smsa (tenure = union south), fe robust
xtoverid
scalar j2=r(j)
assert reldif(j,j2)<1e-6
scalar j=e(j)
assert reldif(j,j2)<1e-6
* with TS
qui xtivreg ln_wage age* L.not_smsa (L.tenure = L.union L.south), fe
xtoverid, robust
scalar j=r(j)
qui xtivreg2 ln_wage age* L.not_smsa (L.tenure = L.union L.south), fe robust
xtoverid
scalar j2=r(j)
assert reldif(j,j2)<1e-6
scalar j=e(j)
assert reldif(j,j2)<1e-6

* cluster
qui xtivreg ln_wage age* not_smsa (tenure = union south), fe
xtoverid, cluster(idcode)
scalar j=r(j)
qui xtivreg2 ln_wage age* not_smsa (tenure = union south), fe cluster(idcode)
xtoverid
scalar j2=r(j)
assert reldif(j,j2)<1e-6
scalar j=e(j)
assert reldif(j,j2)<1e-6
* with TS
qui xtivreg ln_wage age* L.not_smsa (L.tenure = L.union L.south), fe
xtoverid, cluster(idcode)
scalar j=r(j)
qui xtivreg2 ln_wage age* L.not_smsa (L.tenure = L.union L.south), fe cluster(idcode)
xtoverid
scalar j2=r(j)
assert reldif(j,j2)<1e-6
scalar j=e(j)
assert reldif(j,j2)<1e-6

* gmm
qui xtivreg2 ln_wage age* not_smsa (tenure = union south), fe robust gmm2s
xtoverid
qui xtivreg2 ln_wage age* not_smsa (tenure = union south), fe clu(idcode) gmm2s
xtoverid

*** FD ***

* Constant
qui xtivreg ln_wage age* not_smsa (tenure = union south), fd
xtoverid
scalar j=r(j)
qui xtivreg2 ln_wage age* not_smsa (tenure = union south), fd
xtoverid
scalar j2=r(j)
assert reldif(j,j2)<1e-6
scalar j=e(sargan)
assert reldif(j,j2)<1e-6
* with TS
qui xtivreg ln_wage age* L.not_smsa (L.tenure = L.union L.south), fd
xtoverid
scalar j=r(j)
qui xtivreg2 ln_wage age* L.not_smsa (L.tenure = L.union L.south), fd
xtoverid
scalar j2=r(j)
assert reldif(j,j2)<1e-6
scalar j=e(sargan)
assert reldif(j,j2)<1e-6

* No constant
qui xtivreg ln_wage age* not_smsa (tenure = union south), fd nocons
xtoverid
scalar j=r(j)
qui xtivreg2 ln_wage age* not_smsa (tenure = union south), fd nocons
xtoverid
scalar j2=r(j)
assert reldif(j,j2)<1e-6
scalar j=e(sargan)
assert reldif(j,j2)<1e-6

* robust
qui xtivreg ln_wage age* not_smsa (tenure = union south), fd
xtoverid, robust
scalar j=r(j)
qui xtivreg2 ln_wage age* not_smsa (tenure = union south), fd robust
xtoverid
scalar j2=r(j)
assert reldif(j,j2)<1e-6
scalar j=e(j)
assert reldif(j,j2)<1e-6
* with TS
qui xtivreg ln_wage age* L.not_smsa (L.tenure = L.union L.south), fd
xtoverid, robust
scalar j=r(j)
qui xtivreg2 ln_wage age* L.not_smsa (L.tenure = L.union L.south), fd robust
xtoverid
scalar j2=r(j)
assert reldif(j,j2)<1e-6
scalar j=e(j)
assert reldif(j,j2)<1e-6

* cluster
qui xtivreg ln_wage age* not_smsa (tenure = union south), fd
xtoverid, cluster(idcode)
scalar j=r(j)
qui xtivreg2 ln_wage age* not_smsa (tenure = union south), fd cluster(idcode)
xtoverid
scalar j2=r(j)
assert reldif(j,j2)<1e-6
scalar j=e(j)
assert reldif(j,j2)<1e-6
* with TS
qui xtivreg ln_wage age* L.not_smsa (L.tenure = L.union L.south), fd
xtoverid, cluster(idcode)
scalar j=r(j)
qui xtivreg2 ln_wage age* L.not_smsa (L.tenure = L.union L.south), fd cluster(idcode)
xtoverid
scalar j2=r(j)
assert reldif(j,j2)<1e-6
scalar j=e(j)
assert reldif(j,j2)<1e-6

* gmm
qui xtivreg2 ln_wage age* not_smsa (tenure = union south), fd robust gmm2s
xtoverid
qui xtivreg2 ln_wage age* not_smsa (tenure = union south), fd clu(idcode) gmm2s
xtoverid

*** BE ***
* Not yet supported by xtivreg2

qui xtivreg ln_wage age* not_smsa (tenure = union south), be
xtoverid
* robust and cluster should generate same J stat
xtoverid, robust
scalar j=r(j)
xtoverid, cluster(idcode)
scalar j2=r(j)
assert reldif(j,j2)<1e-6
* TS
qui xtivreg ln_wage age* L.not_smsa (L.tenure = L.union L.south), be
xtoverid
scalar j=r(j)
qui xtivreg ln_wage age* Lnot_smsa (Ltenure = Lunion Lsouth), be
xtoverid
scalar j2=r(j)
assert reldif(j,j2)<1e-6


*** G2SLS ***

* Stata manual example.  Note typo in manual - black regressor, not (also) excl. IV
* Singleton groups are dropped, so to be correct, must catch these
* xtivreg has no nocons option
qui xtivreg ln_wage age* not_smsa black (tenure = union birth_yr south), re
xtoverid
scalar j=r(j)
xtoverid, robust
xtoverid, cluster(idcode)
* Both time and group invariant
qui xtivreg ln_wage age* not_smsa t70-t73 t77-t87 (tenure = union birth_yr south), re
xtoverid
xtoverid, robust
xtoverid, cluster(idcode)

* TS
qui xtivreg ln_wage L.age L.age2 not_smsa black (L.tenure = L.union birth_yr south), re
xtoverid
scalar j=r(j)
qui xtivreg ln_wage Lage Lage2 not_smsa black (Ltenure = Lunion birth_yr south), re
xtoverid
scalar j2=r(j)
assert reldif(j,j2)<1e-6

* Balanced panel
xtivreg ln_wage age* not_smsa black (tenure = union birth_yr south), re
xtoverid
* Both time and group invariant
xtivreg ln_wage age* not_smsa t70-t73 t77-t87 (tenure = union birth_yr south), re
xtoverid
xtoverid, robust
xtoverid, cluster(idcode)


*** EC2SLS ***

* Stata manual example.  Note typo in manual - black regressor, not (also) excl. IV
* xtivreg has no nocons option
xtivreg ln_wage age* not_smsa black (tenure = union birth_yr south), ec2sls
xtoverid
xtoverid, robust
xtoverid, cluster(idcode)
* Two time-invariant excl exog
xtivreg ln_wage age* not_smsa (tenure = union birth_yr black south), ec2sls
xtoverid
xtoverid, robust
xtoverid, cluster(idcode)
* One time-invariant excl exog
xtivreg ln_wage age* not_smsa (tenure = union birth_yr south), ec2sls
xtoverid
xtoverid, robust
xtoverid, cluster(idcode)
* Two time-invariant incl exog
xtivreg ln_wage age* not_smsa black birth_yr (tenure = union south), ec2sls
xtoverid
xtoverid, robust
xtoverid, cluster(idcode)
* One time-invariant incl exog
xtivreg ln_wage age* not_smsa black birth_yr (tenure = union south), ec2sls
xtoverid
xtoverid, robust
xtoverid, cluster(idcode)
* Both time and group invariant
xtivreg ln_wage age* not_smsa t70-t73 t77-t87 (tenure = union birth_yr south), ec2sls
xtoverid
xtoverid, robust
xtoverid, cluster(idcode)

* Balanced panel
xtivreg ln_wage age* not_smsa black (tenure = union birth_yr south) if bal==1, ec2sls
xtoverid
xtoverid, robust
xtoverid, cluster(idcode)
* Two time-invariant excl exog
xtivreg ln_wage age* not_smsa (tenure = union birth_yr black south) if bal==1, ec2sls
xtoverid
xtoverid, robust
xtoverid, cluster(idcode)
* One time-invariant excl exog
xtivreg ln_wage age* not_smsa (tenure = union birth_yr south) if bal==1, ec2sls
xtoverid
xtoverid, robust
xtoverid, cluster(idcode)
* Two time-invariant incl exog
xtivreg ln_wage age* not_smsa black birth_yr (tenure = union south) if bal==1, ec2sls
xtoverid
xtoverid, robust
xtoverid, cluster(idcode)
* One time-invariant incl exog
xtivreg ln_wage age* not_smsa black birth_yr (tenure = union south) if bal==1, ec2sls
xtoverid
* Both time and group invariant
xtivreg ln_wage age* not_smsa t72 t73 (tenure = union birth_yr south) if bal==1, ec2sls
xtoverid
xtoverid, robust
xtoverid, cluster(idcode)

* EC2SLS notes
* If no time-invariant inexog or exexog, Sargan dof same in balanced & unbalanced
* If add 1 time-invariant inexog,
*   dof of unbalanced increases by 1
*   dof of balanced stays unchanged
* If add 1 time-invariant exexog,
*   dof of unbalanced increases by 2
*   dof of balanced increases by 1
* If add 1 time-varying group invariant included exogenous,
*   dof of unbalanced increases by 1
*   dof of balanced stays unchanged
* If add 1 time-varying group invariant excluded exogenous,
*   dof of unbalanced increases by 2
*   dof of balanced stays unchanged

*** Hausman-Taylor ***

xthtaylor ln_wage age* tenure hours black birth_yr grade, /*
	*/	endog(tenure hours grade) constant(black birth_yr grade) i(idcode)
xtoverid
xtoverid, robust
xtoverid, cluster(idcode)
* Both time and group invariant
xthtaylor ln_wage age* tenure hours black birth_yr grade t72 t73, /*
	*/	endog(tenure hours grade) constant(black birth_yr grade) i(idcode)
xtoverid
xtoverid, robust
xtoverid, cluster(idcode)

* Balanced panel
xthtaylor ln_wage age* tenure hours black birth_yr grade if bal==1, /*
	*/	endog(tenure hours grade) constant(black birth_yr grade) i(idcode)
xtoverid
xtoverid, robust
xtoverid, cluster(idcode)
* Both time and group invariant
xthtaylor ln_wage age* tenure hours black birth_yr grade t72 t73 if bal==1, /*
	*/	endog(tenure hours grade) constant(black birth_yr grade) i(idcode)
xtoverid
xtoverid, robust
xtoverid, cluster(idcode)

* Empty varlists
* Empty TVexog not allowed by xthtaylor
* Empty TVendog
cap noi xthtaylor ln_wage age* black birth_yr grade, /*
	*/	endog(grade) constant(black birth_yr grade) i(idcode)
cap noi xtoverid
cap noi xthtaylor ln_wage age* black birth_yr grade if bal==1, /*
	*/	endog(grade) constant(black birth_yr grade) i(idcode)
cap noi xtoverid
* Empty TIendog
cap noi xthtaylor ln_wage age* tenure hours black birth_yr grade, /*
	*/	endog(tenure hours) constant(black birth_yr grade) i(idcode)
cap noi xtoverid
cap noi xthtaylor ln_wage age* tenure hours black birth_yr grade if bal==1, /*
	*/	endog(tenure hours) constant(black birth_yr grade) i(idcode)
cap noi xtoverid
* Empty TIexog
cap noi xthtaylor ln_wage age* tenure hours grade, /*
	*/	endog(tenure hours) constant(grade) i(idcode)
cap noi xtoverid
cap noi xthtaylor ln_wage age* tenure hours grade if bal==1, /*
	*/	endog(tenure hours) constant(grade) i(idcode)
cap noi xtoverid


*** Amemiya-MaCurdy ***

* Balanced panel
xthtaylor ln_wage age* tenure hours black birth_yr grade if bal==1, /*
	*/	endog(tenure hours grade) constant(black birth_yr grade) i(idcode) amacurdy
xtoverid
xtoverid, robust
xtoverid, cluster(idcode)
* Both time and group invariant
xthtaylor ln_wage age* tenure hours black birth_yr grade t72 t73 if bal==1, /*
	*/	endog(tenure hours grade) constant(black birth_yr grade) i(idcode) amacurdy
xtoverid
xtoverid, robust
xtoverid, cluster(idcode)

log close
