clear
set more off
capture log close
//cd "..."                                     //Change to working directory
log using "rdcont_example.smcl", replace 

********************************************************************************
//Bugni & Canay (2019) RDD Continuity test on Lee(2008)
********************************************************************************

use table_two_final.dta, clear    //Loading data
capture program drop rdcont       //Installing rdcont program


//Approximate Sign-Test | Bugni & Canay 
rdcont difdemshare if use==1
return list

log off 
