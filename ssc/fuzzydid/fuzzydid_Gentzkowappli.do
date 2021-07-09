clear all

*sysdir set PERSONAL "C:\Users\Clement\Dropbox\Fuzzy DID package\fuzzydid_package_modifs_pour_revision"
*sysdir set PLUS "C:\Users\Clement\Dropbox\Fuzzy DID package\fuzzydid_package_modifs_pour_revision"

*use "C:\Users\Clement\Dropbox\Fuzzy DID package\fuzzydid_package_modifs_pour_revision\turnout_dailies_1868-1928.dta", clear
use "C:\Users\Clement\Dropbox\Fuzzy DID package\fuzzydid_package_modifs_pour_revision\turnout_dailies_1868-1928.dta", clear

set more off
set seed 1
set linesize 80
capture log close
sjlog using "C:\Users\Clement\Dropbox\Fuzzy DID package\fuzzydid_package_modifs_pour_revision\Gentzkow\GentzkowSJ0", replace
use "C:\Users\Clement\Dropbox\Fuzzy DID package\fuzzydid_package_modifs_pour_revision\turnout_dailies_1868-1928.dta", clear
sum pres_turnout numdailies
sjlog close, replace

set more off
set seed 1
set linesize 80
capture log close
sjlog using "C:\Users\Clement\Dropbox\Fuzzy DID package\fuzzydid_package_modifs_pour_revision\Gentzkow\GentzkowSJ1", replace 
gen G1872=(fd_numdailies>0) if (year==1872)&fd_numdailies!=.&fd_numdailies>=0&sample==1
sort cnty90 year
replace G1872=G1872[_n+1] if cnty90==cnty90[_n+1]&year==1868
timer on 1
fuzzydid pres_turnout G1872 year numdailies, did tc cic newcateg(0 1 2 45) breps(200) cluster(cnty90)
timer off 1
timer list 1
timer clear
sjlog close, replace

gen numdailies_bin=(numdailies>0)
set more off
set seed 1
set linesize 80
capture log close
sjlog using "C:\Users\Clement\Dropbox\Fuzzy DID package\fuzzydid_package_modifs_pour_revision\Gentzkow\GentzkowSJ2", replace
timer on 1
fuzzydid pres_turnout G1872 year numdailies_bin, lqte breps(200) cluster(cnty90)
timer off 1
timer list 1
timer clear
sjlog close, replace

set more off
set seed 1
set linesize 80
capture log close
sjlog using "C:\Users\Clement\Dropbox\Fuzzy DID package\fuzzydid_package_modifs_pour_revision\Gentzkow\GentzkowSJ3", replace
sort cnty90 year
by cnty90 year: egen mean_D = mean(numdailies)
by cnty90: g lag_mean_D = mean_D[_n-1] if cnty90==cnty90[_n-1]&year-4==year[_n-1]
g G_T = sign(mean_D - lag_mean_D) if sample==1
g G_Tplus1 = G_T[_n+1] if cnty90==cnty90[_n+1]&year+4==year[_n+1]
timer on 1
fuzzydid pres_turnout G_T G_Tplus1 year numdailies, did tc cic newcateg(0 1 2 45) breps(200) cluster(cnty90) eqtest
timer off 1
timer list 1
timer clear
sjlog close, replace

set more off
set seed 1
set linesize 80
capture log close
sjlog using "C:\Users\Clement\Dropbox\Fuzzy DID package\fuzzydid_package_modifs_pour_revision\Gentzkow\GentzkowSJ4", replace
timer on 1
fuzzydid pres_turnout G_T G_Tplus1 year numdailies, did tc newcateg(0 1 2 45) qualitative(st1-st48) breps(200) cluster(cnty90) eqtest
timer off 1
timer list 1
timer clear
sjlog close, replace

set more off
set seed 1
set linesize 80
capture log close
sjlog using "C:\Users\Clement\Dropbox\Fuzzy DID package\fuzzydid_package_modifs_pour_revision\Gentzkow\GentzkowSJ5", replace
xtset cnty90 year
gen fd_numdailies_l1=l4.fd_numdailies
gen pres_turnout_l1=l4.pres_turnout
sort cnty90 year
g G_T_placebo = sign(mean_D - lag_mean_D) if sample==1&fd_numdailies_l1==0
g G_Tplus1_placebo = G_T_placebo[_n+1] if cnty90==cnty90[_n+1]&year+4==year[_n+1]
timer on 1
fuzzydid pres_turnout_l1 G_T_placebo G_Tplus1_placebo year numdailies, did tc newcateg(0 1 2 45) qualitative(st1-st48) breps(200) cluster(cnty90)
timer off 1
timer list 1
timer clear
sjlog close, replace





