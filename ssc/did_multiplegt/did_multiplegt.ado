*﻿*Author: Clément de Chaisemartin
**1st version: November 8th 2019
**This version: May 18th 2020

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///// Program #1: Does sanity checks and time consuming data manipulations, calls did_multiplegt_results, and stores estimates and standard errors in e() and put them on a graph //////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

capture program drop did_multiplegt
program did_multiplegt, eclass
	version 12.0
	syntax varlist(min=4 numeric) [if] [in]  [, RECAT_treatment(varlist numeric) THRESHOLD_stable_treatment(real 0) trends_nonparam(varlist numeric) trends_lin(varlist numeric) controls(varlist numeric) weight(varlist numeric) placebo(integer 0) dynamic(integer 0) breps(integer 0) cluster(varlist numeric) covariances average_effect(string) save_results(string)]

qui{

preserve

// Globals determining whether we see the results from all the intermediate regressions 

*global no_header_no_table "vce(ols)"
global no_header_no_table "nohea notab"

*global noisily "noisily"
global noisily ""

// Dropping variables that get created later

capture drop outcome_XX
capture drop group_XX
capture drop time_XX
capture drop treatment_XX
capture drop D_cat_XX
capture drop d_cat_group_XX
capture drop diff_y_XX
capture drop diff_d_XX
capture drop ZZ_*
capture drop lag_d_cat_group_XX

// Performing sanity checks on command requested by user

if "`if'" !=""{
did_multiplegt_check `varlist' `if', recat_treatment(`recat_treatment') threshold_stable_treatment(`threshold_stable_treatment') trends_nonparam(`trends_nonparam') trends_lin(`trends_lin') controls(`controls') weight(`weight') placebo(`placebo') dynamic(`dynamic') breps(`breps') cluster(`cluster') `covariances' average_effect(`average_effect')
}

