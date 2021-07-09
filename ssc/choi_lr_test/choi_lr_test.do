log using test.log, replace
* test.log

* This program tests choi_lr_test.ado and choi_lr_testi.ado
* Ancillary files that are needed by these programs are
* nl_choi_support_interval.ado, choi_lr_support_interval.ado
* choi_lr_hypergeom.ado and choi_lr_hyperg_prog.ado.

* These programs calculate statistics described in 
* Choi et al. 2015. Elucidating the Foundations of Statistical Inference with 2 x 2 Tables. 
* PLoS ONE 10(4): e0121263. doi:10.1371/journal.pone.0121263

* Output from this program may be checked against the Shiny app posted at
* http://statcomp2.vanderbilt.edu:37212/ProfileLikelihood/ 
* or against the R program posted at
* https://cran.r-project.org/web/packages/ProfileLikelihood/index.html 

set more off
use choi_lr_testdata.dta

* Test choi_lr_test program
choi_lr_test case exposed [fweight=patients]

* Check scalars returned by the cc program
di r(p)       
di r(or)      
di r(lb_or)   
di r(ub_or)   
di r(afe)     
di r(lb_afe)  
di r(ub_afe)  
di r(afp)     
di r(chi2) 

* Check scalars calculated by the choi_lr_test program
di r(or_cond)            
di r(clr)            
di r(chi2_clr)      
di r(p_choi)        
di r(lr6pt8lsi_lb)  
di r(lr6pt8lsi_ub)  

choi_lr_test case exposed [fweight=patients], exact k(32)
* Check scalars returned by the cc program
di r(p1_exact)
di r(p_exact) 

* Check that extra LSIs are returned
di r(lrklsi_lb)     
di r(lrklsi_ub)     

choi_lr_test case exposed [fweight=patients], corn
choi_lr_test case exposed [fweight=patients], woolf

* Check behavior for tables with larger sample sizes
replace patients = patients*12  
choi_lr_test case exposed [fweight=patients], woolf k(16)

use choi_lr_testdata.dta, clear
replace patients = patients*30
choi_lr_test case exposed [fweight=patients], woolf k(32)

use choi_lr_testdata.dta, clear
replace patients = patients*100
choi_lr_test case exposed [fweight=patients], woolf k(8)

use choi_lr_testdata.dta, clear
replace patients = patients*200
choi_lr_test case exposed [fweight=patients], woolf k(8)

* Check if program handles 1 record per patient properly
use choi_lr_testdata.dta, clear
expand patients
choi_lr_test case exposed 

* Check behavior for tables with 0 patients in some cells
use choi_lr_testdata.dta,clear
list
replace patients =0 if _n==3
replace patients =0 if _n==4
choi_lr_test case exposed [fweight=patients]
replace patients =2 if _n==3
choi_lr_test case exposed [fweight=patients] , k(16)
replace patients =2 if _n==1
replace patients =0 if _n==2
replace patients =5 if _n==3
replace patients =3 if _n==4
choi_lr_test case exposed [fweight=patients] , k(16)
replace patients = patients*100
choi_lr_test case exposed [fweight=patients] , k(8)
* Test choi_lr_testi program
choi_lr_testi 6 2 3 5

* Check scalars returned by the cci program
di r(p)       
di r(or)      
di r(lb_or)   
di r(ub_or)   
di r(afe)     
di r(lb_afe)  
di r(ub_afe)  
di r(afp)     
di r(chi2) 

* Check scalars calculated and returned by the choi_lr_testi program
di r(or_cond)            
di r(clr)            
di r(chi2_clr)      
di r(p_choi)        
di r(lr6pt8lsi_lb)  
di r(lr6pt8lsi_ub)  

choi_lr_testi 6 2 3 5, exact k(8)

* Check scalars returned by the cci program
di r(p1_exact)
di r(p_exact) 

* Check that extra LSIs are returned
di r(lrklsi_lb)     
di r(lrklsi_ub)     

choi_lr_testi 6 2 3 5, corn
choi_lr_testi 6 2 3 5, woolf k(16)
choi_lr_testi 6 2 3 5, exact k(8)

* Check larger sample sizes
choi_lr_testi 72 24 36 60, k(8)
choi_lr_testi 180 60 90 150, k(16)
choi_lr_testi 600 200 300 500, woolf k(32)
choi_lr_testi 1200 400 600 1000, woolf k(32)

* Check behavior with empty cells
choi_lr_testi 0 2 3 5
choi_lr_testi 3 5 0 2, k(8)
choi_lr_testi 300 500 0 200, k(16)

log close
