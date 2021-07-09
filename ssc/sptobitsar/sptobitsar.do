log using D:\sptobitsar.smcl , replace

clear all
sysuse sptobitsar.dta, clear

* (1) Tobit MLE Spatial SAR Normal Regression Model
sptobitsar ys x1 x2 , wmfile(SPWcs) dist(norm) predict(Yh) resid(Ue) ll(0)
sptobitsar ys x1 x2 , wmfile(SPWcs) dist(norm) mfx(lin) test ll(0)
sptobitsar ys x1 x2 , wmfile(SPWcs) dist(norm) mfx(log) test ll(0) tolog

* (2) Tobit MLE Spatial SAR Exponential Regression Model
sptobitsar ys x1 x2 , wmfile(SPWcs) dist(exp) mfx(lin) test ll(0)
sptobitsar ys x1 x2 , wmfile(SPWcs) dist(exp) mfx(log) test ll(0) tolog

* (3) Tobit MLE Spatial SAR Weibull Regression Model
sptobitsar ys x1 x2 , wmfile(SPWcs) dist(weib) mfx(lin) test ll(0)
sptobitsar ys x1 x2 , wmfile(SPWcs) dist(weib) mfx(log) test ll(0) tolog

* (4) Tobit MLE Spatial Lag Multiplicative Heteroscedasticity
sptobitsar ys x1 x2 , wmfile(SPWcs) mfx(lin) test ll(0) mhet(x1 x2)
sptobitsar ys x1 x2 , wmfile(SPWcs) mfx(lin) test ll(0) mhet(x1 x2)
sptobitsar ys x1 x2 , wmfile(SPWcs) mfx(lin) test ll(0) mhet(x1 x2)

* (5) Tobit MLE Weighted Spatial SAR Regression Model
sptobitsar ys x1 x2  [weight = x1], wmfile(SPWcs) mfx(lin) test ll(0)
sptobitsar ys x1 x2 [aweight = x1], wmfile(SPWcs) mfx(lin) test ll(0)
sptobitsar ys x1 x2 [iweight = x1], wmfile(SPWcs) mfx(lin) test ll(0)

log close
