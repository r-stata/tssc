log using c:\gs3slsar.smcl , replace

clear all
sysuse gs3slsar.dta, clear

* Y1 = Y2 X1 X2
* Y2 = Y1 X3 X4

* (1) Generalized Spatial Autoregressive 3SLS - AR(1) (GS3SLSAR)
gs3slsar y1 x1 x2 , var2(y2 x3 x4) wmfile(SPWcs) eq(1) order(1) mfx(lin) test
gs3slsar y1 x1 x2 , var2(y2 x3 x4) wmfile(SPWcs) eq(2) order(1) mfx(lin) test
gs3slsar y1 x1 x2 , var2(y2 x3 x4) wmfile(SPWcs) eq(1) order(1) mfx(lin) test aux(x5)
gs3slsar y1 x1 x2 , var2(y2 x3 x4) wmfile(SPWcs) eq(1) order(1) mfx(log) test tolog

* (2) Generalized Spatial Autoregressive 3SLS - AR(2) (GS3SLSAR)
gs3slsar y1 x1 x2 , var2(y2 x3 x4) wmfile(SPWcs) eq(1) order(2) mfx(lin) test
gs3slsar y1 x1 x2 , var2(y2 x3 x4) wmfile(SPWcs) eq(2) order(2) mfx(lin) test
gs3slsar y1 x1 x2 , var2(y2 x3 x4) wmfile(SPWcs) eq(1) order(2) mfx(lin) test aux(x5)
gs3slsar y1 x1 x2 , var2(y2 x3 x4) wmfile(SPWcs) eq(1) order(2) mfx(log) test tolog

* (3) Generalized Spatial Autoregressive 3SLS - AR(3) (GS3SLSAR)
gs3slsar y1 x1 x2 , var2(y2 x3 x4) wmfile(SPWcs) eq(1) order(3) mfx(lin) test
gs3slsar y1 x1 x2 , var2(y2 x3 x4) wmfile(SPWcs) eq(2) order(3) mfx(lin) test
gs3slsar y1 x1 x2 , var2(y2 x3 x4) wmfile(SPWcs) eq(1) order(3) mfx(lin) test aux(x5)
gs3slsar y1 x1 x2 , var2(y2 x3 x4) wmfile(SPWcs) eq(1) order(3) mfx(log) test tolog

* (4) Generalized Spatial Autoregressive 3SLS - AR(4) (GS3SLSAR)
gs3slsar y1 x1 x2 , var2(y2 x3 x4) wmfile(SPWcs) eq(1) order(4) mfx(lin) test
gs3slsar y1 x1 x2 , var2(y2 x3 x4) wmfile(SPWcs) eq(2) order(4) mfx(lin) test
gs3slsar y1 x1 x2 , var2(y2 x3 x4) wmfile(SPWcs) eq(1) order(4) mfx(lin) test aux(x5)
gs3slsar y1 x1 x2 , var2(y2 x3 x4) wmfile(SPWcs) eq(1) order(4) mfx(log) test tolog

*************
* Generalized Spatial Autoregressive 3SLS (GS3SLSAR) (Cont.)
* This example is taken from Prucha data about:
* Estimation of Simultaneous Systems of Spatially Interrelated Cross Sectional Equations
* More details can be found in:
* http://econweb.umd.edu/~prucha/Research_Prog4.htm
* Results of (gs3slsar) with order(2) is identical to:
* http://econweb.umd.edu/~prucha/STATPROG/SIMEQU/PROGRAM4.log

 clear all
 sysuse gs3slsar1.dta , clear
 gs3slsar y1 x1 , var2(y2 x2) wmfile(SPWcs1) order(2)

log close
