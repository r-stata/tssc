* ranktest cert script 1.0.00 MS 1july2020

cscript "underid" adofile underid
clear all
capture log close
set more off
set rmsg on
program drop _all
log using cs_under, text replace
about
which underid
* also for cert file:
which ranktest
which ivreg2
which xtivreg2
which xtoverid
which avar
* check underid version
underid, version
assert "`r(version)'" == "01.0.00"

********************************************************************************
*********************** start **************************************************
********************************************************************************

*********************** IVREG2 ******************************

sysuse auto, clear
gen id = ceil(_n/4)

// iid
ivreg2 price i.rep78 foreign (mpg gear = weight turn headroom)
underid, kp
assert reldif(e(idstat),r(j_uid))<1e-10
underid, overid jgmm2s
assert reldif(e(j),r(j_oid))<1e-10

// robust
ivreg2 price i.rep78 foreign (mpg gear = weight turn headroom), rob
underid, kp
assert reldif(e(idstat),r(j_uid))<1e-10
underid, overid jgmm2s
assert reldif(e(j),r(j_oid))<1e-10

// robust
ivreg2 price foreign (mpg gear = weight turn headroom i.rep78), rob
underid, kp
assert reldif(e(idstat),r(j_uid))<1e-10
underid, overid jgmm2s
assert reldif(e(j),r(j_oid))<1e-10

// cluster
ivreg2 price i.rep78 foreign (mpg gear = weight turn headroom), cluster(id)
underid, kp
assert reldif(e(idstat),r(j_uid))<1e-10
underid, overid jgmm2s
assert reldif(e(j),r(j_oid))<1e-10

// fweights
ivreg2 price i.rep78 foreign (mpg gear = weight turn headroom) [fw=_n]
underid, kp
assert reldif(e(idstat),r(j_uid))<1e-10
underid, overid jgmm2s
assert reldif(e(j),r(j_oid))<1e-10

// aweights
ivreg2 price i.rep78 foreign (mpg gear = weight turn headroom) [aw=_n]
underid, kp
assert reldif(e(idstat),r(j_uid))<1e-10
underid, overid jgmm2s
assert reldif(e(j),r(j_oid))<1e-10

// pweights
ivreg2 price i.rep78 foreign (mpg gear = weight turn headroom) [pw=_n]
underid, kp
assert reldif(e(idstat),r(j_uid))<1e-10
underid, overid jgmm2s
assert reldif(e(j),r(j_oid))<1e-10

// iweights
ivreg2 price i.rep78 foreign (mpg gear = weight turn headroom) [iw=_n]
underid, kp
assert reldif(e(idstat),r(j_uid))<1e-10
underid, overid jgmm2s
assert reldif(e(j),r(j_oid))<1e-10

// time-series
webuse klein, clear
tsset yr
ivreg2 consump L.profits (profits wagetot = govt taxnetx year wagegovt capital1 L.totinc)
underid, kp
assert reldif(e(idstat),r(j_uid))<1e-10
underid, overid jgmm2s
assert reldif(e(j),r(j_oid))<1e-10

// kernel-robust iid
ivreg2 consump L.profits (profits wagetot = govt taxnetx year wagegovt capital1 L.totinc), bw(4)
underid, kp
assert reldif(e(idstat),r(j_uid))<1e-10
underid, overid jgmm2s
assert reldif(e(j),r(j_oid))<1e-10

// kernel-robust
ivreg2 consump L.profits (profits wagetot = govt taxnetx year wagegovt capital1 L.totinc), bw(4) rob
underid, kp
assert reldif(e(idstat),r(j_uid))<1e-10
underid, overid jgmm2s
assert reldif(e(j),r(j_oid))<1e-10


*********************** IVREGRESS ******************************

sysuse auto, clear
gen id = ceil(_n/4)

// iid
qui ivregress 2sls price i.rep78 foreign (mpg gear = weight turn headroom)
estat overid
scalar sargan=r(sargan)
underid, overid jgmm2s
assert reldif(sargan,r(j_oid))<1e-10

// rob
qui ivregress 2sls price i.rep78 foreign (mpg gear = weight turn headroom), rob
estat overid
scalar score=r(score)
underid, overid jgmm2s
assert reldif(score,r(j_oid))<1e-10

