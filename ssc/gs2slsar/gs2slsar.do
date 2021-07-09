log using c:\gs2slsar.smcl , replace

clear all
sysuse gs2slsar.dta, clear

* (1) Generalized Spatial Autoregressive 2SLS - AR(1) (gs2slsar)
gs2slsar y x1 x2 , wmfile(SPWcs) order(1) mfx(lin) test
gs2slsar y x1 x2    , wmfile(SPWcs) order(1) mfx(lin) test aux(x3)
gs2slsar y x1 x2 x3 , wmfile(SPWcs) order(1) mfx(lin) test

* note the difference of x3 coef with and without aux option.
gs2slsar y x1 x2 , wmfile(SPWcs) order(1) mfx(log) test tolog
gs2slsar y x1 x2 [weight=x1] , wmfile(SPWcs) order(1) mfx(lin) test

* (2) Generalized Spatial Autoregressive 2SLS - AR(2) (gs2slsar)
gs2slsar y x1 x2 , wmfile(SPWcs) order(2) mfx(lin) test

* (3) Generalized Spatial Autoregressive 2SLS - AR(3) (gs2slsar)
gs2slsar y x1 x2 , wmfile(SPWcs) order(3) mfx(lin) test

* (4) Generalized Spatial Autoregressive 2SLS - AR(4) (gs2slsar)
gs2slsar y x1 x2 , wmfile(SPWcs) order(4) mfx(lin) test

* (5) Generalized Spatial Autoregressive GMM - AR(1) (gs2slsar)
gs2slsar y x1 x2 , wmfile(SPWcs) order(1) mfx(lin) test model(gmm)

* (6) Generalized Spatial Autoregressive LIML - AR(1) (gs2slsar)
gs2slsar y x1 x2 , wmfile(SPWcs) order(1) mfx(lin) test model(liml)

* Generalized Spatial Autoregressive 2SLS (GS2SLSAR) (Cont.)
* This example is taken from Prucha data about:
* Generalized Spatial Two-Stage Least Squares Procedures for Estimating
* a Spatial Autoregressive Model with Autoregressive Disturbances
* More details can be found in:
* http://econweb.umd.edu/~prucha/Research_Prog2.htm
* Results of (gs2slsar) with order(2) is identical to:
* http://econweb.umd.edu/~prucha/STATPROG/2SLS/PROGRAM2.log

clear all
sysuse gs2slsar1.dta , clear
gs2slsar y x1 , wmfile(SPWcs1) order(2)

log close
