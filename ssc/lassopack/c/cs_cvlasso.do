* certification script for 
* lassopack package 1.1.01 08nov2018, aa
* parts of the script use R's glmnet for validation

cscript "cvlasso" adofile cvlasso lasso2 lasso2_p lassoutils
clear all
capture log close
set more off
set rmsg on
program drop _all
log using cs_cvlasso,replace
about
which cvlasso
which lasso2
which lasso2_p
which lassoutils

* data source
global prostate prostate.data
*global prostate https://web.stanford.edu/~hastie/ElemStatLearn/datasets/prostate.data

* program to compare two matrices in terms of avg abs deviation
cap program drop comparemat
program define comparemat , rclass
	syntax anything [, tol(real 10e-3)] 
	local A		: word 1 of `0'
	local B		: word 2 of `0'
	tempname Amat Bmat
	mat `Amat' = `A'
	mat `Bmat' = `B'
	local diff=mreldif(`Amat',`Bmat')
	di as text "mreldif=`diff'. tolerance = `tol'"
	mat list `Amat'
	mat list `Bmat'
	return scalar mreldif = `diff'
	assert `diff'<`tol'
end


set seed 123456

********************************************************************************
*** compare with glmnet				                                         ***
********************************************************************************

* load example data
insheet using "$prostate", tab clear
drop if _n==97 // to ensure same size for each fold

global model lpsa lcavol lweight age lbph svi lcp gleason pgg45

* generate fold variable
gen myfid = 1 if _n<=32
replace myfid = 2 if _n>32 & _n<=64
replace myfid = 3 if _n>64

cvlasso $model, foldvar(myfid) lambda(150 15 1.5)
mat L = e(mmspe)
/*
c<-cv.glmnet(X,y,foldid=fid,lambda=c(150, 15, 1.5)/(2*n),keep=TRUE, intercept=TRUE,standardize=TRUE)
> c$cvm # mean-squared prediction error
[1] 2.386518 1.463497 1.484953
> var(predict(c,newx=X,s="lambda.min"))
         1
1 0.608541
*/
mat G = ( 2.38651835211576 \ 1.46349718052732 \ 1.48495268875459 )
comparemat L G // compare coeffs
cap drop xb
predict double xb, lopt
sum xb
assert reldif(0.608541,r(Var))<0.001 // compare predicted values


cvlasso $model, foldvar(myfid) lambda(150 15 1.5) prestd
mat L = e(mmspe)
/*
c<-cv.glmnet(X,y,foldid=fid,lambda=c(150, 15, 1.5)/(2*n),keep=TRUE, intercept=TRUE,standardize=TRUE)
> c$cvm # mean-squared prediction error
[1] 2.386518 1.463497 1.484953
> var(predict(c,newx=X,s="lambda.min"))
         1
1 0.608541
*/
mat G = ( 2.38651835211576 \ 1.46349718052732 \ 1.48495268875459 )
comparemat L G // compare coeffs
cap drop xb
predict double xb, lopt
sum xb
assert reldif(0.608541,r(Var))<0.001 // compare predicted values


cvlasso $model, foldvar(myfid) lambda(150 15 1.5) unitload
mat L = e(mmspe)
/*
> # cross-validation with intercept & standardisation
> c<-cv.glmnet(X,y,foldid=fid,lambda=c(150, 15, 1.5)/(2*n),keep=TRUE, intercept=TRUE,standardize=FALSE)
> c$cvm # mean-squared prediction error
[1] 2.103697 1.429934 1.427561
> var(predict(c,newx=X,s="lambda.min"))
          1
1 0.7840688
*/ 
mat G = ( 2.10369705382686 \ 1.42993421234064 \ 1.42756055333919 )
comparemat L G // compare coeffs
cap drop xb
predict double xb, lopt
sum xb
assert reldif(0.7840688,r(Var))<0.001 // compare predicted values


cvlasso $model, foldvar(myfid) lambda(150 15 1.5) nocons unitload
mat L = e(mmspe)
/*
> c<-cv.glmnet(X,y,foldid=fid,lambda=c(150, 15, 1.5)/(2*n),keep=TRUE, intercept=FALSE,standardize=FALSE)
> c$cvm # mean-squared prediction error
[1] 1.999806 1.266384 1.246805
> var(predict(c,newx=X,s="lambda.min"))
          1
1 0.7919695
*/
mat G = ( 1.99980614859113 \ 1.26638436668758 \ 1.24680539174676 )
comparemat L G // compare coeffs
cap drop xb
predict double xb, lopt
sum xb
assert reldif(0.7919695,r(Var))<0.001 // compare predicted values

cvlasso $model, foldvar(myfid) lambda(150 15 1.5) nocons
mat L = e(mmspe)
/*
c<-cv.glmnet(X,y,foldid=fid,lambda=c(150, 15, 1.5)/(2*n),keep=TRUE, intercept=FALSE,standardize=TRUE)
> c$cvm # mean-squared prediction error
[1] 1.906526 1.232220 1.310531
> var(predict(c,newx=X,s="lambda.min"))
          1
1 0.6062457
*/
mat G = ( 1.90652583524832 \ 1.23222044017428 \ 1.31053116174191 )
comparemat L G // compare coeffs
cap drop xb
predict double xb, lopt
sum xb
assert reldif(0.6062457,r(Var))<0.001 // compare predicted values

cvlasso $model, foldvar(myfid) lambda(150 15 1.5) nocons prestd
mat L = e(mmspe)
/*
c<-cv.glmnet(X,y,foldid=fid,lambda=c(150, 15, 1.5)/(2*n),keep=TRUE, intercept=FALSE,standardize=TRUE)
> c$cvm # mean-squared prediction error
[1] 1.906526 1.232220 1.310531
> var(predict(c,newx=X,s="lambda.min"))
          1
1 0.6062457
*/
mat G = ( 1.90652583524832 \ 1.23222044017428 \ 1.31053116174191 )
comparemat L G // compare coeffs
cap drop xb
predict double xb, lopt
sum xb
assert reldif(0.6062457,r(Var))<0.001 // compare predicted values


********************************************************************************
*** validate                                                        ***
********************************************************************************

* load example data
insheet using "$prostate", tab clear
 
global model lpsa lcavol lweight age lbph svi lcp gleason pgg45
gen sample = _n<70 
 
foreach type of newlist lopt lse { 
 
local type lse 
 
// check that right beta is used for predict
// also validates that "if" works 
cvlasso $model if sample
local mylopt = e(`type')
cap drop myxb  
predict double myxb if !sample, xb `type' postres
mat A = e(b)

lasso2 $model if sample, lambda(`mylopt')
cap drop myxb2
predict double myxb2 if !sample, xb
mat B = e(b)

comparemat A B
assert myxb2==myxb

// and now with alpha list
cvlasso $model if sample, alpha(0 0.3 0.7 1)
local mylopt = e(`type')
local myalpha = e(alphamin)
cap drop myr
predict double myr if !sample, r `type' postres
mat A = e(b)

lasso2 $model if sample, lambda(`mylopt') alpha(`myalpha') 
cap drop myr2
predict double myr2 if !sample, r
mat B = e(b)

comparemat A B
assert myr2==myr

}
*

********************************************************************************
*** partial                                   							 ***
********************************************************************************


* load example data
insheet using "$prostate", tab clear

cvlasso $model, partial(svi) saveest(m)

// make sure that partial works
estimates restore m1
assert "`e(partial)'"=="svi"


********************************************************************************
*** misc options/syntax checks		                                         ***
********************************************************************************

// Support for inrange(.) and similar [if] expressions:
cvlasso $model if inrange(age,50,70)

********************************************************************************
*** plotting                                    							 ***
********************************************************************************

* load example data
insheet using "$prostate", tab clear

cvlasso $model, plotcv

********************************************************************************
*** time-series example with rolling cv                                      ***
********************************************************************************

webuse air2, clear
 
cvlasso air L(1/12).air, rolling origin(130)
// we should have 144-130=14 folds
assert 14==`e(nfolds)'

cvlasso air L(1/12).air, rolling origin(130) h(2)
// we should have 144-130-1=14 folds
assert 13==`e(nfolds)'

cvlasso air L(1/12).air, rolling origin(130) fixedwin
assert 14==`e(nfolds)'

********************************************************************************
*** panel example
********************************************************************************

use "http://fmwww.bc.edu/ec-p/data/macro/abdata.dta", clear

// FE and noftools options
cvlasso ys l(0/3).k l(0/3).n, fe seed(123)
savedresults save ftools e()
cap noi assert "`e(noftools)'"==""  // will be error if ftools not installed
cvlasso ys l(0/3).k l(0/3).n, fe seed(123) noftools
assert "`e(noftools)'"=="noftools"
savedresults comp ftools e(), exclude(macros: lasso2opt)

********************************************************************************
***  check residuals with fe												 ***
********************************************************************************
		
clear
use https://www.stata-press.com/data/r16/nlswork

replace ln_w = . if year == 80

cvlasso ln_w grade age c.age#c.age ttl_exp c.ttl_exp#c.ttl_exp tenure ///
		c.tenure#c.tenure 2.race not_smsa south , fe   
cvlasso, lse postres ols	
		
local sel = e(selected)
di "`sel'"

predict double uehat  , ue noi  
predict double ehat  , e noi  
predict double xbhat  , xb noi  
predict double xbuhat  , xbu noi  
predict double uhat  , u noi  

xtreg ln_w `sel' if e(sample), fe 
mat bxtreg = e(b)

predict double uehat_xtreg   , ue  
predict double ehat_xtreg   , e 
predict double xbhat_xtreg  , xb
predict double xbuhat_xtreg  , xbu
predict double uhat_xtreg  , u

assert abs(ehat_xtreg-ehat)<10e-8 | (missing(ehat_xtreg) | missing(ehat))
assert abs(uehat_xtreg-uehat)<10e-8 | (missing(uehat_xtreg) | missing(uehat)) 
assert abs(xbhat_xtreg-xbhat)<10e-8 | (missing(xbhat_xtreg) | missing(xbhat))
assert abs(xbuhat_xtreg-xbuhat)<10e-8 | (missing(xbuhat_xtreg) | missing(xbuhat))
assert abs(uhat_xtreg-uhat)<10e-8 | (missing(uhat_xtreg) | missing(uhat))


********************************************************************************
*** finish                                                                   ***
********************************************************************************

cap log close
//set more on
set rmsg off