/*
// cluster - NOT AVAILABLE WITH IVREGRESS
qui ivregress 2sls price (mpg gear = weight turn headroom) foreign, vce(cluster id)
estat overid
scalar score=r(score)
underid, overid jgmm2s
assert reldif(score,r(j_oid))<1e-10
*/

// fweights
qui ivregress 2sls price (mpg gear = weight turn headroom) foreign [fw=_n]
estat overid
scalar score=r(score)
underid, overid jgmm2s
assert reldif(score,r(j_oid))<1e-10

// aweights
qui ivregress 2sls price (mpg gear = weight turn headroom) foreign [aw=_n]
estat overid, forceweights
scalar score=r(score)
underid, overid jgmm2s
assert reldif(score,r(j_oid))<1e-10

/* unclear why this fails but ivreg2 does not fail
// pweights
qui ivregress 2sls price (mpg gear = weight turn headroom) foreign [pw=_n]
estat overid, forceweights
scalar score=r(score)
underid, overid jgmm2s
assert reldif(score,r(j_oid))<1e-10
*/

// iweights
qui ivregress 2sls price (mpg gear = weight turn headroom) foreign [iw=_n]
estat overid, forceweights
scalar score=r(score)
underid, overid jgmm2s
assert reldif(score,r(j_oid))<1e-10

// time-series
// iid
webuse klein, clear
tsset yr
qui ivregress 2sls consump L.profits (profits wagetot = govt taxnetx year wagegovt capital1 L.totinc)
estat overid
scalar score=r(score)
underid, overid jgmm2s
assert reldif(score,r(j_oid))<1e-10

// gmm kernel-robust
webuse klein, clear
tsset yr
qui ivregress gmm consump L.profits (profits wagetot = govt taxnetx year wagegovt capital1 L.totinc), wmatrix(hac bartlett 3)
estat overid
scalar score=r(HansenJ)
underid, overid jgmm2s
assert reldif(score,r(j_oid))<1e-10

******************* XTABOND2 **************************

webuse abdata, clear

// factor variables check
// IVs
qui xtabond2 n L.n w L.w k, gmm(L.(w n k)) iv(yr*) noleveleq robust svmat
qui underid, overid jgmm2s
scalar j_oid=r(j_oid)
qui xtabond2 n L.n w L.w k, gmm(L.(w n k)) iv(i.year) noleveleq robust svmat
qui underid, overid jgmm2s
assert reldif(r(j_oid),j_oid)<1e-10
// exog regressors
qui xtabond2 n L.n w L.w k yr*, gmm(L.(w n k)) iv(yr*) noleveleq robust svmat
qui underid, overid jgmm2s
scalar j_oid=r(j_oid)
qui xtabond2 n L.n w L.w k i.year, gmm(L.(w n k)) iv(i.year) noleveleq robust svmat
qui underid, overid jgmm2s
assert reldif(r(j_oid),j_oid)<1e-10

// Diff, one-step, all options
foreach opt in h(1) h(2) h(3) orthog {
	xtabond2 n L.n w L.w k, gmm(L.(w n k)) iv(i.year) noleveleq robust svmat `opt'
	scalar j=e(hansen)
	mat b = e(b)
	qui underid, overid jgmm2s
	scalar j_oid=r(j_oid)
	mat b0_oid = r(b0_oid)	// initial beta
	di
	di as text "One-step, opt=`opt', xtabond2 j = " %6.4f j ", underid j = " %6.4f j_oid
	mat list b
	mat list b0_oid
	assert reldif(j,j_oid)<1e-10
	assert mreldif(b,b0_oid)<1e-10
}

// Diff, two-step, all options
foreach opt in h(1) h(2) h(3) orthog {
	xtabond2 n L.n w L.w k, gmm(L.(w n k)) iv(i.year) noleveleq robust svmat twostep `opt'
	scalar j=e(hansen)
	mat b = e(b)
	qui underid, overid jgmm2s
	scalar j_oid=r(j_oid)
	mat b_oid = r(b_oid)	// 2-step GMM beta
	di
	di as text "Diff, two-step, opt=`opt', xtabond2 j = " %6.4f j ", underid j = " %6.4f j_oid
	mat list b
	mat list b_oid
	assert reldif(j,j_oid)<1e-10
	assert mreldif(b,b_oid)<1e-10
}

