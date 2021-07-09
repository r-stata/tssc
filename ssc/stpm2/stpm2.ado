*! version 1.7.4 20Apr2020
/*
History
PL 20Mar2020: user-specififed knots for tvc fix
PL 02Jul2018: Now autimatically uses the oldest option if Stata version < 15.1
PL 27Oct2016: Correct bug for Cure models with delayed entry and orthogonalization
PL 01Jun2015: Correct "lininit" bug for relative survival models
PL 28Apr2015: Mata library now compiled in Stata 14: Uses "oldest" otherwise
PL 23Apr2015: corrected date conflict that caused some update problems
PL 24Jun2014: Use old estimation commands if Stata version < 13.1.
PL 27Aug2013: If Stata version<13 old estimation commands otherwise used mata programs
PL 09Sep2012: knotstvc fix
PL 06Sep2012: ml programs written in mata for significant speed improvments.
PL 10Mar2012: Fixed bug with orthogonalization for time-dependent effects with delayed entry.
PL 30Jan2012: Allowed lininit to work with rcsbaseoff option
PL 05Oct2011: Fixed bug where noorthog created an error with delayed entry models
PR 09sep2011: storing parent varnames in e(varnames)
PL 08sep2011: fixed bug in complex user defined knots for time-dependent effects
PR 01sep2011: -from()- option restored to allow user to initialise params
PL 03aug2011: allow different boundary knots for time-dependent effects (bug fixed 15th Aug)
PL 01aug2011: fixed bug where variables could not begin "rcs" with delayed entry.
PL 07mar2011: added an option that will try using the lininit option if convergence using default fails
PR 29nov2010: fixed bug in e(cmdline).
PL 01Nov2010: introduced factor variables (However, not for tvc option).
PL 02sep2010: added more of Therese Andersson's changes to enable cure models to be fitted.
PL 15mar2010: incorporated Therese Andersson's changes to allow calculation of splines to be reversed.
PL 29jan2010: converted to Stata 11 to overcome problem of number of constraints.
PL 04jan2010: added use of weights 
PL 21sep2009: added rcsbaseoff option
PL 20aug2009: corrected bug in not dropping constraints.
PL 27apr2009: changed e(aic) and e(bic) to e(AIC) and e(BIC) so can be used with estimates table
PL 23apr2009: correct waldtest - this is no longer reported
PL ??apr2009: stpm2 now reports same likelihood as stpm and other parametric models
PL ??apr2009: added -showcons- option as constraints are not shown by default
PR 16apr2009: -verbose- option added
PL 12mar2009: made it possible for varlist for time varying covariates to be greater than 244 characters.
PR 09mar2009: added e(aic) and e(bic)
PR 11dec2008: changed to using rcsgen for spline functions.
*/

program stpm2, eclass byable(onecall)
	version 11.1

	if strpos("`0'","oldstpm") >0 {
		local 0:subinstr local 0 "oldstpm" ""
		stpm `0'
		exit
	}
	if _by() {
		local by "by `_byvars'`_byrc0':"
	}
	if replay() {
		syntax  [, DF(string) KNOTS(numlist ascending) *]
		if "`df'`knots'" != "" {
			`by' Estimate `0'
			ereturn local cmdline `"stpm2 `0'"'
		}
		else {
			if "`e(cmd)'" != "stpm2" {
				error 301
			}
			if _by() {
				error 190
				}
			Replay `0' 
		}	
		exit
	}
	`by' Estimate `0'
	ereturn local cmdline `"stpm2 `0'"'
end

program Estimate, eclass byable(recall)
	st_is 2 analysis	
	syntax  [varlist(fv default=empty)] [fw pw iw aw] [if] [in] ///
	[, DF(string) TVC(varlist fv) DFTvc(string) KNOTS(numlist ascending) KNOTSTvc(string) ///
		BKnots(numlist ascending min=2 max=2) BKNOTSTVC(string) KNSCALE(string) noORTHog SCale(string) noCONStant ///
		INITTheta(real 1) CONSTheta(string) EForm ALLEQ KEEPCons BHAZard(varname) ///
		LINinit STratify(varlist) THeta(string) OFFset(varname) RCSBASEOFF BHAZINIT(string) ///
		/* !! PR */ STPMDF(int 0) VERBose SHOWCons MLMethod(string) ///
		ALL RMAT REVerse CURE FAILCONVLININIT INITSTRATA(varlist) FROM(string) OLDEST ///
		NOFIRSTDER NOSECONDDER] ///
	[                               ///
	noLOg                           /// -ml model- options
	noLRTEST                        /// 
	Level(real `c(level)')       /// -Replay- option
	*                               /// -mlopts- options
	]

/* !! PR - save (parent) variable names from varlist */
_extract_varnames `varlist'
local varnames `r(varlist)'

// !! PR - note that stpmdf() overrides df() if both specified.
if `stpmdf'>0 local df `stpmdf'

local cmdline `"stpm2 `0'"'

/* Check rcsgen is installed */
	capture which rcsgen
	if _rc >0 {
		display in yellow "You need to install the command rcsgen. This can be installed using,"
		display in yellow ". {stata ssc install rcsgen}"
		exit  198
	}
	
/* Use old estimation commands if Stata version <15.1 */
	if `c(stata_version)' < 15.1 {
		local oldest oldest
	}

/*  Weights */
	if "`weight'" != "" {
		display as err "weights must be stset"
		exit 101
	}
	local wt: char _dta[st_w]	
	local wtvar: char _dta[st_wv]
	if "`wt'" != "" {
		local fw fw(`wtvar')
	}
	
/* Factor variables not allowed for tvc varables */
	fvexpand `tvc'
	if "`r(fvops)'" != "" {
		display as error "Factor variables not allowed for tvc() option. Create your own dummy varibles."
		exit 198
	}

/* Temporary variables */	
	tempvar Z xb lnt lnt0 coxindex S Sadj cons touse2 touse_t0 cons
	tempname initmat Rinv_bh R_bh rmatrix
	
/* Marksample and mlopts */	
	marksample touse
	qui replace `touse' = 0  if _st==0 | `touse' == .
	
	qui count if `touse'
	local nobs=r(N)
	if `r(N)' == 0 {
		display in red "No observations"
		exit 2000
	}
	
	qui count if `touse' & _d
	if `r(N)' == 0 {
		display in red "No failures"
		exit 198
	}

	_get_diopts diopts options, `options'	
	mlopts mlopts, `options'
	local extra_constraints `s(constraints)'

/* collinear option not allowed */
	if `"`s(collinear)'"' != "" {
		di as err "option collinear not allowed"
		exit 198
	}
	
/* use of all option to calculate spline variables out of sample */
	if "`all'" != "" {
		gen `touse2' = 1
	}
	else {
		gen `touse2' = `touse'
	}

/* Drop previous created _rcs and _d_rcs variables */
	capture drop _rcs* 
	capture drop _d_rcs*    
	capture drop _s0_rcs*
	
/* Check time origin for delayed entry models */
	local del_entry = 0
	qui summ _t0 if `touse' , meanonly
	if r(max)>0 {
		display in green  "note: delayed entry models are being fitted"
		local del_entry = 1
	}
	
/* Orthogonal retricted cubic splines */
	if "`orthog'"=="noorthog" {
		local orthog
	}
	else {
		local orthog orthog
	}	
	
/* generate log time */
	qui gen double `lnt' = ln(_t) if `touse2'

/* Ignore options associated with time-dependent effects if specified without the tvc option */
	if "`tvc'" == "" {
		foreach opt in dftvc knotstvc {
			if "``opt''" != "" {
				display as txt _n "[`opt'() used without specifying tvc(), option ignored]"
				local `opt'
			}
		}
	}

/* check df option is an integer */
	if "`df'" != "" {
		capture confirm integer number `df'
		if _rc>0 {
			display in red "df option must be an integer"
			exit 198
		}
	}

/* use no orthogonalization if rmat option specified */
/* add checks for no tvc etc */
	if "`rmat'" != "" {
		if "`tvc'" != "" {
			display as error "tvc option not available when using rmat option"
			exit 198
		}
		local orthog
		matrix `rmatrix' = e(R_bh)
		local rmatrixopt rmatrix(`rmatrix')
	}
	
/* Old stpm options */
/* Stratify */
	if "`stratify'" != "" {
		if "`tvc'" != "" {
			display as error "You can not specify both the stratify and tvc options"
			exit 198
		}
		local tvc `stratify'
		local dftvc `df'
	}
	
/* rcsbaseoff option */
	if "`rcsbaseoff'" != "" & "`tvc'" == "" {
		display as error "You must specify the tvc() option if you use the rcsbaseoff option"
		exit 198
	}

	
/* if bhazard option has missing values report error */
	if "`bhazard'" != "" {
		if `touse' & missing(`bhazard') == 1 {
			display as err "baseline hazard contains missing values"
			exit
		}
		local rs _rs
	}
	
	if "`bhazinit'" == "" {
		local bhazinit 0.1
	}
	
/* set up spline variables */
	tokenize `knots'
	local nbhknots : word count `knots'

/* Only one of df and knots can be specified */
	if "`df'" != "" & `nbhknots'>0 {
		display as error "Only one of DF OR KNOTS can be specified"
		exit
	}
	
/* df must be specified */
	if (`nbhknots' == 0 & "`df'" == "") & "`rcsbaseoff'" == "" {
		display as error "Use of either the df or knots option is compulsory"
		exit 198
	}

/* df for time-dependent variables */
	if "`tvc'"  != "" {
		if "`dftvc'" == "" & "`knotstvc'" == "" {
			display as error "The dftvc or knotstvc option is compulsory if you use the tvc option"
			exit 198
		}

		if "`knotstvc'" == "" {
			local ntvcdf: word count `dftvc'
			local lasttvcdf : word `ntvcdf' of `dftvc'
			capture confirm number `lasttvcdf'
			if `ntvcdf' == 1 | _rc==0 {
				foreach tvcvar in  `tvc' {
					if _rc==0 {
						local tmptvc = subinstr("`1'",".","_",1)
						local tvc_`tvcvar'_df `lasttvcdf'
					}
				}
			}
			if `ntvcdf'>1 | _rc >1 {
				tokenize "`dftvc'"
				forvalues i = 1/`ntvcdf' {
					local tvcdflist`i' ``i''
	
				}
				forvalues i = 1/`ntvcdf' {
					capture confirm number `tvcdflist`i''
					if _rc>0 {
						tokenize "`tvcdflist`i''", parse(":")
						confirm var `1'
						if `"`: list posof `"`1'"' in tvc'"' == "0" {				
								display as error "`1' is not listed in the tvc option"
								exit 198
						}
						local tmptvc `1'
						local tvc_`tmptvc'_df 1
					}
					local `1'_df `3'	
				}
			}
		}
