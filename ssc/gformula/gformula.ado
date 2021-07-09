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
*! version 1.2 RhMD 11 Apr 2011
*! with r(out) bug fixed
*!
*! version 1.1 RhMD 13 Jan 2011
*! with new mediation option -oce- for a single categorical exposure
*! and bug fixed when -control()- was not specified
/*------------------------------------------------------------*\ 
|  This .ado file fits Robins' G-computation formula (Robins   |
|   1986, Mathematical Modelling) to longitudinal datasets in  |
|   which the relationship between a time-varying exposure and |
|   an outcome of interest is potentially confounded by time-  |
|   varying confounders that are themselves affected by        |
|   previous levels of the exposure.                           |
|                                                              |
|  It can also be used (via the 'mediation' option) to         |
|   estimate controlled direct effects, and natural direct/    |
|   indirect effects, in datasets with an exposure (or         |
|   exposures), mediator(s), an outcome, and confounders of    |
|   the mediator-outcome relationship(s) that are themselves   |
|   affected by the exposure.                                  |
|                                                              |
|  The user specifies hypothetical interventions of interest   |
|   and Monte Carlo simulation is then used to generate how    |
|   the population would have looked under each intervention.  |
|   The parameters needed for the MC simulations are estimated |
|   from user-defined parametric models fitted to the observed |
|   data.                                                      |  
|                                                              |
|  If the outcome is binary or continuous, measured at the     |
|   end-of-follow up, the expected values of the potential     |
|   outcome under each intervention is estimated from the      |
|   simulated data. In addition, the parameters of a marginal  |
|   structural model may be estimated. The user specifies the  |
|   MSM of interest.                                           |
|                                                              |
|  If the outcome is time-to-event, the incidence rate and     |
|   cumulative incidence under each intervention are estimated |
|   from the simulated data. In addition, the parameters of a  |
|   marginal structural Cox model may be estimated. The user   |
|   specifies the MSCM of interest. Kaplan-Meier plots are     |
|   produced.                                                  |
|                                                              |
|  Estimates of precision and subsequent inferences are        |
|   obtained by bootstrapping.                                 |
|                                                              |
|  In the time-varying exposure setting, missing data due to   |
|   MAR (missing at random) dropout are dealt with implicitly. |
|   For intermittent patterns of missingness, a single         |
|   stochastic imputation method can be implemented.           |
|                                                              |
|  In the mediation setting, missing data can also be dealt    |
|   with using the single stochastic imputation method.        |
|                                                              |
|                                                              |
|                                                              |
|  Author: Rhian Daniel                                        |
|  Date: 14th Jan 2013                                         |
|  Version: 1.11 beta                                          |
|                                                              |
|                                                              |
|                                                              | 
|  Acknowledgements: This macro uses the 'detangle' and        |
|   'formatlist' procedures used in ice.ado, by kind           |
|   permission of Patrick Royston. The macro is inspired by    |
|   the GFORMULA macro in SAS written by Sarah Taubman         |
|   (Taubman et al 2009, IJE).                                 |
|   I am very grateful to Bianca De Stavola, Simon Cousens,    |
|   Daniela Zugna, Debbie Ford and Linda Harrison for spotting |
|   bugs, and suggesting improvements and additional features. |
|                                                              | 
|  Disclaimer: This .ado file may contain errors. If you spot  |
|   any, please let me know (Rhian.Daniel@LSHTM.ac.uk) and I   |
|   will endeavour to correct as soon as possible for a future |
|   version. Thank you.                                        |
\*------------------------------------------------------------*/

program define gformula, rclass
version 11
syntax varlist(min=2 numeric) [if] [in] , OUTcome(varname) COMmands(string) EQuations(string) [Idvar(varname) ///
    Tvar(varname) VARyingcovariates(varlist) intvars(varlist) interventions(string) monotreat dynamic eofu pooled death(varname) ///
    derived(varlist) derrules(string) FIXedcovariates(varlist) LAGgedvars(varlist) lagrules(string) msm(string) ///
    mediation EXposure(varlist) mediator(varlist) control(string) baseline(string) base_confs(varlist) /// 
    post_confs(varlist) impute(varlist) imp_eq(string) imp_cmd(string) imp_cycles(int 10) SIMulations(int 99999) ///
	SAMples(int 1000) seed(int 0) obe oce boceam linexp minsim moreMC all graph saving(string) replace]
preserve
keep `varlist'
if "`in'"!="" {
	qui keep if _n `in'
}
if "`if'"!="" {
	qui keep `if'
}
if "`mediation'"=="" {
	noi di
	noi di as text "G-computation procedure using Monte Carlo simulation: time-varying confounding"
}
else {
	noi di
	noi di as text "G-computation procedure using Monte Carlo simulation: mediation"
}
noi di
noi di as err "[Please note that neither the abbreviation of variable names nor the use of" 
noi di as err "variable lists (such as x1-x3 to denote x1 x2 x3) is supported by this command."
noi di as err "If you have used abbreviations or lists, the command may fail to run or the"
noi di as err "results below may not be correct.]"  
noi di
*drop observations that cannot be used because of missing data
tempvar missing
qui gen `missing'=0
if "`mediation'"=="" {
	local varlist_info=" "+"`idvar'"+" "+"`tvar'"+" "
	foreach var in `varlist_info' {
		if strmatch(" "+"`impute'"+" ","* `var' *")==1 {
			noi di as err "Missing values of " as text "`var'" as err " cannot be imputed."
			exit 198
		}
		qui count if `var'==.
		qui replace `missing'=1 if `var'==.
		if r(N)!=0 {
			noi di as err "Warning: " as result r(N) as err " observations dropped due to missing data on " as text "`var'" as err "." 
		}
	}
	qui tab `tvar', matrow(matvis)
	local maxv=rowsof(matvis)
	local maxvlab=matvis[`maxv',1]
	local firstv=matvis[1,1]
	foreach var in `intvars' {
		if strmatch(" "+"`impute'"+" ","* `var' *")==0 {
			if "`death'"=="" {
				qui count if `var'==. & `tvar'!=`maxvlab'
				qui replace `missing'=1 if `var'==. & `tvar'!=`maxvlab'
				if r(N)!=0 {
					noi di as err "Warning: " as result r(N) as err " observations dropped due to missing data on " as text "`var'" as err "." 
				}
			}
			else {
				qui count if `var'==. & `tvar'!=`maxvlab' & `death'!=1
				qui replace `missing'=1 if `var'==. & `tvar'!=`maxvlab' & `death'!=1
				if r(N)!=0 {
					noi di as err "Warning: " as result r(N) as err " observations dropped due to missing data on " as text "`var'" as err "." 
				}
			}
		}
	}
	foreach var in `fixedcovariates' {
		if strmatch(" "+"`impute'"+" ","* `var' *")==0 {
			if "`death'"=="" {
				qui count if `var'==. & `tvar'!=`maxvlab'
				qui replace `missing'=1 if `var'==. & `tvar'!=`maxvlab'
				if r(N)!=0 {
					noi di as err "Warning: " as result r(N) as err " observations dropped due to missing data on " as text "`var'" as err "." 
				}
			}
			else {
				qui count if `var'==. & `tvar'!=`maxvlab' & `death'!=1
				qui replace `missing'=1 if `var'==. & `tvar'!=`maxvlab' & `death'!=1
				if r(N)!=0 {
					noi di as err "Warning: " as result r(N) as err " observations dropped due to missing data on " as text "`var'" as err "." 
				}
			}
		}
	}
	if "`death'"!="" {
		local varlist2="`death'"+" "+"`outcome'"+" "+"`varyingcovariates'"+" "+"`intvars'"
		local nvar: word count `varlist2'
		detangle "`commands'" command "`varlist2'"
		forvalues i=1/`nvar' {
			if "${S_`i'}"!="" {
				local command`i' ${S_`i'}
			}
		}
		if "`command1'"!="logit" {
			noi di as err "Error: death must be simulated from a sequence of logistic regressions." 
			exit 198
		}
		if strmatch(" "+"`impute'"+" ","* `death' *")==1 {
			noi di as err "Missing values of " as text "`death'" as err " cannot be imputed."
			exit 198
		}
		qui count if `death'==. & `tvar'!=`firstv'
		qui replace `missing'=1 if `death'==. & `tvar'!=`firstv'
		if r(N)!=0 {
			noi di as err "Warning: " as result r(N) as err " observations dropped due to missing data on " as text "`death'" as err "." 
		}
	}
	foreach var in `varyingcovariates' {
		if strmatch(" "+"`impute'"+" ","* `var' *")==0 {
			if "`death'"=="" {
				qui count if `var'==. & `tvar'!=`firstv' & `tvar'!=`maxvlab'
				qui replace `missing'=1 if `var'==. & `tvar'!=`firstv' & `tvar'!=`maxvlab'
				if r(N)!=0 {
					noi di as err "Warning: " as result r(N) as err " observations dropped due to missing data on " as text "`var'" as err "." 
				}
			}
			else {
				qui count if `var'==. & `tvar'!=`firstv' & `tvar'!=`maxvlab' & `death'!=1
				qui replace `missing'=1 if `var'==. & `tvar'!=`firstv' & `tvar'!=`maxvlab' & `death'!=1
				if r(N)!=0 {
					noi di as err "Warning: " as result r(N) as err " observations dropped due to missing data on " as text "`var'" as err "." 
				}
			}
		}
	}	
	if "`death'"!="" {
		if strmatch(" "+"`impute'"+" ","* `outcome' *")==1 {
			noi di as err "Missing values of " as text "`outcome'" as err " cannot be imputed."
			exit 198
		}
		qui count if `outcome'==. & `tvar'!=`firstv' & `death'!=1
		qui replace `missing'=1 if `outcome'==. & `tvar'!=`firstv' & `death'!=1
		if r(N)!=0 {
			noi di as err "Warning: " as result r(N) as err " observations dropped due to missing data on " as text "`outcome'" as err "." 
		}
	}
	else {
		if strmatch(" "+"`impute'"+" ","* `outcome' *")==1 {
			noi di as err "Missing values of " as text "`outcome'" as err " cannot be imputed."
			exit 198
		}
		qui count if `outcome'==. & `tvar'!=`firstv'
		qui replace `missing'=1 if `outcome'==. & `tvar'!=`firstv'
		if r(N)!=0 {
			noi di as err "Warning: " as result r(N) as err " observations dropped due to missing data on " as text "`outcome'" as err "." 
		}
	}
	if "`monotreat'"!="" {
		local nint_vars: word count `intvars'
		if `nint_vars'>1 {
			noi di as err "Error: the monotreat option can only be used with one binary intervention variable." 
			exit 198
		}
		local varlist2="`death'"+" "+"`outcome'"+" "+"`varyingcovariates'"+" "+"`intvars'"
		local nvar: word count `varlist2'
		detangle "`commands'" command "`varlist2'"
		forvalues i=1/`nvar' {
			if "${S_`i'}"!="" {
				local command`i' ${S_`i'}
			}
		}
		if "`command`nvar''"!="logit" {
			noi di as err "Error: the monotreat option can only be used with the model for the intervention variable specified as a logistic regression." 
			exit 198
		}
	}
}
else {
	foreach var in `exposure' {
		if strmatch(" "+"`impute'"+" ","* `var' *")==0 {
			qui count if `var'==.
			qui replace `missing'=1 if `var'==.
			if r(N)!=0 {
				noi di as err "Warning: " as result r(N) as err " observations dropped due to missing data on " as text "`var'" as err "." 
			}
		}
	}
	foreach var in `mediator' {
		if strmatch(" "+"`impute'"+" ","* `var' *")==0 {
			qui count if `var'==.
			qui replace `missing'=1 if `var'==.
			if r(N)!=0 {
				noi di as err "Warning: " as result r(N) as err " observations dropped due to missing data on " as text "`var'" as err "." 
			}
		}
	}
	foreach var in `base_confs' {
		if strmatch(" "+"`impute'"+" ","* `var' *")==0 {
			qui count if `var'==.
			qui replace `missing'=1 if `var'==.
			if r(N)!=0 {
				noi di as err "Warning: " as result r(N) as err " observations dropped due to missing data on " as text "`var'" as err "." 
			}
		}
	}
	foreach var in `post_confs' {
		if strmatch(" "+"`impute'"+" ","* `var' *")==0 {
			qui count if `var'==.
			qui replace `missing'=1 if `var'==.
			if r(N)!=0 {
				noi di as err "Warning: " as result r(N) as err " observations dropped due to missing data on " as text "`var'" as err "." 
			}
		}
	}
}
*this next part drops any further observations that need to be dropped because, despite containing observations to be imputed, 
*ALL variables needed for imputation are also missing
if "`impute'"!="" {
	tempvar missing2
	qui gen `missing2'=1
	local imp_nvar: word count `impute'
	detangle "`imp_eq'" imp_eq "`impute'"
	forvalues i=1/`imp_nvar' {
		if "${S_`i'}"!="" {
			local imp_eq`i' ${S_`i'}
		}	
	}
	forvalues i=1/`imp_nvar' {
		qui replace `missing2'=1
		local imp_var`i': word `i' of `impute'
		foreach var in `imp_eq`i'' {
			local var=subinstr("`var'","i.","",1)
			qui replace `missing2'=0 if `var'!=.
		}
		qui count if `missing2'==1
		if r(N)!=0 {
			noi di as err "Warning: " as result r(N) as err " observations dropped due to missing data on all variables needed to impute " as text "`imp_var`i''" as err "." 
		}	
		qui drop if `missing2'==1
	}
}

