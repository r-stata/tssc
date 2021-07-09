* ranktest cert script 2.0.03 MS 19june2020
cscript ranktest adofile ranktest
clear
capture log close
set more off
set rmsg on
program drop _all
log using cs_ranktest,replace
about
if _caller()<13 {
	di as err "error - minimum Stata required is version 13"
	log close
	set more on
	set rmsg off
	exit
}

which ivreg2
which ranktest
ranktest, version
assert "`r(version)'" == "02.0.03"

webuse klein, clear
tsset yr
* Used to test weights
gen int weight = _n

* Equivalence of rk statistic and canonical correlations under homoskedasticity
* canon supports aweights and fweights
foreach spec in " " "[fw=weight]" "[aw=weight]" {
	foreach opt in " " ", nocons" {
		di
		di "Checking spec=`spec' opt=`op'"
		canon (profits wagetot) (govt taxnetx year wagegovt) `spec' `opt'
		mat canon=e(ccorr)
		ranktest (profits wagetot) (govt taxnetx year wagegovt) `spec' `opt'
		mat ccorr=r(rkmatrix)
		mat ccorr=ccorr[1..2,6]
		mat ccorr=ccorr'
		assert reldif(ccorr[1,1],canon[1,1]) < 1e-7
		assert reldif(ccorr[1,2],canon[1,2]) < 1e-7
	}
}

* Equality of rk statistic of null rank and Wald test from OLS regressions and suest.
* To show equality, use suest to test joint significance of Z variables in both
* regressions.  L.profits is the partialled-out variable and is not tested.   Note that
* suest introduces a finite sample adjustment of (N-1)/N.)
foreach spec in " " "[aw=weight]" {
	foreach opt in " " "nocons" {
		ranktest (profits wagetot)									///
			(govt taxnetx year wagegovt capital1 L.totinc) `spec',	///
			partial(L.profits) wald null robust `opt'
		scalar rkstat = r(chi2)*(r(N)-1)/r(N)
		regress profits govt taxnetx year wagegovt capital1			///
			L.totinc L.profits `spec', `opt'
		est store e1
		qui regress wagetot govt taxnetx year wagegovt capital1		///
			L.totinc L.profits `spec', `opt'
		est store e2
		qui suest e1 e2
		qui test	[e1_mean]govt [e1_mean]taxnetx [e1_mean]year		///
					[e1_mean]wagegovt [e1_mean]capital1					///
					[e1_mean]L.totinc
		    test	[e2_mean]govt [e2_mean]taxnetx [e2_mean]year		///
					[e2_mean]wagegovt [e2_mean]capital1					///
					[e2_mean]L.totinc, accum
		assert reldif(r(chi2), rkstat) < 1e-7
	}
}

* rk statistic as an LM / Sargan J statistic
qui ivreg2 consump L.profits (profits wagetot = govt taxnetx year wagegovt capital1 L.totinc), partial(L.profits) liml
scalar J=e(j)
cap drop ehat
predict double ehat, r
qui ivreg2 ehat L.profits govt taxnetx year wagegovt capital1 L.totinc
assert reldif(J, e(N)*e(r2)) < 1e-7
ranktest (consump profits wagetot) (govt taxnetx year wagegovt capital1 L.totinc), partial(L.profits) rr(1)
assert reldif(J, r(chi2)) < 1e-7

* rk stat as a Wald / Basmann statistic
qui ivreg2 ehat L.profits govt taxnetx year wagegovt capital1 L.totinc
test govt taxnetx year wagegovt capital1 L.totinc
scalar B=r(chi2)
ranktest (consump profits wagetot) (govt taxnetx year wagegovt capital1 L.totinc), partial(L.profits) rr(1) wald
assert reldif(B, r(chi2)) < 1e-7

* rk stat as a Cragg-Donald CUE-based robust J
ivreg2 consump L.profits (profits wagetot = govt taxnetx year wagegovt capital1 L.totinc), partial(L.profits) rob cue
scalar J=e(j)
ranktest (consump profits wagetot) (govt taxnetx year wagegovt capital1 L.totinc), partial(L.profits) rob jcue rr(1)
assert reldif(J, r(chi2)) < 1e-7

