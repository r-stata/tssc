log using c:\spautoreg.smcl , replace
clear all
sysuse spautoreg.dta, clear

* (1) MLE Spatial Lag Model (SAR):
spautoreg y x1 x2 , wmfile(SPWcs) model(sar) mfx(lin) test
spautoreg y x1 x2 , wmfile(SPWcs) model(sar) mfx(lin) test
spautoreg y x1 x2 , wmfile(SPWcs) model(sar) mfx(log) test tolog
spautoreg y x1 x2 , wmfile(SPWcs) model(sar) predict(Yh) resid(Ue)
spautoreg ys x1 x2, wmfile(SPWcs) model(sar) lmn lmh tobit ll(0)
spautoreg ys x1 x2, wmfile(SPWcs) model(sar) lmn lmh tobit ll(3)

* (2) MLE Spatial Error Model (SEM):
spautoreg y x1 x2 , wmfile(SPWcs) model(sem) mfx(lin) test
spautoreg y x1 x2 , wmfile(SPWcs) model(sem) mfx(log) test tolog
spautoreg ys x1 x2, wmfile(SPWcs) model(sem) lmn lmh tobit ll(0)

* (3) MLE Spatial Durbin Model (SDM):
spautoreg y x1 x2 , wmfile(SPWcs) model(sdm) mfx(lin) test
spautoreg ys x1 x2, wmfile(SPWcs) model(sdm) lmn lmh tobit ll(0)
spautoreg y x1    , wmfile(SPWcs) model(sdm) mfx(lin) test aux(x2)
spautoreg y x1 x2 , wmfile(SPWcs) model(sdm) mfx(log) test tolog

* (4) MLE Spatial AutoCorrelation Model (SAC):
spautoreg y x1 x2 , wmfile(SPWcs) model(sac) mfx(lin) test spar(rho)
spautoreg y x1 x2 , wmfile(SPWcs) model(sac) mfx(log) test spar(rho) tolog
spautoreg y x1 x2 , wmfile(SPWcs) model(sac) mfx(lin) test spar(lam)
spautoreg y x1 x2 , wmfile(SPWcs) model(sac) mfx(log) test spar(lam) tolog
spautoreg ys x1 x2, wmfile(SPWcs) model(sac) lmn lmh tobit ll(0)

* (5) Spatial Exponential Regression Model:
spautoreg y x1 x2 , wmfile(SPWcs) model(sar) dist(exp) mfx(lin) test
spautoreg y x1 x2 , wmfile(SPWcs) model(sem) dist(exp) mfx(lin) test
spautoreg y x1 x2 , wmfile(SPWcs) model(sdm) dist(exp) mfx(lin) test
spautoreg y x1 x2 , wmfile(SPWcs) model(sac) dist(exp) mfx(lin) test

* (6) Spatial Weibull Regression Model:
spautoreg y x1 x2 , wmfile(SPWcs) model(sar) dist(weib) mfx(lin) test
spautoreg y x1 x2 , wmfile(SPWcs) model(sem) dist(weib) mfx(lin) test
spautoreg y x1 x2 , wmfile(SPWcs) model(sdm) dist(weib) mfx(lin) test
spautoreg y x1 x2 , wmfile(SPWcs) model(sac) dist(weib) mfx(lin) test

* (7) Weighted MLE Spatial Models:
* (7-1) Weighted MLE Spatial Lag Model (SAR):
spautoreg y x1 x2 [weight = x1], wmfile(SPWcs) model(sar) mfx(lin) test

* (7-2) Weighted MLE Spatial Error Model (SEM):
spautoreg y x1 x2 [weight = x1], wmfile(SPWcs) model(sem) mfx(lin) test

* (7-3) Weighted MLE Spatial Durbin Model (SDM):
spautoreg y x1 x2 [weight = x1], wmfile(SPWcs) model(sdm) mfx(lin) test

* (7-4) Weighted MLE Spatial AutoCorrelation Model (SAC):
spautoreg y x1 x2 [weight = x1], wmfile(SPWcs) model(sac) mfx(lin) test

* (8) Spatial Tobit - Truncated Dependent Variable (ys):
spautoreg ys x1 x2 , wmfile(SPWcs) model(sar) mfx(lin) test tobit ll(0)
spautoreg ys x1 x2 , wmfile(SPWcs) model(sem) mfx(lin) test tobit ll(0)
spautoreg ys x1 x2 , wmfile(SPWcs) model(sdm) mfx(lin) test tobit ll(0)
spautoreg ys x1 x2 , wmfile(SPWcs) model(sac) mfx(lin) test tobit ll(0)

