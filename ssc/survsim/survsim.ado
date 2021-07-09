*! version 4.0.3 25may2020 MJC

/*
History
25may2020 version 4.0.3 - efficiency of _msm improved
						- bug fix: Stata variables in user-defined hazard functions not parsed correctly; now fixed
30mar2020 version 4.0.2 - bug fix; missing value issue when t = 0 in chq function, now fixed
						- bug fix; indexing issue occurred in varied circumstances, now fixed
29mar2020 version 4.0.1 - bug fix; error in distribution(gompertz) when specified in a hazard#() -> now fixed
						- help file edits
26mar2020 version 4.0.0 - computation time reduced by about 70% for multi-state model simulation
						- reset added to hazard#() for semi-Markov models
						- syntax changed for user-defined functions, #t now {t} for more robust parsing
						- support for general multiple timescales, including:
							- {t0} can be used in user() and tdefunction() for time of entry into initial state for associated transition
						- cr subclass removed, now part of general msm syntax
						- bug fix; variables used directly in user() with a multi-state model were not passed to Mata -> now fixed
						- bug fix; if the same variable was used in multiple hazard#()s, parsing would only pick up the first -> now fixed
24mar2020 version 3.1.0 - general Markov multi-state simulation now added
						- transmatrix() option added
						- tolerance changed to 0 from 1e-08 in mm_root()
21mar2020 version 3.0.0 - complete re-write of core code
						- can now simulate from a fitted merlin survival model
						- can now simulate from cause-specific hazards competing risks models, with either parametric or user-defined hazard functions, with a new syntax
						- distribution() now required for parameteric models
						- ltruncated() added, can be number or varname, synced with all except merlin model simulation
						- maxtime() can now be a number or a varname
						- help files re-written, hugely improved
						- added error report on missing values when general algorithm used
						- parsing made more robust
18dec2013 version 2.0.3 - tde() with logcumh() or cumh() caused an error. Now fixed.
10oct2013 version 2.0.2 - bug fix -> exact option added to confirm vars
08jul2013 version 2.0.1 - minor bug fix in mixture models
04jan2013 version 2.0.0 - maxtime() added to specify maximum generated survival time and event indicator
						- n() removed so must set obs
						- loghazard() and hazard() added for user-defined hazard functions, simulated using quadrature and root finding
						- default centol() changed to 1E-08
						- varnames can now appear in loghazard()/hazard() allowing time-dependent covariates
						- mixture models now use Brent method -> much more reliable than NR, and allows tdes
						- cumhazard() and logcumhazard() now added which just use root finding
15Nov2011 version 1.1.2 - Fixed bug when generating covariate tempvars with competing risks.
20sep2011 version 1.1.1 - Exponential distribution added.
10sep2011 version 1.1.0 - Added Gompertz distribution. Time-dependent effects available for all models except mixture. showerror option added.
09sep2011 version 1.0.1 - Time dependent effects now allowed for standard Weibull.
*/

