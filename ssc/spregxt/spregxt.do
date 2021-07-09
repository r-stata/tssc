 clear all
 log using D:\spregxt.smcl , replace
 sysuse spregxt.dta, clear
 local dum "dcs1 dcs2 dcs3 dcs4"

* (1) Spatial Panel Lag Model (SAR):
spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sar) test mfx(lin) pmfx predict(Yh) resid(Ue)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sar) test mfx(log) pmfx predict(Yh) resid(Ue) tolog
spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sar) test mfx(lin) pmfx aux(`dum')
spregxt ys x1 x2, nc(7) wmfile(SPWxt) model(sar) test mfx(lin) pmfx predict(Yh) resid(Ue) tobit ll(0)
spregxt ys x1 x2, nc(7) wmfile(SPWxt) model(sar) test mfx(lin) pmfx predict(Yh) resid(Ue) tobit ll(3)

* (2) Spatial Panel Error Model (SEM):
spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sem) test mfx(lin) predict(Yh) resid(Ue)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sem) test mfx(log) predict(Yh) resid(Ue) tolog
spregxt ys x1 x2, nc(7) wmfile(SPWxt) model(sem) test mfx(lin) predict(Yh) resid(Ue) tobit ll(0)
spregxt ys x1 x2, nc(7) wmfile(SPWxt) model(sem) test mfx(lin) predict(Yh) resid(Ue) tobit ll(3)

* (3) Spatial Panel Durbin Model (SDM):
spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sdm) test mfx(lin) pmfx predict(Yh) resid(Ue)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sdm) test mfx(log) pmfx predict(Yh) resid(Ue) tolog
spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sdm) test mfx(lin) pmfx aux(`dum')
spregxt ys x1 x2, nc(7) wmfile(SPWxt) model(sdm) test mfx(lin) pmfx predict(Yh) resid(Ue) tobit ll(0)
spregxt ys x1 x2, nc(7) wmfile(SPWxt) model(sdm) test mfx(lin) pmfx predict(Yh) resid(Ue) tobit ll(3)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sdm) aux(`dum') test mfx(lin) pmfx 
spregxt y x1 x2 dcs1-dcs5 , nc(7) wmfile(SPWxt) model(sdm) noconst

* (4) Spatial Panel AutoCorrelation Model (SAC):
spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sac) test mfx(lin) pmfx predict(Yh) resid(Ue)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sac) test mfx(log) pmfx predict(Yh) resid(Ue) tolog
spregxt ys x1 x2, nc(7) wmfile(SPWxt) model(sac) test mfx(lin) pmfx predict(Yh) resid(Ue) tobit ll(0)
spregxt ys x1 x2, nc(7) wmfile(SPWxt) model(sac) test mfx(lin) pmfx predict(Yh) resid(Ue) tobit ll(3)

* (5) (m-STAR) Multiparametric Spatio Temporal AutoRegressive Regression
*** YOU MUST HAVE DIFFERENT Weighted Matrixes Files:
*      (m-STAR) Lag Model
* (5-1) *** rum mstar in 1st nwmat
spregxt y x1 x2 , nc(7) wmfile(SPWmxt1) nwmat(1) model(mstar) mfx(lin) pmfx dist(norm) test
spregxt y x1 x2 , nc(7) wmfile(SPWmxt1) nwmat(1) model(mstar) mfx(lin) pmfx dist(exp) test
spregxt y x1 x2 , nc(7) wmfile(SPWmxt1) nwmat(1) model(mstar) mfx(lin) pmfx dist(weib) test
spregxt y x1 x2 , nc(7) wmfile(SPWmxt1) nwmat(1) model(mstar) mfx(lin) pmfx mhet(x1 x2) test
spregxt ys x1 x2, nc(7) wmfile(SPWmxt1) nwmat(1) model(mstar) mfx(lin) pmfx tobit ll(0) test

* (5-2) *** Import 1     Weight Matrix,   and rum mstar in 2nd nwmat
spregxt y x1 x2 , nc(7) wmfile(SPWmxt1) nwmat(1)
spregxt y x1 x2 , nc(7) wmfile(SPWmxt2) nwmat(2) model(mstar) mfx(lin) pmfx dist(norm) test
spregxt y x1 x2 , nc(7) wmfile(SPWmxt2) nwmat(2) model(mstar) mfx(lin) pmfx dist(exp) test
spregxt y x1 x2 , nc(7) wmfile(SPWmxt2) nwmat(2) model(mstar) mfx(lin) pmfx dist(weib) test
spregxt y x1 x2 , nc(7) wmfile(SPWmxt2) nwmat(2) model(mstar) mfx(lin) pmfx mhet(x1 x2) test
spregxt ys x1 x2, nc(7) wmfile(SPWmxt2) nwmat(2) model(mstar) mfx(lin) pmfx tobit ll(0) test

* (5-3) *** Import 1,2   Weight Matrixes, and rum mstar in 3rd nwmat
spregxt y x1 x2 , nc(7) wmfile(SPWmxt1) nwmat(1)
spregxt y x1 x2 , nc(7) wmfile(SPWmxt2) nwmat(2)
spregxt y x1 x2 , nc(7) wmfile(SPWmxt3) nwmat(3) model(mstar) mfx(lin) pmfx dist(norm) test
spregxt y x1 x2 , nc(7) wmfile(SPWmxt3) nwmat(3) model(mstar) mfx(lin) pmfx dist(exp) test
spregxt y x1 x2 , nc(7) wmfile(SPWmxt3) nwmat(3) model(mstar) mfx(lin) pmfx dist(weib) test
spregxt y x1 x2 , nc(7) wmfile(SPWmxt3) nwmat(3) model(mstar) mfx(lin) pmfx mhet(x1 x2) test
spregxt ys x1 x2, nc(7) wmfile(SPWmxt3) nwmat(3) model(mstar) mfx(lin) pmfx tobit ll(0) test

* (5-4) *** Import 1,2,3 Weight Matrixes, and rum mstar in 4th nwmat
spregxt y x1 x2 , nc(7) wmfile(SPWmxt1) nwmat(1)
spregxt y x1 x2 , nc(7) wmfile(SPWmxt2) nwmat(2)
spregxt y x1 x2 , nc(7) wmfile(SPWmxt3) nwmat(3)
spregxt y x1 x2 , nc(7) wmfile(SPWmxt4) nwmat(4) model(mstar) mfx(lin) pmfx dist(norm) test
spregxt y x1 x2 , nc(7) wmfile(SPWmxt4) nwmat(4) model(mstar) mfx(lin) pmfx dist(exp) test
spregxt y x1 x2 , nc(7) wmfile(SPWmxt4) nwmat(4) model(mstar) mfx(lin) pmfx dist(weib) test
spregxt y x1 x2 , nc(7) wmfile(SPWmxt4) nwmat(4) model(mstar) mfx(lin) pmfx mhet(x1 x2) test
spregxt ys x1 x2, nc(7) wmfile(SPWmxt4) nwmat(4) model(mstar) mfx(lin) pmfx tobit ll(0) test

* (6) (m-STAR) Multiparametric Spatio Temporal AutoRegressive Regression
*** YOU MUST HAVE DIFFERENT Weighted Matrixes Files:
*       (m-STAR) Durbin Model

* (6-1) *** rum mstar in 1st nwmat
spregxt y x1 x2 , nc(7) wmfile(SPWmxt1) nwmat(1) model(mstard) mfx(lin) pmfx dist(norm) test
spregxt y x1 x2 , nc(7) wmfile(SPWmxt1) nwmat(1) model(mstard) mfx(lin) pmfx dist(exp) test
spregxt y x1 x2 , nc(7) wmfile(SPWmxt1) nwmat(1) model(mstard) mfx(lin) pmfx dist(weib) test
spregxt y x1 x2 , nc(7) wmfile(SPWmxt1) nwmat(1) model(mstard) mfx(lin) pmfx mhet(x1 x2) test
spregxt ys x1 x2, nc(7) wmfile(SPWmxt1) nwmat(1) model(mstard) mfx(lin) pmfx tobit ll(0) test

* (6-2) *** Import 1     Weight Matrix,   and rum mstar in 2nd nwmat
spregxt y x1 x2 , nc(7) wmfile(SPWmxt1) nwmat(1)
spregxt y x1 x2 , nc(7) wmfile(SPWmxt2) nwmat(2) model(mstard) mfx(lin) pmfx dist(norm) test
spregxt y x1 x2 , nc(7) wmfile(SPWmxt2) nwmat(2) model(mstard) mfx(lin) pmfx dist(exp) test
spregxt y x1 x2 , nc(7) wmfile(SPWmxt2) nwmat(2) model(mstard) mfx(lin) pmfx dist(weib) test
spregxt y x1 x2 , nc(7) wmfile(SPWmxt2) nwmat(2) model(mstard) mfx(lin) pmfx mhet(x1) test
spregxt ys x1 x2, nc(7) wmfile(SPWmxt2) nwmat(2) model(mstard) mfx(lin) pmfx tobit ll(0) test

* (6-3) *** Import 1,2   Weight Matrixes, and rum mstar in 3rd nwmat
spregxt y x1 x2 , nc(7) wmfile(SPWmxt1) nwmat(1)
spregxt y x1 x2 , nc(7) wmfile(SPWmxt2) nwmat(2)
spregxt y x1 x2 , nc(7) wmfile(SPWmxt3) nwmat(3) model(mstard) mfx(lin) pmfx dist(norm) test
spregxt y x1 x2 , nc(7) wmfile(SPWmxt3) nwmat(3) model(mstard) mfx(lin) pmfx dist(exp) test
spregxt y x1 x2 , nc(7) wmfile(SPWmxt3) nwmat(3) model(mstard) mfx(lin) pmfx dist(weib) test
spregxt y x1 x2 , nc(7) wmfile(SPWmxt3) nwmat(3) model(mstard) mfx(lin) pmfx mhet(x1) test
spregxt ys x1 x2, nc(7) wmfile(SPWmxt3) nwmat(3) model(mstard) mfx(lin) pmfx tobit ll(0) test

* (6-4) *** Import 1,2,3 Weight Matrixes, and rum mstar in 4th nwmat
spregxt y x1 x2 , nc(7) wmfile(SPWmxt1) nwmat(1)
spregxt y x1 x2 , nc(7) wmfile(SPWmxt2) nwmat(2)
spregxt y x1 x2 , nc(7) wmfile(SPWmxt3) nwmat(3)
spregxt y x1 x2 , nc(7) wmfile(SPWmxt4) nwmat(4) model(mstard) mfx(lin) pmfx dist(norm) test
spregxt y x1 x2 , nc(7) wmfile(SPWmxt4) nwmat(4) model(mstard) mfx(lin) pmfx dist(exp) test
spregxt y x1 x2 , nc(7) wmfile(SPWmxt4) nwmat(4) model(mstard) mfx(lin) pmfx dist(weib) test
spregxt y x1 x2 , nc(7) wmfile(SPWmxt4) nwmat(4) model(mstard) mfx(lin) pmfx mhet(x1) test
spregxt ys x1 x2, nc(7) wmfile(SPWmxt4) nwmat(4) model(mstard) mfx(lin) pmfx tobit ll(0) test

* (7) Weighted Spatial Panel Models:
spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sar) test mfx(lin) pmfx wvar(x1)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sem) test mfx(lin) pmfx wvar(x1)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sdm) test mfx(lin) pmfx wvar(x1)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sac) test mfx(lin) pmfx wvar(x1)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(mstar) mfx(lin) pmfx nw(1) test wvar(x1)

* (8) Spatial Panel Exponential Regression Model
spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sar) dist(exp) test mfx(lin) pmfx
spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sem) dist(exp) test mfx(lin)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sdm) dist(exp) test mfx(lin) pmfx
spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sac) dist(exp) test mfx(lin) pmfx

* (9) Spatial Panel Weibull Regression Model
spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sar) dist(weib) test mfx(lin) pmfx
spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sem) dist(weib) test mfx(lin)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sdm) dist(weib) test mfx(lin) pmfx
spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sac) dist(weib) test mfx(lin) pmfx

* (10) Spatial Panel Tobit - Truncated Dependent Variable (ys)
spregxt ys x1 x2 , nc(7) wmfile(SPWxt) model(sar)   test mfx(lin) pmfx
spregxt ys x1 x2 , nc(7) wmfile(SPWxt) model(sem)   test mfx(lin)
spregxt ys x1 x2 , nc(7) wmfile(SPWxt) model(sdm)   test mfx(lin) pmfx
spregxt ys x1 x2 , nc(7) wmfile(SPWxt) model(sac)   test mfx(lin) pmfx
spregxt ys x1 x2 , nc(7) wmfile(SPWxt) model(sarxt) test mfx(lin) run(xttobit)
spregxt ys x1 x2 , nc(7) wmfile(SPWxt) model(sdmxt) test mfx(lin) run(xttobit)

* (11) Spatial Panel Multiplicative Heteroscedasticity
spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sar) mhet(x1 x2) test mfx(lin) pmfx
spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sdm) mhet(x1 x2) test mfx(lin) pmfx

* (12) Generalized Spatial Panel Autoregressive Models
spregxt ys x1 x2, nc(7) wmfile(SPWxt) model(spgmm) test mfx(lin) gmm(1)
spregxt ys x1 x2, nc(7) wmfile(SPWxt) model(spgmm) test mfx(lin) gmm(2)
spregxt ys x1 x2, nc(7) wmfile(SPWxt) model(spgmm) test mfx(lin) gmm(3)

* (13) Tobit Spatial Panel Autoregressive Generalized Method of Moments
spregxt ys x1 x2, nc(7) wmfile(SPWxt) model(spgmm) gmm(1) tobit ll(0) test mfx(lin)
spregxt ys x1 x2, nc(7) wmfile(SPWxt) model(spgmm) gmm(2) tobit ll(0) test mfx(lin)
spregxt ys x1 x2, nc(7) wmfile(SPWxt) model(spgmm) gmm(3) tobit ll(0) test mfx(lin)

* (14) Generalized Spatial Panel 2SLS Models
spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(gs2sls) test mfx(lin) endog(y2) inst(x3 x4)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(gs2sls) order(1) test mfx(lin)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(gs2sls) order(2) test mfx(lin)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(gs2sls) order(3) test mfx(lin)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(gs2sls) order(4) test mfx(lin)
 xtset id t

* (15) Generalized Spatial Panel Autoregressive 2SLS Models
spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(gs2slsar) test mfx(lin) endog(y2) inst(x3 x4)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(gs2slsar) order(1) test mfx(lin)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(gs2slsar) order(2) test mfx(lin)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(gs2slsar) order(3) test mfx(lin)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(gs2slsar) order(4) test mfx(lin)

* (16) Spatial Panel Random-Effets Multiplicative Heteroscedasticity
spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sarxt) run(xtmlh) mhet(x1 x2) test mfx(lin)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sdmxt) run(xtmlh) mhet(x1 x2) test mfx(lin)

* (17) Spatial Panel Lag Regression Models (SAR)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sarxt) run(ols) test mfx(lin)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sarxt) run(xtbe) test mfx(lin)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sarxt) run(xtbem) ridge(grr1) test mfx(lin)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sarxt) run(xtfe) test mfx(lin)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sarxt) run(xtfem) ridge(grr1) test mfx(lin)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sarxt) run(xtfm) test mfx(lin)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sarxt) run(xtpa) test mfx(lin)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sarxt) run(xtwem) test mfx(lin)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sarxt) run(xtmle) test mfx(lin)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sarxt) run(xtam) test mfx(lin)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sarxt) run(xtbn) test mfx(lin)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sarxt) run(xthh) test mfx(lin)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sarxt) run(xtrc) test mfx(lin)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sarxt) run(xtre) test mfx(lin)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sarxt) run(xtrem) test mfx(lin) ridge(grr1)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sarxt) run(xtsa) test mfx(lin)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sarxt) run(xtmlem) test mfx(lin)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sarxt) run(xtwh) test mfx(lin)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sarxt) run(xtgls) test mfx(lin)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sarxt) run(xtkmhomo) test mfx(lin)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sarxt) run(xtkmhet1) test mfx(lin)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sarxt) run(xtkmhet2) test mfx(lin)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sarxt) run(xtparks) test mfx(lin)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sarxt) run(xtmg) test mfx(lin)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sarxt) run(xtpcse) test mfx(lin)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sarxt) run(xtregar) test mfx(lin)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sarxt) run(xtabond) inst(x1 x2) test mfx(lin)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sarxt) run(xtdpdsys) test mfx(lin)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sarxt) run(xtdpd) dgmmiv(x1 x2) test mfx(lin)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sarxt) run(xtdhp) re test mfx(lin)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sarxt) run(xtmln) test mfx(lin)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sarxt) run(xtmlh) mhet(x1 x2) test mfx(lin)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sarxt) run(xtfrontier) ti test mfx(lin)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sarxt) run(xtfrontier) tvd test mfx(lin)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sarxt) run(xtfrontier) ti cost test mfx(lin)
spregxt ys x1 x2, nc(7) wmfile(SPWxt) model(sarxt) run(xttobit) test mfx(lin)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sarxt) run(xtmln) test mfx(lin)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sarxt) run(xtmlh) test mfx(lin) mhet(x1 x2)

* (18) Spatial Panel Lag Regression Models (SAR): Ridge 
spregxt y x1 x2 , nc(7) wmfile(SPWxt) ridge(grr1) model(sarxt) run(ols) test mfx(lin)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) ridge(grr1) model(sarxt) run(xtbem) test mfx(lin)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) ridge(grr1) model(sarxt) run(xtfem) test mfx(lin)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) ridge(grr1) model(sarxt) run(xtwem) test mfx(lin)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) ridge(grr1) model(sarxt) run(xtam) test mfx(lin)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) ridge(grr1) model(sarxt) run(xtbn) test mfx(lin)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) ridge(grr1) model(sarxt) run(xthh) test mfx(lin)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) ridge(grr1) model(sarxt) run(xtrem) test mfx(lin)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) ridge(grr1) model(sarxt) run(xtsa) test mfx(lin)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) ridge(grr1) model(sarxt) run(xtmlem) test mfx(lin)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) ridge(grr1) model(sarxt) run(xtwh) test mfx(lin)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) ridge(grr1) model(sarxt) run(xtmln) test mfx(lin)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) ridge(grr1) model(sarxt) run(xtmlh) mhet(x1 x2) test mfx(lin)

* (19) Spatial Panel Lag Regression Models (SAR): Ridge & Weighted 
spregxt y x1 x2 , nc(7) wmfile(SPWxt) ridge(grr1) weight(x) wvar(x1) model(sarxt) run(ols) test mfx(lin)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) ridge(grr1) weight(x) wvar(x1) model(sarxt) run(xtbem) test mfx(lin)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) ridge(grr1) weight(x) wvar(x1) model(sarxt) run(xtfem) test mfx(lin)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) ridge(grr1) weight(x) wvar(x1) model(sarxt) run(xtwem) test mfx(lin)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) ridge(grr1) weight(x) wvar(x1) model(sarxt) run(xtam) test mfx(lin)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) ridge(grr1) weight(x) wvar(x1) model(sarxt) run(xtbn) test mfx(lin)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) ridge(grr1) weight(x) wvar(x1) model(sarxt) run(xthh) test mfx(lin)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) ridge(grr1) weight(x) wvar(x1) model(sarxt) run(xtrem) test mfx(lin)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) ridge(grr1) weight(x) wvar(x1) model(sarxt) run(xtsa) test mfx(lin)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) ridge(grr1) weight(x) wvar(x1) model(sarxt) run(xtmlem) test mfx(lin)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) ridge(grr1) weight(x) wvar(x1) model(sarxt) run(xtwh) test mfx(lin)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) ridge(grr1) weight(x) wvar(x1) model(sarxt) run(xtmln) test mfx(lin)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) ridge(grr1) weight(x) wvar(x1) model(sarxt) run(xtmlh) test mfx(lin) mhet(x1 x2)

* (20) Spatial Panel Durbin Regression Models (SDM)
local dum "dcs1 dcs2 dcs3 dcs4"
spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sdmxt) run(ols) test mfx(lin)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sdmxt) run(xtbe) test mfx(lin)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sdmxt) run(xtbem) ridge(grr1) test mfx(lin)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sdmxt) run(xtfe) test mfx(lin)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sdmxt) run(xtfem) ridge(grr1) test mfx(lin)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sdmxt) run(xtfm) test mfx(lin)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sdmxt) run(xtpa) test mfx(lin)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sdmxt) run(xtwem) test mfx(lin)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sdmxt) run(xtmle) test mfx(lin)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sdmxt) run(xtam) test mfx(lin)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sdmxt) run(xtbn) test mfx(lin)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sdmxt) run(xthh) test mfx(lin)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sdmxt) run(xtrc) test mfx(lin)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sdmxt) run(xtre) test mfx(lin)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sdmxt) run(xtrem) test mfx(lin) ridge(grr1)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sdmxt) run(xtsa) test mfx(lin)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sdmxt) run(xtmlem) test mfx(lin)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sdmxt) run(xtwh) test mfx(lin)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sdmxt) run(xtgls) test mfx(lin)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sdmxt) run(xtkmhomo) test mfx(lin)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sdmxt) run(xtkmhet1) test mfx(lin)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sdmxt) run(xtkmhet2) test mfx(lin)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sdmxt) run(xtparks) test mfx(lin)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sdmxt) run(xtmg) test mfx(lin)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sdmxt) run(xtpcse) test mfx(lin)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sdmxt) run(xtregar) test mfx(lin)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sdmxt) run(xtabond) inst(x1 x2) test mfx(lin)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sdmxt) run(xtdpdsys) test mfx(lin)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sdmxt) run(xtdpd) dgmmiv(x1 x2) test mfx(lin)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sdmxt) run(xtdhp) re test mfx(lin)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sdmxt) run(xtmln) test mfx(lin)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sdmxt) run(xtmlh) mhet(x1 x2) test mfx(lin)
spregxt y x1 x2, nc(7) wmfile(SPWxt) model(sdmxt) run(xtfrontier) ti test mfx(lin)
spregxt y x1 x2, nc(7) wmfile(SPWxt) model(sdmxt) run(xtfrontier) tvd test mfx(lin)
spregxt y x1 x2, nc(7) wmfile(SPWxt) model(sdmxt) run(xtfrontier) ti cost test mfx(lin)
spregxt ys x1 x2, nc(7) wmfile(SPWxt) model(sdmxt) run(xttobit) test mfx(lin)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sdmxt) run(xtmln) test mfx(lin)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(sdmxt) run(xtmlh) test mfx(lin) mhet(x1 x2)

* (21) Spatial Panel Durbin Regression Models (SDM): Ridge 
spregxt y x1 x2 , nc(7) wmfile(SPWxt) ridge(grr1) model(sdmxt) run(ols) test mfx(lin)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) ridge(grr1) model(sdmxt) run(xtbem) test mfx(lin)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) ridge(grr1) model(sdmxt) run(xtfem) test mfx(lin)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) ridge(grr1) model(sdmxt) run(xtwem) test mfx(lin)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) ridge(grr1) model(sdmxt) run(xtam) test mfx(lin)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) ridge(grr1) model(sdmxt) run(xtbn) test mfx(lin)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) ridge(grr1) model(sdmxt) run(xthh) test mfx(lin)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) ridge(grr1) model(sdmxt) run(xtrem) test mfx(lin)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) ridge(grr1) model(sdmxt) run(xtsa) test mfx(lin)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) ridge(grr1) model(sdmxt) run(xtmlem) test mfx(lin)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) ridge(grr1) model(sdmxt) run(xtwh) test mfx(lin)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) ridge(grr1) model(sdmxt) run(xtmln) test mfx(lin)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) ridge(grr1) model(sdmxt) run(xtmlh) mhet(x1 x2) test mfx(lin)

* (22) Spatial Panel Durbin Regression Models (SDM): Ridge & Weighted 
spregxt y x1 x2 , nc(7) wmfile(SPWxt) ridge(grr1) weight(x) wvar(x1) model(sdmxt) run(ols) test mfx(lin)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) ridge(grr1) weight(x) wvar(x1) model(sdmxt) run(xtbem) test mfx(lin)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) ridge(grr1) weight(x) wvar(x1) model(sdmxt) run(xtfem) test mfx(lin)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) ridge(grr1) weight(x) wvar(x1) model(sdmxt) run(xtwem) test mfx(lin)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) ridge(grr1) weight(x) wvar(x1) model(sdmxt) run(xtam) test mfx(lin)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) ridge(grr1) weight(x) wvar(x1) model(sdmxt) run(xtbn) test mfx(lin)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) ridge(grr1) weight(x) wvar(x1) model(sdmxt) run(xthh) test mfx(lin)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) ridge(grr1) weight(x) wvar(x1) model(sdmxt) run(xtrem) test mfx(lin)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) ridge(grr1) weight(x) wvar(x1) model(sdmxt) run(xtsa) test mfx(lin)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) ridge(grr1) weight(x) wvar(x1) model(sdmxt) run(xtmlem) test mfx(lin)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) ridge(grr1) weight(x) wvar(x1) model(sdmxt) run(xtwh) test mfx(lin)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) ridge(grr1) weight(x) wvar(x1) model(sdmxt) run(xtmln) test mfx(lin)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) ridge(grr1) weight(x) wvar(x1) model(sdmxt) run(xtmlh) test mfx(lin) mhet(x1 x2)

* (23) Non Spatial Panel Regression Models
spregxt y x1 x2 , nc(7) model(ols) run(ols) test mfx(lin)
spregxt y x1 x2 , nc(7) model(ols) run(xtbe) test mfx(lin)
spregxt y x1 x2 , nc(7) model(ols) run(xtbem) ridge(grr1) test mfx(lin)
spregxt y x1 x2 , nc(7) model(ols) run(xtfe) test mfx(lin)
spregxt y x1 x2 , nc(7) model(ols) run(xtfem) ridge(grr1) test mfx(lin)
spregxt y x1 x2 , nc(7) model(ols) run(xtfm) test mfx(lin)
spregxt y x1 x2 , nc(7) model(ols) run(xtpa) test mfx(lin)
spregxt y x1 x2 , nc(7) model(ols) run(xtwem) test mfx(lin)
spregxt y x1 x2 , nc(7) model(ols) run(xtmle) test mfx(lin)
spregxt y x1 x2 , nc(7) model(ols) run(xtam) test mfx(lin)
spregxt y x1 x2 , nc(7) model(ols) run(xtbn) test mfx(lin)
spregxt y x1 x2 , nc(7) model(ols) run(xthh) test mfx(lin)
spregxt y x1 x2 , nc(7) model(ols) run(xtrc) test mfx(lin)
spregxt y x1 x2 , nc(7) model(ols) run(xtre) test mfx(lin)
spregxt y x1 x2 , nc(7) model(ols) run(xtrem) ridge(grr1) test mfx(lin)
spregxt y x1 x2 , nc(7) model(ols) run(xtsa) test mfx(lin)
spregxt y x1 x2 , nc(7) model(ols) run(xtmlem) test mfx(lin)
spregxt y x1 x2 , nc(7) model(ols) run(xtwh) test mfx(lin)
spregxt y x1 x2 , nc(7) model(ols) run(xtgls) test mfx(lin)
spregxt y x1 x2 , nc(7) model(ols) run(xtkmhomo) test mfx(lin)
spregxt y x1 x2 , nc(7) model(ols) run(xtkmhet1) test mfx(lin)
spregxt y x1 x2 , nc(7) model(ols) run(xtkmhet2) test mfx(lin)
spregxt y x1 x2 , nc(7) model(ols) run(xtparks) test mfx(lin)
spregxt y x1 x2 , nc(7) model(ols) run(xtmg) test mfx(lin)
spregxt y x1 x2 , nc(7) model(ols) run(xtpcse) test mfx(lin)
spregxt y x1 x2 , nc(7) model(ols) run(xtregar) test mfx(lin)
spregxt y x1 x2 , nc(7) model(ols) run(xtabond) inst(x1 x2) test mfx(lin)
spregxt y x1 x2 , nc(7) model(ols) run(xtdpdsys) test mfx(lin)
spregxt y x1 x2 , nc(7) model(ols) run(xtdpd) dgmmiv(x1 x2) test mfx(lin)
spregxt y x1 x2 , nc(7) model(ols) run(xtdhp) re test mfx(lin)
spregxt y x1 x2 , nc(7) model(ols) run(xtmln) test mfx(lin)
spregxt y x1 x2 , nc(7) model(ols) run(xtmlh) mhet(x1 x2) test mfx(lin)
spregxt y x1 x2 , nc(7) model(ols) run(xtfrontier) ti test mfx(lin)
spregxt y x1 x2 , nc(7) model(ols) run(xtfrontier) tvd test mfx(lin)
spregxt y x1 x2 , nc(7) model(ols) run(xtfrontier) ti cost test mfx(lin)
spregxt ys x1 x2, nc(7) model(ols) run(xttobit)

* (24) Non Spatial Panel Regression Models
spregxt y x1 x2 , nc(7) ridge(grr1) model(ols) run(ols) test mfx(lin)
spregxt y x1 x2 , nc(7) ridge(grr1) model(ols) run(xtbem) test mfx(lin)
spregxt y x1 x2 , nc(7) ridge(grr1) model(ols) run(xtfem) test mfx(lin)
spregxt y x1 x2 , nc(7) ridge(grr1) model(ols) run(xtwem) test mfx(lin)
spregxt y x1 x2 , nc(7) ridge(grr1) model(ols) run(xtam) test mfx(lin)
spregxt y x1 x2 , nc(7) ridge(grr1) model(ols) run(xtbn) test mfx(lin)
spregxt y x1 x2 , nc(7) ridge(grr1) model(ols) run(xthh) test mfx(lin)
spregxt y x1 x2 , nc(7) ridge(grr1) model(ols) run(xtrem) test mfx(lin)
spregxt y x1 x2 , nc(7) ridge(grr1) model(ols) run(xtsa) test mfx(lin)
spregxt y x1 x2 , nc(7) ridge(grr1) model(ols) run(xtmlem) test mfx(lin)
spregxt y x1 x2 , nc(7) ridge(grr1) model(ols) run(xtwh) test mfx(lin)
spregxt y x1 x2 , nc(7) ridge(grr1) model(ols) run(xtmln) test mfx(lin)
spregxt y x1 x2 , nc(7) ridge(grr1) model(ols) run(xtmlh) mhet(x1 x2) test mfx(lin)

* (25) Non Spatial Panel Regression Models: Ridge & Weighted 
spregxt y x1 x2 , nc(7) ridge(grr1) weight(x) wvar(x1) model(ols) run(ols) test mfx(lin)
spregxt y x1 x2 , nc(7) ridge(grr1) weight(x) wvar(x1) model(ols) run(xtbem) test mfx(lin)
spregxt y x1 x2 , nc(7) ridge(grr1) weight(x) wvar(x1) model(ols) run(xtfem) test mfx(lin)
spregxt y x1 x2 , nc(7) ridge(grr1) weight(x) wvar(x1) model(ols) run(xtwem) test mfx(lin)
spregxt y x1 x2 , nc(7) ridge(grr1) weight(x) wvar(x1) model(ols) run(xtam) test mfx(lin)
spregxt y x1 x2 , nc(7) ridge(grr1) weight(x) wvar(x1) model(ols) run(xtbn) test mfx(lin)
spregxt y x1 x2 , nc(7) ridge(grr1) weight(x) wvar(x1) model(ols) run(xthh) test mfx(lin)
spregxt y x1 x2 , nc(7) ridge(grr1) weight(x) wvar(x1) model(ols) run(xtrem) test mfx(lin)
spregxt y x1 x2 , nc(7) ridge(grr1) weight(x) wvar(x1) model(ols) run(xtsa) test mfx(lin)
spregxt y x1 x2 , nc(7) ridge(grr1) weight(x) wvar(x1) model(ols) run(xtmlem) test mfx(lin)
spregxt y x1 x2 , nc(7) ridge(grr1) weight(x) wvar(x1) model(ols) run(xtwh) test mfx(lin)
spregxt y x1 x2 , nc(7) ridge(grr1) weight(x) wvar(x1) model(ols) run(xtmln) test mfx(lin)
spregxt y x1 x2 , nc(7) ridge(grr1) weight(x) wvar(x1) model(ols) run(xtmlh) mhet(x1 x2) test mfx(lin)

* (26) Spatial Panel Lag Regression Models (SAR): Ridge 
spregxt y x1 x2 , nc(7) wmfile(SPWxt) ridge(grr1) model(sarxt) run(ols) test mfx(lin)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) ridge(grr1) model(sarxt) run(xtbem) test mfx(lin)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) ridge(grr1) model(sarxt) run(xtfem) test mfx(lin)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) ridge(grr1) model(sarxt) run(xtwem) test mfx(lin)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) ridge(grr1) model(sarxt) run(xtam) test mfx(lin)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) ridge(grr1) model(sarxt) run(xtbn) test mfx(lin)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) ridge(grr1) model(sarxt) run(xthh) test mfx(lin)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) ridge(grr1) model(sarxt) run(xtrem) test mfx(lin)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) ridge(grr1) model(sarxt) run(xtsa) test mfx(lin)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) ridge(grr1) model(sarxt) run(xtmlem) test mfx(lin)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) ridge(grr1) model(sarxt) run(xtwh) test mfx(lin)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) ridge(grr1) model(sarxt) run(xtmln) test mfx(lin)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) ridge(grr1) model(sarxt) run(xtmlh) mhet(x1 x2) test mfx(lin)

* (27) Spatial Panel Geographically Weighted Regressions (GWR)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(gwr) run(ols)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(gwr) run(xtbe)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(gwr) run(xtbem) ridge(grr1)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(gwr) run(xtfe)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(gwr) run(xtfem) ridge(grr1)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(gwr) run(xtfm)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(gwr) run(xtpa)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(gwr) run(xtwem)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(gwr) run(xtmle)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(gwr) run(xtam)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(gwr) run(xtbn)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(gwr) run(xthh)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(gwr) run(xtrc)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(gwr) run(xtre) hausman
spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(gwr) run(xtrem) hausman ridge(grr1)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(gwr) run(xtsa)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(gwr) run(xtmlem)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(gwr) run(xtwh)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(gwr) run(xtgls)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(gwr) run(xtkmhomo)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(gwr) run(xtkmhet1)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(gwr) run(xtkmhet2)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(gwr) run(xtparks)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(gwr) run(xtmg)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(gwr) run(xtpcse)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(gwr) run(xtregar)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(gwr) run(xtabond) inst(x1 x2)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(gwr) run(xtdhp) re
spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(gwr) run(xtdpd) dgmmiv(x1 x2)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(gwr) run(xtdpdsys)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(gwr) run(xtmln)
spregxt y x1 x2 , nc(7) wmfile(SPWxt) model(gwr) run(xtmlh) mhet(x1 x2)
spregxt y x1 x2, nc(7) wmfile(SPWxt) model(gwr) run(xtfrontier) ti
spregxt y x1 x2, nc(7) wmfile(SPWxt) model(gwr) run(xtfrontier) tvd
spregxt y x1 x2, nc(7) wmfile(SPWxt) model(gwr) run(xtfrontier) ti cost
spregxt ys x1 x2, nc(7) wmfile(SPWxt) model(gwr) run(xttobit)

* (28) Create Spatial Panel Weight Variables:

spregxt y x1 x2 , nc(7) model(gs2sls) wmfile(SPWxt) order(1) list
list w1y_* w1x_*

spregxt y x1 x2 , nc(7) model(gs2sls) wmfile(SPWxt) order(1) stand inv list
list w1y_* w1x_*

spregxt y x1 x2 , nc(7) model(gs2sls) wmfile(SPWxt) order(1) stand inv2 list
list w1y_* w1x_*

spregxt y x1 x2 , nc(7) model(gs2sls) wmfile(SPWxt) order(1) stand list
list w1y_* w1x_*

spregxt y x1 x2 , nc(7) model(gs2sls) wmfile(SPWxt) order(2) list
list w1y_* w1x_* w2x_*

spregxt y x1 x2 , nc(7) model(gs2sls) wmfile(SPWxt) order(2) stand list
list w1y_* w1x_* w2x_*

spregxt y x1 x2 , nc(7) model(gs2sls) wmfile(SPWxt) order(3) list
list w1y_* w1x_* w2x_* w3x_*

spregxt y x1 x2 , nc(7) model(gs2sls) wmfile(SPWxt) order(3) stand list
list w1y_* w1x_* w2x_* w3x_*

spregxt y x1 x2 , nc(7) model(gs2sls) wmfile(SPWxt) order(4) list
list w1y_* w1x_* w2x_* w3x_* w4x_*

spregxt y x1 x2 , nc(7) model(gs2sls) wmfile(SPWxt) order(4) stand list
list w1y_* w1x_* w2x_* w3x_* w4x_*

* (29) Create Panel Data Dummy Variables:
spregxt y x1 x2, nc(7) dumcs(Dum_cs)
spregxt y x1 x2, nc(7) dumts(Dum_ts)
spregxt y x1 x2, nc(7) dumcs(Dum_cs) dumts(Dum_ts)

**************************************************
*** NO Constant Option:
**************************************************
* (1) Spatial Panel Lag Model (SAR):
spregxt y x1 x2 , noconst nc(7) wmfile(SPWxt) model(sar) test mfx(lin) predict(Yh) resid(Ue)
spregxt y x1 x2 , noconst nc(7) wmfile(SPWxt) model(sar) test mfx(log) predict(Yh) resid(Ue) tolog
spregxt y x1 x2 , noconst nc(7) wmfile(SPWxt) model(sar) test mfx(lin) aux(`dum')
spregxt ys x1 x2, noconst nc(7) wmfile(SPWxt) model(sar) test mfx(lin) predict(Yh) resid(Ue) tobit ll(0)
spregxt ys x1 x2, noconst nc(7) wmfile(SPWxt) model(sar) test mfx(lin) predict(Yh) resid(Ue) tobit ll(3)

* (3) Spatial Panel Durbin Model (SDM):
spregxt y x1 x2 , noconst nc(7) wmfile(SPWxt) model(sdm) test mfx(lin) predict(Yh) resid(Ue)
spregxt y x1 x2 , noconst nc(7) wmfile(SPWxt) model(sdm) test mfx(log) predict(Yh) resid(Ue) tolog
spregxt y x1 x2 , noconst nc(7) wmfile(SPWxt) model(sdm) test mfx(lin) aux(`dum')
spregxt ys x1 x2, noconst nc(7) wmfile(SPWxt) model(sdm) test mfx(lin) predict(Yh) resid(Ue) tobit ll(0)
spregxt ys x1 x2, noconst nc(7) wmfile(SPWxt) model(sdm) test mfx(lin) predict(Yh) resid(Ue) tobit ll(3)

spregxt y x1 x2 , noconst nc(7) wmfile(SPWxt) model(sdm) aux(`dum') test mfx(lin)
spregxt y x1 x2 dcs1-dcs5 , noconst nc(7) wmfile(SPWxt) model(sdm)

* (5) (m-STAR) Multiparametric Spatio Temporal AutoRegressive Regression
*** YOU MUST HAVE DIFFERENT Weighted Matrixes:
* (5-1) *** rum mstar in 1st nwmat
spregxt y x1 x2 , noconst nc(7) wmfile(SPWmxt1) nwmat(1) model(mstar) mfx(lin) pmfx test

* (5-2) *** Import 1 Weight Matrix, and rum mstar in 2nd nwmat
spregxt y x1 x2 , noconst nc(7) wmfile(SPWmxt1) nwmat(1)
spregxt y x1 x2 , noconst nc(7) wmfile(SPWmxt2) nwmat(2) model(mstar) mfx(lin) pmfx test

* (5-3) *** Import 1,2 Weight Matrixes, and rum mstar in 3rd nwmat
spregxt y x1 x2 , noconst nc(7) wmfile(SPWmxt1) nwmat(1)
spregxt y x1 x2 , noconst nc(7) wmfile(SPWmxt2) nwmat(2)
spregxt y x1 x2 , noconst nc(7) wmfile(SPWmxt3) nwmat(3) model(mstar) mfx(lin) pmfx test

* (5-4) *** Import 1,2,3 Weight Matrixes, and rum mstar in 4th nwmat
spregxt y x1 x2 , noconst nc(7) wmfile(SPWmxt1) nwmat(1)
spregxt y x1 x2 , noconst nc(7) wmfile(SPWmxt2) nwmat(2)
spregxt y x1 x2 , noconst nc(7) wmfile(SPWmxt3) nwmat(3)
spregxt y x1 x2 , noconst nc(7) wmfile(SPWmxt4) nwmat(4) model(mstar) mfx(lin) pmfx test

* (6) Weighted Spatial Panel Models:
spregxt y x1 x2 , noconst nc(7) wmfile(SPWxt) model(sar) test mfx(lin) wvar(x1)
spregxt y x1 x2 , noconst nc(7) wmfile(SPWxt) model(sdm) test mfx(lin) wvar(x1)
spregxt y x1 x2 , noconst nc(7) wmfile(SPWxt) model(mstar) mfx(lin) pmfx nw(1) test wvar(x1)

* (7) Spatial Panel Exponential Regression Model
spregxt y x1 x2 , noconst nc(7) wmfile(SPWxt) model(sar) dist(exp) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) wmfile(SPWxt) model(sdm) dist(exp) test mfx(lin)

* (8) Spatial Panel Weibull Regression Model
spregxt y x1 x2 , noconst nc(7) wmfile(SPWxt) model(sar) dist(weib) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) wmfile(SPWxt) model(sdm) dist(weib) test mfx(lin)

