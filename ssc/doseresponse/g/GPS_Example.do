clear

use "LotteryDataSet.dta", clear
qui gen     cut = 23  if prize<=23
qui replace cut = 80  if prize>23 & prize<=80
qui replace cut = 485 if prize >80


#delimit ;
gpscore 
agew male  ownhs owncoll tixbot workthen yearw yearm1 yearm2 yearm3 yearm4 yearm5 yearm6,
t(prize) gpscore(pscore) predict(hat_treat) sigma(sd) cutpoints(cut) 
index(p50) nq_gps(5) t_transf(ln) det
;
#delimit cr
clear
exit

