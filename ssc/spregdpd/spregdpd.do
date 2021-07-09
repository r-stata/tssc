log using c:\spregdpd.smcl , replace

clear all
sysuse spregdpd.dta, clear

* (1) (xtdhp) Han-Philips (2010) Linear Dynamic Panel Data:}
spregdpd y x1 x2 , nc(7) wmfile(SPWxt) model(sar) run(xtdhp) mfx(lin) test
spregdpd y x1 x2 , nc(7) wmfile(SPWxt) model(sar) run(xtdhp) mfx(lin) test re
spregdpd y x1 x2 , nc(7) wmfile(SPWxt) model(sar) run(xtdhp) mfx(lin) test fe
spregdpd y x1 x2 , nc(7) wmfile(SPWxt) model(sar) run(xtdhp) mfx(lin) test be

spregdpd y , nc(7) wmfile(SPWxt) model(sar) run(xtdhp) mfx(lin) test
spregdpd y , nc(7) wmfile(SPWxt) model(sar) run(xtdhp) mfx(lin) test re
spregdpd y , nc(7) wmfile(SPWxt) model(sar) run(xtdhp) mfx(lin) test fe
spregdpd y , nc(7) wmfile(SPWxt) model(sar) run(xtdhp) mfx(lin) test be

spregdpd y , nc(7) wmfile(SPWxt) model(sar) run(xtdhp) mfx(lin) test noconst
spregdpd y , nc(7) wmfile(SPWxt) model(sar) run(xtdhp) mfx(lin) test re noconst
spregdpd y , nc(7) wmfile(SPWxt) model(sar) run(xtdhp) mfx(lin) test fe noconst
spregdpd y , nc(7) wmfile(SPWxt) model(sar) run(xtdhp) mfx(lin) test be noconst

* (2) (xtdpd) Arellano-Bond (1991) Linear Dynamic Panel Data:
spregdpd y x1 x2 , nc(7) wmfile(SPWxt) model(sar) run(xtdpd) dgmmiv(x1 x2) mfx(lin) test
spregdpd y , nc(7) wmfile(SPWxt) model(sar) run(xtdpd) dgmmiv(x1 x2) mfx(lin) test
spregdpd y , nc(7) wmfile(SPWxt) model(sar) run(xtdpd) dgmmiv(x1 x2) mfx(lin) test noconst

* (3) (xtdpdsys) Arellano-Bover/Blundell-Bond (1995, 1998) System Linear Dynamic Panel Data:
spregdpd y x1 x2 , nc(7) wmfile(SPWxt) model(sar) run(xtdpdsys) mfx(lin) test
spregdpd y , nc(7) wmfile(SPWxt) model(sar) run(xtdpdsys) mfx(lin) test
spregdpd y , nc(7) wmfile(SPWxt) model(sar) run(xtdpdsys) mfx(lin) test noconst

* (4) (xtabond) Arellano-Bond Linear Dynamic Panel Data:
spregdpd y x1 x2 , nc(7) wmfile(SPWxt) model(sar) run(xtabond) inst(x1 x2) mfx(lin) test
spregdpd y x1 x2 , nc(7) wmfile(SPWxt) model(sar) run(xtabond) inst(x1 x2) pre(x1 x2) mfx(lin) test

spregdpd y , nc(7) wmfile(SPWxt) model(sar) run(xtabond) inst(x1 x2) mfx(lin) test
spregdpd y , nc(7) wmfile(SPWxt) model(sar) run(xtabond) inst(x1 x2) mfx(lin) test noconst
spregdpd y , nc(7) wmfile(SPWxt) model(sar) run(xtabond) inst(x1 x2) pre(x1 x2) mfx(lin) test
spregdpd y , nc(7) wmfile(SPWxt) model(sar) run(xtabond) inst(x1 x2) pre(x1 x2) mfx(lin) test noconst

log close
