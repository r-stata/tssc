log using D:\sptobitmstardh.smcl , replace

clear all
sysuse sptobitmstardh.dta, clear

* Tobit (m-STAR) Multiparametric Spatio Temporal AutoRegressive Regression
* (m-STAR) Spatial Durbin Multiplicative Heteroscedasticity Model

*** YOU MUST HAVE DIFFERENT Weighted Matrixes Files:

* (1) mSTAR Model
sptobitmstardh y x1 x2 , wmfile(SPWmcs1) nwmat(1) mfx(lin) mhet(x1) ll(0)
sptobitmstardh y x1 x2 , wmfile(SPWmcs2) nwmat(2) mfx(lin) mhet(x1) ll(0)
sptobitmstardh y x1 x2 , wmfile(SPWmcs3) nwmat(3) mfx(lin) mhet(x1) ll(0)
sptobitmstardh y x1 x2 , wmfile(SPWmcs4) nwmat(4) mfx(lin) mhet(x1) ll(0)

* (2) Weighted mSTAR
sptobitmstardh y x1 x2  [weight = x1], wmfile(SPWmcs1) nwmat(1) mfx(lin) mhet(x1) ll(0)
sptobitmstardh y x1 x2 [aweight = x1], wmfile(SPWmcs1) nwmat(1) mfx(lin) mhet(x1) ll(0)

log close
