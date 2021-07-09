
// ===============================================================================
//stmt.ado Flexible parametric survival models with multiple timescales

*! version 1.4.7 06Nov2020
// Updated 20170704 better syntax
// Updated 20170919 two-way timescale interactions (V1.3)
// Updated 20170920 allow multiple timescales for a sub-population
// Updated 20180529 removed the rmat option in first rcsgens since it wasn't being used
//Updated 20180605 fixed error with swapping of timescales
// Updated 20180629 updated ereturn
//Updated 20180927 HB bug fixes (indicator + timescale interactions)
//Updated V1.4.1 20190529 added options to allow for knot position of timescale interaction
//Updated V1.4.2 20190604 bug fix for using tvcknots() option (problem in initial values)
//Updated V1.4.6: bug fixes for indicator option (indicator options in if2 option of rcsgen)
// ===============================================================================


program stmt, eclass byable(onecall)
        version 13.1
        if _by() {
                local by "by `_byvars'`_byrc0':"
        }
        if replay() {
                syntax  [, TIME1(string) *]
                if "`time1'" != "" {
                        `by' Estimate `0'
                        ereturn local cmdline `"stmt `0'"'
                }
                else {
                        if "`e(cmd)'" != "stmt" {
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
        ereturn local cmdline `"stmt `0'"'
end

program parse_timescale_opt , sclass
	version 12.1

	syntax ///
	[ , 					///
		DF(string) 			///
		KNOTS(string)		///
		BKnots(numlist ascending min=2 max=2) ///
		BKNOTSTvc(string)	///
		KNSCale(string)		///
		LOGToff 			///
		TVC(varlist) 		///
		START(varname)		///
		DFTvc(string)		///
		KNOTSTvc(string)	///
		INDIcator(varname)  ///
	]

	sreturn local df `df'
	sreturn local knots `knots'
	sreturn local bknots `bknots'
	sreturn local bknotstvc `bknotstvc'
	sreturn local knscale `knscale'
	sreturn local logtoff `logtoff'
	sreturn local tvc `tvc'
	sreturn local start `start'
	sreturn local dftvc `dftvc'
	sreturn local knotstvc `knotstvc'
	sreturn local indicator `indicator'
end


program Estimate, eclass byable(recall)
        st_is 2 analysis
        syntax  [varlist(default=empty)]                               		///
                        [fw pw iw aw]                                       ///
                        [if] [in] [,                                        ///
                        TIME1(string)                                       ///
                        TIME2(string)                                       ///
                        TIME3(string)                                       ///
						TIMEINT(string)							            ///
						TIMEINTKnots(string)								///
						TIMEINTBKnots(string)								///
                        noORTHog                                            ///
                        noCONStant                                          ///
                        noHR                                                ///
                        NODes(integer 30)                                   ///
                        VERBose                                             ///
                        INITh(varname)                                      ///
                        FROM(string)                                        ///
						MLMethod(string)								    ///
                        ][                                                  ///
                        noLOg			                                    ///
						*													///-mlopts- options
                        ]

ereturn local cmdline `"stmt `0'"'

//SAVE TIMESCALE OPTIONS============================================================
if "`time1'" == "" {
	display as error "You need to specify options for the first timescale using the time1() option"
	exit 198
}

//how many timescales?
if "`time2'" ! = "" {
	local maxtscale 2
	if "`time3'" != "" {
		local maxtscale 3
	}
}
else local maxtscale 1

//save locals
forvalues t=1/`maxtscale' {
	parse_timescale_opt, `time`t''
	local dft`t' `s(df)'
	local knotst`t' `s(knots)'
	local bknotst`t' `s(bknots)'
	local bknotstvct`t' `s(bknotstvc)'
	local knscalet`t' `s(knscale)'
	local logt`t'off `s(logtoff)'
	local tvct`t' `s(tvc)'
	local startt`t' `s(start)'
	local dftvct`t' `s(dftvc)'
	local knotstvct`t' `s(knotstvc)'
	local indicatort`t' `s(indicator)'
}

//ERROR CHECKS ============================================================

/* Check rcsgen is installed */
		capture which rcsgen
        if _rc >0 {
            display in yellow "You need to install the command rcsgen. This can be installed using,"
            display in yellow ". {stata ssc install rcsgen}"
            exit  198
        }

/*  Weights*/
        if "`weight'" != "" {
			display as err "weights must be stset"
            exit 101
        }
        local wt: char _dta[st_w]
        local wtvar: char _dta[st_wv]
        if "`wt'" != "" {
            local fw fw(`wtvar')
        }

/* Temporary variables */
        tempvar  hazard cons timescalet1 timescalet2 timescalet3 lnt cumhazard lnhazard _t1 _t2 _t3
        tempname initmat R_bh_t1 R_bh_t2 R_bh_t3

/* Marksample and mlopts */
        marksample touse
        qui replace `touse' = 0  if _st==0

        qui count if `touse'
        local N `r(N)'
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


/* Drop previous created spline terms __t* */
        capture drop __t?_s*
		capture drop __t?_d*
		capture drop __t?_t?_*



/* generate local hast2 if dft2 or knotst2 and startt2 are defined (and for timescale 3)*/
		forvalues tsuffix=2/3 {
			if "`time`tsuffix''" != "" {
				local hast`tsuffix' hast`tsuffix'
				if "`startt`tsuffix''" == "" {
					display as error "Must specify the start value of timescale using the start() option when using the df() or knots() option within the time`tsuffix'() option "
					exit 198
				}
			}
			if "`startt`tsuffix''" != "" {
				local hast`tsuffix' hast`tsuffix'
				if "`dft`tsuffix''" == "" & "`knotst`tsuffix''" == "" {
					display as error "Must specify either the df() or knots() option when using start() in the time`tsuffix'() option"
					exit 198
				}
			}
		}

  /* make sure there is a timescale 2 if there is a timescale 3*/
	if "`hast3'" ! = "" {
		if "`hast2'" == "" {
			display as error "Must specify the second timescale using the time2() option when using a third timescale"
			exit 198
		}
	}

/* set local for loops with t1 and t2 */
		if "`hast3'" != "" {
			local toptimescale 3
		}
		else if "`hast2'" != "" {
			local toptimescale 2
		}
		else local toptimescale 1

/*NOT USED, captured later on in another error message?
/* Ignore options associated with time-dependent effects if specified without the tvc option */
        forvalues timetvcopt = 1/3 {
			if "tvct`timetvcopt'" == "" {
				foreach opt in dftvct`timetvcopt' knotstvct`timetvcopt' {
					if "``opt''" != "" {
						display as txt _n "[`opt'() used without specifying tvc() in the time`timetvcopt'() option, sub-option ignored]"
						local `opt'
					}
				}
			}
        }
*/

/*Only use indicator for second or third timescale*/
if "`indicatort1'" != "" {
  display as error "Indicator option should only be used for the second or third timescale, please redefine timescales"
  exit 198
}

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

/* generate log time or untransformed time on both timescales */
        qui gen double `lnt' = ln(_t) if `touse'
		qui gen double `_t1' = _t if `touse'
        if "`logt1off'" == "" {
            qui gen double `timescalet1' = ln(_t) if `touse'
        }
        else {
            qui gen double `timescalet1' = _t if `touse'
        }
		forvalues tsuffix=2/3 {
			if "`hast`tsuffix''" != "" {
				qui gen double `_t`tsuffix'' = _t + `startt`tsuffix'' if `touse'
				if "`logt`tsuffix'off'" == "" {
					qui gen double `timescalet`tsuffix'' = ln(_t + `startt`tsuffix'') if `touse'
				}
				else {
					qui gen double `timescalet`tsuffix'' = _t + `startt`tsuffix'' if `touse'
				}
			}
		}

/* check df option is an integer */
	forvalues ts = 1/`toptimescale' {
		if "`dft`ts''" != "" {
			capture confirm integer number `dft`ts''
			if _rc>0 {
				display as error "df() sub-option of time`ts'() must be an integer"
				exit 198
			}
			if `dft`ts''<1 {
				display as error "df()  sub-option of time`ts'() must be 2 or more"
				exit 198
			}
		}
	/*Check we have a binary variable for indicator */
		if "`indicatort`ts''"!= "" {
			qui levelsof `indicatort`ts''
			if "`r(levels)'" != "0 1" {
				di as error "Please use an indicator variable for timescale `ts' that is a binary variable coded 0 1"
				exit 198
			}
			local indopt`ts' & `indicatort`ts''==1
		}

	}

/* Only one of df and knots can be specified */
	foreach timesuffix in t1 t2 t3 {
        if "`dft`timesuffix''" != "" & "`knotst`timesuffix''" != "" {
            display as error "Only one of df() OR knots() can be specified within time`ts'()"
            exit 198
        }
	}

/* df must be specified */
        if ("`knotst1'" == "" & "`dft1'" == "") {
            display as error "Use of either the df() or knots() option is compulsory for the time1() option"
            exit 198
        }

/* knots given on which scale */
        if "`knscalet1'" == "" {
            local knscalet1 time
        }
        if inlist(substr("`knscalet1'",1,1),"t","l","c") != 1 {
            display as error "Invalid knscale() sub-option of the time1() option"
            exit 198
        }
		forvalues tsuffix= 2/3 {
			if "`hast`tsuffix''" != "" {
				if "`knscalet`tsuffix''" == "" {
					local knscalet`tsuffix' time
				}
				if inlist(substr("`knscalet`tsuffix''",1,1),"t","l","c") != 1 {
					display as error "Invalid knscale() sub-option of the time`tsuffix'() option"
					exit 198
				}
			}
		}

/* cannot specify both inith and from options at the same time */
		if "`inith'" != "" & "`from'" != "" {
			display as error "Only one of inith or from can be specified"
			exit 198
		}

/* mlmethod option use gf2 as default if not specified otherwise */
		if "`mlmethod'" == ""  {
			local mlmethod gf2
		}

/* error message for tvc */
forvalues ts = 1/`toptimescale' {
	if "`dftvct`ts''" != "" | "`knotstvct`ts''" != "" {
		if "`tvct`ts''" == "" {
			display as error "The tvc() sub-option of the time`ts'() option is compulsory when using the  dftvc() or knotstvc() sub-option"
			exit 198
		}
	}
}

/*
/*set reverse options- NOT CURRENTLY IMPLEMENTED*/
forvalues ts = 1/`toptimescale' {
	if "`reverset`ts''" != "" {
		local reverset`ts' reverse
	}
}
*/

/* error messages and organisation of timeint option*/
//separate the different interactions
if "`timeint'" != "" {
	tokenize "`timeint'", parse("|")
	local ntimeint 0
	while "`1'" != "" {
		local ntimeint = `ntimeint' +1
		local timeint`ntimeint' `1'
		macro shift 2
	}
	if `ntimeint' > 4 {
		di as error "Up to 4 timescale interactions allowed"
		exit 198
	}
	//separate the timescales and save as locals, error checks for syntax
	forvalues i = 1/`ntimeint' {
		tokenize `timeint`i''
		local timeint`i' `1'
		local dftimeint`i' `2'
	}
	forvalues i = 1/`ntimeint' {
		tokenize `timeint`i'', parse(":")
		foreach j in 1 3 {
			if substr("``j''",1,1) != "t" {
				di as error
				exit 198
			}
		}
		local tint`i'_t1 =substr("`1'",2,1)
		local tint`i'_t2 =substr("`3'",2,1)
		tokenize `dftimeint`i'', parse(":")
		local dftint`i'_t1 `1'
		local dftint`i'_t2 `3'
		if "`dftint`i'_t1'" == "" | "`dftint`i'_t2'" == "" {
			di as error "Specify both degrees of freedom for the timescale interactions"
			exit 198
		}
		if "`dftint`i'_t1'"=="." {
			if "`dftint`i'_t2'" != "." {
				di as error "Please enter the knot positions for the timescale interactions using the timeintknots() option and specify the df in the timeint() option as ."
				exit 198
			}
			if "`timeintknots'" == "" {
				di as error "Please enter the knot positions for the timescale interactions using the timeintknots() option and specify the df in the timeint() option as ."
				exit 198
			}
		}
		else if `dftint`i'_t1'>= 10 | `dftint`i'_t2' >= 10 {
			di as error "Degrees of freedom for timescale interactions must be < 10"
			exit 198
		}
	}
  forvalues i = 1/`ntimeint' {
    forvalues j=1/2 {
     forvalues k=1/3 {
       if "`tint`i'_t`j''" == "`k'" {
         local tintind`i'`j' `indicatort`k''
          if "`indicatort`k''" ! = "" {
           local tintind`i'`j'_opt & `tintind`i'`j''==1
          }
       }
     }
   }
}
	//save knots and boundary knots if they are specified for timescale interaction
	if "`timeintknots'" != "" {
		local i 0
		tokenize `timeintknots', parse("|")
		while "`1'" != "" {
			local i = `i' +1
			local timeintknots`i' `1'
			macro shift 2
		}
		forvalues tint=1/`i' {
			tokenize `timeintknots`tint'', parse(":")
			local timeint`tint'_knotst1 "`1'"
			local timeint`tint'_knotst2 "`3'"
			local dftint`tint'_t1= `=wordcount("`1'")+1'
			local dftint`tint'_t2= `=wordcount("`3'")+1'
			if "`timeintbknots'" == "" {
				summ `_t`tint`tint'_t1'' if `touse' & _d == 1, meanonly
				local timeint`tint'_knotst1 `r(min)' `timeint`tint'_knotst1' `r(max)'
				summ `_t`tint`tint'_t2'' if `touse' & _d == 1, meanonly
				local timeint`tint'_knotst2 `r(min)' `timeint`tint'_knotst2' `r(max)'
			}
		}
	}
	//boundary knots
	if "`timeintbknots'" != "" {
		local i 0
		tokenize `timeintbknots', parse("|")
		while "`1'" != "" {
			local i = `i' +1
			local timeintbknots`i' `1'
			macro shift 2
		}
		forvalues tint=1/`i' {
			tokenize `timeintbknots`tint'', parse(":")
			local timeint`tint'_bknotst1 "`1'"
			local timeint`tint'_bknotst2 "`3'"
			if "`timeintknots'" != "" {
				tokenize `timeint`tint'_bknotst1'
				local timeint`tint'_knotst1 `1' `timeint`tint'_knotst1' `2'
				tokenize `timeint`tint'_bknotst2'
				local timeint`tint'_knotst2 `1' `timeint`tint'_knotst2' `2'
			}
			else {
				local timeint`tint'_bknotst1_opt bknots(`timeint`tint'_bknotst1')
				local timeint`tint'_bknotst2_opt bknots(`timeint`tint'_bknotst2')
			}
		}
	}
}

