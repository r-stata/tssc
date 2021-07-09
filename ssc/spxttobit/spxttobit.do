log using c:\spxttobit.smcl , replace

clear all
sysuse spxttobit.dta, clear

* Tobit Spatial Panel Autoregressive Generalized Method of Moments
spxttobit ys x1 x2 , nc(7) wmfile(SPWxt) gmm(1) mfx(lin) test ll(0)
spxttobit ys x1 x2 , nc(7) wmfile(SPWxt) gmm(1) mfx(log) test ll(0) tolog
spxttobit ys x1 x2 , nc(7) wmfile(SPWxt) gmm(1) mfx(lin) test ll(3)

spxttobit ys x1 x2 , nc(7) wmfile(SPWxt) gmm(2) mfx(lin) test ll(0)
spxttobit ys x1 x2 , nc(7) wmfile(SPWxt) gmm(2) mfx(log) test ll(0) tolog
spxttobit ys x1 x2 , nc(7) wmfile(SPWxt) gmm(2) mfx(lin) test ll(3)

spxttobit ys x1 x2 , nc(7) wmfile(SPWxt) gmm(3) mfx(lin) test ll(0)
spxttobit ys x1 x2 , nc(7) wmfile(SPWxt) gmm(3) mfx(log) test ll(0) tolog
spxttobit ys x1 x2 , nc(7) wmfile(SPWxt) gmm(3) mfx(lin) test ll(3)

log close
