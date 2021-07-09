/*  IPD forest plot post-estimation module by Evangelos Kontopantelis and David Reeves
    created in STATA v11.2
    v1.1, 10 Feb 2012
        - controlling for trial specific estimates for both intercept and baseline (fets - i. notation not allowed).
        - controlling for fixed common baseline
        - compatible with multiple imputation commands
        - compatible with bootstrap commands
        - increased allowed study label length
    v1.2, 13 Feb 2012
        - interaction terms option added with multiple outputs
        - corrected error when factor control/intervention variable was used (was returning not found as a random-effect error)
        - corrected error when fe variable was inputted in factor notation
        - should not be used with xi: xtmixed or xi: xtlogit since it was causing many problems. Users should generate the interactions manually,
          using the xi command before executing the regression command OR use the latest factor variable notation.
        - gsavedir gsavename eps gph (graph) options added
    v1.3, 12 Apr 2012
        - corrected graphs for binary/continuous interactions (only report studies of respective category)
    v1.4, 27 Sep 2012
        - continuous exposure variable allowed
        - included 'auto' option for running command in an easier way
        - added export option
    v1.5, 21 Jan 2013
        - Corrected tabulation error when exposure is continuous
        - Fixed hardcoded study identifier 'studyid', any acceptable variable name can now be used
        - Added small diamond for effects
    v1.6, 12 Apr 2014
        - Added CIs for I^2 and H^2: calculated from tau^2 estimate"
    v1.7, 29 June 2015
        - Added support for mixed (xtmixed) and meqrlogit (xtmelogit)
    v2.0, 25 April 2016
        - Added names to graphs so all remain available after execution
        - Improved the look of the graphs by using the _DISPGBY program used in metan
    v3.0, 12 April 2017
        - fully updated mi impute compatibility: using all imputations to plot study-specific effects
    v3.1, 21 January 2018
        - edited scalars to temp scalars to prevent some errors when users had similary names variables
*/

/*stata version define*/
version 11.0

