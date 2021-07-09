clear all
log using c:\alsmle.smcl , replace
sysuse alsmle.dta, clear
alsmle y x1 x2
alsmle y x1 x2 , iter(1)
alsmle y x1 x2 , twostep
alsmle y x1 x2 , iter(10)
alsmle y x1 x2 , noconstant
alsmle y x1 x2 , mfx(lin) log
alsmle y x1 x2 [weight=x1]
alsmle y x1 x2 [aweight=x1]
alsmle y x1 x2 [iweight=x1]
alsmle y x1 x2 [pweight=x1]
alsmle y x1 x2 in 2/16 [weight=x1] , noconstant
alsmle y x1 x2 , mfx(lin) diag predict(Yh) resid(Ue)
alsmle y x1 x2 , mfx(log) diag predict(Yh) resid(Ue) tolog
alsmle y x1 x2 , mfx(log) log tolog
log close
