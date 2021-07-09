** DO FILE: Applied Analyses of Model Robustness
** Created by: Cristobal Young, March 10, 2014
**     this version: May 29, 2015

clear
clear matrix

set more off

******************************
******************************

** Application 1: Union Wage Premium

******************************
******************************


sysuse nlsw88, clear 

gen log_wage = log(wage)

** scaling the outcome to change the decimal place of the coefficients. 
replace log_wage = log_wage*100

reg log_wage union hours age grade collgrad married south smsa c_city ttl_exp tenure 

mrobust reg log_wage union hours age grade collgrad married south smsa c_city ttl_exp tenure, pref(11.10936   2.199607  ) saveas(union) replace
** using the estimate and standard error from the previous regression


******************************
******************************

**Application 2: Effect of Gender on Mortgage Lending

******************************
******************************


webuse set http://web.stanford.edu/~cy10/public/mrobust/

webuse mortgage.dta, clear

gen accept_scaled = accept*100

reg accept_scaled female black housing_expense_ratio self_employed married bad_history PI_ratio loan_to_value denied_PMI

mrobust reg accept_scaled female black housing_expense_ratio self_employed married bad_history PI_ratio loan_to_value denied_PMI, pref( 3.698935   1.601053  ) saveas(female_OLS) replace


******************************
******************************

** Addtional Results (mentioned but not reported in article)

******************************
******************************

** Variables "Black" and "Married" always included
mrobust reg accept_scaled (female black married) housing_expense_ratio self_employed bad_history PI_ratio loan_to_value denied_PMI, pref( 3.698935   1.601053 )

** Variables "Black" and "Married" excluded
mrobust reg accept_scaled female housing_expense_ratio self_employed bad_history PI_ratio loan_to_value denied_PMI, pref( 3.698935   1.601053 )

** Code to create "Figure 3. Modeling Distributions for the Gender Effect under Different Assumptions"
** retrieve the dataset of coefficients, stored from the inital mrobust run. 
use female_OLS, clear
sum sig pos

gen condition=0 if r_black==0 & r_married==0
replace condition=1 if r_black==1 & r_married==1
*gen b_intvar_100 = b_intvar*100

sum b_intvar if condition==0
sum b_intvar if condition==1

kdensity b_intvar if condition==0
kdensity b_intvar if condition==1

** graph for two distributions:
kdensity b_intvar if (condition==0), plot(kdensity b_intvar if (condition==1)) note("") title("") xtitle("Estimated Coefficients") xline(.0494131, lcolor(gs12) lpattern(shortdash)) xline(4.427974, lcolor(gs12) lpattern(shortdash)) text(1.3 -1 "Race and Married" "controls excluded", place(e)) text(1.15 3 "Race and Married" "controls always included", place(e)) legend(off)


******************************
******************************

**Application 3: Tax-Migration

******************************
******************************

** This application is more computationally demanding. 
**		The following code takes roughly one hour to 
**			run on a desktop computer.
**
**      Un-comment the code to run. 

/*
webuse set http://web.stanford.edu/~cy10/public/mrobust/

webuse migration.dta, clear

**Table 6

poisson TF_count log_ACS_pop_i log_ACS_pop_j all_trate100_ij log_distance_ij contiguous, vce(robust) 

poisson all_mig_count log_allpop_i log_allpop_j log_distance_ij contiguous all_trate100_ij state_sales_ij prop_tax_ij meaninc_ij topog_ij, vce(robust)

poisson TF_count log_ACS_pop_i log_ACS_pop_j log_distance_ij contiguous all_trate100_ij state_sales_ij prop_tax_ij meaninc_ij topog_ij, vce(robust)

** robustness testing for all population:

** Poisson
mrobust poisson all_mig_count (all_trate100_ij log_allpop_i log_allpop_j) log_distance_ij contiguous  wint_temp_ij sun_ij temp_dif_ij humid_ij topog_ij water_ij state_sales_ij prop_tax_ij unemp_ij meaninc_ij , vce(robust) saveas(mig1) replace

mrobust poisson TF_count (all_trate100_ij log_ACS_pop_i log_ACS_pop_j) log_distance_ij contiguous  wint_temp_ij sun_ij temp_dif_ij humid_ij topog_ij water_ij state_sales_ij prop_tax_ij unemp_ij meaninc_ij , vce(robust)  saveas(mig2) replace

** NBreg
mrobust nbreg all_mig_count (all_trate100_ij log_allpop_i log_allpop_j) log_distance_ij contiguous  wint_temp_ij sun_ij temp_dif_ij humid_ij topog_ij water_ij state_sales_ij prop_tax_ij unemp_ij meaninc_ij , vce(robust) saveas(mig3) replace

mrobust nbreg TF_count (all_trate100_ij log_ACS_pop_i log_ACS_pop_j) log_distance_ij contiguous  wint_temp_ij sun_ij temp_dif_ij humid_ij topog_ij water_ij state_sales_ij prop_tax_ij unemp_ij meaninc_ij , vce(robust) saveas(mig4) replace

** OLS
mrobust reg log_all_mig_count (all_trate100_ij log_allpop_i log_allpop_j) log_distance_ij contiguous  wint_temp_ij sun_ij temp_dif_ij humid_ij topog_ij water_ij state_sales_ij prop_tax_ij unemp_ij meaninc_ij , vce(robust) saveas(mig5) replace

mrobust reg log_ACS_count (all_trate100_ij log_ACS_pop_i log_ACS_pop_j) log_distance_ij contiguous  wint_temp_ij sun_ij temp_dif_ij humid_ij topog_ij water_ij state_sales_ij prop_tax_ij unemp_ij meaninc_ij , vce(robust) saveas(mig6) replace

**  Pool robustness results together:

use mig1.dta, clear

append using mig2.dta
append using mig3.dta
append using mig4.dta
append using mig5.dta
append using mig6.dta

encode model, generate(model1)

gen model_code = 1 if model1==3 /* reg */ 
replace model_code = 2 if model1==2 /* poisson */ 
replace model_code = 3 if model1==1 /* nbreg */ 
label define model_code 1 "OLS" 2 "poisson" 3 "nbreg", replace
tab model1 model_code

recode __log_all_mig_count  .=0
recode __all_mig_count  .=0
gen irs = 1 if __log_all_mig_count ==1 | __all_mig_count ==1
replace irs = 0 if irs==.

** ACS is reference category
gen acs=1 if irs==0
replace acs = 0 if acs==.

tab sig
tab pos
tab sig pos

gen b_intvar_100 = b_intvar*100
gen se_100 = se*100

reg b_intvar_100 r_* irs i.model_code

sum b_intvar_100 
** std dev of b_intvar_100 is the modeling standard error
sum se_100
** mean of se_100 is sampling standard error

** Total SE:
di  sqrt(.8297168^2 +  1.09514 ^2)

kdensity b_intvar_100, title("Distribution of Tax Migration Estimates") xline(2.42, lcolor(gs12) lpattern(shortdash)) xtitle("Tax Migration Estimates") note("") saving(migration_graph, replace)

** poisson with IRS gives almost all the positive coeffs: 

tab pos sig if irs==1 & model_code==1
di 56/4096
** still only 1.4% sig

*/



******************************
******************************
*Appendix A: Supplementary results for Functional Form Robustness
******************************
******************************


/*

webuse mortgage.dta, clear

gen accept_scaled = accept*100

mrobust (reg | reg(vce(robust)) | logit | logit(vce(robust)) | probit | probit(vce(robust)) ) accept female black housing_expense_ratio self_employed married bad_history PI_ratio loan_to_value denied_PMI, saveas(female) replace

*/