if "`if'"==""{
did_multiplegt_check `varlist', recat_treatment(`recat_treatment') threshold_stable_treatment(`threshold_stable_treatment') trends_nonparam(`trends_nonparam') trends_lin(`trends_lin') controls(`controls') weight(`weight') placebo(`placebo') dynamic(`dynamic') breps(`breps') cluster(`cluster') `covariances' average_effect(`average_effect')
}

if did_multiplegt_check==1 {

// Selecting the sample
	if "`if'" !=""{
	keep `if'
	}
	if "`weight'" !=""{
	drop if `weight'==.
	}	
	tokenize `varlist'
	//XXX: to show to Shuo
	drop if `2'==.|`3'==.|`4'==.
	if "`controls'" !=""{
	foreach var of varlist `controls'{
	drop if `var'==.
	}
	}
	if "`cluster'" !=""{
	drop if `cluster'==.
	}
	if "`recat_treatment'" !=""{
	drop if `recat_treatment'==.
	}
	if "`weight'" !=""{
	drop if `weight'==.
	}

// If the weight option is not specified, collapse data set at the (g,t) level. 

tempvar counter
gen `counter'=1

if "`weight'" ==""&aggregated_data==0{

//Collapsing the data, ensuring that group variable is not the clustering or the trend_lin variable (XXX: to show to Shuo (new))

if ("`cluster'"!=""&"`cluster'"!="`2'")&("`trends_lin'"!=""&"`trends_lin'"!="`2'"){

collapse (mean) `1' `4' `controls' `trends_nonparam' `trends_lin' `cluster' `recat_treatment' (count) `counter', by(`2' `3')

}

if ("`cluster'"==""|"`cluster'"=="`2'")&("`trends_lin'"!=""&"`trends_lin'"!="`2'"){

collapse (mean) `1' `4' `controls' `trends_nonparam' `trends_lin' `recat_treatment' (count) `counter', by(`2' `3')

}

if ("`cluster'"!=""&"`cluster'"!="`2'")&("`trends_lin'"==""|"`trends_lin'"=="`2'"){

collapse (mean) `1' `4' `controls' `trends_nonparam' `cluster' `recat_treatment' (count) `counter', by(`2' `3')

}

if ("`cluster'"==""|"`cluster'"=="`2'")&("`trends_lin'"==""|"`trends_lin'"=="`2'"){

collapse (mean) `1' `4' `controls' `trends_nonparam' `recat_treatment' (count) `counter', by(`2' `3')

}

}

// If the weight option is specified, set `counter' as `weight'. 

if "`weight'"!=""{

replace `counter'=`weight'

}

// Creating all the variables needed for estimation of instantaneous effect

*Y, G, T, D variables

gen outcome_XX=`1'
//XXX: to show to Shuo (new)
egen group_XX=group(`2')
egen time_XX=group(`3')
gen treatment_XX=`4'

*Creating a discretized treatment even if recat_treatment option not specified

if "`recat_treatment'" !=""{
gen D_cat_XX=`recat_treatment'
}
else{
gen D_cat_XX=treatment_XX
}

*Creating groups of recategorized treatment, to ensure we have an ordered treatment with interval of 1 between consecutive values

egen d_cat_group_XX=group(D_cat_XX)

*Declaring data set as panel

xtset group_XX time_XX

*First diff outcome, treatment, and controls

g diff_y_XX = d.outcome_XX
g diff_d_XX = d.treatment_XX

if "`controls'" !=""{
local count_controls=0
foreach var of varlist `controls'{
local count_controls=`count_controls'+1
gen ZZ_cont`count_controls'=d.`var'
}
}

*Lag D_cat

g lag_d_cat_group_XX = L1.d_cat_group_XX

// If placebos requested, creating all the variables needed for estimation of placebos

if "`placebo'"!="0"{

forvalue i=1/`=`placebo''{

*Lag First diff outcome, treatment, and controls
capture drop diff_d_lag`i'_XX
capture drop diff_y_lag`i'_XX
g diff_d_lag`i'_XX = L`i'.diff_d_XX
g diff_y_lag`i'_XX = L`i'.diff_y_XX

if "`controls'" !=""{
forvalue j=1/`=`count_controls''{
gen ZZ_cont_lag`i'_`j'=L`i'.ZZ_cont`j'
}

}

}

}

// If dynamic effects requested, creating all the variables needed for estimation of dynamic effects

if "`dynamic'"!="0"{

forvalue i=1/`=`dynamic''{

*Long diff outcome, forward of first diff treatment, and long diff controls

capture drop diff_d_for`i'_XX
capture drop ldiff_y_`i'_XX
capture drop ldiff_y_for`i'_XX
g diff_d_for`i'_XX = F`i'.diff_d_XX
g ldiff_y_`i'_XX = S`=`i'+1'.outcome_XX
g ldiff_y_for`i'_XX =F`i'.ldiff_y_`i'_XX 

if "`controls'" !=""{

local count_controls=0
foreach var of varlist `controls'{
local count_controls=`count_controls'+1
g ZZ_cont_ldiff`i'_`count_controls'=S`=`i'+1'.`var'
}
forvalue j=1/`=`count_controls''{
g  ZZ_cont_ldiff_for`i'_`j'=F`i'.ZZ_cont_ldiff`i'_`j'
}

}

}

}

//Replace controls by their first difference 

if "`controls'" !=""{
local count_controls=1
foreach var of varlist `controls'{
replace `var'=ZZ_cont`count_controls'
local count_controls=`count_controls'+1
}
}

//Creating trends_var if needed

if "`trends_nonparam'" !=""{
//XXX: to show to Shuo
egen long trends_var_XX=group(`trends_nonparam' time_XX)
}

// Run did_multiplegt_results.

if "`if'" !=""{
did_multiplegt_results `varlist' `if', threshold_stable_treatment(`threshold_stable_treatment') trends_nonparam(`trends_nonparam') trends_lin(`trends_lin') controls(`controls') counter(`counter') placebo(`placebo') dynamic(`dynamic') breps(`breps') cluster(`cluster')
}
if "`if'" ==""{
did_multiplegt_results `varlist', threshold_stable_treatment(`threshold_stable_treatment') trends_nonparam(`trends_nonparam') trends_lin(`trends_lin') controls(`controls') counter(`counter') placebo(`placebo') dynamic(`dynamic') breps(`breps') cluster(`cluster')
}

// Compute standard errors of point estimates 

if `breps'>0 {

drop _all

svmat bootstrap
sum bootstrap1
scalar se_effect_0_2=r(sd)
forvalue i=1/`dynamic'{
sum bootstrap`=`i'+1'
scalar se_effect_`i'_2=r(sd)
}
forvalue i=1/`placebo'{
sum bootstrap`=`i'+`dynamic'+1'
scalar se_placebo_`i'_2=r(sd)
}

}

// Clearing ereturn

ereturn clear

// Error message if instantaneous effect could not be estimated

if N_effect_0_2==.{
di as error "When estimating the instantaneous treatment effect, the command has not been able to compute any DID comparing" 
di as error "a group going from d to d' units of treatment to a group whose treatment is equal to d at both dates. You may" 
di as error "need to use the threshold_stable_treatment option to ensure you have groups whose treatment does not change" 
di as error "over time. You may also need to use the recat_treatment option to discretize your treatment variable."
}

// If instantaneous effect could be estimated, collect estimate and number of observations 

else {
ereturn scalar effect_0 = effect_0_2
if `breps'>0 {
ereturn scalar se_effect_0 = se_effect_0_2
}
ereturn scalar N_effect_0 = N_effect_0_2
ereturn scalar N_switchers_effect_0 = N_switchers_effect_0_2
}

// If dynamic effects requested, collect estimates and number of observations

if "`dynamic'"!="0"{

*Looping over the number of dynamic effects requested

forvalue i=1/`=`dynamic''{

// Error message if dynamic effect i could not be estimated

if N_effect_`i'_2==.{
di as error "When estimating dynamic effect "`i' 
di as error "the command has not been able to compute any DID comparing a group" 
di as error "going from d to d' units of treatment between t-1 and t to a group whose treatment is still equal to d at t+"`i' 
di as erro " You may use the threshold_stable_treatment option to ensure you have groups whose treatment does not change" 
di as error "over time. You may also need to use the recat_treatment option to discretize your treatment variable." 
di as error "Or maybe you are just trying to estimate too many dynamic effects: for long-run dynamic effects, you need"
di as error "to have groups whose treatment does not change for many periods. There may not be such groups in your data."
}

// If dynamic effect i could be estimated, collect estimate and number of observations 

else {
ereturn scalar effect_`i' = effect_`i'_2
if `breps'>0 {
ereturn scalar se_effect_`i' = se_effect_`i'_2
}
ereturn scalar N_effect_`i' = N_effect_`i'_2
ereturn scalar N_switchers_effect_`i' = N_switchers_effect_`i'_2
}

*End of the loop on the number of dynamic effects
}

*End of the condition assessing if the computation of dynamic effects was requested by the user
}

// If placebos requested, collect estimates and number of observations

