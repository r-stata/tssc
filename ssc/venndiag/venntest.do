version 6
capture log close
capture discard
log using venndiag.log, replace
/* 
---------------------------------------------------------------------------

   Do file "venntest.do" will create simulated data and figures for 
   the updated Venn Diagram routine in "venndiag.ado"

   Author Jens M.lauritsen, Initiative for Accident Prevention
   County of Fyn, Denmark. jm.lauritsen@dadlnet.dk. For further explanation:
   
   help venndiag 

   Note: This file will create a new file called venntest.dta and
            clear memory (issue a break if you do not want this)

--------------------------------------------------------------------------

*/
set more on
more
qui {
clear
set display line 100
set log line 100
set textsize 100
* Generate 4000 artificial data points for 4 variables
set obs 4000
gen eczema = 0
gen astma  = 0
gen season = 0
gen atopi  = 0

replace eczema = 1 in 1326/1599
label data "Simulated testdata for VennDiag"

* recode data to make overlapping symptoms:
replace astma  = 1 in 1060/1399
replace astma  = . in 1100/1125
replace astma  = 1 in 100/199

replace season = 1 in 200/299
replace season = 1 in 1085/1199
replace season = 1 in 1250/1499
replace season = . in 1200/1225

replace atopi  = 1 in 300/399
replace atopi  = 1 in 1200/1499
replace atopi  = . in 1390/1415

replace atopi  = 1 in 1790/1825
replace eczema = 1 in 1800/1999
replace eczema = 1 in 1326/1599
replace eczema = 1 in 1065/1075
replace eczema = . in 1400/1425

label var  eczema "Current hand eczema"
label var  astma  "Astma previous year"
label var  season "Seasonal all. symptoms"
label var  atopi  "Childhood atopia"
label define yn 0 "No" 1 "Yes"
for var eczema-atopi: label value X yn
save venntest,replace
}

* no options at all (except saving figure):
venndiag astma season, saving(figure1)

* no options at all (except saving figure):
venndiag astma season eczema, saving(figure2)

more
venndiag astma season eczema, ellipse

more
venndiag astma season eczema, square saving(figure4)


* count on other variables:
recode ec 1=2                                                                                                                                               
recode as 1=3                                                                                                                                                
recode se 1=4                                                                 
recode at 1=5                                                                 

* Let us include all records (regarding missing as "NO") 
venndiag eczema-atopi,  saving(figure3)/*
   */ t1(Venn Diagram ) c1(2) c2(3) c3(4) c4(5)

use venntest,clear

* now increase size of texts (should be maximum 120) and specify limited information
set textsize 115
venndiag ec-as, lab(x) show(cpvx) xoff(750) yoff(15000) /*
   */   r1(Allergi related symptoms) /*
   */   r3(astma) r4(N=2948) r5(textsize 115) 

set textsize 100

more
graph using figure1 figure2 figure3 figure4
* version of venndiag used shown below:                                

which venndiag

