clear all
log using d:\ridge2sls.smcl , replace
sysuse ridge2sls.dta , clear

* (1) Two Stages Least Squares (2SLS)
ridge2sls y1 x1 x2 (y2 = x1 x2 x3 x4) , ridge(grr1) diag mfx(lin)
ridge2sls y1 x1 x2 (y2 = x1 x2 x3 x4) , mfx(log)

* (2) Weighted Two Stages Least Squares (W2SLS)
ridge2sls y1 x1 x2 (y2 = x1 x2 x3 x4) , weights(yh)
ridge2sls y1 x1 x2 (y2 = x1 x2 x3 x4) , weights(yh2)
ridge2sls y1 x1 x2 (y2 = x1 x2 x3 x4) , weights(abse)
ridge2sls y1 x1 x2 (y2 = x1 x2 x3 x4) , weights(e2)
ridge2sls y1 x1 x2 (y2 = x1 x2 x3 x4) , weights(le2)
ridge2sls y1 x1 x2 (y2 = x1 x2 x3 x4) , weights(x) wvar(x1)
ridge2sls y1 x1 x2 (y2 = x1 x2 x3 x4) , weights(xi) wvar(x1)
ridge2sls y1 x1 x2 (y2 = x1 x2 x3 x4) , weights(x2) wvar(x1)
ridge2sls y1 x1 x2 (y2 = x1 x2 x3 x4) , weights(xi2) wvar(x1)

* (3) Ridge IV-Two Stages Least Squares (R2SLS)
ridge2sls y1 x1 x2 (y2 = x1 x2 x3 x4) , ridge(orr) kr(0.5) weights(x) wvar(x1)
ridge2sls y1 x1 x2 (y2 = x1 x2 x3 x4) , ridge(orr) kr(0.5)
ridge2sls y1 x1 x2 (y2 = x1 x2 x3 x4) , ridge(grr1)
ridge2sls y1 x1 x2 (y2 = x1 x2 x3 x4) , ridge(grr2)
ridge2sls y1 x1 x2 (y2 = x1 x2 x3 x4) , ridge(grr3)

log close

