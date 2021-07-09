*! Attaullah Shah ;  Email: attaullah.shah@imsciences.edu.pk
*! Support website: www.OpenDoors.Pk

*! Version 3.4 : July 9, 2019 : Added adjusted r-squared to fmb
*! Version 3.3 : Dec 19, 2018 : Fixed a bug in  function ASREG4s1f1()
*! Version 3.1 : July 2018: newey() fixing
*! Added noConstant and Robust options
*! Added Fama and MacBeth regressions and newey SE
*! Multiple functions for se and fitted values



prog asreg, byable(onecall) sortpreserve eclass

	                                version 11
	                          syntax       	///
		            varlist(min=1)     ///
		        [in] [if],      ///
		     [Window(string) ///
		   MINimum(real 0) ///
		  by(varlist)     ///
		 FITted         ///
		SE            	///
		RMSE			///
		RECursive		///
		FMB				///
		newey(int 0)    ///
		first    		///
		save(string)	///
		KEEP(string)	///
		NOConstant      ///
		Robust			///
	] 	
	marksample touse
	if "`fmb'" == "" {
		if "`window'"!=""{
			local nwindow : word count `window'
			if `nwindow'!=2 {
				dis ""
				display as error "Option window must have two arguments: rangevar and length of the rolling window"
				display as text " e.g, If your range variable is year, then the syntax would be {opt window(year 10)}"
				exit
			}
			else if `nwindow'==2 {
				tokenize `window'
				gettoken    rangevar window : window
				gettoken  rollwindow window : window
			}
			if "`recursive'"~=""{
				local recursive = 1000000
			}
			else{
				local recursive = 0 
			}
			confirm number `rollwindow'

			local rollwindow = `rollwindow' + `recursive'
			
			confirm numeric variable `rangevar'
			if `rollwindow' <=1 {
				dis ""
				display as error "Length of the rolling window should be at least 1"
				display as res " Alternatively, If you are interested in statistics over a grouping variable, you should omit the {opt w:indow} otpion"
				exit
			}
		}

		
		
		gettoken lhsvar rhs : varlist
		loc varlist "`lhsvar' `rhs'"
		qui {
			if "`rmse'"!="" {
				qui gen double _rmse = .
				label var _rmse "Root-mean-squared error"
				local _b_rmse _rmse
			}

			gen  _Nobs 	= .
			label var _Nobs "No of observatons"
			gen double _R2 	= .
			label var _R2 "R-squared"
			gen double _adjR2	= .
			label var _adjR2 "Adjusted R-squared"
			

			foreach var of varlist `rhs'{
				gen double _b_`var'=.
				label var _b_`var' "Coefficient of `var'"
				local b_rvsvars "`b_rvsvars' _b_`var'"

			}
			if `newey' != 0 {
				loc mindif = `newey' - `minimum' +1
				loc minimum = `mindif'
			}

			if "`noconstant'" == "" {
			tempvar _CONS
				qui gen `_CONS' = 1
				gen double _b_cons = .
				label var _b_cons "Constant of the regression"
				loc _b_cons _b_cons
			}
			
			if "`newey'" ! = "0" | "`robust'" ! = "" loc se se

			if "`se'"!=""{
				if `newey' != 0 & "`robust'" != "" {
					dis as error "Option newey() and robust cannot be combined"
					exit
				}
				if `newey' != 0 local se_text "Newey adj. Std. errors of "
				else if "`robust'" != "" local se_text "Robust Std. errors of "
				else local se_text "Standard Std. errors of "
					
					foreach var of varlist `rhs'{
						gen _se_`var'=.
						label var _se_`var' "`se_text'`var'"
						local _se_rvsvars "`_se_rvsvars' _se_`var'"
					}
					if "`noconstant'" == "" { 
						gen _se_cons = .
						label var _se_cons "`se_text'constant"
						loc _se_cons _se_cons
					}
				local _se_rvsvars "`_se_rvsvars' `_se_cons'"
			}
			if ("`fitted'"!="") {
				gen double  _fitted =.
				gen double  _residuals =.
				local fitres "_fitted _residuals"
			}

		local ResultsVars "_Nobs _R2 _adjR2   `b_rvsvars' `_b_cons' `_se_rvsvars'  `fitres' `_b_rmse'"
		}

		if "`_byvars'"!="" {
			local by "`_byvars'"
		}

		tempvar GByVars first dif
		if "`by'"!="" {
			bysort `by' (`rangevar'): gen  `first' = _n == 1
			qui gen `GByVars'=sum(`first')
			qui by `by' : gen `dif'=`rangevar'-`rangevar'[_n-1]
			qui drop `first'
		}
		else {
			qui gen `GByVars'=1
			qui bys `GByVars' (`rangevar'): gen `dif'=`rangevar'-`rangevar'[_n-1]
		}
		
													if "`rollwindow'"!="" {
												mata: ASREGW(				///
											"`varlist' `_CONS'",  	///
										"`GByVars'" ,		   	///
									"`ResultsVars'" , 	 	///
								`rollwindow',		    /// 
							`minimum', 	       		///
						`newey' ,			  	///
					"`rangevar'",	      	///
				"`dif'"	,				///
			"`se'",           		///
			"`fitted'",      		/// 
			`c(version)' ,  		///
			"`rmse'",				///
			"`robust'",     		///
			"`noconstant'",  		///
			"`touse'"	    		///
			)
			}
			else  {

			mata: ASREGNW(         	///
			"`varlist' `_CONS'",    ///
			"`GByVars'" ,			///
			"`ResultsVars'" , 		///
			"`se'", 				///
			"`fitted'",				///
			`minimum',				///
			`newey' , 				///
			"`rmse'",				///
			"`robust'",		    	///
			"`noconstant'",  		///
			"`touse'"	         	///
			)
		}
		cap qui label variable `generate' "`stat' of `varlist' in a `rollwindow'-periods rol. wind."
		if "`keep'"!="" {
			local keep _fitted
			qui cap unab v : _se_*
			cap confirm var _fitted 
			if _rc==0 local var `var' _fitted _residuals
			cap noi unab b : _b_*
			local all `b' `var' _R2 _adjR2 _Nobs
			local drop : list all - keep
			drop `drop'
		}
	} 
	
	else { 
	marksample touse
	preserve
	qui _xt
	local _byvars `r(tvar)'
	sort `_byvars'
	local nvars : word count `varlist'
	if `newey'<0 { 
		di in red `"newey(`newey') invalid lag selected"'
		exit 198
	}

	gettoken lhsvar rhs : varlist
	
	tsrevar `lhsvar'
	loc lhsvar  `r(varlist)'
	
	tsrevar, list
	tsrevar `rhs'
	loc rhsvars  `r(varlist)'
	tsrevar `rhs', list
	loc rhs  `r(varlist)'
	loc varlist "`lhsvar' `rhsvars'"
	

	qui count if `touse'
    local observations = r(N)
	
	qui {	
		foreach i of varlist `rhs'{
			gen double _b_`i'=.
			local b_rvsvars "`b_rvsvars' _b_`i'"

		}

		cap drop _TimeVar obs R2 cons 
		gen _Cons = .
		gen _R2 = .
		gen _adjR2 = .
		gen _TimeVar = .
		gen _obs = .

		local ResultsVars "_TimeVar _obs _R2 _adjR2  `b_rvsvars' _Cons "
	}
	
	mata: ASREGFMB("`varlist'", "`_byvars'" , "`ResultsVars'" , "`touse'")
	qui count if _obs!=.
	loc periods = r(N)
	if "`save'"~="" {
		keep if _obs!=.
		qui save "`save'", replace
	}
	
	 if "`first'"~=""{
		foreach v of varlist `ResultsVars' {
			qui format %8.0g `v'
		}
		display "{title:First stage Fama-McBeth regression results}"
		list `ResultsVars' in 1/`periods' , noobs mean separator(0)
	 }

	
	 local nVARs : word count `b_rvsvars' +1
	 if `newey'==0 	mata: FMB2("`b_rvsvars'")			
	 else mata: FMB3("`b_rvsvars'", `nVARs', `newey')
		 
	 foreach var of local rhsvars {
		local Labels "`Labels' :`var'"
	}
	
	qui sum _R2
	ereturn local avgr2 = r(mean)
	qui sum _adjR2, meanonly
	
	ereturn local adjR2 = r(mean)
	
	restore		
	matrix rownames b = `lhsvar'
	matrix colnames b = `Labels' :_cons
	matrix rownames v = `Labels' :_cons
	matrix colnames v = `Labels' :_cons

	ereturn clear
	ereturn post b v, esample(`touse') depname("`lhsvar'")

	ereturn scalar N = `observations'
	ereturn scalar N_g = `periods'
	ereturn scalar df_m = wordcount("`rhsvars'")
	ereturn scalar df_r = `periods' - 1
	
	qui if "`rhsvars'"!=""  test `rhsvars', min  
	ereturn scalar F = r(F)

	ereturn scalar r2 = `avgR2'
	ereturn scalar adjr2 = `adjR2'

	if `newey' == 0 {
		ereturn local vcetype "Fama-MacBeth"
		local title "Fama-MacBeth (1973) Two-Step procedure"
	
	} 
	else {
		ereturn local vcetype "Newey-FMB"
		ereturn local title "Fama-MacBeth Two-Step procedure (Newey SE)"
		local title "Fama-MacBeth Two-Step procedure (Newey SE)"
		local Newey_Text "(Newey-West adj. Std. Err. using lags(`newey'))"

	}

	ereturn local depvar "`lhsvar'"
	ereturn local method "Fama-MacBeth Two-Step procedure"
	ereturn local cmd "asreg"
	local R2text "avg. R-squared    =    "
	local adjR2text "Adj. R-squared    =    "
	#delimit ;
		disp _n
		  in green `"`title'"'
		  _col(50) in green `"Number of obs     ="' in yellow %10.0f `observations' _n
		  in green "`Newey_Text'"
		  _col(50) in green `"Num. time periods ="' in yellow %10.0f e(N_g) _n
		  _col(50) in green `"F("' in yellow %3.0f e(df_m) in green `","' in yellow %6.0f e(df_r)
		  in green `")"' _col(68) `"="' in yellow %10.2f e(F) _n
		  _col(50) in green `"Prob > F          =    "' 
		  in yellow %6.4f fprob(e(df_m),e(df_r),e(F)) _n 
		  _col(1) in green `"`SE_Text'"'
		  _col(50) in green `"`R2text'"' in yellow %5.4f `avgR2' _n
		  _col(50) in green `"`adjR2text'"' in yellow %5.4f `adjR2'
		  ;
		#delimit cr
	ereturn display, level(95)

	
	if "`save'"~="" {
	
		preserve
		
		use "`save'", clear
		qui keep `ResultsVars'
		qui save "`save'", replace
		di as smcl `"First stage regression results saved in {browse "`save'.dta"}"'
		}
	}
end