qui drop if `missing'==1


if "`mediation'"=="" {
	tempvar countid
	qui gen `countid'=1 in 1
	local N=_N
	forvalues i=2(1)`N' {
		local j=`i'-1          
		if `idvar'[`i']==`idvar'[`j'] {
			qui replace `countid'=`countid'[`j'] in `i'
		}
		else {
			qui replace `countid'=`countid'[`j']+1 in `i'
		}
	}
	local maxid=`countid'[`N']
	global maxid=`countid'[`N']
	if `maxid'<`simulations'  {
		if `simulations'!=99999 {
			noi di as err "Warning: the number of MC simulations exceeds the sample size, which is not allowed."
			noi di as err "The number of MC simulations has been set to " as result `maxid' as err "."
		}
		local simulations=`maxid'
	}
	if `simulations'==99999 {
		local simulations=`maxid'
	}
}
else {
	if _N<`simulations' & "`moreMC'"=="" {
		if `simulations'!=99999 {
			noi di as err "Warning: the number of MC simulations exceeds the sample size, which is not allowed since you have not specified the -moreMC- option."
			noi di as err "The number of MC simulations has been set to " as result _N as err "."
		}
		local simulations=_N
	}
	if `simulations'==99999 {
		local simulations=_N
	}
}
if "`mediation'"=="" & "`idvar'"=="" {
	noi di as err "Error: idvar() must be specified for a time-varying confounding analysis."
	exit 198
}
if "`mediation'"=="" & "`tvar'"=="" {
	noi di as err "Error: tvar() must be specified for a time-varying confounding analysis."
	exit 198
}
if "`mediation'"=="" & "`varyingcovariates'"=="" {
	noi di as err "Error: varyingcovariates() must be specified for a time-varying confounding analysis."
	exit 198
}
if "`mediation'"=="" & "`intvars'"=="" {
	noi di as err "Error: intvars() must be specified for a time-varying confounding analysis."
	exit 198
}
if "`mediation'"=="" & "`interventions'"=="" {
	noi di as err "Error: interventions() must be specified for a time-varying confounding analysis."
	exit 198
}
if "`mediation'"!="" & "`exposure'"=="" {
	noi di as err "Error: With the mediation option, exposure() must be specified."
	exit 198
}
if "`mediation'"!="" & "`mediator'"=="" {
	noi di as err "Error: With the mediation option, mediator() must be specified."
	exit 198
}
if "`mediation'"!="" & "`baseline'"=="" & "`obe'"=="" & "`oce'"=="" & "`linexp'"=="" {
	noi di as err "Error: With the mediation option, either baseline(), obe, oce or linexp must be specified."
	exit 198
}
if "`obe'"!="" | "`oce'"!="" | "`linexp'"!=="" {
	local nexp: word count `exposure'
	if `nexp'>1 {
		noi di as err "Error: options obe, oce or linexp cannot be specified when there is more than one exposure."
		exit 198
	}
}
if "`obe'"!="" & "`oce'"!="" {
	cap tab `exposure'
	if _rc==0 & r(r)>=2 {
		if r(r)==2 {
			noi di as err "Warning: You cannot specify both obe and oce. Your exposure variable appears to be binary; try dropping oce."
			exit 198
		}
		else {
			noi di as err "Warning: You cannot specify both obe and oce. Your exposure variable appears to be categorical; try dropping obe."
			exit 198
		}
	}
	else {
		noi di as err "Warning: You cannot specify both obe and oce."
		exit 198
	}
}
if "`obe'"!="" & "`linexp'"!="" {
	cap tab `exposure'
	if _rc==0 & r(r)>=2 {
		if r(r)==2 {
			noi di as err "Warning: You cannot specify both obe and linexp. Your exposure variable appears to be binary; try dropping linexp."
			exit 198
		}
		else {
			noi di as err "Warning: You cannot specify both obe and linexp. Your exposure variable appears to be continuous; try dropping obe."
			exit 198		
		}
	}
	else {
		noi di as err "Warning: You cannot specify both obe and linexp."
		exit 198
	}
}
if "`oce'"!="" & "`linexp'"!="" {
	cap tab `exposure'
	if _rc==0 & r(r)<=50 {
		noi di as err "Warning: You cannot specify both oce and linexp. Your exposure variable appears to be categorical; try dropping linexp."
		exit 198
	}
	else {
		noi di as err "Warning: You cannot specify both oce and linexp."
		exit 198
	}
}
if "`mediation'"!="" & "`dynamic'"!="" {
	noi di as err "Warning: the dynamic option is not allowed with the mediation option. Try dropping it."
	exit 198
}
if "`mediation'"!="" & "`monotreat'"!="" {
	noi di as err "Warning: the monotreat option is not allowed with the mediation option. Try dropping it."
	exit 198
}
if "`msm'"!="" & "`dynamic'"!="" {
	noi di as err "Warning: the msm option is not available when comparing dynamic regimes. Try dropping it."
	exit 198
}
if "`mediation'"=="" & "`exposure'"!="" {
	noi di as err "Warning: exposure() only allowed with the mediation option. Try dropping it."
	exit 198
}
if "`mediation'"=="" & "`mediator'"!="" {
	noi di as err "Warning: mediator() only allowed with the mediation option. Try dropping it."
	exit 198
}
if "`mediation'"=="" & "`control'"!="" {
	noi di as err "Warning: control() only allowed with the mediation option. Try dropping it."
	exit 198
}
if "`mediation'"=="" & "`baseline'"!="" {
	noi di as err "Warning: baseline() only allowed with the mediation option. Try dropping it."
	exit 198
}
if "`mediation'"=="" & "`base_confs'"!="" {
	noi di as err "Warning: base_confs() only allowed with the mediation option. Try dropping it."
	exit 198
}
if "`mediation'"=="" & "`post_confs'"!="" {
	noi di as err "Warning: post_confs() only allowed with the mediation option. Try dropping it."
	exit 198
}
if "`obe'"!="" & "`mediation'"=="" {
	noi di as err "Warning: Option obe not relevant for the time-varying confounding analysis. Try dropping it."
	exit 198
}
if "`oce'"!="" & "`mediation'"=="" {
	noi di as err "Warning: Option oce not relevant for the time-varying confounding analysis. Try dropping it."
	exit 198
}
if "`linexp'"!="" & "`mediation'"=="" {
	noi di as err "Warning: Option linexp not relevant for the time-varying confounding analysis. Try dropping it."
	exit 198
}
if "`obe'"!="" & "`baseline'"!="" {
	noi di as err "Warning: Option baseline() is irrelevant when obe is also specified. Try dropping it."
	exit 198
}
if "`linexp'"!="" & "`baseline'"!="" {
	noi di as err "Warning: Option baseline() is irrelevant when linexp is also specified. Try dropping it."
	exit 198
}
if "`oce'"!="" & "`baseline'"=="" {
	cap tab `exposure', matrow(_matrow)
	if _rc==0 {
		local _ass_bas=_matrow[1,1]
		noi di as err "Warning: Option baseline() has not been specified, and therefore the baseline will be assumed to be " as result `_ass_bas' as err "."
		local `baseline'="`exposure'"+":"+"`_ass_bas'"
	}
	else {
		noi di as err "Error: Option baseline() is required."
		exit 198
	}
}
if "`idvar'"!="" & "`mediation'"!="" {
	noi di as err "Warning: Option idvar() not relevant for the mediation analysis. Try dropping it."
	exit 198
}
if "`tvar'"!="" & "`mediation'"!="" {
	noi di as err "Warning: Option tvar() not relevant for the mediation analysis. Try dropping it."
	exit 198
}
if "`varyingcovariates'"!="" & "`mediation'"!="" {
	noi di as err "Warning: Option varyingcovariates() not relevant for the mediation analysis. Try dropping it."
	exit 198
}
if "`intvars'"!="" & "`mediation'"!="" {
	noi di as err "Warning: Option intvars() not relevant for the mediation analysis. Try dropping it."
	exit 198
}
if "`interventions'"!="" & "`mediation'"!="" {
	noi di as err "Warning: Option interventions() not relevant for the mediation analysis. Try dropping it."
	exit 198
}
if "`pooled'"!="" & "`mediation'"!="" {
	noi di as err "Warning: Option pooled not allowed for the mediation analysis. Try dropping it."
	exit 198
}
if "`death'"!="" & "`mediation'"!="" {
	noi di as err "Warning: Option death() not allowed for the mediation analysis. Try dropping it."
	exit 198
}
if "`fixedcovariates'"!="" & "`mediation'"!="" {
	noi di as err "Warning: Option fixedcovariates() not relevant for the mediation analysis. Try dropping it."
	exit 198
}
if "`laggedvars'"!="" & "`mediation'"!="" {
	noi di as err "Warning: Option laggedvars() not relevant for the mediation analysis. Try dropping it."
	exit 198
}
if "`lagrules'"!="" & "`mediation'"!="" {
	noi di as err "Warning: Option lagrules() not relevant for the mediation analysis. Try dropping it."
	exit 198
}
if "`mediation'"=="" {
	if "`msm'"!="" {
		if word("`msm'",1)!="logit" & word("`msm'",1)!="logi" & word("`msm'",1)!="reg" & word("`msm'",1)!="regr" ///
			& word("`msm'",1)!="regre" & word("`msm'",1)!="regres" & word("`msm'",1)!="regress" ///
			& word("`msm'",1)!="stcox" {
			noi di as err "Warning: The command " _cont
			noi di as result word("`msm'",1) _cont
			noi di as err " is not supported by gformula.ado."
			exit 198
		}
	}
}
else {
	if "`msm'"!="" {
		if word("`msm'",1)!="logit" & word("`msm'",1)!="logi" & word("`msm'",1)!="reg" & word("`msm'",1)!="regr" ///
			& word("`msm'",1)!="regre" & word("`msm'",1)!="regres" & word("`msm'",1)!="regress" {
			noi di as err "Warning: The command " _cont
			noi di as result word("`msm'",1) _cont
			noi di as err " is not supported by gformula.ado with the mediation option."
			exit 198
		}
	}
}
noi di
noi di as text "   Outcome variable: " _cont
noi di as result "`outcome'"
if "`mediation'"=="" {
	noi di as text "   Intervention variable(s): " _cont
	noi di as result "`intvars'"
	noi di as text "   Outcome type: " _cont
	if "`eofu'"=="" {
		noi di as result "survival"
	}
	else {
		tempvar out_check
		qui gen `out_check'=`outcome'*(1-`outcome')
		qui summ `out_check'
		if r(mean)==0 {
			noi di as result "binary, measured at end of follow-up"
		}
		else {
			noi di as result "continuous, measured at end of follow-up"
		}
		drop `out_check'
	}
}
else {
	noi di as text "   Exposure variable(s): " _cont
	noi di as result "`exposure'"
	noi di as text "   Mediator variable(s): " _cont
	noi di as result "`mediator'"
}
noi di as text "   Size of MC sample: " _cont
noi di as result "`simulations'"
noi di as text "   No. of bootstrap samples: " _cont
noi di as result "`samples'"
noi di
* Display in a table the parametric models that have been specified (for simulation under different interventions)
if "`mediation'"=="" {
	local varlist2="`death'"+" "+"`outcome'"+" "+"`varyingcovariates'"+" "+"`intvars'"
}
else {
	local varlist2="`post_confs'"+" "+"`mediator'"+" "+"`outcome'"
}
local nvar: word count `varlist2'
* detangle commands
detangle "`commands'" command "`varlist2'"
forvalues i=1/`nvar' {
	if "${S_`i'}"!="" {
		local command`i' ${S_`i'}
	}
}
* detangle equations
detangle "`equations'" equation "`varlist2'"
forvalues i=1/`nvar' {
	if "${S_`i'}"!="" {
		local equation`i' ${S_`i'}
	}
}
forvalues i=1/`nvar' {
	local simvar`i': word `i' of `varlist2'
}
noi di as text _n "   A summary of the specified parametric models:"
noi di as text _n "   (for simulation under different interventions)"
local longstring 55
local off 16
noi di as text _n "      Variable {c |} Command {c |} Prediction equation" _n ///
	 "   {hline 12}{c +}{hline 9}{c +}{hline `longstring'}"