* (9) Spatial Multiplicative Heteroscedasticity:
spautoreg y x1 x2 , wmfile(SPWcs) model(sar) mhet(x1 x2) mfx(lin) test
spautoreg y x1 x2 , wmfile(SPWcs) model(sdm) mhet(x1 x2) mfx(lin) test

* (10) Spatial IV Tobit (IVTOBIT):
spautoreg y x1 x2 , wmfile(SPWcs) model(ivtobit) order(1) mfx(lin) test tobit ll(0)
spautoreg y x1 x2 , wmfile(SPWcs) model(ivtobit) order(2) mfx(lin) test tobit ll(0)
spautoreg y x1 x2 , wmfile(SPWcs) model(ivtobit) order(3) mfx(lin) test tobit ll(0)
spautoreg y x1 x2 , wmfile(SPWcs) model(ivtobit) order(4) mfx(lin) test tobit ll(0)

* (11) MLE -Spatial Lag/Autoregressive Error (SARARML):
spautoreg y x1 x2 , wmfile(SPWcs) model(sararml) spar(rho) mfx(lin) test
spautoreg y x1 x2 , wmfile(SPWcs) model(sararml) spar(lam) mfx(lin) test

* (12) Generalized Spatial Lag/Autoregressive Error GS2SLS (SARARGS):
spautoreg y x1 x2 , wmfile(SPWcs) model(sarargs) spar(rho) mfx(lin) test
spautoreg y x1 x2 , wmfile(SPWcs) model(sarargs) spar(lam) mfx(lin) test

* (13) Generalized Spatial Lag/Autoregressive Error IV-GS2SLS (SARARIV):
spautoreg y x1 x2 , wmfile(SPWcs) model(sarariv) spar(rho) mfx(lin) test
spautoreg y x1 x2 , wmfile(SPWcs) model(sarariv) spar(lam) mfx(lin) test

* (14) Spatial Autoregressive Generalized Method of Moments (SPGMM):
spautoreg y  x1 x2 , wmfile(SPWcs) model(spgmm) mfx(lin) test

* (15) Tobit Spatial Autoregressive Generalized Method of Moments (SPGMM):
spautoreg ys x1 x2 , wmfile(SPWcs) model(spgmm) mfx(lin) test tobit ll(0)

* (16) Generalized Spatial 2SLS Models:
* (16-1) Generalized Spatial 2SLS - AR(1) (GS2SLS):
spautoreg y x1 x2 , wmfile(SPWcs) model(gs2sls) mfx(lin) test

* (16-2) Generalized Spatial 2SLS - AR(2) (GS2SLS):
spautoreg y x1 x2 , wmfile(SPWcs) model(gs2sls) order(2) mfx(lin) test

* (16-3) Generalized Spatial 2SLS - AR(3) (GS2SLS):
spautoreg y x1 x2 , wmfile(SPWcs) model(gs2sls) order(3) mfx(lin) test

* (16-4) Generalized Spatial 2SLS - AR(4) (GS2SLS):
spautoreg y x1 x2 , wmfile(SPWcs) model(gs2sls) order(4) mfx(lin) test

* (17) Generalized Spatial Autoregressive 2SLS (GS2SLSAR):
* (17-1) Generalized Spatial Autoregressive 2SLS - AR(1) (GS2SLSAR):
spautoreg y x1 x2 , wmfile(SPWcs) model(gs2slsar) order(1) lmi haus

* (17-2) Generalized Spatial Autoregressive 2SLS - AR(2) (GS2SLSAR):
spautoreg y x1 x2 , wmfile(SPWcs) model(gs2slsar) order(2) mfx(lin) test

* (17-3) Generalized Spatial Autoregressive 2SLS - AR(3) (GS2SLSAR):
spautoreg y x1 x2 , wmfile(SPWcs) model(gs2slsar) order(3) mfx(lin) test

* (17-4) Generalized Spatial Autoregressive 2SLS - AR(4) (GS2SLSAR):
spautoreg y x1 x2 , wmfile(SPWcs) model(gs2slsar) order(4) mfx(lin) test

* (18) Generalized Spatial 3SLS - (G32SLS)
* Y1 = Y2 X1 X2
* Y2 = Y1 X3 X4

