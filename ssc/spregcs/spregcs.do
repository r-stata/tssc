log using D:\spregcs.smcl , replace
clear all
sysuse spregcs.dta, clear

* (1) MLE Spatial Lag Model (SAR):
spregcs y x1 x2 , wmfile(SPWcs) model(sar) mfx(lin) tests 
spregcs y x1 x2 , wmfile(SPWcs) model(sar) mfx(log) tests tolog
spregcs y x1 x2 , wmfile(SPWcs) model(sar) mfx(lin) tests predict(Yh) resid(Ue)
spregcs ys x1 x2, wmfile(SPWcs) model(sar) mfx(lin) tests tobit ll(0)
spregcs ys x1 x2, wmfile(SPWcs) model(sar) mfx(lin) tests tobit ll(3)

* (2) MLE Spatial Error Model (SEM):
spregcs y x1 x2 , wmfile(SPWcs) model(sem) mfx(lin) tests 
spregcs y x1 x2 , wmfile(SPWcs) model(sem) mfx(log) tests tolog
spregcs ys x1 x2, wmfile(SPWcs) model(sem) mfx(lin) tests tobit ll(0)

* (3) MLE Spatial Durbin Model (SDM):
spregcs y x1 x2 , wmfile(SPWcs) model(sdm) mfx(lin) tests 
spregcs ys x1 x2, wmfile(SPWcs) model(sdm) mfx(lin) tests tobit ll(0)
spregcs y x1    , wmfile(SPWcs) model(sdm) mfx(lin) tests aux(x2)
spregcs y x1 x2 , wmfile(SPWcs) model(sdm) mfx(log) tests tolog

* (4) MLE Spatial AutoCorrelation Model (SAC):
spregcs y x1 x2 , wmfile(SPWcs) model(sac) mfx(lin) tests spar(rho)
spregcs y x1 x2 , wmfile(SPWcs) model(sac) mfx(log) tests spar(rho) tolog
spregcs y x1 x2 , wmfile(SPWcs) model(sac) mfx(lin) tests spar(lam)
spregcs y x1 x2 , wmfile(SPWcs) model(sac) mfx(log) tests spar(lam) tolog
spregcs ys x1 x2, wmfile(SPWcs) model(sac) mfx(lin) tests tobit ll(0)

* (5) Spatial Exponential Regression Model
spregcs y x1 x2 , wmfile(SPWcs) model(sar) dist(exp) mfx(lin) tests 
spregcs y x1 x2 , wmfile(SPWcs) model(sem) dist(exp) mfx(lin) tests
spregcs y x1 x2 , wmfile(SPWcs) model(sdm) dist(exp) mfx(lin) tests
spregcs y x1 x2 , wmfile(SPWcs) model(sac) dist(exp) mfx(lin) tests

* (6) Spatial Weibull Regression Model
spregcs y x1 x2 , wmfile(SPWcs) model(sar) dist(weib) mfx(lin) tests
spregcs y x1 x2 , wmfile(SPWcs) model(sem) dist(weib) mfx(lin) tests
spregcs y x1 x2 , wmfile(SPWcs) model(sdm) dist(weib) mfx(lin) tests
spregcs y x1 x2 , wmfile(SPWcs) model(sac) dist(weib) mfx(lin) tests

* (7) (m-STAR) Multiparametric Spatio Temporal AutoRegressive Regression
*** YOU MUST HAVE DIFFERENT Weighted Matrixes Files:
*      (m-STAR) Lag Model
* (7-1) *** rum mstar in 1st nwmat
spregcs y x1 x2 , wmfile(SPWmcs1) nwmat(1) model(mstar) dist(norm) mfx(lin) tests
spregcs y x1 x2 , wmfile(SPWmcs1) nwmat(1) model(mstar) dist(exp) mfx(lin) tests
spregcs y x1 x2 , wmfile(SPWmcs1) nwmat(1) model(mstar) dist(weib) mfx(lin) tests
spregcs y x1 x2 , wmfile(SPWmcs1) nwmat(1) model(mstar) mhet(x1 x2) mfx(lin) tests
spregcs ys x1 x2, wmfile(SPWmcs1) nwmat(1) model(mstar) tobit ll(0) mfx(lin) tests

