log using c:\spregdhp.smcl , replace

clear all
sysuse spregdhp.dta, clear

* (1) Han-Philips Spatial Lag Linear Dynamic Panel Data Regression
spregdhp y x1 x2 , nc(7) model(sar) wmfile(SPWxt) mfx(lin) test
spregdhp y x1 x2 , nc(7) model(sar) wmfile(SPWxt) mfx(lin) test re
spregdhp y x1 x2 , nc(7) model(sar) wmfile(SPWxt) mfx(lin) test fe
spregdhp y x1 x2 , nc(7) model(sar) wmfile(SPWxt) mfx(lin) test be
spregdhp y x1 x2 , nc(7) model(sar) wmfile(SPWxt) mfx(log) test re tolog
spregdhp y x1 x2 , nc(7) model(sar) wmfile(SPWxt) mfx(log) test fe tolog
spregdhp y x1 x2 , nc(7) model(sar) wmfile(SPWxt) mfx(log) test be tolog
spregdhp y x1 x2 , nc(7) model(sar) wmfile(SPWxt) predict(Yh) resid(Ue)

* (2) Han-Philips Spatial Durbin Linear Dynamic Panel Data Regression
spregdhp y x1 x2 , nc(7) model(sdm) wmfile(SPWxt) mfx(lin) test
spregdhp y x1 x2 , nc(7) model(sdm) wmfile(SPWxt) mfx(lin) test re
spregdhp y x1 x2 , nc(7) model(sdm) wmfile(SPWxt) mfx(lin) test fe
spregdhp y x1 x2 , nc(7) model(sdm) wmfile(SPWxt) mfx(lin) test be
spregdhp y x1 x2 , nc(7) model(sdm) wmfile(SPWxt) mfx(log) test re tolog
spregdhp y x1 x2 , nc(7) model(sdm) wmfile(SPWxt) mfx(log) test fe tolog
spregdhp y x1 x2 , nc(7) model(sdm) wmfile(SPWxt) mfx(log) test be tolog
spregdhp y x1 x2 , nc(7) model(sdm) wmfile(SPWxt) predict(Yh) resid(Ue)

* (3) Han-Philips Spatial Lag Linear Dynamic Panel Data Regression
spregdhp y , nc(7) model(sar) wmfile(SPWxt) mfx(lin) test
spregdhp y , nc(7) model(sar) wmfile(SPWxt) mfx(lin) test re
spregdhp y , nc(7) model(sar) wmfile(SPWxt) mfx(lin) test fe
spregdhp y , nc(7) model(sar) wmfile(SPWxt) mfx(lin) test be
spregdhp y , nc(7) model(sar) wmfile(SPWxt) mfx(log) test re tolog
spregdhp y , nc(7) model(sar) wmfile(SPWxt) mfx(log) test fe tolog
spregdhp y , nc(7) model(sar) wmfile(SPWxt) mfx(log) test be tolog
spregdhp y , nc(7) model(sar) wmfile(SPWxt) predict(Yh) resid(Ue)

log close
