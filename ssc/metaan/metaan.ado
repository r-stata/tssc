/*  meta analysis module by Evangelos Kontopantelis
    created in STATA v9.2, 26 October 2009
    v1.1 10 Jan 2013
		-set variables to double for better precision when study variance is extremely small
    v1.2 25 Feb 2013
		-added bootstrap method (default is 1,000 iterations)
		-added sensitivity analysis using pre-set value for I^2
    v1.3 16 Oct 2013
		-renamed diff scalars since overlap with variables is likely
    v1.4 14 Aug 2014
		-added option to deal with proportions - Freeman-Tukey transformation
    v1.5 05 Sep 2014
		-corrected strange STATA error that suppressed heterogeneity outputs: must have been using variable name recently reserved by Stata (tausq)
		-changed reported H^2 from H^2M (i.e. H^2 - 1) to H^2 to avoid confusion
		-added support for alpha other than 5%
		-addded test based CIs for heterogeneity measures
    v1.6 18 Sep 2014
		-added support for back-transforming effects for binary outcomes to ORs
    v1.7 20 Jun 2015
		-CIs for I^2 and H^2 added to returned scalars
    v2.0 12 Apr 2016
		-major update for forest plot to use program _dipgby by Ross Harris & Mike Bradburn
    v2.1 12 Apr 2016
		-seed number no longer set automatically
    v3.0 11 Apr 2017
		-by option added for subgroup analyses
    v4.0 25 Jul 2018
		-added support for binary data (MH, IV or Peto)
    v4.1 10 Sep 2018
		-added back-transformation for empirical logit
		-gave up moving REML code to main ado file (Stata does not allow this for ML algrithms)
		-added pscl option for [0,1] or [0,100] scaling of percentages (used with prp or backt options only)
    v4.2 17 Sep 2019
		-corrected to allow additional twway graph options
    v4.3 28 Jan 2020
		-four variable syntax now asks for events and non-events, rather than events and totals
		
*/

/*stata version define*/
version 9

