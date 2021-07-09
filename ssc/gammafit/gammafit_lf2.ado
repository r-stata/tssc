*! NJC 2.0.0 12 May 2011 
*! NJC 1.0.0 5 Nov 2003 
program gammafit_lf2
	version 8.1
	args lnf alpha beta
	qui replace `lnf' = ///
	`alpha' * ln(`beta') - lngamma(`alpha') + (`alpha' - 1) * ln($S_MLy) - (`beta' * $S_MLy) 
end 		

