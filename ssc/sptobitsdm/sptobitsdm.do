log using D:\sptobitsdm.smcl , replace

clear all
sysuse sptobitsdm.dta, clear

* (1) Tobit MLE Spatial Durbin Normal Regression Model
sptobitsdm ys x1 x2 , wmfile(SPWcs) mfx(lin) test ll(0) dist(norm)
sptobitsdm ys x1 x2 , wmfile(SPWcs) mfx(log) test ll(0) dist(norm) tolog
sptobitsdm ys x1 x2 , wmfile(SPWcs) mfx(lin) test ll(0) dist(norm) aux(x3 x4)
sptobitsdm ys x1 x2 x3 x4 , wmfile(SPWcs) mfx(lin) test ll(0) dist(norm)
sptobitsdm ys x1 x2 , wmfile(SPWcs) predict(Yh) resid(Ue) ll(0) dist(norm)

* (2) Tobit MLE Spatial Durbin Exponential Regression Model
sptobitsdm ys x1 x2 , wmfile(SPWcs) mfx(lin) test ll(0) dist(exp)
sptobitsdm ys x1 x2 , wmfile(SPWcs) mfx(log) test ll(0) dist(exp) tolog
sptobitsdm ys x1 x2 , wmfile(SPWcs) mfx(lin) test ll(0) dist(exp) aux(x3 x4)
sptobitsdm ys x1 x2 x3 x4 , wmfile(SPWcs) mfx(lin) test ll(0) dist(exp)
sptobitsdm ys x1 x2 , wmfile(SPWcs) predict(Yh) resid(Ue) ll(0) dist(exp)

* (3) Tobit MLE Spatial Durbin Weibull Regression Model
sptobitsdm ys x1 x2 , wmfile(SPWcs) mfx(lin) test ll(0) dist(weib)
sptobitsdm ys x1 x2 , wmfile(SPWcs) mfx(log) test ll(0) dist(weib) tolog
sptobitsdm ys x1 x2 , wmfile(SPWcs) mfx(lin) test ll(0) dist(weib) aux(x3 x4)
sptobitsdm ys x1 x2 x3 x4 , wmfile(SPWcs) mfx(lin) test ll(0) dist(weib)
sptobitsdm ys x1 x2 , wmfile(SPWcs) predict(Yh) resid(Ue) ll(0) dist(weib)

* (4) Tobit MLE Spatial Durbin Multiplicative Heteroscedasticity
sptobitsdm ys x1 x2 , wmfile(SPWcs) mfx(lin) test ll(0) mhet(x1 x2)
sptobitsdm ys x1 x2 , wmfile(SPWcs) mfx(lin) test ll(0) mhet(x1 x2)
sptobitsdm ys x1 x2 , wmfile(SPWcs) mfx(lin) test ll(0) mhet(x1 x2)

* (5) Tobit MLE Weighted Spatial Durbin Regression Model
sptobitsdm ys x1 x2  [weight = x1], wmfile(SPWcs) mfx(lin) test ll(0)
sptobitsdm ys x1 x2 [aweight = x1], wmfile(SPWcs) mfx(lin) test ll(0)
sptobitsdm ys x1 x2 [iweight = x1], wmfile(SPWcs) mfx(lin) test ll(0)

log close