/*metaan calculates the effect and SE for each study (if possible)*/
program define metaan, rclass
    /*command syntax*/
    syntax namelist(min=2 max=4) [if] [in], /*
	*/ [fe dl bdl ml reml pl pe sa exp varc prp label(string) forest /*
	*/ reps(integer -127) seed(integer -127) sens(real 80) plplot(string) /*
	*/ grpby(varname numeric) backt(string) pscl /*
	*/ /*MH and Peto methods*/ mhor mhrr mhrd por poe /* 	
	*/ /*new plot options*/ DP(integer 2) ASTEXT(integer 50) TEXTSize(real 100.0) /*
	*/ BOXSCA(real 100.0) noOVERALL NOHET NULL(real 999) NULLOFF NOWARNING XLAbel(passthru) /*
	*/ XTick(passthru) FORCE SUMMARYONLY EFFECT(string) FAVOURS(string) /*
	*/ DOUBLE BOXOPT(string) CLASSIC DIAMOPT(string) POINTOPT(string) CIOPT(string) /*
	*/ OLINEOPT(string) noSTATS noWT /*
	*/ /*junk now*/ forestw(real -127.5) * ]
    /*temp variables used in all methods*/
    tempvar temp1 temp2 temp3 temp4
    /*temp scalars*/
    tempname btor
    /*INITIAL STUFF*/
    //get level
    local clvl=c(level)
    local mltps=(100-`clvl')/200
    local mltpl=invnormal(1-(100-`clvl')/200)
	//methods
	local mlist1 "fe dl bdl ml pl reml pe sa poe"	
    /*find out if the variables specified are there and include the information they are supposed to have*/
	local tswc=wordcount("`namelist'")
	forvalues i=1(1)`tswc' {
		local var`i' = word("`namelist'",`i')
	}
	if `tswc'==3 {
        di as error "Output variables need to be two or four (see help file)"
        error 110	
	}
    /*make sure a user doesn't give the same variable names*/
	forvalues i=1(1)`tswc' {
		forvalues j=1(1)`tswc' {
			if `i'!=`j' & "`var`i''"=="`var`j''" {
				di as error "Outcome variables need to have different names!"
				error 110
			}
		}
    }
	//find out the variable specified is there and includes the information they are supposed to have
	forvalues i=1(1)`tswc'{
		capture confirm numeric variable `var`i'', exact
		if _rc!=0 {
			di as error "Variable `var`i'' does not exist or is not numeric"
			error 110
		}		
	}
	
	/*check what is happening with model options*/
	local mdcnt=0
	forvalues i=1(1)`=wordcount("`mlist1'")' {
		if "``=word("`mlist1'",`i')''"!="" local mdcnt = `mdcnt' + 1			
	}
	if `mdcnt'>=2 {
		di as error "Please select only one model option"
		error 110
	}	
	
	//if provided effect and its variability
	if `tswc'==2 {	
		if `mdcnt' == 0 {
			di as error "You must select a model option: fe, dl, bdl, ml, pl, reml, pe ,sa, poe"
			error 110
		}
		//variables that need to be positive		
		qui sum `var2' `if' `in'
		if r(min)<=0 {
			di as error "Variable `var2' must only contain positive numbers"
			error 110
		}	
		/*prp and varc*/
		if "`prp'"!="" {
			if "`varc'"!="" {
				di as error "Cannot use varc and prp options together: either standard meta-analysis or one of proportions!"
				error 110
			}
		}
		//exponentiate or not
		scalar `btor'=0
		if "`exp'"!="" {
			scalar `btor'=1
			if "`prp'"!="" {
				di as error "Cannot use exp and prp options together: either meta-analysis of dichotomous outcomes or one of proportions!"
				error 110
			}
		}
		//additional checks and info if MA of proportions
		scalar prpinfo=0
		if "`prp'"!="" {
			//make sure both variables include integers and positive
			qui sum `var1'
			scalar minvar1=r(min)
			if r(min)<0 {
				di as error "Variable `var1' (numerators) must only contain positive or zero numbers"
				error 110
			}
			qui count if mod(`var1', 1)!=0 & `var1'!=.
			if r(N)>0 {
				di as error "Variable `var1' (numerators) must only contain integers"
				error 110
			}
			qui count if mod(`var2', 1)!=0 & `var2'!=.
			if r(N)>0 {
				di as error "Variable `var2' (denominators) must only contain integers"
				error 110
			}
			//make sure denominators are not smaller than numerators
			qui gen `temp1'=`var2'-`var1'
			qui sum `temp1'
			if r(min)<0 {
				di as error "Numerators appear larger than denominators in some cases"
				error 110
			}
			qui drop `temp1'
			//to pass to forest plot for range
			scalar prpinfo=1
		}
		//cannot have Peto or MH
		if "`mhor'"!="" | "`mhrr'"!="" | "`mhrd'"!="" | "`por'"!="" {
			di as error "Cannot select Peto or Mantel-Haenszel when providing an effect and its variance"
			error 110
		}		
		/*Back-transformation options - logit (need percentage) or empirical logit (need percentage and denominator)*/
		local btcntr=0
		if "`backt'"!="" {
			if "`prp'"!="" {
				di as error "Options backt and prp cannot be requested together"
				error 197		
			}
			if "`exp'"!="" {
				di as error "Options backt and exp cannot be requested together"
				error 197		
			}			
			tokenize "`backt'", parse(" ,")
			if "`3'"!="" {
				di as error "At most two variable names in backt() for empirical logit: percentages and denominators"
				error 197
			}
			while "`1'"!="" {
				cap confirm var `1'
				if _rc!=0  {
					di as err "Back-transformation variable `1' not defined"
					error 109
				}
				/*store variable names in local variables for future use*/
				local btcntr = `btcntr'+1
				local btvar`btcntr' = "`1'"
				macro shift
			}
			//make sure first variable is percentages and second denominators
			forvalues i=1(1)`btcntr' {
				capture confirm numeric variable `btvar`i'', exact
				if _rc!=0 {
					di as error "Variable `btvar`i'' does not exist or is not numeric"
					error 109
				}		
				if `i'==1 {
					qui sum `btvar`i''
					if r(min)<0 | r(max)>1 {
						di as error "Variable `btvar`i'' holds percentages and  needs to be in the [0,1] range"
						error 109					
					}
					//if only one variable provided (percentages) it cannot have any zeros
					if `btcntr'==1 & (r(min)==0 | r(max)==1) {
						di as error "Logit back-transformation cannot be applied to variable `btvar`i'' (percentages) since it holds zeros and/or ones"
						di as error "Include values in the (0,1) range or provide denominators so that the empirical logit back-transfomration can be applied"						
						error 109					
					}
				}
				if `i'==2 {
					qui count if mod(`btvar`i'', 1)!=0
					local bttmp=r(N)				
					qui sum `btvar`i''
					if r(min)<=0 | `bttmp'>0 {
						di as error "Variable `btvar`i'' holds denominators (positive integers)"
						error 109					
					}
				}			
			}
		}	
		//pscl option can only be used with prp or backt
		if "`pscl'"!="" {
			if "`backt'"=="" & "`prp'"=="" {
				di as error "Option pscl can only be used with backt or prp options"
				error 197					
			}
		}
	}
	
	//if provided events and non-events variables
	if `tswc'==4 {		
		scalar prpinfo=0
		//calculate denominators to comply with changing input
		qui gen `temp1'=`var1'+`var2'
		qui gen `temp2'=`var3'+`var4'
		//exponentiate or not
		scalar `btor'=0
		if "`exp'"!="" {
			scalar `btor'=1
			if "`mhrd'"!="" {
				di as error "Cannot use exp option with Mantel-Haenszel Risk Difference (option mhrd)"
				error 110
			}
		}
		//events
		foreach i in 1 3 {
			qui sum `var`i''
			if r(min)<0 {
				di as error "Variable `var`i'' must only contain non-negative numbers"
				error 110
			}
		}
		//denominators
		foreach i in 1 2 {
			qui sum `temp`i''
			if r(min)<=0 {
				di as error "Events and non-events for group `i' must be positive"
				error 110
			}
		}		
		//options not allowed
		foreach x in prp varc backt {
			if "``x''"!="" {
				di as error "Cannot use option `x' with events and populations variables"
				error 110
			}
		}
		if "`poe'"!="" {
			di as error "Cannot use Peto O-E option (poe) with the four variable syntax - needs HR or OR estimates"
			error 110
		}
		//must have one of Peto or MH
		local cnt = 0
		foreach x in por mhor mhrr mhrd {
			if "``x''"!="" local cnt = `cnt' + 1
		}
		if `cnt' == 0 {
			di as error "You must select a calculation option when using events and populations: por, mhor, mhrr, mhrd"
			error 110
		}
		else if `cnt'>=2 {
			di as error "Please select only one calculation option (por, mhor, mhrr, mhrd)"
			error 110
		}		
		qui drop `temp1' `temp2'
	}	
	
	//if provided effect and its variability OR a different model has been selected for event data
	if "`tswc'"=="2" | ("`tswc'"=="4" & `mdcnt'>0) {				 							
		/*if profile likelihood plot is selected*/
		if "`plplot'"!="" {
			if "`ml'"=="" & "`pl'"=="" & "`reml'"=="" {
				di as error "Option plplot can only be used with the maximum-likelihood, profile-likelihood & restricted maximum-likelihood methods"
				exit
			}
			tokenize "`plplot'", parse(" ,")
			if "`2'"!="" | ("`1'"!="mu" & "`1'"!="tsq") {
				di as error "Please use plplot with either the mu or tsq option i.e. plplot(mu) or plplot(tsq)"
				exit
			}
			local plplotvar = "`1'"
		}
		/*bootsrap options*/
		if `reps'!=-127 & "`bdl'"=="" {
			di as error "Bootsrap repetitions option only required for the Bootstrapped DerSimonian-Laird method"
			error 110
		}
		if "`bdl'"!="" {
			/*set default to 1000*/
			if `reps'==-127 local reps=1000
			/*error if few repetitions chosen*/
			if `reps'<100 {
				di as error "At least 100 repetitions are recommended"
				error 110
			}
		}
		/*sensitivity analysis*/
		if "`sa'"!="" {
			if `sens'<0 | `sens'>=100 {
				di as error "Sensitivity analyses performed using an I^2 value and constrained to [0,100)"
				error 110
			}
		}
		else {
			if `sens'!=80 {
				di as error "sens() option can only be used when requesting a sensitivity analysis (sa) model"
				error 110
			}
		}
	}

	//common in both 2 or 4 input variables		
    /*to select one of the plot options*/
    local cnt=0
    foreach x in forest plplot {
        if "``x''"!="" local cnt = `cnt' + 1
    }
    if `forestw'!=-127.5 local cnt = `cnt' + 1
    /*if more than one plot options used come back with an error*/
    if `cnt'>1 {
        di as error "Please select only one of the available plot options"
        error 110
    }
    /*set seed*/
    if `seed'!=-127 {
       qui set seed `seed'
    }
	/*by option*/
	if "`grpby'" !="" {
		qui count if mod(`grpby', 1)!=0
		if r(N)>0 {
            di as error "by option variable needs to be numeric and include integers only"
            exit			
		}
	}
    /*label options - title(authors) or year or both*/
    local lcntr=0
    if "`label'"!="" {
    	tokenize "`label'", parse(" ,")
    	if "`3'"!="" {
            di as error "At most two variable names in label(): e.g ...label(authors year)"
            exit
        }
    	while "`1'"!="" {
    		cap confirm var `1'
    		if _rc!=0  {
    			di as err "Label variable `1' not defined"
    			exit
    		}
    		/*store variable names in local variables for future use*/
    		local lcntr = `lcntr'+1
            local lvar`lcntr' = "`1'"
    		macro shift
    	}
    }

	//NEW FOREST PLOT OPTIONS
	global MA_dp = "`dp'"
	global MA_AS_TEXT `astext'
	global MA_TEXT_SCA `textsize'
	global MA_FBSC `boxsca'		
	global MA_nulloff "`nulloff'"
	global MA_nohet "`nohet'"		
	global MA_nowarning "`nowarning'"	
	if `null'!=999 {
		global MA_NULL=`null'
	}
	else {
		//set default null if none provided
		if `btor'==1{
			global MA_NULL=1
		}
		else {
			global MA_NULL=0
		}
	}
	global MA_rfdist ""	/*future trial option not used*/
	global RFL ""
	local xcounts ""	/*raw counts display not used*/
	global MA_G1L ""
	global MA_G2L ""
	local log ""		/*issued with raw counts so not using*/
	//if meta-analysis of proportions
	if prpinfo==1 {
		if "`xlabel'"=="" {
			if "`pscl'"=="" {
				local xlabel "xlabel(0,0.2,0.4,0.6,0.8,1)"
			}
			else {
				local xlabel "xlabel(0,20,40,60,80,100)"
			}
		}
		local force="force"
		global MA_nulloff "nulloff"
	}	
	global MA_rjhby "`grpby'"	/*BY option*/
	global rjhHetGrp ""
	global MA_summaryonly "`summaryonly'"
	global MA_params = 0	/*irrelevant - number of parameters as input in metan*/
	global IND=`clvl'
	global MA_ESLA "`effect'"
	global MA_FAVOURS "`favours'"
	if "`effect'"=="" {
		local sumstat "ES" 
		if `btor'==1 {
			local sumstat "OR"
			if "`mhrr'"!="" {
				local sumstat "RR"
			}
			else if "`mhrd'"!="" {
				local sumstat "RD"
			}			
			else if "`poe'"!="" {
				local sumstat "HR"
			}						
		}
	}
	else {
		local sumstat "`effect'"
	}
	global MA_firststats ""
	global MA_secondstats ""
	global MA_userDescM ""				/*irrelevant - linked to first() option in metan*/
	global MA_userDesc ""
	global MA_DOUBLE  "`double'"
	global MA_efficacy ""				/*irrelevant - linked to efficacy() option in metan*/
	global MA_OTHEROPTS `"`options'"'	/*graph options added - _dispgby can identify them*/
	global MA_BOXOPT `"`boxopt'"'
	global MA_classic "`classic'"
	global MA_DIAMOPT `"`diamopt'"'
	global MA_POINTOPT `"`pointopt'"'
	global MA_CIOPT `"`ciopt'"'
	global MA_OLINEOPT `"`olineopt'"'
	
    /*use temporary file to mess with the data as much as needed (can't use tempvar because need to call in many programs)*/
    preserve	
    /*in and if options - create temp variable that will enable thir usage*/
    qui capture drop use
    qui gen use = 0
    qui replace use = 1 `if' `in'
    qui drop if use==0
	
	//if provided use effect and its variance
	if `tswc'==2 {	
		/*rename to avoid using the same variable names*/
		capture drop tempeff_007
		rename `var1' tempeff_007
		capture drop tempeff_007var
		rename `var2' tempeff_007var
		capture drop eff
		capture drop effvar
		//different approach for standard MA and one of proportions
		if prpinfo==0 {
			/*varc variable option and changes*/
			qui gen double eff = tempeff_007
			if "`varc'"!="" {
				qui gen double effvar = tempeff_007var
			}
			else {
				qui gen double effvar = tempeff_007var^2
			}
		}
		else {
			//if proportions transform (tempeff_007=num, tempeff_007var=den)
			/*effect & SE*/
			qui gen double eff = asin(sqrt(tempeff_007/(tempeff_007var+1))) + asin(sqrt((tempeff_007+1)/(tempeff_007var+1)))
			qui gen double effvar = (1/(tempeff_007var+1))
		}
		/*exclude studies where the eff or the SEeff are missing*/
		qui replace use=0 if eff==. | effvar==.
		qui drop if use==0		
	}
	//if events and denominator calculate
	else {
		/*rename to avoid using the same variable names*/
		capture drop ev1_127
		rename `var1' ev1_127
		capture drop total1_127
		qui gen total1_127=ev1_127+`var2'
		capture drop ev2_127
		rename `var3' ev2_127
		capture drop total2_127
		qui gen total2_127=ev2_127+`var4'		
		/*exclude studies where the eff or the SEeff are missing*/
		qui replace use=0 if ev1_127==. | ev2_127==. | total1_127==. | total2_127==.
		qui drop if use==0				
		capture drop eff
		capture drop effvar
		capture drop weights
		
		//call selected weighting program to return eff and eff var
		if "`mhor'"!="" {
			calc_MHORf "gen"
		}		
		else if "`mhrr'"!="" {
			calc_MHRRf "gen"
		}		
		else if "`mhrd'"!="" {
			calc_MHRDf "gen"
		}			
		else if "`por'"!="" {
			calc_PORf "gen"
		}			
		
		*restore, not
		*error
	}	
	
    /*generate and id for the studies*/
    qui capture qui drop studyid
    qui egen studyid = seq()
    /*create label temp variable*/
    /*first convert if needed to string variables*/
    forvalues i=1(1)`lcntr' {
        qui capture confirm string var `lvar`i''
        if _rc!=0 {
            qui capture drop temp1
            qui gen temp1 = string(`lvar`i'')
            qui drop `lvar`i''
            qui rename temp1 `lvar`i''
        }
    }
    /*then merge*/
    qui capture drop labelvar
    if `lcntr'==0 {
        qui gen str20 labelvar = string(studyid)
    }
    else if `lcntr'==1 {
        qui gen str20 labelvar = trim(`lvar1')
    }
    else {
        qui gen str20 labelvar = trim(`lvar1') + ", " + trim(`lvar2')
    }
    /*lower and upper CI for studies*/
    qui capture drop studyloCI
    qui capture drop studyupCI
    qui gen studyloCI = eff - `mltpl'*sqrt(effvar)
    qui gen studyupCI = eff + `mltpl'*sqrt(effvar)

	
	//loop to accomodate by option
	local numloop=1
	if "`grpby'"!="" {
		qui tab `grpby'
		local numloop=r(r)+1
		//mess with variable to make sure it's numbered 1(1)max
		local lblfoo : val label `grpby'
		qui sum `grpby'
		local tmpmin=r(min)
		local tmpmax=r(max)
		local cntr=0
		qui gen tgrpby=.		
		forvalues i=`tmpmin'(1)`tmpmax' {
			qui count if `grpby'==`i'
			if r(N)>0 {
				local cntr=`cntr'+1
				qui replace tgrpby=`cntr' if `grpby'==`i'
				if "`lblfoo'"=="" {
					local tfoo`cntr' "`i'"
				}				
				else {
					local tfoo`cntr' : label `lblfoo' `i'
				}
				label define tgrpbylbl `cntr' "`tfoo`cntr''", add				
			}
		}		
		label val tgrpby tgrpbylbl
		sort tgrpby		
	}
	tempfile master1 
	qui save `master1', replace
	
	forvalues xlp=1(1)`numloop' {
		qui use `master1', clear
		if `numloop'>1 {
			if `xlp'<`numloop' {
				qui keep if tgrpby==`xlp'
				di _newline(2) as text "Subgroup analysis: `tfoo`xlp''"
			}
			else {
				di _newline(2) as text "Overall analysis"
			}
		}
	
		/*CALCULATE ALL METHODS*/
		/*number of used studies*/
		qui count
		scalar k=r(N)
		
		/*********************/
		/*Fixed effects model*/
		qui gen double `temp1' = eff/effvar
		qui sum `temp1'
		scalar sum1 = r(sum)
		qui gen double `temp2' = 1/effvar
		qui sum `temp2'
		scalar sum2 = r(sum)
		/*mean & var estimates*/
		scalar fe_mu = sum1/sum2
		scalar fe_var = 1/sum2
		/*weights - to be used in display and graphs - different for each method*/
		qui capture drop weights
		qui gen double weights = `temp2'/sum2
		qui drop `temp1' `temp2'
		scalar fe_lo = fe_mu - `mltpl'*sqrt(fe_var)
		scalar fe_up = fe_mu + `mltpl'*sqrt(fe_var)		

		/*************************/
		/*DerSimonian-Laird model*/
		/*calculate Cochran's Qw*/
		qui gen double `temp1' = (1/effvar)*(eff-fe_mu)^2
		qui sum `temp1'
		scalar qw = r(sum)
		qui drop `temp1'
		/*calculate t^2 estimate*/
		qui gen double `temp1' = 1/effvar
		qui sum `temp1'
		scalar sum1 = r(sum)
		qui gen double `temp2' = (1/effvar)^2
		qui sum `temp2'
		scalar sum2 = r(sum)
		/* t^2 can't be negative!*/
		scalar tsq_dl = max((qw-(k-1))/(sum1-sum2/sum1),0)
		/*calculate the s^2 that will be used in the heterogeneity measures*/
		scalar ssq = (k-1)*sum1/(sum1^2-sum2)
		qui drop `temp1' `temp2'
		/*DL model*/
		qui gen double `temp1' = eff/(effvar+tsq_dl)
		qui sum `temp1'
		scalar sum1 = r(sum)
		qui gen double `temp2' = 1/(effvar+tsq_dl)
		qui sum `temp2'
		scalar sum2 = r(sum)
		/*weights - to be used in display and graphs - different for each method*/
		if "`dl'"!="" | "`pe'"!="" {
			qui capture drop weights
			qui gen weights = `temp2'/sum2
		}
		/*mean & var estimates*/
		scalar dl_mu = sum1/sum2
		scalar dl_var = 1/sum2
		scalar dl_lo = dl_mu - `mltpl'*sqrt(dl_var)
		scalar dl_up = dl_mu + `mltpl'*sqrt(dl_var)
		qui drop `temp1' `temp2'
		
		/****************/
		/*T-test "model"*/
		/*only use effect sizes and not effect variances*/
		qui sum eff
		scalar tt_mu = r(mean)
		scalar tt_var = r(Var)
		/*calculate CIs*/
		scalar tt_lo = tt_mu - invttail(k-1,`mltps')*sqrt(tt_var/k)
		scalar tt_up = tt_mu + invttail(k-1,`mltps')*sqrt(tt_var/k)			
		
		/*********************/
		/*events methods**/
		if `tswc'==4 & `mdcnt'==0 {	
			if "`por'"!="" {
				calc_PORf "gen"
				scalar peto_mu = r(mu)
				scalar peto_var = r(var)
				scalar peto_lo = r(lo)
				scalar peto_up = r(up)		
			}		
			else {
				if "`mhor'"!="" {
					calc_MHORf "gen"
				}
				else if "`mhrr'"!="" {
					calc_MHRRf "gen"
				}				
				else if "`mhrd'"!="" {
					calc_MHRDf "gen"
				}					
				scalar mh_mu = r(mu)
				scalar mh_var = r(var)
				scalar mh_lo = r(lo)
				scalar mh_up = r(up)
			}
		}		
		
		/*********************/
		/*O-E Peto method**/
		if "`poe'"!="" {
			calc_PORf "partgen" "effex"
			scalar poe_mu = r(mu)
			scalar poe_var = r(var)
			scalar poe_lo = r(lo)
			scalar poe_up = r(up)		
		}				

		/*************************/
		/*DerSimonian-Laird bootstrap model*/
		/*only if requested*/
		if "`bdl'"!="" {
			tempvar teffvar teff
			forvalues i=1(1)`reps' {
				qui gen `teffvar'=.
				qui gen `teff'=.
				/*NEED A RANDOM SAMPLE WITH REPLACEMENT*/
				forvalues j=1(1)`=k' {
					local tnum = 1+int((`=k')*runiform())
					qui replace `teff'=eff[`tnum'] in `j'
					qui replace `teffvar'=effvar[`tnum'] in `j'
				}
				/*CALCULATE COCHRAN'S Qw */
				qui gen double `temp1' = (1/`teffvar')*(`teff'-fe_mu)^2
				qui sum `temp1'
				scalar _qw = r(sum)
				qui drop `temp1'
				/*CALCULATE ESTIMATE of t^2*/
				qui gen double `temp1' = 1/`teffvar'
				qui sum `temp1'
				scalar sum1 = r(sum)
				qui gen double `temp2' = (1/`teffvar')^2
				qui sum `temp2'
				scalar sum2 = r(sum)
				/* t^2 can't be negative!*/
				scalar _tsq_dl = max((_qw-(k-1))/(sum1-sum2/sum1),0)
				/*calculate the s^2 that will be used in the heterogeneity measures*/
				scalar _ssq = (k-1)*sum1/(sum1^2-sum2)
				/*add to MATA matrices*/
				if `i'==1 {
					qui mata: A = st_numscalar("_tsq_dl")
					qui mata: B = st_numscalar("_ssq")
					qui mata: C = st_numscalar("_qw")
					*qui mata: eff=st_data(.,"`teff'")
					*qui mata: effvar=st_data(.,"`teffvar'")
				}
				else {
					qui mata: A = (A \ st_numscalar("_tsq_dl"))
					qui mata: B = (B \ st_numscalar("_ssq"))
					qui mata: C = (C \ st_numscalar("_qw"))
					*qui mata: eff=(eff, st_data(.,"`teff'"))
					*qui mata: effvar=(effvar, st_data(.,"`teffvar'"))
				}
				*list `teff' `teffvar'
				qui drop `temp1' `temp2' `teff' `teffvar'
			}
			/*use MATA matrices to calculate means*/
			mata: meanA = mean(A)
			mata: meanB = mean(B)
			mata: meanC = mean(C)
			mata: st_numscalar("tsq_bdl", meanA)
			mata: st_numscalar("ssq", meanB)
			mata: st_numscalar("qw", meanC)
			/*DL model*/
			qui gen double `temp1' = eff/(effvar+tsq_bdl)
			qui sum `temp1'
			scalar sum1 = r(sum)
			qui gen double `temp2' = 1/(effvar+tsq_bdl)
			qui sum `temp2'
			scalar sum2 = r(sum)
			/*weights - to be used in display and graphs - different for each method*/
			qui capture drop weights
			qui gen weights = `temp2'/sum2
			/*mean & var estimates*/
			scalar bdl_mu = sum1/sum2
			scalar bdl_var = 1/sum2
			scalar bdl_lo = bdl_mu - `mltpl'*sqrt(bdl_var)
			scalar bdl_up = bdl_mu + `mltpl'*sqrt(bdl_var)
			qui drop `temp1' `temp2'
		}
		

		/*************************/
		/*Sensitivity analysis*/
		if "`sa'"!="" {
			/*get I^2 and H^2 values*/
			scalar Isq=`sens'
			scalar Hsq = Isq/(100-Isq)+1
			/*calculate ssq estimate*/
			qui gen double `temp1' = 1/effvar
			qui sum `temp1'
			scalar sum1 = r(sum)
			qui gen double `temp2' = (1/effvar)^2
			qui sum `temp2'
			scalar sum2 = r(sum)
			scalar ssq = (k-1)*sum1/(sum1^2-sum2)
			qui drop `temp1' `temp2'
			/*calculate the tau^2 estimate from input and ssq*/
			scalar tsq_sa = (Hsq)*ssq-ssq
			/*calculate Cochran's Qw - not reported under sensitivity analysis*/
			scalar qw = .
			/*DL model*/
			qui gen double `temp1' = eff/(effvar+tsq_sa)
			qui sum `temp1'
			scalar sum1 = r(sum)
			qui gen double `temp2' = 1/(effvar+tsq_sa)
			qui sum `temp2'
			scalar sum2 = r(sum)
			/*weights - to be used in display and graphs - different for each method*/
			qui capture drop weights
			qui gen weights = `temp2'/sum2
			/*mean & var estimates*/
			scalar sa_mu = sum1/sum2
			scalar sa_var = 1/sum2
			scalar sa_lo = sa_mu - `mltpl'*sqrt(sa_var)
			scalar sa_up = sa_mu + `mltpl'*sqrt(sa_var)
			qui drop `temp1' `temp2'
		}

		/**************************/
		/*Maximum Likelihood model*/
		/*calculate ML only if asked for (or if PL is asked) - since it takes time*/
		if "`ml'"!="" | "`pl'"!="" {
			/*initialise t^2 estimate*/
			scalar tsq_ml = max(tsq_dl, 1e-4)
			/*calculate initial mu_m (tau estimate)*/
			qui gen double `temp1' = eff/(effvar+tsq_ml)
			qui sum `temp1'
			scalar sum1 = r(sum)
			qui gen double `temp2' = 1/(effvar+tsq_ml)
			qui sum `temp2'
			scalar sum2 = r(sum)
			scalar mu_m = sum1/sum2
			qui drop `temp1' `temp2'
			/*dynamic system: we want it to converge to a fixed point - 500 iterations limit*/
			scalar nz=0
			scalar diff188_1 = 1
			scalar diff188_2 = 1
			/*continue with loop till both converge or we reach 500 iterations*/
			while (abs(diff188_1)>10^-6 | abs(diff188_2)>10^-6) & nz<500 {
				scalar nz = nz + 1
				/*calculate new tsq_ml (t^2 estimate)*/
				qui gen double `temp1' = ((eff-mu_m)^2-effvar)/(effvar+tsq_ml)^2
				qui sum `temp1'
				scalar sum1 = r(sum)
				qui gen double `temp2' = 1/(effvar+tsq_ml)^2
				qui sum `temp2'
				scalar sum2 = r(sum)
				/*calculate new mu_m (tau estimate)*/
				qui gen double `temp3' = eff/(effvar+tsq_ml)
				qui sum `temp3'
				scalar sum3 = r(sum)
				qui gen double `temp4' = 1/(effvar+tsq_ml)
				qui sum `temp4'
				scalar sum4 = r(sum)
				/*calc the differences*/
				scalar diff188_1 = tsq_ml - sum1/sum2
				scalar diff188_2 = mu_m - sum3/sum4
				/*calculate the new values*/
				scalar tsq_ml = sum1/sum2
				scalar mu_m = sum3/sum4
				qui drop `temp1' `temp2' `temp3' `temp4'
			}
			/*save the results to the appropriate variables - choose accordingly if the estimate is negative or not*/
			if tsq_ml>=0 {
				scalar ml_mu = mu_m
				qui gen double `temp1' = 1/(effvar+tsq_ml)
				qui sum `temp1'
				scalar ml_var = 1/r(sum)
				scalar sum2 = r(sum)
				/*weights - to be used in display and graphs - different for each method*/
				qui capture drop weights
				qui gen double weights = `temp1'/sum2
				qui drop `temp1'
				scalar ml_info=1
				/*if it has not converged update information*/
				if abs(diff188_1)>10^-6 | abs(diff188_2)>10^-6 {
					scalar ml_info = 0
					scalar ml_mu = .
					scalar ml_var = .
					scalar tsq_ml = .
					qui replace weights=.
				}
			}
			else {
				scalar ml_mu = fe_mu
				scalar ml_var = fe_var
				scalar tsq_ml = 0
				scalar ml_info = -1
			}
			/*confidence intervals*/
			scalar ml_lo = ml_mu - `mltpl'*sqrt(ml_var)
			scalar ml_up = ml_mu + `mltpl'*sqrt(ml_var)
			/*calculate the log-likelihood value*/
			qui gen double `temp1' = -1/2*ln(2*_pi*(effvar+tsq_ml))-1/2*(eff-ml_mu)^2/(effvar+tsq_ml)			
			qui sum `temp1'
			scalar ml_val = r(sum)
			qui drop `temp1'
		}

		/*calculate PL only if asked for and ML converged - since it takes time*/
		if "`pl'"!="" {
			if ml_info!=0 {
				/********************************************************************/
				/*Profile Likelihood method*/
				/*ML estimates from previous step - PL estimates are the same only the CI is different*/
				scalar pl_mu = ml_mu        /*mean effect*/
				scalar pl_var = ml_var      /*effect variance*/
				scalar tsq_pl = tsq_ml
				scalar Tm = tsq_ml          /*between study variance - only used in CI calculation*/
				/*main method calculations: CI for the effect estimate*/
				/*Lower bound calculations*/
				scalar Mmlo = pl_mu - 20 /*using SE wasn't efficient - many SEs close to 0*/
				/*binary search - stop if within 10^-6*/
				scalar st_0 = Mmlo
				scalar fin_0 =  pl_mu
				scalar diff188_ = 1
				scalar cntr = 0
				while (diff188_<0 | diff188_>10^-6) & cntr<500 {
					local tempxxx = (st_0+fin_0)/2
					scalar cntr = cntr + 1
					/*call program that calculates the ML value for fixed tau*/
					qui PL_value `tempxxx'
					scalar diff188_ = r(mlv) - ml_val + 1.92
					if diff188_<0 {         /*move upwards*/
						scalar st_0 = `tempxxx'
					}
					if diff188_>10^-6 {     /*move downwards*/
						scalar fin_0 = `tempxxx'
					}
				}
				scalar pl_lo = `tempxxx'
				/*if it hasn't converged update indicator*/
				scalar pl_lo_info = 1
				if cntr==500 {
					scalar pl_lo_info = 0
					scalar pl_lo = .
				}
				/*Upper bound calculations*/
				scalar Mmup = pl_mu + 20 /*using SE wasn't efficient - many SEs close to 0*/
				/*binary search - stop if within 10^-6*/
				scalar st_0 = pl_mu
				scalar fin_0 =  Mmup
				scalar diff188_ = 1
				scalar cntr = 0
				while (diff188_<0 | diff188_>10^-6) & cntr<500 {
					scalar cntr = cntr + 1
					local tempxxx = (st_0+fin_0)/2
					/*call program that calculates the ML value for fixed tau*/
					qui PL_value `tempxxx'
					scalar diff188_ = r(mlv) - ml_val + 1.92
					if diff188_>10^-6 {     /*move upwards*/
						scalar st_0 = `tempxxx'
					}
					if diff188_<0 {         /*move downwards*/
						scalar fin_0 = `tempxxx'
					}
				}
				scalar pl_up = `tempxxx'
				/*if it hasn't converged update indicator*/
				scalar pl_up_info = 1
				if cntr==500 {
					scalar pl_up_info = 0
					scalar pl_up = .
				}
				/*heterogeneity calculations: CI for the t^2 estimate*/
				/*Lower bound calculations*/
				scalar Tmlo = 0
				/*binary search - stop if within 10^-6*/
				scalar st_0 = Tmlo
				scalar fin_0 =  Tm
				scalar diff188_ = 1
				scalar cntr = 0
				while (diff188_<0 | diff188_>10^-6) & cntr<500 {
					local tempxxx = (st_0+fin_0)/2
					scalar cntr = cntr + 1
					/*call program that calculates the ML value for fixed t^2*/
					qui PL_value2 `tempxxx'
					scalar diff188_ = r(mlv) - ml_val + 1.92
					if diff188_<0 {         /*move upwards*/
						scalar st_0 = `tempxxx'
					}
					if diff188_>10^-6 {     /*move downwards*/
						scalar fin_0 = `tempxxx'
					}
				}
				/*take into account lower limit very very close to zero*/
				scalar tsq_pl_lo = `tempxxx'
				if `tempxxx' < 10^8 scalar tsq_pl_lo=0
				/*if it hasn't converged update indicator - but take into account values very close to zero*/
				scalar tsq_pl_lo_info = 1
				if cntr==500 & tsq_pl_lo!=0{
					scalar tsq_pl_lo_info = 0
					scalar tsq_pl_lo = .
				}
				/*Upper bound calculations*/
				scalar Tmup = Tm + 10
				/*binary search - stop if within 10^-6*/
				scalar st_0 = Tm
				scalar fin_0 =  Tmup
				scalar diff188_ = 1
				scalar cntr = 0
				while (diff188_<0 | diff188_>10^-6) & cntr<500{
					scalar cntr = cntr + 1
					local tempxxx = (st_0+fin_0)/2
					/*call program that calculates the ML value for fixed t^2*/
					qui PL_value2 `tempxxx'
					scalar diff188_ = r(mlv) - ml_val + 1.92
					if diff188_>10^-6 {     /*move upwards*/
						scalar st_0 = `tempxxx'
					}
					if diff188_<0 {         /*move downwards*/
						scalar fin_0 = `tempxxx'
					}
				}
				scalar tsq_pl_up = `tempxxx'
				scalar tsq_pl_up_info = 1
				/*if it hasn't converged update indicator*/
				if cntr==500 {
					scalar tsq_pl_up_info = 0
					scalar tsq_pl_up = .
				}
			}
			/*if ML has not converged then PL is not executed*/
			else {
				scalar pl_mu = .
				scalar pl_var = .
				scalar pl_lo_info = .
				scalar pl_lo = .
				scalar pl_up_info = .
				scalar pl_up = .
				scalar tsq_pl_lo_info = .
				scalar tsq_pl_lo = .
				scalar tsq_pl_up_info = .
				scalar tsq_pl_up = .
				scalar tsq_pl = .
			}
		}

		/**************************/
		/*Restricted Maximum Likelihood model*/
		/*calculate REML only if asked for - since it may take time*/
		if "`reml'"!="" {
			scalar tsq_reml = max(tsq_dl, 1e-4)
			/* estimate tau2 using ml */
			qui ml model d0 metaan_reml (eff effvar = ), maximize  init(_cons=`=tsq_reml') search(off) nopreserve noscvars /*
			*/ log iterate(100)
			scalar remlconvinfo = e(converged)
			scalar tsq_reml = max(_b[_cons],0)
			/*save the results to the appropriate variables - choose accordingly if the estimate is negative or not*/
			if tsq_reml>=0 {
				qui gen double `temp1' = eff/(effvar+tsq_reml)
				qui sum `temp1'
				scalar sum1 = r(sum)
				qui gen double `temp2' = 1/(effvar+tsq_reml)
				qui sum `temp2'
				scalar sum2 = r(sum)
				/*weights - to be used in display and graphs - different for each method*/
				qui capture drop weights
				qui gen double weights = `temp2'/sum2
				/*mean & var estimates*/
				scalar reml_mu = sum1/sum2
				scalar reml_var = 1/sum2
				qui drop `temp1' `temp2'
				scalar reml_info=1
				/*if it has not converged update information*/
				if remlconvinfo!=1 {
					scalar reml_info = 0
					scalar reml_mu = .
					scalar reml_var = .
					scalar tsq_reml = .
					/*qui replace weights=.*/
				}
			}
			else {
				scalar reml_mu = fe_mu
				scalar reml_var = fe_var
				scalar tsq_reml = 0
				scalar reml_info = -1
			}
			/*confidence intervals*/
			scalar reml_lo = reml_mu - `mltpl'*sqrt(reml_var)
			scalar reml_up = reml_mu + `mltpl'*sqrt(reml_var)
		}

		/*calculate PE only if asked for - since it takes time*/
		if "`pe'"!="" {
			/*Permutations method (Follmann, 1999)*/
			/*drop if there and re-generate*/
			scalar pe_pval=.
			scalar pe_mu = .
			scalar pe_var = .
			scalar pe_lo=.
			scalar pe_up=.
			/*the method does not work for k<6*/
			if k>=6 {
				/*create locals from scalars to manage calls...*/
				local tk = k
				local dlmu = dl_mu
				/*create appropriate permutation (or random) matrix in memory. for k<=10 use permutations; above that random (2^k rows)*/
				if k<=10 {
					mata: permtable = permmat(`tk')
				}
				else {
					mata: permtable = randmat(`tk',11)
				}
				/*get the number of rows of permtable to speed up code*/
				mata: rnum = rows(permtable)
				/*create an empty m table that will be fed into the main mata function*/
				mata: matempty = emptymat(rnum)
				/*call function that will return the variances and means in a matrix*/
				mata: varmu = createmat(`tk')
				/*call the mata function that does all the work and returns a CI matrix*/
				mata: pe_p(`tk',varmu,permtable,matempty,0,`dlmu',`mltps')
				/*convert the scalar returned to values in case i of pe_prob*/
				scalar pe_pval = r(pe_p)
				scalar pe_mu = dl_mu
				scalar pe_lo = r(pe_lo)
				scalar pe_up = r(pe_up)
				/*weights taken care of in DL*/
			}
		}

		/*select the method to be displayed and create appropriate strings*/	
		if "`fe'"!="" {
			local headoutstr = "Fixed-effect method selected"
			local modsel = "fe"
		}
		else if "`dl'"!="" {
			local headoutstr = "DerSimonian-Laird random-effects method selected"
			local modsel = "dl"
		}
		else if "`bdl'"!="" {
			local headoutstr = "Bootstrapped DerSimonian-Laird random-effects method selected"
			local modsel = "bdl"
		}
		else if "`ml'"!="" {
			local headoutstr = "Maximum Likelihood method selected"
			local modsel = "ml"
		}
		else if "`pl'"!="" {
			local headoutstr = "Profile Likelihood method selected"
			local modsel = "pl"
		}
		else if "`reml'"!="" {
			local headoutstr = "Restricted Maximum Likelihood (REML) method selected"
			local modsel = "reml"
		}
		else if "`pe'"!="" {
			local headoutstr = "Permutations method selected (Follmann & Proschan)"
			local modsel = "pe"
		}
		else if "`sa'"!="" {
			local headoutstr = "Sensitivity analysis selected with preset heterogeneity (I^2=`sens'%)"
			local modsel = "sa"
		}
		else if "`poe'"!="" {
			local headoutstr = "Peto fixed-effect for O-E data selected (log(HR) or log(OR))"
			local modsel = "poe"
		}		
		/*if MH/Peto used in conjuction with one of the above*/
		if "`mhor'"!="" {
			if `mdcnt'==0 {
				local headoutstr = "Mantel-Haenszel fixed-effect method (based on Odds-Ratio)"
				local modsel = "mh"		
			}
			else {
				local headoutstr = "`headoutstr' (MH Odds-Ratio)"
			}
		}		
		else if "`mhrr'"!="" {
			if `mdcnt'==0 {
				local headoutstr = "Mantel-Haenszel fixed-effect method (based on Risk-Ratio)"
				local modsel = "mh"		
			}
			else {
				local headoutstr = "`headoutstr' (MH Risk-Ratio)"
			}
		}				
		else if "`mhrd'"!="" {
			if `mdcnt'==0 {
				local headoutstr = "Mantel-Haenszel fixed-effect method (based on Risk-Difference)"
				local modsel = "mh"		
			}
			else {
				local headoutstr = "`headoutstr' (MH Risk-Difference)"
			}
		}
		else if "`por'"!="" {
			if `mdcnt'==0 {
				local headoutstr = "Peto Odds-Ratio (fixed-effect method)"
				local modsel = "peto"		
			}
			else {
				local headoutstr = "`headoutstr' (Peto Odds-Ratio)"
			}			
		}						

		/*information on methods - post texts*/
		/*Bootstrap DL on number of repetitions*/
		if "`modsel'"=="bdl" {
			local posttext1 = "bootstrap of `reps' repetitions"
			local ptxttype1 = "text"
		}
		/*ML information on conergence or not*/
		if "`modsel'"=="ml" | "`modsel'"=="pl" {
			if ml_info==1 {
				local posttext1 = "ML method succesfully converged"
				local ptxttype1 = "text"
			}
			else if ml_info==0 {
				local posttext1 = "Warning: ML convergence was not achieved after 500 iterations"
				local ptxttype1 = "error"
			}
			else if ml_info==-1 {
				local posttext1 = "Warning: tau^2 estimate using ML was negative and fixed-effect method estimates are used instead"
				local ptxttype1 = "error"
			}
		}
		/*PL information on conergence or not*/
		if "`modsel'"=="pl" {
			if ml_info==0 {
				local posttext2 = "PL method not executed since prerequisite ML method did not converge"
				local ptxttype2 = "error"
			}
			else {
				if pl_lo_info==1 & pl_up_info==1 {
					local posttext2 = "PL method succesfully converged for both upper and lower CI limits"
					local ptxttype2 = "text"
				}
				else {
					local posttext2 = "Warning: PL method did not converge for either the lower or upper CI limit of the overall effect, after 500 iterations"
					local ptxttype2 = "error"
				}
			}
		}
		/*REML information on conergence or not*/
		if "`modsel'"=="reml" {
			if reml_info==1 {
				local posttext3 = "REML method succesfully converged"
				local ptxttype3 = "text"
			}
			else if reml_info==0 {
				local posttext3 = "Warning: REML convergence was not achieved after 100 iterations"
				local ptxttype3 = "error"
			}
			else if reml_info==-1 {
				local posttext3 = "Warning: tau^2 estimate using REML was negative and fixed-effect method estimates are used instead"
				local ptxttype3 = "error"
			}
		}
		/*PE information: below or above 6*/
		if "`modsel'"=="pe" {
			if k>=6 {
				scalar execpe = 1
				local posttext4 = "PE method succesfully computed since the number of studies is 6 or above"
				local ptxttype4 = "text"
			}
			else {
				scalar execpe = 0
				local posttext4 = "Warning: PE method could not be computed since the number of studies is below 6"
				local ptxttype4 = "error"
			}
		}
		/*SA information - for Qw and below heterogeneity measures*/
		if "`modsel'"=="sa" {
			local posttext5 = "Cochrane's Q not reported under a sensitivity analysis"
			local ptxttype5 = "text"
		}
		//MH and Peto information
		if "`modsel'"=="mh" | "`modsel'"=="peto" {
			local posttext7 = "Heterogeneity measures reported under an inverse-variance weighting assumption"
			local ptxttype7 = "text"
		}		
		//if exponentiated
		if "`exp'"!="" {
			local posttext6 = "Effects have been exponentiated"
			local ptxttype6 = "text"
		}				

		//restore, not
		//error 110
		//back-transform here if meta-analysis of proportions
		if prpinfo==1 {
			/*overall effect*/
			scalar `modsel'_mu = (sin(`modsel'_mu/2))^2
			scalar `modsel'_lo = (sin(`modsel'_lo/2))^2
			scalar `modsel'_up = (sin(`modsel'_up/2))^2
			/*variable back-transform*/
			qui replace eff = (sin(eff/2))^2
			qui replace studyloCI = (sin(studyloCI/2))^2
			qui replace studyupCI = (sin(studyupCI/2))^2
		}
		//back-transform here if exponentiation requested with `exp' option
		if `btor'==1 {
			/*overall effect*/
			scalar `modsel'_mu = exp(`modsel'_mu)
			scalar `modsel'_lo = exp(`modsel'_lo)
			scalar `modsel'_up = exp(`modsel'_up)
			/*variable back-transform*/
			qui replace eff = exp(eff)
			qui replace studyloCI = exp(studyloCI)
			qui replace studyupCI = exp(studyupCI)
		}
		//back-transform from logit or empirical logit using
		if "`backt'"!="" {
			//unweighted or weighted "anchor" for overall effect
			if `btcntr'==1 {
				qui sum `btvar1'
			}
			else {
				qui sum `btvar1' [fweight=`btvar2']
			}
			/*overall effect - use the mean percentage to anchor*/
			scalar `modsel'_mu = 1/(exp(-`modsel'_mu)*(1-r(mean))/r(mean)+1)-r(mean)
			scalar `modsel'_lo = 1/(exp(-`modsel'_lo)*(1-r(mean))/r(mean)+1)-r(mean)
			scalar `modsel'_up = 1/(exp(-`modsel'_up)*(1-r(mean))/r(mean)+1)-r(mean)						
			//if only percentage provided => simple logit for study estimates (no zeros or ones allowed, checked earlier)
			if `btcntr'==1 {			
				/*variable back-transform*/
				qui replace eff = 1/(exp(-eff)*(1-`btvar1')/`btvar1'+1)-`btvar1'
				qui replace studyloCI = 1/(exp(-studyloCI)*(1-`btvar1')/`btvar1'+1)-`btvar1'
				qui replace studyupCI = 1/(exp(-studyupCI)*(1-`btvar1')/`btvar1'+1)-`btvar1'
			}
			//if denominators are provided => empirical logit for study estimates where zeros or ones available
			else {
				/*variable back-transform*/
				qui replace eff = 1/(exp(-eff)*(1-`btvar1')/`btvar1'+1)-`btvar1' if `btvar1'>0 & `btvar1'<1
				qui replace studyloCI = 1/(exp(-studyloCI)*(1-`btvar1')/`btvar1'+1)-`btvar1' if `btvar1'>0 & `btvar1'<1
				qui replace studyupCI = 1/(exp(-studyupCI)*(1-`btvar1')/`btvar1'+1)-`btvar1' if `btvar1'>0 & `btvar1'<1				
				qui replace eff = 1/(exp(-eff)*(1-`btvar1'+0.5/`btvar2')/(`btvar1'+0.5/`btvar2')+1)-`btvar1' if `btvar1'==0 | `btvar1'==1
				qui replace studyloCI = 1/(exp(-studyloCI)*(1-`btvar1'+0.5/`btvar2')/(`btvar1'+0.5/`btvar2')+1)-`btvar1' if `btvar1'==0 | `btvar1'==1
				qui replace studyupCI = 1/(exp(-studyupCI)*(1-`btvar1'+0.5/`btvar2')/(`btvar1'+0.5/`btvar2')+1)-`btvar1' if `btvar1'==0 | `btvar1'==1			
			}						
		}
		//if meta-analysis of proportions set to % for forest plot
		if "`pscl'"!="" {
			foreach x of varlist eff studyloCI studyupCI {
				qui replace `x'=`x'*100
			}
			foreach x in mu lo up {
				scalar `modsel'_`x'=`modsel'_`x'*100
			}
		}		
		
		if "`grpby'"=="" {
			di as text _newline(2) "`headoutstr'"
		}
		else {
			di as text "`headoutstr'"
		}
		di as text "{hline 21}{c TT}{hline 45}
		di as text "{col 9}Study{col 22}{c |}{col 26}Effect{col 35}[`clvl'% Conf. Interval]{col 57} % Weight"
		di as text "{hline 21}{c +}{hline 45}
		local stnum = k
		forvalues i=1(1)`stnum' {
			di as text %-20s labelvar[`i'] "{col 22}{c |}" as result _col(25) %7.3f eff[`i'] _col(36) %7.3f studyloCI[`i'] /*
			*/_col(46) %7.3f studyupCI[`i'] _col(57) %7.2f weights[`i']*100
		}
		di as text "{hline 21}{c +}{hline 45}
		qui sum weights
		scalar sumweights = 100*r(sum)
		di as text %-20s "Overall effect (`modsel'){col 22}{c |}" as result _col(25) %7.3f `modsel'_mu _col(36) %7.3f `modsel'_lo /*
		*/_col(46) %7.3f `modsel'_up _col(57) %7.2f sumweights
		di as text "{hline 21}{c BT}{hline 45}
		/*post texts*/
		if "`exp'"!="" {
			di as `ptxttype6' "`posttext6'"
		}				
		if "`modsel'"=="ml" | "`modsel'"=="pl" | "`modsel'"=="bdl" {
			di as `ptxttype1' "`posttext1'"
		}
		if "`modsel'"=="pl" {
			di as `ptxttype2' "`posttext2'"
		}
		if "`modsel'"=="reml" {
			di as `ptxttype3' "`posttext3'"
		}
		if "`modsel'"=="pe" {
			di as `ptxttype4' "`posttext4'"
		}

		/*calculate and display heterogeneity measures*/
		/*cochran's Q*/
		scalar qpval = 1-chi2(k-1,qw)
		/*t^2 estimate selection*/
		/*the default is DL but will change if ML,  PL or boot DL is selected*/
		scalar tausqx = tsq_dl
		local tsqmdl = "dl"
		if "`modsel'"=="bdl" {
			scalar tausqx = tsq_bdl
			local tsqmdl = "bdl"
		}
		else if "`modsel'"=="ml" {
			scalar tausqx = tsq_ml
			local tsqmdl = "ml"
		}
		else if "`modsel'"=="pl" {
			scalar tausqx = tsq_ml
			local tsqmdl = "ml"
			/*if pl is selected we will use t^2 CIs and convergence information*/
			if tsq_pl_lo_info==1 & tsq_pl_up_info==1 {
				local posttext5 = "PL method succesfully converged for both upper and lower CI limits of the tau^2 estimate"
				local ptxttype5 = "text"
			}
			else {
				local posttext5 = "Warning: PL method did not converge for either the lower or upper CI limit of the tau^2 estimate, after 500 iterations"
				local ptxttype5 = "error"
			}
		}
		else if "`modsel'"=="reml" {
			scalar tausqx = tsq_reml
			local tsqmdl = "reml"
		}
		else if "`modsel'"=="sa" {
			scalar tausqx = tsq_sa
			local tsqmdl = "sa"
		}
		/*I^2 and H^2 - from Higgins 2002 paper */
		/*scalar Hsq=(qw-(k-1))/(k-1)     relies on DL - not used*/
		scalar Hsq = ((tausqx + ssq)/ssq) /*this is H^2 as described by Mittlboeck*/
		if Hsq<1 scalar Hsq=1
		/*scalar Isq=100*(qw-(k-1))/qw   relies on DL method - not used*/
		scalar Isq = 100*(Hsq-1)/(Hsq)
		if Isq<0 scalar Isq=0
		//calculate CIs for H^2 and I^2 using the test-based confidence interval
		tempname Qart selnh1 selnh2 setouse Hsqlo Hsqup Isqlo Isqup
		scalar `Qart'=(Hsq)*(k-1)
		scalar `selnh1' = 0.5*(ln(`Qart')-ln(k-1))/(sqrt(2*`Qart')-sqrt(2*k-3))
		scalar `selnh2' = sqrt(1/(2*(k-2))*(1-1/(3*(k-2)^2)))
		scalar `setouse'=`selnh1'
		if `Qart'<k scalar `setouse'=`selnh2'
		scalar `Hsqlo' = max(exp((ln(sqrt(Hsq))-`mltpl'*`setouse'))^2,0)
		scalar `Hsqup' = exp((ln(sqrt(Hsq))+`mltpl'*`setouse'))^2
		scalar `Isqlo' = max(100*(`Hsqlo'-1)/(`Hsqlo'),0)
		scalar `Isqup' = min(100*(`Hsqup'-1)/(`Hsqup'),100)

		/*if forest selected and overall analysis - collect some needed data*/
		if ("`forest'"!="" | `forestw'!=-127.5) {
			local `modsel'_mu`xlp'=`modsel'_mu
			local `modsel'_lo`xlp'=`modsel'_lo
			local `modsel'_up`xlp'=`modsel'_up
			local tausqx`xlp'=tausqx
			local Isq`xlp'=Isq
			local k`xlp' = k
		}
		
		/*if forest selected and overall analysis - call forest plot*/
		if ("`forest'"!="" | `forestw'!=-127.5) & `xlp'==`numloop' {
			if `modsel'_mu==. | `modsel'_lo==. | `modsel'_up==. {
				di as error "Forest plot not produced since the model did not converge"
			}
			
			/*NEW FOREST PLOT*/
			//edits and options
			qui replace weights=weights*100
			tempvar rawdata tau2 df
			//linked to unused option COUNTS
			qui gen str1 `rawdata'=""
			//linked to unused option RFDIST
			qui gen `tau2'=.
			qui gen `df'=.
			//additional globals - post analyses
			global MA_method1 `=upper("`modsel'")'
			global MA_method2 "IV"
			/*add the overall effects as an extra observations if requested*/			
			if "`overall'"=="" {
				qui set obs `=k+`numloop'+2*(`numloop'-1)'
				forvalues sg=1(1)`numloop' {								
					qui replace eff = ``modsel'_mu`sg'' in `=k+`sg''
					qui replace studyloCI = ``modsel'_lo`sg'' in `=k+`sg''
					qui replace studyupCI = ``modsel'_up`sg'' in `=k+`sg''
					qui replace studyid = 0 in `=k+`sg''
					if `sg'<`numloop' {
						//results
						qui replace use=3 in `=k+`sg''
						qui sum weights if tgrpby==`sg'
						qui replace weights=r(sum) in `=k+`sg''						
						if "$MA_nohet" != "" {
							qui replace labelvar="Subtotal" in `=k+`sg''
						}
						else {
							qui replace labelvar="Subtotal  (I{superscript:2} = " + string(`Isq`sg'',"%5.1f") + "%)" in `=k+`sg''
						}		
						qui replace tgrpby=`sg' in `=k+`sg''
					}
					else {
						qui replace use=5 in `=k+`sg''
						qui replace weights=100 in `=k+`sg''						
						if "$MA_nohet" != "" {
							qui replace labelvar="Overall" in `=k+`sg''
						}
						else {
							qui replace labelvar="Overall  (I{superscript:2} = " + string(`Isq`sg'',"%5.1f") + "%)" in `=k+`sg''
						}						
					}
					qui replace `tau2' = `tausqx`sg'' in `=k+`sg''
					qui replace `df' = `k`sg'' in `=k+`sg''
				}
				//add labels and space
				forvalues sg=1(1)`=`numloop'-1' {								
					qui replace use=0 in `=k+`numloop'+2*`sg'-1'
					qui replace labelvar="`tfoo`sg''" in `=k+`numloop'+2*`sg'-1'
					qui replace tgrpby=`sg' in `=k+`numloop'+2*`sg'-1'
					qui replace use=36 in `=k+`numloop'+2*`sg''
					qui replace tgrpby=`sg' in `=k+`numloop'+2*`sg''
				}
				capture confirm variable tgrpby
				if _rc==0 {
					sort tgrpby use studyid					
				}
				else {
					sort use studyid									
				}
				qui replace use=0 if use==36
			}
			*restore, not
			*drop author outcome
			*list
			*error

			//if meta-analysis exponentiated tweak label if not set - not needed
			/*
			if `btor'==1 & "`xlabel'"=="" {
				qui sum studyupCI
				local tempup = ceil(r(max))
				if `tempup'<=2 {
					local xlabel "xlabel(0,1,2)"
				}
				else {
					local xlabel "xlabel(0,1,2,`tempup')"
				}
				local force="force"
			}*/			
		
			_dispgby eff studyloCI studyupCI weights use labelvar `rawdata' `tau2' `df', `log'    /*
			*/ `xlabel' `xtick' `force' sumstat(`sumstat') `saving' `box' t1("`t1'") /*
			*/ t2("`t2'")  b1("`b1'") b2("`b2'") lcols("`lcols'") rcols("`rcols'") `overall' `wt' `stats' `xcounts' `eform' /*
			*/ `groupla' `cornfield'	
		}
		/*if plplot is selected and overall analysis call*/
		if "`plplot'"!="" & `xlp'==`numloop' {
			if `modsel'_mu==. | tsq_`modsel'==. {
				di as error "Likelihood plot not produced since the model did not converge"
			}
			plplot `modsel'_mu tsq_`modsel' `plplotvar' `modsel' `btor'
		}

		/*more displays*/
		di as text _newline(2) "Heterogeneity Measures"
		/*cochran's Q*/
		di as text "{hline 15}{c TT}{hline 35}
		di as text "{col 16}{c |}{col 22}value{col 32}df{col 39}p-value"
		di as text "{hline 15}{c +}{hline 35}
		di as text %15s "Cochrane Q {col 16}{c |}" as result _col(20) %8.2f qw _col(29) %6.0f k-1 _col(38) %7.3f qpval
		di as text "{hline 15}{c BT}{hline 35}
		di _newline(1) as text "{hline 15}{c TT}{hline 35}
		di as text "{col 16}{c |}{col 22}value{col 32}[`clvl'% Conf. Interval]"
		di as text "{hline 15}{c +}{hline 35}
		di as text %15s "I^2(%) {col 16}{c |}" as result _col(20) %8.2f Isq _col(29) %8.2f `Isqlo' _col(38) %8.2f `Isqup'
		di as text %15s "H^2 {col 16}{c |}" as result _col(20) %8.2f Hsq _col(29) %8.2f `Hsqlo' _col(38) %8.2f `Hsqup'
		if "`modsel'"!="pl" {
			di as text %15s "tau^2(`tsqmdl') {col 16}{c |}" as result _col(20) %8.3f tausqx
		}
		di as text "{hline 15}{c BT}{hline 35}
		/*if PL model was selected display in different box since it has different fields (CI interval)*/
		if "`modsel'"=="pl" {
			di _newline(1) as text "{hline 15}{c TT}{hline 35}
			di as text "{col 16}{c |}{col 22}value{col 30}[`clvl'% Conf. Interval]"
			di as text "{hline 15}{c +}{hline 35}
			di as text %15s "tau^2 {col 16}{c |}" as result _col(20) %8.3f tausqx /*
			*/ _col(29) %8.3f tsq_pl_lo _col(38) %8.3f tsq_pl_up
			di as text "{hline 15}{c BT}{hline 35}
			if ml_info != 0 {
				di as text "Estimate obtained with Maximum likelihood - Profile likelihood provides the CI"
				di as `ptxttype5' "`posttext5'"
			}
		}
		else if "`modsel'"=="sa" {
			di as `ptxttype5' "`posttext5'"
		}
		if "`modsel'"=="mh" | "`modsel'"=="peto" {
			di as `ptxttype7' "`posttext7'"
		}	
		//if analysis by group report comparison across subgroups
		if "`grpby'"!="" & `xlp'==1 {
			scalar sumqw=0
		}
		if "`grpby'"!="" & `xlp'==`numloop' {
			scalar qdiff=qw-sumqw
			scalar qpdiff = 1-chi2(`numloop'-2,qdiff)
			scalar Hdiff=(qdiff-(`numloop'-2))/(`numloop'-2)	/*relies on DL*/
			if Hdiff<1 scalar Hdiff=1
			scalar Idiff = 100*(Hdiff-1)/(Hdiff)
			if Idiff<0 scalar Idiff=0		
			di as text "Test for subgroup differences: Chi^2=" %4.2f as res qdiff as text ", df=" %1.0f as res `=`numloop'-2' _continue
			di as text ", p-value=" as res %5.3f qpdiff as text ", H^2=" as res %4.2f Hdiff as text ", I^2=" as res %4.2f Idiff
		}
		//save qw in locals to be used for subgroup differences evaluation, if grpby() option used
		if "`grpby'"!="" {
			scalar qw`xlp'=qw
			scalar sumqw=sumqw+qw`xlp'
		}
	}
	
    /*return list - irrelevant to grpby option, will only return overall results*/
    /*universal*/
    return scalar eff = `modsel'_mu
    return scalar efflo = `modsel'_lo
    return scalar effup = `modsel'_up
    return scalar effvar = `modsel'_var
    return scalar Q = qw
    return scalar df = k-1
    return scalar Qpval = qpval
    return scalar Isq = Isq
    return scalar Isq_lo = `Isqlo'
    return scalar Isq_up = `Isqup'
	return scalar Hsq = Hsq
    return scalar Hsq_lo = `Hsqlo'
    return scalar Hsq_up = `Hsqup'
    return scalar tausq_dl = tsq_dl
    /*specific*/
    if "`bdl'"!="" {
        return scalar tausq_bdl = tsq_bdl
    }
    else if "`sa'"!="" {
        return scalar tausq_sa = tsq_sa
    }
    else if "`ml'"!="" {
        return scalar tausq_ml = tsq_ml
        return scalar conv_ml = ml_info
    }
    else if "`pl'"!="" {
        return scalar tausq_pl = tsq_ml
        return scalar tausqlo_pl = tsq_pl_lo
        return scalar tausqup_pl = tsq_pl_up
        return scalar conv_ml = ml_info
        return scalar cloeff_pl = pl_lo_info
        return scalar cupeff_pl = pl_up_info
        return scalar ctausqlo_pl = tsq_pl_lo_info
        return scalar ctausqup_pl = tsq_pl_up_info
    }
    else if "`reml'"!="" {
        return scalar tausq_reml = tsq_reml
        return scalar conv_reml = reml_info
    }
    else if "`pe'"!="" {
        return scalar exec_pe = execpe
    }
    /*un-comment to get lots of created variables you can toy with*/
    *restore, not