* (9) Spatial Panel Tobit - Truncated Dependent Variable (ys)
spregxt ys x1 x2 , noconst nc(7) wmfile(SPWxt) model(sar)   test mfx(lin)
spregxt ys x1 x2 , noconst nc(7) wmfile(SPWxt) model(sdm)   test mfx(lin)
spregxt ys x1 x2 , noconst nc(7) wmfile(SPWxt) model(sarxt) test mfx(lin) run(xttobit)
spregxt ys x1 x2 , noconst nc(7) wmfile(SPWxt) model(sdmxt) test mfx(lin) run(xttobit)

* (10) Spatial Panel Multiplicative Heteroscedasticity
spregxt y x1 x2 , noconst nc(7) wmfile(SPWxt) model(sar) mhet(x1 x2) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) wmfile(SPWxt) model(sdm) mhet(x1 x2) test mfx(lin)

* (11) Generalized Spatial Panel Autoregressive Models
spregxt ys x1 x2, noconst nc(7) wmfile(SPWxt) model(spgmm) test mfx(lin) gmm(1)
spregxt ys x1 x2, noconst nc(7) wmfile(SPWxt) model(spgmm) test mfx(lin) gmm(2)
spregxt ys x1 x2, noconst nc(7) wmfile(SPWxt) model(spgmm) test mfx(lin) gmm(3)

