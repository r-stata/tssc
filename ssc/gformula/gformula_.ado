*! version 1.11 beta RhMD 14 Jan 2013
*! with the "bug" that simulates L independently for different values of
*! X "fixed" so that the errors are always perfectly correlated across
*! worlds. This only affects the calculation of natural mediation effects.
*!
*! version 1.10 beta RhMD 25 May 2012
*! with the bug that post baseline confounders are REQUIRED for the 
*! mediation option fixed.
*!
*! version 1.9 beta RhMD 21 May 2012
*! with the option -moreMC- added to allow the number of MC simulations, 
*! only for mediation, to be greater than the sample size.
*!
*! version 1.8 beta RhMD 03 Feb 2012
*! with the option -minsim- amended so that, for mediation, even more
*! simulation is avoided when the -linexp- option is specified.
*! Note: -minsim- should not be specified in conjunction with
*! -boceam- at the moment - this will be corrected in a future
*! version.
*!
*! version 1.7 beta RhMD 03 Feb 2012
*! with an option -minsim- added that suppresses simulation of outcomes
*! (for both mediation and tvc), using just the predicted means instead.
*! Note: categorical outcomes fitted using ologit or mlogit are still
*! simulated even with minsim.
*!
*! version 1.6 RhMD 30 Jan 2012
*! with the -linexp- option added for mediation, which allows the
*! user to specify that the exposure is continuous and that its effect
*! is assumed to be linear. Thus, the CDE is defined as:
*! E{Y(X+1,m)-Y(X,m)}
*! and so on. 
*!
*! version 1.5 RhMD 21 Dec 2011
*! with mlogit and ologit added for simulation, ologit added for 
*! imputation (mlogit for imputation was already supported); and with
*! a correction to the bug in the -msm- option for mediation, and the
*! addition of the -boceam- option
*!
*! version 1.4 RhMD 28 Jun 2011
*! with -msm- option added for mediation
*!
*! version 1.3 RhMD 01 Jun 2011
*! with -monotreat- option added
*!
*! version 1.2 RhMD 12 Apr 2011
*! with r(out) bug fixed
*! and the "saving discrepancy" fixed 
*!(the saved dataset containing the simulations is now taken from the 
*! first run of gformula_ within the boostrap, so that analysis of this
*! dataset matches the output of the command)
*!
*! version 1.1 RhMD 13 Jan 2011
*! with new mediation option -oce- for a single categorical exposure
*! and bug fixed when -control()- was not specified
program define gformula_, rclass
version 11
syntax varlist(min=2 numeric) [if] [in] , OUTcome(varname) COMmands(string) EQuations(string) [Idvar(varname) ///
    Tvar(varname) VARyingcovariates(varlist) intvars(varlist) interventions(string) monotreat eofu pooled death(varname) ///
    derived(varlist) derrules(string) FIXedcovariates(varlist) LAGgedvars(varlist) lagrules(string) msm(string) ///
    mediation EXposure(varlist) mediator(varlist) control(string) baseline(string) base_confs(varlist) ///
    post_confs(varlist) impute(varlist) imp_eq(string) imp_cmd(string) imp_cycles(int 10) SIMulations(int 10000) ///
	obe oce boceam linexp minsim moreMC graph saving(string) replace]