if "`placebo'"!="0"{

*Looping over the number of placebos requested

forvalue i=1/`=`placebo''{

// Error message if placebo i could not be estimated

if N_placebo_`i'_2==.{
di as error "When estimating placebo "`i' ", the command has not been able to compute any DID comparing a group" 
di as error "going from d to d' units of treatment between t-1 and t and with a treatment equal to d from t-" `=`i'+1' " to t-1"
di as error "to a group whose treatment is equal to d from t-"`=`i'+1' " to t. You may use the threshold_stable_treatment" 
di as error "option to ensure you have groups whose treatment does not change over time. You may also need to use the" 
di as error "recat_treatment option to discretize your treatment variable. Or maybe you are just trying to estimate"
di as error "too many placebos: for long-run placebos, you need to have groups whose treatment does not change"
di as error "for many periods. There may not be such groups in your data."
}

// If placebo i could be estimated, collect estimate and number of observations 

else {
ereturn scalar placebo_`i' = placebo_`i'_2
if `breps'>0 {
ereturn scalar se_placebo_`i' = se_placebo_`i'_2
}
ereturn scalar N_placebo_`i' = N_placebo_`i'_2
}

*End of the loop on the number of placebos
}

*End of the condition assessing if the computation of placebos was requested by the user
}

// If dynamic effects or placebos requested and covariance option specified, compute covariances between all estimated effects

if `breps'>0&"`covariances'"!=""{

if "`dynamic'"!="0"{

forvalue i=0/`dynamic'{
forvalue j=`=`i'+1'/`dynamic'{
correlate bootstrap`=`i'+1' bootstrap`=`j'+1', covariance
ereturn scalar cov_effects_`i'`j'=r(cov_12)
scalar cov_effects_`i'`j'_int=r(cov_12)
scalar cov_effects_`j'`i'_int=r(cov_12)
}
}

}


if `placebo'>1{

forvalue i=1/`placebo'{
forvalue j=`=`i'+1'/`placebo'{
correlate bootstrap`=`i'+`dynamic'+1' bootstrap`=`j'+`dynamic'+1', covariance
ereturn scalar cov_placebo_`i'`j'=r(cov_12)
scalar cov_placebo_`i'`j'_int=r(cov_12)
}
}

}

}

/////// Computing average effect, if option requested (XXX: to show to Shuo)