/* check all time-dependent effects have been specified */
		if "`knotstvc'" == "" {
			foreach tvcvar in `tvc' {
				if "`tvc_`tvcvar'_df'" == "" {
					display as error "df for time-dependent effect of `tvcvar' are not specified"
					exit 198
				}
			}
			forvalues i = 1/`ntvcdf' {
				tokenize "`tvcdflist`i''", parse(":")
				local tvc_`1'_df `3'
			}
		}		
	}

/* knotstvc option */
	if "`knotstvc'" != "" {
		if "`dftvc'" != "" {
			display as error "You can not specify the dftvc and knotstvc options"
			exit 198
		}
		tokenize `knotstvc'
		cap confirm var `1'
		if _rc >0 {
			display as error "Specify the tvc variable(s) when using the knotstvc() option"
			exit 198
		}
		while "`2'"!="" {
			cap confirm var `1'
			if _rc == 0 {
				if `"`: list posof `"`1'"' in tvc'"' == "0" {				
					display as error "`1' is not listed in the tvc option"
					exit 198
				}
				local tmptvc `1'
				local tvc_`tmptvc'_df 1
			}

			cap confirm num `2'
			if _rc == 0 {
				local tvcknots_`tmptvc'_user `tvcknots_`tmptvc'_user' `2' 
				local tvc_`tmptvc'_df = `tvc_`tmptvc'_df' + 1
			}
			else {
				cap confirm var `2'
				if _rc {
					display as error "`2' is not a variable"
					exit 198
				}
			}
			macro shift 1
		}
	}

  
/* Check scale options specified */
	if "`scale'" =="" {
		display as error "The scale must be specified"
		exit
	}

/* define scale */
	if substr("`scale'", 1, 1)=="h" {
		local scale "hazard"
	}
	else if substr("`scale'", 1, 1)=="o" {
		local scale "odds"
	}
	else if substr("`scale'", 1, 1)=="n" {
		local scale "normal"
	}
	else if substr("`scale'", 1, 1)=="l" {
		local scale "log"
	}	
	else if substr("`scale'", 1, 1)=="t" {
		local scale "theta"
	}	
	else {
		display as error "The scale must be specified as either hazard, odds, normal or theta"
		exit
	}

/* Ensure that the hazard scale is specified if using the cure option*/
	if "`cure'" != "" & "`scale'" != "hazard" {
		display as err "The cure option should only be used with the scale(hazard) option"
		exit 198	
	}
/* if the cure option os specified, reverse should always be used for rcsgen*/	
	if "`cure'" != "" {
		local reverse reverse
	}
	
	
