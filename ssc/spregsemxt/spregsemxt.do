log using D:\spregsemxt.smcl , replace

clear all
sysuse spregsemxt.dta, clear

* (1) MLE Spatial Error Panel Normal Regression Model
spregsemxt y x1 x2 , nc(7) wmfile(SPWxt) mfx(lin) test
spregsemxt y x1 x2 , nc(7) wmfile(SPWxt) mfx(lin) test
spregsemxt y x1 x2 , nc(7) wmfile(SPWxt) mfx(log) test tolog
spregsemxt y x1 x2 , nc(7) wmfile(SPWxt) predict(Yh) resid(Ue)

* (2) MLE Spatial Error Panel Exponential Regression Model
spregsemxt y x1 x2 , nc(7) wmfile(SPWxt) mfx(lin) test dist(exp)

* (3) MLE Spatial Error Panel Weibull Regression Model
spregsemxt y x1 x2 , nc(7) wmfile(SPWxt) mfx(lin) test dist(weib)

* (4) MLE Weighted Spatial Error Panel Regression Model
spregsemxt y x1 x2  [weight = x1] , nc(7) wmfile(SPWxt) mfx(lin) test
spregsemxt y x1 x2 [aweight = x1] , nc(7) wmfile(SPWxt) mfx(lin) test

* (5) MLE Spatial Error Panel Tobit - Truncated Dependent Variable (ys)
spregsemxt ys x1 x2, nc(7) wmfile(SPWxt) mfx(lin) test tobit ll(0)
spregsemxt ys x1 x2, nc(7) wmfile(SPWxt) mfx(lin) test tobit ll(3)

log close
