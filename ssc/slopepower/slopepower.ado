*! version 2.0	26March2020
*! Stephen Nash
*! Katy Morgan	katy.morgan@lshtm.ac.uk
*! Amy Mulick	amy.mulick@lshtm.ac.uk

/*
DESCRIPTION
Sample size and power calculator for slope outcomes using a linear mixed model on 
data in memory for estimation of key parameters.

slopepower performs a sample size or power calculation for a proposed randomised 
clinical trial, based partly upon data in Stata’s memory and partly on user 
input. A linear mixed model is run (using mixed) on the data in memory to 
estimate a plausible treatment effect and its variance; the remaining parameters
are specified by the user. The data should come from an observational study or 
a similar clinical trial and contain repeated measurements of the outcome in 
long format.

The data in memory will not be altered by this program. 
*/
cap prog drop slopepower
program define slopepower , rclass
	version 13.0 // Due to use of the -mixed- command, which was introduced in v13
	syntax varname(max=1) [if], SUBJect(varname) TIMe(varname) SCHEDule(numlist ascending integer >=1) ///
		[obs NOCONTrols rct  CASEcon(varname) TReat(varname) SCAle(real 1) ITERate(integer 16000) Alpha(real 0.05) ///
		 POWer(string) n(string) EFFectiveness(string) DROPouts(numlist >=0) noCONTVar USETrt]

		preserve // We're going to change the data - drop rows and create new vars
			capture keep `if' // Get rid of un-needed obs now

			*************************************
			**
			** SYNTAX SECTION - CHECK THE PARAMETERS and CREATE SOME LOCALS
			**
			*************************************
			quietly {
				marksample touse
				local outcome `varlist' // Just to make the code easier to understand

				* Check that we have at least _some_ data
				if _N <1 {
					dis as error "No observations"
					exit 2000
				}
				* CHECK THE OPTIONS ARE VALID
				*
				* MODEL: Check the combinations are valid and assign 1, 2, or 3 to the local model
				if "`obs'"!="" & "`rct'"!="" {
					dis as error "You cannot specify both obs and rct"
					exit 198
				}
				if "`obs'"=="" & "`rct'"=="" {
					dis as error "No model specified: please specify obs or rct"
					exit 198
				}
				if "`obs'"!="" {
					if "`nocontrols'" == "" local model 1
						else local model 2
				}
				else if "`rct'"!="" & "`nocontrols'"=="" local model 3
					else {
						dis as error "You cannot specify nocontrols and rct "
						exit 198
					}
				*
				* ALPHA: Should be between 0 and 1
				if `alpha'<=0 | `alpha'>=1 {
					dis as error "Alpha must be a number greater than 0 and less than 1"
					exit 198
				}
				*POWER AND N
					* Must specify one of power or N: 4 possible cases...
					* 1. 1. Both power an n specified - error
						if "`power'"!="" & "`n'"!="" {
							display as error "Only one of power and n may be specified, not both"
							exit 184
							}
					* 2. Power is specified, n is missing - okay - we'll calculate SAMPLE SIZE (N)
						if "`power'"!="" & "`n'"=="" {
							local given_power=real("`power'")
							if missing(`given_power') { // ...but power isn't a number
								dis as error "Power must be a number greater than 0 and less than 1"
								exit 198
							}
							local power_or_n power
						}
					* 3. Power is absent, n is specified - okay - we'll calculate POWER
						if "`power'"=="" & "`n'"!="" { // 
							local given_n=floor(real("`n'"))
							if missing(`given_n') { // ...but n isn't a number
								dis as error "n must be a numerical value"
								exit 198
							}
							if `given_n' != `n' { // The floor of n must be the same as n... ie n cannot be fractional
								dis as error "n must be a whole number greater than or equal to 2"
								exit 198
							}
							if `given_n' < 2 { // N must be at least 2
								dis as error "n must be at least 2"
								exit 198
							}
							local n = ceil(`given_n')
							local power_or_n n
						}
					* 4. Both power and n absent: okay, use default value for power - we'll calculate SAMPLE SIZE (N)
						if "`power'"=="" & "`n'"=="" {
							local given_power = 0.8 // Default power is 80%
							local power_or_n power
						}
				* Check values
					if "`power_or_n'"=="power" { // Power is specified - we already know it's a number.
						if `given_power'>=1 {
							dis as error "Power must be a value strictly less than 1"
							exit 198
						}
						if `given_power'<=0 {
							dis as error "Power must be a value greater than 0"
							exit 198
						}
					}
					if "`power_or_n'" == "n" { // N is specified - we already know it's a number
						* Make sure it's even, or round down
						local actual_n = 2 * floor(`given_n' / 2)
						if `given_n'<2 {
							dis as error "n must be a number greater or equal to 2"
							exit 198
						}
					}
				*
				* CASECON
					if "`casecon'"!="" & `model'!=1 {
						dis as error "WARNING: casecon can only be specified with observational data which has both cases and controls. It will be ignored."
					}
					* If model is 1, then must have a casecontrol variable
						if (`model'==1) & ("`casecon'"=="") {
								display as error _n "You must provide a case-control variable for this model choice, or specify the nocont option"
								exit 198
						}
						if (`model'==1) {
							* First, check that casecon has exactly two levels
								tab `casecon'
								if r(r)!=2 {
									dis as error "Case-control variable (casecon) must have exactly two levels"
									exit 198
								}
							* Check that it's a numeric variable
								capture confirm numeric variable `casecon'
								if _rc!=0 {
									dis as error "Case-control variable (casecon) must be numeric"
									exit 198
							}
							* And that it's coded 0/1
							sum `casecon'
							if `r(min)' !=0 | `r(max)'!=1 {
								dis as error "Case-control variable (casecon) variable must be coded 0/1"
								exit 198
							}
						}
				*
				* EFFECTIVENESS AND USETRT
				* Check which combination of effectiveness and usetrt have been specified
				* First, check usetrt is only specified with Model 3
				if "`usetrt'"!="" & `model'!=3 {
					dis as error "WARNING: The usetrt option can only be specified with RCT data. It will be ignored here."
					local usetrt
				}
					* User cannot specify both usetrt and effectiveness 
					* If usetrt is not specified effectiveness is as the user inputs, 
					* Unless not specified, in which case default is used (25%)
						if "`usetrt'"!="" & "`effectiveness'"!="" { // Both specified
							dis as error "Only one of usetrt and effectiveness may be specified, not both"
							exit 184
						}
						if "`usetrt'"=="" & "`effectiveness'"=="" local effectiveness 0.25 // Both missing; default effectiveness is 0.25
						* Now check effectivenes is a number >0 and <= 1
							if "`effectiveness'"!="" { // Effectiveness is specified
								capture confirm number `effectiveness'
								if _rc!=0 {
									dis as error "Effectiveness must be a number greater than 0 and less than or equal to 1"
									exit 198
								}
								* So eff is specified and it's a number
								if `effectiveness' > 1 {
									dis as error "Effectiveness must be less than or equal 1"
									exit 198
								}
								if `effectiveness' <=0 {
									dis as error "Effectiveness must be strictly greater than 0"
									exit 198
								}
							} // If statement "eff is specified"
				*
				* TREAT
				* If model is 3 (RCT), then must have a treatment variable
					if (`model'!=3) & ("`treat'"!="") {
						dis as error "Treatment can only be specified with RCT data`. Treatment variable will be ignored."
						}
					if (`model'==3) & ("`treat'"=="") {
							display as error _n "You must provide a treatment variable for this model choice"
							exit 198
						}
					* Check that we have obs in both arms, and that treatment has just two levels
					if (`model'==3) & ("`treat'"!="") {
						tab `treat'
						if r(r)!=2 {
							dis as error "Treatment variable must have exactly two levels"
							exit 198
						}
						* Check that it's a numeric variable
						capture confirm numeric variable `treat'
						if _rc!=0 {
							dis as error "Treatment must be a numeric variable"
							exit 198
						}
						* And that it's coded 0/1
						sum `treat'
						if `r(min)' !=0 | `r(max)'!=1 {
							dis as error "Treatment must be coded 0/1"
							exit 198
						}
					}
				*
				* SCALE
					if `scale' <= 0 {
						dis as error "Scale must be a positive number"
						exit 198
					}
				*
				* NOCONTVAR
				* is only compatible with Model 1
					if "`contvar'"!="" & `model'!=1 {
						dis as error "WARNING: nocontvar can only be set for observational data with controls. This option will be ignored."
					}
				*
				* SCHEDULE
				* Length of schedule list:
					local sched_length = 0
					foreach i of numlist `schedule' {
						local sched_length = `sched_length ' + 1
					}
				* Decant the schedule numlist into locals
					local j = 1 // counter - position number
					foreach i of numlist `schedule' {
						local sched`j++' = `i'
					}
				* Get a nice schedule string with commas for output
					foreach i of numlist `schedule' {
						local sched_string `"`sched_string'`i', "' // Adds commas to the numlist, for use in output
					}
					* Remove the last comma from the schedule string
						local ss = strlen("`sched_string'") - 2
						local sched_string = substr("`sched_string'", 1, `ss')
				*
				* DROPOUTS
				* Is there a dropout list specified?
					local drop_yes = 0
					if "`dropouts'"!="" local drop_yes = 1
				* Decant dropout numlist into locals and calculate people who attend all visits
					local dfrac_complete = 1 // The proportion attending all visits - one unless dropouts specified
					if `drop_yes'==1 {
						local j = 1 // counter - position number
						foreach fr of numlist `dropouts' {
							local dfrac`sched`j'' = `fr'
							local j = `j' + 1
							local dfrac_complete = `dfrac_complete' - `fr'
						}
					* Check the drop matrix adds up to less than 100%
						if `dfrac_complete' < 0 {
							display as error _n "Dropouts cannot exceed 100%"
							exit 198
						}
					* Drop matrix must be same length as Schedule matrix
						* Length of dropout list
						local drop_length = 0
						foreach i of numlist `dropouts' {
							local drop_length = `drop_length ' + 1
						}
						* Is this equal to schedule matrix?
						if `sched_length' != `drop_length' {
							dis as error _n "Dropout list must correspond with visit schedule"
							exit 198
						}
						* Get a nice schedule string with commas for output
							local j = 0 // counter - position in schedule list
							local sched_string ""
							foreach i of numlist `schedule' {
								if `dfrac`i'' != 0 local sched_string `"`sched_string'`i' (0`dfrac`i''), "' // Adds commas to the numlist, for use in output
									else local sched_string `"`sched_string'`i' (0), "' // Adds commas to the numlist, for use in output
							}
							* Remove the last comma from the schedule string
								local ss = strlen("`sched_string'") - 2
								local sched_string = substr("`sched_string'", 1, `ss')
					}
			} // End quietly
			
			*************************************
			**
			** DATA SECTION
			**
			*************************************
			quietly {
				tempname nmeas first_time
				* Drop if outside the sample to use - shouldn't be necessary
					drop if !`touse'
				* Rescale the data
					replace `time' = `time' / `scale'
				* Drop if no outcome variable - the model will ignore anyway but safest this way
					drop if missing(`outcome')

				* Make the time var start at 0
					gen `first_time' = .
					bysort `subject' (`time') : replace `first_time' = `time'[1]
					bysort `subject' : replace `time' = `time' - `first_time'
					sum `first_time'
					if (r(mean)!=0) | (r(sd)!=0) dis as error "WARNING: time variable did not start at zero for all participants. It has been adjusted to provide a common baseline time in the sample size modelling"

				* Make dummy variables for cases and controls
				if (`model'==1) {
					tempname case control timecase timecontrol
					drop if missing(`casecon')
					gen `case' = (`casecon'!=0)
					gen `control' = (`casecon'==0)
					gen `timecase' = `time'*`case'
					gen `timecontrol' = `time'*`control'
				}

				* If model 3 (RCT), make a placebo var from the treat var
					if (`model'==3) {
						tempname placebo
						drop if missing(`treat')
						gen `placebo' = (`treat'==0)
					}
			} // End quietly

			*************************************
			**
			** MODEL SECTION
			**
			*************************************
			quietly {			
				tempname mbeta slope0 slope2 var_slope var_int cov_slopeint var_res var_visit n_in_model people_in_model observed_difference ngroups tte
				
				*************************
				** MODEL 1 - Cases and controls
				*************************
				if `model'==1 {
					if "`contvar'"=="" { // Controls are allowed a variance parameter
						capture mixed `outcome' `case'##c.`time' , `noconsoption' ///
							|| `subject': `timecase' `case', cov(uns) nocons ///
							|| `subject': `timecontrol' `control', cov(uns) nocons ///
							res(ind, by(`case')) reml iterate(`iterate')
						if _rc!=0 {
							dis as error "Model failure. Try using the nocontvar option, or see error code (below)."
							exit _rc
						}
						if e(converged)==0 {
							dis as error "Model did not converge"
							exit 430
						}
						matrix `mbeta'=e(b) // A 1x14 matrix
						scalar `n_in_model' = e(N)
						matrix `ngroups' = e(N_g)
						scalar `people_in_model' = `ngroups'[1,1]
						scalar `slope0'=`mbeta'[1,3] // fixed time - ie time slope for controls
						scalar `slope2'=`mbeta'[1,3] + `mbeta'[1,5] // time + case#time interaction - ie time slope for cases
						scalar `observed_difference' = `slope2' - `slope0'
						scalar `tte' = -1 * `observed_difference' * `effectiveness'
						scalar `var_slope'=(exp(`mbeta'[1,7]))^2 // Variance of time for  cases
						scalar `var_int'=(exp(`mbeta'[1,8]))^2 // Variance of casepos - var of intercept for CASES
						scalar `cov_slopeint'=tanh(`mbeta'[1,9])*exp(`mbeta'[1,7])*exp(`mbeta'[1,8]) // Covariance of time and casepos = b[1,10] + exp2(b8) + exp2(b9)
						scalar `var_res'=(exp(`mbeta'[1,13]+`mbeta'[1,14]))^2 // Residual variance for cases
					} // end of nested if (for control variance)
					else { // Drop the variance parameter for controls
						capture mixed `outcome' `case'##c.`time' /// 
							|| `subject': `timecase' `case', cov(uns) nocons ///
							|| `subject': `control', cov(id) nocons ///
							res(ind, by(`case')) reml iterate(`iterate') coeflegend
						if _rc!=0 {
							dis as error "Model failure. See error code (below)."
							exit _rc
						}
						if e(converged)==0 {
							dis as error "Model did not converge"
							exit 430
						}
						matrix `mbeta'=e(b) // A 1x12 matrix
						scalar `n_in_model' = e(N)
						matrix `ngroups' = e(N_g)
						scalar `people_in_model' = `ngroups'[1,1]
						scalar `slope0'=`mbeta'[1,3] // fixed time - ie time slope for controls
						scalar `slope2'=`mbeta'[1,3] + `mbeta'[1,5] // time + case#time interaction - ie time slope for cases
						scalar `observed_difference' = `slope2' - `slope0'
						scalar `tte' = -1 * `observed_difference' * `effectiveness'
						scalar `var_slope'=(exp(`mbeta'[1,7]))^2 // Variance of time for cases
						scalar `var_int'=(exp(`mbeta'[1,8]))^2 // Variance of casepos - var of intercept for CASES
						scalar `cov_slopeint'=tanh(`mbeta'[1,9])*exp(`mbeta'[1,7])*exp(`mbeta'[1,8]) // Covariance of time and casepos = b[1,10] + exp2(b8) + exp2(b9)
						scalar `var_res'=(exp(`mbeta'[1,11]+`mbeta'[1,12]))^2 // Residual variance for cases
					} // end else (var param for controls)
				} // end Model 1
			
				*************************
				** 		MODEL 2 - Obs, everyone has the condition
				*************************
				else if `model'==2 { // No controls - assume we can get slope (a fraction of the way) to zero
					capture mixed `outcome' c.`time' || `subject': `time', cov(uns) reml iterate(`iterate')
						if _rc!=0 {
							dis as error "Model failure. See error code (below)."
							exit _rc
						}
						if e(converged)==0 {
							dis as error "Model did not converge"
							exit 430
						}
					matrix `mbeta'=e(b)
					scalar `n_in_model' = e(N)
					matrix `ngroups' = e(N_g)
					scalar `people_in_model' = `ngroups'[1,1]
					scalar `slope0' = 0 // For consistency with other models
					scalar `slope2'=`mbeta'[1,1]
					scalar `observed_difference' = `slope2' - `slope0'
					scalar `tte' = -1 * `observed_difference' * `effectiveness'
					scalar `var_slope'=(exp(`mbeta'[1,3]))^2 // var(time) in subject
					scalar `var_int'=(exp(`mbeta'[1,4]))^2 // var(cons) in subject
					scalar `cov_slopeint'=tanh(`mbeta'[1,5])*exp(`mbeta'[1,3])*exp(`mbeta'[1,4]) 
					scalar `var_res'=(exp(`mbeta'[1,6]))^2
					} // end Model 2

				*************************
				** 		MODEL 3 - RCT
				*************************
				else if `model'==3 {
					capture mixed `outcome' `time' `placebo'#c.`time' /// 
						|| `subject': `time', cov(uns) reml iterate(`iterate')
						if _rc!=0 {
							dis as error "Model failure. See error code (below)."
							exit _rc
						}
						if e(converged)==0 {
							dis as error "Model did not converge"
							exit 430
						}
						* Note we're using a "placebo" variable, hence
						* slope0 is slope of the TREATED (placebo==0)
						* slope2 is slope of the UNTREATED, placebo group (placebo=1)
					matrix `mbeta'=e(b) // A 1x8 matrix
					scalar `n_in_model' = e(N)
					matrix `ngroups' = e(N_g)
					scalar `people_in_model' = `ngroups'[1,1]
					scalar `slope2'=`mbeta'[1,1] + `mbeta'[1,3] // slope over time - ie time slope for placebo group
					scalar `observed_difference' = `slope2' - `mbeta'[1,1] // This is for reporting, so we need the actual value
					scalar `slope0' = 0 // Default option is to ignore the slope for treated
					if "`usetrt'"!="" { // usetrt is specified; use the treatment effect from the RCT
						scalar `slope0'=`mbeta'[1,1] // ie time slope for experimental, treated group (placebo==0)
						local effectiveness = 1
						scalar `tte' =  -1 * `observed_difference'
					 }
					 else scalar `tte' = -1 * `slope2' * `effectiveness'
					scalar `var_slope'=(exp(`mbeta'[1,5]))^2 // Variance of time 
					scalar `var_int'=(exp(`mbeta'[1,6]))^2 // Variance of intercept 
					scalar `cov_slopeint'=tanh(`mbeta'[1,7])*exp(`mbeta'[1,5])*exp(`mbeta'[1,6]) // Covariance of slopes and intercepts
					scalar `var_res'=(exp(`mbeta'[1,8]))^2 // Residual variance
				} // end Model 3
			} // end of quitely

			*************************************
			**
			** MATRIX SECTION
			**
			*************************************
			quietly {
				tempname V VSTAR X DSTAR XSTAR F1STAR FSTAR visit_matrix COV
				foreach i of numlist `schedule' {
					tempname DROP`i' DROP`i'STAR DROP
				}
				* First, need to make a visit schedule matrix
				* from the user inputted visit schedule, which is just a numlist...
	
				* What's the biggest number (=number of timepoints), and how many are in the list? (vvv)
					local vvv = 0 // This will count the elements of the numlist
					foreach i of numlist `schedule' { // We want: (i) timepoint of last visit (ii) number of visits and (iii) a nice string of visit times
						local tpoints = `i' + 1
						local vvv = `vvv' + 1
					}
				* Add one to the number in the list to get the number of rows we need visit_matrix to have
					local vplus1 = `vvv' + 1
				* Make a `vplus1' x `tpoints' matrix, all zeros
					matrix `visit_matrix' = J(`vplus1', `tpoints', 0)
				* Make the first row 1, 0, 0... 
					matrix `visit_matrix'[1,1] = 1
				* Fill in the (i+1,j+1) element (=1) where j is the value of the ith number
					local i = 2 // We need the +1's because our matric starts with timepoint 0
					foreach j of numlist `schedule' {
						local jjj = `j' + 1
						matrix `visit_matrix'[`i', `jjj'] = 1
						local i = `i' + 1
					}

				* These scalars make a matrix
					local tpminus1 = `tpoints' - 1
				* Do diagonal first
					forvalues i=1/`tpoints' {
						local v_`i'_`i' = (`var_int')+(`var_res')+(((`i'-1)^2)*(`var_slope'))+ (2*(`i'-1)*`cov_slopeint')
					}
				* Then the bottom left corner
					forvalues j=1/`tpminus1' {
						local jplus1 = `j' + 1
						forvalues i=`jplus1' / `tpoints' {
							local v_`i'_`j' = (`var_int') + ( (`j'-1)*(`i'-1)*`var_slope') + ( (`j'-1+`i'-1)*`cov_slopeint' )
						} // i
					} // j
				* Now fill in the top right corner by symmetry
					forvalues i=1 / `tpoints' {
						local iplus1 = `i' + 1
						forvalues j=`iplus1' / `tpoints' {
							local v_`i'_`j' = `v_`j'_`i''
						}
					}
				* This matrix V is constructed in a loop using the above values
					matrix `V' = J(`tpoints', `tpoints', 0) // create a blank matrix of the right size
					forvalues i=1/`tpoints' {
						forvalues j=1 / `tpoints' {
							matrix `V'[`i', `j'] = `v_`i'_`j''	
						} // i
					} // j

				* Matrix VSTAR
					* Define bottom-left and top-right matrices (COV)
						matrix `COV' = 0*I(`tpoints') // Zeroes everywhere in a square matrix
					* Vstar
					matrix `VSTAR'=(`V',`COV' \ `COV',`V')

				* Matrix X
					matrix `X' = J(`tpoints', 2, 1)
					forvalues i=1/`tpoints' {
						matrix `X'[`i', 2] = `i' - 1
					}
					
				* Make dropout matrices: one for each visit (dropping out BEFORE that visit)
				if `drop_yes'==1 {
					* First, make an indicator matrix
					* Start making it the right size, all zeros, then add 1's...
					local j = 1 // row counter = position in schedule numlist
					matrix `DROP`sched1'' = J(1,`tpoints', 0)
					matrix `DROP`sched1''[1,1] = 1
					forvalues i=2/`vvv' {
						local lag = `i' - 1
						matrix `DROP`sched`i''' = `DROP`sched`lag''' \ J(1, `tpoints', 0) // Add one row at a time
						* Get correct column pos'n for the 1
							local ccc = `sched`lag'' + 1
						matrix `DROP`sched`i'''[`i',`ccc'] = 1
					}
					* Matrix DROPSTAR
					foreach nnn of numlist `schedule' {
						matrix `DROP`nnn'STAR'=(`DROP`nnn'', 0*`DROP`nnn'' \ 0*`DROP`nnn'',`DROP`nnn'')
					}
				} // End if drop_yes

				* Make matrix DSTAR
					matrix `DSTAR'=(`visit_matrix',0*`visit_matrix' \ 0*`visit_matrix',`visit_matrix')

				* Make matrix XSTAR
					matrix `XSTAR' = J(2*`tpoints', 3, 1) // So the first colum is done - all 1s
					forvalues j=1/`tpoints' { // Top of the second column
						matrix `XSTAR'[`j', 2] = `j' - 1
					}
					local aa = `tpoints' + 1
					local bb = `tpoints' * 2
					forvalues j=`aa'/`bb' { // Bottom half of second column
						matrix `XSTAR'[`j', 2] = `j' - 1 - `tpoints'
					}
					forvalues j=1/`tpoints' { // Top of the third column
						matrix `XSTAR'[`j', 3] = 0
					}
					forvalues j=`aa'/`bb' { // Bottom half of third column
						matrix `XSTAR'[`j', 3] = `j' - `tpoints' - 1
					}

					* Matrices FDROPiSTAR
					if `drop_yes'==1 {
						foreach nnn of numlist `schedule' {
							if `nnn'==`sched1' continue
							tempname FDROP`nnn'STAR
							matrix `FDROP`nnn'STAR' = inv((`DROP`nnn'STAR'*`XSTAR')' * ///
											  inv(`DROP`nnn'STAR'*`VSTAR'*`DROP`nnn'STAR'') * ///
											  `DROP`nnn'STAR'*`XSTAR')
						}
					} //end if drop_yes

				* Matrix FSTAR
				  matrix `FSTAR' = inv((`DSTAR'*`XSTAR')'* /// That last ' is for "matrix transpose"
									  inv(`DSTAR'*`VSTAR'*`DSTAR'')* ///
									  `DSTAR'*`XSTAR')
			} // End of quietly
*


			*************************************
			**
			** CALCULATE THE POWER / SAMPLE SIZE
			**
			*************************************
			quietly {
				tempname es_slope var1 sampfactor alpha_tail sampsize sampsize_arm power z_power
					* Slope
						scalar `es_slope'=`slope2'-`slope0'
					* Main variance and effect size component
						scalar `var1' = `FSTAR'[3,3] // This is var_tte
						local part_effsize =  `es_slope' / sqrt(`var1') // use this to get an N (below)

					* Dropout variances and effect size components
					if `drop_yes'==1 {
						foreach nnn of numlist `schedule' {
							if `nnn' == `sched1' continue
							tempname var_drop_`nnn'
							scalar `var_drop_`nnn'' = `FDROP`nnn'STAR'[3,3]
							local effsize_drop`nnn' = `es_slope' / sqrt(`var_drop_`nnn'')
						} // End for
					} // end if drop_yes

					* Combine all effect size components into one overall effect size
						local eff_bit = `dfrac_complete' * (`part_effsize')^2
						if `drop_yes'==1 {
							foreach nnn of numlist `schedule' {
								if `nnn' == `sched1' continue
								local eff_bit = `eff_bit' + (`dfrac`nnn'' * (`effsize_drop`nnn'')^2)
								}
							} // end if drop_yes

					* Calculate the EFFECT SIZE
						local effsize=sign(`es_slope') * sqrt(`eff_bit')
					
					* CALCULATE THE MAIN RESULT: Either sample size or power
						if "`power_or_n'"=="power" { // Calc SAMPLE SIZE
							scalar `alpha_tail' = 1 - (0.5 * `alpha')
							scalar `sampfactor' = ( invnormal(`alpha_tail') + invnormal(`given_power'))^2
							scalar `sampsize_arm' = ceil( ( `sampfactor' / (`effsize')^2) / `effectiveness'^2)
							scalar `sampsize' = 2 * `sampsize_arm'
							scalar `power' = `given_power' // Transferring the local into the scalar...
						}
						else { // Calc POWER
							// Calc the power here
							scalar `sampsize' = `actual_n' // As specified by the user; transferring to output scalar
							scalar `sampsize_arm' = `actual_n' / 2
							scalar `z_power' = ( abs(`effsize')*`effectiveness'*sqrt(`actual_n'/2) ) - invnormal(1-`alpha'/2)
							scalar `power' = normal(`z_power')
						}
					
				if "`usetrt'"!="" local effectiveness = .

			} // close quietly

			*************************************
			**
			** OUTPUT SECTION
			**
			** Same for all models:
			**		- matrix
			**
			** Separate for each model
			**		- other return values
			**		- on-screen text
			**
			*************************************
				quietly { 
					tempname RESULTS
					mat `RESULTS' = J(1, 10 ,.)
					if `model'==1  mat colnames `RESULTS' = alpha power N N1 N2 effectiveness tte var_tte slope_cases slope_controls  // diffnames for diff models
					if `model'==2  mat colnames `RESULTS' = alpha power N N1 N2 effectiveness tte var_tte slope_cases slope_controls
					if `model'==3  mat colnames `RESULTS' = alpha power N N1 N2 effectiveness tte var_tte slope_untreated slope_treated
					mat `RESULTS'[1,1] = `alpha'
					mat `RESULTS'[1,2] = `power'
					mat `RESULTS'[1,3] = `sampsize'
					mat `RESULTS'[1,4] = `sampsize_arm'
					mat `RESULTS'[1,5] = `sampsize_arm'
					mat `RESULTS'[1,6] = `effectiveness'
					mat `RESULTS'[1,7] = `tte'
					mat `RESULTS'[1,8] = `var1'
					if `drop_yes'==1 {
						mat `RESULTS'[1,8] = `sampsize_arm' * (`tte')^2 / (invnormal(1-`alpha'/2)+invnormal(`power'))^2
					}
					mat `RESULTS'[1,9] = `slope2'
					mat `RESULTS'[1,10] = `slope0'
					if `model'==2 mat `RESULTS'[1,10] = .
					if `model'==3 & "`usetrt'"=="" mat `RESULTS'[1,10] = .
					return matrix table = `RESULTS'
				}

				*************************
				** MODEL 1 - Cases and controls
				*************************
				if `model'==1 {

					** ** ** ** ** ** ** **
					**
					** return values
							return scalar slope_controls = `slope0'
							return scalar slope_cases = `slope2'
							if `drop_yes'==1 {
								return scalar var_tte = `sampsize_arm' * (`tte')^2 / (invnormal(1-`alpha'/2)+invnormal(`power'))^2 // if there is dropout get tte variance by inverting sample size formula
							}
							else {
								return scalar var_tte = `var1'
							}
							return scalar tte = `tte' 
							return scalar effectiveness = `effectiveness'
							return scalar sampsize = `sampsize'
							return scalar fupvisits = `vvv'
							return scalar power = `power'
							return scalar alpha = `alpha'
							return scalar obs_in_model = `n_in_model'
							return scalar subjects_in_model = `people_in_model'

					** ** ** ** ** ** ** **
					**
					** on-screen text
						display as text _n "Data characteristics:"
						display as text "        number of observations in model = " as result `n_in_model'
						display as text "        number of participants in model = " as result `people_in_model'
						display as text "          observed difference in slopes = " as result %5.3f `observed_difference'
						display as text "                         slope of cases = " as result %5.3f `slope2'
						display as text "              slope of healthy controls = " as result %5.3f `slope0'
						display as text _n "Parameters for planned study:"

						if "`power_or_n'"=="power" { // Power is given, so we're calculating SAMPLE SIZE
							display as text "                                  alpha = " as result %5.3f round(`alpha', 0.001)
							display as text "                                  power = " as result %5.3f round(`power', 0.001)
							display as text "                          effectiveness = " as result %5.3f round(`effectiveness', 0.001)
							display as text "  target treatment difference in slopes = " as result %5.3f round(`tte', 0.001)
							display as text "             number of follow-up visits = " as result `vvv'
							display as text "                schedule (and dropouts) : " as result "`sched_string'"
							display as text "                                  scale = " as result `scale'
							display as text _n "  Estimated sample size:"
							display as text "                                      N = " as result `sampsize'
							display as text "                              N per arm = " as result `sampsize_arm'
						}
						else { // we're calculating POWER
							display as text "                                  alpha = " as result %5.3f round(`alpha', 0.001)
							display as text "                            specified N = " as result `given_n'
							display as text "                               actual N = " as result `actual_n'
							display as text "                              N per arm = " as result `actual_n' / 2
							display as text "                          effectiveness = " as result %5.3f round(`effectiveness', 0.001)
							display as text "  target treatment difference in slopes = " as result %5.3f round(`tte', 0.001)
							display as text "             number of follow-up visits = " as result `vvv'
							display as text "                schedule (and dropouts) = " as result "`sched_string'"
							display as text "                                  scale = " as result `scale'
							display as text "Estimated power:"
							display as text "                                  power = " as result %5.3f round(`power', 0.001)
						}
				} // end model 1

				*************************
				** MODEL 2 - Obs, everyone has the condition
				*************************
				if `model'==2 {

					** ** ** ** ** ** ** **
					**
					** return values
						return scalar slope_controls = .
						return scalar slope_cases = `slope2'
						if `drop_yes'==1 {
							return scalar var_tte = `sampsize_arm' * (`tte')^2 / (invnormal(1-`alpha'/2)+invnormal(`power'))^2 // if there is dropout get tte variance by inverting sample size formula
						}
						else {
							return scalar var_tte = `var1'
						}
						return scalar tte = `tte'
						return scalar effectiveness = `effectiveness'
						return scalar sampsize = `sampsize'
						return scalar fupvisits = `vvv'
						return scalar power = `power'
						return scalar alpha = `alpha'
						return scalar obs_in_model = `n_in_model'
						return scalar subjects_in_model = `people_in_model'


					** ** ** ** ** ** ** **
					**
					** on-screen text
						display as text _n "Data characteristics:"
						display as text "        Number of observations in model = " as result `n_in_model'
						display as text "                  Participants in model = " as result `people_in_model'
						display as text "                         Slope of cases = " as result %5.3f `slope2'
						display as text _n "Parameters for planned study:"

						if "`power_or_n'"=="power" { // Power is given, so we're calculating SAMPLE SIZE
							display as text "                                  alpha = " as result %5.3f round(`alpha', 0.001)
							display as text "                                  power = " as result %5.3f round(`power', 0.001)
							display as text "                          effectiveness = " as result %5.3f round(`effectiveness', 0.001)
							display as text "  target treatment difference in slopes = " as result %5.3f round(`tte', 0.001)
							display as text "             number of follow-up visits = " as result `vvv'
							display as text "                schedule (and dropouts) : " as result "`sched_string'"
							display as text "                                  scale = " as result `scale'
							display as text _n "  Estimated sample size:"
							display as text "                                      N = " as result `sampsize'
							display as text "                              N per arm = " as result `sampsize_arm'
						}
						else { // we're calculating POWER
							display as text "                                  alpha = " as result %5.3f round(`alpha', 0.001)
							display as text "                            specified N = " as result `given_n'
							display as text "                               actual N = " as result `actual_n'
							display as text "                              N per arm = " as result `actual_n' / 2
							display as text "                          effectiveness = " as result %5.3f round(`effectiveness', 0.001)
							display as text "  target treatment difference in slopes = " as result %5.3f round(`tte', 0.001)
							display as text "             number of follow-up visits = " as result `vvv'
							display as text "                schedule (and dropouts) = " as result "`sched_string'"
							display as text "                                  scale = " as result `scale'
							display as text "Estimated power:"
							display as text "                                  power = " as result %5.3f round(`power', 0.0001)
						}
				} // end model 2 display

				*************************
				** MODEL 3 - RCT (need to separate usetrt and effectiveness
				*************************
				if `model'==3 {

					** ** ** ** ** ** ** **
					**
					** return values
						if "`usetrt'" != "" {
							return scalar slope_treated = `slope0'
						}
						else {
							return scalar slope_treated = .
						}
						return scalar slope_untreated = `slope2'
						if `drop_yes'==1 {
							return scalar var_tte = `sampsize_arm' * (`tte')^2 / (invnormal(1-`alpha'/2)+invnormal(`power'))^2 // if there is dropout get tte variance by inverting sample size formula
						}
						else {
							return scalar var_tte = `var1'
						}
						return scalar tte = `tte'
						return scalar effectiveness = `effectiveness'
						return scalar sampsize = `sampsize'
						return scalar fupvisits = `vvv'
						return scalar power = `power'
						return scalar alpha = `alpha'
						return scalar obs_in_model = `n_in_model'
						return scalar subjects_in_model = `people_in_model'

					** ** ** ** ** ** ** **
					**
					** on-screen text
						display as text _n "Data characteristics:"
						display as text "        number of observations in model = " as result `n_in_model'
						display as text "        number of participants in model = " as result `people_in_model'
						if "`usetrt'"!="" display as text "          observed difference in slopes = " as result %5.3f `observed_difference'
						display as text "                   slope of control arm = " as result %5.3f `slope2'
						if "`usetrt'"!="" display as text "              slope of experimental arm = " as result %5.3f `slope0'
						display as text _n "Parameters for planned study:"

						if "`power_or_n'"=="power" { // Power is given, so we're calculating SAMPLE SIZE
							display as text "                                  alpha = " as result %5.3f round(`alpha', 0.001)
							display as text "                                  power = " as result %5.3f round(`power', 0.001)
							display as text "                          effectiveness = " as result %5.3f round(`effectiveness', 0.001)
							display as text "  target treatment difference in slopes = " as result %5.3f round(`tte', 0.001)
							display as text "             number of follow-up visits = " as result `vvv'
							display as text "                schedule (and dropouts) : " as result "`sched_string'"
							display as text "                                  scale = " as result `scale'
							display as text _n "  Estimated sample size:"
							display as text "                                      N = " as result `sampsize'
							display as text "                              N per arm = " as result `sampsize_arm'
						}
						else { // we're calculating POWER
							display as text "                                  alpha = " as result %5.3f round(`alpha', 0.001)
							display as text "                            specified N = " as result `given_n'
							display as text "                               actual N = " as result `actual_n'
							display as text "                              N per arm = " as result `actual_n' / 2
							display as text "                          effectiveness = " as result %5.3f round(`effectiveness', 0.001)
							display as text "  target treatment difference in slopes = " as result %5.3f round(`tte', 0.001)
							display as text "             number of follow-up visits = " as result `vvv'
							display as text "                schedule (and dropouts) = " as result "`sched_string'"
							display as text "                                  scale = " as result `scale'
							display as text "Estimated power:"
							display as text "                                  power = " as result %5.3f round(`power', 0.001)
						}
				} // close model 3
*




		 * FINAL STEP - RESTORE THE DATA BACK TO HOW WE FOUND IT
		restore

end