end

/*profile likelihood plot*/
program plplot
    preserve
    /*arguments*/
    scalar mu = `1'
    scalar tsq = `2'
    local plottype = "`3'"  /*mu or tsq*/
    local modsel = "`4'"
    if "`modsel'" == "reml" {
        local tstr "REML"
    }
    else {
        local tstr "ML/PL"
    }
	local expinf=`5'	
	if `expinf'==1 {
		scalar mu=ln(mu)
		local txtstr1=" (exponentiated)"
		local txtstr2=" (not exponentiated)"
		qui replace eff=ln(eff)
	}
	
    tempvar temp1
    /*loop to get 100 points around the parameter of interest: mu-1 to mu+1 or 0 to 2*tsq*/
    if "`plottype'"=="tsq" {
        /*bounds*/
        local lowerb = round(`=mu-1', 0.1)
        local upperb = round(`=mu+1', 0.1)
        local cntr=0
        forvalues i=`lowerb'(0.01)`upperb' {
            /*generate a counter so that we won't lose track!*/
            local cntr = `cntr'+1
            /*calculate the likelihood*/
            qui gen double `temp1' = -1/2*ln(2*_pi*(effvar+tsq))-1/2*(eff-`i')^2/(effvar+tsq)
            qui sum `temp1'
            scalar yval`cntr' = r(sum)
            scalar xval`cntr' = `i'
            qui drop `temp1'
        }
        local sttle "for tau^2 fixed to the `tstr' estimate"
        local xttle = "mu values`txtstr1'"
    }
    else {
        /*different number of decimals depending on tsq value*/
        scalar dlev = 0.1
        if tsq < 0.1 scalar dlev = 0.01
        /*bounds*/
        local lowerb = 0
        local upperb = round(max(`=2*tsq',0.1), dlev)
        local cntr=0
        forvalues i=`lowerb'(`=dlev/10')`upperb' {
            /*generate a counter so that we won't lose track!*/
            local cntr = `cntr'+1
            /*calculate the likelihood*/
            qui gen double `temp1' = -1/2*ln(2*_pi*(effvar+`i'))-1/2*(eff-mu)^2/(effvar+`i')
            qui sum `temp1'
            scalar yval`cntr' = r(sum)
            scalar xval`cntr' = `i'
            qui drop `temp1'
        }
        local sttle "for mu fixed to the `tstr' estimate`txtstr2'"
        local xttle = "tau^2 values"
    }
    local ttle = "Likelihood plot"
    local yttle = "log-likelihood"
    /*now generate X and Y variables to create the graph*/
    qui clear
    qui set obs `cntr'
    qui gen xvar=.
    qui gen yvar=.
    forvalues i=1(1)`cntr' {
        qui replace xvar=xval`i' in `i'
        qui replace yvar=yval`i' in `i'
    }
	//exponentiate only for the mu
	if `expinf'==1 & "`plottype'"=="tsq"{
		qui replace xvar=exp(xvar)
	}	
    /*the graph*/
    twoway mspline yvar xvar, lcolor(maroon) lwidth(medthick)  /*
    */ ylabel(, labsize(2) angle(0)) ytitle("`yttle'", size(small)) /*
    */ xlabel(, labsize(2.5) angle(0)) xtitle("`xttle'", size(small)) /*
    */ title("`ttle'", size("medsmall"))/*
    */ subtitle("`sttle'", size("small"))
