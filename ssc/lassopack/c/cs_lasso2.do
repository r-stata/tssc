* certification script for 
* lassopack package 1.1.01 06jan2019, aa
* parts of the script use R's glmnet, Matlab code "SqrtLassoIterative.m", 
* and Wilbur Townsend's elasticregress for validation

cscript "lasso2" adofile lasso2 lasso2_p lassoutils
clear all
capture log close
set more off
set rmsg on
program drop _all
log using cs_lasso2,replace
about
which lasso2
which lasso2_p
which lassoutils

* data source
//global prostate prostate.data
global prostate https://web.stanford.edu/~hastie/ElemStatLearn/datasets/prostate.data

* cert requires elasticregress
//ssc install elasticregress

* simple ridge regression program
cap program drop estridge
program define estridge, rclass
	syntax varlist , Lambda(real) [NOCONStant]
	local yvar		: word 1 of `varlist'
	local xvars		: list varlist - yvar
	qui putmata X=(`xvars') y=(`yvar'), replace
	mata: n=rows(y)
	if ("`noconstant'"=="") {
		mata: X=X:-mean(X)
		mata: y=y:-mean(y)
	}
	mata: p=cols(X)
	mata: beta=lusolve(X'X+(`lambda')/2*I(p),X'y)
	tempname bhat
	mata: st_matrix("`bhat'",beta')
	mat list `bhat'
	return matrix bhat = `bhat'
end

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

* program to compare two vectors using col names
cap program drop comparevec
program define comparevec , rclass
	syntax anything [, tol(real 10e-3)] 
	local A		: word 1 of `0'
	local B		: word 2 of `0'
	tempname Amat Bmat
	mat `Amat' = `A'
	mat `Bmat' = `B'
	local Anames: colnames `Amat' 
	local Bnames: colnames `Bmat'
	local maxdiff = 0
	local num = 0
	foreach var of local Anames {
		local aix = colnumb(`Amat',"`var'")
		local bix = colnumb(`Bmat',"`var'")
		//di `aix'
		//di `bix'
		local thisdiff=reldif(el(`Amat',1,`aix'),el(`Bmat',1,`bix'))
		if `thisdiff'>`maxdiff' {
			local diff = `thisdiff'
		}
		local num=`num'+1
	}
	di as text "Max rel dif = `maxdiff'. tolerance = `tol'"
	mat list `Amat'
	mat list `Bmat'
	return scalar maxdiff = `maxdiff'
	assert `maxdiff'<`tol'
end

* load example data
insheet using "$prostate", tab clear
global model lpsa lcavol lweight age lbph svi lcp gleason pgg45

********************************************************************************
*** replicate glmnet														 ***
********************************************************************************

// # the following R code was run using ‘glmnet’ version 2.0-10
// library("glmnet")
// library("ElemStatLearn")
// data(prostate)
// dta <- prostate
// y <- dta$lpsa
// X <- as.matrix(subset(dta,select=c("lcavol","lweight","age","lbph","svi","lcp","gleason","pgg45")))

lasso2 $model
di e(lmax)
lasso2 $model, lglmnet
di e(lmax)
// glmnet uses the same lambda max (but not the same minimum lambda)
// note the 2*n adjustment required due to the different objective function.
// alternatively, the lglmnet option can used.
/*
	> r<-glmnet(X,y)
	> max(r$lambda*n*2)
	[1] 163.6249
	> max(r$lambda)
	[1] 0.8434274
*/

lasso2 $model, l(150 15 1.5)	
mat L = e(betas)
/*
> # lasso estimation (w/ standardize & w/ intercept)
> r<-glmnet(X,y,lambda=c(150,15,1.5)/(2*n),standardize=TRUE,intercept=TRUE)
> t(coef(r))
3 x 9 sparse Matrix of class "dgCMatrix"
   (Intercept)     lcavol   lweight         age       lbph       svi         lcp    gleason
s0  2.39752500 0.05989726 .          .          .          .          .          .         
s1 -0.06505875 0.49069732 0.4779378  .          0.02746678 0.5334154  .          .         
s2  0.18294444 0.54565337 0.6055144 -0.01820379 0.08889938 0.7084565 -0.06869243 0.03817684
         pgg45
s0 .          
s1 0.001162874
s2 0.003757753
*/
mat G = ( 0.0598972625035856,0,0,0,0,0,0,0,2.39752500012588 \ 0.490697320533337,0.47793780034037,0,0.0274667780837606,0.533415402509892,0,0,0.00116287368561226,-0.0650587459330918 \ 0.545653366713212,0.605514389014173,-0.0182037942686934,0.0888993843088465,0.708456499779504,-0.068692431071907,0.0381768422753705,0.00375775336752149,0.18294443949415 )
comparemat L G

// as above but pre-standardize
lasso2 $model, l(150 15 1.5) prestd
mat L = e(betas)
comparemat L G

lasso2 $model, l(150 15 1.5) unitload
mat L = e(betas)
/* 
> # lasso estimation (w/o standardize & intercept)
> r<-glmnet(X,y,lambda=c(150, 15, 1.5)/(2*n),standardize=FALSE,intercept=TRUE)
> t(coef(r))
3 x 9 sparse Matrix of class "dgCMatrix"
   (Intercept)    lcavol   lweight          age       lbph        svi         lcp     gleason
s0   2.0809125 .         .          .           .          .           .          .          
s1   1.4264961 0.5789631 0.1812337 -0.008794604 0.07658667 0.04715613  .          .          
s2   0.5709279 0.5607932 0.5718048 -0.019339712 0.09484563 0.65884647 -0.07312879 0.003437608
         pgg45
s0 0.016302332
s1 0.006413878
s2 0.005003847
*/
mat G = ( 0,0,0,0,0,0,0,0.0163023319952739,2.08091249516677 \ 0.578963079723197,0.181233651933207,-0.00879460357040878,0.0765866715516214,0.0471561282079499,0,0,0.00641387754085344,1.42649606164357 \ 0.56079320119559,0.571804769257873,-0.0193397117375188,0.0948456306696097,0.658846467359134,-0.0731287924194953,0.0034376077659711,0.00500384714844935,0.570927925454684 ) 
comparemat L G


lasso2 $model, l(150 15 1.5) nocons
mat L = e(betas)
/* 
> # lasso estimation (w/ standardize & w/o intercept)
> r<-glmnet(X,y,lambda=c(150, 15, 1.5)/(2*n),standardize=TRUE,intercept=FALSE)
> t(coef(r))
3 x 9 sparse Matrix of class "dgCMatrix"
   (Intercept)     lcavol   lweight         age       lbph       svi        lcp    gleason
s0           . 0.03202811 0.3597488  .          .          .          .         0.15958484
s1           . 0.49155721 0.4598487  .          0.02987895 0.5357571  .         .         
s2           . 0.54272362 0.6264995 -0.01776074 0.08529663 0.7089062 -0.0691351 0.05116263
         pgg45
s0 .          
s1 0.001132923
s2 0.003532953
*/
mat G = ( 0.0320281112917762,0.359748772081613,0,0,0,0,0.159584841969938,0  \ 0.491557214223318,0.459848707929377,0,0.0298789475809353,0.53575707154284,0,0,0.00113292264640293 \ 0.542723617710186,0.626499540101458,-0.0177607354082528,0.0852966257132293,0.708906240969273,-0.0691351039443382,0.0511626342288098,0.00353295335701127 )
comparemat L G

// as above but pre-standardize
lasso2 $model, l(150 15 1.5) nocons
mat L = e(betas)
comparemat L G


lasso2 $model, l(150 15 1.5) nocons unitload
mat L = e(betas)
/* 
> # lasso estimation (w/o standardize & w/o intercept)
> r<-glmnet(X,y,lambda=c(150, 15, 1.5)/(2*n),standardize=FALSE,intercept=FALSE)
> t(coef(r))
3 x 9 sparse Matrix of class "dgCMatrix"
   (Intercept)    lcavol   lweight         age       lbph        svi         lcp    gleason
s0           . .         .          0.03263871 .          .           .          .         
s1           . 0.5582166 0.4271199  .          0.02888257 0.01868081  .          .         
s2           . 0.5522462 0.6108130 -0.01745695 0.08625277 0.66545544 -0.07473151 0.05386605
         pgg45
s0 0.014883525
s1 0.006455549
s2 0.004082051
*/
mat G = ( 0,0,0.0326387149332038,0,0,0,0,0.0148835249197989 \ 0.558216559129859,0.427119922488729,0,0.0288825748095177,0.0186808135198926,0,0,0.00645554874090459  \ 0.552246180132136,0.610812971251225,-0.0174569524891446,0.0862527702913333,0.665455440830147,-0.0747315133696167,0.0538660488175342,0.00408205134388933   )
comparemat L G

*** now using lglmnet option ***

lasso2 $model, l(.8 .6 .2) lglmnet
mat L = e(betas)
/*
> # lasso estimation (standardize & intercept)
> r<-glmnet(X,y,lambda=c(.8,.6,.2),standardize=TRUE,intercept=TRUE)
> t(coef(r))
3 x 9 sparse Matrix of class "dgCMatrix"
   (Intercept)     lcavol   lweight age lbph       svi lcp gleason pgg45
s0   2.4283862 0.03703726 .           .    . .           .       .     .
s1   2.1981140 0.20760804 .           .    . .           .       .     .
s2   0.7154547 0.45182494 0.2966946   .    . 0.3523241   .       .     .
*/
mat G = ( 0.0370372606890949,0,0,0,0,0,0,0,2.42838622158533 \ 0.207608043458756,0,0,0,0,0,0,0,2.19811403069554 \ 0.45182494276911,0.296694633018004,0,0,0.352324077604082,0,0,0,0.715454720149449 )
comparemat L G

lasso2 $model, l(.8 .6 .2) lglmnet unitload
mat L = e(betas)
/*
> # lasso estimation (w/o standardize & intercept)
> r<-glmnet(X,y,lambda=c(.8,.6,.2),standardize=FALSE,intercept=TRUE)
> t(coef(r))
3 x 9 sparse Matrix of class "dgCMatrix"
   (Intercept)    lcavol lweight age       lbph svi lcp gleason       pgg45
s0    2.081743 .               .   . .            .   .       . 0.016268285
s1    1.950896 0.1372576       .   . .            .   .       . 0.014034947
s2    1.618724 0.4893253       .   . 0.02387818   .   .       . 0.008066494
> asmat(t(coef(r)))
*/
mat G = ( 0,0,0,0,0,0,0,0.0162682849336487,2.08174261166929 \ 0.137257628322798,0,0,0,0,0,0,0.0140349465593846,1.95089551137846 \ 0.489325292943062,0,0,0.0238781766783061,0,0,0,0.00806649425516767,1.61872396370499 )
comparemat L G

lasso2 $model, l(.8 .6 .2) lglmnet  nocons
mat L = e(betas)
/*
> # lasso estimation (w/ standardize & w/o intercept)
> r<-glmnet(X,y,lambda=c(.8,.6,.2),standardize=TRUE,intercept=FALSE)
> t(coef(r))
3 x 9 sparse Matrix of class "dgCMatrix"
   (Intercept)     lcavol   lweight age lbph       svi lcp    gleason pgg45
s0           . 0.01001615 0.3557483   .    . .           . 0.16581999     .
s1           . 0.17424422 0.3773174   .    . .           . 0.12370274     .
s2           . 0.43879201 0.4531537   .    . 0.3434186   . 0.02362562     .
> asmat(t(coef(r)))
*/
mat G = ( 0.0100161543047344,0.355748298540682,0,0,0,0,0.165819987155045,0 \ 0.174244224723816,0.377317383071473,0,0,0,0,0.123702743345189,0 \ 0.438792010313506,0.453153674363568,0,0,0.343418593611708,0,0.0236256173546178,0 )
comparemat L G

lasso2 $model, l(.8 .6 .2) lglmnet unitload nocons
mat L = e(betas)
/*
> # lasso estimation (w/o standardize & w/o intercept)
> r<-glmnet(X,y,lambda=c(.8,.6,.2),standardize=FALSE,intercept=FALSE)
> t(coef(r))
3 x 9 sparse Matrix of class "dgCMatrix"
   (Intercept)    lcavol lweight        age lbph svi lcp gleason       pgg45
s0           . .               . 0.03264146    .   .   .       . 0.014860920
s1           . 0.1357669       . 0.03062938    .   .   .       . 0.012720689
s2           . 0.4877323       . 0.02542719    .   .   .       . 0.007070216
> asmat(t(coef(r)))
*/
mat G = ( 0,0,0.0326414588433045,0,0,0,0,0.0148609196162634 \ 0.13576687334887,0,0.0306293800710363,0,0,0,0,0.0127206887941435 \ 0.487732337283528,0,0.0254271936782152,0,0,0,0,0.00707021639137941 )
comparemat L G

********************************************************************************
*** replicate sqrt-lasso Matlab program										 ***
********************************************************************************

// uses the Matlab code "SqrtLassoIterative.m" (available on request)

lasso2 $model, sqrt l(40) unitload
mat a=e(betaAll)
/*
ans =

    0.3627
         0
         0
         0
         0
         0
         0
    0.0103
    1.7383
*/
mat b = (0.3627,0,0,0,0,0,0,0.0103,1.7383)
comparemat a b

lasso2 $model, sqrt l(10) unitload
mat a=e(betaAll)
/*
ans =

    0.5771
    0.1965
   -0.0092
    0.0773
    0.0685
         0
         0
    0.0063
    1.3946
*/
mat b = (0.5771,0.1965,-0.0092,0.0773,0.0685,0,0,0.0063,1.3946)
comparemat a b

lasso2 $model, sqrt l(1) unitload
mat a=e(betaAll)
/*
ans =

    0.5610
    0.5774
   -0.0196
    0.0950
    0.6700
   -0.0766
    0.0088
    0.0049
    0.5259
*/
mat b = (0.5610, 0.5774,-0.0196,0.0950,0.6700,-0.0766,0.0088,0.0049,0.5259)
comparemat a b

********************************************************************************
*** validation using elasticregress											 ***
********************************************************************************

// NB: check allows for for a 2.5% deviation
// Note that lambda=50 and alpha=0.25 yields a 3.5% deviation.
/*
foreach li of numlist 0.1 1 3 5 10 50 100 {
 foreach ai of numlist  0 0.01 /* 0.25 */ 0.5 0.75 0.9 0.99 1 {
	di
	di as text "lambda=`li'  alpha=`ai'"
	qui lasso2 $model, l(`li') alpha(`ai') prestd
	mat A = e(betaAll)
	local lam = `li'/97/2 // uses different objective function
	elasticregress $model, lambda(`lam') alpha(`ai') tol(10e-10)
	mat B = e(b)
	comparemat A B , tol(0.025)
 }
}
*/

********************************************************************************
*** norecover option														 ***
********************************************************************************

// partial() with constant
lasso2 $model, partial(age) l(50 20 10) 
mat A = e(betas)
mat A = A[2,1..9]
lasso2 $model, l(20) partial(age) postall
mat B = e(b)
comparemat A B

lasso2 $model, partial(age) l(50 20 10) nor 
mat A = e(betas)
mat A = A[2,1..7]
lasso2 $model, l(20) partial(age) nor postall
mat B = e(b)
comparemat A B

// partial() with constant, unitloadings
lasso2 $model, partial(age) l(50 20 10) unitl
mat A = e(betas)
mat A = A[2,1..9]
lasso2 $model, l(20) partial(age) postall unitl
mat B = e(b)
comparemat A B

lasso2 $model, partial(age) l(50 20 10) nor  unitl
mat A = e(betas)
mat A = A[2,1..7]
lasso2 $model, l(20) partial(age) nor postall unitl
mat B = e(b)
comparemat A B

// no partial() w/ constant, unitloadings
lasso2 $model, l(50 20 10) unitl
mat A = e(betas)
mat A = A[2,1..9]
lasso2 $model, l(20) postall unitl
mat B = e(b)
comparemat A B

lasso2 $model, l(50 20 10) nor  unitl
mat A = e(betas)
mat A = A[2,1..9]
lasso2 $model, l(20) nor postall unitl
mat B = e(b)
comparemat A B

// no partial() w/o constant, unit loadings
lasso2 $model, l(50 20 10) unitl nocons
mat A = e(betas)
mat A = A[2,1..8]
lasso2 $model, l(20) postall unitl nocons
mat B = e(b)
comparemat A B

lasso2 $model, l(50 20 10) nor unitl nocons
mat A = e(betas)
mat A = A[2,1..8]
lasso2 $model, l(20) nor postall unitl nocons
mat B = e(b)
comparemat A B


********************************************************************************
*** options																	 ***
********************************************************************************

cap lasso2 $model, alpha(0) sqrt
if _rc != 198 {
	exit 1
} 
*
// should say that lcount/lmax/lminr are being ignored
lasso2 $model, lambda(10) lcount(10)
lasso2 $model, lambda(10) lmax(100)
lasso2 $model, lambda(10) lminr(0.01)

// plotting only supported for lambda list
lasso2 $model, lambda(10) plotpath(lambda)

// incompatible options wrt penalty loadings
cap lasso2 $model, ploadings(abc) adaptive
if _rc != 198 {
	exit 1
} 
*
cap lasso2 $model, ploadings(abc) unitload
if _rc != 198 {
	exit 1
} 
cap lasso2 $model, ploadings(abc) adatheta(3)
if _rc != 198 {
	exit 1
} 
*
cap lasso2 $model, adaptive unitload
if _rc != 198 {
	exit 1
} 
*

// var may not appear in partial() and notpen()
cap lasso2 $model, partial(age svi lcp) notpen(age svi)
if _rc != 198 {
	exit 1
} 
*

// controls the output and content of e(b)
lasso2 $model, l(20) displayall
lasso2 $model, l(20) postall
mat list e(b)

lasso2 $model, l(20) displayall postall
mat list e(b)

********************************************************************************
*** verify results are the same for scalar lambda vs lambda list			 ***
********************************************************************************

global lambdalist 150 130 100 80 60 30 10 5 3 1

* lasso
lasso2 $model, l($lambdalist)
mat A = e(betas)
local j=1
foreach i of numlist $lambdalist {
	mat a = A[`j',1..9]
	lasso2 $model, l(`i')
	mat b = e(betaAll)
	comparemat a b
	local j=`j'+1
}
*

* lasso (w/o constant)
lasso2 $model, l($lambdalist) nocons
mat A = e(betas)
local j=1
foreach i of numlist $lambdalist {
	mat a = A[`j',1..8]
	lasso2 $model, l(`i') nocons
	mat b = e(betaAll)
	comparemat a b
	local j=`j'+1
}
*

* post-lasso
lasso2 $model, l($lambdalist) ols
mat A = e(betas)
local j=1
foreach i of numlist $lambdalist {
	mat a = A[`j',1..9]
	lasso2 $model, l(`i')  
	mat b = e(betaAllOLS)
	comparemat a b
	local j=`j'+1
}
*

global sqrtlambdalist 100 40 20 10 5 1
* sqrt-lasso
lasso2 $model, l($sqrtlambdalist) sqrt   
mat A = e(betas)
local j=1
foreach i of numlist $sqrtlambdalist {
	mat a = A[`j',1..8]
	di `i'
	lasso2 $model, l(`i') sqrt 
	mat b = e(betaAll)
	mat b = b[1,1..8]
	comparemat a b
	local j=`j'+1
}
*

* post-sqrt-lasso ols
lasso2 $model, l($sqrtlambdalist) sqrt ols
mat A = e(betas)
local j=1
foreach i of numlist $sqrtlambdalist {
	di "this lambda: `i'"
	mat a = A[`j',1..9]
	lasso2 $model, l(`i') sqrt ols
	mat b = e(betaAllOLS)
	comparemat a b
	local j=`j'+1
}
*

* ridge
lasso2 $model, l($lambdalist) alpha(0)
mat A = e(betas)
local j=1
foreach i of numlist $lambdalist {
	mat a = A[`j',1..9]
	lasso2 $model, l(`i') alpha(0)
	mat b = e(betaAll)
	comparemat a b
	local j=`j'+1
}
*

* ols ridge
lasso2 $model, l($lambdalist) alpha(0) ols
mat A = e(betas)
local j=1
foreach i of numlist $lambdalist {
	mat a = A[`j',1..9]
	lasso2 $model, l(`i') alpha(0) ols
	mat b = e(betaAllOLS)
	comparemat a b
	local j=`j'+1
}
*
	
* elastic net
foreach ai of numlist 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 {
lasso2 $model, l($lambdalist) alpha(`ai')
mat A = e(betas)
local j=1
foreach i of numlist $lambdalist {
	mat a = A[`j',1..9]
	lasso2 $model, l(`i') alpha(`ai')
	mat b = e(betaAll)
	comparemat a b
	local j=`j'+1
}
}
*

* elastic net with ols
foreach ai of numlist 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 {
lasso2 $model, l($lambdalist) alpha(`ai') ols
mat A = e(betas)
local j=1
foreach i of numlist $lambdalist {
	mat a = A[`j',1..9]
	lasso2 $model, l(`i') alpha(`ai') ols
	mat b = e(betaAllOLS)
	comparemat a b
	local j=`j'+1
}
}
*


********************************************************************************
*** verify adapative weights												 ***
********************************************************************************

** lasso with ada theta = 1
lasso2 $model, adaptive verb
mat psi = e(Psi)

reg $model
mat bols = e(b)

mat checkups = J(1,8,.)
forvalues i=1(1)8 {
	mat checkups[1,`i'] = abs(1/bols[1,`i'])
}
comparemat psi checkups

** lasso with ada theta = 2
lasso2 $model, adaptive verb adatheta(2)
mat psi = e(Psi)

reg $model
mat bols = e(b)

mat checkups = J(1,8,.)
forvalues i=1(1)8 {
	mat checkups[1,`i'] = abs(1/bols[1,`i'])^2
}
comparemat psi checkups

// use of adaloadings option
lasso2 $model , l(10) alph(0)
mat b = e(betaAll)
lasso2 $model, adaptive adal(b) adat(2)
mat psi = e(Psi)
mat checkups = J(1,8,.)
forvalues i=1(1)8 {
	mat checkups[1,`i'] = abs(1/b[1,`i'])^2
}
comparemat psi checkups

// use of adaloadings option
lasso2 $model , l(10) alph(0)
mat b = e(betaAll)
lasso2 $model, adaptive adal(b) adat(1)
mat psi = e(Psi)
mat checkups = J(1,8,.)
forvalues i=1(1)8 {
	mat checkups[1,`i'] = abs(1/b[1,`i'])
}
comparemat psi checkups

********************************************************************************
*** pre-estimation standardisation vs std on the fly   				 		 ***
********************************************************************************

// lasso
// standardisation using penalty loadings (default)
lasso2 $model, l(10) 
mat A = e(beta)
// pre-estimation standardisation of data
lasso2 $model, l(10) prestd  
mat B = e(beta)
comparemat A B , tol(10e-6)

// lasso [nocons]
// standardisation using penalty loadings (default)
lasso2 $model, l(10)  nocons
mat A = e(beta)
// pre-estimation standardisation of data
lasso2 $model, l(10) prestd nocons 
mat B = e(beta)
comparemat A B , tol(10e-6)

// sqrt lasso
// standardisation using penalty loadings (default)
lasso2 $model, l(10) sqrt 
mat A = e(beta)
// pre-estimation standardisation of data
lasso2 $model, l(10) sqrt prestd
mat B = e(beta)
comparemat A B , tol(10e-6)

// sqrt lasso [nocons]
// standardisation using penalty loadings (default)
lasso2 $model, l(10) sqrt nocons
mat A = e(beta)
// pre-estimation standardisation of data
lasso2 $model, l(10) sqrt prestd nocons
mat B = e(beta)
comparemat A B , tol(10e-6)

// elastic net
foreach lam of numlist 1 10 50 150 160 {
foreach ai of numlist 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 {
	// in original units
	// standardisation using penalty loadings (default)
	lasso2 $model, l(`lam')  alpha(`ai')
	mat A = e(beta)

	// pre-estimation standardisation of data
	lasso2 $model, l(`lam') prestd alpha(`ai')
	mat B = e(beta)
	comparemat A B , tol(10e-6)
}
}
*

// elastic net [nocons]
foreach lam of numlist 1 10 50 150 160 {
foreach ai of numlist 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 {
	// in original units
	// standardisation using penalty loadings (default)
	lasso2 $model, l(`lam')  alpha(`ai') nocons
	mat A = e(beta)

	// pre-estimation standardisation of data
	lasso2 $model, l(`lam') prestd alpha(`ai') nocons
	mat B = e(beta)
	comparemat A B , tol(10e-6)
}
}
*

********************************************************************************
*** verify ridge regression results											 ***
********************************************************************************

lasso2 $model, l(150) alpha(0) unitload
mat A = e(beta)
mat A = A[1,1..8] // excl intercept

estridge $model, l(150)
mat B = r(bhat)

comparemat A B , tol(10e-6)


********************************************************************************
*** verify post-estimation OLS results										 ***
********************************************************************************

* lasso
foreach i of numlist 0.5 1 4 10 15 50 150 {
	lasso2 $model, l(`i') ols
	mat A = e(b)
	reg lpsa `e(selected)'
	mat B = e(b)
	comparemat A B
}
*

* lasso (w/o constant)
foreach i of numlist 0.5 1 4 10 15 50 150 {
	lasso2 $model, l(`i') ols nocons
	mat A = e(b)
	reg lpsa `e(selected)', nocons
	mat B = e(b)
	comparemat A B
}
*

* sqrt lasso
foreach i of numlist 0.5 1 4 10 15 50 150 {
	lasso2 $model, l(`i') ols sqrt
	mat A = e(b)
	reg lpsa `e(selected)'
	mat B = e(b)
	comparemat A B
}
*

* elastic net
foreach i of numlist 0.5 1 4 10 15 50 150 {
	lasso2 $model, l(`i') ols alpha(.5)
	mat A = e(b)
	reg lpsa `e(selected)'
	mat B = e(b)
	comparemat A B
}
*

* ridge
foreach i of numlist 0.5 1 4 10 15 50 150 {
	lasso2 $model, l(`i') ols alpha(0)
	mat A = e(b)
	reg lpsa `e(selected)'
	mat B = e(b)
	comparemat A B
}
*

********************************************************************************
*** partial() vs notpen()													 ***
********************************************************************************

lasso2 $model, partial(lcp) l(50)
mat A = e(b) 
lasso2 $model, notpen(lcp) l(50)
mat B = e(b)
comparevec A B  

lasso2 $model, partial(lcp) l(50) sqrt
mat A = e(b) 
lasso2 $model, notpen(lcp) l(50) sqrt
mat B = e(b)
comparevec A B  

lasso2 $model, partial(lcp) l(50) alpha(0.5)
mat A = e(b) 
lasso2 $model, notpen(lcp) l(50) alpha(0.5)
mat B = e(b)
comparevec A B  

lasso2 $model, partial(lcp) l(50) alpha(0)
mat A = e(b) 
lasso2 $model, notpen(lcp) l(50) alpha(0)
mat B = e(b)
comparevec A B  

lasso2 $model, lambda(10) partial(age) notpen(svi)
mat A = e(b) 
lasso2 $model, lambda(10) partial(svi) notpen(age)
mat B = e(b)
comparevec A B  

********************************************************************************
*** penalty loadings vs notpen (see help file)						         ***
********************************************************************************

lasso2 $model, l(10) notpen(lcavol) unitloadings
mat A = e(b)

mat myloadings = (0,1,1,1,1,1,1,1)
lasso2 $model, l(10) ploadings(myloadings)
mat B = e(b)

comparemat A B


********************************************************************************
*** ic option to control display of output 							***
********************************************************************************

di as red "should display EBIC (the default):"
lasso2 $model  
sleep 1000
di as red "should display AIC:"
lasso2 $model , ic(aic)
sleep 1000
di as red "should display AICc:"
lasso2 $model , ic(aicc)
sleep 1000
di as red "should display BIC:"
lasso2 $model , ic(bic)
sleep 1000
di as red "should display EBIC:"
lasso2 $model , ic(ebic)


********************************************************************************
*** degrees of freedom calculation          						   ***
********************************************************************************

// replicate dof w/o constant and no standardisation [OK]
lasso2 $model ,  alpha(0) l(20 .1)  long unitload    nocons nopath
mat D= e(dof)
mat list e(dof)

putmata y=(lpsa) X=(lcavol lweight  age lbph  svi  lcp gleason pgg45  ), replace
mata: df=trace(X*invsym((X'X):+20/2*I(8))*X') 
mata: df

mata: st_local("df",strofreal(df))
assert reldif(el(D,1,1),`df')<10^-6

// standardisation w/o constant [OK]
lasso2 $model ,  alpha(0)   l(20 .1)  long      nocons nopath
mat D1 = e(dof)
mat list e(dof)
lasso2 $model ,  alpha(0)   l(20 .1)  long prestd   nocons nopath
mat D2 = e(dof)
mat list e(dof)
comparemat D1 D2

putmata y=(lpsa) X=(lcavol lweight  age lbph  svi  lcp gleason pgg45  ), replace
mata: s = sqrt(mean((X:-mean(X)):^2))
mata: ssq = s:^2
mata: Xs=X:/s 
mata: df1=trace(X*invsym((X'X):+20/2*diag(ssq))*X')  // "on the fly" standardisation
mata: df2=trace(Xs*invsym((Xs'Xs):+20/2*I(8))*Xs')   // pre-standardisation
mata: df1,df2
mata: st_local("df1",strofreal(df1))
mata: st_local("df2",strofreal(df2))
assert reldif(el(D1,1,1),`df1')<10^-6
assert reldif(el(D1,1,1),`df2')<10^-6
assert reldif(`df1',`df2')<10^-6

// dof with constant and no standardisation [OK]
lasso2 $model ,  alpha(0) l(20 .1)  long unitload  nopath   
mat list e(dof)
mat D = e(dof)

putmata y=(lpsa) X=(lcavol lweight  age lbph  svi  lcp gleason pgg45  ), replace
mata: Xone=(X,J(97,1,1))
mata: Psicons = I(9)
mata: Psicons[9,9]=0
mata: Xdm = X :- mean(X)
mata: trace(X*invsym((X'X):+20/2*I(8))*X') 			// this is wrong (ignores constant)
mata: trace(Xdm*invsym((Xdm'Xdm):+20/2*I(8))*Xdm')   // this is missing the constant
mata: df1=trace(Xone*invsym((Xone'Xone):+20/2*Psicons)*Xone')  // this should be correct
mata: df2=trace(Xdm*invsym((Xdm'Xdm):+20/2*I(8))*Xdm')+1  // this is correct
mata: df1,df2
mata: st_local("df1",strofreal(df1))
mata: st_local("df2",strofreal(df2))
assert reldif(el(D,1,1),`df1')<10^-6
assert reldif(el(D,1,1),`df2')<10^-6
assert reldif(`df1',`df2')<10^-6

// standardisation w/  constant [OK]
lasso2 $model ,  alpha(0) l(20 10 1 .1)  long nopath
mat list e(dof)
mat D1 = e(dof)
lasso2 $model ,  alpha(0) l(20 10 1 .1)  long prestd nopath  
mat list e(dof)
mat D2 = e(dof)
comparemat D1 D2

putmata y=(lpsa) X=(lcavol lweight  age lbph  svi  lcp gleason pgg45), replace
mata: s = sqrt(mean((X:-mean(X)):^2))
mata: ssq = s:^2
mata: Xs=(X:-mean(X)):/s 
mata: Xone=(X,J(97,1,1))
mata: df1=trace(Xdm*invsym((Xdm'Xdm):+20/2*diag(ssq))*Xdm') +1
mata: df2=trace(Xs*invsym((Xs'Xs):+20/2*I(8))*Xs') +1
mata: df1,df2
mata: st_local("df1",strofreal(df1))
mata: st_local("df2",strofreal(df2))
assert reldif(el(D1,1,1),`df1')<10^-6
assert reldif(el(D1,1,1),`df2')<10^-6
assert reldif(`df1',`df2')<10^-6

********************************************************************************
*** lic option 						    							***
********************************************************************************

* check that right lambda is used 
foreach ic of newlist ebic aic aicc bic {
	lasso2 $model 
	local optlambda=e(l`ic') 
	lasso2, lic(`ic') postres
	local thislambda=e(lambda)
	assert reldif(`optlambda',`thislambda')<10^-8
}
*

********************************************************************************
*** predicted values (see help file)										 ***
********************************************************************************

// xbhat1 is generated by re-estimating the model for lambda=10.  The noisily 
// option triggers the display of the
// estimation results.  xbhat2 is generated by linear approximation using the 
// two beta estimates closest to
//    lambda=10.

* load example data
insheet using "$prostate", tab clear
global model lpsa lcavol lweight age lbph svi lcp gleason pgg45

lasso2 $model
cap drop xbhat1
predict double xbhat1, xb l(10) noisily
cap drop xbhat2
predict double xbhat2, xb l(10) approx

//    The model is estimated explicitly using lambda=100.  If lasso2 is 
//called with a scalar lambda value, the
//   subsequent predict command requires no lambda() option.
lasso2 $model, lambda(10)
cap drop xbhat3
predict double xbhat3, xb

//    All three methods yield the same results.  However note that the linear 
// approximation is only exact for the lasso
//   which is piecewise linear.
assert (xbhat1-xbhat2<10e-8) & (xbhat3-xbhat2<10e-8) 

//It is also possible to obtain predicted values by referencing a specific
// lambda ID using the lid() option.
lasso2 $model
cap drop xbhat4
predict double xbhat4, xb lid(21)
cap drop xbhat5
predict double xbhat5, xb l(25.45473900468241)
assert (xbhat4-xbhat5<10e-8)


********************************************************************************
*** misc options/syntax checks		                                         ***
********************************************************************************

// Support for inrange(.) and similar [if] expressions:
lasso2 $model if inrange(age,50,70)


********************************************************************************
*** plotting                                                                 ***
********************************************************************************

lasso2 $model

lasso2, plotpath(lambda) plotlabel plotopt(legend(off))

lasso2, plotpath(lnlambda) plotlabel plotopt(legend(off))

lasso2, plotpath(norm) plotlabel plotopt(legend(off))

lasso2, plotpath(norm) plotlabel plotopt(legend(off)) plotvar(lcavol)

********************************************************************************
*** validate RSS / r-squared    				                             ***
********************************************************************************

// loop over three mehods. "nopath" corresponds to default standardisatin on the fly.
// "nopath" is just a placeholder that doesn't affect calculations.
foreach method in prestd unitl nopath {
foreach a of numlist 0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1 {
	lasso2 $model, alpha(`a') l(10)  `method'
	cap drop xb
	cap drop r
	predict double xb, xb
	predict double r, r

	sum lpsa
	di r(sd)^2*98
	local tss=r(sd)^2*98
	sum xb
	di r(sd)^2*98
	local ess=r(sd)^2*98
	sum r
	di r(sd)^2*98
	local rss=r(sd)^2*98
	 
	di "r-squared"
	local rsq = 1-`rss'/`tss'
	di `rsq'

	lasso2 $model, alpha(`a') l(10 0.1) `method'
	mat list e(rsq)
	mat RSQ = e(rsq)
	di el(RSQ,1,1)
	di reldif(`rsq',el(RSQ,1,1))
	assert reldif(`rsq',el(RSQ,1,1))<10^(-3)
}
}
*

********************************************************************************
*** validate EBIC default gamma     				                         ***
********************************************************************************

webuse air2, clear

lasso2 air L(1/24).air

local myebicgamma = 1-log(e(N))/(2*log(e(p)))

di `myebicgamma'
di e(ebicgamma)
assert reldif(`myebicgamma',e(ebicgamma))<10^(-3)

********************************************************************************
*** panel example: validate within transformation                            ***
********************************************************************************

use "http://fmwww.bc.edu/ec-p/data/macro/abdata.dta", clear

lasso2 ys l(0/3).k l(0/3).n, fe l(10)  
mat A = e(b)

lasso2 ys l(0/3).k l(0/3).n ibn.id, partial(ibn.id) l(10) nor
mat B = e(b)

comparemat A B

// noftools option
lasso2 ys l(0/3).k l(0/3).n, fe l(10)
savedresults save ftools e()
cap noi assert "`e(noftools)'"==""  // will be error if ftools not installed
lasso2 ys l(0/3).k l(0/3).n, fe l(10) noftools
assert "`e(noftools)'"=="noftools"
savedresults comp ftools e(), exclude(macros: lasso2opt)

********************************************************************************
***  check if partial() works with fe				                         ***
***  and followed by lic()													 ***
********************************************************************************

clear 
use https://www.stata-press.com/data/r16/nlswork

lasso2 ln_w grade age c.age#c.age ttl_exp c.ttl_exp#c.ttl_exp tenure ///
		c.tenure#c.tenure 2.race not_smsa south i.year, fe  
ereturn list 

lasso2 ln_w grade age c.age#c.age ttl_exp c.ttl_exp#c.ttl_exp tenure ///
		c.tenure#c.tenure 2.race not_smsa south i.year, fe partial(i.year) 
lasso2, lic(ebic)

lasso2 ln_w grade age c.age#c.age ttl_exp c.ttl_exp#c.ttl_exp tenure ///
		c.tenure#c.tenure 2.race not_smsa south i.year, fe partial(i.year) ///
		lic(ebic)

********************************************************************************
***  check residuals with fe												 ***
********************************************************************************
		
clear
use https://www.stata-press.com/data/r16/nlswork

foreach opt in xb u e ue xbu {
	cap drop `opt'hat_lasso2
	cap drop `opt'hat_xtreg
}
cap drop esample

**replace ln_w = . if year == 80

lasso2 ln_w grade age c.age#c.age ttl_exp c.ttl_exp#c.ttl_exp tenure ///
		c.tenure#c.tenure 2.race not_smsa south , fe
gen byte esample=e(sample)
lasso2, lic(ebic) postres ols
mat bl2 = e(b)
local selected = e(selected)
di "`selected'"
//ereturn list

// confirm post-lasso LSDV matches xtreg,fe
foreach opt in xb u e ue xbu {
	predict double `opt'hat_lasso2, ols `opt'
}
xtreg ln_w `selected' if esample, fe
foreach opt in xb u e ue xbu {
	predict double `opt'hat_xtreg, `opt'
}
foreach opt in xb u e ue xbu {
	di "checking option `opt'
	assert reldif(`opt'hat_lasso2, `opt'hat_xtreg) < 1e-6
}

		
********************************************************************************
*** finish                                                                   ***
********************************************************************************

cap log close
//set more on
set rmsg off
* certification script for 
* lassopack package 1.1.01 06jan2019, aa
* parts of the script use R's glmnet, Matlab code "SqrtLassoIterative.m", 
* and Wilbur Townsend's elasticregress for validation

cscript "lasso2" adofile lasso2 lasso2_p lassoutils
clear all
capture log close
set more off
set rmsg on
program drop _all
log using cs_lasso2,replace
about
which lasso2
which lasso2_p
which lassoutils

* data source
global prostate prostate.data
//global prostate https://web.stanford.edu/~hastie/ElemStatLearn/datasets/prostate.data

* cert requires elasticregress
//ssc install elasticregress

* simple ridge regression program
cap program drop estridge
program define estridge, rclass
	syntax varlist , Lambda(real) [NOCONStant]
	local yvar		: word 1 of `varlist'
	local xvars		: list varlist - yvar
	qui putmata X=(`xvars') y=(`yvar'), replace
	mata: n=rows(y)
	if ("`noconstant'"=="") {
		mata: X=X:-mean(X)
		mata: y=y:-mean(y)
	}
	mata: p=cols(X)
	mata: beta=lusolve(X'X+(`lambda')/2*I(p),X'y)
	tempname bhat
	mata: st_matrix("`bhat'",beta')
	mat list `bhat'
	return matrix bhat = `bhat'
end

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

* program to compare two vectors using col names
cap program drop comparevec
program define comparevec , rclass
	syntax anything [, tol(real 10e-3)] 
	local A		: word 1 of `0'
	local B		: word 2 of `0'
	tempname Amat Bmat
	mat `Amat' = `A'
	mat `Bmat' = `B'
	local Anames: colnames `Amat' 
	local Bnames: colnames `Bmat'
	local maxdiff = 0
	local num = 0
	foreach var of local Anames {
		local aix = colnumb(`Amat',"`var'")
		local bix = colnumb(`Bmat',"`var'")
		//di `aix'
		//di `bix'
		local thisdiff=reldif(el(`Amat',1,`aix'),el(`Bmat',1,`bix'))
		if `thisdiff'>`maxdiff' {
			local diff = `thisdiff'
		}
		local num=`num'+1
	}
	di as text "Max rel dif = `maxdiff'. tolerance = `tol'"
	mat list `Amat'
	mat list `Bmat'
	return scalar maxdiff = `maxdiff'
	assert `maxdiff'<`tol'
end

* load example data
insheet using "$prostate", tab clear
global model lpsa lcavol lweight age lbph svi lcp gleason pgg45

********************************************************************************
*** replicate glmnet														 ***
********************************************************************************

// # the following R code was run using ‘glmnet’ version 2.0-10
// library("glmnet")
// library("ElemStatLearn")
// data(prostate)
// dta <- prostate
// y <- dta$lpsa
// X <- as.matrix(subset(dta,select=c("lcavol","lweight","age","lbph","svi","lcp","gleason","pgg45")))

lasso2 $model
di e(lmax)
lasso2 $model, lglmnet
di e(lmax)
// glmnet uses the same lambda max (but not the same minimum lambda)
// note the 2*n adjustment required due to the different objective function.
// alternatively, the lglmnet option can used.
/*
	> r<-glmnet(X,y)
	> max(r$lambda*n*2)
	[1] 163.6249
	> max(r$lambda)
	[1] 0.8434274
*/

lasso2 $model, l(150 15 1.5)	
mat L = e(betas)
/*
> # lasso estimation (w/ standardize & w/ intercept)
> r<-glmnet(X,y,lambda=c(150,15,1.5)/(2*n),standardize=TRUE,intercept=TRUE)
> t(coef(r))
3 x 9 sparse Matrix of class "dgCMatrix"
   (Intercept)     lcavol   lweight         age       lbph       svi         lcp    gleason
s0  2.39752500 0.05989726 .          .          .          .          .          .         
s1 -0.06505875 0.49069732 0.4779378  .          0.02746678 0.5334154  .          .         
s2  0.18294444 0.54565337 0.6055144 -0.01820379 0.08889938 0.7084565 -0.06869243 0.03817684
         pgg45
s0 .          
s1 0.001162874
s2 0.003757753
*/
mat G = ( 0.0598972625035856,0,0,0,0,0,0,0,2.39752500012588 \ 0.490697320533337,0.47793780034037,0,0.0274667780837606,0.533415402509892,0,0,0.00116287368561226,-0.0650587459330918 \ 0.545653366713212,0.605514389014173,-0.0182037942686934,0.0888993843088465,0.708456499779504,-0.068692431071907,0.0381768422753705,0.00375775336752149,0.18294443949415 )
comparemat L G

// as above but pre-standardize
lasso2 $model, l(150 15 1.5) prestd
mat L = e(betas)
comparemat L G

lasso2 $model, l(150 15 1.5) unitload
mat L = e(betas)
/* 
> # lasso estimation (w/o standardize & intercept)
> r<-glmnet(X,y,lambda=c(150, 15, 1.5)/(2*n),standardize=FALSE,intercept=TRUE)
> t(coef(r))
3 x 9 sparse Matrix of class "dgCMatrix"
   (Intercept)    lcavol   lweight          age       lbph        svi         lcp     gleason
s0   2.0809125 .         .          .           .          .           .          .          
s1   1.4264961 0.5789631 0.1812337 -0.008794604 0.07658667 0.04715613  .          .          
s2   0.5709279 0.5607932 0.5718048 -0.019339712 0.09484563 0.65884647 -0.07312879 0.003437608
         pgg45
s0 0.016302332
s1 0.006413878
s2 0.005003847
*/
mat G = ( 0,0,0,0,0,0,0,0.0163023319952739,2.08091249516677 \ 0.578963079723197,0.181233651933207,-0.00879460357040878,0.0765866715516214,0.0471561282079499,0,0,0.00641387754085344,1.42649606164357 \ 0.56079320119559,0.571804769257873,-0.0193397117375188,0.0948456306696097,0.658846467359134,-0.0731287924194953,0.0034376077659711,0.00500384714844935,0.570927925454684 ) 
comparemat L G


lasso2 $model, l(150 15 1.5) nocons
mat L = e(betas)
/* 
> # lasso estimation (w/ standardize & w/o intercept)
> r<-glmnet(X,y,lambda=c(150, 15, 1.5)/(2*n),standardize=TRUE,intercept=FALSE)
> t(coef(r))
3 x 9 sparse Matrix of class "dgCMatrix"
   (Intercept)     lcavol   lweight         age       lbph       svi        lcp    gleason
s0           . 0.03202811 0.3597488  .          .          .          .         0.15958484
s1           . 0.49155721 0.4598487  .          0.02987895 0.5357571  .         .         
s2           . 0.54272362 0.6264995 -0.01776074 0.08529663 0.7089062 -0.0691351 0.05116263
         pgg45
s0 .          
s1 0.001132923
s2 0.003532953
*/
mat G = ( 0.0320281112917762,0.359748772081613,0,0,0,0,0.159584841969938,0  \ 0.491557214223318,0.459848707929377,0,0.0298789475809353,0.53575707154284,0,0,0.00113292264640293 \ 0.542723617710186,0.626499540101458,-0.0177607354082528,0.0852966257132293,0.708906240969273,-0.0691351039443382,0.0511626342288098,0.00353295335701127 )
comparemat L G

// as above but pre-standardize
lasso2 $model, l(150 15 1.5) nocons
mat L = e(betas)
comparemat L G


lasso2 $model, l(150 15 1.5) nocons unitload
mat L = e(betas)
/* 
> # lasso estimation (w/o standardize & w/o intercept)
> r<-glmnet(X,y,lambda=c(150, 15, 1.5)/(2*n),standardize=FALSE,intercept=FALSE)
> t(coef(r))
3 x 9 sparse Matrix of class "dgCMatrix"
   (Intercept)    lcavol   lweight         age       lbph        svi         lcp    gleason
s0           . .         .          0.03263871 .          .           .          .         
s1           . 0.5582166 0.4271199  .          0.02888257 0.01868081  .          .         
s2           . 0.5522462 0.6108130 -0.01745695 0.08625277 0.66545544 -0.07473151 0.05386605
         pgg45
s0 0.014883525
s1 0.006455549
s2 0.004082051
*/
mat G = ( 0,0,0.0326387149332038,0,0,0,0,0.0148835249197989 \ 0.558216559129859,0.427119922488729,0,0.0288825748095177,0.0186808135198926,0,0,0.00645554874090459  \ 0.552246180132136,0.610812971251225,-0.0174569524891446,0.0862527702913333,0.665455440830147,-0.0747315133696167,0.0538660488175342,0.00408205134388933   )
comparemat L G

*** now using lglmnet option ***

lasso2 $model, l(.8 .6 .2) lglmnet
mat L = e(betas)
/*
> # lasso estimation (standardize & intercept)
> r<-glmnet(X,y,lambda=c(.8,.6,.2),standardize=TRUE,intercept=TRUE)
> t(coef(r))
3 x 9 sparse Matrix of class "dgCMatrix"
   (Intercept)     lcavol   lweight age lbph       svi lcp gleason pgg45
s0   2.4283862 0.03703726 .           .    . .           .       .     .
s1   2.1981140 0.20760804 .           .    . .           .       .     .
s2   0.7154547 0.45182494 0.2966946   .    . 0.3523241   .       .     .
*/
mat G = ( 0.0370372606890949,0,0,0,0,0,0,0,2.42838622158533 \ 0.207608043458756,0,0,0,0,0,0,0,2.19811403069554 \ 0.45182494276911,0.296694633018004,0,0,0.352324077604082,0,0,0,0.715454720149449 )
comparemat L G

lasso2 $model, l(.8 .6 .2) lglmnet unitload
mat L = e(betas)
/*
> # lasso estimation (w/o standardize & intercept)
> r<-glmnet(X,y,lambda=c(.8,.6,.2),standardize=FALSE,intercept=TRUE)
> t(coef(r))
3 x 9 sparse Matrix of class "dgCMatrix"
   (Intercept)    lcavol lweight age       lbph svi lcp gleason       pgg45
s0    2.081743 .               .   . .            .   .       . 0.016268285
s1    1.950896 0.1372576       .   . .            .   .       . 0.014034947
s2    1.618724 0.4893253       .   . 0.02387818   .   .       . 0.008066494
> asmat(t(coef(r)))
*/
mat G = ( 0,0,0,0,0,0,0,0.0162682849336487,2.08174261166929 \ 0.137257628322798,0,0,0,0,0,0,0.0140349465593846,1.95089551137846 \ 0.489325292943062,0,0,0.0238781766783061,0,0,0,0.00806649425516767,1.61872396370499 )
comparemat L G

lasso2 $model, l(.8 .6 .2) lglmnet  nocons
mat L = e(betas)
/*
> # lasso estimation (w/ standardize & w/o intercept)
> r<-glmnet(X,y,lambda=c(.8,.6,.2),standardize=TRUE,intercept=FALSE)
> t(coef(r))
3 x 9 sparse Matrix of class "dgCMatrix"
   (Intercept)     lcavol   lweight age lbph       svi lcp    gleason pgg45
s0           . 0.01001615 0.3557483   .    . .           . 0.16581999     .
s1           . 0.17424422 0.3773174   .    . .           . 0.12370274     .
s2           . 0.43879201 0.4531537   .    . 0.3434186   . 0.02362562     .
> asmat(t(coef(r)))
*/
mat G = ( 0.0100161543047344,0.355748298540682,0,0,0,0,0.165819987155045,0 \ 0.174244224723816,0.377317383071473,0,0,0,0,0.123702743345189,0 \ 0.438792010313506,0.453153674363568,0,0,0.343418593611708,0,0.0236256173546178,0 )
comparemat L G

lasso2 $model, l(.8 .6 .2) lglmnet unitload nocons
mat L = e(betas)
/*
> # lasso estimation (w/o standardize & w/o intercept)
> r<-glmnet(X,y,lambda=c(.8,.6,.2),standardize=FALSE,intercept=FALSE)
> t(coef(r))
3 x 9 sparse Matrix of class "dgCMatrix"
   (Intercept)    lcavol lweight        age lbph svi lcp gleason       pgg45
s0           . .               . 0.03264146    .   .   .       . 0.014860920
s1           . 0.1357669       . 0.03062938    .   .   .       . 0.012720689
s2           . 0.4877323       . 0.02542719    .   .   .       . 0.007070216
> asmat(t(coef(r)))
*/
mat G = ( 0,0,0.0326414588433045,0,0,0,0,0.0148609196162634 \ 0.13576687334887,0,0.0306293800710363,0,0,0,0,0.0127206887941435 \ 0.487732337283528,0,0.0254271936782152,0,0,0,0,0.00707021639137941 )
comparemat L G

********************************************************************************
*** replicate sqrt-lasso Matlab program										 ***
********************************************************************************

// uses the Matlab code "SqrtLassoIterative.m" (available on request)

lasso2 $model, sqrt l(40) unitload
mat a=e(betaAll)
/*
ans =

    0.3627
         0
         0
         0
         0
         0
         0
    0.0103
    1.7383
*/
mat b = (0.3627,0,0,0,0,0,0,0.0103,1.7383)
comparemat a b

lasso2 $model, sqrt l(10) unitload
mat a=e(betaAll)
/*
ans =

    0.5771
    0.1965
   -0.0092
    0.0773
    0.0685
         0
         0
    0.0063
    1.3946
*/
mat b = (0.5771,0.1965,-0.0092,0.0773,0.0685,0,0,0.0063,1.3946)
comparemat a b

lasso2 $model, sqrt l(1) unitload
mat a=e(betaAll)
/*
ans =

    0.5610
    0.5774
   -0.0196
    0.0950
    0.6700
   -0.0766
    0.0088
    0.0049
    0.5259
*/
mat b = (0.5610, 0.5774,-0.0196,0.0950,0.6700,-0.0766,0.0088,0.0049,0.5259)
comparemat a b

********************************************************************************
*** validation using elasticregress											 ***
********************************************************************************

// NB: check allows for for a 2.5% deviation
// Note that lambda=50 and alpha=0.25 yields a 3.5% deviation.
/*
foreach li of numlist 0.1 1 3 5 10 50 100 {
 foreach ai of numlist  0 0.01 /* 0.25 */ 0.5 0.75 0.9 0.99 1 {
	di
	di as text "lambda=`li'  alpha=`ai'"
	qui lasso2 $model, l(`li') alpha(`ai') prestd
	mat A = e(betaAll)
	local lam = `li'/97/2 // uses different objective function
	elasticregress $model, lambda(`lam') alpha(`ai') tol(10e-10)
	mat B = e(b)
	comparemat A B , tol(0.025)
 }
}
*/

********************************************************************************
*** norecover option														 ***
********************************************************************************

// partial() with constant
lasso2 $model, partial(age) l(50 20 10) 
mat A = e(betas)
mat A = A[2,1..9]
lasso2 $model, l(20) partial(age) postall
mat B = e(b)
comparemat A B

lasso2 $model, partial(age) l(50 20 10) nor 
mat A = e(betas)
mat A = A[2,1..7]
lasso2 $model, l(20) partial(age) nor postall
mat B = e(b)
comparemat A B

// partial() with constant, unitloadings
lasso2 $model, partial(age) l(50 20 10) unitl
mat A = e(betas)
mat A = A[2,1..9]
lasso2 $model, l(20) partial(age) postall unitl
mat B = e(b)
comparemat A B

lasso2 $model, partial(age) l(50 20 10) nor  unitl
mat A = e(betas)
mat A = A[2,1..7]
lasso2 $model, l(20) partial(age) nor postall unitl
mat B = e(b)
comparemat A B

// no partial() w/ constant, unitloadings
lasso2 $model, l(50 20 10) unitl
mat A = e(betas)
mat A = A[2,1..9]
lasso2 $model, l(20) postall unitl
mat B = e(b)
comparemat A B

lasso2 $model, l(50 20 10) nor  unitl
mat A = e(betas)
mat A = A[2,1..9]
lasso2 $model, l(20) nor postall unitl
mat B = e(b)
comparemat A B

// no partial() w/o constant, unit loadings
lasso2 $model, l(50 20 10) unitl nocons
mat A = e(betas)
mat A = A[2,1..8]
lasso2 $model, l(20) postall unitl nocons
mat B = e(b)
comparemat A B

lasso2 $model, l(50 20 10) nor unitl nocons
mat A = e(betas)
mat A = A[2,1..8]
lasso2 $model, l(20) nor postall unitl nocons
mat B = e(b)
comparemat A B


********************************************************************************
*** options																	 ***
********************************************************************************

cap lasso2 $model, alpha(0) sqrt
if _rc != 198 {
	exit 1
} 
*
// should say that lcount/lmax/lminr are being ignored
lasso2 $model, lambda(10) lcount(10)
lasso2 $model, lambda(10) lmax(100)
lasso2 $model, lambda(10) lminr(0.01)

// plotting only supported for lambda list
lasso2 $model, lambda(10) plotpath(lambda)

// incompatible options wrt penalty loadings
cap lasso2 $model, ploadings(abc) adaptive
if _rc != 198 {
	exit 1
} 
*
cap lasso2 $model, ploadings(abc) unitload
if _rc != 198 {
	exit 1
} 
cap lasso2 $model, ploadings(abc) adatheta(3)
if _rc != 198 {
	exit 1
} 
*
cap lasso2 $model, adaptive unitload
if _rc != 198 {
	exit 1
} 
*

// var may not appear in partial() and notpen()
cap lasso2 $model, partial(age svi lcp) notpen(age svi)
if _rc != 198 {
	exit 1
} 
*

// controls the output and content of e(b)
lasso2 $model, l(20) displayall
lasso2 $model, l(20) postall
mat list e(b)

lasso2 $model, l(20) displayall postall
mat list e(b)

********************************************************************************
*** verify results are the same for scalar lambda vs lambda list			 ***
********************************************************************************

global lambdalist 150 130 100 80 60 30 10 5 3 1

* lasso
lasso2 $model, l($lambdalist)
mat A = e(betas)
local j=1
foreach i of numlist $lambdalist {
	mat a = A[`j',1..9]
	lasso2 $model, l(`i')
	mat b = e(betaAll)
	comparemat a b
	local j=`j'+1
}
*

* lasso (w/o constant)
lasso2 $model, l($lambdalist) nocons
mat A = e(betas)
local j=1
foreach i of numlist $lambdalist {
	mat a = A[`j',1..8]
	lasso2 $model, l(`i') nocons
	mat b = e(betaAll)
	comparemat a b
	local j=`j'+1
}
*

* post-lasso
lasso2 $model, l($lambdalist) ols
mat A = e(betas)
local j=1
foreach i of numlist $lambdalist {
	mat a = A[`j',1..9]
	lasso2 $model, l(`i')  
	mat b = e(betaAllOLS)
	comparemat a b
	local j=`j'+1
}
*

global sqrtlambdalist 100 40 20 10 5 1
* sqrt-lasso
lasso2 $model, l($sqrtlambdalist) sqrt   
mat A = e(betas)
local j=1
foreach i of numlist $sqrtlambdalist {
	mat a = A[`j',1..8]
	di `i'
	lasso2 $model, l(`i') sqrt 
	mat b = e(betaAll)
	mat b = b[1,1..8]
	comparemat a b
	local j=`j'+1
}
*

* post-sqrt-lasso ols
lasso2 $model, l($sqrtlambdalist) sqrt ols
mat A = e(betas)
local j=1
foreach i of numlist $sqrtlambdalist {
	di "this lambda: `i'"
	mat a = A[`j',1..9]
	lasso2 $model, l(`i') sqrt ols
	mat b = e(betaAllOLS)
	comparemat a b
	local j=`j'+1
}
*

* ridge
lasso2 $model, l($lambdalist) alpha(0)
mat A = e(betas)
local j=1
foreach i of numlist $lambdalist {
	mat a = A[`j',1..9]
	lasso2 $model, l(`i') alpha(0)
	mat b = e(betaAll)
	comparemat a b
	local j=`j'+1
}
*

* ols ridge
lasso2 $model, l($lambdalist) alpha(0) ols
mat A = e(betas)
local j=1
foreach i of numlist $lambdalist {
	mat a = A[`j',1..9]
	lasso2 $model, l(`i') alpha(0) ols
	mat b = e(betaAllOLS)
	comparemat a b
	local j=`j'+1
}
*
	
* elastic net
foreach ai of numlist 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 {
lasso2 $model, l($lambdalist) alpha(`ai')
mat A = e(betas)
local j=1
foreach i of numlist $lambdalist {
	mat a = A[`j',1..9]
	lasso2 $model, l(`i') alpha(`ai')
	mat b = e(betaAll)
	comparemat a b
	local j=`j'+1
}
}
*

* elastic net with ols
foreach ai of numlist 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 {
lasso2 $model, l($lambdalist) alpha(`ai') ols
mat A = e(betas)
local j=1
foreach i of numlist $lambdalist {
	mat a = A[`j',1..9]
	lasso2 $model, l(`i') alpha(`ai') ols
	mat b = e(betaAllOLS)
	comparemat a b
	local j=`j'+1
}
}
*


********************************************************************************
*** verify adapative weights												 ***
********************************************************************************

** lasso with ada theta = 1
lasso2 $model, adaptive verb
mat psi = e(Psi)

reg $model
mat bols = e(b)

mat checkups = J(1,8,.)
forvalues i=1(1)8 {
	mat checkups[1,`i'] = abs(1/bols[1,`i'])
}
comparemat psi checkups

** lasso with ada theta = 2
lasso2 $model, adaptive verb adatheta(2)
mat psi = e(Psi)

reg $model
mat bols = e(b)

mat checkups = J(1,8,.)
forvalues i=1(1)8 {
	mat checkups[1,`i'] = abs(1/bols[1,`i'])^2
}
comparemat psi checkups

// use of adaloadings option
lasso2 $model , l(10) alph(0)
mat b = e(betaAll)
lasso2 $model, adaptive adal(b) adat(2)
mat psi = e(Psi)
mat checkups = J(1,8,.)
forvalues i=1(1)8 {
	mat checkups[1,`i'] = abs(1/b[1,`i'])^2
}
comparemat psi checkups

// use of adaloadings option
lasso2 $model , l(10) alph(0)
mat b = e(betaAll)
lasso2 $model, adaptive adal(b) adat(1)
mat psi = e(Psi)
mat checkups = J(1,8,.)
forvalues i=1(1)8 {
	mat checkups[1,`i'] = abs(1/b[1,`i'])
}
comparemat psi checkups

********************************************************************************
*** pre-estimation standardisation vs std on the fly   				 		 ***
********************************************************************************

// lasso
// standardisation using penalty loadings (default)
lasso2 $model, l(10) 
mat A = e(beta)
// pre-estimation standardisation of data
lasso2 $model, l(10) prestd  
mat B = e(beta)
comparemat A B , tol(10e-6)

// lasso [nocons]
// standardisation using penalty loadings (default)
lasso2 $model, l(10)  nocons
mat A = e(beta)
// pre-estimation standardisation of data
lasso2 $model, l(10) prestd nocons 
mat B = e(beta)
comparemat A B , tol(10e-6)

// sqrt lasso
// standardisation using penalty loadings (default)
lasso2 $model, l(10) sqrt 
mat A = e(beta)
// pre-estimation standardisation of data
lasso2 $model, l(10) sqrt prestd
mat B = e(beta)
comparemat A B , tol(10e-6)

// sqrt lasso [nocons]
// standardisation using penalty loadings (default)
lasso2 $model, l(10) sqrt nocons
mat A = e(beta)
// pre-estimation standardisation of data
lasso2 $model, l(10) sqrt prestd nocons
mat B = e(beta)
comparemat A B , tol(10e-6)

// elastic net
foreach lam of numlist 1 10 50 150 160 {
foreach ai of numlist 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 {
	// in original units
	// standardisation using penalty loadings (default)
	lasso2 $model, l(`lam')  alpha(`ai')
	mat A = e(beta)

	// pre-estimation standardisation of data
	lasso2 $model, l(`lam') prestd alpha(`ai')
	mat B = e(beta)
	comparemat A B , tol(10e-6)
}
}
*

// elastic net [nocons]
foreach lam of numlist 1 10 50 150 160 {
foreach ai of numlist 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 {
	// in original units
	// standardisation using penalty loadings (default)
	lasso2 $model, l(`lam')  alpha(`ai') nocons
	mat A = e(beta)

	// pre-estimation standardisation of data
	lasso2 $model, l(`lam') prestd alpha(`ai') nocons
	mat B = e(beta)
	comparemat A B , tol(10e-6)
}
}
*

********************************************************************************
*** verify ridge regression results											 ***
********************************************************************************

lasso2 $model, l(150) alpha(0) unitload
mat A = e(beta)
mat A = A[1,1..8] // excl intercept

estridge $model, l(150)
mat B = r(bhat)

comparemat A B , tol(10e-6)


********************************************************************************
*** verify post-estimation OLS results										 ***
********************************************************************************

* lasso
foreach i of numlist 0.5 1 4 10 15 50 150 {
	lasso2 $model, l(`i') ols
	mat A = e(b)
	reg lpsa `e(selected)'
	mat B = e(b)
	comparemat A B
}
*

* lasso (w/o constant)
foreach i of numlist 0.5 1 4 10 15 50 150 {
	lasso2 $model, l(`i') ols nocons
	mat A = e(b)
	reg lpsa `e(selected)', nocons
	mat B = e(b)
	comparemat A B
}
*

* sqrt lasso
foreach i of numlist 0.5 1 4 10 15 50 150 {
	lasso2 $model, l(`i') ols sqrt
	mat A = e(b)
	reg lpsa `e(selected)'
	mat B = e(b)
	comparemat A B
}
*

* elastic net
foreach i of numlist 0.5 1 4 10 15 50 150 {
	lasso2 $model, l(`i') ols alpha(.5)
	mat A = e(b)
	reg lpsa `e(selected)'
	mat B = e(b)
	comparemat A B
}
*

* ridge
foreach i of numlist 0.5 1 4 10 15 50 150 {
	lasso2 $model, l(`i') ols alpha(0)
	mat A = e(b)
	reg lpsa `e(selected)'
	mat B = e(b)
	comparemat A B
}
*

********************************************************************************
*** partial() vs notpen()													 ***
********************************************************************************

lasso2 $model, partial(lcp) l(50)
mat A = e(b) 
lasso2 $model, notpen(lcp) l(50)
mat B = e(b)
comparevec A B  

lasso2 $model, partial(lcp) l(50) sqrt
mat A = e(b) 
lasso2 $model, notpen(lcp) l(50) sqrt
mat B = e(b)
comparevec A B  

lasso2 $model, partial(lcp) l(50) alpha(0.5)
mat A = e(b) 
lasso2 $model, notpen(lcp) l(50) alpha(0.5)
mat B = e(b)
comparevec A B  

lasso2 $model, partial(lcp) l(50) alpha(0)
mat A = e(b) 
lasso2 $model, notpen(lcp) l(50) alpha(0)
mat B = e(b)
comparevec A B  

lasso2 $model, lambda(10) partial(age) notpen(svi)
mat A = e(b) 
lasso2 $model, lambda(10) partial(svi) notpen(age)
mat B = e(b)
comparevec A B  

********************************************************************************
*** penalty loadings vs notpen (see help file)						         ***
********************************************************************************

lasso2 $model, l(10) notpen(lcavol) unitloadings
mat A = e(b)

mat myloadings = (0,1,1,1,1,1,1,1)
lasso2 $model, l(10) ploadings(myloadings)
mat B = e(b)

comparemat A B


********************************************************************************
*** ic option to control display of output 							***
********************************************************************************

di as red "should display EBIC (the default):"
lasso2 $model  
sleep 1000
di as red "should display AIC:"
lasso2 $model , ic(aic)
sleep 1000
di as red "should display AICc:"
lasso2 $model , ic(aicc)
sleep 1000
di as red "should display BIC:"
lasso2 $model , ic(bic)
sleep 1000
di as red "should display EBIC:"
lasso2 $model , ic(ebic)


********************************************************************************
*** degrees of freedom calculation          						   ***
********************************************************************************

// replicate dof w/o constant and no standardisation [OK]
lasso2 $model ,  alpha(0) l(20 .1)  long unitload    nocons nopath
mat D= e(dof)
mat list e(dof)

putmata y=(lpsa) X=(lcavol lweight  age lbph  svi  lcp gleason pgg45  ), replace
mata: df=trace(X*invsym((X'X):+20/2*I(8))*X') 
mata: df

mata: st_local("df",strofreal(df))
assert reldif(el(D,1,1),`df')<10^-6

// standardisation w/o constant [OK]
lasso2 $model ,  alpha(0)   l(20 .1)  long      nocons nopath
mat D1 = e(dof)
mat list e(dof)
lasso2 $model ,  alpha(0)   l(20 .1)  long prestd   nocons nopath
mat D2 = e(dof)
mat list e(dof)
comparemat D1 D2

putmata y=(lpsa) X=(lcavol lweight  age lbph  svi  lcp gleason pgg45  ), replace
mata: s = sqrt(mean((X:-mean(X)):^2))
mata: ssq = s:^2
mata: Xs=X:/s 
mata: df1=trace(X*invsym((X'X):+20/2*diag(ssq))*X')  // "on the fly" standardisation
mata: df2=trace(Xs*invsym((Xs'Xs):+20/2*I(8))*Xs')   // pre-standardisation
mata: df1,df2
mata: st_local("df1",strofreal(df1))
mata: st_local("df2",strofreal(df2))
assert reldif(el(D1,1,1),`df1')<10^-6
assert reldif(el(D1,1,1),`df2')<10^-6
assert reldif(`df1',`df2')<10^-6

// dof with constant and no standardisation [OK]
lasso2 $model ,  alpha(0) l(20 .1)  long unitload  nopath   
mat list e(dof)
mat D = e(dof)

putmata y=(lpsa) X=(lcavol lweight  age lbph  svi  lcp gleason pgg45  ), replace
mata: Xone=(X,J(97,1,1))
mata: Psicons = I(9)
mata: Psicons[9,9]=0
mata: Xdm = X :- mean(X)
mata: trace(X*invsym((X'X):+20/2*I(8))*X') 			// this is wrong (ignores constant)
mata: trace(Xdm*invsym((Xdm'Xdm):+20/2*I(8))*Xdm')   // this is missing the constant
mata: df1=trace(Xone*invsym((Xone'Xone):+20/2*Psicons)*Xone')  // this should be correct
mata: df2=trace(Xdm*invsym((Xdm'Xdm):+20/2*I(8))*Xdm')+1  // this is correct
mata: df1,df2
mata: st_local("df1",strofreal(df1))
mata: st_local("df2",strofreal(df2))
assert reldif(el(D,1,1),`df1')<10^-6
assert reldif(el(D,1,1),`df2')<10^-6
assert reldif(`df1',`df2')<10^-6

// standardisation w/  constant [OK]
lasso2 $model ,  alpha(0) l(20 10 1 .1)  long nopath
mat list e(dof)
mat D1 = e(dof)
lasso2 $model ,  alpha(0) l(20 10 1 .1)  long prestd nopath  
mat list e(dof)
mat D2 = e(dof)
comparemat D1 D2

putmata y=(lpsa) X=(lcavol lweight  age lbph  svi  lcp gleason pgg45), replace
mata: s = sqrt(mean((X:-mean(X)):^2))
mata: ssq = s:^2
mata: Xs=(X:-mean(X)):/s 
mata: Xone=(X,J(97,1,1))
mata: df1=trace(Xdm*invsym((Xdm'Xdm):+20/2*diag(ssq))*Xdm') +1
mata: df2=trace(Xs*invsym((Xs'Xs):+20/2*I(8))*Xs') +1
mata: df1,df2
mata: st_local("df1",strofreal(df1))
mata: st_local("df2",strofreal(df2))
assert reldif(el(D1,1,1),`df1')<10^-6
assert reldif(el(D1,1,1),`df2')<10^-6
assert reldif(`df1',`df2')<10^-6

********************************************************************************
*** lic option 						    							***
********************************************************************************

* check that right lambda is used 
foreach ic of newlist ebic aic aicc bic {
	lasso2 $model 
	local optlambda=e(l`ic') 
	lasso2, lic(`ic') postres
	local thislambda=e(lambda)
	assert reldif(`optlambda',`thislambda')<10^-8
}
*

********************************************************************************
*** predicted values (see help file)										 ***
********************************************************************************

// xbhat1 is generated by re-estimating the model for lambda=10.  The noisily 
// option triggers the display of the
// estimation results.  xbhat2 is generated by linear approximation using the 
// two beta estimates closest to
//    lambda=10.
lasso2 $model
cap drop xbhat1
predict double xbhat1, xb l(10) noisily
cap drop xbhat2
predict double xbhat2, xb l(10) approx

//    The model is estimated explicitly using lambda=100.  If lasso2 is 
//called with a scalar lambda value, the
//   subsequent predict command requires no lambda() option.
lasso2 $model, lambda(10)
cap drop xbhat3
predict double xbhat3, xb

//    All three methods yield the same results.  However note that the linear 
// approximation is only exact for the lasso
//   which is piecewise linear.
assert (xbhat1-xbhat2<10e-8) & (xbhat3-xbhat2<10e-8) 

//It is also possible to obtain predicted values by referencing a specific
// lambda ID using the lid() option.
lasso2 $model
cap drop xbhat4
predict double xbhat4, xb lid(21)
cap drop xbhat5
predict double xbhat5, xb l(25.45473900468241)
assert (xbhat4-xbhat5<10e-8)


********************************************************************************
*** misc options/syntax checks		                                         ***
********************************************************************************

// Support for inrange(.) and similar [if] expressions:
lasso2 $model if inrange(age,50,70)


********************************************************************************
*** plotting                                                                 ***
********************************************************************************

lasso2 $model

lasso2, plotpath(lambda) plotlabel plotopt(legend(off))

lasso2, plotpath(lnlambda) plotlabel plotopt(legend(off))

lasso2, plotpath(norm) plotlabel plotopt(legend(off))

lasso2, plotpath(norm) plotlabel plotopt(legend(off)) plotvar(lcavol)

********************************************************************************
*** validate RSS / r-squared    				                             ***
********************************************************************************

// loop over three mehods. "nopath" corresponds to default standardisatin on the fly.
// "nopath" is just a placeholder that doesn't affect calculations.
foreach method in prestd unitl nopath {
foreach a of numlist 0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1 {
	lasso2 $model, alpha(`a') l(10)  `method'
	cap drop xb
	cap drop r
	predict double xb, xb
	predict double r, r

	sum lpsa
	di r(sd)^2*98
	local tss=r(sd)^2*98
	sum xb
	di r(sd)^2*98
	local ess=r(sd)^2*98
	sum r
	di r(sd)^2*98
	local rss=r(sd)^2*98
	 
	di "r-squared"
	local rsq = 1-`rss'/`tss'
	di `rsq'

	lasso2 $model, alpha(`a') l(10 0.1) `method'
	mat list e(rsq)
	mat RSQ = e(rsq)
	di el(RSQ,1,1)
	di reldif(`rsq',el(RSQ,1,1))
	assert reldif(`rsq',el(RSQ,1,1))<10^(-3)
}
}
*

********************************************************************************
*** validate EBIC default gamma     				                         ***
********************************************************************************

webuse air2, clear

lasso2 air L(1/24).air

local myebicgamma = 1-log(e(N))/(2*log(e(p)))

di `myebicgamma'
di e(ebicgamma)
assert reldif(`myebicgamma',e(ebicgamma))<10^(-3)

********************************************************************************
*** panel example: validate within transformation                            ***
********************************************************************************

use "http://fmwww.bc.edu/ec-p/data/macro/abdata.dta", clear

lasso2 ys l(0/3).k l(0/3).n, fe l(10)  
mat A = e(b)

lasso2 ys l(0/3).k l(0/3).n ibn.id, partial(ibn.id) l(10) nor
mat B = e(b)

comparemat A B

// noftools option
lasso2 ys l(0/3).k l(0/3).n, fe l(10)
savedresults save ftools e()
cap noi assert "`e(noftools)'"==""  // will be error if ftools not installed
lasso2 ys l(0/3).k l(0/3).n, fe l(10) noftools
assert "`e(noftools)'"=="noftools"
savedresults comp ftools e(), exclude(macros: lasso2opt)

********************************************************************************
***  check if partial() works with fe				                         ***
***  and followed by lic()													 ***
********************************************************************************

clear 
use https://www.stata-press.com/data/r16/nlswork

lasso2 ln_w grade age c.age#c.age ttl_exp c.ttl_exp#c.ttl_exp tenure ///
		c.tenure#c.tenure 2.race not_smsa south i.year, fe  
ereturn list 

lasso2 ln_w grade age c.age#c.age ttl_exp c.ttl_exp#c.ttl_exp tenure ///
		c.tenure#c.tenure 2.race not_smsa south i.year, fe partial(i.year) 
lasso2, lic(ebic)

lasso2 ln_w grade age c.age#c.age ttl_exp c.ttl_exp#c.ttl_exp tenure ///
		c.tenure#c.tenure 2.race not_smsa south i.year, fe partial(i.year) ///
		lic(ebic)

********************************************************************************
***  check residuals with fe												 ***
********************************************************************************
		
clear
use https://www.stata-press.com/data/r16/nlswork

replace ln_w = . if year == 80

lasso2 ln_w grade age c.age#c.age ttl_exp c.ttl_exp#c.ttl_exp tenure ///
		c.tenure#c.tenure 2.race not_smsa south , fe   
lasso2, lic(ebic) postres ols	
		
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
