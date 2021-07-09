***************************************************************************
***************************************************************************
// 10th October 2005
// Do-file to test intcens, a program for interval-censored survival analysis.
// The downloadable programs lgamma and ivglog are used in a couple of places.
// Also, results are compared to those found with SAS.
 
drop _all
sysuse cancer
rename studytime t
rename died d

// check that results are same as streg for supported distributions when there is no interval-censoring
gen t0=t
gen t1=t if d==1
stset t,f(d)

streg age drug, dist(exp) nohr
intcens t0 t1 age drug, dist(exp)
streg age drug, dist(weib) nohr
intcens t0 t1 age drug, dist(weib)
streg age drug, dist(gomp) nohr
intcens t0 t1 age drug, dist(gomp)
streg age drug, dist(weib) time
intcens t0 t1 age drug, dist(weib) time
streg age drug, dist(logl) 
intcens t0 t1 age drug, dist(logl)
streg age drug, dist(logn) 
intcens t0 t1 age drug, dist(logn)
streg age drug, dist(gam) 
intcens t0 t1 age drug, dist(gen)

// Gompertz, inverse Gaussian and 2-parameter gamma
// interval censored with a small interval, should be almost identical estimates and standard errors
streg age drug, dist(gomp) nohr
replace t1=t1+0.01
intcens t0 t1 age drug, dist(gomp)

// need to install ivglog and lgamma to compare results to other inverse Gaussian and gamma ml results
// inverse Gaussian
glm t age drug if d==1, fam(ig) link(log)
ivglog t age drug if d==1
intcens t t age drug if d==1, dist(invg)
intcens t t1 age drug if d==1, dist(invg)
intcens t t age drug if d==1, dist(wien)
intcens t t1 age drug if d==1, dist(wien)

// gamma
// the 2 parameter gamma likelihood is different from glm and lgamma, but comparable to 3 parameter gamma with streg
glm t age drug if d==1, fam(gam) link(log)
lgamma t age drug if d==1
intcens t t age drug if d==1, dist(gam)
intcens t t1 age drug if d==1, dist(gam)


***************************************************************************
***************************************************************************
// check against results from SAS
// check gamma distribution by setting two shape parameters equal to 1/sqrt(alpha), with alpha as estimated in Stata
drop _all
sysuse cancer
rename studytime t
rename died d
stset t,f(d)
gen t0=t
gen t1=t if d==1
sort d, stable
replace t1=t1+5 in 18/28
replace t0=. in 34/38
intcens t0 t1 age drug, dist(exp) time
intcens t0 t1 age drug, dist(weib) time
intcens t0 t1 age drug, dist(logl)
intcens t0 t1 age drug, dist(logn)
intcens t0 t1 age drug, dist(gen)
intcens t0 t1 age drug, dist(gam)

outsheet using "....txt",replace 
// need to fill in file name here and in SAS program which imports it, intcens_test.sas

// same estimates and log-likelihoods  
// same standard errors (except for 2-parameter gamma, because shape parameter is held fixed in SAS)  

***************************************************************************
***************************************************************************
// check for agreement with streg for weights and robust options
// with and without small censoring interval

drop _all
sysuse cancer
rename studytime t
rename died d

gen t0=t
gen t1=t if d==1
gen t2=t+0.01 if d==1
gen fw=1+round(_n/5)
stset t [fw=fw],f(d) 

streg age drug, dist(exp) nohr
intcens t0 t1 age drug [fw=fw], dist(exp)
intcens t0 t2 age drug [fw=fw], dist(exp)
streg age drug , dist(gam) 
intcens t0 t1 age drug [fw=fw], dist(gen)
intcens t0 t2 age drug [fw=fw], dist(gen)

lgamma t age drug if d==1 [fw=fw]
intcens t t age drug if d==1 [fw=fw], dist(gam)
intcens t0 t2 age drug if d==1 [fw=fw], dist(gam)


***************************************************************************
***************************************************************************
// pweights
set seed 11
gen pw=1/(uniform())
stset t [pw=pw],f(d) 

streg age drug, dist(exp) nohr
intcens t0 t1 age drug [pw=pw], dist(exp)
intcens t0 t2 age drug [pw=pw], dist(exp)
streg age drug , dist(gam) 
intcens t0 t1 age drug [pw=pw], dist(gen)
intcens t0 t2 age drug [pw=pw], dist(gen)

lgamma t age drug if d==1 [pw=pw]
intcens t t age drug if d==1 [pw=pw], dist(gam)
intcens t0 t2 age drug if d==1 [pw=pw], dist(gam)

***************************************************************************
***************************************************************************
// robust
stset t ,f(d) 
streg age drug, dist(exp) nohr robust
intcens t0 t1 age drug , dist(exp) robust
intcens t0 t2 age drug , dist(exp) robust
streg age drug , dist(gam)  robust
intcens t0 t1 age drug , dist(gen) robust
intcens t0 t2 age drug , dist(gen) robust

