
// ===============================================================================
//stmt_pred.ado Flexible parametric survival models with multiple timescales prediction file

*! version 1.4.7 06Nov2020
//Updated 20180629 removed 3 section interaction for cumulative hazard (from strcs command)- working on mata code
//Updated 20180803 added hazard ratio prediction
//Updated 20180920 HB added indicator prediction for hazards
//Updated 20180927 HB bug fixes (indicator + timescale interactions)
//Updated 20181005 HB aded fixtime options
//updated 20181101 by HB predictions for HR using predictnl outside of command
//20181107 HB new syntax using start and stop,
//20181113 HB added timename to save timescales when using predictnl for hazard ratios
//20190411 HB renamed timeid option to offset
//20200903 HB removed creation of timescales, user enters the timescales themselves using options
// ===============================================================================


program stmt_pred
	version 13.1
	syntax newvarname [if] [in], [	XB 				///
									Hazard										///
									AT(string) 								///
									ZEROs 										///
									CI 												///
									LEVel(real `c(level)') 		///
									/*timescale spec*/				///
									time1var(string)					///
									time2var(string)					///
									time3var(string)					///
									NODes(integer 30)					///
									PER(real 1)								///
								]
	marksample touse, novarlist
	local newvarname `varlist'

// ===============================================================================
	// ERROR CHECKS
/*error message if there are no observations*/
	qui count if `touse'
	if r(N)==0 {
		error 2000
	}

/*make sure there's only one prediction option*/
	local hratiotmp = substr("`hrnumerator'",1,1)
	local sdifftmp = substr("`sdiff1'",1,1)
	local hdifftmp = substr("`hdiff1'",1,1)
	if wordcount(`"`survival' `hazard' `meansurv' `hratiotmp' `sdifftmp' `hdifftmp' `xb' `xbnobaseline' `cumhazard'"') > 1 {
		display as error "You have specified more than one option for predict"
		exit 198
	}
	if wordcount(`"`survival' `hazard' `meansurv' `hrnumerator' `sdiff1'  `hdifftmp' `xb' `xbnobaseline' `cumhazard'"') == 0 {
		display as error "You must specify one of the predict options"
		exit 198
	}

	if "`stdp'" != "" & "`ci'" != "" {
		display as error "You can not specify both the ci and stdp options."
		exit 198
	}
	/*make sure that the variables in the timevar exist*/
	forvalues i=1/`e(Ntimescales)' {
		cap confirm var `time`i'var'
		if _rc>0 {
			di as error "Timescale variable defined in the time`i'var option does not exist"
			exit 198
		}
	}


/* store time-dependent effects and main varlist */
	forvalues i=1/`e(Ntimescales)'{
		local etvc_t`i' `e(tvc_t`i')'
	}
	local main_varlist `e(varlist)'

/* can't use the at option with the hrnumerator or hrdenominator */
	if "`hrnumerator'" != "" & "`at'" != "" {
		display as error "You cannot specify the at() option when using the hrnumerator() option"
		exit 198
	}
	if "`hrdenominator'" != "" & "`hrnumerator'" == "" {
		display as error "You must specifiy the hrnumerator option if you specifiy the hrdenominator option"
		exit 198
	}

	/*check that all variables are specified in the at option*/
	local allpossvar `e(varlist)' `etvc_t1'  `etvc_t2'  `etvc_t3' `e(indicator_t1)' `e(indicator_t2)' `e(indicator_t3)'
	local allpossvar : list uniq allpossvar

	if "`at'" != "" {
		tokenize `at'
		while "`1'" != "" {
				local checkat`1' 0
				foreach var in `allpossvar' {
					local checkat`1' 1 if "`1'" == "`var'"
				}
				if "`checkat`1''" == "0" {
					display as error "Variable in at() option is not in the model"
					exit 198
				}
		mac shift 2
		}
		foreach var in `allpossvar' {
			local check`var' 0
		}
		tokenize `at'
		while "`1'" ! = "" {
			foreach var in `allpossvar' {
				if "`1'" == "`var'" {
					local check`var' 1
				}
			}
	mac shift 2
	}
	foreach var in `allpossvar' {
		if "`zeros'" == "" {
			if "`check`var''" != "1" {
				display as error  "The at option doesn't include all variables included in the model."
				exit 198
			}
		}
	}
}


