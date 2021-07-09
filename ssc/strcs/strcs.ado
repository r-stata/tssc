*! version 1.85 21Nov2018

program strcs, eclass byable(onecall)
        version 13.1

        if _by() {
                local by "by `_byvars'`_byrc0':"
        }
        if replay() {
                syntax  [, DF(string) KNots(string) *]
                if "`df'`knots'" != "" {
                        `by' Estimate `0'
                        ereturn local cmdline `"strcs `0'"'
                }
                else {
                        if "`e(cmd)'" != "strcs" {
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
        ereturn local cmdline `"strcs `0'"'
end


program Estimate, eclass byable(recall)
        st_is 2 analysis
        syntax  [varlist(default=empty)]                                ///
                        [fw pw iw aw]                                      ///
                        [if] [in] [,                                       ///
                        DF(string)                                         ///
                        BHAZard(varname)                                   ///
                        noORTHog                                           ///
                        noCONStant                                         ///
                        noHR                                               ///
                        NODes(integer 30)                                  ///
                        KNots(string)                                      ///
                        BKnots(numlist ascending min=2 max=2)   		   ///
                        BKNOTSTVC(string)                                  ///
                        KNSCALE(string)                                    ///
                        BHTime                                             ///
                        TVC(varlist)                                       ///
                        TVCOFFset(varlist)								   ///
						TVCOFFSETKnots(string) 						    	 ///
						dftvc(string)                                      ///
                        KNOTStvc(string)                                   ///
                        OFFset(varname)                                    ///
                        VERBose                                            ///
                        INITh(varname)                                     ///
                        FROM(string)                                       ///
                        REVERSE                                            ///
						MLMethod(string)									///
                        ][                                                 ///
                        noLOg			                                   ///
						*												   ///-mlopts- options
                        ]

ereturn local cmdline `"strcs `0'"'



********************************************************************************
* ERROR CHECKS

/* Check rcsgen is installed */
        capture which rcsgen
        if _rc >0 {
                display in yellow "You need to install the command rcsgen. This can be installed using,"
                display in yellow ". {stata ssc install rcsgen}"
                exit  198
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

/* Temporary variables */
        tempvar  hazard cons timescale lnt t cumhazard lnhazard
        tempname initmat R_bh

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

/* Drop previous created __s */
        capture drop __s*
		capture drop __d*

/* Ignore options associated with time-dependent effects if specified without the tvc option */
        if "`tvc'" == "" {
                foreach opt in dftvc knotstvc {
                        if "``opt''" != "" {
                                display as txt _n "[`opt'() used without specifying tvc(), option ignored]"
                                local `opt'
                        }
                }
        }

/* Check time origin for delayed entry models */
        local del_entry = 0
        qui summ _t0 if `touse' , meanonly
        if r(max)>0 {
                display in green  "note: delayed entry models are being fitted"
                local del_entry = 1
                local mlmethod gf0
        }



/* Orthogonal retricted cubic splines */
        if "`orthog'"=="noorthog" {
                local orthog
        }
        else {
                local orthog orthog
        }

/* generate log time or untransformed time */
        qui gen double `lnt' = ln(_t) if `touse'
        qui summ `lnt' if _d == 1 & `touse', meanonly
        local likeconstant = `r(sum)'
        qui count if `touse'
        local likeconstant = `likeconstant'/`r(N)'

        if "`bhtime'" == "" {
                qui gen double `timescale' = `lnt' if `touse'
        }
        else {
                qui gen double `timescale' = _t if `touse'
        }

/* check df option is an integer */
        if "`df'" != "" {
                capture confirm integer number `df'
                if _rc>0 {
                        display as error "df option must be an integer"
                        exit 198
                }
                if `df'<1 {
                        display as error "df must be 2 or more"
                        exit 198
                }
        }

/* Only one of df and knots can be specified */
        if "`df'" != "" & "`knots'" != "" {
                display as error "Only one of DF OR KNOTS can be specified"
                exit 198
        }

/* df must be specified */
        if ("`knots'" == "" & "`df'" == "") {
                display as error "Use of either the df or knots option is compulsory"
                exit 198
        }

/* knots given on which scale */
        if "`knscale'" == "" {
                local knscale time
        }
        if inlist(substr("`knscale'",1,1),"t","l","c") != 1{
                display as error "Invalid knscale() option"
                exit 198
        }
/* cannot spoecify both inith and from options at the same time */
		if "`inith'" != "" & "`from'" != "" {
			display as error "Only one of inith or from can be specified"
			exit 198
		}

/*ensure tvc option is used when tvcoffset is used*/
		if "`tvcoffset'" != "" & "`tvc'" == ""{
			display as error "Must use the tvc() option when using the tvcoffset() option"
			exit 198
		}

/* mlmethod option use gf2 as default if not specified otherwise */
	if "`mlmethod'" == ""  {
			local mlmethod gf2
	}


********************************************************************************
* KNOT PREP
/* Boundary Knots */
        if "`bknots'" == "" {
                summ _t if `touse' & _d == 1, meanonly
                local lowerknot `r(min)'
                local upperknot `r(max)'
                if substr("`knscale'",1,1) == "c" {
                        local lowerknot 0
                        local upperknot 100
                }
        }
        else if substr("`knscale'",1,1) == "t" {
                local lowerknot = word("`bknots'",1)
                local upperknot = word("`bknots'",2)
        }
        else if substr("`knscale'",1,1) == "l" {
                local lowerknot = exp(real(word("`bknots'",1)))
                local upperknot = exp(real(word("`bknots'",2)))
        }
        else if substr("`knscale'",1,1) == "c" {
                local lowerknot = word("`bknots'",1)
                local upperknot = word("`bknots'",2)
        }



/* Boundary Knots for tvc variables */
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
                                        local lowerknot_`tmptvc'  `2'
                                }
                                else if substr("`knscale'",1,1) == "l" {
                                        local lowerknot_`tmptvc' =exp(`2')
                                }
                                else if substr("`knscale'",1,1) == "c" {
                                        local lowerknot_`tmptvc' `2'
                                }
                        }
                        cap confirm num `3'
                        if _rc == 0 {
                                if substr("`knscale'",1,1) == "t" {
                                        local upperknot_`tmptvc'  `3'
                                }
                                else if substr("`knscale'",1,1) == "l" {
                                        local upperknot_`tmptvc' =exp(`3')
                                }
                                else if substr("`knscale'",1,1) == "c" {
                                        local upperknot_`tmptvc' `3'
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

 /* store the minimum and maximum of all boundary knots */
        local minknot `lowerknot'
        local maxknot `upperknot'
        foreach tvcvar in `tvc' {
                local minknot = min(`minknot',`lowerknot_`tvcvar'')
                local maxknot = max(`maxknot',`upperknot_`tvcvar'')
				 if "`bhtime'" == "" & inlist(substr("`knscale'",1,1),"t","l") == 1  {
                       local lowerknot_`tvcvar'= ln(`lowerknot_`tvcvar'')
                       local upperknot_`tvcvar'= ln(`upperknot_`tvcvar'')
                }
        }



********************************************************************************
* GENERATE BASELINE SPLINES
/*generate baseline splines*/
	// degrees of freedom specified
        if "`df'" != "" {
				// no boundary knots specified
                if "`bknots'" == "" {
                        qui rcsgen `timescale' if `touse', gen(__s) df(`df') `orthog' `rmatrixopt' if2(_d==1) `reverse' dgen(__d_s)
                        local bhknots `r(knots)'
                        foreach k in `r(knots)' {
                                local tmpknot = exp(`k')
                        }
                }
				//boundary knots specified
                else if "`bknots'" != "" {
					// fit on the log time scale
					if "`bhtime'" == "" {
                        foreach i in `lowerknot' `upperknot' {
                                local lnbknots = ln(`i')
                                local bknotslist `bknotslist' `lnbknots'
                        }
					}
					// fit on the time scale
					else if "`bhtime'" != "" {
						foreach i in `lowerknot' `upperknot' {
							local bknotslist `bknotslist' `i'
						}
					}
					//generate the baseline splines
                    qui rcsgen `timescale' if `touse', gen(__s) df(`df') bknots(`bknotslist') `orthog' `rmatrixopt' if2(_d==1) `reverse' dgen(__d_s)
                    local bhknots `r(knots)'
                    foreach k in `r(knots)' {
						local tmpknot = exp(`k')
                    }
				}

       }
       // knots instead of df specified
       else if inlist(substr("`knscale'",1,1),"t","l") == 1 {
                local bhknotslist `lowerknot'
                foreach k in `knots' {
                        capture confirm number `k'
                        if _rc>0 {
                                display as error "Error in knot specification."
                                exit 198
                        }
                        if substr("`knscale'",1,1) == "t" {
                                local tmpknot `k'
                        }
                        else if substr("`knscale'",1,1) == "l" {
                                local tmpknot  = exp(`k')
                        }
                        local bhknotslist `bhknotslist' `tmpknot'

                }
                local bhknotslist `bhknotslist' `upperknot'
                if "`bhtime'" == "" {
                        foreach k in `bhknotslist' {
                                local tmpknot = ln(`k')
                                local tmpknotslist `tmpknotslist' `tmpknot'
                        }
                        local bhknotslist `tmpknotslist'
                }
                qui rcsgen `timescale' if `touse', gen(__s) knots(`bhknotslist') ///
                                                                `orthog' `rmatrixopt' `reverse'  dgen(__d_s)
                local df = wordcount("`r(knots)'") - 1
                local bhknots `r(knots)'
        }

        else if substr("`knscale'",1,1) == "c" {
                local bhknotslist `lowerknot' `knots' `upperknot'
                qui rcsgen `timescale' if `touse', gen(__s) percentiles(`bhknotslist') ///
                                                                `orthog' `rmatrixopt' `reverse' if2(_d==1)  dgen(__d_s)
                local nknots = wordcount("`r(knots)'")
                local df = `nknots' - 1
                local bhknots `r(knots)'
                tokenize `r(knots)'
                local minknot =exp(`1')
                local maxknot =exp(``nknots'')
                foreach k in `bhknots' {
                        local tmpknot = exp(`k')
                }




        }

        local Nbhknots : word count `bhknots'




        if "`orthog'" != "" {
                matrix `R_bh' = r(R)
                local R_bh_opt rmatrix(`R_bh')
        }
        if "`rmat'" != "" {
                local orthog orthog
                matrix `R_bh' = `rmatrix'
        }
        /* create list of spline terms */
        forvalues i = 1/`df' {
                local rcsterms_base "`rcsterms_base' __s`i'"
        }
        local rcsterms `rcsterms_base'


********************************************************************************
*TIME-DEPENDENT VARIABLE STUFF
/* df for time-dependent variables */
        if "`tvc'"  != "" {
                if "`dftvc'" == "" & "`knotstvc'" == "" & "`tvcoffsetknots'" == "" {
                        display as error "The dftvc, knotstvc or tvcoffsetknots option is compulsory if you use the tvc option"
                        exit 198
                }
				if "`tvcoffset'" != "" {
					tokenize `tvcoffset'
					local ntemp: word count `tvcoffset'
					foreach tmptvc in `tvc' {
						forvalues i=1/`ntemp' {
							if "`tmptvc'" == "``i''" local `tmptvc'_intvcoffset 1
						}
					}

				}
				// dftvc specified
                if "`knotstvc'" == "" & "`dftvc'" != "" {
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
                if "`knotstvc'" == "" & "`tvcoffsetknots'" == "" {
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

			/* check if tvcoffset option is specified */
                if "`tvcoffset'" != "" {
                        tempvar tvcoffsetsum
                        qui gen double `tvcoffsetsum' = 0
                        local ntvcoff: word count `tvcoffset'
                        tokenize "`tvcoffset'"
                        while "`2'"!= "" {
                                confirm var `1'
                                if `"`: list posof `"`1'"' in tvc'"' == "0" {
                                        display as error "`1' is not listed in the tvc option"
                                        exit 198
                                }
                                confirm var `2'
                                local tvc_`1'_offset `2'
                                qui replace `tvcoffsetsum' = `tvcoffsetsum' + `2'
								local tvcoffsetvariable `tvcoffsetvariable' `1'
                                macro shift 2
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
                                        if "`bhtime'" == "" {
                                                if substr("`knscale'",1,1) == "t" {
                                                        local newknot = ln(`2')
                                                }
                                                else if substr("`knscale'",1,1) == "l" {
                                                        local newknot `2'
                                                }
                                                else if substr("`knscale'",1,1) == "c" {
                                                        local newknot `2'
                                                }
                                        }
                                        else {
                                                if substr("`knscale'",1,1) == "t" {
                                                        local newknot `2'
                                                }
                                                else if substr("`knscale'",1,1) == "l" {
                                                        local newknot = exp(`2')
                                                }
                                                else if substr("`knscale'",1,1) == "c" {
                                                        local newknot `2'
                                                }
                                        }
                                        local tvcknots_`tmptvc'_user `tvcknots_`tmptvc'_user' `newknot'
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
				// tvcoffsetknots
				if "`tvcoffsetknots'" != "" {
                        tokenize `tvcoffsetknots'
                        cap confirm var `1'
                        if _rc >0 {
                                display as error "Specify the tvcoffset variable(s) when using the tvcoffsetknots() option"
                                exit 198
                        }
                        while "`2'"!="" {
                                cap confirm var `1'
                                if _rc == 0 {
                                        if `"`: list posof `"`1'"' in tvcoffset'"' == "0" {
                                                display as error "`1' is not listed in the tvcoffset option"
                                                exit 198
                                        }
										if `"`: list posof `"`1'"' in tmptvcvariables'"' == "0" {
                                                local tmptvcvariables `tmptvcvariables' `1'

                                        }
                                        local tmptvcos `1'
										local hastvcoffset_knots_`1' 1
                                        local tvcoffset_`tmptvcos'_df 1

                                }

                                cap confirm num `2'
                                if _rc == 0 {
                                        local newknot = `2'

                                        local tvcoffsetknots_`tmptvcos'_user `tvcoffsetknots_`tmptvcos'_user' `newknot'
                                        local tvcoffset_`tmptvcos'_df = `tvcoffset_`tmptvcos'_df' + 1
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
							// tvcoffsetknots includes the boundary knots
							local tvcoffset_`tmptvcos'_df `= `tvcoffset_`tmptvcos'_df' -2'
							foreach tvcvar in `tvc' {
								if "`hastvcoffset_knots_`tvcvar''" == "1" {
									local tvc_`tvcvar'_df `tvcoffset_`tvcvar'_df'
								}
								local alt_tvcoffsetknots `alt_tvcoffsetknots' `tvcvar':`tvc_`tvcvar'_df'
							}

                        }

}



        if "`tvc'" != "" {
                tempvar tvctimevar
                foreach tvcvar in  `tvc' {
                        capture drop `tvctimevar'
                        if "`tvc_`tvcvar'_offset'" != "" {
                               qui gen double `tvctimevar'   = `timescale' + `tvc_`tvcvar'_offset' if `touse'
						}
                        else {
                               qui gen double `tvctimevar'= `timescale' if `touse'
                        }
						//no knots specified for tvc
                        if "`knotstvc'" == ""  {
							if "`tvcoffsetknots'" != "" &  "`hastvcoffset_knots_`tvcvar''" == "1" {
								// for those which have tvcoffsetknots we use tvcoffset_`tvcvar'_df, else we use `tvc_`tvcvar'_df'
								qui rcsgen `tvctimevar' if `touse', knots(`tvcoffsetknots_`tvcvar'_user') gen(__s_`tvcvar') ///
                                                                                                        `orthog' if2(_d==1  & `touse') `reverse' dgen(__d_s_`tvcvar')


							}
							else {
                                if "`bknotstvc'" == "" {
                                        if "`bknots'" == "" {
                                                 qui rcsgen `tvctimevar' if `touse', df(`tvc_`tvcvar'_df') gen(__s_`tvcvar') ///
                                                                                                       `orthog' if2(_d==1  & `touse') `reverse'   dgen(__d_s_`tvcvar')
										}
                                        else if "`bknots'" != "" {
                                                qui rcsgen `tvctimevar' if `touse', df(`tvc_`tvcvar'_df') gen(__s_`tvcvar') ///
                                                                                       bknots(`bknotslist') `orthog' if2(_d==1  & `touse') `reverse' dgen(__d_s_`tvcvar')
                                        }
                                }

                                else if "`bknotstvc'" != "" {
                                        qui rcsgen `tvctimevar' if `touse', df(`tvc_`tvcvar'_df') gen(__s_`tvcvar') ///
                                                                         bknots(`lowerknot_`tvcvar'' `upperknot_`tvcvar'') `orthog' if2(_d ==1  & `touse') `reverse' dgen(__d_s_`tvcvar')
                                }
                        }
						}
						// knots specified for tvc
                        else {
							if "`tvcoffsetknots'" != "" & "``tvcvar'_intvcoffset'" =="1" {
							    qui rcsgen `tvctimevar' if `touse', knots(`tvcoffsetknots_`tmptvc'_user') gen(__s_`tvcvar') ///
                                                                                                        `orthog' if2(_d==1  & `touse') `reverse' dgen(__d_s_`tvcvar')
							}
							else {
                                if inlist(substr("`knscale'",1,1),"t","l") == 1 {
                                        qui rcsgen `tvctimevar' if `touse', knots(`lowerknot_`tvcvar'' `tvcknots_`tvcvar'_user' `upperknot_`tvcvar'') gen(__s_`tvcvar') ///
                                                                                                        `orthog' if2(_d==1  & `touse') `reverse' dgen(__d_s_`tvcvar')
								}
                                else if substr("`knscale'",1,1) == "c" {
                                        qui rcsgen `tvctimevar' if `touse', percentiles(`lowerknot_`tvcvar'' `tvcknots_`tvcvar'_user' `upperknot_`tvcvar'') gen(__s_`tvcvar') ///
                                                                                                        `orthog' if2(_d==1  & `touse') `reverse' dgen(__d_s_`tvcvar')
                                }
							}

                        }

                        if `tvc_`tvcvar'_df' > 1 {
                                local tvcknots_`tvcvar' `r(knots)'
                        }
                        if "`orthog'" != "" {
                                tempname R_`tvcvar' Rinv_`tvcvar'
                                matrix `R_`tvcvar'' = r(R)
                                local R_tvc_`tvcvar'_opt rmatrix(`R_`tvcvar'')
                        }
                        forvalues i = 1/`tvc_`tvcvar'_df' {
                                qui replace __s_`tvcvar'`i' = __s_`tvcvar'`i'*`tvcvar' if `touse'
                                qui replace __d_s_`tvcvar'`i' = __d_s_`tvcvar'`i'*`tvcvar' if `touse'

                        }

                }
        }

        if "`tvc'" != "" {
                foreach tvcvar in  `tvc' {
                        forvalues i = 1/`tvc_`tvcvar'_df' {
                                local rcsterms_`tvcvar' "`rcsterms_`tvcvar'' __s_`tvcvar'`i'"
                                local rcsterms "`rcsterms' __s_`tvcvar'`i'"
                        }
                }
        }

		/* variable labels */
        forvalues i = 1/`df' {
                label var __s`i' "restricted cubic spline `i'"
				label var __d_s`i' "derivative of restricted cubic spline `i'"
        }

        if "`tvc'" != "" {
                foreach tvcvar in  `tvc' {
                        forvalues i = 1/`tvc_`tvcvar'_df' {
                                label var __s_`tvcvar'`i' "restricted cubic spline `i' for tvc `tvcvar'"
								label var __d_s_`tvcvar'`i' "derivative of restricted cubci spline `i' for tvc `tvcvar'"
                        }
                }
        }


/* Define Offset */
        if "`offset'" != "" {
                local offopt offset(`offset')
                local addoff +`offset'
        }
********************************************************************************
* INITIAL VALUES
/* use stpm2 for initial values */
local dfopt = cond("`knots'" == "","df(`df')","knots(`knots')")


if "`knscale'" == "" {
	local knscaleopt = "knscale(t)"
}
else {
	local knscaleopt = "knscale(`knscale')"
}

local tvcopt = cond("`tvc'"!="","tvc(`tvc')","")
local tvcopt `tvcopt' `=cond("`knotstvc'"=="" & "`tvcoffsetknots'"=="","dftvc(`dftvc')",cond("`knotstvc'"=="", "dftvc(`alt_tvcoffsetknots' )","knotstvc(`knotstvc')"))'
local bknotsopt = cond("`bknots'"!="","bknots(`bknots')","")
local bknotstvcopt = cond("`bknotstvc'"!="","bknotstvc(`bknotstvc')","")

local bhazopt = cond("`bhazard'"!="","bhazard(`bhazard')","")


if "`verbose'" != "" {
        display in green "Obtaining initial values"
}


if "`inith'" == "" & "`from'" == "" & "`tvcoffsetknots'" == "" {
        tempname stpm2model
        qui stpm2 `varlist' if `touse', `dfopt' `tvcopt' `bknotsopt' `bknotstvcopt' scale(hazard) `knscaleopt' `offopt' `bhazopt' iter(10)
		estimates store `stpm2model'
        qui predict `hazard' if `touse', hazard
		cap drop _rcs* _d_rcs*
}
else if "`tvcoffsetknots'" != "" {
	    tempname stpm2model
         stpm2 `varlist' if `touse', `dfopt' `tvcopt' `bknotsopt' `bknotstvcopt' scale(hazard) `knscaleopt' `offopt' `bhazopt' iter(10)
		estimates store `stpm2model'
        qui predict `hazard' if `touse', hazard
		local dftvc `alt_tvcoffsetknots'
		cap drop _rcs* _d_rcs*


}
else if "`inith'" != "" {
        gen double `hazard' = `inith' if `touse'
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

********************************************************************************
*SORT READY FOR TWO-STEP INTEGRATION

/* Quadrature Points */
tempname kweights knodes

gaussquad, n(`nodes') leg

matrix `kweights' = r(weights)'
matrix `knodes' = r(nodes)'


if "`constant'" == "" {
        qui gen byte `cons' = 1 if `touse'
        local addcons `cons'
}


/* for integration up to first knot and after last knot */
tempvar lowt includefirstint includesecondint hight includethirdint ln_hight ln_lowt t0 ln_t0 lowerb upperb



qui gen double `lowt' = cond(_t>=`minknot',`minknot',_t) if `touse'
qui gen double `t0' = _t0 if `touse'

qui gen double `lowerb' = cond(_t0>`lowt',_t0,`lowt') if `touse'
qui gen double `upperb' = cond(_t>=`maxknot',`maxknot',_t) if `touse'


qui gen double `hight' = cond(_t0<`maxknot', `maxknot', _t0) if `touse'

qui gen byte `includefirstint' = _t0<`lowt' if `touse'
qui gen byte `includesecondint' = (_t0<`maxknot') & (_t>`minknot') if `touse'
qui gen byte `includethirdint' = _t>`hight' if `touse'

// needed for calculation of slope after last knot
if "`bhtime'" == "" {
                qui gen double `ln_hight' = ln(`hight') if `touse'
                qui gen double `ln_lowt' = ln(`lowt') if `touse'
				qui gen double `ln_t0' = ln(`t0') if `touse'
}





local Nrcsterms: list sizeof rcsterms
local Nrcsterms = `Nrcsterms' + 1

/* Form values of nodes to evaluate */
capture drop __tmpnode*
qui gen double __tmpnode = .
qui gen double __tmpnodetvc = .
capture drop __tmptvcgen
qui gen double __tmptvcgen = .


if "`varlist'" != "" {
        local xb (xb: = `varlist', noconstant)
}

tempname strcs_temp
mata: strcs_setup("`strcs_temp'")

	// initialisation from `from'
	if "`from'" == "" {
		local initopt "init(`initmat')"
	}
	else local initopt "init(`from')"

********************************************************************************
* FIT MODEL

ml model `mlmethod' strcs_gf()                                                                ///
        `xb'                                                                                            ///
        (rcs: = `rcsterms', `constant' `offopt')                        ///
        if `touse'                                                                                      ///
        `wt',                                                                                           ///
        init(`initmat', copy)                                                                         ///
        waldtest(0)                                                                             ///
        `log'                                                                                           ///
        `mlopts'                                                                                        ///
        userinfo(`strcs_temp')                                                          ///
        search(off)                                                                                     ///
        maximize

/* Tidy up what is left in Mata */
capture mata rmexternal("`strcs_temp'")

********************************************************************************
*E-RETURN


        ereturn local reverse `reverse'
		ereturn local orthog  `orthog'
		ereturn local noconstant `constant'
        ereturn local bhtime `bhtime'
        ereturn local bhazard `bhazard'
		ereturn scalar dfbase = `df'
		foreach tvcvar in  `tvc' {
            if `tvc_`tvcvar'_df'>1 {
                if "`bhtime'" == "" {
						foreach k in `tvcknots_`tvcvar'' {
                              local tvctmpknot = exp(`k')
                              local exp_tvcknots_`tvcvar' `exp_tvcknots_`tvcvar'' `tvctmpknot'
                        }
                        ereturn local exp_tvcknots_`tvcvar' `exp_tvcknots_`tvcvar''
                }
				ereturn local tvcknots_`tvcvar' `tvcknots_`tvcvar''
            }
            if "`orthog'" != "" {
                ereturn matrix R_`tvcvar' = `R_`tvcvar''
            }
			ereturn local rcsterms_`tvcvar' `rcsterms_`tvcvar''
			ereturn scalar df_`tvcvar' = `tvc_`tvcvar'_df'
        }

        ereturn local tvc `tvc'

		if "`bhtime'" == "" {
			tokenize `bhknots'
			local numknots=wordcount("`bhknots'")
			local exp_bhknots
			forvalues k=1/`numknots' {
				local tempknot = exp(``k'')
				local exp_bhknots `exp_bhknots' `tempknot'
			}
                ereturn local exp_bhknots `exp_bhknots'
        }
        ereturn local bhknots `bhknots'
		ereturn local rcsterms_base `rcsterms_base'
        ereturn local depvar "_d _t"
		ereturn local varlist `varlist'
		ereturn local predict strcs_pred
        ereturn local cmd strcs





        ereturn scalar minknot = `minknot'
        ereturn scalar maxknot = `maxknot'



        if "`orthog'" != ""  {
                ereturn matrix R_bh = `R_bh'
        }


        ereturn scalar nodes = `nodes'
        ereturn scalar dev = -2*e(ll)
        ereturn scalar AIC = -2*e(ll) + 2 * e(rank)
        qui count if `touse' == 1 & _d == 1
        ereturn scalar BIC = -2*e(ll) + ln(r(N)) * e(rank)



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


*********************************
* Gaussian quadrature 

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