preserve
*for the time-varying option, the first step is to make the dataset long again; this is how we want it, 
*but we had to start with it wide for the sake of the boostrapping
local maxid=_N
if _N!=`simulations' {
	tempvar choosesample
	qui gen `choosesample'=uniform()
	sort `choosesample'
}
if "`mediation'"=="" {
	qui replace `idvar'=_n
	drop $almost_varlist
	drop `tvar'
	qui reshape long $almost_varlist, i(`idvar') j(`tvar')
	qui tab `tvar', matrow(matvis)
	local maxv=rowsof(matvis)
	local maxvlab=matvis[`maxv',1]
	local firstv=matvis[1,1]
}
*for the time-varying option, if the outcome is end-of-follow-up, we must check that there 
*aren't any other measures of the outcome
if "`mediation'"=="" {
	if "`eofu'"!="" {
		local k=matvis[`maxv',1]
		if $check_delete==0 {
			if "`graph'"!="" {
				noi di as err "   Warning: graph option not available when outcome type is end-of-follow-up"
				noi di
			}
			qui count if `outcome'!=. & `tvar'!=`k'
			if r(N)>1 {
				noi di as err "   Warning: " _cont
				noi di as result r(N) _cont
				noi di as err " observations of the outcome variable are being ignored because they were recorded before the end of follow-up"
				noi di
			}
			if r(N)==1 {
				noi di as err "   Warning: " _cont
				noi di as result 1 _cont
				noi di as err " observation of the outcome variable is being ignored because it was recorded before the end of follow-up"
				noi di
			}
			global check_delete=1
		}
		qui replace `outcome'=. if `tvar'!=`k'
	}
}
*for the time-varying option, if the outcome is survival, we need to give a warning re MSM
*if the pooled option has not been specified, or if a common intercept is not used within the pooled option
if "`mediation'"=="" {
	if "`eofu'"=="" {
		if $check_delete==0 {
			if "`pooled'"=="" {
				noi di as err "   Warning: the MC simulations will be generated using a different logistic regression at each visit (since the "
				noi di as result "   pooled " _cont
				noi di as err "option was not specified). But the MSM will be fitted using a time-updated Cox model, asymptotically" 
				noi di as err "   equivalent to a pooled logistic regression. Thus, the MSM is not consistent with the simulation model."
				noi di
			}
			else {
				local varlist2="`death'"+" "+"`outcome'"+" "+"`varyingcovariates'"+" "+"`intvars'"
				local nvar: word count `varlist2'
				detangle "`equations'" equation "`varlist2'"
				forvalues i=1/`nvar' {
					if "${S_`i'}"!="" {
						local equation`i' ${S_`i'}
					}
				}
				forvalues i=1/`nvar' {
					tokenize "`varlist2'"
					if "``i''"=="`outcome'" {	
						local nvareq: word count `equation`i''
						tokenize "`equation`i''"
						forvalues j=1/`nvareq' {
							if "``j''"=="`tvar'" {
								noi di as err "   Warning: the MC simulations will be generated using a pooled logistic regression (since the " _cont
								noi di as result "pooled "
								noi di as err "   option has been specified) but with a different intercept at each visit (since " _cont
								noi di as result substr("`tvar'",1,length("`tvar'")-1) _cont
								noi di as err " was included"
								noi di as err "   in the model for the outcome). But the MSM will be fitted using a time-updated Cox model,"
								noi di as err "   asymptotically equivalent to a pooled logistic regression with a common intercept. Thus, the MSM" 
								noi di as err "   is not consistent with the simulation model."
								noi di
							}
						}
					}
				}			
			}
			global check_delete=1
		}
	}
}
local limit=0
local limit_prop=1
local limit_done=0
local limit_could=0
if $check_print==0 {
	noi di as text "   No. of subjects = " _cont
	noi di as result `maxid'
	if "`mediation'"=="" {
		if "`eofu'"=="" {
			qui count if `outcome'==1
			noi di as text "   No. of events = " _cont
			noi di as result r(N)
		}
		if "`death'"!="" {
			qui count if `death'==1
			noi di as text "   No. of deaths = " _cont
			noi di as result r(N)
		}
	}
	if "`impute'"!="" {
		local imp_nvar: word count `impute'
		if "`mediation'"!="" {
			local maxv=1
		}
		local limit=0
		local k1=max(floor((`imp_cycles'*`maxv'*`imp_nvar'-9)/2),1)
		local k2=max(ceil((`imp_cycles'*`maxv'*`imp_nvar'-9)/2),1)
		if `k2'>26 {
			local limit_prop=60/(`k1'+`k2'+8)
			local k1=26
			local k2=26
			local limit=1
			local limit_done=0
			local limit_could=0
		}
		noi di
		noi di as text "                                              {c LT}" _cont
		noi di as text "{hline `k1'}" _cont
		noi di as text "PROGRESS" _cont
		noi di as text "{hline `k2'}" _cont
		noi di as text "{c RT}"
		noi di as text "   Performing the imputation step:            {c LT}" _cont
	}
}
* The imputation step
if "`impute'"!="" {
	local imp_nvar: word count `impute'
	* detangle imputation commands
	detangle "`imp_cmd'" imp_cmd "`impute'"
	forvalues i=1/`imp_nvar' {
		if "${S_`i'}"!="" {
			local imp_cmd`i' ${S_`i'}
		}
	}
	* detangle imputation equations
	detangle "`imp_eq'" imp_eq "`impute'"
	forvalues i=1/`imp_nvar' {
		if "${S_`i'}"!="" {
			local imp_eq`i' ${S_`i'}
		}
	}
	forvalues i=1/`imp_nvar' {
		local imp_var`i': word `i' of `impute'
	}
	if "`mediation'"=="" {
		*lagged variables
		* detangle lag rules
		local nlag: word count `laggedvars'	
    	detangle "`lagrules'" lagrule "`laggedvars'"
    	forvalues i=1/`nlag' {
    		local lagvar`i': word `i' of `laggedvars'
    		if "${S_`i'}"!="" {
    			local lagrule`i' ${S_`i'}
    		}
    	}
    	forvalues i=1/`nlag' {
    		tokenize "`lagrule`i''", parse(" ")
    		local lagrulevar`i' "`1'"
    		local lag`i' "`2'"
    	}
	}
	*derived variables
	* detangle derivation rules
	local nder: word count `derived'	
	if `nder'>0 {
		detangle "`derrules'" derrule "`derived'"
		forvalues i=1/`nder' {
			local der`i': word `i' of `derived'
			if "${S_`i'}"!="" {
				local derrule`i' ${S_`i'}
			}
		}
	}
	* we determine at which visit each variable in impute is to be imputed
	if "`mediation'"=="" {
		forvalues i=1/`imp_nvar' {
			forvalues j=1/`maxv' {
				local k=matvis[`j',1]           
				qui count if `imp_var`i''!=. & `tvar'==`k'
				if r(N)!=0 {
					local visitcalc`i'_`j'=1
				}
				else {
					local visitcalc`i'_`j'=0
				}
			}
		}
	}
	forvalues i=1/`imp_nvar' {
		tempvar imp_imp_var`i'
		qui gen `imp_imp_var`i''=`imp_var`i''
	}
	* first, we draw the "ad hoc" imputations
	forvalues i=1/`imp_nvar' {
		tempvar adhoc`i'
		qui gen `adhoc`i''=`imp_var`i''
		qui count if `adhoc`i''==.
		local countmiss=r(N)
		while `countmiss'>0 {
			qui replace `adhoc`i''=`imp_var`i''[1+int(_N*uniform())] if `adhoc`i''==.
			qui count if `adhoc`i''==.
			local countmiss=r(N)
		}
	}
	if "`mediation'"=="" {
		forvalues j=1/`maxv' {
			forvalues i=1/`imp_nvar' {
				local k=matvis[`j',1]
				if `visitcalc`i'_`j''==1 {
					qui replace `imp_var`i''=`adhoc`i'' if `imp_imp_var`i''==. & `tvar'==`k'
				}
				*update derived variables
				forvalues ii=1/`nder' {
					capture qui replace `der`ii''=`derrule`ii'' if `der`ii''==.
					if _rc!=0 {
						local derrule`ii'=subinword("`derrule`ii''","if","if (",1)+" )"
						capture qui replace `der`ii''=`derrule`ii'' & `der`ii''==.
					}
				}
				*update lagged variables
				sort `idvar' `tvar'
				forvalues ii=1/`nlag' {
					qui by `idvar': replace `lagvar`ii''=`lagrulevar`ii''[_n-`lag`ii''] if `lagvar`ii''==.
					qui replace `lagvar`ii''=0 if `tvar'==`firstv'
					if `lag`ii''>1 {
						forvalues next=2/`lag`ii'' {
							local nextv=matvis[`next',1]
							qui replace `lagvar`ii''=0 if `tvar'==`nextv'
						}
					}
				}
			}  
		}
	}
	else {
		forvalues i=1/`imp_nvar' {
			qui replace `imp_var`i''=`adhoc`i'' if `imp_imp_var`i''==.
		}  
		*update derived variables
		forvalues i=1/`nder' {
			capture qui replace `der`i''=`derrule`i'' if `der`i''==.
			if _rc!=0 {
				local derrule`i'=subinword("`derrule`i''","if","if (",1)+" )"
				capture qui replace `der`i''=`derrule`i'' & `der`i''==.
			}
		}
	}
	*and now the real imputations, starting at cycle 1
	forvalues cycle=1/`imp_cycles' {
		if "`mediation'"=="" {
			* fit parametric models and impute according to parameter estimates
			forvalues j=1/`maxv' {
				forvalues i=1/`imp_nvar' {
					if $check_print==0 & `limit'==0 {
						if `j'==`maxv' & `i'==`imp_nvar' & `cycle'==`imp_cycles' & `maxv'*`imp_nvar'*`imp_cycles'>=11 {
							noi di "{c RT}" _cont
						}	
						else {
							noi di "{hline 1}" _cont
						}
					}
					if $check_print==0 & `limit'==1 {
						if `j'==`maxv' & `i'==`imp_nvar' & `cycle'==`imp_cycles' & `maxv'*`imp_nvar'*`imp_cycles'>=11 {
							while `limit_done'<60 {
								noi di "{hline 1}" _cont
								local limit_done=`limit_done'+1
							}
							noi di "{c RT}" _cont
						}	
						else {
							if (`limit_done'/(`limit_could'+1))<`limit_prop' & `limit_done'<60 {
								noi di "{hline 1}" _cont
								local limit_done=`limit_done'+1
							}
							local limit_could=`limit_could'+1
						}
					}
					local k=matvis[`j',1]
					if `visitcalc`i'_`j''==1 {
						if "`pooled'"=="" {
							qui `imp_cmd`i'' `imp_imp_var`i'' `imp_eq`i'' if `tvar'==`k'
						}
						else {
							qui `imp_cmd`i'' `imp_imp_var`i'' `imp_eq`i''
						}
						if "`imp_cmd`i''"=="mlogit" | "`imp_cmd`i''"=="ologit" {
							if "`imp_cmd`i''"=="mlogit" {
								local maxl=e(k_out)
								mat out_mlogit=e(out)
							}
							if "`imp_cmd`i''"=="ologit" {
								local maxl=e(k_cat)
								mat out_mlogit=e(cat)
							}
							forvalues l=1/`maxl' {
								local out_mlogit_`l'=out_mlogit[1,`l']
								capture drop _pred_imp_var`i'_`l'
							}
							qui predict _pred_imp_var`i'_1'-_pred_imp_var`i'_`maxl'
						}
						else {
							tempvar pred_imp_var`i'
							qui predict `pred_imp_var`i''
						}
						if "`imp_cmd`i''"=="logit" {
							qui replace `imp_var`i''=uniform()<`pred_imp_var`i'' if `imp_imp_var`i''==. & `tvar'==`k'
						}
						if "`imp_cmd`i''"=="regress" {
							qui replace `imp_var`i''=`pred_imp_var`i''+e(rmse)*invnormal(uniform()) if `imp_imp_var`i''==. & `tvar'==`k'
						}
						if "`imp_cmd`i''"=="mlogit" | "`imp_cmd`i''"=="ologit" {
							tempvar u_for_mlogit
							tempvar cumulative_pred
							qui gen `u_for_mlogit'=uniform()
							qui gen `cumulative_pred'=0
							forvalues l=1/`maxl' {
								qui replace `imp_var`i''=`out_mlogit_`l'' if `u_for_mlogit'>=`cumulative_pred' & `u_for_mlogit'<(`cumulative_pred'+_pred_imp_var`i'_`l') & `imp_imp_var`i''==. & `tvar'==`k' 
								qui replace `cumulative_pred'=`cumulative_pred'+_pred_imp_var`i'_`l'
							}
						}
						if "`imp_cmd`i''"!="regress" & "`imp_cmd`i''"!="logit" & "`imp_cmd`i''"!="mlogit" & "`imp_cmd`i''"!="ologit" {
							noi di as err "Error: only regress, logit, mlogit and ologit are supported as imputation commands in gformula."
							exit 198
						}
					}
					*update derived variables
					forvalues ii=1/`nder' {
						capture qui replace `der`ii''=`derrule`ii'' if `der`ii''==.
						if _rc!=0 {
							local derrule`ii'=subinword("`derrule`ii''","if","if (",1)+" )"
							capture qui replace `der`ii''=`derrule`ii'' & `der`ii''==.
						}
					}
					*update lagged variables
					sort `idvar' `tvar'
					forvalues ii=1/`nlag' {
						qui by `idvar': replace `lagvar`ii''=`lagrulevar`ii''[_n-`lag`ii''] if `lagvar`ii''==.
						qui replace `lagvar`ii''=0 if `tvar'==`firstv'
						if `lag`ii''>1 {
							forvalues next=2/`lag`ii'' {
								local nextv=matvis[`next',1]
								qui replace `lagvar`ii''=0 if `tvar'==`nextv'
							}
						}
					}
				}  
			}
		}
		else {
			* fit parametric models and impute according to parameter estimates
			forvalues i=1/`imp_nvar' {
			
				if $check_print==0 & `limit'==0 {
					if `i'==`imp_nvar' & `cycle'==`imp_cycles' & `imp_nvar'*`imp_cycles'>=11 {
						noi di "{c RT}" _cont
					}	
					else {
						noi di "{hline 1}" _cont
					}
				}
				if $check_print==0 & `limit'==1 {
					if `i'==`imp_nvar' & `cycle'==`imp_cycles' & `imp_nvar'*`imp_cycles'>=11 {
						while `limit_done'<60 {
							noi di "{hline 1}" _cont
							local limit_done=`limit_done'+1
						}
						noi di "{c RT}" _cont
					}	
					else {
						if (`limit_done'/(`limit_could'+1))<`limit_prop' & `limit_done'<60 {
							noi di "{hline 1}" _cont
							local limit_done=`limit_done'+1
						}
						local limit_could=`limit_could'+1
					}
				}
				qui `imp_cmd`i'' `imp_imp_var`i'' `imp_eq`i''
				if "`imp_cmd`i''"=="mlogit" | "`imp_cmd`i''"=="ologit" {
					if "`imp_cmd`i''"=="mlogit" {
						local maxl=e(k_out)
						mat out_mlogit=e(out)
					}
					if "`imp_cmd`i''"=="ologit" {
						local maxl=e(k_cat)
						mat out_mlogit=e(cat)
					}
					forvalues l=1/`maxl' {
						local out_mlogit_`l'=out_mlogit[1,`l']
						capture drop _pred_imp_var`i'_`l'
					}
					qui predict _pred_imp_var`i'_1-_pred_imp_var`i'_`maxl'
				}
				else {
					tempvar pred_imp_var`i'
					qui predict `pred_imp_var`i''
				}				
				if "`imp_cmd`i''"=="logit" {
					qui replace `imp_var`i''=uniform()<`pred_imp_var`i'' if `imp_imp_var`i''==.
				}
				if "`imp_cmd`i''"=="regress" {
					qui replace `imp_var`i''=`pred_imp_var`i''+e(rmse)*invnormal(uniform()) if `imp_imp_var`i''==.
				}
				if "`imp_cmd`i''"=="mlogit" | "`imp_cmd`i''"=="ologit" {
					tempvar u_for_mlogit
					tempvar cumulative_pred
					qui gen `u_for_mlogit'=uniform()
					qui gen `cumulative_pred'=0
					forvalues l=1/`maxl' {
						qui replace `imp_var`i''=`out_mlogit_`l'' if `u_for_mlogit'>=`cumulative_pred' & `u_for_mlogit'<(`cumulative_pred'+_pred_imp_var`i'_`l') & `imp_imp_var`i''==.
						qui replace `cumulative_pred'=`cumulative_pred'+_pred_imp_var`i'_`l'
					}
				}
				if "`imp_cmd`i''"!="regress" & "`imp_cmd`i''"!="logit" & "`imp_cmd`i''"!="mlogit" & "`imp_cmd`i''"!="ologit" {
					noi di as err "Error: only regress, logit, mlogit and ologit are supported as imputation commands in gformula."
					exit 198
				}
			}  
			*update derived variables
			forvalues i=1/`nder' {
				capture qui replace `der`i''=`derrule`i'' if `der`i''==.
				if _rc!=0 {
					local derrule`i'=subinword("`derrule`i''","if","if (",1)+" )"
					capture qui replace `der`i''=`derrule`i'' & `der`i''==.
				}
			}
		}
	}
	if $check_print==0 {
		if "`mediation'"!="" {
			local maxv=1
		}	
		if `imp_cycles'*`maxv'*`imp_nvar'<11 {
			local k3=10-`maxv'*`imp_nvar'*`imp_cycles'
			noi di _dup(`k3') "{hline 1}" _cont
			noi di "{c RT}" _cont
		}
		noi di
	}
}
* end of imputation step and on to preparing for the MC simulation
if $check_print==0 {
	noi di
	noi di as text "                                              {c LT}{hline 1}PROGRESS{hline 1}{c RT}"
	noi di as text "   Preparing dataset for MC simulations:      {c LT}" _cont
}
tempvar int_no
gen `int_no'=0
* It will be useful to have a list of the variables for which models will be specified
if "`mediation'"=="" {
	local varlist2="`death'"+" "+"`outcome'"+" "+"`varyingcovariates'"+" "+"`intvars'"
}
else {
	local varlist2="`post_confs'"+" "+"`mediator'"+" "+"`outcome'"
}
local nvar: word count `varlist2'
local nvar_formono: word count `intvars'
local nvar_untilmono=`nvar'-`nvar_formono'
* detangle commands
detangle "`commands'" command "`varlist2'"
forvalues i=1/`nvar' {
	if "${S_`i'}"!="" {
		local command`i' ${S_`i'}
	}
}
if $check_print==0 {
	noi di as text "{hline 1}" _cont
}
* detangle equations
detangle "`equations'" equation "`varlist2'"
forvalues i=1/`nvar' {
	if "${S_`i'}"!="" {
		local equation`i' ${S_`i'}
	}
}
if $check_print==0 {
	noi di as text "{hline 1}" _cont
}
forvalues i=1/`nvar' {
	local simvar`i': word `i' of `varlist2'
}
if $check_print==0 {
	noi di as text "{hline 1}" _cont
}
* tokenize interventions
if "`mediation'"=="" {
	tokenize "`interventions'", parse(",")
	local nint 0 			
	while "`1'"!="" {
		if "`1'"!="," {
			local nint=`nint'+1
			local int`nint' "`1'"
		}
		mac shift
	}
}
if $check_print==0 {
	noi di as text "{hline 1}" _cont
}
if "`mediation'"=="" {
	forvalues i=1/`nint' {
		tokenize "`int`i''", parse("\")
		local nintcomp`i' 0 			
		while "`1'"!="" {
			if "`1'"!="\" {
				local nintcomp`i'=`nintcomp`i''+1
				local intcomp`i'`nintcomp`i'' "`1'"
			}	
			mac shift
		}
	}
}
else {
    local nbase: word count `exposure'
	if "`obe'"=="" | "`linexp'"=="" {
		detangle "`baseline'" baseline "`exposure'"
		forvalues i=1/`nbase' {
			if "${S_`i'}"!="" {
				local baseline`i' ${S_`i'}
			}
		}
	}
	local nmed: word count `mediator'
    if "`control'"!="" {
        detangle "`control'" control "`mediator'"
        forvalues i=1/`nmed' {
        	if "${S_`i'}"!="" {
        		local control`i' ${S_`i'}
        	}
        }
    }
}
if $check_print==0 {
	noi di as text "{hline 1}" _cont
}
*set up dataset ready for Monte Carlo simulation
    *increase size of dataset to make room for the new simulated observations
	local oldN=_N
	*create an id variable for mediation setting
	if "`mediation'"!="" {
		tempvar subjectid
		qui gen `subjectid'=_n if _n<=`simulations'
	}
    if "`mediation'"=="" {
    	local newN=`oldN'+(`nint'+1)*`simulations'*`maxv'
    }
    else {
		if "`oce'"=="" {
			local nexplev=1
		}
		else {
			qui tab `exposure'
			local nexplev=r(r)-1
		}
		if "`control'"=="" {
			if "`msm'"=="" {
				local newN=`oldN'+`simulations'*(2*`nexplev'+1)
			}
			else {
				if "`boceam'"=="" {
					local newN=`oldN'+`simulations'*(2*`nexplev'+2)
				}
				else {
					qui tab `exposure' `mediator', matrow(matem1) matcol(matem2)
					local comb_em=rowsof(matem1)*colsof(matem2)
					local newN=`oldN'+`simulations'*(2*`nexplev'+1)+`simulations'*`comb_em'
				}
			}
		}
		else {
			if "`msm'"=="" {
				local newN=`oldN'+`simulations'*(3*`nexplev'+2)
			}
			else {
				if "`boceam'"=="" {
					local newN=`oldN'+`simulations'*(3*`nexplev'+3)
				}
				else {
					qui tab `exposure' `mediator', matrow(matem1) matcol(matem2)
					local comb_em=rowsof(matem1)*colsof(matem2)
					local newN=`oldN'+`simulations'*(3*`nexplev'+2)+`simulations'*`comb_em'
				}
			}
		}
    }
    local nump=`oldN'
	capture qui set obs `newN'
	if _rc!=0 {
		noi di as err "Insufficient memory. Increase using -set memory-."
		exit 198
	}
	*idvar and tvar
    if "`mediation'"=="" {
    	qui replace `idvar'=ceil(_n/`maxv') if `idvar'==.
    	qui replace `tvar'=_n-`maxv'*ceil(_n/`maxv')+`maxv' if `tvar'==.
    	qui replace `tvar'=matvis[`tvar',1] if _n>`oldN'
    }
	if $check_print==0 {
		noi di as text "{hline 1}" _cont
	}

	*fixedcovariates / base_confs
	if "`mediation'"!="" {
		if "`control'"=="" {
			if "`msm'"=="" {
				local nint=3
			}
			else {
				if "`boceam'"=="" {
					local nint=4
				}
				else {
					qui tab `exposure' `mediator', matrow(matem1) matcol(matem2)
					local comb_em=rowsof(matem1)*colsof(matem2)
					local nint=3+`comb_em'
				}
			}
        }
        else {
			if "`msm'"=="" {
				local nint=5
			}
			else {
				if "`boceam'"=="" {
					local nint=6
				}
				else {
					qui tab `exposure' `mediator', matrow(matem1) matcol(matem2)
					local comb_em=rowsof(matem1)*colsof(matem2)
					local nint=5+`comb_em'
				}
			}
		}
		local maxv=1
	}
	local nintplus1=`nint'+1
	local nintplus2=`nint'+2
	if "`oce'"!="" {
		if "`boceam'"=="" {
			if "`msm'"=="" {
				local nintplus1=(0.5*(`nint'+1))*(`nexplev'+1)
			}
			else {
				local nintplus1=(0.5*(`nint'))*(`nexplev'+1)+1
			}
		}
		else {
			qui tab `exposure' `mediator', matrow(matem1) matcol(matem2)
			local comb_em=rowsof(matem1)*colsof(matem2)
			local nintplus1=(0.5*(`nint'))*(`nexplev'+1)+`comb_em'
		}
	}	
	forvalues i=1/`nintplus1' {
		foreach var in `fixedcovariates' {
			qui replace `var'=`var'[_n-`oldN'-(`i'-1)*`simulations'*`maxv'] if `var'==. & `int_no'[_n-`oldN'-(`i'-1)*`simulations'*`maxv']==0 
		}
		foreach var in `base_confs' {
			if "`moreMC'"=="" {
				qui replace `var'=`var'[_n-`oldN'-(`i'-1)*`simulations'] if `var'==. & `int_no'[_n-`oldN'-(`i'-1)*`simulations']==0 
			}
			else {
				local RA=ceil(`simulations'/`oldN')
				forvalues ra=1(1)`RA' {
					qui replace `var'=`var'[_n-`ra'*`oldN'-(`i'-1)*`simulations'] if `var'==. & `int_no'[_n-`ra'*`oldN'-(`i'-1)*`simulations']==0 
				}
			}
		}
	}
	
	* subject id
	if "`mediation'"!="" {
		forvalues i=1/`nintplus1' {
			if "`moreMC'"=="" {
				qui replace `subjectid'=`subjectid'[_n-`oldN'-(`i'-1)*`simulations'] if `subjectid'==. & `int_no'[_n-`oldN'-(`i'-1)*`simulations']==0
			}
		}
		if "`moreMC'"!="" {
			qui replace `subjectid'=mod(_n-`oldN',`simulations') if `subjectid'==.
			qui replace `subjectid'=`simulations' if `subjectid'==0
		}
	}
	
	*intervention variables
	local M=`oldN'
    if "`mediation'"=="" {
    	local N=`oldN'+`simulations'*`maxv'
    }
    else {
        local N=`oldN'+`simulations'
    }
    if "`mediation'"=="" {
        forvalues i=1/`nint' {
            qui replace `int_no'=`i' if _n>`M' & _n<=`N'
            forvalues j=1/`nintcomp`i'' {
                capture qui replace `intcomp`i'`j'' if _n>`M' & _n<=`N'
                if _rc!=0 {
					local intcomp`i'`j'=subinword("`intcomp`i'`j''","if","if (",1)+" )"
					capture qui replace `intcomp`i'`j'' & _n>`M' & _n<=`N'
                }
            }
            local M=`N'
            local N=`N'+`simulations'*`maxv'
        }
        qui replace `int_no'=`nint'+1 if _n>`M' & _n<=`N'
        foreach var in `intvars' {
             qui replace `var'=`var'[_n-`oldN'-`nint'*`simulations'*`maxv'] if _n>`M' & _n<=`N'
			 qui replace `var'=. if `tvar'!=`firstv' & _n>`M' & _n<=`N'
         }
    }
    else {
		if "`control'"=="" {
			if "`msm'"=="" {
				local nint=3
			}
			else {
				if "`boceam'"=="" {
					local nint=4
				}
				else {
					qui tab `exposure' `mediator', matrow(matem1) matcol(matem2)
					local comb_em=rowsof(matem1)*colsof(matem2)
					local nint=3+`comb_em'
				}
			}
        }
        else {
			if "`msm'"=="" {
				local nint=5
			}
			else {
				if "`boceam'"=="" {
					local nint=6
				}
				else {
					qui tab `exposure' `mediator', matrow(matem1) matcol(matem2)
					local comb_em=rowsof(matem1)*colsof(matem2)
					local nint=5+`comb_em'
				}
			}
		}
		if "`obe'"=="" & "`oce'"=="" & "`linexp'"=="" {
			forvalues i=1/`nint' {
				qui replace `int_no'=`i' if _n>`M' & _n<=`N'
				forvalues j=1/`nbase' {
					tokenize "`exposure'"
					qui replace ``j''=`baseline`j'' if _n>`M' & _n<=`N'
					if `i'==1 | `i'==3 | `i'==5 {
						if "`moreMC'"=="" {
							qui replace ``j''=``j''[_n-`oldN'-(`i'-1)*`simulations'] if `int_no'==`i'
						}
						else {
							local RA=ceil(`simulations'/`oldN')
							forvalues ra=1(1)`RA' {
								qui replace ``j''=``j''[_n-`ra'*`oldN'-(`i'-1)*`simulations'] if `int_no'==`i' & `int_no'[_n-`ra'*`oldN'-(`i'-1)*`simulations']==0
							}
						}
					}
					if (`i'==4 & "`control'"=="" & "`boceam'"=="") | (`i'==6 & "`control'"!="" & "`boceam'"=="") {
					****************************************************************************************************************************************************************************************************
						tempvar randomorder
						tempvar originalorder
						gen `originalorder'=_n
						gen `randomorder'=uniform()
						sort `int_no' `randomorder'
						if "`moreMC'"=="" {
							qui replace ``j''=``j''[_n-`oldN'-(`i'-1)*`simulations'] if `int_no'==`i'
						}
						else {
							local RA=ceil(`simulations'/`oldN')
							forvalues ra=1(1)`RA' {
								qui replace ``j''=``j''[_n-`ra'*`oldN'-(`i'-1)*`simulations'] if `int_no'==`i' & `int_no'[_n-`ra'*`oldN'-(`i'-1)*`simulations']==0
							}
						}
						sort `originalorder'
					****************************************************************************************************************************************************************************************************
					}
					if "`boceam'"!="" {
					****************************************************************************************************************************************************************************************************
						qui tab `exposure' `mediator', matrow(matem1) matcol(matem2)
						local num_lev_e=rowsof(matem1)
						local num_lev_m=colsof(matem2)
						forvalues lev_e=1(1)`num_lev_e' {
							if "`control'"=="" {
								local i_em=`i'-3
							}
							else {
								local i_em=`i'-5
							}
							if `i_em'/`num_lev_m'<=`lev_e' & (`i_em'/`num_lev_m'>`lev_e'-1) {
								qui replace ``j''=matem1[`lev_e',1] if `int_no'==`i' & `i_em'>=1									
							}
						}
					****************************************************************************************************************************************************************************************************
					}
				}
				local M=`N'
				local N=`N'+`simulations'
			}
		}
		else {
			if "`obe'"!="" {
				forvalues i=1/`nint' {
					qui replace `int_no'=`i' if _n>`M' & _n<=`N'
					local M=`N'
					local N=`N'+`simulations'
				}
				qui replace `exposure'=1 if `int_no'==1 | `int_no'==3 | `int_no'==5
				qui replace `exposure'=0 if `int_no'==2 | `int_no'==4
				********************************************************************************************************************************************************************************************************
				if "`boceam'"=="" {
					qui count if `int_no'<6 & `int_no'>0
					local missout=r(N)
					tempvar randomorder
					tempvar originalorder
					gen `originalorder'=_n
					gen `randomorder'=uniform()
					sort `int_no' `randomorder'
					if "`moreMC'"=="" {
						qui replace `exposure'=`exposure'[_n-`oldN'-`missout'] if `int_no'==6
					}
					else {
						local RA=ceil(`simulations'/`oldN')
						forvalues ra=1(1)`RA' {
							qui replace `exposure'=`exposure'[_n-`ra'*`oldN'-`missout'] if `int_no'==6 & `int_no'[_n-`ra'*`oldN'-`missout']==0
						}
					}
					sort `originalorder'
				}
				********************************************************************************************************************************************************************************************************
				if "`control'"=="" {
				********************************************************************************************************************************************************************************************************
					if "`boceam'"=="" {
						qui count if `int_no'<4 & `int_no'>0
						local missout=r(N)
						tempvar randomorder
						tempvar originalorder
						gen `originalorder'=_n
						gen `randomorder'=uniform()
						sort `int_no' `randomorder'
						if "`moreMC'"=="" {
							qui replace `exposure'=`exposure'[_n-`oldN'-`missout'] if `int_no'==4
						}
						else {
							local RA=ceil(`simulations'/`oldN')
							forvalues ra=1(1)`RA' {
								qui replace `exposure'=`exposure'[_n-`ra'*`oldN'-`missout'] if `int_no'==4 & `int_no'[_n-`ra'*`oldN'-`missout']==0
							}
						}
						sort `originalorder'
					}
				********************************************************************************************************************************************************************************************************
				}	
				if "`boceam'"!="" {
				********************************************************************************************************************************************************************************************************
					qui tab `exposure' `mediator', matrow(matem1) matcol(matem2)
					local num_lev_e=rowsof(matem1)
					local num_lev_m=colsof(matem2)
					if "`control'"=="" {
						qui replace `exposure'=0 if (`int_no'-3)/`num_lev_m'<=1
						qui replace `exposure'=1 if (`int_no'-3)/`num_lev_m'>1
					}
					else {
						qui replace `exposure'=0 if (`int_no'-5)/`num_lev_m'<=1
						qui replace `exposure'=1 if (`int_no'-5)/`num_lev_m'>1
					}
				********************************************************************************************************************************************************************************************************
				}	
			}
			if "`linexp'"!="" {
				forvalues i=1/`nint' {
					qui replace `int_no'=`i' if _n>`M' & _n<=`N'
					if "`moreMC'"=="" {
						qui replace `exposure'=`exposure'[_n-`oldN'-(`i'-1)*`simulations'] if _n>`M' & _n<=`N'
					}
					else {
						local RA=ceil(`simulations'/`oldN')
						forvalues ra=1(1)`RA' {
							qui replace `exposure'=`exposure'[_n-`ra'*`oldN'-(`i'-1)*`simulations'] if _n>`M' & _n<=`N' & `int_no'[_n-`ra'*`oldN'-(`i'-1)*`simulations']==0
						}
					}
					if `i'==1 | `i'==3 | `i'==5 {
						qui replace `exposure'=`exposure'+1 if `int_no'==`i'
					}
					if (`i'==4 & "`control'"=="") | (`i'==6 & "`control'"!="") {
						tempvar randomorder
						tempvar originalorder
						gen `originalorder'=_n
						gen `randomorder'=uniform()
						sort `int_no' `randomorder'
						if "`moreMC'"=="" {
							qui replace `exposure'=`exposure'[_n-`oldN'-(`i'-1)*`simulations'] if `int_no'==`i'
						}
						else {
							local RA=ceil(`simulations'/`oldN')
							forvalues ra=1(1)`RA' {
								qui replace `exposure'=`exposure'[_n-`ra'*`oldN'-(`i'-1)*`simulations'] if `int_no'==`i' & `int_no'[_n-`ra'*`oldN'-(`i'-1)*`simulations']==0
							}
						}
						sort `originalorder'
					}
					local M=`N'
					local N=`N'+`simulations'
				}
			}
			if "`oce'"!="" {
				qui tab `exposure', matrow(_matrow)
				local nexplevels=r(r)-1
				forvalues i=1/`nint' {
					if `i'==1 | `i'==3 | `i'==5 {
						forvalues j=1/`nexplevels' {
							local checkbase=0
							forvalues jj=1/`j' {
								local kk=_matrow[`jj',1]
								if `kk'==`baseline1' {
									local checkbase=1
								}
							}
							if `checkbase'==0 {
								local k=_matrow[`j',1]
							}
							else {
								local kkk=`j'+1
								local k=_matrow[`kkk',1]
							}
							qui replace `int_no'=`i' if _n>`M' & _n<=`N'
							qui replace `exposure'=`k' if _n>`M' & _n<=`N'
							local M=`N'
							local N=`N'+`simulations'
						}
					}
					else {
						qui replace `int_no'=`i' if _n>`M' & _n<=`N'
						qui replace `exposure'=`baseline1' if _n>`M' & _n<=`N'
						local M=`N'
						local N=`N'+`simulations'
					}
					if `i'==6 & "`boceam'"=="" {
					********************************************************************************************************************************************************************************************************
						qui count if `int_no'<6 & `int_no'>0
						local missout=r(N)
						tempvar randomorder
						tempvar originalorder
						gen `originalorder'=_n
						gen `randomorder'=uniform()
						sort `int_no' `randomorder'
						if "`moreMC'"=="" {
							qui replace `exposure'=`exposure'[_n-`oldN'-`missout'] if `int_no'==6
						}
						else {
							local RA=ceil(`simulations'/`oldN')
							forvalues ra=1(1)`RA' {
								qui replace `exposure'=`exposure'[_n-`ra'*`oldN'-`missout'] if `int_no'==6  & `int_no'[_n-`ra'*`oldN'-`missout']==0
							}
						}
						sort `originalorder'
					********************************************************************************************************************************************************************************************************
					}
					if `i'==4 & "`control'"=="" & "`boceam'"=="" {
					********************************************************************************************************************************************************************************************************
						qui count if `int_no'<4 & `int_no'>0
						local missout=r(N)
						tempvar randomorder
						tempvar originalorder
						gen `originalorder'=_n
						gen `randomorder'=uniform()
						sort `int_no' `randomorder'
						if "`moreMC'"=="" {
							qui replace `exposure'=`exposure'[_n-`oldN'-`missout'] if `int_no'==4
						}
						else {
							local RA=ceil(`simulations'/`oldN')
							forvalues ra=1(1)`RA' {
								qui replace `exposure'=`exposure'[_n-`ra'*`oldN'-`missout'] if `int_no'==4 & `int_no'[_n-`ra'*`oldN'-`missout']==0
							}
						}
						sort `originalorder'
					********************************************************************************************************************************************************************************************************
					}
					if "`boceam'"!="" {
					********************************************************************************************************************************************************************************************************
						qui tab `exposure' `mediator', matrow(matem1) matcol(matem2)
						local num_lev_e=rowsof(matem1)
						local num_lev_m=colsof(matem2)
						if "`control'"=="" {
							forvalues lev_e=1(1)`num_lev_e' {
								qui replace `exposure'=matem1[`lev_e',1] if (`int_no'-3)/`num_lev_m'<=`lev_e' & (`int_no'-3)/`num_lev_m'>`lev_e'-1
							}
						}
						else {
							forvalues lev_e=1(1)`num_lev_e' {
								qui replace `exposure'=matem1[`lev_e',1] if (`int_no'-5)/`num_lev_m'<=`lev_e' & (`int_no'-5)/`num_lev_m'>`lev_e'-1
							}

						}
					********************************************************************************************************************************************************************************************************
					}
				}
			}
		}
        forvalues j=1/`nmed' {
            tokenize "`mediator'"
			if "`control'"!="" {
				capture qui replace ``j''=`control`j'' if `int_no'==3 | `int_no'==4
			}
			if "`oce'"=="" {
				local nexplevels=1
			}
			if "`control'"!="" & "`msm'"!="" & "`boceam'"==""{
				********************************************************************************************************************************************************************************************************
				tempvar randomorder
				tempvar originalorder
				gen `originalorder'=_n
				gen `randomorder'=uniform()
				sort `int_no' `randomorder'
				if "`moreMC'"=="" {
					capture qui replace ``j''=``j''[_n-`oldN'-(3*`nexplevels'+2)*`simulations'] if `int_no'==6
				}
				else {
					local RA=ceil(`simulations'/`oldN')
					forvalues ra=1(1)`RA' {
						capture qui replace ``j''=``j''[_n-`ra'*`oldN'-(3*`nexplevels'+2)*`simulations'] if `int_no'==6 & `int_no'[_n-`ra'*`oldN'-(3*`nexplevels'+2)*`simulations']==0
					}
				}
				sort `originalorder'
				********************************************************************************************************************************************************************************************************
			}
			if "`control'"=="" & "`msm'"!="" & "`boceam'"=="" {
				********************************************************************************************************************************************************************************************************
				tempvar randomorder
				tempvar originalorder
				gen `originalorder'=_n
				gen `randomorder'=uniform()
				sort `int_no' `randomorder'
				if "`moreMC'"=="" {
					capture qui replace ``j''=``j''[_n-`oldN'-(2*`nexplevels'+1)*`simulations'] if `int_no'==4
				}
				else {
					local RA=ceil(`simulations'/`oldN')
					forvalues ra=1(1)`RA' {
						capture qui replace ``j''=``j''[_n-`ra'*`oldN'-(2*`nexplevels'+1)*`simulations'] if `int_no'==4 & `int_no'[_n-`ra'*`oldN'-(2*`nexplevels'+1)*`simulations']==0
					}
				}
				sort `originalorder'
				********************************************************************************************************************************************************************************************************
			}
			if "`msm'"!="" & "`boceam'"!=""{
				********************************************************************************************************************************************************************************************************
				qui tab `exposure' `mediator', matrow(matem1) matcol(matem2)
				local num_lev_e=rowsof(matem1)
				local num_lev_m=colsof(matem2)
				if "`control'"=="" {
					forvalues lev_m=1(1)`num_lev_m' {
						qui replace ``j''=matem2[1,`lev_m'] if mod(`int_no'-3,`num_lev_m')==mod(`lev_m',`num_lev_m') & `int_no'>=4
					}
				}
				else {
					forvalues lev_m=1(1)`num_lev_m' {
						qui replace ``j''=matem2[1,`lev_m'] if mod(`int_no'-5,`num_lev_m')==mod(`lev_m',`num_lev_m') & `int_no'>=6
					}
				}
				********************************************************************************************************************************************************************************************************
			}
        }
		tempvar msm_switch_on
		gen `msm_switch_on'=0
		if "`control'"=="" {
			qui replace `msm_switch_on'=1 if `int_no'>=4
		}
		else {
			qui replace `msm_switch_on'=1 if `int_no'>=6
		}
		if "`msm'"!="" & "`boceam'"!="" & "`control'"!="" & ("`oce'"!="" | "`obe'"!="") {
			qui replace `msm_switch_on'=1 if `int_no'==3 | `int_no'==4
			qui count if `int_no'<3
			local int_start_a1=r(N)
			qui count if `int_no'<6
			local int_start_b1=r(N)
			qui count if `int_no'==3 | `int_no'==4
			local max_a=round(r(N)/`simulations',1)
			qui count if `int_no'>=6
			local max_b=round(r(N)/`simulations',1)
			forvalues start_a=1(1)`max_a' {
				forvalues start_b=1(1)`max_b' {
					local check_int_msm=1
					forvalues int_j=1(1)`simulations' {
						local int_k_a`start_a'=`int_start_a`start_a''+`int_j'
						local int_k_b`start_b'=`int_start_b`start_b''+`int_j'
						if `exposure'[`int_k_a`start_a'']!=`exposure'[`int_k_b`start_b''] | `mediator'[`int_k_a`start_a'']!=`mediator'[`int_k_b`start_b''] {
							local check_int_msm=0
						}
					}
					if `check_int_msm'==1 {
						forvalues int_j=1(1)`simulations' {
							local int_k_b`start_b'=`int_start_b`start_b''+`int_j'
							qui replace `msm_switch_on'=0 in `int_k_b`start_b'' 	
						}					
					}
					local start_b_next=`start_b'+1
					local int_start_b`start_b_next'=`int_k_b`start_b''
				}
				local start_a_next=`start_a'+1
				local int_start_a`start_a_next'=`int_k_a`start_a''
			}
		}
    }
	if $check_print==0 {
		noi di as text "{hline 1}" _cont
	}
	   if "`mediation'"=="" {
	   *lagged variables
    		 * detangle lag rules
    		local nlag: word count `laggedvars'	
    		detangle "`lagrules'" lagrule "`laggedvars'"
    		forvalues i=1/`nlag' {
    			local lagvar`i': word `i' of `laggedvars'
    			if "${S_`i'}"!="" {
    				local lagrule`i' ${S_`i'}
    			}
    		}
    		forvalues i=1/`nlag' {
    			tokenize "`lagrule`i''", parse(" ")
    			local lagrulevar`i' "`1'"
    			local lag`i' "`2'"
    		}
    		sort `idvar' `tvar'
    		forvalues i=1/`nlag' {
    			qui by `idvar': replace `lagvar`i''=`lagrulevar`i''[_n-`lag`i''] if `lagvar`i''==.
    		}
    		forvalues i=1/`nlag' {
    			forvalues j=1/`nvar' {
    				qui replace `lagvar`i''=0 if `lagvar`i''==. & `simvar`j''!=.
    			}
    		}
        }
		if $check_print==0 {
			noi di as text "{hline 1}" _cont
		}
		   
	*derived variables
		* detangle derivation rules
		local nder: word count `derived'	
		if `nder'>0 {
			detangle "`derrules'" derrule "`derived'"
			forvalues i=1/`nder' {
				local der`i': word `i' of `derived'
				if "${S_`i'}"!="" {
					local derrule`i' ${S_`i'}
				}
			}
		}
		if $check_print==0 {
			noi di as text "{hline 1}" _cont
		}
		forvalues i=1/`nder' {
			capture qui replace `der`i''=`derrule`i'' if `der`i''==.
			if _rc!=0 {
				local derrule`i'=subinword("`derrule`i''","if","if (",1)+" )"
				capture qui replace `der`i''=`derrule`i'' & `der`i''==.
			}
		}
		if $check_print==0 {
			noi di as text "{hline 1}" _cont
		}