if "`average_effect'"!=""{

scalar average_effect_int=0
scalar var_average_effect_int=0
scalar N_average_effect_int=0

//// Computing weights

// Weights for simple average

if "`average_effect'"=="simple"{
scalar check_cov=1
matrix Weight=J(`dynamic'+1,1,1/(`dynamic'+1))
}

// Weights proportionnal to number of switchers for which each effect is estimated

if "`average_effect'"=="prop_number_switchers"{
scalar check_cov=1
scalar total_switchers=0
forvalue i=0/`=`dynamic''{
matrix Weight[`i'+1,1]=N_switchers_effect_`i'_2
scalar total_switchers=total_switchers+N_switchers_effect_`i'_2
}
matrix Weight=Weight*(1/total_switchers)

}

//// Computing average effect, its variance, and returning results 

forvalue i=0/`=`dynamic''{
ereturn scalar weight_effect_`i'=Weight[`i'+1,1]
scalar average_effect_int=average_effect_int+Weight[`i'+1,1]*effect_`i'_2
scalar N_average_effect_int=N_average_effect_int+N_effect_`i'_2
scalar var_average_effect_int=var_average_effect_int+Weight[`i'+1,1]^2*se_effect_`i'_2^2
if `i'<`dynamic'{
forvalue j=`=`i'+1'/`=`dynamic''{
scalar var_average_effect_int=var_average_effect_int+Weight[`i'+1,1]*Weight[`j'+1,1]*2*cov_effects_`i'`j'_int
}
}
}

*Returning results

ereturn scalar effect_average=average_effect_int  
ereturn scalar se_effect_average=sqrt(var_average_effect_int)
ereturn scalar N_effect_average=N_average_effect_int

}

///// Putting estimates and their confidence intervals on a graph, if breps option specified

if "`breps'"!="0"{

local estimates_req=2+`placebo'+`dynamic'

if `breps'<`estimates_req' {
set obs `estimates_req'
}

gen time_to_treatment=.
gen treatment_effect=.
gen se_treatment_effect=.
gen N_treatment_effect=.
gen treatment_effect_upper_95CI=.
gen treatment_effect_lower_95CI=.

if "`placebo'"!="0"{
forvalue i=1/`=`placebo''{
replace time_to_treatment=-`i' if _n==`placebo'-`i'+1 
replace treatment_effect=placebo_`i'_2 if _n==`placebo'-`i'+1
replace se_treatment_effect=se_placebo_`i'_2 if _n==`placebo'-`i'+1
replace N_treatment_effect=N_placebo_`i'_2 if _n==`placebo'-`i'+1
replace treatment_effect_upper_95CI=placebo_`i'_2+1.96*se_placebo_`i'_2 if _n==`placebo'-`i'+1
replace treatment_effect_lower_95CI=placebo_`i'_2-1.96*se_placebo_`i'_2 if _n==`placebo'-`i'+1
}
}

replace time_to_treatment=0 if _n==`placebo'+1 
replace treatment_effect=effect_0_2 if _n==`placebo'+1 
replace se_treatment_effect=se_effect_0_2 if _n==`placebo'+1
replace N_treatment_effect=N_effect_0_2 if _n==`placebo'+1
replace treatment_effect_upper_95CI=effect_0_2+1.96*se_effect_0_2 if _n==`placebo'+1 
replace treatment_effect_lower_95CI=effect_0_2-1.96*se_effect_0_2 if _n==`placebo'+1 

if "`dynamic'"!="0"{
forvalue i=1/`=`dynamic''{
replace time_to_treatment=`i' if _n==`placebo'+`i'+1 
replace treatment_effect=effect_`i'_2 if _n==`placebo'+`i'+1 
replace se_treatment_effect=se_effect_`i'_2 if _n==`placebo'+`i'+1
replace N_treatment_effect=N_effect_`i'_2 if _n==`placebo'+`i'+1
replace treatment_effect_upper_95CI=effect_`i'_2+1.96*se_effect_`i'_2 if _n==`placebo'+`i'+1 
replace treatment_effect_lower_95CI=effect_`i'_2-1.96*se_effect_`i'_2 if _n==`placebo'+`i'+1 
}
}

twoway (line treatment_effect time_to_treatment, lpattern(solid)) (rcap treatment_effect_upper_95CI treatment_effect_lower_95CI time_to_treatment), xlabel(-`placebo'[1]`dynamic') xtitle("Time since treatment", size(large)) ytitle("Treatment effect", size(large)) graphregion(color(white)) plotregion(color(white)) legend(off)

/////Saving results in a data set, if option requested (XXX: to show to Shuo)

if "`save_results'"!=""{

	if "`average_effect'"!=""{
	tostring time_to_treatment, replace
	replace time_to_treatment="Average effect" if _n==`placebo'+`dynamic'+2 
	replace treatment_effect=average_effect_int if _n==`placebo'+`dynamic'+2 
	replace se_treatment_effect=sqrt(var_average_effect_int) if _n==`placebo'+`dynamic'+2
	replace N_treatment_effect=N_average_effect_int if _n==`placebo'+`dynamic'+2
	replace treatment_effect_upper_95CI=treatment_effect+1.96*se_treatment_effect if _n==`placebo'+`dynamic'+2 
	replace treatment_effect_lower_95CI=treatment_effect-1.96*se_treatment_effect if _n==`placebo'+`dynamic'+2  
	}
 	
keep time_to_treatment N_treatment_effect treatment_effect se_treatment_effect treatment_effect_upper_95CI treatment_effect_lower_95CI

if "`average_effect'"!=""{
keep if _n<=2+`placebo'+`dynamic'
}
if "`average_effect'"==""{
keep if _n<=1+`placebo'+`dynamic'
}

save "`save_results'", replace

}

}

// End of the condition assessing if sanity checks satisfied
}

restore

// End of the quietly condition
}

// Answers to FAQs

if N_effect_0_2!=.&did_multiplegt_check==1{
di as text "This command does not produce a table, but all the estimators you have requested and their standard errors"
di as text "are stored as eclass objects. Please type ereturn list to see them."
di as text "If the breps option was specified, the command also produces a graph, with all the point estimates"
di as text "and their 95% confidence intervals. To change some features of the graph, open the adofile and search" 
di as text "for twoway. That will lead you to the line of code that produces the graph. You can modify that line"
di as text "to produce the graph you would like."
}

end


///////////////////////////////////////////////////////////////////
///// Program #2: does all the sanity checks before estimation ////
///////////////////////////////////////////////////////////////////

capture program drop did_multiplegt_check
program did_multiplegt_check, eclass
	version 12.0
	syntax varlist(min=4 max=4 numeric) [if] [in]  [, RECAT_treatment(varlist numeric) THRESHOLD_stable_treatment(real 0) trends_nonparam(varlist numeric) trends_lin(varlist numeric) controls(varlist numeric) weight(varlist numeric) placebo(integer 0) dynamic(integer 0) breps(integer 0) cluster(varlist numeric) covariances average_effect(string)]
	
preserve	
	
// Names of temporary variables
tempvar counter

// Initializing check

scalar did_multiplegt_check=1

// Selecting sample

	if "`if'" !=""{
	keep `if'
	}
	tokenize `varlist'
	drop if `1'==.|`2'==.|`3'==.|`4'==.
	if "`controls'" !=""{
	foreach var of varlist `controls'{
	drop if `var'==.
	}
	}
	if "`cluster'" !=""{
	drop if `cluster'==.
	}
	if "`recat_treatment'" !=""{
	drop if `recat_treatment'==.
	}
	if "`weight'" !=""{
	drop if `weight'==.
	}

// Creating the Y, G, T, D variables
	
	gen outcome_XX=`1'
	gen group_XX=`2'
	egen time_XX=group(`3')
	gen treatment_XX=`4'

// When the weight option is specified, the data has to be at the (g,t) level.

bys group_XX time_XX: egen `counter'=count(outcome_XX)
sum `counter'

if r(max)>1&"`weight'"!=""{
di as error"You have specified the weight option but your data is not aggregated at the group*time level, the command cannot run, aggregate your data at the group*time level before running it."
scalar did_multiplegt_check=0
}

scalar aggregated_data=0
if r(max)==1{
scalar aggregated_data=1
}

// Counting time periods and checking at least two time periods

sum time_XX, meanonly
if r(max)<2 {
di as error"There are less than two time periods in the data, the command cannot run."
scalar did_multiplegt_check=0
}
local max_time=r(max)

// Creating a discretized treatment even if recat_treatment option not specified

if "`recat_treatment'" !=""{
gen D_cat_XX=`recat_treatment'
}
else{
gen D_cat_XX=treatment_XX
}

// Creating groups of recategorized treatment, to ensure we have an ordered treatment with interval of 1 between consecutive values

egen d_cat_group_XX=group(D_cat_XX)

// Counting treatment values and checking at least two values

sum d_cat_group_XX, meanonly
if r(max)==r(min) {
di as error "Either the treatment variable or the recategorized treatment in the recat_treatment option takes only one value, the command cannot run."
scalar did_multiplegt_check=0
}

// Checking that the number in threshold_stable_treatment is positive

if `threshold_stable_treatment'<0{
di as error "The number in the threshold_stable_treatment option should be greater than or equal to 0."
scalar did_multiplegt_check=0
}

// Checking that the trends_nonparam and trends_lin options have not been jointly specified

if "`trends_nonparam'" !=""&"`trends_lin'" !=""{
di as error "The trends_nonparam and trends_lin options cannot be specified at the same time."
scalar did_multiplegt_check=0
}

// Checking that number of placebos requested is admissible

if `placebo'>`max_time'-2{
di as error "The number of placebo estimates you have requested it too large: it should be at most equal to the number"
di as error "of time periods in your data minus 2."
scalar did_multiplegt_check=0
}

// Checking that number of dynamic effects requested is admissible

if `dynamic'>`max_time'-2{
di as error "The number of dynamic effects you have requested it too large: it should be at most equal to the number"
di as error "of time periods in your data minus 2."
scalar did_multiplegt_check=0
}

// Checking that number of bootstrap replications requested greater than 2

if `breps'==1{
di as error "The number of bootstrap replications should be equal to 0, or greater than 2."
scalar did_multiplegt_check=0
}

// Checking that if average_effect option requested, covariances option also requested and number of dynamic effects at least one (XXX: to show to Shuo)

if "`average_effect'"!=""&("`covariances'"==""|`dynamic'==0) {
di as error "If you request the average_effect option, you also need to request the covariances option," 
di as error "and that at least one dynamic effect be computed."
scalar did_multiplegt_check=0
}

