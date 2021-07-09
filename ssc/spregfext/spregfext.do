log using c:\spregfext.smcl , replace

clear all
sysuse spregfext.dta, clear

* (1) Spatial Panel Fixed Effects Lag Model
spregfext y x1 x2 , nc(7) wmfile(SPWxt) model(sar) mfx(lin) test
spregfext y x1 x2 , nc(7) wmfile(SPWxt) model(sar) mfx(log) test tolog

* (2) Spatial Panel Fixed Effects Durbin Model
spregfext y x1 x2 , nc(7) wmfile(SPWxt) model(sdm) mfx(lin) test
spregfext y x1 x2 , nc(7) wmfile(SPWxt) model(sdm) aux(dcs1 dcs2 dcs3) test
spregfext y x1 x2 dcs1 dcs2 dcs3 , nc(7) wmfile(SPWxt) model(sdm) mfx(lin) test

log close
