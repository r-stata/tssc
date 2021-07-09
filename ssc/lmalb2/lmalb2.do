log using c:\lmalb2.smcl , replace
clear all
sysuse lmalb2.dta , clear
lmalb2 y1 x1 x2 (y2 = x1 x2 x3 x4) , model(2sls) lag(4)
lmalb2 y1 x1 x2 (y2 = x1 x2 x3 x4) , model(2sls)
lmalb2 y1 x1 x2 (y2 = x1 x2 x3 x4) , model(melo)
lmalb2 y1 x1 x2 (y2 = x1 x2 x3 x4) , model(liml)
lmalb2 y1 x1 x2 (y2 = x1 x2 x3 x4) , model(fuller) kf(0.5)
lmalb2 y1 x1 x2 (y2 = x1 x2 x3 x4) , model(kclass) kc(0.5)
lmalb2 y1 x1 x2 (y2 = x1 x2 x3 x4) , model(gmm) hetcov(white)
lmalb2 y1 x1 x2 (y2 = x1 x2 x3 x4) , model(gmm) hetcov(bart)
lmalb2 y1 x1 x2 (y2 = x1 x2 x3 x4) , model(gmm) hetcov(dan)
lmalb2 y1 x1 x2 (y2 = x1 x2 x3 x4) , model(gmm) hetcov(nwest)
lmalb2 y1 x1 x2 (y2 = x1 x2 x3 x4) , model(gmm) hetcov(parzen)
lmalb2 y1 x1 x2 (y2 = x1 x2 x3 x4) , model(gmm) hetcov(quad)
lmalb2 y1 x1 x2 (y2 = x1 x2 x3 x4) , model(gmm) hetcov(tent)
lmalb2 y1 x1 x2 (y2 = x1 x2 x3 x4) , model(gmm) hetcov(trunc)
lmalb2 y1 x1 x2 (y2 = x1 x2 x3 x4) , model(gmm) hetcov(tukeym)
lmalb2 y1 x1 x2 (y2 = x1 x2 x3 x4) , model(gmm) hetcov(tukeyn)
log close