restore

end

/////////////////////////////////////////////////////////
///// Program #3: Runs and boostraps did_multiplegt_estim
/////////////////////////////////////////////////////////


capture program drop did_multiplegt_results
program did_multiplegt_results, eclass
	version 12.0
	syntax varlist(min=4 numeric) [if] [in]  [, RECAT_treatment(varlist numeric) THRESHOLD_stable_treatment(real 0) trends_nonparam(varlist numeric) trends_lin(varlist numeric) controls(varlist numeric) counter(varlist numeric) placebo(integer 0) dynamic(integer 0) breps(integer 0) cluster(varlist numeric) covariances]
	
// If computation of standard errors requested, bootstrap did_multiplegt_estim

if `breps'>0 {

tempvar group_bsample

// Initializing the too many controls scalar

scalar too_many_controls=0
 
forvalue i=1/`breps'{

preserve

bsample, cluster(`cluster')

//Indicate that program will run bootstrap replications

local bootstrap_rep=1

if "`if'" !=""{
did_multiplegt_estim `varlist' `if', threshold_stable_treatment(`threshold_stable_treatment') trends_nonparam(`trends_nonparam') trends_lin(`trends_lin') controls(`controls') counter(`counter') placebo(`placebo') dynamic(`dynamic') breps(`breps') cluster(`cluster') bootstrap_rep(`bootstrap_rep')
}
if "`if'" ==""{
did_multiplegt_estim `varlist', threshold_stable_treatment(`threshold_stable_treatment') trends_nonparam(`trends_nonparam') trends_lin(`trends_lin') controls(`controls') counter(`counter') placebo(`placebo') dynamic(`dynamic') breps(`breps') cluster(`cluster') bootstrap_rep(`bootstrap_rep')
}

// Put results into a matrix 

matrix bootstrap_`i'=effect_0_2
forvalue j=1/`dynamic'{
matrix bootstrap_`i'=bootstrap_`i',effect_`j'_2
}
forvalue j=1/`placebo'{
matrix bootstrap_`i'=bootstrap_`i',placebo_`j'_2
}

restore

// End of the loop on number of bootstrap replications
}

// Putting the matrix with all bootstrap reps together

matrix bootstrap=bootstrap_1
forvalue i=2/`breps'{
matrix bootstrap=bootstrap\ bootstrap_`i'
}

// Error message if too many controls

if too_many_controls==1{
di as text "In some bootstrap replications, the command had to run regressions with more control variables" 
di as text "than the sample size, so the controls could not be accounted for. Typically, this issue only" 
di as text "affects a small number of observations. If you still want to solve this problem, you may" 
di as text "reduce the number of control variables. You may also use the recat_treatment option to discretize"
di as text "your treatment. Finally, you could reduce the number of placebos and/or dynamic effects requested."
}

// End of if condition assessing if bootstrap reps requested 
}

// Run did_multiplegt_estim to get estimates and number of observations used 

preserve

//Indicate that program will run main estimation

local bootstrap_rep=0

// Initializing the too many controls scalar

scalar too_many_controls=0

if "`if'" !=""{
did_multiplegt_estim `varlist' `if', threshold_stable_treatment(`threshold_stable_treatment') trends_nonparam(`trends_nonparam') trends_lin(`trends_lin') controls(`controls') counter(`counter') placebo(`placebo') dynamic(`dynamic') breps(`breps') cluster(`cluster') bootstrap_rep(`bootstrap_rep')
}
if "`if'" ==""{
did_multiplegt_estim `varlist', threshold_stable_treatment(`threshold_stable_treatment') trends_nonparam(`trends_nonparam') trends_lin(`trends_lin') controls(`controls') counter(`counter') placebo(`placebo') dynamic(`dynamic') breps(`breps') cluster(`cluster') bootstrap_rep(`bootstrap_rep')
}

// Error message if too many controls

if too_many_controls==1{
di as text "At some point, the command had to run regressions with more control variables" 
di as text "than the sample size, so the controls could not be accounted for. Typically, this issue only" 
di as text "affects a small number of observations. If you still want to solve this problem, you may"
di as text "reduce the number of control variables. You may also use the recat_treatment option to discretize"
di as text "your treatment. Finally, you could reduce the number of placebos and/or dynamic effects requested."
}

