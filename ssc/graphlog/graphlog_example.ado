********************************************************************************
*** Example for graphlog 1.5 ***************************************************
********************************************************************************

program	graphlog_example
	version 12.1
	
disp ". preserve"
preserve
disp ". capture log close"
capture log close
disp ". log using examplelog.log, replace"
log using examplelog.log, replace
disp ". sysuse auto, clear"
sysuse auto, clear
disp ". summarize length"
summarize length
disp ". scatter trunk length"
scatter trunk length
disp ". pwd"
pwd
disp ". graph export examplegraph.pdf, replace"
graph export examplegraph.pdf, replace
disp ". log close"
log close
disp ". graphlog using examplelog.log, linespacing(1) replace"
graphlog using examplelog.log, linespacing(1) replace
disp ". restore"
restore
end