/* Ensure only certain options used with scale(theta) */	
	if "`scale'" != "theta" {
		foreach thetaopt in constheta {
			if "``thetaopt''" != "" {
				display as err "`thetaopt' should only be used with the scale(theta) option"
				exit 198
			}
		}
	}
	
	if "`scale'" == "odds" & "`theta'" != "" {
		local scale theta
		if "`theta'" != "est" {
			local constheta `theta'
		}
	}

/* knots given on which scale */
	if "`knscale'" == "" {
		local knscale time
	}
	if inlist(substr("`knscale'",1,1),"t","l","c") != 1 {
		display as error "Invalid knscale() option"
		exit 198
	}	
	
/* Boundary Knots */
	if "`bknots'" == "" {
		summ `lnt' if `touse' & _d == 1, meanonly
		local lowerknot `r(min)'
		local upperknot `r(max)'
	}
	else if substr("`knscale'",1,1) == "t" {
		local lowerknot = ln(real(word("`bknots'",1)))
		local upperknot = ln(real(word("`bknots'",2)))
	}
	else if substr("`knscale'",1,1) == "l" {
		local lowerknot = word("`bknots'",1)
		local upperknot = word("`bknots'",2)
	}
	else if substr("`knscale'",1,1) == "c" {
		qui centile `lnt' if `touse' & _d==1, centile(`bknots') 
		local lowerknot = `r(c_1)'
		local upperknot = `r(c_2)'
	}

	if "`bknotstvc'" != "" {
		tokenize `bknotstvc'
			while "`1'"!="" {
			cap confirm var `1'
			if _rc == 0 {
				if `"`: list posof `"`1'"' in tvc'"' == "0" {				
					display as error "`1' is not listed in the tvc option"
					exit 198
				}
				local tmptvc `1'
			}
			cap confirm num `2'
			if _rc == 0 {
				if substr("`knscale'",1,1) == "t" {
					local lowerknot_`tmptvc' = ln(`2') 
				}
				else if substr("`knscale'",1,1) == "l" {
					local lowerknot_`tmptvc' `2' 
				}
				else if substr("`knscale'",1,1) == "c" {
					qui centile `lnt' if `touse' & _d==1, centile(`2') 
					local lowerknot_`tmptvc' `r(c_1)'
				}
			}
			cap confirm num `3'
			if _rc == 0 {
				if substr("`knscale'",1,1) == "t" {
					local upperknot_`tmptvc' = ln(`3') 
				}
				else if substr("`knscale'",1,1) == "l" {
					local upperknot_`tmptvc' `3' 
				}
				else if substr("`knscale'",1,1) == "c" {
					qui centile `lnt' if `touse' & _d==1, centile(`3') 
					local upperknot_`tmptvc' `r(c_1)'
				}
			}
			else {
				cap confirm var `3'
				if _rc {
					display as error "bknotstvc option incorrectly specified"
					exit 198
				}
			}
			macro shift 3
		}
	}
	foreach tvcvar in `tvc' {	
		if "`lowerknot_`tvcvar''" == "" {
			local lowerknot_`tvcvar' = `lowerknot'
			local upperknot_`tvcvar' = `upperknot'
		}
	}
  
/* Knot placement for baseline hazard (unless cure option is specified) */
	if `nbhknots' == 0 & "`rcsbaseoff'" == "" & "`cure'" == "" {
		if `df' == 1 {
			qui rcsgen `lnt' if `touse2', gen(_rcs) dgen(_d_rcs) `orthog' `rmatrixopt' `reverse' `nosecondder' `nofirstder'
			if "`orthog'" != "" {
				matrix `R_bh' =  r(R)
			}
		}
		else if `df' == 2 {
			qui _pctile `lnt' if `touse' & _d==1 `wt', p(50) 
			local bhknots  `lowerknot' `r(r1)' `upperknot'
		}
		else if `df' == 3 {
			qui _pctile `lnt' if `touse' & _d==1 `wt', p(33 67) 
			local bhknots  `lowerknot' `r(r1)' `r(r2)' `upperknot'
		}
		else if `df' == 4 {
			qui _pctile `lnt' if `touse' & _d==1 `wt', p(25 50 75) 
			local bhknots  `lowerknot' `r(r1)' `r(r2)' `r(r3)' `upperknot'
		}
		else if `df' == 5 {
			qui _pctile `lnt' if `touse' & _d==1 `wt', p(20 40 60 80) 
			local bhknots  `lowerknot' `r(r1)' `r(r2)' `r(r3)' `r(r4)' `upperknot'
		}
		else if `df' == 6 {
			qui _pctile `lnt' if `touse' & _d==1 `wt', p(17 33 50 67 83) 
			local bhknots  `lowerknot' `r(r1)' `r(r2)' `r(r3)' `r(r4)' `r(r5)' `upperknot'
		}
		else if `df' == 7 {
			qui _pctile `lnt' if `touse' & _d==1 `wt', p(14 29 43 57 71 86) 
			local bhknots `lowerknot' `r(r1)' `r(r2)' `r(r3)' `r(r4)' `r(r5)' `r(r6)' `upperknot'
		}
		else if `df' == 8 {
			qui _pctile `lnt' if `touse' & _d==1 `wt', p(12.5 25 37.5 50 62.5 75 87.5) 
			local bhknots `lowerknot' `r(r1)' `r(r2)' `r(r3)' `r(r4)' `r(r5)' `r(r6)' `r(r7)' `upperknot'
		}
		else if `df' == 9 {
			qui _pctile `lnt' if `touse' & _d==1 `wt', p(11.1 22.2 33.3 44.4 55.6 66.7 77.8 88.9) 
			local bhknots `lowerknot' `r(r1)' `r(r2)' `r(r3)' `r(r4)' `r(r5)' `r(r6)' `r(r7)' `r(r8)' `upperknot'
		}
		else if `df' == 10 {
			qui _pctile `lnt' if `touse' & _d==1 `wt', p(10 20 30 40 50 60 70 80 90) 
			local bhknots `lowerknot' `r(r1)' `r(r2)' `r(r3)' `r(r4)' `r(r5)' `r(r6)' `r(r7)' `r(r8)' `r(r9)' `upperknot'
		}		
		else {
			display as error "DF must be between 1 and 10"
			exit
		}
	}
	
