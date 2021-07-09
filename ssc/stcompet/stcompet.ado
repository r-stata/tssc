*! stcompet 1.0.7 EC 06 NOV 2012
*! Cumulative Incidence in the Presence of Competing Events

program define stcompet, sortpreserve
	version 10
	st_is 2 analysis
	
******* General frame of the command *****************************************
/*
  Command needs that previous stset has the form:
    	stset survtime, failure(event==# [#])
 
  where # refers to the code of failure of interest. Than stcompet can compute
  cumulative incidence, standard error and confidence bounds for this event and
  for other events that you specify in compet# options.
  Up to 6 competing events can be defined, but there is no problem in adding
  other compet# options.
  The initial syntax of the command is like sts gen because similar commands
  should share similar syntax. 
*/
******************************************************************************
	local rest `"`0'"'
	gettoken varname rest : rest, parse(" =,")
	gettoken eqsign  rest : rest, parse(" =,")
	gettoken thing   rest : rest, parse(" =,")

	if `"`eqsign'"' != "=" { 
		error 198 
	}
	while `"`eqsign'"' == "=" {
		confirm new var `varname'
		local thing = lower(`"`thing'"')
		if `"`thing'"' == "ci" {
			local ci `varname'
		}
		else if `"`thing'"' == "se" {
			local se "`varname'"
		}
		else if `"`thing'"'=="hi" {
			local hi "`varname'"
		}
		else if `"`thing'"'=="lo" {
			local lo "`varname'"
		}
		else {
			di in red `"`thing' unknown function"'
			exit 198
		}
		local 0 `"`rest'"'
		gettoken varname rest : rest, parse(" =,")
		gettoken eqsign  rest : rest, parse(" =,")
		gettoken thing   rest : rest, parse(" =,")
	}
	local what "`se'`hi'`lo'"
	
	syntax /* ... */  [if] [in] , COMPET1(numlist missingokay) [ COMPET2(numlist  missingokay) /*
		*/  COMPET3(numlist  missingokay) COMPET4(numlist missingokay) COMPET5(numlist missingokay) /*
		*/  COMPET6(numlist missingokay) BY(varname) ALLIGNol Level(integer $S_level) ]
	marksample touse
	qui replace `touse' = 0 if _st==0
	local type : set type
	set type double

	preserve

*** 1 - Further checks
		/* previous stset statement must be as required by stcompet */
	if "`_dta[st_bd]'"=="" | "`_dta[st_ev]'"=="" {   	
	    di as err  "failure variable must have been specified as failure(varname==numlist) " /*
        */ _n "on the stset command prior to using this command"
		exit 198
        }
	local if_st "`_dta[st_ifexp]'" /* it will need to restore existing if expression */

		/* enter cannot be specified as varname numlist - 08nov2008 */
	if "`_dta[st_enter]'" !="" {
		local enter `"`_dta[st_enter]'"'
		gettoken enter : enter, parse(" =")
		if "`enter'"!= "time" {
			di as err  "enter option cannot be specified as enter(varname==numlist) " /*
					*/ _n "on the stset command prior to using this command"
			exit 198
		}
	}
		
		/* byvar cannot contain non-integer values */
	capture confirm numeric variable `by'
	local isnum = _rc != 7
	if `isnum' { 		
		capture assert `by' == int(`by') if `touse' 
		if _rc { 
			di as err "`by' contains non-integer values" 
			exit 459
		} 
	}
			
			/* competing and interest events must be different */
	local compet0 "`_dta[st_ev]'"   /* main event */ 
	local i = 0
	while "`compet`i''" != "" {
		local c = `i' + 1
		while "`compet`c''" != "" {
			local ulist : list compet`c' & compet`i'
			if "`ulist'" != "" {	
				di as err "You specify `ulist' as codes for two competing events"
                  	exit 459
        		}
			local c = `c' + 1 
		}
		local i = `i' + 1
	}
	
			/* level as usual */ 
	if `level'<10 | `level'>99 {
		di in red "level() invalid"
		exit 198
	}
	local lvl = invnorm(1-(1-`level'/100)/2)

*** 2 - storing all events togheter and number of events. 
	
	local all_event = "`compet0' `compet1' "
	local nc = 2
	while "`compet`nc''" != "" {
		local all_event = "`all_event' `compet`nc''"
		local nc = `nc' + 1	
	}
	local nc = `nc' - 1
		

*** 3 - Cumulative Incidence estimate: sorting bygroups, if defined, and then starting from 
***     main event and in competing options order
	
	quietly {
			/* initialize as tempvar */
		tempvar byuse s_all cuminc
		gen `cuminc' = .			
		if "`what'" != "" {
			tempvar n_all d_all n_com d_com sevar
			gen `sevar' = .
		}
			 /* If Byvar */
		if "`by'" != "" { 
			tempvar byvar
			egen `byvar' = group(`by')
                        levelsof `byvar' if `touse'  /* byvar values */ 
                        local byvalue "`r(levels)'"
			gen byte `byuse' = 0
			foreach X of local byvalue {
				replace `byuse' = `touse' & `byvar'==`X'
				streset if `byuse', f(`_dta[st_bd]'==`all_event')
				sts gen `s_all' = s
				if "`what'" != "" {
					sts gen `n_all' = n `d_all' = d
				}
				local i = 0
				while "`compet`i''" != "" {    
					tempvar I`X'`i' S`X'`i'
					gen `I`X'`i'' = .
				
				/* compet compute cumulative incidence - It resets the code 
				   of the events in failvar */
					compet `byuse' `s_all' `I`X'`i'', fail(`compet`i'') 
					
					if "`what'" != "" {
				/* some n and some d must be missing because of ties */
						bysort `byuse' _t (`I`X'`i''):  /*
							*/ gen `n_com' = `n_all' if _n==1
						sts gen `d_com' = d
						replace `d_com' = . if `n_com'==.
						gen `S`X'`i'' = .
						
				/* secomp compute standard errors and store them in sevar */  
						secomp `byuse' `I`X'`i'' `n_com' `d_all' /*
						 	*/ `d_com' `s_all' `S`X'`i''				
						drop  `d_com' `n_com' 
						replace `sevar' = `S`X'`i'' if `S`X'`i''!=.
					}
				/* accumulate estimate in cuminc */
					replace `cuminc' = `I`X'`i'' if `I`X'`i''!=. 
					local i = `i' + 1	
				}
				drop `s_all' `n_all' `d_all' 
			}
		}

				/* No byvar */ 
		else {
			streset if `touse', f(`_dta[st_bd]'==`all_event') 
			sts gen `s_all' = s
			if "`what'" != "" {
				sts gen `n_all' = n `d_all' = d
			}
			forvalues i = 0(1)`nc'  {
				tempvar I`i' S`i'
				gen `I`i'' = .
                                compet `touse' `s_all' `I`i'' , fail(`compet`i'') 
				if "`what'" != ""{
					bysort `touse' _t (`I`i''):  /*
						*/ gen `n_com' = `n_all' if _n==1
					sts gen `d_com' = d
					replace `d_com' = . if `n_com'==.
					gen `S`i'' = .
					secomp `touse' `I`i'' `n_com' `d_all' `d_com' `s_all' `S`i''	
					drop  `d_com' `n_com' 
					replace `sevar' = `S`i'' if `S`i''!=.
				}
				replace `cuminc' = `I`i'' if `I`i''!=.
			}
      		}

