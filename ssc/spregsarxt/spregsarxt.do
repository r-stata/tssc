log using D:\spregsarxt.smcl , replace

clear all
sysuse spregsarxt.dta, clear

* (1) MLE Spatial Lag Panel Normal Regression Model
spregsarxt y x1 x2 , nc(7) wmfile(SPWxt) mfx(lin) test
spregsarxt y x1 x2 , nc(7) wmfile(SPWxt) mfx(lin) test
spregsarxt y x1 x2 , nc(7) wmfile(SPWxt) mfx(log) test tolog
spregsarxt y x1 x2 , nc(7) wmfile(SPWxt) predict(Yh) resid(Ue)
spregsarxt ys x1 x2, nc(7) wmfile(SPWxt) mfx(lin) test tobit ll(0)
spregsarxt ys x1 x2, nc(7) wmfile(SPWxt) mfx(lin) test tobit ll(3)

* (2) MLE Spatial Lag Panel Exponential Regression Model
spregsarxt y x1 x2 , nc(7) wmfile(SPWxt) dist(exp) mfx(lin) test

* (3) MLE Spatial Lag Panel Weibull Regression Model
spregsarxt y x1 x2 , nc(7) wmfile(SPWxt) dist(weib) mfx(lin) test

* (4) MLE Weighted Spatial Lag Panel Regression Model
spregsarxt y x1 x2 [weight = x1] , nc(7) wmfile(SPWxt) mfx(lin) test
spregsarxt y x1 x2 [aweight = x1] , nc(7) wmfile(SPWxt) mfx(lin) test

* (5) MLE Spatial Lag Panel Tobit - Truncated Dependent Variable (ys)
spregsarxt ys x1 x2 , nc(7) wmfile(SPWxt) mfx(lin) test tobit ll(0)

* (6) MLE Spatial Lag Panel Multiplicative Heteroscedasticity
spregsarxt y x1 x2 , nc(7) wmfile(SPWxt) mfx(lin) test mhet(x2)

log close
