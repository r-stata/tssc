* certification script for 
* lassopack package 1.1.03 14oct2019, MS

cscript rlasso adofile rlasso
clear all
capture log close
set more off
set rmsg on
program drop _all
log using cs_rlasso, replace
about
which rlasso
which lassoutils
// original code by CBH, modified to use quad precision etc.; not needed.
cap noi which lassoShootingCBH
cap noi which lassoClusterCBH

// Initial checks of rlasso are vs. CBH code.
// Other checks include equivalences that should hold in theory:
// 1. Partialling-out vs. unpenalized regressors.
// 2. Standardization "on the fly" (default) vs. pre-standardization of data.
// 3. Het-robust loadings vs. cluster-robust loadings with singleton clusters.
// 4. Fixed effects vs. unpenalized dummies.

// Currently uses Kiel-McClain 1995 housing/incinerator example dataset.
// Includes some badly-scaled variables so useful.
qui bcuse kielmc, clear
gen lcbd=ln(cbd)
gen lcbdsq=lcbd^2
gen byte one=1
gen n=_n
gen id=ceil(_n/10)


******************************************************************************
// Check vs. CBH code
// Note that as of lassoutils 1.1.01 08nov2018 we need to set the c0 option.

// homoskedastic
/*
lassoShootingCBH lrprice larea cbd intst lintst y81ldist lintstsq y81nrinc,	///
	het(0) verb(0) tolzero(1e-10) tolups(1e-10) ltol(1e-8) maxiter(10000)
mat CBHbetaL=r(betaL)'
mat CBHbetaPL=r(betaPL)'
scalar lambda=r(lambda)
local s = colsof(CBHbetaL)
*/
mat CBHbetaL	= .55033459 , .0958016  , .00259465
mat CBHbetaPL	= .65128713 , .15561146 , .01297576
scalar lambda	= 144.22858784
local s = 3
// Basic
rlasso lrprice larea cbd intst lintst y81ldist lintstsq y81nrinc,	///
	lalt corrnum(0) tolzero(1e-10) tolpsi(1e-10) tolopt(1e-8)		///
	maxiter(10000) c0(0.55)
