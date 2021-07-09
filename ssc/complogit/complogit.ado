*! version 1.0, 30 September 2004, ghoetker@uiuc.edu

program define complogit
	version 8.0
	syntax varlist, Group(varlist min=1 max=1)  ///
	[NUMerator(varlist min=1 max=1)] [DENominator(varlist min=1 max=1)] ///
	[SPecific(varlist min=1 max=1)]
	capture program drop complogitml
	capture estimates drop all zero one allison_1 allison_2
	
//Parse variable list
	gettoken dep xvars : varlist
	
//Run logit equations and save results
	
	display as text "{hline 80}
	display as text "{hline 80}
	display as text "Estimation of logit models"
	display as text "{hline 80}
	display as text "{hline 80}
	display _newline(2)
	display as text "{hline 80}
	display as text "Both groups together for future use"
	display as text "{hline 80}
	logit `dep' `xvars'
	estimates store all
	tempvar zero one two interaction

	display as text _newline"{hline 80}
	display as text  "Estimating " "`group'"  "=0"
	display as text "{hline 80}
	logit `dep' `xvars' if `group'==0, score(`zero')
	estimates store zero
	estimates change zero, scorevar(`zero')

	display as text _newline"{hline 80}
	display as text "Estimating " "`group'"  "=1" 
	display as text "{hline 80}
	logit `dep' `xvars' if `group'==1, score(`one')
	estimates store one
	estimates change one, scorevar(`zero')
	
	logit `dep' `xvars' `group', score(`two')
	estimates store two
	estimates change two, scorevar(`zero')
	
	display as text _newline"{hline 80}
	display as text "Allowing residual variation to differ"
	display as text"{hline 80}"
	ml model lf complogitml (`dep'=`xvars' `group') (delta: `group', nocons)
	ml search
	ml maximize, difficult
	estimates store allison_1
	
	
// Estimate if residual variation differs across groups by likelihood ratio
	display as text _newline(5)"{hline 80}
	display as text "{hline 80}
	display as text "Tests of residual variation and coefficients across groups"
	display as text "{hline 80}
	display as text "{hline 80}
	display as text _newline "{hline 80}
	display as text "Likelihood ratio test to reject" ///
	" null hypothesis of equal residual variation" _newline "{hline 80}"
	lrtest two allison_1, force
	
// Estimate if residual variation differs across groups by Wald test
	display as text _newline "{hline 80}
	display as text "Wald chi-square test to reject" ///
	" null hypothesis of equal residual variation" _newline "{hline 80}"
	test [delta]`group'==0
	
// Test if ANY coefficient differs
	display as text _newline "{hline 80}
	display as text "Likelihood ratio test to reject" ///
	" null hypothesis that all coefficients are the same" _newline "{hline 80}"
	lrtest (zero one) allison_1, force
	
// Test of whether specific coefficient differs	
	if "`specific'"~="" {
	capture drop I_`group'_`specific'
	gen I_`group'_`specific'=`group'*`specific'
	ml model lf complogitml (`dep'=`xvars' `group' I_`group'_`specific' ) (delta: `group', nocons)
	ml search
	ml maximize, difficult
	estimates store allison_2
	
	// Wald test
	display as text _newline "{hline 80}
	display as text "Likelihood ratio test to reject" ///
	" null hypothesis that coefficient of" _newline "`specific'" ///
	" is the same across groups" _newline "{hline 80}"
	display as text "Test assumes that all other coefficients are equal!"
	test I_`group'_`specific'==0
	
	//LR test
	display as text _newline "{hline 80}
	display as text "Wald chi-square test to reject" ///
	" null hypothesis that coefficient of" _newline "`specific'" ///
	" is the same across groups" _newline "{hline 80}"
	display as text "Test assumes that all other coefficients are equal!"
	lrtest allison_1 allison_2
	}

//Test of ratios	
	
	if "`numerator'"~="" {
	suest zero one
	display as text _newline "{hline 80}
	display as text "Wald chi-square test to reject" ///
	" null hypothesis that the ratio " _newline "`numerator'/" ///
	"`denominator' is the same across groups" _newline "{hline 80}"


	testnl [zero]`numerator'*[one]`denominator'=[zero]`denominator'*[one]`numerator'
	}

	
end


