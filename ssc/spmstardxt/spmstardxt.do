log using D:\spmstardxt.smcl , replace

clear all
sysuse spmstardxt.dta, clear

* (m-STAR) Multiparametric Spatio Temporal AutoRegressive Regression
* (m-STAR) Spatial Durbin Panel Models

*** YOU MUST HAVE DIFFERENT Weighted Matrixes Files:

* (1) *** Normal Distribution
spmstardxt y x1 x2 , nc(7) wmfile(SPWmxt1) nwmat(1) mfx(lin) dist(norm)
spmstardxt y x1 x2 , nc(7) wmfile(SPWmxt2) nwmat(2) mfx(lin) dist(norm)
spmstardxt y x1 x2 , nc(7) wmfile(SPWmxt3) nwmat(3) mfx(lin) dist(norm)
spmstardxt y x1 x2 , nc(7) wmfile(SPWmxt4) nwmat(4) mfx(lin) dist(norm)
spmstardxt y x1 x2 , nc(7) wmfile(SPWmxt4) nwmat(4) mfx(lin) dist(norm) aux(x3 x4)
spmstardxt ys x1 x2, nc(7) wmfile(SPWmxt4) nwmat(4) mfx(lin) dist(norm) tobit ll(0)

* (2) *** Weibull Distribution
spmstardxt y x1 x2 , nc(7) wmfile(SPWmxt1) nwmat(1) mfx(lin) dist(weib)
spmstardxt y x1 x2 , nc(7) wmfile(SPWmxt2) nwmat(2) mfx(lin) dist(weib)
spmstardxt y x1 x2 , nc(7) wmfile(SPWmxt3) nwmat(3) mfx(lin) dist(weib)
spmstardxt y x1 x2 , nc(7) wmfile(SPWmxt4) nwmat(4) mfx(lin) dist(weib)
spmstardxt y x1 x2 , nc(7) wmfile(SPWmxt4) nwmat(4) mfx(lin) dist(weib) aux(x3 x4)
spmstardxt ys x1 x2, nc(7) wmfile(SPWmxt4) nwmat(4) mfx(lin) dist(weib) tobit ll(0)

* (3) *** Exponential Distribution
spmstardxt y x1 x2 , nc(7) wmfile(SPWmxt1) nwmat(1) mfx(lin) dist(exp)
spmstardxt y x1 x2 , nc(7) wmfile(SPWmxt2) nwmat(2) mfx(lin) dist(exp)
spmstardxt y x1 x2 , nc(7) wmfile(SPWmxt3) nwmat(3) mfx(lin) dist(exp)
spmstardxt y x1 x2 , nc(7) wmfile(SPWmxt4) nwmat(4) mfx(lin) dist(exp)
spmstardxt y x1 x2 , nc(7) wmfile(SPWmxt4) nwmat(4) mfx(lin) dist(exp) aux(x3 x4)
spmstardxt ys x1 x2, nc(7) wmfile(SPWmxt4) nwmat(4) mfx(lin) dist(exp) tobit ll(0)

* (4) Weighted mSTAR Normal Distribution:
spmstardxt y x1 x2  [weight = x1], nc(7) wmfile(SPWmxt1) nwmat(1) mfx(lin) dist(norm)
spmstardxt y x1 x2 [aweight = x1], nc(7) wmfile(SPWmxt1) nwmat(1) mfx(lin) dist(norm)

* (5) Weighted mSTAR Weibull Distribution:
spmstardxt y x1 x2  [weight = x1], nc(7) wmfile(SPWmxt1) nwmat(1) mfx(lin) dist(weib)
spmstardxt y x1 x2 [aweight = x1], nc(7) wmfile(SPWmxt1) nwmat(1) mfx(lin) dist(weib)

* (6) Weighted mSTAR Exponential Distribution:
spmstardxt y x1 x2  [weight = x1], nc(7) wmfile(SPWmxt1) nwmat(1) mfx(lin) dist(exp)
spmstardxt y x1 x2 [aweight = x1], nc(7) wmfile(SPWmxt1) nwmat(1) mfx(lin) dist(exp)
log close