program define survsim
	version 14.2

	CheckObs
	
	local opts1											/// -fitted merlin model-
							MODel(passthru)				/// 
														//
													
	local opts2											///	-user-defined-
							LOGHazard(passthru)			///	
							Hazard(passthru)			///	
							LOGCHazard(passthru)		/// 
							CHazard(passthru)			/// 
							NODES(passthru)				///	-# nodes-
							TDEFUNCtion(passthru)		///	-function of time to interact with time-dependent effects-
							MIXture						///	-two-component mixture-
							PMix(passthru)				///	-mixture parameter-
							CR							///	-simulate competing risks-
							NCR(string)					///	-number of competing risks-
							Distribution(passthru)		/// 
							Lambdas(passthru)			///	
							Gammas(passthru)			///	
							COVariates(passthru)		///	-baseline covariates, e.g, (sex 0.5 race -0.4)-
							TDE(passthru)				///	-time dependent effects-
														//

	local commonopts	 								///
							MAXTime(string)				///	-right censoring time-
							LTruncated(string)			///	-left truncation/delayed entry-
														//
													
	//==============================================================================================================//
	//parse opts that are common to all three settings
		
		syntax newvarname(min=1 max=3) , [`commonopts' *]
		local newvars `varlist'
		local stime : word 1 of `newvars'
		local died  : word 2 of `newvars'
		local hasmaxtime = "`maxtime'"!=""
		
		if `hasmaxtime' {	
			
			if "`died'"=="" {
				di as error "2 new variable names required"
				exit 198
			}
			
			cap confirm number `maxtime'
			if _rc {
				cap confirm numeric variable `maxtime'
				if _rc {
					di as error "Invalid maxtime()"
					exit 198
				}
			}
			else {
				if `maxtime'<0 {
					di as error "maxtime() must be >0"
					exit 198
				}
			}
			
			tempvar maxtvar 
			gen `maxtvar' = `maxtime'
			local maxtopt maxtime(`maxtvar')
		}
		
		if "`ltruncated'"!="" {
			
			cap confirm number `ltruncated'
			if _rc {
				cap confirm numeric variable `ltruncated'
				if _rc {
					di as error "Invalid ltruncated()"
					exit 198
				}
			}
			else {
				if `ltruncated'<0 {
					di as error "ltruncated() must be >0"
					exit 198
				}
			}
			
			tempvar ltvar 
			gen `ltvar' = `ltruncated'
			local ltopt ltruncated(`ltvar')
		}
		
		local 0 , `options'
	
	//==============================================================================================================//	
	//survsim_model
	
		syntax , [`opts1' *]
		
		if "`model'"!="" {
			survsim_model `newvars', 	`model' 		///
										`maxtopt'		//
										
			RCREPORT 	_survsim_rc
			MISSREPORT 	`stime'
			GENEVENT 	`stime' `died' `maxtime'
			exit
		}	
	
		local 0 , `options'
	
	//==============================================================================================================//	
	//survsim_user
	
		syntax , [`opts2' *]
		
		local useropt "`loghazard'`hazard'`logchazard'`chazard'`mixture'"
		
		if "`useropt'"!="" {
			survsim_user `newvars', 	`useropt' 		///
										`nodes'			///
										`maxtopt' 		///
										`ltopt'			///
										`covariates'	///
										`tde'			///
										`tdefunction'	///
										`distribution'	///	-for mixture-
										`lambdas'		///
										`gammas'		///
										`pmix'			//

			RCREPORT 	_survsim_rc
			MISSREPORT 	`stime'
			GENEVENT 	`stime' `died' `maxtime'
			exit
		}
		
		local 0 , `options'
		
	//==============================================================================================================//	
	//survsim_msm
	
		syntax , [HAZARD1(passthru) HAZARD2(passthru) TRANSMATrix(passthru) STARTSTATE(passthru) *]
		
		if "`hazard1'"!="" {
		
			capture program drop survsim_msm			// refreshes Mata functions
			
			survsim_msm `newvars', 		`transmatrix'	///
										`hazard1'		///
										`hazard2'		///
										`maxtopt' 		///
										`ltopt'			///
										`startstate'	///
										`nodes'			///
										`options' 		//
			exit
			
		}
		
		local 0 , `options' `distribution' `lambdas' `gammas' `covariates' `tde'
		
	//==============================================================================================================//	
	//parametric distribution	
		
		syntax , 	Distribution(string) 		///
					Lambdas(string) 			///
				[								///
					Gammas(string) 				///
					COVariates(string)			///
					TDE(string)					///
					`opts3'						///
				]								//
		
		local ld = length("`distribution'")
		if 		substr("exponential",1,max(1,`ld'))=="`distribution'" {
			local dist "exp"
		}
		else if substr("gompertz",1,max(3,`ld'))=="`distribution'" {
			local dist "gompertz"
		}
		else if substr("weibull",1,max(1,`ld'))=="`distribution'" {
			local dist "weibull"
		}
		else {
			di as error "Unknown distribution"
			exit 198
		}
		
		foreach l of numlist `lambdas' `gammas' {
			if `l'<0 {
				di as error "lambdas()/gammas() must be > 0"
				exit 198
			}
		}
		
		if "`dist'"=="exp" & "`gammas'"!="" {
			di as error "gammas cannot be specified with distribution(exponential)"
			exit 198
		}
				
	//==============================================================================================================//	
	//baseline covariates and time-dependent effects
	
		if "`covariates'"!="" {
		
			tokenize `covariates'
			local ncovlist : word count `covariates'
			local ncovvars = `ncovlist'/2
			cap confirm integer number `ncovvars'
			if _rc>0 {
				di as error "Variable/number missing in covariates"
				exit 198
			}
			local ind = 1
			local error = 0
			forvalues i=1/`ncovvars' {	
				cap confirm var ``ind'', exact
				if _rc {
					local errortxt "invalid covariates(... ``ind'' ``=`ind'+1'' ...)"
					local error = 1
				}
				cap confirm num ``=`ind'+1''
				if _rc {
					local errortxt "invalid covariates(... ``ind'' ``=`ind'+1'' ...)"
					local error = 1
				}
				tempvar vareffect`i'
				gen double `vareffect`i'' = ``ind''*``=`ind'+1'' 
	
				local ind = `ind' + 2
			}
			if `error' {
				di as error "`errortxt'"
				exit 198
			}
			local cov_linpred "`vareffect1'"
			if `ncovvars'>1 {
				forvalues k=2/`ncovvars' {
					local cov_linpred "`cov_linpred' + `vareffect`k''"
				}
			}
			local cov_linpred "* exp(`cov_linpred')"
			
		}
		
		if "`tde'"!="" {
		
			tokenize `tde'
			local ntde : word count `tde'	
			local ntdevars = `ntde'/2
			cap confirm integer number `ntdevars'
			if _rc>0 {
				di as error "Variable/number missing in tde"
				exit 198
			}

			local ind = 1
			local error = 0
			forvalues i=1/`ntdevars' {
				cap confirm var ``ind'', exact
				if _rc {
					local errortxt "invalid tde(... ``ind'' ``=`ind'+1'' ...)"
					local error = 1
				}
				cap confirm num ``=`ind'+1''
				if _rc {
					local errortxt "invalid tde(... ``ind'' ``=`ind'+1'' ...)"
					local error = 1
				}
				tempvar tdeeffect`i'
				gen double `tdeeffect`i'' = ``ind''*``=`ind'+1'' 

				local ind = `ind' + 2
			}
			if `error' {
				di as error "`errortxt'"
				exit 198
			}
			local tde_linpred "`tdeeffect1'"
			if `ntdevars'>1 {
				forvalues k=2/`ntdevars' {
					local tde_linpred "`tde_linpred' + `tdeeffect`k''"
				}
			}
			local tde_linpred "+ `tde_linpred'"

		}
		
	//==============================================================================================================//	
	//stime and died
		
		tempvar u
		qui gen double `u' = runiform() 
		
		if 		"`dist'"=="exp" {
			if "`ltruncated'"!="" {
				local ltcontrib "* exp(-`lambdas' `cov_linpred' * `ltvar' ^ (1 `tde_linpred') / (1 `tde_linpred'))"
			}
			qui gen double `stime' 	= (-ln(`u' `ltcontrib')*(1 `tde_linpred')/(`lambdas' `cov_linpred'))^(1/(1 `tde_linpred'))
		}
		else if "`dist'"=="weibull" {
			if "`ltruncated'"!="" {
				local ltcontrib "* exp(-`lambdas' `cov_linpred' * `gammas' * `ltvar' ^ (`gammas' `tde_linpred') / (`gammas' `tde_linpred'))"
			}
			qui gen double `stime' 	= (-ln(`u' `ltcontrib')*(`gammas' `tde_linpred')/(`lambdas'*`gammas' `cov_linpred'))^(1/(`gammas' `tde_linpred')) 
		}
		else{
			if "`ltruncated'"!="" {
				local ltcontrib "* exp(- `lambdas' `cov_linpred' / (`gammas' `tde_linpred') * (exp(`ltvar' * (`gammas' `tde_linpred') ) - 1))"
			}
			qui gen double `stime' 	= (1/(`gammas' `tde_linpred'))*log(1-(((`gammas' `tde_linpred')*log(`u' `ltcontrib'))/(`lambdas' `cov_linpred'))) 
		}
			
		MISSREPORT `stime'
		if "`maxtime'"!="" {
			GENEVENT `stime' `died' `maxtvar'
			qui replace `stime' = `maxtvar' if `died'==0
		}
	