* (12) Tobit Spatial Panel Autoregressive Generalized Method of Moments
spregxt ys x1 x2, noconst nc(7) wmfile(SPWxt) model(spgmm) gmm(1) tobit ll(0) test mfx(lin)
spregxt ys x1 x2, noconst nc(7) wmfile(SPWxt) model(spgmm) gmm(2) tobit ll(0) test mfx(lin)
spregxt ys x1 x2, noconst nc(7) wmfile(SPWxt) model(spgmm) gmm(3) tobit ll(0) test mfx(lin)

* (15) Spatial Panel Random-Effets Multiplicative Heteroscedasticity
spregxt y x1 x2 , noconst nc(7) wmfile(SPWxt) model(sarxt) run(xtmlh) mhet(x1 x2) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) wmfile(SPWxt) model(sdmxt) run(xtmlh) mhet(x1 x2) test mfx(lin)

* (16) Spatial Panel Lag Regression Models (SAR)
spregxt y x1 x2 , noconst nc(7) wmfile(SPWxt) model(sarxt) run(ols) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) wmfile(SPWxt) model(sarxt) run(xtbem) ridge(grr1) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) wmfile(SPWxt) model(sarxt) run(xtfem) ridge(grr1) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) wmfile(SPWxt) model(sarxt) run(xtfm) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) wmfile(SPWxt) model(sarxt) run(xtwem) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) wmfile(SPWxt) model(sarxt) run(xtam) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) wmfile(SPWxt) model(sarxt) run(xtbn) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) wmfile(SPWxt) model(sarxt) run(xthh) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) wmfile(SPWxt) model(sarxt) run(xtrc) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) wmfile(SPWxt) model(sarxt) run(xtrem) test mfx(lin) ridge(grr1)
spregxt y x1 x2 , noconst nc(7) wmfile(SPWxt) model(sarxt) run(xtsa) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) wmfile(SPWxt) model(sarxt) run(xtmlem) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) wmfile(SPWxt) model(sarxt) run(xtwh) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) wmfile(SPWxt) model(sarxt) run(xtgls) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) wmfile(SPWxt) model(sarxt) run(xtkmhomo) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) wmfile(SPWxt) model(sarxt) run(xtkmhet1) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) wmfile(SPWxt) model(sarxt) run(xtkmhet2) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) wmfile(SPWxt) model(sarxt) run(xtparks) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) wmfile(SPWxt) model(sarxt) run(xtpcse) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) wmfile(SPWxt) model(sarxt) run(xtabond) inst(x1 x2) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) wmfile(SPWxt) model(sarxt) run(xtdpdsys) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) wmfile(SPWxt) model(sarxt) run(xtdpd) dgmmiv(x1 x2) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) wmfile(SPWxt) model(sarxt) run(xtmln) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) wmfile(SPWxt) model(sarxt) run(xtmlh) mhet(x1 x2) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) wmfile(SPWxt) model(sarxt) run(xtfrontier) ti test mfx(lin)
spregxt y x1 x2 , noconst nc(7) wmfile(SPWxt) model(sarxt) run(xtfrontier) tvd test mfx(lin)
spregxt y x1 x2 , noconst nc(7) wmfile(SPWxt) model(sarxt) run(xtfrontier) ti cost test mfx(lin)
spregxt ys x1 x2, noconst nc(7) wmfile(SPWxt) model(sarxt) run(xttobit) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) wmfile(SPWxt) model(sarxt) run(xtmln) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) wmfile(SPWxt) model(sarxt) run(xtmlh) mhet(x1 x2) test mfx(lin)

