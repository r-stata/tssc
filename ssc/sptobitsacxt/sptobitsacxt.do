log using D:\spregsacxt.smcl , replace

clear all
sysuse sptobitsacxt.dta, clear

* (1) Tobit MLE Spatial Panel SAC Normal Regression Model
sptobitsacxt ys x1 x2 , nc(7) wmfile(SPWxt) dist(norm) predict(Yh) resid(Ue) ll(3)
sptobitsacxt ys x1 x2 , nc(7) wmfile(SPWxt) dist(norm) mfx(lin) test ll(3)
sptobitsacxt ys x1 x2 , nc(7) wmfile(SPWxt) dist(norm) mfx(lin) test ll(3) spar(rho)
sptobitsacxt ys x1 x2 , nc(7) wmfile(SPWxt) dist(norm) mfx(lin) test ll(3) spar(lam)
sptobitsacxt ys x1 x2 , nc(7) wmfile(SPWxt) dist(norm) mfx(log) test ll(3) tolog

* (2) Tobit MLE Spatial Panel SAC Exponential Regression Model
sptobitsacxt ys x1 x2 , nc(7) wmfile(SPWxt) dist(exp) mfx(lin) test ll(3)
sptobitsacxt ys x1 x2 , nc(7) wmfile(SPWxt) dist(exp) mfx(lin) test ll(3) spar(rho)
sptobitsacxt ys x1 x2 , nc(7) wmfile(SPWxt) dist(exp) mfx(lin) test ll(3) spar(lam)
sptobitsacxt ys x1 x2 , nc(7) wmfile(SPWxt) dist(exp) mfx(log) test ll(3) tolog

* (3) Tobit MLE Spatial Panel SAC Weibull Regression Model
sptobitsacxt ys x1 x2 , nc(7) wmfile(SPWxt) dist(weib) mfx(lin) test ll(3)
sptobitsacxt ys x1 x2 , nc(7) wmfile(SPWxt) dist(weib) mfx(lin) test ll(3) spar(rho)
sptobitsacxt ys x1 x2 , nc(7) wmfile(SPWxt) dist(weib) mfx(lin) test ll(3) spar(lam)
sptobitsacxt ys x1 x2 , nc(7) wmfile(SPWxt) dist(weib) mfx(log) test ll(3) tolog

* (4) Tobit MLE Weighted Spatial Panel SAC Regression Model
sptobitsacxt ys x1 x2  [weight = x1], nc(7) wmfile(SPWxt) mfx(lin) test ll(3)
sptobitsacxt ys x1 x2 [aweight = x1], nc(7) wmfile(SPWxt) mfx(lin) test ll(3)
sptobitsacxt ys x1 x2 [iweight = x1], nc(7) wmfile(SPWxt) mfx(lin) test ll(3)

log close
