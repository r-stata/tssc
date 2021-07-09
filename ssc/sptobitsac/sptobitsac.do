log using D:\sptobitsac.smcl , replace

clear all
sysuse sptobitsac.dta, clear

* (1) Tobit MLE Spatial SAC Normal Regression Model
sptobitsac ys x1 x2 , wmfile(SPWcs) dist(norm) predict(Yh) resid(Ue) ll(0)
sptobitsac ys x1 x2 , wmfile(SPWcs) dist(norm) mfx(lin) test ll(0)
sptobitsac ys x1 x2 , wmfile(SPWcs) dist(norm) mfx(lin) test ll(0) spar(rho)
sptobitsac ys x1 x2 , wmfile(SPWcs) dist(norm) mfx(lin) test ll(0) spar(lam)
sptobitsac ys x1 x2 , wmfile(SPWcs) dist(norm) mfx(log) test ll(0) tolog

* (2) Tobit MLE Spatial SAC Exponential Regression Model
sptobitsac ys x1 x2 , wmfile(SPWcs) dist(exp) mfx(lin) test ll(0)

* (3) Tobit MLE Spatial SAC Weibull Regression Model
sptobitsac ys x1 x2 , wmfile(SPWcs) dist(weib) mfx(lin) test ll(0)

* (4) Tobit MLE Weighted Spatial SAC Regression Model
sptobitsac ys x1 x2  [weight = x1], wmfile(SPWcs) mfx(lin) test ll(0)
sptobitsac ys x1 x2 [aweight = x1], wmfile(SPWcs) mfx(lin) test ll(0)
sptobitsac ys x1 x2 [iweight = x1], wmfile(SPWcs) mfx(lin) test ll(0)

log close