/* Default knot placement for baseline hazard, if cure is specified. Add an extra knot at the 95th centile */
	if `nbhknots' == 0 & "`rcsbaseoff'" == "" & "`cure'" != ""{
	   if `df' == 3 {
			qui _pctile `lnt' if `touse' & _d==1 `wt', p(50 95) 
			local bhknots  `lowerknot' `r(r1)' `r(r2)' `upperknot'
		}
	   else if `df' == 4{
			qui _pctile `lnt' if `touse' & _d==1 `wt', p(33 67 95) 
			local bhknots  `lowerknot' `r(r1)' `r(r2)' `r(r3)' `upperknot'
		}
		else if `df' == 5 {
			qui _pctile `lnt' if `touse' & _d==1 `wt', p(25 50 75 95) 
			local bhknots  `lowerknot' `r(r1)' `r(r2)' `r(r3)' `r(r4)' `upperknot'
		}
		else if `df' == 6 {
			qui _pctile `lnt' if `touse' & _d==1 `wt', p(20 40 60 80 95) 
			local bhknots  `lowerknot' `r(r1)' `r(r2)' `r(r3)' `r(r4)' `r(r5)' `upperknot'
		}
		else if `df' == 7 {
			qui _pctile `lnt' if `touse' & _d==1 `wt', p(17 33 50 67 83 95) 
			local bhknots  `lowerknot' `r(r1)' `r(r2)' `r(r3)' `r(r4)' `r(r5)' `r(r6)' `upperknot'
		}
		else if `df' == 8 {
			qui _pctile `lnt' if `touse' & _d==1 `wt', p(14 29 43 57 71 86 95) 
			local bhknots `lowerknot' `r(r1)' `r(r2)' `r(r3)' `r(r4)' `r(r5)' `r(r6)' `r(r7)' `upperknot'
		}
		else if `df' == 9 {
			qui _pctile `lnt' if `touse' & _d==1 `wt', p(12.5 25 37.5 50 62.5 75 87.5 95) 
			local bhknots `lowerknot' `r(r1)' `r(r2)' `r(r3)' `r(r4)' `r(r5)' `r(r6)' `r(r7)' `r(r8)' `upperknot'
		}
		else if `df' == 10 {
			qui _pctile `lnt' if `touse' & _d==1 `wt', p(11.1 22.2 33.3 44.4 55.6 66.7 77.8 88.9 95) 
			local bhknots `lowerknot' `r(r1)' `r(r2)' `r(r3)' `r(r4)' `r(r5)' `r(r6)' `r(r7)' `r(r8)' `r(r9)' `upperknot'
		}
		else if `df' == 11 {
			qui _pctile `lnt' if `touse' & _d==1 `wt', p(10 20 30 40 50 60 70 80 90 95) 
			local bhknots `lowerknot' `r(r1)' `r(r2)' `r(r3)' `r(r4)' `r(r5)' `r(r6)' `r(r7)' `r(r8)' `r(r9)' `r(r10)' `upperknot'
		}		
		else {
			display as error "DF must be between 3 and 11"
			exit
		}
	}

/* knot placement for time-varying covariates */
	if "`tvc'" != "" {
		foreach tvcvar in  `tvc' {
			if "`tvcknots_`tvcvar'_user'" == "" {
				if `tvc_`tvcvar'_df' == 1 {
					qui rcsgen `lnt' if `touse2', gen(_rcs_`tvcvar') dgen(_d_rcs_`tvcvar') `orthog' `reverse' `nosecondder' `nofirstder'
					if "`orthog'" != "" {
						tempname R_`tvcvar' Rinv_`tvcvar'
						matrix `R_`tvcvar'' =  r(R)
					}
				}
				else if `tvc_`tvcvar'_df'==2 {
					qui _pctile `lnt' if `touse' & _d==1 `wt', p(50) 
					local tvcknots_`tvcvar'  `lowerknot_`tvcvar'' `r(r1)' `upperknot_`tvcvar''
				}
				else if `tvc_`tvcvar'_df'==3 {
					qui _pctile `lnt' if `touse' & _d==1 `wt', p(33 67) 
					local tvcknots_`tvcvar' `lowerknot_`tvcvar'' `r(r1)' `r(r2)' `upperknot_`tvcvar''
					}
				else if `tvc_`tvcvar'_df'==4 {
					qui _pctile `lnt' if `touse' & _d==1 `wt', p(25 50 75) 
					local tvcknots_`tvcvar' `lowerknot_`tvcvar'' `r(r1)' `r(r2)' `r(r3)' `upperknot_`tvcvar''
				}
				else if `tvc_`tvcvar'_df'==5 {
					qui _pctile `lnt' if `touse' & _d==1 `wt', p(20 40 60 80) 
					local tvcknots_`tvcvar' `lowerknot_`tvcvar'' `r(r1)' `r(r2)' `r(r3)' `r(r4)' `upperknot_`tvcvar''
				}
				else if `tvc_`tvcvar'_df'==6 {
					qui _pctile `lnt' if `touse' & _d==1 `wt', p(17 33 50 67 83) 
					local tvcknots_`tvcvar' `lowerknot_`tvcvar'' `r(r1)' `r(r2)' `r(r3)' `r(r4)' `r(r5)' `upperknot_`tvcvar''
				}
				else if `tvc_`tvcvar'_df'==7 {
					qui _pctile `lnt' if `touse' & _d==1 `wt', p(14 29 43 57 71 86) 
					local tvcknots_`tvcvar' `lowerknot_`tvcvar'' `r(r1)' `r(r2)' `r(r3)' `r(r4)' `r(r5)' `r(r6)' `upperknot_`tvcvar''
				}
				else if `tvc_`tvcvar'_df'==8 {
					qui _pctile `lnt' if `touse' & _d==1 `wt', p(12.5 25 37.5 50 62.5 75 87.5) 
					local tvcknots_`tvcvar' `lowerknot_`tvcvar'' `r(r1)' `r(r2)' `r(r3)' `r(r4)' `r(r5)' `r(r6)' `r(r7)' `upperknot_`tvcvar''
				}
				else if `tvc_`tvcvar'_df'==9 {
					qui _pctile `lnt' if `touse' & _d==1 `wt', p(11.1 22.2 33.3 44.4 55.6 66.7 77.8 88.9) 
					local tvcknots_`tvcvar' `lowerknot_`tvcvar'' `r(r1)' `r(r2)' `r(r3)' `r(r4)' `r(r5)' `r(r6)' `r(r7)' `r(r8)' `upperknot_`tvcvar''
				}
				else if `tvc_`tvcvar'_df'==10 {
					qui _pctile `lnt' if `touse' & _d==1 `wt', p(10 20 30 40 50 60 70 80 90) 
					local tvcknots_`tvcvar' `lowerknot_`tvcvar'' `r(r1)' `r(r2)' `r(r3)' `r(r4)' `r(r5)' `r(r6)' `r(r7)' `r(r8)' `r(r9)' `upperknot_`tvcvar''
				}
				else {
					display as error "DF for time-dependent effects must be between 1 and 10"
					exit
				}		
			}
		}
	}

/* Generate splines for baseline hazard */
	/* !! PR */ if "`verbose'"=="verbose" display as txt "Generating Spline Variables"
	if `nbhknots'>0 & "`rcsbaseoff'" == "" {
		local bhknots `lowerknot'

		forvalues i=1/`nbhknots' {
			if substr("`knscale'",1,1) == "t" {
				local addknot = ln(real(word("`knots'",`i')))
			}
			else if substr("`knscale'",1,1) == "l" {
				local addknot = word("`knots'",`i')
			}
			else if substr("`knscale'",1,1) == "c" {
				local tmpknot = word("`knots'",`i')
				qui _pctile `lnt' if `touse' & _d==1 `wt', p(`tmpknot') 
				local addknot = `r(r1)'
			}
			local bhknots `bhknots' `addknot'
		}
		local bhknots `bhknots' `upperknot'
	}

	if "`df'" != "1" & "`rcsbaseoff'" == "" {
		if  "`:list dups bhknots'" != "" {
			display as error "You have duplicate knots positions for the baseline."
			display as error "Try using fewer degrees of freedom or specifying the knots yourself."
			exit 198
		}
		qui rcsgen `lnt' if `touse2', knots(`bhknots') gen(_rcs) dgen(_d_rcs) `orthog'  `rmatrixopt' `reverse' `nosecondder' `nofirstder'
		if "`orthog'" != "" {
			matrix `R_bh' = r(R)
		}
	}
	
/* Generate splines for time-dependent effects */	
	if "`tvc'" != "" {
		foreach tvcvar in  `tvc' {
			if `tvc_`tvcvar'_df' != 1 {
				if "`tvcknots_`tvcvar'_user'" != "" {
					local n_`tvcvar': word count `tvcknots_`tvcvar'_user'
					local tvcknots_`tvcvar' `lowerknot_`tvcvar''
 
					forvalues i=1/`n_`tvcvar'' {
						if substr("`knscale'",1,1) == "t" {
							local addknot = ln(real(word("`tvcknots_`tvcvar'_user'",`i')))
						}
						else if substr("`knscale'",1,1) == "l" {
							local addknot = word("`tvcknots_`tvcvar'_user'",`i')
						}
						else if substr("`knscale'",1,1) == "c" {
							local tmpknot = word("`tvcknots_`tvcvar'_user'",`i')
							qui centile `lnt' if `touse' & _d==1, centile(`tmpknot') 
							local addknot = `r(c_1)'
						}
						local tvcknots_`tvcvar' `tvcknots_`tvcvar'' `addknot'
					}
					local tvcknots_`tvcvar' `tvcknots_`tvcvar'' `upperknot_`tvcvar''
 				}
				if  "`:list dups tvcknots_`tvcvar''" != "" {
					display as error "You have duplicate knots positions for the time-dependent effect of `tvcvar'"
					exit 198
				}				
				qui rcsgen `lnt' if `touse2', knots(`tvcknots_`tvcvar'') gen(_rcs_`tvcvar') dgen(_d_rcs_`tvcvar') `orthog' `reverse' `nosecondder' `nofirstder'
				if "`orthog'" != "" {
					tempname R_`tvcvar' Rinv_`tvcvar'
					matrix `R_`tvcvar'' = r(R)
				}
			}
		}
	}
  
	/* Added so R matrix is returned when using rmat option */
	if "`rmat'" != "" {
			local orthog orthog		
			matrix `R_bh' = `rmatrix'
	}


	if `del_entry' == 1 {
		qui gen double `lnt0' = ln(_t0) if `touse2' & _t0>0
		if "`orthog'" != "" {
			local rmatrixopt rmatrix(`R_bh')
		}
		if "`df'" == "1" & "`rcsbaseoff'" == "" {
			qui rcsgen `lnt0' if `touse2' & _t0>0, gen(_s0_rcs) `rmatrixopt' `reverse' `nosecondder' `nofirstder'
		}
		else if "`df'" != "1" & "`rcsbaseoff'" == "" {
			qui rcsgen `lnt0' if `touse2' & _t0>0, knots(`bhknots') gen(_s0_rcs) `rmatrixopt' `reverse' `nosecondder' `nofirstder'
		}

		foreach tvcvar in  `tvc' {
			if "`orthog'" != "" {
				local rmatrixopt rmatrix(`R_`tvcvar'')
			}	
			if `tvc_`tvcvar'_df' == 1 {
				qui rcsgen `lnt0' if `touse2' & _t0>0,  gen(_s0_rcs_`tvcvar') `rmatrixopt' `reverse' `nosecondder' `nofirstder'
			}
			else if `tvc_`tvcvar'_df' != 1 {
					qui rcsgen `lnt0' if `touse2' & _t0>0, knots(`tvcknots_`tvcvar'') gen(_s0_rcs_`tvcvar') `rmatrixopt' `reverse' `nosecondder' `nofirstder'
			}
		}		
	}

	if "`rcsbaseoff'" == "" {
		local nk : word count `bhknots'
		if "`df'" == "1" {
			local df = 1
		}
		else if "`nosecondder'" != "" {
			local df = `nk' 
		}
		else if "`nofirstder'" != "" {
			local df = `nk'+1 
		}
		else {
			local df = `nk' - 1
		}
		else {
			local df = `nk' - 1
		}
	}
	else {
		local df 0
	}
	
/* create list of spline terms and their derivatives for use when orthogonalizing and in model equations */
	forvalues i = 1/`df' {
		local rcsterms_base "`rcsterms_base' _rcs`i'"
		local drcsterms_base "`drcsterms_base' _d_rcs`i'"
	}

	local rcsterms `rcsterms_base'
	local drcsterms `drcsterms_base'
	if "`tvc'" != "" {
		foreach tvcvar in  `tvc' {
			if "`nosecondder'" != "" {
				local tvc_`tvcvar'_df = `tvc_`tvcvar'_df'+1 
			}
			else if "`nofirstder'" != "" {
				local tvc_`tvcvar'_df = `tvc_`tvcvar'_df'+2 
			} 
		}
		foreach tvcvar in  `tvc' {
			forvalues i = 1/`tvc_`tvcvar'_df' {
				local rcsterms_`tvcvar' "`rcsterms_`tvcvar'' _rcs_`tvcvar'`i'"
				local drcsterms_`tvcvar' "`drcsterms_`tvcvar'' _d_rcs_`tvcvar'`i'"
				local rcsterms "`rcsterms' _rcs_`tvcvar'`i'"
				local drcsterms "`drcsterms' _d_rcs_`tvcvar'`i'"
			}
		}
	}
	
	local s0_rcsterms : subinstr local rcsterms_base "_rcs" "_s0_rcs", all 
	local s0_rcsterms_base `s0_rcsterms'
	if "`tvc'" != "" {
		foreach tvcvar in  `tvc' {
			forvalues i = 1/`tvc_`tvcvar'_df' {
				local s0_rcsterms_`tvcvar' `s0_rcsterms_`tvcvar'' _s0_rcs_`tvcvar'`i'
			}
			local s0_rcsterms `s0_rcsterms' `s0_rcsterms_`tvcvar''
		}
	}
	
/* multiply time-dependent _rcs and _drcs terms by time-dependent covariates */
	if "`tvc'" != "" {
		foreach tvcvar in  `tvc' {
			forvalues i = 1/`tvc_`tvcvar'_df' {
				qui replace _rcs_`tvcvar'`i' = _rcs_`tvcvar'`i'*`tvcvar' if `touse2'
				qui replace _d_rcs_`tvcvar'`i' = _d_rcs_`tvcvar'`i'*`tvcvar' if `touse2'
				if `del_entry' == 1 {
					qui replace _s0_rcs_`tvcvar'`i' = _s0_rcs_`tvcvar'`i'*`tvcvar' if `touse2' & _t0>0
				}
			}
		}
	}