//KNOT PREP ====================================================================

/* Baseline boundary knots */
	forvalues ts = 1/`toptimescale' {
        if "`bknotst`ts''" == "" {
            qui summ `_t`ts'' if `touse' & _d == 1, meanonly
            *qui summ `timescalet`ts'' if `touse' & _d == 1, meanonly
            local lowerknott`ts' `r(min)'
			local upperknott`ts' `r(max)'
            if substr("`knscalet`ts''",1,1) == "c" {
                local lowerknott`ts' 0
                local upperknott`ts' 100
            }
        }
        else if substr("`knscalet`ts''",1,1) == "t" {
            local lowerknott`ts' = word("`bknotst`ts''",1)
            local upperknott`ts' = word("`bknotst`ts''",2)
        }
        else if substr("`knscalet`ts''",1,1) == "l" {
            local lowerknott`ts' = exp(real(word("`bknotst`ts''",1)))
            local upperknott`ts' = exp(real(word("`bknotst`ts''",2)))
        }
        else if substr("`knscalet`ts''",1,1) == "c" {
            local lowerknott`ts' = word("`bknotst`ts''",1)
            local upperknott`ts' = word("`bknotst`ts''",2)
        }


/* Boundary Knots for tvc variables */
        if "`bknotstvct`ts''" != "" {
            tokenize `bknotstvct`ts''
            while "`1'"!="" {
                cap confirm var `1'
                if _rc == 0 {
                    if `"`: list posof `"`1'"' in tvct`ts''"' == "0" {
                        display as error "`1' is not listed in the tvct`ts'() option"
                        exit 198
                    }
                    local tmptvc `1'
                }
                cap confirm num `2'
                if _rc == 0 {
                    if substr("`knscalet`ts''",1,1) == "t" {
                        local lowerknott`ts'_`tmptvc' `2'
                    }
                    else if substr("`knscalet`ts''",1,1) == "l" {
                        local lowerknott`ts'_`tmptvc' =exp(`2')
                    }
                    else if substr("`knscalet`ts''",1,1) == "c" {
                        local lowerknott`ts'_`tmptvc' `2'
                    }
                }
                cap confirm num `3'
                if _rc == 0 {
                    if substr("`knscalet`ts''",1,1) == "t" {
                        local upperknott`ts'_`tmptvc' `3'
                    }
                    else if substr("`knscalet`ts''",1,1) == "l" {
                        local upperknott`ts'_`tmptvc' =exp(`3')
                    }
                    else if substr("`knscalet`ts''",1,1) == "c" {
                        local upperknott`ts'_`tmptvc' `3'
                    }
                }
                else {
                    cap confirm var `3'
                    if _rc {
                        display as error "bknotstvct`ts'() option incorrectly specified"
                        exit 198
                    }
                }
                macro shift 3
            }
        }
        foreach tvcvar in `tvc' {
            if "`lowerknot_`tvcvar''" == "" {
                local lowerknott`ts'_`tvcvar' = `lowerknott`ts''
                local upperknott`ts'_`tvcvar' = `upperknott`ts''
            }
        }


 /* store the minimum and maximum of all boundary knots */
        local minknott`ts' `lowerknott`ts''
        local maxknott`ts' `upperknott`ts''
        foreach tvcvar in `tvc' {
			local minknott`ts' = min(`minknott`ts'',`lowerknot_`tvcvar'')
			local maxknott`ts' = max(`maxknott`ts'',`upperknott`ts'_`tvcvar'')
			if "`logt`ts'off'" == "" & inlist(substr("`knscalet`ts''",1,1),"t","l") == 1  {
				local lowerknott`ts'_`tvcvar'= ln(`lowerknott`ts'_`tvcvar'')
				local upperknott`ts'_`tvcvar'= ln(`upperknott`ts'_`tvcvar'')
			}
		}




