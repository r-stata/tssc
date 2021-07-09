*! NJC 1.0.0 6 Nov 2003 
program betafit_lf
	version 8.1
	args lnf alpha beta 
	qui replace `lnf' = ///
	lngamma(`beta' + `alpha') - lngamma(`alpha') - lngamma(`beta') ///
	+ ln($S_MLy^(`alpha' - 1)) + ln((1 - $S_MLy)^(`beta' - 1)) 

end 		