* (16) Spatial Panel Lag Regression Models (SAR): Ridge
spregxt y x1 x2 , noconst nc(7) wmfile(SPWxt) ridge(grr1) model(sarxt) run(ols) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) wmfile(SPWxt) ridge(grr1) model(sarxt) run(xtbem) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) wmfile(SPWxt) ridge(grr1) model(sarxt) run(xtfem) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) wmfile(SPWxt) ridge(grr1) model(sarxt) run(xtwem) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) wmfile(SPWxt) ridge(grr1) model(sarxt) run(xtam) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) wmfile(SPWxt) ridge(grr1) model(sarxt) run(xtbn) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) wmfile(SPWxt) ridge(grr1) model(sarxt) run(xthh) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) wmfile(SPWxt) ridge(grr1) model(sarxt) run(xtrem) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) wmfile(SPWxt) ridge(grr1) model(sarxt) run(xtsa) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) wmfile(SPWxt) ridge(grr1) model(sarxt) run(xtmlem) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) wmfile(SPWxt) ridge(grr1) model(sarxt) run(xtwh) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) wmfile(SPWxt) ridge(grr1) model(sarxt) run(xtmln) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) wmfile(SPWxt) ridge(grr1) model(sarxt) run(xtmlh) mhet(x1 x2) test mfx(lin)