end

program CheckObs
	if _N==0 {
		di as error "No observations"
		exit 198
	}
end	

program GENEVENT
	args stime died maxtime
	qui gen byte `died' = `stime'<`maxtime' if `stime'!=.
	qui replace `stime' = `maxtime' if `stime'>`maxtime' & `stime'!=.
end

program RCREPORT
	args rcvar
	qui su `rcvar' if `rcvar'==1, meanonly
	if r(N)>0 {
		di in yellow "Warning: `r(N)' survival times did not converge"
		di in yellow "         They have been set to the final iteration value"
		di in yellow "         You can identify them by _survsim_rc = 1"
	}
	qui su `rcvar' if `rcvar'==2, meanonly
	if r(N)>0 {
		di in yellow "Warning: `r(N)' survival times were below the lower limit"
		di in yellow "         You can identify them by _survsim_rc = 2"
	}
	qui su `rcvar' if `rcvar'==3, meanonly
	if r(N)>0 {
		di in yellow "Warning: `r(N)' survival times were above the upper limit of maxtime()"
		di in yellow "         They have been set to maxtime()"
		di in yellow "         You can identify them by _survsim_rc = 3"
	}	
end

program MISSREPORT
	args time
	qui count if `time'==.
	if `r(N)'>0 {
		di as warning "`r(N)' missing values generated in simulated survival times"		
	}
end