/* replace missing values for delayed entry with -99 as ml will omit these cases. -99 is not included in the likelihood calculation */
	if `del_entry' == 1 {
		forvalues i = 1/`df' {
			qui replace _s0_rcs`i' = -99 if `touse2' & _t0 == 0 & "`rcsbaseoff'" == ""
		}
		foreach tvcvar in `tvc' {
			forvalues i = 1/`tvc_`tvcvar'_df' {
			qui replace _s0_rcs_`tvcvar'`i' = -99 if `touse2' & _t0 == 0
			}
		}
	}

/* variable labels */
	if "`rcsbaseoff'" == "" {
		forvalues i = 1/`df' {
			label var _rcs`i' "restricted cubic spline `i'"
			label var _d_rcs`i' "derivative of restricted cubic spline `i'"
			if `del_entry' == 1 {
				label var _s0_rcs`i' "restricted cubic spline `i' (delayed entry)"
			}
		}
	}

	if "`tvc'" != "" {
		foreach tvcvar in  `tvc' {
			forvalues i = 1/`tvc_`tvcvar'_df' {
				label var _rcs_`tvcvar'`i' "restricted cubic spline `i' for tvc `tvcvar'"
				label var _d_rcs_`tvcvar'`i' "derivative of restricted cubic spline `i' for tvc `tvcvar'"
				if `del_entry' == 1 {
					label var _s0_rcs_`tvcvar'`i' "restricted cubic spline `i' for tvc `tvcvar' (delayed entry)"
				}
			}	
		}
	}

	if "`varlist'" != "" {
		local colvarlist (`varlist')
	}
	_rmcollright (`rcsterms') `colvarlist' if `touse', `constant'
	local varlist `r(block2)'
	foreach var in `varlist' {
		if strpos("`var'","o.") == 0 & strpos("`var'","b.") == 0 {
			local varlist_omitted `varlist_omitted' `var'
		}
	}
	
/* Define Offset */
	if "`offset'" != "" {
		local offopt offset(`offset')
		local addoff +`offset'
	}
	
/* stratify for initial values */
	if "`initstrata'" != "" {
		local initstrata strata(`initstrata')
	}
	
/* initial values fit a Cox model with (linear time-dependent covariates) */
/* Taken from Patrick Roystons stpm code */	
		
	/* !! PR */ if "`verbose'"=="verbose" display as txt "Obtaining Initial Values"
	if "`lininit'" == "" {
		if "`tvc'" != "" {
			local tvcterms tvc(`tvc') texp(ln(_t))
		}
		qui stcox `varlist' if `touse', estimate `initstrata'
		qui predict `coxindex' if `touse', xb
		qui sum `coxindex' if `touse'
		qui replace `coxindex'=`coxindex'-r(mean) if `touse'
		qui stcox `coxindex' if `touse', basechazard(`S') `initstrata'
		if "`bhazard'" != "" {
			qui replace `S' = `S' - `bhazinit'*`bhazard'*_t if `touse'
		}
		qui replace `S'=exp(-`S') if `touse'
		qui predict double `Sadj' if `touse', hr
		qui replace `Sadj'=`S'^`Sadj' if `touse'
		if "`scale'" == "hazard" {
			qui gen double `Z' = ln(-ln(`Sadj')) `addoff' if `touse'
		}
		else if "`scale'" == "odds" {
			qui gen double `Z' = ln((1-`Sadj')/`Sadj')  `addoff'  if `touse'
		}
		else if "`scale'" == "normal" {
			qui gen double `Z' = invnormal((`nobs'*(1-`Sadj')-3/8)/(`nobs'+1/4))  `addoff' if `touse'
		}
		else if "`scale'" == "log" {
			qui gen double `Z' = ln(1-`Sadj') `addoff' if `touse'
		}		
		else if "`scale'" == "theta" {
			qui gen double `Z' = ln((`Sadj'^(-`inittheta') - 1)/(`inittheta'))  `addoff' if `touse'
		}
		qui regress `Z' `varlist' `rcsterms'  if `touse' & _d == 1 , `constant'
		matrix `initmat' = e(b)
		
/* initial values for theta */
		if "`scale'" == "theta" {
			local thetaeq (ln_theta:)
			if "`constheta'"  == "" {
				local lntheta = ln(`inittheta')
				matrix `initmat' = `initmat' , `lntheta'
			}
			else {
				local lntheta = ln(`constheta')
				matrix `initmat' = `initmat' , `lntheta'
			}
		}	
	
		local ncopy : word count `rcsterms'
		local nstart : word count `varlist'
		local nstart = `nstart' + 1
		local ncopy = `nstart' + `ncopy' -1
		matrix `initmat' = `initmat', `initmat'[1,`nstart'..`ncopy']
	}

/* Fit linear term to log(time) for initial values. */
	else {
		if inlist("`scale'","hazard","odds","normal","log") {
			if "`rcsbaseoff'" == "" {
				local initrcslist _rcs1
				local initdrcslist _d_rcs1
				constraint free
				constraint `r(free)' [xb][_rcs1] = [dxb][_d_rcs1]
			}
			local initconslist `r(free)'
			if "`tvc'" != "" {
				foreach tvcvar in `tvc' {
					local initrcslist `initrcslist' _rcs_`tvcvar'1
					local initdrcslist `initdrcslist' _d_rcs_`tvcvar'1
					constraint free
					constraint `r(free)' [xb][_rcs_`tvcvar'1] = [dxb][_d_rcs_`tvcvar'1]
					local initconslist `initconslist' `r(free)'
				}
			}
			if `del_entry' == 1 {
				local xb0 `"(xb0: `varlist'"' 
				if "`rcsbaseoff'" == "" {
					local xb0 `xb0' _s0_rcs1 
				}
				if "`tvc'" != "" {
					foreach tvcvar in `tvc' {
						local xb0 `xb0' _s0_rcs_`tvcvar'1
					}
				}
				local xb0 `xb0', `constant' `offopt')

				if "`constant'" == "" {
					local addconstant _cons
				}
				foreach var in `initrcslist' `varlist' `addconstant' {
					constraint free
					if substr("`var'",1,4) == "_rcs" {
						constraint `r(free)' [xb][`var'] = [xb0][_s0`var']
					}
					else {
						constraint `r(free)' [xb][`var'] = [xb0][`var']
					}
					local initconslist `initconslist' `r(free)'
				}
			}
			/* !! PR */ if "`verbose'"=="verbose" display as txt "Obtaining Initial Values"
			if "`oldest'" == "" {
				if "`mlmethod'" == "" {
					if inlist("`scale'","hazard","odds","normal") {
						local mlmethod lf2
					}
					else {
						local mlmethod lf
					}
				}
				if inlist("`scale'","normal","theta") & "`rs'" != "" {
					local mlmethod lf
				}
		

				if "`scale'" == "log" {
					local iml lf
					local addilf _lf
				}
				else {
					local iml lf2
				}
			
				tempname stpm2_struct
				local userinfo userinfo(`stpm2_struct')
			
				mata stpm2_setup("`stpm2_struct'")		

				qui ml model `iml' stpm2_ml`addilf'_`scale'`rs'() ///
					(xb: =  `varlist' `initrcslist', `constant' `offopt') ///
					`thetaeq' ///
					(dxb: `initdrcslist', nocons)  ///
					`xb0' ///
					if `touse' ///
					`wt', ///
					`mlopts' ///
					`userinfo' ///
					collinear ///
					constraints(`initconslist') ///
					search(norescale) ///
					maximize

				display in green "Initial Values Obtained"
				matrix `initmat' = e(b)
				constraint drop `initconslist'
			}
			else {
				if "`mlmethod'" == "" {
					if inlist("`scale'","hazard","odds","normal") {
						local mlmethod e2
					}
					else {
						local mlmethod lf
					}
				}	
				if "`scale'" == "normal" & "`rs'" != "" {
					local mlmethod lf
				}	
				if "`mlmethod'" == "lf" {
					local addlf _lf
				}
	
				`captureml' qui ml model `mlmethod' stpm2_ml`addlf'_`scale'`rs' /// 			
					(xb: `bhazard' =  `varlist' `initrcslist', `constant' `offopt') ///
					`thetaeq' ///
					(dxb: `initdrcslist', nocons)  ///
					`xb0' ///
					if `touse' ///
					`wt', ///
					`mlopts' ///
					collinear ///
					constraints(`initconslist') ///
					search(norescale) ///
					maximize	
					
				display in green "Initial Values Obtained"
				matrix `initmat' = e(b)
				constraint drop `initconslist'	
			}
		}
	}
	
/* Define constraints */					
	local conslist
	local fplist
	local dfplist

/* constraints for theta if option constheta(#) is specified */	
	if "`scale'" == "theta" & "`constheta'" !="" {
		constraint free
		constraint `r(free)' [ln_theta][_cons] = `constheta'
		local conslist `conslist' `r(free)'
	}

/* constraints for baseline */
	forvalues k = 1/`=cond("`cure'"=="",`df',`df'-1)' {
		constraint free
		constraint `r(free)' [xb][_rcs`k'] = [dxb][_d_rcs`k']
		local conslist `conslist' `r(free)'
	}
	if "`cure'" != "" {
		constraint free
		constraint `r(free)' [dxb][_d_rcs`df'] = 0
		local conslist `conslist' `r(free)'
	}

/* add constraint for baseline if cure option is specified*/
	if "`cure'" != "" {
		if "`rcsbaseoff'" == "" {
			constraint free
			constraint `r(free)' [xb][_rcs`df'] = 0
			local conslist `conslist' `r(free)'
		}
	}
/* constraints for time-dependent effects */
	if "`tvc'" != "" {
		foreach tvcvar in  `tvc' {
			forvalues k = 1/`tvc_`tvcvar'_df' {
				constraint free
				constraint `r(free)' [xb][_rcs_`tvcvar'`k'] = [dxb][_d_rcs_`tvcvar'`k']
				local conslist `conslist' `r(free)'
			}
		}
	}

