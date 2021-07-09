log using d:\spmstardh.smcl , replace

clear all
sysuse spmstardh.dta, clear

* (m-STAR) Multiparametric Spatio Temporal AutoRegressive Regression
* (m-STAR) Spatial Durbin Multiplicative Heteroscedasticity Model

*** YOU MUST HAVE DIFFERENT Weighted Matrixes Files:

* (1) mSTAR Model
spmstardh y x1 x2 , wmfile(SPWmcs1) nwmat(1) mfx(lin) mhet(x1)
spmstardh y x1 x2 , wmfile(SPWmcs2) nwmat(2) mfx(lin) mhet(x1)
spmstardh y x1 x2 , wmfile(SPWmcs3) nwmat(3) mfx(lin) mhet(x1)
spmstardh y x1 x2 , wmfile(SPWmcs4) nwmat(4) mfx(lin) mhet(x1)
spmstardh y x1 x2 , wmfile(SPWmcs4) nwmat(4) mfx(lin) mhet(x1) aux(x3 x4)
spmstardh ys x1 x2, wmfile(SPWmcs4) nwmat(4) mfx(lin) mhet(x1) tobit ll(0)

* (2) Weighted mSTAR
spmstardh y x1 x2  [weight = x1], wmfile(SPWmcs1) nwmat(1) mfx(lin) mhet(x1)
spmstardh y x1 x2 [aweight = x1], wmfile(SPWmcs1) nwmat(1) mfx(lin) mhet(x1)

log close
