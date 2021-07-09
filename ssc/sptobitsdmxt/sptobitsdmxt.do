log using D:\sptobitsdmxt.smcl , replace

clear all
sysuse sptobitsdmxt.dta, clear

* (1) Tobit MLE Spatial Panel Durbin Normal Regression Model
sptobitsdmxt ys x1 x2 , nc(7) wmfile(SPWxt) mfx(lin) test ll(0) dist(norm)
sptobitsdmxt ys x1 x2 , nc(7) wmfile(SPWxt) mfx(log) test ll(0) dist(norm) tolog
sptobitsdmxt ys x1 x2 , nc(7) wmfile(SPWxt) mfx(lin) test ll(0) dist(norm) aux(x3 x4)
sptobitsdmxt ys x1 x2 x3 x4 , nc(7) wmfile(SPWxt) mfx(lin) test ll(0) dist(norm)
sptobitsdmxt ys x1 x2 , nc(7) wmfile(SPWxt) predict(Yh) resid(Ue) ll(0) dist(norm)

* (2) Tobit MLE Spatial Panel Durbin Exponential Regression Model
sptobitsdmxt ys x1 x2 , nc(7) wmfile(SPWxt) mfx(lin) test ll(0) dist(exp)
sptobitsdmxt ys x1 x2 , nc(7) wmfile(SPWxt) mfx(log) test ll(0) dist(exp) tolog
sptobitsdmxt ys x1 x2 , nc(7) wmfile(SPWxt) mfx(lin) test ll(0) dist(exp) aux(x3 x4)
sptobitsdmxt ys x1 x2 x3 x4 , nc(7) wmfile(SPWxt) mfx(lin) test ll(0) dist(exp)
sptobitsdmxt ys x1 x2 , nc(7) wmfile(SPWxt) predict(Yh) resid(Ue) ll(0) dist(exp)

* (3) Tobit MLE Spatial Panel Durbin Weibull Regression Model
sptobitsdmxt ys x1 x2 , nc(7) wmfile(SPWxt) mfx(lin) test ll(0) dist(weib)
sptobitsdmxt ys x1 x2 , nc(7) wmfile(SPWxt) mfx(log) test ll(0) dist(weib) tolog
sptobitsdmxt ys x1 x2 , nc(7) wmfile(SPWxt) mfx(lin) test ll(0) dist(weib) aux(x3 x4)
sptobitsdmxt ys x1 x2 x3 x4 , nc(7) wmfile(SPWxt) mfx(lin) test ll(0) dist(weib)
sptobitsdmxt ys x1 x2 , nc(7) wmfile(SPWxt) predict(Yh) resid(Ue) ll(0) dist(weib)

* (4) Tobit MLE Spatial Panel Durbin Multiplicative Heteroscedasticity
sptobitsdmxt ys x1 x2 , nc(7) wmfile(SPWxt) mfx(lin) test ll(0) mhet(x1 x2)
sptobitsdmxt ys x1 x2 , nc(7) wmfile(SPWxt) mfx(lin) test ll(0) mhet(x1 x2)
sptobitsdmxt ys x1 x2 , nc(7) wmfile(SPWxt) mfx(lin) test ll(0) mhet(x1 x2)

* (5) Tobit MLE Weighted Spatial Panel Durbin Regression Model
sptobitsdmxt ys x1 x2  [weight = x1], nc(7) wmfile(SPWxt) mfx(lin) test ll(0)
sptobitsdmxt ys x1 x2 [aweight = x1], nc(7) wmfile(SPWxt) mfx(lin) test ll(0)
sptobitsdmxt ys x1 x2 [iweight = x1], nc(7) wmfile(SPWxt) mfx(lin) test ll(0)

log close