* (7-2) *** Import 1     Weight Matrix,   and rum mstar in 2nd nwmat
spregcs y x1 x2 , wmfile(SPWmcs1) nwmat(1)
spregcs y x1 x2 , wmfile(SPWmcs2) nwmat(2) model(mstar) dist(norm) mfx(lin) tests
spregcs y x1 x2 , wmfile(SPWmcs2) nwmat(2) model(mstar) dist(exp) mfx(lin) tests
spregcs y x1 x2 , wmfile(SPWmcs2) nwmat(2) model(mstar) dist(weib) mfx(lin) tests
spregcs y x1 x2 , wmfile(SPWmcs2) nwmat(2) model(mstar) mhet(x1 x2) mfx(lin) tests
spregcs ys x1 x2, wmfile(SPWmcs2) nwmat(2) model(mstar) tobit ll(0) mfx(lin) tests

* (7-3) *** Import 1,2   Weight Matrixes, and rum mstar in 3rd nwmat
spregcs y x1 x2 , wmfile(SPWmcs1) nwmat(1)
spregcs y x1 x2 , wmfile(SPWmcs2) nwmat(2)
spregcs y x1 x2 , wmfile(SPWmcs3) nwmat(3) model(mstar) dist(norm) mfx(lin) tests
spregcs y x1 x2 , wmfile(SPWmcs3) nwmat(3) model(mstar) dist(exp) mfx(lin) tests
spregcs y x1 x2 , wmfile(SPWmcs3) nwmat(3) model(mstar) dist(weib) mfx(lin) tests
spregcs y x1 x2 , wmfile(SPWmcs3) nwmat(3) model(mstar) mhet(x1 x2) mfx(lin) tests
spregcs ys x1 x2, wmfile(SPWmcs3) nwmat(3) model(mstar) tobit ll(0) mfx(lin) tests

* (7-4) *** Import 1,2,3 Weight Matrixes, and rum mstar in 4th nwmat
spregcs y x1 x2 , wmfile(SPWmcs1) nwmat(1)
spregcs y x1 x2 , wmfile(SPWmcs2) nwmat(2)
spregcs y x1 x2 , wmfile(SPWmcs3) nwmat(3)
spregcs y x1 x2 , wmfile(SPWmcs4) nwmat(4) model(mstar) dist(norm) mfx(lin) tests
spregcs y x1 x2 , wmfile(SPWmcs4) nwmat(4) model(mstar) dist(exp) mfx(lin) tests
spregcs y x1 x2 , wmfile(SPWmcs4) nwmat(4) model(mstar) dist(weib) mfx(lin) tests
spregcs y x1 x2 , wmfile(SPWmcs4) nwmat(4) model(mstar) mhet(x1 x2) mfx(lin) tests
spregcs ys x1 x2, wmfile(SPWmcs4) nwmat(4) model(mstar) tobit ll(0) mfx(lin) tests

* (8) (m-STAR) Multiparametric Spatio Temporal AutoRegressive Regression
*** YOU MUST HAVE DIFFERENT Weighted Matrixes Files:
*       (m-STAR) Durbin Model

* (8-1) *** rum mstar in 1st nwmat
spregcs y x1 x2 , wmfile(SPWmcs1) nwmat(1) model(mstard) dist(norm) mfx(lin) tests
spregcs y x1 x2 , wmfile(SPWmcs1) nwmat(1) model(mstard) dist(exp) mfx(lin) tests
spregcs y x1 x2 , wmfile(SPWmcs1) nwmat(1) model(mstard) dist(weib) mfx(lin) tests
spregcs y x1 x2 , wmfile(SPWmcs1) nwmat(1) model(mstard) mhet(x1 x2) mfx(lin) tests
spregcs ys x1 x2, wmfile(SPWmcs1) nwmat(1) model(mstard) tobit ll(0) mfx(lin) tests

