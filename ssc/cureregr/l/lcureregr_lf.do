version 13
set linesize 80
set more off
cap log close
local replace `""'
log using C:\data\lcureregr_lf.log,text `replace'
capture program drop _all
mata: mata clear
do C:\ado\personal\PCM_evaluators_00.do
do C:\ado\personal\PCM_evaluators_01.do
mata:
mata mlib create lcureregr_lf, dir(PERSONAL) `replace'
mata mlib add lcureregr_lf *()
mata mlib index
mata describe using lcureregr_lf
end
log close