// ===============================================================================
// SET UP
/* Check to see if noconstant option used */
	if "`e(noconstant)'" == "" {
		tempvar cons
		qui gen `cons' = 1 if `touse'
	}
/* Preserve data for out of sample prediction  */

	tempfile newvars
	preserve
	cap drop __t?_*

/*Save indicator option so we can multiply by indicator where needed*/
	forvalues t=1/`e(Ntimescales)' {
		if "`e(indicator_t`t')'" != "" {
			local indicatoropt_t`t' *`e(indicator_t`t')'
		}
	}


/* save orthogonalisation options and R matrix if orthog was used in stmt */
	if "`e(orthog)'" != "" {
		forvalues t=1/`e(Ntimescales)' {
			tempname rmatrixt`t'
			matrix `rmatrixt`t'' = e(R_bh_t`t')
			local rmatrixopt_t`t' rmatrix(`rmatrixt`t'')
			foreach tvcvar in `e(tvc_t`t')' {
				tempname rmatrix_`tvcvar'_t`t'
				matrix `rmatrix_`tvcvar'_t`t'' = e(R_`tvcvar'_t`t')
				local rmatrixopt_`tvcvar'_t`t' rmatrix(`rmatrix_`tvcvar'_t`t'')
			}
		}
		if "`e(Ntimeint)'" != "" {
			forvalues i = 1/`e(Ntimeint)' {
				forvalues j=1/2 {
					tempname rmatrix_tint`i'_t`j'
					matrix `rmatrix_tint`i'_t`j'' = e(R_timeint`i'_t`j')
					local R_opt_timeint`i'_t`j' rmatrix(`rmatrix_tint`i'_t`j'')
				}
			}
		}
	}
