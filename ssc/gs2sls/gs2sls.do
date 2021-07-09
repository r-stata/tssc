log using c:\gs2sls.smcl , replace

clear all
sysuse gs2sls.dta, clear

* (1) Generalized Spatial 2SLS - AR(1) (GS2SLS)
gs2sls y x1 x2 , wmfile(SPWcs) order(1) mfx(lin) test
gs2sls y x1 x2 , wmfile(SPWcs) order(1) mfx(log) test tolog
gs2sls y x1 x2 [weight=x1] , wmfile(SPWcs) order(1) mfx(lin) test

* (2) Generalized Spatial 2SLS - AR(2) (GS2SLS)
gs2sls y x1 x2 , wmfile(SPWcs) order(2) mfx(lin) test

* (3) Generalized Spatial 2SLS - AR(3) (GS2SLS)
gs2sls y x1 x2 , wmfile(SPWcs) order(3) mfx(lin) test

* (4) Generalized Spatial 2SLS - AR(4) (GS2SLS)
gs2sls y x1 x2 , wmfile(SPWcs) order(4) mfx(lin) test

* (5) Generalized Spatial GMM - AR(1) (GS2SLS)
gs2sls y x1 x2 , wmfile(SPWcs) order(1) mfx(lin) test model(gmm)

* (6) Generalized Spatial LIML - AR(4) (GS2SLS)
gs2sls y x1 x2 , wmfile(SPWcs) order(1) mfx(lin) test model(liml)

log close