* KP as a J test in an artificial regression using LIML residuals
qui ivreg2 profits L.profits (wagetot = govt taxnetx year wagegovt capital1 L.totinc), liml
cap drop esample
cap drop ehat
cap drop Lprofits
cap drop Ltotinc
gen byte esample=e(sample)
gen Lprofits=L.profits
gen Ltotinc=L.totinc
predict double ehat, r
putmata Y=(wagetot) Z=(govt taxnetx year wagegovt capital1 Ltotinc) U=(ehat Lprofits 1) yr if esample, replace
mata: Ztilde = Z - U*invsym(U'U)*U'Z
mata: Yhat = Ztilde*invsym(Ztilde'Ztilde)*Ztilde'Y
getmata (wagetothat)=Yhat, id(yr) replace
qui ivreg2 ehat wagetothat L.profits (=govt taxnetx year wagegovt capital1), rob
scalar J=e(j)
ranktest (profits wagetot) (govt taxnetx year wagegovt capital1 L.totinc), partial(L.profits) rr(1) rob
assert reldif(J, r(chi2)) < 1e-7

* robust KP LM vs Wald
qui ivreg2 ehat wagetothat L.profits (=govt taxnetx year wagegovt capital1), rob
scalar J=e(j)
ranktest (profits wagetot) (govt taxnetx year wagegovt capital1 L.totinc), partial(L.profits) rr(1) rob
assert reldif(J, r(chi2)) < 1e-7
qui ivreg2 ehat wagetothat govt taxnetx year wagegovt capital1 L.profits, rob
test govt taxnetx year wagegovt capital1
scalar W=r(chi2)
ranktest (profits wagetot) (govt taxnetx year wagegovt capital1 L.totinc), partial(L.profits) rr(1) rob wald
assert reldif(W, r(chi2)) < 1e-7

* Equality of rk statistic and Wald test from OLS regression in special case
* of single regressor.
ranktest (profits) (govt taxnetx year wagegovt capital1 L.totinc), partial(L.profits) wald robust
scalar rkstat=r(chi2)
regress profits govt taxnetx year wagegovt capital1 L.totinc L.profits, robust
testparm govt taxnetx year wagegovt capital1 L.totinc
assert reldif(r(F)*r(df)*e(N)/e(df_r) , rkstat) < 1e-7

* Equality of rk statistic and LM test from OLS regression in special case
* of single regressor. Generate a group variable to illustrate cluster.
* Requires ivreg2.
gen clustvar = round(yr/2)
ranktest (profits) (govt taxnetx year wagegovt capital1 L.totinc), partial(L.profits) cluster(clustvar)
scalar rkstat=r(chi2)
ivreg2 profits L.profits (=govt taxnetx year wagegovt capital1 L.totinc), cluster(clustvar)
assert reldif(e(j) , rkstat) < 1e-7

* As above, but for combinations of robust and weights.
* aw and pw
foreach wt in " " "[aw=profits]" "[pw=profits]" {
	foreach vcv in " " "rob" "cluster(clustvar)" "bw(2)" "rob bw(2)" {
		di "options: wt=`wt' vcv=`vcv'"
		ranktest (profits) (govt taxnetx year wagegovt capital1 L.totinc) `wt', partial(L.profits) `vcv'
		scalar rkstat=r(chi2)
		ivreg2 profits L.profits (=govt taxnetx year wagegovt capital1 L.totinc) `wt', `vcv'
		assert reldif(e(j) , rkstat) < 1e-7
	}
}
* fw and iw
tsset, clear
foreach vcv in " " "rob" "cluster(clustvar)" {
	di "option: vcv=`vcv'"
	ranktest (profits) (govt taxnetx year wagegovt capital1) [fw=yr], `vcv'
	scalar rkstat=r(chi2)
	ivreg2 profits (=govt taxnetx year wagegovt capital1) [fw=yr], `vcv'
	assert reldif(e(j) , rkstat) < 1e-7
}

ranktest (profits) (govt taxnetx year wagegovt capital1) [iw=profits]
scalar rkstat=r(chi2)
ivreg2 profits (=govt taxnetx year wagegovt capital1) [iw=profits]
cap noi assert reldif(e(j) , rkstat) < 1e-7

* Bug fixed in ranktest 1.3.01 - 2-way cluster would crash if K>1
sysuse auto, clear
ranktest (price weight) (headroom trunk), cluster(turn trunk)


********************** misc options *********************************

// nostd - all results should be the same
// Canonical correlations, KP
foreach opt in "" "rob" "wald" "rob wald" {
	ranktest (price mpg foreign) (weight turn trunk), `opt'
	mat rkmatrix = r(rkmatrix)
	mat S = r(S)
	mat V = r(V)
	ranktest (price mpg foreign) (weight turn trunk), `opt' nostd
	assert mreldif(rkmatrix, r(rkmatrix)) < 1e-7
	assert mreldif(S, r(S)) < 1e-7
	assert mreldif(V, r(V)) < 1e-7
}
// jcue, jgmm2s
foreach opt in "jcue rob" "jgmm2s rob" "jcue rob wald" "jgmm2s rob wald" {
	ranktest (price mpg foreign) (weight turn trunk), `opt'
	mat rkmatrix = r(rkmatrix)
	ranktest (price mpg foreign) (weight turn trunk), `opt' nostd
	assert mreldif(rkmatrix, r(rkmatrix)) < 1e-7
}
// jcue, jgmm2s - single test of reduced rank, check beta and vcv
// requires noevorder; note looser tolerance
foreach opt in "jcue rob" "jgmm2s rob" "jcue rob wald" "jgmm2s rob wald" {
	ranktest (price mpg foreign) (weight turn trunk), rr(2) noevorder `opt'
	mat rkmatrix = r(rkmatrix)
	mat b = r(b)
	mat b0 = r(b0)
	mat V = r(V)
	mat S = r(S)
	ranktest (price mpg foreign) (weight turn trunk), rr(2) noevorder `opt' nostd
	assert mreldif(rkmatrix, r(rkmatrix)) < 1e-6
	assert mreldif(b, r(b)) < 1e-6
	assert mreldif(b0, r(b0)) < 1e-6
	assert mreldif(S, r(S)) < 1e-6
	assert mreldif(V, r(V)) < 1e-6
}

// noevorder (jcue only)
// check that saved basic results are the same
ranktest (price mpg foreign) (weight turn trunk), rob jcue
mat rkmatrix = r(rkmatrix)
ranktest (price mpg foreign) (weight turn trunk), rob jcue noevorder
assert mreldif(rkmatrix, r(rkmatrix)) < 1e-6
// check that ordering is the same independent of order of y vars
// do this via saved r(b) cue coefs; use rr(.) option
ranktest (price mpg foreign) (weight turn trunk), rob jcue rr(1)
mat b = r(b)
ranktest (mpg price foreign) (weight turn trunk), rob jcue rr(1)
assert mreldif(b, r(b)) < 1e-7
ranktest (mpg foreign price) (weight turn trunk), rob jcue rr(1)
assert mreldif(b, r(b)) < 1e-7
ranktest (foreign price mpg) (weight turn trunk), rob jcue rr(1)
assert mreldif(b, r(b)) < 1e-7

*********************************************************************

* saved beta and VCV if a single test of reduced rank

sysuse auto, clear

// if only one rank test and variant of J, beta saved
// use noevorder to preserve order of dep var and endog Xs
// confirm CUE beta matches ivreg2
// K=2, rr=1
ivreg2 price (mpg = weight turn trunk), partial(_cons) cue rob
mat b=e(b)
ranktest (price mpg) (weight turn trunk), rob jcue rr(1) noevorder
assert mreldif(b,r(b)) < 1e-7
ranktest (price mpg) (weight turn trunk), rob jcue rr(1) nostd noevorder
assert mreldif(b,r(b)) < 1e-7

// K=3, rr=1
ivreg2 price (mpg foreign = weight turn trunk), partial(_cons) cue rob
mat b=e(b)
ranktest (price mpg foreign) (weight turn trunk), rob jcue rr(1) noevorder
assert mreldif(b,r(b)) < 1e-7
ranktest (price mpg foreign) (weight turn trunk), rob jcue rr(1) nostd noevorder
assert mreldif(b,r(b)) < 1e-7

// K=3, rr=2. System CUE so can't use ivreg2 CUE
ranktest (price mpg foreign) (weight turn trunk), rob jcue rr(2) noevorder
mat b=r(b)
ranktest (price mpg foreign) (weight turn trunk), rob jcue rr(2) nostd noevorder
assert mreldif(b,r(b)) < 1e-7

// K=4, rr=2. System CUE so can't use ivreg2 CUE
ranktest (price mpg foreign disp) (weight turn trunk rep78), rob jcue rr(2) noevorder
mat b=r(b)
ranktest (price mpg foreign disp) (weight turn trunk rep78), rob jcue rr(2) nostd noevorder
assert mreldif(b,r(b)) < 1e-7

// requires center command
drop rep78
center price-foreign, double

gmm														///
	(c_mpg		- {b1}*c_foreign - {b3}*c_head)			///
	(c_price	- {b2}*c_foreign - {b4}*c_head)			///
	,													///
	instruments(c_weight c_turn c_trunk c_disp, nocons)	///
	wmatrix(robust)										///
	winitial(unadjusted, independent)					///
	vce(unadjusted)
mat b=e(b)
mat V=e(V)
ranktest (mpg price foreign head) (weight turn trunk disp), rob jgmm2s rr(2) noevorder nostd
assert mreldif(b,r(b)) < 1e-7
assert mreldif(V,r(V)) < 1e-7

*********************************************************************

* Legacy KP matrices
sysuse auto, clear

ranktest (price weight) (headroom trunk disp turn)
mat V=r(V)
mat S=r(S)
local Vrnames : rowfullnames V
local Vcnames : colfullnames V
local Srnames : rowfullnames S
local Scnames : colfullnames S
version 11: ranktest (price weight) (headroom trunk disp turn)
assert mreldif(V,r(V)) < 1e-7
assert mreldif(S,r(S)) < 1e-7
assert "`Vrnames'" == "`: rowfullnames r(V)'"
assert "`Vcnames'" == "`: colfullnames r(V)'"
assert "`Vrnames'" == "`: rowfullnames r(S)'"
assert "`Scnames'" == "`: colfullnames r(S)'"
ranktest (price weight) (headroom trunk disp turn), wald
mat V=r(V)
mat S=r(S)
local Vrnames : rowfullnames V
local Vcnames : colfullnames V
local Srnames : rowfullnames S
local Scnames : colfullnames S
version 11: ranktest (price weight) (headroom trunk disp turn), wald
assert mreldif(V,r(V)) < 1e-7
assert mreldif(S,r(S)) < 1e-7
assert "`Vrnames'" == "`: rowfullnames r(V)'"
assert "`Vcnames'" == "`: colfullnames r(V)'"
assert "`Vrnames'" == "`: rowfullnames r(S)'"
assert "`Scnames'" == "`: colfullnames r(S)'"
ranktest (price weight) (headroom trunk disp turn), kp rob
mat V=r(V)
mat S=r(S)
local Vrnames : rowfullnames V
local Vcnames : colfullnames V
local Srnames : rowfullnames S
local Scnames : colfullnames S
version 11: ranktest (price weight) (headroom trunk disp turn), rob
assert mreldif(V,r(V)) < 1e-7
assert mreldif(S,r(S)) < 1e-7
assert "`Vrnames'" == "`: rowfullnames r(V)'"
assert "`Vcnames'" == "`: colfullnames r(V)'"
assert "`Vrnames'" == "`: rowfullnames r(S)'"
assert "`Scnames'" == "`: colfullnames r(S)'"
ranktest (price weight) (headroom trunk disp turn), kp rob wald
mat V=r(V)
mat S=r(S)
local Vrnames : rowfullnames V
local Vcnames : colfullnames V
local Srnames : rowfullnames S
local Scnames : colfullnames S
version 11: ranktest (price weight) (headroom trunk disp turn), rob wald
assert mreldif(V,r(V)) < 1e-7
assert mreldif(S,r(S)) < 1e-7
assert "`Vrnames'" == "`: rowfullnames r(V)'"
assert "`Vcnames'" == "`: colfullnames r(V)'"
assert "`Vrnames'" == "`: rowfullnames r(S)'"
assert "`Scnames'" == "`: colfullnames r(S)'"



*********************************************************************

* Undocumented options
sysuse auto, clear
* iid case - kp, j2l, j2lr equivalent
ranktest (price weight) (headroom trunk disp turn)
mat rkmatrix=r(rkmatrix)
ranktest (price weight) (headroom trunk disp turn), j2l
assert mreldif(rkmatrix,r(rkmatrix)) < 1e-10
ranktest (price weight) (headroom trunk disp turn), j2lr
assert mreldif(rkmatrix,r(rkmatrix)) < 1e-10
* robust case - just confirm execution with no errors
ranktest (price weight) (headroom trunk disp turn), j2l rob
ranktest (price weight) (headroom trunk disp turn), j2lr rob
ranktest (price weight) (headroom trunk disp turn), jgmm2s rob

log close
set more on
set rmsg off
