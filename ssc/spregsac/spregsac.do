log using D:\spregsac.smcl , replace

clear all
sysuse spregsac.dta, clear

* (1) MLE Spatial SAC Normal Regression Model
spregsac y x1 x2 , wmfile(SPWcs) mfx(lin) test
spregsac y x1 x2 , wmfile(SPWcs) mfx(lin) test spar(rho)
spregsac y x1 x2 , wmfile(SPWcs) mfx(lin) test spar(lam)
spregsac y x1 x2 , wmfile(SPWcs) mfx(log) test tolog
spregsac y x1 x2 , wmfile(SPWcs) predict(Yh) resid(Ue)

* (2) MLE Spatial SAC Exponential Regression Model
spregsac y x1 x2 , wmfile(SPWcs) dist(exp) mfx(lin) test

* (3) MLE Spatial SAC Weibull Regression Model
spregsac y x1 x2 , wmfile(SPWcs) dist(weib) mfx(lin) test

* (4) MLE Weighted Spatial SAC Regression Model
spregsac y x1 x2  [weight = x1], wmfile(SPWcs) mfx(lin) test
spregsac y x1 x2 [aweight = x1], wmfile(SPWcs) mfx(lin) test

* (5) MLE Spatial SAC Tobit} - Truncated Dependent Variable (ys)
spregsac ys x1 x2, wmfile(SPWcs) mfx(lin) test tobit ll(0)
spregsac ys x1 x2, wmfile(SPWcs) mfx(lin) test tobit ll(3)

log close