restore

end

////////////////////////////////////////////////////////////////////////////////
///// Program #4: requests computation of all point estimates asked by user ////
////////////////////////////////////////////////////////////////////////////////

capture program drop did_multiplegt_estim
program did_multiplegt_estim, eclass
	version 12.0
	syntax varlist(min=4 numeric) [if] [in] [, THRESHOLD_stable_treatment(real 0) trends_nonparam(varlist numeric) trends_lin(varlist numeric) controls(varlist numeric) counter(varlist numeric) placebo(integer 0) dynamic(integer 0) breps(integer 0) cluster(varlist numeric) bootstrap_rep(integer 0)]

// Counting time periods

sum time_XX, meanonly
local max_time=r(max)

// Estimating the instantaneous effect

*Running did_multiplegt_core

did_multiplegt_core, threshold_stable_treatment(`threshold_stable_treatment') trends_nonparam(`trends_nonparam') trends_lin(`trends_lin') controls(`controls') d_cat_group(d_cat_group_XX) lag_d_cat_group(lag_d_cat_group_XX) diff_d(diff_d_XX) diff_y(diff_y_XX) counter(`counter') time(time_XX) group_int(group_XX) max_time(`max_time') counter_placebo(0) counter_dynamic(0) bootstrap_rep(`bootstrap_rep')

*Collecting point estimate and number of observations

scalar effect_0_2=effect
scalar N_effect_0_2=N_effect
scalar N_switchers_effect_0_2=N_switchers

// If placebos requested, estimate them and number of observations used in that estimation

if "`placebo'"!="0"{

tempvar cond_placebo  
gen `cond_placebo'=1

*Looping over the number of placebos requested

forvalue i=1/`=`placebo''{

*Replacing FD of outcome by lagged FD of outcome, FD of controls by lagged FD of controls, and excluding from placebo observations whose lagged FD of treatment non 0. 

replace `cond_placebo'=0 if abs(diff_d_lag`i'_XX)>`threshold_stable_treatment'

preserve

replace diff_y_XX=diff_y_lag`i'_XX

if "`controls'" !=""{
local j=0
foreach var of varlist `controls'{
local j=`j'+1
replace `var'=ZZ_cont_lag`i'_`j'
}
}

*If no observation satisfy `cond_placebo'==1, set N_placebo_`i'_2 to 0

sum diff_y_XX if `cond_placebo'==1

if r(N)==0{

scalar N_placebo_`i'_2=.
}

*Otherwise, run did_multiplegt_core

else{

did_multiplegt_core if `cond_placebo'==1, threshold_stable_treatment(`threshold_stable_treatment') trends_nonparam(`trends_nonparam') trends_lin(`trends_lin') controls(`controls') d_cat_group(d_cat_group_XX) lag_d_cat_group(lag_d_cat_group_XX) diff_d(diff_d_XX) diff_y(diff_y_XX) counter(`counter') time(time_XX) group_int(group_XX) max_time(`max_time') counter_placebo(`i') counter_dynamic(0) bootstrap_rep(`bootstrap_rep')

*Collecting point estimate and number of observations

scalar placebo_`i'_2=effect
scalar N_placebo_`i'_2=N_effect

}

restore

*End of the loop on the number of placebos
}

*End of the condition assessing if the computation of placebos was requested by the user
}

// If dynamic effects requested, estimate them and number of observations used in that estimation

if "`dynamic'"!="0"{

tempvar cond_dynamic
gen `cond_dynamic'=1

*Looping over the number of placebos requested

forvalue i=1/`=`dynamic''{

*Replacing FD of outcome by long diff of outcome, and creating variable to exclude from placebo observations whose lead FD of treatment non 0. 

replace `cond_dynamic'=0 if abs(diff_d_for`i'_XX)>`threshold_stable_treatment'

preserve

replace diff_y_XX=ldiff_y_for`i'_XX 

if "`controls'" !=""{
local j=0
foreach var of varlist `controls'{
local j=`j'+1
replace `var'=ZZ_cont_ldiff_for`i'_`j'
}
}

*If no observation satisfy `cond_dynamic'==1, set N_effect_`i'_2 to 0

sum diff_y_XX if `cond_dynamic'==1

if r(N)==0{

scalar N_effect_`i'_2=.
scalar N_switchers_effect_`i'_2=.

}

*Otherwise, run did_multiplegt_core

else{

did_multiplegt_core if `cond_dynamic'==1, threshold_stable_treatment(`threshold_stable_treatment') trends_nonparam(`trends_nonparam') trends_lin(`trends_lin') controls(`controls') d_cat_group(d_cat_group_XX) lag_d_cat_group(lag_d_cat_group_XX) diff_d(diff_d_XX) diff_y(diff_y_XX) counter(`counter') time(time_XX) group_int(group_XX) max_time(`max_time') counter_placebo(0) counter_dynamic(`i') bootstrap_rep(`bootstrap_rep')

*Collecting point estimate and number of observations

scalar effect_`i'_2=effect
scalar N_effect_`i'_2=N_effect
scalar N_switchers_effect_`i'_2=N_switchers

}

restore