forvalues i=1/`nvar' {
	local eq `equation`i''
	if "`eq'"=="" {
		local eq "null"
	}
	formatline, n(`eq') maxlen(`longstring')
	local nlines=r(lines)
	forvalues j=1/`nlines' {
		if `j'==1 noi di as text "   " %11s abbrev("`simvar`i''",11) ///
			 " {c |} " %-8s "`command`i''" "{c |} `r(line`j')'"
		else noi di as text _col(`off') ///
			 "{c |}" _col(26) "{c |} `r(line`j')'"
	}
}
noi di as text "   {hline 12}{c BT}{hline 9}{c BT}{hline `longstring'}"
noi di
noi di
if "`impute'"!="" {
	* Display in a table the parametric models that have been specified for imputation
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
	noi di as text _n "   A summary of the specified parametric models:"
	noi di as text _n "   (for imputation of missing values)"
	local longstring 55
	local off 16
	noi di as text _n "      Variable {c |} Command {c |} Prediction equation" _n ///
		 "   {hline 12}{c +}{hline 9}{c +}{hline `longstring'}"
	forvalues i=1/`imp_nvar' {
		local imp_eq_disp `imp_eq`i''
		if "`imp_eq_disp'"=="" {
			local imp_eq_disp "null"
		}
		formatline, n(`imp_eq_disp') maxlen(`longstring')
		local nlines=r(lines)
		forvalues j=1/`nlines' {
			if `j'==1 noi di as text "   " %11s abbrev("`imp_var`i''",11) ///
				 " {c |} " %-8s "`imp_cmd`i''" "{c |} `r(line`j')'"
			else noi di as text _col(`off') ///
				 "{c |}" _col(26) "{c |} `r(line`j')'"
		}
	}
	noi di as text "   {hline 12}{c BT}{hline 9}{c BT}{hline `longstring'}"
	noi di
	noi di
}

*************************************************************************************************************************************************
if "`mediation'"!="" & "`post_confs'"=="" {
	tempvar junk
	gen `junk'=rnormal()
	local post_confs="`"+"junk"+"'"
	local varlist2="`post_confs'"+" "+"`mediator'"+" "+"`outcome'"
	local nvar: word count `varlist2'
	local commands="`junk': regress, "+"`commands'"
	local equations="`junk': , "+"`equations'"
	detangle "`commands'" command "`varlist2'"
	forvalues i=1/`nvar' {
		if "${S_`i'}"!="" {
			local command`i' ${S_`i'}
		}	
	}
	detangle "`equations'" equation "`varlist2'"
	forvalues i=1/`nvar' {
		if "${S_`i'}"!="" {
			local equation`i' ${S_`i'}
		}
	}	
	forvalues i=1/`nvar' {
		local simvar`i': word `i' of `varlist2'
	}
}
*************************************************************************************************************************************************

global check_delete=0
global check_print=0
global check_save=0
local originallist "varlist varlist2 if in outcome commands equations idvar tvar varyingcovariates intvars interventions eofu pooled death derived derrules fixedcovariates laggedvars lagrules msm mediation exposure mediator control baseline base_confs post_confs impute imp_eq imp_cmd imp_cycles simulations samples seed all graph"
foreach member of local originallist {
	local original`member' "``member''"
}
*first, we rename each varname as varname_ so that when we change from long to wide format,
*we don't have any problems 
foreach var in `varlist' {
	local newname="`var'"+"_"
	rename `var' `newname'
}
*we also need to change the names in all the macros listed in the syntax command
local listofstrings "varlist varlist2 if in outcome commands equations idvar tvar varyingcovariates intvars interventions death derived derrules fixedcovariates laggedvars lagrules msm exposure mediator base_confs post_confs impute imp_eq imp_cmd control baseline"
foreach currstring of local listofstrings {
	tokenize "``currstring''"
	local i=1
	while "`1'"!="" {
		local match=0
		foreach var in `originalvarlist' {
			if rtrim(ltrim("`1'"))==rtrim(ltrim("`var'")) {
				local match=1
				local bit1_`i'="`1'"+"_"
			}
			if rtrim(ltrim("`1'"))=="i."+rtrim(ltrim("`var'")) {
				local match=1
				local bit1_`i'="`1'"+"_"
			}
		}
		if `match'==0 {
			local bit1_`i' "`1'"
		}
		local i=`i'+1
		local bit1_`i' " "
		local i=`i'+1
		mac shift
	}
	local k1=`i'-1
	local m=1
	local mp=2
	local listofchars ", \ : = < > & | ! ( ) [ ] * / + - ^"
	foreach parchar of local listofchars {
		local k`mp'=0
		local i=1
		forvalues j=1(1)`k`m'' {
			tokenize "`bit`m'_`j''", parse("`parchar'")
			while "`1'"!="" {
				local match=0
				foreach var in `originalvarlist' {
					if rtrim(ltrim("`1'"))==rtrim(ltrim("`var'")) {
						local match=1
						local bit`mp'_`i'="`1'"+"_"
					}
					if rtrim(ltrim("`1'"))=="i."+rtrim(ltrim("`var'")) {
						local match=1
						local bit`mp'_`i'="`1'"+"_"
					}	
				}
				if `match'==0 {
					local bit`mp'_`i' "`1'"
				}
				local i=`i'+1
				mac shift
			}
			if "`bit`m'_`j''"==" " {
				local bit`mp'_`i' " "
				local i=`i'+1
			}
		}
		local k`mp'=`i'-1
		local m=`m'+1
		local mp=`mp'+1
	}
	local `currstring' ""
	forvalues j=1(1)`k`m'' {
		local `currstring' "``currstring'' `bit`m'_`j''"
	}
}
if `simulations'<1 {
	noi di as err "number of Monte Carlo simulations must be 1 or more"
	exit 198
}
if `samples'<1 {
	noi di as err "number of bootstrap samples must be 1 or more"
	exit 198
}
if `imp_cycles'<1 {
	noi di as err "number of imputation cycles must be 1 or more"
	exit 198
}
if "`all'"!="" {
	local bca="bca"
}
if `seed'>0 set seed `seed'