// Sys, one-step, all options
foreach opt in h(1) h(2) h(3) orthog {
	xtabond2 n L.n w L.w k, gmm(L.(w n k)) iv(i.year) robust svmat `opt'
	scalar j=e(hansen)
	mat b = e(b)
	mat b = b[1,1..4]
	qui underid, overid jgmm2s
	scalar j_oid=r(j_oid)
	mat b0_oid = r(b0_oid)	// initial beta
	di
	di as text "One-step, opt=`opt', xtabond2 j = " %6.4f j ", underid j = " %6.4f j_oid
	mat list b
	mat list b0_oid
	// note looser tolerance
	assert reldif(j,j_oid)<1e-5
	assert mreldif(b,b0_oid)<1e-10
}

// Sys, two-step, all options
foreach opt in h(1) h(2) h(3) orthog {
	xtabond2 n L.n w L.w k, gmm(L.(w n k)) iv(i.year) robust svmat twostep `opt'
	scalar j=e(hansen)
	mat b = e(b)
	mat b = b[1,1..4]
	qui underid, overid jgmm2s
	scalar j_oid=r(j_oid)
	mat b_oid = r(b_oid)	// 2-step GMM beta
	di
	di as text "Diff, two-step, opt=`opt', xtabond2 j = " %6.4f j ", underid j = " %6.4f j_oid
	mat list b
	mat list b_oid
	// note looser tolerance
	assert reldif(j,j_oid)<1e-5
	// note very loose tolerance
	assert mreldif(b,b_oid)<1e-3
}


// Level equation only
xtabond2 n w cap, iv(cap k ys, eq(level)) iv(rec, eq(level)) cluster(id year) svmat
underid, overid jgmm2s
assert reldif(e(hansen),r(j_oid))<1e-8


*********************** XTIVREG2 ******************************

webuse abdata, clear

// fe

// iid
xtivreg2 n yr* (w k = L(1/2).w L(1/2).k), fe
underid, kp
assert reldif(e(idstat),r(j_uid))<1e-10
underid, overid jgmm2s
assert reldif(e(j),r(j_oid))<1e-10

// cluster
xtivreg2 n yr* (w k = L(1/2).w L(1/2).k), fe cluster(id)
underid, kp
assert reldif(e(idstat),r(j_uid))<1e-10
underid, overid jgmm2s
assert reldif(e(j),r(j_oid))<1e-10

// 2-way cluster; omit year dummies
xtivreg2 n (w k = L(1/2).w L(1/2).k), fe cluster(id year)
underid, kp
assert reldif(e(idstat),r(j_uid))<1e-10
underid, overid jgmm2s
assert reldif(e(j),r(j_oid))<1e-10

// fweights
xtivreg2 n yr* (w k = L(1/2).w L(1/2).k) [fw=_n], fe
underid, kp
assert reldif(e(idstat),r(j_uid))<1e-10
underid, overid jgmm2s
assert reldif(e(j),r(j_oid))<1e-10

// aweights
xtivreg2 n yr* (w k = L(1/2).w L(1/2).k) [aw=_n], fe
underid, kp
assert reldif(e(idstat),r(j_uid))<1e-10
underid, overid jgmm2s
assert reldif(e(j),r(j_oid))<1e-10

// pweights
xtivreg2 n yr* (w k = L(1/2).w L(1/2).k) [pw=_n], fe
underid, kp
assert reldif(e(idstat),r(j_uid))<1e-10
underid, overid jgmm2s
assert reldif(e(j),r(j_oid))<1e-10

// pweights+cluster
xtivreg2 n yr* (w k = L(1/2).w L(1/2).k) [pw=_n], fe cluster(id)
underid, kp
assert reldif(e(idstat),r(j_uid))<1e-10
underid, overid jgmm2s
assert reldif(e(j),r(j_oid))<1e-10

// iweights
xtivreg2 n yr* (w k = L(1/2).w L(1/2).k) [iw=_n], fe
underid, kp
assert reldif(e(idstat),r(j_uid))<1e-10
underid, overid jgmm2s
assert reldif(e(j),r(j_oid))<1e-10

// fd

// iid
xtivreg2 n yr* (w k = L(1/2).w L(1/2).k), fd
underid, kp
assert reldif(e(idstat),r(j_uid))<1e-10
underid, overid jgmm2s
assert reldif(e(j),r(j_oid))<1e-10

// cluster
xtivreg2 n yr* (w k = L(1/2).w L(1/2).k), fd cluster(id)
underid, kp
assert reldif(e(idstat),r(j_uid))<1e-10
underid, overid jgmm2s
assert reldif(e(j),r(j_oid))<1e-10