drop diff_d_for`i'_XX 

*End of the loop on the number of dynamic effects
}

*End of the condition assessing if the computation of dynamic effects was requested by the user
}

end

////////////////////////////////////////////////////////////////////////////////
///// Program #5: performs computation of all individual point estimates ///////
////////////////////////////////////////////////////////////////////////////////

capture program drop did_multiplegt_core
program did_multiplegt_core
	version 12.0
	syntax [if] [in] [, THRESHOLD_stable_treatment(real 0) trends_nonparam(varlist numeric) trends_lin(varlist numeric) controls(varlist numeric) d_cat_group(varlist numeric) lag_d_cat_group(varlist numeric) diff_d(varlist numeric) diff_y(varlist numeric) counter(varlist numeric) time(varlist numeric) group_int(varlist numeric) max_time(integer 0) counter_placebo(integer 0) counter_dynamic(integer 0) bootstrap_rep(integer 0)]

tempvar diff_y_res1 diff_y_res2 group_incl treatment_dummy tag_obs tag_switchers counter_tot counter_switchers

preserve

// Selecting the sample
	if "`if'" !=""{
	keep `if'
	}

// Drop if diff_y_XX missing, to avoid that those observations are used in estimation (XXX: To show to Shuo)

drop if diff_y_XX==.
	
// Creating residualized first diff outcome if control variables specified in estimation

if "`controls'" !=""|"`trends_nonparam'" !=""|"`trends_lin'" !=""{

sum d_cat_group_XX, meanonly
local D_min=r(min)
local D_max=r(max)

$noisily di "residualizing outcome"

forvalue d=`=`D_min''/`=`D_max'' {

global cond_stable "abs(diff_d_XX)<=`threshold_stable_treatment'&lag_d_cat_group_XX==`d'"

sum diff_y_XX if $cond_stable, meanonly

// Assessing if too many controls

if r(N)<=wordcount("`controls'"){
scalar too_many_controls=1
}

