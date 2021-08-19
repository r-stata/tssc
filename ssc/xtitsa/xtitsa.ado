*! 1.1.1 Ariel Linden 22Mar2021 // fixed bug in trperiod() loop
*! 1.1.0 Ariel Linden 10Mar2021 // added parsing code to extract date(s) from trperiod() 
*! 1.0.1 Ariel Linden 21Feb2021 // fixed code to handle depvar when using ts operators (e.g. L.depvar) 
*! 1.0.0 Ariel Linden 13Jan2021

program define xtitsa, sort
version 11.0

	syntax varlist(min=1 numeric ts fv) [if] [in] [iweight fweight pweight],	///
	TRPeriod(string)															///	
	[ TREAT(varname numeric)													///
 	SINGle																		///
	POSTTRend																	///
	FIGure   FIGure2(str asis)													///
	REPLace PREfix(str) *]
	
	
	/* ensure that "eform" was not specified */
	if regexm("`0'", substr(" ef", 1, 2))==1 {
		di as err "eform cannot be used in xtitsa" 
		exit 198
	}
	
	gettoken dvar1 xvar : varlist
	
	di _n // new line between command line and tsset in output
	quietly {
		marksample touse
		count if `touse'
		if r(N) == 0 error 2000
		local N = r(N)
		replace `touse' = -`touse'

		/* check if data is tsset with panel and time var */
		/* -tsset- errors out if no time variable set */
		tsset
		local tvar `r(timevar)'
		local pvar `r(panelvar)'
		
		/* get format for timevar for output */
		* format specified for the timevar (used for lincom title and figure title)
		loc tsf `r(tsfmt)'
		* format used in regression output and parsing trperiod()
		if substr("`tsf'",2,1) == "t" {
			local tsfr = substr("`tsf'",1,3)
			local period = lower(substr("`tsf'", 3, 1))
		}
		else local tsfr `tsf'

		if "`pvar'" != "" & "`single'" == "" {
			if "`r(balanced)'" != "strongly balanced" {
				di as err "strong balance required"
				exit 498
			}
		}
		/* parse dates in trperiod() */
		tokenize "`trperiod'", parse(";")
		local done = 0
		local i = 0
		local count = 0
		while !`done' {  
			local ++i
			local next = "``i''"
			local done = ("`next'" == "")
			// keep dates only (exclude semicolon)
			if ("`next'" != ";") & (!`done') {
				local ++count
				local trp`count' = `period'(`next') 
				local trp `trp' `trp`count''
				local trperiod `trp'
			}  // end if
		} // end while
		
		/* check if trperiod is among tvars */
		levelsof `tvar' if `touse', local(levt)
		if !`: list trperiod in levt' {
			di as err "Treatment periods not found in time variable:" ///
			" check trperiod() and/or tsset settings"
			exit 498
		}
		
		* verify that treat is coded 1/0
		if "`treat'" != "" {
			tabulate `treat' if `touse' 
                if r(r) != 2 { 
                        di as err "`treat' must have exactly two values (coded 0 or 1)."
                exit 420  
                } 
                else if r(r) == 2 { 
                        capture assert inlist(`treat', 0, 1) if `touse' 
                        if _rc { 
                        di as err "`treat' must be coded as either 0 or 1."
                exit 450 
                        }
                }
		} //end treat


	 /********************* SET ANALYSIS TYPES ***********************************
	  *		  Type 1: Treatment group only in data set (single group ITSA)		 *
	  *		  Type 2: Treatment group amongst other data (single group ITSA)	 *
	  *		  Type 3: Multiple group analysis (treatment vs controls)			 *
	  ***************************************************************************/
		if "`treat'" == ""  &  "`single'" !="" {
			local atype = 1
		}
		else if "`treat'" != ""  &  "`single'" !="" {
			local atype = 2
		}
		else if "`treat'" != ""  &  "`single'" =="" {
			local atype = 3
		}

		/* drop program variables if option "replace" is chosen */
		if "`replace'" != "" {
			local itsavars : char _dta[`prefix'_itsavars]
			if "`itsavars'" != "" {
				foreach v of local itsavars {
					capture drop `v'
				}
			}
		}
		
		/* clone dvar and replace "." with "_" if dvar includes time series operator (e.g. l1. or d1.)  */
		if strpos("`dvar1'",".") != 0 {
			tempvar dvar2
			gen `dvar2' = `dvar1'
			local dvar = "_" + subinstr("`dvar1'",".","_",.)
			local dvar  `prefix'`dvar'
			rename `dvar2' `dvar'
		}
		else {
			tempvar dvar2
			gen `dvar2' = `dvar1'
			local dvar _`dvar1'
			local dvar  `prefix'`dvar'
			rename `dvar2' `dvar'
			local w : variable label `dvar1'
			if `"`w'"' != "" label variable `dvar' `"`w'"'
		}
				
	} // end quietly

	/*************************************************
	  TYPE 1 ANALYSIS: SINGLE GROUP IN DATA
	**************************************************/
	if `atype'==1 {
		quietly {
			bysort `touse' `pvar' (`tvar'): gen `prefix'_t = `tvar' - `tvar'[1] if `touse'
			local rhs `prefix'_t
	
			foreach t in `trperiod' {
				local tper = strofreal(`t',"`tsfr'")
				/* x will test change in level after intervention */
				gen `prefix'_x`tper' = `tvar' >= `t' if `touse'
				/* xt will test difference in pre-post slopes */
				gen `prefix'_x_t`tper' = (`tvar' - `t') * `prefix'_x`tper' if `touse'
				local rhs `rhs' `prefix'_x`tper' `prefix'_x_t`tper'
			}
		} // end quietly
			
		/* run xtgee */
		tsset
		xtgee `dvar' `rhs' `xvar'  if `touse' [`weight' `exp'], `options'
		
		quietly predict `prefix'_s_`dvar'_pred
		local itsavars `dvar' `rhs' `prefix'_s_`dvar'_pred
		char def _dta[`prefix'_itsavars] "`itsavars'"

		/*********************************************************
		*  LINCOM: SINGLE GROUP SINGLE PANEL                     *
		**********************************************************/
		if "`posttrend'" != ""{

			/* capture level specified in XTGEE */
			local clv `=string(r(level))'
			local cil `=length("`clv'")'
			
			local bexp "_b[`prefix'_t]"
	
			/* Start Loop over time */
			foreach t in `trperiod' {
				* format trperiod date for lincom output
				local tper = strofreal(`t',"`tsfr'")
				* format trperiod date for lincom title
				local tperl = strofreal(`t',"`tsf'")
				local bexp = "`bexp'+_b[`prefix'_x_t`tper']"
				qui lincom `"`bexp'"', level(`clv')
				qui return list
				local zp P>|z|
				di _newline(1)
				di in smcl in green _col(20) " Postintervention Linear Trend: `tperl'"  _newline
				di  "Treated: `bexp'"
				#delim ;
				di in smcl in gr "{hline 13}{c TT}{hline 64}"
				_newline "Linear Trend {c |}"
				_col(21) "Coef. "
				_col(29) "Std. Err."
				_col(44) "z"
				_col(49) "`zp'"
				_col(`=61-`cil'') `"[`clv'% Conf. Interval]"'
				_newline
				in gr in smcl "{hline 13}{c +}{hline 64}"
				_newline
				_col(1) "     Treated"  /* ARGUMENT */
				_col(14) "{c |}" in ye
				_col(17) %9.7g r(estimate)
				_col(28) %9.7g r(se)
				_col(38) %8.2f r(z)
				_col(46) %8.3f r(p)
				_col(58) %9.7g r(lb)
				_col(70) %9.7g r(ub)
				_newline
				in gr in smcl "{hline 13}{c BT}{hline 64}"
				;
				#delim cr
			}
		} /* END IF POSTTREND & LINCOM BLOCK */

		/*************************************************************
		 *                PLOT SECTION FOR TYPE 1                    *
		 *************************************************************/

		if `"`figure'`figure2'"' != "" {   /* Start Figure Loop */
			/* graph; get variable labels if they exist */
			local ydesc : var label `dvar'
			if `"`ydesc'"' == "" local ydesc "`dvar'"
			local tdesc : var label `tvar'
			if `"`tdesc'"' == "" local tdesc "`tvar'"

			local note "GEE model: family(`e(family)'), link(`e(link)'), correlation(`e(corr)')"
			
			/* Collapse predicted for treated means over time */
			preserve
			collapse (mean) `dvar' `prefix'_s_`dvar'_pred ///
				if `touse' [`weight' `exp'], by(`tvar')

			/* CREATE PREDICTED VALUE FOR PLOTS */
			qui{
				tempvar ypred_t
				gen `ypred_t' = `prefix'_s_`dvar'_pred

				local tct: word count `trperiod'
				local tmax: word `tct' of `trperiod'
				local k = 0
					foreach t in `trperiod' {
						local k = `k' + 1
						tempvar tp_t`k' plt_t`k'
						if `k'== 1 {
							gen `tp_t`k'' = `ypred_t' if `tvar'<=`t' & e(sample)
							replace `tp_t`k''=. if `tvar'==`t'
							ipolate `tp_t`k'' `tvar' if `tvar' <=`t', gen(`plt_t`k'') epolate
						}
						if `k'> 1 & `k'<=`tct' {
							local klast = `k'-1
							local tlast: word `klast' of `trperiod'
							gen `tp_t`k'' = `ypred_t' if `tvar'>=`tlast' & `tvar'<=`t' & e(sample)
							replace `tp_t`k'' = . if `tvar'==`t'
							ipolate `tp_t`k'' `tvar' if `tvar'>=`tlast' & `tvar'<=`t', ///
							gen(`plt_t`k'') epolate
						}
						if `k' ==`tct' {
							tempvar pltx
							gen `pltx' = `ypred_t' if `tvar'>=`tmax' & e(sample)
						}
					}  /* end of TRPERIOD LOOP */
	

					/* Set up Plot Variables */
					forvalues k = 1/`tct' {
						local plotvars `plotvars'  `plt_t`k''
						local cpart `cpart' l
						local mspart `mspart' none
						local lblack `lblack' black
					}
			} /* end of quietly loop */


			/* connect and msymbol options */
			local cpart c(. l `cpart')
			local lc   lcolor(black `lblack' black)
			local mspart  ms(O none `mspart')
			local plotvars `plotvars' `pltx'
			
			/* separate multiple trperiods for subtitle */
			foreach t in `trperiod' {
				local tper = strofreal(`t',"`tsf'")
				local tperlist `tperlist' `tper'
			}
			
			noi scatter  `dvar' `plotvars' `tvar', 	`cpart' `mspart' `lc' ///
				xline(`trperiod', lpattern(shortdash) lcolor(black)) ///
				mcolor(black) ///
				legend(rows(1) order(1 2) ///
				label(1 "Actual") label(2 "Predicted")) ///
				note(`"`note'"') ///
				ytitle("`ydesc'") ///
				xtitle("`tdesc'") ///
				title("`treatdesc'") ///
				subtitle("Intervention starts: `tperlist'") ///
				`figure2'

			restore
		}  /* End of Plot Loop */
		
	}  /* End OF TYPE 1 LOOP */

	/*************************************************
	  TYPE 2 ANALYSIS: SINGLE GROUP MULTIPLE PANELS
	**************************************************/
	else if `atype'==2 {

		quietly {
			bysort `touse' `pvar' (`tvar'): gen `prefix'_t = `tvar' - `tvar'[1] if `touse'
			local rhs `prefix'_t // collating RHS variables

			foreach t in `trperiod' {
				local tper = strofreal(`t',"`tsfr'")
				/* x will test change in level after intervention */
				gen `prefix'_x`tper' = `tvar' >= `t' if `touse'
				/* xt will test difference in pre-post slopes */
				gen `prefix'_x_t`tper' = (`tvar' - `t') * `prefix'_x`tper' if `touse'
				local rhs `rhs' `prefix'_x`tper' `prefix'_x_t`tper'
			}
		} // end quietly

		/* run xtgee */
		tsset
		xtgee `dvar' `rhs' `xvar' if `touse' & `treat'==1 [`weight' `exp'], `options'
		
		quietly predict `prefix'_s_`dvar'_pred
		local itsavars `dvar' `rhs' `prefix'_s_`dvar'_pred
		char def _dta[`prefix'_itsavars] "`itsavars'"
		
		/**************************************************************
		*  LINCOM: SINGLE GROUP MULTIPLE PANELS                     *
		***************************************************************/
		if "`posttrend'" != ""{

			/* capture level specified in XTGEE */
			local clv `=string(r(level))'
			local cil `=length("`clv'")'
			
			local bexp "_b[`prefix'_t]"
			
			/* Start Loop over time */
			foreach t in `trperiod' {
				* format trperiod date for lincom output
				local tper = strofreal(`t',"`tsfr'")
				* format trperiod date for lincom title
				local tperl = strofreal(`t',"`tsf'")
				local bexp = "`bexp'+_b[`prefix'_x_t`tper']"
				qui lincom `"`bexp'"', level(`clv')
				qui return list
				local zp P>|z|
				di _newline(1)
				di in smcl in green _col(20) " Postintervention Linear Trend: `tperl'"  _newline
				di  "Treated: `bexp'"
				#delim ;
				di in smcl in gr "{hline 13}{c TT}{hline 64}"
				_newline "Linear Trend {c |}"
				_col(21) "Coef. "
				_col(29) "Std. Err."
				_col(44) "z"
				_col(49) "`zp'"
				_col(`=61-`cil'') `"[`clv'% Conf. Interval]"'
				_newline
				in gr in smcl "{hline 13}{c +}{hline 64}"
				_newline
				_col(1) "     Treated"  /* ARGUMENT */
				_col(14) "{c |}" in ye
				_col(17) %9.7g r(estimate)
				_col(28) %9.7g r(se)
				_col(38) %8.2f r(z)
				_col(46) %8.3f r(p)
				_col(58) %9.7g r(lb)
				_col(70) %9.7g r(ub)
				_newline
				in gr in smcl "{hline 13}{c BT}{hline 64}"
				;
				#delim cr
			}
		} /* END IF POSTTREND & LINCOM BLOCK */

		/************************************************
		*             PLOT SECTION FOR TYPE 2           *
		*************************************************/

		if `"`figure'`figure2'"' != "" {   /* Start Figure Loop */
			/* graph; get variable labels if they exist */
			local ydesc : var label `dvar'
			if `"`ydesc'"' == "" local ydesc "`dvar'"
			local tdesc : var label `tvar'
			if `"`tdesc'"' == "" local tdesc "`tvar'"
			local treatdesc: var label `treat'
			if "`treatdesc'" == "" local treatdesc "Treated"
			
			local note "GEE model: family(`e(family)'), link(`e(link)'), correlation(`e(corr)')"
			
			/* Collapse predicted for treated means over time */
			preserve
			collapse (mean)  `dvar' `prefix'_s_`dvar'_pred ///
				if `touse' & `treat' == 1 [`weight' `exp'], by(`tvar')
		
			/* CREATE PREDICTED VALUE FOR PLOTS */
			qui{
				tempvar ypred_t
				gen `ypred_t' = `prefix'_s_`dvar'_pred

				local tct: word count `trperiod'
				local tmax: word `tct' of `trperiod'
				local k = 0
					foreach t in `trperiod' {
						local k = `k' + 1
						tempvar tp_t`k' plt_t`k'
						if `k'== 1 {
							gen `tp_t`k'' = `ypred_t' if `tvar'<=`t' & e(sample)
							replace `tp_t`k''=. if `tvar'==`t'
							ipolate `tp_t`k'' `tvar' if `tvar' <=`t', gen(`plt_t`k'') epolate
						}
						if `k'> 1 & `k'<=`tct' {
							local klast = `k'-1
							local tlast: word `klast' of `trperiod'
							gen `tp_t`k'' = `ypred_t' if `tvar'>=`tlast' & `tvar'<=`t' & e(sample)
							replace `tp_t`k'' = . if `tvar'==`t'
							ipolate `tp_t`k'' `tvar' if `tvar'>=`tlast' & `tvar'<=`t', ///
							gen(`plt_t`k'') epolate
						}
						if `k' ==`tct' {
							tempvar pltx
							gen `pltx' = `ypred_t' if `tvar'>=`tmax' & e(sample)
						}
					}  /* end of TRPERIOD LOOP */
	

					/* Set up Plot Variables */
					forvalues k = 1/`tct' {
						local plotvars `plotvars'  `plt_t`k''
						local cpart `cpart' l
						local mspart `mspart' none
						local lblack `lblack' black
					}
			} /* end of quietly loop */


			/* connect and msymbol options */
			local cpart c(. l `cpart')
			local lc   lcolor(black `lblack' black)
			local mspart  ms(O none `mspart')
			local plotvars `plotvars' `pltx'

			/* separate multiple trperiods for subtitle */
			foreach t in `trperiod' {
				local tper = strofreal(`t',"`tsf'")
				local tperlist `tperlist' `tper'
			}
			
			noi scatter  `dvar' `plotvars' `tvar', `cpart' `mspart' `lc' ///
				xline(`trperiod', lpattern(shortdash) lcolor(black)) ///
				mcolor(black) ///
				legend(rows(1) order(1 2) ///
				label(1 "Actual") label(2 "Predicted")) ///
				note(`"`note'"') ///
				ytitle("`ydesc'") ///
				xtitle("`tdesc'") ///
				title("`treatdesc'") ///
				subtitle("Intervention starts: `tperlist'") ///
				`figure2'

			restore
		}  /* End of Plot Loop */
		
	}  /* End OF TYPE 1 LOOP */


	/*************************************************
	TYPE 3 ANALYSIS: MULTIPLE GROUP ANALYSIS
	**************************************************/
	else if `atype'==3 {
		/* variables based on trperiod */
  		quietly {
			bysort `touse' `pvar' (`tvar'): gen `prefix'_t = `tvar' - `tvar'[1] if `touse'
			gen byte `prefix'_z = `treat' if `touse'
			gen `prefix'_z_t = `prefix'_z * `prefix'_t if `touse'
			local rhs `prefix'_t `prefix'_z `prefix'_z_t

			foreach t in `trperiod' {
				local tper = strofreal(`t',"`tsfr'")
				/* x will test change in level after intervention - controls */
				gen `prefix'_x`tper' = `tvar' >= `t' if `touse'
				/* xt will test difference in pre-post slopes - controls */
				gen `prefix'_x_t`tper' = (`tvar' - `t') * `prefix'_x`tper' if `touse'
				/* zx will test difference between groups in level after intervention */
				gen `prefix'_z_x`tper' = `prefix'_z * `prefix'_x`tper' if `touse'
				/* zxt will test difference between groups in pre-post slopes */
				gen `prefix'_z_x_t`tper' = `prefix'_x_t`tper' * `prefix'_z if `touse'
				local rhs `rhs' `prefix'_x`tper' `prefix'_x_t`tper' `prefix'_z_x`tper' `prefix'_z_x_t`tper'
			}
		} //end quietly
		
		/* run xtgee */
		tsset
		xtgee `dvar' `rhs' `xvar' if `touse' [`weight' `exp'], `options'

		quietly predict `prefix'_m_`dvar'_pred // consider adding "if e(sample)"
		local itsavars `dvar' `rhs' `prefix'_m_`dvar'_pred
		char def _dta[`prefix'_itsavars] "`itsavars'"

		/*******************************************
		 LINCOM:   MULTIPLE GROUP COMPARISON       *
		********************************************/
		if "`posttrend'" != "" {
		
			/* capture level specified in XTGEE */
			local clv `=string(r(level))'
			local cil `=length("`clv'")'
		
			/* Start Loop over time */
         	local btexp "_b[`prefix'_t] + _b[`prefix'_z_t]"
            local bcexp "_b[`prefix'_t]"
           	local bdexp "_b[_z_t]"

			foreach t in `trperiod' {
				* format trperiod date for lincom output
				local tper = strofreal(`t',"`tsfr'")
				* format trperiod date for lincom title
				local tperl = strofreal(`t',"`tsf'")
				di _newline(1)
				di in smcl in green _col(20) "Comparison of Linear Postintervention Trends: `tperl'"
				di _newline

				local btexp "`btexp' + _b[`prefix'_x_t`tper'] + _b[`prefix'_z_x_t`tper']"
				local bcexp "`bcexp' + _b[`prefix'_x_t`tper']"
  				local bdexp "`bdexp' +  _b[`prefix'_z_x_t`tper']"

				di  "Treated    : `btexp'"
				di  "Controls   : `bcexp'"
		    	di  "Difference : `bdexp'"

				/* TREATED */
				qui lincom `"`btexp'"', level(`clv')
				qui return list
				#delim ;

				di in smcl in gr "{hline 13}{c TT}{hline 64}"
				_newline "Linear Trend {c |}"
				_col(21) "Coef. "
				_col(29) "Std. Err."
				_col(44) "z"
				_col(49) "P>|z|"
				_col(`=61-`cil'') `"[`clv'% Conf. Interval]"'
				_newline
				in gr in smcl "{hline 13}{c +}{hline 64}"
				_newline

				_col(1) "     Treated"
				_col(14) "{c |}" in ye
				_col(17) %9.7g r(estimate)
				_col(28) %9.7g r(se)
				_col(38) %8.2f r(z)
				_col(46) %8.3f r(p)
				_col(58) %9.7g r(lb)
				_col(70) %9.7g r(ub)
				;

				#delim cr

				/* CONTROLS */
				qui lincom `"`bcexp'"', level(`clv')
				qui return list
				#delim ;
				di  in smcl in gr
				_col(1) "    Controls"
				_col(14) "{c |}" in ye
				_col(17) %9.7g r(estimate)
				_col(28) %9.7g r(se)
				_col(38) %8.2f r(z)
				_col(46) %8.3f r(p)
				_col(58) %9.7g r(lb)
				_col(70) %9.7g r(ub);
				#delim cr
				di in gr in smcl "{hline 13}{c +}{hline 64}"

				/* DIFFERENCE */
				qui lincom `"`bdexp'"', level(`clv')
				qui return list
				#delim ;
				di  in smcl in gr
				_col(1) "  Difference"
				_col(14) "{c |}" in ye
				_col(17) %9.7g r(estimate)
				_col(28) %9.7g r(se)
				_col(38) %8.2f r(z)
				_col(46) %8.3f r(p)
				_col(58) %9.7g r(lb)
				_col(70) %9.7g r(ub);
				di in smcl in gr "{hline 13}{c BT}{hline 64}";
				#delim cr
			} /* End of TRPERIOD LOOP */
		}  /* END OF two-group posttrend LINCOM */


		/************************************************
		 *             PLOT SECTION FOR TYPE 3          *
		 ************************************************/

		if `"`figure'`figure2'"' != ""{   /* Start Figure Loop */

			/* graph; get variable labels if they exist */
			local ydesc : var label `dvar'
					if `"`ydesc'"' == "" local ydesc "`dvar'"
			local tdesc : var label `tvar'
			if `"`tdesc'"' == "" local tdesc "`tvar'"

			local treatdesc: var label `treat'
			if "`treatdesc'" == "" local treatdesc "Treated"

			local note "GEE model: family(`e(family)'), link(`e(link)'), correlation(`e(corr)')"

			 preserve
			/* Collapse actual & predicted for treat/control means */
			collapse (mean) `dvar' `prefix'_m_`dvar'_pred ///
				if `touse' [`weight' `exp'], by(`tvar' `prefix'_z)

			local istreat   `prefix'_z==1
			local iscontrol `prefix'_z==0

			qui {   /* Start Quietly Loop */
				tempvar ypred_t ypred_c
				gen `ypred_t' =  `prefix'_m_`dvar'_pred if `istreat'
				gen `ypred_c' =  `prefix'_m_`dvar'_pred if `iscontrol'

				if "`xvar'"=="" {   /*START NO XVAR LOOP*/
					local tct: word count `trperiod'
					local tmax: word `tct' of `trperiod'

					local k = 0
					foreach t in `trperiod' {
						local k = `k' + 1
						tempvar tp_t`k' plt_t`k'
						if `k'== 1 {
							gen `tp_t`k'' = `ypred_t' if `tvar'<=`t' & `istreat'
							replace `tp_t`k''=. if `tvar'==`t' & `istreat'
							ipolate `tp_t`k'' `tvar' if `tvar' <=`t' & `istreat', gen(`plt_t`k'') epolate
						}
						if `k'> 1 & `k'<=`tct' {
							local klast = `k'-1
							local tlast: word `klast' of `trperiod'
							gen `tp_t`k'' = `ypred_t' if `tvar'>=`tlast' & `tvar'<=`t' & `istreat'
							replace `tp_t`k'' = . if `tvar'==`t' & `istreat'
							ipolate `tp_t`k'' `tvar' if `tvar'>=`tlast' & `tvar'<=`t' & `istreat', ///
							gen(`plt_t`k'') epolate
						}
						if `k' ==`tct' {
							tempvar pltx_t
							gen `pltx_t' = `ypred_t' if `tvar'>=`tmax' &  `istreat'
						}
					} /* END TPERIOD LOOP */

					/* Set up Plot Variables for Treated*/
					forvalues k = 1/`tct' {
						local plotvars_t `plotvars_t'  `plt_t`k''
						local cpart `cpart' l
						local mspart `mspart' none
						local lblack `lblack' black
						local mblack `mblack' black
					}

					/* connect and msymbol options */
					local cpart c(. l `cpart')
					local lc   lcolor(black `lblack' black)
					local mc   mcolor(black `mblack' black)

					local tmspart  ms(O none `mspart')
					local plotvars_t `plotvars_t' `pltx_t'

					/* NEW CONTROL PLOT SECTION */
					local k = 0
					foreach t in `trperiod' {
						local k = `k' + 1
						tempvar tp_c`k' plt_c`k'
					if `k'== 1 {
						gen `tp_c`k'' = `ypred_c' if `tvar'<=`t' & `iscontrol'
						replace `tp_c`k''=. if `tvar'==`t' & `iscontrol'
						ipolate `tp_c`k'' `tvar' if `tvar' <=`t' & `iscontrol', gen(`plt_c`k'') epolate
					}
					if `k'> 1 & `k'<=`tct' {
						local klast = `k'-1
						local tlast: word `klast' of `trperiod'
						gen `tp_c`k'' = `ypred_c' if `tvar'>=`tlast' & `tvar'<=`t' & `iscontrol'
						replace `tp_c`k'' = . if `tvar'==`t' & `iscontrol'
						ipolate `tp_c`k'' `tvar' if `tvar'>=`tlast' & `tvar'<=`t' & `iscontrol', ///
						 gen(`plt_c`k'') epolate
					}
					if `k' ==`tct' {
						tempvar pltx_c
						gen `pltx_c' = `ypred_c' if `tvar'>=`tmax' &  `iscontrol'
					}
					} /* END TPERIOD LOOP */

					/* Set up Plot Variables */
					forvalues k = 1/`tct' {
					local plotvars_c `plotvars_c'  `plt_c`k''
					local clp `clp' dash
					}

					/* connect and msymbol options for controls */
					local cmspart  ms(Oh `mspart' none)
					local clp lpattern(blank `clp' dash)

					local plotvars_c `plotvars_c' `pltx_c'
				} /* END OF NO XVARS BLOCK */

				if "`xvar'"!=""{   /*XVARS Present*/
					local plotvars_t `ypred_t'
					local plotvars_c `ypred_c'
				}

				tempvar  dvar_t dvar_c
				gen `dvar_t' = `dvar' if `istreat'
				gen `dvar_c' = `dvar' if `iscontrol'
			} /* END Quietly Block */

			local ctrl1 = `tct'+3
			local ctrl2 = `tct'+4

			
			/* separate multiple trperiods for subtitle */
			foreach t in `trperiod' {
				local tper = strofreal(`t',"`tsf'")
				local tperlist `tperlist' `tper'
			}

			#delim ;

			 /* Titles for Two-Group Comparison */
			local titlesec
			ytitle("`ydesc'")
			xtitle("`tdesc'")
			title("`treatdesc' vs. Controls")
			subtitle("Intervention starts: `tperlist'")
			;

			if "`xvar'"' == "" {;
				twoway
				(scatter  `dvar_t' `plotvars_t'   `tvar',
						  `cpart' `tmspart' `lc' `mc')

				(scatter  `dvar_c' `plotvars_c'   `tvar',
						  `cpart' `cmspart' `lc' `mc' `clp'),
				xline(`trperiod', lpattern(shortdash) lcolor(black))
				legend(rows(2)
				order(- "`treatdesc' avg: " 1 2
					  - "Controls avg:" `ctrl1' `ctrl2')
				label(1       "Actual") label(2       "Predicted")
				label(`ctrl1' "Actual") label(`ctrl2' "Predicted")
				symxsize(8))
				`titlesec'
				note(`"`note'"')
                  `figure2';
				#delim cr
			}
			else {  /* WITH COVARIATES  */
				#delim ;
				twoway scatter
					`dvar_t' `ypred_t' `dvar_c' `ypred_c'  `tvar',
					c(. l . l) ms(O none Oh none) mcolor(black black black black )
                    lcolor(black black black black) lpattern(blank solid blank dash)
					xline(`trperiod', lpattern(shortdash) lcolor(black))
					legend(rows(2)
						order(- "`treatdesc' avg: " 1 2  - "Controls avg:" 3 4)
						label(1 "Actual") label(2 "Predicted")
						label(3 "Actual") label(4 "Predicted")
						symxsize(8))
					`titlesec'
					note(`"`note'"')
                       `figure2';
				#delim cr
			}
		}   /* End of Figure Block */
	}   /* End of Type 3 */
end

