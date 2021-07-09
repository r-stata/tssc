*! 1.0.0 Ariel Linden 04July2018

program define itsarand, rclass
version 11.0

	/* obtain settings */
	syntax varlist(min=1 numeric ts fv) [if] [in] [aw fw iw],	/// pweights not supported by -statsby-
	TREAT(varname)  			                             	///	treatment variable
	[ BLMin(integer 2)					                    	/// baseline period minimum observations
	TRMin(integer 2)											/// treatment period minimum observations
	REPs(integer 100)       									///
	SEED(string)            									///
	SAVing(string)												///
	NODOTS														///
	LEVel														/// evaluate level rather trend (the default)
	LEFT														///
	RIGHT														///
	CI(cilevel) ] 
	
	

	/* check if data is tsset with panel and time vars */
	/* -tsset- errors out if no time variable set */
	qui	tsset
	local tvar `r(timevar)'
	local pvar `r(panelvar)'

	if "`pvar'" != "" {
		if "`r(balanced)'" != "strongly balanced" {
				di as err "strong balance required"
				exit 498
		}
	}

	quietly {
		marksample touse
		count if `touse'
		if r(N) == 0 error 2000
		local N = r(N)
		replace `touse' = -`touse'
	}
	
	if "`pvar'" != "" {
		local pv "bys `pvar' (`tvar'): "
	}

	if "`left'"!="" & "`right'"!="" {
		di as err "only one of left or right can be specified"
        exit 198
	}
	
	/* get measures */
	tempvar _t
	quietly {
		`pv' gen `_t' = _n if `touse'
		sum `_t' if `touse'
		local tmax `r(max)'
		local tr_max = `tmax' - `trmin' + 1
		local tr_start = `blmin' + 1
	}
	
	gettoken dvar xvar : varlist
	
	*******************************************************************
	* run the command using the entire dataset to get test statistic *
	******************************************************************
	preserve
	quietly {
		if "`pvar'" != "" & "`level'" != "" {
			statsby x=_b[`treat'], by(`pvar') clear: regress `dvar' `treat' `xvar' if `touse' [`weight' `exp']
			qui sum x
			local xstat = r(sum)
		}
		else if "`pvar'" != "" & "`level'" == "" {
			statsby xt=_b[1.`treat'#c.`_t'], by(`pvar') clear: regress `dvar' `xvar' c.`_t'##`treat' if `touse' [`weight' `exp']
			qui sum xt
			local xstat = r(sum)
		}
		else if "`pvar'" == "" & "`level'" != "" {
			regress `dvar' `treat' `xvar' if `touse' [`weight' `exp']
			return scalar xorig = _b[`treat']
			local xstat = _b[`treat']
		}
		else if "`pvar'" == "" & "`level'" == "" {
			regress `dvar' `xvar' c.`_t'##`treat' if `touse' [`weight' `exp']
			local xstat = _b[1.`treat'#c.`_t']
		}
		return local xstat `"`xstat'"'
	
		restore
	} // end quietly
	
	/* set the seed */
	if "`seed'" != "" {
		`version' set seed `seed'
	}
	local seed `c(seed)'
	
	************************************
	*********   MC simulations  ********	
	************************************	
	tempvar start test randseq

	if "`level'" != "" {
		local names "level"
	}
	else {
		local names "trend"
	}
	
	if `"`saving'"'=="" {
		tempfile saving
		local filetmp "yes"
	}
	else {
		_prefix_saving `saving'
		local saving    `"`s(filename)'"'
		local replace   `"`s(replace)'"'
	}

	// prepare post
	tempname postnam
	
	postfile `postnam' `names' using `"`saving'"', `replace'
	
    // setup for dots
	if "`nodots'" == "" {
		di
		_dots 0, title(Permutation replications) reps(`reps')
	}

	forval i = 1/`reps' {
		
		if "`nodots'" == "" {
			_dots `i' 0
		}
	
		quietly {
		
			tempvar start test randseq
			
			gen `start' = floor((`tr_max' - `tr_start' + 1)*runiform() + `tr_start') if `touse'
			gen `test'=. if `touse'
			`pv' replace `test' = `start'[1] if `touse'
			gen `randseq' =. if `touse'
			`pv' replace `randseq' = `_t' >= `test' if `touse'

			preserve
			capture {
				if "`pvar'" != "" & "`level'" != "" {
					statsby x=_b[`randseq'], by(`pvar') clear: regress `dvar' `randseq' `xvar' if `touse' [`weight' `exp']
					qui sum x
					local stat = r(sum)
				}
				else if "`pvar'" != "" & "`level'" == "" {
					statsby xt=_b[1.`randseq'#c.`_t'], by(`pvar') clear: regress `dvar' `xvar' c.`_t'##`randseq' if `touse' [`weight' `exp']
					qui sum xt
					local stat = r(sum)
				}
				else if "`pvar'" == "" & "`level'" != "" {
					regress `dvar' `randseq' `xvar' if `touse' [`weight' `exp']
					local stat = _b[`randseq']
				}
				else if "`pvar'" == "" & "`level'" == "" {
					regress `dvar' `xvar' c.`_t'##`randseq' if `touse' [`weight' `exp']
					local stat = _b[1.`randseq'#c.`_t']
				}
			} // capture
			
			if c(rc) == 111 {
				di as err "The statistic of interest (i.e. level or trend) was omitted because of collinearity. Respecify your xvars and/or weights"
				exit 111
			}
			
			post `postnam' (`stat')
			restore
			drop `start' `test' `randseq'
		
		} //end quietly
			
	} //end forval
	postclose `postnam'

	***************************************************************
	/* load file `saving' with permutation results and evaluate  */
	***************************************************************
	preserve
	
	capture use `"`saving'"', clear
	if c(rc) {
		if c(rc) >= 900 & c(rc) <= 903 {
			di as err "insufficient memory to load file with permutation results"
		}
		error c(rc)
	}

	/* Evaluate observed data relative to original data */

	di _n
	tempname tobs c n p //se ll ul ci
	
	quietly {
			
		/* "T(obs)" */
		scalar `tobs' = `xstat'
			
		/* Get name of variable in saving dataset */
		describe, varlist
		local name = r(varlist)
			
		/* Get count of actual reps */
		count
		scalar `n' =  r(N)
			
		/* left, right or absolute */
		if "`left'"!="" {
			count if `name' <= `xstat'
			local event "T <= T(obs)"
		}
		else if "`right'"!="" {
			count if `name' >= `xstat'
			local event "T >= T(obs)"
		}
		else {
			count if abs(`name') >= abs(`xstat')
			local event "|T| >= |T(obs)|"
		}
			
		scalar `c' =  r(N)
		scalar `p' = `c' / `n'
		return scalar n =  `n'		
		return scalar c =  `c'
		return scalar p = `p'
		
		/* get CIs */
		cii_14_0 `n' `c' , level(`ci')
		tempname se ll ul
		scalar `se' =  r(se)
		scalar `ll' = r(lb)
		scalar `ul' = r(ub)
		
	} // end quietly
		
	*******************
	* Display results *
	*******************
	
	disp ""
	disp "Monte Carlo permutation results                    Number of obs   = "  %9.0g as result  `N'
	disp ""
	tempname Tab results
    .`Tab' = ._tab.new, col(8) lmargin(0) //ignore(.b)
    ret list
    // column           1      2     3     4     5     6     7     8
    .`Tab'.width       13    |12     8     8     8     8    10    10
    .`Tab'.titlefmt %-12s      .     .     .     .     .  %20s     .
    .`Tab'.pad          .      2     0     0     0     0     0     1
    .`Tab'.numfmt       .  %7.4g     .     . %7.4f %7.4f     .     .
	.`Tab'.sep, top
    .`Tab'.titles "T" "T(obs)" "c" "n" "p=c/n" "SE(p)" "[`ci'% Conf. Interval]" ""
	.`Tab'.sep, middle
	.`Tab'.row    "`name'" 				///
		`tobs'							///
		`c'								///
		`n'								///
		`p'								///
		`se'							///
		`ll'							///
		`ul'
	.`Tab'.sep, bottom

	/* Table footnote */
	di as txt ///
	"Note: Confidence intervals are with respect to p=c/n."
     di in smcl as txt "Note: c = #{`event'}"

	/* restore to orginal file */
	restore
	
end
	