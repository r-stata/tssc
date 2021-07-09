clear

use LotteryDataSet.dta, clear
qui gen     cut = 23  if prize<=23
qui replace cut = 80  if prize>23 & prize<=80
qui replace cut = 485 if prize >80

mat def tp = (10\20\30\40\50\60\70\80\90\100)

#delimit ;
doseresponse agew ownhs male tixbot owncoll workthen yearw  yearm1 yearm2 yearm3 yearm4 yearm5 yearm6,
outcome(year6) t(prize) gpscore(pscore) predict(hat_treat) sigma(sd) cutpoints(cut) 
index(p50) nq_gps(5)  t_transf(ln)  dose_response(dose_response)  
tpoints(tp) delta(1)  reg_type_t(quadratic) reg_type_gps(quadratic)  interaction(1)
bootstrap(yes) boot_reps(100)  filename("output")  analysis(yes) graph("graph_output") det
;


#delimit cr
clear