* (16) Spatial Panel Lag Regression Models (SAR): Ridge & Weighted 
spregxt y x1 x2 , noconst nc(7) wmfile(SPWxt) ridge(grr1) weight(x) wvar(x1) model(sarxt) run(ols) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) wmfile(SPWxt) ridge(grr1) weight(x) wvar(x1) model(sarxt) run(xtbem) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) wmfile(SPWxt) ridge(grr1) weight(x) wvar(x1) model(sarxt) run(xtfem) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) wmfile(SPWxt) ridge(grr1) weight(x) wvar(x1) model(sarxt) run(xtwem) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) wmfile(SPWxt) ridge(grr1) weight(x) wvar(x1) model(sarxt) run(xtam) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) wmfile(SPWxt) ridge(grr1) weight(x) wvar(x1) model(sarxt) run(xtbn) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) wmfile(SPWxt) ridge(grr1) weight(x) wvar(x1) model(sarxt) run(xthh) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) wmfile(SPWxt) ridge(grr1) weight(x) wvar(x1) model(sarxt) run(xtrem) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) wmfile(SPWxt) ridge(grr1) weight(x) wvar(x1) model(sarxt) run(xtsa) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) wmfile(SPWxt) ridge(grr1) weight(x) wvar(x1) model(sarxt) run(xtmlem) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) wmfile(SPWxt) ridge(grr1) weight(x) wvar(x1) model(sarxt) run(xtwh) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) wmfile(SPWxt) ridge(grr1) weight(x) wvar(x1) model(sarxt) run(xtmln) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) wmfile(SPWxt) ridge(grr1) weight(x) wvar(x1) model(sarxt) run(xtmlh) test mfx(lin) mhet(x1 x2)

