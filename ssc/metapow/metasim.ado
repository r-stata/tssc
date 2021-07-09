*! version 0.1.1 25jul2012

/*
History
MJC 25jul2012: version 0.1.1 - fixed local name clash in sens/spec var_sens and var_spec 
							 - now using rbinomial() instead of rndbin() so seed will work
MJC 18jul2012: version 0.1.0
*/

program define metasim
	version 11.2
	syntax varlist(min=4 max=6 numeric), 											///
												N(integer) 							/// -number of subjects-
												ES(numlist min=1 max=2)     		/// -pooled estimate-
												VAR(numlist min=1 max=2) 			/// -variance/s for es-
												TYpe(string) 						/// -type of study: clinical or diagnostic-
																					///
											[										///
												MEASure(string) 					/// -or/rr/rd/nostandard/d/ss-
												P(real 0)							/// -event rate in control group / prob being disease in positive group-
												R(real 1) 							/// -ratio of number of subjects in each group-
												STudies(integer 1) 					/// -number of new studies to be generated-
												MODel(string)						/// -type of meta-analysis-
												TAUsq(numlist min=1 max=2)  		/// -between study variation-
												DIST(string)						/// -type of distribution: (normal/t)-
												CORR(real 0)						/// -correlation between logit(sens) and logit(spec)-
											]
	
	//===============================================================================================================================================================//
	// Error checks and defaults 
	
		capture which metan 
		if _rc>0 {
			display as error "You need to install the command metan. This can be installed using,"
			display as error ". {stata ssc install metan}"
			exit 198
		}

		if "`type'"=="diagnostic" {
			capture which metandi 
			if _rc>0 {
				display as error "You need to install the command metandi. This can be installed using,"
				display as error ". {stata ssc install metandi}"
				exit 198
			}
			capture which midas 
			if _rc>0 {
				display as error "You need to install the command midas. This can be installed using,"
				display as error ". {stata ssc install midas}"
				exit 198
			}
		}

		/* Set defaults */

		if "`model'"=="" & "`measure'"!="nostandard" {
			local model "fixed"
		}

		if "`model'" == "" & "`measure'"=="nostandard" {
			local model "fixedi"
		}

		if "`model'"=="random" | "`model'"=="randomi" | "`model'"=="bivariate" {
			if "`tausq'"=="" & "`measure'"!="ss" {
				local tausq = 0
				di in green "Warning: tausq has been assumed to be 0 as it has not been specified by the user"
			}
			if "`tausq'"=="" & "`measure'"=="ss" { 
				local tausq_sens = 0
				local tausq_spec = 0
				di in green "Warning: tausq has been assumed to be 0 for both sensitivity and specificity as it has not been specified by the user"
			}
		}  
		  
		if "`dist'" == "" & ("`model'"=="random" | "`model'"=="randomi") {
			local dist "t"
		}

		if "`dist'"=="" & ("`model'"=="fixed" | "`model'"=="fixedi" | "`model'"=="peto" | "`model'"=="bivariate") {
			local dist "normal"
		}	 


		*** Check user hasn't specified options that don't exist ***
		if ("`model'"!="fixed" & "`model'"!="fixedi" & "`model'"!="random" & "`model'"!="randomi" & "`model'"!="bivariate") {
			di as err "Unknown model specified"
			exit 198
		}

		if ("`type'"!="clinical" & "`type'"!="diagnostic") {
			di as err "Unknown type specified"
			exit 198
		}

		if ("`measure'"!="or" & "`measure'"!="rr" & "`measure'"!="rd" & "`measure'"!="nostandard" & "`measure'"!="dor" & "`measure'"!="ss") {
			di as err "Unknown measure specified"
			exit 198
		}


		/* Count number of estimates specified in numlist variables to determine if using sensitivity and specificity */
		local nes : word count `es'
		if `nes' > 1 { 
			local es_sens : word 1 of `es'
			local es_spec : word 2 of `es'
		}

		if ("`measure'"!="ss" & `nes'>1) {
			di as err "Can not specify more than one estimate unless using sensitivity and specificity as measures for a diagnostic study"
			exit 198
		}

		if ("`measure'"=="ss" & `nes'<2) {
			di as err "Must specify an estimate value for both sensitivity and specificity"
			exit 198
		}

		local nse : word count `var'
		if ("`nse'"=="1") {
			if (`var'<0) {
				di as err "Cannot specify a negative variance"
				exit 198
			}
		}
		
		if "`nse'"=="2" {
			local var_sens : word 1 of `var'
			local var_spec : word 2 of `var'
			if (`var_sens'<0 | `var_spec'<0) {
				di as err "Cannot specify a negative variance"
			}
		}


		if ("`measure'"!="ss" & `nse'==2) {
			di as err "Can not specify more than one variance estimate unless using sensitivity and specificity as measures for a diagnostic study"
			exit 198
		}

		if ("`measure'" == "ss" & `nse'<2) {
			di as err "Must specify an variance value for both sensitivity and specificity"
			exit 198
		}

		if "`tausq'" != "" {
			local ntau : word count `tausq'
			if `ntau' > 1 {
				local tausq_sens : word 1 of `tausq'
				local tausq_spec : word 2 of `tausq'
			}

			if "`measure'"!="ss" & `ntau'>1 {
				di as err "Can not specify more than one tausq value unless using sensitivity and specificity as measures for a diagnostic study"
				exit 198
			}

			if ("`measure'"=="ss" & `ntau'<2) {
				di as err "Must specify an tausq value for both sensitivity and specificity"
				exit 198
			}
		}  

		if "`type'"=="clinical" & ("`measure'"=="dor" | "`measure'"=="ss") {
			di as err "Can only use DOR or sensitivity and specificity when simulating a diagnostic study"
			exit 198
		}

		if "`type'"=="diagnostic" & ("`measure'"=="or" | "`measure'"=="rr" | "`measure'"=="rd" | "`measure'"=="nostandard") {
			di as err "Can only use DOR or sensitivity and specificity when simulating a diagnostic study"
			exit 198
		}

		if "`type'"=="clinical" & "`model'"=="bivariate" {
			di as err "Can only use the bivariate model when simulating a diagnostic study using sensitivity and specificity"
			exit 198
		}

		if "`dist'"=="t" & ("`model'"=="fixed" | "`model'"=="fixedi" | "`model'"=="peto" | "`model'"=="bivariate") {
			di as err "Can only use the t-distribution to sample a new study when using the random or randomi models"
			exit 198
		}

		local number = _N
		if "`dist'"=="t" & `number'<3 {
			di as err "Can only use the t-distribution when there are 3 or more studies in the current dataset"
			exit 198 
		}

		if "`model'"=="peto" & ("`measure'"=="rr" | "`measure'"=="rd" | "`measure'"=="nostandard" | "`measure'"=="ss") {
			di as err "The Peto method can only be used with OR or DOR"
			exit 198
		}

		if "`model'"=="bivariate" & "`corr'"=="0" {
			di in green "Warning: correlation between logit(sensitivity) and logit(specificity) has been set to 0"
		}
		
	//===============================================================================================================================================================//
	// Prep 

	preserve

		tokenize `varlist'

		qui sum `1', meanonly
		if `r(N)'==0 {
			di as err "Current data set not found"
			exit 198
		}
		qui sum `2', meanonly
		if r(N)==0 {
			di as err "Current data set not found"
			exit 198
		}
		qui sum `3', meanonly
		if r(N)==0 {
			di as err "Current data set not found"
			exit 198
		}
		qui sum `4', meanonly
		if r(N)==0 {
			di as err "Current data set not found"
			exit 198
		}

		if "`type'" == "clinical" {
			if  "`6'"=="" & "`measure'" == "" {
				local measure "rr"
			}
			else if "`6'"!="" & "`measure'" == "" {
				local measure "nostandard"
			}
		}
		 
		if "`type'" == "diagnostic" & "`measure'" == "" {
			local measure = "ss"
		}  

		if "`6'"!="" & "`measure'"!= "nostandard" {
			di as err "Can only input 6 values when using nostandard as measure"
			exit 198
		}
	
		/* continuity correction to studies with no events */
		if "`type'"=="clinical" {
			if "`p'"=="0" & "`6'"=="" {    
				tempvar h t p1
				quietly {
					gen `h'=`3'
					gen `t'=`3'+`4'
					replace `t' = `t' + 1 if `h'==0 
					recode `h' 0 = 0.5
					gen `p1' = `h' / `t'
					sum `p1', meanonly
					local p = `r(mean)'
					global p = `p'
				}
			}
		}

		if "`type'"=="diagnostic" {
			if "`p'"=="0" {
				quietly {
					tempvar h t p1
					gen `h' = `1'
					gen `t' = `1'+`2'
					replace `t' = `t' + 1 if `h'==0 
					recode `h' 0 = 0.5
					gen `p1' = `h'/`t'
					sum `p1', meanonly
					local p = `r(mean)'
					global p = `p'
				}
			}
		}

		if "`dist'"=="t" {
			*** Count the degrees of freedom for the t-distribution. *** 
			qui sum `1' if `1'!=., meanonly
			local N = `r(N)'
			local df = `N'-2
			if `N'<3 {
				di as err "Not enough studies to accurately estimate the predictive distribution under the random effects assumption (need 3 or more studies)"
				exit 198
			}
		}

	/*** Postfile declares the filename of a new Stata dataset "temppow". ***/
	/*** "Samp" will contain new study results from each simulation.      ***/

		tempname samp								
		postfile `samp' `varlist' using temppow, replace

		/*** Simulate new clinical study ***/
		if "`type'" == "clinical" {

			/*** Calculate the average mean difference and SD in the control group ***/
			if "`6'"!="" {
				qui su `5', meanonly
				local meanc = `r(mean)'
				global meanc = `meanc'
				qui su `6', meanonly
				local stdevc = `r(mean)'
				global stdevc = `stdevc'
			}

			forvalues i = 1/`studies' {

				*** Clear the data memory ***

				drop _all

				*** Create a local macro for the standard error depending on ***
				*** whether the analysis is fixed effect or random effect    ***

				if "`model'" == "random" | "`model'" == "randomi" {
					local std_err = sqrt(`tausq' + (`var'))
				}
				else {
					local std_err = sqrt(`var')
				}


				*** Sample from either the t-distribution or the normal distribution ***
				*** Create a local macro called mu.  Sample from the Normal/t    ***
				*** distribution and calculate the resulting estimate.           ***
				*** If measure is on log scale (OR/RR) then exponentiate result	 ***

				if "`dist'"=="normal" {
					local rnormdraw = rnormal(0,`std_err')
					if "`measure'" == "or" | "`measure'" == "rr" {	    
						local mu = exp(`es' + `rnormdraw')
					}
					else {
						local mu = (`es' + `rnormdraw')
					}
				}
				else if "`dist'"=="t" {
					local rand=invttail(`df', runiform())
					if "`measure'" == "or" | "`measure'" == "rr" {
						local mu = exp(`es' + (`std_err'*`rand'))
					}
					else{
						local mu = `es' + (`std_err'*`rand')
					}
				}

				*** Set the number of observations in the dataset to be the          ***
				*** number of patients in the control group (defined in program call)***

				qui set obs `n'	

				*** BINARY DATA - when `6' is empty					             ***
				*** Randomly sample from the binomial distribution N=n, Prob=p   ***
				*** xb=1 for event, xb=0 for no event                            ***

				if "`6'" == "" {
					qui gen byte xb = rbinomial(1,`p')
				}
				*** CONTINUOUS DATA - when `6' is populated			             ***
				*** Randomly sample from the normal distribution 		         ***
				else if "`6'" != "" {
					qui drawnorm xb, n(`n') means(`meanc') sds(`stdevc')
				}

				*** BINARY DATA								                      ***
				*** Create a local macro called ec counting the number of events. ***
				*** ec represents the number of events in the control group of    ***
				*** the new study.							                      ***

				if "`6'" == "" {
					qui count if xb==1
					local ec=`r(N)'
				}
				*** CONTINUOUS DATA 							                  ***
				*** Create local macros recording the mean and standard deviation ***
				*** for the simulated data						                  ***
				else if "`6'" != "" {
					qui summ xb
					local mcn=`r(mean)'
					local sdcn=`r(sd)'
				}

				*** delete the xb variable   ***
				drop xb

				*** Estimate the number of events in the treatment group     ***
				*** save the result in a local macro called q or meant       ***
				*** This calculation varies depending on the outcome measure ***

				if "`measure'" == "rr" {
					local q=`p'*`mu'
				}
				else if "`measure'" == "or" {
					local q = (`mu'*`p'/(1-`p'))/(1+(`mu'*`p'/(1-`p')))
				}
				else if "`measure'" == "rd" {
					local q=`p'-`mu'
				}
				else if "`measure'"=="nostandard" {
					local meant=`mcn' + `mu'
				}

				*** Calculate the number of patients in the treatment group        ***

				local m=`n'*`r'

				*** Set the number of observations in the dataset to be the     ***
				*** number of patients in the treatment group 				    ***

				qui drop _all
				qui set obs `m'

				*** BINARY DATA 									               ***
				*** Randomly sample from the binomial distribution N=m, Prob=q     ***
				*** Count the number of events and save in a local macro called et ***    

				if "`6'"=="" {
					qui gen byte xb = rbinomial(1,`q')
					qui count if xb==1	
					local et=r(N)
				}

				*** CONTINUOUS DATA								                   ***
				*** Randomly sample from the normal distribution       	           ***
				*** Assume standard deviation is equal in both groups			   ***
				*** Save results into local macros						           ***

				else if "`6'" != "" {
					qui drawnorm xb, n(`m') means(`meant') sds(`stdevc')
					qui summ xb
					local mtn=r(mean)
					local sdtn=r(sd)
				}

				*** BINARY DATA 									                ***
				*** Create local macros calles net nec containing the number of     ***
				*** patients who did not have an event in the treatment and control ***
				*** groups of the new study									        ***

				if "`6'" == "" {
					local nec=`n'-`ec'									
					local net=`m'-`et'
				}

				*** Add the local macros to buff and close the posting to buff ***
				*** This data will be saved in a dataset called temppow        ***

				if "`6'" == "" {
					qui post `samp' (`et') (`net') (`ec') (`nec') 
				}

				else if "`6'" != "" {
					qui post `samp' (`m') (`mtn') (`sdtn') (`n') (`mcn') (`sdcn') 
				}
			}
		}

		/*** Simulate new diagnostic study ***/
		if "`type'" == "diagnostic" {

			if "`model'"=="bivariate" & "measure'"=="dor" {
				di as err "Can only use sensitivity and specificity with bivariate model"
				exit 198
			}

			forvalues i = 1/`studies' {

				*** Clear the data memory *** 
				drop _all

				*** Create local macros for when using ss as measure of accuracy. ***

				if "`measure'"== "ss" {

					if "`model'"=="bivariate" & "`dist'"=="t" {
						di as err "Can not use t-distribution to sample a new study using bivariate meta-analysis"
						exit 198
					}

					*** Create local macros depending on type of model (fixed/random/bivariate) and type of distribution (normal/t). ***
					if "`dist'" == "t" {
						local std_err_sens = sqrt(`tausq_sens' + `var_sens')
						local std_err_spec = sqrt(`tausq_spec' + `var_spec')
						*** Sample from the t-distribution. ***
						local rand = invttail(`df', runiform())
						local sens = invlogit(`es_sens' + (`std_err_sens'*`rand'))
						local spec = invlogit(`es_spec' + (`std_err_spec'*`rand'))
					} 
					else if "`dist'" == "normal" {

						*** Specify the matrix for estimates of sens and spec. ***
						matrix m = (`es_sens', `es_spec')

						if "`model'"=="fixed" | "`model'"=="fixedi" {
							local var_sens_new = `var_sens'
							local var_spec_new = `var_spec'
						}
						else {		  
							local var_sens_new = `var_sens'+`tausq_sens'
							local var_spec_new = `var_spec'+`tausq_spec'		
						}

						*** Specify the variance-covariance matrix for sens and spec. ***

						matrix C = (1, `corr', 1)
						local sd1 = sqrt(`var_sens_new')
						local sd2 = sqrt(`var_spec_new')
						matrix sd = (`sd1', `sd2')

						*** Sample from the multivariate normal distribution. ***
						qui drawnorm logsens logspec, n(`n') means(m) corr(C) sd(sd) cstorage(lower) 
						local sens=invlogit(logsens)
						local spec=invlogit(logspec)

					}

					*** Set the number of obs to be the number of diseased patients (n). ***	

					qui set obs `n'

					*** Randomly sample from the binomial distribution N=n, Prob=sens. ***
					*** If xb=1 then TP result, if xb=0 then FN result.                ***

					qui gen byte xb = rbinomial(1,`sens')

					*** Create a local macro called rtp counting the number of TP. ***

					qui count if xb==1
					local rtp=r(N)

					drop xb

					*** Calculate the number of healthy patients. ***

					local m=`n'*`r'

					qui drop _all

					*** Set the number of obs to be the number of healthy patients (m). ***

					qui set obs `m'

					*** Randomly sample from the binomial distribution N=m, Prob=spec. ***
					*** If xb=1 then TN result, if xb=0 then FP result.                ***

					qui gen byte xb = rbinomial(1,`spec')

					*** Create a local macro called rtn counting the number of TN. ***

					qui count if xb==1	
					local rtn=r(N)

					*** Create local macros containing number of FN and FP test results. ***

					local rfn=`n'-`rtp'									
					local rfp=`m'-`rtn'
				}
				else if "`measure'"=="dor" { 

					if "`model'" == "random" | "`model'" == "randomi" {
						local std_err = sqrt(`tausq' + (`var'))
					}
					else {
						local std_err = sqrt(`var')
					}

					if "`dist'" == "t" {
						local rand=invttail(`df', runiform())
						local dor = exp(`es' + (`std_err'*`rand'))
					}
					else if "`dist'" == "normal" {
						qui drawnorm logdor, n(`n') means(`es') sds(`std_err')
						local dor=exp(logdor)
					}

					*** Set the number of obs to be the number of positive test results (n). ***

					qui set obs `n'	

					*** Randomly sample from the binomial distribution N=n, Prob=p. ***

					qui gen byte xb = rbinomial(1,`p')
					
					*** Create a local macro called rtp counting the number of diseased patients. ***
					***If xb=0 then patient is healthy, if xb=1 then patient is diseased.        ***

					qui count if xb==1
					local rtp=r(N)

					drop xb

					*** Calculate probability of being diseased given a negative result ***
					*** using pp and dor estimate.                                      ***

					local q = (`p'/(1-`p'))/(`dor'+(`p'/(1-`p')))

					*** Calculate the number of patients with negative test results. ***

					local m = `n'*`r'

					qui drop _all

					*** Set the number of obs to be the number of negative test results (m). ***

					qui set obs `m'

					*** Randomly sample from the binomial distribution N=m, Prob=q. ***

					qui gen byte xb = rbinomial(1,`q')

					*** Create a local macro called rfn counting the number of diseased patients. ***
					***If xb=0 then patient is healthy, if xb=1 then patient is diseased.        ***

					qui count if xb==1	
					local rfn = `r(N)'

					*** Create local macros containing number of FN and FP test results. ***

					local rfp=`n'-`rtp'									
					local rtn=`m'-`rfn'
					
				}

				*** Add a continuity correction to simulated data set if any values are 0. ***	
				local zeros = (`rtp'==0 | `rfp'==0 | `rfn'==0 | `rtn'==0 )
				if `zeros'==1 {
					local rtp = `rtp' + 0.5
					local rfp = `rfp' + 0.5 
					local rfn = `rfn' + 0.5 
					local rtn = `rtn' + 0.5 
				}	 

				qui post `samp' (`rtp') (`rfp') (`rfn') (`rtn')  
			}	
		}
		
	/* Close postfile temppow */
	qui postclose `samp'
	restore
	local dir `c(pwd)'
	display in green "New study/studies simulated are saved in file called `dir'\temppow"

end
