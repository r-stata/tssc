*! 1.0.0 Ariel Linden 25mar2015 

/* 	Framingham Cardiovascular Disease Predictions (10-year risk), from:
	
	D’Agostino, R. B., Vasan, R. S., Pencina, M. J., Wolf, P. A., Cobain, M., Massaro, J. M., & Kannel, W. B. (2008). 
	General cardiovascular risk profile for use in primary care the Framingham Heart Study. Circulation, 117(6), 743-753.

	see also: http://www.framinghamheartstudy.org/risk-functions/cardiovascular-disease/10-year-risk.php

*/

program framinghami, rclass
	version 13.0
	syntax ,  ///
		Male(integer)  	///
		AGE(numlist)   	///
		SBP(integer)  	///
		TRhtn(integer) 	///
		SMoke(integer) 	///
		DIAB(integer) 	///
		HDL(numlist) 	///
		CHOL(numlist) 	///
		[ OPTimal ]

	/* check to ensure binary variables contain 0 or 1 */
	if `male' > 1 {
		di as err "male must be coded as either 0 or 1"
				exit 498
		}
	if `trhtn' > 1 {
		di as err "trhtn must be coded as either 0 or 1"
				exit 498
		}
	if `smoke' > 1 {
		di as err "smoke must be coded as either 0 or 1"
				exit 498
		}
	if `diab' > 1 {
		di as err "diab must be coded as either 0 or 1"
				exit 498
		}

	
	tempname risk adjrisk optrisk adjoptrisk
	
	if `male' == 1 & `trhtn' == 0 {
		scalar `risk' = ln(`age') * 3.06117 + ln(`sbp') * 1.93303 + ln(`chol') * 1.1237 + ln(`hdl') * -0.93263 + `smoke' * 0.65451 + `diab' * 0.57367
	}
	else if `male' == 1 & `trhtn' == 1 {
		scalar `risk' = ln(`age') * 3.06117 + ln(`sbp') * 1.99881 + ln(`chol') * 1.1237 + ln(`hdl') * -0.93263 + `smoke' * 0.65451 + `diab' * 0.57367
	}
	else if `male' == 0 & `trhtn' == 0 {
		scalar `risk' = ln(`age') * 2.32888 + ln(`sbp') * 2.76157 + ln(`chol') * 1.20904 + ln(`hdl') * -0.70833 + `smoke' * 0.52873 + `diab' * 0.69154
	}
	else if `male' == 0 & `trhtn' == 1 {
		scalar `risk' = ln(`age') * 2.32888 + ln(`sbp') * 2.82263 + ln(`chol') * 1.20904 + ln(`hdl') * -0.70833 + `smoke' * 0.52873 + `diab' * 0.69154
	}
	
	if `male' == 1 {
		scalar `adjrisk' = 1 - 0.88936^exp(`risk'- 23.9802)
	}
	else if `male' == 0 {
		scalar `adjrisk' = 1 - 0.95012^exp(`risk'- 26.1931)
	}

	return scalar risk10 = `adjrisk'
	
	if "`optimal'" != "" {
		if `male' == 1 {
		scalar `optrisk' = ln(`age') * 3.06117 + ln(110) * 1.93303 + ln(160) * 1.1237 + ln(60) * -0.93263 
		scalar `adjoptrisk' = 1 - 0.88936^exp(`optrisk'- 23.9802)
		}
		
		else if `male' == 0 {
		scalar `optrisk' = ln(`age') * 2.32888 + ln(110) * 2.76157 + ln(160) * 1.20904 + ln(60) * -0.70833
		scalar `adjoptrisk' = 1 - 0.95012^exp(`optrisk'- 26.1931)
		}
	}
		
	if "`optimal'" != "" {
		return scalar optrisk10 = `adjoptrisk'
	}
	
// display results
    di 
	di as txt "   Your 10-Year CVD Risk Prediction: " as result %4.1f `adjrisk'  * 100 " %"
	
	if "`optimal'" !="" {
	di as txt "   Optimal Risk for Your Age and Gender: " as result %4.1f `adjoptrisk'  * 100 " %" 
	}
	
end
