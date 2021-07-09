log using D:\spmstarhxt.smcl , replace

clear all
sysuse spmstarhxt.dta, clear

* (m-STAR) Multiparametric Spatio Temporal AutoRegressive Regression
* (m-STAR) Spatial Lag Panel Multiplicative Heteroscedasticity Models

*** YOU MUST HAVE DIFFERENT Weighted Matrixes Files:

* (1) *** m-STAR Model
spmstarhxt y x1 x2 , nc(7) wmfile(SPWmxt1) nwmat(1) mfx(log) mhet(x1 x2) tolog
spmstarhxt y x1 x2 , nc(7) wmfile(SPWmxt1) nwmat(1) mfx(lin) mhet(x1 x2)
spmstarhxt y x1 x2 , nc(7) wmfile(SPWmxt2) nwmat(2) mfx(lin) mhet(x1 x2)
spmstarhxt y x1 x2 , nc(7) wmfile(SPWmxt3) nwmat(3) mfx(lin) mhet(x1 x2)
spmstarhxt y x1 x2 , nc(7) wmfile(SPWmxt4) nwmat(4) mfx(lin) mhet(x1 x2)
spmstarhxt ys x1 x2, nc(7) wmfile(SPWmxt4) nwmat(4) mfx(lin) mhet(x1 x2) tobit ll(0)

* (2) Weighted mSTAR
spmstarhxt y x1 x2  [weight= x1], nc(7) wmfile(SPWmxt1) nwmat(1) mfx(lin) mhet(x1 x2)
spmstarhxt y x1 x2  [weight= x1], nc(7) wmfile(SPWmxt2) nwmat(2) mfx(lin) mhet(x1 x2)
spmstarhxt y x1 x2  [weight= x1], nc(7) wmfile(SPWmxt3) nwmat(3) mfx(lin) mhet(x1 x2)
spmstarhxt y x1 x2  [weight= x1], nc(7) wmfile(SPWmxt4) nwmat(4) mfx(lin) mhet(x1 x2)

log close
