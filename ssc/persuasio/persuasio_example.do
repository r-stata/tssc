******************************************************************************* 
* Stata file to provide an example for Stata module "persuasio" 
*
* Original Data Source:
* Gerber, Alan S., Dean Karlan, and Daniel Bergan. 2009. 
* "Does the Media Matter? A Field Experiment Measuring the Effect of Newspapers 
* on Voting Behavior and Political Opinions." 
* American Economic Journal: Applied Economics, 1 (2): 35-52.
*
* The dataset is available at: https://doi.org/10.3886/E113559V1
* A subset of the original dataset is prepared for this example.

* We would like to thank the authors of the original study 
* to make their data available online. 

* The number of bootstrap replications is set at nboot(100).
* This is for illustrational purposes only.
* It is recommended to set it with a larger number of bootstrap replications.
******************************************************************************* 

clear
cap log close
set more off
	
log using "persuasio_example", replace	
*************************************
**** Examples for persuasio.ado *****
*************************************

* Data summary

use GKB_persuasio, clear
by post, sort: tab voteddem_all readsome

*************************************
**** Examples without Covariates ****
*************************************

* The first example conducts inference on APR when y,t,z are observed.

persuasio apr voteddem_all readsome post, level(80) method("normal")

set seed 339487731
persuasio apr voteddem_all readsome post, ///
	level(80) method("bootstrap") nboot(100)
	
* The second example conducts inference on LPR when y,t,z are observed.
		
persuasio lpr voteddem_all readsome post, level(80) method("normal") 

* The third example conducts inference on APR and LPR when y,z are observed only. 		

persuasio yz voteddem_all post, level(80) method("normal")

* The fourth example considers the case when we have summary statistics on Pr(y=1|z) and/or Pr(t=1|z).

foreach var in voteddem_all readsome { 
	foreach treat in 0 1 {
		qui sum `var' if post == `treat'
		scalar `var'_`treat' = r(mean)
	}
}
persuasio calc voteddem_all_1 voteddem_all_0 readsome_1 readsome_0

persuasio calc voteddem_all_1 voteddem_all_0


*************************************
**** Examples with Covariates    ****
*************************************

* The first example conducts inference on APR when y,t,z are observed along with x.

persuasio apr voteddem_all readsome post MZwave2

set seed 339487731
qui persuasio apr voteddem_all readsome post MZwave2, ///
	level(80) method("bootstrap") nboot(100)
* display estimation results
mat list e(apr_est)	
mat list e(apr_ci)	
qui persuasio apr voteddem_all readsome post MZwave2, ///
	level(80) model("interaction") method("bootstrap") nboot(100)
* display estimation results
mat list e(apr_est)	
mat list e(apr_ci)		

* The second example conducts inference on APR and LPR when y,z are observed with a covariate, MZwave2. 		

persuasio lpr voteddem_all readsome post MZwave2, level(80) 
set seed 339487731	
qui persuasio lpr voteddem_all readsome post MZwave2, ///
	level(80) model("interaction") method("bootstrap") nboot(100)
* display estimation results
mat list e(lpr_est)	
mat list e(lpr_ci)			

log close
	
exit
		  
