log using D:\spregsacxt.smcl , replace

clear all
sysuse spregsacxt.dta, clear

* (1) MLE Spatial Panel SAC Normal Regression Model
spregsacxt y x1 x2 , nc(7) wmfile(SPWxt) mfx(lin) test
spregsacxt y x1 x2 , nc(7) wmfile(SPWxt) mfx(lin) test spar(rho)
spregsacxt y x1 x2 , nc(7) wmfile(SPWxt) mfx(lin) test spar(lam)
spregsacxt y x1 x2 , nc(7) wmfile(SPWxt) mfx(log) test tolog
spregsacxt y x1 x2 , nc(7) wmfile(SPWxt) predict(Yh) resid(Ue)

* (2) MLE Spatial Panel SAC Exponential Regression Model
spregsacxt y x1 x2 , nc(7) wmfile(SPWxt) mfx(lin) test dist(exp)

* (3) MLE Spatial Panel SAC Weibull Regression Model
spregsacxt y x1 x2 , nc(7) wmfile(SPWxt) mfx(lin) test dist(weib)

* (4) MLE Weighted Spatial Panel SAC Regression Model
spregsacxt y x1 x2 [weight = x1] , nc(7) wmfile(SPWxt) mfx(lin) test
spregsacxt y x1 x2 [aweight = x1] , nc(7) wmfile(SPWxt) mfx(lin) test

* (5) MLE Spatial Panel SAC Tobit - Truncated Dependent Variable (ys)
spregsacxt ys x1 x2, nc(7) wmfile(SPWxt) mfx(lin) test tobit ll(0)
spregsacxt ys x1 x2, nc(7) wmfile(SPWxt) mfx(lin) test tobit ll(3)

log close