* (17) Spatial Panel Durbin Regression Models (SDM)
local dum "dcs1 dcs2 dcs3 dcs4"
spregxt y x1 x2 , noconst nc(7) wmfile(SPWxt) model(sdmxt) run(ols) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) wmfile(SPWxt) model(sdmxt) run(xtbem) ridge(grr1) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) wmfile(SPWxt) model(sdmxt) run(xtfem) ridge(grr1) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) wmfile(SPWxt) model(sdmxt) run(xtfm) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) wmfile(SPWxt) model(sdmxt) run(xtwem) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) wmfile(SPWxt) model(sdmxt) run(xtam) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) wmfile(SPWxt) model(sdmxt) run(xtbn) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) wmfile(SPWxt) model(sdmxt) run(xthh) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) wmfile(SPWxt) model(sdmxt) run(xtrc) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) wmfile(SPWxt) model(sdmxt) run(xtrem) test mfx(lin) ridge(grr1)
spregxt y x1 x2 , noconst nc(7) wmfile(SPWxt) model(sdmxt) run(xtsa) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) wmfile(SPWxt) model(sdmxt) run(xtmlem) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) wmfile(SPWxt) model(sdmxt) run(xtwh) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) wmfile(SPWxt) model(sdmxt) run(xtgls) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) wmfile(SPWxt) model(sdmxt) run(xtkmhomo) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) wmfile(SPWxt) model(sdmxt) run(xtkmhet1) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) wmfile(SPWxt) model(sdmxt) run(xtkmhet2) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) wmfile(SPWxt) model(sdmxt) run(xtparks) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) wmfile(SPWxt) model(sdmxt) run(xtpcse) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) wmfile(SPWxt) model(sdmxt) run(xtabond) inst(x1 x2) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) wmfile(SPWxt) model(sdmxt) run(xtdpdsys) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) wmfile(SPWxt) model(sdmxt) run(xtdpd) dgmmiv(x1 x2) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) wmfile(SPWxt) model(sdmxt) run(xtmln) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) wmfile(SPWxt) model(sdmxt) run(xtmlh) mhet(x1 x2) test mfx(lin)
spregxt y x1 x2, noconst nc(7) wmfile(SPWxt) model(sdmxt) run(xtfrontier) ti test mfx(lin)
spregxt y x1 x2, noconst nc(7) wmfile(SPWxt) model(sdmxt) run(xtfrontier) tvd test mfx(lin)
spregxt y x1 x2, noconst nc(7) wmfile(SPWxt) model(sdmxt) run(xtfrontier) ti cost test mfx(lin)
spregxt ys x1 x2, noconst nc(7) wmfile(SPWxt) model(sdmxt) run(xttobit) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) wmfile(SPWxt) model(sdmxt) run(xtmln) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) wmfile(SPWxt) model(sdmxt) run(xtmlh) mhet(x1 x2) test mfx(lin)

