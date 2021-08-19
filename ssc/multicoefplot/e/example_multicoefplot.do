/* WORKING EXAMPLE version 1.1 */

* Load and prepare data
webuse nlswork, clear
* For the time being, multicoefplot works only on "regular" periods, irregular periods can be saved as regular in a new var, then used e.g. 1=68 2=69 3=71.. etc. 
keep if inlist(year, 69,71,73,75,77)  
reshape wide birth_yr age race msp nev_mar grade collgrad not_smsa c_city south ind_code occ_code union wks_ue ttl_exp tenure hours wks_work ln_wage, i(idcode) j(year)
gen c_race=race69
gen c_birth_yr=birth_yr69
gen c_collgrad=collgrad69
gen c_south=south69
drop race* birth_yr* collgrad* south*


* Examples of specifications comparison

* Command is a first-time-users friendly option to show in the console a draft of the regression(s) being run. Varying(tenure) tells multicoefplot the treatment is timevarying.
multicoefplot ln_wage, window(69(2)77) command noconstant legend(off) ///
treatment(tenure, varying(tenure)) controls(c_race c_birth_yr c_collgrad c_south) timecontrols(age ttl_exp not_smsa)

* Comparing first spec to a second one adding time-varying FE's
multicoefplot ln_wage, window(69(2)77) command noconstant  ///
treatment1(tenure, varying(tenure)) controls1(c_race c_birth_yr c_collgrad c_south) timecontrols1(age ttl_exp not_smsa) ///
treatment2(tenure, varying(tenure)) controls2(c_race c_birth_yr c_collgrad c_south) timecontrols2(age ttl_exp not_smsa) timeabsorb2(occ_code)

* Comparing first and second specs to a third one adding time-varying FE's and using robust S.E.. Symbols is a black and white friendly option.
multicoefplot ln_wage, window(69(2)77) command noconstant symbols ///
treatment1(tenure, varying(tenure)) controls1(c_race c_birth_yr c_collgrad c_south) timecontrols1(age ttl_exp not_smsa)  ///
treatment2(tenure, varying(tenure)) controls2(c_race c_birth_yr c_collgrad c_south) timecontrols2(age ttl_exp not_smsa) timeabsorb2(occ_code) ///
treatment3(tenure, varying(tenure)) controls3(c_race c_birth_yr c_collgrad c_south) timecontrols3(age ttl_exp not_smsa) timeabsorb3(occ_code) vce3(robust) ///
legend(1 "Baseline" 2 "Occupation FE's" 3 "Occupation FE's + Robust S.E.") xlabel(1 "1969" 2 "1971" 3 "1973" 4 "1975" 5 "1977")
 
 
* Tests

* Tuplestest runs all the tuples of the included controls, separately. They have to be constant, for the time being
multicoefplot ln_wage, window(69(2)77) command noconstant legend(off) ///
treatment(tenure, varying(tenure)) timecontrols(age ttl_exp not_smsa) ///
tuplestest(c_race c_birth_yr c_collgrad c_south)

* Leaveoneouttest leaves out one of the controls at the time
multicoefplot ln_wage, window(69(2)77) command noconstant legend(off) ///
treatment(tenure, varying(tenure)) timecontrols(age ttl_exp not_smsa) ///
leaveoneouttest(c_race c_birth_yr c_collgrad c_south)

* Multitest includes one of the set of controls at the time
global cov1 "c_race c_south"
global cov2 "c_birth_yr c_collgrad"
multicoefplot ln_wage, window(69(2)77) command noconstant legend(off) ///
treatment(tenure, varying(tenure)) timecontrols(age ttl_exp not_smsa) ///
multitest(cov1 cov2)

* Perturbationtest excludes one sub-sample at the time, based on the levelsof() of the variable. Tests look can be adjusted
* Looking at the Diagnostics Table of the Perturbationtest, we see that the minimum sample drop required to change the significance of estimates is roughly 8% of the sample
multicoefplot ln_wage, window(69(2)77) command noconstant legend(off) ///
treatment(tenure, varying(tenure)) controls(c_race c_birth_yr c_collgrad c_south) timecontrols(age ttl_exp not_smsa) ///
perturbationtest(c_birth_yr) testcicolor(navy) testcoefcolor(black)

* Instrumental variable - Variables can be instrumented, and reduced forms and second stages can be put together in the same graph
multicoefplot ln_wage, window(69(2)77) command noconstant symbols ///
treatment1(tenure=age, varying(tenure age)) controls1(c_race c_birth_yr c_collgrad c_south) timecontrols1(ttl_exp not_smsa) ///
treatment2(tenure=age, varying(tenure age)) controls2(c_race c_birth_yr c_collgrad c_south) timecontrols2(ttl_exp not_smsa) timeabsorb2(occ_code) ///
treatment3(tenure=age, varying(tenure age)) controls3(c_race c_birth_yr c_collgrad c_south) timecontrols3(ttl_exp not_smsa) timeabsorb3(occ_code) vce3(robust) ///
legend(1 "Baseline" 2 "Occupation FE's" 3 "Occupation FE's + Robust S.E.") xlabel(1 "1969" 2 "1971" 3 "1973" 4 "1975" 5 "1977") 




