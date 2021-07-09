*
set more off
*

use pca2_table1.dta, clear 
capture log close
log using pca2_table1.log, replace
descr
summ
*
xtabond2 d.YCAPB l.DEBT l.CAPB l.GAP    tau1994-tau2008 if year>1993&year<2009,  /*
*/ iv(tau1994-tau2008  , eq(both)   ) /*
*/ gmm(CAPB GAP DEBT, laglimits(2 .) eq(both)) h(3)
est store all_l
*
tab year if e(sample)==1

xtabond2 d.YCAPB l.DEBT l.CAPB l.GAP     tau1994-tau2008 if year>1993&year<2009,  /*
*/ iv(tau1994-tau2008   , eq(both)  ) /*
*/ gmm(CAPB GAP  DEBT, laglimits(2 3) eq(both)) h(3) 
est store lags_23 
*
tab year if e(sample)==1


xtabond2 d.YCAPB l.DEBT l.CAPB l.GAP     tau1994-tau2008 if year>1993&year<2009,  /*
*/ iv(tau1994-tau2008   , eq(both)  ) /*
*/ gmm(CAPB GAP DEBT, laglimits(2 2) eq(both)) h(3) 
est store lag_2 
*
tab year if e(sample)==1


xtabond2 d.YCAPB l.DEBT l.CAPB l.GAP     tau1994-tau2008 if year>1993&year<2009,  /*
*/ iv(tau1994-tau2008   , eq(both)  ) /*
*/ gmm(CAPB GAP DEBT, laglimits(2 .) collapse eq(both)) h(3) 
est store colla 
*
tab year if e(sample)==1

*
pca2 CAPB GAP  DEBT if year>1993&year<2009 , nt(country year) gmml(2) gmmd (1 1) retain avg 
*
xtabond2 d.YCAPB l.DEBT l.CAPB l.GAP     tau1994-tau2008 if year>1993&year<2009, ///
iv(tau1994-tau2008    , eq(both)) iv(_BM_avgscoreLEVCAPB*, eq(diff) pass) ///
iv(_BM_avgscoreLEVGAP*, eq(diff) pass) iv(_BM_avgscoreLEVDEBT*, eq(diff) pass) ///
iv(_BM_avgscoreDIFCAPB*, eq(lev) pass) iv(_BM_avgscoreDIFGAP*, eq(lev) pass) ///
 iv(_BM_avgscoreDIFDEBT*, eq(lev) pass) h(3) 
*
est store pcavg
tab year if e(sample)==1
*
drop _BM_* _GMM* 
pca2 CAPB GAP DEBT if year>1993&year<2009 , nt(country year) gmml(2 3) gmmd (1 1) avg 
*
xtabond2 d.YCAPB l.DEBT l.CAPB l.GAP     tau1994-tau2008 if year>1993&year<2009, ///
iv(tau1994-tau2008    , eq(both)) iv(_BM_avgscoreLEVCAPB*, eq(diff) pass) ///
iv(_BM_avgscoreLEVGAP*, eq(diff) pass) iv(_BM_avgscoreLEVDEBT*, eq(diff) pass) ///
iv(_BM_avgscoreDIFCAPB*, eq(lev) pass) iv(_BM_avgscoreDIFGAP*, eq(lev) pass) ///
iv(_BM_avgscoreDIFDEBT*, eq(lev) pass) h(3) 
est store pcavg23
tab year if e(sample)==1
*
drop _BM_* 
pca2 CAPB GAP DEBT if year>1993&year<2009 , nt(country year) gmml(2 3) gmmd (1 1) avg togvar     
*
xtabond2 d.YCAPB l.DEBT l.CAPB l.GAP     tau1994-tau2008 if year>1993&year<2009, ///
iv(tau1994-tau2008    , eq(both)) iv(_BM_avgscoreLEV*, eq(diff) pass) ///
iv(_BM_avgscoreDIF*, eq(lev) pass) h(3) 
est store avgtog
tab year if e(sample)==1
*




estimates table all_l lags_23 lag_2 colla pcavg pcavg23 avgtog ,                      /*
*/        keep(l.CAPB l.DEBT l.GAP     _cons )      /*
*/        stats(N N_g g_min g_avg g_max ar1p ar2p sar_df sarganp )           /*
*/ b(%6.3f) se(%6.3f) t(%6.2f) stfmt(%7.0g) style(oneline)  
*
*
log close
