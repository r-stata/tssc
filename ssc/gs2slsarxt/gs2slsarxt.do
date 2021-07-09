log using c:\gs2slsarxt.smcl , replace

clear all
sysuse gs2slsarxt.dta, clear

* Generalized Spatial Panel Autoregressive Two Stage Least Squares (GS2SLSAR)
 gs2slsarxt y x1 x2, nc(7) wmfile(SPWxt) gmm(1) order(1) mfx(lin) test be
 gs2slsarxt y x1 x2, nc(7) wmfile(SPWxt) gmm(1) order(1) mfx(lin) test fe
 gs2slsarxt y x1 x2, nc(7) wmfile(SPWxt) gmm(1) order(1) mfx(lin) test re
 gs2slsarxt y x1 x2, nc(7) wmfile(SPWxt) gmm(1) order(1) mfx(log) test re tolog
 gs2slsarxt y x1 x2, nc(7) wmfile(SPWxt) gmm(1) order(1) mfx(lin) test
 gs2slsarxt y x1 x2, nc(7) wmfile(SPWxt) gmm(1) order(2) mfx(lin) test
 gs2slsarxt y x1 x2, nc(7) wmfile(SPWxt) gmm(1) order(3) mfx(lin) test
 gs2slsarxt y x1 x2, nc(7) wmfile(SPWxt) gmm(1) order(4) mfx(lin) test
 gs2slsarxt y x1 x2, nc(7) wmfile(SPWxt) gmm(2) order(1) mfx(lin) test
 gs2slsarxt y x1 x2, nc(7) wmfile(SPWxt) gmm(2) order(2) mfx(lin) test
 gs2slsarxt y x1 x2, nc(7) wmfile(SPWxt) gmm(2) order(3) mfx(lin) test
 gs2slsarxt y x1 x2, nc(7) wmfile(SPWxt) gmm(2) order(4) mfx(lin) test
 gs2slsarxt y x1 x2, nc(7) wmfile(SPWxt) gmm(3) order(1) mfx(lin) test
 gs2slsarxt y x1 x2, nc(7) wmfile(SPWxt) gmm(3) order(2) mfx(lin) test
 gs2slsarxt y x1 x2, nc(7) wmfile(SPWxt) gmm(3) order(3) mfx(lin) test
 gs2slsarxt y x1 x2, nc(7) wmfile(SPWxt) gmm(3) order(4) mfx(lin) test

log close
