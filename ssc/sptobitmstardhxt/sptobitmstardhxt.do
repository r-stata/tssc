log using D:\sptobitmstardhxt.smcl , replace

clear all
sysuse sptobitmstardhxt.dta, clear

* Tobit (m-STAR) Multiparametric Spatio Temporal AutoRegressive Regression
* (m-STAR) Spatial Durbin Panel Multiplicative Heteroscedasticity Models

*** YOU MUST HAVE DIFFERENT Weighted Matrixes Files:

* (1) mSTAR Model
sptobitmstardhxt ys x1 x2 , nc(7) wmfile(SPWmxt1) nwmat(1) mfx(lin) mhet(x1) ll(0)
sptobitmstardhxt ys x1 x2 , nc(7) wmfile(SPWmxt2) nwmat(2) mfx(lin) mhet(x1) ll(0)
sptobitmstardhxt ys x1 x2 , nc(7) wmfile(SPWmxt3) nwmat(3) mfx(lin) mhet(x1) ll(0)
sptobitmstardhxt ys x1 x2 , nc(7) wmfile(SPWmxt4) nwmat(4) mfx(lin) mhet(x1) ll(0)

* (2) Weighted mSTAR
sptobitmstardhxt ys x1 x2  [weight = x1], nc(7) wmfile(SPWmxt1) nwmat(1) mfx(lin) mhet(x1) ll(0)
sptobitmstardhxt ys x1 x2 [aweight = x1], nc(7) wmfile(SPWmxt1) nwmat(1) mfx(lin) mhet(x1) ll(0)

log close