/* add constraints for time-dependent effects if cure option is specified*/
	if "`tvc'" != "" & "`cure'" != ""{
		foreach tvcvar in  `tvc' {
				constraint free
				constraint `r(free)' [xb][_rcs_`tvcvar'`tvc_`tvcvar'_df'] = 0
				local conslist `conslist' `r(free)'
		}
	}

/* constraints for extra equation if delayed entry models are being fitted */	
	if `del_entry' == 1 {
*		local xb0: subinstr local rcsterms "_rcs" "_s0_rcs", all
		
		local xb0 (xb0: `varlist' `s0_rcsterms', `constant' `offopt')
		local xbvarlist `varlist' `rcsterms' 
		local xbvarlist_omitted `varlist_omitted' `rcsterms' 
		if "`constant'" == "" {
			local xbvarlist `xbvarlist' _cons
			local xbvarlist_omitted `xbvarlist_omitted' _cons
		}
		foreach term in `xbvarlist_omitted' {
			constraint free
			if substr("`term'",1,4) == "_rcs" {
				local addterm = "_s0" + "`term'"
			}
			else {
				local addterm `term'
			}
			constraint free
			if "`cure'" != "" & ("`term'" == "_rcs`df'") {
				constraint `r(free)' [xb0][`addterm'] = 0	
			}
			else {
				constraint `r(free)' [xb][`term'] = [xb0][`addterm']
			}
			local conslist `conslist' `r(free)'
		}
		if "`lininit'" == "" {
			local nxbterms: word count `xbvarlist'
			matrix `initmat' = `initmat', `initmat'[1,1..`nxbterms']
		}
	}

	local dropconslist `conslist'
/* If further constraints are listed stpm2 then remove this from mlopts and add to conslist */
	if "`extra_constraints'" != "" {
		local mlopts : subinstr local mlopts "constraints(`extra_constraints')" "",word
		local conslist `conslist' `extra_constraints'
	}
		
