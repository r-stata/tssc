log using c:\gs2slsxt.smcl , replace

clear all
sysuse gs2slsxt.dta, clear

* Generalized Spatial Panel 2SLS Models
gs2slsxt y x1 x2, nc(7) wmfile(SPWxt) order(1) mfx(lin) test
gs2slsxt y x1 x2, nc(7) wmfile(SPWxt) order(2) mfx(lin) test
gs2slsxt y x1 x2, nc(7) wmfile(SPWxt) order(3) mfx(lin) test
gs2slsxt y x1 x2, nc(7) wmfile(SPWxt) order(4) mfx(lin) test
gs2slsxt y x1 x2, nc(7) wmfile(SPWxt) order(4) mfx(log) test tolog 

log close