***4 - Saving variables        		

		if "`ci'" != "" {
			gen `ci' = `cuminc'
			label var `ci' "Cumulative Incidence"
      		}
		if "`se'" != "" {
			gen `se' = `sevar' 
			label var `se' "Stand Err Cum Incidence"
      		}

		if "`hi'" != "" {
			/* log(-log) confidence bouds -> JB Choudhury, Stat in Med 2002; 21: 1129 */
			if "`allignol'" == "" { 
				gen `hi' = `cuminc' ^ exp(`lvl'*`sevar'/(`cuminc' *log(`cuminc' )))
				label var `hi' "CI() `level'% upper bound"
			}
			/* log(-log) confidence bouds -> Beyersmann J et al. Competing Risks and Multistate Models with R, p. 62 */
			else {
				gen `hi' = 1 - (1-`cuminc')^exp(-`lvl'*`sevar'/((1-`cuminc')*log((1-`cuminc' ))))
				label var `hi' "CI() `level'% upper bound (Allignol)"
			}
      		}
		if "`lo'" != "" {
			if "`allignol'" == "" { 
				gen `lo' = `cuminc' ^ exp(-`lvl'*`sevar'/(`cuminc' *log(`cuminc' )))  
				label var `lo' "CI() `level'% lower bound"
			}
			else {
				gen `lo' = 1 - (1-`cuminc')^exp(`lvl'*`sevar'/((1-`cuminc')*log((1-`cuminc' ))))
				label var `lo' "CI() `level'% lower bound (Allignol)"
			}
      		}

		set type `type'
		char _dta[st_ifexp] `if_st'
		streset, f(`_dta[st_bd]'==`compet0')
	}
	restore,not