/* Fit Model */
	/* !! PR addition for initialisation from `from' */
	if "`from'" == "" {
		if "`lininit'" == "" {
			local initopt "init(`initmat',copy)"
		}
		else {
			local initopt "init(`initmat')"
		}
	}
	else local initopt "init(`from')"

	/* !! PR */ if "`verbose'"=="verbose" display as txt "Starting to Fit Model"
	
	if "`oldest'" == "" {
		if "`mlmethod'" == "" {
			if inlist("`scale'","hazard","odds","normal") {
				local mlmethod lf2
			}
			else {
				local mlmethod lf
			}
			if inlist("`scale'","normal","theta") & "`rs'" != "" {
				local mlmethod lf
			}
		}

/* try lininit if convergence fails */	
		if "`failconvlininit'" != "" {
			local captureml capture
		}
		tempname stpm2_struct
		mata stpm2_setup("`stpm2_struct'")
		local userinfo userinfo(`stpm2_struct')

		`captureml' ml model `mlmethod' stpm2_ml`addlf'_`scale'`rs'() /// 
			(xb:  = `varlist' `rcsterms', `constant' `offopt') ///
			`thetaeq' ///
			(dxb: `drcsterms', nocons)  ///
			`xb0' ///
			if `touse' ///
			`wt', ///
			`mlopts' ///
			`userinfo' ///
			collinear ///
			constraints(`conslist') ///
			`initopt'  ///	
			search(off) ///
			waldtest(0) ///
			`log' ///
			maximize 
	
		if (c(rc) == 1400) & "`lininit'" == "" {
			noi di as txt "[initial values infeasible, retrying with -lininit- option]"
			`cmdline' lininit
			exit
		}
	}
/* old ML estimation */
	else {
		if "`mlmethod'" == "" {
			if inlist("`scale'","hazard","odds","normal") {
				local mlmethod e2
			}
			else {
				local mlmethod lf
			}
			if "`scale'" == "normal" & "`rs'" != "" {
				local mlmethod lf
			}
		}
		if "`mlmethod'" == "lf" {
			local addlf _lf
		}
/* try lininit if convergence fails */	
		if "`failconvlininit'" != "" {
			local captureml capture
		}
	
		`captureml' ml model `mlmethod' stpm2_ml`addlf'_`scale'`rs' /// 
			(xb: `bhazard' = `varlist' `rcsterms', `constant' `offopt') ///
			`thetaeq' ///
			(dxb: `drcsterms', nocons)  ///
			`xb0' ///
			if `touse' ///
			`wt', ///
			`mlopts' ///
			collinear ///
			constraints(`conslist') ///
			`initopt'  ///	
			search(off) ///
			waldtest(0) ///
			`log' ///
			maximize 

		if (c(rc) == 1400) & "`lininit'" == "" {
			noi di as txt "[initial values infeasible, retrying with -lininit- option]"
			`cmdline' lininit
			exit
		}	
	}
	capture mata: rmexternal("`stpm2_struct'")
	ereturn local cmdline `cmdline'
	
	ereturn local predict stpm2_pred
	ereturn local cmd stpm2
	ereturn local depvar "_d _t"
	ereturn local varlist `varlist'
	/* PR */ ereturn local varnames `varnames'
	ereturn local tvc `tvc'
	ereturn local constant `noconstant'
	ereturn local rcsbaseoff `rcsbaseoff'
	ereturn local nosecondder `nosecondder'
	ereturn local nofirstder `nofirstder'
	local exp_lowerknot = exp(`lowerknot')
	local exp_upperknot = exp(`upperknot')
	ereturn local boundary_knots "`exp_lowerknot' `exp_upperknot'"
	foreach tvcvar in  `tvc' {
		local exp_lowerknot = exp(`lowerknot_`tvcvar'')
		local exp_upperknot = exp(`upperknot_`tvcvar'')
		ereturn local boundary_knots_`tvcvar' "`exp_lowerknot' `exp_upperknot'"
	}
	if `df' >1 {
		forvalues i = 2/`df' {
			local addknot = exp(real(word("`bhknots'",`i')))
			local exp_bhknots `exp_bhknots' `addknot' 
		}
		ereturn local bhknots `exp_bhknots'
	}
	ereturn local ln_bhknots `bhknots'
	ereturn local rcsterms_base `rcsterms_base'
	ereturn local drcsterms_base `drcsterms_base'
	ereturn scalar dfbase = `df'
//	ereturn scalar nxbterms = e(rank) - ("`scale'" == "theta")
	_ms_eq_info
	ereturn scalar nxbterms = `r(k1)'
	if "`scale'" != "theta" {
		ereturn scalar ndxbterms = `r(k2)'
	}
	else {
		ereturn scalar ndxbterms = `r(k3)'
	}
  
	foreach tvcvar in  `tvc' {
		local exp_knots
		ereturn scalar df_`tvcvar' = `tvc_`tvcvar'_df'
		ereturn local rcsterms_`tvcvar' `rcsterms_`tvcvar''
		ereturn local drcsterms_`tvcvar' `drcsterms_`tvcvar''
		if `tvc_`tvcvar'_df'>1 {
			forvalues i = 2/`tvc_`tvcvar'_df' {
				local addknot = exp(real(word("`tvcknots_`tvcvar''",`i')))
				local exp_knots `exp_knots' `addknot' 
			}
			ereturn local tvcknots_`tvcvar' `exp_knots'
			ereturn local ln_tvcknots_`tvcvar' `tvcknots_`tvcvar''
		}
		if "`orthog'" != "" {
			ereturn matrix R_`tvcvar' = `R_`tvcvar''
		}
	}
  
	if "`orthog'" != "" & "`rcsbaseoff'" == "" {
		ereturn matrix R_bh = `R_bh'
	}
	ereturn local noconstant `constant'
	ereturn local scale `scale'
	ereturn scalar k_eform = 1
	ereturn local orthog  `orthog'
	ereturn local bhazard `bhazard'
	ereturn scalar del_entry = `del_entry'
	ereturn scalar dev = -2*e(ll)
	ereturn scalar AIC = -2*e(ll) + 2 * e(rank) 
	qui count if `touse' == 1 & _d == 1
	ereturn scalar BIC = -2*e(ll) + ln(r(N)) * e(rank) 
	ereturn local reverse `reverse'
	ereturn local cure `cure'
	if "`keepcons'" == "" {
		constraint drop `dropconslist'
	}
	else {
		ereturn local sp_constraints `dropconslist'
	}
	Replay, level(`level') `alleq' `eform' `showcons' `diopts'
end

program Replay
	syntax [, EFORM ALLEQ SHOWCons Level(int `c(level)') * ]
	_get_diopts diopts, `options'
	if "`alleq'" == "" {
		local neq neq(1)
		if "`e(scale)'" == "theta" {
			local neq neq(2)
		}
	}

/* Don't show constraints unless cnsreport option is used */
	if "`showcons'" == "" {
		local showcons nocnsreport
	}
	else {
		local showcons
	}

	ml display, `eform' `neq' `showcons' level(`level') `diopts'
end

program define _extract_varnames, rclass
version 11
/*
	This program takes a varlist that may contain factor variable
	expressions, interactions, etc, and extracts only the "parent"
	variables. Reduced varlist is saved to `r(varlist)'.
	PR, 09sep2011.
*/

// 1. Replace "#" and parens with space in each token
tokenize `*'
local varlist
while "`1'" != "" {
	mata: st_local("v", subinstr("`1'", "#", " "))
	mata: st_local("v", subinstr("`v'", "(", " "))
	mata: st_local("v", subinstr("`v'", ")", " "))
	local varlist `varlist' `v'
	macro shift
}

// 2. Strip factor junk - "." and anything to the left of it
tokenize `varlist'
local varlist
while "`1'" != "" {
*	local point : list posof "." in 1 // this does not work, for some reason
	local point = strpos("`1'", ".") // assumes `1' is no longer than 244 characters
	if (`point' > 0) local 1 = substr("`1'", `point' + 1, .)
	local varlist `varlist' `1'
	macro shift
}

// 3. Remove repeated varnames
quietly _rmcoll `varlist', forcedrop

return local varlist `r(varlist)'
end

	