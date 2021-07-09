*! version 1.2.0 Stephen P. Jenkins, April 2004
*! Fitting of GB2 distribution by ML
*! Called by gb2fit.ado


program define gb2fit_ll

	version 8.2
	args lnf a b p q

	quietly replace `lnf' = ln(`a') + (`a'*`p'-1)*ln($S_mlinc) ///
		- `a'*`p'*ln(`b')   ///
		- lngamma(`p') - lngamma(`q') + lngamma(`p'+`q') ///
		- (`p'+`q')*ln(1+($S_mlinc/`b')^`a')  
end

