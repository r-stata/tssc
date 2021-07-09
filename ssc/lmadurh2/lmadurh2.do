log using c:\lmadurh2.smcl , replace
clear all
sysuse lmadurh2.dta , clear
lmadurh2 y1 y11 x1 x2 (y2 = y11 x1 x2 x3 x4) , model(2sls) dlag(1)
lmadurh2 y1 x1 y11 x2 (y2 = y11 x1 x2 x3 x4) , model(2sls) dlag(2)
lmadurh2 y1 x1 x2 y11 (y2 = y11 x1 x2 x3 x4) , model(2sls) dlag(3)
lmadurh2 y1 y11 x1 x2 (y2 = y11 x1 x2 x3 x4) , model(melo)
lmadurh2 y1 y11 x1 x2 (y2 = y11 x1 x2 x3 x4) , model(liml)
lmadurh2 y1 y11 x1 x2 (y2 = y11 x1 x2 x3 x4) , model(fuller) kf(0.5)
lmadurh2 y1 y11 x1 x2 (y2 = y11 x1 x2 x3 x4) , model(kclass) kc(0.5)
lmadurh2 y1 y11 x1 x2 (y2 = y11 x1 x2 x3 x4) , model(gmm) hetcov(white)
lmadurh2 y1 y11 x1 x2 (y2 = y11 x1 x2 x3 x4) , model(gmm) hetcov(bart)
lmadurh2 y1 y11 x1 x2 (y2 = y11 x1 x2 x3 x4) , model(gmm) hetcov(dan)
lmadurh2 y1 y11 x1 x2 (y2 = y11 x1 x2 x3 x4) , model(gmm) hetcov(nwest)
lmadurh2 y1 y11 x1 x2 (y2 = y11 x1 x2 x3 x4) , model(gmm) hetcov(parzen)
lmadurh2 y1 y11 x1 x2 (y2 = y11 x1 x2 x3 x4) , model(gmm) hetcov(quad)
lmadurh2 y1 y11 x1 x2 (y2 = y11 x1 x2 x3 x4) , model(gmm) hetcov(tent)
lmadurh2 y1 y11 x1 x2 (y2 = y11 x1 x2 x3 x4) , model(gmm) hetcov(trunc)
lmadurh2 y1 y11 x1 x2 (y2 = y11 x1 x2 x3 x4) , model(gmm) hetcov(tukeym)
lmadurh2 y1 y11 x1 x2 (y2 = y11 x1 x2 x3 x4) , model(gmm) hetcov(tukeyn)
log close
