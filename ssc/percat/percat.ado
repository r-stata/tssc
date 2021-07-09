*!percat version 1.0
*!Written 20Dec2014
*!Written by Mehmet Mehmetoglu
//set trace on                                                                  //locate problems
capture program drop percat
program percat
version 13.1
syntax varlist [if] [in] [, b25 bt25 t25 f25]
marksample touse                                                                //obtains the sample from [if] and [in]
gettoken def 0: 0                                                               //makes the first word typed after command def
/* median-split*/
if "`def'" != "" {                                                              //if def is not empty run the following (median) 
foreach vars of varlist `varlist' {
	qui sum `vars' if `touse', detail                                           //sum based on the marksample
	capture drop med_`vars'
	qui gen med_`vars'=. if `touse'
	qui replace med_`vars'=0 if `vars' <= `r(p50)' & `vars' !=. & `touse'       //replace based on the marksample
    qui replace med_`vars'=1 if `vars' > `r(p50)' & `vars'!=. & `touse'         //replace based on the marksample
	capture label drop labelx
	label define labelx 0 "<= p50 (0)" 1 " > p50 (1)"
	label values med_`vars' labelx 
	label variable med_`vars' "median split"
				}
			}
/* bottom 25% versus rest */ 	
if "`b25'" == "b25" {
foreach vars of varlist `varlist' {
	qui sum `vars' if `touse', detail 
	capture drop b25_`vars'
	qui gen b25_`vars'=. if `touse'
	qui replace b25_`vars'=0 if `vars' <= `r(p25)' & `vars' !=. & `touse' 
    qui replace b25_`vars'=1 if `vars' > `r(p25)' & `vars'!=. & `touse' 
	capture label drop labelx2
	label define labelx2 0 "<= p25 (0)" 1 " > p25 (1)"
	label values b25_`vars' labelx2 
	label variable b25_`vars' "bottom 25% versus rest"
				}
			}
/* bottom 25% versus top 25% */ 	
if "`bt25'" == "bt25" {
foreach vars of varlist `varlist' {
	qui sum `vars' if `touse', detail 
	capture drop bt25_`vars'
	qui gen bt25_`vars'=. if `touse'
	qui replace bt25_`vars'=0 if `vars' <= `r(p25)' & `vars' !=. & `touse' 
    qui replace bt25_`vars'=1 if `vars' > `r(p75)' & `vars'!=.  & `touse' 
	qui replace bt25_`vars'=. if `vars' > `r(p25)' & `vars' < `r(p75)' & `touse'
	capture label drop labelx3
	label define labelx3 0 "<= p25 (0)" 1 " > p75 (1)"
	label values bt25_`vars' labelx3 
	label variable bt25_`vars' "bottom 25% versus top 25%"
				}
			}
/* top 25% versus rest */ 	
if "`t25'" == "t25" {
foreach vars of varlist `varlist' {
	qui sum `vars' if `touse', detail 
	capture drop t25_`vars'
	qui gen t25_`vars'=. if `touse'
	qui replace t25_`vars'=0 if `vars' <= `r(p75)' & `vars' !=. & `touse' 
    qui replace t25_`vars'=1 if `vars' > `r(p75)' & `vars'!=. & `touse'
	capture label drop labelx4
	label define labelx4 0 "<= p75 (0)" 1 " > p75 (1)"
	label values t25_`vars' labelx4 
	label variable t25_`vars' "top 25% versus rest"
				}
			}
/* four 25% segments */
if "`f25'" == "f25" {
foreach vars of varlist `varlist' {
	qui sum `vars' if `touse', detail 
	capture drop f25_`vars'
	qui gen f25_`vars'=. if `touse'
	qui replace f25_`vars'=0 if `vars' <= `r(p25)' & `vars' !=. & `touse' 
    qui replace f25_`vars'=1 if `vars' > `r(p25)' & `vars' <=`r(p50)'  & `vars'!=. & `touse' 
	qui replace f25_`vars'=2 if `vars' > `r(p50)' & `vars' <=`r(p75)' & `vars' !=. & `touse' 
    qui replace f25_`vars'=3 if `vars' > `r(p75)' & `vars'!=. & `touse' 
	capture label drop labelx5
	label define labelx5 0"<= p25 (0)" 1" >p25 <=p50 (1)" 2" >p50 <=p75 (2)" 3" >p75 (3)"
	label values f25_`vars' labelx5 
	label variable f25_`vars' "four 25% segments"
				}
			}
	end
