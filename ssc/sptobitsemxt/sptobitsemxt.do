log using D:\sptobitsemxt.smcl , replace

clear all
sysuse sptobitsemxt.dta, clear

* (1) Tobit MLE Spatial SAC Panel Normal Regression Model
sptobitsemxt y x1 x2 , nc(7) wmfile(SPWxt) dist(norm) predict(Yh) resid(Ue) ll(3)
sptobitsemxt y x1 x2 , nc(7) wmfile(SPWxt) dist(norm) mfx(lin) test ll(3)
sptobitsemxt y x1 x2 , nc(7) wmfile(SPWxt) dist(norm) mfx(log) test ll(3) tolog

* (2) Tobit MLE Spatial SAC Panel Exponential Regression Model
sptobitsemxt y x1 x2 , nc(7) wmfile(SPWxt) dist(exp) mfx(lin) test ll(3)
sptobitsemxt y x1 x2 , nc(7) wmfile(SPWxt) dist(exp) mfx(log) test ll(3) tolog

* (3) Tobit MLE Spatial SAC Panel Weibull Regression Model
sptobitsemxt y x1 x2 , nc(7) wmfile(SPWxt) dist(weib) mfx(lin) test ll(3)
sptobitsemxt y x1 x2 , nc(7) wmfile(SPWxt) dist(weib) mfx(log) test ll(3) tolog

* (4) Tobit MLE Weighted Spatial SAC Panel Regression Model
sptobitsemxt y x1 x2  [weight = x1], nc(7) wmfile(SPWxt) mfx(lin) test ll(3)
sptobitsemxt y x1 x2 [aweight = x1], nc(7) wmfile(SPWxt) mfx(lin) test ll(3)
sptobitsemxt y x1 x2 [iweight = x1], nc(7) wmfile(SPWxt) mfx(lin) test ll(3)

log close