mat b=e(b)
mat beta=e(beta)
mat betaOLS=e(betaOLS)
assert mreldif(b,beta)<1e-8
mat beta=beta[1,1..`s']
mat betaOLS=betaOLS[1,1..`s']
assert mreldif(beta,CBHbetaL)<1e-8
assert mreldif(betaOLS,CBHbetaPL)<1e-8
assert reldif(lambda,e(lambda0))<1e-8
// Partial-out constant
rlasso lrprice larea cbd intst lintst y81ldist lintstsq y81nrinc,	///
	lalt corrnum(0) partial(_cons) tolzero(1e-10) tolpsi(1e-10)		///
	tolopt(1e-8) maxiter(10000) c0(0.55)
mat b=e(b)
mat beta=e(beta)
mat betaOLS=e(betaOLS)
assert mreldif(b,beta)<1e-8
mat beta=beta[1,1..`s']
mat betaOLS=betaOLS[1,1..`s']
assert mreldif(beta,CBHbetaL)<1e-8
assert mreldif(betaOLS,CBHbetaPL)<1e-8
assert reldif(lambda,e(lambda0))<1e-8
// Include unpenalized constant by hand
// Needs high setting for maxpsiiter
// Also needs looser tolerance
rlasso lrprice larea cbd intst lintst y81ldist lintstsq y81nrinc one,	///
	lalt corrnum(0) tolzero(1e-10) tolpsi(1e-10) tolopt(1e-8)			///
	maxiter(10000) nocons pnotpen(one) maxpsiiter(10) c0(0.55)
mat b=e(b)
mat beta=e(beta)
mat betaOLS=e(betaOLS)
mat beta=beta[1,1..`s']
mat betaOLS=betaOLS[1,1..`s']
assert mreldif(beta,CBHbetaL)<1e-6			// higher tolerance
assert mreldif(betaOLS,CBHbetaPL)<1e-8
assert reldif(lambda,e(lambda0))<1e-8

******************************************************************************
// Check vs. CBH code

// With controls/pnotpen - note that controls do not appear in CBH X list
// Needs high setting for maxpsiiter

// Needs looser tolerance
/*
lassoShootingCBH lrprice intst lintst y81ldist lintstsq y81nrinc,	///
	het(0) verb(0) tolzero(1e-10) tolups(1e-10) ltol(1e-8) maxiter(10000) controls(larea cbd)
mat CBHbetaL=r(betaL)'
mat CBHbetaPL=r(betaPL)'
scalar lambda=r(lambda)
local s = colsof(CBHbetaL)
*/
mat CBHbetaL	= .04572585 , .00175637
mat CBHbetaPL	= .20415454 , .01272592
scalar lambda	= 140.55736231
local s = 2
// pnotpen
rlasso lrprice larea cbd intst lintst y81ldist lintstsq y81nrinc,	///
	lalt corrnum(0) partial(_cons) tolzero(1e-10) tolpsi(1e-10)		///
	tolopt(1e-8) maxiter(10000) maxpsiiter(10) pnotpen(larea cbd)	///
	c0(0.55)
mat b=e(b)
mat beta=e(beta)
mat betaOLS=e(betaOLS)
assert mreldif(b,beta)<1e-8
// trim
mat beta=beta[1,3..4]
mat betaOLS=betaOLS[1,3..4]
local s = colsof(CBHbetaL) 
forvalues i=1/`s' {
	assert reldif(CBHbetaL[1,`i'],beta[1,`i'])<1e-6
	assert reldif(CBHbetaPL[1,`i'],betaOLS[1,`i'])<1e-6
}
assert reldif(lambda,e(lambda0))<1e-8
// partial
rlasso lrprice larea cbd intst lintst y81ldist lintstsq y81nrinc,	///
	lalt corrnum(0) tolzero(1e-10) tolpsi(1e-10) tolopt(1e-8)		///
	maxiter(10000) maxpsiiter(10) partial(larea cbd)
mat b=e(b)
mat beta=e(beta)
mat betaOLS=e(betaOLS)
assert mreldif(b,beta)<1e-8
// trim
mat beta=beta[1,1..2]
mat betaOLS=betaOLS[1,1..2]
local s = colsof(CBHbetaL) 
forvalues i=1/`s' {
	assert reldif(CBHbetaL[1,`i'],beta[1,`i'])<1e-8
	assert reldif(CBHbetaPL[1,`i'],betaOLS[1,`i'])<1e-8
}
assert reldif(lambda,e(lambda0))<1e-8

******************************************************************************
// Check vs CBH code

// heteroskedastic
/*
lassoShootingCBH lrprice larea cbd intst lintst y81ldist lintstsq y81nrinc,	///
	het(1) verb(0) tolzero(1e-10) tolups(1e-10) ltol(1e-8) maxiter(10000)
mat CBHbetaL=r(betaL)'
mat CBHbetaPL=r(betaPL)'
scalar lambda=r(lambda)
local s = colsof(CBHbetaL)
*/
mat CBHbetaL	= .52823835 , .09894578 , .0030307
mat CBHbetaPL	= .65128713 , .15561146 , .01297576
scalar lambda	= 144.22858784
local s = 3
// Basic
rlasso lrprice larea cbd intst lintst y81ldist lintstsq y81nrinc,	///
	rob lalt corrnum(0) tolzero(1e-10) tolpsi(1e-10) tolopt(1e-8)	///
	maxiter(10000) c0(0.55)
mat b=e(b)
mat beta=e(beta)
mat betaOLS=e(betaOLS)
assert mreldif(b,beta)<1e-8
forvalues i=1/`s' {
	assert reldif(CBHbetaL[1,`i'],beta[1,`i'])<1e-8
	assert reldif(CBHbetaPL[1,`i'],betaOLS[1,`i'])<1e-8
}
assert reldif(lambda,e(lambda0))<1e-8
// partial-out cons
rlasso lrprice larea cbd intst lintst y81ldist lintstsq y81nrinc,	///
	rob lalt corrnum(0) partial(_cons) tolzero(1e-10) tolpsi(1e-10) tolopt(1e-8) maxiter(10000) c0(0.55)
mat b=e(b)
mat beta=e(beta)
mat betaOLS=e(betaOLS)
assert mreldif(b,beta)<1e-8
local s = colsof(CBHbetaL) 
forvalues i=1/`s' {
	assert reldif(CBHbetaL[1,`i'],beta[1,`i'])<1e-8
	assert reldif(CBHbetaPL[1,`i'],betaOLS[1,`i'])<1e-8
}
assert reldif(lambda,e(lambda0))<1e-8

// With controls/pnotpen - note that controls do not appear in CBH X list
/*
lassoShootingCBH lrprice intst lintst y81ldist lintstsq y81nrinc,	///
	het(1) verb(0) tolzero(1e-10) tolups(1e-10) ltol(1e-8) maxiter(10000) controls(larea cbd)
mat CBHbetaL=r(betaL)'
mat CBHbetaPL=r(betaPL)'
scalar lambda=r(lambda)
*/
mat CBHbetaL	= .01229867 , .00161341
mat CBHbetaPL	= .20415454 , .01272592
scalar lambda	= 140.55736231
local s = 2
// pnotpen
rlasso lrprice larea cbd intst lintst y81ldist lintstsq y81nrinc,	///
	rob lalt corrnum(0) partial(_cons) tolzero(1e-10) tolpsi(1e-10) tolopt(1e-8) maxiter(10000) pnotpen(larea cbd) c0(0.55)
mat b=e(b)
mat beta=e(beta)
mat betaOLS=e(betaOLS)
assert mreldif(b,beta)<1e-8
// trim
mat beta=beta[1,3..4]
mat betaOLS=betaOLS[1,3..4]
forvalues i=1/`s' {
	assert reldif(CBHbetaL[1,`i'],beta[1,`i'])<1e-6
	assert reldif(CBHbetaPL[1,`i'],betaOLS[1,`i'])<1e-6
}
assert reldif(lambda,e(lambda0))<1e-8
// partial
rlasso lrprice larea cbd intst lintst y81ldist lintstsq y81nrinc,	///
	rob lalt corrnum(0) tolzero(1e-10) tolpsi(1e-10) tolopt(1e-8) maxiter(10000) partial(larea cbd) c0(0.55)
mat b=e(b)
mat beta=e(beta)
mat betaOLS=e(betaOLS)
assert mreldif(b,beta)<1e-8
// trim
mat beta=beta[1,1..2]
mat betaOLS=betaOLS[1,1..2]
local s = colsof(CBHbetaL) 
forvalues i=1/`s' {
	assert reldif(CBHbetaL[1,`i'],beta[1,`i'])<1e-8
	assert reldif(CBHbetaPL[1,`i'],betaOLS[1,`i'])<1e-8
}
assert reldif(lambda,e(lambda0))<1e-8

********************** CLUSTER *********************************
// Check vs CBH code
// Update 4 Apr 2018:
//   CBH cluster code lambda = 2.2*sqrt(nclust)*invnorm(1-(.1/log(nclust))/(2p))
//   JBES paper and updated rlasso use 2,2*sqrt(n)*invnorm,
//   i.e., same as standard lasso. Comparisons with CBH lambda commented out.

// clustering (note no lalt required)
// note center and maxupsiter are required to match CBH code
/*
lassoClusterCBH lrprice larea cbd intst lintst y81ldist lintstsq y81nrinc,	///
	cluster(age) verb(0) tolzero(1e-10) tolups(1e-10) ltol(1e-8) maxiter(10000)
mat CBHbetaL=r(betaL)'
mat CBHbetaPL=r(betaPL)'
scalar lambda=r(lambda)
*/
mat CBHbetaL	= .46261782 , .11510062
mat CBHbetaPL	= .68488126 , .15090246
scalar lambda	= 50.21173664
local s = 2
// Basic
// need nclust1 option to replicate CBH
rlasso lrprice larea cbd intst lintst y81ldist lintstsq y81nrinc,	///
	cluster(age) center corrnum(0) nclust1							///
	tolzero(1e-10) tolpsi(1e-10) tolopt(1e-8)						///
	maxiter(10000) maxpsiiter(10) c0(0.55)
mat b=e(b)
mat beta=e(beta)
mat betaOLS=e(betaOLS)
assert mreldif(b,beta)<1e-8
forvalues i=1/`s' {
	assert reldif(CBHbetaL[1,`i'],beta[1,`i'])<1e-8
	assert reldif(CBHbetaPL[1,`i'],betaOLS[1,`i'])<1e-8
}
// assert reldif(lambda,e(lambda0))<1e-8
// partial-out cons
// need nclust1 option to replicate CBH
rlasso lrprice larea cbd intst lintst y81ldist lintstsq y81nrinc,	///
	cluster(age) center corrnum(0) nclust1							///
	partial(_cons) tolzero(1e-10) tolpsi(1e-10) tolopt(1e-8)		///
	maxiter(10000) maxpsiiter(10) c0(0.55)
mat b=e(b)
mat beta=e(beta)
mat betaOLS=e(betaOLS)
assert mreldif(b,beta)<1e-8
forvalues i=1/`s' {
	assert reldif(CBHbetaL[1,`i'],beta[1,`i'])<1e-8
	assert reldif(CBHbetaPL[1,`i'],betaOLS[1,`i'])<1e-8
}
// assert reldif(lambda,e(lambda0))<1e-8

// With controls/pnotpen - note that controls do not appear in CBH X list
/*
lassoClusterCBH lrprice intst lintst y81ldist lintstsq y81nrinc,	///
	cluster(age) verb(0) tolzero(1e-10) tolups(1e-10) ltol(1e-8) maxiter(10000) controls(larea cbd)
mat CBHbetaL=r(betaL)'
mat CBHbetaPL=r(betaPL)'
scalar lambda=r(lambda)
*/
mat CBHbetaL	= .00552125 , .00301795
mat CBHbetaPL	= .01283716 , .01236437
scalar lambda	= 48.38313172
local s = 2
// pnotpen
// need nclust1 option to replicate CBH
rlasso lrprice larea cbd intst lintst y81ldist lintstsq y81nrinc,	///
	cluster(age) center corrnum(0) nclust1							///
	tolzero(1e-10) tolpsi(1e-10) tolopt(1e-8) maxiter(10000)		///
	pnotpen(larea cbd) maxpsiiter(10) c0(0.55)
mat b=e(b)
mat beta=e(beta)
mat betaOLS=e(betaOLS)
assert mreldif(b,beta)<1e-8
// trim
mat beta=beta[1,3..4]
mat betaOLS=betaOLS[1,3..4]
forvalues i=1/`s' {
	assert reldif(CBHbetaL[1,`i'],beta[1,`i'])<1e-6
	assert reldif(CBHbetaPL[1,`i'],betaOLS[1,`i'])<1e-6
}
// assert reldif(lambda,e(lambda0))<1e-8
// partial
// need nclust1 option to replicate CBH
rlasso lrprice larea cbd intst lintst y81ldist lintstsq y81nrinc,	///
	cluster(age) center corrnum(0) nclust1							///
	tolzero(1e-10) tolpsi(1e-10) tolopt(1e-8) maxiter(10000)		///
	partial(larea cbd) maxpsiiter(10) c0(0.55)
mat b=e(b)
mat beta=e(beta)
mat betaOLS=e(betaOLS)
assert mreldif(b,beta)<1e-8
// trim
mat beta=beta[1,1..2]
mat betaOLS=betaOLS[1,1..2]
forvalues i=1/`s' {
	assert reldif(CBHbetaL[1,`i'],beta[1,`i'])<1e-8
	assert reldif(CBHbetaPL[1,`i'],betaOLS[1,`i'])<1e-8
}
// assert reldif(lambda,e(lambda0))<1e-8


********************** CLUSTER+FE *********************************
// Check vs. CBH code.

xtset age
// clustering (note no lalt required) + fixed effects
// note center and maxpsiiter are required to match CBH code
/*
lassoClusterCBH lrprice larea cbd intst lintst y81ldist lintstsq y81nrinc,	///
	cluster(age) fix(age) verb(0) tolzero(1e-10) tolups(1e-10) ltol(1e-8) maxiter(10000)
mat CBHbetaL=r(betaL)'
mat CBHbetaPL=r(betaPL)'
scalar lambda=r(lambda)
*/
mat CBHbetaL	= .38441642 , .00767435
mat CBHbetaPL	= .53696874 , .01285201
scalar lambda	= 50.21173664
local s = 2
// Basic
// need nclust1 option to replicate CBH
rlasso lrprice larea cbd intst lintst y81ldist lintstsq y81nrinc,	///
	cluster(age) fe center corrnum(0) nclust1						///
	tolzero(1e-10) tolpsi(1e-10) tolopt(1e-8)						///
	maxiter(10000) maxpsiiter(10) c0(0.55)
mat b=e(b)
mat beta=e(beta)
mat betaOLS=e(betaOLS)
assert mreldif(b,beta)<1e-8
forvalues i=1/`s' {
	assert reldif(CBHbetaL[1,`i'],beta[1,`i'])<1e-8
	assert reldif(CBHbetaPL[1,`i'],betaOLS[1,`i'])<1e-8
}
// assert reldif(lambda,e(lambda0))<1e-8

// With controls/pnotpen - note that controls do not appear in CBH X list
/*
lassoClusterCBH lrprice intst lintst y81ldist lintstsq y81nrinc,	///
	cluster(age) fix(age) verb(0) tolzero(1e-10) tolups(1e-10) ltol(1e-8) maxiter(10000) controls(larea cbd)
mat CBHbetaL=r(betaL)'
mat CBHbetaPL=r(betaPL)'
scalar lambda=r(lambda)
*/
mat CBHbetaL	= .00308359
mat CBHbetaPL	= .01266582
scalar lambda	= 48.38313172
local s = 1
// pnotpen
// need nclust1 option to replicate CBH
rlasso lrprice larea cbd intst lintst y81ldist lintstsq y81nrinc,	///
	cluster(age) fe center corrnum(0) nclust1						///
	tolzero(1e-10) tolpsi(1e-10) tolopt(1e-8) maxiter(10000)		///
	pnotpen(larea cbd) maxpsiiter(10) c0(0.55)
mat b=e(b)
mat beta=e(beta)
mat betaOLS=e(betaOLS)
assert mreldif(b,beta)<1e-8
// trim
mat beta=beta[1,3..3]
mat betaOLS=betaOLS[1,3..3]
forvalues i=1/`s' {
	assert reldif(CBHbetaL[1,`i'],beta[1,`i'])<1e-6
	assert reldif(CBHbetaPL[1,`i'],betaOLS[1,`i'])<1e-6
}
// assert reldif(lambda,e(lambda0))<1e-8
// partial
// need nclust1 option to replicate CBH
rlasso lrprice larea cbd intst lintst y81ldist lintstsq y81nrinc,	///
	cluster(age) fe center corrnum(0) nclust1						///
	tolzero(1e-10) tolpsi(1e-10) tolopt(1e-8) maxiter(10000)		///
	partial(larea cbd) maxpsiiter(10) c0(0.55)
mat b=e(b)
mat beta=e(beta)
mat betaOLS=e(betaOLS)
assert mreldif(b,beta)<1e-8
// trim
mat beta=beta[1,1..1]
mat betaOLS=betaOLS[1,1..1]
forvalues i=1/`s' {
	assert reldif(CBHbetaL[1,`i'],beta[1,`i'])<1e-8
	assert reldif(CBHbetaPL[1,`i'],betaOLS[1,`i'])<1e-8
}
// assert reldif(lambda,e(lambda0))<1e-8

***************************************************************
// Equivalence check

// Robust vs. singleton clusters - should match
rlasso lrprice larea cbd intst lintst y81ldist lintstsq y81nrinc,	///
	rob tolzero(1e-10) tolpsi(1e-10) tolopt(1e-8) maxiter(10000) maxpsiiter(10)
savedresults save rob e()
rlasso lrprice larea cbd intst lintst y81ldist lintstsq y81nrinc,	///
	cluster(n) tolzero(1e-10) tolpsi(1e-10) tolopt(1e-8) maxiter(10000) maxpsiiter(10)
savedresults comp rob e(), exclude(macro: robust cluster)  tol(1e-8)

// center option
rlasso lrprice larea cbd intst lintst y81ldist lintstsq y81nrinc,	///
	rob center tolzero(1e-10) tolpsi(1e-10) tolopt(1e-8) maxiter(10000) maxpsiiter(10)
savedresults save rob e()
rlasso lrprice larea cbd intst lintst y81ldist lintstsq y81nrinc,	///
	cluster(n) center tolzero(1e-10) tolpsi(1e-10) tolopt(1e-8) maxiter(10000) maxpsiiter(10)
savedresults comp rob e(), exclude(macro: robust cluster)  tol(1e-8)

// partial and pnotpen
// with constant
rlasso lrprice larea cbd intst lintst y81ldist lintstsq y81nrinc,	///
	partial(lintst y81ldist)
savedresults save partial e()
rlasso lrprice larea cbd intst lintst y81ldist lintstsq y81nrinc,	///
	pnotpen(lintst y81ldist)
savedresults comp partial e(), exclude(								///
		macro: pnotpen partial varXmodel							///
		scalar: niter pminus pnotpen_ct partial_ct					///
		matrix: betaAll betaAllOLS Psi ePsi sPsi					/// order/components differ
		)  tol(1e-8)
// with constant + prestd
rlasso lrprice larea cbd intst lintst y81ldist lintstsq y81nrinc,	///
	partial(lintst y81ldist) prestd
savedresults save partial e()
rlasso lrprice larea cbd intst lintst y81ldist lintstsq y81nrinc,	///
	pnotpen(lintst y81ldist) prestd
savedresults comp partial e(), exclude(								///
		macro: pnotpen partial varXmodel							///
		scalar: niter pminus pnotpen_ct partial_ct					///
		matrix: betaAll betaAllOLS Psi ePsi sPsi					/// order/components differ
		)  tol(1e-8)
// with constant + sqrt
rlasso lrprice larea cbd intst lintst y81ldist lintstsq y81nrinc,	///
	partial(lintst y81ldist) sqrt
savedresults save partial e()
rlasso lrprice larea cbd intst lintst y81ldist lintstsq y81nrinc,	///
	pnotpen(lintst y81ldist) sqrt
savedresults comp partial e(), exclude(								///
		macro: pnotpen partial varXmodel							///
		scalar: niter pminus pnotpen_ct partial_ct					///
		matrix: betaAll betaAllOLS Psi ePsi sPsi					/// order/components differ
		)  tol(1e-8)
// nocons - need an easier minimization
rlasso lrprice nbh rooms baths y81 nearinc y81nrinc,				///
	partial(nearinc y81nrinc) nocons
savedresults save partial e()
rlasso lrprice nbh rooms baths y81 nearinc y81nrinc,				///
	pnotpen(nearinc y81nrinc) nocons
savedresults comp partial e(), exclude(								///
		macro: pnotpen partial varXmodel							///
		scalar: niter pminus pnotpen_ct partial_ct					///
		matrix: betaAll betaAllOLS Psi ePsi sPsi					/// order/components differ
		)  tol(1e-8)
// nocons + prestd
rlasso lrprice nbh rooms baths y81 nearinc y81nrinc,				///
	partial(nearinc y81nrinc) nocons prestd
savedresults save partial e()
rlasso lrprice nbh rooms baths y81 nearinc y81nrinc,				///
	pnotpen(nearinc y81nrinc) nocons prestd
savedresults comp partial e(), exclude(								///
		macro: pnotpen partial varXmodel							///
		scalar: niter pminus pnotpen_ct partial_ct					///
		matrix: betaAll betaAllOLS Psi ePsi sPsi					/// order/components differ
		)  tol(1e-8)
// nocons + sqrt
rlasso lrprice nbh rooms baths y81 nearinc y81nrinc,				///
	partial(nearinc y81nrinc) nocons sqrt
savedresults save partial e()
rlasso lrprice nbh rooms baths y81 nearinc y81nrinc,				///
	pnotpen(nearinc y81nrinc) nocons sqrt
savedresults comp partial e(), exclude(								///
		macro: pnotpen partial varXmodel							///
		scalar: niter pminus pnotpen_ct partial_ct					///
		matrix: betaAll betaAllOLS Psi ePsi sPsi					/// order/components differ
		)  tol(1e-8)

********************** FE ONLY *********************************
// Equivalence check

// fe vs. explicit dummies
xtset age
rlasso lrprice larea cbd intst lintst y81ldist lintstsq y81nrinc,	///
	fe tolzero(1e-10) tolpsi(1e-10) tolopt(1e-8) maxiter(10000) maxpsiiter(10)
mat b=e(b)
mat beta=e(beta)
mat betaOLS=e(betaOLS)
rlasso lrprice larea cbd intst lintst y81ldist lintstsq y81nrinc i.age,	///
	partial(i.age) tolzero(1e-10) tolpsi(1e-10) tolopt(1e-8) maxiter(10000) maxpsiiter(10)
mat btemp=(el(e(b),1,1), el(e(b),1,2))
assert mreldif(b,btemp)<1e-8
mat btemp=(el(e(beta),1,1), el(e(beta),1,2))
assert mreldif(beta,btemp)<1e-8
mat btemp=(el(e(betaOLS),1,1), el(e(betaOLS),1,2))
assert mreldif(betaOLS,btemp)<1e-8

// Controls vs pnotpen
xtset age
rlasso lrprice larea cbd intst lintst y81ldist lintstsq y81nrinc,	///
	fe partial(larea cbd) tolzero(1e-10) tolpsi(1e-10) tolopt(1e-8)
mat b=e(b)
mat beta=e(beta)
mat betaOLS=e(betaOLS)
rlasso lrprice larea cbd intst lintst y81ldist lintstsq y81nrinc,	///
	fe pnotpen(larea cbd) tolzero(1e-10) tolpsi(1e-10) tolopt(1e-8)
mat btemp=e(b)
assert reldif(b[1,1],btemp[1,3])<1e-8
assert reldif(b[1,2],btemp[1,1])<1e-8
assert reldif(b[1,3],btemp[1,2])<1e-8
mat btemp=e(beta)
assert reldif(beta[1,1],btemp[1,3])<1e-8
assert reldif(beta[1,2],btemp[1,1])<1e-8
assert reldif(beta[1,3],btemp[1,2])<1e-8
mat btemp=e(betaOLS)
assert reldif(betaOLS[1,1],btemp[1,3])<1e-8
assert reldif(betaOLS[1,2],btemp[1,1])<1e-8
assert reldif(betaOLS[1,3],btemp[1,2])<1e-8

// noftools option
rlasso lrprice larea cbd intst lintst y81ldist lintstsq y81nrinc, fe
savedresults save ftools e()
cap noi assert "`e(noftools)'"==""  // will be error if ftools not installed
rlasso lrprice larea cbd intst lintst y81ldist lintstsq y81nrinc, fe noftools
assert "`e(noftools)'"=="noftools"
savedresults comp ftools e(), tol(1e-10)

********************** Standardization **************************

foreach opt in " " "sqrt" {
	rlasso lrprice larea cbd intst lintst y81ldist lintstsq y81nrinc, rob `opt'
	savedresults save nostd e()
	rlasso lrprice larea cbd intst lintst y81ldist lintstsq y81nrinc, prestd rob `opt'
	savedresults comp nostd e(), exclude(scalar: niter matrix: Psi) tol(1e-8)

	rlasso lrprice larea lintst y81ldist lintstsq y81nrinc, rob `opt' pnotpen(larea lintst)
	savedresults save nostd e()
	rlasso lrprice larea lintst y81ldist lintstsq y81nrinc, prestd rob `opt' pnotpen(larea lintst)
	savedresults comp nostd e(), exclude(scalar: niter matrix: Psi) tol(1e-8)

	rlasso lrprice larea lintst y81ldist lintstsq y81nrinc, rob `opt' partial(larea lintst)
	savedresults save nostd e()
	rlasso lrprice larea lintst y81ldist lintstsq y81nrinc, prestd rob `opt' partial(larea lintst)
	savedresults comp nostd e(), exclude(scalar: niter matrix: Psi) tol(1e-8)

	// note that some coefs have been removed to make it easier for sqrt-lasso
	xtset id
	rlasso lrprice larea lintst y81ldist, rob `opt' fe
	savedresults save nostd e()
	rlasso lrprice larea lintst y81ldist, prestd rob `opt' fe
	savedresults comp nostd e(), exclude(scalar: niter matrix: Psi) tol(1e-8)

	xtset id
	rlasso lrprice larea lintst y81ldist, rob `opt' fe pnotpen(larea)
	savedresults save nostd e()
	rlasso lrprice larea lintst y81ldist, prestd rob `opt' fe pnotpen(larea)
	savedresults comp nostd e(), exclude(scalar: niter matrix: Psi) tol(1e-8)

	xtset id
	rlasso lrprice larea lintst y81ldist, rob `opt' fe partial(larea)
	savedresults save nostd e()
	rlasso lrprice larea lintst y81ldist, prestd rob `opt' fe partial(larea)
	savedresults comp nostd e(), exclude(scalar: niter matrix: Psi) tol(1e-8)
}

********************** Misc options **************************

// Confirm these don't crash it and that post-lasso is the same.
// Lasso est may differ because of slightly different lambda.
mat betaOLS	= .65128713 , .15561146 , .01297576 , 4.7817721
foreach opt in	tolopt(1e-8) tolpsi(1e-3) tolzero(1e-3)	///
				maxiter(1000) maxpsiiter(5)				///
				lassopsi corrn(3) corrn(0)				///
				c(1.05) gamma(0.05) gammad(1)			///
				{
	di "opt=`opt'"
	rlasso lrprice larea cbd intst lintst y81ldist lintstsq y81nrinc, `opt' rob
	assert mreldif(betaOLS,e(betaOLS))<1e-8
}

// xdep option - standard lasso
// NB: update of values for lassoutils 1.1.01 8nov2018
// benchmark - homoskedastic, no xdep
rlasso lrprice larea cbd intst lintst y81ldist lintstsq y81nrinc
mat betaOLS = e(betaOLS)
// xdep, homoskedastic
// uses multiplier bootstrap so set seed for replicability
rlasso lrprice larea cbd intst lintst y81ldist lintstsq y81nrinc, xdep seed(1)
assert mreldif(betaOLS,e(betaOLS))<1e-8
assert reldif(e(lambda0),114.432846013)<1e-8
assert reldif(el(e(beta),1,1),0.571190061895)<1e-8
// benchmark - heteroskedastic, no xdep
rlasso lrprice larea cbd intst lintst y81ldist lintstsq y81nrinc, rob
mat betaOLS = e(betaOLS)
// xdep, heteroskedastic
// uses multiplier bootstrap so set seed for replicability
rlasso lrprice larea cbd intst lintst y81ldist lintstsq y81nrinc, xdep rob seed(1)
assert mreldif(betaOLS,e(betaOLS))<1e-8
assert reldif(e(lambda0),112.94387827)<1e-8
assert reldif(el(e(beta),1,1),0.554928934936)<1e-8
// benchmark - cluster, no xdep
rlasso lrprice larea cbd intst lintst y81ldist lintstsq y81nrinc, cluster(id)
mat betaOLS = e(betaOLS)
// xdep, cluster
// uses multiplier bootstrap so set seed for replicability
rlasso lrprice larea cbd intst lintst y81ldist lintstsq y81nrinc, xdep cluster(id) seed(1)
assert mreldif(betaOLS,e(betaOLS))<1e-8
assert reldif(e(lambda0),108.22341837697)<1e-8
assert reldif(el(e(beta),1,1),0.571588016862)<1e-8

// xdep option - sqrt-lasso
// NB: introduced with update of lassoutils 1.1.01 8nov2018
// benchmark - homoskedastic, no xdep
rlasso lrprice larea cbd intst lintst y81ldist lintstsq y81nrinc, sqrt
mat betaOLS = e(betaOLS)
// xdep, homoskedastic
// uses multiplier bootstrap so set seed for replicability
rlasso lrprice larea cbd intst lintst y81ldist lintstsq y81nrinc, xdep seed(1) sqrt
assert mreldif(betaOLS,e(betaOLS))<1e-8
assert reldif(e(lambda0),57.107312563841)<1e-8
assert reldif(el(e(beta),1,1),0.568200965628)<1e-8
// benchmark - heteroskedastic, no xdep
rlasso lrprice larea cbd intst lintst y81ldist lintstsq y81nrinc, rob sqrt
mat betaOLS = e(betaOLS)
// xdep, heteroskedastic
// uses multiplier bootstrap so set seed for replicability
rlasso lrprice larea cbd intst lintst y81ldist lintstsq y81nrinc, xdep rob seed(1) sqrt
assert mreldif(betaOLS,e(betaOLS))<1e-8
assert reldif(e(lambda0),55.179713611581)<1e-8
assert reldif(el(e(beta),1,1),0.554027632301)<1e-8
// benchmark - cluster, no xdep
rlasso lrprice larea cbd intst lintst y81ldist lintstsq y81nrinc, cluster(id) sqrt
mat betaOLS = e(betaOLS)
// xdep, cluster
// uses multiplier bootstrap so set seed for replicability
rlasso lrprice larea cbd intst lintst y81ldist lintstsq y81nrinc, xdep cluster(id) seed(1) sqrt
assert mreldif(betaOLS,e(betaOLS))<1e-8
assert reldif(e(lambda0),51.922234705643)<1e-8
assert reldif(el(e(beta),1,1),0.571322946179)<1e-8

// supscore option
// uses multiplier bootstrap so set seed for replicability
// update for lassoutils 1.1.01 8nov2018 - now sqrt(n)*L instead of n*L
// set seed for null
set seed 1
gen double ynull=rnormal()
// homoskedastic
rlasso ynull cbd intst lintst y81ldist lintstsq y81nrinc, testonly seed(1)
assert reldif(e(supscore),1.7293626410)<1e-8
assert reldif(e(supscore_p),0.242)<1e-8
assert reldif(e(supscore_cv),2.9020830008)<1e-8
// critical value for gamma=10%
rlasso ynull cbd intst lintst y81ldist lintstsq y81nrinc, testonly ssgamma(0.1) seed(1)
assert reldif(e(supscore_cv),2.63337777980)<1e-8
// heteroskedastic
rlasso ynull cbd intst lintst y81ldist lintstsq y81nrinc, testonly rob seed(1)
assert reldif(e(supscore),1.736085668840)<1e-8
assert reldif(e(supscore_p),0.238)<1e-8
assert reldif(e(supscore_cv),2.9020830008)<1e-8
// clustered
rlasso ynull cbd intst lintst y81ldist lintstsq y81nrinc, testonly cluster(id) seed(1)
assert reldif(e(supscore),1.833764450629)<1e-8
assert reldif(e(supscore_p),0.218)<1e-8
assert reldif(e(supscore_cv),2.9020830008)<1e-8

********************** Prediction *********************

// loop through options
rlasso lrprice larea cbd intst lintst y81ldist lintstsq y81nrinc
foreach option in "xb" "xb lasso" "xb ols" "resid" "resid lasso" "resid ols" {
	cap drop newvar
	di "option=`option'"
	predict double newvar, `option'
}
rlasso lrprice larea cbd intst lintst y81ldist lintstsq y81nrinc, fe
foreach option in "ue" "e" {
	cap drop newvar
	di "option=`option'"
	predict double newvar, `option'
}
// resids should be mean zero
rlasso lrprice larea cbd intst lintst y81ldist lintstsq y81nrinc
foreach option in " " "lasso" "ols" {
	cap drop resid
	predict double resid, resid `option'
	qui sum resid, meanonly
	assert r(mean)<1e-8
}
rlasso lrprice larea cbd intst lintst y81ldist lintstsq y81nrinc, fe
foreach option in "u" "e" "ue" {
	cap drop resid
	predict double resid, `option'
	qui sum resid, meanonly
	assert r(mean)<1e-8
}
// mean of predicted yhat = mean of y
rlasso lrprice larea cbd intst lintst y81ldist lintstsq y81nrinc
qui sum lrprice, meanonly
local ymean `r(mean)'
foreach option in " " "lasso" "ols" {
	cap drop yhat
	predict double yhat, xb
	qui sum yhat, meanonly
	assert r(mean)-`ymean'<1e-8
}
// confirm post-lasso OLS matches regress
rlasso lrprice larea cbd intst lintst y81ldist lintstsq y81nrinc
local selected `e(selected)'
cap drop xb_rlasso
cap drop resid_rlasso
predict double xb_rlasso, xb ols
predict double resid_rlasso, resid ols
regress lrprice `selected'
cap drop xb_regress
cap drop resid_regress
predict double xb_regress, xb
predict double resid_regress, resid
assert reldif(xb_rlasso,xb_regress) < 1e-6
assert reldif(resid_rlasso,resid_regress) < 1e-6
// confirm post-lasso LSDV matches xtreg,fe
foreach opt in xb u e ue xbu {
	cap drop `opt'hat_rlasso
	cap drop `opt'hat_xtreg
}
rlasso lrprice larea cbd intst lintst y81ldist lintstsq y81nrinc, fe
local selected `e(selected)'
foreach opt in xb u e ue xbu {
	predict double `opt'hat_rlasso, ols `opt'
}
xtreg lrprice `selected', fe
foreach opt in xb u e ue xbu {
	predict double `opt'hat_xtreg, `opt'
}
foreach opt in xb u e ue xbu {
	di "checking option `opt'
	assert reldif(`opt'hat_rlasso, `opt'hat_xtreg) < 1e-6
}


**************** Weights *********************

cap drop one
cap drop wt
gen double one=1
// use a non-integer weight
global wtvar lcbdsq
gen double wt=$wtvar
// assumes no missings for any regressors or dep var
sum wt
replace wt = wt * 1/r(mean)

* Basic estimation with constant and no partialling etc.
* w_c_ vars are centered (demeaned using weighted means)
* and then weighted by the sqrt of the weighting var.

cap drop w_*
* weighted centering (so no intercept)
foreach var of varlist lrprice larea cbd intst lintst y81ldist lintstsq y81nrinc {
	qui sum `var' [aw=wt], meanonly
	gen double w_c_`var' = (`var'-r(mean))*sqrt(wt)
}

global vlist lrprice larea cbd intst lintst y81ldist lintstsq y81nrinc
global w_c_vlist w_c_lrprice w_c_larea w_c_cbd w_c_intst w_c_lintst w_c_y81ldist w_c_lintstsq w_c_y81nrinc

// disallowed options
cap noi rlasso $vlist [aw=$wtvar], nocons
assert _rc==198

foreach opt in "" "rob" {
	// cons automatically partialled out
	rlasso $vlist [aw=$wtvar], `opt'
	mat b=e(beta)
	mat bOLS=e(betaOLS)
	rlasso $vlist [aw=$wtvar], prestd `opt'
	assert mreldif(e(beta),b)<1e-8
	assert mreldif(e(betaOLS),bOLS)<1e-8
	// no constant to compare
	mat b=b[1,1..colsof(b)-1]
	mat bOLS=bOLS[1,1..colsof(bOLS)-1]
	// use dm and nocons
	rlasso $w_c_vlist, dm nocons `opt'
	assert mreldif(e(beta),b)<1e-8
	assert mreldif(e(betaOLS),bOLS)<1e-8
}

* Estimation with constant and partial/notpen

cap drop w_*
cap drop c_*
* weighted partialling out of y81nrinc
foreach var of varlist lrprice larea cbd intst lintst y81ldist lintstsq {
	qui reg `var' y81nrinc [aw=wt]
	predict double c_`var', resid
	gen double w_c_`var' = c_`var'*sqrt(wt)
}

global vlist lrprice larea cbd intst lintst y81ldist lintstsq y81nrinc
global w_c_vlist w_c_lrprice w_c_larea w_c_cbd w_c_intst w_c_lintst w_c_y81ldist w_c_lintstsq

foreach opt in "" "rob" {
	rlasso $vlist [aw=$wtvar], partial(y81nrinc) `rob'
	mat b=e(beta)
	mat bOLS=e(betaOLS)
	rlasso $vlist [aw=$wtvar], partial(y81nrinc) prestd `rob'
	assert mreldif(e(beta),b)<1e-8
	assert mreldif(e(betaOLS),bOLS)<1e-8
	rlasso $vlist [aw=$wtvar], pnotpen(y81nrinc) `rob'
	assert mreldif(e(beta),b)<1e-8
	assert mreldif(e(betaOLS),bOLS)<1e-8
	rlasso $vlist [aw=$wtvar], pnotpen(y81nrinc) prestd `rob'
	assert mreldif(e(beta),b)<1e-8
	assert mreldif(e(betaOLS),bOLS)<1e-8
	// no constant or partialled-out var to compare
	mat b=b[1,1..colsof(b)-2]
	mat bOLS=bOLS[1,1..colsof(bOLS)-2]
	// use dm and nocons
	rlasso $w_c_vlist, dm nocons `rob'
	assert mreldif(e(beta),b)<1e-8
	assert mreldif(e(betaOLS),bOLS)<1e-8
}


* Fixed effects + partialling-out
* id var created earlier
xtset id

cap drop w_*
cap drop c_*
* weighted partialling out of y81nrinc and FEs
foreach var of varlist lrprice larea cbd intst lintst y81ldist lintstsq {
	qui reg `var' y81nrinc i.id [aw=wt]
	predict double c_`var', resid
	gen double w_c_`var' = c_`var'*sqrt(wt)
}

global vlist lrprice larea cbd intst lintst y81ldist lintstsq y81nrinc
global w_c_vlist w_c_lrprice w_c_larea w_c_cbd w_c_intst w_c_lintst w_c_y81ldist w_c_lintstsq

// disallowed options
cap noi rlasso $vlist [aw=$wtvar], partial(y81nrinc) fe noftools
assert _rc==198

foreach opt in "" "rob" {
	rlasso $vlist [aw=$wtvar], partial(y81nrinc) fe `rob'
	mat b=e(beta)
	mat bOLS=e(betaOLS)
	rlasso $vlist [aw=$wtvar], partial(y81nrinc) prestd fe `rob'
	assert mreldif(e(beta),b)<1e-8
	assert mreldif(e(betaOLS),bOLS)<1e-8
	rlasso $vlist [aw=$wtvar], pnotpen(y81nrinc) fe `rob'
	assert mreldif(e(beta),b)<1e-8
	assert mreldif(e(betaOLS),bOLS)<1e-8
	rlasso $vlist [aw=$wtvar], pnotpen(y81nrinc) prestd fe `rob'
	assert mreldif(e(beta),b)<1e-8
	assert mreldif(e(betaOLS),bOLS)<1e-8
	// partial-out FEs by hand
	rlasso $vlist i.id [aw=$wtvar], partial(y81nrinc i.id) `rob'
	mat bfe=e(beta)
	mat bfe=bfe[1,1..2]
	mat bfeols=e(betaOLS)
	mat bfeols=bfeols[1,1..2]
	assert mreldif(bfe,b)<1e-8
	assert mreldif(bfeols,bOLS)<1e-8
	// no partialled-out var to compare
	mat b=b[1,1..colsof(b)-1]
	mat bOLS=bOLS[1,1..colsof(bOLS)-1]
	rlasso $w_c_vlist, dm nocons `rob'
	assert mreldif(e(beta),b)<1e-8
	assert mreldif(e(betaOLS),bOLS)<1e-8
}

**************** Misc syntax/options *****************************

// Support for inrange(.) and similar [if] expressions:
rlasso $vlist if inrange(age,50,70)

**************** Panel data with time series ops *****************

use "http://fmwww.bc.edu/ec-p/data/macro/abdata.dta", clear

// FE and noftools options
rlasso ys l(0/3).k l(0/3).n, fe
savedresults save ftools e()
cap noi assert "`e(noftools)'"==""  // will be error if ftools not installed
rlasso ys l(0/3).k l(0/3).n, fe noftools
assert "`e(noftools)'"=="noftools"
savedresults comp ftools e()

// ******************* COMPLETE *********************** //

log close
//set more on
set rmsg off