* (8-2) *** Import 1     Weight Matrix,   and rum mstar in 2nd nwmat
spregcs y x1 x2 , wmfile(SPWmcs1) nwmat(1)
spregcs y x1 x2 , wmfile(SPWmcs2) nwmat(2) model(mstard) dist(norm) mfx(lin) tests
spregcs y x1 x2 , wmfile(SPWmcs2) nwmat(2) model(mstard) dist(exp) mfx(lin) tests
spregcs y x1 x2 , wmfile(SPWmcs2) nwmat(2) model(mstard) dist(weib) mfx(lin) tests
spregcs y x1 x2 , wmfile(SPWmcs2) nwmat(2) model(mstard) mhet(x1 x2) mfx(lin) tests
spregcs ys x1 x2, wmfile(SPWmcs2) nwmat(2) model(mstard) tobit ll(0) mfx(lin) tests

* (8-3) *** Import 1,2   Weight Matrixes, and rum mstar in 3rd nwmat
spregcs y x1 x2 , wmfile(SPWmcs1) nwmat(1)
spregcs y x1 x2 , wmfile(SPWmcs2) nwmat(2)
spregcs y x1 x2 , wmfile(SPWmcs3) nwmat(3) model(mstard) dist(norm) mfx(lin) tests
spregcs y x1 x2 , wmfile(SPWmcs3) nwmat(3) model(mstard) dist(exp) mfx(lin) tests
spregcs y x1 x2 , wmfile(SPWmcs3) nwmat(3) model(mstard) dist(weib) mfx(lin) tests
spregcs y x1 x2 , wmfile(SPWmcs3) nwmat(3) model(mstard) mhet(x1) mfx(lin) tests
spregcs ys x1 x2, wmfile(SPWmcs3) nwmat(3) model(mstard) tobit ll(0) mfx(lin) tests

* (8-4) *** Import 1,2,3 Weight Matrixes, and rum mstar in 4th nwmat
spregcs y x1 x2 , wmfile(SPWmcs1) nwmat(1)
spregcs y x1 x2 , wmfile(SPWmcs2) nwmat(2)
spregcs y x1 x2 , wmfile(SPWmcs3) nwmat(3)
spregcs y x1 x2 , wmfile(SPWmcs4) nwmat(4) model(mstard) dist(norm) mfx(lin) tests
spregcs y x1 x2 , wmfile(SPWmcs4) nwmat(4) model(mstard) dist(exp) mfx(lin) tests
spregcs y x1 x2 , wmfile(SPWmcs4) nwmat(4) model(mstard) dist(weib) mfx(lin) tests
spregcs y x1 x2 , wmfile(SPWmcs4) nwmat(4) model(mstard) mhet(x1) mfx(lin) tests
spregcs ys x1 x2, wmfile(SPWmcs4) nwmat(4) model(mstard) tobit ll(0) mfx(lin) tests

* (9) Weighted MLE Spatial Models:

* (9-1) Weighted MLE Spatial Lag Model (SAR):
spregcs y x1 x2 , wmfile(SPWcs) model(sar) mfx(lin) tests wvar(x1)

* (9-2) Weighted MLE Spatial Error Model (SEM):
spregcs y x1 x2 , wmfile(SPWcs) model(sem) mfx(lin) tests wvar(x1)

* (9-3) Weighted MLE Spatial Durbin Model (SDM):
spregcs y x1 x2 , wmfile(SPWcs) model(sdm) mfx(lin) tests wvar(x1)

* (9-4) Weighted MLE Spatial AutoCorrelation Model (SAC):
spregcs y x1 x2 , wmfile(SPWcs) model(sac) mfx(lin) tests wvar(x1)

* (9-5) Weighted (m-STAR) Lag Model
spregcs y x1 x2 , wmfile(SPWcs) model(mstar) nw(1) mfx(lin) tests wvar(x1)

* (9-6) Weighted (m-STAR) Durbin Model
spregcs y x1 x2 , wmfile(SPWcs) model(mstard) nw(1) mfx(lin) tests

