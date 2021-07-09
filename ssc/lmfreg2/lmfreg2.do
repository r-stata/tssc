log using c:\lmfreg2.smcl , replace
clear all
sysuse lmfreg2.dta , clear
lmfreg2 y1 x1 x2 (y2 = x1 x2 x3 x4) , model(2sls)
lmfreg2 y1 x1 x2 (y2 = x1 x2 x3 x4) , model(melo)
lmfreg2 y1 x1 x2 (y2 = x1 x2 x3 x4) , model(liml)
lmfreg2 y1 x1 x2 (y2 = x1 x2 x3 x4) , model(fuller) kf(0.5)
lmfreg2 y1 x1 x2 (y2 = x1 x2 x3 x4) , model(kclass) kc(0.5)
lmfreg2 y1 x1 x2 (y2 = x1 x2 x3 x4) , model(gmm) hetcov(white)
lmfreg2 y1 x1 x2 (y2 = x1 x2 x3 x4) , model(gmm) hetcov(bart)
lmfreg2 y1 x1 x2 (y2 = x1 x2 x3 x4) , model(gmm) hetcov(dan)
lmfreg2 y1 x1 x2 (y2 = x1 x2 x3 x4) , model(gmm) hetcov(nwest)
lmfreg2 y1 x1 x2 (y2 = x1 x2 x3 x4) , model(gmm) hetcov(parzen)
lmfreg2 y1 x1 x2 (y2 = x1 x2 x3 x4) , model(gmm) hetcov(quad)
lmfreg2 y1 x1 x2 (y2 = x1 x2 x3 x4) , model(gmm) hetcov(tent)
lmfreg2 y1 x1 x2 (y2 = x1 x2 x3 x4) , model(gmm) hetcov(trunc)
lmfreg2 y1 x1 x2 (y2 = x1 x2 x3 x4) , model(gmm) hetcov(tukeym)
lmfreg2 y1 x1 x2 (y2 = x1 x2 x3 x4) , model(gmm) hetcov(tukeyn)
log close
