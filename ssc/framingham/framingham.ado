*! 1.0.0 Ariel Linden 25mar2015 

/* 	Framingham Cardiovascular Disease Event Predictions (10-year risk), from:
	
	D’Agostino, R. B., Vasan, R. S., Pencina, M. J., Wolf, P. A., Cobain, M., Massaro, J. M., & Kannel, W. B. (2008). 
	General cardiovascular risk profile for use in primary care the Framingham Heart Study. Circulation, 117(6), 743-753.

	see also: http://www.framinghamheartstudy.org/risk-functions/cardiovascular-disease/10-year-risk.php
	
*/

program framingham, rclass
	version 13.0
	syntax [if] [in] ,  ///
		Male(varname numeric)  	/// integer 0 or 1
		AGE(varname numeric)    /// 
		SBP(varname numeric)  	///
		TRhtn(varname numeric) 	/// integer 0 or 1
		SMoke(varname numeric) 	/// integer 0 or 1
		DIAB(varname numeric) 	/// integer 0 or 1
		HDL(varname numeric) 	///
		CHOL(varname numeric) 	///
		[ OPTimal				///
		REPLace SUFFix(str) *]

	marksample touse 
	markout `touse' `v' `sbp' `hdl' `chol' `male' `trhtn' `smoke' `diab' 

	qui count if `touse' 
	if r(N) == 0 error 2000 

	/* check to ensure binary variables contain 0 or 1 */
	foreach v in  `male' `trhtn' `smoke' `diab' {
		capture assert inlist(`v', 0, 1) if `touse' 
		if _rc { 
			di as err "`v' contains values other than 0 or 1" 
			exit 498 
		} 
	} 

	/* drop variables if option "replace" is chosen */
	if "`replace'" != "" {
		local framvars : char _dta[framvars`suffix'] 
			if "`framvars'" != "" {
				foreach f of local framvars { 
				capture drop `f' 
				}
			}
		}
	
	quietly {
	
	tempvar risk 
	
	gen `risk' =.
		
		replace `risk' = ln(`age') * 3.06117 + ln(`sbp') * 1.93303 + ln(`chol') * 1.1237 + ln(`hdl') * -0.93263 + `smoke' * 0.65451 + `diab' * 0.57367 if `male' == 1 & `trhtn' == 0 & `touse'
	
		replace `risk' = ln(`age') * 3.06117 + ln(`sbp') * 1.99881 + ln(`chol') * 1.1237 + ln(`hdl') * -0.93263 + `smoke' * 0.65451 + `diab' * 0.57367 if `male' == 1 & `trhtn' == 1 & `touse'
	
		replace `risk' = ln(`age') * 2.32888 + ln(`sbp') * 2.76157 + ln(`chol') * 1.20904 + ln(`hdl') * -0.70833 + `smoke' * 0.52873 + `diab' * 0.69154 if `male' == 0 & `trhtn' == 0 & `touse'

		replace `risk' = ln(`age') * 2.32888 + ln(`sbp') * 2.82263 + ln(`chol') * 1.20904 + ln(`hdl') * -0.70833 + `smoke' * 0.52873 + `diab' * 0.69154 if `male' == 0 & `trhtn' == 1 & `touse'
	
	gen risk10`suffix' =.
	
		replace risk10`suffix' = 1 - 0.88936^exp(`risk'- 23.9802) if `male' == 1 & `touse'
	
		replace risk10`suffix' = 1 - 0.95012^exp(`risk'- 26.1931) if `male' == 0 & `touse'
	
		
	if "`optimal'" !="" { 
	
	tempvar optrisk
	
	gen `optrisk' =.
	
		replace `optrisk' = ln(`age') * 3.06117 + ln(110) * 1.93303 + ln(160) * 1.1237 + ln(60) * -0.93263 if `male' == 1 & `touse'
	
		replace `optrisk' = ln(`age') * 2.32888 + ln(110) * 2.76157 + ln(160) * 1.20904 + ln(60) * -0.70833 if `male' == 0 & `touse'
	
	gen optrisk10`suffix' =.
	
		replace optrisk10`suffix' = 1 - 0.88936^exp(`optrisk'- 23.9802) if `male' == 1 & `touse'
	
		replace optrisk10`suffix' = 1 - 0.95012^exp(`optrisk'- 26.1931) if `male' == 0 & `touse'
	
	}
	
	local framvars risk10`suffix' optrisk10`suffix'
	char def _dta[framvars`suffix'] "`framvars'" 
	
	} // close quietly loop
	
end