end

/*Profile Likelihood extras*/
/*program that estimates t^2 with mu fixed for Profile Likelihood method (used in tau CI estimation)*/
program PL_value, rclass
    /*temporary variables*/
    tempvar temp1 temp2
    /*grab argument (the fixed mean) and assign*/
    local tempx = `1'
    scalar mu = `tempx'
    /*starting value for the t^2 estimate*/
    scalar t_sq_m = 0.001
    /*dynamic system: we want it to converge to a fixed point - 500 iterations limit*/
    scalar nx = 0
    scalar diff188_1 = 1
    /*continue with loop till t^2 estimate converges or we reach 500 iterations*/
    while abs(diff188_1)>10^-6 & nx<500 {
        scalar nx = nx + 1
        /*calculate the new t_sq_m (t^2 estimate)*/
        qui gen double `temp1' = ((eff-mu)^2-effvar)/(effvar+t_sq_m)^2
        qui sum `temp1'
        scalar sum1 = r(sum)
        qui gen double `temp2' = 1/(effvar+t_sq_m)^2
        qui sum `temp2'
        scalar sum2 = r(sum)
        qui drop `temp1' `temp2'
        /*calc the difference*/
        scalar diff188_1 = t_sq_m - sum1/sum2
        /*calculate the new value*/
        scalar t_sq_m = sum1/sum2
    }
    /*calculate the log-likelihood value*/
    qui gen double `temp1' = -1/2*ln(2*_pi*(effvar+t_sq_m))-1/2*(eff-mu)^2/(effvar+t_sq_m)
    qui sum `temp1'
	scalar mlval = r(sum)
    qui drop `temp1'
    /*return values to main program*/
    return scalar mlv = mlval
end
/*program that estimates mu with t^2 fixed for Profile Likelihood method (used in t^2 CI estimation)*/
program PL_value2, rclass
    /*temporary variables*/
    tempvar temp1 temp2
    /*grab argument (the fixed tau^2) and assign*/
    local tempx = `1'
    scalar t_sq_m = `tempx'
    /*starting value for the mu estimate*/
    scalar mu = 0
    /*dynamic system: we want it to converge to a fixed point - 500 iterations limit*/
    scalar nx = 0
    scalar diff188_1 = 1
    /*continue with loop till mu estimate converges or we reach 500 iterations*/
    while abs(diff188_1)>10^-6 & nx<500 {
        scalar nx = nx + 1
        /*calculate the new mu estimate*/
        qui gen double `temp1' = eff/(effvar+t_sq_m)
        qui sum `temp1'
        scalar sum1 = r(sum)
        qui gen double `temp2' = 1/(effvar+t_sq_m)
        qui sum `temp2'
        scalar sum2 = r(sum)
        qui drop `temp1' `temp2'
        /*calc the difference*/
        scalar diff188_1 = mu - sum1/sum2
        /*calculate the new value*/
        scalar mu = sum1/sum2
    }
    /*calculate the log-likelihood value*/
    qui gen double `temp1' = -1/2*ln(2*_pi*(effvar+t_sq_m))-1/2*(eff-mu)^2/(effvar+t_sq_m)
    qui sum `temp1'
	scalar mlval = r(sum)	
    qui drop `temp1'
    /*return values to main program*/
    return scalar mlv = mlval
end

/*Permutation method extras*/
mata:
mata clear
/*calculates all the permutations for n columns*/
real matrix permmat(real scalar n)
{
    real matrix A
    real matrix tempA
    real matrix permtable
    real matrix pos
    string matrix fin_0
    string matrix found
    /*first row of the matrix - all 1's*/
    tempA = 1
    A = 1
    for (i=1; i< n; i++) {
        A = (A,tempA)
    }
    /*up to this point created a line of n elements in A*/
    permtable = A

    pos = n
    fin_0 = "false"
    while (fin_0=="false") {
        A[1,pos] = -1
        /*make sure that when reversed at pos, all to the right (if any) are reset to 1*/
        for (temp=pos+1; temp<=n; temp++) {
            A[1,temp] = 1
        }
        /*reset the position to the end*/
        pos = n
        /*append the current permutation to the final table*/
        permtable = (permtable\A)
        /*check last element and change if it's 1*/
        if (A[1,n] == 1) {
            A[1,n] = -1
            permtable = (permtable\A)
        }
        /*find first 1 on the left and alter pos accordingly*/
        tpos = pos - 1
        found ="false"
        while (found=="false" & tpos>0) {
            if (A[1,tpos]==1) {
                found="true"
            }
            else {
                tpos = tpos - 1
            }
        }
        /*set new position*/
        pos = tpos
        if (pos==0) {
            fin_0 = "true"
        }
    }
    return(permtable)
}
/*creates random permutation table*/
real matrix randmat(real scalar n, real scalar k)
{
    real scalar r
    real matrix permtable
    /*create random table - perhaps in the future get time to change seed number based on time*/
    uniformseed(1976)
    r = 2^k
    permtable = uniform(r, n)
    /*round numbers since they are in the (0,1) range - get them to be either 1 or -1*/
    permtable = round(permtable)
    permtable = permtable:*2
    permtable = permtable:-1
    return(permtable)
}
/*creates and returns an 1XN empty matrix*/
real matrix emptymat(real scalar N)
{
    real matrix m
    m = 0
    for (i=2; i<= N; i++) {
        m = (m\0)
    }
    return(m)
}
/*creates and returns a 2XN matrix with values for the meta-analysis*/
real matrix createmat(real scalar N)
{
    real matrix A
    real scalar temp, cntr, i
    /*create first row*/
    A = .
    for (i=2; i<= N; i++) {
        A = (A,.)
    }
    /*double up, for second row*/
    A = (A\A)
    /*fill up with effect sizes and variances data*/
    i=0
    cntr = 0
    while (i<N) {
        cntr = cntr + 1
        temp = st_data(cntr,"use")
        /*if study is supposed to be used then grab data and increment counter*/
        if (temp==1) {
            i = i + 1
            A[1,i] = st_data(cntr,"effvar")  /*variances in 1st row*/
            A[2,i] = st_data(cntr,"eff")     /*means in 2nd row*/
        }
    }
    return(A)
}
/*returns the probability, upperCI and lowerCI in a 1X2 matrix*/
void pe_p(real scalar k, real matrix varmu, real matrix permtable, real matrix m,real scalar mu, real scalar re_mu, real scalar mltps)
{
    real matrix means
    real matrix Xperm
    real matrix var
    real matrix Xtemp
    real matrix utemp
    real matrix btemp
    real matrix permtemp
    real matrix b
    real matrix cp
    real matrix cptemp
    real scalar numrows
    real scalar posx
    real scalar probab
    real scalar pe_lo
    real scalar pe_up
    real matrix prcpu
    real matrix prcpl
    real matrix prcpt1
    real matrix prcpt2
    /*create the Xp table from tables permtable & the second line of varmu*/
    means = abs(varmu[2,.]:-mu)
    re_mu = re_mu-mu
    Xperm = permtable:*means
    /*grab the variances too*/
    var = varmu[1,.]
    /*find number of rows*/
    numrows = rows(Xperm)
    /*initialise the matrices that we will edit cell by cell*/
    b = m:*0
    cp = m:*0
    prcpu = m:*0
    prcpl = m:*0
    /*grab each row and calculate the tau prediction for it - same dimensions as matrix m*/
    for (i=1; i<= numrows; i++) {
        Xtemp = Xperm[i,.]
        /*calculate Sum(u(i))*/
        utemp = 1:/var
        su1 = sum(utemp)
        /*calculate Sum(u(i)^2)*/
        utemp = 1:/(var:*var)
        su2 = sum(utemp)
        /*calculate Sum(u(i)*X(i))*/
        utemp = (Xtemp:*(1:/var)):/su1
        m0 = sum(utemp)
        /*calculate Sum{u(i)*(X(i)-m0)^2}*/
        utemp = (1:/var):*((Xtemp:-m0):^2)
        anum = sum(utemp)
        /*calculate t_square estimate*/
        t_sq = (anum-(k-1))/(su1-su2/su1)
        if (t_sq<0) {
            t_sq = 0
        }
        /*calculate m prediction for case i*/
        /*calculate SUM(1/(t^2+varj))*/
        utemp = 1:/(var:+t_sq)
        tempS = sum(utemp)
        utemp = ((1:/(var:+t_sq)):/tempS):*Xtemp
        m[i] = sum(utemp)
        /*needed for CI calculation*/
        permtemp = permtable[i,.]
        btemp = ((1:/(var:+t_sq)):/tempS):*permtemp
        tempS = sum(btemp)
        b[i] = tempS
        tempS = (re_mu-m[i])/(1-b[i])
        cp[i] = tempS
    }
    //Wolfgang
    //permtable
    //cp
    /*more needed for the CI calculation*/
    for (i=1; i<= numrows; i++) {
        /*trying to count how many permutations satisfy mu-mu(p)>=c(1-b(p)). sqrt will set negatives to missing*/
        cptemp = sqrt(cp:-cp[i]):+1
        cptemp = round(cptemp:/cptemp)
        tempS = sum(cptemp)/numrows
        prcpu[i] = tempS
        /*trying to count how many permutations satisfy mu-mu(p)<=c(1-b(p)).*/
        cptemp = sqrt(-cp:+cp[i]):+1
        cptemp = round(cptemp:/cptemp)
        tempS = sum(cptemp)/numrows
        prcpl[i] = tempS
    }
    //prcpu
    //prcpl
    /*find the smallest cp(i) for which prcpu(i)<=0.025 - upper CI*/
    prcpt1 = sqrt(mltps:-prcpu):+1
    prcpt2 = round(prcpt1:/prcpt1)
    cptemp = prcpt2:*cp
    pe_up = min(cptemp)
    /*find the largest cp(i) for which prcpl(i)<=0.025 - lower CI*/
    prcpt1 = sqrt(mltps:-prcpl):+1
    prcpt2 = round(prcpt1:/prcpt1)
    cptemp = prcpt2:*cp
    pe_lo = max(cptemp)
    //prcpl
    //prcpt1
    //prcpt2
    //cptemp
    /*BACK TO P value - sort the table*/
    _sort(m,1)
    /*call binary search to find the position*/
    posx = bsearch(re_mu, m)
    /*now from the position calculate probability*/
    if (posx>numrows/2) { /*if the position in the lower half of the table...*/
        probab = 2*(numrows-posx+1)/numrows
    }
    else { /*if the position in the upper half of the table...*/
        probab = 2*posx/numrows
    }
    st_numscalar("r(pe_p)",probab)
    st_numscalar("r(pe_lo)",pe_lo)
    st_numscalar("r(pe_up)",pe_up)
}
/*binary search*/
real scalar bsearch(real scalar sval, real matrix A)
{
    real scalar stpos
    real scalar endpos
    real scalar k
    real scalar found
    real scalar minsofar
    real scalar temp
    /*iniitalise start & end position*/
    stpos = 1
    endpos = rows(A)
    found = 0 /*not found yet*/
    /*main binary search loop*/
    while (stpos<=endpos & found==0) {
        k = trunc((stpos+endpos)/2)
        if (abs(A[k]-sval)<10^-8) {
            found=1
        }
        else {
            if (sval<A[k]) {
                endpos = k - 1
            }
            else {
                stpos = k + 1
            }
        }
    }
    /*if it is not found, i.e. if re_mu was not included in the random matrix (for k>10)
    we need to look for the closest value*/
    if (found==0) {
        /*look if A[k+1]is closer to re_mu(sval) than A[k]*/
        minsofar = abs(A[k]-sval)
        temp = k
        if (temp<rows(A)){
            if (abs(A[temp+1]-sval)<minsofar) {
                minsofar = abs(A[temp+1]-sval)
                k = temp + 1
            }
        }
        if (temp>1){
            if (abs(A[temp-1]-sval)<minsofar) {
                minsofar = abs(A[temp-1]-sval)
                k = temp - 1
            }
        }
    }
    return(k)
}
end

/*Mantel-Haenszel Odds-ratio fixed-effect method*/
program calc_MHORf, rclass
	//not needed but remnant from older code
	local i=127
	//CI level
	local clvl=c(level)
	local mltpl=invnormal(1-(100-`clvl')/200)
	//temp variables
    tempvar a`i' b`i' c`i' d`i' N`i' OR`i' varOR`i' w`i'
    /*only use OR, effmeas= 1 or 2(reversed)*/
	qui gen `a`i'' = .
	qui gen `b`i'' = .
	qui gen `c`i'' = .
	qui gen `d`i'' = .
	/*events and non events*/
	qui replace `a`i'' = ev1_`i'
	qui replace `b`i'' = total1_`i'-ev1_`i'
	qui replace `c`i'' = ev2_`i'
	qui replace `d`i'' = total2_`i'-ev2_`i'	
	/*correction for zero cells*/
	foreach x in a b c d {
		qui replace ``x'`i''=``x'`i''+0.5 if `a`i''<1 | `c`i''<1 | `b`i''<1 | `d`i''<1
	}
	qui gen `N`i'' = `a`i''+`b`i''+`c`i''+`d`i''
	/*but if there are too many that are zero, set all to zero*/
	foreach x in a b c d {
		qui replace ``x'`i''=0 if (`a`i''<1 & `c`i''<1) | (`b`i''<1 & `d`i''<1)
	}
	/*more calculations*/
	qui gen double `OR`i'' = (`a`i''*`d`i'')/(`b`i''*`c`i'')
	qui gen double `varOR`i'' = (1/`a`i''+1/`d`i''+1/`b`i''+1/`c`i'')
	qui gen double `w`i'' = (`b`i''*`c`i'')/`N`i''
	/*if one of the cells is still zero set the numerators in the sums to zero to avoid problems*/
	qui replace `w`i''=1 if (`a`i''<1 & `c`i''<1) | (`b`i''<1 & `d`i''<1)
	qui replace `N`i''=1 if (`a`i''<1 & `c`i''<1) | (`b`i''<1 & `d`i''<1)
	qui replace `OR`i''=0 if (`a`i''<1 & `c`i''<1) | (`b`i''<1 & `d`i''<1)
	qui replace `varOR`i''=1 if (`a`i''<1 & `c`i''<1) | (`b`i''<1 & `d`i''<1)

	//intermediate variables
    tempvar temp1 temp2 vE vF vG vH vR vS
    qui gen double `temp1' = `w`i''*`OR`i''
    qui gen double `temp2' = `w`i''
    qui gen double `vR' = (`a`i''*`d`i'')/`N`i''
    qui gen double `vS' = (`b`i''*`c`i'')/`N`i''
    qui gen double `vE' = ((`a`i''+`d`i'')*`a`i''*`d`i'')/(`N`i''^2)
    qui gen double `vF' = ((`a`i''+`d`i'')*`b`i''*`c`i'')/(`N`i''^2)
    qui gen double `vG' = ((`b`i''+`c`i'')*`a`i''*`d`i'')/(`N`i''^2)
    qui gen double `vH' = ((`b`i''+`c`i'')*`b`i''*`c`i'')/(`N`i''^2)	
	foreach x in temp1 temp2 vE vF vG vH vR vS {
		qui sum ``x''
		local l`x'=r(sum)
	}

    /*mean estimate (coefficient)*/
    local MHf_mu = ln(`ltemp1'/`ltemp2')
    /*variance estimate*/
    local MHf_var =0.5*(`lvE'/(`lvR'^2) + (`lvF'+`lvG')/(`lvR'*`lvS') + `lvH'/(`lvS'^2))
    local MHf_lo = `MHf_mu'-`mltpl'*sqrt(`MHf_var')
    local MHf_up = `MHf_mu'+`mltpl'*sqrt(`MHf_var')
    /*scalars*/
    foreach x in mu var lo up {
		scalar `x'=`MHf_`x''
    }
	
	//create study variables only when requested to do so
	if "`1'"=="gen" {
		capture drop eff effvar weights
		gen double eff=ln(`OR`i'')
		gen double effvar=`varOR`i''		
		qui sum `w`i''
		gen double weights=`w`i''/r(sum)
	}	
    /*return overall to main program*/
	foreach x in mu var lo up {	
		return scalar `x'=`x'
	}	
