log using c:\spmstard.smcl , replace
clear all
sysuse spmstard.dta, clear

* (m-STAR) Multiparametric Spatio Temporal AutoRegressive Regression
*  m-STAR Spatial Durbin Model

*** YOU MUST HAVE DIFFERENT Weighted Matrixes Files:

* (1) *** Normal Distribution
spmstard y x1 x2 , wmfile(SPWmcs1) nwmat(1) mfx(lin) dist(norm)
spmstard y x1 x2 , wmfile(SPWmcs2) nwmat(2) mfx(lin) dist(norm)
spmstard y x1 x2 , wmfile(SPWmcs3) nwmat(3) mfx(lin) dist(norm)
spmstard y x1 x2 , wmfile(SPWmcs4) nwmat(4) mfx(lin) dist(norm)
spmstard y x1 x2 , wmfile(SPWmcs4) nwmat(4) mfx(lin) dist(norm) aux(x3 x4)
spmstard ys x1 x2, wmfile(SPWmcs4) nwmat(4) mfx(lin) dist(norm) tobit ll(0)
spmstard ys x1 x2, wmfile(SPWmcs4) nwmat(4) mfx(lin) dist(norm) tobit ll(3)

* (2) *** Weibull Distribution
spmstard y x1 x2 , wmfile(SPWmcs1) nwmat(1) mfx(lin) dist(weib)
spmstard y x1 x2 , wmfile(SPWmcs2) nwmat(2) mfx(lin) dist(weib)
spmstard y x1 x2 , wmfile(SPWmcs3) nwmat(3) mfx(lin) dist(weib)
spmstard y x1 x2 , wmfile(SPWmcs4) nwmat(4) mfx(lin) dist(weib)
spmstard y x1 x2 , wmfile(SPWmcs4) nwmat(4) mfx(lin) dist(weib) aux(x3 x4)
spmstard ys x1 x2, wmfile(SPWmcs4) nwmat(4) mfx(lin) dist(weib) tobit ll(0)
spmstard ys x1 x2, wmfile(SPWmcs4) nwmat(4) mfx(lin) dist(weib) tobit ll(3)

* (3) Weighted mSTAR Normal Distribution:
spmstard y x1 x2 [weight = x1], wmfile(SPWmcs1) nwmat(1) mfx(lin) dist(norm)
spmstard y x1 x2 [aweight = x1], wmfile(SPWmcs1) nwmat(1) mfx(lin) dist(norm)
spmstard y x1 x2 [iweight = x1], wmfile(SPWmcs1) nwmat(1) mfx(lin) dist(norm)

* (4) Weighted mSTAR Weibull Distribution:
spmstard y x1 x2 [weight = x1], wmfile(SPWmcs1) nwmat(1) mfx(lin) dist(weib)
spmstard y x1 x2 [aweight = x1], wmfile(SPWmcs1) nwmat(1) mfx(lin) dist(weib)
spmstard y x1 x2 [iweight = x1], wmfile(SPWmcs1) nwmat(1) mfx(lin) dist(weib)

log close

