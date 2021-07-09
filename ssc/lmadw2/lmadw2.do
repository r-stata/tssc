log using c:\lmadw2.smcl , replace
clear all
sysuse lmadw2.dta , clear
lmadw2 y1 x1 x2 (y2 = x1 x2 x3 x4) , model(2sls) lag(4)
lmadw2 y1 x1 x2 (y2 = x1 x2 x3 x4) , model(2sls)
lmadw2 y1 x1 x2 (y2 = x1 x2 x3 x4) , model(melo)
lmadw2 y1 x1 x2 (y2 = x1 x2 x3 x4) , model(liml)
lmadw2 y1 x1 x2 (y2 = x1 x2 x3 x4) , model(fuller) kf(0.5)
lmadw2 y1 x1 x2 (y2 = x1 x2 x3 x4) , model(kclass) kc(0.5)
lmadw2 y1 x1 x2 (y2 = x1 x2 x3 x4) , model(gmm) hetcov(white)
lmadw2 y1 x1 x2 (y2 = x1 x2 x3 x4) , model(gmm) hetcov(bart)
lmadw2 y1 x1 x2 (y2 = x1 x2 x3 x4) , model(gmm) hetcov(dan)
lmadw2 y1 x1 x2 (y2 = x1 x2 x3 x4) , model(gmm) hetcov(nwest)
lmadw2 y1 x1 x2 (y2 = x1 x2 x3 x4) , model(gmm) hetcov(parzen)
lmadw2 y1 x1 x2 (y2 = x1 x2 x3 x4) , model(gmm) hetcov(quad)
lmadw2 y1 x1 x2 (y2 = x1 x2 x3 x4) , model(gmm) hetcov(tent)
lmadw2 y1 x1 x2 (y2 = x1 x2 x3 x4) , model(gmm) hetcov(trunc)
lmadw2 y1 x1 x2 (y2 = x1 x2 x3 x4) , model(gmm) hetcov(tukeym)
lmadw2 y1 x1 x2 (y2 = x1 x2 x3 x4) , model(gmm) hetcov(tukeyn)
log close