end

/*Mantel-Haenszel Risk-ratio fixed-effect method*/
program calc_MHRRf, rclass
	//not needed but remnant from older code
	local i=127
	//CI level
	local clvl=c(level)
	local mltpl=invnormal(1-(100-`clvl')/200)
	//temp variables
    tempvar a`i' b`i' c`i' d`i' N`i' RR`i' varRR`i' w`i'
    /*only use OR, effmeas= 1 or 2(reversed)*/
	qui gen `a`i'' = .
	qui gen `b`i'' = .
	qui gen `c`i'' = .
	qui gen `d`i'' = .
	/*events and non events*/
	qui replace `a`i'' = ev1_`i'
	qui replace `b`i'' = total1_`i'-ev1_`i'
	qui replace `c`i'' = ev2_`i'
	qui replace `d`i'' = total2_`i'-ev2_`i'	
	/*correction for zero cells*/
	foreach x in a b c d {
		qui replace ``x'`i''=``x'`i''+0.5 if `a`i''<1 | `c`i''<1 | `b`i''<1 | `d`i''<1
	}
	qui gen `N`i'' = `a`i''+`b`i''+`c`i''+`d`i''
	/*but if there are too many that are zero, set all to zero*/
	foreach x in a b c d {
		qui replace ``x'`i''=0 if (`a`i''<1 & `c`i''<1) | (`b`i''<1 & `d`i''<1)
	}
	/*more calculations*/
	qui gen double `RR`i'' = (`a`i''/(`a`i''+`b`i''))/(`c`i''/(`c`i''+`d`i''))
	qui gen double `varRR`i'' = (1/`a`i'' + 1/`c`i'' - 1/(`a`i''+`b`i'') - 1/(`c`i''+`d`i''))
	qui gen double `w`i'' = `c`i''*(`a`i''+`b`i'')/`N`i''
	/*if one of the cells is still zero set the numerators in the sums to zero to avoid problems*/
	qui replace `w`i''=1 if (`a`i''<1 & `c`i''<1) | (`b`i''<1 & `d`i''<1)
	qui replace `N`i''=1 if (`a`i''<1 & `c`i''<1) | (`b`i''<1 & `d`i''<1)
	qui replace `RR`i''=0 if (`a`i''<1 & `c`i''<1) | (`b`i''<1 & `d`i''<1)
	qui replace `varRR`i''=1 if (`a`i''<1 & `c`i''<1) | (`b`i''<1 & `d`i''<1)	
	//intermediate variables
    tempvar temp1 temp2 vP vR vS
    qui gen double `temp1' = `w`i''*`RR`i''
    qui gen double `temp2' = `w`i''
    qui gen double `vP' = ((`a`i''+`b`i'')*(`c`i''+`d`i'')*(`a`i''+`c`i'') - `a`i''*`c`i''*`N`i'')/(`N`i''^2)
    qui gen double `vR' = (`a`i''*(`c`i''+`d`i''))/`N`i''
    qui gen double `vS' = (`c`i''*(`a`i''+`b`i''))/`N`i''
	foreach x in temp1 temp2 vP vR vS {
		qui sum ``x''
		local l`x'=r(sum)
	}

    /*mean estimate (coefficient)*/
    local MHf_mu = ln(`ltemp1'/`ltemp2')
    /*variance estimate*/
    local MHf_var =(`lvP'/(`lvR'*`lvS'))
    local MHf_lo = `MHf_mu'-`mltpl'*sqrt(`MHf_var')
    local MHf_up = `MHf_mu'+`mltpl'*sqrt(`MHf_var')
    /*scalars*/
    foreach x in mu var lo up {
		scalar `x'=`MHf_`x''
    }
	
	//create study variables only when requested to do so
	if "`1'"=="gen" {
		capture drop eff effvar weights
		gen double eff=ln(`RR`i'')
		gen double effvar=`varRR`i''		
		qui sum `w`i''
		gen double weights=`w`i''/r(sum)
	}
    /*return overall to main program*/
	foreach x in mu var lo up {	
		return scalar `x'=`x'
	}	
end

//METHODS FOR 4 VARIABLE SYNTAX: EVENTS AND POPULATIONS
/*Mantel-Haenszel Risk difference fixed-effect method*/
program calc_MHRDf, rclass
	//not needed but remnant from older code
	local i=127
	//CI level
	local clvl=c(level)
	local mltpl=invnormal(1-(100-`clvl')/200)
	//temp variables
    tempvar a`i' b`i' c`i' d`i' N`i' RD`i' varRD`i' w`i'
    /*only use OR, effmeas= 1 or 2(reversed)*/
	qui gen `a`i'' = .
	qui gen `b`i'' = .
	qui gen `c`i'' = .
	qui gen `d`i'' = .
	/*events and non events*/
	qui replace `a`i'' = ev1_`i'
	qui replace `b`i'' = total1_`i'-ev1_`i'
	qui replace `c`i'' = ev2_`i'
	qui replace `d`i'' = total2_`i'-ev2_`i'	
	/*correction for zero cells*/
	foreach x in a b c d {
		/*`a`i''<1 | `c`i''<1 | `b`i''<1 | `d`i''<1*/
		qui replace ``x'`i''=``x'`i''+0.5 if (`a`i''<1 & `c`i''<1) | (`a`i''<1 & `d`i''<1) | (`b`i''<1 & `c`i''<1) | (`b`i''<1 & `d`i''<1)
	}
	qui gen `N`i'' = `a`i''+`b`i''+`c`i''+`d`i''
	/*more calculations*/
	qui gen double `RD`i'' = (`a`i''/(`a`i''+`b`i'')) - (`c`i''/(`c`i''+`d`i''))
	qui gen double `varRD`i'' = (`a`i''*`b`i'')/((`a`i''+`b`i'')^3) + (`c`i''*`d`i'')/((`c`i''+`d`i'')^3)
	qui gen double `w`i'' = ((`a`i''+`b`i'')*(`c`i''+`d`i''))/`N`i''		
	//intermediate variables
    tempvar temp1 temp2 vJ vK
    qui gen double `temp1' = `w`i''*`RD`i''
    qui gen double `temp2' = `w`i''
    qui gen double `vJ' = (`a`i''*`b`i''*((`c`i''+`d`i'')^3)+`c`i''*`d`i''*((`a`i''+`b`i'')^3))/((`a`i''+`b`i'')*(`c`i''+`d`i'')*(`N`i''^2))
    qui gen double `vK' = ((`a`i''+`b`i'')*(`c`i''+`d`i''))/`N`i''
	foreach x in temp1 temp2 vJ vK {
		qui sum ``x''
		local l`x'=r(sum)
	}
    /*mean estimate*/
    local MHf_mu = (`ltemp1'/`ltemp2')
    /*variance estimate*/
	local MHf_var =(`lvJ'/(`lvK'^2))
    local MHf_lo = `MHf_mu'-`mltpl'*sqrt(`MHf_var')
    local MHf_up = `MHf_mu'+`mltpl'*sqrt(`MHf_var')
    /*scalars*/
    foreach x in mu var lo up {
		scalar `x'=`MHf_`x''
    }
	//create study variables only when requested to do so
	if "`1'"=="gen" {
		capture drop eff effvar weights
		gen double eff=(`RD`i'')
		gen double effvar=`varRD`i''		
		qui sum `w`i''
		gen double weights=`w`i''/r(sum)
	}
    /*return overall to main program*/
	foreach x in mu var lo up {	
		return scalar `x'=`x'
	}	
end

/*Peto Odds-ratio fixed-effect method*/
program calc_PORf, rclass
	//not needed but remnant from older code
	local i=127
	//CI level
	local clvl=c(level)
	local mltpl=invnormal(1-(100-`clvl')/200)
	//temp variables
	tempvar a`i' b`i' c`i' d`i' N`i' OR`i' varOR`i' Z`i' V`i'
	//if effect already there don't calculate
	if "`2'"!="effex" {
		/*only use OR, effmeas= 1 or 2(reversed)*/
		qui gen `a`i'' = .
		qui gen `b`i'' = .
		qui gen `c`i'' = .
		qui gen `d`i'' = .
		/*events and non events*/
		qui replace `a`i'' = ev1_`i'
		qui replace `b`i'' = total1_`i'-ev1_`i'
		qui replace `c`i'' = ev2_`i'
		qui replace `d`i'' = total2_`i'-ev2_`i'	
		
		/*correction for zero cells*/
		foreach x in a b c d {
			*qui replace ``x'`i''=``x'`i''+0.5 if `a`i''<1 | `c`i''<1 | `b`i''<1 | `d`i''<1
		}
		qui gen `N`i'' = `a`i''+`b`i''+`c`i''+`d`i''
		/*but if there are too many that are zero, set all to zero*/
		foreach x in a b c d {
			*qui replace ``x'`i''=0 if (`a`i''<1 & `c`i''<1) | (`b`i''<1 & `d`i''<1)
		}
		/*more calculations*/
		qui gen double `Z`i'' = `a`i'' - (`a`i''+`b`i'')*(`a`i''+`c`i'')/`N`i''
		qui gen double `V`i'' = (`a`i''+`b`i'')*(`c`i''+`d`i'')*(`a`i''+`c`i'')*(`b`i''+`d`i'')/(`N`i''^2*(`N`i''-1))
		qui gen double `OR`i'' = exp(`Z`i''/`V`i'')
		qui gen double `varOR`i'' = 1/`V`i''
		/*can't have any problems with zero cells: only when a=c=b=d=0 which is impossible*/
	}
	else {
		qui gen double `V`i'' = 1/effvar
		qui gen double `OR`i'' = exp(eff)
		qui gen double `varOR`i'' = 1/`V`i''		
	}
	
	//intermediate variables
    tempvar temp1 temp2
    qui gen double `temp1' = `V`i''*ln(`OR`i'')
    qui gen double `temp2' = `V`i''	
	foreach x in temp1 temp2 {
		qui sum ``x''
		local l`x'=r(sum)
	}
    /*mean estimate (coefficients)*/
    local Pf_mu = (`ltemp1'/`ltemp2')
    /*variance estimate*/
    local Pf_var = 1/`ltemp2'
    local Pf_lo = `Pf_mu' - `mltpl'*sqrt(`Pf_var')
    local Pf_up = `Pf_mu' + `mltpl'*sqrt(`Pf_var')

    /*scalars*/
    foreach x in mu var lo up {
		scalar `x'=`Pf_`x''
    }
	
	//create study variables only when requested to do so
	if "`1'"=="gen" {
		capture drop eff effvar
		gen double eff=ln(`OR`i'')
		gen double effvar=`varOR`i''
	}
	if "`1'"=="gen" | "`1'"=="partgen" {	
		capture drop weights		
		qui sum `V`i''
		gen double weights=`V`i''/r(sum)
	}	
    /*return overall to main program*/
	foreach x in mu var lo up {	
		return scalar `x'=`x'
	}	
end

**********************************************************
***                                                    ***
***                        NEW                         ***
***                 _DISPGBY PROGRAM                   ***
***                    ROSS HARRIS                     ***
***                     JULY 2006                      ***
***                       * * *                        ***
***                                                    ***
**********************************************************
//"appropriated" with many thanks
program define _dispgby
version 9.0	

//	AXmin AXmax ARE THE OVERALL LEFT AND RIGHT COORDS
//	DXmin dxMAX ARE THE LEFT AND RIGHT COORDS OF THE GRAPH PART

#delimit ;
syntax varlist(min=6 max=10 default=none ) [if] [in] [,
  LOG XLAbel(string) XTICK(string) FORCE SAVING(string) noBOX SUMSTAT(string) 
  T1(string) T2(string) B1(string) B2(string) LCOLS(string) /* JUNK NOW */
  RCOLS(string) noOVERALL noWT noSTATS COUNTS EFORM 
  noGROUPLA CORNFIELD];
#delimit cr
tempvar effect lci uci weight wtdisp use label tlabel id yrange xrange Ghsqrwt rawdata i2 mylabel
tokenize "`varlist'", parse(" ")

qui{

gen `effect'=`1'
gen `lci'   =`2'

gen `uci'   =`3'
gen `weight'=`4'	// was 4
gen byte `use'=`5'
gen str `label'=`6'
gen str `mylabel'=`6'

if "`lcols'" == ""{
	local lcols "`mylabel'"
	label var `mylabel' "Study ID"
}

gen str80 `rawdata' = `7'
compress `rawdata'

if "`8'"!="" & "$MA_rjhby" != ""{
	*gen `wtdisp'=`8' 
	gen `wtdisp'=`weight' 
}
else { 
	gen `wtdisp'=`weight' 
}

*if "`10'" != "" & "$MA_rjhby" != ""{
if "$MA_rjhby" != ""{
	tempvar tau2 df
	gen `tau2' = `8'
	gen `df' = `9'
}
if "`9'" != "" & "$MA_rjhby" == ""{	// DIFFERENT IF FROM metan OR metanby
	tempvar tau2 df
	gen `tau2' = `8'
	gen `df' = `9'
}
replace `weight' = `wtdisp'	// bodge solu for SG weights

if "$MA_summaryonly" != ""{
	drop if `use' == 1
}

// SET UP EXTENDED CIs FOR RANDOM EFFECTS DISTRIBUTION
// THIS CODE IS A BIT NASTY AS I SET THIS UP BADLY INITIALLY
// REQUIRES MAJOR REWORK IDEALLY...

tempvar tauLCI tauUCI SE tauLCIinf tauUCIinf
*replace `tau2' = .a if `tau2' == 0	// no heterogeneity
replace `tau2' = .b if `df'-1 == 0	// inestimable predictive distribution
//replace `tau2' = . if (`use' == 5 | `use' == 3) & "$MA_method1" != "D+L"
//replace `tau2' = . if (`use' == 17 | `use' == 19) & "$MA_method2" != "D+L"
replace `tau2' = . if (`use' == 5 | `use' == 3) & "$MA_method1" == "FE"
replace `tau2' = . if (`use' == 17 | `use' == 19) & "$MA_method2" == "FE"


gen `tauLCI' = .
gen `tauUCI' = .
gen `tauLCIinf' = .
gen `tauUCIinf' = .
gen `SE' = .


// modified so rf CI (rflevel) used
if "$MA_rfdist" != ""{
	if ( ("`sumstat'"=="OR" | "`sumstat'"=="RR" | "`sumstat'"=="HR") & ("`log'"=="") ) | ("`eform'"!="") {
		replace `SE' = (ln(`uci')-ln(`lci')) / (invnorm($RFL/200+0.5)*2)
		replace `tauLCI' = exp( ln(`effect') - invttail((`df'-1), 0.5-$RFL/200)*sqrt( `tau2' +`SE'^2 ) )
		replace `tauUCI' = exp( ln(`effect') + invttail((`df'-1), 0.5-$RFL/200)*sqrt( `tau2' +`SE'^2 ) )
		replace `tauLCI' = 1e-9 if `tau2' == .b
		replace `tauUCI' = 1e9 if `tau2' == .b 
	}
	else{
		replace `SE' = (`uci'-`lci') / (invnorm($RFL/200+0.5)*2)
		replace `tauLCI' = `effect'-invttail((`df'-1), 0.5-$RFL/200)*sqrt(`tau2'+`SE'^2)
		replace `tauUCI' = `effect'+invttail((`df'-1), 0.5-$RFL/200)*sqrt(`tau2'+`SE'^2)
		replace `tauLCI' = -1e9 if `tau2' == .b
		replace `tauUCI' = 1e9 if `tau2' == .b
	}
}