lgamma t age drug if d==1,  robust
intcens t t age drug if d==1, dist(gam) robust
intcens t0 t2 age drug if d==1, dist(gam) robust

***************************************************************************
***************************************************************************
// robust, cluster
gen cl=round((_n+1)/3)
stset t ,f(d) 
streg age drug, dist(exp) nohr robust cluster(cl)
intcens t0 t1 age drug , dist(exp) robust cluster(cl)
intcens t0 t2 age drug , dist(exp) robust cluster(cl)
streg age drug , dist(gam)  robust cluster(cl)
intcens t0 t1 age drug , dist(gen) robust cluster(cl)
intcens t0 t2 age drug , dist(gen) robust cluster(cl)

lgamma t age drug if d==1,  robust  cluster(cl)
intcens t t age drug if d==1, dist(gam) robust  cluster(cl)
intcens t0 t2 age drug if d==1, dist(gam) robust  cluster(cl)


***************************************************************************
***************************************************************************
// generate gamma deviate and fit model to it

quietly{
	drop _all
	set obs 2000
	local alpha=4
	local b0=1
	local b1=1
	gen byte x=(uniform()<0.5)
	tempvar lambda
	gen `lambda'=exp(-(`b0'+`b1'*x))
	gen t=1/(`lambda'*`alpha')*invgammap(`alpha', uniform())

	tempvar unc
	gen byte `unc'=(uniform()<0.1)
	gen t0=floor(t)
	gen t1=t0+1
	local last=10
	replace t0=`last' if t>`last'
	replace t1=. if t>`last'
	replace t0=t if `unc'==1
	replace t1=t if `unc'==1
}

capt program drop _all
intcens t t x, dist(gam)
intcens t0 t1 x, dist(gam)

intcens t0 t1 x, dist(gen)
//  true model has sigma = kappa = 1/sqrt(alpha)  


***************************************************************************
***************************************************************************
// generate inverse Gaussian deviate and fit model to it
quietly{
	drop _all
	set obs 2000
	local b0=1
	local b1=0.5
	local phi=0.1
	
	tempvar eta
	gen byte trt=(uniform()<0.5)
	gen `eta'=exp(`b0'+`b1'*trt)

	// generate inverse Gaussian deviate
	tempvar w u
	gen `w'=(invnorm(uniform()))^2
	gen `u'=`eta'+`phi'*(`eta')^2*`w'/2-`phi'*`eta'/2*sqrt(4*`eta'*`w'/`phi'+(`eta'*`w')^2)
	gen t=cond(uniform()<`eta'/(`eta'+`u'), `u', (`eta')^2/`u')

	tempvar unc
	gen byte `unc'=(uniform()<0.1)
	gen t0=floor(t)
	gen t1=t0+1
	local last=4
	replace t0=`last' if t>`last'
	replace t1=. if t>`last'
	replace t0=t if `unc'==1&t1~=.
	replace t1=t if `unc'==1&t1~=.
}

intcens t0 t1  trt ,dist(invg)

***************************************************************************
***************************************************************************
// generate time to endpoint of Wiener process with random drift
quietly{
	drop _all
	set obs 2000
	local b0=1
	local b1=0.5
	local c0=1.5
	local c1=0.5
	local tau=0.5
	
	tempvar mu0 mu c eta phi
	gen byte trt=(uniform()<0.5)
	gen x=uniform()
	gen `mu0'=exp(`b0'+`b1'*trt)
	gen `c'=exp(`c0'+`c1'*x)
	gen `mu'=`mu0'+`tau'*invnorm(uniform())
	n count if `mu'<0
	// This is the distribution fitted by option wienran 
	// only if there is a negligible probability of mu < 0  
	gen `eta'=`c'/`mu'
	gen `phi'=1/(`c')^2
	
	tempvar w u
	gen `w'=(invnorm(uniform()))^2
	gen `u'=`eta'+`phi'*(`eta')^2*`w'/2-`phi'*`eta'/2*sqrt(4*`eta'*`w'/`phi'+(`eta'*`w')^2)
	gen t=cond(uniform()<`eta'/(`eta'+`u'), `u', (`eta')^2/`u')

	tempvar unc
	gen byte `unc'=(uniform()<0.1)
	gen t0=floor(t)
	gen t1=t0+1
	local last=4
	replace t0=`last' if t>`last'
	replace t1=. if t>`last'
	replace t0=t if `unc'==1&t1~=.
	replace t1=t if `unc'==1&t1~=.
}

intcens t0 t1 trt,dist(wien) cwien(x) diff
intcens t0 t1 trt,dist(wienran) cwien(x) diff  