* (17) Spatial Panel Durbin Regression Models (SDM): Ridge
spregxt y x1 x2 , noconst nc(7) wmfile(SPWxt) ridge(grr1) model(sdmxt) run(ols) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) wmfile(SPWxt) ridge(grr1) model(sdmxt) run(xtbem) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) wmfile(SPWxt) ridge(grr1) model(sdmxt) run(xtfem) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) wmfile(SPWxt) ridge(grr1) model(sdmxt) run(xtwem) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) wmfile(SPWxt) ridge(grr1) model(sdmxt) run(xtam) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) wmfile(SPWxt) ridge(grr1) model(sdmxt) run(xtbn) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) wmfile(SPWxt) ridge(grr1) model(sdmxt) run(xthh) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) wmfile(SPWxt) ridge(grr1) model(sdmxt) run(xtrem) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) wmfile(SPWxt) ridge(grr1) model(sdmxt) run(xtsa) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) wmfile(SPWxt) ridge(grr1) model(sdmxt) run(xtmlem) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) wmfile(SPWxt) ridge(grr1) model(sdmxt) run(xtwh) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) wmfile(SPWxt) ridge(grr1) model(sdmxt) run(xtmln) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) wmfile(SPWxt) ridge(grr1) model(sdmxt) run(xtmlh) mhet(x1 x2) test mfx(lin)