end


program define compet    /* Compute Crude Cumulative Incidence */ 
	version 7.0
	syntax varlist, fail(numlist missingokay) 
	gettoken byuse varlist : varlist
	gettoken all_surv varlist : varlist
	tempvar h_comp is_even all_comp
        gen byte `is_even' = 0
        foreach num of local fail {
                replace `is_even' = 1 if `_dta[st_bd]'==`num' & `byuse'
		if "`_dta[st_exit]'" != "" {
			replace `is_even'=0 if `_dta[st_bt]' > `_dta[st_exexp]' & `byuse'
		}
	}
	count if `is_even'
	if `r(N)'== 0 {
		exit
	}
	streset if `byuse', f(`_dta[st_bd]'==`fail')
	sts gen `h_comp' = h
	bysort `all_surv' (`is_even') : gen double `all_comp' = `all_surv' if _n==_N 
	replace `h_comp' = . if `all_comp' == .
	gsort -`all_comp'
	replace `varlist' = cond(_n!=1,`h_comp' * `all_comp'[_n-1],`h_comp')
        gsort -`byuse' _t `varlist'
	replace `varlist' = sum(`varlist') if `is_even'
end


program define secomp   /* Compute Standard Error - Marubini & Valsecchi p.341 1995 */
	version 7  
	args by Cum n d_all d_com s sevar
	tempvar newby CI first second third
	tempname t_CI
	gen byte `newby' = `by' & `n'!=.  /* newby is 1 if byuse e n not missing */
	gsort -`newby' _t
	gen `CI' = cond(_n==1 & `Cum'==.,0,`Cum')
	replace `CI' = `CI'[_n-1] if `CI'==. & `newby'
	count if `newby'
	forvalues i = 1 / `r(N)' {
		sca `t_CI' = `CI'[`i']
                gen `first' = (`t_CI' - `CI')^2*`d_all'/(`n'*(`n'-`d_all'))
		gen `second' = cond(_n>1,`s'[_n-1]^2*`d_com'*(`n'-`d_com')/`n'^3, /*
			*/ `d_com' * (`n'-`d_com') / `n'^3) if _n<=`i'
                gen `third' = cond(_n>1,(`t_CI' - `CI')*`s'[_n-1]*`d_com'/`n'^2, /*
			*/ (`t_CI' - `CI') * `d_com' / `n'^2) if _n<=`i'
                replace `first' = sum(`first') if _n<=`i'
		replace `second' = sum(`second') if _n<=`i'
		replace `third' = sum(`third') if _n<=`i'
		replace `sevar' = sqrt(`first' + `second' - 2*`third') in `i'
		drop `first' `second' `third'
	}
	replace `sevar' = . if `Cum' ==. 
	/* filling missing values with previous estimates */
	sort `Cum' `sevar'
	replace `sevar' = `sevar'[_n-1] if `sevar'==. & `Cum'!=.
end