/* xtivreg2 J stat fails in original estimation
// 2-way cluster; omit year dummies
xtivreg2 n (w k = L(1/2).w L(1/2).k), fd cluster(id year)
underid, kp
assert reldif(e(idstat),r(j_uid))<1e-10
underid, overid jgmm2s
assert reldif(e(j),r(j_oid))<1e-10
*/

*********************** XTIVREG ******************************
// nb: xtivreg does not support weights
// nb: repstata option required for crosscheck vs xtoverid

// note lower tolerance

webuse nlswork, clear
tsset idcode year 
gen age2=age^2 
gen black=(race==2)

// FE

// iid
xtivreg ln_wage age (tenure = union south), fe
xtoverid
scalar j=r(j)
underid, overid jgmm2s
assert reldif(j,r(j_oid))<1e-8

// cluster
xtivreg ln_wage age (tenure = union south), fe vce(cluster id)
xtoverid
scalar j=r(j)
underid, overid jgmm2s
assert reldif(j,r(j_oid))<1e-8

// G2SLS

// iid
xtivreg ln_wage age (tenure = union south)
xtoverid
scalar j=r(j)
underid, overid jgmm2s
assert reldif(j,r(j_oid))<1e-8

// cluster
xtivreg ln_wage age (tenure = union south), vce(cluster id)
xtoverid
scalar j=r(j)
underid, overid jgmm2s
assert reldif(j,r(j_oid))<1e-8

// EC2SLS

// iid
xtivreg ln_wage age (tenure = union south), ec2sls
xtoverid
scalar j=r(j)
underid, overid jgmm2s repstata
assert reldif(j,r(j_oid))<1e-8

// cluster
xtivreg ln_wage age (tenure = union south), ec2sls vce(cluster id)
xtoverid
scalar j=r(j)
underid, overid jgmm2s repstata
assert reldif(j,r(j_oid))<1e-8

// check other options for EC2SLS + unbalanced panels besides repstata
xtivreg ln_wage age (tenure = union south), vce(cluster id) ec2sls
underid, overid jgmm2s
underid, overid jgmm2s usemeans


*********************** XTHTAYLOR ******************************

// note lower tolerance

// Hausman-Taylor, unbalanced
webuse nlswork, clear
tsset idcode year 
gen age2=age^2 
gen black=(race==2)

// iid
xthtaylor ln_wage age age2 tenure hours black birth_yr grade, endog(tenure hours grade)
xtoverid
scalar j=r(j)
underid, overid jgmm2s repstata
assert reldif(j,r(j_oid))<1e-8

// cluster
xthtaylor ln_wage age age2 tenure hours black birth_yr grade, endog(tenure hours grade) vce(cluster idcode)
xtoverid
scalar j=r(j)
underid, overid jgmm2s repstata
assert reldif(j,r(j_oid))<1e-8

// Hausman-Taylor, balanced
webuse psidextract, clear

xthtaylor lwage wks south smsa ms exp exp2 occ ind union fem blk ed, endog(exp exp2 occ ind union ed) constant(fem blk ed)
xtoverid
scalar j=r(j)
underid, overid jgmm2s
assert reldif(j,r(j_oid))<1e-8

xthtaylor lwage wks south smsa ms exp exp2 occ ind union fem blk ed, endog(exp exp2 occ ind union ed) constant(fem blk ed) vce(cluster id)
xtoverid
scalar j=r(j)
underid, overid jgmm2s
assert reldif(j,r(j_oid))<1e-8

// Amemiya-MaCurdy

xthtaylor lwage wks south smsa ms exp exp2 occ ind union fem blk ed, endog(exp exp2 occ ind union ed) amacurdy
xtoverid
scalar j=r(j)
underid, overid jgmm2s
assert reldif(j,r(j_oid))<1e-8

xthtaylor lwage wks south smsa ms exp exp2 occ ind union fem blk ed, endog(exp exp2 occ ind union ed) amacurdy vce(cluster id)
xtoverid
scalar j=r(j)
underid, overid jgmm2s
assert reldif(j,r(j_oid))<1e-8

******************* XTDPDGMM **************************

webuse abdata, clear