* (18-1) Generalized Spatial 3SLS - AR(1) (GS3SLS):
spautoreg ys x1 x2 , var2(y2 x3 x4) wmfile(SPWcs) model(gs3sls) eq(1) lmn lmh
spautoreg y1 x1 x2 , var2(y2 x3 x4) wmfile(SPWcs) model(gs3sls) eq(1) order(1)

* (18-2) Generalized Spatial 3SLS - AR(2) (GS3SLS):
spautoreg y1 x1 x2 , var2(y2 x3 x4) wmfile(SPWcs) model(gs3sls) eq(1) mfx(lin) order(2)

* (18-3) Generalized Spatial 3SLS - AR(3) (GS3SLS):
spautoreg y1 x1 x2 , var2(y2 x3 x4) wmfile(SPWcs) model(gs3sls) eq(1) mfx(lin) order(3)

* (18-4) Generalized Spatial 3SLS - AR(4) (GS3SLS):
spautoreg y1 x1 x2 , var2(y2 x3 x4) wmfile(SPWcs) model(gs3sls) eq(1) mfx(lin) order(4)

* (19) Generalized Spatial Autoregressive 3SLS - (GS3SLSAR):
* (19-1) Generalized Spatial Autoregressive 3SLS - AR(1) (GS3SLSAR):
spautoreg y1 x1 x2 , var2(y2 x3 x4) wmfile(SPWcs) model(gs3slsar) eq(1) lmn lmh
spautoreg y1 x1 x2 , var2(y2 x3 x4) wmfile(SPWcs) model(gs3slsar) eq(1) mfx(lin) order(1) lmn

* (19-2) Generalized Spatial Autoregressive 3SLS - AR(2) (GS3SLSAR):
spautoreg y1 x1 x2 , var2(y2 x3 x4) wmfile(SPWcs) model(gs3slsar) eq(1) mfx(lin) order(2)

* (19-3) Generalized Spatial Autoregressive 3SLS - AR(3) (GS3SLSAR):
spautoreg y1 x1 x2 , var2(y2 x3 x4) wmfile(SPWcs) model(gs3slsar) eq(1) mfx(lin) order(3)

* (19-4) Generalized Spatial Autoregressive 3SLS - AR(4) (GS3SLSAR):
spautoreg y1 x1 x2 , var2(y2 x3 x4) wmfile(SPWcs) model(gs3slsar) eq(1) mfx(lin) order(4)

* (14) Spatial Autoregressive Generalized Method of Moments (SPGMM) (Cont.):
* This example is taken from Prucha data about:
* Generalized Moments Estimator for the Autoregressive Parameter in a Spatial Model  
* More details can be found in:
* http://econweb.umd.edu/~prucha/Research_Prog1.htm
* Results of model(spgmm) is identical to:
* http://econweb.umd.edu/~prucha/STATPROG/OLS/PROGRAM1.log

clear all
sysuse spautoreg1.dta , clear
spautoreg y x1 , wmfile(SPWcs1) model(spgmm)

* (16) Generalized Spatial Autoregressive 2SLS (GS2SLSAR) (Cont.):
* This example is taken from Prucha data about:
* Generalized Spatial Two-Stage Least Squares Procedures for Estimating
* a Spatial Autoregressive Model with Autoregressive Disturbances
* More details can be found in:
* http://econweb.umd.edu/~prucha/Research_Prog2.htm
* Results of model(gs2slsar) with order(2) is identical to:
* http://econweb.umd.edu/~prucha/STATPROG/2SLS/PROGRAM2.log

clear all
sysuse spautoreg2.dta , clear
spautoreg y x1 , wmfile(SPWcs1) model(gs2slsar) order(2)

* (17) Generalized Spatial Autoregressive 3SLS (GS3SLSAR) (Cont.):
* This example is taken from Prucha data about:
* Estimation of Simultaneous Systems of Spatially Interrelated Cross Sectional Equations
* More details can be found in:
* http://econweb.umd.edu/~prucha/Research_Prog4.htm
* Results of model(gs3slsar) with order(2) is identical to:
* http://econweb.umd.edu/~prucha/STATPROG/SIMEQU/PROGRAM4.log

clear all
sysuse spautoreg3.dta , clear
spautoreg y1 x1 , var2(y2 x2) wmfile(SPWcs1) model(gs3slsar) order(2)

log close