if "$MA_rfdist" != ""{
	qui count
	local prevN = r(N)
	tempvar expTau orderTau
	gen `orderTau' = _n
	gen `expTau' = 1
	replace `expTau' = 2 if `tau2' != .	// but expand if .a or .b
	expand `expTau'
	replace `use' = 4 if _n > `prevN'
	replace `orderTau' = `orderTau' + 0.5 if _n > `prevN'
	sort `orderTau'
}

tempvar estText weightText RFdistText RFdistLabel
local dp = $MA_dp
gen str `estText' = string(`effect', "%10.`dp'f") + " (" + string(`lci', "%10.`dp'f") + ", " +string(`uci', "%10.`dp'f") + ")"
replace `estText' = "(Excluded)" if `use' == 2

// don't show effect size again, just CI
gen `RFdistLabel' = "with estimated predictive interval" if `use' == 4 & `tau2' < .
gen `RFdistText' = /* string(`effect', "%10.`dp'f") + */ ".       (" + string(`tauLCI', "%10.`dp'f") + ", " +string(`tauUCI', "%10.`dp'f") ///
	+ ")" if `use' == 4 & `tau2' < .

/* not used
replace `RFdistLabel' = "No observed heterogeneity" if `use' == 4 & `tau2' == .a
replace `RFdistText' = string(`effect', "%10.`dp'f") + " (" + string(`lci', "%10.`dp'f") + ", " +string(`uci', "%10.`dp'f") ///
	+ ")" if `use' == 4 & `tau2' == .a
*/

// don't show effect size again, just CI
replace `RFdistLabel' = "Inestimable predictive distribution with <3 studies"  if `use' == 4 & `tau2' == .b
replace `RFdistText' = /* string(`effect', "%4.2f") + */ ".       (  -  ,  -  )" if `use' == 4 & `tau2' == .b


qui replace `estText' = " " +  `estText' if `effect' >= 0 & `use' != 4
gen str `weightText' = string(`weight', "%4.2f")

replace `weightText' = "" if `use' == 17 | `use' == 19 // can cause confusion and not necessary
replace `rawdata' = "" if `use' == 17 | `use' == 19 

if "`counts'" != ""{
	if $MA_params == 6{
		local type "N, mean (SD);"
	}
	else{
		local type "Events,"
	}
	tempvar raw1 raw2
	gen str `raw1' = substr(`rawdata',1,(strpos(`rawdata',";")-1) )
	gen str `raw2' = substr(`rawdata',(strpos(`rawdata',";")+1), (length(`rawdata')-strpos(`rawdata',";")) )
	label var `raw1' "`type' $MA_G1L"
	label var `raw2' "`type' $MA_G2L"
}


/* RJH - probably a better way to get this but I've just used globals from earlier */

if "`overall'" == "" & "$MA_nohet" == ""{
	if "$MA_method1" == "USER"{
		if "$MA_firststats" != ""{
			replace `label' = "Overall ($MA_firststats)" if `use'==5
		}
		else{
			replace `label' = "Overall" if `use'==5
		}
	}
	replace `label' = "Overall ($MA_secondstats)" if `use' == 17 & "$MA_method2" == "USER" & "$MA_secondstats" != ""
	replace `label' = "Overall" if `use' == 17 & "$MA_method2" == "USER" & "$MA_secondstats" == ""
}
if "`overall'" == "" & "$MA_nohet" != ""{
	replace `label' = "Overall" if `use' == 5 | `use' == 17
}

tempvar hetGroupLabel expandOverall orderOverall
if "$MA_rjhby" != "" & "$MA_nohet" == "" & "$MA_method1" == "IV"{
*	replace `label' = `label' + ";" if `use' == 5
	qui count
	local prevMax = r(N)
	gen `orderOverall' = _n
	gen `expandOverall' = 1
	replace `expandOverall' = 2 if `use' == 5
	expand `expandOverall'
	replace `orderOverall' = `orderOverall' -0.5 if _n > `prevMax'
	gen `hetGroupLabel' = "Heterogeneity between groups: p = " + ///
		  string($rjhHetGrp, "%5.3f") if _n > `prevMax'
	replace `use' = 4 if _n > `prevMax'
	sort `orderOverall'
}
else{
	gen `hetGroupLabel' = .
}

replace `label' = "Overall" if `use' == 17 & "$MA_method2" != "USER"
replace `label' = "Subtotal" if `use' == 19

qui count if (`use'==1 | `use'==2)
local ntrials=r(N)
qui count if (`use'>=0 & `use'<=5)
local ymax=r(N)
gen `id'=`ymax'-_n+1 if `use'<9 | `use' == 17 | `use' == 19

if "$MA_method2" != "" | "$MA_method1" == "USER" {
	local dispM1 = "$MA_method1"
	local dispM2 = "$MA_method2"
	if "$MA_method1" == "USER"{
		local dispM1 "$MA_userDescM"
	}
	if "$MA_method2" == "USER"{
		local dispM2 "$MA_userDesc"
	}
	replace `label' = "`dispM1'" + " " + `label' if (`use' == 3 | `use' == 5) & substr(`label',1,3) != "het"
	replace `label' = "`dispM2'" + " " + `label' if `use' == 17 | `use' == 19
}


// GET MIN AND MAX DISPLAY
// SORT OUT TICKS- CODE PINCHED FROM MIKE AND FIDDLED. TURNS OUT I'VE BEEN USING SIMILAR NAMES...
// AS SUGGESTED BY JS JUST ACCEPT ANYTHING AS TICKS AND RESPONSIBILITY IS TO USER!

qui summ `lci', detail
local DXmin = r(min)
qui summ `uci', detail
local DXmax = r(max)
local h0 = 0

// MIKE MAKES A MAX VALUE IF SOMETHING EXTREME OCCURS...
if (( ("`sumstat'"=="OR" | "`sumstat'"=="RR" | "`sumstat'"=="HR") & ("`log'"=="") ) | ("`eform'"!="")) {
	local h0=1
	local Glog "xlog"
	local xlog "log" 
	local xexp "exp"
	replace `lci'=1e-9 if `lci'<1e-8
	replace `lci'=1e9  if `lci'>1e8 & `lci'!=.
	replace `uci'=1e-9 if `uci'<1e-8
	replace `uci'=1e9  if `uci'>1e8 & `uci'!=.
	if `DXmin'<1e-8 {
		local DXmin=1e-8
	}
	if `DXmax'>1e8 {
		local DXmax=1e8
	}
}
if "$MA_NULL" != ""{
	local h0 = $MA_NULL
}
if `h0' != 0 & `h0' != 1{
	noi di "Null specified as `h0' in graph- for most effect measures null is 0 or 1"
}

if "`cornfield'"!="" {
	replace `lci'=`log'(1e-9) if ( (`lci'==. | `lci'==0) & (`effect'!=. & `use'==1) )
	replace `uci'=`log'(1e9)  if ( (`uci'==.) & (`effect'!=. & `use'==1) )
}

// THIS BIT CHANGED- THE USER CAN PUT ANYTHING IN

local flag1=0
if ("`xlabel'"=="" | "`xtick'" == "") & "$MA_nulloff" == ""{ 		// if no xlabel or tick
	local xtick  "`h0'"
}

if "`xlabel'"==""{
	local Gmodxhi=max( abs(`xlog'(`DXmin')),abs(`xlog'(`DXmax')))
	if `Gmodxhi'==. {
		local Gmodxhi=2
	}
	local DXmin=`xexp'(-`Gmodxhi')
	local DXmax=`xexp'( `Gmodxhi')
	if "$MA_nulloff" == ""{
		local xlabel "`DXmin',`h0',`DXmax'"
	}
	else{
		local xlabel "`DXmin',`DXmax'"
	}
}

local DXmin2 = min(`xlabel',`DXmin')
local DXmax2 = max(`xlabel',`DXmax')
if "`force'" == ""{
	local Gmodxhi=max( abs(`xlog'(`DXmin')), abs(`xlog'(`DXmax')), ///
		abs(`xlog'(`DXmin2')), abs(`xlog'(`DXmax2')) )
	if `Gmodxhi'==. {
		local Gmodxhi=2
	}
	local DXmin=`xexp'(-`Gmodxhi')
	local DXmax=`xexp'( `Gmodxhi')
	if "`xlabel'" != "" & "$MA_nulloff" == ""{
		local xlabel "`h0',`xlabel'"
	}
}

if "`force'" != ""{
	local DXmin = min(`xlabel')
	local DXmax = max(`xlabel')
	if "$MA_nulloff" == ""{
		local xlabel "`h0',`xlabel'"
	}
}

// LABELS- DON'T ALLOW SILLY NO. OF DECIMAL PLACES

local lblcmd ""
tokenize "`xlabel'", parse(",")
while "`1'" != ""{
	if "`1'" != ","{
		local lbl = string(`1',"%7.3g")
		local val = `1'
		local lblcmd `lblcmd' `val' "`lbl'"
	}
	mac shift
}
if "`xtick'" == ""{
	local xtick = "`xlabel'"
}

local xtick2 = ""
tokenize "`xtick'", parse(",")
while "`1'" != ""{
	if "`1'" != ","{
		local xtick2 = "`xtick2' " + string(`1')
	}
	if "`1'" == ","{
		local xtick2 = "`xtick2'`1'"
	}
	mac shift
}
local xtick = "`xtick2'"

local DXmin=`xlog'(min(`xlabel',`xtick',`DXmin'))
local DXmax=`xlog'(max(`xlabel',`xtick',`DXmax'))

if ("`eform'" != "" | "`xlog'" != "") {
	local lblcmd ""
	tokenize "`xlabel'", parse(",")
	while "`1'" != ""{
		if "`1'" != ","{
			local lbl = string(`1',"%7.3g")
			local val = ln(`1')
			local lblcmd `lblcmd' `val' "`lbl'"
		}
		mac shift
	}
	
	replace `effect' = ln(`effect')
	replace `lci' = ln(`lci')
	replace `uci' = ln(`uci')
	replace `tauLCI' = ln(`tauLCI')
	replace `tauUCI' = ln(`tauUCI')
	local xtick2 ""
	tokenize "`xtick'", parse(",")
	while "`1'" != ""{
		if "`1'" != ","{
			local ln = ln(`1')
			local xtick2 "`xtick2' `ln'"
		}
		if "`1'" == ","{
			local xtick2 "`xtick2'`1'"
		}
		mac shift
	}
	local xtick "`xtick2'"
	local h0 = 0
}

// JUNK
*noi di "min: `DXmin', `DXminLab'; h0: `h0', `h0Lab'; max: `DXmax', `DXmaxLab'"
	
local DXwidth = `DXmax'-`DXmin'
if `DXmin' > 0{
	local h0 = 1
}

} // END QUI

// END OF TICKS AND LABLES

// MAKE OFF-SCALE ARROWS

qui{
tempvar offLeftX offLeftX2 offRightX offRightX2 offYlo offYhi

local arrowWidth = 0.02	// FRACTION OF GRAPH WIDTH
local arrowHeight = 0.5/2 // Y SCALE IS JUST ORDERED NUMBER- 2x0.25 IS 0.5 OF AVAILABLE SPACE

gen `offLeftX' = `DXmin' if `lci' < `DXmin' | `tauLCI' < `DXmin'
gen `offLeftX2' = `DXmin' + `DXwidth'*`arrowWidth' if `lci' < `DXmin' | `tauLCI' < `DXmin'

gen `offRightX' = `DXmax' if `uci' > `DXmax' | (`tauUCI' > `DXmax' & `tauLCI' < .)
gen `offRightX2' = `DXmax' - `DXwidth'*`arrowWidth' if `uci' > `DXmax' | (`tauUCI' > `DXmax' & `tauLCI' < .)

gen `offYlo' = `id' - `arrowHeight'
gen `offYhi' = `id' + `arrowHeight'

replace `lci' = `DXmin' if `lci' < `DXmin' & (`use' == 1 | `use' == 2)
replace `uci' = `DXmax' if `uci' > `DXmax' & (`use' == 1 | `use' == 2)
replace `lci' = . if `uci' < `DXmin' & (`use' == 1 | `use' == 2)
replace `uci' = . if `lci' > `DXmax' & (`use' == 1 | `use' == 2)
replace `effect' = . if `effect' < `DXmin' & (`use' == 1 | `use' == 2)
replace `effect' = . if `effect' > `DXmax' & (`use' == 1 | `use' == 2)
}	// end qui

************************
**      COLUMNS       **
************************

// OPTIONS FOR L-R JUSTIFY?
// HAVE ONE MORE COL POSITION THAN NECESSARY, COULD THEN R-JUSTIFY
// BY ADDING 1 TO LOOP, ALSO HAVE MAX DIST FOR OUTER EDGE
// HAVE USER SPECIFY % OF GRAPH USED FOR TEXT?

qui{	// KEEP QUIET UNTIL AFTER DIAMONDS
local titleOff = 0

if "`lcols'" == ""{
	local lcols = "`label'"
	local titleOff = 1
}

// DOUBLE LINE OPTION
if "$MA_DOUBLE" != "" & ("`lcols'" != "" | "`rcols'" != ""){
	tempvar expand orig
	gen `orig' = _n
	gen `expand' = 1
	replace `expand' = 2 if `use' == 1
	expand `expand'
	sort `orig'
	replace `id' = `id' - 0.45 if `id' == `id'[_n-1]
	replace `use' = 2 if mod(`id',1) != 0 & `use' != 5
	replace `effect' = .  if mod(`id',1) != 0
	replace `lci' = . if mod(`id',1) != 0
	replace `uci' = . if mod(`id',1) != 0
	replace `estText' = "" if mod(`id',1) != 0
	cap replace `raw1' = "" if mod(`id',1) != 0
	cap replace `raw2' = "" if mod(`id',1) != 0
	replace `weightText' = "" if mod(`id',1) != 0

	foreach var of varlist `lcols' `rcols'{
	   cap confirm string var `var'
	   if _rc == 0{
		
		tempvar length words tosplit splitwhere best
		gen `splitwhere' = 0
		gen `best' = .
		gen `length' = length(`var')
		summ `length', det
		gen `words' = wordcount(`var')
		gen `tosplit' = 1 if `length' > r(max)/2+1 & `words' >= 2
		summ `words', det
		local max = r(max)
		forvalues i = 1/`max'{
			replace `splitwhere' = strpos(`var',word(`var',`i')) ///
			 if abs( strpos(`var',word(`var',`i')) - length(`var')/2 ) < `best' ///
			 & `tosplit' == 1
			replace `best' = abs(strpos(`var',word(`var',`i')) - length(`var')/2) ///
			 if abs(strpos(`var',word(`var',`i')) - length(`var')/2) < `best' 
		}

		replace `var' = substr(`var',1,(`splitwhere'-1)) if `tosplit' == 1 & mod(`id',1) == 0
		replace `var' = substr(`var',`splitwhere',length(`var')) if `tosplit' == 1 & mod(`id',1) != 0
		replace `var' = "" if `tosplit' != 1 & mod(`id',1) != 0 & `use' != 5
		drop `length' `words' `tosplit' `splitwhere' `best'
	   }
	   if _rc != 0{
		replace `var' = . if mod(`id',1) != 0 & `use' != 5
	   }
	}
}

summ `id' if `use' != 9
local max = r(max)
local new = r(N)+4
if `new' > _N { 
	set obs `new' 
}

forvalues i = 1/4{	// up to four lines for titles
	local multip = 1
	local add = 0
	if "$MA_DOUBLE" != ""{		// DOUBLE OPTION- CLOSER TOGETHER, GAP BENEATH
		local multip = 0.45
		local add = 0.5
	}
	local idNew`i' = `max' + `i'*`multip' + `add'
	local Nnew`i'=r(N)+`i'
	local tmp = `Nnew`i''
	replace `id' = `idNew`i'' + 1 in `tmp'
	replace `use' = 1 in `tmp'
	if `i' == 1{
		global borderline = `idNew`i''-0.25
	}
}

local maxline = 1
if "`lcols'" != ""{
	tokenize "`lcols'"
	local lcolsN = 0

	while "`1'" != ""{
		cap confirm var `1'
		if _rc!=0  {
			di in re "Variable `1' not defined"
			exit _rc
		}
		local lcolsN = `lcolsN' + 1
		tempvar left`lcolsN' leftLB`lcolsN' leftWD`lcolsN'
		cap confirm string var `1'
		if _rc == 0{
			gen str `leftLB`lcolsN'' = `1'
		}
		if _rc != 0{
			cap decode `1', gen(`leftLB`lcolsN'')
			if _rc != 0{
				local f: format `1'
				gen str `leftLB`lcolsN'' = string(`1', "`f'")
				replace `leftLB`lcolsN'' = "" if `leftLB`lcolsN'' == "."
			}
		}
		replace `leftLB`lcolsN'' = "" if (`use' != 1 & `use' != 2)
		local colName: variable label `1'
		if "`colName'"==""{
			local colName = "`1'"
		}

		// WORK OUT IF TITLE IS BIGGER THAN THE VARIABLE
		// SPREAD OVER UP TO FOUR LINES IF NECESSARY
		local titleln = length("`colName'")
		tempvar tmpln
		gen `tmpln' = length(`leftLB`lcolsN'')
		qui summ `tmpln' if `use' != 0
		local otherln = r(max)
		drop `tmpln'
		// NOW HAVE LENGTH OF TITLE AND MAX LENGTH OF VARIABLE
		local spread = int(`titleln'/`otherln')+1
		if `spread'>4{
			local spread = 4
		}

		local line = 1
		local end = 0
		local count = -1
		local c2 = -2

		local first = word("`colName'",1)
		local last = word("`colName'",`count')
		local nextlast = word("`colName'",`c2')

		while `end' == 0{
			replace `leftLB`lcolsN'' = "`last'" + " " + `leftLB`lcolsN'' in `Nnew`line''
			local check = `leftLB`lcolsN''[`Nnew`line''] + " `nextlast'"	// what next will be

			local count = `count'-1
			local last = word("`colName'",`count')
			if "`last'" == ""{
				local end = 1
			}

			if length(`leftLB`lcolsN''[`Nnew`line'']) > `titleln'/`spread' | ///
			  length("`check'") > `titleln'/`spread' & "`first'" == "`nextlast'"{
				if `end' == 0{
					local line = `line'+1
				}
			}
		}
		if `line' > `maxline'{
			local maxline = `line'
		}

		mac shift
	}
}

if `titleOff' == 1	{
	forvalues i = 1/4{
		replace `leftLB1' = "" in `Nnew`i'' 		// get rid of horrible __var name
	}
}
replace `leftLB1' = `label' if `use' != 1 & `use' != 2	// put titles back in (overall, sub est etc.)

//	STUFF ADDED FOR JS TO INCLUDE EFFICACY AS COLUMN WITH OVERALL

*effect lci uci tempvars
if "$MA_efficacy" != ""{
	tempvar vetemp ucivetemp lcivetemp vaccine_efficacy
	qui {
	 gen `vetemp'=100*(1-exp(`effect'))
	 tostring `vetemp', replace force format(%4.0f)

	 gen `ucivetemp'=100*(1-exp(`lci'))
	 tostring `ucivetemp', replace force format(%4.0f)

	 gen `lcivetemp'=100*(1-exp(`uci'))
	 tostring `lcivetemp', replace force format(%4.0f)

	 gen str30 `vaccine_efficacy'=`vetemp'+" ("+`lcivetemp'+", "+`ucivetemp'+")" if `effect' != .
	 label var `vaccine_efficacy' "Vaccine efficacy (%)"
	
	 local rcols = "`vaccine_efficacy' " + "`rcols' "

	}
}

