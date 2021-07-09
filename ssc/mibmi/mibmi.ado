/*v1.0 3Oct2014*/
program define mibmi, rclass
	/*stata version define*/
	version 12.1

	/*command syntax*/
    syntax varlist (min=3 max=4 numeric), [weight(varname numeric) height(varname numeric) clean xclean xclnp(real -127) xnomi xsimp minum(integer -127) /*
    */ IXTRapolate RXTRapolate imnar(real -1277) xmnar(real -1277) pmnar milng seed(integer 7) uplim(real 210) lolim(real 8) nodi force]
    tempfile tempf tempg h2 h1 tfX tf1 tf2
	tempvar Height2 tempid heightfin tvar timev tempw tempip tempip2 linpred crpvar3 crpvar3a crpvar3b numobs tmdist
	tempvar tmptid
	tempname xcnt0 xcnt1 intrpat dioutp
	tempname tmat1 tmat2 tmat3 extrpat
	tempname newpred prblm
	/*inputs*/
	/*main variables: patid, time, BMI, age(optional) - in that order*/
	/*note that if age is not provided it is assumed all cases are adults (i.e. no changes in height)*/
	scalar nmnvar=wordcount("`varlist'")
    forvalues i=1(1)`=nmnvar' {
        local var`i' = word("`varlist'",`i')
    }
	/*weight and height*/
	scalar wehe=0
	if "`weight'"!="" & "`height'"!="" {
		local varWx="`weight'"
		local varHx="`height'"
		scalar wehe=1
	}
	else if "`weight'"!="" | "`height'"!="" {
		di as error "Both height (in m) and weight (in kg) need to be provided or neither"
        error 197	
	}
	/*multiple imputations number*/
	scalar numimp=0
    if `minum'!=-127 {
		if `minum'<1 {
			di as error "Number of imputed datasets needs to be at least one: minum(k) needs k>=1"
			error 197
    	}
    	scalar numimp=`minum'
    }
	/*seed number*/
	set seed `seed'
	/*clean option*/
	scalar clnop=0
	if "`clean'"!="" {
		scalar clnop=1
	}
	/*xclean option*/
	scalar xclnop=0
	if "`xclean'"!="" {
		scalar xclnop=1
		/*implies clean as well*/
		scalar clnop=1
		//see if threshold provided - if not set to 0.5
        if `xclnp'==-127 {
            local xclnp=0.5
        }
        else {
            //allow range (0,10] i.e. (0% to 1000%)
            if `xclnp'<=0 | `xclnp'>10 {
    			di as error "Regression cleaning threshold needs to be in the (0,10]  range 0.5 (i.e. 50% change) the default"
	   		    error 197
            }
        }
	}
	else {
        if `xclnp'!=-127 {
			di as error "Regression cleaning not requested yet threshold parameter provided!"
			error 197
        }
    }
	/*extrapolate option*/
	local extrp=0
	if "`ixtrapolate'"!="" {
		local extrp=1
        if "`rxtrapolate'"!="" {
			di as error "Either ipolate or regression extrapolation can be selected, not both!"
			error 197
        }
	}
	else {
       if "`rxtrapolate'"!="" {
            local extrp=2
        }
    }
    /*MNAR assumptions options*/
    //interpolations
    if `imnar'!=-1277 {
        //limit to [-50,+50] or [-200%,+200%]
		if "`pmnar'"=="" {
            if `imnar'<-50 | `imnar'>50 {
			    di as error "MNAR value assumption for interpolations needs to be in the [-50,+50] range"
			    error 197
			}
    	}
    	else {
            if `imnar'<-0.9 | `imnar'>0.9 {
			    di as error "MNAR percentage assumption for interpolations needs to be in the [-0.9,+0.9] range (i.e. -90% to 90%)"
			    error 197
			}
        }
    }
    //extrapolations
    if `xmnar'!=-1277 {
        //limit to [-50,+50] or [-90%,+90%]
		if "`pmnar'"=="" {
            if `xmnar'<-50 | `xmnar'>50 {
			    di as error "MNAR value assumption for extrapolations needs to be in the [-50,+50] range"
			    error 197
			}
    	}
    	else {
            if `xmnar'<-0.9 | `xmnar'>0.9 {
			    di as error "MNAR percentage assumption for extrapolations needs to be in the [-0.9,+0.9] range (i.e. -90% to 90%)"
			    error 197
			}
        }
    }
    local percmnr=0
	if "`pmnar'"!="" {
        local percmnr=1
    }
	//upper and lower limits
	global xlolim = `lolim'
	global xuplim = `uplim'
	/*no imputations option i.e. just cleaning*/
	local nimp=0
	if "`xnomi'"!="" {
		local nimp=1
		if clnop==0 & xclnop==0 {
			di as error "Command will not clean or impute data: it needs to do something!"
			error 197
    	}
		if `extrp'!=0 | numimp!=0 | `seed'!=7 | "`milng'"!="" | `imnar'!=-1277 | `xmnar'!=-1277 | "`pmnar'"!="" {
			di as error "No imputations requested yet imputation parameters provided!"
			error 197
    	}
	}
	/*simple imputation option - no errors and no multiple imputation*/
	local splimp=0
	if "`xsimp'"!="" {
		local splimp=1
		//can not work when issued with the xnomi option
		if `nimp'==1 {
			di as error "Simple imputation (xsimp) option cannot be issued with the no mi option (xnomi)"
			error 197
		}
    	//all mi parameters are not allowed (except for extrapolation parameters)
		if numimp!=0 | `seed'!=7 | "`milng'"!="" | `imnar'!=-1277 | `xmnar'!=-1277 | "`pmnar'"!="" {
			di as error "Simple imputations requested yet multiple imputation parameters provided!"
			error 197
    	}
	}
	//if mi requested set default number to 5
	if "`xnomi'"=="" & "`xsimp'"=="" {
        //if imputation have been requested and no mi number has been provided set to 5
        if numimp==0 {
            scalar numimp=5
        }
    }
    else {
		local nimp=1
	}
	//save original variable
	capture gen _`var3'=`var3'
	if _rc!=0 {
		if "`force'"!="" {
			qui drop _`var3'
			qui gen _`var3'=`var3'
		}
		else {
			di as error "Backup variable _`var1' already exists. Drop or use the 'force' option"
			error 197			
		}
	}

	/*display*/
	scalar `dioutp'=1
	qui set more off
	if "`nodi'"!="" {
		qui set more on
		scalar `dioutp'=0
	}
	/*mi settings if imputations have been requested*/
	if `nimp'==0 {
		qui mi set wide
		capture mi unregister `var3' `var1' `var2' `var4'
		qui mi register imputed `var3'
		//qui mi register system ???
		qui mi register regular `var1' `var2' `var4'
		qui mi set M=`=numimp'
	}

	/*if weight-height provided*/
	if wehe==1 {
		qui gen `Height2' = sqrt(`varWx'/`var3')
	}
	else {
		qui gen `Height2' = .
	}
	/*clean option*/
	if clnop==1 {
		/*BMI*/
		/*if quite extreme BMI drop - http://en.wikipedia.org/wiki/List_of_the_heaviest_people*/
		qui replace `var3'=. if `var3'>$xuplim
		/*age doesn't have a tremendous effect on BMI: http://www.rcpch.ac.uk/system/files/protected/page/GIRLS%20and%20BOYS%20BMI%20CHART.pdf*/
		qui replace `var3'=. if `var3'<$xlolim
		/*if height and weight provided*/
		if wehe==1 {
			/* discard wrong values if clean option provided*/
			foreach x of varlist `varHx' `Height2' {
				qui replace `x'=. if `x'>2.3 & `x'!=.
				/*range for little people is supposed to be 2’8 (approx 81cm) to 4’8: http://www.lpaonline.org/faq- */
				if nmnvar==4 {
					/*limit to age 10*/
					qui replace `x'=. if `x'<0.81 & `var4'>=10
				}
				else {
					/*no age limit*/
					qui replace `x'=. if `x'<0.81
				}
			}
			/*if quite extreme weight drop*/
			qui replace `varWx'=. if `varWx'>500
			if nmnvar==4 {
				qui replace `varWx'=. if `varWx'<15 & `var4'>=10
			}
			else {
				qui replace `varWx'=. if `varWx'<20
			}
		}
	}
	//maybe cleaned already - this allows imputations to be within the "clean" range
	else {
        qui sum `var3'
        if r(min)>=$xlolim & r(max)<=$xuplim {
            scalar clnop=1
        }
    }
	qui compress
	qui save `tempf', replace

	/*longitudingal height analysis*/
	/*if weight-height have been inputed and extra clean option selected*/
	if xclnop==1 & wehe==1 {
		/*using calculated height (from BMI-weight)*/
		qui use `tempf', clear
		/*if age is provided limit to age 18+*/
		if nmnvar==4 {
			qui keep if `var4'>=18
		}
		qui keep `var1' `var2' `Height2'
		qui drop if `Height2'==.
		gsort `var1' `var2'
		qui collapse (median) medheight2=`Height2' (last) lastheight2=`Height2' (count) cntr2=`Height2', by(`var1')
		qui save `h2', replace
		/*using reported weight*/
		qui use `tempf',clear
		/*if age is provided limit to age 18+*/
		if nmnvar==4 {
			qui keep if `var4'>=18
		}
		qui keep `var1' `var2' `varHx'
		qui drop if `varHx'==.
		gsort `var1' `var2'
		qui collapse (median) medheight=`varHx' (last) lastheight=`varHx' (count) cntr=`varHx', by(`var1')
		qui save `h1', replace
		qui merge 1:1 `var1' using `h2'
		/*generate final height variable*/
		qui gen `heightfin' = .
		/*priority to height measurements*/
		qui replace `heightfin'=lastheight if cntr<=2
		qui replace `heightfin'=medheight if cntr>2
		/*if height measurement is missing try guessing actual height*/
		/*trust measurements if median and last agree*/
		qui replace `heightfin'=lastheight2 if cntr==. & cntr2!=. & abs(medheight2-lastheight2)<=0.1
		/*if they don't agree trust last measurement if cntr2<=2*/
		qui replace `heightfin'=lastheight2 if cntr==. & cntr2<=2 & abs(medheight2-lastheight2)>0.1
		/*if they don't agree trust median if cntr2>=3*/
		qui replace `heightfin'=medheight2 if cntr==. & cntr2>2 & abs(medheight2-lastheight2)>0.1
		/*error checking
		list if (abs(medheight-lastheight)>0.1 | abs(medheight2-lastheight2)>0.1 | abs(medheight-medheight2)>0.1 | abs(lastheight-lastheight2)>0.1) & _merge==3
		*/
		/*new get the final height info to the dataset and update*/
		qui keep `var1' `heightfin'
		qui merge 1:m `var1' using `tempf'
		qui drop _merge
	}
	gsort `var1' `var2'
	/*generate a temp variable for patient ID, for easier access*/
	qui egen `tempid' = group(`var1')
	qui sum `tempid'
	scalar patnum = r(max)
	/*generate a temp variable for time, for easier access*/
	qui egen `timev' = group(`var2')
	qui tab `timev'
	scalar timepoints = r(r)
	/*need at least 3 time points across*/
	if timepoints<3 {
		di as error "mibmi needs at least three time points in order to assess variability"
        error 197
	}

	/*extra cleaning*/
	if xclnop==1 {
		/*get a potentially more reliable BMI from cleaned weight and height*/
		if wehe==1 {
			/*if age var provided limit to ages 18+*/
			if nmnvar==4 {
				qui replace `var3'=`varWx'/(`heightfin'^2) if `var4'>=18 & `varWx'!=. & `heightfin'!=.
			}
			else {
				qui replace `var3'=`varWx'/(`heightfin'^2) if `varWx'!=. & `heightfin'!=.
			}
		}
		/*if quite extreme BMI drop - http://en.wikipedia.org/wiki/List_of_the_heaviest_people*/
		qui replace `var3'=. if `var3'>200
		/*age doesn't have a tremendous effect on BMI: http://www.rcpch.ac.uk/system/files/protected/page/GIRLS%20and%20BOYS%20BMI%20CHART.pdf*/
		qui replace `var3'=. if `var3'<9
		/*patient loop for BMI*/
		forvalues i=1(1)`=patnum' {
			qui sum `var3' if `tempid'==`i'
			scalar obsnum = r(N)
			/*three or more observations regress and drop odd observations - differences to predictions above X% (default is 50%) of observed are dropped*/
			if obsnum>=3 {
				qui regress `var3' `var2' if `tempid'==`i'
				qui predict `tvar' if e(sample), residual	/*observed minus prediction*/
				qui replace `var3'=. if abs(`tvar')/`var3'>=`xclnp' & obsnum>=3 & `tempid'==`i'
				qui drop `tvar'
			}
			/*display*/
			if `dioutp'==1 {
				if `i'==1 {
					di as text "Regression cleaning, patients completed (1000s of `=patnum'):"
				}
				if mod(`i',1000)==0 {
					di as result "." _continue
				}
				if mod(`i',50000)==0 | `i'==patnum {
					di `i'
				}
			}
		}
	}
	sort `var1' `var2'
	qui compress
	qui save `tempf', replace

	/*if simple imputation is requested*/
	if `splimp'==1 {
		/*interpolate values to use in getting an estimate of change*/
		sort `var1' `var2'
		qui by `var1': ipolate `var3' `var2', g(`tempip')
		/*also extrapolate if requested*/
       	//based on ipolate
		if `extrp'==1 {
			qui by `var1': ipolate `var3' `var2', g(`tempip2') epolate
		}
        //based on regression - slow
        if `extrp'==2 {
            qui gen `tempip2'=.
            forvalues j=1(1)`=patnum' {
                capture regress `var3' `var2' if `tempid'==`j'
                if _rc==0 {
                    qui predict `tvar' if `tempid'==`j'
                    qui replace `tempip2'=`tvar' if `tempid'==`j'
                    qui drop `tvar'
                }
            }
        }
		//clean the predictions
		qui replace `tempip'=$xuplim if `tempip'>$xuplim & `tempip'!=.
		qui replace `tempip'=$xlolim if `tempip'<$xlolim
		if `extrp'!=0 {
			qui replace `tempip2'=$xuplim if `tempip2'>$xuplim & `tempip2'!=.
			qui replace `tempip2'=$xlolim if `tempip2'<$xlolim
		}
		//now add back to the BMI variable
		qui replace `var3'=`tempip' if `var3'==.
		if `extrp'!=0 {
			qui replace `var3'=`tempip2' if `var3'==.
		}
	}

	/*if imputations have been requested*/
	if `nimp'==0 {
		/*calculate variation of BMI change vs the linear prediction for various time settings*/
		if `dioutp'==1 {
			di as text "Calculating variation between observed and interpolated BMI (`=timepoints-2' steps)"
		}
		/*loop for various time windows*/
		forvalues i=2(1)`=timepoints-1' {
		//forvalues i=3(1)3 {
			tempfile templ`i'
			qui use `tempf', clear
			qui keep `var1' `var2' `var3' `timev'
			/*loop for difference starting points e.g. assuming i=2: 1-3 2-4 etc*/
			forvalues j=1(1)`=timepoints-`i'' {
				qui gen _tempbmi`j'=`var3'
				qui replace _tempbmi`j'=. if `timev'<`j' | `timev'>`=`j'+`i''
			}
			qui save `tempg', replace
			/*collapse to get patients with all needed measurements*/
			qui collapse (count) _tempbmi*, by(`var1')
			forvalues j=1(1)`=timepoints-`i'' {
				qui rename _tempbmi`j' _ctemp`j'
			}
			qui merge 1:m `var1' using `tempg'
			qui drop _merge
			qui save `tempg', replace
			/*go through all variables and get cases with at least one observation between the first and last value*/
			forvalues j=1(1)`=timepoints-`i'' {
				qui use `tempg', clear
				qui keep `var1' `var2' `var3' `timev' _tempbmi`j' _ctemp`j'
				qui keep if _ctemp`j'>2
				qui drop if `timev'<`j' | `timev'>`=`j'+`i''
				sort `var1' `var2'
				qui count
				if r(N)>0 {
    				/*set the middle values to missing in the temp var*/
    				qui replace _tempbmi`j'=. if `timev'!=`j' & `timev'!=`=`j'+`i''
    				/*linear interpolation*/
    				qui by `var1': ipolate _tempbmi`j' `var2', g(_tempbmi`j'x)
    				/*calculate difference: interpolation minus observed value*/
    				qui drop if `timev'==`j' | `timev'==`=`j'+`i''
    				/*calculate RMSD (root mean square deviation) = SE - http://en.wikipedia.org/wiki/Root-mean-square_deviation*/
    				qui replace _tempbmi`j'=(_tempbmi`j'x-`var3')^2
    				/*add distance to observation left and distance to observation right*/
    				qui gen timev=`timev'
    				/*rename and append*/
    				rename _tempbmi`j' _tempbmi
    				qui gen timep=`j'
    				/*save file*/
    				capture save `templ`i''
    				if _rc!=0 {
    					qui append using `templ`i''
    					qui compress
    					qui save `templ`i'', replace
    				}
                }
			}
			qui sum _tempbmi
			//calculate RMSD=SE
			scalar rmsd`i'=sqrt(r(sum)/r(N))
			//di rmsd`i'
			if `dioutp'==1 {
				di as result "." _continue
			}
		}
		//should only be relevant in debugging: when variation cannot be calculated for some distances
		forvalues i=2(1)`=timepoints-1' {
            if `i'==2 {
                if rmsd2==. {
                    if rmsd3!=. {
                        scalar rmsd2=rmsd3
                    }
                    else {
                        di as error "too many missing BMI values for specific time-distances and variation cannot be calculated"
                        error 409
                    }
                }
            }
            else if `i'==`=timepoints-1' {
                if rmsd`=timepoints-1'==. {
                    if rmsd`=timepoints-2'!=. {
                        scalar rmsd`=timepoints-1'=rmsd`=timepoints-2'
                    }
                    else {
                        di as error "too many missing BMI values for specific time-distances and variation cannot be calculated"
                        error 409
                    }
                }
            }
            else {
                if rmsd`i'==. {
                    if rmsd`=`i'-1'!=. & rmsd`=`i'+1'!=. {
                        scalar rmsd`i'=(rmsd`=`i'-1'+rmsd`=`i'+1')/2
                    }
                    else {
                        di as error "too many missing BMI values for specific time-distances and variation cannot be calculated"
                        error 409
                    }
                }
            }
            //di rmsd`i'
        }

		//if extrapolation requested more SE calculations are needed
		if inlist(`extrp',1,2) {
			/*calculate variation of BMI change vs the linear prediction for various time settings*/
			if `dioutp'==1 {
				/*local tmpcntr=0
				forvalues i=3(1)`=timepoints' {
					forvalues j=1(1)`=`i'-2' {
						local tmpcntr=`tmpcntr'+1
					}
				}*/
				di _newline as text "Calculating variation between observed and extrapolated BMI (`=timepoints-2' steps)"
			}
			/*get a file with dropped 'extreme' observations (one on each side)*/
			qui use `tempf', clear
			qui keep if `var3'!=.
			qui keep `var1' `var3' `timev' `tempid'
			qui save `tfX', replace
			//count how many observations per patient
			qui collapse (count) `timev', by(`var1')
			qui rename `timev' `numobs'
			qui merge 1:m `var1' using `tfX'
			qui drop _merge
			//keep only those with 3 or more observations
			qui keep if `numobs'>=3
			qui save `tfX', replace
			local tmpcntr=0
			/*loop for cases with 3 to all observations in place*/
			forvalues i=3(1)`=timepoints' {
				//loop to drop 1, 2 etc cases from each side of the set
				forvalues j=1(1)`=`i'-2' {
					local tmpcntr=`tmpcntr'+1
					/***drop from top***/
					qui use `tfX', clear
					qui keep if `numobs'==`i'
					/*sometimes if restriction have already been placed e.g. patients with a set number of observations in dataset, end ups empty*/
					qui count
					if r(N)>0 {
						gsort `var1' `timev'
						qui egen `tmptid'=seq(), by(`var1')
						//get distance from closest for top
						qui by `var1': gen `tmdist'=`timev'[_n+1] if `tmptid'==`j'
						local tcnt=0
						forvalues k=`=`j'-1'(-1)1 {
							local tcnt=`tcnt'+1
							qui by `var1': replace `tmdist'=`timev'[_n+`=`tcnt'+1'] if `tmptid'==`k'
						}
						qui replace `tmdist'=abs(`tmdist'-`timev')
						qui gen `crpvar3'=`var3'
						qui replace `crpvar3'=. if `tmptid'<=`j'
						sort `var1' `timev'
						qui gen vari=`i'
						qui gen varj=`j'
						qui gen fltp=0
						if `i'==3 {
							qui save `tf1', replace
						}
						else {
							qui append using `tf1'
							sort vari varj `var1' `timev'
							qui compress
							qui save `tf1', replace
						}
					}
					/***drop from bottom***/
					qui use `tfX', clear
					qui keep if `numobs'==`i'
					/*sometimes if restriction have already been placed e.g. patients with a set number of observations in dataset, end ups empty*/
					qui count
					if r(N)>0 {
						gsort `var1' -`timev'
						qui egen `tmptid'=seq(), by(`var1')
						//get distance from closest for bottom
						qui by `var1': gen `tmdist'=`timev'[_n+1] if `tmptid'==`j'
						local tcnt=0
						forvalues k=`=`j'-1'(-1)1 {
							local tcnt=`tcnt'+1
							qui by `var1': replace `tmdist'=`timev'[_n+`=`tcnt'+1'] if `tmptid'==`k'
						}
						qui replace `tmdist'=abs(`tmdist'-`timev')
						qui gen `crpvar3'=`var3'
						qui replace `crpvar3'=. if `tmptid'<=`j'
						sort `var1' `timev'
						qui gen vari=`i'
						qui gen varj=`j'
						qui gen fltp=1
						if `i'==3 {
							qui save `tf2', replace
						}
						else {
							qui append using `tf2'
							sort vari varj `var1' `timev'
							qui compress
							qui save `tf2', replace
						}
					}
				}
				if `dioutp'==1 {
					if mod(`tmpcntr',50)==0 {
						di
					}
                    di as result "." _continue
				}
			}
			//merge the two files
			qui use `tf1', clear
			qui append using `tf2'
			//generate predictions
			//based on ipolate
			if `extrp'==1 {
			    qui bys `var1' fltp varj: ipolate `crpvar3' `timev', g(tempvar) epolate
			}
            //based on regression - very slow
            else if `extrp'==2 {
                qui gen tempvar=.
                //qui gen crpvar3=`crpvar3'
                //qui gen timev=`timev'
                //qui gen tempid=`tempid'
                //qui gen tmdist=`tmdist'
                //individual regressions by patient X direction (right or left) X number of removed cases
                forvalues j1=1(1)`=patnum' {
                    forvalues j2=0(1)1 {
                        forvalues j3=1(1)`=timepoints-2'{
                            capture regress `crpvar3' `timev' if `tempid'==`j1' & fltp==`j2' & varj==`j3'
                            if _rc==0 {
                                qui predict `tvar' if `tempid'==`j1' & fltp==`j2' & varj==`j3'
                                qui replace tempvar=`tvar' if `tempid'==`j1' & fltp==`j2' & varj==`j3'
                                qui drop `tvar'
                            }
                        }
                    }
        			/*display*/
        			if `dioutp'==1 {
        				if `j1'==1 {
        					di _newline as text _col(5) "extra regressions for regression extrapolations (1000s of `=patnum'):"
        					di _col(5) _continue
        				}
        				if mod(`j1',1000)==0 {
        					di as result _continue "."
        				}
        				if mod(`j1',50000)==0 | `j1'==patnum {
        					di _continue `j1'
        				}
        			}
        		}
            }
	        sort fltp vari varj `var1' `timev'
			/*calculate RMSD (root mean square deviation) = SE - http://en.wikipedia.org/wiki/Root-mean-square_deviation*/
			qui gen tempvar2=(tempvar-`var3')^2 if `tmdist'!=.
			qui compress
			qui save `tfX', replace
			/*loop for various distances to calculate RMSD=SE*/
			/*although calcualting for various distances will only use for distance=1*/
			qui sum tempvar2 if `tmdist'==1
			scalar xrmsd1=sqrt(r(sum)/r(N))
			forvalues i=2(1)`=timepoints-2' {
				qui sum tempvar2 if `tmdist'==`i'
				if r(N)>100 {
					scalar xrmsd`i'=sqrt(r(sum)/r(N))
				}
				else {
					scalar xrmsd`i'=xrmsd`=`i'-1'
				}
				//di xrmsd`i'
			}
		}

		/*use file*/
		qui use `tempf', clear
		/*interpolate values to use in getting an estimate of change*/
		sort `var1' `var2'
		qui by `var1': ipolate `var3' `var2', g(`tempip')
		/*also extrapolate if requested*/
        //based on regression - slow
        if `extrp'==2 {
            qui gen `tempip2'=.
            forvalues j=1(1)`=patnum' {
                capture regress `var3' `var2' if `tempid'==`j'
                if _rc==0 {
                    qui predict `tvar' if `tempid'==`j'
                    qui replace `tempip2'=`tvar' if `tempid'==`j'
                    qui drop `tvar'
                }
            }
        }
		else {
			//based on ipolate
			qui by `var1': ipolate `var3' `var2', g(`tempip2') epolate
		}

		/*imputation*/
		/*create the imputation variables*/
		forvalues i=1(1)`=numimp' {
			/*generate variable - copying observed*/
			capture gen _`i'_`var3' = `var3'
			qui replace _`i'_`var3'=. if `var3'==.
			qui format _`i'_`var3' %5.2f
			//generate variables that include info with potential problems
            qui gen _`i'_iinfo=.
            if inlist(`extrp',1,2) {
                qui gen _`i'_xinfo=.
            }
		}
		/*multiple imputation possible for patient x?*/
		qui gen _mi_ipat=0
		if inlist(`extrp',1,2) {
            qui gen _mi_xpat=0
        }
        //debug
        //list if patid==75071
		/*patient loop*/
		forvalues j=1(1)`=patnum' {
			/*interpolation imputation only possible if at least two observations for patient*/
			qui sum `var3' if `tempid'==`j'
			matrix `tmat1' = J(1,timepoints,.)
			scalar `intrpat'=0
			scalar `extrpat'=0
			//counters
			scalar `xcnt0'=0
			scalar `xcnt1'=0			
			//empty locals just in case
			forvalues tp=1(1)`=timepoints' {
				local obsloc`tp'=0
			}
			if r(N)>=2 {
				/*map missing values*/
				forvalues tp=1(1)`=timepoints' {
					/*decide if value is available(=.), missing and intrapolatable (=0), missing and extrapolatable(=1), other (=2)*/
					/*check if data for time point `tp' is missing BUT a linear prediction has been calculated*/
					qui sum `var3' if `tempid'==`j' & `timev'==`tp'
					scalar lt1 = r(mean)
					qui sum `tempip' if `tempid'==`j' & `timev'==`tp'
					scalar lt2 = r(mean)
					qui sum `tempip2' if `tempid'==`j' & `timev'==`tp'
					scalar lt3 = r(mean)
					/*if observed*/
					if lt1!=. {
						//count how many observed and where they are
						scalar `xcnt0'=`xcnt0'+1
						local obsloc`=`xcnt0''=`tp'
					}
					else {
						/*if missing and computable with interpolation*/
						if lt2!=. {
							matrix `tmat1'[1,`tp']=0
							//at lest one value can be interpolated for the patient
							scalar `intrpat'=1
						}
						else {
							/*if missing and computable with extrapolation*/
							if lt3!=. {
								scalar `xcnt1'=`xcnt1'+1
								matrix `tmat1'[1,`tp']=1
								//at lest one value can be extrapolated for the patient
								scalar `extrpat'=1
							}
							/*if missing and patient not in in the dataset anymore*/
							else {
								matrix `tmat1'[1,`tp']=2
							}
						}
					}
				}
			}
			//count how many extrapolations on each side of observations
			local leftxtra=0
			local rghtxtra=0
			if `xcnt1'>0 {
            	forvalues i=1(1)`=`obsloc1'-1' {
					if `tmat1'[1,`i']==1 {
						local leftxtra=`leftxtra'+1
					}
				}
            	forvalues i=`=`obsloc`=`xcnt0'''+1'(1)`=timepoints' {
					if `tmat1'[1,`i']==1 {
						local rghtxtra=`rghtxtra'+1
					}
				}
			}
			//debug
			//if `j'==65 {
				//sum patid
				//matrix list `tmat1'
				//di `intrpat'
				//di `extrpat'
				//di `xcnt0'
				//di `xcnt1'
				//di `leftxtra'
				//di `rghtxtra'
			//}

			//if values can be interpolated for patient, proceed
			if `intrpat'==1 {
				//get the 'distances' for each value that can be predicted to use the appropriate SE (RMSD)
				matrix `tmat2' = J(1,timepoints,.)
				forvalues nnms=1(1)`=`xcnt0'-1' {
					local tmpnm1 = `obsloc`=`nnms'+1'' - `obsloc`nnms''
					forvalues nnmt=`=`obsloc`nnms''+1'(1)`=`obsloc`=`nnms'+1''-1' {
						matrix `tmat2'[1,`nnmt']=`tmpnm1'
					}
				}

				/*repeat process for each variable to be imputted*/
				forvalues i=1(1)`=numimp' {
					/*set temporary linear prediction for subject - will change later*/
					capture drop `linpred'
					qui gen `linpred'=`tempip' if `tempid'==`j'
					/*loop for timepoints*/
					forvalues tp=1(1)`=timepoints' {
						//if can be imputed using interpolation
						if `tmat2'[1,`tp']!=. {
							/*get value of linear prediction*/
							qui sum `linpred' if `tempid'==`j' & `timev'==`tp'
							scalar mval = r(mean)
							/*we wish to randomly draw from a normal distribution with mean=mval and sd=SE*/
							local tmpnm=`tmat2'[1,`tp']
							//draw value
							bmidraw `=mval' `=rmsd`tmpnm'' `=clnop' `imnar' `percmnr'
							scalar `newpred'=r(xnpred)
							scalar `prblm'=r(xprblm)
							if `prblm'==1 {
								qui replace _`i'_iinfo=1 if `tempid'==`j' & `timev'==`tp'
							}
							else {
								qui replace _`i'_iinfo=0 if `tempid'==`j' & `timev'==`tp'
                            }
							/*replace value in MI variable*/
							qui replace _`i'_`var3'=`newpred' if `tempid'==`j' & `timev'==`tp'
							/*and generate new linear prediction*/
							qui drop `linpred'
							qui ipolate _`i'_`var3' `var2' if `tempid'==`j', g(`linpred')
						}
					}
				}
				qui replace _mi_ipat=1 if `tempid'==`j'
			}

			//if extrapolation requested for patient, and can be applied, proceed
			if `extrpat'==1 & inlist(`extrp',1,2) {
				//debug
            	//if `j'==5 {
					//di "ok"
				//}
				//need the first and last observed to start working outwards towards each direction
				// `obsloc1' and `obsloc`=`xcnt0'''
				/*get the number of points to be imputed and order them from closest to furthest e.g. if 4 and 5 are observed
				get 3 6 2 7 1 8 9 10 etc in that order*/
				local pos1=`obsloc1'-1
				local pos2=`obsloc`=`xcnt0'''+1
				local cursr = `pos1'
				matrix `tmat3' = J(1,`=`xcnt1'',.)
				//debug
            	//if `j'==35 {
					//di `pos1'
					//di `pos2'
					//di `cursr'
				//}
				local i=1
				while `i'<=`=`xcnt1'' {
				//forvalues i=1(1)`=`xcnt1'' {
					if `cursr'==`pos1' {
						if `cursr'>=1 & `leftxtra'>0 {
							matrix `tmat3'[1,`i']=`cursr'
							local leftxtra=`leftxtra'-1
							local i=`i'+1
							local pos1=`pos1'-1
						}
						if `rghtxtra'>0 {
							local cursr = `pos2'
						}
						else {
                        	local cursr = `pos1'
						}
					}
					if `cursr'==`pos2' {
						if `cursr'<=timepoints & `rghtxtra'>0 {
							matrix `tmat3'[1,`i']=`cursr'
							local rghtxtra=`rghtxtra'-1
							local i=`i'+1
							local pos2=`pos2'+1
						}
						if `leftxtra'>0 {
							local cursr = `pos1'
						}
						else {
                        	local cursr = `pos2'
						}
					}
					//debug
					//if `j'==35 {
						//di `leftxtra'
						//di `rghtxtra'
					//}
				}
				//debug
            	//if `j'==65 {
					//matrix list `tmat3'
					//di `xcnt0'
					//di `xcnt1'
					//forvalues i=1(1)10 {
						//di `obsloc`i''
					//}
				//}

				/*repeat process for each variable to be imputted*/
				forvalues i=1(1)`=numimp' {
					/*set temporary linear prediction for subject - will change later*/
					capture drop `linpred'
					qui gen `linpred'=`tempip2' if `tempid'==`j'
					/*loop for timepoints*/
					forvalues xp=1(1)`=`xcnt1''{
						local tp=`tmat3'[1,`xp']
						/*it will always be imputable with extrapolation - get value of linear prediction*/
						qui sum `linpred' if `tempid'==`j' & `timev'==`tp'
						scalar mval = r(mean)
						//draw value
						bmidraw `=mval' `=xrmsd1' `=clnop' `xmnar' `percmnr'
						scalar `newpred'=r(xnpred)
						scalar `prblm'=r(xprblm)
						//debug
                        //if `j'==65 {
							//di `tp'
                        	//di `newpred'
                        	//di `prblm'
						//}
						if `prblm'==1 {
							qui replace _`i'_xinfo=1 if `tempid'==`j' & `timev'==`tp'
						}
						else {
                        	qui replace _`i'_xinfo=0 if `tempid'==`j' & `timev'==`tp'
                        }
						/*replace value in MI variable*/
						qui replace _`i'_`var3'=`newpred' if `tempid'==`j' & `timev'==`tp'
						//debug
						//if `j'==65 {
                        	//sum _`i'_`var3' if `tempid'==`j' & `timev'==`tp'
      					//}
						/*and generate new linear prediction*/
						qui drop `linpred'
						if `extrp'==1 {
						    qui ipolate _`i'_`var3' `var2' if `tempid'==`j', g(`linpred') epolate
						}
						else {
                            qui regress _`i'_`var3' `var2' if `tempid'==`j'
                            qui predict `linpred' if `tempid'==`j'
                        }
					}
				}
				qui replace _mi_xpat=1 if `tempid'==`j'
			}
			/*display*/
			if `dioutp'==1 {
				if `j'==1 {
					di _newline as text "Imputing, patients completed (1000s of `=patnum'):"
				}
				if mod(`j',1000)==0 {
					di as result "." _continue
				}
				if mod(`j',50000)==0 | `j'==patnum {
					di `j'
				}
			}
		}
		//list if patid==9384
		//list if patid==66421

		qui compress
		/*update imputations info*/
		//variable might already be there if mi set wide used
		qui replace _mi_miss=0
		if inlist(`extrp',1,2) {
			qui replace _mi_miss=1 if _mi_ipat==1 | _mi_xpat==1
		}
		else {
			qui replace _mi_miss=1 if _mi_ipat==1
		}
		/*if asked then reshape to mlong format*/
        if "`milng'"!="" {
            qui mi convert mlong, clear
        }
	}
end

//program to draw a BMI value with certain limitations
program bmidraw, rclass
	scalar mnval=`1'
	scalar sdval=`2'
	scalar clnop=`3'
	scalar imnar=`4'
	scalar percmnr=`5'
	scalar drlmt=5

	/*we wish to randomly draw from a normal distribution with mean=mval and sd=SE*/
	local newpred = rnormal(mnval,sdval)
	//if MNAR mechanism specified, edit prediction
    if imnar!=-1277 {
        //absolute value change
		if percmnr==0 {
            local newpred=`newpred'+imnar
        }
        //percentage change
        else {
            local newpred=`newpred'+`newpred'*imnar
        }
    }
	//loop to ensure within certain limits - shouldn't be needed
	if clnop==1 {
		local logstr "(`newpred'>$xuplim | `newpred'<$xlolim)"
	}
	else {
		local logstr "`newpred'<0"
	}
	local lgcntr=0
	while `logstr' & `lgcntr'<drlmt {
		local lgcntr=`lgcntr'+1
		local newpred = rnormal(mnval,sdval)
	}
	local prblm=0
	/*if values outside range - not likely to happen but just in case - set to minimum or maximum*/
	if `logstr' & `lgcntr'==drlmt {
		if `newpred'>$xuplim local newpred=$xuplim
		if clnop==1 {
			if `newpred'<$xlolim local newpred=$xlolim
		}
		else {
			if `newpred'<0 local newpred=3
		}
		local prblm=1
	}
	return scalar xnpred=`newpred'
	return scalar xprblm=`prblm'
end
