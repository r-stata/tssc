log using D:\sptobitsarxt.smcl , replace

clear all
sysuse sptobitsarxt.dta, clear

* (1) Tobit MLE Spatial Panel SAR Normal Regression Model
sptobitsarxt ys x1 x2 , nc(7) wmfile(SPWxt) dist(norm) predict(Yh) resid(Ue) ll(0)
sptobitsarxt ys x1 x2 , nc(7) wmfile(SPWxt) dist(norm) mfx(lin) test ll(0)
sptobitsarxt ys x1 x2 , nc(7) wmfile(SPWxt) dist(norm) mfx(log) test ll(0) tolog

* (2) Tobit MLE Spatial Panel SAR Exponential Regression Model
sptobitsarxt ys x1 x2 , nc(7) wmfile(SPWxt) dist(exp) mfx(lin) test ll(0)
sptobitsarxt ys x1 x2 , nc(7) wmfile(SPWxt) dist(exp) mfx(log) test ll(0) tolog

* (3) Tobit MLE Spatial Panel SAR Weibull Regression Model
sptobitsarxt ys x1 x2 , nc(7) wmfile(SPWxt) dist(weib) mfx(lin) test ll(0)
sptobitsarxt ys x1 x2 , nc(7) wmfile(SPWxt) dist(weib) mfx(log) test ll(0) tolog

* (4) Tobit MLE Weighted Spatial Panel SAR Regression Model
sptobitsarxt ys x1 x2  [weight = x1], nc(7) wmfile(SPWxt) mfx(lin) test ll(0)
sptobitsarxt ys x1 x2 [aweight = x1], nc(7) wmfile(SPWxt) mfx(lin) test ll(0)
sptobitsarxt ys x1 x2 [iweight = x1], nc(7) wmfile(SPWxt) mfx(lin) test ll(0)

* (5) Tobit MLE Spatial Lag Panel Multiplicative Heteroscedasticity
sptobitsarxt ys x1 x2 , nc(7) wmfile(SPWxt) mfx(lin) test ll(0) mhet(x1 x2)
sptobitsarxt ys x1 x2 , nc(7) wmfile(SPWxt) mfx(lin) test ll(0) mhet(x1 x2)
sptobitsarxt ys x1 x2 , nc(7) wmfile(SPWxt) mfx(lin) test ll(0) mhet(x1 x2)

log close
