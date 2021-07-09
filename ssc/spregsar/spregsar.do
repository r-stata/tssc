log using d:\spregsar.smcl , replace

clear all
sysuse spregsar.dta, clear

* (1) MLE Spatial Lag Normal Regression Model
spregsar y x1 x2 , wmfile(SPWcs) mfx(lin) test
spregsar y x1 x2 , wmfile(SPWcs) mfx(lin) test
spregsar y x1 x2 , wmfile(SPWcs) mfx(log) test tolog
spregsar y x1 x2 , wmfile(SPWcs) predict(Yh) resid(Ue)
spregsar ys x1 x2, wmfile(SPWcs) mfx(lin) test tobit ll(0)
spregsar ys x1 x2, wmfile(SPWcs) mfx(lin) test tobit ll(3)

* (2) MLE Spatial Lag Exponential Regression Model
spregsar y x1 x2 , wmfile(SPWcs) dist(exp) mfx(lin) test

* (3) MLE Spatial Lag Weibull Regression Model
spregsar y x1 x2 , wmfile(SPWcs) dist(weib) mfx(lin) test

* (4) MLE Weighted Spatial Lag Regression Model
spregsar y x1 x2 [weight = x1], wmfile(SPWcs) mfx(lin) test
spregsar y x1 x2 [aweight = x1], wmfile(SPWcs) mfx(lin) test

* (5) MLE Spatial Lag Tobit - Truncated Dependent Variable (ys)
spregsar ys x1 x2 , wmfile(SPWcs) mfx(lin) test

* (6) MLE Spatial Lag Multiplicative Heteroscedasticity
spregsar y x1 x2 , wmfile(SPWcs) mfx(lin) test mhet(x2)

log close
