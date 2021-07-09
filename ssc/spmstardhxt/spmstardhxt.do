log using D:\spmstardhxt.smcl , replace

clear all
sysuse spmstardhxt.dta, clear

* (m-STAR) Multiparametric Spatio Temporal AutoRegressive Regression
* (m-STAR) Spatial Durbin Panel Multiplicative Heteroscedasticity Models

*** YOU MUST HAVE DIFFERENT Weighted Matrixes Files:

* (1) mSTAR Model
spmstardhxt y x1 x2 , nc(7) wmfile(SPWmxt1) nwmat(1) mfx(lin) mhet(x1)
spmstardhxt y x1 x2 , nc(7) wmfile(SPWmxt2) nwmat(2) mfx(lin) mhet(x1)
spmstardhxt y x1 x2 , nc(7) wmfile(SPWmxt3) nwmat(3) mfx(lin) mhet(x1)
spmstardhxt y x1 x2 , nc(7) wmfile(SPWmxt4) nwmat(4) mfx(lin) mhet(x1)
spmstardhxt y x1 x2 , nc(7) wmfile(SPWmxt4) nwmat(4) mfx(lin) mhet(x1) aux(x3 x4)
spmstardhxt ys x1 x2, nc(7) wmfile(SPWmxt4) nwmat(4) mfx(lin) mhet(x1) tobit ll(0)

* (2) Weighted mSTAR
spmstardhxt y x1 x2  [weight = x1], nc(7) wmfile(SPWmxt1) nwmat(1) mfx(lin) mhet(x1)
spmstardhxt y x1 x2 [aweight = x1], nc(7) wmfile(SPWmxt1) nwmat(1) mfx(lin) mhet(x1)

log close
