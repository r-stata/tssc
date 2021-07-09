*! version 1.2.0 Stephen P. Jenkins, April 2004
*! Fitting of Singh-Maddala distribution by ML
*! Called by smfit.ado

program define smfit_ll

	version 8.2
	args lnf a b q

	quietly replace `lnf' = ln(`a') + ln(`q') ///
		- (`q'+1)*ln(1+($S_mlinc/`b')^`a')  /// 
		- `a'*ln(`b') + (`a'-1)*ln($S_mlinc)

end