* determine at which visit each variable in varlist2 is to be simulated
if "`mediation'"=="" {
    forvalues i=1/`nvar' {
        forvalues j=1/`maxv' {
            local k=matvis[`j',1]           
            qui count if `simvar`i''!=. & `tvar'==`k'
            if r(N)!=0 {
                local visitcalc`i'_`j'=1
            }
            else {
                local visitcalc`i'_`j'=0
            }
        }
    }
}
if $check_print==0 {
    if "`mediation'"!="" {
        local maxv=1
    }
	local k1=max(floor((`maxv'*`nvar'-9)/2),1)
	local k2=max(ceil((`maxv'*`nvar'-9)/2),1)
	noi di as text "{c RT}"
	noi di
	noi di as text "                                              {c LT}" _cont
	noi di as text "{hline `k1'}" _cont
	noi di as text "PROGRESS" _cont
	noi di as text "{hline `k2'}" _cont
	noi di as text "{c RT}"
	noi di as text "   Fitting parametric models and simulating:  {c LT}" _cont
}
* generate Monte Carlo population
if "`mediation'"=="" {
   	* fit parametric models and simulate according to parameter estimates
	forvalues j=1/`maxv' {
		forvalues i=1/`nvar' {
			if $check_print==0 {
				if `j'==`maxv' & `i'==`nvar' & `maxv'*`nvar'>=11 {
					noi di "{c RT}" _cont
				}	
				else {
					noi di "{hline 1}" _cont
				}
			}
			local k=matvis[`j',1]
			if `visitcalc`i'_`j''==1 {
				forvalues l=1/`nlag' {
					qui replace `lagvar`l''=0 if `lagvar`l''==. & `tvar'==`k' & `int_no'>0
				}
				forvalues l=1/`nder' {
					capture qui replace `der`l''=`derrule`l'' if `der`l''==. & `int_no'>0
					if _rc!=0 {
						local derrule`l'=subinword("`derrule`l''","if","if (",1)+" )"
						capture qui replace `der`l''=`derrule`l'' & `der`l''==. & `int_no'>0
					}
				}
				if `j'==1 & strmatch(" "+"`varyingcovariates'"+" ","* "+"`simvar`i''"+" *")==1 {
					qui replace `simvar`i''=`simvar`i''[_n-`oldN'-(`int_no'-1)*`simulations'*`maxv'] if `simvar`i''==. & `tvar'==`k' & `int_no'>0
				}
				else {
					if "`eofu'"!="" {
						if "`pooled'"=="" {
							if "`monotreat'"=="" | `i'<=`nvar_untilmono' {
								qui `command`i'' `simvar`i'' `equation`i'' if `tvar'==`k' & `int_no'==0
							}
							else {
								if `j'==1 {
									qui `command`i'' `simvar`i'' `equation`i'' if `tvar'==`k' & `int_no'==0
								}
								else {
									qui `command`i'' `simvar`i'' `equation`i'' if `tvar'==`k' & `int_no'==0 & `simvar`i''[_n-1]==0
								}
							}
						}
						else {
							if "`monotreat'"=="" | `i'<=`nvar_untilmono' {
								qui `command`i'' `simvar`i'' `equation`i'' if `int_no'==0
							}
							else {
								tempvar checkmono
								gen `checkmono'=(`int_no'==0)
								qui replace `checkmono'=0 if `idvar'[_n]==`idvar'[_n-1] & `simvar`i''[_n-1]==1
								qui `command`i'' `simvar`i'' `equation`i'' if `checkmono'==0
								drop `checkmono'
							}
						}
*****************************************************************************************************************************************************************************
						if "`command`i''"=="logit" | "`command`i''"=="regress" {
							tempvar pred_simvar`i'
							qui predict `pred_simvar`i''
						}
						else {
							if "`command`i''"=="mlogit" {
								local maxcat=e(k_out)
							}
							if "`command`i''"=="ologit" {
								local maxcat=e(k_cat)
							}
							cap drop ___p*
							qui predict ___p1-___p`maxcat'
						}
*****************************************************************************************************************************************************************************
						if "`command`i''"=="logit" {
							if rtrim(ltrim("`simvar`i''"))==rtrim(ltrim("`outcome'")) & "`minsim'"!="" {
								if "`death'"!="" {
									qui replace `simvar`i''=`pred_simvar`i'' if `simvar`i''==. ///
										& `tvar'==`k' & `death'!=1 & `int_no'>0
								}
								else {
									qui replace `simvar`i''=`pred_simvar`i'' if `simvar`i''==. & `tvar'==`k' & `int_no'>0
								}
							}	
							if rtrim(ltrim("`simvar`i''"))==rtrim(ltrim("`outcome'")) & "`minsim'"=="" {
								if "`death'"!="" {
									qui replace `simvar`i''=uniform()<`pred_simvar`i'' if `simvar`i''==. ///
										& `tvar'==`k' & `death'!=1 & `int_no'>0
								}
								else {
									qui replace `simvar`i''=uniform()<`pred_simvar`i'' if `simvar`i''==. & `tvar'==`k' & `int_no'>0
								}
							}	
							if rtrim(ltrim("`simvar`i''"))!=rtrim(ltrim("`outcome'")) {
								qui replace `simvar`i''=uniform()<`pred_simvar`i'' if `simvar`i''==. & `tvar'==`k' & `int_no'>0
								if "`monotreat'"!="" & `i'>`nvar_untilmono' {
									qui replace `simvar`i''=1 if `simvar`i''[_n-1]==1 & `idvar'[_n]==`idvar'[_n-1] & `int_no'==`nint'+1
								}
							}
							if rtrim(ltrim("`simvar`i''"))==rtrim(ltrim("`death'")) {
								local tc=1
								while `tc'>0 {
									tempvar temp_count
									qui by id: gen `temp_count'=`simvar`i''[_n-1]==1
									qui summ `temp_count'
									local tc=r(mean)*r(N)
									qui by `idvar': drop if `simvar`i''[_n-1]==1
									drop `temp_count'
								}
							}
						}
*****************************************************************************************************************************************************************************
						if ("`command`i''"=="mlogit" | "`command`i''"=="ologit") {
							tempvar umlogitimp
							qui gen `umlogitimp'=uniform()
							tempvar cum_p1 cum_p2
							qui gen `cum_p1'=0
							qui gen `cum_p2'=0
							forvalues cat=1(1)`maxcat' {
								if "`command`i''"=="mlogit" {
									mat catvals=e(out)
								}
								if "`command`i''"=="ologit" {
									mat catvals=e(cat)
								}
								local catval=catvals[1,`cat']
								qui replace `cum_p2'=`cum_p2'+___p`cat'
								if "`death'"!="" & rtrim(ltrim("`simvar`i''"))==rtrim(ltrim("`outcome'")) {
									qui replace `simvar`i''=`catval' if `umlogitimp'>`cum_p1' & `umlogitimp'<`cum_p2' & `simvar`i''==. ///
										& `tvar'==`k' & `death'!=1 & `int_no'>0
								}
								else {
									qui replace `simvar`i''=`catval' if `umlogitimp'>`cum_p1' & `umlogitimp'<`cum_p2' & `simvar`i''==. ///
										& `tvar'==`k' & `int_no'>0
								}
								qui replace `cum_p1'=`cum_p2'
							}
						}
*****************************************************************************************************************************************************************************
						if "`command`i''"=="regress" {
							if rtrim(ltrim("`simvar`i''"))==rtrim(ltrim("`outcome'")) & "`minsim'"!="" {
								if "`death'"!="" {
									qui replace `simvar`i''=`pred_simvar`i'' if `simvar`i''==. & `tvar'==`k' & `death'!=1 & `int_no'>0
								}
								else {
									qui replace `simvar`i''=`pred_simvar`i'' if `simvar`i''==. & `tvar'==`k' & `int_no'>0								
								}
							}	
							if rtrim(ltrim("`simvar`i''"))==rtrim(ltrim("`outcome'")) & "`minsim'"=="" {
								if "`death'"!="" {
									qui replace `simvar`i''=`pred_simvar`i''+e(rmse)*invnormal(uniform()) if `simvar`i''==. & `tvar'==`k' & `death'!=1 & `int_no'>0
								}
								else {
									qui replace `simvar`i''=`pred_simvar`i''+e(rmse)*invnormal(uniform()) if `simvar`i''==. & `tvar'==`k' & `int_no'>0								
								}
							}	
							if rtrim(ltrim("`simvar`i''"))!=rtrim(ltrim("`outcome'")) {
								qui replace `simvar`i''=`pred_simvar`i''+e(rmse)*invnormal(uniform()) if `simvar`i''==. & `tvar'==`k' & `int_no'>0
							}
						}
						if "`command`i''"!="regress" & "`command`i''"!="logit" & "`command`i''"!="mlogit" & "`command`i''"!="ologit" {
							noi di as err "Error: only regress, logit, mlogit and ologit are supported as simulation commands in gformula."
							exit 198
						}
					}
					else {
						if rtrim(ltrim("`simvar`i''"))==rtrim(ltrim("`outcome'")) | ///
							rtrim(ltrim("`simvar`i''"))==rtrim(ltrim("`death'")) {
							if "`pooled'"=="" {
								qui `command`i'' `simvar`i'' `equation`i'' if `tvar'==`k'  & `int_no'==0
							}
							else {
								qui `command`i'' `simvar`i'' `equation`i''  if `int_no'==0
							}
*****************************************************************************************************************************************************************************
							if "`command`i''"=="logit" | "`command`i''"=="regress" {
								tempvar pred_simvar`i'
								qui predict `pred_simvar`i''
							}
							else {
								if "`command`i''"=="mlogit" {
									local maxcat=e(k_out)
								}
								if "`command`i''"=="ologit" {
									local maxcat=e(k_cat)
								}
								cap drop ___p*
								qui predict ___p1-___p`maxcat'
							}
*****************************************************************************************************************************************************************************
							if "`command`i''"=="logit" {
								if "`death'"!="" & rtrim(ltrim("`simvar`i''"))==rtrim(ltrim("`outcome'")) {
									qui replace `simvar`i''=uniform()<`pred_simvar`i'' if `simvar`i''==. ///
										& `tvar'==`k' & `death'!=1 & `int_no'>0
								}
								else {
									qui replace `simvar`i''=uniform()<`pred_simvar`i'' if `simvar`i''==. & `tvar'==`k' & `int_no'>0
								}
								local tc=1
								while `tc'>0 {
									tempvar temp_count
									qui by id: gen `temp_count'=`simvar`i''[_n-1]==1
									qui summ `temp_count'
									local tc=r(mean)*r(N)
									qui by `idvar': drop if `simvar`i''[_n-1]==1
									drop `temp_count'
								}
							}
*****************************************************************************************************************************************************************************
							if "`command`i''"=="mlogit" | "`command`i''"=="ologit" {
								tempvar umlogitimp
								qui gen `umlogitimp'=uniform()
								tempvar cum_p1 cum_p2
								qui gen `cum_p1'=0
								qui gen `cum_p2'=0
								forvalues cat=1(1)`maxcat' {
									if "`command`i''"=="mlogit" {
										mat catvals=e(out)
									}
									if "`command`i''"=="ologit" {
										mat catvals=e(cat)
									}
									local catval=catvals[1,`cat']
									qui replace `cum_p2'=`cum_p2'+___p`cat'
									if "`death'"!="" & rtrim(ltrim("`simvar`i''"))==rtrim(ltrim("`outcome'")) {
										qui replace `simvar`i''=`catval' if `umlogitimp'>`cum_p1' & `umlogitimp'<`cum_p2' & `simvar`i''==. ///
											& `tvar'==`k' & `death'!=1 & `int_no'>0
									}
									else {
										qui replace `simvar`i''=`catval' if `umlogitimp'>`cum_p1' & `umlogitimp'<`cum_p2' & `simvar`i''==. ///
											& `tvar'==`k' & `int_no'>0
									}
									qui replace `cum_p1'=`cum_p2'
								}
							}
*****************************************************************************************************************************************************************************
							if "`command`i''"=="regress" {
								if "`death'"!="" & rtrim(ltrim("`simvar`i''"))==rtrim(ltrim("`outcome'")) {
									qui replace `simvar`i''=`pred_simvar`i''+e(rmse)*invnormal(uniform()) if `simvar`i''==. & `tvar'==`k' ///
										& `death'!=1 & `int_no'>0
								}
								else {
									qui replace `simvar`i''=`pred_simvar`i''+e(rmse)*invnormal(uniform()) if `simvar`i''==. & `tvar'==`k' & `int_no'>0
								}
							}
							if "`command`i''"!="regress" & "`command`i''"!="logit" & "`command`i''"!="mlogit" & "`command`i''"!="ologit" {
								noi di as err "Error: only regress, logit, mlogit and ologit are supported as simulation commands in gformula."
								exit 198
							}
						}
						else {
							if "`pooled'"=="" {
								if "`monotreat'"=="" | `i'<=`nvar_untilmono' {
									qui `command`i'' `simvar`i'' `equation`i'' if `tvar'==`k' & `int_no'==0
								}
								else {
									if `j'==1 {
										qui `command`i'' `simvar`i'' `equation`i'' if `tvar'==`k' & `int_no'==0
									}
									else {
										qui `command`i'' `simvar`i'' `equation`i'' if `tvar'==`k' & `int_no'==0 & `simvar`i''[_n-1]==0
									}
								}
							}
							else {
								if "`monotreat'"=="" | `i'<=`nvar_untilmono' {
									qui `command`i'' `simvar`i'' `equation`i'' if `int_no'==0
								}
								else {
									tempvar checkmono
									gen `checkmono'=(`int_no'==0)
									qui replace `checkmono'=0 if `idvar'[_n]==`idvar'[_n-1] & `simvar`i''[_n-1]==1
									qui `command`i'' `simvar`i'' `equation`i'' if `checkmono'==0
									drop `checkmono'
								}
							}
*****************************************************************************************************************************************************************************
							if "`command`i''"=="logit" | "`command`i''"=="regress" {
								tempvar pred_simvar`i'
								qui predict `pred_simvar`i''
							}
							else {
								if "`command`i''"=="mlogit" {
									local maxcat=e(k_out)
								}
								if "`command`i''"=="ologit" {
									local maxcat=e(k_cat)
								}
								cap drop ___p*
								qui predict ___p1-___p`maxcat'
							}
*****************************************************************************************************************************************************************************
							if "`command`i''"=="logit" {
								qui replace `simvar`i''=uniform()<`pred_simvar`i'' if `simvar`i''==. & `tvar'==`k' & `int_no'>0
							}
*****************************************************************************************************************************************************************************
							if "`command`i''"=="mlogit" | "`command`i''"=="ologit" {
								tempvar umlogitimp
								qui gen `umlogitimp'=uniform()
								tempvar cum_p1 cum_p2
								qui gen `cum_p1'=0
								qui gen `cum_p2'=0
								forvalues cat=1(1)`maxcat' {
									if "`command`i''"=="mlogit" {
										mat catvals=e(out)
									}
									if "`command`i''"=="ologit" {
										mat catvals=e(cat)
									}
									local catval=catvals[1,`cat']
									qui replace `cum_p2'=`cum_p2'+___p`cat'
									qui replace `simvar`i''=`catval' if `umlogitimp'>`cum_p1' & `umlogitimp'<`cum_p2' & `simvar`i''==. ///
											& `tvar'==`k' & `int_no'>0
									qui replace `cum_p1'=`cum_p2'
								}
							}
*****************************************************************************************************************************************************************************
							if "`command`i''"=="regress" {
								qui replace `simvar`i''=`pred_simvar`i''+e(rmse)*invnormal(uniform()) if `simvar`i''==. & `tvar'==`k' & `int_no'>0
							}	
							if "`command`i''"!="regress" & "`command`i''"!="logit" & "`command`i''"!="mlogit" & "`command`i''"!="ologit" {
								noi di as err "Error: only regress, logit, mlogit and ologit are supported as simulation commands in gformula."
								exit 198
							}
						}
					}
				}
			}
			*update derived variables
			forvalues ii=1/`nder' {
				capture qui replace `der`ii''=`derrule`ii'' if `der`ii''==. & `int_no'>0
				if _rc!=0 {
					local derrule`ii'=subinword("`derrule`ii''","if","if (",1)+" )"
					capture qui replace `der`ii''=`derrule`ii'' & `der`ii''==. & `int_no'>0
				}
			}
			*update lagged variables
			sort `idvar' `tvar'
			forvalues ii=1/`nlag' {
				qui by `idvar': replace `lagvar`ii''=`lagrulevar`ii''[_n-`lag`ii''] if `lagvar`ii''==.
				qui replace `lagvar`ii''=0 if `tvar'==`firstv' & `int_no'>0
				if `lag`ii''>1 {
					forvalues next=2/`lag`ii'' {
						local nextv=matvis[`next',1]
						qui replace `lagvar`ii''=0 if `tvar'==`nextv' & `int_no'>0
					}
				}
			}
			*update intervention variables (needed if interventions are dynamic)
			forvalues ii=1/`nint' {
				forvalues jj=1/`nintcomp`i'' {
					capture qui replace `intcomp`ii'`jj'' if `int_no'==`ii'
					if _rc!=0 {
						local intcomp`ii'`jj'=subinword("`intcomp`ii'`jj''","if","if (",1)+" )"
						capture qui replace `intcomp`ii'`jj'' & `int_no'==`ii'
					}
				}
			}
			*update lagged variables (in case they depend on intervention variables)
			sort `idvar' `tvar'
			forvalues ii=1/`nlag' {
				qui by `idvar': replace `lagvar`ii''=`lagrulevar`ii''[_n-`lag`ii''] if `int_no'>0
				qui replace `lagvar`ii''=0 if `tvar'==`firstv' & `int_no'>0
				if `lag`ii''>1 {
					forvalues next=2/`lag`ii'' {
						local nextv=matvis[`next',1]
						qui replace `lagvar`ii''=0 if `tvar'==`nextv' & `int_no'>0
					}
				}
			}
			*update derived variables again (in case they depend on intervention variables)
			forvalues ii=1/`nder' {
				capture qui replace `der`ii''=`derrule`ii'' if `int_no'>0
			}
		}  
	}
}
else {
   	* fit parametric models and simulate according to parameter estimates
   	forvalues i=1/`nvar' {
   		if $check_print==0 {
  			if `i'==`nvar' & `nvar'>=11 {
  				noi di "{c RT}" _cont
  			}
   			else {
   				noi di "{hline 1}" _cont
   			}
   		}
		forvalues l=1/`nder' {
   			capture qui replace `der`l''=`derrule`l'' if `der`l''==.
			if _rc!=0 {
				local derrule`l'=subinword("`derrule`l''","if","if (",1)+" )"
				capture qui replace `der`l''=`derrule`l'' & `der`l''==.
			}
		}
		qui `command`i'' `simvar`i'' `equation`i'' if  `int_no'==0
		
*****************************************************************************************************************************************************************************
		if "`command`i''"=="logit" | "`command`i''"=="regress" {
			tempvar pred_simvar`i'
			qui predict `pred_simvar`i''
		}
		else {
			if "`command`i''"=="mlogit" {
				local maxcat=e(k_out)
			}
			if "`command`i''"=="ologit" {
				local maxcat=e(k_cat)
			}
			cap drop ___p*
			qui predict ___p1-___p`maxcat'
		}
*****************************************************************************************************************************************************************************
		if "`command`i''"=="logit" {
			if rtrim(ltrim("`simvar`i''"))==rtrim(ltrim("`outcome'")) & "`minsim'"!="" {
				if "`moreMC'"=="" {
					qui replace `simvar`i''=`simvar`i''[_n-`oldN'-`simulations'] if `simvar`i''==. & `int_no'==2 & "`linexp'"!=""
					qui replace `simvar`i''=`pred_simvar`i'' if `simvar`i''==.
				}
				else {
					local RA=ceil(`simulations'/`oldN')
					forvalues ra=1(1)`RA' {
						qui replace `simvar`i''=`simvar`i''[_n-`ra'*`oldN'-`simulations'] if `simvar`i''==. & `int_no'==2 & "`linexp'"!="" & `int_no'[_n-`ra'*`oldN'-`simulations']==0
						qui replace `simvar`i''=`pred_simvar`i'' if `simvar`i''==.
					}
				}
			}
			else {
				qui replace `simvar`i''=uniform()<`pred_simvar`i'' if `simvar`i''==.				
			}
		}
*****************************************************************************************************************************************************************************
		if "`command`i''"=="mlogit" | "`command`i''"=="ologit" {
			tempvar umlogitimp
			qui gen `umlogitimp'=uniform()
			tempvar cum_p1 cum_p2
			qui gen `cum_p1'=0
			qui gen `cum_p2'=0
			forvalues cat=1(1)`maxcat' {
				if "`command`i''"=="mlogit" {
					mat catvals=e(out)
				}
				if "`command`i''"=="ologit" {
					mat catvals=e(cat)
				}				
				local catval=catvals[1,`cat']
				qui replace `cum_p2'=`cum_p2'+___p`cat'
				qui replace `simvar`i''=`catval' if `umlogitimp'>`cum_p1' & `umlogitimp'<`cum_p2' & `simvar`i''==.
				if "`moreMC'"=="" {
					qui replace `simvar`i''=`simvar`i''[_n-`oldN'-`simulations'] if `int_no'==2 & "`linexp'"!="" & rtrim(ltrim("`simvar`i''"))==rtrim(ltrim("`outcome'"))
				}
				else {
					local RA=ceil(`simulations'/`oldN')
					forvalues ra=1(1)`RA' {
						qui replace `simvar`i''=`simvar`i''[_n-`ra'*`oldN'-`simulations'] if `int_no'==2 & "`linexp'"!="" & rtrim(ltrim("`simvar`i''"))==rtrim(ltrim("`outcome'")) & `int_no'[_n-`ra'*`oldN'-`simulations']==0
					}
				}
				qui replace `cum_p1'=`cum_p2'
			}
		}
*****************************************************************************************************************************************************************************
		if "`command`i''"=="regress" {
			if rtrim(ltrim("`simvar`i''"))==rtrim(ltrim("`outcome'")) & "`minsim'"!="" {
				if "`moreMC'"=="" {
					qui replace `simvar`i''=`simvar`i''[_n-`oldN'-`simulations'] if `simvar`i''==. & `int_no'==2 & "`linexp'"!=""
				}
				else {
					local RA=ceil(`simulations'/`oldN')
					forvalues ra=1(1)`RA' {
						qui replace `simvar`i''=`simvar`i''[_n-`ra'*`oldN'-`simulations'] if `simvar`i''==. & `int_no'==2 & "`linexp'"!="" & `int_no'[_n-`ra'*`oldN'-`simulations']==0
					}
				}
				qui replace `simvar`i''=`pred_simvar`i'' if `simvar`i''==.
			}
			else {
				tempvar helpU
				qui gen `helpU'=invnormal(uniform()) if _n<=`simulations'
				qui replace `simvar`i''=`pred_simvar`i''+e(rmse)*`helpU'[`subjectid'] if `simvar`i''==.
			}
		}
		if "`command`i''"!="regress" & "`command`i''"!="logit" & "`command`i''"!="mlogit" & "`command`i''"!="ologit" {
			noi di as err "Error: only regress, logit, mlogit and ologit are supported as simulation commands in gformula."
			exit 198
		}
        forvalues k=1/`nmed' {
            tokenize "`mediator'"
            if "`simvar`i''"=="``k''" {
				if "`command`i''"=="logit" {
					qui replace `simvar`i''=uniform()<`pred_simvar`i''[_n+`simulations'] if `int_no'==1
					if "`moreMC'"=="" {
						qui replace `simvar`i''=`simvar`i''[_n-`oldN'] if `int_no'==1 & "`linexp'"!="" & "`minsim'"!=""
					}
					else {
						local RA=ceil(`simulations'/`oldN')
						forvalues ra=1(1)`RA' {
							qui replace `simvar`i''=`simvar`i''[_n-`ra'*`oldN'] if `int_no'==1 & "`linexp'"!="" & "`minsim'"!="" & `int_no'[_n-`ra'*`oldN']==0
						}	
					}
				}
*****************************************************************************************************************************************************************************
				if "`command`i''"=="mlogit" | "`command`i''"=="ologit" {
					tempvar umlogitimp
					qui gen `umlogitimp'=uniform()
					tempvar cum_p1 cum_p2
					qui gen `cum_p1'=0
					qui gen `cum_p2'=0
					forvalues cat=1(1)`maxcat' {
						if "`command`i''"=="mlogit" {
							mat catvals=e(out)
						}
						if "`command`i''"=="ologit" {
							mat catvals=e(cat)
						}
						local catval=catvals[1,`cat']
						qui replace `cum_p2'=`cum_p2'+___p`cat'
						qui replace `simvar`i''=`catval' if `umlogitimp'>`cum_p1'[_n+`simulations'] & `umlogitimp'<`cum_p2'[_n+`simulations'] & `int_no'==1
						if "`moreMC'"=="" {
							qui replace `simvar`i''=`simvar`i''[_n-`oldN'] if `int_no'==1 & "`linexp'"!="" & "`minsim'"!=""
						}
						else {
							local RA=ceil(`simulations'/`oldN')
							forvalues ra=1(1)`RA' {
								qui replace `simvar`i''=`simvar`i''[_n-`ra'*`oldN'] if `int_no'==1 & "`linexp'"!="" & "`minsim'"!="" & `int_no'[_n-`ra'*`oldN']==0
							}	
						}
						qui replace `cum_p1'=`cum_p2'
					}
				}
*****************************************************************************************************************************************************************************
				if "`command`i''"=="regress" {
					tempvar helpU2
					qui gen `helpU2'=invnormal(uniform()) if _n<=`simulations'
					qui replace `simvar`i''=`pred_simvar`i''[_n+`simulations']+e(rmse)*`helpU2'[`subjectid'] if `int_no'==1
					if "`moreMC'"=="" {
						qui replace `simvar`i''=`simvar`i''[_n-`oldN'] if `int_no'==1 & "`linexp'"!="" & "`minsim'"!=""
					}
					else {
						local RA=ceil(`simulations'/`oldN')
						forvalues ra=1(1)`RA' {
							qui replace `simvar`i''=`simvar`i''[_n-`ra'*`oldN'] if `int_no'==1 & "`linexp'"!="" & "`minsim'"!="" & `int_no'[_n-`ra'*`oldN']==0
						}	
					}
				}
				if "`command`i''"!="regress" & "`command`i''"!="logit" & "`command`i''"!="mlogit" & "`command`i''"!="ologit" {
					noi di as err "Error: only regress, logit, mlogit and ologit are supported as simulation commands in gformula."
					exit 198
				}
            }
        }
	}  
   	*update derived variables
   	forvalues i=1/`nder' {
   		capture qui replace `der`i''=`derrule`i'' if `der`i''==.
   		if _rc!=0 {
			local derrule`i'=subinword("`derrule`i''","if","if (",1)+" )"
			capture qui replace `der`i''=`derrule`i'' & `der`i''==.
   		}
   	}
}
if $check_print==0 {
    if "`mediation'"!="" {
        local maxv=1
    }
	if `maxv'*`nvar'<11 {
		local k3=10-`maxv'*`nvar'
		noi di _dup(`k3') "{hline 1}" _cont
		noi di "{c RT}" _cont
	}
    if "`mediation'"=="" {
		noi di
		noi di as text "                                              {c LT}" _cont
		noi di as text "{hline `k1'}" _cont
		noi di as text "PROGRESS" _cont
		noi di as text "{hline `k2'}" _cont
		noi di as text "{c RT}"
    	if "`eofu'"!="" {
    		noi di as text "   Estimating mean potential outcomes:        {c LT}" _cont
    	}
    	else {
	   		noi di as text "   Estimating average log incidence rates:    {c LT}" _cont
    	}
    }
}
if "`mediation'"=="" {
    if "`eofu'"!="" {
    	qui regress `outcome' i.`int_no'
		tempname EPO noomit
	    mat `EPO'=e(b)
		_ms_omit_info `EPO'
		local cols = colsof(`EPO')
		matrix `noomit' =  J(1,`cols',1) - r(omit)
		mata: EPO = select(st_matrix(st_local("EPO")),(st_matrix(st_local("noomit"))))
		mata: st_matrix(st_local("EPO"),EPO)
		mat EPO=`EPO'
    	if $check_print==0 {
    		noi di as text "{hline 10}{c RT}"
    	}
    }
    else {
    	qui stset `tvar', id(`idvar') failure(`outcome')
    	qui streg i.`int_no', nohr dist(e)
		tempname EPO noomit
	    mat `EPO'=e(b)
		_ms_omit_info `EPO'
		local cols = colsof(`EPO')
		matrix `noomit' =  J(1,`cols',1) - r(omit)
		mata: EPO = select(st_matrix(st_local("EPO")),(st_matrix(st_local("noomit"))))
		mata: st_matrix(st_local("EPO"),EPO)
		mat EPO=`EPO'
    	if $check_print==0 {
    		if "`graph'"!="" {
    			local leglab " legend(lab(1 Observational data) "			
    			forvalues i=1/`nint' {
    				local j=`i'+1
    				local leglab="`leglab'"+"lab("+"`j'"+" Int. "+"`i'"+") "
    			}
   				local leglab="`leglab'"+"lab("+"`nintplus2'"+" No intervention))"
    			sts graph, by(`int_no') noshow nodraw `leglab'
    		}
    		noi di as text "{hline 10}{c RT}"
			noi di
			noi di as text "                                              {c LT}{hline 1}PROGRESS{hline 1}{c RT}"
			noi di as text "   Estimating cumulative incidences:          {c LT}" _cont    
		}
		tempvar tag
		qui egen `tag'=tag(`idvar')
		local nintplus1=`nint'+1
		qui sort `int_no' `idvar' `tvar'
		forvalues i=0/`nintplus1' {
			qui count if `tag'==1 & `int_no'==`i'
			local tot`i'=r(N)
			if `i'==0 {
				qui count if _d!=1 & `idvar'[_n]!=`idvar'[_n+1] & `int_no'==0
				local d_or_c0=r(N)
				if "`death'"=="" {
					qui count if `outcome'==0 & `outcome'[_n+1]==. & `int_no'==0 & `tvar'!=`maxvlab'
					local ltfu0=r(N)
					qui count if `outcome'==. & `outcome'[_n+1]==. & `int_no'==0 & `tvar'==`firstv'
					local ltfu0=`ltfu0'+r(N)
				}
				else {
					qui count if `outcome'==0 & `death'==0 & `outcome'[_n+1]==. & `death'[_n+1]==. & `int_no'==0 & `tvar'!=`maxvlab'
					local ltfu0=r(N)
					qui count if `outcome'==. & `death'==. & `outcome'[_n+1]==. & `death'[_n+1]==. & `int_no'==0 & `tvar'==`firstv'
					local ltfu0=`ltfu0'+r(N)
				}
			}
			qui count if `outcome'==1 & `int_no'==`i'
			if `i'==0 {
				local tot0=r(N)+`d_or_c0'
				local out_0=r(N)
			}
			else {
				local out_`i'=r(N)/`tot`i''
			}
			if "`death'"!="" {
				qui count if `death'==1 & `int_no'==`i' 
				if `i'==0 {
					local c_at_end_0=`d_or_c0'-r(N)-`ltfu0'
					local ltfu0=`ltfu0'/`tot0'
					local out_0=`out_0'/`tot0'
				}
				local d_`i'=r(N)/`tot`i''
			}
			else {
				if `i'==0 {
					local out_0=`out_0'/`tot0'
					local c_at_end_0=`d_or_c0'-`ltfu0'
					local ltfu0=`ltfu0'/`tot0'
				}
			}
		}
    }
    local nintplus1=`nint'+1
    local nintplus2=`nint'+2
    forvalues i=1/`nintplus1' {
    	mat EPO[1,`i']=EPO[1,`i']+EPO[1,`nintplus2']
    }
   	if $check_print==0 {
   		noi di as text "{hline 10}{c RT}"
	}
    if "`msm'"!="" {
    	if $check_print==0 {
			noi di
    		noi di as text "                                              {c LT}{hline 1}PROGRESS{hline 1}{c RT}"
    		noi di as text "   Estimating parameters of MSM:              {c LT}" _cont
    	}
    	qui capture `msm' if `int_no'!=0 & `int_no'!=`nintplus1'
    	if _rc>0 {
    		tokenize "`msm'", parse(",")
    		qui `1' if `int_no'!=0 & `int_no'!=`nintplus1' `2' `3'
    	}
		tempname msm_params noomit
	    mat `msm_params'=e(b)
		_ms_omit_info `msm_params'
		local cols = colsof(`msm_params')
		matrix `noomit' =  J(1,`cols',1) - r(omit)
		mata: msm_params = select(st_matrix(st_local("msm_params")),(st_matrix(st_local("noomit"))))
		mata: st_matrix(st_local("msm_params"),msm_params)
		mat msm_params=`msm_params'
    	local colnames: colfullnames msm_params
    	tokenize "`colnames'", parse(" ")
    	local nparams 0 			
    	while "`1'"!="" {
    		if "`1'"!=" " {
    			local nparams=`nparams'+1
    			local colname`nparams'=substr(substr("`1'",strpos("`1'",":")+1,.), ///
                    strpos(substr("`1'",strpos("`1'",":")+1,.),".")+1,.)
    		}
    		mac shift
    	}
		return clear
    	forvalues i=1/`nparams' {
    		local p`i'=msm_params[1,`i']
    		return scalar `colname`i''=`p`i''
    	}
    	return scalar N_msm_params=`nparams'
    	if $check_print==0 {
    		noi di as text "{hline 10}{c RT}"
    		if e(cmd)=="cox" {
    			noi di
    			noi di as err "   Note: MSM results will be reported on the log hazard scale, irrespective of whether or not the " as result "nohr" as err " option was" 
    			noi di as err "   specified" 
    		}
    		if e(cmd)=="logit" {
    			noi di
    			noi di as err "   Note: MSM results will be reported on the log odds scale, irrespective of whether or not the " as result "or" as err " option was specified" 
    		}
    	}
    }
    local nb=colsof(EPO)-1
    forvalues i=1/`nb' {
    	local PO`i'=EPO[1,`i']
    	return scalar PO`i'=`PO`i''
    }
    local PO0=EPO[1,`nb'+1]
    return scalar PO0=`PO0'
    return scalar N_PO=`nb'
	if "`mediation'"=="" {
	    if "`eofu'"=="" {
			forvalues i=0/`nintplus1' {
				return scalar out`i'=`out_`i'' 
				if "`death'"!="" {
					return scalar death`i'=`d_`i'' 
				}
			}
			return scalar ltfu0=`ltfu0' 
		}
	}
}
else {
	if "`oce'"=="" {
		if $check_print==0 {
			noi di
			noi di
    		noi di as text "                                              {c LT}{hline 1}PROGRESS{hline 1}{c RT}"
    		noi di as text "   Estimating direct/indirect effects:        {c LT}" _cont
    	}
		if "`control'"=="" {
			qui summ `outcome' if `int_no'==3
		}
		else {
			qui summ `outcome' if `int_no'==5
		}
		local e0=r(mean)
		qui summ `outcome' if `int_no'==1
		local e1=r(mean)
		qui summ `outcome' if `int_no'==2
		local e2=r(mean)
		if "`control'"!="" {
			qui summ `outcome' if `int_no'==3
			local e3=r(mean)
			qui summ `outcome' if `int_no'==4
			local e4=r(mean)
		}
		else {
			local e3=0
			local e4=0
		}
		if $check_print==0 {
			noi di as text "{hline 10}{c RT}"
		}
		local tce=`e0'-`e2'
		local nde=`e1'-`e2'
		local nie=`tce'-`nde'
		local cde=`e3'-`e4'
		return clear
		return scalar tce=`tce'
		return scalar nde=`nde'
		return scalar nie=`nie'
		return scalar cde=`cde'
	}
	else {
		if $check_print==0 {
			noi di
			noi di
    		noi di as text "                                              {c LT}{hline 1}PROGRESS{hline 1}{c RT}"
    		noi di as text "   Estimating direct/indirect effects:        {c LT}" _cont
    	}
		qui tab `exposure', matrow(_matrow)
		local nexplev=r(r)-1
		forvalues j=1/`nexplev' {
			local checkbase=0
			forvalues jj=1/`j' {
				local kk=_matrow[`jj',1]
				if `kk'==`baseline1' {
					local checkbase=1
				}
			}
			if `checkbase'==0 {
				local k=_matrow[`j',1]
			}
			else {
				local kkk=`j'+1
				local k=_matrow[`kkk',1]
			}
			if "`control'"=="" {
				qui summ `outcome' if `int_no'==3 & `exposure'==`k'
			}
			else {
				qui summ `outcome' if `int_no'==5 & `exposure'==`k'
			}
			local e0_`j'=r(mean)
			qui summ `outcome' if `int_no'==1 & `exposure'==`k'
			local e1_`j'=r(mean)
			qui summ `outcome' if `int_no'==2
			local e2=r(mean)
			if "`control'"!="" {
				qui summ `outcome' if `int_no'==3 & `exposure'==`k'
				local e3_`j'=r(mean)
				qui summ `outcome' if `int_no'==4
				local e4=r(mean)
			}
			else {
				local e3_`j'=0
				local e4=0
			}
			return clear
			local tce_`j'=`e0_`j''-`e2'
			local nde_`j'=`e1_`j''-`e2'
			local nie_`j'=`tce_`j''-`nde_`j''
			local cde_`j'=`e3_`j''-`e4'
		}
		if $check_print==0 {
			noi di as text "{hline 10}{c RT}"			
		}
		forvalues j=1/`nexplev' {
			return scalar tce_`j'=`tce_`j''
			return scalar nde_`j'=`nde_`j''
			return scalar nie_`j'=`nie_`j''
			return scalar cde_`j'=`cde_`j''
		}
	}
	if "`msm'"!="" {
		if $check_print==0 {
			noi di
			noi di as text "                                              {c LT}{hline 1}PROGRESS{hline 1}{c RT}"
			noi di as text "   Estimating parameters of MSM:              {c LT}" _cont
		}
		if "`control'"=="" {
			qui capture `msm' if `msm_switch_on'==1
			if _rc>0 {
				tokenize "`msm'", parse(",")
				qui `1' if `msm_switch_on'==1 & `2' `3'
			}
		}
		else {
			qui capture `msm' if `msm_switch_on'==1
			
			if _rc>0 {
				tokenize "`msm'", parse(",")
				qui `1' if `msm_switch_on'==1 & `2' `3'
			}
		}
		tempname msm_params noomit
		mat `msm_params'=e(b)
		_ms_omit_info `msm_params'
		local cols = colsof(`msm_params')
		matrix `noomit' =  J(1,`cols',1) - r(omit)
		mata: msm_params = select(st_matrix(st_local("msm_params")),(st_matrix(st_local("noomit"))))
		mata: st_matrix(st_local("msm_params"),msm_params)
		mat msm_params=`msm_params'
    	local colnames: colfullnames msm_params
    	tokenize "`colnames'", parse(" ")
    	local nparams 0 			
    	while "`1'"!="" {
    		if "`1'"!=" " {
    			local nparams=`nparams'+1
    			local colname`nparams'=substr(substr("`1'",strpos("`1'",":")+1,.), ///
                    strpos(substr("`1'",strpos("`1'",":")+1,.),".")+1,.)
    		}
    		mac shift
    	}
    	forvalues i=1/`nparams' {
    		local p`i'=msm_params[1,`i']
    		return scalar `colname`i''=`p`i''
    	}
    	return scalar N_msm_params=`nparams'
    	if $check_print==0 {
    		noi di as text "{hline 10}{c RT}"
    		if e(cmd)=="cox" {
    			noi di
    			noi di as err "   Note: MSM results will be reported on the log hazard scale, irrespective of whether or not the " as result "nohr" as err " option was" 
    			noi di as err "   specified" 
    		}
    		if e(cmd)=="logit" {
    			noi di
    			noi di as err "   Note: MSM results will be reported on the log odds scale, irrespective of whether or not the " as result "or" as err " option was specified" 
    		}
    	}
    }
}
if "`saving'"!="" {
	if $check_save==2 {
		rename `int_no' _int
		keep _int `varlist'
		foreach var in `varlist' {
			local newname=substr("`var'",1,length("`var'")-1)
			if "`var'"=="`idvar'" {
				rename `idvar' _id
			}
			else {
				rename `var' `newname'
			}
		}
		qui save `saving', `replace'
		global check_save=1
	}
	if $check_save==0 {
		global check_save=2
	}
}
if $check_print==0 {
   	noi di
   	noi di
   	noi di as text "   Bootstrapping:"
   	global check_print=1
}
ereturn clear
end



