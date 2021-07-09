log using D:\sptobitmstarxt.smcl , replace

clear all
sysuse sptobitmstarxt.dta, clear

* Tobit (m-STAR) Multiparametric Spatio Temporal AutoRegressive Regression
* (m-STAR) Spatial  Panel Lag Model

*** YOU MUST HAVE DIFFERENT Weighted Matrixes Files:
 
* (1) *** Normal Distribution
sptobitmstarxt ys x1 x2, nc(7) wmfile(SPWmxt1) nwmat(1) mfx(lin) test dist(norm) ll(0)
sptobitmstarxt ys x1 x2, nc(7) wmfile(SPWmxt2) nwmat(2) mfx(lin) test dist(norm) ll(0)
sptobitmstarxt ys x1 x2, nc(7) wmfile(SPWmxt3) nwmat(3) mfx(lin) test dist(norm) ll(0)
sptobitmstarxt ys x1 x2, nc(7) wmfile(SPWmxt4) nwmat(4) mfx(lin) test dist(norm) ll(0)

* (2) *** Weibull Distribution
sptobitmstarxt ys x1 x2, nc(7) wmfile(SPWmxt1) nwmat(1) mfx(lin) test dist(weib) ll(0)
sptobitmstarxt ys x1 x2, nc(7) wmfile(SPWmxt2) nwmat(2) mfx(lin) test dist(weib) ll(0)
sptobitmstarxt ys x1 x2, nc(7) wmfile(SPWmxt3) nwmat(3) mfx(lin) test dist(weib) ll(0)
sptobitmstarxt ys x1 x2, nc(7) wmfile(SPWmxt4) nwmat(4) mfx(lin) test dist(weib) ll(0)

* (3) *** Exponential Distribution
sptobitmstarxt ys x1 x2, nc(7) wmfile(SPWmxt1) nwmat(1) mfx(lin) test dist(exp) ll(0)
sptobitmstarxt ys x1 x2, nc(7) wmfile(SPWmxt2) nwmat(2) mfx(lin) test dist(exp) ll(0)
sptobitmstarxt ys x1 x2, nc(7) wmfile(SPWmxt3) nwmat(3) mfx(lin) test dist(exp) ll(0)
sptobitmstarxt ys x1 x2, nc(7) wmfile(SPWmxt4) nwmat(4) mfx(lin) test dist(exp) ll(0)

* (4) Weighted mSTAR Normal Distribution:
sptobitmstarxt ys x1 x2  [weight = x1], nc(7) wmfile(SPWmxt1) nwmat(1) mfx(lin) test dist(norm) ll(0)
sptobitmstarxt ys x1 x2 [aweight = x1], nc(7) wmfile(SPWmxt1) nwmat(1) mfx(lin) test dist(norm) ll(0)
sptobitmstarxt ys x1 x2 [iweight = x1], nc(7) wmfile(SPWmxt1) nwmat(1) mfx(lin) test dist(norm) ll(0)

* (5) Weighted mSTAR Weibull Distribution:
sptobitmstarxt ys x1 x2  [weight = x1], nc(7) wmfile(SPWmxt1) nwmat(1) mfx(lin) test dist(weib) ll(0)
sptobitmstarxt ys x1 x2 [aweight = x1], nc(7) wmfile(SPWmxt1) nwmat(1) mfx(lin) test dist(weib) ll(0)
sptobitmstarxt ys x1 x2 [iweight = x1], nc(7) wmfile(SPWmxt1) nwmat(1) mfx(lin) test dist(weib) ll(0)

* (6) Weighted mSTAR Exponential Distribution:
sptobitmstarxt ys x1 x2  [weight = x1], nc(7) wmfile(SPWmxt1) nwmat(1) mfx(lin) test dist(exp) ll(0)
sptobitmstarxt ys x1 x2 [aweight = x1], nc(7) wmfile(SPWmxt1) nwmat(1) mfx(lin) test dist(exp) ll(0)
sptobitmstarxt ys x1 x2 [iweight = x1], nc(7) wmfile(SPWmxt1) nwmat(1) mfx(lin) test dist(exp) ll(0)

log close