if "`wt'" == ""{
	local rcols = "`weightText' " + "`rcols'"
	if "$MA_method2" != ""{
		label var `weightText' "% Weight ($MA_method1)"
	}
	else{
		label var `weightText' "% Weight"
	}
}
if "`counts'" != ""{
	local rcols = "`raw1' " + "`raw2' " + "`rcols'"
}
if "`stats'" == ""{
	local rcols = "`estText' " + "`rcols'"
	if "$MA_ESLA" == ""{
		global MA_ESLA = "`sumstat'"
	}
	label var `estText' "$MA_ESLA ($IND% CI)"
}	

tempvar extra
gen `extra' = ""
label var `extra' " "
local rcols = "`rcols' `extra'"

local rcolsN = 0
if "`rcols'" != ""{
	tokenize "`rcols'"
	local rcolsN = 0
	while "`1'" != ""{
		cap confirm var `1'
		if _rc!=0  {
			di in re "Variable `1' not defined"
			exit _rc
		}
		local rcolsN = `rcolsN' + 1
		tempvar right`rcolsN' rightLB`rcolsN' rightWD`rcolsN'
		cap confirm string var `1'
		if _rc == 0{
			gen str `rightLB`rcolsN'' = `1'
		}
		if _rc != 0{
			local f: format `1'
			gen str `rightLB`rcolsN'' = string(`1', "`f'")
			replace `rightLB`rcolsN'' = "" if `rightLB`rcolsN'' == "."
		}
		local colName: variable label `1'
		if "`colName'"==""{
			local colName = "`1'"
		}

		// WORK OUT IF TITLE IS BIGGER THAN THE VARIABLE
		// SPREAD OVER UP TO FOUR LINES IF NECESSARY
		local titleln = length("`colName'")
		tempvar tmpln
		gen `tmpln' = length(`rightLB`rcolsN'')
		qui summ `tmpln' if `use' != 0
		local otherln = r(max)
		drop `tmpln'
		// NOW HAVE LENGTH OF TITLE AND MAX LENGTH OF VARIABLE
		local spread = int(`titleln'/`otherln')+1
		if `spread'>4{
			local spread = 4
		}

		local line = 1
		local end = 0
		local count = -1
		local c2 = -2

		local first = word("`colName'",1)
		local last = word("`colName'",`count')
		local nextlast = word("`colName'",`c2')

		while `end' == 0{
			replace `rightLB`rcolsN'' = "`last'" + " " + `rightLB`rcolsN'' in `Nnew`line''
			local check = `rightLB`rcolsN''[`Nnew`line''] + " `nextlast'"	// what next will be

			local count = `count'-1
			local last = word("`colName'",`count')
			if "`last'" == ""{
				local end = 1
			}
			if length(`rightLB`rcolsN''[`Nnew`line'']) > `titleln'/`spread' | ///
			  length("`check'") > `titleln'/`spread' & "`first'" == "`nextlast'"{
				if `end' == 0{
					local line = `line'+1
				}
			}
		}
		if `line' > `maxline'{
			local maxline = `line'
		}

		mac shift
	}
}

// now get rid of extra title rows if they weren't used


if `maxline'==3{
	drop in `Nnew4'
}
if `maxline'==2{
	drop in `Nnew3'/`Nnew4'
}
if `maxline'==1{
	drop in `Nnew2'/`Nnew4'
}
	

/* BODGE SOLU- EXTRA COLS */
while `rcolsN' < 2{
	local rcolsN = `rcolsN' + 1
	tempvar right`rcolsN' rightLB`rcolsN' rightWD`rcolsN'
	gen str `rightLB`rcolsN'' = " "
}


local skip = 1
if "`stats'" == "" & "`wt'" == ""{				// sort out titles for stats and weight, if there
	local skip = 3
}

if "`stats'" != "" & "`wt'" == ""{
	local skip = 2
}
if "`stats'" == "" & "`wt'" != ""{
	local skip = 2
}
if "`counts'" != ""{
	local skip = `skip' + 2
}
if "$MA_efficacy" != ""{
	local skip = `skip' + 1
}

/* SET TWO DUMMY RCOLS IF NOSTATS NOWEIGHT */

forvalues i = `skip'/`rcolsN'{					// get rid of junk if not weight, stats or counts
	replace `rightLB`i'' = "" if (`use' != 1 & `use' != 2)
}
forvalues i = 1/`rcolsN'{
	replace `rightLB`i'' = "" if (`use' ==0)
}

local leftWDtot = 0
local rightWDtot = 0
local leftWDtotNoTi = 0

forvalues i = 1/`lcolsN'{
	getWidth `leftLB`i'' `leftWD`i''
	qui summ `leftWD`i'' if `use' != 0 & `use' != 4 & `use' != 3 & `use' != 5 & ///
		`use' != 17 & `use' != 19	// DON'T INCLUDE OVERALL STATS AT THIS POINT
	local maxL = r(max)
	local leftWDtotNoTi = `leftWDtotNoTi' + `maxL'
	replace `leftWD`i'' = `maxL'
}
tempvar titleLN				// CHECK IF OVERALL LENGTH BIGGER THAN REST OF LCOLS
getWidth `leftLB1' `titleLN'	
qui summ `titleLN' if `use' != 0 & `use' != 4
local leftWDtot = max(`leftWDtotNoTi', r(max))

forvalues i = 1/`rcolsN'{
	getWidth `rightLB`i'' `rightWD`i''
	qui summ `rightWD`i'' if `use' != 0 & `use' != 4
	replace `rightWD`i'' = r(max)
	local rightWDtot = `rightWDtot' + r(max)
}

// CHECK IF NOT WIDE ENOUGH (I.E., OVERALL INFO TOO WIDE)
// LOOK FOR EDGE OF DIAMOND summ `lci' if `use' == ...

tempvar maxLeft
getWidth `leftLB1' `maxLeft'
qui count if `use' == 3 | `use' == 5 | `use' == 17 | `use' == 19
if r(N) > 0{
	summ `maxLeft' if `use' == 3 | `use' == 5 | `use' == 17 | `use' == 19	// NOT TITLES THOUGH!
	local max = r(max)
	if `max' > `leftWDtotNoTi'{
		// WORK OUT HOW FAR INTO PLOT CAN EXTEND
		// WIDTH OF LEFT COLUMNS AS FRACTION OF WHOLE GRAPH
		local x = `leftWDtot'*($MA_AS_TEXT/100)/(`leftWDtot'+`rightWDtot')
		tempvar y
		// SPACE TO LEFT OF DIAMOND WITHIN PLOT (FRAC OF GRAPH)
		gen `y' = ((100-$MA_AS_TEXT)/100)*(`lci'-`DXmin') / (`DXmax'-`DXmin') 
		qui summ `y' if `use' == 3 | `use' == 5
		local extend = 1*(r(min)+`x')/`x'
		local leftWDtot = max(`leftWDtot'/`extend',`leftWDtotNoTi') // TRIM TO KEEP ON SAFE SIDE
											// ALSO MAKE SURE NOT LESS THAN BEFORE!
	}

}

global LEFT_WD = `leftWDtot'
global RIGHT_WD = `rightWDtot'


local ratio = $MA_AS_TEXT		// USER SPECIFIED- % OF GRAPH TAKEN BY TEXT (ELSE NUM COLS CALC?)
local textWD = (`DXwidth'/(1-`ratio'/100)-`DXwidth') /(`leftWDtot'+`rightWDtot')

forvalues i = 1/`lcolsN'{
	gen `left`i'' = `DXmin' - `leftWDtot'*`textWD'
	local leftWDtot = `leftWDtot'-`leftWD`i''
}

gen `right1' = `DXmax'
forvalues i = 2/`rcolsN'{
	local r2 = `i'-1
	gen `right`i'' = `right`r2'' + `rightWD`r2''*`textWD'
}

local AXmin = `left1'
local AXmax = `DXmax' + `rightWDtot'*`textWD'