//error check at options
	if "`at'" != "" | "`hrnumerator'" != "" | "`hdiff1'" != "" {
		tokenize `at' `hrnumerator' `hrdenominator' `hdiff1' `hdiff2'
		while "`1'" != "" {
			cap confirm var `1'
			if _rc {
				di as error "You're trying to predict for a variable which is not in the dataset"
				exit 198
			}
			mac shift 2
		}
	}

// ===============================================================================
// create new dataset with timescale values and regenerate the splines
// this will be used for predictions and then merged into the original file
		if "`time1var'" != "" &	wordcount(`"`hazard' `hazard' `xb'"') > 0  {
		//obtain the timescale indicator if it exists
		forvalues t=1/`e(Ntimescales)' {
			//start with creating the timscale indicator
			if "`e(indicator_t`t')'" != "" {
				cap confirm var `e(indicator_t`t')'
				if _rc != 0 {
					qui gen `e(indicator_t`t')'=.
				}
					if "`at'" != "" {
						local whereind: list posof "`e(indicator_t`t')'" in at
						tokenize `at'
						local indicatval ``=`whereind'+1''
						qui replace `e(indicator_t`t')'=`indicatval'
				}
			}
			//now recalculate the splines
			tempvar timepred`t'
			cap drop __t`t'_s*
			qui gen double `timepred`t''=  cond("`e(logtoff_t`t')'"=="",ln(`time`t'var'),`time`t'var')
		 	qui rcsgen `timepred`t'', gen(__t`t'_s) knots(`e(bhknots_t`t')')  `rmatrixopt_t`t''
			//indicator option for baseline timescales (not tvc)
			if "`e(indicator_t`t')'" != "" {
				forvalues df = 1/`e(dfbase_t`t')' {
					qui replace __t`t'_s`df' = __t`t'_s`df'*`e(indicator_t`t')'
				}
			}
			//tvc splines (interacted later)
			if "`e(tvc_t`t')'" != "" {
				local tvcvarnames `tvcvarnames' `e(tvc_t`t')'
				foreach tvcvar in `e(tvc_t`t')' {
					cap drop __t`t'_s_`tvcvar'
					cap confirm var `tvcvar'
					if _rc !=0 {
						qui gen `tvcvar'=.
					}
					qui rcsgen `timepred`t'' , gen(__t`t'_s_`tvcvar') knots(`e(tvcknots_t`t'_`tvcvar')') `rmatrixopt_`tvcvar'_t`t''
				}
			}
		}

		//recalculate the splines for the timescale interactions
		if "`e(Ntimeint)'" != "" {
			forvalues i = 1/`e(Ntimeint)' {
				cap drop tempint*
				qui rcsgen `timepred`e(timeint`i'_t1)'', gen(tempint`i'_t`e(timeint`i'_t1)') knots(`e(knots_timeint`i'_t1)') `R_opt_timeint`i'_t1'
				if "`e(indicator_t`e(timeint`i'_t1)')'" != "" {
					forvalues j = 1/`e(df_timeint`i'_t1)' {
						qui replace tempint`i'_t`e(timeint`i'_t1)'`j'= tempint`i'_t`e(timeint`i'_t1)'`j' * `e(indicator_t`e(timeint`i'_t1)')'
					}
				}
				qui rcsgen `timepred`e(timeint`i'_t2)'', gen(tempint`i'_t`e(timeint`i'_t2)') knots(`e(knots_timeint`i'_t2)') `R_opt_timeint`i'_t2'

				if "`e(indicator_t`e(timeint`i'_t2)')'" != "" {
					forvalues j = 1/`e(df_timeint`i'_t2)' {
						qui replace tempint`i'_t`e(timeint`i'_t2)'`j'= tempint`i'_t`e(timeint`i'_t2)'`j' * `e(indicator_t`e(timeint`i'_t2)')'
					}
				}
				forvalues j = 1/`e(df_timeint`i'_t1)' {
					forvalues k = 1/`e(df_timeint`i'_t2)' {
						qui gen __t`e(timeint`i'_t1)'_t`e(timeint`i'_t2)'_s`j'`k'= tempint`i'_t`e(timeint`i'_t1)'`j' * tempint`i'_t`e(timeint`i'_t2)'`k'
					}
				}
			}
		}

		//need to make sure all the variables in the dataset are included
		// make all variables all zero if zeros option included

		foreach var in `allpossvar' {
			capture confirm var `var'
			if _rc != 0 {
				qui gen `var'=.
			}
		}
		if "`zeros'" != "" {
			forvalues t = 1/`e(Ntimescales)' {
				local tmptvc `e(tvc_t`t')'
				foreach var in `e(varlist)' {
					_ms_parse_parts `var'
					if `"`: list posof `"`r(name)'"' in at'"' == "0" {
						qui replace `r(name)' = 0
						if `"`: list posof `"`r(name)'"' in tmptvc'"' != "0" {
							forvalues i = 1/`e(df_`r(name)'_t`t')' {
								qui replace __t`t'_s_`r(name)'`i' = 0
							}
						}
					}
				}
			}
		}



		// use the at option with or without the zeros option
		if "`at'" != "" | "`hrnumerator'" != "" | "`hdiff1'" != "" {
			tokenize `at' `hrnumerator' `hrdenominator' `hdiff1' `hdiff2'
			while "`1'" != "" {
				cap confirm var `1'
				if _rc {
					qui gen `1' = .
				}
				fvunab tmpfv: `1'
				local 1 `tmpfv'
				_ms_parse_parts `1'
				if "`r(type)'"!="variable" {
					display as error "level indicators of factor" /*
									*/ " variables may not be individually set" /*
									*/ " with the at() option; set one value" /*
									*/ " for the entire factor variable"
					exit 198
				}
				cap confirm var `2'
				if _rc {
					cap confirm num `2'
					if _rc {
						di as err "invalid at(... `1' `2' ...)"
						exit 198
					}
				}
				qui replace `1' = `2'
				forvalues t = 1/`e(Ntimescales)' {
					if `"`: list posof `"`1'"' in etvc_t`t''"' != "0" {
						local tvcvar `1'
						forvalues i = 1/`e(df_`tvcvar'_t`t')' {
						qui replace __t`t'_s_`tvcvar'`i' = __t`t'_s_`tvcvar'`i'*`tvcvar' `indicatoropt_t`t''
						}
					}
				}
				mac shift 2
			}
		}

		// check no missing values for the variables in the model
		foreach var in `e(varlist)' `tvcvarnames' {
			qui sum `var'
			if `r(N)' == 0  & "`zeros'"=="" {
				di as error "Please use the at option to define values of `var' you wish to predict for"
				exit 198
			}
		}
		cap drop `touse' _d _t
		gen `touse'=1
	//	marksample touse, novarlist
		qui gen _d=.
		qui gen _t=.

	}

	else 	if "`time1var'" == "" & 	wordcount(`"`hazard' `hazard' `xb'"') > 0{
		/* zeros */
		if "`zeros'" != "" {
			forvalues t = 1/`e(Ntimescales)' {
				local tmptvc `e(tvc_t`t')'
				foreach var in `e(varlist)' {
					_ms_parse_parts `var'
					if `"`: list posof `"`r(name)'"' in at'"' == "0" {
						qui replace `r(name)' = 0 if `touse'
						if `"`: list posof `"`r(name)'"' in tmptvc'"' != "0" {
							forvalues i = 1/`e(df_`r(name)'_t`t')' {
								qui replace __t`t'_s_`r(name)'`i' = 0 if `touse'
							}
						}
					}
				}
			}
		}

		/* Out of sample predictions using at() */
		if "`at'" != "" | "`hrnumerator'" != "" | "`sdiff1'" != "" | "`hdiff1'" != "" {
			tokenize `at' `hrnumerator' `hrdenominator' `hdiff1' `hdiff2'
			while "`1'"!="" {
				fvunab tmpfv: `1'
				local 1 `tmpfv'
				_ms_parse_parts `1'
				if "`r(type)'"!="variable" {
					display as error "level indicators of factor" /*
									*/ " variables may not be individually set" /*
									*/ " with the at() option; set one value" /*
									*/ " for the entire factor variable"
					exit 198
				}
				cap confirm var `2'
				if _rc {
					cap confirm num `2'
					if _rc {
						di as err "invalid at(... `1' `2' ...)"
						exit 198
					}
				}
				qui replace `1' = `2' if `touse'
				//this alters the rcs-tvc interaction if tvc is in the at option (or in hr hdiff etc.)
				forvalues t = 1/`e(Ntimescales)' {
					if `"`: list posof `"`1'"' in etvc_t`t''"' != "0" {
						local tvcvar `1'
						capture drop __t`t'_s_`tvcvar'*
						forvalues i = 1/`e(df_`tvcvar'_t`t')' {
							qui replace __t`t'_s_`tvcvar'`i' = __t`t'_s_`tvcvar'`i'*`tvcvar' `indicatoropt_t`t''
						}
					}
				}
				mac shift 2
			}


		}
	}

// ===============================================================================
// PREDICT LINEAR PREDICTOR
	if "`e(k_eq)'" == "1" {
		local xb_eq
	}
	else if "`e(k_eq)'" == "2" {
		local xb_eq  + xb(xb)
	}
	if "`xb'" != "" {
		qui predictnl double `newvarname' = xb(rcs) `xb_eq' if `touse', ///
			ci(`newvarname'_lci `newvarname'_uci) level(`level')
	}

// ===============================================================================
//PREDICT HAZARD
	if "`hazard'" != "" {
		tempvar lnh
		if "`ci'" != "" {
			tempvar lnh_lci lnh_uci
			local prednlopt ci(`lnh_lci' `lnh_uci') level(`level')
		}
		predictnl double `lnh' = xb(rcs) `xb_eq'   if `touse', `prednlopt'

		/* Transform back to hazard scale */
		qui gen double `newvarname' = exp(`lnh')*`per' if `touse'

		if "`ci'" != "" {
			qui gen `newvarname'_lci = exp(`lnh_lci')*`per'  if `touse'
			qui gen `newvarname'_uci =  exp(`lnh_uci')*`per' if `touse'
		}
	}



// ===============================================================================
//RESTORE ORIGINAL DATA AND MERGE IN NEW VARIABLES

local keep `newvarname'
if "`ci'" != "" {
	local keep `keep' `newvarname'_lci `newvarname'_uci
}
else if "`stdp'" != "" {
	local keep `keep' `newvarname'_se
}
keep `keep'
tempfile newvars
qui save `"`newvars'"'
restore
merge 1:1 _n using `"`newvars'"', nogenerate noreport
end
