********************************************************************************
*! "CUB_DO_RUN", v.14, Cerulli, 01jan2019
********************************************************************************

********************************************************************************
* READ-ME
********************************************************************************
* This DO-file runs the following Stata commands:
********************************************************************************
* "cub"           // estimates the "cub00" and "cub" models
********************************************************************************
* "pr_pred_cub"   // estimates model predicted probability for cub00
********************************************************************************
* "scattercub"    // produces the scatterplot of "Uncertainty" and "Feeling" for cub00
********************************************************************************
* "gr_prob_cub"   // produces the graph comparing the actual and the expected (or model) probabilities for cub00
********************************************************************************

*
*
*

********************************************************************************
* APPLICATION TO THE DATASET "universtata.dta"
********************************************************************************
clear all
use universtata , clear
set seed 1010
cap gen W=floor(runiform()*100) // generates simulated weights

********************************************************************************
* ESTIMATE "cub00" AND "cub" IN VARIOUS SETTINGS
********************************************************************************
* Estimates "cub00" using as outcome the variable "informat"
cub informat

* Estimates "cub00" (same results of the previous line)
cub informat  , pai() csi() vce(oim)

* Estimates "cub00" with category 2 as "shelter", 
* and assuming 9 categories (7 observed + 2 unobserved)
cub informat  , shelter(2) vce(oim) m(9) 

* Estimates "cub00" using as outcome the variable "officeho"
* and assuming 8 categories (7 observed + 1 unobserved)
cub officeho  , vce(oim) m(8)  

* Estimates "cub" using as outcome the variable "officeho",
* making "csi" function of the variable "freqserv"
* and assuming 8 categories (7 observed + 1 unobserved)
cub officeho  , csi(freqserv) vce(oim) m(8) 

* Estimates "cub00" with category 5 as "shelter", 
* and assuming 8 categories (7 observed + 1 unobserved), 
* and probability weights
cub officeho [pweight=W] , shelter(5) vce(oim) m(8) 
********************************************************************************

********************************************************************************
* CUB without "shelter"
********************************************************************************
cub informat  , pai(age diploma) csi(age) vce(oim) m(9)
********************************************************************************
* CUB with "shelter=2"
********************************************************************************
cub informat  , pai(age diploma) csi(age) vce(oim) shelter(2) m(9)
* CUB with demeaned log of "age" as covariate
gen lnage=ln(age)
egen mlnage=mean(lnage)
gen double slnage=lnage-mlnage
cub officeho  , pai() csi(slnage) vce(oim) shelter(5) m(9)
cub officeho  , pai(slnage gender) csi(slnage freqserv) vce(oim) m(9)
********************************************************************************

********************************************************************************
* SCATTERPLOT OF FEELING AND UNCERTAINTY (just for "cub00")
********************************************************************************
scattercub informat willingn officeho compete global , ///
m(9 10 12 10 12) save_graph(mygraph1) save_data(mydata1)
********************************************************************************

********************************************************************************
* PLOT OF THE ACTUAL VS. EXPECTED PROBABILITIES (just for "cub00")
********************************************************************************
gr_prob_cub informat  , prob(_PROB) save_graph(mygraph2) outname("INFORMATICA")
********************************************************************************

********************************************************************************
* GENERATE PROBABILITY PREDICTIONS (just for "cub00")
********************************************************************************
pr_pred_cub informat  , prob(_PROB)
********************************************************************************
* END
********************************************************************************