/*IPDforest displays a forest plot following an xtmixed or similar estimation command*/
program define ipdforest, rclass
    /*command syntax*/
    syntax varlist (fv max=1 numeric), [fe(varlist fv min=1 numeric) re(varlist fv min=1 numeric) fets(namelist min=1 max=2) /*
    */ ia(varlist fv min=1 max=1 numeric) auto label(varlist min=1 max=2) or gsavedir(string) gsavename(string) eps gph export(string) /*
	*/ /*new options*/ NOPAUSE firstmi /*
	*/ /*new plot options*/ DP(integer 2) ASTEXT(integer 50) TEXTSize(real 100.0) /*
	*/ BOXSCA(real 100.0) noOVERALL NOHET NULL(real 999) NULLOFF NOWARNING XLAbel(passthru) /*
	*/ XTick(passthru) FORCE SUMMARYONLY EFFECT(string) FAVOURS(string) /*
	*/ DOUBLE BOXOPT(string) CLASSIC DIAMOPT(string) POINTOPT(string) CIOPT(string) /*
	*/ OLINEOPT(string) noSTATS noWT]
    /*temp variables used in all methods*/
    tempvar id sidrev weights xeff1 lo95CI1 up95CI1 outcvar2 tempdummy lblsize cnst xb1 esample
    tempfile tempf tempsave tempimp tempx
    tempname startpos endpos vcnt ipref fp cmdstrlen dumcnt tvlistcnt underscore catnum binexp ///
        vcnt intertype maxnum minnum intertype clsize iatype boolval tausq tausqlo tausqup tsq_pl_lo ///
        tsq_pl_up ssq regconst fcint maxstr ivBcnt ivCcnt effnum minval maxval numtot numcnt tempsc ///
        tempse zval feff mincat maxcat sumcat duminc dumbas xfets rsres dumint t1 t2 t3 t4 regconst ///
        fcint studynum casesnum cntr sfound dfres mltpl ztval Hsq Hsqlo Hsqup Isq Isqlo Isqup tstudynum sumweights
    forvalues j=1(1)10 {
        tempname cat`j' eff`j'se_ov eff`j'pe_ov eff`j' eff`j'se  eff`j'lo eff`j'up
    }
    forvalues i=1(1)200 {
        tempname stid`i'
        forvalues j=1(1)10 {
            tempname st`i'_`j'eff st`i'_`j'se st`i'_`j'lo st`i'_`j'up eff`j'se_st`i' eff`j'pe_st`i'
        }
    }

    /*INITIAL STUFF*/
    /*make sure xtmixed or xtmelogit has been executed first*/
    /*take into account multiple imputation commands*/
    di _newline(2)
    local temp = e(mi)
	local prefx ""
	capture drop labelvar
    if "`temp'"=="mi" {
        local cmloc = "cmd_mi"
        /*make sure -mi estimate- has been used with the -post- option*/
        if strpos(e(cmdline_mi),"post")==0 {
            di as error "ipdforest requires the use of the post option in mi estimate"
            error 301
        }
        if strpos(e(cmdline_mi),"esample")==0 {
            di as error "ipdforest requires the use of the esample() option in mi estimate"
            error 301
        }
        /*mi can only be flong or flongsep*/
        qui mi query
        if r(style)!="flong" & r(style)!="flongsep" {
            di as error "mi must be in long or flonsep format"
            error 301
        }
        /*get esample variable name*/
        local i=1
        while strpos(word(e(cmdline_mi),`i'),"esample")==0 {
            local i = `i'+1
        }
        local tvnm = word(e(cmdline_mi),`i')
        scalar startpos = strpos("`tvnm'","(")
        scalar endpos = strpos("`tvnm'",")")
        local tvnm = substr("`tvnm'",`=startpos+1',`=endpos-startpos-1')
        //full mi dataset and 1st dataset
        qui gen `esample'=`tvnm'
		qui save `tempimp', replace
		qui gen `id'=_mi_id
        qui mi extract 1, clear
		//if user has requested study estimates to be based on all imputations
		if "`firstmi'"=="" {
			local prefx "mi estimate, post coefl:"
		}
    }
    else {
        local cmloc = "cmd"
        qui gen `esample' = e(sample)
        qui save `tempimp', replace		
		if "`firstmi'"!="" {
			di as error "option firstmi can only be issued following multiple imputation"
			error 197
		}
    }
	qui count if `esample'==1
	if r(N)==0 {
        di as error "ipdforest uses e(sample) and needs to immediatelly follow an appropriate regression"
		di as error "command: re-run the regression model before issuing ipdforest"
        error 301	
	}	
    qui keep if `esample'==1
	
    if !inlist(e(`cmloc'), "xtmelogit","xtmixed","meqrlogit","mixed") {
        di as error "ipdforest works as a post-estimation command for xtmixed(mixed) or xtmelogit(meqrlogit)"
        error 301
    }
    local modelsel = e(`cmloc')

    if "`or'"!="" {
        if "`modelsel'"!="xtmelogit" & "`modelsel'"!="meqrlogit" {
    	   di as error "Odds Ratios can only be selected following the xtmelogit(meqrlogit) command"
    	   error 321
        }
        local orstr = "ORs"
        local plval = 1
    }
    else {
        local orstr = "coefficients"
        local plval = 0
    }
    /*get the study identifier - only one allowed*/
    if `=wordcount(e(ivars))'!=1 {
        di as error "Only a two-level random-effect structure is allowed"
        error 321
    }
    else {
        local clustervar = e(ivars)
    }
    local methtype = e(method)
    /*get outcome name*/
    local outcomevar = e(depvar)
    /*deal with exposure format (i.* or not)*/
    local var1 = "`varlist'"
    scalar vcnt = 1
    scalar ipref = 0
    if strpos("`var1'","i.")==1 {
        scalar ipref = 1
        local var1 = substr("`var1'",3,.)
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
		if "`or'"!=""{
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
	global MA_rjhby ""		/*BY option*/
	global rjhHetGrp ""
	global MA_summaryonly "`summaryonly'"
	global MA_params = 0	/*irrelevant - number of parameters as input in metan*/
	global IND=c(level)
	global MA_ESLA "`effect'"
	global MA_FAVOURS "`favours'"
	if "`effect'"=="" {
		local sumstat "ES" 
		if "`or'"!="" {
			local sumstat "OR"
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

    /*find beginning of random effects substring*/
    scalar fp = strpos(e(cmdline),"||")
    /*the auto option*/
    if "`auto'"!="" {
        /*make sure conflicting options are not given*/
        if "`fe'"!="" | "`re'"!="" | "`fets'"!="" | "`ia'"!="" {
    	   di as error "auto option cannot be executed with fe(), re(), fets() or ia()"
    	   error 197
        }
        /*check length of command line string - if 245 it's over the limit*/
        scalar cmdstrlen = length("`e(cmdline)'")
        if cmdstrlen >= 244 {
    	   di as error "Previous command info string over the limit and the auto option cannot be used"
    	   error 197
        }
        else {
            /*identify settings - need to be compatible with mi estimate*/
            /*RE*/
            local substr2 = e(revars)
            /*remove exposure*/
            local substr2 = subinstr("`substr2'","`var1'","",.)
            local substr2 = trim("`substr2'")
            local substr2 = itrim("`substr2'")
            /*get in words*/
            forvalues i=1(1)`=wordcount("`substr2'")' {
                local reff`i' = word("`substr2'",`i')
            }
            /*FE and FETS*/
            local substr1 = "`=substr(e(cmdline),1,fp-1)' "
            /*remove model*/
            local substr1 = subinstr("`substr1'","`modelsel'"," ",.)
            /*remove outcome, exposure*/
            foreach x in outcomevar var1 {
                local substr1 = subinstr(" `substr1'"," ``x'' "," ",.)
            }
            /*remove random effects*/
            forvalues i=1(1)`=wordcount("`substr2'")' {
                local substr1 = subinstr(" `substr1'"," `reff`i'' "," ",.)
            }

            /*re - the easiest*/
            local re = "`substr2'"
            /*fets - study intercepts (i* format)*/
            local fets=""
            if strpos("`substr1'", "i."e(ivars))>0 {
                local fets = e(ivars)
                /*remove from independent var string*/
                local substr1 = subinstr(" `substr1'"," i.`=e(ivars)' "," ",.)
            }
            /*everything else is expanded fets (underscore), fixed effect, or interaction*/
            local fe=""
            local ia=""
            scalar dumcnt = 0
            forvalues i=1(1)`=wordcount("`substr1'")' {
                local tempword = word("`substr1'",`i')
                /*need to see if it's an interaction term here since can't use descr*/
                if (strpos("`tempword'","*")>0 & strpos("`tempword'",".")>0) | strpos("`tempword'","#")>0 {
                    local itemp = "`tempword'"
                    foreach x in "*" "#" "i.`var1'" "c." "`var1'" {
                        local itemp = subinstr("`itemp'","`x'","",.)
                    }
                    if "`ia'"=="" {
                        local ia = "`itemp'"
                    }
                    else {
                	    di as error "auto option allows only one interaction term"
                	    di as error "set ipdforest manually if your model includes more"
                	    error 197
                    }
                }
                /*if it's a factor variable - can be fe / ia only*/
                else if (strpos("`tempword'","i.")>0 & strpos("`tempword'","*")==0) & strpos("`tempword'","#")==0 {
                    /*dummy variables interaction notation*/
                    if strpos("`tempword'","X")>0 & strpos("`tempword'","_I")>0 {
                	    di as error "auto option not compatible with dummy variable interaction notation"
                	    di as error "set ipdforest manually or use interaction notation (fv preferable)"
                	    error 197
                    }
                    /*if not interaction probably a fe*/
                    else {
                        if strpos("`tempword'","_")>0 {
                    	    di as error "ipdforest does not allow the use of underscores in fe covariate names"
                    	    di as error "please rename variable `tempword' if included as fixed-effect covariate"
                            di as error "if variable to be included unders fets, include with other study-specific variables,"
                            di as error "e.g. dept0s_* or dept0s_1-dept0s_16"
                    	    error 197
                        }
                        local fe = "`fe' `tempword'"
                    }
                }
                /*for everything else*/
                else {
                    qui descr `tempword', varlist
                    /*get the returned varlist and use - should be either 1 or stdnum (or the string might be 243 char long...)*/
                    local tvlist = r(varlist)
                    scalar tvlistcnt = length(r(varlist))
                    /*if there's only one word - either fixed effect or not allowed interaction*/
                    if wordcount(r(varlist))==1 {
                        /*dummy variables interaction notation*/
                        if strpos("`tempword'","X")>0 & strpos("`tempword'","_I")>0 {
                    	    di as error "auto option not compatible with dummy variable interaction notation"
                    	    di as error "set ipdforest manually or use interaction notation (fv preferable)"
                    	    error 197
                        }
                        /*if not interaction probably a fe*/
                        else {
                            if strpos("`tempword'","_")>0 {
                        	    di as error "ipdforest does not allow the use of underscores in fe covariate names"
                        	    di as error "please rename variable `tempword' if included as fixed-effect covariate"
                                di as error "if variable to be included unders fets, include with other study-specific variables,"
                                di as error "e.g. dept0s_* or dept0s_1-dept0s_16"
                        	    error 197
                            }
                            local fe = "`fe' `tempword'"
                        }
                    }
                    /*if there are more than one words returned in the varlist then fets or fe*/
                    else {
                        /*if underscore in the first variable returned then assume fets*/
                        scalar undpos = strpos("`=word(r(varlist),1)'","_")
                        if undpos>0 {
                            local tmpstr = substr("`=word(r(varlist),1)'",1,undpos)
                            local fets = "`fets' `tmpstr'"
                        }
                        /*if no underscore assume fe*/
                        else {
                            /*need to grab them all*/
                            if tvlistcnt>=243 {
                        	    di as error "the auto option does not support such a long list of fe vars"
                        	    di as error "please set the ipdforest manually"
                        	    error 197
                            }
                            else {
                                forvalues j=1(1)`=wordcount(r(varlist)) {
                                    local fe = "`fe' `=word(r(varlist),`j')'"
                                }
                            }
                        }
                    }
                    /*end for number of returned variables by each word IF clause*/
                }
                /*end of interaction IF clause*/
            }
            /*end of word loop*/
            /*trim final strings just in case*/
            foreach x in fe fets re ia {
                local x = trim("``x''")
                local x = itrim("``x''")
            }
            di in green "Model specification identified through auto option:"
            foreach x in fe fets re ia {
                di in green _col(5) "`x':" _col(12) as res "``x''"
            }
        }
    }

    /*do not allow expanded form to make life simpler (eg checking if has been included as a random effect)*/
    else if strpos("`var1'","_")==1 {
        di as error "Exposure variable cannot be in expanded form"
        di as error "Use factor notation or include as is (eg group or i.group; not _Igroup_1)"
        error 197
    }
    /*make sure intervention variable is binary with value of 0 and 1 if included with an i.* prefix*/
    capture tab `var1'
    if _rc==0 {
        scalar catnum = r(r)
        if catnum<2 {
            di as error "No variation at all in exposure variable `var1'"
            error 197
        }
    }
    else {
        scalar catnum = .
    }
    /*assuming a binary exposure variable for now*/
    scalar binexp = 1
    qui sum `var1'
    /*if i.* prefix can only be binary*/
    if ipref==1 {
        if catnum!=2 | r(min)!=0 | r(max)!=1 {
            di as error "Variable `var1' (exposure) can only be binary in the expanded format (0=control, 1=intervention)"
            error 197
        }
        else {
            di as error "Warning:" _col(12) as res "Binary exposure variable `var1' used"
        }
    }
    /*if no prefix then can be binary or continuous*/
    else {
        if catnum==2 {
            if r(min)!=0 | r(max)!=1 {
                di as error "Binary variable `var1' (exposure)  needs to be coded as 0=control and 1=intervention"
                error 197
            }
            else {
                di as error "Warning:" _col(12) as res "Binary exposure variable `var1' used"
            }
        }
        else {
            di as error "Warning:" _col(12) as res "Continuous exposure variable `var1' used"
            scalar binexp = 0
        }
    }
    /*get all co-variates */
    local allvar = "`clustervar' `outcomevar' `var1'"
    /*add another list with no factor notation which will only be used in the variable comparison so no duplicates are given (var1 has been dealt with)*/
    local allvarnofv = "`clustervar' `outcomevar' `var1'"
    forvalues i=1(1)`=wordcount("`fe'")' {
        scalar vcnt = vcnt + 1
        local var`=vcnt' = word("`fe'",`i')
        local allvar = "`allvar' `var`=vcnt''"
        if strpos("`var`=vcnt''","i.")==1 {
            local allvarnofv = "`allvarnofv' `=substr("`var`=vcnt''",3,.)'"
        }
        else {
            local allvarnofv = "`allvarnofv' `var`=vcnt''"
        }
    }
    forvalues i=1(1)`=wordcount("`re'")' {
        scalar vcnt = vcnt + 1
        local var`=vcnt' = word("`re'",`i')
        local allvar = "`allvar' `var`=vcnt''"
        if strpos("`var`=vcnt''","i.")==1 {
            local tempvar = substr("`var`=vcnt''",3,.)
            local allvarnofv = "`allvarnofv' `tempvar'"
        }
        else {
            local tempvar = "`var`=vcnt''"
            local allvarnofv = "`allvarnofv' `tempvar'"
        }
        /*find if they are included as random effects in the model*/
        if strpos(substr(e(cmdline),fp,.),"`tempvar'")==0 {
            di as error "Warning:" _col(12) as res "RE variable `var`=vcnt'' not included as a random-effects.
            di as res _col(12)"Execution will continue since the command line might have been too long"
        }
    }
    /*fets not counted as variables since they might not be - however add a check*/
    scalar intertype=0  /*assume no interaction term included*/
    qui sum `clustervar' if `esample'==1
    scalar maxnum = r(max)
    scalar minnum = r(min)
    forvalues i=1(1)`=wordcount("`fets'")' {
        local fets`i' = word("`fets'",`i')
        capture confirm var `fets`i'', exact
        if _rc!=0 {
            /*if fets and an interaction assume they are linked, for now - will set to zero later if not the case*/
            if "`ia'"!="" scalar intertype=3
            /*trial specific variables*/
            forvalues j=`=minnum'(1)`=maxnum' {
                qui count if `clustervar'==`j' & `esample'==1
                scalar clsize = r(N)
                if clsize!=0 {
                    capture confirm var `fets`i''`j'
                    if _rc!=0 {
                        di as error "Required dummy variable `fets`i''`j' not found"
                        di as error "in option fets()"
                        error 197
                    }
                    qui sum `fets`i''`j' if `clustervar'!=`j' & `esample'==1
                    if r(min)!=0 | r(max)!=0 {
                        di as error "Required dummy variable `fets`i''`j' not defined correctly"
                        di as error "in option fets()"
                        error 197
                    }
                    qui sum `fets`i''`j' if `clustervar'==`j' & `esample'==1
                    if r(min)==0 & r(max)==0 {
                        di as error "Required dummy variable `fets`i''`j' not defined correctly"
                        di as error "in option fets()"
                        error 197
                    }
                    /*in case an interaction term has been added, run some more checks*/
                    if "`ia'"!="" {
                        local tempia = "`ia'"
                        if strpos("`tempia'","i.")==1 local tempia = substr("`tempia'",3,.)
                        qui count if `fets`i''`j'-`tempia'<10-6 & `clustervar'==`j' & `esample'==1
                        if r(N)!=clsize {
                            scalar intertype=0
                        }
                    }
                }
            }
        }
    }

    /*make sure a user doesn't give the same variable names*/
    forvalues i=1(1)`=wordcount("`allvarnofv'")-1' {
        forvalues j=`=`i'+1'(1)`=wordcount("`allvarnofv'")' {
            if "`=word("`allvarnofv'",`i')'"=="`=word("`allvarnofv'",`j')'" {
                di as error "Outcome, intervention, cluster variables and covariates need to be unique!"
                error 197
            }
        }
    }
    /*for the interaction option though the user must have given the variable either as a fixed or a random effect!*/
    scalar iatype = -1
    if "`ia'"!="" {
        local intervar = "`ia'"
        /*get without the i. prefix*/
        if strpos("`intervar'","i.")==1 {
            local intervar2 = substr("`intervar'",3,.)
            /*ia type clarify*/
            scalar iatype = 1           /*assume binary*/
            qui tab `intervar2' if `esample'==1
            if r(r)>2 scalar iatype = 2 /*categorical*/
        }
        /*if without the i prefix*/
        else {
            qui tab `intervar' if `esample'==1
            if r(r)==2 {
                scalar iatype = 1
            }
            else {
                /*ia type, continuous*/
                scalar iatype = 0
                /*issue a warning if not centered*/
                qui sum `intervar' if `esample'==1
                if abs(r(mean))>10^-3 {
                    di as error "Warning:" _col(12) as res "interaction continuous(?) variable `intervar' is not (sample mean) centered"
                }
            }
            local intervar2 = "`intervar'"
        }

        /*issue error if categorical variable not included in factor form*/
        if strpos("`intervar'","_I")==1 {
            di as error "Interaction variable cannot be in expanded form. Use factor notation for categorical"
            di as error "variables (eg i.age). Factor notation is acceptable for binary variables but not required"
            error 197
        }
        /*do not allow _I prefix at all since we use it later to make life easier (variables that use it will be dropped and will be a problem if
        they are not the ones involved in the interaction - I am using the _I prefix make finding the main effects variable names easier*/
        if  strpos("`fe'", "_I")>0 | strpos("`re'", "_I")>0 {
            di as error "When interaction option used, model variables are not allowed in _I prefix expansion form"
            di as error "Prefix is reserved for the interaction terms: use a different prefix or factor notation"
            error 197
        }
        /*examine if it has been included as a fixed, random or fixed trial specific effect - if neither issue error (must be in identical form)*/
        /*it cannot be both since we have already made sure variables are unique*/
        forvalues i=1(1)`=wordcount("`fe'")' {
            if  word("`fe'",`i')=="`intervar'" {
                scalar intertype=1
            }
        }
        forvalues i=1(1)`=wordcount("`re'")' {
            if  word("`re'",`i')=="`intervar'" {
                scalar intertype=2
            }
        }
        /*fets identification more complicated - has been done earlier in the fets check*/
        if intertype==0 {
            di as error "Var to be interacted with intervention must also be included in fe, re, or fets option"
            di as error "For fets option, dummy variable stub corresponding to the interaction variable is needed"
            di as error "e.g. fets(dept0s_) ia(dept0s) where dept0s_1 the dummy with baseline scores for study 1"
            di as error "in option ia()"
            error 197
        }
    }

    /*some extra checks for the variables*/
    forvalues i=1(1)`=vcnt' {
        local tempstr = "`var`i''"
        if strpos("`var`i''","i.")==1 {
            local tempstr = substr("`var`i''",3,.)
        }
        /*if it is a categorical variable*/
        if strpos("`var`i''","_I")==1 {
            local tempstr = substr("`var`i''",3,`=length("`var`i''")-4')
        }
        /*then check if it's in the regression command line*/
        if strpos(e(cmdline),"`tempstr'")==0 {
            di as error "Warning:" _col(12) as res "variable `tempstr' not found in the `modelsel' command line. Please make sure it was included."
            di as res _col(12)"Execution will continue since the command line might have been too long"
        }
        /*finally check that categorical or continuous variables are treated consistently across the 2 commands*/
        capture tab `tempstr'
        scalar boolval = 0
        if _rc!=0 {
            scalar boolval = 1
        }
        else {
            if r(r)>2 {
                scalar boolval = 1
            }
        }
        if boolval==1 & strpos("`var`i''","i.")==1 & strpos(e(cmdline),"`var`i''")==0 {
            di as error "Variable `tempstr' included as categorical in the forest plot but as continuous in `modelsel'"
            error 197
        }
        if boolval==1 & strpos("`var`i''","i.")==0 & strpos(e(cmdline),"i.`var`i''")>0 {
            di as error "Variable `tempstr' included as categorical in `modelsel' and as continuous in the forest plot"
            error 197
        }
    }
    if "`gsavedir'"!="" {
        /*first bit, needed*/
        capture mkdir "`gsavedir'"
        capture cd "`gsavedir'"
        if _rc!=0 {
            di as error "Specified directory does not exist and could not be created"
            di as error "in option gsave()"
            error 197
        }
        local findir = "`gsavedir'"
    }
    else {
        local findir `c(pwd)'
    }

    /*make sure the intervention variable is included as a random factor and get the location to use in variance grabbing at the end*/
    local foundre = 0
    forvalues i=1(1)`=wordcount(e(revars))' {
        if strpos(word(e(revars),`i'),"`var1'")>0 {
            local foundre = `i'
        }
    }
    if `foundre'==0 {
        di as error "Variable `var1' (exposure) not used as a random-effect in the `modelsel' model"
        error 197
    }
    else {
        /*capture some needed between and within study variance estimates to display in a table at the end*/
        scalar tausq = exp(2*_b[lns1_1_`foundre':_cons])
        scalar tsq_pl_lo = exp(2*(_b[lns1_1_`foundre':_cons] - abs(invnormal(0.5*(1-c(level)/100)))*_se[lns1_1_`foundre':_cons]))
        scalar tsq_pl_up = exp(2*(_b[lns1_1_`foundre':_cons] + abs(invnormal(0.5*(1-c(level)/100)))*_se[lns1_1_`foundre':_cons]))
        if "`modelsel'"=="xtmelogit" | "`modelsel'"=="meqrlogit" {
            scalar ssq = .
        }
        else {
            scalar ssq = exp(2*_b[lnsig_e:_cons])
        }
    }

    /*identify if it's a fixed common intercept model so that individual regressions can take that into account*/
    /*set to no now, but may be changed later*/
    local xtraopt = ""
    scalar regconst=0
    scalar fcint = 0

    estimates store mainreg
    /*supposed to follow an xtmixed command or equivalent - but e(sample) not there for mi estimate in this form and does not make sense to use*/
    if "`cmloc'"=="cmd" {
        qui keep if `esample'==1
    }

    /*create label temp variable*/
    if "`label'"=="" {
		capture drop labelvar
        capture decode `clustervar', generate(labelvar) maxlength(30)
        if _rc!=0 {
            capture gen str30 labelvar = string(`clustervar')
            if _rc!=0 {
                di as error "cluster variable `clustervar' cannot be a string variable"
                di as error "use 'encode' and re-run regression model"
                error 108
            }
        }
    }
    else {
        /*convert if needed to string variables*/
        forvalues i=1(1)`=wordcount("`label'")' {
            local lvar`i' = word("`label'",`i')
            qui capture confirm string var `lvar`i''
            if _rc!=0 {
                qui capture drop temp1
                qui gen temp1 = string(`lvar`i'')
                qui drop `lvar`i''
                qui rename temp1 `lvar`i''
            }
        }
        if wordcount("`label'")==1 {
            qui gen str30 labelvar = trim(`lvar1')
        }
        else {
            qui gen str30 labelvar = trim(`lvar1') + ", " + trim(`lvar2')
        }
    }
    /*size of largest string to be used in output widths*/
    qui gen `lblsize' = strlen(labelvar)
    qui sum `lblsize'
    scalar maxstr = max(r(max), 15)
    
    /*interactions? - get the variable names and counts*/
	qui save `tempx', replace
    if intertype!=0 {
        /*variables with the I prefix should not be present - leftovers from xi: xtmixed or xtlogit will be dropped*/
        /*slightly different approach for (binary and continuous) vs categorical - for binary we don't want the i prefix if present*/
		foreach fnm in tempimp tempx {
			qui use ``fnm'',clear
			if binexp==1 {
				/*if exposure is binary*/
				if iatype==2 {
					/*interaction with categorical*/
					qui xi i.`var1'*`intervar'
				}
				else {
					/*interaction with binary or continuous*/
					qui xi i.`var1'*`intervar2'
				}
			}
			else {
				/*if exposure is continuous*/
				if iatype==2 {
					/*interaction with categorical*/
					qui xi `intervar'*`var1'
				}
				else if iatype==1 {
					/*interaction with binary*/
					qui xi i.`intervar2'*`var1'
					/*drop the dummy variable, not needed but no big deal - would be collinear in regression anyway*/
					capture drop _I`intervar2'_1
				}
				else {
					/*interaction with continuous - NOTE: the only way for this to work is if user creates interaction variable using certain criteria*/
					capture drop _I`var1'X`intervar2'
					qui gen _I`var1'X`intervar2' = `var1'*`intervar2'
				}
			}
			qui save ``fnm'', replace
		}
        qui descr _I*, varlist
        local interterms = r(varlist)
        /*identify exposure*/
        forvalues i=1(1)`=wordcount("`interterms'")' {
            if strpos("`=word("`interterms'",`i')'","_I`=substr("`var1'",1,9)'_")==1 {
                local ivA1 = "`=word("`interterms'",`i')'"
            }
        }
        /*identify the second variable*/
        scalar ivBcnt=0
        local ivB=""
        forvalues i=1(1)`=wordcount("`interterms'")' {
            if strpos("`=word("`interterms'",`i')'","_I`=substr("`intervar2'",1,9)'_")==1 {
                scalar ivBcnt=ivBcnt+1
                local ivB`=ivBcnt' = "`=word("`interterms'",`i')'"
                local ivB = "`ivB' `ivB`=ivBcnt''"
            }
        }
        /*remove the items already assigned just in case capital Xs are included in the variables*/
        if "`ivA1'"!="" {
            local interterms = subinstr("`interterms'", "`ivA1'","",.)
        }
        forvalues i=1(1)`=ivBcnt' {
            local interterms = subinstr("`interterms'", "`ivB`i''","",.)
        }
        local interterms = trim("`interterms'")
        /*identify the interaction terms*/
        scalar ivCcnt=0
        local ivC=""
        forvalues i=1(1)`=wordcount("`interterms'")' {
            if strpos("`=word("`interterms'",`i')'","X")>0 {
                scalar ivCcnt=ivCcnt+1
                local ivC`=ivCcnt' = "`=word("`interterms'",`i')'"
                local ivC = "`ivC' `ivC`=ivCcnt''"
            }
        }
    }
    /*debugging*/
    *di "`ivA1'"
    *di "`ivB'"
    *di "`ivC'"

    /*get the overall diamnond first before executing margins command*/
    /*different approach if intervention variable input with an i.*/
    scalar effnum = 1
    local iabits = ""
    capture scalar eff1 = _b[1.`var1']
    if _rc==0 {
        scalar eff1se = _se[1.`var1']
    }
    else {
        capture scalar eff1 = _b[`var1']
        if _rc==0 {
            scalar eff1se = _se[`var1']
        }
        else {
           /*still possible since i only issue a warning earlier if not in the command line*/
    	   di as error "Selected intervention variable not found in previous `modelsel' command"
    	   error 301
        }
    }
    scalar eff1lo = eff1 - abs(invnormal(0.5*(1-c(level)/100)))*eff1se
    scalar eff1up = eff1 + abs(invnormal(0.5*(1-c(level)/100)))*eff1se
    /*standard output when only main effect is nil*/
    local strout1 = ""
    local graphname1 = "main_`var1'"
    /*if interactions are there get the overall effect(s) for the interaction(s)*/
    if intertype!=0 {
        local strout1 = "Main effect (`var1')"
        /*for the forest plots*/
        if "`gsavedir'"!="" | "`gsavename'"!="" | "`eps'"!="" | "`gph'"!=""{
        /*if !missing("`gsavedir'`gsavename'`eps'`gph'") {*/
            set more off
        }
        else {
            set more on
        }

        /*BINARY EXPOSURE - interactions*/
        if binexp==1 {
            /*continuous interaction*/
            if iatype==0 {
                local strout2 = "Interaction effect (`var1' x `intervar2')"
                local graphname2 = "interaction_`var1'X`intervar2'"
                scalar effnum = 2
                tempvar xeff2 lo95CI2 up95CI2
                /*identify if it's fv format or xi expansion*/
                capture scalar eff2se = _se[0.`var1'#c.`intervar2']
                if _rc==0 {
                    /*we want the effect for category 1 so will reverse if it's there - if se is zero though pickup the effect from cat 1*/
                    if eff2se==0 {
                        scalar eff2 = _b[1.`var1'#c.`intervar2']
                        scalar eff2se = _se[1.`var1'#c.`intervar2']
                        /*hopefully will never happen*/
                        if eff2se==0 {
                            di as error "Could not find SE for the interaction - it seems to be zero"
                            error 197
                        }
                    }
                    else {
                        scalar eff2 = -_b[0.`var1'#c.`intervar2']
                    }
                }
                else {
                    capture scalar eff2 = _b[`ivC1']
                    if _rc==0 {
                        scalar eff2se = _se[`ivC1']
                    }
                    else {
                       /*probably not possilbe*/
                	   di as error "Interaction variable not found in previous `modelsel' command"
                	   error 301
                    }
                }
                scalar eff2lo = eff2 - abs(invnormal(0.5*(1-c(level)/100)))*eff2se
                scalar eff2up = eff2 + abs(invnormal(0.5*(1-c(level)/100)))*eff2se
                /*extra bit to be added to individual regressions - interaction variable and ia var (it might be added twice in regressions but no prob)*/
                local iabits = "`intervar2' `ivC1'"
            }
            /*categorical or binary interaction*/
            else if iatype==1 | iatype==2 {
                /*over-ride the main effect names*/
                qui sum `intervar2'
                scalar minval = r(min)
                scalar maxval = r(max)
                qui tab `intervar2'
                scalar numtot = r(r)
                scalar numcnt = 0
                /*make sure values are there and assign*/
                forvalues x=`=minval'(1)`=maxval' {
                    qui count if `intervar2'==`x'
                    /*if category found, it's another graph*/
                    if r(N)!=0 {
                        scalar numcnt = numcnt + 1
                        local strout`=numcnt' = "Main effect (`var1'), `intervar2'=`x'"
                        local graphname`=numcnt' = "main_`var1'_`intervar2'eq`x'"
                        /*get the categories into scalars since the numbering might not be continuous*/
                        scalar cat`=numcnt' = `x'
                    }
                }
                /*if not all categories are found, issue an error*/
                if numcnt!=numtot {
                    if iatype==1 {
                        di as error "Binary variable `intervar2' contains non-integer categories"
                    }
                    else {
                        di as error "Categorical variable `intervar2' contains non-integer categories"
                    }
                    error 301
                }
                /*total number of effects to be computed*/
                scalar effnum = numtot
    
                /*but also need to find out the format of the main effect coefficient*/
                capture scalar tempsc = _b[1.`var1']
                if _rc==0 {
                    local meffnot = "1.`var1'"
                }
                else {
                    local meffnot = "`var1'"
                }
                /*temp vars for each category*/
                forvalues x=2(1)`=effnum' {
                    tempvar xeff`x' lo95CI`x' up95CI`x'
                }
    
                /*identify if it's fv format or xi expansion*/
                capture scalar tempse = _se[0.`var1'#`=maxval'.`intervar2']
                /*fv format*/
                if _rc==0 {
                    /*it's fv format but if categorical or binary with an i. notation we should use 1.`var' - if binary without i. notation 0.`var*/
                    local tpre = "1."
                    forvalues x=1(1)`=effnum' {
                        if _se[0.`var1'#`=cat`x''.`intervar2']!=0 {
                            local tpre = "0."
                        }
                    }
                    /*if it's fv format go through all categories - overwriting eff1 etc in the process but easier code*/
                    forvalues x=1(1)`=effnum' {
                        if "`tpre'"=="1." {
                            qui test _b[`meffnot'] + _b[`tpre'`var1'#`=cat`x''.`intervar2'] = 0
                            scalar eff`x' = _b[`meffnot'] + _b[`tpre'`var1'#`=cat`x''.`intervar2']
                        }
                        else {
                            qui test _b[`meffnot'] - _b[`tpre'`var1'#`=cat`x''.`intervar2'] = 0
                            scalar eff`x' = _b[`meffnot'] - _b[`tpre'`var1'#`=cat`x''.`intervar2']
                        }
                        scalar zval = sqrt(r(chi2))
                        scalar eff`x'se = abs(eff`x'/zval)
                        scalar eff`x'lo = eff`x' - abs(invnormal(0.5*(1-c(level)/100)))*eff`x'se
                        scalar eff`x'up = eff`x' + abs(invnormal(0.5*(1-c(level)/100)))*eff`x'se
                    }
                }
                /*if it's an xi expansion*/
                else {
                    /*make sure that's the case*/
                    capture scalar tempsc = _b[`ivC1']
                    if _rc==0 {
                        /*if it's expansion format go through all categories - overwriting eff1 etc in the process but easier code*/
                        forvalues x=2(1)`=effnum' {
                            qui test _b[`meffnot'] + _b[`ivC`=`x'-1''] = 0
                            scalar eff`x' = _b[`meffnot'] + _b[`ivC`=`x'-1'']
                            scalar zval = sqrt(r(chi2))
                            scalar eff`x'se = abs(eff`x'/zval)
                            scalar eff`x'lo = eff`x' - abs(invnormal(0.5*(1-c(level)/100)))*eff`x'se
                            scalar eff`x'up = eff`x' + abs(invnormal(0.5*(1-c(level)/100)))*eff`x'se
                        }
                    }
                    else {
                       /*probably not possilbe*/
                	   di as error "Interaction variable not found in previous `modelsel' command"
                	   error 301
                    }
                }
                /*extra bit to be added to individual regressions - interaction variable and ia var (it might be added twice in regressions but no prob)*/
                if iatype==1 {
                    local iabits = "`intervar2' `ivC1'"
                }
                /*extra bit to be added to individual regressions - interaction variable binaries and interaction terms*/
                else {
                    local iabits = "`ivB' `ivC'"
                }
            }
        }
        /*end of binary exposure interactions*/

        /*CONTINUOUS EXPOSURE - interactions*/
        if binexp==0 {
            /*continuous interaction*/
            if iatype==0 {
                local strout2 = "Interaction effect (`var1' x `intervar2')"
                local graphname2 = "interaction_`var1'X`intervar2'"
                scalar effnum = 2
                tempvar xeff2 lo95CI2 up95CI2
                /*identify if it's fv format or xi expansion*/
                capture scalar eff2se = _se[c.`var1'#c.`intervar2']
                if _rc==0 {
                    if eff2se==0 {
                        di as error "Could not find SE for the interaction - it seems to be zero"
                        error 197
                    }
                    scalar eff2 = _b[c.`var1'#c.`intervar2']
                }
                else {
                    capture scalar eff2 = _b[`ivC1']
                    if _rc==0 {
                        scalar eff2se = _se[`ivC1']
                    }
                    else {
                       /*just in case*/
                	   di as error "Interaction variable (continuous by continuous) not found in previous `modelsel' command"
                	   di as error "Preferable option is to use the factor variable notation: c.`var1'#c.`intervar2'"
                	   di as error "Also supported a manually created interaction variable _I`var1'X`intervar2'"
                	   error 301
                    }
                }
                scalar eff2lo = eff2 - abs(invnormal(0.5*(1-c(level)/100)))*eff2se
                scalar eff2up = eff2 + abs(invnormal(0.5*(1-c(level)/100)))*eff2se
                /*extra bit to be added to individual regressions - interaction variable and ia var (it might be added twice in regressions but no prob)*/
                local iabits = "`intervar2' `ivC1'"
            }
            /*categorical or binary interaction*/
            /*some code duplication but i'm not bothered...*/
            else if iatype==1 | iatype==2 {
                /*over-ride the main effect names*/
                qui sum `intervar2'
                scalar minval = r(min)
                scalar maxval = r(max)
                qui tab `intervar2'
                scalar numtot = r(r)
                scalar numcnt = 0
                /*make sure values are there and assign*/
                forvalues x=`=minval'(1)`=maxval' {
                    qui count if `intervar2'==`x'
                    /*if category found, it's another graph*/
                    if r(N)!=0 {
                        scalar numcnt = numcnt + 1
                        local strout`=numcnt' = "Main effect (`var1'), `intervar2'=`x'"
                        local graphname`=numcnt' = "main_`var1'_`intervar2'eq`x'"
                        /*get the categories into scalars since the numbering might not be continuous*/
                        scalar cat`=numcnt' = `x'
                    }
                }
                /*if not all categories are found, issue an error*/
                if numcnt!=numtot {
                    if iatype==1 {
                        di as error "Binary variable `intervar2' contains non-integer categories"
                    }
                    else {
                        di as error "Categorical variable `intervar2' contains non-integer categories"
                    }
                    error 301
                }
                /*total number of effects to be computed*/
                scalar effnum = numtot

                /*here the format of the main effect coefficient can only be continuous*/
                /*temp vars for each category*/
                forvalues x=2(1)`=effnum' {
                    tempvar xeff`x' lo95CI`x' up95CI`x'
                }
                /*identify if it's fv format or xi expansion*/
                capture scalar tempse = _se[c.`var1'#`=maxval'.`intervar2']
                /*fv format*/
                if _rc==0 {
                    /*if it's fv format go through all categories - overwriting eff1 etc in the process but easier code*/
                    forvalues x=1(1)`=effnum' {
                        qui test _b[`var1'] + _b[`tpre'`var1'#`=cat`x''.`intervar2'] = 0
                        scalar eff`x' = _b[`var1'] + _b[c.`var1'#`=cat`x''.`intervar2']
                        scalar zval = sqrt(r(chi2))
                        scalar eff`x'se = abs(eff`x'/zval)
                        scalar eff`x'lo = eff`x' - abs(invnormal(0.5*(1-c(level)/100)))*eff`x'se
                        scalar eff`x'up = eff`x' + abs(invnormal(0.5*(1-c(level)/100)))*eff`x'se
                    }
                }
                /*if it's an xi expansion*/
                else {
                    /*make sure that's the case*/
                    capture scalar tempsc = _b[`ivC1']
                    if _rc==0 {
                        /*if it's expansion format go through all categories - overwriting eff1 etc in the process but easier code*/
                        forvalues x=2(1)`=effnum' {
                            qui test _b[`var1'] + _b[`ivC`=`x'-1''] = 0
                            scalar eff`x' = _b[`var1'] + _b[`ivC`=`x'-1'']
                            scalar zval = sqrt(r(chi2))
                            scalar eff`x'se = abs(eff`x'/zval)
                            scalar eff`x'lo = eff`x' - abs(invnormal(0.5*(1-c(level)/100)))*eff`x'se
                            scalar eff`x'up = eff`x' + abs(invnormal(0.5*(1-c(level)/100)))*eff`x'se
                        }
                    }
                    else {
                       /*probably not possilbe*/
                	   di as error "Interaction variable not found in previous `modelsel' command"
                	   error 301
                    }
                }
                /*extra bit to be added to individual regressions - interaction variable and ia var (it might be added twice in regressions but no prob)*/
                if iatype==1 {
                    local iabits = "`intervar2' `ivC1'"
                }
                /*extra bit to be added to individual regressions - interaction variable binaries and interaction terms*/
                else {
                    local iabits = "`ivB' `ivC'"
                }
            }
        }
        /*end of continuous exposure interactions*/
    }

    /*CALCULATIONS FOR FE and TRIAL SPECIFIC FE*/
    /*generate the temp outcome variable that will be updated if fe covariates are present - same across all studies*/
    qui gen double `xb1'=0
    if "`fe'"!="" {
        forvalues i=1(1)`=wordcount("`fe'")' {
            local fe`i' = word("`fe'",`i')
            /*try to capture the coefficient in its simplest form*/
            capture scalar feff = _b[`fe`i'']
            if _rc==0 {
                qui replace `xb1' = `xb1' + feff*`fe`i''
            }
            if _rc!=0 {
                if strpos("`fe`i''","i.")==1 {
                    local fe_`i' = substr("`fe`i''",3,.)
                    /*if it's categorical or binary (fv, not with the xi prefix - if xtmixed has been executed with xi: user expected to provide the
                    dummies in the varlist)*/
                    qui sum `fe_`i''
                    scalar mincat = r(min)
                    scalar maxcat = r(max)
                    scalar sumcat = r(N)
                    /*categories need to be integers*/
                    forvalues j=`=mincat'(1)`=maxcat' {
                        capture scalar feff = _b[`j'.`fe_`i'']
                        if _rc==0 {
                            qui gen `tempdummy' = 0
                            qui replace `tempdummy' = 1 if `fe_`i''==`j'
                            qui replace `xb1' = `xb1' + feff*`tempdummy'
                            qui drop `tempdummy'
                            /*make sure all values in the categorical variable have been accounted for - i.e. only integers are used*/
                            qui count if `fe_`i''==`j'
                            scalar sumcat = sumcat - r(N)
                        }
                    }
                    /*if all values not accounted for issue error - although xtmixed/xtlogit do not allow execution for non integer values*/
                    if sumcat!=0 {
              	        di as error "Categorical variable `fe_`i'' cannot contain non-integer values"
              	        di as error "and/or make sure you have included `fe_`i'' as a main effect"
              	        error 197
              	    }
                }
                else {
                    /*estimates not found and not in i. notation - shouldn't ever end up here but...*/
              	    di as error "Estimates for fixed-effect component `fe`i'' not found"
              	    error 301
                }
            }
        }
    }
    /*some info on the studies*/
    qui sum `clustervar'
    scalar maxnum = r(max)
    scalar minnum = r(min)
    scalar duminc = 0
    scalar dumbas = 0
    /*trial specific variables*/
    forvalues j=`=minnum'(1)`=maxnum' {
        /*if number corresponds to a study, go on*/
        qui count if `clustervar'==`j'
        if r(N)!=0 {
            /*now if the study is there see if there are trial specific fixed effects that need to be taken into account*/
            if "`fets'"!="" {
                forvalues i=1(1)`=wordcount("`fets'")' {
                    local fets`i' = word("`fets'",`i')
                    /*identify the format of the variable*/
                    capture confirm var `fets`i''
                    /*exact variable name found so should be intercept variable - the first one is the _cons one*/
                    if _rc==0 {
                        /*_cons is the intercept for the first study (_b[1.studyid]=0). _b[x.studyid]=difference of study x intercept compared to
                        study 1*/
                        capture scalar xfets = _b[_cons] + _b[`j'.`fets`i'']
                        /*if saved coeff does not correspond to study numbers, exit with error - impossible t0 happen?*/
                        if _rc!=0 {
                            /*houston we have a problem*/
                            di as error "Estimates for `fets`i'', study #`j', not found"
                            error 301
                        }

                        /*only change the prediction for the respective study*/
                        qui gen `tempdummy' = 0
                        qui replace `tempdummy' = 1 if `fets`i''==`j'
                        qui replace `xb1' = `xb1' + xfets*`tempdummy'
                        qui drop `tempdummy'
                        /*if we are in here it can only be the intercept variable - add the nocons option for the individual regressions*/
                        local xtraopt = "nocons"
                    }
                    else {
                        /*the altertative is for the user to provide the common part of the dummy variables, up until the number - but it might be
                        dummies for the intercept OR the baseline scores*/
                        capture scalar xfets = _b[`fets`i''`j']
                        scalar rsres=0
                        if _rc!=0 {
                            scalar rsres=1
                        }
                        /*if estimate is there, find out if it is a dummy variable or not - OK if 1st dummy estimate is not there*/
                        scalar dumint = 0
                        if rsres==0 {
                            qui sum `fets`i''`j' if `clustervar'!=`j'
                            scalar t1 = r(min)
                            scalar t2 = r(max)
                            qui sum `fets`i''`j' if `clustervar'==`j'
                            scalar t3 = r(min)
                            scalar t4 = r(max)
                            if t1==0 & t2==0 & t3==1 & t4==1 {
                                scalar dumint = 1
                                /*overall to use later - if intercept dummies were included*/
                                scalar duminc = 1
                            }
                        }
                        /*various issues for the first dummy intercept variable*/
                        if `j'==minnum {
                            /*if it is the first study and an estimate has not been found, assume it's the intercept one*/
                            if rsres==1 {
                                local xtraopt = "nocons"
                                scalar xfets = _b[_cons]
                                scalar rsres=0
                            }
                            /*if estimate was found and it was the fist dummy intercept, issue error*/
                            if rsres==0 & dumint==1 {
                                di as error "Please re-run the model, without including the intercept dummy for the first study"
                                error 197
                            }
                            /*note that baseline dummies were found*/
                            if rsres==0 & dumint==0 {
                                scalar dumbas=1
                            }
                        }
                        /*if it isn't the first variable, we need to correct estimates for intercept dummies*/
                        else {
                            if dumint==1 {
                                scalar xfets = _b[_cons] + _b[`fets`i''`j']
                            }
                        }
                        /*if at this point there still isn't an estimate then issue error*/
                        if rsres==1 {
                            di as error "Estimate not found for variable `fets`i''`j': dummy numbering must correspond to study numbers!"
                            error 301
                        }
                        /*at this stage we are done*/
                        else {
                            /*variable may not be there for intercept and first study*/
                            if `j'==minnum & dumint==1  {
                                qui gen `tempdummy' = 0
                                qui replace `tempdummy' = 1 if `clustervar'==`j'
                                qui replace `xb1' = `xb1' + xfets*`tempdummy'
                                qui drop `tempdummy'
                            }
                            else {
                                /*only change the prediction for the respective study since `fets`i'=0 for all other studies*/
                                qui replace `xb1' = `xb1' + xfets*`fets`i''`j'
                            }
                        }
                    }
                }
            }
        }
    }
    /*identify if it's a fixed common intercept model so that individual regression can take that into account*/
    /*if the cluster variable is not included as an independent AND trial-specific intercepts were not added as dummies*/
    if strpos(e(cmdline),"`clustervar'")>fp & strpos(e(cmdline),"nocons")>fp & duminc==0 {
        local xtraopt = "nocons"
        scalar regconst = _b[_cons]
        scalar fcint = 1
    }

    /*some info on the studies and create weights - generate a temp studyid var too*/
    qui tab `clustervar'
    scalar studynum = r(r)
    scalar casesnum = r(N)
    scalar cntr = 0
    scalar sfound = 0
    qui gen `sidrev'=.
    qui gen `weights'=.
    while sfound<studynum {
        scalar cntr = cntr + 1
        qui count if `clustervar'==cntr
        if r(N)>0 {
            scalar sfound = sfound + 1
            scalar stid`=sfound'=cntr
            qui replace `sidrev' = studynum-sfound+1 if `clustervar'==cntr
            qui replace `weights' = r(N)/casesnum if `clustervar'==cntr
        }
    }

    /*execute appropriate regression command - xtlogit or xtmelogit*/
    /*get effects and CIs for studies*/
	qui replace `xb1' = `xb1' + regconst
	//if mi data with all mi requested, reload and give it a try
	if "`firstmi'"=="" & "`cmloc'"=="cmd_mi" {
		qui keep `xb1' `id' `sidrev' `weights' labelvar
		rename `id' _mi_id
		qui save `tempf', replace
		qui use `tempimp', clear
		qui merge m:1 _mi_id using `tempf', nogen
	}
	qui gen `outcvar2' = `outcomevar' - `xb1'
	*sum `xb1' `outcomevar' `outcvar2'
    forvalues i=1(1)`=studynum' {
        if "`modelsel'"=="xtmixed" | "`modelsel'"=="mixed" {
            /*if xb1=0, no effect*/
            qui `prefx' regress `outcvar2' `var1' `re' `iabits' if `sidrev'==`i', `xtraopt'
            /*only for regress commands, find df residuals to be used in confidence intervals*/
            scalar dfres = e(df_r)
            scalar mltpl = invttail(e(df_r),0.025)
        }
        else {
            /*if xb1=0, no effect*/
            qui `prefx' logit `outcomevar' `var1' `re' `iabits' if `sidrev'==`i', offset(`xb1') `xtraopt'
            scalar mltpl = abs(invnormal(0.5*(1-c(level)/100)))
        }
		scalar st`i'_1eff = _b[`var1']
		scalar st`i'_1se = _se[`var1']
        scalar st`i'_1lo = st`i'_1eff-mltpl*st`i'_1se
        scalar st`i'_1up = st`i'_1eff+mltpl*st`i'_1se
        /*if se=0, i.e. coefficient cannot be estimated set to missing*/
        if st`i'_1se<=10^-10 {
            di as error "No variance in main effect for study `=stid`=studynum - `i' + 1'' - needs to be excluded from analysis"
            error 322
        }
        /*if continuous interaction - only one interaction variable*/
        if iatype==0 {
			scalar st`i'_2eff = _b[`ivC1']
			scalar st`i'_2se = _se[`ivC1']
            scalar st`i'_2lo = st`i'_2eff-mltpl*st`i'_2se
            scalar st`i'_2up = st`i'_2eff+mltpl*st`i'_2se
            if st`i'_2se<=10^-10 {
                di as error "No variance in continuous interaction for study `=stid`=studynum - `i' + 1'' - needs to be excluded from analysis"
                error 322
            }
        }
        /*if binary variable*/
        else if iatype==1 {
            qui test _b[`var1'] + _b[`ivC1'] = 0
            if "`modelsel'"=="xtmixed" | "`modelsel'"=="mixed" {
                scalar ztval = sqrt(r(F))
            }
            else {
                scalar ztval = sqrt(r(chi2))
            }
            scalar st`i'_2eff = _b[`var1'] + _b[`ivC1']
            scalar st`i'_2se = abs(st`i'_2eff/ztval)
            scalar st`i'_2lo = st`i'_2eff-mltpl*st`i'_2se
            scalar st`i'_2up = st`i'_2eff+mltpl*st`i'_2se
            if st`i'_2se<=10^-10 {
                di as error "No variance in binary interaction for study `i' - needs to be excluded from analysis"
                error 322
            }
        }
        else if iatype==2 {
            forvalues x=2(1)`=effnum' {
                qui test _b[`var1'] + _b[`ivC`=`x'-1''] = 0
                if "`modelsel'"=="xtmixed" | "`modelsel'"=="mixed" {
                    scalar ztval = sqrt(r(F))
                }
                else {
                    scalar ztval = sqrt(r(chi2))
                }
                scalar st`i'_`x'eff = _b[`var1'] + _b[`ivC`=`x'-1'']
                scalar st`i'_`x'se = abs(st`i'_`x'eff/ztval)
                scalar st`i'_`x'lo = st`i'_`x'eff-mltpl*st`i'_`x'se
                scalar st`i'_`x'up = st`i'_`x'eff+mltpl*st`i'_`x'se
                if st`i'_`x'se<=10^-10 {
                    di as error "No variance in categorical interaction for study `i' - needs to be excluded from analysis"
                    error 322
                }
            }
        }
        /*if binary or continuous variable, set to missing for categories that are not present in study*/
        if iatype==1 | iatype==2 {
            forvalues x=1(1)`=effnum' {
                qui count if `sidrev'==`i' & `intervar2'==cat`x'
                if r(N)==0 {
                    scalar st`i'_`x'eff = .
                    scalar st`i'_`x'se = .
                    scalar st`i'_`x'lo = .
                    scalar st`i'_`x'up = .
                }
            }
        }
    }

    /*if logistic and odds ratio was selected, make appropriate changes*/
    if "`or'"!="" {
        forvalues j=1(1)`=effnum' {
            forvalues i=1(1)`=studynum' {
                scalar st`i'_`j'eff = exp(st`i'_`j'eff)
                scalar st`i'_`j'lo = exp(st`i'_`j'lo)
                scalar st`i'_`j'up = exp(st`i'_`j'up)
            }
            scalar eff`j' = exp(eff`j')
            scalar eff`j'lo = exp(eff`j'lo)
            scalar eff`j'up = exp(eff`j'up)
        }
    }
	
    /*collapse data*/
	if "`firstmi'"=="" & "`cmloc'"=="cmd_mi" {
		mi extract 1, clear
	}	
    qui collapse (first) labelvar `var1' `sidrev' `weights', by(`clustervar')
	//through esample there may have been studies that are completely dropped and need to be removed here
	qui drop if labelvar==""	
    forvalues j=1(1)`=effnum' {
        qui gen `xeff`j''=.
        qui gen `lo95CI`j''=.
        qui gen `up95CI`j''=.
        forvalues i=1(1)`=studynum' {
            qui replace `xeff`j'' = st`i'_`j'eff if `sidrev'==`i'
            qui replace `lo95CI`j'' = st`i'_`j'lo if `sidrev'==`i'
            qui replace `up95CI`j'' = st`i'_`j'up if `sidrev'==`i'
        }
    }
    sort `sidrev'
    /*debugging*/
    *foreach x in sidrev weights xeff1 lo95CI1 up95CI1 xeff2 lo95CI2 up95CI2 {
    *    qui gen `x' = ``x''
    *}
	
    /*calculate heterogeneity measures*/
    /*I^2 and H^2 - from Higgins 2002 paper */
    /*scalar Hsq=(qw-(k-1))/(k-1)     relies on DL - not used*/
    scalar Hsq = (tausq + ssq)/ssq -1 /*this is H^2M as described by Mittlboeck*/
    scalar Hsqlo = (tsq_pl_lo + ssq)/ssq -1
    scalar Hsqup = (tsq_pl_up + ssq)/ssq -1
    foreach x in Hsq Hsqlo Hsqup {
        if `x'<0 scalar `x'=0
    }
    /*scalar Isq=100*(qw-(k-1))/qw   relies on DL method - not used*/
    scalar Isq = 100*(Hsq)/(Hsq+1)
    scalar Isqlo = 100*(Hsqlo)/(Hsqlo+1)
    scalar Isqup = 100*(Hsqup)/(Hsqup+1)
    foreach x in Isq Isqlo Isqup {
        if `x'<0 scalar `x'=0
    }	

	/*******************/
	/*DISPLAY START*/
	/*add the overall effect(s) as extra observation(s)*/
	qui set obs `=studynum+1'
	forvalues j=1(1)`=effnum' {
		qui replace `xeff`j'' = eff`j' in `=studynum+1'
		qui replace `lo95CI`j'' = eff`j'lo in `=studynum+1'
		qui replace `up95CI`j'' = eff`j'up in `=studynum+1'
	}
	qui replace `sidrev' = 0 in `=studynum+1'
	qui replace `clustervar' = 0 in `=studynum+1'
	/*label reversed ID variable*/
	forvalues i=1(1)`=studynum' {
		label define studynames `i' "`=labelvar[`i']'", add
	}
	label define studynames 0 "Overall effect", add
	label val `sidrev' studynames
	
	/*miltiple forest plots*/
	forvalues j=1(1)`=effnum' {
	
        /*save file since we will drop cases to deal with the binary/categorical interactions case*/
        qui save `tempf', replace
        scalar tstudynum = studynum
        qui count if `xeff`j''==.
        if r(N)>0 {
            qui drop if `xeff`j''==.
            qui count
            scalar tstudynum = r(N)-1
            gsort -`clustervar'
            qui drop `sidrev'
            qui egen `sidrev' = seq(), from(1) to(`=tstudynum')
            qui replace `sidrev'=0 if `clustervar'==0
            /*redo the labels*/
            label drop studynames
            forvalues i=1(1)`=tstudynum' {
                label define studynames `i' "`=labelvar[`i']'", add
            }
            label define studynames 0 "Overall effect", add
            label val `sidrev' studynames
        }

        /*since we have the dataset ready use to export*/
        if "`export'"!="" {
            qui save `tempsave', replace
            qui gen eff=`xeff`j''
            qui gen eff_lo=`lo95CI`j''
            qui gen eff_up=`up95CI`j''
            qui gen eff_se = (eff-eff_lo)/abs(invnormal(0.5*(1-c(level)/100)))
            qui gen weight = `weights'
            qui replace weight = 1 if `clustervar'==0
            qui gen efftype = `j'
            qui keep `clustervar' eff* weight
            /*if main effect save first*/
            if `j'==1 {
                qui save "`findir'\\`export'.dta", replace
                if "`strout1'"=="" {
                    local exlblstr = `"1 "Main effect (`var1')""'
                }
                else {
                    local exlblstr = `"1 "`strout1'""'
                }
            }
            else {
                qui append using "`findir'\\`export'.dta"
                qui save "`findir'\\`export'.dta", replace
                local exlblstr = `"`exlblstr' `j' "`strout`j''""'
            }
            /*add overall label at the end*/
            if `j'==`=effnum' {
                label var efftype "Effect type"
                label define efflbl `exlblstr'
                label val efftype efflbl
                sort efftype `clustervar'
                label define stid  0 "Overall", add
                label var eff "Effect"
                label var eff_lo "Effect, lower CI"
                label var eff_up "Effect, upper CI"
                label var eff_se "SE of the effect"
                label var weight "meta-analysis weight"
                qui save "`findir'\\`export'.dta", replace
            }
            qui use `tempsave', clear
        }
	
		//tables
        di as text _newline(2) "One-stage meta-analysis results using `modelsel' (`methtype' method) and ipdforest"
        di as text "`strout`j''"
        di as text "{hline `=maxstr+1'}{c TT}{hline `=maxstr+25'}
        di as text "{col 9}Study{col `=maxstr+2'}{c |}{col `=maxstr+6'}Effect{col `=maxstr+15'}[95% Conf. Interval]{col `=maxstr+37'} % Weight"
        di as text "{hline `=maxstr+1'}{c +}{hline `=maxstr+25'}
        forvalues i=`=tstudynum'(-1)1 {
            di as text labelvar[`i'] "{col `=maxstr+2'}{c |}" as result _col(`=maxstr+5') %7.3f `xeff`j''[`i'] _col(`=maxstr+16') %7.3f `lo95CI`j''[`i'] /*
            */_col(`=maxstr+26') %7.3f `up95CI`j''[`i'] _col(`=maxstr+37') %7.2f `weights'[`i']*100
        }
        di as text "{hline `=maxstr+1'}{c +}{hline `=maxstr+25'}
        qui sum `weights'
        scalar sumweights = 100*r(sum)
        di as text %-20s "Overall effect {col `=maxstr+2'}{c |}" as result _col(`=maxstr+5') %7.3f `xeff`j''[`=tstudynum+1'] _col(`=maxstr+16') /*
        */ %7.3f `lo95CI`j''[`=tstudynum+1'] _col(`=maxstr+26') %7.3f `up95CI`j''[`=tstudynum+1'] _col(`=maxstr+37') %7.2f sumweights
        di as text "{hline `=maxstr+1'}{c BT}{hline `=maxstr+25'}		

		/*NEW FOREST PLOT START*/
		//edits and options
		qui replace `weights'=`weights'*100
		tempvar rawdata tau2 df use
		//linked to unused option COUNTS
		qui gen str1 `rawdata'=""
		//linked to unused option RFDIST
		qui gen `tau2'=.
		qui gen `df'=.
		qui gen `use'=1
		//additional globals - post analyses
		global MA_method1 "`methtype'"
		global MA_method2 "`modelsel'"
		/*add the overall effect as an extra observation if requested*/
		if "`overall'"=="" {
			qui replace `sidrev' = 0 in `=tstudynum+1'
			qui replace `clustervar' = 0 in `=tstudynum+1'				
			qui sum `weights'
			qui replace `weights'=r(sum) in `=tstudynum+1'
			qui replace `use'=5 in `=tstudynum+1'
			
			qui replace `tau2' = tausq in `=tstudynum+1'
			qui replace `df' = studynum in `=tstudynum+1'
			if "$MA_nohet" != "" {
				qui replace labelvar="Overall" in `=tstudynum+1'
			}
			else {
				qui replace labelvar="Overall  (I^2=" + string(Isq,"%5.1f") + "%)" in `=tstudynum+1'
			}		
			qui sum `clustervar'
			qui replace `clustervar'=r(max)+1 in `=tstudynum+1'
		}			
		sort `use' `clustervar'
		//list `clustervar' labelvar `use'
		//list `clustervar' labelvar `use', nolabel
		//call new graph
		_dispgby `xeff`j'' `lo95CI`j'' `up95CI`j'' `weights' `use' labelvar `rawdata' `tau2' `df', `log'    /*
		*/ `xlabel' `xtick' `force' sumstat(`sumstat') `saving' `box' t1("`t1'") /*
		*/ t2("`t2'")  b1("`b1'") b2("`b2'") lcols("`lcols'") rcols("`rcols'") `overall' `wt' `stats' `xcounts' `eform' /*
		*/ `groupla' `cornfield'
		
		//rename graph so all can remain open
		qui graph rename Graph`j', replace
		
        di "`findir'"
        di "`gsavename'"
        /*save if one of the save options provided*/
        if "`gsavedir'"!="" | "`gsavename'"!="" | "`eps'"!="" | "`gph'"!="" {
            if "`eps'"!="" {
                qui graph export "`findir'\\`gsavename'_`graphname`j''.eps", replace
            }
            if "`eps'"=="" | "`gph'"!="" {
                qui graph save "`findir'\\`gsavename'_`graphname`j''.gph", replace
            }
        }		
		
        /*load file*/
        qui use `tempf', clear
        /*add a pause*/
        if `j'<effnum {
            more
        }				
	}
    label drop studynames

    /*more displays*/
    di as text _newline(2) "Heterogeneity Measures"
    /*cochran's Q*/
    di as text "{hline 15}{c TT}{hline 35}
    di as text "{col 16}{c |}{col 22}value{col 30}[95% Conf. Interval]"
    di as text "{hline 15}{c +}{hline 35}
    di as text %15s "I^2 (%) {col 16}{c |}" as result _col(20) %8.2f Isq /*
    */ _col(29) %8.2f Isqlo _col(38) %8.2f Isqup
    di as text %15s "H^2 {col 16}{c |}" as result _col(20) %8.2f Hsq /*
    */ _col(29) %8.2f Hsqlo _col(38) %8.2f Hsqup
    di as text %15s "tau^2 est {col 16}{c |}" as result _col(20) %8.3f tausq /*
    */ _col(29) %8.3f tsq_pl_lo _col(38) %8.3f tsq_pl_up
    di as text "{hline 15}{c BT}{hline 35}

    /*return list*/
    return scalar Isq = Isq
    return scalar Isqlo = Isqlo
    return scalar Isqup = Isqup
    return scalar Hsq = Hsq
    return scalar Hsqlo = Hsqlo
    return scalar Hsqup = Hsqup
    return scalar tausq = tausq
    return scalar tausqlo = tsq_pl_lo
    return scalar tausqup = tsq_pl_up
    forvalues i=`=studynum'(-1)1 {
        local ntmp = studynum - `i' + 1
        return scalar eff1se_st`=stid`ntmp'' = st`i'_1se
        return scalar eff1pe_st`=stid`ntmp'' = st`i'_1eff
    }
    return scalar eff1se_ov = eff1se
    return scalar eff1pe_ov = eff1
    forvalues j=2(1)`=effnum' {
        forvalues i=`=studynum'(-1)1 {
            local ntmp = studynum - `i' + 1
            return scalar eff`j'se_st`=stid`ntmp'' = st`i'_`j'se
            return scalar eff`j'pe_st`=stid`ntmp'' = st`i'_`j'eff
        }
        return scalar eff`j'se_ov = eff`j'se
        return scalar eff`j'pe_ov = eff`j'
    }
    /*load original dataset*/
    qui use `tempimp', clear
    /*return individual study effects in matrix in the future*/
    /*restore xtmixed results*/
    qui estimates restore mainreg
end

/*version 11.1
mata:
void xxx
    X=(st1_1eff,st1_1se)
    for (i=2; i<=studynum; i++) {
        X=(X\(st`=i'_1eff,st`=i'_1se))
    }
end*/


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
	gen `wtdisp'=`8' 
}
else { 
	gen `wtdisp'=`weight' 
}

if "`10'" != "" & "$MA_rjhby" != ""{
	tempvar tau2 df
	gen `tau2' = `9'
	gen `df' = `10'
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
	if ( ("`sumstat'"=="OR" | "`sumstat'"=="RR") & ("`log'"=="") ) | ("`eform'"!="") {
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
if (( ("`sumstat'"=="OR" | "`sumstat'"=="RR") & ("`log'"=="") ) | ("`eform'"!="")) {
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




