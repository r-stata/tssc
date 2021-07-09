set more off

*mediation example with missing data

ssc install ice, replace
ssc install mim, replace

use mediation, clear

gformula sep alc bmi log_ggt sbp log_ggt_alc alc_sbp log_ggt_sbp, ///
mediation out(sbp) eq(bmi:i.sep alc, log_ggt:bmi alc, sbp:bmi alc log_ggt log_ggt_alc i.sep) /// 
com(bmi:regress, log_ggt:regress, sbp:regress) ex(alc) mediator(log_ggt) control(log_ggt:3) ///
baseline(alc:0) post_confs(bmi) base_confs(sep) derived(log_ggt_alc alc_sbp log_ggt_sbp) ///
derrules(log_ggt_alc:log_ggt*alc, alc_sbp:alc*sbp, log_ggt_sbp:log_ggt*sbp) impute(alc bmi log_ggt) ///
imp_cmd(alc:regress, bmi:regress, log_ggt:regress) imp_eq(alc:i.sep bmi log_ggt sbp log_ggt_sbp, ///
bmi:i.sep alc log_ggt sbp log_ggt_alc, log_ggt:i.sep alc bmi sbp alc_sbp) saving(gform_MCsims1) replace seed(79)

ice i.sep alc bmi log_ggt sbp log_ggt_alc alc_sbp log_ggt_sbp, cmd(alc:regress, bmi:regress, log_ggt:regress) ///
eq(alc:i.sep bmi log_ggt sbp log_ggt_sbp, bmi:i.sep alc log_ggt sbp log_ggt_alc, ///
log_ggt:i.sep alc bmi sbp alc_sbp) saving(gform_MCsims_imps) ///
passive(log_ggt_alc:log_ggt*alc \ alc_sbp:alc*sbp \ log_ggt_sbp:log_ggt*sbp) m(5) replace seed(80)

use gform_MCsims_imps, clear

xi:mim: regress sbp i.sep alc
xi:mim: regress sbp i.sep alc log_ggt bmi
   
*time-varying confounding examples

use tvc1, clear 

*comparing static regimes - no deaths or ltfu
gformula y a l a_lag l_lag cuma cuma_lag id t, out(y) com(y:logit, l:regress, a:logit) /// 
eq(y:l_lag cuma_lag, l:l_lag a_lag, a:l a_lag) id(id) t(t) var(l) intvars(a) ///
interventions(a=1 if t<10, a=0 if t<=1 \ a=1 if t>1 & t<10, a=0 if t<=3 \ a=1 if t>3 & t<10, /// 
  a=0 if t<=5 \ a=1 if t>5 & t<10, a=0 if t<=7 \ a=1 if t>7 & t<10, a=0 if t<=9) ///
pooled lag(l_lag a_lag cuma_lag) lagrules(l_lag: l 1, a_lag: a 1, cuma_lag: cuma 1) msm(stcox cuma_lag) ///
derived(cuma) derrules(cuma:cuma_lag+a) graph seed(79) saving(gform_MCsims1) replace

*comparing dynamic regimes - no deaths or ltfu
gformula y a l a_lag l_lag cuma cuma_lag id t, out(y) com(y:logit, l:regress, a:logit) /// 
eq(y:l_lag cuma_lag, l:l_lag a_lag, a:l a_lag) id(id) t(t) var(l) intvars(a) ///
interventions(a=0 if t<10 & l>6.9 \ a=1 if t<10 & l<=6.9, a=0 if t<10 & l>6.55 \ a=1 if t<10 & l<=6.55, ///
a=0 if t<10 & l>6.2 \ a=1 if t<10 & l<=6.2, a=0 if t<10 & l>5.3 \ a=1 if t<10 & l<=5.3, ///
a=0 if t<10 & l>4.6 \ a=1 if t<10 & l<=4.6) dynamic pooled lag(l_lag a_lag cuma_lag) ///
lagrules(l_lag: l 1, a_lag: a 1, cuma_lag: cuma 1) ///
derived(cuma) derrules(cuma:cuma_lag+a) graph seed(801) saving(gform_MCsims3) replace

use tvc2, clear

*comparing static regimes - with deaths and ltfu
gformula y a l a_lag l_lag d cuma cuma_lag id t, out(y) com(y:logit, l:regress, a:logit, d:logit) /// 
eq(y:l_lag cuma_lag, l:l_lag a_lag, a:l a_lag, d:l_lag cuma_lag) id(id) t(t) var(l) intvars(a) ///
interventions(a=1 if t<10, a=0 if t<=1 \ a=1 if t>1 & t<10, a=0 if t<=3 \ a=1 if t>3 & t<10, /// 
  a=0 if t<=5 \ a=1 if t>5 & t<10, a=0 if t<=7 \ a=1 if t>7 & t<10, a=0 if t<=9) ///
pooled lag(l_lag a_lag cuma_lag) lagrules(l_lag: l 1, a_lag: a 1, cuma_lag: cuma 1) msm(stcox cuma_lag) ///
derived(cuma) derrules(cuma:cuma_lag+a) death(d) graph seed(79) saving(gform_MCsims2) replace
   

  
