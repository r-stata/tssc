log using D:\spreghetxt.smcl , replace

clear all
sysuse spreghetxt.dta, clear

* (1) Panel MLE - RE Spatial Lag Model
spreghetxt y x1 x2, nc(7) wmfile(SPWxt) model(sar) run(mlen) mfx(lin) test
spreghetxt y x1 x2, nc(7) wmfile(SPWxt) model(sar) run(mlen) mfx(log) test tolog

* (2) Panel MLE - RE Spatial Durbin Model
spreghetxt y x1 x2, nc(7) wmfile(SPWxt) model(sdm) run(mlen) mfx(lin) test
spreghetxt y x1 x2, nc(7) wmfile(SPWxt) model(sdm) run(mlen) aux(dcs1 dcs2 dcs3)
spreghetxt y x1 x2 dcs1 dcs2 dcs3, nc(7) wmfile(SPWxt) model(sdm) run(mlen) mfx(lin) test

* (3) Panel MLE - RE Spatial Lag Model - Multiplicative Heteroscedasticity
spreghetxt y x1 x2, nc(7) wmfile(SPWxt) model(sar) run(mleh) mfx(lin) test mhet(x1 x2)

* (4) Panel MLE - RE Spatial Durbin Model - Multiplicative Heteroscedasticity
spreghetxt y x1 x2, nc(7) wmfile(SPWxt) model(sdm) run(mleh) mfx(lin) test mhet(x1 x2)
spreghetxt y x1 x2, nc(7) wmfile(SPWxt) model(sdm) run(mleh) mhet(x1 x2) aux(dcs1 dcs2) test
spreghetxt y x1 x2 dcs1 dcs2, nc(7) wmfile(SPWxt) model(sdm) run(mleh) mfx(lin) test mhet(x1 x2)

log close