* (10) Spatial Tobit - Truncated Dependent Variable (ys)
spregcs ys x1 x2 , wmfile(SPWcs) model(sar) mfx(lin) tests
spregcs ys x1 x2 , wmfile(SPWcs) model(sem) mfx(lin) tests
spregcs ys x1 x2 , wmfile(SPWcs) model(sdm) mfx(lin) tests
spregcs ys x1 x2 , wmfile(SPWcs) model(sac) mfx(lin) tests
spregcs ys x1 x2 , wmfile(SPWcs) model(lag) run(tobit) mfx(lin) tests
spregcs ys x1 x2 , wmfile(SPWcs) model(durbin) run(tobit) mfx(lin) tests

* (11) Spatial Multiplicative Heteroscedasticity
spregcs y x1 x2 , wmfile(SPWcs) model(sar) mhet(x1 x2) mfx(lin) tests
spregcs y x1 x2 , wmfile(SPWcs) model(sdm) mhet(x1 x2) mfx(lin) tests

* (12) Spatial IV Tobit (IVTOBIT)

spregcs ys x1 x2 , wmfile(SPWcs) model(ivtobit) endog(y2) inst(x3 x4) mfx(lin) tests lmiden mle
spregcs ys x1 x2 , wmfile(SPWcs) model(ivtobit) endog(y2) inst(x3 x4) mfx(lin) tests lmiden twostep

spregcs ys x1 x2 , wmfile(SPWcs) model(ivtobit) order(1) lmiden twostep mfx(lin) tests
spregcs ys x1 x2 , wmfile(SPWcs) model(ivtobit) order(2) lmiden twostep mfx(lin) tests
spregcs ys x1 x2 , wmfile(SPWcs) model(ivtobit) order(3) lmiden twostep mfx(lin) tests
spregcs ys x1 x2 , wmfile(SPWcs) model(ivtobit) order(4) lmiden twostep mfx(lin) tests

* (13) MLE -Spatial Lag/Autoregressive Error (SARARML)
spregcs y x1 x2 , wmfile(SPWcs) model(sararml) mfx(lin) tests spar(rho)
spregcs y x1 x2 , wmfile(SPWcs) model(sararml) mfx(lin) tests spar(lam)

* (14) Generalized Spatial Lag/Autoregressive Error GS2SLS (SARARGS)
spregcs y x1 x2 , wmfile(SPWcs) model(sarargs) mfx(lin) tests spar(rho)
spregcs y x1 x2 , wmfile(SPWcs) model(sarargs) mfx(lin) tests spar(lam)

* (15) Generalized Spatial Lag/Autoregressive Error IV-GS2SLS (SARARIV)
spregcs y x1 x2 , wmfile(SPWcs) model(sarariv) endog(y2) mfx(lin) tests spar(rho) lmiden
spregcs y x1 x2 , wmfile(SPWcs) model(sarariv) endog(y2) mfx(lin) tests spar(lam) lmiden

* (16) Spatial Autoregressive Generalized Method of Moments (SPGMM)
spregcs y x1 x2 , wmfile(SPWcs) model(spgmm) mfx(lin) tests 
spregcs y x1 x2 , wmfile(SPWcs) model(spgmm) ridge(orr) kr(0.5) mfx(lin) tests
spregcs y x1 x2 , wmfile(SPWcs) model(spgmm) ridge(grr1) weight(x) wvar(x1) mfx(lin) tests

* (17) Tobit Spatial Autoregressive Generalized Method of Moments (SPGMM)
spregcs ys x1 x2 , wmfile(SPWcs) model(spgmm) tobit ll(0) mfx(lin) tests
spregcs ys x1 x2 , wmfile(SPWcs) model(spgmm) tobit ll(0) ridge(grr1) mfx(lin) tests
spregcs ys x1 x2 , wmfile(SPWcs) model(spgmm) tobit ll(0) ridge(orr) kr(0.5) mfx(lin) tests
spregcs ys x1 x2 , wmfile(SPWcs) model(spgmm) tobit ll(0) ridge(grr1) weight(x) wvar(x1) mfx(lin) tests

* (18) Generalized Spatial 2SLS Models
* (18-1) Generalized Spatial 2SLS - AR(1) (GS2SLS)

