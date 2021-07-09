log using c:\spmstarxt.smcl , replace

clear all
sysuse spmstarxt.dta, clear

* (m-STAR) Multiparametric Spatio Temporal AutoRegressive Regression
* (m-STAR) Spatial  Panel Lag Model

*** YOU MUST HAVE DIFFERENT Weighted Matrixes Files:
 
* (1) *** Normal Distribution
spmstarxt y x1 x2 , nc(7) wmfile(SPWmxt1) nwmat(1) mfx(lin) test dist(norm)
spmstarxt y x1 x2 , nc(7) wmfile(SPWmxt2) nwmat(2) mfx(lin) test dist(norm)
spmstarxt y x1 x2 , nc(7) wmfile(SPWmxt3) nwmat(3) mfx(lin) test dist(norm)
spmstarxt y x1 x2 , nc(7) wmfile(SPWmxt4) nwmat(4) mfx(lin) test dist(norm)
spmstarxt ys x1 x2, nc(7) wmfile(SPWmxt4) nwmat(4) mfx(lin) test dist(norm) tobit ll(0)

* (2) *** Weibull Distribution
spmstarxt y x1 x2 , nc(7) wmfile(SPWmxt1) nwmat(1) mfx(lin) test dist(weib)
spmstarxt y x1 x2 , nc(7) wmfile(SPWmxt2) nwmat(2) mfx(lin) test dist(weib)
spmstarxt y x1 x2 , nc(7) wmfile(SPWmxt3) nwmat(3) mfx(lin) test dist(weib)
spmstarxt y x1 x2 , nc(7) wmfile(SPWmxt4) nwmat(4) mfx(lin) test dist(weib)
spmstarxt ys x1 x2, nc(7) wmfile(SPWmxt4) nwmat(4) mfx(lin) test dist(weib) tobit ll(0)

* (3) *** Exponential Distribution
spmstarxt y x1 x2 , nc(7) wmfile(SPWmxt1) nwmat(1) mfx(lin) test dist(exp)
spmstarxt y x1 x2 , nc(7) wmfile(SPWmxt2) nwmat(2) mfx(lin) test dist(exp)
spmstarxt y x1 x2 , nc(7) wmfile(SPWmxt3) nwmat(3) mfx(lin) test dist(exp)
spmstarxt y x1 x2 , nc(7) wmfile(SPWmxt4) nwmat(4) mfx(lin) test dist(exp)
spmstarxt ys x1 x2, nc(7) wmfile(SPWmxt4) nwmat(4) mfx(lin) test dist(exp) tobit ll(0)

* (4) Weighted mSTAR Normal Distribution:
spmstarxt y x1 x2  [weight = x1], nc(7) wmfile(SPWmxt1) nwmat(1) mfx(lin) test dist(norm)
spmstarxt y x1 x2 [aweight = x1], nc(7) wmfile(SPWmxt1) nwmat(1) mfx(lin) test dist(norm)
spmstarxt y x1 x2 [iweight = x1], nc(7) wmfile(SPWmxt1) nwmat(1) mfx(lin) test dist(norm)

* (5) Weighted mSTAR Weibull Distribution:
spmstarxt y x1 x2  [weight = x1], nc(7) wmfile(SPWmxt1) nwmat(1) mfx(lin) test dist(weib)
spmstarxt y x1 x2 [aweight = x1], nc(7) wmfile(SPWmxt1) nwmat(1) mfx(lin) test dist(weib)
spmstarxt y x1 x2 [iweight = x1], nc(7) wmfile(SPWmxt1) nwmat(1) mfx(lin) test dist(weib)

* (6) Weighted mSTAR Exponential Distribution:
spmstarxt y x1 x2  [weight = x1], nc(7) wmfile(SPWmxt1) nwmat(1) mfx(lin) test dist(exp)
spmstarxt y x1 x2 [aweight = x1], nc(7) wmfile(SPWmxt1) nwmat(1) mfx(lin) test dist(exp)
spmstarxt y x1 x2 [iweight = x1], nc(7) wmfile(SPWmxt1) nwmat(1) mfx(lin) test dist(exp)

log close
