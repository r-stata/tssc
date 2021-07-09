log using D:\sptobitmstardxt.smcl , replace

clear all
sysuse sptobitmstardxt.dta, clear

* Tobit (m-STAR) Multiparametric Spatio Temporal AutoRegressive Regression
* (m-STAR) Spatial Durbin Panel Models

*** YOU MUST HAVE DIFFERENT Weighted Matrixes Files:

* (1) *** Normal Distribution
sptobitmstardxt ys x1 x2, nc(7) wmfile(SPWmxt1) nwmat(1) mfx(log) test ll(0) tolog
sptobitmstardxt ys x1 x2, nc(7) wmfile(SPWmxt1) nwmat(1) mfx(lin) dist(norm) test ll(0)
sptobitmstardxt ys x1 x2, nc(7) wmfile(SPWmxt2) nwmat(2) mfx(lin) dist(norm) test ll(0)
sptobitmstardxt ys x1 x2, nc(7) wmfile(SPWmxt3) nwmat(3) mfx(lin) dist(norm) test ll(0)
sptobitmstardxt ys x1 x2, nc(7) wmfile(SPWmxt4) nwmat(4) mfx(lin) dist(norm) test ll(0)

* (2) *** Weibull Distribution
sptobitmstardxt ys x1 x2, nc(7) wmfile(SPWmxt1) nwmat(1) mfx(lin) dist(weib) test ll(0)
sptobitmstardxt ys x1 x2, nc(7) wmfile(SPWmxt2) nwmat(2) mfx(log) test ll(0) tolog
sptobitmstardxt ys x1 x2, nc(7) wmfile(SPWmxt2) nwmat(2) mfx(lin) dist(weib) test ll(0)
sptobitmstardxt ys x1 x2, nc(7) wmfile(SPWmxt3) nwmat(3) mfx(lin) dist(weib) test ll(0)
sptobitmstardxt ys x1 x2, nc(7) wmfile(SPWmxt4) nwmat(4) mfx(lin) dist(weib) test ll(0)

* (3) *** Exponential Distribution
sptobitmstardxt ys x1 x2, nc(7) wmfile(SPWmxt1) nwmat(1) mfx(lin) dist(exp) test ll(0)
sptobitmstardxt ys x1 x2, nc(7) wmfile(SPWmxt2) nwmat(2) mfx(lin) dist(exp) test ll(0)
sptobitmstardxt ys x1 x2, nc(7) wmfile(SPWmxt3) nwmat(3) mfx(log) test ll(0) tolog
sptobitmstardxt ys x1 x2, nc(7) wmfile(SPWmxt3) nwmat(3) mfx(lin) dist(exp) test ll(0)
sptobitmstardxt ys x1 x2, nc(7) wmfile(SPWmxt4) nwmat(4) mfx(lin) dist(exp) test ll(0)

* (4) Weighted mSTAR Normal Distribution:
sptobitmstardxt ys x1 x2  [weight = x1], nc(7) wmfile(SPWmxt1) nwmat(1) mfx(lin) dist(norm) ll(0)
sptobitmstardxt ys x1 x2 [aweight = x1], nc(7) wmfile(SPWmxt1) nwmat(1) mfx(lin) dist(norm) ll(0)

* (5) Weighted mSTAR Weibull Distribution:
sptobitmstardxt ys x1 x2  [weight = x1], nc(7) wmfile(SPWmxt1) nwmat(1) mfx(lin) dist(weib) ll(0)
sptobitmstardxt ys x1 x2 [aweight = x1], nc(7) wmfile(SPWmxt1) nwmat(1) mfx(lin) dist(weib) ll(0)

* (6) Weighted mSTAR Exponential Distribution:
sptobitmstardxt ys x1 x2  [weight = x1], nc(7) wmfile(SPWmxt1) nwmat(1) mfx(lin) dist(exp) ll(0)
sptobitmstardxt ys x1 x2 [aweight = x1], nc(7) wmfile(SPWmxt1) nwmat(1) mfx(lin) dist(exp) ll(0)

log close
