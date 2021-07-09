log using D:\sptobitmstarh.smcl , replace

clear all
sysuse sptobitmstarh.dta, clear

* Tobit (m-STAR) Multiparametric Spatio Temporal AutoRegressive Regression
* (m-STAR) Spatial Lag Multiplicative Heteroscedasticity Model

*** YOU MUST HAVE DIFFERENT Weighted Matrixes Files:

* (1) *** m-STAR Model
sptobitmstarh ys x1 x2 , wmfile(SPWmcs1) nwmat(1) mfx(log) mhet(x1 x2) ll(0) tolog
sptobitmstarh ys x1 x2 , wmfile(SPWmcs1) nwmat(1) mfx(lin) mhet(x1 x2) ll(0)
sptobitmstarh ys x1 x2 , wmfile(SPWmcs2) nwmat(2) mfx(lin) mhet(x1 x2) ll(0)
sptobitmstarh ys x1 x2 , wmfile(SPWmcs3) nwmat(3) mfx(lin) mhet(x1 x2) ll(0)
sptobitmstarh ys x1 x2 , wmfile(SPWmcs4) nwmat(4) mfx(lin) mhet(x1 x2) ll(0)

* (2) Weighted mSTAR
sptobitmstarh ys x1 x2  [weight= x1], wmfile(SPWmcs1) nwmat(1) mfx(lin) mhet(x1 x2) ll(0)
sptobitmstarh ys x1 x2  [weight= x1], wmfile(SPWmcs2) nwmat(2) mfx(lin) mhet(x1 x2) ll(0)
sptobitmstarh ys x1 x2  [weight= x1], wmfile(SPWmcs3) nwmat(3) mfx(lin) mhet(x1 x2) ll(0)
sptobitmstarh ys x1 x2  [weight= x1], wmfile(SPWmcs4) nwmat(4) mfx(lin) mhet(x1 x2) ll(0)

log close