*now, for the time-varying confounding option, we must reshape the dataset into wide format so that the 
*bootstrapping is done at the subject level, rather than the observation level
if "`mediation'"=="" {
	tokenize "`varlist'"
	local i=1
	while "`1'"!="" {
		if "`1'"!=rtrim(ltrim("`idvar'")) & "`1'"!=rtrim(ltrim("`tvar'")) {
			local bit_`i' "`1'"
			local i=`i'+1
		}
		mac shift
	}
	local i=`i'-1
	global almost_varlist ""
	forvalues j=1(1)`i' {
		global almost_varlist "$almost_varlist `bit_`j''"
	}
	qui reshape wide $almost_varlist, i(`idvar') j(`tvar')
	qui gen `tvar'=.
	foreach pastvar of global almost_varlist {
		qui gen `pastvar'=.
	}
}
gformula_ `varlist' `if' `in', out(`outcome') com(`commands') eq(`equations') i(`idvar') t(`tvar') ///
	var(`varyingcovariates') intvars(`intvars') interventions(`interventions') `monotreat' `eofu' `pooled' death(`death') ///
    derived(`derived') derrules(`derrules') fix(`fixedcovariates') lag(`laggedvars') lagrules(`lagrules') ///
    msm(`msm') `mediation' ex(`exposure') mediator(`mediator') control(`control') baseline(`baseline') ///
    base_confs(`base_confs') post_confs(`post_confs') impute(`impute') imp_eq(`imp_eq') imp_cmd(`imp_cmd') ///
	imp_cycles(`imp_cycles') sim(`simulations') `obe' `oce' `boceam' `linexp' `minsim' `moreMC' `graph' saving(`saving') `replace'

if "`mediation'"=="" {	
	local _b=""
	if "`msm'"!="" {
		local r1=r(N_msm_params)
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
		forvalues i=1/`r1' {
			local _b="`_b'"+" "+"r("+"`colname`i''"+")"
		}
	}
	local _po=""
	local r2=r(N_PO)
	forvalues i=1/`r2' {
		local _po="`_po'"+" "+"r(PO`i')"
	}
	local PO0=r(PO0)
	local _cinc=""
	if "`eofu'"=="" {
		local out0=r(out0)
		local ltfu0=r(ltfu0)
		if "`death'"!="" {
			local death0=r(death0)
		}
		forvalues i=1/`r2' {
			local _cinc="`_cinc'"+" "+"r(out`i')"
			if "`death'"!="" {
				local _cinc="`_cinc'"+" "+"r(death`i')"
			}
		}
	}
}
else {
	local _cinc=""
    local _b=""
	if "`msm'"!="" {
		local r1=r(N_msm_params)
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
		forvalues i=1/`r1' {
			local _b="`_b'"+" "+"r("+"`colname`i''"+")"
		}
	}	
	if "`oce'"=="" {
		local _po="r(tce) r(nde) r(nie) r(cde)"
	}
	else {
		local _po=""
		qui tab `exposure', matrow(_matrow)
		local nexplev=r(r)-1
		forvalues j=1/`nexplev' {
			local _po="`_po'"+"r(tce_`j')"
		}
		forvalues j=1/`nexplev' {
			local _po="`_po'"+"r(nde_`j')"
		}
		forvalues j=1/`nexplev' {
			local _po="`_po'"+"r(nie_`j')"
		}
		forvalues j=1/`nexplev' {
			local _po="`_po'"+"r(cde_`j')"
		}
	}
}
bootstrap `_b' `_po' `_cinc', reps(`samples') `bca' noheader nolegend notable nowarn: gformula_ `varlist' `if' `in', ///
    out(`outcome') com(`commands') eq(`equations') i(`idvar') t(`tvar') var(`varyingcovariates') ///
    intvars(`intvars') interventions(`interventions') `monotreat' `eofu' `pooled' death(`death') derived(`derived') ///
    derrules(`derrules') fix(`fixedcovariates') lag(`laggedvars') lagrules(`lagrules') msm(`msm') `mediation' ///
    ex(`exposure') mediator(`mediator') control(`control') baseline(`baseline') base_confs(`base_confs') ///
    post_confs(`post_confs') impute(`impute') imp_eq(`imp_eq') imp_cmd(`imp_cmd') imp_cycles(`imp_cycles') ///
	sim(`simulations') `obe' `oce' `boceam' `linexp' `minsim' `moreMC' saving(`saving') `replace'
mat b=e(b)
mat se=e(se)
mat ci_normal=e(ci_normal)
mat ci_percentile=e(ci_percentile)
mat ci_bc=e(ci_bc)
mat ci_bca=e(ci_bca)
local originallist "if in outcome commands equations idvar tvar varyingcovariates intvars interventions eofu pooled death derived derrules fixedcovariates laggedvars lagrules msm mediation base_confs post_confs impute imp_eq imp_cmd imp_cycles simulations samples seed all graph"
foreach member of local originallist {
	local `member' "`original`member''"
}
if "`msm'"!="" {
	forvalues i=1/`r1' {
		local colname`i'="`colname`i''"+" "
		local colname`i'=subinstr("`colname`i''","_ ","",.)
	}
	noi di as text " "
	noi di as text "G-computation formula estimates for the parameters of the specified marginal structural model"
	noi di as text " "
	noi di as text _col(10) "Specified MSM: " _cont 
	noi di as result "`msm'"
	noi di as text " "
	if "`all'"=="" {
		noi di as text _col(2)  "{hline 13}{c TT}{hline 68}"
		noi di as text _col(15) "{c |}" _col(18)  "G-computation" 
		noi di as text _col(15) "{c |}" _col(19) "estimate of" _col(34) "Bootstrap" _col(68) "Normal-based"
		local w=14-length(abbrev("`outcome'",12))
		if "`eofu'"!="" {
			noi di as text _col(`w')  abbrev("`outcome'",12) _col(15) "{c |}" _col(22) "Coef." ///
                _col(34) "Std. Err." _col(49) "z" _col(54) "P>|z|" _col(64) "[95% Conf. Interval]"         
		}
		else {
			noi di as text _col(`w')  abbrev("`outcome'",12) _col(15) "{c |}" _col(22) ///
            "Coef." _col(34) "Std. Err." _col(49) "z" _col(54) "P>|z|" _col(64) "[95% Conf. Interval]"         
		}
		noi di as text _col(2)  "{hline 13}{c +}{hline 68}"
		forvalues i=1/`r1' {
			local w=14-length(abbrev("`colname`i''",12))
			noi di as text _col(`w') abbrev("`colname`i''",12) _col(15) "{c |}" _cont
			noi di as result %9.0g _col(19) b[1,`i'] _cont 
			noi di as result _col(33) %9.0g se[1,`i'] _cont
			if b[1,`i']<0 {
				local w=47-max(ceil(log10(abs(round(b[1,`i']/se[1,`i']),0.01))),0)
				noi di as result _col(`w') round(b[1,`i']/se[1,`i'],0.01) _cont
			}		
			else {
				local w=48-max(ceil(log10(abs(round(b[1,`i']/se[1,`i']),0.01))),0)
				noi di as result _col(`w') round(b[1,`i']/se[1,`i'],0.01) _cont
			}
			if round(2*(1-normal(abs(b[1,`i']/se[1,`i']))),0.001)>0 {
				noi di as result _col(54) "0" _col(55) round(2*(1-normal(abs(b[1,`i']/se[1,`i']))),0.001) _cont
				if round(2*(1-normal(abs(b[1,`i']/se[1,`i']))),0.001)== ///
                    round(round(2*(1-normal(abs(b[1,`i']/se[1,`i']))),0.001),0.1) {
					noi di _col(57) "00" _cont
				}
				else {
					if round(2*(1-normal(abs(b[1,`i']/se[1,`i']))),0.001)== ///
                        round(round(2*(1-normal(abs(b[1,`i']/se[1,`i']))),0.001),0.01) {
						noi di _col(58) "0" _cont
					}
				}
			}
			else {
				noi di as result _col(54) "0.000" _cont
			}
			noi di as result _col(63) %9.0g ci_normal[1,`i'] _cont
			noi di as result _col(75) %9.0g ci_normal[2,`i']
		}
		noi di as text _col(2)  "{hline 13}{c BT}{hline 68}"
	}
	else {
		noi di as text _col(2)  "{hline 13}{c TT}{hline 74}"
		noi di as text _col(15) "{c |}" _col(18)  "G-computation" 
		noi di as text _col(15) "{c |}" _col(19) "estimate of" _col(34) "Bootstrap"
		local w=14-length(abbrev("`outcome'",12))
		if "`eofu'"!="" {
			noi di as text _col(`w')  abbrev("`outcome'",12) _col(15) "{c |}" _col(22) ///
            "Coef." _col(34) "Std. Err." _col(49) "z" _col(54) "P>|z|" _col(64) "[95% Conf. Interval]"         
		}
		else {
			noi di as text _col(`w')  abbrev("`outcome'",12) _col(15) "{c |}" _col(22) ///
            "Coef." _col(34) "Std. Err." _col(49) "z" _col(54) "P>|z|" _col(64) "[95% Conf. Interval]"         
		}
		noi di as text _col(2)  "{hline 13}{c +}{hline 74}"
		forvalues i=1/`r1' {
			local w=14-length(abbrev("`colname`i''",12))
			noi di as text _col(`w') abbrev("`colname`i''",12) _col(15) "{c |}" _cont
			noi di as result %9.0g _col(19) b[1,`i'] _cont 
			noi di as result _col(33) %9.0g se[1,`i'] _cont
			if b[1,`i']<0 {
				local w=47-max(ceil(log10(abs(round(b[1,`i']/se[1,`i']),0.01))),0)
				noi di as result _col(`w') round(b[1,`i']/se[1,`i'],0.01) _cont
			}		
			else {
				local w=48-max(ceil(log10(abs(round(b[1,`i']/se[1,`i']),0.01))),0)
				noi di as result _col(`w') round(b[1,`i']/se[1,`i'],0.01) _cont
			}
			if round(2*(1-normal(abs(b[1,`i']/se[1,`i']))),0.001)>0 {
				noi di as result _col(54) "0" _col(55) round(2*(1-normal(abs(b[1,`i']/se[1,`i']))),0.001) _cont
				if round(2*(1-normal(abs(b[1,`i']/se[1,`i']))),0.001)== ///
                    round(round(2*(1-normal(abs(b[1,`i']/se[1,`i']))),0.001),0.1) {
					noi di _col(57) "00" _cont
				}
				else {
					if round(2*(1-normal(abs(b[1,`i']/se[1,`i']))),0.001)== ///
                        round(round(2*(1-normal(abs(b[1,`i']/se[1,`i']))),0.001),0.01) {
						noi di _col(58) "0" _cont
					}
				}
			}
			else {
				noi di as result _col(54) "0.000" _cont
			}
			noi di as result _col(63) %9.0g ci_normal[1,`i'] _cont
			noi di as result _col(75) %9.0g ci_normal[2,`i'] _cont
			noi di as text "   (N)"
			noi di as text _col(15) "{c |}" _cont
			noi di as result _col(63) %9.0g ci_percentile[1,`i'] _cont
			noi di as result _col(75) %9.0g ci_percentile[2,`i'] _cont
			noi di as text "   (P)"
			noi di as text _col(15) "{c |}" _cont
			noi di as result _col(63) %9.0g ci_bc[1,`i'] _cont
			noi di as result _col(75) %9.0g ci_bc[2,`i'] _cont
			noi di as text "  (BC)"
			noi di as text _col(15) "{c |}" _cont
			noi di as result _col(63) %9.0g ci_bca[1,`i'] _cont
			noi di as result _col(75) %9.0g ci_bca[2,`i'] _cont
			noi di as text " (BCa)"
		}
		noi di as text _col(2)  "{hline 13}{c BT}{hline 74}"
		noi di as text " (N)    normal confidence interval"
		noi di as text " (P)    percentile confidence interval"
		noi di as text " (BC)   bias-corrected confidence interval"
		noi di as text " (BCa)  bias-corrected and accelerated confidence interval"
		noi di
		noi di
	}
}
if "`mediation'"=="" {
	noi di as text " "
	if "`eofu'"!="" {
		noi di as text "G-computation formula estimates of the expected values of the potential outcome under each of the specified interventions"
		noi di as text "   and under no intervention (i.e. as simulated under the observational regime). For comparison, the mean outcome in the"
		noi di as text "   observed data is also shown."
	}
	else {
		noi di as text "G-computation formula estimates of the average log incidence rates under each of the specified interventions and under no"
		noi di as text "   intervention (i.e. as simulated under the observational regime). For comparison, the average log incidence rate in the"
		noi di as text "   observed data is also shown."
	}
	noi di as text " "
	noi di as text _col(10) "Specified interventions: "
	* tokenize interventions
	tokenize "`interventions'", parse(",")
	local nint 0 			
	while "`1'"!="" {
		if "`1'"!="," {
			local nint=`nint'+1
			local int`nint' "`1'"
		}
		mac shift
	}
	forvalues i=1/`nint' { 	
		noi di as text _col(15) "Intervention " `i' ": " _cont
		noi di as result "`int`i''"
	}
	noi di as text " "
	if "`all'"=="" {
		noi di as text _col(2)  "{hline 13}{c TT}{hline 68}"
		noi di as text _col(15) "{c |}" _col(18)  "G-computation" 
		noi di as text _col(15) "{c |}" _col(19) "estimate of" _col(34) "Bootstrap" _col(68) "Normal-based"
		local w=14-length(abbrev("`outcome'",12))
		if "`eofu'"!="" {
			noi di as text _col(`w')  abbrev("`outcome'",12) _col(15) "{c |}" _col(21) "mean PO" _col(34) ///
                "Std. Err." _col(49) "z" _col(54) "P>|z|" _col(64) "[95% Conf. Interval]"         
		}
		else {
			noi di as text _col(`w')  abbrev("`outcome'",12) _col(15) "{c |}" _col(19) "av. log IR" _col(34) ///
                "Std. Err." _col(49) "z" _col(54) "P>|z|" _col(64) "[95% Conf. Interval]"         
		}
		noi di as text _col(2)  "{hline 13}{c +}{hline 68}"
		if "`msm'"!="" {
			local r3=`r1'+1
			local r4=`r1'+`r2'
			local subtract=`r1'
		}
		else {
			local r3=1
			local r4=`r2'
			local subtract=0
		}
		forvalues i=`r3'/`r4' {
			local j=`i'-`subtract'
			if `j'<=`nint' {
				noi di as text _col(7) "Int. " `j' _col(15) "{c |}" _cont
			}
			else {
				noi di as result _col(2) "Obs. regime" _col(15) "{c |}"
				noi di as text _col(4)   "simulated" _col(15) "{c |}" _cont
			}
			noi di as result %9.0g _col(19) b[1,`i'] _cont 
			noi di as result _col(33) %9.0g se[1,`i'] _cont
			if b[1,`i']<0 {
				local w=47-max(ceil(log10(abs(round(b[1,`i']/se[1,`i']),0.01))),0)
				noi di as result _col(`w') round(b[1,`i']/se[1,`i'],0.01) _cont
			}		
			else {
				local w=48-max(ceil(log10(abs(round(b[1,`i']/se[1,`i']),0.01))),0)
				noi di as result _col(`w') round(b[1,`i']/se[1,`i'],0.01) _cont
			}
			if round(2*(1-normal(abs(b[1,`i']/se[1,`i']))),0.001)>0 {
				noi di as result _col(54) "0" _col(55) round(2*(1-normal(abs(b[1,`i']/se[1,`i']))),0.001) _cont
				if round(2*(1-normal(abs(b[1,`i']/se[1,`i']))),0.001)== ///
                    round(round(2*(1-normal(abs(b[1,`i']/se[1,`i']))),0.001),0.1) {
					noi di _col(57) "00" _cont
				}
				else {
					if round(2*(1-normal(abs(b[1,`i']/se[1,`i']))),0.001)== ///
                        round(round(2*(1-normal(abs(b[1,`i']/se[1,`i']))),0.001),0.01) {
						noi di _col(58) "0" _cont
					}
				}
			}
			else {
				noi di as result _col(54) "0.000" _cont
			}
			noi di as result _col(63) %9.0g ci_normal[1,`i'] _cont
			noi di as result _col(75) %9.0g ci_normal[2,`i']
			if `j'==`nint' {
				noi di as text _col(2)  "{hline 13}{c +}{hline 68}"
			}
		}
		noi di as text _col(5) "observed" _col(15) "{c |}" _cont
		noi di as result %9.0g _col(19) `PO0'
		noi di as text _col(2)  "{hline 13}{c BT}{hline 68}"
	}
	else {
		noi di as text _col(2)  "{hline 13}{c TT}{hline 74}"
		noi di as text _col(15) "{c |}" _col(18)  "G-computation" 
		noi di as text _col(15) "{c |}" _col(19) "estimate of" _col(34) "Bootstrap"
		local w=14-length(abbrev("`outcome'",12))
		if "`eofu'"!="" {
			noi di as text _col(`w')  abbrev("`outcome'",12) _col(15) "{c |}" _col(21) "mean PO" _col(34) ///
                "Std. Err." _col(49) "z" _col(54) "P>|z|" _col(64) "[95% Conf. Interval]"         
		}
		else {
			noi di as text _col(`w')  abbrev("`outcome'",12) _col(15) "{c |}" _col(19) "av. log IR" _col(34) ///
                "Std. Err." _col(49) "z" _col(54) "P>|z|" _col(64) "[95% Conf. Interval]"         
		}
		noi di as text _col(2)  "{hline 13}{c +}{hline 74}"
		if "`msm'"!="" {
			local r3=`r1'+1
			local r4=`r1'+`r2'
			local subtract=`r1'
		}
		else {
			local r3=1
			local r4=`r2'
			local subtract=0
		}
		forvalues i=`r3'/`r4' {
			local j=`i'-`subtract'
			if `j'<=`nint' {
				noi di as text _col(7) "Int. " `j' _col(15) "{c |}" _cont
			}
			else {
				noi di as result _col(2) "Obs. regime" _col(15) "{c |}"
				noi di as text _col(4)   "simulated" _col(15) "{c |}" _cont
			}
			noi di as result %9.0g _col(19) b[1,`i'] _cont 
			noi di as result _col(33) %9.0g se[1,`i'] _cont
			if b[1,`i']<0 {
				local w=47-max(ceil(log10(abs(round(b[1,`i']/se[1,`i']),0.01))),0)
				noi di as result _col(`w') round(b[1,`i']/se[1,`i'],0.01) _cont
			}		
			else {
				local w=48-max(ceil(log10(abs(round(b[1,`i']/se[1,`i']),0.01))),0)
				noi di as result _col(`w') round(b[1,`i']/se[1,`i'],0.01) _cont
			}
			if round(2*(1-normal(abs(b[1,`i']/se[1,`i']))),0.001)>0 {
				noi di as result _col(54) "0" _col(55) round(2*(1-normal(abs(b[1,`i']/se[1,`i']))),0.001) _cont
				if round(2*(1-normal(abs(b[1,`i']/se[1,`i']))),0.001)== ///
                    round(round(2*(1-normal(abs(b[1,`i']/se[1,`i']))),0.001),0.1) {
					noi di _col(57) "00" _cont
				}
				else {
					if round(2*(1-normal(abs(b[1,`i']/se[1,`i']))),0.001)== ///
                        round(round(2*(1-normal(abs(b[1,`i']/se[1,`i']))),0.001),0.01) {
						noi di _col(58) "0" _cont
					}
				}
			}
			else {
				noi di as result _col(54) "0.000" _cont
			}
			noi di as result _col(63) %9.0g ci_normal[1,`i'] _cont
			noi di as result _col(75) %9.0g ci_normal[2,`i'] _cont
			noi di as text "   (N)"
			noi di as text _col(15) "{c |}" _cont
			noi di as result _col(63) %9.0g ci_percentile[1,`i'] _cont
			noi di as result _col(75) %9.0g ci_percentile[2,`i'] _cont
			noi di as text "   (P)"
			noi di as text _col(15) "{c |}" _cont
			noi di as result _col(63) %9.0g ci_bc[1,`i'] _cont
			noi di as result _col(75) %9.0g ci_bc[2,`i'] _cont
			noi di as text "  (BC)"
			noi di as text _col(15) "{c |}" _cont
			noi di as result _col(63) %9.0g ci_bca[1,`i'] _cont
			noi di as result _col(75) %9.0g ci_bca[2,`i'] _cont
			noi di as text " (BCa)"
			if `j'==`nint' {
				noi di as text _col(2)  "{hline 13}{c +}{hline 74}"
			}
		}
		noi di as text _col(5) "observed" _col(15) "{c |}" _cont
		noi di as result %9.0g _col(19) `PO0'
		noi di as text _col(2)  "{hline 13}{c BT}{hline 74}"
		noi di as text " (N)    normal confidence interval"
		noi di as text " (P)    percentile confidence interval"
		noi di as text " (BC)   bias-corrected confidence interval"
		noi di as text " (BCa)  bias-corrected and accelerated confidence interval"
	}
	if "`eofu'"=="" {
		noi di as text " "
		noi di as text "G-computation formula estimates of the cumulative incidence under each of the specified interventions and under no"
		noi di as text "   intervention (i.e. as simulated under the observational regime). For comparison, the cumulative incidence in the"
		noi di as text "   observed data is also shown."
		noi di as text " "
		noi di as text _col(10) "Specified interventions: "
		* tokenize interventions
		tokenize "`interventions'", parse(",")
		local nint 0 			
		while "`1'"!="" {
			if "`1'"!="," {
				local nint=`nint'+1
				local int`nint' "`1'"
			}
			mac shift
		}
		forvalues i=1/`nint' { 	
			noi di as text _col(15) "Intervention " `i' ": " _cont
			noi di as result "`int`i''"
		}
		noi di as text " "
		if "`all'"=="" {
			noi di as text _col(2)  "{hline 13}{c TT}{hline 68}"
			noi di as text _col(15) "{c |}" _col(18)  "G-computation" 
			noi di as text _col(15) "{c |}" _col(19) "estimate of" _col(34) "Bootstrap" _col(68) "Normal-based"
			local w=14-length(abbrev("`outcome'",12))
			noi di as text _col(`w')  abbrev("`outcome'",12) _col(15) "{c |}" _col(18) "cum. incidence" _col(34) ///
				"Std. Err." _col(49) "z" _col(54) "P>|z|" _col(64) "[95% Conf. Interval]" 			
			noi di as text _col(2)  "{hline 13}{c +}{hline 68}"
			if "`msm'"!="" {
				local r3=`r1'+`r2'+1
				if "`death'"=="" {
					local r4=`r1'+2*`r2'
				}
				else {
					local r4=`r1'+3*`r2'
				}
				local subtract=`r1'+`r2'
			}
			else {
				local r3=1+`r2'
				if "`death'"=="" {
					local r4=2*`r2'
				}
				else {
					local r4=3*`r2'
				}
				local subtract=`r2'
			}
			local od=0
			forvalues i=`r3'/`r4' {
				local j=`i'-`subtract'
				if "`death'"=="" {
					if `j'<=`nint' {
						noi di as text _col(7) "Int. " `j'  _col(15) "{c |}" _cont
					}
					else {
						noi di as result _col(2) "Obs. regime" _col(15) "{c |}"
						noi di as text _col(4) "simulated" _col(15) "{c |}" _cont
					}
				}
				else {
					local k=ceil(`j'/2)
					if `k'<=`nint' {
						if `od'==0 {
							noi di as text _col(3) "Int. " `k' " (o)" _col(15) "{c |}" _cont
						}
						else {
							local indent=9+ceil(log10(`k'+1))
							noi di as text _col(`indent') "(d)" _col(15) "{c |}" _cont
						}
						local od=1-`od'
					}
					else {
						if `od'==0 {
							noi di as result _col(2) "Obs. regime" _col(15) "{c |}"
							noi di as text _col(2) "simulated (o)" _col(15) "{c |}" _cont
						}
						else {
							noi di as text _col(2) "          (d)" _col(15) "{c |}" _cont
						}
						local od=1-`od'
					}
				}
				noi di as result %9.0g _col(19) b[1,`i'] _cont 
				noi di as result _col(33) %9.0g se[1,`i'] _cont
				if b[1,`i']<0 {
					local w=47-max(ceil(log10(abs(round(b[1,`i']/se[1,`i']),0.01))),0)
					noi di as result _col(`w') round(b[1,`i']/se[1,`i'],0.01) _cont
				}		
				else {
					local w=48-max(ceil(log10(abs(round(b[1,`i']/se[1,`i']),0.01))),0)
					noi di as result _col(`w') round(b[1,`i']/se[1,`i'],0.01) _cont
				}
				if round(2*(1-normal(abs(b[1,`i']/se[1,`i']))),0.001)>0 {
					noi di as result _col(54) "0" _col(55) round(2*(1-normal(abs(b[1,`i']/se[1,`i']))),0.001) _cont
					if round(2*(1-normal(abs(b[1,`i']/se[1,`i']))),0.001)== ///
						round(round(2*(1-normal(abs(b[1,`i']/se[1,`i']))),0.001),0.1) {
						noi di _col(57) "00" _cont
					}
					else {
						if round(2*(1-normal(abs(b[1,`i']/se[1,`i']))),0.001)== ///
							round(round(2*(1-normal(abs(b[1,`i']/se[1,`i']))),0.001),0.01) {
							noi di _col(58) "0" _cont
						}
					}
				}
				else {
					noi di as result _col(54) "0.000" _cont
				}
				noi di as result _col(63) %9.0g ci_normal[1,`i'] _cont
				noi di as result _col(75) %9.0g ci_normal[2,`i']
				if "`death'"=="" {
					if `j'==`nint' {
						noi di as text _col(2)  "{hline 13}{c +}{hline 68}"
					}
				}
				else {
					if `k'==`nint' & `od'==0 {
						noi di as text _col(2)  "{hline 13}{c +}{hline 68}"
					}
				}
			}
			if "`death'"=="" {
				if `ltfu0'==0 {
					noi di as text _col(5) "observed" _col(15) "{c |}" _cont
					noi di as result %9.0g _col(19) `out0'
				}
				else {
					noi di as text _col(2) "observed (o)" _col(15) "{c |}" _cont
					noi di as result %9.0g _col(19) `out0'
					noi di as text _col(2) "observed (l)" _col(15) "{c |}" _cont
					noi di as result %9.0g _col(19) `ltfu0'
				}
			}
			else {
				if `ltfu0'==0 {
					noi di as text _col(2) "observed (o)" _col(15) "{c |}" _cont
					noi di as result %9.0g _col(19) `out0'
					noi di as text _col(2) "         (d)" _col(15) "{c |}" _cont
					noi di as result %9.0g _col(19) `death0'
				}
				else {
					noi di as text _col(2) "observed (o)" _col(15) "{c |}" _cont
					noi di as result %9.0g _col(19) `out0'
					noi di as text _col(2) "         (d)" _col(15) "{c |}" _cont
					noi di as result %9.0g _col(19) `death0'
					noi di as text _col(2) "         (l)" _col(15) "{c |}" _cont
					noi di as result %9.0g _col(19) `ltfu0'
				}
			}
			noi di as text _col(2)  "{hline 13}{c BT}{hline 68}"
			if "`death'"!="" & `ltfu0'==0 {
				noi di as text _col(2)  "Key: " _cont
				noi di as text _col(2)  as result "(o) " as text "= outcome, " as result "(d) " as text "= death"
			}
			if "`death'"!="" & `ltfu0'!=0 {
				noi di as text _col(2)  "Key: " _cont
				noi di as text _col(2)  as result "(o) " as text "= outcome, " as result "(d) " as text "= death, " ///
					as result "(l) " as text "= lost to follow-up"
			}
		}
		else {
			noi di as text _col(2)  "{hline 13}{c TT}{hline 74}"
			noi di as text _col(15) "{c |}" _col(18)  "G-computation" 
			noi di as text _col(15) "{c |}" _col(19) "estimate of" _col(34) "Bootstrap"
			local w=14-length(abbrev("`outcome'",12))
			noi di as text _col(`w')  abbrev("`outcome'",12) _col(15) "{c |}" _col(18) "cum. incidence" _col(34) ///
				"Std. Err." _col(49) "z" _col(54) "P>|z|" _col(64) "[95% Conf. Interval]" 			
			noi di as text _col(2)  "{hline 13}{c +}{hline 74}"
			if "`msm'"!="" {
				local r3=`r1'+`r2'+1
				if "`death'"=="" {
					local r4=`r1'+2*`r2'
				}
				else {
					local r4=`r1'+3*`r2'
				}
				local subtract=`r1'+`r2'
			}
			else {
				local r3=1+`r2'
				if "`death'"=="" {
					local r4=2*`r2'
				}
				else {
					local r4=3*`r2'
				}
				local subtract=`r2'
			}
			local od=0
			forvalues i=`r3'/`r4' {
				local j=`i'-`subtract'
				if `j'<=`nint' {
					if "`death'"=="" {
						noi di as text _col(7) "Int. " `j'  _col(15) "{c |}" _cont
					}
					else {
						if `od'==0 {
							noi di as text _col(3) "Int. " `j' " (o)" _col(15) "{c |}" _cont
						}
						else {
							local indent=9+ceil(log10(`j'+1))
							noi di as text _col(`indent') "(d)" _col(15) "{c |}" _cont
						}
						local od=1-`od'
					}
				}
				else {
					if "`death'"=="" {
						noi di as result _col(2) "Obs. regime" _col(15) "{c |}"
						noi di as text _col(4) "simulated" _col(15) "{c |}" _cont
					}
					else {
						if `od'==0 {
							noi di as result _col(2) "Obs. regime" _col(15) "{c |}"
							noi di as text _col(2) "simulated (o)" _col(15) "{c |}" _cont
						}
						else {
							noi di as text _col(2) "          (d)" _col(15) "{c |}" _cont						
						}
						local od=1-`od'
					}
				}
				noi di as result %9.0g _col(19) b[1,`i'] _cont 
				noi di as result _col(33) %9.0g se[1,`i'] _cont
				if b[1,`i']<0 {
					local w=47-max(ceil(log10(abs(round(b[1,`i']/se[1,`i']),0.01))),0)
					noi di as result _col(`w') round(b[1,`i']/se[1,`i'],0.01) _cont
				}		
				else {
					local w=48-max(ceil(log10(abs(round(b[1,`i']/se[1,`i']),0.01))),0)
					noi di as result _col(`w') round(b[1,`i']/se[1,`i'],0.01) _cont
				}
				if round(2*(1-normal(abs(b[1,`i']/se[1,`i']))),0.001)>0 {
					noi di as result _col(54) "0" _col(55) round(2*(1-normal(abs(b[1,`i']/se[1,`i']))),0.001) _cont
					if round(2*(1-normal(abs(b[1,`i']/se[1,`i']))),0.001)== ///
						round(round(2*(1-normal(abs(b[1,`i']/se[1,`i']))),0.001),0.1) {
						noi di _col(57) "00" _cont
					}
					else {
						if round(2*(1-normal(abs(b[1,`i']/se[1,`i']))),0.001)== ///
							round(round(2*(1-normal(abs(b[1,`i']/se[1,`i']))),0.001),0.01) {
							noi di _col(58) "0" _cont
						}
					}
				}
				else {
					noi di as result _col(54) "0.000" _cont
				}
				noi di as result _col(63) %9.0g ci_normal[1,`i'] _cont
				noi di as result _col(75) %9.0g ci_normal[2,`i'] _cont
				noi di as text "   (N)"
				noi di as text _col(15) "{c |}" _cont
				noi di as result _col(63) %9.0g ci_percentile[1,`i'] _cont
				noi di as result _col(75) %9.0g ci_percentile[2,`i'] _cont
				noi di as text "   (P)"
				noi di as text _col(15) "{c |}" _cont
				noi di as result _col(63) %9.0g ci_bc[1,`i'] _cont
				noi di as result _col(75) %9.0g ci_bc[2,`i'] _cont
				noi di as text "  (BC)"
				noi di as text _col(15) "{c |}" _cont
				noi di as result _col(63) %9.0g ci_bca[1,`i'] _cont
				noi di as result _col(75) %9.0g ci_bca[2,`i'] _cont
				noi di as text " (BCa)"
				if "`death'"=="" {
					if `j'==`nint' {
						noi di as text _col(2)  "{hline 13}{c +}{hline 74}"
					}
				}
				else {
					if `k'==`nint' & `od'==0 {
						noi di as text _col(2)  "{hline 13}{c +}{hline 74}"
					}
				}
			}
			if "`death'"=="" {
				if `ltfu0'==0 {
					noi di as text _col(5) "observed" _col(15) "{c |}" _cont
					noi di as result %9.0g _col(19) `out0'
				}
				else {
					noi di as text _col(2) "observed (o)" _col(15) "{c |}" _cont
					noi di as result %9.0g _col(19) `out0'
					noi di as text _col(2) "observed (l)" _col(15) "{c |}" _cont
					noi di as result %9.0g _col(19) `ltfu0'
				}
			}
			else {
				if `ltfu0'==0 {
					noi di as text _col(2) "observed (o)" _col(15) "{c |}" _cont
					noi di as result %9.0g _col(19) `out0'
					noi di as text _col(2) "         (d)" _col(15) "{c |}" _cont
					noi di as result %9.0g _col(19) `death0'
				}
				else {
					noi di as text _col(2) "observed (o)" _col(15) "{c |}" _cont
					noi di as result %9.0g _col(19) `out0'
					noi di as text _col(2) "         (d)" _col(15) "{c |}" _cont
					noi di as result %9.0g _col(19) `death0'
					noi di as text _col(2) "         (l)" _col(15) "{c |}" _cont
					noi di as result %9.0g _col(19) `ltfu0'
				}
			}
			noi di as text _col(2)  "{hline 13}{c BT}{hline 74}"
			if "`death'"!="" & `ltfu0'==0 {
				noi di as text _col(2)  "Key: " _cont
				noi di as text _col(2)  as result "(o) " as text "= outcome, " as result "(d) " as text "= death"
			}
			if "`death'"!="" & `ltfu0'!=0 {
				noi di as text _col(2)  "Key: " _cont
				noi di as text _col(2)  as result "(o) " as text "= outcome, " as result "(d) " as text "= death, " ///
					as result "(l) " as text "= lost to follow-up"
			}
			noi di
			noi di as text " (N)    normal confidence interval"
			noi di as text " (P)    percentile confidence interval"
			noi di as text " (BC)   bias-corrected confidence interval"
			noi di as text " (BCa)  bias-corrected and accelerated confidence interval"
		}
	}
	if "`graph'"!="" {
		graph display Graph
	}
}
else {
	if "`msm'"!="" {
		mat _b_msm=b[1,1..`r1']
		mat _se_msm=se[1,1..`r1']
		local r1plus1=`r1'+1
		local r1end=colsof(b)
		matrix b=b[1,`r1plus1'..`r1end']
		matrix se=se[1,`r1plus1'..`r1end']
		matrix ci_normal=ci_normal[1..2,`r1plus1'..`r1end']
		cap matrix ci_percentile=ci_percentile[1..2,`r1plus1'..`r1end']
		cap matrix ci_bc=ci_bc[1..2,`r1plus1'..`r1end']
		cap matrix ci_bca=ci_bca[1..2,`r1plus1'..`r1end']
	}
	noi di as text " "
    if "`control'"=="" {
    	noi di as text "G-computation formula estimates of the total causal effect and the natural direct/indirect effects"
    }
    else {
    	noi di as text "G-computation formula estimates of the total causal effect, the natural direct/indirect effects,"
        noi di as text "and the controlled direct effect"
    }
    noi di
	if "`obe'"=="" & "`oce'"=="" & "`linexp'"=="" {
		noi di as text _col(5) "Note: The total causal effect (" as result "TCE" as text ") is the difference between the"
		noi di as text _col(11) "mean outcome under the observational regime and the mean potential"
		noi di as text _col(11) "outcome if, contrary to fact, all subjects' exposure(s) were"
		noi di as text _col(11) "set at the baseline values. Writing X for the exposure(s), M"
		noi di as text _col(11) "for the mediator(s), Y for the outcome and 0 for the baseline"
		noi di as text _col(11) "value(s) of the exosure(s), then:"
		noi di
		noi di as result _col(23) "TCE" as text "=E[Y{X,M(X)}]-E[Y{0,M(0)}]"
		noi di
		noi di as text _col(11) "The natural direct effect (" as result "NDE" as text ") is the difference between the"
		noi di as text _col(11) "mean of two potential outcomes. The first is the potential"
		noi di as text _col(11) "outcome if, contrary to fact, all subjects' mediator(s) were" 
		noi di as text _col(11) "set to their potential value(s) under the baseline value(s)" 
		noi di as text _col(11) "of the exposure, but the exposure value(s) are those actually" 
		noi di as text _col(11) "observed in the observational data. The second is the" 
		noi di as text _col(11) "potential outcome if, contrary to fact, all subjects'" 
		noi di as text _col(11) "exposure(s) were set at the baseline value(s). That is:"
		noi di
		noi di as result _col(23) "NDE" as text "=E[Y{X,M(0)}]-E[Y{0,M(0)}]"
		noi di
		noi di as text _col(11) "The natural indirect effect (" as result "NIE" as text ") is the difference between"
		noi di as text _col(11) "the " as result "TCE" as text " and the " as result "NDE" as text ". That is:"
		noi di
		noi di as result _col(19) "NIE" as text "=" as result "TCE" as text "-" as result "NDE" as text "=E[Y{X,M(X)}]-E[Y{X,M(0)}]"
		noi di
		if "`control'"!="" {
			noi di as text _col(11) "The controlled direct effect (" as result "CDE" as text ") is the difference between"
			noi di as text _col(11) "the mean potential outcome when subjects' exposure value(s)"
			noi di as text _col(11) "were those actually observed under the observational regime and" 
			noi di as text _col(11) "the mean potential outcome when, contrary to fact, all" 
			noi di as text _col(11) "subjects' exposure(s) were set at the baseline value(s); and,"
			noi di as text _col(11) "in addition, in both cases, the mediator(s) were set to their" 
			noi di as text _col(11) "control value(s). Write m for the control value(s) of the" 
			noi di as text _col(11) "mediator(s), then:"
			noi di
			noi di as result _col(23) "CDE" as text "=E{Y(X,m)}-E{Y(0,m)}"
			noi di
		}
	}
	else {
		if "`obe'"!="" {
			noi di as text _col(5) "Note: The total causal effect (" as result "TCE" as text ") is the difference between the"
			noi di as text _col(11) "mean potential outcome if, contrary to fact, all subjects were"
			noi di as text _col(11) "exposed, and the mean potential outcome if all subjects were"
			noi di as text _col(11) "unexposed. Writing X for the exposure, M for the mediator(s),"
			noi di as text _col(11) "and Y for the outcome and 0 for the baseline, then:"
			noi di
			noi di as result _col(19) "TCE" as text "=E[Y{X=1,M(X=1)}]-E[Y{X=0,M(X=0)}]"
			noi di
			noi di as text _col(11) "The natural direct effect (" as result "NDE" as text ") is the difference between the"
			noi di as text _col(11) "mean of two potential outcomes. The first is the potential"
			noi di as text _col(11) "outcome if, contrary to fact, all subjects were exposed, and"
			noi di as text _col(11) "subjects' mediator(s) were set to their potential value(s)"
			noi di as text _col(11) "under no exposure. The second is the potential outcome if,"
			noi di as text _col(11) "contrary to fact, all subjects were unexposed. That is:"
			noi di
			noi di as result _col(19) "NDE" as text "=E[Y{X=1,M(X=0)}]-E[Y{X=0,M(X=0)}]"
			noi di
			noi di as text _col(11) "The natural indirect effect (" as result "NIE" as text ") is the difference between"
			noi di as text _col(11) "the " as result "TCE" as text " and the " as result "NDE" as text ". That is:"
			noi di
			noi di as result _col(15) "NIE" as text "=" as result "TCE" as text "-" as result "NDE" as text "=E[Y{X=1,M(X=1)}]-E[Y{X=1,M(X=0)}]"
			noi di
			if "`control'"!="" {
				noi di as text _col(11) "The controlled direct effect (" as result "CDE" as text ") is the difference between"
				noi di as text _col(11) "the mean potential outcome when all subjects were exposed"
				noi di as text _col(11) "and the mean potential outcome when all subjects were"
				noi di as text _col(11) "unexposed; and, in addition, in both cases, the mediator(s)"
				noi di as text _col(11) "were set to their control value(s). Write m for the control"
				noi di as text _col(11) "value(s) of the mediator(s), then:"
				noi di
				noi di as result _col(19) "CDE" as text "=E{Y(X=1,M=m)}-E{Y(X=0,M=m)}"
				noi di
			}
		}
		else {
			if "`oce'"=="" {
				noi di as text _col(5) "Note: The total causal effect (" as result "TCE" as text ") is the difference between the"
				noi di as text _col(11) "mean potential outcome if, contrary to fact, all subjects'" 
				noi di as text _col(11) "exposure were set to one value higher than they were in the"
				noi di as text _col(11) "observed data, and the mean outcome when the exposures are left"
				noi di as text _col(11) "unchanged. Writing X for the exposure, M for the mediator(s)" 
				noi di as text _col(11) "and Y for the outcome, then:"
				noi di
				noi di as result _col(23) "TCE" as text "=E[Y{X+1,M(X+1)}]-E[Y{X,M(X)}]"
				noi di
				noi di as text _col(11) "The natural direct effect (" as result "NDE" as text ") is also the difference between"
				noi di as text _col(11) "the mean of a potential outcome and the mean of the actual" 
				noi di as text _col(11) "outcome. The potential outcome in question here is the one we"
				noi di as text _col(11) "would observe if, contrary to fact, all subjects' exposure" 
				noi di as text _col(11) "value were increased by 1, but their mediator value(s) are" 
				noi di as text _col(11) "those actually observed in the observational data. That is:"
				noi di
				noi di as result _col(23) "NDE" as text "=E[Y{X+1,M(X)}]-E[Y{X,M(X)}]"
				noi di
				noi di as text _col(11) "The natural indirect effect (" as result "NIE" as text ") is the difference between"
				noi di as text _col(11) "the " as result "TCE" as text " and the " as result "NDE" as text ". That is:"
				noi di
				noi di as result _col(19) "NIE" as text "=" as result "TCE" as text "-" as result "NDE" as text "=E[Y{X+1,M(X+1)}]-E[Y{X+1,M(X)}]"
				noi di
				if "`control'"!="" {
					noi di as text _col(11) "The controlled direct effect (" as result "CDE" as text ") is the difference between"
					noi di as text _col(11) "the mean potential outcome when subjects' exposure values"
					noi di as text _col(11) "were increased by 1 and the mean potential outcome when, the" 
					noi di as text _col(11) "subjects' exposures were left unchaged; and, in addition, in"
					noi di as text _col(11) "both cases, the mediator(s) were set to their control"
					noi di as text _col(11) "value(s). Write m for the control value(s) of the" 
					noi di as text _col(11) "mediator(s), then:"
					noi di
					noi di as result _col(23) "CDE" as text "=E{Y(X+1,m)}-E{Y(X,m)}"
					noi di
				}
			}
			else {
				noi di as text _col(5) "Note: The total causal effect (" as result "TCE(k)" as text "), comparing level k"
				noi di as text _col(11) "of the exposure against the baseline, is the difference" 
				noi di as text _col(11) "between the mean potential outcome if, contrary to fact," 
				noi di as text _col(11) "all subjects were exposed at level k, and the mean"
				noi di as text _col(11) "potential outcome if all subjects received the baseline" 
				noi di as text _col(11) "level of exposure. Writing X for the exposure, M for the" 
				noi di as text _col(11) "mediator(s), Y for the outcome, and 0 for the baseline:"
				noi di
				noi di as result _col(19) "TCE(k)" as text "=E[Y{X=k,M(X=k)}]-E[Y{X=0,M(X=0)}]"
				noi di
				noi di as text _col(11) "The natural direct effect (" as result "NDE(k)" as text ") is the difference between the"
				noi di as text _col(11) "mean of two potential outcomes. The first is the potential"
				noi di as text _col(11) "outcome if, contrary to fact, all subjects received exposure" 
				noi di as text _col(11) "k, and subjects' mediator(s) were set to their potential"
				noi di as text _col(11) "value(s) under baseline exposure. The second is the potential"
				noi di as text _col(11) "outcome if, contrary to fact, all subjects experienced the"
				noi di as text _col(11) "baseline exposure. That is:"
				noi di
				noi di as result _col(19) "NDE" as text "=E[Y{X=k,M(X=0)}]-E[Y{X=0,M(X=0)}]"
				noi di
				noi di as text _col(11) "The natural indirect effect (" as result "NIE(k)" as text ") is the difference between"
				noi di as text _col(11) "the " as result "TCE(k)" as text " and the " as result "NDE(k)" as text ". That is:"
				noi di
				noi di as result _col(15) "NIE(k)" as text "=" as result "TCE(k)" as text "-" as result "NDE(k)" as text "=E[Y{X=k,M(X=k)}]-E[Y{X=k,M(X=0)}]"
				noi di
				if "`control'"!="" {
					noi di as text _col(11) "The controlled direct effect (" as result "CDE(k,m)" as text ") is the difference between"
					noi di as text _col(11) "the mean potential outcome if all subjects were exposed at"
					noi di as text _col(11) "level k, and the mean potential outcome if all subjects" 
					noi di as text _col(11) "received the baseline exposure; and, in addition, in both"
					noi di as text _col(11) "cases, the mediator(s) were set to their control value(s)."
					noi di as text _col(11) "Write m for the control value(s) of the mediator(s), then:"
					noi di
					noi di as result _col(19) "CDE(k,m)" as text "=E{Y(X=k,M=m)}-E{Y(X=0,M=m)}"
					noi di
				}
			}
		}
	}	
	noi di as text " "
	if "`obe'"=="" & "`linexp'"=="" {
		noi di as text _col(10) "Baseline value(s): "
	}
	tokenize "`exposure'"
	local nbase 0 			
	while "`1'"!="" {
		if "`1'"!="," {
			local nbase=`nbase'+1
			local expos`nbase' "`1'"
		}
		mac shift
	}
    tokenize "`mediator'"
	local nmed 0 			
	while "`1'"!="" {
		if "`1'"!="," {
			local nmed=`nmed'+1
			local medi`nmed' "`1'"
		}
		mac shift
	}
	if "`obe'"=="" & "`linexp'"=="" {
		detangle "`baseline'" baseline "`exposure'"
		forvalues i=1/`nbase' {
			if "${S_`i'}"!="" {
				local baseline`i' ${S_`i'}
			}
		}
	}
    if "`control'"!="" {
        detangle "`control'" control "`mediator'"
        forvalues i=1/`nmed' {
        	if "${S_`i'}"!="" {
        		local control`i' ${S_`i'}
        	}
        }
    }
	if "`obe'"=="" & "`linexp'"=="" {
		forvalues i=1/`nbase' {
			local expos`i'="`expos`i''"+" "
			noi di as text _col(15) subinstr("`expos`i''","_ ","",.) "=" _cont
			noi di as result "`baseline`i''"
		}
	}
    if "`control'"!="" {
    	noi di as text " "
    	noi di as text _col(10) "Control value(s): "
    	forvalues i=1/`nmed' { 	
			local medi`i'="`medi`i''"+" "
			noi di as text _col(15) subinstr("`medi`i''","_ ","",.) "=" _cont
			noi di as result "`control`i''"
	    }
    }
	noi di as text " "
	if "`all'"=="" {
		noi di as text _col(2)  "{hline 13}{c TT}{hline 68}"
		noi di as text _col(15) "{c |}" _col(18) "G-computation" _col(34) "Bootstrap" _col(68) "Normal-based"
		noi di as text _col(15) "{c |}" _col(20) "estimate" _col(34) "Std. Err." _col(49) ///
            "z" _col(54) "P>|z|" _col(64) "[95% Conf. Interval]"         
		noi di as text _col(2)  "{hline 13}{c +}{hline 68}"
		if "`control'"=="" {
			local maxrowtab=3
		}
		else {
			local maxrowtab=4
		}
		if "`oce'"!="" {
			qui tab `exposure', matrow(_matrow)
			local nexplev=r(r)-1
		}
		else {
			local nexplev=1			
		}
        forvalues i=1/`maxrowtab' {
			forvalues j=1/`nexplev' {
				if `i'==1 {
					if `nexplev'==1 {
						noi di as text _col(8) "TCE" _col(15) "{c |}" _cont
					}
					else {
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
						noi di as text _col(5) "TCE(" as result "`k'" as text")" _col(15) "{c |}" _cont
					}
				}
				if `i'==2 {
					if `nexplev'==1 {
						noi di as text _col(8) "NDE" _col(15) "{c |}" _cont
					}
					else {
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
						noi di as text _col(5) "NDE(" as result "`k'" as text")" _col(15) "{c |}" _cont
					}
				}
				if `i'==3 {
					if `nexplev'==1 {
						noi di as text _col(8) "NIE" _col(15) "{c |}" _cont
					}
					else {
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
						noi di as text _col(5) "NIE(" as result "`k'" as text")" _col(15) "{c |}" _cont
					}
				}
				if `i'==4 {
					if `nexplev'==1 {
						noi di as text _col(8) "CDE" _col(15) "{c |}" _cont
					}
					else {
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
						noi di as text _col(5) "CDE(" as result "`k'" as text")" _col(15) "{c |}" _cont
					}
				}
				if "`oce'"=="" {
					noi di as result %9.0g _col(19) b[1,`i'] _cont 
					noi di as result _col(33) %9.0g se[1,`i'] _cont
					if b[1,`i']<0 {
						local w=47-max(ceil(log10(abs(round(b[1,`i']/se[1,`i']),0.01))),0)
						noi di as result _col(`w') round(b[1,`i']/se[1,`i'],0.01) _cont
					}		
					else {
						local w=48-max(ceil(log10(abs(round(b[1,`i']/se[1,`i']),0.01))),0)
						noi di as result _col(`w') round(b[1,`i']/se[1,`i'],0.01) _cont
					}
					if round(2*(1-normal(abs(b[1,`i']/se[1,`i']))),0.001)>0 {
						noi di as result _col(54) "0" _col(55) round(2*(1-normal(abs(b[1,`i']/se[1,`i']))),0.001) _cont
						if round(2*(1-normal(abs(b[1,`i']/se[1,`i']))),0.001)== ///
							round(round(2*(1-normal(abs(b[1,`i']/se[1,`i']))),0.001),0.1) {
							noi di _col(57) "00" _cont
						}
						else {
							if round(2*(1-normal(abs(b[1,`i']/se[1,`i']))),0.001)== ///
								round(round(2*(1-normal(abs(b[1,`i']/se[1,`i']))),0.001),0.01) {
								noi di _col(58) "0" _cont
							}
						}
					}
					else {
						noi di as result _col(54) "0.000" _cont
					}
					noi di as result _col(63) %9.0g ci_normal[1,`i'] _cont
					noi di as result _col(75) %9.0g ci_normal[2,`i']  
				}
				else {
					qui tab `exposure', matrow(_matrow)
					local nexplev=r(r)-1
					local ii=(`i'-1)*`nexplev'+`j'
					noi di as result %9.0g _col(19) b[1,`ii'] _cont 
					noi di as result _col(33) %9.0g se[1,`ii'] _cont
					if b[1,`ii']<0 {
						local w=47-max(ceil(log10(abs(round(b[1,`ii']/se[1,`ii']),0.01))),0)
						noi di as result _col(`w') round(b[1,`ii']/se[1,`ii'],0.01) _cont
					}			
					else {
						local w=48-max(ceil(log10(abs(round(b[1,`ii']/se[1,`ii']),0.01))),0)
						noi di as result _col(`w') round(b[1,`ii']/se[1,`ii'],0.01) _cont
					}
					if round(2*(1-normal(abs(b[1,`ii']/se[1,`ii']))),0.001)>0 {
						noi di as result _col(54) "0" _col(55) round(2*(1-normal(abs(b[1,`ii']/se[1,`ii']))),0.001) _cont
						if round(2*(1-normal(abs(b[1,`ii']/se[1,`ii']))),0.001)== ///
							round(round(2*(1-normal(abs(b[1,`ii']/se[1,`ii']))),0.001),0.1) {
							noi di _col(57) "00" _cont
						}
						else {
							if round(2*(1-normal(abs(b[1,`ii']/se[1,`ii']))),0.001)== ///
								round(round(2*(1-normal(abs(b[1,`ii']/se[1,`ii']))),0.001),0.01) {
								noi di _col(58) "0" _cont
							}
						}
					}
					else {
						noi di as result _col(54) "0.000" _cont
					}
					noi di as result _col(63) %9.0g ci_normal[1,`ii'] _cont
					noi di as result _col(75) %9.0g ci_normal[2,`ii']
					if `j'==`nexplev' & `i'!=`maxrowtab' {
						noi di as text _col(2)  "{hline 13}{c +}{hline 68}"
					}
				}
			}	
		}
		noi di as text _col(2)  "{hline 13}{c BT}{hline 68}"
	}
	else {
		noi di as text _col(2)  "{hline 13}{c TT}{hline 74}"
		noi di as text _col(15) "{c |}" _col(18) "G-computation" _col(34) "Bootstrap"
		noi di as text _col(15) "{c |}" _col(20) "estimate" _col(34) "Std. Err." _col(49) ///
            "z" _col(54) "P>|z|" _col(64) "[95% Conf. Interval]"         
		noi di as text _col(2)  "{hline 13}{c +}{hline 74}"
        if "`control'"=="" {
            local maxrowtab=3
        }
        else {
            local maxrowtab=4
        } 
		if "`oce'"!="" {
			qui tab `exposure', matrow(_matrow)
			local nexplev=r(r)-1
		}
		else {
			local nexplev=1			
		}
        forvalues i=1/`maxrowtab' {
			forvalues j=1/`nexplev' {
				if `i'==1 {
					if `nexplev'==1 {
						noi di as text _col(8) "TCE" _col(15) "{c |}" _cont
					}
					else {
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
						noi di as text _col(5) "TCE(" as result "`k'" as text")" _col(15) "{c |}" _cont
					}
				}
				if `i'==2 {
					if `nexplev'==1 {
						noi di as text _col(8) "NDE" _col(15) "{c |}" _cont
					}
					else {
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
						noi di as text _col(5) "NDE(" as result "`k'" as text")" _col(15) "{c |}" _cont
					}
				}
				if `i'==3 {
					if `nexplev'==1 {
						noi di as text _col(8) "NIE" _col(15) "{c |}" _cont
					}
					else {
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
						noi di as text _col(5) "NIE(" as result "`k'" as text")" _col(15) "{c |}" _cont
					}
				}
				if `i'==4 {
					if `nexplev'==1 {
						noi di as text _col(8) "CDE" _col(15) "{c |}" _cont
					}
					else {
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
						noi di as text _col(5) "CDE(" as result "`k'" as text")" _col(15) "{c |}" _cont
					}
				}
				if "`oce'"=="" {
			   	   	noi di as result %9.0g _col(19) b[1,`i'] _cont 
					noi di as result _col(33) %9.0g se[1,`i'] _cont
					if b[1,`i']<0 {
						local w=47-max(ceil(log10(abs(round(b[1,`i']/se[1,`i']),0.01))),0)
						noi di as result _col(`w') round(b[1,`i']/se[1,`i'],0.01) _cont
					}		
					else {
						local w=48-max(ceil(log10(abs(round(b[1,`i']/se[1,`i']),0.01))),0)
						noi di as result _col(`w') round(b[1,`i']/se[1,`i'],0.01) _cont
					}
					if round(2*(1-normal(abs(b[1,`i']/se[1,`i']))),0.001)>0 {
						noi di as result _col(54) "0" _col(55) round(2*(1-normal(abs(b[1,`i']/se[1,`i']))),0.001) _cont
						if round(2*(1-normal(abs(b[1,`i']/se[1,`i']))),0.001)== ///
							round(round(2*(1-normal(abs(b[1,`i']/se[1,`i']))),0.001),0.1) {
							noi di _col(57) "00" _cont
						}
						else {
							if round(2*(1-normal(abs(b[1,`i']/se[1,`i']))),0.001)== ///
								round(round(2*(1-normal(abs(b[1,`i']/se[1,`i']))),0.001),0.01) {
								noi di _col(58) "0" _cont
							}
						}
					}
					else {
						noi di as result _col(54) "0.000" _cont
					}
					noi di as result _col(63) %9.0g ci_normal[1,`i'] _cont
					noi di as result _col(75) %9.0g ci_normal[2,`i'] _cont
					noi di as text "   (N)"
					noi di as text _col(15) "{c |}" _cont
					noi di as result _col(63) %9.0g ci_percentile[1,`i'] _cont
					noi di as result _col(75) %9.0g ci_percentile[2,`i'] _cont
					noi di as text "   (P)"
					noi di as text _col(15) "{c |}" _cont
					noi di as result _col(63) %9.0g ci_bc[1,`i'] _cont
					noi di as result _col(75) %9.0g ci_bc[2,`i'] _cont
					noi di as text "  (BC)"
					noi di as text _col(15) "{c |}" _cont
					noi di as result _col(63) %9.0g ci_bca[1,`i'] _cont
					noi di as result _col(75) %9.0g ci_bca[2,`i'] _cont
					noi di as text " (BCa)"
				}
				else {
					qui tab `exposure', matrow(_matrow)
					local nexplev=r(r)-1
					local ii=(`i'-1)*`nexplev'+`j'
					noi di as result %9.0g _col(19) b[1,`ii'] _cont 
					noi di as result _col(33) %9.0g se[1,`ii'] _cont
					if b[1,`ii']<0 {
						local w=47-max(ceil(log10(abs(round(b[1,`ii']/se[1,`ii']),0.01))),0)
						noi di as result _col(`w') round(b[1,`ii']/se[1,`ii'],0.01) _cont
					}		
					else {
						local w=48-max(ceil(log10(abs(round(b[1,`ii']/se[1,`ii']),0.01))),0)
						noi di as result _col(`w') round(b[1,`ii']/se[1,`ii'],0.01) _cont
					}
					if round(2*(1-normal(abs(b[1,`ii']/se[1,`ii']))),0.001)>0 {
						noi di as result _col(54) "0" _col(55) round(2*(1-normal(abs(b[1,`ii']/se[1,`ii']))),0.001) _cont
						if round(2*(1-normal(abs(b[1,`ii']/se[1,`ii']))),0.001)== ///
							round(round(2*(1-normal(abs(b[1,`ii']/se[1,`ii']))),0.001),0.1) {
							noi di _col(57) "00" _cont
						}
						else {
							if round(2*(1-normal(abs(b[1,`ii']/se[1,`ii']))),0.001)== ///
								round(round(2*(1-normal(abs(b[1,`ii']/se[1,`ii']))),0.001),0.01) {
								noi di _col(58) "0" _cont
							}
						}
					}
					else {
						noi di as result _col(54) "0.000" _cont
					}
					noi di as result _col(63) %9.0g ci_normal[1,`ii'] _cont
					noi di as result _col(75) %9.0g ci_normal[2,`ii'] _cont
					noi di as text "   (N)"
					noi di as text _col(15) "{c |}" _cont
					noi di as result _col(63) %9.0g ci_percentile[1,`ii'] _cont
					noi di as result _col(75) %9.0g ci_percentile[2,`ii'] _cont
					noi di as text "   (P)"
					noi di as text _col(15) "{c |}" _cont
					noi di as result _col(63) %9.0g ci_bc[1,`ii'] _cont
					noi di as result _col(75) %9.0g ci_bc[2,`ii'] _cont
					noi di as text "  (BC)"
					noi di as text _col(15) "{c |}" _cont
					noi di as result _col(63) %9.0g ci_bca[1,`ii'] _cont
					noi di as result _col(75) %9.0g ci_bca[2,`ii'] _cont
					noi di as text " (BCa)"
					if `j'==`nexplev' & `i'!=`maxrowtab' {
						noi di as text _col(2)  "{hline 13}{c +}{hline 74}"
					}
				}
			}
		}
		noi di as text _col(2)  "{hline 13}{c BT}{hline 74}"
		noi di as text " (N)    normal confidence interval"
		noi di as text " (P)    percentile confidence interval"
		noi di as text " (BC)   bias-corrected confidence interval"
		noi di as text " (BCa)  bias-corrected and accelerated confidence interval"
    }
}
return clear
ereturn clear
if "`msm'"=="" {
	if "`mediation'"=="" {
		return scalar obs_data=`PO0'
		mat _po=b
		mat _se_po=se
	}
	else {
		if "`oce'"=="" {
			return scalar tce=b[1,1]
			return scalar nde=b[1,2]
			return scalar nie=b[1,3]
			return scalar cde=b[1,4]
			return scalar se_tce=se[1,1]
			return scalar se_nde=se[1,2]
			return scalar se_nie=se[1,3]
			return scalar se_cde=se[1,4]
		}
		else {
			forvalues j=1/`nexplev' {
				return scalar tce_`j'=b[1,`j']
				return scalar nde_`j'=b[1,`nexplev'+`j']
				return scalar nie_`j'=b[1,2*`nexplev'+`j']
				return scalar cde_`j'=b[1,3*`nexplev'+`j']
				return scalar se_tce_`j'=se[1,`j']
				return scalar se_nde_`j'=se[1,`nexplev'+`j']
				return scalar se_nie_`j'=se[1,2*`nexplev'+`j']
				return scalar se_cde_`j'=se[1,3*`nexplev'+`j']
			}
		}
	}
}
else {
	if "`mediation'"=="" {
		return scalar obs_data=`PO0'
		mat _b_msm=b[1,1..`r1']
		mat _se_msm=se[1,1..`r1']
		local r2=`r1'+1
		mat _po=b[1,`r2'...]
		mat _se_po=se[1,`r2'...]
	}
}
if "`mediation'"=="" {
	return scalar N=$maxid
}
else {
	return scalar N=_N
}
return scalar MC_sims=`simulations'

end

exit