// We do the residualization only if there are groups with a stable treatment equal to d between two dates
else {
if "`trends_nonparam'"!=""{

/////////////// Regression of diff_y on controls and time FEs interacted with trends_nonparam variable, and computation of residuals (XXX: to show to Shuo)

cap drop FE*
capture $noisily reghdfe diff_y_XX `controls' [aweight=`counter'] if $cond_stable, absorb(FE1=trends_var_XX) resid keepsingletons

// Tagging units with a value of `trends_nonparam' that does not appear in the regression sample
// Example: In a county-level application, we may want to allow for state-year effects.
// But we may have a county going from 2 to 3 units of treatment between two years, but such that no county in that state remains at 2 units between those two years.
// Then, that county-year's state-year effect is dropped from the regression, so we cannot use that regression to compute that county-year's residual.
gen `tag_obs'=e(sample)
bys trends_var_XX: egen `group_incl'=max(`tag_obs')

matrix B = e(b)

// 1st step of residual construction: outcome - FE
fcollapse (mean) FE=FE1 , by(trends_var_XX) merge
gen `diff_y_res1'  = diff_y_XX - FE

// 2nd step of residual construction: residual(outcome - FE) - controls*beta
local j = 0
foreach var of local controls {
local j = `j' + 1
gen coeff`j' = B[1,`j']
replace `diff_y_res1' = `diff_y_res1'  - coeff`j'*`var'
}

// 3rd step of residual construction: residual(outcome - FE- controls*beta) - constant
local j = `j' + 1
gen constant = B[1,`j']
replace `diff_y_res1' = `diff_y_res1' - constant

cap drop FE constant
cap drop coeff*

// Regression of diff_y on controls and time FEs, and computation of residuals 
$noisily reg diff_y_XX `controls' i.time_XX [aweight=`counter'] if $cond_stable, $no_header_no_table
predict `diff_y_res2', r

// Replacing diff_y_XX by residual from 1st regression, for observations whose group was included in first regression, and by residual from 2nd regression for other observations
replace diff_y_XX=`diff_y_res1' if lag_d_cat_group_XX==`d'&`group_incl'==1
replace diff_y_XX=`diff_y_res2' if lag_d_cat_group_XX==`d'&`group_incl'==0

drop `diff_y_res1' `diff_y_res2' `group_incl' `tag_obs'

}

if "`trends_lin'"!=""{

///////////////// Regression of diff_y on controls and FEs of trends_lin, and computation of residuals (XXX: to show to Shuo)

cap drop FE*
capture $noisily reghdfe diff_y_XX `controls' [aweight=`counter'] if $cond_stable, absorb(FE1=`trends_lin' FE2=time_XX) resid keepsingletons

// Tagging units with a value of `trends_nonparam' that does not appear in the regression sample
// Example: In a county-level application, we may want to allow for state-year effects.
// But we may have a county going from 2 to 3 units of treatment between two years, but such that no county in that state remains at 2 units between those two years.
// Then, that county-year's state-year effect is dropped from the regression, so we cannot use that regression to compute that county-year's residual.
gen `tag_obs'=e(sample)
bys `trends_lin': egen `group_incl'=max(`tag_obs')

matrix B = e(b)

// 1st step of residual construction: outcome - FE
fcollapse (mean) FE_1=FE1, by(`trends_lin') merge
fcollapse (mean) FE_2=FE2, by(time_XX) merge
gen `diff_y_res1'  = diff_y_XX - FE_1-FE_2

// 2nd step of residual construction: residual(outcome - FE) - controls*beta
local j = 0
foreach var of local controls {
local j = `j' + 1
gen coeff`j' = B[1,`j']
replace `diff_y_res1' = `diff_y_res1'  - coeff`j'*`var'
}

// 3rd step of residual construction: residual(outcome - FE- controls*beta) - constant
local j = `j' + 1
gen constant = B[1,`j']
replace `diff_y_res1' = `diff_y_res1' - constant

cap drop FE* constant 
cap drop coeff*

///////////////////// Regression of diff_y on controls, and computation of residuals
$noisily reg diff_y_XX `controls' i.time_XX [aweight=`counter'] if $cond_stable, $no_header_no_table
predict `diff_y_res2', r

// Replacing diff_y_XX by residual from 1st regression, for observations whose group was included in first regression, and by residual from 2nd regression for other observations
replace diff_y_XX=`diff_y_res1' if lag_d_cat_group_XX==`d'&`group_incl'==1
replace diff_y_XX=`diff_y_res2' if lag_d_cat_group_XX==`d'&`group_incl'==0
drop `diff_y_res1' `diff_y_res2' `group_incl' `tag_obs'

}

if "`trends_nonparam'"==""&"`trends_lin'"==""{

// Regression of diff_y on controls, computation of residuals, and replacing diff_y by residual
$noisily reg diff_y_XX `controls' i.time_XX [aweight=`counter'] if $cond_stable, $no_header_no_table
predict `diff_y_res1', r
replace diff_y_XX=`diff_y_res1' if lag_d_cat_group_XX==`d'
drop `diff_y_res1' 
}

// End of the if condition assessing if there are groups with a stable value of the treatment equal to d between two dates
}

// End of the loop over values of D_cat
}

// End of the if condition assessing if some type of controls are included in the estimation
}
 
// Treatment effect

// Initializing estimate, weight, and variable to count observations used in estimation
scalar effect=0
scalar N_effect =0
scalar N_switchers=0
scalar denom=0
gen `tag_obs'=0
gen `tag_switchers'=0

$noisily di "Computing DIDM"

// Looping over time periods
forvalue t=`=`counter_placebo'+2'/`=`max_time'-`counter_dynamic''{

// Determining the min and max value of group of treatment at t-1
sum lag_d_cat_group_XX if time_XX==`t', meanonly

local D_min=r(min)
local D_max=r(max)

// Ensuring that there are observations with non missing lagged treatment (XXX: to show to Shuo (new))

if `D_min'!=.&`D_max'!=.{

// Looping over possible values of lag_D at time t
forvalue d=`=`D_min''/`=`D_max'' {

// Defining conditions for groups where treatment increased/remained stable/decreased between t-1 and t

global cond_increase_t "diff_d_XX>`threshold_stable_treatment'&lag_d_cat_group_XX==`d'&time_XX==`t'&diff_d_XX!=."
global cond_stable_t "abs(diff_d_XX)<=`threshold_stable_treatment'&lag_d_cat_group_XX==`d'&time_XX==`t'"
global cond_decrease_t "diff_d_XX<-`threshold_stable_treatment'&lag_d_cat_group_XX==`d'&time_XX==`t'"

// Counting number of units in each supergroup
sum d_cat_group_XX if $cond_increase_t, meanonly
scalar n_increase=r(N)
sum d_cat_group_XX if $cond_stable_t, meanonly
scalar n_stable=r(N)
sum d_cat_group_XX if $cond_decrease_t, meanonly
scalar n_decrease=r(N)

// If there are units whose treatment increased and units whose treatment remained stable, estimate corresponding DID, 
// increment point estimate and weight, and tag observations used in estimation
if n_increase*n_stable>0 {
gen `treatment_dummy' =($cond_increase_t)

if `bootstrap_rep'==0{
replace `tag_obs'=1 if (($cond_increase_t)|($cond_stable_t))
// XXX: To show to Shuo
replace `tag_switchers'=1 if $cond_increase_t
}

$noisily reg diff_y_XX `treatment_dummy' [aweight=`counter'] if ($cond_increase_t)|($cond_stable_t), $no_header_no_table
sum `counter' if $cond_increase_t, meanonly
scalar effect=effect+_b[`treatment_dummy']*r(N)*r(mean)
$noisily reg diff_d_XX `treatment_dummy' [aweight=`counter'] if ($cond_increase_t)|($cond_stable_t), $no_header_no_table
sum `counter' if $cond_increase_t, meanonly
scalar denom=denom+_b[`treatment_dummy']*r(N)*r(mean)
drop `treatment_dummy' 
}

// If there are units whose treatment decreased and units whose treatment remained stable, estimate corresponding DID, 
// increment point estimate and weight, and tag observations used in estimation
if n_decrease*n_stable>0 {
gen `treatment_dummy' =($cond_decrease_t)

if `bootstrap_rep'==0{
replace `tag_obs'=1 if (($cond_decrease_t)|($cond_stable_t))
// XXX: To show to Shuo
replace `tag_switchers'=1 if $cond_decrease_t
}

$noisily reg diff_y_XX `treatment_dummy' [aweight=`counter'] if ($cond_decrease_t)|($cond_stable_t), $no_header_no_table
sum `counter' if $cond_decrease_t, meanonly
scalar effect=effect-_b[`treatment_dummy']*r(N)*r(mean)
$noisily reg diff_d_XX `treatment_dummy' [aweight=`counter'] if ($cond_decrease_t)|($cond_stable_t), $no_header_no_table
sum `counter' if $cond_decrease_t, meanonly
scalar denom=denom-_b[`treatment_dummy']*r(N)*r(mean)
drop `treatment_dummy' 
}

// End of loop on recat treatment values at t-1 
}

// End of condition ensuring that there are observations with non missing lagged treatment (XXX: to show to Shuo (new))
}

// End of loop on time
}

scalar effect=effect/denom

if `bootstrap_rep'==0{
egen `counter_tot'=total(`counter') if `tag_obs'==1
sum `counter_tot', meanonly
scalar N_effect=r(mean)
// XXX: to show to Shuo
egen `counter_switchers'=total(`counter') if `tag_switchers'==1
sum `counter_switchers', meanonly
scalar N_switchers=r(mean)
}

restore

end