// GENERATE BASELINE SPLINES==========================================================
	// degrees of freedom specified
		if "`dft`ts''" != "" {
			// no boundary knots specified
			if "`bknotst`ts''" == "" {
				qui rcsgen `timescalet`ts'' if `touse', gen(__t`ts'_s) df(`dft`ts'') `orthog' /*`rmatrixopt'*/ if2(_d==1 & `touse' `indopt`ts'') `reverset`ts'' dgen(__t`ts'_d_s)
				local bhknotst`ts' `r(knots)'
			}
			//boundary knots specified
			else if "`bknotst`ts''" != "" {
				// fit on the log time scale
				if "`logt`ts'off'" == "" {
					foreach i in `lowerknott`ts'' `upperknott`ts'' {
						local lnbknots = ln(`i')
						local bknotst`ts'list `bknotst`ts'list' `lnbknots'
					}
				}
				// fit on the time scale
				else if "`logt`ts'off'" != "" {
					foreach i in `lowerknott`ts'' `upperknott`ts'' {
						local bknotst`ts'list `bknotst`ts'list' `i'
					}
				}
				//generate the baseline splines
				qui rcsgen `timescalet`ts'' if `touse' , gen(__t`ts'_s) df(`dft`ts'') bknots(`bknotst`ts'list') `orthog' /*`rmatrixopt'*/ if2(_d==1 & `touse' `indopt`ts'') `reverset`ts'' dgen(__t`ts'_d_s)
				local bhknotst`ts' `r(knots)'

			}
		}
       // knots instead of df specified
		if "`dft`ts''" == "" & inlist(substr("`knscalet`ts''",1,1),"t","l") == 1 {
			local bhknotst`ts'list `lowerknott`ts''
			foreach k in `knotst`ts'' {
				capture confirm number `k'
				if _rc>0 {
					display as error "Error in knot specification."
					exit 198
				}
				if substr("`knscalet`ts''",1,1) == "t" {
					local tmpknot `k'
				}
				else if substr("`knscalet`ts''",1,1) == "l" {
					local tmpknot  = exp(`k')
				}
				local bhknotst`ts'list `bhknotst`ts'list' `tmpknot'
			}
			local bhknotst`ts'list `bhknotst`ts'list' `upperknott`ts''
			if "`logt`ts'off'" == "" {
				foreach k in `bhknotst`ts'list' {
					local tmpknot = ln(`k')
					local tmpknotst`ts'list `tmpknotst`ts'list' `tmpknot'
				}
				local bhknotst`ts'list `tmpknotst`ts'list'
			}
			qui rcsgen `timescalet`ts'' if `touse', gen(__t`ts'_s) knots(`bhknotst`ts'list') `orthog' /*`rmatrixopt'*/ `reverset`ts'' if2(_d==1 & `touse' `indopt`ts'') dgen(__t`ts'_d_s)
			local dft`ts' = wordcount("`r(knots)'") - 1
			local bhknotst`ts' `r(knots)'
        }

        else if substr("`knscalet`ts''",1,1) == "c" {
			local bhknotst`ts'list `lowerknott`ts'' `knotst`ts'' `upperknott`ts''
			qui rcsgen `timescalet`ts'' if `touse' , gen(__t`ts'_s) percentiles(`bhknotst`ts'list') `orthog' /*`rmatrixopt'*/ `reverset`ts'' if2(_d==1 & `touse' `indopt`ts'')  dgen(__t`ts'_d_s)
			local nknotst`ts' = wordcount("`r(knots)'")
			local dft`ts' = wordcount("`r(knots)'") - 1
			local bhknotst`ts' `r(knots)'
			tokenize `r(knots)'
			if "`logt`ts'off'" == "" {
				local minknott`ts' =exp(`1')
				local maxknott`ts' =exp(``nknotst`ts''')
			}
			else {
				local minknott`ts' =`1'
				local maxknott`ts' =``nknotst`ts'''
			}
        }
		local Nbhknots_t`ts' : word count `bhknotst`ts''

		/*interact with indicator variable*/
		if "`indicatort`ts''" != "" {
			forvalues i = 1/`dft`ts''{
				qui replace __t`ts'_s`i'=__t`ts'_s`i' * `indicatort`ts''
				qui replace __t`ts'_d_s`i'=__t`ts'_d_s`i' * `indicatort`ts''
			}

		}

        /* create list of spline terms */
        forvalues i = 1/`dft`ts'' {
			local rcsterms_base_t`ts' "`rcsterms_base_t`ts'' __t`ts'_s`i'"
        }
        local rcstermst`ts' `rcstermst`ts'' `rcsterms_base_t`ts''
		if "`orthog'" != "" {
			matrix `R_bh_t`ts'' = r(R)
			local R_bh_t`ts'_opt rmatrix(`R_bh_t`ts'')
		}


	}


//VARIABLES WITH TIME-VARYING COEFFICIENTS===============================================
forvalues ts = 1/`toptimescale' {

/* df for time-varying coefficients */
        if "`tvct`ts''"  != "" {
            if "`dftvct`ts''" == "" & "`knotstvct`ts''" == ""  {
                display as error "The dftvc() or knotstvc() option is compulsory if you use the tvc() sub-option of the time`ts'() option"
                exit 198
            }
			// dftvc specified
			if "`knotstvct`ts''" == "" & "`dftvct`ts''" != "" {
				local ntvcdft`ts': word count `dftvct`ts''
				local lasttvcdft`ts' : word `ntvcdft`ts'' of `dftvct`ts''
				capture confirm number `lasttvcdft`ts''
					if `ntvcdft`ts'' == 1 | _rc==0 {
					foreach tvcvart`ts' in  `tvct`ts'' {
						if _rc==0 {
							local tmptvc = subinstr("`1'",".","_",1)
							local tvc_`tvcvart`ts''_df_t`ts' `lasttvcdft`ts''

						}
					}

				}
				if `ntvcdft`ts''>1 | _rc >1 {
					tokenize "`dftvct`ts''"
					forvalues i = 1/`ntvcdft`ts'' {
						local tvcdft`ts'list`i' ``i''
					}
					forvalues i = 1/`ntvcdft`ts'' {
						capture confirm number `tvcdft`ts'list`i''
						if _rc>0 {
							tokenize "`tvcdft`ts'list`i''", parse(":")
							confirm var `1'
							if `"`: list posof `"`1'"' in tvct`ts''"' == "0" {
								display as error "`1' is not listed in the tvc() sub-option of the time`ts'() option"
								exit 198
							}
							local tmptvc `1'
							local tvc_`tmptvc'_df_t`ts' 1
						}
						local `1'_df_t`ts' `3'
					}
				}
			}

			/* check all time-varying coefficients have been specified */
			if "`knotstvct`ts''" == "" {
				foreach tvcvar in `tvct`ts'' {
					if "`tvc_`tvcvar'_df_t`ts''" == "" {
						display as error "df for time-dependent effect of `tvcvar' are not specified in the time`ts'() option"
						exit 198
					}
				}
				forvalues i = 1/`ntvcdft`ts'' {
					tokenize "`tvcdft`ts'list`i''", parse(":")
					local tvc_`1'_df_t`ts' `3'
				}
			}

			/* knotstvc option */
			if "`knotstvct`ts''" != "" {
				if "`dftvct`ts''" != "" {
					display as error "You can not specify both the dftvc() and knotstvc() sub-options for the time`ts'() option"
					exit 198
				}
				tokenize `knotstvct`ts''
				cap confirm var `1'
				if _rc >0 {
					display as error "Specify the tvc variable(s) when using the knotstvc() sub-option of the time`ts'() option"
					exit 198
				}
				while "`2'"!="" {
					cap confirm var `1'
					if _rc == 0 {
						if `"`: list posof `"`1'"' in tvct`ts''"' == "0" {
							display as error "`1' is not listed in the tvc() sub-option in the time`ts'() option"
							  exit 198
						}
						local tmptvc `1'
						local tvc_`tmptvc'_df_t`ts' 1
					}
					cap confirm num `2'
					if _rc == 0 {
						if "`logt`ts'off'" == "" {
							if substr("`knscalet`ts''",1,1) == "t" {
								local newknot = ln(`2')
							}
							else if substr("`knscalet`ts''",1,1) == "l" {
								local newknot `2'
							}
							else if substr("`knscalet`ts''",1,1) == "c" {
								local newknot `2'
							}
						}
						else {
							if substr("`knscalet`ts''",1,1) == "t" {
								local newknot `2'
							}
							else if substr("`knscalet`ts''",1,1) == "l" {
								local newknot = exp(`2')
							}
							else if substr("`knscalet`ts''",1,1) == "c" {
								local newknot `2'
							}
						}
						local tvcknotst`ts'_`tmptvc'_user `tvcknotst`ts'_`tmptvc'_user' `newknot'
						local tvc_`tmptvc'_df_t`ts' = `tvc_`tmptvc'_df_t`ts'' + 1
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

		}
         /* create splines for time-varying coefficients*/
        if "`tvct`ts''" != "" {
            tempvar tvctimevar
            foreach tvcvar in `tvct`ts'' {
                capture drop `tvctimevar'

				//df specified for tvc
                if "`knotstvct`ts''" == "" {
					if "`bknotstvct`ts''" == "" {
						if "`bknotst`ts''" == "" {
						qui rcsgen `timescalet`ts'' if `touse' , df(`tvc_`tvcvar'_df_t`ts'') gen(__t`ts'_s_`tvcvar') `orthog' if2(_d==1  & `touse' `indopt`ts'') `reverset`ts''   dgen(__t`ts'_d_s_`tvcvar')

						}
						else if "`bknotst`ts''" != "" {
							qui rcsgen `timescalet`ts'' if `touse' , df(`tvc_`tvcvar'_df_t`ts'') gen(__t`ts'_s_`tvcvar') bknots(`bknotst`ts'list') `orthog' if2(_d==1  & `touse' `indopt`ts'') `reverset`ts'' dgen(__t`ts'_d_s_`tvcvar')
						}
					}
					else if "`bknotstvct`ts''" != "" {
						qui rcsgen `timescalet`ts'' if `touse' , df(`tvc_`tvcvar'_df_t`ts'') gen(__t`ts'_s_`tvcvar') bknots(`lowerknott`ts'_`tvcvar'' `upperknott`ts'_`tvcvar'') `orthog' if2(_d ==1  & `touse' `indopt`ts'') `reverset`ts'' dgen(__t`ts'_d_s_`tvcvar')
					}
				}
				// knots specified for tvc
				else if "`knotstvct`ts''" != "" {
					if inlist(substr("`knscalet`ts''",1,1),"t","l") == 1 {
						qui rcsgen `timescalet`ts'' if `touse', knots(`lowerknott`ts'_`tvcvar'' `tvcknotst`ts'_`tvcvar'_user' `upperknott`ts'_`tvcvar'') gen(__t`ts'_s_`tvcvar') `orthog' if2(_d==1  & `touse' `indopt`ts'') `reverset`ts'' dgen(__t`ts'_d_s_`tvcvar')
					}
					else if substr("`knscalet`ts''",1,1) == "c" {
						qui rcsgen `timescalet`ts'' if `touse', percentiles(`lowerknott`ts'_`tvcvar'' `tvcknotst`ts'_`tvcvar'_user' `upperknott`ts'_`tvcvar'') gen(__t`ts'_s_`tvcvar') `orthog' if2(_d==1  & `touse' `indopt`ts'') `reverset`ts'' dgen(__t`ts'_d_s_`tvcvar')
					}
				}
				if `tvc_`tvcvar'_df_t`ts'' > 1 {
					local tvcknotst`ts'_`tvcvar' `r(knots)'
				}
				if "`orthog'" != "" {
					tempname R_`tvcvar'_t`ts' Rinv_`tvcvar'_t`ts'
					matrix `R_`tvcvar'_t`ts'' = r(R)
					local R_tvc_`tvcvar'_t`ts'_opt rmatrix(`R_`tvcvar'_t`ts'')
				}
				forvalues i = 1/`tvc_`tvcvar'_df_t`ts'' {

					if "`indicatort`ts''" == "" {
						qui replace __t`ts'_s_`tvcvar'`i' = __t`ts'_s_`tvcvar'`i'*`tvcvar' if `touse'
						qui replace __t`ts'_d_s_`tvcvar'`i' = __t`ts'_d_s_`tvcvar'`i'*`tvcvar' if `touse'
					}
					else {
						qui replace __t`ts'_s_`tvcvar'`i' = __t`ts'_s_`tvcvar'`i'*`tvcvar' *`indicatort`ts'' if `touse'
						qui replace __t`ts'_d_s_`tvcvar'`i' = __t`ts'_d_s_`tvcvar'`i'*`tvcvar' *`indicatort`ts'' if `touse'
					}
				}
				if "`tvct`ts''" != "" {
					forvalues i = 1/`tvc_`tvcvar'_df_t`ts'' {
						local rcsterms_`tvcvar'_t`ts' "`rcsterms_`tvcvar'_`ts'' __t`ts'_s_`tvcvar'`i'"
						local rcstermstvct`ts' "`rcstermstvct`ts'' __t`ts'_s_`tvcvar'`i'"
					}

				}
				/* variable labels */
				forvalues i = 1/`dft`ts'' {
					label var __t`ts'_s`i' "restricted cubic spline `i' for timescale `ts'"
					label var __t`ts'_d_s`i' "derivative of restricted cubic spline `i' for timescale `ts'"
				}
				if "`tvct`ts''" != "" {
					forvalues i = 1/`tvc_`tvcvar'_df_t`ts'' {
						label var __t`ts'_s_`tvcvar'`i' "restricted cubic spline `i' for tvc `tvcvar' for timescale `ts'"
						label var __t`ts'_d_s_`tvcvar'`i' "derivative of restricted cubci spline `i' for tvc `tvcvar' for timescale `ts'"
					}

				}
			}
		}
	}