spregcs y x1 x2 , wmfile(SPWcs) model(gs2sls) run(2sls) endog(y2) inst(x3 x4) lmiden mfx(lin) tests
spregcs y x1 x2 , wmfile(SPWcs) model(gs2sls) run(2sls) ridge(grr1) mfx(lin) tests
spregcs y x1 x2 , wmfile(SPWcs) model(gs2sls) run(2sls) ridge(orr) kr(0.5) mfx(lin) tests
spregcs ys x1 x2, wmfile(SPWcs) model(gs2sls) run(2sls) order(1) lmn lmh mfx(lin) tests
spregcs y x1 x2 , wmfile(SPWcs) model(gs2sls) run(2sls) order(1) lmiden mfx(lin) tests
spregcs y x1 x2 , wmfile(SPWcs) model(gs2sls) run(melo) mfx(lin) tests
spregcs y x1 x2 , wmfile(SPWcs) model(gs2sls) run(liml) mfx(lin) tests
spregcs y x1 x2 , wmfile(SPWcs) model(gs2sls) run(kclass) kc(0.5) mfx(lin) tests
spregcs y x1 x2 , wmfile(SPWcs) model(gs2sls) run(fuller) kf(0.5) mfx(lin) tests
spregcs y x1 x2 , wmfile(SPWcs) model(gs2sls) run(gmm) hetcov(white) mfx(lin) tests
spregcs y x1 x2 , wmfile(SPWcs) model(gs2sls) run(gmm) hetcov(white) weights(x) wvar(x1) mfx(lin) tests
spregcs y x1 x2 , wmfile(SPWcs) model(gs2sls) run(gmm) hetcov(bart) mfx(lin) tests
spregcs y x1 x2 , wmfile(SPWcs) model(gs2sls) run(gmm) hetcov(dan) mfx(lin) tests
spregcs y x1 x2 , wmfile(SPWcs) model(gs2sls) run(gmm) hetcov(nwest) mfx(lin) tests
spregcs y x1 x2 , wmfile(SPWcs) model(gs2sls) run(gmm) hetcov(parzen) mfx(lin) tests
spregcs y x1 x2 , wmfile(SPWcs) model(gs2sls) run(gmm) hetcov(quad) mfx(lin) tests
spregcs y x1 x2 , wmfile(SPWcs) model(gs2sls) run(gmm) hetcov(tent) mfx(lin) tests
spregcs y x1 x2 , wmfile(SPWcs) model(gs2sls) run(gmm) hetcov(trunc) mfx(lin) tests
spregcs y x1 x2 , wmfile(SPWcs) model(gs2sls) run(gmm) hetcov(tukeym) mfx(lin) tests
spregcs y x1 x2 , wmfile(SPWcs) model(gs2sls) run(gmm) hetcov(tukeyn) mfx(lin) tests

* (18-2) Generalized Spatial 2SLS - AR(2) (GS2SLS)
spregcs y x1 x2 , wmfile(SPWcs) model(gs2sls) run(2sls) order(2) mfx(lin) tests

* (18-3) Generalized Spatial 2SLS - AR(3) (GS2SLS)
spregcs y x1 x2 , wmfile(SPWcs) model(gs2sls) run(2sls) order(3) mfx(lin) tests

* (18-4) Generalized Spatial 2SLS - AR(4) (GS2SLS)
spregcs y x1 x2 , wmfile(SPWcs) model(gs2sls) run(2sls) order(4) mfx(lin) tests

* (19) Generalized Spatial Autoregressive 2SLS (GS2SLSAR)

* (19-1) Generalized Spatial Autoregressive 2SLS - AR(1) (GS2SLSAR)

spregcs y x1 x2 , wmfile(SPWcs) model(gs2slsar) run(2sls) endog(y2) inst(x3 x4) lmiden mfx(lin) tests
spregcs y x1 x2 , wmfile(SPWcs) model(gs2slsar) run(2sls) ridge(grr1) mfx(lin) tests
spregcs y x1 x2 , wmfile(SPWcs) model(gs2slsar) run(2sls) ridge(orr) kr(0.5) mfx(lin) tests
spregcs y x1 x2 , wmfile(SPWcs) model(gs2slsar) run(2sls) order(1) lmi haus mfx(lin) tests
spregcs y x1 x2 , wmfile(SPWcs) model(gs2slsar) run(liml) order(1) lmi haus mfx(lin) tests
spregcs y x1 x2 , wmfile(SPWcs) model(gs2slsar) run(melo) order(1) lmi haus mfx(lin) tests
spregcs y x1 x2 , wmfile(SPWcs) model(gs2slsar) run(gmm) hetcov(white) lmi haus mfx(lin) tests

