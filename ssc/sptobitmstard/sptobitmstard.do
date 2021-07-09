log using D:\sptobitmstard.smcl , replace

clear all
sysuse sptobitmstard.dta, clear

* (m-STAR) Multiparametric Spatio Temporal AutoRegressive Regression
* (m-STAR) Durbin Model

*** YOU MUST HAVE DIFFERENT Weighted Matrixes Files:

* (1) *** Normal Distribution
sptobitmstard ys x1 x2 , wmfile(SPWmcs1) nwmat(1) mfx(lin) dist(norm) ll(0)
sptobitmstard ys x1 x2 , wmfile(SPWmcs2) nwmat(2) mfx(lin) dist(norm) ll(0)
sptobitmstard ys x1 x2 , wmfile(SPWmcs3) nwmat(3) mfx(lin) dist(norm) ll(0)
sptobitmstard ys x1 x2 , wmfile(SPWmcs4) nwmat(4) mfx(lin) dist(norm) ll(0)
sptobitmstard ys x1 x2 , wmfile(SPWmcs4) nwmat(4) mfx(lin) dist(norm) aux(x3 x4) ll(0)

* (2) *** Weibull Distribution
sptobitmstard ys x1 x2 , wmfile(SPWmcs1) nwmat(1) mfx(lin) dist(weib) ll(0)
sptobitmstard ys x1 x2 , wmfile(SPWmcs2) nwmat(2) mfx(lin) dist(weib) ll(0)
sptobitmstard ys x1 x2 , wmfile(SPWmcs3) nwmat(3) mfx(lin) dist(weib) ll(0)
sptobitmstard ys x1 x2 , wmfile(SPWmcs4) nwmat(4) mfx(lin) dist(weib) ll(0)
sptobitmstard ys x1 x2 , wmfile(SPWmcs4) nwmat(4) mfx(lin) dist(weib) aux(x3 x4) ll(0)

* (3) Weighted mSTAR Normal Distribution:
sptobitmstard ys x1 x2  [weight = x1], wmfile(SPWmcs1) nwmat(1) mfx(lin) dist(norm) ll(0)
sptobitmstard ys x1 x2 [aweight = x1], wmfile(SPWmcs1) nwmat(1) mfx(lin) dist(norm) ll(0)

* (4) Weighted mSTAR Weibull Distribution:
sptobitmstard ys x1 x2  [weight = x1], wmfile(SPWmcs1) nwmat(1) mfx(lin) dist(weib) ll(0)
sptobitmstard ys x1 x2 [aweight = x1], wmfile(SPWmcs1) nwmat(1) mfx(lin) dist(weib) ll(0)

log close
