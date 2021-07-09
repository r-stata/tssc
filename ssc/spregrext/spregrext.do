log using c:\spregrext.smcl , replace

clear all
sysuse spregrext.dta, clear

* (1) Spatial Panel Random Effects Lag Model
spregrext y x1 x2 , nc(7) wmfile(SPWxt) model(sar) mfx(lin) test
spregrext y x1 x2 , nc(7) wmfile(SPWxt) model(sar) mfx(log) test tolog

* (2) Spatial Panel Random Effects Durbin Model
spregrext y x1 x2 , nc(7) wmfile(SPWxt) model(sdm) mfx(lin) test
spregrext y x1 x2 , nc(7) wmfile(SPWxt) model(sdm) aux(dcs1 dcs2 dcs3) test
spregrext y x1 x2 dcs1 dcs2 dcs3 , nc(7) wmfile(SPWxt) model(sdm) mfx(lin) test

log close
