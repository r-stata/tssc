*! version 1.2.0 Stephen P. Jenkins, April 2004
*! Fitting of Dagum distribution by ML
*! Called by dagumfit.ado

program define dagumfit_ll

	version 8.2
	args lnf a b p

	quietly replace `lnf' = ln(`a') + ln(`p') + `a'*ln(`b') ///
		- (`a'+1)*ln($S_mlinc)  /// 
		- (`p'+1)*ln(1+(`b'/$S_mlinc)^(`a'))

end