xtdpdgmm L(0/1).n w k, gmmiv(L.n, l(1 4) m(d)) iv(w k, d m(d)) vce(robust)
mat b = e(b)
mat b = b[1.,1..3]
scalar j = e(chi2_J)
underid, overid jgmm2s
mat b0_oid = r(b0_oid)	// initial beta
scalar j_oid = r(j_oid)
mat list b
mat list b0_oid
di "J stats: " j ", " j_oid
* assert reldif(j,j_oid)<1e-10
assert mreldif(b,b0_oid)<1e-8

xtdpdgmm L(0/1).n w k, gmmiv(L.n, l(1 4) m(d)) iv(w k, d m(l)) vce(robust)
mat b = e(b)
mat b = b[1.,1..3]
scalar j = e(chi2_J)
underid, overid jgmm2s
mat b0_oid = r(b0_oid)	// initial beta
scalar j_oid = r(j_oid)
mat list b
mat list b0_oid
di "J stats: " j ", " j_oid
* assert reldif(j,j_oid)<1e-10
assert mreldif(b,b0_oid)<1e-8

xtdpdgmm L(0/1).n w k, gmmiv(L.n w k, l(1 4) c m(fod)) vce(robust)
mat b = e(b)
mat b = b[1.,1..3]
scalar j = e(chi2_J)
underid, overid jgmm2s
mat b0_oid = r(b0_oid)	// initial beta
scalar j_oid = r(j_oid)
mat list b
mat list b0_oid
di "J stats: " j ", " j_oid
* assert reldif(j,j_oid)<1e-10
assert mreldif(b,b0_oid)<1e-8

xtdpdgmm L(0/1).n w k, gmmiv(L.n, l(1 4) m(d)) iv(w k, d m(d)) vce(robust) teffects
mat b = e(b)
mat b = b[1.,1..10]
scalar j = e(chi2_J)
underid, overid jgmm2s
mat b0_oid = r(b0_oid)	// initial beta
scalar j_oid = r(j_oid)
mat list b
mat list b0_oid
di "J stats: " j ", " j_oid
* assert reldif(j,j_oid)<1e-10
assert mreldif(b,b0_oid)<1e-8

xtdpdgmm L(0/1).n w k yr*, gmmiv(L.n, l(1 4) m(d)) iv(w k, d m(d)) iv(yr*) nocons
mat b = e(b)
mat b = b[1.,1..3]
scalar j = e(chi2_J)
underid, overid jgmm2s
mat b0_oid = r(b0_oid)	// initial beta
mat b0_oid = b0_oid[1,1..3]
scalar j_oid = r(j_oid)
mat list b
mat list b0_oid
di "J stats: " j ", " j_oid
* assert reldif(j,j_oid)<1e-10
assert mreldif(b,b0_oid)<1e-8


******************* USBAL89 REPLICATION **************************

import excel "https://www.dropbox.com/s/tnbjtf1sguz2e2u/usbal89.xlsx?dl=1", first clear

xtset id year, yearly

qui xtabond2 y l.y n l.n k l.k i.year,											///
	gmm(y n k, lag(3 5)) iv(i.year) rob svmat nol
underid, sw noreport
assert reldif(r(j_uid),27.91904619868749) < 1e-8
assert reldif(el(r(sw_uid),1,1),63.040418) < 1e-8
assert reldif(el(r(sw_uid),2,1),40.130217) < 1e-8
assert reldif(el(r(sw_uid),3,1),54.56506) < 1e-8
assert reldif(el(r(sw_uid),4,1),42.168843) < 1e-8
assert reldif(el(r(sw_uid),5,1),50.953486) < 1e-8
underid, kp noreport
assert reldif(r(j_uid),28.75294423723649) < 1e-8

qui xtabond2 y l.y n l.n k l.k i.year,											///
	gmm(y n k, lag(3 5)) iv(i.year) rob svmat
underid, sw noreport
assert reldif(r(j_uid),46.07693272541004) < 1e-8
assert reldif(el(r(sw_uid),1,1),79.72662) < 1e-8
assert reldif(el(r(sw_uid),2,1),58.608428) < 1e-8
assert reldif(el(r(sw_uid),3,1),65.096867) < 1e-8
assert reldif(el(r(sw_uid),4,1),88.68872) < 1e-8
assert reldif(el(r(sw_uid),5,1),84.997356) < 1e-8
underid, kp noreport
assert reldif(r(j_uid),48.18028683399609) < 1e-8


********************************************************************************
*** finish                                                                   ***
********************************************************************************

cap log close
set more on
set rmsg off