foreach type in "" "inf"{
	replace `tauLCI`inf'' = `DXmin' if `tauLCI' < `DXmin' & `tauLCI`inf'' != .
	replace `tauLCI`inf'' = . if `lci' < `DXmin'
	replace `tauLCI`inf'' = . if `tauLCI`inf'' > `lci'
	
	replace `tauUCI`inf'' = `DXmax' if `tauUCI`inf'' > `DXmax' & `tauUCI`inf'' != .
	replace `tauUCI`inf'' = . if `uci' > `DXmax'
	replace `tauUCI`inf'' = . if `tauUCI`inf'' < `uci'
	
	//replace `tauLCI`inf'' = . if (`use' == 3 | `use' == 5) & "$MA_method1" != "D+L"
	//replace `tauUCI`inf'' = . if (`use' == 3 | `use' == 5) & "$MA_method1" != "D+L"
	//replace `tauLCI`inf'' = . if (`use' == 17 | `use' == 19) & "$MA_method2" != "D+L"
	//replace `tauUCI`inf'' = . if (`use' == 17 | `use' == 19) & "$MA_method2" != "D+L"
	replace `tauLCI`inf'' = . if (`use' == 3 | `use' == 5) & "$MA_method1" == "FE"
	replace `tauUCI`inf'' = . if (`use' == 3 | `use' == 5) & "$MA_method1" == "FE"
	replace `tauLCI`inf'' = . if (`use' == 17 | `use' == 19) & "$MA_method2" == "FE"
	replace `tauUCI`inf'' = . if (`use' == 17 | `use' == 19) & "$MA_method2" == "FE"	
}


// DIAMONDS TAKE FOREVER...I DON'T THINK THIS IS WHAT MIKE DID
tempvar DIAMleftX DIAMrightX DIAMbottomX DIAMtopX DIAMleftY1 DIAMrightY1 DIAMleftY2 DIAMrightY2 DIAMbottomY DIAMtopY

gen `DIAMleftX' = `lci' if `use' == 3 | `use' == 5 | `use' == 17 | `use' == 19
replace `DIAMleftX' = `DXmin' if `lci' < `DXmin' & (`use' == 3 | `use' == 5 | `use' == 17 | `use' == 19)
replace `DIAMleftX' = . if `effect' < `DXmin' & (`use' == 3 | `use' == 5 | `use' == 17 | `use' == 19)
gen `DIAMleftY1' = `id' if `use' == 3 | `use' == 5 | `use' == 17 | `use' == 19
replace `DIAMleftY1' = `id' + 0.4*( abs((`DXmin'-`lci')/(`effect'-`lci')) ) if `lci' < `DXmin' & (`use' == 3 | `use' == 5 | `use' == 17 | `use' == 19)
replace `DIAMleftY1' = . if `effect' < `DXmin' & (`use' == 3 | `use' == 5 | `use' == 17 | `use' == 19)
gen `DIAMleftY2' = `id' if `use' == 3 | `use' == 5 | `use' == 17 | `use' == 19
replace `DIAMleftY2' = `id' - 0.4*( abs((`DXmin'-`lci')/(`effect'-`lci')) ) if `lci' < `DXmin' & (`use' == 3 | `use' == 5 | `use' == 17 | `use' == 19)
replace `DIAMleftY2' = . if `effect' < `DXmin' & (`use' == 3 | `use' == 5 | `use' == 17 | `use' == 19)

gen `DIAMrightX' = `uci' if `use' == 3 | `use' == 5 | `use' == 17 | `use' == 19
replace `DIAMrightX' = `DXmax' if `uci' > `DXmax' & (`use' == 3 | `use' == 5 | `use' == 17 | `use' == 19)
replace `DIAMrightX' = . if `effect' > `DXmax' & (`use' == 3 | `use' == 5 | `use' == 17 | `use' == 19)
gen `DIAMrightY1' = `id' if `use' == 3 | `use' == 5 | `use' == 17 | `use' == 19
replace `DIAMrightY1' = `id' + 0.4*( abs((`uci'-`DXmax')/(`uci'-`effect')) ) if `uci' > `DXmax' & (`use' == 3 | `use' == 5 | `use' == 17 | `use' == 19)
replace `DIAMrightY1' = . if `effect' > `DXmax' & (`use' == 3 | `use' == 5 | `use' == 17 | `use' == 19)
gen `DIAMrightY2' = `id' if `use' == 3 | `use' == 5 | `use' == 17 | `use' == 19
replace `DIAMrightY2' = `id' - 0.4*( abs((`uci'-`DXmax')/(`uci'-`effect')) ) if `uci' > `DXmax' & (`use' == 3 | `use' == 5 | `use' == 17 | `use' == 19)

replace `DIAMrightY2' = . if `effect' > `DXmax' & (`use' == 3 | `use' == 5 | `use' == 17 | `use' == 19)
gen `DIAMbottomY' = `id' - 0.4 if `use' == 3 | `use' == 5 | `use' == 17 | `use' == 19
replace `DIAMbottomY' = `id' - 0.4*( abs((`uci'-`DXmin')/(`uci'-`effect')) ) if `effect' < `DXmin' & (`use' == 3 | `use' == 5 | `use' == 17 | `use' == 19)
replace `DIAMbottomY' = `id' - 0.4*( abs((`DXmax'-`lci')/(`effect'-`lci')) ) if `effect' > `DXmax' & (`use' == 3 | `use' == 5 | `use' == 17 | `use' == 19)
gen `DIAMtopY' = `id' + 0.4 if `use' == 3 | `use' == 5 | `use' == 17 | `use' == 19
replace `DIAMtopY' = `id' + 0.4*( abs((`uci'-`DXmin')/(`uci'-`effect')) ) if `effect' < `DXmin' & (`use' == 3 | `use' == 5 | `use' == 17 | `use' == 19)
replace `DIAMtopY' = `id' + 0.4*( abs((`DXmax'-`lci')/(`effect'-`lci')) ) if `effect' > `DXmax' & (`use' == 3 | `use' == 5 | `use' == 17 | `use' == 19)

gen `DIAMtopX' = `effect' if `use' == 3 | `use' == 5 | `use' == 17 | `use' == 19
replace `DIAMtopX' = `DXmin' if `effect' < `DXmin' & (`use' == 3 | `use' == 5 | `use' == 17 | `use' == 19)
replace `DIAMtopX' = `DXmax' if `effect' > `DXmax' & (`use' == 3 | `use' == 5 | `use' == 17 | `use' == 19)
replace `DIAMtopX' = . if (`uci' < `DXmin' | `lci' > `DXmax') & (`use' == 3 | `use' == 5 | `use' == 17 | `use' == 19)
gen `DIAMbottomX' = `DIAMtopX'

} // END QUI

// v1.11 TEXT SIZE SOLU
// v1.16 TRYING AGAIN!
// IF aspect IS USED IN "$MA_OTHEROPTS" (OTHER GRAPH OPTS) THEN THIS HELPS TO CALCULATE TEXT SIZE
// IF NO ASPECT, BUT xsize AND ysize USED THEN FIND RATIO MANUALLY
// STATA ALWAYS TRIES TO PRODUCE A GRAPH WITH ASPECT ABOUT 0.77 - TRY TO FIND "NATURAL ASPECT"

local aspect = .

if strpos(`"$MA_OTHEROPTS"',"aspect") > 0{
	local aspectTXT = substr( `"$MA_OTHEROPTS"', (strpos(`"$MA_OTHEROPTS"',"aspect")), (length(`"$MA_OTHEROPTS"')) )
	local aspectTXT = substr( "`aspectTXT'", 1, ( strpos("`aspectTXT'",")")) )
	local aspect = real( substr(   "`aspectTXT'", ( strpos("`aspectTXT'","(") +1 ), ///
					( strpos("`aspectTXT'",")") - strpos("`aspectTXT'","(") -1   )   ))
}

if strpos(`"$MA_OTHEROPTS"',"xsize") > 0 ///
  & strpos(`"$MA_OTHEROPTS"',"ysize") > 0 ///
  & strpos(`"$MA_OTHEROPTS"',"aspect") == 0{

	local xsizeTXT = substr( `"$MA_OTHEROPTS"', (strpos(`"$MA_OTHEROPTS"',"xsize")), (length(`"$MA_OTHEROPTS"')) )

	// Ian White's bug fix!
	local xsizeTXT = substr( `"`xsizeTXT'"', 1, ( strpos(`"`xsizeTXT'"',")")) )
	local xsize = real( substr(   `"`xsizeTXT'"', ( strpos(`"`xsizeTXT'"',"(") +1 ), ///
                     ( strpos(`"`xsizeTXT'"',")") - strpos(`"`xsizeTXT'"',"(") -1   )   ))
	local ysizeTXT = substr( `"$MA_OTHEROPTS"', (strpos(`"$MA_OTHEROPTS"',"ysize")), (length(`"$MA_OTHEROPTS"')) )	
	local ysizeTXT = substr( `"`ysizeTXT'"', 1, ( strpos(`"`ysizeTXT'"',")")) )
	local ysize = real( substr(   `"`ysizeTXT'"', ( strpos(`"`ysizeTXT'"',"(") +1 ), ///
                     ( strpos(`"`ysizeTXT'"',")") - strpos(`"`ysizeTXT'"',"(") -1   )   ))

	local aspect = `ysize'/`xsize'
}
local approx_chars = ($LEFT_WD + $RIGHT_WD)/($MA_AS_TEXT/100)
qui count if `use' != 9
local height = r(N)
local natu_aspect = 1.3*`height'/`approx_chars'


if `aspect' == .{
	// sort out relative to text, but not to ridiculous degree
	local new_asp = 0.5*`natu_aspect' + 0.5*1 
	global MA_OTHEROPTS `"$MA_OTHEROPTS aspect(`new_asp')"'
	local aspectRat = max( `new_asp'/`natu_aspect' , `natu_aspect'/`new_asp' )
}
if `aspect' != .{
	local aspectRat = max( `aspect'/`natu_aspect' , `natu_aspect'/`aspect' )
}
local adj = 1.25
if `natu_aspect' > 0.7{
	local adj = 1/(`natu_aspect'^1.3+0.2)
}

local textSize = `adj' * $MA_TEXT_SCA / (`approx_chars' * sqrt(`aspectRat') )
local textSize2 = `adj' * $MA_TEXT_SCA / (`approx_chars' * sqrt(`aspectRat') )

forvalues i = 1/`lcolsN'{
	local lcolCommands`i' "(scatter `id' `left`i'' if `use' != 4, msymbol(none) mlabel(`leftLB`i'') mlabcolor(black) mlabpos(3) mlabsize(`textSize')) "
}
forvalues i = 1/`rcolsN'{
	local rcolCommands`i' "(scatter `id' `right`i'' if `use' != 4, msymbol(none) mlabel(`rightLB`i'') mlabcolor(black) mlabpos(3) mlabsize(`textSize')) "
}
if "$MA_rfdist" != ""{
	if "`stats'" == ""{
		local predIntCmd "(scatter `id' `right1' if `use' == 4, msymbol(none) mlabel(`RFdistText') mlabcolor(black) mlabpos(3) mlabsize(`textSize')) "
	}
	if "$MA_nohet" == ""{
		local predIntCmd2 "(scatter `id' `left1' if `use' == 4, msymbol(none) mlabel(`RFdistLabel') mlabcolor(black) mlabpos(3) mlabsize(`textSize')) "
	}	
}
if "$MA_nohet" == "" & "$MA_rjhby" != ""{
	local hetGroupCmd  "(scatter `id' `left1' if `use' == 4, msymbol(none) mlabel(`hetGroupLabel') mlabcolor(black) mlabpos(3) mlabsize(`textSize')) "
}

// OTHER BITS AND BOBS

local dispBox "none"
if "`nobox'" == ""{
	local dispBox "square	"
}

local boxsize = $MA_FBSC/150

if "$MA_FAVOURS" != ""{
	local pos = strpos("$MA_FAVOURS", "#")
	local leftfav = substr("$MA_FAVOURS",1,(`pos'-1))
	local rightfav = substr("$MA_FAVOURS",(`pos'+1),(length("$MA_FAVOURS")-`pos'+1) )
}
if `h0' != . & "$MA_nulloff" == ""{
	local leftfp = `DXmin' + (`h0'-`DXmin')/2
	local rightfp = `h0' + (`DXmax'-`h0')/2
}
else{
	local leftfp = `DXmin'
	local rightfp = `DXmax'
}


// GRAPH APPEARANCE OPTIONS- ADDED v1.15

/*
if `"$MA_OPT"' != "" & strpos(`"$MA_OPT"',"m") == 0{(
	global MA_OPT = `"$MA_OPT m()"'
}
*/

if `"$MA_BOXOPT"' != "" & strpos(`"$MA_BOXOPT"',"msymbol") == 0{	// make defaults if unspecified
	global MA_BOXOPT = `"$MA_BOXOPT msymbol(square)"'
}
if `"$MA_BOXOPT"' != "" & strpos(`"$MA_BOXOPT"',"mcolor") == 0{	// make defaults if unspecified
	global MA_BOXOPT = `"$MA_BOXOPT mcolor("180 180 180")"'
}
if `"$MA_BOXOPT"' == ""{
	local boxopt "msymbol(`dispBox') msize(`boxsize') mcolor("180 180 180")"
}
else{
	if strpos(`"$MA_BOXOPT"',"mla") != 0{
		di as error "Option mlabel() not allowed in boxopt()"
		exit
	}
	if strpos(`"$MA_BOXOPT"',"msi") != 0{
		di as error "Option msize() not allowed in boxopt()"
		exit
	}
	local boxopt `"$MA_BOXOPT msize(`boxsize')"'
}
if "$MA_classic" != ""{
	local boxopt "mcolor(black) msymbol(square) msize(`boxsize')"
}
if "`box'" != ""{
	local boxopt "msymbol(none)"
}



if `"$MA_DIAMOPT"' == ""{
	local diamopt "lcolor("0 0 100")"
}
else{
	if strpos(`"$MA_DIAMOPT"',"hor") != 0 | strpos(`"$MA_DIAMOPT"',"vert") != 0{
		di as error "Options horizontal/vertical not allowed in diamopt()"
		exit
	}
	if strpos(`"$MA_DIAMOPT"',"con") != 0{
		di as error "Option connect() not allowed in diamopt()"
		exit
	}
	if strpos(`"$MA_DIAMOPT"',"lp") != 0{
		di as error "Option lpattern() not allowed in diamopt()"
		exit
	}
	local diamopt `"$MA_DIAMOPT"'
}



if `"$MA_POINTOPT"' != "" & strpos(`"$MA_POINTOPT"',"msymbol") == 0{(
	global MA_POINTOPT = `"$MA_POINTOPT msymbol(diamond)"'
}
if `"$MA_POINTOPT"' != "" & strpos(`"$MA_POINTOPT"',"msize") == 0{(
	global MA_POINTOPT = `"$MA_POINTOPT msize(vsmall)"'
}
if `"$MA_POINTOPT"' != "" & strpos(`"$MA_POINTOPT"',"mcolor") == 0{(
	global MA_POINTOPT = `"$MA_POINTOPT mcolor(black)"'
}
if `"$MA_POINTOPT"' == ""{
	local pointopt "msymbol(diamond) msize(vsmall) mcolor("0 0 0")"
}
else{
	local pointopt `"$MA_POINTOPT"'
}
if "$MA_classic" != "" & "`box'" == ""{
	local pointopt "msymbol(none)"
}



if `"$MA_CIOPT"' != "" & strpos(`"$MA_CIOPT"',"lcolor") == 0{(
	global MA_CIOPT = `"$MA_CIOPT lcolor(black)"'
}
if `"$MA_CIOPT"' == ""{
	local ciopt "lcolor("0 0 0")"
}
else{
	if strpos(`"$MA_CIOPT"',"hor") != 0 | strpos(`"$MA_CIOPT"',"vert") != 0{
		di as error "Options horizontal/vertical not allowed in ciopt()"
		exit
	}
	if strpos(`"$MA_CIOPT"',"con") != 0{
		di as error "Option connect() not allowed in ciopt()"
		exit
	}
	if strpos(`"$MA_CIOPT"',"lp") != 0{
		di as error "Option lpattern() not allowed in ciopt()"
		exit
	}
	local ciopt `"$MA_CIOPT"'
}


// END GRAPH OPTS



//if "$MA_method1" == "D+L"{
if "$MA_method1" != "FE"{
	tempvar noteposx noteposy notelab
	qui{
	summ `id'
		gen `noteposy' = r(min) -1.5 in 1
		summ `left1'
		gen `noteposx' = r(mean) in 1
		gen `notelab' = "NOTE: Weights are from random effects analysis" in 1
		local notecmd "(scatter `noteposy' `noteposx', msymbol(none) mlabel(`notelab') mlabcolor(black) mlabpos(3) mlabsize(`textSize')) "
		if "$MA_method1" == "MH" {
			replace `notelab' = "NOTE: Mantel-Haenszel fixed-effect weights" in 1
		}
		if "$MA_method1" == "PETO" {
			replace `notelab' = "NOTE: Peto fixed-effect weights" in 1
		}			
	}
	if "$MA_nowarning" != ""{
		local notecmd
	}
}


if "`overall'" != ""{
	local overallCommand ""
	qui drop if `use' == 5
	qui summ `id'
	local DYmin = r(min)
	cap replace `noteposy' = r(min) -.5 in 1
}

// quick bodge to get overall- can't find log version!
tempvar tempOv ovLine ovMin ovMax h0Line
qui gen `tempOv' = `effect' if `use' == 5
sort `tempOv'
qui summ `id'
local DYmin = r(min)-2
local DYmax = r(max)+1

qui gen `ovLine' = `tempOv' in 1
qui gen `ovMin' = r(min)-2 in 1
qui gen `ovMax' = $borderline in 1
qui gen `h0Line' = `h0' in 1

if `"$MA_OLINEOPT"' == ""{
	local overallCommand " (pcspike `ovMin' `ovLine' `ovMax' `ovLine', lwidth(thin) lcolor(maroon) lpattern(shortdash)) "
}
else{
	local overallCommand `" (pcspike `ovMin' `ovLine' `ovMax' `ovLine', $MA_OLINEOPT) "'
}
if `ovLine' > `DXmax' | `ovLine' < `DXmin' | "`overall'" != ""{	// ditch if not on graph
	local overallCommand ""
}

local nullCommand " (pcspike `ovMin' `h0Line' `ovMax' `h0Line', lwidth(thin) lcolor(black) ) "

// gap if "favours" used
if "`leftfav'" != "" | "`rightfav'" != ""{
	local gap = "labgap(5)"
}

// if summary only must not have weights
local awweight "[aw= `weight']"
if "$MA_summaryonly" != ""{
	local awweight ""
}
qui summ `weight'
if r(N) == 0{
	local awweight ""
}

// rfdist off scale arrows only used when appropriate
qui{
tempvar rfarrow
gen `rfarrow' = 0
if "$MA_rfdist" != ""{
	//if "$MA_method1" == "D+L"{
	if "$MA_method1" != "FE"{
		replace `rfarrow' = 1 if `use' == 3 | `use' == 5
	}
	//if "$MA_method2" == "D+L"{
	if "$MA_method2" != "FE"{
		replace `rfarrow' = 1 if `use' == 17 | `use' == 19
	}
}
}	// end qui


// final addition- if aspect() given but not xsize() ysize(), put these in to get rid of gaps
// need to fiddle to allow space for bottom title
// should this just replace the aspect option?
// suppose good to keep- most people hopefully using xsize and ysize and can always change themselves if using aspect

if strpos(`"$MA_OTHEROPTS"',"xsize") == 0 & strpos(`"$MA_OTHEROPTS"',"ysize") == 0 ///
  & strpos(`"$MA_OTHEROPTS"',"aspect") > 0 {

	local aspct = substr(`"$MA_OTHEROPTS"', (strpos(`"$MA_OTHEROPTS"',"aspect(")+7 ) , length(`"$MA_OTHEROPTS"') )
	local aspct = substr(`"`aspct'"', 1, (strpos(`"`aspct'"',")")-1) )
	if `aspct' > 1{
		local xx = (11.5+(2-2*1/`aspct'))/`aspct'
		local yy = 12
	}
	if `aspct' <= 1{
		local yy = 12*`aspct'
		local xx = 11.5-(2-2*`aspct')
	}
	global MA_OTHEROPTS = `"$MA_OTHEROPTS"' + " xsize(`xx') ysize(`yy')"

}

// switch off null if wanted
if "$MA_nulloff" != ""{
	local nullCommand ""
}

***************************
***        GRAPH        ***
***************************

#delimit ;

twoway
/* NOTE FOR RF, OVERALL AND NULL LINES FIRST */ 
	`notecmd' `overallCommand' `nullCommand' `predIntCmd' `predIntCmd2' `hetGroupCmd'
/* PLOT BOXES AND PUT ALL THE GRAPH OPTIONS IN THERE */
	(scatter `id' `effect' `awweight' if `use' == 1, 
	  `boxopt' 
	  yscale(range(`DYmin' `DYmax') noline )
	  ylabel(none) ytitle("")
	  xscale(range(`AXmin' `AXmax'))
	  xlabel(`lblcmd', labsize(`textSize2') )
	  yline($borderline, lwidth(thin) lcolor(gs12))
/* THIS BIT DOES favours. NOTE SPACES TO SUPPRESS IF THIS IS NOT USED */
	  xmlabel(`leftfp' "`leftfav' " `rightfp' "`rightfav' ", noticks labels labsize(`textSize') 
	  `gap' /* PUT LABELS UNDER xticks? Yes as labels now extended */ ) 
	  xtitle("") legend(off) xtick("`xtick'") )
/* END OF FIRST SCATTER */
/* HERE ARE THE CONFIDENCE INTERVALS */
	(pcspike `id' `lci' `id' `uci' if `use' == 1, `ciopt')
/* ADD ARROWS IF OFFSCALE USING offLeftX offLeftX2 offRightX offRightX2 offYlo offYhi */
	(pcspike `id' `offLeftX' `offYlo' `offLeftX2' if `use' == 1, `ciopt')
	(pcspike `id' `offLeftX' `offYhi' `offLeftX2' if `use' == 1, `ciopt')
	(pcspike `id' `offRightX' `offYlo' `offRightX2' if `use' == 1, `ciopt')
	(pcspike `id' `offRightX' `offYhi' `offRightX2' if `use' == 1, `ciopt')
/* DIAMONDS FOR SUMMARY ESTIMATES -START FROM 9 O'CLOCK */
	(pcspike `DIAMleftY1' `DIAMleftX' `DIAMtopY' `DIAMtopX' if `use' == 3 | `use' == 5 | `use' == 17 | `use' == 19, `diamopt')
	(pcspike `DIAMtopY' `DIAMtopX' `DIAMrightY1' `DIAMrightX' if `use' == 3 | `use' == 5 | `use' == 17 | `use' == 19, `diamopt')
	(pcspike `DIAMrightY2' `DIAMrightX' `DIAMbottomY' `DIAMbottomX' if `use' == 3 | `use' == 5 | `use' == 17 | `use' == 19, `diamopt')
	(pcspike `DIAMbottomY' `DIAMbottomX' `DIAMleftY2' `DIAMleftX' if `use' == 3 | `use' == 5 | `use' == 17 | `use' == 19, `diamopt') 
/* EXTENDED CI FOR RANDOM EFFECTS, SHOW DISTRIBUTION AS RECOMMENDED BY JULIAN HIGGINS 
   DOTTED LINES FOR INESTIMABLE DISTRIBUTION */
	(pcspike `DIAMleftY1' `DIAMleftX' `DIAMleftY1' `tauLCI' if (`use' == 3 | `use' == 5 | `use' == 17 | `use' == 19) & `tau2' < ., `diamopt')
	(pcspike `DIAMrightY1' `DIAMrightX' `DIAMrightY1' `tauUCI' if (`use' == 3 | `use' == 5 | `use' == 17 | `use' == 19) & `tau2' < ., `diamopt')
	(pcspike `DIAMleftY1' `DIAMleftX' `DIAMleftY1' `tauLCI' if (`use' == 3 | `use' == 5 | `use' == 17 | `use' == 19) & `tau2' ==.b, `diamopt' lpattern(shortdash))
	(pcspike `DIAMrightY1' `DIAMrightX' `DIAMrightY1' `tauUCI' if (`use' == 3 | `use' == 5 | `use' == 17 | `use' == 19) & `tau2' ==.b, `diamopt' lpattern(shortdash))
/* DIAMOND EXTENSION FOR RF DIST ALSO HAS ARROWS... */
	(pcspike `id' `offLeftX' `offYlo' `offLeftX2' if (`use' == 3 | `use' == 5 | `use' == 17 | `use' == 19) & `rfarrow' == 1, `diamopt')
	(pcspike `id' `offLeftX' `offYhi' `offLeftX2' if (`use' == 3 | `use' == 5 | `use' == 17 | `use' == 19) & `rfarrow' == 1, `diamopt')
	(pcspike `id' `offRightX' `offYlo' `offRightX2' if (`use' == 3 | `use' == 5 | `use' == 17 | `use' == 19) & `rfarrow' == 1, `diamopt')
	(pcspike `id' `offRightX' `offYhi' `offRightX2' if (`use' == 3 | `use' == 5 | `use' == 17 | `use' == 19) & `rfarrow' == 1, `diamopt')
/* COLUMN VARIBLES */
	`lcolCommands1' `lcolCommands2' `lcolCommands3' `lcolCommands4' `lcolCommands5' `lcolCommands6'
	`lcolCommands7' `lcolCommands8' `lcolCommands9' `lcolCommands10' `lcolCommands11' `lcolCommands12'
	`rcolCommands1' `rcolCommands2' `rcolCommands3' `rcolCommands4' `rcolCommands5' `rcolCommands6'
	`rcolCommands7' `rcolCommands8' `rcolCommands9' `rcolCommands10' `rcolCommands11' `rcolCommands12'
	(scatter `id' `right1' if `use' != 4 & `use' != 0,
	  msymbol(none) mlabel(`rightLB1') mlabcolor("0 0 0") mlabpos(3) mlabsize(`textSize'))
	(scatter `id' `right2' if `use' != 4 & `use' != 0,
	  msymbol(none) mlabel(`rightLB2') mlabcolor("0 0 0") mlabpos(3) mlabsize(`textSize'))
/* 	(scatter `id' `right2', mlabel(`use'))   JUNK, TO SEE WHAT'S WHERE */
/* LAST OF ALL PLOT EFFECT MARKERS TO CLARIFY AND OVERALL EFFECT LINE */
	(scatter `id' `effect' if `use' == 1, `pointopt' )
	, $MA_OTHEROPTS /* RMH added */ plotregion(margin(zero));

#delimit cr

end





program define getWidth
version 9.0

//	ROSS HARRIS, 13TH JULY 2006
//	TEXT SIZES VARY DEPENDING ON CHARACTER
//	THIS PROGRAM GENERATES APPROXIMATE DISPLAY WIDTH OF A STRING
//	FIRST ARG IS STRING TO MEASURE, SECOND THE NEW VARIABLE

//	PREVIOUS CODE DROPPED COMPLETELY AND REPLACED WITH SUGGESTION
//	FROM Jeff Pitblado

qui{

gen `2' = 0
count
local N = r(N)
forvalues i = 1/`N'{
	local this = `1'[`i']
	local width: _length "`this'"
	replace `2' =  `width' +1 in `i'
}

} // end qui

end
