log using D:\spregsdm.smcl , replace

clear all
sysuse spregsdm.dta, clear

* (1) MLE Spatial Durbin Normal Regression Model
spregsdm y x1 x2 , wmfile(SPWcs) mfx(lin) test
spregsdm y x1 x2 , wmfile(SPWcs) mfx(lin) test
spregsdm y x1 x2 , wmfile(SPWcs) mfx(log) test tolog
spregsdm y x1 x2 , wmfile(SPWcs) predict(Yh) resid(Ue)
spregsdm y x1 x2       , wmfile(SPWcs) mfx(lin) test aux(x3 x4)
spregsdm y x1 x2 x3 x4 , wmfile(SPWcs) mfx(lin) test

* (2) MLE Spatial Durbin Exponential Regression Model
spregsdm y x1 x2 , wmfile(SPWcs) dist(exp) mfx(lin) test

* (3) MLE Spatial Durbin Weibull Regression Model
spregsdm y x1 x2 , wmfile(SPWcs) dist(weib) mfx(lin) test

* (4) MLE Weighted Spatial Durbin Regression Model
spregsdm y x1 x2  [weight = x1], wmfile(SPWcs) mfx(lin) test
spregsdm y x1 x2 [aweight = x1], wmfile(SPWcs) mfx(lin) test

* (5) MLE Spatial Durbin Tobit - Truncated Dependent Variable (ys)
spregsdm ys x1 x2, wmfile(SPWcs) mfx(lin) test tobit ll(0)
spregsdm ys x1 x2, wmfile(SPWcs) mfx(lin) test tobit ll(3) 

* (6) MLE Spatial Durbin Multiplicative Heteroscedasticity
spregsdm y x1 x2 , wmfile(SPWcs) mfx(lin) test mhet(x1 x2)

log close
