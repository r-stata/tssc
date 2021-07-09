log using c:\gs3sls.smcl , replace

clear all
sysuse gs3sls.dta, clear

* Y1 = Y2 X1 X2
* Y2 = Y1 X3 X4

* (1) Generalized Spatial 3SLS - AR(1) (GS3SLS)
gs3sls y1 x1 x2 , var2(y2 x3 x4) wmfile(SPWcs) eq(1) order(1) mfx(lin) test
gs3sls y1 x1 x2 , var2(y2 x3 x4) wmfile(SPWcs) eq(2) order(1) mfx(lin) test
gs3sls y1 x1 x2 , var2(y2 x3 x4) wmfile(SPWcs) eq(1) order(1) mfx(lin) test aux(x5)
gs3sls y1 x1 x2 , var2(y2 x3 x4) wmfile(SPWcs) eq(1) order(1) mfx(log) test tolog

* (2) Generalized Spatial 3SLS - AR(2) (GS3SLS)
gs3sls y1 x1 x2 , var2(y2 x3 x4) wmfile(SPWcs) eq(1) order(2) mfx(lin) test
gs3sls y1 x1 x2 , var2(y2 x3 x4) wmfile(SPWcs) eq(2) order(2) mfx(lin) test
gs3sls y1 x1 x2 , var2(y2 x3 x4) wmfile(SPWcs) eq(1) order(2) mfx(lin) test aux(x5)
gs3sls y1 x1 x2 , var2(y2 x3 x4) wmfile(SPWcs) eq(1) order(2) mfx(log) test tolog

* (3) Generalized Spatial 3SLS - AR(3) (GS3SLS)
gs3sls y1 x1 x2 , var2(y2 x3 x4) wmfile(SPWcs) eq(1) order(3) mfx(lin) test
gs3sls y1 x1 x2 , var2(y2 x3 x4) wmfile(SPWcs) eq(2) order(3) mfx(lin) test
gs3sls y1 x1 x2 , var2(y2 x3 x4) wmfile(SPWcs) eq(1) order(3) mfx(lin) test aux(x5)
gs3sls y1 x1 x2 , var2(y2 x3 x4) wmfile(SPWcs) eq(1) order(3) mfx(log) test tolog

* (4) Generalized Spatial 3SLS - AR(4) (GS3SLS)
gs3sls y1 x1 x2 , var2(y2 x3 x4) wmfile(SPWcs) eq(1) order(4) mfx(lin) test
gs3sls y1 x1 x2 , var2(y2 x3 x4) wmfile(SPWcs) eq(2) order(4) mfx(lin) test
gs3sls y1 x1 x2 , var2(y2 x3 x4) wmfile(SPWcs) eq(1) order(4) mfx(lin) test aux(x5)
gs3sls y1 x1 x2 , var2(y2 x3 x4) wmfile(SPWcs) eq(1) order(4) mfx(log) test tolog

log close
