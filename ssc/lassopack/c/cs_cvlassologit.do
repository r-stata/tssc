
clear all 

insheet using prostate.data, clear

gen ybin = lpsa > 2

gen myf = 1
replace myf = 2 if _n > 25
replace myf = 3 if _n > 50
replace myf = 4 if _n > 75

local tol = 0.01

********************************************************************************
*** deviance 																 ***
********************************************************************************

// ok
cvlassologit ybin lcavol-pgg45, foldv(myf) l(.2 0.11 .1 0.05 0.001) lossm(deviance)  lambdan 
mat Scvm = e(mloss)'
mat Scvsd = e(cvsd)'
mat Gcvm = ( 2.08254581596245 \ 2.01772455876113 \ 2.01521038363898 \ 1.85552483852628 \ 1.84971975634164 )
mat Gcvsd = ( 0.983003948645934 \ 1.01362212332398 \ 1.01620614729319 \ 0.891321820785998 \ 0.769254466742782 )
assert mreldif(Scvm,Gcvm)<`tol'
assert mreldif(Scvsd,Gcvsd)<`tol'
// > cv$lambda.min
// [1] 0.001
// > cv$lambda.1se
// [1] 0.2
// >
assert e(lopt)==0.001
assert e(lse)==0.2

// ok
cvlassologit ybin lcavol-pgg45, foldv(myf) l(.2 0.11 .1 0.05 0.001) lossm(deviance) nocons lambdan storeest(d)
mat Scvm = e(mloss)'
mat Scvsd = e(cvsd)'
mat Gcvm = ( 1.88703159578689 \ 1.84295622517937 \ 1.84604832914781 \ 1.71315139941324 \ 2.06072320470385 )
mat Gcvsd = ( 0.807683652389135 \ 0.890207093045443 \ 0.89735498493324 \ 0.831483091061569 \ 0.885306606625466 )
assert mreldif(Scvm,Gcvm)<`tol'
assert mreldif(Scvsd,Gcvsd)<`tol'
// > cv$lambda.min
// [1] 0.05
// > cv$lambda.1se
// [1] 0.2
assert e(lopt)==0.05
assert e(lse)==0.2

//ok
cvlassologit ybin lcavol-pgg45, foldv(myf) l(.2 0.11 .1 0.05 0.001) lossm(deviance) nostd lambdan
mat Scvm = e(mloss)'
mat Scvsd = e(cvsd)'
mat Gcvm = ( 2.17122209560962 \ 2.07796719364886 \ 2.06600265938377 \ 1.92873373066042 \ 1.86328278602207 )
mat Gcvsd = ( 0.976586472178121 \ 0.994800183102049 \ 1.00164196360505 \ 0.919465328924813 \ 0.772522333205428 )
assert mreldif(Scvm,Gcvm)<`tol'
assert mreldif(Scvsd,Gcvsd)<`tol'
// > cv$lambda.min
// [1] 0.001
// > cv$lambda.1se
// [1] 0.2
assert e(lopt)==0.001
assert e(lse)==0.2

// ok
cvlassologit ybin lcavol-pgg45, foldv(myf) l(.2 0.11 .1 0.05 0.001) lossm(deviance) nocons nostd lambdan 
mat Scvm = e(mloss)'
mat Scvsd = e(cvsd)'
mat Gcvm = ( 2.04631386499165 \ 1.96612060457599 \ 1.95374855866588 \ 1.77310874352822 \ 2.07059117964739 )
mat Gcvsd = ( 0.881443394729349 \ 0.910706849371597 \ 0.915312643481268 \ 0.812051490921067 \ 0.890972059994161 )
assert mreldif(Scvm,Gcvm)<`tol'
assert mreldif(Scvsd,Gcvsd)<`tol'
// > cv$lambda.min
// [1] 0.05
// > cv$lambda.1se
// [1] 0.2
assert e(lopt)==0.05
assert e(lse)==0.2

********************************************************************************
*** classification															 ***
********************************************************************************