* (17) Spatial Panel Durbin Regression Models (SDM): Ridge & Weighted 
spregxt y x1 x2 , noconst nc(7) wmfile(SPWxt) ridge(grr1) weight(x) wvar(x1) model(sdmxt) run(ols) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) wmfile(SPWxt) ridge(grr1) weight(x) wvar(x1) model(sdmxt) run(xtbem) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) wmfile(SPWxt) ridge(grr1) weight(x) wvar(x1) model(sdmxt) run(xtfem) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) wmfile(SPWxt) ridge(grr1) weight(x) wvar(x1) model(sdmxt) run(xtwem) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) wmfile(SPWxt) ridge(grr1) weight(x) wvar(x1) model(sdmxt) run(xtam) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) wmfile(SPWxt) ridge(grr1) weight(x) wvar(x1) model(sdmxt) run(xtbn) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) wmfile(SPWxt) ridge(grr1) weight(x) wvar(x1) model(sdmxt) run(xthh) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) wmfile(SPWxt) ridge(grr1) weight(x) wvar(x1) model(sdmxt) run(xtrem) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) wmfile(SPWxt) ridge(grr1) weight(x) wvar(x1) model(sdmxt) run(xtsa) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) wmfile(SPWxt) ridge(grr1) weight(x) wvar(x1) model(sdmxt) run(xtmlem) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) wmfile(SPWxt) ridge(grr1) weight(x) wvar(x1) model(sdmxt) run(xtwh) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) wmfile(SPWxt) ridge(grr1) weight(x) wvar(x1) model(sdmxt) run(xtmln) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) wmfile(SPWxt) ridge(grr1) weight(x) wvar(x1) model(sdmxt) run(xtmlh) test mfx(lin) mhet(x1 x2)

* (18) Non Spatial Panel Regression Models
spregxt y x1 x2 , noconst nc(7) model(ols) run(ols) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) model(ols) run(xtbem) ridge(grr1) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) model(ols) run(xtfem) ridge(grr1) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) model(ols) run(xtfm) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) model(ols) run(xtwem) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) model(ols) run(xtam) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) model(ols) run(xtbn) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) model(ols) run(xthh) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) model(ols) run(xtrc) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) model(ols) run(xtrem) ridge(grr1) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) model(ols) run(xtsa) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) model(ols) run(xtmlem) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) model(ols) run(xtwh) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) model(ols) run(xtgls) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) model(ols) run(xtkmhomo) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) model(ols) run(xtkmhet1) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) model(ols) run(xtkmhet2) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) model(ols) run(xtparks) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) model(ols) run(xtpcse) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) model(ols) run(xtabond) inst(x1 x2) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) model(ols) run(xtdpdsys) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) model(ols) run(xtdpd) dgmmiv(x1 x2) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) model(ols) run(xtmln) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) model(ols) run(xtmlh) mhet(x1 x2) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) model(ols) run(xtfrontier) ti test mfx(lin)
spregxt y x1 x2 , noconst nc(7) model(ols) run(xtfrontier) tvd test mfx(lin)
spregxt y x1 x2 , noconst nc(7) model(ols) run(xtfrontier) ti cost test mfx(lin)
spregxt ys x1 x2, noconst nc(7) model(ols) run(xttobit) test mfx(lin)

* (18) Non Spatial Panel Regression Models: Ridge
spregxt y x1 x2 , noconst nc(7) ridge(grr1) model(ols) run(ols) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) ridge(grr1) model(ols) run(xtbem) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) ridge(grr1) model(ols) run(xtfem) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) ridge(grr1) model(ols) run(xtwem) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) ridge(grr1) model(ols) run(xtam) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) ridge(grr1) model(ols) run(xtbn) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) ridge(grr1) model(ols) run(xthh) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) ridge(grr1) model(ols) run(xtrem) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) ridge(grr1) model(ols) run(xtsa) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) ridge(grr1) model(ols) run(xtmlem) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) ridge(grr1) model(ols) run(xtwh) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) ridge(grr1) model(ols) run(xtmln) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) ridge(grr1) model(ols) run(xtmlh) mhet(x1 x2) test mfx(lin)

* (18) Non Spatial Panel Regression Models: Ridge & Weighted 
spregxt y x1 x2 , noconst nc(7) ridge(grr1) weight(x) wvar(x1) model(ols) run(ols) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) ridge(grr1) weight(x) wvar(x1) model(ols) run(xtbem) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) ridge(grr1) weight(x) wvar(x1) model(ols) run(xtfem) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) ridge(grr1) weight(x) wvar(x1) model(ols) run(xtwem) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) ridge(grr1) weight(x) wvar(x1) model(ols) run(xtam) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) ridge(grr1) weight(x) wvar(x1) model(ols) run(xtbn) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) ridge(grr1) weight(x) wvar(x1) model(ols) run(xthh) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) ridge(grr1) weight(x) wvar(x1) model(ols) run(xtrem) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) ridge(grr1) weight(x) wvar(x1) model(ols) run(xtsa) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) ridge(grr1) weight(x) wvar(x1) model(ols) run(xtmlem) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) ridge(grr1) weight(x) wvar(x1) model(ols) run(xtwh) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) ridge(grr1) weight(x) wvar(x1) model(ols) run(xtmln) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) ridge(grr1) weight(x) wvar(x1) model(ols) run(xtmlh) mhet(x1 x2) test mfx(lin)

* (18) Spatial Panel Lag Regression Models (SAR): Ridge
spregxt y x1 x2 , noconst nc(7) wmfile(SPWxt) ridge(grr1) model(sarxt) run(ols) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) wmfile(SPWxt) ridge(grr1) model(sarxt) run(xtbem) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) wmfile(SPWxt) ridge(grr1) model(sarxt) run(xtfem) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) wmfile(SPWxt) ridge(grr1) model(sarxt) run(xtwem) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) wmfile(SPWxt) ridge(grr1) model(sarxt) run(xtam) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) wmfile(SPWxt) ridge(grr1) model(sarxt) run(xtbn) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) wmfile(SPWxt) ridge(grr1) model(sarxt) run(xthh) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) wmfile(SPWxt) ridge(grr1) model(sarxt) run(xtrem) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) wmfile(SPWxt) ridge(grr1) model(sarxt) run(xtsa) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) wmfile(SPWxt) ridge(grr1) model(sarxt) run(xtmlem) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) wmfile(SPWxt) ridge(grr1) model(sarxt) run(xtwh) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) wmfile(SPWxt) ridge(grr1) model(sarxt) run(xtmln) test mfx(lin)
spregxt y x1 x2 , noconst nc(7) wmfile(SPWxt) ridge(grr1) model(sarxt) run(xtmlh) mhet(x1 x2) test mfx(lin)

* (19) Spatial Panel Autoregressive Generalized Method of Moments (Cont.)
* This example is taken from Prucha data about Spatial Panel Regression.
* More details can be found in: http://econweb.umd.edu/~prucha/Research_Prog3.htm

 clear all
 sysuse spregxt1.dta, clear
 spregxt y x1 , wmfile(SPWxt1) nc(100) model(spgmm) gmm(1) stand
 spregxt y x1 , wmfile(SPWxt1) nc(100) model(spgmm) gmm(2) stand
 spregxt y x1 , wmfile(SPWxt1) nc(100) model(spgmm) gmm(3) stand

* Results of model(spgmm) with gmm(3) option is identical to:
* http://econweb.umd.edu/~prucha/STATPROG/PANOLS/PROGRAM3(L3).log

log close