/* timescale interactions */
if "`timeint'" != "" {
	forvalues i = 1/ `ntimeint' {
		if "`timeintknots'" == "" {
			forvalues j = 1/2 {
				qui rcsgen `timescalet`tint`i'_t`j''' if `touse' ,  df(`dftint`i'_t`j'') gen(temptimeint`i'`j') dgen(temptimeint`i'`j'_d) `timeint`i'_bknotst`j'_opt' `orthog' if2(_d==1  & `touse' `indopt`tint`i'_t`j''')
				local knots_timeint`i'_t`j' `r(knots)'
					if "`orthog'" != "" {
						tempname R_timeint`i'_t`j'
						matrix `R_timeint`i'_t`j'' = r(R)
						local R_opt_timeint`i'_t`j' rmatrix(`R_timeint`i'_t`j'')
					}
				qui mvencode temptimeint`i'`j'? if `touse', mv(0) override
				qui mvencode temptimeint`i'`j'_d? if `touse', mv(0) override
			}
		}

		else if "`timeintknots'" != "" {
			forvalues j = 1/2 {
				qui rcsgen `timescalet`tint`i'_t`j''' if `touse' ,  knots(`timeint`i'_knotst`j'') gen(temptimeint`i'`j') dgen(temptimeint`i'`j'_d) `orthog' if2(_d==1  & `touse' `indopt`tint`i'_t`j''')
				ret list
				local knots_timeint`i'_t`j' `r(knots)'
					if "`orthog'" != "" {
						tempname R_timeint`i'_t`j'
						matrix `R_timeint`i'_t`j'' = r(R)
						local R_opt_timeint`i'_t`j' rmatrix(`R_timeint`i'_t`j'')
					}
			qui mvencode temptimeint`i'`j'? if `touse', mv(0) override
			qui mvencode temptimeint`i'`j'_d? if `touse', mv(0) override
			}
		}
	}

  forvalues i = 1/ `ntimeint' {
		forvalues j= 1/`dftint`i'_t1' {
			forvalues k= 1/`dftint`i'_t2' {
				 qui gen double __t`tint`i'_t1'_t`tint`i'_t2'_s`j'`k'= temptimeint`i'1`j'*temptimeint`i'2`k' if `touse'
				 qui gen double __t`tint`i'_t1'_t`tint`i'_t2'_d_s`j'`k'= temptimeint`i'1_d`j'*temptimeint`i'2_d`k' if `touse'
				local rcsterms_timeints `rcsterms_timeints' __t`tint`i'_t1'_t`tint`i'_t2'_s`j'`k'
				label var __t`tint`i'_t1'_t`tint`i'_t2'_s`j'`k' "timescale interaction for t`tint`i'_t1' (df `dftint`i'_t1') and t`tint`i'_t2' (df `dftint`i'_t2')"
			}
		}

	  // some Mata prep
		 local timeint`i' `tint`i'_t1' `tint`i'_t2'
		 local dftimeint`i'  `dftint`i'_t1' `dftint`i'_t2'
  	 local ind_tint`i'_1 `indicatort`tint`i'_t1''
  	 local ind_tint`i'_2 `indicatort`tint`i'_t2''


	   /*generate a logtoff indicator for the mata code*/
	   forvalues t=1/`toptimescale' {
		 local logtoff_t`t' =cond("`logt`t'off'"== "",0,1)
	   }
	   local logtimeint`i'  `logtoff_t`tint`i'_t1'' `logtoff_t`tint`i'_t2''
	   tempvar int`i'_start1 int`i'_start2
	   forvalues p=1/2 {
		 if "`tint`i'_t`p''" == "1" {
		   qui gen double `int`i'_start`p'' = 0
		 }
		 else qui gen double `int`i'_start`p''= `startt`tint`i'_t`p'''
	   }
	}
  cap drop temptimeint*
}


	forvalues ts = 1/`toptimescale' {
		local rcsterms `rcsterms' `rcstermst`ts''
	}
	forvalues ts = 1/`toptimescale' {
		local rcsterms `rcsterms' `rcstermstvct`ts''
	}
	//add timescale interactions
	local rcsterms `rcsterms' `rcsterms_timeints'



//INITIAL VALUES==================================================================
/* use stpm2 for initial values */
local dfopt = cond("`knots'" == "","df(`dft1')","knots(`knotst1')")
if "`knscalet1'" == "" {
	local knscaleopt = "knscale(t)"
}
else {
	local knscaleopt = "knscale(`knscalet1')"
}

local tvcopt =cond("`tvct1'"!="", "tvc(`tvct1')", "")
local tvcdfopt `tvcdfopt' `=cond("`knotstvct1'"=="",cond("`dftvct1'"=="","","dftvc(`dftvct1')"), "knotstvc(`knotstvct1')")'
local bknotsopt = cond("`bknotst1'"!="","bknots(`bknotst1')","")
local bknotstvcopt = cond("`bknotstvct1'"!="","bknotstvc(`bknotstvct1')","")


if "`verbose'" != "" {
	display in green "Obtaining initial values"
}

if "`inith'" == "" & "`from'" == "" {
  tempname stpm2model
  qui  stpm2 `varlist' if `touse', `dfopt' `tvcopt' `tvcdfopt' `bknotsopt'  `bknotstvcopt' scale(hazard) `knscaleopt' `offopt' `bhazopt' iter(15)
	estimates store `stpm2model'
	qui predict `hazard' if `touse', hazard
	cap drop _rcs*
  cap drop _d_rcs*
  cap drop _s0*
}
else if "`inith'" != "" {
	qui gen double `hazard' = `inith' if `touse'
}
if "`from'" == "" {
	qui gen double `lnhazard' = ln(`hazard') if `touse'
	qui regress `lnhazard' `varlist' `rcsterms' if _d==1 & `touse', `constant'
	matrix `initmat' = e(b)
	}
if "`from'" != "" {
	matrix `initmat' = `from'
}

if "`verbose'" != "" {
	display in green "Initial values Obtained!"
}



// MATA PREP ======================================================================

/* Quadrature Points */
tempname kweights knodes
gaussquad, n(`nodes') leg
matrix `kweights' = r(weights)'
matrix `knodes' = r(nodes)'

if "`constant'" == "" {
        qui gen byte `cons' = 1 if `touse'
}

//create temp variables for gaussian quadrature
tempvar t0 lowerb upperb

qui gen double `t0' = _t0 if `touse'
qui gen double `lowerb' = _t0 if `touse'
qui gen double `upperb' = _t if `touse'


local Nrcsterms: list sizeof rcsterms
local Nrcsterms = `Nrcsterms' + 1

/* Form values of nodes to evaluate */
capture drop __tmpnode*
qui gen double __tmpnodet1 = .
qui gen double __tmpnodetvct1 = .
if "`hast2'" != "" {
	qui gen double __tmpnodet2 = .
	qui gen double __tmpnodetvct2 = .
}
if "`hast3'" != "" {
	qui gen double __tmpnodet3 = .
	qui gen double __tmpnodetvct3 = .
}
if "`timeint'" != "" {
	forvalues j=1/`ntimeint' {
		qui gen double __tmpnodeint`j'_1 =.
		qui gen double __tmpnodeint`j'_2 =.
	}
}


if "`varlist'" != "" {
        local xb (xb: = `varlist', noconstant)
}
tempname stmt_temp
mata: stmt_setup("`stmt_temp'")

	// initialisation from `from'
	if "`from'" == "" {
		local initopt "init(`initmat')"
	}
	else local initopt "init(`from')"

// FIT MODEL ===================================================================
ml model `mlmethod' stmt_gf()								///
        `xb'												///
        (rcs: = `rcsterms', `constant' `offopt')			///
        if `touse'											///
        `wt',												///
        init(`initmat')										///
        waldtest(0)											///
        `log'												///
        `mlopts'											///
        userinfo(`stmt_temp')								///
        search(off)											///
        maximize

/* Tidy up what is left in Mata */
capture mata rmexternal("`stmt_temp'")


// E-RETURN =====================================================================
	forvalues ts = 1/`toptimescale' {
		/* ereturn for baseline timescales */
		ereturn local indicator_t`ts'  `indicatort`ts''
		ereturn local dfbase_t`ts' `dft`ts''
		ereturn local bhknots_t`ts' `bhknotst`ts''
		ereturn local rcsterms_base_t`ts' `rcsterms_base_t`ts''
		ereturn local start_ts_t`ts' `startt`ts''

		if "`logt`ts'off'" == "" {
			tokenize `bhknotst`ts''
			local numknotst`ts'=wordcount("`bhknotst`ts''")
			local exp_bhknots
			forvalues k= 1/`numknotst`ts'' {
				local tempknot = exp(``k'')
				local exp_bhknots `exp_bhknots' `tempknot'
			}
			ereturn local exp_bhknots_t`ts' `exp_bhknots'
		}
		ereturn local logtoff_t`ts' `logt`ts'off'


		/* ereturn for tvc options */
		foreach tvcvar in `tvct`ts'' {
			if `tvc_`tvcvar'_df_t`ts''>1 {
				if "`logt`ts'off'" == "" {
					foreach k in `tvcknotst`ts'_`tvcvar'' {
						local tvctmpknot = exp(`k')
						local exp_tvcknots_t`ts'_`tvcvar' `exp_tvcknots_t`ts'_`tvcvar'' `tvctmpknot'
					}
				ereturn local exp_tvcknots_t`ts'_`tvcvar' `exp_tvcknots_t`ts'_`tvcvar''
				}
				ereturn local tvcknots_t`ts'_`tvcvar' `tvcknotst`ts'_`tvcvar''
			}
			if "`orthog'" != "" {
				ereturn matrix R_`tvcvar'_t`ts' = `R_`tvcvar'_t`ts''
			}
			ereturn local rcsterms_t`ts'_`tvcvar' `rcstermstvct`ts''

			ereturn local df_`tvcvar'_t`ts' `tvc_`tvcvar'_df_t`ts''
			}
		ereturn local tvc_t`ts' `tvct`ts''

		if "`orthog'" != ""  {
                ereturn matrix R_bh_t`ts' = `R_bh_t`ts''
        }
	}

	/*ereturn for timescale interactions */
	if "`timeint'" != "" {
		forvalues i = 1/`ntimeint' {
			ereturn local df_timeint`i'_t`tint`i'_t1' `dftint`i'_t1'
			ereturn local df_timeint`i'_t`tint`i'_t2' `dftint`i'_t2'
			ereturn local Ntimeint `ntimeint'
			ereturn local knots_timeint`i'_t1 `knots_timeint`i'_t1'
			ereturn local knots_timeint`i'_t2 `knots_timeint`i'_t2'
			ereturn local timeint`i'_t1 `tint`i'_t1'
      ereturn local timeint`i'_t2 `tint`i'_t2'
			if "`orthog'" != "" {
			  ereturn matrix R_timeint`i'_t1 = `R_timeint`i'_t1'
			  ereturn matrix R_timeint`i'_t2 = `R_timeint`i'_t2'
			}
		}
	}

	/* other ereturn options*/
		forvalues ts = 1/`toptimescale' {
			ereturn local reverset`ts' `reverset`ts''
		}
		ereturn local orthog  `orthog'
		ereturn local noconstant `constant'
		ereturn local depvar "_d _t"
		ereturn local varlist `varlist'
		ereturn local predict stmt_pred
        ereturn local cmd stmt
		ereturn scalar minknot = `minknott1'
        ereturn scalar maxknot = `maxknott1'
        ereturn scalar nodes = `nodes'
        ereturn scalar dev = -2*e(ll)
        ereturn scalar AIC = -2*e(ll) + 2 * e(rank)
        qui count if `touse' == 1 & _d == 1
        ereturn scalar BIC = -2*e(ll) + ln(r(N)) * e(rank)
		ereturn local Ntimescales `maxtscale'


/* Show results */
        if "`hr'" == "" {
                local hr hr
        }
        Replay, `hr' `diopts'
end

program Replay
        syntax [, HR *]
        _get_diopts diopts, `options'
        ml display, `hr' `diopts'
        display in green " Quadrature method: Gauss-Legendre with `e(nodes)' nodes"

end


// GAUSS QUAD PREP ======================================================================


program define gaussquad, rclass
        syntax [, N(integer -99) LEGendre CHEB1 CHEB2 HERmite JACobi LAGuerre alpha(real 0) beta(real 0)]

    if `n' < 0 {
        display as err "need non-negative number of nodes"
                exit 198
        }
        if wordcount(`"`legendre' `cheb1' `cheb2' `hermite' `jacobi' `laguerre'"') > 1 {
                display as error "You have specified more than one integration option"
                exit 198
        }
        local inttype `legendre'`cheb1'`cheb2'`hermite'`jacobi'`laguerre'
        if "`inttype'" == "" {
                display as error "You must specify one of the integration type options"
                exit 198
        }

        tempname weights nodes
        mata gq("`weights'","`nodes'")
        return matrix weights = `weights'
        return matrix nodes = `nodes'
end