// ok
cvlassologit ybin lcavol-pgg45, foldv(myf) l(.2 0.11 .1 0.05 0.001) lossm(class) lambdan  
mat Scvm = e(mloss)'
mat Scvsd = e(cvsd)'
mat Gcvm = ( 0.329896907216495 \ 0.422680412371134 \ 0.422680412371134 \ 0.422680412371134 \ 0.371134020618557 )
mat Gcvsd = ( 0.233921440752119 \ 0.21546802804412 \ 0.21546802804412 \ 0.219888311955527 \ 0.175517201389091 )
assert mreldif(Scvm,Gcvm)<`tol'
assert mreldif(Scvsd,Gcvsd)<`tol'
// > cv$lambda.min
// [1] 0.2
// > cv$lambda.1se
// [1] 0.2
assert e(lopt)==0.2
assert e(lse)==0.2

// ok
cvlassologit ybin lcavol-pgg45, foldv(myf) l(.2 0.11 .1 0.05 0.001) lossm(class) nocons lambdan
mat Scvm = e(mloss)'
mat Scvsd = e(cvsd)'
mat Gcvm =( 0.329896907216495 \ 0.391752577319588 \ 0.391752577319588 \ 0.422680412371134 \ 0.43298969072165 )
mat Gcvsd = ( 0.233921440752119 \ 0.21676631645944 \ 0.21676631645944 \ 0.210302540152146 \ 0.201492992636001 )
assert mreldif(Scvm,Gcvm)<`tol'
assert mreldif(Scvsd,Gcvsd)<`tol'
// > cv$lambda.min
// [1] 0.2
// > cv$lambda.1se
// [1] 0.2
assert e(lopt)==0.2
assert e(lse)==0.2

//ok
cvlassologit ybin lcavol-pgg45, foldv(myf) l(.2 0.11 .1 0.05 0.001) lossm(class) nostd lambdan
mat Scvm = e(mloss)'
mat Scvsd = e(cvsd)'
mat Gcvm = ( 0.484536082474227 \ 0.443298969072165 \ 0.43298969072165 \ 0.43298969072165 \ 0.381443298969072 )
mat Gcvsd = ( 0.195557378626205 \ 0.212481204585373 \ 0.215980406627655 \ 0.215980406627655 \ 0.176370943087664 )
assert mreldif(Scvm,Gcvm)<`tol'
assert mreldif(Scvsd,Gcvsd)<`tol'
// > cv$lambda.min
// [1] 0.001
// > cv$lambda.1se
// [1] 0.2
assert e(lopt)==0.001
assert e(lse)==0.2

// ok
cvlassologit ybin lcavol-pgg45, foldv(myf) l(.2 0.11 .1 0.05 0.001) lossm(class) nocons nostd lambdan  
mat Scvm = e(mloss)'
mat Scvsd = e(cvsd)'
mat Gcvm = ( 0.45360824742268 \ 0.412371134020619 \ 0.422680412371134 \ 0.422680412371134 \ 0.43298969072165 )
mat Gcvsd = ( 0.209411194781137 \ 0.215428563830343 \ 0.21546802804412 \ 0.212254330138366 \ 0.201492992636001 )
assert mreldif(Scvm,Gcvm)<`tol'
assert mreldif(Scvsd,Gcvsd)<`tol'
// > cv$lambda.min
// [1] 0.11
// > cv$lambda.1se
// [1] 0.2
assert e(lopt)==0.11
assert e(lse)==0.2


********************************************************************************
*** plotting                                                                 ***
******************************************************************************** 

clear all 

insheet using prostate.data, clear

gen ybin = lpsa > 2

cvlassologit ybin lcavol-pgg45 , plotcv nfol(3)

cvlassologit ybin lcavol-pgg45 , plotcv plotopt(legend(off)) nfol(3)


********************************************************************************
*** stratified option                                                        ***
******************************************************************************** 

clear all 

insheet using prostate.data, clear

gen ybin = lpsa > 3

gen f = ceil(rpoisson(3))+1

cvlassologit ybin lcavol-pgg45, tabfold strat

cvlassologit ybin lcavol-pgg45, tabfold 

cvlassologit ybin lcavol-pgg45 [fw=f], tabfold strat
 
cvlassologit ybin lcavol-pgg45 [fw=f], tabfold 