* (19-2) Generalized Spatial Autoregressive 2SLS - AR(2) (GS2SLSAR)
spregcs y x1 x2 , wmfile(SPWcs) model(gs2slsar) run(2sls) order(2) mfx(lin) tests

* (19-3) Generalized Spatial Autoregressive 2SLS - AR(3) (GS2SLSAR)
spregcs y x1 x2 , wmfile(SPWcs) model(gs2slsar) run(2sls) order(3) mfx(lin) tests

* (19-4) Generalized Spatial Autoregressive 2SLS - AR(4) (GS2SLSAR)
spregcs y x1 x2 , wmfile(SPWcs) model(gs2slsar) run(2sls) order(4) mfx(lin) tests

* (20) Generalized Spatial 3SLS - (G32SLS)
* Y1 = Y2 X1 X2
* Y2 = Y1 X3 X4

* (20-1) Generalized Spatial 3SLS - AR(1) (GS3SLS)
spregcs y1 x1 x2 , var2(y2 x3 x4) wmfile(SPWcs) model(gs3sls) eq(1) mfx(lin) tests order(1)

* (20-2) Generalized Spatial 3SLS - AR(2) (GS3SLS)
spregcs y1 x1 x2 , var2(y2 x3 x4) wmfile(SPWcs) model(gs3sls) eq(1) mfx(lin) tests order(2)

* (20-3) Generalized Spatial 3SLS - AR(3) (GS3SLS)
spregcs y1 x1 x2 , var2(y2 x3 x4) wmfile(SPWcs) model(gs3sls) eq(1) mfx(lin) tests order(3)

* (20-4) Generalized Spatial 3SLS - AR(4) (GS3SLS)
spregcs y1 x1 x2 , var2(y2 x3 x4) wmfile(SPWcs) model(gs3sls) eq(1) mfx(lin) tests order(4)

* (21) Generalized Spatial Autoregressive 3SLS - (GS3SLSAR)

* (21-1) Generalized Spatial Autoregressive 3SLS - AR(1) (GS3SLSAR)
spregcs y1 x1 x2 , var2(y2 x3 x4) wmfile(SPWcs) model(gs3slsar) eq(1) lmn lmh mfx(lin) tests
spregcs y1 x1 x2 , var2(y2 x3 x4) wmfile(SPWcs) model(gs3slsar) eq(1) mfx(lin) tests order(1) lmn

* (21-2) Generalized Spatial Autoregressive 3SLS - AR(2) (GS3SLSAR)
spregcs y1 x1 x2 , var2(y2 x3 x4) wmfile(SPWcs) model(gs3slsar) eq(1) mfx(lin) tests order(2)

* (21-3) Generalized Spatial Autoregressive 3SLS - AR(3) (GS3SLSAR)
spregcs y1 x1 x2 , var2(y2 x3 x4) wmfile(SPWcs) model(gs3slsar) eq(1) mfx(lin) tests order(3)

* (21-4) Generalized Spatial Autoregressive 3SLS - AR(4) (GS3SLSAR)
spregcs y1 x1 x2 , var2(y2 x3 x4) wmfile(SPWcs) model(gs3slsar) eq(1) mfx(lin) tests order(4)

* (22) Geographically Weighted Regressions (GWR)
spregcs y x1 x2 , wmfile(SPWcs) model(gwr) run(ols) mfx(lin) tests
spregcs y x1 x2 , wmfile(SPWcs) model(gwr) run(sfa) mfx(lin) tests
spregcs y x1 x2 , wmfile(SPWcs) model(gwr) run(sfa) cost mfx(lin) tests
spregcs ys x1 x2, wmfile(SPWcs) model(gwr) run(tobit) mfx(lin) tests

