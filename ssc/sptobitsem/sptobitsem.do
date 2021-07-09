log using D:\sptobitsem.smcl , replace

clear all
sysuse sptobitsem.dta, clear

* (1) Tobit MLE Spatial SAC Normal Regression Model
sptobitsem ys x1 x2 , wmfile(SPWcs) dist(norm) predict(Yh) resid(Ue) ll(3)
sptobitsem ys x1 x2 , wmfile(SPWcs) dist(norm) mfx(lin) test ll(3)
sptobitsem ys x1 x2 , wmfile(SPWcs) dist(norm) mfx(log) test ll(3) tolog

* (2) Tobit MLE Spatial SAC Exponential Regression Model
sptobitsem ys x1 x2 , wmfile(SPWcs) dist(exp) mfx(lin) test ll(3)
sptobitsem ys x1 x2 , wmfile(SPWcs) dist(exp) mfx(log) test ll(3) tolog

* (3) Tobit MLE Spatial SAC Weibull Regression Model
sptobitsem ys x1 x2 , wmfile(SPWcs) dist(weib) mfx(lin) test ll(3)
sptobitsem ys x1 x2 , wmfile(SPWcs) dist(weib) mfx(log) test ll(3) tolog

* (4) Tobit MLE Weighted Spatial SAC Regression Model
sptobitsem ys x1 x2  [weight = x1], wmfile(SPWcs) mfx(lin) test ll(3)
sptobitsem ys x1 x2 [aweight = x1], wmfile(SPWcs) mfx(lin) test ll(3)
sptobitsem ys x1 x2 [iweight = x1], wmfile(SPWcs) mfx(lin) test ll(3)

log close