* (23) Non Spatial Regression Models
spregcs y x1 x2 , wmfile(SPWcs) model(ols) run(ols) mfx(lin) tests
spregcs y x1 x2 , wmfile(SPWcs) model(ols) run(sfa) mfx(lin) tests
spregcs y x1 x2 , wmfile(SPWcs) model(ols) run(sfa) cost mfx(lin) tests
spregcs ys x1 x2 , wmfile(SPWcs) model(ols) run(tobit) mfx(lin) tests

* (24) Spatial Lag Regression Models (LAG)
spregcs y x1 x2 , wmfile(SPWcs) model(lag) run(ols) mfx(lin) tests
spregcs y x1 x2 , wmfile(SPWcs) model(lag) run(sfa) mfx(lin) tests
spregcs y x1 x2 , wmfile(SPWcs) model(lag) run(sfa) cost mfx(lin) tests
spregcs ys x1 x2, wmfile(SPWcs) model(lag) run(tobit) mfx(lin) tests

* (25) Spatial Durbin Regression Models (DURBIN)
spregcs y x1 x2 , wmfile(SPWcs) model(durbin) run(ols) mfx(lin) tests
spregcs y x1 x2 , wmfile(SPWcs) model(durbin) run(sfa) mfx(lin) tests
spregcs y x1 x2 , wmfile(SPWcs) model(durbin) run(sfa) cost mfx(lin) tests
spregcs ys x1 x2, wmfile(SPWcs) model(durbin) run(tobit) mfx(lin) tests

* (26) Restrected Spatial Regression Models
constraint define 1 x1 + x2 = 1
spregcs y x1 x2 , wmfile(SPWcs) model(sar) rest(1) mfx(lin) tests
spregcs y x1 x2 , wmfile(SPWcs) model(sdm) rest(1) mfx(lin) tests
spregcs y x1 x2 , wmfile(SPWcs) model(mstar) rest(1) mfx(lin) tests
spregcs y x1 x2 , wmfile(SPWcs) model(mstard) rest(1) mfx(lin) tests

* (17) Spatial Autoregressive Generalized Method of Moments (SPGMM) (Cont.)
* This example is taken from Prucha data about:
* Generalized Moments Estimator for the Autoregressive Parameter in a Spatial Model
* More details can be found in: http://econweb.umd.edu/~prucha/Research_Prog1.htm
* Results of model(spgmm) is identical to:
* http://econweb.umd.edu/~prucha/STATPROG/OLS/PROGRAM1.log

clear all
sysuse spregcs1.dta , clear
spregcs y x1 , wmfile(SPWcs1) model(spgmm) mfx(lin) tests

* (19) Generalized Spatial Autoregressive 2SLS (GS2SLSAR) (Cont.)
* This example is taken from Prucha data about:
* Generalized Spatial Two-Stage Least Squares Procedures for Estimating
* a Spatial Autoregressive Model with Autoregressive Disturbances
* More details can be found in: http://econweb.umd.edu/~prucha/Research_Prog2.htm
* Results of model(gs2slsar) with order(2) is identical to:
* http://econweb.umd.edu/~prucha/STATPROG/2SLS/PROGRAM2.log

clear all
sysuse spregcs2.dta , clear
spregcs y x1 , wmfile(SPWcs1) model(gs2slsar) run(2sls) order(2) mfx(lin) tests

* (21) Generalized Spatial Autoregressive 3SLS (GS3SLSAR) (Cont.)
* This example is taken from Prucha data about:
* Estimation of Simultaneous Systems of Spatially Interrelated Cross Sectional Equations
* More details can be found in: http://econweb.umd.edu/~prucha/Research_Prog4.htm
* Results of model(gs3slsar) with order(2) is identical to:
* http://econweb.umd.edu/~prucha/STATPROG/SIMEQU/PROGRAM4.log

clear all
sysuse spregcs3.dta , clear
spregcs y1 x1 , var2(y2 x2) wmfile(SPWcs1) model(gs3slsar) order(2) mfx(lin) tests

log close

